#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;
precision highp usampler2D;
precision highp sampler2DArray;
precision highp usampler2DArray;

const uint TRIANGLE_SIZE = 6u;

const uint INSTANCE_UINT_SIZE = 9u;

const uint TEXTURE_INSTANCE_SIZE = 4u;

const uint BVH_TRIANGLE_SIZE = 1u;
const uint BVH_INSTANCE_SIZE = 3u;

const uint TRIANGLE_BOUNDING_VERTICES_SIZE = 5u;
const uint INSTANCE_BOUNDING_VERTICES_SIZE = 3u;

const float PI = 3.141592653589793;
const float POW32 = 4294967296.0;
const float MAX_SAFE_INTEGER_FOR_F32 = 8388607.0;
const uint UINT_MAX = 4294967295u;
const uint UINT_MAX_M1 = 4294967294u;
const float BIAS = 0.0000152587890625;
const float INV_PI = 0.3183098861837907;
const float INV_255 = 0.00392156862745098;

struct Transform {
    mat3 rotation;
    vec3 shift;
};

struct Ray {
    vec3 origin;
    vec3 unit_direction;
};

struct Material {
    vec3 albedo;
    vec3 emissive;
    float roughness;
    float metallic;
    float transmission;
    float ior;
};

struct Light {
    vec3 position;
    float is_area_light;
    vec3 color;
    float intensity;
    float variance;
};

struct Hit {
    vec2 uv;
    uint instance_index;
    uint triangle_index;
    uint is_point_light;
    float dist;
};

// Geometry buffer of raster pass
uniform sampler2D texture_absolute_position;
uniform usampler2D texture_offset;
// Texture data
uniform usampler2DArray texture_data;
uniform usampler2DArray texture_instance;
uniform sampler2D environment_map;
// Geometry
uniform sampler2DArray triangles;
uniform usampler2DArray triangle_bvh;
uniform sampler2DArray triangle_bounding_vertices;
// Scene
uniform sampler2DArray lights;
uniform usampler2DArray instance_uint;
uniform sampler2DArray instance_transform;
uniform sampler2DArray instance_material;
uniform usampler2DArray instance_bvh;
uniform sampler2DArray instance_bounding_vertices;

uniform mat3 inv_view_matrix;
uniform vec3 camera_position;
uniform vec3 ambient;

uniform uvec2 render_size;
uniform uint temporal_target;
uniform uint samples;
uniform uint max_bounces;
uniform uvec2 environment_map_size;
uniform uint light_count;

layout(location = 0) out vec4 render_out;

ivec3 buffer_position(uint index) {
    // Divide index by 2048 * 2048 to get layer, remainder is split into row and column
    return ivec3(int(index & 0x7FFu), int((index >> 11u) & 0x7FFu), int(index >> 22u));
}

vec4 access_triangle(uint index) {
    return texelFetch(triangles, buffer_position(index), 0);
}

uvec4 access_triangle_bvh(uint index) {
    return texelFetch(triangle_bvh, buffer_position(index), 0);
}

vec4 access_triangle_bounding_vertices(uint index) {
    return texelFetch(triangle_bounding_vertices, buffer_position(index), 0);
}

uvec4 access_texture_data(uint index) {
    return texelFetch(texture_data, buffer_position(index), 0);
}

uint access_texture_instance(uint index) {
    return texelFetch(texture_instance, buffer_position(index), 0).x;
}

uint access_instance_uint(uint index) {
    return texelFetch(instance_uint, buffer_position(index), 0).x;
}

uint access_instance_bvh(uint index) {
    return texelFetch(instance_bvh, buffer_position(index), 0).x;
}

vec4 access_instance_bounding_vertices(uint index) {
    return texelFetch(instance_bounding_vertices, buffer_position(index), 0);
}

// Transforms are stored as 3 rotation columns followed by the shift, each padded to 4 floats
Transform access_instance_transform(uint index) {
    uint offset = index * 4u;
    return Transform(
        mat3(texelFetch(instance_transform, buffer_position(offset), 0).xyz, texelFetch(instance_transform, buffer_position(offset + 1u), 0).xyz, texelFetch(instance_transform, buffer_position(offset + 2u), 0).xyz),
        texelFetch(instance_transform, buffer_position(offset + 3u), 0).xyz
    );
}

