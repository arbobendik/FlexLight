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

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S15 : f32 = alpha_0 * alpha_0;
    var _S16 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S15 * n_dot_h_0 * n_dot_h_0;
    return _S15 / max(3.14159274101257324f * _S16 * _S16, 1.17549435082228751e-38f);
}

fn G1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S17 : f32 = alpha_1 * 0.5f;
    return n_dot_x_0 / max(n_dot_x_0 * (1.0f - _S17) + _S17, 0.0000152587890625f);
}

fn smithG1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S18 : f32 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + sqrt(_S18 + (1.0f - _S18) * n_dot_x_1 * n_dot_x_1));
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S19 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S20 : f32 = eta_i_0 / eta_o_0 * _S19;
    var _S21 : bool = _S20 < 1.0f;
    var kr_0 : f32;
    if(_S21)
    {
        var _S22 : f32 = sqrt(max(0.0f, 1.0f - _S20 * _S20));
        var _S23 : f32 = eta_o_0 * cos_theta_0;
        var _S24 : f32 = eta_i_0 * _S22;
        var _S25 : f32 = (_S23 - _S24) / (_S23 + _S24);
        var _S26 : f32 = eta_i_0 * cos_theta_0;
        var _S27 : f32 = eta_o_0 * _S22;
        var _S28 : f32 = (_S26 - _S27) / (_S26 + _S27);
        var _S29 : f32 = (_S25 * _S25 + _S28 * _S28) / 2.0f;
        kr_0 = _S29;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S30 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S31 : f32 = _S30.x;
    var _S32 : f32 = _S30.y;
    var _S33 : f32 = _S31 * _S31 + _S32 * _S32;
    const _S34 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S35 : vec3<f32> = vec3<f32>(- _S32, _S31, 0.0f);
    var _S36 : f32 = (inverseSqrt((_S33)));
    var _S37 : vec3<f32> = _S35 * vec3<f32>(_S36);
    var _S38 : bool = _S33 > 0.0f;
    var _S39 : vec3<f32> = select(_S34, _S37, _S38);
    var _S40 : vec3<f32> = cross(_S30, _S39);
    var _S41 : f32 = sqrt(U1_0);
    var _S42 : f32 = 6.28318548202514648f * U2_0;
    var _S43 : f32 = _S41 * cos(_S42);
    var t2_0 : f32 = _S41 * sin(_S42);
    var _S44 : f32 = 0.5f * (1.0f + _S30.z);
    var t2_1 : f32 = (1.0f - _S44) * sqrt(max(0.0f, 1.0f - _S43 * _S43)) + _S44 * t2_0;
    var _S45 : vec3<f32> = vec3<f32>(_S43) * _S39 + vec3<f32>(t2_1) * _S40;
    var _S46 : f32 = ((_S43));
    var _S47 : f32 = ((_S43));
    var _S48 : vec3<f32> = _S45 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S46 * _S47 - t2_1 * t2_1))) * _S30;
    var _S49 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S48.x, alpha_3 * _S48.y, max(0.0f, _S48.z)))));
    return _S49;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S50 : f32 = sqrt(random_1_0);
    var _S51 : f32 = 6.28318548202514648f * random_2_0;
    var _S52 : f32 = _S50 * cos(_S51);
    var _S53 : f32 = _S50 * sin(_S51);
    var _S54 : f32 = sqrt(max(0.0f, 1.0f - _S52 * _S52 - _S53 * _S53));
    return vec3<f32>(_S52, _S54, _S53);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S55 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S55)
    {
        const _S56 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S56;
    }
    else
    {
        a_1 = a_0;
    }
    var _S57 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S58 : vec3<f32> = cross(n_0, _S57);
    return vec3<f32>(v_0.x) * _S57 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S58;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S59 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S59)
    {
        const _S60 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S60;
    }
    else
    {
        a_3 = a_2;
    }
    var _S61 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S62 : vec3<f32> = cross(n_1, _S61);
    return vec3<f32>(dot(v_1, _S61), dot(v_1, n_1), dot(v_1, _S62));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S63 : vec3<f32> = p1_0 - p0_0;
    var _S64 : vec3<f32> = p2_0 - p0_0;
    var _S65 : vec2<f32> = uv1_0 - uv0_0;
    var _S66 : vec2<f32> = uv2_0 - uv0_0;
    var _S67 : f32 = _S65.x;
    var _S68 : f32 = _S66.y;
    var _S69 : f32 = _S65.y;
    var _S70 : f32 = _S66.x;
    var _S71 : f32 = _S67 * _S68 - _S69 * _S70;
    var _S72 : f32 = 1.0f / _S71;
    var _S73 : vec3<f32> = vec3<f32>(_S72);
    var t_0 : vec3<f32> = (_S63 * vec3<f32>(_S68) - _S64 * vec3<f32>(_S69)) * _S73;
    var _S74 : vec3<f32> = (_S64 * vec3<f32>(_S67) - _S63 * vec3<f32>(_S70)) * _S73;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S75 : bool = (dot(cross(n_2, t_1), _S74)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S75)
    {
        var _S76 : vec3<f32> = ((-(t_1)));
        t_2 = _S76;
    }
    else
    {
        t_2 = t_1;
    }
    var _S77 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S77, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_0 : vec3<f32>,  uvw_0 : vec3<f32>,  position_0 : vec3<f32>) -> f32
{
    var _S78 : vec3<f32> = t1_0 - t0_0;
    var _S79 : vec3<f32> = t2_2 - t0_0;
    var _S80 : vec3<f32> = t2_2 - t1_0;
    var _S81 : f32 = min(length(_S78), min(length(_S79), length(_S80)));
    var _S82 : vec3<f32> = vec3<f32>(distance(position_0, t0_0), distance(position_0, t1_0), distance(position_0, t2_2));
    var _S83 : vec3<f32> = (normalize((n0_0)));
    var _S84 : f32 = dot(geometry_n_0, _S83);
    var _S85 : vec3<f32> = (normalize((n1_0)));
    var _S86 : f32 = dot(geometry_n_0, _S85);
    var _S87 : vec3<f32> = (normalize((n2_0)));
    var _S88 : vec3<f32> = acos(abs(vec3<f32>(_S84, _S86, dot(geometry_n_0, _S87))));
    var _S89 : vec3<f32> = clamp(tan(_S88), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S82 * _S89, uvw_0), 0.0f, _S81 * 0.125f);
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S90 : Random = pcg((*random_state_0));
    var _S91 : Random = pcg(_S90.state);
    (*random_state_0) = _S91.state;
    var _S92 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S93 : vec3<f32> = sampleGGXVNDF(_S92.xzy, alpha_4, _S90.value, _S91.value);
    var _S94 : vec3<f32> = _S93.xzy;
    var _S95 : vec3<f32> = tangentToWorld(_S94, n_i_0);
    return _S95;
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
    var _S96 : BSDFLobes;
    _S96.v_dot_h = v_dot_h_0;
    _S96.n_dot_h = n_dot_h_1;
    _S96.refracted = refracted_0;
    _S96.F = F_0;
    _S96.F_greyscale = F_greyscale_0;
    _S96.reflect_weight = reflect_weight_0;
    _S96.diffuse_weight = diffuse_weight_0;
    _S96.refract_weight = refract_weight_0;
    _S96.p_diffuse = p_diffuse_0;
    _S96.p_reflect = p_reflect_0;
    _S96.p_refract = p_refract_0;
    return _S96;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S97 : f32 = dot(ggx_n_0, v_4);
    var _S98 : f32 = dot(n_i_1, ggx_n_0);
    var _S99 : f32 = eta_i_1 / eta_o_1;
    var _S100 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S99))));
    var _S101 : f32 = fresnel(abs(_S97), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S101)), (material_0.albedo), (material_0.metallic)));
    var _S102 : f32 = rgb_to_greyscale(F_1);
    var _S103 : f32 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    var _S104 : f32 = max(_S102, 0.0f);
    var _S105 : f32 = 1.0f - _S102;
    var _S106 : f32 = max(_S103 * _S105, 0.0f);
    var _S107 : f32 = material_0.transmission * _S105;
    var _S108 : f32 = (sign((length(_S100))));
    var _S109 : f32 = max(_S107 * _S108, 0.0f);
    var _S110 : f32 = _S104 + _S106 + _S109;
    var _S111 : f32 = 1.0f / max(_S110, 0.0000152587890625f);
    var _S112 : f32 = _S106 * _S111;
    var _S113 : f32 = _S104 * _S111;
    var _S114 : f32 = _S109 * _S111;
    return BSDFLobes_x24init_0(_S97, _S98, _S100, F_1, _S102, 1.0f, _S103, material_0.transmission, _S112, _S113, _S114);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S115 : bool = lobe_0 == u32(0);
    if(_S115)
    {
        var _S116 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S117 : bool = n_i_dot_v_0 > 0.0f;
        var _S118 : f32 = select(0.0f, _S116, _S117);
        return _S118;
    }
    var _S119 : f32 = smithG1(alpha_5, n_i_dot_v_0);
    var _S120 : f32 = _S119 * lobes_0.v_dot_h;
    var _S121 : f32 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    var _S122 : f32 = _S120 * _S121 / n_i_dot_v_0;
    var _S123 : bool = alpha_5 > 0.0f;
    var _S124 : bool;
    if(_S123)
    {
        _S124 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    if(_S124)
    {
        _S124 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    if(_S124)
    {
        _S124 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    var _S125 : f32 = select(0.0f, _S122, _S124);
    var _S126 : bool = lobe_0 == u32(1);
    if(_S126)
    {
        var _S127 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S128 : f32 = lobes_0.p_refract * _S125 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S127 * _S127);
        var _S129 : bool = eta_i_2 != eta_o_2;
        if(_S129)
        {
            _S124 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S124 = false;
        }
        var _S130 : f32 = select(0.0f, _S128, _S124);
        return _S130;
    }
    var _S131 : f32 = lobes_0.p_reflect * _S125 / (4.0f * lobes_0.v_dot_h);
    var _S132 : bool = _S125 > 0.0f;
    var _S133 : f32 = select(0.0f, _S131, _S132);
    return _S133;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_1 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S134 : bool = lobe_1 == u32(0);
    if(_S134)
    {
        return vec3<f32>(lobes_1.diffuse_weight) * material_1.albedo / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S135 : bool = lobe_1 == u32(1);
    if(_S135)
    {
        var _S136 : f32 = - dot(n_i_2, l_0);
        var _S137 : f32 = G1(alpha_6, max(_S136, 0.0f));
        return vec3<f32>((lobes_1.refract_weight * _S137 * (1.0f - lobes_1.F_greyscale))) * material_1.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S138 : f32 = dot(n_i_2, l_0);
    var _S139 : f32 = G1(alpha_6, max(_S138, 0.0f));
    return vec3<f32>((lobes_1.reflect_weight * _S139)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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
    var _S140 : SampleBSDF;
    _S140.unit_direction = unit_direction_0;
    _S140.throughput = throughput_0;
    _S140.random_state = random_state_1;
    _S140.refracted = refracted_1;
    _S140.lobe = lobe_2;
    _S140.pdf = pdf_0;
    return _S140;
}

fn lobeBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_2 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S141 : vec3<f32> = ((-(in_dir_1)));
    var _S142 : f32 = dot(n_3, _S141);
    var _S143 : f32 = (sign((_S142)));
    var _S144 : vec3<f32> = n_3 * vec3<f32>(_S143);
    var _S145 : f32 = material_2.roughness;
    var _S146 : f32 = _S145 * _S145;
    var _S147 : vec3<f32> = _S141 + out_dir_0;
    var _S148 : vec3<f32> = (normalize((_S147)));
    var _S149 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S149)
    {
        var _S150 : vec3<f32> = sampleHalfVector(_S141, _S144, _S146, &(random_state_2));
        ggx_n_1 = _S150;
    }
    else
    {
        ggx_n_1 = _S148;
    }
    var _S151 : bool = lobe_3 == u32(1);
    if(_S151)
    {
        var _S152 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S141 + vec3<f32>(eta_o_3) * out_dir_0)));
        var _S153 : vec3<f32> = (normalize((_S152)));
        var _S154 : f32 = (sign((dot(_S152, _S144))));
        var _S155 : vec3<f32> = _S153 * vec3<f32>(_S154);
        ggx_n_1 = _S155;
    }
    var _S156 : bool = lobe_3 == u32(2);
    if(_S156)
    {
        var _S157 : vec3<f32> = (normalize((_S147)));
        ggx_n_1 = _S157;
    }
    var _S158 : BSDFLobes = bsdfLobes(in_dir_1, _S141, _S144, ggx_n_1, material_2, eta_i_3, eta_o_3);
    var _S159 : f32 = lobeDensity(dot(_S144, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S142), _S146, _S158, eta_i_3, eta_o_3, lobe_3);
    var _S160 : bool = !(_S159 > 0.0f);
    if(_S160)
    {
        var _S161 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S161, _S161, u32(0), false, u32(0), 0.0f);
    }
    var _S162 : vec3<f32> = lobeThroughput(out_dir_0, _S144, _S146, material_2, _S158, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S162, random_state_2, _S151, lobe_3, _S159);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_4 : vec3<f32>,  g_n_0 : vec3<f32>,  material_3 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S163 : vec3<f32> = ((-(in_dir_2)));
    var _S164 : bool = (dot(g_n_0, _S163) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S164)
    {
        var _S165 : SampleBSDF = lobeBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S166 : SampleBSDF = lobeBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S165.throughput * vec3<f32>(_S165.pdf) + _S166.throughput * vec3<f32>(_S166.pdf);
    }
    var _S167 : SampleBSDF = lobeBSDF(in_dir_2, out_dir_1, n_4, material_3, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S167.throughput * vec3<f32>(_S167.pdf);
}

