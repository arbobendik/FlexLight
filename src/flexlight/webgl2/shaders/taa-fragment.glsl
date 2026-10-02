#version 300 es

precision highp float;
precision highp int;
precision highp sampler2DArray;

uniform sampler2DArray input_texture;
uniform int frame_index;
uniform int frames;

out vec4 output_color;

// Load texel of the current frame clamped to texture bounds
vec3 load_current(ivec2 position) {
    return texelFetch(input_texture, ivec3(clamp(position, ivec2(0), textureSize(input_texture, 0).xy - 1), frame_index), 0).xyz;
}

// Helper function to calculate color variance
mat2x3 calculate_neighborhood_bounds(ivec2 center_pos) {
    vec3 min_color = vec3(1.0);
    vec3 max_color = vec3(0.0);
    vec3 mean_color = vec3(0.0);
    vec3 mean_sq_color = vec3(0.0);
    float sample_count = 0.0;

    // Sample 3x3 neighborhood with gaussian weights
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            ivec2 sample_pos = center_pos + ivec2(x, y);
            float weight = (1.0 - abs(float(x)) * 0.35) * (1.0 - abs(float(y)) * 0.35);
            vec3 neighbor = load_current(sample_pos);

            mean_color += neighbor * weight;
            mean_sq_color += neighbor * neighbor * weight;
            min_color = min(min_color, neighbor);
            max_color = max(max_color, neighbor);
            sample_count += weight;
        }
    }

    mean_color /= sample_count;
    mean_sq_color /= sample_count;

    // Calculate variance and adjust bounds
    vec3 variance = max(mean_sq_color - mean_color * mean_color, vec3(0.0));
    vec3 std_dev = sqrt(variance);

    // Expand the color bounds based on local variance with a more lenient gamma
    float gamma = 1.75;
    min_color = max(min_color, mean_color - std_dev * gamma);
    max_color = min(max_color, mean_color + std_dev * gamma);

    return mat2x3(min_color, max_color);
}

void main() {
    ivec2 center_pos = ivec2(gl_FragCoord.xy);
    ivec2 texture_size = textureSize(input_texture, 0).xy;
    vec3 current_color = load_current(center_pos);

    // Calculate color bounds
    mat2x3 bounds = calculate_neighborhood_bounds(center_pos);
    vec3 min_color = bounds[0];
    vec3 max_color = bounds[1];

    // Accumulate history samples with improved clamping
    vec3 final_color = current_color;
    float weight_sum = 1.0;

    for (int i = 0; i < frames; i++) {
        if (i == frame_index) {
            continue;
        }

        vec3 history_color = texelFetch(input_texture, ivec3(center_pos, i), 0).xyz;

        // Clamp history color to neighborhood bounds
        vec3 clamped_color = clamp(history_color, min_color, max_color);

        // Calculate confidence weight based on how much clamping was needed
        float clamp_amount = length(history_color - clamped_color);
        float confidence = 1.0 - smoothstep(0.0, 0.2, clamp_amount);

        final_color += clamped_color * confidence;
        weight_sum += confidence;
    }

    final_color /= weight_sum;

    // Apply a small additional blur to the final result
    vec3 blurred_color = vec3(0.0);
    float blur_weight = 0.0;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            ivec2 sample_pos = center_pos + ivec2(x, y);
            if (sample_pos.x >= 0 && sample_pos.x < texture_size.x &&
                sample_pos.y >= 0 && sample_pos.y < texture_size.y) {
                float weight = (1.0 - abs(float(x)) * 0.4) * (1.0 - abs(float(y)) * 0.4);
                blurred_color += load_current(sample_pos) * weight;
                blur_weight += weight;
            }
        }
    }

    // Mix the final color with the blurred result
    final_color = mix(final_color, blurred_color / blur_weight, 0.3);

    output_color = vec4(final_color, 1.0);
}
