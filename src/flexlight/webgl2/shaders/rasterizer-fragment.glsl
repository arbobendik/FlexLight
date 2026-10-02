
uniform uint env_map_mip_level_count;

vec2 trowbridgeReitz(float alpha, vec2 n_dot_h) {
    float numerator = alpha * alpha;
    vec2 denom = n_dot_h * n_dot_h * (numerator - 1.0) + 1.0;
    return numerator / max(PI * denom * denom, vec2(BIAS));
}

float oneOverSchlickBeckmann(float alpha, float n_dot_x) {
    float k = alpha * 0.5;
    return max(n_dot_x * (1.0 - k) + k, BIAS);
}

vec3 fresnel(vec3 f0, float cos_theta) {
    // Use Schlick approximation
    return f0 + (1.0 - f0) * pow(1.0 - cos_theta, 5.0);
}

// BSDF takes in incoming and outgoing directions and surface properties returning throughput for direct lighting
vec3 BSDF(vec3 in_dir, vec3 out_dir, vec3 n, Material material) {
    // Minimum alpha for better looking smooth metals and caustics
    float alpha = max(material.roughness * material.roughness, 0.04);
    float n_dot_v = abs(dot(n, - in_dir));
    float f0_sqrt = (1.0 - material.ior) / (1.0 + material.ior);
    vec3 f0 = mix(vec3(f0_sqrt * f0_sqrt), material.albedo, material.metallic);
    // Precaluclate reflected vector
    vec3 rv = reflect(- in_dir, n);
    // Precaluclate diffuse component
    vec3 lambert = material.albedo * INV_PI;
    float diffuse = (1.0 - material.metallic) * (1.0 - material.transmission);

    float n_dot_l = abs(dot(n, out_dir));
    vec3 h = normalize(out_dir - in_dir);
    float v_dot_h = abs(dot(in_dir, h));
    float n_dot_h = abs(dot(n, h));

    vec3 rh = normalize(out_dir + rv);
    float n_dot_rh = max(dot(n, rh), 0.0);

    vec3 reflect_factor = fresnel(f0, v_dot_h);
    vec3 diffuse_component = diffuse * lambert;

    vec2 cook_torrance_numerator = trowbridgeReitz(alpha, vec2(n_dot_h, n_dot_rh));
    float cook_torrance_denominator = max(4.0 * oneOverSchlickBeckmann(alpha, n_dot_v) * oneOverSchlickBeckmann(alpha, n_dot_l), BIAS);
    vec2 cook_torrance = cook_torrance_numerator / cook_torrance_denominator;

    // Check for total internal reflection
    float sign_dir = sign(dot(- in_dir, n));
    float eta = mix(1.0 / material.ior, material.ior, max(sign_dir, 0.0));
    float cos_theta_i = abs(dot(- in_dir, n));
    float sin_theta_i_sq = 1.0 - cos_theta_i * cos_theta_i;
    float sin_theta_t_sq = (eta * eta) * sin_theta_i_sq;

    // Total internal reflection occurs when sin²θt > 1
    bool is_total_internal_reflection = sin_theta_t_sq > 1.0;
    float transmission_factor = is_total_internal_reflection ? 0.0 : material.transmission;

    vec3 radiance = diffuse_component + reflect_factor * cook_torrance.x + transmission_factor * cook_torrance.y;
    // Outgoing light to camera
    return radiance * n_dot_l;
}

struct SampledColor {
    vec3 color;
    uint random_state;
};

