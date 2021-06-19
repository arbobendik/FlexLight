#version 300 es

in vec3 position_3d;
in vec3 normal_3d;
in vec2 world_tex_pos;

uniform vec3 player_position;
uniform vec2 perspective;
uniform vec4 conf;

out float normal;
out vec2 world_tex_coord;

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
  if (translate_py.y > 0.0){
    vec2 translate_2d = conf.x * vec2(translate_px.x, translate_py.x * conf.y) / translate_py.y;
    gl_Position = vec4(translate_2d, 0.99 / (1.0 + exp(- length(move_3d))), 1.0 );
    normal = dot(normalize(vec3(-1.0, -1.0, 1.0) * position_3d + vec3(-1.0, 1.0, -1.0) * player_position) ,normal_3d);
    world_tex_coord = world_tex_pos;
  }
}
