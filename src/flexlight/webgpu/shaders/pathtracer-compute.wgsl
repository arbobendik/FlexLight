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
@group(0) @binding(4) var shift_out_float: texture_2d_array<f32>;
@group(0) @binding(5) var shift_out_uint: texture_2d_array<u32>;
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

fn moellerTrumbore(a: vec3<f32>, b: vec3<f32>, c: vec3<f32>, ray: Ray, l: f32) -> Hit {
    let no_hit: Hit = Hit(vec2<f32>(0.0f, 0.0f), 0.0f, UINT_MAX, UINT_MAX);
    let edge1: vec3<f32> = b - a;
    let edge2: vec3<f32> = c - a;
    let pvec: vec3<f32> = cross(ray.unit_direction, edge2);
    let det: f32 = dot(edge1, pvec);
    if(abs(det) < BIAS) {
        return no_hit;
    }
    let inv_det: f32 = 1.0f / det;
    let tvec: vec3<f32> = ray.origin - a;
    let u: f32 = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) {
        return no_hit;
    }
    let qvec: vec3<f32> = cross(tvec, edge1);
    let v: f32 = dot(ray.unit_direction, qvec) * inv_det;
    let uv_sum: f32 = u + v;
    if(v < BIAS || uv_sum > 1.0f) {
        return no_hit;
    }
    let s: f32 = dot(edge2, qvec) * inv_det;
    if(s <= l && s > BIAS) {
        return Hit(vec2<f32>(u, v), s, UINT_MAX, UINT_MAX);
    } else {
        return no_hit;
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

// Test for closest ray triangle intersection
fn traverseTriangleBVH(instance_index: u32, ray: Ray, max_len: f32) -> Hit {
    // Maximal distance a triangle can be away from the ray origin
    let instance_uint_offset = instance_index * INSTANCE_UINT_SIZE;

    let inverse_transform: Transform = instance_transform[instance_index * 2u + 1u];
    let inverse_dir = inverse_transform.rotation * ray.unit_direction;

    let t_ray = Ray(
        inverse_transform.rotation * (ray.origin + inverse_transform.shift),
        normalize(inverse_dir)
    );

    let len_factor: f32 = length(inverse_dir);

    let triangle_instance_offset: u32 = instance_uint[instance_uint_offset];
    let instance_bvh_offset: u32 = instance_uint[instance_uint_offset + 1u];
    let instance_vertex_offset: u32 = instance_uint[instance_uint_offset + 2u];

    // Hit object
    // First element of vector is current closest intersection point
    var hit: Hit = Hit(vec2<f32>(0.0f, 0.0f), max_len, UINT_MAX, UINT_MAX);
    // Stack for BVH traversal
    var stack = array<u32, 24>();
    var stack_index: u32 = 1u;
    
    while (stack_index > 0u && stack_index < 24u) {
        stack_index -= 1u;
        var node_index: u32 = stack[stack_index];

        let bvh_offset: u32 = instance_bvh_offset + node_index * BVH_TRIANGLE_SIZE;
        let vertex_offset: u32 = instance_vertex_offset + node_index * TRIANGLE_BOUNDING_VERTICES_SIZE;

        let indicator_and_children: vec3<u32> = access_triangle_bvh(bvh_offset).xyz;

        let bv0 = access_triangle_bounding_vertices(vertex_offset);
        let bv1 = access_triangle_bounding_vertices(vertex_offset + 1u);
        let bv2 = access_triangle_bounding_vertices(vertex_offset + 2u);
        let bv3 = access_triangle_bounding_vertices(vertex_offset + 3u);
        let bv4 = access_triangle_bounding_vertices(vertex_offset + 4u);
        

        if (indicator_and_children.x == 0u) {
            // Run Moeller-Trumbore algorithm for both triangles
            // Test if ray even intersects
            let hit0: Hit = moellerTrumbore(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), vec3<f32>(bv1.zw, bv2.x), t_ray, hit.distance * len_factor);
            if (hit0.distance != 0.0) {
                // Calculate intersection point
                // hit = hit0;
                hit.distance = hit0.distance / len_factor;
                hit.uv = hit0.uv;
                hit.instance_index = instance_index;
                hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.y;
            }

            if (indicator_and_children.z != UINT_MAX) {
                // Test if ray even intersects
                let hit1: Hit = moellerTrumbore(bv2.yzw, bv3.xyz, vec3<f32>(bv3.w, bv4.xy), t_ray, hit.distance * len_factor);
                if (hit1.distance != 0.0) {
                    // Calculate intersection point
                    hit.distance = hit1.distance / len_factor;
                    hit.uv = hit1.uv;
                    hit.instance_index = instance_index;
                    hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.z;
                }
            }
            
        } else {
            let dist0: f32 = rayBoundingVolume(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), t_ray, hit.distance * len_factor);
            var dist1: f32 = POW32;
            if (indicator_and_children.z != UINT_MAX) {
                dist1 = rayBoundingVolume(vec3<f32>(bv1.zw, bv2.x), bv2.yzw, t_ray, hit.distance * len_factor);
            }

            let near_child = select(indicator_and_children.z, indicator_and_children.y, dist0 < dist1);
            let far_child = select(indicator_and_children.y, indicator_and_children.z, dist0 < dist1);

            // If node is an AABB, push children to stack, furthest first
            if (max(dist0, dist1) != POW32) {
                stack[stack_index] = far_child;
                // distance_stack[stack_index] = max(dist0, dist1);
                stack_index += 1u;
            }
            if (min(dist0, dist1) != POW32) {
                stack[stack_index] = near_child;
                // distance_stack[stack_index] = min(dist0, dist1);
                stack_index += 1u;
            }
        }
    }
    // Return hit object
    return hit;
}

