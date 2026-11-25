fn hash( x_0 : u32) -> u32
{
    var _S1 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S2 : u32 = ((((_S1 >> ((((_S1 >> (u32(28)))) + u32(4))))) ^ (_S1))) * u32(277803737);
    return (((_S2 >> (u32(22)))) ^ (_S2));
}

fn partner_0( p_0 : vec2<i32>,  t_0 : u32) -> vec2<i32>
{
    var sizes_0 : array<i32, i32(3)> = array<i32, i32(3)>( i32(254), i32(230), i32(210) );
    var _S3 : u32 = (uniforms_uint.frame);
    var _S4 : u32 = hash(_S3 * u32(3) + t_0);
    var _S5 : vec2<i32> = vec2<i32>(i32(1));
    var _S6 : vec2<i32> = vec2<i32>(i32(-1));
    var _S7 : vec2<bool> = vec2<bool>(((_S4 & (u32(1)))) != u32(0), ((_S4 & (u32(2)))) != u32(0));
    var _S8 : vec2<i32> = select(_S5, _S6, _S7);
    var _S9 : bool = ((_S4 & (u32(4)))) != u32(0);
    var _S10 : vec2<i32> = vec2<i32>(i32((((_S4 >> (u32(8)))) & (u32(255)))), i32((((_S4 >> (u32(16)))) & (u32(255)))));
    var _S11 : vec2<i32> = p_0.yx;
    var _S12 : vec2<i32> = select(p_0, _S11, _S9);
    var _S13 : vec2<i32> = vec2<i32>(sizes_0[t_0]);
    var _S14 : vec2<i32> = _S12 % _S13;
    var _S15 : vec2<i32> = _S13 - _S14;
    var _S16 : vec2<bool> = _S8 < vec2<i32>(i32(0));
    var _S17 : vec2<i32> = select(_S14, _S15, _S16);
    var _S18 : vec2<i32> = (_S17 + _S10) % _S13;
    var _S19 : vec4<i32> = (textureLoad(pairing, (_S18), (t_0), 0));
    var _S20 : vec2<i32> = _S19.xy * _S8;
    var _S21 : vec2<i32> = _S20.yx;
    var _S22 : vec2<i32> = select(_S20, _S21, _S9);
    return p_0 + _S22;
}

struct Domain
{
     x0 : vec3<f32>,
     x1 : vec3<f32>,
     hit : Hit,
};

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

struct ShiftJob
{
     dom : Domain,
     r : Reservoir,
};

fn spatialJob_0( p_1 : vec2<i32>,  t_1 : u32,  job_0 : ptr<function, ShiftJob>) -> bool
{
    var _S23 : bool = t_1 > u32(2);
    var _S24 : bool;
    if(_S23)
    {
        _S24 = true;
    }
    else
    {
        var _S25 : vec2<u32> = (uniforms_uint.render_size);
        _S24 = (any((p_1 >= vec2<i32>(_S25))));
    }
    if(_S24)
    {
        return false;
    }
    var _S26 : Reservoir = (loadReservoir(reservoir_temp, (p_1)));
    (*job_0).r = _S26;
    var _S27 : bool = ((*job_0).r.w) > 0.0f;
    if(_S27)
    {
        var _S28 : vec2<i32> = partner_0(p_1, t_1);
        var _S29 : Domain = (*job_0).dom;
        var _S30 : bool = (storedDomain(reservoir_temp, (_S28), &(_S29)));
        (*job_0).dom = _S29;
        _S24 = _S30;
    }
    else
    {
        _S24 = false;
    }
    return _S24;
}

fn Hit_x24init_0( uv_0 : vec2<f32>,  instance_index_0 : u32,  triangle_index_0 : u32,  is_point_light_0 : u32,  distance_0 : f32) -> Hit
{
    var _S31 : Hit;
    _S31.uv = uv_0;
    _S31.instance_index = instance_index_0;
    _S31.triangle_index = triangle_index_0;
    _S31.is_point_light = is_point_light_0;
    _S31.distance = distance_0;
    return _S31;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_0 : Hit) -> Domain
{
    var _S32 : Domain;
    _S32.x0 = x0_0;
    _S32.x1 = x1_0;
    _S32.hit = hit_0;
    return _S32;
}

fn Reservoir_x24init_0( seed_0 : u32,  path_0 : u32,  w_0 : f32,  c_0 : f32,  f_0 : vec3<f32>,  jac_0 : f32,  rc_0 : vec4<u32>,  dir_0 : vec3<f32>,  radiance_0 : vec3<f32>) -> Reservoir
{
    var _S33 : Reservoir;
    _S33.seed = seed_0;
    _S33.path = path_0;
    _S33.w = w_0;
    _S33.c = c_0;
    _S33.f = f_0;
    _S33.jac = jac_0;
    _S33.rc = rc_0;
    _S33.dir = dir_0;
    _S33.radiance = radiance_0;
    return _S33;
}

fn ShiftJob_x24init_0( dom_0 : Domain,  r_0 : Reservoir) -> ShiftJob
{
    var _S34 : ShiftJob;
    _S34.dom = dom_0;
    _S34.r = r_0;
    return _S34;
}

fn shiftBin_0( r_1 : Reservoir) -> u32
{
    var _S35 : u32 = (extractBits((r_1.path), (u32(10)), (u32(2))));
    var _S36 : bool = _S35 == u32(2);
    var _S37 : bool;
    if(_S36)
    {
        var _S38 : u32 = (extractBits((r_1.path), (u32(12)), (u32(3))));
        _S37 = _S38 == u32(4);
    }
    else
    {
        _S37 = false;
    }
    var _S39 : u32 = select(_S35, u32(4), _S37);
    var _S40 : u32 = (extractBits((r_1.path), (u32(5)), (u32(5))));
    var _S41 : u32 = (extractBits((r_1.path), (u32(0)), (u32(5))));
    var _S42 : u32 = _S41 + u32(1);
    var _S43 : bool = _S35 == u32(0);
    var _S44 : u32 = select(_S40, _S42, _S43);
    return _S39 * u32(8) + clamp(_S44, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_2 : vec2<i32>,  _S45 : ptr<function, array<u32, i32(3)>>)
{
    var _S46 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_2 : u32 = u32(0);
    loop
    {
        var _S47 : u32 = (uniforms_uint.restir_neighbours);
        if(t_2 < _S47)
        {
        }
        else
        {
            break;
        }
        var _S48 : vec3<f32> = vec3<f32>(0.0f);
        var _S49 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S48, _S48, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S48, 0.0f, vec4<u32>(u32(0)), _S48, _S48));
        var job_1 : ShiftJob = _S49;
        var _S50 : bool = spatialJob_0(p_2, t_2, &(job_1));
        if(_S50)
        {
            var _S51 : u32 = shiftBin_0(job_1.r);
            bins_0[t_2] = _S51;
        }
        var t_3 : u32 = t_2 + u32(1);
        t_2 = t_3;
    }
    (*_S45) = bins_0;
    return;
}

struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Selection_x24init_0( r_2 : Reservoir,  w_sum_0 : f32,  color_0 : vec3<f32>,  random_state_0 : u32) -> Selection
{
    var _S52 : Selection;
    _S52.r = r_2;
    _S52.w_sum = w_sum_0;
    _S52.color = color_0;
    _S52.random_state = random_state_0;
    return _S52;
}

fn Shift_x24init_0( f_1 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S53 : Shift;
    _S53.f = f_1;
    _S53.jac = jac_1;
    return _S53;
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S54 : Ray;
    _S54.origin = origin_0;
    _S54.unit_direction = unit_direction_0;
    return _S54;
}

struct NEEVertex
{
     none : bool,
     pdf : f32,
     origin : vec3<f32>,
     smooth_n : vec3<f32>,
     start : vec3<f32>,
};

fn NEEVertex_x24init_0( none_0 : bool,  pdf_0 : f32,  origin_1 : vec3<f32>,  smooth_n_0 : vec3<f32>,  start_0 : vec3<f32>) -> NEEVertex
{
    var _S55 : NEEVertex;
    _S55.none = none_0;
    _S55.pdf = pdf_0;
    _S55.origin = origin_1;
    _S55.smooth_n = smooth_n_0;
    _S55.start = start_0;
    return _S55;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_0 : u32,  pdf_1 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S56 : Vertex;
    _S56.rough = rough_0;
    _S56.lobe = lobe_0;
    _S56.pdf = pdf_1;
    _S56.cos = cos_0;
    _S56.inside = inside_0;
    return _S56;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_0 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_0 : vec3<f32>,  velvet_0 : f32,  dispersion_0 : f32,  coat_0 : f32,  coat_roughness_0 : f32,  coat_ior_0 : f32,  coat_tint_0 : vec3<f32>,  coat_normal_0 : vec3<f32>) -> Material
{
    var _S57 : Material;
    _S57.albedo = albedo_0;
    _S57.emissive = emissive_0;
    _S57.roughness = roughness_0;
    _S57.metallic = metallic_0;
    _S57.transmission = transmission_0;
    _S57.ior = ior_0;
    _S57.absorption = absorption_0;
    _S57.specular_tint = specular_tint_0;
    _S57.specular_level = specular_level_0;
    _S57.translucent = translucent_0;
    _S57.sheen = sheen_0;
    _S57.sheen_roughness = sheen_roughness_0;
    _S57.anisotropy = anisotropy_0;
    _S57.anisotropic_rotation = anisotropic_rotation_0;
    _S57.tangent = tangent_0;
    _S57.velvet = velvet_0;
    _S57.dispersion = dispersion_0;
    _S57.coat = coat_0;
    _S57.coat_roughness = coat_roughness_0;
    _S57.coat_ior = coat_ior_0;
    _S57.coat_tint = coat_tint_0;
    _S57.coat_normal = coat_normal_0;
    return _S57;
}

fn Surface_x24init_0( smooth_n_1 : vec3<f32>,  geometry_n_0 : vec3<f32>,  geometry_offset_0 : f32,  material_0 : Material,  skip_0 : bool,  random_state_1 : u32) -> Surface
{
    var _S58 : Surface;
    _S58.smooth_n = smooth_n_1;
    _S58.geometry_n = geometry_n_0;
    _S58.geometry_offset = geometry_offset_0;
    _S58.material = material_0;
    _S58.skip = skip_0;
    _S58.random_state = random_state_1;
    return _S58;
}

fn noiseOffset( k_0 : u32) -> vec2<u32>
{
    var _S59 : vec2<u32> = vec2<u32>(u32(16));
    var _S60 : vec2<u32> = (vec2<u32>(k_0 * u32(3242174889), k_0 * u32(2447445414)) >> (_S59));
    var _S61 : u32 = (fkBlueNoiseSize());
    return ((_S60 * vec2<u32>(_S61)) >> (_S59));
}

fn noiseAddress( origin_2 : u32,  bounce_0 : u32) -> u32
{
    var _S62 : vec2<u32> = vec2<u32>((origin_2 & (u32(2047))), (((origin_2 >> (u32(11)))) & (u32(2047))));
    var _S63 : vec2<u32> = noiseOffset(u32(64) + bounce_0 * u32(17));
    var _S64 : vec2<u32> = ((_S62 + _S63) & (vec2<u32>(u32(2047))));
    return ((((_S64.x) | ((((_S64.y) << (u32(11))))))) | (((((origin_2 >> (u32(22)))) << (u32(22))))));
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S65 : bool = transmission_1 > 0.0f;
    var _S66 : bool;
    if(_S65)
    {
        _S66 = true;
    }
    else
    {
        _S66 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S67 : f32 = select(-1.0f, 1.0f, _S66);
    return _S67;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S68 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S69 : vec3<f32> = vec3<f32>(_S68);
    return Surface_x24init_0(surface_0.smooth_n * _S69, surface_0.geometry_n * _S69, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

var<private> SPECTRAL_PRIMARIES_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f );
fn upsample( rgb_0 : vec3<f32>,  wavelength_0 : f32) -> f32
{
    var _S70 : f32 = clamp((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S71 : u32 = min(u32(_S70), u32(79));
    var _S72 : u32 = u32(3) * _S71;
    var _S73 : vec3<f32> = vec3<f32>(SPECTRAL_PRIMARIES_0[_S72], SPECTRAL_PRIMARIES_0[_S72 + u32(1)], SPECTRAL_PRIMARIES_0[_S72 + u32(2)]);
    var _S74 : vec3<f32> = vec3<f32>(SPECTRAL_PRIMARIES_0[_S72 + u32(3)], SPECTRAL_PRIMARIES_0[_S72 + u32(4)], SPECTRAL_PRIMARIES_0[_S72 + u32(5)]);
    return dot(rgb_0, _S73 + (_S74 - _S73) * vec3<f32>((_S70 - f32(_S71))));
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S75 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S75));
}

fn dispersive( material_1 : Material) -> bool
{
    var _S76 : bool = (material_1.dispersion) > 0.0f;
    var _S77 : bool;
    if(_S76)
    {
        _S77 = (material_1.ior) != 1.0f;
    }
    else
    {
        _S77 = false;
    }
    return _S77;
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S78 : u32 = hash(index_0);
    var _S79 : u32 = hash((seed_1 ^ (_S78)));
    return _S79;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S80 : Random;
    _S80.state = state_0;
    _S80.value = value_0;
    return _S80;
}

fn pcg( state_1 : u32) -> Random
{
    var _S81 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S82 : u32 = hash(state_1);
    return Random_x24init_0(_S81, f32(_S82) / 4.294967296e+09f);
}

var<private> WAVELENGTH_CDF_0 : array<f32, i32(81)> = array<f32, i32(81)>( 0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996238946914673f, 0.99997591972351074f, 0.9999845027923584f, 0.99998998641967773f, 0.99999326467514038f, 0.99999552965164185f, 0.99999749660491943f, 0.99999898672103882f, 1.0f );
fn sampleWavelength( u_0 : f32) -> vec2<f32>
{
    var low_0 : u32 = u32(0);
    var high_0 : u32 = u32(79);
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S83 : u32 = (low_0 + high_0 + u32(1)) / u32(2);
        var _S84 : bool = (WAVELENGTH_CDF_0[_S83]) <= u_0;
        if(_S84)
        {
            low_0 = _S83;
        }
        else
        {
            var _S85 : u32 = _S83 - u32(1);
            high_0 = _S85;
        }
    }
    var _S86 : u32 = low_0;
    var _S87 : f32 = WAVELENGTH_CDF_0[low_0 + u32(1)] - WAVELENGTH_CDF_0[low_0];
    return vec2<f32>(0.37999999523162842f + 0.00499999988824129f * (f32(low_0) + (u_0 - WAVELENGTH_CDF_0[_S86]) / _S87), _S87 / 0.00499999988824129f);
}

var<private> WAVELENGTH_WEIGHTS_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f );
fn wavelengthWeights( wavelength_1 : f32) -> vec3<f32>
{
    var _S88 : f32 = clamp((wavelength_1 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S89 : u32 = min(u32(_S88), u32(79));
    var _S90 : u32 = u32(3) * _S89;
    var _S91 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S90], WAVELENGTH_WEIGHTS_0[_S90 + u32(1)], WAVELENGTH_WEIGHTS_0[_S90 + u32(2)]);
    var _S92 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S90 + u32(3)], WAVELENGTH_WEIGHTS_0[_S90 + u32(4)], WAVELENGTH_WEIGHTS_0[_S90 + u32(5)]);
    return _S91 + (_S92 - _S91) * vec3<f32>((_S88 - f32(_S89)));
}

fn atWavelength( material_2 : Material,  wavelength_2 : f32) -> Material
{
    var at_0 : Material = material_2;
    var _S93 : f32 = upsample(material_2.albedo, wavelength_2);
    var _S94 : vec3<f32> = vec3<f32>(_S93);
    at_0.albedo = _S94;
    var _S95 : f32 = upsample(material_2.emissive, wavelength_2);
    var _S96 : vec3<f32> = vec3<f32>(_S95);
    at_0.emissive = _S96;
    var _S97 : f32 = upsample(material_2.absorption, wavelength_2);
    var _S98 : vec3<f32> = vec3<f32>(_S97);
    at_0.absorption = _S98;
    var _S99 : f32 = upsample(material_2.specular_tint, wavelength_2);
    var _S100 : vec3<f32> = vec3<f32>(_S99);
    at_0.specular_tint = _S100;
    var _S101 : f32 = upsample(material_2.translucent, wavelength_2);
    var _S102 : vec3<f32> = vec3<f32>(_S101);
    at_0.translucent = _S102;
    var _S103 : f32 = upsample(material_2.sheen, wavelength_2);
    var _S104 : vec3<f32> = vec3<f32>(_S103);
    at_0.sheen = _S104;
    var _S105 : f32 = upsample(material_2.coat_tint, wavelength_2);
    var _S106 : vec3<f32> = vec3<f32>(_S105);
    at_0.coat_tint = _S106;
    return at_0;
}

fn pathMaterial( material_3 : Material,  wavelength_3 : f32) -> Material
{
    var _S107 : Material;
    if(wavelength_3 > 0.0f)
    {
        var _S108 : Material = atWavelength(material_3, wavelength_3);
        _S107 = _S108;
    }
    else
    {
        _S107 = material_3;
    }
    return _S107;
}

fn dispersedIor( ior_1 : f32,  dispersion_1 : f32,  wavelength_4 : f32) -> f32
{
    var _S109 : f32 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    var _S110 : f32 = _S109 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    var _S111 : bool = dispersion_1 > 0.0f;
    var _S112 : f32 = select(0.0f, _S110, _S111);
    return ior_1 + _S112;
}

fn vertexEta( material_4 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S113 : bool = n_dot_v_0 < 0.0f;
    var _S114 : f32 = select(1.0f, material_4.ior, _S113);
    var _S115 : f32 = select(material_4.ior, 1.0f, _S113);
    return vec2<f32>(_S114, _S115);
}

fn wavelengthEta( material_5 : Material,  n_dot_v_1 : f32,  wavelength_5 : f32) -> vec2<f32>
{
    var refractive_0 : Material = material_5;
    var _S116 : f32 = dispersedIor(material_5.ior, material_5.dispersion, wavelength_5);
    var _S117 : bool = wavelength_5 > 0.0f;
    var _S118 : f32 = select(material_5.ior, _S116, _S117);
    refractive_0.ior = _S118;
    var _S119 : vec2<f32> = vertexEta(refractive_0, n_dot_v_1);
    return _S119;
}

struct Facets
{
     h : vec3<f32>,
     coat_h : vec3<f32>,
};

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S120 : AnisotropicFrame;
    _S120.tangent = tangent_1;
    _S120.alphas = alphas_0;
    return _S120;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S121 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S121)
    {
        const _S122 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S122;
    }
    else
    {
        a_1 = a_0;
    }
    var _S123 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S124 : vec3<f32> = cross(n_0, _S123);
    return vec3<f32>(v_0.x) * _S123 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S124;
}

fn anisotropicFrame( material_6 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S125 : f32 = material_6.roughness;
    var _S126 : f32 = _S125 * _S125;
    var _S127 : bool = (material_6.anisotropy) == 0.0f;
    var _S128 : bool;
    if(_S127)
    {
        _S128 = true;
    }
    else
    {
        _S128 = !(_S126 > 0.0f);
    }
    if(_S128)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S129 : vec3<f32> = material_6.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_6.tangent));
    var _S130 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S131 : bool = (dot(_S129, _S129)) > 0.0f;
    var _S132 : vec3<f32> = select(_S130, _S129, _S131);
    var _S133 : vec3<f32> = (normalize((_S132)));
    var _S134 : f32 = 6.28318548202514648f * material_6.anisotropic_rotation;
    var _S135 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_6.anisotropy));
    var _S136 : f32 = 1.0f / _S135;
    var _S137 : bool = (material_6.anisotropy) < 0.0f;
    var _S138 : f32 = select(_S135, _S136, _S137);
    return AnisotropicFrame_x24init_0(_S133 * vec3<f32>(cos(_S134)) + cross(n_i_0, _S133) * vec3<f32>(sin(_S134)), vec2<f32>(_S126 / _S138, _S126 * _S138));
}

fn draw( address_0 : u32,  variable_0 : u32) -> Random
{
    var _S139 : u32 = (address_0 >> (u32(22)));
    var _S140 : u32 = _S139 / u32(32);
    var _S141 : vec2<u32> = vec2<u32>((address_0 & (u32(2047))), (((address_0 >> (u32(11)))) & (u32(2047))));
    var _S142 : u32 = (variable_0 & (u32(2147483647)));
    var _S143 : vec2<u32> = noiseOffset(_S142);
    var _S144 : vec2<u32> = _S141 + _S143;
    var _S145 : vec2<u32> = noiseOffset(u32(4096) + _S140);
    var _S146 : vec2<u32> = _S144 + _S145;
    var _S147 : u32 = (fkBlueNoiseSize());
    var _S148 : vec2<u32> = (_S146 & (vec2<u32>((_S147 - u32(1)))));
    var _S149 : u32 = (fkBlueNoise((_S148.x), (_S148.y), ((_S139 + (((_S140 * u32(2654435769)) >> (u32(27))))) % u32(32))));
    var _S150 : bool = ((variable_0 & (u32(2147483648)))) != u32(0);
    var _S151 : u32 = stream(address_0, _S142);
    var _S152 : Random = pcg(_S151);
    var _S153 : u32 = (_S149 & (u32(65535)));
    var _S154 : u32 = (_S149 >> (u32(16)));
    var _S155 : u32 = select(_S153, _S154, _S150);
    var _S156 : f32 = (f32(_S155) + 0.5f) / 6.5536e+04f;
    var _S157 : Random = pcg(_S152.state);
    var _S158 : f32 = select(_S152.value, _S157.value, _S150);
    var _S159 : bool = _S149 == u32(4294967295);
    var _S160 : f32 = select(_S156, _S158, _S159);
    return Random_x24init_0(address_0, _S160);
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_1, t_4)), dot(w_1, n_1));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S161 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S162 : f32 = _S161.x;
    var _S163 : f32 = _S161.y;
    var _S164 : f32 = _S162 * _S162 + _S163 * _S163;
    const _S165 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S166 : vec3<f32> = vec3<f32>(- _S163, _S162, 0.0f);
    var _S167 : f32 = (inverseSqrt((_S164)));
    var _S168 : vec3<f32> = _S166 * vec3<f32>(_S167);
    var _S169 : bool = _S164 > 0.0f;
    var _S170 : vec3<f32> = select(_S165, _S168, _S169);
    var _S171 : vec3<f32> = cross(_S161, _S170);
    var _S172 : f32 = sqrt(U1_0);
    var _S173 : f32 = 6.28318548202514648f * U2_0;
    var _S174 : f32 = _S172 * cos(_S173);
    var t2_0 : f32 = _S172 * sin(_S173);
    var _S175 : f32 = 0.5f * (1.0f + _S161.z);
    var t2_1 : f32 = (1.0f - _S175) * sqrt(max(0.0f, 1.0f - _S174 * _S174)) + _S175 * t2_0;
    var _S176 : vec3<f32> = vec3<f32>(_S174) * _S170 + vec3<f32>(t2_1) * _S171;
    var _S177 : f32 = ((_S174));
    var _S178 : f32 = ((_S174));
    var _S179 : vec3<f32> = _S176 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S177 * _S178 - t2_1 * t2_1))) * _S161;
    var _S180 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S179.x, alpha_0 * _S179.y, max(0.0f, _S179.z)))));
    return _S180;
}

