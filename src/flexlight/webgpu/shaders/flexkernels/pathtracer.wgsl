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
        return RandomHemisphere_x24init_0(_S17.state, (vec3<f32>(0) - _S17.value));
    }
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S19 : u32 = hash(index_0);
    var _S20 : u32 = hash((seed_0 ^ (_S19)));
    return _S20;
}

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S21 : f32 = alpha_0 * alpha_0;
    var _S22 : f32 = n_dot_h_0 * n_dot_h_0 * (_S21 - 1.0f) + 1.0f;
    return _S21 / max(3.14159274101257324f * _S22 * _S22, 0.0000152587890625f);
}

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S23 : f32 = alpha_1 * alpha_1;
    return 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S23 + (1.0f - _S23) * n_dot_x_0 * n_dot_x_0));
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

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_2 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S35 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z))));
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
    var _S54 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * _S53.x, alpha_2 * _S53.y, max(0.0f, _S53.z)))));
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

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S68 : Random = pcg((*random_state_0));
    var _S69 : Random = pcg(_S68.state);
    (*random_state_0) = _S69.state;
    var _S70 : vec3<f32> = worldToTangent(v_2, n_i_0);
    var _S71 : vec3<f32> = sampleGGXVNDF(_S70.xzy, alpha_3, _S68.value, _S69.value);
    var _S72 : vec3<f32> = _S71.xzy;
    var _S73 : vec3<f32> = tangentToWorld(_S72, n_i_0);
    return _S73;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S74 : vec3<f32> = a_4 / b_0;
    var _S75 : vec3<f32> = vec3<f32>(0.0f);
    var _S76 : vec3<bool> = b_0 == _S75;
    var _S77 : vec3<f32> = select(_S74, _S75, _S76);
    return _S77;
}

struct Surface
{
     normal : vec3<f32>,
     albedo : vec3<f32>,
     metallic : f32,
     roughness : f32,
     emissive : vec3<f32>,
     transparency : f32,
     ior : f32,
     tint : vec3<f32>,
     level : f32,
     coverage : f32,
     absorption : vec3<f32>,
     density : f32,
};

fn tinted( material_0 : Surface,  cos_theta_1 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var root_0 : f32 = (eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1) * sqrt(material_0.level);
    var F_0 : f32 = fresnel(cos_theta_1, 1.0f + root_0, 1.0f - root_0);
    var F0_0 : f32 = root_0 * root_0;
    return vec3<f32>(F_0, F_0, F_0) - (vec3<f32>(1.0f, 1.0f, 1.0f) - material_0.tint) * vec3<f32>((F0_0 * (1.0f - F_0) / max(1.0f - F0_0, 0.0000152587890625f)));
}

fn mix_0( a_5 : vec3<f32>,  b_1 : vec3<f32>,  t_0 : f32) -> vec3<f32>
{
    return a_5 * vec3<f32>((1.0f - t_0)) + b_1 * vec3<f32>(t_0);
}

fn sign_0( x_1 : f32) -> f32
{
    return f32(x_1 > 0.0f) - f32(x_1 < 0.0f);
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

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_1 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : f32,  refract_weight_0 : f32,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32) -> BSDFLobes
{
    var _S78 : BSDFLobes;
    _S78.v_dot_h = v_dot_h_0;
    _S78.n_dot_h = n_dot_h_1;
    _S78.refracted = refracted_0;
    _S78.F = F_1;
    _S78.F_greyscale = F_greyscale_0;
    _S78.reflect_weight = reflect_weight_0;
    _S78.diffuse_weight = diffuse_weight_0;
    _S78.refract_weight = refract_weight_0;
    _S78.p_diffuse = p_diffuse_0;
    _S78.p_reflect = p_reflect_0;
    _S78.p_refract = p_refract_0;
    return _S78;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Surface,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var v_dot_h_1 : f32 = dot(ggx_n_0, v_3);
    var n_dot_h_2 : f32 = dot(n_i_1, ggx_n_0);
    var eta_0 : f32 = eta_i_2 / eta_o_2;
    var refracted_1 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, eta_0))));
    var _S79 : vec3<f32> = tinted(material_1, abs(v_dot_h_1), eta_i_2, eta_o_2);
    var F_2 : vec3<f32> = mix_0(_S79, material_1.albedo, material_1.metallic);
    var F_greyscale_1 : f32 = rgb_to_greyscale(F_2);
    var diffuse_weight_1 : f32 = (1.0f - material_1.transparency) * (1.0f - material_1.metallic);
    var _S80 : f32 = max(F_greyscale_1, 0.0f);
    var _S81 : f32 = 1.0f - F_greyscale_1;
    var _S82 : f32 = max(diffuse_weight_1 * _S81, 0.0f);
    var _S83 : f32 = material_1.transparency * _S81;
    var _S84 : f32 = sign_0(sqrt(dot(refracted_1, refracted_1)));
    var _S85 : f32 = max(_S83 * _S84, 0.0f);
    var total_component_0 : f32 = _S80 + _S82 + _S85;
    var total_component_inv_0 : f32 = 1.0f / max(total_component_0, 0.0000152587890625f);
    var p_diffuse_1 : f32 = _S82 * total_component_inv_0;
    var p_reflect_1 : f32 = _S80 * total_component_inv_0;
    var p_refract_1 : f32 = _S85 * total_component_inv_0;
    return BSDFLobes_x24init_0(v_dot_h_1, n_dot_h_2, refracted_1, F_2, F_greyscale_1, 1.0f, diffuse_weight_1, material_1.transparency, p_diffuse_1, p_reflect_1, p_refract_1);
}

