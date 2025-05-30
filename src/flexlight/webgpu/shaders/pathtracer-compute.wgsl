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
// const BIAS: f32 = 0.0000009536743164;
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
    point_light_count: u32,
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

struct Intersect{
    uv: vec2<f32>,
    distance: f32
};

struct Hit {
    uv: vec2<f32>,
    distance: f32,
    instance_index: u32,
    triangle_index: u32
};


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

    let texel_position: vec2<f32> = uv * vec2<f32>(f32(width), f32(height));
    let texel_position_u32: vec2<u32> = vec2<u32>(u32(texel_position.x), u32(texel_position.y));
    let texel_position_mat: mat4x2<f32> = mat4x2<f32>(texel_position, texel_position, texel_position, texel_position);

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
    let t_texel_pos_u32_x: vec4<u32> = vec4<u32>(texel_position_u32.x, texel_position_u32.x + 1u, texel_position_u32.x, texel_position_u32.x + 1u);
    let t_texel_pos_u32_y: vec4<u32> = vec4<u32>(texel_position_u32.y, texel_position_u32.y, texel_position_u32.y + 1u, texel_position_u32.y + 1u);
    let texel_index: vec4<u32> = texture_data_offset + t_texel_pos_u32_x + t_texel_pos_u32_y * width;
    // Fetch texel and return result
    let uint_data_00: vec4<u32> = access_texture_data(texel_index.x);
    let uint_data_10: vec4<u32> = access_texture_data(texel_index.y);
    let uint_data_01: vec4<u32> = access_texture_data(texel_index.z);
    let uint_data_11: vec4<u32> = access_texture_data(texel_index.w);

    let float_data: mat4x4<f32> = mat4x4<f32>(
        vec4<f32>(uint_data_00),
        vec4<f32>(uint_data_10),
        vec4<f32>(uint_data_01),
        vec4<f32>(uint_data_11)
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

fn rgb_to_greyscale(rgb: vec3<f32>) -> f32 {
    return dot(rgb, vec3<f32>(0.299, 0.587, 0.114));
}

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

fn moellerTrumbore(a: vec3<f32>, b: vec3<f32>, c: vec3<f32>, ray: Ray, l: f32) -> Intersect {
    let edge1: vec3<f32> = b - a;
    let edge2: vec3<f32> = c - a;
    let pvec: vec3<f32> = cross(ray.unit_direction, edge2);
    let det: f32 = dot(edge1, pvec);
    if(abs(det) < BIAS) {
        return Intersect(vec2<f32>(0.0f, 0.0f), 0.0f);
    }
    let inv_det: f32 = 1.0f / det;
    let tvec: vec3<f32> = ray.origin - a;
    let u: f32 = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) {
        return Intersect(vec2<f32>(0.0f, 0.0f), 0.0f);
    }
    let qvec: vec3<f32> = cross(tvec, edge1);
    let v: f32 = dot(ray.unit_direction, qvec) * inv_det;
    let uv_sum: f32 = u + v;
    if(v < BIAS || uv_sum > 1.0f) {
        return Intersect(vec2<f32>(0.0f, 0.0f), 0.0f);
    }
    let s: f32 = dot(edge2, qvec) * inv_det;
    if(s <= l && s > BIAS) {
        return Intersect(vec2<f32>(u, v), s);
    } else {
        return Intersect(vec2<f32>(0.0f, 0.0f), 0.0f);
    }
}

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
fn moellerTrumboreCull(a: vec3<f32>, b: vec3<f32>, c: vec3<f32>, ray: Ray, l: f32) -> bool {
    let edge1: vec3<f32> = b - a;
    let edge2: vec3<f32> = c - a;
    let pvec: vec3<f32> = cross(ray.unit_direction, edge2);
    let det: f32 = dot(edge1, pvec);
    let inv_det: f32 = 1.0f / det;
    if(det < BIAS) {
        return false;
    }
    let tvec: vec3<f32> = ray.origin - a;
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

    if (tmax >= max(tmin, BIAS) && tmin < max_len) {
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
    let len_factor: f32 = length(inverse_dir);
    let len_factor_inv: f32 = 1.0f / len_factor;

    let t_ray = Ray(
        inverse_transform.rotation * (ray.origin + inverse_transform.shift),
        inverse_dir * len_factor_inv
    );

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
            let intersect0: Intersect = moellerTrumbore(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), vec3<f32>(bv1.zw, bv2.x), t_ray, hit.distance * len_factor);
            if (intersect0.distance != 0.0) {
                // Calculate intersection point
                hit.distance = intersect0.distance * len_factor_inv;
                hit.uv = intersect0.uv;
                hit.instance_index = instance_index;
                hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.y;
            }

            if (indicator_and_children.z != UINT_MAX) {
                // Test if ray even intersects
                let intersect1: Intersect = moellerTrumbore(bv2.yzw, bv3.xyz, vec3<f32>(bv3.w, bv4.xy), t_ray, hit.distance * len_factor);
                if (intersect1.distance != 0.0) {
                    // Calculate intersection point
                    hit.distance = intersect1.distance * len_factor_inv;
                    hit.uv = intersect1.uv;
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

fn trowbridgeReitz(alpha: f32, n_dot_h: vec2<f32>) -> vec2<f32> {
    let numerator: f32 = alpha * alpha;
    let denom: vec2<f32> = n_dot_h * n_dot_h * (numerator - 1.0f) + 1.0f;
    return numerator / max(PI * denom * denom, vec2<f32>(BIAS));
}

fn oneOverSchlickBeckmann(alpha: f32, n_dot_x: f32) -> f32 {
    let k: f32 = alpha * 0.5f;
    return max(n_dot_x * (1.0f - k) + k, BIAS);
}

fn fresnel(f0: vec3<f32>, cos_theta: f32) -> vec3<f32> {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - cos_theta, 5.0f);
}

// Helper function for GGX importance sampling
fn sampleGGX(alpha: f32, random1: f32, random2: f32) -> vec3<f32> {
    let theta: f32 = atan(alpha * sqrt(random1) / sqrt(1.0f - random1));
    let phi: f32 = 2.0f * PI * random2;
    let sin_theta: f32 = sin(theta);
    return vec3<f32>(
        sin_theta * cos(phi),
        sin_theta * sin(phi),
        cos(theta)
    );
}

// Transform vector from tangent space to world space
fn tangentToWorld(v: vec3<f32>, n: vec3<f32>) -> vec3<f32> {
    // Rotationally-invariant tangent frame construction (Frisvad method)
    // Only depends on the normal, not absolute world orientation
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;
    
    if (n.z < -1.0f + BIAS) {
        // Handle singularity when normal points down
        tangent = vec3<f32>(0.0f, -1.0f, 0.0f);
        bitangent = vec3<f32>(-1.0f, 0.0f, 0.0f);
    } else {
        let a: f32 = 1.0f / (1.0f + n.z);
        let b: f32 = -n.x * n.y * a;
        tangent = vec3<f32>(1.0f - n.x * n.x * a, b, -n.x);
        bitangent = vec3<f32>(b, 1.0f - n.y * n.y * a, -n.y);
    }
    
    return v.x * tangent + v.y * bitangent + v.z * n;
}

struct ForwardPreCalc {
    reflected_view: vec3<f32>,
    one_over_4_schlick_beckmann_n_dot_v: f32,
    f0: vec3<f32>,
    alpha: f32,
    diffuse_component: vec3<f32>
}


// BSDF takes in incoming and outgoing directions and surface properties returning throughput for direct lighting
fn BSDF(in_dir: vec3<f32>, out_dir: vec3<f32>, n: vec3<f32>, material: Material) -> vec3<f32> {
    // Minimum alpha for better looking smooth metals and caustics
    let alpha: f32 = max(material.roughness * material.roughness, 0.05f);
    let n_dot_v: f32 = abs(dot(n, - in_dir));
    let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
    let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);
    // Precaluclate reflected vector
    let rv: vec3<f32> = reflect(- in_dir, n);
    // let one_over_4_schlick_beckmann_n_dot_v: f32 = oneOverSchlickBeckmann(alpha, n_dot_v) * 4.0f;
    // Precaluclate diffuse component
    let lambert: vec3<f32> = material.albedo * INV_PI;
    let diffuse: f32 = (1.0f - material.metallic) * (1.0f - material.transmission);

    let n_dot_l: f32 = abs(dot(n, out_dir));
    let h: vec3<f32> = normalize(out_dir - in_dir);
    let v_dot_h: f32 = abs(dot(in_dir, h));
    let n_dot_h: f32 = abs(dot(n, h));

    let rh: vec3<f32> = normalize(out_dir + rv);
    let n_dot_rh: f32 = max(dot(n, rh), 0.0f);

    let reflect_component: vec3<f32> = fresnel(f0, v_dot_h);
    let diffuse_component: vec3<f32> = diffuse * lambert;

    let cook_torrance_numerator: vec2<f32> = trowbridgeReitz(alpha, vec2<f32>(n_dot_h, n_dot_rh));
    let cook_torrance_denominator: f32 = max(4.0f * oneOverSchlickBeckmann(alpha, n_dot_v) * oneOverSchlickBeckmann(alpha, n_dot_l), BIAS);
    let cook_torrance: vec2<f32> = cook_torrance_numerator / cook_torrance_denominator;

    // Check for total internal reflection
    let sign_dir: f32 = sign(dot(- in_dir, n));
    let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
    let cos_theta_i: f32 = abs(dot(- in_dir, n));
    let sin_theta_i_sq: f32 = 1.0f - cos_theta_i * cos_theta_i;
    let sin_theta_t_sq: f32 = (eta * eta) * sin_theta_i_sq;
    
    // Total internal reflection occurs when sin²θt > 1
    let is_total_internal_reflection: bool = sin_theta_t_sq > 1.0f;
    let transmission_factor: f32 = select(material.transmission, 0.0f, is_total_internal_reflection);

    let radiance: vec3<f32> = diffuse_component + reflect_component * cook_torrance.x + transmission_factor * cook_torrance.y;
    // Outgoing light to camera
    return radiance * n_dot_l;
}

struct SampleBSDF {
    unit_direction: vec3<f32>,
    throughput: vec3<f32>,
    random_state: u32,
    normal: vec3<f32>
}
// SampleBSDF takes in incoming direction, surface normal, material and random state and returns an outgoing direction with throughput according to the BSDF for global illumination
fn sampleBSDF(in_dir: vec3<f32>, n: vec3<f32>, material: Material, random_init: u32, sign_dir: f32) -> SampleBSDF {
    var sample: SampleBSDF = SampleBSDF(vec3<f32>(1.0f), vec3<f32>(1.0f), random_init, n);

    let alpha: f32 = material.roughness * material.roughness; // Don't match BSDF alpha clamping
    let n_dot_v: f32 = abs(dot(n, - in_dir));
    let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
    let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);

    // Generate random values for sampling
    let random1: Random = pcg(sample.random_state);
    sample.random_state = random1.state;
    let random2: Random = pcg(sample.random_state);
    sample.random_state = random2.state;
    let random3: Random = pcg(sample.random_state);
    sample.random_state = random3.state;

    // Calculate component weights for importance sampling
    let reflect_component: f32 = rgb_to_greyscale(fresnel(f0, n_dot_v));
    let diffuse_component: f32 = (1.0f - material.metallic) * (1.0f - material.transmission);
    let refract_component: f32 = material.transmission;

    // Calculate sampling probabilities
    let total_component: f32 = reflect_component + diffuse_component + refract_component;
    let total_component_inv: f32 = 1.0f / max(total_component, BIAS);
    let reflect_ratio: f32 = reflect_component * total_component_inv;
    let refract_ratio: f32 = refract_component * total_component_inv;

    // Generate diffuse direction for mixing
    let random_sphere: RandomSphere = random_sphere(sample.random_state);
    sample.random_state = random_sphere.state;
    let diffuse_random_dir: vec3<f32> = normalize(n + random_sphere.value);

    if (random1.value < reflect_ratio) {
        // Sample specular reflection using GGX importance sampling
        let half_vector_local: vec3<f32> = sampleGGX(alpha, random2.value, random3.value);
        let half_vector: vec3<f32> = tangentToWorld(half_vector_local, n);
        sample.unit_direction = normalize(reflect(in_dir, half_vector));
        
        // Throughput accounts for what's not captured by sampling
        sample.throughput = mix(vec3<f32>(1.0f), material.albedo, material.metallic);
        
    } else if (random1.value < reflect_ratio + refract_ratio) {
        // Sample transmission using GGX importance sampling
        let half_vector_local: vec3<f32> = sampleGGX(alpha, random2.value, random3.value);
        var half_vector: vec3<f32> = tangentToWorld(half_vector_local, n);
        
        let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
        
        // Ensure half vector is oriented correctly for refraction
        // For refraction to work, we want dot(-in_dir, half_vector) > 0
        
        // Try refraction through the properly oriented half vector
        let refracted: vec3<f32> = refract(in_dir, half_vector, eta);
        
        // Check if total internal reflection occurred
        if (length(refracted) < BIAS) {
            // Total internal reflection - use half vector for reflection
            sample.unit_direction = normalize(reflect(in_dir, half_vector));
            // Throughput accounts for what's not captured by sampling
            sample.throughput = mix(vec3<f32>(1.0f), material.albedo, material.metallic);
        } else {
            // Normal refraction through microfacet
            sample.unit_direction = normalize(refracted);
            // Flip normal for transmission (ray exits on opposite side)
            sample.normal = - sample.normal;
        }
        sample.throughput = material.albedo;
        
    } else {
        // Sample diffuse using cosine-weighted hemisphere sampling
        sample.unit_direction = diffuse_random_dir;
        sample.throughput = material.albedo;
    }
    
    return sample;
}

