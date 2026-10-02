#version 300 es

precision highp float;
precision highp int;

const float POW32 = 4294967296.0;

in vec3 absolute_position;
in vec2 uv;
in float depth;
flat in uint instance_index;
flat in uint triangle_index;

layout(location = 0) out vec4 position_out;
layout(location = 1) out uvec4 offset_out;

void main() {
    // Linear depth in a float depth buffer keeps precision relative to the distance
    gl_FragDepth = depth / POW32;
    // Save values for shading pass
    position_out = vec4(absolute_position, 0.0);
    // Add 1 to have 0 as invalid index, store uv bits alongside to save a texture unit in the shading pass
    offset_out = uvec4(instance_index + 1u, triangle_index + 1u, floatBitsToUint(uv));
}
