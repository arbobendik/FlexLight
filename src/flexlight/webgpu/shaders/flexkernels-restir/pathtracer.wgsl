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
    var _S67 : f32;
    if(_S66)
    {
        _S67 = 1.0f;
    }
    else
    {
        _S67 = -1.0f;
    }
    return _S67;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S68 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S69 : vec3<f32> = vec3<f32>(_S68);
    return Surface_x24init_0(surface_0.smooth_n * _S69, surface_0.geometry_n * _S69, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

fn upsample( rgb_0 : vec3<f32>,  wavelength_0 : f32) -> f32
{
    var _S70 : f32 = dot(vec3<f32>(-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    var _S71 : f32 = dot(vec3<f32>(0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    var _S72 : f32 = dot(vec3<f32>(1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    var _S73 : vec3<f32> = vec3<f32>(_S70, _S71, _S72);
    var _S74 : f32 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    var _S75 : f32 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S70 + _S71 * exp(-0.5f * _S74 * _S74) + _S72 * exp(-0.5f * _S75 * _S75);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S76 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S76));
}

fn dispersive( material_1 : Material) -> bool
{
    var _S77 : bool = (material_1.dispersion) > 0.0f;
    var _S78 : bool;
    if(_S77)
    {
        _S78 = (material_1.ior) != 1.0f;
    }
    else
    {
        _S78 = false;
    }
    return _S78;
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S79 : u32 = hash(index_0);
    var _S80 : u32 = hash((seed_1 ^ (_S79)));
    return _S80;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S81 : Random;
    _S81.state = state_0;
    _S81.value = value_0;
    return _S81;
}

fn pcg( state_1 : u32) -> Random
{
    var _S82 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S83 : u32 = hash(state_1);
    return Random_x24init_0(_S82, f32(_S83) / 4.294967296e+09f);
}

var<private> WAVELENGTH_CDF_0 : array<f32, i32(81)> = array<f32, i32(81)>( 0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996000528335571f, 0.99997997283935547f, 0.99998998641967773f, 0.99998998641967773f, 0.99998998641967773f, 1.0f, 1.0f, 1.0f, 1.0f );
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
        var _S84 : u32 = (low_0 + high_0 + u32(1)) / u32(2);
        var _S85 : bool = (WAVELENGTH_CDF_0[_S84]) <= u_0;
        if(_S85)
        {
            low_0 = _S84;
        }
        else
        {
            var _S86 : u32 = _S84 - u32(1);
            high_0 = _S86;
        }
    }
    var _S87 : u32 = low_0;
    var _S88 : f32 = WAVELENGTH_CDF_0[low_0 + u32(1)] - WAVELENGTH_CDF_0[low_0];
    return vec2<f32>(0.37999999523162842f + 0.00499999988824129f * (f32(low_0) + (u_0 - WAVELENGTH_CDF_0[_S87]) / _S88), _S88 / 0.00499999988824129f);
}

var<private> WAVELENGTH_WEIGHTS_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f );
fn wavelengthWeights( wavelength_1 : f32) -> vec3<f32>
{
    var _S89 : f32 = clamp((wavelength_1 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S90 : u32 = min(u32(_S89), u32(79));
    var _S91 : u32 = u32(3) * _S90;
    var _S92 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S91], WAVELENGTH_WEIGHTS_0[_S91 + u32(1)], WAVELENGTH_WEIGHTS_0[_S91 + u32(2)]);
    var _S93 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S91 + u32(3)], WAVELENGTH_WEIGHTS_0[_S91 + u32(4)], WAVELENGTH_WEIGHTS_0[_S91 + u32(5)]);
    return _S92 + (_S93 - _S92) * vec3<f32>((_S89 - f32(_S90)));
}

fn atWavelength( material_2 : Material,  wavelength_2 : f32) -> Material
{
    var at_0 : Material = material_2;
    var _S94 : f32 = upsample(material_2.albedo, wavelength_2);
    var _S95 : vec3<f32> = vec3<f32>(_S94);
    at_0.albedo = _S95;
    var _S96 : f32 = upsample(material_2.emissive, wavelength_2);
    var _S97 : vec3<f32> = vec3<f32>(_S96);
    at_0.emissive = _S97;
    var _S98 : f32 = upsample(material_2.absorption, wavelength_2);
    var _S99 : vec3<f32> = vec3<f32>(_S98);
    at_0.absorption = _S99;
    var _S100 : f32 = upsample(material_2.specular_tint, wavelength_2);
    var _S101 : vec3<f32> = vec3<f32>(_S100);
    at_0.specular_tint = _S101;
    var _S102 : f32 = upsample(material_2.translucent, wavelength_2);
    var _S103 : vec3<f32> = vec3<f32>(_S102);
    at_0.translucent = _S103;
    var _S104 : f32 = upsample(material_2.sheen, wavelength_2);
    var _S105 : vec3<f32> = vec3<f32>(_S104);
    at_0.sheen = _S105;
    var _S106 : f32 = upsample(material_2.coat_tint, wavelength_2);
    var _S107 : vec3<f32> = vec3<f32>(_S106);
    at_0.coat_tint = _S107;
    return at_0;
}

fn pathMaterial( material_3 : Material,  wavelength_3 : f32) -> Material
{
    var _S108 : Material;
    if(wavelength_3 > 0.0f)
    {
        var _S109 : Material = atWavelength(material_3, wavelength_3);
        _S108 = _S109;
    }
    else
    {
        _S108 = material_3;
    }
    return _S108;
}

fn dispersedIor( ior_1 : f32,  dispersion_1 : f32,  wavelength_4 : f32) -> f32
{
    var _S110 : f32 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    var _S111 : f32 = _S110 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    var _S112 : bool = dispersion_1 > 0.0f;
    var _S113 : f32 = select(0.0f, _S111, _S112);
    return ior_1 + _S113;
}

fn vertexEta( material_4 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S114 : bool = n_dot_v_0 < 0.0f;
    var _S115 : f32 = select(1.0f, material_4.ior, _S114);
    var _S116 : f32 = select(material_4.ior, 1.0f, _S114);
    return vec2<f32>(_S115, _S116);
}

