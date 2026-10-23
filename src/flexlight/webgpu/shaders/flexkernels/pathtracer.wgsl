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
        var _S25 : bool = eta_i_0 == eta_o_0;
        var _S26 : f32 = select(_S24, cos_theta_0, _S25);
        var _S27 : f32 = eta_o_0 * cos_theta_0;
        var _S28 : f32 = eta_i_0 * _S26;
        var _S29 : f32 = (_S27 - _S28) / (_S27 + _S28);
        var _S30 : f32 = eta_i_0 * cos_theta_0;
        var _S31 : f32 = eta_o_0 * _S26;
        var _S32 : f32 = (_S30 - _S31) / (_S30 + _S31);
        var _S33 : f32 = (_S29 * _S29 + _S32 * _S32) / 2.0f;
        kr_0 = _S33;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_2 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S34 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z))));
    var _S35 : f32 = _S34.x;
    var _S36 : f32 = _S34.y;
    var _S37 : f32 = _S35 * _S35 + _S36 * _S36;
    const _S38 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S39 : vec3<f32> = vec3<f32>(- _S36, _S35, 0.0f);
    var _S40 : f32 = (inverseSqrt((_S37)));
    var _S41 : vec3<f32> = _S39 * vec3<f32>(_S40);
    var _S42 : bool = _S37 > 0.0f;
    var _S43 : vec3<f32> = select(_S38, _S41, _S42);
    var _S44 : vec3<f32> = cross(_S34, _S43);
    var _S45 : f32 = sqrt(U1_0);
    var _S46 : f32 = 6.28318548202514648f * U2_0;
    var _S47 : f32 = _S45 * cos(_S46);
    var t2_0 : f32 = _S45 * sin(_S46);
    var _S48 : f32 = 0.5f * (1.0f + _S34.z);
    var t2_1 : f32 = (1.0f - _S48) * sqrt(max(0.0f, 1.0f - _S47 * _S47)) + _S48 * t2_0;
    var _S49 : vec3<f32> = vec3<f32>(_S47) * _S43 + vec3<f32>(t2_1) * _S44;
    var _S50 : f32 = ((_S47));
    var _S51 : f32 = ((_S47));
    var _S52 : vec3<f32> = _S49 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S50 * _S51 - t2_1 * t2_1))) * _S34;
    var _S53 : vec3<f32> = (normalize((vec3<f32>(alpha_2 * _S52.x, alpha_2 * _S52.y, max(0.0f, _S52.z)))));
    return _S53;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S54 : f32 = sqrt(random_1_0);
    var _S55 : f32 = 6.28318548202514648f * random_2_0;
    var _S56 : f32 = _S54 * cos(_S55);
    var _S57 : f32 = _S54 * sin(_S55);
    var _S58 : f32 = sqrt(max(0.0f, 1.0f - _S56 * _S56 - _S57 * _S57));
    return vec3<f32>(_S56, _S58, _S57);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S59 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S59)
    {
        const _S60 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S60;
    }
    else
    {
        a_1 = a_0;
    }
    var _S61 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S62 : vec3<f32> = cross(n_0, _S61);
    return vec3<f32>(v_0.x) * _S61 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S62;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S63 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S63)
    {
        const _S64 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S64;
    }
    else
    {
        a_3 = a_2;
    }
    var _S65 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S66 : vec3<f32> = cross(n_1, _S65);
    return vec3<f32>(dot(v_1, _S65), dot(v_1, n_1), dot(v_1, _S66));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S67 : vec3<f32> = p1_0 - p0_0;
    var _S68 : vec3<f32> = p2_0 - p0_0;
    var _S69 : vec2<f32> = uv1_0 - uv0_0;
    var _S70 : vec2<f32> = uv2_0 - uv0_0;
    var _S71 : f32 = _S69.x;
    var _S72 : f32 = _S70.y;
    var _S73 : f32 = _S69.y;
    var _S74 : f32 = _S70.x;
    var _S75 : f32 = _S71 * _S72 - _S73 * _S74;
    var _S76 : f32 = 1.0f / _S75;
    var _S77 : vec3<f32> = vec3<f32>(_S76);
    var t_0 : vec3<f32> = (_S67 * vec3<f32>(_S72) - _S68 * vec3<f32>(_S73)) * _S77;
    var _S78 : vec3<f32> = (_S68 * vec3<f32>(_S71) - _S67 * vec3<f32>(_S74)) * _S77;
    var _S79 : vec3<f32> = t_0 - n_2 * vec3<f32>(dot(n_2, t_0));
    var _S80 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_2);
    var _S81 : bool = (dot(_S79, _S79)) > 0.0f;
    var _S82 : vec3<f32> = select(_S80, _S79, _S81);
    var _S83 : vec3<f32> = (normalize((_S82)));
    var _S84 : bool = (dot(cross(n_2, _S83), _S78)) > 0.0f;
    var t_1 : vec3<f32>;
    if(_S84)
    {
        var _S85 : vec3<f32> = ((-(_S83)));
        t_1 = _S85;
    }
    else
    {
        t_1 = _S83;
    }
    var _S86 : vec3<f32> = cross(n_2, t_1);
    return mat3x3<f32>(t_1, _S86, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_0 : vec3<f32>,  uvw_0 : vec3<f32>,  position_0 : vec3<f32>) -> f32
{
    var _S87 : vec3<f32> = t1_0 - t0_0;
    var _S88 : vec3<f32> = t2_2 - t0_0;
    var _S89 : vec3<f32> = t2_2 - t1_0;
    var _S90 : f32 = min(length(_S87), min(length(_S88), length(_S89)));
    var _S91 : vec3<f32> = vec3<f32>(distance(position_0, t0_0), distance(position_0, t1_0), distance(position_0, t2_2));
    var _S92 : vec3<f32> = (normalize((n0_0)));
    var _S93 : f32 = dot(geometry_n_0, _S92);
    var _S94 : vec3<f32> = (normalize((n1_0)));
    var _S95 : f32 = dot(geometry_n_0, _S94);
    var _S96 : vec3<f32> = (normalize((n2_0)));
    var _S97 : vec3<f32> = acos(abs(vec3<f32>(_S93, _S95, dot(geometry_n_0, _S96))));
    var _S98 : vec3<f32> = clamp(tan(_S97), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S91 * _S98, uvw_0), 0.0f, _S90 * 0.125f);
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S99 : Random = pcg((*random_state_0));
    var _S100 : Random = pcg(_S99.state);
    (*random_state_0) = _S100.state;
    var _S101 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S102 : vec3<f32> = sampleGGXVNDF(_S101.xzy, alpha_3, _S99.value, _S100.value);
    var _S103 : vec3<f32> = _S102.xzy;
    var _S104 : vec3<f32> = tangentToWorld(_S103, n_i_0);
    return _S104;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_0 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S105 : vec3<f32> = ((-(in_dir_0)));
    var _S106 : f32 = (sign((dot(n_3, _S105))));
    var _S107 : f32 = material_0.roughness;
    var _S108 : vec3<f32> = sampleHalfVector(_S105, n_3 * vec3<f32>(_S106), _S107 * _S107, &(state_5));
    return _S108;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S109 : vec3<f32> = ((-(in_dir_1)));
    var _S110 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S109 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S111 : vec3<f32> = (normalize((_S110)));
    var _S112 : f32 = (sign((dot(n_4, _S109))));
    var _S113 : f32 = (sign((dot(_S110, n_4 * vec3<f32>(_S112)))));
    return _S111 * vec3<f32>(_S113);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S114 : vec3<f32> = ((-(in_dir_2)));
    var _S115 : vec3<f32> = (normalize((_S114 + out_dir_1)));
    return _S115;
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
    var _S116 : BSDFLobes;
    _S116.v_dot_h = v_dot_h_0;
    _S116.n_dot_h = n_dot_h_1;
    _S116.refracted = refracted_0;
    _S116.F = F_0;
    _S116.F_greyscale = F_greyscale_0;
    _S116.reflect_weight = reflect_weight_0;
    _S116.diffuse_weight = diffuse_weight_0;
    _S116.refract_weight = refract_weight_0;
    _S116.p_diffuse = p_diffuse_0;
    _S116.p_reflect = p_reflect_0;
    _S116.p_refract = p_refract_0;
    return _S116;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S117 : f32 = dot(ggx_n_0, v_4);
    var _S118 : f32 = dot(n_i_1, ggx_n_0);
    var _S119 : f32 = eta_i_2 / eta_o_2;
    var _S120 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S119))));
    var _S121 : f32 = fresnel(abs(_S117), eta_i_2, eta_o_2);
    var F_1 : vec3<f32> = (mix((vec3<f32>(_S121)), (material_1.albedo), (material_1.metallic)));
    var _S122 : f32 = rgb_to_greyscale(F_1);
    var _S123 : f32 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic) * (1.0f - _S121);
    var _S124 : f32 = max(_S122, 0.0f);
    var _S125 : f32 = max(_S123, 0.0f);
    var _S126 : f32 = material_1.transmission * (1.0f - _S122);
    var _S127 : f32 = (sign((length(_S120))));
    var _S128 : f32 = max(_S126 * _S127, 0.0f);
    var _S129 : f32 = _S124 + _S125 + _S128;
    var _S130 : f32 = 1.0f / max(_S129, 0.0000152587890625f);
    var _S131 : f32 = _S125 * _S130;
    var _S132 : f32 = _S124 * _S130;
    var _S133 : f32 = _S128 * _S130;
    return BSDFLobes_x24init_0(_S117, _S118, _S120, F_1, _S122, 1.0f, _S123, material_1.transmission, _S131, _S132, _S133);
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S134 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S135 : bool = n_i_dot_v_0 > 0.0f;
    var _S136 : f32 = select(0.0f, _S134, _S135);
    return _S136;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_5 : f32,  material_2 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    return vec3<f32>(lobes_1.diffuse_weight) * material_2.albedo / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S137 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S138 : f32 = _S137 * lobes_2.v_dot_h;
    var _S139 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S140 : f32 = _S138 * _S139 / n_i_dot_v_1;
    var _S141 : bool = alpha_6 > 0.0f;
    var _S142 : bool;
    if(_S141)
    {
        _S142 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S142 = false;
    }
    if(_S142)
    {
        _S142 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S142 = false;
    }
    if(_S142)
    {
        _S142 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S142 = false;
    }
    var _S143 : f32 = select(0.0f, _S140, _S142);
    return _S143;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S144 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S145 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S146 : f32 = lobes_3.p_refract * _S144 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S145 * _S145);
    var _S147 : bool = eta_i_4 != eta_o_4;
    var _S148 : bool;
    if(_S147)
    {
        _S148 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S148 = false;
    }
    var _S149 : f32 = select(0.0f, _S146, _S148);
    return _S149;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_8 : f32,  material_3 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S150 : f32 = - dot(n_i_3, l_1);
    var _S151 : f32 = smithG1(alpha_8, max(_S150, 0.0f));
    return vec3<f32>((lobes_4.refract_weight * _S151 * (1.0f - lobes_4.F_greyscale))) * material_3.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S152 : f32 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    var _S153 : f32 = lobes_5.p_reflect * _S152 / (4.0f * lobes_5.v_dot_h);
    var _S154 : bool = _S152 > 0.0f;
    var _S155 : f32 = select(0.0f, _S153, _S154);
    return _S155;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_10 : f32,  material_4 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S156 : f32 = dot(n_i_4, l_2);
    var _S157 : f32 = smithG1(alpha_10, max(_S156, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S157)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_5 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(3)>>,  pdfs_0 : ptr<function, array<f32, i32(3)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S158 : vec3<f32> = ((-(in_dir_4)));
    var _S159 : f32 = dot(n_5, _S158);
    var _S160 : f32 = (sign((_S159)));
    var _S161 : vec3<f32> = n_5 * vec3<f32>(_S160);
    var _S162 : f32 = dot(_S161, out_dir_2);
    var _S163 : f32 = material_5.roughness;
    var _S164 : f32 = _S163 * _S163;
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
        var _S165 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S165;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S166 : vec3<f32> = vec3<f32>(0.0f);
    var _S167 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S166, _S166, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var lobe_terms_0 : BSDFLobes = _S167;
    var ggx_n_2 : vec3<f32> = _S166;
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
        var _S168 : bool = i_0 == u32(1);
        var _S169 : bool = _S168 != refracted_1;
        if(_S169)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S170 : bool = i_0 != half_of_0;
        var half_of_1 : u32;
        var lobe_terms_1 : BSDFLobes;
        if(_S170)
        {
            var _S171 : bool = i_0 == u32(0);
            if(_S171)
            {
                var _S172 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_5, random_state_2);
                ggx_n_1 = _S172;
            }
            else
            {
                if(_S168)
                {
                    var _S173 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_1 = _S173;
                }
                else
                {
                    var _S174 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S174;
                }
            }
            var _S175 : vec3<f32> = ((-(in_dir_4)));
            var _S176 : BSDFLobes = bsdfLobes(in_dir_4, _S175, _S161, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S176;
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
                var _S177 : f32 = diffusePDF(_S162, 0.0f, abs(_S159), _S164, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(0)] = _S177;
                var _S178 : vec3<f32> = diffuseBSDF(out_dir_2, _S161, _S164, material_5, lobe_terms_1);
                (*throughputs_0)[i32(0)] = _S178;
            }
        case u32(1):
            {
                var _S179 : f32 = refractPDF(_S162, dot(out_dir_2, ggx_n_1), abs(_S159), _S164, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(1)] = _S179;
                var _S180 : vec3<f32> = refractBSDF(out_dir_2, _S161, _S164, material_5, lobe_terms_1);
                (*throughputs_0)[i32(1)] = _S180;
            }
        default :
            {
                var _S181 : f32 = reflectPDF(_S162, 0.0f, abs(_S159), _S164, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(2)] = _S181;
                var _S182 : vec3<f32> = reflectBSDF(out_dir_2, _S161, _S164, material_5, lobe_terms_1);
                (*throughputs_0)[i32(2)] = _S182;
            }
        }
        half_of_0 = half_of_1;
        lobe_terms_0 = lobe_terms_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S166;
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S183 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S183)
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
    var _S184 : SampleBSDF;
    _S184.unit_direction = unit_direction_0;
    _S184.throughput = throughput_0;
    _S184.random_state = random_state_3;
    _S184.refracted = refracted_2;
    _S184.lobe = lobe_0;
    _S184.pdf = pdf_0;
    return _S184;
}

