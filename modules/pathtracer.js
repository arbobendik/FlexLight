'use strict';

import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';

export class PathTracer {
  type = 'pathtracer';
  // Configurable runtime properties of the pathtracer (public attributes)
  // Quality settings
  samplesPerRay = 1;
  renderQuality = 1;
  maxReflections = 3;
  minImportancy = 0.3;
  firstPasses = 0;
  secondPasses = 0;
  temporal = true;
  temporalSamples = 5;
  filter = true;
  hdr = true;
  // Performance metric
  fps = 0;

  #antialiasing = 'taa';
  #AAObject;
  // Make gl object inaccessible from outside the class
  #gl;
  #canvas;

  #halt = false;

  #worldTexture;
  #randomTextures = new Array(this.temporalSamples);
  // Internal gl texture variables of texture atlases
  #textureAtlas;
  #pbrAtlas;
  #translucencyAtlas;

  #textureList = [];
  #pbrList = [];
  #translucencyList = [];

  #lightTexture;
  // Shader source will be generated later
  #tempGlsl;
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


  vec3 clipPosition (vec3 pos, vec2 dir) {
    vec2 translate_px = vec2(
      pos.x * cos(dir.x) + pos.z * sin(dir.x),
      pos.z * cos(dir.x) - pos.x * sin(dir.x)
    );

    vec2 translate_py = vec2(
      pos.y * cos(dir.y) + translate_px.y * sin(dir.y),
      translate_px.y * cos(dir.y) - pos.y * sin(dir.y)
    );

    vec2 translate_2d = vec2(translate_px.x / conf.y, translate_py.x) / conf.x;

    return vec3(translate_2d, translate_py.y);
  }

  void main(){
    vec3 move_3d = position_3d + vec3(camera_position.x, - camera_position.yz) * vec3(-1.0, 1.0, 1.0);

    clip_space = clipPosition (move_3d, perspective + conf.zw);
    
    // Set triangle position in clip space
    gl_Position = vec4(clip_space.xy, - 1.0 / (1.0 + exp(- length(move_3d / 1048576.0))), clip_space.z);

    position = position_3d;
    tex_coord = tex_pos;
    vertex_id = id;
    player = camera_position;
  }
  `;
  #fragmentGlsl = `#version 300 es
  #define SQRT3 1.73205
  #define POW32 4294967296.0
  #define BIAS 0.00001525879
  #define INV_TRIANGLES_PER_ROW 0.00390625
  #define TRIANGLES_PER_ROW 256.0
  #define INV_256 0.00390625
  #define INV_65536 0.00001525879
  #define THIRD 0.333333

  precision highp float;
  precision highp sampler2D;

  float inv_texture_width = 1.0;

  struct Ray {
    vec3 direction;
    vec3 origin;
    vec3 normal;
  };

  struct Material {
    vec3 color;
    vec3 rme;
    vec3 tpo;
  };

  struct Light {
    vec3 origin;
    float strength;
    float variance;
  };

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
  layout(location = 5) out vec4 render_location_id;

  // Prevent blur over shadow border or over (close to) perfect reflections
  float first_ray_length = 1.0;
  // Accumulate color of mirror reflections
  float glass_filter = 0.0;
  float original_rmex = 0.0;
  float original_tpox = 0.0;
  vec3 original_color = vec3(1.0);

