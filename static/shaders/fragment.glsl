#version 300 es

precision highp float;
in vec3 player;
in vec3 position;
in vec3 normal;
in vec2 tex_coord;
in vec4 color;
in vec3 clip_space;

// Declare null vector as constant.
const vec3 null = vec3(0.0, 0.0, 0.0);

vec3 light = vec3(0.0, 3.0, 0.0);
float strength = 3.0;
uniform sampler2D world_tex;

out vec4 outColor;


// light source, pixel position, triangle points a, b, c, normal.
bool rayTriangle(vec3 l, vec3 r, vec3 p, vec3 a, vec3 b, vec3 c, vec3 n){
  float dnr = dot(n, r);
  // Test if ray or surface face in same direction.
  if(sign(n) == sign(r)) return false;
  // Test if ray and plane are parallel.
  if(dnr == 0.0) return false;
  // Get distance to intersection point.
  float s = dot(n , a - p) / dnr;
  // Ensure that ray triangle intersection is between light source and texture.
  if(s > length(l - p) || s <= 0.0) return false;
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

bool rayCuboid(vec3 inv_ray, vec3 p, vec3 min_corner, vec3 max_corner){
  vec2 v1 = (vec2(min_corner.x, max_corner.x) - p.x) * inv_ray.x;
  vec2 v2 = (vec2(min_corner.y, max_corner.y) - p.y) * inv_ray.y;
  vec2 v3 = (vec2(min_corner.z, max_corner.z) - p.z) * inv_ray.z;
  float lowest = max(max(min(v1.x, v1.y), min(v2.x, v2.y)), min(v3.x, v3.y));
  float highest = min(min(max(v1.x, v1.y), max(v2.x, v2.y)), max(v3.x, v3.y));
  // Cuboid is behind ray.
  if (highest < 0.0) return false;
  // Ray points in cuboid direction, but doesn't intersect.
  if (lowest > highest) return false;
  return true;
}

bool shadowTest(sampler2D tex, vec3 ray, vec3 light){
  // Precompute inverse of ray for AABB cuboid intersection test.
  vec3 inv_ray = 1.0 / ray;
  // Get texture size as max iteration value.
  ivec2 size = textureSize(world_tex, 0);
  // Test if pixel is in shadow or not.
  bool in_shadow = false;
  // Iterate through lines of texture.
  for(int i = 0; i < size.y && !in_shadow; i++){
    // Read point a and normal from traingle.
    vec3 n = texelFetch(tex, ivec2(4, i), 0).xyz;
    vec3 a = texelFetch(tex, ivec2(0, i), 0).xyz;
    // Fetch triangle coordinates from world texture.
    //  Three cases:
    //   - normal is not 0 0 0 --> normal vertex
    //   - normal is 0 0 0 --> beginning of new bounding volume
    if(n != null){
      vec3 b = texelFetch(tex, ivec2(1, i), 0).xyz;
      vec3 c = texelFetch(tex, ivec2(2, i), 0).xyz;
      // Test if triangle intersects ray.
      in_shadow = rayTriangle(light, ray, position, a, b, c, n);
    }else{
      vec3 b = texelFetch(tex, ivec2(1, i), 0).xyz;
      // Test if Ray intersects bounding volume.
      // a = x x2 y
      // b = y2 z z2
      if(!rayCuboid(inv_ray, position, vec3(a.x, a.z, b.y), vec3(a.y, b.x, b.z))){
        vec3 c = texelFetch(tex, ivec2(2, i), 0).xyz;
        // If it doesn't intersect, skip ahadow test for all elements in bounding volume.
        i += 12;
      }
    }
  }
  // Return if bounding volume is partially in shadow or not.
  return in_shadow;
}

vec3 lightTrace(sampler2D tex, vec3 ray, vec3 light, int bounces){
  // Use additive color mixing technique, so start with black.
  vec3 color = vec3(0.0, 0.0, 0.0);
  // Ray currently traced.
  vec3 active_ray = ray;
  // Triangle ray lastly intersected with.
  mat3 last_triangle = mat3(0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0);
  // Iterate over each bounce and modify color accordingly.
  for(int i = 0; i < bounces; i++){
    bool in_shadow = shadowTest(tex, active_ray, light);
    active_ray = active_ray;
  }
  // Return final pixel color.
  return color;
}

void main(){
  // Test if pixel is in shadow or not.
  bool in_shadow = false;
  if(clip_space.z < 0.0) return;
  vec3 ray = normalize(light - position);
  // Iterate over traingles in scene.
  if(dot(ray, normal) > 0.0){
    // Start hybrid ray tracing.
    in_shadow = shadowTest(world_tex, ray, light);
  }

  float intensity = strength / (1.0 + length(light - position) / strength);
  if(in_shadow){
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
