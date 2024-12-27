const POW32U: u32 = 4294967295u;
const POW24F: f32 = 16777216.0f;
const SQRT2: f32 = 1.4142135623730951f;

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

@group(0) @binding(0) var accumulated: texture_2d_array<f32>;
@group(0) @binding(1) var<storage, read_write> buffer_out: array<atomic<u32>>;

@group(1) @binding(0) var<uniform> uniforms: Uniforms;

// atomicStore(atomic_ptr: ptr<AS, atomic<T>, read_write>, v: T)

fn store_atomic(pos: vec2<u32>, val: vec4<f32>) {
    let b_pos: u32 = (pos.x + u32(uniforms.render_size.x) * pos.y) * 4u;
    // Spread out the float values over the range of u32.
    let u32vals: vec4<u32> = vec4<u32>(val * POW24F);
    // Store the u32 values.
    atomicStore(&buffer_out[b_pos], u32vals.x);
    atomicStore(&buffer_out[b_pos + 1], u32vals.y);
    atomicStore(&buffer_out[b_pos + 2], u32vals.z);
    atomicStore(&buffer_out[b_pos + 3], u32vals.w);
}

fn add_atomic(pos: vec2<u32>, val: vec4<f32>) {
    let b_pos: u32 = (pos.x + u32(uniforms.render_size.x) * pos.y) * 4u;
    // Spread out the float values over the range of u32.
    let u32vals: vec4<u32> = vec4<u32>(val * POW24F);
    // Store the u32 values.
    atomicAdd(&buffer_out[b_pos], u32vals.x);
    atomicAdd(&buffer_out[b_pos + 1], u32vals.y);
    atomicAdd(&buffer_out[b_pos + 2], u32vals.z);
    atomicAdd(&buffer_out[b_pos + 3], u32vals.w);
}

fn interpolate_store(pos: vec2<f32>, val: vec4<f32>) {
    let pos_fract: vec2<f32> = fract(pos);
    let pos_u32: vec2<u32> = vec2<u32>(pos);

    let offsets = mat4x2<f32>(
        vec2<f32>(0.0f, 0.0f),
        vec2<f32>(1.0f, 0.0f),
        vec2<f32>(0.0f, 1.0f),
        vec2<f32>(1.0f, 1.0f)
    );

    let distances: vec4<f32> = max(1.0f - vec4<f32>(
        length(offsets[0] - pos_fract),
        length(offsets[1] - pos_fract),
        length(offsets[2] - pos_fract),
        length(offsets[3] - pos_fract)
    ), vec4<f32>(0.0f));

    let weights: vec4<f32> = distances / (distances.x + distances.y + distances.z + distances.w);

    // let positions: mat4x2<u32> = pos_u32 + mat4x2<u32>(offsets);

    add_atomic(pos_u32 + vec2<u32>(offsets[0]), val * weights.x);
    add_atomic(pos_u32 + vec2<u32>(offsets[1]), val * weights.y);
    add_atomic(pos_u32 + vec2<u32>(offsets[2]), val * weights.z);
    add_atomic(pos_u32 + vec2<u32>(offsets[3]), val * weights.w);
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
    
    if (global_invocation_id.x > u32(uniforms.render_size.x) || global_invocation_id.y > u32(uniforms.render_size.y)) {
        return;
    }
    

    // Get texel position of screen
    let screen_pos: vec2<u32> = global_invocation_id.xy;
    // Amount of temporal passes
    // for (var i: u32 = 0; i < depth; i++) {
    // Extract color value from old position
    var color: vec4<f32> = textureLoad(accumulated, screen_pos, 0, 0);
    // Extract 3d position value
    let position_cur: vec4<f32> = textureLoad(accumulated, screen_pos, 4, 0);
    // If absolute position is all zeros then there is nothing to do

    if (position_cur.w != uniforms.temporal_target) {
        store_atomic(screen_pos, vec4<f32>(uniforms.ambient, 1.0f));
        return;
    }

    if (uniforms.is_temporal == 1.0f) {
        // Reproject position to jitter if temporal is enabled
        let clip_space: vec3<f32> = uniforms.view_matrix_jitter * (position_cur.xyz - uniforms.camera_position);
        let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;
        let canvas_pos: vec2<f32> = vec2<f32>(
            uniforms.render_size.x * screen_space.x,
            uniforms.render_size.y * (1.0f - screen_space.y)
        );

        let canvas_pos_u32: vec2<u32> = vec2<u32>(
            u32(uniforms.render_size.x * screen_space.x),
            u32(uniforms.render_size.y * (1.0f - screen_space.y))
        );

        // Interpolate color from old position
        // interpolate_store(canvas_pos, color);
        store_atomic(canvas_pos_u32, color);


        // fine_color = vec3<f32>(1.0f, 0.0f, 0.0f);
    } else {
        // Write straight to canvas.
        store_atomic(screen_pos, color);
        // textureStore(canvas_out, screen_pos, vec4<f32>(fine_color, 1.0f));
    }

    // textureStore(shift_out, coord, 1, fine_color_low_variance_acc);
    // textureStore(shift_out, coord, 3, coarse_color_low_variance_acc);
    //}

    // Clear textures we render to every frame
}