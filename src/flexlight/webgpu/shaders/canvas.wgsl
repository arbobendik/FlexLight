// const KERNEL_SIZE: u32 = 5u;
// const NUM_SAMPLES: u32 = KERNEL_SIZE * KERNEL_SIZE;
const POW32U: u32 = 4294967295u;

struct UniformFloat {
    view_matrix: mat3x3<f32>,
    inv_view_matrix: mat3x3<f32>,

    camera_position: vec3<f32>,
    ambient: vec3<f32>,

    min_importancy: f32,
};

struct UniformUint {
    render_size: vec2<u32>,
    temporal_target: u32,
    temporal_max: u32,
    is_temporal: u32,

    samples: u32,
    max_reflections: u32,

    tonemapping_operator: u32,
    point_light_count: u32,
};

@group(0) @binding(0) var compute_out: texture_2d<f32>;
@group(0) @binding(1) var canvas_out: texture_storage_2d<rgba8unorm, write>;

@group(1) @binding(0) var<uniform> uniforms_float: UniformFloat;
@group(1) @binding(1) var<uniform> uniforms_uint: UniformUint;

// Based on http://www.oscars.org/science-technology/sci-tech-projects/aces
fn aces_tonemap(color: vec3<f32>) -> vec3<f32> {	
	let m1: mat3x3<f32> = mat3x3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
	);
	let m2: mat3x3<f32> = mat3x3(
        1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602
	);
	let v: vec3<f32> = m1 * color;    
	let a: vec3<f32> = v * (v + 0.0245786) - 0.000090537;
	let b: vec3<f32> = v * (0.983729 * v + 0.4329510) + 0.238081;
	return pow(clamp(m2 * (a / b), vec3<f32>(0.0), vec3<f32>(1.0)), vec3<f32>(1.0 / 2.2));	
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
    // Get texel position of screen
    let screen_pos: vec2<u32> = global_invocation_id.xy;
    if (screen_pos.x > uniforms_uint.render_size.x || screen_pos.y > uniforms_uint.render_size.y) {
        return;
    }
    

    let center_texel: vec4<f32> = textureLoad(compute_out, screen_pos, 0);
    var median_color: vec3<f32> = center_texel.xyz;

    let alpha: f32 = center_texel.w;

    // Apply tone mapping if required.
    if (uniforms_uint.tonemapping_operator == 1u) {
        // Apply Reinhard tone mapping.
        // median_color = median_color / (median_color + vec3<f32>(1.0f));
        median_color = aces_tonemap(median_color);
    }

    /*
    if (abs(screen_pos.x - 1280u) < 10u) {
        median_color = vec3<f32>(1.0, 0.0, 0.0);
    }
    */
    /*
    let dist = distance(vec2<f32>(screen_pos), vec2<f32>(uniforms_uint.render_size) * 0.5f);

    if (dist < 3.0f) {
        median_color = vec3<f32>(0.0, 0.0, 0.0);
    }
    */
    // Write the final color to canvas.
    textureStore(canvas_out, screen_pos, vec4<f32>(median_color, alpha));
}

/*
// Helper function to load a neighbor texel with clamping.
fn loadNeighbour(center: vec2<u32>, offset: vec2<i32>) -> vec4<f32> {
    let renderSize: vec2<i32> = vec2<i32>(i32(uniforms_uint.render_size.x), i32(uniforms_uint.render_size.y));
    let pos: vec2<i32> = vec2<i32>(i32(center.x), i32(center.y)) + offset;
    let clamped: vec2<i32> = clamp(pos, vec2<i32>(0, 0), renderSize - vec2<i32>(1, 1));
    return textureLoad(compute_out, vec2<u32>(u32(clamped.x), u32(clamped.y)), 0);
}

// Helper function to compute the median of an array of NUM_SAMPLES floats using merge sort.
fn median(values: array<f32, NUM_SAMPLES>) -> u32 {
    // Copy the input values into an array to be sorted.
    var a: array<f32, NUM_SAMPLES> = values;
    var temp: array<f32, NUM_SAMPLES>;
    let n: u32 = NUM_SAMPLES;
    var width: u32 = 1u;

    // Iterative bottom-up merge sort.
    while (width < n) {
        for (var i: u32 = 0u; i < n; i = i + width * 2u) {
            // Set boundaries for the subarrays.
            var left: u32 = i;
            var right: u32 = i + width;
            let left_end: u32 = min(i + width, n);
            let right_end: u32 = min(i + width * 2u, n);
            var index: u32 = i;

            // Merge the two subarrays.
            while (left < left_end && right < right_end) {
                if (a[left] <= a[right]) {
                    temp[index] = a[left];
                    left = left + 1u;
                } else {
                    temp[index] = a[right];
                    right = right + 1u;
                }
                index = index + 1u;
            }

            // Copy any remaining elements from the left subarray.
            while (left < left_end) {
                temp[index] = a[left];
                left = left + 1u;
                index = index + 1u;
            }

            // Copy any remaining elements from the right subarray.
            while (right < right_end) {
                temp[index] = a[right];
                right = right + 1u;
                index = index + 1u;
            }
        }
        // Copy the merged results back into a for the next iteration.
        for (var j: u32 = 0u; j < n; j = j + 1u) {
            a[j] = temp[j];
        }
        width = width * 2u;
    }

    // Return the median element.
    return n / 2u;
}
*/
