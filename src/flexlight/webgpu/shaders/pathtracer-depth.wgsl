const TRIANGLE_SIZE: u32 = 24u;
const INSTANCE_SIZE: u32 = 11u;
const TRANSFORM_SIZE: u32 = 28u;

const PI: f32 = 3.141592653589793;
const PHI: f32 = 1.61803398874989484820459;
const SQRT3: f32 = 1.7320508075688772;
const POW32: f32 = 4294967296.0;
const POW23M1: f32 = 8388607.0;
const POW23M1U: u32 = 8388607u;
const BIAS: f32 = 0.0000152587890625;
const INV_PI: f32 = 0.3183098861837907;
const INV_255: f32 = 0.00392156862745098;


struct Transform {
    rotation: mat3x3<f32>,
    inverse_rotation: mat3x3<f32>,
    shift: vec3<f32>,
};

struct Uniforms {
    view_matrix: mat3x3<f32>,
    view_matrix_jitter: mat3x3<f32>,

    camera_position: vec3<f32>,
    ambient: vec3<f32>,

    render_size: vec2<f32>,
    samples: f32,
    max_reflections: f32,

    min_importancy: f32,
    tonemapping_operator: f32,
    is_temporal: f32,
    temporal_target: f32,
};

struct VertexOut {
    @builtin(position) pos: vec4<f32>,
    @location(0) absolute_position: vec3<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) clip_space: vec3<f32>,
    @location(3) @interpolate(flat) instance_offset: u32,
    @location(4) @interpolate(flat) triangle_offset: u32,
};

// DepthBindGroup
@group(0) @binding(0) var<storage, read_write> depth_buffer: array<atomic<u32>>;

// RasterGeometryBindGroup
@group(1) @binding(0) var triangles: texture_2d_array<f32>;

// RasterDynamicBindGroup
@group(2) @binding(0) var<uniform> uniforms: Uniforms;
@group(2) @binding(1) var<storage, read> transforms: array<Transform>;
@group(2) @binding(2) var<storage, read> instances: array<u32>;


fn access_triangle(index: u32) -> f32 {
    // Divide triangle index by 2048 * 2048 to get layer
    let layer: u32 = index >> 22u;
    // Get height of triangle
    let height: u32 = (index >> 11u) & 0x7FFu;
    // Get width of triangle
    let width: u32 = index & 0x7FFu;
    // Return triangle
    return textureLoad(triangles, vec2<u32>(width, height), layer, 0).x;
}

fn binary_search_instance(triangle_number: u32) -> u32 {
    var left: u32 = 0u;
    var right: u32 = arrayLength(&instances) / INSTANCE_SIZE;
    
    while (left < right - 1u) {
        let mid: u32 = left + (right - left) / 2u;
        let start_number: u32 = instances[mid * INSTANCE_SIZE + 10u];
        
        if (start_number <= triangle_number) {
            left = mid;
        } else {
            right = mid;
        }
    }
    
    return left;
}

@vertex
fn vertex(
    @builtin(vertex_index) global_vertex_index: u32,
    @builtin(instance_index) triangle_index: u32
) -> VertexOut {
    var out: VertexOut;
    let vertex_num: u32 = global_vertex_index % 3u;

    let instance_offset: u32 = binary_search_instance(triangle_index) * INSTANCE_SIZE;
    out.instance_offset = instance_offset;

    let triangle_offset: u32 = instances[instance_offset];
    let transform_offset: u32 = instances[instance_offset + 3u];
    let triangle_index_offset: u32 = instances[instance_offset + 10u];
    let internal_triangle_index: u32 = triangle_index - triangle_index_offset;
    out.triangle_offset = internal_triangle_index;

    let vertex_offset: u32 = triangle_offset + internal_triangle_index * TRIANGLE_SIZE + vertex_num * 3u;

    let relative_position: vec3<f32> = vec3<f32>(
        access_triangle(vertex_offset),
        access_triangle(vertex_offset + 1u),
        access_triangle(vertex_offset + 2u)
    );
    // Trasform position
    let transform: Transform = transforms[transform_offset / TRANSFORM_SIZE];
    out.absolute_position = relative_position + transform.shift;
    // Set uv to vertex uv and let the vertex interpolation generate the values in between
    switch (vertex_num) {
        case 0u: {
            // out.absolute_position = vec3<f32>(0.0f, 1.0f, 1.0f);
            out.uv = vec2<f32>(1.0f, 0.0f);
        }
        case 1u: {
            // out.absolute_position = vec3<f32>(1.0f, 0.0f, 1.0f);
            out.uv = vec2<f32>(0.0f, 1.0f);
        }
        case 2u: {
            // out.absolute_position = vec3<f32>(0.0f, 0.0f, 1.0f);
            out.uv = vec2<f32>(0.0f, 0.0f);
        }
        default: {
            // out.absolute_position = vec3<f32>(0.0f, 0.0f, 1.0f);
            out.uv = vec2<f32>(0.0f, 0.0f);
        }
    }

    out.clip_space = uniforms.view_matrix_jitter * (out.absolute_position - uniforms.camera_position);
    // Set triangle position in clip space
    out.pos = vec4<f32>(out.clip_space.xy, 0.0, out.clip_space.z);
    
    return out;
}

// FRAGMENT SHADER ------------------------------------------------------------------------------------------------------------------------

@fragment
fn fragment(
    @location(0) absolute_position: vec3<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) clip_space: vec3<f32>,
    @location(3) @interpolate(flat) instance_index: u32,
    @location(4) @interpolate(flat) triangle_index: u32
) -> @location(0) vec4<f32> {

    // Get canvas size
    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;
    let coord: vec2<u32> = vec2<u32>(
        u32(uniforms.render_size.x * screen_space.x),
        u32(uniforms.render_size.y  * (1.0 - screen_space.y))
    );

    let buffer_index: u32 = coord.x + u32(uniforms.render_size.x) * coord.y;
    // Only save if texel is closer to camera then previously
    let current_depth: u32 = POW23M1U - u32(POW23M1 / (1.0f + exp(- clip_space.z * INV_255)));
    // Store in texture
    atomicMax(&depth_buffer[buffer_index], current_depth);
    // Return meaningless value, as this shader is only used to populate the atomic depth buffer.
    return vec4<f32>(1.0f);
}