fn sampleBSDF( in_dir_3 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_4 : u32 = random_init_1;
    var _S168 : vec3<f32> = ((-(in_dir_3)));
    var _S169 : f32 = dot(n_5, _S168);
    var _S170 : f32 = (sign((_S169)));
    var n_i_3 : vec3<f32> = n_5 * vec3<f32>(_S170);
    var _S171 : f32 = abs(_S169);
    var _S172 : f32 = material_4.roughness;
    var _S173 : f32 = _S172 * _S172;
    var _S174 : vec3<f32> = sampleHalfVector(_S168, n_i_3, _S173, &(random_state_4));
    var _S175 : BSDFLobes = bsdfLobes(in_dir_3, _S168, n_i_3, _S174, material_4, eta_i_5, eta_o_5);
    var _S176 : vec3<f32> = vec3<f32>(1.0f);
    var _S177 : SampleBSDF = SampleBSDF_x24init_0(_S176, _S176, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S177;
    var _S178 : Random = pcg(random_state_4);
    random_state_4 = _S178.state;
    var _S179 : bool = (_S178.value) < (_S175.p_diffuse);
    if(_S179)
    {
        var _S180 : Random = pcg(random_state_4);
        var _S181 : Random = pcg(_S180.state);
        sample_0.random_state = _S181.state;
        var _S182 : vec3<f32> = sampleCosWeightedHemisphere(_S180.value, _S181.value);
        var _S183 : vec3<f32> = tangentToWorld(_S182, n_i_3);
        sample_0.unit_direction = _S183;
        var _S184 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S173, material_4, _S175, u32(0));
        sample_0.throughput = _S184;
        var _S185 : f32 = lobeDensity(_S182.y, 0.0f, _S171, _S173, _S175, eta_i_5, eta_o_5, u32(0));
        sample_0.pdf = _S185;
        return sample_0;
    }
    var _S186 : bool = (_S178.value) < (_S175.p_diffuse + _S175.p_refract);
    if(_S186)
    {
        sample_0.unit_direction = _S175.refracted;
        var _S187 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S174), _S171, _S173, _S175, eta_i_5, eta_o_5, u32(1));
        sample_0.pdf = _S187;
        var _S188 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S173, material_4, _S175, u32(1));
        sample_0.throughput = _S188;
        sample_0.random_state = random_state_4;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S189 : vec3<f32> = (normalize((reflect(in_dir_3, _S174))));
    sample_0.unit_direction = _S189;
    var _S190 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S173, material_4, _S175, u32(2));
    sample_0.throughput = _S190;
    sample_0.random_state = random_state_4;
    sample_0.lobe = u32(2);
    var _S191 : f32 = lobeDensity(0.0f, 0.0f, _S171, _S173, _S175, eta_i_5, eta_o_5, u32(2));
    sample_0.pdf = _S191;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S192 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S192));
}

