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
        var _S23 : bool = eta_i_0 == eta_o_0;
        var _S24 : f32 = select(_S22, cos_theta_0, _S23);
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

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S32 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
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
    var _S51 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S50.x, alpha_3 * _S50.y, max(0.0f, _S50.z)))));
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
    var _S77 : vec3<f32> = t_0 - n_2 * vec3<f32>(dot(n_2, t_0));
    var _S78 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_2);
    var _S79 : bool = (dot(_S77, _S77)) > 0.0f;
    var _S80 : vec3<f32> = select(_S78, _S77, _S79);
    var _S81 : vec3<f32> = (normalize((_S80)));
    var _S82 : bool = (dot(cross(n_2, _S81), _S76)) > 0.0f;
    var t_1 : vec3<f32>;
    if(_S82)
    {
        var _S83 : vec3<f32> = ((-(_S81)));
        t_1 = _S83;
    }
    else
    {
        t_1 = _S81;
    }
    var _S84 : vec3<f32> = cross(n_2, t_1);
    return mat3x3<f32>(t_1, _S84, n_2);
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

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S91 : vec3<f32> = ((-(in_dir_0)));
    var _S92 : f32 = (sign((dot(n_3, _S91))));
    var _S93 : f32 = material_0.roughness;
    var _S94 : vec3<f32> = sampleHalfVector(_S91, n_3 * vec3<f32>(_S92), _S93 * _S93, &(state_5));
    return _S94;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S95 : vec3<f32> = ((-(in_dir_1)));
    var _S96 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S95 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S97 : vec3<f32> = (normalize((_S96)));
    var _S98 : f32 = (sign((dot(n_4, _S95))));
    var _S99 : f32 = (sign((dot(_S96, n_4 * vec3<f32>(_S98)))));
    return _S97 * vec3<f32>(_S99);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S100 : vec3<f32> = ((-(in_dir_2)));
    var _S101 : vec3<f32> = (normalize((_S100 + out_dir_1)));
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

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S103 : f32 = dot(ggx_n_0, v_4);
    var _S104 : f32 = dot(n_i_1, ggx_n_0);
    var _S105 : f32 = eta_i_2 / eta_o_2;
    var _S106 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S105))));
    var _S107 : f32 = fresnel(abs(_S103), eta_i_2, eta_o_2);
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

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S121 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S122 : bool = n_i_dot_v_0 > 0.0f;
    var _S123 : f32 = select(0.0f, _S121, _S122);
    return _S123;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_7 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S124 : f32 = smithG1(alpha_7, n_i_dot_v_1);
    var _S125 : f32 = _S124 * lobes_2.v_dot_h;
    var _S126 : f32 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    var _S127 : f32 = _S125 * _S126 / n_i_dot_v_1;
    var _S128 : bool = alpha_7 > 0.0f;
    var _S129 : bool;
    if(_S128)
    {
        _S129 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S129 = false;
    }
    if(_S129)
    {
        _S129 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S129 = false;
    }
    if(_S129)
    {
        _S129 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S129 = false;
    }
    var _S130 : f32 = select(0.0f, _S127, _S129);
    return _S130;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_8 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S131 : f32 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    var _S132 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S133 : f32 = lobes_3.p_refract * _S131 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S132 * _S132);
    var _S134 : bool = eta_i_4 != eta_o_4;
    var _S135 : bool;
    if(_S134)
    {
        _S135 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S135 = false;
    }
    var _S136 : f32 = select(0.0f, _S133, _S135);
    return _S136;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_9 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S137 : f32 = - dot(n_i_3, l_1);
    var _S138 : f32 = G1(alpha_9, max(_S137, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S138 * (1.0f - lobes_4.F_greyscale))) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_10 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S139 : f32 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    var _S140 : f32 = lobes_5.p_reflect * _S139 / (4.0f * lobes_5.v_dot_h);
    var _S141 : bool = _S139 > 0.0f;
    var _S142 : f32 = select(0.0f, _S140, _S141);
    return _S142;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_11 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S143 : f32 = dot(n_i_4, l_2);
    var _S144 : f32 = G1(alpha_11, max(_S143, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S144)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(3)>>,  pdfs_0 : ptr<function, array<f32, i32(3)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S145 : vec3<f32> = ((-(in_dir_4)));
    var _S146 : f32 = dot(n_5, _S145);
    var _S147 : f32 = (sign((_S146)));
    var _S148 : vec3<f32> = n_5 * vec3<f32>(_S147);
    var _S149 : f32 = dot(_S148, out_dir_2);
    var _S150 : f32 = material_5.roughness;
    var _S151 : f32 = _S150 * _S150;
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
        var _S152 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S152;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S153 : vec3<f32> = vec3<f32>(0.0f);
    var _S154 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S153, _S153, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S154;
    var ggx_n_2 : vec3<f32> = _S153;
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
        var _S155 : bool = i_0 == u32(1);
        var _S156 : bool = _S155 != refracted_1;
        if(_S156)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S157 : bool = i_0 != half_of_0;
        var half_of_1 : u32;
        var lobe_terms_1 : BSDFLobes;
        if(_S157)
        {
            var _S158 : bool = i_0 == u32(0);
            if(_S158)
            {
                var _S159 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_1 = _S159;
            }
            else
            {
                if(_S155)
                {
                    var _S160 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_1 = _S160;
                }
                else
                {
                    var _S161 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S161;
                }
            }
            var _S162 : vec3<f32> = ((-(in_dir_4)));
            var _S163 : BSDFLobes = bsdfLobes(in_dir_4, _S162, _S148, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S163;
            half_of_1 = i_0;
        }
        else
        {
            lobe_terms_1 = lobe_terms_0;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(i_0)
        {
        case u32(0):
            {
                var _S164 : f32 = diffusePDF(_S149, 0.0f, abs(_S146), _S151, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(0)] = _S164;
                var _S165 : vec3<f32> = diffuseBSDF(out_dir_2, _S148, _S151, material_5, lobe_terms_1);
                (*throughputs_0)[i32(0)] = _S165;
            }
        case u32(1):
            {
                var _S166 : f32 = refractPDF(_S149, dot(out_dir_2, ggx_n_1), abs(_S146), _S151, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(1)] = _S166;
                var _S167 : vec3<f32> = refractBSDF(out_dir_2, _S148, _S151, material_5, lobe_terms_1);
                (*throughputs_0)[i32(1)] = _S167;
            }
        default :
            {
                var _S168 : f32 = reflectPDF(_S149, 0.0f, abs(_S146), _S151, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(2)] = _S168;
                var _S169 : vec3<f32> = reflectBSDF(out_dir_2, _S148, _S151, material_5, lobe_terms_1);
                (*throughputs_0)[i32(2)] = _S169;
            }
        }
        half_of_0 = half_of_1;
        lobe_terms_0 = lobe_terms_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S153;
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S170 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S170)
        {
            var f_0 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_0;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
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
    var _S171 : SampleBSDF;
    _S171.unit_direction = unit_direction_0;
    _S171.throughput = throughput_0;
    _S171.random_state = random_state_3;
    _S171.refracted = refracted_2;
    _S171.lobe = lobe_0;
    _S171.pdf = pdf_0;
    return _S171;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_12 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S172 : vec3<f32> = vec3<f32>(1.0f);
    var _S173 : SampleBSDF = SampleBSDF_x24init_0(_S172, _S172, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S173;
    var _S174 : Random = pcg(random_state_4);
    var _S175 : Random = pcg(_S174.state);
    sample_0.random_state = _S175.state;
    var _S176 : vec3<f32> = sampleCosWeightedHemisphere(_S174.value, _S175.value);
    var _S177 : vec3<f32> = tangentToWorld(_S176, n_i_5);
    sample_0.unit_direction = _S177;
    sample_0.lobe = u32(0);
    var _S178 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    sample_0.throughput = _S178;
    var _S179 : f32 = diffusePDF(_S176.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S179;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S180 : vec3<f32> = vec3<f32>(1.0f);
    var _S181 : SampleBSDF = SampleBSDF_x24init_0(_S180, _S180, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S181;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S182 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    sample_1.throughput = _S182;
    var _S183 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S183;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S184 : vec3<f32> = vec3<f32>(1.0f);
    var _S185 : SampleBSDF = SampleBSDF_x24init_0(_S184, _S184, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S185;
    var _S186 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S186;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S187 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    sample_2.throughput = _S187;
    var _S188 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S188;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S189 : vec3<f32> = ((-(in_dir_6)));
    var _S190 : f32 = dot(n_6, _S189);
    var _S191 : f32 = (sign((_S190)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S191);
    var _S192 : f32 = abs(_S190);
    var _S193 : f32 = material_9.roughness;
    var _S194 : f32 = _S193 * _S193;
    var _S195 : vec3<f32> = sampleHalfVector(_S189, n_i_8, _S194, &(random_state_7));
    var _S196 : BSDFLobes = bsdfLobes(in_dir_6, _S189, n_i_8, _S195, material_9, eta_i_10, eta_o_10);
    var _S197 : Random = pcg(random_state_7);
    random_state_7 = _S197.state;
    var _S198 : bool = (_S197.value) < (_S196.p_diffuse);
    if(_S198)
    {
        var _S199 : SampleBSDF = diffuseSample(n_i_8, _S192, _S194, material_9, _S196, eta_i_10, eta_o_10, random_state_7);
        return _S199;
    }
    var _S200 : bool = (_S197.value) < (_S196.p_diffuse + _S196.p_refract);
    if(_S200)
    {
        var _S201 : SampleBSDF = refractSample(_S195, n_i_8, _S192, _S194, material_9, _S196, eta_i_10, eta_o_10, random_state_7);
        return _S201;
    }
    var _S202 : SampleBSDF = reflectSample(in_dir_6, _S195, n_i_8, _S192, _S194, material_9, _S196, eta_i_10, eta_o_10, random_state_7);
    return _S202;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S203 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S203));
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S204 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S205 : vec3<f32> = (mix((vec3<f32>(_S204)), (material_10.albedo), (material_10.metallic)));
    var _S206 : f32 = rgb_to_greyscale(_S205);
    var _S207 : f32 = max((1.0f - _S206) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S208 : bool = _S207 > 0.03999999910593033f;
    var _S209 : bool;
    if(_S208)
    {
        _S209 = true;
    }
    else
    {
        _S209 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S209;
}

fn straightThrough( material_11 : Material) -> vec3<f32>
{
    var _S210 : f32 = rgb_to_greyscale(material_11.albedo * vec3<f32>(material_11.metallic));
    return vec3<f32>((material_11.transmission * (1.0f - _S210))) * material_11.albedo;
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

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S231 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S232 : u32 = (insertBits((_S231), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S232;
    candidate_2.f = f_1;
    return candidate_2;
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S233 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S234 : bool = cos_a_0 > cos_b_0;
    var _S235 : f32 = select(_S233, 1.0f, _S234);
    return _S235;
}

fn sine( c_1 : f32) -> f32
{
    return sqrt(max(1.0f - c_1 * c_1, 0.0f));
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
    var _S236 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S237 : vec3<f32> = node_0.high - node_0.low;
    var _S238 : vec3<f32> = p_0 - _S236;
    var _S239 : vec3<f32> = (normalize((_S238)));
    var _S240 : f32 = dot(_S238, _S238);
    var _S241 : f32 = dot(_S237, _S237) / 4.0f;
    var _S242 : f32 = abs(dot(node_0.w, _S239));
    var _S243 : f32 = sine(node_0.cos_theta_o);
    var _S244 : f32 = sqrt(max(1.0f - _S241 / _S240, 0.0f));
    var _S245 : bool = _S240 < _S241;
    var _S246 : f32 = select(_S244, -1.0f, _S245);
    var _S247 : f32 = sine(_S246);
    var _S248 : f32 = sine(_S242);
    var _S249 : f32 = cosSubClamped(_S248, _S242, _S243, node_0.cos_theta_o);
    var _S250 : f32 = sine(_S242);
    var _S251 : f32 = _S250 * node_0.cos_theta_o - _S242 * _S243;
    var _S252 : bool = _S242 > (node_0.cos_theta_o);
    var _S253 : f32 = select(_S251, 0.0f, _S252);
    var _S254 : f32 = cosSubClamped(_S253, _S249, _S247, _S246);
    var _S255 : bool = _S254 <= 0.0f;
    if(_S255)
    {
        return 0.0f;
    }
    var _S256 : f32 = - dot(_S239, normal_0);
    var _S257 : f32 = node_0.phi * _S254 / max(_S240, length(_S237) / 2.0f);
    var _S258 : f32 = sine(_S256);
    var _S259 : f32 = cosSubClamped(_S258, _S256, _S247, _S246);
    var _S260 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S261 : f32 = select(_S259, 1.0f, _S260);
    return max(_S257 * _S261, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_1, toward_0));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S262 : f32 = importance(first_0, p_1, normal_2);
    var _S263 : f32 = importance(second_0, p_1, normal_2);
    var _S264 : vec2<f32> = vec2<f32>(_S262, _S263);
    var _S265 : bool = _S262 == 0.0f;
    var _S266 : bool;
    if(_S265)
    {
        _S266 = _S263 == 0.0f;
    }
    else
    {
        _S266 = false;
    }
    if(_S266)
    {
        return u32(2);
    }
    var _S267 : f32 = _S262 + _S263;
    var _S268 : bool = _S263 > 0.0f;
    if(_S268)
    {
        _S266 = ((*pick_0) * _S267) >= _S262;
    }
    else
    {
        _S266 = false;
    }
    var _S269 : u32 = select(u32(0), u32(1), _S266);
    var _S270 : f32 = min(((*pick_0) * _S267 - f32(_S269) * _S262) / _S264[_S269], 0.99999994039535522f);
    (*pick_0) = _S270;
    var _S271 : f32 = (*probability_1) * (_S264[_S269] / _S267);
    (*probability_1) = _S271;
    return _S269;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S272 : f32 = importance(first_1, p_2, normal_3);
    var _S273 : f32 = importance(second_1, p_2, normal_3);
    var _S274 : vec2<f32> = vec2<f32>(_S272, _S273);
    var _S275 : f32 = _S274[child_0] / (_S272 + _S273);
    var _S276 : bool = (_S274[child_0]) > 0.0f;
    var _S277 : f32 = select(0.0f, _S275, _S276);
    return _S277;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S278 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S279 : bool = b_1 > 0.0f;
    var _S280 : f32 = select(1.0f, _S278, _S279);
    return _S280;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S281 : vec3<f32> = center_0 - p_3;
    var _S282 : f32 = radius_1 * radius_1 / dot(_S281, _S281);
    var _S283 : bool = _S282 >= 1.0f;
    if(_S283)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S282)) / (6.28318548202514648f * _S282);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S284 : vec3<f32> = center_1 - p_4;
    var _S285 : f32 = radius_2 * radius_2 / dot(_S284, _S284);
    var _S286 : f32 = u1_0 * _S285 / (1.0f + sqrt(max(1.0f - _S285, 0.0f)));
    var _S287 : f32 = 2.0f * u1_0;
    var _S288 : bool = _S285 >= 1.0f;
    var _S289 : f32 = select(_S286, _S287, _S288);
    var _S290 : f32 = sqrt(max(_S289 * (2.0f - _S289), 0.0f));
    var _S291 : f32 = 6.28318548202514648f * u2_0;
    var _S292 : vec3<f32> = vec3<f32>(_S290 * cos(_S291), 1.0f - _S289, _S290 * sin(_S291));
    var _S293 : vec3<f32> = (normalize((_S284)));
    var _S294 : vec3<f32> = tangentToWorld(_S292, _S293);
    return _S294;
}

