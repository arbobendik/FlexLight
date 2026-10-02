#version 300 es

precision highp float;
precision highp int;
precision highp sampler2DArray;
precision highp usampler2DArray;

const uint TRIANGLE_SIZE = 6u;
const uint INSTANCE_UINT_SIZE = 9u;

struct Transform {
    mat3 rotation;
    vec3 shift;
};

uniform sampler2DArray triangles;
uniform usampler2DArray instance_uint;
uniform sampler2DArray instance_transform;

uniform mat3 view_matrix;
uniform vec3 camera_position;
uniform uint instance_count;

out vec3 absolute_position;
out vec2 uv;
out float depth;
flat out uint instance_index;
flat out uint triangle_index;

ivec3 buffer_position(uint index) {
    // Divide index by 2048 * 2048 to get layer, remainder is split into row and column
    return ivec3(int(index & 0x7FFu), int((index >> 11u) & 0x7FFu), int(index >> 22u));
}

vec4 access_triangle(uint index) {
    return texelFetch(triangles, buffer_position(index), 0);
}

uint access_instance_uint(uint index) {
    return texelFetch(instance_uint, buffer_position(index), 0).x;
}

Transform access_instance_transform(uint index) {
    uint offset = index * 4u;
    return Transform(
        mat3(texelFetch(instance_transform, buffer_position(offset), 0).xyz, texelFetch(instance_transform, buffer_position(offset + 1u), 0).xyz, texelFetch(instance_transform, buffer_position(offset + 2u), 0).xyz),
        texelFetch(instance_transform, buffer_position(offset + 3u), 0).xyz
    );
}

uint binary_search_instance(uint triangle_number) {
    uint left = 0u;
    uint right = instance_count;
    while (left + 1u < right) {
        uint mid = left + (right - left) / 2u;
        uint start_number = access_instance_uint(mid * INSTANCE_UINT_SIZE + 8u);
        if (start_number <= triangle_number) {
            left = mid;
        } else {
            right = mid;
        }
    }
    return left;
}

void main() {
    uint vertex_num = uint(gl_VertexID) % 3u;
    uint triangle_number = uint(gl_InstanceID);

    instance_index = binary_search_instance(triangle_number);
    uint instance_uint_offset = instance_index * INSTANCE_UINT_SIZE;

    uint triangle_instance_offset = access_instance_uint(instance_uint_offset);
    uint triangle_index_offset = access_instance_uint(instance_uint_offset + 8u);
    uint triangle_offset = triangle_instance_offset + (triangle_number - triangle_index_offset) * TRIANGLE_SIZE;
    triangle_index = triangle_offset / TRIANGLE_SIZE;

    vec3 relative_position;
    // Set uv to vertex uv and let the vertex interpolation generate the values in between
    if (vertex_num == 0u) {
        relative_position = access_triangle(triangle_offset).xyz;
        uv = vec2(1.0, 0.0);
    } else if (vertex_num == 1u) {
        relative_position = vec3(access_triangle(triangle_offset).w, access_triangle(triangle_offset + 1u).xy);
        uv = vec2(0.0, 1.0);
    } else {
        relative_position = vec3(access_triangle(triangle_offset + 1u).zw, access_triangle(triangle_offset + 2u).x);
        uv = vec2(0.0, 0.0);
    }
    // Transform position
    Transform transform = access_instance_transform(instance_index * 2u);
    absolute_position = transform.rotation * relative_position + transform.shift;

    vec3 clip_space = view_matrix * (absolute_position - camera_position);
    depth = clip_space.z;
    // Set triangle position in clip space
    gl_Position = vec4(clip_space.xy, 0.0, clip_space.z);
}
