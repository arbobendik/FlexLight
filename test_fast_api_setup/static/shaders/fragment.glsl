#version 300 es

precision highp float;
precision highp sampler2D;

in vec3 position;
in vec2 tex_coord;
in vec3 clip_space;

flat in vec4 color;
flat in vec3 normal;
flat in vec3 player;
flat in int vertex_id;
flat in vec2 texture_nums;
// Quality configurators.
uniform int samples;
uniform int reflections;
uniform int use_filter;
// Textures in parallel for texture atlas.
uniform int texture_width;
// Texture with information about all triangles in scene.
uniform sampler2D world_tex;
// Random texture to multiply with normal map to simulate rough surfaces.
uniform sampler2D random;

uniform sampler2D normal_tex;
uniform sampler2D tex;
// Texture with all primary light sources of scene.
uniform sampler2D light_tex;
// Get global illumination color, intensity.
uniform vec3 global_illumination;

layout(location = 0) out vec4 render_color;
layout(location = 1) out vec4 render_normal;
layout(location = 2) out vec4 render_original_color;
layout(location = 3) out vec4 render_id;

// Global constants.
// Declare null vector as constant.
const vec3 null = vec3(0.0, 0.0, 0.0);
const vec4 vec4_null = vec4(0.0, 0.0, 0.0, 0.0);
const float shadow_bias = 0.00001;

// Prevent blur over shadow border.
float first_in_shadow = 0.0;

// Lookup values for texture atlases.
vec4 lookup(sampler2D atlas, vec3 coords){
  float atlas_height_factor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) / float(texture_width);
  float atlas_width_factor = 1.0 / float(texture_width);
  vec2 atlas_coords = vec2(
    (coords.x + mod(coords.z, float(texture_width))) * atlas_width_factor,
    (coords.y + floor(coords.z / float(texture_width))) * atlas_height_factor
  );
  // Return texel on requested location.
  return texture(atlas, atlas_coords);
}

float triangleSurface(mat3 vertices){
  vec3 ab = vertices[1] - vertices[0];
  vec3 ac = vertices[2] - vertices[0];
  // Apply sarrus rule.
  vec3 sarrus = vec3(ab.x*ac.y - ab.y*ac.x, ab.z*ac.y - ab.y*ac.z, ab.x*ac.z - ab.z*ac.x);
  return 0.5 * length(sarrus);
}

