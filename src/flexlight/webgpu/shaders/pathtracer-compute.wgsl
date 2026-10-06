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

const LIGHT_SIZE: u32 = 3u;

const PI: f32 = 3.141592653589793;
const PHI: f32 = 1.61803398874989484820459;
const SQRT3: f32 = 1.7320508075688772;
const POW32: f32 = 4294967296.0;
const MAX_SAFE_INTEGER_FOR_F32: f32 = 8388607.0;
const MAX_SAFE_INTEGER_FOR_F32_U: u32 = 8388607u;
const UINT_MAX: u32 = 4294967295u;
const UINT_MAX_M1: u32 = 4294967294u;
const BIAS: f32 = 0.0000152587890625;
// const BIAS: f32 = 0.0000009536743164;
const INV_PI: f32 = 0.3183098861837907;
const INV_255: f32 = 0.00392156862745098;
const INV_SQRT3: f32 = 0.5773502691896258;

struct Transform {
    rotation: mat3x3<f32>,
    shift: vec3<f32>,
};

struct UniformFloat {
    view_matrix: mat3x3<f32>,
    inv_view_matrix: mat3x3<f32>,

    camera_position: vec3<f32>,
    ambient: vec3<f32>,

    max_reprojection: f32,

    prev_view_matrix: mat3x3<f32>,
    prev_camera_position: vec3<f32>,
};

struct UniformUint {
    render_size: vec2<u32>,
    temporal_target: u32,
    temporal_max: u32,

    is_temporal: u32,
    samples: u32,
    max_bounces: u32,
    tonemapping_operator: u32,

