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

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S17 : f32 = alpha_1 * alpha_1;
    var _S18 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S17 + (1.0f - _S17) * n_dot_x_0 * n_dot_x_0));
    var _S19 : bool = alpha_1 > 0.0f;
    var _S20 : f32 = select(1.0f, _S18, _S19);
    return _S20;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S21 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S22 : f32 = eta_i_0 / eta_o_0 * _S21;
    var _S23 : bool = _S22 < 1.0f;
    var kr_0 : f32;
    if(_S23)
    {
        var _S24 : f32 = sqrt(max(0.0f, 1.0f - _S22 * _S22));
        var _S25 : f32 = eta_o_0 * cos_theta_0;
        var _S26 : f32 = eta_i_0 * _S24;
        var _S27 : f32 = (_S25 - _S26) / (_S25 + _S26);
        var _S28 : f32 = eta_i_0 * cos_theta_0;
        var _S29 : f32 = eta_o_0 * _S24;
        var _S30 : f32 = (_S28 - _S29) / (_S28 + _S29);
        var _S31 : f32 = (_S27 * _S27 + _S30 * _S30) / 2.0f;
        kr_0 = _S31;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_2 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S32 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z))));
    var _S33 : f32 = _S32.x;
    var _S34 : f32 = _S32.y;
    var _S35 : f32 = _S33 * _S33 + _S34 * _S34;
    const _S36 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S37 : vec3<f32> = vec3<f32>(- _S34, _S33, 0.0f);
    var _S38 : f32 = (inverseSqrt((_S35)));
    var _S39 : vec3<f32> = _S37 * vec3<f32>(_S38);
    var _S40 : bool = _S35 > 0.0f;
    var _S41 : vec3<f32> = select(_S36, _S39, _S40);
    var _S42 : vec3<f32> = cross(_S32, _S41);
    var _S43 : f32 = sqrt(U1_0);
    var _S44 : f32 = 6.28318548202514648f * U2_0;
    var _S45 : f32 = _S43 * cos(_S44);
    var t2_0 : f32 = _S43 * sin(_S44);
    var _S46 : f32 = 0.5f * (1.0f + _S32.z);
    var t2_1 : f32 = (1.0f - _S46) * sqrt(max(0.0f, 1.0f - _S45 * _S45)) + _S46 * t2_0;
    var _S47 : vec3<f32> = vec3<f32>(_S45) * _S41 + vec3<f32>(t2_1) * _S42;
    var _S48 : f32 = ((_S45));
    var _S49 : f32 = ((_S45));
    var _S50 : vec3<f32> = _S47 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S48 * _S49 - t2_1 * t2_1))) * _S32;
    var _S51 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * _S50.x, alpha_2 * _S50.y, max(0.0f, _S50.z)))));
    return _S51;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S52 : f32 = sqrt(random_1_0);
    var _S53 : f32 = 6.28318548202514648f * random_2_0;
    var _S54 : f32 = _S52 * cos(_S53);
    var _S55 : f32 = _S52 * sin(_S53);
    var _S56 : f32 = sqrt(max(0.0f, 1.0f - _S54 * _S54 - _S55 * _S55));
    return vec3<f32>(_S54, _S56, _S55);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S57 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S57)
    {
        const _S58 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S58;
    }
    else
    {
        a_1 = a_0;
    }
    var _S59 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S60 : vec3<f32> = cross(n_0, _S59);
    return vec3<f32>(v_0.x) * _S59 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S60;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S61 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S61)
    {
        const _S62 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S62;
    }
    else
    {
        a_3 = a_2;
    }
    var _S63 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S64 : vec3<f32> = cross(n_1, _S63);
    return vec3<f32>(dot(v_1, _S63), dot(v_1, n_1), dot(v_1, _S64));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S65 : vec3<f32> = p1_0 - p0_0;
    var _S66 : vec3<f32> = p2_0 - p0_0;
    var _S67 : vec2<f32> = uv1_0 - uv0_0;
    var _S68 : vec2<f32> = uv2_0 - uv0_0;
    var _S69 : f32 = _S67.x;
    var _S70 : f32 = _S68.y;
    var _S71 : f32 = _S67.y;
    var _S72 : f32 = _S68.x;
    var _S73 : f32 = _S69 * _S70 - _S71 * _S72;
    var _S74 : f32 = 1.0f / _S73;
    var _S75 : vec3<f32> = vec3<f32>(_S74);
    var t_0 : vec3<f32> = (_S65 * vec3<f32>(_S70) - _S66 * vec3<f32>(_S71)) * _S75;
    var _S76 : vec3<f32> = (_S66 * vec3<f32>(_S69) - _S65 * vec3<f32>(_S72)) * _S75;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S77 : bool = (dot(cross(n_2, t_1), _S76)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S77)
    {
        var _S78 : vec3<f32> = ((-(t_1)));
        t_2 = _S78;
    }
    else
    {
        t_2 = t_1;
    }
    var _S79 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S79, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_0 : vec3<f32>,  uvw_0 : vec3<f32>,  position_0 : vec3<f32>) -> f32
{
    var _S80 : vec3<f32> = t1_0 - t0_0;
    var _S81 : vec3<f32> = t2_2 - t0_0;
    var _S82 : vec3<f32> = t2_2 - t1_0;
    var _S83 : f32 = min(length(_S80), min(length(_S81), length(_S82)));
    var _S84 : vec3<f32> = vec3<f32>(distance(position_0, t0_0), distance(position_0, t1_0), distance(position_0, t2_2));
    var _S85 : vec3<f32> = (normalize((n0_0)));
    var _S86 : f32 = dot(geometry_n_0, _S85);
    var _S87 : vec3<f32> = (normalize((n1_0)));
    var _S88 : f32 = dot(geometry_n_0, _S87);
    var _S89 : vec3<f32> = (normalize((n2_0)));
    var _S90 : vec3<f32> = acos(abs(vec3<f32>(_S86, _S88, dot(geometry_n_0, _S89))));
    var _S91 : vec3<f32> = clamp(tan(_S90), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S84 * _S91, uvw_0), 0.0f, _S83 * 0.125f);
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S92 : Random = pcg((*random_state_0));
    var _S93 : Random = pcg(_S92.state);
    (*random_state_0) = _S93.state;
    var _S94 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S95 : vec3<f32> = sampleGGXVNDF(_S94.xzy, alpha_3, _S92.value, _S93.value);
    var _S96 : vec3<f32> = _S95.xzy;
    var _S97 : vec3<f32> = tangentToWorld(_S96, n_i_0);
    return _S97;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S98 : vec3<f32> = ((-(in_dir_0)));
    var _S99 : f32 = (sign((dot(n_3, _S98))));
    var _S100 : f32 = material_0.roughness;
    var _S101 : vec3<f32> = sampleHalfVector(_S98, n_3 * vec3<f32>(_S99), _S100 * _S100, &(state_5));
    return _S101;
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
    var _S102 : BSDFLobes;
    _S102.v_dot_h = v_dot_h_0;
    _S102.n_dot_h = n_dot_h_1;
    _S102.refracted = refracted_0;
    _S102.F = F_0;
    _S102.F_greyscale = F_greyscale_0;
    _S102.reflect_weight = reflect_weight_0;
    _S102.diffuse_weight = diffuse_weight_0;
    _S102.refract_weight = refract_weight_0;
    _S102.p_diffuse = p_diffuse_0;
    _S102.p_reflect = p_reflect_0;
    _S102.p_refract = p_refract_0;
    return _S102;
}

