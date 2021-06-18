#version 300 es

precision lowp float;
in float normal;
in vec2 position_texture_coord;

uniform sampler2D position_texture;
uniform vec4 color;

out vec4 outColor;

void main() {
  outColor = vec4(normal * color.xyz, color.w);
}
