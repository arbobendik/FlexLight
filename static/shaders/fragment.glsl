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
const float shadow_bias = 0.00001;

vec3 light = vec3(0.0, 3.2, 0.0);
float strength = 3.0;

uniform sampler2D world_tex;

out vec4 outColor;


// Test if ray intersects triangle and return intersection.
vec3 rayTriangle(float l, vec3 r, vec3 p, vec3 a, vec3 b, vec3 c, vec3 n){
  float dnr = dot(n, r);
  // Test if ray or surface face in same direction.
  if(sign(n) == sign(r)) return null;
  // Test if ray and plane are parallel.
  if(dnr == 0.0) return null;
  // Get distance to intersection point.
  float s = dot(n , a - p) / dnr;
  // Ensure that ray triangle intersection is between light source and texture.
  if(s > l || s < 0.0) return null;
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
  if((u > shadow_bias) && (v > shadow_bias) && (u + v < 1.0)){
    return d;
  }else{
    return null;
  }
}

// Don't return intersection point, because we're looking for a specific triangle.
bool rayCuboid(vec3 inv_ray, vec3 p, vec3 min_corner, vec3 max_corner){
  vec2 v1 = (vec2(min_corner.x, max_corner.x) - p.x) * inv_ray.x;
  vec2 v2 = (vec2(min_corner.y, max_corner.y) - p.y) * inv_ray.y;
  vec2 v3 = (vec2(min_corner.z, max_corner.z) - p.z) * inv_ray.z;
  float lowest = max(max(min(v1.x, v1.y), min(v2.x, v2.y)), min(v3.x, v3.y));
  float highest = min(min(max(v1.x, v1.y), max(v2.x, v2.y)), max(v3.x, v3.y));
  // Cuboid is behind ray.
  if (highest <= shadow_bias) return false;
  // Ray points in cuboid direction, but doesn't intersect.
  if (lowest > highest) return false;
  return true;
}

// Test for closest ray triangle intersection.
// Return intersection position in world space (rayTracer.xyz).
// Return index of target triangle in world_tex (rayTracer.w).
vec4 rayTracer(vec3 ray, vec3 origin){
  // Precompute inverse of ray for AABB cuboid intersection test.
  vec3 inv_ray = 1.0 / ray;
  // Get texture size as max iteration value.
  ivec2 size = textureSize(world_tex, 0);
  // Test if pixel is in shadow or not.
  int target_triangle = - 1;
  // Latest intersection which is now closest to origin.
  vec3 intersection = null;
  // Length to latest intersection.
  float min_len = - 1.0;
  // Iterate through lines of texture.
  for(int i = 0; i < size.y; i++){
    // Read point a and normal from traingle.
    vec3 n = texelFetch(world_tex, ivec2(4, i), 0).xyz;
    vec3 a = texelFetch(world_tex, ivec2(0, i), 0).xyz;
    vec3 b = texelFetch(world_tex, ivec2(1, i), 0).xyz;
    // Fetch triangle coordinates from world texture.
    //  Three cases:
    //   - normal is not 0 0 0 --> normal vertex
    //   - normal is 0 0 0 --> beginning of new bounding volume
    if(n != null){
      vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
      // Test if triangle intersects ray.
      vec3 current_intersection = rayTriangle(50.0, ray, origin, a, b, c, n);
      // Test if ray even intersects.
      if(current_intersection == null) continue;
      // Calculate length to origin.
      float len = length(current_intersection - origin);
      // Test if this intersection is the closest.
      if(len < min_len || min_len == - 1.0){
        min_len = len;
        target_triangle = i;
        intersection = current_intersection;
      }
    }else{
      // Test if Ray intersects bounding volume.
      // a = x x2 y
      // b = y2 z z2
      if(!rayCuboid(inv_ray, origin, vec3(a.x, a.z, b.y), vec3(a.y, b.x, b.z))){
        vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
        // If it doesn't intersect, skip shadow test for all elements in bounding volume.
        i += int(c.x);
      }
    }
  }
  // Return if pixel is in shadow or not.
  return vec4(intersection, float(target_triangle));
}

