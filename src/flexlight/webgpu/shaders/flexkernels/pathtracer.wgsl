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

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S96 : vec3<f32> = ((-(in_dir_0)));
    var _S97 : f32 = (sign((dot(n_3, _S96))));
    var _S98 : f32 = material_0.roughness;
    var _S99 : vec3<f32> = sampleHalfVector(_S96, n_3 * vec3<f32>(_S97), _S98 * _S98, &(state_5));
    return _S99;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S100 : vec3<f32> = ((-(in_dir_1)));
    var _S101 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S100 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S102 : vec3<f32> = (normalize((_S101)));
    var _S103 : f32 = (sign((dot(n_4, _S100))));
    var _S104 : f32 = (sign((dot(_S101, n_4 * vec3<f32>(_S103)))));
    return _S102 * vec3<f32>(_S104);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S105 : vec3<f32> = ((-(in_dir_2)));
    var _S106 : vec3<f32> = (normalize((_S105 + out_dir_1)));
    return _S106;
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
    var _S107 : BSDFLobes;
    _S107.v_dot_h = v_dot_h_0;
    _S107.n_dot_h = n_dot_h_1;
    _S107.refracted = refracted_0;
    _S107.F = F_0;
    _S107.F_greyscale = F_greyscale_0;
    _S107.reflect_weight = reflect_weight_0;
    _S107.diffuse_weight = diffuse_weight_0;
    _S107.refract_weight = refract_weight_0;
    _S107.p_diffuse = p_diffuse_0;
    _S107.p_reflect = p_reflect_0;
    _S107.p_refract = p_refract_0;
    return _S107;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S108 : f32 = dot(ggx_n_0, v_4);
    var _S109 : f32 = dot(n_i_1, ggx_n_0);
    var _S110 : f32 = eta_i_2 / eta_o_2;
    var _S111 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S110))));
    var _S112 : f32 = fresnel(abs(_S108), eta_i_2, eta_o_2);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S112)), (material_1.albedo), (material_1.metallic)));
    var _S113 : f32 = rgb_to_greyscale(F_1);
    var _S114 : f32 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    var _S115 : f32 = max(_S113, 0.0f);
    var _S116 : f32 = 1.0f - _S113;
    var _S117 : f32 = max(_S114 * _S116, 0.0f);
    var _S118 : f32 = material_1.transmission * _S116;
    var _S119 : f32 = (sign((length(_S111))));
    var _S120 : f32 = max(_S118 * _S119, 0.0f);
    var _S121 : f32 = _S115 + _S117 + _S120;
    var _S122 : f32 = 1.0f / max(_S121, 0.0000152587890625f);
    var _S123 : f32 = _S117 * _S122;
    var _S124 : f32 = _S115 * _S122;
    var _S125 : f32 = _S120 * _S122;
    return BSDFLobes_x24init_0(_S108, _S109, _S111, F_1, _S113, 1.0f, _S114, material_1.transmission, _S123, _S124, _S125);
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S126 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S127 : bool = n_i_dot_v_0 > 0.0f;
    var _S128 : f32 = select(0.0f, _S126, _S127);
    return _S128;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_7 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S129 : f32 = smithG1(alpha_7, n_i_dot_v_1);
    var _S130 : f32 = _S129 * lobes_2.v_dot_h;
    var _S131 : f32 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    var _S132 : f32 = _S130 * _S131 / n_i_dot_v_1;
    var _S133 : bool = alpha_7 > 0.0f;
    var _S134 : bool;
    if(_S133)
    {
        _S134 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S134 = false;
    }
    if(_S134)
    {
        _S134 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S134 = false;
    }
    if(_S134)
    {
        _S134 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S134 = false;
    }
    var _S135 : f32 = select(0.0f, _S132, _S134);
    return _S135;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_8 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S136 : f32 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    var _S137 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S138 : f32 = lobes_3.p_refract * _S136 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S137 * _S137);
    var _S139 : bool = eta_i_4 != eta_o_4;
    var _S140 : bool;
    if(_S139)
    {
        _S140 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S140 = false;
    }
    var _S141 : f32 = select(0.0f, _S138, _S140);
    return _S141;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_9 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S142 : f32 = - dot(n_i_3, l_1);
    var _S143 : f32 = G1(alpha_9, max(_S142, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S143 * (1.0f - lobes_4.F_greyscale))) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_10 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S144 : f32 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    var _S145 : f32 = lobes_5.p_reflect * _S144 / (4.0f * lobes_5.v_dot_h);
    var _S146 : bool = _S144 > 0.0f;
    var _S147 : f32 = select(0.0f, _S145, _S146);
    return _S147;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_11 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S148 : f32 = dot(n_i_4, l_2);
    var _S149 : f32 = G1(alpha_11, max(_S148, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S149)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_2 : u32) -> vec3<f32>
{
    var _S150 : vec3<f32> = ((-(in_dir_4)));
    var _S151 : f32 = dot(n_5, _S150);
    var _S152 : f32 = (sign((_S151)));
    var _S153 : vec3<f32> = n_5 * vec3<f32>(_S152);
    var _S154 : f32 = dot(_S153, out_dir_2);
    var _S155 : f32 = material_5.roughness;
    var _S156 : f32 = _S155 * _S155;
    var _S157 : bool = (dot(g_n_0, _S150) * dot(g_n_0, out_dir_2)) > 0.0f;
    var _S158 : u32;
    if(_S157)
    {
        _S158 = u32(2);
    }
    else
    {
        _S158 = u32(1);
    }
    var _S159 : vec3<f32> = vec3<f32>(0.0f);
    var _S160 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S159, _S159, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S160;
    var ggx_n_1 : vec3<f32> = _S159;
    var f_0 : vec3<f32> = _S159;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < _S158)
        {
        }
        else
        {
            break;
        }
        var _S161 : u32;
        if(!_S157)
        {
            _S161 = u32(1);
        }
        else
        {
            if(i_0 == u32(0))
            {
                _S161 = u32(0);
            }
            else
            {
                _S161 = u32(2);
            }
        }
        var _S162 : bool = _S161 != half_of_0;
        var ggx_n_2 : vec3<f32>;
        if(_S162)
        {
            var _S163 : bool = _S161 == u32(0);
            if(_S163)
            {
                var _S164 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_2 = _S164;
            }
            else
            {
                var _S165 : bool = _S161 == u32(1);
                if(_S165)
                {
                    var _S166 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_2 = _S166;
                }
                else
                {
                    var _S167 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_2 = _S167;
                }
            }
            var _S168 : vec3<f32> = ((-(in_dir_4)));
            var _S169 : BSDFLobes = bsdfLobes(in_dir_4, _S168, _S153, ggx_n_2, material_5, eta_i_6, eta_o_6);
            lobe_terms_0 = _S169;
            half_of_0 = _S161;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        var throughput_0 : vec3<f32>;
        var pdf_0 : f32;
        switch(_S161)
        {
        case u32(0):
            {
                var _S170 : f32 = diffusePDF(_S154, 0.0f, abs(_S151), _S156, lobe_terms_0, eta_i_6, eta_o_6);
                var _S171 : vec3<f32> = diffuseBSDF(out_dir_2, _S153, _S156, material_5, lobe_terms_0);
                pdf_0 = _S170;
                throughput_0 = _S171;
            }
        case u32(1):
            {
                var _S172 : f32 = refractPDF(_S154, dot(out_dir_2, ggx_n_2), abs(_S151), _S156, lobe_terms_0, eta_i_6, eta_o_6);
                var _S173 : vec3<f32> = refractBSDF(out_dir_2, _S153, _S156, material_5, lobe_terms_0);
                pdf_0 = _S172;
                throughput_0 = _S173;
            }
        default :
            {
                var _S174 : f32 = reflectPDF(_S154, 0.0f, abs(_S151), _S156, lobe_terms_0, eta_i_6, eta_o_6);
                var _S175 : vec3<f32> = reflectBSDF(out_dir_2, _S153, _S156, material_5, lobe_terms_0);
                pdf_0 = _S174;
                throughput_0 = _S175;
            }
        }
        var _S176 : vec3<f32>;
        if(pdf_0 > 0.0f)
        {
            _S176 = throughput_0 * vec3<f32>(pdf_0);
        }
        else
        {
            _S176 = _S159;
        }
        if(i_0 == u32(0))
        {
            f_0 = _S176;
        }
        else
        {
            f_0 = f_0 + _S176;
        }
        var i_1 : u32 = i_0 + u32(1);
        ggx_n_1 = ggx_n_2;
        i_0 = i_1;
    }
    return f_0;
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