struct SamplePreCalc {
    f0: vec3<f32>,
    alpha: f32,
    random_sphere: vec3<f32>,
    n_dot_v: f32,
}

struct SampledColor {
    color: vec3<f32>,
    random_state: u32
}

fn reservoirSample(material: Material, camera_ray: Ray, init_random_state: u32, smooth_n: vec3<f32>, geometry_offset: f32, random_sphere: vec3<f32>) -> SampledColor {
    let m: u32 = uniforms_uint.point_light_count + 1u;
    // If no lights, return emissive color
    if (m <= 1u) {
        return SampledColor(vec3<f32>(0.0f), init_random_state);
    }

    var w_sum: f32 = 0.0f;
    var reservoir_color: vec3<f32> = vec3<f32>(0.0f);
    var reservoir_dir: vec3<f32>;
    var random_state: u32 = init_random_state;
    // Minimum alpha for better looking smooth metals and caustics
    // let alpha: f32 = max(pre.alpha, 0.05f);
    // Precaluclate reflected vector
    // let rv: vec3<f32> = reflect(- camera_ray.unit_direction, smooth_n);
    // let one_over_4_schlick_beckmann_n_dot_v: f32 = oneOverSchlickBeckmann(alpha, pre.n_dot_v) * 4.0f;
    // Precaluclate diffuse component
    // let lambert: vec3<f32> = material.albedo * INV_PI;
    // let diffuse: f32 = (1.0f - material.metallic) * (1.0f - material.transmission);
    // let diffuse_component: vec3<f32> = diffuse * lambert;
    // Precalculated values for sampleBRDF
    // let pre_calc: ForwardPreCalc = ForwardPreCalc(rv, one_over_4_schlick_beckmann_n_dot_v, pre.f0, alpha, diffuse_component);
    // Iterate over point lights
    for (var i: u32 = 0u; i < uniforms_uint.point_light_count; i++) {
        // Read light from storage buffer
        let light: Light = lights[i + 1u];
        // Yeild random sphere and update state
        let light_position = light.position + random_sphere * light.variance;
        // Alter light source position according to variation.
        let dir: vec3<f32> = light_position - camera_ray.origin;
        let len: f32 = length(dir);
        let len_p1: f32 = 1.0f + len;
        // Apply inverse square law
        let brightness: vec3<f32> = light.color * light.intensity / (len_p1 * len_p1);
        let l: vec3<f32> = dir / len;
        let color_for_light: vec3<f32> = BSDF(camera_ray.unit_direction, l, smooth_n, material) * brightness;
        let w_i: f32 = rgb_to_greyscale(color_for_light);
        w_sum += w_i;
        // Yeild random value between 0 and 1 and update state
        let random_value: Random = pcg(random_state);
        random_state = random_value.state;
        if (random_value.value * w_sum <= w_i) {
            reservoir_color = color_for_light / w_i;
            reservoir_dir = dir;
        }
    }

    let unit_light_dir: vec3<f32> = normalize(reservoir_dir);
    // Compute quick exit criterion to potentially skip expensive shadow test
    let show_shadow: bool = w_sum == 0.0f || dot(smooth_n, unit_light_dir) < 0.0f;
    // Test if in shadow
    if (show_shadow) {
        return SampledColor(vec3<f32>(0.0f), random_state);
    }
    // Apply geometry offset
    let offset_target: vec3<f32> = camera_ray.origin + geometry_offset * smooth_n;
    let light_ray: Ray = Ray(offset_target, unit_light_dir);
    
    if (shadowTraverseInstanceBVH(light_ray, length(reservoir_dir))) {
        return SampledColor(vec3<f32>(0.0f), random_state);
    } else {
        return SampledColor(reservoir_color * w_sum, random_state);
    }
}



