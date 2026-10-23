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

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S102 : vec3<f32> = ((-(in_dir_1)));
    var _S103 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S102 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S104 : vec3<f32> = (normalize((_S103)));
    var _S105 : f32 = (sign((dot(n_4, _S102))));
    var _S106 : f32 = (sign((dot(_S103, n_4 * vec3<f32>(_S105)))));
    return _S104 * vec3<f32>(_S106);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S107 : vec3<f32> = ((-(in_dir_2)));
    var _S108 : vec3<f32> = (normalize((_S107 + out_dir_1)));
    return _S108;
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
    var _S109 : BSDFLobes;
    _S109.v_dot_h = v_dot_h_0;
    _S109.n_dot_h = n_dot_h_1;
    _S109.refracted = refracted_0;
    _S109.F = F_0;
    _S109.F_greyscale = F_greyscale_0;
    _S109.reflect_weight = reflect_weight_0;
    _S109.diffuse_weight = diffuse_weight_0;
    _S109.refract_weight = refract_weight_0;
    _S109.p_diffuse = p_diffuse_0;
    _S109.p_reflect = p_reflect_0;
    _S109.p_refract = p_refract_0;
    return _S109;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S110 : f32 = dot(ggx_n_0, v_4);
    var _S111 : f32 = dot(n_i_1, ggx_n_0);
    var _S112 : f32 = eta_i_2 / eta_o_2;
    var _S113 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S112))));
    var _S114 : f32 = fresnel(abs(_S110), eta_i_2, eta_o_2);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S114)), (material_1.albedo), (material_1.metallic)));
    var _S115 : f32 = rgb_to_greyscale(F_1);
    var _S116 : f32 = 1.0f - material_1.metallic;
    var _S117 : f32 = 1.0f - _S114;
    var _S118 : f32 = (1.0f - material_1.transmission) * _S116 * _S117;
    var _S119 : f32 = material_1.transmission * _S116 * _S117;
    var _S120 : f32 = max(_S115, 0.0f);
    var _S121 : f32 = max(_S118, 0.0f);
    var _S122 : f32 = (sign((length(_S113))));
    var _S123 : f32 = max(_S119 * _S122, 0.0f);
    var _S124 : f32 = _S120 + _S121 + _S123;
    var _S125 : f32 = 1.0f / max(_S124, 0.0000152587890625f);
    var _S126 : f32 = _S121 * _S125;
    var _S127 : f32 = _S120 * _S125;
    var _S128 : f32 = _S123 * _S125;
    return BSDFLobes_x24init_0(_S110, _S111, _S113, F_1, _S115, 1.0f, _S118, _S119, _S126, _S127, _S128);
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S129 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S130 : bool = n_i_dot_v_0 > 0.0f;
    var _S131 : f32 = select(0.0f, _S129, _S130);
    return _S131;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_5 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S132 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S133 : f32 = _S132 * lobes_2.v_dot_h;
    var _S134 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S135 : f32 = _S133 * _S134 / n_i_dot_v_1;
    var _S136 : bool = alpha_6 > 0.0f;
    var _S137 : bool;
    if(_S136)
    {
        _S137 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S137 = false;
    }
    if(_S137)
    {
        _S137 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S137 = false;
    }
    if(_S137)
    {
        _S137 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S137 = false;
    }
    var _S138 : f32 = select(0.0f, _S135, _S137);
    return _S138;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S139 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S140 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S141 : f32 = lobes_3.p_refract * _S139 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S140 * _S140);
    var _S142 : bool = eta_i_4 != eta_o_4;
    var _S143 : bool;
    if(_S142)
    {
        _S143 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S143 = false;
    }
    var _S144 : f32 = select(0.0f, _S141, _S143);
    return _S144;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_8 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S145 : f32 = - dot(n_i_3, l_1);
    var _S146 : f32 = smithG1(alpha_8, max(_S145, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S146)) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S147 : f32 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    var _S148 : f32 = lobes_5.p_reflect * _S147 / (4.0f * lobes_5.v_dot_h);
    var _S149 : bool = _S147 > 0.0f;
    var _S150 : f32 = select(0.0f, _S148, _S149);
    return _S150;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_10 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S151 : f32 = dot(n_i_4, l_2);
    var _S152 : f32 = smithG1(alpha_10, max(_S151, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S152)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_2 : u32) -> vec3<f32>
{
    var _S153 : vec3<f32> = ((-(in_dir_4)));
    var _S154 : f32 = dot(n_5, _S153);
    var _S155 : f32 = (sign((_S154)));
    var _S156 : vec3<f32> = n_5 * vec3<f32>(_S155);
    var _S157 : f32 = dot(_S156, out_dir_2);
    var _S158 : f32 = material_5.roughness;
    var _S159 : f32 = _S158 * _S158;
    var _S160 : bool = (dot(g_n_0, _S153) * dot(g_n_0, out_dir_2)) > 0.0f;
    var _S161 : u32;
    if(_S160)
    {
        _S161 = u32(2);
    }
    else
    {
        _S161 = u32(1);
    }
    var _S162 : vec3<f32> = vec3<f32>(0.0f);
    var _S163 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S162, _S162, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S163;
    var ggx_n_1 : vec3<f32> = _S162;
    var f_0 : vec3<f32> = _S162;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < _S161)
        {
        }
        else
        {
            break;
        }
        var _S164 : u32;
        if(!_S160)
        {
            _S164 = u32(1);
        }
        else
        {
            if(i_0 == u32(0))
            {
                _S164 = u32(0);
            }
            else
            {
                _S164 = u32(2);
            }
        }
        var _S165 : bool = _S164 != half_of_0;
        var ggx_n_2 : vec3<f32>;
        if(_S165)
        {
            var _S166 : bool = _S164 == u32(0);
            if(_S166)
            {
                var _S167 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_2 = _S167;
            }
            else
            {
                var _S168 : bool = _S164 == u32(1);
                if(_S168)
                {
                    var _S169 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_2 = _S169;
                }
                else
                {
                    var _S170 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_2 = _S170;
                }
            }
            var _S171 : vec3<f32> = ((-(in_dir_4)));
            var _S172 : BSDFLobes = bsdfLobes(in_dir_4, _S171, _S156, ggx_n_2, material_5, eta_i_6, eta_o_6);
            lobe_terms_0 = _S172;
            half_of_0 = _S164;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        var throughput_0 : vec3<f32>;
        var pdf_0 : f32;
        switch(_S164)
        {
        case u32(0):
            {
                var _S173 : f32 = diffusePDF(_S157, 0.0f, abs(_S154), _S159, lobe_terms_0, eta_i_6, eta_o_6);
                var _S174 : vec3<f32> = diffuseBSDF(out_dir_2, _S156, _S159, material_5, lobe_terms_0);
                pdf_0 = _S173;
                throughput_0 = _S174;
            }
        case u32(1):
            {
                var _S175 : f32 = refractPDF(_S157, dot(out_dir_2, ggx_n_2), abs(_S154), _S159, lobe_terms_0, eta_i_6, eta_o_6);
                var _S176 : vec3<f32> = refractBSDF(out_dir_2, _S156, _S159, material_5, lobe_terms_0);
                pdf_0 = _S175;
                throughput_0 = _S176;
            }
        default :
            {
                var _S177 : f32 = reflectPDF(_S157, 0.0f, abs(_S154), _S159, lobe_terms_0, eta_i_6, eta_o_6);
                var _S178 : vec3<f32> = reflectBSDF(out_dir_2, _S156, _S159, material_5, lobe_terms_0);
                pdf_0 = _S177;
                throughput_0 = _S178;
            }
        }
        var _S179 : vec3<f32>;
        if(pdf_0 > 0.0f)
        {
            _S179 = throughput_0 * vec3<f32>(pdf_0);
        }
        else
        {
            _S179 = _S162;
        }
        if(i_0 == u32(0))
        {
            f_0 = _S179;
        }
        else
        {
            f_0 = f_0 + _S179;
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
    var _S180 : SampleBSDF;
    _S180.unit_direction = unit_direction_0;
    _S180.throughput = throughput_1;
    _S180.random_state = random_state_3;
    _S180.refracted = refracted_1;
    _S180.lobe = lobe_0;
    _S180.pdf = pdf_1;
    return _S180;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_11 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S181 : vec3<f32> = vec3<f32>(1.0f);
    var _S182 : SampleBSDF = SampleBSDF_x24init_0(_S181, _S181, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S182;
    var _S183 : Random = pcg(random_state_4);
    var _S184 : Random = pcg(_S183.state);
    sample_0.random_state = _S184.state;
    var _S185 : vec3<f32> = sampleCosWeightedHemisphere(_S183.value, _S184.value);
    var _S186 : vec3<f32> = tangentToWorld(_S185, n_i_5);
    sample_0.unit_direction = _S186;
    sample_0.lobe = u32(0);
    var _S187 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    sample_0.throughput = _S187;
    var _S188 : f32 = diffusePDF(_S185.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S188;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_12 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S189 : vec3<f32> = vec3<f32>(1.0f);
    var _S190 : SampleBSDF = SampleBSDF_x24init_0(_S189, _S189, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S190;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S191 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    sample_1.throughput = _S191;
    var _S192 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S192;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_13 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S193 : vec3<f32> = vec3<f32>(1.0f);
    var _S194 : SampleBSDF = SampleBSDF_x24init_0(_S193, _S193, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S194;
    var _S195 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S195;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S196 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    sample_2.throughput = _S196;
    var _S197 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S197;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S198 : vec3<f32> = ((-(in_dir_6)));
    var _S199 : f32 = dot(n_6, _S198);
    var _S200 : f32 = (sign((_S199)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S200);
    var _S201 : f32 = abs(_S199);
    var _S202 : f32 = material_9.roughness;
    var _S203 : f32 = _S202 * _S202;
    var _S204 : vec3<f32> = sampleHalfVector(_S198, n_i_8, _S203, &(random_state_7));
    var _S205 : BSDFLobes = bsdfLobes(in_dir_6, _S198, n_i_8, _S204, material_9, eta_i_10, eta_o_10);
    var _S206 : Random = pcg(random_state_7);
    random_state_7 = _S206.state;
    var _S207 : bool = (_S206.value) < (_S205.p_diffuse);
    if(_S207)
    {
        var _S208 : SampleBSDF = diffuseSample(n_i_8, _S201, _S203, material_9, _S205, eta_i_10, eta_o_10, random_state_7);
        return _S208;
    }
    var _S209 : bool = (_S206.value) < (_S205.p_diffuse + _S205.p_refract);
    if(_S209)
    {
        var _S210 : SampleBSDF = refractSample(_S204, n_i_8, _S201, _S203, material_9, _S205, eta_i_10, eta_o_10, random_state_7);
        return _S210;
    }
    var _S211 : SampleBSDF = reflectSample(in_dir_6, _S204, n_i_8, _S201, _S203, material_9, _S205, eta_i_10, eta_o_10, random_state_7);
    return _S211;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S212 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S212));
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S213 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S214 : vec3<f32> = (mix((vec3<f32>(_S213)), (material_10.albedo), (material_10.metallic)));
    var _S215 : f32 = rgb_to_greyscale(_S214);
    var _S216 : f32 = max((1.0f - _S215) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S217 : bool = _S216 > 0.03999999910593033f;
    var _S218 : bool;
    if(_S217)
    {
        _S218 = true;
    }
    else
    {
        _S218 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S218;
}

fn misWeighted( throughput_2 : vec3<f32>,  lobe_pdf_0 : f32,  pdf_2 : f32,  power_0 : bool) -> vec3<f32>
{
    if(power_0)
    {
        var _S219 : f32 = lobe_pdf_0 / pdf_2;
        return throughput_2 * vec3<f32>(lobe_pdf_0) / vec3<f32>((pdf_2 * (1.0f + _S219 * _S219)));
    }
    return throughput_2 * vec3<f32>(lobe_pdf_0) / vec3<f32>((lobe_pdf_0 + pdf_2));
}

fn neeLobes_0( in_dir_7 : vec3<f32>,  dir_0 : vec3<f32>,  n_7 : vec3<f32>,  material_11 : Material,  eta_i_12 : f32,  eta_o_12 : f32,  refracted_2 : bool,  pdf_3 : f32,  power_1 : bool,  random_state_8 : u32,  each_0 : ptr<function, array<vec3<f32>, i32(3)>>,  reached_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S220 : vec3<f32> = ((-(in_dir_7)));
    var _S221 : f32 = dot(n_7, _S220);
    var _S222 : f32 = (sign((_S221)));
    var _S223 : vec3<f32> = n_7 * vec3<f32>(_S222);
    var _S224 : f32 = dot(_S223, dir_0);
    var _S225 : f32 = material_11.roughness;
    var _S226 : f32 = _S225 * _S225;
    var _S227 : vec3<f32> = vec3<f32>(0.0f);
    (*reached_0) = u32(0);
    var _S228 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S227, _S227, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
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
        (*each_0)[i_2] = _S227;
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var half_of_1 : u32 = u32(4294967295);
    var lobe_terms_1 : BSDFLobes = _S228;
    var ggx_n_5 : vec3<f32> = _S227;
    i_2 = u32(0);
    var f_1 : vec3<f32> = _S227;
    loop
    {
        if(i_2 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S229 : bool = i_2 == u32(1);
        var _S230 : bool = _S229 == refracted_2;
        var ggx_n_6 : vec3<f32>;
        if(_S230)
        {
            var _S231 : bool = i_2 != half_of_1;
            var half_of_2 : u32;
            var lobe_terms_2 : BSDFLobes;
            if(_S231)
            {
                var _S232 : bool = i_2 == u32(0);
                if(_S232)
                {
                    var _S233 : vec3<f32> = sampledHalf(in_dir_7, n_7, material_11, random_state_8);
                    ggx_n_6 = _S233;
                }
                else
                {
                    if(_S229)
                    {
                        var _S234 : vec3<f32> = refractedHalf(in_dir_7, dir_0, n_7, eta_i_12, eta_o_12);
                        ggx_n_6 = _S234;
                    }
                    else
                    {
                        var _S235 : vec3<f32> = reflectedHalf(in_dir_7, dir_0);
                        ggx_n_6 = _S235;
                    }
                }
                var _S236 : vec3<f32> = ((-(in_dir_7)));
                var _S237 : BSDFLobes = bsdfLobes(in_dir_7, _S236, _S223, ggx_n_6, material_11, eta_i_12, eta_o_12);
                lobe_terms_2 = _S237;
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
                    var _S238 : f32 = diffusePDF(_S224, 0.0f, abs(_S221), _S226, lobe_terms_2, eta_i_12, eta_o_12);
                    var _S239 : vec3<f32> = diffuseBSDF(dir_0, _S223, _S226, material_11, lobe_terms_2);
                    lobe_pdf_1 = _S238;
                    throughput_3 = _S239;
                }
            case u32(1):
                {
                    var _S240 : f32 = refractPDF(_S224, dot(dir_0, ggx_n_6), abs(_S221), _S226, lobe_terms_2, eta_i_12, eta_o_12);
                    var _S241 : vec3<f32> = refractBSDF(dir_0, _S223, _S226, material_11, lobe_terms_2);
                    lobe_pdf_1 = _S240;
                    throughput_3 = _S241;
                }
            default :
                {
                    var _S242 : f32 = reflectPDF(_S224, 0.0f, abs(_S221), _S226, lobe_terms_2, eta_i_12, eta_o_12);
                    var _S243 : vec3<f32> = reflectBSDF(dir_0, _S223, _S226, material_11, lobe_terms_2);
                    lobe_pdf_1 = _S242;
                    throughput_3 = _S243;
                }
            }
            var _S244 : bool = lobe_pdf_1 > 0.0f;
            var f_2 : vec3<f32>;
            if(_S244)
            {
                var _S245 : vec3<f32> = misWeighted(throughput_3, lobe_pdf_1, pdf_3, power_1);
                (*each_0)[i_2] = _S245;
                var _S246 : u32 = ((*reached_0) | (((u32(1) << (i_2)))));
                (*reached_0) = _S246;
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
    var _S247 : vec3<f32> = neeLobes_0(in_dir_8, dir_1, n_8, material_12, eta_i_13, eta_o_13, refracted_3, pdf_4, power_2, random_state_9, &(each_1), &(reached_1));
    return _S247;
}

fn straightThrough( dir_2 : vec3<f32>,  n_9 : vec3<f32>,  material_13 : Material) -> vec3<f32>
{
    var _S248 : f32 = material_13.transmission * (1.0f - material_13.metallic);
    var _S249 : f32 = material_13.roughness;
    var _S250 : f32 = smithG1(_S249 * _S249, abs(dot(n_9, dir_2)));
    return vec3<f32>((_S248 * _S250)) * material_13.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S251 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S251 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_10 : vec3<f32>,  material_14 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S252 : vec3<f32>;
    if((material_14.ior) == 1.0f)
    {
        var _S253 : vec3<f32> = straightThrough(toward_0, n_10, material_14);
        _S252 = _S253;
    }
    else
    {
        _S252 = vec3<f32>(0.0f);
    }
    return _S252 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S254 : u32 = hash(index_0);
    var _S255 : u32 = hash((seed_0 ^ (_S254)));
    return _S255;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S256 : vec3<f32> = a_4 / b_0;
    var _S257 : vec3<f32> = vec3<f32>(0.0f);
    var _S258 : vec3<bool> = b_0 == _S257;
    var _S259 : vec3<f32> = select(_S256, _S257, _S258);
    return _S259;
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
    var _S260 : f32 = rgb_to_greyscale(weight_0);
    var _S261 : bool = _S260 > 0.0f;
    var _S262 : bool;
    if(_S261)
    {
        _S262 = _S260 < 3.00000000549775576e+38f;
    }
    else
    {
        _S262 = false;
    }
    var _S263 : bool = !_S262;
    if(_S263)
    {
        return;
    }
    var _S264 : f32 = (*sel_0).w_sum + _S260;
    (*sel_0).w_sum = _S264;
    var _S265 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S265;
    var _S266 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S266.state;
    var _S267 : bool = (_S266.value * (*sel_0).w_sum) <= _S260;
    if(_S267)
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
    var _S268 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S268;
    var _S269 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S269;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S270 : f32 = rgb_to_greyscale(r_1.f);
    var _S271 : f32 = sel_2.w_sum / _S270;
    var _S272 : bool = _S270 > 0.0f;
    var _S273 : f32 = select(0.0f, _S271, _S272);
    r_1.w = _S273;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S274 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S275 : u32 = (insertBits((_S274), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S275;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S276 : bool = transmission_0 > 0.0f;
    var _S277 : bool;
    if(_S276)
    {
        _S277 = true;
    }
    else
    {
        _S277 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S278 : f32;
    if(_S277)
    {
        _S278 = 1.0f;
    }
    else
    {
        _S278 = -1.0f;
    }
    return _S278;
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
    var _S279 : bool;
    if(open_0)
    {
        _S279 = prev_rough_0;
    }
    else
    {
        _S279 = false;
    }
    if(_S279)
    {
        _S279 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S279 = false;
    }
    return _S279;
}

fn withinInverseFootprint( pdf_5 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S280 : bool = pdf_5 > 0.0f;
    var _S281 : bool;
    if(_S280)
    {
        if(diffuse_0)
        {
            _S281 = true;
        }
        else
        {
            _S281 = (pdf_5 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S281 = false;
    }
    return _S281;
}

fn roughLobe( pdf_6 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S282 : bool = pdf_6 > 0.0f;
    var _S283 : bool;
    if(_S282)
    {
        if(diffuse_1)
        {
            _S283 = true;
        }
        else
        {
            _S283 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S283 = false;
    }
    return _S283;
}

fn survivalProbability( throughput_4 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S284 : vec3<f32> = throughput_4 / vec3<f32>(density_0);
    return clamp(max(_S284.x, max(_S284.y, _S284.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S285 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S285;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S286 : f32 = c_1 * p_c_0;
    var _S287 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S286 / (_S286 + c_t_0 * g_previous_0), _S287 / (_S287 + c_1 * g_current_0));
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
    var _S288 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S289 : bool = cos_a_0 > cos_b_0;
    var _S290 : f32 = select(_S288, 1.0f, _S289);
    return _S290;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S291 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S292 : bool = cos_a_1 > cos_b_1;
    var _S293 : f32 = select(_S291, 0.0f, _S292);
    return _S293;
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
    var _S294 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S295 : vec3<f32> = node_0.high - node_0.low;
    var _S296 : vec3<f32> = p_0 - _S294;
    var _S297 : vec3<f32> = (normalize((_S296)));
    var _S298 : f32 = dot(_S296, _S296);
    var _S299 : f32 = dot(_S295, _S295) / 4.0f;
    var _S300 : f32 = abs(dot(node_0.w, _S297));
    var _S301 : f32 = sine(node_0.cos_theta_o);
    var _S302 : f32 = sqrt(max(1.0f - _S299 / _S298, 0.0f));
    var _S303 : bool = _S298 < _S299;
    var _S304 : f32 = select(_S302, -1.0f, _S303);
    var _S305 : f32 = sine(_S304);
    var _S306 : f32 = sine(_S300);
    var _S307 : f32 = cosSubClamped(_S306, _S300, _S301, node_0.cos_theta_o);
    var _S308 : f32 = sine(_S300);
    var _S309 : f32 = sinSubClamped(_S308, _S300, _S301, node_0.cos_theta_o);
    var _S310 : f32 = cosSubClamped(_S309, _S307, _S305, _S304);
    var _S311 : bool = _S310 <= 0.0f;
    if(_S311)
    {
        return 0.0f;
    }
    var _S312 : f32 = - dot(_S297, normal_0);
    var _S313 : f32 = node_0.phi * _S310 / max(_S298, length(_S295) / 2.0f);
    var _S314 : f32 = sine(_S312);
    var _S315 : f32 = cosSubClamped(_S314, _S312, _S305, _S304);
    var _S316 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S317 : f32 = select(_S315, 1.0f, _S316);
    return max(_S313 * _S317, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S318 : f32 = importance(first_0, p_1, normal_2);
    var _S319 : f32 = importance(second_0, p_1, normal_2);
    var _S320 : vec2<f32> = vec2<f32>(_S318, _S319);
    var _S321 : bool = _S318 == 0.0f;
    var _S322 : bool;
    if(_S321)
    {
        _S322 = _S319 == 0.0f;
    }
    else
    {
        _S322 = false;
    }
    if(_S322)
    {
        return u32(2);
    }
    var _S323 : f32 = _S318 + _S319;
    var _S324 : bool = _S319 > 0.0f;
    if(_S324)
    {
        _S322 = ((*pick_0) * _S323) >= _S318;
    }
    else
    {
        _S322 = false;
    }
    var _S325 : u32 = select(u32(0), u32(1), _S322);
    var _S326 : f32 = min(((*pick_0) * _S323 - f32(_S325) * _S318) / _S320[_S325], 0.99999994039535522f);
    (*pick_0) = _S326;
    var _S327 : f32 = (*probability_1) * (_S320[_S325] / _S323);
    (*probability_1) = _S327;
    return _S325;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S328 : f32 = importance(first_1, p_2, normal_3);
    var _S329 : f32 = importance(second_1, p_2, normal_3);
    var _S330 : vec2<f32> = vec2<f32>(_S328, _S329);
    var _S331 : f32 = _S330[child_0] / (_S328 + _S329);
    var _S332 : bool = (_S330[child_0]) > 0.0f;
    var _S333 : f32 = select(0.0f, _S331, _S332);
    return _S333;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S334 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S335 : bool = b_1 > 0.0f;
    var _S336 : f32 = select(1.0f, _S334, _S335);
    return _S336;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S337 : vec3<f32> = center_0 - p_3;
    var _S338 : f32 = radius_1 * radius_1 / dot(_S337, _S337);
    var _S339 : bool = _S338 >= 1.0f;
    if(_S339)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S338)) / (6.28318548202514648f * _S338);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S340 : vec3<f32> = center_1 - p_4;
    var _S341 : f32 = radius_2 * radius_2 / dot(_S340, _S340);
    var _S342 : f32 = u1_0 * _S341 / (1.0f + sqrt(max(1.0f - _S341, 0.0f)));
    var _S343 : f32 = 2.0f * u1_0;
    var _S344 : bool = _S341 >= 1.0f;
    var _S345 : f32 = select(_S342, _S343, _S344);
    var _S346 : f32 = sqrt(max(_S345 * (2.0f - _S345), 0.0f));
    var _S347 : f32 = 6.28318548202514648f * u2_0;
    var _S348 : vec3<f32> = vec3<f32>(_S346 * cos(_S347), 1.0f - _S345, _S346 * sin(_S347));
    var _S349 : vec3<f32> = (normalize((_S340)));
    var _S350 : vec3<f32> = tangentToWorld(_S348, _S349);
    return _S350;
}

