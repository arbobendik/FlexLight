const POW32U: u32 = 4294967295u;
const POW24F: f32 = 16777216.0f;
const INV_POW24F: f32 = 0.000000059604644775390625;

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

@group(0) @binding(0) var<storage, read> buffer_in: array<u32>;
@group(0) @binding(1) var canvas_in: texture_storage_2d<rgba32float, write>;

@group(1) @binding(0) var<uniform> uniforms: Uniforms;

fn read_buffer(pos: vec2<u32>) -> vec4<f32> {
    let b_pos: u32 = (pos.x + u32(uniforms.render_size.x) * pos.y) * 4u;
    return vec4<f32>(f32(buffer_in[b_pos]), f32(buffer_in[b_pos + 1]), f32(buffer_in[b_pos + 2]), f32(buffer_in[b_pos + 3])) * INV_POW24F;
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
    // Amount of temporal passes
    // for (var i: u32 = 0; i < depth; i++) {
    // Extract color value from old position
    let color: vec4<f32> = read_buffer(screen_pos);


    textureStore(canvas_in, screen_pos, color);

    
    /*
    let pos_f32: vec2<f32> = vec2<f32>(screen_pos) / uniforms.render_size;

    let corners = mat4x2<f32>(
        vec2<f32>(0.0f, 0.0f),
        vec2<f32>(1.0f, 0.0f),
        vec2<f32>(0.0f, 1.0f),
        vec2<f32>(1.0f, 1.0f)
    );

    let colors = mat4x3<f32>(
        vec3<f32>(0.0f, 0.0f, 1.0f),
        vec3<f32>(1.0f, 0.0f, 0.0f),
        vec3<f32>(0.0f, 1.0f, 0.0f),
        vec3<f32>(1.0f, 1.0f, 0.0f)
    );


    let distances = max(1.0f - vec4<f32>(
        length(pos_f32 - corners[0]),
        length(pos_f32 - corners[1]),
        length(pos_f32 - corners[2]),
        length(pos_f32 - corners[3])
    ), vec4<f32>(0.0f));

    let weights = distances / (distances.x + distances.y + distances.z + distances.w);

    let final_color = weights.x * colors[0] + weights.y * colors[1] + weights.z * colors[2] + weights.w * colors[3];

    textureStore(canvas_in, screen_pos, vec4<f32>(final_color, 1.0f));
    */
}
