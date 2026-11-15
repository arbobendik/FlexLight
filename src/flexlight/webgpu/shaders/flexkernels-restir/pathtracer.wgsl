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
    var _S60 : f32;
    if(_S59)
    {
        _S60 = 1.0f;
    }
    else
    {
        _S60 = -1.0f;
    }
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
        var _S71 : f32 = eta_o_0 * cos_theta_0;
        var _S72 : f32 = eta_i_0 * _S70;
        var _S73 : f32 = (_S71 - _S72) / (_S71 + _S72);
        var _S74 : f32 = eta_i_0 * cos_theta_0;
        var _S75 : f32 = eta_o_0 * _S70;
        var _S76 : f32 = (_S74 - _S75) / (_S74 + _S75);
        var _S77 : f32 = (_S73 * _S73 + _S76 * _S76) / 2.0f;
        kr_0 = _S77;
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
    var _S78 : f32 = fresnel(abs(n_dot_v_1), eta_i_1, eta_o_1);
    var _S79 : vec3<f32> = (mix((vec3<f32>(_S78)), (material_2.albedo), (material_2.metallic)));
    var _S80 : f32 = rgb_to_greyscale(_S79);
    var _S81 : f32 = max((1.0f - _S80) * (1.0f - material_2.metallic) * (1.0f - material_2.transmission), 0.0f);
    var _S82 : bool = _S81 > 0.03999999910593033f;
    var _S83 : bool;
    if(_S82)
    {
        _S83 = true;
    }
    else
    {
        _S83 = (material_2.roughness) > 0.20000000298023224f;
    }
    return _S83;
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
    var _S84 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S85 : bool = cos_a_0 > cos_b_0;
    var _S86 : f32 = select(_S84, 1.0f, _S85);
    return _S86;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S87 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S88 : vec3<f32> = node_0.high - node_0.low;
    var _S89 : vec3<f32> = p_3 - _S87;
    var _S90 : vec3<f32> = (normalize((_S89)));
    var _S91 : f32 = dot(_S89, _S89);
    var _S92 : f32 = dot(_S88, _S88) / 4.0f;
    var _S93 : f32 = abs(dot(node_0.w, _S90));
    var _S94 : f32 = sine(node_0.cos_theta_o);
    var _S95 : f32 = sqrt(max(1.0f - _S92 / _S91, 0.0f));
    var _S96 : bool = _S91 < _S92;
    var _S97 : f32 = select(_S95, -1.0f, _S96);
    var _S98 : f32 = sine(_S97);
    var _S99 : f32 = sine(_S93);
    var _S100 : f32 = cosSubClamped(_S99, _S93, _S94, node_0.cos_theta_o);
    var _S101 : f32 = sine(_S93);
    var _S102 : f32 = _S101 * node_0.cos_theta_o - _S93 * _S94;
    var _S103 : bool = _S93 > (node_0.cos_theta_o);
    var _S104 : f32 = select(_S102, 0.0f, _S103);
    var _S105 : f32 = cosSubClamped(_S104, _S100, _S98, _S97);
    var _S106 : bool = _S105 <= 0.0f;
    if(_S106)
    {
        return 0.0f;
    }
    var _S107 : f32 = - dot(_S90, normal_0);
    var _S108 : f32 = node_0.phi * _S105 / max(_S91, length(_S88) / 2.0f);
    var _S109 : f32 = sine(_S107);
    var _S110 : f32 = cosSubClamped(_S109, _S107, _S98, _S97);
    var _S111 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S112 : f32 = select(_S110, 1.0f, _S111);
    return max(_S108 * _S112, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S113 : f32 = importance(first_0, p_4, normal_1);
    var _S114 : f32 = importance(second_0, p_4, normal_1);
    var _S115 : vec2<f32> = vec2<f32>(_S113, _S114);
    var _S116 : f32 = _S115[child_0] / (_S113 + _S114);
    var _S117 : bool = (_S115[child_0]) > 0.0f;
    var _S118 : f32 = select(0.0f, _S116, _S117);
    return _S118;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S119 : vec3<f32> = center_0 - p_5;
    var _S120 : f32 = radius_0 * radius_0 / dot(_S119, _S119);
    var _S121 : bool = _S120 >= 1.0f;
    if(_S121)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S120)) / (6.28318548202514648f * _S120);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S122 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S123 : vec2<u32> = _S122.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S123;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S124 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S124.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S125 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S126 : u32 = n_0 + u32(1);
        var _S127 : LightBounds = (lightBounds((_S126)));
        var _S128 : LightBounds = (lightBounds((_S125)));
        var _S129 : u32 = trail_0.x;
        var _S130 : u32 = (_S129 & (u32(1)));
        var _S131 : f32 = childShare(_S127, _S128, origin_2, smooth_n_2, _S130);
        var probability_2 : f32 = probability_1 * _S131;
        var _S132 : bool = _S130 == u32(1);
        var _S133 : u32 = select(_S126, _S125, _S132);
        var _S134 : u32 = trail_0.y;
        var _S135 : vec2<u32> = vec2<u32>((((_S129 >> (u32(1)))) | (((_S134 << (u32(31)))))), (_S134 >> (u32(1))));
        n_0 = _S133;
        trail_0 = _S135;
        probability_1 = probability_2;
    }
    var _S136 : bool = (((_S122).z == (n_0)));
    var _S137 : bool = !_S136;
    var _S138 : bool;
    if(_S137)
    {
        _S138 = true;
    }
    else
    {
        var _S139 : LightBounds = (lightBounds((n_0)));
        var _S140 : f32 = importance(_S139, origin_2, smooth_n_2);
        _S138 = !(_S140 > 0.0f);
    }
    if(_S138)
    {
        _S138 = true;
    }
    else
    {
        var _S141 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S141)
        {
            _S138 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S138 = false;
        }
    }
    if(_S138)
    {
        return 0.0f;
    }
    var _S142 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S143 : bool = (_S142.x) == u32(2);
    if(_S143)
    {
        var _S144 : u32 = _S142.y;
        var _S145 : Light = (lights[(_S144)]);
        var _S146 : Light = (lights[(_S144)]);
        var _S147 : f32 = sphereDensity(_S145.position, _S146.variance, start_1);
        return probability_1 * _S147;
    }
    var _S148 : u32 = _S142.y;
    var _S149 : u32 = ((instance_uint[(_S148) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S150 : mat3x3<f32> = (worldTriangle((_S148), (_S149 + _S142.z)));
    var _S151 : f32 = solidAngle(probability_1, cross(_S150[i32(1)] - _S150[i32(0)], _S150[i32(2)] - _S150[i32(0)]), light_point_0 - start_1);
    return _S151;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S152 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S153 : bool = b_0 > 0.0f;
    var _S154 : f32 = select(1.0f, _S152, _S153);
    return _S154;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S155 : u32 = (lightSlot((hit_1)));
    var _S156 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S155, light_point_1);
    var _S157 : f32 = powerHeuristic(vertex_0.pdf, _S156);
    return _S157;
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_2 : vec3<f32>,  radiance_1 : vec3<f32>,  density_0 : f32,  random_state_2 : u32) -> TreeSample
{
    var _S158 : TreeSample;
    _S158.dir = dir_2;
    _S158.radiance = radiance_1;
    _S158.density = density_0;
    _S158.random_state = random_state_2;
    return _S158;
}

fn isTranslucent_0( material_3 : Material) -> bool
{
    var _S159 : f32 = rgb_to_greyscale(material_3.translucent);
    return _S159 > 0.0f;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S160 : Random;
    _S160.state = state_0;
    _S160.value = value_0;
    return _S160;
}

fn pcg( state_1 : u32) -> Random
{
    var _S161 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S162 : u32 = hash(state_1);
    return Random_x24init_0(_S161, f32(_S162) / 4.294967296e+09f);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S163 : f32 = importance(first_1, p_6, normal_3);
    var _S164 : f32 = importance(second_1, p_6, normal_3);
    var _S165 : vec2<f32> = vec2<f32>(_S163, _S164);
    var _S166 : bool = _S163 == 0.0f;
    var _S167 : bool;
    if(_S166)
    {
        _S167 = _S164 == 0.0f;
    }
    else
    {
        _S167 = false;
    }
    if(_S167)
    {
        return u32(2);
    }
    var _S168 : f32 = _S163 + _S164;
    var _S169 : bool = _S164 > 0.0f;
    if(_S169)
    {
        _S167 = ((*pick_0) * _S168) >= _S163;
    }
    else
    {
        _S167 = false;
    }
    var _S170 : u32 = select(u32(0), u32(1), _S167);
    var _S171 : f32 = min(((*pick_0) * _S168 - f32(_S170) * _S163) / _S165[_S170], 0.99999994039535522f);
    (*pick_0) = _S171;
    var _S172 : f32 = (*probability_3) * (_S165[_S170] / _S168);
    (*probability_3) = _S172;
    return _S170;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S173 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S173)
    {
        const _S174 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S174;
    }
    else
    {
        a_2 = a_1;
    }
    var _S175 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S176 : vec3<f32> = cross(n_1, _S175);
    return vec3<f32>(v_0.x) * _S175 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S176;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S177 : vec3<f32> = center_1 - p_7;
    var _S178 : f32 = radius_1 * radius_1 / dot(_S177, _S177);
    var _S179 : f32 = u1_0 * _S178 / (1.0f + sqrt(max(1.0f - _S178, 0.0f)));
    var _S180 : f32 = 2.0f * u1_0;
    var _S181 : bool = _S178 >= 1.0f;
    var _S182 : f32 = select(_S179, _S180, _S181);
    var _S183 : f32 = sqrt(max(_S182 * (2.0f - _S182), 0.0f));
    var _S184 : f32 = 6.28318548202514648f * u2_0;
    var _S185 : vec3<f32> = vec3<f32>(_S183 * cos(_S184), 1.0f - _S182, _S183 * sin(_S184));
    var _S186 : vec3<f32> = (normalize((_S177)));
    var _S187 : vec3<f32> = tangentToWorld(_S185, _S186);
    return _S187;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S188 : vec3<f32> = center_2 - ray_0.origin;
    var _S189 : f32 = dot(_S188, ray_0.unit_direction);
    var _S190 : f32 = dot(_S188, _S188) - _S189 * _S189;
    var _S191 : f32 = radius_3 * radius_3;
    var _S192 : bool = _S190 > _S191;
    if(_S192)
    {
        return 4.294967296e+09f;
    }
    var _S193 : f32 = sqrt(_S191 - _S190);
    var _S194 : f32 = _S189 - _S193;
    var _S195 : f32 = _S189 + _S193;
    var _S196 : bool = _S194 > 0.0000152587890625f;
    var _S197 : bool;
    if(_S196)
    {
        _S197 = _S194 < max_len_0;
    }
    else
    {
        _S197 = false;
    }
    if(_S197)
    {
        return _S194;
    }
    var _S198 : bool = _S195 > 0.0000152587890625f;
    if(_S198)
    {
        _S197 = _S195 < max_len_0;
    }
    else
    {
        _S197 = false;
    }
    if(_S197)
    {
        return _S195;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S199 : vec3<f32> = (normalize((light_dir_0)));
    var _S200 : bool = (dot(smooth_n_3, _S199)) < 0.0f;
    if(_S200)
    {
        return vec3<f32>(0.0f);
    }
    var _S201 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S202 : Ray = Ray_x24init_0(_S201, _S199);
    var _S203 : f32 = shadowLength(light_dir_0);
    var _S204 : vec3<f32> = (shadowTransmittance((_S202), (_S203)));
    return _S204;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S205 : Random = pcg(init_random_state_0);
    var _S206 : Random = pcg(_S205.state);
    var _S207 : Random = pcg(_S206.state);
    var _S208 : vec3<f32> = vec3<f32>(0.0f);
    var _S209 : TreeSample = TreeSample_x24init_0(_S208, _S208, 0.0f, _S207.state);
    var sample_0 : TreeSample = _S209;
    var _S210 : vec3<f32> = select(smooth_n_4, _S208, sided_0);
    var _S211 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S212 : vec3<f32> = origin_4 + _S211 * smooth_n_4;
    var pick_1 : f32 = _S205.value;
    var probability_4 : f32 = 1.0f;
    var n_2 : u32 = u32(0);
    loop
    {
        var _S213 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
        if((_S213.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S214 : u32 = (access_light_tree(3u + 4u * (n_2)).w);
        var _S215 : u32 = n_2 + u32(1);
        var _S216 : LightBounds = (lightBounds((_S215)));
        var _S217 : LightBounds = (lightBounds((_S214)));
        var _S218 : u32 = pickChild(_S216, _S217, origin_4, _S210, &(pick_1), &(probability_4));
        var _S219 : bool = _S218 > u32(1);
        if(_S219)
        {
            return sample_0;
        }
        var _S220 : bool = _S218 == u32(1);
        var _S221 : u32 = select(_S215, _S214, _S220);
        n_2 = _S221;
    }
    var _S222 : bool = n_2 == u32(0);
    var _S223 : bool;
    if(_S222)
    {
        var _S224 : LightBounds = (lightBounds((u32(0))));
        var _S225 : f32 = importance(_S224, origin_4, _S210);
        _S223 = !(_S225 > 0.0f);
    }
    else
    {
        _S223 = false;
    }
    if(_S223)
    {
        return sample_0;
    }
    var _S226 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
    var _S227 : bool = (_S226.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S227)
    {
        var _S228 : Light = (lights[(_S226.y)]);
        if(sided_0)
        {
            var _S229 : f32 = (sign((dot(geometry_n_1, _S228.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S229);
            var _S230 : vec3<f32> = origin_4 + _S211 * lift_n_1;
            start_2 = _S230;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S212;
            lift_n_0 = smooth_n_4;
        }
        var _S231 : bool = (_S228.variance) == 0.0f;
        if(_S231)
        {
            var _S232 : vec3<f32> = _S228.position - start_2;
            var _S233 : vec3<f32> = (normalize((_S232)));
            sample_0.dir = _S233;
            var _S234 : vec3<f32> = _S228.color * vec3<f32>(_S228.intensity) / vec3<f32>((dot(_S232, _S232) * probability_4));
            sample_0.radiance = _S234;
            shadow_1 = _S232;
        }
        else
        {
            var _S235 : vec3<f32> = sampleSphere(_S228.position, _S228.variance, start_2, _S206.value, _S207.value);
            sample_0.dir = _S235;
            var _S236 : f32 = sphereDensity(_S228.position, _S228.variance, start_2);
            var _S237 : f32 = probability_4 * _S236;
            sample_0.density = _S237;
            var _S238 : vec3<f32> = pointLightRadiance(_S228.color, _S228.intensity, _S228.variance);
            var _S239 : vec3<f32> = _S238 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S239;
            var _S240 : f32 = raySphere_0(_S228.position, _S228.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S241 : vec3<f32> = sample_0.dir * vec3<f32>(_S240);
            shadow_1 = _S241;
        }
    }
    else
    {
        var _S242 : u32 = _S226.y;
        var _S243 : u32 = ((instance_uint[(_S242) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S244 : u32 = _S243 + _S226.z;
        var _S245 : mat3x3<f32> = (worldTriangle((_S242), (_S244)));
        var _S246 : f32 = sqrt(_S206.value);
        var _S247 : vec2<f32> = vec2<f32>(_S246 * (1.0f - _S207.value), _S246 * _S207.value);
        var _S248 : vec3<f32> = (((_S245) * (vec3<f32>(1.0f - _S246, _S247))));
        if(sided_0)
        {
            var _S249 : f32 = (sign((dot(geometry_n_1, _S248 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S249);
            var _S250 : vec3<f32> = origin_4 + _S211 * lift_n_2;
            start_2 = _S250;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S251 : bool = !((dot(smooth_n_4, _S248 - origin_4)) > 0.0f);
            if(_S251)
            {
                return sample_0;
            }
            start_2 = _S212;
            lift_n_0 = smooth_n_4;
        }
        var _S252 : Surface = (surfaceAt((Hit_x24init_0(_S247, _S242, _S244, u32(0), 0.0f)), (_S248), (_S207.state)));
        sample_0.random_state = _S252.random_state;
        var _S253 : vec3<f32> = _S248 - start_2;
        var _S254 : vec3<f32> = (normalize((_S253)));
        sample_0.dir = _S254;
        var _S255 : f32 = solidAngle(probability_4, cross(_S245[i32(1)] - _S245[i32(0)], _S245[i32(2)] - _S245[i32(0)]), _S253);
        sample_0.density = _S255;
        var _S256 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S252.smooth_n))));
        var _S257 : vec3<f32> = _S252.material.emissive * vec3<f32>(max(_S256, 0.0f));
        var _S258 : vec3<f32> = select(_S257, _S208, _S252.skip);
        var _S259 : vec3<f32> = _S258 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S259;
        shadow_1 = _S253;
    }
    var _S260 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S261 : vec3<f32> = sample_0.radiance * _S260;
    var _S262 : bool = (all((_S260 == _S208)));
    var _S263 : vec3<f32> = select(_S261, _S208, _S262);
    sample_0.radiance = _S263;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S264 : AnisotropicFrame;
    _S264.tangent = tangent_1;
    _S264.alphas = alphas_0;
    return _S264;
}

fn anisotropicFrame( material_4 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S265 : f32 = material_4.roughness;
    var _S266 : f32 = _S265 * _S265;
    var _S267 : bool = (material_4.anisotropy) == 0.0f;
    var _S268 : bool;
    if(_S267)
    {
        _S268 = true;
    }
    else
    {
        _S268 = !(_S266 > 0.0f);
    }
    if(_S268)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S269 : vec3<f32> = material_4.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_4.tangent));
    var _S270 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S271 : bool = (dot(_S269, _S269)) > 0.0f;
    var _S272 : vec3<f32> = select(_S270, _S269, _S271);
    var _S273 : vec3<f32> = (normalize((_S272)));
    var _S274 : f32 = 6.28318548202514648f * material_4.anisotropic_rotation;
    var _S275 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_4.anisotropy));
    var _S276 : f32 = 1.0f / _S275;
    var _S277 : bool = (material_4.anisotropy) < 0.0f;
    var _S278 : f32 = select(_S275, _S276, _S277);
    return AnisotropicFrame_x24init_0(_S273 * vec3<f32>(cos(_S274)) + cross(n_i_0, _S273) * vec3<f32>(sin(_S274)), vec2<f32>(_S266 / _S278, _S266 * _S278));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S279 : SheenProfile;
    _S279.on = on_0;
    _S279.albedo = albedo_1;
    return _S279;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_5 : Material) -> SheenProfile
{
    var _S280 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S281 : f32 = rgb_to_greyscale(material_5.sheen);
    var _S282 : bool = _S281 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S282)
    {
        var _S283 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S284 : u32 = min(u32(_S283), u32(22));
        var _S285 : f32 = sqrt(0.05000000074505806f);
        var _S286 : f32 = (clamp(sqrt(max(material_5.sheen_roughness, 0.0f)), _S285, 1.0f) - _S285) / (1.0f - _S285) * 23.0f;
        var _S287 : u32 = min(u32(_S286), u32(22));
        var _S288 : u32 = _S284 * u32(24) + _S287;
        var _S289 : f32 = _S283 - f32(_S284);
        var _S290 : f32 = _S286 - f32(_S287);
        var _S291 : u32 = _S288 + u32(24);
        var _S292 : f32 = SHEEN_ALBEDO_0[_S288] + (SHEEN_ALBEDO_0[_S291] - SHEEN_ALBEDO_0[_S288]) * _S289;
        var _S293 : u32 = _S288 + u32(1);
        var _S294 : f32 = SHEEN_ALBEDO_0[_S293] + (SHEEN_ALBEDO_0[_S291 + u32(1)] - SHEEN_ALBEDO_0[_S293]) * _S289;
        var _S295 : SheenProfile = SheenProfile_x24init_0(true, exp(_S292 + (_S294 - _S292) * _S290));
        profile_0 = _S295;
    }
    else
    {
        profile_0 = _S280;
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
    var _S296 : BSDFLobes;
    _S296.v_dot_h = v_dot_h_0;
    _S296.n_dot_h = n_dot_h_0;
    _S296.refracted = refracted_0;
    _S296.F = F_0;
    _S296.F_greyscale = F_greyscale_0;
    _S296.reflect_weight = reflect_weight_0;
    _S296.diffuse_weight = diffuse_weight_0;
    _S296.refract_weight = refract_weight_0;
    _S296.p_diffuse = p_diffuse_0;
    _S296.p_reflect = p_reflect_0;
    _S296.p_refract = p_refract_0;
    _S296.translucent_share = translucent_share_0;
    _S296.sheen = sheen_1;
    _S296.p_sheen_velvet = p_sheen_velvet_0;
    _S296.view = view_0;
    _S296.tangent = tangent_2;
    _S296.alphas = alphas_1;
    _S296.visible = visible_0;
    return _S296;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_3, t_4)), dot(w_1, n_3));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S297 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S298 : f32 = _S297.x;
    var _S299 : f32 = _S297.y;
    var _S300 : f32 = _S298 * _S298 + _S299 * _S299;
    const _S301 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S302 : vec3<f32> = vec3<f32>(- _S299, _S298, 0.0f);
    var _S303 : f32 = (inverseSqrt((_S300)));
    var _S304 : vec3<f32> = _S302 * vec3<f32>(_S303);
    var _S305 : bool = _S300 > 0.0f;
    var _S306 : vec3<f32> = select(_S301, _S304, _S305);
    var _S307 : vec3<f32> = cross(_S297, _S306);
    var _S308 : f32 = sqrt(U1_0);
    var _S309 : f32 = 6.28318548202514648f * U2_0;
    var _S310 : f32 = _S308 * cos(_S309);
    var t2_0 : f32 = _S308 * sin(_S309);
    var _S311 : f32 = 0.5f * (1.0f + _S297.z);
    var t2_1 : f32 = (1.0f - _S311) * sqrt(max(0.0f, 1.0f - _S310 * _S310)) + _S311 * t2_0;
    var _S312 : vec3<f32> = vec3<f32>(_S310) * _S306 + vec3<f32>(t2_1) * _S307;
    var _S313 : f32 = ((_S310));
    var _S314 : f32 = ((_S310));
    var _S315 : vec3<f32> = _S312 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S313 * _S314 - t2_1 * t2_1))) * _S297;
    var _S316 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S315.x, alpha_0 * _S315.y, max(0.0f, _S315.z)))));
    return _S316;
}

