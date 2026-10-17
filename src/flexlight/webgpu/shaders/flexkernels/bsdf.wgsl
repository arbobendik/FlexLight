fn smithG1( alpha_0 : f32,  n_dot_x_0 : f32) -> f32
{
    var alpha_sq_0 : f32 = alpha_0 * alpha_0;
    return 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(alpha_sq_0 + (1.0f - alpha_sq_0) * n_dot_x_0 * n_dot_x_0));
}

fn trowbridgeReitz( alpha_1 : f32,  n_dot_h_0 : f32) -> f32
{
    var numerator_0 : f32 = alpha_1 * alpha_1;
    var denom_0 : f32 = n_dot_h_0 * n_dot_h_0 * (numerator_0 - 1.0f) + 1.0f;
    return numerator_0 / max(3.14159274101257324f * denom_0 * denom_0, 0.0000152587890625f);
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var sin_psi_0 : f32 = eta_i_0 / eta_o_0 * sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var kr_0 : f32;
    if(sin_psi_0 < 1.0f)
    {
        var cos_psi_0 : f32 = sqrt(max(0.0f, 1.0f - sin_psi_0 * sin_psi_0));
        var _S1 : f32 = eta_o_0 * cos_theta_0;
        var _S2 : f32 = eta_i_0 * cos_psi_0;
        var Rs_0 : f32 = (_S1 - _S2) / (_S1 + _S2);
        var _S3 : f32 = eta_i_0 * cos_theta_0;
        var _S4 : f32 = eta_o_0 * cos_psi_0;
        var Rp_0 : f32 = (_S3 - _S4) / (_S3 + _S4);
        kr_0 = (Rs_0 * Rs_0 + Rp_0 * Rp_0) / 2.0f;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_2 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var Vh_0 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z))));
    var _S5 : f32 = Vh_0.x;
    var _S6 : f32 = Vh_0.y;
    var lensq_0 : f32 = _S5 * _S5 + _S6 * _S6;
    var T1_0 : vec3<f32>;
    if(lensq_0 > 0.0f)
    {
        var _S7 : vec3<f32> = vec3<f32>(- _S6, _S5, 0.0f);
        var _S8 : f32 = (inverseSqrt((lensq_0)));
        T1_0 = _S7 * vec3<f32>(_S8);
    }
    else
    {
        T1_0 = vec3<f32>(1.0f, 0.0f, 0.0f);
    }
    var r_0 : f32 = sqrt(U1_0);
    var phi_0 : f32 = 6.28318548202514648f * U2_0;
    var t1_0 : f32 = r_0 * cos(phi_0);
    var s_0 : f32 = 0.5f * (1.0f + Vh_0.z);
    var _S9 : f32 = 1.0f - t1_0 * t1_0;
    var t2_0 : f32 = s_0 * (r_0 * sin(phi_0)) + (1.0f - s_0) * sqrt(max(0.0f, _S9));
    var Nh_0 : vec3<f32> = vec3<f32>(t1_0) * T1_0 + vec3<f32>(t2_0) * cross(Vh_0, T1_0) + vec3<f32>(sqrt(max(0.0f, _S9 - t2_0 * t2_0))) * Vh_0;
    var _S10 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Nh_0.x, alpha_2 * Nh_0.y, max(0.0f, Nh_0.z)))));
    return _S10;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var r_1 : f32 = sqrt(random_1_0);
    var theta_0 : f32 = 6.28318548202514648f * random_2_0;
    var x_0 : f32 = r_1 * cos(theta_0);
    var z_0 : f32 = r_1 * sin(theta_0);
    return vec3<f32>(x_0, sqrt(max(0.0f, 1.0f - x_0 * x_0 - z_0 * z_0)), z_0);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var a_1 : vec3<f32>;
    if((abs(dot(n_0, a_0))) > 0.9999847412109375f)
    {
        a_1 = vec3<f32>(1.0f, 0.0f, 0.0f);
    }
    else
    {
        a_1 = a_0;
    }
    var tangent_0 : vec3<f32> = (normalize((cross(n_0, a_1))));
    return vec3<f32>(v_0.x) * tangent_0 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * cross(n_0, tangent_0);
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var a_3 : vec3<f32>;
    if((abs(dot(n_1, a_2))) > 0.9999847412109375f)
    {
        a_3 = vec3<f32>(1.0f, 0.0f, 0.0f);
    }
    else
    {
        a_3 = a_2;
    }
    var tangent_1 : vec3<f32> = (normalize((cross(n_1, a_3))));
    return vec3<f32>(dot(v_1, tangent_1), dot(v_1, n_1), dot(v_1, cross(n_1, tangent_1)));
}