fn neeDecision( material_5 : Material,  n_dot_v_0 : f32,  eta_i_6 : f32,  eta_o_6 : f32) -> bool
{
    var _S193 : f32 = fresnel(abs(n_dot_v_0), eta_i_6, eta_o_6);
    var _S194 : vec3<f32> = (mix((vec3<f32>(_S193)), (material_5.albedo), (material_5.metallic)));
    var _S195 : f32 = rgb_to_greyscale(_S194);
    var _S196 : f32 = max((1.0f - _S195) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission), 0.0f);
    var _S197 : bool = _S196 > 0.03999999910593033f;
    var _S198 : bool;
    if(_S197)
    {
        _S198 = true;
    }
    else
    {
        _S198 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S198;
}

fn neeBSDF( in_dir_4 : vec3<f32>,  dir_0 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_5 : u32) -> vec3<f32>
{
    var _S199 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S199;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S200 : bool = (lobe_4 == u32(1)) == refracted_2;
        var f_1 : vec3<f32>;
        if(_S200)
        {
            var _S201 : SampleBSDF = lobeBSDF(in_dir_4, dir_0, n_6, material_6, eta_i_7, eta_o_7, lobe_4, random_state_5);
            var _S202 : bool = (_S201.pdf) > 0.0f;
            if(_S202)
            {
                if(power_0)
                {
                    var _S203 : f32 = _S201.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S201.throughput * vec3<f32>(_S201.pdf) / vec3<f32>((pdf_1 * (1.0f + _S203 * _S203)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S201.throughput * vec3<f32>(_S201.pdf) / vec3<f32>((_S201.pdf + pdf_1));
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
    var _S204 : f32 = rgb_to_greyscale(material_7.albedo * vec3<f32>(material_7.metallic));
    var _S205 : f32 = material_7.roughness;
    var _S206 : f32 = G1(_S205 * _S205, abs(dot(n_7, dir_1)));
    return vec3<f32>((material_7.transmission * _S206 * (1.0f - _S204))) * material_7.albedo;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S207 : u32 = hash(index_0);
    var _S208 : u32 = hash((seed_0 ^ (_S207)));
    return _S208;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S209 : vec3<f32> = a_4 / b_0;
    var _S210 : vec3<f32> = vec3<f32>(0.0f);
    var _S211 : vec3<bool> = b_0 == _S210;
    var _S212 : vec3<f32> = select(_S209, _S210, _S211);
    return _S212;
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
    var _S213 : f32 = rgb_to_greyscale(weight_0);
    var _S214 : bool = _S213 > 0.0f;
    var _S215 : bool;
    if(_S214)
    {
        _S215 = _S213 < 3.00000000549775576e+38f;
    }
    else
    {
        _S215 = false;
    }
    var _S216 : bool = !_S215;
    if(_S216)
    {
        return;
    }
    var _S217 : f32 = (*sel_0).w_sum + _S213;
    (*sel_0).w_sum = _S217;
    var _S218 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S218;
    var _S219 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S219.state;
    var _S220 : bool = (_S219.value * (*sel_0).w_sum) <= _S213;
    if(_S220)
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
    var _S221 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S221;
    var _S222 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S222;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S223 : f32 = rgb_to_greyscale(r_1.f);
    var _S224 : f32 = sel_2.w_sum / _S223;
    var _S225 : bool = _S223 > 0.0f;
    var _S226 : f32 = select(0.0f, _S224, _S225);
    r_1.w = _S226;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S227 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S228 : u32 = (insertBits((_S227), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S228;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S229 : bool = transmission_0 > 0.0f;
    var _S230 : bool;
    if(_S229)
    {
        _S230 = true;
    }
    else
    {
        _S230 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S231 : f32;
    if(_S230)
    {
        _S231 = 1.0f;
    }
    else
    {
        _S231 = -1.0f;
    }
    return _S231;
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
    var _S232 : bool;
    if(open_0)
    {
        _S232 = prev_rough_0;
    }
    else
    {
        _S232 = false;
    }
    if(_S232)
    {
        _S232 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S232 = false;
    }
    return _S232;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S233 : bool = pdf_2 > 0.0f;
    var _S234 : bool;
    if(_S233)
    {
        if(diffuse_0)
        {
            _S234 = true;
        }
        else
        {
            _S234 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S234 = false;
    }
    return _S234;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S235 : bool = pdf_3 > 0.0f;
    var _S236 : bool;
    if(_S235)
    {
        if(diffuse_1)
        {
            _S236 = true;
        }
        else
        {
            _S236 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S236 = false;
    }
    return _S236;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S237 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S237.x, max(_S237.y, _S237.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S238 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S238;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S239 : f32 = c_1 * p_c_0;
    var _S240 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S239 / (_S239 + c_t_0 * g_previous_0), _S240 / (_S240 + c_1 * g_current_0));
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
    var _S241 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S242 : bool = cos_a_0 > cos_b_0;
    var _S243 : f32 = select(_S241, 1.0f, _S242);
    return _S243;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S244 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S245 : bool = cos_a_1 > cos_b_1;
    var _S246 : f32 = select(_S244, 0.0f, _S245);
    return _S246;
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

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S247 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S248 : vec3<f32> = node_0.high - node_0.low;
    var _S249 : vec3<f32> = p_0 - _S247;
    var _S250 : vec3<f32> = (normalize((_S249)));
    var _S251 : f32 = dot(_S249, _S249);
    var _S252 : f32 = dot(_S248, _S248) / 4.0f;
    var _S253 : f32 = abs(dot(node_0.w, _S250));
    var _S254 : f32 = sine(node_0.cos_theta_o);
    var _S255 : f32 = sqrt(max(1.0f - _S252 / _S251, 0.0f));
    var _S256 : bool = _S251 < _S252;
    var _S257 : f32 = select(_S255, -1.0f, _S256);
    var _S258 : f32 = sine(_S257);
    var _S259 : f32 = sine(_S253);
    var _S260 : f32 = cosSubClamped(_S259, _S253, _S254, node_0.cos_theta_o);
    var _S261 : f32 = sine(_S253);
    var _S262 : f32 = sinSubClamped(_S261, _S253, _S254, node_0.cos_theta_o);
    var _S263 : f32 = cosSubClamped(_S262, _S260, _S258, _S257);
    var _S264 : bool = _S263 <= 0.0f;
    if(_S264)
    {
        return 0.0f;
    }
    var _S265 : f32 = - dot(_S250, normal_0);
    var _S266 : f32 = node_0.phi * _S263 / max(_S251, length(_S248) / 2.0f);
    var _S267 : f32 = sine(_S265);
    var _S268 : f32 = cosSubClamped(_S267, _S265, _S258, _S257);
    var _S269 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S270 : f32 = select(_S268, 1.0f, _S269);
    return max(_S266 * _S270, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_1, toward_0));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S271 : f32 = importance(first_0, p_1, normal_2);
    var _S272 : f32 = importance(second_0, p_1, normal_2);
    var _S273 : vec2<f32> = vec2<f32>(_S271, _S272);
    var _S274 : bool = _S271 == 0.0f;
    var _S275 : bool;
    if(_S274)
    {
        _S275 = _S272 == 0.0f;
    }
    else
    {
        _S275 = false;
    }
    if(_S275)
    {
        return u32(2);
    }
    var _S276 : f32 = _S271 + _S272;
    var _S277 : bool = _S272 > 0.0f;
    if(_S277)
    {
        _S275 = ((*pick_0) * _S276) >= _S271;
    }
    else
    {
        _S275 = false;
    }
    var _S278 : u32 = select(u32(0), u32(1), _S275);
    var _S279 : f32 = min(((*pick_0) * _S276 - f32(_S278) * _S271) / _S273[_S278], 0.99999994039535522f);
    (*pick_0) = _S279;
    var _S280 : f32 = (*probability_1) * (_S273[_S278] / _S276);
    (*probability_1) = _S280;
    return _S278;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S281 : f32 = importance(first_1, p_2, normal_3);
    var _S282 : f32 = importance(second_1, p_2, normal_3);
    var _S283 : vec2<f32> = vec2<f32>(_S281, _S282);
    var _S284 : f32 = _S283[child_0] / (_S281 + _S282);
    var _S285 : bool = (_S283[child_0]) > 0.0f;
    var _S286 : f32 = select(0.0f, _S284, _S285);
    return _S286;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S287 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S288 : bool = b_1 > 0.0f;
    var _S289 : f32 = select(1.0f, _S287, _S288);
    return _S289;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S290 : vec3<f32> = center_0 - p_3;
    var _S291 : f32 = radius_1 * radius_1 / dot(_S290, _S290);
    var _S292 : bool = _S291 >= 1.0f;
    if(_S292)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S291)) / (6.28318548202514648f * _S291);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S293 : vec3<f32> = center_1 - p_4;
    var _S294 : f32 = radius_2 * radius_2 / dot(_S293, _S293);
    var _S295 : f32 = u1_0 * _S294 / (1.0f + sqrt(max(1.0f - _S294, 0.0f)));
    var _S296 : f32 = 2.0f * u1_0;
    var _S297 : bool = _S294 >= 1.0f;
    var _S298 : f32 = select(_S295, _S296, _S297);
    var _S299 : f32 = sqrt(max(_S298 * (2.0f - _S298), 0.0f));
    var _S300 : f32 = 6.28318548202514648f * u2_0;
    var _S301 : vec3<f32> = vec3<f32>(_S299 * cos(_S300), 1.0f - _S298, _S299 * sin(_S300));
    var _S302 : vec3<f32> = (normalize((_S293)));
    var _S303 : vec3<f32> = tangentToWorld(_S301, _S302);
    return _S303;
}

