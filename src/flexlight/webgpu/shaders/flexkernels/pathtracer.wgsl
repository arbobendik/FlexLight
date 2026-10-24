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
     diffuse_weight : vec3<f32>,
     refract_weight : vec3<f32>,
     p_diffuse : f32,
     p_reflect : f32,
     p_refract : f32,
     translucent_share : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32) -> BSDFLobes
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
    _S102.translucent_share = translucent_share_0;
    return _S102;
}

fn bsdfLobes( in_dir_1 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S103 : f32 = dot(ggx_n_0, v_4);
    var _S104 : f32 = dot(n_i_1, ggx_n_0);
    var _S105 : f32 = eta_i_1 / eta_o_1;
    var _S106 : vec3<f32> = (normalize((refract(in_dir_1, ggx_n_0, _S105))));
    var _S107 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S108 : f32 = _S107 * _S107;
    var _S109 : f32 = (1.0f + _S107) / (1.0f - _S107);
    var _S110 : f32 = abs(_S103);
    var _S111 : bool = eta_i_1 > eta_o_1;
    var _S112 : f32;
    if(_S111)
    {
        _S112 = _S109;
    }
    else
    {
        _S112 = 1.0f;
    }
    var _S113 : f32;
    if(_S111)
    {
        _S113 = 1.0f;
    }
    else
    {
        _S113 = _S109;
    }
    var _S114 : f32 = fresnel(_S110, _S112, _S113);
    var _S115 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S103 * _S103)) >= (eta_o_1 * eta_o_1);
    var _S116 : vec3<f32>;
    if(_S115)
    {
        _S116 = vec3<f32>(1.0f);
    }
    else
    {
        var _S117 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S108);
        _S116 = _S117 + (vec3<f32>(1.0f) - _S117) * vec3<f32>((_S114 - _S108)) / vec3<f32>((1.0f - _S108));
    }
    var F_1 : vec3<f32> = (mix((_S116), (material_1.albedo), (material_1.metallic)));
    var _S118 : f32 = rgb_to_greyscale(F_1);
    var _S119 : f32 = 1.0f - material_1.metallic;
    var _S120 : vec3<f32> = vec3<f32>(1.0f) - _S116;
    var _S121 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S119)) * _S120;
    var _S122 : vec3<f32> = vec3<f32>((material_1.transmission * _S119)) * _S120;
    var _S123 : f32 = max(_S118, 0.0f);
    var _S124 : f32 = rgb_to_greyscale(_S121);
    var _S125 : f32 = max(_S124, 0.0f);
    var _S126 : f32 = rgb_to_greyscale(_S122);
    var _S127 : f32 = (sign((length(_S106))));
    var _S128 : f32 = max(_S126 * _S127, 0.0f);
    var _S129 : f32 = _S123 + _S125 + _S128;
    var _S130 : f32 = 1.0f / max(_S129, 0.0000152587890625f);
    var _S131 : f32 = _S125 * _S130;
    var _S132 : f32 = _S123 * _S130;
    var _S133 : f32 = _S128 * _S130;
    return BSDFLobes_x24init_0(_S103, _S104, _S106, F_1, _S118, 1.0f, _S121, _S122, _S131, _S132, _S133, 0.0f);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S134 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S135 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S136 : f32 = _S134 / (_S135 + _S134);
    var _S137 : bool = _S134 > 0.0f;
    var _S138 : f32 = select(0.0f, _S136, _S137);
    return _S138;
}

fn refractedHalf( in_dir_2 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S139 : vec3<f32> = ((-(in_dir_2)));
    var _S140 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S139 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S141 : vec3<f32> = (normalize((_S140)));
    var _S142 : f32 = (sign((dot(n_4, _S139))));
    var _S143 : f32 = (sign((dot(_S140, n_4 * vec3<f32>(_S142)))));
    return _S141 * vec3<f32>(_S143);
}

