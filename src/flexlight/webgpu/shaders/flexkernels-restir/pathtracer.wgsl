fn hash( x_0 : u32) -> u32
{
    var _S1 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S2 : u32 = ((((_S1 >> ((((_S1 >> (u32(28)))) + u32(4))))) ^ (_S1))) * u32(277803737);
    return (((_S2 >> (u32(22)))) ^ (_S2));
}

fn partner_0( p_0 : vec2<i32>,  t_0 : u32) -> vec2<i32>
{
    var sizes_0 : array<i32, i32(3)> = array<i32, i32(3)>( i32(254), i32(230), i32(210) );
    var _S3 : u32 = (uniforms_uint.frame);
    var _S4 : u32 = hash(_S3 * u32(3) + t_0);
    var _S5 : vec2<i32> = vec2<i32>(i32(1));
    var _S6 : vec2<i32> = vec2<i32>(i32(-1));
    var _S7 : vec2<bool> = vec2<bool>(((_S4 & (u32(1)))) != u32(0), ((_S4 & (u32(2)))) != u32(0));
    var _S8 : vec2<i32> = select(_S5, _S6, _S7);
    var _S9 : bool = ((_S4 & (u32(4)))) != u32(0);
    var _S10 : vec2<i32> = vec2<i32>(i32((((_S4 >> (u32(8)))) & (u32(255)))), i32((((_S4 >> (u32(16)))) & (u32(255)))));
    var _S11 : vec2<i32> = p_0.yx;
    var _S12 : vec2<i32> = select(p_0, _S11, _S9);
    var _S13 : vec2<i32> = vec2<i32>(sizes_0[t_0]);
    var _S14 : vec2<i32> = (_S12 * _S8 + _S10) % _S13;
    var _S15 : vec2<i32> = (_S14 + _S13) % _S13;
    var _S16 : vec4<i32> = (textureLoad(pairing, (_S15), (t_0), 0));
    var _S17 : vec2<i32> = _S16.xy * _S8;
    var _S18 : vec2<i32> = _S17.yx;
    var _S19 : vec2<i32> = select(_S17, _S18, _S9);
    return p_0 + _S19;
}

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

struct ShiftJob
{
     dom : Domain,
     r : Reservoir,
};

fn spatialJob_0( p_1 : vec2<i32>,  t_1 : u32,  job_0 : ptr<function, ShiftJob>) -> bool
{
    var _S20 : bool = t_1 > u32(2);
    var _S21 : bool;
    if(_S20)
    {
        _S21 = true;
    }
    else
    {
        var _S22 : vec2<u32> = (uniforms_uint.render_size);
        _S21 = (any((p_1 >= vec2<i32>(_S22))));
    }
    if(_S21)
    {
        return false;
    }
    var _S23 : Reservoir = (loadReservoir(reservoir_temp, (p_1)));
    (*job_0).r = _S23;
    var _S24 : bool = ((*job_0).r.w) > 0.0f;
    if(_S24)
    {
        var _S25 : vec2<i32> = partner_0(p_1, t_1);
        var _S26 : Domain = (*job_0).dom;
        var _S27 : bool = (storedDomain(reservoir_temp, (_S25), &(_S26)));
        (*job_0).dom = _S26;
        _S21 = _S27;
    }
    else
    {
        _S21 = false;
    }
    return _S21;
}

fn Hit_x24init_0( uv_0 : vec2<f32>,  instance_index_0 : u32,  triangle_index_0 : u32,  is_point_light_0 : u32,  distance_0 : f32) -> Hit
{
    var _S28 : Hit;
    _S28.uv = uv_0;
    _S28.instance_index = instance_index_0;
    _S28.triangle_index = triangle_index_0;
    _S28.is_point_light = is_point_light_0;
    _S28.distance = distance_0;
    return _S28;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_0 : Hit) -> Domain
{
    var _S29 : Domain;
    _S29.x0 = x0_0;
    _S29.x1 = x1_0;
    _S29.hit = hit_0;
    return _S29;
}

fn Reservoir_x24init_0( seed_0 : u32,  path_0 : u32,  w_0 : f32,  c_0 : f32,  f_0 : vec3<f32>,  jac_0 : f32,  rc_0 : vec4<u32>,  dir_0 : vec3<f32>,  radiance_0 : vec3<f32>) -> Reservoir
{
    var _S30 : Reservoir;
    _S30.seed = seed_0;
    _S30.path = path_0;
    _S30.w = w_0;
    _S30.c = c_0;
    _S30.f = f_0;
    _S30.jac = jac_0;
    _S30.rc = rc_0;
    _S30.dir = dir_0;
    _S30.radiance = radiance_0;
    return _S30;
}

fn ShiftJob_x24init_0( dom_0 : Domain,  r_0 : Reservoir) -> ShiftJob
{
    var _S31 : ShiftJob;
    _S31.dom = dom_0;
    _S31.r = r_0;
    return _S31;
}

fn shiftBin_0( r_1 : Reservoir) -> u32
{
    var _S32 : u32 = (extractBits((r_1.path), (u32(10)), (u32(2))));
    var _S33 : bool = _S32 == u32(2);
    var _S34 : bool;
    if(_S33)
    {
        var _S35 : u32 = (extractBits((r_1.path), (u32(12)), (u32(3))));
        _S34 = _S35 == u32(4);
    }
    else
    {
        _S34 = false;
    }
    var _S36 : u32 = select(_S32, u32(4), _S34);
    var _S37 : u32 = (extractBits((r_1.path), (u32(5)), (u32(5))));
    var _S38 : u32 = (extractBits((r_1.path), (u32(0)), (u32(5))));
    var _S39 : u32 = _S38 + u32(1);
    var _S40 : bool = _S32 == u32(0);
    var _S41 : u32 = select(_S37, _S39, _S40);
    return _S36 * u32(8) + clamp(_S41, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_2 : vec2<i32>,  _S42 : ptr<function, array<u32, i32(3)>>)
{
    var _S43 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_2 : u32 = u32(0);
    loop
    {
        var _S44 : u32 = (uniforms_uint.restir_neighbours);
        if(t_2 < _S44)
        {
        }
        else
        {
            break;
        }
        var _S45 : vec3<f32> = vec3<f32>(0.0f);
        var _S46 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S45, _S45, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S45, 0.0f, vec4<u32>(u32(0)), _S45, _S45));
        var job_1 : ShiftJob = _S46;
        var _S47 : bool = spatialJob_0(p_2, t_2, &(job_1));
        if(_S47)
        {
            var _S48 : u32 = shiftBin_0(job_1.r);
            bins_0[t_2] = _S48;
        }
        var t_3 : u32 = t_2 + u32(1);
        t_2 = t_3;
    }
    (*_S42) = bins_0;
    return;
}

struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Selection_x24init_0( r_2 : Reservoir,  w_sum_0 : f32,  color_0 : vec3<f32>,  random_state_0 : u32) -> Selection
{
    var _S49 : Selection;
    _S49.r = r_2;
    _S49.w_sum = w_sum_0;
    _S49.color = color_0;
    _S49.random_state = random_state_0;
    return _S49;
}

fn Shift_x24init_0( f_1 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S50 : Shift;
    _S50.f = f_1;
    _S50.jac = jac_1;
    return _S50;
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S51 : Ray;
    _S51.origin = origin_0;
    _S51.unit_direction = unit_direction_0;
    return _S51;
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
    var _S52 : NEEVertex;
    _S52.none = none_0;
    _S52.pdf = pdf_0;
    _S52.origin = origin_1;
    _S52.smooth_n = smooth_n_0;
    _S52.start = start_0;
    return _S52;
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
    var _S53 : Vertex;
    _S53.rough = rough_0;
    _S53.lobe = lobe_0;
    _S53.pdf = pdf_1;
    _S53.cos = cos_0;
    _S53.inside = inside_0;
    return _S53;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_0 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_0 : vec3<f32>) -> Material
{
    var _S54 : Material;
    _S54.albedo = albedo_0;
    _S54.emissive = emissive_0;
    _S54.roughness = roughness_0;
    _S54.metallic = metallic_0;
    _S54.transmission = transmission_0;
    _S54.ior = ior_0;
    _S54.absorption = absorption_0;
    _S54.specular_tint = specular_tint_0;
    _S54.specular_level = specular_level_0;
    _S54.translucent = translucent_0;
    _S54.sheen = sheen_0;
    _S54.sheen_roughness = sheen_roughness_0;
    _S54.anisotropy = anisotropy_0;
    _S54.anisotropic_rotation = anisotropic_rotation_0;
    _S54.tangent = tangent_0;
    return _S54;
}

fn Surface_x24init_0( smooth_n_1 : vec3<f32>,  geometry_n_0 : vec3<f32>,  geometry_offset_0 : f32,  material_0 : Material,  skip_0 : bool,  random_state_1 : u32) -> Surface
{
    var _S55 : Surface;
    _S55.smooth_n = smooth_n_1;
    _S55.geometry_n = geometry_n_0;
    _S55.geometry_offset = geometry_offset_0;
    _S55.material = material_0;
    _S55.skip = skip_0;
    _S55.random_state = random_state_1;
    return _S55;
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S56 : u32 = hash(index_0);
    var _S57 : u32 = hash((seed_1 ^ (_S56)));
    return _S57;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S58 : bool = transmission_1 > 0.0f;
    var _S59 : bool;
    if(_S58)
    {
        _S59 = true;
    }
    else
    {
        _S59 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S60 : f32 = select(-1.0f, 1.0f, _S59);
    return _S60;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S61 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S62 : vec3<f32> = vec3<f32>(_S61);
    return Surface_x24init_0(surface_0.smooth_n * _S62, surface_0.geometry_n * _S62, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S63 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S63));
}

