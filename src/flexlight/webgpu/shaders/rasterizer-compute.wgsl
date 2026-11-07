const TRIANGLE_SIZE: u32 = 6u;

const INSTANCE_UINT_SIZE: u32 = 9u;

const TEXTURE_INSTANCE_SIZE: u32 = 4u;

// const INSTANCE_TRANSFORM_SIZE: u32 = 1u;
// const INSTANCE_MATERIAL_SIZE: u32 = 11u;

const BVH_TRIANGLE_SIZE: u32 = 1u;
const BVH_INSTANCE_SIZE: u32 = 3u;

const TRIANGLE_BOUNDING_VERTICES_SIZE: u32 = 5u;
const INSTANCE_BOUNDING_VERTICES_SIZE: u32 = 3u;

// const ZERO_FLOAT: f16 = 0.0;

const POINT_LIGHT_SIZE: u32 = 3u;

const PI: f32 = 3.141592653589793;
const POW32: f32 = 4294967296.0;
const UINT_MAX: u32 = 4294967295u;
const UINT_MAX_M1: u32 = 4294967294u;
const BIAS: f32 = 0.0000152587890625;
const INV_PI: f32 = 0.3183098861837907;
const INV_255: f32 = 0.00392156862745098;


struct Transform {
    rotation: mat3x3<f32>,
    shift: vec3<f32>,
};

struct UniformFloat {
    view_matrix: mat3x3<f32>,
    inv_view_matrix: mat3x3<f32>,

    camera_position: vec3<f32>,
    ambient: vec3<f32>,

    max_temporal_reproject: f32,
};

struct UniformUint {
    render_size: vec2<u32>,
    temporal_target: u32,
    temporal_max: u32,

    is_temporal: u32,
    samples: u32,
    max_reflections: u32,
    tonemapping_operator: u32,

    environment_map_size: vec2<u32>,
    point_light_count: u32,
    env_map_mip_level_count: u32,
    frame: u32,
};

@group(0) @binding(0) var compute_out: texture_storage_2d_array<rgba32float, write>;
@group(0) @binding(1) var<storage, read> texture_offset: array<u32>;
@group(0) @binding(2) var texture_absolute_position: texture_2d<f32>;
@group(0) @binding(3) var texture_uv: texture_2d<f32>;
// ComputeTextureBindGroup
@group(1) @binding(0) var texture_data: texture_2d_array<u32>;
@group(1) @binding(1) var<storage, read> texture_instance: array<u32>;
// textureSample(hdri_map, hdri_sampler, direction * vec3f(1, 1, -1));
@group(1) @binding(2) var environment_map: texture_2d<f32>;
@group(1) @binding(3) var environment_map_sampler: sampler;
// ComputeGeometryBindGroup
@group(2) @binding(0) var triangles: texture_2d_array<f32>;
@group(2) @binding(1) var triangle_bvh: texture_2d_array<u32>;
@group(2) @binding(2) var triangle_bounding_vertices: texture_2d_array<f32>;

// ComputeDynamicBindGroup
@group(3) @binding(0) var<uniform> uniforms_float: UniformFloat;
@group(3) @binding(1) var<uniform> uniforms_uint: UniformUint;
@group(3) @binding(2) var<storage, read> lights: array<Light>;

@group(3) @binding(3) var<storage, read> instance_uint: array<u32>;
@group(3) @binding(4) var<storage, read> instance_transform: array<Transform>;
@group(3) @binding(5) var<storage, read> instance_material: array<Material>;
@group(3) @binding(6) var<storage, read> instance_bvh: array<u32>;
@group(3) @binding(7) var<storage, read> instance_bounding_vertices: array<vec4<f32>>;

struct Hit {
    uv: vec2<f32>,
    distance: f32,
    instance_index: u32,
    triangle_index: u32
};



/*
fn smith(alpha: f32, n_dot_v: f32, n_dot_l: f32) -> f32 {
    return schlickBeckmann(alpha, n_dot_v) * schlickBeckmann(alpha, n_dot_l);
}
*/

