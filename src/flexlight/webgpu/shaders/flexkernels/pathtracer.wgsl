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
        var _S25 : f32 = eta_o_0 * cos_theta_0;
        var _S26 : f32 = eta_i_0 * _S24;
        var _S27 : f32 = (_S25 - _S26) / (_S25 + _S26);
        var _S28 : f32 = eta_i_0 * cos_theta_0;
        var _S29 : f32 = eta_o_0 * _S24;
        var _S30 : f32 = (_S28 - _S29) / (_S28 + _S29);
        var _S31 : f32 = (_S27 * _S27 + _S30 * _S30) / 2.0f;
        kr_0 = _S31;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S32 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S33 : f32 = _S32.x;
    var _S34 : f32 = _S32.y;
    var _S35 : f32 = _S33 * _S33 + _S34 * _S34;
    const _S36 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S37 : vec3<f32> = vec3<f32>(- _S34, _S33, 0.0f);
    var _S38 : f32 = (inverseSqrt((_S35)));
    var _S39 : vec3<f32> = _S37 * vec3<f32>(_S38);
    var _S40 : bool = _S35 > 0.0f;
    var _S41 : vec3<f32> = select(_S36, _S39, _S40);
    var _S42 : vec3<f32> = cross(_S32, _S41);
    var _S43 : f32 = sqrt(U1_0);
    var _S44 : f32 = 6.28318548202514648f * U2_0;
    var _S45 : f32 = _S43 * cos(_S44);
    var t2_0 : f32 = _S43 * sin(_S44);
    var _S46 : f32 = 0.5f * (1.0f + _S32.z);
    var t2_1 : f32 = (1.0f - _S46) * sqrt(max(0.0f, 1.0f - _S45 * _S45)) + _S46 * t2_0;
    var _S47 : vec3<f32> = vec3<f32>(_S45) * _S41 + vec3<f32>(t2_1) * _S42;
    var _S48 : f32 = ((_S45));
    var _S49 : f32 = ((_S45));
    var _S50 : vec3<f32> = _S47 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S48 * _S49 - t2_1 * t2_1))) * _S32;
    var _S51 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S50.x, alpha_3 * _S50.y, max(0.0f, _S50.z)))));
    return _S51;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S52 : f32 = sqrt(random_1_0);
    var _S53 : f32 = 6.28318548202514648f * random_2_0;
    var _S54 : f32 = _S52 * cos(_S53);
    var _S55 : f32 = _S52 * sin(_S53);
    var _S56 : f32 = sqrt(max(0.0f, 1.0f - _S54 * _S54 - _S55 * _S55));
    return vec3<f32>(_S54, _S56, _S55);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S57 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S57)
    {
        const _S58 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S58;
    }
    else
    {
        a_1 = a_0;
    }
    var _S59 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S60 : vec3<f32> = cross(n_0, _S59);
    return vec3<f32>(v_0.x) * _S59 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S60;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S61 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S61)
    {
        const _S62 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S62;
    }
    else
    {
        a_3 = a_2;
    }
    var _S63 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S64 : vec3<f32> = cross(n_1, _S63);
    return vec3<f32>(dot(v_1, _S63), dot(v_1, n_1), dot(v_1, _S64));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S65 : vec3<f32> = p1_0 - p0_0;
    var _S66 : vec3<f32> = p2_0 - p0_0;
    var _S67 : vec2<f32> = uv1_0 - uv0_0;
    var _S68 : vec2<f32> = uv2_0 - uv0_0;
    var _S69 : f32 = _S67.x;
    var _S70 : f32 = _S68.y;
    var _S71 : f32 = _S67.y;
    var _S72 : f32 = _S68.x;
    var _S73 : f32 = _S69 * _S70 - _S71 * _S72;
    var _S74 : f32 = 1.0f / _S73;
    var _S75 : vec3<f32> = vec3<f32>(_S74);
    var t_0 : vec3<f32> = (_S65 * vec3<f32>(_S70) - _S66 * vec3<f32>(_S71)) * _S75;
    var _S76 : vec3<f32> = (_S66 * vec3<f32>(_S69) - _S65 * vec3<f32>(_S72)) * _S75;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S77 : bool = (dot(cross(n_2, t_1), _S76)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S77)
    {
        var _S78 : vec3<f32> = ((-(t_1)));
        t_2 = _S78;
    }
    else
    {
        t_2 = t_1;
    }
    var _S79 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S79, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S80 : Random = pcg((*random_state_0));
    var _S81 : Random = pcg(_S80.state);
    (*random_state_0) = _S81.state;
    var _S82 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S83 : vec3<f32> = sampleGGXVNDF(_S82.xzy, alpha_4, _S80.value, _S81.value);
    var _S84 : vec3<f32> = _S83.xzy;
    var _S85 : vec3<f32> = tangentToWorld(_S84, n_i_0);
    return _S85;
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
    var _S86 : BSDFLobes;
    _S86.v_dot_h = v_dot_h_0;
    _S86.n_dot_h = n_dot_h_1;
    _S86.refracted = refracted_0;
    _S86.F = F_0;
    _S86.F_greyscale = F_greyscale_0;
    _S86.reflect_weight = reflect_weight_0;
    _S86.diffuse_weight = diffuse_weight_0;
    _S86.refract_weight = refract_weight_0;
    _S86.colorless_reflection = colorless_reflection_0;
    _S86.p_diffuse = p_diffuse_0;
    _S86.p_reflect = p_reflect_0;
    _S86.p_refract = p_refract_0;
    return _S86;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S87 : f32 = dot(ggx_n_0, v_4);
    var _S88 : f32 = dot(n_i_1, ggx_n_0);
    var _S89 : f32 = eta_i_1 / eta_o_1;
    var _S90 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S89))));
    var _S91 : f32 = fresnel(abs(_S87), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S91)), (material_0.albedo), (material_0.metallic)));
    var _S92 : f32 = rgb_to_greyscale(F_1);
    var _S93 : f32 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    var _S94 : f32 = max(_S92, 0.0f);
    var _S95 : f32 = 1.0f - _S92;
    var _S96 : f32 = max(_S93 * _S95, 0.0f);
    var _S97 : f32 = material_0.transmission * _S95;
    var _S98 : f32 = (sign((length(_S90))));
    var _S99 : f32 = max(_S97 * _S98, 0.0f);
    var _S100 : f32 = _S94 + _S96 + _S99;
    var _S101 : f32 = 1.0f / max(_S100, 0.0000152587890625f);
    var _S102 : f32 = _S96 * _S101;
    var _S103 : f32 = _S94 * _S101;
    var _S104 : f32 = _S99 * _S101;
    return BSDFLobes_x24init_0(_S87, _S88, _S90, F_1, _S92, 1.0f, _S93, material_0.transmission, material_0.transmission, _S102, _S103, _S104);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S105 : bool = lobe_0 == u32(0);
    if(_S105)
    {
        var _S106 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S107 : bool = n_i_dot_v_0 > 0.0f;
        var _S108 : f32 = select(0.0f, _S106, _S107);
        return _S108;
    }
    var _S109 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S110 : f32 = _S109 * lobes_0.v_dot_h;
    var _S111 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S112 : f32 = _S110 * _S111 / n_i_dot_v_0;
    var _S113 : bool = alpha_5 > 0.0f;
    var _S114 : bool;
    if(_S113)
    {
        _S114 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S114 = false;
    }
    if(_S114)
    {
        _S114 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S114 = false;
    }
    if(_S114)
    {
        _S114 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S114 = false;
    }
    var _S115 : f32 = select(0.0f, _S112, _S114);
    var _S116 : bool = lobe_0 == u32(1);
    if(_S116)
    {
        var _S117 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S118 : f32 = lobes_0.p_refract * _S115 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S117 * _S117);
        var _S119 : bool = eta_i_2 != eta_o_2;
        if(_S119)
        {
            _S114 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S114 = false;
        }
        var _S120 : f32 = select(0.0f, _S118, _S114);
        return _S120;
    }
    var _S121 : f32 = lobes_0.p_reflect * _S115 / (4.0f * lobes_0.v_dot_h);
    var _S122 : bool = _S115 > 0.0f;
    var _S123 : f32 = select(0.0f, _S121, _S122);
    return _S123;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S124 : bool = lobe_1 == u32(0);
    if(_S124)
    {
        return vec3<f32>(lobes_1.diffuse_weight) * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S125 : bool = lobe_1 == u32(1);
    if(_S125)
    {
        var _S126 : f32 = - dot(n_i_2, l_0);
        var _S127 : f32 = G1(alpha_6, max(_S126, 0.0f));
        return vec3<f32>((lobes_1.refract_weight * _S127 * (1.0f - lobes_1.F_greyscale) / lobes_1.p_refract));
    }
    var _S128 : f32 = dot(n_i_2, l_0);
    var _S129 : f32 = G1(alpha_6, max(_S128, 0.0f));
    var _S130 : f32 = lobes_1.reflect_weight * _S129;
    var _S131 : vec3<f32> = (mix((lobes_1.F), (vec3<f32>(lobes_1.F_greyscale)), (lobes_1.colorless_reflection)));
    return vec3<f32>(_S130) * _S131 / vec3<f32>(lobes_1.p_reflect);
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
    var _S132 : SampleBSDF;
    _S132.unit_direction = unit_direction_0;
    _S132.throughput = throughput_0;
    _S132.random_state = random_state_1;
    _S132.refracted = refracted_1;
    _S132.lobe = lobe_2;
    _S132.pdf = pdf_0;
    return _S132;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S133 : vec3<f32> = ((-(in_dir_1)));
    var _S134 : f32 = dot(n_3, _S133);
    var _S135 : f32 = (sign((_S134)));
    var _S136 : vec3<f32> = n_3 * vec3<f32>(_S135);
    var _S137 : f32 = material_2.roughness;
    var _S138 : f32 = _S137 * _S137;
    var _S139 : vec3<f32> = _S133 + out_dir_0;
    var _S140 : vec3<f32> = (normalize((_S139)));
    var _S141 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S141)
    {
        var _S142 : vec3<f32> = sampleHalfVector(_S133, _S136, _S138, &(random_state_2));
        ggx_n_1 = _S142;
    }
    else
    {
        ggx_n_1 = _S140;
    }
    var _S143 : bool = lobe_3 == u32(1);
    if(_S143)
    {
        var _S144 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S133 + vec3<f32>(eta_o_3) * out_dir_0)));
        var _S145 : vec3<f32> = (normalize((_S144)));
        var _S146 : f32 = (sign((dot(_S144, _S136))));
        var _S147 : vec3<f32> = _S145 * vec3<f32>(_S146);
        ggx_n_1 = _S147;
    }
    var _S148 : bool = lobe_3 == u32(2);
    if(_S148)
    {
        var _S149 : vec3<f32> = (normalize((_S139)));
        ggx_n_1 = _S149;
    }
    var _S150 : BSDFLobes = bsdfLobes(in_dir_1, _S133, _S136, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S151 : f32 = lobeDensity(dot(_S136, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S134), _S138, _S150, eta_i_3, eta_o_3, lobe_3);
    var _S152 : bool = !(_S151 > 0.0f);
    if(_S152)
    {
        var _S153 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S153, _S153, u32(0), false, u32(0), 0.0f);
    }
    var _S154 : vec3<f32> = lobeThroughput(out_dir_0, _S136, _S138, material_2, _S150, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S154, random_state_2, _S143, lobe_3, _S151);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S155 : vec3<f32> = ((-(in_dir_2)));
    var _S156 : bool = (dot(g_n_0, _S155) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S156)
    {
        var _S157 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S158 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S157.throughput * vec3<f32>(_S157.pdf) + _S158.throughput * vec3<f32>(_S158.pdf);
    }
    var _S159 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S159.throughput * vec3<f32>(_S159.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S160 : vec3<f32> = ((-(in_dir_3)));
    var _S161 : f32 = dot(n_5, _S160);
    var _S162 : f32 = (sign((_S161)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S162);
    var _S163 : f32 = abs(_S161);
    var _S164 : f32 = material_4.roughness;
    var _S165 : f32 = _S164 * _S164;
    var _S166 : vec3<f32> = sampleHalfVector(_S160, n_i_3, _S165, &(random_state_4));
    var _S167 : BSDFLobes = bsdfLobes(in_dir_3, _S160, n_i_3, _S166, material_4, eta_i_5, eta_o_5);
    var _S168 : vec3<f32> = vec3<f32>(1.0f);
    var _S169 : SampleBSDF = SampleBSDF_x24init_0(_S168, _S168, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S169;
    var _S170 : Random = pcg(random_state_4);
    random_state_4 = _S170.state;
    var _S171 : bool = (_S170.value) < (_S167.p_diffuse);
    if(_S171)
    {
        var _S172 : Random = pcg(random_state_4);
        var _S173 : Random = pcg(_S172.state);
        sample_0.random_state = _S173.state;
        var _S174 : vec3<f32> = sampleCosWeightedHemisphere(_S172.value, _S173.value);
        var _S175 : vec3<f32> = tangentToWorld(_S174, n_i_3);
        sample_0.unit_direction = _S175;
        var _S176 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S165, material_4, _S167, u32(0));
        sample_0.throughput = _S176;
        var _S177 : f32 = lobeDensity(_S174.y, 0.0f, _S163, _S165, _S167, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S177;
        return sample_0;
    }
    var _S178 : bool = (_S170.value) < (_S167.p_diffuse + _S167.p_refract);
    if(_S178)
    {
        sample_0.unit_direction = _S167.refracted;
        var _S179 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S166), _S163, _S165, _S167, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S179;
        var _S180 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S165, material_4, _S167, u32(1));
        sample_0.throughput = _S180;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S181 : vec3<f32> = (normalize((reflect(in_dir_3, _S166))));
    sample_0.unit_direction = _S181;
    var _S182 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S165, material_4, _S167, u32(2));
    sample_0.throughput = _S182;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S183 : f32 = lobeDensity(0.0f, 0.0f, _S163, _S165, _S167, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S183;
    return sample_0;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S184 : vec3<f32> = a_4 / b_0;
    var _S185 : vec3<f32> = vec3<f32>(0.0f);
    var _S186 : vec3<bool> = b_0 == _S185;
    var _S187 : vec3<f32> = select(_S184, _S185, _S186);
    return _S187;
}

