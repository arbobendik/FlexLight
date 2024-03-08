const INV_65535: f32 = 0.000015259021896696422;

struct Uniforms {
    viewMatrix: mat3x3<f32>,
    cameraPosition: vec3f,
};

struct VertexOut {
    @builtin(position) pos: vec4f,
    @location(0) color: vec4f,
    @location(1) clipSpace: vec3f,
    @location(2) @interpolate(flat) triangleIndex: i32,
};

@group(0) @binding(0) var<uniform> uniforms: Uniforms;
@group(0) @binding(1) var<storage, read> indexBuffer: array<i32>;
@group(0) @binding(2) var<storage, read> geometryBuffer: array<f32>;
@group(0) @binding(3) var<storage, read> sceneBuffer: array<f32>;

@vertex
fn vsMain(
    @builtin(vertex_index) vertexIndex : u32,
    @builtin(instance_index) instanceIndex: u32
) -> VertexOut {
    var out: VertexOut;

    let triangleIndex = indexBuffer[instanceIndex];
    let geometryIndex = triangleIndex * 12 + i32(vertexIndex % 3) * 3;
    // Transform position
    let absolutePosition = vec3(geometryBuffer[geometryIndex], geometryBuffer[geometryIndex + 1], geometryBuffer[geometryIndex + 2]);

    out.clipSpace = uniforms.viewMatrix * (absolutePosition - uniforms.cameraPosition);
    // Set triangle position in clip space
    out.pos = vec4f(out.clipSpace.xy, 1.0f / (1.0f + exp(out.clipSpace.z * INV_65535)), out.clipSpace.z);
    out.triangleIndex = triangleIndex;
    return out;
}

struct Material {
    albedo: vec3f,
    rme: vec3f,
    tpo: vec3f
};

@fragment
fn fsMain(
    @location(0) color: vec4f,
    @location(1) clipSpace: vec3f,
    @location(2) @interpolate(flat) triangleIndex: i32
) -> @location(0) vec4f {
    let sceneIndex = triangleIndex * 28;
    let normal = vec3(sceneBuffer[sceneIndex], sceneBuffer[sceneIndex + 1], sceneBuffer[sceneIndex + 2]);
    let albedo = vec3(sceneBuffer[sceneIndex + 18], sceneBuffer[sceneIndex + 19], sceneBuffer[sceneIndex + 20]);
    return vec4(albedo * dot(normal, normalize(uniforms.cameraPosition - clipSpace.xyz)), 1.0);
}