SampledColor sampleLights(Material material, Ray camera_ray, uint init_random_state, vec3 smooth_n, float geometry_offset) {
    uint size = light_count + 1u;

    if (size <= 1u) {
        return SampledColor(material.emissive, init_random_state);
    }

    vec3 local_color = vec3(0.0);
    uint random_state = init_random_state;

    for (uint i = 1u; i < size; i++) {
        // Read light from storage buffer
        Light light = access_light(i);

        vec3 light_dir = vec3(0.0);
        vec3 color_for_light = vec3(0.0);

        // Handle if light is an area light
        if (light.is_area_light == 1.0) {
            // CASE 0: Area ligh
            uint instance_id = uint(light.position.x);
            float triangle_count = light.position.y;

            Random random_triangle = pcg(random_state);
            random_state = random_triangle.state;

            uint triangle_instance_offset = access_instance_uint(instance_id * INSTANCE_UINT_SIZE);

            // Choose random triangle from instance
            uint triangle_offset = triangle_instance_offset + uint(random_triangle.value * triangle_count) * TRIANGLE_SIZE;
            // Fetch triangle coordinates from scene graph texture
            vec4 t0 = access_triangle(triangle_offset);
            vec4 t1 = access_triangle(triangle_offset + 1u);
            vec4 t2 = access_triangle(triangle_offset + 2u);
            vec4 t3 = access_triangle(triangle_offset + 3u);
            vec4 t4 = access_triangle(triangle_offset + 4u);

            // Fetch triangle coordinates from scene graph texture
            Transform transform = access_instance_transform(instance_id * 2u);
            // Assemble and transform triangle with shift.
            mat3 t = transform.rotation * mat3(t0.xyz, vec3(t0.w, t1.xy), vec3(t1.zw, t2.x)) + mat3(transform.shift, transform.shift, transform.shift);

            // Assemble and transform normals
            mat3 normals = transform.rotation * mat3(t2.yzw, t3.xyz, vec3(t3.w, t4.xy));
            // Compute edge vectors
            vec3 edge1 = t[1] - t[0];
            vec3 edge2 = t[2] - t[0];
            vec3 edge3 = t[2] - t[1];

            float min_edge_length = min(length(edge1), min(length(edge2), length(edge3)));

            vec3 light_geometry_n = normalize(cross(edge2, edge1));
            vec3 diffs = vec3(
                distance(camera_ray.origin, t[0]),
                distance(camera_ray.origin, t[1]),
                distance(camera_ray.origin, t[2])
            );
            // Choose random barycentric coordinates
            Random random_value_0 = pcg(random_state);
            Random random_value_1 = pcg(random_value_0.state);
            random_state = random_value_1.state;

            vec2 u = vec2(random_value_0.value, random_value_1.value);
            if (u.x + u.y > 1.0) {
                u = vec2(1.0 - u.x, 1.0 - u.y);
            }
            vec3 geometry_uvw = vec3(1.0 - u.x - u.y, u.x, u.y);
            // Interpolate smooth normal
            vec3 light_smooth_n = normalize(normals * geometry_uvw);
            // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
            vec3 angles = acos(abs(vec3(
                dot(light_geometry_n, normalize(normals[0])),
                dot(light_geometry_n, normalize(normals[1])),
                dot(light_geometry_n, normalize(normals[2]))
            )));
            // Limit angles to 45 degrees
            vec3 angle_tan = clamp(tan(angles), vec3(0.0), vec3(PI * 0.25));
            // Keep geometry offset within reasonable range
            float light_geometry_offset = clamp(dot(diffs * angle_tan, geometry_uvw), 0.0, min_edge_length * 0.5);
            // Interpolate point on triangle
            vec3 light_position = t * geometry_uvw;
            // Calculate normal
            vec3 edge_cross = cross(edge1, edge2);
            float light_area = max(length(edge_cross) * 0.5, BIAS);
            // Calculate light direction
            vec3 dir = light_position - camera_ray.origin;
            float len = length(dir);

            vec3 l = normalize(dir);
            // Outgoing angle at light source
            float light_n_dot_ml = max(dot(light_smooth_n, - l), 0.0);
            // Calculate brightness
            vec3 brightness = light.color * light_area * triangle_count * light_n_dot_ml / (len * len);
            // Calculate BSDF for light
            color_for_light = BSDF(camera_ray.unit_direction, l, smooth_n, material) * brightness;
            light_dir = dir + light_smooth_n * light_geometry_offset;
        } else if (light.is_area_light == 0.0) {
            // CASE 1: Point light
            // Yeild random sphere and update state
            RandomSphere light_sphere = random_sphere(random_state);
            random_state = light_sphere.state;
            vec3 light_position = light.position + light_sphere.value * light.variance;
            // Alter light source position according to variation.
            vec3 dir = light_position - camera_ray.origin;
            float len = length(dir);
            // Apply inverse square law
            vec3 brightness = light.color * light.intensity / (len * len);
            vec3 l = dir / len;
            // Calculate BSDF for light
            color_for_light = BSDF(camera_ray.unit_direction, l, smooth_n, material) * brightness;
            light_dir = dir;
        }

        float color_intensity = rgb_to_greyscale(color_for_light);

        vec3 unit_light_dir = normalize(light_dir);
        // Compute quick exit criterion to potentially skip expensive shadow test
        bool show_color = color_intensity == 0.0;
        bool show_shadow = dot(smooth_n, unit_light_dir) < 0.0;
        // Test if in shadow
        if (show_color) {
            local_color += color_for_light;
        } else if (!show_shadow) {
            // Apply geometry offset
            vec3 offset_target = camera_ray.origin + geometry_offset * smooth_n;
            Ray light_ray = Ray(offset_target, unit_light_dir);
            if (!shadowTraverseInstanceBVH(light_ray, length(light_dir))) {
                local_color += color_for_light;
            }
        }
    }

    // Apply emissive texture and ambient light
    vec3 base_luminance = material.emissive;
    return SampledColor(local_color + base_luminance, random_state);
}