// Simplified rayTracer to only test if ray intersects anything
fn traverseInstanceBVH(ray: Ray) -> Hit {
    // Hit object
    // Maximal distance a triangle can be away from the ray origin is POW32 at initialisation
    var hit: Hit = Hit(vec2<f32>(0.0f, 0.0f), POW32, UINT_MAX, UINT_MAX);
    // Stack for BVH traversal
    var stack = array<u32, 16>();
    var stack_index: u32 = 1u;

    while (stack_index > 0u && stack_index < 16u) {
        stack_index -= 1u;
        var node_index: u32 = stack[stack_index];
        let bvh_offset: u32 = node_index * BVH_INSTANCE_SIZE;
        let vertex_offset: u32 = node_index * INSTANCE_BOUNDING_VERTICES_SIZE;
        
        // let indicator_and_children: vec3<u32> = instance_bvh[bvh_offset];
        let indicator = instance_bvh[bvh_offset];
        let child0 = instance_bvh[bvh_offset + 1u];
        let child1 = instance_bvh[bvh_offset + 2u];

        let bv0 = instance_bounding_vertices[vertex_offset];
        let bv1 = instance_bounding_vertices[vertex_offset + 1u];
        let bv2 = instance_bounding_vertices[vertex_offset + 2u];

        let dist0 = rayBoundingVolume(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), ray, hit.distance);
        
        var dist1: f32 = POW32;
        if (child1 != UINT_MAX) {
            dist1 = rayBoundingVolume(vec3<f32>(bv1.zw, bv2.x), bv2.yzw, ray, hit.distance);
        }

        let dist_near = min(dist0, dist1);
        let dist_far = max(dist0, dist1);
        let near_child = select(child1, child0, dist0 < dist1);
        let far_child = select(child0, child1, dist0 < dist1);

        if (indicator == 0u) {
            // If node is an instance, test for intersection, closest first
            if (dist_near != POW32) {
                let new_hit: Hit = traverseTriangleBVH(near_child, ray, hit.distance);
                if (new_hit.distance < hit.distance) {
                    hit = new_hit;
                }
            }
            if (dist_far != POW32 && dist_far < hit.distance) {
                let new_hit: Hit = traverseTriangleBVH(far_child, ray, hit.distance);
                if (new_hit.distance < hit.distance) {
                    hit = new_hit;
                }
            }
        } else {
            // If node is an AABB, push children to stack, furthest first
            if (dist_far != POW32) {
                stack[stack_index] = far_child;
                // distance_stack[stack_index] = dist_far;
                stack_index += 1u;
            }
            if (dist_near != POW32) {
                stack[stack_index] = near_child;
                // distance_stack[stack_index] = dist_near;
                stack_index += 1u;
            }
        }
    }
    // Return hit object
    return hit;
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

