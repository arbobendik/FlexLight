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

struct Intersection {
    vec3 uvw;
    vec3 point;
    float dist;
};

struct Hit {
    mat3 triangle;
    vec3 uvw;
    vec3 point;
    int triangleId;
    int transformationId;
};

struct ShadowTerminator {
    mat3 triangle;
    mat3 normals;
    vec3 uvw;
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

const Intersection NO_INTERSECT = Intersection(vec3(0.0), vec3(0.0), 0.0);
const Hit NO_HIT = Hit(mat3(0.0), vec3(0.0), vec3(0.0), - 1, 0);

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

Intersection moellerTrumbore(mat3 t, NormalizedRay ray, float l) {
    vec3 edge1 = t[1] - t[0];
    vec3 edge2 = t[2] - t[0];
    vec3 pvec = cross(ray.unitDirection, edge2);
    float det = dot(edge1, pvec);
    if(abs(det) < BIAS) return NO_INTERSECT;
    float inv_det = 1.0f / det;
    vec3 tvec = ray.target - t[0];
    float u = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) return NO_INTERSECT;
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unitDirection, qvec) * inv_det;
    float uvSum = u + v;
    if(v < BIAS || uvSum > 1.0f) return NO_INTERSECT;
    float s = dot(edge2, qvec) * inv_det;
    if(s > l || s <= BIAS) return NO_INTERSECT;
    // Calculate intersection point
    vec3 d = (s * ray.unitDirection) + ray.target;
    return Intersection(vec3(1.0f - uvSum, u, v), d, s);
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
Hit rayTracer(NormalizedRay ray, int triangleId) {
    // Cache transformed ray attributes
    NormalizedRay tR = NormalizedRay(ray.target, ray.unitDirection);
    // Inverse of transformed normalized ray
    vec3 invDir = 1.0 / ray.unitDirection;
    int cachedTI = 0;
    // Latest intersection which is now closest to origin
    Hit hit = NO_HIT;
    // Length to latest intersection
    float minLen = POW32;
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * TRIANGLES_PER_ROW;
    // Iterate through lines of texture
    for(int i = 0; i < size; i++) {
        if (triangleId == i) continue;
        // Get position of current triangle/vertex in geometryTex
        int triangleColumn = i >> TRIANGLES_PER_ROW_POWER;
        ivec2 index = ivec2((i - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);
        // Fetch triangle coordinates from scene graph
        vec4 t0 = texelFetch(geometryTex, index, 0);
        vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);
        vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);

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
        // t2.z = 0        => end of list: stop loop
        // t2.z = 1        => is bounding volume: do AABB intersection test
        // t2.z = 2        => is triangle: do triangle intersection test
        if (t2.z == 0.0) break;

        if (t2.z == 1.0) {
            if (!rayCuboid(minLen, invDir, tR.target, t0.xyz, vec3(t0.w, t1.xy))) i += int(t1.z);
        } else {
            mat3 triangle = mat3 (t0, t1, t2.x);
            // Test if triangle intersects ray
            Intersection intersection = moellerTrumbore(triangle, tR, minLen);
            // Test if ray even intersects
            if(intersection.dist != 0.0) {
                hit.uvw = intersection.uvw;
                // Translate intersection point back to absolute space
                hit.point = intersection.point;
                hit.triangle = triangle;
                hit.transformationId = int(t2.y);
                hit.triangleId = i;
                // Update maximum object distance for future rays
                minLen = intersection.dist;
            }
        }
    }
    
    int tI = hit.transformationId << 1;
    hit.point = rotation[tI] * hit.point + shift[tI];
    hit.triangle = rotation[tI] * hit.triangle + mat3(shift[tI], shift[tI], shift[tI]);
    // Return ray hit with all required information
    return hit;
}


// Simplified rayTracer to only test if ray intersects anything
bool shadowTest(Ray ray, int triangleId) {
    // Cache transformed ray attributes
    NormalizedRay tR = NormalizedRay(ray.origin, ray.unitDirection);
    // Inverse of transformed normalized ray
    vec3 invDir = 1.0 / ray.unitDirection;
    int cachedTI = 0;
    // Precompute max length
    float minLen = length(ray.direction);
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * TRIANGLES_PER_ROW;
    // Iterate through lines of texture
    for(int i = 0; i < size; i++) {
        if (triangleId == i) continue;
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
                rotation[iI] * (ray.origin + shift[iI]),
                normalize(rotation[iI] * ray.unitDirection)
            );
            invDir = 1.0 / tR.unitDirection;
        }
        // Three cases:
        // t2.z = 0        => end of list: stop loop
        // t2.z = 1        => is bounding volume: do AABB intersection test
        // t2.z = 2        => is triangle: do triangle intersection test
        if (t2.z == 0.0) break;
        else if (t2.z == 1.0 && !rayCuboid(minLen, invDir, tR.target, a, b)) i += int(c.x);
        else if(t2.z == 2.0 && moellerTrumboreCull(minLen, tR, a, b, c)) return true;
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

