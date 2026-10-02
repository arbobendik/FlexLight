#version 300 es

void main() {
    // Generate (0, 0), (2, 0), (0, 2) from vertex index to cover clip space with one triangle
    vec2 position = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
    gl_Position = vec4(position * 2.0 - 1.0, 0.0, 1.0);
}