fn fresnelSchlick(f0: vec3<f32>, cos_theta: f32) -> vec3<f32> {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - cos_theta, 5.0f);
}

struct SampledColor {
    color: vec3<f32>,
    random_state: u32
}

fn sample(material: Material, camera_ray: Ray, init_random_state: u32, smooth_n: vec3<f32>, geometry_n: vec3<f32>, geometry_offset: f32) -> SampledColor {
    let size: u32 = uniforms_uint.point_light_count + 1u;

    if (size <= 1u) {
        return SampledColor(material.emissive, init_random_state);
    }

    var local_color: vec3<f32> = vec3<f32>(0.0f);
    var random_state: u32 = init_random_state;
    // FlexKernels' BSDF toward the lights, its roughness at least 0.2 for better looking smooth metals, as point lights
    // leave a smooth one's delta lobes dark, entering the surface from the side the camera ray arrives on
    var shaded: Material = material;
    shaded.roughness = max(material.roughness, 0.2f);
    let front: bool = dot(camera_ray.unit_direction, smooth_n) < 0.0f;
    let eta_i: f32 = select(material.ior, 1.0f, front);
    let eta_o: f32 = select(1.0f, material.ior, front);

    //let size: u32 = u32(arrayLength(&lights));
    for (var i: u32 = 1u; i < size; i++) {
        let light_offset: u32 = i;
        // Read light from storage buffer
        let light: Light = lights[light_offset];

        var light_dir: vec3<f32> = vec3<f32>(0.0f);
        var color_for_light: vec3<f32> = vec3<f32>(0.0f);

        // Handle if light is an area light
        if (light.is_area_light == 1.0f) {
            // CASE 0: Area ligh
            let instance_id: u32 = u32(light.position.x);
            let triangle_count: f32 = light.position.y;

            let random_triangle: Random = pcg(random_state);
            random_state = random_triangle.state;

            let triangle_instance_offset: u32 = instance_uint[instance_id * INSTANCE_UINT_SIZE];

            // Choose random triangle from instance
            let triangle_offset: u32 = triangle_instance_offset + u32(random_triangle.value * triangle_count) * TRIANGLE_SIZE;
            // Fetch triangle coordinates from scene graph texture
            let t0 = access_triangle(triangle_offset);
            let t1 = access_triangle(triangle_offset + 1u); 
            let t2 = access_triangle(triangle_offset + 2u);
            let t3 = access_triangle(triangle_offset + 3u);
            let t4 = access_triangle(triangle_offset + 4u);

            // Fetch triangle coordinates from scene graph texture
            let transform: Transform = instance_transform[instance_id * 2u];
            // Assemble and transform triangle with shift.
            let t: mat3x3<f32> = transform.rotation * mat3x3<f32>(t0.xyz, vec3<f32>(t0.w, t1.xy), vec3<f32>(t1.zw, t2.x)) + mat3x3<f32>(transform.shift, transform.shift, transform.shift);

            // Assemble and transform normals, by the inverse transpose, which keeps them normal under a scale that is not uniform
            let normals: mat3x3<f32> = transpose(instance_transform[instance_id * 2u + 1u].rotation) * mat3x3<f32>(t2.yzw, t3.xyz, vec3<f32>(t3.w, t4.xy));
            // Compute edge vectors
            let edge1: vec3<f32> = t[1] - t[0];
            let edge2: vec3<f32> = t[2] - t[0];
            let edge3: vec3<f32> = t[2] - t[1];

            let min_edge_length: f32 = min(length(edge1), min(length(edge2), length(edge3)));

            let light_geometry_n: vec3<f32> = normalize(cross(edge2, edge1));
            let diffs: vec3<f32> = vec3<f32>(
                distance(camera_ray.origin, t[0]),
                distance(camera_ray.origin, t[1]),
                distance(camera_ray.origin, t[2])
            );
            // Choose random barycentric coordinates
            let random_value_0: Random = pcg(random_state);
            let random_value_1: Random = pcg(random_value_0.state);
            random_state = random_value_1.state;

            var u: vec2<f32> = vec2<f32>(random_value_0.value, random_value_1.value);
            if (u.x + u.y > 1.0f) {
                u = vec2<f32>(1.0f - u.x, 1.0f - u.y);
            }
            let geometry_uvw: vec3<f32> = vec3<f32>(1.0f - u.x - u.y, u.x, u.y);
            // Interpolate smooth normal
            var light_smooth_n: vec3<f32> = normalize(normals * geometry_uvw);
            // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
            let angles: vec3<f32> = acos(abs(vec3<f32>(
                dot(light_geometry_n, normalize(normals[0])),
                dot(light_geometry_n, normalize(normals[1])),
                dot(light_geometry_n, normalize(normals[2]))
            )));
            // Limit angles to 45 degrees
            let angle_tan: vec3<f32> = clamp(tan(angles), vec3<f32>(0.0f), vec3<f32>(PI * 0.25f));
            // Keep geometry offset within reasonable range
            let light_geometry_offset: f32 = clamp(dot(diffs * angle_tan, geometry_uvw), 0.0f, min_edge_length * 0.5f);
            // Interpolate point on triangle
            let light_position_raw: vec3<f32> = t * geometry_uvw;
            // Calculate normal
            let edge_cross: vec3<f32> = cross(edge1, edge2);
            let light_area: f32 = max(length(edge_cross) * 0.5f, BIAS);
            // Offset light position to avoid self shadowing
            let light_position: vec3<f32> = light_position_raw;
            // Calculate light direction
            let dir: vec3<f32> = light_position - camera_ray.origin;
            let len: f32 = length(dir);

            let l: vec3<f32> = normalize(dir);
            // Outgoing angle at light source
            let light_n_dot_ml: f32 = max(dot(light_smooth_n, - l), 0.0f);
            // Calculate brightness
            let brightness: vec3<f32> = light.color * light_area * triangle_count * light_n_dot_ml / (len * len);
            // Calculate BSDF for light
            color_for_light = BSDF(camera_ray.unit_direction, l, smooth_n, geometry_n, shaded, eta_i, eta_o, random_state) * brightness;
            light_dir = dir + shadowLift(light_smooth_n, light_geometry_offset, camera_ray.origin + geometry_offset * smooth_n, light_position);
        } else if (light.is_area_light == 0.0f) {
            // CASE 1: Point light
            // Yeild random sphere and update state
            let random_sphere: RandomSphere = random_sphere(random_state);
            random_state = random_sphere.state;
            let light_position = light.position + random_sphere.value * light.variance;
            // Alter light source position according to variation.
            let dir: vec3<f32> = light_position - camera_ray.origin;
            let len: f32 = length(dir);
            // Apply inverse square law
            let brightness: vec3<f32> = light.color * light.intensity / (len * len);
            let l: vec3<f32> = dir / len;
            // Calculate BSDF for light
            color_for_light = BSDF(camera_ray.unit_direction, l, smooth_n, geometry_n, shaded, eta_i, eta_o, random_state) * brightness;
            light_dir = dir;
        }



        let color_intensity: f32 = rgb_to_greyscale(color_for_light);

        let unit_light_dir: vec3<f32> = normalize(light_dir - geometry_offset * smooth_n);
        // Compute quick exit criterion to potentially skip expensive shadow test
        let show_color: bool = color_intensity == 0.0f;
        let show_shadow: bool = dot(smooth_n, unit_light_dir) < 0.0f;
        // Test if in shadow
        if (show_color) {
            local_color += color_for_light;
        } else if (!show_shadow) {
            // Apply geometry offset
            let offset_target: vec3<f32> = camera_ray.origin + geometry_offset * smooth_n;
            let shadow: vec3<f32> = camera_ray.origin + light_dir - offset_target;
            let light_ray: Ray = Ray(offset_target, normalize(shadow));
            if (!shadowTraverseInstanceBVH(light_ray, shadowLength(shadow), true)) {
                local_color += color_for_light;
            }
        }
    }

    // Apply emissive texture and ambient light
    let base_luminance: vec3<f32> = material.emissive;
    return SampledColor(local_color + base_luminance, random_state);
}


