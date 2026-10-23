fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn hash( x_0 : u32) -> u32
{
    var _S1 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S2 : u32 = ((((_S1 >> ((((_S1 >> (u32(28)))) + u32(4))))) ^ (_S1))) * u32(277803737);
    return (((_S2 >> (u32(22)))) ^ (_S2));
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S3 : Random;
    _S3.state = state_0;
    _S3.value = value_0;
    return _S3;
}

fn pcg( state_1 : u32) -> Random
{
    var new_state_0 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S4 : u32 = ((((new_state_0 >> ((((new_state_0 >> (u32(28)))) + u32(4))))) ^ (new_state_0))) * u32(277803737);
    var _S5 : u32 = (((_S4 >> (u32(22)))) ^ (_S4));
    var _S6 : f32 = f32(_S5) / 4.294967296e+09f;
    return Random_x24init_0(new_state_0, _S6);
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S7 : Random = pcg(state_2);
    var _S8 : Random = pcg(_S7.state);
    var _S9 : f32 = 6.28318548202514648f * _S7.value;
    var _S10 : f32 = sqrt(-2.0f * clamp(log(_S8.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S8.state, _S10 * cos(_S9));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S11 : RandomSphere;
    _S11.state = state_3;
    _S11.value = value_1;
    return _S11;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S12 : Random = normal_distribution(state_4);
    var _S13 : Random = normal_distribution(_S12.state);
    var _S14 : Random = normal_distribution(_S13.state);
    var _S15 : vec3<f32> = (normalize((vec3<f32>(_S12.value, _S13.value, _S14.value))));
    return RandomSphere_x24init_0(_S14.state, _S15);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S16 : RandomHemisphere;
    _S16.state = state_5;
    _S16.value = value_2;
    return _S16;
}

fn random_hemisphere( state_6 : u32,  normal_0 : vec3<f32>) -> RandomHemisphere
{
    var _S17 : RandomSphere = random_sphere(state_6);
    var _S18 : bool = (dot(_S17.value, normal_0)) > 0.0f;
    if(_S18)
    {
        return RandomHemisphere_x24init_0(_S17.state, _S17.value);
    }
    else
    {
        var _S19 : vec3<f32> = ((-(_S17.value)));
        return RandomHemisphere_x24init_0(_S17.state, _S19);
    }
}

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S20 : f32 = alpha_0 * alpha_0;
    var _S21 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S20 * n_dot_h_0 * n_dot_h_0;
    return _S20 / max(3.14159274101257324f * _S21 * _S21, 1.17549435082228751e-38f);
}

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S22 : f32 = alpha_1 * alpha_1;
    var _S23 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S22 + (1.0f - _S22) * n_dot_x_0 * n_dot_x_0));
    var _S24 : bool = alpha_1 > 0.0f;
    var _S25 : f32 = select(1.0f, _S23, _S24);
    return _S25;
}

