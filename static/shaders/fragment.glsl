#version 300 es

precision lowp float;
in float normal;
in vec2 texture_coord;

uniform sampler2D texture;
uniform vec4 color;

out vec4 outColor;

void main() {
  outColor = vec4(
    color.x * normal,
    color.y * normal,
    color.z * normal,
    color.w
  );
}
