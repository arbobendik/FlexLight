#version 300 es
#define TRIANGLES_PER_ROW_POWER 8
#define TRIANGLES_PER_ROW 256
#define PI 3.141592653589793
#define PHI 1.61803398874989484820459
#define SQRT3 1.7320508075688772
#define POW32 4294967296.0
#define BIAS 0.0000152587890625
#define THIRD 0.3333333333333333
#define INV_PI 0.3183098861837907
#define INV_256 0.00390625
#define INV_255 0.00392156862745098
#define INV_65536 0.0000152587890625

precision highp int;
precision highp float;
precision highp sampler2D;

struct NormalizedRay {
    vec3 target;
    vec3 unitDirection;
};
struct Ray {
    vec3 origin;
    vec3 target;
    vec3 direction;
    vec3 unitDirection;
};
struct Material {
    vec3 albedo;
    vec3 rme;
    vec3 tpo;
};

in vec3 position;
in vec2 uv;
in vec3 clipSpace;

flat in vec3 camera;
flat in int fragmentTriangleId;
flat in int transformationId;

layout (std140) uniform transformMatrix
{
    mat3 rotation[MAX_TRANSFORMS];
    vec3 shift[MAX_TRANSFORMS];
};

// Quality configurators
uniform int samples;
uniform int maxReflections;
uniform float minImportancy;
uniform int useFilter;
uniform int isTemporal;

uniform float randomSeed;
// Get global illumination color, intensity
uniform vec3 ambient;
// Textures in parallel for texture atlas
uniform int textureWidth;

// Texture with information about all triangles in scene
uniform sampler2D geometryTex;
uniform sampler2D sceneTex;
uniform sampler2D translucencyTex;
uniform sampler2D pbrTex;
uniform sampler2D tex;

// Texture with all primary light sources of scene
uniform sampler2D lightTex;

layout(location = 0) out vec4 renderColor;
layout(location = 1) out vec4 renderColorIp;
layout(location = 2) out vec4 renderOriginalColor;
layout(location = 3) out vec4 renderId;
layout(location = 4) out vec4 renderOriginalId;
layout(location = 5) out vec4 renderLocationId;

float invTextureWidth = 1.0f;
// Prevent blur over shadow border or over (close to) perfect reflections
float firstRayLength = 1.0f;
// Accumulate color of mirror reflections
float glassFilter = 0.0f;
float originalRMEx = 0.0f;
float originalTPOx = 0.0f;
vec3 originalColor = vec3(1.0f);

float to4BitRepresentation(float a, float b) {
    uint aui = uint(a * 255.0f) & uint(240);
    uint bui = (uint(b * 255.0f) & uint(240)) >> 4;
    return float(aui + bui) * INV_255;
}

float normalToSphearical4BitRepresentation(vec3 n) {
    float phi = (atan(n.z, n.x) * INV_PI) * 0.5f + 0.5f;
    float theta = (atan(n.x, n.y) * INV_PI) * 0.5f + 0.5f;
    return to4BitRepresentation(phi, theta);
}

vec3 combineNormalRME(vec3 n, vec3 rme) {
    return vec3(normalToSphearical4BitRepresentation(n), rme.x, to4BitRepresentation(rme.y, rme.z));
}

// Lookup values for texture atlases
vec3 lookup(sampler2D atlas, vec3 coords) {
    float atlasHeightFactor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) * invTextureWidth;
    vec2 atlasCoords = vec2((coords.x + mod(coords.z, float(textureWidth))) * invTextureWidth, (coords.y + floor(coords.z * invTextureWidth)) * atlasHeightFactor);
    // Return texel on requested location
    return texture(atlas, atlasCoords).xyz;
}

vec4 noise(vec2 n, float seed) {
    return fract(sin(dot(n.xy, vec2(12.9898f, 78.233f)) + vec4(53.0f, 59.0f, 61.0f, 67.0f) * (seed + randomSeed * PHI)) * 43758.5453f) * 2.0f - 1.0f;
}

