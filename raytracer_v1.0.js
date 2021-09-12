"use strict";

const RayTracer = (target_canvas) => {
  var RT = {
    // Initialize Gl context variable.
    GL: target_canvas.getContext("webgl2"),
    // Configurable runtime properties of the Raytracer.
    QUEUE: [],
    LIGHT: [[0, 10, 0]],
    GI: [0.05, 0.05, 0.05],
    TEXTURE: [],
    NORMAL_TEXTURE: [],
    TEXTURE_SIZES: [512, 512],
    // Quality settings.
    SAMPLES: 1,
    SCALE: 1,
    REFLECTIONS: 3,
    FILTER: true,
    // Camera and frustrum settings.
    FOV: Math.PI,
    X: -12, Y: 5, Z: -18,
    FX: 0.440, FY: 0.235,
    // Movement settings.
    MOUSE_ROTATION: true,
    MOVEMENT: true,
    MOVEMENT_SPEED: 0.1,
    MOUSE_Y: 1 / 500, MOUSE_X: 1 / 500,
    KEYMAP: [["w", 0, 0, 1], ["s", 0, 0, -1], ["a", 1, 0, 0], ["d", -1, 0, 0], [" ", 0, 1, 0], ["shift", 0, -1, 0]],
    // Performance metric.
    FPS: 0,
    // Init scene state GL textures.
    NormalTexture: null,
    ColorTexture: null,
    LightTexture: null,
    // Functions to update scene states.
    UPDATE_NORMAL: () => {
      // Test if there is even a texture.
      if (RT.NORMAL_TEXTURE.length === 0) return;

      RT.GL.bindTexture(RT.GL.TEXTURE_2D, RT.NormalTexture);
      RT.GL.pixelStorei(RT.GL.UNPACK_ALIGNMENT, 1);
      // Set data texture details and tell webgl, that no mip maps are required.
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);

      let [width, height] = RT.TEXTURE_SIZES;
      let textureWidth = Math.floor(2048 / RT.TEXTURE_SIZES[0]);

      var canvas = document.createElement('canvas');
      var ctx = canvas.getContext('2d');
      canvas.width = width * textureWidth;
      canvas.height = height * RT.TEXTURE.length;

      RT.NORMAL_TEXTURE.forEach(async (item, i) => {
          ctx.drawImage(item, width*(i%textureWidth), height*Math.floor(i/3), width, height);
      });
      RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, canvas.width, canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, new Uint8Array(Array.from(ctx.getImageData(0, 0, canvas.width, canvas.height).data)));
    },
    UPDATE_TEXTURE: () => {
      // Test if there is even a texture.
      if (RT.TEXTURE.length === 0) return;

      RT.GL.bindTexture(RT.GL.TEXTURE_2D, RT.ColorTexture);
      RT.GL.pixelStorei(RT.GL.UNPACK_ALIGNMENT, 1);
      // Set data texture details and tell webgl, that no mip maps are required.
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);

      let [width, height] = RT.TEXTURE_SIZES;
      let textureWidth = Math.floor(2048 / RT.TEXTURE_SIZES[0]);

      var canvas = document.createElement('canvas');
      var ctx = canvas.getContext('2d');
      canvas.width = width * textureWidth;
      canvas.height = height * RT.TEXTURE.length;

      RT.TEXTURE.forEach(async (item, i) => {
          ctx.drawImage(item, width*(i%textureWidth), height*Math.floor(i/3), width, height);
      });

      RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, canvas.width, canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, new Uint8Array(Array.from(ctx.getImageData(0, 0, canvas.width, canvas.height).data)));
    },
    UPDATE_LIGHT: () => {
      RT.GL.bindTexture(RT.GL.TEXTURE_2D, RT.LightTexture);
      RT.GL.pixelStorei(RT.GL.UNPACK_ALIGNMENT, 1);
      // Set data texture details and tell webgl, that no mip maps are required.
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
      RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);

      var LightTexArray = [];
      // Iterate over light sources and default strength value if not set.
      for(let i = 0; i < RT.LIGHT.length; i++)
      {
        // Set default value.
        let strength = 5;
        // Overwrite default if set.
        if(typeof(RT.LIGHT[i].strength) !== "undefined") strength = RT.LIGHT[i].strength;
        // Push light location to Texture.
        LightTexArray.push(RT.LIGHT[i][0], RT.LIGHT[i][1], RT.LIGHT[i][2]);
        // Push strength and 0, 0 to texture, because RGB texture format needs 3x values per row.
        LightTexArray.push(strength, 0, 0);
      }
      RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGB32F, 2, RT.LIGHT.length, 0, RT.GL.RGB, RT.GL.FLOAT, new Float32Array(LightTexArray));
    },
    // Start function for engine.
    START: async () => {
      const vertex_glsl = `#version 300 es

      in vec3 position_3d;
      in vec3 normal_3d;
      in vec2 tex_pos;
      in vec4 color_3d;

      in vec2 texture_nums_3d;
      in vec2 texture_sizes_3d;

      uniform vec3 camera_position;
      uniform vec2 perspective;
      uniform vec4 conf;

      out vec3 position;
      out vec2 tex_coord;
      out vec3 clip_space;

      flat out vec4 color;
      flat out vec3 normal;
      flat out vec3 player;
      flat out int vertex_id;
      flat out vec2 texture_nums;

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
        vec2 translate_2d = conf.x * vec2(translate_px.x, translate_py.x * conf.y);
        // Set final clip space position.
        gl_Position = vec4(translate_2d, - 0.99 / (1.0 + exp(- length(move_3d / 10000000000.0))), translate_py.y);
        vertex_id = gl_VertexID;
        clip_space = vec3(translate_2d, translate_py.y);
        player = camera_position * vec3(-1.0, 1.0, 1.0);
        position = position_3d;
        normal = normalize(normal_3d);
        tex_coord = tex_pos;
        texture_nums = texture_nums_3d;
        color = color_3d;
      }
      `;
      const fragment_glsl = `#version 300 es

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
      float first_ray_length = 256.0;

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
        if(s > l || s <= shadow_bias) return vec4_null;
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
        if((u > shadow_bias) && (v > shadow_bias) && (u + v < 1.0 - shadow_bias)){
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

          if(i == 0) first_ray_length = length(intersection.xyz - last_position);
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
              vec2 random_coord = mod(((clip_space.xy / clip_space.z) + 1.0) * cos(float(i)), 1.0);
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
            // forwardTrace(rough_normal, tex_color.xyz, normalize(light - position),light * vec3(-1.0, 1.0, 1.0), player, position, strength);
          }
        }

        // Render all relevant information to 4 textures for the post processing shader.
        if(use_filter == 1){
          render_color = vec4(final_color / float(samples), first_in_shadow + 1.0 / 256.0);
        }else{
          render_color = vec4(final_color / float(samples), 1.0);
        }
        // Render all relevant information to 4 textures for the post processing shader.
        render_color = vec4(final_color / float(samples), 1.0);
        render_normal = vec4(normal / 2.0 + 0.5, first_in_shadow);
        render_original_color = vec4(tex_color.xyz, roughness * (first_ray_length + 1.0/4.0));
        render_id = vec4(1.0 / vec3(float((vertex_id/3)%16777216), float((vertex_id/3)%65536), float((vertex_id/3)%256)), 0.0);
      }
      `;
      const post_vertex_glsl = `#version 300 es

      in vec2 position_2d;
      // Pass clip space position to fragment shader.
      out vec2 clip_space;

      void main(){
        vec2 pos = position_2d * 2.0 - 1.0;
        // Set final clip space position.
        gl_Position = vec4(pos, 0, 1);
        clip_space = position_2d;
      }
      `;
      const post_fragment_glsl = `#version 300 es

      precision highp float;
      in vec2 clip_space;

      uniform sampler2D pre_render_color;
      uniform sampler2D pre_render_normal;
      uniform sampler2D pre_render_original_color;
      uniform sampler2D pre_render_id;

      out vec4 out_color;

      void main(){

        // Get texture size.
        ivec2 texel = ivec2(vec2(textureSize(pre_render_color, 0)) * clip_space);

        vec4 center_color = texelFetch(pre_render_color, texel, 0);
        vec4 center_normal = texelFetch(pre_render_normal, texel, 0);
        vec4 center_original_color = texelFetch(pre_render_original_color, texel, 0);
        vec4 center_id = texelFetch(pre_render_id, texel, 0);

        vec4 color = center_color;
        float count = 1.0;
        int increment = 3;
        int max_radius = 10;
        int radius = int(sqrt(float(textureSize(pre_render_color, 0).x * textureSize(pre_render_color, 0).y)) * 0.06 * center_original_color.w);
        // Force max radius.
        if(radius > max_radius) radius = max_radius;

        // Apply blur filter on image.
        for(int i = 0; i < radius; i++){
          for(int j = 0; j < radius; j++){

            ivec2 coords = ivec2(vec2(texel) + vec2(i, j) * float(increment) - float(radius * increment / 2));
            vec4 next_color = texelFetch(pre_render_color, coords, 0);
            vec4 normal = texelFetch(pre_render_normal, coords, 0);
            vec4 original_color = texelFetch(pre_render_original_color, coords, 0);
            vec4 id = texelFetch(pre_render_id, coords, 0);

            if (
              normal == center_normal
              && original_color.xyz == center_original_color.xyz
              && (
                center_id == id
                || round(center_color.xyz - next_color.xyz) == vec3(0.0, 0.0, 0.0)
              )
            ){
              color += next_color;
              count ++;
            }
          }
        }
        if (color.w > 0.0){
          // Set out color for render texture for the antialiasing filter.
          out_color = vec4(color.xyz / count, 1.0);
        }else{
          out_color = vec4(0.0, 0.0, 0.0, 0.0);
        }
      }
      `;
      const kernel_glsl = `#version 300 es

      precision highp float;
      in vec2 clip_space;
      uniform sampler2D pre_render;
      out vec4 out_color;

      void main(){

        int kernel[12] = int[12](
             1, 2, 1,
             2, 4, 2,
             1, 2, 1,
             0, 0, 0
        );

        // Get texture size.
        vec2 texel = vec2(textureSize(pre_render, 0)) * clip_space;

        vec4 original_color = texelFetch(pre_render, ivec2(texel), 0);
        vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
        float count = 0.0;
        int increment = 1;
        int radius = 3;

        // Apply 3x3 kernel on image.
        for(int i = 0; i < radius; i++){
          for(int j = 0; j < radius; j++){
            vec4 next_color = texelFetch(pre_render, ivec2(texel + vec2(i, j) - float(radius/2)), 0);
              color += next_color * float(kernel[i%3+j]);
              count += float(kernel[i%3+j]);
          }
        }
        if(original_color.w != 0.0){
          out_color = color / count;
        }else{
          out_color = vec4(0.0, 0.0, 0.0, 0.0);
        }
      }
      `;
      // Initialize internal globals.
      {
        // Initialize performance metric globals.
        var Frame = 0;
        // The micros variable is needed to calculate fps.
        var Micros = window.performance.now();
        // Internal GL objects.
        var Program;
        var CameraPosition;
        var Perspective;
        var RenderConf;
        var SamplesLocation;
        var ReflectionsLocation;
        var FilterLocation;
        var GILocation;
        var TextureWidth;
        var WorldTex;
        var RandomTex;
        var NormalTex;
        var ColorTex;
        var LightTex;
        // Init Buffers.
        var PositionBuffer;
        var NormalBuffer;
        var TexBuffer;
        var ColorBuffer;
        var TexSizeBuffer;
        var TexNumBuffer;
        var SurfaceBuffer;
        var TriangleBuffer;
        // Init Texture elements.
        var WorldTexture;
        var RandomTexture;
        var Random;
        // Linkers for GLATTRIBARRAYS.
        var Position = 0;
        var Normal = 1;
        var TexCoord = 2;
        var Color = 3;
        var TexNum = 4;
        // List of all vertices currently in world space.
        var Data = [];
        var DataHeight = 0;
        // Post Program.
        var Framebuffer;
        var PostProgram;
        var PostPosition = 0;
        var PostVertexBuffer;
        var ColorRenderTexture;
        var ColorRenderTex;
        var NormalRenderTexture;
        var NormalRenderTex;
        var OriginalRenderTexture;
        var OriginalRenderTex;
        var IdRenderTexture;
        var IdRenderTex;
        var DepthTexture;
        // Convolution-kernel program.
        var PostFramebuffer;
        var KernelProgram;
        var KernelPosition = 0;
        var KernelVertexBuffer;
        var KernelTexture;
        var KernelTex;
        // Create different VAOs for different rendering/filtering steps in pipeline.
        var VAO = RT.GL.createVertexArray();
        var POST_VAO = RT.GL.createVertexArray();
        var KERNEL_VAO = RT.GL.createVertexArray();
        // Momentary rotation change.
        var DeltaX = 0;
        var DeltaY = 0;
        var DeltaZ = 0;
        // Store pressed keys in this to handle multikey input.
        var KeysPressed = [];
        // current pointer lock state.
        var PointerLocked = false;
      }
      // Add eventlisteners for movement and rotation.
      {
        window.addEventListener("keydown", function(event){
          if(!KeysPressed.includes(event.key.toLowerCase()))
          {
            KeysPressed.push(event.key.toLowerCase());
          }
        });
        // Remove keys from list if they are not longer pressed.
        window.addEventListener("keyup", function(event){
          KeysPressed.forEach((item, i) => {
            if (item === event.key.toLowerCase())
            {
              KeysPressed.splice(i, 1);
            }
          });
        });
        // Change perspective on mouse movement and lock pointer to screen.
        document.addEventListener('pointerlockchange', function(){
          PointerLocked = !PointerLocked;
          KeysPressed = [];
        });
        // Start pointer lock with click on canvas.
        target_canvas.addEventListener("click", function (event) {
            event.target.requestPointerLock();
        });
        // Detect mouse movements.
        document.addEventListener("pointermove", function (event) {
            if (PointerLocked && RT.MOUSE_ROTATION)
            {
              RT.FX -= RT.MOUSE_X * event.movementX;
              if (Math.abs(RT.FY + RT.MOUSE_Y * event.movementY) < Math.PI / 2) RT.FY += RT.MOUSE_Y * event.movementY;
            }
        });
        // Handle canvas resize.
        window.addEventListener("resize", function(){
        	resize();
        	// Rebuild textures with every resize.
        	randomTextureBuilder();
        	renderTextureBuilder();
        	postRenderTextureBuilder();
        });
        // Function to handle canvas resize.
        function resize(){
        	target_canvas.width = target_canvas.clientWidth * RT.SCALE;
        	target_canvas.height = target_canvas.clientHeight * RT.SCALE;
        	RT.GL.viewport(0, 0, RT.GL.canvas.width, RT.GL.canvas.height);
          // Generate Random variable after each resize.
        	Random = [];
        	for (let i = 0; i < RT.GL.canvas.width * RT.GL.canvas.height * 3; i++) Random.push(Math.random() * 256);
        }
        // Init canvas parameters with resize.
        resize();
      }
      // Update movement with 60Hz.
      setInterval(
        async function(){
        if (RT.MOVEMENT)
        {
          evalKeys();
          RT.X += DeltaX * Math.cos(RT.FX) + DeltaZ * Math.sin(RT.FX);
          RT.Y += DeltaY;
          RT.Z += DeltaZ * Math.cos(RT.FX) - DeltaX * Math.sin(RT.FX);
        }
        },
        100/6
      );
      // Handle new keyboard input.
      async function evalKeys(){
        if (PointerLocked)
        {
          let [x, y, z] = [0, 0, 0];
          RT.KEYMAP.forEach((item, i) => {
            if (KeysPressed.includes(item[0]))
            {
              x += item[1] * RT.MOVEMENT_SPEED;
              y += item[2] * RT.MOVEMENT_SPEED;
              z += item[3] * RT.MOVEMENT_SPEED;
            }
          });
          if (x !== DeltaX || y !== DeltaY || z !== DeltaZ)
          {
            DeltaX = x;
            DeltaY = y;
            DeltaZ = z;
          }
        }
      }
      async function buildProgram(shaders){
        // Create Program, compile and append vertex and fragment shader to it.
        let program = RT.GL.createProgram();
        // Compile GLSL shaders.
        await shaders.forEach(async (item, i) => {
          let shader = RT.GL.createShader(item.type);
          RT.GL.shaderSource(shader, item.source);
          RT.GL.compileShader(shader);
          // Append shader to Program if GLSL compiled successfully.
          if (RT.GL.getShaderParameter(shader, RT.GL.COMPILE_STATUS))
          {
            RT.GL.attachShader(program, shader);
          }
          else
          {
            // Log debug info and delete shader if shader fails to compile.
            console.warn(RT.GL.getShaderInfoLog(shader));
            RT.GL.deleteShader(shader);
          }
        });
        RT.GL.linkProgram(program);
        // Return Program if it links successfully.
        if (!RT.GL.getProgramParameter(program, RT.GL.LINK_STATUS))
        {
          // Log debug info and delete Program if Program fails to link.
          console.warn(RT.GL.getProgramInfoLog(program));
          RT.GL.deleteProgram(program);
        }
        else
        {
          return program;
        }
      }
      function worldTextureBuilder(){
        RT.GL.bindTexture(RT.GL.TEXTURE_2D, WorldTexture);
        // Reset old world space texture.
        Data = [];
        // Fill texture with data pixels.
        for(let i = 0; i < RT.QUEUE.length; i++) fillData(RT.QUEUE[i]);
        // Calculate DataHeight.
        DataHeight = Data.length / 24;
        // Tell webgl to use 4 bytes per value for the 32 bit floats.
        RT.GL.pixelStorei(RT.GL.UNPACK_ALIGNMENT, 4);
        // Set data texture details and tell webgl, that no mip maps are required.
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGB32F, 8, DataHeight, 0, RT.GL.RGB, RT.GL.FLOAT, new Float32Array(Data));
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
      }
      function randomTextureBuilder(){
        RT.GL.bindTexture(RT.GL.TEXTURE_2D, RandomTexture);
        // Fill texture with pseudo random pixels.
        // Tell webgl to use 1 byte per value for the 8 bit ints.
        RT.GL.pixelStorei(RT.GL.UNPACK_ALIGNMENT, 1);
        // Set data texture details and tell webgl, that no mip maps are required.
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.LINEAR_MIPMAP_LINEAR);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.LINEAR_MIPMAP_LINEAR);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGB8, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.RGB, RT.GL.UNSIGNED_BYTE, new Uint8Array(Random));
        RT.GL.generateMipmap(RT.GL.TEXTURE_2D);
      }
      function renderTextureBuilder(){
        RT.GL.bindTexture(RT.GL.TEXTURE_2D, ColorRenderTexture);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, null);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);

        RT.GL.bindTexture(RT.GL.TEXTURE_2D, NormalRenderTexture);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, null);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);

        RT.GL.bindTexture(RT.GL.TEXTURE_2D, OriginalRenderTexture);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, null);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);

        RT.GL.bindTexture(RT.GL.TEXTURE_2D, IdRenderTexture);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, null);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);

        RT.GL.bindTexture(RT.GL.TEXTURE_2D, DepthTexture);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.DEPTH_COMPONENT24, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.DEPTH_COMPONENT, RT.GL.UNSIGNED_INT, null);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);
      }
      function postRenderTextureBuilder(){
        RT.GL.bindTexture(RT.GL.TEXTURE_2D, KernelTexture);
        RT.GL.texImage2D(RT.GL.TEXTURE_2D, 0, RT.GL.RGBA, RT.GL.canvas.width, RT.GL.canvas.height, 0, RT.GL.RGBA, RT.GL.UNSIGNED_BYTE, null);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MIN_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_MAG_FILTER, RT.GL.NEAREST);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_S, RT.GL.CLAMP_TO_EDGE);
        RT.GL.texParameteri(RT.GL.TEXTURE_2D, RT.GL.TEXTURE_WRAP_T, RT.GL.CLAMP_TO_EDGE);
      }
      // Build simple AABB tree (Axis aligned bounding box).
      async function fillData(item){
        if(Array.isArray(item))
        {
          let b = item[0];
          // Save position of len variable in array.
          let len_pos = Data.length;
          // Begin bounding volume array.
          Data.push(b[0],b[1],b[2],b[3],b[4],b[5],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          // Iterate over all sub elements and skip bounding (item[0]).
          for (let i = 1; i < item.length; i++){
            // Push sub elements in QUEUE.
            fillData(item[i]);
          }
          let len = Math.floor((Data.length - len_pos) / 24);
          // console.log(len);
          // Set now calculated vertices length of bounding box
          // to skip if ray doesn't intersect with it.
          Data[len_pos + 6] = len;
          // console.log(item.slice(1));
        }
        else
        {
          let b = item.bounding;
          // Create extra bounding volume for each object.
          let v = item.vertices;
          let c = item.colors;
          let n = item.normals;
          let t = item.textureNums;
          let uv = item.uvs;
          let len = item.arrayLength;
          // Declare bounding volume of object.
          try{
            Data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          }catch{
            console.warn(item);
          }
          // Data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          for(let i = 0; i < len * 3; i += 9){
            let j = i/3*2
            // 1 vertex = 1 line in world texture.
            // a, b, c, color, normal, texture_nums, UVs1, UVs2.
            Data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i/9*4],c[i/9*4+1],c[i/9*4+2],n[i],n[i+1],n[i+2],t[j],t[j+1],0,uv[j],uv[j+1],uv[j+2],uv[j+3],uv[j+4],uv[j+5]);
          }
        }
      }
      // Internal render engine Functions.
      function frameCycle(){
        RT.GL.clear(RT.GL.COLOR_BUFFER_BIT | RT.GL.DEPTH_BUFFER_BIT);
        // Request the browser to render frame with hardware accelerated rendering.
        requestAnimationFrame(frameCycle);
        // Render new Image, work through QUEUE.
      	renderFrame();
        // Calculate fps by measuring the time it takes to render 30 frames.
        Frame++;
        if (Frame >= 30)
        {
      		Frame = 0;
      		// Calculate Fps.
          RT.FPS = (30000 / (performance.now() - Micros)).toFixed(0);
          // Update Microse variable
      		Micros = window.performance.now();
        }
      }
      function renderFrame(){
        {
          // Configure where the final image should go.
          if(RT.FILTER)
          {
            RT.GL.bindFramebuffer(RT.GL.FRAMEBUFFER, Framebuffer);
            RT.GL.drawBuffers([
              RT.GL.COLOR_ATTACHMENT0,
              RT.GL.COLOR_ATTACHMENT1,
              RT.GL.COLOR_ATTACHMENT2,
              RT.GL.COLOR_ATTACHMENT3
            ]);
            // Configure framebuffer for color and depth.
            RT.GL.framebufferTexture2D(RT.GL.FRAMEBUFFER, RT.GL.COLOR_ATTACHMENT0, RT.GL.TEXTURE_2D, ColorRenderTexture, 0);
            RT.GL.framebufferTexture2D(RT.GL.FRAMEBUFFER, RT.GL.COLOR_ATTACHMENT1, RT.GL.TEXTURE_2D, NormalRenderTexture, 0);
            RT.GL.framebufferTexture2D(RT.GL.FRAMEBUFFER, RT.GL.COLOR_ATTACHMENT2, RT.GL.TEXTURE_2D, OriginalRenderTexture, 0);
            RT.GL.framebufferTexture2D(RT.GL.FRAMEBUFFER, RT.GL.COLOR_ATTACHMENT3, RT.GL.TEXTURE_2D, IdRenderTexture, 0);
            RT.GL.framebufferTexture2D(RT.GL.FRAMEBUFFER, RT.GL.DEPTH_ATTACHMENT, RT.GL.TEXTURE_2D, DepthTexture, 0);
          }
          else
          {
            RT.GL.bindFramebuffer(RT.GL.FRAMEBUFFER, null);
          }
          // Clear depth and color buffers from last frame.
          RT.GL.clear(RT.GL.COLOR_BUFFER_BIT | RT.GL.DEPTH_BUFFER_BIT);

          RT.GL.bindVertexArray(VAO);
          RT.GL.useProgram(Program);
          // Set world-texture.
          worldTextureBuilder();

          RT.GL.activeTexture(RT.GL.TEXTURE0);
          RT.GL.bindTexture(RT.GL.TEXTURE_2D, WorldTexture);
          RT.GL.activeTexture(RT.GL.TEXTURE1);
          RT.GL.bindTexture(RT.GL.TEXTURE_2D, RandomTexture);
          RT.GL.activeTexture(RT.GL.TEXTURE2);
          RT.GL.bindTexture(RT.GL.TEXTURE_2D, RT.NormalTexture);
          RT.GL.activeTexture(RT.GL.TEXTURE3);
          RT.GL.bindTexture(RT.GL.TEXTURE_2D, RT.ColorTexture);
          RT.GL.activeTexture(RT.GL.TEXTURE4);
          RT.GL.bindTexture(RT.GL.TEXTURE_2D, RT.LightTexture);
          // Set uniforms for shaders.
          // Set 3d camera position.
          RT.GL.uniform3f(CameraPosition, RT.X, RT.Y, RT.Z);
          // Set x and y rotation of camera.
          RT.GL.uniform2f(Perspective, RT.FX, RT.FY);
          // Set fov and X/Y ratio of screen.
          RT.GL.uniform4f(RenderConf, RT.FOV, target_canvas.width / target_canvas.height, 1, 1);
          // Set amount of samples per ray.
          RT.GL.uniform1i(SamplesLocation, RT.SAMPLES);
          // Set max reflections per ray.
          RT.GL.uniform1i(ReflectionsLocation, RT.REFLECTIONS);
          // Instuct shader to render for filter or not.
          RT.GL.uniform1i(FilterLocation, RT.FILTER);
          // Set global illumination.
          RT.GL.uniform3f(GILocation, RT.GI[0], RT.GI[1], RT.GI[2]);
          // Set width of height and normal texture.
          RT.GL.uniform1i(TextureWidth, Math.floor(2048 / RT.TEXTURE_SIZES[0]));
          // Pass whole current world space as data structure to GPU.
          RT.GL.uniform1i(WorldTex, 0);
          // Pass random texture to GPU.
          RT.GL.uniform1i(RandomTex, 1);
          // Pass normal texture to GPU.
          RT.GL.uniform1i(NormalTex, 2);
          // Pass texture to GPU.
          RT.GL.uniform1i(ColorTex, 3);
          // Pass texture with all primary light sources in the scene.
          RT.GL.uniform1i(LightTex, 4);

          let vertices = [];
          let normals = [];
          let colors = [];
          let uvs = [];
          let texNums = [];
          let length = 0;
          // Iterate through render queue and build arrays for GPU.
          var flattenQUEUE = (item) => {
            if (Array.isArray(item))
            {
              // Iterate over all sub elements and skip bounding (item[0]).
              for (let i = 1; i < item.length; i++){
                // flatten sub element of QUEUE.
                flattenQUEUE(item[i]);
              }
            }
            else
            {
              vertices.push(item.vertices);
              normals.push(item.normals);
              colors.push(item.colors);
              uvs.push(item.uvs);
              texNums.push(item.textureNums);
              //console.log(item.textureNums);
              length += item.arrayLength;
            }
          };
          // Start recursion.
          RT.QUEUE.forEach((item, i) => {flattenQUEUE(item)});
          // Set PositionBuffer.
          RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, PositionBuffer);
          RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array(vertices.flat()), RT.GL.STATIC_DRAW);
          // Set NormalBuffer.
          RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, NormalBuffer);
          RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array(normals.flat()), RT.GL.STATIC_DRAW);
          // Set ColorBuffer.
          RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, ColorBuffer);
          RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array(colors.flat()), RT.GL.STATIC_DRAW);
          // Set TexBuffer.
          RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, TexBuffer);
          RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array(uvs.flat()), RT.GL.STATIC_DRAW);
          // Pass texture IDs to GPU.
          RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, TexNumBuffer);
          RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array(texNums.flat()), RT.GL.STATIC_DRAW);
          // Actual drawcall.
          RT.GL.drawArrays(RT.GL.TRIANGLES, 0, length);
        }
        // Apply post processing.
        if(RT.FILTER)
        {
          {
            // Configure where the final image should go.
            RT.GL.bindFramebuffer(RT.GL.FRAMEBUFFER, PostFramebuffer);
            // Configure framebuffer for color and depth.
            RT.GL.framebufferTexture2D(RT.GL.FRAMEBUFFER, RT.GL.COLOR_ATTACHMENT0, RT.GL.TEXTURE_2D, KernelTexture, 0);
            // Clear depth and color buffers from last frame.
            RT.GL.clear(RT.GL.COLOR_BUFFER_BIT | RT.GL.DEPTH_BUFFER_BIT);
            // Make pre rendered image TEXTURE0.
            RT.GL.activeTexture(RT.GL.TEXTURE0);
            RT.GL.bindTexture(RT.GL.TEXTURE_2D, ColorRenderTexture);
            // Make pre rendered normal map TEXTURE1.
            RT.GL.activeTexture(RT.GL.TEXTURE1);
            RT.GL.bindTexture(RT.GL.TEXTURE_2D, NormalRenderTexture);
            // Make pre rendered map of original colors TEXTURE2.
            RT.GL.activeTexture(RT.GL.TEXTURE2);
            RT.GL.bindTexture(RT.GL.TEXTURE_2D, OriginalRenderTexture);

            RT.GL.activeTexture(RT.GL.TEXTURE3);
            RT.GL.bindTexture(RT.GL.TEXTURE_2D, IdRenderTexture);
            // Switch program and VAO.
            RT.GL.useProgram(PostProgram);
            RT.GL.bindVertexArray(POST_VAO);
            // Pass pre rendered texture to shader.
            RT.GL.uniform1i(ColorRenderTex, 0);
            // Pass normal texture to GPU.
            RT.GL.uniform1i(NormalRenderTex, 1);
            // Pass original color texture to GPU.
            RT.GL.uniform1i(OriginalRenderTex, 2);
            // Pass vertex_id texture to GPU.
            RT.GL.uniform1i(IdRenderTex, 3);
            // Post processing drawcall.
            RT.GL.drawArrays(RT.GL.TRIANGLES, 0, 6);
          }
          // Apply kernel convolution matrix.
          {
            // Render to canvas now.
            RT.GL.bindFramebuffer(RT.GL.FRAMEBUFFER, null);
            // Make pre rendered texture TEXTURE0.
            RT.GL.activeTexture(RT.GL.TEXTURE0);
            RT.GL.bindTexture(RT.GL.TEXTURE_2D, KernelTexture);
            // Switch program and VAO.
            RT.GL.useProgram(KernelProgram);
            RT.GL.bindVertexArray(KERNEL_VAO);
            // Pass pre rendered texture to shader.
            RT.GL.uniform1i(KernelTex, 0);
            // Post processing drawcall.
            RT.GL.drawArrays(RT.GL.TRIANGLES, 0, 6);
          }
        }
      }
      // Start render engine.
      {
      	// Compile shaders and link them into Program global.
        Program = await buildProgram([
          { source: vertex_glsl, type: RT.GL.VERTEX_SHADER },
          { source: fragment_glsl, type: RT.GL.FRAGMENT_SHADER }
        ]);
        // Compile shaders and link them into PostProgram global.
        PostProgram = await buildProgram([
          { source: post_vertex_glsl, type: RT.GL.VERTEX_SHADER },
          { source: post_fragment_glsl, type: RT.GL.FRAGMENT_SHADER }
        ]);
        // Compile shaders and link them into KernelProgram global.
        KernelProgram = await buildProgram([
          { source: post_vertex_glsl, type: RT.GL.VERTEX_SHADER },
          { source: kernel_glsl, type: RT.GL.FRAGMENT_SHADER }
        ]);
        // Create global vertex array object (VAO).
        RT.GL.bindVertexArray(VAO);
      	// Bind Attribute varying to their respective shader locations.
      	RT.GL.bindAttribLocation(Program, Position, "position_3d");
        RT.GL.bindAttribLocation(Program, Normal, "normal_3d");
        RT.GL.bindAttribLocation(Program, TexCoord, "tex_pos");
        RT.GL.bindAttribLocation(Program, Color, "color_3d");
        RT.GL.bindAttribLocation(Program, TexNum, "texture_nums_3d");
      	// Bind uniforms to Program.
        CameraPosition = RT.GL.getUniformLocation(Program, "camera_position");
        Perspective = RT.GL.getUniformLocation(Program, "perspective");
        RenderConf = RT.GL.getUniformLocation(Program, "conf");
        SamplesLocation = RT.GL.getUniformLocation(Program, "samples");
        ReflectionsLocation = RT.GL.getUniformLocation(Program, "reflections");
        FilterLocation = RT.GL.getUniformLocation(Program, "use_filter");
        GILocation = RT.GL.getUniformLocation(Program, "global_illumination");
        WorldTex = RT.GL.getUniformLocation(Program, "world_tex");
        RandomTex = RT.GL.getUniformLocation(Program, "random");
        TextureWidth = RT.GL.getUniformLocation(Program, "texture_width");

        LightTex = RT.GL.getUniformLocation(Program, "light_tex");
        NormalTex = RT.GL.getUniformLocation(Program, "normal_tex");
        ColorTex = RT.GL.getUniformLocation(Program, "tex");
        // Set pixel density in canvas correctly.
        RT.GL.viewport(0, 0, RT.GL.canvas.width, RT.GL.canvas.height);
      	// Enable depth buffer and therefore overlapping vertices.
        RT.GL.enable(RT.GL.DEPTH_TEST);
        RT.GL.depthMask(true);
      	// Cull (exclude from rendering) hidden vertices at the other side of objects.
        RT.GL.enable(RT.GL.CULL_FACE);
        // Set clear color for framebuffer.
      	RT.GL.clearColor(0, 0, 0, 0);
      	// Define Program with its currently bound shaders as the program to use for the webgl2 context.
        RT.GL.useProgram(Program);
        // Prepare position buffer for coordinates array.
        PositionBuffer = RT.GL.createBuffer();
        // Create a buffer for normals.
        NormalBuffer = RT.GL.createBuffer();
        // Create a buffer for tex_coords.
        TexBuffer = RT.GL.createBuffer();
        // Create buffer for texture sizes.
        TexSizeBuffer = RT.GL.createBuffer();
        // Create buffer for textur IDs.
        TexNumBuffer = RT.GL.createBuffer();
        // Create a buffer for colors.
        ColorBuffer = RT.GL.createBuffer();
        // Create a world texture containing all information about world space.
        WorldTexture = RT.GL.createTexture();
        // Create Textures for primary render.
        RandomTexture = RT.GL.createTexture();

        RT.NormalTexture = RT.GL.createTexture();
        RT.ColorTexture = RT.GL.createTexture();
        // Create texture for all primary light sources in scene.
        RT.LightTexture = RT.GL.createTexture();
        // Create random texture.
        randomTextureBuilder();
        // Bind and set buffer parameters.
        // Bind position buffer.
        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, PositionBuffer);
        RT.GL.enableVertexAttribArray(Position);
        RT.GL.vertexAttribPointer(Position, 3, RT.GL.FLOAT, false, 0, 0);
        // Bind normal buffer.
        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, NormalBuffer);
        RT.GL.enableVertexAttribArray(Normal);
        RT.GL.vertexAttribPointer(Normal, 3, RT.GL.FLOAT, false, 0, 0);
        // Bind color buffer.
        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, ColorBuffer);
        RT.GL.enableVertexAttribArray(Color);
        RT.GL.vertexAttribPointer(Color, 4, RT.GL.FLOAT, false, 0, 0);
        //Set TexBuffer
        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, TexBuffer);
        RT.GL.enableVertexAttribArray(TexCoord);
        RT.GL.vertexAttribPointer(TexCoord, 2, RT.GL.FLOAT, true, 0, 0);

        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, TexNumBuffer);
        RT.GL.enableVertexAttribArray(TexNum);
        RT.GL.vertexAttribPointer(TexNum, 2, RT.GL.FLOAT, true, 0, 0);
        // Create frame buffers and textures to be rendered to.
        Framebuffer = RT.GL.createFramebuffer();
        ColorRenderTexture = RT.GL.createTexture();
        NormalRenderTexture = RT.GL.createTexture();
        OriginalRenderTexture = RT.GL.createTexture();
        IdRenderTexture = RT.GL.createTexture();

        DepthTexture = RT.GL.createTexture();

        renderTextureBuilder();
        // Create post program buffers and uniforms.
        RT.GL.bindVertexArray(POST_VAO);
        RT.GL.useProgram(PostProgram);

        // Bind uniforms.
        ColorRenderTex = RT.GL.getUniformLocation(PostProgram, "pre_render_color");
        NormalRenderTex = RT.GL.getUniformLocation(PostProgram, "pre_render_normal");
        OriginalRenderTex = RT.GL.getUniformLocation(PostProgram, "pre_render_original_color");
        IdRenderTex = RT.GL.getUniformLocation(PostProgram, "pre_render_id");

        PostVertexBuffer = RT.GL.createBuffer();

        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, PostVertexBuffer);
        RT.GL.enableVertexAttribArray(PostPosition);
        RT.GL.vertexAttribPointer(PostPosition, 2, RT.GL.FLOAT, false, 0, 0);
        // Fill buffer with data for two verices.
        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, PostVertexBuffer);
        RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array([0,0,1,0,0,1,1,1,0,1,1,0]), RT.GL.DYNAMIC_DRAW);

        PostFramebuffer = RT.GL.createFramebuffer();
        KernelTexture = RT.GL.createTexture();

        postRenderTextureBuilder();
        // Create post program buffers and uniforms.
        RT.GL.bindVertexArray(KERNEL_VAO);
        RT.GL.useProgram(KernelProgram);

        KernelVertexBuffer = RT.GL.createBuffer();

        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, KernelVertexBuffer);
        RT.GL.enableVertexAttribArray(KernelPosition);
        RT.GL.vertexAttribPointer(KernelPosition, 2, RT.GL.FLOAT, false, 0, 0);
        // Fill buffer with data for two verices.
        RT.GL.bindBuffer(RT.GL.ARRAY_BUFFER, KernelVertexBuffer);
        RT.GL.bufferData(RT.GL.ARRAY_BUFFER, new Float32Array([0,0,1,0,0,1,1,1,0,1,1,0]), RT.GL.DYNAMIC_DRAW);
        // Load existing textures.
        RT.UPDATE_NORMAL();
        RT.UPDATE_TEXTURE();
        RT.UPDATE_LIGHT();
        // Begin frame cycle.
        frameCycle();
      }
    },
    // Cuboid element prototype.
    CUBOID: (x, y, z, width, height, depth) => {
      // Predefine properties of vertices.
      let [x2, y2, z2] = [x + width, y + height, z + depth];
      // Create surface elements for cuboid.
      let surfaces = new Array(2);
      surfaces[0] = [x, x2, y, y2, z, z2];
      surfaces[1] = RT.PLANE([x,y2,z],[x2,y2,z],[x2,y2,z2],[x,y2,z2],[0,1,0]);
      surfaces[2] = RT.PLANE([x2,y2,z],[x2,y,z],[x2,y,z2],[x2,y2,z2],[1,0,0]);
      surfaces[3] = RT.PLANE([x2,y2,z2],[x2,y,z2],[x,y,z2],[x,y2,z2],[0,0,1]);
      surfaces[4] = RT.PLANE([x,y,z2],[x2,y,z2],[x2,y,z],[x,y,z],[0,-1,0]);
      surfaces[5] = RT.PLANE([x,y2,z2],[x,y,z2],[x,y,z],[x,y2,z],[-1,0,0]);
      surfaces[6] = RT.PLANE([x,y2,z],[x,y,z],[x2,y,z],[x2,y2,z],[0,0,-1]);
      return surfaces;
    },
    // Surface element prototype.
    PLANE: (c0, c1, c2, c3, normal) => {
      return {
        // Set normals.
        normals: new Array(6).fill(normal).flat(),
        // Set vertices.
        vertices: [c0,c1,c2,c2,c3,c0].flat(),
        // Default color to white.
        colors: new Array(24).fill(1).flat(),
        // Set UVs.
        uvs: [0,0,0,1,1,1,1,1,1,0,0,0],
        // Set used textures.
        textureNums: new Array(6).fill([-1,-1]).flat(),
        // Define maximum bounding volume of cuboid.
        bounding: [Math.min(c0[0],c1[0],c2[0],c3[0]),
                   Math.max(c0[0],c1[0],c2[0],c3[0]),
                   Math.min(c0[1],c1[1],c2[1],c3[1]),
                   Math.max(c0[1],c1[1],c2[1],c3[1]),
                   Math.min(c0[2],c1[2],c2[2],c3[2]),
                   Math.max(c0[2],c1[2],c2[2],c3[2])],
        // Set default arrayLength for this object.
        arrayLength: 6
      }
    }
  };
  return RT;
};
