const POW32U: u32 = 4294967295u;
const INV_255: f32 = 0.00392156862745098;
const INV_1023: f32 = 0.0009775171065493646;
const INV_65535: f32 = 0.000015259021896696422;

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
@group(0) @binding(1) var compute_id: texture_2d_array<f32>;
@group(0) @binding(2) var canvas_out: texture_storage_2d<rgba32float, write>;

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

    let cur_texel = textureLoad(shift_out, screen_pos, u32(uniforms.temporal_target), 0);
    // The current pixel has the desireable depth
    let cur_depth: f32 = cur_texel.w;

    // If depth is 0.0f then that pixel is in the void in current frame
    if (cur_depth == 0.0f) {
        // Output current color value
        textureStore(canvas_out, screen_pos, vec4<f32>(uniforms.ambient, 0.0f));
        return;
    }
    // Accumulate color values
    var color_sum: vec3<f32> = vec3<f32>(0.0f);
    var counter: i32 = 0;
    // Amount of temporal passes
    let layers: u32 = textureNumLayers(shift_out);

    for (var i: u32 = 0; i < layers; i++) {
        // Skip current layer as it's already accounted for
        //if (i == u32(uniforms.temporal_target)) {
        //    continue;
        //}
        // Extract color values
        /*
        let texel: vec4<f32> = textureLoad(shift_out, screen_pos, i, 0);
        // Test if depth is close enough to account for non-perfect overlap
        if (abs(cur_depth - texel.w) < cur_depth * INV_1023) {
            // Add color to total and increase counter by one
            color_sum += texel.xyz;
            counter++;
        }
        */

        if (id[i].xyzw == id.xyzw) {
          color += c[i].xyz + ip[i].xyz * 256.0;
          counter ++;
        }
    }

    // Write average to target
    textureStore(canvas_out, screen_pos, vec4<f32>(color_sum / f32(counter), cur_depth));
}