fn worldToTangent( v_1 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S181 : bool = (abs(dot(n_2, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S181)
    {
        const _S182 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S182;
    }
    else
    {
        a_3 = a_2;
    }
    var _S183 : vec3<f32> = (normalize((cross(n_2, a_3))));
    var _S184 : vec3<f32> = cross(n_2, _S183);
    return vec3<f32>(dot(v_1, _S183), dot(v_1, n_2), dot(v_1, _S184));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_2 : ptr<function, u32>,  first_0 : u32) -> vec3<f32>
{
    var _S185 : Random = draw((*random_state_2), first_0);
    var _S186 : Random = draw((*random_state_2), (first_0 | (u32(2147483648))));
    (*random_state_2) = _S186.state;
    var _S187 : f32 = frame_0.alphas.x;
    var _S188 : bool = _S187 > 0.0f;
    if(_S188)
    {
        var _S189 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S190 : f32 = frame_0.alphas.y;
        var _S191 : vec3<f32> = (normalize((vec3<f32>(_S187 * _S189.x, _S190 * _S189.y, _S189.z))));
        var _S192 : vec3<f32> = sampleGGXVNDF(_S191, 1.0f, _S185.value, _S186.value);
        var _S193 : vec3<f32> = (normalize((vec3<f32>(_S187 * _S192.x, _S190 * _S192.y, _S192.z))));
        return vec3<f32>(_S193.x) * frame_0.tangent + vec3<f32>(_S193.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S193.z) * n_i_1;
    }
    var _S194 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S195 : vec3<f32> = sampleGGXVNDF(_S194.xzy, alpha_1, _S185.value, _S186.value);
    var _S196 : vec3<f32> = _S195.xzy;
    var _S197 : vec3<f32> = tangentToWorld(_S196, n_i_1);
    return _S197;
}

struct CoatFrame
{
     normal : vec3<f32>,
     alpha : f32,
     ior : f32,
};

fn CoatFrame_x24init_0( normal_0 : vec3<f32>,  alpha_2 : f32,  ior_2 : f32) -> CoatFrame
{
    var _S198 : CoatFrame;
    _S198.normal = normal_0;
    _S198.alpha = alpha_2;
    _S198.ior = ior_2;
    return _S198;
}

fn coatFrame( material_7 : Material,  n_3 : vec3<f32>) -> CoatFrame
{
    var _S199 : CoatFrame = CoatFrame_x24init_0(vec3<f32>(0.0f), 0.0f, 0.0f);
    var _S200 : bool = (material_7.coat) > 0.0f;
    var frame_1 : CoatFrame;
    if(_S200)
    {
        var _S201 : vec3<f32> = material_7.coat_normal;
        var _S202 : bool = (dot(_S201, _S201)) > 0.0f;
        var _S203 : vec3<f32> = (normalize((material_7.coat_normal)));
        var _S204 : vec3<f32> = select(n_3, _S203, _S202);
        var _S205 : f32 = (sign((dot(_S204, n_3))));
        var _S206 : f32 = material_7.coat_roughness;
        var _S207 : CoatFrame = CoatFrame_x24init_0(_S204 * vec3<f32>(_S205), _S206 * _S206, max(material_7.coat_ior, 1.00999999046325684f));
        frame_1 = _S207;
    }
    else
    {
        frame_1 = _S199;
    }
    return frame_1;
}

fn coatHalf( v_3 : vec3<f32>,  coat_frame_0 : CoatFrame,  random_state_3 : u32) -> vec3<f32>
{
    var _S208 : bool = !((dot(coat_frame_0.normal, v_3)) > 0.0f);
    if(_S208)
    {
        return vec3<f32>(0.0f);
    }
    var state_2 : u32 = random_state_3;
    var _S209 : vec3<f32> = sampleHalfVector(v_3, coat_frame_0.normal, coat_frame_0.alpha, AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f)), &(state_2), u32(1));
    return _S209;
}

fn Facets_x24init_0( h_0 : vec3<f32>,  coat_h_0 : vec3<f32>) -> Facets
{
    var _S210 : Facets;
    _S210.h = h_0;
    _S210.coat_h = coat_h_0;
    return _S210;
}

