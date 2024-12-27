const PI: f32 = 3.141592653589793;
const PHI: f32 = 1.61803398874989484820459;
const SQRT3: f32 = 1.7320508075688772;
const POW32: f32 = 4294967296.0;
const POW32U: u32 = 4294967295u;
const POW23M1: f32 = 8388607.0;
const BIAS: f32 = 0.0000152587890625;
const INV_PI: f32 = 0.3183098861837907;
const INV_255: f32 = 0.00392156862745098;

struct Transform {
    rotation: mat3x3<f32>,
    shift: vec3<f32>,
};

struct Uniforms {
    view_matrix: mat3x3<f32>,
    view_matrix_jitter: mat3x3<f32>,

    camera_position: vec3<f32>,
    ambient: vec3<f32>,

    texture_size: vec2<f32>,
    render_size: vec2<f32>,

    samples: f32,
    max_reflections: f32,
    min_importancy: f32,
    use_filter: f32,

    tonemapping_operator: f32,
    is_temporal: f32,
    temporal_target: f32
};

struct VertexOut {
    @builtin(position) pos: vec4<f32>,
    @location(0) absolute_position: vec3<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) clip_space: vec3<f32>,
    @location(3) @interpolate(flat) triangle_id: i32,
};


@group(0) @binding(0) var<storage, read> depth_buffer: array<u32>;
@group(0) @binding(1) var texture_triangle_id: texture_storage_2d<r32sint, write>;
@group(0) @binding(2) var texture_absolute_position: texture_storage_2d<rgba32float, write>;
@group(0) @binding(3) var texture_uv: texture_storage_2d<rg32float, write>;

@group(1) @binding(0) var<storage, read> indices: array<i32>;
@group(1) @binding(1) var<storage, read> geometry: array<f32>;

@group(2) @binding(0) var<uniform> uniforms: Uniforms;
@group(2) @binding(1) var<storage, read> transforms: array<Transform>;



@vertex
fn vertex(
    @builtin(vertex_index) vertex_index : u32,
    @builtin(instance_index) instance_index: u32
) -> VertexOut {
    var out: VertexOut;

    let vertex_num: i32 = i32(vertex_index) % 3;
    out.triangle_id = indices[instance_index];
    let geometry_index: i32 = out.triangle_id * 12;
    let v_i: i32 = geometry_index + vertex_num * 3;
    // Transform position
    let relative_position: vec3<f32> = vec3<f32>(geometry[v_i], geometry[v_i + 1], geometry[v_i + 2]);
    // Get transformation ID
    let t_i: i32 = i32(geometry[geometry_index + 9]) << 1u;
    // Trasform position
    let transform: Transform = transforms[t_i];
    out.absolute_position = (transform.rotation * relative_position) + transform.shift;
    // Set uv to vertex uv and let the vertex interpolation generate the values in between
    switch (vertex_num) {
        case 0: {
            out.uv = vec2<f32>(1.0f, 0.0f);
        }
        case 1: {
            out.uv = vec2<f32>(0.0f, 1.0f);
        }
        case 2, default {
            out.uv = vec2<f32>(0.0f, 0.0f);
        }
    }
    out.clip_space = uniforms.view_matrix_jitter * (out.absolute_position - uniforms.camera_position);
    // Set triangle position in clip space
    out.pos = vec4<f32>(out.clip_space.xy, 0.0f, out.clip_space.z);
    return out;
}

// FRAGMENT SHADER ------------------------------------------------------------------------------------------------------------------------

@fragment
fn fragment(
    @location(0) absolute_position: vec3<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) clip_space: vec3<f32>,
    @location(3) @interpolate(flat) triangle_id: i32
) -> @location(0) vec4<f32> {

    // Get canvas size
    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5f + 0.5f;
    let coord: vec2<u32> = vec2<u32>(
        u32(uniforms.render_size.x * screen_space.x),
        u32(uniforms.render_size.y  * (1.0f - screen_space.y))
    );

    let buffer_index: u32 = coord.x + u32(uniforms.render_size.x) * coord.y;
    // Only save if texel is closer to camera then previously
    let current_depth: u32 = u32(POW23M1 / (1.0f + exp(- clip_space.z * INV_255)));

    if (current_depth == depth_buffer[buffer_index]) {
        // Save values for compute pass
        textureStore(texture_absolute_position, coord, vec4<f32>(absolute_position, 0.0f));
        textureStore(texture_uv, coord, vec4<f32>(uv, 0.0f, 0.0f));
        textureStore(texture_triangle_id, coord, vec4<i32>(i32(triangle_id), 0, 0, 0));
    }

    return vec4<f32>(f32(triangle_id % 3) / 3.0f, f32(triangle_id % 2) / 2.0f, f32(triangle_id % 5) / 5.0f, 1.0f);
}