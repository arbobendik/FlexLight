#version 300 es

precision lowp float;
in float normal;

uniform vec4 coordinates;
uniform vec4 color;

// we need to declare an output for the fragment shader
out vec4 outColor;

void main() {
  outColor = vec4(
    color.x * normal,
    color.y * normal,
    color.z * normal,
    color.w
  );
}