fn drawFacets( in_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_8 : Material,  random_state_4 : u32) -> Facets
{
    var _S211 : vec3<f32> = ((-(in_dir_0)));
    var _S212 : f32 = (sign((dot(n_4, _S211))));
    var _S213 : vec3<f32> = n_4 * vec3<f32>(_S212);
    var state_3 : u32 = random_state_4;
    var _S214 : f32 = material_8.roughness;
    var _S215 : f32 = _S214 * _S214;
    var _S216 : AnisotropicFrame = anisotropicFrame(material_8, _S213);
    var _S217 : vec3<f32> = sampleHalfVector(_S211, _S213, _S215, _S216, &(state_3), u32(0));
    var _S218 : CoatFrame = coatFrame(material_8, _S213);
    var _S219 : vec3<f32> = coatHalf(_S211, _S218, random_state_4);
    return Facets_x24init_0(_S217, _S219);
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S220 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S221 : f32 = eta_i_0 / eta_o_0 * _S220;
    var _S222 : bool = _S221 < 1.0f;
    var kr_0 : f32;
    if(_S222)
    {
        var _S223 : f32 = sqrt(max(0.0f, 1.0f - _S221 * _S221));
        var _S224 : bool = eta_i_0 == eta_o_0;
        var _S225 : f32 = select(_S223, cos_theta_0, _S224);
        var _S226 : f32 = eta_o_0 * cos_theta_0;
        var _S227 : f32 = eta_i_0 * _S225;
        var _S228 : f32 = (_S226 - _S227) / (_S226 + _S227);
        var _S229 : f32 = eta_i_0 * cos_theta_0;
        var _S230 : f32 = eta_o_0 * _S225;
        var _S231 : f32 = (_S229 - _S230) / (_S229 + _S230);
        var _S232 : f32 = (_S228 * _S228 + _S231 * _S231) / 2.0f;
        kr_0 = _S232;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn rgb_to_greyscale( rgb_1 : vec3<f32>) -> f32
{
    return dot(rgb_1, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn neeDecision( material_9 : Material,  n_dot_v_2 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> bool
{
    var _S233 : f32 = fresnel(abs(n_dot_v_2), eta_i_1, eta_o_1);
    var _S234 : vec3<f32> = (mix((vec3<f32>(_S233)), (material_9.albedo), (material_9.metallic)));
    var _S235 : f32 = rgb_to_greyscale(_S234);
    var _S236 : f32 = max((1.0f - _S235) * (1.0f - material_9.metallic) * (1.0f - material_9.transmission), 0.0f);
    var _S237 : bool = _S236 > 0.03999999910593033f;
    var _S238 : bool;
    if(_S237)
    {
        _S238 = true;
    }
    else
    {
        _S238 = (material_9.roughness) > 0.20000000298023224f;
    }
    return _S238;
}

fn isTranslucent_0( material_10 : Material) -> bool
{
    var _S239 : f32 = rgb_to_greyscale(material_10.translucent);
    return _S239 > 0.0f;
}

struct LightBounds
{
     low : vec3<f32>,
     high : vec3<f32>,
     w : vec3<f32>,
     phi : f32,
     cos_theta_o : f32,
};

fn sine( c_1 : f32) -> f32
{
    return sqrt(max(1.0f - c_1 * c_1, 0.0f));
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S240 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S241 : bool = cos_a_0 > cos_b_0;
    var _S242 : f32 = select(_S240, 1.0f, _S241);
    return _S242;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_1 : vec3<f32>) -> f32
{
    var _S243 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S244 : vec3<f32> = node_0.high - node_0.low;
    var _S245 : vec3<f32> = p_3 - _S243;
    var _S246 : vec3<f32> = (normalize((_S245)));
    var _S247 : f32 = dot(_S245, _S245);
    var _S248 : f32 = dot(_S244, _S244) / 4.0f;
    var _S249 : f32 = abs(dot(node_0.w, _S246));
    var _S250 : f32 = sine(node_0.cos_theta_o);
    var _S251 : f32 = sqrt(max(1.0f - _S248 / _S247, 0.0f));
    var _S252 : bool = _S247 < _S248;
    var _S253 : f32 = select(_S251, -1.0f, _S252);
    var _S254 : f32 = sine(_S253);
    var _S255 : f32 = sine(_S249);
    var _S256 : f32 = cosSubClamped(_S255, _S249, _S250, node_0.cos_theta_o);
    var _S257 : f32 = sine(_S249);
    var _S258 : f32 = _S257 * node_0.cos_theta_o - _S249 * _S250;
    var _S259 : bool = _S249 > (node_0.cos_theta_o);
    var _S260 : f32 = select(_S258, 0.0f, _S259);
    var _S261 : f32 = cosSubClamped(_S260, _S256, _S254, _S253);
    var _S262 : bool = _S261 <= 0.0f;
    if(_S262)
    {
        return 0.0f;
    }
    var _S263 : f32 = - dot(_S246, normal_1);
    var _S264 : f32 = node_0.phi * _S261 / max(_S247, length(_S244) / 2.0f);
    var _S265 : f32 = sine(_S263);
    var _S266 : f32 = cosSubClamped(_S265, _S263, _S254, _S253);
    var _S267 : bool = (dot(normal_1, normal_1)) == 0.0f;
    var _S268 : f32 = select(_S266, 1.0f, _S267);
    return max(_S264 * _S268, 0.0f);
}

fn childShare( first_1 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_2 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S269 : f32 = importance(first_1, p_4, normal_2);
    var _S270 : f32 = importance(second_0, p_4, normal_2);
    var _S271 : vec2<f32> = vec2<f32>(_S269, _S270);
    var _S272 : f32 = _S271[child_0] / (_S269 + _S270);
    var _S273 : bool = (_S271[child_0]) > 0.0f;
    var _S274 : f32 = select(0.0f, _S272, _S273);
    return _S274;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S275 : vec3<f32> = center_0 - p_5;
    var _S276 : f32 = radius_0 * radius_0 / dot(_S275, _S275);
    var _S277 : bool = _S276 >= 1.0f;
    if(_S277)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S276)) / (6.28318548202514648f * _S276);
}

fn solidAngle( probability_0 : f32,  normal_3 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_3, toward_0));
}

fn lightPdf_0( origin_3 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S278 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S279 : vec2<u32> = _S278.xy;
    var n_5 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S279;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S280 : vec4<u32> = (access_light_tree(4u + 4u * (n_5)));
        if((_S280.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S281 : u32 = (access_light_tree(3u + 4u * (n_5)).w);
        var _S282 : u32 = n_5 + u32(1);
        var _S283 : LightBounds = (lightBounds((_S282)));
        var _S284 : LightBounds = (lightBounds((_S281)));
        var _S285 : u32 = trail_0.x;
        var _S286 : u32 = (_S285 & (u32(1)));
        var _S287 : f32 = childShare(_S283, _S284, origin_3, smooth_n_2, _S286);
        var probability_2 : f32 = probability_1 * _S287;
        var _S288 : bool = _S286 == u32(1);
        var _S289 : u32 = select(_S282, _S281, _S288);
        var _S290 : u32 = trail_0.y;
        var _S291 : vec2<u32> = vec2<u32>((((_S285 >> (u32(1)))) | (((_S290 << (u32(31)))))), (_S290 >> (u32(1))));
        n_5 = _S289;
        trail_0 = _S291;
        probability_1 = probability_2;
    }
    var _S292 : bool = (((_S278).z == (n_5)));
    var _S293 : bool = !_S292;
    var _S294 : bool;
    if(_S293)
    {
        _S294 = true;
    }
    else
    {
        var _S295 : LightBounds = (lightBounds((n_5)));
        var _S296 : f32 = importance(_S295, origin_3, smooth_n_2);
        _S294 = !(_S296 > 0.0f);
    }
    if(_S294)
    {
        _S294 = true;
    }
    else
    {
        var _S297 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S297)
        {
            _S294 = !((dot(smooth_n_2, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S294 = false;
        }
    }
    if(_S294)
    {
        return 0.0f;
    }
    var _S298 : vec4<u32> = (access_light_tree(4u + 4u * (n_5)));
    var _S299 : bool = (_S298.x) == u32(2);
    if(_S299)
    {
        var _S300 : Light = (lights[(_S298.y)]);
        var _S301 : f32 = sphereDensity(_S300.position, _S300.variance, start_1);
        return probability_1 * _S301;
    }
    var _S302 : u32 = _S298.y;
    var _S303 : u32 = ((instance_uint[(_S302) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S304 : mat3x3<f32> = (worldTriangle((_S302), (_S303 + _S298.z)));
    var _S305 : f32 = solidAngle(probability_1, cross(_S304[i32(1)] - _S304[i32(0)], _S304[i32(2)] - _S304[i32(0)]), light_point_0 - start_1);
    return _S305;
}

fn powerHeuristic( a_4 : f32,  b_0 : f32) -> f32
{
    var _S306 : f32 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    var _S307 : bool = b_0 > 0.0f;
    var _S308 : f32 = select(1.0f, _S306, _S307);
    return _S308;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S309 : u32 = (lightSlot((hit_1)));
    var _S310 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S309, light_point_1);
    var _S311 : f32 = powerHeuristic(vertex_0.pdf, _S310);
    return _S311;
}

fn pathColor( f_2 : vec3<f32>,  weight_0 : vec3<f32>,  wavelength_6 : f32) -> vec3<f32>
{
    var _S312 : f32 = upsample(f_2, wavelength_6);
    var _S313 : vec3<f32> = weight_0 * vec3<f32>(_S312);
    var _S314 : bool = wavelength_6 > 0.0f;
    var _S315 : vec3<f32> = select(f_2, _S313, _S314);
    return _S315;
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_2 : vec3<f32>,  radiance_1 : vec3<f32>,  density_0 : f32,  random_state_5 : u32) -> TreeSample
{
    var _S316 : TreeSample;
    _S316.dir = dir_2;
    _S316.radiance = radiance_1;
    _S316.density = density_0;
    _S316.random_state = random_state_5;
    return _S316;
}

fn pickChild( first_2 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_4 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S317 : f32 = importance(first_2, p_6, normal_4);
    var _S318 : f32 = importance(second_1, p_6, normal_4);
    var _S319 : vec2<f32> = vec2<f32>(_S317, _S318);
    var _S320 : bool = _S317 == 0.0f;
    var _S321 : bool;
    if(_S320)
    {
        _S321 = _S318 == 0.0f;
    }
    else
    {
        _S321 = false;
    }
    if(_S321)
    {
        return u32(2);
    }
    var _S322 : f32 = _S317 + _S318;
    var _S323 : bool = _S318 > 0.0f;
    if(_S323)
    {
        _S321 = ((*pick_0) * _S322) >= _S317;
    }
    else
    {
        _S321 = false;
    }
    var _S324 : u32 = select(u32(0), u32(1), _S321);
    var _S325 : f32 = min(((*pick_0) * _S322 - f32(_S324) * _S317) / _S319[_S324], 0.99999994039535522f);
    (*pick_0) = _S325;
    var _S326 : f32 = (*probability_3) * (_S319[_S324] / _S322);
    (*probability_3) = _S326;
    return _S324;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S327 : vec3<f32> = center_1 - p_7;
    var _S328 : f32 = radius_1 * radius_1 / dot(_S327, _S327);
    var _S329 : f32 = u1_0 * _S328 / (1.0f + sqrt(max(1.0f - _S328, 0.0f)));
    var _S330 : f32 = 2.0f * u1_0;
    var _S331 : bool = _S328 >= 1.0f;
    var _S332 : f32 = select(_S329, _S330, _S331);
    var _S333 : f32 = sqrt(max(_S332 * (2.0f - _S332), 0.0f));
    var _S334 : f32 = 6.28318548202514648f * u2_0;
    var _S335 : vec3<f32> = vec3<f32>(_S333 * cos(_S334), 1.0f - _S332, _S333 * sin(_S334));
    var _S336 : vec3<f32> = (normalize((_S327)));
    var _S337 : vec3<f32> = tangentToWorld(_S335, _S336);
    return _S337;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S338 : vec3<f32> = center_2 - ray_0.origin;
    var _S339 : f32 = dot(_S338, ray_0.unit_direction);
    var _S340 : f32 = dot(_S338, _S338) - _S339 * _S339;
    var _S341 : f32 = radius_3 * radius_3;
    var _S342 : bool = _S340 > _S341;
    if(_S342)
    {
        return 4.294967296e+09f;
    }
    var _S343 : f32 = sqrt(_S341 - _S340);
    var _S344 : f32 = _S339 - _S343;
    var _S345 : f32 = _S339 + _S343;
    var _S346 : bool = _S344 > 0.0000152587890625f;
    var _S347 : bool;
    if(_S346)
    {
        _S347 = _S344 < max_len_0;
    }
    else
    {
        _S347 = false;
    }
    if(_S347)
    {
        return _S344;
    }
    var _S348 : bool = _S345 > 0.0000152587890625f;
    if(_S348)
    {
        _S347 = _S345 < max_len_0;
    }
    else
    {
        _S347 = false;
    }
    if(_S347)
    {
        return _S345;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_4 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S349 : vec3<f32> = (normalize((light_dir_0)));
    var _S350 : bool = (dot(smooth_n_3, _S349)) < 0.0f;
    if(_S350)
    {
        return vec3<f32>(0.0f);
    }
    var _S351 : vec3<f32> = origin_4 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S352 : Ray = Ray_x24init_0(_S351, _S349);
    var _S353 : f32 = shadowLength(light_dir_0);
    var _S354 : vec3<f32> = (shadowTransmittance((_S352), (_S353)));
    return _S354;
}

fn sampleLightTree_0( origin_5 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S355 : Random = draw(init_random_state_0, u32(4));
    var _S356 : Random = draw(init_random_state_0, u32(5));
    var _S357 : Random = draw(init_random_state_0, u32(2147483653));
    var _S358 : vec3<f32> = vec3<f32>(0.0f);
    var _S359 : TreeSample = TreeSample_x24init_0(_S358, _S358, 0.0f, _S357.state);
    var sample_0 : TreeSample = _S359;
    var _S360 : vec3<f32> = select(smooth_n_4, _S358, sided_0);
    var _S361 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S362 : vec3<f32> = origin_5 + _S361 * smooth_n_4;
    var pick_1 : f32 = _S355.value;
    var probability_4 : f32 = 1.0f;
    var n_6 : u32 = u32(0);
    loop
    {
        var _S363 : vec4<u32> = (access_light_tree(4u + 4u * (n_6)));
        if((_S363.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S364 : u32 = (access_light_tree(3u + 4u * (n_6)).w);
        var _S365 : u32 = n_6 + u32(1);
        var _S366 : LightBounds = (lightBounds((_S365)));
        var _S367 : LightBounds = (lightBounds((_S364)));
        var _S368 : u32 = pickChild(_S366, _S367, origin_5, _S360, &(pick_1), &(probability_4));
        var _S369 : bool = _S368 > u32(1);
        if(_S369)
        {
            return sample_0;
        }
        var _S370 : bool = _S368 == u32(1);
        var _S371 : u32 = select(_S365, _S364, _S370);
        n_6 = _S371;
    }
    var _S372 : bool = n_6 == u32(0);
    var _S373 : bool;
    if(_S372)
    {
        var _S374 : LightBounds = (lightBounds((u32(0))));
        var _S375 : f32 = importance(_S374, origin_5, _S360);
        _S373 = !(_S375 > 0.0f);
    }
    else
    {
        _S373 = false;
    }
    if(_S373)
    {
        return sample_0;
    }
    var _S376 : vec4<u32> = (access_light_tree(4u + 4u * (n_6)));
    var _S377 : bool = (_S376.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S377)
    {
        var _S378 : Light = (lights[(_S376.y)]);
        if(sided_0)
        {
            var _S379 : f32 = (sign((dot(geometry_n_1, _S378.position - origin_5))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S379);
            var _S380 : vec3<f32> = origin_5 + _S361 * lift_n_1;
            start_2 = _S380;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S362;
            lift_n_0 = smooth_n_4;
        }
        var _S381 : bool = (_S378.variance) == 0.0f;
        if(_S381)
        {
            var _S382 : vec3<f32> = _S378.position - start_2;
            var _S383 : vec3<f32> = (normalize((_S382)));
            sample_0.dir = _S383;
            var _S384 : vec3<f32> = _S378.color * vec3<f32>(_S378.intensity) / vec3<f32>((dot(_S382, _S382) * probability_4));
            sample_0.radiance = _S384;
            shadow_1 = _S382;
        }
        else
        {
            var _S385 : vec3<f32> = sampleSphere(_S378.position, _S378.variance, start_2, _S356.value, _S357.value);
            sample_0.dir = _S385;
            var _S386 : f32 = sphereDensity(_S378.position, _S378.variance, start_2);
            var _S387 : f32 = probability_4 * _S386;
            sample_0.density = _S387;
            var _S388 : vec3<f32> = pointLightRadiance(_S378.color, _S378.intensity, _S378.variance);
            var _S389 : vec3<f32> = _S388 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S389;
            var _S390 : f32 = raySphere_0(_S378.position, _S378.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S391 : vec3<f32> = sample_0.dir * vec3<f32>(_S390);
            shadow_1 = _S391;
        }
    }
    else
    {
        var _S392 : u32 = _S376.y;
        var _S393 : u32 = ((instance_uint[(_S392) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S394 : u32 = _S393 + _S376.z;
        var _S395 : mat3x3<f32> = (worldTriangle((_S392), (_S394)));
        var _S396 : f32 = sqrt(_S356.value);
        var _S397 : vec2<f32> = vec2<f32>(_S396 * (1.0f - _S357.value), _S396 * _S357.value);
        var _S398 : vec3<f32> = (((_S395) * (vec3<f32>(1.0f - _S396, _S397))));
        if(sided_0)
        {
            var _S399 : f32 = (sign((dot(geometry_n_1, _S398 - origin_5))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S399);
            var _S400 : vec3<f32> = origin_5 + _S361 * lift_n_2;
            start_2 = _S400;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S401 : bool = !((dot(smooth_n_4, _S398 - origin_5)) > 0.0f);
            if(_S401)
            {
                return sample_0;
            }
            start_2 = _S362;
            lift_n_0 = smooth_n_4;
        }
        var _S402 : Surface = (surfaceAt((Hit_x24init_0(_S397, _S392, _S394, u32(0), 0.0f)), (_S398), (_S357.state)));
        sample_0.random_state = _S402.random_state;
        var _S403 : vec3<f32> = _S398 - start_2;
        var _S404 : vec3<f32> = (normalize((_S403)));
        sample_0.dir = _S404;
        var _S405 : f32 = solidAngle(probability_4, cross(_S395[i32(1)] - _S395[i32(0)], _S395[i32(2)] - _S395[i32(0)]), _S403);
        sample_0.density = _S405;
        var _S406 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S402.smooth_n))));
        var _S407 : vec3<f32> = _S402.material.emissive * vec3<f32>(max(_S406, 0.0f));
        var _S408 : vec3<f32> = select(_S407, _S358, _S402.skip);
        var _S409 : vec3<f32> = _S408 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S409;
        shadow_1 = _S403;
    }
    var _S410 : vec3<f32> = lightTransmittance_0(origin_5, lift_n_0, geometry_offset_2, shadow_1);
    var _S411 : vec3<f32> = sample_0.radiance * _S410;
    var _S412 : bool = (all((_S410 == _S358)));
    var _S413 : vec3<f32> = select(_S411, _S358, _S412);
    sample_0.radiance = _S413;
    return sample_0;
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S414 : SheenProfile;
    _S414.on = on_0;
    _S414.albedo = albedo_1;
    return _S414;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_4 : vec3<f32>,  n_i_2 : vec3<f32>,  material_11 : Material) -> SheenProfile
{
    var _S415 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S416 : f32 = rgb_to_greyscale(material_11.sheen);
    var _S417 : bool = _S416 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S417)
    {
        var _S418 : f32 = clamp(sqrt(max(dot(n_i_2, v_4), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S419 : u32 = min(u32(_S418), u32(22));
        var _S420 : f32 = sqrt(0.05000000074505806f);
        var _S421 : f32 = sqrt(0.00999999977648258f);
        var _S422 : bool = (material_11.velvet) > 0.0f;
        var _S423 : f32 = select(_S420, _S421, _S422);
        var _S424 : f32 = (clamp(sqrt(max(material_11.sheen_roughness, 0.0f)), _S423, 1.0f) - _S423) / (1.0f - _S423) * 23.0f;
        var _S425 : u32 = min(u32(_S424), u32(22));
        var _S426 : u32 = _S419 * u32(24) + _S425;
        var _S427 : f32 = _S418 - f32(_S419);
        var _S428 : f32 = _S424 - f32(_S425);
        if(_S422)
        {
            var _S429 : u32 = _S426 + u32(24);
            var _S430 : f32 = VELVET_ALBEDO_0[_S426] + (VELVET_ALBEDO_0[_S429] - VELVET_ALBEDO_0[_S426]) * _S427;
            var _S431 : u32 = _S426 + u32(1);
            var _S432 : f32 = VELVET_ALBEDO_0[_S431] + (VELVET_ALBEDO_0[_S429 + u32(1)] - VELVET_ALBEDO_0[_S431]) * _S427;
            var _S433 : SheenProfile = SheenProfile_x24init_0(true, _S430 + (_S432 - _S430) * _S428);
            profile_0 = _S433;
        }
        else
        {
            var _S434 : u32 = _S426 + u32(24);
            var _S435 : f32 = SHEEN_ALBEDO_0[_S426] + (SHEEN_ALBEDO_0[_S434] - SHEEN_ALBEDO_0[_S426]) * _S427;
            var _S436 : u32 = _S426 + u32(1);
            var _S437 : f32 = SHEEN_ALBEDO_0[_S436] + (SHEEN_ALBEDO_0[_S434 + u32(1)] - SHEEN_ALBEDO_0[_S436]) * _S427;
            var _S438 : SheenProfile = SheenProfile_x24init_0(true, exp(_S435 + (_S437 - _S435) * _S428));
            profile_0 = _S438;
        }
    }
    else
    {
        profile_0 = _S415;
    }
    return profile_0;
}

fn coatSeries( coat_frame_1 : CoatFrame,  material_12 : Material) -> vec3<f32>
{
    var _S439 : vec3<f32> = vec3<f32>(0.0f);
    var _S440 : bool = (coat_frame_1.ior) > 0.0f;
    var series_0 : vec3<f32>;
    if(_S440)
    {
        var _S441 : f32 = coat_frame_1.ior * coat_frame_1.ior;
        var _S442 : f32 = _S441 * _S441;
        var _S443 : f32 = coat_frame_1.ior - 1.0f;
        var _S444 : f32 = coat_frame_1.ior + 1.0f;
        var _S445 : f32 = _S441 - 1.0f;
        var _S446 : f32 = _S441 + 1.0f;
        var _S447 : f32 = _S442 - 1.0f;
        var _S448 : f32 = _S446 * _S447;
        var _S449 : f32 = 0.5f + _S443 * (3.0f * coat_frame_1.ior + 1.0f) / (6.0f * _S444 * _S444) + _S441 * _S445 * _S445 / (_S446 * _S446 * _S446) * log(_S443 / _S444) - 2.0f * _S441 * coat_frame_1.ior * (_S441 + 2.0f * coat_frame_1.ior - 1.0f) / _S448 + 8.0f * _S442 * (_S442 + 1.0f) / (_S448 * _S447) * log(coat_frame_1.ior);
        var _S450 : f32 = 1.0f - (1.0f - _S449) / _S441;
        var _S451 : vec3<f32> = material_12.coat_tint;
        var _S452 : vec3<f32> = _S451 * _S451 * vec3<f32>((1.0f - _S450)) / (vec3<f32>(1.0f) - material_12.albedo * vec3<f32>(_S450));
        series_0 = _S452;
    }
    else
    {
        series_0 = _S439;
    }
    return series_0;
}

fn reflectedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S453 : vec3<f32> = ((-(in_dir_1)));
    var _S454 : vec3<f32> = (normalize((_S453 + out_dir_0)));
    return _S454;
}

struct Weights
{
     v_dot_h : f32,
     refracted : vec3<f32>,
     F : vec3<f32>,
     reflect_weight : f32,
     diffuse_weight : vec3<f32>,
     refract_weight : vec3<f32>,
     p_diffuse : f32,
     p_reflect : f32,
     p_refract : f32,
     p_sheen_velvet : f32,
     p_toon : f32,
     sheen : vec3<f32>,
     toon : vec3<f32>,
     coat : vec3<f32>,
     p_coat : f32,
};

fn smithG1( alpha_3 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S455 : f32 = alpha_3 * alpha_3;
    var _S456 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S455 + (1.0f - _S455) * n_dot_x_0 * n_dot_x_0));
    var _S457 : bool = alpha_3 > 0.0f;
    var _S458 : f32 = select(1.0f, _S456, _S457);
    return _S458;
}

fn coatFresnel( in_dir_2 : vec3<f32>,  v_5 : vec3<f32>,  coat_h_1 : vec3<f32>,  coat_frame_2 : CoatFrame,  eta_i_2 : f32,  behind_0 : bool) -> f32
{
    var _S459 : f32 = dot(coat_frame_2.normal, reflect(in_dir_2, coat_h_1));
    var _S460 : f32 = abs(dot(v_5, coat_h_1));
    var _S461 : f32 = eta_i_2 / coat_frame_2.ior * sqrt(max(1.0f - _S460 * _S460, 0.0f));
    var _S462 : f32 = sqrt(max(1.0f - _S461 * _S461, 0.0f));
    var _S463 : f32 = select(_S460, _S462, behind_0);
    var _S464 : f32 = select(1.0f, coat_frame_2.ior, behind_0);
    var _S465 : f32 = select(coat_frame_2.ior, 1.0f, behind_0);
    var _S466 : f32 = fresnel(_S463, _S464, _S465);
    var _S467 : f32 = smithG1(coat_frame_2.alpha, _S459);
    var _S468 : f32 = _S466 * _S467;
    var _S469 : bool = _S459 > 0.0f;
    var _S470 : f32 = select(0.0f, _S468, _S469);
    return _S470;
}

fn Weights_x24init_0( v_dot_h_0 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  p_sheen_velvet_0 : f32,  p_toon_0 : f32,  sheen_1 : vec3<f32>,  toon_0 : vec3<f32>,  coat_1 : vec3<f32>,  p_coat_0 : f32) -> Weights
{
    var _S471 : Weights;
    _S471.v_dot_h = v_dot_h_0;
    _S471.refracted = refracted_0;
    _S471.F = F_0;
    _S471.reflect_weight = reflect_weight_0;
    _S471.diffuse_weight = diffuse_weight_0;
    _S471.refract_weight = refract_weight_0;
    _S471.p_diffuse = p_diffuse_0;
    _S471.p_reflect = p_reflect_0;
    _S471.p_refract = p_refract_0;
    _S471.p_sheen_velvet = p_sheen_velvet_0;
    _S471.p_toon = p_toon_0;
    _S471.sheen = sheen_1;
    _S471.toon = toon_0;
    _S471.coat = coat_1;
    _S471.p_coat = p_coat_0;
    return _S471;
}

fn lobeWeights( in_dir_3 : vec3<f32>,  v_6 : vec3<f32>,  n_i_3 : vec3<f32>,  h_1 : vec3<f32>,  coat_h_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  coat_n_0 : vec3<f32>,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile,  coat_frame_3 : CoatFrame,  coat_series_0 : vec3<f32>,  material_13 : Material,  eta_i_3 : f32,  eta_o_2 : f32) -> Weights
{
    var _S472 : f32 = min(sqrt(material_13.specular_level) * abs(eta_i_3 - eta_o_2) / (eta_i_3 + eta_o_2), 0.9999847412109375f);
    var _S473 : f32 = _S472 * _S472;
    var _S474 : f32 = (1.0f + _S472) / (1.0f - _S472);
    var _S475 : vec3<f32> = vec3<f32>(1.0f);
    var _S476 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S477 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S478 : vec3<f32> = vec3<f32>(1.0f) - material_13.sheen * vec3<f32>(_S477);
        var _S479 : f32 = rgb_to_greyscale(material_13.sheen);
        var _S480 : f32 = _S479 * _S477;
        var _S481 : vec3<f32> = material_13.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S478;
        sheen_component_0 = _S480;
        sheen_2 = _S481;
    }
    else
    {
        scale_0 = _S475;
        sheen_component_0 = 0.0f;
        sheen_2 = _S476;
    }
    var _S482 : bool = (material_13.metallic) > 0.0f;
    var rebounce_0 : vec3<f32>;
    if(_S482)
    {
        var _S483 : f32 = frame_2.alphas.x;
        var _S484 : f32 = sqrt(min(_S483, frame_2.alphas.y));
        var _S485 : bool = _S483 > 0.0f;
        var _S486 : f32 = select(material_13.roughness, _S484, _S485);
        var _S487 : f32 = _S486 * _S486;
        var _S488 : f32 = pow(_S487, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S487) / (1.0f + 1.28094995021820068f * _S487);
        var _S489 : bool = _S487 > 0.0f;
        var _S490 : f32 = select(0.0f, _S488, _S489);
        var _S491 : f32 = clamp(dot(n_i_3, v_6), 0.0f, 1.0f);
        var _S492 : f32 = _S487 * _S486;
        var _S493 : f32 = min(1.00064504146575928f - _S486 * (0.00375499995425344f + _S491 * (-0.04133399948477745f + _S491 * (-0.90938502550125122f + _S491 * 0.35275399684906006f))) - _S487 * (0.27602800726890564f + _S491 * (1.27023398876190186f + _S491 * 0.04740000143647194f)) - _S492 * (0.31452900171279907f - _S491 * 0.34830701351165771f) + _S492 * _S486 * 0.27229699492454529f, 1.0f);
        var _S494 : vec3<f32> = vec3<f32>(1.0f);
        var _S495 : vec3<f32> = min(_S494 / (_S494 - material_13.albedo * vec3<f32>(_S490)), vec3<f32>((1.0f / max(_S493, 0.0000152587890625f))));
        rebounce_0 = _S495;
    }
    else
    {
        rebounce_0 = _S475;
    }
    var _S496 : f32 = dot(h_1, v_6);
    var _S497 : f32 = eta_i_3 / eta_o_2;
    var _S498 : vec3<f32> = (normalize((refract(in_dir_3, h_1, _S497))));
    var _S499 : f32 = abs(_S496);
    var _S500 : bool = eta_i_3 > eta_o_2;
    var _S501 : f32 = select(1.0f, _S474, _S500);
    var _S502 : f32 = select(_S474, 1.0f, _S500);
    var _S503 : f32 = fresnel(_S499, _S501, _S502);
    var _S504 : f32 = eta_i_3 * eta_i_3;
    var _S505 : f32 = eta_o_2 * eta_o_2;
    var _S506 : bool = (_S504 * (1.0f - _S496 * _S496)) >= _S505;
    var _S507 : vec3<f32> = material_13.specular_tint * vec3<f32>(_S473);
    var _S508 : vec3<f32> = vec3<f32>(1.0f);
    var _S509 : vec3<f32> = _S508 - _S507;
    var _S510 : vec3<f32> = vec3<f32>((1.0f - _S473));
    var _S511 : vec3<f32> = _S507 + _S509 * vec3<f32>((_S503 - _S473)) / _S510;
    var _S512 : vec3<f32> = select(_S511, _S475, _S506);
    var _S513 : bool = (dot(coat_h_2, coat_h_2)) > 0.0f;
    var coat_2 : vec3<f32>;
    var up_0 : vec3<f32>;
    var through_0 : vec3<f32>;
    if(_S513)
    {
        var _S514 : f32 = coatFresnel(in_dir_3, v_6, coat_h_2, coat_frame_3, eta_i_3, _S500);
        var _S515 : f32 = material_13.coat * _S514;
        var _S516 : vec3<f32> = material_13.coat_tint;
        var _S517 : vec3<f32> = _S516 * _S516;
        var _S518 : vec3<f32> = select(_S475, _S517, _S500);
        var _S519 : vec3<f32> = vec3<f32>(_S515) * _S518;
        var _S520 : f32 = 1.0f - _S514;
        var _S521 : bool = !_S500;
        var _S522 : vec3<f32> = select(_S475, coat_series_0, _S521);
        var _S523 : vec3<f32> = vec3<f32>(_S520);
        var _S524 : vec3<f32> = (mix((_S475), (_S523 * _S522), (material_13.coat)));
        var _S525 : vec3<f32> = (mix((_S475), (_S523 * material_13.coat_tint), (material_13.coat)));
        coat_2 = _S519;
        up_0 = _S524;
        through_0 = _S525;
    }
    else
    {
        coat_2 = _S476;
        up_0 = _S475;
        through_0 = _S475;
    }
    var _S526 : vec3<f32> = scale_0 * coat_2;
    var _S527 : f32 = rgb_to_greyscale(_S526);
    var _S528 : vec3<f32> = material_13.albedo * rebounce_0;
    var _S529 : vec3<f32> = (mix((_S512), (_S528), (material_13.metallic)));
    var F_1 : vec3<f32> = _S529 * scale_0 * up_0;
    var _S530 : f32 = rgb_to_greyscale(F_1);
    var _S531 : f32 = 1.0f - material_13.metallic;
    var _S532 : vec3<f32> = _S508 - _S512;
    var _S533 : vec3<f32> = vec3<f32>(((1.0f - material_13.transmission) * _S531));
    var _S534 : vec3<f32> = _S533 * _S532 * scale_0 * up_0;
    var _S535 : vec3<f32> = vec3<f32>((material_13.transmission * _S531));
    var _S536 : vec3<f32> = _S535 * _S532 * scale_0 * through_0;
    var _S537 : f32 = max(_S530, 0.0f);
    var _S538 : f32 = rgb_to_greyscale(_S534);
    var _S539 : f32 = max(_S538, 0.0f);
    var _S540 : f32 = rgb_to_greyscale(_S536);
    var _S541 : f32 = (sign((length(_S498))));
    var _S542 : f32 = max(_S540 * _S541, 0.0f);
    var _S543 : f32 = _S537 + _S539 + _S542 + _S527;
    var _S544 : f32 = min(sheen_component_0, 1.0f);
    var _S545 : bool = sheen_component_0 > 0.0f;
    var _S546 : bool;
    if(_S545)
    {
        _S546 = !(_S543 > 0.0f);
    }
    else
    {
        _S546 = false;
    }
    var _S547 : f32 = select(_S544, 1.0f, _S546);
    var _S548 : f32 = (1.0f - _S547) / max(_S543, 0.0000152587890625f);
    var _S549 : f32 = _S539 * _S548;
    var _S550 : f32 = _S537 * _S548;
    var _S551 : f32 = _S542 * _S548;
    var _S552 : Weights = Weights_x24init_0(_S496, _S498, F_1, 1.0f, _S534, _S536, _S549, _S550, _S551, _S547, 0.0f * _S548, sheen_2, _S476, _S526, _S527 * _S548);
    var _S553 : bool = (any((ggx_n_0 != h_1)));
    var leaving_0 : Weights;
    if(_S553)
    {
        var _S554 : f32 = dot(ggx_n_0, v_6);
        var _S555 : f32 = eta_i_3 / eta_o_2;
        var _S556 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S555))));
        var _S557 : f32 = abs(_S554);
        var _S558 : f32 = select(1.0f, _S474, _S500);
        var _S559 : f32 = select(_S474, 1.0f, _S500);
        var _S560 : f32 = fresnel(_S557, _S558, _S559);
        var _S561 : bool = (_S504 * (1.0f - _S554 * _S554)) >= _S505;
        var _S562 : vec3<f32> = _S507 + _S509 * vec3<f32>((_S560 - _S473)) / _S510;
        var _S563 : vec3<f32> = select(_S562, _S475, _S561);
        if(_S513)
        {
            var _S564 : f32 = coatFresnel(in_dir_3, v_6, coat_h_2, coat_frame_3, eta_i_3, _S500);
            var _S565 : f32 = material_13.coat * _S564;
            var _S566 : vec3<f32> = material_13.coat_tint;
            var _S567 : vec3<f32> = _S566 * _S566;
            var _S568 : vec3<f32> = select(_S475, _S567, _S500);
            var _S569 : vec3<f32> = vec3<f32>(_S565) * _S568;
            var _S570 : f32 = 1.0f - _S564;
            var _S571 : bool = !_S500;
            var _S572 : vec3<f32> = select(_S475, coat_series_0, _S571);
            var _S573 : vec3<f32> = vec3<f32>(_S570);
            var _S574 : vec3<f32> = (mix((_S475), (_S573 * _S572), (material_13.coat)));
            var _S575 : vec3<f32> = (mix((_S475), (_S573 * material_13.coat_tint), (material_13.coat)));
            coat_2 = _S569;
            up_0 = _S574;
            through_0 = _S575;
        }
        else
        {
            coat_2 = _S476;
            up_0 = _S475;
            through_0 = _S475;
        }
        var _S576 : vec3<f32> = scale_0 * coat_2;
        var _S577 : f32 = rgb_to_greyscale(_S576);
        var _S578 : vec3<f32> = (mix((_S563), (_S528), (material_13.metallic)));
        var F_2 : vec3<f32> = _S578 * scale_0 * up_0;
        var _S579 : f32 = rgb_to_greyscale(F_2);
        var _S580 : vec3<f32> = _S508 - _S563;
        var _S581 : vec3<f32> = _S533 * _S580 * scale_0 * up_0;
        var _S582 : vec3<f32> = _S535 * _S580 * scale_0 * through_0;
        var _S583 : f32 = max(_S579, 0.0f);
        var _S584 : f32 = rgb_to_greyscale(_S581);
        var _S585 : f32 = max(_S584, 0.0f);
        var _S586 : f32 = rgb_to_greyscale(_S582);
        var _S587 : f32 = (sign((length(_S556))));
        var _S588 : f32 = max(_S586 * _S587, 0.0f);
        var _S589 : f32 = _S583 + _S585 + _S588 + _S577;
        if(_S545)
        {
            _S546 = !(_S589 > 0.0f);
        }
        else
        {
            _S546 = false;
        }
        var _S590 : f32 = select(_S544, 1.0f, _S546);
        var _S591 : f32 = (1.0f - _S590) / max(_S589, 0.0000152587890625f);
        var _S592 : f32 = _S585 * _S591;
        var _S593 : f32 = _S583 * _S591;
        var _S594 : f32 = _S588 * _S591;
        var _S595 : Weights = Weights_x24init_0(_S554, _S556, F_2, 1.0f, _S581, _S582, _S592, _S593, _S594, _S590, 0.0f * _S591, sheen_2, _S476, _S576, _S577 * _S591);
        leaving_0 = _S595;
    }
    else
    {
        leaving_0 = _S552;
    }
    var _S596 : bool = (any((coat_n_0 != coat_h_2)));
    var coated_0 : Weights;
    if(_S596)
    {
        var _S597 : f32 = eta_i_3 / eta_o_2;
        var _S598 : vec3<f32> = (normalize((refract(in_dir_3, h_1, _S597))));
        var _S599 : f32 = select(1.0f, _S474, _S500);
        var _S600 : f32 = select(_S474, 1.0f, _S500);
        var _S601 : f32 = fresnel(_S499, _S599, _S600);
        var _S602 : vec3<f32> = _S507 + _S509 * vec3<f32>((_S601 - _S473)) / _S510;
        var _S603 : vec3<f32> = select(_S602, _S475, _S506);
        var _S604 : bool = (dot(coat_n_0, coat_n_0)) > 0.0f;
        if(_S604)
        {
            var _S605 : f32 = coatFresnel(in_dir_3, v_6, coat_n_0, coat_frame_3, eta_i_3, _S500);
            var _S606 : f32 = material_13.coat * _S605;
            var _S607 : vec3<f32> = material_13.coat_tint;
            var _S608 : vec3<f32> = _S607 * _S607;
            var _S609 : vec3<f32> = select(_S475, _S608, _S500);
            var _S610 : vec3<f32> = vec3<f32>(_S606) * _S609;
            var _S611 : f32 = 1.0f - _S605;
            var _S612 : bool = !_S500;
            var _S613 : vec3<f32> = select(_S475, coat_series_0, _S612);
            var _S614 : vec3<f32> = vec3<f32>(_S611);
            var _S615 : vec3<f32> = (mix((_S475), (_S614 * _S613), (material_13.coat)));
            var _S616 : vec3<f32> = (mix((_S475), (_S614 * material_13.coat_tint), (material_13.coat)));
            coat_2 = _S610;
            up_0 = _S615;
            through_0 = _S616;
        }
        else
        {
            coat_2 = _S476;
            up_0 = _S475;
            through_0 = _S475;
        }
        var _S617 : vec3<f32> = scale_0 * coat_2;
        var _S618 : f32 = rgb_to_greyscale(_S617);
        var _S619 : vec3<f32> = (mix((_S603), (_S528), (material_13.metallic)));
        var F_3 : vec3<f32> = _S619 * scale_0 * up_0;
        var _S620 : f32 = rgb_to_greyscale(F_3);
        var _S621 : vec3<f32> = _S508 - _S603;
        var _S622 : vec3<f32> = _S533 * _S621 * scale_0 * up_0;
        var _S623 : vec3<f32> = _S535 * _S621 * scale_0 * through_0;
        var _S624 : f32 = max(_S620, 0.0f);
        var _S625 : f32 = rgb_to_greyscale(_S622);
        var _S626 : f32 = max(_S625, 0.0f);
        var _S627 : f32 = rgb_to_greyscale(_S623);
        var _S628 : f32 = (sign((length(_S598))));
        var _S629 : f32 = max(_S627 * _S628, 0.0f);
        var _S630 : f32 = _S624 + _S626 + _S629 + _S618;
        if(_S545)
        {
            _S546 = !(_S630 > 0.0f);
        }
        else
        {
            _S546 = false;
        }
        var _S631 : f32 = select(_S544, 1.0f, _S546);
        var _S632 : f32 = (1.0f - _S631) / max(_S630, 0.0000152587890625f);
        var _S633 : f32 = _S626 * _S632;
        var _S634 : f32 = _S624 * _S632;
        var _S635 : f32 = _S629 * _S632;
        var _S636 : Weights = Weights_x24init_0(_S496, _S598, F_3, 1.0f, _S622, _S623, _S633, _S634, _S635, _S631, 0.0f * _S632, sheen_2, _S476, _S617, _S618 * _S632);
        coated_0 = _S636;
    }
    else
    {
        coated_0 = _S552;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S552.diffuse_weight, leaving_0.refract_weight, _S552.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S552.p_sheen_velvet, _S552.p_toon, sheen_2, _S476, coated_0.coat, coated_0.p_coat);
}

fn translucentShare( material_14 : Material) -> f32
{
    var _S637 : f32 = rgb_to_greyscale(material_14.translucent);
    var _S638 : f32 = rgb_to_greyscale(material_14.albedo);
    var _S639 : f32 = _S637 / (_S638 + _S637);
    var _S640 : bool = _S637 > 0.0f;
    var _S641 : f32 = select(0.0f, _S639, _S640);
    return _S641;
}

fn diffusePDF( n_i_dot_l_0 : f32,  n_i_dot_v_0 : f32,  material_15 : Material,  w_2 : Weights) -> f32
{
    var _S642 : f32 = translucentShare(material_15);
    var _S643 : f32 = w_2.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S644 : f32 = w_2.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S645 : f32 = 1.0f - _S642;
    var _S646 : bool = n_i_dot_l_0 < 0.0f;
    var _S647 : f32 = select(_S645, _S642, _S646);
    var _S648 : f32 = _S644 * _S647;
    var _S649 : bool = _S642 > 0.0f;
    var _S650 : f32 = select(_S643, _S648, _S649);
    var _S651 : bool = n_i_dot_v_0 > 0.0f;
    var _S652 : f32 = select(0.0f, _S650, _S651);
    return _S652;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  material_16 : Material,  w_3 : Weights) -> vec3<f32>
{
    var _S653 : f32 = translucentShare(material_16);
    var _S654 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S655 : vec3<f32> = select(material_16.albedo, material_16.translucent, _S654);
    var _S656 : f32 = 1.0f - _S653;
    var _S657 : f32 = select(_S656, _S653, _S654);
    var _S658 : vec3<f32> = _S655 / vec3<f32>(_S657);
    var _S659 : bool = _S653 > 0.0f;
    var _S660 : vec3<f32> = select(material_16.albedo, _S658, _S659);
    return w_3.diffuse_weight * _S660 / vec3<f32>(w_3.p_diffuse);
}

fn trowbridgeReitz( alpha_4 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S661 : f32 = alpha_4 * alpha_4;
    var _S662 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S661 * n_dot_h_0 * n_dot_h_0;
    return _S661 / max(3.14159274101257324f * _S662 * _S662, 1.17549435082228751e-38f);
}

fn anisotropicG1( w_4 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S663 : f32 = max(w_4.z, 0.0f);
    return 2.0f * _S663 / (_S663 + length(vec3<f32>(alphas_1.x * w_4.x, alphas_1.y * w_4.y, _S663)));
}

fn anisotropicD( h_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S664 : f32 = alphas_2.x;
    var _S665 : f32 = h_2.x / _S664;
    var _S666 : f32 = alphas_2.y;
    var _S667 : f32 = h_2.y / _S666;
    var _S668 : f32 = h_2.z;
    var _S669 : f32 = _S665 * _S665 + _S667 * _S667 + _S668 * _S668;
    return 1.0f / max(3.14159274101257324f * _S664 * _S666 * _S669 * _S669, 1.17549435082228751e-38f);
}

fn vndfPDF( v_7 : vec3<f32>,  h_3 : vec3<f32>,  n_i_5 : vec3<f32>,  n_i_dot_v_1 : f32,  alpha_5 : f32,  frame_3 : AnisotropicFrame,  v_dot_h_1 : f32) -> f32
{
    var _S670 : f32 = dot(n_i_5, h_3);
    var _S671 : f32 = smithG1(alpha_5, n_i_dot_v_1);
    var _S672 : f32 = _S671 * v_dot_h_1;
    var _S673 : f32 = trowbridgeReitz(alpha_5, _S670);
    var _S674 : f32 = _S672 * _S673 / n_i_dot_v_1;
    var _S675 : bool = alpha_5 > 0.0f;
    var _S676 : bool;
    if(_S675)
    {
        _S676 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S676 = false;
    }
    if(_S676)
    {
        _S676 = _S670 > 0.0f;
    }
    else
    {
        _S676 = false;
    }
    if(_S676)
    {
        _S676 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S676 = false;
    }
    var _S677 : f32 = select(0.0f, _S674, _S676);
    var _S678 : bool = (frame_3.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S678)
    {
        var _S679 : vec3<f32> = anisotropicLocal(v_7, frame_3.tangent, n_i_5);
        var _S680 : f32 = anisotropicG1(_S679, frame_3.alphas);
        var _S681 : vec3<f32> = anisotropicLocal(h_3, frame_3.tangent, n_i_5);
        var _S682 : f32 = anisotropicD(_S681, frame_3.alphas);
        var _S683 : f32 = _S680 * _S682;
        var _S684 : f32 = _S683 * v_dot_h_1 / n_i_dot_v_1;
        var _S685 : bool = v_dot_h_1 > 0.0f;
        if(_S685)
        {
            _S676 = _S670 > 0.0f;
        }
        else
        {
            _S676 = false;
        }
        if(_S676)
        {
            _S676 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S676 = false;
        }
        var _S686 : f32 = select(0.0f, _S684, _S676);
        pdf_h_0 = _S686;
    }
    else
    {
        pdf_h_0 = _S677;
    }
    return pdf_h_0;
}

fn refractPDF( l_dot_h_0 : f32,  pdf_h_1 : f32,  w_5 : Weights,  eta_i_4 : f32,  eta_o_3 : f32) -> f32
{
    var _S687 : f32 = eta_i_4 * w_5.v_dot_h + eta_o_3 * l_dot_h_0;
    var _S688 : f32 = w_5.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * abs(l_dot_h_0) / (_S687 * _S687);
    var _S689 : bool = eta_i_4 != eta_o_3;
    var _S690 : bool;
    if(_S689)
    {
        _S690 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S690 = false;
    }
    var _S691 : f32 = select(0.0f, _S688, _S690);
    return _S691;
}

fn maskingG1( l_1 : vec3<f32>,  n_i_6 : vec3<f32>,  side_0 : f32,  alpha_6 : f32,  frame_4 : AnisotropicFrame) -> f32
{
    var _S692 : f32 = smithG1(alpha_6, max(side_0 * dot(n_i_6, l_1), 0.0f));
    var _S693 : bool = (frame_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S693)
    {
        var _S694 : vec3<f32> = anisotropicLocal(l_1, frame_4.tangent, n_i_6 * vec3<f32>(side_0));
        var _S695 : f32 = anisotropicG1(_S694, frame_4.alphas);
        G1_l_0 = _S695;
    }
    else
    {
        G1_l_0 = _S692;
    }
    return G1_l_0;
}

fn refractBSDF( G1_l_1 : f32,  material_17 : Material,  w_6 : Weights) -> vec3<f32>
{
    var _S696 : bool = (material_17.ior) == 1.0f;
    var _S697 : f32 = select(G1_l_1, 1.0f, _S696);
    return w_6.refract_weight * vec3<f32>(_S697) * material_17.albedo / vec3<f32>(w_6.p_refract);
}

fn reflectPDF( pdf_h_2 : f32,  w_7 : Weights) -> f32
{
    var _S698 : f32 = w_7.p_reflect * pdf_h_2 / (4.0f * w_7.v_dot_h);
    var _S699 : bool = pdf_h_2 > 0.0f;
    var _S700 : f32 = select(0.0f, _S698, _S699);
    return _S700;
}

fn reflectBSDF( G1_l_2 : f32,  w_8 : Weights) -> vec3<f32>
{
    return vec3<f32>((w_8.reflect_weight * G1_l_2)) * w_8.F / vec3<f32>(w_8.p_reflect);
}

fn sheenVelvetPDF( n_i_dot_l_1 : f32,  n_i_dot_v_2 : f32,  w_9 : Weights) -> f32
{
    var _S701 : f32 = w_9.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S702 : bool = n_i_dot_l_1 > 0.0f;
    var _S703 : bool;
    if(_S702)
    {
        _S703 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S703 = false;
    }
    var _S704 : f32 = select(0.0f, _S701, _S703);
    return _S704;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  v_8 : vec3<f32>,  n_i_7 : vec3<f32>,  material_18 : Material,  w_10 : Weights) -> vec3<f32>
{
    var _S705 : vec3<f32> = (normalize((l_2 + v_8)));
    var _S706 : f32 = dot(n_i_7, _S705);
    var _S707 : f32 = max(dot(n_i_7, l_2), 0.0f);
    var _S708 : f32 = max(dot(n_i_7, v_8), 0.0f);
    var _S709 : f32 = 1.0f / max(material_18.sheen_roughness, 0.05000000074505806f);
    var _S710 : f32 = 1.0f - _S706 * _S706;
    var _S711 : f32 = (2.0f + _S709) * pow(max(_S710, 0.0f), 0.5f * _S709) * 0.5f * 0.31830987334251404f / max(4.0f * (_S707 + _S708 - _S707 * _S708), 0.0000152587890625f);
    var _S712 : bool = (material_18.velvet) > 0.0f;
    var f_3 : f32;
    if(_S712)
    {
        var _S713 : f32 = max(material_18.sheen_roughness, 0.00999999977648258f);
        var _S714 : f32 = _S713 * _S713;
        var _S715 : f32 = max(_S710, 0.0000152587890625f);
        var _S716 : f32 = exp(- _S706 * _S706 / (_S715 * _S714)) / (3.14159274101257324f * _S714 * _S715 * _S715) * min(1.0f, 2.0f * _S706 * min(_S707, _S708) / max(abs(dot(_S705, v_8)), 0.0000152587890625f)) / max(4.0f * _S707 * _S708, 0.0000152587890625f);
        f_3 = _S716;
    }
    else
    {
        f_3 = _S711;
    }
    return w_10.sheen * vec3<f32>((f_3 * _S707 * 2.0f * 3.14159274101257324f / w_10.p_sheen_velvet));
}

fn coatPDF( v_9 : vec3<f32>,  coat_h_3 : vec3<f32>,  coat_frame_4 : CoatFrame,  w_11 : Weights) -> f32
{
    var _S717 : f32 = dot(coat_frame_4.normal, v_9);
    var _S718 : f32 = smithG1(coat_frame_4.alpha, _S717);
    var _S719 : f32 = trowbridgeReitz(coat_frame_4.alpha, dot(coat_frame_4.normal, coat_h_3));
    var _S720 : f32 = _S718 * _S719 / (4.0f * _S717);
    var _S721 : bool = (coat_frame_4.alpha) > 0.0f;
    var _S722 : f32 = select(0.0f, _S720, _S721);
    return w_11.p_coat * _S722;
}

fn coatBSDF( w_12 : Weights) -> vec3<f32>
{
    return w_12.coat / vec3<f32>(w_12.p_coat);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_7 : vec3<f32>,  material_19 : Material,  eta_i_5 : f32,  eta_o_4 : f32,  refracted_1 : bool,  facets_0 : Facets,  throughputs_0 : ptr<function, array<vec3<f32>, i32(6)>>,  pdfs_0 : ptr<function, array<f32, i32(6)>>)
{
    var _S723 : vec3<f32> = ((-(in_dir_4)));
    var _S724 : f32 = dot(n_7, _S723);
    var _S725 : f32 = (sign((_S724)));
    var _S726 : vec3<f32> = n_7 * vec3<f32>(_S725);
    var _S727 : f32 = dot(_S726, out_dir_1);
    var _S728 : f32 = material_19.roughness;
    var _S729 : f32 = _S728 * _S728;
    var _S730 : AnisotropicFrame = anisotropicFrame(material_19, _S726);
    var _S731 : SheenProfile = sheenProfile(_S723, _S726, material_19);
    var _S732 : CoatFrame = coatFrame(material_19, _S726);
    var _S733 : vec3<f32> = coatSeries(_S732, material_19);
    var _S734 : f32 = rgb_to_greyscale(material_19.translucent);
    var _S735 : bool = _S734 > 0.0f;
    var _S736 : bool = (dot(n_7, out_dir_1) * _S724) < 0.0f;
    var _S737 : vec3<f32> = facets_0.coat_h;
    var _S738 : bool = (dot(_S737, _S737)) > 0.0f;
    var _S739 : bool;
    if(_S735)
    {
        _S739 = _S736;
    }
    else
    {
        _S739 = false;
    }
    var _S740 : bool = _S739 == refracted_1;
    var _S741 : bool = !refracted_1;
    if(_S741)
    {
        _S739 = _S738;
    }
    else
    {
        _S739 = false;
    }
    var _S742 : vec3<f32> = ((-(vec3<f32>(eta_i_5) * _S723 + vec3<f32>(eta_o_4) * out_dir_1)));
    var _S743 : vec3<f32> = (normalize((_S742)));
    var _S744 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_1);
    var _S745 : f32 = (sign((dot(_S743, _S726))));
    var _S746 : vec3<f32> = _S743 * vec3<f32>(_S745);
    var _S747 : vec3<f32> = select(_S744, _S746, refracted_1);
    var _S748 : vec3<f32> = vec3<f32>(0.0f);
    var _S749 : vec3<f32> = select(_S748, _S744, _S739);
    var _S750 : Weights = lobeWeights(in_dir_4, _S723, _S726, facets_0.h, facets_0.coat_h, _S747, _S749, _S730, _S731, _S732, _S733, material_19, eta_i_5, eta_o_4);
    var _S751 : f32 = abs(_S724);
    var _S752 : f32 = diffusePDF(_S727, _S751, material_19, _S750);
    var _S753 : f32 = select(0.0f, _S752, _S740);
    (*pdfs_0)[i32(0)] = _S753;
    var _S754 : vec3<f32> = diffuseBSDF(out_dir_1, _S726, material_19, _S750);
    var _S755 : vec3<f32> = select(_S748, _S754, _S740);
    (*throughputs_0)[i32(0)] = _S755;
    var _S756 : f32 = vndfPDF(_S723, _S747, _S726, _S751, _S729, _S730, _S750.v_dot_h);
    var _S757 : f32 = refractPDF(dot(out_dir_1, _S747), _S756, _S750, eta_i_5, eta_o_4);
    var _S758 : f32 = select(0.0f, _S757, refracted_1);
    (*pdfs_0)[i32(1)] = _S758;
    var _S759 : f32 = maskingG1(out_dir_1, _S726, -1.0f, _S729, _S730);
    var _S760 : vec3<f32> = refractBSDF(_S759, material_19, _S750);
    var _S761 : vec3<f32> = select(_S748, _S760, refracted_1);
    (*throughputs_0)[i32(1)] = _S761;
    var _S762 : f32 = reflectPDF(_S756, _S750);
    var _S763 : f32 = select(0.0f, _S762, _S741);
    (*pdfs_0)[i32(2)] = _S763;
    var _S764 : f32 = maskingG1(out_dir_1, _S726, 1.0f, _S729, _S730);
    var _S765 : vec3<f32> = reflectBSDF(_S764, _S750);
    var _S766 : vec3<f32> = select(_S748, _S765, _S741);
    (*throughputs_0)[i32(2)] = _S766;
    var _S767 : f32 = sheenVelvetPDF(_S727, _S751, _S750);
    var _S768 : f32 = select(0.0f, _S767, _S741);
    (*pdfs_0)[i32(3)] = _S768;
    var _S769 : vec3<f32> = sheenVelvetBSDF(out_dir_1, _S723, _S726, material_19, _S750);
    var _S770 : vec3<f32> = select(_S748, _S769, _S741);
    (*throughputs_0)[i32(3)] = _S770;
    (*pdfs_0)[i32(4)] = 0.0f;
    (*throughputs_0)[i32(4)] = _S748;
    var _S771 : f32 = coatPDF(_S723, _S749, _S732, _S750);
    var _S772 : f32 = select(0.0f, _S771, _S739);
    (*pdfs_0)[i32(5)] = _S772;
    var _S773 : vec3<f32> = coatBSDF(_S750);
    var _S774 : vec3<f32> = select(_S748, _S773, _S739);
    (*throughputs_0)[i32(5)] = _S774;
    return;
}

fn lightBSDF_0( in_dir_5 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_2 : vec3<f32>,  material_20 : Material,  eta_i_6 : f32,  eta_o_5 : f32,  competing_0 : bool,  facets_1 : Facets) -> vec3<f32>
{
    var _S775 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(6)>;
    var pdfs_1 : array<f32, i32(6)>;
    BSDF(in_dir_5, light_0.dir, smooth_n_5, material_20, eta_i_6, eta_o_5, _S775, facets_1, &(throughputs_1), &(pdfs_1));
    var _S776 : bool;
    if(competing_0)
    {
        _S776 = (light_0.density) != 0.0f;
    }
    else
    {
        _S776 = false;
    }
    var _S777 : vec3<f32> = vec3<f32>(0.0f);
    var i_0 : u32 = u32(0);
    var f_4 : vec3<f32> = _S777;
    loop
    {
        if(i_0 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S778 : bool = (pdfs_1[i_0]) > 0.0f;
        if(_S778)
        {
            var f_5 : vec3<f32>;
            if(_S776)
            {
                var _S779 : f32 = pdfs_1[i_0] / light_0.density;
                var f_6 : vec3<f32> = f_4 + throughputs_1[i_0] * vec3<f32>(pdfs_1[i_0]) / vec3<f32>((light_0.density * (1.0f + _S779 * _S779)));
                f_5 = f_6;
            }
            else
            {
                var f_7 : vec3<f32> = f_4 + throughputs_1[i_0] * vec3<f32>(pdfs_1[i_0]);
                f_5 = f_7;
            }
            f_4 = f_5;
        }
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S780 : vec3<f32> = f_4 * light_0.radiance;
    var _S781 : vec3<f32> = _S780 * vec3<f32>(light_0.density);
    var _S782 : vec3<f32> = select(_S780, _S781, _S776);
    return _S782;
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S783 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S784 : vec2<u32> = _S783 - vec2<u32>(u32(1), u32(0));
    var _S785 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S786 : vec2<u32> = min(vec2<u32>(_S785 * vec2<f32>(_S784)), _S784 - vec2<u32>(u32(1)));
    var _S787 : vec4<f32> = (textureLoad(environment_cdf, (_S786), 0));
    var _S788 : f32 = _S787.y;
    var _S789 : u32 = _S784.x;
    var _S790 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S789, _S786.y)), 0));
    var _S791 : f32 = _S788 * _S790.y;
    return _S791 * f32(_S789 * _S784.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  material_21 : Material,  eta_0 : vec2<f32>,  is_inside_1 : bool,  facets_2 : Facets,  pdf_2 : f32,  terms_0 : ptr<function, array<vec3<f32>, i32(6)>>,  pdfs_2 : ptr<function, array<f32, i32(6)>>) -> vec3<f32>
{
    var _S792 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    BSDF(in_dir_6, dir_5, surface_1.smooth_n, material_21, eta_0.x, eta_0.y, _S792, facets_2, &((*terms_0)), &((*pdfs_2)));
    var _S793 : vec3<f32> = vec3<f32>(0.0f);
    var i_2 : u32 = u32(0);
    var f_8 : vec3<f32> = _S793;
    loop
    {
        if(i_2 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S794 : bool = ((*pdfs_2)[i_2]) > 0.0f;
        if(_S794)
        {
            var _S795 : vec3<f32> = (*terms_0)[i_2] * vec3<f32>((*pdfs_2)[i_2]) / vec3<f32>(((*pdfs_2)[i_2] + pdf_2));
            (*terms_0)[i_2] = _S795;
            var f_9 : vec3<f32> = f_8 + (*terms_0)[i_2];
            f_8 = f_9;
        }
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    return f_8;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_6 : vec3<f32>,  surface_2 : Surface,  material_22 : Material,  eta_1 : vec2<f32>,  is_inside_2 : bool,  facets_3 : Facets,  pdf_3 : f32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(6)>;
    var pdfs_3 : array<f32, i32(6)>;
    var _S796 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, material_22, eta_1, is_inside_2, facets_3, pdf_3, &(terms_1), &(pdfs_3));
    return _S796;
}

struct SkySample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     color : vec3<f32>,
     random_state : u32,
};

fn searchCDF_0( start_3 : vec2<u32>,  step_0 : vec2<u32>,  count_0 : u32,  u_1 : f32) -> u32
{
    var _S797 : u32 = count_0 - u32(1);
    var low_1 : u32 = u32(0);
    var high_1 : u32 = _S797;
    loop
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        var _S798 : u32 = (low_1 + high_1) / u32(2);
        var _S799 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S798)), 0));
        var _S800 : bool = (_S799.x) > u_1;
        if(_S800)
        {
            high_1 = _S798;
        }
        else
        {
            var _S801 : u32 = _S798 + u32(1);
            low_1 = _S801;
        }
    }
    return low_1;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_6 : u32) -> SkySample
{
    var _S802 : SkySample;
    _S802.dir = dir_7;
    _S802.radiance = radiance_2;
    _S802.color = color_2;
    _S802.random_state = random_state_6;
    return _S802;
}

