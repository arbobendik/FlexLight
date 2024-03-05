
struct Uniforms {
    viewMatrix: mat3x3<f32>,
    cameraPosition: vec3f,
}


struct VertexOut {
    @builtin(position) pos: vec4f,
    @location(0) color: vec4f,
}

@group(0) @binding(0) var<uniform> uniforms: Uniforms;
@group(0) @binding(1) var<storage, read> indexBuffer: array<i32>;
@group(0) @binding(2) var<storage, read> geometryBuffer: array<f32>;

@vertex fn vs(
    @builtin(vertex_index) vertexIndex : u32,
    @builtin(instance_index) instanceIndex: u32
) -> VertexOut {
    var out: VertexOut;

    let triangleIndex = indexBuffer[instanceIndex];
    let geometryIndex = triangleIndex * 12 + i32(vertexIndex % 3) * 3;
    // Transform position
    let absolutePosition = vec3(geometryBuffer[geometryIndex], geometryBuffer[geometryIndex + 1], geometryBuffer[geometryIndex + 2]);
    let clipSpace = (absolutePosition - uniforms.cameraPosition);
    // Set triangle position in clip space
    out.pos = vec4f(clipSpace.xy, 2.0 - 1.0f / (1.0f + exp(- length(absolutePosition / 65536.0))), clipSpace.z);

    let index = f32(triangleIndex);
    let indexCol = vec3f(index, index % 10.0, index % 100.0) * 0.1;

    out.color = vec4f(indexCol, 1);
    return out;
}

@fragment fn fs(@location(0) color: vec4f) -> @location(0) vec4f {
    return max(color, vec4f(0.1));
}