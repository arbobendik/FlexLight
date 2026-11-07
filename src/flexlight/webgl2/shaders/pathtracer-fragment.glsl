
// Previous frame and count of frames it has accumulated
uniform sampler2D accumulated;
uniform float accumulation_count;

struct Intersect {
    vec2 uv;
    float dist;
};

Intersect moellerTrumbore(vec3 a, vec3 b, vec3 c, Ray ray, float l) {
    vec3 edge1 = b - a;
    vec3 edge2 = c - a;
    vec3 pvec = cross(ray.unit_direction, edge2);
    float det = dot(edge1, pvec);
    if (abs(det) < BIAS) {
        return Intersect(vec2(0.0, 0.0), 0.0);
    }
    float inv_det = 1.0 / det;
    vec3 tvec = ray.origin - a;
    float u = dot(tvec, pvec) * inv_det;
    if (u < BIAS || u > 1.0) {
        return Intersect(vec2(0.0, 0.0), 0.0);
    }
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unit_direction, qvec) * inv_det;
    float uv_sum = u + v;
    if (v < BIAS || uv_sum > 1.0) {
        return Intersect(vec2(0.0, 0.0), 0.0);
    }
    float s = dot(edge2, qvec) * inv_det;
    if (s <= l && s > BIAS) {
        return Intersect(vec2(u, v), s);
    } else {
        return Intersect(vec2(0.0, 0.0), 0.0);
    }
}

// Ray sphere intersection test.
float raySphere(vec3 center, float radius, Ray ray, float max_len) {
    vec3 L = center - ray.origin;
    float tca = dot(L, ray.unit_direction);

    float d2 = dot(L, L) - tca * tca;
    if (d2 > radius * radius) {
        return POW32;
    }

    float thc = sqrt(radius * radius - d2);
    float t0 = tca - thc;
    float t1 = tca + thc;

    if (t0 > BIAS && t0 < max_len) {
        return t0;
    }

    if (t1 > BIAS && t1 < max_len) {
        return t1;
    }

    return POW32;
}

