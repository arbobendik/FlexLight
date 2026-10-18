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
    var _S4 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S5 : u32 = hash(state_1);
    return Random_x24init_0(_S4, f32(_S5) / 4.294967296e+09f);
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S6 : Random = pcg(state_2);
    var _S7 : Random = pcg(_S6.state);
    var _S8 : f32 = 6.28318548202514648f * _S6.value;
    var _S9 : f32 = sqrt(-2.0f * clamp(log(_S7.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S7.state, _S9 * cos(_S8));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S10 : RandomSphere;
    _S10.state = state_3;
    _S10.value = value_1;
    return _S10;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S11 : Random = normal_distribution(state_4);
    var _S12 : Random = normal_distribution(_S11.state);
    var _S13 : Random = normal_distribution(_S12.state);
    var _S14 : vec3<f32> = (normalize((vec3<f32>(_S11.value, _S12.value, _S13.value))));
    return RandomSphere_x24init_0(_S13.state, _S14);
}

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S15 : f32 = alpha_0 * alpha_0;
    var _S16 : f32 = n_dot_h_0 * n_dot_h_0 * (_S15 - 1.0f) + 1.0f;
    return _S15 / max(3.14159274101257324f * _S16 * _S16, 0.0000152587890625f);
}

fn G1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S17 : f32 = alpha_1 * 0.5f;
    return n_dot_x_0 / max(n_dot_x_0 * (1.0f - _S17) + _S17, 0.0000152587890625f);
}

