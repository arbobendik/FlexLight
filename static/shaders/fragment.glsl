#version 300 es

precision highp float;
in vec3 player;
in vec3 position;
in vec3 normal;
in vec2 tex_coord;
in vec4 color;

vec3 light = vec3(0.0, 3.5, 0.0);
float strength = 3.0;
uniform sampler2D world_tex;

out vec4 outColor;

// normal, light source, pixel position, triangle.
bool shadowTrace(vec3 l, vec3 r, vec3 p, vec3 a, vec3 b, vec3 c, vec3 n){
  // Test if ray and plane are parallel.
  if(dot(n, r) == 0.0) return false;
  float s = dot(n , a - p) / dot(n, r);
  // Ensure that ray triangle intersection is between light source and texture.
  if (s > length(l - p) || s <= 0.0) return false;
  // Calculate intersection point.
  vec3 d = (s * r) + p;
  // Test if point on plane is in Triangle by looking for each edge if point is in or outside.
  if (dot(cross(c-b, d-b), cross(c-b, a-b)) < 0.0) return false;
  if (dot(cross(c-a, d-a), cross(c-a, b-a)) < 0.0) return false;
  return dot(cross(b-a, d-a), cross(b-a, c-a)) >= 0.0;
}

void main(){
  ivec2 size = textureSize(world_tex, 0);
  bool in_shadow = false;
  vec3 ray = normalize(light - position);

  for(int i = 0; i < size.y; i++){
    vec3 n = normalize(texelFetch(world_tex, ivec2(4, i), 0).xyz);
    // Test if ray or surface face in different direction.
    if(sign(n) == sign(ray)) continue;
    // If surfaces point in same direction intersection is not possible.
    if(n == normal) continue;
    // Fetch triangle coordinates from world texture.
    vec3 a = texelFetch(world_tex, ivec2(0, i), 0).xyz;
    vec3 b = texelFetch(world_tex, ivec2(1, i), 0).xyz;
    vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
    in_shadow = shadowTrace(light, ray, position, a, b, c, n);
    if(in_shadow) break;
  }
  float intensity = strength / (1.0 + length(light - position) / strength);
  if (in_shadow){
    outColor = vec4(0.0 * color.xyz, color.w);
  }else{
    vec3 view = normalize(vec3(-player.x, player.yz) - position);
    vec3 halfVector = normalize(ray + view);
    float l = dot(normalize(vec3(-light.x - position.x, ray.y, -light.z + position.z)), normal);
    float specular = pow(dot(normal, halfVector), 50.0 * strength);
    outColor = vec4(color.xyz * l * intensity, color.w);
    if (specular > 0.0) outColor.rgb += specular * intensity;
  }
}
