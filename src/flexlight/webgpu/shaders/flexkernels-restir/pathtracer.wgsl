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
    var _S86 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S87 : bool = cos_a_0 > cos_b_0;
    var _S88 : f32 = select(_S86, 1.0f, _S87);
    return _S88;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S89 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S90 : vec3<f32> = node_0.high - node_0.low;
    var _S91 : vec3<f32> = p_3 - _S89;
    var _S92 : vec3<f32> = (normalize((_S91)));
    var _S93 : f32 = dot(_S91, _S91);
    var _S94 : f32 = dot(_S90, _S90) / 4.0f;
    var _S95 : f32 = abs(dot(node_0.w, _S92));
    var _S96 : f32 = sine(node_0.cos_theta_o);
    var _S97 : f32 = sqrt(max(1.0f - _S94 / _S93, 0.0f));
    var _S98 : bool = _S93 < _S94;
    var _S99 : f32 = select(_S97, -1.0f, _S98);
    var _S100 : f32 = sine(_S99);
    var _S101 : f32 = sine(_S95);
    var _S102 : f32 = cosSubClamped(_S101, _S95, _S96, node_0.cos_theta_o);
    var _S103 : f32 = sine(_S95);
    var _S104 : f32 = _S103 * node_0.cos_theta_o - _S95 * _S96;
    var _S105 : bool = _S95 > (node_0.cos_theta_o);
    var _S106 : f32 = select(_S104, 0.0f, _S105);
    var _S107 : f32 = cosSubClamped(_S106, _S102, _S100, _S99);
    var _S108 : bool = _S107 <= 0.0f;
    if(_S108)
    {
        return 0.0f;
    }
    var _S109 : f32 = - dot(_S92, normal_0);
    var _S110 : f32 = node_0.phi * _S107 / max(_S93, length(_S90) / 2.0f);
    var _S111 : f32 = sine(_S109);
    var _S112 : f32 = cosSubClamped(_S111, _S109, _S100, _S99);
    var _S113 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S114 : f32 = select(_S112, 1.0f, _S113);
    return max(_S110 * _S114, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S115 : f32 = importance(first_0, p_4, normal_1);
    var _S116 : f32 = importance(second_0, p_4, normal_1);
    var _S117 : vec2<f32> = vec2<f32>(_S115, _S116);
    var _S118 : f32 = _S117[child_0] / (_S115 + _S116);
    var _S119 : bool = (_S117[child_0]) > 0.0f;
    var _S120 : f32 = select(0.0f, _S118, _S119);
    return _S120;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S121 : vec3<f32> = center_0 - p_5;
    var _S122 : f32 = radius_0 * radius_0 / dot(_S121, _S121);
    var _S123 : bool = _S122 >= 1.0f;
    if(_S123)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S122)) / (6.28318548202514648f * _S122);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S124 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S125 : vec2<u32> = _S124.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S125;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S126 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S126.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S127 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S128 : u32 = n_0 + u32(1);
        var _S129 : LightBounds = (lightBounds((_S128)));
        var _S130 : LightBounds = (lightBounds((_S127)));
        var _S131 : u32 = trail_0.x;
        var _S132 : u32 = (_S131 & (u32(1)));
        var _S133 : f32 = childShare(_S129, _S130, origin_2, smooth_n_2, _S132);
        var probability_2 : f32 = probability_1 * _S133;
        var _S134 : bool = _S132 == u32(1);
        var _S135 : u32 = select(_S128, _S127, _S134);
        var _S136 : u32 = trail_0.y;
        var _S137 : vec2<u32> = vec2<u32>((((_S131 >> (u32(1)))) | (((_S136 << (u32(31)))))), (_S136 >> (u32(1))));
        n_0 = _S135;
        trail_0 = _S137;
        probability_1 = probability_2;
    }
    var _S138 : bool = (((_S124).z == (n_0)));
    var _S139 : bool = !_S138;
    var _S140 : bool;
    if(_S139)
    {
        _S140 = true;
    }
    else
    {
        var _S141 : LightBounds = (lightBounds((n_0)));
        var _S142 : f32 = importance(_S141, origin_2, smooth_n_2);
        _S140 = !(_S142 > 0.0f);
    }
    if(_S140)
    {
        _S140 = true;
    }
    else
    {
        var _S143 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S143)
        {
            _S140 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S140 = false;
        }
    }
    if(_S140)
    {
        return 0.0f;
    }
    var _S144 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S145 : bool = (_S144.x) == u32(2);
    if(_S145)
    {
        var _S146 : u32 = _S144.y;
        var _S147 : Light = (lights[(_S146)]);
        var _S148 : Light = (lights[(_S146)]);
        var _S149 : f32 = sphereDensity(_S147.position, _S148.variance, start_1);
        return probability_1 * _S149;
    }
    var _S150 : u32 = _S144.y;
    var _S151 : u32 = ((instance_uint[(_S150) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S152 : mat3x3<f32> = (worldTriangle((_S150), (_S151 + _S144.z)));
    var _S153 : f32 = solidAngle(probability_1, cross(_S152[i32(1)] - _S152[i32(0)], _S152[i32(2)] - _S152[i32(0)]), light_point_0 - start_1);
    return _S153;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S154 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S155 : bool = b_0 > 0.0f;
    var _S156 : f32 = select(1.0f, _S154, _S155);
    return _S156;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S157 : u32 = (lightSlot((hit_1)));
    var _S158 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S157, light_point_1);
    var _S159 : f32 = powerHeuristic(vertex_0.pdf, _S158);
    return _S159;
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
    var _S160 : TreeSample;
    _S160.dir = dir_2;
    _S160.radiance = radiance_1;
    _S160.density = density_0;
    _S160.random_state = random_state_2;
    return _S160;
}

fn isTranslucent_0( material_3 : Material) -> bool
{
    var _S161 : f32 = rgb_to_greyscale(material_3.translucent);
    return _S161 > 0.0f;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S162 : Random;
    _S162.state = state_0;
    _S162.value = value_0;
    return _S162;
}

fn pcg( state_1 : u32) -> Random
{
    var _S163 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S164 : u32 = hash(state_1);
    return Random_x24init_0(_S163, f32(_S164) / 4.294967296e+09f);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S165 : f32 = importance(first_1, p_6, normal_3);
    var _S166 : f32 = importance(second_1, p_6, normal_3);
    var _S167 : vec2<f32> = vec2<f32>(_S165, _S166);
    var _S168 : bool = _S165 == 0.0f;
    var _S169 : bool;
    if(_S168)
    {
        _S169 = _S166 == 0.0f;
    }
    else
    {
        _S169 = false;
    }
    if(_S169)
    {
        return u32(2);
    }
    var _S170 : f32 = _S165 + _S166;
    var _S171 : bool = _S166 > 0.0f;
    if(_S171)
    {
        _S169 = ((*pick_0) * _S170) >= _S165;
    }
    else
    {
        _S169 = false;
    }
    var _S172 : u32 = select(u32(0), u32(1), _S169);
    var _S173 : f32 = min(((*pick_0) * _S170 - f32(_S172) * _S165) / _S167[_S172], 0.99999994039535522f);
    (*pick_0) = _S173;
    var _S174 : f32 = (*probability_3) * (_S167[_S172] / _S170);
    (*probability_3) = _S174;
    return _S172;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S175 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S175)
    {
        const _S176 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S176;
    }
    else
    {
        a_2 = a_1;
    }
    var _S177 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S178 : vec3<f32> = cross(n_1, _S177);
    return vec3<f32>(v_0.x) * _S177 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S178;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S179 : vec3<f32> = center_1 - p_7;
    var _S180 : f32 = radius_1 * radius_1 / dot(_S179, _S179);
    var _S181 : f32 = u1_0 * _S180 / (1.0f + sqrt(max(1.0f - _S180, 0.0f)));
    var _S182 : f32 = 2.0f * u1_0;
    var _S183 : bool = _S180 >= 1.0f;
    var _S184 : f32 = select(_S181, _S182, _S183);
    var _S185 : f32 = sqrt(max(_S184 * (2.0f - _S184), 0.0f));
    var _S186 : f32 = 6.28318548202514648f * u2_0;
    var _S187 : vec3<f32> = vec3<f32>(_S185 * cos(_S186), 1.0f - _S184, _S185 * sin(_S186));
    var _S188 : vec3<f32> = (normalize((_S179)));
    var _S189 : vec3<f32> = tangentToWorld(_S187, _S188);
    return _S189;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S190 : vec3<f32> = center_2 - ray_0.origin;
    var _S191 : f32 = dot(_S190, ray_0.unit_direction);
    var _S192 : f32 = dot(_S190, _S190) - _S191 * _S191;
    var _S193 : f32 = radius_3 * radius_3;
    var _S194 : bool = _S192 > _S193;
    if(_S194)
    {
        return 4.294967296e+09f;
    }
    var _S195 : f32 = sqrt(_S193 - _S192);
    var _S196 : f32 = _S191 - _S195;
    var _S197 : f32 = _S191 + _S195;
    var _S198 : bool = _S196 > 0.0000152587890625f;
    var _S199 : bool;
    if(_S198)
    {
        _S199 = _S196 < max_len_0;
    }
    else
    {
        _S199 = false;
    }
    if(_S199)
    {
        return _S196;
    }
    var _S200 : bool = _S197 > 0.0000152587890625f;
    if(_S200)
    {
        _S199 = _S197 < max_len_0;
    }
    else
    {
        _S199 = false;
    }
    if(_S199)
    {
        return _S197;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S201 : vec3<f32> = (normalize((light_dir_0)));
    var _S202 : bool = (dot(smooth_n_3, _S201)) < 0.0f;
    if(_S202)
    {
        return vec3<f32>(0.0f);
    }
    var _S203 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S204 : Ray = Ray_x24init_0(_S203, _S201);
    var _S205 : f32 = shadowLength(light_dir_0);
    var _S206 : vec3<f32> = (shadowTransmittance((_S204), (_S205)));
    return _S206;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S207 : Random = pcg(init_random_state_0);
    var _S208 : Random = pcg(_S207.state);
    var _S209 : Random = pcg(_S208.state);
    var _S210 : vec3<f32> = vec3<f32>(0.0f);
    var _S211 : TreeSample = TreeSample_x24init_0(_S210, _S210, 0.0f, _S209.state);
    var sample_0 : TreeSample = _S211;
    var _S212 : vec3<f32> = select(smooth_n_4, _S210, sided_0);
    var _S213 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S214 : vec3<f32> = origin_4 + _S213 * smooth_n_4;
    var pick_1 : f32 = _S207.value;
    var probability_4 : f32 = 1.0f;
    var n_2 : u32 = u32(0);
    loop
    {
        var _S215 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
        if((_S215.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S216 : u32 = (access_light_tree(3u + 4u * (n_2)).w);
        var _S217 : u32 = n_2 + u32(1);
        var _S218 : LightBounds = (lightBounds((_S217)));
        var _S219 : LightBounds = (lightBounds((_S216)));
        var _S220 : u32 = pickChild(_S218, _S219, origin_4, _S212, &(pick_1), &(probability_4));
        var _S221 : bool = _S220 > u32(1);
        if(_S221)
        {
            return sample_0;
        }
        var _S222 : bool = _S220 == u32(1);
        var _S223 : u32 = select(_S217, _S216, _S222);
        n_2 = _S223;
    }
    var _S224 : bool = n_2 == u32(0);
    var _S225 : bool;
    if(_S224)
    {
        var _S226 : LightBounds = (lightBounds((u32(0))));
        var _S227 : f32 = importance(_S226, origin_4, _S212);
        _S225 = !(_S227 > 0.0f);
    }
    else
    {
        _S225 = false;
    }
    if(_S225)
    {
        return sample_0;
    }
    var _S228 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
    var _S229 : bool = (_S228.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S229)
    {
        var _S230 : Light = (lights[(_S228.y)]);
        if(sided_0)
        {
            var _S231 : f32 = (sign((dot(geometry_n_1, _S230.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S231);
            var _S232 : vec3<f32> = origin_4 + _S213 * lift_n_1;
            start_2 = _S232;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S214;
            lift_n_0 = smooth_n_4;
        }
        var _S233 : bool = (_S230.variance) == 0.0f;
        if(_S233)
        {
            var _S234 : vec3<f32> = _S230.position - start_2;
            var _S235 : vec3<f32> = (normalize((_S234)));
            sample_0.dir = _S235;
            var _S236 : vec3<f32> = _S230.color * vec3<f32>(_S230.intensity) / vec3<f32>((dot(_S234, _S234) * probability_4));
            sample_0.radiance = _S236;
            shadow_1 = _S234;
        }
        else
        {
            var _S237 : vec3<f32> = sampleSphere(_S230.position, _S230.variance, start_2, _S208.value, _S209.value);
            sample_0.dir = _S237;
            var _S238 : f32 = sphereDensity(_S230.position, _S230.variance, start_2);
            var _S239 : f32 = probability_4 * _S238;
            sample_0.density = _S239;
            var _S240 : vec3<f32> = pointLightRadiance(_S230.color, _S230.intensity, _S230.variance);
            var _S241 : vec3<f32> = _S240 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S241;
            var _S242 : f32 = raySphere_0(_S230.position, _S230.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S243 : vec3<f32> = sample_0.dir * vec3<f32>(_S242);
            shadow_1 = _S243;
        }
    }
    else
    {
        var _S244 : u32 = _S228.y;
        var _S245 : u32 = ((instance_uint[(_S244) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S246 : u32 = _S245 + _S228.z;
        var _S247 : mat3x3<f32> = (worldTriangle((_S244), (_S246)));
        var _S248 : f32 = sqrt(_S208.value);
        var _S249 : vec2<f32> = vec2<f32>(_S248 * (1.0f - _S209.value), _S248 * _S209.value);
        var _S250 : vec3<f32> = (((_S247) * (vec3<f32>(1.0f - _S248, _S249))));
        if(sided_0)
        {
            var _S251 : f32 = (sign((dot(geometry_n_1, _S250 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S251);
            var _S252 : vec3<f32> = origin_4 + _S213 * lift_n_2;
            start_2 = _S252;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S253 : bool = !((dot(smooth_n_4, _S250 - origin_4)) > 0.0f);
            if(_S253)
            {
                return sample_0;
            }
            start_2 = _S214;
            lift_n_0 = smooth_n_4;
        }
        var _S254 : Surface = (surfaceAt((Hit_x24init_0(_S249, _S244, _S246, u32(0), 0.0f)), (_S250), (_S209.state)));
        sample_0.random_state = _S254.random_state;
        var _S255 : vec3<f32> = _S250 - start_2;
        var _S256 : vec3<f32> = (normalize((_S255)));
        sample_0.dir = _S256;
        var _S257 : f32 = solidAngle(probability_4, cross(_S247[i32(1)] - _S247[i32(0)], _S247[i32(2)] - _S247[i32(0)]), _S255);
        sample_0.density = _S257;
        var _S258 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S254.smooth_n))));
        var _S259 : vec3<f32> = _S254.material.emissive * vec3<f32>(max(_S258, 0.0f));
        var _S260 : vec3<f32> = select(_S259, _S210, _S254.skip);
        var _S261 : vec3<f32> = _S260 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S261;
        shadow_1 = _S255;
    }
    var _S262 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S263 : vec3<f32> = sample_0.radiance * _S262;
    var _S264 : bool = (all((_S262 == _S210)));
    var _S265 : vec3<f32> = select(_S263, _S210, _S264);
    sample_0.radiance = _S265;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S266 : AnisotropicFrame;
    _S266.tangent = tangent_1;
    _S266.alphas = alphas_0;
    return _S266;
}

fn anisotropicFrame( material_4 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S267 : f32 = material_4.roughness;
    var _S268 : f32 = _S267 * _S267;
    var _S269 : bool = (material_4.anisotropy) == 0.0f;
    var _S270 : bool;
    if(_S269)
    {
        _S270 = true;
    }
    else
    {
        _S270 = !(_S268 > 0.0f);
    }
    if(_S270)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S271 : vec3<f32> = material_4.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_4.tangent));
    var _S272 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S273 : bool = (dot(_S271, _S271)) > 0.0f;
    var _S274 : vec3<f32> = select(_S272, _S271, _S273);
    var _S275 : vec3<f32> = (normalize((_S274)));
    var _S276 : f32 = 6.28318548202514648f * material_4.anisotropic_rotation;
    var _S277 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_4.anisotropy));
    var _S278 : f32 = 1.0f / _S277;
    var _S279 : bool = (material_4.anisotropy) < 0.0f;
    var _S280 : f32 = select(_S277, _S278, _S279);
    return AnisotropicFrame_x24init_0(_S275 * vec3<f32>(cos(_S276)) + cross(n_i_0, _S275) * vec3<f32>(sin(_S276)), vec2<f32>(_S268 / _S280, _S268 * _S280));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S281 : SheenProfile;
    _S281.on = on_0;
    _S281.albedo = albedo_1;
    return _S281;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_5 : Material) -> SheenProfile
{
    var _S282 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S283 : f32 = rgb_to_greyscale(material_5.sheen);
    var _S284 : bool = _S283 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S284)
    {
        var _S285 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S286 : u32 = min(u32(_S285), u32(22));
        var _S287 : f32 = sqrt(0.05000000074505806f);
        var _S288 : f32 = (clamp(sqrt(max(material_5.sheen_roughness, 0.0f)), _S287, 1.0f) - _S287) / (1.0f - _S287) * 23.0f;
        var _S289 : u32 = min(u32(_S288), u32(22));
        var _S290 : u32 = _S286 * u32(24) + _S289;
        var _S291 : f32 = _S285 - f32(_S286);
        var _S292 : f32 = _S288 - f32(_S289);
        var _S293 : u32 = _S290 + u32(24);
        var _S294 : f32 = SHEEN_ALBEDO_0[_S290] + (SHEEN_ALBEDO_0[_S293] - SHEEN_ALBEDO_0[_S290]) * _S291;
        var _S295 : u32 = _S290 + u32(1);
        var _S296 : f32 = SHEEN_ALBEDO_0[_S295] + (SHEEN_ALBEDO_0[_S293 + u32(1)] - SHEEN_ALBEDO_0[_S295]) * _S291;
        var _S297 : SheenProfile = SheenProfile_x24init_0(true, exp(_S294 + (_S296 - _S294) * _S292));
        profile_0 = _S297;
    }
    else
    {
        profile_0 = _S282;
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
    var _S298 : BSDFLobes;
    _S298.v_dot_h = v_dot_h_0;
    _S298.n_dot_h = n_dot_h_0;
    _S298.refracted = refracted_0;
    _S298.F = F_0;
    _S298.F_greyscale = F_greyscale_0;
    _S298.reflect_weight = reflect_weight_0;
    _S298.diffuse_weight = diffuse_weight_0;
    _S298.refract_weight = refract_weight_0;
    _S298.p_diffuse = p_diffuse_0;
    _S298.p_reflect = p_reflect_0;
    _S298.p_refract = p_refract_0;
    _S298.translucent_share = translucent_share_0;
    _S298.sheen = sheen_1;
    _S298.p_sheen_velvet = p_sheen_velvet_0;
    _S298.view = view_0;
    _S298.tangent = tangent_2;
    _S298.alphas = alphas_1;
    _S298.visible = visible_0;
    return _S298;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_3, t_4)), dot(w_1, n_3));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S299 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S300 : f32 = _S299.x;
    var _S301 : f32 = _S299.y;
    var _S302 : f32 = _S300 * _S300 + _S301 * _S301;
    const _S303 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S304 : vec3<f32> = vec3<f32>(- _S301, _S300, 0.0f);
    var _S305 : f32 = (inverseSqrt((_S302)));
    var _S306 : vec3<f32> = _S304 * vec3<f32>(_S305);
    var _S307 : bool = _S302 > 0.0f;
    var _S308 : vec3<f32> = select(_S303, _S306, _S307);
    var _S309 : vec3<f32> = cross(_S299, _S308);
    var _S310 : f32 = sqrt(U1_0);
    var _S311 : f32 = 6.28318548202514648f * U2_0;
    var _S312 : f32 = _S310 * cos(_S311);
    var t2_0 : f32 = _S310 * sin(_S311);
    var _S313 : f32 = 0.5f * (1.0f + _S299.z);
    var t2_1 : f32 = (1.0f - _S313) * sqrt(max(0.0f, 1.0f - _S312 * _S312)) + _S313 * t2_0;
    var _S314 : vec3<f32> = vec3<f32>(_S312) * _S308 + vec3<f32>(t2_1) * _S309;
    var _S315 : f32 = ((_S312));
    var _S316 : f32 = ((_S312));
    var _S317 : vec3<f32> = _S314 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S315 * _S316 - t2_1 * t2_1))) * _S299;
    var _S318 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S317.x, alpha_0 * _S317.y, max(0.0f, _S317.z)))));
    return _S318;
}