fn smithG1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S18 : f32 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + sqrt(_S18 + (1.0f - _S18) * n_dot_x_1 * n_dot_x_1));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S19 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S20 : f32 = eta_i_0 / eta_o_0 * _S19;
    var _S21 : bool = _S20 < 1.0f;
    var kr_0 : f32;
    if(_S21)
    {
        var _S22 : f32 = sqrt(max(0.0f, 1.0f - _S20 * _S20));
        var _S23 : f32 = eta_o_0 * cos_theta_0;
        var _S24 : f32 = eta_i_0 * _S22;
        var _S25 : f32 = (_S23 - _S24) / (_S23 + _S24);
        var _S26 : f32 = eta_i_0 * cos_theta_0;
        var _S27 : f32 = eta_o_0 * _S22;
        var _S28 : f32 = (_S26 - _S27) / (_S26 + _S27);
        var _S29 : f32 = (_S25 * _S25 + _S28 * _S28) / 2.0f;
        kr_0 = _S29;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S30 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S31 : f32 = _S30.x;
    var _S32 : f32 = _S30.y;
    var _S33 : f32 = _S31 * _S31 + _S32 * _S32;
    const _S34 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S35 : vec3<f32> = vec3<f32>(- _S32, _S31, 0.0f);
    var _S36 : f32 = (inverseSqrt((_S33)));
    var _S37 : vec3<f32> = _S35 * vec3<f32>(_S36);
    var _S38 : bool = _S33 > 0.0f;
    var _S39 : vec3<f32> = select(_S34, _S37, _S38);
    var _S40 : vec3<f32> = cross(_S30, _S39);
    var _S41 : f32 = sqrt(U1_0);
    var _S42 : f32 = 6.28318548202514648f * U2_0;
    var _S43 : f32 = _S41 * cos(_S42);
    var t2_0 : f32 = _S41 * sin(_S42);
    var _S44 : f32 = 0.5f * (1.0f + _S30.z);
    var t2_1 : f32 = (1.0f - _S44) * sqrt(max(0.0f, 1.0f - _S43 * _S43)) + _S44 * t2_0;
    var _S45 : vec3<f32> = vec3<f32>(_S43) * _S39 + vec3<f32>(t2_1) * _S40;
    var _S46 : f32 = ((_S43));
    var _S47 : f32 = ((_S43));
    var _S48 : vec3<f32> = _S45 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S46 * _S47 - t2_1 * t2_1))) * _S30;
    var _S49 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S48.x, alpha_3 * _S48.y, max(0.0f, _S48.z)))));
    return _S49;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S50 : f32 = sqrt(random_1_0);
    var _S51 : f32 = 6.28318548202514648f * random_2_0;
    var _S52 : f32 = _S50 * cos(_S51);
    var _S53 : f32 = _S50 * sin(_S51);
    var _S54 : f32 = sqrt(max(0.0f, 1.0f - _S52 * _S52 - _S53 * _S53));
    return vec3<f32>(_S52, _S54, _S53);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S55 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S55)
    {
        const _S56 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S56;
    }
    else
    {
        a_1 = a_0;
    }
    var _S57 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S58 : vec3<f32> = cross(n_0, _S57);
    return vec3<f32>(v_0.x) * _S57 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S58;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S59 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S59)
    {
        const _S60 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S60;
    }
    else
    {
        a_3 = a_2;
    }
    var _S61 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S62 : vec3<f32> = cross(n_1, _S61);
    return vec3<f32>(dot(v_1, _S61), dot(v_1, n_1), dot(v_1, _S62));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S63 : vec3<f32> = p1_0 - p0_0;
    var _S64 : vec3<f32> = p2_0 - p0_0;
    var _S65 : vec2<f32> = uv1_0 - uv0_0;
    var _S66 : vec2<f32> = uv2_0 - uv0_0;
    var _S67 : f32 = _S65.x;
    var _S68 : f32 = _S66.y;
    var _S69 : f32 = _S65.y;
    var _S70 : f32 = _S66.x;
    var _S71 : f32 = _S67 * _S68 - _S69 * _S70;
    var _S72 : f32 = 1.0f / _S71;
    var _S73 : vec3<f32> = vec3<f32>(_S72);
    var t_0 : vec3<f32> = (_S63 * vec3<f32>(_S68) - _S64 * vec3<f32>(_S69)) * _S73;
    var _S74 : vec3<f32> = (_S64 * vec3<f32>(_S67) - _S63 * vec3<f32>(_S70)) * _S73;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S75 : bool = (dot(cross(n_2, t_1), _S74)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S75)
    {
        var _S76 : vec3<f32> = ((-(t_1)));
        t_2 = _S76;
    }
    else
    {
        t_2 = t_1;
    }
    var _S77 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S77, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S78 : Random = pcg((*random_state_0));
    var _S79 : Random = pcg(_S78.state);
    (*random_state_0) = _S79.state;
    var _S80 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S81 : vec3<f32> = sampleGGXVNDF(_S80.xzy, alpha_4, _S78.value, _S79.value);
    var _S82 : vec3<f32> = _S81.xzy;
    var _S83 : vec3<f32> = tangentToWorld(_S82, n_i_0);
    return _S83;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S84 : vec3<f32> = ((-(in_dir_0)));
    var _S85 : f32 = (sign((dot(n_3, _S84))));
    var _S86 : f32 = material_0.roughness;
    var _S87 : vec3<f32> = sampleHalfVector(_S84, n_3 * vec3<f32>(_S85), _S86 * _S86, &(state_5));
    return _S87;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S88 : vec3<f32> = ((-(in_dir_1)));
    var _S89 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S88 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S90 : vec3<f32> = (normalize((_S89)));
    var _S91 : f32 = (sign((dot(n_4, _S88))));
    var _S92 : f32 = (sign((dot(_S89, n_4 * vec3<f32>(_S91)))));
    return _S90 * vec3<f32>(_S92);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S93 : vec3<f32> = ((-(in_dir_2)));
    var _S94 : vec3<f32> = (normalize((_S93 + out_dir_1)));
    return _S94;
}

