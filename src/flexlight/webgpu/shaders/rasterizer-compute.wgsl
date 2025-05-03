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
const PHI: f32 = 1.61803398874989484820459;
const SQRT3: f32 = 1.7320508075688772;
const POW32: f32 = 4294967296.0;
const MAX_SAFE_INTEGER_FOR_F32: f32 = 8388607.0;
const MAX_SAFE_INTEGER_FOR_F32_U: u32 = 8388607u;
const UINT_MAX: u32 = 4294967295u;
const BIAS: f32 = 0.0000152587890625;
// const BIAS: f32 = 0.0009765625;
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

    min_importancy: f32,
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

struct Ray {
    origin: vec3<f32>,
    unit_direction: vec3<f32>,
};

struct Material {
    albedo: vec3<f32>,
    emissive: vec3<f32>,
    roughness: f32,
    metallic: f32,
    transmission: f32,
    ior: f32
};

struct Light {
    position: vec3<f32>,
    color: vec3<f32>,
    intensity: f32,
    variance: f32
};

struct Hit {
    uv: vec2<f32>,
    distance: f32,
    instance_index: u32,
    triangle_index: u32
};

/*
struct Sample {
    color: vec3<f32>,
    render_id_w: f32
}
*/

struct SampledColor {
    color: vec3<f32>,
    random_state: u32
}


fn access_triangle(index: u32) -> vec4<f32> {
    // Divide triangle index by 2048 * 2048 to get layer
    let layer: u32 = index >> 22u;
    // Get height of triangle
    let height: u32 = (index >> 11u) & 0x7FFu;
    // Get width of triangle
    let width: u32 = index & 0x7FFu;
    // Return triangle
    return textureLoad(triangles, vec2<u32>(width, height), layer, 0);
}

fn access_triangle_bvh(index: u32) -> vec4<u32> {
    // Divide triangle index by 2048 * 2048 to get layer
    let layer: u32 = index >> 22u;
    // Get height of triangle
    let height: u32 = (index >> 11u) & 0x7FFu;
    // Get width of triangle
    let width: u32 = index & 0x7FFu;
    // Return triangle
    return textureLoad(triangle_bvh, vec2<u32>(width, height), layer, 0);
}



fn access_triangle_bounding_vertices(index: u32) -> vec4<f32> {
    // Fetch from texture
    // Divide triangle index by 2048 * 2048 to get layer
    let layer: u32 = index >> 22u;
    // Get height of triangle
    let height: u32 = (index >> 11u) & 0x7FFu;
    // Get width of triangle
    let width: u32 = index & 0x7FFu;
    return textureLoad(triangle_bounding_vertices, vec2<u32>(width, height), layer, 0);
}


fn access_texture_data(index: u32) -> vec4<u32> {
    // Divide triangle index by 2048 * 2048 to get layer
    let layer: u32 = index >> 22u;
    // Get height of triangle
    let height: u32 = (index >> 11u) & 0x7FFu;
    // Get width of triangle
    let width: u32 = index & 0x7FFu;
    return textureLoad(texture_data, vec2<u32>(width, height), layer, 0);
    // return vec4<u32>(255u, 255u, 255u, 1u);
}