fn reflectedHalf( in_dir_3 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S144 : vec3<f32> = ((-(in_dir_3)));
    var _S145 : vec3<f32> = (normalize((_S144 + out_dir_1)));
    return _S145;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S146 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S147 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S148 : f32 = 1.0f - lobes_0.translucent_share;
    var _S149 : bool = n_i_dot_l_0 < 0.0f;
    var _S150 : f32 = select(_S148, lobes_0.translucent_share, _S149);
    var _S151 : f32 = _S147 * _S150;
    var _S152 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S153 : f32 = select(_S146, _S151, _S152);
    var _S154 : bool = n_i_dot_v_0 > 0.0f;
    var _S155 : f32 = select(0.0f, _S153, _S154);
    return _S155;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S156 : bool = (dot(n_i_2, l_0)) < 0.0f;
    var _S157 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S156);
    var _S158 : f32 = 1.0f - lobes_1.translucent_share;
    var _S159 : f32 = select(_S158, lobes_1.translucent_share, _S156);
    var _S160 : vec3<f32> = _S157 / vec3<f32>(_S159);
    var _S161 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S162 : vec3<f32> = select(material_3.albedo, _S160, _S161);
    return lobes_1.diffuse_weight * _S162 / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S163 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S164 : f32 = _S163 * lobes_2.v_dot_h;
    var _S165 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S166 : f32 = _S164 * _S165 / n_i_dot_v_1;
    var _S167 : bool = alpha_6 > 0.0f;
    var _S168 : bool;
    if(_S167)
    {
        _S168 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S168 = false;
    }
    if(_S168)
    {
        _S168 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S168 = false;
    }
    if(_S168)
    {
        _S168 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S168 = false;
    }
    var _S169 : f32 = select(0.0f, _S166, _S168);
    return _S169;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S170 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S171 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S172 : f32 = lobes_3.p_refract * _S170 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S171 * _S171);
    var _S173 : bool = eta_i_4 != eta_o_4;
    var _S174 : bool;
    if(_S173)
    {
        _S174 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S174 = false;
    }
    var _S175 : f32 = select(0.0f, _S172, _S174);
    return _S175;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_8 : f32,  material_4 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S176 : f32 = - dot(n_i_3, l_1);
    var _S177 : f32 = smithG1(alpha_8, max(_S176, 0.0f));
    return lobes_4.refract_weight * vec3<f32>(_S177) * material_4.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S178 : f32 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    var _S179 : f32 = lobes_5.p_reflect * _S178 / (4.0f * lobes_5.v_dot_h);
    var _S180 : bool = _S178 > 0.0f;
    var _S181 : f32 = select(0.0f, _S179, _S180);
    return _S181;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_10 : f32,  material_5 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S182 : f32 = dot(n_i_4, l_2);
    var _S183 : f32 = smithG1(alpha_10, max(_S182, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S183)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_6 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(3)>>,  pdfs_0 : ptr<function, array<f32, i32(3)>>) -> vec3<f32>
{
    var _S184 : vec3<f32> = ((-(in_dir_4)));
    var _S185 : f32 = dot(n_5, _S184);
    var _S186 : f32 = (sign((_S185)));
    var _S187 : vec3<f32> = n_5 * vec3<f32>(_S186);
    var _S188 : f32 = dot(_S187, out_dir_2);
    var _S189 : f32 = material_6.roughness;
    var _S190 : f32 = _S189 * _S189;
    var _S191 : f32 = rgb_to_greyscale(material_6.translucent);
    var _S192 : bool = _S191 > 0.0f;
    var _S193 : bool = (dot(n_5, out_dir_2) * _S185) < 0.0f;
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
        var _S194 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S194;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S195 : vec3<f32> = vec3<f32>(0.0f);
    var _S196 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S195, _S195, 0.0f, 0.0f, _S195, _S195, 0.0f, 0.0f, 0.0f, 0.0f);
    var sampled_terms_0 : BSDFLobes = _S196;
    var _S197 : bool;
    if(_S192)
    {
        _S197 = _S193;
    }
    else
    {
        _S197 = false;
    }
    var _S198 : bool = _S197 == refracted_1;
    if(_S198)
    {
        var sampled_n_0 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_6, random_state_2);
        var _S199 : vec3<f32> = ((-(in_dir_4)));
        var _S200 : BSDFLobes = bsdfLobes(in_dir_4, _S199, _S187, sampled_n_0, material_6, eta_i_6, eta_o_6);
        sampled_terms_0 = _S200;
        var _S201 : f32 = translucentShare(material_6);
        sampled_terms_0.translucent_share = _S201;
    }
    var f_0 : vec3<f32>;
    if(refracted_1)
    {
        var _S202 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
        f_0 = _S202;
    }
    else
    {
        var _S203 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
        f_0 = _S203;
    }
    var _S204 : vec3<f32> = ((-(in_dir_4)));
    var _S205 : BSDFLobes = bsdfLobes(in_dir_4, _S204, _S187, f_0, material_6, eta_i_6, eta_o_6);
    var lobe_terms_0 : BSDFLobes = _S205;
    var _S206 : f32 = translucentShare(material_6);
    lobe_terms_0.translucent_share = _S206;
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
        var _S207 : bool = i_0 == u32(0);
        if(_S207)
        {
            _S197 = _S192;
        }
        else
        {
            _S197 = false;
        }
        var _S208 : bool;
        if(_S197)
        {
            _S208 = _S193;
        }
        else
        {
            _S208 = i_0 == u32(1);
        }
        var _S209 : bool = _S208 != refracted_1;
        if(_S209)
        {
            var i_2 : u32 = i_0 + u32(1);
            i_0 = i_2;
            continue;
        }
        switch(i_0)
        {
        case u32(0):
            {
                var _S210 : f32 = diffusePDF(_S188, 0.0f, abs(_S185), _S190, sampled_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(0)] = _S210;
                var _S211 : vec3<f32> = diffuseBSDF(out_dir_2, _S187, _S190, material_6, sampled_terms_0);
                (*throughputs_0)[i32(0)] = _S211;
            }
        case u32(1):
            {
                var _S212 : f32 = refractPDF(_S188, dot(out_dir_2, f_0), abs(_S185), _S190, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(1)] = _S212;
                var _S213 : vec3<f32> = refractBSDF(out_dir_2, _S187, _S190, material_6, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S213;
            }
        default :
            {
                var _S214 : f32 = reflectPDF(_S188, 0.0f, abs(_S185), _S190, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(2)] = _S214;
                var _S215 : vec3<f32> = reflectBSDF(out_dir_2, _S187, _S190, material_6, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S215;
            }
        }
        var i_2 : u32 = i_0 + u32(1);
        i_0 = i_2;
    }
    i_0 = u32(0);
    f_0 = _S195;
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S216 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S216)
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
    var _S217 : SampleBSDF;
    _S217.unit_direction = unit_direction_0;
    _S217.throughput = throughput_0;
    _S217.random_state = random_state_3;
    _S217.refracted = refracted_2;
    _S217.lobe = lobe_0;
    _S217.pdf = pdf_0;
    return _S217;
}