fn wavelengthEta( material_5 : Material,  n_dot_v_1 : f32,  wavelength_5 : f32) -> vec2<f32>
{
    var refractive_0 : Material = material_5;
    var _S117 : f32 = dispersedIor(material_5.ior, material_5.dispersion, wavelength_5);
    var _S118 : bool = wavelength_5 > 0.0f;
    var _S119 : f32 = select(material_5.ior, _S117, _S118);
    refractive_0.ior = _S119;
    var _S120 : vec2<f32> = vertexEta(refractive_0, n_dot_v_1);
    return _S120;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S121 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S122 : f32 = eta_i_0 / eta_o_0 * _S121;
    var _S123 : bool = _S122 < 1.0f;
    var kr_0 : f32;
    if(_S123)
    {
        var _S124 : f32 = sqrt(max(0.0f, 1.0f - _S122 * _S122));
        var _S125 : f32 = eta_o_0 * cos_theta_0;
        var _S126 : f32 = eta_i_0 * _S124;
        var _S127 : f32 = (_S125 - _S126) / (_S125 + _S126);
        var _S128 : f32 = eta_i_0 * cos_theta_0;
        var _S129 : f32 = eta_o_0 * _S124;
        var _S130 : f32 = (_S128 - _S129) / (_S128 + _S129);
        var _S131 : f32 = (_S127 * _S127 + _S130 * _S130) / 2.0f;
        kr_0 = _S131;
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

fn neeDecision( material_6 : Material,  n_dot_v_2 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> bool
{
    var _S132 : f32 = fresnel(abs(n_dot_v_2), eta_i_1, eta_o_1);
    var _S133 : vec3<f32> = (mix((vec3<f32>(_S132)), (material_6.albedo), (material_6.metallic)));
    var _S134 : f32 = rgb_to_greyscale(_S133);
    var _S135 : f32 = max((1.0f - _S134) * (1.0f - material_6.metallic) * (1.0f - material_6.transmission), 0.0f);
    var _S136 : bool = _S135 > 0.03999999910593033f;
    var _S137 : bool;
    if(_S136)
    {
        _S137 = true;
    }
    else
    {
        _S137 = (material_6.roughness) > 0.20000000298023224f;
    }
    return _S137;
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
    var _S138 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S139 : bool = cos_a_0 > cos_b_0;
    var _S140 : f32 = select(_S138, 1.0f, _S139);
    return _S140;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S141 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S142 : vec3<f32> = node_0.high - node_0.low;
    var _S143 : vec3<f32> = p_3 - _S141;
    var _S144 : vec3<f32> = (normalize((_S143)));
    var _S145 : f32 = dot(_S143, _S143);
    var _S146 : f32 = dot(_S142, _S142) / 4.0f;
    var _S147 : f32 = abs(dot(node_0.w, _S144));
    var _S148 : f32 = sine(node_0.cos_theta_o);
    var _S149 : f32 = sqrt(max(1.0f - _S146 / _S145, 0.0f));
    var _S150 : bool = _S145 < _S146;
    var _S151 : f32 = select(_S149, -1.0f, _S150);
    var _S152 : f32 = sine(_S151);
    var _S153 : f32 = sine(_S147);
    var _S154 : f32 = cosSubClamped(_S153, _S147, _S148, node_0.cos_theta_o);
    var _S155 : f32 = sine(_S147);
    var _S156 : f32 = _S155 * node_0.cos_theta_o - _S147 * _S148;
    var _S157 : bool = _S147 > (node_0.cos_theta_o);
    var _S158 : f32 = select(_S156, 0.0f, _S157);
    var _S159 : f32 = cosSubClamped(_S158, _S154, _S152, _S151);
    var _S160 : bool = _S159 <= 0.0f;
    if(_S160)
    {
        return 0.0f;
    }
    var _S161 : f32 = - dot(_S144, normal_0);
    var _S162 : f32 = node_0.phi * _S159 / max(_S145, length(_S142) / 2.0f);
    var _S163 : f32 = sine(_S161);
    var _S164 : f32 = cosSubClamped(_S163, _S161, _S152, _S151);
    var _S165 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S166 : f32 = select(_S164, 1.0f, _S165);
    return max(_S162 * _S166, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S167 : f32 = importance(first_0, p_4, normal_1);
    var _S168 : f32 = importance(second_0, p_4, normal_1);
    var _S169 : vec2<f32> = vec2<f32>(_S167, _S168);
    var _S170 : f32 = _S169[child_0] / (_S167 + _S168);
    var _S171 : bool = (_S169[child_0]) > 0.0f;
    var _S172 : f32 = select(0.0f, _S170, _S171);
    return _S172;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S173 : vec3<f32> = center_0 - p_5;
    var _S174 : f32 = radius_0 * radius_0 / dot(_S173, _S173);
    var _S175 : bool = _S174 >= 1.0f;
    if(_S175)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S174)) / (6.28318548202514648f * _S174);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_3 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S176 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S177 : vec2<u32> = _S176.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S177;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S178 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S178.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S179 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S180 : u32 = n_0 + u32(1);
        var _S181 : LightBounds = (lightBounds((_S180)));
        var _S182 : LightBounds = (lightBounds((_S179)));
        var _S183 : u32 = trail_0.x;
        var _S184 : u32 = (_S183 & (u32(1)));
        var _S185 : f32 = childShare(_S181, _S182, origin_3, smooth_n_2, _S184);
        var probability_2 : f32 = probability_1 * _S185;
        var _S186 : bool = _S184 == u32(1);
        var _S187 : u32 = select(_S180, _S179, _S186);
        var _S188 : u32 = trail_0.y;
        var _S189 : vec2<u32> = vec2<u32>((((_S183 >> (u32(1)))) | (((_S188 << (u32(31)))))), (_S188 >> (u32(1))));
        n_0 = _S187;
        trail_0 = _S189;
        probability_1 = probability_2;
    }
    var _S190 : bool = (((_S176).z == (n_0)));
    var _S191 : bool = !_S190;
    var _S192 : bool;
    if(_S191)
    {
        _S192 = true;
    }
    else
    {
        var _S193 : LightBounds = (lightBounds((n_0)));
        var _S194 : f32 = importance(_S193, origin_3, smooth_n_2);
        _S192 = !(_S194 > 0.0f);
    }
    if(_S192)
    {
        _S192 = true;
    }
    else
    {
        var _S195 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S195)
        {
            _S192 = !((dot(smooth_n_2, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S192 = false;
        }
    }
    if(_S192)
    {
        return 0.0f;
    }
    var _S196 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S197 : bool = (_S196.x) == u32(2);
    if(_S197)
    {
        var _S198 : u32 = _S196.y;
        var _S199 : Light = (lights[(_S198)]);
        var _S200 : Light = (lights[(_S198)]);
        var _S201 : f32 = sphereDensity(_S199.position, _S200.variance, start_1);
        return probability_1 * _S201;
    }
    var _S202 : u32 = _S196.y;
    var _S203 : u32 = ((instance_uint[(_S202) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S204 : mat3x3<f32> = (worldTriangle((_S202), (_S203 + _S196.z)));
    var _S205 : f32 = solidAngle(probability_1, cross(_S204[i32(1)] - _S204[i32(0)], _S204[i32(2)] - _S204[i32(0)]), light_point_0 - start_1);
    return _S205;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S206 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S207 : bool = b_0 > 0.0f;
    var _S208 : f32 = select(1.0f, _S206, _S207);
    return _S208;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S209 : u32 = (lightSlot((hit_1)));
    var _S210 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S209, light_point_1);
    var _S211 : f32 = powerHeuristic(vertex_0.pdf, _S210);
    return _S211;
}

fn pathColor( f_2 : vec3<f32>,  weight_0 : vec3<f32>,  wavelength_6 : f32) -> vec3<f32>
{
    var _S212 : vec3<f32>;
    if(wavelength_6 > 0.0f)
    {
        var _S213 : f32 = upsample(f_2, wavelength_6);
        _S212 = weight_0 * vec3<f32>(_S213);
    }
    else
    {
        _S212 = f_2;
    }
    return _S212;
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_2 : vec3<f32>,  radiance_1 : vec3<f32>,  density_0 : f32,  random_state_2 : u32) -> TreeSample
{
    var _S214 : TreeSample;
    _S214.dir = dir_2;
    _S214.radiance = radiance_1;
    _S214.density = density_0;
    _S214.random_state = random_state_2;
    return _S214;
}

fn isTranslucent_0( material_7 : Material) -> bool
{
    var _S215 : f32 = rgb_to_greyscale(material_7.translucent);
    return _S215 > 0.0f;
}

fn draw( address_0 : u32,  variable_0 : u32) -> Random
{
    var _S216 : u32 = (address_0 >> (u32(22)));
    var _S217 : u32 = _S216 / u32(32);
    var _S218 : vec2<u32> = vec2<u32>((address_0 & (u32(2047))), (((address_0 >> (u32(11)))) & (u32(2047))));
    var _S219 : u32 = (variable_0 & (u32(2147483647)));
    var _S220 : vec2<u32> = noiseOffset(_S219);
    var _S221 : vec2<u32> = _S218 + _S220;
    var _S222 : vec2<u32> = noiseOffset(u32(4096) + _S217);
    var _S223 : vec2<u32> = _S221 + _S222;
    var _S224 : u32 = (fkBlueNoiseSize());
    var _S225 : vec2<u32> = (_S223 & (vec2<u32>((_S224 - u32(1)))));
    var _S226 : u32 = (fkBlueNoise((_S225.x), (_S225.y), ((_S216 + (((_S217 * u32(2654435769)) >> (u32(27))))) % u32(32))));
    var _S227 : bool = ((variable_0 & (u32(2147483648)))) != u32(0);
    var _S228 : u32 = stream(address_0, _S219);
    var _S229 : Random = pcg(_S228);
    var _S230 : f32;
    if(_S226 == u32(4294967295))
    {
        if(_S227)
        {
            var _S231 : Random = pcg(_S229.state);
            _S230 = _S231.value;
        }
        else
        {
            _S230 = _S229.value;
        }
    }
    else
    {
        var _S232 : u32;
        if(_S227)
        {
            _S232 = (_S226 >> (u32(16)));
        }
        else
        {
            _S232 = (_S226 & (u32(65535)));
        }
        _S230 = (f32(_S232) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S230);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S233 : f32 = importance(first_1, p_6, normal_3);
    var _S234 : f32 = importance(second_1, p_6, normal_3);
    var _S235 : vec2<f32> = vec2<f32>(_S233, _S234);
    var _S236 : bool = _S233 == 0.0f;
    var _S237 : bool;
    if(_S236)
    {
        _S237 = _S234 == 0.0f;
    }
    else
    {
        _S237 = false;
    }
    if(_S237)
    {
        return u32(2);
    }
    var _S238 : f32 = _S233 + _S234;
    var _S239 : bool = _S234 > 0.0f;
    if(_S239)
    {
        _S237 = ((*pick_0) * _S238) >= _S233;
    }
    else
    {
        _S237 = false;
    }
    var _S240 : u32 = select(u32(0), u32(1), _S237);
    var _S241 : f32 = min(((*pick_0) * _S238 - f32(_S240) * _S233) / _S235[_S240], 0.99999994039535522f);
    (*pick_0) = _S241;
    var _S242 : f32 = (*probability_3) * (_S235[_S240] / _S238);
    (*probability_3) = _S242;
    return _S240;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S243 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S243)
    {
        const _S244 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S244;
    }
    else
    {
        a_2 = a_1;
    }
    var _S245 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S246 : vec3<f32> = cross(n_1, _S245);
    return vec3<f32>(v_0.x) * _S245 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S246;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S247 : vec3<f32> = center_1 - p_7;
    var _S248 : f32 = radius_1 * radius_1 / dot(_S247, _S247);
    var _S249 : f32 = u1_0 * _S248 / (1.0f + sqrt(max(1.0f - _S248, 0.0f)));
    var _S250 : f32 = 2.0f * u1_0;
    var _S251 : bool = _S248 >= 1.0f;
    var _S252 : f32 = select(_S249, _S250, _S251);
    var _S253 : f32 = sqrt(max(_S252 * (2.0f - _S252), 0.0f));
    var _S254 : f32 = 6.28318548202514648f * u2_0;
    var _S255 : vec3<f32> = vec3<f32>(_S253 * cos(_S254), 1.0f - _S252, _S253 * sin(_S254));
    var _S256 : vec3<f32> = (normalize((_S247)));
    var _S257 : vec3<f32> = tangentToWorld(_S255, _S256);
    return _S257;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S258 : vec3<f32> = center_2 - ray_0.origin;
    var _S259 : f32 = dot(_S258, ray_0.unit_direction);
    var _S260 : f32 = dot(_S258, _S258) - _S259 * _S259;
    var _S261 : f32 = radius_3 * radius_3;
    var _S262 : bool = _S260 > _S261;
    if(_S262)
    {
        return 4.294967296e+09f;
    }
    var _S263 : f32 = sqrt(_S261 - _S260);
    var _S264 : f32 = _S259 - _S263;
    var _S265 : f32 = _S259 + _S263;
    var _S266 : bool = _S264 > 0.0000152587890625f;
    var _S267 : bool;
    if(_S266)
    {
        _S267 = _S264 < max_len_0;
    }
    else
    {
        _S267 = false;
    }
    if(_S267)
    {
        return _S264;
    }
    var _S268 : bool = _S265 > 0.0000152587890625f;
    if(_S268)
    {
        _S267 = _S265 < max_len_0;
    }
    else
    {
        _S267 = false;
    }
    if(_S267)
    {
        return _S265;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_4 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S269 : vec3<f32> = (normalize((light_dir_0)));
    var _S270 : bool = (dot(smooth_n_3, _S269)) < 0.0f;
    if(_S270)
    {
        return vec3<f32>(0.0f);
    }
    var _S271 : vec3<f32> = origin_4 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S272 : Ray = Ray_x24init_0(_S271, _S269);
    var _S273 : f32 = shadowLength(light_dir_0);
    var _S274 : vec3<f32> = (shadowTransmittance((_S272), (_S273)));
    return _S274;
}

fn sampleLightTree_0( origin_5 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S275 : Random = draw(init_random_state_0, u32(4));
    var _S276 : Random = draw(init_random_state_0, u32(5));
    var _S277 : Random = draw(init_random_state_0, u32(2147483653));
    var _S278 : vec3<f32> = vec3<f32>(0.0f);
    var _S279 : TreeSample = TreeSample_x24init_0(_S278, _S278, 0.0f, _S277.state);
    var sample_0 : TreeSample = _S279;
    var _S280 : vec3<f32> = select(smooth_n_4, _S278, sided_0);
    var _S281 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S282 : vec3<f32> = origin_5 + _S281 * smooth_n_4;
    var pick_1 : f32 = _S275.value;
    var probability_4 : f32 = 1.0f;
    var n_2 : u32 = u32(0);
    loop
    {
        var _S283 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
        if((_S283.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S284 : u32 = (access_light_tree(3u + 4u * (n_2)).w);
        var _S285 : u32 = n_2 + u32(1);
        var _S286 : LightBounds = (lightBounds((_S285)));
        var _S287 : LightBounds = (lightBounds((_S284)));
        var _S288 : u32 = pickChild(_S286, _S287, origin_5, _S280, &(pick_1), &(probability_4));
        var _S289 : bool = _S288 > u32(1);
        if(_S289)
        {
            return sample_0;
        }
        var _S290 : bool = _S288 == u32(1);
        var _S291 : u32 = select(_S285, _S284, _S290);
        n_2 = _S291;
    }
    var _S292 : bool = n_2 == u32(0);
    var _S293 : bool;
    if(_S292)
    {
        var _S294 : LightBounds = (lightBounds((u32(0))));
        var _S295 : f32 = importance(_S294, origin_5, _S280);
        _S293 = !(_S295 > 0.0f);
    }
    else
    {
        _S293 = false;
    }
    if(_S293)
    {
        return sample_0;
    }
    var _S296 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
    var _S297 : bool = (_S296.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S297)
    {
        var _S298 : Light = (lights[(_S296.y)]);
        if(sided_0)
        {
            var _S299 : f32 = (sign((dot(geometry_n_1, _S298.position - origin_5))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S299);
            var _S300 : vec3<f32> = origin_5 + _S281 * lift_n_1;
            start_2 = _S300;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S282;
            lift_n_0 = smooth_n_4;
        }
        var _S301 : bool = (_S298.variance) == 0.0f;
        if(_S301)
        {
            var _S302 : vec3<f32> = _S298.position - start_2;
            var _S303 : vec3<f32> = (normalize((_S302)));
            sample_0.dir = _S303;
            var _S304 : vec3<f32> = _S298.color * vec3<f32>(_S298.intensity) / vec3<f32>((dot(_S302, _S302) * probability_4));
            sample_0.radiance = _S304;
            shadow_1 = _S302;
        }
        else
        {
            var _S305 : vec3<f32> = sampleSphere(_S298.position, _S298.variance, start_2, _S276.value, _S277.value);
            sample_0.dir = _S305;
            var _S306 : f32 = sphereDensity(_S298.position, _S298.variance, start_2);
            var _S307 : f32 = probability_4 * _S306;
            sample_0.density = _S307;
            var _S308 : vec3<f32> = pointLightRadiance(_S298.color, _S298.intensity, _S298.variance);
            var _S309 : vec3<f32> = _S308 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S309;
            var _S310 : f32 = raySphere_0(_S298.position, _S298.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S311 : vec3<f32> = sample_0.dir * vec3<f32>(_S310);
            shadow_1 = _S311;
        }
    }
    else
    {
        var _S312 : u32 = _S296.y;
        var _S313 : u32 = ((instance_uint[(_S312) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S314 : u32 = _S313 + _S296.z;
        var _S315 : mat3x3<f32> = (worldTriangle((_S312), (_S314)));
        var _S316 : f32 = sqrt(_S276.value);
        var _S317 : vec2<f32> = vec2<f32>(_S316 * (1.0f - _S277.value), _S316 * _S277.value);
        var _S318 : vec3<f32> = (((_S315) * (vec3<f32>(1.0f - _S316, _S317))));
        if(sided_0)
        {
            var _S319 : f32 = (sign((dot(geometry_n_1, _S318 - origin_5))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S319);
            var _S320 : vec3<f32> = origin_5 + _S281 * lift_n_2;
            start_2 = _S320;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S321 : bool = !((dot(smooth_n_4, _S318 - origin_5)) > 0.0f);
            if(_S321)
            {
                return sample_0;
            }
            start_2 = _S282;
            lift_n_0 = smooth_n_4;
        }
        var _S322 : Surface = (surfaceAt((Hit_x24init_0(_S317, _S312, _S314, u32(0), 0.0f)), (_S318), (_S277.state)));
        sample_0.random_state = _S322.random_state;
        var _S323 : vec3<f32> = _S318 - start_2;
        var _S324 : vec3<f32> = (normalize((_S323)));
        sample_0.dir = _S324;
        var _S325 : f32 = solidAngle(probability_4, cross(_S315[i32(1)] - _S315[i32(0)], _S315[i32(2)] - _S315[i32(0)]), _S323);
        sample_0.density = _S325;
        var _S326 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S322.smooth_n))));
        var _S327 : vec3<f32> = _S322.material.emissive * vec3<f32>(max(_S326, 0.0f));
        var _S328 : vec3<f32> = select(_S327, _S278, _S322.skip);
        var _S329 : vec3<f32> = _S328 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S329;
        shadow_1 = _S323;
    }
    var _S330 : vec3<f32> = lightTransmittance_0(origin_5, lift_n_0, geometry_offset_2, shadow_1);
    var _S331 : vec3<f32> = sample_0.radiance * _S330;
    var _S332 : bool = (all((_S330 == _S278)));
    var _S333 : vec3<f32> = select(_S331, _S278, _S332);
    sample_0.radiance = _S333;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S334 : AnisotropicFrame;
    _S334.tangent = tangent_1;
    _S334.alphas = alphas_0;
    return _S334;
}

fn anisotropicFrame( material_8 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S335 : f32 = material_8.roughness;
    var _S336 : f32 = _S335 * _S335;
    var _S337 : bool = (material_8.anisotropy) == 0.0f;
    var _S338 : bool;
    if(_S337)
    {
        _S338 = true;
    }
    else
    {
        _S338 = !(_S336 > 0.0f);
    }
    if(_S338)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S339 : vec3<f32> = material_8.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_8.tangent));
    var _S340 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S341 : bool = (dot(_S339, _S339)) > 0.0f;
    var _S342 : vec3<f32> = select(_S340, _S339, _S341);
    var _S343 : vec3<f32> = (normalize((_S342)));
    var _S344 : f32 = 6.28318548202514648f * material_8.anisotropic_rotation;
    var _S345 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_8.anisotropy));
    var _S346 : f32 = 1.0f / _S345;
    var _S347 : bool = (material_8.anisotropy) < 0.0f;
    var _S348 : f32 = select(_S345, _S346, _S347);
    return AnisotropicFrame_x24init_0(_S343 * vec3<f32>(cos(_S344)) + cross(n_i_0, _S343) * vec3<f32>(sin(_S344)), vec2<f32>(_S336 / _S348, _S336 * _S348));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S349 : SheenProfile;
    _S349.on = on_0;
    _S349.albedo = albedo_1;
    return _S349;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_9 : Material) -> SheenProfile
{
    var _S350 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S351 : f32 = rgb_to_greyscale(material_9.sheen);
    var _S352 : bool = _S351 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S352)
    {
        var _S353 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S354 : u32 = min(u32(_S353), u32(22));
        var _S355 : f32 = sqrt(0.05000000074505806f);
        var _S356 : f32 = sqrt(0.10000000149011612f);
        var _S357 : bool = (material_9.velvet) > 0.0f;
        var _S358 : f32 = select(_S355, _S356, _S357);
        var _S359 : f32 = (clamp(sqrt(max(material_9.sheen_roughness, 0.0f)), _S358, 1.0f) - _S358) / (1.0f - _S358) * 23.0f;
        var _S360 : u32 = min(u32(_S359), u32(22));
        var _S361 : u32 = _S354 * u32(24) + _S360;
        var _S362 : f32 = _S353 - f32(_S354);
        var _S363 : f32 = _S359 - f32(_S360);
        if(_S357)
        {
            var _S364 : u32 = _S361 + u32(24);
            var _S365 : f32 = VELVET_ALBEDO_0[_S361] + (VELVET_ALBEDO_0[_S364] - VELVET_ALBEDO_0[_S361]) * _S362;
            var _S366 : u32 = _S361 + u32(1);
            var _S367 : f32 = VELVET_ALBEDO_0[_S366] + (VELVET_ALBEDO_0[_S364 + u32(1)] - VELVET_ALBEDO_0[_S366]) * _S362;
            var _S368 : SheenProfile = SheenProfile_x24init_0(true, _S365 + (_S367 - _S365) * _S363);
            profile_0 = _S368;
        }
        else
        {
            var _S369 : u32 = _S361 + u32(24);
            var _S370 : f32 = SHEEN_ALBEDO_0[_S361] + (SHEEN_ALBEDO_0[_S369] - SHEEN_ALBEDO_0[_S361]) * _S362;
            var _S371 : u32 = _S361 + u32(1);
            var _S372 : f32 = SHEEN_ALBEDO_0[_S371] + (SHEEN_ALBEDO_0[_S369 + u32(1)] - SHEEN_ALBEDO_0[_S371]) * _S362;
            var _S373 : SheenProfile = SheenProfile_x24init_0(true, exp(_S370 + (_S372 - _S370) * _S363));
            profile_0 = _S373;
        }
    }
    else
    {
        profile_0 = _S350;
    }
    return profile_0;
}

struct CoatFrame
{
     normal : vec3<f32>,
     alpha : f32,
     ior : f32,
};

fn CoatFrame_x24init_0( normal_4 : vec3<f32>,  alpha_0 : f32,  ior_2 : f32) -> CoatFrame
{
    var _S374 : CoatFrame;
    _S374.normal = normal_4;
    _S374.alpha = alpha_0;
    _S374.ior = ior_2;
    return _S374;
}

fn coatFrame( material_10 : Material,  n_3 : vec3<f32>) -> CoatFrame
{
    var _S375 : CoatFrame = CoatFrame_x24init_0(vec3<f32>(0.0f), 0.0f, 0.0f);
    var _S376 : bool = (material_10.coat) > 0.0f;
    var frame_0 : CoatFrame;
    if(_S376)
    {
        var _S377 : vec3<f32> = material_10.coat_normal;
        var _S378 : bool = (dot(_S377, _S377)) > 0.0f;
        var _S379 : vec3<f32> = (normalize((material_10.coat_normal)));
        var _S380 : vec3<f32> = select(n_3, _S379, _S378);
        var _S381 : f32 = (sign((dot(_S380, n_3))));
        var _S382 : f32 = material_10.coat_roughness;
        var _S383 : CoatFrame = CoatFrame_x24init_0(_S380 * vec3<f32>(_S381), _S382 * _S382, max(material_10.coat_ior, 1.00999999046325684f));
        frame_0 = _S383;
    }
    else
    {
        frame_0 = _S375;
    }
    return frame_0;
}

fn coatSeries( coat_frame_0 : CoatFrame,  material_11 : Material) -> vec3<f32>
{
    var _S384 : vec3<f32> = vec3<f32>(0.0f);
    var _S385 : bool = (coat_frame_0.ior) > 0.0f;
    var series_0 : vec3<f32>;
    if(_S385)
    {
        var _S386 : f32 = coat_frame_0.ior * coat_frame_0.ior;
        var _S387 : f32 = _S386 * _S386;
        var _S388 : f32 = coat_frame_0.ior - 1.0f;
        var _S389 : f32 = coat_frame_0.ior + 1.0f;
        var _S390 : f32 = _S386 - 1.0f;
        var _S391 : f32 = _S386 + 1.0f;
        var _S392 : f32 = _S387 - 1.0f;
        var _S393 : f32 = _S391 * _S392;
        var _S394 : f32 = 0.5f + _S388 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S389 * _S389) + _S386 * _S390 * _S390 / (_S391 * _S391 * _S391) * log(_S388 / _S389) - 2.0f * _S386 * coat_frame_0.ior * (_S386 + 2.0f * coat_frame_0.ior - 1.0f) / _S393 + 8.0f * _S387 * (_S387 + 1.0f) / (_S393 * _S392) * log(coat_frame_0.ior);
        var _S395 : f32 = 1.0f - (1.0f - _S394) / _S386;
        var _S396 : vec3<f32> = material_11.coat_tint;
        var _S397 : vec3<f32> = _S396 * _S396 * vec3<f32>((1.0f - _S395)) / (vec3<f32>(1.0f) - material_11.albedo * vec3<f32>(_S395));
        series_0 = _S397;
    }
    else
    {
        series_0 = _S384;
    }
    return series_0;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_4, t_4)), dot(w_1, n_4));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_1 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S398 : vec3<f32> = (normalize((vec3<f32>(alpha_1 * Ve_0.x, alpha_1 * Ve_0.y, Ve_0.z))));
    var _S399 : f32 = _S398.x;
    var _S400 : f32 = _S398.y;
    var _S401 : f32 = _S399 * _S399 + _S400 * _S400;
    const _S402 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S403 : vec3<f32> = vec3<f32>(- _S400, _S399, 0.0f);
    var _S404 : f32 = (inverseSqrt((_S401)));
    var _S405 : vec3<f32> = _S403 * vec3<f32>(_S404);
    var _S406 : bool = _S401 > 0.0f;
    var _S407 : vec3<f32> = select(_S402, _S405, _S406);
    var _S408 : vec3<f32> = cross(_S398, _S407);
    var _S409 : f32 = sqrt(U1_0);
    var _S410 : f32 = 6.28318548202514648f * U2_0;
    var _S411 : f32 = _S409 * cos(_S410);
    var t2_0 : f32 = _S409 * sin(_S410);
    var _S412 : f32 = 0.5f * (1.0f + _S398.z);
    var t2_1 : f32 = (1.0f - _S412) * sqrt(max(0.0f, 1.0f - _S411 * _S411)) + _S412 * t2_0;
    var _S413 : vec3<f32> = vec3<f32>(_S411) * _S407 + vec3<f32>(t2_1) * _S408;
    var _S414 : f32 = ((_S411));
    var _S415 : f32 = ((_S411));
    var _S416 : vec3<f32> = _S413 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S414 * _S415 - t2_1 * t2_1))) * _S398;
    var _S417 : vec3<f32> = (normalize((vec3<f32>(alpha_1 * _S416.x, alpha_1 * _S416.y, max(0.0f, _S416.z)))));
    return _S417;
}

fn worldToTangent( v_2 : vec3<f32>,  n_5 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S418 : bool = (abs(dot(n_5, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S418)
    {
        const _S419 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S419;
    }
    else
    {
        a_4 = a_3;
    }
    var _S420 : vec3<f32> = (normalize((cross(n_5, a_4))));
    var _S421 : vec3<f32> = cross(n_5, _S420);
    return vec3<f32>(dot(v_2, _S420), dot(v_2, n_5), dot(v_2, _S421));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_2 : f32,  frame_1 : AnisotropicFrame,  random_state_3 : ptr<function, u32>,  first_2 : u32) -> vec3<f32>
{
    var _S422 : Random = draw((*random_state_3), first_2);
    var _S423 : Random = draw((*random_state_3), (first_2 | (u32(2147483648))));
    (*random_state_3) = _S423.state;
    var _S424 : f32 = frame_1.alphas.x;
    var _S425 : bool = _S424 > 0.0f;
    if(_S425)
    {
        var _S426 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S427 : f32 = frame_1.alphas.y;
        var _S428 : vec3<f32> = (normalize((vec3<f32>(_S424 * _S426.x, _S427 * _S426.y, _S426.z))));
        var _S429 : vec3<f32> = sampleGGXVNDF(_S428, 1.0f, _S422.value, _S423.value);
        var _S430 : vec3<f32> = (normalize((vec3<f32>(_S424 * _S429.x, _S427 * _S429.y, _S429.z))));
        return vec3<f32>(_S430.x) * frame_1.tangent + vec3<f32>(_S430.y) * cross(n_i_2, frame_1.tangent) + vec3<f32>(_S430.z) * n_i_2;
    }
    var _S431 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S432 : vec3<f32> = sampleGGXVNDF(_S431.xzy, alpha_2, _S422.value, _S423.value);
    var _S433 : vec3<f32> = _S432.xzy;
    var _S434 : vec3<f32> = tangentToWorld(_S433, n_i_2);
    return _S434;
}

fn coatHalf( v_4 : vec3<f32>,  coat_frame_1 : CoatFrame,  random_state_4 : u32) -> vec3<f32>
{
    var _S435 : bool = !((dot(coat_frame_1.normal, v_4)) > 0.0f);
    if(_S435)
    {
        return vec3<f32>(0.0f);
    }
    var state_2 : u32 = random_state_4;
    var _S436 : vec3<f32> = sampleHalfVector(v_4, coat_frame_1.normal, coat_frame_1.alpha, AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f)), &(state_2), u32(1));
    return _S436;
}

fn sampledHalf( v_5 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_3 : f32,  frame_2 : AnisotropicFrame,  random_state_5 : u32) -> vec3<f32>
{
    var state_3 : u32 = random_state_5;
    var _S437 : vec3<f32> = sampleHalfVector(v_5, n_i_3, alpha_3, frame_2, &(state_3), u32(0));
    return _S437;
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

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S438 : f32 = alpha_4 * alpha_4;
    var _S439 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S438 + (1.0f - _S438) * n_dot_x_0 * n_dot_x_0));
    var _S440 : bool = alpha_4 > 0.0f;
    var _S441 : f32 = select(1.0f, _S439, _S440);
    return _S441;
}

fn coatFresnel( in_dir_0 : vec3<f32>,  v_6 : vec3<f32>,  coat_h_0 : vec3<f32>,  coat_frame_2 : CoatFrame,  eta_i_2 : f32,  behind_0 : bool) -> f32
{
    var _S442 : f32 = dot(coat_frame_2.normal, reflect(in_dir_0, coat_h_0));
    var _S443 : f32 = abs(dot(v_6, coat_h_0));
    var _S444 : f32 = eta_i_2 / coat_frame_2.ior * sqrt(max(1.0f - _S443 * _S443, 0.0f));
    var _S445 : f32 = sqrt(max(1.0f - _S444 * _S444, 0.0f));
    var _S446 : f32 = select(_S443, _S445, behind_0);
    var _S447 : f32 = select(1.0f, coat_frame_2.ior, behind_0);
    var _S448 : f32 = select(coat_frame_2.ior, 1.0f, behind_0);
    var _S449 : f32 = fresnel(_S446, _S447, _S448);
    var _S450 : f32 = smithG1(coat_frame_2.alpha, _S442);
    var _S451 : f32 = _S449 * _S450;
    var _S452 : bool = _S442 > 0.0f;
    var _S453 : f32 = select(0.0f, _S451, _S452);
    return _S453;
}