// Test if ray intersects triangle and return intersection.
vec4 rayTriangle(float l, vec3 r, vec3 p, vec3 a, vec3 b, vec3 c, vec3 n){
  float dnr = dot(n, r);
  // Test if ray or surface face in same direction.
  if(sign(n) == sign(r)) return vec4_null;
  // Test if ray and plane are parallel.
  if(dnr == 0.0) return vec4_null;
  // Get distance to intersection point.
  float s = dot(n , a - p) / dnr;
  // Ensure that ray triangle intersection is between light source and texture.
  if(s > l || s <= 0.0) return vec4_null;
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
    return vec4(d, s);
  }else{
    return vec4_null;
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
  if (highest < 0.0) return false;
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
  // Which triangle (number) reflects ray.
  int target_triangle = -1;
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
    //  Two cases:
    //   - normal is not 0 0 0 --> normal vertex
    //   - normal is 0 0 0 --> beginning of new bounding volume
    if(n != null){
      vec3 c = texelFetch(world_tex, ivec2(2, i), 0).xyz;
      // Test if triangle intersects ray.
      vec4 current_intersection = rayTriangle(1000.0, ray, origin, a, b, c, n);
      // Test if ray even intersects.
      if(current_intersection == vec4_null) continue;
      // Test if this intersection is the closest.
      if(current_intersection.w < min_len || min_len == - 1.0){
        min_len = current_intersection.w;
        target_triangle = i;
        intersection = current_intersection.xyz;
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
      in_shadow = (rayTriangle(length(light - origin), ray, origin, a, b, c, n).xyz != null);
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
  float l = abs(dot(normalize(vec3(- light.x - position.x, ray.y, - light.z + position.z)), normal));
  float specular = pow(dot(normal, halfVector), 50.0 * strength);
  // Determine final color and return it.
  vec3 l_color = color * l * intensity;
  if (specular > 0.0) l_color.rgb += specular * intensity;
  return l_color;
}

float fresnel(vec3 normal, vec3 lightDir) {
  // Apply fresnel effect.
  return dot(normal, normalize(lightDir));
}

vec3 lightTrace(sampler2D world_tex, vec3 light, vec3 origin, vec3 position, int sample_n, vec3 rough_normal, vec3 normal, vec3 color, float roughness, int bounces, float strength){
  vec3 inv_light = light * vec3(-1.0, 1.0, 1.0);
  // Use additive color mixing technique, so start with black.
  vec3 final_color = null;
  vec3 importancy_factor = vec3(1.0, 1.0, 1.0);
  // Ray currently traced.
  vec3 active_ray = normalize(position - origin);
  // Ray from last_position to light source.
  vec3 last_origin = origin;
  // Triangle ray lastly intersected with is last_position.w.
  vec3 last_position = position;
  vec3 last_normal = normal;
  vec3 last_rough_normal = rough_normal;
  // Remember color of triangle ray intersected lastly.
  // Start with white instead of original triangle color to seperate raytracing from texture, combine both results in filter.
  vec3 last_color = color;
  float last_roughness = roughness;
  // Iterate over each bounce and modify color accordingly.
  for(int i = 0; i < bounces; i++){
    // Precalculate importancy_factor of this iteration.
    importancy_factor *= last_color;
    // Recalculate position -> light vector.
    vec3 active_light_ray = normalize(light - last_position);
    // Update pixel color if coordinate is not in shadow.
    if(!shadowTest(active_light_ray, light, last_position)){
      final_color += forwardTrace(last_rough_normal, last_color, active_light_ray, inv_light, last_origin, last_position, strength) * importancy_factor;
    }else if(i == 0){
      first_in_shadow += 1.0 / 256.0;
    }
    // Break out of the loop after color is calculated if i was the last iteration.
    if(i == bounces - 1) break;
    // Generate pseudo random vector.
    vec2 random_coord = mod(((clip_space.xy / clip_space.z) + 1.0) * (sin(float(i)) + cos(float(sample_n))), 1.0);
    vec3 random_vec = (texture(random, random_coord).xyz - 0.5) * 2.0;
    // Calculate reflecting ray.
    active_ray = normalize(random_vec * last_roughness + reflect(active_ray, last_normal) * (1.0 - last_roughness));
    if (dot(active_ray, last_normal) <= 0.0) active_ray = - active_ray;
    // Calculate next intersection.
    vec4 intersection = rayTracer(active_ray, last_position);
    // Stop loop if there is no intersection and ray goes in the void.
    if(intersection.xyz == null) break;
    // Calculate barycentric coordinates to map textures.
    // Read UVs of vertices.
    vec3 v_uvs_1 = texelFetch(world_tex, ivec2(6, int(intersection.w)), 0).xyz;
    vec3 v_uvs_2 = texelFetch(world_tex, ivec2(7, int(intersection.w)), 0).xyz;

    mat3x2 vertex_uvs = mat3x2(vec2(v_uvs_1.xy), vec2(v_uvs_1.z, v_uvs_2.x), vec2(v_uvs_2.yz));
    // Get vertices of triangle.
    mat3 vertices = mat3(
      texelFetch(world_tex, ivec2(0, int(intersection.w)), 0).xyz,
      texelFetch(world_tex, ivec2(1, int(intersection.w)), 0).xyz,
      texelFetch(world_tex, ivec2(2, int(intersection.w)), 0).xyz
    );
    // Calculate sub surfaces of triangles.
    vec3 sub_surfaces = vec3(
      triangleSurface(mat3(intersection.xyz, vertices[1], vertices[2])),
      triangleSurface(mat3(intersection.xyz, vertices[2], vertices[0])),
      triangleSurface(mat3(intersection.xyz, vertices[0], vertices[1]))
    );

    float surface_sum = sub_surfaces.x + sub_surfaces.y + sub_surfaces.z;
    sub_surfaces = sub_surfaces / surface_sum;
    // Interpolate final barycentric coordinates.
    vec2 barycentric = vertex_uvs * sub_surfaces;
    // Read triangle normal.
    vec2 tex_nums = texelFetch(world_tex, ivec2(5, int(intersection.w)), 0).xy;
    // Default last_color to color of target triangle.
    last_color = texelFetch(world_tex, ivec2(3, int(intersection.w)), 0).xyz;
    // Multiply with texture value if available.
    if(tex_nums.x != -1.0) last_color *= lookup(tex, vec3(barycentric, tex_nums.x)).xyz;
    // Default last_roughness to 0.5.
    last_roughness = 0.5;
    // Use roughness from texture if available.
    if(tex_nums.y != -1.0) last_roughness = lookup(normal_tex, vec3(barycentric, tex_nums.y)).x;
    // Update parameters.
    last_origin = last_position;
    last_position = intersection.xyz;
    last_normal = normalize(texelFetch(world_tex, ivec2(4, int(intersection.w)), 0).xyz);
    // Fresnel effect.
    last_roughness *= fresnel(last_normal, last_origin - last_position);
    last_rough_normal = normalize(random_vec * last_roughness + last_normal * (1.0 - last_roughness));
  }
  // Apply global illumination.
  final_color += global_illumination * importancy_factor;
  // Return final pixel color.
  return final_color;
}

void main(){
  // Test if pixel is in frustum or not.
  if(clip_space.z < 0.0) return;
  // Alter normal and color according to texture and normal texture.
  // Test if textures are even set otherwise default to 0.5 / color.
  // Default tex_color to color.
  vec4 tex_color = color;
  // Multiply with texture value if texture is defined.
  if(texture_nums.x != -1.0) tex_color *= lookup(tex, vec3(tex_coord, texture_nums.x));
  // Default roughness to 0.5.
  float roughness = 0.5;
  // Set roughness to texture value if texture is defined.
  if(texture_nums.y != -1.0) roughness = lookup(normal_tex, vec3(tex_coord, texture_nums.y)).x;
  // Fresnel effect.
  roughness *= fresnel(normal, player - position);
  // Start hybrid ray tracing on a per light source base.
  vec3 final_color = null;
  vec3 random_vec = null;
  // Addapt outer loop iterations depending on how many light sources there are.
  int samples = samples;
  // Generate multiple samples.
  for(int i = 0; i < samples; i++){
    for (int j = 0; j < textureSize(light_tex, 0).y; j++){
      if(mod(float(i), 2.0) == 0.0){
        vec2 random_coord = mod(((clip_space.xy / clip_space.z) + 1.0) * float(i/2 + 1), 1.0);
        random_vec = (texture(random, random_coord).xyz - 0.5) * 2.0;
      }else{
        // Invert vector every second sample instead of getting a new one.
        // --> smoother image.
        random_vec = - random_vec;
      }
      // Alter normal and color according to texture and normal texture.
      vec3 rough_normal = normalize(random_vec * roughness + normal * (1.0 - roughness));
      // Read light position.
      vec3 light = texture(light_tex, vec2(0.0, float(j))).xyz;
      // Read light strength from texture.
      float strength = texture(light_tex, vec2(1.0, float(j))).x;
      // Calculate pixel for specific normal.
      final_color += lightTrace(world_tex, light, player, position, i, rough_normal, normal, tex_color.xyz, roughness, reflections, strength);
    }
  }
  // Improved precision for render_color.
  // Build render_color with improved precision that value can be larger than 1.
  vec3 render_color_ip = vec3(final_color / float(samples) / 255.0);

  // Render all relevant information to 4 textures for the post processing shader.
  if(use_filter == 1){
    render_color = vec4(final_color / float(samples), first_in_shadow + 1.0 / 256.0);
  }else{
    render_color = vec4(final_color / float(samples), 1.0);
  }
  // Render all relevant information to 4 textures for the post processing shader.
  render_color = vec4(final_color / float(samples), 1.0);
  render_normal = vec4(normal, first_in_shadow);
  render_original_color = vec4(tex_color.xyz, roughness);
  render_id = vec4(1.0 / vec3(float((vertex_id/3)%16777216), float((vertex_id/3)%65536), float((vertex_id/3)%256)), 0.0);
}