fn worldToTangent( v_2 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S319 : bool = (abs(dot(n_4, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S319)
    {
        const _S320 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S320;
    }
    else
    {
        a_4 = a_3;
    }
    var _S321 : vec3<f32> = (normalize((cross(n_4, a_4))));
    var _S322 : vec3<f32> = cross(n_4, _S321);
    return vec3<f32>(dot(v_2, _S321), dot(v_2, n_4), dot(v_2, _S322));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S323 : Random = pcg((*random_state_3));
    var _S324 : Random = pcg(_S323.state);
    (*random_state_3) = _S324.state;
    var _S325 : f32 = frame_0.alphas.x;
    var _S326 : bool = _S325 > 0.0f;
    if(_S326)
    {
        var _S327 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S328 : f32 = frame_0.alphas.y;
        var _S329 : vec3<f32> = (normalize((vec3<f32>(_S325 * _S327.x, _S328 * _S327.y, _S327.z))));
        var _S330 : vec3<f32> = sampleGGXVNDF(_S329, 1.0f, _S323.value, _S324.value);
        var _S331 : vec3<f32> = (normalize((vec3<f32>(_S325 * _S330.x, _S328 * _S330.y, _S330.z))));
        return vec3<f32>(_S331.x) * frame_0.tangent + vec3<f32>(_S331.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S331.z) * n_i_2;
    }
    var _S332 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S333 : vec3<f32> = sampleGGXVNDF(_S332.xzy, alpha_1, _S323.value, _S324.value);
    var _S334 : vec3<f32> = _S333.xzy;
    var _S335 : vec3<f32> = tangentToWorld(_S334, n_i_2);
    return _S335;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_6 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S336 : vec3<f32> = ((-(in_dir_0)));
    var _S337 : f32 = (sign((dot(n_5, _S336))));
    var _S338 : f32 = material_6.roughness;
    var _S339 : vec3<f32> = sampleHalfVector(_S336, n_5 * vec3<f32>(_S337), _S338 * _S338, frame_1, &(state_2));
    return _S339;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S340 : vec3<f32> = ((-(in_dir_1)));
    var _S341 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S340 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S342 : vec3<f32> = (normalize((_S341)));
    var _S343 : f32 = (sign((dot(n_6, _S340))));
    var _S344 : f32 = (sign((dot(_S341, n_6 * vec3<f32>(_S343)))));
    return _S342 * vec3<f32>(_S344);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S345 : vec3<f32> = ((-(in_dir_2)));
    var _S346 : vec3<f32> = (normalize((_S345 + out_dir_1)));
    return _S346;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S347 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S347 / (_S347 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S347)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S348 : f32 = alphas_3.x;
    var _S349 : f32 = h_0.x / _S348;
    var _S350 : f32 = alphas_3.y;
    var _S351 : f32 = h_0.y / _S350;
    var _S352 : f32 = h_0.z;
    var _S353 : f32 = _S349 * _S349 + _S351 * _S351 + _S352 * _S352;
    return 1.0f / max(3.14159274101257324f * _S348 * _S350 * _S353 * _S353, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_7 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S354 : f32 = dot(ggx_n_0, v_4);
    var _S355 : f32 = dot(n_i_3, ggx_n_0);
    var _S356 : f32 = eta_i_3 / eta_o_3;
    var _S357 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S356))));
    var _S358 : f32 = min(sqrt(material_7.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S359 : f32 = _S358 * _S358;
    var _S360 : f32 = (1.0f + _S358) / (1.0f - _S358);
    var _S361 : f32 = abs(_S354);
    var _S362 : bool = eta_i_3 > eta_o_3;
    var sheen_component_0 : f32;
    if(_S362)
    {
        sheen_component_0 = _S360;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S362)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S360;
    }
    var _S363 : f32 = fresnel(_S361, sheen_component_0, visible_1);
    var _S364 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S354 * _S354)) >= (eta_o_3 * eta_o_3);
    var _S365 : vec3<f32>;
    if(_S364)
    {
        _S365 = vec3<f32>(1.0f);
    }
    else
    {
        var _S366 : vec3<f32> = material_7.specular_tint * vec3<f32>(_S359);
        _S365 = _S366 + (vec3<f32>(1.0f) - _S366) * vec3<f32>((_S363 - _S359)) / vec3<f32>((1.0f - _S359));
    }
    var _S367 : vec3<f32> = vec3<f32>(1.0f);
    var _S368 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S369 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S370 : vec3<f32> = vec3<f32>(1.0f) - material_7.sheen * vec3<f32>(_S369);
        var _S371 : f32 = rgb_to_greyscale(material_7.sheen);
        var _S372 : f32 = _S371 * _S369;
        var _S373 : vec3<f32> = material_7.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S370;
        sheen_component_0 = _S372;
        sheen_2 = _S373;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S367;
        sheen_component_0 = 0.0f;
        sheen_2 = _S368;
        view_1 = _S368;
    }
    var _S374 : vec3<f32> = (mix((_S365), (material_7.albedo), (material_7.metallic)));
    var F_1 : vec3<f32> = _S374 * scale_0;
    var _S375 : f32 = rgb_to_greyscale(F_1);
    var _S376 : f32 = 1.0f - material_7.metallic;
    var _S377 : vec3<f32> = vec3<f32>(1.0f) - _S365;
    var _S378 : vec3<f32> = vec3<f32>(((1.0f - material_7.transmission) * _S376)) * _S377 * scale_0;
    var _S379 : vec3<f32> = vec3<f32>((material_7.transmission * _S376)) * _S377 * scale_0;
    var _S380 : f32 = max(_S375, 0.0f);
    var _S381 : f32 = rgb_to_greyscale(_S378);
    var _S382 : f32 = max(_S381, 0.0f);
    var _S383 : f32 = rgb_to_greyscale(_S379);
    var _S384 : f32 = (sign((length(_S357))));
    var _S385 : f32 = max(_S383 * _S384, 0.0f);
    var _S386 : f32 = _S380 + _S382 + _S385;
    var _S387 : f32 = min(sheen_component_0, 1.0f);
    var _S388 : bool = sheen_component_0 > 0.0f;
    var _S389 : bool;
    if(_S388)
    {
        _S389 = !(_S386 > 0.0f);
    }
    else
    {
        _S389 = false;
    }
    var _S390 : f32 = select(_S387, 1.0f, _S389);
    var _S391 : f32 = (1.0f - _S390) / max(_S386, 0.0000152587890625f);
    var _S392 : f32 = _S382 * _S391;
    var _S393 : f32 = _S380 * _S391;
    var _S394 : f32 = _S385 * _S391;
    var _S395 : bool = (frame_2.alphas.x) > 0.0f;
    if(_S395)
    {
        var _S396 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S397 : f32 = anisotropicG1(_S396, frame_2.alphas);
        var _S398 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S399 : f32 = anisotropicD(_S398, frame_2.alphas);
        var _S400 : f32 = _S397 * _S399;
        visible_1 = _S400;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S354, _S355, _S357, F_1, _S375, 1.0f, _S378, _S379, _S392, _S393, _S394, 0.0f, sheen_2, _S390, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_8 : Material) -> f32
{
    var _S401 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S402 : f32 = rgb_to_greyscale(material_8.albedo);
    var _S403 : f32 = _S401 / (_S402 + _S401);
    var _S404 : bool = _S401 > 0.0f;
    var _S405 : f32 = select(0.0f, _S403, _S404);
    return _S405;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S406 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S407 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S408 : f32 = 1.0f - lobes_0.translucent_share;
    var _S409 : bool = n_i_dot_l_0 < 0.0f;
    var _S410 : f32 = select(_S408, lobes_0.translucent_share, _S409);
    var _S411 : f32 = _S407 * _S410;
    var _S412 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S413 : f32 = select(_S406, _S411, _S412);
    var _S414 : bool = n_i_dot_v_0 > 0.0f;
    var _S415 : f32 = select(0.0f, _S413, _S414);
    return _S415;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_9 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S416 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S417 : vec3<f32> = select(material_9.albedo, material_9.translucent, _S416);
    var _S418 : f32 = 1.0f - lobes_1.translucent_share;
    var _S419 : f32 = select(_S418, lobes_1.translucent_share, _S416);
    var _S420 : vec3<f32> = _S417 / vec3<f32>(_S419);
    var _S421 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S422 : vec3<f32> = select(material_9.albedo, _S420, _S421);
    return lobes_1.diffuse_weight * _S422 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S423 : f32 = alpha_4 * alpha_4;
    var _S424 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S423 + (1.0f - _S423) * n_dot_x_0 * n_dot_x_0));
    var _S425 : bool = alpha_4 > 0.0f;
    var _S426 : f32 = select(1.0f, _S424, _S425);
    return _S426;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S427 : f32 = alpha_5 * alpha_5;
    var _S428 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S427 * n_dot_h_1 * n_dot_h_1;
    return _S427 / max(3.14159274101257324f * _S428 * _S428, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S429 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S430 : f32 = _S429 * lobes_2.v_dot_h;
    var _S431 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S432 : f32 = _S430 * _S431 / n_i_dot_v_1;
    var _S433 : bool = alpha_6 > 0.0f;
    var _S434 : bool;
    if(_S433)
    {
        _S434 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        _S434 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        _S434 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    var _S435 : f32 = select(0.0f, _S432, _S434);
    var _S436 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S436)
    {
        var _S437 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S438 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S438)
        {
            _S434 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S434 = false;
        }
        if(_S434)
        {
            _S434 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S434 = false;
        }
        var _S439 : f32 = select(0.0f, _S437, _S434);
        pdf_h_0 = _S439;
    }
    else
    {
        pdf_h_0 = _S435;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S440 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S441 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S442 : f32 = lobes_3.p_refract * _S440 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S441 * _S441);
    var _S443 : bool = eta_i_5 != eta_o_5;
    var _S444 : bool;
    if(_S443)
    {
        _S444 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S444 = false;
    }
    var _S445 : f32 = select(0.0f, _S442, _S444);
    return _S445;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_10 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S446 : f32 = - dot(n_i_5, l_1);
    var _S447 : f32 = smithG1(alpha_8, max(_S446, 0.0f));
    var _S448 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S448)
    {
        var _S449 : vec3<f32> = ((-(n_i_5)));
        var _S450 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S449);
        var _S451 : f32 = anisotropicG1(_S450, lobes_4.alphas);
        G1_l_0 = _S451;
    }
    else
    {
        G1_l_0 = _S447;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_10.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S452 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S453 : bool = n_i_dot_l_2 > 0.0f;
    var _S454 : bool;
    if(_S453)
    {
        _S454 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S454 = false;
    }
    var _S455 : f32 = select(0.0f, _S452, _S454);
    return _S455;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_11 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S456 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S457 : f32 = dot(n_i_6, _S456);
    var _S458 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S459 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S460 : f32 = 1.0f / max(material_11.sheen_roughness, 0.05000000074505806f);
    var _S461 : f32 = (2.0f + _S460) * pow(max(1.0f - _S457 * _S457, 0.0f), 0.5f * _S460) * 0.5f * 0.31830987334251404f / max(4.0f * (_S458 + _S459 - _S458 * _S459), 0.0000152587890625f);
    return lobes_6.sheen * vec3<f32>((_S461 * _S458 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S462 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S463 : f32 = lobes_7.p_reflect * _S462 / (4.0f * lobes_7.v_dot_h);
    var _S464 : bool = _S462 > 0.0f;
    var _S465 : f32 = select(0.0f, _S463, _S464);
    return _S465;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_12 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S466 : f32 = dot(n_i_7, l_3);
    var _S467 : f32 = smithG1(alpha_12, max(_S466, 0.0f));
    var _S468 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S468)
    {
        var _S469 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S470 : f32 = anisotropicG1(_S469, lobes_8.alphas);
        G1_l_1 = _S470;
    }
    else
    {
        G1_l_1 = _S467;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_0 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S471 : vec3<f32> = ((-(in_dir_4)));
    var _S472 : f32 = dot(n_7, _S471);
    var _S473 : f32 = (sign((_S472)));
    var _S474 : vec3<f32> = n_7 * vec3<f32>(_S473);
    var _S475 : AnisotropicFrame = anisotropicFrame(material_13, _S474);
    var _S476 : f32 = dot(_S474, out_dir_2);
    var _S477 : f32 = material_13.roughness;
    var _S478 : f32 = _S477 * _S477;
    var _S479 : SheenProfile = sheenProfile(_S471, _S474, material_13);
    var _S480 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S481 : bool = _S480 > 0.0f;
    var _S482 : bool = (dot(n_7, out_dir_2) * _S472) < 0.0f;
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
        var _S483 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S483;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S484 : vec3<f32> = vec3<f32>(0.0f);
    var _S485 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S484, _S484, 0.0f, 0.0f, _S484, _S484, 0.0f, 0.0f, 0.0f, 0.0f, _S484, 0.0f, _S484, _S484, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S485;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S484;
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
        var _S486 : u32;
        if(i_0 == u32(3))
        {
            _S486 = u32(4);
        }
        else
        {
            _S486 = i_0;
        }
        var _S487 : bool = _S486 == u32(0);
        var _S488 : bool;
        if(_S487)
        {
            _S488 = _S481;
        }
        else
        {
            _S488 = false;
        }
        var _S489 : bool;
        if(_S488)
        {
            _S489 = _S482;
        }
        else
        {
            _S489 = _S486 == u32(1);
        }
        var _S490 : bool = _S489 != refracted_1;
        if(_S490)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S491 : u32;
        if(_S486 == u32(4))
        {
            _S491 = u32(2);
        }
        else
        {
            _S491 = _S486;
        }
        var _S492 : bool = _S491 != half_of_0;
        var half_of_1 : u32;
        if(_S492)
        {
            var _S493 : bool = _S491 == u32(0);
            if(_S493)
            {
                var _S494 : vec3<f32> = sampledHalf(in_dir_4, n_7, material_13, random_state_5, _S475);
                ggx_n_1 = _S494;
            }
            else
            {
                var _S495 : bool = _S491 == u32(1);
                if(_S495)
                {
                    var _S496 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S496;
                }
                else
                {
                    var _S497 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S497;
                }
            }
            var _S498 : vec3<f32> = ((-(in_dir_4)));
            var _S499 : BSDFLobes = bsdfLobes(in_dir_4, _S498, _S474, ggx_n_1, material_13, eta_i_8, eta_o_8, _S475, _S479);
            lobe_terms_0 = _S499;
            var _S500 : f32 = translucentShare(material_13);
            lobe_terms_0.translucent_share = _S500;
            half_of_1 = _S491;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S486)
        {
        case u32(0):
            {
                var _S501 : f32 = diffusePDF(_S476, 0.0f, abs(_S472), _S478, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S501;
                var _S502 : vec3<f32> = diffuseBSDF(out_dir_2, _S474, _S478, material_13, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S502;
            }
        case u32(1):
            {
                var _S503 : f32 = refractPDF(_S476, dot(out_dir_2, ggx_n_1), abs(_S472), _S478, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S503;
                var _S504 : vec3<f32> = refractBSDF(out_dir_2, _S474, _S478, material_13, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S504;
            }
        case u32(4):
            {
                var _S505 : f32 = sheenVelvetPDF(_S476, 0.0f, abs(_S472), _S478, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S505;
                var _S506 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S474, _S478, material_13, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S506;
            }
        default :
            {
                var _S507 : f32 = reflectPDF(_S476, 0.0f, abs(_S472), _S478, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S507;
                var _S508 : vec3<f32> = reflectBSDF(out_dir_2, _S474, _S478, material_13, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S508;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S484;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S509 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S509)
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
    var _S510 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(4)>;
    var pdfs_1 : array<f32, i32(4)>;
    var _S511 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S510, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S512 : bool = !competing_0;
    var _S513 : bool;
    if(_S512)
    {
        _S513 = true;
    }
    else
    {
        _S513 = (light_0.density) == 0.0f;
    }
    if(_S513)
    {
        return _S511 * light_0.radiance;
    }
    var _S514 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S514;
    loop
    {
        if(i_4 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S515 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S515)
        {
            var _S516 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S516 * _S516)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S517 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S518 : vec2<u32> = _S517 - vec2<u32>(u32(1), u32(0));
    var _S519 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S520 : vec2<u32> = min(vec2<u32>(_S519 * vec2<f32>(_S518)), _S518 - vec2<u32>(u32(1)));
    var _S521 : vec4<f32> = (textureLoad(environment_cdf, (_S520), 0));
    var _S522 : f32 = _S521.y;
    var _S523 : u32 = _S518.x;
    var _S524 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S523, _S520.y)), 0));
    var _S525 : f32 = _S522 * _S524.y;
    return _S525 * f32(_S523 * _S518.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_2 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var _S526 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    var _S527 : vec3<f32> = BSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S526, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S528 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_3 : vec3<f32> = _S528;
    loop
    {
        if(i_6 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S529 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S529)
        {
            var _S530 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S530;
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
    var _S531 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S531;
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
    var _S532 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S532;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S533 : u32 = (low_0 + high_0) / u32(2);
        var _S534 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S533)), 0));
        var _S535 : bool = (_S534.x) > u_0;
        if(_S535)
        {
            high_0 = _S533;
        }
        else
        {
            var _S536 : u32 = _S533 + u32(1);
            low_0 = _S536;
        }
    }
    return low_0;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S537 : SkySample;
    _S537.dir = dir_7;
    _S537.radiance = radiance_2;
    _S537.color = color_2;
    _S537.random_state = random_state_9;
    return _S537;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S538 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S539 : bool = is_inside_3 != _S538;
    var _S540 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S541 : vec3<f32> = select(surface_3.smooth_n, _S540, _S539);
    var _S542 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S541, dir_8);
    var _S543 : vec3<f32> = (env_map_sample((dir_8)));
    var _S544 : vec3<f32> = (shadowTransmittance((_S542), (4.294967296e+09f)));
    return _S543 * _S544;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S545 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S546 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S547 : vec2<u32> = _S545 - _S546;
    var _S548 : Random = pcg(init_random_state_1);
    var _S549 : Random = pcg(_S548.state);
    var _S550 : Random = pcg(_S549.state);
    var _S551 : Random = pcg(_S550.state);
    var _S552 : u32 = _S547.x;
    var _S553 : u32 = searchCDF_0(vec2<u32>(_S552, u32(0)), vec2<u32>(u32(0), u32(1)), _S547.y, _S548.value);
    var _S554 : u32 = searchCDF_0(vec2<u32>(u32(0), _S553), _S546, _S552, _S549.value);
    var _S555 : vec2<f32> = (vec2<f32>(f32(_S554), f32(_S553)) + vec2<f32>(_S550.value, _S551.value)) / vec2<f32>(_S547) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S556 : f32 = _S555.y;
    var _S557 : f32 = sin(_S556);
    var _S558 : f32 = _S555.x;
    var _S559 : vec3<f32> = vec3<f32>(_S557 * cos(_S558), cos(_S556), _S557 * sin(_S558));
    var _S560 : f32 = environmentPdf_0(_S559);
    var _S561 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S559, surface_4, eta_2, is_inside_4, _S560, lobe_state_0);
    var _S562 : bool = !(_S560 > 0.0f);
    var _S563 : bool;
    if(_S562)
    {
        _S563 = true;
    }
    else
    {
        _S563 = (all((_S561 == vec3<f32>(0.0f))));
    }
    if(_S563)
    {
        var _S564 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S559, _S564, _S564, _S551.state);
    }
    var _S565 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S559);
    return SkySample_x24init_0(_S559, _S565, _S561 * _S565, _S551.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S566 : vec3<f32> = a_5 / b_1;
    var _S567 : vec3<f32> = vec3<f32>(0.0f);
    var _S568 : vec3<bool> = b_1 == _S567;
    var _S569 : vec3<f32> = select(_S566, _S567, _S568);
    return _S569;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_5 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S570 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S571 : u32 = (insertBits((_S570), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S571;
    candidate_0.f = f_5;
    return candidate_0;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S572 : f32 = rgb_to_greyscale(weight_0);
    var _S573 : bool = _S572 > 0.0f;
    var _S574 : bool;
    if(_S573)
    {
        _S574 = _S572 < 3.00000000549775576e+38f;
    }
    else
    {
        _S574 = false;
    }
    var _S575 : bool = !_S574;
    if(_S575)
    {
        return;
    }
    var _S576 : f32 = (*sel_0).w_sum + _S572;
    (*sel_0).w_sum = _S576;
    var _S577 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S577;
    var _S578 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S578.state;
    var _S579 : bool = (_S578.value * (*sel_0).w_sum) <= _S572;
    if(_S579)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S580 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S581 : bool = (_S580.x) > u32(1);
    var _S582 : bool;
    if(_S581)
    {
        var _S583 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S582 = (_S583.y) > u32(1);
    }
    else
    {
        _S582 = false;
    }
    return _S582;
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
    var _S584 : SampleBSDF;
    _S584.unit_direction = unit_direction_1;
    _S584.throughput = throughput_0;
    _S584.random_state = random_state_10;
    _S584.refracted = refracted_3;
    _S584.lobe = lobe_1;
    _S584.pdf = pdf_4;
    return _S584;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S585 : vec3<f32> = vec3<f32>(1.0f);
    var _S586 : SampleBSDF = SampleBSDF_x24init_0(_S585, _S585, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S586;
    var _S587 : Random = pcg(random_state_11);
    var _S588 : Random = pcg(_S587.state);
    sample_1.random_state = _S588.state;
    var _S589 : f32 = _S587.value;
    var _S590 : f32 = sqrt(max(0.0f, 1.0f - _S589 * _S589));
    var _S591 : f32 = 6.28318548202514648f * _S588.value;
    var _S592 : vec3<f32> = tangentToWorld(vec3<f32>(_S590 * cos(_S591), _S587.value, _S590 * sin(_S591)), n_i_8);
    sample_1.unit_direction = _S592;
    sample_1.lobe = u32(4);
    var _S593 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S593;
    var _S594 : f32 = sheenVelvetPDF(_S587.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S594;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S595 : f32 = sqrt(random_1_0);
    var _S596 : f32 = 6.28318548202514648f * random_2_0;
    var _S597 : f32 = _S595 * cos(_S596);
    var _S598 : f32 = _S595 * sin(_S596);
    var _S599 : f32 = sqrt(max(0.0f, 1.0f - _S597 * _S597 - _S598 * _S598));
    return vec3<f32>(_S597, _S599, _S598);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S600 : vec3<f32> = vec3<f32>(1.0f);
    var _S601 : SampleBSDF = SampleBSDF_x24init_0(_S600, _S600, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S601;
    var _S602 : Random = pcg(random_state_12);
    var _S603 : Random = pcg(_S602.state);
    sample_2.random_state = _S603.state;
    var _S604 : vec3<f32> = sampleCosWeightedHemisphere(_S602.value, _S603.value);
    var _S605 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S606 : f32 = _S604.y;
    var _S607 : f32 = - _S606;
    var _S608 : f32 = select(_S606, _S607, _S605);
    var _S609 : vec3<f32> = tangentToWorld(vec3<f32>(_S604.x, _S608, _S604.z), n_i_9);
    sample_2.unit_direction = _S609;
    sample_2.refracted = _S605;
    sample_2.lobe = u32(0);
    var _S610 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S610;
    var _S611 : f32 = diffusePDF(_S608, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S611;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S612 : vec3<f32> = vec3<f32>(1.0f);
    var _S613 : SampleBSDF = SampleBSDF_x24init_0(_S612, _S612, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S613;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S614 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S614;
    var _S615 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S615;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S616 : vec3<f32> = vec3<f32>(1.0f);
    var _S617 : SampleBSDF = SampleBSDF_x24init_0(_S616, _S616, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S617;
    var _S618 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S618;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S619 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S619;
    var _S620 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S620;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S621 : vec3<f32> = ((-(in_dir_9)));
    var _S622 : f32 = dot(n_8, _S621);
    var _S623 : f32 = (sign((_S622)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S623);
    var _S624 : f32 = abs(_S622);
    var _S625 : f32 = material_19.roughness;
    var _S626 : f32 = _S625 * _S625;
    var _S627 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S628 : SheenProfile = sheenProfile(_S621, n_i_12, material_19);
    var _S629 : vec3<f32> = sampleHalfVector(_S621, n_i_12, _S626, _S627, &(random_state_15));
    var _S630 : BSDFLobes = bsdfLobes(in_dir_9, _S621, n_i_12, _S629, material_19, eta_i_14, eta_o_14, _S627, _S628);
    var lobes_13 : BSDFLobes = _S630;
    var _S631 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S631;
    var _S632 : Random = pcg(random_state_15);
    random_state_15 = _S632.state;
    var _S633 : bool = (_S632.value) < (lobes_13.p_sheen_velvet);
    if(_S633)
    {
        var _S634 : SampleBSDF = sheenVelvetSample(n_i_12, _S624, _S626, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S634;
    }
    var _S635 : f32 = _S632.value - lobes_13.p_sheen_velvet;
    var _S636 : bool = _S635 < (lobes_13.p_diffuse);
    if(_S636)
    {
        var _S637 : SampleBSDF = diffuseSample(_S635, n_i_12, _S624, _S626, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S637;
    }
    var _S638 : bool = _S635 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S638)
    {
        var _S639 : SampleBSDF = refractSample(_S629, n_i_12, _S624, _S626, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S639;
    }
    var _S640 : SampleBSDF = reflectSample(in_dir_9, _S629, n_i_12, _S624, _S626, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S640;
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S641 : bool = pdf_5 <= 0.0f;
    var _S642 : bool;
    if(_S641)
    {
        _S642 = true;
    }
    else
    {
        var _S643 : bool = environmentMapped_0();
        _S642 = !_S643;
    }
    if(_S642)
    {
        return 1.0f;
    }
    var _S644 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S644);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S645 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S645.x, max(_S645.y, _S645.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S646 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S647 : bool = (_S646.x) > u32(1);
    var _S648 : bool;
    if(_S647)
    {
        var _S649 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S648 = (_S649.y) > u32(1);
    }
    else
    {
        _S648 = false;
    }
    if(_S648)
    {
        var _S650 : vec3<f32> = (env_map_sample((dir_10)));
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
            var _S698 : bool = neeDecision(_S693.material, _S695, _S696.x, _S696.y);
            _S697 = _S698;
        }
        else
        {
            _S697 = false;
        }
        var _S699 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S700 : vec3<f32> = _S693.material.emissive * vec3<f32>(max(_S699, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S675)
        {
            var _S701 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S701;
        }
        else
        {
            emission_0 = _S700;
        }
        var _S702 : bool = !replay_0;
        var _S703 : bool;
        if(_S702)
        {
            _S703 = true;
        }
        else
        {
            _S703 = b_2 >= _S667;
        }
        var _S704 : bool;
        if(_S703)
        {
            var _S705 : f32 = rgb_to_greyscale(emission_0);
            _S704 = _S705 > 0.0f;
        }
        else
        {
            _S704 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S704)
        {
            var _S706 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S706);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S707 : bool;
        if(replay_0)
        {
            _S707 = _S656 == u32(1);
        }
        else
        {
            _S707 = false;
        }
        var _S708 : bool;
        if(_S707)
        {
            _S708 = b_2 > _S655;
        }
        else
        {
            _S708 = false;
        }
        var _S709 : bool;
        if(_S708)
        {
            _S709 = b_2 == _S654;
        }
        else
        {
            _S709 = false;
        }
        var _S710 : bool;
        if(_S709)
        {
            var _S711 : bool = _S657 == u32(1);
            if(_S711)
            {
                _S710 = true;
            }
            else
            {
                _S710 = _S657 == u32(2);
            }
        }
        else
        {
            _S710 = false;
        }
        if(_S710)
        {
            var _S712 : bool = _S675 != (_S657 == u32(2));
            if(_S712)
            {
                return _S653;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S713 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S714 : bool = _S713 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S715 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S716 : u32 = (insertBits((_S715), (u32(1)), (u32(10)), (u32(2))));
        var _S717 : u32 = (insertBits((_S716), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S718 : bool = prev_0.inside;
        var _S719 : u32 = select(u32(0), u32(1), _S718);
        var _S720 : u32 = (insertBits((_S717), (_S719), (u32(22)), (u32(1))));
        here_0.path = _S720;
        var _S721 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S721;
        var _S722 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S722;
        var _S723 : bool;
        if(replay_0)
        {
            _S723 = _S656 == u32(1);
        }
        else
        {
            _S723 = false;
        }
        var _S724 : bool;
        if(_S723)
        {
            _S724 = b_2 == _S655;
        }
        else
        {
            _S724 = false;
        }
        var _S725 : bool = b_2 == _S667;
        var _S726 : bool;
        if(_S725)
        {
            var _S727 : bool = !scatter_0;
            if(_S727)
            {
                _S726 = true;
            }
            else
            {
                var _S728 : bool = _S656 != u32(1);
                if(_S728)
                {
                    _S726 = _S656 != u32(3);
                }
                else
                {
                    _S726 = false;
                }
            }
        }
        else
        {
            _S726 = false;
        }
        var _S729 : bool;
        if(_S726)
        {
            _S729 = _S656 == u32(2);
        }
        else
        {
            _S729 = false;
        }
        var _S730 : bool;
        if(_S729)
        {
            _S730 = !_S692;
        }
        else
        {
            _S730 = false;
        }
        var _S731 : bool;
        if(_S730)
        {
            _S731 = _S657 != u32(4);
        }
        else
        {
            _S731 = false;
        }
        var _S732 : bool = _S655 == _S654;
        var _S733 : bool;
        if(_S732)
        {
            _S733 = _S657 == u32(0);
        }
        else
        {
            _S733 = false;
        }
        var _S734 : bool;
        if(_S733)
        {
            _S734 = (hit_2.instance_index) == (_S668.instance_index);
        }
        else
        {
            _S734 = false;
        }
        var _S735 : bool;
        if(_S734)
        {
            _S735 = (hit_2.triangle_index) == (_S668.triangle_index);
        }
        else
        {
            _S735 = false;
        }
        var _S736 : bool;
        if(_S735)
        {
            _S736 = _S692;
        }
        else
        {
            _S736 = false;
        }
        var _S737 : bool = select(_S731, _S736, _S724);
        var _S738 : bool;
        if(_S697)
        {
            _S738 = select(scatter_0, _S737, replay_0);
        }
        else
        {
            _S738 = false;
        }
        var _S739 : TreeSample = TreeSample_x24init_0(_S652, _S652, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S738)
        {
            var _S740 : Surface = surface_5;
            var _S741 : bool = isTranslucent_0(_S693.material);
            var _S742 : u32 = stream(r_4.seed, b_2 + u32(64));
            var _S743 : TreeSample = sampleLightTree_0(ray_2.origin, _S694.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S741, _S742);
            var _S744 : bool = (any(((_S743.radiance) != _S652)));
            if(_S744)
            {
                var _S745 : f32 = _S696.x;
                var _S746 : f32 = _S696.y;
                var _S747 : u32 = (uniforms_uint.max_bounces);
                var _S748 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S743, _S694.smooth_n, _S740.geometry_n, _S693.material, _S745, _S746, b_2 < _S747, surface_5.random_state);
                lit_0 = _S748;
            }
            else
            {
                lit_0 = _S652;
            }
            light_1 = _S743;
        }
        else
        {
            light_1 = _S739;
            lit_0 = _S652;
        }
        var _S749 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S750 : bool;
        var _S751 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S724)
        {
            var _S752 : bool = !_S692;
            if(_S752)
            {
                return _S653;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S732)
            {
                _S749 = _S657 == u32(1);
            }
            else
            {
                _S749 = false;
            }
            if(_S749)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S732)
            {
                wrong_side_0 = _S657 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S753 : bool = !_S697;
                if(_S753)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S754 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S754 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S653;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S732)
            {
                refracted_4 = _S657 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S755 : bool = !_S697;
                if(_S755)
                {
                    return _S653;
                }
                var _S756 : f32 = environmentPdf_0(r_4.dir);
                var _S757 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S696, is_inside_5, _S756, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S757 * r_4.radiance / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S758 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S759 : bool = _S697 != (_S758 == u32(1));
            if(_S759)
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
                _S749 = _S725;
            }
            else
            {
                _S749 = false;
            }
            if(_S749)
            {
                var _S760 : bool = !scatter_0;
                if(_S760)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S761 : bool = _S656 != u32(1);
                    if(_S761)
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
                var _S762 : bool = _S656 == u32(2);
                if(_S762)
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
                    var _S763 : u32 = stream(r_4.seed, b_2 + u32(256));
                    var _S764 : SkySample = sampleSky_0(ray_2, surface_5, _S696, is_inside_5, _S763, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S764.color, 1.0f);
                }
                if(_S762)
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
                    var _S765 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S766 : bool = !(_S765 > 0.0f);
                    if(_S766)
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
                if(_S702)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S767 : bool = b_2 > u32(0);
                    if(_S767)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S714)
                        {
                            var _S768 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S768;
                        }
                        else
                        {
                            if(_S692)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S769 : vec3<f32> = throughput_3 * emission_1;
                        var _S770 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S769);
                        offer(&((*sel_1)), _S770, _S769 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S697)
                    {
                        var _S771 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S714)
                        {
                            var _S772 : vec3<f32> = safeDivide(_S771, chain_throughput_0);
                            candidate_3.radiance = _S772;
                        }
                        else
                        {
                            if(_S692)
                            {
                                candidate_3 = here_0;
                                var _S773 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S773;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S774 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S775 : u32 = (insertBits((_S774), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S775;
                            }
                        }
                        var _S776 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S771);
                        offer(&((*sel_1)), _S776, _S771 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S697)
                    {
                        var _S777 : bool = environmentMapped_0();
                        _S750 = _S777;
                    }
                    else
                    {
                        _S750 = false;
                    }
                    if(_S750)
                    {
                        var _S778 : u32 = (uniforms_uint.max_bounces);
                        _S751 = b_2 < _S778;
                    }
                    else
                    {
                        _S751 = false;
                    }
                    if(_S751)
                    {
                        var _S779 : u32 = stream(r_4.seed, b_2 + u32(256));
                        var _S780 : SkySample = sampleSky_0(ray_2, surface_5, _S696, is_inside_5, _S779, surface_5.random_state);
                        var _S781 : vec3<f32> = throughput_3 * _S780.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S714)
                        {
                            var _S782 : vec3<f32> = safeDivide(_S781, chain_throughput_0);
                            candidate_4.radiance = _S782;
                        }
                        else
                        {
                            if(_S692)
                            {
                                candidate_4 = here_0;
                                var _S783 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S783;
                                candidate_4.dir = _S780.dir;
                                candidate_4.radiance = _S780.radiance;
                            }
                            else
                            {
                                var _S784 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S785 : u32 = (insertBits((_S784), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S785;
                            }
                        }
                        var _S786 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S781);
                        offer(&((*sel_1)), _S786, _S781 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S787 : bool;
        var _S788 : bool;
        var _S789 : bool;
        var _S790 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S749 = _S725;
            }
            else
            {
                _S749 = false;
            }
            var _S791 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S792 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S793 : u32 = select(_S791, _S792, _S724);
            var refracted_5 : bool = _S793 == u32(1);
            var _S794 : SampleBSDF = SampleBSDF_x24init_0(_S652, _S652, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S794;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S749)
            {
                var _S795 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S796 : bool = is_inside_5 != (_S795 == u32(1));
                if(_S796)
                {
                    return _S653;
                }
                var _S797 : bool = _S656 == u32(1);
                if(_S797)
                {
                    var _S798 : vec3<f32> = (hitPosition((_S668)));
                    dir_11 = _S798;
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
                    var _S799 : bool = isTranslucent_0(_S693.material);
                    if(_S799)
                    {
                        wrong_side_0 = _S793 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S800 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S801 : vec3<f32> = select(r_4.dir, _S800, _S797);
                        refracted_4 = (dot(_S694.smooth_n, _S801) * _S695) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S797)
                {
                    var _S802 : vec3<f32> = ray_2.origin;
                    var _S803 : Surface = surface_5;
                    var _S804 : vec3<f32> = (vec3<f32>(0) - _S694.smooth_n);
                    var _S805 : bool = is_inside_5 != refracted_4;
                    var _S806 : vec3<f32> = select(_S694.smooth_n, _S804, _S805);
                    var _S807 : vec3<f32> = (normalize((dir_11 - (_S802 + vec3<f32>(_S803.geometry_offset) * _S806))));
                    reconnection_1 = _S807;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S808 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S808)
                {
                    return _S653;
                }
                var _S809 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S793;
                wrong_side_0 = false;
                reconnection_1 = _S809;
            }
            else
            {
                var _S810 : bool = !_S724;
                if(_S810)
                {
                    var _S811 : f32 = _S696.x;
                    var _S812 : f32 = _S696.y;
                    var _S813 : vec2<f32> = vec2<f32>(0.0f);
                    var _S814 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S694.smooth_n, _S693.material, _S811, _S812, surface_5.random_state, _S813);
                    var bsdf_sampled_0 : SampleBSDF = _S814;
                    var _S815 : Surface = surface_5;
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
                        var _S816 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S815.geometry_n, _S693.material, _S811, _S812, bsdf_sampled_0.random_state, _S813);
                        bsdf_sampled_0.unit_direction = _S816.unit_direction;
                        bsdf_sampled_0.refracted = _S816.refracted;
                        bsdf_sampled_0.throughput = _S816.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S817 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S815.geometry_n))) * _S815.geometry_n;
                            bsdf_sampled_0.unit_direction = _S817;
                        }
                    }
                    var _S818 : u32 = bsdf_sampled_0.lobe;
                    var _S819 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S820 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S821 : f32 = bsdf_sampled_0.pdf;
                    var _S822 : f32 = select(_S821, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S822;
                    dir_11 = _S819;
                    lobe_index_0 = _S818;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S820;
                }
                else
                {
                    dir_11 = r_4.dir;
                    lobe_index_0 = _S793;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S749)
            {
                _S750 = true;
            }
            else
            {
                _S750 = _S724;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S750)
            {
                var _S823 : vec3<f32> = ray_2.unit_direction;
                var _S824 : f32 = (sign((_S695)));
                var _S825 : vec3<f32> = _S694.smooth_n * vec3<f32>(_S824);
                var _S826 : f32 = dot(_S825, dir_11);
                var _S827 : f32 = _S693.material.roughness;
                var _S828 : f32 = _S827 * _S827;
                var _S829 : AnisotropicFrame = anisotropicFrame(_S693.material, _S825);
                var _S830 : vec3<f32> = ((-(_S823)));
                var _S831 : SheenProfile = sheenProfile(_S830, _S825, _S693.material);
                var _S832 : vec3<f32> = reflectedHalf(_S823, dir_11);
                var _S833 : bool = lobe_index_0 == u32(1);
                if(_S833)
                {
                    var _S834 : vec3<f32> = refractedHalf(_S823, dir_11, _S694.smooth_n, _S696.x, _S696.y);
                    throughput_6 = _S834;
                }
                else
                {
                    throughput_6 = _S832;
                }
                var _S835 : bool = lobe_index_0 == u32(0);
                if(_S835)
                {
                    var _S836 : vec3<f32> = sampledHalf(_S823, _S694.smooth_n, _S693.material, surface_5.random_state, _S829);
                    throughput_7 = _S836;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S837 : vec3<f32> = ((-(_S823)));
                var _S838 : f32 = _S696.x;
                var _S839 : f32 = _S696.y;
                var _S840 : BSDFLobes = bsdfLobes(_S823, _S837, _S825, throughput_7, _S693.material, _S838, _S839, _S829, _S831);
                var lobe_terms_1 : BSDFLobes = _S840;
                var _S841 : f32 = translucentShare(_S693.material);
                lobe_terms_1.translucent_share = _S841;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S842 : f32 = diffusePDF(_S826, 0.0f, abs(_S695), _S828, lobe_terms_1, _S838, _S839);
                        var _S843 : vec3<f32> = diffuseBSDF(dir_11, _S825, _S828, _S693.material, lobe_terms_1);
                        density_5 = _S842;
                        chain_throughput_1 = _S843;
                    }
                case u32(1):
                    {
                        var _S844 : f32 = refractPDF(_S826, dot(dir_11, throughput_7), abs(_S695), _S828, lobe_terms_1, _S838, _S839);
                        var _S845 : vec3<f32> = refractBSDF(dir_11, _S825, _S828, _S693.material, lobe_terms_1);
                        density_5 = _S844;
                        chain_throughput_1 = _S845;
                    }
                case u32(4):
                    {
                        var _S846 : f32 = sheenVelvetPDF(_S826, 0.0f, abs(_S695), _S828, lobe_terms_1, _S838, _S839);
                        var _S847 : vec3<f32> = sheenVelvetBSDF(dir_11, _S825, _S828, _S693.material, lobe_terms_1);
                        density_5 = _S846;
                        chain_throughput_1 = _S847;
                    }
                default :
                    {
                        var _S848 : f32 = reflectPDF(_S826, 0.0f, abs(_S695), _S828, lobe_terms_1, _S838, _S839);
                        var _S849 : vec3<f32> = reflectBSDF(dir_11, _S825, _S828, _S693.material, lobe_terms_1);
                        density_5 = _S848;
                        chain_throughput_1 = _S849;
                    }
                }
                var _S850 : bool = density_5 > 0.0f;
                if(_S850)
                {
                    var _S851 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, surface_5.random_state, _S833, lobe_index_0, density_5);
                    lobe_2 = _S851;
                }
            }
            var _S852 : bool = lobe_index_0 == u32(0);
            if(_S852)
            {
                _S751 = true;
            }
            else
            {
                _S751 = lobe_index_0 == u32(4);
            }
            var _S853 : bool = !_S751;
            if(_S853)
            {
                var _S854 : bool = (_S693.material.roughness) == 0.0f;
                if(_S854)
                {
                    _S787 = true;
                }
                else
                {
                    var _S855 : bool = lobe_index_0 == u32(1);
                    if(_S855)
                    {
                        _S787 = (_S696.x) == (_S696.y);
                    }
                    else
                    {
                        _S787 = false;
                    }
                }
            }
            else
            {
                _S787 = false;
            }
            var _S856 : bool = isTranslucent_0(_S693.material);
            if(_S856)
            {
                _S788 = _S852;
            }
            else
            {
                _S788 = false;
            }
            if(_S788)
            {
                _S789 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S789 = false;
            }
            if(_S697)
            {
                _S790 = !_S787;
            }
            else
            {
                _S790 = false;
            }
            var _S857 : bool;
            if(_S790)
            {
                _S857 = !wrong_side_0;
            }
            else
            {
                _S857 = false;
            }
            var _S858 : bool;
            if(_S857)
            {
                var _S859 : f32 = lobe_2.pdf;
                var _S860 : vec3<f32> = ray_2.origin;
                var _S861 : bool = isTranslucent_0(_S693.material);
                var _S862 : vec3<f32> = select(_S694.smooth_n, _S652, _S861);
                var _S863 : vec3<f32> = ray_2.origin;
                var _S864 : Surface = surface_5;
                var _S865 : vec3<f32> = (vec3<f32>(0) - _S694.smooth_n);
                var _S866 : vec3<f32> = select(_S694.smooth_n, _S865, _S789);
                var _S867 : NEEVertex = NEEVertex_x24init_0(false, _S859, _S860, _S862, _S863 + vec3<f32>(_S864.geometry_offset) * _S866);
                nee_vertex_0 = _S867;
            }
            else
            {
                var _S868 : bool = lobe_index_0 != u32(1);
                if(_S868)
                {
                    _S858 = true;
                }
                else
                {
                    _S858 = (_S696.x) != (_S696.y);
                }
                if(_S858)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S869 : bool = (lobe_2.pdf) > 0.0f;
            if(_S869)
            {
                if(_S751)
                {
                    _S858 = true;
                }
                else
                {
                    _S858 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S858 = false;
            }
            var _S870 : bool = (lobe_2.pdf) > 0.0f;
            var _S871 : bool;
            if(_S870)
            {
                if(_S751)
                {
                    _S871 = true;
                }
                else
                {
                    _S871 = (_S693.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S871 = false;
            }
            var _S872 : bool;
            if(_S724)
            {
                var _S873 : bool = !_S858;
                if(_S873)
                {
                    return _S653;
                }
                var _S874 : bool = _S657 != u32(1);
                if(_S874)
                {
                    _S872 = _S657 != u32(2);
                }
                else
                {
                    _S872 = false;
                }
                if(_S872)
                {
                    var _S875 : f32 = lobe_2.pdf;
                    var _S876 : f32 = select(0.0f, _S875, _S697);
                    var _S877 : f32 = escapeWeight_0(_S876, r_4.dir);
                    if(_S732)
                    {
                        is_inside_5 = _S663;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S878 : f32 = select(1.0f, _S877, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S878) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S879 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S880 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S879;
                density_5 = _S880;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S872 = b_2 <= _S667;
            }
            else
            {
                _S872 = false;
            }
            var _S881 : bool;
            if(_S872)
            {
                _S881 = _S692;
            }
            else
            {
                _S881 = false;
            }
            var _S882 : bool;
            if(_S881)
            {
                _S882 = _S858;
            }
            else
            {
                _S882 = false;
            }
            var _S883 : bool;
            if(_S882)
            {
                _S883 = true;
            }
            else
            {
                if(_S749)
                {
                    _S883 = !_S871;
                }
                else
                {
                    _S883 = false;
                }
            }
            if(_S883)
            {
                return _S653;
            }
            if(_S749)
            {
                var _S884 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S885 : f32 = lobe_2.pdf;
                throughput_7 = _S884;
                survival_probability_0 = _S885;
            }
            else
            {
                var _S886 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S652);
                throughput_7 = _S886;
                survival_probability_0 = density_5;
            }
            var _S887 : bool;
            if(_S702)
            {
                _S887 = !_S714;
            }
            else
            {
                _S887 = false;
            }
            var _S888 : bool;
            if(_S887)
            {
                _S888 = _S692;
            }
            else
            {
                _S888 = false;
            }
            var _S889 : bool;
            if(_S888)
            {
                _S889 = _S858;
            }
            else
            {
                _S889 = false;
            }
            if(_S889)
            {
                chain_0 = here_0;
                var _S890 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S891 : u32 = select(u32(0), u32(1), _S697);
                var _S892 : u32 = (insertBits((_S890), (_S891), (u32(21)), (u32(1))));
                chain_0.path = _S892;
                var _S893 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S893;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S894 : Vertex = Vertex_x24init_0(_S871, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S894;
            var _S895 : f32 = lobe_2.pdf;
            var _S896 : bool = lobe_index_0 == u32(1);
            var _S897 : bool;
            if(_S896)
            {
                _S897 = (_S696.x) == (_S696.y);
            }
            else
            {
                _S897 = false;
            }
            var _S898 : f32 = select(_S895, sky_pdf_0, _S897);
            var _S899 : bool;
            if(refracted_4)
            {
                _S899 = !_S789;
            }
            else
            {
                _S899 = false;
            }
            var is_inside_6 : bool;
            if(_S899)
            {
                var _S900 : bool = !is_inside_5;
                is_inside_6 = _S900;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S901 : Surface = surface_5;
            var _S902 : vec3<f32> = (vec3<f32>(0) - _S694.smooth_n);
            var _S903 : bool = is_inside_6 != _S789;
            var _S904 : vec3<f32> = select(_S694.smooth_n, _S902, _S903);
            var _S905 : vec3<f32> = ray_2.origin + vec3<f32>(_S901.geometry_offset) * _S904;
            ray_2.origin = _S905;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S898;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S702)
        {
            if(_S675)
            {
                var _S906 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S907 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S908 : bool = _S907 == u32(1);
                if(_S908)
                {
                    var _S909 : vec3<f32> = safeDivide(_S906, chain_throughput_0);
                    candidate_5.radiance = _S909;
                }
                var _S910 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S906);
                offer(&((*sel_1)), _S910, _S906 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S675)
            {
                _S749 = true;
            }
            else
            {
                _S749 = scatter_0;
            }
            if(_S749)
            {
                var _S911 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S911;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S912 : u32 = stream(r_4.seed, b_2 + u32(128));
            var _S913 : Random = pcg(_S912);
            var _S914 : bool = survival_probability_0 < (_S913.value);
            if(_S914)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S915 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S915;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S916 : f32 = density_5 * survival_probability_0;
            density_2 = _S916;
        }
        else
        {
            density_2 = density_5;
        }
        var _S917 : Ray = ray_2;
        var _S918 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S749 = _S725;
        }
        else
        {
            _S749 = false;
        }
        if(_S749)
        {
            wrong_side_0 = _S656 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S919 : f32 = select(4.294967296e+09f, _S918, wrong_side_0);
        var _S920 : Hit = (traverseInstanceBVH((_S917), (_S681), (_S919)));
        hit_2 = _S920;
        if(replay_0)
        {
            refracted_4 = _S725;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S750 = _S656 == u32(1);
        }
        else
        {
            _S750 = false;
        }
        if(_S750)
        {
            _S751 = (hit_2.instance_index) == (_S668.instance_index);
        }
        else
        {
            _S751 = false;
        }
        if(_S751)
        {
            _S787 = (hit_2.triangle_index) == (_S668.triangle_index);
        }
        else
        {
            _S787 = false;
        }
        if(_S787)
        {
            hit_2.uv = _S668.uv;
            var _S921 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S921;
        }
        if(replay_0)
        {
            _S788 = _S725;
        }
        else
        {
            _S788 = false;
        }
        if(_S788)
        {
            _S789 = _S656 == u32(3);
        }
        else
        {
            _S789 = false;
        }
        if(_S789)
        {
            _S790 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S790 = false;
        }
        if(_S790)
        {
            return _S653;
        }
        var _S922 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S922)
        {
            var _S923 : bool = !nee_vertex_0.none;
            var _S924 : f32 = select(0.0f, sky_pdf_0, _S923);
            var _S925 : f32 = escapeWeight_0(_S924, ray_2.unit_direction);
            var _S926 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S927 : vec3<f32> = throughput_2 * _S926;
            if(replay_0)
            {
                if(_S725)
                {
                    is_inside_5 = _S656 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S927 * vec3<f32>(_S925) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
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
                    return Shift_x24init_0(_S927 * vec3<f32>(_S925), 1.0f);
                }
                return _S653;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S928 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S929 : bool = _S928 == u32(1);
            if(_S929)
            {
                var _S930 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S931 : bool = _S930 == b_2;
                var _S932 : f32 = select(_S925, 1.0f, _S931);
                var _S933 : vec3<f32> = safeDivide(_S927 * vec3<f32>(_S932), chain_throughput_0);
                candidate_6.radiance = _S933;
            }
            else
            {
                var _S934 : bool = prev_0.rough;
                if(_S934)
                {
                    var _S935 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S936 : u32 = (insertBits((_S935), (u32(3)), (u32(10)), (u32(2))));
                    var _S937 : u32 = (insertBits((_S936), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S938 : bool = prev_0.inside;
                    var _S939 : u32 = select(u32(0), u32(1), _S938);
                    var _S940 : u32 = (insertBits((_S937), (_S939), (u32(22)), (u32(1))));
                    candidate_6.path = _S940;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S941 : vec3<f32> = _S927 * vec3<f32>(_S925);
            var _S942 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S941);
            offer(&((*sel_1)), _S942, _S941 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S943 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S943;
        var _S944 : u32 = b_2 + u32(1);
        b_2 = _S944;
    }
    return _S653;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S945 : vec3<f32> = vec3<f32>(0.0f);
    var _S946 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S945, 0.0f, vec4<u32>(u32(0)), _S945, _S945), 0.0f, _S945, u32(0));
    var sel_2 : Selection = _S946;
    var _S947 : bool = (r_5.w) <= 0.0f;
    if(_S947)
    {
        return Shift_x24init_0(_S945, 0.0f);
    }
    var _S948 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S948;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S949 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S949;
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
        var _S950 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S951 : u32 = (_S950 + u32(63)) / u32(64);
        var _S952 : bool = group_0 < _S951;
        if(_S952)
        {
            var _S953 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S954 : bool = _S953 < _S950;
            if(_S954)
            {
                var _S955 : u32 = (queued_shifts[(u32(83) + start_4 + _S953)]);
                return _S955;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S951;
        var start_5 : u32 = start_4 + _S950;
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
    var _S956 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S957 : u32 = t_5;
        var _S958 : bool = (bins_1[t_5]) < u32(40);
        if(_S958)
        {
            var _S959 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S957]]), u32(1));
            slots_0[t_5] = _S959;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S960 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S960)
    {
        var _S961 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S962 : bool = _S961 > u32(0);
        if(_S962)
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
                var _S963 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S963;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S964 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S961)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S964;
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
        var _S965 : u32 = t_5;
        var _S966 : bool = (bins_1[t_5]) < u32(40);
        if(_S966)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S965]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S967 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S967)
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
            var _S968 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S968 + u32(63)) / u32(64);
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
    var _S969 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S970 : vec2<f32> = vec2<f32>(0.5f);
    var _S971 : vec2<f32> = _S969.xy / vec2<f32>(_S969.z) * _S970 + _S970;
    var _S972 : vec2<f32> = vec2<f32>(_S971.x, 1.0f - _S971.y);
    var _S973 : vec2<u32> = (uniforms_uint.render_size);
    return _S972 * vec2<f32>(_S973);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S974 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S975 : bool;
    if(_S974)
    {
        var _S976 : vec2<u32> = (uniforms_uint.render_size);
        _S975 = (all((q_0 < vec2<i32>(_S976))));
    }
    else
    {
        _S975 = false;
    }
    if(_S975)
    {
        var _S977 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S975 = (bitcast<f32>((_S977.w))) > 0.0f;
    }
    else
    {
        _S975 = false;
    }
    return _S975;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S978 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S979 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S980 : vec2<f32> = project_0(_S978, _S979, dom_3.x1);
    var _S981 : vec2<i32> = vec2<i32>(floor(_S980));
    var _S982 : bool = previousValid_0(_S981);
    var _S983 : bool = !_S982;
    if(_S983)
    {
        return vec2<i32>(i32(-1));
    }
    var _S984 : Domain = (previousDomain((_S981)));
    var _S985 : bool = (_S984.hit.instance_index) == (dom_3.hit.instance_index);
    var _S986 : bool;
    if(_S985)
    {
        var _S987 : f32 = distance(_S984.x1, dom_3.x1);
        var _S988 : f32 = dom_3.hit.distance * 8.0f;
        var _S989 : vec2<u32> = (uniforms_uint.render_size);
        _S986 = _S987 <= (_S988 / f32(_S989.x));
    }
    else
    {
        _S986 = false;
    }
    if(_S986)
    {
        return _S981;
    }
    var _S990 : vec2<f32> = vec2<f32>(p_9 + _S981) + vec2<f32>(1.0f);
    var _S991 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S992 : vec3<f32> = (uniforms_float.camera_position);
    var _S993 : vec2<f32> = project_0(_S991, _S992, _S984.x1);
    var _S994 : vec2<i32> = vec2<i32>(floor(_S990 - _S993));
    var _S995 : vec2<i32> = vec2<i32>(i32(-1));
    var _S996 : bool = previousValid_0(_S994);
    var _S997 : vec2<i32> = select(_S995, _S994, _S996);
    return _S997;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S998 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S999 : bool;
    if(_S998)
    {
        _S999 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S999 = false;
    }
    if(_S999)
    {
        _S999 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S999 = false;
    }
    if(_S999)
    {
        _S999 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S999 = false;
    }
    return _S999;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1000 : vec3<f32> = vec3<f32>(0.0f);
    var _S1001 : Domain = Domain_x24init_0(_S1000, _S1000, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1001;
    var _S1002 : bool = t_8 > u32(1);
    var _S1003 : bool;
    if(_S1002)
    {
        _S1003 = true;
    }
    else
    {
        var _S1004 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1003 = !_S1004;
    }
    if(_S1003)
    {
        return false;
    }
    var _S1005 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1006 : bool = (_S1005.x) < i32(0);
    if(_S1006)
    {
        return false;
    }
    var _S1007 : bool = t_8 == u32(0);
    if(_S1007)
    {
        var _S1008 : Reservoir = (loadReservoir(reservoir_prev, (_S1005)));
        var _S1009 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1008);
        (*job_2) = _S1009;
    }
    else
    {
        var _S1010 : Domain = (previousDomain((_S1005)));
        var _S1011 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1012 : ShiftJob = ShiftJob_x24init_0(_S1010, _S1011);
        (*job_2) = _S1012;
    }
    var _S1013 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1013)
    {
        if(_S1007)
        {
            _S1003 = true;
        }
        else
        {
            var _S1014 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1003 = !_S1014;
        }
    }
    else
    {
        _S1003 = false;
    }
    return _S1003;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1015 : ptr<function, array<u32, i32(3)>>)
{
    var _S1016 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S1017 : vec3<f32> = vec3<f32>(0.0f);
        var _S1018 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1017, _S1017, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1017, 0.0f, vec4<u32>(u32(0)), _S1017, _S1017));
        var job_3 : ShiftJob = _S1018;
        var _S1019 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1019)
        {
            var _S1020 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1020;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1015) = bins_2;
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
        var _S1021 : u32 = t_11;
        var _S1022 : bool = (bins_3[t_11]) < u32(40);
        if(_S1022)
        {
            var _S1023 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1021]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1024 : bool = local_invocation_index_2 < u32(40);
    if(_S1024)
    {
        var _S1025 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1026 : bool = _S1025 > u32(0);
        if(_S1026)
        {
            var _S1027 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1025)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1028 : vec2<u32> = global_invocation_id_1.xy;
    var _S1029 : vec2<i32> = vec2<i32>(_S1028 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1030 : vec2<i32> = _S1029 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1031 : bool = (all((_S1030 >= vec2<i32>(i32(0)))));
        var _S1032 : bool;
        if(_S1031)
        {
            var _S1033 : vec2<u32> = (uniforms_uint.render_size);
            _S1032 = (all((_S1030 < vec2<i32>(_S1033))));
        }
        else
        {
            _S1032 = false;
        }
        if(_S1032)
        {
            var _S1034 : vec4<u32> = (textureLoad(reservoir_prev, (_S1030), (u32(0)), 0));
            var _S1035 : u32 = _S1034.x;
            var _S1036 : bool = (bitcast<f32>((_S1034.z))) > 0.0f;
            var _S1037 : u32 = select(u32(0), _S1035, _S1036);
            seed_2 = _S1037;
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
    var _S1038 : u32 = local_invocation_id_0.y;
    var _S1039 : u32 = local_invocation_id_0.x;
    var _S1040 : u32 = duplication_seeds_0[(_S1038 + u32(8)) * u32(24) + _S1039 + u32(8)];
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
            var _S1041 : bool = (duplication_seeds_0[(_S1038 + seed_2) * u32(24) + _S1039 + x_1]) == _S1040;
            var _S1042 : u32 = select(u32(0), u32(1), _S1041);
            var count_2 : u32 = count_1 + _S1042;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1043 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1044 : bool = _S1040 != u32(0);
    var _S1045 : f32 = select(0.0f, _S1043, _S1044);
    textureStore(duplication_out, (vec2<i32>(_S1028)), 0, (vec4<u32>((bitcast<u32>((_S1045))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1046 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1046;
    var _S1047 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1047;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1048 : f32 = rgb_to_greyscale(r_7.f);
    var _S1049 : f32 = sel_4.w_sum / _S1048;
    var _S1050 : bool = _S1048 > 0.0f;
    var _S1051 : f32 = select(0.0f, _S1049, _S1050);
    r_7.w = _S1051;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1052 : vec2<u32> = global_invocation_id_2.xy;
    var _S1053 : vec2<i32> = vec2<i32>(_S1052);
    var _S1054 : vec3<f32> = vec3<f32>(0.0f);
    var _S1055 : Domain = Domain_x24init_0(_S1054, _S1054, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1055;
    var _S1056 : bool = (currentDomain((_S1053), &(dom_5)));
    var _S1057 : bool = !_S1056;
    if(_S1057)
    {
        storeReservoir(reservoir_prev_out, (_S1053), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1054, 0.0f, vec4<u32>(u32(0)), _S1054, _S1054)), (dom_5.hit));
        var _S1058 : vec2<f32> = vec2<f32>(_S1052);
        var _S1059 : vec2<u32> = (uniforms_uint.render_size);
        var _S1060 : vec2<f32> = _S1058 / vec2<f32>(_S1059.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1061 : vec3<f32> = vec3<f32>(_S1060, 1.0f);
        var _S1062 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1063 : vec3<f32> = (normalize(((((_S1062) * (_S1061))))));
        var _S1064 : vec3<f32> = environment_0(_S1063);
        textureStore(compute_out, (_S1053), (u32(0)), (vec4<f32>(_S1064, 1.0f)));
        var _S1065 : u32 = (uniforms_uint.is_temporal);
        var _S1066 : bool = _S1065 == u32(1);
        if(_S1066)
        {
            textureStore(compute_out, (_S1053), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1067 : Reservoir = (loadReservoir(reservoir_temp, (_S1053)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1067.c;
    loop
    {
        var _S1068 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1068)
        {
        }
        else
        {
            break;
        }
        var _S1069 : vec2<i32> = partner_0(_S1053, t_13);
        var neighbor_0 : Domain = _S1055;
        var _S1070 : bool = (currentDomain((_S1069), &(neighbor_0)));
        if(_S1070)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1071 : vec4<u32> = (textureLoad(reservoir_temp, (_S1069), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1071.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1072 : f32 = _S1067.c / max(count_3, 1.0f);
    var _S1073 : f32 = rgb_to_greyscale(_S1067.f);
    var _S1074 : bool = count_3 == 0.0f;
    var _S1075 : f32 = select(0.0f, 1.0f, _S1074);
    var _S1076 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1054, 0.0f, vec4<u32>(u32(0)), _S1054, _S1054), 0.0f, _S1054, u32(0));
    var sel_5 : Selection = _S1076;
    var _S1077 : u32 = (uniforms_uint.frame);
    var _S1078 : u32 = hash(_S1077);
    var _S1079 : u32 = global_invocation_id_2.x;
    var _S1080 : vec2<u32> = (uniforms_uint.render_size);
    var _S1081 : u32 = stream(_S1078, _S1079 + _S1080.x * global_invocation_id_2.y);
    var _S1082 : u32 = stream(_S1081, u32(195));
    sel_5.random_state = _S1082;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1075;
    loop
    {
        var _S1083 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1083)
        {
        }
        else
        {
            break;
        }
        var _S1084 : vec2<i32> = partner_0(_S1053, t_13);
        var neighbor_dom_0 : Domain = _S1055;
        var _S1085 : bool = (currentDomain((_S1084), &(neighbor_dom_0)));
        if(_S1085)
        {
            var _S1086 : Reservoir = (loadReservoir(reservoir_temp, (_S1084)));
            var _S1087 : vec4<u32> = (textureLoad(shift_data, (_S1084), (t_13), 0));
            var _S1088 : vec4<f32> = (bitcast<vec4<f32>>((_S1087)));
            var _S1089 : vec4<u32> = (textureLoad(shift_data, (_S1053), (t_13), 0));
            var _S1090 : vec4<f32> = (bitcast<vec4<f32>>((_S1089)));
            var _S1091 : f32 = (_S1086.c + _S1072) / c_sum_0;
            var _S1092 : bool = _S1073 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1092)
            {
                var _S1093 : f32 = _S1091 * _S1072 * _S1073;
                var _S1094 : f32 = _S1072 * _S1073;
                var _S1095 : f32 = rgb_to_greyscale(_S1090.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1093 / (_S1094 + _S1086.c * _S1095);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1096 : f32 = rgb_to_greyscale(_S1086.f);
            var _S1097 : vec3<f32> = _S1088.xyz;
            var _S1098 : Shift = Shift_x24init_0(_S1097, _S1088.w);
            var _S1099 : f32 = _S1091 * _S1086.c * _S1096;
            var _S1100 : f32 = _S1086.c * _S1096;
            var _S1101 : f32 = rgb_to_greyscale(_S1097);
            offerShifted(&(sel_5), _S1086, _S1098, _S1099 / (_S1100 + _S1072 * _S1101));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1067, Shift_x24init_0(_S1067.f, 1.0f), canonical_mis_0);
    var _S1102 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1053), (_S1102), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1053), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1103 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1104 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1105 : f32 = (sign((dot(_S1104, _S1103.smooth_n))));
    var _S1106 : vec3<f32> = _S1103.material.emissive * vec3<f32>(max(_S1105, 0.0f));
    var _S1107 : vec3<f32> = select(_S1106, _S1054, _S1103.skip);
    var _S1108 : vec3<f32> = clamp(sel_5.color + _S1107, _S1054, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1053), (u32(0)), (vec4<f32>(_S1108, 1.0f)));
    var _S1109 : u32 = (uniforms_uint.is_temporal);
    var _S1110 : bool = _S1109 == u32(1);
    if(_S1110)
    {
        textureStore(compute_out, (_S1053), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1111 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1112 : bool = _S1111 != u32(4294967295);
    if(_S1112)
    {
        var _S1113 : vec2<i32> = vec2<i32>((vec2<u32>(_S1111, (_S1111 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1114 : vec3<f32> = vec3<f32>(0.0f);
        var _S1115 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1114, _S1114, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1114, 0.0f, vec4<u32>(u32(0)), _S1114, _S1114));
        var shift_job_0 : ShiftJob = _S1115;
        var _S1116 : u32 = (_S1111 >> (u32(28)));
        var _S1117 : bool = spatialJob_0(_S1113, _S1116, &(shift_job_0));
        var _S1118 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1113), (_S1116), (vec4<u32>((bitcast<vec3<u32>>((_S1118.f))), (bitcast<u32>((_S1118.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1119 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1120 : array<u32, i32(3)>;
    spatialBins_0(_S1119, &(_S1120));
    var _S1121 : array<u32, i32(3)> = _S1120;
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
        var _S1122 : bool = (_S1121[t_16]) == u32(40);
        if(_S1122)
        {
            textureStore(shift_data_out, (_S1119), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1119, _S1121, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1123 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1123));
    countShifts_0(_S1123, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1124 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1125 : bool = _S1124 != u32(4294967295);
    if(_S1125)
    {
        var _S1126 : vec2<i32> = vec2<i32>((vec2<u32>(_S1124, (_S1124 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1127 : vec3<f32> = vec3<f32>(0.0f);
        var _S1128 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1127, _S1127, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1127, 0.0f, vec4<u32>(u32(0)), _S1127, _S1127));
        var shift_job_1 : ShiftJob = _S1128;
        var _S1129 : u32 = (_S1124 >> (u32(28)));
        var _S1130 : bool = temporalJob_0(_S1126, _S1129, &(shift_job_1));
        var _S1131 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1126), (_S1129), (vec4<u32>((bitcast<vec3<u32>>((_S1131.f))), (bitcast<u32>((_S1131.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1132 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1133 : array<u32, i32(3)>;
    temporalBins_0(_S1132, &(_S1133));
    var _S1134 : array<u32, i32(3)> = _S1133;
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
        var _S1135 : bool = (_S1134[t_18]) == u32(40);
        if(_S1135)
        {
            textureStore(temporal_shifts_out, (_S1132), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1132, _S1134, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1136 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1136));
    countShifts_0(_S1136, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1137 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1138 : vec3<f32> = vec3<f32>(0.0f);
    var _S1139 : Domain = Domain_x24init_0(_S1138, _S1138, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1139;
    var _S1140 : bool = (currentDomain((_S1137), &(dom_6)));
    var _S1141 : bool = !_S1140;
    if(_S1141)
    {
        storeReservoir(reservoir_temp_out, (_S1137), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1138, 0.0f, vec4<u32>(u32(0)), _S1138, _S1138)), (dom_6.hit));
        return;
    }
    var _S1142 : Reservoir = (loadReservoir(reservoir_initial, (_S1137)));
    var _S1143 : vec2<i32> = temporalNeighbor_0(_S1137, dom_6);
    var _S1144 : bool = (_S1143.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1144)
    {
        var _S1145 : Reservoir = (loadReservoir(reservoir_prev, (_S1143)));
        var _S1146 : vec4<u32> = (textureLoad(duplication, (_S1143), 0, 0));
        var _S1147 : f32 = (bitcast<f32>((_S1146.x)));
        var _S1148 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1149 : bool = _S1148 == u32(1);
        var _S1150 : f32 = select(0.0f, _S1147, _S1149);
        var _S1151 : f32 = (mix((20.0f), (1.0f), (pow(_S1150, 0.10000000149011612f))));
        var _S1152 : f32 = min(_S1145.c, _S1151);
        var _S1153 : vec4<u32> = (textureLoad(temporal_shifts, (_S1137), (u32(0)), 0));
        var _S1154 : vec4<f32> = (bitcast<vec4<f32>>((_S1153)));
        var _S1155 : vec4<f32> = vec4<f32>(_S1142.f, 1.0f);
        var _S1156 : Domain = (previousDomain((_S1143)));
        var _S1157 : bool = sameDomain_0(_S1156, dom_6);
        var _S1158 : bool = !_S1157;
        var to_previous_0 : vec4<f32>;
        if(_S1158)
        {
            var _S1159 : vec4<u32> = (textureLoad(temporal_shifts, (_S1137), (u32(1)), 0));
            var _S1160 : vec4<f32> = (bitcast<vec4<f32>>((_S1159)));
            to_previous_0 = _S1160;
        }
        else
        {
            to_previous_0 = _S1155;
        }
        var _S1161 : f32 = rgb_to_greyscale(_S1142.f);
        var _S1162 : f32 = rgb_to_greyscale(_S1145.f);
        var _S1163 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1138, 0.0f, vec4<u32>(u32(0)), _S1138, _S1138), 0.0f, _S1138, u32(0));
        var sel_6 : Selection = _S1163;
        var _S1164 : u32 = (uniforms_uint.frame);
        var _S1165 : u32 = hash(_S1164);
        var _S1166 : u32 = global_invocation_id_7.x;
        var _S1167 : vec2<u32> = (uniforms_uint.render_size);
        var _S1168 : u32 = stream(_S1165, _S1166 + _S1167.x * global_invocation_id_7.y);
        var _S1169 : u32 = stream(_S1168, u32(194));
        sel_6.random_state = _S1169;
        var _S1170 : f32 = _S1142.c * _S1161;
        var _S1171 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1172 : f32 = _S1170 / (_S1170 + _S1152 * _S1171);
        var _S1173 : f32 = _S1152 * _S1162;
        var _S1174 : vec3<f32> = _S1154.xyz;
        var _S1175 : f32 = rgb_to_greyscale(_S1174);
        var _S1176 : f32 = _S1173 / (_S1173 + _S1142.c * _S1175);
        var _S1177 : vec2<f32> = vec2<f32>(_S1172, _S1176);
        offerShifted(&(sel_6), _S1142, Shift_x24init_0(_S1142.f, 1.0f), _S1172);
        offerShifted(&(sel_6), _S1145, Shift_x24init_0(_S1174, _S1154.w), _S1176);
        var _S1178 : Reservoir = finalize(sel_6, _S1142.c + _S1152);
        r_8 = _S1178;
    }
    else
    {
        r_8 = _S1142;
    }
    storeReservoir(reservoir_temp_out, (_S1137), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1179 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1180 : vec3<f32> = vec3<f32>(0.0f);
    var _S1181 : Domain = Domain_x24init_0(_S1180, _S1180, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1181;
    var _S1182 : bool = (currentDomain((_S1179), &(dom_7)));
    var _S1183 : bool = !_S1182;
    if(_S1183)
    {
        storeReservoir(reservoir_initial_out, (_S1179), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1180, 0.0f, vec4<u32>(u32(0)), _S1180, _S1180)), (dom_7.hit));
        return;
    }
    var _S1184 : u32 = (uniforms_uint.frame);
    var _S1185 : u32 = hash(_S1184);
    var _S1186 : u32 = global_invocation_id_8.x;
    var _S1187 : vec2<u32> = (uniforms_uint.render_size);
    var _S1188 : u32 = stream(_S1185, _S1186 + _S1187.x * global_invocation_id_8.y);
    var _S1189 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1180, 0.0f, vec4<u32>(u32(0)), _S1180, _S1180);
    var _S1190 : Selection = Selection_x24init_0(_S1189, 0.0f, _S1180, u32(0));
    var initial_0 : Selection = _S1190;
    var _S1191 : u32 = stream(_S1188, u32(193));
    initial_0.random_state = _S1191;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1192 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1192)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1189;
        var _S1193 : u32 = stream(_S1188, i_10);
        r_9.seed = _S1193;
        var _S1194 : u32 = (uniforms_uint.samples);
        var _S1195 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1194), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1196 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1179), (_S1196), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1197 : Random = pcg(state_3);
    var _S1198 : Random = pcg(_S1197.state);
    var _S1199 : f32 = 6.28318548202514648f * _S1197.value;
    var _S1200 : f32 = sqrt(-2.0f * clamp(log(_S1198.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1198.state, _S1200 * cos(_S1199));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1201 : RandomSphere;
    _S1201.state = state_4;
    _S1201.value = value_1;
    return _S1201;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1202 : Random = normal_distribution(state_5);
    var _S1203 : Random = normal_distribution(_S1202.state);
    var _S1204 : Random = normal_distribution(_S1203.state);
    var _S1205 : vec3<f32> = (normalize((vec3<f32>(_S1202.value, _S1203.value, _S1204.value))));
    return RandomSphere_x24init_0(_S1204.state, _S1205);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1206 : vec3<f32> = p1_0 - p0_0;
    var _S1207 : vec3<f32> = p2_0 - p0_0;
    var _S1208 : vec2<f32> = uv1_0 - uv0_0;
    var _S1209 : vec2<f32> = uv2_0 - uv0_0;
    var _S1210 : f32 = _S1208.x;
    var _S1211 : f32 = _S1209.y;
    var _S1212 : f32 = _S1208.y;
    var _S1213 : f32 = _S1209.x;
    var _S1214 : f32 = _S1210 * _S1211 - _S1212 * _S1213;
    var _S1215 : f32 = 1.0f / _S1214;
    var _S1216 : vec3<f32> = vec3<f32>(_S1215);
    var t_20 : vec3<f32> = (_S1206 * vec3<f32>(_S1211) - _S1207 * vec3<f32>(_S1212)) * _S1216;
    var _S1217 : vec3<f32> = (_S1207 * vec3<f32>(_S1210) - _S1206 * vec3<f32>(_S1213)) * _S1216;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1218 : bool = (dot(cross(n_9, t_21), _S1217)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1218)
    {
        var _S1219 : vec3<f32> = ((-(t_21)));
        t_22 = _S1219;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1220 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1220, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1221 : vec3<f32> = t1_0 - t0_0;
    var _S1222 : vec3<f32> = t2_2 - t0_0;
    var _S1223 : vec3<f32> = t2_2 - t1_0;
    var _S1224 : f32 = min(length(_S1221), min(length(_S1222), length(_S1223)));
    var _S1225 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1226 : vec3<f32> = (normalize((n0_0)));
    var _S1227 : f32 = dot(geometry_n_4, _S1226);
    var _S1228 : vec3<f32> = (normalize((n1_0)));
    var _S1229 : f32 = dot(geometry_n_4, _S1228);
    var _S1230 : vec3<f32> = (normalize((n2_0)));
    var _S1231 : vec3<f32> = acos(abs(vec3<f32>(_S1227, _S1229, dot(geometry_n_4, _S1230))));
    var _S1232 : vec3<f32> = clamp(tan(_S1231), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1225 * _S1232, uvw_0), 0.0f, _S1224 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_10 : vec3<f32>,  material_20 : Material) -> vec3<f32>
{
    var _S1233 : vec3<f32> = ((-(dir_12)));
    var _S1234 : f32 = (sign((dot(n_10, _S1233))));
    var _S1235 : vec3<f32> = n_10 * vec3<f32>(_S1234);
    var _S1236 : AnisotropicFrame = anisotropicFrame(material_20, _S1235);
    var _S1237 : bool = (_S1236.alphas.x) > 0.0f;
    if(_S1237)
    {
        var _S1238 : f32 = material_20.transmission * (1.0f - material_20.metallic);
        var _S1239 : vec3<f32> = ((-(_S1235)));
        var _S1240 : vec3<f32> = anisotropicLocal(dir_12, _S1236.tangent, _S1239);
        var _S1241 : f32 = anisotropicG1(_S1240, _S1236.alphas);
        return vec3<f32>((_S1238 * _S1241)) * material_20.albedo;
    }
    var _S1242 : f32 = material_20.transmission * (1.0f - material_20.metallic);
    var _S1243 : f32 = material_20.roughness;
    var _S1244 : f32 = smithG1(_S1243 * _S1243, abs(dot(n_10, dir_12)));
    return vec3<f32>((_S1242 * _S1244)) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1245 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1246 : vec3<f32> = straightThrough(toward_1, n_11, material_21);
        _S1245 = _S1246;
    }
    else
    {
        _S1245 = vec3<f32>(0.0f);
    }
    return _S1245 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1247 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1247;
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