fn fresnel(f0: vec3<f32>, cos_theta: f32) -> vec3<f32> {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - cos_theta, 5.0f);
}

fn schlick(f0: f32, cos_theta: f32) -> f32 {
    return f0 + (1.0f - f0) * pow(1.0f - cos_theta, 5.0f);
}

fn forwardTrace(material: Material, light_dir: vec3<f32>, light_color: vec3<f32>, light_intensity: f32, n: vec3<f32>, v: vec3<f32>) -> vec3<f32> {
    let len_p1: f32 = 1.0f + length(light_dir);
    // Apply inverse square law
    let brightness: vec3<f32> = light_color * light_intensity / (len_p1 * len_p1);

    let l: vec3<f32> = normalize(light_dir);
    let h: vec3<f32> = normalize(v + l);

    let v_dot_h: f32 = abs(dot(v, h));
    let n_dot_h: f32 = abs(dot(n, h));
    let n_dot_l: f32 = abs(dot(n, l));
    let n_dot_v: f32 = abs(dot(n, v));


    let vm: vec3<f32> = reflect(v, n);

    let n_dot_vm: f32 = abs(dot(n, vm));
    
    let hm: vec3<f32> = normalize(l + vm);
    let n_dot_hm: f32 = max(dot(n, hm), 0.0f);

    let alpha: f32 = max(material.roughness * material.roughness, 0.05f);
    let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
    let f0: vec3<f32> = material.albedo * f0_sqrt * f0_sqrt;
    let lambert: vec3<f32> = material.albedo * INV_PI;

    let reflect_component: vec3<f32> = fresnel(f0, v_dot_h);
    let diffuse_component: vec3<f32> = (1.0f - reflect_component) * (1.0f - material.metallic) * (1.0f - material.transmission);
    let refract_component: vec3<f32> = reflect_component * material.transmission;

    let smith: f32 = smith(alpha, n_dot_v, n_dot_l);

    let cook_torrance_numerator: f32 = trowbridgeReitz(alpha, n_dot_h) * smith;
    let cook_torrance_denominator: f32 = max(4.0f * n_dot_v * n_dot_l, BIAS);
    let cook_torrance: f32 = max(cook_torrance_numerator / cook_torrance_denominator, 0.0f);

    let cook_torrance_numerator_m: f32 = trowbridgeReitz(alpha, n_dot_hm) * smith;
    let cook_torrance_denominator_m: f32 = max(4.0f * n_dot_vm * n_dot_l, BIAS);
    let cook_torrance_m: f32 = max(cook_torrance_numerator_m / cook_torrance_denominator_m, 0.0f);
    
    let radiance: vec3<f32> = diffuse_component * lambert + reflect_component * cook_torrance + refract_component * cook_torrance_m;

    // Outgoing light to camera
    return radiance * n_dot_l * brightness;
}


