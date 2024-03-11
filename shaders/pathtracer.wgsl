const PI: f32 = 3.141592653589793;
const PHI: f32 = 1.61803398874989484820459;
const BIAS: f32 = 0.0000152587890625;
const INV_PI: f32 = 0.3183098861837907;
const INV_65535: f32 = 0.000015259021896696422;

struct Transform {
    rotation: mat3x3<f32>,
    shift: vec3f,
};

struct Light {
    position: vec3f,
    strength_variation: vec2f,
}

struct Uniforms {
    view_matrix: mat3x3<f32>,
    camera_position: vec3f,
    ambient: vec3f,
    random_seed: f32,
    texture_size: vec2f,
};

struct VertexOut {
    @builtin(position) pos: vec4f,
    @location(0) relative_position: vec3f,
    @location(1) absolute_position: vec3f,
    @location(2) uv: vec2f,
    @location(3) clip_space: vec3f,
    @location(4) @interpolate(flat) triangle_index: i32,
};

@group(0) @binding(0) var<storage, read> indices: array<i32>;
@group(0) @binding(1) var<storage, read> geometry: array<f32>;
@group(0) @binding(2) var<storage, read> scene: array<f32>;

@group(1) @binding(0) var<uniform> uniforms: Uniforms;
@group(1) @binding(1) var<storage, read> lights: array<Light>;
@group(1) @binding(2) var<storage, read> transforms: array<Transform>;


const base_uvs = array(
    vec2f(1, 0),
    vec2f(0, 1),
    vec2f(0, 0)
);

@vertex
fn vsMain(
    @builtin(vertex_index) vertex_index : u32,
    @builtin(instance_index) instance_index: u32
) -> VertexOut {
    var out: VertexOut;

    let vertex_num: i32 = i32(vertex_index % 3);
    out.triangle_index = indices[instance_index];
    let geometry_index: i32 = out.triangle_index * 12;
    let v_i: i32 = geometry_index + vertex_num * 3;
    // Transform position
    out.relative_position = vec3f(geometry[v_i], geometry[v_i + 1], geometry[v_i + 2]);
    // Get transformation ID
    let t_i: i32 = i32(geometry[geometry_index + 9]) << 1;

    // Trasform position
    let transform: Transform = transforms[t_i];
    out.absolute_position = (transform.rotation * out.relative_position) + transform.shift;
    // Set uv to vertex uv and let the vertex interpolation generate the values in between
    out.uv = base_uvs[vertex_num];

    out.clip_space = uniforms.view_matrix * (out.absolute_position - uniforms.camera_position);
    // Set triangle position in clip space
    out.pos = vec4f(out.clip_space.xy, 1.0f / (1.0f + exp(out.clip_space.z * INV_65535)), out.clip_space.z);
    return out;
}

// FRAGMENT SHADER ------------------------------------------------------------------------------------------------------------------------

//@group(2) @binding(0) var unfiltered: sampler;
@group(2) @binding(0) var texture_atlas: texture_2d<f32>;
@group(2) @binding(1) var pbr_atlas: texture_2d<f32>;
@group(2) @binding(2) var translucency_atlas: texture_2d<f32>;

struct Ray {
    origin: vec3f,
    unit_direction: vec3f,
};

struct Material {
    albedo: vec3f,
    rme: vec3f,
    tpo: vec3f
};

// Lookup values for texture atlases
fn fetchTexVal(atlas: texture_2d<f32>, uv: vec2f, tex_num: f32, default_val: vec3f) -> vec3f {
    // Return default value if no texture is set
    if (tex_num == - 1.0) {
        return default_val;
    }
    // Get dimensions of texture atlas
    let atlas_size: vec2f = vec2f(textureDimensions(atlas));
    let width: f32 = tex_num * uniforms.texture_size.x;
    let offset: vec2f = vec2f(
        width % atlas_size.x,
        atlas_size.y - floor(width / atlas_size.x) * uniforms.texture_size.y
    );
    // WebGPU quirk of having upsidedown height for textures
    let atlas_texel: vec2<i32> = vec2<i32>(offset + uv * uniforms.texture_size * vec2f(1, -1));
    // Fetch texel on requested coordinate
    let tex_val: vec3f = textureLoad(atlas, atlas_texel, 0).xyz;
    return tex_val;
}

fn noise(n: vec2f, seed: f32) -> vec4f {
    return fract(sin(dot(n.xy, vec2f(12.9898f, 78.233f)) + vec4f(53.0f, 59.0f, 61.0f, 67.0f) * (seed + uniforms.random_seed * PHI)) * 43758.5453f) * 2.0f - 1.0f;
}


// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
fn moellerTrumboreCull(t: mat3x3<f32>, ray: Ray, l: f32) -> bool {
    let edge1 = t[1] - t[0];
    let edge2 = t[2] - t[0];
    let pvec = cross(ray.unit_direction, edge2);
    let det = dot(edge1, pvec);
    let inv_det = 1.0f / det;
    if(det < BIAS) { 
        return false;
    }
    let tvec = ray.origin - t[0];
    let u: f32 = dot(tvec, pvec) * inv_det;
    if(u < BIAS || u > 1.0f) {
        return false;
    }
    let qvec: vec3f = cross(tvec, edge1);
    let v: f32 = dot(ray.unit_direction, qvec) * inv_det;
    if(v < BIAS || u + v > 1.0f) {
        return false;
    }
    let s: f32 = dot(edge2, qvec) * inv_det;
    return (s <= l && s > BIAS);
}

// Don't return intersection point, because we're looking for a specific triangle
fn rayCuboid(min_corner: vec3f, max_corner: vec3f, ray: Ray, l: f32) -> bool {
    let v0: vec3f = (min_corner - ray.origin) / ray.unit_direction;
    let v1: vec3f = (max_corner - ray.origin) / ray.unit_direction;
    let tmin: f32 = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));
    let tmax: f32 = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));
    return tmax >= max(tmin, BIAS) && tmin < l;
}

// Simplified rayTracer to only test if ray intersects anything
fn shadowTest(ray: Ray, l: f32) -> bool {
    // Cache transformed ray attributes
    var t_ray: Ray = Ray(ray.origin, ray.unit_direction);
    // Inverse of transformed normalized ray
    var cached_t_i: i32 = 0;
    // Precomput max length
    let min_len: f32 = l;
    // Get texture size as max iteration value
    let size: i32 = i32(arrayLength(&geometry)) / 12;
    // Iterate through lines of texture
    for (var i: i32 = 0; i < size; i++) {
        // Get position of current triangle/vertex in geometryTex
        let index: i32 = i * 12;
        // Fetch triangle coordinates from scene graph
        let a = vec3f(geometry[index    ], geometry[index + 1], geometry[index + 2]);
        let b = vec3f(geometry[index + 3], geometry[index + 4], geometry[index + 5]);
        let c = vec3f(geometry[index + 6], geometry[index + 7], geometry[index + 8]);

        let t_i: i32 = i32(geometry[index + 9]) << 1;
        // Test if cached transformed variables are still valid
        if (t_i != cached_t_i) {
            let i_i: i32 = t_i + 1;
            cached_t_i = t_i;
            let i_transform = transforms[i_i];
            t_ray = Ray(
                i_transform.rotation * (ray.origin + i_transform.shift),
                normalize(i_transform.rotation * ray.unit_direction)
            );
        }
        // Three cases:
        // indicator = 0        => end of list: stop loop
        // indicator = 1        => is bounding volume: do AABB intersection test
        // indicator = 2        => is triangle: do triangle intersection test
        switch i32(geometry[index + 10]) {
            case 0 {
                return false;
            }
            case 1: {
                if(!rayCuboid(a, b, t_ray, min_len)) {
                    i += i32(c.x);
                }
            }
            case 2: {
                let triangle: mat3x3<f32> = mat3x3<f32>(a, b, c);
                // Test for triangle intersection in positive light ray direction
                if(moellerTrumboreCull(triangle, t_ray, min_len)) {
                    return true;
                }
            }
            default: {
                continue;
            }
        }
    }
    // Tested all triangles, but there is no intersection
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

fn fresnel(f0: vec3f, theta: f32) -> vec3f {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - theta, 5.0f);
}


fn forwardTrace(material: Material, light_dir: vec3f, strength: f32, n: vec3f, v: vec3f) -> vec3f {
    let len_p1: f32 = 1.0f + length(light_dir);
    // Apply inverse square law
    let brightness: f32 = strength / (len_p1 * len_p1);

    let l: vec3f = normalize(light_dir);
    let h: vec3f = normalize(v + l);

    let v_dot_h: f32 = max(dot(v, h), 0.0f);
    let n_dot_l: f32 = max(dot(n, l), 0.0f);
    let n_dot_h: f32 = max(dot(n, h), 0.0f);
    let n_dot_v: f32 = max(dot(n, v), 0.0f);

    let alpha: f32 = material.rme.x * material.rme.x;
    let brdf: f32 = mix(1.0f, n_dot_v, material.rme.y);
    let f0: vec3f = material.albedo * brdf;

    let ks: vec3f = fresnel(f0, v_dot_h);
    let kd: vec3f = (1.0f - ks) * (1.0f - material.rme.y);
    let lambert: vec3f = material.albedo * INV_PI;

    let cook_torrance_numerator: vec3f = ks * trowbridgeReitz(alpha, n_dot_h) * smith(alpha, n_dot_v, n_dot_l);
    let cook_torrance_denominator: f32 = max(4.0f * n_dot_v * n_dot_l, BIAS);

    let cook_torrance: vec3f = cook_torrance_numerator / cook_torrance_denominator;
    let radiance: vec3f = kd * lambert + cook_torrance;

    // Outgoing light to camera
    return radiance * n_dot_l * brightness;
}

