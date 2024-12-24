struct Uniforms {
    frame_index: f32,
    frames: f32,
    random_vecs: vec2<f32>
};

@group(0) @binding(0) var input_texture: texture_2d_array<f32>;
@group(0) @binding(1) var output_texture: texture_storage_2d<rgba32float, write>;
@group(0) @binding(2) var<uniform> uniforms: Uniforms;

@compute
@workgroup_size(8, 8)
fn compute(
    @builtin(global_invocation_id) global_id: vec3<u32>
) {
    let screen_pos = global_id.xy;
    let texture_size = textureDimensions(input_texture);
    
    // Early exit if outside render bounds
    if (screen_pos.x >= texture_size.x || screen_pos.y >= texture_size.y) {
        return;
    }

    // Calculate min/max RGB values from 3x3 neighborhood
    var min_rgb = vec3<f32>(1.0);
    var max_rgb = vec3<f32>(0.0);
    
    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
            let offset = vec2<i32>(i - 1, j - 1);
            let sample_pos = vec2<i32>(screen_pos) + offset;
            // Ensure we don't sample outside texture bounds
            let neighbor = textureLoad(input_texture, vec2<u32>(sample_pos), u32(uniforms.frame_index), 0).xyz;
            min_rgb = min(min_rgb, neighbor);
            max_rgb = max(max_rgb, neighbor);
        }
    }

    // Accumulate colors from history frames (1-8)
    var final_color = textureLoad(input_texture, screen_pos, u32(uniforms.frame_index), 0).xyz;
    
    var counter = 1;
    // Process first history frames
    for (var i = 0; i < i32(uniforms.frames); i++) {
        if (i == i32(uniforms.frame_index)) {
            continue;
        }
        
        let history_color = textureLoad(input_texture, screen_pos, u32(i), 0).xyz;
        //final_color += min(max(history_color, min_rgb), max_rgb);
        //counter += 1;

        
        if (all(min(min_rgb, history_color) == min_rgb) && all(max(max_rgb, history_color) == max_rgb)) {
            counter += 1;
            final_color += history_color;
        }
        
        
    }
    
    // Average the accumulated colors (9 samples total - current + 8 history frames)
    final_color /= f32(counter);
    
    // Write final color to output
    textureStore(output_texture, screen_pos, vec4<f32>(final_color, 1.0));
}