fn worldToTangent( v_2 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S317 : bool = (abs(dot(n_4, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S317)
    {
        const _S318 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S318;
    }
    else
    {
        a_4 = a_3;
    }
    var _S319 : vec3<f32> = (normalize((cross(n_4, a_4))));
    var _S320 : vec3<f32> = cross(n_4, _S319);
    return vec3<f32>(dot(v_2, _S319), dot(v_2, n_4), dot(v_2, _S320));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S321 : Random = pcg((*random_state_3));
    var _S322 : Random = pcg(_S321.state);
    (*random_state_3) = _S322.state;
    var _S323 : f32 = frame_0.alphas.x;
    var _S324 : bool = _S323 > 0.0f;
    if(_S324)
    {
        var _S325 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S326 : f32 = frame_0.alphas.y;
        var _S327 : vec3<f32> = (normalize((vec3<f32>(_S323 * _S325.x, _S326 * _S325.y, _S325.z))));
        var _S328 : vec3<f32> = sampleGGXVNDF(_S327, 1.0f, _S321.value, _S322.value);
        var _S329 : vec3<f32> = (normalize((vec3<f32>(_S323 * _S328.x, _S326 * _S328.y, _S328.z))));
        return vec3<f32>(_S329.x) * frame_0.tangent + vec3<f32>(_S329.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S329.z) * n_i_2;
    }
    var _S330 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S331 : vec3<f32> = sampleGGXVNDF(_S330.xzy, alpha_1, _S321.value, _S322.value);
    var _S332 : vec3<f32> = _S331.xzy;
    var _S333 : vec3<f32> = tangentToWorld(_S332, n_i_2);
    return _S333;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_6 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S334 : vec3<f32> = ((-(in_dir_0)));
    var _S335 : f32 = (sign((dot(n_5, _S334))));
    var _S336 : f32 = material_6.roughness;
    var _S337 : vec3<f32> = sampleHalfVector(_S334, n_5 * vec3<f32>(_S335), _S336 * _S336, frame_1, &(state_2));
    return _S337;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S338 : vec3<f32> = ((-(in_dir_1)));
    var _S339 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S338 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S340 : vec3<f32> = (normalize((_S339)));
    var _S341 : f32 = (sign((dot(n_6, _S338))));
    var _S342 : f32 = (sign((dot(_S339, n_6 * vec3<f32>(_S341)))));
    return _S340 * vec3<f32>(_S342);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S343 : vec3<f32> = ((-(in_dir_2)));
    var _S344 : vec3<f32> = (normalize((_S343 + out_dir_1)));
    return _S344;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S345 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S345 / (_S345 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S345)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S346 : f32 = alphas_3.x;
    var _S347 : f32 = h_0.x / _S346;
    var _S348 : f32 = alphas_3.y;
    var _S349 : f32 = h_0.y / _S348;
    var _S350 : f32 = h_0.z;
    var _S351 : f32 = _S347 * _S347 + _S349 * _S349 + _S350 * _S350;
    return 1.0f / max(3.14159274101257324f * _S346 * _S348 * _S351 * _S351, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_7 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S352 : f32 = dot(ggx_n_0, v_4);
    var _S353 : f32 = dot(n_i_3, ggx_n_0);
    var _S354 : f32 = eta_i_3 / eta_o_3;
    var _S355 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S354))));
    var _S356 : f32 = min(sqrt(material_7.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S357 : f32 = _S356 * _S356;
    var _S358 : f32 = (1.0f + _S356) / (1.0f - _S356);
    var _S359 : f32 = abs(_S352);
    var _S360 : bool = eta_i_3 > eta_o_3;
    var sheen_component_0 : f32;
    if(_S360)
    {
        sheen_component_0 = _S358;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S360)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S358;
    }
    var _S361 : f32 = fresnel(_S359, sheen_component_0, visible_1);
    var _S362 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S352 * _S352)) >= (eta_o_3 * eta_o_3);
    var _S363 : vec3<f32>;
    if(_S362)
    {
        _S363 = vec3<f32>(1.0f);
    }
    else
    {
        var _S364 : vec3<f32> = material_7.specular_tint * vec3<f32>(_S357);
        _S363 = _S364 + (vec3<f32>(1.0f) - _S364) * vec3<f32>((_S361 - _S357)) / vec3<f32>((1.0f - _S357));
    }
    var _S365 : vec3<f32> = vec3<f32>(1.0f);
    var _S366 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S367 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S368 : vec3<f32> = vec3<f32>(1.0f) - material_7.sheen * vec3<f32>(_S367);
        var _S369 : f32 = rgb_to_greyscale(material_7.sheen);
        var _S370 : f32 = _S369 * _S367;
        var _S371 : vec3<f32> = material_7.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S368;
        sheen_component_0 = _S370;
        sheen_2 = _S371;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S365;
        sheen_component_0 = 0.0f;
        sheen_2 = _S366;
        view_1 = _S366;
    }
    var _S372 : vec3<f32> = (mix((_S363), (material_7.albedo), (material_7.metallic)));
    var F_1 : vec3<f32> = _S372 * scale_0;
    var _S373 : f32 = rgb_to_greyscale(F_1);
    var _S374 : f32 = 1.0f - material_7.metallic;
    var _S375 : vec3<f32> = vec3<f32>(1.0f) - _S363;
    var _S376 : vec3<f32> = vec3<f32>(((1.0f - material_7.transmission) * _S374)) * _S375 * scale_0;
    var _S377 : vec3<f32> = vec3<f32>((material_7.transmission * _S374)) * _S375 * scale_0;
    var _S378 : f32 = max(_S373, 0.0f);
    var _S379 : f32 = rgb_to_greyscale(_S376);
    var _S380 : f32 = max(_S379, 0.0f);
    var _S381 : f32 = rgb_to_greyscale(_S377);
    var _S382 : f32 = (sign((length(_S355))));
    var _S383 : f32 = max(_S381 * _S382, 0.0f);
    var _S384 : f32 = _S378 + _S380 + _S383;
    var _S385 : f32 = min(sheen_component_0, 1.0f);
    var _S386 : bool = sheen_component_0 > 0.0f;
    var _S387 : bool;
    if(_S386)
    {
        _S387 = !(_S384 > 0.0f);
    }
    else
    {
        _S387 = false;
    }
    var _S388 : f32 = select(_S385, 1.0f, _S387);
    var _S389 : f32 = (1.0f - _S388) / max(_S384, 0.0000152587890625f);
    var _S390 : f32 = _S380 * _S389;
    var _S391 : f32 = _S378 * _S389;
    var _S392 : f32 = _S383 * _S389;
    var _S393 : bool = (frame_2.alphas.x) > 0.0f;
    if(_S393)
    {
        var _S394 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S395 : f32 = anisotropicG1(_S394, frame_2.alphas);
        var _S396 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S397 : f32 = anisotropicD(_S396, frame_2.alphas);
        var _S398 : f32 = _S395 * _S397;
        visible_1 = _S398;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S352, _S353, _S355, F_1, _S373, 1.0f, _S376, _S377, _S390, _S391, _S392, 0.0f, sheen_2, _S388, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_8 : Material) -> f32
{
    var _S399 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S400 : f32 = rgb_to_greyscale(material_8.albedo);
    var _S401 : f32 = _S399 / (_S400 + _S399);
    var _S402 : bool = _S399 > 0.0f;
    var _S403 : f32 = select(0.0f, _S401, _S402);
    return _S403;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S404 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S405 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S406 : f32 = 1.0f - lobes_0.translucent_share;
    var _S407 : bool = n_i_dot_l_0 < 0.0f;
    var _S408 : f32 = select(_S406, lobes_0.translucent_share, _S407);
    var _S409 : f32 = _S405 * _S408;
    var _S410 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S411 : f32 = select(_S404, _S409, _S410);
    var _S412 : bool = n_i_dot_v_0 > 0.0f;
    var _S413 : f32 = select(0.0f, _S411, _S412);
    return _S413;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_9 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S414 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S415 : vec3<f32> = select(material_9.albedo, material_9.translucent, _S414);
    var _S416 : f32 = 1.0f - lobes_1.translucent_share;
    var _S417 : f32 = select(_S416, lobes_1.translucent_share, _S414);
    var _S418 : vec3<f32> = _S415 / vec3<f32>(_S417);
    var _S419 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S420 : vec3<f32> = select(material_9.albedo, _S418, _S419);
    return lobes_1.diffuse_weight * _S420 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S421 : f32 = alpha_4 * alpha_4;
    var _S422 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S421 + (1.0f - _S421) * n_dot_x_0 * n_dot_x_0));
    var _S423 : bool = alpha_4 > 0.0f;
    var _S424 : f32 = select(1.0f, _S422, _S423);
    return _S424;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S425 : f32 = alpha_5 * alpha_5;
    var _S426 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S425 * n_dot_h_1 * n_dot_h_1;
    return _S425 / max(3.14159274101257324f * _S426 * _S426, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S427 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S428 : f32 = _S427 * lobes_2.v_dot_h;
    var _S429 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S430 : f32 = _S428 * _S429 / n_i_dot_v_1;
    var _S431 : bool = alpha_6 > 0.0f;
    var _S432 : bool;
    if(_S431)
    {
        _S432 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S432 = false;
    }
    if(_S432)
    {
        _S432 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S432 = false;
    }
    if(_S432)
    {
        _S432 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S432 = false;
    }
    var _S433 : f32 = select(0.0f, _S430, _S432);
    var _S434 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S434)
    {
        var _S435 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S436 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S436)
        {
            _S432 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S432 = false;
        }
        if(_S432)
        {
            _S432 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S432 = false;
        }
        var _S437 : f32 = select(0.0f, _S435, _S432);
        pdf_h_0 = _S437;
    }
    else
    {
        pdf_h_0 = _S433;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S438 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S439 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S440 : f32 = lobes_3.p_refract * _S438 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S439 * _S439);
    var _S441 : bool = eta_i_5 != eta_o_5;
    var _S442 : bool;
    if(_S441)
    {
        _S442 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S442 = false;
    }
    var _S443 : f32 = select(0.0f, _S440, _S442);
    return _S443;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_10 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S444 : f32 = - dot(n_i_5, l_1);
    var _S445 : f32 = smithG1(alpha_8, max(_S444, 0.0f));
    var _S446 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S446)
    {
        var _S447 : vec3<f32> = ((-(n_i_5)));
        var _S448 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S447);
        var _S449 : f32 = anisotropicG1(_S448, lobes_4.alphas);
        G1_l_0 = _S449;
    }
    else
    {
        G1_l_0 = _S445;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_10.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S450 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S451 : bool = n_i_dot_l_2 > 0.0f;
    var _S452 : bool;
    if(_S451)
    {
        _S452 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S452 = false;
    }
    var _S453 : f32 = select(0.0f, _S450, _S452);
    return _S453;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_11 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S454 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S455 : f32 = dot(n_i_6, _S454);
    var _S456 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S457 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S458 : f32 = 1.0f / max(material_11.sheen_roughness, 0.05000000074505806f);
    var _S459 : f32 = (2.0f + _S458) * pow(max(1.0f - _S455 * _S455, 0.0f), 0.5f * _S458) * 0.5f * 0.31830987334251404f / max(4.0f * (_S456 + _S457 - _S456 * _S457), 0.0000152587890625f);
    return lobes_6.sheen * vec3<f32>((_S459 * _S456 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S460 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S461 : f32 = lobes_7.p_reflect * _S460 / (4.0f * lobes_7.v_dot_h);
    var _S462 : bool = _S460 > 0.0f;
    var _S463 : f32 = select(0.0f, _S461, _S462);
    return _S463;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_12 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S464 : f32 = dot(n_i_7, l_3);
    var _S465 : f32 = smithG1(alpha_12, max(_S464, 0.0f));
    var _S466 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S466)
    {
        var _S467 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S468 : f32 = anisotropicG1(_S467, lobes_8.alphas);
        G1_l_1 = _S468;
    }
    else
    {
        G1_l_1 = _S465;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_0 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S469 : vec3<f32> = ((-(in_dir_4)));
    var _S470 : f32 = dot(n_7, _S469);
    var _S471 : f32 = (sign((_S470)));
    var _S472 : vec3<f32> = n_7 * vec3<f32>(_S471);
    var _S473 : AnisotropicFrame = anisotropicFrame(material_13, _S472);
    var _S474 : f32 = dot(_S472, out_dir_2);
    var _S475 : f32 = material_13.roughness;
    var _S476 : f32 = _S475 * _S475;
    var _S477 : SheenProfile = sheenProfile(_S469, _S472, material_13);
    var _S478 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S479 : bool = _S478 > 0.0f;
    var _S480 : bool = (dot(n_7, out_dir_2) * _S470) < 0.0f;
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
        var _S481 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S481;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S482 : vec3<f32> = vec3<f32>(0.0f);
    var _S483 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S482, _S482, 0.0f, 0.0f, _S482, _S482, 0.0f, 0.0f, 0.0f, 0.0f, _S482, 0.0f, _S482, _S482, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S483;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S482;
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
        var _S484 : u32;
        if(i_0 == u32(3))
        {
            _S484 = u32(4);
        }
        else
        {
            _S484 = i_0;
        }
        var _S485 : bool = _S484 == u32(0);
        var _S486 : bool;
        if(_S485)
        {
            _S486 = _S479;
        }
        else
        {
            _S486 = false;
        }
        var _S487 : bool;
        if(_S486)
        {
            _S487 = _S480;
        }
        else
        {
            _S487 = _S484 == u32(1);
        }
        var _S488 : bool = _S487 != refracted_1;
        if(_S488)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S489 : u32;
        if(_S484 == u32(4))
        {
            _S489 = u32(2);
        }
        else
        {
            _S489 = _S484;
        }
        var _S490 : bool = _S489 != half_of_0;
        var half_of_1 : u32;
        if(_S490)
        {
            var _S491 : bool = _S489 == u32(0);
            if(_S491)
            {
                var _S492 : vec3<f32> = sampledHalf(in_dir_4, n_7, material_13, random_state_5, _S473);
                ggx_n_1 = _S492;
            }
            else
            {
                var _S493 : bool = _S489 == u32(1);
                if(_S493)
                {
                    var _S494 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S494;
                }
                else
                {
                    var _S495 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S495;
                }
            }
            var _S496 : vec3<f32> = ((-(in_dir_4)));
            var _S497 : BSDFLobes = bsdfLobes(in_dir_4, _S496, _S472, ggx_n_1, material_13, eta_i_8, eta_o_8, _S473, _S477);
            lobe_terms_0 = _S497;
            var _S498 : f32 = translucentShare(material_13);
            lobe_terms_0.translucent_share = _S498;
            half_of_1 = _S489;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S484)
        {
        case u32(0):
            {
                var _S499 : f32 = diffusePDF(_S474, 0.0f, abs(_S470), _S476, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S499;
                var _S500 : vec3<f32> = diffuseBSDF(out_dir_2, _S472, _S476, material_13, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S500;
            }
        case u32(1):
            {
                var _S501 : f32 = refractPDF(_S474, dot(out_dir_2, ggx_n_1), abs(_S470), _S476, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S501;
                var _S502 : vec3<f32> = refractBSDF(out_dir_2, _S472, _S476, material_13, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S502;
            }
        case u32(4):
            {
                var _S503 : f32 = sheenVelvetPDF(_S474, 0.0f, abs(_S470), _S476, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S503;
                var _S504 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S472, _S476, material_13, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S504;
            }
        default :
            {
                var _S505 : f32 = reflectPDF(_S474, 0.0f, abs(_S470), _S476, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S505;
                var _S506 : vec3<f32> = reflectBSDF(out_dir_2, _S472, _S476, material_13, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S506;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S482;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S507 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S507)
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
    var _S508 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(4)>;
    var pdfs_1 : array<f32, i32(4)>;
    var _S509 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S508, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S510 : bool = !competing_0;
    var _S511 : bool;
    if(_S510)
    {
        _S511 = true;
    }
    else
    {
        _S511 = (light_0.density) == 0.0f;
    }
    if(_S511)
    {
        return _S509 * light_0.radiance;
    }
    var _S512 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S512;
    loop
    {
        if(i_4 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S513 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S513)
        {
            var _S514 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S514 * _S514)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S515 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S516 : vec2<u32> = _S515 - vec2<u32>(u32(1), u32(0));
    var _S517 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S518 : vec2<u32> = min(vec2<u32>(_S517 * vec2<f32>(_S516)), _S516 - vec2<u32>(u32(1)));
    var _S519 : vec4<f32> = (textureLoad(environment_cdf, (_S518), 0));
    var _S520 : f32 = _S519.y;
    var _S521 : u32 = _S516.x;
    var _S522 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S521, _S518.y)), 0));
    var _S523 : f32 = _S520 * _S522.y;
    return _S523 * f32(_S521 * _S516.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_2 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var _S524 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    var _S525 : vec3<f32> = BSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S524, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S526 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_3 : vec3<f32> = _S526;
    loop
    {
        if(i_6 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S527 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S527)
        {
            var _S528 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S528;
            var f_4 : vec3<f32> = f_3 + (*terms_0)[i_6];
            f_3 = f_4;
        }
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    return f_3;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_6 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_8 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(4)>;
    var pdfs_3 : array<f32, i32(4)>;
    var _S529 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S529;
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
    var _S530 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S530;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S531 : u32 = (low_0 + high_0) / u32(2);
        var _S532 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S531)), 0));
        var _S533 : bool = (_S532.x) > u_0;
        if(_S533)
        {
            high_0 = _S531;
        }
        else
        {
            var _S534 : u32 = _S531 + u32(1);
            low_0 = _S534;
        }
    }
    return low_0;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S535 : SkySample;
    _S535.dir = dir_7;
    _S535.radiance = radiance_2;
    _S535.color = color_2;
    _S535.random_state = random_state_9;
    return _S535;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S536 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S537 : bool = is_inside_3 != _S536;
    var _S538 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S539 : vec3<f32> = select(surface_3.smooth_n, _S538, _S537);
    var _S540 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S539, dir_8);
    var _S541 : vec3<f32> = (env_map_sample((dir_8)));
    var _S542 : vec3<f32> = (shadowTransmittance((_S540), (4.294967296e+09f)));
    return _S541 * _S542;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S543 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S544 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S545 : vec2<u32> = _S543 - _S544;
    var _S546 : Random = pcg(init_random_state_1);
    var _S547 : Random = pcg(_S546.state);
    var _S548 : Random = pcg(_S547.state);
    var _S549 : Random = pcg(_S548.state);
    var _S550 : u32 = _S545.x;
    var _S551 : u32 = searchCDF_0(vec2<u32>(_S550, u32(0)), vec2<u32>(u32(0), u32(1)), _S545.y, _S546.value);
    var _S552 : u32 = searchCDF_0(vec2<u32>(u32(0), _S551), _S544, _S550, _S547.value);
    var _S553 : vec2<f32> = (vec2<f32>(f32(_S552), f32(_S551)) + vec2<f32>(_S548.value, _S549.value)) / vec2<f32>(_S545) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S554 : f32 = _S553.y;
    var _S555 : f32 = sin(_S554);
    var _S556 : f32 = _S553.x;
    var _S557 : vec3<f32> = vec3<f32>(_S555 * cos(_S556), cos(_S554), _S555 * sin(_S556));
    var _S558 : f32 = environmentPdf_0(_S557);
    var _S559 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S557, surface_4, eta_2, is_inside_4, _S558, lobe_state_0);
    var _S560 : bool = !(_S558 > 0.0f);
    var _S561 : bool;
    if(_S560)
    {
        _S561 = true;
    }
    else
    {
        _S561 = (all((_S559 == vec3<f32>(0.0f))));
    }
    if(_S561)
    {
        var _S562 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S557, _S562, _S562, _S549.state);
    }
    var _S563 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S557);
    return SkySample_x24init_0(_S557, _S563, _S559 * _S563, _S549.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S564 : vec3<f32> = a_5 / b_1;
    var _S565 : vec3<f32> = vec3<f32>(0.0f);
    var _S566 : vec3<bool> = b_1 == _S565;
    var _S567 : vec3<f32> = select(_S564, _S565, _S566);
    return _S567;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_5 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S568 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S569 : u32 = (insertBits((_S568), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S569;
    candidate_0.f = f_5;
    return candidate_0;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S570 : f32 = rgb_to_greyscale(weight_0);
    var _S571 : bool = _S570 > 0.0f;
    var _S572 : bool;
    if(_S571)
    {
        _S572 = _S570 < 3.00000000549775576e+38f;
    }
    else
    {
        _S572 = false;
    }
    var _S573 : bool = !_S572;
    if(_S573)
    {
        return;
    }
    var _S574 : f32 = (*sel_0).w_sum + _S570;
    (*sel_0).w_sum = _S574;
    var _S575 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S575;
    var _S576 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S576.state;
    var _S577 : bool = (_S576.value * (*sel_0).w_sum) <= _S570;
    if(_S577)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S578 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S579 : bool = (_S578.x) > u32(1);
    var _S580 : bool;
    if(_S579)
    {
        var _S581 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S580 = (_S581.y) > u32(1);
    }
    else
    {
        _S580 = false;
    }
    return _S580;
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
    var _S582 : SampleBSDF;
    _S582.unit_direction = unit_direction_1;
    _S582.throughput = throughput_0;
    _S582.random_state = random_state_10;
    _S582.refracted = refracted_3;
    _S582.lobe = lobe_1;
    _S582.pdf = pdf_4;
    return _S582;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S583 : vec3<f32> = vec3<f32>(1.0f);
    var _S584 : SampleBSDF = SampleBSDF_x24init_0(_S583, _S583, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S584;
    var _S585 : Random = pcg(random_state_11);
    var _S586 : Random = pcg(_S585.state);
    sample_1.random_state = _S586.state;
    var _S587 : f32 = _S585.value;
    var _S588 : f32 = sqrt(max(0.0f, 1.0f - _S587 * _S587));
    var _S589 : f32 = 6.28318548202514648f * _S586.value;
    var _S590 : vec3<f32> = tangentToWorld(vec3<f32>(_S588 * cos(_S589), _S585.value, _S588 * sin(_S589)), n_i_8);
    sample_1.unit_direction = _S590;
    sample_1.lobe = u32(4);
    var _S591 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S591;
    var _S592 : f32 = sheenVelvetPDF(_S585.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S592;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S593 : f32 = sqrt(random_1_0);
    var _S594 : f32 = 6.28318548202514648f * random_2_0;
    var _S595 : f32 = _S593 * cos(_S594);
    var _S596 : f32 = _S593 * sin(_S594);
    var _S597 : f32 = sqrt(max(0.0f, 1.0f - _S595 * _S595 - _S596 * _S596));
    return vec3<f32>(_S595, _S597, _S596);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S598 : vec3<f32> = vec3<f32>(1.0f);
    var _S599 : SampleBSDF = SampleBSDF_x24init_0(_S598, _S598, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S599;
    var _S600 : Random = pcg(random_state_12);
    var _S601 : Random = pcg(_S600.state);
    sample_2.random_state = _S601.state;
    var _S602 : vec3<f32> = sampleCosWeightedHemisphere(_S600.value, _S601.value);
    var _S603 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S604 : f32 = _S602.y;
    var _S605 : f32 = - _S604;
    var _S606 : f32 = select(_S604, _S605, _S603);
    var _S607 : vec3<f32> = tangentToWorld(vec3<f32>(_S602.x, _S606, _S602.z), n_i_9);
    sample_2.unit_direction = _S607;
    sample_2.refracted = _S603;
    sample_2.lobe = u32(0);
    var _S608 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S608;
    var _S609 : f32 = diffusePDF(_S606, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S609;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S610 : vec3<f32> = vec3<f32>(1.0f);
    var _S611 : SampleBSDF = SampleBSDF_x24init_0(_S610, _S610, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S611;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S612 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S612;
    var _S613 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S613;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S614 : vec3<f32> = vec3<f32>(1.0f);
    var _S615 : SampleBSDF = SampleBSDF_x24init_0(_S614, _S614, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S615;
    var _S616 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S616;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S617 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S617;
    var _S618 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S618;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S619 : vec3<f32> = ((-(in_dir_9)));
    var _S620 : f32 = dot(n_8, _S619);
    var _S621 : f32 = (sign((_S620)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S621);
    var _S622 : f32 = abs(_S620);
    var _S623 : f32 = material_19.roughness;
    var _S624 : f32 = _S623 * _S623;
    var _S625 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S626 : SheenProfile = sheenProfile(_S619, n_i_12, material_19);
    var _S627 : vec3<f32> = sampleHalfVector(_S619, n_i_12, _S624, _S625, &(random_state_15));
    var _S628 : BSDFLobes = bsdfLobes(in_dir_9, _S619, n_i_12, _S627, material_19, eta_i_14, eta_o_14, _S625, _S626);
    var lobes_13 : BSDFLobes = _S628;
    var _S629 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S629;
    var _S630 : Random = pcg(random_state_15);
    random_state_15 = _S630.state;
    var _S631 : bool = (_S630.value) < (lobes_13.p_sheen_velvet);
    if(_S631)
    {
        var _S632 : SampleBSDF = sheenVelvetSample(n_i_12, _S622, _S624, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S632;
    }
    var _S633 : f32 = _S630.value - lobes_13.p_sheen_velvet;
    var _S634 : bool = _S633 < (lobes_13.p_diffuse);
    if(_S634)
    {
        var _S635 : SampleBSDF = diffuseSample(_S633, n_i_12, _S622, _S624, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S635;
    }
    var _S636 : bool = _S633 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S636)
    {
        var _S637 : SampleBSDF = refractSample(_S627, n_i_12, _S622, _S624, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S637;
    }
    var _S638 : SampleBSDF = reflectSample(in_dir_9, _S627, n_i_12, _S622, _S624, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S638;
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S639 : bool = pdf_5 <= 0.0f;
    var _S640 : bool;
    if(_S639)
    {
        _S640 = true;
    }
    else
    {
        var _S641 : bool = environmentMapped_0();
        _S640 = !_S641;
    }
    if(_S640)
    {
        return 1.0f;
    }
    var _S642 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S642);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S643 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S643.x, max(_S643.y, _S643.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S644 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S645 : bool = (_S644.x) > u32(1);
    var _S646 : bool;
    if(_S645)
    {
        var _S647 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S646 = (_S647.y) > u32(1);
    }
    else
    {
        _S646 = false;
    }
    if(_S646)
    {
        var _S648 : vec3<f32> = (env_map_sample((dir_10)));
        return _S648;
    }
    var _S649 : vec3<f32> = (uniforms_float.ambient);
    return _S649;
}

fn walk_0( dom_1 : Domain,  r_4 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S650 : vec3<f32> = vec3<f32>(0.0f);
    var _S651 : Shift = Shift_x24init_0(_S650, 0.0f);
    var _S652 : u32 = (extractBits((r_4.path), (u32(0)), (u32(5))));
    var _S653 : u32 = (extractBits((r_4.path), (u32(5)), (u32(5))));
    var _S654 : u32 = (extractBits((r_4.path), (u32(10)), (u32(2))));
    var _S655 : u32 = (extractBits((r_4.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S656 : bool = _S655 >= u32(3);
        var _S657 : u32 = select(u32(0), u32(1), _S656);
        var _S658 : u32 = _S652 + _S657;
        var _S659 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S658 > _S659;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S651;
    }
    var _S660 : u32 = _S653 - u32(1);
    var _S661 : bool = _S655 == u32(3);
    var _S662 : u32 = select(u32(0), u32(1), _S661);
    var _S663 : u32 = _S652 + _S662;
    var _S664 : bool = _S654 == u32(0);
    var _S665 : u32 = select(_S660, _S663, _S664);
    var _S666 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_4.rc.zw))), r_4.rc.x, r_4.rc.y, u32(0), 0.0f);
    var _S667 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S668 : Ray = Ray_x24init_0(dom_1.x1, _S667);
    var ray_2 : Ray = _S668;
    var hit_2 : Hit = dom_1.hit;
    var _S669 : vec3<f32> = vec3<f32>(1.0f);
    var _S670 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S650, _S650, _S650);
    var nee_vertex_0 : NEEVertex = _S670;
    var _S671 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S671;
    var _S672 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S650, 0.0f, vec4<u32>(u32(0)), _S650, _S650);
    var chain_0 : Reservoir = _S672;
    chain_0.seed = r_4.seed;
    is_inside_5 = false;
    var threshold_0 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S650;
    var reconnection_0 : vec3<f32> = _S650;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S669;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S673 : bool = (hit_2.is_point_light) == u32(1);
        var _S674 : bool;
        if(replay_0)
        {
            _S674 = _S654 == u32(1);
        }
        else
        {
            _S674 = false;
        }
        var _S675 : bool;
        if(_S674)
        {
            _S675 = b_2 == _S653;
        }
        else
        {
            _S675 = false;
        }
        var _S676 : bool;
        if(_S675)
        {
            var _S677 : bool = (hit_2.instance_index) != (_S666.instance_index);
            if(_S677)
            {
                _S676 = true;
            }
            else
            {
                _S676 = (hit_2.triangle_index) != (_S666.triangle_index);
            }
        }
        else
        {
            _S676 = false;
        }
        if(_S676)
        {
            return _S651;
        }
        var _S678 : Surface = Surface_x24init_0(_S650, _S650, 0.0f, Material_x24init_0(_S650, _S650, 0.0f, 0.0f, 0.0f, 0.0f, _S650, _S669, 1.0f, _S650, _S650, 0.5f, 0.0f, 0.0f, _S650), false, u32(0));
        var _S679 : bool = !_S673;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S679)
        {
            var _S680 : u32 = stream(r_4.seed, b_2);
            var _S681 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S680)));
            var surface_6 : Surface = facingRay_0(_S681, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S682 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S683 : vec3<f32> = throughput_2 * _S682;
                front_n_0 = _S683;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S684 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S685 : bool = b_2 == u32(0);
            if(_S685)
            {
                var _S686 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S686;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S687 : vec3<f32> = front_n_0;
            var _S688 : f32 = geometry_density_0;
            scatter_0 = _S684;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S688;
            surface_5 = surface_6;
            front_n_0 = _S681.smooth_n;
            throughput_3 = _S687;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S678;
            front_n_0 = _S650;
            throughput_3 = throughput_2;
        }
        var _S689 : bool;
        if(scatter_0)
        {
            _S689 = prev_0.rough;
        }
        else
        {
            _S689 = false;
        }
        var _S690 : bool;
        if(_S689)
        {
            _S690 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S690 = false;
        }
        var _S691 : Surface = surface_5;
        var _S692 : Surface = surface_5;
        var _S693 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S694 : vec2<f32> = vertexEta(_S691.material, _S693);
        var _S695 : bool;
        if(scatter_0)
        {
            var _S696 : bool = neeDecision(_S691.material, _S693, _S694.x, _S694.y);
            _S695 = _S696;
        }
        else
        {
            _S695 = false;
        }
        var _S697 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S698 : vec3<f32> = _S691.material.emissive * vec3<f32>(max(_S697, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S673)
        {
            var _S699 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S699;
        }
        else
        {
            emission_0 = _S698;
        }
        var _S700 : bool = !replay_0;
        var _S701 : bool;
        if(_S700)
        {
            _S701 = true;
        }
        else
        {
            _S701 = b_2 >= _S665;
        }
        var _S702 : bool;
        if(_S701)
        {
            var _S703 : f32 = rgb_to_greyscale(emission_0);
            _S702 = _S703 > 0.0f;
        }
        else
        {
            _S702 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S702)
        {
            var _S704 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S704);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S705 : bool;
        if(replay_0)
        {
            _S705 = _S654 == u32(1);
        }
        else
        {
            _S705 = false;
        }
        var _S706 : bool;
        if(_S705)
        {
            _S706 = b_2 > _S653;
        }
        else
        {
            _S706 = false;
        }
        var _S707 : bool;
        if(_S706)
        {
            _S707 = b_2 == _S652;
        }
        else
        {
            _S707 = false;
        }
        var _S708 : bool;
        if(_S707)
        {
            var _S709 : bool = _S655 == u32(1);
            if(_S709)
            {
                _S708 = true;
            }
            else
            {
                _S708 = _S655 == u32(2);
            }
        }
        else
        {
            _S708 = false;
        }
        if(_S708)
        {
            var _S710 : bool = _S673 != (_S655 == u32(2));
            if(_S710)
            {
                return _S651;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S711 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S712 : bool = _S711 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S713 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S714 : u32 = (insertBits((_S713), (u32(1)), (u32(10)), (u32(2))));
        var _S715 : u32 = (insertBits((_S714), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S716 : bool = prev_0.inside;
        var _S717 : u32 = select(u32(0), u32(1), _S716);
        var _S718 : u32 = (insertBits((_S715), (_S717), (u32(22)), (u32(1))));
        here_0.path = _S718;
        var _S719 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S719;
        var _S720 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S720;
        var _S721 : bool;
        if(replay_0)
        {
            _S721 = _S654 == u32(1);
        }
        else
        {
            _S721 = false;
        }
        var _S722 : bool;
        if(_S721)
        {
            _S722 = b_2 == _S653;
        }
        else
        {
            _S722 = false;
        }
        var _S723 : bool = b_2 == _S665;
        var _S724 : bool;
        if(_S723)
        {
            var _S725 : bool = !scatter_0;
            if(_S725)
            {
                _S724 = true;
            }
            else
            {
                var _S726 : bool = _S654 != u32(1);
                if(_S726)
                {
                    _S724 = _S654 != u32(3);
                }
                else
                {
                    _S724 = false;
                }
            }
        }
        else
        {
            _S724 = false;
        }
        var _S727 : bool;
        if(_S724)
        {
            _S727 = _S654 == u32(2);
        }
        else
        {
            _S727 = false;
        }
        var _S728 : bool;
        if(_S727)
        {
            _S728 = !_S690;
        }
        else
        {
            _S728 = false;
        }
        var _S729 : bool;
        if(_S728)
        {
            _S729 = _S655 != u32(4);
        }
        else
        {
            _S729 = false;
        }
        var _S730 : bool = _S653 == _S652;
        var _S731 : bool;
        if(_S730)
        {
            _S731 = _S655 == u32(0);
        }
        else
        {
            _S731 = false;
        }
        var _S732 : bool;
        if(_S731)
        {
            _S732 = (hit_2.instance_index) == (_S666.instance_index);
        }
        else
        {
            _S732 = false;
        }
        var _S733 : bool;
        if(_S732)
        {
            _S733 = (hit_2.triangle_index) == (_S666.triangle_index);
        }
        else
        {
            _S733 = false;
        }
        var _S734 : bool;
        if(_S733)
        {
            _S734 = _S690;
        }
        else
        {
            _S734 = false;
        }
        var _S735 : bool = select(_S729, _S734, _S722);
        var _S736 : bool;
        if(_S695)
        {
            _S736 = select(scatter_0, _S735, replay_0);
        }
        else
        {
            _S736 = false;
        }
        var _S737 : TreeSample = TreeSample_x24init_0(_S650, _S650, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S736)
        {
            var _S738 : Surface = surface_5;
            var _S739 : bool = isTranslucent_0(_S691.material);
            var _S740 : u32 = stream(r_4.seed, b_2 + u32(64));
            var _S741 : TreeSample = sampleLightTree_0(ray_2.origin, _S692.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S739, _S740);
            var _S742 : bool = (any(((_S741.radiance) != _S650)));
            if(_S742)
            {
                var _S743 : f32 = _S694.x;
                var _S744 : f32 = _S694.y;
                var _S745 : u32 = (uniforms_uint.max_bounces);
                var _S746 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S741, _S692.smooth_n, _S738.geometry_n, _S691.material, _S743, _S744, b_2 < _S745, surface_5.random_state);
                lit_0 = _S746;
            }
            else
            {
                lit_0 = _S650;
            }
            light_1 = _S741;
        }
        else
        {
            light_1 = _S737;
            lit_0 = _S650;
        }
        var _S747 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S748 : bool;
        var _S749 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S722)
        {
            var _S750 : bool = !_S690;
            if(_S750)
            {
                return _S651;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S730)
            {
                _S747 = _S655 == u32(1);
            }
            else
            {
                _S747 = false;
            }
            if(_S747)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S730)
            {
                wrong_side_0 = _S655 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S751 : bool = !_S695;
                if(_S751)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S752 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S752 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S651;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S730)
            {
                refracted_4 = _S655 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S753 : bool = !_S695;
                if(_S753)
                {
                    return _S651;
                }
                var _S754 : f32 = environmentPdf_0(r_4.dir);
                var _S755 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S694, is_inside_5, _S754, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S755 * r_4.radiance / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S756 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S757 : bool = _S695 != (_S756 == u32(1));
            if(_S757)
            {
                return _S651;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S747 = _S723;
            }
            else
            {
                _S747 = false;
            }
            if(_S747)
            {
                var _S758 : bool = !scatter_0;
                if(_S758)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S759 : bool = _S654 != u32(1);
                    if(_S759)
                    {
                        wrong_side_0 = _S654 != u32(3);
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
                var _S760 : bool = _S654 == u32(2);
                if(_S760)
                {
                    _S674 = _S695;
                }
                else
                {
                    _S674 = false;
                }
                if(_S674)
                {
                    _S674 = !_S690;
                }
                else
                {
                    _S674 = false;
                }
                if(_S674)
                {
                    _S674 = _S655 == u32(4);
                }
                else
                {
                    _S674 = false;
                }
                if(_S674)
                {
                    var _S761 : u32 = stream(r_4.seed, b_2 + u32(256));
                    var _S762 : SkySample = sampleSky_0(ray_2, surface_5, _S694, is_inside_5, _S761, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S762.color, 1.0f);
                }
                if(_S760)
                {
                    is_inside_5 = _S695;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S690;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S763 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S764 : bool = !(_S763 > 0.0f);
                    if(_S764)
                    {
                        return _S651;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S664)
                {
                    is_inside_5 = _S655 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S673;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S664)
                {
                    is_inside_5 = _S655 == u32(1);
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
                    is_inside_5 = !_S690;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S651;
            }
            else
            {
                if(_S700)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S765 : bool = b_2 > u32(0);
                    if(_S765)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S712)
                        {
                            var _S766 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S766;
                        }
                        else
                        {
                            if(_S690)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S767 : vec3<f32> = throughput_3 * emission_1;
                        var _S768 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S767);
                        offer(&((*sel_1)), _S768, _S767 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S695)
                    {
                        var _S769 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S712)
                        {
                            var _S770 : vec3<f32> = safeDivide(_S769, chain_throughput_0);
                            candidate_3.radiance = _S770;
                        }
                        else
                        {
                            if(_S690)
                            {
                                candidate_3 = here_0;
                                var _S771 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S771;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S772 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S773 : u32 = (insertBits((_S772), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S773;
                            }
                        }
                        var _S774 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S769);
                        offer(&((*sel_1)), _S774, _S769 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S695)
                    {
                        var _S775 : bool = environmentMapped_0();
                        _S748 = _S775;
                    }
                    else
                    {
                        _S748 = false;
                    }
                    if(_S748)
                    {
                        var _S776 : u32 = (uniforms_uint.max_bounces);
                        _S749 = b_2 < _S776;
                    }
                    else
                    {
                        _S749 = false;
                    }
                    if(_S749)
                    {
                        var _S777 : u32 = stream(r_4.seed, b_2 + u32(256));
                        var _S778 : SkySample = sampleSky_0(ray_2, surface_5, _S694, is_inside_5, _S777, surface_5.random_state);
                        var _S779 : vec3<f32> = throughput_3 * _S778.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S712)
                        {
                            var _S780 : vec3<f32> = safeDivide(_S779, chain_throughput_0);
                            candidate_4.radiance = _S780;
                        }
                        else
                        {
                            if(_S690)
                            {
                                candidate_4 = here_0;
                                var _S781 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S781;
                                candidate_4.dir = _S778.dir;
                                candidate_4.radiance = _S778.radiance;
                            }
                            else
                            {
                                var _S782 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S783 : u32 = (insertBits((_S782), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S783;
                            }
                        }
                        var _S784 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S779);
                        offer(&((*sel_1)), _S784, _S779 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S785 : bool;
        var _S786 : bool;
        var _S787 : bool;
        var _S788 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S747 = _S723;
            }
            else
            {
                _S747 = false;
            }
            var _S789 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S790 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S791 : u32 = select(_S789, _S790, _S722);
            var refracted_5 : bool = _S791 == u32(1);
            var _S792 : SampleBSDF = SampleBSDF_x24init_0(_S650, _S650, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S792;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S747)
            {
                var _S793 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S794 : bool = is_inside_5 != (_S793 == u32(1));
                if(_S794)
                {
                    return _S651;
                }
                var _S795 : bool = _S654 == u32(1);
                if(_S795)
                {
                    var _S796 : vec3<f32> = (hitPosition((_S666)));
                    dir_11 = _S796;
                }
                else
                {
                    dir_11 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    var _S797 : bool = isTranslucent_0(_S691.material);
                    if(_S797)
                    {
                        wrong_side_0 = _S791 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S798 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S799 : vec3<f32> = select(r_4.dir, _S798, _S795);
                        refracted_4 = (dot(_S692.smooth_n, _S799) * _S693) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S795)
                {
                    var _S800 : vec3<f32> = ray_2.origin;
                    var _S801 : Surface = surface_5;
                    var _S802 : vec3<f32> = (vec3<f32>(0) - _S692.smooth_n);
                    var _S803 : bool = is_inside_5 != refracted_4;
                    var _S804 : vec3<f32> = select(_S692.smooth_n, _S802, _S803);
                    var _S805 : vec3<f32> = (normalize((dir_11 - (_S800 + vec3<f32>(_S801.geometry_offset) * _S804))));
                    reconnection_1 = _S805;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S806 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S806)
                {
                    return _S651;
                }
                var _S807 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S791;
                wrong_side_0 = false;
                reconnection_1 = _S807;
            }
            else
            {
                var _S808 : bool = !_S722;
                if(_S808)
                {
                    var _S809 : f32 = _S694.x;
                    var _S810 : f32 = _S694.y;
                    var _S811 : vec2<f32> = vec2<f32>(0.0f);
                    var _S812 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S692.smooth_n, _S691.material, _S809, _S810, surface_5.random_state, _S811);
                    var bsdf_sampled_0 : SampleBSDF = _S812;
                    var _S813 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S691.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S814 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S813.geometry_n, _S691.material, _S809, _S810, bsdf_sampled_0.random_state, _S811);
                        bsdf_sampled_0.unit_direction = _S814.unit_direction;
                        bsdf_sampled_0.refracted = _S814.refracted;
                        bsdf_sampled_0.throughput = _S814.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S815 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S813.geometry_n))) * _S813.geometry_n;
                            bsdf_sampled_0.unit_direction = _S815;
                        }
                    }
                    var _S816 : u32 = bsdf_sampled_0.lobe;
                    var _S817 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S818 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S819 : f32 = bsdf_sampled_0.pdf;
                    var _S820 : f32 = select(_S819, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S820;
                    dir_11 = _S817;
                    lobe_index_0 = _S816;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S818;
                }
                else
                {
                    dir_11 = r_4.dir;
                    lobe_index_0 = _S791;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S747)
            {
                _S748 = true;
            }
            else
            {
                _S748 = _S722;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S748)
            {
                var _S821 : vec3<f32> = ray_2.unit_direction;
                var _S822 : f32 = (sign((_S693)));
                var _S823 : vec3<f32> = _S692.smooth_n * vec3<f32>(_S822);
                var _S824 : f32 = dot(_S823, dir_11);
                var _S825 : f32 = _S691.material.roughness;
                var _S826 : f32 = _S825 * _S825;
                var _S827 : AnisotropicFrame = anisotropicFrame(_S691.material, _S823);
                var _S828 : vec3<f32> = ((-(_S821)));
                var _S829 : SheenProfile = sheenProfile(_S828, _S823, _S691.material);
                var _S830 : vec3<f32> = reflectedHalf(_S821, dir_11);
                var _S831 : bool = lobe_index_0 == u32(1);
                if(_S831)
                {
                    var _S832 : vec3<f32> = refractedHalf(_S821, dir_11, _S692.smooth_n, _S694.x, _S694.y);
                    throughput_6 = _S832;
                }
                else
                {
                    throughput_6 = _S830;
                }
                var _S833 : bool = lobe_index_0 == u32(0);
                if(_S833)
                {
                    var _S834 : vec3<f32> = sampledHalf(_S821, _S692.smooth_n, _S691.material, surface_5.random_state, _S827);
                    throughput_7 = _S834;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S835 : vec3<f32> = ((-(_S821)));
                var _S836 : f32 = _S694.x;
                var _S837 : f32 = _S694.y;
                var _S838 : BSDFLobes = bsdfLobes(_S821, _S835, _S823, throughput_7, _S691.material, _S836, _S837, _S827, _S829);
                var lobe_terms_1 : BSDFLobes = _S838;
                var _S839 : f32 = translucentShare(_S691.material);
                lobe_terms_1.translucent_share = _S839;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S840 : f32 = diffusePDF(_S824, 0.0f, abs(_S693), _S826, lobe_terms_1, _S836, _S837);
                        var _S841 : vec3<f32> = diffuseBSDF(dir_11, _S823, _S826, _S691.material, lobe_terms_1);
                        density_5 = _S840;
                        chain_throughput_1 = _S841;
                    }
                case u32(1):
                    {
                        var _S842 : f32 = refractPDF(_S824, dot(dir_11, throughput_7), abs(_S693), _S826, lobe_terms_1, _S836, _S837);
                        var _S843 : vec3<f32> = refractBSDF(dir_11, _S823, _S826, _S691.material, lobe_terms_1);
                        density_5 = _S842;
                        chain_throughput_1 = _S843;
                    }
                case u32(4):
                    {
                        var _S844 : f32 = sheenVelvetPDF(_S824, 0.0f, abs(_S693), _S826, lobe_terms_1, _S836, _S837);
                        var _S845 : vec3<f32> = sheenVelvetBSDF(dir_11, _S823, _S826, _S691.material, lobe_terms_1);
                        density_5 = _S844;
                        chain_throughput_1 = _S845;
                    }
                default :
                    {
                        var _S846 : f32 = reflectPDF(_S824, 0.0f, abs(_S693), _S826, lobe_terms_1, _S836, _S837);
                        var _S847 : vec3<f32> = reflectBSDF(dir_11, _S823, _S826, _S691.material, lobe_terms_1);
                        density_5 = _S846;
                        chain_throughput_1 = _S847;
                    }
                }
                var _S848 : bool = density_5 > 0.0f;
                if(_S848)
                {
                    var _S849 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, surface_5.random_state, _S831, lobe_index_0, density_5);
                    lobe_2 = _S849;
                }
            }
            var _S850 : bool = lobe_index_0 == u32(0);
            if(_S850)
            {
                _S749 = true;
            }
            else
            {
                _S749 = lobe_index_0 == u32(4);
            }
            var _S851 : bool = !_S749;
            if(_S851)
            {
                var _S852 : bool = (_S691.material.roughness) == 0.0f;
                if(_S852)
                {
                    _S785 = true;
                }
                else
                {
                    var _S853 : bool = lobe_index_0 == u32(1);
                    if(_S853)
                    {
                        _S785 = (_S694.x) == (_S694.y);
                    }
                    else
                    {
                        _S785 = false;
                    }
                }
            }
            else
            {
                _S785 = false;
            }
            var _S854 : bool = isTranslucent_0(_S691.material);
            if(_S854)
            {
                _S786 = _S850;
            }
            else
            {
                _S786 = false;
            }
            if(_S786)
            {
                _S787 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S787 = false;
            }
            if(_S695)
            {
                _S788 = !_S785;
            }
            else
            {
                _S788 = false;
            }
            var _S855 : bool;
            if(_S788)
            {
                _S855 = !wrong_side_0;
            }
            else
            {
                _S855 = false;
            }
            var _S856 : bool;
            if(_S855)
            {
                var _S857 : f32 = lobe_2.pdf;
                var _S858 : vec3<f32> = ray_2.origin;
                var _S859 : bool = isTranslucent_0(_S691.material);
                var _S860 : vec3<f32> = select(_S692.smooth_n, _S650, _S859);
                var _S861 : vec3<f32> = ray_2.origin;
                var _S862 : Surface = surface_5;
                var _S863 : vec3<f32> = (vec3<f32>(0) - _S692.smooth_n);
                var _S864 : vec3<f32> = select(_S692.smooth_n, _S863, _S787);
                var _S865 : NEEVertex = NEEVertex_x24init_0(false, _S857, _S858, _S860, _S861 + vec3<f32>(_S862.geometry_offset) * _S864);
                nee_vertex_0 = _S865;
            }
            else
            {
                var _S866 : bool = lobe_index_0 != u32(1);
                if(_S866)
                {
                    _S856 = true;
                }
                else
                {
                    _S856 = (_S694.x) != (_S694.y);
                }
                if(_S856)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S867 : bool = (lobe_2.pdf) > 0.0f;
            if(_S867)
            {
                if(_S749)
                {
                    _S856 = true;
                }
                else
                {
                    _S856 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S856 = false;
            }
            var _S868 : bool = (lobe_2.pdf) > 0.0f;
            var _S869 : bool;
            if(_S868)
            {
                if(_S749)
                {
                    _S869 = true;
                }
                else
                {
                    _S869 = (_S691.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S869 = false;
            }
            var _S870 : bool;
            if(_S722)
            {
                var _S871 : bool = !_S856;
                if(_S871)
                {
                    return _S651;
                }
                var _S872 : bool = _S655 != u32(1);
                if(_S872)
                {
                    _S870 = _S655 != u32(2);
                }
                else
                {
                    _S870 = false;
                }
                if(_S870)
                {
                    var _S873 : f32 = lobe_2.pdf;
                    var _S874 : f32 = select(0.0f, _S873, _S695);
                    var _S875 : f32 = escapeWeight_0(_S874, r_4.dir);
                    if(_S730)
                    {
                        is_inside_5 = _S661;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S876 : f32 = select(1.0f, _S875, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S876) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S877 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S878 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S877;
                density_5 = _S878;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S870 = b_2 <= _S665;
            }
            else
            {
                _S870 = false;
            }
            var _S879 : bool;
            if(_S870)
            {
                _S879 = _S690;
            }
            else
            {
                _S879 = false;
            }
            var _S880 : bool;
            if(_S879)
            {
                _S880 = _S856;
            }
            else
            {
                _S880 = false;
            }
            var _S881 : bool;
            if(_S880)
            {
                _S881 = true;
            }
            else
            {
                if(_S747)
                {
                    _S881 = !_S869;
                }
                else
                {
                    _S881 = false;
                }
            }
            if(_S881)
            {
                return _S651;
            }
            if(_S747)
            {
                var _S882 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S883 : f32 = lobe_2.pdf;
                throughput_7 = _S882;
                survival_probability_0 = _S883;
            }
            else
            {
                var _S884 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S650);
                throughput_7 = _S884;
                survival_probability_0 = density_5;
            }
            var _S885 : bool;
            if(_S700)
            {
                _S885 = !_S712;
            }
            else
            {
                _S885 = false;
            }
            var _S886 : bool;
            if(_S885)
            {
                _S886 = _S690;
            }
            else
            {
                _S886 = false;
            }
            var _S887 : bool;
            if(_S886)
            {
                _S887 = _S856;
            }
            else
            {
                _S887 = false;
            }
            if(_S887)
            {
                chain_0 = here_0;
                var _S888 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S889 : u32 = select(u32(0), u32(1), _S695);
                var _S890 : u32 = (insertBits((_S888), (_S889), (u32(21)), (u32(1))));
                chain_0.path = _S890;
                var _S891 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S891;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S892 : Vertex = Vertex_x24init_0(_S869, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S892;
            var _S893 : f32 = lobe_2.pdf;
            var _S894 : bool = lobe_index_0 == u32(1);
            var _S895 : bool;
            if(_S894)
            {
                _S895 = (_S694.x) == (_S694.y);
            }
            else
            {
                _S895 = false;
            }
            var _S896 : f32 = select(_S893, sky_pdf_0, _S895);
            var _S897 : bool;
            if(refracted_4)
            {
                _S897 = !_S787;
            }
            else
            {
                _S897 = false;
            }
            var is_inside_6 : bool;
            if(_S897)
            {
                var _S898 : bool = !is_inside_5;
                is_inside_6 = _S898;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S899 : Surface = surface_5;
            var _S900 : vec3<f32> = (vec3<f32>(0) - _S692.smooth_n);
            var _S901 : bool = is_inside_6 != _S787;
            var _S902 : vec3<f32> = select(_S692.smooth_n, _S900, _S901);
            var _S903 : vec3<f32> = ray_2.origin + vec3<f32>(_S899.geometry_offset) * _S902;
            ray_2.origin = _S903;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S896;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S700)
        {
            if(_S673)
            {
                var _S904 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S905 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S906 : bool = _S905 == u32(1);
                if(_S906)
                {
                    var _S907 : vec3<f32> = safeDivide(_S904, chain_throughput_0);
                    candidate_5.radiance = _S907;
                }
                var _S908 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S904);
                offer(&((*sel_1)), _S908, _S904 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S673)
            {
                _S747 = true;
            }
            else
            {
                _S747 = scatter_0;
            }
            if(_S747)
            {
                var _S909 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S909;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S910 : u32 = stream(r_4.seed, b_2 + u32(128));
            var _S911 : Random = pcg(_S910);
            var _S912 : bool = survival_probability_0 < (_S911.value);
            if(_S912)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S913 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S913;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S914 : f32 = density_5 * survival_probability_0;
            density_2 = _S914;
        }
        else
        {
            density_2 = density_5;
        }
        var _S915 : Ray = ray_2;
        var _S916 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S747 = _S723;
        }
        else
        {
            _S747 = false;
        }
        if(_S747)
        {
            wrong_side_0 = _S654 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S917 : f32 = select(4.294967296e+09f, _S916, wrong_side_0);
        var _S918 : Hit = (traverseInstanceBVH((_S915), (_S679), (_S917)));
        hit_2 = _S918;
        if(replay_0)
        {
            refracted_4 = _S723;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S748 = _S654 == u32(1);
        }
        else
        {
            _S748 = false;
        }
        if(_S748)
        {
            _S749 = (hit_2.instance_index) == (_S666.instance_index);
        }
        else
        {
            _S749 = false;
        }
        if(_S749)
        {
            _S785 = (hit_2.triangle_index) == (_S666.triangle_index);
        }
        else
        {
            _S785 = false;
        }
        if(_S785)
        {
            hit_2.uv = _S666.uv;
            var _S919 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S919;
        }
        if(replay_0)
        {
            _S786 = _S723;
        }
        else
        {
            _S786 = false;
        }
        if(_S786)
        {
            _S787 = _S654 == u32(3);
        }
        else
        {
            _S787 = false;
        }
        if(_S787)
        {
            _S788 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S788 = false;
        }
        if(_S788)
        {
            return _S651;
        }
        var _S920 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S920)
        {
            var _S921 : bool = !nee_vertex_0.none;
            var _S922 : f32 = select(0.0f, sky_pdf_0, _S921);
            var _S923 : f32 = escapeWeight_0(_S922, ray_2.unit_direction);
            var _S924 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S925 : vec3<f32> = throughput_2 * _S924;
            if(replay_0)
            {
                if(_S723)
                {
                    is_inside_5 = _S654 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S925 * vec3<f32>(_S923) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
                }
                if(_S664)
                {
                    is_inside_5 = _S661;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S652;
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
                    return Shift_x24init_0(_S925 * vec3<f32>(_S923), 1.0f);
                }
                return _S651;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S926 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S927 : bool = _S926 == u32(1);
            if(_S927)
            {
                var _S928 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S929 : bool = _S928 == b_2;
                var _S930 : f32 = select(_S923, 1.0f, _S929);
                var _S931 : vec3<f32> = safeDivide(_S925 * vec3<f32>(_S930), chain_throughput_0);
                candidate_6.radiance = _S931;
            }
            else
            {
                var _S932 : bool = prev_0.rough;
                if(_S932)
                {
                    var _S933 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S934 : u32 = (insertBits((_S933), (u32(3)), (u32(10)), (u32(2))));
                    var _S935 : u32 = (insertBits((_S934), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S936 : bool = prev_0.inside;
                    var _S937 : u32 = select(u32(0), u32(1), _S936);
                    var _S938 : u32 = (insertBits((_S935), (_S937), (u32(22)), (u32(1))));
                    candidate_6.path = _S938;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S939 : vec3<f32> = _S925 * vec3<f32>(_S923);
            var _S940 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S939);
            offer(&((*sel_1)), _S940, _S939 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S941 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S941;
        var _S942 : u32 = b_2 + u32(1);
        b_2 = _S942;
    }
    return _S651;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S943 : vec3<f32> = vec3<f32>(0.0f);
    var _S944 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S943, 0.0f, vec4<u32>(u32(0)), _S943, _S943), 0.0f, _S943, u32(0));
    var sel_2 : Selection = _S944;
    var _S945 : bool = (r_5.w) <= 0.0f;
    if(_S945)
    {
        return Shift_x24init_0(_S943, 0.0f);
    }
    var _S946 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S946;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S947 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S947;
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
        var _S948 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S949 : u32 = (_S948 + u32(63)) / u32(64);
        var _S950 : bool = group_0 < _S949;
        if(_S950)
        {
            var _S951 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S952 : bool = _S951 < _S948;
            if(_S952)
            {
                var _S953 : u32 = (queued_shifts[(u32(83) + start_4 + _S951)]);
                return _S953;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S949;
        var start_5 : u32 = start_4 + _S948;
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
    var _S954 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S955 : u32 = t_5;
        var _S956 : bool = (bins_1[t_5]) < u32(40);
        if(_S956)
        {
            var _S957 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S955]]), u32(1));
            slots_0[t_5] = _S957;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S958 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S958)
    {
        var _S959 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S960 : bool = _S959 > u32(0);
        if(_S960)
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
                var _S961 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S961;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S962 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S959)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S962;
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
        var _S963 : u32 = t_5;
        var _S964 : bool = (bins_1[t_5]) < u32(40);
        if(_S964)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S963]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S965 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S965)
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
            var _S966 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S966 + u32(63)) / u32(64);
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
    var _S967 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S968 : vec2<f32> = vec2<f32>(0.5f);
    var _S969 : vec2<f32> = _S967.xy / vec2<f32>(_S967.z) * _S968 + _S968;
    var _S970 : vec2<f32> = vec2<f32>(_S969.x, 1.0f - _S969.y);
    var _S971 : vec2<u32> = (uniforms_uint.render_size);
    return _S970 * vec2<f32>(_S971);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S972 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S973 : bool;
    if(_S972)
    {
        var _S974 : vec2<u32> = (uniforms_uint.render_size);
        _S973 = (all((q_0 < vec2<i32>(_S974))));
    }
    else
    {
        _S973 = false;
    }
    if(_S973)
    {
        var _S975 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S973 = (bitcast<f32>((_S975.w))) > 0.0f;
    }
    else
    {
        _S973 = false;
    }
    return _S973;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S976 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S977 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S978 : vec2<f32> = project_0(_S976, _S977, dom_3.x1);
    var _S979 : vec2<i32> = vec2<i32>(floor(_S978));
    var _S980 : bool = previousValid_0(_S979);
    var _S981 : bool = !_S980;
    if(_S981)
    {
        return vec2<i32>(i32(-1));
    }
    var _S982 : Domain = (previousDomain((_S979)));
    var _S983 : bool = (_S982.hit.instance_index) == (dom_3.hit.instance_index);
    var _S984 : bool;
    if(_S983)
    {
        var _S985 : f32 = distance(_S982.x1, dom_3.x1);
        var _S986 : f32 = dom_3.hit.distance * 8.0f;
        var _S987 : vec2<u32> = (uniforms_uint.render_size);
        _S984 = _S985 <= (_S986 / f32(_S987.x));
    }
    else
    {
        _S984 = false;
    }
    if(_S984)
    {
        return _S979;
    }
    var _S988 : vec2<f32> = vec2<f32>(p_9 + _S979) + vec2<f32>(1.0f);
    var _S989 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S990 : vec3<f32> = (uniforms_float.camera_position);
    var _S991 : vec2<f32> = project_0(_S989, _S990, _S982.x1);
    var _S992 : vec2<i32> = vec2<i32>(floor(_S988 - _S991));
    var _S993 : vec2<i32> = vec2<i32>(i32(-1));
    var _S994 : bool = previousValid_0(_S992);
    var _S995 : vec2<i32> = select(_S993, _S992, _S994);
    return _S995;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S996 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S997 : bool;
    if(_S996)
    {
        _S997 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S997 = false;
    }
    if(_S997)
    {
        _S997 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S997 = false;
    }
    if(_S997)
    {
        _S997 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S997 = false;
    }
    return _S997;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S998 : vec3<f32> = vec3<f32>(0.0f);
    var _S999 : Domain = Domain_x24init_0(_S998, _S998, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S999;
    var _S1000 : bool = t_8 > u32(1);
    var _S1001 : bool;
    if(_S1000)
    {
        _S1001 = true;
    }
    else
    {
        var _S1002 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1001 = !_S1002;
    }
    if(_S1001)
    {
        return false;
    }
    var _S1003 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1004 : bool = (_S1003.x) < i32(0);
    if(_S1004)
    {
        return false;
    }
    var _S1005 : bool = t_8 == u32(0);
    if(_S1005)
    {
        var _S1006 : Reservoir = (loadReservoir(reservoir_prev, (_S1003)));
        var _S1007 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1006);
        (*job_2) = _S1007;
    }
    else
    {
        var _S1008 : Domain = (previousDomain((_S1003)));
        var _S1009 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1010 : ShiftJob = ShiftJob_x24init_0(_S1008, _S1009);
        (*job_2) = _S1010;
    }
    var _S1011 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1011)
    {
        if(_S1005)
        {
            _S1001 = true;
        }
        else
        {
            var _S1012 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1001 = !_S1012;
        }
    }
    else
    {
        _S1001 = false;
    }
    return _S1001;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1013 : ptr<function, array<u32, i32(3)>>)
{
    var _S1014 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S1015 : vec3<f32> = vec3<f32>(0.0f);
        var _S1016 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1015, _S1015, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1015, 0.0f, vec4<u32>(u32(0)), _S1015, _S1015));
        var job_3 : ShiftJob = _S1016;
        var _S1017 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1017)
        {
            var _S1018 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1018;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1013) = bins_2;
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
        var _S1019 : u32 = t_11;
        var _S1020 : bool = (bins_3[t_11]) < u32(40);
        if(_S1020)
        {
            var _S1021 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1019]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1022 : bool = local_invocation_index_2 < u32(40);
    if(_S1022)
    {
        var _S1023 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1024 : bool = _S1023 > u32(0);
        if(_S1024)
        {
            var _S1025 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1023)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1026 : vec2<u32> = global_invocation_id_1.xy;
    var _S1027 : vec2<i32> = vec2<i32>(_S1026 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1028 : vec2<i32> = _S1027 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1029 : bool = (all((_S1028 >= vec2<i32>(i32(0)))));
        var _S1030 : bool;
        if(_S1029)
        {
            var _S1031 : vec2<u32> = (uniforms_uint.render_size);
            _S1030 = (all((_S1028 < vec2<i32>(_S1031))));
        }
        else
        {
            _S1030 = false;
        }
        if(_S1030)
        {
            var _S1032 : vec4<u32> = (textureLoad(reservoir_prev, (_S1028), (u32(0)), 0));
            var _S1033 : u32 = _S1032.x;
            var _S1034 : bool = (bitcast<f32>((_S1032.z))) > 0.0f;
            var _S1035 : u32 = select(u32(0), _S1033, _S1034);
            seed_2 = _S1035;
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
    var _S1036 : u32 = local_invocation_id_0.y;
    var _S1037 : u32 = local_invocation_id_0.x;
    var _S1038 : u32 = duplication_seeds_0[(_S1036 + u32(8)) * u32(24) + _S1037 + u32(8)];
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
            var _S1039 : bool = (duplication_seeds_0[(_S1036 + seed_2) * u32(24) + _S1037 + x_1]) == _S1038;
            var _S1040 : u32 = select(u32(0), u32(1), _S1039);
            var count_2 : u32 = count_1 + _S1040;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1041 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1042 : bool = _S1038 != u32(0);
    var _S1043 : f32 = select(0.0f, _S1041, _S1042);
    textureStore(duplication_out, (vec2<i32>(_S1026)), 0, (vec4<u32>((bitcast<u32>((_S1043))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1044 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1044;
    var _S1045 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1045;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1046 : f32 = rgb_to_greyscale(r_7.f);
    var _S1047 : f32 = sel_4.w_sum / _S1046;
    var _S1048 : bool = _S1046 > 0.0f;
    var _S1049 : f32 = select(0.0f, _S1047, _S1048);
    r_7.w = _S1049;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1050 : vec2<u32> = global_invocation_id_2.xy;
    var _S1051 : vec2<i32> = vec2<i32>(_S1050);
    var _S1052 : vec3<f32> = vec3<f32>(0.0f);
    var _S1053 : Domain = Domain_x24init_0(_S1052, _S1052, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1053;
    var _S1054 : bool = (currentDomain((_S1051), &(dom_5)));
    var _S1055 : bool = !_S1054;
    if(_S1055)
    {
        storeReservoir(reservoir_prev_out, (_S1051), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1052, 0.0f, vec4<u32>(u32(0)), _S1052, _S1052)), (dom_5.hit));
        var _S1056 : vec2<f32> = vec2<f32>(_S1050);
        var _S1057 : vec2<u32> = (uniforms_uint.render_size);
        var _S1058 : vec2<f32> = _S1056 / vec2<f32>(_S1057.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1059 : vec3<f32> = vec3<f32>(_S1058, 1.0f);
        var _S1060 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1061 : vec3<f32> = (normalize(((((_S1060) * (_S1059))))));
        var _S1062 : vec3<f32> = environment_0(_S1061);
        textureStore(compute_out, (_S1051), (u32(0)), (vec4<f32>(_S1062, 1.0f)));
        var _S1063 : u32 = (uniforms_uint.is_temporal);
        var _S1064 : bool = _S1063 == u32(1);
        if(_S1064)
        {
            textureStore(compute_out, (_S1051), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1065 : Reservoir = (loadReservoir(reservoir_temp, (_S1051)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1065.c;
    loop
    {
        var _S1066 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1066)
        {
        }
        else
        {
            break;
        }
        var _S1067 : vec2<i32> = partner_0(_S1051, t_13);
        var neighbor_0 : Domain = _S1053;
        var _S1068 : bool = (currentDomain((_S1067), &(neighbor_0)));
        if(_S1068)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1069 : vec4<u32> = (textureLoad(reservoir_temp, (_S1067), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1069.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1070 : f32 = _S1065.c / max(count_3, 1.0f);
    var _S1071 : f32 = rgb_to_greyscale(_S1065.f);
    var _S1072 : bool = count_3 == 0.0f;
    var _S1073 : f32 = select(0.0f, 1.0f, _S1072);
    var _S1074 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1052, 0.0f, vec4<u32>(u32(0)), _S1052, _S1052), 0.0f, _S1052, u32(0));
    var sel_5 : Selection = _S1074;
    var _S1075 : u32 = (uniforms_uint.frame);
    var _S1076 : u32 = hash(_S1075);
    var _S1077 : u32 = global_invocation_id_2.x;
    var _S1078 : vec2<u32> = (uniforms_uint.render_size);
    var _S1079 : u32 = stream(_S1076, _S1077 + _S1078.x * global_invocation_id_2.y);
    var _S1080 : u32 = stream(_S1079, u32(195));
    sel_5.random_state = _S1080;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1073;
    loop
    {
        var _S1081 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1081)
        {
        }
        else
        {
            break;
        }
        var _S1082 : vec2<i32> = partner_0(_S1051, t_13);
        var neighbor_dom_0 : Domain = _S1053;
        var _S1083 : bool = (currentDomain((_S1082), &(neighbor_dom_0)));
        if(_S1083)
        {
            var _S1084 : Reservoir = (loadReservoir(reservoir_temp, (_S1082)));
            var _S1085 : vec4<u32> = (textureLoad(shift_data, (_S1082), (t_13), 0));
            var _S1086 : vec4<f32> = (bitcast<vec4<f32>>((_S1085)));
            var _S1087 : vec4<u32> = (textureLoad(shift_data, (_S1051), (t_13), 0));
            var _S1088 : vec4<f32> = (bitcast<vec4<f32>>((_S1087)));
            var _S1089 : f32 = (_S1084.c + _S1070) / c_sum_0;
            var _S1090 : bool = _S1071 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1090)
            {
                var _S1091 : f32 = _S1089 * _S1070 * _S1071;
                var _S1092 : f32 = _S1070 * _S1071;
                var _S1093 : f32 = rgb_to_greyscale(_S1088.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1091 / (_S1092 + _S1084.c * _S1093);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1094 : f32 = rgb_to_greyscale(_S1084.f);
            var _S1095 : vec3<f32> = _S1086.xyz;
            var _S1096 : Shift = Shift_x24init_0(_S1095, _S1086.w);
            var _S1097 : f32 = _S1089 * _S1084.c * _S1094;
            var _S1098 : f32 = _S1084.c * _S1094;
            var _S1099 : f32 = rgb_to_greyscale(_S1095);
            offerShifted(&(sel_5), _S1084, _S1096, _S1097 / (_S1098 + _S1070 * _S1099));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1065, Shift_x24init_0(_S1065.f, 1.0f), canonical_mis_0);
    var _S1100 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1051), (_S1100), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1051), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1101 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1102 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1103 : f32 = (sign((dot(_S1102, _S1101.smooth_n))));
    var _S1104 : vec3<f32> = _S1101.material.emissive * vec3<f32>(max(_S1103, 0.0f));
    var _S1105 : vec3<f32> = select(_S1104, _S1052, _S1101.skip);
    var _S1106 : vec3<f32> = clamp(sel_5.color + _S1105, _S1052, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1051), (u32(0)), (vec4<f32>(_S1106, 1.0f)));
    var _S1107 : u32 = (uniforms_uint.is_temporal);
    var _S1108 : bool = _S1107 == u32(1);
    if(_S1108)
    {
        textureStore(compute_out, (_S1051), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1109 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1110 : bool = _S1109 != u32(4294967295);
    if(_S1110)
    {
        var _S1111 : vec2<i32> = vec2<i32>((vec2<u32>(_S1109, (_S1109 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1112 : vec3<f32> = vec3<f32>(0.0f);
        var _S1113 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1112, _S1112, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1112, 0.0f, vec4<u32>(u32(0)), _S1112, _S1112));
        var shift_job_0 : ShiftJob = _S1113;
        var _S1114 : u32 = (_S1109 >> (u32(28)));
        var _S1115 : bool = spatialJob_0(_S1111, _S1114, &(shift_job_0));
        var _S1116 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1111), (_S1114), (vec4<u32>((bitcast<vec3<u32>>((_S1116.f))), (bitcast<u32>((_S1116.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1117 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1118 : array<u32, i32(3)>;
    spatialBins_0(_S1117, &(_S1118));
    var _S1119 : array<u32, i32(3)> = _S1118;
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
        var _S1120 : bool = (_S1119[t_16]) == u32(40);
        if(_S1120)
        {
            textureStore(shift_data_out, (_S1117), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1117, _S1119, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1121 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1121));
    countShifts_0(_S1121, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1122 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1123 : bool = _S1122 != u32(4294967295);
    if(_S1123)
    {
        var _S1124 : vec2<i32> = vec2<i32>((vec2<u32>(_S1122, (_S1122 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1125 : vec3<f32> = vec3<f32>(0.0f);
        var _S1126 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1125, _S1125, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1125, 0.0f, vec4<u32>(u32(0)), _S1125, _S1125));
        var shift_job_1 : ShiftJob = _S1126;
        var _S1127 : u32 = (_S1122 >> (u32(28)));
        var _S1128 : bool = temporalJob_0(_S1124, _S1127, &(shift_job_1));
        var _S1129 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1124), (_S1127), (vec4<u32>((bitcast<vec3<u32>>((_S1129.f))), (bitcast<u32>((_S1129.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1130 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1131 : array<u32, i32(3)>;
    temporalBins_0(_S1130, &(_S1131));
    var _S1132 : array<u32, i32(3)> = _S1131;
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
        var _S1133 : bool = (_S1132[t_18]) == u32(40);
        if(_S1133)
        {
            textureStore(temporal_shifts_out, (_S1130), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1130, _S1132, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1134 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1134));
    countShifts_0(_S1134, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1135 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1136 : vec3<f32> = vec3<f32>(0.0f);
    var _S1137 : Domain = Domain_x24init_0(_S1136, _S1136, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1137;
    var _S1138 : bool = (currentDomain((_S1135), &(dom_6)));
    var _S1139 : bool = !_S1138;
    if(_S1139)
    {
        storeReservoir(reservoir_temp_out, (_S1135), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1136, 0.0f, vec4<u32>(u32(0)), _S1136, _S1136)), (dom_6.hit));
        return;
    }
    var _S1140 : Reservoir = (loadReservoir(reservoir_initial, (_S1135)));
    var _S1141 : vec2<i32> = temporalNeighbor_0(_S1135, dom_6);
    var _S1142 : bool = (_S1141.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1142)
    {
        var _S1143 : Reservoir = (loadReservoir(reservoir_prev, (_S1141)));
        var _S1144 : vec4<u32> = (textureLoad(duplication, (_S1141), 0, 0));
        var _S1145 : f32 = (bitcast<f32>((_S1144.x)));
        var _S1146 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1147 : bool = _S1146 == u32(1);
        var _S1148 : f32 = select(0.0f, _S1145, _S1147);
        var _S1149 : f32 = (mix((20.0f), (1.0f), (pow(_S1148, 0.10000000149011612f))));
        var _S1150 : f32 = min(_S1143.c, _S1149);
        var _S1151 : vec4<u32> = (textureLoad(temporal_shifts, (_S1135), (u32(0)), 0));
        var _S1152 : vec4<f32> = (bitcast<vec4<f32>>((_S1151)));
        var _S1153 : vec4<f32> = vec4<f32>(_S1140.f, 1.0f);
        var _S1154 : Domain = (previousDomain((_S1141)));
        var _S1155 : bool = sameDomain_0(_S1154, dom_6);
        var _S1156 : bool = !_S1155;
        var to_previous_0 : vec4<f32>;
        if(_S1156)
        {
            var _S1157 : vec4<u32> = (textureLoad(temporal_shifts, (_S1135), (u32(1)), 0));
            var _S1158 : vec4<f32> = (bitcast<vec4<f32>>((_S1157)));
            to_previous_0 = _S1158;
        }
        else
        {
            to_previous_0 = _S1153;
        }
        var _S1159 : f32 = rgb_to_greyscale(_S1140.f);
        var _S1160 : f32 = rgb_to_greyscale(_S1143.f);
        var _S1161 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1136, 0.0f, vec4<u32>(u32(0)), _S1136, _S1136), 0.0f, _S1136, u32(0));
        var sel_6 : Selection = _S1161;
        var _S1162 : u32 = (uniforms_uint.frame);
        var _S1163 : u32 = hash(_S1162);
        var _S1164 : u32 = global_invocation_id_7.x;
        var _S1165 : vec2<u32> = (uniforms_uint.render_size);
        var _S1166 : u32 = stream(_S1163, _S1164 + _S1165.x * global_invocation_id_7.y);
        var _S1167 : u32 = stream(_S1166, u32(194));
        sel_6.random_state = _S1167;
        var _S1168 : f32 = _S1140.c * _S1159;
        var _S1169 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1170 : f32 = _S1168 / (_S1168 + _S1150 * _S1169);
        var _S1171 : f32 = _S1150 * _S1160;
        var _S1172 : vec3<f32> = _S1152.xyz;
        var _S1173 : f32 = rgb_to_greyscale(_S1172);
        var _S1174 : f32 = _S1171 / (_S1171 + _S1140.c * _S1173);
        var _S1175 : vec2<f32> = vec2<f32>(_S1170, _S1174);
        offerShifted(&(sel_6), _S1140, Shift_x24init_0(_S1140.f, 1.0f), _S1170);
        offerShifted(&(sel_6), _S1143, Shift_x24init_0(_S1172, _S1152.w), _S1174);
        var _S1176 : Reservoir = finalize(sel_6, _S1140.c + _S1150);
        r_8 = _S1176;
    }
    else
    {
        r_8 = _S1140;
    }
    storeReservoir(reservoir_temp_out, (_S1135), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1177 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1178 : vec3<f32> = vec3<f32>(0.0f);
    var _S1179 : Domain = Domain_x24init_0(_S1178, _S1178, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1179;
    var _S1180 : bool = (currentDomain((_S1177), &(dom_7)));
    var _S1181 : bool = !_S1180;
    if(_S1181)
    {
        storeReservoir(reservoir_initial_out, (_S1177), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1178, 0.0f, vec4<u32>(u32(0)), _S1178, _S1178)), (dom_7.hit));
        return;
    }
    var _S1182 : u32 = (uniforms_uint.frame);
    var _S1183 : u32 = hash(_S1182);
    var _S1184 : u32 = global_invocation_id_8.x;
    var _S1185 : vec2<u32> = (uniforms_uint.render_size);
    var _S1186 : u32 = stream(_S1183, _S1184 + _S1185.x * global_invocation_id_8.y);
    var _S1187 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1178, 0.0f, vec4<u32>(u32(0)), _S1178, _S1178);
    var _S1188 : Selection = Selection_x24init_0(_S1187, 0.0f, _S1178, u32(0));
    var initial_0 : Selection = _S1188;
    var _S1189 : u32 = stream(_S1186, u32(193));
    initial_0.random_state = _S1189;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1190 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1190)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1187;
        var _S1191 : u32 = stream(_S1186, i_10);
        r_9.seed = _S1191;
        var _S1192 : u32 = (uniforms_uint.samples);
        var _S1193 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1192), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1194 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1177), (_S1194), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1195 : Random = pcg(state_3);
    var _S1196 : Random = pcg(_S1195.state);
    var _S1197 : f32 = 6.28318548202514648f * _S1195.value;
    var _S1198 : f32 = sqrt(-2.0f * clamp(log(_S1196.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1196.state, _S1198 * cos(_S1197));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1199 : RandomSphere;
    _S1199.state = state_4;
    _S1199.value = value_1;
    return _S1199;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1200 : Random = normal_distribution(state_5);
    var _S1201 : Random = normal_distribution(_S1200.state);
    var _S1202 : Random = normal_distribution(_S1201.state);
    var _S1203 : vec3<f32> = (normalize((vec3<f32>(_S1200.value, _S1201.value, _S1202.value))));
    return RandomSphere_x24init_0(_S1202.state, _S1203);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1204 : vec3<f32> = p1_0 - p0_0;
    var _S1205 : vec3<f32> = p2_0 - p0_0;
    var _S1206 : vec2<f32> = uv1_0 - uv0_0;
    var _S1207 : vec2<f32> = uv2_0 - uv0_0;
    var _S1208 : f32 = _S1206.x;
    var _S1209 : f32 = _S1207.y;
    var _S1210 : f32 = _S1206.y;
    var _S1211 : f32 = _S1207.x;
    var _S1212 : f32 = _S1208 * _S1209 - _S1210 * _S1211;
    var _S1213 : f32 = 1.0f / _S1212;
    var _S1214 : vec3<f32> = vec3<f32>(_S1213);
    var t_20 : vec3<f32> = (_S1204 * vec3<f32>(_S1209) - _S1205 * vec3<f32>(_S1210)) * _S1214;
    var _S1215 : vec3<f32> = (_S1205 * vec3<f32>(_S1208) - _S1204 * vec3<f32>(_S1211)) * _S1214;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1216 : bool = (dot(cross(n_9, t_21), _S1215)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1216)
    {
        var _S1217 : vec3<f32> = ((-(t_21)));
        t_22 = _S1217;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1218 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1218, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1219 : vec3<f32> = t1_0 - t0_0;
    var _S1220 : vec3<f32> = t2_2 - t0_0;
    var _S1221 : vec3<f32> = t2_2 - t1_0;
    var _S1222 : f32 = min(length(_S1219), min(length(_S1220), length(_S1221)));
    var _S1223 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1224 : vec3<f32> = (normalize((n0_0)));
    var _S1225 : f32 = dot(geometry_n_4, _S1224);
    var _S1226 : vec3<f32> = (normalize((n1_0)));
    var _S1227 : f32 = dot(geometry_n_4, _S1226);
    var _S1228 : vec3<f32> = (normalize((n2_0)));
    var _S1229 : vec3<f32> = acos(abs(vec3<f32>(_S1225, _S1227, dot(geometry_n_4, _S1228))));
    var _S1230 : vec3<f32> = clamp(tan(_S1229), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1223 * _S1230, uvw_0), 0.0f, _S1222 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_10 : vec3<f32>,  material_20 : Material) -> vec3<f32>
{
    var _S1231 : vec3<f32> = ((-(dir_12)));
    var _S1232 : f32 = (sign((dot(n_10, _S1231))));
    var _S1233 : vec3<f32> = n_10 * vec3<f32>(_S1232);
    var _S1234 : AnisotropicFrame = anisotropicFrame(material_20, _S1233);
    var _S1235 : bool = (_S1234.alphas.x) > 0.0f;
    if(_S1235)
    {
        var _S1236 : f32 = material_20.transmission * (1.0f - material_20.metallic);
        var _S1237 : vec3<f32> = ((-(_S1233)));
        var _S1238 : vec3<f32> = anisotropicLocal(dir_12, _S1234.tangent, _S1237);
        var _S1239 : f32 = anisotropicG1(_S1238, _S1234.alphas);
        return vec3<f32>((_S1236 * _S1239)) * material_20.albedo;
    }
    var _S1240 : f32 = material_20.transmission * (1.0f - material_20.metallic);
    var _S1241 : f32 = material_20.roughness;
    var _S1242 : f32 = smithG1(_S1241 * _S1241, abs(dot(n_10, dir_12)));
    return vec3<f32>((_S1240 * _S1242)) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1243 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1244 : vec3<f32> = straightThrough(toward_1, n_11, material_21);
        _S1243 = _S1244;
    }
    else
    {
        _S1243 = vec3<f32>(0.0f);
    }
    return _S1243 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1245 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1245;
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

