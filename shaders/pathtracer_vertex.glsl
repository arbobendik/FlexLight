#version 300 es
#define TRIANGLES_PER_ROW_POWER 8
#define TRIANGLES_PER_ROW 256
#define INV_65536 0.00001525879

precision highp int;
precision highp float;
precision highp sampler2D;

in int triangleId;
in int vertexId;

layout (std140) uniform transformMatrix
{
    mat3 rotation[MAX_TRANSFORMS];
    vec3 shift[MAX_TRANSFORMS];
};

uniform vec3 cameraPosition;
uniform mat3 viewMatrix;

// Texture with vertex information about all triangles in scene
uniform sampler2D geometryTex;

out vec3 position;
out vec2 uv;
out vec3 clipSpace;

flat out vec3 camera;
flat out int fragmentTriangleId;
flat out int transformationId;

flat out mat3 firstTriangle;

const vec2 baseUVs[3] = vec2[3](
    vec2(1, 0), 
    vec2(0, 1), 
    vec2(0, 0)
);

void main() {
    // Calculate vertex position in texture
    int triangleColumn = triangleId >> TRIANGLES_PER_ROW_POWER;
    ivec2 index = ivec2((triangleId - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);

    vec4 t0 = texelFetch(geometryTex, index, 0);
    vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);
    vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);

    mat3 triangle = mat3(t0, t1, t2.x);

    transformationId = int(t2.y);
    // Apply local geometry transform
    int tI = transformationId << 1;
    // Combine vertex position
    switch (vertexId) {
        case 0:
            position = rotation[tI] * triangle[0] + shift[tI];
            break;
        case 1:
            position = rotation[tI] * triangle[1] + shift[tI];
            break;
        case 2:
            position = rotation[tI] * triangle[2] + shift[tI];
            break;
    }
    // Transform position
    vec3 move3d = position - cameraPosition;
    clipSpace = viewMatrix * move3d;
    // Set triangle position in clip space
    gl_Position = vec4(clipSpace.xy, -1.0f / (1.0f + exp(- length(move3d * INV_65536))), clipSpace.z);
    position = position;

    uv = baseUVs[vertexId];
    camera = cameraPosition;
    fragmentTriangleId = triangleId;
    // Transform triangle
    firstTriangle = rotation[tI] * triangle + mat3(shift[tI], shift[tI], shift[tI]);
}