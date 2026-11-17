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
    var _S14 : vec2<i32> = _S12 % _S13;
    var _S15 : vec2<i32> = _S13 - _S14;
    var _S16 : vec2<bool> = _S8 < vec2<i32>(i32(0));
    var _S17 : vec2<i32> = select(_S14, _S15, _S16);
    var _S18 : vec2<i32> = (_S17 + _S10) % _S13;
    var _S19 : vec4<i32> = (textureLoad(pairing, (_S18), (t_0), 0));
    var _S20 : vec2<i32> = _S19.xy * _S8;
    var _S21 : vec2<i32> = _S20.yx;
    var _S22 : vec2<i32> = select(_S20, _S21, _S9);
    return p_0 + _S22;
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
    var _S23 : bool = t_1 > u32(2);
    var _S24 : bool;
    if(_S23)
    {
        _S24 = true;
    }
    else
    {
        var _S25 : vec2<u32> = (uniforms_uint.render_size);
        _S24 = (any((p_1 >= vec2<i32>(_S25))));
    }
    if(_S24)
    {
        return false;
    }
    var _S26 : Reservoir = (loadReservoir(reservoir_temp, (p_1)));
    (*job_0).r = _S26;
    var _S27 : bool = ((*job_0).r.w) > 0.0f;
    if(_S27)
    {
        var _S28 : vec2<i32> = partner_0(p_1, t_1);
        var _S29 : Domain = (*job_0).dom;
        var _S30 : bool = (storedDomain(reservoir_temp, (_S28), &(_S29)));
        (*job_0).dom = _S29;
        _S24 = _S30;
    }
    else
    {
        _S24 = false;
    }
    return _S24;
}

fn Hit_x24init_0( uv_0 : vec2<f32>,  instance_index_0 : u32,  triangle_index_0 : u32,  is_point_light_0 : u32,  distance_0 : f32) -> Hit
{
    var _S31 : Hit;
    _S31.uv = uv_0;
    _S31.instance_index = instance_index_0;
    _S31.triangle_index = triangle_index_0;
    _S31.is_point_light = is_point_light_0;
    _S31.distance = distance_0;
    return _S31;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_0 : Hit) -> Domain
{
    var _S32 : Domain;
    _S32.x0 = x0_0;
    _S32.x1 = x1_0;
    _S32.hit = hit_0;
    return _S32;
}

fn Reservoir_x24init_0( seed_0 : u32,  path_0 : u32,  w_0 : f32,  c_0 : f32,  f_0 : vec3<f32>,  jac_0 : f32,  rc_0 : vec4<u32>,  dir_0 : vec3<f32>,  radiance_0 : vec3<f32>) -> Reservoir
{
    var _S33 : Reservoir;
    _S33.seed = seed_0;
    _S33.path = path_0;
    _S33.w = w_0;
    _S33.c = c_0;
    _S33.f = f_0;
    _S33.jac = jac_0;
    _S33.rc = rc_0;
    _S33.dir = dir_0;
    _S33.radiance = radiance_0;
    return _S33;
}

fn ShiftJob_x24init_0( dom_0 : Domain,  r_0 : Reservoir) -> ShiftJob
{
    var _S34 : ShiftJob;
    _S34.dom = dom_0;
    _S34.r = r_0;
    return _S34;
}

fn shiftBin_0( r_1 : Reservoir) -> u32
{
    var _S35 : u32 = (extractBits((r_1.path), (u32(10)), (u32(2))));
    var _S36 : bool = _S35 == u32(2);
    var _S37 : bool;
    if(_S36)
    {
        var _S38 : u32 = (extractBits((r_1.path), (u32(12)), (u32(3))));
        _S37 = _S38 == u32(4);
    }
    else
    {
        _S37 = false;
    }
    var _S39 : u32 = select(_S35, u32(4), _S37);
    var _S40 : u32 = (extractBits((r_1.path), (u32(5)), (u32(5))));
    var _S41 : u32 = (extractBits((r_1.path), (u32(0)), (u32(5))));
    var _S42 : u32 = _S41 + u32(1);
    var _S43 : bool = _S35 == u32(0);
    var _S44 : u32 = select(_S40, _S42, _S43);
    return _S39 * u32(8) + clamp(_S44, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_2 : vec2<i32>,  _S45 : ptr<function, array<u32, i32(3)>>)
{
    var _S46 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_2 : u32 = u32(0);
    loop
    {
        var _S47 : u32 = (uniforms_uint.restir_neighbours);
        if(t_2 < _S47)
        {
        }
        else
        {
            break;
        }
        var _S48 : vec3<f32> = vec3<f32>(0.0f);
        var _S49 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S48, _S48, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S48, 0.0f, vec4<u32>(u32(0)), _S48, _S48));
        var job_1 : ShiftJob = _S49;
        var _S50 : bool = spatialJob_0(p_2, t_2, &(job_1));
        if(_S50)
        {
            var _S51 : u32 = shiftBin_0(job_1.r);
            bins_0[t_2] = _S51;
        }
        var t_3 : u32 = t_2 + u32(1);
        t_2 = t_3;
    }
    (*_S45) = bins_0;
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
    var _S52 : Selection;
    _S52.r = r_2;
    _S52.w_sum = w_sum_0;
    _S52.color = color_0;
    _S52.random_state = random_state_0;
    return _S52;
}

fn Shift_x24init_0( f_1 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S53 : Shift;
    _S53.f = f_1;
    _S53.jac = jac_1;
    return _S53;
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S54 : Ray;
    _S54.origin = origin_0;
    _S54.unit_direction = unit_direction_0;
    return _S54;
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
    var _S55 : NEEVertex;
    _S55.none = none_0;
    _S55.pdf = pdf_0;
    _S55.origin = origin_1;
    _S55.smooth_n = smooth_n_0;
    _S55.start = start_0;
    return _S55;
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
    var _S56 : Vertex;
    _S56.rough = rough_0;
    _S56.lobe = lobe_0;
    _S56.pdf = pdf_1;
    _S56.cos = cos_0;
    _S56.inside = inside_0;
    return _S56;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_0 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_0 : vec3<f32>,  velvet_0 : f32) -> Material
{
    var _S57 : Material;
    _S57.albedo = albedo_0;
    _S57.emissive = emissive_0;
    _S57.roughness = roughness_0;
    _S57.metallic = metallic_0;
    _S57.transmission = transmission_0;
    _S57.ior = ior_0;
    _S57.absorption = absorption_0;
    _S57.specular_tint = specular_tint_0;
    _S57.specular_level = specular_level_0;
    _S57.translucent = translucent_0;
    _S57.sheen = sheen_0;
    _S57.sheen_roughness = sheen_roughness_0;
    _S57.anisotropy = anisotropy_0;
    _S57.anisotropic_rotation = anisotropic_rotation_0;
    _S57.tangent = tangent_0;
    _S57.velvet = velvet_0;
    return _S57;
}

fn Surface_x24init_0( smooth_n_1 : vec3<f32>,  geometry_n_0 : vec3<f32>,  geometry_offset_0 : f32,  material_0 : Material,  skip_0 : bool,  random_state_1 : u32) -> Surface
{
    var _S58 : Surface;
    _S58.smooth_n = smooth_n_1;
    _S58.geometry_n = geometry_n_0;
    _S58.geometry_offset = geometry_offset_0;
    _S58.material = material_0;
    _S58.skip = skip_0;
    _S58.random_state = random_state_1;
    return _S58;
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S59 : u32 = hash(index_0);
    var _S60 : u32 = hash((seed_1 ^ (_S59)));
    return _S60;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S61 : bool = transmission_1 > 0.0f;
    var _S62 : bool;
    if(_S61)
    {
        _S62 = true;
    }
    else
    {
        _S62 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S63 : f32;
    if(_S62)
    {
        _S63 = 1.0f;
    }
    else
    {
        _S63 = -1.0f;
    }
    return _S63;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S64 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S65 : vec3<f32> = vec3<f32>(_S64);
    return Surface_x24init_0(surface_0.smooth_n * _S65, surface_0.geometry_n * _S65, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S66 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S66));
}

