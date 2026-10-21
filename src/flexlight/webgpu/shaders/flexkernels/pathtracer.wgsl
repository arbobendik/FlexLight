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
    var _S16 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S15 * n_dot_h_0 * n_dot_h_0;
    return _S15 / max(3.14159274101257324f * _S16 * _S16, 1.17549435082228751e-38f);
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
    var _S84 : BSDFLobes;
    _S84.v_dot_h = v_dot_h_0;
    _S84.n_dot_h = n_dot_h_1;
    _S84.refracted = refracted_0;
    _S84.F = F_0;
    _S84.F_greyscale = F_greyscale_0;
    _S84.reflect_weight = reflect_weight_0;
    _S84.diffuse_weight = diffuse_weight_0;
    _S84.refract_weight = refract_weight_0;
    _S84.p_diffuse = p_diffuse_0;
    _S84.p_reflect = p_reflect_0;
    _S84.p_refract = p_refract_0;
    return _S84;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S85 : f32 = dot(ggx_n_0, v_4);
    var _S86 : f32 = dot(n_i_1, ggx_n_0);
    var _S87 : f32 = eta_i_1 / eta_o_1;
    var _S88 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S87))));
    var _S89 : f32 = fresnel(abs(_S85), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S89)), (material_0.albedo), (material_0.metallic)));
    var _S90 : f32 = rgb_to_greyscale(F_1);
    var _S91 : f32 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    var _S92 : f32 = max(_S90, 0.0f);
    var _S93 : f32 = 1.0f - _S90;
    var _S94 : f32 = max(_S91 * _S93, 0.0f);
    var _S95 : f32 = material_0.transmission * _S93;
    var _S96 : f32 = (sign((length(_S88))));
    var _S97 : f32 = max(_S95 * _S96, 0.0f);
    var _S98 : f32 = _S92 + _S94 + _S97;
    var _S99 : f32 = 1.0f / max(_S98, 0.0000152587890625f);
    var _S100 : f32 = _S94 * _S99;
    var _S101 : f32 = _S92 * _S99;
    var _S102 : f32 = _S97 * _S99;
    return BSDFLobes_x24init_0(_S85, _S86, _S88, F_1, _S90, 1.0f, _S91, material_0.transmission, _S100, _S101, _S102);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S103 : bool = lobe_0 == u32(0);
    if(_S103)
    {
        var _S104 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S105 : bool = n_i_dot_v_0 > 0.0f;
        var _S106 : f32 = select(0.0f, _S104, _S105);
        return _S106;
    }
    var _S107 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S108 : f32 = _S107 * lobes_0.v_dot_h;
    var _S109 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S110 : f32 = _S108 * _S109 / n_i_dot_v_0;
    var _S111 : bool = alpha_5 > 0.0f;
    var _S112 : bool;
    if(_S111)
    {
        _S112 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S112 = false;
    }
    if(_S112)
    {
        _S112 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S112 = false;
    }
    if(_S112)
    {
        _S112 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S112 = false;
    }
    var _S113 : f32 = select(0.0f, _S110, _S112);
    var _S114 : bool = lobe_0 == u32(1);
    if(_S114)
    {
        var _S115 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S116 : f32 = lobes_0.p_refract * _S113 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S115 * _S115);
        var _S117 : bool = eta_i_2 != eta_o_2;
        if(_S117)
        {
            _S112 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S112 = false;
        }
        var _S118 : f32 = select(0.0f, _S116, _S112);
        return _S118;
    }
    var _S119 : f32 = lobes_0.p_reflect * _S113 / (4.0f * lobes_0.v_dot_h);
    var _S120 : bool = _S113 > 0.0f;
    var _S121 : f32 = select(0.0f, _S119, _S120);
    return _S121;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S122 : bool = lobe_1 == u32(0);
    if(_S122)
    {
        return vec3<f32>(lobes_1.diffuse_weight) * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S123 : bool = lobe_1 == u32(1);
    if(_S123)
    {
        var _S124 : f32 = - dot(n_i_2, l_0);
        var _S125 : f32 = G1(alpha_6, max(_S124, 0.0f));
        return vec3<f32>((lobes_1.refract_weight * _S125 * (1.0f - lobes_1.F_greyscale))) * material_1.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S126 : f32 = dot(n_i_2, l_0);
    var _S127 : f32 = G1(alpha_6, max(_S126, 0.0f));
    return vec3<f32>((lobes_1.reflect_weight * _S127)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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
    var _S128 : SampleBSDF;
    _S128.unit_direction = unit_direction_0;
    _S128.throughput = throughput_0;
    _S128.random_state = random_state_1;
    _S128.refracted = refracted_1;
    _S128.lobe = lobe_2;
    _S128.pdf = pdf_0;
    return _S128;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S129 : vec3<f32> = ((-(in_dir_1)));
    var _S130 : f32 = dot(n_3, _S129);
    var _S131 : f32 = (sign((_S130)));
    var _S132 : vec3<f32> = n_3 * vec3<f32>(_S131);
    var _S133 : f32 = material_2.roughness;
    var _S134 : f32 = _S133 * _S133;
    var _S135 : vec3<f32> = (normalize((_S129 + out_dir_0)));
    var _S136 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S136)
    {
        var _S137 : vec3<f32> = sampleHalfVector(_S129, _S132, _S134, &(random_state_2));
        ggx_n_1 = _S137;
    }
    else
    {
        var _S138 : bool = lobe_3 == u32(1);
        if(_S138)
        {
            var _S139 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S129 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S140 : vec3<f32> = (normalize((_S139)));
            var _S141 : f32 = (sign((dot(_S139, _S132))));
            var _S142 : vec3<f32> = _S140 * vec3<f32>(_S141);
            ggx_n_1 = _S142;
        }
        else
        {
            ggx_n_1 = _S135;
        }
    }
    var _S143 : BSDFLobes = bsdfLobes(in_dir_1, _S129, _S132, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S144 : f32 = lobeDensity(dot(_S132, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S130), _S134, _S143, eta_i_3, eta_o_3, lobe_3);
    var _S145 : bool = !(_S144 > 0.0f);
    if(_S145)
    {
        var _S146 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S146, _S146, u32(0), false, u32(0), 0.0f);
    }
    var _S147 : vec3<f32> = lobeThroughput(out_dir_0, _S132, _S134, material_2, _S143, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S147, random_state_2, lobe_3 == u32(1), lobe_3, _S144);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S148 : vec3<f32> = ((-(in_dir_2)));
    var _S149 : bool = (dot(g_n_0, _S148) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S149)
    {
        var _S150 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S151 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S150.throughput * vec3<f32>(_S150.pdf) + _S151.throughput * vec3<f32>(_S151.pdf);
    }
    var _S152 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S152.throughput * vec3<f32>(_S152.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S153 : vec3<f32> = ((-(in_dir_3)));
    var _S154 : f32 = dot(n_5, _S153);
    var _S155 : f32 = (sign((_S154)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S155);
    var _S156 : f32 = abs(_S154);
    var _S157 : f32 = material_4.roughness;
    var _S158 : f32 = _S157 * _S157;
    var _S159 : vec3<f32> = sampleHalfVector(_S153, n_i_3, _S158, &(random_state_4));
    var _S160 : BSDFLobes = bsdfLobes(in_dir_3, _S153, n_i_3, _S159, material_4, eta_i_5, eta_o_5);
    var _S161 : vec3<f32> = vec3<f32>(1.0f);
    var _S162 : SampleBSDF = SampleBSDF_x24init_0(_S161, _S161, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S162;
    var _S163 : Random = pcg(random_state_4);
    random_state_4 = _S163.state;
    var _S164 : bool = (_S163.value) < (_S160.p_diffuse);
    if(_S164)
    {
        var _S165 : Random = pcg(random_state_4);
        var _S166 : Random = pcg(_S165.state);
        sample_0.random_state = _S166.state;
        var _S167 : vec3<f32> = sampleCosWeightedHemisphere(_S165.value, _S166.value);
        var _S168 : vec3<f32> = tangentToWorld(_S167, n_i_3);
        sample_0.unit_direction = _S168;
        var _S169 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S158, material_4, _S160, u32(0));
        sample_0.throughput = _S169;
        var _S170 : f32 = lobeDensity(_S167.y, 0.0f, _S156, _S158, _S160, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S170;
        return sample_0;
    }
    var _S171 : bool = (_S163.value) < (_S160.p_diffuse + _S160.p_refract);
    if(_S171)
    {
        sample_0.unit_direction = _S160.refracted;
        var _S172 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S159), _S156, _S158, _S160, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S172;
        var _S173 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S158, material_4, _S160, u32(1));
        sample_0.throughput = _S173;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S174 : vec3<f32> = (normalize((reflect(in_dir_3, _S159))));
    sample_0.unit_direction = _S174;
    var _S175 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S158, material_4, _S160, u32(2));
    sample_0.throughput = _S175;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S176 : f32 = lobeDensity(0.0f, 0.0f, _S156, _S158, _S160, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S176;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S177 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S177));
}

fn neeDecision( material_5 : Material,  n_dot_v_0 : f32,  eta_i_6 : f32,  eta_o_6 : f32) -> bool
{
    var _S178 : f32 = fresnel(abs(n_dot_v_0), eta_i_6, eta_o_6);
    var _S179 : vec3<f32> = (mix((vec3<f32>(_S178)), (material_5.albedo), (material_5.metallic)));
    var _S180 : f32 = rgb_to_greyscale(_S179);
    var _S181 : f32 = max((1.0f - _S180) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission), 0.0f);
    var _S182 : bool = _S181 > 0.03999999910593033f;
    var _S183 : bool;
    if(_S182)
    {
        _S183 = true;
    }
    else
    {
        _S183 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S183;
}

fn neeBSDF( in_dir_4 : vec3<f32>,  dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_5 : u32) -> vec3<f32>
{
    var _S184 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S184;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S185 : bool = (lobe_4 == u32(1)) == refracted_2;
        var f_1 : vec3<f32>;
        if(_S185)
        {
            var _S186 : SampleBSDF = connectBSDF(in_dir_4, dir_0, n_6, material_6, eta_i_7, eta_o_7, lobe_4, random_state_5);
            var _S187 : bool = (_S186.pdf) > 0.0f;
            if(_S187)
            {
                if(power_0)
                {
                    var _S188 : f32 = _S186.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S186.throughput * vec3<f32>(_S186.pdf) / vec3<f32>((pdf_1 * (1.0f + _S188 * _S188)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S186.throughput * vec3<f32>(_S186.pdf) / vec3<f32>((_S186.pdf + pdf_1));
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
    var _S189 : f32 = rgb_to_greyscale(material_7.albedo * vec3<f32>(material_7.metallic));
    var _S190 : f32 = material_7.roughness;
    var _S191 : f32 = G1(_S190 * _S190, abs(dot(n_7, dir_1)));
    return vec3<f32>((material_7.transmission * _S191 * (1.0f - _S189))) * material_7.albedo;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S192 : u32 = hash(index_0);
    var _S193 : u32 = hash((seed_0 ^ (_S192)));
    return _S193;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S194 : vec3<f32> = a_4 / b_0;
    var _S195 : vec3<f32> = vec3<f32>(0.0f);
    var _S196 : vec3<bool> = b_0 == _S195;
    var _S197 : vec3<f32> = select(_S194, _S195, _S196);
    return _S197;
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
    var _S198 : f32 = rgb_to_greyscale(weight_0);
    var _S199 : bool = _S198 > 0.0f;
    var _S200 : bool;
    if(_S199)
    {
        _S200 = _S198 < 3.00000000549775576e+38f;
    }
    else
    {
        _S200 = false;
    }
    var _S201 : bool = !_S200;
    if(_S201)
    {
        return;
    }
    var _S202 : f32 = (*sel_0).w_sum + _S198;
    (*sel_0).w_sum = _S202;
    var _S203 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S203;
    var _S204 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S204.state;
    var _S205 : bool = (_S204.value * (*sel_0).w_sum) <= _S198;
    if(_S205)
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
    var _S206 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S206;
    var _S207 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S207;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S208 : f32 = rgb_to_greyscale(r_1.f);
    var _S209 : f32 = sel_2.w_sum / _S208;
    var _S210 : bool = _S208 > 0.0f;
    var _S211 : f32 = select(0.0f, _S209, _S210);
    r_1.w = _S211;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S212 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S213 : u32 = (insertBits((_S212), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S213;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S214 : bool = transmission_0 > 0.0f;
    var _S215 : bool;
    if(_S214)
    {
        _S215 = true;
    }
    else
    {
        _S215 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S216 : f32;
    if(_S215)
    {
        _S216 = 1.0f;
    }
    else
    {
        _S216 = -1.0f;
    }
    return _S216;
}

fn geometryDensity( geometry_n_0 : vec3<f32>,  direction_1 : vec3<f32>,  distance_1 : f32) -> f32
{
    return abs(dot(geometry_n_0, direction_1)) / (distance_1 * distance_1);
}

fn footprintThreshold( geometry_density_0 : f32) -> f32
{
    return 0.00251327408477664f / geometry_density_0;
}

fn withinFootprint( open_0 : bool,  prev_rough_0 : bool,  prev_pdf_0 : f32,  geometry_density_1 : f32,  threshold_0 : f32) -> bool
{
    var _S217 : bool;
    if(open_0)
    {
        _S217 = prev_rough_0;
    }
    else
    {
        _S217 = false;
    }
    if(_S217)
    {
        _S217 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S217 = false;
    }
    return _S217;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S218 : bool = pdf_2 > 0.0f;
    var _S219 : bool;
    if(_S218)
    {
        if(diffuse_0)
        {
            _S219 = true;
        }
        else
        {
            _S219 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S219 = false;
    }
    return _S219;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S220 : bool = pdf_3 > 0.0f;
    var _S221 : bool;
    if(_S220)
    {
        if(diffuse_1)
        {
            _S221 = true;
        }
        else
        {
            _S221 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S221 = false;
    }
    return _S221;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S222 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S222.x, max(_S222.y, _S222.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S223 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S223;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S224 : f32 = c_1 * p_c_0;
    var _S225 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S224 / (_S224 + c_t_0 * g_previous_0), _S225 / (_S225 + c_1 * g_current_0));
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
    var _S226 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S227 : bool = cos_a_0 > cos_b_0;
    var _S228 : f32 = select(_S226, 1.0f, _S227);
    return _S228;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S229 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S230 : bool = cos_a_1 > cos_b_1;
    var _S231 : f32 = select(_S229, 0.0f, _S230);
    return _S231;
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

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S232 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S233 : vec3<f32> = node_0.high - node_0.low;
    var _S234 : vec3<f32> = p_0 - _S232;
    var _S235 : vec3<f32> = (normalize((_S234)));
    var _S236 : f32 = dot(_S234, _S234);
    var _S237 : f32 = dot(_S233, _S233) / 4.0f;
    var _S238 : f32 = abs(dot(node_0.w, _S235));
    var _S239 : f32 = sine(node_0.cos_theta_o);
    var _S240 : f32 = sqrt(max(1.0f - _S237 / _S236, 0.0f));
    var _S241 : bool = _S236 < _S237;
    var _S242 : f32 = select(_S240, -1.0f, _S241);
    var _S243 : f32 = sine(_S242);
    var _S244 : f32 = sine(_S238);
    var _S245 : f32 = cosSubClamped(_S244, _S238, _S239, node_0.cos_theta_o);
    var _S246 : f32 = sine(_S238);
    var _S247 : f32 = sinSubClamped(_S246, _S238, _S239, node_0.cos_theta_o);
    var _S248 : f32 = cosSubClamped(_S247, _S245, _S243, _S242);
    var _S249 : bool = _S248 <= 0.0f;
    if(_S249)
    {
        return 0.0f;
    }
    var _S250 : f32 = - dot(_S235, normal_0);
    var _S251 : f32 = node_0.phi * _S248 / max(_S236, length(_S233) / 2.0f);
    var _S252 : f32 = sine(_S250);
    var _S253 : f32 = cosSubClamped(_S252, _S250, _S243, _S242);
    var _S254 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S255 : f32 = select(_S253, 1.0f, _S254);
    return max(_S251 * _S255, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_1, toward_0));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S256 : f32 = importance(first_0, p_1, normal_2);
    var _S257 : f32 = importance(second_0, p_1, normal_2);
    var _S258 : vec2<f32> = vec2<f32>(_S256, _S257);
    var _S259 : bool = _S256 == 0.0f;
    var _S260 : bool;
    if(_S259)
    {
        _S260 = _S257 == 0.0f;
    }
    else
    {
        _S260 = false;
    }
    if(_S260)
    {
        return u32(2);
    }
    var _S261 : f32 = _S256 + _S257;
    var _S262 : bool = _S257 > 0.0f;
    if(_S262)
    {
        _S260 = ((*pick_0) * _S261) >= _S256;
    }
    else
    {
        _S260 = false;
    }
    var _S263 : u32 = select(u32(0), u32(1), _S260);
    var _S264 : f32 = min(((*pick_0) * _S261 - f32(_S263) * _S256) / _S258[_S263], 0.99999994039535522f);
    (*pick_0) = _S264;
    var _S265 : f32 = (*probability_1) * (_S258[_S263] / _S261);
    (*probability_1) = _S265;
    return _S263;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S266 : f32 = importance(first_1, p_2, normal_3);
    var _S267 : f32 = importance(second_1, p_2, normal_3);
    var _S268 : vec2<f32> = vec2<f32>(_S266, _S267);
    var _S269 : f32 = _S268[child_0] / (_S266 + _S267);
    var _S270 : bool = (_S268[child_0]) > 0.0f;
    var _S271 : f32 = select(0.0f, _S269, _S270);
    return _S271;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S272 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S273 : bool = b_1 > 0.0f;
    var _S274 : f32 = select(1.0f, _S272, _S273);
    return _S274;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S275 : vec3<f32> = center_0 - p_3;
    var _S276 : f32 = radius_1 * radius_1 / dot(_S275, _S275);
    var _S277 : bool = _S276 >= 1.0f;
    if(_S277)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S276)) / (6.28318548202514648f * _S276);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S278 : vec3<f32> = center_1 - p_4;
    var _S279 : f32 = radius_2 * radius_2 / dot(_S278, _S278);
    var _S280 : f32 = u1_0 * _S279 / (1.0f + sqrt(max(1.0f - _S279, 0.0f)));
    var _S281 : f32 = 2.0f * u1_0;
    var _S282 : bool = _S279 >= 1.0f;
    var _S283 : f32 = select(_S280, _S281, _S282);
    var _S284 : f32 = sqrt(max(_S283 * (2.0f - _S283), 0.0f));
    var _S285 : f32 = 6.28318548202514648f * u2_0;
    var _S286 : vec3<f32> = vec3<f32>(_S284 * cos(_S285), 1.0f - _S283, _S284 * sin(_S285));
    var _S287 : vec3<f32> = (normalize((_S278)));
    var _S288 : vec3<f32> = tangentToWorld(_S286, _S287);
    return _S288;
}