fn lightTrace(init_hit: Hit, origin: vec3<f32>, camera: vec3<f32>, init_random_state: u32, screen_space: vec2<f32>) -> SampledColor {
    // Use additive color mixing technique, so start with black
    var final_color: vec3<f32> = vec3<f32>(0.0f);
    var importancy_factor: vec3<f32> = vec3<f32>(1.0f);
    var hit: Hit = init_hit;
    var ray: Ray = Ray(origin, normalize(origin - camera));
    var random_state: u32 = init_random_state;
    var add_ambient: bool = false;
    var i: u32 = 0u;
    // Precalculate random sphere
    let light_offset_sphere: RandomSphere = random_sphere(random_state);
    let light_offset_dir: vec3<f32> = light_offset_sphere.value;
    random_state = light_offset_sphere.state;
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
        let edge3: vec3<f32> = t[2] - t[1];

        let min_edge_length: f32 = min(length(edge1), min(length(edge2), length(edge3)));

        let geometry_n: vec3<f32> = normalize(cross(edge2, edge1));
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
        // Limit angles to 45 degrees
        let angle_tan: vec3<f32> = clamp(tan(angles), vec3<f32>(0.0f), vec3<f32>(PI * 0.25f));
        // Keep geometry offset within reasonable range
        let geometry_offset: f32 = clamp(dot(diffs * angle_tan, geometry_uvw), 0.0f, min_edge_length * 0.5f);
        // Interpolate final barycentric texture coordinates between UV's of the respective vertices
        let barycentric: vec2<f32> = fract(mat3x2<f32>(t4.zw, t5.xy, t5.zw) * geometry_uvw);
        // Sample material
        var material: Material = instance_material[hit.instance_index];

        let hit_instance_location: u32 = hit.instance_index * INSTANCE_UINT_SIZE;
        // Read material textures
        let albedo_texture_id: u32 = instance_uint[hit_instance_location + 3u];
        if (albedo_texture_id != UINT_MAX) {
            let albedo_data: vec4<f32> = textureSample(albedo_texture_id, barycentric) * INV_255;
            material.albedo = albedo_data.xyz;
            /*
            // Enable transparent textures
            // Yeild random value between 0 and 1 and update state
            let transparancy_random_value: Random = pcg(random_state);
            random_state = transparancy_random_value.state;
            if (1.0f - albedo_data.w > transparancy_random_value.value) {
                // Redirect ray to next triangle as this one is transparent
                hit = traverseInstanceBVH(ray);
                // Stop loop if there is no intersection and ray goes in the void
                if (hit.instance_index == UINT_MAX) {
                    add_ambient = true;
                    break;
                }
                // Project ray origin to hit point
                ray.origin += hit.distance * ray.unit_direction;
                continue;
            }
            */
        }

        let normal_texture_id: u32 = instance_uint[hit_instance_location + 4u];
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
        
        let emissive_texture_id: u32 = instance_uint[hit_instance_location + 5u];
        if (emissive_texture_id != UINT_MAX) {
            material.emissive = textureSample(emissive_texture_id, barycentric).xyz * INV_255;
        }

        let roughness_texture_id: u32 = instance_uint[hit_instance_location + 6u];
        if (roughness_texture_id != UINT_MAX) {
            material.roughness = textureSample(roughness_texture_id, barycentric).x * INV_255;
        }

        let metallic_texture_id: u32 = instance_uint[hit_instance_location + 7u];
        if (metallic_texture_id != UINT_MAX) {
            material.metallic = textureSample(metallic_texture_id, barycentric).x * INV_255;
        }

        /*
        let alpha: f32 = material.roughness * material.roughness;
        let n_dot_v: f32 = abs(dot(smooth_n, - ray.unit_direction));

        let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
        let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);
        */
        // Determine local color considering PBR attributes and lighting
        let local_sampled: SampledColor = reservoirSample(material, ray, random_state, smooth_n, geometry_offset, light_offset_dir);
        random_state = local_sampled.random_state;
        // Calculate primary light sources for this pass if ray hits non translucent object
        final_color += local_sampled.color * importancy_factor;
        // Add emissive color to final color
        final_color += material.emissive * importancy_factor;

        // If ray reflects from inside or onto an transparent object,
        // the surface faces in the opposite direction as usual
        let sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));
        smooth_n *= - sign_dir;

        let bsdf_sampled: SampleBSDF = sampleBSDF(ray.unit_direction, smooth_n, material, random_state, sign_dir);
        random_state = bsdf_sampled.random_state;
        ray.unit_direction = bsdf_sampled.unit_direction;
        importancy_factor *= bsdf_sampled.throughput;
        smooth_n = bsdf_sampled.normal;

        /*
        // If ray reflects from inside or onto an transparent object,
        // the surface faces in the opposite direction as usual
        let sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));
        smooth_n *= - sign_dir;

        // let v_dot_n = max(dot(smooth_n, - ray.unit_direction), 0.0f);
        // Bias ray direction on material properties
        // Generate pseudo random vector for diffuse reflection
        let random_sphere: RandomSphere = random_sphere(random_state);
        random_state = random_sphere.state;
        let diffuse_random_dir: vec3<f32> = normalize(smooth_n + random_sphere.value);
        // Yeild random value between 0 and 1 and update state
        let random_value_reflect: Random = pcg(random_state);
        random_state = random_value_reflect.state;


        let reflect_component: f32 = rgb_to_greyscale(fresnel(f0, n_dot_v));
        let diffuse_component: f32 = (1.0f - material.metallic) * (1.0f - material.transmission);
        let refract_component: f32 = material.transmission;

        // Calculate ratio of reflection and transmission
        let total_component: f32 = reflect_component + diffuse_component + refract_component;
        let total_component_inv: f32 = 1.0f / total_component;
        let reflect_ratio: f32 = reflect_component * total_component_inv;
        let refract_ratio: f32 = refract_component * total_component_inv;
        // Does ray reflect or refract or diffuse?
        if (reflect_ratio > abs(random_value_reflect.value)) {
            ray.unit_direction = normalize(mix(reflect(ray.unit_direction, smooth_n), diffuse_random_dir, alpha));
            importancy_factor *= mix(vec3<f32>(1.0f), material.albedo, material.metallic);
        } else {
            if (reflect_ratio + refract_ratio > abs(random_value_reflect.value)) {
                let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
                // Refract ray depending on IOR of material
                ray.unit_direction = normalize(mix(refract(ray.unit_direction, smooth_n, eta), - diffuse_random_dir, alpha));
                smooth_n = - smooth_n;
            } else {
                ray.unit_direction = diffuse_random_dir;
            }
            importancy_factor *= material.albedo;
        }
        */
        // Test for early termination, avoiding last bounce
        i = i + 1u;
        let survival_probability: f32 = rgb_to_greyscale(importancy_factor);
        let random_value: Random = pcg(random_state);
        random_state = random_value.state;


        if (i >= uniforms_uint.max_reflections || survival_probability < random_value.value) {
            add_ambient = false;
            break;
        }

        importancy_factor /= survival_probability;

        // let new_sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));
        // Calculate next intersection
        ray.origin = geometry_offset * smooth_n + ray.origin;
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
            let dir: vec3<f32> = ray.unit_direction;
            let env_color: vec3<f32> = env_map_sample(dir);
            final_color += importancy_factor * env_color;
        } else {
            // If no environment map is present, use ambient color
            final_color += importancy_factor * uniforms_float.ambient;
        }
    }
    // Return final pixel color
    return SampledColor(final_color, random_state);
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
/*
// Helper function to calculate GGX PDF for half vector sampling
fn ggxPDF(alpha: f32, n_dot_h: f32) -> f32 {
    let alpha_sq: f32 = alpha * alpha;
    let denom: f32 = n_dot_h * n_dot_h * (alpha_sq - 1.0f) + 1.0f;
    return alpha_sq / (PI * denom * denom) * n_dot_h;
}

// PBSDF calculates the probability density function of sampleBSDF for a given output direction
fn PBSDF(in_dir: vec3<f32>, out_dir: vec3<f32>, n: vec3<f32>, material: Material, sign_dir: f32) -> f32 {
    let alpha: f32 = material.roughness * material.roughness;
    let n_dot_v: f32 = abs(dot(n, - in_dir));
    let n_dot_l: f32 = abs(dot(n, out_dir));
    let f0_sqrt: f32 = (1.0f - material.ior) / (1.0f + material.ior);
    let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);
    
    // Check for total internal reflection to match sampleBSDF behavior
    let eta: f32 = mix(1.0f / material.ior, material.ior, max(sign_dir, 0.0f));
    let cos_theta_i: f32 = abs(dot(- in_dir, n));
    let sin_theta_i_sq: f32 = 1.0f - cos_theta_i * cos_theta_i;
    let sin_theta_t_sq: f32 = (eta * eta) * sin_theta_i_sq;
    let is_total_internal_reflection: bool = sin_theta_t_sq > 1.0f;
    let transmission_component: f32 = select(material.transmission, 0.0f, is_total_internal_reflection);

    // Calculate component weights (same as sampleBSDF)
    let reflect_component: f32 = rgb_to_greyscale(fresnel(f0, n_dot_v));
    let diffuse_component: f32 = (1.0f - material.metallic) * (1.0f - transmission_component);

    // Calculate sampling probabilities
    let total_component: f32 = reflect_component + diffuse_component + transmission_component;
    let total_component_inv: f32 = 1.0f / max(total_component, BIAS);
    let reflect_ratio: f32 = reflect_component * total_component_inv;
    let refract_ratio: f32 = transmission_component * total_component_inv;
    let diffuse_ratio: f32 = diffuse_component * total_component_inv;

    var total_pdf: f32 = 0.0f;

    // Check if output direction is on same side as input (reflection/diffuse) or opposite side (transmission)
    let same_side: bool = dot(out_dir, n) * dot(in_dir, n) > 0.0f;

    if (same_side) {
        // Reflection or diffuse case
        
        // Calculate reflection PDF using GGX half-vector sampling
        let h_reflect: vec3<f32> = normalize(out_dir - in_dir);
        let n_dot_h_reflect: f32 = abs(dot(n, h_reflect));
        let v_dot_h_reflect: f32 = abs(dot(in_dir, h_reflect));
        
        if (n_dot_h_reflect > BIAS && v_dot_h_reflect > BIAS) {
            // GGX PDF for half vector * Jacobian for reflection (1 / 4(v·h))
            let ggx_half_pdf: f32 = ggxPDF(alpha, n_dot_h_reflect);
            let reflection_pdf: f32 = ggx_half_pdf / (4.0f * v_dot_h_reflect);
            total_pdf += reflect_ratio * reflection_pdf;
        }

        // Add diffuse PDF (cosine-weighted hemisphere sampling)
        if (n_dot_l > BIAS) {
            let diffuse_pdf: f32 = n_dot_l * INV_PI; // cos(theta) / pi
            total_pdf += diffuse_ratio * diffuse_pdf;
        }

    } else {
        // Transmission case (opposite side)
        if (!is_total_internal_reflection && transmission_component > BIAS) {
            // Calculate transmission PDF using GGX half-vector sampling
            // For transmission, half vector is on the "average" side between incident and transmitted
            let eta_inv: f32 = 1.0f / eta;
            let h_transmission: vec3<f32> = normalize(-(in_dir + eta * out_dir));
            
            // Ensure half vector points toward same side as surface normal
            let h_trans: vec3<f32> = select(-h_transmission, h_transmission, dot(h_transmission, n) > 0.0f);
            
            let n_dot_h_trans: f32 = abs(dot(n, h_trans));
            let v_dot_h_trans: f32 = abs(dot(in_dir, h_trans));
            let l_dot_h_trans: f32 = abs(dot(out_dir, h_trans));
            
            if (n_dot_h_trans > BIAS && v_dot_h_trans > BIAS && l_dot_h_trans > BIAS) {
                // GGX PDF for half vector * Jacobian for transmission
                let ggx_half_pdf: f32 = ggxPDF(alpha, n_dot_h_trans);
                
                // Jacobian for transmission: |l·h| / |((v·h) + eta*(l·h))|^2
                let denom: f32 = v_dot_h_trans + eta * l_dot_h_trans;
                let transmission_jacobian: f32 = l_dot_h_trans / max(denom * denom, BIAS);
                let transmission_pdf: f32 = ggx_half_pdf * transmission_jacobian;
                
                total_pdf += refract_ratio * transmission_pdf;
            }
        }
    }

    return total_pdf;
}
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

    let screen_space: vec2<f32> = vec2<f32>(global_invocation_id.xy) / vec2<f32>(uniforms_uint.render_size.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
    let view_direction: vec3<f32> = normalize(uniforms_float.inv_view_matrix * vec3<f32>(screen_space, 1.0f));
    
    if (instance_index == UINT_MAX && triangle_index == UINT_MAX) {
        var env_color: vec3<f32> = vec3<f32>(0.0f);
        if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {
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
    let uvw: vec3<f32> = vec3<f32>(uv, 1.0f - uv.x - uv.y);
    // Generate hit struct for pathtracer
    let init_hit: Hit = Hit(uvw.yz, distance(absolute_position, uniforms_float.camera_position.xyz), instance_index, triangle_index);
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
        let fine_color_low_acc: vec4<f32> = vec4<f32>(unpack2x16float(shift_out_uint_0.z), unpack2x16float(shift_out_uint_0.w));
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
    }
    // Init color accumulator and random state
    var final_color = vec3<f32>(0.0f);
    var random_state: u32 = (uniforms_uint.temporal_target + 1u) * (global_invocation_id.y * uniforms_uint.render_size.x + global_invocation_id.x);
    // Generate multiple samples
    for(var i: u32 = 0u; i < uniforms_uint.samples * sampleFactor; i++) {
        // Use cosine as noise in random coordinate picker
        let sampled_color: SampledColor = lightTrace(init_hit, absolute_position, uniforms_float.camera_position, random_state, screen_space);
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
        textureStore(compute_out, screen_pos, 1, vec4<f32>(absolute_position, f32(instance_index)));
    } else {
        // Render to compute target
        textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));
    }
}