/*
float fresnelFloat (float F0, float theta) {
    // Use Schlick approximation
    return F0 + (1.0f - F0) * pow(1.0f - theta, 5.0f);
}

vec3 altForward (Material material, vec3 lightDir, float strength, vec3 N, vec3 V) {
    float lenP1 = 1.0f + length(lightDir);
    // Apply inverse square law
    float brightness = strength / (lenP1 * lenP1);
    //float F0 = material.rme.y;
    vec3 L = normalize(lightDir);
    float NdotL = max(0.0, dot(N, L));
	vec3 Rs = vec3(0.0);
	if (NdotL > 0.9) 
	{
		vec3 H = normalize(L + V);
		float NdotH = max(0.0, dot(N, H));
		float NdotV = max(0.0, dot(N, V));
		float VdotH = max(0.0, dot(L, H));

		// Fresnel reflectance
        float BRDF = mix(1.0f, NdotV, material.rme.y);
        vec3 F0 = material.albedo * BRDF;
		vec3 F = fresnel(F0, VdotH);

		// Microfacet distribution by Beckmann
		float m_squared = material.rme.x * material.rme.x;
		float r1 = 1.0 / (4.0 * m_squared * pow(NdotH, 4.0));
		float r2 = (NdotH * NdotH - 1.0) / (m_squared * NdotH * NdotH);
		float D = r1 * exp(r2);

		// Geometric shadowing
		float two_NdotH = 2.0 * NdotH;
		float g1 = (two_NdotH * NdotV) / VdotH;
		float g2 = (two_NdotH * NdotL) / VdotH;
		float G = min(1.0, min(g1, g2));

		Rs = (F * D * G) / (PI * NdotL * NdotV);
	}
	return material.albedo * brightness * (NdotL + max(Rs, 0.0));
}
*/

vec3 forwardTrace(Material material, vec3 lightDir, float strength, vec3 N, vec3 V) {
    float lenP1 = 1.0f + length(lightDir);
    // Apply inverse square law
    float brightness = strength / (lenP1 * lenP1);

    vec3 L = normalize(lightDir);
    vec3 H = normalize(V + L);

    float VdotH = max(dot(V, H), 0.0f);
    float NdotL = max(dot(N, L), 0.0f);
    float NdotH = max(dot(N, H), 0.0f);
    float NdotV = max(dot(N, V), 0.0f);

    float alpha = material.rme.x * material.rme.x;
    float BRDF = mix(1.0f, NdotV, material.rme.y);
    vec3 F0 = material.albedo * BRDF;

    vec3 Ks = fresnel(F0, VdotH);
    vec3 Kd = (1.0f - Ks) * (1.0f - material.rme.y);
    vec3 lambert = material.albedo * INV_PI;

    vec3 cookTorranceNumerator = Ks * trowbridgeReitz(alpha, NdotH) * smith(alpha, NdotV, NdotL);
    float cookTorranceDenominator = 4.0f * NdotV * NdotL;
    cookTorranceDenominator = max(cookTorranceDenominator, BIAS);

    vec3 cookTorrance = cookTorranceNumerator / cookTorranceDenominator;
    vec3 radiance = Kd * lambert + cookTorrance;

    // Outgoing light to camera
    return radiance * NdotL * brightness;
}

