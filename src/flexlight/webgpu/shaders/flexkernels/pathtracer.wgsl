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

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S24 : f32 = alpha_1 * alpha_1;
    return 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S24 + (1.0f - _S24) * n_dot_x_0 * n_dot_x_0));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S25 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S26 : f32 = eta_i_0 / eta_o_0 * _S25;
    var _S27 : bool = _S26 < 1.0f;
    var kr_0 : f32;
    if(_S27)
    {
        var _S28 : f32 = sqrt(max(0.0f, 1.0f - _S26 * _S26));
        var _S29 : f32 = eta_o_0 * cos_theta_0;
        var _S30 : f32 = eta_i_0 * _S28;
        var _S31 : f32 = (_S29 - _S30) / (_S29 + _S30);
        var _S32 : f32 = eta_i_0 * cos_theta_0;
        var _S33 : f32 = eta_o_0 * _S28;
        var _S34 : f32 = (_S32 - _S33) / (_S32 + _S33);
        var _S35 : f32 = (_S31 * _S31 + _S34 * _S34) / 2.0f;
        kr_0 = _S35;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_2 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S36 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z))));
    var _S37 : f32 = _S36.x;
    var _S38 : f32 = _S36.y;
    var _S39 : f32 = _S37 * _S37 + _S38 * _S38;
    const _S40 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S41 : vec3<f32> = vec3<f32>(- _S38, _S37, 0.0f);
    var _S42 : f32 = (inverseSqrt((_S39)));
    var _S43 : vec3<f32> = _S41 * vec3<f32>(_S42);
    var _S44 : bool = _S39 > 0.0f;
    var _S45 : vec3<f32> = select(_S40, _S43, _S44);
    var _S46 : vec3<f32> = cross(_S36, _S45);
    var _S47 : f32 = sqrt(U1_0);
    var _S48 : f32 = 6.28318548202514648f * U2_0;
    var _S49 : f32 = _S47 * cos(_S48);
    var t2_0 : f32 = _S47 * sin(_S48);
    var _S50 : f32 = 0.5f * (1.0f + _S36.z);
    var t2_1 : f32 = (1.0f - _S50) * sqrt(max(0.0f, 1.0f - _S49 * _S49)) + _S50 * t2_0;
    var _S51 : vec3<f32> = vec3<f32>(_S49) * _S45 + vec3<f32>(t2_1) * _S46;
    var _S52 : f32 = ((_S49));
    var _S53 : f32 = ((_S49));
    var _S54 : vec3<f32> = _S51 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S52 * _S53 - t2_1 * t2_1))) * _S36;
    var _S55 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * _S54.x, alpha_2 * _S54.y, max(0.0f, _S54.z)))));
    return _S55;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S56 : f32 = sqrt(random_1_0);
    var _S57 : f32 = 6.28318548202514648f * random_2_0;
    var _S58 : f32 = _S56 * cos(_S57);
    var _S59 : f32 = _S56 * sin(_S57);
    var _S60 : f32 = sqrt(max(0.0f, 1.0f - _S58 * _S58 - _S59 * _S59));
    return vec3<f32>(_S58, _S60, _S59);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S61 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S61)
    {
        const _S62 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S62;
    }
    else
    {
        a_1 = a_0;
    }
    var _S63 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S64 : vec3<f32> = cross(n_0, _S63);
    return vec3<f32>(v_0.x) * _S63 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S64;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S65 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S65)
    {
        const _S66 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S66;
    }
    else
    {
        a_3 = a_2;
    }
    var _S67 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S68 : vec3<f32> = cross(n_1, _S67);
    return vec3<f32>(dot(v_1, _S67), dot(v_1, n_1), dot(v_1, _S68));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S69 : Random = pcg((*random_state_0));
    var _S70 : Random = pcg(_S69.state);
    (*random_state_0) = _S70.state;
    var _S71 : vec3<f32> = worldToTangent(v_2, n_i_0);
    var _S72 : vec3<f32> = sampleGGXVNDF(_S71.xzy, alpha_3, _S69.value, _S70.value);
    var _S73 : vec3<f32> = _S72.xzy;
    var _S74 : vec3<f32> = tangentToWorld(_S73, n_i_0);
    return _S74;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S75 : vec3<f32> = a_4 / b_0;
    var _S76 : vec3<f32> = vec3<f32>(0.0f);
    var _S77 : vec3<bool> = b_0 == _S76;
    var _S78 : vec3<f32> = select(_S75, _S76, _S77);
    return _S78;
}