fn G1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S26 : f32 = smithG1(alpha_2, n_dot_x_1);
    return _S26;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S27 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S28 : f32 = eta_i_0 / eta_o_0 * _S27;
    var _S29 : bool = _S28 < 1.0f;
    var kr_0 : f32;
    if(_S29)
    {
        var _S30 : f32 = sqrt(max(0.0f, 1.0f - _S28 * _S28));
        var _S31 : f32 = eta_o_0 * cos_theta_0;
        var _S32 : f32 = eta_i_0 * _S30;
        var _S33 : f32 = (_S31 - _S32) / (_S31 + _S32);
        var _S34 : f32 = eta_i_0 * cos_theta_0;
        var _S35 : f32 = eta_o_0 * _S30;
        var _S36 : f32 = (_S34 - _S35) / (_S34 + _S35);
        var _S37 : f32 = (_S33 * _S33 + _S36 * _S36) / 2.0f;
        kr_0 = _S37;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S38 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S39 : f32 = _S38.x;
    var _S40 : f32 = _S38.y;
    var _S41 : f32 = _S39 * _S39 + _S40 * _S40;
    const _S42 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S43 : vec3<f32> = vec3<f32>(- _S40, _S39, 0.0f);
    var _S44 : f32 = (inverseSqrt((_S41)));
    var _S45 : vec3<f32> = _S43 * vec3<f32>(_S44);
    var _S46 : bool = _S41 > 0.0f;
    var _S47 : vec3<f32> = select(_S42, _S45, _S46);
    var _S48 : vec3<f32> = cross(_S38, _S47);
    var _S49 : f32 = sqrt(U1_0);
    var _S50 : f32 = 6.28318548202514648f * U2_0;
    var _S51 : f32 = _S49 * cos(_S50);
    var t2_0 : f32 = _S49 * sin(_S50);
    var _S52 : f32 = 0.5f * (1.0f + _S38.z);
    var t2_1 : f32 = (1.0f - _S52) * sqrt(max(0.0f, 1.0f - _S51 * _S51)) + _S52 * t2_0;
    var _S53 : vec3<f32> = vec3<f32>(_S51) * _S47 + vec3<f32>(t2_1) * _S48;
    var _S54 : f32 = ((_S51));
    var _S55 : f32 = ((_S51));
    var _S56 : vec3<f32> = _S53 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S54 * _S55 - t2_1 * t2_1))) * _S38;
    var _S57 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S56.x, alpha_3 * _S56.y, max(0.0f, _S56.z)))));
    return _S57;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S58 : f32 = sqrt(random_1_0);
    var _S59 : f32 = 6.28318548202514648f * random_2_0;
    var _S60 : f32 = _S58 * cos(_S59);
    var _S61 : f32 = _S58 * sin(_S59);
    var _S62 : f32 = sqrt(max(0.0f, 1.0f - _S60 * _S60 - _S61 * _S61));
    return vec3<f32>(_S60, _S62, _S61);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S63 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S63)
    {
        const _S64 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S64;
    }
    else
    {
        a_1 = a_0;
    }
    var _S65 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S66 : vec3<f32> = cross(n_0, _S65);
    return vec3<f32>(v_0.x) * _S65 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S66;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S67 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S67)
    {
        const _S68 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S68;
    }
    else
    {
        a_3 = a_2;
    }
    var _S69 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S70 : vec3<f32> = cross(n_1, _S69);
    return vec3<f32>(dot(v_1, _S69), dot(v_1, n_1), dot(v_1, _S70));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S71 : vec3<f32> = p1_0 - p0_0;
    var _S72 : vec3<f32> = p2_0 - p0_0;
    var _S73 : vec2<f32> = uv1_0 - uv0_0;
    var _S74 : vec2<f32> = uv2_0 - uv0_0;
    var _S75 : f32 = _S73.x;
    var _S76 : f32 = _S74.y;
    var _S77 : f32 = _S73.y;
    var _S78 : f32 = _S74.x;
    var _S79 : f32 = _S75 * _S76 - _S77 * _S78;
    var _S80 : f32 = 1.0f / _S79;
    var _S81 : vec3<f32> = vec3<f32>(_S80);
    var t_0 : vec3<f32> = (_S71 * vec3<f32>(_S76) - _S72 * vec3<f32>(_S77)) * _S81;
    var _S82 : vec3<f32> = (_S72 * vec3<f32>(_S75) - _S71 * vec3<f32>(_S78)) * _S81;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S83 : bool = (dot(cross(n_2, t_1), _S82)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S83)
    {
        var _S84 : vec3<f32> = ((-(t_1)));
        t_2 = _S84;
    }
    else
    {
        t_2 = t_1;
    }
    var _S85 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S85, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_0 : vec3<f32>,  uvw_0 : vec3<f32>,  position_0 : vec3<f32>) -> f32
{
    var _S86 : vec3<f32> = t1_0 - t0_0;
    var _S87 : vec3<f32> = t2_2 - t0_0;
    var _S88 : vec3<f32> = t2_2 - t1_0;
    var _S89 : f32 = min(length(_S86), min(length(_S87), length(_S88)));
    var _S90 : vec3<f32> = vec3<f32>(distance(position_0, t0_0), distance(position_0, t1_0), distance(position_0, t2_2));
    var _S91 : vec3<f32> = (normalize((n0_0)));
    var _S92 : f32 = dot(geometry_n_0, _S91);
    var _S93 : vec3<f32> = (normalize((n1_0)));
    var _S94 : f32 = dot(geometry_n_0, _S93);
    var _S95 : vec3<f32> = (normalize((n2_0)));
    var _S96 : vec3<f32> = acos(abs(vec3<f32>(_S92, _S94, dot(geometry_n_0, _S95))));
    var _S97 : vec3<f32> = clamp(tan(_S96), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S90 * _S97, uvw_0), 0.0f, _S89 * 0.125f);
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S98 : Random = pcg((*random_state_0));
    var _S99 : Random = pcg(_S98.state);
    (*random_state_0) = _S99.state;
    var _S100 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S101 : vec3<f32> = sampleGGXVNDF(_S100.xzy, alpha_4, _S98.value, _S99.value);
    var _S102 : vec3<f32> = _S101.xzy;
    var _S103 : vec3<f32> = tangentToWorld(_S102, n_i_0);
    return _S103;
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
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32) -> BSDFLobes
{
    var _S104 : BSDFLobes;
    _S104.v_dot_h = v_dot_h_0;
    _S104.n_dot_h = n_dot_h_1;
    _S104.refracted = refracted_0;
    _S104.F = F_0;
    _S104.F_greyscale = F_greyscale_0;
    _S104.reflect_weight = reflect_weight_0;
    _S104.diffuse_weight = diffuse_weight_0;
    _S104.refract_weight = refract_weight_0;
    _S104.p_diffuse = p_diffuse_0;
    _S104.p_reflect = p_reflect_0;
    _S104.p_refract = p_refract_0;
    return _S104;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S105 : f32 = dot(ggx_n_0, v_4);
    var _S106 : f32 = dot(n_i_1, ggx_n_0);
    var _S107 : f32 = eta_i_1 / eta_o_1;
    var _S108 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S107))));
    var _S109 : f32 = min(sqrt(material_0.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S110 : f32 = _S109 * _S109;
    var _S111 : f32 = (1.0f + _S109) / (1.0f - _S109);
    var _S112 : f32 = abs(_S105);
    var _S113 : bool = eta_i_1 > eta_o_1;
    var _S114 : f32;
    if(_S113)
    {
        _S114 = _S111;
    }
    else
    {
        _S114 = 1.0f;
    }
    var _S115 : f32;
    if(_S113)
    {
        _S115 = 1.0f;
    }
    else
    {
        _S115 = _S111;
    }
    var _S116 : f32 = fresnel(_S112, _S114, _S115);
    var _S117 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S105 * _S105)) >= (eta_o_1 * eta_o_1);
    var _S118 : vec3<f32>;
    if(_S117)
    {
        _S118 = vec3<f32>(1.0f);
    }
    else
    {
        var _S119 : vec3<f32> = material_0.specular_tint * vec3<f32>(_S110);
        _S118 = _S119 + (vec3<f32>(1.0f) - _S119) * vec3<f32>((_S116 - _S110)) / vec3<f32>((1.0f - _S110));
    }
    var F_1 : vec3<f32> = (mix((_S118), (material_0.albedo), (material_0.metallic)));
    var _S120 : f32 = rgb_to_greyscale(F_1);
    var _S121 : f32 = 1.0f - material_0.metallic;
    var _S122 : vec3<f32> = vec3<f32>(1.0f) - _S118;
    var _S123 : vec3<f32> = vec3<f32>(((1.0f - material_0.transmission) * _S121)) * _S122;
    var _S124 : vec3<f32> = vec3<f32>((material_0.transmission * _S121)) * _S122;
    var _S125 : f32 = max(_S120, 0.0f);
    var _S126 : f32 = rgb_to_greyscale(_S123);
    var _S127 : f32 = max(_S126, 0.0f);
    var _S128 : f32 = rgb_to_greyscale(_S124);
    var _S129 : f32 = (sign((length(_S108))));
    var _S130 : f32 = max(_S128 * _S129, 0.0f);
    var _S131 : f32 = _S125 + _S127 + _S130;
    var _S132 : f32 = 1.0f / max(_S131, 0.0000152587890625f);
    var _S133 : f32 = _S127 * _S132;
    var _S134 : f32 = _S125 * _S132;
    var _S135 : f32 = _S130 * _S132;
    return BSDFLobes_x24init_0(_S105, _S106, _S108, F_1, _S120, 1.0f, _S123, _S124, _S133, _S134, _S135);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S136 : bool = lobe_0 == u32(0);
    if(_S136)
    {
        var _S137 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S138 : bool = n_i_dot_v_0 > 0.0f;
        var _S139 : f32 = select(0.0f, _S137, _S138);
        return _S139;
    }
    var _S140 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S141 : f32 = _S140 * lobes_0.v_dot_h;
    var _S142 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S143 : f32 = _S141 * _S142 / n_i_dot_v_0;
    var _S144 : bool = alpha_5 > 0.0f;
    var _S145 : bool;
    if(_S144)
    {
        _S145 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S145 = false;
    }
    if(_S145)
    {
        _S145 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S145 = false;
    }
    if(_S145)
    {
        _S145 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S145 = false;
    }
    var _S146 : f32 = select(0.0f, _S143, _S145);
    var _S147 : bool = lobe_0 == u32(1);
    if(_S147)
    {
        var _S148 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S149 : f32 = lobes_0.p_refract * _S146 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S148 * _S148);
        var _S150 : bool = eta_i_2 != eta_o_2;
        if(_S150)
        {
            _S145 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S145 = false;
        }
        var _S151 : f32 = select(0.0f, _S149, _S145);
        return _S151;
    }
    var _S152 : f32 = lobes_0.p_reflect * _S146 / (4.0f * lobes_0.v_dot_h);
    var _S153 : bool = _S146 > 0.0f;
    var _S154 : f32 = select(0.0f, _S152, _S153);
    return _S154;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S155 : bool = lobe_1 == u32(0);
    if(_S155)
    {
        return lobes_1.diffuse_weight * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S156 : bool = lobe_1 == u32(1);
    if(_S156)
    {
        var _S157 : f32 = - dot(n_i_2, l_0);
        var _S158 : f32 = G1(alpha_6, max(_S157, 0.0f));
        return lobes_1.refract_weight * vec3<f32>(_S158) * material_1.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S159 : f32 = dot(n_i_2, l_0);
    var _S160 : f32 = G1(alpha_6, max(_S159, 0.0f));
    return vec3<f32>((lobes_1.reflect_weight * _S160)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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

fn SampleBSDF_x24init_0( unit_direction_0 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_1 : bool,  lobe_2 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S161 : SampleBSDF;
    _S161.unit_direction = unit_direction_0;
    _S161.throughput = throughput_0;
    _S161.random_state = random_state_1;
    _S161.refracted = refracted_1;
    _S161.lobe = lobe_2;
    _S161.pdf = pdf_0;
    return _S161;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S162 : vec3<f32> = ((-(in_dir_1)));
    var _S163 : f32 = dot(n_3, _S162);
    var _S164 : f32 = (sign((_S163)));
    var _S165 : vec3<f32> = n_3 * vec3<f32>(_S164);
    var _S166 : f32 = material_2.roughness;
    var _S167 : f32 = _S166 * _S166;
    var _S168 : vec3<f32> = (normalize((_S162 + out_dir_0)));
    var _S169 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S169)
    {
        var _S170 : vec3<f32> = sampleHalfVector(_S162, _S165, _S167, &(random_state_2));
        ggx_n_1 = _S170;
    }
    else
    {
        var _S171 : bool = lobe_3 == u32(1);
        if(_S171)
        {
            var _S172 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S162 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S173 : vec3<f32> = (normalize((_S172)));
            var _S174 : f32 = (sign((dot(_S172, _S165))));
            var _S175 : vec3<f32> = _S173 * vec3<f32>(_S174);
            ggx_n_1 = _S175;
        }
        else
        {
            ggx_n_1 = _S168;
        }
    }
    var _S176 : BSDFLobes = bsdfLobes(in_dir_1, _S162, _S165, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S177 : f32 = lobeDensity(dot(_S165, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S163), _S167, _S176, eta_i_3, eta_o_3, lobe_3);
    var _S178 : bool = !(_S177 > 0.0f);
    if(_S178)
    {
        var _S179 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S179, _S179, u32(0), false, u32(0), 0.0f);
    }
    var _S180 : vec3<f32> = lobeThroughput(out_dir_0, _S165, _S167, material_2, _S176, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S180, random_state_2, lobe_3 == u32(1), lobe_3, _S177);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S181 : vec3<f32> = ((-(in_dir_2)));
    var _S182 : bool = (dot(g_n_0, _S181) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S182)
    {
        var _S183 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S184 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S183.throughput * vec3<f32>(_S183.pdf) + _S184.throughput * vec3<f32>(_S184.pdf);
    }
    var _S185 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S185.throughput * vec3<f32>(_S185.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S186 : vec3<f32> = ((-(in_dir_3)));
    var _S187 : f32 = dot(n_5, _S186);
    var _S188 : f32 = (sign((_S187)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S188);
    var _S189 : f32 = abs(_S187);
    var _S190 : f32 = material_4.roughness;
    var _S191 : f32 = _S190 * _S190;
    var _S192 : vec3<f32> = sampleHalfVector(_S186, n_i_3, _S191, &(random_state_4));
    var _S193 : BSDFLobes = bsdfLobes(in_dir_3, _S186, n_i_3, _S192, material_4, eta_i_5, eta_o_5);
    var _S194 : vec3<f32> = vec3<f32>(1.0f);
    var _S195 : SampleBSDF = SampleBSDF_x24init_0(_S194, _S194, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S195;
    var _S196 : Random = pcg(random_state_4);
    random_state_4 = _S196.state;
    var _S197 : bool = (_S196.value) < (_S193.p_diffuse);
    if(_S197)
    {
        var _S198 : Random = pcg(random_state_4);
        var _S199 : Random = pcg(_S198.state);
        sample_0.random_state = _S199.state;
        var _S200 : vec3<f32> = sampleCosWeightedHemisphere(_S198.value, _S199.value);
        var _S201 : vec3<f32> = tangentToWorld(_S200, n_i_3);
        sample_0.unit_direction = _S201;
        var _S202 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S191, material_4, _S193, u32(0));
        sample_0.throughput = _S202;
        var _S203 : f32 = lobeDensity(_S200.y, 0.0f, _S189, _S191, _S193, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S203;
        return sample_0;
    }
    var _S204 : bool = (_S196.value) < (_S193.p_diffuse + _S193.p_refract);
    if(_S204)
    {
        sample_0.unit_direction = _S193.refracted;
        var _S205 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S192), _S189, _S191, _S193, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S205;
        var _S206 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S191, material_4, _S193, u32(1));
        sample_0.throughput = _S206;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S207 : vec3<f32> = (normalize((reflect(in_dir_3, _S192))));
    sample_0.unit_direction = _S207;
    var _S208 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S191, material_4, _S193, u32(2));
    sample_0.throughput = _S208;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S209 : f32 = lobeDensity(0.0f, 0.0f, _S189, _S191, _S193, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S209;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S210 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S210));
}

fn samplesLights( material_5 : Material) -> bool
{
    var _S211 : bool = (material_5.roughness) > 0.0f;
    var _S212 : bool;
    if(_S211)
    {
        _S212 = true;
    }
    else
    {
        var _S213 : bool = (material_5.metallic) < 1.0f;
        if(_S213)
        {
            _S212 = (material_5.transmission) < 1.0f;
        }
        else
        {
            _S212 = false;
        }
    }
    return _S212;
}

fn neeBSDF( in_dir_4 : vec3<f32>,  dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_5 : u32) -> vec3<f32>
{
    var _S214 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S214;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S215 : bool = (lobe_4 == u32(1)) == refracted_2;
        var f_1 : vec3<f32>;
        if(_S215)
        {
            var _S216 : SampleBSDF = connectBSDF(in_dir_4, dir_0, n_6, material_6, eta_i_6, eta_o_6, lobe_4, random_state_5);
            var _S217 : bool = (_S216.pdf) > 0.0f;
            if(_S217)
            {
                if(power_0)
                {
                    var _S218 : f32 = _S216.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S216.throughput * vec3<f32>(_S216.pdf) / vec3<f32>((pdf_1 * (1.0f + _S218 * _S218)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S216.throughput * vec3<f32>(_S216.pdf) / vec3<f32>((_S216.pdf + pdf_1));
                    f_1 = f_3;
                }
            }
            else
            {
                f_1 = f_0;
            }
        }
        else
        {
            f_1 = f_0;
        }
        var lobe_5 : u32 = lobe_4 + u32(1);
        lobe_4 = lobe_5;
        f_0 = f_1;
    }
    return f_0;
}

fn straightThrough( dir_1 : vec3<f32>,  n_7 : vec3<f32>,  material_7 : Material) -> vec3<f32>
{
    var _S219 : f32 = material_7.transmission * (1.0f - material_7.metallic);
    var _S220 : f32 = material_7.roughness;
    var _S221 : f32 = G1(_S220 * _S220, abs(dot(n_7, dir_1)));
    return vec3<f32>((_S219 * _S221)) * material_7.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S222 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S222 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_8 : vec3<f32>,  material_8 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S223 : vec3<f32>;
    if((material_8.ior) == 1.0f)
    {
        var _S224 : vec3<f32> = straightThrough(toward_0, n_8, material_8);
        _S223 = _S224;
    }
    else
    {
        _S223 = vec3<f32>(0.0f);
    }
    return _S223 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S225 : u32 = hash(index_0);
    var _S226 : u32 = hash((seed_0 ^ (_S225)));
    return _S226;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S227 : vec3<f32> = a_4 / b_0;
    var _S228 : vec3<f32> = vec3<f32>(0.0f);
    var _S229 : vec3<bool> = b_0 == _S228;
    var _S230 : vec3<f32> = select(_S227, _S228, _S229);
    return _S230;
}

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

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S231 : f32 = rgb_to_greyscale(weight_0);
    var _S232 : bool = _S231 > 0.0f;
    var _S233 : bool;
    if(_S232)
    {
        _S233 = _S231 < 3.00000000549775576e+38f;
    }
    else
    {
        _S233 = false;
    }
    var _S234 : bool = !_S233;
    if(_S234)
    {
        return;
    }
    var _S235 : f32 = (*sel_0).w_sum + _S231;
    (*sel_0).w_sum = _S235;
    var _S236 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S236;
    var _S237 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S237.state;
    var _S238 : bool = (_S237.value * (*sel_0).w_sum) <= _S231;
    if(_S238)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

fn offerShifted( sel_1 : ptr<function, Selection>,  r_0 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_0;
    var _S239 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S239;
    var _S240 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S240;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S241 : f32 = rgb_to_greyscale(r_1.f);
    var _S242 : f32 = sel_2.w_sum / _S241;
    var _S243 : bool = _S241 > 0.0f;
    var _S244 : f32 = select(0.0f, _S242, _S243);
    r_1.w = _S244;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S245 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S246 : u32 = (insertBits((_S245), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S246;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S247 : bool = transmission_0 > 0.0f;
    var _S248 : bool;
    if(_S247)
    {
        _S248 = true;
    }
    else
    {
        _S248 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S249 : f32;
    if(_S248)
    {
        _S249 = 1.0f;
    }
    else
    {
        _S249 = -1.0f;
    }
    return _S249;
}

fn geometryDensity( geometry_n_1 : vec3<f32>,  direction_1 : vec3<f32>,  distance_1 : f32) -> f32
{
    return abs(dot(geometry_n_1, direction_1)) / (distance_1 * distance_1);
}

fn footprintThreshold( geometry_density_0 : f32) -> f32
{
    return 0.00251327408477664f / geometry_density_0;
}

fn withinFootprint( open_0 : bool,  prev_rough_0 : bool,  prev_pdf_0 : f32,  geometry_density_1 : f32,  threshold_0 : f32) -> bool
{
    var _S250 : bool;
    if(open_0)
    {
        _S250 = prev_rough_0;
    }
    else
    {
        _S250 = false;
    }
    if(_S250)
    {
        _S250 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S250 = false;
    }
    return _S250;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S251 : bool = pdf_2 > 0.0f;
    var _S252 : bool;
    if(_S251)
    {
        if(diffuse_0)
        {
            _S252 = true;
        }
        else
        {
            _S252 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S252 = false;
    }
    return _S252;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S253 : bool = pdf_3 > 0.0f;
    var _S254 : bool;
    if(_S253)
    {
        if(diffuse_1)
        {
            _S254 = true;
        }
        else
        {
            _S254 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S254 = false;
    }
    return _S254;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S255 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S255.x, max(_S255.y, _S255.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S256 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S256;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S257 : f32 = c_1 * p_c_0;
    var _S258 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S257 / (_S257 + c_t_0 * g_previous_0), _S258 / (_S258 + c_1 * g_current_0));
}

fn pairShare( c_n_0 : f32,  c_pair_0 : f32,  c_sum_0 : f32) -> f32
{
    return (c_n_0 + c_pair_0) / c_sum_0;
}

fn neighborWeight( share_0 : f32,  c_n_1 : f32,  p_n_0 : f32,  c_pair_1 : f32,  g_here_0 : f32) -> f32
{
    return share_0 * c_n_1 * p_n_0 / (c_n_1 * p_n_0 + c_pair_1 * g_here_0);
}

fn canonicalWeight( share_1 : f32,  c_pair_2 : f32,  p_c_1 : f32,  c_n_2 : f32,  g_there_0 : f32) -> f32
{
    return share_1 * c_pair_2 * p_c_1 / (c_pair_2 * p_c_1 + c_n_2 * g_there_0);
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S259 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S260 : bool = cos_a_0 > cos_b_0;
    var _S261 : f32 = select(_S259, 1.0f, _S260);
    return _S261;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S262 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S263 : bool = cos_a_1 > cos_b_1;
    var _S264 : f32 = select(_S262, 0.0f, _S263);
    return _S264;
}

fn sine( c_2 : f32) -> f32
{
    return sqrt(max(1.0f - c_2 * c_2, 0.0f));
}

struct LightBounds
{
     low : vec3<f32>,
     high : vec3<f32>,
     w : vec3<f32>,
     phi : f32,
     cos_theta_o : f32,
};

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_1 : vec3<f32>) -> f32
{
    var _S265 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S266 : vec3<f32> = node_0.high - node_0.low;
    var _S267 : vec3<f32> = p_0 - _S265;
    var _S268 : vec3<f32> = (normalize((_S267)));
    var _S269 : f32 = dot(_S267, _S267);
    var _S270 : f32 = dot(_S266, _S266) / 4.0f;
    var _S271 : f32 = abs(dot(node_0.w, _S268));
    var _S272 : f32 = sine(node_0.cos_theta_o);
    var _S273 : f32 = sqrt(max(1.0f - _S270 / _S269, 0.0f));
    var _S274 : bool = _S269 < _S270;
    var _S275 : f32 = select(_S273, -1.0f, _S274);
    var _S276 : f32 = sine(_S275);
    var _S277 : f32 = sine(_S271);
    var _S278 : f32 = cosSubClamped(_S277, _S271, _S272, node_0.cos_theta_o);
    var _S279 : f32 = sine(_S271);
    var _S280 : f32 = sinSubClamped(_S279, _S271, _S272, node_0.cos_theta_o);
    var _S281 : f32 = cosSubClamped(_S280, _S278, _S276, _S275);
    var _S282 : bool = _S281 <= 0.0f;
    if(_S282)
    {
        return 0.0f;
    }
    var _S283 : f32 = - dot(_S268, normal_1);
    var _S284 : f32 = node_0.phi * _S281 / max(_S269, length(_S266) / 2.0f);
    var _S285 : f32 = sine(_S283);
    var _S286 : f32 = cosSubClamped(_S285, _S283, _S276, _S275);
    var _S287 : bool = (dot(normal_1, normal_1)) == 0.0f;
    var _S288 : f32 = select(_S286, 1.0f, _S287);
    return max(_S284 * _S288, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_2, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S289 : f32 = importance(first_0, p_1, normal_3);
    var _S290 : f32 = importance(second_0, p_1, normal_3);
    var _S291 : vec2<f32> = vec2<f32>(_S289, _S290);
    var _S292 : bool = _S289 == 0.0f;
    var _S293 : bool;
    if(_S292)
    {
        _S293 = _S290 == 0.0f;
    }
    else
    {
        _S293 = false;
    }
    if(_S293)
    {
        return u32(2);
    }
    var _S294 : f32 = _S289 + _S290;
    var _S295 : bool = _S290 > 0.0f;
    if(_S295)
    {
        _S293 = ((*pick_0) * _S294) >= _S289;
    }
    else
    {
        _S293 = false;
    }
    var _S296 : u32 = select(u32(0), u32(1), _S293);
    var _S297 : f32 = min(((*pick_0) * _S294 - f32(_S296) * _S289) / _S291[_S296], 0.99999994039535522f);
    (*pick_0) = _S297;
    var _S298 : f32 = (*probability_1) * (_S291[_S296] / _S294);
    (*probability_1) = _S298;
    return _S296;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_4 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S299 : f32 = importance(first_1, p_2, normal_4);
    var _S300 : f32 = importance(second_1, p_2, normal_4);
    var _S301 : vec2<f32> = vec2<f32>(_S299, _S300);
    var _S302 : f32 = _S301[child_0] / (_S299 + _S300);
    var _S303 : bool = (_S301[child_0]) > 0.0f;
    var _S304 : f32 = select(0.0f, _S302, _S303);
    return _S304;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S305 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S306 : bool = b_1 > 0.0f;
    var _S307 : f32 = select(1.0f, _S305, _S306);
    return _S307;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S308 : vec3<f32> = center_0 - p_3;
    var _S309 : f32 = radius_1 * radius_1 / dot(_S308, _S308);
    var _S310 : bool = _S309 >= 1.0f;
    if(_S310)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S309)) / (6.28318548202514648f * _S309);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S311 : vec3<f32> = center_1 - p_4;
    var _S312 : f32 = radius_2 * radius_2 / dot(_S311, _S311);
    var _S313 : f32 = u1_0 * _S312 / (1.0f + sqrt(max(1.0f - _S312, 0.0f)));
    var _S314 : f32 = 2.0f * u1_0;
    var _S315 : bool = _S312 >= 1.0f;
    var _S316 : f32 = select(_S313, _S314, _S315);
    var _S317 : f32 = sqrt(max(_S316 * (2.0f - _S316), 0.0f));
    var _S318 : f32 = 6.28318548202514648f * u2_0;
    var _S319 : vec3<f32> = vec3<f32>(_S317 * cos(_S318), 1.0f - _S316, _S317 * sin(_S318));
    var _S320 : vec3<f32> = (normalize((_S311)));
    var _S321 : vec3<f32> = tangentToWorld(_S319, _S320);
    return _S321;
}