// Simplified rayTracer test only if ray intersects anything.
bool shadowTest(vec3 ray, vec3 light, vec3 origin){
  // Precompute inverse of ray for AABB cuboid intersection test.
  vec3 inv_ray = 1.0 / ray;
  // Get texture size as max iteration value.
  ivec2 size = textureSize(world_tex, 0);
  // Test if pixel is in shadow or not.
  bool in_shadow = false;
  // Iterate through lines of texture.
  for(int i = 0; i < size.y && !in_shadow; i++){
    // Read point a and normal from traingle.
    vec3 n = texelFetch(world_tex, ivec2(4, i), 0).xyz;
    vec3 a = texelFetch(world_tex, ivec2(0, i), 0).xyz;
    vec3 b = texelFetch(world_tex, ivec2(1, i), 0).xyz;
    // Fetch triangle coordinates from world texture.
    //  Three cases:
    //   - normal is not 0 0 0 --> normal vertex
    //   - normal is 0 0 0 --> beginning of new bounding volume
    if(n != null){
      vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
      // Test if triangle intersects ray.
      in_shadow = (rayTriangle(length(light - origin), ray, origin, a, b, c, n) != null);
    }else if(!rayCuboid(inv_ray, origin, vec3(a.x, a.z, b.y), vec3(a.y, b.x, b.z))){
      // Test if Ray intersects bounding volume.
      // a = x x2 y
      // b = y2 z z2
      vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
      // If it doesn't intersect, skip ahadow test for all elements in bounding volume.
      i += int(c.x);
    }
  }
  // Return if pixel is in shadow or not.
  return in_shadow;
}

vec3 forwardTrace(vec3 normal, vec3 color, vec3 ray, vec3 light, vec3 origin, vec3 position, float strength){
  // Calculate intensity of light reflection.
  float intensity = strength / (1.0 + length(light - position) / strength);
  // Process specularity of ray in view from origin's perspective.
  vec3 view = normalize(origin - position);
  vec3 halfVector = normalize(ray + view);
  float l = dot(normalize(vec3(- light.x - position.x, ray.y, - light.z + position.z)), normal);
  float specular = pow(dot(normal, halfVector), 50.0 * strength);
  // Determine final color and return it.
  vec3 l_color = color * l * intensity;
  if (specular > 0.0) l_color.rgb += specular * intensity;
  return l_color;
}

vec3 lightTrace(sampler2D world_tex, vec3 light, vec3 origin, vec3 position, vec3 normal, vec3 color, int bounces, float strength){
  // Use additive color mixing technique, so start with black.
  vec3 final_color = vec3(0.0, 0.0, 0.0);
  float importancy = 0.5;
  // Test if coordinate is in shadow.
  bool in_shadow = false;
  // Ray currently traced.
  vec3 active_ray = normalize(position - origin);
  // Ray from last_position to light source.
  vec3 last_origin = origin;
  // Triangle ray lastly intersected with is last_position.w.
  vec3 last_position = position;
  vec3 last_normal = normal;
  // Remember color of triangle ray intersected lastly.
  vec3 last_color = color;

  // Iterate over each bounce and modify color accordingly.
  for(int i = 0; i < bounces; i++){
    vec3 active_light_ray = normalize(light - last_position);
    // Assemble color.
    in_shadow = shadowTest(active_light_ray, light, last_position);
    // Update pixel color if coordinate is not in shadow.
    if(!in_shadow){
      final_color += forwardTrace(last_normal, last_color, active_light_ray, light, last_origin, last_position, strength)
      * pow(importancy, float(i));
    }
    // Calculate reflecting ray.
    active_ray = reflect(active_ray, last_normal);
    // Calculate next intersection.
    vec4 intersection = rayTracer(active_ray, last_position);
    // Stop loop if there is no intersection and ray goes in the void.
    if(intersection.xyz == null) break;
    //final_color = vec3(1.0, 0.0, 0.0);
    //break;
    // Update parameters.
    // Read triangle normal.
    last_origin = last_position;
    last_position = intersection.xyz;
    last_normal = texelFetch(world_tex, ivec2(4, int(intersection.w)), 0).xyz;
    last_color = texelFetch(world_tex, ivec2(3, int(intersection.w)), 0).xyz;
    // importancy *= 0.5;
  }
  // Return final pixel color.
  return final_color;
}

void main(){
  // Test if pixel is in shadow or not.
  if(clip_space.z < 0.0) return;
  // Start hybrid ray tracing per light source.
  outColor = vec4(lightTrace(world_tex, light, player * vec3(-1.0, 1.0, 1.0), position, normal, color.xyz, 5, 3.0), 1.0);
}
