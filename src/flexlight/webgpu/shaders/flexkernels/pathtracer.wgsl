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

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S15 : u32 = hash(index_0);
    var _S16 : u32 = hash((seed_0 ^ (_S15)));
    return _S16;
}

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S17 : f32 = alpha_0 * alpha_0;
    var _S18 : f32 = n_dot_h_0 * n_dot_h_0 * (_S17 - 1.0f) + 1.0f;
    return _S17 / max(3.14159274101257324f * _S18 * _S18, 0.0000152587890625f);
}

fn G1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S19 : f32 = alpha_1 * 0.5f;
    return n_dot_x_0 / max(n_dot_x_0 * (1.0f - _S19) + _S19, 0.0000152587890625f);
}

fn smithG1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S20 : f32 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + sqrt(_S20 + (1.0f - _S20) * n_dot_x_1 * n_dot_x_1));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S21 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S22 : f32 = eta_i_0 / eta_o_0 * _S21;
    var _S23 : bool = _S22 < 1.0f;
    var kr_0 : f32;
    if(_S23)
    {
        var _S24 : f32 = sqrt(max(0.0f, 1.0f - _S22 * _S22));
        var _S25 : bool = eta_i_0 == eta_o_0;
        var _S26 : f32 = select(_S24, cos_theta_0, _S25);
        var _S27 : f32 = eta_o_0 * cos_theta_0;
        var _S28 : f32 = eta_i_0 * _S26;
        var _S29 : f32 = (_S27 - _S28) / (_S27 + _S28);
        var _S30 : f32 = eta_i_0 * cos_theta_0;
        var _S31 : f32 = eta_o_0 * _S26;
        var _S32 : f32 = (_S30 - _S31) / (_S30 + _S31);
        var _S33 : f32 = (_S29 * _S29 + _S32 * _S32) / 2.0f;
        kr_0 = _S33;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S34 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S35 : f32 = _S34.x;
    var _S36 : f32 = _S34.y;
    var _S37 : f32 = _S35 * _S35 + _S36 * _S36;
    const _S38 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S39 : vec3<f32> = vec3<f32>(- _S36, _S35, 0.0f);
    var _S40 : f32 = (inverseSqrt((_S37)));
    var _S41 : vec3<f32> = _S39 * vec3<f32>(_S40);
    var _S42 : bool = _S37 > 0.0f;
    var _S43 : vec3<f32> = select(_S38, _S41, _S42);
    var _S44 : vec3<f32> = cross(_S34, _S43);
    var _S45 : f32 = sqrt(U1_0);
    var _S46 : f32 = 6.28318548202514648f * U2_0;
    var _S47 : f32 = _S45 * cos(_S46);
    var t2_0 : f32 = _S45 * sin(_S46);
    var _S48 : f32 = 0.5f * (1.0f + _S34.z);
    var t2_1 : f32 = (1.0f - _S48) * sqrt(max(0.0f, 1.0f - _S47 * _S47)) + _S48 * t2_0;
    var _S49 : vec3<f32> = vec3<f32>(_S47) * _S43 + vec3<f32>(t2_1) * _S44;
    var _S50 : f32 = ((_S47));
    var _S51 : f32 = ((_S47));
    var _S52 : vec3<f32> = _S49 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S50 * _S51 - t2_1 * t2_1))) * _S34;
    var _S53 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S52.x, alpha_3 * _S52.y, max(0.0f, _S52.z)))));
    return _S53;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S54 : f32 = sqrt(random_1_0);
    var _S55 : f32 = 6.28318548202514648f * random_2_0;
    var _S56 : f32 = _S54 * cos(_S55);
    var _S57 : f32 = _S54 * sin(_S55);
    var _S58 : f32 = sqrt(max(0.0f, 1.0f - _S56 * _S56 - _S57 * _S57));
    return vec3<f32>(_S56, _S58, _S57);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S59 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S59)
    {
        const _S60 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S60;
    }
    else
    {
        a_1 = a_0;
    }
    var _S61 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S62 : vec3<f32> = cross(n_0, _S61);
    return vec3<f32>(v_0.x) * _S61 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S62;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S63 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S63)
    {
        const _S64 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S64;
    }
    else
    {
        a_3 = a_2;
    }
    var _S65 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S66 : vec3<f32> = cross(n_1, _S65);
    return vec3<f32>(dot(v_1, _S65), dot(v_1, n_1), dot(v_1, _S66));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S67 : vec3<f32> = p1_0 - p0_0;
    var _S68 : vec3<f32> = p2_0 - p0_0;
    var _S69 : vec2<f32> = uv1_0 - uv0_0;
    var _S70 : vec2<f32> = uv2_0 - uv0_0;
    var _S71 : f32 = _S69.x;
    var _S72 : f32 = _S70.y;
    var _S73 : f32 = _S69.y;
    var _S74 : f32 = _S70.x;
    var _S75 : f32 = _S71 * _S72 - _S73 * _S74;
    var _S76 : f32 = 1.0f / _S75;
    var _S77 : vec3<f32> = vec3<f32>(_S76);
    var t_0 : vec3<f32> = (_S67 * vec3<f32>(_S72) - _S68 * vec3<f32>(_S73)) * _S77;
    var _S78 : vec3<f32> = (_S68 * vec3<f32>(_S71) - _S67 * vec3<f32>(_S74)) * _S77;
    var _S79 : vec3<f32> = t_0 - n_2 * vec3<f32>(dot(n_2, t_0));
    var _S80 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_2);
    var _S81 : bool = (dot(_S79, _S79)) > 0.0f;
    var _S82 : vec3<f32> = select(_S80, _S79, _S81);
    var _S83 : vec3<f32> = (normalize((_S82)));
    var _S84 : bool = (dot(cross(n_2, _S83), _S78)) > 0.0f;
    var t_1 : vec3<f32>;
    if(_S84)
    {
        var _S85 : vec3<f32> = ((-(_S83)));
        t_1 = _S85;
    }
    else
    {
        t_1 = _S83;
    }
    var _S86 : vec3<f32> = cross(n_2, t_1);
    return mat3x3<f32>(t_1, _S86, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S87 : Random = pcg((*random_state_0));
    var _S88 : Random = pcg(_S87.state);
    (*random_state_0) = _S88.state;
    var _S89 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S90 : vec3<f32> = sampleGGXVNDF(_S89.xzy, alpha_4, _S87.value, _S88.value);
    var _S91 : vec3<f32> = _S90.xzy;
    var _S92 : vec3<f32> = tangentToWorld(_S91, n_i_0);
    return _S92;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S93 : vec3<f32> = ((-(in_dir_0)));
    var _S94 : f32 = (sign((dot(n_3, _S93))));
    var _S95 : f32 = material_0.roughness;
    var _S96 : vec3<f32> = sampleHalfVector(_S93, n_3 * vec3<f32>(_S94), _S95 * _S95, &(state_5));
    return _S96;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S97 : vec3<f32> = ((-(in_dir_1)));
    var _S98 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S97 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S99 : vec3<f32> = (normalize((_S98)));
    var _S100 : f32 = (sign((dot(n_4, _S97))));
    var _S101 : f32 = (sign((dot(_S98, n_4 * vec3<f32>(_S100)))));
    return _S99 * vec3<f32>(_S101);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S102 : vec3<f32> = ((-(in_dir_2)));
    var _S103 : vec3<f32> = (normalize((_S102 + out_dir_1)));
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
     diffuse_weight : f32,
     refract_weight : f32,
     colorless_reflection : f32,
     p_diffuse : f32,
     p_reflect : f32,
     p_refract : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : f32,  refract_weight_0 : f32,  colorless_reflection_0 : f32,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32) -> BSDFLobes
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
    _S104.colorless_reflection = colorless_reflection_0;
    _S104.p_diffuse = p_diffuse_0;
    _S104.p_reflect = p_reflect_0;
    _S104.p_refract = p_refract_0;
    return _S104;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S105 : f32 = dot(ggx_n_0, v_4);
    var _S106 : f32 = dot(n_i_1, ggx_n_0);
    var _S107 : f32 = eta_i_2 / eta_o_2;
    var _S108 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S107))));
    var _S109 : f32 = fresnel(abs(_S105), eta_i_2, eta_o_2);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S109)), (material_1.albedo), (material_1.metallic)));
    var _S110 : f32 = rgb_to_greyscale(F_1);
    var _S111 : f32 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    var _S112 : f32 = max(_S110, 0.0f);
    var _S113 : f32 = 1.0f - _S110;
    var _S114 : f32 = max(_S111 * _S113, 0.0f);
    var _S115 : f32 = material_1.transmission * _S113;
    var _S116 : f32 = (sign((length(_S108))));
    var _S117 : f32 = max(_S115 * _S116, 0.0f);
    var _S118 : f32 = _S112 + _S114 + _S117;
    var _S119 : f32 = 1.0f / max(_S118, 0.0000152587890625f);
    var _S120 : f32 = _S114 * _S119;
    var _S121 : f32 = _S112 * _S119;
    var _S122 : f32 = _S117 * _S119;
    return BSDFLobes_x24init_0(_S105, _S106, _S108, F_1, _S110, 1.0f, _S111, material_1.transmission, material_1.transmission, _S120, _S121, _S122);
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S123 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S124 : bool = n_i_dot_v_0 > 0.0f;
    var _S125 : f32 = select(0.0f, _S123, _S124);
    return _S125;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_7 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S126 : f32 = smithG1(alpha_7, n_i_dot_v_1);
    var _S127 : f32 = _S126 * lobes_2.v_dot_h;
    var _S128 : f32 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    var _S129 : f32 = _S127 * _S128 / n_i_dot_v_1;
    var _S130 : bool = alpha_7 > 0.0f;
    var _S131 : bool;
    if(_S130)
    {
        _S131 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S131 = false;
    }
    if(_S131)
    {
        _S131 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S131 = false;
    }
    if(_S131)
    {
        _S131 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S131 = false;
    }
    var _S132 : f32 = select(0.0f, _S129, _S131);
    return _S132;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_8 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S133 : f32 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    var _S134 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S135 : f32 = lobes_3.p_refract * _S133 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S134 * _S134);
    var _S136 : bool = eta_i_4 != eta_o_4;
    var _S137 : bool;
    if(_S136)
    {
        _S137 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S137 = false;
    }
    var _S138 : f32 = select(0.0f, _S135, _S137);
    return _S138;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_9 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S139 : f32 = - dot(n_i_3, l_1);
    var _S140 : f32 = G1(alpha_9, max(_S139, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S140 * (1.0f - lobes_4.F_greyscale) / lobes_4.p_refract));
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_10 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S141 : f32 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    var _S142 : f32 = lobes_5.p_reflect * _S141 / (4.0f * lobes_5.v_dot_h);
    var _S143 : bool = _S141 > 0.0f;
    var _S144 : f32 = select(0.0f, _S142, _S143);
    return _S144;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_11 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S145 : f32 = dot(n_i_4, l_2);
    var _S146 : f32 = G1(alpha_11, max(_S145, 0.0f));
    var _S147 : f32 = lobes_6.reflect_weight * _S146;
    var _S148 : vec3<f32> = (mix((lobes_6.F), (vec3<f32>(lobes_6.F_greyscale)), (lobes_6.colorless_reflection)));
    return vec3<f32>(_S147) * _S148 / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_2 : u32) -> vec3<f32>
{
    var _S149 : vec3<f32> = ((-(in_dir_4)));
    var _S150 : f32 = dot(n_5, _S149);
    var _S151 : f32 = (sign((_S150)));
    var _S152 : vec3<f32> = n_5 * vec3<f32>(_S151);
    var _S153 : f32 = dot(_S152, out_dir_2);
    var _S154 : f32 = material_5.roughness;
    var _S155 : f32 = _S154 * _S154;
    var _S156 : bool = (dot(g_n_0, _S149) * dot(g_n_0, out_dir_2)) > 0.0f;
    var _S157 : u32;
    if(_S156)
    {
        _S157 = u32(2);
    }
    else
    {
        _S157 = u32(1);
    }
    var _S158 : vec3<f32> = vec3<f32>(0.0f);
    var _S159 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S158, _S158, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S159;
    var ggx_n_1 : vec3<f32> = _S158;
    var f_0 : vec3<f32> = _S158;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < _S157)
        {
        }
        else
        {
            break;
        }
        var _S160 : u32;
        if(!_S156)
        {
            _S160 = u32(1);
        }
        else
        {
            if(i_0 == u32(0))
            {
                _S160 = u32(0);
            }
            else
            {
                _S160 = u32(2);
            }
        }
        var _S161 : bool = _S160 != half_of_0;
        var ggx_n_2 : vec3<f32>;
        if(_S161)
        {
            var _S162 : bool = _S160 == u32(0);
            if(_S162)
            {
                var _S163 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_2 = _S163;
            }
            else
            {
                var _S164 : bool = _S160 == u32(1);
                if(_S164)
                {
                    var _S165 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_2 = _S165;
                }
                else
                {
                    var _S166 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_2 = _S166;
                }
            }
            var _S167 : vec3<f32> = ((-(in_dir_4)));
            var _S168 : BSDFLobes = bsdfLobes(in_dir_4, _S167, _S152, ggx_n_2, material_5, eta_i_6, eta_o_6);
            lobe_terms_0 = _S168;
            half_of_0 = _S160;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        var throughput_0 : vec3<f32>;
        var pdf_0 : f32;
        switch(_S160)
        {
        case u32(0):
            {
                var _S169 : f32 = diffusePDF(_S153, 0.0f, abs(_S150), _S155, lobe_terms_0, eta_i_6, eta_o_6);
                var _S170 : vec3<f32> = diffuseBSDF(out_dir_2, _S152, _S155, material_5, lobe_terms_0);
                pdf_0 = _S169;
                throughput_0 = _S170;
            }
        case u32(1):
            {
                var _S171 : f32 = refractPDF(_S153, dot(out_dir_2, ggx_n_2), abs(_S150), _S155, lobe_terms_0, eta_i_6, eta_o_6);
                var _S172 : vec3<f32> = refractBSDF(out_dir_2, _S152, _S155, material_5, lobe_terms_0);
                pdf_0 = _S171;
                throughput_0 = _S172;
            }
        default :
            {
                var _S173 : f32 = reflectPDF(_S153, 0.0f, abs(_S150), _S155, lobe_terms_0, eta_i_6, eta_o_6);
                var _S174 : vec3<f32> = reflectBSDF(out_dir_2, _S152, _S155, material_5, lobe_terms_0);
                pdf_0 = _S173;
                throughput_0 = _S174;
            }
        }
        var _S175 : vec3<f32>;
        if(pdf_0 > 0.0f)
        {
            _S175 = throughput_0 * vec3<f32>(pdf_0);
        }
        else
        {
            _S175 = _S158;
        }
        if(i_0 == u32(0))
        {
            f_0 = _S175;
        }
        else
        {
            f_0 = f_0 + _S175;
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
    var _S176 : SampleBSDF;
    _S176.unit_direction = unit_direction_0;
    _S176.throughput = throughput_1;
    _S176.random_state = random_state_3;
    _S176.refracted = refracted_1;
    _S176.lobe = lobe_0;
    _S176.pdf = pdf_1;
    return _S176;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_12 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S177 : vec3<f32> = vec3<f32>(1.0f);
    var _S178 : SampleBSDF = SampleBSDF_x24init_0(_S177, _S177, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S178;
    var _S179 : Random = pcg(random_state_4);
    var _S180 : Random = pcg(_S179.state);
    sample_0.random_state = _S180.state;
    var _S181 : vec3<f32> = sampleCosWeightedHemisphere(_S179.value, _S180.value);
    var _S182 : vec3<f32> = tangentToWorld(_S181, n_i_5);
    sample_0.unit_direction = _S182;
    sample_0.lobe = u32(0);
    var _S183 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    sample_0.throughput = _S183;
    var _S184 : f32 = diffusePDF(_S181.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S184;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S185 : vec3<f32> = vec3<f32>(1.0f);
    var _S186 : SampleBSDF = SampleBSDF_x24init_0(_S185, _S185, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S186;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S187 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    sample_1.throughput = _S187;
    var _S188 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S188;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S189 : vec3<f32> = vec3<f32>(1.0f);
    var _S190 : SampleBSDF = SampleBSDF_x24init_0(_S189, _S189, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S190;
    var _S191 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S191;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S192 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    sample_2.throughput = _S192;
    var _S193 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S193;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S194 : vec3<f32> = ((-(in_dir_6)));
    var _S195 : f32 = dot(n_6, _S194);
    var _S196 : f32 = (sign((_S195)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S196);
    var _S197 : f32 = abs(_S195);
    var _S198 : f32 = material_9.roughness;
    var _S199 : f32 = _S198 * _S198;
    var _S200 : vec3<f32> = sampleHalfVector(_S194, n_i_8, _S199, &(random_state_7));
    var _S201 : BSDFLobes = bsdfLobes(in_dir_6, _S194, n_i_8, _S200, material_9, eta_i_10, eta_o_10);
    var _S202 : Random = pcg(random_state_7);
    random_state_7 = _S202.state;
    var _S203 : bool = (_S202.value) < (_S201.p_diffuse);
    if(_S203)
    {
        var _S204 : SampleBSDF = diffuseSample(n_i_8, _S197, _S199, material_9, _S201, eta_i_10, eta_o_10, random_state_7);
        return _S204;
    }
    var _S205 : bool = (_S202.value) < (_S201.p_diffuse + _S201.p_refract);
    if(_S205)
    {
        var _S206 : SampleBSDF = refractSample(_S200, n_i_8, _S197, _S199, material_9, _S201, eta_i_10, eta_o_10, random_state_7);
        return _S206;
    }
    var _S207 : SampleBSDF = reflectSample(in_dir_6, _S200, n_i_8, _S197, _S199, material_9, _S201, eta_i_10, eta_o_10, random_state_7);
    return _S207;
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S208 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S209 : vec3<f32> = (mix((vec3<f32>(_S208)), (material_10.albedo), (material_10.metallic)));
    var _S210 : f32 = rgb_to_greyscale(_S209);
    var _S211 : f32 = max((1.0f - _S210) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S212 : bool = _S211 > 0.03999999910593033f;
    var _S213 : bool;
    if(_S212)
    {
        _S213 = true;
    }
    else
    {
        _S213 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S213;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S214 : vec3<f32> = a_4 / b_0;
    var _S215 : vec3<f32> = vec3<f32>(0.0f);
    var _S216 : vec3<bool> = b_0 == _S215;
    var _S217 : vec3<f32> = select(_S214, _S215, _S216);
    return _S217;
}