fn textureSample(index: u32, uv: vec2<f32>) -> vec4<f32> {
    
    let texture_instance_offset: u32 = index * TEXTURE_INSTANCE_SIZE;
    // Fetch data from texture instance buffer
    let texture_data_offset: u32 = texture_instance[texture_instance_offset];
    let width: u32 = texture_instance[texture_instance_offset + 2u];
    let height: u32 = texture_instance[texture_instance_offset + 3u];

    // WebGPU quirk of having upsidedown height for textures
    let texel_position: vec2<f32> = uv * vec2<f32>(f32(width), f32(height));
    let texel_position_u32: vec2<u32> = vec2<u32>(u32(texel_position.x), u32(texel_position.y));

    let texel_position_mat: mat4x2<f32> = mat4x2<f32>(texel_position, texel_position, texel_position, texel_position);


    let t_texel_pos_u32_x: vec4<u32> = vec4<u32>(texel_position_u32.x + 0u, texel_position_u32.x + 1u, texel_position_u32.x + 0u, texel_position_u32.x + 1u);
    let t_texel_pos_u32_y: vec4<u32> = vec4<u32>(texel_position_u32.y + 0u, texel_position_u32.y + 0u, texel_position_u32.y + 1u, texel_position_u32.y + 1u);

    let texel_pos: mat4x2<f32> = mat4x2<f32>(
        floor(texel_position + vec2<f32>(0.0f, 0.0f)),
        floor(texel_position + vec2<f32>(1.0f, 0.0f)),
        floor(texel_position + vec2<f32>(0.0f, 1.0f)),
        floor(texel_position + vec2<f32>(1.0f, 1.0f))
    );

    let difference: mat4x2<f32> = texel_pos - texel_position_mat;

    var texel_weights: vec4<f32> = vec4<f32>(
        abs(difference[0].x * difference[0].y),
        abs(difference[1].x * difference[1].y),
        abs(difference[2].x * difference[2].y),
        abs(difference[3].x * difference[3].y),
    );
    
    // Convert to index

    // let texel_index_00: u32 = texture_data_offset + u32(texel_pos[0].x) + u32(texel_pos[0].y) * width;
    // let texel_index_10: u32 = texture_data_offset + u32(texel_pos[1].x) + u32(texel_pos[1].y) * width;
    // let texel_index_01: u32 = texture_data_offset + u32(texel_pos[2].x) + u32(texel_pos[2].y) * width;
    //let texel_index_11: u32 = texture_data_offset + u32(texel_pos[3].x) + u32(texel_pos[3].y) * width;

    let texel_index: vec4<u32> = texture_data_offset + t_texel_pos_u32_x + t_texel_pos_u32_y * width;
    // Fetch texel and return result
    let uint_data_00: vec4<u32> = access_texture_data(texel_index.x);
    let uint_data_10: vec4<u32> = access_texture_data(texel_index.y);
    let uint_data_01: vec4<u32> = access_texture_data(texel_index.z);
    let uint_data_11: vec4<u32> = access_texture_data(texel_index.w);

    let float_data: mat4x4<f32> = mat4x4<f32>(
        f32(uint_data_00.x), f32(uint_data_00.y), f32(uint_data_00.z), f32(uint_data_00.w),
        f32(uint_data_10.x), f32(uint_data_10.y), f32(uint_data_10.z), f32(uint_data_10.w),
        f32(uint_data_01.x), f32(uint_data_01.y), f32(uint_data_01.z), f32(uint_data_01.w),
        f32(uint_data_11.x), f32(uint_data_11.y), f32(uint_data_11.z), f32(uint_data_11.w)
    );
    

    // Add weighted texels
    return float_data * texel_weights.wzyx;
}

struct Random {
    state: u32,
    value: f32
};

struct RandomSphere {
    state: u32,
    value: vec3<f32>
};

struct RandomHemisphere {
    state: u32,
    value: vec3<f32>
};

fn pcg(state: u32) -> Random {
    // PCG random number generator
    // Reference: http://www.pcg-random.org/
    var new_state: u32 = state * 747796405u + 2891336453u;
    let word: u32 = ((new_state >> ((new_state >> 28u) + 4u)) ^ new_state) * 277803737u;
    let result: u32 = (word >> 22u) ^ word;
    // Return random f32 between 0 and 1
    let random: f32 = f32(result) / f32(UINT_MAX);
    return Random(new_state, random);
}

fn normal_distribution(state: u32) -> Random {
    let r1: Random = pcg(state);
    let r2: Random = pcg(r1.state);
    // Sample normal distribution
    let theta: f32 = 2.0f * PI * r1.value;
    let rho: f32 = sqrt(-2.0f * clamp(log(r2.value), - MAX_SAFE_INTEGER_FOR_F32, 0.0f));
    return Random(r2.state, rho * cos(theta));
}