fn diffuseSample( u_0 : f32,  n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_11 : f32,  material_7 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S218 : vec3<f32> = vec3<f32>(1.0f);
    var _S219 : SampleBSDF = SampleBSDF_x24init_0(_S218, _S218, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S219;
    var _S220 : Random = pcg(random_state_4);
    var _S221 : Random = pcg(_S220.state);
    sample_0.random_state = _S221.state;
    var _S222 : vec3<f32> = sampleCosWeightedHemisphere(_S220.value, _S221.value);
    var _S223 : bool = u_0 < (lobes_7.p_diffuse * lobes_7.translucent_share);
    var _S224 : f32 = _S222.y;
    var _S225 : f32 = - _S224;
    var _S226 : f32 = select(_S224, _S225, _S223);
    var _S227 : vec3<f32> = tangentToWorld(vec3<f32>(_S222.x, _S226, _S222.z), n_i_5);
    sample_0.unit_direction = _S227;
    sample_0.refracted = _S223;
    sample_0.lobe = u32(0);
    var _S228 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_11, material_7, lobes_7);
    sample_0.throughput = _S228;
    var _S229 : f32 = diffusePDF(_S226, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S229;
    return sample_0;
}

fn refractSample( ggx_n_1 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_12 : f32,  material_8 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S230 : vec3<f32> = vec3<f32>(1.0f);
    var _S231 : SampleBSDF = SampleBSDF_x24init_0(_S230, _S230, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S231;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S232 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_12, material_8, lobes_8);
    sample_1.throughput = _S232;
    var _S233 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_1), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S233;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_2 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_13 : f32,  material_9 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S234 : vec3<f32> = vec3<f32>(1.0f);
    var _S235 : SampleBSDF = SampleBSDF_x24init_0(_S234, _S234, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S235;
    var _S236 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_2))));
    sample_2.unit_direction = _S236;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S237 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    sample_2.throughput = _S237;
    var _S238 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S238;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_10 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S239 : vec3<f32> = ((-(in_dir_6)));
    var _S240 : f32 = dot(n_6, _S239);
    var _S241 : f32 = (sign((_S240)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S241);
    var _S242 : f32 = abs(_S240);
    var _S243 : f32 = material_10.roughness;
    var _S244 : f32 = _S243 * _S243;
    var _S245 : vec3<f32> = sampleHalfVector(_S239, n_i_8, _S244, &(random_state_7));
    var _S246 : BSDFLobes = bsdfLobes(in_dir_6, _S239, n_i_8, _S245, material_10, eta_i_10, eta_o_10);
    var lobes_10 : BSDFLobes = _S246;
    var _S247 : f32 = translucentShare(material_10);
    lobes_10.translucent_share = _S247;
    var _S248 : Random = pcg(random_state_7);
    random_state_7 = _S248.state;
    var _S249 : bool = (_S248.value) < (lobes_10.p_diffuse);
    if(_S249)
    {
        var _S250 : SampleBSDF = diffuseSample(_S248.value, n_i_8, _S242, _S244, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S250;
    }
    var _S251 : bool = (_S248.value) < (lobes_10.p_diffuse + lobes_10.p_refract);
    if(_S251)
    {
        var _S252 : SampleBSDF = refractSample(_S245, n_i_8, _S242, _S244, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S252;
    }
    var _S253 : SampleBSDF = reflectSample(in_dir_6, _S245, n_i_8, _S242, _S244, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
    return _S253;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S254 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S254));
}

fn neeDecision( material_11 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S255 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S256 : vec3<f32> = (mix((vec3<f32>(_S255)), (material_11.albedo), (material_11.metallic)));
    var _S257 : f32 = rgb_to_greyscale(_S256);
    var _S258 : f32 = max((1.0f - _S257) * (1.0f - material_11.metallic) * (1.0f - material_11.transmission), 0.0f);
    var _S259 : bool = _S258 > 0.03999999910593033f;
    var _S260 : bool;
    if(_S259)
    {
        _S260 = true;
    }
    else
    {
        _S260 = (material_11.roughness) > 0.20000000298023224f;
    }
    return _S260;
}

fn straightThrough( dir_0 : vec3<f32>,  n_7 : vec3<f32>,  material_12 : Material) -> vec3<f32>
{
    var _S261 : f32 = material_12.transmission * (1.0f - material_12.metallic);
    var _S262 : f32 = material_12.roughness;
    var _S263 : f32 = smithG1(_S262 * _S262, abs(dot(n_7, dir_0)));
    return vec3<f32>((_S261 * _S263)) * material_12.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S264 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S264 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_8 : vec3<f32>,  material_13 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S265 : vec3<f32>;
    if((material_13.ior) == 1.0f)
    {
        var _S266 : vec3<f32> = straightThrough(toward_0, n_8, material_13);
        _S265 = _S266;
    }
    else
    {
        _S265 = vec3<f32>(0.0f);
    }
    return _S265 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S267 : u32 = hash(index_0);
    var _S268 : u32 = hash((seed_0 ^ (_S267)));
    return _S268;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S269 : vec3<f32> = a_4 / b_0;
    var _S270 : vec3<f32> = vec3<f32>(0.0f);
    var _S271 : vec3<bool> = b_0 == _S270;
    var _S272 : vec3<f32> = select(_S269, _S270, _S271);
    return _S272;
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
    var _S273 : f32 = rgb_to_greyscale(weight_0);
    var _S274 : bool = _S273 > 0.0f;
    var _S275 : bool;
    if(_S274)
    {
        _S275 = _S273 < 3.00000000549775576e+38f;
    }
    else
    {
        _S275 = false;
    }
    var _S276 : bool = !_S275;
    if(_S276)
    {
        return;
    }
    var _S277 : f32 = (*sel_0).w_sum + _S273;
    (*sel_0).w_sum = _S277;
    var _S278 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S278;
    var _S279 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S279.state;
    var _S280 : bool = (_S279.value * (*sel_0).w_sum) <= _S273;
    if(_S280)
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
    var _S281 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S281;
    var _S282 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S282;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S283 : f32 = rgb_to_greyscale(r_1.f);
    var _S284 : f32 = sel_2.w_sum / _S283;
    var _S285 : bool = _S283 > 0.0f;
    var _S286 : f32 = select(0.0f, _S284, _S285);
    r_1.w = _S286;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_2 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S287 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S288 : u32 = (insertBits((_S287), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S288;
    candidate_2.f = f_2;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S289 : bool = transmission_0 > 0.0f;
    var _S290 : bool;
    if(_S289)
    {
        _S290 = true;
    }
    else
    {
        _S290 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S291 : f32;
    if(_S290)
    {
        _S291 = 1.0f;
    }
    else
    {
        _S291 = -1.0f;
    }
    return _S291;
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
    var _S292 : bool;
    if(open_0)
    {
        _S292 = prev_rough_0;
    }
    else
    {
        _S292 = false;
    }
    if(_S292)
    {
        _S292 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S292 = false;
    }
    return _S292;
}

fn withinInverseFootprint( pdf_1 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S293 : bool = pdf_1 > 0.0f;
    var _S294 : bool;
    if(_S293)
    {
        if(diffuse_0)
        {
            _S294 = true;
        }
        else
        {
            _S294 = (pdf_1 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S294 = false;
    }
    return _S294;
}

fn roughLobe( pdf_2 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S295 : bool = pdf_2 > 0.0f;
    var _S296 : bool;
    if(_S295)
    {
        if(diffuse_1)
        {
            _S296 = true;
        }
        else
        {
            _S296 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S296 = false;
    }
    return _S296;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S297 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S297.x, max(_S297.y, _S297.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S298 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S298;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S299 : f32 = c_1 * p_c_0;
    var _S300 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S299 / (_S299 + c_t_0 * g_previous_0), _S300 / (_S300 + c_1 * g_current_0));
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
    var _S301 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S302 : bool = cos_a_0 > cos_b_0;
    var _S303 : f32 = select(_S301, 1.0f, _S302);
    return _S303;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S304 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S305 : bool = cos_a_1 > cos_b_1;
    var _S306 : f32 = select(_S304, 0.0f, _S305);
    return _S306;
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
    var _S307 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S308 : vec3<f32> = node_0.high - node_0.low;
    var _S309 : vec3<f32> = p_0 - _S307;
    var _S310 : vec3<f32> = (normalize((_S309)));
    var _S311 : f32 = dot(_S309, _S309);
    var _S312 : f32 = dot(_S308, _S308) / 4.0f;
    var _S313 : f32 = abs(dot(node_0.w, _S310));
    var _S314 : f32 = sine(node_0.cos_theta_o);
    var _S315 : f32 = sqrt(max(1.0f - _S312 / _S311, 0.0f));
    var _S316 : bool = _S311 < _S312;
    var _S317 : f32 = select(_S315, -1.0f, _S316);
    var _S318 : f32 = sine(_S317);
    var _S319 : f32 = sine(_S313);
    var _S320 : f32 = cosSubClamped(_S319, _S313, _S314, node_0.cos_theta_o);
    var _S321 : f32 = sine(_S313);
    var _S322 : f32 = sinSubClamped(_S321, _S313, _S314, node_0.cos_theta_o);
    var _S323 : f32 = cosSubClamped(_S322, _S320, _S318, _S317);
    var _S324 : bool = _S323 <= 0.0f;
    if(_S324)
    {
        return 0.0f;
    }
    var _S325 : f32 = - dot(_S310, normal_0);
    var _S326 : f32 = node_0.phi * _S323 / max(_S311, length(_S308) / 2.0f);
    var _S327 : f32 = sine(_S325);
    var _S328 : f32 = cosSubClamped(_S327, _S325, _S318, _S317);
    var _S329 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S330 : f32 = select(_S328, 1.0f, _S329);
    return max(_S326 * _S330, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S331 : f32 = importance(first_0, p_1, normal_2);
    var _S332 : f32 = importance(second_0, p_1, normal_2);
    var _S333 : vec2<f32> = vec2<f32>(_S331, _S332);
    var _S334 : bool = _S331 == 0.0f;
    var _S335 : bool;
    if(_S334)
    {
        _S335 = _S332 == 0.0f;
    }
    else
    {
        _S335 = false;
    }
    if(_S335)
    {
        return u32(2);
    }
    var _S336 : f32 = _S331 + _S332;
    var _S337 : bool = _S332 > 0.0f;
    if(_S337)
    {
        _S335 = ((*pick_0) * _S336) >= _S331;
    }
    else
    {
        _S335 = false;
    }
    var _S338 : u32 = select(u32(0), u32(1), _S335);
    var _S339 : f32 = min(((*pick_0) * _S336 - f32(_S338) * _S331) / _S333[_S338], 0.99999994039535522f);
    (*pick_0) = _S339;
    var _S340 : f32 = (*probability_1) * (_S333[_S338] / _S336);
    (*probability_1) = _S340;
    return _S338;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S341 : f32 = importance(first_1, p_2, normal_3);
    var _S342 : f32 = importance(second_1, p_2, normal_3);
    var _S343 : vec2<f32> = vec2<f32>(_S341, _S342);
    var _S344 : f32 = _S343[child_0] / (_S341 + _S342);
    var _S345 : bool = (_S343[child_0]) > 0.0f;
    var _S346 : f32 = select(0.0f, _S344, _S345);
    return _S346;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S347 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S348 : bool = b_1 > 0.0f;
    var _S349 : f32 = select(1.0f, _S347, _S348);
    return _S349;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S350 : vec3<f32> = center_0 - p_3;
    var _S351 : f32 = radius_1 * radius_1 / dot(_S350, _S350);
    var _S352 : bool = _S351 >= 1.0f;
    if(_S352)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S351)) / (6.28318548202514648f * _S351);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S353 : vec3<f32> = center_1 - p_4;
    var _S354 : f32 = radius_2 * radius_2 / dot(_S353, _S353);
    var _S355 : f32 = u1_0 * _S354 / (1.0f + sqrt(max(1.0f - _S354, 0.0f)));
    var _S356 : f32 = 2.0f * u1_0;
    var _S357 : bool = _S354 >= 1.0f;
    var _S358 : f32 = select(_S355, _S356, _S357);
    var _S359 : f32 = sqrt(max(_S358 * (2.0f - _S358), 0.0f));
    var _S360 : f32 = 6.28318548202514648f * u2_0;
    var _S361 : vec3<f32> = vec3<f32>(_S359 * cos(_S360), 1.0f - _S358, _S359 * sin(_S360));
    var _S362 : vec3<f32> = (normalize((_S353)));
    var _S363 : vec3<f32> = tangentToWorld(_S361, _S362);
    return _S363;
}