fn env_map_sample(dir: vec3<f32>, roughness: f32) -> vec3<f32> {
    let len:f32 = sqrt (dir.x * dir.x + dir.z * dir.z);
    var s:f32 = acos( dir.x / len);
    if (dir.z < 0) {
        s = 2.0 * PI - s;
    }
    s = s / (2.0 * PI);
    var tex_coord: vec2<f32> = vec2(s , ((asin(dir.y) * -2.0 / PI ) + 1.0) * 0.5);
    // return vec3<f32>(0.5f, 0.5f, 0.5f);
    var mip_level: f32 = max(0.0f, ceil(f32(uniforms_uint.env_map_mip_level_count - 1u) * (1.0f - (1.0f - roughness) * (1.0f - roughness))));
    return textureSampleLevel(environment_map, environment_map_sampler, tex_coord, mip_level).xyz * 255.0f;
}


fn lightTrace(init_hit: Hit, origin: vec3<f32>, camera: vec3<f32>, clip_space: vec2<f32>, init_random_state: u32) -> SampledColor {
    // Use additive color mixing technique, so start with black
    var hit: Hit = init_hit;
    var ray: Ray = Ray(origin, normalize(origin - camera));
    var random_state: u32 = init_random_state;
    var i: u32 = 0u;
    // Iterate over each bounce and modify color accordingly
    // while (true) {
    let triangle_offset: u32 = hit.triangle_index * TRIANGLE_SIZE;
    // Fetch triangle coordinates from scene graph texture
    let t0 = access_triangle(triangle_offset);
    let t1 = access_triangle(triangle_offset + 1u);
    let t2 = access_triangle(triangle_offset + 2u);
    let t3 = access_triangle(triangle_offset + 3u);
    let t4 = access_triangle(triangle_offset + 4u);
    let t5 = access_triangle(triangle_offset + 5u);
    // Fetch triangle coordinates from scene graph texture
    let transform: Transform = instance_transform[hit.instance_index * 2u];
    // Assemble and transform triangle
    let t: mat3x3<f32> = transform.rotation * mat3x3<f32>(t0.xyz, vec3<f32>(t0.w, t1.xy), vec3<f32>(t1.zw, t2.x));
    // Assemble and transform normals, by the inverse transpose, which keeps them normal under a scale that is not uniform
    let normals: mat3x3<f32> = transpose(instance_transform[hit.instance_index * 2u + 1u].rotation) * mat3x3<f32>(t2.yzw, t3.xyz, vec3<f32>(t3.w, t4.xy));
    let offset_ray_target: vec3<f32> = ray.origin - transform.shift;
    // Compute edge vectors
    let edge1: vec3<f32> = t[1] - t[0];
    let edge2: vec3<f32> = t[2] - t[0];

    let geometry_n: vec3<f32> = normalize(cross(t[2] - t[0], t[1] - t[0]));
    let diffs: vec3<f32> = vec3<f32>(
        distance(offset_ray_target, t[0]),
        distance(offset_ray_target, t[1]),
        distance(offset_ray_target, t[2])
    );

    // Calculate barycentric coordinates
    let geometry_uvw: vec3<f32> = vec3<f32>(1.0f - hit.uv.x - hit.uv.y, hit.uv.x, hit.uv.y);
    // Interpolate smooth normal
    var smooth_n: vec3<f32> = normalize(normals * geometry_uvw);
    // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
    let angles: vec3<f32> = acos(abs(vec3<f32>(
        dot(geometry_n, normalize(normals[0])),
        dot(geometry_n, normalize(normals[1])),
        dot(geometry_n, normalize(normals[2]))
    )));

    let angle_tan: vec3<f32> = clamp(tan(angles), vec3<f32>(0.0f), vec3<f32>(1.0f));
    let geometry_offset: f32 = dot(diffs * angle_tan, geometry_uvw);
    // Interpolate final barycentric texture coordinates between UV's of the respective vertices
    let barycentric: vec2<f32> = fract(mat3x2<f32>(t4.zw, t5.xy, t5.zw) * geometry_uvw);
    // Sample material
    var material: Material = instance_material[hit.instance_index];
    // Read material textures
    let albedo_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 3u];
    if (albedo_texture_id != UINT_MAX) {
        material.albedo = textureSample(albedo_texture_id, barycentric).xyz * INV_255;
    }

    let normal_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 4u];
    if (normal_texture_id != UINT_MAX) {
        let uv0: vec2<f32> = t4.zw;
        let uv1: vec2<f32> = t5.xy;
        let uv2: vec2<f32> = t5.zw;
        let tbn: mat3x3<f32> = normalMapTBN(t[0], t[1], t[2], uv0, uv1, uv2, smooth_n);
        var normal_data: vec3<f32> = normalize(textureSample(normal_texture_id, barycentric).xyz * INV_255 * 2.0f - 1.0f);
        normal_data.y = -normal_data.y;
        smooth_n = normalize(tangentToWorldNormalMap(normal_data, tbn));
    }

    let emissive_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 5u];
    if (emissive_texture_id != UINT_MAX) {
        material.emissive = textureSample(emissive_texture_id, barycentric).xyz * INV_255;
    }

    let roughness_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 6u];
    if (roughness_texture_id != UINT_MAX) {
        material.roughness = textureSample(roughness_texture_id, barycentric).x * INV_255;
    }

    let metallic_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 7u];
    if (metallic_texture_id != UINT_MAX) {
        material.metallic = textureSample(metallic_texture_id, barycentric).x * INV_255;
    }

    let n_dot_v: f32 = abs(dot(smooth_n, - ray.unit_direction));

    let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
    let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);

    var final_color: vec3<f32>;
    // Determine local color considering PBR attributes and lighting
    for (var i: u32 = 0u; i < uniforms_uint.samples; i++) {
        let local_sampled: SampledColor = sample(material, ray, random_state, smooth_n, geometry_n, geometry_offset);
        random_state = local_sampled.random_state;
        final_color += local_sampled.color;
    }
    // Average the color over samples
    final_color /= f32(uniforms_uint.samples);


    // Calculate primary light sources for this pass if ray hits non translucent object

    // If ray reflects from inside or onto an transparent object,
    // the surface faces in the opposite direction as usual
    var sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));
    smooth_n *= - sign_dir;

    // Sample environment map if present
    if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {
            let reflect_component: f32 = rgb_to_greyscale(fresnelSchlick(f0, n_dot_v));
            let diffuse_component: f32 = (1.0f - material.metallic) * (1.0f - material.transmission);
            let refract_component: f32 = material.transmission;
            // Calculate ratio of reflection and transmission
            let total_component: f32 = reflect_component + diffuse_component + refract_component;
            let total_component_inv: f32 = 1.0f / total_component;
            let reflect_ratio: f32 = reflect_component * total_component_inv;
            let diffuse_ratio: f32 = diffuse_component * total_component_inv;
            let refract_ratio: f32 = refract_component * total_component_inv;
            // Does ray reflect or refract or diffuse?

            let reflect_diffuse_ray_dir: vec3<f32> = reflect(ray.unit_direction, smooth_n);
            let reflect_importancy_factor: vec3<f32> = mix(vec3<f32>(1.0f), material.albedo, material.metallic);
            let diffuse_importancy_factor: vec3<f32> = material.albedo;
            let env_color_reflect_diffuse: vec3<f32> = env_map_sample(reflect_diffuse_ray_dir * vec3<f32>(1.0f, 1.0f, -1.0f), material.roughness);

            final_color += env_color_reflect_diffuse * reflect_ratio * reflect_importancy_factor;
            final_color += env_color_reflect_diffuse * diffuse_ratio * diffuse_importancy_factor;

            if (material.transmission > 0.0f) {
                let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
                // Refract ray depending on IOR of material
                let refract_ray_dir: vec3<f32> = refract(ray.unit_direction, smooth_n, eta);
                let refract_importancy_factor: vec3<f32> = material.albedo;
                let env_color_refract: vec3<f32> = env_map_sample(refract_ray_dir * vec3<f32>(1.0f, 1.0f, -1.0f), material.roughness) * refract_importancy_factor;
                final_color += env_color_refract * refract_ratio;
            }
    } else {
        // If no environment map is present, use ambient color
        final_color += material.albedo * uniforms_float.ambient;
    }
    // Return final pixel color
    return SampledColor(final_color, random_state);
}