struct BSDFLobes
{
     v_dot_h : f32,
     n_dot_h : f32,
     refracted : vec3<f32>,
     F : vec3<f32>,
     F_greyscale : f32,
     reflect_weight : f32,
     diffuse_weight : f32,
     refract_weight : f32,
     p_diffuse : f32,
     p_reflect : f32,
     p_refract : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : f32,  refract_weight_0 : f32,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32) -> BSDFLobes
{
    var _S95 : BSDFLobes;
    _S95.v_dot_h = v_dot_h_0;
    _S95.n_dot_h = n_dot_h_1;
    _S95.refracted = refracted_0;
    _S95.F = F_0;
    _S95.F_greyscale = F_greyscale_0;
    _S95.reflect_weight = reflect_weight_0;
    _S95.diffuse_weight = diffuse_weight_0;
    _S95.refract_weight = refract_weight_0;
    _S95.p_diffuse = p_diffuse_0;
    _S95.p_reflect = p_reflect_0;
    _S95.p_refract = p_refract_0;
    return _S95;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S96 : f32 = dot(ggx_n_0, v_4);
    var _S97 : f32 = dot(n_i_1, ggx_n_0);
    var _S98 : f32 = eta_i_2 / eta_o_2;
    var _S99 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S98))));
    var _S100 : f32 = fresnel(abs(_S96), eta_i_2, eta_o_2);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S100)), (material_1.albedo), (material_1.metallic)));
    var _S101 : f32 = rgb_to_greyscale(F_1);
    var _S102 : f32 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    var _S103 : f32 = max(_S101, 0.0f);
    var _S104 : f32 = 1.0f - _S101;
    var _S105 : f32 = max(_S102 * _S104, 0.0f);
    var _S106 : f32 = material_1.transmission * _S104;
    var _S107 : f32 = (sign((length(_S99))));
    var _S108 : f32 = max(_S106 * _S107, 0.0f);
    var _S109 : f32 = _S103 + _S105 + _S108;
    var _S110 : f32 = 1.0f / max(_S109, 0.0000152587890625f);
    var _S111 : f32 = _S105 * _S110;
    var _S112 : f32 = _S103 * _S110;
    var _S113 : f32 = _S108 * _S110;
    return BSDFLobes_x24init_0(_S96, _S97, _S99, F_1, _S101, 1.0f, _S102, material_1.transmission, _S111, _S112, _S113);
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S114 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S115 : bool = n_i_dot_v_0 > 0.0f;
    var _S116 : f32 = select(0.0f, _S114, _S115);
    return _S116;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_7 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S117 : f32 = smithG1(alpha_7, n_i_dot_v_1);
    var _S118 : f32 = _S117 * lobes_2.v_dot_h;
    var _S119 : f32 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    var _S120 : f32 = _S118 * _S119 / n_i_dot_v_1;
    var _S121 : bool = alpha_7 > 0.0f;
    var _S122 : bool;
    if(_S121)
    {
        _S122 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S122 = false;
    }
    if(_S122)
    {
        _S122 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S122 = false;
    }
    if(_S122)
    {
        _S122 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S122 = false;
    }
    var _S123 : f32 = select(0.0f, _S120, _S122);
    return _S123;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_8 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S124 : f32 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    var _S125 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S126 : f32 = lobes_3.p_refract * _S124 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S125 * _S125);
    var _S127 : bool = eta_i_4 != eta_o_4;
    var _S128 : bool;
    if(_S127)
    {
        _S128 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S128 = false;
    }
    var _S129 : f32 = select(0.0f, _S126, _S128);
    return _S129;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_9 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S130 : f32 = - dot(n_i_3, l_1);
    var _S131 : f32 = G1(alpha_9, max(_S130, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S131 * (1.0f - lobes_4.F_greyscale))) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_10 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S132 : f32 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    var _S133 : f32 = lobes_5.p_reflect * _S132 / (4.0f * lobes_5.v_dot_h);
    var _S134 : bool = _S132 > 0.0f;
    var _S135 : f32 = select(0.0f, _S133, _S134);
    return _S135;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_11 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S136 : f32 = dot(n_i_4, l_2);
    var _S137 : f32 = G1(alpha_11, max(_S136, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S137)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_2 : u32) -> vec3<f32>
{
    var _S138 : vec3<f32> = ((-(in_dir_4)));
    var _S139 : f32 = dot(n_5, _S138);
    var _S140 : f32 = (sign((_S139)));
    var _S141 : vec3<f32> = n_5 * vec3<f32>(_S140);
    var _S142 : f32 = dot(_S141, out_dir_2);
    var _S143 : f32 = material_5.roughness;
    var _S144 : f32 = _S143 * _S143;
    var _S145 : bool = (dot(g_n_0, _S138) * dot(g_n_0, out_dir_2)) > 0.0f;
    var _S146 : u32;
    if(_S145)
    {
        _S146 = u32(2);
    }
    else
    {
        _S146 = u32(1);
    }
    var _S147 : vec3<f32> = vec3<f32>(0.0f);
    var _S148 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S147, _S147, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S148;
    var ggx_n_1 : vec3<f32> = _S147;
    var f_0 : vec3<f32> = _S147;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < _S146)
        {
        }
        else
        {
            break;
        }
        var _S149 : u32;
        if(!_S145)
        {
            _S149 = u32(1);
        }
        else
        {
            if(i_0 == u32(0))
            {
                _S149 = u32(0);
            }
            else
            {
                _S149 = u32(2);
            }
        }
        var _S150 : bool = _S149 != half_of_0;
        var ggx_n_2 : vec3<f32>;
        if(_S150)
        {
            var _S151 : bool = _S149 == u32(0);
            if(_S151)
            {
                var _S152 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_2 = _S152;
            }
            else
            {
                var _S153 : bool = _S149 == u32(1);
                if(_S153)
                {
                    var _S154 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_2 = _S154;
                }
                else
                {
                    var _S155 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_2 = _S155;
                }
            }
            var _S156 : vec3<f32> = ((-(in_dir_4)));
            var _S157 : BSDFLobes = bsdfLobes(in_dir_4, _S156, _S141, ggx_n_2, material_5, eta_i_6, eta_o_6);
            lobe_terms_0 = _S157;
            half_of_0 = _S149;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        var throughput_0 : vec3<f32>;
        var pdf_0 : f32;
        switch(_S149)
        {
        case u32(0):
            {
                var _S158 : f32 = diffusePDF(_S142, 0.0f, abs(_S139), _S144, lobe_terms_0, eta_i_6, eta_o_6);
                var _S159 : vec3<f32> = diffuseBSDF(out_dir_2, _S141, _S144, material_5, lobe_terms_0);
                pdf_0 = _S158;
                throughput_0 = _S159;
            }
        case u32(1):
            {
                var _S160 : f32 = refractPDF(_S142, dot(out_dir_2, ggx_n_2), abs(_S139), _S144, lobe_terms_0, eta_i_6, eta_o_6);
                var _S161 : vec3<f32> = refractBSDF(out_dir_2, _S141, _S144, material_5, lobe_terms_0);
                pdf_0 = _S160;
                throughput_0 = _S161;
            }
        default :
            {
                var _S162 : f32 = reflectPDF(_S142, 0.0f, abs(_S139), _S144, lobe_terms_0, eta_i_6, eta_o_6);
                var _S163 : vec3<f32> = reflectBSDF(out_dir_2, _S141, _S144, material_5, lobe_terms_0);
                pdf_0 = _S162;
                throughput_0 = _S163;
            }
        }
        var _S164 : vec3<f32>;
        if(pdf_0 > 0.0f)
        {
            _S164 = throughput_0 * vec3<f32>(pdf_0);
        }
        else
        {
            _S164 = _S147;
        }
        if(i_0 == u32(0))
        {
            f_0 = _S164;
        }
        else
        {
            f_0 = f_0 + _S164;
        }
        var i_1 : u32 = i_0 + u32(1);
        ggx_n_1 = ggx_n_2;
        i_0 = i_1;
    }
    return f_0;
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