fn random_sphere(state: u32) -> RandomSphere {
    let x: Random = normal_distribution(state);
    let y: Random = normal_distribution(x.state);
    let z: Random = normal_distribution(y.state);
    return RandomSphere(z.state, normalize(vec3<f32>(x.value, y.value, z.value)));
}

fn random_hemisphere(state: u32, normal: vec3<f32>) -> RandomHemisphere {
    let random_sphere: RandomSphere = random_sphere(state);
    // If the random sphere is in the same hemisphere as the normal, return it
    if(dot(random_sphere.value, normal) > 0.0f) {
        return RandomHemisphere(random_sphere.state, random_sphere.value);
    } else {
        // Otherwise, return the opposite direction
        return RandomHemisphere(random_sphere.state, - random_sphere.value);
    }
}

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
fn moellerTrumboreCull(a: vec3<f32>, b: vec3<f32>, c: vec3<f32>, ray: Ray, l: f32) -> bool {
    let edge1 = b - a;
    let edge2 = c - a;
    let pvec = cross(ray.unit_direction, edge2);
    let det = dot(edge1, pvec);
    let inv_det = 1.0f / det;
    if(det < BIAS) {
        return false;
    }
    let tvec = ray.origin - a;
    let u: f32 = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) {
        return false;
    }
    let qvec: vec3<f32> = cross(tvec, edge1);
    let v: f32 = dot(ray.unit_direction, qvec) * inv_det;
    if(v < BIAS || u + v > 1.0f) {
        return false;
    }
    let s: f32 = dot(edge2, qvec) * inv_det;
    return (s <= l && s > BIAS);
}

// Bounding volume intersection test
fn rayBoundingVolume(min_corner: vec3<f32>, max_corner: vec3<f32>, ray: Ray, max_len: f32) -> f32 {
    let inv_dir: vec3<f32> = 1.0f / ray.unit_direction;
    let v0: vec3<f32> = (min_corner - ray.origin) * inv_dir;
    let v1: vec3<f32> = (max_corner - ray.origin) * inv_dir;
    let tmin: f32 = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));
    let tmax: f32 = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));

    if (tmax >= max(tmin, 0.0f) && tmin < max_len) {
        return tmin;
    } else {
        return POW32;
    }
}

