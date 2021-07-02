#version 300 es

in vec3 position_3d;
in vec3 normal_3d;
in vec2 tex_pos;
in vec4 color_3d;

uniform vec3 player_position;
uniform vec2 perspective;
uniform vec4 conf;

out vec3 player;
out vec3 position;
out vec3 normal;
out vec2 tex_coord;
out vec4 color;
out vec3 clip_space;

void main(){
  vec3 move_3d = position_3d + vec3(player_position.x, - player_position.yz);
  vec2 translate_px = vec2(
    move_3d.x * cos(perspective.x) + move_3d.z * sin(perspective.x),
    move_3d.z * cos(perspective.x) - move_3d.x * sin(perspective.x)
  );
  vec2 translate_py = vec2(
    move_3d.y * cos(perspective.y) + translate_px.y * sin(perspective.y),
    translate_px.y * cos(perspective.y) - move_3d.y * sin(perspective.y)
  );
  vec2 translate_2d = conf.x * vec2(translate_px.x, translate_py.x * conf.y);
  // Set final clip space position.
  gl_Position = vec4(translate_2d, - 0.99 / (1.0 + exp(- length(move_3d / 100.0))), translate_py.y);
  clip_space = vec3(translate_2d, translate_py.y);
  player = player_position;
  position = position_3d;
  normal = normalize(normal_3d);
  tex_coord = tex_pos;
  color = color_3d;
}
