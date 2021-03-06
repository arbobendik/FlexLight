'use strict';

export class RayTracer {
  type = 'raytracer';
  // Configurable runtime properties of the raytracer (public attributes)
  // Quality settings
  samplesPerRay = 1;
  renderQuality = 1;
  maxReflections = 3;
  minImportancy = 0.3;
  firstPasses = 0;
  secondPasses = 0;
  filter = true;
  antialiasing = true;
  hdr = true;
  // Performance metric
  fps = 0;

  halt = () => this.#halt = true;
  #halt = false;
  // Make gl object inaccessible from outside the class
  #gl;
  #canvas;
  // Internal gl texture variables of texture atlases
  #worldTexture = null;
  #pbrTexture = null;
  #translucencyTexture = null;
  #texture = null;
  #lightTexture = null;
  // Shader sources in glsl 3.0.0 es
  #vertexGlsl = `#version 300 es
  precision highp float;
  in vec3 position_3d;
  in vec4 id;
  in vec2 tex_pos;
  uniform vec3 camera_position;
  uniform vec2 perspective;
  uniform vec4 conf;
  out vec3 position;
  out vec2 tex_coord;
  out vec3 clip_space;
  flat out vec4 vertex_id;
  flat out vec3 player;
  void main(){
    vec3 move_3d = position_3d + vec3(camera_position.x, - camera_position.yz);
    vec2 translate_px = vec2(
      move_3d.x * cos(perspective.x) + move_3d.z * sin(perspective.x),
      move_3d.z * cos(perspective.x) - move_3d.x * sin(perspective.x)
    );
    vec2 translate_py = vec2(
      move_3d.y * cos(perspective.y) + translate_px.y * sin(perspective.y),
      translate_px.y * cos(perspective.y) - move_3d.y * sin(perspective.y)
    );
    vec2 translate_2d = conf.x * vec2(translate_px.x / conf.y, translate_py.x);
    // Set final clip space position
    gl_Position = vec4(translate_2d, - 1.0 / (1.0 + exp(- length(move_3d / 1048576.0))), translate_py.y);
    position = position_3d;
    tex_coord = tex_pos;
    clip_space = vec3(translate_2d, translate_py.y);
    vertex_id = id;
    player = camera_position * vec3(-1.0, 1.0, 1.0);
  }
  `;
  #fragmentGlsl = `#version 300 es
  #define SQRT3 1.7320508075688772
  #define BIAS 0.0000152587890625
  #define TrianglesPerRow 256
  precision highp float;
  precision highp sampler2D;
  in vec3 position;
  in vec2 tex_coord;
  in vec3 clip_space;
  flat in vec4 vertex_id;
  flat in vec3 player;
  // Quality configurators
  uniform int samples;
  uniform int max_reflections;
  uniform float min_importancy;
  uniform int use_filter;
  // Get global illumination color, intensity
  uniform vec3 ambient;
  // Textures in parallel for texture atlas
  uniform int texture_width;
  // Texture with information about all triangles in scene
  uniform sampler2D world_tex;
  // Random texture to multiply with normal map to simulate rough surfaces
  uniform sampler2D random;
  uniform sampler2D translucency_tex;
  uniform sampler2D pbr_tex;
  uniform sampler2D tex;
  // Texture with all primary light sources of scene
  uniform sampler2D light_tex;
  layout(location = 0) out vec4 render_color;
  layout(location = 1) out vec4 render_color_ip;
  layout(location = 2) out vec4 render_original_color;
  layout(location = 3) out vec4 render_id;
  layout(location = 4) out vec4 render_original_id;
  // Prevent blur over shadow border or over (close to) perfect reflections
  float first_ray_length = 1.0;
  // Accumulate color of mirror reflections
  float glass_filter = 0.0;
  float original_rmex = 0.0;
  float original_tpox = 0.0;
  vec3 original_color = vec3(1.0);
  // Lookup values for texture atlases
  vec4 lookup(sampler2D atlas, vec3 coords){
    float atlas_height_factor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) / float(texture_width);
    float atlas_width_factor = 1.0 / float(texture_width);
    vec2 atlas_coords = vec2(
      (coords.x + mod(coords.z, float(texture_width))) * atlas_width_factor,
      (coords.y + floor(coords.z / float(texture_width))) * atlas_height_factor
    );
    // Return texel on requested location
    return texture(atlas, atlas_coords);
  }
  // Test if ray intersects triangle and return intersection
  mat2x4 rayTriangle(float l, vec3 r, vec3 p, mat3 t, vec3 n, vec3 on){
    // Can't intersect with triangle with the same normal as the origin
    if (n == on) return mat2x4(0);
    // Get distance to intersection point
    float s = dot(n, t[0] - p) / dot(n, r);
    // Ensure that ray triangle intersection is between light source and texture
    if (s > l || s <= BIAS) return mat2x4(0);
    // Calculate intersection point
    vec3 d = (s * r) + p;
    // Test if point on plane is in Triangle by looking for each edge if point is in or outside
    vec3 v0 = t[1] - t[0];
    vec3 v1 = t[2] - t[0];
    vec3 v2 = d - t[0];
    float d00 = dot(v0, v0);
    float d01 = dot(v0, v1);
    float d11 = dot(v1, v1);
    float d20 = dot(v2, v0);
    float d21 = dot(v2, v1);
    float denom = d00 * d11 - d01 * d01;
    float v = (d11 * d20 - d01 * d21) / denom;
    float w = (d00 * d21 - d01 * d20) / denom;
    float u =  1.0 - v - w;
    if (min(u, v) <= BIAS || u + v >= 1.0 - BIAS) return mat2x4(0);
    // Return uvw and intersection point on triangle.
    return mat2x4(vec4(d, s), vec4(u, v, w, 0));
  }
  // Don't return intersection point, because we're looking for a specific triangle
  bool rayCuboid(vec3 inv_ray, vec3 p, vec3 min_corner, vec3 max_corner) {
    mat2x3 v = matrixCompMult(mat2x3(min_corner, max_corner) - mat2x3(p, p), mat2x3(inv_ray, inv_ray));
    // vec2 v1 = (vec2(min_corner.x, max_corner.x) - p.x) * inv_ray.x;
    // vec2 v2 = (vec2(min_corner.y, max_corner.y) - p.y) * inv_ray.y;
    // vec2 v3 = (vec2(min_corner.z, max_corner.z) - p.z) * inv_ray.z;
    float lowest = max(max(min(v[0].x, v[1].x), min(v[0].y, v[1].y)), min(v[0].z, v[1].z));
    float highest = min(min(max(v[0].x, v[1].x), max(v[0].y, v[1].y)), max(v[0].z, v[1].z));
    // Cuboid is behind ray
    // Ray points in cuboid direction, but doesn't intersect
    return max(lowest, BIAS) <= highest;
  }
  // Test for closest ray triangle intersection
  // Return intersection position in world space (rayTracer.xyz)
  // Return index of target triangle in world_tex (rayTracer.w)
  mat2x4 rayTracer(vec3 ray, vec3 origin, vec3 origin_normal){
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 inv_ray = 1.0 / ray;
    // Latest intersection which is now closest to origin
    mat2x4 intersection = mat2x4(vec4(0), vec4(vec3(0), -1));
    // Length to latest intersection
    float min_len = 1.0 / 0.0;
    // Get texture size as max iteration value
    int size = textureSize(world_tex, 0).y * TrianglesPerRow;
    // Iterate through lines of texture
    for (int i = 0; i < size; i++){
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(float(i), float(TrianglesPerRow)) * 8.0, i / TrianglesPerRow);
      // Read triangle and normal from world tex
      vec3 n = texelFetch(world_tex, index + ivec2(4, 0), 0).xyz;
      mat3 t = mat3(
        texelFetch(world_tex, index, 0).xyz,
        texelFetch(world_tex, index + ivec2(1, 0), 0).xyz,
        texelFetch(world_tex, index + ivec2(2, 0), 0).xyz
      );
      // Fetch triangle coordinates from world texture
      //  Two cases:
      //   - normal is not 0 0 0 --> normal vertex
      //   - normal is 0 0 0 --> beginning of new bounding volume
      if (n != vec3(0)){
        // Test if triangle intersects ray
        mat2x4 current_intersection = rayTriangle(min_len, ray, origin, t, n, origin_normal);
        // Test if ray even intersects
        if (current_intersection != mat2x4(0)){
          min_len = current_intersection[0].w;
          intersection = current_intersection;
          intersection[1].w = float(i);
        }
      } else if (t == mat3(0)) {
        // Break if all values are zero and texture already ended
        break;
      } else if (!rayCuboid(inv_ray, origin, vec3(t[0].x, t[0].z, t[1].y), vec3(t[0].y, t[1].x, t[1].z))){
        // Test if Ray intersects bounding volume
        // t[0] = x x2 y
        // t[1] = y2 z z2
        // If it doesn't intersect, skip shadow test for all elements in bounding volume
        i += int(t[2].x);
      }
    }
    // Return if pixel is in shadow or not
    return intersection;
  }
  // Simplified rayTracer test only if ray intersects anything
  bool shadowTest(vec3 ray, vec3 light, vec3 origin, vec3 origin_normal){
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 inv_ray = 1.0 / ray;
    // Get texture size as max iteration value
    int size = textureSize(world_tex, 0).y * TrianglesPerRow;
    // Iterate through lines of texture
    for (int i = 0; i < size; i++){
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(float(i), float(TrianglesPerRow)) * 8.0, i / TrianglesPerRow);
      // Read normal and triangle from world_tex
      vec3 n = texelFetch(world_tex, index + ivec2(4, 0), 0).xyz;
      // Fetch triangle coordinates from world texture
      mat3 t = mat3(
        texelFetch(world_tex, index, 0).xyz,
        texelFetch(world_tex, index + ivec2(1, 0), 0).xyz,
        texelFetch(world_tex, index + ivec2(2, 0), 0).xyz
      );
      //  Three cases:
      //   - normal is not 0 0 0 --> normal vertex
      //   - normal is 0 0 0 --> beginning of new bounding volume
      if (n != vec3(0)) {
        // Test if triangle intersects ray and return true if there is shadow
        if (rayTriangle(length(light - origin), ray, origin, t, n, origin_normal)[0].xyz != vec3(0)) return true;
      } else if (t == mat3(0)) {
        // Break if all values are zero and texture already ended
        break;
      } else if (!rayCuboid(inv_ray, origin, vec3(t[0].x, t[0].z, t[1].y), vec3(t[0].y, t[1].x, t[1].z))){
        // Test if Ray intersects bounding volume
        // t[0] = x x2 y
        // t[1] = y2 z z2
        // If it doesn't intersect, skip shadow test for all elements in bounding volume
        i += int(t[2].x);
      }
    }
    // Tested all triangles, but there is no intersection
    return false;
  }
  float forwardTrace(vec3 normal, vec3 light_ray, vec3 origin, vec3 position, float metallicity, float strength){
    // Calculate intensity of light reflection, which decreases squared over distance
    float intensity = strength / pow(1.0 + length(light_ray),2.0);
    // Process specularity of ray in view from origin's perspective
    vec3 halfVector = normalize(normalize(light_ray) + normalize(origin - position));
    float light = abs(dot(normalize(light_ray), normal)) * (1.0 - metallicity);
    float specular = pow(abs(dot(normal, halfVector)), 300.0 / intensity) * 8.0 * metallicity;
    // Determine final color and return it
    if (dot(normal, halfVector) > 0.0) return light * intensity + specular * intensity;
    // Return just light if specular is negative
    return light * intensity;
  }
  float fresnel(vec3 normal, vec3 lightDir) {
    // Apply fresnel effect
    return dot(normal, lightDir);
  }
  vec3 lightTrace(sampler2D world_tex, sampler2D light_tex, vec3 origin, vec3 position, vec3 normal, vec3 rme, vec3 tpo, int sample_n, int bounces){
    // Set bool to false when filter becomes necessary
    bool dont_filter = true;
    float last_filter_roughness = 0.0;
    float last_id = 0.0;
    // Use additive color mixing technique, so start with black
    vec3 final_color = vec3(0);
    vec3 importancy_factor = vec3(1);
    // Ray currently traced
    vec3 active_ray = normalize(position - origin);
    // Ray from last_position to light source
    vec3 last_origin = origin;
    // Triangle ray lastly intersected with is last_position.w
    vec3 last_position = position;
    vec3 last_normal = normal;
    // Remember color of triangle ray intersected lastly
    // Start with white instead of original triangle color to seperate raytracing from texture, combine both results in filter
    vec3 last_color = vec3(1);
    // Pack roughness, metallicity and emissiveness in one vector for simplicity
    vec3 last_rme = rme;
    // Pack all translucency related values in one vector
    vec3 last_tpo = tpo;
    // Iterate over each bounce and modify color accordingly
    for (int i = 0; i < bounces && length(importancy_factor) >= min_importancy * SQRT3; i++){
      // (a multiplicator vec3, that indicates how much the calculated values influence the final_color)
      importancy_factor *= last_color;
      // Apply emissive texture and ambient light
      final_color = (ambient * 0.25 + last_rme.z) * importancy_factor + final_color;
      // Generate pseudo random vector
      vec2 random_coord = mod((clip_space.xy / clip_space.z) + (sin(float(i)) + cos(float(sample_n))), 1.0);
      vec3 random_vec = texture(random, random_coord).xyz * 2.0 - 1.0;
      // Alter normal according to roughness value
      vec3 last_rough_normal = normalize(mix(last_normal, random_vec, last_rme.x));
      // Fix for Windows devices, invert last_rough_normal if it points under the surface.
      if (dot(last_rough_normal, last_normal) <= 0.0) last_rough_normal = - last_rough_normal;
      // Handle fresnel reflection
      float fresnel_reflect = abs(fresnel(last_normal, active_ray));
      // object is solid or translucent by chance because of the fresnel effect
      bool is_solid = last_tpo.x * fresnel_reflect <= abs(random_vec.x);
      // Test if filter is already necessary
      if (dont_filter && i != 0) {
        // Set color in filter
        if (sample_n == 0) original_color *= last_color;
        last_color = vec3(1.0);
        // Add filtering intensity for respective surface
        original_rmex += last_filter_roughness;
        // Update render id
        render_id += pow(2.0, - float(i + 0)) * vec4(last_id/65535.0, last_id/255.0, (last_filter_roughness * 2.0 + last_rme.y) / 3.0, 0.0);
        original_tpox += 1.0;
      }
      // Update dont_filter variable
      dont_filter = (dont_filter && (
        (last_rme.x < 0.01 && is_solid)
        || !is_solid
        ));
      // Intersection of ray with triangle
      mat2x4 intersection;
      // Handle translucency and skip rest of light calculation
      if (is_solid) {
        if (dont_filter && last_tpo.x > 0.5) {
          glass_filter = 1.0;
          dont_filter = false;
        }
        // If ray fresnel reflects from inside an transparent object,
        // the surface faces in the opposite direction as usual
        if (dot(active_ray, last_normal) > 0.0) last_normal = - last_normal;
        //  Calculate primary light sources for this pass if ray hits non translucent object
        for (int j = 0; j < textureSize(light_tex, 0).y; j++){
          // Read light position
          vec3 light = texelFetch(light_tex, ivec2(0, j), 0).xyz * vec3(-1.0, 1.0, 1.0);
          // Read light strength from texture
          float strength = texelFetch(light_tex, ivec2(1, j), 0).x;
          float variation = texelFetch(light_tex, ivec2(1, j), 0).y;
          // Alter light source position according to variation.
          light = random_vec * variation + light;
          // Skip if strength is negative or zero
          if (strength <= 0.0) continue;
          // Recalculate position -> light vector
          vec3 active_light_ray = light * vec3(-1.0, 1.0, 1.0) - last_position;
          // Update pixel color if coordinate is not in shadow
          if (!shadowTest(normalize(active_light_ray), light, last_position, last_normal)) {
            final_color += forwardTrace(last_rough_normal, active_light_ray, last_origin, last_position, last_rme.y, strength) * importancy_factor;
          } else if (dont_filter || i == 0) {
            render_id.w += pow(2.0, - float(i + 2));
          }
        }
        // Break out of the loop after color is calculated if i was the last iteration
        if (i == bounces - 1) break;
        // Calculate reflecting ray
        active_ray = normalize(mix(reflect(active_ray, last_normal), random_vec, last_rme.x));
        if (dot(active_ray, last_normal) <= 0.0) active_ray = - active_ray;
        // Calculate next intersection
        intersection = rayTracer(active_ray, last_position, last_normal);
        // Stop loop if there is no intersection and ray goes in the void
        if (intersection[0] == vec4(0)) break;
      } else {
        // Break out of the loop after color is calculated if i was the last iteration
        if (i == bounces - 1) break;
        float ratio = last_tpo.z * 4.0;
        if (dot(active_ray, last_normal) <= 0.0){
          active_ray = normalize(active_ray + 1.0 * refract(active_ray, last_normal, 1.0 / ratio));
        }else{
          active_ray = normalize(active_ray + 1.0 * refract(active_ray, - last_normal, ratio));
        }
        // Calculate next intersection
        intersection = rayTracer(active_ray, last_position, last_normal);
        last_origin = 2.0 * last_position - last_origin;
        for (int j = 0; j < textureSize(light_tex, 0).y; j++){
          // Read light position
          vec3 light = texelFetch(light_tex, ivec2(0, j), 0).xyz * vec3(-1.0, 1.0, 1.0);
          // Read light strength from texture
          float strength = texelFetch(light_tex, ivec2(1, j), 0).x;
          float variation = texelFetch(light_tex, ivec2(1, j), 0).y;
          // Alter light source position according to variation.
          light += random_vec * variation;
          // Skip if strength is negative or zero
          if (strength <= 0.0) continue;
          // Recalculate position -> light vector
          vec3 active_light_ray = light * vec3(-1.0, 1.0, 1.0) - last_position;
          // Update pixel color if coordinate is not in shadow
          if (!shadowTest(normalize(active_light_ray), light, last_position, last_normal)){
            final_color += forwardTrace(last_rough_normal, active_light_ray, last_origin, last_position, last_rme.y, strength) * importancy_factor * (1.0 - fresnel_reflect);
          } else if (dont_filter || i == 0) {
            render_id.w += pow(3.0, - float(i + 1));
          }
        }
      }
      // Stop loop if there is no intersection and ray goes in the void
      if (intersection[0] == vec4(0)) break;
      // Update last used tpo.x value
      if(dont_filter) original_tpox = last_tpo.x;
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(intersection[1].w, float(TrianglesPerRow)) * 8.0, intersection[1].w / float(TrianglesPerRow));
      // Calculate barycentric coordinates to map textures
      // Read UVs of vertices
      vec3 v_uvs_1 = texelFetch(world_tex, index + ivec2(6, 0), 0).xyz;
      vec3 v_uvs_2 = texelFetch(world_tex, index + ivec2(7, 0), 0).xyz;
      mat3x2 vertex_uvs = mat3x2(vec2(v_uvs_1.xy), vec2(v_uvs_1.z, v_uvs_2.x), vec2(v_uvs_2.yz));
      // Interpolate final barycentric coordinates
      vec2 barycentric = vertex_uvs * intersection[1].xyz;
      // Read triangle normal
      vec3 tex_nums = texelFetch(world_tex, index + ivec2(5, 0), 0).xyz;
      // Default last_color to color of target triangle
      // Multiply with texture value if available
      last_color = mix(texelFetch(world_tex, index + ivec2(3, 0), 0).xyz, lookup(tex, vec3(barycentric, tex_nums.x)).xyz, sign(tex_nums.x + 1.0));
      // Default roughness, metallicity and emissiveness
      // Set roughness to texture value if texture is defined
      last_rme = mix(vec3(0.5, 0.5, 0.0), lookup(pbr_tex, vec3(barycentric, tex_nums.y)).xyz * vec3(1.0, 1.0, 4.0), sign(tex_nums.y + 1.0));
      // Update tpo for next pass
      last_tpo = mix(vec3(0.0, 1.0, 0.25), lookup(translucency_tex, vec3(barycentric, tex_nums.z)).xyz, sign(tex_nums.z + 1.0));
      // Update other parameters
      last_id = intersection[1].w;
      last_origin = last_position;
      last_position = intersection[0].xyz;
      last_normal = normalize(texelFetch(world_tex, index + ivec2(4, 0), 0).xyz);
      // Preserve original roughness for filter pass
      last_filter_roughness = last_rme.x;
      // Fresnel effect
      last_rme.x *= mix(1.0, fresnel(last_normal, last_origin - last_position), last_rme.y);
      if (i==0) first_ray_length = min(length(last_position - last_origin) / length(position - origin), 1.0);
    }
    // Return final pixel color
    return final_color;
  }
  void main(){
    float id = vertex_id.x * 65535.0 + vertex_id.y;
    ivec2 index = ivec2(mod(id, float(TrianglesPerRow)) * 8.0, id / float(TrianglesPerRow));
    // Read base attributes from world texture.
    vec3 color = texelFetch(world_tex, index + ivec2(3, 0), 0).xyz;
    vec3 normal = normalize(texelFetch(world_tex, index + ivec2(4, 0), 0).xyz);
    vec3 texture_nums = texelFetch(world_tex, index + ivec2(5, 0), 0).xyz;
    // Test if pixel is in frustum or not
    if (clip_space.z < 0.0) return;
    // Alter normal and color according to texture and normal texture
    // Test if textures are even set otherwise use defaults.
    // Default tex_color to color
    vec3 tex_color = mix(color, lookup(tex, vec3(tex_coord, texture_nums.x)).xyz, sign(texture_nums.x + 1.0));
    // Default roughness, metallicity and emissiveness
    // Set roughness to texture value if texture is defined
    vec3 rme = mix(vec3(0.5, 0.5, 0.0), lookup(pbr_tex, vec3(tex_coord, texture_nums.y)).xyz * vec3(1.0, 1.0, 4.0), sign(texture_nums.y + 1.0));
    // Default to non translucent object (translucency, particle density, optical density) => tpo
    vec3 tpo = mix(vec3(0.0, 1.0, 0.25), lookup(translucency_tex, vec3(tex_coord, texture_nums.z)).xyz, sign(texture_nums.z + 1.0));
    original_tpox = tpo.x;
    // Preserve original roughness for filter pass
    float filter_roughness = rme.x;
    // Fresnel effect
    rme.x = rme.x * mix(1.0, fresnel(normal, player - position), rme.y);
    // Start hybrid ray tracing on a per light source base
    // Directly add emissive light of original surface to final_color
    vec3 final_color = vec3(0);
    // Generate multiple samples
    for (int i = 0; i < samples; i++){
      // Set color of object itself
      // Calculate pixel for specific normal
      final_color += lightTrace(world_tex, light_tex, player, position, normal, rme, tpo, i, max_reflections);
    }
    // Average ray colors over samples.
    final_color /= float(samples);
    // Render all relevant information to 4 textures for the post processing shader
    if (use_filter == 0) {
      render_color = vec4((final_color) * tex_color.xyz, 1.0);
      return;
    }
    render_color = vec4(mod(final_color, 1.0), 1.0);
    // 16 bit HDR for improved filtering
    render_color_ip = vec4(floor(final_color) / 255.0, glass_filter);
    render_original_color = vec4(tex_color.xyz * original_color, (rme.x + original_rmex + 0.0625 * tpo.x) * (first_ray_length + 0.06125));
		render_id += vec4(vertex_id.zw, (filter_roughness * 2.0 + rme.y) / 6.0, 0.0);
    render_original_id = vec4(vertex_id.zw, (filter_roughness * 2.0 + rme.y) / 6.0, original_tpox);
  }
  `;
  #postProcessGlsl = `#version 300 es
  in vec2 position_2d;
  // Pass clip space position to fragment shader
  out vec2 clip_space;
  void main() {
    vec2 pos = position_2d * 2.0 - 1.0;
    // Set final clip space position
    gl_Position = vec4(pos, 0, 1);
    clip_space = position_2d;
  }
  `;
  #firstFilterGlsl = `#version 300 es
  precision highp float;
  in vec2 clip_space;
  uniform sampler2D pre_render_color;
  uniform sampler2D pre_render_color_ip;
  uniform sampler2D pre_render_normal;
  uniform sampler2D pre_render_original_color;
  uniform sampler2D pre_render_id;
  uniform sampler2D pre_render_original_id;
  layout(location = 0) out vec4 render_color;
  layout(location = 1) out vec4 render_color_ip;
  layout(location = 2) out vec4 render_id;
  void main() {
    // Get texture size
    ivec2 texel = ivec2(vec2(textureSize(pre_render_color, 0)) * clip_space);
    vec4 center_color = texelFetch(pre_render_color, texel, 0);
    vec4 center_color_ip = texelFetch(pre_render_color_ip, texel, 0);
    vec4 center_o_color = texelFetch(pre_render_original_color, texel, 0);
    vec4 center_id = texelFetch(pre_render_id, texel, 0);
    render_id = center_id;
    vec4 center_o_id = texelFetch(pre_render_original_id, texel, 0);
    vec4 color = vec4(0);
    float count = 0.0;
    int diameter = int(sqrt(float(textureSize(pre_render_color, 0).x * textureSize(pre_render_color, 0).y) * center_o_color.w));
    
    if (center_color_ip.w > 0.0) {
      mat4 ids = mat4(0);
      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          ivec2 coords = texel + ivec2(vec2(i, j) - 2.0);
          vec4 id = texelFetch(pre_render_id, coords, 0);
          vec4 next_color_ip = texelFetch(pre_render_color_ip, coords, 0);
          if (next_color_ip.w <= 0.0) {
            for (int k = 0; k < 3; k++) {
              if (ids[k] == vec4(0.0)) {
                ids[k] = id;
                ids[3][k]++;
                break;
              } else if (ids[k] == id) {
                ids[3][k]++;
                break;
              }
            }
          }
        }
      }
      int id_number = 0;
      for (int i = 0; i < 3; i++) {
        if (ids[3][i] > ids[3][id_number]) id_number = i;
      }
      if (ids[3][id_number] > 1.0) {
        render_id = ids[id_number];
        center_color_ip.w = 0.0;
      }
    }
    
    // Force max radius
    if (diameter > 3) diameter = 3;
    if (diameter != 0) {
      // Apply blur filter on image
      for (int i = 0; i < diameter; i++) {
        for (int j = 0; j < diameter; j++) {
          ivec2 coords = texel + ivec2((vec2(i, j) - floor(0.5 * float(diameter))) * pow(1.0 + center_o_color.w, 2.0) * float(i + j + diameter));
          vec4 id = texelFetch(pre_render_id, coords, 0);
          vec4 next_color = texelFetch(pre_render_color, coords, 0);
          vec4 next_color_ip = texelFetch(pre_render_color_ip, coords, 0);
          if (id == center_id) {
            color += next_color + next_color_ip * 255.0;
            count ++;
          }
        }
      }
    } else {
      count = 1.0;
      color = center_color + center_color_ip * 255.0;
    }
    if (center_color.w > 0.0) {
      render_color = vec4(mod(color.xyz / count, 1.0), 1.0);
      // Set out color for render texture for the antialiasing filter
      render_color_ip = vec4(floor(color.xyz / count) / 255.0, center_color_ip.w);
    } else {
      render_color = vec4(0);
      render_color_ip = vec4(0);
    }
  }
  `;
  #secondFilterGlsl = `#version 300 es
  precision highp float;
  in vec2 clip_space;
  uniform sampler2D pre_render_color;
  uniform sampler2D pre_render_color_ip;
  uniform sampler2D pre_render_original_color;
  uniform sampler2D pre_render_id;
  uniform sampler2D pre_render_original_id;
  layout(location = 0) out vec4 render_color;
  layout(location = 1) out vec4 render_color_ip;
  layout(location = 2) out vec4 render_original_color;
  void main(){
    // Get texture size
    ivec2 texel = ivec2(vec2(textureSize(pre_render_color, 0)) * clip_space);
    vec4 center_color = texelFetch(pre_render_color, texel, 0);
    vec4 center_color_ip = texelFetch(pre_render_color_ip, texel, 0);
    vec4 center_o_color = texelFetch(pre_render_original_color, texel, 0);
    vec4 center_id = texelFetch(pre_render_id, texel, 0);
    vec4 center_o_id = texelFetch(pre_render_original_id, texel, 0);
    vec4 color = vec4(0);
    vec4 o_color = vec4(0);
    float ipw = 0.0;
    float count = 0.0;
    float o_count = 0.0;
    float radius = floor(sqrt(float(textureSize(pre_render_color, 0).x * textureSize(pre_render_color, 0).y) * center_o_color.w));
    // Force max radius
    if (radius > 2.0) radius = 2.0;
    int diameter = 2 * int(radius) + 1;
    if (diameter != 1) {
      // Apply blur filter on image
      for (int i = 0; i < diameter; i++) {
        for (int j = 0; j < diameter; j++) {
          vec2 texel_offset = vec2(i, j) - radius;
          if (length(texel_offset) >= radius) continue;
          ivec2 coords = ivec2(vec2(texel) + texel_offset * 2.0);
          vec4 id = texelFetch(pre_render_id, coords, 0);
          vec4 next_o_id = texelFetch(pre_render_original_id, coords, 0);
          vec4 next_color = texelFetch(pre_render_color, coords, 0);
          vec4 next_color_ip = texelFetch(pre_render_color_ip, coords, 0);
          vec4 next_o_color = texelFetch(pre_render_original_color, coords, 0);
          if (min(center_o_id.w, next_o_id.w) > 0.0 && (
            (max(next_color_ip.w, center_color_ip.w) > 0.5 && center_o_id.xyz == next_o_id.xyz) || id == center_id)) {
            color += next_color + next_color_ip * 255.0;
            count ++;
            ipw += next_color_ip.w;
            o_color += next_o_color;
            o_count++;
          } else if (id.xyz == center_id.xyz) {
            color += next_color + next_color_ip * 255.0;
            count ++;
          }
        }
      }
    } else {
      count = 1.0;
      o_count = 1.0;
      color = center_color + center_color_ip * 255.0;  
      o_color = center_o_color;
      ipw = center_color_ip.w;
    }
    if (center_color.w > 0.0) {
      render_color = vec4(mod(color.xyz / count, 1.0), 1.0);
      // Set out color for render texture for the antialiasing filter
      render_color_ip = vec4(floor(color.xyz / count) / 255.0, ipw);
      if (o_count == 0.0) {
        render_original_color = center_o_color;
      } else {
        // render_original_color = center_o_color;
        render_original_color = o_color / o_count;
      } 
    } else {
      render_color = vec4(0.0);
      render_color_ip = vec4(0.0);
      render_original_color = vec4(0.0);
    }
  }
  `;
  #finalFilterGlsl = `#version 300 es
  precision highp float;
  in vec2 clip_space;
  uniform sampler2D pre_render_color;
  uniform sampler2D pre_render_color_ip;
  uniform sampler2D pre_render_original_color;
  uniform sampler2D pre_render_id;
  uniform sampler2D pre_render_original_id;
  uniform int hdr;
  out vec4 out_color;
  void main(){
    // Get texture size
    ivec2 texel = ivec2(vec2(textureSize(pre_render_color, 0)) * clip_space);
    vec4 center_color = texelFetch(pre_render_color, texel, 0);
    vec4 center_color_ip = texelFetch(pre_render_color_ip, texel, 0);
    vec4 center_o_color = texelFetch(pre_render_original_color, texel, 0);
    vec4 center_id = texelFetch(pre_render_id, texel, 0);
    vec4 center_o_id = texelFetch(pre_render_original_id, texel, 0);
    vec4 color = vec4(0);
    vec4 o_color = vec4(0);
    float count = 0.0;
    float o_count = 0.0;
    float radius = ceil(sqrt(float(textureSize(pre_render_color, 0).x * textureSize(pre_render_color, 0).y) * center_o_color.w));
    // Force max radius
    if (radius > 3.0) radius = 3.0;
    int diameter = 2 * int(radius) + 1;
    if (diameter != 1) {
      // Apply blur filter on image
      for (int i = 0; i < diameter; i++) {
        for (int j = 0; j < diameter; j++) {
          vec2 texel_offset = vec2(i, j) - radius;
          if (length(texel_offset) >= radius) continue;
          ivec2 coords = ivec2(vec2(texel) + texel_offset);
          vec4 id = texelFetch(pre_render_id, coords, 0);
          vec4 next_o_id = texelFetch(pre_render_original_id, coords, 0);
          vec4 next_color = texelFetch(pre_render_color, coords, 0);
          vec4 next_color_ip = texelFetch(pre_render_color_ip, coords, 0);
          vec4 next_o_color = texelFetch(pre_render_original_color, coords, 0);
          if (max(next_color_ip.w, center_color_ip.w) > 0.0 && min(center_o_id.w, next_o_id.w) >= 0.5 && center_o_id.xyz == next_o_id.xyz) {
            color += next_color + next_color_ip * 255.0;
            count ++;
            o_color += next_o_color;
            o_count++;
          } else if (id.xyz == center_id.xyz) {
            color += next_color + next_color_ip * 255.0;
            count ++;
          }
        }
      }
    } else {
      count = 1.0;
      o_count = 1.0;
      color = center_color + center_color_ip * 255.0;  
      o_color = center_o_color;
    }
    if (center_color.w > 0.0) {
      // Set out target_color for render texture for the antialiasing filter
      vec3 final_color = color.xyz / count;
      if (o_count == 0.0) {
        final_color *= center_o_color.xyz;
      } else {
        final_color *= o_color.xyz / o_count;
      }
      if (hdr == 1) {
        // Apply Reinhard tone mapping
        final_color = final_color / (final_color + vec3(1.0));
        // Gamma correction
        float gamma = 0.8;
        final_color = pow(4.0 * final_color, vec3(1.0 / gamma)) / 4.0 * 1.3;
      }
      out_color = vec4(final_color, 1.0);
    } else {
      out_color = vec4(0.0, 0.0, 0.0, 0.0);
    }
  }
  `;
  #fxaaGlsl = `#version 300 es
  // Define FXAA constants
  #define FXAA_EDGE_THRESHOLD_MIN 1.0 / 32.0
  #define FXAA_EDGE_THRESHOLD 1.0 / 4.0
  #define FXAA_SUBPIX_TRIM 0.0
  #define FXAA_SUBPIX_TRIM_SCALE 1.0
  #define FXAA_SUBPIX_CAP 7.0 / 8.0
  #define FXAA_SEARCH_STEPS 6
  precision highp float;
  in vec2 clip_space;
  uniform sampler2D pre_render;
  out vec4 out_color;
  vec2 texel;
  vec4 fetch(int x, int y) {
    return texelFetch(pre_render, ivec2(texel) + ivec2(x, y), 0);
  }
  // Color to luminance conversion from NVIDIA FXAA white paper
  float fxaa_luma(vec4 rgba) {
    return (rgba.y * (0.587/0.299) + rgba.x) * rgba.w;
  }
  float tex_luma(int x, int y) {
    // Devide length through square root of 3 to have a maximum length of 1
    return fxaa_luma(fetch(x, y));
  }
  // Local contrast checker from NVIDIA FXAA white paper
  vec2 fxaa_contrast(int x, int y) {
    return vec2(
      min(tex_luma(x, y), min(min(tex_luma(x, y-1), tex_luma(x-1, y)), min(tex_luma(x, y+1), tex_luma(x+1, y)))),
      max(tex_luma(x, y), max(max(tex_luma(x, y-1), tex_luma(x-1, y)), max(tex_luma(x, y+1), tex_luma(x+1, y))))
    );
  }
  // Local low contrast checker from NVIDIA FXAA white paper
  bool fxaa_is_low_contrast(int x, int y) {
    vec2 range_min_max = fxaa_contrast(x, y);
    float range = range_min_max.y - range_min_max.x;
    return (range < max(FXAA_EDGE_THRESHOLD_MIN, range_min_max.y * FXAA_EDGE_THRESHOLD));
  }
  vec4 blur_3x3(int x, int y) {
    return 1.0 / 9.0 * (
        fetch(x-1,y-1) + fetch(  x,y-1) + fetch(x+1,y-1)
      + fetch(x-1,  y) + fetch(  x,  y) + fetch(x+1,  y)
      + fetch(x-1,y+1) + fetch(  x,y+1) + fetch(x+1,y+1)
    );
  }
  float fxaa_sub_pixel_aliasing(int x, int y) {
    float luma_l = 0.25 * (tex_luma(x,y-1) + tex_luma(x-1,y) + tex_luma(x+1,y) + tex_luma(x,y+1));
    float range_l = abs(luma_l - tex_luma(x, y));
    // Get contrast range
    vec2 range_min_max = fxaa_contrast(x, y);
    float range = range_min_max.y - range_min_max.x;
    float blend_l = max(0.0,
    (range_l / range) - FXAA_SUBPIX_TRIM) * FXAA_SUBPIX_TRIM_SCALE;
    blend_l = min(FXAA_SUBPIX_CAP, blend_l);
    return blend_l;
  }
  void main() {
    // Get texture size
    texel = vec2(textureSize(pre_render, 0)) * clip_space;
    vec4 original_color = fetch(0, 0);
    float original_luma = tex_luma(0, 0);
    mat3 luma = mat3(
      vec3(tex_luma(-1,-1),tex_luma(0,-1),tex_luma(1,-1)),
      vec3(tex_luma(-1, 0),tex_luma(0, 0),tex_luma(1, 0)),
      vec3(tex_luma(-1, 1),tex_luma(0, 1),tex_luma(1, 1))
    );
    // Edge detection from NVIDIA FXAA white paper
    float edge_vert =
      abs((0.25 * luma[0].x) + (-0.5 * luma[0].y) + (0.25 * luma[0].z)) +
      abs((0.50 * luma[1].x) + (-1.0 * luma[1].y) + (0.50 * luma[1].z)) +
      abs((0.25 * luma[2].x) + (-0.5 * luma[2].y) + (0.25 * luma[2].z));
    float edge_horz =
      abs((0.25 * luma[0].x) + (-0.5 * luma[1].x) + (0.25 * luma[2].x)) +
      abs((0.50 * luma[0].y) + (-1.0 * luma[1].y) + (0.50 * luma[2].y)) +
      abs((0.25 * luma[0].z) + (-0.5 * luma[1].z) + (0.25 * luma[2].z));
    bool horz_span = edge_horz >= edge_vert;
    ivec2 step = ivec2(0, 1);
    if (horz_span) step = ivec2(1, 0);
    if (fxaa_is_low_contrast(0, 0)) {
      out_color = original_color;
      return;
    }
    ivec2 pos_n = - step;
    ivec2 pos_p = step;
    vec4 color = original_color;
    float pixel_count = 1.0;
    bool done_n = false;
    bool done_p = false;
    // Luma of neighbour with highest contrast
    float luma_mcn = max(
      max(abs(luma[0].y - luma[1].y), abs(luma[1].z - luma[1].y)),
      max(abs(luma[2].y - luma[1].y), abs(luma[1].x - luma[1].y))
    );
    float gradient = abs(luma_mcn - luma[1].y);
    for (int i = 0; i < FXAA_SEARCH_STEPS; i++) {
      // Blend pixel with 3x3 box filter to preserve sub pixel detail
      if (!done_n) {
        vec4 local_blur_n = blur_3x3(pos_n.x, pos_n.y);
        done_n = (abs(fxaa_luma(local_blur_n) - luma_mcn) >= gradient);
        color += mix(fetch(pos_n.x, pos_n.y), local_blur_n, fxaa_sub_pixel_aliasing(pos_n.x, pos_n.y));
        pixel_count++;
        pos_n -= step;
      } else if (!done_p) {
        vec4 local_blur_p = blur_3x3(pos_p.x, pos_p.y);
        done_p = (abs(fxaa_luma(local_blur_p) - luma_mcn) >= gradient);
        color += mix(fetch(pos_p.x, pos_p.y), local_blur_p, fxaa_sub_pixel_aliasing(pos_p.x, pos_p.y));
        pixel_count++;
        pos_p += step;
      } else {
        break;
      }
    }
    out_color = color / pixel_count;
  }
  `;
  // Create new rayTracer from canvas and setup movement
  constructor (canvas, camera, scene) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.#gl = canvas.getContext('webgl2');
  }

  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
  }

  // Functions to update texture atlases to add more textures during runtime
	#updateTextureType (type, fakeTextureWidth) {
		// Test if there is even a texture
		if (type.length === 0) {
			this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, 1, 1, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, new Uint8Array(4));
			return;
		}

		const [width, height] = this.scene.standardTextureSizes;
		const textureWidth = Math.floor(2048 / width);

		const canvas = document.createElement('canvas');
		const ctx = canvas.getContext('2d');

		canvas.width = width * textureWidth;
		canvas.height = height * type.length;
		ctx.imageSmoothingEnabled = false;

		type.forEach(async (texture, i) => {
			// textureWidth for third argument was 3 for regular textures
			ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height);
		});
		this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, canvas.width, canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, Uint8Array.from(ctx.getImageData(0, 0, canvas.width, canvas.height).data));
	}
  updatePbrTextures () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#pbrTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);

		this.#updateTextureType(this.scene.pbrTextures);
  }
  updateTranslucencyTextures () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#translucencyTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);

		this.#updateTextureType(this.scene.translucencyTextures);
  }
  updateTextures () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#texture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_S, this.#gl.CLAMP_TO_EDGE);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_T, this.#gl.CLAMP_TO_EDGE);

		this.#updateTextureType(this.scene.textures);
  }
  // Functions to update vertex and light source data textures
  updatePrimaryLightSources () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_S, this.#gl.CLAMP_TO_EDGE);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_T, this.#gl.CLAMP_TO_EDGE);

		// Don't update light sources if there is none
		if (this.scene.primaryLightSources.length === 0) {
			this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 1, 1, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(3));
			return;
		}

    var lightTexArray = [];
    // Iterate over light sources
		this.scene.primaryLightSources.forEach(lightSource => {
			// Set intensity to lightSource intensity or default if not specified
			const intensity = Object.is(lightSource.intensity)? this.scene.defaultLightIntensity : lightSource.intensity;
			const variation = Object.is(lightSource.variation)? this.scene.defaultLightVariation : lightSource.variation;
			// push location of lightSource and intensity to texture, value count has to be a multiple of 3 rgb format
			lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], intensity, variation, 0);
		});

    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2, this.scene.primaryLightSources.length, 0, this.#gl.RGB, this.#gl.FLOAT, Float32Array.from(lightTexArray));
  }
  updateScene () {
    let id = 0;
    // Set data variable for texels in world space texture
    var data = [];
    // Build simple AABB tree (Axis aligned bounding box)
    var fillData = async (item) => {
      //console.log(item);
      if (Array.isArray(item) || item.indexable){
        let b = item[0];
        // Save position of len variable in array
        let len_pos = data.length;
        // Begin bounding volume array
        data.push(b[0],b[1],b[2],b[3],b[4],b[5],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
        id++;
        // Iterate over all sub elements and skip bounding (item[0])
        for (let i = 1; i < item.length; i++){
          // Push sub elements in queue
          fillData(item[i]);
        }
        let len = Math.floor((data.length - len_pos) / 24);
        // Set now calculated vertices length of bounding box
        // to skip if ray doesn't intersect with it
        data[len_pos + 6] = len;
      }else{
        // Alias object properties to simplify data texture assembly
        let v = item.vertices;
        let c = item.colors;
        let n = item.normals;
        let t = item.textureNums;
        let uv = item.uvs;
        let len = item.length;
        // Test if bounding volume is set
        if (item.bounding !== undefined){
          // Declare bounding volume of object
          let b = item.bounding;
          data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          id++;
        }else if (item.length > 3){
          // Warn if length is greater than 3
          console.warn(item);
          // A single triangle needs no bounding voume, so nothing happens in this case
        }
        // Give item new id property to identify vertex in fragment shader
        item.ids = [];
        for (let i = 0; i < len * 3; i += 9){
          let j = i/3*2;
          // 1 vertex = 1 line in world texture
          // a, b, c, color, normal, texture_nums, UVs1, UVs2
          data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i/3],c[i/3+1],c[i/3+2],n[i],n[i+1],n[i+2],t[j],t[j+1],t[j+2],uv[j],uv[j+1],uv[j+2],uv[j+3],uv[j+4],uv[j+5]);
          item.ids.push(Math.floor(id / 65535), id % 65535, Math.floor(id / 65535), id % 65535, Math.floor(id / 65535), id % 65535);
          id++;
        }
      }
    }
    // Fill texture with data pixels
    for (let i = 0; i < this.scene.queue.length; i++) fillData(this.scene.queue[i]);
    // Round up data to next higher multiple of 6144 (8 pixels * 3 values * 256 vertecies per line)
    data.push(new Array(6144 - data.length % 6144).fill(0));
    data = data.flat();
    // Calculate DataHeight by dividing value count through 6144 (8 pixels * 3 values * 256 vertecies per line)
    var dataHeight = data.length / 6144;
    // Manipulate actual webgl texture
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#worldTexture);
    // Tell webgl to use 4 bytes per value for the 32 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2048, dataHeight, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(data));
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
  }

  render() {
    var rt = this;
    // Allow frame rendering
    rt.#halt = false;
    // Initialize internal globals of render functiod
    // The millis variable is needed to calculate fps and movement speed
    var TimeElapsed = performance.now();
    // Total frames calculated since last meassured
    var Frames = 0;
    // Internal GL objects
    var Program, CameraPosition, Perspective, RenderConf, SamplesLocation, MaxReflectionsLocation, MinImportancyLocation, FilterLocation, AmbientLocation, TextureWidth, WorldTex, RandomTex, PbrTex, TranslucencyTex, Tex, LightTex;
    // Init Buffers
    var PositionBuffer, IdBuffer, TexBuffer;
    // Init Texture elements
    var RandomTexture, Random;
    // Framebuffer, Post Program buffers and textures
    var Framebuffer, OriginalRenderTexture, OriginalRenderTex, IdRenderTexture, OriginalIdRenderTexture;
    // Set post program array
    var PostProgram = [];
    // Create textures for Framebuffers in PostPrograms
    var RenderTexture = new Array(5);
    var IpRenderTexture = new Array(5);
    var DepthTexture = new Array(5);
    var OriginalRenderTexture = new Array(2);
    var IdRenderTexture = new Array(2);

    var RenderTex = new Array(5);
    var IpRenderTex = new Array(5);
    var OriginalRenderTex = new Array(5);
    var IdRenderTex = new Array(5);
    var OriginalIdRenderTex = new Array(5);
    var HdrLocation;
    // Create caching textures for denoising
		for (let i = 0; i < 5; i ++) {
				RenderTexture[i] = this.#gl.createTexture();
				IpRenderTexture[i] = this.#gl.createTexture();
        if (i < 2) OriginalRenderTexture[i] = this.#gl.createTexture();
        if (i < 2) IdRenderTexture[i] = this.#gl.createTexture();
				DepthTexture[i] = this.#gl.createTexture();
    }
    // Create buffers for vertices in PostPrograms
    var PostVertexBuffer = new Array(5);
    var PostFramebuffer = new Array(5);
    // Convolution-Antialiasing program and its buffers and textures
    var AntialiasingProgram, AntialiasingVertexBuffer, AntialiasingTexture, AntialiasingTex;
    // Create different Vaos for different rendering/filtering steps in pipeline
    var Vao = this.#gl.createVertexArray();
		// Generate enough Vaos for each denoise pass
    var PostVao = new Array(5).map(() => this.#gl.createVertexArray());
    var AntialiasingVao = this.#gl.createVertexArray();

    // Check if recompile is needed
    var State = [this.filter, this.renderQuality];
    // Handle canvas resize
    window.addEventListener('resize', function(){
    	resize();
    });
    // Function to handle canvas resize
    function resize(){
			const canvas = rt.canvas;
    	canvas.width = canvas.clientWidth * rt.renderQuality;
    	canvas.height = canvas.clientHeight * rt.renderQuality;
    	rt.#gl.viewport(0, 0, canvas.width, canvas.height);
      // Generate Random variable after each resize
    	Random = new Uint8Array(3 * canvas.width * canvas.height).map(() => 256 * Math.random());
      // Rebuild textures with every resize
      randomTextureBuilder();
      renderTextureBuilder();
      antialiasingRenderTextureBuilder();

      rt.firstPasses = 1 + Math.round(Math.sqrt(canvas.width * canvas.height) / 200);
      rt.secondPasses = 1 + Math.round(Math.sqrt(canvas.width * canvas.height) / 50);
    }
    // Init canvas parameters and textures with resize
    resize();


    function buildProgram(shaders){
      // Create Program, compile and append vertex and fragment shader to it
      let program = rt.#gl.createProgram();
      // Compile GLSL shaders
      shaders.forEach((item, i) => {
        let shader = rt.#gl.createShader(item.type);
        rt.#gl.shaderSource(shader, item.source);
        rt.#gl.compileShader(shader);
        // Append shader to Program if GLSL compiled successfully
        if (rt.#gl.getShaderParameter(shader, rt.#gl.COMPILE_STATUS)){
          rt.#gl.attachShader(program, shader);
        }else{
          // Log debug info and delete shader if shader fails to compile
          console.warn(rt.#gl.getShaderInfoLog(shader));
          rt.#gl.deleteShader(shader);
        }
      });
      rt.#gl.linkProgram(program);
      // Return Program if it links successfully
      if (!rt.#gl.getProgramParameter(program, rt.#gl.LINK_STATUS)){
        console.log(shaders);
        // Log debug info and delete Program if Program fails to link
        console.warn(rt.#gl.getProgramInfoLog(program));
        rt.#gl.deleteProgram(program);
      }else{
        return program;
      }
    }

    function randomTextureBuilder(){
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, RandomTexture);
      // Fill texture with pseudo random pixels
      // Tell webgl to use 1 byte per value for the 8 bit ints
      rt.#gl.pixelStorei(rt.#gl.UNPACK_ALIGNMENT, 1);
      // Set data texture details and tell webgl, that no mip maps are required
      rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MIN_FILTER, rt.#gl.LINEAR);
      rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MAG_FILTER, rt.#gl.LINEAR);
      rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGB8, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGB, rt.#gl.UNSIGNED_BYTE, Random);
      rt.#gl.generateMipmap(rt.#gl.TEXTURE_2D);
    }
    function renderTextureBuilder(){
      // Init textures for denoiser
      [RenderTexture, IpRenderTexture, OriginalRenderTexture, IdRenderTexture].forEach((parent) => {
        parent.forEach(function(item){
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
          rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGBA, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGBA, rt.#gl.UNSIGNED_BYTE, null);
          rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MIN_FILTER, rt.#gl.NEAREST);
          rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MAG_FILTER, rt.#gl.NEAREST);
          rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_S, rt.#gl.CLAMP_TO_EDGE);
          rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_T, rt.#gl.CLAMP_TO_EDGE);
        });
      });
      // Init single channel depth textures
      DepthTexture.forEach((item) => {
        rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.DEPTH_COMPONENT24, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.DEPTH_COMPONENT, rt.#gl.UNSIGNED_INT, null);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MIN_FILTER, rt.#gl.NEAREST);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MAG_FILTER, rt.#gl.NEAREST);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_S, rt.#gl.CLAMP_TO_EDGE);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_T, rt.#gl.CLAMP_TO_EDGE);
      });
      // Init other textures
      [OriginalIdRenderTexture].forEach(function(item){
        rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGBA, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGBA, rt.#gl.UNSIGNED_BYTE, null);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MIN_FILTER, rt.#gl.NEAREST);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MAG_FILTER, rt.#gl.NEAREST);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_S, rt.#gl.CLAMP_TO_EDGE);
        rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_T, rt.#gl.CLAMP_TO_EDGE);
      });
    }
    function antialiasingRenderTextureBuilder(){
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, AntialiasingTexture);
      rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGBA, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGBA, rt.#gl.UNSIGNED_BYTE, null);
      rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MIN_FILTER, rt.#gl.NEAREST);
      rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_MAG_FILTER, rt.#gl.NEAREST);
      rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_S, rt.#gl.CLAMP_TO_EDGE);
      rt.#gl.texParameteri(rt.#gl.TEXTURE_2D, rt.#gl.TEXTURE_WRAP_T, rt.#gl.CLAMP_TO_EDGE);
    }

    // Internal render engine Functions
    function frameCycle (Millis) {
			// Clear screen
      rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
      // Check if recompile is required
      if (State[0] !== rt.filter || State[1] !== rt.renderQuality) {
        resize();
        prepareEngine();
        State = [rt.filter, rt.renderQuality];
      }
      // Request the browser to render frame with hardware acceleration
      if (!rt.#halt) requestAnimationFrame(frameCycle);
      // Render new Image, work through queue
      if (rt.filter) {
        renderFrameRt();
      } else {
        renderFrameRtRaw();
      }
      // Update frame counter
      Frames ++;
      // Calculate Fps
			const timeDifference = Millis - TimeElapsed;
      if (timeDifference > 500) {
        rt.fps = (1000 * Frames / timeDifference).toFixed(0);
        [TimeElapsed, Frames] = [Millis, 0];
      }
    }

    function texturesToGPU() {
      rt.#gl.bindVertexArray(Vao);
      rt.#gl.useProgram(Program);
      // Set world-texture
      rt.updateScene();
      rt.updatePrimaryLightSources();

      rt.#gl.activeTexture(rt.#gl.TEXTURE0);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#worldTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE1);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, RandomTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE2);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#pbrTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE3);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#translucencyTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE4);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#texture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE5);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#lightTexture);
      // Set uniforms for shaders
      // Set 3d camera position
      rt.#gl.uniform3f(CameraPosition, rt.camera.x, rt.camera.y, rt.camera.z);
      // Set x and y rotation of camera
      rt.#gl.uniform2f(Perspective, rt.camera.fx, rt.camera.fy);
      // Set fov and X/Y ratio of screen
      rt.#gl.uniform4f(RenderConf, rt.camera.fov, rt.#gl.canvas.width / rt.#gl.canvas.height, 1, 1);
      // Set amount of samples per ray
      rt.#gl.uniform1i(SamplesLocation, rt.samplesPerRay);
      // Set max reflections per ray
      rt.#gl.uniform1i(MaxReflectionsLocation, rt.maxReflections);
      // Set min importancy of light ray
      rt.#gl.uniform1f(MinImportancyLocation, rt.minImportancy);
      // Instuct shader to render for filter or not
      rt.#gl.uniform1i(FilterLocation, rt.filter);
      // Set global illumination
      rt.#gl.uniform3f(AmbientLocation, rt.scene.ambientLight[0], rt.scene.ambientLight[1], rt.scene.ambientLight[2]);
      // Set width of height and normal texture
      rt.#gl.uniform1i(TextureWidth, Math.floor(2048 / rt.scene.standardTextureSizes[0]));
      // Pass whole current world space as data structure to GPU
      rt.#gl.uniform1i(WorldTex, 0);
      // Pass random texture to GPU
      rt.#gl.uniform1i(RandomTex, 1);
      // Pass pbr texture to GPU
      rt.#gl.uniform1i(PbrTex, 2);
      // Pass pbr texture to GPU
      rt.#gl.uniform1i(TranslucencyTex, 3);
      // Pass texture to GPU
      rt.#gl.uniform1i(Tex, 4);
      // Pass texture with all primary light sources in the scene
      rt.#gl.uniform1i(LightTex, 5);
    }

    function fillBuffers() {
      let vertices = [];
      let ids = [];
      let uvs = [];
      let id = 0;
      let length = 0;
      // Iterate through render queue and build arrays for GPU
      var flattenQUEUE = (item) => {
        if (Array.isArray(item) || item.indexable){
          // Iterate over all sub elements and skip bounding (item[0])
          for (let i = 1; i < item.length; i++){
            // flatten sub element of queue
            flattenQUEUE(item[i]);
          }
        } else {
					id ++;
          for(let i = 0; i < item.ids.length; i+=2) {
            ids.push(item.ids[i], item.ids[i + 1], id / 65535, id / 256);
          }
					vertices.push(item.vertices);
          uvs.push(item.uvs);
          length += item.length;
        }
      };
      // Start recursion
      rt.scene.queue.forEach(item => flattenQUEUE(item));
      // Set buffers
      [
        [PositionBuffer, vertices],
        [IdBuffer, ids],
        [TexBuffer, uvs]
      ].forEach(function(item) {
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, item[0]);
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, new Float32Array(item[1].flat()), rt.#gl.DYNAMIC_DRAW);
      });
      // Actual drawcall
      rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, length);
    }

    function renderFrameRt() {
      {
        // Configure where the final image should go
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, Framebuffer);
        rt.#gl.drawBuffers([
          rt.#gl.COLOR_ATTACHMENT0,
          rt.#gl.COLOR_ATTACHMENT1,
          rt.#gl.COLOR_ATTACHMENT2,
          rt.#gl.COLOR_ATTACHMENT3,
          rt.#gl.COLOR_ATTACHMENT4
        ]);
        // Configure framebuffer for color and depth
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[0], 0);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[0], 0);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[0], 0);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT3, rt.#gl.TEXTURE_2D, IdRenderTexture[0], 0);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT4, rt.#gl.TEXTURE_2D, OriginalIdRenderTexture, 0);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.DEPTH_ATTACHMENT, rt.#gl.TEXTURE_2D, DepthTexture[0], 0);
        // Clear depth and color buffers from last frame
        rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);

        texturesToGPU();
        fillBuffers();
      }
      // Apply post processing
      {
        // Save last used program slot
        let n = 0;
        let nId = 0;
        let nOriginal = 0;
        for (let i = 0; i < rt.firstPasses + rt.secondPasses; i++) {
          // Look for next free compatible program slot
          let np = (i%2)^1;
          let npOriginal = ((i - rt.firstPasses)%2)^1;
          if (rt.firstPasses <= i) np += 2;
          // Configure where the final image should go
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, PostFramebuffer[n]);
          // Set attachments to use for framebuffer
          rt.#gl.drawBuffers([
            rt.#gl.COLOR_ATTACHMENT0,
            rt.#gl.COLOR_ATTACHMENT1,
            rt.#gl.COLOR_ATTACHMENT2
          ]);
          // Configure framebuffer for color and depth
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[np], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[np], 0);
          if (rt.firstPasses <= i - 2) {
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[npOriginal], 0);
          } else {
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, IdRenderTexture[np], 0);
          }
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.DEPTH_ATTACHMENT, rt.#gl.TEXTURE_2D, DepthTexture[np], 0);
          // Clear depth and color buffers from last frame
          rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
          // Push pre rendered textures to next shader (post processing)
          [RenderTexture[n], IpRenderTexture[n], OriginalRenderTexture[nOriginal], IdRenderTexture[nId], OriginalIdRenderTexture].forEach(function(item, i){
            rt.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
            rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
          });
          // Switch program and Vao
          rt.#gl.useProgram(PostProgram[n]);
          rt.#gl.bindVertexArray(PostVao[n]);
          // Pass pre rendered texture to shad
          rt.#gl.uniform1i(RenderTex[n], 0);
          rt.#gl.uniform1i(IpRenderTex[n], 1);
          // Pass original color texture to GPU
          rt.#gl.uniform1i(OriginalRenderTex[n], 2);
          // Pass vertex_id texture to GPU
          rt.#gl.uniform1i(IdRenderTex[n], 3);
          // Pass vertex_id of original vertex as a texture to GPU
          rt.#gl.uniform1i(OriginalIdRenderTex[n], 4);
          // Post processing drawcall
          rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
          // Save current program slot in n for next pass
          n = np;

          if (rt.firstPasses <= i) {
            nOriginal = npOriginal;
          } else {
            nId = np;
          }
        }
      }
      // Last denoise pass
      {
        rt.#gl.drawBuffers([
          rt.#gl.COLOR_ATTACHMENT0,
          rt.#gl.COLOR_ATTACHMENT1
        ]);
        // Configure framebuffer for color and depth
        if (rt.antialiasing) {
          // Configure where the final image should go
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, PostFramebuffer[4]);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, AntialiasingTexture, 0);
        } else {
          // Render to canvas now
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, null);
        }
        // Clear depth and color buffers from last frame
        rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);

        let index = 2 + (rt.firstPasses + rt.secondPasses) % 2;
        let indexId = rt.firstPasses % 2;
        let indexOriginal = rt.secondPasses % 2;
        // Push pre rendered textures to next shader (post processing)
        [RenderTexture[index], IpRenderTexture[index], OriginalRenderTexture[indexOriginal], IdRenderTexture[indexId], OriginalIdRenderTexture].forEach(function(item, i){
          rt.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        });
        // Switch program and VAO
        rt.#gl.useProgram(PostProgram[4]);
        rt.#gl.bindVertexArray(PostVao[4]);
        // Pass pre rendered texture to shader
        rt.#gl.uniform1i(RenderTex[4], 0);
        rt.#gl.uniform1i(IpRenderTex[4], 1);
        // Pass original color texture to GPU
        rt.#gl.uniform1i(OriginalRenderTex[4], 2);
        // Pass vertex_id texture to GPU
        rt.#gl.uniform1i(IdRenderTex[4], 3);
        // Pass vertex_id of original vertex as a texture to GPU
        rt.#gl.uniform1i(OriginalIdRenderTex[4], 4);
        // Pass hdr variable to last post processing shader
        rt.#gl.uniform1i(HdrLocation, rt.hdr);
        // Post processing drawcall
        rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
      }
      // Apply antialiasing shader if enabled
      if (rt.antialiasing) {
        // Render to canvas now
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, null);
        // Make pre rendered texture TEXTURE0
        rt.#gl.activeTexture(rt.#gl.TEXTURE0);
        rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, AntialiasingTexture);
        // Switch program and vao
        rt.#gl.useProgram(AntialiasingProgram);
        rt.#gl.bindVertexArray(AntialiasingVao);
        // Pass pre rendered texture to shader
        rt.#gl.uniform1i(AntialiasingTex, 0);
        // Post processing drawcall
        rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
      }
    }

    function renderFrameRtRaw(){
      {
        // If Filter variable is not set render to canvas directly
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, null);
        // Clear depth and color buffers from last frame
        rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
        texturesToGPU();
        fillBuffers();
      }
    }

    function prepareEngine() {
      rt.updateTextures();
      rt.updatePbrTextures();
      rt.updateTranslucencyTextures();
      // Compile shaders and link them into Program global
      Program = buildProgram([
        { source: rt.#vertexGlsl, type: rt.#gl.VERTEX_SHADER },
        { source: rt.#fragmentGlsl, type: rt.#gl.FRAGMENT_SHADER }
      ]);

      // Compile shaders and link them into PostProgram global
      for (let i = 0; i < 2; i++){
        PostProgram[i] = buildProgram([
          { source: rt.#postProcessGlsl, type: rt.#gl.VERTEX_SHADER },
          { source: rt.#firstFilterGlsl, type: rt.#gl.FRAGMENT_SHADER }
        ]);
      }

      // Compile shaders and link them into PostProgram global
      for (let i = 2; i < 4; i++){
        PostProgram[i] = buildProgram([
          { source: rt.#postProcessGlsl, type: rt.#gl.VERTEX_SHADER },
          { source: rt.#secondFilterGlsl, type: rt.#gl.FRAGMENT_SHADER }
        ]);
      }

      // Compile shaders and link them into PostProgram global
      PostProgram[4] = buildProgram([
        { source: rt.#postProcessGlsl, type: rt.#gl.VERTEX_SHADER },
        { source: rt.#finalFilterGlsl, type: rt.#gl.FRAGMENT_SHADER }
      ]);
      // Compile shaders and link them into AntialiasingProgram global
      AntialiasingProgram = buildProgram([
        { source: rt.#postProcessGlsl, type: rt.#gl.VERTEX_SHADER },
        { source: rt.#fxaaGlsl, type: rt.#gl.FRAGMENT_SHADER }
      ]);
      // Create global vertex array object (Vao)
      rt.#gl.bindVertexArray(Vao);
      // Bind uniforms to Program
      CameraPosition = rt.#gl.getUniformLocation(Program, 'camera_position');
      Perspective = rt.#gl.getUniformLocation(Program, 'perspective');
      RenderConf = rt.#gl.getUniformLocation(Program, 'conf');
      SamplesLocation = rt.#gl.getUniformLocation(Program, 'samples');
      MaxReflectionsLocation = rt.#gl.getUniformLocation(Program, 'max_reflections');
      MinImportancyLocation = rt.#gl.getUniformLocation(Program, 'min_importancy');
      FilterLocation = rt.#gl.getUniformLocation(Program, 'use_filter');
      AmbientLocation = rt.#gl.getUniformLocation(Program, 'ambient');
      WorldTex = rt.#gl.getUniformLocation(Program, 'world_tex');
      RandomTex = rt.#gl.getUniformLocation(Program, 'random');
      TextureWidth = rt.#gl.getUniformLocation(Program, 'texture_width');

      LightTex = rt.#gl.getUniformLocation(Program, 'light_tex');
      PbrTex = rt.#gl.getUniformLocation(Program, 'pbr_tex');
      TranslucencyTex = rt.#gl.getUniformLocation(Program, 'translucency_tex');
      Tex = rt.#gl.getUniformLocation(Program, 'tex');
      // Enable depth buffer and therefore overlapping vertices
      rt.#gl.enable(rt.#gl.DEPTH_TEST);
      rt.#gl.depthMask(true);
      // Cull (exclude from rendering) hidden vertices at the other side of objects
      rt.#gl.enable(rt.#gl.CULL_FACE);
      // Set clear color for framebuffer
      rt.#gl.clearColor(0, 0, 0, 0);
      // Define Program with its currently bound shaders as the program to use for the webgl2 context
      rt.#gl.useProgram(Program);
      // Create Textures for primary render
      RandomTexture = rt.#gl.createTexture();
      rt.#pbrTexture = rt.#gl.createTexture();
      rt.#translucencyTexture = rt.#gl.createTexture();
      rt.#texture = rt.#gl.createTexture();
      // Create texture for all primary light sources in scene
      rt.#lightTexture = rt.#gl.createTexture();
      // Init a world texture containing all information about world space
      rt.#worldTexture = rt.#gl.createTexture();
      // Create random texture
      randomTextureBuilder();
      // Create buffers
      [PositionBuffer, IdBuffer, TexBuffer] = [rt.#gl.createBuffer(), rt.#gl.createBuffer(), rt.#gl.createBuffer()];
      [
        // Bind world space position buffer
        [PositionBuffer, 3, false],
        // Surface id buffer
        [IdBuffer, 4, false],
        // Set barycentric texture coordinates
        [TexBuffer, 2, true]
      ].forEach((item, i) => {
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, item[0]);
        rt.#gl.enableVertexAttribArray(i);
        rt.#gl.vertexAttribPointer(i, item[1], rt.#gl.FLOAT, item[2], 0, 0);
      });
      // Create frame buffers and textures to be rendered to
      [Framebuffer, OriginalIdRenderTexture] = [rt.#gl.createFramebuffer(), rt.#gl.createTexture()];

      renderTextureBuilder();

      for (let i = 0; i < 5; i++){
        // Create post program buffers and uniforms
        rt.#gl.bindVertexArray(PostVao[i]);
        rt.#gl.useProgram(PostProgram[i]);
        // Bind uniforms
        RenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'pre_render_color');
        IpRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'pre_render_color_ip');
        OriginalRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'pre_render_original_color');
        IdRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'pre_render_id');
        OriginalIdRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'pre_render_original_id');
        if (i === 4) HdrLocation = rt.#gl.getUniformLocation(PostProgram[i], 'hdr');
        PostVertexBuffer[i] = rt.#gl.createBuffer();
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, PostVertexBuffer[i]);
        rt.#gl.enableVertexAttribArray(0);
        rt.#gl.vertexAttribPointer(0, 2, rt.#gl.FLOAT, false, 0, 0);
        // Fill buffer with data for two verices
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, PostVertexBuffer[i]);
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), rt.#gl.DYNAMIC_DRAW);
        PostFramebuffer[i] = rt.#gl.createFramebuffer();
      }

      // Post processing (end of render pipeline)
      AntialiasingTexture = rt.#gl.createTexture();

      antialiasingRenderTextureBuilder();
      // Create post program buffers and uniforms
      rt.#gl.bindVertexArray(AntialiasingVao);
      rt.#gl.useProgram(AntialiasingProgram);

      AntialiasingTex = rt.#gl.getUniformLocation(AntialiasingProgram, 'pre_render');

      AntialiasingVertexBuffer = rt.#gl.createBuffer();

      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, AntialiasingVertexBuffer);
      rt.#gl.enableVertexAttribArray(0);
      rt.#gl.vertexAttribPointer(0, 2, rt.#gl.FLOAT, false, 0, 0);
      // Fill buffer with data for two verices
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, AntialiasingVertexBuffer);
      rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), rt.#gl.DYNAMIC_DRAW);
    }
    // Prepare Renderengine
    prepareEngine();
    // Begin frame cycle
    frameCycle();
  }
}