vec3 env_map_sample(vec3 dir, float roughness) {
    float len = sqrt(dir.x * dir.x + dir.z * dir.z);
    float s = acos(dir.x / len);
    if (dir.z < 0.0) {
        s = 2.0 * PI - s;
    }
    s = s / (2.0 * PI);
    vec2 tex_coord = vec2(s, ((asin(dir.y) * -2.0 / PI) + 1.0) * 0.5);
    float mip_level = max(0.0, ceil(float(env_map_mip_level_count - 1u) * (1.0 - (1.0 - roughness) * (1.0 - roughness))));
    return textureLod(environment_map, tex_coord, mip_level).xyz * 255.0;
}

SampledColor lightTrace(Hit init_hit, vec3 origin, vec3 camera, uint init_random_state) {
    // Use additive color mixing technique, so start with black
    Hit hit = init_hit;
    Ray ray = Ray(origin, normalize(origin - camera));
    uint random_state = init_random_state;
    uint triangle_offset = hit.triangle_index * TRIANGLE_SIZE;
    // Fetch triangle coordinates from scene graph texture
    vec4 t0 = access_triangle(triangle_offset);
    vec4 t1 = access_triangle(triangle_offset + 1u);
    vec4 t2 = access_triangle(triangle_offset + 2u);
    vec4 t3 = access_triangle(triangle_offset + 3u);
    vec4 t4 = access_triangle(triangle_offset + 4u);
    vec4 t5 = access_triangle(triangle_offset + 5u);
    // Fetch triangle coordinates from scene graph texture
    Transform transform = access_instance_transform(hit.instance_index * 2u);
    // Assemble and transform triangle
    mat3 t = transform.rotation * mat3(t0.xyz, vec3(t0.w, t1.xy), vec3(t1.zw, t2.x));
    // Assemble and transform normals
    mat3 normals = transform.rotation * mat3(t2.yzw, t3.xyz, vec3(t3.w, t4.xy));
    vec3 offset_ray_target = ray.origin - transform.shift;

    vec3 geometry_n = normalize(cross(t[2] - t[0], t[1] - t[0]));
    vec3 diffs = vec3(
        distance(offset_ray_target, t[0]),
        distance(offset_ray_target, t[1]),
        distance(offset_ray_target, t[2])
    );

    // Calculate barycentric coordinates
    vec3 geometry_uvw = vec3(1.0 - hit.uv.x - hit.uv.y, hit.uv.x, hit.uv.y);
    // Interpolate smooth normal
    vec3 smooth_n = normalize(normals * geometry_uvw);
    // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
    vec3 angles = acos(abs(vec3(
        dot(geometry_n, normalize(normals[0])),
        dot(geometry_n, normalize(normals[1])),
        dot(geometry_n, normalize(normals[2]))
    )));

    vec3 angle_tan = clamp(tan(angles), vec3(0.0), vec3(1.0));
    float geometry_offset = dot(diffs * angle_tan, geometry_uvw);
    // Interpolate final barycentric texture coordinates between UV's of the respective vertices
    vec2 barycentric = fract(mat3x2(t4.zw, t5.xy, t5.zw) * geometry_uvw);
    // Sample material
    Material material = access_instance_material(hit.instance_index);
    // Read material textures
    uint albedo_texture_id = access_instance_uint(hit.instance_index * INSTANCE_UINT_SIZE + 3u);
    if (albedo_texture_id != UINT_MAX) {
        material.albedo = textureSample(albedo_texture_id, barycentric).xyz * INV_255;
    }

    uint normal_texture_id = access_instance_uint(hit.instance_index * INSTANCE_UINT_SIZE + 4u);
    if (normal_texture_id != UINT_MAX) {
        vec2 uv0 = t4.zw;
        vec2 uv1 = t5.xy;
        vec2 uv2 = t5.zw;
        mat3 tbn = normalMapTBN(t[0], t[1], t[2], uv0, uv1, uv2, smooth_n);
        vec3 normal_data = normalize(textureSample(normal_texture_id, barycentric).xyz * INV_255 * 2.0 - 1.0);
        normal_data.y = -normal_data.y;
        smooth_n = normalize(tangentToWorldNormalMap(normal_data, tbn));
    }

    uint emissive_texture_id = access_instance_uint(hit.instance_index * INSTANCE_UINT_SIZE + 5u);
    if (emissive_texture_id != UINT_MAX) {
        material.emissive = textureSample(emissive_texture_id, barycentric).xyz * INV_255;
    }

    uint roughness_texture_id = access_instance_uint(hit.instance_index * INSTANCE_UINT_SIZE + 6u);
    if (roughness_texture_id != UINT_MAX) {
        material.roughness = textureSample(roughness_texture_id, barycentric).x * INV_255;
    }

    uint metallic_texture_id = access_instance_uint(hit.instance_index * INSTANCE_UINT_SIZE + 7u);
    if (metallic_texture_id != UINT_MAX) {
        material.metallic = textureSample(metallic_texture_id, barycentric).x * INV_255;
    }

    float n_dot_v = abs(dot(smooth_n, - ray.unit_direction));

    float f0_sqrt = (1.0 - material.ior) / (1.0 + material.ior);
    vec3 f0 = mix(vec3(f0_sqrt * f0_sqrt), material.albedo, material.metallic);

    vec3 final_color = vec3(0.0);
    // Determine local color considering PBR attributes and lighting
    for (uint i = 0u; i < samples; i++) {
        RandomSphere light_offset_sphere = random_sphere(random_state);
        random_state = light_offset_sphere.state;
        SampledColor local_sampled = sampleLights(material, ray, random_state, smooth_n, geometry_offset);
        random_state = local_sampled.random_state;
        final_color += local_sampled.color;
    }
    // Average the color over samples
    final_color /= float(samples);

    // If ray reflects from inside or onto an transparent object,
    // the surface faces in the opposite direction as usual
    float sign_dir = sign(dot(ray.unit_direction, smooth_n));
    smooth_n *= - sign_dir;

    // Sample environment map if present
    if (environment_map_size.x > 1u && environment_map_size.y > 1u) {
        float reflect_component = rgb_to_greyscale(fresnel(f0, n_dot_v));
        float diffuse_component = (1.0 - material.metallic) * (1.0 - material.transmission);
        float refract_component = material.transmission;
        // Calculate ratio of reflection and transmission
        float total_component = reflect_component + diffuse_component + refract_component;
        float total_component_inv = 1.0 / total_component;
        float reflect_ratio = reflect_component * total_component_inv;
        float diffuse_ratio = diffuse_component * total_component_inv;
        float refract_ratio = refract_component * total_component_inv;
        // Does ray reflect or refract or diffuse?

        vec3 reflect_diffuse_ray_dir = reflect(ray.unit_direction, smooth_n);
        vec3 reflect_importancy_factor = mix(vec3(1.0), material.albedo, material.metallic);
        vec3 diffuse_importancy_factor = material.albedo;
        vec3 env_color_reflect_diffuse = env_map_sample(reflect_diffuse_ray_dir * vec3(1.0, 1.0, -1.0), material.roughness);

        final_color += env_color_reflect_diffuse * reflect_ratio * reflect_importancy_factor;
        final_color += env_color_reflect_diffuse * diffuse_ratio * diffuse_importancy_factor;

        if (material.transmission > 0.0) {
            float eta = mix(1.0 / material.ior, material.ior, max(sign_dir, 0.0));
            // Refract ray depending on IOR of material
            vec3 refract_ray_dir = refract(ray.unit_direction, smooth_n, eta);
            vec3 refract_importancy_factor = material.albedo;
            vec3 env_color_refract = env_map_sample(refract_ray_dir * vec3(1.0, 1.0, -1.0), material.roughness) * refract_importancy_factor;
            final_color += env_color_refract * refract_ratio;
        }
    } else {
        // If no environment map is present, use ambient color
        final_color += material.albedo * ambient;
    }
    // Return final pixel color
    return SampledColor(final_color, random_state);
}

