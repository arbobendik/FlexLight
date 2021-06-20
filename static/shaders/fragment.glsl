#version 300 es

precision lowp float;
in float normal;
in vec2 world_tex_coord;

uniform vec4 sampler2D world_tex;
uniform vec4 color;

out vec4 outColor;

void main() {
  outColor = 0.5 * vec4(normal * color.xyz, color.w) + 0.5 * normal * texture(world_tex, world_tex_coord);
}