fn Weights_x24init_0( v_dot_h_0 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  p_sheen_velvet_0 : f32,  p_toon_0 : f32,  sheen_1 : vec3<f32>,  toon_0 : vec3<f32>,  coat_1 : vec3<f32>,  p_coat_0 : f32) -> Weights
{
    var _S454 : Weights;
    _S454.v_dot_h = v_dot_h_0;
    _S454.refracted = refracted_0;
    _S454.F = F_0;
    _S454.reflect_weight = reflect_weight_0;
    _S454.diffuse_weight = diffuse_weight_0;
    _S454.refract_weight = refract_weight_0;
    _S454.p_diffuse = p_diffuse_0;
    _S454.p_reflect = p_reflect_0;
    _S454.p_refract = p_refract_0;
    _S454.p_sheen_velvet = p_sheen_velvet_0;
    _S454.p_toon = p_toon_0;
    _S454.sheen = sheen_1;
    _S454.toon = toon_0;
    _S454.coat = coat_1;
    _S454.p_coat = p_coat_0;
    return _S454;
}

fn lobeWeights( in_dir_1 : vec3<f32>,  v_7 : vec3<f32>,  n_i_4 : vec3<f32>,  ggx_n_0 : vec3<f32>,  coat_h_1 : vec3<f32>,  frame_3 : AnisotropicFrame,  sheen_profile_0 : SheenProfile,  coat_frame_3 : CoatFrame,  coat_series_0 : vec3<f32>,  material_12 : Material,  eta_i_3 : f32,  eta_o_2 : f32) -> Weights
{
    var _S455 : f32 = dot(ggx_n_0, v_7);
    var _S456 : f32 = eta_i_3 / eta_o_2;
    var _S457 : vec3<f32> = (normalize((refract(in_dir_1, ggx_n_0, _S456))));
    var _S458 : f32 = min(sqrt(material_12.specular_level) * abs(eta_i_3 - eta_o_2) / (eta_i_3 + eta_o_2), 0.9999847412109375f);
    var _S459 : f32 = _S458 * _S458;
    var _S460 : f32 = (1.0f + _S458) / (1.0f - _S458);
    var _S461 : f32 = abs(_S455);
    var _S462 : bool = eta_i_3 > eta_o_2;
    var sheen_component_0 : f32;
    if(_S462)
    {
        sheen_component_0 = _S460;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var _S463 : f32;
    if(_S462)
    {
        _S463 = 1.0f;
    }
    else
    {
        _S463 = _S460;
    }
    var _S464 : f32 = fresnel(_S461, sheen_component_0, _S463);
    var _S465 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S455 * _S455)) >= (eta_o_2 * eta_o_2);
    var _S466 : vec3<f32>;
    if(_S465)
    {
        _S466 = vec3<f32>(1.0f);
    }
    else
    {
        var _S467 : vec3<f32> = material_12.specular_tint * vec3<f32>(_S459);
        _S466 = _S467 + (vec3<f32>(1.0f) - _S467) * vec3<f32>((_S464 - _S459)) / vec3<f32>((1.0f - _S459));
    }
    var _S468 : vec3<f32> = vec3<f32>(1.0f);
    var _S469 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S470 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S471 : vec3<f32> = vec3<f32>(1.0f) - material_12.sheen * vec3<f32>(_S470);
        var _S472 : f32 = rgb_to_greyscale(material_12.sheen);
        var _S473 : f32 = _S472 * _S470;
        var _S474 : vec3<f32> = material_12.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S471;
        sheen_component_0 = _S473;
        sheen_2 = _S474;
    }
    else
    {
        scale_0 = _S468;
        sheen_component_0 = 0.0f;
        sheen_2 = _S469;
    }
    var _S475 : bool = (material_12.metallic) > 0.0f;
    var rebounce_0 : vec3<f32>;
    if(_S475)
    {
        var _S476 : f32 = frame_3.alphas.x;
        var _S477 : f32 = sqrt(min(_S476, frame_3.alphas.y));
        var _S478 : bool = _S476 > 0.0f;
        var _S479 : f32 = select(material_12.roughness, _S477, _S478);
        var _S480 : f32 = _S479 * _S479;
        var _S481 : f32 = pow(_S480, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S480) / (1.0f + 1.28094995021820068f * _S480);
        var _S482 : bool = _S480 > 0.0f;
        var _S483 : f32 = select(0.0f, _S481, _S482);
        var _S484 : f32 = clamp(dot(n_i_4, v_7), 0.0f, 1.0f);
        var _S485 : f32 = _S480 * _S479;
        var _S486 : f32 = min(1.00064504146575928f - _S479 * (0.00375499995425344f + _S484 * (-0.04133399948477745f + _S484 * (-0.90938502550125122f + _S484 * 0.35275399684906006f))) - _S480 * (0.27602800726890564f + _S484 * (1.27023398876190186f + _S484 * 0.04740000143647194f)) - _S485 * (0.31452900171279907f - _S484 * 0.34830701351165771f) + _S485 * _S479 * 0.27229699492454529f, 1.0f);
        var _S487 : vec3<f32> = vec3<f32>(1.0f);
        var _S488 : vec3<f32> = min(_S487 / (_S487 - material_12.albedo * vec3<f32>(_S483)), vec3<f32>((1.0f / max(_S486, 0.0000152587890625f))));
        rebounce_0 = _S488;
    }
    else
    {
        rebounce_0 = _S468;
    }
    var _S489 : bool = (dot(coat_h_1, coat_h_1)) > 0.0f;
    var coat_2 : vec3<f32>;
    var up_0 : vec3<f32>;
    var through_0 : vec3<f32>;
    if(_S489)
    {
        var _S490 : f32 = coatFresnel(in_dir_1, v_7, coat_h_1, coat_frame_3, eta_i_3, _S462);
        var _S491 : f32 = material_12.coat * _S490;
        var _S492 : vec3<f32> = material_12.coat_tint;
        var _S493 : vec3<f32> = _S492 * _S492;
        var _S494 : vec3<f32> = select(_S468, _S493, _S462);
        var _S495 : vec3<f32> = vec3<f32>(_S491) * _S494;
        var _S496 : f32 = 1.0f - _S490;
        var _S497 : bool = !_S462;
        var _S498 : vec3<f32> = select(_S468, coat_series_0, _S497);
        var _S499 : vec3<f32> = vec3<f32>(_S496);
        var _S500 : vec3<f32> = (mix((_S468), (_S499 * _S498), (material_12.coat)));
        var _S501 : vec3<f32> = (mix((_S468), (_S499 * material_12.coat_tint), (material_12.coat)));
        coat_2 = _S495;
        up_0 = _S500;
        through_0 = _S501;
    }
    else
    {
        coat_2 = _S469;
        up_0 = _S468;
        through_0 = _S468;
    }
    var _S502 : vec3<f32> = scale_0 * coat_2;
    var _S503 : f32 = rgb_to_greyscale(_S502);
    var _S504 : vec3<f32> = (mix((_S466), (material_12.albedo * rebounce_0), (material_12.metallic)));
    var F_1 : vec3<f32> = _S504 * scale_0 * up_0;
    var _S505 : f32 = rgb_to_greyscale(F_1);
    var _S506 : f32 = 1.0f - material_12.metallic;
    var _S507 : vec3<f32> = vec3<f32>(1.0f) - _S466;
    var _S508 : vec3<f32> = vec3<f32>(((1.0f - material_12.transmission) * _S506)) * _S507 * scale_0 * up_0;
    var _S509 : vec3<f32> = vec3<f32>((material_12.transmission * _S506)) * _S507 * scale_0 * through_0;
    var _S510 : f32 = max(_S505, 0.0f);
    var _S511 : f32 = rgb_to_greyscale(_S508);
    var _S512 : f32 = max(_S511, 0.0f);
    var _S513 : f32 = rgb_to_greyscale(_S509);
    var _S514 : f32 = (sign((length(_S457))));
    var _S515 : f32 = max(_S513 * _S514, 0.0f);
    var _S516 : f32 = _S510 + _S512 + _S515 + _S503;
    var _S517 : f32 = min(sheen_component_0, 1.0f);
    var _S518 : bool = sheen_component_0 > 0.0f;
    var _S519 : bool;
    if(_S518)
    {
        _S519 = !(_S516 > 0.0f);
    }
    else
    {
        _S519 = false;
    }
    var _S520 : f32 = select(_S517, 1.0f, _S519);
    var _S521 : f32 = (1.0f - _S520) / max(_S516, 0.0000152587890625f);
    var _S522 : f32 = _S512 * _S521;
    var _S523 : f32 = _S510 * _S521;
    var _S524 : f32 = _S515 * _S521;
    return Weights_x24init_0(_S455, _S457, F_1, 1.0f, _S508, _S509, _S522, _S523, _S524, _S520, 0.0f * _S521, sheen_2, _S469, _S502, _S503 * _S521);
}

fn translucentShare( material_13 : Material) -> f32
{
    var _S525 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S526 : f32 = rgb_to_greyscale(material_13.albedo);
    var _S527 : f32 = _S525 / (_S526 + _S525);
    var _S528 : bool = _S525 > 0.0f;
    var _S529 : f32 = select(0.0f, _S527, _S528);
    return _S529;
}

fn diffusePDF( n_i_dot_l_0 : f32,  n_i_dot_v_0 : f32,  material_14 : Material,  w_2 : Weights) -> f32
{
    var _S530 : f32 = translucentShare(material_14);
    var _S531 : f32 = w_2.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S532 : f32 = w_2.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S533 : f32 = 1.0f - _S530;
    var _S534 : bool = n_i_dot_l_0 < 0.0f;
    var _S535 : f32 = select(_S533, _S530, _S534);
    var _S536 : f32 = _S532 * _S535;
    var _S537 : bool = _S530 > 0.0f;
    var _S538 : f32 = select(_S531, _S536, _S537);
    var _S539 : bool = n_i_dot_v_0 > 0.0f;
    var _S540 : f32 = select(0.0f, _S538, _S539);
    return _S540;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_5 : vec3<f32>,  material_15 : Material,  w_3 : Weights) -> vec3<f32>
{
    var _S541 : f32 = translucentShare(material_15);
    var _S542 : bool = (dot(n_i_5, l_0)) < 0.0f;
    var _S543 : vec3<f32> = select(material_15.albedo, material_15.translucent, _S542);
    var _S544 : f32 = 1.0f - _S541;
    var _S545 : f32 = select(_S544, _S541, _S542);
    var _S546 : vec3<f32> = _S543 / vec3<f32>(_S545);
    var _S547 : bool = _S541 > 0.0f;
    var _S548 : vec3<f32> = select(material_15.albedo, _S546, _S547);
    return w_3.diffuse_weight * _S548 / vec3<f32>(w_3.p_diffuse);
}

fn refractedHalf( in_dir_2 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_4 : f32,  eta_o_3 : f32) -> vec3<f32>
{
    var _S549 : vec3<f32> = ((-(in_dir_2)));
    var _S550 : vec3<f32> = ((-(vec3<f32>(eta_i_4) * _S549 + vec3<f32>(eta_o_3) * out_dir_0)));
    var _S551 : vec3<f32> = (normalize((_S550)));
    var _S552 : f32 = (sign((dot(n_6, _S549))));
    var _S553 : f32 = (sign((dot(_S550, n_6 * vec3<f32>(_S552)))));
    return _S551 * vec3<f32>(_S553);
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S554 : f32 = alpha_5 * alpha_5;
    var _S555 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S554 * n_dot_h_0 * n_dot_h_0;
    return _S554 / max(3.14159274101257324f * _S555 * _S555, 1.17549435082228751e-38f);
}

fn anisotropicG1( w_4 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S556 : f32 = max(w_4.z, 0.0f);
    return 2.0f * _S556 / (_S556 + length(vec3<f32>(alphas_1.x * w_4.x, alphas_1.y * w_4.y, _S556)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S557 : f32 = alphas_2.x;
    var _S558 : f32 = h_0.x / _S557;
    var _S559 : f32 = alphas_2.y;
    var _S560 : f32 = h_0.y / _S559;
    var _S561 : f32 = h_0.z;
    var _S562 : f32 = _S558 * _S558 + _S560 * _S560 + _S561 * _S561;
    return 1.0f / max(3.14159274101257324f * _S557 * _S559 * _S562 * _S562, 1.17549435082228751e-38f);
}

fn vndfPDF( v_8 : vec3<f32>,  h_1 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_1 : f32,  alpha_6 : f32,  frame_4 : AnisotropicFrame,  v_dot_h_1 : f32) -> f32
{
    var _S563 : f32 = dot(n_i_6, h_1);
    var _S564 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S565 : f32 = _S564 * v_dot_h_1;
    var _S566 : f32 = trowbridgeReitz(alpha_6, _S563);
    var _S567 : f32 = _S565 * _S566 / n_i_dot_v_1;
    var _S568 : bool = alpha_6 > 0.0f;
    var _S569 : bool;
    if(_S568)
    {
        _S569 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S569 = false;
    }
    if(_S569)
    {
        _S569 = _S563 > 0.0f;
    }
    else
    {
        _S569 = false;
    }
    if(_S569)
    {
        _S569 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S569 = false;
    }
    var _S570 : f32 = select(0.0f, _S567, _S569);
    var _S571 : bool = (frame_4.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S571)
    {
        var _S572 : vec3<f32> = anisotropicLocal(v_8, frame_4.tangent, n_i_6);
        var _S573 : f32 = anisotropicG1(_S572, frame_4.alphas);
        var _S574 : vec3<f32> = anisotropicLocal(h_1, frame_4.tangent, n_i_6);
        var _S575 : f32 = anisotropicD(_S574, frame_4.alphas);
        var _S576 : f32 = _S573 * _S575;
        var _S577 : f32 = _S576 * v_dot_h_1 / n_i_dot_v_1;
        var _S578 : bool = v_dot_h_1 > 0.0f;
        if(_S578)
        {
            _S569 = _S563 > 0.0f;
        }
        else
        {
            _S569 = false;
        }
        if(_S569)
        {
            _S569 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S569 = false;
        }
        var _S579 : f32 = select(0.0f, _S577, _S569);
        pdf_h_0 = _S579;
    }
    else
    {
        pdf_h_0 = _S570;
    }
    return pdf_h_0;
}

fn refractPDF( l_dot_h_0 : f32,  pdf_h_1 : f32,  w_5 : Weights,  eta_i_5 : f32,  eta_o_4 : f32) -> f32
{
    var _S580 : f32 = eta_i_5 * w_5.v_dot_h + eta_o_4 * l_dot_h_0;
    var _S581 : f32 = w_5.p_refract * pdf_h_1 * eta_o_4 * eta_o_4 * abs(l_dot_h_0) / (_S580 * _S580);
    var _S582 : bool = eta_i_5 != eta_o_4;
    var _S583 : bool;
    if(_S582)
    {
        _S583 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S583 = false;
    }
    var _S584 : f32 = select(0.0f, _S581, _S583);
    return _S584;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_7 : f32,  frame_5 : AnisotropicFrame,  material_16 : Material,  w_6 : Weights) -> vec3<f32>
{
    var _S585 : f32 = - dot(n_i_7, l_1);
    var _S586 : f32 = smithG1(alpha_7, max(_S585, 0.0f));
    var _S587 : bool = (frame_5.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S587)
    {
        var _S588 : vec3<f32> = ((-(n_i_7)));
        var _S589 : vec3<f32> = anisotropicLocal(l_1, frame_5.tangent, _S588);
        var _S590 : f32 = anisotropicG1(_S589, frame_5.alphas);
        G1_l_0 = _S590;
    }
    else
    {
        G1_l_0 = _S586;
    }
    return w_6.refract_weight * vec3<f32>(G1_l_0) * material_16.albedo / vec3<f32>(w_6.p_refract);
}

fn reflectedHalf( in_dir_3 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S591 : vec3<f32> = ((-(in_dir_3)));
    var _S592 : vec3<f32> = (normalize((_S591 + out_dir_1)));
    return _S592;
}

fn reflectPDF( pdf_h_2 : f32,  w_7 : Weights) -> f32
{
    var _S593 : f32 = w_7.p_reflect * pdf_h_2 / (4.0f * w_7.v_dot_h);
    var _S594 : bool = pdf_h_2 > 0.0f;
    var _S595 : f32 = select(0.0f, _S593, _S594);
    return _S595;
}

fn reflectBSDF( l_2 : vec3<f32>,  n_i_8 : vec3<f32>,  alpha_8 : f32,  frame_6 : AnisotropicFrame,  w_8 : Weights) -> vec3<f32>
{
    var _S596 : f32 = dot(n_i_8, l_2);
    var _S597 : f32 = smithG1(alpha_8, max(_S596, 0.0f));
    var _S598 : bool = (frame_6.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S598)
    {
        var _S599 : vec3<f32> = anisotropicLocal(l_2, frame_6.tangent, n_i_8);
        var _S600 : f32 = anisotropicG1(_S599, frame_6.alphas);
        G1_l_1 = _S600;
    }
    else
    {
        G1_l_1 = _S597;
    }
    return vec3<f32>((w_8.reflect_weight * G1_l_1)) * w_8.F / vec3<f32>(w_8.p_reflect);
}

fn sheenVelvetPDF( n_i_dot_l_1 : f32,  n_i_dot_v_2 : f32,  w_9 : Weights) -> f32
{
    var _S601 : f32 = w_9.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S602 : bool = n_i_dot_l_1 > 0.0f;
    var _S603 : bool;
    if(_S602)
    {
        _S603 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S603 = false;
    }
    var _S604 : f32 = select(0.0f, _S601, _S603);
    return _S604;
}

fn sheenVelvetBSDF( l_3 : vec3<f32>,  v_9 : vec3<f32>,  n_i_9 : vec3<f32>,  material_17 : Material,  w_10 : Weights) -> vec3<f32>
{
    var _S605 : vec3<f32> = (normalize((l_3 + v_9)));
    var _S606 : f32 = dot(n_i_9, _S605);
    var _S607 : f32 = max(dot(n_i_9, l_3), 0.0f);
    var _S608 : f32 = max(dot(n_i_9, v_9), 0.0f);
    var _S609 : f32 = 1.0f / max(material_17.sheen_roughness, 0.05000000074505806f);
    var _S610 : f32 = 1.0f - _S606 * _S606;
    var _S611 : f32 = (2.0f + _S609) * pow(max(_S610, 0.0f), 0.5f * _S609) * 0.5f * 0.31830987334251404f / max(4.0f * (_S607 + _S608 - _S607 * _S608), 0.0000152587890625f);
    var _S612 : bool = (material_17.velvet) > 0.0f;
    var f_3 : f32;
    if(_S612)
    {
        var _S613 : f32 = max(material_17.sheen_roughness, 0.00999999977648258f);
        var _S614 : f32 = _S613 * _S613;
        var _S615 : f32 = max(_S610, 0.0000152587890625f);
        var _S616 : f32 = exp(- _S606 * _S606 / (_S615 * _S614)) / (3.14159274101257324f * _S614 * _S615 * _S615) * min(1.0f, 2.0f * _S606 * min(_S607, _S608) / max(abs(dot(_S605, v_9)), 0.0000152587890625f)) / max(4.0f * _S607 * _S608, 0.0000152587890625f);
        f_3 = _S616;
    }
    else
    {
        f_3 = _S611;
    }
    return w_10.sheen * vec3<f32>((f_3 * _S607 * 2.0f * 3.14159274101257324f / w_10.p_sheen_velvet));
}

fn coatPDF( v_10 : vec3<f32>,  coat_h_2 : vec3<f32>,  coat_frame_4 : CoatFrame,  w_11 : Weights) -> f32
{
    var _S617 : f32 = dot(coat_frame_4.normal, v_10);
    var _S618 : f32 = smithG1(coat_frame_4.alpha, _S617);
    var _S619 : f32 = trowbridgeReitz(coat_frame_4.alpha, dot(coat_frame_4.normal, coat_h_2));
    var _S620 : f32 = _S618 * _S619 / (4.0f * _S617);
    var _S621 : bool = (coat_frame_4.alpha) > 0.0f;
    var _S622 : f32 = select(0.0f, _S620, _S621);
    return w_11.p_coat * _S622;
}

fn coatBSDF( w_12 : Weights) -> vec3<f32>
{
    return w_12.coat / vec3<f32>(w_12.p_coat);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_18 : Material,  eta_i_6 : f32,  eta_o_5 : f32,  refracted_1 : bool,  random_state_6 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(6)>>,  pdfs_0 : ptr<function, array<f32, i32(6)>>) -> vec3<f32>
{
    var _S623 : vec3<f32> = ((-(in_dir_4)));
    var _S624 : f32 = dot(n_7, _S623);
    var _S625 : f32 = (sign((_S624)));
    var _S626 : vec3<f32> = n_7 * vec3<f32>(_S625);
    var _S627 : f32 = dot(_S626, out_dir_2);
    var _S628 : f32 = material_18.roughness;
    var _S629 : f32 = _S628 * _S628;
    var _S630 : AnisotropicFrame = anisotropicFrame(material_18, _S626);
    var _S631 : SheenProfile = sheenProfile(_S623, _S626, material_18);
    var _S632 : CoatFrame = coatFrame(material_18, _S626);
    var _S633 : vec3<f32> = coatSeries(_S632, material_18);
    var _S634 : f32 = rgb_to_greyscale(material_18.translucent);
    var _S635 : bool = _S634 > 0.0f;
    var _S636 : bool = (dot(n_7, out_dir_2) * _S624) < 0.0f;
    var _S637 : bool = (_S632.ior) > 0.0f;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S638 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S638;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S639 : bool;
    if(_S635)
    {
        _S639 = _S636;
    }
    else
    {
        _S639 = false;
    }
    var _S640 : bool = _S639 == refracted_1;
    var _S641 : bool = !refracted_1;
    if(_S641)
    {
        _S639 = _S637;
    }
    else
    {
        _S639 = false;
    }
    var _S642 : vec3<f32> = coatHalf(_S623, _S632, random_state_6);
    var _S643 : vec3<f32> = vec3<f32>(0.0f);
    var _S644 : bool;
    if(_S640)
    {
        _S644 = true;
    }
    else
    {
        _S644 = _S639;
    }
    var sampled_n_0 : vec3<f32>;
    if(_S644)
    {
        var _S645 : vec3<f32> = sampledHalf(_S623, _S626, _S629, _S630, random_state_6);
        sampled_n_0 = _S645;
    }
    else
    {
        sampled_n_0 = _S643;
    }
    if(_S640)
    {
        var _S646 : Weights = lobeWeights(in_dir_4, _S623, _S626, sampled_n_0, _S642, _S630, _S631, _S632, _S633, material_18, eta_i_6, eta_o_5);
        if(_S640)
        {
            var _S647 : f32 = diffusePDF(_S627, abs(_S624), material_18, _S646);
            (*pdfs_0)[i32(0)] = _S647;
            var _S648 : vec3<f32> = diffuseBSDF(out_dir_2, _S626, material_18, _S646);
            (*throughputs_0)[i32(0)] = _S648;
        }
    }
    if(refracted_1)
    {
        var _S649 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_5);
        var _S650 : Weights = lobeWeights(in_dir_4, _S623, _S626, _S649, _S642, _S630, _S631, _S632, _S633, material_18, eta_i_6, eta_o_5);
        var _S651 : f32 = dot(out_dir_2, _S649);
        var _S652 : f32 = vndfPDF(_S623, _S649, _S626, abs(_S624), _S629, _S630, _S650.v_dot_h);
        var _S653 : f32 = refractPDF(_S651, _S652, _S650, eta_i_6, eta_o_5);
        (*pdfs_0)[i32(1)] = _S653;
        var _S654 : vec3<f32> = refractBSDF(out_dir_2, _S626, _S629, _S630, material_18, _S650);
        (*throughputs_0)[i32(1)] = _S654;
    }
    else
    {
        var _S655 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
        var _S656 : Weights = lobeWeights(in_dir_4, _S623, _S626, _S655, _S642, _S630, _S631, _S632, _S633, material_18, eta_i_6, eta_o_5);
        var _S657 : f32 = abs(_S624);
        var _S658 : f32 = vndfPDF(_S623, _S655, _S626, _S657, _S629, _S630, _S656.v_dot_h);
        var _S659 : f32 = reflectPDF(_S658, _S656);
        (*pdfs_0)[i32(2)] = _S659;
        var _S660 : vec3<f32> = reflectBSDF(out_dir_2, _S626, _S629, _S630, _S656);
        (*throughputs_0)[i32(2)] = _S660;
        var _S661 : f32 = sheenVelvetPDF(_S627, _S657, _S656);
        (*pdfs_0)[i32(3)] = _S661;
        var _S662 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S623, _S626, material_18, _S656);
        (*throughputs_0)[i32(3)] = _S662;
        if(_S639)
        {
            var _S663 : Weights = lobeWeights(in_dir_4, _S623, _S626, sampled_n_0, _S655, _S630, _S631, _S632, _S633, material_18, eta_i_6, eta_o_5);
            var _S664 : f32 = coatPDF(_S623, _S655, _S632, _S663);
            (*pdfs_0)[i32(5)] = _S664;
            var _S665 : vec3<f32> = coatBSDF(_S663);
            (*throughputs_0)[i32(5)] = _S665;
        }
    }
    i_0 = u32(0);
    var f_4 : vec3<f32> = _S643;
    loop
    {
        if(i_0 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S666 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S666)
        {
            var f_5 : vec3<f32> = f_4 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            f_4 = f_5;
        }
        var i_2 : u32 = i_0 + u32(1);
        i_0 = i_2;
    }
    return f_4;
}

