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
  float dnr = dot(n, r);
  // Test if ray and plane are parallel.
  if(dnr == 0.0) return false;
  float s = dot(n , a - p) / dnr;
  // Ensure that ray triangle intersection is between light source and texture.
  if (s > length(l - p) || s <= 0.0) return false;
  // Calculate intersection point.
  vec3 d = (s * r) + p;
  // Test if point on plane is in Triangle by looking for each edge if point is in or outside.
  vec3 v0 = c - a;
  vec3 v1 = b - a;
  vec3 v2 = d - a;
  float dot00 = dot(v0, v0);
  float dot01 = dot(v0, v1);
  float dot02 = dot(v0, v2);
  float dot11 = dot(v1, v1);
  float dot12 = dot(v1, v2);
  float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
  float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
  float v = (dot00 * dot12 - dot01 * dot02) * invDenom;
  return (u >= 0.0) && (v >= 0.0) && (u + v < 1.0);
}

void main(){
  ivec2 size = textureSize(world_tex, 0);
  bool in_shadow = false;
  vec3 ray = normalize(light - position);

  for(int i = 0; i < size.y; i++){
    vec3 n = normalize(texelFetch(world_tex, ivec2(4, i), 0).xyz);
    // If surfaces point in same direction intersection is not possible.
    if(n == normal) continue;
    // Test if ray or surface face in same direction.
    if(sign(n) == sign(ray)) continue;
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