mat3 moellerTrumbore(float l, NormalizedRay ray, vec3 a, vec3 b, vec3 c) {
    vec3 edge1 = b - a;
    vec3 edge2 = c - a;
    vec3 pvec = cross(ray.unitDirection, edge2);
    float det = dot(edge1, pvec);
    if(abs(det) < BIAS) return mat3(0);
    float inv_det = 1.0f / det;
    vec3 tvec = ray.target - a;
    float u = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) return mat3(0);
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unitDirection, qvec) * inv_det;
    float uvSum = u + v;
    if(v < BIAS || uvSum > 1.0f) return mat3(0);
    float s = dot(edge2, qvec) * inv_det;
    if(s > l || s <= BIAS) return mat3(0);
    // Calculate intersection point
    vec3 d = (s * ray.unitDirection) + ray.target;
    return mat3(
        d,
        vec3(1.0f - uvSum, u, v), 
        vec3(s, 0, 0)
    );
}

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
bool moellerTrumboreCull(float l, NormalizedRay ray, vec3 a, vec3 b, vec3 c) {
    vec3 edge1 = b - a;
    vec3 edge2 = c - a;
    vec3 pvec = cross(ray.unitDirection, edge2);
    float det = dot(edge1, pvec);
    float invDet = 1.0f / det;
    if(det < BIAS) return false;
    vec3 tvec = ray.target - a;
    float u = dot(tvec, pvec) * invDet;
    if(u < BIAS || u > 1.0f) return false;
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unitDirection, qvec) * invDet;
    if(v < BIAS || u + v > 1.0f) return false;
    float s = dot(edge2, qvec) * invDet;
    return (s <= l && s > BIAS);
}

// Don't return intersection point, because we're looking for a specific triangle not bounding box
bool rayCuboid(float l, vec3 invRay, vec3 p, vec3 minCorner, vec3 maxCorner) {
    vec3 v0 = (minCorner - p) * invRay;
    vec3 v1 = (maxCorner - p) * invRay;
    float tmin = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));
    float tmax = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));
    return tmax >= max(tmin, BIAS) && tmin < l;
}

/*
bool raySphere(float l, Ray ray, vec3 c, float r2) {
    vec3 diff = c - ray.target;
    float cosa = dot(diff, ray.unitDirection);
    // if (cosa < 0.0f) return false;
    float d2 = dot(diff, diff) - cosa * cosa;
    if (d2 > r2) return false;
    float thc = sqrt(r2 - d2);
    return l > cosa - abs(thc);
}
*/

// Test for closest ray triangle intersection
// Return intersection position in world space (rayTracer[0].xyz) and index of target triangle in geometryTex (rayTracer[1].w)
mat3 rayTracer(Ray ray) {
    // Cache transformed ray attributes
    NormalizedRay tR = NormalizedRay(ray.target, ray.unitDirection);
    // Inverse of transformed normalized ray
    vec3 invDir = 1.0 / ray.unitDirection;
    int cachedTI = 0;
    // Latest intersection which is now closest to origin
    mat3 intersection = mat3(0, 0, 0, 0, 0, 0, 0, -1, 0);
    // Length to latest intersection
    float minLen = POW32;
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * TRIANGLES_PER_ROW;
    // Iterate through lines of texture
    for(int i = 0; i < size; i++) {
        float fi = float(i);
        // Get position of current triangle/vertex in geometryTex
        int triangleColumn = i >> TRIANGLES_PER_ROW_POWER;
        ivec2 index = ivec2((i - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);
        // Fetch triangle coordinates from scene graph
        vec4 t0 = texelFetch(geometryTex, index, 0);
        vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);
        vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);

        vec3 a = t0.xyz;
        vec3 b = vec3(t0.w, t1.xy);
        vec3 c = vec3(t1.zw, t2.x);

        int tI = int(t2.y) << 1;
        // Test if cached transformed variables are still valid
        if (tI != cachedTI) {
            int iI = tI + 1;
            cachedTI = tI;
            tR = NormalizedRay(
                rotation[iI] * (ray.target + shift[iI]),
                rotation[iI] * ray.unitDirection
            );
            invDir = 1.0 / tR.unitDirection;
        }
        // Three cases:
        // c is X 0 0        => is bounding volume: do AABB intersection test
        // c is 0 0 0        => end of list: stop loop
        // otherwise         => is triangle: do triangle intersection test
        if(c.yz == vec2(0)) {
            if(c.x == 0.0f) break;
            if(!rayCuboid(minLen, invDir, tR.target, a, b)) i += int(c.x);
        } else {
            // Test if triangle intersects ray
            mat3 currentIntersection = moellerTrumbore(minLen, tR, a, b, c);
            // Test if ray even intersects
            if(currentIntersection[2].x != 0.0f) {
                // Translate intersection point back to absolute space.
                currentIntersection[0] = rotation[tI] * currentIntersection[0] + shift[tI];
                minLen = currentIntersection[2].x;
                intersection = currentIntersection;
                intersection[2].y = fi;
                intersection[2].z = t2.y;
            }
        }
    }
    // Return if pixel is in shadow or not
    return intersection;
}