fn SampleBSDF_x24init_0( unit_direction_0 : vec3<f32>,  throughput_1 : vec3<f32>,  random_state_3 : u32,  refracted_1 : bool,  lobe_0 : u32,  pdf_1 : f32) -> SampleBSDF
{
    var _S165 : SampleBSDF;
    _S165.unit_direction = unit_direction_0;
    _S165.throughput = throughput_1;
    _S165.random_state = random_state_3;
    _S165.refracted = refracted_1;
    _S165.lobe = lobe_0;
    _S165.pdf = pdf_1;
    return _S165;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_12 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S166 : vec3<f32> = vec3<f32>(1.0f);
    var _S167 : SampleBSDF = SampleBSDF_x24init_0(_S166, _S166, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S167;
    var _S168 : Random = pcg(random_state_4);
    var _S169 : Random = pcg(_S168.state);
    sample_0.random_state = _S169.state;
    var _S170 : vec3<f32> = sampleCosWeightedHemisphere(_S168.value, _S169.value);
    var _S171 : vec3<f32> = tangentToWorld(_S170, n_i_5);
    sample_0.unit_direction = _S171;
    sample_0.lobe = u32(0);
    var _S172 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    sample_0.throughput = _S172;
    var _S173 : f32 = diffusePDF(_S170.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S173;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S174 : vec3<f32> = vec3<f32>(1.0f);
    var _S175 : SampleBSDF = SampleBSDF_x24init_0(_S174, _S174, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S175;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S176 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    sample_1.throughput = _S176;
    var _S177 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S177;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S178 : vec3<f32> = vec3<f32>(1.0f);
    var _S179 : SampleBSDF = SampleBSDF_x24init_0(_S178, _S178, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S179;
    var _S180 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S180;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S181 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    sample_2.throughput = _S181;
    var _S182 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S182;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S183 : vec3<f32> = ((-(in_dir_6)));
    var _S184 : f32 = dot(n_6, _S183);
    var _S185 : f32 = (sign((_S184)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S185);
    var _S186 : f32 = abs(_S184);
    var _S187 : f32 = material_9.roughness;
    var _S188 : f32 = _S187 * _S187;
    var _S189 : vec3<f32> = sampleHalfVector(_S183, n_i_8, _S188, &(random_state_7));
    var _S190 : BSDFLobes = bsdfLobes(in_dir_6, _S183, n_i_8, _S189, material_9, eta_i_10, eta_o_10);
    var _S191 : Random = pcg(random_state_7);
    random_state_7 = _S191.state;
    var _S192 : bool = (_S191.value) < (_S190.p_diffuse);
    if(_S192)
    {
        var _S193 : SampleBSDF = diffuseSample(n_i_8, _S186, _S188, material_9, _S190, eta_i_10, eta_o_10, random_state_7);
        return _S193;
    }
    var _S194 : bool = (_S191.value) < (_S190.p_diffuse + _S190.p_refract);
    if(_S194)
    {
        var _S195 : SampleBSDF = refractSample(_S189, n_i_8, _S186, _S188, material_9, _S190, eta_i_10, eta_o_10, random_state_7);
        return _S195;
    }
    var _S196 : SampleBSDF = reflectSample(in_dir_6, _S189, n_i_8, _S186, _S188, material_9, _S190, eta_i_10, eta_o_10, random_state_7);
    return _S196;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S197 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S197));
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S198 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S199 : vec3<f32> = (mix((vec3<f32>(_S198)), (material_10.albedo), (material_10.metallic)));
    var _S200 : f32 = rgb_to_greyscale(_S199);
    var _S201 : f32 = max((1.0f - _S200) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S202 : bool = _S201 > 0.03999999910593033f;
    var _S203 : bool;
    if(_S202)
    {
        _S203 = true;
    }
    else
    {
        _S203 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S203;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S204 : u32 = hash(index_0);
    var _S205 : u32 = hash((seed_0 ^ (_S204)));
    return _S205;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S206 : vec3<f32> = a_4 / b_0;
    var _S207 : vec3<f32> = vec3<f32>(0.0f);
    var _S208 : vec3<bool> = b_0 == _S207;
    var _S209 : vec3<f32> = select(_S206, _S207, _S208);
    return _S209;
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
    var _S210 : f32 = rgb_to_greyscale(weight_0);
    var _S211 : bool = _S210 > 0.0f;
    var _S212 : bool;
    if(_S211)
    {
        _S212 = _S210 < 3.00000000549775576e+38f;
    }
    else
    {
        _S212 = false;
    }
    var _S213 : bool = !_S212;
    if(_S213)
    {
        return;
    }
    var _S214 : f32 = (*sel_0).w_sum + _S210;
    (*sel_0).w_sum = _S214;
    var _S215 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S215;
    var _S216 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S216.state;
    var _S217 : bool = (_S216.value * (*sel_0).w_sum) <= _S210;
    if(_S217)
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
    var _S218 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S218;
    var _S219 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S219;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S220 : f32 = rgb_to_greyscale(r_1.f);
    var _S221 : f32 = sel_2.w_sum / _S220;
    var _S222 : bool = _S220 > 0.0f;
    var _S223 : f32 = select(0.0f, _S221, _S222);
    r_1.w = _S223;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S224 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S225 : u32 = (insertBits((_S224), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S225;
    candidate_2.f = f_1;
    return candidate_2;
}