fn bsdfLobes( in_dir_1 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S103 : f32 = dot(ggx_n_0, v_4);
    var _S104 : f32 = dot(n_i_1, ggx_n_0);
    var _S105 : f32 = eta_i_1 / eta_o_1;
    var _S106 : vec3<f32> = (normalize((refract(in_dir_1, ggx_n_0, _S105))));
    var _S107 : f32 = fresnel(abs(_S103), eta_i_1, eta_o_1);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S107)), (material_1.albedo), (material_1.metallic)));
    var _S108 : f32 = rgb_to_greyscale(F_1);
    var _S109 : f32 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    var _S110 : f32 = max(_S108, 0.0f);
    var _S111 : f32 = 1.0f - _S108;
    var _S112 : f32 = max(_S109 * _S111, 0.0f);
    var _S113 : f32 = material_1.transmission * _S111;
    var _S114 : f32 = (sign((length(_S106))));
    var _S115 : f32 = max(_S113 * _S114, 0.0f);
    var _S116 : f32 = _S110 + _S112 + _S115;
    var _S117 : f32 = 1.0f / max(_S116, 0.0000152587890625f);
    var _S118 : f32 = _S112 * _S117;
    var _S119 : f32 = _S110 * _S117;
    var _S120 : f32 = _S115 * _S117;
    return BSDFLobes_x24init_0(_S103, _S104, _S106, F_1, _S108, 1.0f, _S109, material_1.transmission, _S118, _S119, _S120);
}