fn diffuseSample( n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_11 : f32,  material_6 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S185 : vec3<f32> = vec3<f32>(1.0f);
    var _S186 : SampleBSDF = SampleBSDF_x24init_0(_S185, _S185, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S186;
    var _S187 : Random = pcg(random_state_4);
    var _S188 : Random = pcg(_S187.state);
    sample_0.random_state = _S188.state;
    var _S189 : vec3<f32> = sampleCosWeightedHemisphere(_S187.value, _S188.value);
    var _S190 : vec3<f32> = tangentToWorld(_S189, n_i_5);
    sample_0.unit_direction = _S190;
    sample_0.lobe = u32(0);
    var _S191 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    sample_0.throughput = _S191;
    var _S192 : f32 = diffusePDF(_S189.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S192;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_12 : f32,  material_7 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S193 : vec3<f32> = vec3<f32>(1.0f);
    var _S194 : SampleBSDF = SampleBSDF_x24init_0(_S193, _S193, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S194;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S195 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    sample_1.throughput = _S195;
    var _S196 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S196;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_13 : f32,  material_8 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S197 : vec3<f32> = vec3<f32>(1.0f);
    var _S198 : SampleBSDF = SampleBSDF_x24init_0(_S197, _S197, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S198;
    var _S199 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S199;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S200 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    sample_2.throughput = _S200;
    var _S201 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S201;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S202 : vec3<f32> = ((-(in_dir_6)));
    var _S203 : f32 = dot(n_6, _S202);
    var _S204 : f32 = (sign((_S203)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S204);
    var _S205 : f32 = abs(_S203);
    var _S206 : f32 = material_9.roughness;
    var _S207 : f32 = _S206 * _S206;
    var _S208 : vec3<f32> = sampleHalfVector(_S202, n_i_8, _S207, &(random_state_7));
    var _S209 : BSDFLobes = bsdfLobes(in_dir_6, _S202, n_i_8, _S208, material_9, eta_i_10, eta_o_10);
    var _S210 : Random = pcg(random_state_7);
    random_state_7 = _S210.state;
    var _S211 : bool = (_S210.value) < (_S209.p_diffuse);
    if(_S211)
    {
        var _S212 : SampleBSDF = diffuseSample(n_i_8, _S205, _S207, material_9, _S209, eta_i_10, eta_o_10, random_state_7);
        return _S212;
    }
    var _S213 : bool = (_S210.value) < (_S209.p_diffuse + _S209.p_refract);
    if(_S213)
    {
        var _S214 : SampleBSDF = refractSample(_S208, n_i_8, _S205, _S207, material_9, _S209, eta_i_10, eta_o_10, random_state_7);
        return _S214;
    }
    var _S215 : SampleBSDF = reflectSample(in_dir_6, _S208, n_i_8, _S205, _S207, material_9, _S209, eta_i_10, eta_o_10, random_state_7);
    return _S215;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S216 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S216));
}

fn neeDecision( material_10 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S217 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S218 : vec3<f32> = (mix((vec3<f32>(_S217)), (material_10.albedo), (material_10.metallic)));
    var _S219 : f32 = rgb_to_greyscale(_S218);
    var _S220 : f32 = max((1.0f - _S219) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission), 0.0f);
    var _S221 : bool = _S220 > 0.03999999910593033f;
    var _S222 : bool;
    if(_S221)
    {
        _S222 = true;
    }
    else
    {
        _S222 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S222;
}

fn straightThrough( material_11 : Material) -> vec3<f32>
{
    var _S223 : f32 = rgb_to_greyscale(material_11.albedo * vec3<f32>(material_11.metallic));
    return vec3<f32>((material_11.transmission * (1.0f - _S223))) * material_11.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S224 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S224 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_7 : vec3<f32>,  material_12 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S225 : vec3<f32>;
    if((material_12.ior) == 1.0f)
    {
        var _S226 : vec3<f32> = straightThrough(material_12);
        _S225 = _S226;
    }
    else
    {
        _S225 = vec3<f32>(0.0f);
    }
    return _S225 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S227 : u32 = hash(index_0);
    var _S228 : u32 = hash((seed_0 ^ (_S227)));
    return _S228;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S229 : vec3<f32> = a_4 / b_0;
    var _S230 : vec3<f32> = vec3<f32>(0.0f);
    var _S231 : vec3<bool> = b_0 == _S230;
    var _S232 : vec3<f32> = select(_S229, _S230, _S231);
    return _S232;
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
    var _S233 : f32 = rgb_to_greyscale(weight_0);
    var _S234 : bool = _S233 > 0.0f;
    var _S235 : bool;
    if(_S234)
    {
        _S235 = _S233 < 3.00000000549775576e+38f;
    }
    else
    {
        _S235 = false;
    }
    var _S236 : bool = !_S235;
    if(_S236)
    {
        return;
    }
    var _S237 : f32 = (*sel_0).w_sum + _S233;
    (*sel_0).w_sum = _S237;
    var _S238 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S238;
    var _S239 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S239.state;
    var _S240 : bool = (_S239.value * (*sel_0).w_sum) <= _S233;
    if(_S240)
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
    var _S241 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S241;
    var _S242 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S242;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S243 : f32 = rgb_to_greyscale(r_1.f);
    var _S244 : f32 = sel_2.w_sum / _S243;
    var _S245 : bool = _S243 > 0.0f;
    var _S246 : f32 = select(0.0f, _S244, _S245);
    r_1.w = _S246;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S247 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S248 : u32 = (insertBits((_S247), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S248;
    candidate_2.f = f_1;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S249 : bool = transmission_0 > 0.0f;
    var _S250 : bool;
    if(_S249)
    {
        _S250 = true;
    }
    else
    {
        _S250 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S251 : f32;
    if(_S250)
    {
        _S251 = 1.0f;
    }
    else
    {
        _S251 = -1.0f;
    }
    return _S251;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S252 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S252.x, max(_S252.y, _S252.z)), 0.0f, 1.0f);
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S253 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S254 : bool = cos_a_0 > cos_b_0;
    var _S255 : f32 = select(_S253, 1.0f, _S254);
    return _S255;
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
    var _S256 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S257 : vec3<f32> = node_0.high - node_0.low;
    var _S258 : vec3<f32> = p_0 - _S256;
    var _S259 : vec3<f32> = (normalize((_S258)));
    var _S260 : f32 = dot(_S258, _S258);
    var _S261 : f32 = dot(_S257, _S257) / 4.0f;
    var _S262 : f32 = abs(dot(node_0.w, _S259));
    var _S263 : f32 = sine(node_0.cos_theta_o);
    var _S264 : f32 = sqrt(max(1.0f - _S261 / _S260, 0.0f));
    var _S265 : bool = _S260 < _S261;
    var _S266 : f32 = select(_S264, -1.0f, _S265);
    var _S267 : f32 = sine(_S266);
    var _S268 : f32 = sine(_S262);
    var _S269 : f32 = cosSubClamped(_S268, _S262, _S263, node_0.cos_theta_o);
    var _S270 : f32 = sine(_S262);
    var _S271 : f32 = _S270 * node_0.cos_theta_o - _S262 * _S263;
    var _S272 : bool = _S262 > (node_0.cos_theta_o);
    var _S273 : f32 = select(_S271, 0.0f, _S272);
    var _S274 : f32 = cosSubClamped(_S273, _S269, _S267, _S266);
    var _S275 : bool = _S274 <= 0.0f;
    if(_S275)
    {
        return 0.0f;
    }
    var _S276 : f32 = - dot(_S259, normal_0);
    var _S277 : f32 = node_0.phi * _S274 / max(_S260, length(_S257) / 2.0f);
    var _S278 : f32 = sine(_S276);
    var _S279 : f32 = cosSubClamped(_S278, _S276, _S267, _S266);
    var _S280 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S281 : f32 = select(_S279, 1.0f, _S280);
    return max(_S277 * _S281, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S282 : f32 = importance(first_0, p_1, normal_2);
    var _S283 : f32 = importance(second_0, p_1, normal_2);
    var _S284 : vec2<f32> = vec2<f32>(_S282, _S283);
    var _S285 : bool = _S282 == 0.0f;
    var _S286 : bool;
    if(_S285)
    {
        _S286 = _S283 == 0.0f;
    }
    else
    {
        _S286 = false;
    }
    if(_S286)
    {
        return u32(2);
    }
    var _S287 : f32 = _S282 + _S283;
    var _S288 : bool = _S283 > 0.0f;
    if(_S288)
    {
        _S286 = ((*pick_0) * _S287) >= _S282;
    }
    else
    {
        _S286 = false;
    }
    var _S289 : u32 = select(u32(0), u32(1), _S286);
    var _S290 : f32 = min(((*pick_0) * _S287 - f32(_S289) * _S282) / _S284[_S289], 0.99999994039535522f);
    (*pick_0) = _S290;
    var _S291 : f32 = (*probability_1) * (_S284[_S289] / _S287);
    (*probability_1) = _S291;
    return _S289;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S292 : f32 = importance(first_1, p_2, normal_3);
    var _S293 : f32 = importance(second_1, p_2, normal_3);
    var _S294 : vec2<f32> = vec2<f32>(_S292, _S293);
    var _S295 : f32 = _S294[child_0] / (_S292 + _S293);
    var _S296 : bool = (_S294[child_0]) > 0.0f;
    var _S297 : f32 = select(0.0f, _S295, _S296);
    return _S297;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S298 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S299 : bool = b_1 > 0.0f;
    var _S300 : f32 = select(1.0f, _S298, _S299);
    return _S300;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S301 : vec3<f32> = center_0 - p_3;
    var _S302 : f32 = radius_1 * radius_1 / dot(_S301, _S301);
    var _S303 : bool = _S302 >= 1.0f;
    if(_S303)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S302)) / (6.28318548202514648f * _S302);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S304 : vec3<f32> = center_1 - p_4;
    var _S305 : f32 = radius_2 * radius_2 / dot(_S304, _S304);
    var _S306 : f32 = u1_0 * _S305 / (1.0f + sqrt(max(1.0f - _S305, 0.0f)));
    var _S307 : f32 = 2.0f * u1_0;
    var _S308 : bool = _S305 >= 1.0f;
    var _S309 : f32 = select(_S306, _S307, _S308);
    var _S310 : f32 = sqrt(max(_S309 * (2.0f - _S309), 0.0f));
    var _S311 : f32 = 6.28318548202514648f * u2_0;
    var _S312 : vec3<f32> = vec3<f32>(_S310 * cos(_S311), 1.0f - _S309, _S310 * sin(_S311));
    var _S313 : vec3<f32> = (normalize((_S304)));
    var _S314 : vec3<f32> = tangentToWorld(_S312, _S313);
    return _S314;
}

