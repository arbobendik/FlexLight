const POW32U: u32 = 4294967295u;

@group(0) @binding(0) var<storage, read_write> depth_buffer: array<u32>;
@group(0) @binding(1) var texture_triangle_id: texture_storage_2d<r32sint, write>;

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
    let buffer_index: u32 = global_invocation_id.x + num_workgroups.x * 8u * global_invocation_id.y;
    // Clear textures we render to every frame
    textureStore(texture_triangle_id, screen_pos, vec4<i32>(0));
    depth_buffer[buffer_index] = POW32U;
}