// Simplified rayTracer to only test if ray intersects anything
bool shadowTest(Ray ray) {
    // Cache transformed ray attributes
    NormalizedRay tR = NormalizedRay(ray.target, ray.unitDirection);
    // Inverse of transformed normalized ray
    vec3 invDir = 1.0 / ray.unitDirection;
    int cachedTI = 0;
    // Precomput max length
    float minLen = length(ray.direction);
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * TRIANGLES_PER_ROW;
    // Iterate through lines of texture
    for(int i = 0; i < size; i++) {
        // Get position of current triangle/vertex in geometryTex
        int triangleColumn = i >> TRIANGLES_PER_ROW_POWER;
        ivec2 index = ivec2((i - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);
        // Fetch triangle coordinates from scene graph
        vec4 t0 = texelFetch(geometryTex, index, 0);
        vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);
        vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);

        vec3 a = t0.xyz;
        vec3 b = vec3(t0.w, t1.xy);
        vec3 c = vec3(t1.zw, t2.x);

        int tI = int(t2.y) << 1;
        // Test if cached transformed variables are still valid
        if (tI != cachedTI) {
            int iI = tI + 1;
            cachedTI = tI;
            tR = NormalizedRay(
                rotation[iI] * (ray.target + shift[iI]),
                rotation[iI] * ray.unitDirection
            );
            invDir = 1.0 / tR.unitDirection;
        }
        // Three cases:
        // c is X 0 0        => is bounding volume: do AABB intersection test
        // c is 0 0 0        => end of list: stop loop
        // otherwise         => is triangle: do triangle intersection test
        if(c.yz == vec2(0)) {
            if(c.x == 0.0f) break;
            if(!rayCuboid(minLen, invDir, tR.target, a, b)) i += int(c.x);
        } else if(moellerTrumboreCull(minLen, tR, a, b, c)) {
            return true;
        }
    }
    // Tested all triangles, but there is no intersection
    return false;
}

float trowbridgeReitz(float alpha, float NdotH) {
    float numerator = alpha * alpha;
    float denom = NdotH * NdotH * (alpha * alpha - 1.0f) + 1.0f;
    return numerator / max(PI * denom * denom, BIAS);
}

float schlickBeckmann(float alpha, float NdotX) {
    float k = alpha * 0.5f;
    float denominator = NdotX * (1.0f - k) + k;
    denominator = max(denominator, BIAS);
    return NdotX / denominator;
}

float smith(float alpha, float NdotV, float NdotL) {
    return schlickBeckmann(alpha, NdotV) * schlickBeckmann(alpha, NdotL);
}

vec3 fresnel(vec3 F0, float theta) {
    // Use Schlick approximation
    return F0 + (1.0f - F0) * pow(1.0f - theta, 5.0f);
}

vec3 forwardTrace(vec3 lightDir, vec3 N, vec3 V, Material material, float strength) {
    float lenP1 = 1.0f + length(lightDir);
    // Apply inverse square law
    float brightness = strength / (lenP1 * lenP1);

    float alpha = material.rme.x * material.rme.x;
    vec3 F0 = material.albedo * material.rme.y;
    vec3 L = normalize(lightDir);
    vec3 H = normalize(V + L);

    float VdotH = max(dot(V, H), 0.0f);
    float NdotL = max(dot(N, L), 0.0f);
    float NdotH = max(dot(N, H), 0.0f);
    float NdotV = max(dot(N, V), 0.0f);

    vec3 fresnelFactor = fresnel(F0, VdotH);
    vec3 Ks = fresnelFactor;
    vec3 Kd = (1.0f - Ks) * (1.0f - material.rme.y);
    vec3 lambert = material.albedo * INV_PI;

    vec3 cookTorranceNumerator = trowbridgeReitz(alpha, NdotH) * smith(alpha, NdotV, NdotL) * fresnelFactor;
    float cookTorranceDenominator = 4.0f * NdotV * NdotL;
    cookTorranceDenominator = max(cookTorranceDenominator, BIAS);

    vec3 cookTorrance = cookTorranceNumerator / cookTorranceDenominator;
    vec3 BRDF = Kd * lambert + cookTorrance;

    // Outgoing light to camera
    return BRDF * NdotL * brightness;
}