// Albedo, pad | emissive, roughness | metallic, transmission, ior, pad
Material access_instance_material(uint index) {
    uint offset = index * 3u;
    vec4 m0 = texelFetch(instance_material, buffer_position(offset), 0);
    vec4 m1 = texelFetch(instance_material, buffer_position(offset + 1u), 0);
    vec4 m2 = texelFetch(instance_material, buffer_position(offset + 2u), 0);
    return Material(m0.xyz, m1.xyz, m1.w, m2.x, m2.y, m2.z);
}

// Position, is area light | color, intensity | variance, pad
Light access_light(uint index) {
    uint offset = index * 3u;
    vec4 l0 = texelFetch(lights, buffer_position(offset), 0);
    vec4 l1 = texelFetch(lights, buffer_position(offset + 1u), 0);
    vec4 l2 = texelFetch(lights, buffer_position(offset + 2u), 0);
    return Light(l0.xyz, l0.w, l1.xyz, l1.w, l2.x);
}

vec4 textureSample(uint index, vec2 uv) {
    uint texture_instance_offset = index * TEXTURE_INSTANCE_SIZE;
    // Fetch data from texture instance buffer
    uint texture_data_offset = access_texture_instance(texture_instance_offset);
    uint width = access_texture_instance(texture_instance_offset + 2u);
    uint height = access_texture_instance(texture_instance_offset + 3u);

    vec2 texel_position = uv * vec2(float(width), float(height));
    uvec2 texel_position_u32 = uvec2(texel_position);
    mat4x2 texel_position_mat = mat4x2(texel_position, texel_position, texel_position, texel_position);

    mat4x2 texel_pos = mat4x2(
        floor(texel_position + vec2(0.0, 0.0)),
        floor(texel_position + vec2(1.0, 0.0)),
        floor(texel_position + vec2(0.0, 1.0)),
        floor(texel_position + vec2(1.0, 1.0))
    );

    mat4x2 difference = texel_pos - texel_position_mat;

    vec4 texel_weights = vec4(
        abs(difference[0].x * difference[0].y),
        abs(difference[1].x * difference[1].y),
        abs(difference[2].x * difference[2].y),
        abs(difference[3].x * difference[3].y)
    );
    // Convert to index
    uvec4 t_texel_pos_u32_x = uvec4(texel_position_u32.x, texel_position_u32.x + 1u, texel_position_u32.x, texel_position_u32.x + 1u);
    uvec4 t_texel_pos_u32_y = uvec4(texel_position_u32.y, texel_position_u32.y, texel_position_u32.y + 1u, texel_position_u32.y + 1u);
    uvec4 texel_index = texture_data_offset + t_texel_pos_u32_x + t_texel_pos_u32_y * width;
    // Fetch texel and return result
    mat4 float_data = mat4(
        vec4(access_texture_data(texel_index.x)),
        vec4(access_texture_data(texel_index.y)),
        vec4(access_texture_data(texel_index.z)),
        vec4(access_texture_data(texel_index.w))
    );
    // Add weighted texels
    return float_data * texel_weights.wzyx;
}

struct Random {
    uint state;
    float value;
};

struct RandomSphere {
    uint state;
    vec3 value;
};

float rgb_to_greyscale(vec3 rgb) {
    return dot(rgb, vec3(0.299, 0.587, 0.114));
}

Random pcg(uint state) {
    // PCG random number generator
    // Reference: http://www.pcg-random.org/
    uint new_state = state * 747796405u + 2891336453u;
    uint word = ((new_state >> ((new_state >> 28u) + 4u)) ^ new_state) * 277803737u;
    uint result = (word >> 22u) ^ word;
    // Return random float between 0 and 1
    return Random(new_state, float(result) / float(UINT_MAX));
}

Random normal_distribution(uint state) {
    Random r1 = pcg(state);
    Random r2 = pcg(r1.state);
    // Sample normal distribution
    float theta = 2.0 * PI * r1.value;
    float rho = sqrt(-2.0 * clamp(log(r2.value), - MAX_SAFE_INTEGER_FOR_F32, 0.0));
    return Random(r2.state, rho * cos(theta));
}