/*
vec3 referenceSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 target, vec3 V, Material material, bool dontFilter, int triangleId, int i) {
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
        if (quickExitCriterion || shadowTest(lightRay, triangleId)) {
            if (dontFilter || i == 0) renderId.w = float(((j % 128) << 1) + 1) * INV_255;
        } else {
            if (dontFilter || i == 0) renderId.w = float((j % 128) << 1) * INV_255;
            // localColor *= (totalWeight / reservoirLength) / reservoirWeight;
            localColor += lightColor;
        }
    }

    return localColor + material.rme.z + ambient * material.rme.y;
}

vec3 randomSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 target, vec3 V, Material material, bool dontFilter, int triangleId, int i) {
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
    if (quickExitCriterion || shadowTest(lightRay, triangleId)) {
        if (dontFilter || i == 0) renderId.w = float(((randIndex % 128) << 1) + 1) * INV_255;
        return material.rme.z + ambient * material.rme.y;
    } else {
        if (dontFilter || i == 0) renderId.w = float((randIndex % 128) << 1) * INV_255;
        return lightColor * float(lights) + material.rme.z + ambient * material.rme.y;
    }
}
*/
vec3 reservoirSample (ShadowTerminator shadow, vec4 randomVec, vec3 N, vec3 smoothNormal, vec3 target, vec3 V, Material material, bool dontFilter, int triangleId, int i) {
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
    
      vec3 colorForLight = forwardTrace(material, dir, strengthVariation.x, N, V);
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

    vec3 unitLightDir = normalize(reservoirLightDir);
    // Compute quick exit criterion to potentially skip expensive shadow test
    bool showColor = reservoirLength == 0.0 || reservoirWeight == 0.0;
    bool showShadow = dot(smoothNormal, unitLightDir) <= BIAS;
    // Apply emissive texture and ambient light
    vec3 baseLuminance = vec3(material.rme.z);
    // Test if in shadow
    if (showColor) {
        if (dontFilter || i == 0) renderId.w = float((reservoirNum % 128) << 1) * INV_255;
        return localColor + baseLuminance;
    }

    if (showShadow) {
        if (dontFilter || i == 0) renderId.w = float(((reservoirNum % 128) << 1) + 1) * INV_255;
        return baseLuminance;
    }
    
    // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
    vec3 geometryNormal = normalize(cross(shadow.triangle[1] - shadow.triangle[0], shadow.triangle[2] - shadow.triangle[0]));
    // geometryNormal = faceforward(geometryNormal, smoothNormal, geometryNormal);
    geometryNormal *= sign(dot(smoothNormal, geometryNormal));


    vec3 normalDots = geometryNormal * shadow.normals;

    vec3 diffs = max(vec3(
        distance(target, shadow.triangle[0]) * sin(acos(dot(shadow.normals[0], geometryNormal))),
        distance(target, shadow.triangle[1]) * sin(acos(dot(shadow.normals[1], geometryNormal))),
        distance(target, shadow.triangle[2]) * sin(acos(dot(shadow.normals[2], geometryNormal)))
    ), 0.0);
    // diffs = max(diffs, 0.0);
    float geometryOffset = dot(diffs, vec3(uv, 1.0f - uv.x - uv.y));
    vec3 offsetTarget = target + geometryOffset * smoothNormal;
    
    Ray lightRay = Ray(offsetTarget, reservoirLight, reservoirLightDir, unitLightDir);

    if (shadowTest(lightRay, triangleId)) {
        if (dontFilter || i == 0) renderId.w = float(((reservoirNum % 128) << 1) + 1) * INV_255;
        return baseLuminance;
    } else {
        if (dontFilter || i == 0) renderId.w = float((reservoirNum % 128) << 1) * INV_255;
        return localColor + baseLuminance;
    }
}


