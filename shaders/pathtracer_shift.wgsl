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

    is_temporal: f32,
    temporal_target: f32
};

@group(0) @binding(0) var compute_out: texture_storage_2d_array<rgba32float, read>;
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

    var color_sum: vec4<f32> = vec4<f32>(0.0f);
    // Amount of temporal passes
    let depth: u32 = textureNumLayers(compute_out) / 2;

    for (var i: u32 = 0; i < depth; i++) {
        // Extract color value from old position
        let color: vec3<f32> = textureLoad(compute_out, screen_pos, i).xyz;
        // Extract 3d position value
        let absolute_position: vec3<f32> = textureLoad(compute_out, screen_pos, depth + i).xyz;
        // Map postion according to current camera positon and view matrix to clip space
        let clip_space: vec3<f32> = uniforms.view_matrix * (absolute_position - uniforms.camera_position);
        // Project onto screen and shift origin to the corner
        let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;
        // Translate to texel value
        let coord: vec2<u32> = vec2<u32>(
            u32(uniforms.render_size.x * screen_space.x),
            u32(uniforms.render_size.y  * (1.0 - screen_space.y))
        );
        // Write color value to projected position in new texture and store depth in the 4'th variable
        if (i == u32(uniforms.temporal_target)) {
            // No need to shift current pass
            textureStore(shift_out, screen_pos, i, vec4<f32>(color, clip_space.z));
        } else {
            textureStore(shift_out, coord, i, vec4<f32>(color, clip_space.z));
        }
    }

    // Clear textures we render to every frame
}