// Simplified rayTracer to only test if ray intersects anything
fn shadowTraverseTriangleBVH(instance_index: u32, ray: Ray, l: f32) -> bool {
    // Maximal distance a triangle can be away from the ray origin
    let instance_uint_offset = instance_index * INSTANCE_UINT_SIZE;

    let inverse_transform: Transform = instance_transform[instance_index * 2u + 1u];
    let inverse_dir = inverse_transform.rotation * ray.unit_direction;

    let t_ray = Ray(
        inverse_transform.rotation * (ray.origin + inverse_transform.shift),
        normalize(inverse_dir)
    );
    let max_len: f32 = length(inverse_dir) * l;

    let instance_bvh_offset: u32 = instance_uint[instance_uint_offset + 1u];
    let instance_vertex_offset: u32 = instance_uint[instance_uint_offset + 2u];
    
    var stack: array<u32, 24> = array<u32, 24>();
    var stack_index: u32 = 1u;
    
    while (stack_index > 0u && stack_index < 24u) {
        stack_index -= 1u;
        let node_index: u32 = stack[stack_index];

        let bvh_offset: u32 = instance_bvh_offset + node_index * BVH_TRIANGLE_SIZE;
        let vertex_offset: u32 = instance_vertex_offset + node_index * TRIANGLE_BOUNDING_VERTICES_SIZE;

        let indicator_and_children: vec3<u32> = access_triangle_bvh(bvh_offset).xyz;

        let bv0 = access_triangle_bounding_vertices(vertex_offset);
        let bv1 = access_triangle_bounding_vertices(vertex_offset + 1u);
        let bv2 = access_triangle_bounding_vertices(vertex_offset + 2u);

        if (indicator_and_children.x == 0u) {
            if (moellerTrumboreCull(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), vec3<f32>(bv1.zw, bv2.x), t_ray, max_len)) {
                return true;
            }

            if (indicator_and_children.z != UINT_MAX) {
                let bv3 = access_triangle_bounding_vertices(vertex_offset + 3u);
                let bv4 = access_triangle_bounding_vertices(vertex_offset + 4u);
                if (moellerTrumboreCull(bv2.yzw, bv3.xyz, vec3<f32>(bv3.w, bv4.xy), t_ray, max_len)) {
                    return true;
                }   
            }
        } else {
            let dist0: f32 = rayBoundingVolume(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), t_ray, max_len);
            var dist1: f32 = POW32;
            if (indicator_and_children.z != UINT_MAX) {
                dist1 = rayBoundingVolume(vec3<f32>(bv1.zw, bv2.x), bv2.yzw, t_ray, max_len);
            }

            let near_child = select(indicator_and_children.z, indicator_and_children.y, dist0 < dist1);
            let far_child = select(indicator_and_children.y, indicator_and_children.z, dist0 < dist1);

            if (max(dist0, dist1) != POW32) {
                stack[stack_index] = far_child;
                stack_index += 1u;
            }
            if (min(dist0, dist1) != POW32) {
                stack[stack_index] = near_child;
                stack_index += 1u;
            }
        }
    }
    
    // If nothing was hit, return false (not in shadow)
    return false;
}

// Simplified rayTracer to only test if ray intersects anything
fn shadowTraverseInstanceBVH(ray: Ray, l: f32) -> bool {
    // Get texture size as max iteration value
    var stack = array<u32, 16>();
    var stack_index: u32 = 1u;

    while (stack_index > 0u && stack_index < 16u) {
        stack_index -= 1u;
        let node_index: u32 = stack[stack_index];

        let bvh_offset: u32 = node_index * BVH_INSTANCE_SIZE;
        let vertex_offset: u32 = node_index * INSTANCE_BOUNDING_VERTICES_SIZE;
        
        let indicator = instance_bvh[bvh_offset];
        let child0 = instance_bvh[bvh_offset + 1u];
        let child1 = instance_bvh[bvh_offset + 2u];

        let bv0 = instance_bounding_vertices[vertex_offset];
        let bv1 = instance_bounding_vertices[vertex_offset + 1u];
        let bv2 = instance_bounding_vertices[vertex_offset + 2u];

        let dist0 = rayBoundingVolume(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), ray, l);
        
        var dist1: f32 = POW32;
        if (child1 != UINT_MAX) {
            dist1 = rayBoundingVolume(vec3<f32>(bv1.zw, bv2.x), bv2.yzw, ray, l);
        }

        let dist_near = min(dist0, dist1);
        let dist_far = max(dist0, dist1);
        let near_child = select(child1, child0, dist0 < dist1);
        let far_child = select(child0, child1, dist0 < dist1);

        if (indicator == 0u) {
            // If node is a triangle, test for intersection, closest first
            if (dist_near != POW32) {
                if (shadowTraverseTriangleBVH(near_child, ray, l)) {
                    return true;
                }
            }
            if (dist_far != POW32) {
                if (shadowTraverseTriangleBVH(far_child, ray, l)) {
                    return true;
                }
            }
        } else {
            // If node is an AABB, push children to stack, furthest first
            if (dist_far != POW32) {
                stack[stack_index] = far_child;
                stack_index += 1u;
            }
            if (dist_near != POW32) {
                stack[stack_index] = near_child;
                stack_index += 1u;
            }
        }
    }
    // If nothing was hit, return false (not in shadow)
    return false;
}