fn refractedHalf( in_dir_2 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S121 : vec3<f32> = ((-(in_dir_2)));
    var _S122 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S121 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S123 : vec3<f32> = (normalize((_S122)));
    var _S124 : f32 = (sign((dot(n_4, _S121))));
    var _S125 : f32 = (sign((dot(_S122, n_4 * vec3<f32>(_S124)))));
    return _S123 * vec3<f32>(_S125);
}

fn reflectedHalf( in_dir_3 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S126 : vec3<f32> = ((-(in_dir_3)));
    var _S127 : vec3<f32> = (normalize((_S126 + out_dir_1)));
    return _S127;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S128 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S129 : bool = n_i_dot_v_0 > 0.0f;
    var _S130 : f32 = select(0.0f, _S128, _S129);
    return _S130;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_5 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S131 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S132 : f32 = _S131 * lobes_2.v_dot_h;
    var _S133 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S134 : f32 = _S132 * _S133 / n_i_dot_v_1;
    var _S135 : bool = alpha_6 > 0.0f;
    var _S136 : bool;
    if(_S135)
    {
        _S136 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    if(_S136)
    {
        _S136 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    if(_S136)
    {
        _S136 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    var _S137 : f32 = select(0.0f, _S134, _S136);
    return _S137;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S138 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S139 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S140 : f32 = lobes_3.p_refract * _S138 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S139 * _S139);
    var _S141 : bool = eta_i_4 != eta_o_4;
    var _S142 : bool;
    if(_S141)
    {
        _S142 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S142 = false;
    }
    var _S143 : f32 = select(0.0f, _S140, _S142);
    return _S143;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_8 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S144 : f32 = - dot(n_i_3, l_1);
    var _S145 : f32 = smithG1(alpha_8, max(_S144, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S145 * (1.0f - lobes_4.F_greyscale))) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S146 : f32 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    var _S147 : f32 = lobes_5.p_reflect * _S146 / (4.0f * lobes_5.v_dot_h);
    var _S148 : bool = _S146 > 0.0f;
    var _S149 : f32 = select(0.0f, _S147, _S148);
    return _S149;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_10 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S150 : f32 = dot(n_i_4, l_2);
    var _S151 : f32 = smithG1(alpha_10, max(_S150, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S151)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(3)>>,  pdfs_0 : ptr<function, array<f32, i32(3)>>) -> vec3<f32>
{
    var _S152 : vec3<f32> = ((-(in_dir_4)));
    var _S153 : f32 = dot(n_5, _S152);
    var _S154 : f32 = (sign((_S153)));
    var _S155 : vec3<f32> = n_5 * vec3<f32>(_S154);
    var _S156 : f32 = dot(_S155, out_dir_2);
    var _S157 : f32 = material_5.roughness;
    var _S158 : f32 = _S157 * _S157;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S159 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S159;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S160 : vec3<f32> = vec3<f32>(0.0f);
    var _S161 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S160, _S160, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var _S162 : bool = !refracted_1;
    var sampled_terms_0 : BSDFLobes;
    if(_S162)
    {
        var sampled_n_0 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
        var _S163 : vec3<f32> = ((-(in_dir_4)));
        var _S164 : BSDFLobes = bsdfLobes(in_dir_4, _S163, _S155, sampled_n_0, material_5, eta_i_6, eta_o_6);
        sampled_terms_0 = _S164;
    }
    else
    {
        sampled_terms_0 = _S161;
    }
    var f_0 : vec3<f32>;
    if(refracted_1)
    {
        var _S165 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
        f_0 = _S165;
    }
    else
    {
        var _S166 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
        f_0 = _S166;
    }
    var _S167 : vec3<f32> = ((-(in_dir_4)));
    var _S168 : BSDFLobes = bsdfLobes(in_dir_4, _S167, _S155, f_0, material_5, eta_i_6, eta_o_6);
    i_0 = u32(0);
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S169 : bool = (i_0 == u32(1)) != refracted_1;
        if(_S169)
        {
            var i_2 : u32 = i_0 + u32(1);
            i_0 = i_2;
            continue;
        }
        switch(i_0)
        {
        case u32(0):
            {
                var _S170 : f32 = diffusePDF(_S156, 0.0f, abs(_S153), _S158, sampled_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(0)] = _S170;
                var _S171 : vec3<f32> = diffuseBSDF(out_dir_2, _S155, _S158, material_5, sampled_terms_0);
                (*throughputs_0)[i32(0)] = _S171;
            }
        case u32(1):
            {
                var _S172 : f32 = refractPDF(_S156, dot(out_dir_2, f_0), abs(_S153), _S158, _S168, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(1)] = _S172;
                var _S173 : vec3<f32> = refractBSDF(out_dir_2, _S155, _S158, material_5, _S168);
                (*throughputs_0)[i32(1)] = _S173;
            }
        default :
            {
                var _S174 : f32 = reflectPDF(_S156, 0.0f, abs(_S153), _S158, _S168, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(2)] = _S174;
                var _S175 : vec3<f32> = reflectBSDF(out_dir_2, _S155, _S158, material_5, _S168);
                (*throughputs_0)[i32(2)] = _S175;
            }
        }
        var i_2 : u32 = i_0 + u32(1);
        i_0 = i_2;
    }
    i_0 = u32(0);
    f_0 = _S160;
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S176 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S176)
        {
            var f_1 : vec3<f32> = f_0 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            f_0 = f_1;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
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

fn SampleBSDF_x24init_0( unit_direction_0 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_3 : u32,  refracted_2 : bool,  lobe_0 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S177 : SampleBSDF;
    _S177.unit_direction = unit_direction_0;
    _S177.throughput = throughput_0;
    _S177.random_state = random_state_3;
    _S177.refracted = refracted_2;
    _S177.lobe = lobe_0;
    _S177.pdf = pdf_0;
    return _S177;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_11 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
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
    var _S184 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    sample_0.throughput = _S184;
    var _S185 : f32 = diffusePDF(_S182.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S185;
    return sample_0;
}

fn refractSample( ggx_n_1 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_12 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S186 : vec3<f32> = vec3<f32>(1.0f);
    var _S187 : SampleBSDF = SampleBSDF_x24init_0(_S186, _S186, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S187;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S188 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    sample_1.throughput = _S188;
    var _S189 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_1), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S189;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_2 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_13 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S190 : vec3<f32> = vec3<f32>(1.0f);
    var _S191 : SampleBSDF = SampleBSDF_x24init_0(_S190, _S190, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S191;
    var _S192 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_2))));
    sample_2.unit_direction = _S192;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S193 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    sample_2.throughput = _S193;
    var _S194 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S194;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32) -> SampleBSDF
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

fn straightThrough( dir_0 : vec3<f32>,  n_7 : vec3<f32>,  material_11 : Material) -> vec3<f32>
{
    var _S216 : f32 = rgb_to_greyscale(material_11.albedo * vec3<f32>(material_11.metallic));
    var _S217 : f32 = material_11.roughness;
    var _S218 : f32 = smithG1(_S217 * _S217, abs(dot(n_7, dir_0)));
    return vec3<f32>((material_11.transmission * _S218 * (1.0f - _S216))) * material_11.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S219 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S219 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_8 : vec3<f32>,  material_12 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S220 : vec3<f32>;
    if((material_12.ior) == 1.0f)
    {
        var _S221 : vec3<f32> = straightThrough(toward_0, n_8, material_12);
        _S220 = _S221;
    }
    else
    {
        _S220 = vec3<f32>(0.0f);
    }
    return _S220 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S222 : u32 = hash(index_0);
    var _S223 : u32 = hash((seed_0 ^ (_S222)));
    return _S223;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S224 : vec3<f32> = a_4 / b_0;
    var _S225 : vec3<f32> = vec3<f32>(0.0f);
    var _S226 : vec3<bool> = b_0 == _S225;
    var _S227 : vec3<f32> = select(_S224, _S225, _S226);
    return _S227;
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
    var _S228 : f32 = rgb_to_greyscale(weight_0);
    var _S229 : bool = _S228 > 0.0f;
    var _S230 : bool;
    if(_S229)
    {
        _S230 = _S228 < 3.00000000549775576e+38f;
    }
    else
    {
        _S230 = false;
    }
    var _S231 : bool = !_S230;
    if(_S231)
    {
        return;
    }
    var _S232 : f32 = (*sel_0).w_sum + _S228;
    (*sel_0).w_sum = _S232;
    var _S233 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S233;
    var _S234 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S234.state;
    var _S235 : bool = (_S234.value * (*sel_0).w_sum) <= _S228;
    if(_S235)
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
    var _S236 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S236;
    var _S237 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S237;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S238 : f32 = rgb_to_greyscale(r_1.f);
    var _S239 : f32 = sel_2.w_sum / _S238;
    var _S240 : bool = _S238 > 0.0f;
    var _S241 : f32 = select(0.0f, _S239, _S240);
    r_1.w = _S241;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_2 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S242 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S243 : u32 = (insertBits((_S242), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S243;
    candidate_2.f = f_2;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S244 : bool = transmission_0 > 0.0f;
    var _S245 : bool;
    if(_S244)
    {
        _S245 = true;
    }
    else
    {
        _S245 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S246 : f32;
    if(_S245)
    {
        _S246 = 1.0f;
    }
    else
    {
        _S246 = -1.0f;
    }
    return _S246;
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
    var _S247 : bool;
    if(open_0)
    {
        _S247 = prev_rough_0;
    }
    else
    {
        _S247 = false;
    }
    if(_S247)
    {
        _S247 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S247 = false;
    }
    return _S247;
}

fn withinInverseFootprint( pdf_1 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S248 : bool = pdf_1 > 0.0f;
    var _S249 : bool;
    if(_S248)
    {
        if(diffuse_0)
        {
            _S249 = true;
        }
        else
        {
            _S249 = (pdf_1 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S249 = false;
    }
    return _S249;
}

fn roughLobe( pdf_2 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S250 : bool = pdf_2 > 0.0f;
    var _S251 : bool;
    if(_S250)
    {
        if(diffuse_1)
        {
            _S251 = true;
        }
        else
        {
            _S251 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S251 = false;
    }
    return _S251;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S252 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S252.x, max(_S252.y, _S252.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S253 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S253;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S254 : f32 = c_1 * p_c_0;
    var _S255 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S254 / (_S254 + c_t_0 * g_previous_0), _S255 / (_S255 + c_1 * g_current_0));
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
    var _S256 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S257 : bool = cos_a_0 > cos_b_0;
    var _S258 : f32 = select(_S256, 1.0f, _S257);
    return _S258;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S259 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S260 : bool = cos_a_1 > cos_b_1;
    var _S261 : f32 = select(_S259, 0.0f, _S260);
    return _S261;
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
    var _S262 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S263 : vec3<f32> = node_0.high - node_0.low;
    var _S264 : vec3<f32> = p_0 - _S262;
    var _S265 : vec3<f32> = (normalize((_S264)));
    var _S266 : f32 = dot(_S264, _S264);
    var _S267 : f32 = dot(_S263, _S263) / 4.0f;
    var _S268 : f32 = abs(dot(node_0.w, _S265));
    var _S269 : f32 = sine(node_0.cos_theta_o);
    var _S270 : f32 = sqrt(max(1.0f - _S267 / _S266, 0.0f));
    var _S271 : bool = _S266 < _S267;
    var _S272 : f32 = select(_S270, -1.0f, _S271);
    var _S273 : f32 = sine(_S272);
    var _S274 : f32 = sine(_S268);
    var _S275 : f32 = cosSubClamped(_S274, _S268, _S269, node_0.cos_theta_o);
    var _S276 : f32 = sine(_S268);
    var _S277 : f32 = sinSubClamped(_S276, _S268, _S269, node_0.cos_theta_o);
    var _S278 : f32 = cosSubClamped(_S277, _S275, _S273, _S272);
    var _S279 : bool = _S278 <= 0.0f;
    if(_S279)
    {
        return 0.0f;
    }
    var _S280 : f32 = - dot(_S265, normal_0);
    var _S281 : f32 = node_0.phi * _S278 / max(_S266, length(_S263) / 2.0f);
    var _S282 : f32 = sine(_S280);
    var _S283 : f32 = cosSubClamped(_S282, _S280, _S273, _S272);
    var _S284 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S285 : f32 = select(_S283, 1.0f, _S284);
    return max(_S281 * _S285, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S286 : f32 = importance(first_0, p_1, normal_2);
    var _S287 : f32 = importance(second_0, p_1, normal_2);
    var _S288 : vec2<f32> = vec2<f32>(_S286, _S287);
    var _S289 : bool = _S286 == 0.0f;
    var _S290 : bool;
    if(_S289)
    {
        _S290 = _S287 == 0.0f;
    }
    else
    {
        _S290 = false;
    }
    if(_S290)
    {
        return u32(2);
    }
    var _S291 : f32 = _S286 + _S287;
    var _S292 : bool = _S287 > 0.0f;
    if(_S292)
    {
        _S290 = ((*pick_0) * _S291) >= _S286;
    }
    else
    {
        _S290 = false;
    }
    var _S293 : u32 = select(u32(0), u32(1), _S290);
    var _S294 : f32 = min(((*pick_0) * _S291 - f32(_S293) * _S286) / _S288[_S293], 0.99999994039535522f);
    (*pick_0) = _S294;
    var _S295 : f32 = (*probability_1) * (_S288[_S293] / _S291);
    (*probability_1) = _S295;
    return _S293;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S296 : f32 = importance(first_1, p_2, normal_3);
    var _S297 : f32 = importance(second_1, p_2, normal_3);
    var _S298 : vec2<f32> = vec2<f32>(_S296, _S297);
    var _S299 : f32 = _S298[child_0] / (_S296 + _S297);
    var _S300 : bool = (_S298[child_0]) > 0.0f;
    var _S301 : f32 = select(0.0f, _S299, _S300);
    return _S301;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S302 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S303 : bool = b_1 > 0.0f;
    var _S304 : f32 = select(1.0f, _S302, _S303);
    return _S304;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S305 : vec3<f32> = center_0 - p_3;
    var _S306 : f32 = radius_1 * radius_1 / dot(_S305, _S305);
    var _S307 : bool = _S306 >= 1.0f;
    if(_S307)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S306)) / (6.28318548202514648f * _S306);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S308 : vec3<f32> = center_1 - p_4;
    var _S309 : f32 = radius_2 * radius_2 / dot(_S308, _S308);
    var _S310 : f32 = u1_0 * _S309 / (1.0f + sqrt(max(1.0f - _S309, 0.0f)));
    var _S311 : f32 = 2.0f * u1_0;
    var _S312 : bool = _S309 >= 1.0f;
    var _S313 : f32 = select(_S310, _S311, _S312);
    var _S314 : f32 = sqrt(max(_S313 * (2.0f - _S313), 0.0f));
    var _S315 : f32 = 6.28318548202514648f * u2_0;
    var _S316 : vec3<f32> = vec3<f32>(_S314 * cos(_S315), 1.0f - _S313, _S314 * sin(_S315));
    var _S317 : vec3<f32> = (normalize((_S308)));
    var _S318 : vec3<f32> = tangentToWorld(_S316, _S317);
    return _S318;
}

