const POW32U: u32 = 4294967295u;
const SQRT3: f32 = 1.7320508075688772;
const INV_1023: f32 = 0.0009775171065493646;

struct Uniforms {
    view_matrix: mat3x3<f32>,

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

@group(0) @binding(0) var compute_out: texture_2d_array<f32>;
@group(0) @binding(1) var shift_out: texture_2d_array<f32>;
@group(0) @binding(2) var accumulated: texture_storage_2d_array<rgba32float, write>;
@group(0) @binding(3) var canvas_out: texture_storage_2d<rgba32float, write>;

@group(1) @binding(0) var<uniform> uniforms: Uniforms;

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
    if (screen_pos.x > u32(uniforms.render_size.x) || screen_pos.y > u32(uniforms.render_size.y)) {
        return;
    }

    // Get current color and position.
    let color_cur: vec4<f32> = textureLoad(compute_out, screen_pos, 0, 0);
    let position_cur: vec4<f32> = textureLoad(compute_out, screen_pos, 1, 0);

    
    
    // for (var i: u32 = 0; i < depth; i++) {
    // Extract 3d position value
    let fine_color_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 0, 0);
    let fine_color_low_variance_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 1, 0);
    let coarse_color_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 2, 0);
    let coarse_color_low_variance_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 3, 0);
    let position_acc: vec4<f32> = textureLoad(shift_out, screen_pos, 4, 0);
    // If absolute position is all zeros then there is nothing to do

    let diff: f32 = length(position_cur.xyz - position_acc.xyz);
    let cur_depth: f32 = length(position_cur.xyz - uniforms.camera_position.xyz);
    // let norm_color_diff = dot(normalize(current_color.xyz), normalize(accumulated_color.xyz));

    let croped_cur_color: vec3<f32> = min(color_cur.xyz, vec3<f32>(1.0f));

    var fine_color: vec3<f32> = color_cur.xyz;
    var fine_color_low_variance: vec3<f32> = croped_cur_color;
    var fine_count: f32 = 0.0f;

    var coarse_color: vec3<f32> = color_cur.xyz;
    var coarse_color_low_variance: vec3<f32> = croped_cur_color;
    var coarse_count: f32 = 0.0f;

    if (diff < cur_depth * INV_1023 * 16.0f) {
        // Add color to total and increase counter by one
        fine_count = min(fine_color_acc.w + 1.0f, 32.0f);
        fine_color = mix(fine_color_acc.xyz, color_cur.xyz, 1.0f / fine_count);
        fine_color_low_variance = mix(fine_color_low_variance_acc.xyz, croped_cur_color, 1.0f / fine_count);

        coarse_count = min(coarse_color_acc.w + 1.0f, 4.0f);
        coarse_color = mix(coarse_color_acc.xyz, color_cur.xyz, 1.0f / coarse_count);
        coarse_color_low_variance = mix(coarse_color_low_variance_acc.xyz, croped_cur_color, 1.0f / coarse_count);


        let average_low_variance: f32 = (length(fine_color_low_variance) + length(coarse_color_low_variance)) / 2.0f;

        if (
            dot(normalize(fine_color), normalize(coarse_color)) < 0.9f
            || length(fine_color_low_variance) - length(coarse_color_low_variance) > 0.9f * average_low_variance
        ) {
            fine_color = coarse_color;
            fine_color_low_variance = coarse_color_low_variance;
            fine_count = coarse_count;
        }
    }
    //}
    textureStore(accumulated, screen_pos, 0, vec4<f32>(fine_color, fine_count));
    textureStore(accumulated, screen_pos, 1, vec4<f32>(fine_color_low_variance, fine_count));
    textureStore(accumulated, screen_pos, 2, vec4<f32>(coarse_color, coarse_count));
    textureStore(accumulated, screen_pos, 3, vec4<f32>(coarse_color_low_variance, coarse_count));
    textureStore(accumulated, screen_pos, 4, vec4<f32>(position_cur.xyz, 1.0f));
    textureStore(canvas_out, screen_pos, vec4<f32>(fine_color, 1.0f));
}