fn vertexEta( material_1 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S67 : bool = n_dot_v_0 < 0.0f;
    var _S68 : f32 = select(1.0f, material_1.ior, _S67);
    var _S69 : f32 = select(material_1.ior, 1.0f, _S67);
    return vec2<f32>(_S68, _S69);
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S70 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S71 : f32 = eta_i_0 / eta_o_0 * _S70;
    var _S72 : bool = _S71 < 1.0f;
    var kr_0 : f32;
    if(_S72)
    {
        var _S73 : f32 = sqrt(max(0.0f, 1.0f - _S71 * _S71));
        var _S74 : bool = eta_i_0 == eta_o_0;
        var _S75 : f32 = select(_S73, cos_theta_0, _S74);
        var _S76 : f32 = eta_o_0 * cos_theta_0;
        var _S77 : f32 = eta_i_0 * _S75;
        var _S78 : f32 = (_S76 - _S77) / (_S76 + _S77);
        var _S79 : f32 = eta_i_0 * cos_theta_0;
        var _S80 : f32 = eta_o_0 * _S75;
        var _S81 : f32 = (_S79 - _S80) / (_S79 + _S80);
        var _S82 : f32 = (_S78 * _S78 + _S81 * _S81) / 2.0f;
        kr_0 = _S82;
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
    var _S83 : f32 = fresnel(abs(n_dot_v_1), eta_i_1, eta_o_1);
    var _S84 : vec3<f32> = (mix((vec3<f32>(_S83)), (material_2.albedo), (material_2.metallic)));
    var _S85 : f32 = rgb_to_greyscale(_S84);
    var _S86 : f32 = max((1.0f - _S85) * (1.0f - material_2.metallic) * (1.0f - material_2.transmission), 0.0f);
    var _S87 : bool = _S86 > 0.03999999910593033f;
    var _S88 : bool;
    if(_S87)
    {
        _S88 = true;
    }
    else
    {
        _S88 = (material_2.roughness) > 0.20000000298023224f;
    }
    return _S88;
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
    var _S89 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S90 : bool = cos_a_0 > cos_b_0;
    var _S91 : f32 = select(_S89, 1.0f, _S90);
    return _S91;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S92 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S93 : vec3<f32> = node_0.high - node_0.low;
    var _S94 : vec3<f32> = p_3 - _S92;
    var _S95 : vec3<f32> = (normalize((_S94)));
    var _S96 : f32 = dot(_S94, _S94);
    var _S97 : f32 = dot(_S93, _S93) / 4.0f;
    var _S98 : f32 = abs(dot(node_0.w, _S95));
    var _S99 : f32 = sine(node_0.cos_theta_o);
    var _S100 : f32 = sqrt(max(1.0f - _S97 / _S96, 0.0f));
    var _S101 : bool = _S96 < _S97;
    var _S102 : f32 = select(_S100, -1.0f, _S101);
    var _S103 : f32 = sine(_S102);
    var _S104 : f32 = sine(_S98);
    var _S105 : f32 = cosSubClamped(_S104, _S98, _S99, node_0.cos_theta_o);
    var _S106 : f32 = sine(_S98);
    var _S107 : f32 = _S106 * node_0.cos_theta_o - _S98 * _S99;
    var _S108 : bool = _S98 > (node_0.cos_theta_o);
    var _S109 : f32 = select(_S107, 0.0f, _S108);
    var _S110 : f32 = cosSubClamped(_S109, _S105, _S103, _S102);
    var _S111 : bool = _S110 <= 0.0f;
    if(_S111)
    {
        return 0.0f;
    }
    var _S112 : f32 = - dot(_S95, normal_0);
    var _S113 : f32 = node_0.phi * _S110 / max(_S96, length(_S93) / 2.0f);
    var _S114 : f32 = sine(_S112);
    var _S115 : f32 = cosSubClamped(_S114, _S112, _S103, _S102);
    var _S116 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S117 : f32 = select(_S115, 1.0f, _S116);
    return max(_S113 * _S117, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S118 : f32 = importance(first_0, p_4, normal_1);
    var _S119 : f32 = importance(second_0, p_4, normal_1);
    var _S120 : vec2<f32> = vec2<f32>(_S118, _S119);
    var _S121 : f32 = _S120[child_0] / (_S118 + _S119);
    var _S122 : bool = (_S120[child_0]) > 0.0f;
    var _S123 : f32 = select(0.0f, _S121, _S122);
    return _S123;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S124 : vec3<f32> = center_0 - p_5;
    var _S125 : f32 = radius_0 * radius_0 / dot(_S124, _S124);
    var _S126 : bool = _S125 >= 1.0f;
    if(_S126)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S125)) / (6.28318548202514648f * _S125);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S127 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S128 : vec2<u32> = _S127.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S128;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S129 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S129.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S130 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S131 : u32 = n_0 + u32(1);
        var _S132 : LightBounds = (lightBounds((_S131)));
        var _S133 : LightBounds = (lightBounds((_S130)));
        var _S134 : u32 = trail_0.x;
        var _S135 : u32 = (_S134 & (u32(1)));
        var _S136 : f32 = childShare(_S132, _S133, origin_2, smooth_n_2, _S135);
        var probability_2 : f32 = probability_1 * _S136;
        var _S137 : bool = _S135 == u32(1);
        var _S138 : u32 = select(_S131, _S130, _S137);
        var _S139 : u32 = trail_0.y;
        var _S140 : vec2<u32> = vec2<u32>((((_S134 >> (u32(1)))) | (((_S139 << (u32(31)))))), (_S139 >> (u32(1))));
        n_0 = _S138;
        trail_0 = _S140;
        probability_1 = probability_2;
    }
    var _S141 : bool = (((_S127).z == (n_0)));
    var _S142 : bool = !_S141;
    var _S143 : bool;
    if(_S142)
    {
        _S143 = true;
    }
    else
    {
        var _S144 : LightBounds = (lightBounds((n_0)));
        var _S145 : f32 = importance(_S144, origin_2, smooth_n_2);
        _S143 = !(_S145 > 0.0f);
    }
    if(_S143)
    {
        _S143 = true;
    }
    else
    {
        var _S146 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S146)
        {
            _S143 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S143 = false;
        }
    }
    if(_S143)
    {
        return 0.0f;
    }
    var _S147 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S148 : bool = (_S147.x) == u32(2);
    if(_S148)
    {
        var _S149 : u32 = _S147.y;
        var _S150 : Light = (lights[(_S149)]);
        var _S151 : Light = (lights[(_S149)]);
        var _S152 : f32 = sphereDensity(_S150.position, _S151.variance, start_1);
        return probability_1 * _S152;
    }
    var _S153 : u32 = _S147.y;
    var _S154 : u32 = ((instance_uint[(_S153) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S155 : mat3x3<f32> = (worldTriangle((_S153), (_S154 + _S147.z)));
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

fn TreeSample_x24init_0( dir_2 : vec3<f32>,  radiance_1 : vec3<f32>,  density_0 : f32,  random_state_2 : u32) -> TreeSample
{
    var _S163 : TreeSample;
    _S163.dir = dir_2;
    _S163.radiance = radiance_1;
    _S163.density = density_0;
    _S163.random_state = random_state_2;
    return _S163;
}

fn isTranslucent_0( material_3 : Material) -> bool
{
    var _S164 : f32 = rgb_to_greyscale(material_3.translucent);
    return _S164 > 0.0f;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S165 : Random;
    _S165.state = state_0;
    _S165.value = value_0;
    return _S165;
}

fn pcg( state_1 : u32) -> Random
{
    var _S166 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S167 : u32 = hash(state_1);
    return Random_x24init_0(_S166, f32(_S167) / 4.294967296e+09f);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S168 : f32 = importance(first_1, p_6, normal_3);
    var _S169 : f32 = importance(second_1, p_6, normal_3);
    var _S170 : vec2<f32> = vec2<f32>(_S168, _S169);
    var _S171 : bool = _S168 == 0.0f;
    var _S172 : bool;
    if(_S171)
    {
        _S172 = _S169 == 0.0f;
    }
    else
    {
        _S172 = false;
    }
    if(_S172)
    {
        return u32(2);
    }
    var _S173 : f32 = _S168 + _S169;
    var _S174 : bool = _S169 > 0.0f;
    if(_S174)
    {
        _S172 = ((*pick_0) * _S173) >= _S168;
    }
    else
    {
        _S172 = false;
    }
    var _S175 : u32 = select(u32(0), u32(1), _S172);
    var _S176 : f32 = min(((*pick_0) * _S173 - f32(_S175) * _S168) / _S170[_S175], 0.99999994039535522f);
    (*pick_0) = _S176;
    var _S177 : f32 = (*probability_3) * (_S170[_S175] / _S173);
    (*probability_3) = _S177;
    return _S175;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S178 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S178)
    {
        const _S179 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S179;
    }
    else
    {
        a_2 = a_1;
    }
    var _S180 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S181 : vec3<f32> = cross(n_1, _S180);
    return vec3<f32>(v_0.x) * _S180 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S181;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S182 : vec3<f32> = center_1 - p_7;
    var _S183 : f32 = radius_1 * radius_1 / dot(_S182, _S182);
    var _S184 : f32 = u1_0 * _S183 / (1.0f + sqrt(max(1.0f - _S183, 0.0f)));
    var _S185 : f32 = 2.0f * u1_0;
    var _S186 : bool = _S183 >= 1.0f;
    var _S187 : f32 = select(_S184, _S185, _S186);
    var _S188 : f32 = sqrt(max(_S187 * (2.0f - _S187), 0.0f));
    var _S189 : f32 = 6.28318548202514648f * u2_0;
    var _S190 : vec3<f32> = vec3<f32>(_S188 * cos(_S189), 1.0f - _S187, _S188 * sin(_S189));
    var _S191 : vec3<f32> = (normalize((_S182)));
    var _S192 : vec3<f32> = tangentToWorld(_S190, _S191);
    return _S192;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S193 : vec3<f32> = center_2 - ray_0.origin;
    var _S194 : f32 = dot(_S193, ray_0.unit_direction);
    var _S195 : f32 = dot(_S193, _S193) - _S194 * _S194;
    var _S196 : f32 = radius_3 * radius_3;
    var _S197 : bool = _S195 > _S196;
    if(_S197)
    {
        return 4.294967296e+09f;
    }
    var _S198 : f32 = sqrt(_S196 - _S195);
    var _S199 : f32 = _S194 - _S198;
    var _S200 : f32 = _S194 + _S198;
    var _S201 : bool = _S199 > 0.0000152587890625f;
    var _S202 : bool;
    if(_S201)
    {
        _S202 = _S199 < max_len_0;
    }
    else
    {
        _S202 = false;
    }
    if(_S202)
    {
        return _S199;
    }
    var _S203 : bool = _S200 > 0.0000152587890625f;
    if(_S203)
    {
        _S202 = _S200 < max_len_0;
    }
    else
    {
        _S202 = false;
    }
    if(_S202)
    {
        return _S200;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S204 : vec3<f32> = (normalize((light_dir_0)));
    var _S205 : bool = (dot(smooth_n_3, _S204)) < 0.0f;
    if(_S205)
    {
        return vec3<f32>(0.0f);
    }
    var _S206 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S207 : Ray = Ray_x24init_0(_S206, _S204);
    var _S208 : f32 = shadowLength(light_dir_0);
    var _S209 : vec3<f32> = (shadowTransmittance((_S207), (_S208)));
    return _S209;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S210 : Random = pcg(init_random_state_0);
    var _S211 : Random = pcg(_S210.state);
    var _S212 : Random = pcg(_S211.state);
    var _S213 : vec3<f32> = vec3<f32>(0.0f);
    var _S214 : TreeSample = TreeSample_x24init_0(_S213, _S213, 0.0f, _S212.state);
    var sample_0 : TreeSample = _S214;
    var _S215 : vec3<f32> = select(smooth_n_4, _S213, sided_0);
    var _S216 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S217 : vec3<f32> = origin_4 + _S216 * smooth_n_4;
    var pick_1 : f32 = _S210.value;
    var probability_4 : f32 = 1.0f;
    var n_2 : u32 = u32(0);
    loop
    {
        var _S218 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
        if((_S218.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S219 : u32 = (access_light_tree(3u + 4u * (n_2)).w);
        var _S220 : u32 = n_2 + u32(1);
        var _S221 : LightBounds = (lightBounds((_S220)));
        var _S222 : LightBounds = (lightBounds((_S219)));
        var _S223 : u32 = pickChild(_S221, _S222, origin_4, _S215, &(pick_1), &(probability_4));
        var _S224 : bool = _S223 > u32(1);
        if(_S224)
        {
            return sample_0;
        }
        var _S225 : bool = _S223 == u32(1);
        var _S226 : u32 = select(_S220, _S219, _S225);
        n_2 = _S226;
    }
    var _S227 : bool = n_2 == u32(0);
    var _S228 : bool;
    if(_S227)
    {
        var _S229 : LightBounds = (lightBounds((u32(0))));
        var _S230 : f32 = importance(_S229, origin_4, _S215);
        _S228 = !(_S230 > 0.0f);
    }
    else
    {
        _S228 = false;
    }
    if(_S228)
    {
        return sample_0;
    }
    var _S231 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
    var _S232 : bool = (_S231.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S232)
    {
        var _S233 : Light = (lights[(_S231.y)]);
        if(sided_0)
        {
            var _S234 : f32 = (sign((dot(geometry_n_1, _S233.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S234);
            var _S235 : vec3<f32> = origin_4 + _S216 * lift_n_1;
            start_2 = _S235;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S217;
            lift_n_0 = smooth_n_4;
        }
        var _S236 : bool = (_S233.variance) == 0.0f;
        if(_S236)
        {
            var _S237 : vec3<f32> = _S233.position - start_2;
            var _S238 : vec3<f32> = (normalize((_S237)));
            sample_0.dir = _S238;
            var _S239 : vec3<f32> = _S233.color * vec3<f32>(_S233.intensity) / vec3<f32>((dot(_S237, _S237) * probability_4));
            sample_0.radiance = _S239;
            shadow_1 = _S237;
        }
        else
        {
            var _S240 : vec3<f32> = sampleSphere(_S233.position, _S233.variance, start_2, _S211.value, _S212.value);
            sample_0.dir = _S240;
            var _S241 : f32 = sphereDensity(_S233.position, _S233.variance, start_2);
            var _S242 : f32 = probability_4 * _S241;
            sample_0.density = _S242;
            var _S243 : vec3<f32> = pointLightRadiance(_S233.color, _S233.intensity, _S233.variance);
            var _S244 : vec3<f32> = _S243 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S244;
            var _S245 : f32 = raySphere_0(_S233.position, _S233.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S246 : vec3<f32> = sample_0.dir * vec3<f32>(_S245);
            shadow_1 = _S246;
        }
    }
    else
    {
        var _S247 : u32 = _S231.y;
        var _S248 : u32 = ((instance_uint[(_S247) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S249 : u32 = _S248 + _S231.z;
        var _S250 : mat3x3<f32> = (worldTriangle((_S247), (_S249)));
        var _S251 : f32 = sqrt(_S211.value);
        var _S252 : vec2<f32> = vec2<f32>(_S251 * (1.0f - _S212.value), _S251 * _S212.value);
        var _S253 : vec3<f32> = (((_S250) * (vec3<f32>(1.0f - _S251, _S252))));
        if(sided_0)
        {
            var _S254 : f32 = (sign((dot(geometry_n_1, _S253 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S254);
            var _S255 : vec3<f32> = origin_4 + _S216 * lift_n_2;
            start_2 = _S255;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S256 : bool = !((dot(smooth_n_4, _S253 - origin_4)) > 0.0f);
            if(_S256)
            {
                return sample_0;
            }
            start_2 = _S217;
            lift_n_0 = smooth_n_4;
        }
        var _S257 : Surface = (surfaceAt((Hit_x24init_0(_S252, _S247, _S249, u32(0), 0.0f)), (_S253), (_S212.state)));
        sample_0.random_state = _S257.random_state;
        var _S258 : vec3<f32> = _S253 - start_2;
        var _S259 : vec3<f32> = (normalize((_S258)));
        sample_0.dir = _S259;
        var _S260 : f32 = solidAngle(probability_4, cross(_S250[i32(1)] - _S250[i32(0)], _S250[i32(2)] - _S250[i32(0)]), _S258);
        sample_0.density = _S260;
        var _S261 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S257.smooth_n))));
        var _S262 : vec3<f32> = _S257.material.emissive * vec3<f32>(max(_S261, 0.0f));
        var _S263 : vec3<f32> = select(_S262, _S213, _S257.skip);
        var _S264 : vec3<f32> = _S263 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S264;
        shadow_1 = _S258;
    }
    var _S265 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S266 : vec3<f32> = sample_0.radiance * _S265;
    var _S267 : bool = (all((_S265 == _S213)));
    var _S268 : vec3<f32> = select(_S266, _S213, _S267);
    sample_0.radiance = _S268;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S269 : AnisotropicFrame;
    _S269.tangent = tangent_1;
    _S269.alphas = alphas_0;
    return _S269;
}

fn anisotropicFrame( material_4 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S270 : f32 = material_4.roughness;
    var _S271 : f32 = _S270 * _S270;
    var _S272 : bool = (material_4.anisotropy) == 0.0f;
    var _S273 : bool;
    if(_S272)
    {
        _S273 = true;
    }
    else
    {
        _S273 = !(_S271 > 0.0f);
    }
    if(_S273)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S274 : vec3<f32> = material_4.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_4.tangent));
    var _S275 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S276 : bool = (dot(_S274, _S274)) > 0.0f;
    var _S277 : vec3<f32> = select(_S275, _S274, _S276);
    var _S278 : vec3<f32> = (normalize((_S277)));
    var _S279 : f32 = 6.28318548202514648f * material_4.anisotropic_rotation;
    var _S280 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_4.anisotropy));
    var _S281 : f32 = 1.0f / _S280;
    var _S282 : bool = (material_4.anisotropy) < 0.0f;
    var _S283 : f32 = select(_S280, _S281, _S282);
    return AnisotropicFrame_x24init_0(_S278 * vec3<f32>(cos(_S279)) + cross(n_i_0, _S278) * vec3<f32>(sin(_S279)), vec2<f32>(_S271 / _S283, _S271 * _S283));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S284 : SheenProfile;
    _S284.on = on_0;
    _S284.albedo = albedo_1;
    return _S284;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_5 : Material) -> SheenProfile
{
    var _S285 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S286 : f32 = rgb_to_greyscale(material_5.sheen);
    var _S287 : bool = _S286 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S287)
    {
        var _S288 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S289 : u32 = min(u32(_S288), u32(22));
        var _S290 : f32 = sqrt(0.05000000074505806f);
        var _S291 : f32 = sqrt(0.00999999977648258f);
        var _S292 : bool = (material_5.velvet) > 0.0f;
        var _S293 : f32 = select(_S290, _S291, _S292);
        var _S294 : f32 = (clamp(sqrt(max(material_5.sheen_roughness, 0.0f)), _S293, 1.0f) - _S293) / (1.0f - _S293) * 23.0f;
        var _S295 : u32 = min(u32(_S294), u32(22));
        var _S296 : u32 = _S289 * u32(24) + _S295;
        var _S297 : f32 = _S288 - f32(_S289);
        var _S298 : f32 = _S294 - f32(_S295);
        if(_S292)
        {
            var _S299 : u32 = _S296 + u32(24);
            var _S300 : f32 = VELVET_ALBEDO_0[_S296] + (VELVET_ALBEDO_0[_S299] - VELVET_ALBEDO_0[_S296]) * _S297;
            var _S301 : u32 = _S296 + u32(1);
            var _S302 : f32 = VELVET_ALBEDO_0[_S301] + (VELVET_ALBEDO_0[_S299 + u32(1)] - VELVET_ALBEDO_0[_S301]) * _S297;
            var _S303 : SheenProfile = SheenProfile_x24init_0(true, _S300 + (_S302 - _S300) * _S298);
            profile_0 = _S303;
        }
        else
        {
            var _S304 : u32 = _S296 + u32(24);
            var _S305 : f32 = SHEEN_ALBEDO_0[_S296] + (SHEEN_ALBEDO_0[_S304] - SHEEN_ALBEDO_0[_S296]) * _S297;
            var _S306 : u32 = _S296 + u32(1);
            var _S307 : f32 = SHEEN_ALBEDO_0[_S306] + (SHEEN_ALBEDO_0[_S304 + u32(1)] - SHEEN_ALBEDO_0[_S306]) * _S297;
            var _S308 : SheenProfile = SheenProfile_x24init_0(true, exp(_S305 + (_S307 - _S305) * _S298));
            profile_0 = _S308;
        }
    }
    else
    {
        profile_0 = _S285;
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
    var _S309 : BSDFLobes;
    _S309.v_dot_h = v_dot_h_0;
    _S309.n_dot_h = n_dot_h_0;
    _S309.refracted = refracted_0;
    _S309.F = F_0;
    _S309.F_greyscale = F_greyscale_0;
    _S309.reflect_weight = reflect_weight_0;
    _S309.diffuse_weight = diffuse_weight_0;
    _S309.refract_weight = refract_weight_0;
    _S309.p_diffuse = p_diffuse_0;
    _S309.p_reflect = p_reflect_0;
    _S309.p_refract = p_refract_0;
    _S309.translucent_share = translucent_share_0;
    _S309.sheen = sheen_1;
    _S309.p_sheen_velvet = p_sheen_velvet_0;
    _S309.view = view_0;
    _S309.tangent = tangent_2;
    _S309.alphas = alphas_1;
    _S309.visible = visible_0;
    return _S309;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_3, t_4)), dot(w_1, n_3));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S310 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S311 : f32 = _S310.x;
    var _S312 : f32 = _S310.y;
    var _S313 : f32 = _S311 * _S311 + _S312 * _S312;
    const _S314 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S315 : vec3<f32> = vec3<f32>(- _S312, _S311, 0.0f);
    var _S316 : f32 = (inverseSqrt((_S313)));
    var _S317 : vec3<f32> = _S315 * vec3<f32>(_S316);
    var _S318 : bool = _S313 > 0.0f;
    var _S319 : vec3<f32> = select(_S314, _S317, _S318);
    var _S320 : vec3<f32> = cross(_S310, _S319);
    var _S321 : f32 = sqrt(U1_0);
    var _S322 : f32 = 6.28318548202514648f * U2_0;
    var _S323 : f32 = _S321 * cos(_S322);
    var t2_0 : f32 = _S321 * sin(_S322);
    var _S324 : f32 = 0.5f * (1.0f + _S310.z);
    var t2_1 : f32 = (1.0f - _S324) * sqrt(max(0.0f, 1.0f - _S323 * _S323)) + _S324 * t2_0;
    var _S325 : vec3<f32> = vec3<f32>(_S323) * _S319 + vec3<f32>(t2_1) * _S320;
    var _S326 : f32 = ((_S323));
    var _S327 : f32 = ((_S323));
    var _S328 : vec3<f32> = _S325 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S326 * _S327 - t2_1 * t2_1))) * _S310;
    var _S329 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S328.x, alpha_0 * _S328.y, max(0.0f, _S328.z)))));
    return _S329;
}

