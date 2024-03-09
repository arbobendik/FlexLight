const INV_65535: f32 = 0.000015259021896696422;
const PI: f32 = 3.141592653589793;
const BIAS: f32 = 0.0000152587890625;

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
};

struct VertexOut {
    @builtin(position) pos: vec4f,
    @location(0) relative_position: vec3f,
    @location(1) absolute_position: vec3f,
    @location(2) clip_space: vec3f,
    @location(3) @interpolate(flat) triangle_index: i32,
};

@group(0) @binding(0) var<storage, read> indices: array<i32>;
@group(0) @binding(1) var<storage, read> geometry: array<f32>;
@group(0) @binding(2) var<storage, read> scene: array<f32>;

@group(1) @binding(0) var<uniform> uniforms: Uniforms;
@group(1) @binding(1) var<storage, read> lights: array<Light>;
@group(1) @binding(2) var<storage, read> transforms: array<Transform>;

@vertex
fn vsMain(
    @builtin(vertex_index) vertex_index : u32,
    @builtin(instance_index) instance_index: u32
) -> VertexOut {
    var out: VertexOut;

    out.triangle_index = indices[instance_index];
    let geometry_index: i32 = out.triangle_index * 12;
    let v_i: i32 = geometry_index + i32(vertex_index % 3) * 3;
    // Transform position
    out.relative_position = vec3f(geometry[v_i], geometry[v_i + 1], geometry[v_i + 2]);
    // Get transformation ID
    let tI: i32 = i32(geometry[geometry_index + 9]) << 1;

    // Trasform position
    let transform: Transform = transforms[tI];
    out.absolute_position = (transform.rotation * out.relative_position) + transform.shift;


    out.clip_space = uniforms.view_matrix * (out.absolute_position - uniforms.camera_position);
    // Set triangle position in clip space
    out.pos = vec4f(out.clip_space.xy, 1.0f / (1.0f + exp(out.clip_space.z * INV_65535)), out.clip_space.z);
    return out;
}

// FRAGMENT SHADER ------------------------------------------------------------------------------------------------------------------------


struct Ray {
    origin: vec3f,
    unit_direction: vec3f,
};

struct Material {
    albedo: vec3f,
    rme: vec3f,
    tpo: vec3f
};

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
/*
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
    return F0 + (1.0f - F0) * pow(1.0f - theta, 5.0f);
}

vec3 forwardTrace(Material material, vec3 lightDir, float strength, vec3 N, vec3 V) {
    float lenP1 = 1.0f + length(lightDir);
    // Apply inverse square law
    float brightness = strength / (lenP1 * lenP1);

    vec3 L = normalize(lightDir);
    vec3 H = normalize(V + L);

    float VdotH = max(dot(V, H), 0.0f);
    float NdotL = max(dot(N, L), 0.0f);
    float NdotH = max(dot(N, H), 0.0f);
    float NdotV = max(dot(N, V), 0.0f);

    float alpha = material.rme.x * material.rme.x;
    float BRDF = mix(1.0f, NdotV, material.rme.y);
    vec3 F0 = material.albedo * BRDF;

    vec3 Ks = fresnel(F0, VdotH);
    vec3 Kd = (1.0f - Ks) * (1.0f - material.rme.y);
    vec3 lambert = material.albedo * INV_PI;

    vec3 cookTorranceNumerator = Ks * trowbridgeReitz(alpha, NdotH) * smith(alpha, NdotV, NdotL);
    float cookTorranceDenominator = 4.0f * NdotV * NdotL;
    cookTorranceDenominator = max(cookTorranceDenominator, BIAS);

    vec3 cookTorrance = cookTorranceNumerator / cookTorranceDenominator;
    vec3 radiance = Kd * lambert + cookTorrance;

    // Outgoing light to camera
    return radiance * NdotL * brightness;
}
*/
@fragment
fn fsMain(
    @location(1) absolute_position: vec3f,
    @location(2) clip_space: vec3f,
    @location(3) @interpolate(flat) triangle_index: i32
) -> @location(0) vec4f {
    let scene_index = triangle_index * 28;
    let normal = vec3(scene[scene_index], scene[scene_index + 1], scene[scene_index + 2]);
    let albedo = vec3(scene[scene_index + 18], scene[scene_index + 19], scene[scene_index + 20]);

    let lightDir: vec3f = lights[0].position - absolute_position;
    let lightRay: Ray = Ray(absolute_position, normalize(lightDir));
    if (shadowTest(lightRay, length(lightDir))) {
        return vec4(0.1f) * vec4(albedo, 1.0f);
    } else {
        return vec4(albedo * dot(normal, normalize(lights[0].position - absolute_position)), 1.0f);
    }

}