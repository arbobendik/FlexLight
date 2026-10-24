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
     translucent_share : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32) -> BSDFLobes
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
    _S104.translucent_share = translucent_share_0;
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
    return BSDFLobes_x24init_0(_S105, _S106, _S108, F_1, _S120, 1.0f, _S123, _S124, _S133, _S134, _S135, 0.0f);
}

fn translucentShare( material_1 : Material) -> f32
{
    var _S136 : f32 = rgb_to_greyscale(material_1.translucent);
    var _S137 : f32 = rgb_to_greyscale(material_1.albedo);
    var _S138 : f32 = _S136 / (_S137 + _S136);
    var _S139 : bool = _S136 > 0.0f;
    var _S140 : f32 = select(0.0f, _S138, _S139);
    return _S140;
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S141 : bool = lobe_0 == u32(0);
    if(_S141)
    {
        var _S142 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S143 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S144 : f32 = 1.0f - lobes_0.translucent_share;
        var _S145 : bool = n_i_dot_l_0 < 0.0f;
        var _S146 : f32 = select(_S144, lobes_0.translucent_share, _S145);
        var _S147 : f32 = _S143 * _S146;
        var _S148 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S149 : f32 = select(_S142, _S147, _S148);
        var _S150 : bool = n_i_dot_v_0 > 0.0f;
        var _S151 : f32 = select(0.0f, _S149, _S150);
        return _S151;
    }
    var _S152 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S153 : f32 = _S152 * lobes_0.v_dot_h;
    var _S154 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S155 : f32 = _S153 * _S154 / n_i_dot_v_0;
    var _S156 : bool = alpha_5 > 0.0f;
    var _S157 : bool;
    if(_S156)
    {
        _S157 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S157 = false;
    }
    if(_S157)
    {
        _S157 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S157 = false;
    }
    if(_S157)
    {
        _S157 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S157 = false;
    }
    var _S158 : f32 = select(0.0f, _S155, _S157);
    var _S159 : bool = lobe_0 == u32(1);
    if(_S159)
    {
        var _S160 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S161 : f32 = lobes_0.p_refract * _S158 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S160 * _S160);
        var _S162 : bool = eta_i_2 != eta_o_2;
        if(_S162)
        {
            _S157 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S157 = false;
        }
        var _S163 : f32 = select(0.0f, _S161, _S157);
        return _S163;
    }
    var _S164 : f32 = lobes_0.p_reflect * _S158 / (4.0f * lobes_0.v_dot_h);
    var _S165 : bool = _S158 > 0.0f;
    var _S166 : f32 = select(0.0f, _S164, _S165);
    return _S166;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_2 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S167 : bool = lobe_1 == u32(0);
    if(_S167)
    {
        var _S168 : bool = (dot(n_i_2, l_0)) < 0.0f;
        var _S169 : vec3<f32> = select(material_2.albedo, material_2.translucent, _S168);
        var _S170 : f32 = 1.0f - lobes_1.translucent_share;
        var _S171 : f32 = select(_S170, lobes_1.translucent_share, _S168);
        var _S172 : vec3<f32> = _S169 / vec3<f32>(_S171);
        var _S173 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S174 : vec3<f32> = select(material_2.albedo, _S172, _S173);
        return lobes_1.diffuse_weight * _S174 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S175 : bool = lobe_1 == u32(1);
    if(_S175)
    {
        var _S176 : f32 = - dot(n_i_2, l_0);
        var _S177 : f32 = G1(alpha_6, max(_S176, 0.0f));
        return lobes_1.refract_weight * vec3<f32>(_S177) * material_2.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S178 : f32 = dot(n_i_2, l_0);
    var _S179 : f32 = G1(alpha_6, max(_S178, 0.0f));
    return vec3<f32>((lobes_1.reflect_weight * _S179)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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
    var _S180 : SampleBSDF;
    _S180.unit_direction = unit_direction_0;
    _S180.throughput = throughput_0;
    _S180.random_state = random_state_1;
    _S180.refracted = refracted_1;
    _S180.lobe = lobe_2;
    _S180.pdf = pdf_0;
    return _S180;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_3 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S181 : vec3<f32> = ((-(in_dir_1)));
    var _S182 : f32 = dot(n_3, _S181);
    var _S183 : f32 = (sign((_S182)));
    var _S184 : vec3<f32> = n_3 * vec3<f32>(_S183);
    var _S185 : f32 = material_3.roughness;
    var _S186 : f32 = _S185 * _S185;
    var _S187 : vec3<f32> = (normalize((_S181 + out_dir_0)));
    var _S188 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S188)
    {
        var _S189 : vec3<f32> = sampleHalfVector(_S181, _S184, _S186, &(random_state_2));
        ggx_n_1 = _S189;
    }
    else
    {
        var _S190 : bool = lobe_3 == u32(1);
        if(_S190)
        {
            var _S191 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S181 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S192 : vec3<f32> = (normalize((_S191)));
            var _S193 : f32 = (sign((dot(_S191, _S184))));
            var _S194 : vec3<f32> = _S192 * vec3<f32>(_S193);
            ggx_n_1 = _S194;
        }
        else
        {
            ggx_n_1 = _S187;
        }
    }
    var _S195 : BSDFLobes = bsdfLobes(in_dir_1, _S181, _S184, ggx_n_1, material_3, eta_i_3, eta_o_3);
    var lobes_2 : BSDFLobes = _S195;
    var _S196 : f32 = translucentShare(material_3);
    lobes_2.translucent_share = _S196;
    var _S197 : f32 = lobeDensity(dot(_S184, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S182), _S186, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S198 : bool = !(_S197 > 0.0f);
    if(_S198)
    {
        var _S199 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S199, _S199, u32(0), false, u32(0), 0.0f);
    }
    var _S200 : vec3<f32> = lobeThroughput(out_dir_0, _S184, _S186, material_3, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S200, random_state_2, lobe_3 == u32(1), lobe_3, _S197);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_4 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S201 : vec3<f32> = ((-(in_dir_2)));
    var _S202 : bool = (dot(g_n_0, _S201) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S202)
    {
        var _S203 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_4, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S204 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_4, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S203.throughput * vec3<f32>(_S203.pdf) + _S204.throughput * vec3<f32>(_S204.pdf);
    }
    var _S205 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_4, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S205.throughput * vec3<f32>(_S205.pdf);
}

fn translucentCorrection( in_dir_3 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  g_n_1 : vec3<f32>,  material_5 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S206 : f32 = dot(n_5, out_dir_2);
    var _S207 : vec3<f32> = ((-(in_dir_3)));
    var _S208 : bool = (_S206 * dot(n_5, _S207)) < 0.0f;
    var _S209 : SampleBSDF = connectBSDF(in_dir_3, out_dir_2, n_5, material_5, eta_i_5, eta_o_5, u32(0), random_state_4);
    var _S210 : vec3<f32> = ((-(in_dir_3)));
    var _S211 : bool = (dot(g_n_1, _S210) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S212 : vec3<f32> = vec3<f32>(0.0f);
    var _S213 : vec3<f32> = _S209.throughput * vec3<f32>(_S209.pdf);
    var _S214 : f32 = select(1.0f, -1.0f, _S211);
    var _S215 : vec3<f32> = _S213 * vec3<f32>(_S214);
    var _S216 : vec3<f32> = select(_S212, _S215, _S208);
    return _S216;
}

fn translucentBSDF( in_dir_4 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_6 : vec3<f32>,  g_n_2 : vec3<f32>,  material_6 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_5 : u32) -> vec3<f32>
{
    var _S217 : vec3<f32> = BSDF(in_dir_4, out_dir_3, n_6, g_n_2, material_6, eta_i_6, eta_o_6, random_state_5);
    var _S218 : vec3<f32> = translucentCorrection(in_dir_4, out_dir_3, n_6, g_n_2, material_6, eta_i_6, eta_o_6, random_state_5);
    return _S217 + _S218;
}

fn sampleBSDF( in_dir_5 : vec3<f32>,  n_7 : vec3<f32>,  material_7 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_6 : u32 = random_init_1;
    var _S219 : vec3<f32> = ((-(in_dir_5)));
    var _S220 : f32 = dot(n_7, _S219);
    var _S221 : f32 = (sign((_S220)));
    var n_i_3 : vec3<f32> = n_7 * vec3<f32>(_S221);
    var _S222 : f32 = abs(_S220);
    var _S223 : f32 = material_7.roughness;
    var _S224 : f32 = _S223 * _S223;
    var _S225 : vec3<f32> = sampleHalfVector(_S219, n_i_3, _S224, &(random_state_6));
    var _S226 : BSDFLobes = bsdfLobes(in_dir_5, _S219, n_i_3, _S225, material_7, eta_i_7, eta_o_7);
    var lobes_3 : BSDFLobes = _S226;
    var _S227 : f32 = translucentShare(material_7);
    lobes_3.translucent_share = _S227;
    var _S228 : vec3<f32> = vec3<f32>(1.0f);
    var _S229 : SampleBSDF = SampleBSDF_x24init_0(_S228, _S228, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S229;
    var _S230 : Random = pcg(random_state_6);
    random_state_6 = _S230.state;
    var _S231 : bool = (_S230.value) < (lobes_3.p_diffuse);
    if(_S231)
    {
        var _S232 : Random = pcg(random_state_6);
        var _S233 : Random = pcg(_S232.state);
        sample_0.random_state = _S233.state;
        var _S234 : vec3<f32> = sampleCosWeightedHemisphere(_S232.value, _S233.value);
        var _S235 : bool = (_S230.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S236 : f32 = _S234.y;
        var _S237 : f32 = - _S236;
        var _S238 : f32 = select(_S236, _S237, _S235);
        var _S239 : vec3<f32> = tangentToWorld(vec3<f32>(_S234.x, _S238, _S234.z), n_i_3);
        sample_0.unit_direction = _S239;
        var _S240 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S224, material_7, lobes_3, u32(0));
        sample_0.throughput = _S240;
        var _S241 : f32 = lobeDensity(_S238, 0.0f, _S222, _S224, lobes_3, eta_i_7, eta_o_7, u32(0));
        sample_0.pdf = _S241;
        sample_0.refracted = _S235;
        return sample_0;
    }
    var _S242 : bool = (_S230.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S242)
    {
        sample_0.unit_direction = lobes_3.refracted;
        var _S243 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S225), _S222, _S224, lobes_3, eta_i_7, eta_o_7, u32(1));
        sample_0.pdf = _S243;
        var _S244 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S224, material_7, lobes_3, u32(1));
        sample_0.throughput = _S244;
        sample_0.random_state = random_state_6;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S245 : vec3<f32> = (normalize((reflect(in_dir_5, _S225))));
    sample_0.unit_direction = _S245;
    var _S246 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S224, material_7, lobes_3, u32(2));
    sample_0.throughput = _S246;
    sample_0.random_state = random_state_6;
    sample_0.lobe = u32(2);
    var _S247 : f32 = lobeDensity(0.0f, 0.0f, _S222, _S224, lobes_3, eta_i_7, eta_o_7, u32(2));
    sample_0.pdf = _S247;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S248 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S248));
}