fn lightBSDF_0( in_dir_5 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_2 : vec3<f32>,  material_19 : Material,  eta_i_7 : f32,  eta_o_6 : f32,  competing_0 : bool,  random_state_7 : u32) -> vec3<f32>
{
    var _S667 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(6)>;
    var pdfs_1 : array<f32, i32(6)>;
    var _S668 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_19, eta_i_7, eta_o_6, _S667, random_state_7, &(throughputs_1), &(pdfs_1));
    var _S669 : bool = !competing_0;
    var _S670 : bool;
    if(_S669)
    {
        _S670 = true;
    }
    else
    {
        _S670 = (light_0.density) == 0.0f;
    }
    if(_S670)
    {
        return _S668 * light_0.radiance;
    }
    var _S671 : vec3<f32> = vec3<f32>(0.0f);
    var i_3 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S671;
    loop
    {
        if(i_3 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S672 : bool = (pdfs_1[i_3]) > 0.0f;
        if(_S672)
        {
            var _S673 : f32 = pdfs_1[i_3] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_3] * vec3<f32>(pdfs_1[i_3]) / vec3<f32>((light_0.density * (1.0f + _S673 * _S673)));
            weighted_0 = weighted_1;
        }
        var i_4 : u32 = i_3 + u32(1);
        i_3 = i_4;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S674 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S675 : vec2<u32> = _S674 - vec2<u32>(u32(1), u32(0));
    var _S676 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S677 : vec2<u32> = min(vec2<u32>(_S676 * vec2<f32>(_S675)), _S675 - vec2<u32>(u32(1)));
    var _S678 : vec4<f32> = (textureLoad(environment_cdf, (_S677), 0));
    var _S679 : f32 = _S678.y;
    var _S680 : u32 = _S675.x;
    var _S681 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S680, _S677.y)), 0));
    var _S682 : f32 = _S679 * _S681.y;
    return _S682 * f32(_S680 * _S675.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  material_20 : Material,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_8 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(6)>>,  pdfs_2 : ptr<function, array<f32, i32(6)>>) -> vec3<f32>
{
    var _S683 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    var _S684 : vec3<f32> = BSDF(in_dir_6, dir_5, surface_1.smooth_n, material_20, eta_0.x, eta_0.y, _S683, random_state_8, &((*terms_0)), &((*pdfs_2)));
    var _S685 : vec3<f32> = vec3<f32>(0.0f);
    var i_5 : u32 = u32(0);
    var f_6 : vec3<f32> = _S685;
    loop
    {
        if(i_5 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S686 : bool = ((*pdfs_2)[i_5]) > 0.0f;
        if(_S686)
        {
            var _S687 : vec3<f32> = (*terms_0)[i_5] * vec3<f32>((*pdfs_2)[i_5]) / vec3<f32>(((*pdfs_2)[i_5] + pdf_2));
            (*terms_0)[i_5] = _S687;
            var f_7 : vec3<f32> = f_6 + (*terms_0)[i_5];
            f_6 = f_7;
        }
        var i_6 : u32 = i_5 + u32(1);
        i_5 = i_6;
    }
    return f_6;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_6 : vec3<f32>,  surface_2 : Surface,  material_21 : Material,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(6)>;
    var pdfs_3 : array<f32, i32(6)>;
    var _S688 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, material_21, eta_1, is_inside_2, pdf_3, random_state_9, &(terms_1), &(pdfs_3));
    return _S688;
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
    var _S689 : u32 = count_0 - u32(1);
    var low_1 : u32 = u32(0);
    var high_1 : u32 = _S689;
    loop
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        var _S690 : u32 = (low_1 + high_1) / u32(2);
        var _S691 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S690)), 0));
        var _S692 : bool = (_S691.x) > u_1;
        if(_S692)
        {
            high_1 = _S690;
        }
        else
        {
            var _S693 : u32 = _S690 + u32(1);
            low_1 = _S693;
        }
    }
    return low_1;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_10 : u32) -> SkySample
{
    var _S694 : SkySample;
    _S694.dir = dir_7;
    _S694.radiance = radiance_2;
    _S694.color = color_2;
    _S694.random_state = random_state_10;
    return _S694;
}

