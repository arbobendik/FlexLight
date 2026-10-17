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
    return Random_x24init_0(state_1 * u32(747796405) + u32(2891336453), f32(hash(state_1)) / 4.294967296e+09f);
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
    var _S4 : RandomSphere;
    _S4.state = state_3;
    _S4.value = value_1;
    return _S4;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var x_1 : Random = normal_distribution(state_4);
    var y_0 : Random = normal_distribution(x_1.state);
    var z_0 : Random = normal_distribution(y_0.state);
    var _S5 : vec3<f32> = (normalize((vec3<f32>(x_1.value, y_0.value, z_0.value))));
    return RandomSphere_x24init_0(z_0.state, _S5);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S6 : RandomHemisphere;
    _S6.state = state_5;
    _S6.value = value_2;
    return _S6;
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

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn safeDivide( a_0 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S7 : f32 = b_0.x;
    var _S8 : f32;
    if(_S7 == 0.0f)
    {
        _S8 = 0.0f;
    }
    else
    {
        _S8 = a_0.x / _S7;
    }
    var _S9 : f32 = b_0.y;
    var _S10 : f32;
    if(_S9 == 0.0f)
    {
        _S10 = 0.0f;
    }
    else
    {
        _S10 = a_0.y / _S9;
    }
    var _S11 : f32 = b_0.z;
    var _S12 : f32;
    if(_S11 == 0.0f)
    {
        _S12 = 0.0f;
    }
    else
    {
        _S12 = a_0.z / _S11;
    }
    return vec3<f32>(_S8, _S10, _S12);
}

