#version 300 es
#define TRIANGLES_PER_ROW_POWER 8
#define TRIANGLES_PER_ROW 256.0
#define INV_TRIANGLES_PER_ROW 0.00390625
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

struct Ray {
    vec3 direction;
    vec3 unitDirection;
    vec3 origin;
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

mat2x4 moellerTrumbore(float l, Ray ray, vec3 a, vec3 b, vec3 c) {
    vec3 edge1 = b - a;
    vec3 edge2 = c - a;
    vec3 pvec = cross(ray.unitDirection, edge2);
    float det = dot(edge1, pvec);
    if(abs(det) < BIAS) return mat2x4(0);
    float inv_det = 1.0f / det;
    vec3 tvec = ray.origin - a;
    float u = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) return mat2x4(0);
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unitDirection, qvec) * inv_det;
    float uvSum = u + v;
    if(v < BIAS || uvSum > 1.0f) return mat2x4(0);
    float s = dot(edge2, qvec) * inv_det;
    if(s > l || s <= BIAS) return mat2x4(0);
    // Calculate intersection point
    vec3 d = (s * ray.unitDirection) + ray.origin;
    return mat2x4(d, s, 1.0f - uvSum, u, v, 0);
}

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
bool moellerTrumboreCull(float l, Ray ray, vec3 a, vec3 b, vec3 c) {
    vec3 edge1 = b - a;
    vec3 edge2 = c - a;
    vec3 pvec = cross(ray.unitDirection, edge2);
    float det = dot(edge1, pvec);
    float invDet = 1.0f / det;
    if(det < BIAS) return false;
    vec3 tvec = ray.origin - a;
    float u = dot(tvec, pvec) * invDet;
    if(u < BIAS || u > 1.0f) return false;
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unitDirection, qvec) * invDet;
    if(v < BIAS || u + v > 1.0f) return false;
    float s = dot(edge2, qvec) * invDet;
    return (s <= l && s > BIAS);
}

// Don't return intersection point, because we're looking for a specific triangle
bool rayCuboid(float l, vec3 invRay, vec3 p, vec3 minCorner, vec3 maxCorner) {
    vec3 v0 = (minCorner - p) * invRay;
    vec3 v1 = (maxCorner - p) * invRay;
    float tmin = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));
    float tmax = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));
    return tmax >= max(tmin, BIAS) && tmin < l;
}

// Test for closest ray triangle intersection
// Return intersection position in world space (rayTracer[0].xyz) and index of target triangle in geometryTex (rayTracer[1].w)
mat2x4 rayTracer(Ray ray) {
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 invRay = 1.0f / ray.unitDirection;
    // Latest intersection which is now closest to origin
    mat2x4 intersection = mat2x4(0, 0, 0, 0, 0, 0, 0, -1);
    // Length to latest intersection
    float minLen = POW32;
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for(int i = 0; i < size; i++) {
        float fi = float(i);
        // Get position of current triangle/vertex in geometryTex
        ivec2 index = ivec2(mod(fi, TRIANGLES_PER_ROW) * 3.0f, fi * INV_TRIANGLES_PER_ROW);
        // Fetch triangle coordinates from scene graph
        vec3 a = texelFetch(geometryTex, index, 0).xyz;
        vec3 b = texelFetch(geometryTex, index + ivec2(1, 0), 0).xyz;
        vec3 c = texelFetch(geometryTex, index + ivec2(2, 0), 0).xyz;
        // Three cases:
        // c is X 0 0        => is bounding volume: do AABB intersection test
        // c is 0 0 0        => end of list: stop loop
        // otherwise         => is triangle: do triangle intersection test
        if(c.yz == vec2(0)) {
            if(c.x == 0.0f) break;
            if(!rayCuboid(minLen, invRay, ray.origin, a, b)) i += int(c.x);
        } else {
            // Test if triangle intersects ray
            mat2x4 currentIntersection = moellerTrumbore(minLen, ray, a, b, c);
            // Test if ray even intersects
            if(currentIntersection[0].w != 0.0f) {
                minLen = currentIntersection[0].w;
                intersection = currentIntersection;
                intersection[1].w = fi;
            }
        }
    }
    // Return if pixel is in shadow or not
    return intersection;
}

