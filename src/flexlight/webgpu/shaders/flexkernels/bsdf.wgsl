fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S1 : f32 = alpha_0 * alpha_0;
    var _S2 : f32 = n_dot_h_0 * n_dot_h_0 * (_S1 - 1.0f) + 1.0f;
    return _S1 / max(3.14159274101257324f * _S2 * _S2, 0.0000152587890625f);
}

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S3 : f32 = alpha_1 * alpha_1;
    return 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S3 + (1.0f - _S3) * n_dot_x_0 * n_dot_x_0));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S4 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S5 : f32 = eta_i_0 / eta_o_0 * _S4;
    var _S6 : bool = _S5 < 1.0f;
    var kr_0 : f32;
    if(_S6)
    {
        var _S7 : f32 = sqrt(max(0.0f, 1.0f - _S5 * _S5));
        var _S8 : f32 = eta_o_0 * cos_theta_0;
        var _S9 : f32 = eta_i_0 * _S7;
        var _S10 : f32 = (_S8 - _S9) / (_S8 + _S9);
        var _S11 : f32 = eta_i_0 * cos_theta_0;
        var _S12 : f32 = eta_o_0 * _S7;
        var _S13 : f32 = (_S11 - _S12) / (_S11 + _S12);
        var _S14 : f32 = (_S10 * _S10 + _S13 * _S13) / 2.0f;
        kr_0 = _S14;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_2 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S15 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z))));
    var _S16 : f32 = _S15.x;
    var _S17 : f32 = _S15.y;
    var _S18 : f32 = _S16 * _S16 + _S17 * _S17;
    const _S19 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S20 : vec3<f32> = vec3<f32>(- _S17, _S16, 0.0f);
    var _S21 : f32 = (inverseSqrt((_S18)));
    var _S22 : vec3<f32> = _S20 * vec3<f32>(_S21);
    var _S23 : bool = _S18 > 0.0f;
    var _S24 : vec3<f32> = select(_S19, _S22, _S23);
    var _S25 : vec3<f32> = cross(_S15, _S24);
    var _S26 : f32 = sqrt(U1_0);
    var _S27 : f32 = 6.28318548202514648f * U2_0;
    var _S28 : f32 = _S26 * cos(_S27);
    var t2_0 : f32 = _S26 * sin(_S27);
    var _S29 : f32 = 0.5f * (1.0f + _S15.z);
    var t2_1 : f32 = (1.0f - _S29) * sqrt(max(0.0f, 1.0f - _S28 * _S28)) + _S29 * t2_0;
    var _S30 : vec3<f32> = vec3<f32>(_S28) * _S24 + vec3<f32>(t2_1) * _S25;
    var _S31 : f32 = ((_S28));
    var _S32 : f32 = ((_S28));
    var _S33 : vec3<f32> = _S30 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S31 * _S32 - t2_1 * t2_1))) * _S15;
    var _S34 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * _S33.x, alpha_2 * _S33.y, max(0.0f, _S33.z)))));
    return _S34;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S35 : f32 = sqrt(random_1_0);
    var _S36 : f32 = 6.28318548202514648f * random_2_0;
    var _S37 : f32 = _S35 * cos(_S36);
    var _S38 : f32 = _S35 * sin(_S36);
    var _S39 : f32 = sqrt(max(0.0f, 1.0f - _S37 * _S37 - _S38 * _S38));
    return vec3<f32>(_S37, _S39, _S38);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S40 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S40)
    {
        const _S41 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S41;
    }
    else
    {
        a_1 = a_0;
    }
    var _S42 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S43 : vec3<f32> = cross(n_0, _S42);
    return vec3<f32>(v_0.x) * _S42 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S43;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S44 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S44)
    {
        const _S45 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S45;
    }
    else
    {
        a_3 = a_2;
    }
    var _S46 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S47 : vec3<f32> = cross(n_1, _S46);
    return vec3<f32>(dot(v_1, _S46), dot(v_1, n_1), dot(v_1, _S47));
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S48 : Random;
    _S48.state = state_0;
    _S48.value = value_0;
    return _S48;
}

fn hash( x_0 : u32) -> u32
{
    var _S49 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S50 : u32 = ((((_S49 >> ((((_S49 >> (u32(28)))) + u32(4))))) ^ (_S49))) * u32(277803737);
    return (((_S50 >> (u32(22)))) ^ (_S50));
}

fn pcg( state_1 : u32) -> Random
{
    var new_state_0 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S51 : u32 = ((((new_state_0 >> ((((new_state_0 >> (u32(28)))) + u32(4))))) ^ (new_state_0))) * u32(277803737);
    var _S52 : u32 = (((_S51 >> (u32(22)))) ^ (_S51));
    var _S53 : f32 = f32(_S52) / 4.294967296e+09f;
    return Random_x24init_0(new_state_0, _S53);
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S54 : Random = pcg((*random_state_0));
    var _S55 : Random = pcg(_S54.state);
    (*random_state_0) = _S55.state;
    var _S56 : vec3<f32> = worldToTangent(v_2, n_i_0);
    var _S57 : vec3<f32> = sampleGGXVNDF(_S56.xzy, alpha_3, _S54.value, _S55.value);
    var _S58 : vec3<f32> = _S57.xzy;
    var _S59 : vec3<f32> = tangentToWorld(_S58, n_i_0);
    return _S59;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S60 : vec3<f32> = a_4 / b_0;
    var _S61 : vec3<f32> = vec3<f32>(0.0f);
    var _S62 : vec3<bool> = b_0 == _S61;
    var _S63 : vec3<f32> = select(_S60, _S61, _S62);
    return _S63;
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S64 : Random = pcg(state_2);
    var _S65 : Random = pcg(_S64.state);
    var _S66 : f32 = 6.28318548202514648f * _S64.value;
    var _S67 : f32 = sqrt(-2.0f * clamp(log(_S65.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S65.state, _S67 * cos(_S66));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S68 : RandomSphere;
    _S68.state = state_3;
    _S68.value = value_1;
    return _S68;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S69 : Random = normal_distribution(state_4);
    var _S70 : Random = normal_distribution(_S69.state);
    var _S71 : Random = normal_distribution(_S70.state);
    var _S72 : vec3<f32> = (normalize((vec3<f32>(_S69.value, _S70.value, _S71.value))));
    return RandomSphere_x24init_0(_S71.state, _S72);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S73 : RandomHemisphere;
    _S73.state = state_5;
    _S73.value = value_2;
    return _S73;
}

fn random_hemisphere( state_6 : u32,  normal_0 : vec3<f32>) -> RandomHemisphere
{
    var _S74 : RandomSphere = random_sphere(state_6);
    var _S75 : bool = (dot(_S74.value, normal_0)) > 0.0f;
    if(_S75)
    {
        return RandomHemisphere_x24init_0(_S74.state, _S74.value);
    }
    else
    {
        return RandomHemisphere_x24init_0(_S74.state, (vec3<f32>(0) - _S74.value));
    }
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S76 : u32 = hash(index_0);
    var _S77 : u32 = hash((seed_0 ^ (_S76)));
    return _S77;
}

