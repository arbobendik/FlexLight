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

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S80 : Random = pcg((*random_state_0));
    var _S81 : Random = pcg(_S80.state);
    (*random_state_0) = _S81.state;
    var _S82 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S83 : vec3<f32> = sampleGGXVNDF(_S82.xzy, alpha_4, _S80.value, _S81.value);
    var _S84 : vec3<f32> = _S83.xzy;
    var _S85 : vec3<f32> = tangentToWorld(_S84, n_i_0);
    return _S85;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S86 : vec3<f32> = ((-(in_dir_0)));
    var _S87 : f32 = (sign((dot(n_3, _S86))));
    var _S88 : f32 = material_0.roughness;
    var _S89 : vec3<f32> = sampleHalfVector(_S86, n_3 * vec3<f32>(_S87), _S88 * _S88, &(state_5));
    return _S89;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S90 : vec3<f32> = ((-(in_dir_1)));
    var _S91 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S90 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S92 : vec3<f32> = (normalize((_S91)));
    var _S93 : f32 = (sign((dot(n_4, _S90))));
    var _S94 : f32 = (sign((dot(_S91, n_4 * vec3<f32>(_S93)))));
    return _S92 * vec3<f32>(_S94);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S95 : vec3<f32> = ((-(in_dir_2)));
    var _S96 : vec3<f32> = (normalize((_S95 + out_dir_1)));
    return _S96;
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
    var _S97 : BSDFLobes;
    _S97.v_dot_h = v_dot_h_0;
    _S97.n_dot_h = n_dot_h_1;
    _S97.refracted = refracted_0;
    _S97.F = F_0;
    _S97.F_greyscale = F_greyscale_0;
    _S97.reflect_weight = reflect_weight_0;
    _S97.diffuse_weight = diffuse_weight_0;
    _S97.refract_weight = refract_weight_0;
    _S97.p_diffuse = p_diffuse_0;
    _S97.p_reflect = p_reflect_0;
    _S97.p_refract = p_refract_0;
    return _S97;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S98 : f32 = dot(ggx_n_0, v_4);
    var _S99 : f32 = dot(n_i_1, ggx_n_0);
    var _S100 : f32 = eta_i_2 / eta_o_2;
    var _S101 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S100))));
    var _S102 : f32 = fresnel(abs(_S98), eta_i_2, eta_o_2);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S102)), (material_1.albedo), (material_1.metallic)));
    var _S103 : f32 = rgb_to_greyscale(F_1);
    var _S104 : f32 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    var _S105 : f32 = max(_S103, 0.0f);
    var _S106 : f32 = 1.0f - _S103;
    var _S107 : f32 = max(_S104 * _S106, 0.0f);
    var _S108 : f32 = material_1.transmission * _S106;
    var _S109 : f32 = (sign((length(_S101))));
    var _S110 : f32 = max(_S108 * _S109, 0.0f);
    var _S111 : f32 = _S105 + _S107 + _S110;
    var _S112 : f32 = 1.0f / max(_S111, 0.0000152587890625f);
    var _S113 : f32 = _S107 * _S112;
    var _S114 : f32 = _S105 * _S112;
    var _S115 : f32 = _S110 * _S112;
    return BSDFLobes_x24init_0(_S98, _S99, _S101, F_1, _S103, 1.0f, _S104, material_1.transmission, _S113, _S114, _S115);
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_5 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S116 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S117 : bool = n_i_dot_v_0 > 0.0f;
    var _S118 : f32 = select(0.0f, _S116, _S117);
    return _S118;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_7 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S119 : f32 = smithG1(alpha_7, n_i_dot_v_1);
    var _S120 : f32 = _S119 * lobes_2.v_dot_h;
    var _S121 : f32 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    var _S122 : f32 = _S120 * _S121 / n_i_dot_v_1;
    var _S123 : bool = alpha_7 > 0.0f;
    var _S124 : bool;
    if(_S123)
    {
        _S124 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    if(_S124)
    {
        _S124 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    if(_S124)
    {
        _S124 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    var _S125 : f32 = select(0.0f, _S122, _S124);
    return _S125;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_8 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S126 : f32 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    var _S127 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S128 : f32 = lobes_3.p_refract * _S126 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S127 * _S127);
    var _S129 : bool = eta_i_4 != eta_o_4;
    var _S130 : bool;
    if(_S129)
    {
        _S130 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S130 = false;
    }
    var _S131 : f32 = select(0.0f, _S128, _S130);
    return _S131;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_9 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S132 : f32 = - dot(n_i_3, l_1);
    var _S133 : f32 = G1(alpha_9, max(_S132, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S133 * (1.0f - lobes_4.F_greyscale))) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_10 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S134 : f32 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    var _S135 : f32 = lobes_5.p_reflect * _S134 / (4.0f * lobes_5.v_dot_h);
    var _S136 : bool = _S134 > 0.0f;
    var _S137 : f32 = select(0.0f, _S135, _S136);
    return _S137;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_11 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S138 : f32 = dot(n_i_4, l_2);
    var _S139 : f32 = G1(alpha_11, max(_S138, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S139)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(3)>>,  pdfs_0 : ptr<function, array<f32, i32(3)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S140 : vec3<f32> = ((-(in_dir_4)));
    var _S141 : f32 = dot(n_5, _S140);
    var _S142 : f32 = (sign((_S141)));
    var _S143 : vec3<f32> = n_5 * vec3<f32>(_S142);
    var _S144 : f32 = dot(_S143, out_dir_2);
    var _S145 : f32 = material_5.roughness;
    var _S146 : f32 = _S145 * _S145;
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
        var _S147 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S147;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S148 : vec3<f32> = vec3<f32>(0.0f);
    var _S149 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S148, _S148, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S149;
    var ggx_n_2 : vec3<f32> = _S148;
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
        var _S150 : bool = i_0 == u32(1);
        var _S151 : bool = _S150 != refracted_1;
        if(_S151)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S152 : bool = i_0 != half_of_0;
        var half_of_1 : u32;
        var lobe_terms_1 : BSDFLobes;
        if(_S152)
        {
            var _S153 : bool = i_0 == u32(0);
            if(_S153)
            {
                var _S154 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_1 = _S154;
            }
            else
            {
                if(_S150)
                {
                    var _S155 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_1 = _S155;
                }
                else
                {
                    var _S156 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S156;
                }
            }
            var _S157 : vec3<f32> = ((-(in_dir_4)));
            var _S158 : BSDFLobes = bsdfLobes(in_dir_4, _S157, _S143, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S158;
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
                var _S159 : f32 = diffusePDF(_S144, 0.0f, abs(_S141), _S146, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(0)] = _S159;
                var _S160 : vec3<f32> = diffuseBSDF(out_dir_2, _S143, _S146, material_5, lobe_terms_1);
                (*throughputs_0)[i32(0)] = _S160;
            }
        case u32(1):
            {
                var _S161 : f32 = refractPDF(_S144, dot(out_dir_2, ggx_n_1), abs(_S141), _S146, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(1)] = _S161;
                var _S162 : vec3<f32> = refractBSDF(out_dir_2, _S143, _S146, material_5, lobe_terms_1);
                (*throughputs_0)[i32(1)] = _S162;
            }
        default :
            {
                var _S163 : f32 = reflectPDF(_S144, 0.0f, abs(_S141), _S146, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(2)] = _S163;
                var _S164 : vec3<f32> = reflectBSDF(out_dir_2, _S143, _S146, material_5, lobe_terms_1);
                (*throughputs_0)[i32(2)] = _S164;
            }
        }
        half_of_0 = half_of_1;
        lobe_terms_0 = lobe_terms_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S148;
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S165 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S165)
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
    var _S166 : SampleBSDF;
    _S166.unit_direction = unit_direction_0;
    _S166.throughput = throughput_0;
    _S166.random_state = random_state_3;
    _S166.refracted = refracted_2;
    _S166.lobe = lobe_0;
    _S166.pdf = pdf_0;
    return _S166;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_12 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S167 : vec3<f32> = vec3<f32>(1.0f);
    var _S168 : SampleBSDF = SampleBSDF_x24init_0(_S167, _S167, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S168;
    var _S169 : Random = pcg(random_state_4);
    var _S170 : Random = pcg(_S169.state);
    sample_0.random_state = _S170.state;
    var _S171 : vec3<f32> = sampleCosWeightedHemisphere(_S169.value, _S170.value);
    var _S172 : vec3<f32> = tangentToWorld(_S171, n_i_5);
    sample_0.unit_direction = _S172;
    sample_0.lobe = u32(0);
    var _S173 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    sample_0.throughput = _S173;
    var _S174 : f32 = diffusePDF(_S171.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S174;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S175 : vec3<f32> = vec3<f32>(1.0f);
    var _S176 : SampleBSDF = SampleBSDF_x24init_0(_S175, _S175, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S176;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S177 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    sample_1.throughput = _S177;
    var _S178 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S178;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S179 : vec3<f32> = vec3<f32>(1.0f);
    var _S180 : SampleBSDF = SampleBSDF_x24init_0(_S179, _S179, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S180;
    var _S181 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S181;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S182 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    sample_2.throughput = _S182;
    var _S183 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S183;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S184 : vec3<f32> = ((-(in_dir_6)));
    var _S185 : f32 = dot(n_6, _S184);
    var _S186 : f32 = (sign((_S185)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S186);
    var _S187 : f32 = abs(_S185);
    var _S188 : f32 = material_9.roughness;
    var _S189 : f32 = _S188 * _S188;
    var _S190 : vec3<f32> = sampleHalfVector(_S184, n_i_8, _S189, &(random_state_7));
    var _S191 : BSDFLobes = bsdfLobes(in_dir_6, _S184, n_i_8, _S190, material_9, eta_i_10, eta_o_10);
    var _S192 : Random = pcg(random_state_7);
    random_state_7 = _S192.state;
    var _S193 : bool = (_S192.value) < (_S191.p_diffuse);
    if(_S193)
    {
        var _S194 : SampleBSDF = diffuseSample(n_i_8, _S187, _S189, material_9, _S191, eta_i_10, eta_o_10, random_state_7);
        return _S194;
    }
    var _S195 : bool = (_S192.value) < (_S191.p_diffuse + _S191.p_refract);
    if(_S195)
    {
        var _S196 : SampleBSDF = refractSample(_S190, n_i_8, _S187, _S189, material_9, _S191, eta_i_10, eta_o_10, random_state_7);
        return _S196;
    }
    var _S197 : SampleBSDF = reflectSample(in_dir_6, _S190, n_i_8, _S187, _S189, material_9, _S191, eta_i_10, eta_o_10, random_state_7);
    return _S197;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S198 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S198));
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S199 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S200 : vec3<f32> = (mix((vec3<f32>(_S199)), (material_10.albedo), (material_10.metallic)));
    var _S201 : f32 = rgb_to_greyscale(_S200);
    var _S202 : f32 = max((1.0f - _S201) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S203 : bool = _S202 > 0.03999999910593033f;
    var _S204 : bool;
    if(_S203)
    {
        _S204 = true;
    }
    else
    {
        _S204 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S204;
}

fn straightThrough( dir_0 : vec3<f32>,  n_7 : vec3<f32>,  material_11 : Material) -> vec3<f32>
{
    var _S205 : f32 = rgb_to_greyscale(material_11.albedo * vec3<f32>(material_11.metallic));
    var _S206 : f32 = material_11.roughness;
    var _S207 : f32 = G1(_S206 * _S206, abs(dot(n_7, dir_0)));
    return vec3<f32>((material_11.transmission * _S207 * (1.0f - _S205))) * material_11.albedo;
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S208 : u32 = hash(index_0);
    var _S209 : u32 = hash((seed_0 ^ (_S208)));
    return _S209;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S210 : vec3<f32> = a_4 / b_0;
    var _S211 : vec3<f32> = vec3<f32>(0.0f);
    var _S212 : vec3<bool> = b_0 == _S211;
    var _S213 : vec3<f32> = select(_S210, _S211, _S212);
    return _S213;
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
    var _S214 : f32 = rgb_to_greyscale(weight_0);
    var _S215 : bool = _S214 > 0.0f;
    var _S216 : bool;
    if(_S215)
    {
        _S216 = _S214 < 3.00000000549775576e+38f;
    }
    else
    {
        _S216 = false;
    }
    var _S217 : bool = !_S216;
    if(_S217)
    {
        return;
    }
    var _S218 : f32 = (*sel_0).w_sum + _S214;
    (*sel_0).w_sum = _S218;
    var _S219 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S219;
    var _S220 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S220.state;
    var _S221 : bool = (_S220.value * (*sel_0).w_sum) <= _S214;
    if(_S221)
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
    var _S222 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S222;
    var _S223 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S223;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S224 : f32 = rgb_to_greyscale(r_1.f);
    var _S225 : f32 = sel_2.w_sum / _S224;
    var _S226 : bool = _S224 > 0.0f;
    var _S227 : f32 = select(0.0f, _S225, _S226);
    r_1.w = _S227;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S228 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S229 : u32 = (insertBits((_S228), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S229;
    candidate_2.f = f_1;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S230 : bool = transmission_0 > 0.0f;
    var _S231 : bool;
    if(_S230)
    {
        _S231 = true;
    }
    else
    {
        _S231 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S232 : f32;
    if(_S231)
    {
        _S232 = 1.0f;
    }
    else
    {
        _S232 = -1.0f;
    }
    return _S232;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S233 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S233.x, max(_S233.y, _S233.z)), 0.0f, 1.0f);
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S234 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S235 : bool = cos_a_0 > cos_b_0;
    var _S236 : f32 = select(_S234, 1.0f, _S235);
    return _S236;
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
    var _S237 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S238 : vec3<f32> = node_0.high - node_0.low;
    var _S239 : vec3<f32> = p_0 - _S237;
    var _S240 : vec3<f32> = (normalize((_S239)));
    var _S241 : f32 = dot(_S239, _S239);
    var _S242 : f32 = dot(_S238, _S238) / 4.0f;
    var _S243 : f32 = abs(dot(node_0.w, _S240));
    var _S244 : f32 = sine(node_0.cos_theta_o);
    var _S245 : f32 = sqrt(max(1.0f - _S242 / _S241, 0.0f));
    var _S246 : bool = _S241 < _S242;
    var _S247 : f32 = select(_S245, -1.0f, _S246);
    var _S248 : f32 = sine(_S247);
    var _S249 : f32 = sine(_S243);
    var _S250 : f32 = cosSubClamped(_S249, _S243, _S244, node_0.cos_theta_o);
    var _S251 : f32 = sine(_S243);
    var _S252 : f32 = _S251 * node_0.cos_theta_o - _S243 * _S244;
    var _S253 : bool = _S243 > (node_0.cos_theta_o);
    var _S254 : f32 = select(_S252, 0.0f, _S253);
    var _S255 : f32 = cosSubClamped(_S254, _S250, _S248, _S247);
    var _S256 : bool = _S255 <= 0.0f;
    if(_S256)
    {
        return 0.0f;
    }
    var _S257 : f32 = - dot(_S240, normal_0);
    var _S258 : f32 = node_0.phi * _S255 / max(_S241, length(_S238) / 2.0f);
    var _S259 : f32 = sine(_S257);
    var _S260 : f32 = cosSubClamped(_S259, _S257, _S248, _S247);
    var _S261 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S262 : f32 = select(_S260, 1.0f, _S261);
    return max(_S258 * _S262, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_1, toward_0));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S263 : f32 = importance(first_0, p_1, normal_2);
    var _S264 : f32 = importance(second_0, p_1, normal_2);
    var _S265 : vec2<f32> = vec2<f32>(_S263, _S264);
    var _S266 : bool = _S263 == 0.0f;
    var _S267 : bool;
    if(_S266)
    {
        _S267 = _S264 == 0.0f;
    }
    else
    {
        _S267 = false;
    }
    if(_S267)
    {
        return u32(2);
    }
    var _S268 : f32 = _S263 + _S264;
    var _S269 : bool = _S264 > 0.0f;
    if(_S269)
    {
        _S267 = ((*pick_0) * _S268) >= _S263;
    }
    else
    {
        _S267 = false;
    }
    var _S270 : u32 = select(u32(0), u32(1), _S267);
    var _S271 : f32 = min(((*pick_0) * _S268 - f32(_S270) * _S263) / _S265[_S270], 0.99999994039535522f);
    (*pick_0) = _S271;
    var _S272 : f32 = (*probability_1) * (_S265[_S270] / _S268);
    (*probability_1) = _S272;
    return _S270;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S273 : f32 = importance(first_1, p_2, normal_3);
    var _S274 : f32 = importance(second_1, p_2, normal_3);
    var _S275 : vec2<f32> = vec2<f32>(_S273, _S274);
    var _S276 : f32 = _S275[child_0] / (_S273 + _S274);
    var _S277 : bool = (_S275[child_0]) > 0.0f;
    var _S278 : f32 = select(0.0f, _S276, _S277);
    return _S278;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S279 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S280 : bool = b_1 > 0.0f;
    var _S281 : f32 = select(1.0f, _S279, _S280);
    return _S281;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S282 : vec3<f32> = center_0 - p_3;
    var _S283 : f32 = radius_1 * radius_1 / dot(_S282, _S282);
    var _S284 : bool = _S283 >= 1.0f;
    if(_S284)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S283)) / (6.28318548202514648f * _S283);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S285 : vec3<f32> = center_1 - p_4;
    var _S286 : f32 = radius_2 * radius_2 / dot(_S285, _S285);
    var _S287 : f32 = u1_0 * _S286 / (1.0f + sqrt(max(1.0f - _S286, 0.0f)));
    var _S288 : f32 = 2.0f * u1_0;
    var _S289 : bool = _S286 >= 1.0f;
    var _S290 : f32 = select(_S287, _S288, _S289);
    var _S291 : f32 = sqrt(max(_S290 * (2.0f - _S290), 0.0f));
    var _S292 : f32 = 6.28318548202514648f * u2_0;
    var _S293 : vec3<f32> = vec3<f32>(_S291 * cos(_S292), 1.0f - _S290, _S291 * sin(_S292));
    var _S294 : vec3<f32> = (normalize((_S285)));
    var _S295 : vec3<f32> = tangentToWorld(_S293, _S294);
    return _S295;
}