fn brightest_0( rgb_1 : vec3<f32>) -> f32
{
    return max(rgb_1.x, max(rgb_1.y, rgb_1.z));
}

fn G1_0( alpha_4 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S86 : f32 = smithG1(alpha_4, n_dot_x_1);
    return _S86;
}

fn lobeThroughput( v_4 : vec3<f32>,  l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_5 : f32,  material_2 : Surface,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_0 : u32) -> vec3<f32>
{
    var _S87 : bool = lobe_0 == u32(0);
    if(_S87)
    {
        var _S88 : vec3<f32> = vec3<f32>(lobes_0.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_0.p_diffuse);
        var _S89 : vec3<f32> = (normalize((v_4 + l_0)));
        var _S90 : vec3<f32> = tinted(material_2, abs(dot(v_4, _S89)), eta_i_3, eta_o_3);
        var _S91 : vec3<f32> = mix_0(_S90, material_2.albedo, material_2.metallic);
        var _S92 : f32 = brightest_0(_S91);
        return _S88 * vec3<f32>((1.0f - _S92));
    }
    var _S93 : bool = lobe_0 == u32(1);
    if(_S93)
    {
        var m_n_i_dot_l_0 : f32 = - dot(n_i_2, l_0);
        var G1_l_0 : f32 = G1_0(alpha_5, max(m_n_i_dot_l_0, 0.0f));
        return material_2.albedo * vec3<f32>((lobes_0.refract_weight * G1_l_0 * (1.0f - lobes_0.F_greyscale) / lobes_0.p_refract));
    }
    var n_i_dot_l_0 : f32 = dot(n_i_2, l_0);
    var G1_l_1 : f32 = G1_0(alpha_5, max(n_i_dot_l_0, 0.0f));
    return vec3<f32>((lobes_0.reflect_weight * G1_l_1)) * lobes_0.F / vec3<f32>(lobes_0.p_reflect);
}

