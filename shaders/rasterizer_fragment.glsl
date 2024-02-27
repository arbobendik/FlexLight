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

precision highp float;
precision highp sampler2D;

struct NormalizedRay {
    vec3 origin;
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
// Get global illumination color, intensity
uniform vec3 ambient;
// Textures in parallel for texture atlas
uniform int textureWidth;
uniform int hdr;
// Texture with information about all triangles in scene
uniform sampler2D geometryTex;
uniform sampler2D sceneTex;
// Random texture to multiply with normal map to simulate rough surfaces
uniform sampler2D translucencyTex;
uniform sampler2D pbrTex;
uniform sampler2D tex;
// Texture with all primary light sources of scene
uniform sampler2D lightTex;

layout(location = 0) out vec4 renderColor;
float invTextureWidth = 1.0f;


// Lookup values for texture atlases
vec3 lookup(sampler2D atlas, vec3 coords) {
    float atlasHeightFactor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) * invTextureWidth;
    vec2 atlasCoords = vec2((coords.x + mod(coords.z, float(textureWidth))) * invTextureWidth, (coords.y + floor(coords.z * invTextureWidth)) * atlasHeightFactor);
    // Return texel on requested location
    return texture(atlas, atlasCoords).xyz;
}

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
bool moellerTrumboreCull(float l, NormalizedRay ray, vec3 a, vec3 b, vec3 c) {
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

// Simplified rayTracer to only test if ray intersects anything
bool shadowTest(Ray ray) {
    // Cache transformed ray attributes
    NormalizedRay tR = NormalizedRay(ray.origin, ray.unitDirection);
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
                rotation[iI] * (ray.origin + shift[iI]),
                normalize(rotation[iI] * ray.unitDirection)
            );
            invDir = 1.0 / tR.unitDirection;
        }
        // Three cases:
        // c is X 0 0        => is bounding volume: do AABB intersection test
        // c is 0 0 0        => end of list: stop loop
        // otherwise         => is triangle: do triangle intersection test
        if(c.yz == vec2(0)) {
            if(c.x == 0.0f) break;
            if(!rayCuboid(minLen, invDir, tR.origin, a, b)) i += int(c.x);
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

vec3 fresnel(vec3 F0, float VdotH) {
    // Use Schlick approximation
    return F0 + (1.0f - F0) * pow(1.0f - VdotH, 5.0f);
}

/*
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
    return BRDF * brightness;
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
    vec3 geometryNormal = normalize(normals[0] + normals[1] + normals[2]);
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

    vec3 finalColor = vec3(material.rme.z + ambient);
    // Calculate primary light sources for this pass if ray hits non translucent object
    for(int j = 0; j < textureSize(lightTex, 0).y; j++) {
        // Read light position
        vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz;
        // Read light strength from texture
        float strength = texelFetch(lightTex, ivec2(1, j), 0).x;
        // Skip if strength is negative or zero
        if(strength <= 0.0f) continue;

        // Form light vector
        vec3 dir = light - absolutePosition;
        Ray lightRay = Ray(absolutePosition, light, dir, normalize(dir));
        vec3 localColor = forwardTrace(material, light - position, strength, smoothNormal, normalize(camera - position));
        // Compute quick exit criterion to potentially skip expensive shadow test
        bool showColor = length(localColor) == 0.0f;

        // lightRay.origin += sin(acos(dot(smoothNormal, geometryNormal))) * smoothNormal;
        // Update pixel color if coordinate is not in shadow
        if(showColor || !shadowTest(lightRay)) finalColor += localColor;
    }

    finalColor *= material.albedo;

    float translucencyFactor = min(1.0 + max(finalColor.x, max(finalColor.y, finalColor.z)) - material.tpo.x, 1.0);
    finalColor = mix(material.albedo * material.albedo, finalColor, translucencyFactor);

    if(hdr == 1) {
        // Apply Reinhard tone mapping
        finalColor = finalColor / (finalColor + vec3(1.0f));
        // Gamma correction
        float gamma = 0.8f;
        finalColor = pow(4.0f * finalColor, vec3(1.0f / gamma)) / 4.0f * 1.3f;
    }

    renderColor = vec4(finalColor, 1.0f - (0.5 * material.tpo.x));
}
