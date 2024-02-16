#version 300 es
#define TRIANGLES_PER_ROW_POWER 8
#define TRIANGLES_PER_ROW 256
#define INV_65536 0.00001525879

precision highp int;
precision highp float;
precision highp sampler2D;

in int triangleId;
in int vertexId;

layout (std140) uniform transformMatrix {
    mat4 transform[65520];
};

uniform vec3 cameraPosition;
uniform mat3 matrix;

// Texture with vertex information about all triangles in scene
uniform sampler2D geometryTex;

out vec3 position;
out vec2 uv;
out vec3 clipSpace;

flat out vec3 camera;
flat out int fragmentTriangleId;

const mat4 identityMatrix = mat4(
    vec4(1.0f, 0.0f, 0.0f, 0.0f),
    vec4(0.0f, 1.0f, 0.0f, 0.0f),
    vec4(0.0f, 0.0f, 1.0f, 0.0f),
    vec4(0.0f, 0.0f, 0.0f, 1.0f)
);

const vec2 baseUVs[3] = vec2[3](vec2(1, 0), vec2(0, 1), vec2(0, 0));

void main() {
    // Calculate vertex position in texture
    int triangleColumn = triangleId >> TRIANGLES_PER_ROW_POWER;
    ivec2 index = ivec2((triangleId - triangleColumn * TRIANGLES_PER_ROW) * 4, triangleColumn);

    // Read vertex position from texture
    vec3 position3d = texelFetch(geometryTex, index + ivec2(vertexId, 0), 0).xyz;
    int tranformationIndex = int(texelFetch(geometryTex, index + ivec2(3, 0), 0).x);

    mat4 localTransform = identityMatrix;
    if (tranformationIndex >= 0) localTransform = transform[tranformationIndex];
    // Apply local geometry transform
    vec4 localGeometry = localTransform * vec4(position3d, 1.0);
    vec3 move3d = localGeometry.xyz - cameraPosition;
    clipSpace = matrix * move3d;

    // Set triangle position in clip space
    gl_Position = vec4(clipSpace.xy, -1.0f / (1.0f + exp(- length(move3d * INV_65536))), clipSpace.z);
    position = position3d;

    uv = baseUVs[vertexId];
    camera = cameraPosition;
    fragmentTriangleId = triangleId;
}