vec3 referenceSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 target, vec3 V, Material material, bool dontFilter, int i) {
    vec3 localColor = vec3(0);
    int lights = textureSize(lightTex, 0).y;

    for (int j = 0; j < lights; j++) {
        // Read light position
        vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz;
        // Read light strength from texture
        vec2 strengthVariation = texelFetch(lightTex, ivec2(1, j), 0).xy;
        // Skip if strength is negative or zero
        // if (strengthVariation.x <= 0.0) continue;
        // Alter light source position according to variation.
        light = randomVec.xyz * strengthVariation.y + light;
        vec3 lightDir = light - target;
        vec3 lightColor = forwardTrace(lightDir, N, V, material, strengthVariation.x);
        // Compute quick exit criterion to potentially skip expensive shadow test
        bool quickExitCriterion = dot(lightDir, N) <= BIAS;
        Ray lightRay = Ray(light, target, lightDir, normalize(lightDir));
        // Test if in shadow
        if (quickExitCriterion || shadowTest(lightRay)) {
            if (dontFilter || i == 0) renderId.w = float(((j % 128) << 1) + 1) * INV_255;
        } else {
            if (dontFilter || i == 0) renderId.w = float((j % 128) << 1) * INV_255;
            // localColor *= (totalWeight / reservoirLength) / reservoirWeight;
            localColor += lightColor;
        }
    }

    return localColor + material.rme.z + ambient;
}

vec3 randomSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 target, vec3 V, Material material, bool dontFilter, int i) {
    int lights = textureSize(lightTex, 0).y;

    int randIndex = int(floor(abs(randomVec.y) * float(lights)));

    
    // Read light position
    vec3 light = texelFetch(lightTex, ivec2(0, randIndex), 0).xyz;
    // Read light strength from texture
    vec2 strengthVariation = texelFetch(lightTex, ivec2(1, randIndex), 0).xy;
    // Skip if strength is negative or zero
    // if (strengthVariation.x <= 0.0) continue;
    // Alter light source position according to variation.
    light = randomVec.xyz * strengthVariation.y + light;
    vec3 lightDir = light - target;
    vec3 lightColor = forwardTrace(lightDir, N, V, material, strengthVariation.x);
    // Compute quick exit criterion to potentially skip expensive shadow test
    bool quickExitCriterion = dot(lightDir, N) <= BIAS;
    Ray lightRay = Ray(light, target, lightDir, normalize(lightDir));
    // Test if in shadow
    if (quickExitCriterion || shadowTest(lightRay)) {
        if (dontFilter || i == 0) renderId.w = float(((randIndex % 128) << 1) + 1) * INV_255;
        return material.rme.z + ambient;
    } else {
        if (dontFilter || i == 0) renderId.w = float((randIndex % 128) << 1) * INV_255;
        return lightColor * float(lights) + material.rme.z + ambient;
    }
}

vec3 reservoirSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 target, vec3 V, Material material, bool dontFilter, int i) {
    vec3 localColor = vec3(0);
    float reservoirLength = 0.0f;
    float totalWeight = 0.0f;
    int reservoirNum = 0;
    float reservoirWeight = 0.0f;
    vec3 reservoirLight;
    vec3 reservoirLightDir;
    vec2 lastRandom = noise(randomVec.zw, BIAS).xy;

    for (int j = 0; j < textureSize(lightTex, 0).y; j++) {
      // Read light position
      vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz;
      // Read light strength from texture
      vec2 strengthVariation = texelFetch(lightTex, ivec2(1, j), 0).xy;
      // Skip if strength is negative or zero
      if (strengthVariation.x <= 0.0) continue;
      reservoirLength ++;
      // Alter light source position according to variation.
      light = randomVec.xyz * strengthVariation.y + light;
      vec3 dir = light - target;
      vec3 colorForLight = forwardTrace(dir, N, V, material, strengthVariation.x);
      localColor += colorForLight;
      float weight = length(colorForLight);
      totalWeight += weight;
      if (abs(lastRandom.y) * totalWeight <= weight) {
        reservoirNum = j;
        reservoirWeight = weight;
        reservoirLight = light;
        reservoirLightDir = dir;
      }
      // Update pseudo random variable.
      lastRandom = noise(lastRandom, BIAS).zw;
    }

    // Compute quick exit criterion to potentially skip expensive shadow test
    bool quickExitCriterion = reservoirLength == 0.0 || reservoirWeight == 0.0 || dot(reservoirLightDir, N) <= BIAS;
    Ray lightRay = Ray(reservoirLight, target, reservoirLightDir, normalize(reservoirLightDir));
    // Apply emissive texture and ambient light
    vec3 baseLuminance = material.rme.z + ambient;
    // Test if in shadow
    if (quickExitCriterion || shadowTest(lightRay)) {
        if (dontFilter || i == 0) renderId.w = float(((reservoirNum % 128) << 1) + 1) * INV_255;
        return baseLuminance;
    } else {
        if (dontFilter || i == 0) renderId.w = float((reservoirNum % 128) << 1) * INV_255;
        // localColor *= (totalWeight / reservoirLength) / reservoirWeight;
        return localColor + baseLuminance;
    }
}