fn SampleBSDF_x24init_0( unit_direction_0 : vec3<f32>,  throughput_1 : vec3<f32>,  random_state_3 : u32,  refracted_1 : bool,  lobe_0 : u32,  pdf_1 : f32) -> SampleBSDF
{
    var _S177 : SampleBSDF;
    _S177.unit_direction = unit_direction_0;
    _S177.throughput = throughput_1;
    _S177.random_state = random_state_3;
    _S177.refracted = refracted_1;
    _S177.lobe = lobe_0;
    _S177.pdf = pdf_1;
    return _S177;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_12 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S178 : vec3<f32> = vec3<f32>(1.0f);
    var _S179 : SampleBSDF = SampleBSDF_x24init_0(_S178, _S178, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S179;
    var _S180 : Random = pcg(random_state_4);
    var _S181 : Random = pcg(_S180.state);
    sample_0.random_state = _S181.state;
    var _S182 : vec3<f32> = sampleCosWeightedHemisphere(_S180.value, _S181.value);
    var _S183 : vec3<f32> = tangentToWorld(_S182, n_i_5);
    sample_0.unit_direction = _S183;
    sample_0.lobe = u32(0);
    var _S184 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    sample_0.throughput = _S184;
    var _S185 : f32 = diffusePDF(_S182.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S185;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S186 : vec3<f32> = vec3<f32>(1.0f);
    var _S187 : SampleBSDF = SampleBSDF_x24init_0(_S186, _S186, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S187;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S188 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    sample_1.throughput = _S188;
    var _S189 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S189;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S190 : vec3<f32> = vec3<f32>(1.0f);
    var _S191 : SampleBSDF = SampleBSDF_x24init_0(_S190, _S190, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S191;
    var _S192 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S192;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S193 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    sample_2.throughput = _S193;
    var _S194 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S194;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S195 : vec3<f32> = ((-(in_dir_6)));
    var _S196 : f32 = dot(n_6, _S195);
    var _S197 : f32 = (sign((_S196)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S197);
    var _S198 : f32 = abs(_S196);
    var _S199 : f32 = material_9.roughness;
    var _S200 : f32 = _S199 * _S199;
    var _S201 : vec3<f32> = sampleHalfVector(_S195, n_i_8, _S200, &(random_state_7));
    var _S202 : BSDFLobes = bsdfLobes(in_dir_6, _S195, n_i_8, _S201, material_9, eta_i_10, eta_o_10);
    var _S203 : Random = pcg(random_state_7);
    random_state_7 = _S203.state;
    var _S204 : bool = (_S203.value) < (_S202.p_diffuse);
    if(_S204)
    {
        var _S205 : SampleBSDF = diffuseSample(n_i_8, _S198, _S200, material_9, _S202, eta_i_10, eta_o_10, random_state_7);
        return _S205;
    }
    var _S206 : bool = (_S203.value) < (_S202.p_diffuse + _S202.p_refract);
    if(_S206)
    {
        var _S207 : SampleBSDF = refractSample(_S201, n_i_8, _S198, _S200, material_9, _S202, eta_i_10, eta_o_10, random_state_7);
        return _S207;
    }
    var _S208 : SampleBSDF = reflectSample(in_dir_6, _S201, n_i_8, _S198, _S200, material_9, _S202, eta_i_10, eta_o_10, random_state_7);
    return _S208;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S209 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S209));
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S210 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S211 : vec3<f32> = (mix((vec3<f32>(_S210)), (material_10.albedo), (material_10.metallic)));
    var _S212 : f32 = rgb_to_greyscale(_S211);
    var _S213 : f32 = max((1.0f - _S212) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S214 : bool = _S213 > 0.03999999910593033f;
    var _S215 : bool;
    if(_S214)
    {
        _S215 = true;
    }
    else
    {
        _S215 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S215;
}

fn misWeighted( throughput_2 : vec3<f32>,  lobe_pdf_0 : f32,  pdf_2 : f32,  power_0 : bool) -> vec3<f32>
{
    if(power_0)
    {
        var _S216 : f32 = lobe_pdf_0 / pdf_2;
        return throughput_2 * vec3<f32>(lobe_pdf_0) / vec3<f32>((pdf_2 * (1.0f + _S216 * _S216)));
    }
    return throughput_2 * vec3<f32>(lobe_pdf_0) / vec3<f32>((lobe_pdf_0 + pdf_2));
}

fn neeLobes_0( in_dir_7 : vec3<f32>,  dir_0 : vec3<f32>,  n_7 : vec3<f32>,  material_11 : Material,  eta_i_12 : f32,  eta_o_12 : f32,  refracted_2 : bool,  pdf_3 : f32,  power_1 : bool,  random_state_8 : u32,  each_0 : ptr<function, array<vec3<f32>, i32(3)>>,  reached_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S217 : vec3<f32> = ((-(in_dir_7)));
    var _S218 : f32 = dot(n_7, _S217);
    var _S219 : f32 = (sign((_S218)));
    var _S220 : vec3<f32> = n_7 * vec3<f32>(_S219);
    var _S221 : f32 = dot(_S220, dir_0);
    var _S222 : f32 = material_11.roughness;
    var _S223 : f32 = _S222 * _S222;
    var _S224 : vec3<f32> = vec3<f32>(0.0f);
    (*reached_0) = u32(0);
    var _S225 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S224, _S224, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var i_2 : u32 = u32(0);
    loop
    {
        if(i_2 < u32(3))
        {
        }
        else
        {
            break;
        }
        (*each_0)[i_2] = _S224;
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var half_of_1 : u32 = u32(4294967295);
    var lobe_terms_1 : BSDFLobes = _S225;
    var ggx_n_5 : vec3<f32> = _S224;
    i_2 = u32(0);
    var f_1 : vec3<f32> = _S224;
    loop
    {
        if(i_2 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S226 : bool = i_2 == u32(1);
        var _S227 : bool = _S226 == refracted_2;
        var ggx_n_6 : vec3<f32>;
        if(_S227)
        {
            var _S228 : bool = i_2 != half_of_1;
            var half_of_2 : u32;
            var lobe_terms_2 : BSDFLobes;
            if(_S228)
            {
                var _S229 : bool = i_2 == u32(0);
                if(_S229)
                {
                    var _S230 : vec3<f32> = sampledHalf(in_dir_7, n_7, material_11, random_state_8);
                    ggx_n_6 = _S230;
                }
                else
                {
                    if(_S226)
                    {
                        var _S231 : vec3<f32> = refractedHalf(in_dir_7, dir_0, n_7, eta_i_12, eta_o_12);
                        ggx_n_6 = _S231;
                    }
                    else
                    {
                        var _S232 : vec3<f32> = reflectedHalf(in_dir_7, dir_0);
                        ggx_n_6 = _S232;
                    }
                }
                var _S233 : vec3<f32> = ((-(in_dir_7)));
                var _S234 : BSDFLobes = bsdfLobes(in_dir_7, _S233, _S220, ggx_n_6, material_11, eta_i_12, eta_o_12);
                lobe_terms_2 = _S234;
                half_of_2 = i_2;
            }
            else
            {
                lobe_terms_2 = lobe_terms_1;
                ggx_n_6 = ggx_n_5;
                half_of_2 = half_of_1;
            }
            var throughput_3 : vec3<f32>;
            var lobe_pdf_1 : f32;
            switch(i_2)
            {
            case u32(0):
                {
                    var _S235 : f32 = diffusePDF(_S221, 0.0f, abs(_S218), _S223, lobe_terms_2, eta_i_12, eta_o_12);
                    var _S236 : vec3<f32> = diffuseBSDF(dir_0, _S220, _S223, material_11, lobe_terms_2);
                    lobe_pdf_1 = _S235;
                    throughput_3 = _S236;
                }
            case u32(1):
                {
                    var _S237 : f32 = refractPDF(_S221, dot(dir_0, ggx_n_6), abs(_S218), _S223, lobe_terms_2, eta_i_12, eta_o_12);
                    var _S238 : vec3<f32> = refractBSDF(dir_0, _S220, _S223, material_11, lobe_terms_2);
                    lobe_pdf_1 = _S237;
                    throughput_3 = _S238;
                }
            default :
                {
                    var _S239 : f32 = reflectPDF(_S221, 0.0f, abs(_S218), _S223, lobe_terms_2, eta_i_12, eta_o_12);
                    var _S240 : vec3<f32> = reflectBSDF(dir_0, _S220, _S223, material_11, lobe_terms_2);
                    lobe_pdf_1 = _S239;
                    throughput_3 = _S240;
                }
            }
            var _S241 : bool = lobe_pdf_1 > 0.0f;
            var f_2 : vec3<f32>;
            if(_S241)
            {
                var _S242 : vec3<f32> = misWeighted(throughput_3, lobe_pdf_1, pdf_3, power_1);
                (*each_0)[i_2] = _S242;
                var _S243 : u32 = ((*reached_0) | (((u32(1) << (i_2)))));
                (*reached_0) = _S243;
                var f_3 : vec3<f32> = f_1 + (*each_0)[i_2];
                f_2 = f_3;
            }
            else
            {
                f_2 = f_1;
            }
            half_of_1 = half_of_2;
            lobe_terms_1 = lobe_terms_2;
            f_1 = f_2;
        }
        else
        {
            ggx_n_6 = ggx_n_5;
        }
        var i_4 : u32 = i_2 + u32(1);
        ggx_n_5 = ggx_n_6;
        i_2 = i_4;
    }
    return f_1;
}

fn neeBSDF( in_dir_8 : vec3<f32>,  dir_1 : vec3<f32>,  n_8 : vec3<f32>,  material_12 : Material,  eta_i_13 : f32,  eta_o_13 : f32,  refracted_3 : bool,  pdf_4 : f32,  power_2 : bool,  random_state_9 : u32) -> vec3<f32>
{
    var reached_1 : u32 = u32(0);
    var each_1 : array<vec3<f32>, i32(3)>;
    var _S244 : vec3<f32> = neeLobes_0(in_dir_8, dir_1, n_8, material_12, eta_i_13, eta_o_13, refracted_3, pdf_4, power_2, random_state_9, &(each_1), &(reached_1));
    return _S244;
}

fn straightThrough( dir_2 : vec3<f32>,  n_9 : vec3<f32>,  material_13 : Material) -> vec3<f32>
{
    var _S245 : f32 = rgb_to_greyscale(material_13.albedo * vec3<f32>(material_13.metallic));
    var _S246 : f32 = material_13.roughness;
    var _S247 : f32 = G1(_S246 * _S246, abs(dot(n_9, dir_2)));
    return vec3<f32>((material_13.transmission * _S247 * (1.0f - _S245))) * material_13.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S248 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S248 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_10 : vec3<f32>,  material_14 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S249 : vec3<f32>;
    if((material_14.ior) == 1.0f)
    {
        var _S250 : vec3<f32> = straightThrough(toward_0, n_10, material_14);
        _S249 = _S250;
    }
    else
    {
        _S249 = vec3<f32>(0.0f);
    }
    return _S249 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S251 : u32 = hash(index_0);
    var _S252 : u32 = hash((seed_0 ^ (_S251)));
    return _S252;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S253 : vec3<f32> = a_4 / b_0;
    var _S254 : vec3<f32> = vec3<f32>(0.0f);
    var _S255 : vec3<bool> = b_0 == _S254;
    var _S256 : vec3<f32> = select(_S253, _S254, _S255);
    return _S256;
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
    var _S257 : f32 = rgb_to_greyscale(weight_0);
    var _S258 : bool = _S257 > 0.0f;
    var _S259 : bool;
    if(_S258)
    {
        _S259 = _S257 < 3.00000000549775576e+38f;
    }
    else
    {
        _S259 = false;
    }
    var _S260 : bool = !_S259;
    if(_S260)
    {
        return;
    }
    var _S261 : f32 = (*sel_0).w_sum + _S257;
    (*sel_0).w_sum = _S261;
    var _S262 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S262;
    var _S263 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S263.state;
    var _S264 : bool = (_S263.value * (*sel_0).w_sum) <= _S257;
    if(_S264)
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
    var _S265 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S265;
    var _S266 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S266;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S267 : f32 = rgb_to_greyscale(r_1.f);
    var _S268 : f32 = sel_2.w_sum / _S267;
    var _S269 : bool = _S267 > 0.0f;
    var _S270 : f32 = select(0.0f, _S268, _S269);
    r_1.w = _S270;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S271 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S272 : u32 = (insertBits((_S271), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S272;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S273 : bool = transmission_0 > 0.0f;
    var _S274 : bool;
    if(_S273)
    {
        _S274 = true;
    }
    else
    {
        _S274 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S275 : f32;
    if(_S274)
    {
        _S275 = 1.0f;
    }
    else
    {
        _S275 = -1.0f;
    }
    return _S275;
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
    var _S276 : bool;
    if(open_0)
    {
        _S276 = prev_rough_0;
    }
    else
    {
        _S276 = false;
    }
    if(_S276)
    {
        _S276 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S276 = false;
    }
    return _S276;
}

fn withinInverseFootprint( pdf_5 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S277 : bool = pdf_5 > 0.0f;
    var _S278 : bool;
    if(_S277)
    {
        if(diffuse_0)
        {
            _S278 = true;
        }
        else
        {
            _S278 = (pdf_5 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S278 = false;
    }
    return _S278;
}

fn roughLobe( pdf_6 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S279 : bool = pdf_6 > 0.0f;
    var _S280 : bool;
    if(_S279)
    {
        if(diffuse_1)
        {
            _S280 = true;
        }
        else
        {
            _S280 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S280 = false;
    }
    return _S280;
}

fn survivalProbability( throughput_4 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S281 : vec3<f32> = throughput_4 / vec3<f32>(density_0);
    return clamp(max(_S281.x, max(_S281.y, _S281.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S282 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S282;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S283 : f32 = c_1 * p_c_0;
    var _S284 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S283 / (_S283 + c_t_0 * g_previous_0), _S284 / (_S284 + c_1 * g_current_0));
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
    var _S285 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S286 : bool = cos_a_0 > cos_b_0;
    var _S287 : f32 = select(_S285, 1.0f, _S286);
    return _S287;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S288 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S289 : bool = cos_a_1 > cos_b_1;
    var _S290 : f32 = select(_S288, 0.0f, _S289);
    return _S290;
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
    var _S291 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S292 : vec3<f32> = node_0.high - node_0.low;
    var _S293 : vec3<f32> = p_0 - _S291;
    var _S294 : vec3<f32> = (normalize((_S293)));
    var _S295 : f32 = dot(_S293, _S293);
    var _S296 : f32 = dot(_S292, _S292) / 4.0f;
    var _S297 : f32 = abs(dot(node_0.w, _S294));
    var _S298 : f32 = sine(node_0.cos_theta_o);
    var _S299 : f32 = sqrt(max(1.0f - _S296 / _S295, 0.0f));
    var _S300 : bool = _S295 < _S296;
    var _S301 : f32 = select(_S299, -1.0f, _S300);
    var _S302 : f32 = sine(_S301);
    var _S303 : f32 = sine(_S297);
    var _S304 : f32 = cosSubClamped(_S303, _S297, _S298, node_0.cos_theta_o);
    var _S305 : f32 = sine(_S297);
    var _S306 : f32 = sinSubClamped(_S305, _S297, _S298, node_0.cos_theta_o);
    var _S307 : f32 = cosSubClamped(_S306, _S304, _S302, _S301);
    var _S308 : bool = _S307 <= 0.0f;
    if(_S308)
    {
        return 0.0f;
    }
    var _S309 : f32 = - dot(_S294, normal_0);
    var _S310 : f32 = node_0.phi * _S307 / max(_S295, length(_S292) / 2.0f);
    var _S311 : f32 = sine(_S309);
    var _S312 : f32 = cosSubClamped(_S311, _S309, _S302, _S301);
    var _S313 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S314 : f32 = select(_S312, 1.0f, _S313);
    return max(_S310 * _S314, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S315 : f32 = importance(first_0, p_1, normal_2);
    var _S316 : f32 = importance(second_0, p_1, normal_2);
    var _S317 : vec2<f32> = vec2<f32>(_S315, _S316);
    var _S318 : bool = _S315 == 0.0f;
    var _S319 : bool;
    if(_S318)
    {
        _S319 = _S316 == 0.0f;
    }
    else
    {
        _S319 = false;
    }
    if(_S319)
    {
        return u32(2);
    }
    var _S320 : f32 = _S315 + _S316;
    var _S321 : bool = _S316 > 0.0f;
    if(_S321)
    {
        _S319 = ((*pick_0) * _S320) >= _S315;
    }
    else
    {
        _S319 = false;
    }
    var _S322 : u32 = select(u32(0), u32(1), _S319);
    var _S323 : f32 = min(((*pick_0) * _S320 - f32(_S322) * _S315) / _S317[_S322], 0.99999994039535522f);
    (*pick_0) = _S323;
    var _S324 : f32 = (*probability_1) * (_S317[_S322] / _S320);
    (*probability_1) = _S324;
    return _S322;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S325 : f32 = importance(first_1, p_2, normal_3);
    var _S326 : f32 = importance(second_1, p_2, normal_3);
    var _S327 : vec2<f32> = vec2<f32>(_S325, _S326);
    var _S328 : f32 = _S327[child_0] / (_S325 + _S326);
    var _S329 : bool = (_S327[child_0]) > 0.0f;
    var _S330 : f32 = select(0.0f, _S328, _S329);
    return _S330;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S331 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S332 : bool = b_1 > 0.0f;
    var _S333 : f32 = select(1.0f, _S331, _S332);
    return _S333;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S334 : vec3<f32> = center_0 - p_3;
    var _S335 : f32 = radius_1 * radius_1 / dot(_S334, _S334);
    var _S336 : bool = _S335 >= 1.0f;
    if(_S336)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S335)) / (6.28318548202514648f * _S335);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S337 : vec3<f32> = center_1 - p_4;
    var _S338 : f32 = radius_2 * radius_2 / dot(_S337, _S337);
    var _S339 : f32 = u1_0 * _S338 / (1.0f + sqrt(max(1.0f - _S338, 0.0f)));
    var _S340 : f32 = 2.0f * u1_0;
    var _S341 : bool = _S338 >= 1.0f;
    var _S342 : f32 = select(_S339, _S340, _S341);
    var _S343 : f32 = sqrt(max(_S342 * (2.0f - _S342), 0.0f));
    var _S344 : f32 = 6.28318548202514648f * u2_0;
    var _S345 : vec3<f32> = vec3<f32>(_S343 * cos(_S344), 1.0f - _S342, _S343 * sin(_S344));
    var _S346 : vec3<f32> = (normalize((_S337)));
    var _S347 : vec3<f32> = tangentToWorld(_S345, _S346);
    return _S347;
}