fn trowbridgeReitz(alpha: f32, n_dot_h: f32) -> f32 {
    let numerator: f32 = alpha * alpha;
    let denom: f32 = n_dot_h * n_dot_h * (numerator - 1.0f) + 1.0f;
    return numerator / max(PI * denom * denom, BIAS);
}

fn schlickBeckmann(alpha: f32, n_dot_x: f32) -> f32 {
    let k: f32 = alpha * 0.5f;
    let denom: f32 = max(n_dot_x * (1.0f - k) + k, BIAS);
    return n_dot_x / denom;
}

fn smith(alpha: f32, n_dot_v: f32, n_dot_l: f32) -> f32 {
    return schlickBeckmann(alpha, n_dot_v) * schlickBeckmann(alpha, n_dot_l);
}

fn fresnel(f0: vec3<f32>, theta: f32) -> vec3<f32> {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - theta, 5.0f);
}

fn forwardTrace(material: Material, light_dir: vec3<f32>, light_color: vec3<f32>, light_intensity: f32, n: vec3<f32>, v: vec3<f32>) -> vec3<f32> {
    let len_p1: f32 = 1.0f + length(light_dir);
    // Apply inverse square law
    let brightness: vec3<f32> = light_color * light_intensity / (len_p1 * len_p1);

    let l: vec3<f32> = normalize(light_dir);
    let h: vec3<f32> = normalize(v + l);

    let v_dot_h: f32 = max(dot(v, h), 0.0f);
    let n_dot_h: f32 = max(dot(n, h), 0.0f);
    let n_dot_l: f32 = max(dot(n, l), 0.0f);
    let n_dot_v: f32 = max(dot(n, v), 0.0f);

    let alpha: f32 = material.roughness * material.roughness;
    let brdf: f32 = mix(1.0f, n_dot_v, material.metallic);
    let f0: vec3<f32> = material.albedo * brdf;

    let ks: vec3<f32> = fresnel(f0, v_dot_h);
    let kd: vec3<f32> = (1.0f - ks) * (1.0f - material.metallic);
    let lambert: vec3<f32> = material.albedo * INV_PI;

    let cook_torrance_numerator: vec3<f32> = ks * trowbridgeReitz(alpha, n_dot_h) * smith(alpha, n_dot_v, n_dot_l);
    let cook_torrance_denominator: f32 = max(4.0f * n_dot_v * n_dot_l, BIAS);

    let cook_torrance: vec3<f32> = cook_torrance_numerator / cook_torrance_denominator;


    // Use cook-torrance for specular and lambert for diffuse
    let radiance: vec3<f32> = kd * lambert + cook_torrance;
    // Add radiance term using sky

    // Outgoing light to camera
    return radiance * n_dot_l * brightness;
}

fn sampleSkyBox(material: Material, light_dir: vec3<f32>, light_color: vec3<f32>,  n: vec3<f32>, v: vec3<f32>) -> vec3<f32> {
    let l: vec3<f32> = normalize(light_dir);
    let h: vec3<f32> = normalize(v + l);

    let v_dot_h: f32 = max(dot(v, h), 0.0f);
    let n_dot_h: f32 = max(dot(n, h), 0.0f);
    let n_dot_l: f32 = max(dot(n, l), 0.0f);
    let n_dot_v: f32 = max(dot(n, v), 0.0f);

    let alpha: f32 = material.roughness * material.roughness;
    let brdf: f32 = mix(1.0f, n_dot_v, material.metallic);
    let f0: vec3<f32> = material.albedo * brdf;

    let ks: vec3<f32> = fresnel(f0, v_dot_h);
    let kd: vec3<f32> = (1.0f - ks) * (1.0f - material.metallic);
    let lambert: vec3<f32> = material.albedo * INV_PI;

    let cook_torrance_numerator: vec3<f32> = ks * trowbridgeReitz(alpha, n_dot_h) * smith(alpha, n_dot_v, n_dot_l);
    let cook_torrance_denominator: f32 = max(4.0f * n_dot_v * n_dot_l, BIAS);

    let cook_torrance: vec3<f32> = cook_torrance_numerator / cook_torrance_denominator;


    // Use cook-torrance for specular and lambert for diffuse
    let radiance: vec3<f32> = kd * lambert + cook_torrance;
    // Add radiance term using sky

    // Outgoing light to camera
    return radiance * n_dot_l * light_color;
}