    environment_map_size: vec2<u32>,
    light_count: u32,
    frame: u32,
    restir_decorrelation: u32,
    restir_neighbours: u32,
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
// Luminance CDF of the environment map, rows with the marginal CDF in the last column, probabilities in the second channel
@group(1) @binding(4) var environment_cdf: texture_2d<f32>;
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
    is_area_light: f32,
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
    instance_index: u32,
    triangle_index: u32,
    is_point_light: u32,
    distance: f32,
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

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles, or both sides if two_sided
fn moellerTrumboreCull(a: vec3<f32>, b: vec3<f32>, c: vec3<f32>, ray: Ray, l: f32, two_sided: bool) -> bool {
    let edge1: vec3<f32> = b - a;
    let edge2: vec3<f32> = c - a;
    let pvec: vec3<f32> = cross(ray.unit_direction, edge2);
    let det: f32 = dot(edge1, pvec);
    let inv_det: f32 = 1.0f / det;
    if(select(det, abs(det), two_sided) < BIAS) {
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

// Ray sphere intersection test.
fn raySphere(center: vec3<f32>, radius: f32, ray: Ray, max_len: f32) -> f32 {
    let L: vec3<f32> = center - ray.origin;
    let tca: f32 = dot(L, ray.unit_direction);

    let d2: f32 = dot(L, L) - tca * tca;
    if (d2 > radius * radius) {
        return POW32;
    }

    let thc: f32 = sqrt(radius * radius - d2);
    let t0: f32 = tca - thc;
    let t1: f32 = tca + thc;

    if (t0 > BIAS && t0 < max_len) {
        return t0;
    }

    if (t1 > BIAS && t1 < max_len) {
        return t1;
    }

    return POW32;
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
    var hit: Hit = Hit(vec2<f32>(0.0f, 0.0f), UINT_MAX, UINT_MAX, 0u, max_len);
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
fn traverseInstanceBVH(ray: Ray, consider_point_lights: bool, max_len: f32) -> Hit {
    // Hit object
    // Maximal distance a triangle can be away from the ray origin is max_len at initialisation
    var hit: Hit = Hit(vec2<f32>(0.0f, 0.0f), UINT_MAX, UINT_MAX, 0u, max_len);
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

        var dist0: f32 = POW32;
        var dist1: f32 = POW32;
        if (child0 == UINT_MAX_M1 && consider_point_lights) {
            // Child 0 is a point light
            let light_dist: f32 = raySphere(bv0.xyz, bv0.w, ray, hit.distance);
            if (light_dist != POW32) {
                hit.distance = light_dist;
                hit.is_point_light = 1u;
                hit.instance_index = u32(bv1.y);
            }
        } else if (child0 != UINT_MAX_M1) {
            // Child 0 is an instance
            dist0 = rayBoundingVolume(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), ray, hit.distance);
        }

        if (child1 == UINT_MAX_M1 && consider_point_lights) {
            // Child 1 is a point light
            let light_dist: f32 = raySphere(vec3<f32>(bv1.zw, bv2.x), bv2.y, ray, hit.distance);
            if (light_dist != POW32) {
                hit.distance = light_dist;
                hit.is_point_light = 1u;
                hit.instance_index = u32(bv2.w);
            }
        } else if (child0 != UINT_MAX && child1 != UINT_MAX_M1) {
            // Child 1 is an instance
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
fn shadowTraverseTriangleBVH(instance_index: u32, ray: Ray, l: f32, two_sided: bool) -> bool {
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
            if (moellerTrumboreCull(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), vec3<f32>(bv1.zw, bv2.x), t_ray, max_len, two_sided)) {
                return true;
            }

            if (indicator_and_children.z != UINT_MAX) {
                let bv3 = access_triangle_bounding_vertices(vertex_offset + 3u);
                let bv4 = access_triangle_bounding_vertices(vertex_offset + 4u);
                if (moellerTrumboreCull(bv2.yzw, bv3.xyz, vec3<f32>(bv3.w, bv4.xy), t_ray, max_len, two_sided)) {
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
fn shadowTraverseInstanceBVH(ray: Ray, l: f32, two_sided: bool) -> bool {
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

        var dist0: f32 = POW32;
        var dist1: f32 = POW32;
        if (child0 != UINT_MAX_M1) {
            dist0 = rayBoundingVolume(bv0.xyz, vec3<f32>(bv0.w, bv1.xy), ray, l);
        }

        if (child1 != UINT_MAX && child1 != UINT_MAX_M1) {
            dist1 = rayBoundingVolume(vec3<f32>(bv1.zw, bv2.x), bv2.yzw, ray, l);
        }

        let dist_near = min(dist0, dist1);
        let dist_far = max(dist0, dist1);
        let near_child = select(child1, child0, dist0 < dist1);
        let far_child = select(child0, child1, dist0 < dist1);

        if (indicator == 0u) {
            // If node is a triangle, test for intersection, closest first
            if (dist_near != POW32) {
                if (shadowTraverseTriangleBVH(near_child, ray, l, two_sided)) {
                    return true;
                }
            }
            if (dist_far != POW32) {
                if (shadowTraverseTriangleBVH(far_child, ray, l, two_sided)) {
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

fn G1(alpha: f32, n_dot_x: f32) -> f32 {
    let k: f32 = alpha * 0.5f;
    return n_dot_x / max(n_dot_x * (1.0f - k) + k, BIAS);
}
/*
fn delta(v: vec3<f32>, alpha: f32) -> f32 {
    let alpha_sq: f32 = alpha * alpha;
    let nom: f32 = alpha_sq * (v.x + v.y)

    let sqrt_term: f32 = sqrt(alpha * alpha + v.z * v.z);
}
*/

fn schlickBeckmann(k: f32, n_dot_x: f32) -> f32 {
    return n_dot_x / max(n_dot_x * (1.0f - k) + k, BIAS);
}

fn smith(alpha: f32, n_dot_v: f32, n_dot_l: f32) -> f32 {
    let k: f32 = alpha * 0.5f;
    return schlickBeckmann(k, n_dot_v) * schlickBeckmann(k, n_dot_l);
}

/*
fn smithAlt(alpha: f32, n_dot_v: f32, n_dot_l: f32) -> f32 {
    let k: f32 = alpha * 0.5f;
    return 1.0f / max((n_dot_v * (1.0f - k) + k) * (n_dot_l * (1.0f - k) + k), BIAS);
}
*/
/*
fn fresnel_schlick(f0: vec3<f32>, cos_theta: f32) -> vec3<f32> {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - cos_theta, 5.0f);
}
*/

fn fresnel(cos_theta: f32, eta_i: f32, eta_o: f32) -> f32 {
    // Compute sini using Snell's law
    let sin_theta = sqrt(max(0.0f, 1.0f - cos_theta * cos_theta));
    let sin_psi = (eta_i / eta_o) * sin_theta;
    // Total internal reflection
    var kr: f32 = 1.0f;
    if (sin_psi < 1.0f) {
        let cos_psi = sqrt(max(0.0f, 1.0f - sin_psi * sin_psi));
        // cos = abs(cosi);
        let Rs = ((eta_o * cos_theta) - (eta_i * cos_psi)) / ((eta_o * cos_theta) + (eta_i * cos_psi));
        let Rp = ((eta_i * cos_theta) - (eta_o * cos_psi)) / ((eta_i * cos_theta) + (eta_o * cos_psi));
        kr = (Rs * Rs + Rp * Rp) / 2.0f;
    }

    return kr;
}

// Helper function for GGX importance sampling
// Corresponding PDF is: pdf = trowbridgeReitz(alpha, n_dot_h) * n_dot_h
/*
fn sampleTrowbridgeReitz(alpha: f32, random_1: f32, random_2: f32) -> vec3<f32> {
    let theta: f32 = atan(alpha * sqrt(random_1) / sqrt(1.0f - random_1));
    let phi: f32 = 2.0f * PI * random_2;
    let sin_theta: f32 = sin(theta);
    return vec3<f32>(sin_theta * cos(phi), sin_theta * sin(phi), cos(theta));
}
*/

// Sampling of the GGX VNDF
fn sampleGGXVNDF(Ve: vec3<f32>, alpha: f32, U1: f32, U2: f32) -> vec3<f32> {
    // The Ve argument is the view direction in tangent space, where the normal is (0, 0, 1).
    // Section 3.2: transforming the view direction to the hemisphere configuration.
    let Vh: vec3<f32> = normalize(vec3<f32>(alpha * Ve.x, alpha * Ve.y, Ve.z));
    // Section 4.1: orthonormal basis (with special case if cross product is zero).
    let lensq: f32 = Vh.x * Vh.x + Vh.y * Vh.y;
    let T1: vec3<f32> = select(vec3<f32>(1.0, 0.0, 0.0), vec3<f32>(-Vh.y, Vh.x, 0.0) * inverseSqrt(lensq), lensq > 0.0);
    let T2: vec3<f32> = cross(Vh, T1);
    // Section 4.2: parameterization of the projected area.
    let r: f32 = sqrt(U1);
    let phi: f32 = 2.0 * PI * U2;
    let t1: f32 = r * cos(phi);
    var t2: f32 = r * sin(phi);
    let s: f32 = 0.5 * (1.0 + Vh.z);
    t2 = (1.0 - s) * sqrt(max(0.0, 1.0 - t1 * t1)) + s * t2;
    // Section 4.3: reprojection onto hemisphere.
    let Nh: vec3<f32> = t1 * T1 + t2 * T2 + sqrt(max(0.0, 1.0 - t1 * t1 - t2 * t2)) * Vh;
    // Section 3.4: transforming the normal back to the ellipsoid configuration.
    return normalize(vec3<f32>(alpha * Nh.x, alpha * Nh.y, max(0.0, Nh.z)));
}

// Corresponding PDF is: pdf = cos(theta) / PI
fn sampleCosWeightedHemisphere(random_1: f32, random_2: f32) -> vec3<f32> {
    let r = sqrt(random_1);
    let theta: f32 = 2.0f * PI * random_2;
    let x = r * cos(theta);
    let z = r * sin(theta);
    let y = sqrt(max(0.0f, 1.0f - x * x - z * z));
    return vec3<f32>(x, y, z);
}

fn tangentToWorld(v: vec3<f32>, n: vec3<f32>) -> vec3<f32> {
    var a: vec3<f32> = vec3<f32>(0.0, 1.0, 0.0);
    if (abs(dot(n, a)) > 1.0f - BIAS) {
        a = vec3<f32>(1.0, 0.0, 0.0);
    }
    let tangent: vec3<f32> = normalize(cross(n, a));
    let bitangent: vec3<f32> = cross(n, tangent);
    return v.x * tangent + v.y * n + v.z * bitangent;
}

fn worldToTangent(v: vec3<f32>, n: vec3<f32>) -> vec3<f32> {
    var a: vec3<f32> = vec3<f32>(0.0, 1.0, 0.0);
    if (abs(dot(n, a)) > 1.0f - BIAS) {
        a = vec3<f32>(1.0, 0.0, 0.0);
    }
    let tangent: vec3<f32> = normalize(cross(n, a));
    let bitangent: vec3<f32> = cross(n, tangent);
    return vec3<f32>(dot(v, tangent), dot(v, n), dot(v, bitangent));
}

// Build TBN matrix for tangent-space normal mapping. Uses triangle edges and UV deltas to compute
// tangent (U direction) and bitangent (V direction), with handedness fix.
fn normalMapTBN(p0: vec3<f32>, p1: vec3<f32>, p2: vec3<f32>, uv0: vec2<f32>, uv1: vec2<f32>, uv2: vec2<f32>, n: vec3<f32>) -> mat3x3<f32> {
    let e1: vec3<f32> = p1 - p0;
    let e2: vec3<f32> = p2 - p0;
    let duv1: vec2<f32> = uv1 - uv0;
    let duv2: vec2<f32> = uv2 - uv0;
    // Compute inverse determinant for UV to world space transformation.
    let det: f32 = duv1.x * duv2.y - duv1.y * duv2.x;
    let inv_det: f32 = 1.0f / det;
    var t: vec3<f32> = (e1 * duv2.y - e2 * duv1.y) * inv_det;
    let b_geom: vec3<f32> = (e2 * duv1.x - e1 * duv2.x) * inv_det;

    // Gram-Schmidt: make tangent perpendicular to interpolated normal.
    t = normalize(t - n * dot(n, t));
    // Handedness: ensure TBN is right-handed; flip T if geometric b disagrees with cross(n,t).
    if (dot(cross(n, t), b_geom) > 0.0f) {
        t = -t;
    }
    let b: vec3<f32> = cross(n, t);

    return mat3x3<f32>(t, b, n);
}

fn tangentToWorldNormalMap(v: vec3<f32>, tbn: mat3x3<f32>) -> vec3<f32> {
    return tbn * v;
}

// BSDF takes in incoming and outgoing directions and surface properties returning throughput for direct lighting
// Only consider lighting on the surface of the object, not the inside. Assume direct light is always outside the object as shadowing also makes that assumption.
fn BSDF(in_dir: vec3<f32>, out_dir: vec3<f32>, n: vec3<f32>, g_n: vec3<f32>, material: Material, eta_i: f32, eta_o: f32, screen_space: vec2<f32>) -> vec3<f32> {
    let v = - in_dir;
    // Precalculate dot products
    let n_dot_v: f32 = dot(n, v);
    let n_dot_l: f32 = dot(n, out_dir);
    // Calculate material constants needed for BRDF and BTDF
    var alpha: f32 = material.roughness * material.roughness;
    // Precalculate dot products for geometry normal
    let g_n_dot_v: f32 = dot(g_n, v);
    let g_n_dot_l: f32 = dot(g_n, out_dir);
    // Test if v and l are on the same side of the surface
    if (g_n_dot_v * g_n_dot_l > 0.0f) {
        // If v and l are on the same side of the surface do Torrance-Sparrow BRDF
        // Positive definite dot products
        let pd_n_dot_v: f32 = max(n_dot_v, 0.0f);
        let pd_n_dot_l: f32 = max(n_dot_l, 0.0f);
        // Precaluclate dot products and half vectors
        let h_r: vec3<f32> = normalize(out_dir + v);
        let v_dot_h: f32 = max(dot(v, h_r), 0.0f);
        let n_dot_h: f32 = max(dot(n, h_r), 0.0f);
        // Lambertian diffuse
        let lambert: vec3<f32> = material.albedo * INV_PI;
        // Torrance-Sparrow
        let F: vec3<f32> = mix(vec3<f32>(fresnel(abs(v_dot_h), eta_i, eta_o)), material.albedo, material.metallic);

        let F_greyscale: f32 = rgb_to_greyscale(F);
        let D: f32 = trowbridgeReitz(alpha, n_dot_h);
        // let G = smithAlt(alpha, pd_n_dot_v, pd_n_dot_l);
        let G: f32 = smith(alpha, pd_n_dot_v, pd_n_dot_l);
        let diffuse_factor: f32 = (1.0f - F_greyscale) * (1.0f - material.metallic) * (1.0f - material.transmission);
        let torrance_sparrow: vec3<f32> = D * F * G / max(4.0f * pd_n_dot_v * pd_n_dot_l, BIAS);
        let radiance: vec3<f32> = diffuse_factor * lambert + torrance_sparrow;
        return radiance * n_dot_l;
    } else {
        // Refractive half-vector (eq. 16)
        let ht_unorm = - (eta_i * v + eta_o * out_dir);
        let ht = normalize(ht_unorm);
        // Precalculate dot products
        let v_dot_ht = dot(v, ht);
        let l_dot_ht = dot(out_dir, ht);
        let n_dot_ht = abs(dot(n, ht));
        // Microfacet terms
        let DT: f32 = trowbridgeReitz(alpha, abs(n_dot_ht));
        let GT: f32 = smith(alpha, abs(n_dot_v), abs(n_dot_l));

        let FT: vec3<f32> = mix(vec3<f32>(fresnel(abs(v_dot_ht), eta_i, eta_o)), material.albedo, material.metallic);
        // Geometry term numerator and denominator
        let numerator_geom = abs(v_dot_ht) * abs(l_dot_ht);
        let denominator_geom: f32 = abs(n_dot_v) * abs(n_dot_l);
        // Refractive term denominator
        let denom_f = eta_i * v_dot_ht + eta_o * l_dot_ht;
        let denom_f_sq = denom_f * denom_f;
        // Check if refraction is possible
        if (abs(denom_f) > BIAS && denominator_geom > BIAS) {
            // Term is uncolored by albedo, this is handled by Beer's law in lightTrace
            let walter = (numerator_geom / denominator_geom) * (1.0f - rgb_to_greyscale(FT)) * DT * GT * (eta_o * eta_o / denom_f_sq);
            return vec3<f32>(walter) * material.transmission * n_dot_l;
        }
        // If refraction is not possible, return black this case should never happen
        return vec3<f32>(0.0f, 0.0f, 0.0f);
    }
}

struct SampleBSDF {
    unit_direction: vec3<f32>,
    throughput: vec3<f32>,
    random_state: u32,
    refracted: bool,
    lobe: u32,
    // Solid angle density of the sampled direction as evalLobe defines it, zero for delta lobes
    pdf: f32
}

// SampleBSDF takes in incoming direction, surface normal, material and random state and returns an outgoing direction with throughput according to the BSDF for global illumination
fn sampleBSDF(in_dir: vec3<f32>, n: vec3<f32>, material: Material, eta_i: f32, eta_o: f32, random_init: u32, screen_space: vec2<f32>) -> SampleBSDF {
    var random_state: u32 = random_init;
    // Basic dot products
    let v: vec3<f32> = - in_dir;
    let n_dot_v: f32 = dot(n, v);
    var n_i: vec3<f32> = n * sign(n_dot_v);
    let n_i_dot_v: f32 = abs(n_dot_v);
    // Material constants
    let alpha: f32 = material.roughness * material.roughness;
    // Sample using GGX importance sampling for potential refractive or reflective case
    var ggx_n: vec3<f32> = n_i;
    // Generate random values for sampling
    let random_h_1: Random = pcg(random_state);
    let random_h_2: Random = pcg(random_h_1.state);
    random_state = random_h_2.state;
    let v_tangent: vec3<f32> = worldToTangent(v, n_i);
    ggx_n = sampleGGXVNDF(v_tangent.xzy, alpha, random_h_1.value, random_h_2.value).xzy;
    // Transform half vector back to world space
    ggx_n = tangentToWorld(ggx_n, n_i);
    // Calculate shared half vector dot products
    let v_dot_h: f32 = dot(ggx_n, v);
    let n_dot_h: f32 = dot(n_i, ggx_n);
    // Visible normal density of the unclamped GGX distribution for the sampled half vector
    let d_term: f32 = n_dot_h * n_dot_h * (alpha * alpha - 1.0f) + 1.0f;
    let pdf_h: f32 = select(0.0f, smithG1(alpha, n_i_dot_v) * v_dot_h * alpha * alpha / (PI * d_term * d_term * n_i_dot_v), alpha > 0.0f && v_dot_h > 0.0f && n_dot_h > 0.0f && n_i_dot_v > 0.0f);
    // Try refraction through the properly oriented half vector
    let eta: f32 = eta_i / eta_o;
    let refracted: vec3<f32> = normalize(refract(in_dir, ggx_n, eta));
    // let refracted_sign = sign(length(refracted));
    // Calculate fresnel term
    var F: vec3<f32> = mix(vec3<f32>(fresnel(abs(v_dot_h), eta_i, eta_o)), material.albedo, material.metallic);
    /*
    if (screen_space.x > 0.0f) {
        let f0_sqrt = (eta_i - eta_o) / (eta_i + eta_o);
        let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);
        F = fresnel_schlick(f0, n_i_dot_v);
    }
    */
    let F_greyscale: f32 = rgb_to_greyscale(F);
    // BSDF weights (these are artistic choices to balance the lobes)
    let reflect_weight: f32 = 1.0f;
    let diffuse_weight: f32 = (1.0f - material.transmission) * (1.0f - material.metallic);
    let refract_weight: f32 = material.transmission;
    // Add fresnel term for improved sampling performance
    let reflect_component: f32 = max(reflect_weight * F_greyscale, 0.0f);
    let diffuse_component: f32 = max(diffuse_weight * (1.0f - F_greyscale), 0.0f);
    let refract_component: f32 = max(refract_weight * (1.0f - F_greyscale) * sign(length(refracted)), 0.0f);
    // Do not account for chroma of reflection for transmissive materials as in this case our model uses albedo as proxy for absorption instead.
    var colorless_reflection: f32 = material.transmission;
    // Calculate sampling probabilities
    let total_component: f32 = reflect_component + diffuse_component + refract_component;
    let total_component_inv: f32 = 1.0f / max(total_component, BIAS);
    let p_diffuse: f32 = diffuse_component * total_component_inv;
    let p_reflect: f32 = reflect_component * total_component_inv;
    let p_refract: f32 = refract_component * total_component_inv;
    //let p_total_reflect: f32 = total_reflection_component * total_component_inv;

    var sample: SampleBSDF = SampleBSDF(vec3<f32>(1.0f), vec3<f32>(1.0f), 0u, false, 0u, 0.0f);
    let random_p: Random = pcg(random_state);
    random_state = random_p.state;
    // Diffuse case
    if (random_p.value < p_diffuse) {
        let random_d_1: Random = pcg(random_state);
        let random_d_2: Random = pcg(random_d_1.state);
        sample.random_state = random_d_2.state;
        // Sample cosine weighted hemisphere
        let cosine_hemisphere: vec3<f32> = sampleCosWeightedHemisphere(random_d_1.value, random_d_2.value);
        sample.unit_direction = tangentToWorld(cosine_hemisphere, n_i);

        // BSDF = diffuse_weight * albedo / PI
        // => BSDF * n_dot_v = diffuse_weight * albedo * n_dot_l / PI

        // PDF_COSINE_HEMISPHERE = cosine_hemisphere.y / PI
        // => PDF = cosine_hemisphere.y / PI

        // throughput = BSDF * n_dot_l / PDF
        //            = diffuse_weight * albedo * n_dot_l / PI / cosine_hemisphere.y * PI
        //            = diffuse_weight * albedo * n_dot_l / cosine_hemisphere.y

        // Since cosine_hemisphere.y is n_dot_l over the unit hemisphere, we can simplify the throughput to:
        // => throughput = albedo * diffuse_weight
        sample.throughput = diffuse_weight * material.albedo / p_diffuse;
        sample.pdf = select(0.0f, p_diffuse * cosine_hemisphere.y * INV_PI, n_i_dot_v > 0.0f);
        return sample;
    }
    // Refractive case
    if (random_p.value < p_diffuse + p_refract) {
        // Refraction is valid
        sample.unit_direction = refracted;
        let l: vec3<f32> = sample.unit_direction;
        let m_n_i_dot_l: f32 = - dot(n_i, l);
        let l_dot_h: f32 = dot(l, ggx_n);
        let denom: f32 = eta_i * v_dot_h + eta_o * l_dot_h;
        sample.pdf = select(0.0f, p_refract * pdf_h * eta_o * eta_o * abs(l_dot_h) / (denom * denom), eta_i != eta_o && l_dot_h < 0.0f);
        // Microfacet term
        // let GT: f32 = smith(alpha, n_i_dot_v, m_n_i_dot_l);
        let G1_l: f32 = G1(alpha, max(m_n_i_dot_l, 0.0f));
        // JACOBIAN = eta_o^2 * l_dot_h / (eta_i * v_dot_h + eta_o * l_dot_h)^2

        // BSDF = refract_weight * v_dot_h / n_dot_v / n_dot_l * D * G * (1 - F) * JACOBIAN
        // => BSDF * n_dot_l = refract_weight * v_dot_h / n_dot_v * D * G * (1 - F) * JACOBIAN

        // PDF_VNDF = G1_v * v_dot_h * D / n_dot_v
        // PDF_REFRACT = PDF_VNDF * JACOBIAN
        //             = G1_v * v_dot_h * D / n_dot_v * JACOBIAN

        // PDF = PDF_REFRACT
        //     = G1_v * v_dot_h * D / n_dot_v * JACOBIAN

        // throughput = BSDF * n_dot_l
        //            = refract_weight * v_dot_h / n_dot_v * D * G * (1 - F) * JACOBIAN / G1_v / v_dot_h / D * n_dot_v / JACOBIAN
        //            = refract_weight * G * (1 - F) / G1_v

        // G = G1_v * G1_l
        // => throughput = refract_weight * G1_l * (1 - F)
        sample.throughput = vec3<f32>(refract_weight * G1_l * (1.0f - F_greyscale) / p_refract);
        sample.random_state = random_state;
        sample.refracted = true;
        sample.lobe = 1u;
        return sample;
    }
    // Otherwise assume reflective case.
    sample.unit_direction = normalize(reflect(in_dir, ggx_n));
    let l: vec3<f32> = sample.unit_direction;
    let n_i_dot_l: f32 = dot(n_i, l);
    // Torrance-Sparrow
    let G1_l: f32 = G1(alpha, max(n_i_dot_l, 0.0f));
    // BSDF = reflect_weight * D * G * F / (4 * n_dot_v * n_dot_l)
    // => BSDF * n_dot_l = reflect_weight * D * G * F / (4 * n_dot_v)

    // PDF_VNDF = G1_v * v_dot_h * D / n_dot_v
    // JACOBIAN = 1 / (4 * v_dot_h)
    // PDF_REFLECT = PDF_VNDF * JACOBIAN
    // => PDF_REFLECT = G1_v * D / (4 * n_dot_v)

    // PDF = PDF_REFLECT
    // => PDF = G1_v * D / (4 * v_dot_n)

    // throughput = BSDF * n_dot_l / PDF
    //            = reflect_weight * D * G * F / (4 * n_dot_v) / G1_v / D * (4 * n_dot_v)
    //            = reflect_weight * G * F / G1_v

    // G = G1_v * G1_l
    // => throughput = reflect_weight * G1_l * F
    sample.throughput = reflect_weight * G1_l * mix(F, vec3<f32>(F_greyscale), colorless_reflection) / p_reflect;
    sample.random_state = random_state;
    sample.lobe = 2u;
    sample.pdf = select(0.0f, p_reflect * pdf_h / (4.0f * v_dot_h), pdf_h > 0.0f);
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

struct LightSample {
    dir: vec3<f32>,
    offset: vec3<f32>,
    brightness: vec3<f32>,
    inv_pdf: f32,
    random_state: u32
}

// Draw a point on the light and compute the unshadowed brightness it casts onto origin
fn sampleLight(light: Light, init_random_state: u32, origin: vec3<f32>, random_sphere: vec3<f32>) -> LightSample {
        var random_state: u32 = init_random_state;
        var light_position: vec3<f32>;
        var dir: vec3<f32>;
        var offset: vec3<f32>;
        var intensity: f32;
        var inv_pdf: f32 = 1.0f;
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

            // Assemble and transform normals
            let normals: mat3x3<f32> = transform.rotation * mat3x3<f32>(t2.yzw, t3.xyz, vec3<f32>(t3.w, t4.xy));
            // Compute edge vectors
            let edge1: vec3<f32> = t[1] - t[0];
            let edge2: vec3<f32> = t[2] - t[0];
            let edge3: vec3<f32> = t[2] - t[1];

            let min_edge_length: f32 = min(length(edge1), min(length(edge2), length(edge3)));

            let light_geometry_n: vec3<f32> = normalize(cross(edge1, edge2));
            let diffs: vec3<f32> = vec3<f32>(
                distance(origin, t[0]),
                distance(origin, t[1]),
                distance(origin, t[2])
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
            light_position = t * geometry_uvw;
            // Calculate normal
            let edge_cross: vec3<f32> = cross(edge1, edge2);
            let light_area: f32 = max(length(edge_cross) * 0.5f, BIAS);

            // Calculate light direction
            dir = light_position - origin;
            // Outgoing angle at light source
            let light_n_dot_ml: f32 = max(dot(light_smooth_n, - normalize(dir)), 0.0f);
            // Offset light position to avoid self shadowing
            offset = light_smooth_n * light_geometry_offset;
            // Calculate intensity with respect to sampling probability of triangle and point on triangle
            inv_pdf = light_area * triangle_count;
            intensity = inv_pdf * light_n_dot_ml;
        } else if (light.is_area_light == 0.0f) {
            // CASE 1: Point light
            // Yeild random vector in sphere to simulate point light volume and update state
            light_position = light.position + random_sphere * light.variance;
            // Calculate light direction
            dir = light_position - origin;
            offset = vec3<f32>(0.0f);
            intensity = light.intensity;
        }

        let len: f32 = length(dir);
        // Apply inverse square law
        return LightSample(dir, offset, light.color * intensity / max(len * len, BIAS), inv_pdf, random_state);
}

// Shadow test toward a light sample, including the quick exit for lights behind the shading normal
fn occluded(origin: vec3<f32>, smooth_n: vec3<f32>, geometry_offset: f32, light_dir: vec3<f32>) -> bool {
    let unit_light_dir: vec3<f32> = normalize(light_dir);
    // Compute quick exit criterion to potentially skip expensive shadow test
    if (dot(smooth_n, unit_light_dir) < 0.0f) {
        return true;
    }
    // Apply geometry offset
    let offset_target: vec3<f32> = origin + geometry_offset * smooth_n;
    let light_ray: Ray = Ray(offset_target, unit_light_dir);
    return shadowTraverseInstanceBVH(light_ray, length(light_dir), false);
}

struct NEESample {
    color: vec3<f32>,
    random_state: u32,
    // Selected light, the random state its point was drawn with, unshadowed radiance and direction toward it
    light: u32,
    light_state: u32,
    // Reciprocal area density of the light point times the light selection weight
    inv_pdf: f32,
    radiance: vec3<f32>,
    dir: vec3<f32>
}

fn reservoirSample(material: Material, eta_i: f32, eta_o: f32, camera_ray: Ray, init_random_state: u32, smooth_n: vec3<f32>, geometry_n: vec3<f32>, geometry_offset: f32, random_sphere: vec3<f32>, screen_space: vec2<f32>) -> NEESample {
    var sample: NEESample;
    sample.random_state = init_random_state;
    let m: u32 = uniforms_uint.light_count + 1u;
    // If no lights, return emissive color
    if (m <= 1u) {
        return sample;
    }

    var w_sum: f32 = 0.0f;
    var reservoir_color: vec3<f32> = vec3<f32>(0.0f);
    var reservoir_dir: vec3<f32>;
    var random_state: u32 = init_random_state;
    // Iterate over lights
    for (var i: u32 = 0u; i < uniforms_uint.light_count; i++) {
        // Read light from storage buffer
        let light_sample: LightSample = sampleLight(lights[i + 1u], random_state, camera_ray.origin, random_sphere);
        let light_state: u32 = random_state;
        random_state = light_sample.random_state;
        let l: vec3<f32> = light_sample.dir / length(light_sample.dir);
        let brightness: vec3<f32> = light_sample.brightness;
        // Calculate BSDF for light
        let color_with_smooth = BSDF(camera_ray.unit_direction, l, smooth_n, geometry_n, material, eta_i, eta_o, screen_space);
        let color_for_light: vec3<f32> = color_with_smooth * brightness;
        let w_i: f32 = rgb_to_greyscale(color_for_light);
        // Skip light if its contribution is too small
        if (w_i <= BIAS) {
            continue;
        }

        w_sum += w_i;
        // Yeild random value between 0 and 1 and update state
        let random_value: Random = pcg(random_state);
        random_state = random_value.state;
        if (random_value.value * w_sum <= w_i) {
            reservoir_color = color_for_light / w_i;
            reservoir_dir = light_sample.dir + light_sample.offset;
            sample.light = i;
            sample.light_state = light_state;
            sample.inv_pdf = light_sample.inv_pdf / w_i;
            sample.radiance = brightness / light_sample.inv_pdf;
            sample.dir = l;
        }
    }

    sample.random_state = random_state;
    // Test if in shadow
    if (w_sum == 0.0f || occluded(camera_ray.origin, smooth_n, geometry_offset, reservoir_dir)) {
        sample.radiance = vec3<f32>(0.0f);
        return sample;
    }
    sample.color = reservoir_color * w_sum;
    sample.inv_pdf *= w_sum;
    return sample;
}

fn calculatePointLightContrib(point_light_index: u32) -> vec3<f32> {
    let point_light: Light = lights[point_light_index];
    return point_light.color * point_light.intensity / (4.0f * PI * point_light.variance * point_light.variance);
}

struct Surface {
    smooth_n: vec3<f32>,
    geometry_n: vec3<f32>,
    geometry_offset: f32,
    material: Material,
    skip: bool,
    random_state: u32
}

// Fetch geometry and textured material of a triangle hit, transparent texels are skipped stochastically
fn surfaceAt(hit: Hit, origin: vec3<f32>, init_random_state: u32) -> Surface {
    var random_state: u32 = init_random_state;
    var skip_hit: bool = false;
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
    let offset_ray_target: vec3<f32> = origin - transform.shift;
    // Compute edge vectors
    let edge1: vec3<f32> = t[1] - t[0];
    let edge2: vec3<f32> = t[2] - t[0];
    let edge3: vec3<f32> = t[2] - t[1];

    let min_edge_length: f32 = min(length(edge1), min(length(edge2), length(edge3)));

    let geometry_n: vec3<f32> = normalize(cross(edge1, edge2));
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
    let geometry_offset: f32 = clamp(dot(diffs * angle_tan, geometry_uvw), 0.0f, min_edge_length * 0.125f);
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
        // Enable transparent textures
        // Yeild random value between 0 and 1 and update state
        let transparancy_random_value: Random = pcg(random_state);
        random_state = transparancy_random_value.state;
        if (1.0f - albedo_data.w > transparancy_random_value.value) {
            skip_hit = true;
        }
    }

    if (!skip_hit) {
        let normal_texture_id: u32 = instance_uint[hit_instance_location + 4u];
        if (normal_texture_id != UINT_MAX) {
            let uv0: vec2<f32> = t4.zw;
            let uv1: vec2<f32> = t5.xy;
            let uv2: vec2<f32> = t5.zw;
            let tbn: mat3x3<f32> = normalMapTBN(t[0], t[1], t[2], uv0, uv1, uv2, smooth_n);
            var normal_data: vec3<f32> = normalize(textureSample(normal_texture_id, barycentric).xyz * INV_255 * 2.0f - 1.0f);
            normal_data.y = -normal_data.y;
            smooth_n = normalize(tangentToWorldNormalMap(normal_data, tbn));
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
    }
    return Surface(smooth_n, geometry_n, geometry_offset, material, skip_hit, random_state);
}

// If the ray is inside a medium, apply Beer's law for absorption.
fn beerLambert(distance: f32, instance_index: u32) -> vec3<f32> {
    // Convert absorption color from sRGB to linear space for physically correct Beer-Lambert
    // The amount of light transmitted is T = exp(-sigma_a * d).
    let absorption_coefficient: vec3<f32> = max(instance_material[instance_index].albedo, vec3<f32>(BIAS));
    return exp(distance * log(absorption_coefficient));
}

// Decide between next event estimation and emission on the next hit, as the path tracer does
fn neeDecision(material: Material, n_dot_v: f32, eta_i: f32, eta_o: f32) -> bool {
    // Calculate fresnel term
    let F_n: vec3<f32> = mix(vec3<f32>(fresnel(abs(n_dot_v), eta_i, eta_o)), material.albedo, material.metallic);
    let F_n_greyscale: f32 = rgb_to_greyscale(F_n);
    let diffuse_factor_estimate: f32 = max((1.0f - F_n_greyscale) * (1.0f - material.metallic) * (1.0f - material.transmission), 0.0f);
    return diffuse_factor_estimate > 0.04f || material.roughness > 0.2f;
}

fn lightTrace(init_hit: Hit, origin: vec3<f32>, camera: vec3<f32>, init_random_state: u32, screen_space: vec2<f32>) -> SampledColor {
    // Use additive color mixing technique, so start with black
    var final_color: vec3<f32> = vec3<f32>(0.0f);
    var importancy_factor: vec3<f32> = vec3<f32>(1.0f);
    var hit: Hit = init_hit;
    var ray: Ray = Ray(origin, normalize(origin - camera));
    var random_state: u32 = init_random_state;
    var add_ambient: bool = false;
    var is_inside: bool = false;
    // var skip_hit: bool = false;
    var i: u32 = 0u;
    // Precalculate random sphere
    let light_offset_sphere: RandomSphere = random_sphere(random_state);
    let light_offset_dir: vec3<f32> = light_offset_sphere.value;

    random_state = light_offset_sphere.state;
    var direct_light_emission: bool = true;
    // Density of the lobe the last escape was sampled with, zero if it takes the full weight
    var escape_pdf: f32 = 0.0f;
    // Iterate over each bounce and modify color accordingly
    while (true) {
        var geometry_offset: f32 = 0.0f;
        var smooth_n: vec3<f32> = vec3<f32>(0.0f);
        var skip_hit: bool = false;
        let point_light_lighting: bool = hit.is_point_light == 1u && direct_light_emission;
        let current_direct_light_emission: bool = direct_light_emission;

        if (!point_light_lighting) {
            let surface: Surface = surfaceAt(hit, ray.origin, random_state);
            random_state = surface.random_state;
            smooth_n = surface.smooth_n;
            geometry_offset = surface.geometry_offset;
            skip_hit = surface.skip;
            let geometry_n: vec3<f32> = surface.geometry_n;
            let material: Material = surface.material;
            if (is_inside) {
                importancy_factor *= beerLambert(hit.distance, hit.instance_index);
            }
            // Environment next event estimation never passes texels, escapes through them take the full weight
            escape_pdf = 0.0f;

            if (!skip_hit) {
                // Determine local color considering PBR attributes and lighting
                // Hybrid method
                if (current_direct_light_emission) {
                    final_color += material.emissive * importancy_factor * max(sign(dot(- ray.unit_direction, smooth_n)), 0.0f);
                    direct_light_emission = false;
                }

                let alpha: f32 = material.roughness * material.roughness;

                let n_dot_v: f32 = dot(smooth_n, - ray.unit_direction);
                let is_entering: bool = n_dot_v < 0.0f;
                // Incident side is air, outgoing side is material (entering)
                let eta_i: f32 = select(1.0f, material.ior, is_entering);
                // Incident side is material, outgoing side is air (exiting)
                let eta_o: f32 = select(material.ior, 1.0f, is_entering);
                // if (screen_space.x > 0.0f) {
                if (neeDecision(material, n_dot_v, eta_i, eta_o)) {
                    // Do NEE
                    let local_sampled: NEESample = reservoirSample(material, eta_i, eta_o, ray, random_state, smooth_n, geometry_n, geometry_offset, light_offset_dir, screen_space);
                    random_state = local_sampled.random_state;
                    final_color += local_sampled.color * importancy_factor;
                } else {
                    // Sample directly next round
                    direct_light_emission = true;
                }
                /*
                } else {
                    // Conservative only NEE method
                    let local_sampled: SampledColor = reservoirSample(material, eta_i, eta_o, ray, random_state, smooth_n, geometry_n, geometry_offset, light_offset_dir, screen_space);
                    random_state = local_sampled.random_state;
                    // Calculate primary light sources for this pass if ray hits non translucent object
                    final_color += local_sampled.color * importancy_factor;
                    // Add emissive color to final color only on first bounce otherwise rely on NEE
                    if (i == 0u) {
                        final_color += material.emissive * importancy_factor;
                    }
                }
                */
                // Attempt ray bounce with material normal first
                let bsdf_state: u32 = random_state;
                var bsdf_sampled: SampleBSDF = sampleBSDF(ray.unit_direction, smooth_n, material, eta_i, eta_o, random_state, screen_space);
                random_state = bsdf_sampled.random_state;
                // Meassure if outgoing ray points towards incorrect side of the sphere.
                let expected_out_dir_normal_aligned: bool = (!is_inside && !bsdf_sampled.refracted) || (is_inside && bsdf_sampled.refracted);
                let out_dir_normal_aligned: bool = dot(bsdf_sampled.unit_direction, geometry_n) > 0.0f;
                // Continue sampling with geometry normal if ray points to incorrect side of the surface
                if (expected_out_dir_normal_aligned != out_dir_normal_aligned) {
                    // Continue ray bounce and pretend the self reflection faces according to the geometry normal, making incorrect bounces impossible.
                    let geometry_bsdf_sampled = sampleBSDF(bsdf_sampled.unit_direction, geometry_n, material, eta_i, eta_o, random_state, screen_space);
                    random_state = geometry_bsdf_sampled.random_state;
                    // Redirect outgoing ray according to new bsdf sample.
                    bsdf_sampled.unit_direction = geometry_bsdf_sampled.unit_direction;
                    bsdf_sampled.refracted = geometry_bsdf_sampled.refracted;
                    // Multiply to compute combined throughput, doing proper self shadowing.
                    bsdf_sampled.throughput = geometry_bsdf_sampled.throughput;
                }
                // Next event estimation toward the environment map, weighted against the BSDF sampled escape
                if (!direct_light_emission && environmentMapped() && i < uniforms_uint.max_bounces) {
                    let sky: SkySample = sampleSky(ray, surface, vec2<f32>(eta_i, eta_o), is_inside, random_state, bsdf_state);
                    random_state = sky.random_state;
                    final_color += importancy_factor * sky.color;
                    if (expected_out_dir_normal_aligned == out_dir_normal_aligned) {
                        escape_pdf = bsdf_sampled.pdf;
                    }
                }
                // If the scattered ray is on the opposite side of the surface, we have entered or exited the medium.
                if (bsdf_sampled.refracted) {
                    is_inside = !is_inside;
                }

                ray.unit_direction = bsdf_sampled.unit_direction;
                importancy_factor *= max(bsdf_sampled.throughput, vec3<f32>(0.0f));

                let out_dir_aligned_normal: vec3<f32> = select(smooth_n, - smooth_n, is_inside);
                ray.origin += geometry_offset * out_dir_aligned_normal;
            }
        }

        var survival_probability: f32 = 1.0f;
        if (!skip_hit) {
            survival_probability = clamp(max(importancy_factor.x, max(importancy_factor.y, importancy_factor.z)), 0.0f, 1.0f);
        }

        let random_value: Random = pcg(random_state);
        random_state = random_value.state;
        // Test for early termination, avoiding last bounce
        if (survival_probability < random_value.value || i >= uniforms_uint.max_bounces ) {
            add_ambient = false;
            break;
        }
        // Continue with next bounce
        importancy_factor /= survival_probability;

        if (point_light_lighting && !skip_hit) {
            final_color += importancy_factor * calculatePointLightContrib(hit.instance_index);
        }
        // Increment hit iterator
        i = i + 1u;
        // Calculate next intersection
        hit = traverseInstanceBVH(ray, direct_light_emission, POW32);
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
            final_color += importancy_factor * env_color * escapeWeight(escape_pdf, dir);
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

fn environmentMapped() -> bool {
    return uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u;
}

// Solid angle density of sampleSky, piecewise constant over the luminance distribution of the environment map
fn environmentPdf(dir: vec3<f32>) -> f32 {
    let size: vec2<u32> = textureDimensions(environment_cdf) - vec2<u32>(1u, 0u);
    // Same coordinates as env_map_sample
    let st: vec2<f32> = vec2<f32>(atan2(- dir.z, - dir.x) / (2.0f * PI) + 0.5f, acos(clamp(dir.y, -1.0f, 1.0f)) / PI);
    let cell: vec2<u32> = min(vec2<u32>(st * vec2<f32>(size)), size - 1u);
    let p: f32 = textureLoad(environment_cdf, cell, 0).y * textureLoad(environment_cdf, vec2<u32>(size.x, cell.y), 0).y;
    return p * f32(size.x * size.y) / (2.0f * PI * PI * length(dir.xz));
}

// First entry of a row or of the marginal column of the environment CDF exceeding u
fn searchCDF(start: vec2<u32>, step: vec2<u32>, count: u32, u: f32) -> u32 {
    var low: u32 = 0u;
    var high: u32 = count - 1u;
    while (low < high) {
        let middle: u32 = (low + high) / 2u;
        if (textureLoad(environment_cdf, start + step * middle, 0).x > u) {
            high = middle;
        } else {
            low = middle + 1u;
        }
    }
    return low;
}

// Radiance the path tracer's ray from a vertex along dir receives from the environment map if it hits nothing on the way.
// Escapes passing transparent texels are left to BSDF sampling.
fn skyRadiance(origin: vec3<f32>, surface: Surface, is_inside: bool, dir: vec3<f32>) -> vec3<f32> {
    let inside: bool = is_inside != wrongSide(is_inside, false, dir, surface.geometry_n);
    let ray: Ray = Ray(origin + surface.geometry_offset * select(surface.smooth_n, - surface.smooth_n, inside), dir);
    return select(env_map_sample(dir), vec3<f32>(0.0f), shadowTraverseInstanceBVH(ray, POW32, true));
}

struct SkySample {
    dir: vec3<f32>,
    radiance: vec3<f32>,
    // Radiance times the weighted BSDF of skyBSDF
    color: vec3<f32>,
    random_state: u32
}

// Next event estimation toward the environment map, drawing a direction by its luminance. lobe_state is the random state of skyBSDF.
fn sampleSky(ray: Ray, surface: Surface, eta: vec2<f32>, is_inside: bool, init_random_state: u32, lobe_state: u32) -> SkySample {
    let size: vec2<u32> = textureDimensions(environment_cdf) - vec2<u32>(1u, 0u);
    let random_0: Random = pcg(init_random_state);
    let random_1: Random = pcg(random_0.state);
    let random_2: Random = pcg(random_1.state);
    let random_3: Random = pcg(random_2.state);
    let row: u32 = searchCDF(vec2<u32>(size.x, 0u), vec2<u32>(0u, 1u), size.y, random_0.value);
    let column: u32 = searchCDF(vec2<u32>(0u, row), vec2<u32>(1u, 0u), size.x, random_1.value);
    let angles: vec2<f32> = (vec2<f32>(f32(column), f32(row)) + vec2<f32>(random_2.value, random_3.value)) / vec2<f32>(size) * vec2<f32>(2.0f * PI, PI);
    let dir: vec3<f32> = vec3<f32>(sin(angles.y) * cos(angles.x), cos(angles.y), sin(angles.y) * sin(angles.x));
    let pdf: f32 = environmentPdf(dir);
    let f: vec3<f32> = skyBSDF(ray.unit_direction, dir, surface, eta, is_inside, pdf, lobe_state);
    // Only trace toward directions that contribute
    if (!(pdf > 0.0f) || all(f == vec3<f32>(0.0f))) {
        return SkySample(dir, vec3<f32>(0.0f), vec3<f32>(0.0f), random_3.state);
    }
    let radiance: vec3<f32> = skyRadiance(ray.origin, surface, is_inside, dir);
    return SkySample(dir, radiance, f * radiance, random_3.state);
}

// BSDF times cosine toward an environment sample over its density, each lobe weighted against the BSDF sampled escape by the
// balance heuristic. Lobes the first sampling attempt can't produce toward dir are left to the geometry normal fallback.
fn skyBSDF(in_dir: vec3<f32>, dir: vec3<f32>, surface: Surface, eta: vec2<f32>, is_inside: bool, pdf: f32, random_state: u32) -> vec3<f32> {
    let refracted: bool = wrongSide(is_inside, false, dir, surface.geometry_n);
    var f: vec3<f32> = vec3<f32>(0.0f);
    for (var lobe: u32 = 0u; lobe < 3u; lobe++) {
        if ((lobe == LOBE_REFRACT) == refracted) {
            let l: Lobe = evalLobe(in_dir, dir, surface.smooth_n, surface.material, eta.x, eta.y, lobe, random_state);
            if (l.pdf > 0.0f) {
                f += l.f_cos / (l.pdf + pdf);
            }
        }
    }
    return f;
}

// MIS weight of a BSDF sampled escape from a vertex doing next event estimation, pdf is the density of the sampled lobe.
// Delta lobes and the geometry normal fallback (pdf zero) are never drawn by sampleSky.
fn escapeWeight(pdf: f32, dir: vec3<f32>) -> f32 {
    if (pdf <= 0.0f || !environmentMapped()) {
        return 1.0f;
    }
    return pdf / (pdf + environmentPdf(dir));
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
    let init_hit: Hit = Hit(uvw.yz, instance_index, triangle_index, 0u, distance(absolute_position, uniforms_float.camera_position.xyz));
    // Determine if additional samples are needed
    var sampleFactor: u32 = 1u;

    if (uniforms_uint.is_temporal == 1u) {
        // Get count of shifted texture
        let shift_out_float_0: vec4<f32> = textureLoad(shift_out_float, screen_pos, 0, 0);
        let shift_out_float_1: vec4<f32> = textureLoad(shift_out_float, screen_pos, 1, 0);
        /*
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
        */
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

    // Clamp color to 16 bit float
    // Maximal representable number in f16 is 65520
    final_color = clamp(final_color, vec3<f32>(0.0f), vec3<f32>(65519.0f));
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

// ReSTIR PT Enhanced (Lin, Kettunen and Wyman 2026) on top of the path tracer above.
// Paths live in primary sample space, vertex b draws its random numbers from stream(seed, b).

// Single-vertex roughness threshold (Sec. 4.2)
const RESTIR_ROUGHNESS: f32 = 0.2;
// Dual ray footprint constant c / 100 * 4 PI of Eq. 5 with c = 0.02
const RESTIR_FOOTPRINT: f32 = 0.0025132741228718345;
// Temporal confidence cap and its duplication-driven reduction (Sec. 5)
const RESTIR_CAP: f32 = 20.0;
const RESTIR_CAP_MIN: f32 = 1.0;
const RESTIR_DUPLICATION_ALPHA: f32 = 0.1;

const LOBE_DIFFUSE: u32 = 0u;
const LOBE_REFRACT: u32 = 1u;

// How a path ends: next event estimation, emissive surface, point light sphere, environment or environment by next event estimation
const END_NEE: u32 = 0u;
const END_EMIT: u32 = 1u;
const END_POINT: u32 = 2u;
const END_ENV: u32 = 3u;
const END_SKY: u32 = 4u;

// Reconnection vertex: none (pure random replay), triangle hit, NEE light vertex or environment direction
const RC_NONE: u32 = 0u;
const RC_SURFACE: u32 = 1u;
const RC_LIGHT: u32 = 2u;
const RC_ENV: u32 = 3u;

// Bit offsets of the packed path description
const PATH_END: u32 = 0u;
const PATH_K: u32 = 5u;
const PATH_RC: u32 = 10u;
const PATH_TYPE: u32 = 12u;
const PATH_LOBE_PREV: u32 = 15u;
const PATH_LOBE: u32 = 17u;
const PATH_NEE: u32 = 19u;
const PATH_INSIDE: u32 = 20u;

// Random streams besides the per vertex ones
const STREAM_NEE: u32 = 64u;
const STREAM_RR: u32 = 128u;
const STREAM_SPHERE: u32 = 192u;
const STREAM_SELECT: u32 = 193u;
const STREAM_SKY: u32 = 256u;

// Layers 0 - 5 previous frame reservoirs, 6 - 10 temporal reservoirs, 11 - 15 initial reservoirs or paired shifts, 16 duplication map
@group(0) @binding(6) var reservoir_prev: texture_2d_array<u32>;
@group(0) @binding(7) var reservoir_temp: texture_2d_array<u32>;
@group(0) @binding(8) var reservoir_temp_out: texture_storage_2d_array<rgba32uint, write>;
@group(0) @binding(9) var reservoir_prev_out: texture_storage_2d_array<rgba32uint, write>;
@group(0) @binding(15) var reservoir_initial: texture_2d_array<u32>;
@group(0) @binding(16) var reservoir_initial_out: texture_storage_2d_array<rgba32uint, write>;
@group(0) @binding(10) var shift_data: texture_2d_array<u32>;
@group(0) @binding(11) var shift_data_out: texture_storage_2d_array<rgba32uint, write>;
@group(0) @binding(12) var duplication: texture_2d_array<u32>;
@group(0) @binding(13) var duplication_out: texture_storage_2d_array<rgba32uint, write>;
@group(0) @binding(14) var pairing: texture_2d_array<i32>;
@group(0) @binding(18) var<storage, read_write> shift_queue: ShiftQueue;
// The queue again, read only while it also holds the indirect dispatch size
@group(0) @binding(19) var<storage, read> queued_shifts: array<u32>;
// Layers 17 - 18 shifts of temporal reuse
@group(0) @binding(17) var temporal_shifts_out: texture_storage_2d_array<rgba32uint, write>;
@group(0) @binding(20) var temporal_shifts: texture_2d_array<u32>;

// Stream compaction of the temporal and paired spatial shifts (Sec. 6.2.2), sorted into bins of equal reconnection type and replay depth
const SHIFT_DEPTHS: u32 = 8u;
const SHIFT_BINS: u32 = 40u;

struct ShiftQueue {
    // Workgroups of restir_shift, jobs per bin, jobs written per bin and the jobs of all bins back to back
    dispatch: array<u32, 3>,
    counts: array<atomic<u32>, SHIFT_BINS>,
    cursors: array<atomic<u32>, SHIFT_BINS>,
    jobs: array<u32>,
}

struct Reservoir {
    seed: u32,
    path: u32,
    // Unbiased contribution weight and confidence
    w: f32,
    c: f32,
    // Integrand of the sample in the owning pixel
    f: vec3<f32>,
    // Source densities p(x_k-1 -> x_k) G(x_k-1 -> x_k) p(x_k -> x_k+1) of the reconnection
    jac: f32,
    // Triangle hit (instance, triangle, uv) of the reconnection vertex or NEE light (index, random state)
    rc: vec4<u32>,
    // Direction leaving the reconnection vertex and the radiance arriving along it
    dir: vec3<f32>,
    radiance: vec3<f32>,
}

struct Domain {
    x0: vec3<f32>,
    x1: vec3<f32>,
    hit: Hit,
}

// Sampling record of the previous path vertex for the reconnection criteria (Sec. 4)
struct Vertex {
    rough: bool,
    lobe: u32,
    pdf: f32,
    cos: f32,
    inside: bool,
}

struct Lobe {
    f_cos: vec3<f32>,
    pdf: f32,
}

struct Shift {
    f: vec3<f32>,
    jac: f32,
}

struct Selection {
    r: Reservoir,
    w_sum: f32,
    color: vec3<f32>,
    random_state: u32,
}

fn hash(x: u32) -> u32 {
    let state: u32 = x * 747796405u + 2891336453u;
    let word: u32 = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

fn stream(seed: u32, index: u32) -> u32 {
    return hash(seed ^ hash(index));
}

fn loadReservoir(source: texture_2d_array<u32>, p: vec2<i32>) -> Reservoir {
    let l0: vec4<u32> = textureLoad(source, p, 0, 0);
    let l1: vec4<u32> = textureLoad(source, p, 1, 0);
    let l3: vec4<u32> = textureLoad(source, p, 3, 0);
    let l4: vec4<u32> = textureLoad(source, p, 4, 0);
    return Reservoir(l0.x, l0.y, bitcast<f32>(l0.z), bitcast<f32>(l0.w), bitcast<vec3<f32>>(l1.xyz), bitcast<f32>(l1.w),
        textureLoad(source, p, 2, 0), bitcast<vec3<f32>>(l3.xyz), vec3<f32>(bitcast<f32>(l3.w), bitcast<vec2<f32>>(l4.xy)));
}

fn storeReservoir(destination: texture_storage_2d_array<rgba32uint, write>, p: vec2<i32>, r: Reservoir, x1: Hit) {
    textureStore(destination, p, 0, vec4<u32>(r.seed, r.path, bitcast<u32>(r.w), bitcast<u32>(r.c)));
    textureStore(destination, p, 1, vec4<u32>(bitcast<vec3<u32>>(r.f), bitcast<u32>(r.jac)));
    textureStore(destination, p, 2, r.rc);
    textureStore(destination, p, 3, vec4<u32>(bitcast<vec3<u32>>(r.dir), bitcast<u32>(r.radiance.x)));
    textureStore(destination, p, 4, vec4<u32>(bitcast<vec2<u32>>(r.radiance.yz), x1.instance_index, x1.triangle_index));
}

fn hitPosition(hit: Hit) -> vec3<f32> {
    let triangle_offset: u32 = hit.triangle_index * TRIANGLE_SIZE;
    let t0 = access_triangle(triangle_offset);
    let t1 = access_triangle(triangle_offset + 1u);
    let t2 = access_triangle(triangle_offset + 2u);
    let transform: Transform = instance_transform[hit.instance_index * 2u];
    let t: mat3x3<f32> = mat3x3<f32>(t0.xyz, vec3<f32>(t0.w, t1.xy), vec3<f32>(t1.zw, t2.x));
    return transform.rotation * (t * vec3<f32>(1.0f - hit.uv.x - hit.uv.y, hit.uv.x, hit.uv.y)) + transform.shift;
}

// Camera and primary hit of a pixel in the current frame, false for background pixels
fn currentDomain(p: vec2<i32>, dom: ptr<function, Domain>) -> bool {
    if (any(p < vec2<i32>(0)) || any(p >= vec2<i32>(uniforms_uint.render_size))) {
        return false;
    }
    let buffer_index: u32 = u32(p.x) + uniforms_uint.render_size.x * u32(p.y);
    return hitDomain(p, texture_offset[buffer_index * 2u] - 1u, texture_offset[buffer_index * 2u + 1u] - 1u, dom);
}

// Current domain from the primary hit stored with the pixel's initial or temporal reservoir
fn storedDomain(source: texture_2d_array<u32>, p: vec2<i32>, dom: ptr<function, Domain>) -> bool {
    if (any(p < vec2<i32>(0)) || any(p >= vec2<i32>(uniforms_uint.render_size))) {
        return false;
    }
    let hit: vec2<u32> = textureLoad(source, p, 4, 0).zw;
    return hitDomain(p, hit.x, hit.y, dom);
}

// The instance index marks background pixels in stored reservoirs
fn hitDomain(p: vec2<i32>, instance_index: u32, triangle_index: u32, dom: ptr<function, Domain>) -> bool {
    (*dom).hit.instance_index = instance_index;
    if (instance_index == UINT_MAX) {
        return false;
    }
    let x1: vec3<f32> = textureLoad(texture_absolute_position, p, 0).xyz;
    let uv: vec2<f32> = textureLoad(texture_uv, p, 0).xy;
    let distance_x1: f32 = distance(x1, uniforms_float.camera_position);
    *dom = Domain(uniforms_float.camera_position, x1, Hit(vec2<f32>(uv.y, 1.0f - uv.x - uv.y), instance_index, triangle_index, 0u, distance_x1));
    return true;
}

// Camera and primary hit a pixel had in the previous frame
fn previousDomain(q: vec2<i32>) -> Domain {
    let l4: vec4<u32> = textureLoad(reservoir_prev, q, 4, 0);
    var hit: Hit = Hit(bitcast<vec2<f32>>(textureLoad(reservoir_prev, q, 5, 0).xy), l4.z, l4.w, 0u, 0.0f);
    let x1: vec3<f32> = hitPosition(hit);
    hit.distance = distance(x1, uniforms_float.prev_camera_position);
    return Domain(uniforms_float.prev_camera_position, x1, hit);
}

fn environment(dir: vec3<f32>) -> vec3<f32> {
    if (uniforms_uint.environment_map_size.x > 1u && uniforms_uint.environment_map_size.y > 1u) {
        return env_map_sample(dir);
    }
    // If no environment map is present, use ambient color
    return uniforms_float.ambient;
}

fn vertexEta(material: Material, n_dot_v: f32) -> vec2<f32> {
    let is_entering: bool = n_dot_v < 0.0f;
    return vec2<f32>(select(1.0f, material.ior, is_entering), select(material.ior, 1.0f, is_entering));
}

fn safeDivide(a: vec3<f32>, b: vec3<f32>) -> vec3<f32> {
    return select(a / b, vec3<f32>(0.0f), b == vec3<f32>(0.0f));
}

// Exact Smith masking of GGX, the visible normal density sampleGGXVNDF draws from
fn smithG1(alpha: f32, n_dot_x: f32) -> f32 {
    let alpha_sq: f32 = alpha * alpha;
    return 2.0f * n_dot_x / (n_dot_x + sqrt(alpha_sq + (1.0f - alpha_sq) * n_dot_x * n_dot_x));
}

// BSDF times cosine and solid angle density of sampleBSDF choosing lobe and producing out_dir.
// Both are the ones sampleBSDF's throughput implies, delta lobes have no density and evaluate to zero.
fn evalLobe(in_dir: vec3<f32>, out_dir: vec3<f32>, n: vec3<f32>, material: Material, eta_i: f32, eta_o: f32, lobe: u32, random_state: u32) -> Lobe {
    let none: Lobe = Lobe(vec3<f32>(0.0f), 0.0f);
    let v: vec3<f32> = - in_dir;
    let n_i: vec3<f32> = n * sign(dot(n, v));
    let n_i_dot_v: f32 = abs(dot(n, v));
    let alpha: f32 = material.roughness * material.roughness;
    var h: vec3<f32> = normalize(v + out_dir);
    if (lobe == LOBE_DIFFUSE) {
        // The visible normal only steers the lobe choice of diffuse samples
        let random_h_1: Random = pcg(random_state);
        let random_h_2: Random = pcg(random_h_1.state);
        h = tangentToWorld(sampleGGXVNDF(worldToTangent(v, n_i).xzy, alpha, random_h_1.value, random_h_2.value).xzy, n_i);
    } else if (lobe == LOBE_REFRACT) {
        // Refraction without index change passes straight through
        if (eta_i == eta_o) {
            return none;
        }
        let h_t: vec3<f32> = - (eta_i * v + eta_o * out_dir);
        h = normalize(h_t) * sign(dot(h_t, n_i));
    }
    let v_dot_h: f32 = dot(v, h);
    let l_dot_h: f32 = dot(out_dir, h);
    let n_dot_l: f32 = dot(n_i, out_dir);
    let n_dot_h: f32 = dot(n_i, h);
    let F: vec3<f32> = mix(vec3<f32>(fresnel(abs(v_dot_h), eta_i, eta_o)), material.albedo, material.metallic);
    let F_greyscale: f32 = rgb_to_greyscale(F);
    let eta: f32 = eta_i / eta_o;
    let refractable: f32 = select(0.0f, 1.0f, 1.0f - eta * eta * (1.0f - v_dot_h * v_dot_h) >= 0.0f);
    let diffuse_weight: f32 = (1.0f - material.transmission) * (1.0f - material.metallic);
    // Lobe probabilities as sampleBSDF uses them and the chance its random number lands in each lobe
    let components: vec3<f32> = max(vec3<f32>(diffuse_weight * (1.0f - F_greyscale), material.transmission * (1.0f - F_greyscale) * refractable, F_greyscale), vec3<f32>(0.0f));
    let p: vec3<f32> = components / max(components.x + components.y + components.z, BIAS);
    let cdf: vec2<f32> = min(vec2<f32>(p.x, p.x + p.y), vec2<f32>(1.0f));
    let chance: vec3<f32> = vec3<f32>(cdf.x, cdf.y - cdf.x, 1.0f - cdf.y);
    if (chance[lobe] <= 0.0f || p[lobe] <= 0.0f || n_i_dot_v <= 0.0f) {
        return none;
    }
    if (lobe == LOBE_DIFFUSE) {
        let pdf: f32 = chance.x * max(n_dot_l, 0.0f) * INV_PI;
        return Lobe(pdf * diffuse_weight * material.albedo / p.x, pdf);
    }
    if (alpha == 0.0f || v_dot_h <= 0.0f || n_dot_h <= 0.0f) {
        return none;
    }
    // Visible normal density of the unclamped GGX distribution
    let d_term: f32 = n_dot_h * n_dot_h * (alpha * alpha - 1.0f) + 1.0f;
    let pdf_h: f32 = smithG1(alpha, n_i_dot_v) * v_dot_h * alpha * alpha / (PI * d_term * d_term * n_i_dot_v);
    if (lobe == LOBE_REFRACT) {
        if (l_dot_h >= 0.0f) {
            return none;
        }
        let denom: f32 = eta_i * v_dot_h + eta_o * l_dot_h;
        let pdf: f32 = chance.y * pdf_h * eta_o * eta_o * abs(l_dot_h) / (denom * denom);
        return Lobe(vec3<f32>(pdf * material.transmission * G1(alpha, max(- n_dot_l, 0.0f)) * (1.0f - F_greyscale) / p.y), pdf);
    }
    let pdf: f32 = chance.z * pdf_h / (4.0f * v_dot_h);
    return Lobe(pdf * G1(alpha, max(n_dot_l, 0.0f)) * mix(F, vec3<f32>(F_greyscale), material.transmission) / p.z, pdf);
}

// Weighted reservoir sampling step, weight is the vector-valued resampling weight (Sec. 6.3)
fn offer(sel: ptr<function, Selection>, candidate: Reservoir, weight: vec3<f32>) {
    let w: f32 = rgb_to_greyscale(weight);
    // Also rejects NaN and infinite weights of degenerate samples
    if (!(w > 0.0f && w < 3.0e38f)) {
        return;
    }
    (*sel).w_sum += w;
    (*sel).color += weight;
    let random_value: Random = pcg((*sel).random_state);
    (*sel).random_state = random_value.state;
    if (random_value.value * (*sel).w_sum <= w) {
        (*sel).r = candidate;
    }
}

// Resample a shifted sample with MIS weight mis, keeping its Jacobian for later shifts
fn offerShifted(sel: ptr<function, Selection>, r: Reservoir, shifted: Shift, mis: f32) {
    var candidate: Reservoir = r;
    candidate.f = shifted.f / shifted.jac;
    candidate.jac = r.jac * shifted.jac;
    offer(sel, candidate, mis * shifted.f * r.w);
}

fn finalize(sel: Selection, c: f32) -> Reservoir {
    var r: Reservoir = sel.r;
    let p_hat: f32 = rgb_to_greyscale(r.f);
    r.w = select(0.0f, sel.w_sum / p_hat, p_hat > 0.0f);
    r.c = c;
    return r;
}

fn withEnd(r: Reservoir, end_type: u32, end: u32, f: vec3<f32>) -> Reservoir {
    var candidate: Reservoir = r;
    candidate.path = insertBits(insertBits(r.path, end, PATH_END, 5u), end_type, PATH_TYPE, 3u);
    candidate.f = f;
    return candidate;
}

// Whether the path tracer considers dir to point towards the incorrect side of the surface
fn wrongSide(is_inside: bool, refracted: bool, dir: vec3<f32>, geometry_n: vec3<f32>) -> bool {
    return (is_inside == refracted) != (dot(dir, geometry_n) > 0.0f);
}

// Walk a path from dom like lightTrace. Generating, every path of the tree is resampled into sel with its reconnection
// vertex (Sec. 6.1), Russian roulette only modifies their source density (Sec. 6.2.4). Replaying, the hybrid shift maps r into
// dom (Sec. 2.3): random replay up to x_k-1 and reconnection to x_k. It returns the shifted integrand times the Jacobian
// determinant of Eq. 2, zero if the path is not in the image of the shift.
fn walk(dom: Domain, r: Reservoir, replay: bool, scale: f32, sel: ptr<function, Selection>) -> Shift {
    let fail: Shift = Shift(vec3<f32>(0.0f), 0.0f);
    let end: u32 = extractBits(r.path, PATH_END, 5u);
    let k: u32 = extractBits(r.path, PATH_K, 5u);
    let rc: u32 = extractBits(r.path, PATH_RC, 2u);
    let end_type: u32 = extractBits(r.path, PATH_TYPE, 3u);
    // Point lights and the environment are only reached after a further bounce
    if (replay && end + select(0u, 1u, end_type >= END_POINT) > uniforms_uint.max_bounces) {
        return fail;
    }
    // Replaying stops sampling at x_k-1 for reconnections and at the path end otherwise
    let stop: u32 = select(k - 1u, end + select(0u, 1u, end_type == END_ENV), rc == RC_NONE);
    let rc_hit: Hit = Hit(bitcast<vec2<f32>>(r.rc.zw), r.rc.x, r.rc.y, 0u, 0.0f);
    var ray: Ray = Ray(dom.x1, normalize(dom.x1 - dom.x0));
    var hit: Hit = dom.hit;
    var throughput: vec3<f32> = vec3<f32>(1.0f);
    // Replaying the densities of the reconnection, generating the product of Russian roulette survival probabilities
    var density: f32 = 1.0f;
    var is_inside: bool = false;
    var direct_light_emission: bool = true;
    let light_offset_dir: vec3<f32> = random_sphere(stream(r.seed, STREAM_SPHERE)).value;
    var threshold: f32 = 0.0f;
    var reconnection: vec3<f32>;
    var prev: Vertex;
    // Template for generated paths reconnecting at the first vertex meeting both footprint criteria
    var chain: Reservoir;
    chain.seed = r.seed;
    var chain_throughput: vec3<f32> = vec3<f32>(0.0f);
    for (var b: u32 = 0u; ; b++) {
        let point_light_lighting: bool = hit.is_point_light == 1u && direct_light_emission;
        // Loop scoped variables are initialized explicitly, some compilers keep the previous iteration's value otherwise
        var surface: Surface = Surface();
        var scatter: bool = false;
        var geometry_density: f32 = 0.0f;
        if (!point_light_lighting) {
            surface = surfaceAt(hit, ray.origin, stream(r.seed, b));
            if (is_inside) {
                throughput *= beerLambert(hit.distance, hit.instance_index);
            }
            scatter = !surface.skip;
            geometry_density = abs(dot(surface.geometry_n, ray.unit_direction)) / (hit.distance * hit.distance);
            if (b == 0u) {
                // Primary ray footprint (Eq. 5)
                threshold = RESTIR_FOOTPRINT / geometry_density;
            }
        }
        // Ray footprint criterion for reconnecting from the previous vertex to this one (Eq. 5)
        let footprint: bool = scatter && prev.rough && prev.pdf * geometry_density * threshold <= 1.0f;
        let material: Material = surface.material;
        let n_dot_v: f32 = dot(surface.smooth_n, - ray.unit_direction);
        let eta: vec2<f32> = vertexEta(material, n_dot_v);
        let nee: bool = scatter && neeDecision(material, n_dot_v, eta.x, eta.y);
        let emission: vec3<f32> = material.emissive * max(sign(dot(- ray.unit_direction, surface.smooth_n)), 0.0f);
        let chain_found: bool = extractBits(chain.path, PATH_RC, 2u) == RC_SURFACE;
        // Reconnection at this vertex for paths ending here
        var here: Reservoir = chain;
        here.path = insertBits(insertBits(insertBits(insertBits(0u, b, PATH_K, 5u), RC_SURFACE, PATH_RC, 2u), prev.lobe, PATH_LOBE_PREV, 2u), select(0u, 1u, prev.inside), PATH_INSIDE, 1u);
        here.jac = prev.pdf * geometry_density;
        here.rc = vec4<u32>(hit.instance_index, hit.triangle_index, bitcast<vec2<u32>>(hit.uv));
        let arrived: bool = replay && rc == RC_SURFACE && b == k;
        if (arrived) {
            // The stored path takes over at the reconnection vertex
            if (hit.instance_index != rc_hit.instance_index || hit.triangle_index != rc_hit.triangle_index || !footprint) {
                return fail;
            }
            throughput *= geometry_density;
            density *= geometry_density;
            if (k == end && end_type == END_EMIT) {
                if (!direct_light_emission) {
                    return fail;
                }
                return Shift(throughput * emission / r.jac, density / r.jac);
            }
            if (k == end && end_type == END_NEE) {
                if (!nee) {
                    return fail;
                }
                return Shift(throughput * BSDF(ray.unit_direction, r.dir, surface.smooth_n, surface.geometry_n, material, eta.x, eta.y, vec2<f32>(0.0f)) * r.radiance / r.jac, density / r.jac);
            }
            if (k == end && end_type == END_SKY) {
                if (!nee) {
                    return fail;
                }
                return Shift(throughput * skyBSDF(ray.unit_direction, r.dir, surface, eta, is_inside, environmentPdf(r.dir), surface.random_state) * r.radiance / r.jac, density / r.jac);
            }
            if (nee != (extractBits(r.path, PATH_NEE, 1u) == 1u)) {
                return fail;
            }
        } else if (replay && b == stop && (!scatter || (rc != RC_SURFACE && rc != RC_ENV))) {
            if (rc == RC_LIGHT && nee && !footprint && end_type == END_SKY) {
                // Forced reconnection to the environment direction, drawn independently of the vertex (unit Jacobian)
                let sky: SkySample = sampleSky(ray, surface, eta, is_inside, stream(r.seed, b + STREAM_SKY), surface.random_state);
                return Shift(throughput * sky.color, 1.0f);
            }
            if (rc == RC_LIGHT && nee && !footprint) {
                // Forced reconnection to the light vertex of next event estimation (Sec. 6.2.3)
                let light: LightSample = sampleLight(lights[r.rc.x + 1u], r.rc.y, ray.origin, light_offset_dir);
                if (occluded(ray.origin, surface.smooth_n, surface.geometry_offset, light.dir + light.offset)) {
                    return fail;
                }
                return Shift(throughput * BSDF(ray.unit_direction, light.dir / length(light.dir), surface.smooth_n, surface.geometry_n, material, eta.x, eta.y, vec2<f32>(0.0f)) * light.brightness / light.inv_pdf, 1.0f);
            }
            if (rc == RC_NONE && end_type == END_POINT && point_light_lighting) {
                return Shift(throughput * calculatePointLightContrib(hit.instance_index), 1.0f);
            }
            // Emission seen right after a vertex that skipped next event estimation
            if (rc == RC_NONE && end_type == END_EMIT && scatter && direct_light_emission && !footprint) {
                return Shift(throughput * emission, 1.0f);
            }
            return fail;
        } else if (!replay && scatter) {
            // Emission seen directly carries no randomness to resample, shading adds it
            if (direct_light_emission && b > 0u) {
                var candidate: Reservoir = chain;
                if (chain_found) {
                    candidate.radiance = safeDivide(throughput * emission, chain_throughput);
                } else if (footprint) {
                    candidate = here;
                }
                offer(sel, withEnd(candidate, END_EMIT, b, throughput * emission), throughput * emission * scale / density);
            }
            if (nee) {
                let light: NEESample = reservoirSample(material, eta.x, eta.y, ray, stream(r.seed, b + STREAM_NEE), surface.smooth_n, surface.geometry_n, surface.geometry_offset, light_offset_dir, vec2<f32>(0.0f));
                // The light vertex is parameterized by area, light selection only enters its contribution weight
                let f: vec3<f32> = throughput * light.color / light.inv_pdf;
                var candidate: Reservoir = chain;
                if (chain_found) {
                    candidate.radiance = safeDivide(f, chain_throughput);
                } else if (footprint) {
                    candidate = here;
                    candidate.path = insertBits(candidate.path, 1u, PATH_NEE, 1u);
                    candidate.dir = light.dir;
                    candidate.radiance = light.radiance;
                } else {
                    // Forced reconnection to the light vertex (Sec. 6.2.3)
                    candidate.path = insertBits(insertBits(0u, b + 1u, PATH_K, 5u), RC_LIGHT, PATH_RC, 2u);
                    candidate.rc = vec4<u32>(light.light, light.light_state, 0u, 0u);
                }
                offer(sel, withEnd(candidate, END_NEE, b, f), throughput * light.color * scale / density);
            }
            if (nee && environmentMapped() && b < uniforms_uint.max_bounces) {
                let sky: SkySample = sampleSky(ray, surface, eta, is_inside, stream(r.seed, b + STREAM_SKY), surface.random_state);
                let f: vec3<f32> = throughput * sky.color;
                var candidate: Reservoir = chain;
                if (chain_found) {
                    candidate.radiance = safeDivide(f, chain_throughput);
                } else if (footprint) {
                    candidate = here;
                    candidate.path = insertBits(candidate.path, 1u, PATH_NEE, 1u);
                    candidate.dir = sky.dir;
                    candidate.radiance = sky.radiance;
                } else {
                    // Forced reconnection to the environment direction
                    candidate.path = insertBits(insertBits(0u, b + 1u, PATH_K, 5u), RC_LIGHT, PATH_RC, 2u);
                }
                offer(sel, withEnd(candidate, END_SKY, b, f), f * scale / density);
            }
        }
        if (scatter) {
            direct_light_emission = !nee;
            // Replaying, x_k-1 connects to the reconnection vertex and x_k leaves along the stored direction with the stored lobes
            let connect: bool = replay && b == stop;
            var lobe_index: u32 = select(extractBits(r.path, PATH_LOBE_PREV, 2u), extractBits(r.path, PATH_LOBE, 2u), arrived);
            var dir: vec3<f32> = r.dir;
            var refracted: bool = lobe_index == LOBE_REFRACT;
            var sample_throughput: vec3<f32> = vec3<f32>(0.0f);
            var fallback: bool = false;
            // Density of the direction leaving this vertex, unknown after the fallback
            var lobe: Lobe = Lobe(vec3<f32>(0.0f), 0.0f);
            if (connect) {
                if (is_inside != (extractBits(r.path, PATH_INSIDE, 1u) == 1u)) {
                    return fail;
                }
                if (rc == RC_SURFACE) {
                    reconnection = hitPosition(rc_hit);
                    dir = normalize(reconnection - (ray.origin + surface.geometry_offset * select(surface.smooth_n, - surface.smooth_n, is_inside != refracted)));
                }
                // The path tracer would resample such a direction against the geometry normal
                if (wrongSide(is_inside, refracted, dir, surface.geometry_n)) {
                    return fail;
                }
            } else if (!arrived) {
                var bsdf_sampled: SampleBSDF = sampleBSDF(ray.unit_direction, surface.smooth_n, material, eta.x, eta.y, surface.random_state, vec2<f32>(0.0f));
                // Continue sampling with geometry normal if ray points to incorrect side of the surface
                fallback = wrongSide(is_inside, bsdf_sampled.refracted, bsdf_sampled.unit_direction, surface.geometry_n);
                if (fallback) {
                    let geometry_bsdf_sampled: SampleBSDF = sampleBSDF(bsdf_sampled.unit_direction, surface.geometry_n, material, eta.x, eta.y, bsdf_sampled.random_state, vec2<f32>(0.0f));
                    bsdf_sampled.unit_direction = geometry_bsdf_sampled.unit_direction;
                    bsdf_sampled.refracted = geometry_bsdf_sampled.refracted;
                    bsdf_sampled.throughput = geometry_bsdf_sampled.throughput;
                }
                lobe_index = bsdf_sampled.lobe;
                dir = bsdf_sampled.unit_direction;
                refracted = bsdf_sampled.refracted;
                sample_throughput = bsdf_sampled.throughput;
                lobe.pdf = select(bsdf_sampled.pdf, 0.0f, fallback);
            }
            // Connections evaluate the given direction
            if (connect || arrived) {
                lobe = evalLobe(ray.unit_direction, dir, surface.smooth_n, material, eta.x, eta.y, lobe_index, surface.random_state);
            }
            // Inverse ray footprint criterion for the density of the direction leaving this vertex (Eq. 5)
            let inverse_footprint: bool = lobe.pdf > 0.0f && (lobe_index == LOBE_DIFFUSE || lobe.pdf * prev.cos / (hit.distance * hit.distance) * threshold <= 1.0f);
            let rough: bool = lobe.pdf > 0.0f && (lobe_index == LOBE_DIFFUSE || material.roughness >= RESTIR_ROUGHNESS);
            if (arrived) {
                if (!inverse_footprint) {
                    return fail;
                }
                // An escape right after x_k is weighted against next event estimation with its new incoming direction
                let weight: f32 = select(1.0f, escapeWeight(select(0.0f, lobe.pdf, nee), r.dir), k == end && end_type == END_ENV);
                return Shift(throughput * lobe.f_cos * r.radiance * weight / r.jac, density * lobe.pdf / r.jac);
            }
            // A replayed path meeting the criteria before x_k is not in the image of the shift
            if ((replay && footprint && inverse_footprint) || (connect && !rough)) {
                return fail;
            }
            if (connect) {
                throughput *= lobe.f_cos;
                density = lobe.pdf;
            } else {
                throughput *= max(sample_throughput, vec3<f32>(0.0f));
            }
            if (!replay && !chain_found && footprint && inverse_footprint) {
                chain = here;
                chain.path = insertBits(insertBits(chain.path, lobe_index, PATH_LOBE, 2u), select(0u, 1u, nee), PATH_NEE, 1u);
                chain.jac *= lobe.pdf;
                chain.dir = dir;
                chain_throughput = throughput;
            }
            prev = Vertex(rough, lobe_index, lobe.pdf, abs(dot(surface.geometry_n, dir)), is_inside);
            if (refracted) {
                is_inside = !is_inside;
            }
            ray.unit_direction = dir;
            ray.origin += surface.geometry_offset * select(surface.smooth_n, - surface.smooth_n, is_inside);
        } else {
            prev.rough = false;
            // Environment next event estimation never passes texels, escapes through them take the full weight
            prev.pdf = 0.0f;
        }
        if (!replay) {
            var survival_probability: f32 = 1.0f;
            if (point_light_lighting || scatter) {
                let importancy_factor: vec3<f32> = throughput / density;
                survival_probability = clamp(max(importancy_factor.x, max(importancy_factor.y, importancy_factor.z)), 0.0f, 1.0f);
            }
            if (survival_probability < pcg(stream(r.seed, b + STREAM_RR)).value || b >= uniforms_uint.max_bounces) {
                break;
            }
            density *= survival_probability;
            if (point_light_lighting) {
                let f: vec3<f32> = throughput * calculatePointLightContrib(hit.instance_index);
                var candidate: Reservoir = chain;
                if (extractBits(chain.path, PATH_RC, 2u) == RC_SURFACE) {
                    candidate.radiance = safeDivide(f, chain_throughput);
                }
                offer(sel, withEnd(candidate, END_POINT, b, f), f * scale / density);
            }
        }
        // Only occluders in front of the reconnection vertex matter
        hit = traverseInstanceBVH(ray, direct_light_emission, select(POW32, distance(reconnection, ray.origin) * 1.001f, replay && b == stop && rc == RC_SURFACE));
        // Reaching the reconnection vertex, it is shaded exactly where the stored path has it
        if (replay && b == stop && rc == RC_SURFACE && hit.instance_index == rc_hit.instance_index && hit.triangle_index == rc_hit.triangle_index) {
            hit.uv = rc_hit.uv;
            hit.distance = distance(reconnection, ray.origin);
        }
        // The connection to the environment direction has to escape the scene
        if (replay && b == stop && rc == RC_ENV && hit.instance_index != UINT_MAX) {
            return fail;
        }
        if (hit.instance_index == UINT_MAX) {
            // BSDF sampled escapes share the environment with its next event estimation
            let weight: f32 = escapeWeight(select(0.0f, prev.pdf, !direct_light_emission), ray.unit_direction);
            let f: vec3<f32> = throughput * environment(ray.unit_direction);
            if (replay) {
                if (b == stop && rc == RC_ENV) {
                    return Shift(f * weight / r.jac, density / r.jac);
                }
                if (rc == RC_NONE && end_type == END_ENV && b == end && !prev.rough) {
                    return Shift(f * weight, 1.0f);
                }
                return fail;
            }
            var candidate: Reservoir = chain;
            if (extractBits(chain.path, PATH_RC, 2u) == RC_SURFACE) {
                // Escaping right after x_k, the shift evaluates the weight with the new incoming direction
                candidate.radiance = safeDivide(f * select(weight, 1.0f, extractBits(chain.path, PATH_K, 5u) == b), chain_throughput);
            } else if (prev.rough) {
                // Reconnection to the environment direction, guarded by the roughness threshold only (Sec. 4.2)
                candidate.path = insertBits(insertBits(insertBits(insertBits(0u, b + 1u, PATH_K, 5u), RC_ENV, PATH_RC, 2u), prev.lobe, PATH_LOBE_PREV, 2u), select(0u, 1u, prev.inside), PATH_INSIDE, 1u);
                candidate.jac = prev.pdf;
                candidate.dir = ray.unit_direction;
            }
            offer(sel, withEnd(candidate, END_ENV, b, f * weight), f * weight * scale / density);
            break;
        }
        // Project ray origin to hit point
        ray.origin += hit.distance * ray.unit_direction;
    }
    return fail;
}

fn project(view: mat3x3<f32>, camera: vec3<f32>, position: vec3<f32>) -> vec2<f32> {
    let clip_space: vec3<f32> = view * (position - camera);
    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5f + 0.5f;
    return vec2<f32>(screen_space.x, 1.0f - screen_space.y) * vec2<f32>(uniforms_uint.render_size);
}

fn previousValid(q: vec2<i32>) -> bool {
    return all(q >= vec2<i32>(0)) && all(q < vec2<i32>(uniforms_uint.render_size)) && bitcast<f32>(textureLoad(reservoir_prev, q, 0, 0).w) > 0.0f;
}

// Backprojection of the camera motion, or the dual motion vector of the surface previously seen there (Sec. 6.4)
fn temporalNeighbor(p: vec2<i32>, dom: Domain) -> vec2<i32> {
    // Primary hits are rasterized at pixel centers
    let q: vec2<i32> = vec2<i32>(floor(project(uniforms_float.prev_view_matrix, uniforms_float.prev_camera_position, dom.x1)));
    if (!previousValid(q)) {
        return vec2<i32>(-1);
    }
    let previous: Domain = previousDomain(q);
    if (previous.hit.instance_index == dom.hit.instance_index && distance(previous.x1, dom.x1) <= dom.hit.distance * 8.0f / f32(uniforms_uint.render_size.x)) {
        return q;
    }
    let dual: vec2<i32> = vec2<i32>(floor(vec2<f32>(p + q) + 1.0f - project(uniforms_float.view_matrix, uniforms_float.camera_position, previous.x1)));
    return select(vec2<i32>(-1), dual, previousValid(dual));
}

// Partner of p in reuse texture t, randomly flipped, transposed and offset every frame (Sec. 3.2)
fn partner(p: vec2<i32>, t: u32) -> vec2<i32> {
    var sizes: array<i32, 3> = array<i32, 3>(254, 230, 210);
    let size: i32 = sizes[t];
    let random: u32 = hash(uniforms_uint.frame * 3u + t);
    let flip: vec2<i32> = select(vec2<i32>(1), vec2<i32>(-1), vec2<bool>((random & 1u) != 0u, (random & 2u) != 0u));
    let transpose: bool = (random & 4u) != 0u;
    let offset: vec2<i32> = vec2<i32>(i32((random >> 8u) & 255u), i32((random >> 16u) & 255u));
    let texel: vec2<i32> = ((select(p, p.yx, transpose) * flip + offset) % size + size) % size;
    let delta: vec2<i32> = textureLoad(pairing, texel, t, 0).xy * flip;
    return p + select(delta, delta.yx, transpose);
}

fn shift(dom: Domain, r: Reservoir) -> Shift {
    var sel: Selection;
    if (r.w <= 0.0f) {
        return Shift(vec3<f32>(0.0f), 0.0f);
    }
    return walk(dom, r, true, 0.0f, &sel);
}

// Initial candidates
@compute
@workgroup_size(8, 8)
fn restir_initial(@builtin(global_invocation_id) global_invocation_id: vec3<u32>) {
    let p: vec2<i32> = vec2<i32>(global_invocation_id.xy);
    var dom: Domain;
    if (!currentDomain(p, &dom)) {
        storeReservoir(reservoir_initial_out, p, Reservoir(), dom.hit);
        return;
    }
    let pixel_seed: u32 = stream(hash(uniforms_uint.frame), global_invocation_id.x + uniforms_uint.render_size.x * global_invocation_id.y);
    var initial: Selection;
    initial.random_state = stream(pixel_seed, STREAM_SELECT);
    for (var i: u32 = 0u; i < uniforms_uint.samples; i++) {
        var r: Reservoir;
        r.seed = stream(pixel_seed, i);
        walk(dom, r, false, 1.0f / f32(uniforms_uint.samples), &initial);
    }
    storeReservoir(reservoir_initial_out, p, finalize(initial, 1.0f), dom.hit);
}

// Temporal reuse with the shifts of the temporal round
@compute
@workgroup_size(8, 8)
fn restir_temporal(@builtin(global_invocation_id) global_invocation_id: vec3<u32>) {
    let p: vec2<i32> = vec2<i32>(global_invocation_id.xy);
    var dom: Domain;
    if (!currentDomain(p, &dom)) {
        storeReservoir(reservoir_temp_out, p, Reservoir(), dom.hit);
        return;
    }
    var r: Reservoir = loadReservoir(reservoir_initial, p);
    let q: vec2<i32> = temporalNeighbor(p, dom);
    if (q.x >= 0) {
        let temporal: Reservoir = loadReservoir(reservoir_prev, q);
        // Optionally lower the confidence cap where the previous frame duplicated samples (Sec. 5), this biases the estimate
        let duplicated: f32 = select(0.0f, bitcast<f32>(textureLoad(duplication, q, 0, 0).x), uniforms_uint.restir_decorrelation == 1u);
        let cap: f32 = mix(RESTIR_CAP, RESTIR_CAP_MIN, pow(duplicated, RESTIR_DUPLICATION_ALPHA));
        let c_t: f32 = min(temporal.c, cap);
        let to_current: vec4<f32> = bitcast<vec4<f32>>(textureLoad(temporal_shifts, p, 0, 0));
        var to_previous: vec4<f32> = vec4<f32>(r.f, 1.0f);
        if (!sameDomain(previousDomain(q), dom)) {
            to_previous = bitcast<vec4<f32>>(textureLoad(temporal_shifts, p, 1, 0));
        }
        let p_c: f32 = rgb_to_greyscale(r.f);
        let p_t: f32 = rgb_to_greyscale(temporal.f);
        var sel: Selection;
        sel.random_state = stream(stream(hash(uniforms_uint.frame), global_invocation_id.x + uniforms_uint.render_size.x * global_invocation_id.y), STREAM_SELECT + 1u);
        offerShifted(&sel, r, Shift(r.f, 1.0f), r.c * p_c / (r.c * p_c + c_t * rgb_to_greyscale(to_previous.xyz)));
        offerShifted(&sel, temporal, Shift(to_current.xyz, to_current.w), c_t * p_t / (c_t * p_t + r.c * rgb_to_greyscale(to_current.xyz)));
        r = finalize(sel, r.c + c_t);
    }
    storeReservoir(reservoir_temp_out, p, r, dom.hit);
}

// Shifting into an identical domain is the identity
fn sameDomain(a: Domain, b: Domain) -> bool {
    return all(a.x0 == b.x0) && a.hit.instance_index == b.hit.instance_index && a.hit.triangle_index == b.hit.triangle_index && all(a.hit.uv == b.hit.uv);
}

struct ShiftJob {
    dom: Domain,
    r: Reservoir,
}

// Temporal round job t of p: the previous frame's sample into the current domain (t = 0) or the current sample into the
// previous domain (t = 1). False if the shift is zero or the identity, which temporal reuse handles itself.
fn temporalJob(p: vec2<i32>, t: u32, job: ptr<function, ShiftJob>) -> bool {
    var dom: Domain;
    if (t > 1u || !storedDomain(reservoir_initial, p, &dom)) {
        return false;
    }
    let q: vec2<i32> = temporalNeighbor(p, dom);
    if (q.x < 0) {
        return false;
    }
    if (t == 0u) {
        *job = ShiftJob(dom, loadReservoir(reservoir_prev, q));
    } else {
        *job = ShiftJob(previousDomain(q), loadReservoir(reservoir_initial, p));
    }
    return (*job).r.w > 0.0f && (t == 0u || !sameDomain((*job).dom, dom));
}

// Spatial round job t of p: its sample into the domain of partner t
fn spatialJob(p: vec2<i32>, t: u32, job: ptr<function, ShiftJob>) -> bool {
    if (t > 2u || any(p >= vec2<i32>(uniforms_uint.render_size))) {
        return false;
    }
    (*job).r = loadReservoir(reservoir_temp, p);
    return (*job).r.w > 0.0f && storedDomain(reservoir_temp, partner(p, t), &(*job).dom);
}

// Compaction bin of shifting r: reconnection type, with environment next event estimation apart from light sampling, and replay depth
fn shiftBin(r: Reservoir) -> u32 {
    let rc: u32 = extractBits(r.path, PATH_RC, 2u);
    let kind: u32 = select(rc, 4u, rc == RC_LIGHT && extractBits(r.path, PATH_TYPE, 3u) == END_SKY);
    let depth: u32 = select(extractBits(r.path, PATH_K, 5u), extractBits(r.path, PATH_END, 5u) + 1u, rc == RC_NONE);
    return kind * SHIFT_DEPTHS + clamp(depth, 1u, SHIFT_DEPTHS) - 1u;
}

// Bins of the jobs of p, SHIFT_BINS for shifts without work
fn temporalBins(p: vec2<i32>) -> array<u32, 3> {
    var bins: array<u32, 3> = array<u32, 3>(SHIFT_BINS, SHIFT_BINS, SHIFT_BINS);
    for (var t: u32 = 0u; t < 2u; t++) {
        var job: ShiftJob;
        if (temporalJob(p, t, &job)) {
            bins[t] = shiftBin(job.r);
        }
    }
    return bins;
}

fn spatialBins(p: vec2<i32>) -> array<u32, 3> {
    var bins: array<u32, 3> = array<u32, 3>(SHIFT_BINS, SHIFT_BINS, SHIFT_BINS);
    for (var t: u32 = 0u; t < uniforms_uint.restir_neighbours; t++) {
        var job: ShiftJob;
        if (spatialJob(p, t, &job)) {
            bins[t] = shiftBin(job.r);
        }
    }
    return bins;
}

var<workgroup> bin_jobs: array<atomic<u32>, SHIFT_BINS>;
var<workgroup> bin_offsets: array<u32, SHIFT_BINS>;

// Count the jobs of the workgroup per bin
fn countShifts(bins: array<u32, 3>, local_invocation_index: u32) {
    for (var t: u32 = 0u; t < 3u; t++) {
        if (bins[t] < SHIFT_BINS) {
            atomicAdd(&bin_jobs[bins[t]], 1u);
        }
    }
    workgroupBarrier();
    if (local_invocation_index < SHIFT_BINS) {
        let jobs: u32 = atomicLoad(&bin_jobs[local_invocation_index]);
        if (jobs > 0u) {
            atomicAdd(&shift_queue.counts[local_invocation_index], jobs);
        }
    }
}

// Write the jobs of the workgroup bin by bin into the queue and the size of the indirect dispatch running them
fn queueShifts(p: vec2<i32>, bins: array<u32, 3>, global_invocation_id: vec3<u32>, local_invocation_index: u32) {
    var slots: array<u32, 3>;
    for (var t: u32 = 0u; t < 3u; t++) {
        if (bins[t] < SHIFT_BINS) {
            slots[t] = atomicAdd(&bin_jobs[bins[t]], 1u);
        }
    }
    workgroupBarrier();
    if (local_invocation_index < SHIFT_BINS) {
        let jobs: u32 = atomicLoad(&bin_jobs[local_invocation_index]);
        if (jobs > 0u) {
            var start: u32 = 0u;
            for (var bin: u32 = 0u; bin < local_invocation_index; bin++) {
                start += atomicLoad(&shift_queue.counts[bin]);
            }
            bin_offsets[local_invocation_index] = start + atomicAdd(&shift_queue.cursors[local_invocation_index], jobs);
        }
    }
    workgroupBarrier();
    for (var t: u32 = 0u; t < 3u; t++) {
        if (bins[t] < SHIFT_BINS) {
            shift_queue.jobs[bin_offsets[bins[t]] + slots[t]] = u32(p.x) | (u32(p.y) << 14u) | (t << 28u);
        }
    }
    if (all(global_invocation_id.xy == vec2<u32>(0u))) {
        var groups: u32 = 0u;
        for (var bin: u32 = 0u; bin < SHIFT_BINS; bin++) {
            groups += (atomicLoad(&shift_queue.counts[bin]) + 63u) / 64u;
        }
        shift_queue.dispatch = array<u32, 3>(min(groups, 65535u), (groups + 65534u) / 65535u, 1u);
    }
}

// Queued job of an invocation of the indirect shift passes, UINT_MAX for none. Every workgroup works on a single bin.
fn queuedShift(workgroup_id: vec3<u32>, local_invocation_index: u32) -> u32 {
    var group: u32 = workgroup_id.y * 65535u + workgroup_id.x;
    var start: u32 = 0u;
    for (var bin: u32 = 0u; bin < SHIFT_BINS; bin++) {
        let jobs: u32 = queued_shifts[3u + bin];
        let groups: u32 = (jobs + 63u) / 64u;
        if (group < groups) {
            let index: u32 = group * 64u + local_invocation_index;
            if (index < jobs) {
                return queued_shifts[3u + 2u * SHIFT_BINS + start + index];
            }
            return UINT_MAX;
        }
        group -= groups;
        start += jobs;
    }
    return UINT_MAX;
}

// The temporal round of the shift queue
@compute
@workgroup_size(8, 8)
fn restir_temporal_count(@builtin(global_invocation_id) global_invocation_id: vec3<u32>, @builtin(local_invocation_index) local_invocation_index: u32) {
    countShifts(temporalBins(vec2<i32>(global_invocation_id.xy)), local_invocation_index);
}

@compute
@workgroup_size(8, 8)
fn restir_temporal_prepass(@builtin(global_invocation_id) global_invocation_id: vec3<u32>, @builtin(local_invocation_index) local_invocation_index: u32) {
    let p: vec2<i32> = vec2<i32>(global_invocation_id.xy);
    let bins: array<u32, 3> = temporalBins(p);
    for (var t: u32 = 0u; t < 2u; t++) {
        if (bins[t] == SHIFT_BINS) {
            textureStore(temporal_shifts_out, p, t, vec4<u32>(0u));
        }
    }
    queueShifts(p, bins, global_invocation_id, local_invocation_index);
}

@compute
@workgroup_size(64)
fn restir_temporal_shift(@builtin(workgroup_id) workgroup_id: vec3<u32>, @builtin(local_invocation_index) local_invocation_index: u32) {
    let job: u32 = queuedShift(workgroup_id, local_invocation_index);
    if (job != UINT_MAX) {
        let p: vec2<i32> = vec2<i32>(vec2<u32>(job, job >> 14u) & vec2<u32>(16383u));
        var shift_job: ShiftJob;
        _ = temporalJob(p, job >> 28u, &shift_job);
        let shifted: Shift = shift(shift_job.dom, shift_job.r);
        textureStore(temporal_shifts_out, p, job >> 28u, vec4<u32>(bitcast<vec3<u32>>(shifted.f), bitcast<u32>(shifted.jac)));
    }
}

// The spatial round of the shift queue, every pixel's sample to its partners of all reuse textures
@compute
@workgroup_size(8, 8)
fn restir_count(@builtin(global_invocation_id) global_invocation_id: vec3<u32>, @builtin(local_invocation_index) local_invocation_index: u32) {
    countShifts(spatialBins(vec2<i32>(global_invocation_id.xy)), local_invocation_index);
}

@compute
@workgroup_size(8, 8)
fn restir_prepass(@builtin(global_invocation_id) global_invocation_id: vec3<u32>, @builtin(local_invocation_index) local_invocation_index: u32) {
    let p: vec2<i32> = vec2<i32>(global_invocation_id.xy);
    let bins: array<u32, 3> = spatialBins(p);
    for (var t: u32 = 0u; t < 3u; t++) {
        if (bins[t] == SHIFT_BINS) {
            textureStore(shift_data_out, p, t, vec4<u32>(0u));
        }
    }
    queueShifts(p, bins, global_invocation_id, local_invocation_index);
}

@compute
@workgroup_size(64)
fn restir_shift(@builtin(workgroup_id) workgroup_id: vec3<u32>, @builtin(local_invocation_index) local_invocation_index: u32) {
    let job: u32 = queuedShift(workgroup_id, local_invocation_index);
    if (job != UINT_MAX) {
        let p: vec2<i32> = vec2<i32>(vec2<u32>(job, job >> 14u) & vec2<u32>(16383u));
        var shift_job: ShiftJob;
        _ = spatialJob(p, job >> 28u, &shift_job);
        let shifted: Shift = shift(shift_job.dom, shift_job.r);
        textureStore(shift_data_out, p, job >> 28u, vec4<u32>(bitcast<vec3<u32>>(shifted.f), bitcast<u32>(shifted.jac)));
    }
}

// Paired spatial reuse with pairwise MIS (Sec. 3) and shading with vector-valued weights (Sec. 6.3)
@compute
@workgroup_size(8, 8)
fn restir_spatial(@builtin(global_invocation_id) global_invocation_id: vec3<u32>) {
    let p: vec2<i32> = vec2<i32>(global_invocation_id.xy);
    var dom: Domain;
    if (!currentDomain(p, &dom)) {
        storeReservoir(reservoir_prev_out, p, Reservoir(), dom.hit);
        let screen_space: vec2<f32> = vec2<f32>(global_invocation_id.xy) / vec2<f32>(uniforms_uint.render_size.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        // If there is no triangle render ambient color
        textureStore(compute_out, p, 0, vec4<f32>(environment(normalize(uniforms_float.inv_view_matrix * vec3<f32>(screen_space, 1.0f))), 1.0f));
        if (uniforms_uint.is_temporal == 1u) {
            textureStore(compute_out, p, 1, vec4<f32>(0.0f));
        }
        return;
    }
    let r: Reservoir = loadReservoir(reservoir_temp, p);
    var count: f32 = 0.0f;
    var c_sum: f32 = r.c;
    for (var t: u32 = 0u; t < uniforms_uint.restir_neighbours; t++) {
        let q: vec2<i32> = partner(p, t);
        var neighbor: Domain;
        if (currentDomain(q, &neighbor)) {
            count += 1.0f;
            c_sum += bitcast<f32>(textureLoad(reservoir_temp, q, 0, 0).w);
        }
    }
    // Confidence of the current pixel is split evenly across the pairs
    let c_pair: f32 = r.c / max(count, 1.0f);
    let p_c: f32 = rgb_to_greyscale(r.f);
    var canonical_mis: f32 = select(0.0f, 1.0f, count == 0.0f);
    var sel: Selection;
    sel.random_state = stream(stream(hash(uniforms_uint.frame), global_invocation_id.x + uniforms_uint.render_size.x * global_invocation_id.y), STREAM_SELECT + 2u);
    for (var t: u32 = 0u; t < uniforms_uint.restir_neighbours; t++) {
        let q: vec2<i32> = partner(p, t);
        var neighbor_dom: Domain;
        if (currentDomain(q, &neighbor_dom)) {
            let neighbor: Reservoir = loadReservoir(reservoir_temp, q);
            let to_here: vec4<f32> = bitcast<vec4<f32>>(textureLoad(shift_data, q, t, 0));
            let to_there: vec4<f32> = bitcast<vec4<f32>>(textureLoad(shift_data, p, t, 0));
            let share: f32 = (neighbor.c + c_pair) / c_sum;
            let p_n: f32 = rgb_to_greyscale(neighbor.f);
            if (p_c > 0.0f) {
                canonical_mis += share * c_pair * p_c / (c_pair * p_c + neighbor.c * rgb_to_greyscale(to_there.xyz));
            }
            offerShifted(&sel, neighbor, Shift(to_here.xyz, to_here.w), share * neighbor.c * p_n / (neighbor.c * p_n + c_pair * rgb_to_greyscale(to_here.xyz)));
        }
    }
    offerShifted(&sel, r, Shift(r.f, 1.0f), canonical_mis);
    storeReservoir(reservoir_prev_out, p, finalize(sel, c_sum), dom.hit);
    textureStore(reservoir_prev_out, p, 5, vec4<u32>(bitcast<vec2<u32>>(dom.hit.uv), 0u, 0u));
    let primary: Surface = surfaceAt(dom.hit, dom.x1, sel.random_state);
    let emission: vec3<f32> = select(primary.material.emissive * max(sign(dot(normalize(dom.x0 - dom.x1), primary.smooth_n)), 0.0f), vec3<f32>(0.0f), primary.skip);
    // Clamp color to 16 bit float
    let final_color: vec3<f32> = clamp(sel.color + emission, vec3<f32>(0.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, p, 0, vec4<f32>(final_color, 1.0f));
    if (uniforms_uint.is_temporal == 1u) {
        textureStore(compute_out, p, 1, vec4<f32>(dom.x1, f32(dom.hit.instance_index)));
    }
}

var<workgroup> duplication_seeds: array<u32, 576>;

// Fraction of the 17 x 17 neighborhood sharing each pixel's sample (Sec. 5)
@compute
@workgroup_size(8, 8)
fn restir_duplicates(
    @builtin(global_invocation_id) global_invocation_id: vec3<u32>,
    @builtin(local_invocation_id) local_invocation_id: vec3<u32>,
    @builtin(local_invocation_index) local_invocation_index: u32
) {
    let corner: vec2<i32> = vec2<i32>(global_invocation_id.xy - local_invocation_id.xy) - 8;
    for (var i: u32 = local_invocation_index; i < 576u; i += 64u) {
        let q: vec2<i32> = corner + vec2<i32>(i32(i % 24u), i32(i / 24u));
        var seed: u32 = 0u;
        if (all(q >= vec2<i32>(0)) && all(q < vec2<i32>(uniforms_uint.render_size))) {
            let l0: vec4<u32> = textureLoad(reservoir_prev, q, 0, 0);
            seed = select(0u, l0.x, bitcast<f32>(l0.z) > 0.0f);
        }
        duplication_seeds[i] = seed;
    }
    workgroupBarrier();
    let own: u32 = duplication_seeds[(local_invocation_id.y + 8u) * 24u + local_invocation_id.x + 8u];
    var count: u32 = 0u;
    for (var y: u32 = 0u; y < 17u; y++) {
        for (var x: u32 = 0u; x < 17u; x++) {
            count += select(0u, 1u, duplication_seeds[(local_invocation_id.y + y) * 24u + local_invocation_id.x + x] == own);
        }
    }
    let score: f32 = select(0.0f, f32(count - 1u) / 288.0f, own != 0u);
    textureStore(duplication_out, vec2<i32>(global_invocation_id.xy), 0, vec4<u32>(bitcast<u32>(score), 0u, 0u, 0u));
}