void main() {
    // Get texel position of screen
    ivec2 screen_pos = ivec2(gl_FragCoord.xy);
    // Row counted from the top, like the screen position of the WebGPU compute shader
    uint row = render_size.y - 1u - uint(screen_pos.y);
    // Subtract 1 to have 0 as invalid index
    uvec4 offset = texelFetch(texture_offset, screen_pos, 0);
    uint instance_index = offset.x - 1u;
    uint triangle_index = offset.y - 1u;

    vec2 screen_space = vec2(float(screen_pos.x), float(row)) / vec2(render_size) * vec2(2.0, -2.0) + vec2(-1.0, 1.0);
    vec3 view_direction = normalize(inv_view_matrix * vec3(screen_space, 1.0) * vec3(1.0, 1.0, -1.0));

    if (instance_index == UINT_MAX && triangle_index == UINT_MAX) {
        vec3 env_color = vec3(0.0);
        if (environment_map_size.x > 1u && environment_map_size.y > 1u) {
            env_color = env_map_sample(view_direction, 0.0);
        } else {
            // If no environment map is present, use ambient color
            env_color = ambient;
        }
        // If there is no triangle render ambient color
        render_out = vec4(env_color, 1.0);
        return;
    }

    vec3 absolute_position = texelFetch(texture_absolute_position, screen_pos, 0).xyz;
    vec2 uv = uintBitsToFloat(offset.zw);
    vec3 uvw = vec3(uv, 1.0 - uv.x - uv.y);
    // Generate hit struct for rasterizer
    Hit init_hit = Hit(uvw.yz, instance_index, triangle_index, 0u, distance(absolute_position, camera_position));

    uint random_state = (temporal_target + 1u) * (row * render_size.x + uint(screen_pos.x));
    // Generate sample
    SampledColor sampled_color = lightTrace(init_hit, absolute_position, camera_position, random_state);
    // Render to compute target
    render_out = vec4(sampled_color.color, 1.0);
}