fn worldToTangent( v_2 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S330 : bool = (abs(dot(n_4, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S330)
    {
        const _S331 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S331;
    }
    else
    {
        a_4 = a_3;
    }
    var _S332 : vec3<f32> = (normalize((cross(n_4, a_4))));
    var _S333 : vec3<f32> = cross(n_4, _S332);
    return vec3<f32>(dot(v_2, _S332), dot(v_2, n_4), dot(v_2, _S333));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S334 : Random = pcg((*random_state_3));
    var _S335 : Random = pcg(_S334.state);
    (*random_state_3) = _S335.state;
    var _S336 : f32 = frame_0.alphas.x;
    var _S337 : bool = _S336 > 0.0f;
    if(_S337)
    {
        var _S338 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S339 : f32 = frame_0.alphas.y;
        var _S340 : vec3<f32> = (normalize((vec3<f32>(_S336 * _S338.x, _S339 * _S338.y, _S338.z))));
        var _S341 : vec3<f32> = sampleGGXVNDF(_S340, 1.0f, _S334.value, _S335.value);
        var _S342 : vec3<f32> = (normalize((vec3<f32>(_S336 * _S341.x, _S339 * _S341.y, _S341.z))));
        return vec3<f32>(_S342.x) * frame_0.tangent + vec3<f32>(_S342.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S342.z) * n_i_2;
    }
    var _S343 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S344 : vec3<f32> = sampleGGXVNDF(_S343.xzy, alpha_1, _S334.value, _S335.value);
    var _S345 : vec3<f32> = _S344.xzy;
    var _S346 : vec3<f32> = tangentToWorld(_S345, n_i_2);
    return _S346;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_6 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S347 : vec3<f32> = ((-(in_dir_0)));
    var _S348 : f32 = (sign((dot(n_5, _S347))));
    var _S349 : f32 = material_6.roughness;
    var _S350 : vec3<f32> = sampleHalfVector(_S347, n_5 * vec3<f32>(_S348), _S349 * _S349, frame_1, &(state_2));
    return _S350;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S351 : vec3<f32> = ((-(in_dir_1)));
    var _S352 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S351 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S353 : vec3<f32> = (normalize((_S352)));
    var _S354 : f32 = (sign((dot(n_6, _S351))));
    var _S355 : f32 = (sign((dot(_S352, n_6 * vec3<f32>(_S354)))));
    return _S353 * vec3<f32>(_S355);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S356 : vec3<f32> = ((-(in_dir_2)));
    var _S357 : vec3<f32> = (normalize((_S356 + out_dir_1)));
    return _S357;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S358 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S358 / (_S358 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S358)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S359 : f32 = alphas_3.x;
    var _S360 : f32 = h_0.x / _S359;
    var _S361 : f32 = alphas_3.y;
    var _S362 : f32 = h_0.y / _S361;
    var _S363 : f32 = h_0.z;
    var _S364 : f32 = _S360 * _S360 + _S362 * _S362 + _S363 * _S363;
    return 1.0f / max(3.14159274101257324f * _S359 * _S361 * _S364 * _S364, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_7 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S365 : f32 = dot(ggx_n_0, v_4);
    var _S366 : f32 = dot(n_i_3, ggx_n_0);
    var _S367 : f32 = eta_i_3 / eta_o_3;
    var _S368 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S367))));
    var _S369 : f32 = min(sqrt(material_7.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S370 : f32 = _S369 * _S369;
    var _S371 : f32 = (1.0f + _S369) / (1.0f - _S369);
    var _S372 : f32 = abs(_S365);
    var _S373 : bool = eta_i_3 > eta_o_3;
    var sheen_component_0 : f32;
    if(_S373)
    {
        sheen_component_0 = _S371;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S373)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S371;
    }
    var _S374 : f32 = fresnel(_S372, sheen_component_0, visible_1);
    var _S375 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S365 * _S365)) >= (eta_o_3 * eta_o_3);
    var _S376 : vec3<f32>;
    if(_S375)
    {
        _S376 = vec3<f32>(1.0f);
    }
    else
    {
        var _S377 : vec3<f32> = material_7.specular_tint * vec3<f32>(_S370);
        _S376 = _S377 + (vec3<f32>(1.0f) - _S377) * vec3<f32>((_S374 - _S370)) / vec3<f32>((1.0f - _S370));
    }
    var _S378 : vec3<f32> = vec3<f32>(1.0f);
    var _S379 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S380 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S381 : vec3<f32> = vec3<f32>(1.0f) - material_7.sheen * vec3<f32>(_S380);
        var _S382 : f32 = rgb_to_greyscale(material_7.sheen);
        var _S383 : f32 = _S382 * _S380;
        var _S384 : vec3<f32> = material_7.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S381;
        sheen_component_0 = _S383;
        sheen_2 = _S384;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S378;
        sheen_component_0 = 0.0f;
        sheen_2 = _S379;
        view_1 = _S379;
    }
    var _S385 : vec3<f32> = (mix((_S376), (material_7.albedo), (material_7.metallic)));
    var F_1 : vec3<f32> = _S385 * scale_0;
    var _S386 : f32 = rgb_to_greyscale(F_1);
    var _S387 : f32 = 1.0f - material_7.metallic;
    var _S388 : vec3<f32> = vec3<f32>(1.0f) - _S376;
    var _S389 : vec3<f32> = vec3<f32>(((1.0f - material_7.transmission) * _S387)) * _S388 * scale_0;
    var _S390 : vec3<f32> = vec3<f32>((material_7.transmission * _S387)) * _S388 * scale_0;
    var _S391 : f32 = max(_S386, 0.0f);
    var _S392 : f32 = rgb_to_greyscale(_S389);
    var _S393 : f32 = max(_S392, 0.0f);
    var _S394 : f32 = rgb_to_greyscale(_S390);
    var _S395 : f32 = (sign((length(_S368))));
    var _S396 : f32 = max(_S394 * _S395, 0.0f);
    var _S397 : f32 = _S391 + _S393 + _S396;
    var _S398 : f32 = min(sheen_component_0, 1.0f);
    var _S399 : bool = sheen_component_0 > 0.0f;
    var _S400 : bool;
    if(_S399)
    {
        _S400 = !(_S397 > 0.0f);
    }
    else
    {
        _S400 = false;
    }
    var _S401 : f32 = select(_S398, 1.0f, _S400);
    var _S402 : f32 = (1.0f - _S401) / max(_S397, 0.0000152587890625f);
    var _S403 : f32 = _S393 * _S402;
    var _S404 : f32 = _S391 * _S402;
    var _S405 : f32 = _S396 * _S402;
    var _S406 : bool = (frame_2.alphas.x) > 0.0f;
    if(_S406)
    {
        var _S407 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S408 : f32 = anisotropicG1(_S407, frame_2.alphas);
        var _S409 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S410 : f32 = anisotropicD(_S409, frame_2.alphas);
        var _S411 : f32 = _S408 * _S410;
        visible_1 = _S411;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S365, _S366, _S368, F_1, _S386, 1.0f, _S389, _S390, _S403, _S404, _S405, 0.0f, sheen_2, _S401, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_8 : Material) -> f32
{
    var _S412 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S413 : f32 = rgb_to_greyscale(material_8.albedo);
    var _S414 : f32 = _S412 / (_S413 + _S412);
    var _S415 : bool = _S412 > 0.0f;
    var _S416 : f32 = select(0.0f, _S414, _S415);
    return _S416;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S417 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S418 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S419 : f32 = 1.0f - lobes_0.translucent_share;
    var _S420 : bool = n_i_dot_l_0 < 0.0f;
    var _S421 : f32 = select(_S419, lobes_0.translucent_share, _S420);
    var _S422 : f32 = _S418 * _S421;
    var _S423 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S424 : f32 = select(_S417, _S422, _S423);
    var _S425 : bool = n_i_dot_v_0 > 0.0f;
    var _S426 : f32 = select(0.0f, _S424, _S425);
    return _S426;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_9 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S427 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S428 : vec3<f32> = select(material_9.albedo, material_9.translucent, _S427);
    var _S429 : f32 = 1.0f - lobes_1.translucent_share;
    var _S430 : f32 = select(_S429, lobes_1.translucent_share, _S427);
    var _S431 : vec3<f32> = _S428 / vec3<f32>(_S430);
    var _S432 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S433 : vec3<f32> = select(material_9.albedo, _S431, _S432);
    return lobes_1.diffuse_weight * _S433 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S434 : f32 = alpha_4 * alpha_4;
    var _S435 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S434 + (1.0f - _S434) * n_dot_x_0 * n_dot_x_0));
    var _S436 : bool = alpha_4 > 0.0f;
    var _S437 : f32 = select(1.0f, _S435, _S436);
    return _S437;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S438 : f32 = alpha_5 * alpha_5;
    var _S439 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S438 * n_dot_h_1 * n_dot_h_1;
    return _S438 / max(3.14159274101257324f * _S439 * _S439, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S440 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S441 : f32 = _S440 * lobes_2.v_dot_h;
    var _S442 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S443 : f32 = _S441 * _S442 / n_i_dot_v_1;
    var _S444 : bool = alpha_6 > 0.0f;
    var _S445 : bool;
    if(_S444)
    {
        _S445 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S445 = false;
    }
    if(_S445)
    {
        _S445 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S445 = false;
    }
    if(_S445)
    {
        _S445 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S445 = false;
    }
    var _S446 : f32 = select(0.0f, _S443, _S445);
    var _S447 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S447)
    {
        var _S448 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S449 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S449)
        {
            _S445 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S445 = false;
        }
        if(_S445)
        {
            _S445 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S445 = false;
        }
        var _S450 : f32 = select(0.0f, _S448, _S445);
        pdf_h_0 = _S450;
    }
    else
    {
        pdf_h_0 = _S446;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S451 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S452 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S453 : f32 = lobes_3.p_refract * _S451 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S452 * _S452);
    var _S454 : bool = eta_i_5 != eta_o_5;
    var _S455 : bool;
    if(_S454)
    {
        _S455 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S455 = false;
    }
    var _S456 : f32 = select(0.0f, _S453, _S455);
    return _S456;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_10 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S457 : f32 = - dot(n_i_5, l_1);
    var _S458 : f32 = smithG1(alpha_8, max(_S457, 0.0f));
    var _S459 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S459)
    {
        var _S460 : vec3<f32> = ((-(n_i_5)));
        var _S461 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S460);
        var _S462 : f32 = anisotropicG1(_S461, lobes_4.alphas);
        G1_l_0 = _S462;
    }
    else
    {
        G1_l_0 = _S458;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_10.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S463 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S464 : bool = n_i_dot_l_2 > 0.0f;
    var _S465 : bool;
    if(_S464)
    {
        _S465 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S465 = false;
    }
    var _S466 : f32 = select(0.0f, _S463, _S465);
    return _S466;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_11 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S467 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S468 : f32 = dot(n_i_6, _S467);
    var _S469 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S470 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S471 : f32 = 1.0f / max(material_11.sheen_roughness, 0.05000000074505806f);
    var _S472 : f32 = 1.0f - _S468 * _S468;
    var _S473 : f32 = (2.0f + _S471) * pow(max(_S472, 0.0f), 0.5f * _S471) * 0.5f * 0.31830987334251404f / max(4.0f * (_S469 + _S470 - _S469 * _S470), 0.0000152587890625f);
    var _S474 : bool = (material_11.velvet) > 0.0f;
    var f_2 : f32;
    if(_S474)
    {
        var _S475 : f32 = max(material_11.sheen_roughness, 0.00999999977648258f);
        var _S476 : f32 = _S475 * _S475;
        var _S477 : f32 = max(_S472, 0.0000152587890625f);
        var _S478 : f32 = exp(- _S468 * _S468 / (_S477 * _S476)) / (3.14159274101257324f * _S476 * _S477 * _S477) * min(1.0f, 2.0f * _S468 * min(_S469, _S470) / max(abs(dot(_S467, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S469 * _S470, 0.0000152587890625f);
        f_2 = _S478;
    }
    else
    {
        f_2 = _S473;
    }
    return lobes_6.sheen * vec3<f32>((f_2 * _S469 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S479 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S480 : f32 = lobes_7.p_reflect * _S479 / (4.0f * lobes_7.v_dot_h);
    var _S481 : bool = _S479 > 0.0f;
    var _S482 : f32 = select(0.0f, _S480, _S481);
    return _S482;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_12 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S483 : f32 = dot(n_i_7, l_3);
    var _S484 : f32 = smithG1(alpha_12, max(_S483, 0.0f));
    var _S485 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S485)
    {
        var _S486 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S487 : f32 = anisotropicG1(_S486, lobes_8.alphas);
        G1_l_1 = _S487;
    }
    else
    {
        G1_l_1 = _S484;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S488 : vec3<f32> = ((-(in_dir_4)));
    var _S489 : f32 = dot(n_7, _S488);
    var _S490 : f32 = (sign((_S489)));
    var _S491 : vec3<f32> = n_7 * vec3<f32>(_S490);
    var _S492 : AnisotropicFrame = anisotropicFrame(material_13, _S491);
    var _S493 : f32 = dot(_S491, out_dir_2);
    var _S494 : f32 = material_13.roughness;
    var _S495 : f32 = _S494 * _S494;
    var _S496 : SheenProfile = sheenProfile(_S488, _S491, material_13);
    var _S497 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S498 : bool = _S497 > 0.0f;
    var _S499 : bool = (dot(n_7, out_dir_2) * _S489) < 0.0f;
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
        var _S500 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S500;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S501 : vec3<f32> = vec3<f32>(0.0f);
    var _S502 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S501, _S501, 0.0f, 0.0f, _S501, _S501, 0.0f, 0.0f, 0.0f, 0.0f, _S501, 0.0f, _S501, _S501, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S502;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S501;
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
        var _S503 : u32;
        if(i_0 == u32(3))
        {
            _S503 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S503 = u32(6);
            }
            else
            {
                _S503 = i_0;
            }
        }
        var _S504 : bool = _S503 == u32(0);
        var _S505 : bool;
        if(_S504)
        {
            _S505 = _S498;
        }
        else
        {
            _S505 = false;
        }
        var _S506 : bool;
        if(_S505)
        {
            _S506 = _S499;
        }
        else
        {
            _S506 = _S503 == u32(1);
        }
        var _S507 : bool = _S506 != refracted_1;
        if(_S507)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S508 : u32;
        if(_S503 == u32(6))
        {
            _S508 = u32(0);
        }
        else
        {
            if(_S503 == u32(4))
            {
                _S508 = u32(2);
            }
            else
            {
                _S508 = _S503;
            }
        }
        var _S509 : bool = _S508 != half_of_0;
        var half_of_1 : u32;
        if(_S509)
        {
            var _S510 : bool = _S508 == u32(0);
            if(_S510)
            {
                var _S511 : vec3<f32> = sampledHalf(in_dir_4, n_7, material_13, random_state_5, _S492);
                ggx_n_1 = _S511;
            }
            else
            {
                var _S512 : bool = _S508 == u32(1);
                if(_S512)
                {
                    var _S513 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S513;
                }
                else
                {
                    var _S514 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S514;
                }
            }
            var _S515 : vec3<f32> = ((-(in_dir_4)));
            var _S516 : BSDFLobes = bsdfLobes(in_dir_4, _S515, _S491, ggx_n_1, material_13, eta_i_8, eta_o_8, _S492, _S496);
            lobe_terms_0 = _S516;
            var _S517 : f32 = translucentShare(material_13);
            lobe_terms_0.translucent_share = _S517;
            half_of_1 = _S508;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S503)
        {
        case u32(0):
            {
                var _S518 : f32 = diffusePDF(_S493, 0.0f, abs(_S489), _S495, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S518;
                var _S519 : vec3<f32> = diffuseBSDF(out_dir_2, _S491, _S495, material_13, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S519;
            }
        case u32(1):
            {
                var _S520 : f32 = refractPDF(_S493, dot(out_dir_2, ggx_n_1), abs(_S489), _S495, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S520;
                var _S521 : vec3<f32> = refractBSDF(out_dir_2, _S491, _S495, material_13, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S521;
            }
        case u32(4):
            {
                var _S522 : f32 = sheenVelvetPDF(_S493, 0.0f, abs(_S489), _S495, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S522;
                var _S523 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S491, _S495, material_13, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S523;
            }
        default :
            {
                var _S524 : f32 = reflectPDF(_S493, 0.0f, abs(_S489), _S495, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S524;
                var _S525 : vec3<f32> = reflectBSDF(out_dir_2, _S491, _S495, material_13, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S525;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S501;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S526 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S526)
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
    var _S527 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S528 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S527, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S529 : bool = !competing_0;
    var _S530 : bool;
    if(_S529)
    {
        _S530 = true;
    }
    else
    {
        _S530 = (light_0.density) == 0.0f;
    }
    if(_S530)
    {
        return _S528 * light_0.radiance;
    }
    var _S531 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S531;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S532 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S532)
        {
            var _S533 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S533 * _S533)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S534 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S535 : vec2<u32> = _S534 - vec2<u32>(u32(1), u32(0));
    var _S536 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S537 : vec2<u32> = min(vec2<u32>(_S536 * vec2<f32>(_S535)), _S535 - vec2<u32>(u32(1)));
    var _S538 : vec4<f32> = (textureLoad(environment_cdf, (_S537), 0));
    var _S539 : f32 = _S538.y;
    var _S540 : u32 = _S535.x;
    var _S541 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S540, _S537.y)), 0));
    var _S542 : f32 = _S539 * _S541.y;
    return _S542 * f32(_S540 * _S535.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_2 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S543 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    var _S544 : vec3<f32> = BSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S543, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S545 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_4 : vec3<f32> = _S545;
    loop
    {
        if(i_6 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S546 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S546)
        {
            var _S547 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S547;
            var f_5 : vec3<f32> = f_4 + (*terms_0)[i_6];
            f_4 = f_5;
        }
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    return f_4;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_6 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_8 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(5)>;
    var pdfs_3 : array<f32, i32(5)>;
    var _S548 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S548;
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
    var _S549 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S549;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S550 : u32 = (low_0 + high_0) / u32(2);
        var _S551 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S550)), 0));
        var _S552 : bool = (_S551.x) > u_0;
        if(_S552)
        {
            high_0 = _S550;
        }
        else
        {
            var _S553 : u32 = _S550 + u32(1);
            low_0 = _S553;
        }
    }
    return low_0;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S554 : SkySample;
    _S554.dir = dir_7;
    _S554.radiance = radiance_2;
    _S554.color = color_2;
    _S554.random_state = random_state_9;
    return _S554;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S555 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S556 : bool = is_inside_3 != _S555;
    var _S557 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S558 : vec3<f32> = select(surface_3.smooth_n, _S557, _S556);
    var _S559 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S558, dir_8);
    var _S560 : vec3<f32> = (env_map_sample((dir_8)));
    var _S561 : vec3<f32> = (shadowTransmittance((_S559), (4.294967296e+09f)));
    return _S560 * _S561;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S562 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S563 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S564 : vec2<u32> = _S562 - _S563;
    var _S565 : Random = pcg(init_random_state_1);
    var _S566 : Random = pcg(_S565.state);
    var _S567 : Random = pcg(_S566.state);
    var _S568 : Random = pcg(_S567.state);
    var _S569 : u32 = _S564.x;
    var _S570 : u32 = searchCDF_0(vec2<u32>(_S569, u32(0)), vec2<u32>(u32(0), u32(1)), _S564.y, _S565.value);
    var _S571 : u32 = searchCDF_0(vec2<u32>(u32(0), _S570), _S563, _S569, _S566.value);
    var _S572 : vec2<f32> = (vec2<f32>(f32(_S571), f32(_S570)) + vec2<f32>(_S567.value, _S568.value)) / vec2<f32>(_S564) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S573 : f32 = _S572.y;
    var _S574 : f32 = sin(_S573);
    var _S575 : f32 = _S572.x;
    var _S576 : vec3<f32> = vec3<f32>(_S574 * cos(_S575), cos(_S573), _S574 * sin(_S575));
    var _S577 : f32 = environmentPdf_0(_S576);
    var _S578 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S576, surface_4, eta_2, is_inside_4, _S577, lobe_state_0);
    var _S579 : bool = !(_S577 > 0.0f);
    var _S580 : bool;
    if(_S579)
    {
        _S580 = true;
    }
    else
    {
        _S580 = (all((_S578 == vec3<f32>(0.0f))));
    }
    if(_S580)
    {
        var _S581 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S576, _S581, _S581, _S568.state);
    }
    var _S582 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S576);
    return SkySample_x24init_0(_S576, _S582, _S578 * _S582, _S568.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S583 : vec3<f32> = a_5 / b_1;
    var _S584 : vec3<f32> = vec3<f32>(0.0f);
    var _S585 : vec3<bool> = b_1 == _S584;
    var _S586 : vec3<f32> = select(_S583, _S584, _S585);
    return _S586;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S587 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S588 : u32 = (insertBits((_S587), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S588;
    candidate_0.f = f_6;
    return candidate_0;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S589 : f32 = rgb_to_greyscale(weight_0);
    var _S590 : bool = _S589 > 0.0f;
    var _S591 : bool;
    if(_S590)
    {
        _S591 = _S589 < 3.00000000549775576e+38f;
    }
    else
    {
        _S591 = false;
    }
    var _S592 : bool = !_S591;
    if(_S592)
    {
        return;
    }
    var _S593 : f32 = (*sel_0).w_sum + _S589;
    (*sel_0).w_sum = _S593;
    var _S594 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S594;
    var _S595 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S595.state;
    var _S596 : bool = (_S595.value * (*sel_0).w_sum) <= _S589;
    if(_S596)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S597 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S598 : bool = (_S597.x) > u32(1);
    var _S599 : bool;
    if(_S598)
    {
        var _S600 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S599 = (_S600.y) > u32(1);
    }
    else
    {
        _S599 = false;
    }
    return _S599;
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
    var _S601 : SampleBSDF;
    _S601.unit_direction = unit_direction_1;
    _S601.throughput = throughput_0;
    _S601.random_state = random_state_10;
    _S601.refracted = refracted_3;
    _S601.lobe = lobe_1;
    _S601.pdf = pdf_4;
    return _S601;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S602 : vec3<f32> = vec3<f32>(1.0f);
    var _S603 : SampleBSDF = SampleBSDF_x24init_0(_S602, _S602, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S603;
    var _S604 : Random = pcg(random_state_11);
    var _S605 : Random = pcg(_S604.state);
    sample_1.random_state = _S605.state;
    var _S606 : f32 = _S604.value;
    var _S607 : f32 = sqrt(max(0.0f, 1.0f - _S606 * _S606));
    var _S608 : f32 = 6.28318548202514648f * _S605.value;
    var _S609 : vec3<f32> = tangentToWorld(vec3<f32>(_S607 * cos(_S608), _S604.value, _S607 * sin(_S608)), n_i_8);
    sample_1.unit_direction = _S609;
    sample_1.lobe = u32(4);
    var _S610 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S610;
    var _S611 : f32 = sheenVelvetPDF(_S604.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S611;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S612 : f32 = sqrt(random_1_0);
    var _S613 : f32 = 6.28318548202514648f * random_2_0;
    var _S614 : f32 = _S612 * cos(_S613);
    var _S615 : f32 = _S612 * sin(_S613);
    var _S616 : f32 = sqrt(max(0.0f, 1.0f - _S614 * _S614 - _S615 * _S615));
    return vec3<f32>(_S614, _S616, _S615);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S617 : vec3<f32> = vec3<f32>(1.0f);
    var _S618 : SampleBSDF = SampleBSDF_x24init_0(_S617, _S617, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S618;
    var _S619 : Random = pcg(random_state_12);
    var _S620 : Random = pcg(_S619.state);
    sample_2.random_state = _S620.state;
    var _S621 : vec3<f32> = sampleCosWeightedHemisphere(_S619.value, _S620.value);
    var _S622 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S623 : f32 = _S621.y;
    var _S624 : f32 = - _S623;
    var _S625 : f32 = select(_S623, _S624, _S622);
    var _S626 : vec3<f32> = tangentToWorld(vec3<f32>(_S621.x, _S625, _S621.z), n_i_9);
    sample_2.unit_direction = _S626;
    sample_2.refracted = _S622;
    sample_2.lobe = u32(0);
    var _S627 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S627;
    var _S628 : f32 = diffusePDF(_S625, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S628;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S629 : vec3<f32> = vec3<f32>(1.0f);
    var _S630 : SampleBSDF = SampleBSDF_x24init_0(_S629, _S629, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S630;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S631 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S631;
    var _S632 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S632;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S633 : vec3<f32> = vec3<f32>(1.0f);
    var _S634 : SampleBSDF = SampleBSDF_x24init_0(_S633, _S633, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S634;
    var _S635 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S635;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S636 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S636;
    var _S637 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S637;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S638 : vec3<f32> = ((-(in_dir_9)));
    var _S639 : f32 = dot(n_8, _S638);
    var _S640 : f32 = (sign((_S639)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S640);
    var _S641 : f32 = abs(_S639);
    var _S642 : f32 = material_19.roughness;
    var _S643 : f32 = _S642 * _S642;
    var _S644 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S645 : SheenProfile = sheenProfile(_S638, n_i_12, material_19);
    var _S646 : vec3<f32> = sampleHalfVector(_S638, n_i_12, _S643, _S644, &(random_state_15));
    var _S647 : BSDFLobes = bsdfLobes(in_dir_9, _S638, n_i_12, _S646, material_19, eta_i_14, eta_o_14, _S644, _S645);
    var lobes_13 : BSDFLobes = _S647;
    var _S648 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S648;
    var _S649 : Random = pcg(random_state_15);
    random_state_15 = _S649.state;
    var _S650 : bool = (_S649.value) < (lobes_13.p_sheen_velvet);
    if(_S650)
    {
        var _S651 : SampleBSDF = sheenVelvetSample(n_i_12, _S641, _S643, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S651;
    }
    var _S652 : f32 = _S649.value - lobes_13.p_sheen_velvet;
    var _S653 : bool = _S652 < (lobes_13.p_diffuse);
    if(_S653)
    {
        var _S654 : SampleBSDF = diffuseSample(_S652, n_i_12, _S641, _S643, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S654;
    }
    var _S655 : bool = _S652 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S655)
    {
        var _S656 : SampleBSDF = refractSample(_S646, n_i_12, _S641, _S643, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S656;
    }
    var _S657 : SampleBSDF = reflectSample(in_dir_9, _S646, n_i_12, _S641, _S643, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S657;
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S658 : bool = pdf_5 <= 0.0f;
    var _S659 : bool;
    if(_S658)
    {
        _S659 = true;
    }
    else
    {
        var _S660 : bool = environmentMapped_0();
        _S659 = !_S660;
    }
    if(_S659)
    {
        return 1.0f;
    }
    var _S661 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S661);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S662 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S662.x, max(_S662.y, _S662.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S663 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S664 : bool = (_S663.x) > u32(1);
    var _S665 : bool;
    if(_S664)
    {
        var _S666 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S665 = (_S666.y) > u32(1);
    }
    else
    {
        _S665 = false;
    }
    if(_S665)
    {
        var _S667 : vec3<f32> = (env_map_sample((dir_10)));
        return _S667;
    }
    var _S668 : vec3<f32> = (uniforms_float.ambient);
    return _S668;
}

fn walk_0( dom_1 : Domain,  r_4 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S669 : vec3<f32> = vec3<f32>(0.0f);
    var _S670 : Shift = Shift_x24init_0(_S669, 0.0f);
    var _S671 : u32 = (extractBits((r_4.path), (u32(0)), (u32(5))));
    var _S672 : u32 = (extractBits((r_4.path), (u32(5)), (u32(5))));
    var _S673 : u32 = (extractBits((r_4.path), (u32(10)), (u32(2))));
    var _S674 : u32 = (extractBits((r_4.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S675 : bool = _S674 >= u32(3);
        var _S676 : u32 = select(u32(0), u32(1), _S675);
        var _S677 : u32 = _S671 + _S676;
        var _S678 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S677 > _S678;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S670;
    }
    var _S679 : u32 = _S672 - u32(1);
    var _S680 : bool = _S674 == u32(3);
    var _S681 : u32 = select(u32(0), u32(1), _S680);
    var _S682 : u32 = _S671 + _S681;
    var _S683 : bool = _S673 == u32(0);
    var _S684 : u32 = select(_S679, _S682, _S683);
    var _S685 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_4.rc.zw))), r_4.rc.x, r_4.rc.y, u32(0), 0.0f);
    var _S686 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S687 : Ray = Ray_x24init_0(dom_1.x1, _S686);
    var ray_2 : Ray = _S687;
    var hit_2 : Hit = dom_1.hit;
    var _S688 : vec3<f32> = vec3<f32>(1.0f);
    var _S689 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S669, _S669, _S669);
    var nee_vertex_0 : NEEVertex = _S689;
    var _S690 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S690;
    var _S691 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S669, 0.0f, vec4<u32>(u32(0)), _S669, _S669);
    var chain_0 : Reservoir = _S691;
    chain_0.seed = r_4.seed;
    is_inside_5 = false;
    var threshold_0 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S669;
    var reconnection_0 : vec3<f32> = _S669;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S688;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S692 : bool = (hit_2.is_point_light) == u32(1);
        var _S693 : bool;
        if(replay_0)
        {
            _S693 = _S673 == u32(1);
        }
        else
        {
            _S693 = false;
        }
        var _S694 : bool;
        if(_S693)
        {
            _S694 = b_2 == _S672;
        }
        else
        {
            _S694 = false;
        }
        var _S695 : bool;
        if(_S694)
        {
            var _S696 : bool = (hit_2.instance_index) != (_S685.instance_index);
            if(_S696)
            {
                _S695 = true;
            }
            else
            {
                _S695 = (hit_2.triangle_index) != (_S685.triangle_index);
            }
        }
        else
        {
            _S695 = false;
        }
        if(_S695)
        {
            return _S670;
        }
        var _S697 : Surface = Surface_x24init_0(_S669, _S669, 0.0f, Material_x24init_0(_S669, _S669, 0.0f, 0.0f, 0.0f, 0.0f, _S669, _S688, 1.0f, _S669, _S669, 0.5f, 0.0f, 0.0f, _S669, 0.0f), false, u32(0));
        var _S698 : bool = !_S692;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S698)
        {
            var _S699 : u32 = stream(r_4.seed, b_2);
            var _S700 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S699)));
            var surface_6 : Surface = facingRay_0(_S700, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S701 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S702 : vec3<f32> = throughput_2 * _S701;
                front_n_0 = _S702;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S703 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S704 : bool = b_2 == u32(0);
            if(_S704)
            {
                var _S705 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S705;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S706 : vec3<f32> = front_n_0;
            var _S707 : f32 = geometry_density_0;
            scatter_0 = _S703;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S707;
            surface_5 = surface_6;
            front_n_0 = _S700.smooth_n;
            throughput_3 = _S706;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S697;
            front_n_0 = _S669;
            throughput_3 = throughput_2;
        }
        var _S708 : bool;
        if(scatter_0)
        {
            _S708 = prev_0.rough;
        }
        else
        {
            _S708 = false;
        }
        var _S709 : bool;
        if(_S708)
        {
            _S709 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S709 = false;
        }
        var _S710 : Surface = surface_5;
        var _S711 : Surface = surface_5;
        var _S712 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S713 : vec2<f32> = vertexEta(_S710.material, _S712);
        var _S714 : bool;
        if(scatter_0)
        {
            var _S715 : u32 = (uniforms_uint.max_bounces);
            var _S716 : bool = b_2 >= _S715;
            if(_S716)
            {
                _S714 = true;
            }
            else
            {
                var _S717 : bool = neeDecision(_S710.material, _S712, _S713.x, _S713.y);
                _S714 = _S717;
            }
        }
        else
        {
            _S714 = false;
        }
        var _S718 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S719 : vec3<f32> = _S710.material.emissive * vec3<f32>(max(_S718, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S692)
        {
            var _S720 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S720;
        }
        else
        {
            emission_0 = _S719;
        }
        var _S721 : bool = !replay_0;
        var _S722 : bool;
        if(_S721)
        {
            _S722 = true;
        }
        else
        {
            _S722 = b_2 >= _S684;
        }
        var _S723 : bool;
        if(_S722)
        {
            var _S724 : f32 = rgb_to_greyscale(emission_0);
            _S723 = _S724 > 0.0f;
        }
        else
        {
            _S723 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S723)
        {
            var _S725 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S725);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S726 : bool;
        if(replay_0)
        {
            _S726 = _S673 == u32(1);
        }
        else
        {
            _S726 = false;
        }
        var _S727 : bool;
        if(_S726)
        {
            _S727 = b_2 > _S672;
        }
        else
        {
            _S727 = false;
        }
        var _S728 : bool;
        if(_S727)
        {
            _S728 = b_2 == _S671;
        }
        else
        {
            _S728 = false;
        }
        var _S729 : bool;
        if(_S728)
        {
            var _S730 : bool = _S674 == u32(1);
            if(_S730)
            {
                _S729 = true;
            }
            else
            {
                _S729 = _S674 == u32(2);
            }
        }
        else
        {
            _S729 = false;
        }
        if(_S729)
        {
            var _S731 : bool = _S692 != (_S674 == u32(2));
            if(_S731)
            {
                return _S670;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S732 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S733 : bool = _S732 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S734 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S735 : u32 = (insertBits((_S734), (u32(1)), (u32(10)), (u32(2))));
        var _S736 : u32 = (insertBits((_S735), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S737 : bool = prev_0.inside;
        var _S738 : u32 = select(u32(0), u32(1), _S737);
        var _S739 : u32 = (insertBits((_S736), (_S738), (u32(22)), (u32(1))));
        here_0.path = _S739;
        var _S740 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S740;
        var _S741 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S741;
        var _S742 : bool;
        if(replay_0)
        {
            _S742 = _S673 == u32(1);
        }
        else
        {
            _S742 = false;
        }
        var _S743 : bool;
        if(_S742)
        {
            _S743 = b_2 == _S672;
        }
        else
        {
            _S743 = false;
        }
        var _S744 : bool = b_2 == _S684;
        var _S745 : bool;
        if(_S744)
        {
            var _S746 : bool = !scatter_0;
            if(_S746)
            {
                _S745 = true;
            }
            else
            {
                var _S747 : bool = _S673 != u32(1);
                if(_S747)
                {
                    _S745 = _S673 != u32(3);
                }
                else
                {
                    _S745 = false;
                }
            }
        }
        else
        {
            _S745 = false;
        }
        var _S748 : bool;
        if(_S745)
        {
            _S748 = _S673 == u32(2);
        }
        else
        {
            _S748 = false;
        }
        var _S749 : bool;
        if(_S748)
        {
            _S749 = !_S709;
        }
        else
        {
            _S749 = false;
        }
        var _S750 : bool;
        if(_S749)
        {
            _S750 = _S674 != u32(4);
        }
        else
        {
            _S750 = false;
        }
        var _S751 : bool = _S672 == _S671;
        var _S752 : bool;
        if(_S751)
        {
            _S752 = _S674 == u32(0);
        }
        else
        {
            _S752 = false;
        }
        var _S753 : bool;
        if(_S752)
        {
            _S753 = (hit_2.instance_index) == (_S685.instance_index);
        }
        else
        {
            _S753 = false;
        }
        var _S754 : bool;
        if(_S753)
        {
            _S754 = (hit_2.triangle_index) == (_S685.triangle_index);
        }
        else
        {
            _S754 = false;
        }
        var _S755 : bool;
        if(_S754)
        {
            _S755 = _S709;
        }
        else
        {
            _S755 = false;
        }
        var _S756 : bool = select(_S750, _S755, _S743);
        var _S757 : bool;
        if(_S714)
        {
            _S757 = select(scatter_0, _S756, replay_0);
        }
        else
        {
            _S757 = false;
        }
        var _S758 : TreeSample = TreeSample_x24init_0(_S669, _S669, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S757)
        {
            var _S759 : Surface = surface_5;
            var _S760 : bool = isTranslucent_0(_S710.material);
            var _S761 : u32 = stream(r_4.seed, b_2 + u32(64));
            var _S762 : TreeSample = sampleLightTree_0(ray_2.origin, _S711.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S760, _S761);
            var _S763 : bool = (any(((_S762.radiance) != _S669)));
            if(_S763)
            {
                var _S764 : f32 = _S713.x;
                var _S765 : f32 = _S713.y;
                var _S766 : u32 = (uniforms_uint.max_bounces);
                var _S767 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S762, _S711.smooth_n, _S759.geometry_n, _S710.material, _S764, _S765, b_2 < _S766, surface_5.random_state);
                lit_0 = _S767;
            }
            else
            {
                lit_0 = _S669;
            }
            light_1 = _S762;
        }
        else
        {
            light_1 = _S758;
            lit_0 = _S669;
        }
        var _S768 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S769 : bool;
        var _S770 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S743)
        {
            var _S771 : bool = !_S709;
            if(_S771)
            {
                return _S670;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S751)
            {
                _S768 = _S674 == u32(1);
            }
            else
            {
                _S768 = false;
            }
            if(_S768)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S751)
            {
                wrong_side_0 = _S674 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S772 : bool = !_S714;
                if(_S772)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S773 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S773 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S670;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S751)
            {
                refracted_4 = _S674 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S774 : bool = !_S714;
                if(_S774)
                {
                    return _S670;
                }
                var _S775 : f32 = environmentPdf_0(r_4.dir);
                var _S776 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S713, is_inside_5, _S775, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S776 * r_4.radiance / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S777 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S778 : bool = _S714 != (_S777 == u32(1));
            if(_S778)
            {
                return _S670;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S768 = _S744;
            }
            else
            {
                _S768 = false;
            }
            if(_S768)
            {
                var _S779 : bool = !scatter_0;
                if(_S779)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S780 : bool = _S673 != u32(1);
                    if(_S780)
                    {
                        wrong_side_0 = _S673 != u32(3);
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
                var _S781 : bool = _S673 == u32(2);
                if(_S781)
                {
                    _S693 = _S714;
                }
                else
                {
                    _S693 = false;
                }
                if(_S693)
                {
                    _S693 = !_S709;
                }
                else
                {
                    _S693 = false;
                }
                if(_S693)
                {
                    _S693 = _S674 == u32(4);
                }
                else
                {
                    _S693 = false;
                }
                if(_S693)
                {
                    var _S782 : u32 = stream(r_4.seed, b_2 + u32(256));
                    var _S783 : SkySample = sampleSky_0(ray_2, surface_5, _S713, is_inside_5, _S782, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S783.color, 1.0f);
                }
                if(_S781)
                {
                    is_inside_5 = _S714;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S709;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S784 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S785 : bool = !(_S784 > 0.0f);
                    if(_S785)
                    {
                        return _S670;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S683)
                {
                    is_inside_5 = _S674 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S692;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S683)
                {
                    is_inside_5 = _S674 == u32(1);
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
                    is_inside_5 = !_S709;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S670;
            }
            else
            {
                if(_S721)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S786 : bool = b_2 > u32(0);
                    if(_S786)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S733)
                        {
                            var _S787 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S787;
                        }
                        else
                        {
                            if(_S709)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S788 : vec3<f32> = throughput_3 * emission_1;
                        var _S789 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S788);
                        offer(&((*sel_1)), _S789, _S788 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S714)
                    {
                        var _S790 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S733)
                        {
                            var _S791 : vec3<f32> = safeDivide(_S790, chain_throughput_0);
                            candidate_3.radiance = _S791;
                        }
                        else
                        {
                            if(_S709)
                            {
                                candidate_3 = here_0;
                                var _S792 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S792;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S793 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S794 : u32 = (insertBits((_S793), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S794;
                            }
                        }
                        var _S795 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S790);
                        offer(&((*sel_1)), _S795, _S790 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S714)
                    {
                        var _S796 : bool = environmentMapped_0();
                        _S769 = _S796;
                    }
                    else
                    {
                        _S769 = false;
                    }
                    if(_S769)
                    {
                        var _S797 : u32 = (uniforms_uint.max_bounces);
                        _S770 = b_2 < _S797;
                    }
                    else
                    {
                        _S770 = false;
                    }
                    if(_S770)
                    {
                        var _S798 : u32 = stream(r_4.seed, b_2 + u32(256));
                        var _S799 : SkySample = sampleSky_0(ray_2, surface_5, _S713, is_inside_5, _S798, surface_5.random_state);
                        var _S800 : vec3<f32> = throughput_3 * _S799.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S733)
                        {
                            var _S801 : vec3<f32> = safeDivide(_S800, chain_throughput_0);
                            candidate_4.radiance = _S801;
                        }
                        else
                        {
                            if(_S709)
                            {
                                candidate_4 = here_0;
                                var _S802 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S802;
                                candidate_4.dir = _S799.dir;
                                candidate_4.radiance = _S799.radiance;
                            }
                            else
                            {
                                var _S803 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S804 : u32 = (insertBits((_S803), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S804;
                            }
                        }
                        var _S805 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S800);
                        offer(&((*sel_1)), _S805, _S800 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S806 : bool;
        var _S807 : bool;
        var straight_0 : bool;
        var _S808 : bool;
        var _S809 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S768 = _S744;
            }
            else
            {
                _S768 = false;
            }
            var _S810 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S811 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S812 : u32 = select(_S810, _S811, _S743);
            var refracted_5 : bool = _S812 == u32(1);
            var _S813 : SampleBSDF = SampleBSDF_x24init_0(_S669, _S669, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S813;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S768)
            {
                var _S814 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S815 : bool = is_inside_5 != (_S814 == u32(1));
                if(_S815)
                {
                    return _S670;
                }
                var _S816 : bool = _S673 == u32(1);
                if(_S816)
                {
                    var _S817 : vec3<f32> = (hitPosition((_S685)));
                    dir_11 = _S817;
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
                    var _S818 : bool = isTranslucent_0(_S710.material);
                    if(_S818)
                    {
                        wrong_side_0 = _S812 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S819 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S820 : vec3<f32> = select(r_4.dir, _S819, _S816);
                        refracted_4 = (dot(_S711.smooth_n, _S820) * _S712) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S816)
                {
                    var _S821 : vec3<f32> = ray_2.origin;
                    var _S822 : Surface = surface_5;
                    var _S823 : vec3<f32> = (vec3<f32>(0) - _S711.smooth_n);
                    var _S824 : bool = is_inside_5 != refracted_4;
                    var _S825 : vec3<f32> = select(_S711.smooth_n, _S823, _S824);
                    var _S826 : vec3<f32> = (normalize((dir_11 - (_S821 + vec3<f32>(_S822.geometry_offset) * _S825))));
                    reconnection_1 = _S826;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S827 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S827)
                {
                    return _S670;
                }
                var _S828 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S812;
                wrong_side_0 = false;
                reconnection_1 = _S828;
            }
            else
            {
                var _S829 : bool = !_S743;
                if(_S829)
                {
                    var _S830 : f32 = _S713.x;
                    var _S831 : f32 = _S713.y;
                    var _S832 : vec2<f32> = vec2<f32>(0.0f);
                    var _S833 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S711.smooth_n, _S710.material, _S830, _S831, surface_5.random_state, _S832);
                    var bsdf_sampled_0 : SampleBSDF = _S833;
                    var _S834 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S710.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S835 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S834.geometry_n, _S710.material, _S830, _S831, bsdf_sampled_0.random_state, _S832);
                        bsdf_sampled_0.unit_direction = _S835.unit_direction;
                        bsdf_sampled_0.refracted = _S835.refracted;
                        bsdf_sampled_0.throughput = _S835.throughput;
                        bsdf_sampled_0.lobe = _S835.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S836 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S834.geometry_n))) * _S834.geometry_n;
                            bsdf_sampled_0.unit_direction = _S836;
                        }
                    }
                    var _S837 : u32 = bsdf_sampled_0.lobe;
                    var _S838 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S839 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S840 : f32 = bsdf_sampled_0.pdf;
                    var _S841 : f32 = select(_S840, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S841;
                    dir_11 = _S838;
                    lobe_index_0 = _S837;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S839;
                }
                else
                {
                    dir_11 = r_4.dir;
                    lobe_index_0 = _S812;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S768)
            {
                _S769 = true;
            }
            else
            {
                _S769 = _S743;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S769)
            {
                var _S842 : vec3<f32> = ray_2.unit_direction;
                var _S843 : f32 = (sign((_S712)));
                var _S844 : vec3<f32> = _S711.smooth_n * vec3<f32>(_S843);
                var _S845 : f32 = dot(_S844, dir_11);
                var _S846 : f32 = _S710.material.roughness;
                var _S847 : f32 = _S846 * _S846;
                var _S848 : AnisotropicFrame = anisotropicFrame(_S710.material, _S844);
                var _S849 : vec3<f32> = ((-(_S842)));
                var _S850 : SheenProfile = sheenProfile(_S849, _S844, _S710.material);
                var _S851 : vec3<f32> = reflectedHalf(_S842, dir_11);
                var _S852 : bool = lobe_index_0 == u32(1);
                if(_S852)
                {
                    var _S853 : vec3<f32> = refractedHalf(_S842, dir_11, _S711.smooth_n, _S713.x, _S713.y);
                    throughput_6 = _S853;
                }
                else
                {
                    throughput_6 = _S851;
                }
                var _S854 : bool = lobe_index_0 == u32(0);
                if(_S854)
                {
                    _S770 = true;
                }
                else
                {
                    _S770 = lobe_index_0 == u32(6);
                }
                if(_S770)
                {
                    var _S855 : vec3<f32> = sampledHalf(_S842, _S711.smooth_n, _S710.material, surface_5.random_state, _S848);
                    throughput_7 = _S855;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S856 : vec3<f32> = ((-(_S842)));
                var _S857 : f32 = _S713.x;
                var _S858 : f32 = _S713.y;
                var _S859 : BSDFLobes = bsdfLobes(_S842, _S856, _S844, throughput_7, _S710.material, _S857, _S858, _S848, _S850);
                var lobe_terms_1 : BSDFLobes = _S859;
                var _S860 : f32 = translucentShare(_S710.material);
                lobe_terms_1.translucent_share = _S860;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S861 : f32 = diffusePDF(_S845, 0.0f, abs(_S712), _S847, lobe_terms_1, _S857, _S858);
                        var _S862 : vec3<f32> = diffuseBSDF(dir_11, _S844, _S847, _S710.material, lobe_terms_1);
                        density_5 = _S861;
                        chain_throughput_1 = _S862;
                    }
                case u32(1):
                    {
                        var _S863 : f32 = refractPDF(_S845, dot(dir_11, throughput_7), abs(_S712), _S847, lobe_terms_1, _S857, _S858);
                        var _S864 : vec3<f32> = refractBSDF(dir_11, _S844, _S847, _S710.material, lobe_terms_1);
                        density_5 = _S863;
                        chain_throughput_1 = _S864;
                    }
                case u32(4):
                    {
                        var _S865 : f32 = sheenVelvetPDF(_S845, 0.0f, abs(_S712), _S847, lobe_terms_1, _S857, _S858);
                        var _S866 : vec3<f32> = sheenVelvetBSDF(dir_11, _S844, _S847, _S710.material, lobe_terms_1);
                        density_5 = _S865;
                        chain_throughput_1 = _S866;
                    }
                default :
                    {
                        var _S867 : f32 = reflectPDF(_S845, 0.0f, abs(_S712), _S847, lobe_terms_1, _S857, _S858);
                        var _S868 : vec3<f32> = reflectBSDF(dir_11, _S844, _S847, _S710.material, lobe_terms_1);
                        density_5 = _S867;
                        chain_throughput_1 = _S868;
                    }
                }
                var _S869 : bool = density_5 > 0.0f;
                if(_S869)
                {
                    var _S870 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, surface_5.random_state, _S852, lobe_index_0, density_5);
                    lobe_2 = _S870;
                }
            }
            var _S871 : bool = lobe_index_0 == u32(0);
            if(_S871)
            {
                _S770 = true;
            }
            else
            {
                _S770 = lobe_index_0 == u32(4);
            }
            if(_S770)
            {
                _S806 = true;
            }
            else
            {
                _S806 = lobe_index_0 == u32(6);
            }
            var _S872 : bool = !_S806;
            if(_S872)
            {
                var _S873 : bool = (_S710.material.roughness) == 0.0f;
                if(_S873)
                {
                    _S807 = true;
                }
                else
                {
                    var _S874 : bool = lobe_index_0 == u32(1);
                    if(_S874)
                    {
                        _S807 = (_S713.x) == (_S713.y);
                    }
                    else
                    {
                        _S807 = false;
                    }
                }
            }
            else
            {
                _S807 = false;
            }
            var _S875 : bool = lobe_index_0 == u32(1);
            if(_S875)
            {
                straight_0 = (_S710.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S876 : bool = isTranslucent_0(_S710.material);
            if(_S876)
            {
                _S808 = _S871;
            }
            else
            {
                _S808 = false;
            }
            if(_S808)
            {
                _S809 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S809 = false;
            }
            var _S877 : bool;
            if(_S714)
            {
                _S877 = !_S807;
            }
            else
            {
                _S877 = false;
            }
            var _S878 : bool;
            if(_S877)
            {
                _S878 = !wrong_side_0;
            }
            else
            {
                _S878 = false;
            }
            var _S879 : bool;
            if(_S878)
            {
                var _S880 : f32 = lobe_2.pdf;
                var _S881 : vec3<f32> = ray_2.origin;
                var _S882 : bool = isTranslucent_0(_S710.material);
                var _S883 : vec3<f32> = select(_S711.smooth_n, _S669, _S882);
                var _S884 : vec3<f32> = ray_2.origin;
                var _S885 : Surface = surface_5;
                var _S886 : vec3<f32> = (vec3<f32>(0) - _S711.smooth_n);
                var _S887 : vec3<f32> = select(_S711.smooth_n, _S886, _S809);
                var _S888 : NEEVertex = NEEVertex_x24init_0(false, _S880, _S881, _S883, _S884 + vec3<f32>(_S885.geometry_offset) * _S887);
                nee_vertex_0 = _S888;
            }
            else
            {
                var _S889 : bool = lobe_index_0 != u32(1);
                if(_S889)
                {
                    _S879 = true;
                }
                else
                {
                    _S879 = (_S713.x) != (_S713.y);
                }
                if(_S879)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S890 : bool = (lobe_2.pdf) > 0.0f;
            if(_S890)
            {
                if(_S806)
                {
                    _S879 = true;
                }
                else
                {
                    _S879 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S879 = false;
            }
            var _S891 : bool = (lobe_2.pdf) > 0.0f;
            var _S892 : bool;
            if(_S891)
            {
                if(_S806)
                {
                    _S892 = true;
                }
                else
                {
                    _S892 = (_S710.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S892 = false;
            }
            var _S893 : bool;
            if(_S743)
            {
                var _S894 : bool = !_S879;
                if(_S894)
                {
                    return _S670;
                }
                var _S895 : bool = _S674 != u32(1);
                if(_S895)
                {
                    _S893 = _S674 != u32(2);
                }
                else
                {
                    _S893 = false;
                }
                if(_S893)
                {
                    var _S896 : f32 = lobe_2.pdf;
                    var _S897 : f32 = select(0.0f, _S896, _S714);
                    var _S898 : f32 = escapeWeight_0(_S897, r_4.dir);
                    if(_S751)
                    {
                        is_inside_5 = _S680;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S899 : f32 = select(1.0f, _S898, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S899) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S900 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S901 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S900;
                density_5 = _S901;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S893 = b_2 <= _S684;
            }
            else
            {
                _S893 = false;
            }
            var _S902 : bool;
            if(_S893)
            {
                _S902 = _S709;
            }
            else
            {
                _S902 = false;
            }
            var _S903 : bool;
            if(_S902)
            {
                _S903 = _S879;
            }
            else
            {
                _S903 = false;
            }
            var _S904 : bool;
            if(_S903)
            {
                _S904 = true;
            }
            else
            {
                if(_S768)
                {
                    _S904 = !_S892;
                }
                else
                {
                    _S904 = false;
                }
            }
            if(_S904)
            {
                return _S670;
            }
            if(_S768)
            {
                var _S905 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S906 : f32 = lobe_2.pdf;
                throughput_7 = _S905;
                survival_probability_0 = _S906;
            }
            else
            {
                var _S907 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S669);
                throughput_7 = _S907;
                survival_probability_0 = density_5;
            }
            var _S908 : bool;
            if(_S721)
            {
                _S908 = !_S733;
            }
            else
            {
                _S908 = false;
            }
            var _S909 : bool;
            if(_S908)
            {
                _S909 = _S709;
            }
            else
            {
                _S909 = false;
            }
            var _S910 : bool;
            if(_S909)
            {
                _S910 = _S879;
            }
            else
            {
                _S910 = false;
            }
            if(_S910)
            {
                chain_0 = here_0;
                var _S911 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S912 : u32 = select(u32(0), u32(1), _S714);
                var _S913 : u32 = (insertBits((_S911), (_S912), (u32(21)), (u32(1))));
                chain_0.path = _S913;
                var _S914 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S914;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S915 : Vertex = Vertex_x24init_0(_S892, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S915;
            var _S916 : f32 = lobe_2.pdf;
            var _S917 : bool;
            if(_S875)
            {
                _S917 = (_S713.x) == (_S713.y);
            }
            else
            {
                _S917 = false;
            }
            var _S918 : f32 = select(_S916, sky_pdf_0, _S917);
            var _S919 : bool;
            if(refracted_4)
            {
                _S919 = !_S809;
            }
            else
            {
                _S919 = false;
            }
            var is_inside_6 : bool;
            if(_S919)
            {
                var _S920 : bool = !is_inside_5;
                is_inside_6 = _S920;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S921 : Surface = surface_5;
            var _S922 : f32 = select(_S921.geometry_offset, 0.0f, straight_0);
            var _S923 : vec3<f32> = (vec3<f32>(0) - _S711.smooth_n);
            var _S924 : bool = is_inside_6 != _S809;
            var _S925 : vec3<f32> = select(_S711.smooth_n, _S923, _S924);
            var _S926 : vec3<f32> = ray_2.origin + vec3<f32>(_S922) * _S925;
            ray_2.origin = _S926;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S918;
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
        if(_S721)
        {
            if(_S692)
            {
                var _S927 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S928 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S929 : bool = _S928 == u32(1);
                if(_S929)
                {
                    var _S930 : vec3<f32> = safeDivide(_S927, chain_throughput_0);
                    candidate_5.radiance = _S930;
                }
                var _S931 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S927);
                offer(&((*sel_1)), _S931, _S927 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S692)
            {
                _S768 = true;
            }
            else
            {
                _S768 = scatter_0;
            }
            if(_S768)
            {
                var _S932 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S932;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S933 : u32 = stream(r_4.seed, b_2 + u32(128));
            var _S934 : Random = pcg(_S933);
            var _S935 : bool = survival_probability_0 < (_S934.value);
            if(_S935)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S936 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S936;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S937 : f32 = density_5 * survival_probability_0;
            density_2 = _S937;
        }
        else
        {
            density_2 = density_5;
        }
        var _S938 : Ray = ray_2;
        var _S939 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S768 = _S744;
        }
        else
        {
            _S768 = false;
        }
        if(_S768)
        {
            wrong_side_0 = _S673 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S940 : f32 = select(4.294967296e+09f, _S939, wrong_side_0);
        var _S941 : Hit;
        if(straight_0)
        {
            _S941 = hit_2;
        }
        else
        {
            _S941 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S942 : Hit = (traverseInstanceBVH((_S938), (_S698), (_S940), (_S941)));
        hit_2 = _S942;
        if(replay_0)
        {
            refracted_4 = _S744;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S769 = _S673 == u32(1);
        }
        else
        {
            _S769 = false;
        }
        if(_S769)
        {
            _S770 = (hit_2.instance_index) == (_S685.instance_index);
        }
        else
        {
            _S770 = false;
        }
        if(_S770)
        {
            _S806 = (hit_2.triangle_index) == (_S685.triangle_index);
        }
        else
        {
            _S806 = false;
        }
        if(_S806)
        {
            hit_2.uv = _S685.uv;
            var _S943 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S943;
        }
        if(replay_0)
        {
            _S807 = _S744;
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
        {
            _S808 = _S673 == u32(3);
        }
        else
        {
            _S808 = false;
        }
        if(_S808)
        {
            _S809 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S809 = false;
        }
        if(_S809)
        {
            return _S670;
        }
        var _S944 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S944)
        {
            var _S945 : bool = !nee_vertex_0.none;
            var _S946 : f32 = select(0.0f, sky_pdf_0, _S945);
            var _S947 : f32 = escapeWeight_0(_S946, ray_2.unit_direction);
            var _S948 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S949 : vec3<f32> = throughput_2 * _S948;
            if(replay_0)
            {
                if(_S744)
                {
                    is_inside_5 = _S673 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S949 * vec3<f32>(_S947) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
                }
                if(_S683)
                {
                    is_inside_5 = _S680;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S671;
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
                    return Shift_x24init_0(_S949 * vec3<f32>(_S947), 1.0f);
                }
                return _S670;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S950 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S951 : bool = _S950 == u32(1);
            if(_S951)
            {
                var _S952 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S953 : bool = _S952 == b_2;
                var _S954 : f32 = select(_S947, 1.0f, _S953);
                var _S955 : vec3<f32> = safeDivide(_S949 * vec3<f32>(_S954), chain_throughput_0);
                candidate_6.radiance = _S955;
            }
            else
            {
                var _S956 : bool = prev_0.rough;
                if(_S956)
                {
                    var _S957 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S958 : u32 = (insertBits((_S957), (u32(3)), (u32(10)), (u32(2))));
                    var _S959 : u32 = (insertBits((_S958), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S960 : bool = prev_0.inside;
                    var _S961 : u32 = select(u32(0), u32(1), _S960);
                    var _S962 : u32 = (insertBits((_S959), (_S961), (u32(22)), (u32(1))));
                    candidate_6.path = _S962;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S963 : vec3<f32> = _S949 * vec3<f32>(_S947);
            var _S964 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S963);
            offer(&((*sel_1)), _S964, _S963 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S965 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S965;
        var _S966 : u32 = b_2 + u32(1);
        b_2 = _S966;
    }
    return _S670;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S967 : vec3<f32> = vec3<f32>(0.0f);
    var _S968 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S967, 0.0f, vec4<u32>(u32(0)), _S967, _S967), 0.0f, _S967, u32(0));
    var sel_2 : Selection = _S968;
    var _S969 : bool = (r_5.w) <= 0.0f;
    if(_S969)
    {
        return Shift_x24init_0(_S967, 0.0f);
    }
    var _S970 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S970;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S971 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S971;
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
        var _S972 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S973 : u32 = (_S972 + u32(63)) / u32(64);
        var _S974 : bool = group_0 < _S973;
        if(_S974)
        {
            var _S975 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S976 : bool = _S975 < _S972;
            if(_S976)
            {
                var _S977 : u32 = (queued_shifts[(u32(83) + start_4 + _S975)]);
                return _S977;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S973;
        var start_5 : u32 = start_4 + _S972;
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
    var _S978 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S979 : u32 = t_5;
        var _S980 : bool = (bins_1[t_5]) < u32(40);
        if(_S980)
        {
            var _S981 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S979]]), u32(1));
            slots_0[t_5] = _S981;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S982 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S982)
    {
        var _S983 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S984 : bool = _S983 > u32(0);
        if(_S984)
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
                var _S985 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S985;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S986 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S983)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S986;
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
        var _S987 : u32 = t_5;
        var _S988 : bool = (bins_1[t_5]) < u32(40);
        if(_S988)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S987]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S989 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S989)
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
            var _S990 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S990 + u32(63)) / u32(64);
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
    var _S991 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S992 : vec2<f32> = vec2<f32>(0.5f);
    var _S993 : vec2<f32> = _S991.xy / vec2<f32>(_S991.z) * _S992 + _S992;
    var _S994 : vec2<f32> = vec2<f32>(_S993.x, 1.0f - _S993.y);
    var _S995 : vec2<u32> = (uniforms_uint.render_size);
    return _S994 * vec2<f32>(_S995);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S996 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S997 : bool;
    if(_S996)
    {
        var _S998 : vec2<u32> = (uniforms_uint.render_size);
        _S997 = (all((q_0 < vec2<i32>(_S998))));
    }
    else
    {
        _S997 = false;
    }
    if(_S997)
    {
        var _S999 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S997 = (bitcast<f32>((_S999.w))) > 0.0f;
    }
    else
    {
        _S997 = false;
    }
    return _S997;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S1000 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S1001 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1002 : vec2<f32> = project_0(_S1000, _S1001, dom_3.x1);
    var _S1003 : vec2<i32> = vec2<i32>(floor(_S1002));
    var _S1004 : bool = previousValid_0(_S1003);
    var _S1005 : bool = !_S1004;
    if(_S1005)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1006 : Domain = (previousDomain((_S1003)));
    var _S1007 : bool = (_S1006.hit.instance_index) == (dom_3.hit.instance_index);
    var _S1008 : bool;
    if(_S1007)
    {
        var _S1009 : f32 = distance(_S1006.x1, dom_3.x1);
        var _S1010 : f32 = dom_3.hit.distance * 8.0f;
        var _S1011 : vec2<u32> = (uniforms_uint.render_size);
        _S1008 = _S1009 <= (_S1010 / f32(_S1011.x));
    }
    else
    {
        _S1008 = false;
    }
    if(_S1008)
    {
        return _S1003;
    }
    var _S1012 : vec2<f32> = vec2<f32>(p_9 + _S1003) + vec2<f32>(1.0f);
    var _S1013 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S1014 : vec3<f32> = (uniforms_float.camera_position);
    var _S1015 : vec2<f32> = project_0(_S1013, _S1014, _S1006.x1);
    var _S1016 : vec2<i32> = vec2<i32>(floor(_S1012 - _S1015));
    var _S1017 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1018 : bool = previousValid_0(_S1016);
    var _S1019 : vec2<i32> = select(_S1017, _S1016, _S1018);
    return _S1019;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S1020 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S1021 : bool;
    if(_S1020)
    {
        _S1021 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S1021 = false;
    }
    if(_S1021)
    {
        _S1021 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S1021 = false;
    }
    if(_S1021)
    {
        _S1021 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S1021 = false;
    }
    return _S1021;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1022 : vec3<f32> = vec3<f32>(0.0f);
    var _S1023 : Domain = Domain_x24init_0(_S1022, _S1022, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1023;
    var _S1024 : bool = t_8 > u32(1);
    var _S1025 : bool;
    if(_S1024)
    {
        _S1025 = true;
    }
    else
    {
        var _S1026 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1025 = !_S1026;
    }
    if(_S1025)
    {
        return false;
    }
    var _S1027 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1028 : bool = (_S1027.x) < i32(0);
    if(_S1028)
    {
        return false;
    }
    var _S1029 : bool = t_8 == u32(0);
    if(_S1029)
    {
        var _S1030 : Reservoir = (loadReservoir(reservoir_prev, (_S1027)));
        var _S1031 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1030);
        (*job_2) = _S1031;
    }
    else
    {
        var _S1032 : Domain = (previousDomain((_S1027)));
        var _S1033 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1034 : ShiftJob = ShiftJob_x24init_0(_S1032, _S1033);
        (*job_2) = _S1034;
    }
    var _S1035 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1035)
    {
        if(_S1029)
        {
            _S1025 = true;
        }
        else
        {
            var _S1036 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1025 = !_S1036;
        }
    }
    else
    {
        _S1025 = false;
    }
    return _S1025;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1037 : ptr<function, array<u32, i32(3)>>)
{
    var _S1038 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S1039 : vec3<f32> = vec3<f32>(0.0f);
        var _S1040 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1039, _S1039, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1039, 0.0f, vec4<u32>(u32(0)), _S1039, _S1039));
        var job_3 : ShiftJob = _S1040;
        var _S1041 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1041)
        {
            var _S1042 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1042;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1037) = bins_2;
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
        var _S1043 : u32 = t_11;
        var _S1044 : bool = (bins_3[t_11]) < u32(40);
        if(_S1044)
        {
            var _S1045 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1043]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1046 : bool = local_invocation_index_2 < u32(40);
    if(_S1046)
    {
        var _S1047 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1048 : bool = _S1047 > u32(0);
        if(_S1048)
        {
            var _S1049 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1047)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1050 : vec2<u32> = global_invocation_id_1.xy;
    var _S1051 : vec2<i32> = vec2<i32>(_S1050 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1052 : vec2<i32> = _S1051 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1053 : bool = (all((_S1052 >= vec2<i32>(i32(0)))));
        var _S1054 : bool;
        if(_S1053)
        {
            var _S1055 : vec2<u32> = (uniforms_uint.render_size);
            _S1054 = (all((_S1052 < vec2<i32>(_S1055))));
        }
        else
        {
            _S1054 = false;
        }
        if(_S1054)
        {
            var _S1056 : vec4<u32> = (textureLoad(reservoir_prev, (_S1052), (u32(0)), 0));
            var _S1057 : u32 = _S1056.x;
            var _S1058 : bool = (bitcast<f32>((_S1056.z))) > 0.0f;
            var _S1059 : u32 = select(u32(0), _S1057, _S1058);
            seed_2 = _S1059;
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
    var _S1060 : u32 = local_invocation_id_0.y;
    var _S1061 : u32 = local_invocation_id_0.x;
    var _S1062 : u32 = duplication_seeds_0[(_S1060 + u32(8)) * u32(24) + _S1061 + u32(8)];
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
            var _S1063 : bool = (duplication_seeds_0[(_S1060 + seed_2) * u32(24) + _S1061 + x_1]) == _S1062;
            var _S1064 : u32 = select(u32(0), u32(1), _S1063);
            var count_2 : u32 = count_1 + _S1064;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1065 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1066 : bool = _S1062 != u32(0);
    var _S1067 : f32 = select(0.0f, _S1065, _S1066);
    textureStore(duplication_out, (vec2<i32>(_S1050)), 0, (vec4<u32>((bitcast<u32>((_S1067))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1068 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1068;
    var _S1069 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1069;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1070 : f32 = rgb_to_greyscale(r_7.f);
    var _S1071 : f32 = sel_4.w_sum / _S1070;
    var _S1072 : bool = _S1070 > 0.0f;
    var _S1073 : f32 = select(0.0f, _S1071, _S1072);
    r_7.w = _S1073;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1074 : vec2<u32> = global_invocation_id_2.xy;
    var _S1075 : vec2<i32> = vec2<i32>(_S1074);
    var _S1076 : vec3<f32> = vec3<f32>(0.0f);
    var _S1077 : Domain = Domain_x24init_0(_S1076, _S1076, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1077;
    var _S1078 : bool = (currentDomain((_S1075), &(dom_5)));
    var _S1079 : bool = !_S1078;
    if(_S1079)
    {
        storeReservoir(reservoir_prev_out, (_S1075), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1076, 0.0f, vec4<u32>(u32(0)), _S1076, _S1076)), (dom_5.hit));
        var _S1080 : vec2<f32> = vec2<f32>(_S1074);
        var _S1081 : vec2<u32> = (uniforms_uint.render_size);
        var _S1082 : vec2<f32> = _S1080 / vec2<f32>(_S1081.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1083 : vec3<f32> = vec3<f32>(_S1082, 1.0f);
        var _S1084 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1085 : vec3<f32> = (normalize(((((_S1084) * (_S1083))))));
        var _S1086 : vec3<f32> = environment_0(_S1085);
        textureStore(compute_out, (_S1075), (u32(0)), (vec4<f32>(_S1086, 1.0f)));
        var _S1087 : u32 = (uniforms_uint.is_temporal);
        var _S1088 : bool = _S1087 == u32(1);
        if(_S1088)
        {
            textureStore(compute_out, (_S1075), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1089 : Reservoir = (loadReservoir(reservoir_temp, (_S1075)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1089.c;
    loop
    {
        var _S1090 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1090)
        {
        }
        else
        {
            break;
        }
        var _S1091 : vec2<i32> = partner_0(_S1075, t_13);
        var neighbor_0 : Domain = _S1077;
        var _S1092 : bool = (currentDomain((_S1091), &(neighbor_0)));
        if(_S1092)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1093 : vec4<u32> = (textureLoad(reservoir_temp, (_S1091), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1093.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1094 : f32 = _S1089.c / max(count_3, 1.0f);
    var _S1095 : f32 = rgb_to_greyscale(_S1089.f);
    var _S1096 : bool = count_3 == 0.0f;
    var _S1097 : f32 = select(0.0f, 1.0f, _S1096);
    var _S1098 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1076, 0.0f, vec4<u32>(u32(0)), _S1076, _S1076), 0.0f, _S1076, u32(0));
    var sel_5 : Selection = _S1098;
    var _S1099 : u32 = (uniforms_uint.frame);
    var _S1100 : u32 = hash(_S1099);
    var _S1101 : u32 = global_invocation_id_2.x;
    var _S1102 : vec2<u32> = (uniforms_uint.render_size);
    var _S1103 : u32 = stream(_S1100, _S1101 + _S1102.x * global_invocation_id_2.y);
    var _S1104 : u32 = stream(_S1103, u32(195));
    sel_5.random_state = _S1104;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1097;
    loop
    {
        var _S1105 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1105)
        {
        }
        else
        {
            break;
        }
        var _S1106 : vec2<i32> = partner_0(_S1075, t_13);
        var neighbor_dom_0 : Domain = _S1077;
        var _S1107 : bool = (currentDomain((_S1106), &(neighbor_dom_0)));
        if(_S1107)
        {
            var _S1108 : Reservoir = (loadReservoir(reservoir_temp, (_S1106)));
            var _S1109 : vec4<u32> = (textureLoad(shift_data, (_S1106), (t_13), 0));
            var _S1110 : vec4<f32> = (bitcast<vec4<f32>>((_S1109)));
            var _S1111 : vec4<u32> = (textureLoad(shift_data, (_S1075), (t_13), 0));
            var _S1112 : vec4<f32> = (bitcast<vec4<f32>>((_S1111)));
            var _S1113 : f32 = (_S1108.c + _S1094) / c_sum_0;
            var _S1114 : bool = _S1095 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1114)
            {
                var _S1115 : f32 = _S1113 * _S1094 * _S1095;
                var _S1116 : f32 = _S1094 * _S1095;
                var _S1117 : f32 = rgb_to_greyscale(_S1112.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1115 / (_S1116 + _S1108.c * _S1117);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1118 : f32 = rgb_to_greyscale(_S1108.f);
            var _S1119 : vec3<f32> = _S1110.xyz;
            var _S1120 : Shift = Shift_x24init_0(_S1119, _S1110.w);
            var _S1121 : f32 = _S1113 * _S1108.c * _S1118;
            var _S1122 : f32 = _S1108.c * _S1118;
            var _S1123 : f32 = rgb_to_greyscale(_S1119);
            offerShifted(&(sel_5), _S1108, _S1120, _S1121 / (_S1122 + _S1094 * _S1123));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1089, Shift_x24init_0(_S1089.f, 1.0f), canonical_mis_0);
    var _S1124 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1075), (_S1124), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1075), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1125 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1126 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1127 : f32 = (sign((dot(_S1126, _S1125.smooth_n))));
    var _S1128 : vec3<f32> = _S1125.material.emissive * vec3<f32>(max(_S1127, 0.0f));
    var _S1129 : vec3<f32> = select(_S1128, _S1076, _S1125.skip);
    var _S1130 : vec3<f32> = clamp(sel_5.color + _S1129, _S1076, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1075), (u32(0)), (vec4<f32>(_S1130, 1.0f)));
    var _S1131 : u32 = (uniforms_uint.is_temporal);
    var _S1132 : bool = _S1131 == u32(1);
    if(_S1132)
    {
        textureStore(compute_out, (_S1075), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1133 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1134 : bool = _S1133 != u32(4294967295);
    if(_S1134)
    {
        var _S1135 : vec2<i32> = vec2<i32>((vec2<u32>(_S1133, (_S1133 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1136 : vec3<f32> = vec3<f32>(0.0f);
        var _S1137 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1136, _S1136, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1136, 0.0f, vec4<u32>(u32(0)), _S1136, _S1136));
        var shift_job_0 : ShiftJob = _S1137;
        var _S1138 : u32 = (_S1133 >> (u32(28)));
        var _S1139 : bool = spatialJob_0(_S1135, _S1138, &(shift_job_0));
        var _S1140 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1135), (_S1138), (vec4<u32>((bitcast<vec3<u32>>((_S1140.f))), (bitcast<u32>((_S1140.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1141 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1142 : array<u32, i32(3)>;
    spatialBins_0(_S1141, &(_S1142));
    var _S1143 : array<u32, i32(3)> = _S1142;
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
        var _S1144 : bool = (_S1143[t_16]) == u32(40);
        if(_S1144)
        {
            textureStore(shift_data_out, (_S1141), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1141, _S1143, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1145 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1145));
    countShifts_0(_S1145, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1146 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1147 : bool = _S1146 != u32(4294967295);
    if(_S1147)
    {
        var _S1148 : vec2<i32> = vec2<i32>((vec2<u32>(_S1146, (_S1146 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1149 : vec3<f32> = vec3<f32>(0.0f);
        var _S1150 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1149, _S1149, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1149, 0.0f, vec4<u32>(u32(0)), _S1149, _S1149));
        var shift_job_1 : ShiftJob = _S1150;
        var _S1151 : u32 = (_S1146 >> (u32(28)));
        var _S1152 : bool = temporalJob_0(_S1148, _S1151, &(shift_job_1));
        var _S1153 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1148), (_S1151), (vec4<u32>((bitcast<vec3<u32>>((_S1153.f))), (bitcast<u32>((_S1153.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1154 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1155 : array<u32, i32(3)>;
    temporalBins_0(_S1154, &(_S1155));
    var _S1156 : array<u32, i32(3)> = _S1155;
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
        var _S1157 : bool = (_S1156[t_18]) == u32(40);
        if(_S1157)
        {
            textureStore(temporal_shifts_out, (_S1154), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1154, _S1156, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1158 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1158));
    countShifts_0(_S1158, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1159 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1160 : vec3<f32> = vec3<f32>(0.0f);
    var _S1161 : Domain = Domain_x24init_0(_S1160, _S1160, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1161;
    var _S1162 : bool = (currentDomain((_S1159), &(dom_6)));
    var _S1163 : bool = !_S1162;
    if(_S1163)
    {
        storeReservoir(reservoir_temp_out, (_S1159), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1160, 0.0f, vec4<u32>(u32(0)), _S1160, _S1160)), (dom_6.hit));
        return;
    }
    var _S1164 : Reservoir = (loadReservoir(reservoir_initial, (_S1159)));
    var _S1165 : vec2<i32> = temporalNeighbor_0(_S1159, dom_6);
    var _S1166 : bool = (_S1165.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1166)
    {
        var _S1167 : Reservoir = (loadReservoir(reservoir_prev, (_S1165)));
        var _S1168 : vec4<u32> = (textureLoad(duplication, (_S1165), 0, 0));
        var _S1169 : f32 = (bitcast<f32>((_S1168.x)));
        var _S1170 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1171 : bool = _S1170 == u32(1);
        var _S1172 : f32 = select(0.0f, _S1169, _S1171);
        var _S1173 : f32 = (mix((20.0f), (1.0f), (pow(_S1172, 0.10000000149011612f))));
        var _S1174 : f32 = min(_S1167.c, _S1173);
        var _S1175 : vec4<u32> = (textureLoad(temporal_shifts, (_S1159), (u32(0)), 0));
        var _S1176 : vec4<f32> = (bitcast<vec4<f32>>((_S1175)));
        var _S1177 : vec4<f32> = vec4<f32>(_S1164.f, 1.0f);
        var _S1178 : Domain = (previousDomain((_S1165)));
        var _S1179 : bool = sameDomain_0(_S1178, dom_6);
        var _S1180 : bool = !_S1179;
        var to_previous_0 : vec4<f32>;
        if(_S1180)
        {
            var _S1181 : vec4<u32> = (textureLoad(temporal_shifts, (_S1159), (u32(1)), 0));
            var _S1182 : vec4<f32> = (bitcast<vec4<f32>>((_S1181)));
            to_previous_0 = _S1182;
        }
        else
        {
            to_previous_0 = _S1177;
        }
        var _S1183 : f32 = rgb_to_greyscale(_S1164.f);
        var _S1184 : f32 = rgb_to_greyscale(_S1167.f);
        var _S1185 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1160, 0.0f, vec4<u32>(u32(0)), _S1160, _S1160), 0.0f, _S1160, u32(0));
        var sel_6 : Selection = _S1185;
        var _S1186 : u32 = (uniforms_uint.frame);
        var _S1187 : u32 = hash(_S1186);
        var _S1188 : u32 = global_invocation_id_7.x;
        var _S1189 : vec2<u32> = (uniforms_uint.render_size);
        var _S1190 : u32 = stream(_S1187, _S1188 + _S1189.x * global_invocation_id_7.y);
        var _S1191 : u32 = stream(_S1190, u32(194));
        sel_6.random_state = _S1191;
        var _S1192 : f32 = _S1164.c * _S1183;
        var _S1193 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1194 : f32 = _S1192 / (_S1192 + _S1174 * _S1193);
        var _S1195 : f32 = _S1174 * _S1184;
        var _S1196 : vec3<f32> = _S1176.xyz;
        var _S1197 : f32 = rgb_to_greyscale(_S1196);
        var _S1198 : f32 = _S1195 / (_S1195 + _S1164.c * _S1197);
        var _S1199 : vec2<f32> = vec2<f32>(_S1194, _S1198);
        offerShifted(&(sel_6), _S1164, Shift_x24init_0(_S1164.f, 1.0f), _S1194);
        offerShifted(&(sel_6), _S1167, Shift_x24init_0(_S1196, _S1176.w), _S1198);
        var _S1200 : Reservoir = finalize(sel_6, _S1164.c + _S1174);
        r_8 = _S1200;
    }
    else
    {
        r_8 = _S1164;
    }
    storeReservoir(reservoir_temp_out, (_S1159), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1201 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1202 : vec3<f32> = vec3<f32>(0.0f);
    var _S1203 : Domain = Domain_x24init_0(_S1202, _S1202, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1203;
    var _S1204 : bool = (currentDomain((_S1201), &(dom_7)));
    var _S1205 : bool = !_S1204;
    if(_S1205)
    {
        storeReservoir(reservoir_initial_out, (_S1201), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1202, 0.0f, vec4<u32>(u32(0)), _S1202, _S1202)), (dom_7.hit));
        return;
    }
    var _S1206 : u32 = (uniforms_uint.frame);
    var _S1207 : u32 = hash(_S1206);
    var _S1208 : u32 = global_invocation_id_8.x;
    var _S1209 : vec2<u32> = (uniforms_uint.render_size);
    var _S1210 : u32 = stream(_S1207, _S1208 + _S1209.x * global_invocation_id_8.y);
    var _S1211 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1202, 0.0f, vec4<u32>(u32(0)), _S1202, _S1202);
    var _S1212 : Selection = Selection_x24init_0(_S1211, 0.0f, _S1202, u32(0));
    var initial_0 : Selection = _S1212;
    var _S1213 : u32 = stream(_S1210, u32(193));
    initial_0.random_state = _S1213;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1214 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1214)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1211;
        var _S1215 : u32 = stream(_S1210, i_10);
        r_9.seed = _S1215;
        var _S1216 : u32 = (uniforms_uint.samples);
        var _S1217 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1216), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1218 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1201), (_S1218), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1219 : Random = pcg(state_3);
    var _S1220 : Random = pcg(_S1219.state);
    var _S1221 : f32 = 6.28318548202514648f * _S1219.value;
    var _S1222 : f32 = sqrt(-2.0f * clamp(log(_S1220.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1220.state, _S1222 * cos(_S1221));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1223 : RandomSphere;
    _S1223.state = state_4;
    _S1223.value = value_1;
    return _S1223;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1224 : Random = normal_distribution(state_5);
    var _S1225 : Random = normal_distribution(_S1224.state);
    var _S1226 : Random = normal_distribution(_S1225.state);
    var _S1227 : vec3<f32> = (normalize((vec3<f32>(_S1224.value, _S1225.value, _S1226.value))));
    return RandomSphere_x24init_0(_S1226.state, _S1227);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1228 : vec3<f32> = p1_0 - p0_0;
    var _S1229 : vec3<f32> = p2_0 - p0_0;
    var _S1230 : vec2<f32> = uv1_0 - uv0_0;
    var _S1231 : vec2<f32> = uv2_0 - uv0_0;
    var _S1232 : f32 = _S1230.x;
    var _S1233 : f32 = _S1231.y;
    var _S1234 : f32 = _S1230.y;
    var _S1235 : f32 = _S1231.x;
    var _S1236 : f32 = _S1232 * _S1233 - _S1234 * _S1235;
    var _S1237 : f32 = 1.0f / _S1236;
    var _S1238 : vec3<f32> = vec3<f32>(_S1237);
    var t_20 : vec3<f32> = (_S1228 * vec3<f32>(_S1233) - _S1229 * vec3<f32>(_S1234)) * _S1238;
    var _S1239 : vec3<f32> = (_S1229 * vec3<f32>(_S1232) - _S1228 * vec3<f32>(_S1235)) * _S1238;
    var _S1240 : vec3<f32> = t_20 - n_9 * vec3<f32>(dot(n_9, t_20));
    var _S1241 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_9);
    var _S1242 : bool = (dot(_S1240, _S1240)) > 0.0f;
    var _S1243 : vec3<f32> = select(_S1241, _S1240, _S1242);
    var _S1244 : vec3<f32> = (normalize((_S1243)));
    var _S1245 : bool = (dot(cross(n_9, _S1244), _S1239)) > 0.0f;
    var t_21 : vec3<f32>;
    if(_S1245)
    {
        var _S1246 : vec3<f32> = ((-(_S1244)));
        t_21 = _S1246;
    }
    else
    {
        t_21 = _S1244;
    }
    var _S1247 : vec3<f32> = cross(n_9, t_21);
    return mat3x3<f32>(t_21, _S1247, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1248 : vec3<f32> = t1_0 - t0_0;
    var _S1249 : vec3<f32> = t2_2 - t0_0;
    var _S1250 : vec3<f32> = t2_2 - t1_0;
    var _S1251 : f32 = min(length(_S1248), min(length(_S1249), length(_S1250)));
    var _S1252 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1253 : vec3<f32> = (normalize((n0_0)));
    var _S1254 : f32 = dot(geometry_n_4, _S1253);
    var _S1255 : vec3<f32> = (normalize((n1_0)));
    var _S1256 : f32 = dot(geometry_n_4, _S1255);
    var _S1257 : vec3<f32> = (normalize((n2_0)));
    var _S1258 : vec3<f32> = acos(abs(vec3<f32>(_S1254, _S1256, dot(geometry_n_4, _S1257))));
    var _S1259 : vec3<f32> = clamp(tan(_S1258), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1252 * _S1259, uvw_0), 0.0f, _S1251 * 0.125f);
}

fn straightThrough( material_20 : Material) -> vec3<f32>
{
    return vec3<f32>((material_20.transmission * (1.0f - material_20.metallic))) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_10 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1260 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1261 : vec3<f32> = straightThrough(material_21);
        _S1260 = _S1261;
    }
    else
    {
        _S1260 = vec3<f32>(0.0f);
    }
    return _S1260 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1262 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1262;
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

