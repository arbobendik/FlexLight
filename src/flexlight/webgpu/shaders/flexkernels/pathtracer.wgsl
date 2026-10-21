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

fn G1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S22 : f32 = alpha_1 * 0.5f;
    return n_dot_x_0 / max(n_dot_x_0 * (1.0f - _S22) + _S22, 0.0000152587890625f);
}

fn smithG1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S23 : f32 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + sqrt(_S23 + (1.0f - _S23) * n_dot_x_1 * n_dot_x_1));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S24 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S25 : f32 = eta_i_0 / eta_o_0 * _S24;
    var _S26 : bool = _S25 < 1.0f;
    var kr_0 : f32;
    if(_S26)
    {
        var _S27 : f32 = sqrt(max(0.0f, 1.0f - _S25 * _S25));
        var _S28 : f32 = eta_o_0 * cos_theta_0;
        var _S29 : f32 = eta_i_0 * _S27;
        var _S30 : f32 = (_S28 - _S29) / (_S28 + _S29);
        var _S31 : f32 = eta_i_0 * cos_theta_0;
        var _S32 : f32 = eta_o_0 * _S27;
        var _S33 : f32 = (_S31 - _S32) / (_S31 + _S32);
        var _S34 : f32 = (_S30 * _S30 + _S33 * _S33) / 2.0f;
        kr_0 = _S34;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S35 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S36 : f32 = _S35.x;
    var _S37 : f32 = _S35.y;
    var _S38 : f32 = _S36 * _S36 + _S37 * _S37;
    const _S39 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S40 : vec3<f32> = vec3<f32>(- _S37, _S36, 0.0f);
    var _S41 : f32 = (inverseSqrt((_S38)));
    var _S42 : vec3<f32> = _S40 * vec3<f32>(_S41);
    var _S43 : bool = _S38 > 0.0f;
    var _S44 : vec3<f32> = select(_S39, _S42, _S43);
    var _S45 : vec3<f32> = cross(_S35, _S44);
    var _S46 : f32 = sqrt(U1_0);
    var _S47 : f32 = 6.28318548202514648f * U2_0;
    var _S48 : f32 = _S46 * cos(_S47);
    var t2_0 : f32 = _S46 * sin(_S47);
    var _S49 : f32 = 0.5f * (1.0f + _S35.z);
    var t2_1 : f32 = (1.0f - _S49) * sqrt(max(0.0f, 1.0f - _S48 * _S48)) + _S49 * t2_0;
    var _S50 : vec3<f32> = vec3<f32>(_S48) * _S44 + vec3<f32>(t2_1) * _S45;
    var _S51 : f32 = ((_S48));
    var _S52 : f32 = ((_S48));
    var _S53 : vec3<f32> = _S50 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S51 * _S52 - t2_1 * t2_1))) * _S35;
    var _S54 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S53.x, alpha_3 * _S53.y, max(0.0f, _S53.z)))));
    return _S54;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S55 : f32 = sqrt(random_1_0);
    var _S56 : f32 = 6.28318548202514648f * random_2_0;
    var _S57 : f32 = _S55 * cos(_S56);
    var _S58 : f32 = _S55 * sin(_S56);
    var _S59 : f32 = sqrt(max(0.0f, 1.0f - _S57 * _S57 - _S58 * _S58));
    return vec3<f32>(_S57, _S59, _S58);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S60 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S60)
    {
        const _S61 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S61;
    }
    else
    {
        a_1 = a_0;
    }
    var _S62 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S63 : vec3<f32> = cross(n_0, _S62);
    return vec3<f32>(v_0.x) * _S62 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S63;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S64 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S64)
    {
        const _S65 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S65;
    }
    else
    {
        a_3 = a_2;
    }
    var _S66 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S67 : vec3<f32> = cross(n_1, _S66);
    return vec3<f32>(dot(v_1, _S66), dot(v_1, n_1), dot(v_1, _S67));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S68 : vec3<f32> = p1_0 - p0_0;
    var _S69 : vec3<f32> = p2_0 - p0_0;
    var _S70 : vec2<f32> = uv1_0 - uv0_0;
    var _S71 : vec2<f32> = uv2_0 - uv0_0;
    var _S72 : f32 = _S70.x;
    var _S73 : f32 = _S71.y;
    var _S74 : f32 = _S70.y;
    var _S75 : f32 = _S71.x;
    var _S76 : f32 = _S72 * _S73 - _S74 * _S75;
    var _S77 : f32 = 1.0f / _S76;
    var _S78 : vec3<f32> = vec3<f32>(_S77);
    var t_0 : vec3<f32> = (_S68 * vec3<f32>(_S73) - _S69 * vec3<f32>(_S74)) * _S78;
    var _S79 : vec3<f32> = (_S69 * vec3<f32>(_S72) - _S68 * vec3<f32>(_S75)) * _S78;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S80 : bool = (dot(cross(n_2, t_1), _S79)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S80)
    {
        var _S81 : vec3<f32> = ((-(t_1)));
        t_2 = _S81;
    }
    else
    {
        t_2 = t_1;
    }
    var _S82 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S82, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S83 : Random = pcg((*random_state_0));
    var _S84 : Random = pcg(_S83.state);
    (*random_state_0) = _S84.state;
    var _S85 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S86 : vec3<f32> = sampleGGXVNDF(_S85.xzy, alpha_4, _S83.value, _S84.value);
    var _S87 : vec3<f32> = _S86.xzy;
    var _S88 : vec3<f32> = tangentToWorld(_S87, n_i_0);
    return _S88;
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
    var _S89 : BSDFLobes;
    _S89.v_dot_h = v_dot_h_0;
    _S89.n_dot_h = n_dot_h_1;
    _S89.refracted = refracted_0;
    _S89.F = F_0;
    _S89.F_greyscale = F_greyscale_0;
    _S89.reflect_weight = reflect_weight_0;
    _S89.diffuse_weight = diffuse_weight_0;
    _S89.refract_weight = refract_weight_0;
    _S89.p_diffuse = p_diffuse_0;
    _S89.p_reflect = p_reflect_0;
    _S89.p_refract = p_refract_0;
    return _S89;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S90 : f32 = dot(ggx_n_0, v_4);
    var _S91 : f32 = dot(n_i_1, ggx_n_0);
    var _S92 : f32 = eta_i_1 / eta_o_1;
    var _S93 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S92))));
    var _S94 : f32 = fresnel(abs(_S90), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S94)), (material_0.albedo), (material_0.metallic)));
    var _S95 : f32 = rgb_to_greyscale(F_1);
    var _S96 : f32 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    var _S97 : f32 = max(_S95, 0.0f);
    var _S98 : f32 = 1.0f - _S95;
    var _S99 : f32 = max(_S96 * _S98, 0.0f);
    var _S100 : f32 = material_0.transmission * _S98;
    var _S101 : f32 = (sign((length(_S93))));
    var _S102 : f32 = max(_S100 * _S101, 0.0f);
    var _S103 : f32 = _S97 + _S99 + _S102;
    var _S104 : f32 = 1.0f / max(_S103, 0.0000152587890625f);
    var _S105 : f32 = _S99 * _S104;
    var _S106 : f32 = _S97 * _S104;
    var _S107 : f32 = _S102 * _S104;
    return BSDFLobes_x24init_0(_S90, _S91, _S93, F_1, _S95, 1.0f, _S96, material_0.transmission, _S105, _S106, _S107);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S108 : bool = lobe_0 == u32(0);
    if(_S108)
    {
        var _S109 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S110 : bool = n_i_dot_v_0 > 0.0f;
        var _S111 : f32 = select(0.0f, _S109, _S110);
        return _S111;
    }
    var _S112 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S113 : f32 = _S112 * lobes_0.v_dot_h;
    var _S114 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S115 : f32 = _S113 * _S114 / n_i_dot_v_0;
    var _S116 : bool = alpha_5 > 0.0f;
    var _S117 : bool;
    if(_S116)
    {
        _S117 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S117 = false;
    }
    if(_S117)
    {
        _S117 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S117 = false;
    }
    if(_S117)
    {
        _S117 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S117 = false;
    }
    var _S118 : f32 = select(0.0f, _S115, _S117);
    var _S119 : bool = lobe_0 == u32(1);
    if(_S119)
    {
        var _S120 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S121 : f32 = lobes_0.p_refract * _S118 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S120 * _S120);
        var _S122 : bool = eta_i_2 != eta_o_2;
        if(_S122)
        {
            _S117 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S117 = false;
        }
        var _S123 : f32 = select(0.0f, _S121, _S117);
        return _S123;
    }
    var _S124 : f32 = lobes_0.p_reflect * _S118 / (4.0f * lobes_0.v_dot_h);
    var _S125 : bool = _S118 > 0.0f;
    var _S126 : f32 = select(0.0f, _S124, _S125);
    return _S126;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S127 : bool = lobe_1 == u32(0);
    if(_S127)
    {
        return vec3<f32>(lobes_1.diffuse_weight) * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S128 : bool = lobe_1 == u32(1);
    if(_S128)
    {
        var _S129 : f32 = - dot(n_i_2, l_0);
        var _S130 : f32 = G1(alpha_6, max(_S129, 0.0f));
        return vec3<f32>((lobes_1.refract_weight * _S130 * (1.0f - lobes_1.F_greyscale))) * material_1.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S131 : f32 = dot(n_i_2, l_0);
    var _S132 : f32 = G1(alpha_6, max(_S131, 0.0f));
    return vec3<f32>((lobes_1.reflect_weight * _S132)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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
    var _S133 : SampleBSDF;
    _S133.unit_direction = unit_direction_0;
    _S133.throughput = throughput_0;
    _S133.random_state = random_state_1;
    _S133.refracted = refracted_1;
    _S133.lobe = lobe_2;
    _S133.pdf = pdf_0;
    return _S133;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S134 : vec3<f32> = ((-(in_dir_1)));
    var _S135 : f32 = dot(n_3, _S134);
    var _S136 : f32 = (sign((_S135)));
    var _S137 : vec3<f32> = n_3 * vec3<f32>(_S136);
    var _S138 : f32 = material_2.roughness;
    var _S139 : f32 = _S138 * _S138;
    var _S140 : vec3<f32> = (normalize((_S134 + out_dir_0)));
    var _S141 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S141)
    {
        var _S142 : vec3<f32> = sampleHalfVector(_S134, _S137, _S139, &(random_state_2));
        ggx_n_1 = _S142;
    }
    else
    {
        var _S143 : bool = lobe_3 == u32(1);
        if(_S143)
        {
            var _S144 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S134 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S145 : vec3<f32> = (normalize((_S144)));
            var _S146 : f32 = (sign((dot(_S144, _S137))));
            var _S147 : vec3<f32> = _S145 * vec3<f32>(_S146);
            ggx_n_1 = _S147;
        }
        else
        {
            ggx_n_1 = _S140;
        }
    }
    var _S148 : BSDFLobes = bsdfLobes(in_dir_1, _S134, _S137, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S149 : f32 = lobeDensity(dot(_S137, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S135), _S139, _S148, eta_i_3, eta_o_3, lobe_3);
    var _S150 : bool = !(_S149 > 0.0f);
    if(_S150)
    {
        var _S151 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S151, _S151, u32(0), false, u32(0), 0.0f);
    }
    var _S152 : vec3<f32> = lobeThroughput(out_dir_0, _S137, _S139, material_2, _S148, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S152, random_state_2, lobe_3 == u32(1), lobe_3, _S149);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S153 : vec3<f32> = ((-(in_dir_2)));
    var _S154 : bool = (dot(g_n_0, _S153) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S154)
    {
        var _S155 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S156 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S155.throughput * vec3<f32>(_S155.pdf) + _S156.throughput * vec3<f32>(_S156.pdf);
    }
    var _S157 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S157.throughput * vec3<f32>(_S157.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S158 : vec3<f32> = ((-(in_dir_3)));
    var _S159 : f32 = dot(n_5, _S158);
    var _S160 : f32 = (sign((_S159)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S160);
    var _S161 : f32 = abs(_S159);
    var _S162 : f32 = material_4.roughness;
    var _S163 : f32 = _S162 * _S162;
    var _S164 : vec3<f32> = sampleHalfVector(_S158, n_i_3, _S163, &(random_state_4));
    var _S165 : BSDFLobes = bsdfLobes(in_dir_3, _S158, n_i_3, _S164, material_4, eta_i_5, eta_o_5);
    var _S166 : vec3<f32> = vec3<f32>(1.0f);
    var _S167 : SampleBSDF = SampleBSDF_x24init_0(_S166, _S166, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S167;
    var _S168 : Random = pcg(random_state_4);
    random_state_4 = _S168.state;
    var _S169 : bool = (_S168.value) < (_S165.p_diffuse);
    if(_S169)
    {
        var _S170 : Random = pcg(random_state_4);
        var _S171 : Random = pcg(_S170.state);
        sample_0.random_state = _S171.state;
        var _S172 : vec3<f32> = sampleCosWeightedHemisphere(_S170.value, _S171.value);
        var _S173 : vec3<f32> = tangentToWorld(_S172, n_i_3);
        sample_0.unit_direction = _S173;
        var _S174 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S163, material_4, _S165, u32(0));
        sample_0.throughput = _S174;
        var _S175 : f32 = lobeDensity(_S172.y, 0.0f, _S161, _S163, _S165, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S175;
        return sample_0;
    }
    var _S176 : bool = (_S168.value) < (_S165.p_diffuse + _S165.p_refract);
    if(_S176)
    {
        sample_0.unit_direction = _S165.refracted;
        var _S177 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S164), _S161, _S163, _S165, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S177;
        var _S178 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S163, material_4, _S165, u32(1));
        sample_0.throughput = _S178;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S179 : vec3<f32> = (normalize((reflect(in_dir_3, _S164))));
    sample_0.unit_direction = _S179;
    var _S180 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S163, material_4, _S165, u32(2));
    sample_0.throughput = _S180;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S181 : f32 = lobeDensity(0.0f, 0.0f, _S161, _S163, _S165, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S181;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S182 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S182));
}

fn samplesLights( material_5 : Material) -> bool
{
    var _S183 : bool = (material_5.roughness) > 0.0f;
    var _S184 : bool;
    if(_S183)
    {
        _S184 = true;
    }
    else
    {
        var _S185 : bool = (material_5.metallic) < 1.0f;
        if(_S185)
        {
            _S184 = (material_5.transmission) < 1.0f;
        }
        else
        {
            _S184 = false;
        }
    }
    return _S184;
}

fn neeBSDF( in_dir_4 : vec3<f32>,  dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_5 : u32) -> vec3<f32>
{
    var _S186 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S186;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S187 : bool = (lobe_4 == u32(1)) == refracted_2;
        var f_1 : vec3<f32>;
        if(_S187)
        {
            var _S188 : SampleBSDF = connectBSDF(in_dir_4, dir_0, n_6, material_6, eta_i_6, eta_o_6, lobe_4, random_state_5);
            var _S189 : bool = (_S188.pdf) > 0.0f;
            if(_S189)
            {
                if(power_0)
                {
                    var _S190 : f32 = _S188.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S188.throughput * vec3<f32>(_S188.pdf) / vec3<f32>((pdf_1 * (1.0f + _S190 * _S190)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S188.throughput * vec3<f32>(_S188.pdf) / vec3<f32>((_S188.pdf + pdf_1));
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
    var _S191 : f32 = rgb_to_greyscale(material_7.albedo * vec3<f32>(material_7.metallic));
    var _S192 : f32 = material_7.roughness;
    var _S193 : f32 = G1(_S192 * _S192, abs(dot(n_7, dir_1)));
    return vec3<f32>((material_7.transmission * _S193 * (1.0f - _S191))) * material_7.albedo;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S194 : u32 = hash(index_0);
    var _S195 : u32 = hash((seed_0 ^ (_S194)));
    return _S195;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S196 : vec3<f32> = a_4 / b_0;
    var _S197 : vec3<f32> = vec3<f32>(0.0f);
    var _S198 : vec3<bool> = b_0 == _S197;
    var _S199 : vec3<f32> = select(_S196, _S197, _S198);
    return _S199;
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
    var _S200 : f32 = rgb_to_greyscale(weight_0);
    var _S201 : bool = _S200 > 0.0f;
    var _S202 : bool;
    if(_S201)
    {
        _S202 = _S200 < 3.00000000549775576e+38f;
    }
    else
    {
        _S202 = false;
    }
    var _S203 : bool = !_S202;
    if(_S203)
    {
        return;
    }
    var _S204 : f32 = (*sel_0).w_sum + _S200;
    (*sel_0).w_sum = _S204;
    var _S205 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S205;
    var _S206 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S206.state;
    var _S207 : bool = (_S206.value * (*sel_0).w_sum) <= _S200;
    if(_S207)
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
    var _S208 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S208;
    var _S209 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S209;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S210 : f32 = rgb_to_greyscale(r_1.f);
    var _S211 : f32 = sel_2.w_sum / _S210;
    var _S212 : bool = _S210 > 0.0f;
    var _S213 : f32 = select(0.0f, _S211, _S212);
    r_1.w = _S213;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S214 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S215 : u32 = (insertBits((_S214), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S215;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S216 : bool = transmission_0 > 0.0f;
    var _S217 : bool;
    if(_S216)
    {
        _S217 = true;
    }
    else
    {
        _S217 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S218 : f32;
    if(_S217)
    {
        _S218 = 1.0f;
    }
    else
    {
        _S218 = -1.0f;
    }
    return _S218;
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
    var _S219 : bool;
    if(open_0)
    {
        _S219 = prev_rough_0;
    }
    else
    {
        _S219 = false;
    }
    if(_S219)
    {
        _S219 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S219 = false;
    }
    return _S219;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S220 : bool = pdf_2 > 0.0f;
    var _S221 : bool;
    if(_S220)
    {
        if(diffuse_0)
        {
            _S221 = true;
        }
        else
        {
            _S221 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S221 = false;
    }
    return _S221;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S222 : bool = pdf_3 > 0.0f;
    var _S223 : bool;
    if(_S222)
    {
        if(diffuse_1)
        {
            _S223 = true;
        }
        else
        {
            _S223 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S223 = false;
    }
    return _S223;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S224 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S224.x, max(_S224.y, _S224.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S225 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S225;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S226 : f32 = c_1 * p_c_0;
    var _S227 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S226 / (_S226 + c_t_0 * g_previous_0), _S227 / (_S227 + c_1 * g_current_0));
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
    var _S228 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S229 : bool = cos_a_0 > cos_b_0;
    var _S230 : f32 = select(_S228, 1.0f, _S229);
    return _S230;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S231 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S232 : bool = cos_a_1 > cos_b_1;
    var _S233 : f32 = select(_S231, 0.0f, _S232);
    return _S233;
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
    var _S234 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S235 : vec3<f32> = node_0.high - node_0.low;
    var _S236 : vec3<f32> = p_0 - _S234;
    var _S237 : vec3<f32> = (normalize((_S236)));
    var _S238 : f32 = dot(_S236, _S236);
    var _S239 : f32 = dot(_S235, _S235) / 4.0f;
    var _S240 : f32 = abs(dot(node_0.w, _S237));
    var _S241 : f32 = sine(node_0.cos_theta_o);
    var _S242 : f32 = sqrt(max(1.0f - _S239 / _S238, 0.0f));
    var _S243 : bool = _S238 < _S239;
    var _S244 : f32 = select(_S242, -1.0f, _S243);
    var _S245 : f32 = sine(_S244);
    var _S246 : f32 = sine(_S240);
    var _S247 : f32 = cosSubClamped(_S246, _S240, _S241, node_0.cos_theta_o);
    var _S248 : f32 = sine(_S240);
    var _S249 : f32 = sinSubClamped(_S248, _S240, _S241, node_0.cos_theta_o);
    var _S250 : f32 = cosSubClamped(_S249, _S247, _S245, _S244);
    var _S251 : bool = _S250 <= 0.0f;
    if(_S251)
    {
        return 0.0f;
    }
    var _S252 : f32 = - dot(_S237, normal_1);
    var _S253 : f32 = node_0.phi * _S250 / max(_S238, length(_S235) / 2.0f);
    var _S254 : f32 = sine(_S252);
    var _S255 : f32 = cosSubClamped(_S254, _S252, _S245, _S244);
    var _S256 : bool = (dot(normal_1, normal_1)) == 0.0f;
    var _S257 : f32 = select(_S255, 1.0f, _S256);
    return max(_S253 * _S257, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S258 : f32 = importance(first_0, p_1, normal_3);
    var _S259 : f32 = importance(second_0, p_1, normal_3);
    var _S260 : vec2<f32> = vec2<f32>(_S258, _S259);
    var _S261 : bool = _S258 == 0.0f;
    var _S262 : bool;
    if(_S261)
    {
        _S262 = _S259 == 0.0f;
    }
    else
    {
        _S262 = false;
    }
    if(_S262)
    {
        return u32(2);
    }
    var _S263 : f32 = _S258 + _S259;
    var _S264 : bool = _S259 > 0.0f;
    if(_S264)
    {
        _S262 = ((*pick_0) * _S263) >= _S258;
    }
    else
    {
        _S262 = false;
    }
    var _S265 : u32 = select(u32(0), u32(1), _S262);
    var _S266 : f32 = min(((*pick_0) * _S263 - f32(_S265) * _S258) / _S260[_S265], 0.99999994039535522f);
    (*pick_0) = _S266;
    var _S267 : f32 = (*probability_1) * (_S260[_S265] / _S263);
    (*probability_1) = _S267;
    return _S265;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_4 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S268 : f32 = importance(first_1, p_2, normal_4);
    var _S269 : f32 = importance(second_1, p_2, normal_4);
    var _S270 : vec2<f32> = vec2<f32>(_S268, _S269);
    var _S271 : f32 = _S270[child_0] / (_S268 + _S269);
    var _S272 : bool = (_S270[child_0]) > 0.0f;
    var _S273 : f32 = select(0.0f, _S271, _S272);
    return _S273;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S274 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S275 : bool = b_1 > 0.0f;
    var _S276 : f32 = select(1.0f, _S274, _S275);
    return _S276;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S277 : vec3<f32> = center_0 - p_3;
    var _S278 : f32 = radius_1 * radius_1 / dot(_S277, _S277);
    var _S279 : bool = _S278 >= 1.0f;
    if(_S279)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S278)) / (6.28318548202514648f * _S278);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S280 : vec3<f32> = center_1 - p_4;
    var _S281 : f32 = radius_2 * radius_2 / dot(_S280, _S280);
    var _S282 : f32 = u1_0 * _S281 / (1.0f + sqrt(max(1.0f - _S281, 0.0f)));
    var _S283 : f32 = 2.0f * u1_0;
    var _S284 : bool = _S281 >= 1.0f;
    var _S285 : f32 = select(_S282, _S283, _S284);
    var _S286 : f32 = sqrt(max(_S285 * (2.0f - _S285), 0.0f));
    var _S287 : f32 = 6.28318548202514648f * u2_0;
    var _S288 : vec3<f32> = vec3<f32>(_S286 * cos(_S287), 1.0f - _S285, _S286 * sin(_S287));
    var _S289 : vec3<f32> = (normalize((_S280)));
    var _S290 : vec3<f32> = tangentToWorld(_S288, _S289);
    return _S290;
}