fn samplesLights( material_8 : Material) -> bool
{
    var _S249 : bool = (material_8.roughness) > 0.0f;
    var _S250 : bool;
    if(_S249)
    {
        _S250 = true;
    }
    else
    {
        var _S251 : bool = (material_8.metallic) < 1.0f;
        if(_S251)
        {
            _S250 = (material_8.transmission) < 1.0f;
        }
        else
        {
            _S250 = false;
        }
    }
    return _S250;
}

fn neeBSDF( in_dir_6 : vec3<f32>,  dir_0 : vec3<f32>,  n_8 : vec3<f32>,  material_9 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_7 : u32) -> vec3<f32>
{
    var _S252 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S252;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S253 : bool = lobe_4 == u32(0);
        var _S254 : bool;
        if(_S253)
        {
            var _S255 : f32 = rgb_to_greyscale(material_9.translucent);
            _S254 = _S255 > 0.0f;
        }
        else
        {
            _S254 = false;
        }
        var _S256 : bool;
        if(_S254)
        {
            var _S257 : f32 = dot(n_8, dir_0);
            var _S258 : vec3<f32> = ((-(in_dir_6)));
            _S256 = ((_S257 * dot(n_8, _S258)) < 0.0f) == refracted_2;
        }
        else
        {
            _S256 = (lobe_4 == u32(1)) == refracted_2;
        }
        var f_1 : vec3<f32>;
        if(_S256)
        {
            var _S259 : SampleBSDF = connectBSDF(in_dir_6, dir_0, n_8, material_9, eta_i_8, eta_o_8, lobe_4, random_state_7);
            var _S260 : bool = (_S259.pdf) > 0.0f;
            if(_S260)
            {
                if(power_0)
                {
                    var _S261 : f32 = _S259.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S259.throughput * vec3<f32>(_S259.pdf) / vec3<f32>((pdf_1 * (1.0f + _S261 * _S261)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S259.throughput * vec3<f32>(_S259.pdf) / vec3<f32>((_S259.pdf + pdf_1));
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

fn straightThrough( dir_1 : vec3<f32>,  n_9 : vec3<f32>,  material_10 : Material) -> vec3<f32>
{
    var _S262 : f32 = material_10.transmission * (1.0f - material_10.metallic);
    var _S263 : f32 = material_10.roughness;
    var _S264 : f32 = G1(_S263 * _S263, abs(dot(n_9, dir_1)));
    return vec3<f32>((_S262 * _S264)) * material_10.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S265 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S265 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_10 : vec3<f32>,  material_11 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S266 : vec3<f32>;
    if((material_11.ior) == 1.0f)
    {
        var _S267 : vec3<f32> = straightThrough(toward_0, n_10, material_11);
        _S266 = _S267;
    }
    else
    {
        _S266 = vec3<f32>(0.0f);
    }
    return _S266 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S268 : u32 = hash(index_0);
    var _S269 : u32 = hash((seed_0 ^ (_S268)));
    return _S269;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S270 : vec3<f32> = a_4 / b_0;
    var _S271 : vec3<f32> = vec3<f32>(0.0f);
    var _S272 : vec3<bool> = b_0 == _S271;
    var _S273 : vec3<f32> = select(_S270, _S271, _S272);
    return _S273;
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
    var _S274 : f32 = rgb_to_greyscale(weight_0);
    var _S275 : bool = _S274 > 0.0f;
    var _S276 : bool;
    if(_S275)
    {
        _S276 = _S274 < 3.00000000549775576e+38f;
    }
    else
    {
        _S276 = false;
    }
    var _S277 : bool = !_S276;
    if(_S277)
    {
        return;
    }
    var _S278 : f32 = (*sel_0).w_sum + _S274;
    (*sel_0).w_sum = _S278;
    var _S279 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S279;
    var _S280 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S280.state;
    var _S281 : bool = (_S280.value * (*sel_0).w_sum) <= _S274;
    if(_S281)
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
    var _S282 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S282;
    var _S283 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S283;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S284 : f32 = rgb_to_greyscale(r_1.f);
    var _S285 : f32 = sel_2.w_sum / _S284;
    var _S286 : bool = _S284 > 0.0f;
    var _S287 : f32 = select(0.0f, _S285, _S286);
    r_1.w = _S287;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S288 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S289 : u32 = (insertBits((_S288), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S289;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S290 : bool = transmission_0 > 0.0f;
    var _S291 : bool;
    if(_S290)
    {
        _S291 = true;
    }
    else
    {
        _S291 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S292 : f32;
    if(_S291)
    {
        _S292 = 1.0f;
    }
    else
    {
        _S292 = -1.0f;
    }
    return _S292;
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
    var _S293 : bool;
    if(open_0)
    {
        _S293 = prev_rough_0;
    }
    else
    {
        _S293 = false;
    }
    if(_S293)
    {
        _S293 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S293 = false;
    }
    return _S293;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S294 : bool = pdf_2 > 0.0f;
    var _S295 : bool;
    if(_S294)
    {
        if(diffuse_0)
        {
            _S295 = true;
        }
        else
        {
            _S295 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S295 = false;
    }
    return _S295;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S296 : bool = pdf_3 > 0.0f;
    var _S297 : bool;
    if(_S296)
    {
        if(diffuse_1)
        {
            _S297 = true;
        }
        else
        {
            _S297 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S297 = false;
    }
    return _S297;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S298 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S298.x, max(_S298.y, _S298.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S299 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S299;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S300 : f32 = c_1 * p_c_0;
    var _S301 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S300 / (_S300 + c_t_0 * g_previous_0), _S301 / (_S301 + c_1 * g_current_0));
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
    var _S302 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S303 : bool = cos_a_0 > cos_b_0;
    var _S304 : f32 = select(_S302, 1.0f, _S303);
    return _S304;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S305 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S306 : bool = cos_a_1 > cos_b_1;
    var _S307 : f32 = select(_S305, 0.0f, _S306);
    return _S307;
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
    var _S308 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S309 : vec3<f32> = node_0.high - node_0.low;
    var _S310 : vec3<f32> = p_0 - _S308;
    var _S311 : vec3<f32> = (normalize((_S310)));
    var _S312 : f32 = dot(_S310, _S310);
    var _S313 : f32 = dot(_S309, _S309) / 4.0f;
    var _S314 : f32 = abs(dot(node_0.w, _S311));
    var _S315 : f32 = sine(node_0.cos_theta_o);
    var _S316 : f32 = sqrt(max(1.0f - _S313 / _S312, 0.0f));
    var _S317 : bool = _S312 < _S313;
    var _S318 : f32 = select(_S316, -1.0f, _S317);
    var _S319 : f32 = sine(_S318);
    var _S320 : f32 = sine(_S314);
    var _S321 : f32 = cosSubClamped(_S320, _S314, _S315, node_0.cos_theta_o);
    var _S322 : f32 = sine(_S314);
    var _S323 : f32 = sinSubClamped(_S322, _S314, _S315, node_0.cos_theta_o);
    var _S324 : f32 = cosSubClamped(_S323, _S321, _S319, _S318);
    var _S325 : bool = _S324 <= 0.0f;
    if(_S325)
    {
        return 0.0f;
    }
    var _S326 : f32 = - dot(_S311, normal_1);
    var _S327 : f32 = node_0.phi * _S324 / max(_S312, length(_S309) / 2.0f);
    var _S328 : f32 = sine(_S326);
    var _S329 : f32 = cosSubClamped(_S328, _S326, _S319, _S318);
    var _S330 : bool = (dot(normal_1, normal_1)) == 0.0f;
    var _S331 : f32 = select(_S329, 1.0f, _S330);
    return max(_S327 * _S331, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_2, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S332 : f32 = importance(first_0, p_1, normal_3);
    var _S333 : f32 = importance(second_0, p_1, normal_3);
    var _S334 : vec2<f32> = vec2<f32>(_S332, _S333);
    var _S335 : bool = _S332 == 0.0f;
    var _S336 : bool;
    if(_S335)
    {
        _S336 = _S333 == 0.0f;
    }
    else
    {
        _S336 = false;
    }
    if(_S336)
    {
        return u32(2);
    }
    var _S337 : f32 = _S332 + _S333;
    var _S338 : bool = _S333 > 0.0f;
    if(_S338)
    {
        _S336 = ((*pick_0) * _S337) >= _S332;
    }
    else
    {
        _S336 = false;
    }
    var _S339 : u32 = select(u32(0), u32(1), _S336);
    var _S340 : f32 = min(((*pick_0) * _S337 - f32(_S339) * _S332) / _S334[_S339], 0.99999994039535522f);
    (*pick_0) = _S340;
    var _S341 : f32 = (*probability_1) * (_S334[_S339] / _S337);
    (*probability_1) = _S341;
    return _S339;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_4 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S342 : f32 = importance(first_1, p_2, normal_4);
    var _S343 : f32 = importance(second_1, p_2, normal_4);
    var _S344 : vec2<f32> = vec2<f32>(_S342, _S343);
    var _S345 : f32 = _S344[child_0] / (_S342 + _S343);
    var _S346 : bool = (_S344[child_0]) > 0.0f;
    var _S347 : f32 = select(0.0f, _S345, _S346);
    return _S347;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S348 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S349 : bool = b_1 > 0.0f;
    var _S350 : f32 = select(1.0f, _S348, _S349);
    return _S350;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S351 : vec3<f32> = center_0 - p_3;
    var _S352 : f32 = radius_1 * radius_1 / dot(_S351, _S351);
    var _S353 : bool = _S352 >= 1.0f;
    if(_S353)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S352)) / (6.28318548202514648f * _S352);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S354 : vec3<f32> = center_1 - p_4;
    var _S355 : f32 = radius_2 * radius_2 / dot(_S354, _S354);
    var _S356 : f32 = u1_0 * _S355 / (1.0f + sqrt(max(1.0f - _S355, 0.0f)));
    var _S357 : f32 = 2.0f * u1_0;
    var _S358 : bool = _S355 >= 1.0f;
    var _S359 : f32 = select(_S356, _S357, _S358);
    var _S360 : f32 = sqrt(max(_S359 * (2.0f - _S359), 0.0f));
    var _S361 : f32 = 6.28318548202514648f * u2_0;
    var _S362 : vec3<f32> = vec3<f32>(_S360 * cos(_S361), 1.0f - _S359, _S360 * sin(_S361));
    var _S363 : vec3<f32> = (normalize((_S354)));
    var _S364 : vec3<f32> = tangentToWorld(_S362, _S363);
    return _S364;
}

