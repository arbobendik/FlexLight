struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

struct Domain
{
     x0 : vec3<f32>,
     x1 : vec3<f32>,
     hit : Hit,
};

struct Reservoir
{
     seed : u32,
     path : u32,
     w : f32,
     c : f32,
     f : vec3<f32>,
     jac : f32,
     rc : vec4<u32>,
     dir : vec3<f32>,
     radiance : vec3<f32>,
};

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Reservoir_x24init_0( seed_0 : u32,  path_0 : u32,  w_0 : f32,  c_0 : f32,  f_0 : vec3<f32>,  jac_0 : f32,  rc_0 : vec4<u32>,  dir_0 : vec3<f32>,  radiance_0 : vec3<f32>) -> Reservoir
{
    var _S1 : Reservoir;
    _S1.seed = seed_0;
    _S1.path = path_0;
    _S1.w = w_0;
    _S1.c = c_0;
    _S1.f = f_0;
    _S1.jac = jac_0;
    _S1.rc = rc_0;
    _S1.dir = dir_0;
    _S1.radiance = radiance_0;
    return _S1;
}

fn Selection_x24init_0( r_0 : Reservoir,  w_sum_0 : f32,  color_0 : vec3<f32>,  random_state_0 : u32) -> Selection
{
    var _S2 : Selection;
    _S2.r = r_0;
    _S2.w_sum = w_sum_0;
    _S2.color = color_0;
    _S2.random_state = random_state_0;
    return _S2;
}

fn Shift_x24init_0( f_1 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S3 : Shift;
    _S3.f = f_1;
    _S3.jac = jac_1;
    return _S3;
}

fn Hit_x24init_0( uv_0 : vec2<f32>,  instance_index_0 : u32,  triangle_index_0 : u32,  is_point_light_0 : u32,  distance_0 : f32) -> Hit
{
    var _S4 : Hit;
    _S4.uv = uv_0;
    _S4.instance_index = instance_index_0;
    _S4.triangle_index = triangle_index_0;
    _S4.is_point_light = is_point_light_0;
    _S4.distance = distance_0;
    return _S4;
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S5 : Ray;
    _S5.origin = origin_0;
    _S5.unit_direction = unit_direction_0;
    return _S5;
}

struct NEEVertex
{
     none : bool,
     pdf : f32,
     origin : vec3<f32>,
     smooth_n : vec3<f32>,
     start : vec3<f32>,
};

fn NEEVertex_x24init_0( none_0 : bool,  pdf_0 : f32,  origin_1 : vec3<f32>,  smooth_n_0 : vec3<f32>,  start_0 : vec3<f32>) -> NEEVertex
{
    var _S6 : NEEVertex;
    _S6.none = none_0;
    _S6.pdf = pdf_0;
    _S6.origin = origin_1;
    _S6.smooth_n = smooth_n_0;
    _S6.start = start_0;
    return _S6;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_0 : u32,  pdf_1 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S7 : Vertex;
    _S7.rough = rough_0;
    _S7.lobe = lobe_0;
    _S7.pdf = pdf_1;
    _S7.cos = cos_0;
    _S7.inside = inside_0;
    return _S7;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_0 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_0 : vec3<f32>,  velvet_0 : f32) -> Material
{
    var _S8 : Material;
    _S8.albedo = albedo_0;
    _S8.emissive = emissive_0;
    _S8.roughness = roughness_0;
    _S8.metallic = metallic_0;
    _S8.transmission = transmission_0;
    _S8.ior = ior_0;
    _S8.absorption = absorption_0;
    _S8.specular_tint = specular_tint_0;
    _S8.specular_level = specular_level_0;
    _S8.translucent = translucent_0;
    _S8.sheen = sheen_0;
    _S8.sheen_roughness = sheen_roughness_0;
    _S8.anisotropy = anisotropy_0;
    _S8.anisotropic_rotation = anisotropic_rotation_0;
    _S8.tangent = tangent_0;
    _S8.velvet = velvet_0;
    return _S8;
}

fn Surface_x24init_0( smooth_n_1 : vec3<f32>,  geometry_n_0 : vec3<f32>,  geometry_offset_0 : f32,  material_0 : Material,  skip_0 : bool,  random_state_1 : u32) -> Surface
{
    var _S9 : Surface;
    _S9.smooth_n = smooth_n_1;
    _S9.geometry_n = geometry_n_0;
    _S9.geometry_offset = geometry_offset_0;
    _S9.material = material_0;
    _S9.skip = skip_0;
    _S9.random_state = random_state_1;
    return _S9;
}

fn hash( x_0 : u32) -> u32
{
    var _S10 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S11 : u32 = ((((_S10 >> ((((_S10 >> (u32(28)))) + u32(4))))) ^ (_S10))) * u32(277803737);
    return (((_S11 >> (u32(22)))) ^ (_S11));
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S12 : u32 = hash(index_0);
    var _S13 : u32 = hash((seed_1 ^ (_S12)));
    return _S13;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S14 : bool = transmission_1 > 0.0f;
    var _S15 : bool;
    if(_S14)
    {
        _S15 = true;
    }
    else
    {
        _S15 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S16 : f32 = select(-1.0f, 1.0f, _S15);
    return _S16;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S17 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S18 : vec3<f32> = vec3<f32>(_S17);
    return Surface_x24init_0(surface_0.smooth_n * _S18, surface_0.geometry_n * _S18, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S19 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S19));
}

