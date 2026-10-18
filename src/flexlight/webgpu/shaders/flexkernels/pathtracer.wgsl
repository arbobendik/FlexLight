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

fn lobeBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S129 : vec3<f32> = ((-(in_dir_1)));
    var _S130 : f32 = dot(n_3, _S129);
    var _S131 : f32 = (sign((_S130)));
    var _S132 : vec3<f32> = n_3 * vec3<f32>(_S131);
    var _S133 : f32 = material_2.roughness;
    var _S134 : f32 = _S133 * _S133;
    var _S135 : vec3<f32> = _S129 + out_dir_0;
    var _S136 : vec3<f32> = (normalize((_S135)));
    var _S137 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S137)
    {
        var _S138 : vec3<f32> = sampleHalfVector(_S129, _S132, _S134, &(random_state_2));
        ggx_n_1 = _S138;
    }
    else
    {
        ggx_n_1 = _S136;
    }
    var _S139 : bool = lobe_3 == u32(1);
    if(_S139)
    {
        var _S140 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S129 + vec3<f32>(eta_o_3) * out_dir_0)));
        var _S141 : vec3<f32> = (normalize((_S140)));
        var _S142 : f32 = (sign((dot(_S140, _S132))));
        var _S143 : vec3<f32> = _S141 * vec3<f32>(_S142);
        ggx_n_1 = _S143;
    }
    var _S144 : bool = lobe_3 == u32(2);
    if(_S144)
    {
        var _S145 : vec3<f32> = (normalize((_S135)));
        ggx_n_1 = _S145;
    }
    var _S146 : BSDFLobes = bsdfLobes(in_dir_1, _S129, _S132, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S147 : f32 = lobeDensity(dot(_S132, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S130), _S134, _S146, eta_i_3, eta_o_3, lobe_3);
    var _S148 : bool = !(_S147 > 0.0f);
    if(_S148)
    {
        var _S149 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S149, _S149, u32(0), false, u32(0), 0.0f);
    }
    var _S150 : vec3<f32> = lobeThroughput(out_dir_0, _S132, _S134, material_2, _S146, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S150, random_state_2, _S139, lobe_3, _S147);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S151 : vec3<f32> = ((-(in_dir_2)));
    var _S152 : bool = (dot(g_n_0, _S151) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S152)
    {
        var _S153 : SampleBSDF = lobeBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S154 : SampleBSDF = lobeBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S153.throughput * vec3<f32>(_S153.pdf) + _S154.throughput * vec3<f32>(_S154.pdf);
    }
    var _S155 : SampleBSDF = lobeBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S155.throughput * vec3<f32>(_S155.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S156 : vec3<f32> = ((-(in_dir_3)));
    var _S157 : f32 = dot(n_5, _S156);
    var _S158 : f32 = (sign((_S157)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S158);
    var _S159 : f32 = abs(_S157);
    var _S160 : f32 = material_4.roughness;
    var _S161 : f32 = _S160 * _S160;
    var _S162 : vec3<f32> = sampleHalfVector(_S156, n_i_3, _S161, &(random_state_4));
    var _S163 : BSDFLobes = bsdfLobes(in_dir_3, _S156, n_i_3, _S162, material_4, eta_i_5, eta_o_5);
    var _S164 : vec3<f32> = vec3<f32>(1.0f);
    var _S165 : SampleBSDF = SampleBSDF_x24init_0(_S164, _S164, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S165;
    var _S166 : Random = pcg(random_state_4);
    random_state_4 = _S166.state;
    var _S167 : bool = (_S166.value) < (_S163.p_diffuse);
    if(_S167)
    {
        var _S168 : Random = pcg(random_state_4);
        var _S169 : Random = pcg(_S168.state);
        sample_0.random_state = _S169.state;
        var _S170 : vec3<f32> = sampleCosWeightedHemisphere(_S168.value, _S169.value);
        var _S171 : vec3<f32> = tangentToWorld(_S170, n_i_3);
        sample_0.unit_direction = _S171;
        var _S172 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S161, material_4, _S163, u32(0));
        sample_0.throughput = _S172;
        var _S173 : f32 = lobeDensity(_S170.y, 0.0f, _S159, _S161, _S163, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S173;
        return sample_0;
    }
    var _S174 : bool = (_S166.value) < (_S163.p_diffuse + _S163.p_refract);
    if(_S174)
    {
        sample_0.unit_direction = _S163.refracted;
        var _S175 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S162), _S159, _S161, _S163, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S175;
        var _S176 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S161, material_4, _S163, u32(1));
        sample_0.throughput = _S176;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S177 : vec3<f32> = (normalize((reflect(in_dir_3, _S162))));
    sample_0.unit_direction = _S177;
    var _S178 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S161, material_4, _S163, u32(2));
    sample_0.throughput = _S178;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S179 : f32 = lobeDensity(0.0f, 0.0f, _S159, _S161, _S163, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S179;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S180 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S180));
}

fn neeDecision( material_5 : Material,  n_dot_v_0 : f32,  eta_i_6 : f32,  eta_o_6 : f32) -> bool
{
    var _S181 : f32 = fresnel(abs(n_dot_v_0), eta_i_6, eta_o_6);
    var _S182 : vec3<f32> = (mix((vec3<f32>(_S181)), (material_5.albedo), (material_5.metallic)));
    var _S183 : f32 = rgb_to_greyscale(_S182);
    var _S184 : f32 = max((1.0f - _S183) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission), 0.0f);
    var _S185 : bool = _S184 > 0.03999999910593033f;
    var _S186 : bool;
    if(_S185)
    {
        _S186 = true;
    }
    else
    {
        _S186 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S186;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S187 : u32 = hash(index_0);
    var _S188 : u32 = hash((seed_0 ^ (_S187)));
    return _S188;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S189 : vec3<f32> = a_4 / b_0;
    var _S190 : vec3<f32> = vec3<f32>(0.0f);
    var _S191 : vec3<bool> = b_0 == _S190;
    var _S192 : vec3<f32> = select(_S189, _S190, _S191);
    return _S192;
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
    var _S193 : f32 = rgb_to_greyscale(weight_0);
    var _S194 : bool = _S193 > 0.0f;
    var _S195 : bool;
    if(_S194)
    {
        _S195 = _S193 < 3.00000000549775576e+38f;
    }
    else
    {
        _S195 = false;
    }
    var _S196 : bool = !_S195;
    if(_S196)
    {
        return;
    }
    var _S197 : f32 = (*sel_0).w_sum + _S193;
    (*sel_0).w_sum = _S197;
    var _S198 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S198;
    var _S199 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S199.state;
    var _S200 : bool = (_S199.value * (*sel_0).w_sum) <= _S193;
    if(_S200)
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
    var _S201 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S201;
    var _S202 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S202;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S203 : f32 = rgb_to_greyscale(r_1.f);
    var _S204 : f32 = sel_2.w_sum / _S203;
    var _S205 : bool = _S203 > 0.0f;
    var _S206 : f32 = select(0.0f, _S204, _S205);
    r_1.w = _S206;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_0 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S207 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S208 : u32 = (insertBits((_S207), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S208;
    candidate_2.f = f_0;
    return candidate_2;
}

