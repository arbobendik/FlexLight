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

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S20 : u32 = hash(index_0);
    var _S21 : u32 = hash((seed_0 ^ (_S20)));
    return _S21;
}

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S22 : f32 = alpha_0 * alpha_0;
    var _S23 : f32 = n_dot_h_0 * n_dot_h_0 * (_S22 - 1.0f) + 1.0f;
    return _S22 / max(3.14159274101257324f * _S23 * _S23, 0.0000152587890625f);
}

fn G1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S24 : f32 = alpha_1 * 0.5f;
    return n_dot_x_0 / max(n_dot_x_0 * (1.0f - _S24) + _S24, 0.0000152587890625f);
}

fn smithG1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S25 : f32 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + sqrt(_S25 + (1.0f - _S25) * n_dot_x_1 * n_dot_x_1));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S26 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S27 : f32 = eta_i_0 / eta_o_0 * _S26;
    var _S28 : bool = _S27 < 1.0f;
    var kr_0 : f32;
    if(_S28)
    {
        var _S29 : f32 = sqrt(max(0.0f, 1.0f - _S27 * _S27));
        var _S30 : f32 = eta_o_0 * cos_theta_0;
        var _S31 : f32 = eta_i_0 * _S29;
        var _S32 : f32 = (_S30 - _S31) / (_S30 + _S31);
        var _S33 : f32 = eta_i_0 * cos_theta_0;
        var _S34 : f32 = eta_o_0 * _S29;
        var _S35 : f32 = (_S33 - _S34) / (_S33 + _S34);
        var _S36 : f32 = (_S32 * _S32 + _S35 * _S35) / 2.0f;
        kr_0 = _S36;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S37 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S38 : f32 = _S37.x;
    var _S39 : f32 = _S37.y;
    var _S40 : f32 = _S38 * _S38 + _S39 * _S39;
    const _S41 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S42 : vec3<f32> = vec3<f32>(- _S39, _S38, 0.0f);
    var _S43 : f32 = (inverseSqrt((_S40)));
    var _S44 : vec3<f32> = _S42 * vec3<f32>(_S43);
    var _S45 : bool = _S40 > 0.0f;
    var _S46 : vec3<f32> = select(_S41, _S44, _S45);
    var _S47 : vec3<f32> = cross(_S37, _S46);
    var _S48 : f32 = sqrt(U1_0);
    var _S49 : f32 = 6.28318548202514648f * U2_0;
    var _S50 : f32 = _S48 * cos(_S49);
    var t2_0 : f32 = _S48 * sin(_S49);
    var _S51 : f32 = 0.5f * (1.0f + _S37.z);
    var t2_1 : f32 = (1.0f - _S51) * sqrt(max(0.0f, 1.0f - _S50 * _S50)) + _S51 * t2_0;
    var _S52 : vec3<f32> = vec3<f32>(_S50) * _S46 + vec3<f32>(t2_1) * _S47;
    var _S53 : f32 = ((_S50));
    var _S54 : f32 = ((_S50));
    var _S55 : vec3<f32> = _S52 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S53 * _S54 - t2_1 * t2_1))) * _S37;
    var _S56 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S55.x, alpha_3 * _S55.y, max(0.0f, _S55.z)))));
    return _S56;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S57 : f32 = sqrt(random_1_0);
    var _S58 : f32 = 6.28318548202514648f * random_2_0;
    var _S59 : f32 = _S57 * cos(_S58);
    var _S60 : f32 = _S57 * sin(_S58);
    var _S61 : f32 = sqrt(max(0.0f, 1.0f - _S59 * _S59 - _S60 * _S60));
    return vec3<f32>(_S59, _S61, _S60);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S62 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S62)
    {
        const _S63 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S63;
    }
    else
    {
        a_1 = a_0;
    }
    var _S64 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S65 : vec3<f32> = cross(n_0, _S64);
    return vec3<f32>(v_0.x) * _S64 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S65;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S66 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S66)
    {
        const _S67 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S67;
    }
    else
    {
        a_3 = a_2;
    }
    var _S68 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S69 : vec3<f32> = cross(n_1, _S68);
    return vec3<f32>(dot(v_1, _S68), dot(v_1, n_1), dot(v_1, _S69));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S70 : vec3<f32> = p1_0 - p0_0;
    var _S71 : vec3<f32> = p2_0 - p0_0;
    var _S72 : vec2<f32> = uv1_0 - uv0_0;
    var _S73 : vec2<f32> = uv2_0 - uv0_0;
    var _S74 : f32 = _S72.x;
    var _S75 : f32 = _S73.y;
    var _S76 : f32 = _S72.y;
    var _S77 : f32 = _S73.x;
    var _S78 : f32 = _S74 * _S75 - _S76 * _S77;
    var _S79 : f32 = 1.0f / _S78;
    var _S80 : vec3<f32> = vec3<f32>(_S79);
    var t_0 : vec3<f32> = (_S70 * vec3<f32>(_S75) - _S71 * vec3<f32>(_S76)) * _S80;
    var _S81 : vec3<f32> = (_S71 * vec3<f32>(_S74) - _S70 * vec3<f32>(_S77)) * _S80;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S82 : bool = (dot(cross(n_2, t_1), _S81)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S82)
    {
        var _S83 : vec3<f32> = ((-(t_1)));
        t_2 = _S83;
    }
    else
    {
        t_2 = t_1;
    }
    var _S84 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S84, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S85 : Random = pcg((*random_state_0));
    var _S86 : Random = pcg(_S85.state);
    (*random_state_0) = _S86.state;
    var _S87 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S88 : vec3<f32> = sampleGGXVNDF(_S87.xzy, alpha_4, _S85.value, _S86.value);
    var _S89 : vec3<f32> = _S88.xzy;
    var _S90 : vec3<f32> = tangentToWorld(_S89, n_i_0);
    return _S90;
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
    var _S91 : BSDFLobes;
    _S91.v_dot_h = v_dot_h_0;
    _S91.n_dot_h = n_dot_h_1;
    _S91.refracted = refracted_0;
    _S91.F = F_0;
    _S91.F_greyscale = F_greyscale_0;
    _S91.reflect_weight = reflect_weight_0;
    _S91.diffuse_weight = diffuse_weight_0;
    _S91.refract_weight = refract_weight_0;
    _S91.colorless_reflection = colorless_reflection_0;
    _S91.p_diffuse = p_diffuse_0;
    _S91.p_reflect = p_reflect_0;
    _S91.p_refract = p_refract_0;
    return _S91;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S92 : f32 = dot(ggx_n_0, v_4);
    var _S93 : f32 = dot(n_i_1, ggx_n_0);
    var _S94 : f32 = eta_i_1 / eta_o_1;
    var _S95 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S94))));
    var _S96 : f32 = fresnel(abs(_S92), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S96)), (material_0.albedo), (material_0.metallic)));
    var _S97 : f32 = rgb_to_greyscale(F_1);
    var _S98 : f32 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    var _S99 : f32 = max(_S97, 0.0f);
    var _S100 : f32 = 1.0f - _S97;
    var _S101 : f32 = max(_S98 * _S100, 0.0f);
    var _S102 : f32 = material_0.transmission * _S100;
    var _S103 : f32 = (sign((length(_S95))));
    var _S104 : f32 = max(_S102 * _S103, 0.0f);
    var _S105 : f32 = _S99 + _S101 + _S104;
    var _S106 : f32 = 1.0f / max(_S105, 0.0000152587890625f);
    var _S107 : f32 = _S101 * _S106;
    var _S108 : f32 = _S99 * _S106;
    var _S109 : f32 = _S104 * _S106;
    return BSDFLobes_x24init_0(_S92, _S93, _S95, F_1, _S97, 1.0f, _S98, material_0.transmission, material_0.transmission, _S107, _S108, _S109);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S110 : bool = lobe_0 == u32(0);
    if(_S110)
    {
        var _S111 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S112 : bool = n_i_dot_v_0 > 0.0f;
        var _S113 : f32 = select(0.0f, _S111, _S112);
        return _S113;
    }
    var _S114 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S115 : f32 = _S114 * lobes_0.v_dot_h;
    var _S116 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S117 : f32 = _S115 * _S116 / n_i_dot_v_0;
    var _S118 : bool = alpha_5 > 0.0f;
    var _S119 : bool;
    if(_S118)
    {
        _S119 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S119 = false;
    }
    if(_S119)
    {
        _S119 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S119 = false;
    }
    if(_S119)
    {
        _S119 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S119 = false;
    }
    var _S120 : f32 = select(0.0f, _S117, _S119);
    var _S121 : bool = lobe_0 == u32(1);
    if(_S121)
    {
        var _S122 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S123 : f32 = lobes_0.p_refract * _S120 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S122 * _S122);
        var _S124 : bool = eta_i_2 != eta_o_2;
        if(_S124)
        {
            _S119 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S119 = false;
        }
        var _S125 : f32 = select(0.0f, _S123, _S119);
        return _S125;
    }
    var _S126 : f32 = lobes_0.p_reflect * _S120 / (4.0f * lobes_0.v_dot_h);
    var _S127 : bool = _S120 > 0.0f;
    var _S128 : f32 = select(0.0f, _S126, _S127);
    return _S128;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S129 : bool = lobe_1 == u32(0);
    if(_S129)
    {
        return vec3<f32>(lobes_1.diffuse_weight) * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S130 : bool = lobe_1 == u32(1);
    if(_S130)
    {
        var _S131 : f32 = - dot(n_i_2, l_0);
        var _S132 : f32 = G1(alpha_6, max(_S131, 0.0f));
        return vec3<f32>((lobes_1.refract_weight * _S132 * (1.0f - lobes_1.F_greyscale) / lobes_1.p_refract));
    }
    var _S133 : f32 = dot(n_i_2, l_0);
    var _S134 : f32 = G1(alpha_6, max(_S133, 0.0f));
    var _S135 : f32 = lobes_1.reflect_weight * _S134;
    var _S136 : vec3<f32> = (mix((lobes_1.F), (vec3<f32>(lobes_1.F_greyscale)), (lobes_1.colorless_reflection)));
    return vec3<f32>(_S135) * _S136 / vec3<f32>(lobes_1.p_reflect);
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
    var _S137 : SampleBSDF;
    _S137.unit_direction = unit_direction_0;
    _S137.throughput = throughput_0;
    _S137.random_state = random_state_1;
    _S137.refracted = refracted_1;
    _S137.lobe = lobe_2;
    _S137.pdf = pdf_0;
    return _S137;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S138 : vec3<f32> = ((-(in_dir_1)));
    var _S139 : f32 = dot(n_3, _S138);
    var _S140 : f32 = (sign((_S139)));
    var _S141 : vec3<f32> = n_3 * vec3<f32>(_S140);
    var _S142 : f32 = material_2.roughness;
    var _S143 : f32 = _S142 * _S142;
    var _S144 : vec3<f32> = (normalize((_S138 + out_dir_0)));
    var _S145 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S145)
    {
        var _S146 : vec3<f32> = sampleHalfVector(_S138, _S141, _S143, &(random_state_2));
        ggx_n_1 = _S146;
    }
    else
    {
        var _S147 : bool = lobe_3 == u32(1);
        if(_S147)
        {
            var _S148 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S138 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S149 : vec3<f32> = (normalize((_S148)));
            var _S150 : f32 = (sign((dot(_S148, _S141))));
            var _S151 : vec3<f32> = _S149 * vec3<f32>(_S150);
            ggx_n_1 = _S151;
        }
        else
        {
            ggx_n_1 = _S144;
        }
    }
    var _S152 : BSDFLobes = bsdfLobes(in_dir_1, _S138, _S141, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S153 : f32 = lobeDensity(dot(_S141, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S139), _S143, _S152, eta_i_3, eta_o_3, lobe_3);
    var _S154 : bool = !(_S153 > 0.0f);
    if(_S154)
    {
        var _S155 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S155, _S155, u32(0), false, u32(0), 0.0f);
    }
    var _S156 : vec3<f32> = lobeThroughput(out_dir_0, _S141, _S143, material_2, _S152, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S156, random_state_2, lobe_3 == u32(1), lobe_3, _S153);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S157 : vec3<f32> = ((-(in_dir_2)));
    var _S158 : bool = (dot(g_n_0, _S157) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S158)
    {
        var _S159 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S160 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S159.throughput * vec3<f32>(_S159.pdf) + _S160.throughput * vec3<f32>(_S160.pdf);
    }
    var _S161 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S161.throughput * vec3<f32>(_S161.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S162 : vec3<f32> = ((-(in_dir_3)));
    var _S163 : f32 = dot(n_5, _S162);
    var _S164 : f32 = (sign((_S163)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S164);
    var _S165 : f32 = abs(_S163);
    var _S166 : f32 = material_4.roughness;
    var _S167 : f32 = _S166 * _S166;
    var _S168 : vec3<f32> = sampleHalfVector(_S162, n_i_3, _S167, &(random_state_4));
    var _S169 : BSDFLobes = bsdfLobes(in_dir_3, _S162, n_i_3, _S168, material_4, eta_i_5, eta_o_5);
    var _S170 : vec3<f32> = vec3<f32>(1.0f);
    var _S171 : SampleBSDF = SampleBSDF_x24init_0(_S170, _S170, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S171;
    var _S172 : Random = pcg(random_state_4);
    random_state_4 = _S172.state;
    var _S173 : bool = (_S172.value) < (_S169.p_diffuse);
    if(_S173)
    {
        var _S174 : Random = pcg(random_state_4);
        var _S175 : Random = pcg(_S174.state);
        sample_0.random_state = _S175.state;
        var _S176 : vec3<f32> = sampleCosWeightedHemisphere(_S174.value, _S175.value);
        var _S177 : vec3<f32> = tangentToWorld(_S176, n_i_3);
        sample_0.unit_direction = _S177;
        var _S178 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S167, material_4, _S169, u32(0));
        sample_0.throughput = _S178;
        var _S179 : f32 = lobeDensity(_S176.y, 0.0f, _S165, _S167, _S169, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S179;
        return sample_0;
    }
    var _S180 : bool = (_S172.value) < (_S169.p_diffuse + _S169.p_refract);
    if(_S180)
    {
        sample_0.unit_direction = _S169.refracted;
        var _S181 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S168), _S165, _S167, _S169, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S181;
        var _S182 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S167, material_4, _S169, u32(1));
        sample_0.throughput = _S182;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S183 : vec3<f32> = (normalize((reflect(in_dir_3, _S168))));
    sample_0.unit_direction = _S183;
    var _S184 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S167, material_4, _S169, u32(2));
    sample_0.throughput = _S184;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S185 : f32 = lobeDensity(0.0f, 0.0f, _S165, _S167, _S169, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S185;
    return sample_0;
}

fn neeDecision( material_5 : Material,  n_dot_v_0 : f32,  eta_i_6 : f32,  eta_o_6 : f32) -> bool
{
    var _S186 : f32 = fresnel(abs(n_dot_v_0), eta_i_6, eta_o_6);
    var _S187 : vec3<f32> = (mix((vec3<f32>(_S186)), (material_5.albedo), (material_5.metallic)));
    var _S188 : f32 = rgb_to_greyscale(_S187);
    var _S189 : f32 = max((1.0f - _S188) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission), 0.0f);
    var _S190 : bool = _S189 > 0.03999999910593033f;
    var _S191 : bool;
    if(_S190)
    {
        _S191 = true;
    }
    else
    {
        _S191 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S191;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S192 : vec3<f32> = a_4 / b_0;
    var _S193 : vec3<f32> = vec3<f32>(0.0f);
    var _S194 : vec3<bool> = b_0 == _S193;
    var _S195 : vec3<f32> = select(_S192, _S193, _S194);
    return _S195;
}