@compute
@workgroup_size(8, 8)
fn compute(
    @builtin(workgroup_id) workgroup_id : vec3<u32>,
    @builtin(local_invocation_id) local_invocation_id : vec3<u32>,
    @builtin(global_invocation_id) global_invocation_id : vec3<u32>,
    @builtin(local_invocation_index) local_invocation_index: u32,
    @builtin(num_workgroups) num_workgroups: vec3<u32>
) {
    // Get texel position of screen
    let screen_pos: vec2<u32> = global_invocation_id.xy;
    let buffer_index: u32 = global_invocation_id.x + uniforms_uint.render_size.x * global_invocation_id.y;

    // Get based clip space coordinates (with 0.0 at upper left corner)
    // Load attributes from fragment shader out ofad(texture_triangle_id, screen_pos).x;
    // Subtract 1 to have 0 as invalid index
    let instance_index: u32 = texture_offset[buffer_index * 2u] - 1u;
    let triangle_index: u32 = texture_offset[buffer_index * 2u + 1u] - 1u;

    let screen_space: vec2<f32> = vec2<f32>(f32(global_invocation_id.x) / f32(uniforms_uint.render_size.x), - f32(global_invocation_id.y) / f32(uniforms_uint.render_size.y)) * 2.0f + vec2<f32>(-1.0f, 1.0f);
    // let clip_space: vec3<f32> = vec3<f32>(screen_space.x, - screen_space.y, 1.0f);
    let view_direction: vec3<f32> = normalize(uniforms_float.inv_view_matrix * vec3<f32>(screen_space, 1.0f) * vec3<f32>(1.0f, 1.0f, -1.0f));

    if (instance_index == UINT_MAX && triangle_index == UINT_MAX) {

        var env_color: vec3<f32> = vec3<f32>(0.0f);
        if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {

            // let env_color: vec3<f32> = textureSample(shift_out_float, environment_map_sampler, vec2(0.0f,0.0f)).xyz;
            env_color = env_map_sample(view_direction, 0.0f);
        } else {
            // If no environment map is present, use ambient color
            env_color = uniforms_float.ambient;
        }

        // If there is no triangle render ambient color 
        textureStore(compute_out, screen_pos, 0, vec4<f32>(env_color, 1.0f));
        // And overwrite position with 0 0 0 0
        if (uniforms_uint.is_temporal == 1u) {
            // Store position in target
            textureStore(compute_out, screen_pos, 1, vec4<f32>(0.0f));
        }
        return;
    }

    let absolute_position: vec3<f32> = textureLoad(texture_absolute_position, screen_pos, 0).xyz;
    let uv: vec2<f32> = textureLoad(texture_uv, screen_pos, 0).xy;

    // let clip_space: vec2<f32> = vec2<f32>(screen_pos) / vec2<f32>(num_workgroups.xy * 8u);
    let uvw: vec3<f32> = vec3<f32>(uv, 1.0f - uv.x - uv.y);
    // Generate hit struct for pathtracer
    let init_hit: Hit = Hit(uvw.yz, distance(absolute_position, uniforms_float.camera_position), instance_index, triangle_index);

    var final_color = vec3<f32>(0.0f);


    var random_state: u32 = stream(hash(uniforms_uint.frame), global_invocation_id.x + uniforms_uint.render_size.x * global_invocation_id.y);
    // Generate sample

    let sampled_color: SampledColor = lightTrace(init_hit, absolute_position, uniforms_float.camera_position, screen_space, random_state);
    random_state = sampled_color.random_state;
    final_color += sampled_color.color;

    // Render to compute target
    textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));
}