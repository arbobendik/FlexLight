#version 300 es

in vec2 position_2d;
// Pass clip space position to fragment shader.
out vec2 clip_space;

void main(){
  vec2 pos = position_2d * 2.0 - 1.0;
  // Set final clip space position.
  gl_Position = vec4(pos, 0, 1);
  clip_space = position_2d;
}
