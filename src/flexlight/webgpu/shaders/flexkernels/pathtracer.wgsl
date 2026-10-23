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

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S22 : f32 = alpha_1 * alpha_1;
    var _S23 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S22 + (1.0f - _S22) * n_dot_x_0 * n_dot_x_0));
    var _S24 : bool = alpha_1 > 0.0f;
    var _S25 : f32 = select(1.0f, _S23, _S24);
    return _S25;
}

fn G1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S26 : f32 = smithG1(alpha_2, n_dot_x_1);
    return _S26;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S27 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S28 : f32 = eta_i_0 / eta_o_0 * _S27;
    var _S29 : bool = _S28 < 1.0f;
    var kr_0 : f32;
    if(_S29)
    {
        var _S30 : f32 = sqrt(max(0.0f, 1.0f - _S28 * _S28));
        var _S31 : f32 = eta_o_0 * cos_theta_0;
        var _S32 : f32 = eta_i_0 * _S30;
        var _S33 : f32 = (_S31 - _S32) / (_S31 + _S32);
        var _S34 : f32 = eta_i_0 * cos_theta_0;
        var _S35 : f32 = eta_o_0 * _S30;
        var _S36 : f32 = (_S34 - _S35) / (_S34 + _S35);
        var _S37 : f32 = (_S33 * _S33 + _S36 * _S36) / 2.0f;
        kr_0 = _S37;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S38 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S39 : f32 = _S38.x;
    var _S40 : f32 = _S38.y;
    var _S41 : f32 = _S39 * _S39 + _S40 * _S40;
    const _S42 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S43 : vec3<f32> = vec3<f32>(- _S40, _S39, 0.0f);
    var _S44 : f32 = (inverseSqrt((_S41)));
    var _S45 : vec3<f32> = _S43 * vec3<f32>(_S44);
    var _S46 : bool = _S41 > 0.0f;
    var _S47 : vec3<f32> = select(_S42, _S45, _S46);
    var _S48 : vec3<f32> = cross(_S38, _S47);
    var _S49 : f32 = sqrt(U1_0);
    var _S50 : f32 = 6.28318548202514648f * U2_0;
    var _S51 : f32 = _S49 * cos(_S50);
    var t2_0 : f32 = _S49 * sin(_S50);
    var _S52 : f32 = 0.5f * (1.0f + _S38.z);
    var t2_1 : f32 = (1.0f - _S52) * sqrt(max(0.0f, 1.0f - _S51 * _S51)) + _S52 * t2_0;
    var _S53 : vec3<f32> = vec3<f32>(_S51) * _S47 + vec3<f32>(t2_1) * _S48;
    var _S54 : f32 = ((_S51));
    var _S55 : f32 = ((_S51));
    var _S56 : vec3<f32> = _S53 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S54 * _S55 - t2_1 * t2_1))) * _S38;
    var _S57 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S56.x, alpha_3 * _S56.y, max(0.0f, _S56.z)))));
    return _S57;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S58 : f32 = sqrt(random_1_0);
    var _S59 : f32 = 6.28318548202514648f * random_2_0;
    var _S60 : f32 = _S58 * cos(_S59);
    var _S61 : f32 = _S58 * sin(_S59);
    var _S62 : f32 = sqrt(max(0.0f, 1.0f - _S60 * _S60 - _S61 * _S61));
    return vec3<f32>(_S60, _S62, _S61);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S63 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S63)
    {
        const _S64 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S64;
    }
    else
    {
        a_1 = a_0;
    }
    var _S65 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S66 : vec3<f32> = cross(n_0, _S65);
    return vec3<f32>(v_0.x) * _S65 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S66;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S67 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S67)
    {
        const _S68 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S68;
    }
    else
    {
        a_3 = a_2;
    }
    var _S69 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S70 : vec3<f32> = cross(n_1, _S69);
    return vec3<f32>(dot(v_1, _S69), dot(v_1, n_1), dot(v_1, _S70));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S71 : vec3<f32> = p1_0 - p0_0;
    var _S72 : vec3<f32> = p2_0 - p0_0;
    var _S73 : vec2<f32> = uv1_0 - uv0_0;
    var _S74 : vec2<f32> = uv2_0 - uv0_0;
    var _S75 : f32 = _S73.x;
    var _S76 : f32 = _S74.y;
    var _S77 : f32 = _S73.y;
    var _S78 : f32 = _S74.x;
    var _S79 : f32 = _S75 * _S76 - _S77 * _S78;
    var _S80 : f32 = 1.0f / _S79;
    var _S81 : vec3<f32> = vec3<f32>(_S80);
    var t_0 : vec3<f32> = (_S71 * vec3<f32>(_S76) - _S72 * vec3<f32>(_S77)) * _S81;
    var _S82 : vec3<f32> = (_S72 * vec3<f32>(_S75) - _S71 * vec3<f32>(_S78)) * _S81;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S83 : bool = (dot(cross(n_2, t_1), _S82)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S83)
    {
        var _S84 : vec3<f32> = ((-(t_1)));
        t_2 = _S84;
    }
    else
    {
        t_2 = t_1;
    }
    var _S85 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S85, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_0 : vec3<f32>,  uvw_0 : vec3<f32>,  position_0 : vec3<f32>) -> f32
{
    var _S86 : vec3<f32> = t1_0 - t0_0;
    var _S87 : vec3<f32> = t2_2 - t0_0;
    var _S88 : vec3<f32> = t2_2 - t1_0;
    var _S89 : f32 = min(length(_S86), min(length(_S87), length(_S88)));
    var _S90 : vec3<f32> = vec3<f32>(distance(position_0, t0_0), distance(position_0, t1_0), distance(position_0, t2_2));
    var _S91 : vec3<f32> = (normalize((n0_0)));
    var _S92 : f32 = dot(geometry_n_0, _S91);
    var _S93 : vec3<f32> = (normalize((n1_0)));
    var _S94 : f32 = dot(geometry_n_0, _S93);
    var _S95 : vec3<f32> = (normalize((n2_0)));
    var _S96 : vec3<f32> = acos(abs(vec3<f32>(_S92, _S94, dot(geometry_n_0, _S95))));
    var _S97 : vec3<f32> = clamp(tan(_S96), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S90 * _S97, uvw_0), 0.0f, _S89 * 0.125f);
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S98 : Random = pcg((*random_state_0));
    var _S99 : Random = pcg(_S98.state);
    (*random_state_0) = _S99.state;
    var _S100 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S101 : vec3<f32> = sampleGGXVNDF(_S100.xzy, alpha_4, _S98.value, _S99.value);
    var _S102 : vec3<f32> = _S101.xzy;
    var _S103 : vec3<f32> = tangentToWorld(_S102, n_i_0);
    return _S103;
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
    var _S104 : BSDFLobes;
    _S104.v_dot_h = v_dot_h_0;
    _S104.n_dot_h = n_dot_h_1;
    _S104.refracted = refracted_0;
    _S104.F = F_0;
    _S104.F_greyscale = F_greyscale_0;
    _S104.reflect_weight = reflect_weight_0;
    _S104.diffuse_weight = diffuse_weight_0;
    _S104.refract_weight = refract_weight_0;
    _S104.p_diffuse = p_diffuse_0;
    _S104.p_reflect = p_reflect_0;
    _S104.p_refract = p_refract_0;
    return _S104;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S105 : f32 = dot(ggx_n_0, v_4);
    var _S106 : f32 = dot(n_i_1, ggx_n_0);
    var _S107 : f32 = eta_i_1 / eta_o_1;
    var _S108 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S107))));
    var _S109 : f32 = fresnel(abs(_S105), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S109)), (material_0.albedo), (material_0.metallic)));
    var _S110 : f32 = rgb_to_greyscale(F_1);
    var _S111 : f32 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic) * (1.0f - _S109);
    var _S112 : f32 = max(_S110, 0.0f);
    var _S113 : f32 = max(_S111, 0.0f);
    var _S114 : f32 = material_0.transmission * (1.0f - _S110);
    var _S115 : f32 = (sign((length(_S108))));
    var _S116 : f32 = max(_S114 * _S115, 0.0f);
    var _S117 : f32 = _S112 + _S113 + _S116;
    var _S118 : f32 = 1.0f / max(_S117, 0.0000152587890625f);
    var _S119 : f32 = _S113 * _S118;
    var _S120 : f32 = _S112 * _S118;
    var _S121 : f32 = _S116 * _S118;
    return BSDFLobes_x24init_0(_S105, _S106, _S108, F_1, _S110, 1.0f, _S111, material_0.transmission, _S119, _S120, _S121);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S122 : bool = lobe_0 == u32(0);
    if(_S122)
    {
        var _S123 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S124 : bool = n_i_dot_v_0 > 0.0f;
        var _S125 : f32 = select(0.0f, _S123, _S124);
        return _S125;
    }
    var _S126 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S127 : f32 = _S126 * lobes_0.v_dot_h;
    var _S128 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S129 : f32 = _S127 * _S128 / n_i_dot_v_0;
    var _S130 : bool = alpha_5 > 0.0f;
    var _S131 : bool;
    if(_S130)
    {
        _S131 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S131 = false;
    }
    if(_S131)
    {
        _S131 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S131 = false;
    }
    if(_S131)
    {
        _S131 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S131 = false;
    }
    var _S132 : f32 = select(0.0f, _S129, _S131);
    var _S133 : bool = lobe_0 == u32(1);
    if(_S133)
    {
        var _S134 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S135 : f32 = lobes_0.p_refract * _S132 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S134 * _S134);
        var _S136 : bool = eta_i_2 != eta_o_2;
        if(_S136)
        {
            _S131 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S131 = false;
        }
        var _S137 : f32 = select(0.0f, _S135, _S131);
        return _S137;
    }
    var _S138 : f32 = lobes_0.p_reflect * _S132 / (4.0f * lobes_0.v_dot_h);
    var _S139 : bool = _S132 > 0.0f;
    var _S140 : f32 = select(0.0f, _S138, _S139);
    return _S140;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S141 : bool = lobe_1 == u32(0);
    if(_S141)
    {
        return vec3<f32>(lobes_1.diffuse_weight) * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S142 : bool = lobe_1 == u32(1);
    if(_S142)
    {
        var _S143 : f32 = - dot(n_i_2, l_0);
        var _S144 : f32 = G1(alpha_6, max(_S143, 0.0f));
        return vec3<f32>((lobes_1.refract_weight * _S144 * (1.0f - lobes_1.F_greyscale))) * material_1.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S145 : f32 = dot(n_i_2, l_0);
    var _S146 : f32 = G1(alpha_6, max(_S145, 0.0f));
    return vec3<f32>((lobes_1.reflect_weight * _S146)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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
    var _S147 : SampleBSDF;
    _S147.unit_direction = unit_direction_0;
    _S147.throughput = throughput_0;
    _S147.random_state = random_state_1;
    _S147.refracted = refracted_1;
    _S147.lobe = lobe_2;
    _S147.pdf = pdf_0;
    return _S147;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S148 : vec3<f32> = ((-(in_dir_1)));
    var _S149 : f32 = dot(n_3, _S148);
    var _S150 : f32 = (sign((_S149)));
    var _S151 : vec3<f32> = n_3 * vec3<f32>(_S150);
    var _S152 : f32 = material_2.roughness;
    var _S153 : f32 = _S152 * _S152;
    var _S154 : vec3<f32> = (normalize((_S148 + out_dir_0)));
    var _S155 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S155)
    {
        var _S156 : vec3<f32> = sampleHalfVector(_S148, _S151, _S153, &(random_state_2));
        ggx_n_1 = _S156;
    }
    else
    {
        var _S157 : bool = lobe_3 == u32(1);
        if(_S157)
        {
            var _S158 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S148 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S159 : vec3<f32> = (normalize((_S158)));
            var _S160 : f32 = (sign((dot(_S158, _S151))));
            var _S161 : vec3<f32> = _S159 * vec3<f32>(_S160);
            ggx_n_1 = _S161;
        }
        else
        {
            ggx_n_1 = _S154;
        }
    }
    var _S162 : BSDFLobes = bsdfLobes(in_dir_1, _S148, _S151, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S163 : f32 = lobeDensity(dot(_S151, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S149), _S153, _S162, eta_i_3, eta_o_3, lobe_3);
    var _S164 : bool = !(_S163 > 0.0f);
    if(_S164)
    {
        var _S165 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S165, _S165, u32(0), false, u32(0), 0.0f);
    }
    var _S166 : vec3<f32> = lobeThroughput(out_dir_0, _S151, _S153, material_2, _S162, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S166, random_state_2, lobe_3 == u32(1), lobe_3, _S163);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S167 : vec3<f32> = ((-(in_dir_2)));
    var _S168 : bool = (dot(g_n_0, _S167) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S168)
    {
        var _S169 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S170 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S169.throughput * vec3<f32>(_S169.pdf) + _S170.throughput * vec3<f32>(_S170.pdf);
    }
    var _S171 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S171.throughput * vec3<f32>(_S171.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S172 : vec3<f32> = ((-(in_dir_3)));
    var _S173 : f32 = dot(n_5, _S172);
    var _S174 : f32 = (sign((_S173)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S174);
    var _S175 : f32 = abs(_S173);
    var _S176 : f32 = material_4.roughness;
    var _S177 : f32 = _S176 * _S176;
    var _S178 : vec3<f32> = sampleHalfVector(_S172, n_i_3, _S177, &(random_state_4));
    var _S179 : BSDFLobes = bsdfLobes(in_dir_3, _S172, n_i_3, _S178, material_4, eta_i_5, eta_o_5);
    var _S180 : vec3<f32> = vec3<f32>(1.0f);
    var _S181 : SampleBSDF = SampleBSDF_x24init_0(_S180, _S180, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S181;
    var _S182 : Random = pcg(random_state_4);
    random_state_4 = _S182.state;
    var _S183 : bool = (_S182.value) < (_S179.p_diffuse);
    if(_S183)
    {
        var _S184 : Random = pcg(random_state_4);
        var _S185 : Random = pcg(_S184.state);
        sample_0.random_state = _S185.state;
        var _S186 : vec3<f32> = sampleCosWeightedHemisphere(_S184.value, _S185.value);
        var _S187 : vec3<f32> = tangentToWorld(_S186, n_i_3);
        sample_0.unit_direction = _S187;
        var _S188 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S177, material_4, _S179, u32(0));
        sample_0.throughput = _S188;
        var _S189 : f32 = lobeDensity(_S186.y, 0.0f, _S175, _S177, _S179, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S189;
        return sample_0;
    }
    var _S190 : bool = (_S182.value) < (_S179.p_diffuse + _S179.p_refract);
    if(_S190)
    {
        sample_0.unit_direction = _S179.refracted;
        var _S191 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S178), _S175, _S177, _S179, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S191;
        var _S192 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S177, material_4, _S179, u32(1));
        sample_0.throughput = _S192;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S193 : vec3<f32> = (normalize((reflect(in_dir_3, _S178))));
    sample_0.unit_direction = _S193;
    var _S194 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S177, material_4, _S179, u32(2));
    sample_0.throughput = _S194;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S195 : f32 = lobeDensity(0.0f, 0.0f, _S175, _S177, _S179, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S195;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S196 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S196));
}

fn samplesLights( material_5 : Material) -> bool
{
    var _S197 : bool = (material_5.roughness) > 0.0f;
    var _S198 : bool;
    if(_S197)
    {
        _S198 = true;
    }
    else
    {
        var _S199 : bool = (material_5.metallic) < 1.0f;
        if(_S199)
        {
            _S198 = (material_5.transmission) < 1.0f;
        }
        else
        {
            _S198 = false;
        }
    }
    return _S198;
}

fn neeBSDF( in_dir_4 : vec3<f32>,  dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_5 : u32) -> vec3<f32>
{
    var _S200 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S200;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S201 : bool = (lobe_4 == u32(1)) == refracted_2;
        var f_1 : vec3<f32>;
        if(_S201)
        {
            var _S202 : SampleBSDF = connectBSDF(in_dir_4, dir_0, n_6, material_6, eta_i_6, eta_o_6, lobe_4, random_state_5);
            var _S203 : bool = (_S202.pdf) > 0.0f;
            if(_S203)
            {
                if(power_0)
                {
                    var _S204 : f32 = _S202.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S202.throughput * vec3<f32>(_S202.pdf) / vec3<f32>((pdf_1 * (1.0f + _S204 * _S204)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S202.throughput * vec3<f32>(_S202.pdf) / vec3<f32>((_S202.pdf + pdf_1));
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
    var _S205 : f32 = rgb_to_greyscale(material_7.albedo * vec3<f32>(material_7.metallic));
    var _S206 : f32 = material_7.roughness;
    var _S207 : f32 = G1(_S206 * _S206, abs(dot(n_7, dir_1)));
    return vec3<f32>((material_7.transmission * _S207 * (1.0f - _S205))) * material_7.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S208 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S208 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_8 : vec3<f32>,  material_8 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S209 : vec3<f32>;
    if((material_8.ior) == 1.0f)
    {
        var _S210 : vec3<f32> = straightThrough(toward_0, n_8, material_8);
        _S209 = _S210;
    }
    else
    {
        _S209 = vec3<f32>(0.0f);
    }
    return _S209 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S211 : u32 = hash(index_0);
    var _S212 : u32 = hash((seed_0 ^ (_S211)));
    return _S212;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S213 : vec3<f32> = a_4 / b_0;
    var _S214 : vec3<f32> = vec3<f32>(0.0f);
    var _S215 : vec3<bool> = b_0 == _S214;
    var _S216 : vec3<f32> = select(_S213, _S214, _S215);
    return _S216;
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
    var _S217 : f32 = rgb_to_greyscale(weight_0);
    var _S218 : bool = _S217 > 0.0f;
    var _S219 : bool;
    if(_S218)
    {
        _S219 = _S217 < 3.00000000549775576e+38f;
    }
    else
    {
        _S219 = false;
    }
    var _S220 : bool = !_S219;
    if(_S220)
    {
        return;
    }
    var _S221 : f32 = (*sel_0).w_sum + _S217;
    (*sel_0).w_sum = _S221;
    var _S222 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S222;
    var _S223 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S223.state;
    var _S224 : bool = (_S223.value * (*sel_0).w_sum) <= _S217;
    if(_S224)
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
    var _S225 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S225;
    var _S226 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S226;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S227 : f32 = rgb_to_greyscale(r_1.f);
    var _S228 : f32 = sel_2.w_sum / _S227;
    var _S229 : bool = _S227 > 0.0f;
    var _S230 : f32 = select(0.0f, _S228, _S229);
    r_1.w = _S230;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S231 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S232 : u32 = (insertBits((_S231), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S232;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S233 : bool = transmission_0 > 0.0f;
    var _S234 : bool;
    if(_S233)
    {
        _S234 = true;
    }
    else
    {
        _S234 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S235 : f32;
    if(_S234)
    {
        _S235 = 1.0f;
    }
    else
    {
        _S235 = -1.0f;
    }
    return _S235;
}

fn geometryDensity( geometry_n_1 : vec3<f32>,  direction_1 : vec3<f32>,  distance_1 : f32) -> f32
{
    return abs(dot(geometry_n_1, direction_1)) / (distance_1 * distance_1);
}

fn footprintThreshold( geometry_density_0 : f32) -> f32
{
    return 0.00251327408477664f / geometry_density_0;
}

fn withinFootprint( open_0 : bool,  prev_rough_0 : bool,  prev_pdf_0 : f32,  geometry_density_1 : f32,  threshold_0 : f32) -> bool
{
    var _S236 : bool;
    if(open_0)
    {
        _S236 = prev_rough_0;
    }
    else
    {
        _S236 = false;
    }
    if(_S236)
    {
        _S236 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S236 = false;
    }
    return _S236;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S237 : bool = pdf_2 > 0.0f;
    var _S238 : bool;
    if(_S237)
    {
        if(diffuse_0)
        {
            _S238 = true;
        }
        else
        {
            _S238 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S238 = false;
    }
    return _S238;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S239 : bool = pdf_3 > 0.0f;
    var _S240 : bool;
    if(_S239)
    {
        if(diffuse_1)
        {
            _S240 = true;
        }
        else
        {
            _S240 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S240 = false;
    }
    return _S240;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S241 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S241.x, max(_S241.y, _S241.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S242 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S242;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S243 : f32 = c_1 * p_c_0;
    var _S244 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S243 / (_S243 + c_t_0 * g_previous_0), _S244 / (_S244 + c_1 * g_current_0));
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
    var _S245 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S246 : bool = cos_a_0 > cos_b_0;
    var _S247 : f32 = select(_S245, 1.0f, _S246);
    return _S247;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S248 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S249 : bool = cos_a_1 > cos_b_1;
    var _S250 : f32 = select(_S248, 0.0f, _S249);
    return _S250;
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
    var _S251 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S252 : vec3<f32> = node_0.high - node_0.low;
    var _S253 : vec3<f32> = p_0 - _S251;
    var _S254 : vec3<f32> = (normalize((_S253)));
    var _S255 : f32 = dot(_S253, _S253);
    var _S256 : f32 = dot(_S252, _S252) / 4.0f;
    var _S257 : f32 = abs(dot(node_0.w, _S254));
    var _S258 : f32 = sine(node_0.cos_theta_o);
    var _S259 : f32 = sqrt(max(1.0f - _S256 / _S255, 0.0f));
    var _S260 : bool = _S255 < _S256;
    var _S261 : f32 = select(_S259, -1.0f, _S260);
    var _S262 : f32 = sine(_S261);
    var _S263 : f32 = sine(_S257);
    var _S264 : f32 = cosSubClamped(_S263, _S257, _S258, node_0.cos_theta_o);
    var _S265 : f32 = sine(_S257);
    var _S266 : f32 = sinSubClamped(_S265, _S257, _S258, node_0.cos_theta_o);
    var _S267 : f32 = cosSubClamped(_S266, _S264, _S262, _S261);
    var _S268 : bool = _S267 <= 0.0f;
    if(_S268)
    {
        return 0.0f;
    }
    var _S269 : f32 = - dot(_S254, normal_1);
    var _S270 : f32 = node_0.phi * _S267 / max(_S255, length(_S252) / 2.0f);
    var _S271 : f32 = sine(_S269);
    var _S272 : f32 = cosSubClamped(_S271, _S269, _S262, _S261);
    var _S273 : bool = (dot(normal_1, normal_1)) == 0.0f;
    var _S274 : f32 = select(_S272, 1.0f, _S273);
    return max(_S270 * _S274, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_2, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S275 : f32 = importance(first_0, p_1, normal_3);
    var _S276 : f32 = importance(second_0, p_1, normal_3);
    var _S277 : vec2<f32> = vec2<f32>(_S275, _S276);
    var _S278 : bool = _S275 == 0.0f;
    var _S279 : bool;
    if(_S278)
    {
        _S279 = _S276 == 0.0f;
    }
    else
    {
        _S279 = false;
    }
    if(_S279)
    {
        return u32(2);
    }
    var _S280 : f32 = _S275 + _S276;
    var _S281 : bool = _S276 > 0.0f;
    if(_S281)
    {
        _S279 = ((*pick_0) * _S280) >= _S275;
    }
    else
    {
        _S279 = false;
    }
    var _S282 : u32 = select(u32(0), u32(1), _S279);
    var _S283 : f32 = min(((*pick_0) * _S280 - f32(_S282) * _S275) / _S277[_S282], 0.99999994039535522f);
    (*pick_0) = _S283;
    var _S284 : f32 = (*probability_1) * (_S277[_S282] / _S280);
    (*probability_1) = _S284;
    return _S282;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_4 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S285 : f32 = importance(first_1, p_2, normal_4);
    var _S286 : f32 = importance(second_1, p_2, normal_4);
    var _S287 : vec2<f32> = vec2<f32>(_S285, _S286);
    var _S288 : f32 = _S287[child_0] / (_S285 + _S286);
    var _S289 : bool = (_S287[child_0]) > 0.0f;
    var _S290 : f32 = select(0.0f, _S288, _S289);
    return _S290;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S291 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S292 : bool = b_1 > 0.0f;
    var _S293 : f32 = select(1.0f, _S291, _S292);
    return _S293;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S294 : vec3<f32> = center_0 - p_3;
    var _S295 : f32 = radius_1 * radius_1 / dot(_S294, _S294);
    var _S296 : bool = _S295 >= 1.0f;
    if(_S296)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S295)) / (6.28318548202514648f * _S295);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S297 : vec3<f32> = center_1 - p_4;
    var _S298 : f32 = radius_2 * radius_2 / dot(_S297, _S297);
    var _S299 : f32 = u1_0 * _S298 / (1.0f + sqrt(max(1.0f - _S298, 0.0f)));
    var _S300 : f32 = 2.0f * u1_0;
    var _S301 : bool = _S298 >= 1.0f;
    var _S302 : f32 = select(_S299, _S300, _S301);
    var _S303 : f32 = sqrt(max(_S302 * (2.0f - _S302), 0.0f));
    var _S304 : f32 = 6.28318548202514648f * u2_0;
    var _S305 : vec3<f32> = vec3<f32>(_S303 * cos(_S304), 1.0f - _S302, _S303 * sin(_S304));
    var _S306 : vec3<f32> = (normalize((_S297)));
    var _S307 : vec3<f32> = tangentToWorld(_S305, _S306);
    return _S307;
}

