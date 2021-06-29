#version 300 es

precision highp float;
in vec3 player;
in vec3 position;
in vec3 normal;
in vec2 tex_coord;
in vec4 color;
in vec3 clip_space;

vec3 light = vec3(0.0, 3.0, 0.0);
float strength = 3.0;
uniform sampler2D world_tex;

out vec4 outColor;

// normal, light source, pixel position, triangle.
bool shadowTrace(vec3 l, vec3 r, vec3 p, vec3 a, vec3 b, vec3 c, vec3 n){
  float dnr = dot(n, r);
  // Test if ray or surface face in same direction.
  if(sign(n) == sign(r)) return false;
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
  // Precalculate dot products.
  float d00 = dot(v0, v0);
  float d01 = dot(v0, v1);
  float d02 = dot(v0, v2);
  float d11 = dot(v1, v1);
  float d12 = dot(v1, v2);
  // Compute coordinates.
  float i = 1.0 / (d00 * d11 - d01 * d01);
  float u = (d11 * d02 - d01 * d12) * i;
  float v = (d00 * d12 - d01 * d02) * i;
  // Return if ray intersects triangle or not.
  return (u > 0.0) && (v > 0.0) && (u + v < 1.0);
}

void main(){
  if (clip_space.z < 0.0) return;
  ivec2 size = textureSize(world_tex, 0);
  bool in_shadow = false;
  vec3 ray = normalize(light - position);
  // Iterate over traingles in scene.
  if (dot(ray, normal) > 0.1){
    for (int i = 0; i < size.y && !in_shadow; i++){
      vec3 n = normalize(texelFetch(world_tex, ivec2(4, i), 0).xyz);
      // Fetch triangle coordinates from world texture.
      vec3 a = texelFetch(world_tex, ivec2(0, i), 0).xyz;
      vec3 b = texelFetch(world_tex, ivec2(1, i), 0).xyz;
      vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
      // Test if triangle intersects ray.
      in_shadow = shadowTrace(light, ray, position, a, b, c, n);
    }
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
