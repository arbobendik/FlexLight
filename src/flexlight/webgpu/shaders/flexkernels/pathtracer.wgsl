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
     diffuse_weight : vec3<f32>,
     refract_weight : vec3<f32>,
     p_diffuse : f32,
     p_reflect : f32,
     p_refract : f32,
     translucent_share : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32) -> BSDFLobes
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
    _S116.translucent_share = translucent_share_0;
    return _S116;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> BSDFLobes
{
    var _S117 : f32 = dot(ggx_n_0, v_4);
    var _S118 : f32 = dot(n_i_1, ggx_n_0);
    var _S119 : f32 = eta_i_2 / eta_o_2;
    var _S120 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S119))));
    var _S121 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S122 : f32 = _S121 * _S121;
    var _S123 : f32 = (1.0f + _S121) / (1.0f - _S121);
    var _S124 : f32 = abs(_S117);
    var _S125 : bool = eta_i_2 > eta_o_2;
    var _S126 : f32 = select(1.0f, _S123, _S125);
    var _S127 : f32 = select(_S123, 1.0f, _S125);
    var _S128 : f32 = fresnel(_S124, _S126, _S127);
    var _S129 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S117 * _S117)) >= (eta_o_2 * eta_o_2);
    var _S130 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S122);
    var _S131 : vec3<f32> = vec3<f32>(1.0f);
    var _S132 : vec3<f32> = _S130 + (_S131 - _S130) * vec3<f32>((_S128 - _S122)) / vec3<f32>((1.0f - _S122));
    var _S133 : vec3<f32> = vec3<f32>(1.0f);
    var _S134 : vec3<f32> = select(_S132, _S133, _S129);
    var F_1 : vec3<f32> = (mix((_S134), (material_1.albedo), (material_1.metallic)));
    var _S135 : f32 = rgb_to_greyscale(F_1);
    var _S136 : f32 = 1.0f - material_1.metallic;
    var _S137 : vec3<f32> = _S131 - _S134;
    var _S138 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S136)) * _S137;
    var _S139 : vec3<f32> = vec3<f32>((material_1.transmission * _S136)) * _S137;
    var _S140 : f32 = max(_S135, 0.0f);
    var _S141 : f32 = rgb_to_greyscale(_S138);
    var _S142 : f32 = max(_S141, 0.0f);
    var _S143 : f32 = rgb_to_greyscale(_S139);
    var _S144 : f32 = (sign((length(_S120))));
    var _S145 : f32 = max(_S143 * _S144, 0.0f);
    var _S146 : f32 = _S140 + _S142 + _S145;
    var _S147 : f32 = 1.0f / max(_S146, 0.0000152587890625f);
    var _S148 : f32 = _S142 * _S147;
    var _S149 : f32 = _S140 * _S147;
    var _S150 : f32 = _S145 * _S147;
    return BSDFLobes_x24init_0(_S117, _S118, _S120, F_1, _S135, 1.0f, _S138, _S139, _S148, _S149, _S150, 0.0f);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S151 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S152 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S153 : f32 = _S151 / (_S152 + _S151);
    var _S154 : bool = _S151 > 0.0f;
    var _S155 : f32 = select(0.0f, _S153, _S154);
    return _S155;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S156 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S157 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S158 : f32 = 1.0f - lobes_0.translucent_share;
    var _S159 : bool = n_i_dot_l_0 < 0.0f;
    var _S160 : f32 = select(_S158, lobes_0.translucent_share, _S159);
    var _S161 : f32 = _S157 * _S160;
    var _S162 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S163 : f32 = select(_S156, _S161, _S162);
    var _S164 : bool = n_i_dot_v_0 > 0.0f;
    var _S165 : f32 = select(0.0f, _S163, _S164);
    return _S165;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S166 : bool = (dot(n_i_2, l_0)) < 0.0f;
    var _S167 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S166);
    var _S168 : f32 = 1.0f - lobes_1.translucent_share;
    var _S169 : f32 = select(_S168, lobes_1.translucent_share, _S166);
    var _S170 : vec3<f32> = _S167 / vec3<f32>(_S169);
    var _S171 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S172 : vec3<f32> = select(material_3.albedo, _S170, _S171);
    return lobes_1.diffuse_weight * _S172 / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S173 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S174 : f32 = _S173 * lobes_2.v_dot_h;
    var _S175 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S176 : f32 = _S174 * _S175 / n_i_dot_v_1;
    var _S177 : bool = alpha_6 > 0.0f;
    var _S178 : bool;
    if(_S177)
    {
        _S178 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S178 = false;
    }
    if(_S178)
    {
        _S178 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S178 = false;
    }
    if(_S178)
    {
        _S178 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S178 = false;
    }
    var _S179 : f32 = select(0.0f, _S176, _S178);
    return _S179;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S180 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S181 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S182 : f32 = lobes_3.p_refract * _S180 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S181 * _S181);
    var _S183 : bool = eta_i_4 != eta_o_4;
    var _S184 : bool;
    if(_S183)
    {
        _S184 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S184 = false;
    }
    var _S185 : f32 = select(0.0f, _S182, _S184);
    return _S185;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_8 : f32,  material_4 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S186 : f32 = - dot(n_i_3, l_1);
    var _S187 : f32 = smithG1(alpha_8, max(_S186, 0.0f));
    return lobes_4.refract_weight * vec3<f32>(_S187) * material_4.albedo / vec3<f32>(lobes_4.p_refract);
}