fn reservoirSample(material: Material, camera_ray: Ray, init_random_state: u32, smooth_n: vec3<f32>, geometry_offset: f32) -> SampledColor {
    var local_color: vec3<f32> = vec3<f32>(0.0f);
    var reservoir_length: f32 = 0.0f;
    var total_weight: f32 = 0.0f;
    var reservoir_num: u32 = 0u;
    var reservoir_weight: f32 = 0.0f;
    var reservoir_dir: vec3<f32>;

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
        // Increment light weight
        reservoir_length += 1.0f;
        // Alter light source position according to variation.
        let dir: vec3<f32> = light_position - camera_ray.origin;

        let color_for_light: vec3<f32> = forwardTrace(material, dir, light.color, light.intensity, smooth_n, - camera_ray.unit_direction);

        local_color += color_for_light;
        let weight: f32 = length(color_for_light);

        total_weight += weight;
        // Yeild random value between 0 and 1 and update state
        let random_value: Random = pcg(random_state);
        random_state = random_value.state;

        if (random_value.value * total_weight <= weight) {
            reservoir_num = i;
            reservoir_weight = weight;
            reservoir_dir = dir;
        }
    }

    let unit_light_dir: vec3<f32> = normalize(reservoir_dir);
    // Apply emissive texture and ambient light
    let base_luminance: vec3<f32> = material.emissive;
    
    // Compute quick exit criterion to potentially skip expensive shadow test
    let show_color: bool = reservoir_length == 0.0f || reservoir_weight == 0.0f;
    let show_shadow: bool = dot(smooth_n, unit_light_dir) < 0.0f;
    // Test if in shadow
    if (show_color) {
        return SampledColor(local_color + base_luminance, random_state);
    }

    if (show_shadow) {
        return SampledColor(base_luminance, random_state);
    }
    // Apply geometry offset
    let offset_target: vec3<f32> = camera_ray.origin + geometry_offset * smooth_n;
    let light_ray: Ray = Ray(offset_target, unit_light_dir);
    
    if (shadowTraverseInstanceBVH(light_ray, length(reservoir_dir))) {
        return SampledColor(base_luminance, random_state);
    } else {
        return SampledColor(local_color + base_luminance, random_state);
    }
}



