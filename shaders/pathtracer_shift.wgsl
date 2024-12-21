const POW32U: u32 = 4294967295u;

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

@group(0) @binding(0) var accumulated: texture_2d_array<f32>;
@group(0) @binding(1) var shift_out: texture_storage_2d_array<rgba32float, write>;

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
    // Amount of temporal passes
    // for (var i: u32 = 0; i < depth; i++) {
    // Extract color value from old position
    let fine_color_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 0, 0);
    let fine_color_low_variance_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 1, 0);
    let coarse_color_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 2, 0);
    let coarse_color_low_variance_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 3, 0);
    // Extract 3d position value
    let absolute_position: vec4<f32> = textureLoad(accumulated, screen_pos, 4, 0);
    // If absolute position is all zeros then there is nothing to do
    if (
        absolute_position.x == 0.0f &&
        absolute_position.y == 0.0f &&
        absolute_position.z == 0.0f &&
        absolute_position.w == 0.0f
    ) {
        return;
    }
    // Map postion according to current camera positon and view matrix to clip space
    let clip_space: vec3<f32> = uniforms.view_matrix * (absolute_position.xyz - uniforms.camera_position);
    // Project onto screen and shift origin to the corner
    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;
    // Translate to texel value
    let coord: vec2<u32> = vec2<u32>(
        u32(uniforms.render_size.x * screen_space.x),
        u32(uniforms.render_size.y * (1.0 - screen_space.y))
    );

    // let depth = length(absolute_position.xyz - uniforms.camera_position.xyz);
    // let color = 0.1 * current_color + 0.9 * accumulated_color;
    // Write color value to projected position in new texture and store depth in the 4'th variable
    textureStore(shift_out, coord, 0, fine_color_acc);
    textureStore(shift_out, coord, 1, fine_color_low_variance_acc);
    textureStore(shift_out, coord, 2, coarse_color_acc);
    textureStore(shift_out, coord, 3, coarse_color_low_variance_acc);
    textureStore(shift_out, coord, 4, vec4<f32>(absolute_position.xyz, 1.0f));
    //}

    // Clear textures we render to every frame
}