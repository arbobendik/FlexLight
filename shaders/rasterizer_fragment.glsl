#version 300 es
#define PI 3.141592653589793
#define SQRT3 1.73205
#define BIAS 0.00001525879
#define INV_TRIANGLES_PER_ROW 0.00390625
#define TRIANGLES_PER_ROW 256.0
#define INV_PI 0.3183098861837907
#define INV_256 0.00390625
#define INV_65536 0.00001525879
#define THIRD 0.333333

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
flat in int transformationId;

layout (std140) uniform transformMatrix {
    mat4 transform[65520];
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

// Simplified rayTracer to only test if ray intersects anything
bool shadowTest(Ray ray) {
    // Precomput max length
    float minLen = length(ray.direction);
    // Get texture size as max iteration value
    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;
    int size = geometryTexSize.y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for(int i = 0; i < size; i++) {
        float fi = float(i);
        // Get position of current triangle/vertex in geometryTex
        ivec2 index = ivec2(mod(fi, TRIANGLES_PER_ROW) * 4.0f, fi * INV_TRIANGLES_PER_ROW);
        // Fetch triangle coordinates from scene graph
        vec3 a = texelFetch(geometryTex, index, 0).xyz;
        vec3 b = texelFetch(geometryTex, index + ivec2(1, 0), 0).xyz;
        vec3 c = texelFetch(geometryTex, index + ivec2(2, 0), 0).xyz;

        int transformationIndex = int(texelFetch(geometryTex, index + ivec2(3, 0), 0).x);
        mat4 localTransformInverse = transform[transformationIndex * 2 + 1];
        vec3 transformedDir = (localTransformInverse * vec4(ray.unitDirection, 0.0)).xyz;
        vec3 transformedOrigin = (localTransformInverse * vec4(ray.origin, 1.0)).xyz;
        // Three cases:
        // c is X 0 0        => is bounding volume: do AABB intersection test
        // c is 0 0 0        => end of list: stop loop
        // otherwise         => is triangle: do triangle intersection test
        if(c.yz == vec2(0)) {
            if(c.x == 0.0f) break;
            if(!rayCuboid(minLen, 1.0 / transformedDir, transformedOrigin, a, b)) i += int(c.x);
        } else {
            Ray transformed = Ray(transformedDir, transformedDir, transformedOrigin);
            if(moellerTrumboreCull(minLen, transformed, a, b, c)) return true;
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


    vec3 absolutePosition = (transform[transformationId * 2] * vec4(position, 1.0)).xyz;
    // Transform normal with local transform
    vec3 smoothNormal = normalize((transform[transformationId * 2] * vec4(normals * vec3(uv, 1.0f - uv.x - uv.y), 0.0)).xyz);
    
    // Read UVs of vertices
    vec3 vUVs1 = texelFetch(sceneTex, index + ivec2(3, 0), 0).xyz;
    vec3 vUVs2 = texelFetch(sceneTex, index + ivec2(4, 0), 0).xyz;
    mat3x2 vertexUVs = mat3x2(vUVs1, vUVs2);
    // Fetch texture ids for current face
    vec3 textureNums = texelFetch(sceneTex, index + ivec2(5, 0), 0).xyz;
    vec3 albedo = texelFetch(sceneTex, index + ivec2(6, 0), 0).xyz;
    vec3 rme = texelFetch(sceneTex, index + ivec2(7, 0), 0).xyz;
    vec3 tpo = texelFetch(sceneTex, index + ivec2(8, 0), 0).xyz;
    // Interpolate final barycentric coordinates
    vec2 barycentric = vertexUVs * vec3(uv, 1.0f - uv.x - uv.y);
    // Test if textures are even set otherwise use defaults.
    // Default texColor to color
    Material material = Material(
        mix(
            albedo,
            lookup(tex, vec3(barycentric, textureNums.x)),
            max(sign(textureNums.x + 0.5f), 0.0f)
        ), 
        mix(
            rme,
            lookup(pbrTex, vec3(barycentric, textureNums.y)).xyz, 
            max(sign(textureNums.y + 0.5f), 0.0f)
        ),
        mix(
            tpo,
            lookup(translucencyTex, vec3(barycentric, textureNums.z)),
            max(sign(textureNums.z + 0.5f), 0.0f)
        )
    );

    vec3 finalColor = vec3(material.rme.z);
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
        Ray lightRay = Ray(dir, normalize(dir), absolutePosition);
        vec3 localColor = forwardTrace(light - position, smoothNormal, normalize(camera - position), material, strength);
        // Add emissive and ambient light
        localColor += material.rme.z + ambient * 0.25;
        // Compute quick exit criterion to potentially skip expensive shadow test
        bool quickExitCriterion = length(localColor) == 0.0f || dot(lightRay.unitDirection, smoothNormal) <= BIAS;
        // Update pixel color if coordinate is not in shadow
        if(!quickExitCriterion && !shadowTest(lightRay)) finalColor += localColor;
    }

    finalColor *= material.albedo;

    float translucencyFactor = min(1.0 + max(finalColor.x, max(finalColor.y, finalColor.z)) - material.tpo.x, 1.0);
    finalColor = mix(material.albedo * material.albedo * 0.25, finalColor, translucencyFactor);

    if(hdr == 1) {
        // Apply Reinhard tone mapping
        finalColor = finalColor / (finalColor + vec3(1.0f));
        // Gamma correction
        float gamma = 0.8f;
        finalColor = pow(4.0f * finalColor, vec3(1.0f / gamma)) / 4.0f * 1.3f;
    }

    renderColor = vec4(finalColor, 1.0f - (0.5 * material.tpo.x));
}