vec3 lightTrace(Ray firstRay, Material m, vec3 smoothNormal, int sampleN, int bounces) {
    // Set bool to false when filter becomes necessary
    bool dontFilter = true;
    float lastFilterRoughness = 0.0f;
    float lastId = 0.0f;
    // Use additive color mixing technique, so start with black
    vec3 finalColor = vec3(0);
    vec3 importancyFactor = vec3(1);
    // Ray currently traced
    Ray ray = firstRay;
    // Bundles all attributes of the current surface
    Material material = m;
    // Use cosine as noise in random coordinate picker
    float cosSampleN = cos(float(sampleN));
    // Iterate over each bounce and modify color accordingly
    for(int i = 0; i < bounces && length(importancyFactor * originalColor) >= minImportancy * SQRT3; i++) {
        float fi = float(i);
        // Multiply albedo with either absorption value or filter color
        if(dontFilter) {
            if (sampleN == 0) originalColor *= material.albedo;
        } else {
            importancyFactor *= material.albedo;
        }

        // Generate pseudo random vector
        vec4 randomVec = noise(clipSpace.xy / clipSpace.z, fi + cosSampleN);
        vec3 randomSpheareVec = (smoothNormal + randomVec.xyz) * 0.5;

        // Obtain normalized viewing direction
        vec3 V = normalize(ray.origin - ray.target);

        float BRDF = mix(1.0f, abs(dot(smoothNormal, V)), material.rme.y);

        // Alter normal according to roughness value
        float roughnessBRDF = material.rme.x * BRDF;
        vec3 roughNormal = normalize(mix(smoothNormal, randomSpheareVec, roughnessBRDF));

        vec3 H = normalize(V + roughNormal);
        float VdotH = max(dot(V, H), 0.0f);
        /*
        float ior = mix(1.0f / material.tpo.z, material.tpo.z, max(signDir, 0.0f));

        vec3 F0 = vec3((1.0 - ior) / (1.0 + ior));
        vec3 f = fresnel(F0, VdotH);
        */
        vec3 F0 = material.albedo * BRDF;
        vec3 f = fresnel(F0, VdotH);

        float fresnelReflect = max(f.x, max(f.y, f.z));
        // object is solid or translucent by chance because of the fresnel effect
        bool isSolid = material.tpo.x * fresnelReflect <= abs(randomVec.w);

        // Test if filter is already necessary
        if(dontFilter && i != 0) {
            // Add filtering intensity for respective surface
            originalRMEx += lastFilterRoughness;
            // Update render id
            renderId += pow(2.0f, -fi) * vec4(combineNormalRME(smoothNormal, material.rme), 0.0f);
            originalTPOx++;
        }
        // Update dontFilter variable
        dontFilter = dontFilter && ((material.rme.x < 0.01f && isSolid) || !isSolid);
        float signDir = sign(dot(ray.unitDirection, smoothNormal));
        // If ray reflects from inside or onto an transparent object,
        // the surface faces in the opposite direction as usual
        smoothNormal *= - signDir;
        // Handle translucency and skip rest of light calculation
        if(isSolid) {
            if(dontFilter && material.tpo.x > 0.5f) {
                glassFilter += 1.0f;
                dontFilter = false;
            }
            // Calculate reflecting ray
            ray.unitDirection = normalize(mix(
                reflect(ray.unitDirection, smoothNormal), 
                randomSpheareVec, 
                roughnessBRDF
            ));
            // Determine local color considering PBR attributes and lighting
            vec3 localColor;
            localColor = reservoirSample(lightTex, randomVec, roughNormal, ray.target, V, material, dontFilter, i);
            /*
            if (abs(clipSpace.x / clipSpace.z) < 0.001) localColor = vec3(65536.0);
            else if (clipSpace.x / clipSpace.z < 0.0) {
                localColor = reservoirSample(lightTex, randomVec, roughNormal, ray.target, V, material, dontFilter, i);
            } else {
                localColor = Sample(lightTex, randomVec, roughNormal, ray.target, V, material, dontFilter, i);
            }
            */
            // Calculate primary light sources for this pass if ray hits non translucent object
            finalColor += localColor * importancyFactor;
        } else {
            // Refract ray depending on IOR (material.tpo.z)
            ray.unitDirection = normalize(mix(
                refract(ray.unitDirection, smoothNormal, mix(1.0f / material.tpo.z, material.tpo.z, max(signDir, 0.0f))),
                randomSpheareVec,
                roughnessBRDF
            ));
        }
        // Calculate next intersection
        mat3 intersection = rayTracer(ray);
        // Stop loop if there is no intersection and ray goes in the void
        if(intersection[0] == vec3(0)) break;
        // Update last used tpo.x value
        if(dontFilter) originalTPOx = material.tpo.x;
        // Get position of current triangle/vertex in sceneTex
        int lineNum = int(intersection[2].y);
        int triangleColumn = lineNum >> TRIANGLES_PER_ROW_POWER;
        ivec2 index = ivec2((lineNum - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);
        // Fetch texture data
        vec4 t0 = texelFetch(sceneTex, index, 0);
        vec4 t1 = texelFetch(sceneTex, index + ivec2(1, 0), 0);
        vec4 t2 = texelFetch(sceneTex, index + ivec2(2, 0), 0);
        vec4 t3 = texelFetch(sceneTex, index + ivec2(3, 0), 0);
        vec4 t4 = texelFetch(sceneTex, index + ivec2(4, 0), 0);
        vec4 t5 = texelFetch(sceneTex, index + ivec2(5, 0), 0);
        vec4 t6 = texelFetch(sceneTex, index + ivec2(6, 0), 0);
        // Calculate barycentric coordinates to map textures
        // Assemble 3 vertex normals
        mat3 normals = mat3 (t0, t1, t2.x);
        // Transform normal according to object transform
        int ti = int(intersection[2].z) << 1;
        smoothNormal = normalize(rotation[ti] * (normals * intersection[1]));
        // Create 3 2-component vectors for the UV's of the respective vertex
        mat3x2 vertexUVs = mat3x2(t2.yzw, t3.xyz);
        // Interpolate final barycentric texture coordinates
        vec2 barycentric = vertexUVs * intersection[1].xyz;
        // Read texture id's used as material
        vec3 texNums = vec3(t3.w, t4.xy);
        // Gather material attributes (albedo, roughness, metallicity, emissiveness, translucency, partical density and optical density aka. IOR) out of world texture
        material = Material(
            mix(
                vec3(t4.zw, t5.x), 
                lookup(tex, vec3(barycentric, texNums.x)).xyz, 
                max(sign(texNums.x + 0.5f), 0.0f)
            ),
            mix(
                t5.yzw, 
                lookup(pbrTex, vec3(barycentric, texNums.y)).xyz, 
                max(sign(texNums.y + 0.5f), 0.0f)
            ),
            mix(
                t6.xyz, 
                lookup(translucencyTex, vec3(barycentric, texNums.z)).xyz, 
                max(sign(texNums.z + 0.5f), 0.0f)
            )
        );
        // Update other parameters
        ray.origin = ray.target;
        lastId = intersection[2].y;
        ray.target = intersection[0];
        // Preserve original roughness for filter pass
        lastFilterRoughness = material.rme.x;
        if (i == 0) firstRayLength = min(length(ray.target - ray.origin) / length(firstRay.target - firstRay.origin), firstRayLength);
    }
    // Return final pixel color
    return finalColor;
}

void main() {
    // Calculate constant for this pass
    invTextureWidth = 1.0f / float(textureWidth);

    // Calculate vertex position in texture
    int triangleColumn = fragmentTriangleId >> 8;
    ivec2 index = ivec2((fragmentTriangleId - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);

    // Fetch texture data
    vec4 t0 = texelFetch(sceneTex, index, 0);
    vec4 t1 = texelFetch(sceneTex, index + ivec2(1, 0), 0);
    vec4 t2 = texelFetch(sceneTex, index + ivec2(2, 0), 0);
    vec4 t3 = texelFetch(sceneTex, index + ivec2(3, 0), 0);
    vec4 t4 = texelFetch(sceneTex, index + ivec2(4, 0), 0);
    vec4 t5 = texelFetch(sceneTex, index + ivec2(5, 0), 0);
    vec4 t6 = texelFetch(sceneTex, index + ivec2(6, 0), 0);
    // Calculate barycentric coordinates to map textures
    // Assemble 3 vertex normals
    mat3 normals = mat3 (
        t0.xyz, 
        vec3(t0.w, t1.xy),
        vec3(t1.zw, t2.x)
    );
    // Transform normal according to object transform
    int tI = transformationId << 1;
    vec3 absolutePosition = rotation[tI] * position + shift[tI];
    // Transform normal with local transform
    vec3 smoothNormal = normalize(rotation[tI] * (normals * vec3(uv, 1.0f - uv.x - uv.y)));
    // Create 3 2-component vectors for the UV's of the respective vertex
    mat3x2 vertexUVs = mat3x2(t2.yzw, t3.xyz);
    // Interpolate final barycentric texture coordinates
    vec2 barycentric = vertexUVs * vec3(uv, 1.0f - uv.x - uv.y);
    // Read texture id's used as material
    vec3 texNums = vec3(t3.w, t4.xy);
    // Gather material attributes (albedo, roughness, metallicity, emissiveness, translucency, partical density and optical density aka. IOR) out of world texture
    Material material = Material(
        mix(
            vec3(t4.zw, t5.x), 
            lookup(tex, vec3(barycentric, texNums.x)).xyz, 
            max(sign(texNums.x + 0.5f), 0.0f)
        ),
        mix(
            t5.yzw, 
            lookup(pbrTex, vec3(barycentric, texNums.y)).xyz, 
            max(sign(texNums.y + 0.5f), 0.0f)
        ),
        mix(
            t6.xyz, 
            lookup(translucencyTex, vec3(barycentric, texNums.z)).xyz, 
            max(sign(texNums.z + 0.5f), 0.0f)
        )
    );

    originalTPOx = material.tpo.x;
    // Preserve original roughness for filter pass
    float filterRoughness = material.rme.x;
    // Generate camera ray
    vec3 dir = absolutePosition - camera;
    vec3 normDir = normalize(dir);
    Ray ray = Ray(camera, absolutePosition, dir, normDir);
    // vec3 finalColor = material.rme;
    vec3 finalColor = vec3(0);
    // Generate multiple samples
    for(int i = 0; i < samples; i++) finalColor += lightTrace(ray, material, smoothNormal, i, maxReflections);
    // Average ray colors over samples.
    float invSamples = 1.0f / float(samples);
    finalColor *= invSamples;
    originalRMEx *= invSamples;
    if(useFilter == 1) {
        // Render all relevant information to 4 textures for the post processing shader
        renderColor = vec4(fract(finalColor), 1.0f);
        // 16 bit HDR for improved filtering
        renderColorIp = vec4(floor(finalColor) * INV_256, glassFilter);
    } else {
        finalColor *= originalColor;
        if(isTemporal == 1) {
            renderColor = vec4(fract(finalColor), 1.0f);
            // 16 bit HDR for improved filtering
            renderColorIp = vec4(floor(finalColor) * INV_256, 1.0f);
        } else {
            renderColor = vec4(finalColor, 1.0f);
        }
    }

    material.rme.x = filterRoughness;

    renderOriginalColor = vec4(originalColor, min(material.rme.x + originalRMEx, firstRayLength) + INV_255);
    // render normal (last in transparency)
    renderId += vec4(combineNormalRME(smoothNormal, material.rme), INV_255);
    // render material (last in transparency)
    renderOriginalId = vec4(combineNormalRME(smoothNormal, material.rme), originalTPOx + INV_255);
    // render modulus of absolute position (last in transparency)
    float div = 2.0f * length(absolutePosition - camera);
    renderLocationId = vec4(mod(absolutePosition, div) / div, material.rme.z + INV_255);
}