fn skyRadiance_0( origin_6 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S803 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S804 : bool = is_inside_3 != _S803;
    var _S805 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S806 : vec3<f32> = select(surface_3.smooth_n, _S805, _S804);
    var _S807 : Ray = Ray_x24init_0(origin_6 + vec3<f32>(surface_3.geometry_offset) * _S806, dir_8);
    var _S808 : vec3<f32> = (env_map_sample((dir_8)));
    var _S809 : vec3<f32> = (shadowTransmittance((_S807), (4.294967296e+09f)));
    return _S808 * _S809;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  wavelength_7 : f32,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  facets_4 : Facets) -> SkySample
{
    var _S810 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S811 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S812 : vec2<u32> = _S810 - _S811;
    var _S813 : Random = draw(init_random_state_1, u32(6));
    var _S814 : Random = draw(init_random_state_1, u32(2147483654));
    var _S815 : Random = draw(init_random_state_1, u32(7));
    var _S816 : Random = draw(init_random_state_1, u32(2147483655));
    var _S817 : u32 = _S812.x;
    var _S818 : u32 = searchCDF_0(vec2<u32>(_S817, u32(0)), vec2<u32>(u32(0), u32(1)), _S812.y, _S813.value);
    var _S819 : u32 = searchCDF_0(vec2<u32>(u32(0), _S818), _S811, _S817, _S814.value);
    var _S820 : vec2<f32> = (vec2<f32>(f32(_S819), f32(_S818)) + vec2<f32>(_S815.value, _S816.value)) / vec2<f32>(_S812) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S821 : f32 = _S820.y;
    var _S822 : f32 = sin(_S821);
    var _S823 : f32 = _S820.x;
    var _S824 : vec3<f32> = vec3<f32>(_S822 * cos(_S823), cos(_S821), _S822 * sin(_S823));
    var _S825 : f32 = environmentPdf_0(_S824);
    var _S826 : Material = pathMaterial(surface_4.material, wavelength_7);
    var terms_2 : array<vec3<f32>, i32(6)>;
    var pdfs_4 : array<f32, i32(6)>;
    var _S827 : vec3<f32> = skyLobes_0(ray_1.unit_direction, _S824, surface_4, _S826, eta_2, is_inside_4, facets_4, _S825, &(terms_2), &(pdfs_4));
    var _S828 : bool = !(_S825 > 0.0f);
    var _S829 : bool;
    if(_S828)
    {
        _S829 = true;
    }
    else
    {
        _S829 = (all((_S827 == vec3<f32>(0.0f))));
    }
    if(_S829)
    {
        var _S830 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S824, _S830, _S830, _S816.state);
    }
    var _S831 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S824);
    return SkySample_x24init_0(_S824, _S831, _S827 * _S831, _S816.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S832 : vec3<f32> = a_5 / b_1;
    var _S833 : vec3<f32> = vec3<f32>(0.0f);
    var _S834 : vec3<bool> = b_1 == _S833;
    var _S835 : vec3<f32> = select(_S832, _S833, _S834);
    return _S835;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_10 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S836 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S837 : u32 = (insertBits((_S836), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S837;
    candidate_0.f = f_10;
    return candidate_0;
}

fn resamplingTarget( f_11 : vec3<f32>) -> f32
{
    var _S838 : f32 = rgb_to_greyscale(abs(f_11));
    return _S838;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_1 : vec3<f32>)
{
    var _S839 : f32 = resamplingTarget(weight_1);
    var _S840 : bool = _S839 > 0.0f;
    var _S841 : bool;
    if(_S840)
    {
        _S841 = _S839 < 3.00000000549775576e+38f;
    }
    else
    {
        _S841 = false;
    }
    var _S842 : bool = !_S841;
    if(_S842)
    {
        return;
    }
    var _S843 : f32 = (*sel_0).w_sum + _S839;
    (*sel_0).w_sum = _S843;
    var _S844 : vec3<f32> = (*sel_0).color + weight_1;
    (*sel_0).color = _S844;
    var _S845 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S845.state;
    var _S846 : bool = (_S845.value * (*sel_0).w_sum) <= _S839;
    if(_S846)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S847 : vec2<u32> = (uniforms_uint.environment_map_size);
    return (all((_S847 > vec2<u32>(u32(1)))));
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_7 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_4 : f32) -> SampleBSDF
{
    var _S848 : SampleBSDF;
    _S848.unit_direction = unit_direction_1;
    _S848.throughput = throughput_0;
    _S848.random_state = random_state_7;
    _S848.refracted = refracted_3;
    _S848.lobe = lobe_1;
    _S848.pdf = pdf_4;
    return _S848;
}

fn sheenVelvetSample( v_10 : vec3<f32>,  n_i_8 : vec3<f32>,  n_i_dot_v_3 : f32,  material_23 : Material,  w_13 : Weights,  random_state_8 : u32) -> SampleBSDF
{
    var _S849 : Random = draw(random_state_8, u32(3));
    var _S850 : Random = draw(random_state_8, u32(2147483651));
    var _S851 : f32 = _S849.value;
    var _S852 : f32 = sqrt(max(0.0f, 1.0f - _S851 * _S851));
    var _S853 : f32 = 6.28318548202514648f * _S850.value;
    var _S854 : vec3<f32> = tangentToWorld(vec3<f32>(_S852 * cos(_S853), _S849.value, _S852 * sin(_S853)), n_i_8);
    var _S855 : vec3<f32> = sheenVelvetBSDF(_S854, v_10, n_i_8, material_23, w_13);
    var _S856 : f32 = sheenVelvetPDF(_S849.value, n_i_dot_v_3, w_13);
    return SampleBSDF_x24init_0(_S854, _S855, _S850.state, false, u32(4), _S856);
}

fn coatSample( in_dir_8 : vec3<f32>,  v_11 : vec3<f32>,  coat_h_4 : vec3<f32>,  coat_frame_5 : CoatFrame,  w_14 : Weights,  random_state_9 : u32) -> SampleBSDF
{
    var _S857 : vec3<f32> = (normalize((reflect(in_dir_8, coat_h_4))));
    var _S858 : vec3<f32> = coatBSDF(w_14);
    var _S859 : f32 = coatPDF(v_11, coat_h_4, coat_frame_5, w_14);
    return SampleBSDF_x24init_0(_S857, _S858, random_state_9, false, u32(5), _S859);
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S860 : f32 = sqrt(random_1_0);
    var _S861 : f32 = 6.28318548202514648f * random_2_0;
    var _S862 : f32 = _S860 * cos(_S861);
    var _S863 : f32 = _S860 * sin(_S861);
    var _S864 : f32 = sqrt(max(0.0f, 1.0f - _S862 * _S862 - _S863 * _S863));
    return vec3<f32>(_S862, _S864, _S863);
}

fn diffuseSample( u_2 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_4 : f32,  material_24 : Material,  w_15 : Weights,  random_state_10 : u32) -> SampleBSDF
{
    var _S865 : Random = draw(random_state_10, u32(3));
    var _S866 : Random = draw(random_state_10, u32(2147483651));
    var _S867 : vec3<f32> = sampleCosWeightedHemisphere(_S865.value, _S866.value);
    var _S868 : f32 = translucentShare(material_24);
    var _S869 : bool = u_2 < (w_15.p_diffuse * _S868);
    var _S870 : f32 = _S867.y;
    var _S871 : f32 = - _S870;
    var _S872 : f32 = select(_S870, _S871, _S869);
    var _S873 : vec3<f32> = tangentToWorld(vec3<f32>(_S867.x, _S872, _S867.z), n_i_9);
    var _S874 : vec3<f32> = diffuseBSDF(_S873, n_i_9, material_24, w_15);
    var _S875 : f32 = diffusePDF(_S872, n_i_dot_v_4, material_24, w_15);
    return SampleBSDF_x24init_0(_S873, _S874, _S866.state, _S869, u32(0), _S875);
}

fn refractSample( ggx_n_1 : vec3<f32>,  n_i_10 : vec3<f32>,  alpha_7 : f32,  frame_5 : AnisotropicFrame,  material_25 : Material,  w_16 : Weights,  pdf_h_3 : f32,  eta_i_7 : f32,  eta_o_6 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S876 : f32 = maskingG1(w_16.refracted, n_i_10, -1.0f, alpha_7, frame_5);
    var _S877 : vec3<f32> = refractBSDF(_S876, material_25, w_16);
    var _S878 : f32 = refractPDF(dot(w_16.refracted, ggx_n_1), pdf_h_3, w_16, eta_i_7, eta_o_6);
    return SampleBSDF_x24init_0(w_16.refracted, _S877, random_state_11, true, u32(1), _S878);
}

fn reflectSample( in_dir_9 : vec3<f32>,  ggx_n_2 : vec3<f32>,  n_i_11 : vec3<f32>,  alpha_8 : f32,  frame_6 : AnisotropicFrame,  w_17 : Weights,  pdf_h_4 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S879 : vec3<f32> = (normalize((reflect(in_dir_9, ggx_n_2))));
    var _S880 : f32 = maskingG1(_S879, n_i_11, 1.0f, alpha_8, frame_6);
    var _S881 : vec3<f32> = reflectBSDF(_S880, w_17);
    var _S882 : f32 = reflectPDF(pdf_h_4, w_17);
    return SampleBSDF_x24init_0(_S879, _S881, random_state_12, false, u32(2), _S882);
}

fn sampleBSDF( in_dir_10 : vec3<f32>,  n_8 : vec3<f32>,  material_26 : Material,  eta_i_8 : f32,  eta_o_7 : f32,  facets_5 : Facets,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var _S883 : vec3<f32> = ((-(in_dir_10)));
    var _S884 : f32 = dot(n_8, _S883);
    var _S885 : f32 = (sign((_S884)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S885);
    var _S886 : f32 = abs(_S884);
    var _S887 : f32 = material_26.roughness;
    var _S888 : f32 = _S887 * _S887;
    var _S889 : AnisotropicFrame = anisotropicFrame(material_26, n_i_12);
    var _S890 : SheenProfile = sheenProfile(_S883, n_i_12, material_26);
    var _S891 : CoatFrame = coatFrame(material_26, n_i_12);
    var _S892 : vec3<f32> = coatSeries(_S891, material_26);
    var _S893 : Weights = lobeWeights(in_dir_10, _S883, n_i_12, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S889, _S890, _S891, _S892, material_26, eta_i_8, eta_o_7);
    var _S894 : Random = draw(random_init_0, u32(2));
    var _S895 : bool = (_S894.value) < (_S893.p_sheen_velvet);
    if(_S895)
    {
        var _S896 : SampleBSDF = sheenVelvetSample(_S883, n_i_12, _S886, material_26, _S893, _S894.state);
        return _S896;
    }
    var _S897 : f32 = _S894.value - _S893.p_sheen_velvet;
    var _S898 : bool = _S897 < (_S893.p_coat);
    if(_S898)
    {
        var _S899 : SampleBSDF = coatSample(in_dir_10, _S883, facets_5.coat_h, _S891, _S893, _S894.state);
        return _S899;
    }
    var _S900 : f32 = _S897 - _S893.p_coat;
    var _S901 : bool = _S900 < (_S893.p_diffuse);
    if(_S901)
    {
        var _S902 : SampleBSDF = diffuseSample(_S900, n_i_12, _S886, material_26, _S893, _S894.state);
        return _S902;
    }
    var _S903 : f32 = vndfPDF(_S883, facets_5.h, n_i_12, _S886, _S888, _S889, _S893.v_dot_h);
    var _S904 : bool = _S900 < (_S893.p_diffuse + _S893.p_refract);
    if(_S904)
    {
        var _S905 : SampleBSDF = refractSample(facets_5.h, n_i_12, _S888, _S889, material_26, _S893, _S903, eta_i_8, eta_o_7, _S894.state);
        return _S905;
    }
    var _S906 : SampleBSDF = reflectSample(in_dir_10, facets_5.h, n_i_12, _S888, _S889, _S893, _S903, _S894.state);
    return _S906;
}

fn refractedHalf( in_dir_11 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  eta_i_9 : f32,  eta_o_8 : f32) -> vec3<f32>
{
    var _S907 : vec3<f32> = ((-(in_dir_11)));
    var _S908 : vec3<f32> = ((-(vec3<f32>(eta_i_9) * _S907 + vec3<f32>(eta_o_8) * out_dir_2)));
    var _S909 : vec3<f32> = (normalize((_S908)));
    var _S910 : f32 = (sign((dot(n_9, _S907))));
    var _S911 : f32 = (sign((dot(_S908, n_9 * vec3<f32>(_S910)))));
    return _S909 * vec3<f32>(_S911);
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S912 : bool = pdf_5 <= 0.0f;
    var _S913 : bool;
    if(_S912)
    {
        _S913 = true;
    }
    else
    {
        var _S914 : bool = environmentMapped_0();
        _S913 = !_S914;
    }
    if(_S913)
    {
        return 1.0f;
    }
    var _S915 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S915);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S916 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S916.x, max(_S916.y, _S916.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S917 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S918 : bool = (all((_S917 > vec2<u32>(u32(1)))));
    if(_S918)
    {
        var _S919 : vec3<f32> = (env_map_sample((dir_10)));
        return _S919;
    }
    var _S920 : vec3<f32> = (uniforms_float.ambient);
    return _S920;
}

fn escape_0( r_4 : Reservoir,  replay_0 : bool,  stop_0 : u32,  rc_1 : u32,  end_1 : u32,  end_type_1 : u32,  scale_1 : f32,  strata_0 : u32,  chain_0 : Reservoir,  chain_throughput_0 : vec3<f32>,  b_2 : u32,  ray_2 : Ray,  throughput_2 : vec3<f32>,  density_2 : f32,  prev_0 : Vertex,  nee_vertex_0 : NEEVertex,  sky_pdf_0 : f32,  spectral_weight_0 : vec3<f32>,  wavelength_8 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S921 : Shift = Shift_x24init_0(vec3<f32>(0.0f), 0.0f);
    var _S922 : bool = !nee_vertex_0.none;
    var _S923 : f32 = select(0.0f, sky_pdf_0, _S922);
    var _S924 : f32 = escapeWeight_0(_S923, ray_2.unit_direction);
    var _S925 : vec3<f32> = environment_0(ray_2.unit_direction);
    var _S926 : vec3<f32> = pathColor(throughput_2 * _S925, spectral_weight_0, wavelength_8);
    if(replay_0)
    {
        var _S927 : bool = b_2 == stop_0;
        var _S928 : bool;
        if(_S927)
        {
            _S928 = rc_1 == u32(3);
        }
        else
        {
            _S928 = false;
        }
        if(_S928)
        {
            return Shift_x24init_0(_S926 * vec3<f32>(_S924) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S929 : bool = rc_1 == u32(0);
        if(_S929)
        {
            _S928 = end_type_1 == u32(3);
        }
        else
        {
            _S928 = false;
        }
        if(_S928)
        {
            _S928 = b_2 == end_1;
        }
        else
        {
            _S928 = false;
        }
        if(_S928)
        {
            _S928 = !prev_0.rough;
        }
        else
        {
            _S928 = false;
        }
        if(_S928)
        {
            return Shift_x24init_0(_S926 * vec3<f32>(_S924), 1.0f);
        }
        return _S921;
    }
    var candidate_2 : Reservoir = chain_0;
    var _S930 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
    var _S931 : bool = _S930 == u32(1);
    if(_S931)
    {
        var _S932 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
        var _S933 : bool = _S932 == b_2;
        var _S934 : f32 = select(_S924, 1.0f, _S933);
        var _S935 : vec3<f32> = safeDivide(_S926 * vec3<f32>(_S934), chain_throughput_0);
        candidate_2.radiance = _S935;
    }
    else
    {
        if(prev_0.rough)
        {
            var _S936 : u32 = (insertBits((strata_0), (b_2 + u32(1)), (u32(5)), (u32(5))));
            var _S937 : u32 = (insertBits((_S936), (u32(3)), (u32(10)), (u32(2))));
            var _S938 : u32 = (insertBits((_S937), (prev_0.lobe), (u32(15)), (u32(3))));
            var _S939 : u32 = select(u32(0), u32(1), prev_0.inside);
            var _S940 : u32 = (insertBits((_S938), (_S939), (u32(22)), (u32(1))));
            candidate_2.path = _S940;
            candidate_2.jac = prev_0.pdf;
            candidate_2.dir = ray_2.unit_direction;
        }
    }
    var _S941 : vec3<f32> = _S926 * vec3<f32>(_S924);
    var _S942 : Reservoir = withEnd(candidate_2, u32(3), b_2, _S941);
    offer(&((*sel_1)), _S942, _S941 * vec3<f32>(scale_1) / vec3<f32>(density_2));
    return _S921;
}

fn walk_0( dom_1 : Domain,  r_5 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_2 : ptr<function, Selection>) -> Shift
{
    var _S943 : vec3<f32> = vec3<f32>(0.0f);
    var _S944 : Shift = Shift_x24init_0(_S943, 0.0f);
    var _S945 : u32 = (extractBits((r_5.path), (u32(0)), (u32(5))));
    var _S946 : u32 = (extractBits((r_5.path), (u32(5)), (u32(5))));
    var _S947 : u32 = (extractBits((r_5.path), (u32(10)), (u32(2))));
    var _S948 : u32 = (extractBits((r_5.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_1)
    {
        var _S949 : bool = _S948 >= u32(3);
        var _S950 : u32 = select(u32(0), u32(1), _S949);
        var _S951 : u32 = _S945 + _S950;
        var _S952 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S951 > _S952;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S944;
    }
    var _S953 : u32 = _S946 - u32(1);
    var _S954 : bool = _S948 == u32(3);
    var _S955 : u32 = select(u32(0), u32(1), _S954);
    var _S956 : u32 = _S945 + _S955;
    var _S957 : bool = _S947 == u32(0);
    var _S958 : u32 = select(_S953, _S956, _S957);
    var _S959 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_5.rc.zw))), r_5.rc.x, r_5.rc.y, u32(0), 0.0f);
    var _S960 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S961 : Ray = Ray_x24init_0(dom_1.x1, _S960);
    var ray_3 : Ray = _S961;
    var hit_2 : Hit = dom_1.hit;
    var _S962 : vec3<f32> = vec3<f32>(1.0f);
    var _S963 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S943, _S943, _S943);
    var nee_vertex_1 : NEEVertex = _S963;
    var _S964 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_1 : Vertex = _S964;
    var _S965 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S943, 0.0f, vec4<u32>(u32(0)), _S943, _S943);
    var chain_1 : Reservoir = _S965;
    chain_1.seed = r_5.seed;
    var _S966 : u32 = (extractBits((r_5.path), (u32(24)), (u32(8))));
    var _S967 : u32 = (insertBits((u32(0)), (_S966), (u32(24)), (u32(8))));
    chain_1.path = _S967;
    is_inside_5 = false;
    var wavelength_9 : f32 = 0.0f;
    var threshold_0 : f32 = 0.0f;
    var spectral_weight_1 : vec3<f32> = _S962;
    var chain_throughput_1 : vec3<f32> = _S943;
    var reconnection_0 : vec3<f32> = _S943;
    var b_3 : u32 = u32(0);
    var throughput_3 : vec3<f32> = _S962;
    var scatter_in_0 : vec3<f32> = _S943;
    var extinction_in_0 : vec3<f32> = _S943;
    var density_3 : f32 = 1.0f;
    var sky_pdf_1 : f32 = 0.0f;
    loop
    {
        var _S968 : bool = (hit_2.is_point_light) == u32(1);
        var _S969 : bool;
        if(replay_1)
        {
            _S969 = _S947 == u32(1);
        }
        else
        {
            _S969 = false;
        }
        var _S970 : bool;
        if(_S969)
        {
            _S970 = b_3 == _S946;
        }
        else
        {
            _S970 = false;
        }
        var _S971 : bool;
        if(_S970)
        {
            var _S972 : bool = (hit_2.instance_index) != (_S959.instance_index);
            if(_S972)
            {
                _S971 = true;
            }
            else
            {
                _S971 = (hit_2.triangle_index) != (_S959.triangle_index);
            }
        }
        else
        {
            _S971 = false;
        }
        if(_S971)
        {
            return _S944;
        }
        var _S973 : Surface = Surface_x24init_0(_S943, _S943, 0.0f, Material_x24init_0(_S943, _S943, 0.0f, 0.0f, 0.0f, 0.0f, _S943, _S962, 1.0f, _S943, _S943, 0.5f, 0.0f, 0.0f, _S943, 0.0f, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S962, _S943), false, u32(0));
        var _S974 : bool = !_S968;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_4 : vec3<f32>;
        var surface_5 : Surface;
        if(_S974)
        {
            var _S975 : u32 = noiseAddress(r_5.seed, b_3);
            var _S976 : Surface = (surfaceAt((hit_2), (ray_3.origin), (_S975)));
            var surface_6 : Surface = facingRay_0(_S976, ray_3.unit_direction);
            if(is_inside_5)
            {
                var _S977 : f32 = hit_2.distance;
                var _S978 : f32 = upsample(surface_6.material.absorption, wavelength_9);
                var _S979 : vec3<f32> = vec3<f32>(_S978);
                var _S980 : bool = wavelength_9 > 0.0f;
                var _S981 : vec3<f32> = select(surface_6.material.absorption, _S979, _S980);
                var _S982 : vec3<f32> = beerLambert(_S977, _S981);
                var _S983 : vec3<f32> = throughput_3 * _S982;
                front_n_0 = _S983;
            }
            else
            {
                front_n_0 = throughput_3;
            }
            var _S984 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_3.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S985 : bool = b_3 == u32(0);
            if(_S985)
            {
                var _S986 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S986;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S987 : vec3<f32> = front_n_0;
            var _S988 : f32 = geometry_density_0;
            scatter_0 = _S984;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S988;
            surface_5 = surface_6;
            front_n_0 = _S976.smooth_n;
            throughput_4 = _S987;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S973;
            front_n_0 = _S943;
            throughput_4 = throughput_3;
        }
        var _S989 : bool;
        if(scatter_0)
        {
            _S989 = prev_1.rough;
        }
        else
        {
            _S989 = false;
        }
        var _S990 : bool;
        if(_S989)
        {
            _S990 = (prev_1.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S990 = false;
        }
        var _S991 : Surface = surface_5;
        var _S992 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_3.unit_direction));
        var _S993 : bool = ((true));
        var _S994 : bool;
        if(_S993)
        {
            _S994 = wavelength_9 == 0.0f;
        }
        else
        {
            _S994 = false;
        }
        var _S995 : bool;
        if(_S994)
        {
            _S995 = scatter_0;
        }
        else
        {
            _S995 = false;
        }
        var _S996 : bool;
        if(_S995)
        {
            var _S997 : bool = dispersive(surface_5.material);
            _S996 = _S997;
        }
        else
        {
            _S996 = false;
        }
        var throughput_5 : vec3<f32>;
        if(_S996)
        {
            var _S998 : u32 = stream(r_5.seed, u32(512));
            var _S999 : Random = pcg(_S998);
            var _S1000 : u32 = (extractBits((r_5.path), (u32(25)), (u32(7))));
            var _S1001 : f32 = (f32(_S1000) + _S999.value) / 128.0f;
            var _S1002 : u32 = (extractBits((r_5.path), (u32(24)), (u32(1))));
            var _S1003 : bool = _S1002 == u32(1);
            var _S1004 : f32 = select(_S999.value, _S1001, _S1003);
            var _S1005 : vec2<f32> = sampleWavelength(_S1004);
            var wavelength_10 : f32 = _S1005.x;
            var _S1006 : vec3<f32> = wavelengthWeights(wavelength_10);
            var _S1007 : vec3<f32> = _S1006 / vec3<f32>(_S1005.y);
            var _S1008 : f32 = upsample(throughput_4, wavelength_10);
            var _S1009 : vec3<f32> = vec3<f32>(_S1008);
            var _S1010 : f32 = upsample(scatter_in_0, wavelength_10);
            var _S1011 : vec3<f32> = vec3<f32>(_S1010);
            var _S1012 : f32 = upsample(extinction_in_0, wavelength_10);
            var _S1013 : vec3<f32> = vec3<f32>(_S1012);
            wavelength_9 = wavelength_10;
            spectral_weight_1 = _S1007;
            throughput_5 = _S1009;
            scatter_in_0 = _S1011;
            extinction_in_0 = _S1013;
        }
        else
        {
            throughput_5 = throughput_4;
        }
        var _S1014 : Material = pathMaterial(surface_5.material, wavelength_9);
        var _S1015 : vec2<f32> = wavelengthEta(_S1014, _S992, wavelength_9);
        var _S1016 : Surface = surface_5;
        var _S1017 : Facets = drawFacets(ray_3.unit_direction, _S991.smooth_n, _S1014, surface_5.random_state);
        var _S1018 : bool;
        if(scatter_0)
        {
            var _S1019 : u32 = (uniforms_uint.max_bounces);
            var _S1020 : bool = b_3 >= _S1019;
            if(_S1020)
            {
                _S1018 = true;
            }
            else
            {
                var _S1021 : bool = neeDecision(_S1014, _S992, _S1015.x, _S1015.y);
                _S1018 = _S1021;
            }
        }
        else
        {
            _S1018 = false;
        }
        var _S1022 : bool = isTranslucent_0(_S1014);
        var _S1023 : f32 = (sign((dot((vec3<f32>(0) - ray_3.unit_direction), front_n_0))));
        var _S1024 : vec3<f32> = _S1014.emissive * vec3<f32>(max(_S1023, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S968)
        {
            var _S1025 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S1025;
        }
        else
        {
            emission_0 = _S1024;
        }
        var _S1026 : bool = !replay_1;
        var _S1027 : bool;
        if(_S1026)
        {
            _S1027 = true;
        }
        else
        {
            _S1027 = b_3 >= _S958;
        }
        var _S1028 : bool;
        if(_S1027)
        {
            var _S1029 : f32 = rgb_to_greyscale(emission_0);
            _S1028 = _S1029 > 0.0f;
        }
        else
        {
            _S1028 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S1028)
        {
            var _S1030 : f32 = emissionWeight_0(nee_vertex_1, hit_2, ray_3.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S1030);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S1031 : bool;
        if(replay_1)
        {
            _S1031 = _S947 == u32(1);
        }
        else
        {
            _S1031 = false;
        }
        var _S1032 : bool;
        if(_S1031)
        {
            _S1032 = b_3 > _S946;
        }
        else
        {
            _S1032 = false;
        }
        var _S1033 : bool;
        if(_S1032)
        {
            _S1033 = b_3 == _S945;
        }
        else
        {
            _S1033 = false;
        }
        var _S1034 : bool;
        if(_S1033)
        {
            var _S1035 : bool = _S948 == u32(1);
            if(_S1035)
            {
                _S1034 = true;
            }
            else
            {
                _S1034 = _S948 == u32(2);
            }
        }
        else
        {
            _S1034 = false;
        }
        if(_S1034)
        {
            var _S1036 : bool = _S968 != (_S948 == u32(2));
            if(_S1036)
            {
                return _S944;
            }
            var _S1037 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S1037 / vec3<f32>(r_5.jac), density_3 / r_5.jac);
        }
        var _S1038 : u32 = (extractBits((chain_1.path), (u32(10)), (u32(2))));
        var _S1039 : bool = _S1038 == u32(1);
        var here_0 : Reservoir = chain_1;
        var _S1040 : u32 = (insertBits((_S967), (b_3), (u32(5)), (u32(5))));
        var _S1041 : u32 = (insertBits((_S1040), (u32(1)), (u32(10)), (u32(2))));
        var _S1042 : u32 = (insertBits((_S1041), (prev_1.lobe), (u32(15)), (u32(3))));
        var _S1043 : bool = prev_1.inside;
        var _S1044 : u32 = select(u32(0), u32(1), _S1043);
        var _S1045 : u32 = (insertBits((_S1042), (_S1044), (u32(22)), (u32(1))));
        here_0.path = _S1045;
        var _S1046 : u32 = here_0.path;
        var _S1047 : bool = wavelength_9 > 0.0f;
        var _S1048 : u32 = select(u32(0), u32(1), _S1047);
        var _S1049 : u32 = (insertBits((_S1046), (_S1048), (u32(23)), (u32(1))));
        here_0.path = _S1049;
        var _S1050 : f32 = prev_1.pdf * geometry_density_0;
        here_0.jac = _S1050;
        var _S1051 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S1051;
        var _S1052 : bool;
        if(replay_1)
        {
            _S1052 = _S947 == u32(1);
        }
        else
        {
            _S1052 = false;
        }
        var _S1053 : bool;
        if(_S1052)
        {
            _S1053 = b_3 == _S946;
        }
        else
        {
            _S1053 = false;
        }
        var _S1054 : bool = b_3 == _S958;
        var _S1055 : bool;
        if(_S1054)
        {
            var _S1056 : bool = !scatter_0;
            if(_S1056)
            {
                _S1055 = true;
            }
            else
            {
                var _S1057 : bool = _S947 != u32(1);
                if(_S1057)
                {
                    _S1055 = _S947 != u32(3);
                }
                else
                {
                    _S1055 = false;
                }
            }
        }
        else
        {
            _S1055 = false;
        }
        var _S1058 : bool;
        if(_S1055)
        {
            _S1058 = _S947 == u32(2);
        }
        else
        {
            _S1058 = false;
        }
        var _S1059 : bool;
        if(_S1058)
        {
            _S1059 = !_S990;
        }
        else
        {
            _S1059 = false;
        }
        var _S1060 : bool;
        if(_S1059)
        {
            _S1060 = _S948 != u32(4);
        }
        else
        {
            _S1060 = false;
        }
        var _S1061 : bool = _S946 == _S945;
        var _S1062 : bool;
        if(_S1061)
        {
            _S1062 = _S948 == u32(0);
        }
        else
        {
            _S1062 = false;
        }
        var _S1063 : bool;
        if(_S1062)
        {
            _S1063 = (hit_2.instance_index) == (_S959.instance_index);
        }
        else
        {
            _S1063 = false;
        }
        var _S1064 : bool;
        if(_S1063)
        {
            _S1064 = (hit_2.triangle_index) == (_S959.triangle_index);
        }
        else
        {
            _S1064 = false;
        }
        var _S1065 : bool;
        if(_S1064)
        {
            _S1065 = _S990;
        }
        else
        {
            _S1065 = false;
        }
        var _S1066 : bool = select(_S1060, _S1065, _S1053);
        var _S1067 : bool;
        if(_S1018)
        {
            _S1067 = select(scatter_0, _S1066, replay_1);
        }
        else
        {
            _S1067 = false;
        }
        var _S1068 : TreeSample = TreeSample_x24init_0(_S943, _S943, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S1067)
        {
            var _S1069 : Surface = surface_5;
            var _S1070 : u32 = noiseAddress(r_5.seed, b_3);
            var _S1071 : TreeSample = sampleLightTree_0(ray_3.origin, _S991.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S1022, _S1070);
            var _S1072 : bool = (any(((_S1071.radiance) != _S943)));
            if(_S1072)
            {
                var _S1073 : f32 = _S1015.x;
                var _S1074 : f32 = _S1015.y;
                var _S1075 : u32 = (uniforms_uint.max_bounces);
                var _S1076 : vec3<f32> = lightBSDF_0(ray_3.unit_direction, _S1071, _S991.smooth_n, _S1069.geometry_n, _S1014, _S1073, _S1074, b_3 < _S1075, _S1017);
                lit_0 = _S1076;
            }
            else
            {
                lit_0 = _S943;
            }
            light_1 = _S1071;
        }
        else
        {
            light_1 = _S1068;
            lit_0 = _S943;
        }
        var _S1077 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S1078 : bool;
        var _S1079 : bool;
        var density_4 : f32;
        var throughput_6 : vec3<f32>;
        if(_S1053)
        {
            var _S1080 : bool = !_S990;
            if(_S1080)
            {
                return _S944;
            }
            var _S1081 : u32 = (extractBits((r_5.path), (u32(23)), (u32(1))));
            var _S1082 : bool = _S1047 != (_S1081 == u32(1));
            if(_S1082)
            {
                return _S944;
            }
            var throughput_7 : vec3<f32> = throughput_5 * vec3<f32>(geometry_density_0);
            var density_5 : f32 = density_3 * geometry_density_0;
            if(_S1061)
            {
                _S1077 = _S948 == u32(1);
            }
            else
            {
                _S1077 = false;
            }
            if(_S1077)
            {
                var _S1083 : vec3<f32> = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1083 / vec3<f32>(r_5.jac), density_5 / r_5.jac);
            }
            if(_S1061)
            {
                wrong_side_0 = _S948 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S1084 : bool = !_S1018;
                if(_S1084)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S1085 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S1085 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S944;
                }
                var _S1086 : vec3<f32> = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1086 / vec3<f32>(r_5.jac), density_5 / r_5.jac);
            }
            if(_S1061)
            {
                refracted_4 = _S948 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S1087 : bool = !_S1018;
                if(_S1087)
                {
                    return _S944;
                }
                var _S1088 : f32 = environmentPdf_0(r_5.dir);
                var _S1089 : vec3<f32> = skyBSDF(ray_3.unit_direction, r_5.dir, surface_5, _S1014, _S1015, is_inside_5, _S1017, _S1088);
                var _S1090 : vec3<f32> = pathColor(throughput_7 * _S1089 * r_5.radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1090 / vec3<f32>(r_5.jac), density_5 / r_5.jac);
            }
            var _S1091 : u32 = (extractBits((r_5.path), (u32(21)), (u32(1))));
            var _S1092 : bool = _S1018 != (_S1091 == u32(1));
            if(_S1092)
            {
                return _S944;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S1077 = _S1054;
            }
            else
            {
                _S1077 = false;
            }
            if(_S1077)
            {
                var _S1093 : bool = !scatter_0;
                if(_S1093)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S1094 : bool = _S947 != u32(1);
                    if(_S1094)
                    {
                        wrong_side_0 = _S947 != u32(3);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                }
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S1095 : bool = _S947 == u32(2);
                if(_S1095)
                {
                    _S969 = _S1018;
                }
                else
                {
                    _S969 = false;
                }
                if(_S969)
                {
                    _S969 = !_S990;
                }
                else
                {
                    _S969 = false;
                }
                if(_S969)
                {
                    _S969 = _S948 == u32(4);
                }
                else
                {
                    _S969 = false;
                }
                if(_S969)
                {
                    var _S1096 : u32 = noiseAddress(r_5.seed, b_3);
                    var _S1097 : SkySample = sampleSky_0(ray_3, surface_5, wavelength_9, _S1015, is_inside_5, _S1096, _S1017);
                    var _S1098 : vec3<f32> = pathColor(throughput_5 * _S1097.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1098, 1.0f);
                }
                if(_S1095)
                {
                    is_inside_5 = _S1018;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S990;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S1099 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S1100 : bool = !(_S1099 > 0.0f);
                    if(_S1100)
                    {
                        return _S944;
                    }
                    var _S1101 : vec3<f32> = pathColor(throughput_5 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1101, 1.0f);
                }
                if(_S957)
                {
                    is_inside_5 = _S948 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S968;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S1102 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1102, 1.0f);
                }
                if(_S957)
                {
                    is_inside_5 = _S948 == u32(1);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = scatter_0;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S990;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S1103 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1103, 1.0f);
                }
                return _S944;
            }
            else
            {
                if(_S1026)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S1104 : bool = b_3 > u32(0);
                    if(_S1104)
                    {
                        var candidate_3 : Reservoir = chain_1;
                        if(_S1039)
                        {
                            var _S1105 : vec3<f32> = safeDivide(throughput_5 * emission_1, chain_throughput_1);
                            candidate_3.radiance = _S1105;
                        }
                        else
                        {
                            if(_S990)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S1106 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                        var _S1107 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S1106);
                        offer(&((*sel_2)), _S1107, _S1106 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                    if(_S1018)
                    {
                        var _S1108 : vec3<f32> = pathColor(throughput_5 * lit_0, spectral_weight_1, wavelength_9);
                        var candidate_4 : Reservoir = chain_1;
                        if(_S1039)
                        {
                            var _S1109 : vec3<f32> = safeDivide(_S1108, chain_throughput_1);
                            candidate_4.radiance = _S1109;
                        }
                        else
                        {
                            if(_S990)
                            {
                                candidate_4 = here_0;
                                var _S1110 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S1110;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S1111 : u32 = (insertBits((_S967), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S1112 : u32 = (insertBits((_S1111), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S1112;
                            }
                        }
                        var _S1113 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S1108);
                        offer(&((*sel_2)), _S1113, _S1108 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                    if(_S1018)
                    {
                        var _S1114 : bool = environmentMapped_0();
                        _S1078 = _S1114;
                    }
                    else
                    {
                        _S1078 = false;
                    }
                    if(_S1078)
                    {
                        var _S1115 : u32 = (uniforms_uint.max_bounces);
                        _S1079 = b_3 < _S1115;
                    }
                    else
                    {
                        _S1079 = false;
                    }
                    if(_S1079)
                    {
                        var _S1116 : u32 = noiseAddress(r_5.seed, b_3);
                        var _S1117 : SkySample = sampleSky_0(ray_3, surface_5, wavelength_9, _S1015, is_inside_5, _S1116, _S1017);
                        var _S1118 : vec3<f32> = pathColor(throughput_5 * _S1117.color, spectral_weight_1, wavelength_9);
                        var candidate_5 : Reservoir = chain_1;
                        if(_S1039)
                        {
                            var _S1119 : vec3<f32> = safeDivide(_S1118, chain_throughput_1);
                            candidate_5.radiance = _S1119;
                        }
                        else
                        {
                            if(_S990)
                            {
                                candidate_5 = here_0;
                                var _S1120 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S1120;
                                candidate_5.dir = _S1117.dir;
                                candidate_5.radiance = _S1117.radiance;
                            }
                            else
                            {
                                var _S1121 : u32 = (insertBits((_S967), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S1122 : u32 = (insertBits((_S1121), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S1122;
                            }
                        }
                        var _S1123 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S1118);
                        offer(&((*sel_2)), _S1123, _S1118 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_3;
        }
        var _S1124 : bool;
        var _S1125 : bool;
        var straight_0 : bool;
        var _S1126 : bool;
        var _S1127 : bool;
        var density_6 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_1)
            {
                _S1077 = _S1054;
            }
            else
            {
                _S1077 = false;
            }
            var _S1128 : u32 = (extractBits((r_5.path), (u32(15)), (u32(3))));
            var _S1129 : u32 = (extractBits((r_5.path), (u32(18)), (u32(3))));
            var _S1130 : u32 = select(_S1128, _S1129, _S1053);
            var refracted_5 : bool = _S1130 == u32(1);
            var _S1131 : SampleBSDF = SampleBSDF_x24init_0(_S943, _S943, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S1131;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S1077)
            {
                var _S1132 : u32 = (extractBits((r_5.path), (u32(22)), (u32(1))));
                var _S1133 : bool = is_inside_5 != (_S1132 == u32(1));
                if(_S1133)
                {
                    return _S944;
                }
                var _S1134 : bool = _S947 == u32(1);
                if(_S1134)
                {
                    var _S1135 : vec3<f32> = (hitPosition((_S959)));
                    dir_11 = _S1135;
                }
                else
                {
                    dir_11 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    var _S1136 : bool = isTranslucent_0(_S1014);
                    if(_S1136)
                    {
                        wrong_side_0 = _S1130 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1137 : vec3<f32> = dir_11 - ray_3.origin;
                        var _S1138 : vec3<f32> = select(r_5.dir, _S1137, _S1134);
                        refracted_4 = (dot(_S991.smooth_n, _S1138) * _S992) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S1134)
                {
                    var _S1139 : vec3<f32> = ray_3.origin;
                    var _S1140 : Surface = surface_5;
                    var _S1141 : vec3<f32> = (vec3<f32>(0) - _S991.smooth_n);
                    var _S1142 : bool = is_inside_5 != refracted_4;
                    var _S1143 : vec3<f32> = select(_S991.smooth_n, _S1141, _S1142);
                    var _S1144 : vec3<f32> = (normalize((dir_11 - (_S1139 + vec3<f32>(_S1140.geometry_offset) * _S1143))));
                    reconnection_1 = _S1144;
                }
                else
                {
                    reconnection_1 = r_5.dir;
                }
                var _S1145 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S1145)
                {
                    return _S944;
                }
                var _S1146 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S1130;
                wrong_side_0 = false;
                reconnection_1 = _S1146;
            }
            else
            {
                var _S1147 : bool = !_S1053;
                if(_S1147)
                {
                    var _S1148 : f32 = _S1015.x;
                    var _S1149 : f32 = _S1015.y;
                    var _S1150 : vec2<f32> = vec2<f32>(0.0f);
                    var _S1151 : SampleBSDF = sampleBSDF(ray_3.unit_direction, _S991.smooth_n, _S1014, _S1148, _S1149, _S1017, _S1016.random_state, _S1150);
                    var bsdf_sampled_0 : SampleBSDF = _S1151;
                    var _S1152 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S1014.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1153 : Facets = drawFacets(bsdf_sampled_0.unit_direction, _S1152.geometry_n, _S1014, bsdf_sampled_0.random_state);
                        var _S1154 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S1152.geometry_n, _S1014, _S1148, _S1149, _S1153, bsdf_sampled_0.random_state, _S1150);
                        bsdf_sampled_0.unit_direction = _S1154.unit_direction;
                        bsdf_sampled_0.refracted = _S1154.refracted;
                        bsdf_sampled_0.throughput = _S1154.throughput;
                        bsdf_sampled_0.lobe = _S1154.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S1155 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S1152.geometry_n))) * _S1152.geometry_n;
                            bsdf_sampled_0.unit_direction = _S1155;
                        }
                    }
                    var _S1156 : u32 = bsdf_sampled_0.lobe;
                    var _S1157 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S1158 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S1159 : f32 = bsdf_sampled_0.pdf;
                    var _S1160 : f32 = select(_S1159, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S1160;
                    dir_11 = _S1157;
                    lobe_index_0 = _S1156;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1158;
                }
                else
                {
                    dir_11 = r_5.dir;
                    lobe_index_0 = _S1130;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S1077)
            {
                _S1078 = true;
            }
            else
            {
                _S1078 = _S1053;
            }
            var throughput_8 : vec3<f32>;
            var throughput_9 : vec3<f32>;
            if(_S1078)
            {
                var _S1161 : vec3<f32> = ray_3.unit_direction;
                var _S1162 : vec3<f32> = ((-(_S1161)));
                var _S1163 : f32 = (sign((_S992)));
                var _S1164 : vec3<f32> = _S991.smooth_n * vec3<f32>(_S1163);
                var _S1165 : f32 = dot(_S1164, dir_11);
                var _S1166 : f32 = _S1014.roughness;
                var _S1167 : f32 = _S1166 * _S1166;
                var _S1168 : AnisotropicFrame = anisotropicFrame(_S1014, _S1164);
                var _S1169 : SheenProfile = sheenProfile(_S1162, _S1164, _S1014);
                var _S1170 : CoatFrame = coatFrame(_S1014, _S1164);
                var _S1171 : vec3<f32> = coatSeries(_S1170, _S1014);
                var _S1172 : vec3<f32> = reflectedHalf(_S1161, dir_11);
                var _S1173 : bool = lobe_index_0 == u32(1);
                if(_S1173)
                {
                    var _S1174 : vec3<f32> = refractedHalf(_S1161, dir_11, _S991.smooth_n, _S1015.x, _S1015.y);
                    throughput_8 = _S1174;
                }
                else
                {
                    throughput_8 = _S1172;
                }
                var _S1175 : vec3<f32> = _S1017.coat_h;
                var _S1176 : bool = (dot(_S1175, _S1175)) > 0.0f;
                var _S1177 : vec3<f32> = select(_S943, _S1172, _S1176);
                var _S1178 : f32 = _S1015.x;
                var _S1179 : f32 = _S1015.y;
                var _S1180 : Weights = lobeWeights(_S1161, _S1162, _S1164, _S1017.h, _S1017.coat_h, throughput_8, _S1177, _S1168, _S1169, _S1170, _S1171, _S1014, _S1178, _S1179);
                var _S1181 : f32 = abs(_S992);
                var _S1182 : f32 = vndfPDF(_S1162, throughput_8, _S1164, _S1181, _S1167, _S1168, _S1180.v_dot_h);
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S1183 : f32 = diffusePDF(_S1165, _S1181, _S1014, _S1180);
                        var _S1184 : vec3<f32> = diffuseBSDF(dir_11, _S1164, _S1014, _S1180);
                        density_6 = _S1183;
                        throughput_9 = _S1184;
                    }
                case u32(1):
                    {
                        var _S1185 : f32 = refractPDF(dot(dir_11, throughput_8), _S1182, _S1180, _S1178, _S1179);
                        var _S1186 : f32 = maskingG1(dir_11, _S1164, -1.0f, _S1167, _S1168);
                        var _S1187 : vec3<f32> = refractBSDF(_S1186, _S1014, _S1180);
                        density_6 = _S1185;
                        throughput_9 = _S1187;
                    }
                case u32(4):
                    {
                        var _S1188 : f32 = sheenVelvetPDF(_S1165, _S1181, _S1180);
                        var _S1189 : vec3<f32> = sheenVelvetBSDF(dir_11, _S1162, _S1164, _S1014, _S1180);
                        density_6 = _S1188;
                        throughput_9 = _S1189;
                    }
                case u32(5):
                    {
                        var _S1190 : f32 = coatPDF(_S1162, _S1177, _S1170, _S1180);
                        var _S1191 : vec3<f32> = coatBSDF(_S1180);
                        density_6 = _S1190;
                        throughput_9 = _S1191;
                    }
                default :
                    {
                        var _S1192 : f32 = reflectPDF(_S1182, _S1180);
                        var _S1193 : f32 = maskingG1(dir_11, _S1164, 1.0f, _S1167, _S1168);
                        var _S1194 : vec3<f32> = reflectBSDF(_S1193, _S1180);
                        density_6 = _S1192;
                        throughput_9 = _S1194;
                    }
                }
                var _S1195 : bool = density_6 > 0.0f;
                if(_S1195)
                {
                    var _S1196 : SampleBSDF = SampleBSDF_x24init_0(dir_11, throughput_9, _S1016.random_state, _S1173, lobe_index_0, density_6);
                    lobe_2 = _S1196;
                }
            }
            var _S1197 : bool = lobe_index_0 == u32(0);
            if(_S1197)
            {
                _S1079 = true;
            }
            else
            {
                _S1079 = lobe_index_0 == u32(4);
            }
            if(_S1079)
            {
                _S1124 = true;
            }
            else
            {
                _S1124 = lobe_index_0 == u32(6);
            }
            var _S1198 : bool = lobe_index_0 == u32(5);
            var _S1199 : f32 = select(_S1014.roughness, _S1014.coat_roughness, _S1198);
            var _S1200 : bool = !_S1124;
            if(_S1200)
            {
                var _S1201 : bool = _S1199 == 0.0f;
                if(_S1201)
                {
                    _S1125 = true;
                }
                else
                {
                    var _S1202 : bool = lobe_index_0 == u32(1);
                    if(_S1202)
                    {
                        _S1125 = (_S1015.x) == (_S1015.y);
                    }
                    else
                    {
                        _S1125 = false;
                    }
                }
            }
            else
            {
                _S1125 = false;
            }
            var _S1203 : bool = lobe_index_0 == u32(1);
            if(_S1203)
            {
                straight_0 = (_S1014.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S1204 : bool = isTranslucent_0(_S1014);
            if(_S1204)
            {
                _S1126 = _S1197;
            }
            else
            {
                _S1126 = false;
            }
            if(_S1126)
            {
                _S1127 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S1127 = false;
            }
            var _S1205 : bool;
            if(_S1018)
            {
                _S1205 = !_S1125;
            }
            else
            {
                _S1205 = false;
            }
            var _S1206 : bool;
            if(_S1205)
            {
                _S1206 = !wrong_side_0;
            }
            else
            {
                _S1206 = false;
            }
            var _S1207 : bool;
            if(_S1206)
            {
                var _S1208 : f32 = lobe_2.pdf;
                var _S1209 : vec3<f32> = ray_3.origin;
                var _S1210 : vec3<f32> = select(_S991.smooth_n, _S943, _S1022);
                var _S1211 : vec3<f32> = ray_3.origin;
                var _S1212 : Surface = surface_5;
                var _S1213 : vec3<f32> = (vec3<f32>(0) - _S991.smooth_n);
                var _S1214 : vec3<f32> = select(_S991.smooth_n, _S1213, _S1127);
                var _S1215 : NEEVertex = NEEVertex_x24init_0(false, _S1208, _S1209, _S1210, _S1211 + vec3<f32>(_S1212.geometry_offset) * _S1214);
                nee_vertex_1 = _S1215;
            }
            else
            {
                var _S1216 : bool = lobe_index_0 != u32(1);
                if(_S1216)
                {
                    _S1207 = true;
                }
                else
                {
                    _S1207 = (_S1015.x) != (_S1015.y);
                }
                if(_S1207)
                {
                    nee_vertex_1.none = true;
                }
            }
            var _S1217 : bool = (lobe_2.pdf) > 0.0f;
            if(_S1217)
            {
                if(_S1124)
                {
                    _S1207 = true;
                }
                else
                {
                    _S1207 = (lobe_2.pdf * prev_1.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1207 = false;
            }
            var _S1218 : bool = (lobe_2.pdf) > 0.0f;
            var _S1219 : bool;
            if(_S1218)
            {
                if(_S1124)
                {
                    _S1219 = true;
                }
                else
                {
                    _S1219 = _S1199 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1219 = false;
            }
            var _S1220 : bool;
            if(_S1053)
            {
                var _S1221 : bool = !_S1207;
                if(_S1221)
                {
                    return _S944;
                }
                var _S1222 : bool = _S948 != u32(1);
                if(_S1222)
                {
                    _S1220 = _S948 != u32(2);
                }
                else
                {
                    _S1220 = false;
                }
                if(_S1220)
                {
                    var _S1223 : f32 = lobe_2.pdf;
                    var _S1224 : f32 = select(0.0f, _S1223, _S1018);
                    var _S1225 : f32 = escapeWeight_0(_S1224, r_5.dir);
                    if(_S1061)
                    {
                        is_inside_5 = _S954;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S1226 : f32 = select(1.0f, _S1225, is_inside_5);
                    return Shift_x24init_0(throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_5.radiance * vec3<f32>(_S1226) / vec3<f32>(r_5.jac), density_4 * lobe_2.pdf / r_5.jac);
                }
                var _S1227 : vec3<f32> = throughput_6 * vec3<f32>(lobe_2.pdf);
                var _S1228 : f32 = density_4 * lobe_2.pdf;
                throughput_8 = _S1227;
                density_6 = _S1228;
            }
            else
            {
                throughput_8 = throughput_6;
                density_6 = density_4;
            }
            if(replay_1)
            {
                _S1220 = b_3 <= _S958;
            }
            else
            {
                _S1220 = false;
            }
            var _S1229 : bool;
            if(_S1220)
            {
                _S1229 = _S990;
            }
            else
            {
                _S1229 = false;
            }
            var _S1230 : bool;
            if(_S1229)
            {
                _S1230 = _S1207;
            }
            else
            {
                _S1230 = false;
            }
            var _S1231 : bool;
            if(_S1230)
            {
                _S1231 = true;
            }
            else
            {
                if(_S1077)
                {
                    _S1231 = !_S1219;
                }
                else
                {
                    _S1231 = false;
                }
            }
            if(_S1231)
            {
                return _S944;
            }
            if(_S1077)
            {
                var _S1232 : vec3<f32> = throughput_8 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1233 : f32 = lobe_2.pdf;
                throughput_9 = _S1232;
                survival_probability_0 = _S1233;
            }
            else
            {
                var _S1234 : vec3<f32> = throughput_8 * max(lobe_2.throughput, _S943);
                throughput_9 = _S1234;
                survival_probability_0 = density_6;
            }
            var _S1235 : bool;
            if(_S1026)
            {
                _S1235 = !_S1039;
            }
            else
            {
                _S1235 = false;
            }
            var _S1236 : bool;
            if(_S1235)
            {
                _S1236 = _S990;
            }
            else
            {
                _S1236 = false;
            }
            var _S1237 : bool;
            if(_S1236)
            {
                _S1237 = _S1207;
            }
            else
            {
                _S1237 = false;
            }
            var chain_throughput_2 : vec3<f32>;
            if(_S1237)
            {
                chain_1 = here_0;
                var _S1238 : u32 = (insertBits((chain_1.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1239 : u32 = select(u32(0), u32(1), _S1018);
                var _S1240 : u32 = (insertBits((_S1238), (_S1239), (u32(21)), (u32(1))));
                chain_1.path = _S1240;
                var _S1241 : f32 = chain_1.jac * lobe_2.pdf;
                chain_1.jac = _S1241;
                chain_1.dir = dir_11;
                chain_throughput_2 = throughput_9;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            var _S1242 : Vertex = Vertex_x24init_0(_S1219, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_1 = _S1242;
            var _S1243 : f32 = lobe_2.pdf;
            var _S1244 : bool;
            if(_S1203)
            {
                _S1244 = (_S1015.x) == (_S1015.y);
            }
            else
            {
                _S1244 = false;
            }
            var _S1245 : f32 = select(_S1243, sky_pdf_1, _S1244);
            var _S1246 : bool;
            if(refracted_4)
            {
                _S1246 = !_S1127;
            }
            else
            {
                _S1246 = false;
            }
            var is_inside_6 : bool;
            if(_S1246)
            {
                var _S1247 : bool = !is_inside_5;
                is_inside_6 = _S1247;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_3.unit_direction = dir_11;
            var _S1248 : Surface = surface_5;
            var _S1249 : f32 = select(_S1248.geometry_offset, 0.0f, straight_0);
            var _S1250 : vec3<f32> = (vec3<f32>(0) - _S991.smooth_n);
            var _S1251 : bool = is_inside_6 != _S1127;
            var _S1252 : vec3<f32> = select(_S991.smooth_n, _S1250, _S1251);
            var _S1253 : vec3<f32> = ray_3.origin + vec3<f32>(_S1249) * _S1252;
            ray_3.origin = _S1253;
            chain_throughput_1 = chain_throughput_2;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_3 = throughput_9;
            density_6 = survival_probability_0;
            sky_pdf_1 = _S1245;
        }
        else
        {
            prev_1.rough = false;
            prev_1.pdf = 0.0f;
            straight_0 = false;
            throughput_3 = throughput_6;
            density_6 = density_4;
            sky_pdf_1 = 0.0f;
        }
        if(_S1026)
        {
            if(_S968)
            {
                var _S1254 : vec3<f32> = pathColor(throughput_3 * emission_1, spectral_weight_1, wavelength_9);
                var candidate_6 : Reservoir = chain_1;
                var _S1255 : u32 = (extractBits((chain_1.path), (u32(10)), (u32(2))));
                var _S1256 : bool = _S1255 == u32(1);
                if(_S1256)
                {
                    var _S1257 : vec3<f32> = safeDivide(_S1254, chain_throughput_1);
                    candidate_6.radiance = _S1257;
                }
                var _S1258 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1254);
                offer(&((*sel_2)), _S1258, _S1254 * vec3<f32>(scale_2) / vec3<f32>(density_6));
            }
            if(_S968)
            {
                _S1077 = true;
            }
            else
            {
                _S1077 = scatter_0;
            }
            if(_S1077)
            {
                var _S1259 : f32 = survivalProbability(abs(throughput_3), density_6);
                survival_probability_0 = _S1259;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1260 : u32 = (uniforms_uint.max_bounces);
            var _S1261 : bool = b_3 >= _S1260;
            if(_S1261)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1262 : bool = survival_probability_0 < 1.0f;
                if(_S1262)
                {
                    var _S1263 : u32 = noiseAddress(r_5.seed, b_3);
                    var _S1264 : Random = draw(_S1263, u32(8));
                    wrong_side_0 = survival_probability_0 < (_S1264.value);
                }
                else
                {
                    wrong_side_0 = false;
                }
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1265 : f32 = density_6 * survival_probability_0;
            density_3 = _S1265;
        }
        else
        {
            density_3 = density_6;
        }
        var _S1266 : Ray = ray_3;
        var _S1267 : f32 = distance(reconnection_0, ray_3.origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S1077 = _S1054;
        }
        else
        {
            _S1077 = false;
        }
        if(_S1077)
        {
            wrong_side_0 = _S947 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1268 : f32 = select(4.294967296e+09f, _S1267, wrong_side_0);
        var _S1269 : Hit;
        if(straight_0)
        {
            _S1269 = hit_2;
        }
        else
        {
            _S1269 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1270 : Hit = (traverseInstanceBVH((_S1266), (_S974), (_S1268), (_S1269)));
        hit_2 = _S1270;
        if(replay_1)
        {
            refracted_4 = _S1054;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S1078 = _S947 == u32(1);
        }
        else
        {
            _S1078 = false;
        }
        if(_S1078)
        {
            _S1079 = (hit_2.instance_index) == (_S959.instance_index);
        }
        else
        {
            _S1079 = false;
        }
        if(_S1079)
        {
            _S1124 = (hit_2.triangle_index) == (_S959.triangle_index);
        }
        else
        {
            _S1124 = false;
        }
        if(_S1124)
        {
            hit_2.uv = _S959.uv;
            var _S1271 : f32 = distance(reconnection_0, ray_3.origin);
            hit_2.distance = _S1271;
        }
        if(replay_1)
        {
            _S1125 = _S1054;
        }
        else
        {
            _S1125 = false;
        }
        if(_S1125)
        {
            _S1126 = _S947 == u32(3);
        }
        else
        {
            _S1126 = false;
        }
        if(_S1126)
        {
            _S1127 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S1127 = false;
        }
        if(_S1127)
        {
            return _S944;
        }
        var _S1272 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1272)
        {
            var _S1273 : Shift = escape_0(r_5, replay_1, _S958, _S947, _S945, _S948, scale_2, _S967, chain_1, chain_throughput_1, b_3, ray_3, throughput_3, density_3, prev_1, nee_vertex_1, sky_pdf_1, spectral_weight_1, wavelength_9, &((*sel_2)));
            return _S1273;
        }
        var _S1274 : Hit = hit_2;
        var _S1275 : vec3<f32> = ray_3.origin + vec3<f32>(_S1274.distance) * ray_3.unit_direction;
        ray_3.origin = _S1275;
        var _S1276 : u32 = b_3 + u32(1);
        b_3 = _S1276;
    }
    return _S944;
}

fn shift_0( dom_2 : Domain,  r_6 : Reservoir) -> Shift
{
    var _S1277 : vec3<f32> = vec3<f32>(0.0f);
    var _S1278 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1277, 0.0f, vec4<u32>(u32(0)), _S1277, _S1277), 0.0f, _S1277, u32(0));
    var sel_3 : Selection = _S1278;
    var _S1279 : bool = (r_6.w) <= 0.0f;
    if(_S1279)
    {
        return Shift_x24init_0(_S1277, 0.0f);
    }
    var _S1280 : Shift = walk_0(dom_2, r_6, true, 0.0f, &(sel_3));
    return _S1280;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S1281 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S1281;
    var start_4 : u32 = u32(0);
    loop
    {
        if(bin_0 < u32(40))
        {
        }
        else
        {
            break;
        }
        var _S1282 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S1283 : u32 = (_S1282 + u32(63)) / u32(64);
        var _S1284 : bool = group_0 < _S1283;
        if(_S1284)
        {
            var _S1285 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S1286 : bool = _S1285 < _S1282;
            if(_S1286)
            {
                var _S1287 : u32 = (queued_shifts[(u32(83) + start_4 + _S1285)]);
                return _S1287;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S1283;
        var start_5 : u32 = start_4 + _S1282;
        var bin_1 : u32 = bin_0 + u32(1);
        bin_0 = bin_1;
        group_0 = group_1;
        start_4 = start_5;
    }
    return u32(4294967295);
}

var<workgroup> bin_jobs_0 : array<atomic<u32>, i32(40)>;

var<workgroup> bin_offsets_0 : array<u32, i32(40)>;

fn queueShifts_0( p_8 : vec2<i32>,  bins_1 : array<u32, i32(3)>,  global_invocation_id_0 : vec3<u32>,  local_invocation_index_1 : u32)
{
    var _S1288 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
    var slots_0 : array<u32, i32(3)>;
    slots_0[i32(0)] = u32(0);
    slots_0[i32(1)] = u32(0);
    slots_0[i32(2)] = u32(0);
    var t_5 : u32 = u32(0);
    loop
    {
        if(t_5 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1289 : u32 = t_5;
        var _S1290 : bool = (bins_1[t_5]) < u32(40);
        if(_S1290)
        {
            var _S1291 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S1289]]), u32(1));
            slots_0[t_5] = _S1291;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S1292 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S1292)
    {
        var _S1293 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S1294 : bool = _S1293 > u32(0);
        if(_S1294)
        {
            bin_2 = u32(0);
            groups_0 = u32(0);
            loop
            {
                if(bin_2 < local_invocation_index_1)
                {
                }
                else
                {
                    break;
                }
                var _S1295 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S1295;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S1296 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S1293)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S1296;
        }
    }
    workgroupBarrier();
    t_5 = u32(0);
    loop
    {
        if(t_5 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1297 : u32 = t_5;
        var _S1298 : bool = (bins_1[t_5]) < u32(40);
        if(_S1298)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S1297]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S1299 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S1299)
    {
        bin_2 = u32(0);
        groups_0 = u32(0);
        loop
        {
            if(bin_2 < u32(40))
            {
            }
            else
            {
                break;
            }
            var _S1300 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S1300 + u32(63)) / u32(64);
            var bin_4 : u32 = bin_2 + u32(1);
            bin_2 = bin_4;
            groups_0 = groups_1;
        }
        shift_queue.dispatch = array<u32, 3>((min(groups_0, u32(65535))), ((groups_0 + u32(65534)) / u32(65535)), (u32(1)));
    }
    return;
}

fn project_0( view_0 : mat3x3<f32>,  camera_0 : vec3<f32>,  position_0 : vec3<f32>) -> vec2<f32>
{
    var _S1301 : vec3<f32> = (((view_0) * (position_0 - camera_0)));
    var _S1302 : vec2<f32> = vec2<f32>(0.5f);
    var _S1303 : vec2<f32> = _S1301.xy / vec2<f32>(_S1301.z) * _S1302 + _S1302;
    var _S1304 : vec2<f32> = vec2<f32>(_S1303.x, 1.0f - _S1303.y);
    var _S1305 : vec2<u32> = (uniforms_uint.render_size);
    return _S1304 * vec2<f32>(_S1305);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S1306 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S1307 : bool;
    if(_S1306)
    {
        var _S1308 : vec2<u32> = (uniforms_uint.render_size);
        _S1307 = (all((q_0 < vec2<i32>(_S1308))));
    }
    else
    {
        _S1307 = false;
    }
    if(_S1307)
    {
        var _S1309 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S1307 = (bitcast<f32>((_S1309.w))) > 0.0f;
    }
    else
    {
        _S1307 = false;
    }
    return _S1307;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S1310 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S1311 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1312 : vec2<f32> = project_0(_S1310, _S1311, dom_3.x1);
    var _S1313 : vec2<i32> = vec2<i32>(floor(_S1312));
    var _S1314 : bool = previousValid_0(_S1313);
    var _S1315 : bool = !_S1314;
    if(_S1315)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1316 : Domain = (previousDomain((_S1313)));
    var _S1317 : bool = (_S1316.hit.instance_index) == (dom_3.hit.instance_index);
    var _S1318 : bool;
    if(_S1317)
    {
        var _S1319 : f32 = distance(_S1316.x1, dom_3.x1);
        var _S1320 : f32 = dom_3.hit.distance * 8.0f;
        var _S1321 : vec2<u32> = (uniforms_uint.render_size);
        _S1318 = _S1319 <= (_S1320 / f32(_S1321.x));
    }
    else
    {
        _S1318 = false;
    }
    if(_S1318)
    {
        return _S1313;
    }
    var _S1322 : vec2<f32> = vec2<f32>(p_9 + _S1313) + vec2<f32>(1.0f);
    var _S1323 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S1324 : vec3<f32> = (uniforms_float.camera_position);
    var _S1325 : vec2<f32> = project_0(_S1323, _S1324, _S1316.x1);
    var _S1326 : vec2<i32> = vec2<i32>(floor(_S1322 - _S1325));
    var _S1327 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1328 : bool = previousValid_0(_S1326);
    var _S1329 : vec2<i32> = select(_S1327, _S1326, _S1328);
    return _S1329;
}

fn sameDomain_0( a_6 : Domain,  b_4 : Domain) -> bool
{
    var _S1330 : bool = (all(((a_6.x0) == (b_4.x0))));
    var _S1331 : bool;
    if(_S1330)
    {
        _S1331 = (a_6.hit.instance_index) == (b_4.hit.instance_index);
    }
    else
    {
        _S1331 = false;
    }
    if(_S1331)
    {
        _S1331 = (a_6.hit.triangle_index) == (b_4.hit.triangle_index);
    }
    else
    {
        _S1331 = false;
    }
    if(_S1331)
    {
        _S1331 = (all(((a_6.hit.uv) == (b_4.hit.uv))));
    }
    else
    {
        _S1331 = false;
    }
    return _S1331;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1332 : vec3<f32> = vec3<f32>(0.0f);
    var _S1333 : Domain = Domain_x24init_0(_S1332, _S1332, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1333;
    var _S1334 : bool = t_8 > u32(1);
    var _S1335 : bool;
    if(_S1334)
    {
        _S1335 = true;
    }
    else
    {
        var _S1336 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1335 = !_S1336;
    }
    if(_S1335)
    {
        return false;
    }
    var _S1337 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1338 : bool = (_S1337.x) < i32(0);
    if(_S1338)
    {
        return false;
    }
    var _S1339 : bool = t_8 == u32(0);
    if(_S1339)
    {
        var _S1340 : Reservoir = (loadReservoir(reservoir_prev, (_S1337)));
        var _S1341 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1340);
        (*job_2) = _S1341;
    }
    else
    {
        var _S1342 : Domain = (previousDomain((_S1337)));
        var _S1343 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1344 : ShiftJob = ShiftJob_x24init_0(_S1342, _S1343);
        (*job_2) = _S1344;
    }
    var _S1345 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1345)
    {
        if(_S1339)
        {
            _S1335 = true;
        }
        else
        {
            var _S1346 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1335 = !_S1346;
        }
    }
    else
    {
        _S1335 = false;
    }
    return _S1335;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1347 : ptr<function, array<u32, i32(3)>>)
{
    var _S1348 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_2 : array<u32, i32(3)>;
    bins_2[i32(0)] = u32(40);
    bins_2[i32(1)] = u32(40);
    bins_2[i32(2)] = u32(40);
    var t_9 : u32 = u32(0);
    loop
    {
        if(t_9 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1349 : vec3<f32> = vec3<f32>(0.0f);
        var _S1350 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1349, _S1349, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1349, 0.0f, vec4<u32>(u32(0)), _S1349, _S1349));
        var job_3 : ShiftJob = _S1350;
        var _S1351 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1351)
        {
            var _S1352 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1352;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1347) = bins_2;
    return;
}

fn countShifts_0( bins_3 : array<u32, i32(3)>,  local_invocation_index_2 : u32)
{
    var t_11 : u32 = u32(0);
    loop
    {
        if(t_11 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1353 : u32 = t_11;
        var _S1354 : bool = (bins_3[t_11]) < u32(40);
        if(_S1354)
        {
            var _S1355 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1353]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1356 : bool = local_invocation_index_2 < u32(40);
    if(_S1356)
    {
        var _S1357 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1358 : bool = _S1357 > u32(0);
        if(_S1358)
        {
            var _S1359 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1357)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1360 : vec2<u32> = global_invocation_id_1.xy;
    var _S1361 : vec2<i32> = vec2<i32>(_S1360 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_4 : u32 = local_invocation_index_3;
    loop
    {
        if(i_4 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S1362 : vec2<i32> = _S1361 + vec2<i32>(i32(i_4 % u32(24)), i32(i_4 / u32(24)));
        var _S1363 : bool = (all((_S1362 >= vec2<i32>(i32(0)))));
        var _S1364 : bool;
        if(_S1363)
        {
            var _S1365 : vec2<u32> = (uniforms_uint.render_size);
            _S1364 = (all((_S1362 < vec2<i32>(_S1365))));
        }
        else
        {
            _S1364 = false;
        }
        if(_S1364)
        {
            var _S1366 : vec4<u32> = (textureLoad(reservoir_prev, (_S1362), (u32(0)), 0));
            var _S1367 : u32 = _S1366.x;
            var _S1368 : bool = (bitcast<f32>((_S1366.z))) > 0.0f;
            var _S1369 : u32 = select(u32(0), _S1367, _S1368);
            seed_2 = _S1369;
        }
        else
        {
            seed_2 = u32(0);
        }
        duplication_seeds_0[i_4] = seed_2;
        var i_5 : u32 = i_4 + u32(64);
        i_4 = i_5;
    }
    workgroupBarrier();
    var _S1370 : u32 = local_invocation_id_0.y;
    var _S1371 : u32 = local_invocation_id_0.x;
    var _S1372 : u32 = duplication_seeds_0[(_S1370 + u32(8)) * u32(24) + _S1371 + u32(8)];
    seed_2 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(seed_2 < u32(17))
        {
        }
        else
        {
            break;
        }
        var x_1 : u32 = u32(0);
        loop
        {
            if(x_1 < u32(17))
            {
            }
            else
            {
                break;
            }
            var _S1373 : bool = (duplication_seeds_0[(_S1370 + seed_2) * u32(24) + _S1371 + x_1]) == _S1372;
            var _S1374 : u32 = select(u32(0), u32(1), _S1373);
            var count_2 : u32 = count_1 + _S1374;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1375 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1376 : bool = _S1372 != u32(0);
    var _S1377 : f32 = select(0.0f, _S1375, _S1376);
    textureStore(duplication_out, (vec2<i32>(_S1360)), 0, (vec4<u32>((bitcast<u32>((_S1377))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_4 : ptr<function, Selection>,  r_7 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_7;
    var _S1378 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1378;
    var _S1379 : f32 = r_7.jac * shifted_0.jac;
    candidate_7.jac = _S1379;
    offer(&((*sel_4)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_7.w));
    return;
}

fn finalize( sel_5 : Selection,  c_2 : f32) -> Reservoir
{
    var r_8 : Reservoir = sel_5.r;
    var _S1380 : f32 = resamplingTarget(r_8.f);
    var _S1381 : f32 = sel_5.w_sum / _S1380;
    var _S1382 : bool = _S1380 > 0.0f;
    var _S1383 : f32 = select(0.0f, _S1381, _S1382);
    r_8.w = _S1383;
    r_8.c = c_2;
    return r_8;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1384 : vec2<u32> = global_invocation_id_2.xy;
    var _S1385 : vec2<i32> = vec2<i32>(_S1384);
    var _S1386 : vec3<f32> = vec3<f32>(0.0f);
    var _S1387 : Domain = Domain_x24init_0(_S1386, _S1386, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1387;
    var _S1388 : bool = (currentDomain((_S1385), &(dom_5)));
    var _S1389 : bool = !_S1388;
    if(_S1389)
    {
        storeReservoir(reservoir_prev_out, (_S1385), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1386, 0.0f, vec4<u32>(u32(0)), _S1386, _S1386)), (dom_5.hit));
        var _S1390 : vec2<f32> = vec2<f32>(_S1384);
        var _S1391 : vec2<u32> = (uniforms_uint.render_size);
        var _S1392 : vec2<f32> = _S1390 / vec2<f32>(_S1391.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1393 : vec3<f32> = vec3<f32>(_S1392, 1.0f);
        var _S1394 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1395 : vec3<f32> = (normalize(((((_S1394) * (_S1393))))));
        var _S1396 : vec3<f32> = environment_0(_S1395);
        textureStore(compute_out, (_S1385), (u32(0)), (vec4<f32>(_S1396, 1.0f)));
        var _S1397 : u32 = (uniforms_uint.is_temporal);
        var _S1398 : bool = _S1397 == u32(1);
        if(_S1398)
        {
            textureStore(compute_out, (_S1385), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1399 : Reservoir = (loadReservoir(reservoir_temp, (_S1385)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1399.c;
    loop
    {
        var _S1400 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1400)
        {
        }
        else
        {
            break;
        }
        var _S1401 : vec2<i32> = partner_0(_S1385, t_13);
        var neighbor_0 : Domain = _S1387;
        var _S1402 : bool = (currentDomain((_S1401), &(neighbor_0)));
        if(_S1402)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1403 : vec4<u32> = (textureLoad(reservoir_temp, (_S1401), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1403.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1404 : f32 = _S1399.c / max(count_3, 1.0f);
    var _S1405 : f32 = resamplingTarget(_S1399.f);
    var _S1406 : bool = count_3 == 0.0f;
    var _S1407 : f32 = select(0.0f, 1.0f, _S1406);
    var _S1408 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1386, 0.0f, vec4<u32>(u32(0)), _S1386, _S1386), 0.0f, _S1386, u32(0));
    var sel_6 : Selection = _S1408;
    var _S1409 : u32 = (uniforms_uint.frame);
    var _S1410 : u32 = hash(_S1409);
    var _S1411 : u32 = global_invocation_id_2.x;
    var _S1412 : vec2<u32> = (uniforms_uint.render_size);
    var _S1413 : u32 = stream(_S1410, _S1411 + _S1412.x * global_invocation_id_2.y);
    var _S1414 : u32 = stream(_S1413, u32(195));
    sel_6.random_state = _S1414;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1407;
    loop
    {
        var _S1415 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1415)
        {
        }
        else
        {
            break;
        }
        var _S1416 : vec2<i32> = partner_0(_S1385, t_13);
        var neighbor_dom_0 : Domain = _S1387;
        var _S1417 : bool = (currentDomain((_S1416), &(neighbor_dom_0)));
        if(_S1417)
        {
            var _S1418 : Reservoir = (loadReservoir(reservoir_temp, (_S1416)));
            var _S1419 : vec4<u32> = (textureLoad(shift_data, (_S1416), (t_13), 0));
            var _S1420 : vec4<f32> = (bitcast<vec4<f32>>((_S1419)));
            var _S1421 : vec4<u32> = (textureLoad(shift_data, (_S1385), (t_13), 0));
            var _S1422 : vec4<f32> = (bitcast<vec4<f32>>((_S1421)));
            var _S1423 : f32 = (_S1418.c + _S1404) / c_sum_0;
            var _S1424 : bool = _S1405 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1424)
            {
                var _S1425 : f32 = _S1423 * _S1404 * _S1405;
                var _S1426 : f32 = _S1404 * _S1405;
                var _S1427 : f32 = resamplingTarget(_S1422.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1425 / (_S1426 + _S1418.c * _S1427);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1428 : f32 = resamplingTarget(_S1418.f);
            var _S1429 : vec3<f32> = _S1420.xyz;
            var _S1430 : Shift = Shift_x24init_0(_S1429, _S1420.w);
            var _S1431 : f32 = _S1423 * _S1418.c * _S1428;
            var _S1432 : f32 = _S1418.c * _S1428;
            var _S1433 : f32 = resamplingTarget(_S1429);
            offerShifted(&(sel_6), _S1418, _S1430, _S1431 / (_S1432 + _S1404 * _S1433));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_6), _S1399, Shift_x24init_0(_S1399.f, 1.0f), canonical_mis_0);
    var _S1434 : Reservoir = finalize(sel_6, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1385), (_S1434), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1385), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1435 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_6.random_state)));
    var _S1436 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1437 : f32 = (sign((dot(_S1436, _S1435.smooth_n))));
    var _S1438 : vec3<f32> = _S1435.material.emissive * vec3<f32>(max(_S1437, 0.0f));
    var _S1439 : vec3<f32> = select(_S1438, _S1386, _S1435.skip);
    var _S1440 : vec3<f32> = clamp(sel_6.color + _S1439, vec3<f32>(-65519.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1385), (u32(0)), (vec4<f32>(_S1440, 1.0f)));
    var _S1441 : u32 = (uniforms_uint.is_temporal);
    var _S1442 : bool = _S1441 == u32(1);
    if(_S1442)
    {
        textureStore(compute_out, (_S1385), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1443 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1444 : bool = _S1443 != u32(4294967295);
    if(_S1444)
    {
        var _S1445 : vec2<i32> = vec2<i32>((vec2<u32>(_S1443, (_S1443 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1446 : vec3<f32> = vec3<f32>(0.0f);
        var _S1447 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1446, _S1446, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1446, 0.0f, vec4<u32>(u32(0)), _S1446, _S1446));
        var shift_job_0 : ShiftJob = _S1447;
        var _S1448 : u32 = (_S1443 >> (u32(28)));
        var _S1449 : bool = spatialJob_0(_S1445, _S1448, &(shift_job_0));
        var _S1450 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1445), (_S1448), (vec4<u32>((bitcast<vec3<u32>>((_S1450.f))), (bitcast<u32>((_S1450.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1451 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1452 : array<u32, i32(3)>;
    spatialBins_0(_S1451, &(_S1452));
    var _S1453 : array<u32, i32(3)> = _S1452;
    var t_16 : u32 = u32(0);
    loop
    {
        if(t_16 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1454 : bool = (_S1453[t_16]) == u32(40);
        if(_S1454)
        {
            textureStore(shift_data_out, (_S1451), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1451, _S1453, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1455 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1455));
    countShifts_0(_S1455, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1456 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1457 : bool = _S1456 != u32(4294967295);
    if(_S1457)
    {
        var _S1458 : vec2<i32> = vec2<i32>((vec2<u32>(_S1456, (_S1456 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1459 : vec3<f32> = vec3<f32>(0.0f);
        var _S1460 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1459, _S1459, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1459, 0.0f, vec4<u32>(u32(0)), _S1459, _S1459));
        var shift_job_1 : ShiftJob = _S1460;
        var _S1461 : u32 = (_S1456 >> (u32(28)));
        var _S1462 : bool = temporalJob_0(_S1458, _S1461, &(shift_job_1));
        var _S1463 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1458), (_S1461), (vec4<u32>((bitcast<vec3<u32>>((_S1463.f))), (bitcast<u32>((_S1463.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1464 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1465 : array<u32, i32(3)>;
    temporalBins_0(_S1464, &(_S1465));
    var _S1466 : array<u32, i32(3)> = _S1465;
    var t_18 : u32 = u32(0);
    loop
    {
        if(t_18 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1467 : bool = (_S1466[t_18]) == u32(40);
        if(_S1467)
        {
            textureStore(temporal_shifts_out, (_S1464), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1464, _S1466, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1468 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1468));
    countShifts_0(_S1468, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1469 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1470 : vec3<f32> = vec3<f32>(0.0f);
    var _S1471 : Domain = Domain_x24init_0(_S1470, _S1470, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1471;
    var _S1472 : bool = (currentDomain((_S1469), &(dom_6)));
    var _S1473 : bool = !_S1472;
    if(_S1473)
    {
        storeReservoir(reservoir_temp_out, (_S1469), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1470, 0.0f, vec4<u32>(u32(0)), _S1470, _S1470)), (dom_6.hit));
        return;
    }
    var _S1474 : Reservoir = (loadReservoir(reservoir_initial, (_S1469)));
    var _S1475 : vec2<i32> = temporalNeighbor_0(_S1469, dom_6);
    var _S1476 : bool = (_S1475.x) >= i32(0);
    var r_9 : Reservoir;
    if(_S1476)
    {
        var _S1477 : Reservoir = (loadReservoir(reservoir_prev, (_S1475)));
        var _S1478 : vec4<u32> = (textureLoad(duplication, (_S1475), 0, 0));
        var _S1479 : f32 = (bitcast<f32>((_S1478.x)));
        var _S1480 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1481 : bool = _S1480 == u32(1);
        var _S1482 : f32 = select(0.0f, _S1479, _S1481);
        var _S1483 : f32 = (mix((20.0f), (1.0f), (pow(_S1482, 0.10000000149011612f))));
        var _S1484 : f32 = min(_S1477.c, _S1483);
        var _S1485 : vec4<u32> = (textureLoad(temporal_shifts, (_S1469), (u32(0)), 0));
        var _S1486 : vec4<f32> = (bitcast<vec4<f32>>((_S1485)));
        var _S1487 : vec4<f32> = vec4<f32>(_S1474.f, 1.0f);
        var _S1488 : Domain = (previousDomain((_S1475)));
        var _S1489 : bool = sameDomain_0(_S1488, dom_6);
        var _S1490 : bool = !_S1489;
        var to_previous_0 : vec4<f32>;
        if(_S1490)
        {
            var _S1491 : vec4<u32> = (textureLoad(temporal_shifts, (_S1469), (u32(1)), 0));
            var _S1492 : vec4<f32> = (bitcast<vec4<f32>>((_S1491)));
            to_previous_0 = _S1492;
        }
        else
        {
            to_previous_0 = _S1487;
        }
        var _S1493 : f32 = resamplingTarget(_S1474.f);
        var _S1494 : f32 = resamplingTarget(_S1477.f);
        var _S1495 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1470, 0.0f, vec4<u32>(u32(0)), _S1470, _S1470), 0.0f, _S1470, u32(0));
        var sel_7 : Selection = _S1495;
        var _S1496 : u32 = (uniforms_uint.frame);
        var _S1497 : u32 = hash(_S1496);
        var _S1498 : u32 = global_invocation_id_7.x;
        var _S1499 : vec2<u32> = (uniforms_uint.render_size);
        var _S1500 : u32 = stream(_S1497, _S1498 + _S1499.x * global_invocation_id_7.y);
        var _S1501 : u32 = stream(_S1500, u32(194));
        sel_7.random_state = _S1501;
        var _S1502 : f32 = _S1474.c * _S1493;
        var _S1503 : f32 = resamplingTarget(to_previous_0.xyz);
        var _S1504 : f32 = _S1502 / (_S1502 + _S1484 * _S1503);
        var _S1505 : f32 = _S1484 * _S1494;
        var _S1506 : vec3<f32> = _S1486.xyz;
        var _S1507 : f32 = resamplingTarget(_S1506);
        var _S1508 : f32 = _S1505 / (_S1505 + _S1474.c * _S1507);
        var _S1509 : vec2<f32> = vec2<f32>(_S1504, _S1508);
        offerShifted(&(sel_7), _S1474, Shift_x24init_0(_S1474.f, 1.0f), _S1504);
        offerShifted(&(sel_7), _S1477, Shift_x24init_0(_S1506, _S1486.w), _S1508);
        var _S1510 : Reservoir = finalize(sel_7, _S1474.c + _S1484);
        r_9 = _S1510;
    }
    else
    {
        r_9 = _S1474;
    }
    storeReservoir(reservoir_temp_out, (_S1469), (r_9), (dom_6.hit));
    return;
}

fn noiseOrigin( p_12 : vec2<u32>,  k_1 : u32) -> u32
{
    var _S1511 : u32 = ((((p_12.x) >> (u32(11)))) | ((((((p_12.y) >> (u32(11)))) << (u32(4))))));
    var _S1512 : vec2<u32> = noiseOffset(u32(8192) + ((k_1 >> (u32(10)))) + ((_S1511 << (u32(20)))));
    var _S1513 : vec2<u32> = ((p_12 + _S1512) & (vec2<u32>(u32(2047))));
    return ((((_S1513.x) | ((((_S1513.y) << (u32(11))))))) | (((((k_1 & (u32(1023)))) << (u32(22))))));
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1514 : vec2<u32> = global_invocation_id_8.xy;
    var _S1515 : vec2<i32> = vec2<i32>(_S1514);
    var _S1516 : vec3<f32> = vec3<f32>(0.0f);
    var _S1517 : Domain = Domain_x24init_0(_S1516, _S1516, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1517;
    var _S1518 : bool = (currentDomain((_S1515), &(dom_7)));
    var _S1519 : bool = !_S1518;
    if(_S1519)
    {
        storeReservoir(reservoir_initial_out, (_S1515), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1516, 0.0f, vec4<u32>(u32(0)), _S1516, _S1516)), (dom_7.hit));
        return;
    }
    var _S1520 : u32 = (uniforms_uint.frame);
    var _S1521 : u32 = hash(_S1520);
    var _S1522 : u32 = global_invocation_id_8.x;
    var _S1523 : vec2<u32> = (uniforms_uint.render_size);
    var _S1524 : u32 = global_invocation_id_8.y;
    var _S1525 : u32 = stream(_S1521, _S1522 + _S1523.x * _S1524);
    var _S1526 : vec2<u32> = (uniforms_uint.render_size);
    var _S1527 : u32 = stream(_S1522 + _S1526.x * _S1524, u32(512));
    var _S1528 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1516, 0.0f, vec4<u32>(u32(0)), _S1516, _S1516);
    var _S1529 : Selection = Selection_x24init_0(_S1528, 0.0f, _S1516, u32(0));
    var initial_0 : Selection = _S1529;
    var _S1530 : u32 = stream(_S1525, u32(193));
    initial_0.random_state = _S1530;
    var i_6 : u32 = u32(0);
    loop
    {
        var _S1531 : u32 = (uniforms_uint.samples);
        if(i_6 < _S1531)
        {
        }
        else
        {
            break;
        }
        var r_10 : Reservoir = _S1528;
        var _S1532 : u32 = (uniforms_uint.frame);
        var _S1533 : u32 = (uniforms_uint.samples);
        var _S1534 : u32 = _S1532 * _S1533 + i_6;
        var _S1535 : u32 = noiseOrigin(_S1514, _S1534);
        r_10.seed = _S1535;
        var _S1536 : u32 = (insertBits((u32(0)), (u32(1)), (u32(24)), (u32(1))));
        var _S1537 : u32 = (insertBits((_S1536), (((_S1527 + _S1534 * u32(2654435769)) >> (u32(25)))), (u32(25)), (u32(7))));
        r_10.path = _S1537;
        var _S1538 : u32 = (uniforms_uint.samples);
        var _S1539 : Shift = walk_0(dom_7, r_10, false, 1.0f / f32(_S1538), &(initial_0));
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    var _S1540 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1515), (_S1540), (dom_7.hit));
    return;
}

fn normal_distribution( state_4 : u32) -> Random
{
    var _S1541 : Random = pcg(state_4);
    var _S1542 : Random = pcg(_S1541.state);
    var _S1543 : f32 = 6.28318548202514648f * _S1541.value;
    var _S1544 : f32 = sqrt(-2.0f * clamp(log(_S1542.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1542.state, _S1544 * cos(_S1543));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_5 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1545 : RandomSphere;
    _S1545.state = state_5;
    _S1545.value = value_1;
    return _S1545;
}

fn random_sphere( state_6 : u32) -> RandomSphere
{
    var _S1546 : Random = normal_distribution(state_6);
    var _S1547 : Random = normal_distribution(_S1546.state);
    var _S1548 : Random = normal_distribution(_S1547.state);
    var _S1549 : vec3<f32> = (normalize((vec3<f32>(_S1546.value, _S1547.value, _S1548.value))));
    return RandomSphere_x24init_0(_S1548.state, _S1549);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_10 : vec3<f32>) -> mat3x3<f32>
{
    var _S1550 : vec3<f32> = p1_0 - p0_0;
    var _S1551 : vec3<f32> = p2_0 - p0_0;
    var _S1552 : vec2<f32> = uv1_0 - uv0_0;
    var _S1553 : vec2<f32> = uv2_0 - uv0_0;
    var _S1554 : f32 = _S1552.x;
    var _S1555 : f32 = _S1553.y;
    var _S1556 : f32 = _S1552.y;
    var _S1557 : f32 = _S1553.x;
    var _S1558 : f32 = _S1554 * _S1555 - _S1556 * _S1557;
    var _S1559 : f32 = 1.0f / _S1558;
    var _S1560 : vec3<f32> = vec3<f32>(_S1559);
    var t_20 : vec3<f32> = (_S1550 * vec3<f32>(_S1555) - _S1551 * vec3<f32>(_S1556)) * _S1560;
    var _S1561 : vec3<f32> = (_S1551 * vec3<f32>(_S1554) - _S1550 * vec3<f32>(_S1557)) * _S1560;
    var _S1562 : vec3<f32> = t_20 - n_10 * vec3<f32>(dot(n_10, t_20));
    var _S1563 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_10);
    var _S1564 : bool = (dot(_S1562, _S1562)) > 0.0f;
    var _S1565 : vec3<f32> = select(_S1563, _S1562, _S1564);
    var _S1566 : vec3<f32> = (normalize((_S1565)));
    var _S1567 : bool = (dot(cross(n_10, _S1566), _S1561)) > 0.0f;
    var t_21 : vec3<f32>;
    if(_S1567)
    {
        var _S1568 : vec3<f32> = ((-(_S1566)));
        t_21 = _S1568;
    }
    else
    {
        t_21 = _S1566;
    }
    var _S1569 : vec3<f32> = cross(n_10, t_21);
    return mat3x3<f32>(t_21, _S1569, n_10);
}

fn tangentToWorldNormalMap( v_12 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_12)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1570 : vec3<f32> = t1_0 - t0_0;
    var _S1571 : vec3<f32> = t2_2 - t0_0;
    var _S1572 : vec3<f32> = t2_2 - t1_0;
    var _S1573 : f32 = min(length(_S1570), min(length(_S1571), length(_S1572)));
    var _S1574 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1575 : vec3<f32> = (normalize((n0_0)));
    var _S1576 : f32 = dot(geometry_n_4, _S1575);
    var _S1577 : vec3<f32> = (normalize((n1_0)));
    var _S1578 : f32 = dot(geometry_n_4, _S1577);
    var _S1579 : vec3<f32> = (normalize((n2_0)));
    var _S1580 : vec3<f32> = acos(abs(vec3<f32>(_S1576, _S1578, dot(geometry_n_4, _S1579))));
    var _S1581 : vec3<f32> = clamp(tan(_S1580), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1574 * _S1581, uvw_0), 0.0f, _S1573 * 0.125f);
}

fn straightThrough( material_27 : Material) -> vec3<f32>
{
    return vec3<f32>((material_27.transmission * (1.0f - material_27.metallic))) * material_27.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_28 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var through_1 : vec3<f32>;
    if((material_28.ior) == 1.0f)
    {
        var _S1582 : vec3<f32> = straightThrough(material_28);
        through_1 = _S1582;
    }
    else
    {
        through_1 = vec3<f32>(0.0f);
    }
    var _S1583 : CoatFrame = coatFrame(material_28, n_11);
    var _S1584 : bool = (_S1583.ior) > 0.0f;
    if(_S1584)
    {
        var _S1585 : f32 = fresnel(abs(dot(_S1583.normal, toward_1)), 1.0f, _S1583.ior);
        var _S1586 : vec3<f32> = (mix((vec3<f32>(1.0f)), (vec3<f32>((1.0f - _S1585)) * material_28.coat_tint), (material_28.coat)));
        var through_2 : vec3<f32> = through_1 * _S1586;
        through_1 = through_2;
    }
    return through_1 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_11 : Reservoir,  replay_2 : bool,  scale_3 : f32,  sel_8 : ptr<function, Selection>) -> Shift
{
    var _S1587 : Shift = walk_0(dom_8, r_11, replay_2, scale_3, &((*sel_8)));
    return _S1587;
}

fn restir_initial_hook( global_invocation_id_9 : vec3<u32>)
{
    restir_initial_0(global_invocation_id_9);
    return;
}

fn restir_temporal_hook( global_invocation_id_10 : vec3<u32>)
{
    restir_temporal_0(global_invocation_id_10);
    return;
}

fn restir_temporal_count_hook( global_invocation_id_11 : vec3<u32>,  local_invocation_index_10 : u32)
{
    restir_temporal_count_0(global_invocation_id_11, local_invocation_index_10);
    return;
}

fn restir_temporal_prepass_hook( global_invocation_id_12 : vec3<u32>,  local_invocation_index_11 : u32)
{
    restir_temporal_prepass_0(global_invocation_id_12, local_invocation_index_11);
    return;
}

fn restir_temporal_shift_hook( workgroup_id_3 : vec3<u32>,  local_invocation_index_12 : u32)
{
    restir_temporal_shift_0(workgroup_id_3, local_invocation_index_12);
    return;
}

fn restir_count_hook( global_invocation_id_13 : vec3<u32>,  local_invocation_index_13 : u32)
{
    restir_count_0(global_invocation_id_13, local_invocation_index_13);
    return;
}

fn restir_prepass_hook( global_invocation_id_14 : vec3<u32>,  local_invocation_index_14 : u32)
{
    restir_prepass_0(global_invocation_id_14, local_invocation_index_14);
    return;
}

fn restir_shift_hook( workgroup_id_4 : vec3<u32>,  local_invocation_index_15 : u32)
{
    restir_shift_0(workgroup_id_4, local_invocation_index_15);
    return;
}

fn restir_spatial_hook( global_invocation_id_15 : vec3<u32>)
{
    restir_spatial_0(global_invocation_id_15);
    return;
}

fn restir_duplicates_hook( global_invocation_id_16 : vec3<u32>,  local_invocation_id_1 : vec3<u32>,  local_invocation_index_16 : u32)
{
    restir_duplicates_0(global_invocation_id_16, local_invocation_id_1, local_invocation_index_16);
    return;
}

fn noiseWhite( x_3 : u32,  y_1 : u32,  t_22 : u32,  size_0 : u32) -> u32
{
    var ranks_0 : array<u32, i32(4)>;
    var i_8 : u32 = u32(0);
    loop
    {
        if(i_8 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S1588 : u32 = size_0 - u32(1);
        var _S1589 : u32 = ((x_3 + size_0 / u32(2)) & (_S1588));
        var _S1590 : bool = i_8 < u32(2);
        var _S1591 : u32 = select(_S1589, x_3, _S1590);
        var l_3 : u32 = _S1591;
        var r_12 : u32 = y_1;
        var k_2 : u32 = u32(0);
        loop
        {
            if(k_2 < u32(4))
            {
            }
            else
            {
                break;
            }
            var _S1592 : u32 = hash((((((r_12 ^ (((t_22 << (u32(16))))))) ^ (((k_2 << (u32(28))))))) ^ (((((i_8 & (u32(1)))) << (u32(31)))))));
            var _S1593 : u32 = (l_3 ^ (((_S1592 & (_S1588)))));
            var k_3 : u32 = k_2 + u32(1);
            l_3 = r_12;
            r_12 = _S1593;
            k_2 = k_3;
        }
        var _S1594 : u32 = l_3 + r_12 * size_0;
        var _S1595 : u32 = size_0 * size_0;
        var _S1596 : u32;
        if(_S1595 >= u32(65536))
        {
            var _S1597 : u32 = _S1594 / (_S1595 / u32(65536));
            _S1596 = _S1597;
        }
        else
        {
            var _S1598 : u32 = u32(65536) / _S1595;
            _S1596 = _S1594 * _S1598;
        }
        ranks_0[i_8] = _S1596;
        var i_9 : u32 = i_8 + u32(1);
        i_8 = i_9;
    }
    var _S1599 : bool = (ranks_0[i32(0)]) == u32(65535);
    var _S1600 : bool;
    if(_S1599)
    {
        _S1600 = (ranks_0[i32(1)]) == u32(65535);
    }
    else
    {
        _S1600 = false;
    }
    var _S1601 : bool = (ranks_0[i32(2)]) == u32(65535);
    var _S1602 : bool;
    if(_S1601)
    {
        _S1602 = (ranks_0[i32(3)]) == u32(65535);
    }
    else
    {
        _S1602 = false;
    }
    if(_S1600)
    {
        _S1600 = (ranks_0[i32(3)]) != u32(65535);
    }
    else
    {
        _S1600 = false;
    }
    if(_S1600)
    {
        _S1600 = true;
    }
    else
    {
        if(_S1602)
        {
            _S1600 = (ranks_0[i32(1)]) != u32(65535);
        }
        else
        {
            _S1600 = false;
        }
    }
    var _S1603 : u32 = ranks_0[i32(0)];
    var _S1604 : u32 = ranks_0[i32(1)];
    var _S1605 : u32 = ranks_0[i32(3)];
    var _S1606 : u32 = select(_S1604, _S1605, _S1600);
    return (_S1603 | (((_S1606 << (u32(16))))));
}

fn noiseBlock( sweep_0 : u32,  colour_0 : u32,  block_0 : u32,  size_1 : u32) -> vec3<u32>
{
    var _S1607 : u32 = hash(sweep_0 * u32(7919) + u32(1));
    var _S1608 : u32 = size_1 / u32(16);
    var _S1609 : u32 = block_0 % _S1608;
    var _S1610 : u32 = block_0 / _S1608;
    var _S1611 : u32 = _S1610 % _S1608;
    var _S1612 : u32 = block_0 / (_S1608 * _S1608);
    var _S1613 : vec3<u32> = vec3<u32>(_S1609, _S1611, _S1612);
    var _S1614 : vec3<u32> = vec3<u32>((colour_0 & (u32(1))), (((colour_0 >> (u32(1)))) & (u32(1))), (colour_0 >> (u32(2))));
    return _S1613 * vec3<u32>(u32(16)) + _S1614 * vec3<u32>(u32(8)) + vec3<u32>((_S1607 & (u32(7))), (((_S1607 >> (u32(3)))) & (u32(7))), (((_S1607 >> (u32(6)))) & (u32(7))));
}

