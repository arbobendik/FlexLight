#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D compute_out;
uniform uint tonemapping_operator;

out vec4 canvas_out;

// Based on http://www.oscars.org/science-technology/sci-tech-projects/aces
vec3 aces_tonemap(vec3 color) {
    mat3 m1 = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
    );
    mat3 m2 = mat3(
        1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602
    );
    vec3 v = m1 * color;
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return pow(clamp(m2 * (a / b), vec3(0.0), vec3(1.0)), vec3(1.0 / 2.2));
}

void main() {
    vec4 center_texel = texelFetch(compute_out, ivec2(gl_FragCoord.xy), 0);
    vec3 color = center_texel.xyz;
    // Apply tone mapping if required.
    if (tonemapping_operator == 1u) {
        color = aces_tonemap(color);
    }
    // Write the final color to canvas.
    canvas_out = vec4(color, center_texel.w);
}