fn sample(material: Material, camera_ray: Ray, init_random_state: u32, smooth_n: vec3<f32>, geometry_offset: f32) -> SampledColor {
    var local_color: vec3<f32> = vec3<f32>(0.0f);

    var random_state: u32 = init_random_state;

    let size: u32 = u32(arrayLength(&lights));
    for (var i: u32 = 0u; i < size; i++) {
        let light_offset: u32 = i;
        // Read light from storage buffer
        let light: Light = lights[light_offset];
        // Yeild random sphere and update state
        let random_sphere: RandomSphere = random_sphere(random_state);
        random_state = random_sphere.state;

        let light_position = light.position + random_sphere.value * light.variance;
        // Alter light source position according to variation.
        let dir: vec3<f32> = light_position - camera_ray.origin;

        let color_for_light: vec3<f32> = forwardTrace(material, dir, light.color, light.intensity, smooth_n, - camera_ray.unit_direction);
        let color_intensity: f32 = length(color_for_light);

        let unit_light_dir: vec3<f32> = normalize(dir);
        // Compute quick exit criterion to potentially skip expensive shadow test
        let show_color: bool = color_intensity == 0.0f;
        let show_shadow: bool = dot(smooth_n, unit_light_dir) < 0.0f;
        // Test if in shadow
        if (show_color) {
            local_color += color_for_light;
        }

        if (show_shadow) {
            continue;
        }
        // Apply geometry offset
        let offset_target: vec3<f32> = camera_ray.origin + geometry_offset * smooth_n;
        let light_ray: Ray = Ray(offset_target, unit_light_dir);
        if (!shadowTraverseInstanceBVH(light_ray, length(dir))) {
            local_color += color_for_light;
        }
    }

    // Apply emissive texture and ambient light
    let base_luminance: vec3<f32> = material.emissive;
    return SampledColor(local_color + base_luminance, random_state);
}