fn lobeDensity( n_i_dot_l_1 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_6 : f32,  lobes_1 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32,  lobe_1 : u32) -> f32
{
    var _S94 : bool = lobe_1 == u32(0);
    var pdf_h_0 : f32;
    if(_S94)
    {
        if(n_i_dot_v_0 > 0.0f)
        {
            pdf_h_0 = lobes_1.p_diffuse * n_i_dot_l_1 * 0.31830987334251404f;
        }
        else
        {
            pdf_h_0 = 0.0f;
        }
        return pdf_h_0;
    }
    var _S95 : f32 = lobes_1.n_dot_h;
    var d_term_0 : f32 = _S95 * _S95 * (alpha_6 * alpha_6 - 1.0f) + 1.0f;
    var _S96 : bool = alpha_6 > 0.0f;
    var _S97 : bool;
    if(_S96)
    {
        _S97 = (lobes_1.v_dot_h) > 0.0f;
    }
    else
    {
        _S97 = false;
    }
    if(_S97)
    {
        _S97 = (lobes_1.n_dot_h) > 0.0f;
    }
    else
    {
        _S97 = false;
    }
    if(_S97)
    {
        _S97 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S97 = false;
    }
    if(_S97)
    {
        var _S98 : f32 = smithG1(alpha_6, n_i_dot_v_0);
        pdf_h_0 = _S98 * lobes_1.v_dot_h * alpha_6 * alpha_6 / (3.14159274101257324f * d_term_0 * d_term_0 * n_i_dot_v_0);
    }
    else
    {
        pdf_h_0 = 0.0f;
    }
    var _S99 : bool = lobe_1 == u32(1);
    if(_S99)
    {
        var denom_0 : f32 = eta_i_4 * lobes_1.v_dot_h + eta_o_4 * l_dot_h_0;
        var _S100 : bool = eta_i_4 != eta_o_4;
        if(_S100)
        {
            _S97 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S97 = false;
        }
        if(_S97)
        {
            pdf_h_0 = lobes_1.p_refract * pdf_h_0 * eta_o_4 * eta_o_4 * abs(l_dot_h_0) / (denom_0 * denom_0);
        }
        else
        {
            pdf_h_0 = 0.0f;
        }
        return pdf_h_0;
    }
    if(pdf_h_0 > 0.0f)
    {
        pdf_h_0 = lobes_1.p_reflect * pdf_h_0 / (4.0f * lobes_1.v_dot_h);
    }
    else
    {
        pdf_h_0 = 0.0f;
    }
    return pdf_h_0;
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

fn SampleBSDF_x24init_0( unit_direction_0 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_2 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S101 : SampleBSDF;
    _S101.unit_direction = unit_direction_0;
    _S101.throughput = throughput_0;
    _S101.random_state = random_state_1;
    _S101.refracted = refracted_2;
    _S101.lobe = lobe_2;
    _S101.pdf = pdf_0;
    return _S101;
}

fn sampleBSDF( in_dir_1 : vec3<f32>,  n_2 : vec3<f32>,  material_3 : Surface,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var v_5 : vec3<f32> = (vec3<f32>(0) - in_dir_1);
    var n_dot_v_0 : f32 = dot(n_2, v_5);
    var _S102 : f32 = sign_0(n_dot_v_0);
    var n_i_3 : vec3<f32> = n_2 * vec3<f32>(_S102);
    var n_i_dot_v_1 : f32 = abs(n_dot_v_0);
    var _S103 : f32 = material_3.roughness;
    var alpha_7 : f32 = _S103 * _S103;
    var ggx_n_1 : vec3<f32> = sampleHalfVector(v_5, n_i_3, alpha_7, &(random_state_2));
    var lobes_2 : BSDFLobes = bsdfLobes(in_dir_1, v_5, n_i_3, ggx_n_1, material_3, eta_i_5, eta_o_5);
    const _S104 : vec3<f32> = vec3<f32>(1.0f, 1.0f, 1.0f);
    var _S105 : SampleBSDF = SampleBSDF_x24init_0(_S104, _S104, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S105;
    var random_p_0 : Random = pcg(random_state_2);
    random_state_2 = random_p_0.state;
    var _S106 : bool = (random_p_0.value) < (lobes_2.p_diffuse);
    if(_S106)
    {
        var random_d_1_0 : Random = pcg(random_state_2);
        var random_d_2_0 : Random = pcg(random_d_1_0.state);
        sample_0.random_state = random_d_2_0.state;
        var cosine_hemisphere_0 : vec3<f32> = sampleCosWeightedHemisphere(random_d_1_0.value, random_d_2_0.value);
        var _S107 : vec3<f32> = tangentToWorld(cosine_hemisphere_0, n_i_3);
        sample_0.unit_direction = _S107;
        var _S108 : vec3<f32> = lobeThroughput(v_5, sample_0.unit_direction, n_i_3, alpha_7, material_3, lobes_2, eta_i_5, eta_o_5, u32(0));
        sample_0.throughput = _S108;
        var _S109 : f32 = lobeDensity(cosine_hemisphere_0.y, 0.0f, n_i_dot_v_1, alpha_7, lobes_2, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S109;
        return sample_0;
    }
    var _S110 : bool = (random_p_0.value) < (lobes_2.p_diffuse + lobes_2.p_refract);
    if(_S110)
    {
        sample_0.unit_direction = lobes_2.refracted;
        var _S111 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, ggx_n_1), n_i_dot_v_1, alpha_7, lobes_2, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S111;
        var _S112 : vec3<f32> = lobeThroughput(v_5, sample_0.unit_direction, n_i_3, alpha_7, material_3, lobes_2, eta_i_5, eta_o_5, u32(1));
        sample_0.throughput = _S112;
        sample_0.random_state = random_state_2;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S113 : vec3<f32> = (normalize((reflect(in_dir_1, ggx_n_1))));
    sample_0.unit_direction = _S113;
    var _S114 : vec3<f32> = lobeThroughput(v_5, sample_0.unit_direction, n_i_3, alpha_7, material_3, lobes_2, eta_i_5, eta_o_5, u32(2));
    sample_0.throughput = _S114;
    sample_0.random_state = random_state_2;
    sample_0.lobe = u32(2);
    var _S115 : f32 = lobeDensity(0.0f, 0.0f, n_i_dot_v_1, alpha_7, lobes_2, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S115;
    return sample_0;
}

fn connectBSDF( in_dir_2 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_4 : Surface,  eta_i_6 : f32,  eta_o_6 : f32,  lobe_3 : u32,  random_init_1 : u32) -> SampleBSDF
{
    var random_state_3 : u32 = random_init_1;
    var v_6 : vec3<f32> = (vec3<f32>(0) - in_dir_2);
    var n_dot_v_1 : f32 = dot(n_3, v_6);
    var _S116 : f32 = sign_0(n_dot_v_1);
    var n_i_4 : vec3<f32> = n_3 * vec3<f32>(_S116);
    var _S117 : f32 = material_4.roughness;
    var alpha_8 : f32 = _S117 * _S117;
    var _S118 : vec3<f32> = (normalize((v_6 + out_dir_0)));
    var _S119 : bool = lobe_3 == u32(0);
    var ggx_n_2 : vec3<f32>;
    if(_S119)
    {
        var _S120 : vec3<f32> = sampleHalfVector(v_6, n_i_4, alpha_8, &(random_state_3));
        ggx_n_2 = _S120;
    }
    else
    {
        var _S121 : bool = lobe_3 == u32(1);
        if(_S121)
        {
            var h_t_0 : vec3<f32> = (vec3<f32>(0) - (vec3<f32>(eta_i_6) * v_6 + vec3<f32>(eta_o_6) * out_dir_0));
            var _S122 : vec3<f32> = (normalize((h_t_0)));
            var _S123 : f32 = sign_0(dot(h_t_0, n_i_4));
            var _S124 : vec3<f32> = _S122 * vec3<f32>(_S123);
            ggx_n_2 = _S124;
        }
        else
        {
            ggx_n_2 = _S118;
        }
    }
    var lobes_3 : BSDFLobes = bsdfLobes(in_dir_2, v_6, n_i_4, ggx_n_2, material_4, eta_i_6, eta_o_6);
    var pdf_1 : f32 = lobeDensity(dot(n_i_4, out_dir_0), dot(out_dir_0, ggx_n_2), abs(n_dot_v_1), alpha_8, lobes_3, eta_i_6, eta_o_6, lobe_3);
    var _S125 : bool = !(pdf_1 > 0.0f);
    if(_S125)
    {
        var _S126 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S126, _S126, u32(0), false, u32(0), 0.0f);
    }
    var _S127 : vec3<f32> = lobeThroughput(v_6, out_dir_0, n_i_4, alpha_8, material_4, lobes_3, eta_i_6, eta_o_6, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S127, random_state_3, lobe_3 == u32(1), lobe_3, pdf_1);
}

fn BSDF( in_dir_3 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Surface,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S128 : bool = (dot(g_n_0, (vec3<f32>(0) - in_dir_3)) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S128)
    {
        var diffuse_0 : SampleBSDF = connectBSDF(in_dir_3, out_dir_1, n_4, material_5, eta_i_7, eta_o_7, u32(0), random_state_4);
        var reflection_0 : SampleBSDF = connectBSDF(in_dir_3, out_dir_1, n_4, material_5, eta_i_7, eta_o_7, u32(2), random_state_4);
        return diffuse_0.throughput * vec3<f32>(diffuse_0.pdf) + reflection_0.throughput * vec3<f32>(reflection_0.pdf);
    }
    var refraction_0 : SampleBSDF = connectBSDF(in_dir_3, out_dir_1, n_4, material_5, eta_i_7, eta_o_7, u32(1), random_state_4);
    return refraction_0.throughput * vec3<f32>(refraction_0.pdf);
}

fn beerLambert( distance_0 : f32,  material_6 : Surface) -> vec3<f32>
{
    var depth_0 : f32 = distance_0 * material_6.density;
    return vec3<f32>(exp(depth_0 * (material_6.absorption.x - 1.0f)), exp(depth_0 * (material_6.absorption.y - 1.0f)), exp(depth_0 * (material_6.absorption.z - 1.0f)));
}

fn neeDecision( material_7 : Surface,  n_dot_v_2 : f32,  eta_i_8 : f32,  eta_o_8 : f32) -> bool
{
    var _S129 : vec3<f32> = tinted(material_7, abs(n_dot_v_2), eta_i_8, eta_o_8);
    var F_n_0 : vec3<f32> = mix_0(_S129, material_7.albedo, material_7.metallic);
    var F_n_greyscale_0 : f32 = rgb_to_greyscale(F_n_0);
    var _S130 : f32 = max((1.0f - F_n_greyscale_0) * (1.0f - material_7.metallic) * (1.0f - material_7.transparency), 0.0f);
    var _S131 : bool = _S130 > 0.03999999910593033f;
    var _S132 : bool;
    if(_S131)
    {
        _S132 = true;
    }
    else
    {
        _S132 = (material_7.roughness) > 0.20000000298023224f;
    }
    return _S132;
}

