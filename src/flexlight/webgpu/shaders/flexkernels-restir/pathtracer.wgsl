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
    var _S63 : f32 = select(-1.0f, 1.0f, _S62);
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

fn isTranslucent_0( material_3 : Material) -> bool
{
    var _S89 : f32 = rgb_to_greyscale(material_3.translucent);
    return _S89 > 0.0f;
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
    var _S90 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S91 : bool = cos_a_0 > cos_b_0;
    var _S92 : f32 = select(_S90, 1.0f, _S91);
    return _S92;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S93 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S94 : vec3<f32> = node_0.high - node_0.low;
    var _S95 : vec3<f32> = p_3 - _S93;
    var _S96 : vec3<f32> = (normalize((_S95)));
    var _S97 : f32 = dot(_S95, _S95);
    var _S98 : f32 = dot(_S94, _S94) / 4.0f;
    var _S99 : f32 = abs(dot(node_0.w, _S96));
    var _S100 : f32 = sine(node_0.cos_theta_o);
    var _S101 : f32 = sqrt(max(1.0f - _S98 / _S97, 0.0f));
    var _S102 : bool = _S97 < _S98;
    var _S103 : f32 = select(_S101, -1.0f, _S102);
    var _S104 : f32 = sine(_S103);
    var _S105 : f32 = sine(_S99);
    var _S106 : f32 = cosSubClamped(_S105, _S99, _S100, node_0.cos_theta_o);
    var _S107 : f32 = sine(_S99);
    var _S108 : f32 = _S107 * node_0.cos_theta_o - _S99 * _S100;
    var _S109 : bool = _S99 > (node_0.cos_theta_o);
    var _S110 : f32 = select(_S108, 0.0f, _S109);
    var _S111 : f32 = cosSubClamped(_S110, _S106, _S104, _S103);
    var _S112 : bool = _S111 <= 0.0f;
    if(_S112)
    {
        return 0.0f;
    }
    var _S113 : f32 = - dot(_S96, normal_0);
    var _S114 : f32 = node_0.phi * _S111 / max(_S97, length(_S94) / 2.0f);
    var _S115 : f32 = sine(_S113);
    var _S116 : f32 = cosSubClamped(_S115, _S113, _S104, _S103);
    var _S117 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S118 : f32 = select(_S116, 1.0f, _S117);
    return max(_S114 * _S118, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S119 : f32 = importance(first_0, p_4, normal_1);
    var _S120 : f32 = importance(second_0, p_4, normal_1);
    var _S121 : vec2<f32> = vec2<f32>(_S119, _S120);
    var _S122 : f32 = _S121[child_0] / (_S119 + _S120);
    var _S123 : bool = (_S121[child_0]) > 0.0f;
    var _S124 : f32 = select(0.0f, _S122, _S123);
    return _S124;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S125 : vec3<f32> = center_0 - p_5;
    var _S126 : f32 = radius_0 * radius_0 / dot(_S125, _S125);
    var _S127 : bool = _S126 >= 1.0f;
    if(_S127)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S126)) / (6.28318548202514648f * _S126);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S128 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S129 : vec2<u32> = _S128.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S129;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S130 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S130.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S131 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S132 : u32 = n_0 + u32(1);
        var _S133 : LightBounds = (lightBounds((_S132)));
        var _S134 : LightBounds = (lightBounds((_S131)));
        var _S135 : u32 = trail_0.x;
        var _S136 : u32 = (_S135 & (u32(1)));
        var _S137 : f32 = childShare(_S133, _S134, origin_2, smooth_n_2, _S136);
        var probability_2 : f32 = probability_1 * _S137;
        var _S138 : bool = _S136 == u32(1);
        var _S139 : u32 = select(_S132, _S131, _S138);
        var _S140 : u32 = trail_0.y;
        var _S141 : vec2<u32> = vec2<u32>((((_S135 >> (u32(1)))) | (((_S140 << (u32(31)))))), (_S140 >> (u32(1))));
        n_0 = _S139;
        trail_0 = _S141;
        probability_1 = probability_2;
    }
    var _S142 : bool = (((_S128).z == (n_0)));
    var _S143 : bool = !_S142;
    var _S144 : bool;
    if(_S143)
    {
        _S144 = true;
    }
    else
    {
        var _S145 : LightBounds = (lightBounds((n_0)));
        var _S146 : f32 = importance(_S145, origin_2, smooth_n_2);
        _S144 = !(_S146 > 0.0f);
    }
    if(_S144)
    {
        _S144 = true;
    }
    else
    {
        var _S147 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S147)
        {
            _S144 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S144 = false;
        }
    }
    if(_S144)
    {
        return 0.0f;
    }
    var _S148 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S149 : bool = (_S148.x) == u32(2);
    if(_S149)
    {
        var _S150 : Light = (lights[(_S148.y)]);
        var _S151 : f32 = sphereDensity(_S150.position, _S150.variance, start_1);
        return probability_1 * _S151;
    }
    var _S152 : u32 = _S148.y;
    var _S153 : u32 = ((instance_uint[(_S152) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S154 : mat3x3<f32> = (worldTriangle((_S152), (_S153 + _S148.z)));
    var _S155 : f32 = solidAngle(probability_1, cross(_S154[i32(1)] - _S154[i32(0)], _S154[i32(2)] - _S154[i32(0)]), light_point_0 - start_1);
    return _S155;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S156 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S157 : bool = b_0 > 0.0f;
    var _S158 : f32 = select(1.0f, _S156, _S157);
    return _S158;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S159 : u32 = (lightSlot((hit_1)));
    var _S160 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S159, light_point_1);
    var _S161 : f32 = powerHeuristic(vertex_0.pdf, _S160);
    return _S161;
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
    var _S162 : TreeSample;
    _S162.dir = dir_2;
    _S162.radiance = radiance_1;
    _S162.density = density_0;
    _S162.random_state = random_state_2;
    return _S162;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S163 : Random;
    _S163.state = state_0;
    _S163.value = value_0;
    return _S163;
}

fn pcg( state_1 : u32) -> Random
{
    var _S164 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S165 : u32 = hash(state_1);
    return Random_x24init_0(_S164, f32(_S165) / 4.294967296e+09f);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S166 : f32 = importance(first_1, p_6, normal_3);
    var _S167 : f32 = importance(second_1, p_6, normal_3);
    var _S168 : vec2<f32> = vec2<f32>(_S166, _S167);
    var _S169 : bool = _S166 == 0.0f;
    var _S170 : bool;
    if(_S169)
    {
        _S170 = _S167 == 0.0f;
    }
    else
    {
        _S170 = false;
    }
    if(_S170)
    {
        return u32(2);
    }
    var _S171 : f32 = _S166 + _S167;
    var _S172 : bool = _S167 > 0.0f;
    if(_S172)
    {
        _S170 = ((*pick_0) * _S171) >= _S166;
    }
    else
    {
        _S170 = false;
    }
    var _S173 : u32 = select(u32(0), u32(1), _S170);
    var _S174 : f32 = min(((*pick_0) * _S171 - f32(_S173) * _S166) / _S168[_S173], 0.99999994039535522f);
    (*pick_0) = _S174;
    var _S175 : f32 = (*probability_3) * (_S168[_S173] / _S171);
    (*probability_3) = _S175;
    return _S173;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S176 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S176)
    {
        const _S177 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S177;
    }
    else
    {
        a_2 = a_1;
    }
    var _S178 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S179 : vec3<f32> = cross(n_1, _S178);
    return vec3<f32>(v_0.x) * _S178 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S179;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S180 : vec3<f32> = center_1 - p_7;
    var _S181 : f32 = radius_1 * radius_1 / dot(_S180, _S180);
    var _S182 : f32 = u1_0 * _S181 / (1.0f + sqrt(max(1.0f - _S181, 0.0f)));
    var _S183 : f32 = 2.0f * u1_0;
    var _S184 : bool = _S181 >= 1.0f;
    var _S185 : f32 = select(_S182, _S183, _S184);
    var _S186 : f32 = sqrt(max(_S185 * (2.0f - _S185), 0.0f));
    var _S187 : f32 = 6.28318548202514648f * u2_0;
    var _S188 : vec3<f32> = vec3<f32>(_S186 * cos(_S187), 1.0f - _S185, _S186 * sin(_S187));
    var _S189 : vec3<f32> = (normalize((_S180)));
    var _S190 : vec3<f32> = tangentToWorld(_S188, _S189);
    return _S190;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S191 : vec3<f32> = center_2 - ray_0.origin;
    var _S192 : f32 = dot(_S191, ray_0.unit_direction);
    var _S193 : f32 = dot(_S191, _S191) - _S192 * _S192;
    var _S194 : f32 = radius_3 * radius_3;
    var _S195 : bool = _S193 > _S194;
    if(_S195)
    {
        return 4.294967296e+09f;
    }
    var _S196 : f32 = sqrt(_S194 - _S193);
    var _S197 : f32 = _S192 - _S196;
    var _S198 : f32 = _S192 + _S196;
    var _S199 : bool = _S197 > 0.0000152587890625f;
    var _S200 : bool;
    if(_S199)
    {
        _S200 = _S197 < max_len_0;
    }
    else
    {
        _S200 = false;
    }
    if(_S200)
    {
        return _S197;
    }
    var _S201 : bool = _S198 > 0.0000152587890625f;
    if(_S201)
    {
        _S200 = _S198 < max_len_0;
    }
    else
    {
        _S200 = false;
    }
    if(_S200)
    {
        return _S198;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S202 : vec3<f32> = (normalize((light_dir_0)));
    var _S203 : bool = (dot(smooth_n_3, _S202)) < 0.0f;
    if(_S203)
    {
        return vec3<f32>(0.0f);
    }
    var _S204 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S205 : Ray = Ray_x24init_0(_S204, _S202);
    var _S206 : f32 = shadowLength(light_dir_0);
    var _S207 : vec3<f32> = (shadowTransmittance((_S205), (_S206)));
    return _S207;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S208 : Random = pcg(init_random_state_0);
    var _S209 : Random = pcg(_S208.state);
    var _S210 : Random = pcg(_S209.state);
    var _S211 : vec3<f32> = vec3<f32>(0.0f);
    var _S212 : TreeSample = TreeSample_x24init_0(_S211, _S211, 0.0f, _S210.state);
    var sample_0 : TreeSample = _S212;
    var _S213 : vec3<f32> = select(smooth_n_4, _S211, sided_0);
    var _S214 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S215 : vec3<f32> = origin_4 + _S214 * smooth_n_4;
    var pick_1 : f32 = _S208.value;
    var probability_4 : f32 = 1.0f;
    var n_2 : u32 = u32(0);
    loop
    {
        var _S216 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
        if((_S216.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S217 : u32 = (access_light_tree(3u + 4u * (n_2)).w);
        var _S218 : u32 = n_2 + u32(1);
        var _S219 : LightBounds = (lightBounds((_S218)));
        var _S220 : LightBounds = (lightBounds((_S217)));
        var _S221 : u32 = pickChild(_S219, _S220, origin_4, _S213, &(pick_1), &(probability_4));
        var _S222 : bool = _S221 > u32(1);
        if(_S222)
        {
            return sample_0;
        }
        var _S223 : bool = _S221 == u32(1);
        var _S224 : u32 = select(_S218, _S217, _S223);
        n_2 = _S224;
    }
    var _S225 : bool = n_2 == u32(0);
    var _S226 : bool;
    if(_S225)
    {
        var _S227 : LightBounds = (lightBounds((u32(0))));
        var _S228 : f32 = importance(_S227, origin_4, _S213);
        _S226 = !(_S228 > 0.0f);
    }
    else
    {
        _S226 = false;
    }
    if(_S226)
    {
        return sample_0;
    }
    var _S229 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
    var _S230 : bool = (_S229.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S230)
    {
        var _S231 : Light = (lights[(_S229.y)]);
        if(sided_0)
        {
            var _S232 : f32 = (sign((dot(geometry_n_1, _S231.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S232);
            var _S233 : vec3<f32> = origin_4 + _S214 * lift_n_1;
            start_2 = _S233;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S215;
            lift_n_0 = smooth_n_4;
        }
        var _S234 : bool = (_S231.variance) == 0.0f;
        if(_S234)
        {
            var _S235 : vec3<f32> = _S231.position - start_2;
            var _S236 : vec3<f32> = (normalize((_S235)));
            sample_0.dir = _S236;
            var _S237 : vec3<f32> = _S231.color * vec3<f32>(_S231.intensity) / vec3<f32>((dot(_S235, _S235) * probability_4));
            sample_0.radiance = _S237;
            shadow_1 = _S235;
        }
        else
        {
            var _S238 : vec3<f32> = sampleSphere(_S231.position, _S231.variance, start_2, _S209.value, _S210.value);
            sample_0.dir = _S238;
            var _S239 : f32 = sphereDensity(_S231.position, _S231.variance, start_2);
            var _S240 : f32 = probability_4 * _S239;
            sample_0.density = _S240;
            var _S241 : vec3<f32> = pointLightRadiance(_S231.color, _S231.intensity, _S231.variance);
            var _S242 : vec3<f32> = _S241 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S242;
            var _S243 : f32 = raySphere_0(_S231.position, _S231.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S244 : vec3<f32> = sample_0.dir * vec3<f32>(_S243);
            shadow_1 = _S244;
        }
    }
    else
    {
        var _S245 : u32 = _S229.y;
        var _S246 : u32 = ((instance_uint[(_S245) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S247 : u32 = _S246 + _S229.z;
        var _S248 : mat3x3<f32> = (worldTriangle((_S245), (_S247)));
        var _S249 : f32 = sqrt(_S209.value);
        var _S250 : vec2<f32> = vec2<f32>(_S249 * (1.0f - _S210.value), _S249 * _S210.value);
        var _S251 : vec3<f32> = (((_S248) * (vec3<f32>(1.0f - _S249, _S250))));
        if(sided_0)
        {
            var _S252 : f32 = (sign((dot(geometry_n_1, _S251 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S252);
            var _S253 : vec3<f32> = origin_4 + _S214 * lift_n_2;
            start_2 = _S253;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S254 : bool = !((dot(smooth_n_4, _S251 - origin_4)) > 0.0f);
            if(_S254)
            {
                return sample_0;
            }
            start_2 = _S215;
            lift_n_0 = smooth_n_4;
        }
        var _S255 : Surface = (surfaceAt((Hit_x24init_0(_S250, _S245, _S247, u32(0), 0.0f)), (_S251), (_S210.state)));
        sample_0.random_state = _S255.random_state;
        var _S256 : vec3<f32> = _S251 - start_2;
        var _S257 : vec3<f32> = (normalize((_S256)));
        sample_0.dir = _S257;
        var _S258 : f32 = solidAngle(probability_4, cross(_S248[i32(1)] - _S248[i32(0)], _S248[i32(2)] - _S248[i32(0)]), _S256);
        sample_0.density = _S258;
        var _S259 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S255.smooth_n))));
        var _S260 : vec3<f32> = _S255.material.emissive * vec3<f32>(max(_S259, 0.0f));
        var _S261 : vec3<f32> = select(_S260, _S211, _S255.skip);
        var _S262 : vec3<f32> = _S261 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S262;
        shadow_1 = _S256;
    }
    var _S263 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S264 : vec3<f32> = sample_0.radiance * _S263;
    var _S265 : bool = (all((_S263 == _S211)));
    var _S266 : vec3<f32> = select(_S264, _S211, _S265);
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

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f );
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
        var _S289 : f32 = sqrt(0.00999999977648258f);
        var _S290 : bool = (material_5.velvet) > 0.0f;
        var _S291 : f32 = select(_S288, _S289, _S290);
        var _S292 : f32 = (clamp(sqrt(max(material_5.sheen_roughness, 0.0f)), _S291, 1.0f) - _S291) / (1.0f - _S291) * 23.0f;
        var _S293 : u32 = min(u32(_S292), u32(22));
        var _S294 : u32 = _S287 * u32(24) + _S293;
        var _S295 : f32 = _S286 - f32(_S287);
        var _S296 : f32 = _S292 - f32(_S293);
        if(_S290)
        {
            var _S297 : u32 = _S294 + u32(24);
            var _S298 : f32 = VELVET_ALBEDO_0[_S294] + (VELVET_ALBEDO_0[_S297] - VELVET_ALBEDO_0[_S294]) * _S295;
            var _S299 : u32 = _S294 + u32(1);
            var _S300 : f32 = VELVET_ALBEDO_0[_S299] + (VELVET_ALBEDO_0[_S297 + u32(1)] - VELVET_ALBEDO_0[_S299]) * _S295;
            var _S301 : SheenProfile = SheenProfile_x24init_0(true, _S298 + (_S300 - _S298) * _S296);
            profile_0 = _S301;
        }
        else
        {
            var _S302 : u32 = _S294 + u32(24);
            var _S303 : f32 = SHEEN_ALBEDO_0[_S294] + (SHEEN_ALBEDO_0[_S302] - SHEEN_ALBEDO_0[_S294]) * _S295;
            var _S304 : u32 = _S294 + u32(1);
            var _S305 : f32 = SHEEN_ALBEDO_0[_S304] + (SHEEN_ALBEDO_0[_S302 + u32(1)] - SHEEN_ALBEDO_0[_S304]) * _S295;
            var _S306 : SheenProfile = SheenProfile_x24init_0(true, exp(_S303 + (_S305 - _S303) * _S296));
            profile_0 = _S306;
        }
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
    var _S307 : BSDFLobes;
    _S307.v_dot_h = v_dot_h_0;
    _S307.n_dot_h = n_dot_h_0;
    _S307.refracted = refracted_0;
    _S307.F = F_0;
    _S307.F_greyscale = F_greyscale_0;
    _S307.reflect_weight = reflect_weight_0;
    _S307.diffuse_weight = diffuse_weight_0;
    _S307.refract_weight = refract_weight_0;
    _S307.p_diffuse = p_diffuse_0;
    _S307.p_reflect = p_reflect_0;
    _S307.p_refract = p_refract_0;
    _S307.translucent_share = translucent_share_0;
    _S307.sheen = sheen_1;
    _S307.p_sheen_velvet = p_sheen_velvet_0;
    _S307.view = view_0;
    _S307.tangent = tangent_2;
    _S307.alphas = alphas_1;
    _S307.visible = visible_0;
    return _S307;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_3, t_4)), dot(w_1, n_3));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S308 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S309 : f32 = _S308.x;
    var _S310 : f32 = _S308.y;
    var _S311 : f32 = _S309 * _S309 + _S310 * _S310;
    const _S312 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S313 : vec3<f32> = vec3<f32>(- _S310, _S309, 0.0f);
    var _S314 : f32 = (inverseSqrt((_S311)));
    var _S315 : vec3<f32> = _S313 * vec3<f32>(_S314);
    var _S316 : bool = _S311 > 0.0f;
    var _S317 : vec3<f32> = select(_S312, _S315, _S316);
    var _S318 : vec3<f32> = cross(_S308, _S317);
    var _S319 : f32 = sqrt(U1_0);
    var _S320 : f32 = 6.28318548202514648f * U2_0;
    var _S321 : f32 = _S319 * cos(_S320);
    var t2_0 : f32 = _S319 * sin(_S320);
    var _S322 : f32 = 0.5f * (1.0f + _S308.z);
    var t2_1 : f32 = (1.0f - _S322) * sqrt(max(0.0f, 1.0f - _S321 * _S321)) + _S322 * t2_0;
    var _S323 : vec3<f32> = vec3<f32>(_S321) * _S317 + vec3<f32>(t2_1) * _S318;
    var _S324 : f32 = ((_S321));
    var _S325 : f32 = ((_S321));
    var _S326 : vec3<f32> = _S323 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S324 * _S325 - t2_1 * t2_1))) * _S308;
    var _S327 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S326.x, alpha_0 * _S326.y, max(0.0f, _S326.z)))));
    return _S327;
}

