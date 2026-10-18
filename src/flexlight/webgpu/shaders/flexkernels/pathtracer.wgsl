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

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S91 : vec3<f32> = a_4 / b_0;
    var _S92 : vec3<f32> = vec3<f32>(0.0f);
    var _S93 : vec3<bool> = b_0 == _S92;
    var _S94 : vec3<f32> = select(_S91, _S92, _S93);
    return _S94;
}