fn env_map_sample(dir: vec3<f32>) -> vec3<f32> {
    let len:f32 = sqrt (dir.x * dir.x + dir.z * dir.z);
    var s:f32 = acos( dir.x / len);
    if (dir.z < 0) {
        s = 2.0 * PI - s;
    }
    s = s / (2.0 * PI);
    var tex_coord: vec2<f32> = vec2(s , ((asin(dir.y) * -2.0 / PI ) + 1.0) * 0.5);
    // return vec3<f32>(0.5f, 0.5f, 0.5f);
    return textureSampleLevel(environment_map, environment_map_sampler, tex_coord, 0.0f).xyz * 255.0f;
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
    // Assemble and transform normals
    let normals: mat3x3<f32> = transform.rotation * mat3x3<f32>(t2.yzw, t3.xyz, vec3<f32>(t3.w, t4.xy));
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
    let barycentric: vec2<f32> = mat3x2<f32>(t4.zw, t5.xy, t5.zw) * geometry_uvw;
    // Sample material
    var material: Material = instance_material[hit.instance_index];
    // Read material textures
    let albedo_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 3u];
    if (albedo_texture_id != UINT_MAX) {
        material.albedo = textureSample(albedo_texture_id, barycentric).xyz * INV_255;
    }

    let normal_texture_id: u32 = instance_uint[hit.instance_index * INSTANCE_UINT_SIZE + 4u];
    if (normal_texture_id != UINT_MAX) {
        let normal_data: vec3<f32> = normalize(textureSample(normal_texture_id, barycentric).xyz * 2.0f - 255.0f);
        let delta_uv1: vec2<f32> = t4.zw - t5.xy;
        let delta_uv2: vec2<f32> = t5.zw - t5.xy;  
        // With the required data for calculating tangents and bitangents we can start following the equation from the previous section:
        let f: f32 = 1.0f / (delta_uv1.x * delta_uv2.y - delta_uv2.x * delta_uv1.y);
        let tangent: vec3<f32> = f * (delta_uv2.y * edge1 - delta_uv1.y * edge2);
        let bitangent: vec3<f32> = f * (delta_uv1.x * edge2 - delta_uv2.x * edge1);

        let tbn: mat3x3<f32> = mat3x3<f32>(normalize(tangent), normalize(cross(smooth_n, tangent)), smooth_n);

        smooth_n = normalize(tbn * normal_data);
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

    // ray = Ray(ray.origin, normalize(ray.origin - old_ray_origin));
    // Determine local color considering PBR attributes and lighting
    let local_sampled: SampledColor = sample(material, ray, random_state, smooth_n, geometry_offset);
    var final_color: vec3<f32> = local_sampled.color;
    // let skybox_factor: vec3<f32> = vec3<f32>(0.0f);


    random_state = local_sampled.random_state;
    // Calculate primary light sources for this pass if ray hits non translucent object

    // If ray reflects from inside or onto an transparent object,
    // the surface faces in the opposite direction as usual
    var sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));
    smooth_n *= - sign_dir;


    if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {
        let inv_samples: f32 = 1.0f / f32(uniforms_uint.samples);

        for (var i: u32 = 0u; i < uniforms_uint.samples; i++) {
            // Bias ray direction on material properties
            // Generate pseudo random vector for diffuse reflection
            let random_sphere: RandomSphere = random_sphere(random_state);
            random_state = random_sphere.state;
            let diffuse_random_dir: vec3<f32> = normalize(smooth_n + random_sphere.value);
            let brdf: f32 = mix(1.0f, abs(dot(smooth_n, - ray.unit_direction)), material.metallic);
            // Alter normal according to roughness value
            let roughness_brdf: f32 = material.roughness * brdf;
            let rough_n: vec3<f32> = normalize(mix(smooth_n, diffuse_random_dir, roughness_brdf));

            let h: vec3<f32> = normalize(rough_n - ray.unit_direction);
            let v_dot_h = max(dot(- ray.unit_direction, h), 0.0f);
            let f0: vec3<f32> = material.albedo * brdf;
            let f: vec3<f32> = fresnel(f0, v_dot_h);

            let fresnel_reflect: f32 = max(f.x, max(f.y, f.z));
            // Yeild random value between 0 and 1 and update state
            let random_value: Random = pcg(random_state);
            random_state = random_value.state;

            var outgoing_ray_dir: vec3<f32>;
            // Handle translucency and skip rest of light calculation
            if (material.transmission * fresnel_reflect <= abs(random_value.value)) {
                // Calculate perfect reflection ray
                outgoing_ray_dir = reflect(ray.unit_direction, smooth_n);
            } else {
                let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
                // Refract ray depending on IOR of material
                outgoing_ray_dir = refract(ray.unit_direction, smooth_n, eta);
            }
            // Mix ideal and diffuse reflection/refraction
            outgoing_ray_dir = normalize(mix(outgoing_ray_dir, diffuse_random_dir, roughness_brdf));
            // Sample environment map if present
            let env_color: vec3<f32> = env_map_sample(outgoing_ray_dir * vec3<f32>(1.0f, 1.0f, -1.0f));
            final_color += material.albedo * env_color * inv_samples;
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
            env_color = env_map_sample(view_direction);
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


    var random_state: u32 = global_invocation_id.y * uniforms_uint.render_size.x + global_invocation_id.x;
    // Generate sample
    
    let sampled_color: SampledColor = lightTrace(init_hit, absolute_position, uniforms_float.camera_position, screen_space, random_state);
    random_state = sampled_color.random_state;
    final_color += sampled_color.color;
    
    // Render to compute target
    textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));
}