fn vertexEta( material_1 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S64 : bool = n_dot_v_0 < 0.0f;
    var _S65 : f32 = select(1.0f, material_1.ior, _S64);
    var _S66 : f32 = select(material_1.ior, 1.0f, _S64);
    return vec2<f32>(_S65, _S66);
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S67 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S68 : f32 = eta_i_0 / eta_o_0 * _S67;
    var _S69 : bool = _S68 < 1.0f;
    var kr_0 : f32;
    if(_S69)
    {
        var _S70 : f32 = sqrt(max(0.0f, 1.0f - _S68 * _S68));
        var _S71 : bool = eta_i_0 == eta_o_0;
        var _S72 : f32 = select(_S70, cos_theta_0, _S71);
        var _S73 : f32 = eta_o_0 * cos_theta_0;
        var _S74 : f32 = eta_i_0 * _S72;
        var _S75 : f32 = (_S73 - _S74) / (_S73 + _S74);
        var _S76 : f32 = eta_i_0 * cos_theta_0;
        var _S77 : f32 = eta_o_0 * _S72;
        var _S78 : f32 = (_S76 - _S77) / (_S76 + _S77);
        var _S79 : f32 = (_S75 * _S75 + _S78 * _S78) / 2.0f;
        kr_0 = _S79;
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
    var _S80 : f32 = fresnel(abs(n_dot_v_1), eta_i_1, eta_o_1);
    var _S81 : vec3<f32> = (mix((vec3<f32>(_S80)), (material_2.albedo), (material_2.metallic)));
    var _S82 : f32 = rgb_to_greyscale(_S81);
    var _S83 : f32 = max((1.0f - _S82) * (1.0f - material_2.metallic) * (1.0f - material_2.transmission), 0.0f);
    var _S84 : bool = _S83 > 0.03999999910593033f;
    var _S85 : bool;
    if(_S84)
    {
        _S85 = true;
    }
    else
    {
        _S85 = (material_2.roughness) > 0.20000000298023224f;
    }
    return _S85;
}

fn isTranslucent_0( material_3 : Material) -> bool
{
    var _S86 : f32 = rgb_to_greyscale(material_3.translucent);
    return _S86 > 0.0f;
}

fn emitted_0( emissive_1 : vec3<f32>,  dir_2 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    var _S87 : f32 = (sign((dot((vec3<f32>(0) - dir_2), n_0))));
    var _S88 : vec3<f32> = emissive_1 * vec3<f32>(max(_S87, 0.0f));
    var _S89 : bool = ((false));
    var _S90 : vec3<f32> = select(_S88, emissive_1, _S89);
    return _S90;
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
    var _S91 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S92 : bool = cos_a_0 > cos_b_0;
    var _S93 : f32 = select(_S91, 1.0f, _S92);
    return _S93;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S94 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S95 : vec3<f32> = node_0.high - node_0.low;
    var _S96 : vec3<f32> = p_3 - _S94;
    var _S97 : vec3<f32> = (normalize((_S96)));
    var _S98 : f32 = dot(_S96, _S96);
    var _S99 : f32 = dot(_S95, _S95) / 4.0f;
    var _S100 : f32 = abs(dot(node_0.w, _S97));
    var _S101 : f32 = sine(node_0.cos_theta_o);
    var _S102 : f32 = sqrt(max(1.0f - _S99 / _S98, 0.0f));
    var _S103 : bool = _S98 < _S99;
    var _S104 : f32 = select(_S102, -1.0f, _S103);
    var _S105 : f32 = sine(_S104);
    var _S106 : f32 = sine(_S100);
    var _S107 : f32 = cosSubClamped(_S106, _S100, _S101, node_0.cos_theta_o);
    var _S108 : f32 = sine(_S100);
    var _S109 : f32 = _S108 * node_0.cos_theta_o - _S100 * _S101;
    var _S110 : bool = _S100 > (node_0.cos_theta_o);
    var _S111 : f32 = select(_S109, 0.0f, _S110);
    var _S112 : f32 = cosSubClamped(_S111, _S107, _S105, _S104);
    var _S113 : bool = _S112 <= 0.0f;
    if(_S113)
    {
        return 0.0f;
    }
    var _S114 : f32 = - dot(_S97, normal_0);
    var _S115 : f32 = node_0.phi * _S112 / max(_S98, length(_S95) / 2.0f);
    var _S116 : f32 = sine(_S114);
    var _S117 : f32 = cosSubClamped(_S116, _S114, _S105, _S104);
    var _S118 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S119 : f32 = select(_S117, 1.0f, _S118);
    return max(_S115 * _S119, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S120 : f32 = importance(first_0, p_4, normal_1);
    var _S121 : f32 = importance(second_0, p_4, normal_1);
    var _S122 : vec2<f32> = vec2<f32>(_S120, _S121);
    var _S123 : f32 = _S122[child_0] / (_S120 + _S121);
    var _S124 : bool = (_S122[child_0]) > 0.0f;
    var _S125 : f32 = select(0.0f, _S123, _S124);
    return _S125;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S126 : vec3<f32> = center_0 - p_5;
    var _S127 : f32 = radius_0 * radius_0 / dot(_S126, _S126);
    var _S128 : bool = _S127 >= 1.0f;
    if(_S128)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S127)) / (6.28318548202514648f * _S127);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S129 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S130 : vec2<u32> = _S129.xy;
    var n_1 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S130;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S131 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
        if((_S131.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S132 : u32 = (access_light_tree(3u + 4u * (n_1)).w);
        var _S133 : u32 = n_1 + u32(1);
        var _S134 : LightBounds = (lightBounds((_S133)));
        var _S135 : LightBounds = (lightBounds((_S132)));
        var _S136 : u32 = trail_0.x;
        var _S137 : u32 = (_S136 & (u32(1)));
        var _S138 : f32 = childShare(_S134, _S135, origin_2, smooth_n_2, _S137);
        var probability_2 : f32 = probability_1 * _S138;
        var _S139 : bool = _S137 == u32(1);
        var _S140 : u32 = select(_S133, _S132, _S139);
        var _S141 : u32 = trail_0.y;
        var _S142 : vec2<u32> = vec2<u32>((((_S136 >> (u32(1)))) | (((_S141 << (u32(31)))))), (_S141 >> (u32(1))));
        n_1 = _S140;
        trail_0 = _S142;
        probability_1 = probability_2;
    }
    var _S143 : bool = (((_S129).z == (n_1)));
    var _S144 : bool = !_S143;
    var _S145 : bool;
    if(_S144)
    {
        _S145 = true;
    }
    else
    {
        var _S146 : LightBounds = (lightBounds((n_1)));
        var _S147 : f32 = importance(_S146, origin_2, smooth_n_2);
        _S145 = !(_S147 > 0.0f);
    }
    if(_S145)
    {
        _S145 = true;
    }
    else
    {
        var _S148 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S148)
        {
            _S145 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S145 = false;
        }
    }
    if(_S145)
    {
        return 0.0f;
    }
    var _S149 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
    var _S150 : bool = (_S149.x) == u32(2);
    if(_S150)
    {
        var _S151 : Light = (lights[(_S149.y)]);
        var _S152 : f32 = sphereDensity(_S151.position, _S151.variance, start_1);
        return probability_1 * _S152;
    }
    var _S153 : u32 = _S149.y;
    var _S154 : u32 = ((instance_uint[(_S153) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S155 : mat3x3<f32> = (worldTriangle((_S153), (_S154 + _S149.z)));
    var _S156 : f32 = solidAngle(probability_1, cross(_S155[i32(1)] - _S155[i32(0)], _S155[i32(2)] - _S155[i32(0)]), light_point_0 - start_1);
    return _S156;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S157 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S158 : bool = b_0 > 0.0f;
    var _S159 : f32 = select(1.0f, _S157, _S158);
    return _S159;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S160 : u32 = (lightSlot((hit_1)));
    var _S161 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S160, light_point_1);
    var _S162 : f32 = powerHeuristic(vertex_0.pdf, _S161);
    return _S162;
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
    var _S163 : TreeSample;
    _S163.dir = dir_3;
    _S163.radiance = radiance_1;
    _S163.density = density_0;
    _S163.random_state = random_state_2;
    return _S163;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S164 : Random;
    _S164.state = state_0;
    _S164.value = value_0;
    return _S164;
}

fn pcg( state_1 : u32) -> Random
{
    var _S165 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S166 : u32 = hash(state_1);
    return Random_x24init_0(_S165, f32(_S166) / 4.294967296e+09f);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S167 : f32 = importance(first_1, p_6, normal_3);
    var _S168 : f32 = importance(second_1, p_6, normal_3);
    var _S169 : vec2<f32> = vec2<f32>(_S167, _S168);
    var _S170 : bool = _S167 == 0.0f;
    var _S171 : bool;
    if(_S170)
    {
        _S171 = _S168 == 0.0f;
    }
    else
    {
        _S171 = false;
    }
    if(_S171)
    {
        return u32(2);
    }
    var _S172 : f32 = _S167 + _S168;
    var _S173 : bool = _S168 > 0.0f;
    if(_S173)
    {
        _S171 = ((*pick_0) * _S172) >= _S167;
    }
    else
    {
        _S171 = false;
    }
    var _S174 : u32 = select(u32(0), u32(1), _S171);
    var _S175 : f32 = min(((*pick_0) * _S172 - f32(_S174) * _S167) / _S169[_S174], 0.99999994039535522f);
    (*pick_0) = _S175;
    var _S176 : f32 = (*probability_3) * (_S169[_S174] / _S172);
    (*probability_3) = _S176;
    return _S174;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S177 : bool = (abs(dot(n_2, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S177)
    {
        const _S178 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S178;
    }
    else
    {
        a_2 = a_1;
    }
    var _S179 : vec3<f32> = (normalize((cross(n_2, a_2))));
    var _S180 : vec3<f32> = cross(n_2, _S179);
    return vec3<f32>(v_0.x) * _S179 + vec3<f32>(v_0.y) * n_2 + vec3<f32>(v_0.z) * _S180;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S181 : vec3<f32> = center_1 - p_7;
    var _S182 : f32 = radius_1 * radius_1 / dot(_S181, _S181);
    var _S183 : f32 = u1_0 * _S182 / (1.0f + sqrt(max(1.0f - _S182, 0.0f)));
    var _S184 : f32 = 2.0f * u1_0;
    var _S185 : bool = _S182 >= 1.0f;
    var _S186 : f32 = select(_S183, _S184, _S185);
    var _S187 : f32 = sqrt(max(_S186 * (2.0f - _S186), 0.0f));
    var _S188 : f32 = 6.28318548202514648f * u2_0;
    var _S189 : vec3<f32> = vec3<f32>(_S187 * cos(_S188), 1.0f - _S186, _S187 * sin(_S188));
    var _S190 : vec3<f32> = (normalize((_S181)));
    var _S191 : vec3<f32> = tangentToWorld(_S189, _S190);
    return _S191;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S192 : vec3<f32> = center_2 - ray_0.origin;
    var _S193 : f32 = dot(_S192, ray_0.unit_direction);
    var _S194 : f32 = dot(_S192, _S192) - _S193 * _S193;
    var _S195 : f32 = radius_3 * radius_3;
    var _S196 : bool = _S194 > _S195;
    if(_S196)
    {
        return 4.294967296e+09f;
    }
    var _S197 : f32 = sqrt(_S195 - _S194);
    var _S198 : f32 = _S193 - _S197;
    var _S199 : f32 = _S193 + _S197;
    var _S200 : bool = _S198 > 0.0000152587890625f;
    var _S201 : bool;
    if(_S200)
    {
        _S201 = _S198 < max_len_0;
    }
    else
    {
        _S201 = false;
    }
    if(_S201)
    {
        return _S198;
    }
    var _S202 : bool = _S199 > 0.0000152587890625f;
    if(_S202)
    {
        _S201 = _S199 < max_len_0;
    }
    else
    {
        _S201 = false;
    }
    if(_S201)
    {
        return _S199;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S203 : vec3<f32> = (normalize((light_dir_0)));
    var _S204 : bool = (dot(smooth_n_3, _S203)) < 0.0f;
    if(_S204)
    {
        return vec3<f32>(0.0f);
    }
    var _S205 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S206 : Ray = Ray_x24init_0(_S205, _S203);
    var _S207 : f32 = shadowLength(light_dir_0);
    var _S208 : vec3<f32> = (shadowTransmittance((_S206), (_S207)));
    return _S208;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S209 : Random = pcg(init_random_state_0);
    var _S210 : Random = pcg(_S209.state);
    var _S211 : Random = pcg(_S210.state);
    var _S212 : vec3<f32> = vec3<f32>(0.0f);
    var _S213 : TreeSample = TreeSample_x24init_0(_S212, _S212, 0.0f, _S211.state);
    var sample_0 : TreeSample = _S213;
    var _S214 : vec3<f32> = select(smooth_n_4, _S212, sided_0);
    var _S215 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S216 : vec3<f32> = origin_4 + _S215 * smooth_n_4;
    var pick_1 : f32 = _S209.value;
    var probability_4 : f32 = 1.0f;
    var n_3 : u32 = u32(0);
    loop
    {
        var _S217 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
        if((_S217.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S218 : u32 = (access_light_tree(3u + 4u * (n_3)).w);
        var _S219 : u32 = n_3 + u32(1);
        var _S220 : LightBounds = (lightBounds((_S219)));
        var _S221 : LightBounds = (lightBounds((_S218)));
        var _S222 : u32 = pickChild(_S220, _S221, origin_4, _S214, &(pick_1), &(probability_4));
        var _S223 : bool = _S222 > u32(1);
        if(_S223)
        {
            return sample_0;
        }
        var _S224 : bool = _S222 == u32(1);
        var _S225 : u32 = select(_S219, _S218, _S224);
        n_3 = _S225;
    }
    var _S226 : bool = n_3 == u32(0);
    var _S227 : bool;
    if(_S226)
    {
        var _S228 : LightBounds = (lightBounds((u32(0))));
        var _S229 : f32 = importance(_S228, origin_4, _S214);
        _S227 = !(_S229 > 0.0f);
    }
    else
    {
        _S227 = false;
    }
    if(_S227)
    {
        return sample_0;
    }
    var _S230 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
    var _S231 : bool = (_S230.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S231)
    {
        var _S232 : Light = (lights[(_S230.y)]);
        if(sided_0)
        {
            var _S233 : f32 = (sign((dot(geometry_n_1, _S232.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S233);
            var _S234 : vec3<f32> = origin_4 + _S215 * lift_n_1;
            start_2 = _S234;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S216;
            lift_n_0 = smooth_n_4;
        }
        var _S235 : bool = (_S232.variance) == 0.0f;
        if(_S235)
        {
            var _S236 : vec3<f32> = _S232.position - start_2;
            var _S237 : vec3<f32> = (normalize((_S236)));
            sample_0.dir = _S237;
            var _S238 : vec3<f32> = _S232.color * vec3<f32>(_S232.intensity) / vec3<f32>((dot(_S236, _S236) * probability_4));
            sample_0.radiance = _S238;
            shadow_1 = _S236;
        }
        else
        {
            var _S239 : vec3<f32> = sampleSphere(_S232.position, _S232.variance, start_2, _S210.value, _S211.value);
            sample_0.dir = _S239;
            var _S240 : f32 = sphereDensity(_S232.position, _S232.variance, start_2);
            var _S241 : f32 = probability_4 * _S240;
            sample_0.density = _S241;
            var _S242 : vec3<f32> = pointLightRadiance(_S232.color, _S232.intensity, _S232.variance);
            var _S243 : vec3<f32> = _S242 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S243;
            var _S244 : f32 = raySphere_0(_S232.position, _S232.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S245 : vec3<f32> = sample_0.dir * vec3<f32>(_S244);
            shadow_1 = _S245;
        }
    }
    else
    {
        var _S246 : u32 = _S230.y;
        var _S247 : u32 = ((instance_uint[(_S246) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S248 : u32 = _S247 + _S230.z;
        var _S249 : mat3x3<f32> = (worldTriangle((_S246), (_S248)));
        var _S250 : f32 = sqrt(_S210.value);
        var _S251 : vec2<f32> = vec2<f32>(_S250 * (1.0f - _S211.value), _S250 * _S211.value);
        var _S252 : vec3<f32> = (((_S249) * (vec3<f32>(1.0f - _S250, _S251))));
        if(sided_0)
        {
            var _S253 : f32 = (sign((dot(geometry_n_1, _S252 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S253);
            var _S254 : vec3<f32> = origin_4 + _S215 * lift_n_2;
            start_2 = _S254;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S255 : bool = !((dot(smooth_n_4, _S252 - origin_4)) > 0.0f);
            if(_S255)
            {
                return sample_0;
            }
            start_2 = _S216;
            lift_n_0 = smooth_n_4;
        }
        var _S256 : Surface = (surfaceAt((Hit_x24init_0(_S251, _S246, _S248, u32(0), 0.0f)), (_S252), (_S211.state)));
        sample_0.random_state = _S256.random_state;
        var _S257 : vec3<f32> = _S252 - start_2;
        var _S258 : vec3<f32> = (normalize((_S257)));
        sample_0.dir = _S258;
        var _S259 : f32 = solidAngle(probability_4, cross(_S249[i32(1)] - _S249[i32(0)], _S249[i32(2)] - _S249[i32(0)]), _S257);
        sample_0.density = _S259;
        var _S260 : vec3<f32> = emitted_0(_S256.material.emissive, sample_0.dir, _S256.smooth_n);
        var _S261 : vec3<f32> = select(_S260, _S212, _S256.skip);
        var _S262 : vec3<f32> = _S261 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S262;
        shadow_1 = _S257;
    }
    var _S263 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S264 : vec3<f32> = sample_0.radiance * _S263;
    var _S265 : bool = (all((_S263 == _S212)));
    var _S266 : vec3<f32> = select(_S264, _S212, _S265);
    sample_0.radiance = _S266;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S267 : AnisotropicFrame;
    _S267.tangent = tangent_1;
    _S267.alphas = alphas_0;
    return _S267;
}

fn anisotropicFrame( material_4 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S268 : f32 = material_4.roughness;
    var _S269 : f32 = _S268 * _S268;
    var _S270 : bool = (material_4.anisotropy) == 0.0f;
    var _S271 : bool;
    if(_S270)
    {
        _S271 = true;
    }
    else
    {
        _S271 = !(_S269 > 0.0f);
    }
    if(_S271)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S272 : vec3<f32> = material_4.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_4.tangent));
    var _S273 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S274 : bool = (dot(_S272, _S272)) > 0.0f;
    var _S275 : vec3<f32> = select(_S273, _S272, _S274);
    var _S276 : vec3<f32> = (normalize((_S275)));
    var _S277 : f32 = 6.28318548202514648f * material_4.anisotropic_rotation;
    var _S278 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_4.anisotropy));
    var _S279 : f32 = 1.0f / _S278;
    var _S280 : bool = (material_4.anisotropy) < 0.0f;
    var _S281 : f32 = select(_S278, _S279, _S280);
    return AnisotropicFrame_x24init_0(_S276 * vec3<f32>(cos(_S277)) + cross(n_i_0, _S276) * vec3<f32>(sin(_S277)), vec2<f32>(_S269 / _S281, _S269 * _S281));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S282 : SheenProfile;
    _S282.on = on_0;
    _S282.albedo = albedo_1;
    return _S282;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_5 : Material) -> SheenProfile
{
    var _S283 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S284 : f32 = rgb_to_greyscale(material_5.sheen);
    var _S285 : bool = _S284 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S285)
    {
        var _S286 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S287 : u32 = min(u32(_S286), u32(22));
        var _S288 : f32 = sqrt(0.05000000074505806f);
        var _S289 : f32 = (clamp(sqrt(max(material_5.sheen_roughness, 0.0f)), _S288, 1.0f) - _S288) / (1.0f - _S288) * 23.0f;
        var _S290 : u32 = min(u32(_S289), u32(22));
        var _S291 : u32 = _S287 * u32(24) + _S290;
        var _S292 : f32 = _S286 - f32(_S287);
        var _S293 : f32 = _S289 - f32(_S290);
        var _S294 : u32 = _S291 + u32(24);
        var _S295 : f32 = SHEEN_ALBEDO_0[_S291] + (SHEEN_ALBEDO_0[_S294] - SHEEN_ALBEDO_0[_S291]) * _S292;
        var _S296 : u32 = _S291 + u32(1);
        var _S297 : f32 = SHEEN_ALBEDO_0[_S296] + (SHEEN_ALBEDO_0[_S294 + u32(1)] - SHEEN_ALBEDO_0[_S296]) * _S292;
        var _S298 : SheenProfile = SheenProfile_x24init_0(true, exp(_S295 + (_S297 - _S295) * _S293));
        profile_0 = _S298;
    }
    else
    {
        profile_0 = _S283;
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
    var _S299 : BSDFLobes;
    _S299.v_dot_h = v_dot_h_0;
    _S299.n_dot_h = n_dot_h_0;
    _S299.refracted = refracted_0;
    _S299.F = F_0;
    _S299.F_greyscale = F_greyscale_0;
    _S299.reflect_weight = reflect_weight_0;
    _S299.diffuse_weight = diffuse_weight_0;
    _S299.refract_weight = refract_weight_0;
    _S299.p_diffuse = p_diffuse_0;
    _S299.p_reflect = p_reflect_0;
    _S299.p_refract = p_refract_0;
    _S299.translucent_share = translucent_share_0;
    _S299.sheen = sheen_1;
    _S299.p_sheen_velvet = p_sheen_velvet_0;
    _S299.view = view_0;
    _S299.tangent = tangent_2;
    _S299.alphas = alphas_1;
    _S299.visible = visible_0;
    return _S299;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_4, t_4)), dot(w_1, n_4));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S300 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S301 : f32 = _S300.x;
    var _S302 : f32 = _S300.y;
    var _S303 : f32 = _S301 * _S301 + _S302 * _S302;
    const _S304 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S305 : vec3<f32> = vec3<f32>(- _S302, _S301, 0.0f);
    var _S306 : f32 = (inverseSqrt((_S303)));
    var _S307 : vec3<f32> = _S305 * vec3<f32>(_S306);
    var _S308 : bool = _S303 > 0.0f;
    var _S309 : vec3<f32> = select(_S304, _S307, _S308);
    var _S310 : vec3<f32> = cross(_S300, _S309);
    var _S311 : f32 = sqrt(U1_0);
    var _S312 : f32 = 6.28318548202514648f * U2_0;
    var _S313 : f32 = _S311 * cos(_S312);
    var t2_0 : f32 = _S311 * sin(_S312);
    var _S314 : f32 = 0.5f * (1.0f + _S300.z);
    var t2_1 : f32 = (1.0f - _S314) * sqrt(max(0.0f, 1.0f - _S313 * _S313)) + _S314 * t2_0;
    var _S315 : vec3<f32> = vec3<f32>(_S313) * _S309 + vec3<f32>(t2_1) * _S310;
    var _S316 : f32 = ((_S313));
    var _S317 : f32 = ((_S313));
    var _S318 : vec3<f32> = _S315 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S316 * _S317 - t2_1 * t2_1))) * _S300;
    var _S319 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S318.x, alpha_0 * _S318.y, max(0.0f, _S318.z)))));
    return _S319;
}

fn worldToTangent( v_2 : vec3<f32>,  n_5 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S320 : bool = (abs(dot(n_5, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S320)
    {
        const _S321 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S321;
    }
    else
    {
        a_4 = a_3;
    }
    var _S322 : vec3<f32> = (normalize((cross(n_5, a_4))));
    var _S323 : vec3<f32> = cross(n_5, _S322);
    return vec3<f32>(dot(v_2, _S322), dot(v_2, n_5), dot(v_2, _S323));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S324 : Random = pcg((*random_state_3));
    var _S325 : Random = pcg(_S324.state);
    (*random_state_3) = _S325.state;
    var _S326 : f32 = frame_0.alphas.x;
    var _S327 : bool = _S326 > 0.0f;
    if(_S327)
    {
        var _S328 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S329 : f32 = frame_0.alphas.y;
        var _S330 : vec3<f32> = (normalize((vec3<f32>(_S326 * _S328.x, _S329 * _S328.y, _S328.z))));
        var _S331 : vec3<f32> = sampleGGXVNDF(_S330, 1.0f, _S324.value, _S325.value);
        var _S332 : vec3<f32> = (normalize((vec3<f32>(_S326 * _S331.x, _S329 * _S331.y, _S331.z))));
        return vec3<f32>(_S332.x) * frame_0.tangent + vec3<f32>(_S332.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S332.z) * n_i_2;
    }
    var _S333 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S334 : vec3<f32> = sampleGGXVNDF(_S333.xzy, alpha_1, _S324.value, _S325.value);
    var _S335 : vec3<f32> = _S334.xzy;
    var _S336 : vec3<f32> = tangentToWorld(_S335, n_i_2);
    return _S336;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S337 : vec3<f32> = ((-(in_dir_0)));
    var _S338 : f32 = (sign((dot(n_6, _S337))));
    var _S339 : f32 = material_6.roughness;
    var _S340 : vec3<f32> = sampleHalfVector(_S337, n_6 * vec3<f32>(_S338), _S339 * _S339, frame_1, &(state_2));
    return _S340;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_7 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S341 : vec3<f32> = ((-(in_dir_1)));
    var _S342 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S341 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S343 : vec3<f32> = (normalize((_S342)));
    var _S344 : f32 = (sign((dot(n_7, _S341))));
    var _S345 : f32 = (sign((dot(_S342, n_7 * vec3<f32>(_S344)))));
    return _S343 * vec3<f32>(_S345);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S346 : vec3<f32> = ((-(in_dir_2)));
    var _S347 : vec3<f32> = (normalize((_S346 + out_dir_1)));
    return _S347;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S348 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S348 / (_S348 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S348)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S349 : f32 = alphas_3.x;
    var _S350 : f32 = h_0.x / _S349;
    var _S351 : f32 = alphas_3.y;
    var _S352 : f32 = h_0.y / _S351;
    var _S353 : f32 = h_0.z;
    var _S354 : f32 = _S350 * _S350 + _S352 * _S352 + _S353 * _S353;
    return 1.0f / max(3.14159274101257324f * _S349 * _S351 * _S354 * _S354, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_7 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S355 : f32 = dot(ggx_n_0, v_4);
    var _S356 : f32 = dot(n_i_3, ggx_n_0);
    var _S357 : f32 = eta_i_3 / eta_o_3;
    var _S358 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S357))));
    var _S359 : f32 = min(sqrt(material_7.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S360 : f32 = _S359 * _S359;
    var _S361 : f32 = (1.0f + _S359) / (1.0f - _S359);
    var _S362 : f32 = abs(_S355);
    var _S363 : bool = eta_i_3 > eta_o_3;
    var _S364 : f32 = select(1.0f, _S361, _S363);
    var _S365 : f32 = select(_S361, 1.0f, _S363);
    var _S366 : f32 = fresnel(_S362, _S364, _S365);
    var _S367 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S355 * _S355)) >= (eta_o_3 * eta_o_3);
    var _S368 : vec3<f32> = material_7.specular_tint * vec3<f32>(_S360);
    var _S369 : vec3<f32> = vec3<f32>(1.0f);
    var _S370 : vec3<f32> = _S368 + (_S369 - _S368) * vec3<f32>((_S366 - _S360)) / vec3<f32>((1.0f - _S360));
    var _S371 : vec3<f32> = vec3<f32>(1.0f);
    var _S372 : vec3<f32> = select(_S370, _S371, _S367);
    var _S373 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S374 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S375 : vec3<f32> = _S369 - material_7.sheen * vec3<f32>(_S374);
        var _S376 : f32 = rgb_to_greyscale(material_7.sheen);
        var _S377 : f32 = _S376 * _S374;
        var _S378 : vec3<f32> = material_7.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S375;
        sheen_component_0 = _S377;
        sheen_2 = _S378;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S371;
        sheen_component_0 = 0.0f;
        sheen_2 = _S373;
        view_1 = _S373;
    }
    var _S379 : vec3<f32> = (mix((_S372), (material_7.albedo), (material_7.metallic)));
    var F_1 : vec3<f32> = _S379 * scale_0;
    var _S380 : f32 = rgb_to_greyscale(F_1);
    var _S381 : f32 = 1.0f - material_7.metallic;
    var _S382 : vec3<f32> = _S369 - _S372;
    var _S383 : vec3<f32> = vec3<f32>(((1.0f - material_7.transmission) * _S381)) * _S382 * scale_0;
    var _S384 : vec3<f32> = vec3<f32>((material_7.transmission * _S381)) * _S382 * scale_0;
    var _S385 : f32 = max(_S380, 0.0f);
    var _S386 : f32 = rgb_to_greyscale(_S383);
    var _S387 : f32 = max(_S386, 0.0f);
    var _S388 : f32 = rgb_to_greyscale(_S384);
    var _S389 : f32 = (sign((length(_S358))));
    var _S390 : f32 = max(_S388 * _S389, 0.0f);
    var _S391 : f32 = _S385 + _S387 + _S390;
    var _S392 : f32 = min(sheen_component_0, 1.0f);
    var _S393 : bool = sheen_component_0 > 0.0f;
    var _S394 : bool;
    if(_S393)
    {
        _S394 = !(_S391 > 0.0f);
    }
    else
    {
        _S394 = false;
    }
    var _S395 : f32 = select(_S392, 1.0f, _S394);
    var _S396 : f32 = (1.0f - _S395) / max(_S391, 0.0000152587890625f);
    var _S397 : f32 = _S387 * _S396;
    var _S398 : f32 = _S385 * _S396;
    var _S399 : f32 = _S390 * _S396;
    var _S400 : bool = (frame_2.alphas.x) > 0.0f;
    var visible_1 : f32;
    if(_S400)
    {
        var _S401 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S402 : f32 = anisotropicG1(_S401, frame_2.alphas);
        var _S403 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S404 : f32 = anisotropicD(_S403, frame_2.alphas);
        var _S405 : f32 = _S402 * _S404;
        visible_1 = _S405;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S355, _S356, _S358, F_1, _S380, 1.0f, _S383, _S384, _S397, _S398, _S399, 0.0f, sheen_2, _S395, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_8 : Material) -> f32
{
    var _S406 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S407 : f32 = rgb_to_greyscale(material_8.albedo);
    var _S408 : f32 = _S406 / (_S407 + _S406);
    var _S409 : bool = _S406 > 0.0f;
    var _S410 : f32 = select(0.0f, _S408, _S409);
    return _S410;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S411 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S412 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S413 : f32 = 1.0f - lobes_0.translucent_share;
    var _S414 : bool = n_i_dot_l_0 < 0.0f;
    var _S415 : f32 = select(_S413, lobes_0.translucent_share, _S414);
    var _S416 : f32 = _S412 * _S415;
    var _S417 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S418 : f32 = select(_S411, _S416, _S417);
    var _S419 : bool = n_i_dot_v_0 > 0.0f;
    var _S420 : f32 = select(0.0f, _S418, _S419);
    return _S420;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_9 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S421 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S422 : vec3<f32> = select(material_9.albedo, material_9.translucent, _S421);
    var _S423 : f32 = 1.0f - lobes_1.translucent_share;
    var _S424 : f32 = select(_S423, lobes_1.translucent_share, _S421);
    var _S425 : vec3<f32> = _S422 / vec3<f32>(_S424);
    var _S426 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S427 : vec3<f32> = select(material_9.albedo, _S425, _S426);
    return lobes_1.diffuse_weight * _S427 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S428 : f32 = alpha_4 * alpha_4;
    var _S429 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S428 + (1.0f - _S428) * n_dot_x_0 * n_dot_x_0));
    var _S430 : bool = alpha_4 > 0.0f;
    var _S431 : f32 = select(1.0f, _S429, _S430);
    return _S431;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S432 : f32 = alpha_5 * alpha_5;
    var _S433 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S432 * n_dot_h_1 * n_dot_h_1;
    return _S432 / max(3.14159274101257324f * _S433 * _S433, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S434 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S435 : f32 = _S434 * lobes_2.v_dot_h;
    var _S436 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S437 : f32 = _S435 * _S436 / n_i_dot_v_1;
    var _S438 : bool = alpha_6 > 0.0f;
    var _S439 : bool;
    if(_S438)
    {
        _S439 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S439 = false;
    }
    if(_S439)
    {
        _S439 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S439 = false;
    }
    if(_S439)
    {
        _S439 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S439 = false;
    }
    var _S440 : f32 = select(0.0f, _S437, _S439);
    var _S441 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S441)
    {
        var _S442 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S443 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S443)
        {
            _S439 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S439 = false;
        }
        if(_S439)
        {
            _S439 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S439 = false;
        }
        var _S444 : f32 = select(0.0f, _S442, _S439);
        pdf_h_0 = _S444;
    }
    else
    {
        pdf_h_0 = _S440;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S445 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S446 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S447 : f32 = lobes_3.p_refract * _S445 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S446 * _S446);
    var _S448 : bool = eta_i_5 != eta_o_5;
    var _S449 : bool;
    if(_S448)
    {
        _S449 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S449 = false;
    }
    var _S450 : f32 = select(0.0f, _S447, _S449);
    return _S450;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_10 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S451 : f32 = - dot(n_i_5, l_1);
    var _S452 : f32 = smithG1(alpha_8, max(_S451, 0.0f));
    var _S453 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S453)
    {
        var _S454 : vec3<f32> = ((-(n_i_5)));
        var _S455 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S454);
        var _S456 : f32 = anisotropicG1(_S455, lobes_4.alphas);
        G1_l_0 = _S456;
    }
    else
    {
        G1_l_0 = _S452;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_10.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S457 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S458 : bool = n_i_dot_l_2 > 0.0f;
    var _S459 : bool;
    if(_S458)
    {
        _S459 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S459 = false;
    }
    var _S460 : f32 = select(0.0f, _S457, _S459);
    return _S460;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_11 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S461 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S462 : f32 = dot(n_i_6, _S461);
    var _S463 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S464 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S465 : f32 = 1.0f / max(material_11.sheen_roughness, 0.05000000074505806f);
    var _S466 : f32 = (2.0f + _S465) * pow(max(1.0f - _S462 * _S462, 0.0f), 0.5f * _S465) * 0.5f * 0.31830987334251404f / max(4.0f * (_S463 + _S464 - _S463 * _S464), 0.0000152587890625f);
    return lobes_6.sheen * vec3<f32>((_S466 * _S463 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S467 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S468 : f32 = lobes_7.p_reflect * _S467 / (4.0f * lobes_7.v_dot_h);
    var _S469 : bool = _S467 > 0.0f;
    var _S470 : f32 = select(0.0f, _S468, _S469);
    return _S470;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_12 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S471 : f32 = dot(n_i_7, l_3);
    var _S472 : f32 = smithG1(alpha_12, max(_S471, 0.0f));
    var _S473 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S473)
    {
        var _S474 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S475 : f32 = anisotropicG1(_S474, lobes_8.alphas);
        G1_l_1 = _S475;
    }
    else
    {
        G1_l_1 = _S472;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_8 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_0 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S476 : vec3<f32> = ((-(in_dir_4)));
    var _S477 : f32 = dot(n_8, _S476);
    var _S478 : f32 = (sign((_S477)));
    var _S479 : vec3<f32> = n_8 * vec3<f32>(_S478);
    var _S480 : AnisotropicFrame = anisotropicFrame(material_13, _S479);
    var _S481 : f32 = dot(_S479, out_dir_2);
    var _S482 : f32 = material_13.roughness;
    var _S483 : f32 = _S482 * _S482;
    var _S484 : SheenProfile = sheenProfile(_S476, _S479, material_13);
    var _S485 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S486 : bool = _S485 > 0.0f;
    var _S487 : bool = (dot(n_8, out_dir_2) * _S477) < 0.0f;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S488 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S488;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S489 : vec3<f32> = vec3<f32>(0.0f);
    var _S490 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S489, _S489, 0.0f, 0.0f, _S489, _S489, 0.0f, 0.0f, 0.0f, 0.0f, _S489, 0.0f, _S489, _S489, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S490;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S489;
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
        var _S491 : u32;
        if(i_0 == u32(3))
        {
            _S491 = u32(4);
        }
        else
        {
            _S491 = i_0;
        }
        var _S492 : bool = _S491 == u32(0);
        var _S493 : bool;
        if(_S492)
        {
            _S493 = _S486;
        }
        else
        {
            _S493 = false;
        }
        var _S494 : bool;
        if(_S493)
        {
            _S494 = _S487;
        }
        else
        {
            _S494 = _S491 == u32(1);
        }
        var _S495 : bool = _S494 != refracted_1;
        if(_S495)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S496 : u32;
        if(_S491 == u32(4))
        {
            _S496 = u32(2);
        }
        else
        {
            _S496 = _S491;
        }
        var _S497 : bool = _S496 != half_of_0;
        var half_of_1 : u32;
        if(_S497)
        {
            var _S498 : bool = _S496 == u32(0);
            if(_S498)
            {
                var _S499 : vec3<f32> = sampledHalf(in_dir_4, n_8, material_13, random_state_5, _S480);
                ggx_n_1 = _S499;
            }
            else
            {
                var _S500 : bool = _S496 == u32(1);
                if(_S500)
                {
                    var _S501 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_8, eta_i_8, eta_o_8);
                    ggx_n_1 = _S501;
                }
                else
                {
                    var _S502 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S502;
                }
            }
            var _S503 : vec3<f32> = ((-(in_dir_4)));
            var _S504 : BSDFLobes = bsdfLobes(in_dir_4, _S503, _S479, ggx_n_1, material_13, eta_i_8, eta_o_8, _S480, _S484);
            lobe_terms_0 = _S504;
            var _S505 : f32 = translucentShare(material_13);
            lobe_terms_0.translucent_share = _S505;
            half_of_1 = _S496;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S491)
        {
        case u32(0):
            {
                var _S506 : f32 = diffusePDF(_S481, 0.0f, abs(_S477), _S483, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S506;
                var _S507 : vec3<f32> = diffuseBSDF(out_dir_2, _S479, _S483, material_13, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S507;
            }
        case u32(1):
            {
                var _S508 : f32 = refractPDF(_S481, dot(out_dir_2, ggx_n_1), abs(_S477), _S483, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S508;
                var _S509 : vec3<f32> = refractBSDF(out_dir_2, _S479, _S483, material_13, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S509;
            }
        case u32(4):
            {
                var _S510 : f32 = sheenVelvetPDF(_S481, 0.0f, abs(_S477), _S483, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S510;
                var _S511 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S479, _S483, material_13, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S511;
            }
        default :
            {
                var _S512 : f32 = reflectPDF(_S481, 0.0f, abs(_S477), _S483, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S512;
                var _S513 : vec3<f32> = reflectBSDF(out_dir_2, _S479, _S483, material_13, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S513;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S489;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S514 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S514)
        {
            var f_2 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_2;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
}

fn lightBSDF_0( in_dir_5 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_2 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  competing_0 : bool,  random_state_6 : u32) -> vec3<f32>
{
    var _S515 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(4)>;
    var pdfs_1 : array<f32, i32(4)>;
    var _S516 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S515, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S517 : bool = !competing_0;
    var _S518 : bool;
    if(_S517)
    {
        _S518 = true;
    }
    else
    {
        _S518 = (light_0.density) == 0.0f;
    }
    if(_S518)
    {
        return _S516 * light_0.radiance;
    }
    var _S519 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S519;
    loop
    {
        if(i_4 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S520 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S520)
        {
            var _S521 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S521 * _S521)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_4 : vec3<f32>) -> f32
{
    var _S522 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S523 : vec2<u32> = _S522 - vec2<u32>(u32(1), u32(0));
    var _S524 : vec2<f32> = vec2<f32>(atan2(- dir_4.z, - dir_4.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_4.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S525 : vec2<u32> = min(vec2<u32>(_S524 * vec2<f32>(_S523)), _S523 - vec2<u32>(u32(1)));
    var _S526 : vec4<f32> = (textureLoad(environment_cdf, (_S525), 0));
    var _S527 : f32 = _S526.y;
    var _S528 : u32 = _S523.x;
    var _S529 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S528, _S525.y)), 0));
    var _S530 : f32 = _S527 * _S529.y;
    return _S530 * f32(_S528 * _S523.y) / (19.73921012878417969f * length(dir_4.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_5 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_5, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_6 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_2 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var _S531 : bool = wrongSide_0(is_inside_1, false, dir_6, surface_1.geometry_n);
    var _S532 : vec3<f32> = BSDF(in_dir_6, dir_6, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S531, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S533 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_3 : vec3<f32> = _S533;
    loop
    {
        if(i_6 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S534 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S534)
        {
            var _S535 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S535;
            var f_4 : vec3<f32> = f_3 + (*terms_0)[i_6];
            f_3 = f_4;
        }
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    return f_3;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_7 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_8 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(4)>;
    var pdfs_3 : array<f32, i32(4)>;
    var _S536 : vec3<f32> = skyLobes_0(in_dir_7, dir_7, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S536;
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
    var _S537 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S537;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S538 : u32 = (low_0 + high_0) / u32(2);
        var _S539 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S538)), 0));
        var _S540 : bool = (_S539.x) > u_0;
        if(_S540)
        {
            high_0 = _S538;
        }
        else
        {
            var _S541 : u32 = _S538 + u32(1);
            low_0 = _S541;
        }
    }
    return low_0;
}

fn SkySample_x24init_0( dir_8 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S542 : SkySample;
    _S542.dir = dir_8;
    _S542.radiance = radiance_2;
    _S542.color = color_2;
    _S542.random_state = random_state_9;
    return _S542;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_9 : vec3<f32>) -> vec3<f32>
{
    var _S543 : bool = wrongSide_0(is_inside_3, false, dir_9, surface_3.geometry_n);
    var _S544 : bool = is_inside_3 != _S543;
    var _S545 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S546 : vec3<f32> = select(surface_3.smooth_n, _S545, _S544);
    var _S547 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S546, dir_9);
    var _S548 : vec3<f32> = (env_map_sample((dir_9)));
    var _S549 : vec3<f32> = (shadowTransmittance((_S547), (4.294967296e+09f)));
    return _S548 * _S549;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S550 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S551 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S552 : vec2<u32> = _S550 - _S551;
    var _S553 : Random = pcg(init_random_state_1);
    var _S554 : Random = pcg(_S553.state);
    var _S555 : Random = pcg(_S554.state);
    var _S556 : Random = pcg(_S555.state);
    var _S557 : u32 = _S552.x;
    var _S558 : u32 = searchCDF_0(vec2<u32>(_S557, u32(0)), vec2<u32>(u32(0), u32(1)), _S552.y, _S553.value);
    var _S559 : u32 = searchCDF_0(vec2<u32>(u32(0), _S558), _S551, _S557, _S554.value);
    var _S560 : vec2<f32> = (vec2<f32>(f32(_S559), f32(_S558)) + vec2<f32>(_S555.value, _S556.value)) / vec2<f32>(_S552) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S561 : f32 = _S560.y;
    var _S562 : f32 = sin(_S561);
    var _S563 : f32 = _S560.x;
    var _S564 : vec3<f32> = vec3<f32>(_S562 * cos(_S563), cos(_S561), _S562 * sin(_S563));
    var _S565 : f32 = environmentPdf_0(_S564);
    var _S566 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S564, surface_4, eta_2, is_inside_4, _S565, lobe_state_0);
    var _S567 : bool = !(_S565 > 0.0f);
    var _S568 : bool;
    if(_S567)
    {
        _S568 = true;
    }
    else
    {
        _S568 = (all((_S566 == vec3<f32>(0.0f))));
    }
    if(_S568)
    {
        var _S569 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S564, _S569, _S569, _S556.state);
    }
    var _S570 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S564);
    return SkySample_x24init_0(_S564, _S570, _S566 * _S570, _S556.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S571 : vec3<f32> = a_5 / b_1;
    var _S572 : vec3<f32> = vec3<f32>(0.0f);
    var _S573 : vec3<bool> = b_1 == _S572;
    var _S574 : vec3<f32> = select(_S571, _S572, _S573);
    return _S574;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_5 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S575 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S576 : u32 = (insertBits((_S575), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S576;
    candidate_0.f = f_5;
    return candidate_0;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S577 : f32 = rgb_to_greyscale(weight_0);
    var _S578 : bool = _S577 > 0.0f;
    var _S579 : bool;
    if(_S578)
    {
        _S579 = _S577 < 3.00000000549775576e+38f;
    }
    else
    {
        _S579 = false;
    }
    var _S580 : bool = !_S579;
    if(_S580)
    {
        return;
    }
    var _S581 : f32 = (*sel_0).w_sum + _S577;
    (*sel_0).w_sum = _S581;
    var _S582 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S582;
    var _S583 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S583.state;
    var _S584 : bool = (_S583.value * (*sel_0).w_sum) <= _S577;
    if(_S584)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S585 : vec2<u32> = (uniforms_uint.environment_map_size);
    return (all((_S585 > vec2<u32>(u32(1)))));
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
    var _S586 : SampleBSDF;
    _S586.unit_direction = unit_direction_1;
    _S586.throughput = throughput_0;
    _S586.random_state = random_state_10;
    _S586.refracted = refracted_3;
    _S586.lobe = lobe_1;
    _S586.pdf = pdf_4;
    return _S586;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S587 : vec3<f32> = vec3<f32>(1.0f);
    var _S588 : SampleBSDF = SampleBSDF_x24init_0(_S587, _S587, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S588;
    var _S589 : Random = pcg(random_state_11);
    var _S590 : Random = pcg(_S589.state);
    sample_1.random_state = _S590.state;
    var _S591 : f32 = _S589.value;
    var _S592 : f32 = sqrt(max(0.0f, 1.0f - _S591 * _S591));
    var _S593 : f32 = 6.28318548202514648f * _S590.value;
    var _S594 : vec3<f32> = tangentToWorld(vec3<f32>(_S592 * cos(_S593), _S589.value, _S592 * sin(_S593)), n_i_8);
    sample_1.unit_direction = _S594;
    sample_1.lobe = u32(4);
    var _S595 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S595;
    var _S596 : f32 = sheenVelvetPDF(_S589.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S596;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S597 : f32 = sqrt(random_1_0);
    var _S598 : f32 = 6.28318548202514648f * random_2_0;
    var _S599 : f32 = _S597 * cos(_S598);
    var _S600 : f32 = _S597 * sin(_S598);
    var _S601 : f32 = sqrt(max(0.0f, 1.0f - _S599 * _S599 - _S600 * _S600));
    return vec3<f32>(_S599, _S601, _S600);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S602 : vec3<f32> = vec3<f32>(1.0f);
    var _S603 : SampleBSDF = SampleBSDF_x24init_0(_S602, _S602, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S603;
    var _S604 : Random = pcg(random_state_12);
    var _S605 : Random = pcg(_S604.state);
    sample_2.random_state = _S605.state;
    var _S606 : vec3<f32> = sampleCosWeightedHemisphere(_S604.value, _S605.value);
    var _S607 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S608 : f32 = _S606.y;
    var _S609 : f32 = - _S608;
    var _S610 : f32 = select(_S608, _S609, _S607);
    var _S611 : vec3<f32> = tangentToWorld(vec3<f32>(_S606.x, _S610, _S606.z), n_i_9);
    sample_2.unit_direction = _S611;
    sample_2.refracted = _S607;
    sample_2.lobe = u32(0);
    var _S612 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S612;
    var _S613 : f32 = diffusePDF(_S610, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S613;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S614 : vec3<f32> = vec3<f32>(1.0f);
    var _S615 : SampleBSDF = SampleBSDF_x24init_0(_S614, _S614, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S615;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S616 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S616;
    var _S617 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S617;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S618 : vec3<f32> = vec3<f32>(1.0f);
    var _S619 : SampleBSDF = SampleBSDF_x24init_0(_S618, _S618, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S619;
    var _S620 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S620;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S621 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S621;
    var _S622 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S622;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_9 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S623 : vec3<f32> = ((-(in_dir_9)));
    var _S624 : f32 = dot(n_9, _S623);
    var _S625 : f32 = (sign((_S624)));
    var n_i_12 : vec3<f32> = n_9 * vec3<f32>(_S625);
    var _S626 : f32 = abs(_S624);
    var _S627 : f32 = material_19.roughness;
    var _S628 : f32 = _S627 * _S627;
    var _S629 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S630 : SheenProfile = sheenProfile(_S623, n_i_12, material_19);
    var _S631 : vec3<f32> = sampleHalfVector(_S623, n_i_12, _S628, _S629, &(random_state_15));
    var _S632 : BSDFLobes = bsdfLobes(in_dir_9, _S623, n_i_12, _S631, material_19, eta_i_14, eta_o_14, _S629, _S630);
    var lobes_13 : BSDFLobes = _S632;
    var _S633 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S633;
    var _S634 : Random = pcg(random_state_15);
    random_state_15 = _S634.state;
    var _S635 : bool = (_S634.value) < (lobes_13.p_sheen_velvet);
    if(_S635)
    {
        var _S636 : SampleBSDF = sheenVelvetSample(n_i_12, _S626, _S628, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S636;
    }
    var _S637 : f32 = _S634.value - lobes_13.p_sheen_velvet;
    var _S638 : bool = _S637 < (lobes_13.p_diffuse);
    if(_S638)
    {
        var _S639 : SampleBSDF = diffuseSample(_S637, n_i_12, _S626, _S628, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S639;
    }
    var _S640 : bool = _S637 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S640)
    {
        var _S641 : SampleBSDF = refractSample(_S631, n_i_12, _S626, _S628, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S641;
    }
    var _S642 : SampleBSDF = reflectSample(in_dir_9, _S631, n_i_12, _S626, _S628, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S642;
}

fn escapeWeight_0( pdf_5 : f32,  dir_10 : vec3<f32>) -> f32
{
    var _S643 : bool = pdf_5 <= 0.0f;
    var _S644 : bool;
    if(_S643)
    {
        _S644 = true;
    }
    else
    {
        var _S645 : bool = environmentMapped_0();
        _S644 = !_S645;
    }
    if(_S644)
    {
        return 1.0f;
    }
    var _S646 : f32 = environmentPdf_0(dir_10);
    return pdf_5 / (pdf_5 + _S646);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S647 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S647.x, max(_S647.y, _S647.z)), 0.0f, 1.0f);
}

fn environment_0( dir_11 : vec3<f32>) -> vec3<f32>
{
    var _S648 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S649 : bool = (all((_S648 > vec2<u32>(u32(1)))));
    if(_S649)
    {
        var _S650 : vec3<f32> = (env_map_sample((dir_11)));
        return _S650;
    }
    var _S651 : vec3<f32> = (uniforms_float.ambient);
    return _S651;
}

fn walk_0( dom_1 : Domain,  r_4 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S652 : vec3<f32> = vec3<f32>(0.0f);
    var _S653 : Shift = Shift_x24init_0(_S652, 0.0f);
    var _S654 : u32 = (extractBits((r_4.path), (u32(0)), (u32(5))));
    var _S655 : u32 = (extractBits((r_4.path), (u32(5)), (u32(5))));
    var _S656 : u32 = (extractBits((r_4.path), (u32(10)), (u32(2))));
    var _S657 : u32 = (extractBits((r_4.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S658 : bool = _S657 >= u32(3);
        var _S659 : u32 = select(u32(0), u32(1), _S658);
        var _S660 : u32 = _S654 + _S659;
        var _S661 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S660 > _S661;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S653;
    }
    var _S662 : u32 = _S655 - u32(1);
    var _S663 : bool = _S657 == u32(3);
    var _S664 : u32 = select(u32(0), u32(1), _S663);
    var _S665 : u32 = _S654 + _S664;
    var _S666 : bool = _S656 == u32(0);
    var _S667 : u32 = select(_S662, _S665, _S666);
    var _S668 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_4.rc.zw))), r_4.rc.x, r_4.rc.y, u32(0), 0.0f);
    var _S669 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S670 : Ray = Ray_x24init_0(dom_1.x1, _S669);
    var ray_2 : Ray = _S670;
    var hit_2 : Hit = dom_1.hit;
    var _S671 : vec3<f32> = vec3<f32>(1.0f);
    var _S672 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S652, _S652, _S652);
    var nee_vertex_0 : NEEVertex = _S672;
    var _S673 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S673;
    var _S674 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S652, 0.0f, vec4<u32>(u32(0)), _S652, _S652);
    var chain_0 : Reservoir = _S674;
    chain_0.seed = r_4.seed;
    is_inside_5 = false;
    var threshold_0 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S652;
    var reconnection_0 : vec3<f32> = _S652;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S671;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S675 : bool = (hit_2.is_point_light) == u32(1);
        var _S676 : bool;
        if(replay_0)
        {
            _S676 = _S656 == u32(1);
        }
        else
        {
            _S676 = false;
        }
        var _S677 : bool;
        if(_S676)
        {
            _S677 = b_2 == _S655;
        }
        else
        {
            _S677 = false;
        }
        var _S678 : bool;
        if(_S677)
        {
            var _S679 : bool = (hit_2.instance_index) != (_S668.instance_index);
            if(_S679)
            {
                _S678 = true;
            }
            else
            {
                _S678 = (hit_2.triangle_index) != (_S668.triangle_index);
            }
        }
        else
        {
            _S678 = false;
        }
        if(_S678)
        {
            return _S653;
        }
        var _S680 : Surface = Surface_x24init_0(_S652, _S652, 0.0f, Material_x24init_0(_S652, _S652, 0.0f, 0.0f, 0.0f, 0.0f, _S652, _S671, 1.0f, _S652, _S652, 0.5f, 0.0f, 0.0f, _S652), false, u32(0));
        var _S681 : bool = !_S675;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S681)
        {
            var _S682 : u32 = stream(r_4.seed, b_2);
            var _S683 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S682)));
            var surface_6 : Surface = facingRay_0(_S683, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S684 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S685 : vec3<f32> = throughput_2 * _S684;
                front_n_0 = _S685;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S686 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S687 : bool = b_2 == u32(0);
            if(_S687)
            {
                var _S688 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S688;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S689 : vec3<f32> = front_n_0;
            var _S690 : f32 = geometry_density_0;
            scatter_0 = _S686;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S690;
            surface_5 = surface_6;
            front_n_0 = _S683.smooth_n;
            throughput_3 = _S689;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S680;
            front_n_0 = _S652;
            throughput_3 = throughput_2;
        }
        var _S691 : bool;
        if(scatter_0)
        {
            _S691 = prev_0.rough;
        }
        else
        {
            _S691 = false;
        }
        var _S692 : bool;
        if(_S691)
        {
            _S692 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S692 = false;
        }
        var _S693 : Surface = surface_5;
        var _S694 : Surface = surface_5;
        var _S695 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S696 : vec2<f32> = vertexEta(_S693.material, _S695);
        var _S697 : bool;
        if(scatter_0)
        {
            var _S698 : u32 = (uniforms_uint.max_bounces);
            var _S699 : bool = b_2 >= _S698;
            if(_S699)
            {
                _S697 = true;
            }
            else
            {
                var _S700 : bool = neeDecision(_S693.material, _S695, _S696.x, _S696.y);
                _S697 = _S700;
            }
        }
        else
        {
            _S697 = false;
        }
        var _S701 : bool = isTranslucent_0(_S693.material);
        var _S702 : vec3<f32> = emitted_0(_S693.material.emissive, ray_2.unit_direction, front_n_0);
        var emission_0 : vec3<f32>;
        if(_S675)
        {
            var _S703 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S703;
        }
        else
        {
            emission_0 = _S702;
        }
        var _S704 : bool = !replay_0;
        var _S705 : bool;
        if(_S704)
        {
            _S705 = true;
        }
        else
        {
            _S705 = b_2 >= _S667;
        }
        var _S706 : bool;
        if(_S705)
        {
            var _S707 : f32 = rgb_to_greyscale(emission_0);
            _S706 = _S707 > 0.0f;
        }
        else
        {
            _S706 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S706)
        {
            var _S708 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S708);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S709 : bool;
        if(replay_0)
        {
            _S709 = _S656 == u32(1);
        }
        else
        {
            _S709 = false;
        }
        var _S710 : bool;
        if(_S709)
        {
            _S710 = b_2 > _S655;
        }
        else
        {
            _S710 = false;
        }
        var _S711 : bool;
        if(_S710)
        {
            _S711 = b_2 == _S654;
        }
        else
        {
            _S711 = false;
        }
        var _S712 : bool;
        if(_S711)
        {
            var _S713 : bool = _S657 == u32(1);
            if(_S713)
            {
                _S712 = true;
            }
            else
            {
                _S712 = _S657 == u32(2);
            }
        }
        else
        {
            _S712 = false;
        }
        if(_S712)
        {
            var _S714 : bool = _S675 != (_S657 == u32(2));
            if(_S714)
            {
                return _S653;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S715 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S716 : bool = _S715 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S717 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S718 : u32 = (insertBits((_S717), (u32(1)), (u32(10)), (u32(2))));
        var _S719 : u32 = (insertBits((_S718), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S720 : bool = prev_0.inside;
        var _S721 : u32 = select(u32(0), u32(1), _S720);
        var _S722 : u32 = (insertBits((_S719), (_S721), (u32(22)), (u32(1))));
        here_0.path = _S722;
        var _S723 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S723;
        var _S724 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S724;
        var _S725 : bool;
        if(replay_0)
        {
            _S725 = _S656 == u32(1);
        }
        else
        {
            _S725 = false;
        }
        var _S726 : bool;
        if(_S725)
        {
            _S726 = b_2 == _S655;
        }
        else
        {
            _S726 = false;
        }
        var _S727 : bool = b_2 == _S667;
        var _S728 : bool;
        if(_S727)
        {
            var _S729 : bool = !scatter_0;
            if(_S729)
            {
                _S728 = true;
            }
            else
            {
                var _S730 : bool = _S656 != u32(1);
                if(_S730)
                {
                    _S728 = _S656 != u32(3);
                }
                else
                {
                    _S728 = false;
                }
            }
        }
        else
        {
            _S728 = false;
        }
        var _S731 : bool;
        if(_S728)
        {
            _S731 = _S656 == u32(2);
        }
        else
        {
            _S731 = false;
        }
        var _S732 : bool;
        if(_S731)
        {
            _S732 = !_S692;
        }
        else
        {
            _S732 = false;
        }
        var _S733 : bool;
        if(_S732)
        {
            _S733 = _S657 != u32(4);
        }
        else
        {
            _S733 = false;
        }
        var _S734 : bool = _S655 == _S654;
        var _S735 : bool;
        if(_S734)
        {
            _S735 = _S657 == u32(0);
        }
        else
        {
            _S735 = false;
        }
        var _S736 : bool;
        if(_S735)
        {
            _S736 = (hit_2.instance_index) == (_S668.instance_index);
        }
        else
        {
            _S736 = false;
        }
        var _S737 : bool;
        if(_S736)
        {
            _S737 = (hit_2.triangle_index) == (_S668.triangle_index);
        }
        else
        {
            _S737 = false;
        }
        var _S738 : bool;
        if(_S737)
        {
            _S738 = _S692;
        }
        else
        {
            _S738 = false;
        }
        var _S739 : bool = select(_S733, _S738, _S726);
        var _S740 : bool;
        if(_S697)
        {
            _S740 = select(scatter_0, _S739, replay_0);
        }
        else
        {
            _S740 = false;
        }
        var _S741 : TreeSample = TreeSample_x24init_0(_S652, _S652, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S740)
        {
            var _S742 : Surface = surface_5;
            var _S743 : bool = isTranslucent_0(_S693.material);
            var _S744 : u32 = stream(r_4.seed, b_2 + u32(64));
            var _S745 : TreeSample = sampleLightTree_0(ray_2.origin, _S694.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S743, _S744);
            var _S746 : bool = (any(((_S745.radiance) != _S652)));
            if(_S746)
            {
                var _S747 : f32 = _S696.x;
                var _S748 : f32 = _S696.y;
                var _S749 : u32 = (uniforms_uint.max_bounces);
                var _S750 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S745, _S694.smooth_n, _S742.geometry_n, _S693.material, _S747, _S748, b_2 < _S749, surface_5.random_state);
                lit_0 = _S750;
            }
            else
            {
                lit_0 = _S652;
            }
            light_1 = _S745;
        }
        else
        {
            light_1 = _S741;
            lit_0 = _S652;
        }
        var _S751 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S752 : bool;
        var _S753 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S726)
        {
            var _S754 : bool = !_S692;
            if(_S754)
            {
                return _S653;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S734)
            {
                _S751 = _S657 == u32(1);
            }
            else
            {
                _S751 = false;
            }
            if(_S751)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S734)
            {
                wrong_side_0 = _S657 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S755 : bool = !_S697;
                if(_S755)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S756 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S756 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S653;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S734)
            {
                refracted_4 = _S657 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S757 : bool = !_S697;
                if(_S757)
                {
                    return _S653;
                }
                var _S758 : f32 = environmentPdf_0(r_4.dir);
                var _S759 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S696, is_inside_5, _S758, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S759 * r_4.radiance / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S760 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S761 : bool = _S697 != (_S760 == u32(1));
            if(_S761)
            {
                return _S653;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S751 = _S727;
            }
            else
            {
                _S751 = false;
            }
            if(_S751)
            {
                var _S762 : bool = !scatter_0;
                if(_S762)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S763 : bool = _S656 != u32(1);
                    if(_S763)
                    {
                        wrong_side_0 = _S656 != u32(3);
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
                var _S764 : bool = _S656 == u32(2);
                if(_S764)
                {
                    _S676 = _S697;
                }
                else
                {
                    _S676 = false;
                }
                if(_S676)
                {
                    _S676 = !_S692;
                }
                else
                {
                    _S676 = false;
                }
                if(_S676)
                {
                    _S676 = _S657 == u32(4);
                }
                else
                {
                    _S676 = false;
                }
                if(_S676)
                {
                    var _S765 : u32 = stream(r_4.seed, b_2 + u32(256));
                    var _S766 : SkySample = sampleSky_0(ray_2, surface_5, _S696, is_inside_5, _S765, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S766.color, 1.0f);
                }
                if(_S764)
                {
                    is_inside_5 = _S697;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S692;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S767 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S768 : bool = !(_S767 > 0.0f);
                    if(_S768)
                    {
                        return _S653;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S666)
                {
                    is_inside_5 = _S657 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S675;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S666)
                {
                    is_inside_5 = _S657 == u32(1);
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
                    is_inside_5 = !_S692;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S653;
            }
            else
            {
                if(_S704)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S769 : bool = b_2 > u32(0);
                    if(_S769)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S716)
                        {
                            var _S770 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S770;
                        }
                        else
                        {
                            if(_S692)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S771 : vec3<f32> = throughput_3 * emission_1;
                        var _S772 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S771);
                        offer(&((*sel_1)), _S772, _S771 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S697)
                    {
                        var _S773 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S716)
                        {
                            var _S774 : vec3<f32> = safeDivide(_S773, chain_throughput_0);
                            candidate_3.radiance = _S774;
                        }
                        else
                        {
                            if(_S692)
                            {
                                candidate_3 = here_0;
                                var _S775 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S775;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S776 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S777 : u32 = (insertBits((_S776), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S777;
                            }
                        }
                        var _S778 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S773);
                        offer(&((*sel_1)), _S778, _S773 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S697)
                    {
                        var _S779 : bool = environmentMapped_0();
                        _S752 = _S779;
                    }
                    else
                    {
                        _S752 = false;
                    }
                    if(_S752)
                    {
                        var _S780 : u32 = (uniforms_uint.max_bounces);
                        _S753 = b_2 < _S780;
                    }
                    else
                    {
                        _S753 = false;
                    }
                    if(_S753)
                    {
                        var _S781 : u32 = stream(r_4.seed, b_2 + u32(256));
                        var _S782 : SkySample = sampleSky_0(ray_2, surface_5, _S696, is_inside_5, _S781, surface_5.random_state);
                        var _S783 : vec3<f32> = throughput_3 * _S782.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S716)
                        {
                            var _S784 : vec3<f32> = safeDivide(_S783, chain_throughput_0);
                            candidate_4.radiance = _S784;
                        }
                        else
                        {
                            if(_S692)
                            {
                                candidate_4 = here_0;
                                var _S785 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S785;
                                candidate_4.dir = _S782.dir;
                                candidate_4.radiance = _S782.radiance;
                            }
                            else
                            {
                                var _S786 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S787 : u32 = (insertBits((_S786), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S787;
                            }
                        }
                        var _S788 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S783);
                        offer(&((*sel_1)), _S788, _S783 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S789 : bool;
        var _S790 : bool;
        var _S791 : bool;
        var _S792 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S751 = _S727;
            }
            else
            {
                _S751 = false;
            }
            var _S793 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S794 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S795 : u32 = select(_S793, _S794, _S726);
            var refracted_5 : bool = _S795 == u32(1);
            var _S796 : SampleBSDF = SampleBSDF_x24init_0(_S652, _S652, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S796;
            var dir_12 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S751)
            {
                var _S797 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S798 : bool = is_inside_5 != (_S797 == u32(1));
                if(_S798)
                {
                    return _S653;
                }
                var _S799 : bool = _S656 == u32(1);
                if(_S799)
                {
                    var _S800 : vec3<f32> = (hitPosition((_S668)));
                    dir_12 = _S800;
                }
                else
                {
                    dir_12 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    var _S801 : bool = isTranslucent_0(_S693.material);
                    if(_S801)
                    {
                        wrong_side_0 = _S795 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S802 : vec3<f32> = dir_12 - ray_2.origin;
                        var _S803 : vec3<f32> = select(r_4.dir, _S802, _S799);
                        refracted_4 = (dot(_S694.smooth_n, _S803) * _S695) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S799)
                {
                    var _S804 : vec3<f32> = ray_2.origin;
                    var _S805 : Surface = surface_5;
                    var _S806 : vec3<f32> = (vec3<f32>(0) - _S694.smooth_n);
                    var _S807 : bool = is_inside_5 != refracted_4;
                    var _S808 : vec3<f32> = select(_S694.smooth_n, _S806, _S807);
                    var _S809 : vec3<f32> = (normalize((dir_12 - (_S804 + vec3<f32>(_S805.geometry_offset) * _S808))));
                    reconnection_1 = _S809;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S810 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S810)
                {
                    return _S653;
                }
                var _S811 : vec3<f32> = dir_12;
                dir_12 = reconnection_1;
                lobe_index_0 = _S795;
                wrong_side_0 = false;
                reconnection_1 = _S811;
            }
            else
            {
                var _S812 : bool = !_S726;
                if(_S812)
                {
                    var _S813 : f32 = _S696.x;
                    var _S814 : f32 = _S696.y;
                    var _S815 : vec2<f32> = vec2<f32>(0.0f);
                    var _S816 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S694.smooth_n, _S693.material, _S813, _S814, surface_5.random_state, _S815);
                    var bsdf_sampled_0 : SampleBSDF = _S816;
                    var _S817 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S693.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S818 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S817.geometry_n, _S693.material, _S813, _S814, bsdf_sampled_0.random_state, _S815);
                        bsdf_sampled_0.unit_direction = _S818.unit_direction;
                        bsdf_sampled_0.refracted = _S818.refracted;
                        bsdf_sampled_0.throughput = _S818.throughput;
                        bsdf_sampled_0.lobe = _S818.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S819 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S817.geometry_n))) * _S817.geometry_n;
                            bsdf_sampled_0.unit_direction = _S819;
                        }
                    }
                    var _S820 : u32 = bsdf_sampled_0.lobe;
                    var _S821 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S822 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S823 : f32 = bsdf_sampled_0.pdf;
                    var _S824 : f32 = select(_S823, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S824;
                    dir_12 = _S821;
                    lobe_index_0 = _S820;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S822;
                }
                else
                {
                    dir_12 = r_4.dir;
                    lobe_index_0 = _S795;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S751)
            {
                _S752 = true;
            }
            else
            {
                _S752 = _S726;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S752)
            {
                var _S825 : vec3<f32> = ray_2.unit_direction;
                var _S826 : f32 = (sign((_S695)));
                var _S827 : vec3<f32> = _S694.smooth_n * vec3<f32>(_S826);
                var _S828 : f32 = dot(_S827, dir_12);
                var _S829 : f32 = _S693.material.roughness;
                var _S830 : f32 = _S829 * _S829;
                var _S831 : AnisotropicFrame = anisotropicFrame(_S693.material, _S827);
                var _S832 : vec3<f32> = ((-(_S825)));
                var _S833 : SheenProfile = sheenProfile(_S832, _S827, _S693.material);
                var _S834 : vec3<f32> = reflectedHalf(_S825, dir_12);
                var _S835 : bool = lobe_index_0 == u32(1);
                if(_S835)
                {
                    var _S836 : vec3<f32> = refractedHalf(_S825, dir_12, _S694.smooth_n, _S696.x, _S696.y);
                    throughput_6 = _S836;
                }
                else
                {
                    throughput_6 = _S834;
                }
                var _S837 : bool = lobe_index_0 == u32(0);
                if(_S837)
                {
                    var _S838 : vec3<f32> = sampledHalf(_S825, _S694.smooth_n, _S693.material, surface_5.random_state, _S831);
                    throughput_7 = _S838;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S839 : vec3<f32> = ((-(_S825)));
                var _S840 : f32 = _S696.x;
                var _S841 : f32 = _S696.y;
                var _S842 : BSDFLobes = bsdfLobes(_S825, _S839, _S827, throughput_7, _S693.material, _S840, _S841, _S831, _S833);
                var lobe_terms_1 : BSDFLobes = _S842;
                var _S843 : f32 = translucentShare(_S693.material);
                lobe_terms_1.translucent_share = _S843;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S844 : f32 = diffusePDF(_S828, 0.0f, abs(_S695), _S830, lobe_terms_1, _S840, _S841);
                        var _S845 : vec3<f32> = diffuseBSDF(dir_12, _S827, _S830, _S693.material, lobe_terms_1);
                        density_5 = _S844;
                        chain_throughput_1 = _S845;
                    }
                case u32(1):
                    {
                        var _S846 : f32 = refractPDF(_S828, dot(dir_12, throughput_7), abs(_S695), _S830, lobe_terms_1, _S840, _S841);
                        var _S847 : vec3<f32> = refractBSDF(dir_12, _S827, _S830, _S693.material, lobe_terms_1);
                        density_5 = _S846;
                        chain_throughput_1 = _S847;
                    }
                case u32(4):
                    {
                        var _S848 : f32 = sheenVelvetPDF(_S828, 0.0f, abs(_S695), _S830, lobe_terms_1, _S840, _S841);
                        var _S849 : vec3<f32> = sheenVelvetBSDF(dir_12, _S827, _S830, _S693.material, lobe_terms_1);
                        density_5 = _S848;
                        chain_throughput_1 = _S849;
                    }
                default :
                    {
                        var _S850 : f32 = reflectPDF(_S828, 0.0f, abs(_S695), _S830, lobe_terms_1, _S840, _S841);
                        var _S851 : vec3<f32> = reflectBSDF(dir_12, _S827, _S830, _S693.material, lobe_terms_1);
                        density_5 = _S850;
                        chain_throughput_1 = _S851;
                    }
                }
                var _S852 : bool = density_5 > 0.0f;
                if(_S852)
                {
                    var _S853 : SampleBSDF = SampleBSDF_x24init_0(dir_12, chain_throughput_1, surface_5.random_state, _S835, lobe_index_0, density_5);
                    lobe_2 = _S853;
                }
            }
            var _S854 : bool = lobe_index_0 == u32(0);
            if(_S854)
            {
                _S753 = true;
            }
            else
            {
                _S753 = lobe_index_0 == u32(4);
            }
            var _S855 : bool = !_S753;
            if(_S855)
            {
                var _S856 : bool = (_S693.material.roughness) == 0.0f;
                if(_S856)
                {
                    _S789 = true;
                }
                else
                {
                    var _S857 : bool = lobe_index_0 == u32(1);
                    if(_S857)
                    {
                        _S789 = (_S696.x) == (_S696.y);
                    }
                    else
                    {
                        _S789 = false;
                    }
                }
            }
            else
            {
                _S789 = false;
            }
            var _S858 : bool = isTranslucent_0(_S693.material);
            if(_S858)
            {
                _S790 = _S854;
            }
            else
            {
                _S790 = false;
            }
            if(_S790)
            {
                _S791 = (dot(dir_12, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S791 = false;
            }
            if(_S697)
            {
                _S792 = !_S789;
            }
            else
            {
                _S792 = false;
            }
            var _S859 : bool;
            if(_S792)
            {
                _S859 = !wrong_side_0;
            }
            else
            {
                _S859 = false;
            }
            var _S860 : bool;
            if(_S859)
            {
                var _S861 : f32 = lobe_2.pdf;
                var _S862 : vec3<f32> = ray_2.origin;
                var _S863 : vec3<f32> = select(_S694.smooth_n, _S652, _S701);
                var _S864 : vec3<f32> = ray_2.origin;
                var _S865 : Surface = surface_5;
                var _S866 : vec3<f32> = (vec3<f32>(0) - _S694.smooth_n);
                var _S867 : vec3<f32> = select(_S694.smooth_n, _S866, _S791);
                var _S868 : NEEVertex = NEEVertex_x24init_0(false, _S861, _S862, _S863, _S864 + vec3<f32>(_S865.geometry_offset) * _S867);
                nee_vertex_0 = _S868;
            }
            else
            {
                var _S869 : bool = lobe_index_0 != u32(1);
                if(_S869)
                {
                    _S860 = true;
                }
                else
                {
                    _S860 = (_S696.x) != (_S696.y);
                }
                if(_S860)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S870 : bool = (lobe_2.pdf) > 0.0f;
            if(_S870)
            {
                if(_S753)
                {
                    _S860 = true;
                }
                else
                {
                    _S860 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S860 = false;
            }
            var _S871 : bool = (lobe_2.pdf) > 0.0f;
            var _S872 : bool;
            if(_S871)
            {
                if(_S753)
                {
                    _S872 = true;
                }
                else
                {
                    _S872 = (_S693.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S872 = false;
            }
            var _S873 : bool;
            if(_S726)
            {
                var _S874 : bool = !_S860;
                if(_S874)
                {
                    return _S653;
                }
                var _S875 : bool = _S657 != u32(1);
                if(_S875)
                {
                    _S873 = _S657 != u32(2);
                }
                else
                {
                    _S873 = false;
                }
                if(_S873)
                {
                    var _S876 : f32 = lobe_2.pdf;
                    var _S877 : f32 = select(0.0f, _S876, _S697);
                    var _S878 : f32 = escapeWeight_0(_S877, r_4.dir);
                    if(_S734)
                    {
                        is_inside_5 = _S663;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S879 : f32 = select(1.0f, _S878, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S879) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S880 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S881 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S880;
                density_5 = _S881;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S873 = b_2 <= _S667;
            }
            else
            {
                _S873 = false;
            }
            var _S882 : bool;
            if(_S873)
            {
                _S882 = _S692;
            }
            else
            {
                _S882 = false;
            }
            var _S883 : bool;
            if(_S882)
            {
                _S883 = _S860;
            }
            else
            {
                _S883 = false;
            }
            var _S884 : bool;
            if(_S883)
            {
                _S884 = true;
            }
            else
            {
                if(_S751)
                {
                    _S884 = !_S872;
                }
                else
                {
                    _S884 = false;
                }
            }
            if(_S884)
            {
                return _S653;
            }
            if(_S751)
            {
                var _S885 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S886 : f32 = lobe_2.pdf;
                throughput_7 = _S885;
                survival_probability_0 = _S886;
            }
            else
            {
                var _S887 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S652);
                throughput_7 = _S887;
                survival_probability_0 = density_5;
            }
            var _S888 : bool;
            if(_S704)
            {
                _S888 = !_S716;
            }
            else
            {
                _S888 = false;
            }
            var _S889 : bool;
            if(_S888)
            {
                _S889 = _S692;
            }
            else
            {
                _S889 = false;
            }
            var _S890 : bool;
            if(_S889)
            {
                _S890 = _S860;
            }
            else
            {
                _S890 = false;
            }
            if(_S890)
            {
                chain_0 = here_0;
                var _S891 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S892 : u32 = select(u32(0), u32(1), _S697);
                var _S893 : u32 = (insertBits((_S891), (_S892), (u32(21)), (u32(1))));
                chain_0.path = _S893;
                var _S894 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S894;
                chain_0.dir = dir_12;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S895 : Vertex = Vertex_x24init_0(_S872, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_12)), is_inside_5);
            prev_0 = _S895;
            var _S896 : f32 = lobe_2.pdf;
            var _S897 : bool = lobe_index_0 == u32(1);
            var _S898 : bool;
            if(_S897)
            {
                _S898 = (_S696.x) == (_S696.y);
            }
            else
            {
                _S898 = false;
            }
            var _S899 : f32 = select(_S896, sky_pdf_0, _S898);
            var _S900 : bool;
            if(refracted_4)
            {
                _S900 = !_S791;
            }
            else
            {
                _S900 = false;
            }
            var is_inside_6 : bool;
            if(_S900)
            {
                var _S901 : bool = !is_inside_5;
                is_inside_6 = _S901;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_12;
            var _S902 : Surface = surface_5;
            var _S903 : vec3<f32> = (vec3<f32>(0) - _S694.smooth_n);
            var _S904 : bool = is_inside_6 != _S791;
            var _S905 : vec3<f32> = select(_S694.smooth_n, _S903, _S904);
            var _S906 : vec3<f32> = ray_2.origin + vec3<f32>(_S902.geometry_offset) * _S905;
            ray_2.origin = _S906;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S899;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S704)
        {
            if(_S675)
            {
                var _S907 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S908 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S909 : bool = _S908 == u32(1);
                if(_S909)
                {
                    var _S910 : vec3<f32> = safeDivide(_S907, chain_throughput_0);
                    candidate_5.radiance = _S910;
                }
                var _S911 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S907);
                offer(&((*sel_1)), _S911, _S907 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S675)
            {
                _S751 = true;
            }
            else
            {
                _S751 = scatter_0;
            }
            if(_S751)
            {
                var _S912 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S912;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S913 : u32 = stream(r_4.seed, b_2 + u32(128));
            var _S914 : Random = pcg(_S913);
            var _S915 : bool = survival_probability_0 < (_S914.value);
            if(_S915)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S916 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S916;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S917 : f32 = density_5 * survival_probability_0;
            density_2 = _S917;
        }
        else
        {
            density_2 = density_5;
        }
        var _S918 : Ray = ray_2;
        var _S919 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S751 = _S727;
        }
        else
        {
            _S751 = false;
        }
        if(_S751)
        {
            wrong_side_0 = _S656 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S920 : f32 = select(4.294967296e+09f, _S919, wrong_side_0);
        var _S921 : Hit = (traverseInstanceBVH((_S918), (_S681), (_S920)));
        hit_2 = _S921;
        if(replay_0)
        {
            refracted_4 = _S727;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S752 = _S656 == u32(1);
        }
        else
        {
            _S752 = false;
        }
        if(_S752)
        {
            _S753 = (hit_2.instance_index) == (_S668.instance_index);
        }
        else
        {
            _S753 = false;
        }
        if(_S753)
        {
            _S789 = (hit_2.triangle_index) == (_S668.triangle_index);
        }
        else
        {
            _S789 = false;
        }
        if(_S789)
        {
            hit_2.uv = _S668.uv;
            var _S922 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S922;
        }
        if(replay_0)
        {
            _S790 = _S727;
        }
        else
        {
            _S790 = false;
        }
        if(_S790)
        {
            _S791 = _S656 == u32(3);
        }
        else
        {
            _S791 = false;
        }
        if(_S791)
        {
            _S792 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S792 = false;
        }
        if(_S792)
        {
            return _S653;
        }
        var _S923 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S923)
        {
            var _S924 : bool = !nee_vertex_0.none;
            var _S925 : f32 = select(0.0f, sky_pdf_0, _S924);
            var _S926 : f32 = escapeWeight_0(_S925, ray_2.unit_direction);
            var _S927 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S928 : vec3<f32> = throughput_2 * _S927;
            if(replay_0)
            {
                if(_S727)
                {
                    is_inside_5 = _S656 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S928 * vec3<f32>(_S926) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
                }
                if(_S666)
                {
                    is_inside_5 = _S663;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S654;
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
                    return Shift_x24init_0(_S928 * vec3<f32>(_S926), 1.0f);
                }
                return _S653;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S929 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S930 : bool = _S929 == u32(1);
            if(_S930)
            {
                var _S931 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S932 : bool = _S931 == b_2;
                var _S933 : f32 = select(_S926, 1.0f, _S932);
                var _S934 : vec3<f32> = safeDivide(_S928 * vec3<f32>(_S933), chain_throughput_0);
                candidate_6.radiance = _S934;
            }
            else
            {
                var _S935 : bool = prev_0.rough;
                if(_S935)
                {
                    var _S936 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S937 : u32 = (insertBits((_S936), (u32(3)), (u32(10)), (u32(2))));
                    var _S938 : u32 = (insertBits((_S937), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S939 : bool = prev_0.inside;
                    var _S940 : u32 = select(u32(0), u32(1), _S939);
                    var _S941 : u32 = (insertBits((_S938), (_S940), (u32(22)), (u32(1))));
                    candidate_6.path = _S941;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S942 : vec3<f32> = _S928 * vec3<f32>(_S926);
            var _S943 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S942);
            offer(&((*sel_1)), _S943, _S942 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S944 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S944;
        var _S945 : u32 = b_2 + u32(1);
        b_2 = _S945;
    }
    return _S653;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S946 : vec3<f32> = vec3<f32>(0.0f);
    var _S947 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S946, 0.0f, vec4<u32>(u32(0)), _S946, _S946), 0.0f, _S946, u32(0));
    var sel_2 : Selection = _S947;
    var _S948 : bool = (r_5.w) <= 0.0f;
    if(_S948)
    {
        return Shift_x24init_0(_S946, 0.0f);
    }
    var _S949 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S949;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S950 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S950;
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
        var _S951 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S952 : u32 = (_S951 + u32(63)) / u32(64);
        var _S953 : bool = group_0 < _S952;
        if(_S953)
        {
            var _S954 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S955 : bool = _S954 < _S951;
            if(_S955)
            {
                var _S956 : u32 = (queued_shifts[(u32(83) + start_4 + _S954)]);
                return _S956;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S952;
        var start_5 : u32 = start_4 + _S951;
        var bin_1 : u32 = bin_0 + u32(1);
        bin_0 = bin_1;
        group_0 = group_1;
        start_4 = start_5;
    }
    return u32(4294967295);
}

var<workgroup> bin_jobs_0 : array<atomic<u32>, i32(40)>;

var<workgroup> bin_offsets_0 : array<u32, i32(40)>;

fn queueShifts_0( p_8 : vec2<i32>,  bins_1 : array<u32, i32(3)>,  global_invocation_id_0 : vec3<u32>,  local_invocation_index_1 : u32)
{
    var _S957 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
    var slots_0 : array<u32, i32(3)>;
    slots_0[i32(0)] = u32(0);
    slots_0[i32(1)] = u32(0);
    slots_0[i32(2)] = u32(0);
    var t_5 : u32 = u32(0);
    loop
    {
        if(t_5 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S958 : u32 = t_5;
        var _S959 : bool = (bins_1[t_5]) < u32(40);
        if(_S959)
        {
            var _S960 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S958]]), u32(1));
            slots_0[t_5] = _S960;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S961 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S961)
    {
        var _S962 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S963 : bool = _S962 > u32(0);
        if(_S963)
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
                var _S964 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S964;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S965 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S962)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S965;
        }
    }
    workgroupBarrier();
    t_5 = u32(0);
    loop
    {
        if(t_5 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S966 : u32 = t_5;
        var _S967 : bool = (bins_1[t_5]) < u32(40);
        if(_S967)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S966]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S968 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S968)
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
            var _S969 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S969 + u32(63)) / u32(64);
            var bin_4 : u32 = bin_2 + u32(1);
            bin_2 = bin_4;
            groups_0 = groups_1;
        }
        shift_queue.dispatch = array<u32, 3>((min(groups_0, u32(65535))), ((groups_0 + u32(65534)) / u32(65535)), (u32(1)));
    }
    return;
}

fn project_0( view_2 : mat3x3<f32>,  camera_0 : vec3<f32>,  position_0 : vec3<f32>) -> vec2<f32>
{
    var _S970 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S971 : vec2<f32> = vec2<f32>(0.5f);
    var _S972 : vec2<f32> = _S970.xy / vec2<f32>(_S970.z) * _S971 + _S971;
    var _S973 : vec2<f32> = vec2<f32>(_S972.x, 1.0f - _S972.y);
    var _S974 : vec2<u32> = (uniforms_uint.render_size);
    return _S973 * vec2<f32>(_S974);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S975 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S976 : bool;
    if(_S975)
    {
        var _S977 : vec2<u32> = (uniforms_uint.render_size);
        _S976 = (all((q_0 < vec2<i32>(_S977))));
    }
    else
    {
        _S976 = false;
    }
    if(_S976)
    {
        var _S978 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S976 = (bitcast<f32>((_S978.w))) > 0.0f;
    }
    else
    {
        _S976 = false;
    }
    return _S976;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S979 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S980 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S981 : vec2<f32> = project_0(_S979, _S980, dom_3.x1);
    var _S982 : vec2<i32> = vec2<i32>(floor(_S981));
    var _S983 : bool = previousValid_0(_S982);
    var _S984 : bool = !_S983;
    if(_S984)
    {
        return vec2<i32>(i32(-1));
    }
    var _S985 : Domain = (previousDomain((_S982)));
    var _S986 : bool = (_S985.hit.instance_index) == (dom_3.hit.instance_index);
    var _S987 : bool;
    if(_S986)
    {
        var _S988 : f32 = distance(_S985.x1, dom_3.x1);
        var _S989 : f32 = dom_3.hit.distance * 8.0f;
        var _S990 : vec2<u32> = (uniforms_uint.render_size);
        _S987 = _S988 <= (_S989 / f32(_S990.x));
    }
    else
    {
        _S987 = false;
    }
    if(_S987)
    {
        return _S982;
    }
    var _S991 : vec2<f32> = vec2<f32>(p_9 + _S982) + vec2<f32>(1.0f);
    var _S992 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S993 : vec3<f32> = (uniforms_float.camera_position);
    var _S994 : vec2<f32> = project_0(_S992, _S993, _S985.x1);
    var _S995 : vec2<i32> = vec2<i32>(floor(_S991 - _S994));
    var _S996 : vec2<i32> = vec2<i32>(i32(-1));
    var _S997 : bool = previousValid_0(_S995);
    var _S998 : vec2<i32> = select(_S996, _S995, _S997);
    return _S998;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S999 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S1000 : bool;
    if(_S999)
    {
        _S1000 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S1000 = false;
    }
    if(_S1000)
    {
        _S1000 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S1000 = false;
    }
    if(_S1000)
    {
        _S1000 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S1000 = false;
    }
    return _S1000;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1001 : vec3<f32> = vec3<f32>(0.0f);
    var _S1002 : Domain = Domain_x24init_0(_S1001, _S1001, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1002;
    var _S1003 : bool = t_8 > u32(1);
    var _S1004 : bool;
    if(_S1003)
    {
        _S1004 = true;
    }
    else
    {
        var _S1005 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1004 = !_S1005;
    }
    if(_S1004)
    {
        return false;
    }
    var _S1006 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1007 : bool = (_S1006.x) < i32(0);
    if(_S1007)
    {
        return false;
    }
    var _S1008 : bool = t_8 == u32(0);
    if(_S1008)
    {
        var _S1009 : Reservoir = (loadReservoir(reservoir_prev, (_S1006)));
        var _S1010 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1009);
        (*job_2) = _S1010;
    }
    else
    {
        var _S1011 : Domain = (previousDomain((_S1006)));
        var _S1012 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1013 : ShiftJob = ShiftJob_x24init_0(_S1011, _S1012);
        (*job_2) = _S1013;
    }
    var _S1014 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1014)
    {
        if(_S1008)
        {
            _S1004 = true;
        }
        else
        {
            var _S1015 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1004 = !_S1015;
        }
    }
    else
    {
        _S1004 = false;
    }
    return _S1004;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1016 : ptr<function, array<u32, i32(3)>>)
{
    var _S1017 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_2 : array<u32, i32(3)>;
    bins_2[i32(0)] = u32(40);
    bins_2[i32(1)] = u32(40);
    bins_2[i32(2)] = u32(40);
    var t_9 : u32 = u32(0);
    loop
    {
        if(t_9 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1018 : vec3<f32> = vec3<f32>(0.0f);
        var _S1019 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1018, _S1018, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1018, 0.0f, vec4<u32>(u32(0)), _S1018, _S1018));
        var job_3 : ShiftJob = _S1019;
        var _S1020 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1020)
        {
            var _S1021 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1021;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1016) = bins_2;
    return;
}

fn countShifts_0( bins_3 : array<u32, i32(3)>,  local_invocation_index_2 : u32)
{
    var t_11 : u32 = u32(0);
    loop
    {
        if(t_11 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1022 : u32 = t_11;
        var _S1023 : bool = (bins_3[t_11]) < u32(40);
        if(_S1023)
        {
            var _S1024 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1022]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1025 : bool = local_invocation_index_2 < u32(40);
    if(_S1025)
    {
        var _S1026 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1027 : bool = _S1026 > u32(0);
        if(_S1027)
        {
            var _S1028 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1026)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1029 : vec2<u32> = global_invocation_id_1.xy;
    var _S1030 : vec2<i32> = vec2<i32>(_S1029 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1031 : vec2<i32> = _S1030 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1032 : bool = (all((_S1031 >= vec2<i32>(i32(0)))));
        var _S1033 : bool;
        if(_S1032)
        {
            var _S1034 : vec2<u32> = (uniforms_uint.render_size);
            _S1033 = (all((_S1031 < vec2<i32>(_S1034))));
        }
        else
        {
            _S1033 = false;
        }
        if(_S1033)
        {
            var _S1035 : vec4<u32> = (textureLoad(reservoir_prev, (_S1031), (u32(0)), 0));
            var _S1036 : u32 = _S1035.x;
            var _S1037 : bool = (bitcast<f32>((_S1035.z))) > 0.0f;
            var _S1038 : u32 = select(u32(0), _S1036, _S1037);
            seed_2 = _S1038;
        }
        else
        {
            seed_2 = u32(0);
        }
        duplication_seeds_0[i_8] = seed_2;
        var i_9 : u32 = i_8 + u32(64);
        i_8 = i_9;
    }
    workgroupBarrier();
    var _S1039 : u32 = local_invocation_id_0.y;
    var _S1040 : u32 = local_invocation_id_0.x;
    var _S1041 : u32 = duplication_seeds_0[(_S1039 + u32(8)) * u32(24) + _S1040 + u32(8)];
    seed_2 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(seed_2 < u32(17))
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
            var _S1042 : bool = (duplication_seeds_0[(_S1039 + seed_2) * u32(24) + _S1040 + x_1]) == _S1041;
            var _S1043 : u32 = select(u32(0), u32(1), _S1042);
            var count_2 : u32 = count_1 + _S1043;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1044 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1045 : bool = _S1041 != u32(0);
    var _S1046 : f32 = select(0.0f, _S1044, _S1045);
    textureStore(duplication_out, (vec2<i32>(_S1029)), 0, (vec4<u32>((bitcast<u32>((_S1046))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1047 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1047;
    var _S1048 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1048;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1049 : f32 = rgb_to_greyscale(r_7.f);
    var _S1050 : f32 = sel_4.w_sum / _S1049;
    var _S1051 : bool = _S1049 > 0.0f;
    var _S1052 : f32 = select(0.0f, _S1050, _S1051);
    r_7.w = _S1052;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1053 : vec2<u32> = global_invocation_id_2.xy;
    var _S1054 : vec2<i32> = vec2<i32>(_S1053);
    var _S1055 : vec3<f32> = vec3<f32>(0.0f);
    var _S1056 : Domain = Domain_x24init_0(_S1055, _S1055, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1056;
    var _S1057 : bool = (currentDomain((_S1054), &(dom_5)));
    var _S1058 : bool = !_S1057;
    if(_S1058)
    {
        storeReservoir(reservoir_prev_out, (_S1054), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1055, 0.0f, vec4<u32>(u32(0)), _S1055, _S1055)), (dom_5.hit));
        var _S1059 : vec2<f32> = vec2<f32>(_S1053);
        var _S1060 : vec2<u32> = (uniforms_uint.render_size);
        var _S1061 : vec2<f32> = _S1059 / vec2<f32>(_S1060.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1062 : vec3<f32> = vec3<f32>(_S1061, 1.0f);
        var _S1063 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1064 : vec3<f32> = (normalize(((((_S1063) * (_S1062))))));
        var _S1065 : vec3<f32> = environment_0(_S1064);
        textureStore(compute_out, (_S1054), (u32(0)), (vec4<f32>(_S1065, 1.0f)));
        var _S1066 : u32 = (uniforms_uint.is_temporal);
        var _S1067 : bool = _S1066 == u32(1);
        if(_S1067)
        {
            textureStore(compute_out, (_S1054), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1068 : Reservoir = (loadReservoir(reservoir_temp, (_S1054)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1068.c;
    loop
    {
        var _S1069 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1069)
        {
        }
        else
        {
            break;
        }
        var _S1070 : vec2<i32> = partner_0(_S1054, t_13);
        var neighbor_0 : Domain = _S1056;
        var _S1071 : bool = (currentDomain((_S1070), &(neighbor_0)));
        if(_S1071)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1072 : vec4<u32> = (textureLoad(reservoir_temp, (_S1070), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1072.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1073 : f32 = _S1068.c / max(count_3, 1.0f);
    var _S1074 : f32 = rgb_to_greyscale(_S1068.f);
    var _S1075 : bool = count_3 == 0.0f;
    var _S1076 : f32 = select(0.0f, 1.0f, _S1075);
    var _S1077 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1055, 0.0f, vec4<u32>(u32(0)), _S1055, _S1055), 0.0f, _S1055, u32(0));
    var sel_5 : Selection = _S1077;
    var _S1078 : u32 = (uniforms_uint.frame);
    var _S1079 : u32 = hash(_S1078);
    var _S1080 : u32 = global_invocation_id_2.x;
    var _S1081 : vec2<u32> = (uniforms_uint.render_size);
    var _S1082 : u32 = stream(_S1079, _S1080 + _S1081.x * global_invocation_id_2.y);
    var _S1083 : u32 = stream(_S1082, u32(195));
    sel_5.random_state = _S1083;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1076;
    loop
    {
        var _S1084 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1084)
        {
        }
        else
        {
            break;
        }
        var _S1085 : vec2<i32> = partner_0(_S1054, t_13);
        var neighbor_dom_0 : Domain = _S1056;
        var _S1086 : bool = (currentDomain((_S1085), &(neighbor_dom_0)));
        if(_S1086)
        {
            var _S1087 : Reservoir = (loadReservoir(reservoir_temp, (_S1085)));
            var _S1088 : vec4<u32> = (textureLoad(shift_data, (_S1085), (t_13), 0));
            var _S1089 : vec4<f32> = (bitcast<vec4<f32>>((_S1088)));
            var _S1090 : vec4<u32> = (textureLoad(shift_data, (_S1054), (t_13), 0));
            var _S1091 : vec4<f32> = (bitcast<vec4<f32>>((_S1090)));
            var _S1092 : f32 = (_S1087.c + _S1073) / c_sum_0;
            var _S1093 : bool = _S1074 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1093)
            {
                var _S1094 : f32 = _S1092 * _S1073 * _S1074;
                var _S1095 : f32 = _S1073 * _S1074;
                var _S1096 : f32 = rgb_to_greyscale(_S1091.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1094 / (_S1095 + _S1087.c * _S1096);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1097 : f32 = rgb_to_greyscale(_S1087.f);
            var _S1098 : vec3<f32> = _S1089.xyz;
            var _S1099 : Shift = Shift_x24init_0(_S1098, _S1089.w);
            var _S1100 : f32 = _S1092 * _S1087.c * _S1097;
            var _S1101 : f32 = _S1087.c * _S1097;
            var _S1102 : f32 = rgb_to_greyscale(_S1098);
            offerShifted(&(sel_5), _S1087, _S1099, _S1100 / (_S1101 + _S1073 * _S1102));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1068, Shift_x24init_0(_S1068.f, 1.0f), canonical_mis_0);
    var _S1103 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1054), (_S1103), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1054), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1104 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1105 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1106 : f32 = (sign((dot(_S1105, _S1104.smooth_n))));
    var _S1107 : vec3<f32> = _S1104.material.emissive * vec3<f32>(max(_S1106, 0.0f));
    var _S1108 : vec3<f32> = select(_S1107, _S1055, _S1104.skip);
    var _S1109 : vec3<f32> = clamp(sel_5.color + _S1108, _S1055, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1054), (u32(0)), (vec4<f32>(_S1109, 1.0f)));
    var _S1110 : u32 = (uniforms_uint.is_temporal);
    var _S1111 : bool = _S1110 == u32(1);
    if(_S1111)
    {
        textureStore(compute_out, (_S1054), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1112 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1113 : bool = _S1112 != u32(4294967295);
    if(_S1113)
    {
        var _S1114 : vec2<i32> = vec2<i32>((vec2<u32>(_S1112, (_S1112 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1115 : vec3<f32> = vec3<f32>(0.0f);
        var _S1116 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1115, _S1115, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1115, 0.0f, vec4<u32>(u32(0)), _S1115, _S1115));
        var shift_job_0 : ShiftJob = _S1116;
        var _S1117 : u32 = (_S1112 >> (u32(28)));
        var _S1118 : bool = spatialJob_0(_S1114, _S1117, &(shift_job_0));
        var _S1119 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1114), (_S1117), (vec4<u32>((bitcast<vec3<u32>>((_S1119.f))), (bitcast<u32>((_S1119.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1120 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1121 : array<u32, i32(3)>;
    spatialBins_0(_S1120, &(_S1121));
    var _S1122 : array<u32, i32(3)> = _S1121;
    var t_16 : u32 = u32(0);
    loop
    {
        if(t_16 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1123 : bool = (_S1122[t_16]) == u32(40);
        if(_S1123)
        {
            textureStore(shift_data_out, (_S1120), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1120, _S1122, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1124 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1124));
    countShifts_0(_S1124, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1125 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1126 : bool = _S1125 != u32(4294967295);
    if(_S1126)
    {
        var _S1127 : vec2<i32> = vec2<i32>((vec2<u32>(_S1125, (_S1125 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1128 : vec3<f32> = vec3<f32>(0.0f);
        var _S1129 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1128, _S1128, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1128, 0.0f, vec4<u32>(u32(0)), _S1128, _S1128));
        var shift_job_1 : ShiftJob = _S1129;
        var _S1130 : u32 = (_S1125 >> (u32(28)));
        var _S1131 : bool = temporalJob_0(_S1127, _S1130, &(shift_job_1));
        var _S1132 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1127), (_S1130), (vec4<u32>((bitcast<vec3<u32>>((_S1132.f))), (bitcast<u32>((_S1132.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1133 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1134 : array<u32, i32(3)>;
    temporalBins_0(_S1133, &(_S1134));
    var _S1135 : array<u32, i32(3)> = _S1134;
    var t_18 : u32 = u32(0);
    loop
    {
        if(t_18 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1136 : bool = (_S1135[t_18]) == u32(40);
        if(_S1136)
        {
            textureStore(temporal_shifts_out, (_S1133), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1133, _S1135, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1137 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1137));
    countShifts_0(_S1137, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1138 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1139 : vec3<f32> = vec3<f32>(0.0f);
    var _S1140 : Domain = Domain_x24init_0(_S1139, _S1139, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1140;
    var _S1141 : bool = (currentDomain((_S1138), &(dom_6)));
    var _S1142 : bool = !_S1141;
    if(_S1142)
    {
        storeReservoir(reservoir_temp_out, (_S1138), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1139, 0.0f, vec4<u32>(u32(0)), _S1139, _S1139)), (dom_6.hit));
        return;
    }
    var _S1143 : Reservoir = (loadReservoir(reservoir_initial, (_S1138)));
    var _S1144 : vec2<i32> = temporalNeighbor_0(_S1138, dom_6);
    var _S1145 : bool = (_S1144.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1145)
    {
        var _S1146 : Reservoir = (loadReservoir(reservoir_prev, (_S1144)));
        var _S1147 : vec4<u32> = (textureLoad(duplication, (_S1144), 0, 0));
        var _S1148 : f32 = (bitcast<f32>((_S1147.x)));
        var _S1149 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1150 : bool = _S1149 == u32(1);
        var _S1151 : f32 = select(0.0f, _S1148, _S1150);
        var _S1152 : f32 = (mix((20.0f), (1.0f), (pow(_S1151, 0.10000000149011612f))));
        var _S1153 : f32 = min(_S1146.c, _S1152);
        var _S1154 : vec4<u32> = (textureLoad(temporal_shifts, (_S1138), (u32(0)), 0));
        var _S1155 : vec4<f32> = (bitcast<vec4<f32>>((_S1154)));
        var _S1156 : vec4<f32> = vec4<f32>(_S1143.f, 1.0f);
        var _S1157 : Domain = (previousDomain((_S1144)));
        var _S1158 : bool = sameDomain_0(_S1157, dom_6);
        var _S1159 : bool = !_S1158;
        var to_previous_0 : vec4<f32>;
        if(_S1159)
        {
            var _S1160 : vec4<u32> = (textureLoad(temporal_shifts, (_S1138), (u32(1)), 0));
            var _S1161 : vec4<f32> = (bitcast<vec4<f32>>((_S1160)));
            to_previous_0 = _S1161;
        }
        else
        {
            to_previous_0 = _S1156;
        }
        var _S1162 : f32 = rgb_to_greyscale(_S1143.f);
        var _S1163 : f32 = rgb_to_greyscale(_S1146.f);
        var _S1164 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1139, 0.0f, vec4<u32>(u32(0)), _S1139, _S1139), 0.0f, _S1139, u32(0));
        var sel_6 : Selection = _S1164;
        var _S1165 : u32 = (uniforms_uint.frame);
        var _S1166 : u32 = hash(_S1165);
        var _S1167 : u32 = global_invocation_id_7.x;
        var _S1168 : vec2<u32> = (uniforms_uint.render_size);
        var _S1169 : u32 = stream(_S1166, _S1167 + _S1168.x * global_invocation_id_7.y);
        var _S1170 : u32 = stream(_S1169, u32(194));
        sel_6.random_state = _S1170;
        var _S1171 : f32 = _S1143.c * _S1162;
        var _S1172 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1173 : f32 = _S1171 / (_S1171 + _S1153 * _S1172);
        var _S1174 : f32 = _S1153 * _S1163;
        var _S1175 : vec3<f32> = _S1155.xyz;
        var _S1176 : f32 = rgb_to_greyscale(_S1175);
        var _S1177 : f32 = _S1174 / (_S1174 + _S1143.c * _S1176);
        var _S1178 : vec2<f32> = vec2<f32>(_S1173, _S1177);
        offerShifted(&(sel_6), _S1143, Shift_x24init_0(_S1143.f, 1.0f), _S1173);
        offerShifted(&(sel_6), _S1146, Shift_x24init_0(_S1175, _S1155.w), _S1177);
        var _S1179 : Reservoir = finalize(sel_6, _S1143.c + _S1153);
        r_8 = _S1179;
    }
    else
    {
        r_8 = _S1143;
    }
    storeReservoir(reservoir_temp_out, (_S1138), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1180 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1181 : vec3<f32> = vec3<f32>(0.0f);
    var _S1182 : Domain = Domain_x24init_0(_S1181, _S1181, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1182;
    var _S1183 : bool = (currentDomain((_S1180), &(dom_7)));
    var _S1184 : bool = !_S1183;
    if(_S1184)
    {
        storeReservoir(reservoir_initial_out, (_S1180), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1181, 0.0f, vec4<u32>(u32(0)), _S1181, _S1181)), (dom_7.hit));
        return;
    }
    var _S1185 : u32 = (uniforms_uint.frame);
    var _S1186 : u32 = hash(_S1185);
    var _S1187 : u32 = global_invocation_id_8.x;
    var _S1188 : vec2<u32> = (uniforms_uint.render_size);
    var _S1189 : u32 = stream(_S1186, _S1187 + _S1188.x * global_invocation_id_8.y);
    var _S1190 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1181, 0.0f, vec4<u32>(u32(0)), _S1181, _S1181);
    var _S1191 : Selection = Selection_x24init_0(_S1190, 0.0f, _S1181, u32(0));
    var initial_0 : Selection = _S1191;
    var _S1192 : u32 = stream(_S1189, u32(193));
    initial_0.random_state = _S1192;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1193 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1193)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1190;
        var _S1194 : u32 = stream(_S1189, i_10);
        r_9.seed = _S1194;
        var _S1195 : u32 = (uniforms_uint.samples);
        var _S1196 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1195), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1197 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1180), (_S1197), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1198 : Random = pcg(state_3);
    var _S1199 : Random = pcg(_S1198.state);
    var _S1200 : f32 = 6.28318548202514648f * _S1198.value;
    var _S1201 : f32 = sqrt(-2.0f * clamp(log(_S1199.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1199.state, _S1201 * cos(_S1200));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1202 : RandomSphere;
    _S1202.state = state_4;
    _S1202.value = value_1;
    return _S1202;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1203 : Random = normal_distribution(state_5);
    var _S1204 : Random = normal_distribution(_S1203.state);
    var _S1205 : Random = normal_distribution(_S1204.state);
    var _S1206 : vec3<f32> = (normalize((vec3<f32>(_S1203.value, _S1204.value, _S1205.value))));
    return RandomSphere_x24init_0(_S1205.state, _S1206);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_10 : vec3<f32>) -> mat3x3<f32>
{
    var _S1207 : vec3<f32> = p1_0 - p0_0;
    var _S1208 : vec3<f32> = p2_0 - p0_0;
    var _S1209 : vec2<f32> = uv1_0 - uv0_0;
    var _S1210 : vec2<f32> = uv2_0 - uv0_0;
    var _S1211 : f32 = _S1209.x;
    var _S1212 : f32 = _S1210.y;
    var _S1213 : f32 = _S1209.y;
    var _S1214 : f32 = _S1210.x;
    var _S1215 : f32 = _S1211 * _S1212 - _S1213 * _S1214;
    var _S1216 : f32 = 1.0f / _S1215;
    var _S1217 : vec3<f32> = vec3<f32>(_S1216);
    var t_20 : vec3<f32> = (_S1207 * vec3<f32>(_S1212) - _S1208 * vec3<f32>(_S1213)) * _S1217;
    var _S1218 : vec3<f32> = (_S1208 * vec3<f32>(_S1211) - _S1207 * vec3<f32>(_S1214)) * _S1217;
    var _S1219 : vec3<f32> = t_20 - n_10 * vec3<f32>(dot(n_10, t_20));
    var _S1220 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_10);
    var _S1221 : bool = (dot(_S1219, _S1219)) > 0.0f;
    var _S1222 : vec3<f32> = select(_S1220, _S1219, _S1221);
    var _S1223 : vec3<f32> = (normalize((_S1222)));
    var _S1224 : bool = (dot(cross(n_10, _S1223), _S1218)) > 0.0f;
    var t_21 : vec3<f32>;
    if(_S1224)
    {
        var _S1225 : vec3<f32> = ((-(_S1223)));
        t_21 = _S1225;
    }
    else
    {
        t_21 = _S1223;
    }
    var _S1226 : vec3<f32> = cross(n_10, t_21);
    return mat3x3<f32>(t_21, _S1226, n_10);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1227 : vec3<f32> = t1_0 - t0_0;
    var _S1228 : vec3<f32> = t2_2 - t0_0;
    var _S1229 : vec3<f32> = t2_2 - t1_0;
    var _S1230 : f32 = min(length(_S1227), min(length(_S1228), length(_S1229)));
    var _S1231 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1232 : vec3<f32> = (normalize((n0_0)));
    var _S1233 : f32 = dot(geometry_n_4, _S1232);
    var _S1234 : vec3<f32> = (normalize((n1_0)));
    var _S1235 : f32 = dot(geometry_n_4, _S1234);
    var _S1236 : vec3<f32> = (normalize((n2_0)));
    var _S1237 : vec3<f32> = acos(abs(vec3<f32>(_S1233, _S1235, dot(geometry_n_4, _S1236))));
    var _S1238 : vec3<f32> = clamp(tan(_S1237), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1231 * _S1238, uvw_0), 0.0f, _S1230 * 0.125f);
}

fn straightThrough( material_20 : Material) -> vec3<f32>
{
    return vec3<f32>((material_20.transmission * (1.0f - material_20.metallic))) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1239 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1240 : vec3<f32> = straightThrough(material_21);
        _S1239 = _S1240;
    }
    else
    {
        _S1239 = vec3<f32>(0.0f);
    }
    return _S1239 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1241 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1241;
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

