// The material as the upload lays it out, which the path tracer, the rasterizer and the shared kernels read
struct Material {
    albedo: vec3<f32>,
    emissive: vec3<f32>,
    roughness: f32,
    metallic: f32,
    transmission: f32,
    ior: f32,
    absorption: vec3<f32>,
    specular_tint: vec3<f32>,
    specular_level: f32,
    // Blender's Translucent BSDF's color, which the diffuse lobe transmits to the other side of the face
    translucent: vec3<f32>,
    // Blender's sheen over the base, its weight times its tint, and its roughness
    sheen: vec3<f32>,
    sheen_roughness: f32,
    // Blender's Principled Anisotropic, its rotation in turns about the normal, whether its tangent is the UV map's
    // over Blender's default and the hit's tangent, which surfaceAt writes once anisotropy shades
    anisotropy: f32,
    anisotropic_rotation: f32,
    tangent_source: f32,
    tangent: vec3<f32>
};