fn reflectPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S188 : f32 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    var _S189 : f32 = lobes_5.p_reflect * _S188 / (4.0f * lobes_5.v_dot_h);
    var _S190 : bool = _S188 > 0.0f;
    var _S191 : f32 = select(0.0f, _S189, _S190);
    return _S191;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_10 : f32,  material_5 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S192 : f32 = dot(n_i_4, l_2);
    var _S193 : f32 = smithG1(alpha_10, max(_S192, 0.0f));
    return vec3<f32>((lobes_6.reflect_weight * _S193)) * lobes_6.F / vec3<f32>(lobes_6.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_6 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(3)>>,  pdfs_0 : ptr<function, array<f32, i32(3)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S194 : vec3<f32> = ((-(in_dir_4)));
    var _S195 : f32 = dot(n_5, _S194);
    var _S196 : f32 = (sign((_S195)));
    var _S197 : vec3<f32> = n_5 * vec3<f32>(_S196);
    var _S198 : f32 = dot(_S197, out_dir_2);
    var _S199 : f32 = material_6.roughness;
    var _S200 : f32 = _S199 * _S199;
    var _S201 : f32 = rgb_to_greyscale(material_6.translucent);
    var _S202 : bool = _S201 > 0.0f;
    var _S203 : bool = (dot(n_5, out_dir_2) * _S195) < 0.0f;
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
        var _S204 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S204;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S205 : vec3<f32> = vec3<f32>(0.0f);
    var _S206 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S205, _S205, 0.0f, 0.0f, _S205, _S205, 0.0f, 0.0f, 0.0f, 0.0f);
    var lobe_terms_0 : BSDFLobes = _S206;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S205;
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
        var _S208 : bool;
        if(_S207)
        {
            _S208 = _S202;
        }
        else
        {
            _S208 = false;
        }
        var _S209 : bool;
        if(_S208)
        {
            _S209 = _S203;
        }
        else
        {
            _S209 = i_0 == u32(1);
        }
        var _S210 : bool = _S209 != refracted_1;
        if(_S210)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S211 : bool = i_0 != half_of_0;
        var half_of_1 : u32;
        if(_S211)
        {
            if(_S207)
            {
                var _S212 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_6, random_state_2);
                ggx_n_1 = _S212;
            }
            else
            {
                var _S213 : bool = i_0 == u32(1);
                if(_S213)
                {
                    var _S214 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_6, eta_o_6);
                    ggx_n_1 = _S214;
                }
                else
                {
                    var _S215 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S215;
                }
            }
            var _S216 : vec3<f32> = ((-(in_dir_4)));
            var _S217 : BSDFLobes = bsdfLobes(in_dir_4, _S216, _S197, ggx_n_1, material_6, eta_i_6, eta_o_6);
            lobe_terms_0 = _S217;
            var _S218 : f32 = translucentShare(material_6);
            lobe_terms_0.translucent_share = _S218;
            half_of_1 = i_0;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(i_0)
        {
        case u32(0):
            {
                var _S219 : f32 = diffusePDF(_S198, 0.0f, abs(_S195), _S200, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(0)] = _S219;
                var _S220 : vec3<f32> = diffuseBSDF(out_dir_2, _S197, _S200, material_6, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S220;
            }
        case u32(1):
            {
                var _S221 : f32 = refractPDF(_S198, dot(out_dir_2, ggx_n_1), abs(_S195), _S200, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(1)] = _S221;
                var _S222 : vec3<f32> = refractBSDF(out_dir_2, _S197, _S200, material_6, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S222;
            }
        default :
            {
                var _S223 : f32 = reflectPDF(_S198, 0.0f, abs(_S195), _S200, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[i32(2)] = _S223;
                var _S224 : vec3<f32> = reflectBSDF(out_dir_2, _S197, _S200, material_6, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S224;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S205;
    loop
    {
        if(i_0 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S225 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S225)
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
    var _S226 : SampleBSDF;
    _S226.unit_direction = unit_direction_0;
    _S226.throughput = throughput_0;
    _S226.random_state = random_state_3;
    _S226.refracted = refracted_2;
    _S226.lobe = lobe_0;
    _S226.pdf = pdf_0;
    return _S226;
}

fn diffuseSample( u_0 : f32,  n_i_5 : vec3<f32>,  n_i_dot_v_4 : f32,  alpha_11 : f32,  material_7 : Material,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S227 : vec3<f32> = vec3<f32>(1.0f);
    var _S228 : SampleBSDF = SampleBSDF_x24init_0(_S227, _S227, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S228;
    var _S229 : Random = pcg(random_state_4);
    var _S230 : Random = pcg(_S229.state);
    sample_0.random_state = _S230.state;
    var _S231 : vec3<f32> = sampleCosWeightedHemisphere(_S229.value, _S230.value);
    var _S232 : bool = u_0 < (lobes_7.p_diffuse * lobes_7.translucent_share);
    var _S233 : f32 = _S231.y;
    var _S234 : f32 = - _S233;
    var _S235 : f32 = select(_S233, _S234, _S232);
    var _S236 : vec3<f32> = tangentToWorld(vec3<f32>(_S231.x, _S235, _S231.z), n_i_5);
    sample_0.unit_direction = _S236;
    sample_0.refracted = _S232;
    sample_0.lobe = u32(0);
    var _S237 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_5, alpha_11, material_7, lobes_7);
    sample_0.throughput = _S237;
    var _S238 : f32 = diffusePDF(_S235, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    sample_0.pdf = _S238;
    return sample_0;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_12 : f32,  material_8 : Material,  lobes_8 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S239 : vec3<f32> = vec3<f32>(1.0f);
    var _S240 : SampleBSDF = SampleBSDF_x24init_0(_S239, _S239, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S240;
    sample_1.unit_direction = lobes_8.refracted;
    sample_1.random_state = random_state_5;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S241 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_6, alpha_12, material_8, lobes_8);
    sample_1.throughput = _S241;
    var _S242 : f32 = refractPDF(0.0f, dot(sample_1.unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    sample_1.pdf = _S242;
    return sample_1;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_7 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_13 : f32,  material_9 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S243 : vec3<f32> = vec3<f32>(1.0f);
    var _S244 : SampleBSDF = SampleBSDF_x24init_0(_S243, _S243, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S244;
    var _S245 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_2.unit_direction = _S245;
    sample_2.random_state = random_state_6;
    sample_2.lobe = u32(2);
    var _S246 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    sample_2.throughput = _S246;
    var _S247 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    sample_2.pdf = _S247;
    return sample_2;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_10 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_7 : u32 = random_init_0;
    var _S248 : vec3<f32> = ((-(in_dir_6)));
    var _S249 : f32 = dot(n_6, _S248);
    var _S250 : f32 = (sign((_S249)));
    var n_i_8 : vec3<f32> = n_6 * vec3<f32>(_S250);
    var _S251 : f32 = abs(_S249);
    var _S252 : f32 = material_10.roughness;
    var _S253 : f32 = _S252 * _S252;
    var _S254 : vec3<f32> = sampleHalfVector(_S248, n_i_8, _S253, &(random_state_7));
    var _S255 : BSDFLobes = bsdfLobes(in_dir_6, _S248, n_i_8, _S254, material_10, eta_i_10, eta_o_10);
    var lobes_10 : BSDFLobes = _S255;
    var _S256 : f32 = translucentShare(material_10);
    lobes_10.translucent_share = _S256;
    var _S257 : Random = pcg(random_state_7);
    random_state_7 = _S257.state;
    var _S258 : bool = (_S257.value) < (lobes_10.p_diffuse);
    if(_S258)
    {
        var _S259 : SampleBSDF = diffuseSample(_S257.value, n_i_8, _S251, _S253, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S259;
    }
    var _S260 : bool = (_S257.value) < (lobes_10.p_diffuse + lobes_10.p_refract);
    if(_S260)
    {
        var _S261 : SampleBSDF = refractSample(_S254, n_i_8, _S251, _S253, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S261;
    }
    var _S262 : SampleBSDF = reflectSample(in_dir_6, _S254, n_i_8, _S251, _S253, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
    return _S262;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S263 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S263));
}

fn neeDecision( material_11 : Material,  n_dot_v_0 : f32,  eta_i_11 : f32,  eta_o_11 : f32) -> bool
{
    var _S264 : f32 = fresnel(abs(n_dot_v_0), eta_i_11, eta_o_11);
    var _S265 : vec3<f32> = (mix((vec3<f32>(_S264)), (material_11.albedo), (material_11.metallic)));
    var _S266 : f32 = rgb_to_greyscale(_S265);
    var _S267 : f32 = max((1.0f - _S266) * (1.0f - material_11.metallic) * (1.0f - material_11.transmission), 0.0f);
    var _S268 : bool = _S267 > 0.03999999910593033f;
    var _S269 : bool;
    if(_S268)
    {
        _S269 = true;
    }
    else
    {
        _S269 = (material_11.roughness) > 0.20000000298023224f;
    }
    return _S269;
}

fn straightThrough( material_12 : Material) -> vec3<f32>
{
    return vec3<f32>((material_12.transmission * (1.0f - material_12.metallic))) * material_12.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S270 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S270 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_7 : vec3<f32>,  material_13 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S271 : vec3<f32>;
    if((material_13.ior) == 1.0f)
    {
        var _S272 : vec3<f32> = straightThrough(material_13);
        _S271 = _S272;
    }
    else
    {
        _S271 = vec3<f32>(0.0f);
    }
    return _S271 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S273 : u32 = hash(index_0);
    var _S274 : u32 = hash((seed_0 ^ (_S273)));
    return _S274;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S275 : vec3<f32> = a_4 / b_0;
    var _S276 : vec3<f32> = vec3<f32>(0.0f);
    var _S277 : vec3<bool> = b_0 == _S276;
    var _S278 : vec3<f32> = select(_S275, _S276, _S277);
    return _S278;
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
    var _S279 : f32 = rgb_to_greyscale(weight_0);
    var _S280 : bool = _S279 > 0.0f;
    var _S281 : bool;
    if(_S280)
    {
        _S281 = _S279 < 3.00000000549775576e+38f;
    }
    else
    {
        _S281 = false;
    }
    var _S282 : bool = !_S281;
    if(_S282)
    {
        return;
    }
    var _S283 : f32 = (*sel_0).w_sum + _S279;
    (*sel_0).w_sum = _S283;
    var _S284 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S284;
    var _S285 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S285.state;
    var _S286 : bool = (_S285.value * (*sel_0).w_sum) <= _S279;
    if(_S286)
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
    var _S287 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S287;
    var _S288 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S288;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S289 : f32 = rgb_to_greyscale(r_1.f);
    var _S290 : f32 = sel_2.w_sum / _S289;
    var _S291 : bool = _S289 > 0.0f;
    var _S292 : f32 = select(0.0f, _S290, _S291);
    r_1.w = _S292;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S293 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S294 : u32 = (insertBits((_S293), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S294;
    candidate_2.f = f_1;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S295 : bool = transmission_0 > 0.0f;
    var _S296 : bool;
    if(_S295)
    {
        _S296 = true;
    }
    else
    {
        _S296 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S297 : f32;
    if(_S296)
    {
        _S297 = 1.0f;
    }
    else
    {
        _S297 = -1.0f;
    }
    return _S297;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S298 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S298.x, max(_S298.y, _S298.z)), 0.0f, 1.0f);
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S299 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S300 : bool = cos_a_0 > cos_b_0;
    var _S301 : f32 = select(_S299, 1.0f, _S300);
    return _S301;
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
    var _S302 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S303 : vec3<f32> = node_0.high - node_0.low;
    var _S304 : vec3<f32> = p_0 - _S302;
    var _S305 : vec3<f32> = (normalize((_S304)));
    var _S306 : f32 = dot(_S304, _S304);
    var _S307 : f32 = dot(_S303, _S303) / 4.0f;
    var _S308 : f32 = abs(dot(node_0.w, _S305));
    var _S309 : f32 = sine(node_0.cos_theta_o);
    var _S310 : f32 = sqrt(max(1.0f - _S307 / _S306, 0.0f));
    var _S311 : bool = _S306 < _S307;
    var _S312 : f32 = select(_S310, -1.0f, _S311);
    var _S313 : f32 = sine(_S312);
    var _S314 : f32 = sine(_S308);
    var _S315 : f32 = cosSubClamped(_S314, _S308, _S309, node_0.cos_theta_o);
    var _S316 : f32 = sine(_S308);
    var _S317 : f32 = _S316 * node_0.cos_theta_o - _S308 * _S309;
    var _S318 : bool = _S308 > (node_0.cos_theta_o);
    var _S319 : f32 = select(_S317, 0.0f, _S318);
    var _S320 : f32 = cosSubClamped(_S319, _S315, _S313, _S312);
    var _S321 : bool = _S320 <= 0.0f;
    if(_S321)
    {
        return 0.0f;
    }
    var _S322 : f32 = - dot(_S305, normal_0);
    var _S323 : f32 = node_0.phi * _S320 / max(_S306, length(_S303) / 2.0f);
    var _S324 : f32 = sine(_S322);
    var _S325 : f32 = cosSubClamped(_S324, _S322, _S313, _S312);
    var _S326 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S327 : f32 = select(_S325, 1.0f, _S326);
    return max(_S323 * _S327, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S328 : f32 = importance(first_0, p_1, normal_2);
    var _S329 : f32 = importance(second_0, p_1, normal_2);
    var _S330 : vec2<f32> = vec2<f32>(_S328, _S329);
    var _S331 : bool = _S328 == 0.0f;
    var _S332 : bool;
    if(_S331)
    {
        _S332 = _S329 == 0.0f;
    }
    else
    {
        _S332 = false;
    }
    if(_S332)
    {
        return u32(2);
    }
    var _S333 : f32 = _S328 + _S329;
    var _S334 : bool = _S329 > 0.0f;
    if(_S334)
    {
        _S332 = ((*pick_0) * _S333) >= _S328;
    }
    else
    {
        _S332 = false;
    }
    var _S335 : u32 = select(u32(0), u32(1), _S332);
    var _S336 : f32 = min(((*pick_0) * _S333 - f32(_S335) * _S328) / _S330[_S335], 0.99999994039535522f);
    (*pick_0) = _S336;
    var _S337 : f32 = (*probability_1) * (_S330[_S335] / _S333);
    (*probability_1) = _S337;
    return _S335;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S338 : f32 = importance(first_1, p_2, normal_3);
    var _S339 : f32 = importance(second_1, p_2, normal_3);
    var _S340 : vec2<f32> = vec2<f32>(_S338, _S339);
    var _S341 : f32 = _S340[child_0] / (_S338 + _S339);
    var _S342 : bool = (_S340[child_0]) > 0.0f;
    var _S343 : f32 = select(0.0f, _S341, _S342);
    return _S343;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S344 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S345 : bool = b_1 > 0.0f;
    var _S346 : f32 = select(1.0f, _S344, _S345);
    return _S346;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S347 : vec3<f32> = center_0 - p_3;
    var _S348 : f32 = radius_1 * radius_1 / dot(_S347, _S347);
    var _S349 : bool = _S348 >= 1.0f;
    if(_S349)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S348)) / (6.28318548202514648f * _S348);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S350 : vec3<f32> = center_1 - p_4;
    var _S351 : f32 = radius_2 * radius_2 / dot(_S350, _S350);
    var _S352 : f32 = u1_0 * _S351 / (1.0f + sqrt(max(1.0f - _S351, 0.0f)));
    var _S353 : f32 = 2.0f * u1_0;
    var _S354 : bool = _S351 >= 1.0f;
    var _S355 : f32 = select(_S352, _S353, _S354);
    var _S356 : f32 = sqrt(max(_S355 * (2.0f - _S355), 0.0f));
    var _S357 : f32 = 6.28318548202514648f * u2_0;
    var _S358 : vec3<f32> = vec3<f32>(_S356 * cos(_S357), 1.0f - _S355, _S356 * sin(_S357));
    var _S359 : vec3<f32> = (normalize((_S350)));
    var _S360 : vec3<f32> = tangentToWorld(_S358, _S359);
    return _S360;
}

