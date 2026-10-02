#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

const float EDGE_THRESHOLD_MIN = 1.0 / 16.0;
const float EDGE_THRESHOLD_MAX = 1.0 / 4.0;
const float SUBPIX_QUALITY = 1.0 / 4.0;

uniform sampler2D input_texture;

out vec4 output_color;

// Helper function to get luminance from RGB
float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// Load texel clamped to texture bounds
vec4 load(ivec2 position) {
    return texelFetch(input_texture, clamp(position, ivec2(0), textureSize(input_texture, 0) - 1), 0);
}

void main() {
    ivec2 load_pos = ivec2(gl_FragCoord.xy);

    // Sample the 3x3 neighborhood, rows grow upwards in WebGL2 opposed to WebGPU
    vec4 center = load(load_pos);
    vec4 north = load(load_pos + ivec2(0, -1));
    vec4 south = load(load_pos + ivec2(0, 1));
    vec4 east = load(load_pos + ivec2(1, 0));
    vec4 west = load(load_pos + ivec2(-1, 0));

    // Get luminance values
    float luma_center = luminance(center.rgb);
    float luma_north = luminance(north.rgb);
    float luma_south = luminance(south.rgb);
    float luma_east = luminance(east.rgb);
    float luma_west = luminance(west.rgb);

    // Find min and max luma in 3x3 neighborhood
    float luma_min = min(luma_center, min(min(luma_north, luma_south), min(luma_east, luma_west)));
    float luma_max = max(luma_center, max(max(luma_north, luma_south), max(luma_east, luma_west)));

    // Compute local contrast
    float luma_range = luma_max - luma_min;

    // Early exit if contrast is lower than minimum
    if (luma_range < max(EDGE_THRESHOLD_MIN, luma_max * EDGE_THRESHOLD_MAX)) {
        output_color = center;
        return;
    }

    // Compute horizontal and vertical gradients
    float horizontal = abs(luma_west + luma_east - 2.0 * luma_center) * 2.0 +
                       abs(luma_north + luma_south - 2.0 * luma_center);
    float vertical = abs(luma_north + luma_south - 2.0 * luma_center) * 2.0 +
                     abs(luma_west + luma_east - 2.0 * luma_center);

    // Determine edge direction
    bool is_horizontal = horizontal >= vertical;

    // Choose positive and negative endpoints
    float pos_grad = is_horizontal ? luma_east : luma_north;
    float neg_grad = is_horizontal ? luma_west : luma_south;

    // Compute local gradient
    float gradient = max(
        abs(pos_grad - luma_center),
        abs(neg_grad - luma_center)
    );

    // Calculate blend factor
    float blend_factor = smoothstep(0.0, 1.0, gradient / luma_range);
    float subpix_blend = clamp(blend_factor * SUBPIX_QUALITY, 0.0, 1.0);

    // Perform anti-aliasing blend
    if (is_horizontal) {
        vec4 blend_color = mix(west, east, subpix_blend);
        output_color = mix(center, blend_color, 0.5);
    } else {
        vec4 blend_color = mix(south, north, subpix_blend);
        output_color = mix(center, blend_color, 0.5);
    }
}
