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
    var _S21 : f32 = n_dot_h_0 * n_dot_h_0 * (_S20 - 1.0f) + 1.0f;
    return _S20 / max(3.14159274101257324f * _S21 * _S21, 0.0000152587890625f);
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

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S182 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S182));
}

fn neeDecision( material_5 : Material,  n_dot_v_0 : f32,  eta_i_6 : f32,  eta_o_6 : f32) -> bool
{
    var _S183 : f32 = fresnel(abs(n_dot_v_0), eta_i_6, eta_o_6);
    var _S184 : vec3<f32> = (mix((vec3<f32>(_S183)), (material_5.albedo), (material_5.metallic)));
    var _S185 : f32 = rgb_to_greyscale(_S184);
    var _S186 : f32 = max((1.0f - _S185) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission), 0.0f);
    var _S187 : bool = _S186 > 0.03999999910593033f;
    var _S188 : bool;
    if(_S187)
    {
        _S188 = true;
    }
    else
    {
        _S188 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S188;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S189 : u32 = hash(index_0);
    var _S190 : u32 = hash((seed_0 ^ (_S189)));
    return _S190;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S191 : vec3<f32> = a_4 / b_0;
    var _S192 : vec3<f32> = vec3<f32>(0.0f);
    var _S193 : vec3<bool> = b_0 == _S192;
    var _S194 : vec3<f32> = select(_S191, _S192, _S193);
    return _S194;
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
    var _S195 : f32 = rgb_to_greyscale(weight_0);
    var _S196 : bool = _S195 > 0.0f;
    var _S197 : bool;
    if(_S196)
    {
        _S197 = _S195 < 3.00000000549775576e+38f;
    }
    else
    {
        _S197 = false;
    }
    var _S198 : bool = !_S197;
    if(_S198)
    {
        return;
    }
    var _S199 : f32 = (*sel_0).w_sum + _S195;
    (*sel_0).w_sum = _S199;
    var _S200 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S200;
    var _S201 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S201.state;
    var _S202 : bool = (_S201.value * (*sel_0).w_sum) <= _S195;
    if(_S202)
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
    var _S203 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S203;
    var _S204 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S204;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S205 : f32 = rgb_to_greyscale(r_1.f);
    var _S206 : f32 = sel_2.w_sum / _S205;
    var _S207 : bool = _S205 > 0.0f;
    var _S208 : f32 = select(0.0f, _S206, _S207);
    r_1.w = _S208;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_0 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S209 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S210 : u32 = (insertBits((_S209), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S210;
    candidate_2.f = f_0;
    return candidate_2;
}