// Simplified rayTracer to only test if ray intersects anything
bool shadowTest(Ray ray) {
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 invRay = 1.0 / ray.unitDirection;
    // Precomput max length
    float minLen = length(ray.direction);
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for (int i = 0; i < size; i++) {
        float fi = float(i);
        // Get position of current triangle/vertex in geometryTex
        ivec2 index = ivec2(mod(fi, TRIANGLES_PER_ROW) * 3.0, fi * INV_TRIANGLES_PER_ROW);
        // Fetch triangle coordinates from scene graph
        vec3 a = texelFetch(geometryTex, index, 0).xyz;
        vec3 b = texelFetch(geometryTex, index + ivec2(1, 0), 0).xyz;
        vec3 c = texelFetch(geometryTex, index + ivec2(2, 0), 0).xyz;
        // Three cases:
        // c is X 0 0        => is bounding volume: do AABB intersection test
        // c is 0 0 0        => end of list: stop loop
        // otherwise         => is triangle: do triangle intersection test
        if (c.yz == vec2(0)) {
        if (c.x == 0.0) break;
        if (!rayCuboid(minLen, invRay, ray.origin, a, b)) i += int(c.x);
        } else if (moellerTrumboreCull(minLen, ray, a, b, c)) return true;
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

vec3 fresnel(vec3 F0, float VdotH) {
    // Use Schlick approximation
    return F0 + (1.0f - F0) * pow(1.0f - VdotH, 5.0f);
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


vec3 reservoirSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 smoothNormal, vec3 origin, vec3 V, Material material, bool dontFilter, int i) {


    vec3 localColor = vec3(0);
    float reservoirLength = 0.0;
    float totalWeight = 0.0;
    int reservoirNum = 0;
    float reservoirWeight;
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
      vec3 dir = light - origin;
      vec3 colorForLight = forwardTrace(dir, N, V, material, strengthVariation.x);
      localColor += colorForLight;
      float weight = length(colorForLight);
      totalWeight += weight;
      if (abs(lastRandom.y) * totalWeight <= weight) {
        reservoirNum = j;
        reservoirWeight = weight;
        reservoirLightDir = dir;
      }
      // Update pseudo random variable.
      lastRandom = noise(lastRandom, BIAS).zw;
    }

    // Compute quick exit criterion to potentially skip expensive shadow test
    bool quickExitCriterion = reservoirLength == 0.0 || reservoirWeight == 0.0 || dot(reservoirLightDir, N) <= BIAS;
    Ray lightRay = Ray(reservoirLightDir, normalize(reservoirLightDir), origin);
    // Apply emissive texture and ambient light
    vec3 baseLuminance = material.rme.z + ambient * 0.25f;
    // Test if in shadow
    if (quickExitCriterion || !shadowTest(lightRay)) {
        if (dontFilter || i == 0) renderId.w = float((reservoirNum % 128) * 2) * INV_255;
        return localColor + baseLuminance;
    } else {
        if (dontFilter || i == 0) renderId.w = float((reservoirNum % 128) * 2 + 1) * INV_255;
        return baseLuminance;
    }
}


vec3 lightTrace(vec3 origin, Ray firstRay, Material m, vec3 smoothNormal, vec3 geometryNormal, int sampleN, int bounces) {
    // Set bool to false when filter becomes necessary
    bool dontFilter = true;
    float lastFilterRoughness = 0.0f;
    float lastId = 0.0f;
    // Use additive color mixing technique, so start with black
    vec3 finalColor = vec3(0);
    vec3 importancyFactor = vec3(1);
    vec3 viewPoint = origin;
    // Ray currently traced
    Ray ray = firstRay;
    // Bundles all attributes of the current surface
    Material material = m;
    // Use cosine as noise in random coordinate picker
    float cosSampleN = cos(float(sampleN));
    // Iterate over each bounce and modify color accordingly
    for(int i = 0; i < bounces && length(importancyFactor) >= minImportancy * SQRT3; i++) {
        float fi = float(i);
        // Multiply albedo with either absorption value or filter color
        if(dontFilter) {
            if(sampleN == 0) originalColor *= material.albedo;
        } else {
            importancyFactor *= material.albedo;
        }

        // Generate pseudo random vector
        vec4 randomVec = noise(clipSpace.xy / clipSpace.z, fi + cosSampleN);
        vec3 randomSpheareVec = (smoothNormal + randomVec.xyz) * 0.5;

        // Obtain normalized viewing direction
        vec3 V = normalize(viewPoint - ray.origin);

        float BRDF = mix(1.0f, abs(dot(smoothNormal, V)), material.rme.y);

        // Alter normal according to roughness value
        float roughnessBRDF = material.rme.x * BRDF;
        vec3 roughNormal = normalize(mix(smoothNormal, randomSpheareVec, roughnessBRDF));
        // Invert roughNormal if it points under the surface.
        // roughNormal = sign(dot(roughNormal, geometryNormal)) * roughNormal;


        vec3 H = normalize(V + roughNormal);
        float VdotH = max(dot(V, H), 0.0f);
        vec3 f = fresnel(material.albedo, VdotH) * BRDF;

        float fresnelReflect = max(f.x, max(f.y, f.z));
        // object is solid or translucent by chance because of the fresnel effect
        bool isSolid = material.tpo.x * fresnelReflect <= abs(randomVec.w);

        // Test if filter is already necessary
        if(dontFilter && i != 0) {
            // Add filtering intensity for respective surface
            originalRMEx += lastFilterRoughness;
            // Update render id
            renderId += pow(2.0f, -fi) * vec4(combineNormalRME(geometryNormal, material.rme), 0.0f);
            originalTPOx++;
        }
        // Update dontFilter variable
        dontFilter = dontFilter && ((material.rme.x < 0.01f && isSolid) || !isSolid);

        // Intersection of ray with triangle
        mat2x4 intersection;
        // Handle translucency and skip rest of light calculation
        if(isSolid) {
            if(dontFilter && material.tpo.x > 0.5f) {
                glassFilter += 1.0f;
                dontFilter = false;
            }
            // If ray reflects from inside an transparent object,
            // the surface faces in the opposite direction as usual
            smoothNormal *= -sign(dot(ray.unitDirection, smoothNormal));
            
            // Calculate reflecting ray
            ray.unitDirection = normalize(mix(reflect(ray.unitDirection, smoothNormal), randomSpheareVec, roughnessBRDF));
            if(dot(ray.unitDirection, geometryNormal) <= BIAS) ray.unitDirection = normalize(ray.unitDirection + geometryNormal);
            // Determine local color considering PBR attributes and lighting
            vec3 localColor = reservoirSample(lightTex, randomVec, roughNormal, smoothNormal, ray.origin, V, material, dontFilter, i);
            // Calculate primary light sources for this pass if ray hits non translucent object
            finalColor += localColor * importancyFactor;
        } else {
            float signDir = sign(dot(ray.unitDirection, roughNormal));
            // Refract ray depending on IOR (material.tpo.z)
            ray.unitDirection = normalize(ray.unitDirection + refract(ray.unitDirection, - signDir * roughNormal, mix(1.0f / material.tpo.z, material.tpo.z, max(signDir, 0.0f))));
        }
        // Calculate next intersection
        intersection = rayTracer(ray);
        // Stop loop if there is no intersection and ray goes in the void
        if(intersection[0] == vec4(0)) break;
        // Update last used tpo.x value
        if(dontFilter) originalTPOx = material.tpo.x;
        // Get position of current triangle/vertex in sceneTex
        ivec2 index = ivec2(mod(intersection[1].w, TRIANGLES_PER_ROW) * 9.0f, intersection[1].w * INV_TRIANGLES_PER_ROW);
        // Calculate barycentric coordinates to map textures
        // Fetch normal
        mat3 normals = mat3 (
            texelFetch(sceneTex, index + ivec2(0, 0), 0).xyz,
            texelFetch(sceneTex, index + ivec2(1, 0), 0).xyz,
            texelFetch(sceneTex, index + ivec2(2, 0), 0).xyz
        );

        smoothNormal = normals * intersection[1].xyz; 
        geometryNormal = smoothNormal;
        // Read UVs of vertices
        vec3 vUVs1 = texelFetch(sceneTex, index + ivec2(3, 0), 0).xyz;
        vec3 vUVs2 = texelFetch(sceneTex, index + ivec2(4, 0), 0).xyz;
        mat3x2 vertexUVs = mat3x2(vUVs1, vUVs2);
        // Interpolate final barycentric coordinates
        vec2 barycentric = vertexUVs * intersection[1].xyz;
        // Read triangle normal
        vec3 texNums = texelFetch(sceneTex, index + ivec2(5, 0), 0).xyz;
        // Gather material attributes (albedo, roughness, metallicity, emissiveness, translucency, partical density and optical density aka. IOR) out of world texture
        material = Material(
            mix(
                texelFetch(sceneTex, index + ivec2(6, 0), 0).xyz, 
                lookup(tex, vec3(barycentric, texNums.x)).xyz, 
                max(sign(texNums.x + 0.5f), 0.0f)
            ),
            mix(
                texelFetch(sceneTex, index + ivec2(7, 0), 0).xyz, 
                lookup(pbrTex, vec3(barycentric, texNums.y)).xyz, 
                max(sign(texNums.y + 0.5f), 0.0f)
            ),
            mix(
                texelFetch(sceneTex, index + ivec2(8, 0), 0).xyz, 
                lookup(translucencyTex, vec3(barycentric, texNums.z)).xyz, 
                max(sign(texNums.z + 0.5f), 0.0f)
            )
        );
        // Update other parameters
        viewPoint = ray.origin;
        lastId = intersection[1].w;
        ray.origin = intersection[0].xyz;
        // Preserve original roughness for filter pass
        lastFilterRoughness = material.rme.x;
        if(i == 0) firstRayLength = min(length(ray.origin - viewPoint) / length(firstRay.origin - origin), firstRayLength);
    }
    // Return final pixel color
    return finalColor;
}

void main() {
    // Calculate constant for this pass
    invTextureWidth = 1.0f / float(textureWidth);

    // Calculate vertex position in texture
    int triangleColumn = fragmentTriangleId >> 8;
    ivec2 index = ivec2((fragmentTriangleId - triangleColumn * 256) * 9, triangleColumn);

    // Read base attributes from world texture.
    mat3 normals = mat3 (
        texelFetch(sceneTex, index + ivec2(0, 0), 0).xyz,
        texelFetch(sceneTex, index + ivec2(1, 0), 0).xyz,
        texelFetch(sceneTex, index + ivec2(2, 0), 0).xyz
    );

    vec3 smoothNormal = normals * vec3(uv, 1.0f - uv.x - uv.y);
    vec3 geometryNormal = smoothNormal;
    // Read UVs of vertices
    vec3 vUVs1 = texelFetch(sceneTex, index + ivec2(3, 0), 0).xyz;
    vec3 vUVs2 = texelFetch(sceneTex, index + ivec2(4, 0), 0).xyz;
    mat3x2 vertexUVs = mat3x2(vUVs1, vUVs2);
    // Fetch texture ids for current face
    vec3 textureNums = texelFetch(sceneTex, index + ivec2(5, 0), 0).xyz;
    // Interpolate final barycentric coordinates
    vec2 barycentric = vertexUVs * vec3(uv, 1.0f - uv.x - uv.y);
    // Alter normal and color according to texture and normal texture
    // Test if textures are even set otherwise use defaults.
    // Default texColor to color
    Material material = Material(
        mix(
            texelFetch(sceneTex, index + ivec2(6, 0), 0).xyz,
            lookup(tex, vec3(barycentric, textureNums.x)),
            max(sign(textureNums.x + 0.5f), 0.0f)
        ), 
        mix(
            texelFetch(sceneTex, index + ivec2(7, 0), 0).xyz,
            lookup(pbrTex, vec3(barycentric, textureNums.y)).xyz, 
            max(sign(textureNums.y + 0.5f), 0.0f)
        ),
        mix(
            texelFetch(sceneTex, index + ivec2(8, 0), 0).xyz,
            lookup(translucencyTex, vec3(barycentric, textureNums.z)),
            max(sign(textureNums.z + 0.5f), 0.0f)
        )
    );

    originalTPOx = material.tpo.x;
    // Preserve original roughness for filter pass
    float filterRoughness = material.rme.x;
    // Generate camera ray
    vec3 dir = normalize(position - camera);
    Ray ray = Ray(dir, dir, position);
    // vec3 finalColor = material.rme;
    vec3 finalColor = vec3(0);
    // Generate multiple samples
    for(int i = 0; i < samples; i++) finalColor += lightTrace(camera, ray, material, smoothNormal, geometryNormal, i, maxReflections);
    // Average ray colors over samples.
    float invSamples = 1.0f / float(samples);
    finalColor *= invSamples;
    originalRMEx *= invSamples;
    if(useFilter == 1) {
        // Render all relevant information to 4 textures for the post processing shader
        renderColor = vec4(mod(finalColor, 1.0f), 1.0f);
        // 16 bit HDR for improved filtering
        renderColorIp = vec4(floor(finalColor) * INV_256, glassFilter);
    } else {
        finalColor *= originalColor;
        if(isTemporal == 1) {
            renderColor = vec4(mod(finalColor, 1.0f), 1.0f);
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