RandomSphere random_sphere(uint state) {
    Random x = normal_distribution(state);
    Random y = normal_distribution(x.state);
    Random z = normal_distribution(y.state);
    return RandomSphere(z.state, normalize(vec3(x.value, y.value, z.value)));
}

// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
bool moellerTrumboreCull(vec3 a, vec3 b, vec3 c, Ray ray, float l) {
    vec3 edge1 = b - a;
    vec3 edge2 = c - a;
    vec3 pvec = cross(ray.unit_direction, edge2);
    float det = dot(edge1, pvec);
    float inv_det = 1.0 / det;
    if (det < BIAS) {
        return false;
    }
    vec3 tvec = ray.origin - a;
    float u = dot(tvec, pvec) * inv_det;
    if (u < BIAS || u > 1.0) {
        return false;
    }
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unit_direction, qvec) * inv_det;
    if (v < BIAS || u + v > 1.0) {
        return false;
    }
    float s = dot(edge2, qvec) * inv_det;
    return (s <= l && s > BIAS);
}

// Bounding volume intersection test
float rayBoundingVolume(vec3 min_corner, vec3 max_corner, Ray ray, float max_len) {
    vec3 inv_dir = 1.0 / ray.unit_direction;
    vec3 v0 = (min_corner - ray.origin) * inv_dir;
    vec3 v1 = (max_corner - ray.origin) * inv_dir;
    float tmin = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));
    float tmax = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));

    if (tmax >= max(tmin, BIAS) && tmin < max_len) {
        return tmin;
    } else {
        return POW32;
    }
}

// Simplified rayTracer to only test if ray intersects anything
bool shadowTraverseTriangleBVH(uint instance_index, Ray ray, float l) {
    // Maximal distance a triangle can be away from the ray origin
    uint instance_uint_offset = instance_index * INSTANCE_UINT_SIZE;

    Transform inverse_transform = access_instance_transform(instance_index * 2u + 1u);
    vec3 inverse_dir = inverse_transform.rotation * ray.unit_direction;

    Ray t_ray = Ray(
        inverse_transform.rotation * (ray.origin + inverse_transform.shift),
        normalize(inverse_dir)
    );
    float max_len = length(inverse_dir) * l;

    uint instance_bvh_offset = access_instance_uint(instance_uint_offset + 1u);
    uint instance_vertex_offset = access_instance_uint(instance_uint_offset + 2u);

    uint stack[24];
    stack[0] = 0u;
    uint stack_index = 1u;

    while (stack_index > 0u && stack_index < 24u) {
        stack_index -= 1u;
        uint node_index = stack[stack_index];

        uint bvh_offset = instance_bvh_offset + node_index * BVH_TRIANGLE_SIZE;
        uint vertex_offset = instance_vertex_offset + node_index * TRIANGLE_BOUNDING_VERTICES_SIZE;

        uvec3 indicator_and_children = access_triangle_bvh(bvh_offset).xyz;

        vec4 bv0 = access_triangle_bounding_vertices(vertex_offset);
        vec4 bv1 = access_triangle_bounding_vertices(vertex_offset + 1u);
        vec4 bv2 = access_triangle_bounding_vertices(vertex_offset + 2u);

        if (indicator_and_children.x == 0u) {
            if (moellerTrumboreCull(bv0.xyz, vec3(bv0.w, bv1.xy), vec3(bv1.zw, bv2.x), t_ray, max_len)) {
                return true;
            }

            if (indicator_and_children.z != UINT_MAX) {
                vec4 bv3 = access_triangle_bounding_vertices(vertex_offset + 3u);
                vec4 bv4 = access_triangle_bounding_vertices(vertex_offset + 4u);
                if (moellerTrumboreCull(bv2.yzw, bv3.xyz, vec3(bv3.w, bv4.xy), t_ray, max_len)) {
                    return true;
                }
            }
        } else {
            float dist0 = rayBoundingVolume(bv0.xyz, vec3(bv0.w, bv1.xy), t_ray, max_len);
            float dist1 = POW32;
            if (indicator_and_children.z != UINT_MAX) {
                dist1 = rayBoundingVolume(vec3(bv1.zw, bv2.x), bv2.yzw, t_ray, max_len);
            }

            uint near_child = dist0 < dist1 ? indicator_and_children.y : indicator_and_children.z;
            uint far_child = dist0 < dist1 ? indicator_and_children.z : indicator_and_children.y;

            if (max(dist0, dist1) != POW32) {
                stack[stack_index] = far_child;
                stack_index += 1u;
            }
            if (min(dist0, dist1) != POW32) {
                stack[stack_index] = near_child;
                stack_index += 1u;
            }
        }
    }

    // If nothing was hit, return false (not in shadow)
    return false;
}