  // Lookup values for texture atlases
  vec4 lookup(sampler2D atlas, vec3 coords) {
    float atlas_height_factor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) * inv_texture_width;
    vec2 atlas_coords = vec2(
      (coords.x + mod(coords.z, float(texture_width))) * inv_texture_width,
      (coords.y + floor(coords.z * inv_texture_width)) * atlas_height_factor
    );
    // Return texel on requested location
    return texture(atlas, atlas_coords);
  }

  // Test if ray intersects triangle and return intersection
  mat2x4 rayTriangle(float l, Ray ray, mat3 t, vec3 n) {
    // Can't intersect with triangle with the same normal as the origin
    if (n == ray.normal) return mat2x4(0);
    // Get distance to intersection point
    float s = dot(n, t[0] - ray.origin) / dot(n, normalize(ray.direction));
    // Ensure that ray triangle intersection is between light source and texture
    if (s > l || s <= BIAS) return mat2x4(0);
    // Calculate intersection point
    vec3 d = (s * normalize(ray.direction)) + ray.origin;
    // Test if point on plane is in Triangle by looking for each edge if point is in or outside
    vec3 v0 = t[1] - t[0];
    vec3 v1 = t[2] - t[0];
    vec3 v2 = d - t[0];
    float d00 = dot(v0, v0);
    float d01 = dot(v0, v1);
    float d11 = dot(v1, v1);
    float d20 = dot(v2, v0);
    float d21 = dot(v2, v1);
    float denom = 1.0 / (d00 * d11 - d01 * d01);
    float v = (d11 * d20 - d01 * d21) * denom;
    float w = (d00 * d21 - d01 * d20) * denom;
    float u = 1.0 - v - w;
    if (min(u, v) <= BIAS || u + v >= 1.0 - BIAS) return mat2x4(0);
    // Return uvw and intersection point on triangle.
    return mat2x4(vec4(d, s), vec4(u, v, w, 0));
  }

  // Don't return intersection point, because we're looking for a specific triangle
  bool rayCuboid(vec3 inv_ray, vec3 p, vec3 min_corner, vec3 max_corner) {
    mat2x3 v = matrixCompMult(mat2x3(min_corner, max_corner) - mat2x3(p, p), mat2x3(inv_ray, inv_ray));
    float lowest = max(max(min(v[0].x, v[1].x), min(v[0].y, v[1].y)), min(v[0].z, v[1].z));
    float highest = min(min(max(v[0].x, v[1].x), max(v[0].y, v[1].y)), max(v[0].z, v[1].z));
    // Cuboid is behind ray
    // Ray points in cuboid direction, but doesn't intersect
    return max(lowest, BIAS) <= highest;
  }

  // Test for closest ray triangle intersection
  // Return intersection position in world space (rayTracer[0].xyz) and index of target triangle in world_tex (rayTracer[1].w)
  mat2x4 rayTracer(Ray ray) {
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 inv_ray = 1.0 / normalize(ray.direction);
    // Latest intersection which is now closest to origin
    mat2x4 intersection = mat2x4(vec4(0), vec4(vec3(0), -1));
    // Length to latest intersection
    float min_len = POW32;
    // Get texture size as max iteration value
    int size = textureSize(world_tex, 0).y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for (int i = 0; i < size; i++){
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(float(i), TRIANGLES_PER_ROW) * 8.0, float(i) * INV_TRIANGLES_PER_ROW);
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
        mat2x4 current_intersection = rayTriangle(min_len, ray, t, n);
        // Test if ray even intersects
        if (current_intersection != mat2x4(0)){
          min_len = current_intersection[0].w;
          intersection = current_intersection;
          intersection[1].w = float(i);
        }
      } else if (t == mat3(0)) {
        // Break if all values are zero and texture already ended
        break;
      } else if (!rayCuboid(inv_ray, ray.origin, vec3(t[0].x, t[0].z, t[1].y), vec3(t[0].y, t[1].x, t[1].z))){
        // If ray doesn't intersect bounding volume, skip shadow test for all elements in bounding volume
        i += int(t[2].x);
      }
    }
    // Return if pixel is in shadow or not
    return intersection;
  }

  // Simplified rayTracer to only test if ray intersects anything
  bool shadowTest(Ray ray, vec3 light){
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 inv_ray = 1.0 / normalize(ray.direction);
    // Precomput max length
    float max = length(light - ray.origin);
    // Get texture size as max iteration value
    int size = textureSize(world_tex, 0).y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for (int i = 0; i < size; i++) {
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(float(i), TRIANGLES_PER_ROW) * 8.0, float(i) * INV_TRIANGLES_PER_ROW);
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
        if (rayTriangle(length(light - ray.origin), ray, t, normalize(cross(t[0] - t[2], t[0] - t[1])))[0].xyz != vec3(0)) return true;
      } else if (t == mat3(0)) {
        // Break if all values are zero and texture already ended
        break;
      } else if (!rayCuboid(inv_ray, ray.origin, vec3(t[0].x, t[0].z, t[1].y), vec3(t[0].y, t[1].x, t[1].z))) {
        // If ray doesn't intersect bounding volume, skip shadow test for all elements in bounding volume
        i += int(t[2].x);
      }
    }
    // Tested all triangles, but there is no intersection
    return false;
  }

  float forwardTrace (Ray ray, vec3 origin, float metallicity, float strength) {
    float lenP1 = 1.0 + length(ray.direction);
    vec3 normalDir = normalize(ray.direction);

    // Calculate intensity of light reflection, which decreases squared over distance
    float intensity = strength / (lenP1 * lenP1);
    // Process specularity of ray in view from origin's perspective
    vec3 halfVector = normalize(normalDir + normalize(origin - ray.origin));
    float light = max(dot(normalDir, ray.normal), 0.0);
    float specular = pow(max(dot(halfVector, normalDir), 0.0), metallicity);
    // Determine final color and return it
    return mix(light, max(specular, 0.0), metallicity) * intensity;
  }

  float reservoirSample (sampler2D light_tex, vec4 random_vec, vec3 origin, vec3 last_rough_normal, vec3 last_origin, vec3 last_rme, bool dont_filter, int i) {
    float reservoir_length = 0.0;
    float total_weight = 0.0;

    int reservoir_num = 0;

    float reservoir_weight;
    Ray reservoir_light_ray;
    vec3 reservoir_light;


    vec2 last_random = abs(random_vec.zw);

    for (int j = 0; j < textureSize(light_tex, 0).y; j++) {
      // Read light position
      vec3 light = texelFetch(light_tex, ivec2(0, j), 0).xyz;
      // Read light strength from texture
      vec2 strength_variation = texelFetch(light_tex, ivec2(1, j), 0).xy;
      float strength = strength_variation.x;
      float variation = strength_variation.y;
      // Skip if strength is negative or zero
      if (strength <= 0.0) continue;
      reservoir_length ++;
      // Alter light source position according to variation.
      light = random_vec.xyz * variation + light;
      Ray light_ray = Ray (light - origin, origin, normalize(last_rough_normal));
      float weight = forwardTrace(light_ray, last_origin, last_rme.y, strength);
      total_weight += weight;
      if (last_random.y * total_weight <= weight) {
        reservoir_weight = weight;
        reservoir_light_ray = light_ray;
        reservoir_light = light;
        reservoir_num = j;
      }
      // Update pseudo random variable.
      last_random = texture(random, last_random).zw;
    }

    if (reservoir_length == 0.0) return 0.0;
    // Test if in shadow
    if (reservoir_weight == 0.0 || !shadowTest(reservoir_light_ray, reservoir_light)) {
      if (dont_filter || i == 0) render_id.w = float((reservoir_num % 128) * 2) / 255.0;
      return total_weight;
    } else if (dont_filter || i == 0) render_id.w = float((reservoir_num % 128) * 2 + 1) / 255.0;
    return 0.0;
  }

  float fresnel(vec3 normal, vec3 lightDir) {
    // Apply fresnel effect
    return dot(normal, lightDir);
  }

  vec3 lightTrace(sampler2D world_tex, sampler2D light_tex, vec3 origin, Ray first_ray, vec3 rme, vec3 tpo, int sample_n, int bounces){
    bool first_rough = rme.x >= 0.25;
    // Set bool to false when filter becomes necessary
    bool dont_filter = true;
    float last_filter_roughness = 0.0;
    float last_id = 0.0;
    // Use additive color mixing technique, so start with black
    vec3 final_color = vec3(0);
    vec3 importancy_factor = vec3(1);
    vec3 last_origin = origin;
    // Ray currently traced
    Ray ray = Ray(first_ray.direction, first_ray.origin, first_ray.normal);
    // Remember color of triangle ray intersected lastly
    // Start with white instead of original triangle color to seperate raytracing from texture, combine both results in filter
    vec3 last_color = vec3(1);
    // Pack roughness, metallicity and emissiveness in one vector for simplicity
    vec3 last_rme = rme;
    // Pack all translucency related values in one vector
    vec3 last_tpo = tpo;
    float cos_sample_n = cos(float(sample_n));
    // Iterate over each bounce and modify color accordingly
    for (int i = 0; i < bounces && length(importancy_factor) >= min_importancy * SQRT3; i++){
      float fi = float(i);
      // (a multiplicator vec3, that indicates how much the calculated values influence the final_color)
      importancy_factor *= last_color;
      // Apply emissive texture and ambient light
      final_color = (ambient * 0.25 + last_rme.z) * importancy_factor + final_color;
      // Generate pseudo random vector
      ivec2 random_coord = ivec2(mod(((clip_space.xy / clip_space.z) + (sin(fi) + cos_sample_n)) * 2.0, 1.0) * vec2(textureSize(random, 0).xy));
      vec4 random_vec = texelFetch(random, random_coord, 0) * 2.0 - 1.0;
      // Alter normal according to roughness value
      vec3 last_rough_normal = normalize(mix(ray.normal, random_vec.xyz, last_rme.x));
      // Fix for Windows devices, invert last_rough_normal if it points under the surface.
      last_rough_normal = sign(dot(last_rough_normal, ray.normal)) * last_rough_normal;
      // Handle fresnel reflection
      float fresnel_reflect = abs(fresnel(ray.normal, ray.direction));
      // object is solid or translucent by chance because of the fresnel effect
      bool is_solid = last_tpo.x * fresnel_reflect <= abs(random_vec.w);
      // Test if filter is already necessary
      if (dont_filter && i != 0) {
        if(sample_n == 0) {
          // Set color in filter
          original_color *= last_color;
          last_color = vec3(1);
        }
        // Add filtering intensity for respective surface
        original_rmex += last_filter_roughness;
        // Update render id
        if (original_tpox > 0.0) {
          render_id += pow(2.0, - fi) * vec4(ray.normal.xy, (last_filter_roughness * 2.0 + last_rme.y) * THIRD, 0.0);
        } else {
          render_id += pow(2.0, - fi) * vec4(last_id * INV_65536, last_id * INV_256, (last_filter_roughness * 2.0 + last_rme.y) * THIRD, 0.0);
        }
        original_tpox ++;
      }
      // Update dont_filter variable
      dont_filter = dont_filter && ((last_rme.x < 0.01 && is_solid) || !is_solid);
      // Intersection of ray with triangle
      mat2x4 intersection;
      // Calculate brightness for current hit
      float brightness_sample = reservoirSample (light_tex, random_vec, ray.origin, last_rough_normal, last_origin, last_rme, dont_filter, i);
      // Handle translucency and skip rest of light calculation
      if (is_solid) {
        if (dont_filter && last_tpo.x > 0.5) {
          glass_filter += 1.0;
          dont_filter = false;
        }
        // If ray fresnel reflects from inside an transparent object,
        // the surface faces in the opposite direction as usual
        ray.normal *= - sign(dot(ray.direction, ray.normal));
        // Calculate primary light sources for this pass if ray hits non translucent object
        final_color += brightness_sample * importancy_factor;
        // Calculate reflecting ray
        ray.direction = normalize(mix(reflect(ray.direction, ray.normal), normalize(random_vec.xyz), last_rme.x));
        if (dot(ray.direction, ray.normal) <= 0.0) ray.direction = normalize(ray.direction + ray.normal);
        // Calculate next intersection
        intersection = rayTracer(ray);
      } else {
        float ratio = last_tpo.z * 4.0;
        float sign = sign(dot(ray.direction, ray.normal));
        ray.direction = normalize(ray.direction + refract(ray.direction, - sign * ray.normal, pow(ratio, sign)));
        // Calculate next intersection
        intersection = rayTracer(ray);
        last_origin = 2.0 * ray.origin - last_origin;
        final_color += brightness_sample * importancy_factor * (1.0 - fresnel_reflect);
      }
      // Stop loop if there is no intersection and ray goes in the void
      if (intersection[0] == vec4(0)) break;
      // Update last used tpo.x value
      if (dont_filter) original_tpox = last_tpo.x;
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(intersection[1].w, TRIANGLES_PER_ROW) * 8.0, intersection[1].w * INV_TRIANGLES_PER_ROW);
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
      last_origin = ray.origin;
      ray.origin = intersection[0].xyz;
      ray.normal = normalize(texelFetch(world_tex, index + ivec2(4, 0), 0).xyz);
      // Preserve original roughness for filter pass
      last_filter_roughness = last_rme.x;
      // Fresnel effect
      last_rme.x *= mix(1.0, fresnel(ray.normal, last_origin - ray.origin), last_rme.y);
      if (i == 0) first_ray_length = min(length(ray.origin - last_origin) / length(first_ray.origin - origin), 1.0);
    }
    // Return final pixel color
    return final_color;
  }
  
  void main(){
    // Calculate constant for this pass
    inv_texture_width = 1.0 / float(texture_width);

    float id = vertex_id.x * 65535.0 + vertex_id.y;
    ivec2 index = ivec2(mod(id, TRIANGLES_PER_ROW) * 8.0, id * INV_TRIANGLES_PER_ROW);
    // Read base attributes from world texture.
    vec3 color = texelFetch(world_tex, index + ivec2(3, 0), 0).xyz;
    vec3 normal = normalize(texelFetch(world_tex, index + ivec2(4, 0), 0).xyz);
    vec3 texture_nums = texelFetch(world_tex, index + ivec2(5, 0), 0).xyz;
    // Test if pixel is in frustum or not
    if (clip_space.z < 0.0) return;
    // Alter normal and color according to texture and normal texture
    // Test if textures are even set otherwise use defaults.
    // Default tex_color to color
    Material material = Material (
      mix(color, lookup(tex, vec3(tex_coord, texture_nums.x)).xyz, sign(texture_nums.x + 1.0)),
      mix(vec3(0.5, 0.0, 0.0), lookup(pbr_tex, vec3(tex_coord, texture_nums.y)).xyz * vec3(1.0, 1.0, 4.0), sign(texture_nums.y + 1.0)),
      mix(vec3(0.0, 0.0, 0.25), lookup(translucency_tex, vec3(tex_coord, texture_nums.z)).xyz, sign(texture_nums.z + 1.0))
    );
    original_tpox = material.tpo.x;
    // Preserve original roughness for filter pass
    float filter_roughness = material.rme.x;
    // Fresnel effect
    material.rme.x = material.rme.x * mix(1.0, fresnel(normal, player - position), material.rme.y);
    // Start hybrid ray tracing on a per light source base
    // Directly add emissive light of original surface to final_color
    vec3 final_color = vec3(0);
    // Generate multiple samples
    for (int i = 0; i < samples; i++){
      // Set color of object itself
      // Calculate pixel for specific normal
      Ray ray = Ray (normalize(position - player), position, normalize(normal));
      final_color += lightTrace(world_tex, light_tex, player, ray, material.rme, material.tpo, i, max_reflections);
    }
    // Average ray colors over samples.
    final_color /= float(samples);
    first_ray_length /= float(samples);
    original_rmex /= float(samples);
    // if (samples != 1) glass_filter = 0.0;
    // Render all relevant information to 4 textures for the post processing shader
    render_color = vec4(mix(final_color * material.color, mod(final_color, 1.0), float(use_filter)), 1.0);
    // 16 bit HDR for improved filtering
    render_color_ip = vec4(floor(final_color) * INV_256, glass_filter);
    render_original_color = vec4(material.color * original_color, (material.rme.x + original_rmex + 0.0625 * material.tpo.x) * (first_ray_length + 0.06125));
		render_id += vec4(vertex_id.zw, (filter_roughness * 2.0 + material.rme.y) / 3.0, 0.0);
    render_original_id = vec4(vertex_id.zw, (filter_roughness * 2.0 + material.rme.y) / 3.0, original_tpox);
    float div = 4.0 * length(position - player);
    render_location_id = vec4(mod(position, div) / div, material.rme.z);
  }
  `;
  #firstFilterGlsl = `#version 300 es
  #define INV_256 0.00390625

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

    int center_id_w = int(center_id.w * 255.0);
    int center_light_num = center_id_w / 2;
    int center_shadow = center_id_w % 2;

    render_id = center_id;

    vec4 center_o_id = texelFetch(pre_render_original_id, texel, 0);
    vec4 color = vec4(0);
    float count = 0.0;

    const ivec2 stencil1[4] = ivec2[4](
                     ivec2(-1, 0), 
      ivec2( 0, -1),              ivec2( 0, 1),
                     ivec2( 1, 0)
    );

    const vec2 stencil3[37] = vec2[37](
                                  vec2(-3, -1), vec2(-3, 0), vec2(-3, 1), 
                    vec2(-2, -2), vec2(-2, -1), vec2(-2, 0), vec2(-2, 1), vec2(-2, 2),
      vec2(-1, -3), vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2), vec2(-1, 3),
      vec2( 0, -3), vec2( 0, -2), vec2( 0, -1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2), vec2( 0, 3),
      vec2( 1, -3), vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2), vec2( 1, 3),
                    vec2( 2, -2), vec2( 2, -1), vec2( 2, 0), vec2( 2, 1), vec2( 2, 2),
                                  vec2( 3, -1), vec2( 3, 0), vec2( 3, 1)
    );
    
    if (center_o_id.w > 0.0 && center_color_ip.w > 0.0) {
      vec4 id = center_id;

      mat4 ids = mat4(0);
      mat4 o_ids = mat4(0);

      vec4 ipws = vec4(0);
      for (int i = 0; i < 4; i++) {
        ids[i] = texelFetch(pre_render_id, texel + stencil1[i], 0);
        o_ids[i] = texelFetch(pre_render_original_id, texel + stencil1[i], 0);
        ipws[i] = texelFetch(pre_render_color_ip, texel + stencil1[i], 0).w;
      }

      ivec4 vote = ivec4(0);
      for (int i = 0; i < 4; i++) {
        if (ipws[i] == 0.0) {
          vote[i] = 1;
          if (ids[i].xyz == id.xyz && o_ids[i] == center_o_id) vote[i] ++;
          for (int j = i + 1; j < 4; j++) if (ids[i].xyz == ids[j].xyz && o_ids[i] == o_ids[j]) vote[i] ++;
        }
      }

      int max_vote = 0;
      int id_number = 0;

      for (int i = 0; i < 4; i++) {
        if (vote[i] >= max_vote) {
          max_vote = vote[i];
          id_number = i;
        }
      }
      
      render_id = ids[id_number];
      render_color_ip.w = 1.0 - sign(float(max_vote));
    }

    if (center_o_color.w == 0.0) {
      color = center_color;
      count = 1.0;
    } else {
      for (int i = 0; i < 37; i++) {
        ivec2 coord = texel + ivec2(stencil3[i] * (1.0 + center_o_color.w) * (1.0 + center_o_color.w) * 3.5);
        
        vec4 id = texelFetch(pre_render_id, coord, 0);
        vec4 original_id = texelFetch(pre_render_original_id, coord, 0);

        int id_w = int(id.w * 255.0);
        int light_num = id_w / 2;
        int shadow = id_w % 2;    

        vec4 next_color = texelFetch(pre_render_color, coord, 0);
        vec4 next_color_ip = texelFetch(pre_render_color_ip, coord, 0);
        if (id.xyz == center_id.xyz && (center_light_num != light_num || center_shadow == shadow)) {
          color += next_color + next_color_ip * 256.0;
          count ++;
        }
      }
    }
    
    
    float inv_count = 1.0 / count;
    render_color = sign(center_color.w) * vec4(mod(color.xyz * inv_count, 1.0), center_color.w);
    // Set out color for render texture for the antialiasing filter
    render_color_ip = sign(center_color.w) * vec4(floor(color.xyz * inv_count) * INV_256, render_color_ip.w);
  }
  `;
  #secondFilterGlsl = `#version 300 es
  #define INV_256 0.00390625
  
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

    const vec2 stencil[89] = vec2[89](
                                                              vec2(-5, -1), vec2(-5, 0), vec2(-5, 1),
                                  vec2(-4, -3), vec2(-4, -2), vec2(-4, -1), vec2(-4, 0), vec2(-4, 1), vec2(-4, 2), vec2(-4, 3),
                    vec2(-3, -4), vec2(-3, -3), vec2(-3, -2), vec2(-3, -1), vec2(-3, 0), vec2(-3, 1), vec2(-3, 2), vec2(-3, 3), vec2(-3, 4),
                    vec2(-2, -4), vec2(-2, -3), vec2(-2, -2), vec2(-2, -1), vec2(-2, 0), vec2(-2, 1), vec2(-2, 2), vec2(-2, 3), vec2(-2, 4),
      vec2(-1, -5), vec2(-1, -4), vec2(-1, -3), vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2), vec2(-1, 3), vec2(-1, 4), vec2(-1, 5),
      vec2( 0, -5), vec2( 0, -4), vec2( 0, -3), vec2( 0, -2), vec2( 0, -1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2), vec2( 0, 3), vec2( 0, 4), vec2( 0, 5),
      vec2( 1, -5), vec2( 1, -4), vec2( 1, -3), vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2), vec2( 1, 3), vec2( 1, 4), vec2( 1, 5),
                    vec2( 2, -4), vec2( 2, -3), vec2( 2, -2), vec2( 2, -1), vec2( 2, 0), vec2( 2, 1), vec2( 2, 2), vec2( 2, 3), vec2( 2, 4),
                    vec2( 3, -4), vec2( 3, -3), vec2( 3, -2), vec2( 3, -1), vec2( 3, 0), vec2( 3, 1), vec2( 3, 2), vec2( 3, 3), vec2( 3, 4),
                                  vec2( 4, -3), vec2( 4, -2), vec2( 4, -1), vec2( 4, 0), vec2( 4, 1), vec2( 4, 2), vec2( 4, 3),
                                                              vec2( 5, -1), vec2( 5, 0), vec2( 5, 1)
    );
    
    // Apply blur filter on image
    for (int i = 0; i < 89; i++) {
      ivec2 coord = texel + ivec2(stencil[i] * (1.0 + 2.0 * tanh(center_o_color.w + center_o_id.w * 4.0)));
      vec4 id = texelFetch(pre_render_id, coord, 0);
      vec4 next_o_id = texelFetch(pre_render_original_id, coord, 0);
      vec4 next_color = texelFetch(pre_render_color, coord, 0);
      vec4 next_color_ip = texelFetch(pre_render_color_ip, coord, 0);
      vec4 next_o_color = texelFetch(pre_render_original_color, coord, 0);

      if (min(center_o_id.w, next_o_id.w) > 0.1) {
        if (id == center_id || (max(next_color_ip.w, center_color_ip.w) != 0.0 && center_o_id.xyz == next_o_id.xyz)) {
          color += next_color + vec4(next_color_ip.xyz, 0.0) * 256.0;
          count ++;
          ipw += next_color_ip.w;
          o_color += next_o_color;
          o_count++;
        }
      }

      if (id.xyz == center_id.xyz) {
        color += next_color + vec4(next_color_ip.xyz, 0.0) * 256.0;
        count ++;
      }
    }

    float inv_count = 1.0 / count;
    render_color = center_color.w * vec4(mod(color.xyz * inv_count, 1.0), color.w * inv_count);
    // Set out color for render texture for the antialiasing filter
    render_color_ip =  center_color.w * vec4(floor(color.xyz * inv_count) * INV_256, ipw);
    render_original_color = center_color.w * ((o_count == 0.0) ? center_o_color : o_color / o_count);
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

    const vec2 stencil[89] = vec2[89](
                                                              vec2(-5, -1), vec2(-5, 0), vec2(-5, 1),
                                  vec2(-4, -3), vec2(-4, -2), vec2(-4, -1), vec2(-4, 0), vec2(-4, 1), vec2(-4, 2), vec2(-4, 3),
                    vec2(-3, -4), vec2(-3, -3), vec2(-3, -2), vec2(-3, -1), vec2(-3, 0), vec2(-3, 1), vec2(-3, 2), vec2(-3, 3), vec2(-3, 4),
                    vec2(-2, -4), vec2(-2, -3), vec2(-2, -2), vec2(-2, -1), vec2(-2, 0), vec2(-2, 1), vec2(-2, 2), vec2(-2, 3), vec2(-2, 4),
      vec2(-1, -5), vec2(-1, -4), vec2(-1, -3), vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2), vec2(-1, 3), vec2(-1, 4), vec2(-1, 5),
      vec2( 0, -5), vec2( 0, -4), vec2( 0, -3), vec2( 0, -2), vec2( 0, -1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2), vec2( 0, 3), vec2( 0, 4), vec2( 0, 5),
      vec2( 1, -5), vec2( 1, -4), vec2( 1, -3), vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2), vec2( 1, 3), vec2( 1, 4), vec2( 1, 5),
                    vec2( 2, -4), vec2( 2, -3), vec2( 2, -2), vec2( 2, -1), vec2( 2, 0), vec2( 2, 1), vec2( 2, 2), vec2( 2, 3), vec2( 2, 4),
                    vec2( 3, -4), vec2( 3, -3), vec2( 3, -2), vec2( 3, -1), vec2( 3, 0), vec2( 3, 1), vec2( 3, 2), vec2( 3, 3), vec2( 3, 4),
                                  vec2( 4, -3), vec2( 4, -2), vec2( 4, -1), vec2( 4, 0), vec2( 4, 1), vec2( 4, 2), vec2( 4, 3),
                                                              vec2( 5, -1), vec2( 5, 0), vec2( 5, 1)
    );

    // Apply blur filter on image
    for (int i = 0; i < 89; i++) {
      ivec2 coord = texel + ivec2(stencil[i] * (0.7 + 2.0 * tanh(center_o_color.w + center_o_id.w * 4.0)));
      vec4 id = texelFetch(pre_render_id, coord, 0);
      vec4 next_o_id = texelFetch(pre_render_original_id, coord, 0);
      vec4 next_color = texelFetch(pre_render_color, coord, 0);
      vec4 next_color_ip = texelFetch(pre_render_color_ip, coord, 0);
      vec4 next_o_color = texelFetch(pre_render_original_color, coord, 0);
      if (max(next_color_ip.w, center_color_ip.w) != 0.0 && min(center_o_id.w, next_o_id.w) >= 0.5 && center_o_id.xyz == next_o_id.xyz) {
        color += next_color + next_color_ip * 255.0;
        count ++;
        o_color += next_o_color;
        o_count++;
      } else if (id.xyz == center_id.xyz) {
        color += next_color + next_color_ip * 255.0;
        count ++;
      }
    }
    
    if (center_color.w > 0.0) {
      // Set out target_color for render texture for the antialiasing filter
      vec3 final_color = color.xyz / count;
      final_color *= (o_count == 0.0) ? center_o_color.xyz : o_color.xyz / o_count;

      if (hdr == 1) {
        // Apply Reinhard tone mapping
        final_color = final_color / (final_color + vec3(1.0));
        // Gamma correction
        float gamma = 0.8;
        final_color = pow(4.0 * final_color, vec3(1.0 / gamma)) / 4.0 * 1.3;
      }
      out_color = vec4(final_color, 1.0);
    } else {
      out_color = vec4(0);
    }
  }
  `;
  // Create new PathTracer from canvas and setup movement
  constructor (canvas, camera, scene) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.#gl = canvas.getContext('webgl2');
    this.halt = () => {
      try {
        this.#gl.loseContext();
      } catch (e) {
        console.warn("Unable to lose previous context, reload page in case of performance issue");
      }
      this.#halt = true;
    }
    this.#antialiasing = 'taa';
  }
  
  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
  }

  get antialiasing () {
    if (this.#antialiasing === null) return 'none';
    return this.#antialiasing;
  }

  set antialiasing (val) {
    switch (val.toLowerCase()) {
      case 'fxaa':
        this.#antialiasing = val;
        this.#AAObject = new FXAA(this.#gl);
        break;
      case 'taa':
        this.#antialiasing = val;
        this.#AAObject = new TAA(this.#gl);
        break;
      default:
        this.#antialiasing = null;
        this.#AAObject = null;
    }
  }

  // Functions to update texture atlases to add more textures during runtime
	async #updateAtlas (list) {
		// Test if there is even a texture
		if (list.length === 0) {
			this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, 1, 1, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, new Uint8Array(4));
			return;
		}

		const [width, height] = this.scene.standardTextureSizes;
		const textureWidth = Math.floor(2048 / width);
		const canvas = document.createElement('canvas');
		const ctx = canvas.getContext('2d');

		canvas.width = width * textureWidth;
		canvas.height = height * list.length;
		ctx.imageSmoothingEnabled = false;
		list.forEach(async (texture, i) => {
			// textureWidth for third argument was 3 for regular textures
			ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height);
		});

    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, canvas);
	}

  async #updateTextureAtlas () {
    // Don't build texture atlas if there are no changes.
    if (this.scene.textures.length === this.#textureList.length && this.scene.textures.every((e, i) => e === this.#textureList[i])) return;
    this.#textureList = this.scene.textures;

    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textureAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		this.#updateAtlas(this.scene.textures);
  }

  async #updatePbrAtlas () {
    // Don't build texture atlas if there are no changes.
    if (this.scene.pbrTextures.length === this.#pbrList.length && this.scene.pbrTextures.every((e, i) => e === this.#pbrList[i])) return;
    this.#pbrList = this.scene.pbrTextures;

    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#pbrAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		this.#updateAtlas(this.scene.pbrTextures);
  }

  async #updateTranslucencyAtlas () {
    // Don't build texture atlas if there are no changes.
    if (this.scene.translucencyTextures.length === this.#translucencyList.length && this.scene.translucencyTextures.every((e, i) => e === this.#translucencyList[i])) return;
    this.#translucencyList = this.scene.translucencyTextures;

    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#translucencyAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		this.#updateAtlas(this.scene.translucencyTextures);
  }

  // Functions to update vertex and light source data textures
  async updatePrimaryLightSources () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
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

  async updateScene () {
    let id = 0;
    // Set data variable for texels in world space texture
    var data = [];
    // Build simple AABB tree (Axis aligned bounding box)
    var fillData = async (item) => {
      if (Array.isArray(item) || item.indexable) {
        if (item.length === 0) return;

        let b = item.bounding;
        // Save position of len variable in array
        let len_pos = data.length;
        // Begin bounding volume array
        data.push(b[0], b[1], b[2], b[3], b[4], b[5], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        id++;
        // Iterate over all sub elements
        for (let i = 0; i < item.length; i++) fillData(item[i]);
        let len = Math.floor((data.length - len_pos) / 24);
        // Set now calculated vertices length of bounding box
        // to skip if ray doesn't intersect with it
        data[len_pos + 6] = len;
      } else {
        let len = item.length;
        // Test if bounding volume is set
        if (item.bounding !== undefined){
          // Declare bounding volume of object
          let b = item.bounding;
          data.push(b[0], b[1], b[2], b[3], b[4], b[5], len / 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
          id++;
        } else if (item.length > 3) {
          // Warn if length is greater than 3
          console.warn(item);
          // A single triangle needs no bounding voume, so nothing happens in this case
        }
        // Give item new id property to identify vertex in fragment shader
        item.ids = [];
        // console.log(id, item.textureArray);
        data.push(...item.textureArray);

        for (let i = 0; i < len * 3; i += 9) {
          let idHigh = Math.floor(id / 65535);
          let idLow = id % 65535;
          // 1 vertex = 1 line in world texture
          // a, b, c, color, normal, texture_nums, UVs1, UVs2
          item.ids.push(idHigh, idLow, idHigh, idLow, idHigh, idLow);
          id ++;
        }
      }
    }
    // Fill texture with data pixels
    for (let i = 0; i < this.scene.queue.length; i++) fillData(this.scene.queue[i]);
    // Round up data to next higher multiple of 6144 (8 pixels * 3 values * 256 vertecies per line)
    data.push(... new Array(6144 - data.length % 6144).fill(0));
    // console.log(data);
    // Calculate DataHeight by dividing value count through 6144 (8 pixels * 3 values * 256 vertecies per line)
    var dataHeight = data.length / 6144;
    // Manipulate actual webglfor (int i = 0; i < 4; i++) out_color += min(max(c[i], minRGB), maxRGB); texture
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#worldTexture);
    // Tell webgl to use 4 bytes per value for the 32 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2048, dataHeight, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(data));
  }

  async render() {
    // start rendering
    let rt = this;
    // Allow frame rendering
    rt.#halt = false;
    // Initialize internal globals of render functiod
    // The millis variable is needed to calculate fps and movement speed
    let TimeElapsed = performance.now();
    // Total frames calculated since last meassured
    let Frames = 0;
    let LastMeasuredFrames = 0;
    // Internal GL objects
    let Program, CameraPosition, Perspective, RenderConf, SamplesLocation, MaxReflectionsLocation, MinImportancyLocation, FilterLocation, HdrLocation, AmbientLocation, TextureWidth;
    let TempProgram, TempHdrLocation;
    let WorldTex, RandomTex, PbrTex, TranslucencyTex, Tex, LightTex;
    // Init Buffers
    let PositionBuffer, IdBuffer, TexBuffer;
    // Framebuffer, Post Program buffers and textures
    let Framebuffer, TempFramebuffer, OriginalIdRenderTexture;
    // Set post program array
    let PostProgram = [];
    // Create textures for Framebuffers in PostPrograms
    let RenderTexture = new Array(5);
    let IpRenderTexture = new Array(5);
    let DepthTexture = new Array(5);
    let OriginalRenderTexture = new Array(2);
    let IdRenderTexture = new Array(2);

    let TempTexture = new Array(this.temporalSamples);
    let TempIpTexture = new Array(this.temporalSamples);
    let TempIdTexture = new Array(this.temporalSamples);
    
    let TempTex = new Array(this.temporalSamples);
    let TempIpTex = new Array(this.temporalSamples);
    let TempIdTex = new Array(this.temporalSamples);

    for (let i = 0; i < this.temporalSamples; i++) {
      TempTexture[i] = this.#gl.createTexture();
      TempIpTexture[i] = this.#gl.createTexture();
      TempIdTexture[i] = this.#gl.createTexture();
    }

    let RenderTex = new Array(5);
    let IpRenderTex = new Array(5);
    let OriginalRenderTex = new Array(5);
    let IdRenderTex = new Array(5);
    let OriginalIdRenderTex = new Array(5);
    // Create caching textures for denoising
		for (let i = 0; i < 5; i ++) {
				RenderTexture[i] = this.#gl.createTexture();
				IpRenderTexture[i] = this.#gl.createTexture();
        if (i < 2) OriginalRenderTexture[i] = this.#gl.createTexture();
        if (i < 2) IdRenderTexture[i] = this.#gl.createTexture();
				DepthTexture[i] = this.#gl.createTexture();
    }
    // Create buffers for vertices in PostPrograms
    let PostVertexBuffer = new Array(5);
    let PostFramebuffer = new Array(5);
    // Create different Vaos for different rendering/filtering steps in pipeline
    let Vao = this.#gl.createVertexArray();

    let TempVao = this.#gl.createVertexArray();
		// Generate enough Vaos for each denoise pass
    let PostVao = new Array(5).map(() => this.#gl.createVertexArray());
    // Check if recompile is needed
    let State = [this.filter, this.renderQuality];
    // Function to handle canvas resize
    let resize = () => {
			const canvas = rt.canvas;
    	canvas.width = canvas.clientWidth * rt.renderQuality;
    	canvas.height = canvas.clientHeight * rt.renderQuality;
    	rt.#gl.viewport(0, 0, canvas.width, canvas.height);
      // Rebuild textures with every resize
      renderTextureBuilder();
      if (rt.#AAObject != null) this.#AAObject.buildTexture();

      rt.firstPasses = 1;
      rt.secondPasses = Math.max(1 + Math.round(Math.min(canvas.width, canvas.height) / 800), 2);
    }
    // Init canvas parameters and textures with resize
    resize();
    // Handle canvas resize
    window.addEventListener('resize', resize);

    function renderTextureBuilder(){
      for (let i = 0; i < rt.temporalSamples; i++) {
        rt.#randomTextures[i] = rt.#gl.createTexture();
        GLLib.randomTextureBuilder(rt.#gl.canvas.width / 4, rt.#gl.canvas.height / 4, rt.#gl, rt.#randomTextures[i]);
      }
      // Init textures for denoiser
      [TempTexture, TempIpTexture, TempIdTexture, RenderTexture, IpRenderTexture, OriginalRenderTexture, IdRenderTexture].forEach((parent) => {
        parent.forEach(function(item){
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
          rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGBA, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGBA, rt.#gl.UNSIGNED_BYTE, null);
          GLLib.setTexParams(rt.#gl);
        });
      });
      // Init single channel depth textures
      DepthTexture.forEach((item) => {
        rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.DEPTH_COMPONENT24, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.DEPTH_COMPONENT, rt.#gl.UNSIGNED_INT, null);
        GLLib.setTexParams(rt.#gl);
      });
      // Init other textures
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, OriginalIdRenderTexture);
      rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGBA, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGBA, rt.#gl.UNSIGNED_BYTE, null);
      GLLib.setTexParams(rt.#gl);
    }

    // Internal render engine Functions
    function frameCycle (Millis) {
      // generate bounding volumes
      rt.scene.updateBoundings();
      // Update Textures
      rt.#updateTextureAtlas();
      rt.#updatePbrAtlas();
      rt.#updateTranslucencyAtlas();
      // set world-texture
      rt.updateScene();
      // build bounding boxes for scene first
      rt.updatePrimaryLightSources();
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
      renderFrame();
      // Update frame counter
      Frames ++;
      // Calculate Fps
			const timeDifference = Millis - TimeElapsed;
      if (timeDifference > 50) {
        rt.fps = (1000 * (Frames - LastMeasuredFrames) / timeDifference).toFixed(0);
        [TimeElapsed, LastMeasuredFrames] = [Millis, Frames];
      }
    }

    let A = new TAA(this.#gl, this);;

    function texturesToGPU() {
      let [jitterX, jitterY] = [0, 0];
      if (rt.#antialiasing !== null && (rt.#antialiasing.toLocaleLowerCase() === 'taa')) {
        let jitter = rt.#AAObject.jitter(rt.#canvas);
        [jitterX, jitterY] = [jitter.x, jitter.y];
      }

      rt.#gl.bindVertexArray(Vao);
      rt.#gl.useProgram(Program);

      rt.#gl.activeTexture(rt.#gl.TEXTURE0);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#worldTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE1);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#randomTextures[rt.temporal ? Frames % rt.temporalSamples : 0]);
      rt.#gl.activeTexture(rt.#gl.TEXTURE2);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#pbrAtlas);
      rt.#gl.activeTexture(rt.#gl.TEXTURE3);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#translucencyAtlas);
      rt.#gl.activeTexture(rt.#gl.TEXTURE4);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#textureAtlas);
      rt.#gl.activeTexture(rt.#gl.TEXTURE5);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#lightTexture);
      // Set uniforms for shaders
      // Set 3d camera position
      rt.#gl.uniform3f(CameraPosition, rt.camera.x, rt.camera.y, rt.camera.z);
      // Set x and y rotation of camera
      rt.#gl.uniform2f(Perspective, rt.camera.fx, rt.camera.fy);
      // Set fov and X/Y ratio of screen
      rt.#gl.uniform4f(RenderConf, rt.camera.fov, rt.#gl.canvas.width / rt.#gl.canvas.height, jitterX, jitterY);
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

    async function fillBuffers() {
      let vertices = [];
      let ids = [];
      let uvs = [];
      let id = 0;
      let bufferLength = 0;
      // Iterate through render queue and build arrays for GPU
      var flattenQUEUE = (item) => {
        if (Array.isArray(item) || item.indexable){
          // Iterate over all sub elements
          for (let i = 0; i < item.length; i++){
            // flatten sub element of queue
            flattenQUEUE(item[i]);
          }
        } else {
          id ++;
          for(let i = 0; i < item.ids.length; i += 2) ids.push(item.ids[i], item.ids[i + 1], (id % 65535) / 65535, (id % 255) / 255);
          vertices.push(...item.vertices);
          uvs.push(...item.uvs);
          bufferLength += item.length;
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
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, new Float32Array(item[1]), rt.#gl.DYNAMIC_DRAW);
      });
      // Actual drawcall
      rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, bufferLength);
    }

    let renderFrame = () => {
      // Configure where the final image should go
      if (rt.temporal || rt.filter || rt.#antialiasing) {
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, Framebuffer);
        rt.#gl.drawBuffers([
          rt.#gl.COLOR_ATTACHMENT0,
          rt.#gl.COLOR_ATTACHMENT1,
          rt.#gl.COLOR_ATTACHMENT2,
          rt.#gl.COLOR_ATTACHMENT3,
          rt.#gl.COLOR_ATTACHMENT4,
          rt.#gl.COLOR_ATTACHMENT5
        ]);
  
        // Configure framebuffer for color and depth
        if (rt.temporal) {
          // Rotate textures for temporal filter
          TempTexture.unshift(TempTexture.pop());
          TempIpTexture.unshift(TempIpTexture.pop());
          TempIdTexture.unshift(TempIdTexture.pop());

          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, TempTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, TempIpTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT3, rt.#gl.TEXTURE_2D, IdRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT4, rt.#gl.TEXTURE_2D, OriginalIdRenderTexture, 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT5, rt.#gl.TEXTURE_2D, TempIdTexture[0], 0);
        } else if (rt.filter) {
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT3, rt.#gl.TEXTURE_2D, IdRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT4, rt.#gl.TEXTURE_2D, OriginalIdRenderTexture, 0);
        } else if (rt.#antialiasing) {
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        }
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.DEPTH_ATTACHMENT, rt.#gl.TEXTURE_2D, DepthTexture[0], 0);
        
      } else {
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, null);
      }

      // Clear depth and color buffers from last frame
      rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
      texturesToGPU();
      fillBuffers();

      if (rt.temporal) {
        if (rt.filter || rt.#antialiasing) {
            // Temporal sample averaging
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, TempFramebuffer);
          // Set attachments to use for framebuffer
          rt.#gl.drawBuffers([
            rt.#gl.COLOR_ATTACHMENT0,
            rt.#gl.COLOR_ATTACHMENT1
          ]);

          // Configure framebuffer for color and depth
          if (rt.filter) {
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[0], 0);
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[0], 0);
          } else if (rt.#antialiasing) {
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
          }
        } else {
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, null);
        }
        
        // Clear depth and color buffers from last frame
        rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);

        [TempTexture, TempIpTexture, TempIdTexture].flat().forEach(function(item, i){
          rt.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        });

        rt.#gl.bindVertexArray(TempVao);
        rt.#gl.useProgram(TempProgram);

        rt.#gl.uniform1i(TempHdrLocation, rt.hdr);

        for (let i = 0; i < rt.temporalSamples; i++) {
          rt.#gl.uniform1i(TempTex[i], i);
          rt.#gl.uniform1i(TempIpTex[i], rt.temporalSamples + i);
          rt.#gl.uniform1i(TempIdTex[i], 2 * rt.temporalSamples + i);
        }
        
        // PostTemporal averaging processing drawcall
        rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
      }

      if (rt.filter) {
        // Apply post processing filter
        let n = 0;
        let nId = 0;
        let nOriginal = 0;
        for (let i = 0; i < rt.firstPasses + rt.secondPasses; i++) {
          // Look for next free compatible program slot
          let np = (i % 2) ^ 1;
          let npOriginal = ((i - rt.firstPasses) % 2) ^ 1;
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
          if (rt.firstPasses <= i - 2) rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[npOriginal], 0);
          else rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, IdRenderTexture[np], 0);
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
          // Pass pre rendered texture to shader
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

          if (rt.firstPasses <= i) nOriginal = npOriginal;
          else nId = np;
        }

        // Last denoise pass
        rt.#gl.drawBuffers([rt.#gl.COLOR_ATTACHMENT0, rt.#gl.COLOR_ATTACHMENT1]);
        // Configure framebuffer for color and depth
        if (rt.#antialiasing) {
          // Configure where the final image should go
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, PostFramebuffer[4]);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
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
      if (rt.#antialiasing) this.#AAObject.renderFrame();
    }

    let prepareEngine = () => {
      let newLine = `
      `;
      // Build tempShader
      this.#tempGlsl = `#version 300 es
      precision highp float;
      in vec2 clip_space;
      uniform int hdr;
      `;

      for (let i = 0; i < rt.temporalSamples; i++) {
        this.#tempGlsl += 'uniform sampler2D cache_' + i + ';' + newLine;
        this.#tempGlsl += 'uniform sampler2D cache_ip_' + i + ';' + newLine;
        this.#tempGlsl += 'uniform sampler2D cache_id_' + i + ';' + newLine;
      }

      this.#tempGlsl += `
      layout(location = 0) out vec4 render_color;
      layout(location = 1) out vec4 render_color_ip;
    
      void main () {
        ivec2 texel = ivec2(vec2(textureSize(cache_0, 0)) * clip_space);
        vec4 id = texelFetch(cache_id_0, texel, 0);
        float counter = 1.0;
        
        float center_w = texelFetch(cache_0, texel, 0).w;
      `;

      this.#tempGlsl += rt.filter ? `
        vec3 color = texelFetch(cache_0, texel, 0).xyz + texelFetch(cache_ip_0, texel, 0).xyz * 256.0;
        float glass_filter = texelFetch(cache_ip_0, texel, 0).w;
      ` : `
        vec3 color = texelFetch(cache_0, texel, 0).xyz;` + newLine;

      for (let i = 1; i < rt.temporalSamples; i += 4) {
        this.#tempGlsl += 'mat4 c' + i + ' = mat4(';
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cache_' + j + ', texel, 0),' : 'vec4(0),') + newLine;
        this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cache_' + (i + 3) + ', texel, 0) ' + newLine + ' ); ' : 'vec4(0) ' + newLine + '); ') + newLine;
        if (rt.filter) {
          this.#tempGlsl += 'mat4 ip' + i + ' = mat4(';
          for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cache_ip_' + j + ', texel, 0),' : 'vec4(0),') + newLine;
          this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cache_ip_' + (i + 3) + ', texel, 0) ' + newLine + '); ' : 'vec4(0) ' + newLine + '); ') + newLine;
        }
        this.#tempGlsl += 'mat4 id' + i + ' = mat4(';
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cache_id_' + j + ', texel, 0),' : 'vec4(0),') + newLine;
        this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cache_id_' + (i + 3) + ', texel, 0) ' + newLine + '); ' : 'vec4(0) ' + newLine + '); ') + newLine;
        this.#tempGlsl += rt.filter ? `
        for (int i = 0; i < 4; i++) if (id` + i + `[i].xyz == id.xyz) {
          color += c` + i + `[i].xyz + ip` + i + `[i].xyz * 256.0;
          counter ++;
        }
        for (int i = 0; i < 4; i++) glass_filter += ip` + i + `[i].w;
        ` : `
        for (int i = 0; i < 4; i++) if (id` + i + `[i].xyz == id.xyz) {
          color += c` + i + `[i].xyz;
          counter ++;
        }
        `;
      }

      this.#tempGlsl += 'color /= counter;' + newLine;

      this.#tempGlsl += rt.filter ? `
        render_color = vec4(mod(color, 1.0), center_w);
        // 16 bit HDR for improved filtering
        render_color_ip = vec4(floor(color) / 256.0, glass_filter);
      }` : `
        if (hdr == 1) {
          // Apply Reinhard tone mapping
          color = color / (color + vec3(1));
          // Gamma correction
          float gamma = 0.8;
          color = pow(4.0 * color, vec3(1.0 / gamma)) / 4.0 * 1.3;
          render_color = vec4(color, center_w);
        } else {
          render_color = vec4(color, center_w);
        }
        render_color = vec4(color, center_w);
      }`;
      // Force update textures by resetting texture Lists
      rt.#textureList = [];
      rt.#pbrList = [];
      rt.#translucencyList = [];
      // Compile shaders and link them into Program global
      Program = GLLib.compile (rt.#gl, rt.#vertexGlsl, rt.#fragmentGlsl);
      TempProgram = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#tempGlsl);
      // Compile shaders and link them into PostProgram global
      for (let i = 0; i < 2; i++) PostProgram[i] = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#firstFilterGlsl);
      // Compile shaders and link them into PostProgram global
      for (let i = 2; i < 4; i++) PostProgram[i] = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#secondFilterGlsl);
      // Compile shaders and link them into PostProgram global
      PostProgram[4] = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#finalFilterGlsl);
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
      rt.#gl.disable(rt.#gl.BLEND);
      rt.#gl.enable(rt.#gl.DEPTH_TEST);
      rt.#gl.depthMask(true);
      // Cull (exclude from rendering) hidden vertices at the other side of objects
      rt.#gl.enable(rt.#gl.CULL_FACE);
      // Set clear color for framebuffer
      rt.#gl.clearColor(0, 0, 0, 0);
      // Define Program with its currently bound shaders as the program to use for the webgl2 context
      rt.#gl.useProgram(Program);
      rt.#pbrAtlas = rt.#gl.createTexture();
      rt.#translucencyAtlas = rt.#gl.createTexture();
      rt.#textureAtlas = rt.#gl.createTexture();
      // Create texture for all primary light sources in scene
      rt.#lightTexture = rt.#gl.createTexture();
      // Init a world texture containing all information about world space
      rt.#worldTexture = rt.#gl.createTexture();
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

      rt.#gl.bindVertexArray(TempVao);
      rt.#gl.useProgram(TempProgram);
      TempHdrLocation = rt.#gl.getUniformLocation(TempProgram, 'hdr');

      for (let i = 0; i < rt.temporalSamples; i++) {
        TempTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cache_' + i);
        TempIpTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cache_ip_' + i);
        TempIdTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cache_id_' + i);
      }
      
      let TempVertexBuffer = rt.#gl.createBuffer();
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, TempVertexBuffer);
      rt.#gl.enableVertexAttribArray(0);
      rt.#gl.vertexAttribPointer(0, 2, rt.#gl.FLOAT, false, 0, 0);
      // Fill buffer with data for two verices
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, TempVertexBuffer);
      rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), rt.#gl.DYNAMIC_DRAW);
      TempFramebuffer = rt.#gl.createFramebuffer();

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
      if (rt.#antialiasing !== null) {
        switch (this.#antialiasing.toLowerCase()) {
          case "fxaa":
            this.#AAObject = new FXAA(rt.#gl);
            break;
          case "taa":
            this.#AAObject = new TAA(rt.#gl);
            break;
          default:
            this.#AAObject = null;
        }
      } else {
        this.#AAObject = null;
      }
    }
    // Prepare Renderengine
    prepareEngine();
    // Begin frame cycle
    frameCycle();
  }
}