fn hash( x_1 : u32) -> u32
{
    var _S11 : u32 = x_1 * u32(747796405) + u32(2891336453);
    var _S12 : u32 = ((((_S11 >> ((((_S11 >> (u32(28)))) + u32(4))))) ^ (_S11))) * u32(277803737);
    return (((_S12 >> (u32(22)))) ^ (_S12));
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S13 : Random;
    _S13.state = state_0;
    _S13.value = value_0;
    return _S13;
}

fn pcg( state_1 : u32) -> Random
{
    return Random_x24init_0(state_1 * u32(747796405) + u32(2891336453), f32(hash(state_1)) / 4.294967296e+09f);
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var random_h_1_0 : Random = pcg((*random_state_0));
    var random_h_2_0 : Random = pcg(random_h_1_0.state);
    (*random_state_0) = random_h_2_0.state;
    var v_tangent_0 : vec3<f32> = worldToTangent(v_2, n_i_0);
    var _S14 : vec3<f32> = sampleGGXVNDF(v_tangent_0.xzy, alpha_3, random_h_1_0.value, random_h_2_0.value);
    var _S15 : vec3<f32> = tangentToWorld(_S14.xzy, n_i_0);
    return _S15;
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S16 : f32 = b_0.x;
    var _S17 : f32;
    if(_S16 == 0.0f)
    {
        _S17 = 0.0f;
    }
    else
    {
        _S17 = a_4.x / _S16;
    }
    var _S18 : f32 = b_0.y;
    var _S19 : f32;
    if(_S18 == 0.0f)
    {
        _S19 = 0.0f;
    }
    else
    {
        _S19 = a_4.y / _S18;
    }
    var _S20 : f32 = b_0.z;
    var _S21 : f32;
    if(_S20 == 0.0f)
    {
        _S21 = 0.0f;
    }
    else
    {
        _S21 = a_4.z / _S20;
    }
    return vec3<f32>(_S17, _S19, _S21);
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    return hash((seed_0 ^ ((hash(index_0)))));
}

fn normal_distribution( state_2 : u32) -> Random
{
    var r1_0 : Random = pcg(state_2);
    var r2_0 : Random = pcg(r1_0.state);
    return Random_x24init_0(r2_0.state, sqrt(-2.0f * min(max(log(r2_0.value), -8.388607e+06f), 0.0f)) * cos(6.28318548202514648f * r1_0.value));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S22 : RandomSphere;
    _S22.state = state_3;
    _S22.value = value_1;
    return _S22;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var x_2 : Random = normal_distribution(state_4);
    var y_0 : Random = normal_distribution(x_2.state);
    var z_1 : Random = normal_distribution(y_0.state);
    var _S23 : vec3<f32> = (normalize((vec3<f32>(x_2.value, y_0.value, z_1.value))));
    return RandomSphere_x24init_0(z_1.state, _S23);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S24 : RandomHemisphere;
    _S24.state = state_5;
    _S24.value = value_2;
    return _S24;
}

fn random_hemisphere( state_6 : u32,  normal_0 : vec3<f32>) -> RandomHemisphere
{
    var random_sphere_0 : RandomSphere = random_sphere(state_6);
    if((dot(random_sphere_0.value, normal_0)) > 0.0f)
    {
        return RandomHemisphere_x24init_0(random_sphere_0.state, random_sphere_0.value);
    }
    else
    {
        return RandomHemisphere_x24init_0(random_sphere_0.state, (vec3<f32>(0) - random_sphere_0.value));
    }
}