fn worldToTangent( v_2 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S328 : bool = (abs(dot(n_4, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S328)
    {
        const _S329 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S329;
    }
    else
    {
        a_4 = a_3;
    }
    var _S330 : vec3<f32> = (normalize((cross(n_4, a_4))));
    var _S331 : vec3<f32> = cross(n_4, _S330);
    return vec3<f32>(dot(v_2, _S330), dot(v_2, n_4), dot(v_2, _S331));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S332 : Random = pcg((*random_state_3));
    var _S333 : Random = pcg(_S332.state);
    (*random_state_3) = _S333.state;
    var _S334 : f32 = frame_0.alphas.x;
    var _S335 : bool = _S334 > 0.0f;
    if(_S335)
    {
        var _S336 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S337 : f32 = frame_0.alphas.y;
        var _S338 : vec3<f32> = (normalize((vec3<f32>(_S334 * _S336.x, _S337 * _S336.y, _S336.z))));
        var _S339 : vec3<f32> = sampleGGXVNDF(_S338, 1.0f, _S332.value, _S333.value);
        var _S340 : vec3<f32> = (normalize((vec3<f32>(_S334 * _S339.x, _S337 * _S339.y, _S339.z))));
        return vec3<f32>(_S340.x) * frame_0.tangent + vec3<f32>(_S340.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S340.z) * n_i_2;
    }
    var _S341 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S342 : vec3<f32> = sampleGGXVNDF(_S341.xzy, alpha_1, _S332.value, _S333.value);
    var _S343 : vec3<f32> = _S342.xzy;
    var _S344 : vec3<f32> = tangentToWorld(_S343, n_i_2);
    return _S344;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_6 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S345 : vec3<f32> = ((-(in_dir_0)));
    var _S346 : f32 = (sign((dot(n_5, _S345))));
    var _S347 : f32 = material_6.roughness;
    var _S348 : vec3<f32> = sampleHalfVector(_S345, n_5 * vec3<f32>(_S346), _S347 * _S347, frame_1, &(state_2));
    return _S348;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S349 : vec3<f32> = ((-(in_dir_1)));
    var _S350 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S349 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S351 : vec3<f32> = (normalize((_S350)));
    var _S352 : f32 = (sign((dot(n_6, _S349))));
    var _S353 : f32 = (sign((dot(_S350, n_6 * vec3<f32>(_S352)))));
    return _S351 * vec3<f32>(_S353);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S354 : vec3<f32> = ((-(in_dir_2)));
    var _S355 : vec3<f32> = (normalize((_S354 + out_dir_1)));
    return _S355;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S356 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S356 / (_S356 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S356)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S357 : f32 = alphas_3.x;
    var _S358 : f32 = h_0.x / _S357;
    var _S359 : f32 = alphas_3.y;
    var _S360 : f32 = h_0.y / _S359;
    var _S361 : f32 = h_0.z;
    var _S362 : f32 = _S358 * _S358 + _S360 * _S360 + _S361 * _S361;
    return 1.0f / max(3.14159274101257324f * _S357 * _S359 * _S362 * _S362, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_7 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S363 : f32 = dot(ggx_n_0, v_4);
    var _S364 : f32 = dot(n_i_3, ggx_n_0);
    var _S365 : f32 = eta_i_3 / eta_o_3;
    var _S366 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S365))));
    var _S367 : f32 = min(sqrt(material_7.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S368 : f32 = _S367 * _S367;
    var _S369 : f32 = (1.0f + _S367) / (1.0f - _S367);
    var _S370 : f32 = abs(_S363);
    var _S371 : bool = eta_i_3 > eta_o_3;
    var _S372 : f32 = select(1.0f, _S369, _S371);
    var _S373 : f32 = select(_S369, 1.0f, _S371);
    var _S374 : f32 = fresnel(_S370, _S372, _S373);
    var _S375 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S363 * _S363)) >= (eta_o_3 * eta_o_3);
    var _S376 : vec3<f32> = material_7.specular_tint * vec3<f32>(_S368);
    var _S377 : vec3<f32> = vec3<f32>(1.0f);
    var _S378 : vec3<f32> = _S376 + (_S377 - _S376) * vec3<f32>((_S374 - _S368)) / vec3<f32>((1.0f - _S368));
    var _S379 : vec3<f32> = vec3<f32>(1.0f);
    var _S380 : vec3<f32> = select(_S378, _S379, _S375);
    var _S381 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S382 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S383 : vec3<f32> = _S377 - material_7.sheen * vec3<f32>(_S382);
        var _S384 : f32 = rgb_to_greyscale(material_7.sheen);
        var _S385 : f32 = _S384 * _S382;
        var _S386 : vec3<f32> = material_7.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S383;
        sheen_component_0 = _S385;
        sheen_2 = _S386;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S379;
        sheen_component_0 = 0.0f;
        sheen_2 = _S381;
        view_1 = _S381;
    }
    var _S387 : vec3<f32> = (mix((_S380), (material_7.albedo), (material_7.metallic)));
    var F_1 : vec3<f32> = _S387 * scale_0;
    var _S388 : f32 = rgb_to_greyscale(F_1);
    var _S389 : f32 = 1.0f - material_7.metallic;
    var _S390 : vec3<f32> = _S377 - _S380;
    var _S391 : vec3<f32> = vec3<f32>(((1.0f - material_7.transmission) * _S389)) * _S390 * scale_0;
    var _S392 : vec3<f32> = vec3<f32>((material_7.transmission * _S389)) * _S390 * scale_0;
    var _S393 : f32 = max(_S388, 0.0f);
    var _S394 : f32 = rgb_to_greyscale(_S391);
    var _S395 : f32 = max(_S394, 0.0f);
    var _S396 : f32 = rgb_to_greyscale(_S392);
    var _S397 : f32 = (sign((length(_S366))));
    var _S398 : f32 = max(_S396 * _S397, 0.0f);
    var _S399 : f32 = _S393 + _S395 + _S398;
    var _S400 : f32 = min(sheen_component_0, 1.0f);
    var _S401 : bool = sheen_component_0 > 0.0f;
    var _S402 : bool;
    if(_S401)
    {
        _S402 = !(_S399 > 0.0f);
    }
    else
    {
        _S402 = false;
    }
    var _S403 : f32 = select(_S400, 1.0f, _S402);
    var _S404 : f32 = (1.0f - _S403) / max(_S399, 0.0000152587890625f);
    var _S405 : f32 = _S395 * _S404;
    var _S406 : f32 = _S393 * _S404;
    var _S407 : f32 = _S398 * _S404;
    var _S408 : bool = (frame_2.alphas.x) > 0.0f;
    var visible_1 : f32;
    if(_S408)
    {
        var _S409 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S410 : f32 = anisotropicG1(_S409, frame_2.alphas);
        var _S411 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S412 : f32 = anisotropicD(_S411, frame_2.alphas);
        var _S413 : f32 = _S410 * _S412;
        visible_1 = _S413;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S363, _S364, _S366, F_1, _S388, 1.0f, _S391, _S392, _S405, _S406, _S407, 0.0f, sheen_2, _S403, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_8 : Material) -> f32
{
    var _S414 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S415 : f32 = rgb_to_greyscale(material_8.albedo);
    var _S416 : f32 = _S414 / (_S415 + _S414);
    var _S417 : bool = _S414 > 0.0f;
    var _S418 : f32 = select(0.0f, _S416, _S417);
    return _S418;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S419 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S420 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S421 : f32 = 1.0f - lobes_0.translucent_share;
    var _S422 : bool = n_i_dot_l_0 < 0.0f;
    var _S423 : f32 = select(_S421, lobes_0.translucent_share, _S422);
    var _S424 : f32 = _S420 * _S423;
    var _S425 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S426 : f32 = select(_S419, _S424, _S425);
    var _S427 : bool = n_i_dot_v_0 > 0.0f;
    var _S428 : f32 = select(0.0f, _S426, _S427);
    return _S428;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_9 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S429 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S430 : vec3<f32> = select(material_9.albedo, material_9.translucent, _S429);
    var _S431 : f32 = 1.0f - lobes_1.translucent_share;
    var _S432 : f32 = select(_S431, lobes_1.translucent_share, _S429);
    var _S433 : vec3<f32> = _S430 / vec3<f32>(_S432);
    var _S434 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S435 : vec3<f32> = select(material_9.albedo, _S433, _S434);
    return lobes_1.diffuse_weight * _S435 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S436 : f32 = alpha_4 * alpha_4;
    var _S437 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S436 + (1.0f - _S436) * n_dot_x_0 * n_dot_x_0));
    var _S438 : bool = alpha_4 > 0.0f;
    var _S439 : f32 = select(1.0f, _S437, _S438);
    return _S439;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S440 : f32 = alpha_5 * alpha_5;
    var _S441 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S440 * n_dot_h_1 * n_dot_h_1;
    return _S440 / max(3.14159274101257324f * _S441 * _S441, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S442 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S443 : f32 = _S442 * lobes_2.v_dot_h;
    var _S444 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S445 : f32 = _S443 * _S444 / n_i_dot_v_1;
    var _S446 : bool = alpha_6 > 0.0f;
    var _S447 : bool;
    if(_S446)
    {
        _S447 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S447 = false;
    }
    if(_S447)
    {
        _S447 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S447 = false;
    }
    if(_S447)
    {
        _S447 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S447 = false;
    }
    var _S448 : f32 = select(0.0f, _S445, _S447);
    var _S449 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S449)
    {
        var _S450 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S451 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S451)
        {
            _S447 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S447 = false;
        }
        if(_S447)
        {
            _S447 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S447 = false;
        }
        var _S452 : f32 = select(0.0f, _S450, _S447);
        pdf_h_0 = _S452;
    }
    else
    {
        pdf_h_0 = _S448;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S453 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S454 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S455 : f32 = lobes_3.p_refract * _S453 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S454 * _S454);
    var _S456 : bool = eta_i_5 != eta_o_5;
    var _S457 : bool;
    if(_S456)
    {
        _S457 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S457 = false;
    }
    var _S458 : f32 = select(0.0f, _S455, _S457);
    return _S458;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_10 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S459 : f32 = - dot(n_i_5, l_1);
    var _S460 : f32 = smithG1(alpha_8, max(_S459, 0.0f));
    var _S461 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S461)
    {
        var _S462 : vec3<f32> = ((-(n_i_5)));
        var _S463 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S462);
        var _S464 : f32 = anisotropicG1(_S463, lobes_4.alphas);
        G1_l_0 = _S464;
    }
    else
    {
        G1_l_0 = _S460;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_10.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S465 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S466 : bool = n_i_dot_l_2 > 0.0f;
    var _S467 : bool;
    if(_S466)
    {
        _S467 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S467 = false;
    }
    var _S468 : f32 = select(0.0f, _S465, _S467);
    return _S468;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_11 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S469 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S470 : f32 = dot(n_i_6, _S469);
    var _S471 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S472 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S473 : f32 = 1.0f / max(material_11.sheen_roughness, 0.05000000074505806f);
    var _S474 : f32 = 1.0f - _S470 * _S470;
    var _S475 : f32 = (2.0f + _S473) * pow(max(_S474, 0.0f), 0.5f * _S473) * 0.5f * 0.31830987334251404f / max(4.0f * (_S471 + _S472 - _S471 * _S472), 0.0000152587890625f);
    var _S476 : bool = (material_11.velvet) > 0.0f;
    var f_2 : f32;
    if(_S476)
    {
        var _S477 : f32 = max(material_11.sheen_roughness, 0.00999999977648258f);
        var _S478 : f32 = _S477 * _S477;
        var _S479 : f32 = max(_S474, 0.0000152587890625f);
        var _S480 : f32 = exp(- _S470 * _S470 / (_S479 * _S478)) / (3.14159274101257324f * _S478 * _S479 * _S479) * min(1.0f, 2.0f * _S470 * min(_S471, _S472) / max(abs(dot(_S469, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S471 * _S472, 0.0000152587890625f);
        f_2 = _S480;
    }
    else
    {
        f_2 = _S475;
    }
    return lobes_6.sheen * vec3<f32>((f_2 * _S471 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S481 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S482 : f32 = lobes_7.p_reflect * _S481 / (4.0f * lobes_7.v_dot_h);
    var _S483 : bool = _S481 > 0.0f;
    var _S484 : f32 = select(0.0f, _S482, _S483);
    return _S484;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_12 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S485 : f32 = dot(n_i_7, l_3);
    var _S486 : f32 = smithG1(alpha_12, max(_S485, 0.0f));
    var _S487 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S487)
    {
        var _S488 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S489 : f32 = anisotropicG1(_S488, lobes_8.alphas);
        G1_l_1 = _S489;
    }
    else
    {
        G1_l_1 = _S486;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S490 : vec3<f32> = ((-(in_dir_4)));
    var _S491 : f32 = dot(n_7, _S490);
    var _S492 : f32 = (sign((_S491)));
    var _S493 : vec3<f32> = n_7 * vec3<f32>(_S492);
    var _S494 : AnisotropicFrame = anisotropicFrame(material_13, _S493);
    var _S495 : f32 = dot(_S493, out_dir_2);
    var _S496 : f32 = material_13.roughness;
    var _S497 : f32 = _S496 * _S496;
    var _S498 : SheenProfile = sheenProfile(_S490, _S493, material_13);
    var _S499 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S500 : bool = _S499 > 0.0f;
    var _S501 : bool = (dot(n_7, out_dir_2) * _S491) < 0.0f;
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
        var _S502 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S502;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S503 : vec3<f32> = vec3<f32>(0.0f);
    var _S504 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S503, _S503, 0.0f, 0.0f, _S503, _S503, 0.0f, 0.0f, 0.0f, 0.0f, _S503, 0.0f, _S503, _S503, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S504;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S503;
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
        var _S505 : u32;
        if(i_0 == u32(3))
        {
            _S505 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S505 = u32(6);
            }
            else
            {
                _S505 = i_0;
            }
        }
        var _S506 : bool = _S505 == u32(0);
        var _S507 : bool;
        if(_S506)
        {
            _S507 = _S500;
        }
        else
        {
            _S507 = false;
        }
        var _S508 : bool;
        if(_S507)
        {
            _S508 = _S501;
        }
        else
        {
            _S508 = _S505 == u32(1);
        }
        var _S509 : bool = _S508 != refracted_1;
        if(_S509)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S510 : u32;
        if(_S505 == u32(6))
        {
            _S510 = u32(0);
        }
        else
        {
            if(_S505 == u32(4))
            {
                _S510 = u32(2);
            }
            else
            {
                _S510 = _S505;
            }
        }
        var _S511 : bool = _S510 != half_of_0;
        var half_of_1 : u32;
        if(_S511)
        {
            var _S512 : bool = _S510 == u32(0);
            if(_S512)
            {
                var _S513 : vec3<f32> = sampledHalf(in_dir_4, n_7, material_13, random_state_5, _S494);
                ggx_n_1 = _S513;
            }
            else
            {
                var _S514 : bool = _S510 == u32(1);
                if(_S514)
                {
                    var _S515 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S515;
                }
                else
                {
                    var _S516 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S516;
                }
            }
            var _S517 : vec3<f32> = ((-(in_dir_4)));
            var _S518 : BSDFLobes = bsdfLobes(in_dir_4, _S517, _S493, ggx_n_1, material_13, eta_i_8, eta_o_8, _S494, _S498);
            lobe_terms_0 = _S518;
            var _S519 : f32 = translucentShare(material_13);
            lobe_terms_0.translucent_share = _S519;
            half_of_1 = _S510;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S505)
        {
        case u32(0):
            {
                var _S520 : f32 = diffusePDF(_S495, 0.0f, abs(_S491), _S497, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S520;
                var _S521 : vec3<f32> = diffuseBSDF(out_dir_2, _S493, _S497, material_13, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S521;
            }
        case u32(1):
            {
                var _S522 : f32 = refractPDF(_S495, dot(out_dir_2, ggx_n_1), abs(_S491), _S497, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S522;
                var _S523 : vec3<f32> = refractBSDF(out_dir_2, _S493, _S497, material_13, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S523;
            }
        case u32(4):
            {
                var _S524 : f32 = sheenVelvetPDF(_S495, 0.0f, abs(_S491), _S497, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S524;
                var _S525 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S493, _S497, material_13, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S525;
            }
        default :
            {
                var _S526 : f32 = reflectPDF(_S495, 0.0f, abs(_S491), _S497, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S526;
                var _S527 : vec3<f32> = reflectBSDF(out_dir_2, _S493, _S497, material_13, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S527;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S503;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S528 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S528)
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
    var _S529 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S530 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S529, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S531 : bool = !competing_0;
    var _S532 : bool;
    if(_S531)
    {
        _S532 = true;
    }
    else
    {
        _S532 = (light_0.density) == 0.0f;
    }
    if(_S532)
    {
        return _S530 * light_0.radiance;
    }
    var _S533 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S533;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S534 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S534)
        {
            var _S535 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S535 * _S535)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S536 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S537 : vec2<u32> = _S536 - vec2<u32>(u32(1), u32(0));
    var _S538 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S539 : vec2<u32> = min(vec2<u32>(_S538 * vec2<f32>(_S537)), _S537 - vec2<u32>(u32(1)));
    var _S540 : vec4<f32> = (textureLoad(environment_cdf, (_S539), 0));
    var _S541 : f32 = _S540.y;
    var _S542 : u32 = _S537.x;
    var _S543 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S542, _S539.y)), 0));
    var _S544 : f32 = _S541 * _S543.y;
    return _S544 * f32(_S542 * _S537.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_2 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S545 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    var _S546 : vec3<f32> = BSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S545, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S547 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_4 : vec3<f32> = _S547;
    loop
    {
        if(i_6 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S548 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S548)
        {
            var _S549 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S549;
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
    var _S550 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S550;
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
    var _S551 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S551;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S552 : u32 = (low_0 + high_0) / u32(2);
        var _S553 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S552)), 0));
        var _S554 : bool = (_S553.x) > u_0;
        if(_S554)
        {
            high_0 = _S552;
        }
        else
        {
            var _S555 : u32 = _S552 + u32(1);
            low_0 = _S555;
        }
    }
    return low_0;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S556 : SkySample;
    _S556.dir = dir_7;
    _S556.radiance = radiance_2;
    _S556.color = color_2;
    _S556.random_state = random_state_9;
    return _S556;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S557 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S558 : bool = is_inside_3 != _S557;
    var _S559 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S560 : vec3<f32> = select(surface_3.smooth_n, _S559, _S558);
    var _S561 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S560, dir_8);
    var _S562 : vec3<f32> = (env_map_sample((dir_8)));
    var _S563 : vec3<f32> = (shadowTransmittance((_S561), (4.294967296e+09f)));
    return _S562 * _S563;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S564 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S565 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S566 : vec2<u32> = _S564 - _S565;
    var _S567 : Random = pcg(init_random_state_1);
    var _S568 : Random = pcg(_S567.state);
    var _S569 : Random = pcg(_S568.state);
    var _S570 : Random = pcg(_S569.state);
    var _S571 : u32 = _S566.x;
    var _S572 : u32 = searchCDF_0(vec2<u32>(_S571, u32(0)), vec2<u32>(u32(0), u32(1)), _S566.y, _S567.value);
    var _S573 : u32 = searchCDF_0(vec2<u32>(u32(0), _S572), _S565, _S571, _S568.value);
    var _S574 : vec2<f32> = (vec2<f32>(f32(_S573), f32(_S572)) + vec2<f32>(_S569.value, _S570.value)) / vec2<f32>(_S566) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S575 : f32 = _S574.y;
    var _S576 : f32 = sin(_S575);
    var _S577 : f32 = _S574.x;
    var _S578 : vec3<f32> = vec3<f32>(_S576 * cos(_S577), cos(_S575), _S576 * sin(_S577));
    var _S579 : f32 = environmentPdf_0(_S578);
    var _S580 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S578, surface_4, eta_2, is_inside_4, _S579, lobe_state_0);
    var _S581 : bool = !(_S579 > 0.0f);
    var _S582 : bool;
    if(_S581)
    {
        _S582 = true;
    }
    else
    {
        _S582 = (all((_S580 == vec3<f32>(0.0f))));
    }
    if(_S582)
    {
        var _S583 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S578, _S583, _S583, _S570.state);
    }
    var _S584 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S578);
    return SkySample_x24init_0(_S578, _S584, _S580 * _S584, _S570.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S585 : vec3<f32> = a_5 / b_1;
    var _S586 : vec3<f32> = vec3<f32>(0.0f);
    var _S587 : vec3<bool> = b_1 == _S586;
    var _S588 : vec3<f32> = select(_S585, _S586, _S587);
    return _S588;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S589 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S590 : u32 = (insertBits((_S589), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S590;
    candidate_0.f = f_6;
    return candidate_0;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S591 : f32 = rgb_to_greyscale(weight_0);
    var _S592 : bool = _S591 > 0.0f;
    var _S593 : bool;
    if(_S592)
    {
        _S593 = _S591 < 3.00000000549775576e+38f;
    }
    else
    {
        _S593 = false;
    }
    var _S594 : bool = !_S593;
    if(_S594)
    {
        return;
    }
    var _S595 : f32 = (*sel_0).w_sum + _S591;
    (*sel_0).w_sum = _S595;
    var _S596 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S596;
    var _S597 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S597.state;
    var _S598 : bool = (_S597.value * (*sel_0).w_sum) <= _S591;
    if(_S598)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S599 : vec2<u32> = (uniforms_uint.environment_map_size);
    return (all((_S599 > vec2<u32>(u32(1)))));
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
    var _S600 : SampleBSDF;
    _S600.unit_direction = unit_direction_1;
    _S600.throughput = throughput_0;
    _S600.random_state = random_state_10;
    _S600.refracted = refracted_3;
    _S600.lobe = lobe_1;
    _S600.pdf = pdf_4;
    return _S600;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S601 : vec3<f32> = vec3<f32>(1.0f);
    var _S602 : SampleBSDF = SampleBSDF_x24init_0(_S601, _S601, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S602;
    var _S603 : Random = pcg(random_state_11);
    var _S604 : Random = pcg(_S603.state);
    sample_1.random_state = _S604.state;
    var _S605 : f32 = _S603.value;
    var _S606 : f32 = sqrt(max(0.0f, 1.0f - _S605 * _S605));
    var _S607 : f32 = 6.28318548202514648f * _S604.value;
    var _S608 : vec3<f32> = tangentToWorld(vec3<f32>(_S606 * cos(_S607), _S603.value, _S606 * sin(_S607)), n_i_8);
    sample_1.unit_direction = _S608;
    sample_1.lobe = u32(4);
    var _S609 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S609;
    var _S610 : f32 = sheenVelvetPDF(_S603.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S610;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S611 : f32 = sqrt(random_1_0);
    var _S612 : f32 = 6.28318548202514648f * random_2_0;
    var _S613 : f32 = _S611 * cos(_S612);
    var _S614 : f32 = _S611 * sin(_S612);
    var _S615 : f32 = sqrt(max(0.0f, 1.0f - _S613 * _S613 - _S614 * _S614));
    return vec3<f32>(_S613, _S615, _S614);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S616 : vec3<f32> = vec3<f32>(1.0f);
    var _S617 : SampleBSDF = SampleBSDF_x24init_0(_S616, _S616, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S617;
    var _S618 : Random = pcg(random_state_12);
    var _S619 : Random = pcg(_S618.state);
    sample_2.random_state = _S619.state;
    var _S620 : vec3<f32> = sampleCosWeightedHemisphere(_S618.value, _S619.value);
    var _S621 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S622 : f32 = _S620.y;
    var _S623 : f32 = - _S622;
    var _S624 : f32 = select(_S622, _S623, _S621);
    var _S625 : vec3<f32> = tangentToWorld(vec3<f32>(_S620.x, _S624, _S620.z), n_i_9);
    sample_2.unit_direction = _S625;
    sample_2.refracted = _S621;
    sample_2.lobe = u32(0);
    var _S626 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S626;
    var _S627 : f32 = diffusePDF(_S624, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S627;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S628 : vec3<f32> = vec3<f32>(1.0f);
    var _S629 : SampleBSDF = SampleBSDF_x24init_0(_S628, _S628, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S629;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S630 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S630;
    var _S631 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S631;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S632 : vec3<f32> = vec3<f32>(1.0f);
    var _S633 : SampleBSDF = SampleBSDF_x24init_0(_S632, _S632, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S633;
    var _S634 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S634;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S635 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S635;
    var _S636 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S636;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S637 : vec3<f32> = ((-(in_dir_9)));
    var _S638 : f32 = dot(n_8, _S637);
    var _S639 : f32 = (sign((_S638)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S639);
    var _S640 : f32 = abs(_S638);
    var _S641 : f32 = material_19.roughness;
    var _S642 : f32 = _S641 * _S641;
    var _S643 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S644 : SheenProfile = sheenProfile(_S637, n_i_12, material_19);
    var _S645 : vec3<f32> = sampleHalfVector(_S637, n_i_12, _S642, _S643, &(random_state_15));
    var _S646 : BSDFLobes = bsdfLobes(in_dir_9, _S637, n_i_12, _S645, material_19, eta_i_14, eta_o_14, _S643, _S644);
    var lobes_13 : BSDFLobes = _S646;
    var _S647 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S647;
    var _S648 : Random = pcg(random_state_15);
    random_state_15 = _S648.state;
    var _S649 : bool = (_S648.value) < (lobes_13.p_sheen_velvet);
    if(_S649)
    {
        var _S650 : SampleBSDF = sheenVelvetSample(n_i_12, _S640, _S642, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S650;
    }
    var _S651 : f32 = _S648.value - lobes_13.p_sheen_velvet;
    var _S652 : bool = _S651 < (lobes_13.p_diffuse);
    if(_S652)
    {
        var _S653 : SampleBSDF = diffuseSample(_S651, n_i_12, _S640, _S642, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S653;
    }
    var _S654 : bool = _S651 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S654)
    {
        var _S655 : SampleBSDF = refractSample(_S645, n_i_12, _S640, _S642, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S655;
    }
    var _S656 : SampleBSDF = reflectSample(in_dir_9, _S645, n_i_12, _S640, _S642, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S656;
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S657 : bool = pdf_5 <= 0.0f;
    var _S658 : bool;
    if(_S657)
    {
        _S658 = true;
    }
    else
    {
        var _S659 : bool = environmentMapped_0();
        _S658 = !_S659;
    }
    if(_S658)
    {
        return 1.0f;
    }
    var _S660 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S660);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S661 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S661.x, max(_S661.y, _S661.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S662 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S663 : bool = (all((_S662 > vec2<u32>(u32(1)))));
    if(_S663)
    {
        var _S664 : vec3<f32> = (env_map_sample((dir_10)));
        return _S664;
    }
    var _S665 : vec3<f32> = (uniforms_float.ambient);
    return _S665;
}

fn walk_0( dom_1 : Domain,  r_4 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S666 : vec3<f32> = vec3<f32>(0.0f);
    var _S667 : Shift = Shift_x24init_0(_S666, 0.0f);
    var _S668 : u32 = (extractBits((r_4.path), (u32(0)), (u32(5))));
    var _S669 : u32 = (extractBits((r_4.path), (u32(5)), (u32(5))));
    var _S670 : u32 = (extractBits((r_4.path), (u32(10)), (u32(2))));
    var _S671 : u32 = (extractBits((r_4.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S672 : bool = _S671 >= u32(3);
        var _S673 : u32 = select(u32(0), u32(1), _S672);
        var _S674 : u32 = _S668 + _S673;
        var _S675 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S674 > _S675;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S667;
    }
    var _S676 : u32 = _S669 - u32(1);
    var _S677 : bool = _S671 == u32(3);
    var _S678 : u32 = select(u32(0), u32(1), _S677);
    var _S679 : u32 = _S668 + _S678;
    var _S680 : bool = _S670 == u32(0);
    var _S681 : u32 = select(_S676, _S679, _S680);
    var _S682 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_4.rc.zw))), r_4.rc.x, r_4.rc.y, u32(0), 0.0f);
    var _S683 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S684 : Ray = Ray_x24init_0(dom_1.x1, _S683);
    var ray_2 : Ray = _S684;
    var hit_2 : Hit = dom_1.hit;
    var _S685 : vec3<f32> = vec3<f32>(1.0f);
    var _S686 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S666, _S666, _S666);
    var nee_vertex_0 : NEEVertex = _S686;
    var _S687 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S687;
    var _S688 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S666, 0.0f, vec4<u32>(u32(0)), _S666, _S666);
    var chain_0 : Reservoir = _S688;
    chain_0.seed = r_4.seed;
    is_inside_5 = false;
    var threshold_0 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S666;
    var reconnection_0 : vec3<f32> = _S666;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S685;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S689 : bool = (hit_2.is_point_light) == u32(1);
        var _S690 : bool;
        if(replay_0)
        {
            _S690 = _S670 == u32(1);
        }
        else
        {
            _S690 = false;
        }
        var _S691 : bool;
        if(_S690)
        {
            _S691 = b_2 == _S669;
        }
        else
        {
            _S691 = false;
        }
        var _S692 : bool;
        if(_S691)
        {
            var _S693 : bool = (hit_2.instance_index) != (_S682.instance_index);
            if(_S693)
            {
                _S692 = true;
            }
            else
            {
                _S692 = (hit_2.triangle_index) != (_S682.triangle_index);
            }
        }
        else
        {
            _S692 = false;
        }
        if(_S692)
        {
            return _S667;
        }
        var _S694 : Surface = Surface_x24init_0(_S666, _S666, 0.0f, Material_x24init_0(_S666, _S666, 0.0f, 0.0f, 0.0f, 0.0f, _S666, _S685, 1.0f, _S666, _S666, 0.5f, 0.0f, 0.0f, _S666, 0.0f), false, u32(0));
        var _S695 : bool = !_S689;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S695)
        {
            var _S696 : u32 = stream(r_4.seed, b_2);
            var _S697 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S696)));
            var surface_6 : Surface = facingRay_0(_S697, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S698 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S699 : vec3<f32> = throughput_2 * _S698;
                front_n_0 = _S699;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S700 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S701 : bool = b_2 == u32(0);
            if(_S701)
            {
                var _S702 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S702;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S703 : vec3<f32> = front_n_0;
            var _S704 : f32 = geometry_density_0;
            scatter_0 = _S700;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S704;
            surface_5 = surface_6;
            front_n_0 = _S697.smooth_n;
            throughput_3 = _S703;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S694;
            front_n_0 = _S666;
            throughput_3 = throughput_2;
        }
        var _S705 : bool;
        if(scatter_0)
        {
            _S705 = prev_0.rough;
        }
        else
        {
            _S705 = false;
        }
        var _S706 : bool;
        if(_S705)
        {
            _S706 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S706 = false;
        }
        var _S707 : Surface = surface_5;
        var _S708 : Surface = surface_5;
        var _S709 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S710 : vec2<f32> = vertexEta(_S707.material, _S709);
        var _S711 : bool;
        if(scatter_0)
        {
            var _S712 : u32 = (uniforms_uint.max_bounces);
            var _S713 : bool = b_2 >= _S712;
            if(_S713)
            {
                _S711 = true;
            }
            else
            {
                var _S714 : bool = neeDecision(_S707.material, _S709, _S710.x, _S710.y);
                _S711 = _S714;
            }
        }
        else
        {
            _S711 = false;
        }
        var _S715 : bool = isTranslucent_0(_S707.material);
        var _S716 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S717 : vec3<f32> = _S707.material.emissive * vec3<f32>(max(_S716, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S689)
        {
            var _S718 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S718;
        }
        else
        {
            emission_0 = _S717;
        }
        var _S719 : bool = !replay_0;
        var _S720 : bool;
        if(_S719)
        {
            _S720 = true;
        }
        else
        {
            _S720 = b_2 >= _S681;
        }
        var _S721 : bool;
        if(_S720)
        {
            var _S722 : f32 = rgb_to_greyscale(emission_0);
            _S721 = _S722 > 0.0f;
        }
        else
        {
            _S721 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S721)
        {
            var _S723 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S723);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S724 : bool;
        if(replay_0)
        {
            _S724 = _S670 == u32(1);
        }
        else
        {
            _S724 = false;
        }
        var _S725 : bool;
        if(_S724)
        {
            _S725 = b_2 > _S669;
        }
        else
        {
            _S725 = false;
        }
        var _S726 : bool;
        if(_S725)
        {
            _S726 = b_2 == _S668;
        }
        else
        {
            _S726 = false;
        }
        var _S727 : bool;
        if(_S726)
        {
            var _S728 : bool = _S671 == u32(1);
            if(_S728)
            {
                _S727 = true;
            }
            else
            {
                _S727 = _S671 == u32(2);
            }
        }
        else
        {
            _S727 = false;
        }
        if(_S727)
        {
            var _S729 : bool = _S689 != (_S671 == u32(2));
            if(_S729)
            {
                return _S667;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S730 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S731 : bool = _S730 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S732 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S733 : u32 = (insertBits((_S732), (u32(1)), (u32(10)), (u32(2))));
        var _S734 : u32 = (insertBits((_S733), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S735 : bool = prev_0.inside;
        var _S736 : u32 = select(u32(0), u32(1), _S735);
        var _S737 : u32 = (insertBits((_S734), (_S736), (u32(22)), (u32(1))));
        here_0.path = _S737;
        var _S738 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S738;
        var _S739 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S739;
        var _S740 : bool;
        if(replay_0)
        {
            _S740 = _S670 == u32(1);
        }
        else
        {
            _S740 = false;
        }
        var _S741 : bool;
        if(_S740)
        {
            _S741 = b_2 == _S669;
        }
        else
        {
            _S741 = false;
        }
        var _S742 : bool = b_2 == _S681;
        var _S743 : bool;
        if(_S742)
        {
            var _S744 : bool = !scatter_0;
            if(_S744)
            {
                _S743 = true;
            }
            else
            {
                var _S745 : bool = _S670 != u32(1);
                if(_S745)
                {
                    _S743 = _S670 != u32(3);
                }
                else
                {
                    _S743 = false;
                }
            }
        }
        else
        {
            _S743 = false;
        }
        var _S746 : bool;
        if(_S743)
        {
            _S746 = _S670 == u32(2);
        }
        else
        {
            _S746 = false;
        }
        var _S747 : bool;
        if(_S746)
        {
            _S747 = !_S706;
        }
        else
        {
            _S747 = false;
        }
        var _S748 : bool;
        if(_S747)
        {
            _S748 = _S671 != u32(4);
        }
        else
        {
            _S748 = false;
        }
        var _S749 : bool = _S669 == _S668;
        var _S750 : bool;
        if(_S749)
        {
            _S750 = _S671 == u32(0);
        }
        else
        {
            _S750 = false;
        }
        var _S751 : bool;
        if(_S750)
        {
            _S751 = (hit_2.instance_index) == (_S682.instance_index);
        }
        else
        {
            _S751 = false;
        }
        var _S752 : bool;
        if(_S751)
        {
            _S752 = (hit_2.triangle_index) == (_S682.triangle_index);
        }
        else
        {
            _S752 = false;
        }
        var _S753 : bool;
        if(_S752)
        {
            _S753 = _S706;
        }
        else
        {
            _S753 = false;
        }
        var _S754 : bool = select(_S748, _S753, _S741);
        var _S755 : bool;
        if(_S711)
        {
            _S755 = select(scatter_0, _S754, replay_0);
        }
        else
        {
            _S755 = false;
        }
        var _S756 : TreeSample = TreeSample_x24init_0(_S666, _S666, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S755)
        {
            var _S757 : Surface = surface_5;
            var _S758 : bool = isTranslucent_0(_S707.material);
            var _S759 : u32 = stream(r_4.seed, b_2 + u32(64));
            var _S760 : TreeSample = sampleLightTree_0(ray_2.origin, _S708.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S758, _S759);
            var _S761 : bool = (any(((_S760.radiance) != _S666)));
            if(_S761)
            {
                var _S762 : f32 = _S710.x;
                var _S763 : f32 = _S710.y;
                var _S764 : u32 = (uniforms_uint.max_bounces);
                var _S765 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S760, _S708.smooth_n, _S757.geometry_n, _S707.material, _S762, _S763, b_2 < _S764, surface_5.random_state);
                lit_0 = _S765;
            }
            else
            {
                lit_0 = _S666;
            }
            light_1 = _S760;
        }
        else
        {
            light_1 = _S756;
            lit_0 = _S666;
        }
        var _S766 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S767 : bool;
        var _S768 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S741)
        {
            var _S769 : bool = !_S706;
            if(_S769)
            {
                return _S667;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S749)
            {
                _S766 = _S671 == u32(1);
            }
            else
            {
                _S766 = false;
            }
            if(_S766)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S749)
            {
                wrong_side_0 = _S671 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S770 : bool = !_S711;
                if(_S770)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S771 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S771 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S667;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S749)
            {
                refracted_4 = _S671 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S772 : bool = !_S711;
                if(_S772)
                {
                    return _S667;
                }
                var _S773 : f32 = environmentPdf_0(r_4.dir);
                var _S774 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S710, is_inside_5, _S773, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S774 * r_4.radiance / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S775 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S776 : bool = _S711 != (_S775 == u32(1));
            if(_S776)
            {
                return _S667;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S766 = _S742;
            }
            else
            {
                _S766 = false;
            }
            if(_S766)
            {
                var _S777 : bool = !scatter_0;
                if(_S777)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S778 : bool = _S670 != u32(1);
                    if(_S778)
                    {
                        wrong_side_0 = _S670 != u32(3);
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
                var _S779 : bool = _S670 == u32(2);
                if(_S779)
                {
                    _S690 = _S711;
                }
                else
                {
                    _S690 = false;
                }
                if(_S690)
                {
                    _S690 = !_S706;
                }
                else
                {
                    _S690 = false;
                }
                if(_S690)
                {
                    _S690 = _S671 == u32(4);
                }
                else
                {
                    _S690 = false;
                }
                if(_S690)
                {
                    var _S780 : u32 = stream(r_4.seed, b_2 + u32(256));
                    var _S781 : SkySample = sampleSky_0(ray_2, surface_5, _S710, is_inside_5, _S780, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S781.color, 1.0f);
                }
                if(_S779)
                {
                    is_inside_5 = _S711;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S706;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S782 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S783 : bool = !(_S782 > 0.0f);
                    if(_S783)
                    {
                        return _S667;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S680)
                {
                    is_inside_5 = _S671 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S689;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S680)
                {
                    is_inside_5 = _S671 == u32(1);
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
                    is_inside_5 = !_S706;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S667;
            }
            else
            {
                if(_S719)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S784 : bool = b_2 > u32(0);
                    if(_S784)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S731)
                        {
                            var _S785 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S785;
                        }
                        else
                        {
                            if(_S706)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S786 : vec3<f32> = throughput_3 * emission_1;
                        var _S787 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S786);
                        offer(&((*sel_1)), _S787, _S786 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S711)
                    {
                        var _S788 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S731)
                        {
                            var _S789 : vec3<f32> = safeDivide(_S788, chain_throughput_0);
                            candidate_3.radiance = _S789;
                        }
                        else
                        {
                            if(_S706)
                            {
                                candidate_3 = here_0;
                                var _S790 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S790;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S791 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S792 : u32 = (insertBits((_S791), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S792;
                            }
                        }
                        var _S793 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S788);
                        offer(&((*sel_1)), _S793, _S788 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S711)
                    {
                        var _S794 : bool = environmentMapped_0();
                        _S767 = _S794;
                    }
                    else
                    {
                        _S767 = false;
                    }
                    if(_S767)
                    {
                        var _S795 : u32 = (uniforms_uint.max_bounces);
                        _S768 = b_2 < _S795;
                    }
                    else
                    {
                        _S768 = false;
                    }
                    if(_S768)
                    {
                        var _S796 : u32 = stream(r_4.seed, b_2 + u32(256));
                        var _S797 : SkySample = sampleSky_0(ray_2, surface_5, _S710, is_inside_5, _S796, surface_5.random_state);
                        var _S798 : vec3<f32> = throughput_3 * _S797.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S731)
                        {
                            var _S799 : vec3<f32> = safeDivide(_S798, chain_throughput_0);
                            candidate_4.radiance = _S799;
                        }
                        else
                        {
                            if(_S706)
                            {
                                candidate_4 = here_0;
                                var _S800 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S800;
                                candidate_4.dir = _S797.dir;
                                candidate_4.radiance = _S797.radiance;
                            }
                            else
                            {
                                var _S801 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S802 : u32 = (insertBits((_S801), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S802;
                            }
                        }
                        var _S803 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S798);
                        offer(&((*sel_1)), _S803, _S798 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S804 : bool;
        var _S805 : bool;
        var straight_0 : bool;
        var _S806 : bool;
        var _S807 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S766 = _S742;
            }
            else
            {
                _S766 = false;
            }
            var _S808 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S809 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S810 : u32 = select(_S808, _S809, _S741);
            var refracted_5 : bool = _S810 == u32(1);
            var _S811 : SampleBSDF = SampleBSDF_x24init_0(_S666, _S666, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S811;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S766)
            {
                var _S812 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S813 : bool = is_inside_5 != (_S812 == u32(1));
                if(_S813)
                {
                    return _S667;
                }
                var _S814 : bool = _S670 == u32(1);
                if(_S814)
                {
                    var _S815 : vec3<f32> = (hitPosition((_S682)));
                    dir_11 = _S815;
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
                    var _S816 : bool = isTranslucent_0(_S707.material);
                    if(_S816)
                    {
                        wrong_side_0 = _S810 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S817 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S818 : vec3<f32> = select(r_4.dir, _S817, _S814);
                        refracted_4 = (dot(_S708.smooth_n, _S818) * _S709) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S814)
                {
                    var _S819 : vec3<f32> = ray_2.origin;
                    var _S820 : Surface = surface_5;
                    var _S821 : vec3<f32> = (vec3<f32>(0) - _S708.smooth_n);
                    var _S822 : bool = is_inside_5 != refracted_4;
                    var _S823 : vec3<f32> = select(_S708.smooth_n, _S821, _S822);
                    var _S824 : vec3<f32> = (normalize((dir_11 - (_S819 + vec3<f32>(_S820.geometry_offset) * _S823))));
                    reconnection_1 = _S824;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S825 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S825)
                {
                    return _S667;
                }
                var _S826 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S810;
                wrong_side_0 = false;
                reconnection_1 = _S826;
            }
            else
            {
                var _S827 : bool = !_S741;
                if(_S827)
                {
                    var _S828 : f32 = _S710.x;
                    var _S829 : f32 = _S710.y;
                    var _S830 : vec2<f32> = vec2<f32>(0.0f);
                    var _S831 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S708.smooth_n, _S707.material, _S828, _S829, surface_5.random_state, _S830);
                    var bsdf_sampled_0 : SampleBSDF = _S831;
                    var _S832 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S707.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S833 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S832.geometry_n, _S707.material, _S828, _S829, bsdf_sampled_0.random_state, _S830);
                        bsdf_sampled_0.unit_direction = _S833.unit_direction;
                        bsdf_sampled_0.refracted = _S833.refracted;
                        bsdf_sampled_0.throughput = _S833.throughput;
                        bsdf_sampled_0.lobe = _S833.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S834 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S832.geometry_n))) * _S832.geometry_n;
                            bsdf_sampled_0.unit_direction = _S834;
                        }
                    }
                    var _S835 : u32 = bsdf_sampled_0.lobe;
                    var _S836 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S837 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S838 : f32 = bsdf_sampled_0.pdf;
                    var _S839 : f32 = select(_S838, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S839;
                    dir_11 = _S836;
                    lobe_index_0 = _S835;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S837;
                }
                else
                {
                    dir_11 = r_4.dir;
                    lobe_index_0 = _S810;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S766)
            {
                _S767 = true;
            }
            else
            {
                _S767 = _S741;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S767)
            {
                var _S840 : vec3<f32> = ray_2.unit_direction;
                var _S841 : f32 = (sign((_S709)));
                var _S842 : vec3<f32> = _S708.smooth_n * vec3<f32>(_S841);
                var _S843 : f32 = dot(_S842, dir_11);
                var _S844 : f32 = _S707.material.roughness;
                var _S845 : f32 = _S844 * _S844;
                var _S846 : AnisotropicFrame = anisotropicFrame(_S707.material, _S842);
                var _S847 : vec3<f32> = ((-(_S840)));
                var _S848 : SheenProfile = sheenProfile(_S847, _S842, _S707.material);
                var _S849 : vec3<f32> = reflectedHalf(_S840, dir_11);
                var _S850 : bool = lobe_index_0 == u32(1);
                if(_S850)
                {
                    var _S851 : vec3<f32> = refractedHalf(_S840, dir_11, _S708.smooth_n, _S710.x, _S710.y);
                    throughput_6 = _S851;
                }
                else
                {
                    throughput_6 = _S849;
                }
                var _S852 : bool = lobe_index_0 == u32(0);
                if(_S852)
                {
                    _S768 = true;
                }
                else
                {
                    _S768 = lobe_index_0 == u32(6);
                }
                if(_S768)
                {
                    var _S853 : vec3<f32> = sampledHalf(_S840, _S708.smooth_n, _S707.material, surface_5.random_state, _S846);
                    throughput_7 = _S853;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S854 : vec3<f32> = ((-(_S840)));
                var _S855 : f32 = _S710.x;
                var _S856 : f32 = _S710.y;
                var _S857 : BSDFLobes = bsdfLobes(_S840, _S854, _S842, throughput_7, _S707.material, _S855, _S856, _S846, _S848);
                var lobe_terms_1 : BSDFLobes = _S857;
                var _S858 : f32 = translucentShare(_S707.material);
                lobe_terms_1.translucent_share = _S858;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S859 : f32 = diffusePDF(_S843, 0.0f, abs(_S709), _S845, lobe_terms_1, _S855, _S856);
                        var _S860 : vec3<f32> = diffuseBSDF(dir_11, _S842, _S845, _S707.material, lobe_terms_1);
                        density_5 = _S859;
                        chain_throughput_1 = _S860;
                    }
                case u32(1):
                    {
                        var _S861 : f32 = refractPDF(_S843, dot(dir_11, throughput_7), abs(_S709), _S845, lobe_terms_1, _S855, _S856);
                        var _S862 : vec3<f32> = refractBSDF(dir_11, _S842, _S845, _S707.material, lobe_terms_1);
                        density_5 = _S861;
                        chain_throughput_1 = _S862;
                    }
                case u32(4):
                    {
                        var _S863 : f32 = sheenVelvetPDF(_S843, 0.0f, abs(_S709), _S845, lobe_terms_1, _S855, _S856);
                        var _S864 : vec3<f32> = sheenVelvetBSDF(dir_11, _S842, _S845, _S707.material, lobe_terms_1);
                        density_5 = _S863;
                        chain_throughput_1 = _S864;
                    }
                default :
                    {
                        var _S865 : f32 = reflectPDF(_S843, 0.0f, abs(_S709), _S845, lobe_terms_1, _S855, _S856);
                        var _S866 : vec3<f32> = reflectBSDF(dir_11, _S842, _S845, _S707.material, lobe_terms_1);
                        density_5 = _S865;
                        chain_throughput_1 = _S866;
                    }
                }
                var _S867 : bool = density_5 > 0.0f;
                if(_S867)
                {
                    var _S868 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, surface_5.random_state, _S850, lobe_index_0, density_5);
                    lobe_2 = _S868;
                }
            }
            var _S869 : bool = lobe_index_0 == u32(0);
            if(_S869)
            {
                _S768 = true;
            }
            else
            {
                _S768 = lobe_index_0 == u32(4);
            }
            if(_S768)
            {
                _S804 = true;
            }
            else
            {
                _S804 = lobe_index_0 == u32(6);
            }
            var _S870 : bool = !_S804;
            if(_S870)
            {
                var _S871 : bool = (_S707.material.roughness) == 0.0f;
                if(_S871)
                {
                    _S805 = true;
                }
                else
                {
                    var _S872 : bool = lobe_index_0 == u32(1);
                    if(_S872)
                    {
                        _S805 = (_S710.x) == (_S710.y);
                    }
                    else
                    {
                        _S805 = false;
                    }
                }
            }
            else
            {
                _S805 = false;
            }
            var _S873 : bool = lobe_index_0 == u32(1);
            if(_S873)
            {
                straight_0 = (_S707.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S874 : bool = isTranslucent_0(_S707.material);
            if(_S874)
            {
                _S806 = _S869;
            }
            else
            {
                _S806 = false;
            }
            if(_S806)
            {
                _S807 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S807 = false;
            }
            var _S875 : bool;
            if(_S711)
            {
                _S875 = !_S805;
            }
            else
            {
                _S875 = false;
            }
            var _S876 : bool;
            if(_S875)
            {
                _S876 = !wrong_side_0;
            }
            else
            {
                _S876 = false;
            }
            var _S877 : bool;
            if(_S876)
            {
                var _S878 : f32 = lobe_2.pdf;
                var _S879 : vec3<f32> = ray_2.origin;
                var _S880 : vec3<f32> = select(_S708.smooth_n, _S666, _S715);
                var _S881 : vec3<f32> = ray_2.origin;
                var _S882 : Surface = surface_5;
                var _S883 : vec3<f32> = (vec3<f32>(0) - _S708.smooth_n);
                var _S884 : vec3<f32> = select(_S708.smooth_n, _S883, _S807);
                var _S885 : NEEVertex = NEEVertex_x24init_0(false, _S878, _S879, _S880, _S881 + vec3<f32>(_S882.geometry_offset) * _S884);
                nee_vertex_0 = _S885;
            }
            else
            {
                var _S886 : bool = lobe_index_0 != u32(1);
                if(_S886)
                {
                    _S877 = true;
                }
                else
                {
                    _S877 = (_S710.x) != (_S710.y);
                }
                if(_S877)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S887 : bool = (lobe_2.pdf) > 0.0f;
            if(_S887)
            {
                if(_S804)
                {
                    _S877 = true;
                }
                else
                {
                    _S877 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S877 = false;
            }
            var _S888 : bool = (lobe_2.pdf) > 0.0f;
            var _S889 : bool;
            if(_S888)
            {
                if(_S804)
                {
                    _S889 = true;
                }
                else
                {
                    _S889 = (_S707.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S889 = false;
            }
            var _S890 : bool;
            if(_S741)
            {
                var _S891 : bool = !_S877;
                if(_S891)
                {
                    return _S667;
                }
                var _S892 : bool = _S671 != u32(1);
                if(_S892)
                {
                    _S890 = _S671 != u32(2);
                }
                else
                {
                    _S890 = false;
                }
                if(_S890)
                {
                    var _S893 : f32 = lobe_2.pdf;
                    var _S894 : f32 = select(0.0f, _S893, _S711);
                    var _S895 : f32 = escapeWeight_0(_S894, r_4.dir);
                    if(_S749)
                    {
                        is_inside_5 = _S677;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S896 : f32 = select(1.0f, _S895, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S896) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S897 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S898 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S897;
                density_5 = _S898;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S890 = b_2 <= _S681;
            }
            else
            {
                _S890 = false;
            }
            var _S899 : bool;
            if(_S890)
            {
                _S899 = _S706;
            }
            else
            {
                _S899 = false;
            }
            var _S900 : bool;
            if(_S899)
            {
                _S900 = _S877;
            }
            else
            {
                _S900 = false;
            }
            var _S901 : bool;
            if(_S900)
            {
                _S901 = true;
            }
            else
            {
                if(_S766)
                {
                    _S901 = !_S889;
                }
                else
                {
                    _S901 = false;
                }
            }
            if(_S901)
            {
                return _S667;
            }
            if(_S766)
            {
                var _S902 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S903 : f32 = lobe_2.pdf;
                throughput_7 = _S902;
                survival_probability_0 = _S903;
            }
            else
            {
                var _S904 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S666);
                throughput_7 = _S904;
                survival_probability_0 = density_5;
            }
            var _S905 : bool;
            if(_S719)
            {
                _S905 = !_S731;
            }
            else
            {
                _S905 = false;
            }
            var _S906 : bool;
            if(_S905)
            {
                _S906 = _S706;
            }
            else
            {
                _S906 = false;
            }
            var _S907 : bool;
            if(_S906)
            {
                _S907 = _S877;
            }
            else
            {
                _S907 = false;
            }
            if(_S907)
            {
                chain_0 = here_0;
                var _S908 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S909 : u32 = select(u32(0), u32(1), _S711);
                var _S910 : u32 = (insertBits((_S908), (_S909), (u32(21)), (u32(1))));
                chain_0.path = _S910;
                var _S911 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S911;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S912 : Vertex = Vertex_x24init_0(_S889, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S912;
            var _S913 : f32 = lobe_2.pdf;
            var _S914 : bool;
            if(_S873)
            {
                _S914 = (_S710.x) == (_S710.y);
            }
            else
            {
                _S914 = false;
            }
            var _S915 : f32 = select(_S913, sky_pdf_0, _S914);
            var _S916 : bool;
            if(refracted_4)
            {
                _S916 = !_S807;
            }
            else
            {
                _S916 = false;
            }
            var is_inside_6 : bool;
            if(_S916)
            {
                var _S917 : bool = !is_inside_5;
                is_inside_6 = _S917;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S918 : Surface = surface_5;
            var _S919 : f32 = select(_S918.geometry_offset, 0.0f, straight_0);
            var _S920 : vec3<f32> = (vec3<f32>(0) - _S708.smooth_n);
            var _S921 : bool = is_inside_6 != _S807;
            var _S922 : vec3<f32> = select(_S708.smooth_n, _S920, _S921);
            var _S923 : vec3<f32> = ray_2.origin + vec3<f32>(_S919) * _S922;
            ray_2.origin = _S923;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S915;
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
        if(_S719)
        {
            if(_S689)
            {
                var _S924 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S925 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S926 : bool = _S925 == u32(1);
                if(_S926)
                {
                    var _S927 : vec3<f32> = safeDivide(_S924, chain_throughput_0);
                    candidate_5.radiance = _S927;
                }
                var _S928 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S924);
                offer(&((*sel_1)), _S928, _S924 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S689)
            {
                _S766 = true;
            }
            else
            {
                _S766 = scatter_0;
            }
            if(_S766)
            {
                var _S929 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S929;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S930 : u32 = stream(r_4.seed, b_2 + u32(128));
            var _S931 : Random = pcg(_S930);
            var _S932 : bool = survival_probability_0 < (_S931.value);
            if(_S932)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S933 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S933;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S934 : f32 = density_5 * survival_probability_0;
            density_2 = _S934;
        }
        else
        {
            density_2 = density_5;
        }
        var _S935 : Ray = ray_2;
        var _S936 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S766 = _S742;
        }
        else
        {
            _S766 = false;
        }
        if(_S766)
        {
            wrong_side_0 = _S670 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S937 : f32 = select(4.294967296e+09f, _S936, wrong_side_0);
        var _S938 : Hit;
        if(straight_0)
        {
            _S938 = hit_2;
        }
        else
        {
            _S938 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S939 : Hit = (traverseInstanceBVH((_S935), (_S695), (_S937), (_S938)));
        hit_2 = _S939;
        if(replay_0)
        {
            refracted_4 = _S742;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S767 = _S670 == u32(1);
        }
        else
        {
            _S767 = false;
        }
        if(_S767)
        {
            _S768 = (hit_2.instance_index) == (_S682.instance_index);
        }
        else
        {
            _S768 = false;
        }
        if(_S768)
        {
            _S804 = (hit_2.triangle_index) == (_S682.triangle_index);
        }
        else
        {
            _S804 = false;
        }
        if(_S804)
        {
            hit_2.uv = _S682.uv;
            var _S940 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S940;
        }
        if(replay_0)
        {
            _S805 = _S742;
        }
        else
        {
            _S805 = false;
        }
        if(_S805)
        {
            _S806 = _S670 == u32(3);
        }
        else
        {
            _S806 = false;
        }
        if(_S806)
        {
            _S807 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
        {
            return _S667;
        }
        var _S941 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S941)
        {
            var _S942 : bool = !nee_vertex_0.none;
            var _S943 : f32 = select(0.0f, sky_pdf_0, _S942);
            var _S944 : f32 = escapeWeight_0(_S943, ray_2.unit_direction);
            var _S945 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S946 : vec3<f32> = throughput_2 * _S945;
            if(replay_0)
            {
                if(_S742)
                {
                    is_inside_5 = _S670 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S946 * vec3<f32>(_S944) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
                }
                if(_S680)
                {
                    is_inside_5 = _S677;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S668;
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
                    return Shift_x24init_0(_S946 * vec3<f32>(_S944), 1.0f);
                }
                return _S667;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S947 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S948 : bool = _S947 == u32(1);
            if(_S948)
            {
                var _S949 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S950 : bool = _S949 == b_2;
                var _S951 : f32 = select(_S944, 1.0f, _S950);
                var _S952 : vec3<f32> = safeDivide(_S946 * vec3<f32>(_S951), chain_throughput_0);
                candidate_6.radiance = _S952;
            }
            else
            {
                var _S953 : bool = prev_0.rough;
                if(_S953)
                {
                    var _S954 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S955 : u32 = (insertBits((_S954), (u32(3)), (u32(10)), (u32(2))));
                    var _S956 : u32 = (insertBits((_S955), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S957 : bool = prev_0.inside;
                    var _S958 : u32 = select(u32(0), u32(1), _S957);
                    var _S959 : u32 = (insertBits((_S956), (_S958), (u32(22)), (u32(1))));
                    candidate_6.path = _S959;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S960 : vec3<f32> = _S946 * vec3<f32>(_S944);
            var _S961 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S960);
            offer(&((*sel_1)), _S961, _S960 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S962 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S962;
        var _S963 : u32 = b_2 + u32(1);
        b_2 = _S963;
    }
    return _S667;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S964 : vec3<f32> = vec3<f32>(0.0f);
    var _S965 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S964, 0.0f, vec4<u32>(u32(0)), _S964, _S964), 0.0f, _S964, u32(0));
    var sel_2 : Selection = _S965;
    var _S966 : bool = (r_5.w) <= 0.0f;
    if(_S966)
    {
        return Shift_x24init_0(_S964, 0.0f);
    }
    var _S967 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S967;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S968 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S968;
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
        var _S969 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S970 : u32 = (_S969 + u32(63)) / u32(64);
        var _S971 : bool = group_0 < _S970;
        if(_S971)
        {
            var _S972 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S973 : bool = _S972 < _S969;
            if(_S973)
            {
                var _S974 : u32 = (queued_shifts[(u32(83) + start_4 + _S972)]);
                return _S974;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S970;
        var start_5 : u32 = start_4 + _S969;
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
    var _S975 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S976 : u32 = t_5;
        var _S977 : bool = (bins_1[t_5]) < u32(40);
        if(_S977)
        {
            var _S978 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S976]]), u32(1));
            slots_0[t_5] = _S978;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S979 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S979)
    {
        var _S980 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S981 : bool = _S980 > u32(0);
        if(_S981)
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
                var _S982 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S982;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S983 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S980)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S983;
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
        var _S984 : u32 = t_5;
        var _S985 : bool = (bins_1[t_5]) < u32(40);
        if(_S985)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S984]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S986 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S986)
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
            var _S987 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S987 + u32(63)) / u32(64);
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
    var _S988 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S989 : vec2<f32> = vec2<f32>(0.5f);
    var _S990 : vec2<f32> = _S988.xy / vec2<f32>(_S988.z) * _S989 + _S989;
    var _S991 : vec2<f32> = vec2<f32>(_S990.x, 1.0f - _S990.y);
    var _S992 : vec2<u32> = (uniforms_uint.render_size);
    return _S991 * vec2<f32>(_S992);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S993 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S994 : bool;
    if(_S993)
    {
        var _S995 : vec2<u32> = (uniforms_uint.render_size);
        _S994 = (all((q_0 < vec2<i32>(_S995))));
    }
    else
    {
        _S994 = false;
    }
    if(_S994)
    {
        var _S996 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S994 = (bitcast<f32>((_S996.w))) > 0.0f;
    }
    else
    {
        _S994 = false;
    }
    return _S994;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S997 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S998 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S999 : vec2<f32> = project_0(_S997, _S998, dom_3.x1);
    var _S1000 : vec2<i32> = vec2<i32>(floor(_S999));
    var _S1001 : bool = previousValid_0(_S1000);
    var _S1002 : bool = !_S1001;
    if(_S1002)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1003 : Domain = (previousDomain((_S1000)));
    var _S1004 : bool = (_S1003.hit.instance_index) == (dom_3.hit.instance_index);
    var _S1005 : bool;
    if(_S1004)
    {
        var _S1006 : f32 = distance(_S1003.x1, dom_3.x1);
        var _S1007 : f32 = dom_3.hit.distance * 8.0f;
        var _S1008 : vec2<u32> = (uniforms_uint.render_size);
        _S1005 = _S1006 <= (_S1007 / f32(_S1008.x));
    }
    else
    {
        _S1005 = false;
    }
    if(_S1005)
    {
        return _S1000;
    }
    var _S1009 : vec2<f32> = vec2<f32>(p_9 + _S1000) + vec2<f32>(1.0f);
    var _S1010 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S1011 : vec3<f32> = (uniforms_float.camera_position);
    var _S1012 : vec2<f32> = project_0(_S1010, _S1011, _S1003.x1);
    var _S1013 : vec2<i32> = vec2<i32>(floor(_S1009 - _S1012));
    var _S1014 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1015 : bool = previousValid_0(_S1013);
    var _S1016 : vec2<i32> = select(_S1014, _S1013, _S1015);
    return _S1016;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S1017 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S1018 : bool;
    if(_S1017)
    {
        _S1018 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S1018 = false;
    }
    if(_S1018)
    {
        _S1018 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S1018 = false;
    }
    if(_S1018)
    {
        _S1018 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S1018 = false;
    }
    return _S1018;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1019 : vec3<f32> = vec3<f32>(0.0f);
    var _S1020 : Domain = Domain_x24init_0(_S1019, _S1019, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1020;
    var _S1021 : bool = t_8 > u32(1);
    var _S1022 : bool;
    if(_S1021)
    {
        _S1022 = true;
    }
    else
    {
        var _S1023 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1022 = !_S1023;
    }
    if(_S1022)
    {
        return false;
    }
    var _S1024 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1025 : bool = (_S1024.x) < i32(0);
    if(_S1025)
    {
        return false;
    }
    var _S1026 : bool = t_8 == u32(0);
    if(_S1026)
    {
        var _S1027 : Reservoir = (loadReservoir(reservoir_prev, (_S1024)));
        var _S1028 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1027);
        (*job_2) = _S1028;
    }
    else
    {
        var _S1029 : Domain = (previousDomain((_S1024)));
        var _S1030 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1031 : ShiftJob = ShiftJob_x24init_0(_S1029, _S1030);
        (*job_2) = _S1031;
    }
    var _S1032 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1032)
    {
        if(_S1026)
        {
            _S1022 = true;
        }
        else
        {
            var _S1033 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1022 = !_S1033;
        }
    }
    else
    {
        _S1022 = false;
    }
    return _S1022;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1034 : ptr<function, array<u32, i32(3)>>)
{
    var _S1035 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S1036 : vec3<f32> = vec3<f32>(0.0f);
        var _S1037 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1036, _S1036, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1036, 0.0f, vec4<u32>(u32(0)), _S1036, _S1036));
        var job_3 : ShiftJob = _S1037;
        var _S1038 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1038)
        {
            var _S1039 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1039;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1034) = bins_2;
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
        var _S1040 : u32 = t_11;
        var _S1041 : bool = (bins_3[t_11]) < u32(40);
        if(_S1041)
        {
            var _S1042 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1040]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1043 : bool = local_invocation_index_2 < u32(40);
    if(_S1043)
    {
        var _S1044 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1045 : bool = _S1044 > u32(0);
        if(_S1045)
        {
            var _S1046 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1044)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1047 : vec2<u32> = global_invocation_id_1.xy;
    var _S1048 : vec2<i32> = vec2<i32>(_S1047 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1049 : vec2<i32> = _S1048 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1050 : bool = (all((_S1049 >= vec2<i32>(i32(0)))));
        var _S1051 : bool;
        if(_S1050)
        {
            var _S1052 : vec2<u32> = (uniforms_uint.render_size);
            _S1051 = (all((_S1049 < vec2<i32>(_S1052))));
        }
        else
        {
            _S1051 = false;
        }
        if(_S1051)
        {
            var _S1053 : vec4<u32> = (textureLoad(reservoir_prev, (_S1049), (u32(0)), 0));
            var _S1054 : u32 = _S1053.x;
            var _S1055 : bool = (bitcast<f32>((_S1053.z))) > 0.0f;
            var _S1056 : u32 = select(u32(0), _S1054, _S1055);
            seed_2 = _S1056;
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
    var _S1057 : u32 = local_invocation_id_0.y;
    var _S1058 : u32 = local_invocation_id_0.x;
    var _S1059 : u32 = duplication_seeds_0[(_S1057 + u32(8)) * u32(24) + _S1058 + u32(8)];
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
            var _S1060 : bool = (duplication_seeds_0[(_S1057 + seed_2) * u32(24) + _S1058 + x_1]) == _S1059;
            var _S1061 : u32 = select(u32(0), u32(1), _S1060);
            var count_2 : u32 = count_1 + _S1061;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1062 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1063 : bool = _S1059 != u32(0);
    var _S1064 : f32 = select(0.0f, _S1062, _S1063);
    textureStore(duplication_out, (vec2<i32>(_S1047)), 0, (vec4<u32>((bitcast<u32>((_S1064))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1065 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1065;
    var _S1066 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1066;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1067 : f32 = rgb_to_greyscale(r_7.f);
    var _S1068 : f32 = sel_4.w_sum / _S1067;
    var _S1069 : bool = _S1067 > 0.0f;
    var _S1070 : f32 = select(0.0f, _S1068, _S1069);
    r_7.w = _S1070;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1071 : vec2<u32> = global_invocation_id_2.xy;
    var _S1072 : vec2<i32> = vec2<i32>(_S1071);
    var _S1073 : vec3<f32> = vec3<f32>(0.0f);
    var _S1074 : Domain = Domain_x24init_0(_S1073, _S1073, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1074;
    var _S1075 : bool = (currentDomain((_S1072), &(dom_5)));
    var _S1076 : bool = !_S1075;
    if(_S1076)
    {
        storeReservoir(reservoir_prev_out, (_S1072), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1073, 0.0f, vec4<u32>(u32(0)), _S1073, _S1073)), (dom_5.hit));
        var _S1077 : vec2<f32> = vec2<f32>(_S1071);
        var _S1078 : vec2<u32> = (uniforms_uint.render_size);
        var _S1079 : vec2<f32> = _S1077 / vec2<f32>(_S1078.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1080 : vec3<f32> = vec3<f32>(_S1079, 1.0f);
        var _S1081 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1082 : vec3<f32> = (normalize(((((_S1081) * (_S1080))))));
        var _S1083 : vec3<f32> = environment_0(_S1082);
        textureStore(compute_out, (_S1072), (u32(0)), (vec4<f32>(_S1083, 1.0f)));
        var _S1084 : u32 = (uniforms_uint.is_temporal);
        var _S1085 : bool = _S1084 == u32(1);
        if(_S1085)
        {
            textureStore(compute_out, (_S1072), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1086 : Reservoir = (loadReservoir(reservoir_temp, (_S1072)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1086.c;
    loop
    {
        var _S1087 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1087)
        {
        }
        else
        {
            break;
        }
        var _S1088 : vec2<i32> = partner_0(_S1072, t_13);
        var neighbor_0 : Domain = _S1074;
        var _S1089 : bool = (currentDomain((_S1088), &(neighbor_0)));
        if(_S1089)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1090 : vec4<u32> = (textureLoad(reservoir_temp, (_S1088), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1090.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1091 : f32 = _S1086.c / max(count_3, 1.0f);
    var _S1092 : f32 = rgb_to_greyscale(_S1086.f);
    var _S1093 : bool = count_3 == 0.0f;
    var _S1094 : f32 = select(0.0f, 1.0f, _S1093);
    var _S1095 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1073, 0.0f, vec4<u32>(u32(0)), _S1073, _S1073), 0.0f, _S1073, u32(0));
    var sel_5 : Selection = _S1095;
    var _S1096 : u32 = (uniforms_uint.frame);
    var _S1097 : u32 = hash(_S1096);
    var _S1098 : u32 = global_invocation_id_2.x;
    var _S1099 : vec2<u32> = (uniforms_uint.render_size);
    var _S1100 : u32 = stream(_S1097, _S1098 + _S1099.x * global_invocation_id_2.y);
    var _S1101 : u32 = stream(_S1100, u32(195));
    sel_5.random_state = _S1101;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1094;
    loop
    {
        var _S1102 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1102)
        {
        }
        else
        {
            break;
        }
        var _S1103 : vec2<i32> = partner_0(_S1072, t_13);
        var neighbor_dom_0 : Domain = _S1074;
        var _S1104 : bool = (currentDomain((_S1103), &(neighbor_dom_0)));
        if(_S1104)
        {
            var _S1105 : Reservoir = (loadReservoir(reservoir_temp, (_S1103)));
            var _S1106 : vec4<u32> = (textureLoad(shift_data, (_S1103), (t_13), 0));
            var _S1107 : vec4<f32> = (bitcast<vec4<f32>>((_S1106)));
            var _S1108 : vec4<u32> = (textureLoad(shift_data, (_S1072), (t_13), 0));
            var _S1109 : vec4<f32> = (bitcast<vec4<f32>>((_S1108)));
            var _S1110 : f32 = (_S1105.c + _S1091) / c_sum_0;
            var _S1111 : bool = _S1092 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1111)
            {
                var _S1112 : f32 = _S1110 * _S1091 * _S1092;
                var _S1113 : f32 = _S1091 * _S1092;
                var _S1114 : f32 = rgb_to_greyscale(_S1109.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1112 / (_S1113 + _S1105.c * _S1114);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1115 : f32 = rgb_to_greyscale(_S1105.f);
            var _S1116 : vec3<f32> = _S1107.xyz;
            var _S1117 : Shift = Shift_x24init_0(_S1116, _S1107.w);
            var _S1118 : f32 = _S1110 * _S1105.c * _S1115;
            var _S1119 : f32 = _S1105.c * _S1115;
            var _S1120 : f32 = rgb_to_greyscale(_S1116);
            offerShifted(&(sel_5), _S1105, _S1117, _S1118 / (_S1119 + _S1091 * _S1120));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1086, Shift_x24init_0(_S1086.f, 1.0f), canonical_mis_0);
    var _S1121 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1072), (_S1121), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1072), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1122 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1123 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1124 : f32 = (sign((dot(_S1123, _S1122.smooth_n))));
    var _S1125 : vec3<f32> = _S1122.material.emissive * vec3<f32>(max(_S1124, 0.0f));
    var _S1126 : vec3<f32> = select(_S1125, _S1073, _S1122.skip);
    var _S1127 : vec3<f32> = clamp(sel_5.color + _S1126, _S1073, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1072), (u32(0)), (vec4<f32>(_S1127, 1.0f)));
    var _S1128 : u32 = (uniforms_uint.is_temporal);
    var _S1129 : bool = _S1128 == u32(1);
    if(_S1129)
    {
        textureStore(compute_out, (_S1072), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1130 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1131 : bool = _S1130 != u32(4294967295);
    if(_S1131)
    {
        var _S1132 : vec2<i32> = vec2<i32>((vec2<u32>(_S1130, (_S1130 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1133 : vec3<f32> = vec3<f32>(0.0f);
        var _S1134 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1133, _S1133, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1133, 0.0f, vec4<u32>(u32(0)), _S1133, _S1133));
        var shift_job_0 : ShiftJob = _S1134;
        var _S1135 : u32 = (_S1130 >> (u32(28)));
        var _S1136 : bool = spatialJob_0(_S1132, _S1135, &(shift_job_0));
        var _S1137 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1132), (_S1135), (vec4<u32>((bitcast<vec3<u32>>((_S1137.f))), (bitcast<u32>((_S1137.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1138 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1139 : array<u32, i32(3)>;
    spatialBins_0(_S1138, &(_S1139));
    var _S1140 : array<u32, i32(3)> = _S1139;
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
        var _S1141 : bool = (_S1140[t_16]) == u32(40);
        if(_S1141)
        {
            textureStore(shift_data_out, (_S1138), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1138, _S1140, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1142 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1142));
    countShifts_0(_S1142, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1143 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1144 : bool = _S1143 != u32(4294967295);
    if(_S1144)
    {
        var _S1145 : vec2<i32> = vec2<i32>((vec2<u32>(_S1143, (_S1143 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1146 : vec3<f32> = vec3<f32>(0.0f);
        var _S1147 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1146, _S1146, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1146, 0.0f, vec4<u32>(u32(0)), _S1146, _S1146));
        var shift_job_1 : ShiftJob = _S1147;
        var _S1148 : u32 = (_S1143 >> (u32(28)));
        var _S1149 : bool = temporalJob_0(_S1145, _S1148, &(shift_job_1));
        var _S1150 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1145), (_S1148), (vec4<u32>((bitcast<vec3<u32>>((_S1150.f))), (bitcast<u32>((_S1150.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1151 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1152 : array<u32, i32(3)>;
    temporalBins_0(_S1151, &(_S1152));
    var _S1153 : array<u32, i32(3)> = _S1152;
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
        var _S1154 : bool = (_S1153[t_18]) == u32(40);
        if(_S1154)
        {
            textureStore(temporal_shifts_out, (_S1151), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1151, _S1153, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1155 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1155));
    countShifts_0(_S1155, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1156 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1157 : vec3<f32> = vec3<f32>(0.0f);
    var _S1158 : Domain = Domain_x24init_0(_S1157, _S1157, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1158;
    var _S1159 : bool = (currentDomain((_S1156), &(dom_6)));
    var _S1160 : bool = !_S1159;
    if(_S1160)
    {
        storeReservoir(reservoir_temp_out, (_S1156), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1157, 0.0f, vec4<u32>(u32(0)), _S1157, _S1157)), (dom_6.hit));
        return;
    }
    var _S1161 : Reservoir = (loadReservoir(reservoir_initial, (_S1156)));
    var _S1162 : vec2<i32> = temporalNeighbor_0(_S1156, dom_6);
    var _S1163 : bool = (_S1162.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1163)
    {
        var _S1164 : Reservoir = (loadReservoir(reservoir_prev, (_S1162)));
        var _S1165 : vec4<u32> = (textureLoad(duplication, (_S1162), 0, 0));
        var _S1166 : f32 = (bitcast<f32>((_S1165.x)));
        var _S1167 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1168 : bool = _S1167 == u32(1);
        var _S1169 : f32 = select(0.0f, _S1166, _S1168);
        var _S1170 : f32 = (mix((20.0f), (1.0f), (pow(_S1169, 0.10000000149011612f))));
        var _S1171 : f32 = min(_S1164.c, _S1170);
        var _S1172 : vec4<u32> = (textureLoad(temporal_shifts, (_S1156), (u32(0)), 0));
        var _S1173 : vec4<f32> = (bitcast<vec4<f32>>((_S1172)));
        var _S1174 : vec4<f32> = vec4<f32>(_S1161.f, 1.0f);
        var _S1175 : Domain = (previousDomain((_S1162)));
        var _S1176 : bool = sameDomain_0(_S1175, dom_6);
        var _S1177 : bool = !_S1176;
        var to_previous_0 : vec4<f32>;
        if(_S1177)
        {
            var _S1178 : vec4<u32> = (textureLoad(temporal_shifts, (_S1156), (u32(1)), 0));
            var _S1179 : vec4<f32> = (bitcast<vec4<f32>>((_S1178)));
            to_previous_0 = _S1179;
        }
        else
        {
            to_previous_0 = _S1174;
        }
        var _S1180 : f32 = rgb_to_greyscale(_S1161.f);
        var _S1181 : f32 = rgb_to_greyscale(_S1164.f);
        var _S1182 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1157, 0.0f, vec4<u32>(u32(0)), _S1157, _S1157), 0.0f, _S1157, u32(0));
        var sel_6 : Selection = _S1182;
        var _S1183 : u32 = (uniforms_uint.frame);
        var _S1184 : u32 = hash(_S1183);
        var _S1185 : u32 = global_invocation_id_7.x;
        var _S1186 : vec2<u32> = (uniforms_uint.render_size);
        var _S1187 : u32 = stream(_S1184, _S1185 + _S1186.x * global_invocation_id_7.y);
        var _S1188 : u32 = stream(_S1187, u32(194));
        sel_6.random_state = _S1188;
        var _S1189 : f32 = _S1161.c * _S1180;
        var _S1190 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1191 : f32 = _S1189 / (_S1189 + _S1171 * _S1190);
        var _S1192 : f32 = _S1171 * _S1181;
        var _S1193 : vec3<f32> = _S1173.xyz;
        var _S1194 : f32 = rgb_to_greyscale(_S1193);
        var _S1195 : f32 = _S1192 / (_S1192 + _S1161.c * _S1194);
        var _S1196 : vec2<f32> = vec2<f32>(_S1191, _S1195);
        offerShifted(&(sel_6), _S1161, Shift_x24init_0(_S1161.f, 1.0f), _S1191);
        offerShifted(&(sel_6), _S1164, Shift_x24init_0(_S1193, _S1173.w), _S1195);
        var _S1197 : Reservoir = finalize(sel_6, _S1161.c + _S1171);
        r_8 = _S1197;
    }
    else
    {
        r_8 = _S1161;
    }
    storeReservoir(reservoir_temp_out, (_S1156), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1198 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1199 : vec3<f32> = vec3<f32>(0.0f);
    var _S1200 : Domain = Domain_x24init_0(_S1199, _S1199, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1200;
    var _S1201 : bool = (currentDomain((_S1198), &(dom_7)));
    var _S1202 : bool = !_S1201;
    if(_S1202)
    {
        storeReservoir(reservoir_initial_out, (_S1198), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1199, 0.0f, vec4<u32>(u32(0)), _S1199, _S1199)), (dom_7.hit));
        return;
    }
    var _S1203 : u32 = (uniforms_uint.frame);
    var _S1204 : u32 = hash(_S1203);
    var _S1205 : u32 = global_invocation_id_8.x;
    var _S1206 : vec2<u32> = (uniforms_uint.render_size);
    var _S1207 : u32 = stream(_S1204, _S1205 + _S1206.x * global_invocation_id_8.y);
    var _S1208 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1199, 0.0f, vec4<u32>(u32(0)), _S1199, _S1199);
    var _S1209 : Selection = Selection_x24init_0(_S1208, 0.0f, _S1199, u32(0));
    var initial_0 : Selection = _S1209;
    var _S1210 : u32 = stream(_S1207, u32(193));
    initial_0.random_state = _S1210;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1211 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1211)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1208;
        var _S1212 : u32 = stream(_S1207, i_10);
        r_9.seed = _S1212;
        var _S1213 : u32 = (uniforms_uint.samples);
        var _S1214 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1213), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1215 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1198), (_S1215), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1216 : Random = pcg(state_3);
    var _S1217 : Random = pcg(_S1216.state);
    var _S1218 : f32 = 6.28318548202514648f * _S1216.value;
    var _S1219 : f32 = sqrt(-2.0f * clamp(log(_S1217.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1217.state, _S1219 * cos(_S1218));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1220 : RandomSphere;
    _S1220.state = state_4;
    _S1220.value = value_1;
    return _S1220;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1221 : Random = normal_distribution(state_5);
    var _S1222 : Random = normal_distribution(_S1221.state);
    var _S1223 : Random = normal_distribution(_S1222.state);
    var _S1224 : vec3<f32> = (normalize((vec3<f32>(_S1221.value, _S1222.value, _S1223.value))));
    return RandomSphere_x24init_0(_S1223.state, _S1224);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1225 : vec3<f32> = p1_0 - p0_0;
    var _S1226 : vec3<f32> = p2_0 - p0_0;
    var _S1227 : vec2<f32> = uv1_0 - uv0_0;
    var _S1228 : vec2<f32> = uv2_0 - uv0_0;
    var _S1229 : f32 = _S1227.x;
    var _S1230 : f32 = _S1228.y;
    var _S1231 : f32 = _S1227.y;
    var _S1232 : f32 = _S1228.x;
    var _S1233 : f32 = _S1229 * _S1230 - _S1231 * _S1232;
    var _S1234 : f32 = 1.0f / _S1233;
    var _S1235 : vec3<f32> = vec3<f32>(_S1234);
    var t_20 : vec3<f32> = (_S1225 * vec3<f32>(_S1230) - _S1226 * vec3<f32>(_S1231)) * _S1235;
    var _S1236 : vec3<f32> = (_S1226 * vec3<f32>(_S1229) - _S1225 * vec3<f32>(_S1232)) * _S1235;
    var _S1237 : vec3<f32> = t_20 - n_9 * vec3<f32>(dot(n_9, t_20));
    var _S1238 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_9);
    var _S1239 : bool = (dot(_S1237, _S1237)) > 0.0f;
    var _S1240 : vec3<f32> = select(_S1238, _S1237, _S1239);
    var _S1241 : vec3<f32> = (normalize((_S1240)));
    var _S1242 : bool = (dot(cross(n_9, _S1241), _S1236)) > 0.0f;
    var t_21 : vec3<f32>;
    if(_S1242)
    {
        var _S1243 : vec3<f32> = ((-(_S1241)));
        t_21 = _S1243;
    }
    else
    {
        t_21 = _S1241;
    }
    var _S1244 : vec3<f32> = cross(n_9, t_21);
    return mat3x3<f32>(t_21, _S1244, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1245 : vec3<f32> = t1_0 - t0_0;
    var _S1246 : vec3<f32> = t2_2 - t0_0;
    var _S1247 : vec3<f32> = t2_2 - t1_0;
    var _S1248 : f32 = min(length(_S1245), min(length(_S1246), length(_S1247)));
    var _S1249 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1250 : vec3<f32> = (normalize((n0_0)));
    var _S1251 : f32 = dot(geometry_n_4, _S1250);
    var _S1252 : vec3<f32> = (normalize((n1_0)));
    var _S1253 : f32 = dot(geometry_n_4, _S1252);
    var _S1254 : vec3<f32> = (normalize((n2_0)));
    var _S1255 : vec3<f32> = acos(abs(vec3<f32>(_S1251, _S1253, dot(geometry_n_4, _S1254))));
    var _S1256 : vec3<f32> = clamp(tan(_S1255), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1249 * _S1256, uvw_0), 0.0f, _S1248 * 0.125f);
}

fn straightThrough( material_20 : Material) -> vec3<f32>
{
    return vec3<f32>((material_20.transmission * (1.0f - material_20.metallic))) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_10 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1257 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1258 : vec3<f32> = straightThrough(material_21);
        _S1257 = _S1258;
    }
    else
    {
        _S1257 = vec3<f32>(0.0f);
    }
    return _S1257 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1259 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1259;
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