fn vertexEta( material_1 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S20 : bool = n_dot_v_0 < 0.0f;
    var _S21 : f32 = select(1.0f, material_1.ior, _S20);
    var _S22 : f32 = select(material_1.ior, 1.0f, _S20);
    return vec2<f32>(_S21, _S22);
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S23 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S24 : f32 = eta_i_0 / eta_o_0 * _S23;
    var _S25 : bool = _S24 < 1.0f;
    var kr_0 : f32;
    if(_S25)
    {
        var _S26 : f32 = sqrt(max(0.0f, 1.0f - _S24 * _S24));
        var _S27 : bool = eta_i_0 == eta_o_0;
        var _S28 : f32 = select(_S26, cos_theta_0, _S27);
        var _S29 : f32 = eta_o_0 * cos_theta_0;
        var _S30 : f32 = eta_i_0 * _S28;
        var _S31 : f32 = (_S29 - _S30) / (_S29 + _S30);
        var _S32 : f32 = eta_i_0 * cos_theta_0;
        var _S33 : f32 = eta_o_0 * _S28;
        var _S34 : f32 = (_S32 - _S33) / (_S32 + _S33);
        var _S35 : f32 = (_S31 * _S31 + _S34 * _S34) / 2.0f;
        kr_0 = _S35;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn neeDecision( material_2 : Material,  n_dot_v_1 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> bool
{
    var _S36 : f32 = fresnel(abs(n_dot_v_1), eta_i_1, eta_o_1);
    var _S37 : vec3<f32> = (mix((vec3<f32>(_S36)), (material_2.albedo), (material_2.metallic)));
    var _S38 : f32 = rgb_to_greyscale(_S37);
    var _S39 : f32 = max((1.0f - _S38) * (1.0f - material_2.metallic) * (1.0f - material_2.transmission), 0.0f);
    var _S40 : bool = _S39 > 0.03999999910593033f;
    var _S41 : bool;
    if(_S40)
    {
        _S41 = true;
    }
    else
    {
        _S41 = (material_2.roughness) > 0.20000000298023224f;
    }
    return _S41;
}

fn isTranslucent_0( material_3 : Material) -> bool
{
    var _S42 : f32 = rgb_to_greyscale(material_3.translucent);
    return _S42 > 0.0f;
}

fn emitted_0( emissive_1 : vec3<f32>,  dir_2 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    var _S43 : f32 = (sign((dot((vec3<f32>(0) - dir_2), n_0))));
    var _S44 : vec3<f32> = emissive_1 * vec3<f32>(max(_S43, 0.0f));
    var _S45 : bool = ((false));
    var _S46 : vec3<f32> = select(_S44, emissive_1, _S45);
    return _S46;
}

struct LightBounds
{
     low : vec3<f32>,
     high : vec3<f32>,
     w : vec3<f32>,
     phi : f32,
     cos_theta_o : f32,
};

fn sine( c_1 : f32) -> f32
{
    return sqrt(max(1.0f - c_1 * c_1, 0.0f));
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S47 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S48 : bool = cos_a_0 > cos_b_0;
    var _S49 : f32 = select(_S47, 1.0f, _S48);
    return _S49;
}

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S50 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S51 : vec3<f32> = node_0.high - node_0.low;
    var _S52 : vec3<f32> = p_0 - _S50;
    var _S53 : vec3<f32> = (normalize((_S52)));
    var _S54 : f32 = dot(_S52, _S52);
    var _S55 : f32 = dot(_S51, _S51) / 4.0f;
    var _S56 : f32 = abs(dot(node_0.w, _S53));
    var _S57 : f32 = sine(node_0.cos_theta_o);
    var _S58 : f32 = sqrt(max(1.0f - _S55 / _S54, 0.0f));
    var _S59 : bool = _S54 < _S55;
    var _S60 : f32 = select(_S58, -1.0f, _S59);
    var _S61 : f32 = sine(_S60);
    var _S62 : f32 = sine(_S56);
    var _S63 : f32 = cosSubClamped(_S62, _S56, _S57, node_0.cos_theta_o);
    var _S64 : f32 = sine(_S56);
    var _S65 : f32 = _S64 * node_0.cos_theta_o - _S56 * _S57;
    var _S66 : bool = _S56 > (node_0.cos_theta_o);
    var _S67 : f32 = select(_S65, 0.0f, _S66);
    var _S68 : f32 = cosSubClamped(_S67, _S63, _S61, _S60);
    var _S69 : bool = _S68 <= 0.0f;
    if(_S69)
    {
        return 0.0f;
    }
    var _S70 : f32 = - dot(_S53, normal_0);
    var _S71 : f32 = node_0.phi * _S68 / max(_S54, length(_S51) / 2.0f);
    var _S72 : f32 = sine(_S70);
    var _S73 : f32 = cosSubClamped(_S72, _S70, _S61, _S60);
    var _S74 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S75 : f32 = select(_S73, 1.0f, _S74);
    return max(_S71 * _S75, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S76 : f32 = importance(first_0, p_1, normal_1);
    var _S77 : f32 = importance(second_0, p_1, normal_1);
    var _S78 : vec2<f32> = vec2<f32>(_S76, _S77);
    var _S79 : f32 = _S78[child_0] / (_S76 + _S77);
    var _S80 : bool = (_S78[child_0]) > 0.0f;
    var _S81 : f32 = select(0.0f, _S79, _S80);
    return _S81;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_2 : vec3<f32>) -> f32
{
    var _S82 : vec3<f32> = center_0 - p_2;
    var _S83 : f32 = radius_0 * radius_0 / dot(_S82, _S82);
    var _S84 : bool = _S83 >= 1.0f;
    if(_S84)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S83)) / (6.28318548202514648f * _S83);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S85 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S86 : vec2<u32> = _S85.xy;
    var n_1 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S86;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S87 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
        if((_S87.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S88 : u32 = (access_light_tree(3u + 4u * (n_1)).w);
        var _S89 : u32 = n_1 + u32(1);
        var _S90 : LightBounds = (lightBounds((_S89)));
        var _S91 : LightBounds = (lightBounds((_S88)));
        var _S92 : u32 = trail_0.x;
        var _S93 : u32 = (_S92 & (u32(1)));
        var _S94 : f32 = childShare(_S90, _S91, origin_2, smooth_n_2, _S93);
        var probability_2 : f32 = probability_1 * _S94;
        var _S95 : bool = _S93 == u32(1);
        var _S96 : u32 = select(_S89, _S88, _S95);
        var _S97 : u32 = trail_0.y;
        var _S98 : vec2<u32> = vec2<u32>((((_S92 >> (u32(1)))) | (((_S97 << (u32(31)))))), (_S97 >> (u32(1))));
        n_1 = _S96;
        trail_0 = _S98;
        probability_1 = probability_2;
    }
    var _S99 : bool = (((_S85).z == (n_1)));
    var _S100 : bool = !_S99;
    var _S101 : bool;
    if(_S100)
    {
        _S101 = true;
    }
    else
    {
        var _S102 : LightBounds = (lightBounds((n_1)));
        var _S103 : f32 = importance(_S102, origin_2, smooth_n_2);
        _S101 = !(_S103 > 0.0f);
    }
    if(_S101)
    {
        _S101 = true;
    }
    else
    {
        var _S104 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S104)
        {
            _S101 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S101 = false;
        }
    }
    if(_S101)
    {
        return 0.0f;
    }
    var _S105 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
    var _S106 : bool = (_S105.x) == u32(2);
    if(_S106)
    {
        var _S107 : Light = (lights[(_S105.y)]);
        var _S108 : f32 = sphereDensity(_S107.position, _S107.variance, start_1);
        return probability_1 * _S108;
    }
    var _S109 : u32 = _S105.y;
    var _S110 : u32 = ((instance_uint[(_S109) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S111 : mat3x3<f32> = (worldTriangle((_S109), (_S110 + _S105.z)));
    var _S112 : f32 = solidAngle(probability_1, cross(_S111[i32(1)] - _S111[i32(0)], _S111[i32(2)] - _S111[i32(0)]), light_point_0 - start_1);
    return _S112;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S113 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S114 : bool = b_0 > 0.0f;
    var _S115 : f32 = select(1.0f, _S113, _S114);
    return _S115;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_0 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S116 : u32 = (lightSlot((hit_0)));
    var _S117 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S116, light_point_1);
    var _S118 : f32 = powerHeuristic(vertex_0.pdf, _S117);
    return _S118;
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_3 : vec3<f32>,  radiance_1 : vec3<f32>,  density_0 : f32,  random_state_2 : u32) -> TreeSample
{
    var _S119 : TreeSample;
    _S119.dir = dir_3;
    _S119.radiance = radiance_1;
    _S119.density = density_0;
    _S119.random_state = random_state_2;
    return _S119;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S120 : Random;
    _S120.state = state_0;
    _S120.value = value_0;
    return _S120;
}

fn pcg( state_1 : u32) -> Random
{
    var _S121 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S122 : u32 = hash(state_1);
    return Random_x24init_0(_S121, f32(_S122) / 4.294967296e+09f);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_3 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S123 : f32 = importance(first_1, p_3, normal_3);
    var _S124 : f32 = importance(second_1, p_3, normal_3);
    var _S125 : vec2<f32> = vec2<f32>(_S123, _S124);
    var _S126 : bool = _S123 == 0.0f;
    var _S127 : bool;
    if(_S126)
    {
        _S127 = _S124 == 0.0f;
    }
    else
    {
        _S127 = false;
    }
    if(_S127)
    {
        return u32(2);
    }
    var _S128 : f32 = _S123 + _S124;
    var _S129 : bool = _S124 > 0.0f;
    if(_S129)
    {
        _S127 = ((*pick_0) * _S128) >= _S123;
    }
    else
    {
        _S127 = false;
    }
    var _S130 : u32 = select(u32(0), u32(1), _S127);
    var _S131 : f32 = min(((*pick_0) * _S128 - f32(_S130) * _S123) / _S125[_S130], 0.99999994039535522f);
    (*pick_0) = _S131;
    var _S132 : f32 = (*probability_3) * (_S125[_S130] / _S128);
    (*probability_3) = _S132;
    return _S130;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S133 : bool = (abs(dot(n_2, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S133)
    {
        const _S134 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S134;
    }
    else
    {
        a_2 = a_1;
    }
    var _S135 : vec3<f32> = (normalize((cross(n_2, a_2))));
    var _S136 : vec3<f32> = cross(n_2, _S135);
    return vec3<f32>(v_0.x) * _S135 + vec3<f32>(v_0.y) * n_2 + vec3<f32>(v_0.z) * _S136;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S137 : vec3<f32> = center_1 - p_4;
    var _S138 : f32 = radius_1 * radius_1 / dot(_S137, _S137);
    var _S139 : f32 = u1_0 * _S138 / (1.0f + sqrt(max(1.0f - _S138, 0.0f)));
    var _S140 : f32 = 2.0f * u1_0;
    var _S141 : bool = _S138 >= 1.0f;
    var _S142 : f32 = select(_S139, _S140, _S141);
    var _S143 : f32 = sqrt(max(_S142 * (2.0f - _S142), 0.0f));
    var _S144 : f32 = 6.28318548202514648f * u2_0;
    var _S145 : vec3<f32> = vec3<f32>(_S143 * cos(_S144), 1.0f - _S142, _S143 * sin(_S144));
    var _S146 : vec3<f32> = (normalize((_S137)));
    var _S147 : vec3<f32> = tangentToWorld(_S145, _S146);
    return _S147;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S148 : vec3<f32> = center_2 - ray_0.origin;
    var _S149 : f32 = dot(_S148, ray_0.unit_direction);
    var _S150 : f32 = dot(_S148, _S148) - _S149 * _S149;
    var _S151 : f32 = radius_3 * radius_3;
    var _S152 : bool = _S150 > _S151;
    if(_S152)
    {
        return 4.294967296e+09f;
    }
    var _S153 : f32 = sqrt(_S151 - _S150);
    var _S154 : f32 = _S149 - _S153;
    var _S155 : f32 = _S149 + _S153;
    var _S156 : bool = _S154 > 0.0000152587890625f;
    var _S157 : bool;
    if(_S156)
    {
        _S157 = _S154 < max_len_0;
    }
    else
    {
        _S157 = false;
    }
    if(_S157)
    {
        return _S154;
    }
    var _S158 : bool = _S155 > 0.0000152587890625f;
    if(_S158)
    {
        _S157 = _S155 < max_len_0;
    }
    else
    {
        _S157 = false;
    }
    if(_S157)
    {
        return _S155;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S159 : vec3<f32> = (normalize((light_dir_0)));
    var _S160 : bool = (dot(smooth_n_3, _S159)) < 0.0f;
    if(_S160)
    {
        return vec3<f32>(0.0f);
    }
    var _S161 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S162 : Ray = Ray_x24init_0(_S161, _S159);
    var _S163 : f32 = shadowLength(light_dir_0);
    var _S164 : vec3<f32> = (shadowTransmittance((_S162), (_S163)));
    return _S164;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S165 : Random = pcg(init_random_state_0);
    var _S166 : Random = pcg(_S165.state);
    var _S167 : Random = pcg(_S166.state);
    var _S168 : vec3<f32> = vec3<f32>(0.0f);
    var _S169 : TreeSample = TreeSample_x24init_0(_S168, _S168, 0.0f, _S167.state);
    var sample_0 : TreeSample = _S169;
    var _S170 : vec3<f32> = select(smooth_n_4, _S168, sided_0);
    var _S171 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S172 : vec3<f32> = origin_4 + _S171 * smooth_n_4;
    var pick_1 : f32 = _S165.value;
    var probability_4 : f32 = 1.0f;
    var n_3 : u32 = u32(0);
    loop
    {
        var _S173 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
        if((_S173.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S174 : u32 = (access_light_tree(3u + 4u * (n_3)).w);
        var _S175 : u32 = n_3 + u32(1);
        var _S176 : LightBounds = (lightBounds((_S175)));
        var _S177 : LightBounds = (lightBounds((_S174)));
        var _S178 : u32 = pickChild(_S176, _S177, origin_4, _S170, &(pick_1), &(probability_4));
        var _S179 : bool = _S178 > u32(1);
        if(_S179)
        {
            return sample_0;
        }
        var _S180 : bool = _S178 == u32(1);
        var _S181 : u32 = select(_S175, _S174, _S180);
        n_3 = _S181;
    }
    var _S182 : bool = n_3 == u32(0);
    var _S183 : bool;
    if(_S182)
    {
        var _S184 : LightBounds = (lightBounds((u32(0))));
        var _S185 : f32 = importance(_S184, origin_4, _S170);
        _S183 = !(_S185 > 0.0f);
    }
    else
    {
        _S183 = false;
    }
    if(_S183)
    {
        return sample_0;
    }
    var _S186 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
    var _S187 : bool = (_S186.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S187)
    {
        var _S188 : Light = (lights[(_S186.y)]);
        if(sided_0)
        {
            var _S189 : f32 = (sign((dot(geometry_n_1, _S188.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S189);
            var _S190 : vec3<f32> = origin_4 + _S171 * lift_n_1;
            start_2 = _S190;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S172;
            lift_n_0 = smooth_n_4;
        }
        var _S191 : bool = (_S188.variance) == 0.0f;
        if(_S191)
        {
            var _S192 : vec3<f32> = _S188.position - start_2;
            var _S193 : vec3<f32> = (normalize((_S192)));
            sample_0.dir = _S193;
            var _S194 : vec3<f32> = _S188.color * vec3<f32>(_S188.intensity) / vec3<f32>((dot(_S192, _S192) * probability_4));
            sample_0.radiance = _S194;
            shadow_1 = _S192;
        }
        else
        {
            var _S195 : vec3<f32> = sampleSphere(_S188.position, _S188.variance, start_2, _S166.value, _S167.value);
            sample_0.dir = _S195;
            var _S196 : f32 = sphereDensity(_S188.position, _S188.variance, start_2);
            var _S197 : f32 = probability_4 * _S196;
            sample_0.density = _S197;
            var _S198 : vec3<f32> = pointLightRadiance(_S188.color, _S188.intensity, _S188.variance);
            var _S199 : vec3<f32> = _S198 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S199;
            var _S200 : f32 = raySphere_0(_S188.position, _S188.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S201 : vec3<f32> = sample_0.dir * vec3<f32>(_S200);
            shadow_1 = _S201;
        }
    }
    else
    {
        var _S202 : u32 = _S186.y;
        var _S203 : u32 = ((instance_uint[(_S202) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S204 : u32 = _S203 + _S186.z;
        var _S205 : mat3x3<f32> = (worldTriangle((_S202), (_S204)));
        var _S206 : f32 = sqrt(_S166.value);
        var _S207 : vec2<f32> = vec2<f32>(_S206 * (1.0f - _S167.value), _S206 * _S167.value);
        var _S208 : vec3<f32> = (((_S205) * (vec3<f32>(1.0f - _S206, _S207))));
        if(sided_0)
        {
            var _S209 : f32 = (sign((dot(geometry_n_1, _S208 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S209);
            var _S210 : vec3<f32> = origin_4 + _S171 * lift_n_2;
            start_2 = _S210;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S211 : bool = !((dot(smooth_n_4, _S208 - origin_4)) > 0.0f);
            if(_S211)
            {
                return sample_0;
            }
            start_2 = _S172;
            lift_n_0 = smooth_n_4;
        }
        var _S212 : Surface = (surfaceAt((Hit_x24init_0(_S207, _S202, _S204, u32(0), 0.0f)), (_S208), (_S167.state)));
        sample_0.random_state = _S212.random_state;
        var _S213 : vec3<f32> = _S208 - start_2;
        var _S214 : vec3<f32> = (normalize((_S213)));
        sample_0.dir = _S214;
        var _S215 : f32 = solidAngle(probability_4, cross(_S205[i32(1)] - _S205[i32(0)], _S205[i32(2)] - _S205[i32(0)]), _S213);
        sample_0.density = _S215;
        var _S216 : vec3<f32> = emitted_0(_S212.material.emissive, sample_0.dir, _S212.smooth_n);
        var _S217 : vec3<f32> = select(_S216, _S168, _S212.skip);
        var _S218 : vec3<f32> = _S217 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S218;
        shadow_1 = _S213;
    }
    var _S219 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S220 : vec3<f32> = sample_0.radiance * _S219;
    var _S221 : bool = (all((_S219 == _S168)));
    var _S222 : vec3<f32> = select(_S220, _S168, _S221);
    sample_0.radiance = _S222;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S223 : AnisotropicFrame;
    _S223.tangent = tangent_1;
    _S223.alphas = alphas_0;
    return _S223;
}

fn anisotropicFrame( material_4 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S224 : f32 = material_4.roughness;
    var _S225 : f32 = _S224 * _S224;
    var _S226 : bool = (material_4.anisotropy) == 0.0f;
    var _S227 : bool;
    if(_S226)
    {
        _S227 = true;
    }
    else
    {
        _S227 = !(_S225 > 0.0f);
    }
    if(_S227)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S228 : vec3<f32> = material_4.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_4.tangent));
    var _S229 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S230 : bool = (dot(_S228, _S228)) > 0.0f;
    var _S231 : vec3<f32> = select(_S229, _S228, _S230);
    var _S232 : vec3<f32> = (normalize((_S231)));
    var _S233 : f32 = 6.28318548202514648f * material_4.anisotropic_rotation;
    var _S234 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_4.anisotropy));
    var _S235 : f32 = 1.0f / _S234;
    var _S236 : bool = (material_4.anisotropy) < 0.0f;
    var _S237 : f32 = select(_S234, _S235, _S236);
    return AnisotropicFrame_x24init_0(_S232 * vec3<f32>(cos(_S233)) + cross(n_i_0, _S232) * vec3<f32>(sin(_S233)), vec2<f32>(_S225 / _S237, _S225 * _S237));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S238 : SheenProfile;
    _S238.on = on_0;
    _S238.albedo = albedo_1;
    return _S238;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_5 : Material) -> SheenProfile
{
    var _S239 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S240 : f32 = rgb_to_greyscale(material_5.sheen);
    var _S241 : bool = _S240 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S241)
    {
        var _S242 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S243 : u32 = min(u32(_S242), u32(22));
        var _S244 : f32 = sqrt(0.05000000074505806f);
        var _S245 : f32 = sqrt(0.00999999977648258f);
        var _S246 : bool = (material_5.velvet) > 0.0f;
        var _S247 : f32 = select(_S244, _S245, _S246);
        var _S248 : f32 = (clamp(sqrt(max(material_5.sheen_roughness, 0.0f)), _S247, 1.0f) - _S247) / (1.0f - _S247) * 23.0f;
        var _S249 : u32 = min(u32(_S248), u32(22));
        var _S250 : u32 = _S243 * u32(24) + _S249;
        var _S251 : f32 = _S242 - f32(_S243);
        var _S252 : f32 = _S248 - f32(_S249);
        if(_S246)
        {
            var _S253 : u32 = _S250 + u32(24);
            var _S254 : f32 = VELVET_ALBEDO_0[_S250] + (VELVET_ALBEDO_0[_S253] - VELVET_ALBEDO_0[_S250]) * _S251;
            var _S255 : u32 = _S250 + u32(1);
            var _S256 : f32 = VELVET_ALBEDO_0[_S255] + (VELVET_ALBEDO_0[_S253 + u32(1)] - VELVET_ALBEDO_0[_S255]) * _S251;
            var _S257 : SheenProfile = SheenProfile_x24init_0(true, _S254 + (_S256 - _S254) * _S252);
            profile_0 = _S257;
        }
        else
        {
            var _S258 : u32 = _S250 + u32(24);
            var _S259 : f32 = SHEEN_ALBEDO_0[_S250] + (SHEEN_ALBEDO_0[_S258] - SHEEN_ALBEDO_0[_S250]) * _S251;
            var _S260 : u32 = _S250 + u32(1);
            var _S261 : f32 = SHEEN_ALBEDO_0[_S260] + (SHEEN_ALBEDO_0[_S258 + u32(1)] - SHEEN_ALBEDO_0[_S260]) * _S251;
            var _S262 : SheenProfile = SheenProfile_x24init_0(true, exp(_S259 + (_S261 - _S259) * _S252));
            profile_0 = _S262;
        }
    }
    else
    {
        profile_0 = _S239;
    }
    return profile_0;
}

struct BSDFLobes
{
     v_dot_h : f32,
     n_dot_h : f32,
     refracted : vec3<f32>,
     F : vec3<f32>,
     F_greyscale : f32,
     reflect_weight : f32,
     diffuse_weight : vec3<f32>,
     refract_weight : vec3<f32>,
     p_diffuse : f32,
     p_reflect : f32,
     p_refract : f32,
     translucent_share : f32,
     sheen : vec3<f32>,
     p_sheen_velvet : f32,
     view : vec3<f32>,
     tangent : vec3<f32>,
     alphas : vec2<f32>,
     visible : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_1 : vec3<f32>,  p_sheen_velvet_0 : f32,  view_0 : vec3<f32>,  tangent_2 : vec3<f32>,  alphas_1 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S263 : BSDFLobes;
    _S263.v_dot_h = v_dot_h_0;
    _S263.n_dot_h = n_dot_h_0;
    _S263.refracted = refracted_0;
    _S263.F = F_0;
    _S263.F_greyscale = F_greyscale_0;
    _S263.reflect_weight = reflect_weight_0;
    _S263.diffuse_weight = diffuse_weight_0;
    _S263.refract_weight = refract_weight_0;
    _S263.p_diffuse = p_diffuse_0;
    _S263.p_reflect = p_reflect_0;
    _S263.p_refract = p_refract_0;
    _S263.translucent_share = translucent_share_0;
    _S263.sheen = sheen_1;
    _S263.p_sheen_velvet = p_sheen_velvet_0;
    _S263.view = view_0;
    _S263.tangent = tangent_2;
    _S263.alphas = alphas_1;
    _S263.visible = visible_0;
    return _S263;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_0 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_0), dot(w_1, cross(n_4, t_0)), dot(w_1, n_4));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S264 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S265 : f32 = _S264.x;
    var _S266 : f32 = _S264.y;
    var _S267 : f32 = _S265 * _S265 + _S266 * _S266;
    const _S268 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S269 : vec3<f32> = vec3<f32>(- _S266, _S265, 0.0f);
    var _S270 : f32 = (inverseSqrt((_S267)));
    var _S271 : vec3<f32> = _S269 * vec3<f32>(_S270);
    var _S272 : bool = _S267 > 0.0f;
    var _S273 : vec3<f32> = select(_S268, _S271, _S272);
    var _S274 : vec3<f32> = cross(_S264, _S273);
    var _S275 : f32 = sqrt(U1_0);
    var _S276 : f32 = 6.28318548202514648f * U2_0;
    var _S277 : f32 = _S275 * cos(_S276);
    var t2_0 : f32 = _S275 * sin(_S276);
    var _S278 : f32 = 0.5f * (1.0f + _S264.z);
    var t2_1 : f32 = (1.0f - _S278) * sqrt(max(0.0f, 1.0f - _S277 * _S277)) + _S278 * t2_0;
    var _S279 : vec3<f32> = vec3<f32>(_S277) * _S273 + vec3<f32>(t2_1) * _S274;
    var _S280 : f32 = ((_S277));
    var _S281 : f32 = ((_S277));
    var _S282 : vec3<f32> = _S279 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S280 * _S281 - t2_1 * t2_1))) * _S264;
    var _S283 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S282.x, alpha_0 * _S282.y, max(0.0f, _S282.z)))));
    return _S283;
}

fn worldToTangent( v_2 : vec3<f32>,  n_5 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S284 : bool = (abs(dot(n_5, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S284)
    {
        const _S285 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S285;
    }
    else
    {
        a_4 = a_3;
    }
    var _S286 : vec3<f32> = (normalize((cross(n_5, a_4))));
    var _S287 : vec3<f32> = cross(n_5, _S286);
    return vec3<f32>(dot(v_2, _S286), dot(v_2, n_5), dot(v_2, _S287));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S288 : Random = pcg((*random_state_3));
    var _S289 : Random = pcg(_S288.state);
    (*random_state_3) = _S289.state;
    var _S290 : f32 = frame_0.alphas.x;
    var _S291 : bool = _S290 > 0.0f;
    if(_S291)
    {
        var _S292 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S293 : f32 = frame_0.alphas.y;
        var _S294 : vec3<f32> = (normalize((vec3<f32>(_S290 * _S292.x, _S293 * _S292.y, _S292.z))));
        var _S295 : vec3<f32> = sampleGGXVNDF(_S294, 1.0f, _S288.value, _S289.value);
        var _S296 : vec3<f32> = (normalize((vec3<f32>(_S290 * _S295.x, _S293 * _S295.y, _S295.z))));
        return vec3<f32>(_S296.x) * frame_0.tangent + vec3<f32>(_S296.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S296.z) * n_i_2;
    }
    var _S297 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S298 : vec3<f32> = sampleGGXVNDF(_S297.xzy, alpha_1, _S288.value, _S289.value);
    var _S299 : vec3<f32> = _S298.xzy;
    var _S300 : vec3<f32> = tangentToWorld(_S299, n_i_2);
    return _S300;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S301 : vec3<f32> = ((-(in_dir_0)));
    var _S302 : f32 = (sign((dot(n_6, _S301))));
    var _S303 : f32 = material_6.roughness;
    var _S304 : vec3<f32> = sampleHalfVector(_S301, n_6 * vec3<f32>(_S302), _S303 * _S303, frame_1, &(state_2));
    return _S304;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_7 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S305 : vec3<f32> = ((-(in_dir_1)));
    var _S306 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S305 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S307 : vec3<f32> = (normalize((_S306)));
    var _S308 : f32 = (sign((dot(n_7, _S305))));
    var _S309 : f32 = (sign((dot(_S306, n_7 * vec3<f32>(_S308)))));
    return _S307 * vec3<f32>(_S309);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S310 : vec3<f32> = ((-(in_dir_2)));
    var _S311 : vec3<f32> = (normalize((_S310 + out_dir_1)));
    return _S311;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S312 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S312 / (_S312 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S312)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S313 : f32 = alphas_3.x;
    var _S314 : f32 = h_0.x / _S313;
    var _S315 : f32 = alphas_3.y;
    var _S316 : f32 = h_0.y / _S315;
    var _S317 : f32 = h_0.z;
    var _S318 : f32 = _S314 * _S314 + _S316 * _S316 + _S317 * _S317;
    return 1.0f / max(3.14159274101257324f * _S313 * _S315 * _S318 * _S318, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_7 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S319 : f32 = dot(ggx_n_0, v_4);
    var _S320 : f32 = dot(n_i_3, ggx_n_0);
    var _S321 : f32 = eta_i_3 / eta_o_3;
    var _S322 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S321))));
    var _S323 : f32 = min(sqrt(material_7.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S324 : f32 = _S323 * _S323;
    var _S325 : f32 = (1.0f + _S323) / (1.0f - _S323);
    var _S326 : f32 = abs(_S319);
    var _S327 : bool = eta_i_3 > eta_o_3;
    var _S328 : f32 = select(1.0f, _S325, _S327);
    var _S329 : f32 = select(_S325, 1.0f, _S327);
    var _S330 : f32 = fresnel(_S326, _S328, _S329);
    var _S331 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S319 * _S319)) >= (eta_o_3 * eta_o_3);
    var _S332 : vec3<f32> = material_7.specular_tint * vec3<f32>(_S324);
    var _S333 : vec3<f32> = vec3<f32>(1.0f);
    var _S334 : vec3<f32> = _S332 + (_S333 - _S332) * vec3<f32>((_S330 - _S324)) / vec3<f32>((1.0f - _S324));
    var _S335 : vec3<f32> = vec3<f32>(1.0f);
    var _S336 : vec3<f32> = select(_S334, _S335, _S331);
    var _S337 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S338 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S339 : vec3<f32> = _S333 - material_7.sheen * vec3<f32>(_S338);
        var _S340 : f32 = rgb_to_greyscale(material_7.sheen);
        var _S341 : f32 = _S340 * _S338;
        var _S342 : vec3<f32> = material_7.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S339;
        sheen_component_0 = _S341;
        sheen_2 = _S342;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S335;
        sheen_component_0 = 0.0f;
        sheen_2 = _S337;
        view_1 = _S337;
    }
    var _S343 : f32 = frame_2.alphas.x;
    var _S344 : f32 = sqrt(min(_S343, frame_2.alphas.y));
    var _S345 : bool = _S343 > 0.0f;
    var _S346 : f32 = select(material_7.roughness, _S344, _S345);
    var _S347 : f32 = _S346 * _S346;
    var _S348 : f32 = pow(_S347, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S347) / (1.0f + 1.28094995021820068f * _S347);
    var _S349 : bool = _S347 > 0.0f;
    var _S350 : f32 = select(0.0f, _S348, _S349);
    var _S351 : f32 = clamp(dot(n_i_3, v_4), 0.0f, 1.0f);
    var _S352 : f32 = _S347 * _S346;
    var _S353 : f32 = min(1.00064504146575928f - _S346 * (0.00375499995425344f + _S351 * (-0.04133399948477745f + _S351 * (-0.90938502550125122f + _S351 * 0.35275399684906006f))) - _S347 * (0.27602800726890564f + _S351 * (1.27023398876190186f + _S351 * 0.04740000143647194f)) - _S352 * (0.31452900171279907f - _S351 * 0.34830701351165771f) + _S352 * _S346 * 0.27229699492454529f, 1.0f);
    var _S354 : vec3<f32> = min(_S333 / (_S333 - material_7.albedo * vec3<f32>(_S350)), vec3<f32>((1.0f / max(_S353, 0.0000152587890625f))));
    var _S355 : vec3<f32> = (mix((_S336), (material_7.albedo * _S354), (material_7.metallic)));
    var F_1 : vec3<f32> = _S355 * scale_0;
    var _S356 : f32 = rgb_to_greyscale(F_1);
    var _S357 : f32 = 1.0f - material_7.metallic;
    var _S358 : vec3<f32> = _S333 - _S336;
    var _S359 : vec3<f32> = vec3<f32>(((1.0f - material_7.transmission) * _S357)) * _S358 * scale_0;
    var _S360 : vec3<f32> = vec3<f32>((material_7.transmission * _S357)) * _S358 * scale_0;
    var _S361 : f32 = max(_S356, 0.0f);
    var _S362 : f32 = rgb_to_greyscale(_S359);
    var _S363 : f32 = max(_S362, 0.0f);
    var _S364 : f32 = rgb_to_greyscale(_S360);
    var _S365 : f32 = (sign((length(_S322))));
    var _S366 : f32 = max(_S364 * _S365, 0.0f);
    var _S367 : f32 = _S361 + _S363 + _S366;
    var _S368 : f32 = min(sheen_component_0, 1.0f);
    var _S369 : bool = sheen_component_0 > 0.0f;
    var _S370 : bool;
    if(_S369)
    {
        _S370 = !(_S367 > 0.0f);
    }
    else
    {
        _S370 = false;
    }
    var _S371 : f32 = select(_S368, 1.0f, _S370);
    var _S372 : f32 = (1.0f - _S371) / max(_S367, 0.0000152587890625f);
    var _S373 : f32 = _S363 * _S372;
    var _S374 : f32 = _S361 * _S372;
    var _S375 : f32 = _S366 * _S372;
    var visible_1 : f32;
    if(_S345)
    {
        var _S376 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S377 : f32 = anisotropicG1(_S376, frame_2.alphas);
        var _S378 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S379 : f32 = anisotropicD(_S378, frame_2.alphas);
        var _S380 : f32 = _S377 * _S379;
        visible_1 = _S380;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S319, _S320, _S322, F_1, _S356, 1.0f, _S359, _S360, _S373, _S374, _S375, 0.0f, sheen_2, _S371, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_8 : Material) -> f32
{
    var _S381 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S382 : f32 = rgb_to_greyscale(material_8.albedo);
    var _S383 : f32 = _S381 / (_S382 + _S381);
    var _S384 : bool = _S381 > 0.0f;
    var _S385 : f32 = select(0.0f, _S383, _S384);
    return _S385;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S386 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S387 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S388 : f32 = 1.0f - lobes_0.translucent_share;
    var _S389 : bool = n_i_dot_l_0 < 0.0f;
    var _S390 : f32 = select(_S388, lobes_0.translucent_share, _S389);
    var _S391 : f32 = _S387 * _S390;
    var _S392 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S393 : f32 = select(_S386, _S391, _S392);
    var _S394 : bool = n_i_dot_v_0 > 0.0f;
    var _S395 : f32 = select(0.0f, _S393, _S394);
    return _S395;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_9 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S396 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S397 : vec3<f32> = select(material_9.albedo, material_9.translucent, _S396);
    var _S398 : f32 = 1.0f - lobes_1.translucent_share;
    var _S399 : f32 = select(_S398, lobes_1.translucent_share, _S396);
    var _S400 : vec3<f32> = _S397 / vec3<f32>(_S399);
    var _S401 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S402 : vec3<f32> = select(material_9.albedo, _S400, _S401);
    return lobes_1.diffuse_weight * _S402 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S403 : f32 = alpha_4 * alpha_4;
    var _S404 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S403 + (1.0f - _S403) * n_dot_x_0 * n_dot_x_0));
    var _S405 : bool = alpha_4 > 0.0f;
    var _S406 : f32 = select(1.0f, _S404, _S405);
    return _S406;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S407 : f32 = alpha_5 * alpha_5;
    var _S408 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S407 * n_dot_h_1 * n_dot_h_1;
    return _S407 / max(3.14159274101257324f * _S408 * _S408, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S409 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S410 : f32 = _S409 * lobes_2.v_dot_h;
    var _S411 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S412 : f32 = _S410 * _S411 / n_i_dot_v_1;
    var _S413 : bool = alpha_6 > 0.0f;
    var _S414 : bool;
    if(_S413)
    {
        _S414 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S414 = false;
    }
    if(_S414)
    {
        _S414 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S414 = false;
    }
    if(_S414)
    {
        _S414 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S414 = false;
    }
    var _S415 : f32 = select(0.0f, _S412, _S414);
    var _S416 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S416)
    {
        var _S417 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S418 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S418)
        {
            _S414 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S414 = false;
        }
        if(_S414)
        {
            _S414 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S414 = false;
        }
        var _S419 : f32 = select(0.0f, _S417, _S414);
        pdf_h_0 = _S419;
    }
    else
    {
        pdf_h_0 = _S415;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S420 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S421 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S422 : f32 = lobes_3.p_refract * _S420 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S421 * _S421);
    var _S423 : bool = eta_i_5 != eta_o_5;
    var _S424 : bool;
    if(_S423)
    {
        _S424 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S424 = false;
    }
    var _S425 : f32 = select(0.0f, _S422, _S424);
    return _S425;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_10 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S426 : f32 = - dot(n_i_5, l_1);
    var _S427 : f32 = smithG1(alpha_8, max(_S426, 0.0f));
    var _S428 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S428)
    {
        var _S429 : vec3<f32> = ((-(n_i_5)));
        var _S430 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S429);
        var _S431 : f32 = anisotropicG1(_S430, lobes_4.alphas);
        G1_l_0 = _S431;
    }
    else
    {
        G1_l_0 = _S427;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_10.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S432 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S433 : bool = n_i_dot_l_2 > 0.0f;
    var _S434 : bool;
    if(_S433)
    {
        _S434 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    var _S435 : f32 = select(0.0f, _S432, _S434);
    return _S435;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_11 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S436 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S437 : f32 = dot(n_i_6, _S436);
    var _S438 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S439 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S440 : f32 = 1.0f / max(material_11.sheen_roughness, 0.05000000074505806f);
    var _S441 : f32 = 1.0f - _S437 * _S437;
    var _S442 : f32 = (2.0f + _S440) * pow(max(_S441, 0.0f), 0.5f * _S440) * 0.5f * 0.31830987334251404f / max(4.0f * (_S438 + _S439 - _S438 * _S439), 0.0000152587890625f);
    var _S443 : bool = (material_11.velvet) > 0.0f;
    var f_2 : f32;
    if(_S443)
    {
        var _S444 : f32 = max(material_11.sheen_roughness, 0.00999999977648258f);
        var _S445 : f32 = _S444 * _S444;
        var _S446 : f32 = max(_S441, 0.0000152587890625f);
        var _S447 : f32 = exp(- _S437 * _S437 / (_S446 * _S445)) / (3.14159274101257324f * _S445 * _S446 * _S446) * min(1.0f, 2.0f * _S437 * min(_S438, _S439) / max(abs(dot(_S436, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S438 * _S439, 0.0000152587890625f);
        f_2 = _S447;
    }
    else
    {
        f_2 = _S442;
    }
    return lobes_6.sheen * vec3<f32>((f_2 * _S438 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S448 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S449 : f32 = lobes_7.p_reflect * _S448 / (4.0f * lobes_7.v_dot_h);
    var _S450 : bool = _S448 > 0.0f;
    var _S451 : f32 = select(0.0f, _S449, _S450);
    return _S451;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_12 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S452 : f32 = dot(n_i_7, l_3);
    var _S453 : f32 = smithG1(alpha_12, max(_S452, 0.0f));
    var _S454 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S454)
    {
        var _S455 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S456 : f32 = anisotropicG1(_S455, lobes_8.alphas);
        G1_l_1 = _S456;
    }
    else
    {
        G1_l_1 = _S453;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_8 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S457 : vec3<f32> = ((-(in_dir_4)));
    var _S458 : f32 = dot(n_8, _S457);
    var _S459 : f32 = (sign((_S458)));
    var _S460 : vec3<f32> = n_8 * vec3<f32>(_S459);
    var _S461 : AnisotropicFrame = anisotropicFrame(material_13, _S460);
    var _S462 : f32 = dot(_S460, out_dir_2);
    var _S463 : f32 = material_13.roughness;
    var _S464 : f32 = _S463 * _S463;
    var _S465 : SheenProfile = sheenProfile(_S457, _S460, material_13);
    var _S466 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S467 : bool = _S466 > 0.0f;
    var _S468 : bool = (dot(n_8, out_dir_2) * _S458) < 0.0f;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S469 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S469;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S470 : vec3<f32> = vec3<f32>(0.0f);
    var _S471 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S470, _S470, 0.0f, 0.0f, _S470, _S470, 0.0f, 0.0f, 0.0f, 0.0f, _S470, 0.0f, _S470, _S470, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S471;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S470;
    i_0 = u32(0);
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S472 : u32;
        if(i_0 == u32(3))
        {
            _S472 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S472 = u32(6);
            }
            else
            {
                _S472 = i_0;
            }
        }
        var _S473 : bool = _S472 == u32(0);
        var _S474 : bool;
        if(_S473)
        {
            _S474 = _S467;
        }
        else
        {
            _S474 = false;
        }
        var _S475 : bool;
        if(_S474)
        {
            _S475 = _S468;
        }
        else
        {
            _S475 = _S472 == u32(1);
        }
        var _S476 : bool = _S475 != refracted_1;
        if(_S476)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S477 : u32;
        if(_S472 == u32(6))
        {
            _S477 = u32(0);
        }
        else
        {
            if(_S472 == u32(4))
            {
                _S477 = u32(2);
            }
            else
            {
                _S477 = _S472;
            }
        }
        var _S478 : bool = _S477 != half_of_0;
        var half_of_1 : u32;
        if(_S478)
        {
            var _S479 : bool = _S477 == u32(0);
            if(_S479)
            {
                var _S480 : vec3<f32> = sampledHalf(in_dir_4, n_8, material_13, random_state_5, _S461);
                ggx_n_1 = _S480;
            }
            else
            {
                var _S481 : bool = _S477 == u32(1);
                if(_S481)
                {
                    var _S482 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_8, eta_i_8, eta_o_8);
                    ggx_n_1 = _S482;
                }
                else
                {
                    var _S483 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S483;
                }
            }
            var _S484 : vec3<f32> = ((-(in_dir_4)));
            var _S485 : BSDFLobes = bsdfLobes(in_dir_4, _S484, _S460, ggx_n_1, material_13, eta_i_8, eta_o_8, _S461, _S465);
            lobe_terms_0 = _S485;
            var _S486 : f32 = translucentShare(material_13);
            lobe_terms_0.translucent_share = _S486;
            half_of_1 = _S477;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S472)
        {
        case u32(0):
            {
                var _S487 : f32 = diffusePDF(_S462, 0.0f, abs(_S458), _S464, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S487;
                var _S488 : vec3<f32> = diffuseBSDF(out_dir_2, _S460, _S464, material_13, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S488;
            }
        case u32(1):
            {
                var _S489 : f32 = refractPDF(_S462, dot(out_dir_2, ggx_n_1), abs(_S458), _S464, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S489;
                var _S490 : vec3<f32> = refractBSDF(out_dir_2, _S460, _S464, material_13, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S490;
            }
        case u32(4):
            {
                var _S491 : f32 = sheenVelvetPDF(_S462, 0.0f, abs(_S458), _S464, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S491;
                var _S492 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S460, _S464, material_13, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S492;
            }
        default :
            {
                var _S493 : f32 = reflectPDF(_S462, 0.0f, abs(_S458), _S464, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S493;
                var _S494 : vec3<f32> = reflectBSDF(out_dir_2, _S460, _S464, material_13, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S494;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S470;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S495 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S495)
        {
            var f_3 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_3;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
}

fn lightBSDF_0( in_dir_5 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_2 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  competing_0 : bool,  random_state_6 : u32) -> vec3<f32>
{
    var _S496 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S497 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S496, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S498 : bool = !competing_0;
    var _S499 : bool;
    if(_S498)
    {
        _S499 = true;
    }
    else
    {
        _S499 = (light_0.density) == 0.0f;
    }
    if(_S499)
    {
        return _S497 * light_0.radiance;
    }
    var _S500 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S500;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S501 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S501)
        {
            var _S502 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S502 * _S502)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn skyFrame_0( dir_4 : vec3<f32>) -> vec3<f32>
{
    var _S503 : vec3<f32> = vec3<f32>(- dir_4.x, dir_4.z, dir_4.y);
    var _S504 : bool = ((false));
    var _S505 : vec3<f32> = select(dir_4, _S503, _S504);
    return _S505;
}

fn environmentPdf_0( dir_5 : vec3<f32>) -> f32
{
    var _S506 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S507 : vec2<u32> = _S506 - vec2<u32>(u32(1), u32(0));
    var _S508 : vec3<f32> = skyFrame_0(dir_5);
    var _S509 : vec2<f32> = vec2<f32>(atan2(- _S508.z, - _S508.x) / 6.28318548202514648f + 0.5f, acos(clamp(_S508.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S510 : vec2<u32> = min(vec2<u32>(_S509 * vec2<f32>(_S507)), _S507 - vec2<u32>(u32(1)));
    var _S511 : vec4<f32> = (textureLoad(environment_cdf, (_S510), 0));
    var _S512 : f32 = _S511.y;
    var _S513 : u32 = _S507.x;
    var _S514 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S513, _S510.y)), 0));
    var _S515 : f32 = _S512 * _S514.y;
    return _S515 * f32(_S513 * _S507.y) / (19.73921012878417969f * length(_S508.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_6 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_6, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_7 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_2 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S516 : bool = wrongSide_0(is_inside_1, false, dir_7, surface_1.geometry_n);
    var _S517 : vec3<f32> = BSDF(in_dir_6, dir_7, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S516, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S518 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_4 : vec3<f32> = _S518;
    loop
    {
        if(i_6 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S519 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S519)
        {
            var _S520 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S520;
            var f_5 : vec3<f32> = f_4 + (*terms_0)[i_6];
            f_4 = f_5;
        }
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    return f_4;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_8 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_8 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(5)>;
    var pdfs_3 : array<f32, i32(5)>;
    var _S521 : vec3<f32> = skyLobes_0(in_dir_7, dir_8, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S521;
}

struct SkySample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     color : vec3<f32>,
     random_state : u32,
};

fn searchCDF_0( start_3 : vec2<u32>,  step_0 : vec2<u32>,  count_0 : u32,  u_0 : f32) -> u32
{
    var _S522 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S522;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S523 : u32 = (low_0 + high_0) / u32(2);
        var _S524 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S523)), 0));
        var _S525 : bool = (_S524.x) > u_0;
        if(_S525)
        {
            high_0 = _S523;
        }
        else
        {
            var _S526 : u32 = _S523 + u32(1);
            low_0 = _S526;
        }
    }
    return low_0;
}

fn SkySample_x24init_0( dir_9 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S527 : SkySample;
    _S527.dir = dir_9;
    _S527.radiance = radiance_2;
    _S527.color = color_2;
    _S527.random_state = random_state_9;
    return _S527;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S528 : bool = wrongSide_0(is_inside_3, false, dir_10, surface_3.geometry_n);
    var _S529 : bool = is_inside_3 != _S528;
    var _S530 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S531 : vec3<f32> = select(surface_3.smooth_n, _S530, _S529);
    var _S532 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S531, dir_10);
    var _S533 : vec3<f32> = (env_map_sample((dir_10)));
    var _S534 : vec3<f32> = (shadowTransmittance((_S532), (4.294967296e+09f)));
    return _S533 * _S534;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S535 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S536 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S537 : vec2<u32> = _S535 - _S536;
    var _S538 : Random = pcg(init_random_state_1);
    var _S539 : Random = pcg(_S538.state);
    var _S540 : Random = pcg(_S539.state);
    var _S541 : Random = pcg(_S540.state);
    var _S542 : u32 = _S537.x;
    var _S543 : u32 = searchCDF_0(vec2<u32>(_S542, u32(0)), vec2<u32>(u32(0), u32(1)), _S537.y, _S538.value);
    var _S544 : u32 = searchCDF_0(vec2<u32>(u32(0), _S543), _S536, _S542, _S539.value);
    var _S545 : vec2<f32> = (vec2<f32>(f32(_S544), f32(_S543)) + vec2<f32>(_S540.value, _S541.value)) / vec2<f32>(_S537) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S546 : f32 = _S545.y;
    var _S547 : f32 = sin(_S546);
    var _S548 : f32 = _S545.x;
    var _S549 : vec3<f32> = skyFrame_0(vec3<f32>(_S547 * cos(_S548), cos(_S546), _S547 * sin(_S548)));
    var _S550 : f32 = environmentPdf_0(_S549);
    var _S551 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S549, surface_4, eta_2, is_inside_4, _S550, lobe_state_0);
    var _S552 : bool = !(_S550 > 0.0f);
    var _S553 : bool;
    if(_S552)
    {
        _S553 = true;
    }
    else
    {
        _S553 = (all((_S551 == vec3<f32>(0.0f))));
    }
    if(_S553)
    {
        var _S554 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S549, _S554, _S554, _S541.state);
    }
    var _S555 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S549);
    return SkySample_x24init_0(_S549, _S555, _S551 * _S555, _S541.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S556 : vec3<f32> = a_5 / b_1;
    var _S557 : vec3<f32> = vec3<f32>(0.0f);
    var _S558 : vec3<bool> = b_1 == _S557;
    var _S559 : vec3<f32> = select(_S556, _S557, _S558);
    return _S559;
}

fn withEnd( r_1 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_1;
    var _S560 : u32 = (insertBits((r_1.path), (end_0), (u32(0)), (u32(5))));
    var _S561 : u32 = (insertBits((_S560), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S561;
    candidate_0.f = f_6;
    return candidate_0;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S562 : f32 = rgb_to_greyscale(weight_0);
    var _S563 : bool = _S562 > 0.0f;
    var _S564 : bool;
    if(_S563)
    {
        _S564 = _S562 < 3.00000000549775576e+38f;
    }
    else
    {
        _S564 = false;
    }
    var _S565 : bool = !_S564;
    if(_S565)
    {
        return;
    }
    var _S566 : f32 = (*sel_0).w_sum + _S562;
    (*sel_0).w_sum = _S566;
    var _S567 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S567;
    var _S568 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S568.state;
    var _S569 : bool = (_S568.value * (*sel_0).w_sum) <= _S562;
    if(_S569)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S570 : vec2<u32> = (uniforms_uint.environment_map_size);
    return (all((_S570 > vec2<u32>(u32(1)))));
}

struct SampleBSDF
{
     unit_direction : vec3<f32>,
     throughput : vec3<f32>,
     random_state : u32,
     refracted : bool,
     lobe : u32,
     pdf : f32,
};

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_10 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_4 : f32) -> SampleBSDF
{
    var _S571 : SampleBSDF;
    _S571.unit_direction = unit_direction_1;
    _S571.throughput = throughput_0;
    _S571.random_state = random_state_10;
    _S571.refracted = refracted_3;
    _S571.lobe = lobe_1;
    _S571.pdf = pdf_4;
    return _S571;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S572 : vec3<f32> = vec3<f32>(1.0f);
    var _S573 : SampleBSDF = SampleBSDF_x24init_0(_S572, _S572, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S573;
    var _S574 : Random = pcg(random_state_11);
    var _S575 : Random = pcg(_S574.state);
    sample_1.random_state = _S575.state;
    var _S576 : f32 = _S574.value;
    var _S577 : f32 = sqrt(max(0.0f, 1.0f - _S576 * _S576));
    var _S578 : f32 = 6.28318548202514648f * _S575.value;
    var _S579 : vec3<f32> = tangentToWorld(vec3<f32>(_S577 * cos(_S578), _S574.value, _S577 * sin(_S578)), n_i_8);
    sample_1.unit_direction = _S579;
    sample_1.lobe = u32(4);
    var _S580 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S580;
    var _S581 : f32 = sheenVelvetPDF(_S574.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S581;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S582 : f32 = sqrt(random_1_0);
    var _S583 : f32 = 6.28318548202514648f * random_2_0;
    var _S584 : f32 = _S582 * cos(_S583);
    var _S585 : f32 = _S582 * sin(_S583);
    var _S586 : f32 = sqrt(max(0.0f, 1.0f - _S584 * _S584 - _S585 * _S585));
    return vec3<f32>(_S584, _S586, _S585);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S587 : vec3<f32> = vec3<f32>(1.0f);
    var _S588 : SampleBSDF = SampleBSDF_x24init_0(_S587, _S587, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S588;
    var _S589 : Random = pcg(random_state_12);
    var _S590 : Random = pcg(_S589.state);
    sample_2.random_state = _S590.state;
    var _S591 : vec3<f32> = sampleCosWeightedHemisphere(_S589.value, _S590.value);
    var _S592 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S593 : f32 = _S591.y;
    var _S594 : f32 = - _S593;
    var _S595 : f32 = select(_S593, _S594, _S592);
    var _S596 : vec3<f32> = tangentToWorld(vec3<f32>(_S591.x, _S595, _S591.z), n_i_9);
    sample_2.unit_direction = _S596;
    sample_2.refracted = _S592;
    sample_2.lobe = u32(0);
    var _S597 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S597;
    var _S598 : f32 = diffusePDF(_S595, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S598;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S599 : vec3<f32> = vec3<f32>(1.0f);
    var _S600 : SampleBSDF = SampleBSDF_x24init_0(_S599, _S599, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S600;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S601 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S601;
    var _S602 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S602;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S603 : vec3<f32> = vec3<f32>(1.0f);
    var _S604 : SampleBSDF = SampleBSDF_x24init_0(_S603, _S603, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S604;
    var _S605 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S605;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S606 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S606;
    var _S607 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S607;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_9 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S608 : vec3<f32> = ((-(in_dir_9)));
    var _S609 : f32 = dot(n_9, _S608);
    var _S610 : f32 = (sign((_S609)));
    var n_i_12 : vec3<f32> = n_9 * vec3<f32>(_S610);
    var _S611 : f32 = abs(_S609);
    var _S612 : f32 = material_19.roughness;
    var _S613 : f32 = _S612 * _S612;
    var _S614 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S615 : SheenProfile = sheenProfile(_S608, n_i_12, material_19);
    var _S616 : vec3<f32> = sampleHalfVector(_S608, n_i_12, _S613, _S614, &(random_state_15));
    var _S617 : BSDFLobes = bsdfLobes(in_dir_9, _S608, n_i_12, _S616, material_19, eta_i_14, eta_o_14, _S614, _S615);
    var lobes_13 : BSDFLobes = _S617;
    var _S618 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S618;
    var _S619 : Random = pcg(random_state_15);
    random_state_15 = _S619.state;
    var _S620 : bool = (_S619.value) < (lobes_13.p_sheen_velvet);
    if(_S620)
    {
        var _S621 : SampleBSDF = sheenVelvetSample(n_i_12, _S611, _S613, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S621;
    }
    var _S622 : f32 = _S619.value - lobes_13.p_sheen_velvet;
    var _S623 : bool = _S622 < (lobes_13.p_diffuse);
    if(_S623)
    {
        var _S624 : SampleBSDF = diffuseSample(_S622, n_i_12, _S611, _S613, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S624;
    }
    var _S625 : bool = _S622 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S625)
    {
        var _S626 : SampleBSDF = refractSample(_S616, n_i_12, _S611, _S613, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S626;
    }
    var _S627 : SampleBSDF = reflectSample(in_dir_9, _S616, n_i_12, _S611, _S613, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S627;
}

fn escapeWeight_0( pdf_5 : f32,  dir_11 : vec3<f32>) -> f32
{
    var _S628 : bool = pdf_5 <= 0.0f;
    var _S629 : bool;
    if(_S628)
    {
        _S629 = true;
    }
    else
    {
        var _S630 : bool = environmentMapped_0();
        _S629 = !_S630;
    }
    if(_S629)
    {
        return 1.0f;
    }
    var _S631 : f32 = environmentPdf_0(dir_11);
    return pdf_5 / (pdf_5 + _S631);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S632 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S632.x, max(_S632.y, _S632.z)), 0.0f, 1.0f);
}

fn environment_0( dir_12 : vec3<f32>) -> vec3<f32>
{
    var _S633 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S634 : bool = (all((_S633 > vec2<u32>(u32(1)))));
    if(_S634)
    {
        var _S635 : vec3<f32> = (env_map_sample((dir_12)));
        return _S635;
    }
    var _S636 : vec3<f32> = (uniforms_float.ambient);
    return _S636;
}

fn walk_0( dom_0 : Domain,  r_2 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S637 : vec3<f32> = vec3<f32>(0.0f);
    var _S638 : Shift = Shift_x24init_0(_S637, 0.0f);
    var _S639 : u32 = (extractBits((r_2.path), (u32(0)), (u32(5))));
    var _S640 : u32 = (extractBits((r_2.path), (u32(5)), (u32(5))));
    var _S641 : u32 = (extractBits((r_2.path), (u32(10)), (u32(2))));
    var _S642 : u32 = (extractBits((r_2.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S643 : bool = _S642 >= u32(3);
        var _S644 : u32 = select(u32(0), u32(1), _S643);
        var _S645 : u32 = _S639 + _S644;
        var _S646 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S645 > _S646;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S638;
    }
    var _S647 : u32 = _S640 - u32(1);
    var _S648 : bool = _S642 == u32(3);
    var _S649 : u32 = select(u32(0), u32(1), _S648);
    var _S650 : u32 = _S639 + _S649;
    var _S651 : bool = _S641 == u32(0);
    var _S652 : u32 = select(_S647, _S650, _S651);
    var _S653 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_2.rc.zw))), r_2.rc.x, r_2.rc.y, u32(0), 0.0f);
    var _S654 : vec3<f32> = (normalize((dom_0.x1 - dom_0.x0)));
    var _S655 : Ray = Ray_x24init_0(dom_0.x1, _S654);
    var ray_2 : Ray = _S655;
    var hit_1 : Hit = dom_0.hit;
    var _S656 : vec3<f32> = vec3<f32>(1.0f);
    var _S657 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S637, _S637, _S637);
    var nee_vertex_0 : NEEVertex = _S657;
    var _S658 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S658;
    var _S659 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S637, 0.0f, vec4<u32>(u32(0)), _S637, _S637);
    var chain_0 : Reservoir = _S659;
    chain_0.seed = r_2.seed;
    is_inside_5 = false;
    var threshold_0 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S637;
    var reconnection_0 : vec3<f32> = _S637;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S656;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S660 : bool = (hit_1.is_point_light) == u32(1);
        var _S661 : bool;
        if(replay_0)
        {
            _S661 = _S641 == u32(1);
        }
        else
        {
            _S661 = false;
        }
        var _S662 : bool;
        if(_S661)
        {
            _S662 = b_2 == _S640;
        }
        else
        {
            _S662 = false;
        }
        var _S663 : bool;
        if(_S662)
        {
            var _S664 : bool = (hit_1.instance_index) != (_S653.instance_index);
            if(_S664)
            {
                _S663 = true;
            }
            else
            {
                _S663 = (hit_1.triangle_index) != (_S653.triangle_index);
            }
        }
        else
        {
            _S663 = false;
        }
        if(_S663)
        {
            return _S638;
        }
        var _S665 : Surface = Surface_x24init_0(_S637, _S637, 0.0f, Material_x24init_0(_S637, _S637, 0.0f, 0.0f, 0.0f, 0.0f, _S637, _S656, 1.0f, _S637, _S637, 0.5f, 0.0f, 0.0f, _S637, 0.0f), false, u32(0));
        var _S666 : bool = !_S660;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S666)
        {
            var _S667 : u32 = stream(r_2.seed, b_2);
            var _S668 : Surface = (surfaceAt((hit_1), (ray_2.origin), (_S667)));
            var surface_6 : Surface = facingRay_0(_S668, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S669 : vec3<f32> = beerLambert(hit_1.distance, surface_6.material.absorption);
                var _S670 : vec3<f32> = throughput_2 * _S669;
                front_n_0 = _S670;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S671 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_1.distance * hit_1.distance);
            var _S672 : bool = b_2 == u32(0);
            if(_S672)
            {
                var _S673 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S673;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S674 : vec3<f32> = front_n_0;
            var _S675 : f32 = geometry_density_0;
            scatter_0 = _S671;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S675;
            surface_5 = surface_6;
            front_n_0 = _S668.smooth_n;
            throughput_3 = _S674;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S665;
            front_n_0 = _S637;
            throughput_3 = throughput_2;
        }
        var _S676 : bool;
        if(scatter_0)
        {
            _S676 = prev_0.rough;
        }
        else
        {
            _S676 = false;
        }
        var _S677 : bool;
        if(_S676)
        {
            _S677 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S677 = false;
        }
        var _S678 : Surface = surface_5;
        var _S679 : Surface = surface_5;
        var _S680 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S681 : vec2<f32> = vertexEta(_S678.material, _S680);
        var _S682 : bool;
        if(scatter_0)
        {
            var _S683 : u32 = (uniforms_uint.max_bounces);
            var _S684 : bool = b_2 >= _S683;
            if(_S684)
            {
                _S682 = true;
            }
            else
            {
                var _S685 : bool = neeDecision(_S678.material, _S680, _S681.x, _S681.y);
                _S682 = _S685;
            }
        }
        else
        {
            _S682 = false;
        }
        var _S686 : bool = isTranslucent_0(_S678.material);
        var _S687 : vec3<f32> = emitted_0(_S678.material.emissive, ray_2.unit_direction, front_n_0);
        var emission_0 : vec3<f32>;
        if(_S660)
        {
            var _S688 : vec3<f32> = (calculatePointLightContrib((hit_1.instance_index)));
            emission_0 = _S688;
        }
        else
        {
            emission_0 = _S687;
        }
        var _S689 : bool = !replay_0;
        var _S690 : bool;
        if(_S689)
        {
            _S690 = true;
        }
        else
        {
            _S690 = b_2 >= _S652;
        }
        var _S691 : bool;
        if(_S690)
        {
            var _S692 : f32 = rgb_to_greyscale(emission_0);
            _S691 = _S692 > 0.0f;
        }
        else
        {
            _S691 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S691)
        {
            var _S693 : f32 = emissionWeight_0(nee_vertex_0, hit_1, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S693);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S694 : bool;
        if(replay_0)
        {
            _S694 = _S641 == u32(1);
        }
        else
        {
            _S694 = false;
        }
        var _S695 : bool;
        if(_S694)
        {
            _S695 = b_2 > _S640;
        }
        else
        {
            _S695 = false;
        }
        var _S696 : bool;
        if(_S695)
        {
            _S696 = b_2 == _S639;
        }
        else
        {
            _S696 = false;
        }
        var _S697 : bool;
        if(_S696)
        {
            var _S698 : bool = _S642 == u32(1);
            if(_S698)
            {
                _S697 = true;
            }
            else
            {
                _S697 = _S642 == u32(2);
            }
        }
        else
        {
            _S697 = false;
        }
        if(_S697)
        {
            var _S699 : bool = _S660 != (_S642 == u32(2));
            if(_S699)
            {
                return _S638;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_2.jac), density_2 / r_2.jac);
        }
        var _S700 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S701 : bool = _S700 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S702 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S703 : u32 = (insertBits((_S702), (u32(1)), (u32(10)), (u32(2))));
        var _S704 : u32 = (insertBits((_S703), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S705 : bool = prev_0.inside;
        var _S706 : u32 = select(u32(0), u32(1), _S705);
        var _S707 : u32 = (insertBits((_S704), (_S706), (u32(22)), (u32(1))));
        here_0.path = _S707;
        var _S708 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S708;
        var _S709 : vec4<u32> = vec4<u32>(hit_1.instance_index, hit_1.triangle_index, (bitcast<vec2<u32>>((hit_1.uv))));
        here_0.rc = _S709;
        var _S710 : bool;
        if(replay_0)
        {
            _S710 = _S641 == u32(1);
        }
        else
        {
            _S710 = false;
        }
        var _S711 : bool;
        if(_S710)
        {
            _S711 = b_2 == _S640;
        }
        else
        {
            _S711 = false;
        }
        var _S712 : bool = b_2 == _S652;
        var _S713 : bool;
        if(_S712)
        {
            var _S714 : bool = !scatter_0;
            if(_S714)
            {
                _S713 = true;
            }
            else
            {
                var _S715 : bool = _S641 != u32(1);
                if(_S715)
                {
                    _S713 = _S641 != u32(3);
                }
                else
                {
                    _S713 = false;
                }
            }
        }
        else
        {
            _S713 = false;
        }
        var _S716 : bool;
        if(_S713)
        {
            _S716 = _S641 == u32(2);
        }
        else
        {
            _S716 = false;
        }
        var _S717 : bool;
        if(_S716)
        {
            _S717 = !_S677;
        }
        else
        {
            _S717 = false;
        }
        var _S718 : bool;
        if(_S717)
        {
            _S718 = _S642 != u32(4);
        }
        else
        {
            _S718 = false;
        }
        var _S719 : bool = _S640 == _S639;
        var _S720 : bool;
        if(_S719)
        {
            _S720 = _S642 == u32(0);
        }
        else
        {
            _S720 = false;
        }
        var _S721 : bool;
        if(_S720)
        {
            _S721 = (hit_1.instance_index) == (_S653.instance_index);
        }
        else
        {
            _S721 = false;
        }
        var _S722 : bool;
        if(_S721)
        {
            _S722 = (hit_1.triangle_index) == (_S653.triangle_index);
        }
        else
        {
            _S722 = false;
        }
        var _S723 : bool;
        if(_S722)
        {
            _S723 = _S677;
        }
        else
        {
            _S723 = false;
        }
        var _S724 : bool = select(_S718, _S723, _S711);
        var _S725 : bool;
        if(_S682)
        {
            _S725 = select(scatter_0, _S724, replay_0);
        }
        else
        {
            _S725 = false;
        }
        var _S726 : TreeSample = TreeSample_x24init_0(_S637, _S637, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S725)
        {
            var _S727 : Surface = surface_5;
            var _S728 : bool = isTranslucent_0(_S678.material);
            var _S729 : u32 = stream(r_2.seed, b_2 + u32(64));
            var _S730 : TreeSample = sampleLightTree_0(ray_2.origin, _S679.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S728, _S729);
            var _S731 : bool = (any(((_S730.radiance) != _S637)));
            if(_S731)
            {
                var _S732 : f32 = _S681.x;
                var _S733 : f32 = _S681.y;
                var _S734 : u32 = (uniforms_uint.max_bounces);
                var _S735 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S730, _S679.smooth_n, _S727.geometry_n, _S678.material, _S732, _S733, b_2 < _S734, surface_5.random_state);
                lit_0 = _S735;
            }
            else
            {
                lit_0 = _S637;
            }
            light_1 = _S730;
        }
        else
        {
            light_1 = _S726;
            lit_0 = _S637;
        }
        var _S736 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S737 : bool;
        var _S738 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S711)
        {
            var _S739 : bool = !_S677;
            if(_S739)
            {
                return _S638;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S719)
            {
                _S736 = _S642 == u32(1);
            }
            else
            {
                _S736 = false;
            }
            if(_S736)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_2.jac), density_4 / r_2.jac);
            }
            if(_S719)
            {
                wrong_side_0 = _S642 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S740 : bool = !_S682;
                if(_S740)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S741 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S741 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S638;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_2.jac), density_4 / r_2.jac);
            }
            if(_S719)
            {
                refracted_4 = _S642 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S742 : bool = !_S682;
                if(_S742)
                {
                    return _S638;
                }
                var _S743 : f32 = environmentPdf_0(r_2.dir);
                var _S744 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_2.dir, surface_5, _S681, is_inside_5, _S743, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S744 * r_2.radiance / vec3<f32>(r_2.jac), density_4 / r_2.jac);
            }
            var _S745 : u32 = (extractBits((r_2.path), (u32(21)), (u32(1))));
            var _S746 : bool = _S682 != (_S745 == u32(1));
            if(_S746)
            {
                return _S638;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S736 = _S712;
            }
            else
            {
                _S736 = false;
            }
            if(_S736)
            {
                var _S747 : bool = !scatter_0;
                if(_S747)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S748 : bool = _S641 != u32(1);
                    if(_S748)
                    {
                        wrong_side_0 = _S641 != u32(3);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                }
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S749 : bool = _S641 == u32(2);
                if(_S749)
                {
                    _S661 = _S682;
                }
                else
                {
                    _S661 = false;
                }
                if(_S661)
                {
                    _S661 = !_S677;
                }
                else
                {
                    _S661 = false;
                }
                if(_S661)
                {
                    _S661 = _S642 == u32(4);
                }
                else
                {
                    _S661 = false;
                }
                if(_S661)
                {
                    var _S750 : u32 = stream(r_2.seed, b_2 + u32(256));
                    var _S751 : SkySample = sampleSky_0(ray_2, surface_5, _S681, is_inside_5, _S750, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S751.color, 1.0f);
                }
                if(_S749)
                {
                    is_inside_5 = _S682;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S677;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S752 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S753 : bool = !(_S752 > 0.0f);
                    if(_S753)
                    {
                        return _S638;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S651)
                {
                    is_inside_5 = _S642 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S660;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S651)
                {
                    is_inside_5 = _S642 == u32(1);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = scatter_0;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S677;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S638;
            }
            else
            {
                if(_S689)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S754 : bool = b_2 > u32(0);
                    if(_S754)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S701)
                        {
                            var _S755 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S755;
                        }
                        else
                        {
                            if(_S677)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S756 : vec3<f32> = throughput_3 * emission_1;
                        var _S757 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S756);
                        offer(&((*sel_1)), _S757, _S756 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S682)
                    {
                        var _S758 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S701)
                        {
                            var _S759 : vec3<f32> = safeDivide(_S758, chain_throughput_0);
                            candidate_3.radiance = _S759;
                        }
                        else
                        {
                            if(_S677)
                            {
                                candidate_3 = here_0;
                                var _S760 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S760;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S761 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S762 : u32 = (insertBits((_S761), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S762;
                            }
                        }
                        var _S763 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S758);
                        offer(&((*sel_1)), _S763, _S758 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S682)
                    {
                        var _S764 : bool = environmentMapped_0();
                        _S737 = _S764;
                    }
                    else
                    {
                        _S737 = false;
                    }
                    if(_S737)
                    {
                        var _S765 : u32 = (uniforms_uint.max_bounces);
                        _S738 = b_2 < _S765;
                    }
                    else
                    {
                        _S738 = false;
                    }
                    if(_S738)
                    {
                        var _S766 : u32 = stream(r_2.seed, b_2 + u32(256));
                        var _S767 : SkySample = sampleSky_0(ray_2, surface_5, _S681, is_inside_5, _S766, surface_5.random_state);
                        var _S768 : vec3<f32> = throughput_3 * _S767.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S701)
                        {
                            var _S769 : vec3<f32> = safeDivide(_S768, chain_throughput_0);
                            candidate_4.radiance = _S769;
                        }
                        else
                        {
                            if(_S677)
                            {
                                candidate_4 = here_0;
                                var _S770 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S770;
                                candidate_4.dir = _S767.dir;
                                candidate_4.radiance = _S767.radiance;
                            }
                            else
                            {
                                var _S771 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S772 : u32 = (insertBits((_S771), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S772;
                            }
                        }
                        var _S773 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S768);
                        offer(&((*sel_1)), _S773, _S768 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S774 : bool;
        var _S775 : bool;
        var straight_0 : bool;
        var _S776 : bool;
        var _S777 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S736 = _S712;
            }
            else
            {
                _S736 = false;
            }
            var _S778 : u32 = (extractBits((r_2.path), (u32(15)), (u32(3))));
            var _S779 : u32 = (extractBits((r_2.path), (u32(18)), (u32(3))));
            var _S780 : u32 = select(_S778, _S779, _S711);
            var refracted_5 : bool = _S780 == u32(1);
            var _S781 : SampleBSDF = SampleBSDF_x24init_0(_S637, _S637, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S781;
            var dir_13 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S736)
            {
                var _S782 : u32 = (extractBits((r_2.path), (u32(22)), (u32(1))));
                var _S783 : bool = is_inside_5 != (_S782 == u32(1));
                if(_S783)
                {
                    return _S638;
                }
                var _S784 : bool = _S641 == u32(1);
                if(_S784)
                {
                    var _S785 : vec3<f32> = (hitPosition((_S653)));
                    dir_13 = _S785;
                }
                else
                {
                    dir_13 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    var _S786 : bool = isTranslucent_0(_S678.material);
                    if(_S786)
                    {
                        wrong_side_0 = _S780 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S787 : vec3<f32> = dir_13 - ray_2.origin;
                        var _S788 : vec3<f32> = select(r_2.dir, _S787, _S784);
                        refracted_4 = (dot(_S679.smooth_n, _S788) * _S680) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S784)
                {
                    var _S789 : vec3<f32> = ray_2.origin;
                    var _S790 : Surface = surface_5;
                    var _S791 : vec3<f32> = (vec3<f32>(0) - _S679.smooth_n);
                    var _S792 : bool = is_inside_5 != refracted_4;
                    var _S793 : vec3<f32> = select(_S679.smooth_n, _S791, _S792);
                    var _S794 : vec3<f32> = (normalize((dir_13 - (_S789 + vec3<f32>(_S790.geometry_offset) * _S793))));
                    reconnection_1 = _S794;
                }
                else
                {
                    reconnection_1 = r_2.dir;
                }
                var _S795 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S795)
                {
                    return _S638;
                }
                var _S796 : vec3<f32> = dir_13;
                dir_13 = reconnection_1;
                lobe_index_0 = _S780;
                wrong_side_0 = false;
                reconnection_1 = _S796;
            }
            else
            {
                var _S797 : bool = !_S711;
                if(_S797)
                {
                    var _S798 : f32 = _S681.x;
                    var _S799 : f32 = _S681.y;
                    var _S800 : vec2<f32> = vec2<f32>(0.0f);
                    var _S801 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S679.smooth_n, _S678.material, _S798, _S799, surface_5.random_state, _S800);
                    var bsdf_sampled_0 : SampleBSDF = _S801;
                    var _S802 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S678.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S803 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S802.geometry_n, _S678.material, _S798, _S799, bsdf_sampled_0.random_state, _S800);
                        bsdf_sampled_0.unit_direction = _S803.unit_direction;
                        bsdf_sampled_0.refracted = _S803.refracted;
                        bsdf_sampled_0.throughput = _S803.throughput;
                        bsdf_sampled_0.lobe = _S803.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S804 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S802.geometry_n))) * _S802.geometry_n;
                            bsdf_sampled_0.unit_direction = _S804;
                        }
                    }
                    var _S805 : u32 = bsdf_sampled_0.lobe;
                    var _S806 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S807 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S808 : f32 = bsdf_sampled_0.pdf;
                    var _S809 : f32 = select(_S808, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S809;
                    dir_13 = _S806;
                    lobe_index_0 = _S805;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S807;
                }
                else
                {
                    dir_13 = r_2.dir;
                    lobe_index_0 = _S780;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S736)
            {
                _S737 = true;
            }
            else
            {
                _S737 = _S711;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S737)
            {
                var _S810 : vec3<f32> = ray_2.unit_direction;
                var _S811 : f32 = (sign((_S680)));
                var _S812 : vec3<f32> = _S679.smooth_n * vec3<f32>(_S811);
                var _S813 : f32 = dot(_S812, dir_13);
                var _S814 : f32 = _S678.material.roughness;
                var _S815 : f32 = _S814 * _S814;
                var _S816 : AnisotropicFrame = anisotropicFrame(_S678.material, _S812);
                var _S817 : vec3<f32> = ((-(_S810)));
                var _S818 : SheenProfile = sheenProfile(_S817, _S812, _S678.material);
                var _S819 : vec3<f32> = reflectedHalf(_S810, dir_13);
                var _S820 : bool = lobe_index_0 == u32(1);
                if(_S820)
                {
                    var _S821 : vec3<f32> = refractedHalf(_S810, dir_13, _S679.smooth_n, _S681.x, _S681.y);
                    throughput_6 = _S821;
                }
                else
                {
                    throughput_6 = _S819;
                }
                var _S822 : bool = lobe_index_0 == u32(0);
                if(_S822)
                {
                    _S738 = true;
                }
                else
                {
                    _S738 = lobe_index_0 == u32(6);
                }
                if(_S738)
                {
                    var _S823 : vec3<f32> = sampledHalf(_S810, _S679.smooth_n, _S678.material, surface_5.random_state, _S816);
                    throughput_7 = _S823;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S824 : vec3<f32> = ((-(_S810)));
                var _S825 : f32 = _S681.x;
                var _S826 : f32 = _S681.y;
                var _S827 : BSDFLobes = bsdfLobes(_S810, _S824, _S812, throughput_7, _S678.material, _S825, _S826, _S816, _S818);
                var lobe_terms_1 : BSDFLobes = _S827;
                var _S828 : f32 = translucentShare(_S678.material);
                lobe_terms_1.translucent_share = _S828;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S829 : f32 = diffusePDF(_S813, 0.0f, abs(_S680), _S815, lobe_terms_1, _S825, _S826);
                        var _S830 : vec3<f32> = diffuseBSDF(dir_13, _S812, _S815, _S678.material, lobe_terms_1);
                        density_5 = _S829;
                        chain_throughput_1 = _S830;
                    }
                case u32(1):
                    {
                        var _S831 : f32 = refractPDF(_S813, dot(dir_13, throughput_7), abs(_S680), _S815, lobe_terms_1, _S825, _S826);
                        var _S832 : vec3<f32> = refractBSDF(dir_13, _S812, _S815, _S678.material, lobe_terms_1);
                        density_5 = _S831;
                        chain_throughput_1 = _S832;
                    }
                case u32(4):
                    {
                        var _S833 : f32 = sheenVelvetPDF(_S813, 0.0f, abs(_S680), _S815, lobe_terms_1, _S825, _S826);
                        var _S834 : vec3<f32> = sheenVelvetBSDF(dir_13, _S812, _S815, _S678.material, lobe_terms_1);
                        density_5 = _S833;
                        chain_throughput_1 = _S834;
                    }
                default :
                    {
                        var _S835 : f32 = reflectPDF(_S813, 0.0f, abs(_S680), _S815, lobe_terms_1, _S825, _S826);
                        var _S836 : vec3<f32> = reflectBSDF(dir_13, _S812, _S815, _S678.material, lobe_terms_1);
                        density_5 = _S835;
                        chain_throughput_1 = _S836;
                    }
                }
                var _S837 : bool = density_5 > 0.0f;
                if(_S837)
                {
                    var _S838 : SampleBSDF = SampleBSDF_x24init_0(dir_13, chain_throughput_1, surface_5.random_state, _S820, lobe_index_0, density_5);
                    lobe_2 = _S838;
                }
            }
            var _S839 : bool = lobe_index_0 == u32(0);
            if(_S839)
            {
                _S738 = true;
            }
            else
            {
                _S738 = lobe_index_0 == u32(4);
            }
            if(_S738)
            {
                _S774 = true;
            }
            else
            {
                _S774 = lobe_index_0 == u32(6);
            }
            var _S840 : bool = !_S774;
            if(_S840)
            {
                var _S841 : bool = (_S678.material.roughness) == 0.0f;
                if(_S841)
                {
                    _S775 = true;
                }
                else
                {
                    var _S842 : bool = lobe_index_0 == u32(1);
                    if(_S842)
                    {
                        _S775 = (_S681.x) == (_S681.y);
                    }
                    else
                    {
                        _S775 = false;
                    }
                }
            }
            else
            {
                _S775 = false;
            }
            var _S843 : bool = lobe_index_0 == u32(1);
            if(_S843)
            {
                straight_0 = (_S678.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S844 : bool = isTranslucent_0(_S678.material);
            if(_S844)
            {
                _S776 = _S839;
            }
            else
            {
                _S776 = false;
            }
            if(_S776)
            {
                _S777 = (dot(dir_13, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S777 = false;
            }
            var _S845 : bool;
            if(_S682)
            {
                _S845 = !_S775;
            }
            else
            {
                _S845 = false;
            }
            var _S846 : bool;
            if(_S845)
            {
                _S846 = !wrong_side_0;
            }
            else
            {
                _S846 = false;
            }
            var _S847 : bool;
            if(_S846)
            {
                var _S848 : f32 = lobe_2.pdf;
                var _S849 : vec3<f32> = ray_2.origin;
                var _S850 : vec3<f32> = select(_S679.smooth_n, _S637, _S686);
                var _S851 : vec3<f32> = ray_2.origin;
                var _S852 : Surface = surface_5;
                var _S853 : vec3<f32> = (vec3<f32>(0) - _S679.smooth_n);
                var _S854 : vec3<f32> = select(_S679.smooth_n, _S853, _S777);
                var _S855 : NEEVertex = NEEVertex_x24init_0(false, _S848, _S849, _S850, _S851 + vec3<f32>(_S852.geometry_offset) * _S854);
                nee_vertex_0 = _S855;
            }
            else
            {
                var _S856 : bool = lobe_index_0 != u32(1);
                if(_S856)
                {
                    _S847 = true;
                }
                else
                {
                    _S847 = (_S681.x) != (_S681.y);
                }
                if(_S847)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S857 : bool = (lobe_2.pdf) > 0.0f;
            if(_S857)
            {
                if(_S774)
                {
                    _S847 = true;
                }
                else
                {
                    _S847 = (lobe_2.pdf * prev_0.cos / (hit_1.distance * hit_1.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S847 = false;
            }
            var _S858 : bool = (lobe_2.pdf) > 0.0f;
            var _S859 : bool;
            if(_S858)
            {
                if(_S774)
                {
                    _S859 = true;
                }
                else
                {
                    _S859 = (_S678.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S859 = false;
            }
            var _S860 : bool;
            if(_S711)
            {
                var _S861 : bool = !_S847;
                if(_S861)
                {
                    return _S638;
                }
                var _S862 : bool = _S642 != u32(1);
                if(_S862)
                {
                    _S860 = _S642 != u32(2);
                }
                else
                {
                    _S860 = false;
                }
                if(_S860)
                {
                    var _S863 : f32 = lobe_2.pdf;
                    var _S864 : f32 = select(0.0f, _S863, _S682);
                    var _S865 : f32 = escapeWeight_0(_S864, r_2.dir);
                    if(_S719)
                    {
                        is_inside_5 = _S648;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S866 : f32 = select(1.0f, _S865, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_2.radiance * vec3<f32>(_S866) / vec3<f32>(r_2.jac), density_3 * lobe_2.pdf / r_2.jac);
                }
                var _S867 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S868 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S867;
                density_5 = _S868;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S860 = b_2 <= _S652;
            }
            else
            {
                _S860 = false;
            }
            var _S869 : bool;
            if(_S860)
            {
                _S869 = _S677;
            }
            else
            {
                _S869 = false;
            }
            var _S870 : bool;
            if(_S869)
            {
                _S870 = _S847;
            }
            else
            {
                _S870 = false;
            }
            var _S871 : bool;
            if(_S870)
            {
                _S871 = true;
            }
            else
            {
                if(_S736)
                {
                    _S871 = !_S859;
                }
                else
                {
                    _S871 = false;
                }
            }
            if(_S871)
            {
                return _S638;
            }
            if(_S736)
            {
                var _S872 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S873 : f32 = lobe_2.pdf;
                throughput_7 = _S872;
                survival_probability_0 = _S873;
            }
            else
            {
                var _S874 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S637);
                throughput_7 = _S874;
                survival_probability_0 = density_5;
            }
            var _S875 : bool;
            if(_S689)
            {
                _S875 = !_S701;
            }
            else
            {
                _S875 = false;
            }
            var _S876 : bool;
            if(_S875)
            {
                _S876 = _S677;
            }
            else
            {
                _S876 = false;
            }
            var _S877 : bool;
            if(_S876)
            {
                _S877 = _S847;
            }
            else
            {
                _S877 = false;
            }
            if(_S877)
            {
                chain_0 = here_0;
                var _S878 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S879 : u32 = select(u32(0), u32(1), _S682);
                var _S880 : u32 = (insertBits((_S878), (_S879), (u32(21)), (u32(1))));
                chain_0.path = _S880;
                var _S881 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S881;
                chain_0.dir = dir_13;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S882 : Vertex = Vertex_x24init_0(_S859, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_13)), is_inside_5);
            prev_0 = _S882;
            var _S883 : f32 = lobe_2.pdf;
            var _S884 : bool;
            if(_S843)
            {
                _S884 = (_S681.x) == (_S681.y);
            }
            else
            {
                _S884 = false;
            }
            var _S885 : f32 = select(_S883, sky_pdf_0, _S884);
            var _S886 : bool;
            if(refracted_4)
            {
                _S886 = !_S777;
            }
            else
            {
                _S886 = false;
            }
            var is_inside_6 : bool;
            if(_S886)
            {
                var _S887 : bool = !is_inside_5;
                is_inside_6 = _S887;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_13;
            var _S888 : Surface = surface_5;
            var _S889 : f32 = select(_S888.geometry_offset, 0.0f, straight_0);
            var _S890 : vec3<f32> = (vec3<f32>(0) - _S679.smooth_n);
            var _S891 : bool = is_inside_6 != _S777;
            var _S892 : vec3<f32> = select(_S679.smooth_n, _S890, _S891);
            var _S893 : vec3<f32> = ray_2.origin + vec3<f32>(_S889) * _S892;
            ray_2.origin = _S893;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S885;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            straight_0 = false;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S689)
        {
            if(_S660)
            {
                var _S894 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S895 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S896 : bool = _S895 == u32(1);
                if(_S896)
                {
                    var _S897 : vec3<f32> = safeDivide(_S894, chain_throughput_0);
                    candidate_5.radiance = _S897;
                }
                var _S898 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S894);
                offer(&((*sel_1)), _S898, _S894 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S660)
            {
                _S736 = true;
            }
            else
            {
                _S736 = scatter_0;
            }
            if(_S736)
            {
                var _S899 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S899;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S900 : u32 = stream(r_2.seed, b_2 + u32(128));
            var _S901 : Random = pcg(_S900);
            var _S902 : bool = survival_probability_0 < (_S901.value);
            if(_S902)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S903 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S903;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S904 : f32 = density_5 * survival_probability_0;
            density_2 = _S904;
        }
        else
        {
            density_2 = density_5;
        }
        var _S905 : Ray = ray_2;
        var _S906 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S736 = _S712;
        }
        else
        {
            _S736 = false;
        }
        if(_S736)
        {
            wrong_side_0 = _S641 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S907 : f32 = select(4.294967296e+09f, _S906, wrong_side_0);
        var _S908 : Hit;
        if(straight_0)
        {
            _S908 = hit_1;
        }
        else
        {
            _S908 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S909 : Hit = (traverseInstanceBVH((_S905), (_S666), (_S907), (_S908)));
        hit_1 = _S909;
        if(replay_0)
        {
            refracted_4 = _S712;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S737 = _S641 == u32(1);
        }
        else
        {
            _S737 = false;
        }
        if(_S737)
        {
            _S738 = (hit_1.instance_index) == (_S653.instance_index);
        }
        else
        {
            _S738 = false;
        }
        if(_S738)
        {
            _S774 = (hit_1.triangle_index) == (_S653.triangle_index);
        }
        else
        {
            _S774 = false;
        }
        if(_S774)
        {
            hit_1.uv = _S653.uv;
            var _S910 : f32 = distance(reconnection_0, ray_2.origin);
            hit_1.distance = _S910;
        }
        if(replay_0)
        {
            _S775 = _S712;
        }
        else
        {
            _S775 = false;
        }
        if(_S775)
        {
            _S776 = _S641 == u32(3);
        }
        else
        {
            _S776 = false;
        }
        if(_S776)
        {
            _S777 = (hit_1.instance_index) != u32(4294967295);
        }
        else
        {
            _S777 = false;
        }
        if(_S777)
        {
            return _S638;
        }
        var _S911 : bool = (hit_1.instance_index) == u32(4294967295);
        if(_S911)
        {
            var _S912 : bool = !nee_vertex_0.none;
            var _S913 : f32 = select(0.0f, sky_pdf_0, _S912);
            var _S914 : f32 = escapeWeight_0(_S913, ray_2.unit_direction);
            var _S915 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S916 : vec3<f32> = throughput_2 * _S915;
            if(replay_0)
            {
                if(_S712)
                {
                    is_inside_5 = _S641 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S916 * vec3<f32>(_S914) / vec3<f32>(r_2.jac), density_2 / r_2.jac);
                }
                if(_S651)
                {
                    is_inside_5 = _S648;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S639;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !prev_0.rough;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S916 * vec3<f32>(_S914), 1.0f);
                }
                return _S638;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S917 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S918 : bool = _S917 == u32(1);
            if(_S918)
            {
                var _S919 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S920 : bool = _S919 == b_2;
                var _S921 : f32 = select(_S914, 1.0f, _S920);
                var _S922 : vec3<f32> = safeDivide(_S916 * vec3<f32>(_S921), chain_throughput_0);
                candidate_6.radiance = _S922;
            }
            else
            {
                var _S923 : bool = prev_0.rough;
                if(_S923)
                {
                    var _S924 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S925 : u32 = (insertBits((_S924), (u32(3)), (u32(10)), (u32(2))));
                    var _S926 : u32 = (insertBits((_S925), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S927 : bool = prev_0.inside;
                    var _S928 : u32 = select(u32(0), u32(1), _S927);
                    var _S929 : u32 = (insertBits((_S926), (_S928), (u32(22)), (u32(1))));
                    candidate_6.path = _S929;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S930 : vec3<f32> = _S916 * vec3<f32>(_S914);
            var _S931 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S930);
            offer(&((*sel_1)), _S931, _S930 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S932 : vec3<f32> = ray_2.origin + vec3<f32>(hit_1.distance) * ray_2.unit_direction;
        ray_2.origin = _S932;
        var _S933 : u32 = b_2 + u32(1);
        b_2 = _S933;
    }
    return _S638;
}

fn shift_0( dom_1 : Domain,  r_3 : Reservoir) -> Shift
{
    var _S934 : vec3<f32> = vec3<f32>(0.0f);
    var _S935 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S934, 0.0f, vec4<u32>(u32(0)), _S934, _S934), 0.0f, _S934, u32(0));
    var sel_2 : Selection = _S935;
    var _S936 : bool = (r_3.w) <= 0.0f;
    if(_S936)
    {
        return Shift_x24init_0(_S934, 0.0f);
    }
    var _S937 : Shift = walk_0(dom_1, r_3, true, 0.0f, &(sel_2));
    return _S937;
}

fn partner_0( p_5 : vec2<i32>,  t_1 : u32) -> vec2<i32>
{
    var sizes_0 : array<i32, i32(3)> = array<i32, i32(3)>( i32(254), i32(230), i32(210) );
    var _S938 : u32 = (uniforms_uint.frame);
    var _S939 : u32 = hash(_S938 * u32(3) + t_1);
    var _S940 : vec2<i32> = vec2<i32>(i32(1));
    var _S941 : vec2<i32> = vec2<i32>(i32(-1));
    var _S942 : vec2<bool> = vec2<bool>(((_S939 & (u32(1)))) != u32(0), ((_S939 & (u32(2)))) != u32(0));
    var _S943 : vec2<i32> = select(_S940, _S941, _S942);
    var _S944 : bool = ((_S939 & (u32(4)))) != u32(0);
    var _S945 : vec2<i32> = vec2<i32>(i32((((_S939 >> (u32(8)))) & (u32(255)))), i32((((_S939 >> (u32(16)))) & (u32(255)))));
    var _S946 : vec2<i32> = p_5.yx;
    var _S947 : vec2<i32> = select(p_5, _S946, _S944);
    var _S948 : vec2<i32> = vec2<i32>(sizes_0[t_1]);
    var _S949 : vec2<i32> = _S947 % _S948;
    var _S950 : vec2<i32> = _S948 - _S949;
    var _S951 : vec2<bool> = _S943 < vec2<i32>(i32(0));
    var _S952 : vec2<i32> = select(_S949, _S950, _S951);
    var _S953 : vec2<i32> = (_S952 + _S945) % _S948;
    var _S954 : vec4<i32> = (textureLoad(pairing, (_S953), (t_1), 0));
    var _S955 : vec2<i32> = _S954.xy * _S943;
    var _S956 : vec2<i32> = _S955.yx;
    var _S957 : vec2<i32> = select(_S955, _S956, _S944);
    return p_5 + _S957;
}

struct ShiftJob
{
     dom : Domain,
     r : Reservoir,
};

fn spatialJob_0( p_6 : vec2<i32>,  t_2 : u32,  job_0 : ptr<function, ShiftJob>) -> bool
{
    var _S958 : bool = t_2 > u32(2);
    var _S959 : bool;
    if(_S958)
    {
        _S959 = true;
    }
    else
    {
        var _S960 : vec2<u32> = (uniforms_uint.render_size);
        _S959 = (any((p_6 >= vec2<i32>(_S960))));
    }
    if(_S959)
    {
        return false;
    }
    var _S961 : Reservoir = (loadReservoir(reservoir_temp, (p_6)));
    (*job_0).r = _S961;
    var _S962 : bool = ((*job_0).r.w) > 0.0f;
    if(_S962)
    {
        var _S963 : vec2<i32> = partner_0(p_6, t_2);
        var _S964 : Domain = (*job_0).dom;
        var _S965 : bool = (storedDomain(reservoir_temp, (_S963), &(_S964)));
        (*job_0).dom = _S964;
        _S959 = _S965;
    }
    else
    {
        _S959 = false;
    }
    return _S959;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_2 : Hit) -> Domain
{
    var _S966 : Domain;
    _S966.x0 = x0_0;
    _S966.x1 = x1_0;
    _S966.hit = hit_2;
    return _S966;
}

fn ShiftJob_x24init_0( dom_2 : Domain,  r_4 : Reservoir) -> ShiftJob
{
    var _S967 : ShiftJob;
    _S967.dom = dom_2;
    _S967.r = r_4;
    return _S967;
}

fn shiftBin_0( r_5 : Reservoir) -> u32
{
    var _S968 : u32 = (extractBits((r_5.path), (u32(10)), (u32(2))));
    var _S969 : bool = _S968 == u32(2);
    var _S970 : bool;
    if(_S969)
    {
        var _S971 : u32 = (extractBits((r_5.path), (u32(12)), (u32(3))));
        _S970 = _S971 == u32(4);
    }
    else
    {
        _S970 = false;
    }
    var _S972 : u32 = select(_S968, u32(4), _S970);
    var _S973 : u32 = (extractBits((r_5.path), (u32(5)), (u32(5))));
    var _S974 : u32 = (extractBits((r_5.path), (u32(0)), (u32(5))));
    var _S975 : u32 = _S974 + u32(1);
    var _S976 : bool = _S968 == u32(0);
    var _S977 : u32 = select(_S973, _S975, _S976);
    return _S972 * u32(8) + clamp(_S977, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_7 : vec2<i32>,  _S978 : ptr<function, array<u32, i32(3)>>)
{
    var _S979 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_3 : u32 = u32(0);
    loop
    {
        var _S980 : u32 = (uniforms_uint.restir_neighbours);
        if(t_3 < _S980)
        {
        }
        else
        {
            break;
        }
        var _S981 : vec3<f32> = vec3<f32>(0.0f);
        var _S982 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S981, _S981, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S981, 0.0f, vec4<u32>(u32(0)), _S981, _S981));
        var job_1 : ShiftJob = _S982;
        var _S983 : bool = spatialJob_0(p_7, t_3, &(job_1));
        if(_S983)
        {
            var _S984 : u32 = shiftBin_0(job_1.r);
            bins_0[t_3] = _S984;
        }
        var t_4 : u32 = t_3 + u32(1);
        t_3 = t_4;
    }
    (*_S978) = bins_0;
    return;
}

fn passWalk_0( dom_3 : Domain,  r_6 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_3 : ptr<function, Selection>) -> Shift
{
    var _S985 : Shift = walk_0(dom_3, r_6, replay_1, scale_2, &((*sel_3)));
    return _S985;
}

fn passShift_0( dom_4 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S986 : vec3<f32> = vec3<f32>(0.0f);
    var _S987 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S986, 0.0f, vec4<u32>(u32(0)), _S986, _S986), 0.0f, _S986, u32(0));
    var sel_4 : Selection = _S987;
    var _S988 : bool = (r_7.w) <= 0.0f;
    if(_S988)
    {
        return Shift_x24init_0(_S986, 0.0f);
    }
    var _S989 : Shift = passWalk_0(dom_4, r_7, true, 0.0f, &(sel_4));
    return _S989;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S990 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S991 : bool;
    if(_S990)
    {
        _S991 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S991 = false;
    }
    if(_S991)
    {
        _S991 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S991 = false;
    }
    if(_S991)
    {
        _S991 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S991 = false;
    }
    return _S991;
}

fn temporalJob_0( p_8 : vec2<i32>,  q_0 : vec2<i32>,  t_5 : u32,  job_2 : ptr<function, ShiftJob>,  target_0 : bool) -> bool
{
    var _S992 : bool = t_5 > u32(1);
    var _S993 : bool;
    if(_S992)
    {
        _S993 = true;
    }
    else
    {
        var _S994 : vec2<u32> = (uniforms_uint.render_size);
        _S993 = (any((p_8 >= vec2<i32>(_S994))));
    }
    if(_S993)
    {
        _S993 = true;
    }
    else
    {
        var _S995 : bool = ((false));
        _S993 = _S995;
    }
    if(_S993)
    {
        _S993 = true;
    }
    else
    {
        _S993 = (q_0.x) < i32(0);
    }
    if(_S993)
    {
        return false;
    }
    var _S996 : bool = t_5 == u32(0);
    if(_S996)
    {
        var _S997 : Reservoir = (loadReservoir(reservoir_prev, (q_0)));
        (*job_2).r = _S997;
        var _S998 : bool = ((*job_2).r.w) > 0.0f;
        if(_S998)
        {
            var _S999 : bool = !target_0;
            if(_S999)
            {
                _S993 = true;
            }
            else
            {
                var _S1000 : Domain = (*job_2).dom;
                var _S1001 : bool = (storedDomain(reservoir_initial, (p_8), &(_S1000)));
                (*job_2).dom = _S1000;
                _S993 = _S1001;
            }
        }
        else
        {
            _S993 = false;
        }
        return _S993;
    }
    var _S1002 : Reservoir = (loadReservoir(reservoir_initial, (p_8)));
    (*job_2).r = _S1002;
    var _S1003 : bool = !target_0;
    if(_S1003)
    {
        var _S1004 : bool = ((false));
        _S993 = _S1004;
    }
    else
    {
        _S993 = false;
    }
    if(_S993)
    {
        return ((*job_2).r.w) > 0.0f;
    }
    var _S1005 : Domain = (previousDomain((q_0)));
    (*job_2).dom = _S1005;
    var _S1006 : vec3<f32> = vec3<f32>(0.0f);
    var _S1007 : Domain = Domain_x24init_0(_S1006, _S1006, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var own_0 : Domain = _S1007;
    var _S1008 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1008)
    {
        var _S1009 : bool = ((false));
        if(_S1009)
        {
            _S993 = true;
        }
        else
        {
            var _S1010 : bool = (storedDomain(reservoir_initial, (p_8), &(own_0)));
            if(_S1010)
            {
                var _S1011 : bool = sameDomain_0((*job_2).dom, own_0);
                _S993 = _S1011;
            }
            else
            {
                _S993 = false;
            }
            _S993 = !_S993;
        }
    }
    else
    {
        _S993 = false;
    }
    return _S993;
}

fn temporalShiftAt_0( p_9 : vec2<i32>,  q_1 : vec2<i32>,  t_6 : u32) -> Shift
{
    var _S1012 : vec3<f32> = vec3<f32>(0.0f);
    var _S1013 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1012, _S1012, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1012, 0.0f, vec4<u32>(u32(0)), _S1012, _S1012));
    var job_3 : ShiftJob = _S1013;
    var _S1014 : bool = temporalJob_0(p_9, q_1, t_6, &(job_3), true);
    var _S1015 : bool = !_S1014;
    if(_S1015)
    {
        return Shift_x24init_0(_S1012, 0.0f);
    }
    var _S1016 : Shift = passShift_0(job_3.dom, job_3.r);
    return _S1016;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S1017 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S1017;
    var start_4 : u32 = u32(0);
    loop
    {
        if(bin_0 < u32(40))
        {
        }
        else
        {
            break;
        }
        var _S1018 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S1019 : u32 = (_S1018 + u32(63)) / u32(64);
        var _S1020 : bool = group_0 < _S1019;
        if(_S1020)
        {
            var _S1021 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S1022 : bool = _S1021 < _S1018;
            if(_S1022)
            {
                var _S1023 : u32 = (queued_shifts[(u32(83) + start_4 + _S1021)]);
                return _S1023;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S1019;
        var start_5 : u32 = start_4 + _S1018;
        var bin_1 : u32 = bin_0 + u32(1);
        bin_0 = bin_1;
        group_0 = group_1;
        start_4 = start_5;
    }
    return u32(4294967295);
}

var<workgroup> bin_jobs_0 : array<atomic<u32>, i32(40)>;

var<workgroup> bin_offsets_0 : array<u32, i32(40)>;

fn queueShifts_0( p_10 : vec2<i32>,  bins_1 : array<u32, i32(3)>,  global_invocation_id_0 : vec3<u32>,  local_invocation_index_1 : u32)
{
    var _S1024 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
    var slots_0 : array<u32, i32(3)>;
    slots_0[i32(0)] = u32(0);
    slots_0[i32(1)] = u32(0);
    slots_0[i32(2)] = u32(0);
    var t_7 : u32 = u32(0);
    loop
    {
        if(t_7 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1025 : u32 = t_7;
        var _S1026 : bool = (bins_1[t_7]) < u32(40);
        if(_S1026)
        {
            var _S1027 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S1025]]), u32(1));
            slots_0[t_7] = _S1027;
        }
        var t_8 : u32 = t_7 + u32(1);
        t_7 = t_8;
    }
    workgroupBarrier();
    var _S1028 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S1028)
    {
        var _S1029 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S1030 : bool = _S1029 > u32(0);
        if(_S1030)
        {
            bin_2 = u32(0);
            groups_0 = u32(0);
            loop
            {
                if(bin_2 < local_invocation_index_1)
                {
                }
                else
                {
                    break;
                }
                var _S1031 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S1031;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S1032 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S1029)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S1032;
        }
    }
    workgroupBarrier();
    t_7 = u32(0);
    loop
    {
        if(t_7 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1033 : u32 = t_7;
        var _S1034 : bool = (bins_1[t_7]) < u32(40);
        if(_S1034)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S1033]] + slots_0[t_7])] = ((((u32(p_10.x) | (((u32(p_10.y) << (u32(14))))))) | (((t_7 << (u32(28)))))));
        }
        var t_9 : u32 = t_7 + u32(1);
        t_7 = t_9;
    }
    var _S1035 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S1035)
    {
        bin_2 = u32(0);
        groups_0 = u32(0);
        loop
        {
            if(bin_2 < u32(40))
            {
            }
            else
            {
                break;
            }
            var _S1036 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S1036 + u32(63)) / u32(64);
            var bin_4 : u32 = bin_2 + u32(1);
            bin_2 = bin_4;
            groups_0 = groups_1;
        }
        shift_queue.dispatch = array<u32, 3>((min(groups_0, u32(65535))), ((groups_0 + u32(65534)) / u32(65535)), (u32(1)));
    }
    return;
}

fn previousValid_0( q_2 : vec2<i32>) -> bool
{
    var _S1037 : bool = (all((q_2 >= vec2<i32>(i32(0)))));
    var _S1038 : bool;
    if(_S1037)
    {
        var _S1039 : vec2<u32> = (uniforms_uint.render_size);
        _S1038 = (all((q_2 < vec2<i32>(_S1039))));
    }
    else
    {
        _S1038 = false;
    }
    if(_S1038)
    {
        var _S1040 : vec4<u32> = (textureLoad(reservoir_prev, (q_2), (u32(0)), 0));
        _S1038 = (bitcast<f32>((_S1040.w))) > 0.0f;
    }
    else
    {
        _S1038 = false;
    }
    return _S1038;
}

fn project_0( view_2 : mat3x3<f32>,  camera_0 : vec3<f32>,  position_0 : vec3<f32>) -> vec2<f32>
{
    var _S1041 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S1042 : vec2<f32> = vec2<f32>(0.5f);
    var _S1043 : vec2<f32> = _S1041.xy / vec2<f32>(_S1041.z) * _S1042 + _S1042;
    var _S1044 : vec2<f32> = vec2<f32>(_S1043.x, 1.0f - _S1043.y);
    var _S1045 : vec2<u32> = (uniforms_uint.render_size);
    return _S1044 * vec2<f32>(_S1045);
}

fn pixelOf_0( position_1 : vec3<f32>,  previous_0 : bool) -> vec2<f32>
{
    var _S1046 : mat3x3<f32>;
    if(previous_0)
    {
        var _S1047 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
        _S1046 = _S1047;
    }
    else
    {
        var _S1048 : mat3x3<f32> = (uniforms_float.view_matrix);
        _S1046 = _S1048;
    }
    var _S1049 : vec3<f32> = (uniforms_float.camera_position);
    var _S1050 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1051 : vec2<f32> = project_0(_S1046, select(_S1049, _S1050, previous_0), position_1);
    return _S1051;
}

fn temporalNeighbor_0( p_11 : vec2<i32>,  dom_5 : Domain,  seed_2 : u32) -> vec2<i32>
{
    var _S1052 : bool = previousValid_0(p_11);
    var _S1053 : bool;
    if(_S1052)
    {
        var _S1054 : Domain = (previousDomain((p_11)));
        var _S1055 : bool = sameDomain_0(_S1054, dom_5);
        _S1053 = _S1055;
    }
    else
    {
        _S1053 = false;
    }
    if(_S1053)
    {
        return p_11;
    }
    var _S1056 : bool = (dom_5.hit.instance_index) == u32(4294967295);
    if(_S1056)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1057 : vec2<f32> = pixelOf_0(dom_5.x1, true);
    var _S1058 : vec2<i32> = vec2<i32>(floor(_S1057));
    var _S1059 : bool = previousValid_0(_S1058);
    var _S1060 : bool = !_S1059;
    if(_S1060)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1061 : vec4<u32> = (textureLoad(reservoir_prev, (_S1058), (u32(0)), 0));
    var _S1062 : Domain = (previousDomain((_S1058)));
    var _S1063 : bool = (_S1062.hit.instance_index) == (dom_5.hit.instance_index);
    if(_S1063)
    {
        var _S1064 : f32 = distance(_S1062.x1, dom_5.x1);
        var _S1065 : f32 = dom_5.hit.distance * 8.0f;
        var _S1066 : vec2<u32> = (uniforms_uint.render_size);
        _S1053 = _S1064 <= (_S1065 / f32(_S1066.x));
    }
    else
    {
        _S1053 = false;
    }
    if(_S1053)
    {
        return _S1058;
    }
    var _S1067 : vec2<f32> = vec2<f32>(p_11 + _S1058) + vec2<f32>(1.0f);
    var _S1068 : vec2<f32> = pixelOf_0(_S1062.x1, false);
    var _S1069 : vec2<i32> = vec2<i32>(floor(_S1067 - _S1068));
    var _S1070 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1071 : bool = previousValid_0(_S1069);
    var _S1072 : vec2<i32> = select(_S1070, _S1069, _S1071);
    return _S1072;
}

fn sampleNeighbor_0( p_12 : vec2<i32>,  seed_3 : u32) -> vec2<i32>
{
    var _S1073 : bool = ((false));
    if(_S1073)
    {
        var _S1074 : vec2<i32> = vec2<i32>(i32(-1));
        var _S1075 : bool = previousValid_0(p_12);
        var _S1076 : vec2<i32> = select(_S1074, p_12, _S1075);
        return _S1076;
    }
    var _S1077 : vec3<f32> = vec3<f32>(0.0f);
    var _S1078 : Domain = Domain_x24init_0(_S1077, _S1077, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1078;
    var _S1079 : vec2<u32> = (uniforms_uint.render_size);
    var _S1080 : bool = (any((p_12 >= vec2<i32>(_S1079))));
    var _S1081 : bool;
    if(_S1080)
    {
        _S1081 = true;
    }
    else
    {
        var _S1082 : bool = (storedDomain(reservoir_initial, (p_12), &(dom_6)));
        _S1081 = !_S1082;
    }
    if(_S1081)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1083 : vec2<i32> = temporalNeighbor_0(p_12, dom_6, seed_3);
    return _S1083;
}

fn storedNeighbor_0( p_13 : vec2<i32>) -> vec2<i32>
{
    var _S1084 : Reservoir = (loadReservoir(reservoir_initial, (p_13)));
    var _S1085 : vec2<i32> = sampleNeighbor_0(p_13, _S1084.seed);
    return _S1085;
}

fn temporalBins_0( p_14 : vec2<i32>,  _S1086 : ptr<function, array<u32, i32(3)>>)
{
    var _S1087 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_2 : array<u32, i32(3)>;
    bins_2[i32(0)] = u32(40);
    bins_2[i32(1)] = u32(40);
    bins_2[i32(2)] = u32(40);
    var _S1088 : vec2<i32> = storedNeighbor_0(p_14);
    var t_10 : u32 = u32(0);
    loop
    {
        if(t_10 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1089 : vec3<f32> = vec3<f32>(0.0f);
        var _S1090 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1089, _S1089, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1089, 0.0f, vec4<u32>(u32(0)), _S1089, _S1089));
        var job_4 : ShiftJob = _S1090;
        var _S1091 : bool = temporalJob_0(p_14, _S1088, t_10, &(job_4), false);
        if(_S1091)
        {
            var _S1092 : u32 = shiftBin_0(job_4.r);
            bins_2[t_10] = _S1092;
        }
        var t_11 : u32 = t_10 + u32(1);
        t_10 = t_11;
    }
    (*_S1086) = bins_2;
    return;
}

fn countShifts_0( bins_3 : array<u32, i32(3)>,  local_invocation_index_2 : u32)
{
    var t_12 : u32 = u32(0);
    loop
    {
        if(t_12 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1093 : u32 = t_12;
        var _S1094 : bool = (bins_3[t_12]) < u32(40);
        if(_S1094)
        {
            var _S1095 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1093]]), u32(1));
        }
        var t_13 : u32 = t_12 + u32(1);
        t_12 = t_13;
    }
    workgroupBarrier();
    var _S1096 : bool = local_invocation_index_2 < u32(40);
    if(_S1096)
    {
        var _S1097 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1098 : bool = _S1097 > u32(0);
        if(_S1098)
        {
            var _S1099 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1097)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_4 : u32;
    var _S1100 : vec2<u32> = global_invocation_id_1.xy;
    var _S1101 : vec2<i32> = vec2<i32>(_S1100 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_8 : u32 = local_invocation_index_3;
    loop
    {
        if(i_8 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S1102 : vec2<i32> = _S1101 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1103 : bool = (all((_S1102 >= vec2<i32>(i32(0)))));
        var _S1104 : bool;
        if(_S1103)
        {
            var _S1105 : vec2<u32> = (uniforms_uint.render_size);
            _S1104 = (all((_S1102 < vec2<i32>(_S1105))));
        }
        else
        {
            _S1104 = false;
        }
        if(_S1104)
        {
            var _S1106 : vec4<u32> = (textureLoad(reservoir_prev, (_S1102), (u32(0)), 0));
            var _S1107 : u32 = _S1106.x;
            var _S1108 : bool = (bitcast<f32>((_S1106.z))) > 0.0f;
            var _S1109 : u32 = select(u32(0), _S1107, _S1108);
            seed_4 = _S1109;
        }
        else
        {
            seed_4 = u32(0);
        }
        duplication_seeds_0[i_8] = seed_4;
        var i_9 : u32 = i_8 + u32(64);
        i_8 = i_9;
    }
    workgroupBarrier();
    var _S1110 : u32 = local_invocation_id_0.y;
    var _S1111 : u32 = local_invocation_id_0.x;
    var _S1112 : u32 = duplication_seeds_0[(_S1110 + u32(8)) * u32(24) + _S1111 + u32(8)];
    seed_4 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(seed_4 < u32(17))
        {
        }
        else
        {
            break;
        }
        var x_1 : u32 = u32(0);
        loop
        {
            if(x_1 < u32(17))
            {
            }
            else
            {
                break;
            }
            var _S1113 : bool = (duplication_seeds_0[(_S1110 + seed_4) * u32(24) + _S1111 + x_1]) == _S1112;
            var _S1114 : u32 = select(u32(0), u32(1), _S1113);
            var count_2 : u32 = count_1 + _S1114;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_4 + u32(1);
        seed_4 = y_0;
    }
    var _S1115 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1116 : bool = _S1112 != u32(0);
    var _S1117 : f32 = select(0.0f, _S1115, _S1116);
    textureStore(duplication_out, (vec2<i32>(_S1100)), 0, (vec4<u32>((bitcast<u32>((_S1117))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_5 : ptr<function, Selection>,  r_8 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_8;
    var _S1118 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1118;
    var _S1119 : f32 = r_8.jac * shifted_0.jac;
    candidate_7.jac = _S1119;
    offer(&((*sel_5)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_8.w));
    return;
}

fn finalize( sel_6 : Selection,  c_2 : f32) -> Reservoir
{
    var r_9 : Reservoir = sel_6.r;
    var _S1120 : f32 = rgb_to_greyscale(r_9.f);
    var _S1121 : f32 = sel_6.w_sum / _S1120;
    var _S1122 : bool = _S1120 > 0.0f;
    var _S1123 : f32 = select(0.0f, _S1121, _S1122);
    r_9.w = _S1123;
    r_9.c = c_2;
    return r_9;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1124 : vec2<u32> = global_invocation_id_2.xy;
    var _S1125 : vec2<i32> = vec2<i32>(_S1124);
    var _S1126 : vec3<f32> = vec3<f32>(0.0f);
    var _S1127 : Domain = Domain_x24init_0(_S1126, _S1126, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1127;
    var _S1128 : bool = (currentDomain((_S1125), &(dom_7)));
    var _S1129 : bool = !_S1128;
    if(_S1129)
    {
        storeReservoir(reservoir_prev_out, (_S1125), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1126, 0.0f, vec4<u32>(u32(0)), _S1126, _S1126)), (dom_7.hit));
        var _S1130 : vec2<f32> = vec2<f32>(_S1124);
        var _S1131 : vec2<u32> = (uniforms_uint.render_size);
        var _S1132 : vec2<f32> = _S1130 / vec2<f32>(_S1131.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1133 : vec3<f32> = vec3<f32>(_S1132, 1.0f);
        var _S1134 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1135 : vec3<f32> = (normalize(((((_S1134) * (_S1133))))));
        var _S1136 : vec3<f32> = environment_0(_S1135);
        textureStore(compute_out, (_S1125), (u32(0)), (vec4<f32>(_S1136, 1.0f)));
        var _S1137 : u32 = (uniforms_uint.is_temporal);
        var _S1138 : bool = _S1137 == u32(1);
        if(_S1138)
        {
            textureStore(compute_out, (_S1125), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1139 : Reservoir = (loadReservoir(reservoir_temp, (_S1125)));
    var t_14 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1139.c;
    loop
    {
        var _S1140 : u32 = (uniforms_uint.restir_neighbours);
        if(t_14 < _S1140)
        {
        }
        else
        {
            break;
        }
        var _S1141 : vec2<i32> = partner_0(_S1125, t_14);
        var neighbor_0 : Domain = _S1127;
        var _S1142 : bool = (currentDomain((_S1141), &(neighbor_0)));
        if(_S1142)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1143 : vec4<u32> = (textureLoad(reservoir_temp, (_S1141), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1143.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_15 : u32 = t_14 + u32(1);
        t_14 = t_15;
    }
    var _S1144 : f32 = _S1139.c / max(count_3, 1.0f);
    var _S1145 : f32 = rgb_to_greyscale(_S1139.f);
    var _S1146 : bool = count_3 == 0.0f;
    var _S1147 : f32 = select(0.0f, 1.0f, _S1146);
    var _S1148 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1126, 0.0f, vec4<u32>(u32(0)), _S1126, _S1126), 0.0f, _S1126, u32(0));
    var sel_7 : Selection = _S1148;
    var _S1149 : u32 = (uniforms_uint.frame);
    var _S1150 : u32 = hash(_S1149);
    var _S1151 : u32 = global_invocation_id_2.x;
    var _S1152 : vec2<u32> = (uniforms_uint.render_size);
    var _S1153 : u32 = stream(_S1150, _S1151 + _S1152.x * global_invocation_id_2.y);
    var _S1154 : u32 = stream(_S1153, u32(195));
    sel_7.random_state = _S1154;
    t_14 = u32(0);
    var canonical_mis_0 : f32 = _S1147;
    loop
    {
        var _S1155 : u32 = (uniforms_uint.restir_neighbours);
        if(t_14 < _S1155)
        {
        }
        else
        {
            break;
        }
        var _S1156 : vec2<i32> = partner_0(_S1125, t_14);
        var neighbor_dom_0 : Domain = _S1127;
        var _S1157 : bool = (currentDomain((_S1156), &(neighbor_dom_0)));
        if(_S1157)
        {
            var _S1158 : Reservoir = (loadReservoir(reservoir_temp, (_S1156)));
            var _S1159 : vec4<u32> = (textureLoad(shift_data, (_S1156), (t_14), 0));
            var _S1160 : vec4<f32> = (bitcast<vec4<f32>>((_S1159)));
            var _S1161 : vec4<u32> = (textureLoad(shift_data, (_S1125), (t_14), 0));
            var _S1162 : vec4<f32> = (bitcast<vec4<f32>>((_S1161)));
            var _S1163 : f32 = (_S1158.c + _S1144) / c_sum_0;
            var _S1164 : bool = _S1145 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1164)
            {
                var _S1165 : f32 = _S1163 * _S1144 * _S1145;
                var _S1166 : f32 = _S1144 * _S1145;
                var _S1167 : f32 = rgb_to_greyscale(_S1162.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1165 / (_S1166 + _S1158.c * _S1167);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1168 : f32 = rgb_to_greyscale(_S1158.f);
            var _S1169 : vec3<f32> = _S1160.xyz;
            var _S1170 : Shift = Shift_x24init_0(_S1169, _S1160.w);
            var _S1171 : f32 = _S1163 * _S1158.c * _S1168;
            var _S1172 : f32 = _S1158.c * _S1168;
            var _S1173 : f32 = rgb_to_greyscale(_S1169);
            offerShifted(&(sel_7), _S1158, _S1170, _S1171 / (_S1172 + _S1144 * _S1173));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_16 : u32 = t_14 + u32(1);
        t_14 = t_16;
    }
    offerShifted(&(sel_7), _S1139, Shift_x24init_0(_S1139.f, 1.0f), canonical_mis_0);
    var _S1174 : Reservoir = finalize(sel_7, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1125), (_S1174), (dom_7.hit));
    textureStore(reservoir_prev_out, (_S1125), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_7.hit.uv))), u32(0), u32(0))));
    var _S1175 : Surface = (surfaceAt((dom_7.hit), (dom_7.x1), (sel_7.random_state)));
    var _S1176 : vec3<f32> = (normalize((dom_7.x0 - dom_7.x1)));
    var _S1177 : f32 = (sign((dot(_S1176, _S1175.smooth_n))));
    var _S1178 : vec3<f32> = _S1175.material.emissive * vec3<f32>(max(_S1177, 0.0f));
    var _S1179 : vec3<f32> = select(_S1178, _S1126, _S1175.skip);
    var _S1180 : vec3<f32> = clamp(sel_7.color + _S1179, _S1126, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1125), (u32(0)), (vec4<f32>(_S1180, 1.0f)));
    var _S1181 : u32 = (uniforms_uint.is_temporal);
    var _S1182 : bool = _S1181 == u32(1);
    if(_S1182)
    {
        textureStore(compute_out, (_S1125), (u32(1)), (vec4<f32>(dom_7.x1, f32(dom_7.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1183 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1184 : bool = _S1183 != u32(4294967295);
    if(_S1184)
    {
        var _S1185 : vec2<i32> = vec2<i32>((vec2<u32>(_S1183, (_S1183 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1186 : vec3<f32> = vec3<f32>(0.0f);
        var _S1187 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1186, _S1186, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1186, 0.0f, vec4<u32>(u32(0)), _S1186, _S1186));
        var shift_job_0 : ShiftJob = _S1187;
        var _S1188 : u32 = (_S1183 >> (u32(28)));
        var _S1189 : bool = spatialJob_0(_S1185, _S1188, &(shift_job_0));
        var _S1190 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1185), (_S1188), (vec4<u32>((bitcast<vec3<u32>>((_S1190.f))), (bitcast<u32>((_S1190.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1191 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1192 : array<u32, i32(3)>;
    spatialBins_0(_S1191, &(_S1192));
    var _S1193 : array<u32, i32(3)> = _S1192;
    var t_17 : u32 = u32(0);
    loop
    {
        if(t_17 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1194 : bool = (_S1193[t_17]) == u32(40);
        if(_S1194)
        {
            textureStore(shift_data_out, (_S1191), (t_17), (vec4<u32>(u32(0))));
        }
        var t_18 : u32 = t_17 + u32(1);
        t_17 = t_18;
    }
    queueShifts_0(_S1191, _S1193, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1195 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1195));
    countShifts_0(_S1195, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1196 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1197 : bool = _S1196 != u32(4294967295);
    if(_S1197)
    {
        var _S1198 : vec2<i32> = vec2<i32>((vec2<u32>(_S1196, (_S1196 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1199 : vec2<i32> = storedNeighbor_0(_S1198);
        var _S1200 : u32 = (_S1196 >> (u32(28)));
        var _S1201 : Shift = temporalShiftAt_0(_S1198, _S1199, _S1200);
        textureStore(temporal_shifts_out, (_S1198), (_S1200), (vec4<u32>((bitcast<vec3<u32>>((_S1201.f))), (bitcast<u32>((_S1201.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1202 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1203 : array<u32, i32(3)>;
    temporalBins_0(_S1202, &(_S1203));
    var _S1204 : array<u32, i32(3)> = _S1203;
    var t_19 : u32 = u32(0);
    loop
    {
        if(t_19 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1205 : bool = (_S1204[t_19]) == u32(40);
        if(_S1205)
        {
            textureStore(temporal_shifts_out, (_S1202), (t_19), (vec4<u32>(u32(0))));
        }
        var t_20 : u32 = t_19 + u32(1);
        t_19 = t_20;
    }
    queueShifts_0(_S1202, _S1204, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1206 : vec2<i32> = vec2<i32>(global_invocation_id_6.xy);
    var _S1207 : array<u32, i32(3)>;
    temporalBins_0(_S1206, &(_S1207));
    countShifts_0(_S1207, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1208 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1209 : vec3<f32> = vec3<f32>(0.0f);
    var _S1210 : Domain = Domain_x24init_0(_S1209, _S1209, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_8 : Domain = _S1210;
    var _S1211 : bool = (currentDomain((_S1208), &(dom_8)));
    var _S1212 : bool = !_S1211;
    if(_S1212)
    {
        storeReservoir(reservoir_temp_out, (_S1208), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1209, 0.0f, vec4<u32>(u32(0)), _S1209, _S1209)), (dom_8.hit));
        return;
    }
    var _S1213 : Reservoir = (loadReservoir(reservoir_initial, (_S1208)));
    var _S1214 : vec2<i32> = temporalNeighbor_0(_S1208, dom_8, _S1213.seed);
    var _S1215 : bool = (_S1214.x) >= i32(0);
    var r_10 : Reservoir;
    if(_S1215)
    {
        var _S1216 : Reservoir = (loadReservoir(reservoir_prev, (_S1214)));
        var _S1217 : vec4<u32> = (textureLoad(duplication, (_S1214), 0, 0));
        var _S1218 : f32 = (bitcast<f32>((_S1217.x)));
        var _S1219 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1220 : bool = _S1219 == u32(1);
        var _S1221 : f32 = select(0.0f, _S1218, _S1220);
        var _S1222 : f32 = (mix((20.0f), (1.0f), (pow(_S1221, 0.10000000149011612f))));
        var _S1223 : f32 = min(_S1216.c, _S1222);
        var _S1224 : vec4<u32> = (textureLoad(temporal_shifts, (_S1208), (u32(0)), 0));
        var _S1225 : vec4<f32> = (bitcast<vec4<f32>>((_S1224)));
        var _S1226 : vec4<f32> = vec4<f32>(_S1213.f, 1.0f);
        var _S1227 : Domain = (previousDomain((_S1214)));
        var _S1228 : bool = sameDomain_0(_S1227, dom_8);
        var _S1229 : bool = !_S1228;
        var to_previous_0 : vec4<f32>;
        if(_S1229)
        {
            var _S1230 : vec4<u32> = (textureLoad(temporal_shifts, (_S1208), (u32(1)), 0));
            var _S1231 : vec4<f32> = (bitcast<vec4<f32>>((_S1230)));
            to_previous_0 = _S1231;
        }
        else
        {
            to_previous_0 = _S1226;
        }
        var _S1232 : f32 = rgb_to_greyscale(_S1213.f);
        var _S1233 : f32 = rgb_to_greyscale(_S1216.f);
        var _S1234 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1209, 0.0f, vec4<u32>(u32(0)), _S1209, _S1209), 0.0f, _S1209, u32(0));
        var sel_8 : Selection = _S1234;
        var _S1235 : u32 = (uniforms_uint.frame);
        var _S1236 : u32 = hash(_S1235);
        var _S1237 : u32 = global_invocation_id_7.x;
        var _S1238 : vec2<u32> = (uniforms_uint.render_size);
        var _S1239 : u32 = stream(_S1236, _S1237 + _S1238.x * global_invocation_id_7.y);
        var _S1240 : u32 = stream(_S1239, u32(194));
        sel_8.random_state = _S1240;
        var _S1241 : f32 = _S1213.c * _S1232;
        var _S1242 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1243 : f32 = _S1241 / (_S1241 + _S1223 * _S1242);
        var _S1244 : f32 = _S1223 * _S1233;
        var _S1245 : vec3<f32> = _S1225.xyz;
        var _S1246 : f32 = rgb_to_greyscale(_S1245);
        var _S1247 : f32 = _S1244 / (_S1244 + _S1213.c * _S1246);
        var _S1248 : vec2<f32> = vec2<f32>(_S1243, _S1247);
        offerShifted(&(sel_8), _S1213, Shift_x24init_0(_S1213.f, 1.0f), _S1243);
        offerShifted(&(sel_8), _S1216, Shift_x24init_0(_S1245, _S1225.w), _S1247);
        var _S1249 : Reservoir = finalize(sel_8, _S1213.c + _S1223);
        r_10 = _S1249;
    }
    else
    {
        r_10 = _S1213;
    }
    storeReservoir(reservoir_temp_out, (_S1208), (r_10), (dom_8.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1250 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1251 : vec3<f32> = vec3<f32>(0.0f);
    var _S1252 : Domain = Domain_x24init_0(_S1251, _S1251, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_9 : Domain = _S1252;
    var _S1253 : bool = (currentDomain((_S1250), &(dom_9)));
    var _S1254 : bool = !_S1253;
    if(_S1254)
    {
        storeReservoir(reservoir_initial_out, (_S1250), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1251, 0.0f, vec4<u32>(u32(0)), _S1251, _S1251)), (dom_9.hit));
        return;
    }
    var _S1255 : u32 = (uniforms_uint.frame);
    var _S1256 : u32 = hash(_S1255);
    var _S1257 : u32 = global_invocation_id_8.x;
    var _S1258 : vec2<u32> = (uniforms_uint.render_size);
    var _S1259 : u32 = stream(_S1256, _S1257 + _S1258.x * global_invocation_id_8.y);
    var _S1260 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1251, 0.0f, vec4<u32>(u32(0)), _S1251, _S1251);
    var _S1261 : Selection = Selection_x24init_0(_S1260, 0.0f, _S1251, u32(0));
    var initial_0 : Selection = _S1261;
    var _S1262 : u32 = stream(_S1259, u32(193));
    initial_0.random_state = _S1262;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1263 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1263)
        {
        }
        else
        {
            break;
        }
        var r_11 : Reservoir = _S1260;
        var _S1264 : u32 = stream(_S1259, i_10);
        r_11.seed = _S1264;
        var _S1265 : u32 = (uniforms_uint.samples);
        var _S1266 : Shift = walk_0(dom_9, r_11, false, 1.0f / f32(_S1265), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1267 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1250), (_S1267), (dom_9.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1268 : Random = pcg(state_3);
    var _S1269 : Random = pcg(_S1268.state);
    var _S1270 : f32 = 6.28318548202514648f * _S1268.value;
    var _S1271 : f32 = sqrt(-2.0f * clamp(log(_S1269.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1269.state, _S1271 * cos(_S1270));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1272 : RandomSphere;
    _S1272.state = state_4;
    _S1272.value = value_1;
    return _S1272;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1273 : Random = normal_distribution(state_5);
    var _S1274 : Random = normal_distribution(_S1273.state);
    var _S1275 : Random = normal_distribution(_S1274.state);
    var _S1276 : vec3<f32> = (normalize((vec3<f32>(_S1273.value, _S1274.value, _S1275.value))));
    return RandomSphere_x24init_0(_S1275.state, _S1276);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_10 : vec3<f32>) -> mat3x3<f32>
{
    var _S1277 : vec3<f32> = p1_0 - p0_0;
    var _S1278 : vec3<f32> = p2_0 - p0_0;
    var _S1279 : vec2<f32> = uv1_0 - uv0_0;
    var _S1280 : vec2<f32> = uv2_0 - uv0_0;
    var _S1281 : f32 = _S1279.x;
    var _S1282 : f32 = _S1280.y;
    var _S1283 : f32 = _S1279.y;
    var _S1284 : f32 = _S1280.x;
    var _S1285 : f32 = _S1281 * _S1282 - _S1283 * _S1284;
    var _S1286 : f32 = 1.0f / _S1285;
    var _S1287 : vec3<f32> = vec3<f32>(_S1286);
    var t_21 : vec3<f32> = (_S1277 * vec3<f32>(_S1282) - _S1278 * vec3<f32>(_S1283)) * _S1287;
    var _S1288 : vec3<f32> = (_S1278 * vec3<f32>(_S1281) - _S1277 * vec3<f32>(_S1284)) * _S1287;
    var _S1289 : vec3<f32> = t_21 - n_10 * vec3<f32>(dot(n_10, t_21));
    var _S1290 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_10);
    var _S1291 : bool = (dot(_S1289, _S1289)) > 0.0f;
    var _S1292 : vec3<f32> = select(_S1290, _S1289, _S1291);
    var _S1293 : vec3<f32> = (normalize((_S1292)));
    var _S1294 : bool = (dot(cross(n_10, _S1293), _S1288)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1294)
    {
        var _S1295 : vec3<f32> = ((-(_S1293)));
        t_22 = _S1295;
    }
    else
    {
        t_22 = _S1293;
    }
    var _S1296 : vec3<f32> = cross(n_10, t_22);
    return mat3x3<f32>(t_22, _S1296, n_10);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_2 : vec3<f32>) -> f32
{
    var _S1297 : vec3<f32> = t1_0 - t0_0;
    var _S1298 : vec3<f32> = t2_2 - t0_0;
    var _S1299 : vec3<f32> = t2_2 - t1_0;
    var _S1300 : f32 = min(length(_S1297), min(length(_S1298), length(_S1299)));
    var _S1301 : vec3<f32> = vec3<f32>(distance(position_2, t0_0), distance(position_2, t1_0), distance(position_2, t2_2));
    var _S1302 : vec3<f32> = (normalize((n0_0)));
    var _S1303 : f32 = dot(geometry_n_4, _S1302);
    var _S1304 : vec3<f32> = (normalize((n1_0)));
    var _S1305 : f32 = dot(geometry_n_4, _S1304);
    var _S1306 : vec3<f32> = (normalize((n2_0)));
    var _S1307 : vec3<f32> = acos(abs(vec3<f32>(_S1303, _S1305, dot(geometry_n_4, _S1306))));
    var _S1308 : vec3<f32> = clamp(tan(_S1307), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1301 * _S1308, uvw_0), 0.0f, _S1300 * 0.125f);
}

fn straightThrough( material_20 : Material) -> vec3<f32>
{
    return vec3<f32>((material_20.transmission * (1.0f - material_20.metallic))) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1309 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1310 : vec3<f32> = straightThrough(material_21);
        _S1309 = _S1310;
    }
    else
    {
        _S1309 = vec3<f32>(0.0f);
    }
    return _S1309 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_10 : Domain,  r_12 : Reservoir,  replay_2 : bool,  scale_3 : f32,  sel_9 : ptr<function, Selection>) -> Shift
{
    var _S1311 : Shift = walk_0(dom_10, r_12, replay_2, scale_3, &((*sel_9)));
    return _S1311;
}

fn restir_initial_hook( global_invocation_id_9 : vec3<u32>)
{
    restir_initial_0(global_invocation_id_9);
    return;
}

fn restir_temporal_hook( global_invocation_id_10 : vec3<u32>)
{
    restir_temporal_0(global_invocation_id_10);
    return;
}

fn restir_temporal_count_hook( global_invocation_id_11 : vec3<u32>,  local_invocation_index_10 : u32)
{
    restir_temporal_count_0(global_invocation_id_11, local_invocation_index_10);
    return;
}

fn restir_temporal_prepass_hook( global_invocation_id_12 : vec3<u32>,  local_invocation_index_11 : u32)
{
    restir_temporal_prepass_0(global_invocation_id_12, local_invocation_index_11);
    return;
}

fn restir_temporal_shift_hook( workgroup_id_3 : vec3<u32>,  local_invocation_index_12 : u32)
{
    restir_temporal_shift_0(workgroup_id_3, local_invocation_index_12);
    return;
}

fn restir_count_hook( global_invocation_id_13 : vec3<u32>,  local_invocation_index_13 : u32)
{
    restir_count_0(global_invocation_id_13, local_invocation_index_13);
    return;
}

fn restir_prepass_hook( global_invocation_id_14 : vec3<u32>,  local_invocation_index_14 : u32)
{
    restir_prepass_0(global_invocation_id_14, local_invocation_index_14);
    return;
}

fn restir_shift_hook( workgroup_id_4 : vec3<u32>,  local_invocation_index_15 : u32)
{
    restir_shift_0(workgroup_id_4, local_invocation_index_15);
    return;
}

fn restir_spatial_hook( global_invocation_id_15 : vec3<u32>)
{
    restir_spatial_0(global_invocation_id_15);
    return;
}

fn restir_duplicates_hook( global_invocation_id_16 : vec3<u32>,  local_invocation_id_1 : vec3<u32>,  local_invocation_index_16 : u32)
{
    restir_duplicates_0(global_invocation_id_16, local_invocation_id_1, local_invocation_index_16);
    return;
}