fn skyRadiance_0( origin_6 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S695 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S696 : bool = is_inside_3 != _S695;
    var _S697 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S698 : vec3<f32> = select(surface_3.smooth_n, _S697, _S696);
    var _S699 : Ray = Ray_x24init_0(origin_6 + vec3<f32>(surface_3.geometry_offset) * _S698, dir_8);
    var _S700 : vec3<f32> = (env_map_sample((dir_8)));
    var _S701 : vec3<f32> = (shadowTransmittance((_S699), (4.294967296e+09f)));
    return _S700 * _S701;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  wavelength_7 : f32,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S702 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S703 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S704 : vec2<u32> = _S702 - _S703;
    var _S705 : Random = draw(init_random_state_1, u32(6));
    var _S706 : Random = draw(init_random_state_1, u32(2147483654));
    var _S707 : Random = draw(init_random_state_1, u32(7));
    var _S708 : Random = draw(init_random_state_1, u32(2147483655));
    var _S709 : u32 = _S704.x;
    var _S710 : u32 = searchCDF_0(vec2<u32>(_S709, u32(0)), vec2<u32>(u32(0), u32(1)), _S704.y, _S705.value);
    var _S711 : u32 = searchCDF_0(vec2<u32>(u32(0), _S710), _S703, _S709, _S706.value);
    var _S712 : vec2<f32> = (vec2<f32>(f32(_S711), f32(_S710)) + vec2<f32>(_S707.value, _S708.value)) / vec2<f32>(_S704) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S713 : f32 = _S712.y;
    var _S714 : f32 = sin(_S713);
    var _S715 : f32 = _S712.x;
    var _S716 : vec3<f32> = vec3<f32>(_S714 * cos(_S715), cos(_S713), _S714 * sin(_S715));
    var _S717 : f32 = environmentPdf_0(_S716);
    var _S718 : Material = pathMaterial(surface_4.material, wavelength_7);
    var _S719 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S716, surface_4, _S718, eta_2, is_inside_4, _S717, lobe_state_0);
    var _S720 : bool = !(_S717 > 0.0f);
    var _S721 : bool;
    if(_S720)
    {
        _S721 = true;
    }
    else
    {
        _S721 = (all((_S719 == vec3<f32>(0.0f))));
    }
    if(_S721)
    {
        var _S722 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S716, _S722, _S722, _S708.state);
    }
    var _S723 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S716);
    return SkySample_x24init_0(_S716, _S723, _S719 * _S723, _S708.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S724 : vec3<f32> = a_5 / b_1;
    var _S725 : vec3<f32> = vec3<f32>(0.0f);
    var _S726 : vec3<bool> = b_1 == _S725;
    var _S727 : vec3<f32> = select(_S724, _S725, _S726);
    return _S727;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_8 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S728 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S729 : u32 = (insertBits((_S728), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S729;
    candidate_0.f = f_8;
    return candidate_0;
}

fn resamplingTarget( f_9 : vec3<f32>) -> f32
{
    var _S730 : f32 = rgb_to_greyscale(abs(f_9));
    return _S730;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_1 : vec3<f32>)
{
    var _S731 : f32 = resamplingTarget(weight_1);
    var _S732 : bool = _S731 > 0.0f;
    var _S733 : bool;
    if(_S732)
    {
        _S733 = _S731 < 3.00000000549775576e+38f;
    }
    else
    {
        _S733 = false;
    }
    var _S734 : bool = !_S733;
    if(_S734)
    {
        return;
    }
    var _S735 : f32 = (*sel_0).w_sum + _S731;
    (*sel_0).w_sum = _S735;
    var _S736 : vec3<f32> = (*sel_0).color + weight_1;
    (*sel_0).color = _S736;
    var _S737 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S737.state;
    var _S738 : bool = (_S737.value * (*sel_0).w_sum) <= _S731;
    if(_S738)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S739 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S740 : bool = (_S739.x) > u32(1);
    var _S741 : bool;
    if(_S740)
    {
        var _S742 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S741 = (_S742.y) > u32(1);
    }
    else
    {
        _S741 = false;
    }
    return _S741;
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_11 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_4 : f32) -> SampleBSDF
{
    var _S743 : SampleBSDF;
    _S743.unit_direction = unit_direction_1;
    _S743.throughput = throughput_0;
    _S743.random_state = random_state_11;
    _S743.refracted = refracted_3;
    _S743.lobe = lobe_1;
    _S743.pdf = pdf_4;
    return _S743;
}

fn sheenVelvetSample( v_11 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_3 : f32,  material_22 : Material,  w_13 : Weights,  random_state_12 : u32) -> SampleBSDF
{
    var _S744 : vec3<f32> = vec3<f32>(1.0f);
    var _S745 : SampleBSDF = SampleBSDF_x24init_0(_S744, _S744, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S745;
    var _S746 : Random = draw(random_state_12, u32(3));
    var _S747 : Random = draw(random_state_12, u32(2147483651));
    sample_1.random_state = _S747.state;
    var _S748 : f32 = _S746.value;
    var _S749 : f32 = sqrt(max(0.0f, 1.0f - _S748 * _S748));
    var _S750 : f32 = 6.28318548202514648f * _S747.value;
    var _S751 : vec3<f32> = tangentToWorld(vec3<f32>(_S749 * cos(_S750), _S746.value, _S749 * sin(_S750)), n_i_10);
    sample_1.unit_direction = _S751;
    sample_1.lobe = u32(4);
    var _S752 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, v_11, n_i_10, material_22, w_13);
    sample_1.throughput = _S752;
    var _S753 : f32 = sheenVelvetPDF(_S746.value, n_i_dot_v_3, w_13);
    sample_1.pdf = _S753;
    return sample_1;
}

fn coatSample( in_dir_8 : vec3<f32>,  v_12 : vec3<f32>,  coat_h_3 : vec3<f32>,  coat_frame_5 : CoatFrame,  w_14 : Weights,  random_state_13 : u32) -> SampleBSDF
{
    var _S754 : vec3<f32> = vec3<f32>(1.0f);
    var _S755 : SampleBSDF = SampleBSDF_x24init_0(_S754, _S754, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S755;
    var _S756 : vec3<f32> = (normalize((reflect(in_dir_8, coat_h_3))));
    sample_2.unit_direction = _S756;
    sample_2.random_state = random_state_13;
    sample_2.lobe = u32(5);
    var _S757 : vec3<f32> = coatBSDF(w_14);
    sample_2.throughput = _S757;
    var _S758 : f32 = coatPDF(v_12, coat_h_3, coat_frame_5, w_14);
    sample_2.pdf = _S758;
    return sample_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S759 : f32 = sqrt(random_1_0);
    var _S760 : f32 = 6.28318548202514648f * random_2_0;
    var _S761 : f32 = _S759 * cos(_S760);
    var _S762 : f32 = _S759 * sin(_S760);
    var _S763 : f32 = sqrt(max(0.0f, 1.0f - _S761 * _S761 - _S762 * _S762));
    return vec3<f32>(_S761, _S763, _S762);
}

fn diffuseSample( u_2 : f32,  n_i_11 : vec3<f32>,  n_i_dot_v_4 : f32,  material_23 : Material,  w_15 : Weights,  random_state_14 : u32) -> SampleBSDF
{
    var _S764 : vec3<f32> = vec3<f32>(1.0f);
    var _S765 : SampleBSDF = SampleBSDF_x24init_0(_S764, _S764, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S765;
    var _S766 : Random = draw(random_state_14, u32(3));
    var _S767 : Random = draw(random_state_14, u32(2147483651));
    sample_3.random_state = _S767.state;
    var _S768 : vec3<f32> = sampleCosWeightedHemisphere(_S766.value, _S767.value);
    var _S769 : f32 = translucentShare(material_23);
    var _S770 : bool = u_2 < (w_15.p_diffuse * _S769);
    var _S771 : f32 = _S768.y;
    var _S772 : f32 = - _S771;
    var _S773 : f32 = select(_S771, _S772, _S770);
    var _S774 : vec3<f32> = tangentToWorld(vec3<f32>(_S768.x, _S773, _S768.z), n_i_11);
    sample_3.unit_direction = _S774;
    sample_3.refracted = _S770;
    sample_3.lobe = u32(0);
    var _S775 : vec3<f32> = diffuseBSDF(sample_3.unit_direction, n_i_11, material_23, w_15);
    sample_3.throughput = _S775;
    var _S776 : f32 = diffusePDF(_S773, n_i_dot_v_4, material_23, w_15);
    sample_3.pdf = _S776;
    return sample_3;
}

fn refractSample( ggx_n_1 : vec3<f32>,  n_i_12 : vec3<f32>,  alpha_9 : f32,  frame_7 : AnisotropicFrame,  material_24 : Material,  w_16 : Weights,  pdf_h_3 : f32,  eta_i_8 : f32,  eta_o_7 : f32,  random_state_15 : u32) -> SampleBSDF
{
    var _S777 : vec3<f32> = vec3<f32>(1.0f);
    var _S778 : SampleBSDF = SampleBSDF_x24init_0(_S777, _S777, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S778;
    sample_4.unit_direction = w_16.refracted;
    sample_4.random_state = random_state_15;
    sample_4.refracted = true;
    sample_4.lobe = u32(1);
    var _S779 : vec3<f32> = refractBSDF(sample_4.unit_direction, n_i_12, alpha_9, frame_7, material_24, w_16);
    sample_4.throughput = _S779;
    var _S780 : f32 = refractPDF(dot(sample_4.unit_direction, ggx_n_1), pdf_h_3, w_16, eta_i_8, eta_o_7);
    sample_4.pdf = _S780;
    return sample_4;
}

fn reflectSample( in_dir_9 : vec3<f32>,  ggx_n_2 : vec3<f32>,  n_i_13 : vec3<f32>,  alpha_10 : f32,  frame_8 : AnisotropicFrame,  w_17 : Weights,  pdf_h_4 : f32,  random_state_16 : u32) -> SampleBSDF
{
    var _S781 : vec3<f32> = vec3<f32>(1.0f);
    var _S782 : SampleBSDF = SampleBSDF_x24init_0(_S781, _S781, u32(0), false, u32(0), 0.0f);
    var sample_5 : SampleBSDF = _S782;
    var _S783 : vec3<f32> = (normalize((reflect(in_dir_9, ggx_n_2))));
    sample_5.unit_direction = _S783;
    sample_5.random_state = random_state_16;
    sample_5.lobe = u32(2);
    var _S784 : vec3<f32> = reflectBSDF(sample_5.unit_direction, n_i_13, alpha_10, frame_8, w_17);
    sample_5.throughput = _S784;
    var _S785 : f32 = reflectPDF(pdf_h_4, w_17);
    sample_5.pdf = _S785;
    return sample_5;
}

fn sampleBSDF( in_dir_10 : vec3<f32>,  n_8 : vec3<f32>,  material_25 : Material,  eta_i_9 : f32,  eta_o_8 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_17 : u32 = random_init_0;
    var _S786 : vec3<f32> = ((-(in_dir_10)));
    var _S787 : f32 = dot(n_8, _S786);
    var _S788 : f32 = (sign((_S787)));
    var n_i_14 : vec3<f32> = n_8 * vec3<f32>(_S788);
    var _S789 : f32 = abs(_S787);
    var _S790 : f32 = material_25.roughness;
    var _S791 : f32 = _S790 * _S790;
    var _S792 : AnisotropicFrame = anisotropicFrame(material_25, n_i_14);
    var _S793 : SheenProfile = sheenProfile(_S786, n_i_14, material_25);
    var _S794 : CoatFrame = coatFrame(material_25, n_i_14);
    var _S795 : vec3<f32> = coatSeries(_S794, material_25);
    var _S796 : vec3<f32> = sampleHalfVector(_S786, n_i_14, _S791, _S792, &(random_state_17), u32(0));
    var _S797 : vec3<f32> = coatHalf(_S786, _S794, random_init_0);
    var _S798 : Weights = lobeWeights(in_dir_10, _S786, n_i_14, _S796, _S797, _S792, _S793, _S794, _S795, material_25, eta_i_9, eta_o_8);
    var _S799 : Random = draw(random_state_17, u32(2));
    random_state_17 = _S799.state;
    var _S800 : bool = (_S799.value) < (_S798.p_sheen_velvet);
    if(_S800)
    {
        var _S801 : SampleBSDF = sheenVelvetSample(_S786, n_i_14, _S789, material_25, _S798, random_state_17);
        return _S801;
    }
    var _S802 : f32 = _S799.value - _S798.p_sheen_velvet;
    var _S803 : bool = _S802 < (_S798.p_coat);
    if(_S803)
    {
        var _S804 : SampleBSDF = coatSample(in_dir_10, _S786, _S797, _S794, _S798, random_state_17);
        return _S804;
    }
    var _S805 : f32 = _S802 - _S798.p_coat;
    var _S806 : bool = _S805 < (_S798.p_diffuse);
    if(_S806)
    {
        var _S807 : SampleBSDF = diffuseSample(_S805, n_i_14, _S789, material_25, _S798, random_state_17);
        return _S807;
    }
    var _S808 : f32 = vndfPDF(_S786, _S796, n_i_14, _S789, _S791, _S792, _S798.v_dot_h);
    var _S809 : bool = _S805 < (_S798.p_diffuse + _S798.p_refract);
    if(_S809)
    {
        var _S810 : SampleBSDF = refractSample(_S796, n_i_14, _S791, _S792, material_25, _S798, _S808, eta_i_9, eta_o_8, random_state_17);
        return _S810;
    }
    var _S811 : SampleBSDF = reflectSample(in_dir_10, _S796, n_i_14, _S791, _S792, _S798, _S808, random_state_17);
    return _S811;
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S812 : bool = pdf_5 <= 0.0f;
    var _S813 : bool;
    if(_S812)
    {
        _S813 = true;
    }
    else
    {
        var _S814 : bool = environmentMapped_0();
        _S813 = !_S814;
    }
    if(_S813)
    {
        return 1.0f;
    }
    var _S815 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S815);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S816 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S816.x, max(_S816.y, _S816.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S817 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S818 : bool = (_S817.x) > u32(1);
    var _S819 : bool;
    if(_S818)
    {
        var _S820 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S819 = (_S820.y) > u32(1);
    }
    else
    {
        _S819 = false;
    }
    if(_S819)
    {
        var _S821 : vec3<f32> = (env_map_sample((dir_10)));
        return _S821;
    }
    var _S822 : vec3<f32> = (uniforms_float.ambient);
    return _S822;
}

fn walk_0( dom_1 : Domain,  r_4 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S823 : vec3<f32> = vec3<f32>(0.0f);
    var _S824 : Shift = Shift_x24init_0(_S823, 0.0f);
    var _S825 : u32 = (extractBits((r_4.path), (u32(0)), (u32(5))));
    var _S826 : u32 = (extractBits((r_4.path), (u32(5)), (u32(5))));
    var _S827 : u32 = (extractBits((r_4.path), (u32(10)), (u32(2))));
    var _S828 : u32 = (extractBits((r_4.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S829 : bool = _S828 >= u32(3);
        var _S830 : u32 = select(u32(0), u32(1), _S829);
        var _S831 : u32 = _S825 + _S830;
        var _S832 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S831 > _S832;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S824;
    }
    var _S833 : u32 = _S826 - u32(1);
    var _S834 : bool = _S828 == u32(3);
    var _S835 : u32 = select(u32(0), u32(1), _S834);
    var _S836 : u32 = _S825 + _S835;
    var _S837 : bool = _S827 == u32(0);
    var _S838 : u32 = select(_S833, _S836, _S837);
    var _S839 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_4.rc.zw))), r_4.rc.x, r_4.rc.y, u32(0), 0.0f);
    var _S840 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S841 : Ray = Ray_x24init_0(dom_1.x1, _S840);
    var ray_2 : Ray = _S841;
    var hit_2 : Hit = dom_1.hit;
    var _S842 : vec3<f32> = vec3<f32>(1.0f);
    var _S843 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S823, _S823, _S823);
    var nee_vertex_0 : NEEVertex = _S843;
    var _S844 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S844;
    var _S845 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S823, 0.0f, vec4<u32>(u32(0)), _S823, _S823);
    var chain_0 : Reservoir = _S845;
    chain_0.seed = r_4.seed;
    var _S846 : u32 = (extractBits((r_4.path), (u32(24)), (u32(8))));
    var _S847 : u32 = (insertBits((u32(0)), (_S846), (u32(24)), (u32(8))));
    chain_0.path = _S847;
    is_inside_5 = false;
    var wavelength_8 : f32 = 0.0f;
    var threshold_0 : f32 = 0.0f;
    var spectral_weight_0 : vec3<f32> = _S842;
    var chain_throughput_0 : vec3<f32> = _S823;
    var reconnection_0 : vec3<f32> = _S823;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S842;
    var scatter_in_0 : vec3<f32> = _S823;
    var extinction_in_0 : vec3<f32> = _S823;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S848 : bool = (hit_2.is_point_light) == u32(1);
        var _S849 : bool;
        if(replay_0)
        {
            _S849 = _S827 == u32(1);
        }
        else
        {
            _S849 = false;
        }
        var _S850 : bool;
        if(_S849)
        {
            _S850 = b_2 == _S826;
        }
        else
        {
            _S850 = false;
        }
        var _S851 : bool;
        if(_S850)
        {
            var _S852 : bool = (hit_2.instance_index) != (_S839.instance_index);
            if(_S852)
            {
                _S851 = true;
            }
            else
            {
                _S851 = (hit_2.triangle_index) != (_S839.triangle_index);
            }
        }
        else
        {
            _S851 = false;
        }
        if(_S851)
        {
            return _S824;
        }
        var _S853 : Surface = Surface_x24init_0(_S823, _S823, 0.0f, Material_x24init_0(_S823, _S823, 0.0f, 0.0f, 0.0f, 0.0f, _S823, _S842, 1.0f, _S823, _S823, 0.5f, 0.0f, 0.0f, _S823, 0.0f, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S842, _S823), false, u32(0));
        var _S854 : bool = !_S848;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S854)
        {
            var _S855 : u32 = noiseAddress(r_4.seed, b_2);
            var _S856 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S855)));
            var surface_6 : Surface = facingRay_0(_S856, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S857 : f32 = hit_2.distance;
                var _S858 : f32 = upsample(surface_6.material.absorption, wavelength_8);
                var _S859 : vec3<f32> = vec3<f32>(_S858);
                var _S860 : bool = wavelength_8 > 0.0f;
                var _S861 : vec3<f32> = select(surface_6.material.absorption, _S859, _S860);
                var _S862 : vec3<f32> = beerLambert(_S857, _S861);
                var _S863 : vec3<f32> = throughput_2 * _S862;
                front_n_0 = _S863;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S864 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S865 : bool = b_2 == u32(0);
            if(_S865)
            {
                var _S866 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S866;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S867 : vec3<f32> = front_n_0;
            var _S868 : f32 = geometry_density_0;
            scatter_0 = _S864;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S868;
            surface_5 = surface_6;
            front_n_0 = _S856.smooth_n;
            throughput_3 = _S867;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S853;
            front_n_0 = _S823;
            throughput_3 = throughput_2;
        }
        var _S869 : bool;
        if(scatter_0)
        {
            _S869 = prev_0.rough;
        }
        else
        {
            _S869 = false;
        }
        var _S870 : bool;
        if(_S869)
        {
            _S870 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S870 = false;
        }
        var _S871 : Surface = surface_5;
        var _S872 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S873 : bool = ((true));
        var _S874 : bool;
        if(_S873)
        {
            _S874 = wavelength_8 == 0.0f;
        }
        else
        {
            _S874 = false;
        }
        var _S875 : bool;
        if(_S874)
        {
            _S875 = scatter_0;
        }
        else
        {
            _S875 = false;
        }
        var _S876 : bool;
        if(_S875)
        {
            var _S877 : bool = dispersive(surface_5.material);
            _S876 = _S877;
        }
        else
        {
            _S876 = false;
        }
        var throughput_4 : vec3<f32>;
        if(_S876)
        {
            var _S878 : u32 = stream(r_4.seed, u32(512));
            var _S879 : Random = pcg(_S878);
            var _S880 : u32 = (extractBits((r_4.path), (u32(25)), (u32(7))));
            var _S881 : f32 = (f32(_S880) + _S879.value) / 128.0f;
            var _S882 : u32 = (extractBits((r_4.path), (u32(24)), (u32(1))));
            var _S883 : bool = _S882 == u32(1);
            var _S884 : f32 = select(_S879.value, _S881, _S883);
            var _S885 : vec2<f32> = sampleWavelength(_S884);
            var wavelength_9 : f32 = _S885.x;
            var _S886 : vec3<f32> = wavelengthWeights(wavelength_9);
            var _S887 : vec3<f32> = _S886 / vec3<f32>(_S885.y);
            var _S888 : f32 = upsample(throughput_3, wavelength_9);
            var _S889 : vec3<f32> = vec3<f32>(_S888);
            var _S890 : f32 = upsample(scatter_in_0, wavelength_9);
            var _S891 : vec3<f32> = vec3<f32>(_S890);
            var _S892 : f32 = upsample(extinction_in_0, wavelength_9);
            var _S893 : vec3<f32> = vec3<f32>(_S892);
            wavelength_8 = wavelength_9;
            spectral_weight_0 = _S887;
            throughput_4 = _S889;
            scatter_in_0 = _S891;
            extinction_in_0 = _S893;
        }
        else
        {
            throughput_4 = throughput_3;
        }
        var _S894 : Material = pathMaterial(surface_5.material, wavelength_8);
        var _S895 : vec2<f32> = wavelengthEta(_S894, _S872, wavelength_8);
        var _S896 : bool;
        if(scatter_0)
        {
            var _S897 : bool = neeDecision(_S894, _S872, _S895.x, _S895.y);
            _S896 = _S897;
        }
        else
        {
            _S896 = false;
        }
        var _S898 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S899 : vec3<f32> = _S894.emissive * vec3<f32>(max(_S898, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S848)
        {
            var _S900 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S900;
        }
        else
        {
            emission_0 = _S899;
        }
        var _S901 : bool = !replay_0;
        var _S902 : bool;
        if(_S901)
        {
            _S902 = true;
        }
        else
        {
            _S902 = b_2 >= _S838;
        }
        var _S903 : bool;
        if(_S902)
        {
            var _S904 : f32 = rgb_to_greyscale(emission_0);
            _S903 = _S904 > 0.0f;
        }
        else
        {
            _S903 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S903)
        {
            var _S905 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S905);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S906 : bool;
        if(replay_0)
        {
            _S906 = _S827 == u32(1);
        }
        else
        {
            _S906 = false;
        }
        var _S907 : bool;
        if(_S906)
        {
            _S907 = b_2 > _S826;
        }
        else
        {
            _S907 = false;
        }
        var _S908 : bool;
        if(_S907)
        {
            _S908 = b_2 == _S825;
        }
        else
        {
            _S908 = false;
        }
        var _S909 : bool;
        if(_S908)
        {
            var _S910 : bool = _S828 == u32(1);
            if(_S910)
            {
                _S909 = true;
            }
            else
            {
                _S909 = _S828 == u32(2);
            }
        }
        else
        {
            _S909 = false;
        }
        if(_S909)
        {
            var _S911 : bool = _S848 != (_S828 == u32(2));
            if(_S911)
            {
                return _S824;
            }
            var _S912 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_8);
            return Shift_x24init_0(_S912 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S913 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S914 : bool = _S913 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S915 : u32 = (insertBits((_S847), (b_2), (u32(5)), (u32(5))));
        var _S916 : u32 = (insertBits((_S915), (u32(1)), (u32(10)), (u32(2))));
        var _S917 : u32 = (insertBits((_S916), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S918 : bool = prev_0.inside;
        var _S919 : u32 = select(u32(0), u32(1), _S918);
        var _S920 : u32 = (insertBits((_S917), (_S919), (u32(22)), (u32(1))));
        here_0.path = _S920;
        var _S921 : u32 = here_0.path;
        var _S922 : bool = wavelength_8 > 0.0f;
        var _S923 : u32 = select(u32(0), u32(1), _S922);
        var _S924 : u32 = (insertBits((_S921), (_S923), (u32(23)), (u32(1))));
        here_0.path = _S924;
        var _S925 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S925;
        var _S926 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S926;
        var _S927 : bool;
        if(replay_0)
        {
            _S927 = _S827 == u32(1);
        }
        else
        {
            _S927 = false;
        }
        var _S928 : bool;
        if(_S927)
        {
            _S928 = b_2 == _S826;
        }
        else
        {
            _S928 = false;
        }
        var _S929 : bool = b_2 == _S838;
        var _S930 : bool;
        if(_S929)
        {
            var _S931 : bool = !scatter_0;
            if(_S931)
            {
                _S930 = true;
            }
            else
            {
                var _S932 : bool = _S827 != u32(1);
                if(_S932)
                {
                    _S930 = _S827 != u32(3);
                }
                else
                {
                    _S930 = false;
                }
            }
        }
        else
        {
            _S930 = false;
        }
        var _S933 : bool;
        if(_S930)
        {
            _S933 = _S827 == u32(2);
        }
        else
        {
            _S933 = false;
        }
        var _S934 : bool;
        if(_S933)
        {
            _S934 = !_S870;
        }
        else
        {
            _S934 = false;
        }
        var _S935 : bool;
        if(_S934)
        {
            _S935 = _S828 != u32(4);
        }
        else
        {
            _S935 = false;
        }
        var _S936 : bool = _S826 == _S825;
        var _S937 : bool;
        if(_S936)
        {
            _S937 = _S828 == u32(0);
        }
        else
        {
            _S937 = false;
        }
        var _S938 : bool;
        if(_S937)
        {
            _S938 = (hit_2.instance_index) == (_S839.instance_index);
        }
        else
        {
            _S938 = false;
        }
        var _S939 : bool;
        if(_S938)
        {
            _S939 = (hit_2.triangle_index) == (_S839.triangle_index);
        }
        else
        {
            _S939 = false;
        }
        var _S940 : bool;
        if(_S939)
        {
            _S940 = _S870;
        }
        else
        {
            _S940 = false;
        }
        var _S941 : bool = select(_S935, _S940, _S928);
        var _S942 : bool;
        if(_S896)
        {
            _S942 = select(scatter_0, _S941, replay_0);
        }
        else
        {
            _S942 = false;
        }
        var _S943 : TreeSample = TreeSample_x24init_0(_S823, _S823, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S942)
        {
            var _S944 : Surface = surface_5;
            var _S945 : bool = isTranslucent_0(_S894);
            var _S946 : u32 = noiseAddress(r_4.seed, b_2);
            var _S947 : TreeSample = sampleLightTree_0(ray_2.origin, _S871.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S945, _S946);
            var _S948 : bool = (any(((_S947.radiance) != _S823)));
            if(_S948)
            {
                var _S949 : f32 = _S895.x;
                var _S950 : f32 = _S895.y;
                var _S951 : u32 = (uniforms_uint.max_bounces);
                var _S952 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S947, _S871.smooth_n, _S944.geometry_n, _S894, _S949, _S950, b_2 < _S951, surface_5.random_state);
                lit_0 = _S952;
            }
            else
            {
                lit_0 = _S823;
            }
            light_1 = _S947;
        }
        else
        {
            light_1 = _S943;
            lit_0 = _S823;
        }
        var _S953 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S954 : bool;
        var _S955 : bool;
        var density_3 : f32;
        var throughput_5 : vec3<f32>;
        if(_S928)
        {
            var _S956 : bool = !_S870;
            if(_S956)
            {
                return _S824;
            }
            var _S957 : u32 = (extractBits((r_4.path), (u32(23)), (u32(1))));
            var _S958 : bool = _S922 != (_S957 == u32(1));
            if(_S958)
            {
                return _S824;
            }
            var throughput_6 : vec3<f32> = throughput_4 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S936)
            {
                _S953 = _S828 == u32(1);
            }
            else
            {
                _S953 = false;
            }
            if(_S953)
            {
                var _S959 : vec3<f32> = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S959 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S936)
            {
                wrong_side_0 = _S828 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S960 : bool = !_S896;
                if(_S960)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S961 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S961 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S824;
                }
                var _S962 : vec3<f32> = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S962 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S936)
            {
                refracted_4 = _S828 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S963 : bool = !_S896;
                if(_S963)
                {
                    return _S824;
                }
                var _S964 : f32 = environmentPdf_0(r_4.dir);
                var _S965 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S894, _S895, is_inside_5, _S964, surface_5.random_state);
                var _S966 : vec3<f32> = pathColor(throughput_6 * _S965 * r_4.radiance, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S966 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S967 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S968 : bool = _S896 != (_S967 == u32(1));
            if(_S968)
            {
                return _S824;
            }
            throughput_5 = throughput_6;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S953 = _S929;
            }
            else
            {
                _S953 = false;
            }
            if(_S953)
            {
                var _S969 : bool = !scatter_0;
                if(_S969)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S970 : bool = _S827 != u32(1);
                    if(_S970)
                    {
                        wrong_side_0 = _S827 != u32(3);
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
                var _S971 : bool = _S827 == u32(2);
                if(_S971)
                {
                    _S849 = _S896;
                }
                else
                {
                    _S849 = false;
                }
                if(_S849)
                {
                    _S849 = !_S870;
                }
                else
                {
                    _S849 = false;
                }
                if(_S849)
                {
                    _S849 = _S828 == u32(4);
                }
                else
                {
                    _S849 = false;
                }
                if(_S849)
                {
                    var _S972 : u32 = noiseAddress(r_4.seed, b_2);
                    var _S973 : SkySample = sampleSky_0(ray_2, surface_5, wavelength_8, _S895, is_inside_5, _S972, surface_5.random_state);
                    var _S974 : vec3<f32> = pathColor(throughput_4 * _S973.color, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S974, 1.0f);
                }
                if(_S971)
                {
                    is_inside_5 = _S896;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S870;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S975 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S976 : bool = !(_S975 > 0.0f);
                    if(_S976)
                    {
                        return _S824;
                    }
                    var _S977 : vec3<f32> = pathColor(throughput_4 * lit_0, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S977, 1.0f);
                }
                if(_S837)
                {
                    is_inside_5 = _S828 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S848;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S978 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S978, 1.0f);
                }
                if(_S837)
                {
                    is_inside_5 = _S828 == u32(1);
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
                    is_inside_5 = !_S870;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S979 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S979, 1.0f);
                }
                return _S824;
            }
            else
            {
                if(_S901)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S980 : bool = b_2 > u32(0);
                    if(_S980)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S914)
                        {
                            var _S981 : vec3<f32> = safeDivide(throughput_4 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S981;
                        }
                        else
                        {
                            if(_S870)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S982 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_8);
                        var _S983 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S982);
                        offer(&((*sel_1)), _S983, _S982 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S896)
                    {
                        var _S984 : vec3<f32> = pathColor(throughput_4 * lit_0, spectral_weight_0, wavelength_8);
                        var candidate_3 : Reservoir = chain_0;
                        if(_S914)
                        {
                            var _S985 : vec3<f32> = safeDivide(_S984, chain_throughput_0);
                            candidate_3.radiance = _S985;
                        }
                        else
                        {
                            if(_S870)
                            {
                                candidate_3 = here_0;
                                var _S986 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S986;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S987 : u32 = (insertBits((_S847), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S988 : u32 = (insertBits((_S987), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S988;
                            }
                        }
                        var _S989 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S984);
                        offer(&((*sel_1)), _S989, _S984 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S896)
                    {
                        var _S990 : bool = environmentMapped_0();
                        _S954 = _S990;
                    }
                    else
                    {
                        _S954 = false;
                    }
                    if(_S954)
                    {
                        var _S991 : u32 = (uniforms_uint.max_bounces);
                        _S955 = b_2 < _S991;
                    }
                    else
                    {
                        _S955 = false;
                    }
                    if(_S955)
                    {
                        var _S992 : u32 = noiseAddress(r_4.seed, b_2);
                        var _S993 : SkySample = sampleSky_0(ray_2, surface_5, wavelength_8, _S895, is_inside_5, _S992, surface_5.random_state);
                        var _S994 : vec3<f32> = pathColor(throughput_4 * _S993.color, spectral_weight_0, wavelength_8);
                        var candidate_4 : Reservoir = chain_0;
                        if(_S914)
                        {
                            var _S995 : vec3<f32> = safeDivide(_S994, chain_throughput_0);
                            candidate_4.radiance = _S995;
                        }
                        else
                        {
                            if(_S870)
                            {
                                candidate_4 = here_0;
                                var _S996 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S996;
                                candidate_4.dir = _S993.dir;
                                candidate_4.radiance = _S993.radiance;
                            }
                            else
                            {
                                var _S997 : u32 = (insertBits((_S847), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S998 : u32 = (insertBits((_S997), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S998;
                            }
                        }
                        var _S999 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S994);
                        offer(&((*sel_1)), _S999, _S994 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_5 = throughput_4;
            density_3 = density_2;
        }
        var _S1000 : bool;
        var _S1001 : bool;
        var straight_0 : bool;
        var _S1002 : bool;
        var _S1003 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S953 = _S929;
            }
            else
            {
                _S953 = false;
            }
            var _S1004 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S1005 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S1006 : u32 = select(_S1004, _S1005, _S928);
            var refracted_5 : bool = _S1006 == u32(1);
            var _S1007 : SampleBSDF = SampleBSDF_x24init_0(_S823, _S823, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S1007;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S953)
            {
                var _S1008 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S1009 : bool = is_inside_5 != (_S1008 == u32(1));
                if(_S1009)
                {
                    return _S824;
                }
                var _S1010 : bool = _S827 == u32(1);
                if(_S1010)
                {
                    var _S1011 : vec3<f32> = (hitPosition((_S839)));
                    dir_11 = _S1011;
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
                    var _S1012 : bool = isTranslucent_0(_S894);
                    if(_S1012)
                    {
                        wrong_side_0 = _S1006 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1013 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S1014 : vec3<f32> = select(r_4.dir, _S1013, _S1010);
                        refracted_4 = (dot(_S871.smooth_n, _S1014) * _S872) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S1010)
                {
                    var _S1015 : vec3<f32> = ray_2.origin;
                    var _S1016 : Surface = surface_5;
                    var _S1017 : vec3<f32> = (vec3<f32>(0) - _S871.smooth_n);
                    var _S1018 : bool = is_inside_5 != refracted_4;
                    var _S1019 : vec3<f32> = select(_S871.smooth_n, _S1017, _S1018);
                    var _S1020 : vec3<f32> = (normalize((dir_11 - (_S1015 + vec3<f32>(_S1016.geometry_offset) * _S1019))));
                    reconnection_1 = _S1020;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S1021 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S1021)
                {
                    return _S824;
                }
                var _S1022 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S1006;
                wrong_side_0 = false;
                reconnection_1 = _S1022;
            }
            else
            {
                var _S1023 : bool = !_S928;
                if(_S1023)
                {
                    var _S1024 : f32 = _S895.x;
                    var _S1025 : f32 = _S895.y;
                    var _S1026 : vec2<f32> = vec2<f32>(0.0f);
                    var _S1027 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S871.smooth_n, _S894, _S1024, _S1025, surface_5.random_state, _S1026);
                    var bsdf_sampled_0 : SampleBSDF = _S1027;
                    var _S1028 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S894.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1029 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S1028.geometry_n, _S894, _S1024, _S1025, bsdf_sampled_0.random_state, _S1026);
                        bsdf_sampled_0.unit_direction = _S1029.unit_direction;
                        bsdf_sampled_0.refracted = _S1029.refracted;
                        bsdf_sampled_0.throughput = _S1029.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S1030 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S1028.geometry_n))) * _S1028.geometry_n;
                            bsdf_sampled_0.unit_direction = _S1030;
                        }
                    }
                    var _S1031 : u32 = bsdf_sampled_0.lobe;
                    var _S1032 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S1033 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S1034 : f32 = bsdf_sampled_0.pdf;
                    var _S1035 : f32 = select(_S1034, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S1035;
                    dir_11 = _S1032;
                    lobe_index_0 = _S1031;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1033;
                }
                else
                {
                    dir_11 = r_4.dir;
                    lobe_index_0 = _S1006;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S953)
            {
                _S954 = true;
            }
            else
            {
                _S954 = _S928;
            }
            var throughput_7 : vec3<f32>;
            var throughput_8 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S954)
            {
                var _S1036 : vec3<f32> = ray_2.unit_direction;
                var _S1037 : vec3<f32> = ((-(_S1036)));
                var _S1038 : f32 = (sign((_S872)));
                var _S1039 : vec3<f32> = _S871.smooth_n * vec3<f32>(_S1038);
                var _S1040 : f32 = dot(_S1039, dir_11);
                var _S1041 : f32 = _S894.roughness;
                var _S1042 : f32 = _S1041 * _S1041;
                var _S1043 : AnisotropicFrame = anisotropicFrame(_S894, _S1039);
                var _S1044 : SheenProfile = sheenProfile(_S1037, _S1039, _S894);
                var _S1045 : CoatFrame = coatFrame(_S894, _S1039);
                var _S1046 : vec3<f32> = coatSeries(_S1045, _S894);
                var _S1047 : vec3<f32> = reflectedHalf(_S1036, dir_11);
                var _S1048 : bool = lobe_index_0 == u32(1);
                if(_S1048)
                {
                    var _S1049 : vec3<f32> = refractedHalf(_S1036, dir_11, _S871.smooth_n, _S895.x, _S895.y);
                    throughput_7 = _S1049;
                }
                else
                {
                    throughput_7 = _S1047;
                }
                var _S1050 : Surface = surface_5;
                var _S1051 : vec3<f32> = coatHalf(_S1037, _S1045, surface_5.random_state);
                var _S1052 : bool = lobe_index_0 == u32(5);
                var _S1053 : vec3<f32> = select(_S1051, throughput_7, _S1052);
                var _S1054 : bool = lobe_index_0 == u32(0);
                if(_S1054)
                {
                    _S955 = true;
                }
                else
                {
                    _S955 = lobe_index_0 == u32(6);
                }
                if(_S955)
                {
                    _S1000 = true;
                }
                else
                {
                    _S1000 = _S1052;
                }
                if(_S1000)
                {
                    var _S1055 : vec3<f32> = sampledHalf(_S1037, _S1039, _S1042, _S1043, _S1050.random_state);
                    throughput_8 = _S1055;
                }
                else
                {
                    throughput_8 = throughput_7;
                }
                var _S1056 : f32 = _S895.x;
                var _S1057 : f32 = _S895.y;
                var _S1058 : Weights = lobeWeights(_S1036, _S1037, _S1039, throughput_8, _S1053, _S1043, _S1044, _S1045, _S1046, _S894, _S1056, _S1057);
                var _S1059 : f32 = abs(_S872);
                var _S1060 : f32 = vndfPDF(_S1037, throughput_8, _S1039, _S1059, _S1042, _S1043, _S1058.v_dot_h);
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S1061 : f32 = diffusePDF(_S1040, _S1059, _S894, _S1058);
                        var _S1062 : vec3<f32> = diffuseBSDF(dir_11, _S1039, _S894, _S1058);
                        density_5 = _S1061;
                        chain_throughput_1 = _S1062;
                    }
                case u32(1):
                    {
                        var _S1063 : f32 = refractPDF(dot(dir_11, throughput_8), _S1060, _S1058, _S1056, _S1057);
                        var _S1064 : vec3<f32> = refractBSDF(dir_11, _S1039, _S1042, _S1043, _S894, _S1058);
                        density_5 = _S1063;
                        chain_throughput_1 = _S1064;
                    }
                case u32(4):
                    {
                        var _S1065 : f32 = sheenVelvetPDF(_S1040, _S1059, _S1058);
                        var _S1066 : vec3<f32> = sheenVelvetBSDF(dir_11, _S1037, _S1039, _S894, _S1058);
                        density_5 = _S1065;
                        chain_throughput_1 = _S1066;
                    }
                case u32(5):
                    {
                        var _S1067 : f32 = coatPDF(_S1037, _S1053, _S1045, _S1058);
                        var _S1068 : vec3<f32> = coatBSDF(_S1058);
                        density_5 = _S1067;
                        chain_throughput_1 = _S1068;
                    }
                default :
                    {
                        var _S1069 : f32 = reflectPDF(_S1060, _S1058);
                        var _S1070 : vec3<f32> = reflectBSDF(dir_11, _S1039, _S1042, _S1043, _S1058);
                        density_5 = _S1069;
                        chain_throughput_1 = _S1070;
                    }
                }
                var _S1071 : bool = density_5 > 0.0f;
                if(_S1071)
                {
                    var _S1072 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, _S1050.random_state, _S1048, lobe_index_0, density_5);
                    lobe_2 = _S1072;
                }
            }
            var _S1073 : bool = lobe_index_0 == u32(0);
            if(_S1073)
            {
                _S955 = true;
            }
            else
            {
                _S955 = lobe_index_0 == u32(4);
            }
            if(_S955)
            {
                _S1000 = true;
            }
            else
            {
                _S1000 = lobe_index_0 == u32(6);
            }
            var _S1074 : bool = lobe_index_0 == u32(5);
            var _S1075 : f32 = select(_S894.roughness, _S894.coat_roughness, _S1074);
            var _S1076 : bool = !_S1000;
            if(_S1076)
            {
                var _S1077 : bool = _S1075 == 0.0f;
                if(_S1077)
                {
                    _S1001 = true;
                }
                else
                {
                    var _S1078 : bool = lobe_index_0 == u32(1);
                    if(_S1078)
                    {
                        _S1001 = (_S895.x) == (_S895.y);
                    }
                    else
                    {
                        _S1001 = false;
                    }
                }
            }
            else
            {
                _S1001 = false;
            }
            var _S1079 : bool = lobe_index_0 == u32(1);
            if(_S1079)
            {
                straight_0 = (_S894.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S1080 : bool = isTranslucent_0(_S894);
            if(_S1080)
            {
                _S1002 = _S1073;
            }
            else
            {
                _S1002 = false;
            }
            if(_S1002)
            {
                _S1003 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S1003 = false;
            }
            var _S1081 : bool;
            if(_S896)
            {
                _S1081 = !_S1001;
            }
            else
            {
                _S1081 = false;
            }
            var _S1082 : bool;
            if(_S1081)
            {
                _S1082 = !wrong_side_0;
            }
            else
            {
                _S1082 = false;
            }
            var _S1083 : bool;
            if(_S1082)
            {
                var _S1084 : f32 = lobe_2.pdf;
                var _S1085 : vec3<f32> = ray_2.origin;
                var _S1086 : bool = isTranslucent_0(_S894);
                var _S1087 : vec3<f32> = select(_S871.smooth_n, _S823, _S1086);
                var _S1088 : vec3<f32> = ray_2.origin;
                var _S1089 : Surface = surface_5;
                var _S1090 : vec3<f32> = (vec3<f32>(0) - _S871.smooth_n);
                var _S1091 : vec3<f32> = select(_S871.smooth_n, _S1090, _S1003);
                var _S1092 : NEEVertex = NEEVertex_x24init_0(false, _S1084, _S1085, _S1087, _S1088 + vec3<f32>(_S1089.geometry_offset) * _S1091);
                nee_vertex_0 = _S1092;
            }
            else
            {
                var _S1093 : bool = lobe_index_0 != u32(1);
                if(_S1093)
                {
                    _S1083 = true;
                }
                else
                {
                    _S1083 = (_S895.x) != (_S895.y);
                }
                if(_S1083)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S1094 : bool = (lobe_2.pdf) > 0.0f;
            if(_S1094)
            {
                if(_S1000)
                {
                    _S1083 = true;
                }
                else
                {
                    _S1083 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1083 = false;
            }
            var _S1095 : bool = (lobe_2.pdf) > 0.0f;
            var _S1096 : bool;
            if(_S1095)
            {
                if(_S1000)
                {
                    _S1096 = true;
                }
                else
                {
                    _S1096 = _S1075 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1096 = false;
            }
            var _S1097 : bool;
            if(_S928)
            {
                var _S1098 : bool = !_S1083;
                if(_S1098)
                {
                    return _S824;
                }
                var _S1099 : bool = _S828 != u32(1);
                if(_S1099)
                {
                    _S1097 = _S828 != u32(2);
                }
                else
                {
                    _S1097 = false;
                }
                if(_S1097)
                {
                    var _S1100 : f32 = lobe_2.pdf;
                    var _S1101 : f32 = select(0.0f, _S1100, _S896);
                    var _S1102 : f32 = escapeWeight_0(_S1101, r_4.dir);
                    if(_S936)
                    {
                        is_inside_5 = _S834;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S1103 : f32 = select(1.0f, _S1102, is_inside_5);
                    return Shift_x24init_0(throughput_5 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S1103) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S1104 : vec3<f32> = throughput_5 * vec3<f32>(lobe_2.pdf);
                var _S1105 : f32 = density_3 * lobe_2.pdf;
                throughput_7 = _S1104;
                density_5 = _S1105;
            }
            else
            {
                throughput_7 = throughput_5;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S1097 = b_2 <= _S838;
            }
            else
            {
                _S1097 = false;
            }
            var _S1106 : bool;
            if(_S1097)
            {
                _S1106 = _S870;
            }
            else
            {
                _S1106 = false;
            }
            var _S1107 : bool;
            if(_S1106)
            {
                _S1107 = _S1083;
            }
            else
            {
                _S1107 = false;
            }
            var _S1108 : bool;
            if(_S1107)
            {
                _S1108 = true;
            }
            else
            {
                if(_S953)
                {
                    _S1108 = !_S1096;
                }
                else
                {
                    _S1108 = false;
                }
            }
            if(_S1108)
            {
                return _S824;
            }
            if(_S953)
            {
                var _S1109 : vec3<f32> = throughput_7 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1110 : f32 = lobe_2.pdf;
                throughput_8 = _S1109;
                survival_probability_0 = _S1110;
            }
            else
            {
                var _S1111 : vec3<f32> = throughput_7 * max(lobe_2.throughput, _S823);
                throughput_8 = _S1111;
                survival_probability_0 = density_5;
            }
            var _S1112 : bool;
            if(_S901)
            {
                _S1112 = !_S914;
            }
            else
            {
                _S1112 = false;
            }
            var _S1113 : bool;
            if(_S1112)
            {
                _S1113 = _S870;
            }
            else
            {
                _S1113 = false;
            }
            var _S1114 : bool;
            if(_S1113)
            {
                _S1114 = _S1083;
            }
            else
            {
                _S1114 = false;
            }
            if(_S1114)
            {
                chain_0 = here_0;
                var _S1115 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1116 : u32 = select(u32(0), u32(1), _S896);
                var _S1117 : u32 = (insertBits((_S1115), (_S1116), (u32(21)), (u32(1))));
                chain_0.path = _S1117;
                var _S1118 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S1118;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_8;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1119 : Vertex = Vertex_x24init_0(_S1096, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S1119;
            var _S1120 : f32 = lobe_2.pdf;
            var _S1121 : bool;
            if(_S1079)
            {
                _S1121 = (_S895.x) == (_S895.y);
            }
            else
            {
                _S1121 = false;
            }
            var _S1122 : f32 = select(_S1120, sky_pdf_0, _S1121);
            var _S1123 : bool;
            if(refracted_4)
            {
                _S1123 = !_S1003;
            }
            else
            {
                _S1123 = false;
            }
            var is_inside_6 : bool;
            if(_S1123)
            {
                var _S1124 : bool = !is_inside_5;
                is_inside_6 = _S1124;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S1125 : Surface = surface_5;
            var _S1126 : f32 = select(_S1125.geometry_offset, 0.0f, straight_0);
            var _S1127 : vec3<f32> = (vec3<f32>(0) - _S871.smooth_n);
            var _S1128 : bool = is_inside_6 != _S1003;
            var _S1129 : vec3<f32> = select(_S871.smooth_n, _S1127, _S1128);
            var _S1130 : vec3<f32> = ray_2.origin + vec3<f32>(_S1126) * _S1129;
            ray_2.origin = _S1130;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_8;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1122;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            straight_0 = false;
            throughput_2 = throughput_5;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S901)
        {
            if(_S848)
            {
                var _S1131 : vec3<f32> = pathColor(throughput_2 * emission_1, spectral_weight_0, wavelength_8);
                var candidate_5 : Reservoir = chain_0;
                var _S1132 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1133 : bool = _S1132 == u32(1);
                if(_S1133)
                {
                    var _S1134 : vec3<f32> = safeDivide(_S1131, chain_throughput_0);
                    candidate_5.radiance = _S1134;
                }
                var _S1135 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S1131);
                offer(&((*sel_1)), _S1135, _S1131 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S848)
            {
                _S953 = true;
            }
            else
            {
                _S953 = scatter_0;
            }
            if(_S953)
            {
                var _S1136 : f32 = survivalProbability(abs(throughput_2), density_5);
                survival_probability_0 = _S1136;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1137 : u32 = noiseAddress(r_4.seed, b_2);
            var _S1138 : Random = draw(_S1137, u32(8));
            var _S1139 : bool = survival_probability_0 < (_S1138.value);
            if(_S1139)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1140 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S1140;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1141 : f32 = density_5 * survival_probability_0;
            density_2 = _S1141;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1142 : Ray = ray_2;
        var _S1143 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S953 = _S929;
        }
        else
        {
            _S953 = false;
        }
        if(_S953)
        {
            wrong_side_0 = _S827 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1144 : f32 = select(4.294967296e+09f, _S1143, wrong_side_0);
        var _S1145 : Hit;
        if(straight_0)
        {
            _S1145 = hit_2;
        }
        else
        {
            _S1145 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1146 : Hit = (traverseInstanceBVH((_S1142), (_S854), (_S1144), (_S1145)));
        hit_2 = _S1146;
        if(replay_0)
        {
            refracted_4 = _S929;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S954 = _S827 == u32(1);
        }
        else
        {
            _S954 = false;
        }
        if(_S954)
        {
            _S955 = (hit_2.instance_index) == (_S839.instance_index);
        }
        else
        {
            _S955 = false;
        }
        if(_S955)
        {
            _S1000 = (hit_2.triangle_index) == (_S839.triangle_index);
        }
        else
        {
            _S1000 = false;
        }
        if(_S1000)
        {
            hit_2.uv = _S839.uv;
            var _S1147 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1147;
        }
        if(replay_0)
        {
            _S1001 = _S929;
        }
        else
        {
            _S1001 = false;
        }
        if(_S1001)
        {
            _S1002 = _S827 == u32(3);
        }
        else
        {
            _S1002 = false;
        }
        if(_S1002)
        {
            _S1003 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S1003 = false;
        }
        if(_S1003)
        {
            return _S824;
        }
        var _S1148 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1148)
        {
            var _S1149 : bool = !nee_vertex_0.none;
            var _S1150 : f32 = select(0.0f, sky_pdf_0, _S1149);
            var _S1151 : f32 = escapeWeight_0(_S1150, ray_2.unit_direction);
            var _S1152 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1153 : vec3<f32> = pathColor(throughput_2 * _S1152, spectral_weight_0, wavelength_8);
            if(replay_0)
            {
                if(_S929)
                {
                    is_inside_5 = _S827 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S1153 * vec3<f32>(_S1151) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
                }
                if(_S837)
                {
                    is_inside_5 = _S834;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S825;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !prev_0.rough;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S1153 * vec3<f32>(_S1151), 1.0f);
                }
                return _S824;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S1154 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1155 : bool = _S1154 == u32(1);
            if(_S1155)
            {
                var _S1156 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1157 : bool = _S1156 == b_2;
                var _S1158 : f32 = select(_S1151, 1.0f, _S1157);
                var _S1159 : vec3<f32> = safeDivide(_S1153 * vec3<f32>(_S1158), chain_throughput_0);
                candidate_6.radiance = _S1159;
            }
            else
            {
                var _S1160 : bool = prev_0.rough;
                if(_S1160)
                {
                    var _S1161 : u32 = (insertBits((_S847), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S1162 : u32 = (insertBits((_S1161), (u32(3)), (u32(10)), (u32(2))));
                    var _S1163 : u32 = (insertBits((_S1162), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1164 : bool = prev_0.inside;
                    var _S1165 : u32 = select(u32(0), u32(1), _S1164);
                    var _S1166 : u32 = (insertBits((_S1163), (_S1165), (u32(22)), (u32(1))));
                    candidate_6.path = _S1166;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S1167 : vec3<f32> = _S1153 * vec3<f32>(_S1151);
            var _S1168 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S1167);
            offer(&((*sel_1)), _S1168, _S1167 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1169 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1169;
        var _S1170 : u32 = b_2 + u32(1);
        b_2 = _S1170;
    }
    return _S824;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S1171 : vec3<f32> = vec3<f32>(0.0f);
    var _S1172 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1171, 0.0f, vec4<u32>(u32(0)), _S1171, _S1171), 0.0f, _S1171, u32(0));
    var sel_2 : Selection = _S1172;
    var _S1173 : bool = (r_5.w) <= 0.0f;
    if(_S1173)
    {
        return Shift_x24init_0(_S1171, 0.0f);
    }
    var _S1174 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S1174;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S1175 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S1175;
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
        var _S1176 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S1177 : u32 = (_S1176 + u32(63)) / u32(64);
        var _S1178 : bool = group_0 < _S1177;
        if(_S1178)
        {
            var _S1179 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S1180 : bool = _S1179 < _S1176;
            if(_S1180)
            {
                var _S1181 : u32 = (queued_shifts[(u32(83) + start_4 + _S1179)]);
                return _S1181;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S1177;
        var start_5 : u32 = start_4 + _S1176;
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
    var _S1182 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S1183 : u32 = t_5;
        var _S1184 : bool = (bins_1[t_5]) < u32(40);
        if(_S1184)
        {
            var _S1185 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S1183]]), u32(1));
            slots_0[t_5] = _S1185;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S1186 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S1186)
    {
        var _S1187 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S1188 : bool = _S1187 > u32(0);
        if(_S1188)
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
                var _S1189 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S1189;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S1190 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S1187)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S1190;
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
        var _S1191 : u32 = t_5;
        var _S1192 : bool = (bins_1[t_5]) < u32(40);
        if(_S1192)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S1191]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S1193 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S1193)
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
            var _S1194 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S1194 + u32(63)) / u32(64);
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
    var _S1195 : vec3<f32> = (((view_0) * (position_0 - camera_0)));
    var _S1196 : vec2<f32> = vec2<f32>(0.5f);
    var _S1197 : vec2<f32> = _S1195.xy / vec2<f32>(_S1195.z) * _S1196 + _S1196;
    var _S1198 : vec2<f32> = vec2<f32>(_S1197.x, 1.0f - _S1197.y);
    var _S1199 : vec2<u32> = (uniforms_uint.render_size);
    return _S1198 * vec2<f32>(_S1199);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S1200 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S1201 : bool;
    if(_S1200)
    {
        var _S1202 : vec2<u32> = (uniforms_uint.render_size);
        _S1201 = (all((q_0 < vec2<i32>(_S1202))));
    }
    else
    {
        _S1201 = false;
    }
    if(_S1201)
    {
        var _S1203 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S1201 = (bitcast<f32>((_S1203.w))) > 0.0f;
    }
    else
    {
        _S1201 = false;
    }
    return _S1201;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S1204 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S1205 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1206 : vec2<f32> = project_0(_S1204, _S1205, dom_3.x1);
    var _S1207 : vec2<i32> = vec2<i32>(floor(_S1206));
    var _S1208 : bool = previousValid_0(_S1207);
    var _S1209 : bool = !_S1208;
    if(_S1209)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1210 : Domain = (previousDomain((_S1207)));
    var _S1211 : bool = (_S1210.hit.instance_index) == (dom_3.hit.instance_index);
    var _S1212 : bool;
    if(_S1211)
    {
        var _S1213 : f32 = distance(_S1210.x1, dom_3.x1);
        var _S1214 : f32 = dom_3.hit.distance * 8.0f;
        var _S1215 : vec2<u32> = (uniforms_uint.render_size);
        _S1212 = _S1213 <= (_S1214 / f32(_S1215.x));
    }
    else
    {
        _S1212 = false;
    }
    if(_S1212)
    {
        return _S1207;
    }
    var _S1216 : vec2<f32> = vec2<f32>(p_9 + _S1207) + vec2<f32>(1.0f);
    var _S1217 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S1218 : vec3<f32> = (uniforms_float.camera_position);
    var _S1219 : vec2<f32> = project_0(_S1217, _S1218, _S1210.x1);
    var _S1220 : vec2<i32> = vec2<i32>(floor(_S1216 - _S1219));
    var _S1221 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1222 : bool = previousValid_0(_S1220);
    var _S1223 : vec2<i32> = select(_S1221, _S1220, _S1222);
    return _S1223;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S1224 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S1225 : bool;
    if(_S1224)
    {
        _S1225 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S1225 = false;
    }
    if(_S1225)
    {
        _S1225 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S1225 = false;
    }
    if(_S1225)
    {
        _S1225 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S1225 = false;
    }
    return _S1225;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1226 : vec3<f32> = vec3<f32>(0.0f);
    var _S1227 : Domain = Domain_x24init_0(_S1226, _S1226, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1227;
    var _S1228 : bool = t_8 > u32(1);
    var _S1229 : bool;
    if(_S1228)
    {
        _S1229 = true;
    }
    else
    {
        var _S1230 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1229 = !_S1230;
    }
    if(_S1229)
    {
        return false;
    }
    var _S1231 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1232 : bool = (_S1231.x) < i32(0);
    if(_S1232)
    {
        return false;
    }
    var _S1233 : bool = t_8 == u32(0);
    if(_S1233)
    {
        var _S1234 : Reservoir = (loadReservoir(reservoir_prev, (_S1231)));
        var _S1235 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1234);
        (*job_2) = _S1235;
    }
    else
    {
        var _S1236 : Domain = (previousDomain((_S1231)));
        var _S1237 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1238 : ShiftJob = ShiftJob_x24init_0(_S1236, _S1237);
        (*job_2) = _S1238;
    }
    var _S1239 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1239)
    {
        if(_S1233)
        {
            _S1229 = true;
        }
        else
        {
            var _S1240 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1229 = !_S1240;
        }
    }
    else
    {
        _S1229 = false;
    }
    return _S1229;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1241 : ptr<function, array<u32, i32(3)>>)
{
    var _S1242 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S1243 : vec3<f32> = vec3<f32>(0.0f);
        var _S1244 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1243, _S1243, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1243, 0.0f, vec4<u32>(u32(0)), _S1243, _S1243));
        var job_3 : ShiftJob = _S1244;
        var _S1245 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1245)
        {
            var _S1246 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1246;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1241) = bins_2;
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
        var _S1247 : u32 = t_11;
        var _S1248 : bool = (bins_3[t_11]) < u32(40);
        if(_S1248)
        {
            var _S1249 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1247]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1250 : bool = local_invocation_index_2 < u32(40);
    if(_S1250)
    {
        var _S1251 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1252 : bool = _S1251 > u32(0);
        if(_S1252)
        {
            var _S1253 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1251)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1254 : vec2<u32> = global_invocation_id_1.xy;
    var _S1255 : vec2<i32> = vec2<i32>(_S1254 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_7 : u32 = local_invocation_index_3;
    loop
    {
        if(i_7 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S1256 : vec2<i32> = _S1255 + vec2<i32>(i32(i_7 % u32(24)), i32(i_7 / u32(24)));
        var _S1257 : bool = (all((_S1256 >= vec2<i32>(i32(0)))));
        var _S1258 : bool;
        if(_S1257)
        {
            var _S1259 : vec2<u32> = (uniforms_uint.render_size);
            _S1258 = (all((_S1256 < vec2<i32>(_S1259))));
        }
        else
        {
            _S1258 = false;
        }
        if(_S1258)
        {
            var _S1260 : vec4<u32> = (textureLoad(reservoir_prev, (_S1256), (u32(0)), 0));
            var _S1261 : u32 = _S1260.x;
            var _S1262 : bool = (bitcast<f32>((_S1260.z))) > 0.0f;
            var _S1263 : u32 = select(u32(0), _S1261, _S1262);
            seed_2 = _S1263;
        }
        else
        {
            seed_2 = u32(0);
        }
        duplication_seeds_0[i_7] = seed_2;
        var i_8 : u32 = i_7 + u32(64);
        i_7 = i_8;
    }
    workgroupBarrier();
    var _S1264 : u32 = local_invocation_id_0.y;
    var _S1265 : u32 = local_invocation_id_0.x;
    var _S1266 : u32 = duplication_seeds_0[(_S1264 + u32(8)) * u32(24) + _S1265 + u32(8)];
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
            var _S1267 : bool = (duplication_seeds_0[(_S1264 + seed_2) * u32(24) + _S1265 + x_1]) == _S1266;
            var _S1268 : u32 = select(u32(0), u32(1), _S1267);
            var count_2 : u32 = count_1 + _S1268;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1269 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1270 : bool = _S1266 != u32(0);
    var _S1271 : f32 = select(0.0f, _S1269, _S1270);
    textureStore(duplication_out, (vec2<i32>(_S1254)), 0, (vec4<u32>((bitcast<u32>((_S1271))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1272 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1272;
    var _S1273 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1273;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1274 : f32 = resamplingTarget(r_7.f);
    var _S1275 : f32 = sel_4.w_sum / _S1274;
    var _S1276 : bool = _S1274 > 0.0f;
    var _S1277 : f32 = select(0.0f, _S1275, _S1276);
    r_7.w = _S1277;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1278 : vec2<u32> = global_invocation_id_2.xy;
    var _S1279 : vec2<i32> = vec2<i32>(_S1278);
    var _S1280 : vec3<f32> = vec3<f32>(0.0f);
    var _S1281 : Domain = Domain_x24init_0(_S1280, _S1280, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1281;
    var _S1282 : bool = (currentDomain((_S1279), &(dom_5)));
    var _S1283 : bool = !_S1282;
    if(_S1283)
    {
        storeReservoir(reservoir_prev_out, (_S1279), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1280, 0.0f, vec4<u32>(u32(0)), _S1280, _S1280)), (dom_5.hit));
        var _S1284 : vec2<f32> = vec2<f32>(_S1278);
        var _S1285 : vec2<u32> = (uniforms_uint.render_size);
        var _S1286 : vec2<f32> = _S1284 / vec2<f32>(_S1285.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1287 : vec3<f32> = vec3<f32>(_S1286, 1.0f);
        var _S1288 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1289 : vec3<f32> = (normalize(((((_S1288) * (_S1287))))));
        var _S1290 : vec3<f32> = environment_0(_S1289);
        textureStore(compute_out, (_S1279), (u32(0)), (vec4<f32>(_S1290, 1.0f)));
        var _S1291 : u32 = (uniforms_uint.is_temporal);
        var _S1292 : bool = _S1291 == u32(1);
        if(_S1292)
        {
            textureStore(compute_out, (_S1279), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1293 : Reservoir = (loadReservoir(reservoir_temp, (_S1279)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1293.c;
    loop
    {
        var _S1294 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1294)
        {
        }
        else
        {
            break;
        }
        var _S1295 : vec2<i32> = partner_0(_S1279, t_13);
        var neighbor_0 : Domain = _S1281;
        var _S1296 : bool = (currentDomain((_S1295), &(neighbor_0)));
        if(_S1296)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1297 : vec4<u32> = (textureLoad(reservoir_temp, (_S1295), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1297.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1298 : f32 = _S1293.c / max(count_3, 1.0f);
    var _S1299 : f32 = resamplingTarget(_S1293.f);
    var _S1300 : bool = count_3 == 0.0f;
    var _S1301 : f32 = select(0.0f, 1.0f, _S1300);
    var _S1302 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1280, 0.0f, vec4<u32>(u32(0)), _S1280, _S1280), 0.0f, _S1280, u32(0));
    var sel_5 : Selection = _S1302;
    var _S1303 : u32 = (uniforms_uint.frame);
    var _S1304 : u32 = hash(_S1303);
    var _S1305 : u32 = global_invocation_id_2.x;
    var _S1306 : vec2<u32> = (uniforms_uint.render_size);
    var _S1307 : u32 = stream(_S1304, _S1305 + _S1306.x * global_invocation_id_2.y);
    var _S1308 : u32 = stream(_S1307, u32(195));
    sel_5.random_state = _S1308;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1301;
    loop
    {
        var _S1309 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1309)
        {
        }
        else
        {
            break;
        }
        var _S1310 : vec2<i32> = partner_0(_S1279, t_13);
        var neighbor_dom_0 : Domain = _S1281;
        var _S1311 : bool = (currentDomain((_S1310), &(neighbor_dom_0)));
        if(_S1311)
        {
            var _S1312 : Reservoir = (loadReservoir(reservoir_temp, (_S1310)));
            var _S1313 : vec4<u32> = (textureLoad(shift_data, (_S1310), (t_13), 0));
            var _S1314 : vec4<f32> = (bitcast<vec4<f32>>((_S1313)));
            var _S1315 : vec4<u32> = (textureLoad(shift_data, (_S1279), (t_13), 0));
            var _S1316 : vec4<f32> = (bitcast<vec4<f32>>((_S1315)));
            var _S1317 : f32 = (_S1312.c + _S1298) / c_sum_0;
            var _S1318 : bool = _S1299 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1318)
            {
                var _S1319 : f32 = _S1317 * _S1298 * _S1299;
                var _S1320 : f32 = _S1298 * _S1299;
                var _S1321 : f32 = resamplingTarget(_S1316.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1319 / (_S1320 + _S1312.c * _S1321);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1322 : f32 = resamplingTarget(_S1312.f);
            var _S1323 : vec3<f32> = _S1314.xyz;
            var _S1324 : Shift = Shift_x24init_0(_S1323, _S1314.w);
            var _S1325 : f32 = _S1317 * _S1312.c * _S1322;
            var _S1326 : f32 = _S1312.c * _S1322;
            var _S1327 : f32 = resamplingTarget(_S1323);
            offerShifted(&(sel_5), _S1312, _S1324, _S1325 / (_S1326 + _S1298 * _S1327));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1293, Shift_x24init_0(_S1293.f, 1.0f), canonical_mis_0);
    var _S1328 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1279), (_S1328), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1279), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1329 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1330 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1331 : f32 = (sign((dot(_S1330, _S1329.smooth_n))));
    var _S1332 : vec3<f32> = _S1329.material.emissive * vec3<f32>(max(_S1331, 0.0f));
    var _S1333 : vec3<f32> = select(_S1332, _S1280, _S1329.skip);
    var _S1334 : vec3<f32> = clamp(sel_5.color + _S1333, vec3<f32>(-65519.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1279), (u32(0)), (vec4<f32>(_S1334, 1.0f)));
    var _S1335 : u32 = (uniforms_uint.is_temporal);
    var _S1336 : bool = _S1335 == u32(1);
    if(_S1336)
    {
        textureStore(compute_out, (_S1279), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1337 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1338 : bool = _S1337 != u32(4294967295);
    if(_S1338)
    {
        var _S1339 : vec2<i32> = vec2<i32>((vec2<u32>(_S1337, (_S1337 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1340 : vec3<f32> = vec3<f32>(0.0f);
        var _S1341 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1340, _S1340, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1340, 0.0f, vec4<u32>(u32(0)), _S1340, _S1340));
        var shift_job_0 : ShiftJob = _S1341;
        var _S1342 : u32 = (_S1337 >> (u32(28)));
        var _S1343 : bool = spatialJob_0(_S1339, _S1342, &(shift_job_0));
        var _S1344 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1339), (_S1342), (vec4<u32>((bitcast<vec3<u32>>((_S1344.f))), (bitcast<u32>((_S1344.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1345 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1346 : array<u32, i32(3)>;
    spatialBins_0(_S1345, &(_S1346));
    var _S1347 : array<u32, i32(3)> = _S1346;
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
        var _S1348 : bool = (_S1347[t_16]) == u32(40);
        if(_S1348)
        {
            textureStore(shift_data_out, (_S1345), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1345, _S1347, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1349 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1349));
    countShifts_0(_S1349, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1350 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1351 : bool = _S1350 != u32(4294967295);
    if(_S1351)
    {
        var _S1352 : vec2<i32> = vec2<i32>((vec2<u32>(_S1350, (_S1350 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1353 : vec3<f32> = vec3<f32>(0.0f);
        var _S1354 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1353, _S1353, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1353, 0.0f, vec4<u32>(u32(0)), _S1353, _S1353));
        var shift_job_1 : ShiftJob = _S1354;
        var _S1355 : u32 = (_S1350 >> (u32(28)));
        var _S1356 : bool = temporalJob_0(_S1352, _S1355, &(shift_job_1));
        var _S1357 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1352), (_S1355), (vec4<u32>((bitcast<vec3<u32>>((_S1357.f))), (bitcast<u32>((_S1357.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1358 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1359 : array<u32, i32(3)>;
    temporalBins_0(_S1358, &(_S1359));
    var _S1360 : array<u32, i32(3)> = _S1359;
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
        var _S1361 : bool = (_S1360[t_18]) == u32(40);
        if(_S1361)
        {
            textureStore(temporal_shifts_out, (_S1358), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1358, _S1360, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1362 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1362));
    countShifts_0(_S1362, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1363 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1364 : vec3<f32> = vec3<f32>(0.0f);
    var _S1365 : Domain = Domain_x24init_0(_S1364, _S1364, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1365;
    var _S1366 : bool = (currentDomain((_S1363), &(dom_6)));
    var _S1367 : bool = !_S1366;
    if(_S1367)
    {
        storeReservoir(reservoir_temp_out, (_S1363), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1364, 0.0f, vec4<u32>(u32(0)), _S1364, _S1364)), (dom_6.hit));
        return;
    }
    var _S1368 : Reservoir = (loadReservoir(reservoir_initial, (_S1363)));
    var _S1369 : vec2<i32> = temporalNeighbor_0(_S1363, dom_6);
    var _S1370 : bool = (_S1369.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1370)
    {
        var _S1371 : Reservoir = (loadReservoir(reservoir_prev, (_S1369)));
        var _S1372 : vec4<u32> = (textureLoad(duplication, (_S1369), 0, 0));
        var _S1373 : f32 = (bitcast<f32>((_S1372.x)));
        var _S1374 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1375 : bool = _S1374 == u32(1);
        var _S1376 : f32 = select(0.0f, _S1373, _S1375);
        var _S1377 : f32 = (mix((20.0f), (1.0f), (pow(_S1376, 0.10000000149011612f))));
        var _S1378 : f32 = min(_S1371.c, _S1377);
        var _S1379 : vec4<u32> = (textureLoad(temporal_shifts, (_S1363), (u32(0)), 0));
        var _S1380 : vec4<f32> = (bitcast<vec4<f32>>((_S1379)));
        var _S1381 : vec4<f32> = vec4<f32>(_S1368.f, 1.0f);
        var _S1382 : Domain = (previousDomain((_S1369)));
        var _S1383 : bool = sameDomain_0(_S1382, dom_6);
        var _S1384 : bool = !_S1383;
        var to_previous_0 : vec4<f32>;
        if(_S1384)
        {
            var _S1385 : vec4<u32> = (textureLoad(temporal_shifts, (_S1363), (u32(1)), 0));
            var _S1386 : vec4<f32> = (bitcast<vec4<f32>>((_S1385)));
            to_previous_0 = _S1386;
        }
        else
        {
            to_previous_0 = _S1381;
        }
        var _S1387 : f32 = resamplingTarget(_S1368.f);
        var _S1388 : f32 = resamplingTarget(_S1371.f);
        var _S1389 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1364, 0.0f, vec4<u32>(u32(0)), _S1364, _S1364), 0.0f, _S1364, u32(0));
        var sel_6 : Selection = _S1389;
        var _S1390 : u32 = (uniforms_uint.frame);
        var _S1391 : u32 = hash(_S1390);
        var _S1392 : u32 = global_invocation_id_7.x;
        var _S1393 : vec2<u32> = (uniforms_uint.render_size);
        var _S1394 : u32 = stream(_S1391, _S1392 + _S1393.x * global_invocation_id_7.y);
        var _S1395 : u32 = stream(_S1394, u32(194));
        sel_6.random_state = _S1395;
        var _S1396 : f32 = _S1368.c * _S1387;
        var _S1397 : f32 = resamplingTarget(to_previous_0.xyz);
        var _S1398 : f32 = _S1396 / (_S1396 + _S1378 * _S1397);
        var _S1399 : f32 = _S1378 * _S1388;
        var _S1400 : vec3<f32> = _S1380.xyz;
        var _S1401 : f32 = resamplingTarget(_S1400);
        var _S1402 : f32 = _S1399 / (_S1399 + _S1368.c * _S1401);
        var _S1403 : vec2<f32> = vec2<f32>(_S1398, _S1402);
        offerShifted(&(sel_6), _S1368, Shift_x24init_0(_S1368.f, 1.0f), _S1398);
        offerShifted(&(sel_6), _S1371, Shift_x24init_0(_S1400, _S1380.w), _S1402);
        var _S1404 : Reservoir = finalize(sel_6, _S1368.c + _S1378);
        r_8 = _S1404;
    }
    else
    {
        r_8 = _S1368;
    }
    storeReservoir(reservoir_temp_out, (_S1363), (r_8), (dom_6.hit));
    return;
}

fn noiseOrigin( p_12 : vec2<u32>,  k_1 : u32) -> u32
{
    var _S1405 : u32 = ((((p_12.x) >> (u32(11)))) | ((((((p_12.y) >> (u32(11)))) << (u32(4))))));
    var _S1406 : vec2<u32> = noiseOffset(u32(8192) + ((k_1 >> (u32(10)))) + ((_S1405 << (u32(20)))));
    var _S1407 : vec2<u32> = ((p_12 + _S1406) & (vec2<u32>(u32(2047))));
    return ((((_S1407.x) | ((((_S1407.y) << (u32(11))))))) | (((((k_1 & (u32(1023)))) << (u32(22))))));
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1408 : vec2<u32> = global_invocation_id_8.xy;
    var _S1409 : vec2<i32> = vec2<i32>(_S1408);
    var _S1410 : vec3<f32> = vec3<f32>(0.0f);
    var _S1411 : Domain = Domain_x24init_0(_S1410, _S1410, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1411;
    var _S1412 : bool = (currentDomain((_S1409), &(dom_7)));
    var _S1413 : bool = !_S1412;
    if(_S1413)
    {
        storeReservoir(reservoir_initial_out, (_S1409), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1410, 0.0f, vec4<u32>(u32(0)), _S1410, _S1410)), (dom_7.hit));
        return;
    }
    var _S1414 : u32 = (uniforms_uint.frame);
    var _S1415 : u32 = hash(_S1414);
    var _S1416 : u32 = global_invocation_id_8.x;
    var _S1417 : vec2<u32> = (uniforms_uint.render_size);
    var _S1418 : u32 = global_invocation_id_8.y;
    var _S1419 : u32 = stream(_S1415, _S1416 + _S1417.x * _S1418);
    var _S1420 : vec2<u32> = (uniforms_uint.render_size);
    var _S1421 : u32 = stream(_S1416 + _S1420.x * _S1418, u32(512));
    var _S1422 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1410, 0.0f, vec4<u32>(u32(0)), _S1410, _S1410);
    var _S1423 : Selection = Selection_x24init_0(_S1422, 0.0f, _S1410, u32(0));
    var initial_0 : Selection = _S1423;
    var _S1424 : u32 = stream(_S1419, u32(193));
    initial_0.random_state = _S1424;
    var i_9 : u32 = u32(0);
    loop
    {
        var _S1425 : u32 = (uniforms_uint.samples);
        if(i_9 < _S1425)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1422;
        var _S1426 : u32 = (uniforms_uint.frame);
        var _S1427 : u32 = (uniforms_uint.samples);
        var _S1428 : u32 = _S1426 * _S1427 + i_9;
        var _S1429 : u32 = noiseOrigin(_S1408, _S1428);
        r_9.seed = _S1429;
        var _S1430 : u32 = (insertBits((u32(0)), (u32(1)), (u32(24)), (u32(1))));
        var _S1431 : u32 = (insertBits((_S1430), (((_S1421 + _S1428 * u32(2654435769)) >> (u32(25)))), (u32(25)), (u32(7))));
        r_9.path = _S1431;
        var _S1432 : u32 = (uniforms_uint.samples);
        var _S1433 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1432), &(initial_0));
        var i_10 : u32 = i_9 + u32(1);
        i_9 = i_10;
    }
    var _S1434 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1409), (_S1434), (dom_7.hit));
    return;
}

fn normal_distribution( state_4 : u32) -> Random
{
    var _S1435 : Random = pcg(state_4);
    var _S1436 : Random = pcg(_S1435.state);
    var _S1437 : f32 = 6.28318548202514648f * _S1435.value;
    var _S1438 : f32 = sqrt(-2.0f * clamp(log(_S1436.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1436.state, _S1438 * cos(_S1437));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_5 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1439 : RandomSphere;
    _S1439.state = state_5;
    _S1439.value = value_1;
    return _S1439;
}

fn random_sphere( state_6 : u32) -> RandomSphere
{
    var _S1440 : Random = normal_distribution(state_6);
    var _S1441 : Random = normal_distribution(_S1440.state);
    var _S1442 : Random = normal_distribution(_S1441.state);
    var _S1443 : vec3<f32> = (normalize((vec3<f32>(_S1440.value, _S1441.value, _S1442.value))));
    return RandomSphere_x24init_0(_S1442.state, _S1443);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1444 : vec3<f32> = p1_0 - p0_0;
    var _S1445 : vec3<f32> = p2_0 - p0_0;
    var _S1446 : vec2<f32> = uv1_0 - uv0_0;
    var _S1447 : vec2<f32> = uv2_0 - uv0_0;
    var _S1448 : f32 = _S1446.x;
    var _S1449 : f32 = _S1447.y;
    var _S1450 : f32 = _S1446.y;
    var _S1451 : f32 = _S1447.x;
    var _S1452 : f32 = _S1448 * _S1449 - _S1450 * _S1451;
    var _S1453 : f32 = 1.0f / _S1452;
    var _S1454 : vec3<f32> = vec3<f32>(_S1453);
    var t_20 : vec3<f32> = (_S1444 * vec3<f32>(_S1449) - _S1445 * vec3<f32>(_S1450)) * _S1454;
    var _S1455 : vec3<f32> = (_S1445 * vec3<f32>(_S1448) - _S1444 * vec3<f32>(_S1451)) * _S1454;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1456 : bool = (dot(cross(n_9, t_21), _S1455)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1456)
    {
        var _S1457 : vec3<f32> = ((-(t_21)));
        t_22 = _S1457;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1458 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1458, n_9);
}

fn tangentToWorldNormalMap( v_13 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_13)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1459 : vec3<f32> = t1_0 - t0_0;
    var _S1460 : vec3<f32> = t2_2 - t0_0;
    var _S1461 : vec3<f32> = t2_2 - t1_0;
    var _S1462 : f32 = min(length(_S1459), min(length(_S1460), length(_S1461)));
    var _S1463 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1464 : vec3<f32> = (normalize((n0_0)));
    var _S1465 : f32 = dot(geometry_n_4, _S1464);
    var _S1466 : vec3<f32> = (normalize((n1_0)));
    var _S1467 : f32 = dot(geometry_n_4, _S1466);
    var _S1468 : vec3<f32> = (normalize((n2_0)));
    var _S1469 : vec3<f32> = acos(abs(vec3<f32>(_S1465, _S1467, dot(geometry_n_4, _S1468))));
    var _S1470 : vec3<f32> = clamp(tan(_S1469), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1463 * _S1470, uvw_0), 0.0f, _S1462 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_10 : vec3<f32>,  material_26 : Material) -> vec3<f32>
{
    var _S1471 : vec3<f32> = ((-(dir_12)));
    var _S1472 : f32 = (sign((dot(n_10, _S1471))));
    var _S1473 : vec3<f32> = n_10 * vec3<f32>(_S1472);
    var _S1474 : AnisotropicFrame = anisotropicFrame(material_26, _S1473);
    var _S1475 : bool = (_S1474.alphas.x) > 0.0f;
    if(_S1475)
    {
        var _S1476 : f32 = material_26.transmission * (1.0f - material_26.metallic);
        var _S1477 : vec3<f32> = ((-(_S1473)));
        var _S1478 : vec3<f32> = anisotropicLocal(dir_12, _S1474.tangent, _S1477);
        var _S1479 : f32 = anisotropicG1(_S1478, _S1474.alphas);
        return vec3<f32>((_S1476 * _S1479)) * material_26.albedo;
    }
    var _S1480 : f32 = material_26.transmission * (1.0f - material_26.metallic);
    var _S1481 : f32 = material_26.roughness;
    var _S1482 : f32 = smithG1(_S1481 * _S1481, abs(dot(n_10, dir_12)));
    return vec3<f32>((_S1480 * _S1482)) * material_26.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_27 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var through_1 : vec3<f32>;
    if((material_27.ior) == 1.0f)
    {
        var _S1483 : vec3<f32> = straightThrough(toward_1, n_11, material_27);
        through_1 = _S1483;
    }
    else
    {
        through_1 = vec3<f32>(0.0f);
    }
    var _S1484 : CoatFrame = coatFrame(material_27, n_11);
    var _S1485 : bool = (_S1484.ior) > 0.0f;
    if(_S1485)
    {
        var _S1486 : f32 = fresnel(abs(dot(_S1484.normal, toward_1)), 1.0f, _S1484.ior);
        var _S1487 : vec3<f32> = (mix((vec3<f32>(1.0f)), (vec3<f32>((1.0f - _S1486)) * material_27.coat_tint), (material_27.coat)));
        var through_2 : vec3<f32> = through_1 * _S1487;
        through_1 = through_2;
    }
    return through_1 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1488 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1488;
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

fn noiseWhite( x_3 : u32,  y_1 : u32,  t_23 : u32,  size_0 : u32) -> u32
{
    var ranks_0 : array<u32, i32(4)>;
    var i_11 : u32 = u32(0);
    loop
    {
        if(i_11 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S1489 : u32;
        if(i_11 < u32(2))
        {
            _S1489 = x_3;
        }
        else
        {
            _S1489 = ((x_3 + size_0 / u32(2)) & ((size_0 - u32(1))));
        }
        var l_4 : u32 = _S1489;
        var r_11 : u32 = y_1;
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
            var _S1490 : u32 = hash((((((r_11 ^ (((t_23 << (u32(16))))))) ^ (((k_2 << (u32(28))))))) ^ (((((i_11 & (u32(1)))) << (u32(31)))))));
            var _S1491 : u32 = (l_4 ^ (((_S1490 & ((size_0 - u32(1)))))));
            var k_3 : u32 = k_2 + u32(1);
            l_4 = r_11;
            r_11 = _S1491;
            k_2 = k_3;
        }
        var _S1492 : u32 = l_4 + r_11 * size_0;
        var _S1493 : u32 = size_0 * size_0;
        var _S1494 : u32;
        if(_S1493 >= u32(65536))
        {
            var _S1495 : u32 = _S1492 / (_S1493 / u32(65536));
            _S1494 = _S1495;
        }
        else
        {
            var _S1496 : u32 = u32(65536) / _S1493;
            _S1494 = _S1492 * _S1496;
        }
        ranks_0[i_11] = _S1494;
        var i_12 : u32 = i_11 + u32(1);
        i_11 = i_12;
    }
    var _S1497 : bool = (ranks_0[i32(0)]) == u32(65535);
    var _S1498 : bool;
    if(_S1497)
    {
        _S1498 = (ranks_0[i32(1)]) == u32(65535);
    }
    else
    {
        _S1498 = false;
    }
    var _S1499 : bool = (ranks_0[i32(2)]) == u32(65535);
    var _S1500 : bool;
    if(_S1499)
    {
        _S1500 = (ranks_0[i32(3)]) == u32(65535);
    }
    else
    {
        _S1500 = false;
    }
    if(_S1498)
    {
        _S1498 = (ranks_0[i32(3)]) != u32(65535);
    }
    else
    {
        _S1498 = false;
    }
    if(_S1498)
    {
        _S1498 = true;
    }
    else
    {
        if(_S1500)
        {
            _S1498 = (ranks_0[i32(1)]) != u32(65535);
        }
        else
        {
            _S1498 = false;
        }
    }
    var _S1501 : u32 = ranks_0[i32(0)];
    if(_S1498)
    {
        i_11 = ranks_0[i32(3)];
    }
    else
    {
        i_11 = ranks_0[i32(1)];
    }
    return (_S1501 | (((i_11 << (u32(16))))));
}

fn noiseBlock( sweep_0 : u32,  colour_0 : u32,  block_0 : u32,  size_1 : u32) -> vec3<u32>
{
    var _S1502 : u32 = hash(sweep_0 * u32(7919) + u32(1));
    var _S1503 : u32 = size_1 / u32(16);
    var _S1504 : u32 = block_0 % _S1503;
    var _S1505 : u32 = block_0 / _S1503;
    var _S1506 : u32 = _S1505 % _S1503;
    var _S1507 : u32 = block_0 / (_S1503 * _S1503);
    var _S1508 : vec3<u32> = vec3<u32>(_S1504, _S1506, _S1507);
    var _S1509 : vec3<u32> = vec3<u32>((colour_0 & (u32(1))), (((colour_0 >> (u32(1)))) & (u32(1))), (colour_0 >> (u32(2))));
    return _S1508 * vec3<u32>(u32(16)) + _S1509 * vec3<u32>(u32(8)) + vec3<u32>((_S1502 & (u32(7))), (((_S1502 >> (u32(3)))) & (u32(7))), (((_S1502 >> (u32(6)))) & (u32(7))));
}