fn lightTrace(init_hit: Hit, origin: vec3<f32>, camera: vec3<f32>, clip_space: vec2<f32>, init_random_state: u32) -> SampledColor {
    // Use additive color mixing technique, so start with black
    var final_color: vec3<f32> = vec3<f32>(0.0f);
    var importancy_factor: vec3<f32> = vec3<f32>(1.0f);
    var hit: Hit = init_hit;
    var ray: Ray = Ray(origin, normalize(origin - camera));
    var random_state: u32 = init_random_state;
    var add_ambient: bool = false;
    var i: u32 = 0u;
    // Iterate over each bounce and modify color accordingly
    while (true) {
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

        // Determine local color considering PBR attributes and lighting
        let local_sampled: SampledColor = reservoirSample(material, ray, random_state, smooth_n, geometry_offset);
        random_state = local_sampled.random_state;
        // Calculate primary light sources for this pass if ray hits non translucent object
        final_color += local_sampled.color * importancy_factor;

        // If ray reflects from inside or onto an transparent object,
        // the surface faces in the opposite direction as usual
        var sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));
        smooth_n *= - sign_dir;
        // Bias ray direction on material properties
        // Generate pseudo random vector for diffuse reflection
        let random_sphere: RandomSphere = random_sphere(random_state);
        random_state = random_sphere.state;
        let diffuse_random_dir: vec3<f32> = normalize(smooth_n + random_sphere.value);

        // let brdf: f32 = mix(1.0f, abs(dot(smooth_n, - ray.unit_direction)), material.metallic);
        // Alter normal according to roughness value
        // let roughness_brdf: f32 = material.roughness * brdf;
        // let rough_n: vec3<f32> = normalize(mix(smooth_n, diffuse_random_dir, roughness_brdf));

        let h: vec3<f32> = normalize(smooth_n - ray.unit_direction);
        let v_dot_h = max(dot(- ray.unit_direction, h), 0.0f);
        let v_dot_n = max(dot(smooth_n, - ray.unit_direction), 0.0f);

        // let f0: f32 = vec3<f32>((1.0f - material.ior) * (1.0f - material.ior) / ((1.0f + material.ior) * (1.0f + material.ior)));
        // let fresnel_reflect: f32 = schlick(f0, v_dot_h);
        let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
        let f0: vec3<f32> = material.albedo * f0_sqrt * f0_sqrt;
        // f0 = mix(f0, material.albedo, material.metallic);
        // Yeild random value between 0 and 1 and update state

        
        let random_value_reflect: Random = pcg(random_state);
        random_state = random_value_reflect.state;

        let reflect_component: f32 = length(fresnel(f0, v_dot_n));
        let diffuse_component: f32 = (1.0f - reflect_component) * (1.0f - material.transmission) * (1.0f - material.metallic);
        let refract_component: f32 = (1.0f - reflect_component) * material.transmission;

        let reflect_ratio: f32 = reflect_component / (reflect_component + diffuse_component + refract_component);
        let refract_ratio: f32 = refract_component / (diffuse_component + refract_component);

        // Does ray reflect or refract?
        if (reflect_ratio <= abs(random_value_reflect.value)) {
            let random_value_transmission: Random = pcg(random_state);
            random_state = random_value_transmission.state;
            // Refract or diffuse
            if (refract_ratio <= abs(random_value_transmission.value)) {
                ray.unit_direction = diffuse_random_dir;
            } else {
                let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
                // Refract ray depending on IOR of material
                ray.unit_direction = refract(ray.unit_direction, smooth_n, eta);
            }
            
            importancy_factor = importancy_factor * material.albedo;
        } else {
            ray.unit_direction = reflect(ray.unit_direction, smooth_n);
            // importancy_factor = importancy_factor * material.albedo;
            importancy_factor = importancy_factor * mix(vec3<f32>(1.0f), material.albedo, reflect_ratio);
        }

        ray.unit_direction = normalize(mix(ray.unit_direction, diffuse_random_dir, material.roughness * material.roughness));
        
        /*
        let ks: f32 = length(fresnel(f0, v_dot_n));
        let diffuse: f32 = (1.0f - ks) * (1.0f - material.metallic);

        var specular_ray_dir: vec3<f32> = ray.unit_direction;

        let random_value_transmission: Random = pcg(random_state);
        random_state = random_value_transmission.state;
        // Handle translucency and skip rest of light calculation
        if (material.transmission * (1.0f - ks) <= abs(random_value_transmission.value)) {
            // Calculate perfect reflection ray
            specular_ray_dir = reflect(ray.unit_direction, smooth_n);
        } else {
            let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
            // Refract ray depending on IOR of material
            specular_ray_dir = refract(ray.unit_direction, smooth_n, eta);
        }
        // Mix ideal and diffuse reflection/refraction
        specular_ray_dir = normalize(mix(specular_ray_dir, diffuse_random_dir, material.roughness * material.roughness));


        let random_value_specular: Random = pcg(random_state);
        random_state = random_value_specular.state;

        let diffuse_ratio: f32 = diffuse * (1.0f - material.transmission) / (ks + diffuse);
        
        if (length(diffuse_ratio) <= random_value_specular.value) {
            ray.unit_direction = specular_ray_dir;
            importancy_factor = importancy_factor * mix(material.albedo, vec3<f32>(1.0f), diffuse_ratio);
        } else {
            ray.unit_direction = diffuse_random_dir;
            importancy_factor = importancy_factor * material.albedo;
        }
        */
        

        // Test for early termination, avoiding last bounce
        i = i + 1u;
        if (i >= uniforms_uint.max_reflections || length(importancy_factor) < uniforms_float.min_importancy * SQRT3) {
            add_ambient = false;
            break;
        }
        // Calculate next intersection
        ray.origin = geometry_offset * ray.unit_direction + ray.origin;
        hit = traverseInstanceBVH(ray);
        // Stop loop if there is no intersection and ray goes in the void
        if (hit.instance_index == UINT_MAX) {
            add_ambient = true;
            break;
        }
        // Project ray origin to hit point
        ray.origin += hit.distance * ray.unit_direction;
    }


    // Sample environment map if present
    if (add_ambient) {
        if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {
            let dir: vec3<f32> = ray.unit_direction * vec3<f32>(1.0f, 1.0f, -1.0f);
            let env_color: vec3<f32> = env_map_sample(dir, clip_space);
            // let env_color: vec3<f32> = textureSampleLevel(environment_map, environment_map_sampler, ray.unit_direction * vec3<f32>(1.0f, 1.0f, -1.0f), 0.0f).xyz;
            final_color += importancy_factor * env_color;
        } else {
            // If no environment map is present, use ambient color
            final_color += importancy_factor * uniforms_float.ambient;
        }
    }
    // Return final pixel color
    return SampledColor(final_color, random_state);
}