// Test for closest ray triangle intersection
Hit traverseTriangleBVH(uint instance_index, Ray ray, float max_len) {
    // Maximal distance a triangle can be away from the ray origin
    uint instance_uint_offset = instance_index * INSTANCE_UINT_SIZE;

    Transform inverse_transform = access_instance_transform(instance_index * 2u + 1u);
    vec3 inverse_dir = inverse_transform.rotation * ray.unit_direction;
    float len_factor = length(inverse_dir);
    float len_factor_inv = 1.0 / len_factor;

    Ray t_ray = Ray(
        inverse_transform.rotation * (ray.origin + inverse_transform.shift),
        inverse_dir * len_factor_inv
    );

    uint triangle_instance_offset = access_instance_uint(instance_uint_offset);
    uint instance_bvh_offset = access_instance_uint(instance_uint_offset + 1u);
    uint instance_vertex_offset = access_instance_uint(instance_uint_offset + 2u);

    // Hit object
    // First element of vector is current closest intersection point
    Hit hit = Hit(vec2(0.0, 0.0), UINT_MAX, UINT_MAX, 0u, max_len);
    // Stack for BVH traversal
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
        vec4 bv3 = access_triangle_bounding_vertices(vertex_offset + 3u);
        vec4 bv4 = access_triangle_bounding_vertices(vertex_offset + 4u);

        if (indicator_and_children.x == 0u) {
            // Run Moeller-Trumbore algorithm for both triangles
            // Test if ray even intersects
            Intersect intersect0 = moellerTrumbore(bv0.xyz, vec3(bv0.w, bv1.xy), vec3(bv1.zw, bv2.x), t_ray, hit.dist * len_factor);
            if (intersect0.dist != 0.0) {
                // Calculate intersection point
                hit.dist = intersect0.dist * len_factor_inv;
                hit.uv = intersect0.uv;
                hit.instance_index = instance_index;
                hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.y;
            }

            if (indicator_and_children.z != UINT_MAX) {
                // Test if ray even intersects
                Intersect intersect1 = moellerTrumbore(bv2.yzw, bv3.xyz, vec3(bv3.w, bv4.xy), t_ray, hit.dist * len_factor);
                if (intersect1.dist != 0.0) {
                    // Calculate intersection point
                    hit.dist = intersect1.dist * len_factor_inv;
                    hit.uv = intersect1.uv;
                    hit.instance_index = instance_index;
                    hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.z;
                }
            }

        } else {
            float dist0 = rayBoundingVolume(bv0.xyz, vec3(bv0.w, bv1.xy), t_ray, hit.dist * len_factor);
            float dist1 = POW32;
            if (indicator_and_children.z != UINT_MAX) {
                dist1 = rayBoundingVolume(vec3(bv1.zw, bv2.x), bv2.yzw, t_ray, hit.dist * len_factor);
            }

            uint near_child = dist0 < dist1 ? indicator_and_children.y : indicator_and_children.z;
            uint far_child = dist0 < dist1 ? indicator_and_children.z : indicator_and_children.y;

            // If node is an AABB, push children to stack, furthest first
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
    // Return hit object
    return hit;
}

// Find closest intersection with instances and optionally point lights
Hit traverseInstanceBVH(Ray ray, bool consider_point_lights) {
    // Hit object
    // Maximal distance a triangle can be away from the ray origin is POW32 at initialisation
    Hit hit = Hit(vec2(0.0, 0.0), UINT_MAX, UINT_MAX, 0u, POW32);
    // Stack for BVH traversal
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
        if (child0 == UINT_MAX_M1 && consider_point_lights) {
            // Child 0 is a point light
            float light_dist = raySphere(bv0.xyz, bv0.w, ray, hit.dist);
            if (light_dist != POW32) {
                hit.dist = light_dist;
                hit.is_point_light = 1u;
                hit.instance_index = uint(bv1.y);
            }
        } else if (child0 != UINT_MAX_M1) {
            // Child 0 is an instance
            dist0 = rayBoundingVolume(bv0.xyz, vec3(bv0.w, bv1.xy), ray, hit.dist);
        }

        if (child1 == UINT_MAX_M1 && consider_point_lights) {
            // Child 1 is a point light
            float light_dist = raySphere(vec3(bv1.zw, bv2.x), bv2.y, ray, hit.dist);
            if (light_dist != POW32) {
                hit.dist = light_dist;
                hit.is_point_light = 1u;
                hit.instance_index = uint(bv2.w);
            }
        } else if (child0 != UINT_MAX && child1 != UINT_MAX_M1) {
            // Child 1 is an instance
            dist1 = rayBoundingVolume(vec3(bv1.zw, bv2.x), bv2.yzw, ray, hit.dist);
        }

        float dist_near = min(dist0, dist1);
        float dist_far = max(dist0, dist1);
        uint near_child = dist0 < dist1 ? child0 : child1;
        uint far_child = dist0 < dist1 ? child1 : child0;

        if (indicator == 0u) {
            // If node is an instance, test for intersection, closest first
            if (dist_near != POW32) {
                Hit new_hit = traverseTriangleBVH(near_child, ray, hit.dist);
                if (new_hit.dist < hit.dist) {
                    hit = new_hit;
                }
            }
            if (dist_far != POW32 && dist_far < hit.dist) {
                Hit new_hit = traverseTriangleBVH(far_child, ray, hit.dist);
                if (new_hit.dist < hit.dist) {
                    hit = new_hit;
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
    // Return hit object
    return hit;
}

// Blender's default tangent at the point p of the instance's prototype, as the WebGPU path tracer's radialTangent: radial
// about z through the middle of the prototype's bounds, those of its BVH's root, two triangles or two boxes
vec3 radialTangent(uint instance_index, vec3 p) {
    uint instance_uint_offset = instance_index * INSTANCE_UINT_SIZE;
    uvec3 root = access_triangle_bvh(access_instance_uint(instance_uint_offset + 1u)).xyz;
    uint vertex_offset = access_instance_uint(instance_uint_offset + 2u);
    vec4 bv0 = access_triangle_bounding_vertices(vertex_offset);
    vec4 bv1 = access_triangle_bounding_vertices(vertex_offset + 1u);
    vec4 bv2 = access_triangle_bounding_vertices(vertex_offset + 2u);
    vec4 bv3 = access_triangle_bounding_vertices(vertex_offset + 3u);
    vec4 bv4 = access_triangle_bounding_vertices(vertex_offset + 4u);
    // A box's two corners or a triangle's first two vertices, its third, then the second box or triangle
    vec3 low = min(bv0.xyz, vec3(bv0.w, bv1.xy));
    vec3 high = max(bv0.xyz, vec3(bv0.w, bv1.xy));
    if (root.x == 0u) low = min(low, vec3(bv1.zw, bv2.x)), high = max(high, vec3(bv1.zw, bv2.x));
    if (root.z != UINT_MAX && root.x == 0u) {
        low = min(low, min(bv2.yzw, min(bv3.xyz, vec3(bv3.w, bv4.xy))));
        high = max(high, max(bv2.yzw, max(bv3.xyz, vec3(bv3.w, bv4.xy))));
    } else if (root.z != UINT_MAX) {
        low = min(low, vec3(bv1.zw, bv2.x));
        high = max(high, bv2.yzw);
    }
    // A flat side's generated coordinate is its middle, as Blender's
    vec3 g = mix(vec3(0.5), (p - low) / (high - low), greaterThan(high, low));
    return vec3(0.5 - g.y, g.x - 0.5, 0.0);
}

struct SampledColor {
    vec3 color;
    uint random_state;
};

SampledColor reservoirSample(Material material, float eta_i, float eta_o, Ray camera_ray, uint init_random_state, vec3 smooth_n, vec3 geometry_n, float geometry_offset, vec3 light_offset_dir) {
    uint m = light_count + 1u;
    // If no lights, return emissive color
    if (m <= 1u) {
        return SampledColor(vec3(0.0), init_random_state);
    }

    float w_sum = 0.0;
    vec3 reservoir_color = vec3(0.0);
    vec3 reservoir_dir = vec3(0.0);
    uvec2 reservoir_target = uvec2(UINT_MAX);
    uint random_state = init_random_state;
    // Iterate over lights
    for (uint i = 0u; i < light_count; i++) {
        // Read light from storage buffer
        Light light = access_light(i + 1u);

        vec3 light_position = vec3(0.0);
        vec3 dir = vec3(0.0);
        vec3 light_offset = vec3(0.0);
        float intensity = 0.0;
        uvec2 target = uvec2(UINT_MAX);
        // Handle if light is an area light
        if (light.is_area_light == 1.0) {
            // CASE 0: Area ligh
            uint instance_id = uint(light.position.x);
            float triangle_count = light.position.y;

            Random random_triangle = pcg(random_state);
            random_state = random_triangle.state;

            uint triangle_instance_offset = access_instance_uint(instance_id * INSTANCE_UINT_SIZE);

            // Choose random triangle from instance
            target = uvec2(instance_id, uint(random_triangle.value * triangle_count));
            uint triangle_offset = triangle_instance_offset + target.y * TRIANGLE_SIZE;
            // Fetch triangle coordinates from scene graph texture
            vec4 t0 = access_triangle(triangle_offset);
            vec4 t1 = access_triangle(triangle_offset + 1u);
            vec4 t2 = access_triangle(triangle_offset + 2u);
            vec4 t3 = access_triangle(triangle_offset + 3u);
            vec4 t4 = access_triangle(triangle_offset + 4u);

            // Fetch triangle coordinates from scene graph texture
            Transform transform = access_instance_transform(instance_id * 2u);
            // Assemble and transform triangle with shift.
            mat3 t = transform.rotation * mat3(t0.xyz, vec3(t0.w, t1.xy), vec3(t1.zw, t2.x)) + mat3(transform.shift, transform.shift, transform.shift);

            // Assemble and transform normals
            // Normals by the inverse transpose of the instance's matrix, which keeps them normal under a scale that is not uniform
            mat3 normals = transpose(access_instance_transform(instance_id * 2u + 1u).rotation) * mat3(t2.yzw, t3.xyz, vec3(t3.w, t4.xy));
            // Compute edge vectors
            vec3 edge1 = t[1] - t[0];
            vec3 edge2 = t[2] - t[0];
            vec3 edge3 = t[2] - t[1];

            float min_edge_length = min(length(edge1), min(length(edge2), length(edge3)));

            vec3 light_geometry_n = normalize(cross(edge1, edge2));
            vec3 diffs = vec3(
                distance(camera_ray.origin, t[0]),
                distance(camera_ray.origin, t[1]),
                distance(camera_ray.origin, t[2])
            );
            // Choose random barycentric coordinates
            Random random_value_0 = pcg(random_state);
            Random random_value_1 = pcg(random_value_0.state);
            random_state = random_value_1.state;

            vec2 u = vec2(random_value_0.value, random_value_1.value);
            if (u.x + u.y > 1.0) {
                u = vec2(1.0 - u.x, 1.0 - u.y);
            }
            vec3 geometry_uvw = vec3(1.0 - u.x - u.y, u.x, u.y);
            // Interpolate smooth normal
            vec3 light_smooth_n = normalize(normals * geometry_uvw);
            // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
            vec3 angles = acos(abs(vec3(
                dot(light_geometry_n, normalize(normals[0])),
                dot(light_geometry_n, normalize(normals[1])),
                dot(light_geometry_n, normalize(normals[2]))
            )));
            // Limit angles to 45 degrees
            vec3 angle_tan = clamp(tan(angles), vec3(0.0), vec3(PI * 0.25));
            // Keep geometry offset within reasonable range
            float light_geometry_offset = clamp(dot(diffs * angle_tan, geometry_uvw), 0.0, min_edge_length * 0.5);
            // Interpolate point on triangle
            light_position = t * geometry_uvw;
            // Calculate normal
            vec3 edge_cross = cross(edge1, edge2);
            float light_area = max(length(edge_cross) * 0.5, BIAS);

            // Calculate light direction
            dir = light_position - camera_ray.origin;
            // Outgoing angle at light source
            float light_n_dot_ml = max(dot(light_smooth_n, - normalize(dir)), 0.0);
            // Offset light position to avoid self shadowing
            light_offset = light_smooth_n * light_geometry_offset;
            // Calculate intensity with respect to sampling probability of triangle and point on triangle
            intensity = light_area * triangle_count * light_n_dot_ml;
        } else if (light.is_area_light == 0.0) {
            // CASE 1: Point light
            // Yeild random vector in sphere to simulate point light volume and update state
            light_position = light.position + light_offset_dir * light.variance;
            // Calculate light direction
            dir = light_position - camera_ray.origin;
            light_offset = vec3(0.0);
            intensity = light.intensity;
        }

        float len = length(dir);
        vec3 l = dir / len;
        // Apply inverse square law
        vec3 brightness = light.color * intensity / max(len * len, BIAS);
        // Calculate BSDF for light, its visible normal from a stream of its own, apart from the selection's numbers
        vec3 color_with_smooth = TRANSLUCENT ? translucentBSDF(camera_ray.unit_direction, l, smooth_n, geometry_n, material, eta_i, eta_o, stream(random_state, 1u)) : BSDF(camera_ray.unit_direction, l, smooth_n, geometry_n, material, eta_i, eta_o, stream(random_state, 1u));
        vec3 color_for_light = color_with_smooth * brightness;
        float w_i = rgb_to_greyscale(color_for_light);
        // Skip light if its contribution is too small
        if (w_i <= BIAS) {
            continue;
        }

        w_sum += w_i;
        // Yeild random value between 0 and 1 and update state
        Random random_value = pcg(random_state);
        random_state = random_value.state;
        if (random_value.value * w_sum <= w_i) {
            reservoir_color = color_for_light / w_i;
            reservoir_dir = dir + light_offset;
            reservoir_target = target;
        }
    }

    // Translucent surfaces see light all around, the shadow ray lifted to the side of the face the light lies on
    vec3 lift_n = rgb_to_greyscale(material.translucent) > 0.0 ? smooth_n * sign(dot(geometry_n, reservoir_dir)) : smooth_n;
    // Compute quick exit criterion to potentially skip expensive shadow test, behind the normal seen from the surface, as the
    // BSDF weighs the light: seen from the lifted start, it would drop those lying less than the lift above its tangent plane
    bool show_shadow = w_sum == 0.0 || dot(lift_n, reservoir_dir) < 0.0;
    // Test if in shadow
    if (show_shadow) {
        return SampledColor(vec3(0.0), random_state);
    }
    // Apply geometry offset
    vec3 offset_target = camera_ray.origin + geometry_offset * lift_n;
    vec3 shadow = camera_ray.origin + reservoir_dir - offset_target;
    Ray light_ray = Ray(offset_target, normalize(shadow));

    if (shadowTraverseInstanceBVH(light_ray, length(shadow), true, reservoir_target)) {
        return SampledColor(vec3(0.0), random_state);
    } else {
        return SampledColor(reservoir_color * w_sum, random_state);
    }
}

vec3 calculatePointLightContrib(uint point_light_index) {
    Light point_light = access_light(point_light_index);
    return pointLightRadiance(point_light.color, point_light.intensity, point_light.variance);
}

vec3 env_map_sample(vec3 dir) {
    float len = sqrt(dir.x * dir.x + dir.z * dir.z);
    float s = acos(dir.x / len);
    if (dir.z < 0.0) {
        s = 2.0 * PI - s;
    }

    s = s / (2.0 * PI);
    vec2 tex_coord = vec2(s, ((asin(dir.y) * -2.0 / PI) + 1.0) * 0.5);
    return textureLod(environment_map, tex_coord, 0.0).xyz * 255.0;
}

SampledColor lightTrace(Hit init_hit, vec3 origin, vec3 camera, uint init_random_state) {
    // Use additive color mixing technique, so start with black
    vec3 final_color = vec3(0.0);
    vec3 importancy_factor = vec3(1.0);
    Hit hit = init_hit;
    Ray ray = Ray(origin, normalize(origin - camera));
    uint random_state = init_random_state;
    bool add_ambient = false;
    bool is_inside = false;
    uint i = 0u;
    // Precalculate random sphere
    RandomSphere light_offset_sphere = random_sphere(random_state);
    vec3 light_offset_dir = light_offset_sphere.value;

    random_state = light_offset_sphere.state;
    bool direct_light_emission = true;
    // Iterate over each bounce and modify color accordingly
    while (true) {
        float geometry_offset = 0.0;
        vec3 smooth_n = vec3(0.0);
        bool skip_hit = false;
        bool point_light_lighting = hit.is_point_light == 1u && direct_light_emission;
        bool current_direct_light_emission = direct_light_emission;

        if (!point_light_lighting) {
            uint triangle_offset = hit.triangle_index * TRIANGLE_SIZE;
            // Fetch triangle coordinates from scene graph texture
            vec4 t0 = access_triangle(triangle_offset);
            vec4 t1 = access_triangle(triangle_offset + 1u);
            vec4 t2 = access_triangle(triangle_offset + 2u);
            vec4 t3 = access_triangle(triangle_offset + 3u);
            vec4 t4 = access_triangle(triangle_offset + 4u);
            vec4 t5 = access_triangle(triangle_offset + 5u);
            // Fetch triangle coordinates from scene graph texture
            Transform transform = access_instance_transform(hit.instance_index * 2u);
            // Assemble and transform triangle
            mat3 t = transform.rotation * mat3(t0.xyz, vec3(t0.w, t1.xy), vec3(t1.zw, t2.x));
            // Assemble and transform normals
            // Normals by the inverse transpose of the instance's matrix, which keeps them normal under a scale that is not uniform
            mat3 normals = transpose(access_instance_transform(hit.instance_index * 2u + 1u).rotation) * mat3(t2.yzw, t3.xyz, vec3(t3.w, t4.xy));
            vec3 offset_ray_target = ray.origin - transform.shift;
            // Compute edge vectors
            vec3 edge1 = t[1] - t[0];
            vec3 edge2 = t[2] - t[0];
            vec3 edge3 = t[2] - t[1];

            float min_edge_length = min(length(edge1), min(length(edge2), length(edge3)));

            vec3 geometry_n = normalize(cross(edge1, edge2));
            vec3 diffs = vec3(
                distance(offset_ray_target, t[0]),
                distance(offset_ray_target, t[1]),
                distance(offset_ray_target, t[2])
            );
            // Calculate barycentric coordinates
            vec3 geometry_uvw = vec3(1.0 - hit.uv.x - hit.uv.y, hit.uv.x, hit.uv.y);
            // Interpolate smooth normal
            smooth_n = normalize(normals * geometry_uvw);
            // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry
            vec3 angles = acos(abs(vec3(
                dot(geometry_n, normalize(normals[0])),
                dot(geometry_n, normalize(normals[1])),
                dot(geometry_n, normalize(normals[2]))
            )));
            // Limit angles to 45 degrees
            vec3 angle_tan = clamp(tan(angles), vec3(0.0), vec3(PI * 0.25));
            // Keep geometry offset within reasonable range
            geometry_offset = clamp(dot(diffs * angle_tan, geometry_uvw), 0.0, min_edge_length * 0.125);
            // Interpolate final barycentric texture coordinates between UV's of the respective vertices
            vec2 barycentric = fract(mat3x2(t4.zw, t5.xy, t5.zw) * geometry_uvw);
            // Sample material
            Material material = access_instance_material(hit.instance_index);
            // Anisotropic materials' tangent, Blender's default in its object, transformed into the world as a normal, or
            // the UV map's, the triangle's made normal to the smooth normal
            if (material.anisotropy != 0.0 && material.tangent_source != 0.0) {
                material.tangent = normalMapTBN(t[0], t[1], t[2], t4.zw, t5.xy, t5.zw, smooth_n)[0];
            } else if (material.anisotropy != 0.0) {
                material.tangent = transpose(access_instance_transform(hit.instance_index * 2u + 1u).rotation)
                    * radialTangent(hit.instance_index, mat3(t0.xyz, vec3(t0.w, t1.xy), vec3(t1.zw, t2.x)) * geometry_uvw);
            }
            // If the ray is inside a medium, apply Beer's law for absorption.
            if (is_inside) {
                // The amount of light transmitted is T = exp(-sigma_a * d).
                vec3 absorption_coefficient = max(material.absorption, vec3(BIAS));
                vec3 transmittance = exp(hit.dist * log(absorption_coefficient));
                importancy_factor *= transmittance;
            }

            uint hit_instance_location = hit.instance_index * INSTANCE_UINT_SIZE;
            // Read material textures
            uint albedo_texture_id = access_instance_uint(hit_instance_location + 3u);
            if (albedo_texture_id != UINT_MAX) {
                vec4 albedo_data = textureSample(albedo_texture_id, barycentric) * INV_255;
                material.albedo = albedo_data.xyz;
                // Enable transparent textures
                // Yeild random value between 0 and 1 and update state
                Random transparancy_random_value = pcg(random_state);
                random_state = transparancy_random_value.state;
                if (1.0 - albedo_data.w > transparancy_random_value.value) {
                    skip_hit = true;
                }
            }

            if (!skip_hit) {
                uint normal_texture_id = access_instance_uint(hit_instance_location + 4u);
                if (normal_texture_id != UINT_MAX) {
                    vec2 uv0 = t4.zw;
                    vec2 uv1 = t5.xy;
                    vec2 uv2 = t5.zw;
                    mat3 tbn = normalMapTBN(t[0], t[1], t[2], uv0, uv1, uv2, smooth_n);
                    vec3 normal_data = normalize(textureSample(normal_texture_id, barycentric).xyz * INV_255 * 2.0 - 1.0);
                    normal_data.y = -normal_data.y;
                    smooth_n = normalize(tangentToWorldNormalMap(normal_data, tbn));
                }

                uint emissive_texture_id = access_instance_uint(hit_instance_location + 5u);
                if (emissive_texture_id != UINT_MAX) {
                    material.emissive = textureSample(emissive_texture_id, barycentric).xyz * INV_255;
                }

                uint roughness_texture_id = access_instance_uint(hit_instance_location + 6u);
                if (roughness_texture_id != UINT_MAX) {
                    material.roughness = textureSample(roughness_texture_id, barycentric).x * INV_255;
                }

                uint metallic_texture_id = access_instance_uint(hit_instance_location + 7u);
                if (metallic_texture_id != UINT_MAX) {
                    material.metallic = textureSample(metallic_texture_id, barycentric).x * INV_255;
                }
                // Determine local color considering PBR attributes and lighting
                // Hybrid method
                if (current_direct_light_emission) {
                    final_color += material.emissive * importancy_factor * max(sign(dot(- ray.unit_direction, smooth_n)), 0.0);
                    direct_light_emission = false;
                }
                // Surfaces transmitting nothing face the ray with both normals once they emitted, as in flex-cuda-pt's walk and Cycles
                float facing = material.transmission > 0.0 || dot(geometry_n, ray.unit_direction) < 0.0 ? 1.0 : -1.0;
                smooth_n *= facing;
                geometry_n *= facing;

                float n_dot_v = dot(smooth_n, - ray.unit_direction);
                bool is_entering = n_dot_v < 0.0;
                // Incident side is air, outgoing side is material (entering)
                float eta_i = is_entering ? material.ior : 1.0;
                // Incident side is material, outgoing side is air (exiting)
                float eta_o = is_entering ? 1.0 : material.ior;
                // Calculate fresnel term
                vec3 F_n = mix(vec3(fresnel(abs(n_dot_v), eta_i, eta_o)), material.albedo, material.metallic);
                float F_n_greyscale = rgb_to_greyscale(F_n);

                float diffuse_factor_estimate = max((1.0 - F_n_greyscale) * (1.0 - material.metallic) * (1.0 - material.transmission), 0.0);
                if (diffuse_factor_estimate > 0.04 || material.roughness > 0.2) {
                    // Do NEE
                    SampledColor local_sampled = reservoirSample(material, eta_i, eta_o, ray, random_state, smooth_n, geometry_n, geometry_offset, light_offset_dir);
                    random_state = local_sampled.random_state;
                    final_color += local_sampled.color * importancy_factor;
                } else {
                    // Sample directly next round
                    direct_light_emission = true;
                }
                // Attempt ray bounce with material normal first
                SampleBSDF bsdf_sampled = sampleBSDF(ray.unit_direction, smooth_n, material, eta_i, eta_o, random_state, vec2(0.0));
                random_state = bsdf_sampled.random_state;
                // Meassure if outgoing ray points towards incorrect side of the sphere.
                bool expected_out_dir_normal_aligned = (!is_inside && !bsdf_sampled.refracted) || (is_inside && bsdf_sampled.refracted);
                bool out_dir_normal_aligned = dot(bsdf_sampled.unit_direction, geometry_n) > 0.0;
                // Rays sampled to the wrong side of the face lose no energy there: surfaces transmitting light sample again
                // against the geometry normal, opaque ones mirror the ray into their side by it
                if (expected_out_dir_normal_aligned != out_dir_normal_aligned) {
                    // Light sampling covers no direction it reaches, so the emission it meets counts in full
                    direct_light_emission = true;
                    if (material.transmission > 0.0) {
                        // Continue ray bounce and pretend the self reflection faces according to the geometry normal, making incorrect bounces impossible.
                        SampleBSDF geometry_bsdf_sampled = sampleBSDF(bsdf_sampled.unit_direction, geometry_n, material, eta_i, eta_o, random_state, vec2(0.0));
                        random_state = geometry_bsdf_sampled.random_state;
                        // Redirect outgoing ray according to new bsdf sample.
                        bsdf_sampled.unit_direction = geometry_bsdf_sampled.unit_direction;
                        bsdf_sampled.refracted = geometry_bsdf_sampled.refracted;
                        bsdf_sampled.lobe = geometry_bsdf_sampled.lobe;
                        // Multiply to compute combined throughput, doing proper self shadowing.
                        bsdf_sampled.throughput = geometry_bsdf_sampled.throughput;
                    } else {
                        bsdf_sampled.unit_direction -= 2.0 * dot(bsdf_sampled.unit_direction, geometry_n) * geometry_n;
                    }
                }
                // If the scattered ray is on the opposite side of the surface, we have entered or exited the medium.
                // Translucent surfaces are thin: the diffuse lobe leaves through to the other side of the face, into no medium
                bool through = bsdf_sampled.lobe == 0u && rgb_to_greyscale(material.translucent) > 0.0 && dot(bsdf_sampled.unit_direction, geometry_n) < 0.0;
                if (bsdf_sampled.refracted && !through) {
                    is_inside = !is_inside;
                }

                ray.unit_direction = bsdf_sampled.unit_direction;
                importancy_factor *= max(bsdf_sampled.throughput, vec3(0.0));

                vec3 out_dir_aligned_normal = is_inside != through ? - smooth_n : smooth_n;
                ray.origin += geometry_offset * out_dir_aligned_normal;
            }
        }

        float survival_probability = 1.0;
        if (!skip_hit) {
            survival_probability = clamp(max(importancy_factor.x, max(importancy_factor.y, importancy_factor.z)), 0.0, 1.0);
        }

        Random random_value = pcg(random_state);
        random_state = random_value.state;
        // Test for early termination, avoiding last bounce
        if (survival_probability < random_value.value || i >= max_bounces) {
            add_ambient = false;
            break;
        }
        // Continue with next bounce
        importancy_factor /= survival_probability;

        if (point_light_lighting && !skip_hit) {
            final_color += importancy_factor * calculatePointLightContrib(hit.instance_index);
            direct_light_emission = false;
        }
        // Increment hit iterator
        i = i + 1u;
        // Calculate next intersection
        hit = traverseInstanceBVH(ray, direct_light_emission);
        // Stop loop if there is no intersection and ray goes in the void
        if (hit.instance_index == UINT_MAX) {
            add_ambient = true;
            break;
        }
        // Project ray origin to hit point
        ray.origin += hit.dist * ray.unit_direction;
    }
    // Sample environment map if present
    if (add_ambient) {
        if (environment_map_size.x > 1u && environment_map_size.y > 1u) {
            final_color += importancy_factor * env_map_sample(ray.unit_direction);
        } else {
            // If no environment map is present, use ambient color
            final_color += importancy_factor * ambient;
        }
    }
    // Return final pixel color
    return SampledColor(final_color, random_state);
}

void main() {
    // Get texel position of screen
    ivec2 screen_pos = ivec2(gl_FragCoord.xy);
    // Row counted from the top, like the screen position of the WebGPU compute shader
    uint row = render_size.y - 1u - uint(screen_pos.y);
    // Subtract 1 to have 0 as invalid index
    uvec4 offset = texelFetch(texture_offset, screen_pos, 0);
    uint instance_index = offset.x - 1u;
    uint triangle_index = offset.y - 1u;

    vec2 screen_space = vec2(float(screen_pos.x), float(row)) / vec2(render_size) * vec2(2.0, -2.0) + vec2(-1.0, 1.0);
    vec3 view_direction = normalize(inv_view_matrix * vec3(screen_space, 1.0));

    vec3 final_color = vec3(0.0);
    if (instance_index == UINT_MAX && triangle_index == UINT_MAX) {
        if (environment_map_size.x > 1u && environment_map_size.y > 1u) {
            final_color = env_map_sample(view_direction);
        } else {
            // If no environment map is present, use ambient color
            final_color = ambient;
        }
    } else {
        vec3 absolute_position = texelFetch(texture_absolute_position, screen_pos, 0).xyz;
        vec2 uv = uintBitsToFloat(offset.zw);
        vec3 uvw = vec3(uv, 1.0 - uv.x - uv.y);
        // Generate hit struct for pathtracer
        Hit init_hit = Hit(uvw.yz, instance_index, triangle_index, 0u, distance(absolute_position, camera_position));
        // Init random state
        uint random_state = stream(hash(frame), uint(screen_pos.x) + render_size.x * row);
        // Generate multiple samples
        for (uint i = 0u; i < samples; i++) {
            SampledColor sampled_color = lightTrace(init_hit, absolute_position, camera_position, random_state);
            random_state = sampled_color.random_state;
            final_color += sampled_color.color;
        }
        // Average ray colors over samples.
        final_color *= 1.0 / float(samples);
        // Clamp color to 16 bit float
        // Maximal representable number in f16 is 65520
        final_color = clamp(final_color, vec3(0.0), vec3(65519.0));
    }
    // Average with previous frames while camera is still, skip read on reset to not carry over invalid values
    if (accumulation_count > 0.0) {
        final_color = mix(texelFetch(accumulated, screen_pos, 0).xyz, final_color, 1.0 / (accumulation_count + 1.0));
    }
    render_out = vec4(final_color, 1.0);
}