// Simplified rayTracer to only test if ray intersects anything
bool shadowTraverseInstanceBVH(Ray ray, float l) {
    uint stack[16];
    stack[0] = 0u;
    uint stack_index = 1u;

    while (stack_index > 0u && stack_index < 16u) {
        stack_index -= 1u;
        uint node_index = stack[stack_index];

        uint bvh_offset = node_index * BVH_INSTANCE_SIZE;
        uint vertex_offset = node_index * INSTANCE_BOUNDING_VERTICES_SIZE;

        uint indicator = access_instance_bvh(bvh_offset);
        uint child0 = access_instance_bvh(bvh_offset + 1u);
        uint child1 = access_instance_bvh(bvh_offset + 2u);

        vec4 bv0 = access_instance_bounding_vertices(vertex_offset);
        vec4 bv1 = access_instance_bounding_vertices(vertex_offset + 1u);
        vec4 bv2 = access_instance_bounding_vertices(vertex_offset + 2u);

        float dist0 = POW32;
        float dist1 = POW32;
        if (child0 != UINT_MAX_M1) {
            dist0 = rayBoundingVolume(bv0.xyz, vec3(bv0.w, bv1.xy), ray, l);
        }

        if (child1 != UINT_MAX && child1 != UINT_MAX_M1) {
            dist1 = rayBoundingVolume(vec3(bv1.zw, bv2.x), bv2.yzw, ray, l);
        }

        float dist_near = min(dist0, dist1);
        float dist_far = max(dist0, dist1);
        uint near_child = dist0 < dist1 ? child0 : child1;
        uint far_child = dist0 < dist1 ? child1 : child0;

        if (indicator == 0u) {
            // If node is a triangle, test for intersection, closest first
            if (dist_near != POW32) {
                if (shadowTraverseTriangleBVH(near_child, ray, l)) {
                    return true;
                }
            }
            if (dist_far != POW32) {
                if (shadowTraverseTriangleBVH(far_child, ray, l)) {
                    return true;
                }
            }
        } else {
            // If node is an AABB, push children to stack, furthest first
            if (dist_far != POW32) {
                stack[stack_index] = far_child;
                stack_index += 1u;
            }
            if (dist_near != POW32) {
                stack[stack_index] = near_child;
                stack_index += 1u;
            }
        }
    }
    // If nothing was hit, return false (not in shadow)
    return false;
}

// Build TBN matrix for tangent-space normal mapping. Uses triangle edges and UV deltas to compute
// tangent (U direction) and bitangent (V direction), with handedness fix.
mat3 normalMapTBN(vec3 p0, vec3 p1, vec3 p2, vec2 uv0, vec2 uv1, vec2 uv2, vec3 n) {
    vec3 e1 = p1 - p0;
    vec3 e2 = p2 - p0;
    vec2 duv1 = uv1 - uv0;
    vec2 duv2 = uv2 - uv0;
    // Compute inverse determinant for UV to world space transformation.
    float det = duv1.x * duv2.y - duv1.y * duv2.x;
    float inv_det = 1.0 / det;
    vec3 t = (e1 * duv2.y - e2 * duv1.y) * inv_det;
    vec3 b_geom = (e2 * duv1.x - e1 * duv2.x) * inv_det;

    // Gram-Schmidt: make tangent perpendicular to interpolated normal.
    t = normalize(t - n * dot(n, t));
    // Handedness: ensure TBN is right-handed; flip T if geometric b disagrees with cross(n,t).
    if (dot(cross(n, t), b_geom) > 0.0) {
        t = -t;
    }
    vec3 b = cross(n, t);

    return mat3(t, b, n);
}

vec3 tangentToWorldNormalMap(vec3 v, mat3 tbn) {
    return tbn * v;
}