fn env_map_sample(dir: vec3<f32>, clip_space: vec2<f32>) -> vec3<f32> {
    /*
    if (clip_space.x < 0.0f) {
        return vec3<f32>(uniforms_float.ambient);
    }
    */

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

/*
fn write_no_hit(screen_pos: vec2<u32>) {
    // If there is no triangle render ambient color 
    textureStore(compute_out, screen_pos, 0, vec4<f32>(uniforms_float.ambient, 1.0f));
    // And overwrite position with 0 0 0 0
    if (uniforms_uint.is_temporal == 1u) {
        // Store position in target
        textureStore(compute_out, screen_pos, 1, vec4<f32>(0.0f));
    }
}

var<workgroup> workgroup_any_hit: bool;
*/

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

    /*
    let no_hit: bool = instance_index == UINT_MAX && triangle_index == UINT_MAX;
    if (!no_hit) {
        workgroup_any_hit = true;
    }
    // Terminate if entire workgroup desn't contain any hit.
    if (!workgroupUniformLoad(&workgroup_any_hit)) {
        write_no_hit(screen_pos);
        return;
    }
    */

    // let view_inv_matrix: mat3x3<f32> = (uniforms_float.view_matrix);

    let screen_space: vec2<f32> = vec2<f32>(f32(global_invocation_id.x) / f32(uniforms_uint.render_size.x), - f32(global_invocation_id.y) / f32(uniforms_uint.render_size.y)) * 2.0f + vec2<f32>(-1.0f, 1.0f);
    // let clip_space: vec3<f32> = vec3<f32>(screen_space.x, - screen_space.y, 1.0f);
    let view_direction: vec3<f32> = normalize(uniforms_float.inv_view_matrix * vec3<f32>(screen_space, 1.0f) * vec3<f32>(1.0f, 1.0f, -1.0f));
    
    if (instance_index == UINT_MAX && triangle_index == UINT_MAX) {

        var env_color: vec3<f32> = vec3<f32>(0.0f);
        if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {
            
            // let env_color: vec3<f32> = textureSample(shift_out_float, environment_map_sampler, vec2(0.0f,0.0f)).xyz;
            env_color = env_map_sample(view_direction, screen_space);
            // env_color = pow(env_color * 1.5f, vec3<f32>(2.0f));
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
    // let camera_ray: Ray = Ray(absolute_position, - normalize(uniforms_float.camera_position - absolute_position));

    // Determine if additional samples are needed
    var sampleFactor: u32 = 1u;
    
    
    if (uniforms_uint.is_temporal == 1u) {
        // Get count of shifted texture

        let shift_out_float_0: vec4<f32> = textureLoad(shift_out_float, screen_pos, 0, 0);
        let shift_out_float_1: vec4<f32> = textureLoad(shift_out_float, screen_pos, 1, 0);

        let shift_out_uint_0: vec4<u32> = textureLoad(shift_out_uint, screen_pos, 0, 0);
        let shift_out_uint_2: vec4<u32> = textureLoad(shift_out_uint, screen_pos, 2, 0);
        // Extract 3d position value
        let fine_color_acc: vec4<f32> = vec4<f32>(unpack2x16float(shift_out_uint_0.x), unpack2x16float(shift_out_uint_0.y));
        // let coarse_color_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 1, 0);
        let fine_color_low_acc: vec4<f32> = vec4<f32>(unpack2x16float(shift_out_uint_0.z), unpack2x16float(shift_out_uint_0.w));
        // let coarse_color_low_variance_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 3, 0);
        let abs_position_old: vec4<f32> = shift_out_float_1;
        // If absolute position is all zeros then there is nothing to do
        let dist: f32 = distance(absolute_position, abs_position_old.xyz);
        let cur_depth: f32 = distance(absolute_position, uniforms_float.camera_position.xyz);
        // let norm_color_diff = dot(normalize(current_color.xyz), normalize(accumulated_color.xyz));
        let old_temporal_target: u32 = shift_out_uint_2.x;
        let fine_count: u32 = shift_out_uint_2.z;

        let last_frame = old_temporal_target == uniforms_uint.temporal_target;

        if (fine_count == 0u || !last_frame) {
            sampleFactor = 1u;
        }

        /*
        let temporal_target_mod: u32 = (uniforms_uint.temporal_target + (workgroup_id.x * 8u) / (uniforms_uint.render_size.x / 2u)) % 3u;
        if (
            dist <= cur_depth * 8.0f / f32(uniforms_uint.render_size.x)
            && last_frame
            // Only keep old pixel if accumulation is saturated
            && fine_count >= 8u
            // Recalculate every third frame anyways to detect change in reflection
            && temporal_target_mod != 0u
        ){
            textureStore(compute_out, screen_pos, 0, fine_color_acc);
            // Store position in target
            textureStore(compute_out, screen_pos, 1, vec4<f32>(absolute_position, f32(instance_index)));
            return;
        }
        */
        
    }
    

    // Load bounding vertices
    /*

    let is_leader: bool = local_invocation_id.x == 0u && local_invocation_id.y == 0u;

    if (is_leader) {
        for (var i: u32 = 0u; i < INSTANCE_BVH_CACHE_SIZE; i++) {
            instance_bvh_cache[i] = instance_bvh[i];
        }

        for (var i: u32 = 0u; i < INSTANCE_BOUNDING_VERTICES_CACHE_SIZE; i++) {
            instance_bounding_vertices_cache[i] = instance_bounding_vertices[i];
        }
    }

    workgroupBarrier();

    // BREAK UNIFORM CONTROL FLOW
    if (no_hit) {
        write_no_hit(screen_pos);
        return;
    }
    
    */

    var final_color = vec3<f32>(0.0f);


    var random_state: u32 = (uniforms_uint.temporal_target + 1u) * (global_invocation_id.y * uniforms_uint.render_size.x + global_invocation_id.x);
    // Generate multiple samples
    for(var i: u32 = 0u; i < uniforms_uint.samples * sampleFactor; i++) {
        // Use cosine as noise in random coordinate picker
        // let cos_sample_n = cos(f32(i));
        let sampled_color: SampledColor = lightTrace(init_hit, absolute_position, uniforms_float.camera_position, screen_space, random_state);
        random_state = sampled_color.random_state;
        final_color += sampled_color.color;
    }

    // Average ray colors over samples.
    let inv_samples: f32 = 1.0f / f32(uniforms_uint.samples * sampleFactor);
    final_color *= inv_samples;

    // Write to additional textures for temporal pass
    if (uniforms_uint.is_temporal == 1u) {
        // Render to compute target
        textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));


        // Get inverse transform
        // let inverse_transform: Transform = instance_transform[instance_index * 2u + 1u];
        // Store position in target
        // textureStore(compute_out, screen_pos, 1, vec4<f32>(inverse_transform.rotation * (absolute_position + inverse_transform.shift), f32(instance_index)));
        textureStore(compute_out, screen_pos, 1, vec4<f32>(absolute_position, f32(instance_index)));
    } else {
        // Render to compute target
        textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));
    }
    
    // textureStore(compute_out, screen_pos, 0, vec4<f32>(1.0f, 0.0f, 0.0f, 1.0f));
}