vec3 lightTrace(Ray firstRay, Material m, ShadowTerminator shadow, vec3 smoothNormal, int triangleId, int sampleN, int bounces) {
    // Set bool to false when filter becomes necessary
    bool dontFilter = true;
    float lastFilterRoughness = 0.0f;
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

        // If ray reflects from inside or onto an transparent object,
        // the surface faces in the opposite direction as usual
        float signDir = sign(dot(ray.unitDirection, smoothNormal));
        // vec3 faceSmoothNormal = smoothNormal;
        smoothNormal *= - signDir;

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
        // vec3(pow(signDir * (1.0 - material.tpo.z) / (1.0 + material.tpo.z), 2.0)) * 
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
        } else {
            // Refract ray depending on IOR (material.tpo.z)
            ray.unitDirection = normalize(mix(
                refract(ray.unitDirection, smoothNormal, mix(1.0f / material.tpo.z, material.tpo.z, max(signDir, 0.0f))),
                - randomSpheareVec,
                roughnessBRDF
            ));
        }
        // Determine local color considering PBR attributes and lighting
        vec3 localColor = reservoirSample(shadow, randomVec, - signDir * roughNormal, - signDir * smoothNormal, ray.target, V, material, dontFilter, triangleId, i);
        // Calculate primary light sources for this pass if ray hits non translucent object
        finalColor += localColor * importancyFactor;
        // Calculate next intersection
        Hit hit = rayTracer(NormalizedRay(ray.target, ray.unitDirection), triangleId);
        // Stop loop if there is no intersection and ray goes in the void
        if (hit.triangleId == - 1) break;
        // Update last used tpo.x value
        if (dontFilter) originalTPOx = material.tpo.x;
        // Get position of current triangle/vertex in sceneTex
        triangleId = hit.triangleId;
        int triangleColumn = triangleId >> TRIANGLES_PER_ROW_POWER;
        ivec2 indexScene = ivec2((triangleId - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);
        // Fetch texture data
        vec4 t0 = texelFetch(sceneTex, indexScene, 0);
        vec4 t1 = texelFetch(sceneTex, indexScene + ivec2(1, 0), 0);
        vec4 t2 = texelFetch(sceneTex, indexScene + ivec2(2, 0), 0);
        vec4 t3 = texelFetch(sceneTex, indexScene + ivec2(3, 0), 0);
        vec4 t4 = texelFetch(sceneTex, indexScene + ivec2(4, 0), 0);
        vec4 t5 = texelFetch(sceneTex, indexScene + ivec2(5, 0), 0);
        vec4 t6 = texelFetch(sceneTex, indexScene + ivec2(6, 0), 0);
        // Assemble 3 vertex normals
        int tI = hit.transformationId << 1;
        mat3 normals = rotation[tI] * mat3 (t0, t1, t2.x);
        //mat3 rotatedNormals = 
        // Update shadow terminator instance for considering smooth normals in shading through a geometry offset
        shadow.triangle = hit.triangle;
        shadow.normals = normals;
        shadow.uvw = hit.uvw;
        // Transform normal according to object transform
        smoothNormal = normalize(normals * hit.uvw);
        // Create 3 2-component vectors for the UV's of the respective vertex
        mat3x2 vertexUVs = mat3x2(t2.yzw, t3.xyz);
        // Interpolate final barycentric texture coordinates
        vec2 barycentric = vertexUVs * hit.uvw;
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
        ray.target = hit.point;
        // Preserve original roughness for filter pass
        lastFilterRoughness = material.rme.x;
        if (i == 0) firstRayLength = min(length(ray.target - ray.origin) / length(firstRay.target - firstRay.origin), firstRayLength);
    }
    // Return final pixel color
    return finalColor + importancyFactor * ambient;
}

void main() {
    // Calculate constant for this pass
    invTextureWidth = 1.0f / float(textureWidth);
    // Transform normal according to object transform
    int tI = transformationId << 1;

    // Calculate vertex position in texture
    int triangleColumn = fragmentTriangleId >> 8;
    ivec2 indexGeometry = ivec2((fragmentTriangleId - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);
    ivec2 indexScene = ivec2((fragmentTriangleId - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);
    // Fetch texture data
    vec4 g0 = texelFetch(sceneTex, indexScene, 0);
    vec4 g1 = texelFetch(sceneTex, indexScene + ivec2(1, 0), 0);
    vec4 g2 = texelFetch(sceneTex, indexScene + ivec2(2, 0), 0);

    mat3 triangle = rotation[tI] * mat3(g0, g1, g2.x) + mat3(shift[tI], shift[tI], shift[tI]);
    // Scene texture
    vec4 t0 = texelFetch(sceneTex, indexScene, 0);
    vec4 t1 = texelFetch(sceneTex, indexScene + ivec2(1, 0), 0);
    vec4 t2 = texelFetch(sceneTex, indexScene + ivec2(2, 0), 0);
    vec4 t3 = texelFetch(sceneTex, indexScene + ivec2(3, 0), 0);
    vec4 t4 = texelFetch(sceneTex, indexScene + ivec2(4, 0), 0);
    vec4 t5 = texelFetch(sceneTex, indexScene + ivec2(5, 0), 0);
    vec4 t6 = texelFetch(sceneTex, indexScene + ivec2(6, 0), 0);
    // Assemble 3 vertex normals
    mat3 normals = rotation[tI] * mat3(t0, t1, t2.x);
    // Create shadow terminator instance for later shading
    ShadowTerminator shadow = ShadowTerminator(triangle, normals, vec3(uv, 1.0f - uv.x - uv.y));
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
    vec3 dir = position - camera;
    vec3 normDir = normalize(dir);
    Ray ray = Ray(camera, position, dir, normDir);
    // vec3 finalColor = material.rme;
    vec3 finalColor = vec3(0);

    // finalColor = fract(absolutePosition);//fract(smoothNormal);
    // Generate multiple samples
    for(int i = 0; i < samples; i++) finalColor += lightTrace(ray, material, shadow, smoothNormal, fragmentTriangleId, i, maxReflections);
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
    float div = 2.0f * length(position - camera);
    renderLocationId = vec4(mod(position, div) / div, material.rme.z + INV_255);
}