fn reservoirSample(material: Material, ray: Ray, random_vec: vec4f, rough_n: vec3f, smooth_n: vec3f, geometry_offset: f32, dont_filter: bool, i: i32) -> vec3f {
    var local_color: vec3f = vec3f(0.0f);
    var reservoir_length: f32 = 0.0f;
    var total_weight: f32 = 0.0f;
    var reservoir_num: i32 = 0;
    var reservoir_weight: f32 = 0.0f;
    var reservoir_light_pos: vec3f;
    var reservoir_light_dir: vec3f;
    var last_random: vec2f = noise(random_vec.zw, BIAS).xy;

    let size: i32 = i32(arrayLength(&lights));
    for (var j: i32 = 0; j < size; j++) {
        // Read light from storage buffer
        var light: Light = lights[j];
        // Skip if strength is negative or zero
        if (light.strength_variation.x <= 0.0f) {
            continue;
        }
        // Increment light weight
        reservoir_length += 1.0f;
        // Alter light source position according to variation.
        light.position += random_vec.xyz * light.strength_variation.y;
        let dir: vec3f = light.position - ray.origin;

        let color_for_light: vec3f = forwardTrace(material, dir, light.strength_variation.x, rough_n, - ray.unit_direction);

        local_color += color_for_light;
        let weight: f32 = length(color_for_light);

        total_weight += weight;
        if (abs(last_random.y) * total_weight <= weight) {
            reservoir_num = j;
            reservoir_weight = weight;
            reservoir_light_pos = light.position;
            reservoir_light_dir = dir;
        }
        // Update pseudo random variable.
        last_random = noise(last_random, BIAS).zw;
    }

    let unit_light_dir: vec3f = normalize(reservoir_light_dir);
    // Compute quick exit criterion to potentially skip expensive shadow test
    let show_color: bool = reservoir_length == 0.0f || reservoir_weight == 0.0f;
    let show_shadow: bool = dot(smooth_n, unit_light_dir) <= BIAS;
    // Apply emissive texture and ambient light
    let base_luminance: vec3f = vec3f(material.rme.z);
    // Update filter
    // if (dont_filter || i == 0) renderId.w = float((reservoirNum % 128) << 1) * INV_255;
    // Test if in shadow
    if (show_color) {
        return local_color + base_luminance;
    }

    if (show_shadow) {
        // if (dontFilter || i == 0) renderId.w += INV_255;
        return base_luminance;
    }
    // Apply geometry offset
    let offset_target: vec3f = ray.origin + geometry_offset * smooth_n;
    let light_ray: Ray = Ray(offset_target, unit_light_dir);

    if (shadowTest(light_ray, length(reservoir_light_dir))) {
        // if (dontFilter || i == 0) renderId.w += INV_255;
        return base_luminance;
    } else {
        return local_color + base_luminance;
    }
}

@fragment
fn fsMain(
    @location(1) absolute_position: vec3f,
    @location(2) uv: vec2f,
    @location(3) clip_space: vec3f,
    @location(4) @interpolate(flat) triangle_index: i32
) -> @location(0) vec4f {
    let scene_index: i32 = triangle_index * 28;
    let normal: vec3f = vec3f(scene[scene_index], scene[scene_index + 1], scene[scene_index + 2]);

    let uvw: vec3f = vec3f(uv, 1.0f - uv.x - uv.y);
    let barycentric = mat3x2<f32>(
        scene[scene_index + 9], scene[scene_index + 10], scene[scene_index + 11],
        scene[scene_index + 12], scene[scene_index + 13], scene[scene_index + 14]
    ) * uvw;

    let tex_num: vec3f = vec3f(scene[scene_index + 15], scene[scene_index + 16], scene[scene_index + 17]);

    let albedo_default: vec3f = vec3f(scene[scene_index + 18], scene[scene_index + 19], scene[scene_index + 20]);
    let rme_default: vec3f = vec3f(scene[scene_index + 21], scene[scene_index + 22], scene[scene_index + 23]);
    let tpo_default: vec3f = vec3f(scene[scene_index + 24], scene[scene_index + 25], scene[scene_index + 26]);

    let material: Material = Material (
        fetchTexVal(texture_atlas, barycentric, tex_num.x, albedo_default),
        fetchTexVal(pbr_atlas, barycentric, tex_num.y, rme_default),
        fetchTexVal(translucency_atlas, barycentric, tex_num.z, tpo_default),
    );


    var final_color: vec3f = uniforms.ambient;

    let camera_ray: Ray = Ray(absolute_position, normalize(absolute_position - uniforms.camera_position));

    let random_vec: vec4f = noise(clip_space.xy / clip_space.z, 1);
    // vec3 randomSpheareVec = normalize(smoothNormal + normalize(randomVec.xyz));
    final_color += reservoirSample(material, camera_ray, random_vec, normal, normal, 0.0f, false, 1);
    final_color *= material.albedo;

    return vec4f(final_color, 1.0f);

}