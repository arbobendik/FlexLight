struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

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

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
     glow : vec3<f32>,
     sums : bool,
};

fn Reservoir_x24init_0( seed_0 : u32,  path_0 : u32,  w_0 : f32,  c_0 : f32,  f_0 : vec3<f32>,  jac_0 : f32,  rc_0 : vec4<u32>,  dir_0 : vec3<f32>,  radiance_0 : vec3<f32>) -> Reservoir
{
    var _S1 : Reservoir;
    _S1.seed = seed_0;
    _S1.path = path_0;
    _S1.w = w_0;
    _S1.c = c_0;
    _S1.f = f_0;
    _S1.jac = jac_0;
    _S1.rc = rc_0;
    _S1.dir = dir_0;
    _S1.radiance = radiance_0;
    return _S1;
}

fn Selection_x24init_0( r_0 : Reservoir,  w_sum_0 : f32,  color_0 : vec3<f32>,  random_state_0 : u32,  glow_0 : vec3<f32>,  sums_0 : bool) -> Selection
{
    var _S2 : Selection;
    _S2.r = r_0;
    _S2.w_sum = w_sum_0;
    _S2.color = color_0;
    _S2.random_state = random_state_0;
    _S2.glow = glow_0;
    _S2.sums = sums_0;
    return _S2;
}

fn Shift_x24init_0( f_1 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S3 : Shift;
    _S3.f = f_1;
    _S3.jac = jac_1;
    return _S3;
}

fn Hit_x24init_0( uv_0 : vec2<f32>,  instance_index_0 : u32,  triangle_index_0 : u32,  is_point_light_0 : u32,  distance_0 : f32) -> Hit
{
    var _S4 : Hit;
    _S4.uv = uv_0;
    _S4.instance_index = instance_index_0;
    _S4.triangle_index = triangle_index_0;
    _S4.is_point_light = is_point_light_0;
    _S4.distance = distance_0;
    return _S4;
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S5 : Ray;
    _S5.origin = origin_0;
    _S5.unit_direction = unit_direction_0;
    return _S5;
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
    var _S6 : NEEVertex;
    _S6.none = none_0;
    _S6.pdf = pdf_0;
    _S6.origin = origin_1;
    _S6.smooth_n = smooth_n_0;
    _S6.start = start_0;
    return _S6;
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
    var _S7 : Vertex;
    _S7.rough = rough_0;
    _S7.lobe = lobe_0;
    _S7.pdf = pdf_1;
    _S7.cos = cos_0;
    _S7.inside = inside_0;
    return _S7;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_0 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_0 : vec3<f32>,  velvet_0 : f32,  dispersion_0 : f32) -> Material
{
    var _S8 : Material;
    _S8.albedo = albedo_0;
    _S8.emissive = emissive_0;
    _S8.roughness = roughness_0;
    _S8.metallic = metallic_0;
    _S8.transmission = transmission_0;
    _S8.ior = ior_0;
    _S8.absorption = absorption_0;
    _S8.specular_tint = specular_tint_0;
    _S8.specular_level = specular_level_0;
    _S8.translucent = translucent_0;
    _S8.sheen = sheen_0;
    _S8.sheen_roughness = sheen_roughness_0;
    _S8.anisotropy = anisotropy_0;
    _S8.anisotropic_rotation = anisotropic_rotation_0;
    _S8.tangent = tangent_0;
    _S8.velvet = velvet_0;
    _S8.dispersion = dispersion_0;
    return _S8;
}

fn Surface_x24init_0( smooth_n_1 : vec3<f32>,  geometry_n_0 : vec3<f32>,  geometry_offset_0 : f32,  material_0 : Material,  skip_0 : bool,  random_state_1 : u32) -> Surface
{
    var _S9 : Surface;
    _S9.smooth_n = smooth_n_1;
    _S9.geometry_n = geometry_n_0;
    _S9.geometry_offset = geometry_offset_0;
    _S9.material = material_0;
    _S9.skip = skip_0;
    _S9.random_state = random_state_1;
    return _S9;
}

fn noiseOffset( k_0 : u32) -> vec2<u32>
{
    var _S10 : vec2<u32> = vec2<u32>(u32(16));
    var _S11 : vec2<u32> = (vec2<u32>(k_0 * u32(3242174889), k_0 * u32(2447445414)) >> (_S10));
    var _S12 : u32 = (fkBlueNoiseSize());
    return ((_S11 * vec2<u32>(_S12)) >> (_S10));
}

fn noiseAddress( origin_2 : u32,  bounce_0 : u32) -> u32
{
    var _S13 : vec2<u32> = vec2<u32>((origin_2 & (u32(2047))), (((origin_2 >> (u32(11)))) & (u32(2047))));
    var _S14 : vec2<u32> = noiseOffset(u32(64) + bounce_0 * u32(17));
    var _S15 : vec2<u32> = ((_S13 + _S14) & (vec2<u32>(u32(2047))));
    return ((((_S15.x) | ((((_S15.y) << (u32(11))))))) | (((((origin_2 >> (u32(22)))) << (u32(22))))));
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S16 : bool = transmission_1 > 0.0f;
    var _S17 : bool;
    if(_S16)
    {
        _S17 = true;
    }
    else
    {
        _S17 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S18 : f32 = select(-1.0f, 1.0f, _S17);
    return _S18;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S19 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S20 : vec3<f32> = vec3<f32>(_S19);
    return Surface_x24init_0(surface_0.smooth_n * _S20, surface_0.geometry_n * _S20, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

var<private> SPECTRAL_PRIMARIES_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f );
fn upsample( rgb_0 : vec3<f32>,  wavelength_0 : f32) -> f32
{
    var _S21 : f32 = clamp((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S22 : u32 = min(u32(_S21), u32(79));
    var _S23 : u32 = u32(3) * _S22;
    var _S24 : vec3<f32> = vec3<f32>(SPECTRAL_PRIMARIES_0[_S23], SPECTRAL_PRIMARIES_0[_S23 + u32(1)], SPECTRAL_PRIMARIES_0[_S23 + u32(2)]);
    var _S25 : vec3<f32> = vec3<f32>(SPECTRAL_PRIMARIES_0[_S23 + u32(3)], SPECTRAL_PRIMARIES_0[_S23 + u32(4)], SPECTRAL_PRIMARIES_0[_S23 + u32(5)]);
    return dot(rgb_0, _S24 + (_S25 - _S24) * vec3<f32>((_S21 - f32(_S22))));
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S26 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S26));
}

fn dispersive( material_1 : Material) -> bool
{
    var _S27 : bool = (material_1.dispersion) > 0.0f;
    var _S28 : bool;
    if(_S27)
    {
        _S28 = (material_1.ior) != 1.0f;
    }
    else
    {
        _S28 = false;
    }
    return _S28;
}

fn hash( x_0 : u32) -> u32
{
    var _S29 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S30 : u32 = ((((_S29 >> ((((_S29 >> (u32(28)))) + u32(4))))) ^ (_S29))) * u32(277803737);
    return (((_S30 >> (u32(22)))) ^ (_S30));
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S31 : u32 = hash(index_0);
    var _S32 : u32 = hash((seed_1 ^ (_S31)));
    return _S32;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S33 : Random;
    _S33.state = state_0;
    _S33.value = value_0;
    return _S33;
}

fn pcg( state_1 : u32) -> Random
{
    var _S34 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S35 : u32 = hash(state_1);
    return Random_x24init_0(_S34, f32(_S35) / 4.294967296e+09f);
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
        var _S36 : u32 = (low_0 + high_0 + u32(1)) / u32(2);
        var _S37 : bool = (WAVELENGTH_CDF_0[_S36]) <= u_0;
        if(_S37)
        {
            low_0 = _S36;
        }
        else
        {
            var _S38 : u32 = _S36 - u32(1);
            high_0 = _S38;
        }
    }
    var _S39 : u32 = low_0;
    var _S40 : f32 = WAVELENGTH_CDF_0[low_0 + u32(1)] - WAVELENGTH_CDF_0[low_0];
    return vec2<f32>(0.37999999523162842f + 0.00499999988824129f * (f32(low_0) + (u_0 - WAVELENGTH_CDF_0[_S39]) / _S40), _S40 / 0.00499999988824129f);
}

var<private> WAVELENGTH_WEIGHTS_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f );
fn wavelengthWeights( wavelength_1 : f32) -> vec3<f32>
{
    var _S41 : f32 = clamp((wavelength_1 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S42 : u32 = min(u32(_S41), u32(79));
    var _S43 : u32 = u32(3) * _S42;
    var _S44 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S43], WAVELENGTH_WEIGHTS_0[_S43 + u32(1)], WAVELENGTH_WEIGHTS_0[_S43 + u32(2)]);
    var _S45 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S43 + u32(3)], WAVELENGTH_WEIGHTS_0[_S43 + u32(4)], WAVELENGTH_WEIGHTS_0[_S43 + u32(5)]);
    return _S44 + (_S45 - _S44) * vec3<f32>((_S41 - f32(_S42)));
}

fn atWavelength( material_2 : Material,  wavelength_2 : f32) -> Material
{
    var at_0 : Material = material_2;
    var _S46 : f32 = upsample(material_2.albedo, wavelength_2);
    var _S47 : vec3<f32> = vec3<f32>(_S46);
    at_0.albedo = _S47;
    var _S48 : f32 = upsample(material_2.emissive, wavelength_2);
    var _S49 : vec3<f32> = vec3<f32>(_S48);
    at_0.emissive = _S49;
    var _S50 : f32 = upsample(material_2.absorption, wavelength_2);
    var _S51 : vec3<f32> = vec3<f32>(_S50);
    at_0.absorption = _S51;
    var _S52 : f32 = upsample(material_2.specular_tint, wavelength_2);
    var _S53 : vec3<f32> = vec3<f32>(_S52);
    at_0.specular_tint = _S53;
    var _S54 : f32 = upsample(material_2.translucent, wavelength_2);
    var _S55 : vec3<f32> = vec3<f32>(_S54);
    at_0.translucent = _S55;
    var _S56 : f32 = upsample(material_2.sheen, wavelength_2);
    var _S57 : vec3<f32> = vec3<f32>(_S56);
    at_0.sheen = _S57;
    return at_0;
}

fn pathMaterial( material_3 : Material,  wavelength_3 : f32) -> Material
{
    var _S58 : Material;
    if(wavelength_3 > 0.0f)
    {
        var _S59 : Material = atWavelength(material_3, wavelength_3);
        _S58 = _S59;
    }
    else
    {
        _S58 = material_3;
    }
    return _S58;
}

fn dispersedIor( ior_1 : f32,  dispersion_1 : f32,  wavelength_4 : f32) -> f32
{
    var _S60 : f32 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    var _S61 : f32 = _S60 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    var _S62 : bool = dispersion_1 > 0.0f;
    var _S63 : f32 = select(0.0f, _S61, _S62);
    return ior_1 + _S63;
}

fn vertexEta( material_4 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S64 : bool = n_dot_v_0 < 0.0f;
    var _S65 : f32 = select(1.0f, material_4.ior, _S64);
    var _S66 : f32 = select(material_4.ior, 1.0f, _S64);
    return vec2<f32>(_S65, _S66);
}

fn wavelengthEta( material_5 : Material,  n_dot_v_1 : f32,  wavelength_5 : f32) -> vec2<f32>
{
    var refractive_0 : Material = material_5;
    var _S67 : f32 = dispersedIor(material_5.ior, material_5.dispersion, wavelength_5);
    var _S68 : bool = wavelength_5 > 0.0f;
    var _S69 : f32 = select(material_5.ior, _S67, _S68);
    refractive_0.ior = _S69;
    var _S70 : vec2<f32> = vertexEta(refractive_0, n_dot_v_1);
    return _S70;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S71 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S72 : f32 = eta_i_0 / eta_o_0 * _S71;
    var _S73 : bool = _S72 < 1.0f;
    var kr_0 : f32;
    if(_S73)
    {
        var _S74 : f32 = sqrt(max(0.0f, 1.0f - _S72 * _S72));
        var _S75 : bool = eta_i_0 == eta_o_0;
        var _S76 : f32 = select(_S74, cos_theta_0, _S75);
        var _S77 : f32 = eta_o_0 * cos_theta_0;
        var _S78 : f32 = eta_i_0 * _S76;
        var _S79 : f32 = (_S77 - _S78) / (_S77 + _S78);
        var _S80 : f32 = eta_i_0 * cos_theta_0;
        var _S81 : f32 = eta_o_0 * _S76;
        var _S82 : f32 = (_S80 - _S81) / (_S80 + _S81);
        var _S83 : f32 = (_S79 * _S79 + _S82 * _S82) / 2.0f;
        kr_0 = _S83;
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
    var _S84 : f32 = fresnel(abs(n_dot_v_2), eta_i_1, eta_o_1);
    var _S85 : vec3<f32> = (mix((vec3<f32>(_S84)), (material_6.albedo), (material_6.metallic)));
    var _S86 : f32 = rgb_to_greyscale(_S85);
    var _S87 : f32 = max((1.0f - _S86) * (1.0f - material_6.metallic) * (1.0f - material_6.transmission), 0.0f);
    var _S88 : bool = _S87 > 0.03999999910593033f;
    var _S89 : bool;
    if(_S88)
    {
        _S89 = true;
    }
    else
    {
        _S89 = (material_6.roughness) > 0.20000000298023224f;
    }
    return _S89;
}

fn isTranslucent_0( material_7 : Material) -> bool
{
    var _S90 : f32 = rgb_to_greyscale(material_7.translucent);
    return _S90 > 0.0f;
}

fn emitted_0( emissive_1 : vec3<f32>,  dir_2 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    var _S91 : f32 = (sign((dot((vec3<f32>(0) - dir_2), n_0))));
    var _S92 : vec3<f32> = emissive_1 * vec3<f32>(max(_S91, 0.0f));
    var _S93 : bool = ((false));
    var _S94 : vec3<f32> = select(_S92, emissive_1, _S93);
    return _S94;
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
    var _S95 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S96 : bool = cos_a_0 > cos_b_0;
    var _S97 : f32 = select(_S95, 1.0f, _S96);
    return _S97;
}

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S98 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S99 : vec3<f32> = node_0.high - node_0.low;
    var _S100 : vec3<f32> = p_0 - _S98;
    var _S101 : vec3<f32> = (normalize((_S100)));
    var _S102 : f32 = dot(_S100, _S100);
    var _S103 : f32 = dot(_S99, _S99) / 4.0f;
    var _S104 : f32 = abs(dot(node_0.w, _S101));
    var _S105 : f32 = sine(node_0.cos_theta_o);
    var _S106 : f32 = sqrt(max(1.0f - _S103 / _S102, 0.0f));
    var _S107 : bool = _S102 < _S103;
    var _S108 : f32 = select(_S106, -1.0f, _S107);
    var _S109 : f32 = sine(_S108);
    var _S110 : f32 = sine(_S104);
    var _S111 : f32 = cosSubClamped(_S110, _S104, _S105, node_0.cos_theta_o);
    var _S112 : f32 = sine(_S104);
    var _S113 : f32 = _S112 * node_0.cos_theta_o - _S104 * _S105;
    var _S114 : bool = _S104 > (node_0.cos_theta_o);
    var _S115 : f32 = select(_S113, 0.0f, _S114);
    var _S116 : f32 = cosSubClamped(_S115, _S111, _S109, _S108);
    var _S117 : bool = _S116 <= 0.0f;
    if(_S117)
    {
        return 0.0f;
    }
    var _S118 : f32 = - dot(_S101, normal_0);
    var _S119 : f32 = node_0.phi * _S116 / max(_S102, length(_S99) / 2.0f);
    var _S120 : f32 = sine(_S118);
    var _S121 : f32 = cosSubClamped(_S120, _S118, _S109, _S108);
    var _S122 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S123 : f32 = select(_S121, 1.0f, _S122);
    return max(_S119 * _S123, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S124 : f32 = importance(first_0, p_1, normal_1);
    var _S125 : f32 = importance(second_0, p_1, normal_1);
    var _S126 : vec2<f32> = vec2<f32>(_S124, _S125);
    var _S127 : f32 = _S126[child_0] / (_S124 + _S125);
    var _S128 : bool = (_S126[child_0]) > 0.0f;
    var _S129 : f32 = select(0.0f, _S127, _S128);
    return _S129;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_2 : vec3<f32>) -> f32
{
    var _S130 : vec3<f32> = center_0 - p_2;
    var _S131 : f32 = radius_0 * radius_0 / dot(_S130, _S130);
    var _S132 : bool = _S131 >= 1.0f;
    if(_S132)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S131)) / (6.28318548202514648f * _S131);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_3 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S133 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S134 : vec2<u32> = _S133.xy;
    var n_1 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S134;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S135 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
        if((_S135.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S136 : u32 = (access_light_tree(3u + 4u * (n_1)).w);
        var _S137 : u32 = n_1 + u32(1);
        var _S138 : LightBounds = (lightBounds((_S137)));
        var _S139 : LightBounds = (lightBounds((_S136)));
        var _S140 : u32 = trail_0.x;
        var _S141 : u32 = (_S140 & (u32(1)));
        var _S142 : f32 = childShare(_S138, _S139, origin_3, smooth_n_2, _S141);
        var probability_2 : f32 = probability_1 * _S142;
        var _S143 : bool = _S141 == u32(1);
        var _S144 : u32 = select(_S137, _S136, _S143);
        var _S145 : u32 = trail_0.y;
        var _S146 : vec2<u32> = vec2<u32>((((_S140 >> (u32(1)))) | (((_S145 << (u32(31)))))), (_S145 >> (u32(1))));
        n_1 = _S144;
        trail_0 = _S146;
        probability_1 = probability_2;
    }
    var _S147 : bool = (((_S133).z == (n_1)));
    var _S148 : bool = !_S147;
    var _S149 : bool;
    if(_S148)
    {
        _S149 = true;
    }
    else
    {
        var _S150 : LightBounds = (lightBounds((n_1)));
        var _S151 : f32 = importance(_S150, origin_3, smooth_n_2);
        _S149 = !(_S151 > 0.0f);
    }
    if(_S149)
    {
        _S149 = true;
    }
    else
    {
        var _S152 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S152)
        {
            _S149 = !((dot(smooth_n_2, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S149 = false;
        }
    }
    if(_S149)
    {
        return 0.0f;
    }
    var _S153 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
    var _S154 : bool = (_S153.x) == u32(2);
    if(_S154)
    {
        var _S155 : Light = (lights[(_S153.y)]);
        var _S156 : f32 = sphereDensity(_S155.position, _S155.variance, start_1);
        return probability_1 * _S156;
    }
    var _S157 : u32 = _S153.y;
    var _S158 : u32 = ((instance_uint[(_S157) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S159 : mat3x3<f32> = (worldTriangle((_S157), (_S158 + _S153.z)));
    var _S160 : f32 = solidAngle(probability_1, cross(_S159[i32(1)] - _S159[i32(0)], _S159[i32(2)] - _S159[i32(0)]), light_point_0 - start_1);
    return _S160;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S161 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S162 : bool = b_0 > 0.0f;
    var _S163 : f32 = select(1.0f, _S161, _S162);
    return _S163;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_0 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S164 : u32 = (lightSlot((hit_0)));
    var _S165 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S164, light_point_1);
    var _S166 : f32 = powerHeuristic(vertex_0.pdf, _S165);
    return _S166;
}

fn pathColor( f_2 : vec3<f32>,  weight_0 : vec3<f32>,  wavelength_6 : f32) -> vec3<f32>
{
    var _S167 : f32 = upsample(f_2, wavelength_6);
    var _S168 : vec3<f32> = weight_0 * vec3<f32>(_S167);
    var _S169 : bool = wavelength_6 > 0.0f;
    var _S170 : vec3<f32> = select(f_2, _S168, _S169);
    return _S170;
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_3 : vec3<f32>,  radiance_1 : vec3<f32>,  density_0 : f32,  random_state_2 : u32) -> TreeSample
{
    var _S171 : TreeSample;
    _S171.dir = dir_3;
    _S171.radiance = radiance_1;
    _S171.density = density_0;
    _S171.random_state = random_state_2;
    return _S171;
}

fn draw( address_0 : u32,  variable_0 : u32) -> Random
{
    var _S172 : u32 = (address_0 >> (u32(22)));
    var _S173 : u32 = _S172 / u32(32);
    var _S174 : vec2<u32> = vec2<u32>((address_0 & (u32(2047))), (((address_0 >> (u32(11)))) & (u32(2047))));
    var _S175 : u32 = (variable_0 & (u32(2147483647)));
    var _S176 : vec2<u32> = noiseOffset(_S175);
    var _S177 : vec2<u32> = _S174 + _S176;
    var _S178 : vec2<u32> = noiseOffset(u32(4096) + _S173);
    var _S179 : vec2<u32> = _S177 + _S178;
    var _S180 : u32 = (fkBlueNoiseSize());
    var _S181 : vec2<u32> = (_S179 & (vec2<u32>((_S180 - u32(1)))));
    var _S182 : u32 = (fkBlueNoise((_S181.x), (_S181.y), ((_S172 + (((_S173 * u32(2654435769)) >> (u32(27))))) % u32(32))));
    var _S183 : bool = ((variable_0 & (u32(2147483648)))) != u32(0);
    var _S184 : u32 = stream(address_0, _S175);
    var _S185 : Random = pcg(_S184);
    var _S186 : u32 = (_S182 & (u32(65535)));
    var _S187 : u32 = (_S182 >> (u32(16)));
    var _S188 : u32 = select(_S186, _S187, _S183);
    var _S189 : f32 = (f32(_S188) + 0.5f) / 6.5536e+04f;
    var _S190 : Random = pcg(_S185.state);
    var _S191 : f32 = select(_S185.value, _S190.value, _S183);
    var _S192 : bool = _S182 == u32(4294967295);
    var _S193 : f32 = select(_S189, _S191, _S192);
    return Random_x24init_0(address_0, _S193);
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_3 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S194 : f32 = importance(first_1, p_3, normal_3);
    var _S195 : f32 = importance(second_1, p_3, normal_3);
    var _S196 : vec2<f32> = vec2<f32>(_S194, _S195);
    var _S197 : bool = _S194 == 0.0f;
    var _S198 : bool;
    if(_S197)
    {
        _S198 = _S195 == 0.0f;
    }
    else
    {
        _S198 = false;
    }
    if(_S198)
    {
        return u32(2);
    }
    var _S199 : f32 = _S194 + _S195;
    var _S200 : bool = _S195 > 0.0f;
    if(_S200)
    {
        _S198 = ((*pick_0) * _S199) >= _S194;
    }
    else
    {
        _S198 = false;
    }
    var _S201 : u32 = select(u32(0), u32(1), _S198);
    var _S202 : f32 = min(((*pick_0) * _S199 - f32(_S201) * _S194) / _S196[_S201], 0.99999994039535522f);
    (*pick_0) = _S202;
    var _S203 : f32 = (*probability_3) * (_S196[_S201] / _S199);
    (*probability_3) = _S203;
    return _S201;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S204 : bool = (abs(dot(n_2, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S204)
    {
        const _S205 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S205;
    }
    else
    {
        a_2 = a_1;
    }
    var _S206 : vec3<f32> = (normalize((cross(n_2, a_2))));
    var _S207 : vec3<f32> = cross(n_2, _S206);
    return vec3<f32>(v_0.x) * _S206 + vec3<f32>(v_0.y) * n_2 + vec3<f32>(v_0.z) * _S207;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S208 : vec3<f32> = center_1 - p_4;
    var _S209 : f32 = radius_1 * radius_1 / dot(_S208, _S208);
    var _S210 : f32 = u1_0 * _S209 / (1.0f + sqrt(max(1.0f - _S209, 0.0f)));
    var _S211 : f32 = 2.0f * u1_0;
    var _S212 : bool = _S209 >= 1.0f;
    var _S213 : f32 = select(_S210, _S211, _S212);
    var _S214 : f32 = sqrt(max(_S213 * (2.0f - _S213), 0.0f));
    var _S215 : f32 = 6.28318548202514648f * u2_0;
    var _S216 : vec3<f32> = vec3<f32>(_S214 * cos(_S215), 1.0f - _S213, _S214 * sin(_S215));
    var _S217 : vec3<f32> = (normalize((_S208)));
    var _S218 : vec3<f32> = tangentToWorld(_S216, _S217);
    return _S218;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S219 : vec3<f32> = center_2 - ray_0.origin;
    var _S220 : f32 = dot(_S219, ray_0.unit_direction);
    var _S221 : f32 = dot(_S219, _S219) - _S220 * _S220;
    var _S222 : f32 = radius_3 * radius_3;
    var _S223 : bool = _S221 > _S222;
    if(_S223)
    {
        return 4.294967296e+09f;
    }
    var _S224 : f32 = sqrt(_S222 - _S221);
    var _S225 : f32 = _S220 - _S224;
    var _S226 : f32 = _S220 + _S224;
    var _S227 : bool = _S225 > 0.0000152587890625f;
    var _S228 : bool;
    if(_S227)
    {
        _S228 = _S225 < max_len_0;
    }
    else
    {
        _S228 = false;
    }
    if(_S228)
    {
        return _S225;
    }
    var _S229 : bool = _S226 > 0.0000152587890625f;
    if(_S229)
    {
        _S228 = _S226 < max_len_0;
    }
    else
    {
        _S228 = false;
    }
    if(_S228)
    {
        return _S226;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_4 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S230 : vec3<f32> = (normalize((light_dir_0)));
    var _S231 : bool = (dot(smooth_n_3, _S230)) < 0.0f;
    if(_S231)
    {
        return vec3<f32>(0.0f);
    }
    var _S232 : vec3<f32> = origin_4 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S233 : Ray = Ray_x24init_0(_S232, _S230);
    var _S234 : f32 = shadowLength(light_dir_0);
    var _S235 : vec3<f32> = (shadowTransmittance((_S233), (_S234)));
    return _S235;
}

fn sampleLightTree_0( origin_5 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S236 : Random = draw(init_random_state_0, u32(4));
    var _S237 : Random = draw(init_random_state_0, u32(5));
    var _S238 : Random = draw(init_random_state_0, u32(2147483653));
    var _S239 : vec3<f32> = vec3<f32>(0.0f);
    var _S240 : TreeSample = TreeSample_x24init_0(_S239, _S239, 0.0f, _S238.state);
    var sample_0 : TreeSample = _S240;
    var _S241 : vec3<f32> = select(smooth_n_4, _S239, sided_0);
    var _S242 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S243 : vec3<f32> = origin_5 + _S242 * smooth_n_4;
    var pick_1 : f32 = _S236.value;
    var probability_4 : f32 = 1.0f;
    var n_3 : u32 = u32(0);
    loop
    {
        var _S244 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
        if((_S244.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S245 : u32 = (access_light_tree(3u + 4u * (n_3)).w);
        var _S246 : u32 = n_3 + u32(1);
        var _S247 : LightBounds = (lightBounds((_S246)));
        var _S248 : LightBounds = (lightBounds((_S245)));
        var _S249 : u32 = pickChild(_S247, _S248, origin_5, _S241, &(pick_1), &(probability_4));
        var _S250 : bool = _S249 > u32(1);
        if(_S250)
        {
            return sample_0;
        }
        var _S251 : bool = _S249 == u32(1);
        var _S252 : u32 = select(_S246, _S245, _S251);
        n_3 = _S252;
    }
    var _S253 : bool = n_3 == u32(0);
    var _S254 : bool;
    if(_S253)
    {
        var _S255 : LightBounds = (lightBounds((u32(0))));
        var _S256 : f32 = importance(_S255, origin_5, _S241);
        _S254 = !(_S256 > 0.0f);
    }
    else
    {
        _S254 = false;
    }
    if(_S254)
    {
        return sample_0;
    }
    var _S257 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
    var _S258 : bool = (_S257.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S258)
    {
        var _S259 : Light = (lights[(_S257.y)]);
        if(sided_0)
        {
            var _S260 : f32 = (sign((dot(geometry_n_1, _S259.position - origin_5))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S260);
            var _S261 : vec3<f32> = origin_5 + _S242 * lift_n_1;
            start_2 = _S261;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S243;
            lift_n_0 = smooth_n_4;
        }
        var _S262 : bool = (_S259.variance) == 0.0f;
        if(_S262)
        {
            var _S263 : vec3<f32> = _S259.position - start_2;
            var _S264 : vec3<f32> = (normalize((_S263)));
            sample_0.dir = _S264;
            var _S265 : vec3<f32> = _S259.color * vec3<f32>(_S259.intensity) / vec3<f32>((dot(_S263, _S263) * probability_4));
            sample_0.radiance = _S265;
            shadow_1 = _S263;
        }
        else
        {
            var _S266 : vec3<f32> = sampleSphere(_S259.position, _S259.variance, start_2, _S237.value, _S238.value);
            sample_0.dir = _S266;
            var _S267 : f32 = sphereDensity(_S259.position, _S259.variance, start_2);
            var _S268 : f32 = probability_4 * _S267;
            sample_0.density = _S268;
            var _S269 : vec3<f32> = pointLightRadiance(_S259.color, _S259.intensity, _S259.variance);
            var _S270 : vec3<f32> = _S269 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S270;
            var _S271 : f32 = raySphere_0(_S259.position, _S259.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S272 : vec3<f32> = sample_0.dir * vec3<f32>(_S271);
            shadow_1 = _S272;
        }
    }
    else
    {
        var _S273 : u32 = _S257.y;
        var _S274 : u32 = ((instance_uint[(_S273) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S275 : u32 = _S274 + _S257.z;
        var _S276 : mat3x3<f32> = (worldTriangle((_S273), (_S275)));
        var _S277 : f32 = sqrt(_S237.value);
        var _S278 : vec2<f32> = vec2<f32>(_S277 * (1.0f - _S238.value), _S277 * _S238.value);
        var _S279 : vec3<f32> = (((_S276) * (vec3<f32>(1.0f - _S277, _S278))));
        if(sided_0)
        {
            var _S280 : f32 = (sign((dot(geometry_n_1, _S279 - origin_5))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S280);
            var _S281 : vec3<f32> = origin_5 + _S242 * lift_n_2;
            start_2 = _S281;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S282 : bool = !((dot(smooth_n_4, _S279 - origin_5)) > 0.0f);
            if(_S282)
            {
                return sample_0;
            }
            start_2 = _S243;
            lift_n_0 = smooth_n_4;
        }
        var _S283 : Surface = (surfaceAt((Hit_x24init_0(_S278, _S273, _S275, u32(0), 0.0f)), (_S279), (_S238.state)));
        sample_0.random_state = _S283.random_state;
        var _S284 : vec3<f32> = _S279 - start_2;
        var _S285 : vec3<f32> = (normalize((_S284)));
        sample_0.dir = _S285;
        var _S286 : f32 = solidAngle(probability_4, cross(_S276[i32(1)] - _S276[i32(0)], _S276[i32(2)] - _S276[i32(0)]), _S284);
        sample_0.density = _S286;
        var _S287 : vec3<f32> = emitted_0(_S283.material.emissive, sample_0.dir, _S283.smooth_n);
        var _S288 : vec3<f32> = select(_S287, _S239, _S283.skip);
        var _S289 : vec3<f32> = _S288 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S289;
        shadow_1 = _S284;
    }
    var _S290 : vec3<f32> = lightTransmittance_0(origin_5, lift_n_0, geometry_offset_2, shadow_1);
    var _S291 : vec3<f32> = sample_0.radiance * _S290;
    var _S292 : bool = (all((_S290 == _S239)));
    var _S293 : vec3<f32> = select(_S291, _S239, _S292);
    sample_0.radiance = _S293;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S294 : AnisotropicFrame;
    _S294.tangent = tangent_1;
    _S294.alphas = alphas_0;
    return _S294;
}

fn anisotropicFrame( material_8 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S295 : f32 = material_8.roughness;
    var _S296 : f32 = _S295 * _S295;
    var _S297 : bool = (material_8.anisotropy) == 0.0f;
    var _S298 : bool;
    if(_S297)
    {
        _S298 = true;
    }
    else
    {
        _S298 = !(_S296 > 0.0f);
    }
    if(_S298)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S299 : vec3<f32> = material_8.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_8.tangent));
    var _S300 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S301 : bool = (dot(_S299, _S299)) > 0.0f;
    var _S302 : vec3<f32> = select(_S300, _S299, _S301);
    var _S303 : vec3<f32> = (normalize((_S302)));
    var _S304 : f32 = 6.28318548202514648f * material_8.anisotropic_rotation;
    var _S305 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_8.anisotropy));
    var _S306 : f32 = 1.0f / _S305;
    var _S307 : bool = (material_8.anisotropy) < 0.0f;
    var _S308 : f32 = select(_S305, _S306, _S307);
    return AnisotropicFrame_x24init_0(_S303 * vec3<f32>(cos(_S304)) + cross(n_i_0, _S303) * vec3<f32>(sin(_S304)), vec2<f32>(_S296 / _S308, _S296 * _S308));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S309 : SheenProfile;
    _S309.on = on_0;
    _S309.albedo = albedo_1;
    return _S309;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_9 : Material) -> SheenProfile
{
    var _S310 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S311 : f32 = rgb_to_greyscale(material_9.sheen);
    var _S312 : bool = _S311 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S312)
    {
        var _S313 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S314 : u32 = min(u32(_S313), u32(22));
        var _S315 : f32 = sqrt(0.05000000074505806f);
        var _S316 : f32 = sqrt(0.00999999977648258f);
        var _S317 : bool = (material_9.velvet) > 0.0f;
        var _S318 : f32 = select(_S315, _S316, _S317);
        var _S319 : f32 = (clamp(sqrt(max(material_9.sheen_roughness, 0.0f)), _S318, 1.0f) - _S318) / (1.0f - _S318) * 23.0f;
        var _S320 : u32 = min(u32(_S319), u32(22));
        var _S321 : u32 = _S314 * u32(24) + _S320;
        var _S322 : f32 = _S313 - f32(_S314);
        var _S323 : f32 = _S319 - f32(_S320);
        if(_S317)
        {
            var _S324 : u32 = _S321 + u32(24);
            var _S325 : f32 = VELVET_ALBEDO_0[_S321] + (VELVET_ALBEDO_0[_S324] - VELVET_ALBEDO_0[_S321]) * _S322;
            var _S326 : u32 = _S321 + u32(1);
            var _S327 : f32 = VELVET_ALBEDO_0[_S326] + (VELVET_ALBEDO_0[_S324 + u32(1)] - VELVET_ALBEDO_0[_S326]) * _S322;
            var _S328 : SheenProfile = SheenProfile_x24init_0(true, _S325 + (_S327 - _S325) * _S323);
            profile_0 = _S328;
        }
        else
        {
            var _S329 : u32 = _S321 + u32(24);
            var _S330 : f32 = SHEEN_ALBEDO_0[_S321] + (SHEEN_ALBEDO_0[_S329] - SHEEN_ALBEDO_0[_S321]) * _S322;
            var _S331 : u32 = _S321 + u32(1);
            var _S332 : f32 = SHEEN_ALBEDO_0[_S331] + (SHEEN_ALBEDO_0[_S329 + u32(1)] - SHEEN_ALBEDO_0[_S331]) * _S322;
            var _S333 : SheenProfile = SheenProfile_x24init_0(true, exp(_S330 + (_S332 - _S330) * _S323));
            profile_0 = _S333;
        }
    }
    else
    {
        profile_0 = _S310;
    }
    return profile_0;
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
};

fn Weights_x24init_0( v_dot_h_0 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  p_sheen_velvet_0 : f32,  p_toon_0 : f32,  sheen_1 : vec3<f32>,  toon_0 : vec3<f32>) -> Weights
{
    var _S334 : Weights;
    _S334.v_dot_h = v_dot_h_0;
    _S334.refracted = refracted_0;
    _S334.F = F_0;
    _S334.reflect_weight = reflect_weight_0;
    _S334.diffuse_weight = diffuse_weight_0;
    _S334.refract_weight = refract_weight_0;
    _S334.p_diffuse = p_diffuse_0;
    _S334.p_reflect = p_reflect_0;
    _S334.p_refract = p_refract_0;
    _S334.p_sheen_velvet = p_sheen_velvet_0;
    _S334.p_toon = p_toon_0;
    _S334.sheen = sheen_1;
    _S334.toon = toon_0;
    return _S334;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_0 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_0), dot(w_1, cross(n_4, t_0)), dot(w_1, n_4));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S335 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S336 : f32 = _S335.x;
    var _S337 : f32 = _S335.y;
    var _S338 : f32 = _S336 * _S336 + _S337 * _S337;
    const _S339 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S340 : vec3<f32> = vec3<f32>(- _S337, _S336, 0.0f);
    var _S341 : f32 = (inverseSqrt((_S338)));
    var _S342 : vec3<f32> = _S340 * vec3<f32>(_S341);
    var _S343 : bool = _S338 > 0.0f;
    var _S344 : vec3<f32> = select(_S339, _S342, _S343);
    var _S345 : vec3<f32> = cross(_S335, _S344);
    var _S346 : f32 = sqrt(U1_0);
    var _S347 : f32 = 6.28318548202514648f * U2_0;
    var _S348 : f32 = _S346 * cos(_S347);
    var t2_0 : f32 = _S346 * sin(_S347);
    var _S349 : f32 = 0.5f * (1.0f + _S335.z);
    var t2_1 : f32 = (1.0f - _S349) * sqrt(max(0.0f, 1.0f - _S348 * _S348)) + _S349 * t2_0;
    var _S350 : vec3<f32> = vec3<f32>(_S348) * _S344 + vec3<f32>(t2_1) * _S345;
    var _S351 : f32 = ((_S348));
    var _S352 : f32 = ((_S348));
    var _S353 : vec3<f32> = _S350 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S351 * _S352 - t2_1 * t2_1))) * _S335;
    var _S354 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S353.x, alpha_0 * _S353.y, max(0.0f, _S353.z)))));
    return _S354;
}

fn worldToTangent( v_2 : vec3<f32>,  n_5 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S355 : bool = (abs(dot(n_5, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S355)
    {
        const _S356 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S356;
    }
    else
    {
        a_4 = a_3;
    }
    var _S357 : vec3<f32> = (normalize((cross(n_5, a_4))));
    var _S358 : vec3<f32> = cross(n_5, _S357);
    return vec3<f32>(dot(v_2, _S357), dot(v_2, n_5), dot(v_2, _S358));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S359 : Random = draw((*random_state_3), u32(0));
    var _S360 : Random = draw((*random_state_3), u32(2147483648));
    (*random_state_3) = _S360.state;
    var _S361 : f32 = frame_0.alphas.x;
    var _S362 : bool = _S361 > 0.0f;
    if(_S362)
    {
        var _S363 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S364 : f32 = frame_0.alphas.y;
        var _S365 : vec3<f32> = (normalize((vec3<f32>(_S361 * _S363.x, _S364 * _S363.y, _S363.z))));
        var _S366 : vec3<f32> = sampleGGXVNDF(_S365, 1.0f, _S359.value, _S360.value);
        var _S367 : vec3<f32> = (normalize((vec3<f32>(_S361 * _S366.x, _S364 * _S366.y, _S366.z))));
        return vec3<f32>(_S367.x) * frame_0.tangent + vec3<f32>(_S367.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S367.z) * n_i_2;
    }
    var _S368 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S369 : vec3<f32> = sampleGGXVNDF(_S368.xzy, alpha_1, _S359.value, _S360.value);
    var _S370 : vec3<f32> = _S369.xzy;
    var _S371 : vec3<f32> = tangentToWorld(_S370, n_i_2);
    return _S371;
}

fn sampledHalf( v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_2 : f32,  frame_1 : AnisotropicFrame,  random_state_4 : u32) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S372 : vec3<f32> = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &(state_2));
    return _S372;
}

fn refractedHalf( in_dir_0 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S373 : vec3<f32> = ((-(in_dir_0)));
    var _S374 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S373 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S375 : vec3<f32> = (normalize((_S374)));
    var _S376 : f32 = (sign((dot(n_6, _S373))));
    var _S377 : f32 = (sign((dot(_S374, n_6 * vec3<f32>(_S376)))));
    return _S375 * vec3<f32>(_S377);
}

fn reflectedHalf( in_dir_1 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S378 : vec3<f32> = ((-(in_dir_1)));
    var _S379 : vec3<f32> = (normalize((_S378 + out_dir_1)));
    return _S379;
}

fn lobeWeights( in_dir_2 : vec3<f32>,  v_5 : vec3<f32>,  n_i_4 : vec3<f32>,  ggx_n_0 : vec3<f32>,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile,  material_10 : Material,  eta_i_3 : f32,  eta_o_3 : f32) -> Weights
{
    var _S380 : f32 = dot(ggx_n_0, v_5);
    var _S381 : f32 = eta_i_3 / eta_o_3;
    var _S382 : vec3<f32> = (normalize((refract(in_dir_2, ggx_n_0, _S381))));
    var _S383 : f32 = min(sqrt(material_10.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S384 : f32 = _S383 * _S383;
    var _S385 : f32 = (1.0f + _S383) / (1.0f - _S383);
    var _S386 : f32 = abs(_S380);
    var _S387 : bool = eta_i_3 > eta_o_3;
    var _S388 : f32 = select(1.0f, _S385, _S387);
    var _S389 : f32 = select(_S385, 1.0f, _S387);
    var _S390 : f32 = fresnel(_S386, _S388, _S389);
    var _S391 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S380 * _S380)) >= (eta_o_3 * eta_o_3);
    var _S392 : vec3<f32> = material_10.specular_tint * vec3<f32>(_S384);
    var _S393 : vec3<f32> = vec3<f32>(1.0f);
    var _S394 : vec3<f32> = _S392 + (_S393 - _S392) * vec3<f32>((_S390 - _S384)) / vec3<f32>((1.0f - _S384));
    var _S395 : vec3<f32> = vec3<f32>(1.0f);
    var _S396 : vec3<f32> = select(_S394, _S395, _S391);
    var _S397 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S398 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S399 : vec3<f32> = _S393 - material_10.sheen * vec3<f32>(_S398);
        var _S400 : f32 = rgb_to_greyscale(material_10.sheen);
        var _S401 : f32 = _S400 * _S398;
        var _S402 : vec3<f32> = material_10.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S399;
        sheen_component_0 = _S401;
        sheen_2 = _S402;
    }
    else
    {
        scale_0 = _S395;
        sheen_component_0 = 0.0f;
        sheen_2 = _S397;
    }
    var _S403 : bool = (material_10.metallic) > 0.0f;
    var rebounce_0 : vec3<f32>;
    if(_S403)
    {
        var _S404 : f32 = frame_2.alphas.x;
        var _S405 : f32 = sqrt(min(_S404, frame_2.alphas.y));
        var _S406 : bool = _S404 > 0.0f;
        var _S407 : f32 = select(material_10.roughness, _S405, _S406);
        var _S408 : f32 = _S407 * _S407;
        var _S409 : f32 = pow(_S408, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S408) / (1.0f + 1.28094995021820068f * _S408);
        var _S410 : bool = _S408 > 0.0f;
        var _S411 : f32 = select(0.0f, _S409, _S410);
        var _S412 : f32 = clamp(dot(n_i_4, v_5), 0.0f, 1.0f);
        var _S413 : f32 = _S408 * _S407;
        var _S414 : f32 = min(1.00064504146575928f - _S407 * (0.00375499995425344f + _S412 * (-0.04133399948477745f + _S412 * (-0.90938502550125122f + _S412 * 0.35275399684906006f))) - _S408 * (0.27602800726890564f + _S412 * (1.27023398876190186f + _S412 * 0.04740000143647194f)) - _S413 * (0.31452900171279907f - _S412 * 0.34830701351165771f) + _S413 * _S407 * 0.27229699492454529f, 1.0f);
        var _S415 : vec3<f32> = min(_S393 / (_S393 - material_10.albedo * vec3<f32>(_S411)), vec3<f32>((1.0f / max(_S414, 0.0000152587890625f))));
        rebounce_0 = _S415;
    }
    else
    {
        rebounce_0 = _S395;
    }
    var _S416 : vec3<f32> = (mix((_S396), (material_10.albedo * rebounce_0), (material_10.metallic)));
    var F_1 : vec3<f32> = _S416 * scale_0;
    var _S417 : f32 = rgb_to_greyscale(F_1);
    var _S418 : f32 = 1.0f - material_10.metallic;
    var _S419 : vec3<f32> = _S393 - _S396;
    var _S420 : vec3<f32> = vec3<f32>(((1.0f - material_10.transmission) * _S418)) * _S419 * scale_0;
    var _S421 : vec3<f32> = vec3<f32>((material_10.transmission * _S418)) * _S419 * scale_0;
    var _S422 : f32 = max(_S417, 0.0f);
    var _S423 : f32 = rgb_to_greyscale(_S420);
    var _S424 : f32 = max(_S423, 0.0f);
    var _S425 : f32 = rgb_to_greyscale(_S421);
    var _S426 : f32 = (sign((length(_S382))));
    var _S427 : f32 = max(_S425 * _S426, 0.0f);
    var _S428 : f32 = _S422 + _S424 + _S427;
    var _S429 : f32 = min(sheen_component_0, 1.0f);
    var _S430 : bool = sheen_component_0 > 0.0f;
    var _S431 : bool;
    if(_S430)
    {
        _S431 = !(_S428 > 0.0f);
    }
    else
    {
        _S431 = false;
    }
    var _S432 : f32 = select(_S429, 1.0f, _S431);
    var _S433 : f32 = (1.0f - _S432) / max(_S428, 0.0000152587890625f);
    var _S434 : f32 = _S424 * _S433;
    var _S435 : f32 = _S422 * _S433;
    var _S436 : f32 = _S427 * _S433;
    return Weights_x24init_0(_S380, _S382, F_1, 1.0f, _S420, _S421, _S434, _S435, _S436, _S432, 0.0f * _S433, sheen_2, _S397);
}

fn translucentShare( material_11 : Material) -> f32
{
    var _S437 : f32 = rgb_to_greyscale(material_11.translucent);
    var _S438 : f32 = rgb_to_greyscale(material_11.albedo);
    var _S439 : f32 = _S437 / (_S438 + _S437);
    var _S440 : bool = _S437 > 0.0f;
    var _S441 : f32 = select(0.0f, _S439, _S440);
    return _S441;
}

fn diffusePDF( n_i_dot_l_0 : f32,  n_i_dot_v_0 : f32,  material_12 : Material,  w_2 : Weights) -> f32
{
    var _S442 : f32 = translucentShare(material_12);
    var _S443 : f32 = w_2.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S444 : f32 = w_2.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S445 : f32 = 1.0f - _S442;
    var _S446 : bool = n_i_dot_l_0 < 0.0f;
    var _S447 : f32 = select(_S445, _S442, _S446);
    var _S448 : f32 = _S444 * _S447;
    var _S449 : bool = _S442 > 0.0f;
    var _S450 : f32 = select(_S443, _S448, _S449);
    var _S451 : bool = n_i_dot_v_0 > 0.0f;
    var _S452 : f32 = select(0.0f, _S450, _S451);
    return _S452;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_5 : vec3<f32>,  material_13 : Material,  w_3 : Weights) -> vec3<f32>
{
    var _S453 : f32 = translucentShare(material_13);
    var _S454 : bool = (dot(n_i_5, l_0)) < 0.0f;
    var _S455 : vec3<f32> = select(material_13.albedo, material_13.translucent, _S454);
    var _S456 : f32 = 1.0f - _S453;
    var _S457 : f32 = select(_S456, _S453, _S454);
    var _S458 : vec3<f32> = _S455 / vec3<f32>(_S457);
    var _S459 : bool = _S453 > 0.0f;
    var _S460 : vec3<f32> = select(material_13.albedo, _S458, _S459);
    return w_3.diffuse_weight * _S460 / vec3<f32>(w_3.p_diffuse);
}

fn smithG1( alpha_3 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S461 : f32 = alpha_3 * alpha_3;
    var _S462 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S461 + (1.0f - _S461) * n_dot_x_0 * n_dot_x_0));
    var _S463 : bool = alpha_3 > 0.0f;
    var _S464 : f32 = select(1.0f, _S462, _S463);
    return _S464;
}

fn trowbridgeReitz( alpha_4 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S465 : f32 = alpha_4 * alpha_4;
    var _S466 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S465 * n_dot_h_0 * n_dot_h_0;
    return _S465 / max(3.14159274101257324f * _S466 * _S466, 1.17549435082228751e-38f);
}

fn anisotropicG1( w_4 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S467 : f32 = max(w_4.z, 0.0f);
    return 2.0f * _S467 / (_S467 + length(vec3<f32>(alphas_1.x * w_4.x, alphas_1.y * w_4.y, _S467)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S468 : f32 = alphas_2.x;
    var _S469 : f32 = h_0.x / _S468;
    var _S470 : f32 = alphas_2.y;
    var _S471 : f32 = h_0.y / _S470;
    var _S472 : f32 = h_0.z;
    var _S473 : f32 = _S469 * _S469 + _S471 * _S471 + _S472 * _S472;
    return 1.0f / max(3.14159274101257324f * _S468 * _S470 * _S473 * _S473, 1.17549435082228751e-38f);
}

fn vndfPDF( v_6 : vec3<f32>,  h_1 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_1 : f32,  alpha_5 : f32,  frame_3 : AnisotropicFrame,  v_dot_h_1 : f32) -> f32
{
    var _S474 : f32 = dot(n_i_6, h_1);
    var _S475 : f32 = smithG1(alpha_5, n_i_dot_v_1);
    var _S476 : f32 = _S475 * v_dot_h_1;
    var _S477 : f32 = trowbridgeReitz(alpha_5, _S474);
    var _S478 : f32 = _S476 * _S477 / n_i_dot_v_1;
    var _S479 : bool = alpha_5 > 0.0f;
    var _S480 : bool;
    if(_S479)
    {
        _S480 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S480 = false;
    }
    if(_S480)
    {
        _S480 = _S474 > 0.0f;
    }
    else
    {
        _S480 = false;
    }
    if(_S480)
    {
        _S480 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S480 = false;
    }
    var _S481 : f32 = select(0.0f, _S478, _S480);
    var _S482 : bool = (frame_3.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S482)
    {
        var _S483 : vec3<f32> = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        var _S484 : f32 = anisotropicG1(_S483, frame_3.alphas);
        var _S485 : vec3<f32> = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        var _S486 : f32 = anisotropicD(_S485, frame_3.alphas);
        var _S487 : f32 = _S484 * _S486;
        var _S488 : f32 = _S487 * v_dot_h_1 / n_i_dot_v_1;
        var _S489 : bool = v_dot_h_1 > 0.0f;
        if(_S489)
        {
            _S480 = _S474 > 0.0f;
        }
        else
        {
            _S480 = false;
        }
        if(_S480)
        {
            _S480 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S480 = false;
        }
        var _S490 : f32 = select(0.0f, _S488, _S480);
        pdf_h_0 = _S490;
    }
    else
    {
        pdf_h_0 = _S481;
    }
    return pdf_h_0;
}

fn refractPDF( l_dot_h_0 : f32,  pdf_h_1 : f32,  w_5 : Weights,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S491 : f32 = eta_i_4 * w_5.v_dot_h + eta_o_4 * l_dot_h_0;
    var _S492 : f32 = w_5.p_refract * pdf_h_1 * eta_o_4 * eta_o_4 * abs(l_dot_h_0) / (_S491 * _S491);
    var _S493 : bool = eta_i_4 != eta_o_4;
    var _S494 : bool;
    if(_S493)
    {
        _S494 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S494 = false;
    }
    var _S495 : f32 = select(0.0f, _S492, _S494);
    return _S495;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_6 : f32,  frame_4 : AnisotropicFrame,  material_14 : Material,  w_6 : Weights) -> vec3<f32>
{
    var _S496 : f32 = - dot(n_i_7, l_1);
    var _S497 : f32 = smithG1(alpha_6, max(_S496, 0.0f));
    var _S498 : bool = (frame_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S498)
    {
        var _S499 : vec3<f32> = ((-(n_i_7)));
        var _S500 : vec3<f32> = anisotropicLocal(l_1, frame_4.tangent, _S499);
        var _S501 : f32 = anisotropicG1(_S500, frame_4.alphas);
        G1_l_0 = _S501;
    }
    else
    {
        G1_l_0 = _S497;
    }
    var _S502 : bool = (material_14.ior) == 1.0f;
    var _S503 : f32 = select(G1_l_0, 1.0f, _S502);
    return w_6.refract_weight * vec3<f32>(_S503) * material_14.albedo / vec3<f32>(w_6.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_1 : f32,  n_i_dot_v_2 : f32,  w_7 : Weights) -> f32
{
    var _S504 : f32 = w_7.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S505 : bool = n_i_dot_l_1 > 0.0f;
    var _S506 : bool;
    if(_S505)
    {
        _S506 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S506 = false;
    }
    var _S507 : f32 = select(0.0f, _S504, _S506);
    return _S507;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  v_7 : vec3<f32>,  n_i_8 : vec3<f32>,  material_15 : Material,  w_8 : Weights) -> vec3<f32>
{
    var _S508 : vec3<f32> = (normalize((l_2 + v_7)));
    var _S509 : f32 = dot(n_i_8, _S508);
    var _S510 : f32 = max(dot(n_i_8, l_2), 0.0f);
    var _S511 : f32 = max(dot(n_i_8, v_7), 0.0f);
    var _S512 : f32 = 1.0f / max(material_15.sheen_roughness, 0.05000000074505806f);
    var _S513 : f32 = 1.0f - _S509 * _S509;
    var _S514 : f32 = (2.0f + _S512) * pow(max(_S513, 0.0f), 0.5f * _S512) * 0.5f * 0.31830987334251404f / max(4.0f * (_S510 + _S511 - _S510 * _S511), 0.0000152587890625f);
    var _S515 : bool = (material_15.velvet) > 0.0f;
    var f_3 : f32;
    if(_S515)
    {
        var _S516 : f32 = max(material_15.sheen_roughness, 0.00999999977648258f);
        var _S517 : f32 = _S516 * _S516;
        var _S518 : f32 = max(_S513, 0.0000152587890625f);
        var _S519 : f32 = exp(- _S509 * _S509 / (_S518 * _S517)) / (3.14159274101257324f * _S517 * _S518 * _S518) * min(1.0f, 2.0f * _S509 * min(_S510, _S511) / max(abs(dot(_S508, v_7)), 0.0000152587890625f)) / max(4.0f * _S510 * _S511, 0.0000152587890625f);
        f_3 = _S519;
    }
    else
    {
        f_3 = _S514;
    }
    return w_8.sheen * vec3<f32>((f_3 * _S510 * 2.0f * 3.14159274101257324f / w_8.p_sheen_velvet));
}

fn reflectPDF( pdf_h_2 : f32,  w_9 : Weights) -> f32
{
    var _S520 : f32 = w_9.p_reflect * pdf_h_2 / (4.0f * w_9.v_dot_h);
    var _S521 : bool = pdf_h_2 > 0.0f;
    var _S522 : f32 = select(0.0f, _S520, _S521);
    return _S522;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_9 : vec3<f32>,  alpha_7 : f32,  frame_5 : AnisotropicFrame,  w_10 : Weights) -> vec3<f32>
{
    var _S523 : f32 = dot(n_i_9, l_3);
    var _S524 : f32 = smithG1(alpha_7, max(_S523, 0.0f));
    var _S525 : bool = (frame_5.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S525)
    {
        var _S526 : vec3<f32> = anisotropicLocal(l_3, frame_5.tangent, n_i_9);
        var _S527 : f32 = anisotropicG1(_S526, frame_5.alphas);
        G1_l_1 = _S527;
    }
    else
    {
        G1_l_1 = _S524;
    }
    return vec3<f32>((w_10.reflect_weight * G1_l_1)) * w_10.F / vec3<f32>(w_10.p_reflect);
}

fn BSDF( in_dir_3 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_16 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S528 : vec3<f32> = ((-(in_dir_3)));
    var _S529 : f32 = dot(n_7, _S528);
    var _S530 : f32 = (sign((_S529)));
    var _S531 : vec3<f32> = n_7 * vec3<f32>(_S530);
    var _S532 : f32 = dot(_S531, out_dir_2);
    var _S533 : f32 = material_16.roughness;
    var _S534 : f32 = _S533 * _S533;
    var _S535 : AnisotropicFrame = anisotropicFrame(material_16, _S531);
    var _S536 : SheenProfile = sheenProfile(_S528, _S531, material_16);
    var _S537 : f32 = rgb_to_greyscale(material_16.translucent);
    var _S538 : bool = _S537 > 0.0f;
    var _S539 : bool = (dot(n_7, out_dir_2) * _S529) < 0.0f;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S540 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S540;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S541 : vec3<f32> = vec3<f32>(0.0f);
    var _S542 : Weights = Weights_x24init_0(0.0f, _S541, _S541, 0.0f, _S541, _S541, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S541, _S541);
    var half_of_0 : u32 = u32(4294967295);
    var w_11 : Weights = _S542;
    var ggx_n_2 : vec3<f32> = _S541;
    i_0 = u32(0);
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S543 : u32;
        if(i_0 == u32(3))
        {
            _S543 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S543 = u32(6);
            }
            else
            {
                _S543 = i_0;
            }
        }
        var _S544 : bool = _S543 == u32(0);
        var _S545 : bool;
        if(_S544)
        {
            _S545 = _S538;
        }
        else
        {
            _S545 = false;
        }
        var _S546 : bool;
        if(_S545)
        {
            _S546 = _S539;
        }
        else
        {
            _S546 = _S543 == u32(1);
        }
        var _S547 : bool = _S546 != refracted_1;
        if(_S547)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S548 : u32;
        if(_S543 == u32(6))
        {
            _S548 = u32(0);
        }
        else
        {
            if(_S543 == u32(4))
            {
                _S548 = u32(2);
            }
            else
            {
                _S548 = _S543;
            }
        }
        var _S549 : bool = _S548 != half_of_0;
        var half_of_1 : u32;
        var w_12 : Weights;
        if(_S549)
        {
            var _S550 : bool = _S548 == u32(0);
            if(_S550)
            {
                var _S551 : vec3<f32> = sampledHalf(_S528, _S531, _S534, _S535, random_state_5);
                ggx_n_1 = _S551;
            }
            else
            {
                var _S552 : bool = _S548 == u32(1);
                if(_S552)
                {
                    var _S553 : vec3<f32> = refractedHalf(in_dir_3, out_dir_2, n_7, eta_i_5, eta_o_5);
                    ggx_n_1 = _S553;
                }
                else
                {
                    var _S554 : vec3<f32> = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S554;
                }
            }
            var _S555 : Weights = lobeWeights(in_dir_3, _S528, _S531, ggx_n_1, _S535, _S536, material_16, eta_i_5, eta_o_5);
            w_12 = _S555;
            half_of_1 = _S548;
        }
        else
        {
            w_12 = w_11;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S543)
        {
        case u32(0):
            {
                var _S556 : f32 = diffusePDF(_S532, abs(_S529), material_16, w_12);
                (*pdfs_0)[i32(0)] = _S556;
                var _S557 : vec3<f32> = diffuseBSDF(out_dir_2, _S531, material_16, w_12);
                (*throughputs_0)[i32(0)] = _S557;
            }
        case u32(1):
            {
                var _S558 : f32 = dot(out_dir_2, ggx_n_1);
                var _S559 : f32 = vndfPDF(_S528, ggx_n_1, _S531, abs(_S529), _S534, _S535, w_12.v_dot_h);
                var _S560 : f32 = refractPDF(_S558, _S559, w_12, eta_i_5, eta_o_5);
                (*pdfs_0)[i32(1)] = _S560;
                var _S561 : vec3<f32> = refractBSDF(out_dir_2, _S531, _S534, _S535, material_16, w_12);
                (*throughputs_0)[i32(1)] = _S561;
            }
        case u32(4):
            {
                var _S562 : f32 = sheenVelvetPDF(_S532, abs(_S529), w_12);
                (*pdfs_0)[i32(3)] = _S562;
                var _S563 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S528, _S531, material_16, w_12);
                (*throughputs_0)[i32(3)] = _S563;
            }
        default :
            {
                var _S564 : f32 = vndfPDF(_S528, ggx_n_1, _S531, abs(_S529), _S534, _S535, w_12.v_dot_h);
                var _S565 : f32 = reflectPDF(_S564, w_12);
                (*pdfs_0)[i32(2)] = _S565;
                var _S566 : vec3<f32> = reflectBSDF(out_dir_2, _S531, _S534, _S535, w_12);
                (*throughputs_0)[i32(2)] = _S566;
            }
        }
        half_of_0 = half_of_1;
        w_11 = w_12;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S541;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S567 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S567)
        {
            var f_4 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_4;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
}

fn lightBSDF_0( in_dir_4 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_2 : vec3<f32>,  material_17 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  competing_0 : bool,  random_state_6 : u32) -> vec3<f32>
{
    var _S568 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_4)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S569 : vec3<f32> = BSDF(in_dir_4, light_0.dir, smooth_n_5, material_17, eta_i_6, eta_o_6, _S568, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S570 : bool = !competing_0;
    var _S571 : bool;
    if(_S570)
    {
        _S571 = true;
    }
    else
    {
        _S571 = (light_0.density) == 0.0f;
    }
    if(_S571)
    {
        return _S569 * light_0.radiance;
    }
    var _S572 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S572;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S573 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S573)
        {
            var _S574 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S574 * _S574)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn skyFrame_0( dir_4 : vec3<f32>) -> vec3<f32>
{
    var _S575 : vec3<f32> = vec3<f32>(- dir_4.x, dir_4.z, dir_4.y);
    var _S576 : bool = ((false));
    var _S577 : vec3<f32> = select(dir_4, _S575, _S576);
    return _S577;
}

fn environmentPdf_0( dir_5 : vec3<f32>) -> f32
{
    var _S578 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S579 : vec2<u32> = _S578 - vec2<u32>(u32(1), u32(0));
    var _S580 : vec3<f32> = skyFrame_0(dir_5);
    var _S581 : vec2<f32> = vec2<f32>(atan2(- _S580.z, - _S580.x) / 6.28318548202514648f + 0.5f, acos(clamp(_S580.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S582 : vec2<u32> = min(vec2<u32>(_S581 * vec2<f32>(_S579)), _S579 - vec2<u32>(u32(1)));
    var _S583 : vec4<f32> = (textureLoad(environment_cdf, (_S582), 0));
    var _S584 : f32 = _S583.y;
    var _S585 : u32 = _S579.x;
    var _S586 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S585, _S582.y)), 0));
    var _S587 : f32 = _S584 * _S586.y;
    return _S587 * f32(_S585 * _S579.y) / (19.73921012878417969f * length(_S580.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_6 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_6, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_5 : vec3<f32>,  dir_7 : vec3<f32>,  surface_1 : Surface,  material_18 : Material,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_2 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S588 : bool = wrongSide_0(is_inside_1, false, dir_7, surface_1.geometry_n);
    var _S589 : vec3<f32> = BSDF(in_dir_5, dir_7, surface_1.smooth_n, material_18, eta_0.x, eta_0.y, _S588, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S590 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_5 : vec3<f32> = _S590;
    loop
    {
        if(i_6 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S591 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S591)
        {
            var _S592 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S592;
            var f_6 : vec3<f32> = f_5 + (*terms_0)[i_6];
            f_5 = f_6;
        }
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    return f_5;
}

fn skyBSDF( in_dir_6 : vec3<f32>,  dir_8 : vec3<f32>,  surface_2 : Surface,  material_19 : Material,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_8 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(5)>;
    var pdfs_3 : array<f32, i32(5)>;
    var _S593 : vec3<f32> = skyLobes_0(in_dir_6, dir_8, surface_2, material_19, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S593;
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
    var _S594 : u32 = count_0 - u32(1);
    var low_1 : u32 = u32(0);
    var high_1 : u32 = _S594;
    loop
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        var _S595 : u32 = (low_1 + high_1) / u32(2);
        var _S596 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S595)), 0));
        var _S597 : bool = (_S596.x) > u_1;
        if(_S597)
        {
            high_1 = _S595;
        }
        else
        {
            var _S598 : u32 = _S595 + u32(1);
            low_1 = _S598;
        }
    }
    return low_1;
}

fn SkySample_x24init_0( dir_9 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S599 : SkySample;
    _S599.dir = dir_9;
    _S599.radiance = radiance_2;
    _S599.color = color_2;
    _S599.random_state = random_state_9;
    return _S599;
}

fn skyRadiance_0( origin_6 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S600 : bool = wrongSide_0(is_inside_3, false, dir_10, surface_3.geometry_n);
    var _S601 : bool = is_inside_3 != _S600;
    var _S602 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S603 : vec3<f32> = select(surface_3.smooth_n, _S602, _S601);
    var _S604 : Ray = Ray_x24init_0(origin_6 + vec3<f32>(surface_3.geometry_offset) * _S603, dir_10);
    var _S605 : vec3<f32> = (env_map_sample((dir_10)));
    var _S606 : vec3<f32> = (shadowTransmittance((_S604), (4.294967296e+09f)));
    return _S605 * _S606;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  wavelength_7 : f32,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S607 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S608 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S609 : vec2<u32> = _S607 - _S608;
    var _S610 : Random = draw(init_random_state_1, u32(6));
    var _S611 : Random = draw(init_random_state_1, u32(2147483654));
    var _S612 : Random = draw(init_random_state_1, u32(7));
    var _S613 : Random = draw(init_random_state_1, u32(2147483655));
    var _S614 : u32 = _S609.x;
    var _S615 : u32 = searchCDF_0(vec2<u32>(_S614, u32(0)), vec2<u32>(u32(0), u32(1)), _S609.y, _S610.value);
    var _S616 : u32 = searchCDF_0(vec2<u32>(u32(0), _S615), _S608, _S614, _S611.value);
    var _S617 : vec2<f32> = (vec2<f32>(f32(_S616), f32(_S615)) + vec2<f32>(_S612.value, _S613.value)) / vec2<f32>(_S609) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S618 : f32 = _S617.y;
    var _S619 : f32 = sin(_S618);
    var _S620 : f32 = _S617.x;
    var _S621 : vec3<f32> = skyFrame_0(vec3<f32>(_S619 * cos(_S620), cos(_S618), _S619 * sin(_S620)));
    var _S622 : f32 = environmentPdf_0(_S621);
    var _S623 : Material = pathMaterial(surface_4.material, wavelength_7);
    var _S624 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S621, surface_4, _S623, eta_2, is_inside_4, _S622, lobe_state_0);
    var _S625 : bool = !(_S622 > 0.0f);
    var _S626 : bool;
    if(_S625)
    {
        _S626 = true;
    }
    else
    {
        _S626 = (all((_S624 == vec3<f32>(0.0f))));
    }
    if(_S626)
    {
        var _S627 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S621, _S627, _S627, _S613.state);
    }
    var _S628 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S621);
    return SkySample_x24init_0(_S621, _S628, _S624 * _S628, _S613.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S629 : vec3<f32> = a_5 / b_1;
    var _S630 : vec3<f32> = vec3<f32>(0.0f);
    var _S631 : vec3<bool> = b_1 == _S630;
    var _S632 : vec3<f32> = select(_S629, _S630, _S631);
    return _S632;
}

fn withEnd( r_1 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_7 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_1;
    var _S633 : u32 = (insertBits((r_1.path), (end_0), (u32(0)), (u32(5))));
    var _S634 : u32 = (insertBits((_S633), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S634;
    candidate_0.f = f_7;
    return candidate_0;
}

fn resamplingTarget( f_8 : vec3<f32>) -> f32
{
    var _S635 : f32 = rgb_to_greyscale(abs(f_8));
    return _S635;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_1 : vec3<f32>)
{
    var _S636 : f32 = resamplingTarget(weight_1);
    var _S637 : bool = _S636 > 0.0f;
    var _S638 : bool;
    if(_S637)
    {
        _S638 = _S636 < 3.00000000549775576e+38f;
    }
    else
    {
        _S638 = false;
    }
    var _S639 : bool = !_S638;
    if(_S639)
    {
        return;
    }
    var _S640 : f32 = (*sel_0).w_sum + _S636;
    (*sel_0).w_sum = _S640;
    var _S641 : vec3<f32> = (*sel_0).color + weight_1;
    (*sel_0).color = _S641;
    var _S642 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S642.state;
    var _S643 : bool = (_S642.value * (*sel_0).w_sum) <= _S636;
    if(_S643)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S644 : vec2<u32> = (uniforms_uint.environment_map_size);
    return (all((_S644 > vec2<u32>(u32(1)))));
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_10 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_4 : f32) -> SampleBSDF
{
    var _S645 : SampleBSDF;
    _S645.unit_direction = unit_direction_1;
    _S645.throughput = throughput_0;
    _S645.random_state = random_state_10;
    _S645.refracted = refracted_3;
    _S645.lobe = lobe_1;
    _S645.pdf = pdf_4;
    return _S645;
}

fn sheenVelvetSample( v_8 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_3 : f32,  material_20 : Material,  w_13 : Weights,  random_state_11 : u32) -> SampleBSDF
{
    var _S646 : Random = draw(random_state_11, u32(3));
    var _S647 : Random = draw(random_state_11, u32(2147483651));
    var _S648 : f32 = _S646.value;
    var _S649 : f32 = sqrt(max(0.0f, 1.0f - _S648 * _S648));
    var _S650 : f32 = 6.28318548202514648f * _S647.value;
    var _S651 : vec3<f32> = tangentToWorld(vec3<f32>(_S649 * cos(_S650), _S646.value, _S649 * sin(_S650)), n_i_10);
    var _S652 : vec3<f32> = sheenVelvetBSDF(_S651, v_8, n_i_10, material_20, w_13);
    var _S653 : f32 = sheenVelvetPDF(_S646.value, n_i_dot_v_3, w_13);
    return SampleBSDF_x24init_0(_S651, _S652, _S647.state, false, u32(4), _S653);
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S654 : f32 = sqrt(random_1_0);
    var _S655 : f32 = 6.28318548202514648f * random_2_0;
    var _S656 : f32 = _S654 * cos(_S655);
    var _S657 : f32 = _S654 * sin(_S655);
    var _S658 : f32 = sqrt(max(0.0f, 1.0f - _S656 * _S656 - _S657 * _S657));
    return vec3<f32>(_S656, _S658, _S657);
}

fn diffuseSample( u_2 : f32,  n_i_11 : vec3<f32>,  n_i_dot_v_4 : f32,  material_21 : Material,  w_14 : Weights,  random_state_12 : u32) -> SampleBSDF
{
    var _S659 : Random = draw(random_state_12, u32(3));
    var _S660 : Random = draw(random_state_12, u32(2147483651));
    var _S661 : vec3<f32> = sampleCosWeightedHemisphere(_S659.value, _S660.value);
    var _S662 : f32 = translucentShare(material_21);
    var _S663 : bool = u_2 < (w_14.p_diffuse * _S662);
    var _S664 : f32 = _S661.y;
    var _S665 : f32 = - _S664;
    var _S666 : f32 = select(_S664, _S665, _S663);
    var _S667 : vec3<f32> = tangentToWorld(vec3<f32>(_S661.x, _S666, _S661.z), n_i_11);
    var _S668 : vec3<f32> = diffuseBSDF(_S667, n_i_11, material_21, w_14);
    var _S669 : f32 = diffusePDF(_S666, n_i_dot_v_4, material_21, w_14);
    return SampleBSDF_x24init_0(_S667, _S668, _S660.state, _S663, u32(0), _S669);
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_12 : vec3<f32>,  alpha_8 : f32,  frame_6 : AnisotropicFrame,  material_22 : Material,  w_15 : Weights,  pdf_h_3 : f32,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S670 : vec3<f32> = vec3<f32>(1.0f);
    var _S671 : SampleBSDF = SampleBSDF_x24init_0(_S670, _S670, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S671;
    sample_1.unit_direction = w_15.refracted;
    sample_1.random_state = random_state_13;
    sample_1.refracted = true;
    sample_1.lobe = u32(1);
    var _S672 : vec3<f32> = refractBSDF(sample_1.unit_direction, n_i_12, alpha_8, frame_6, material_22, w_15);
    sample_1.throughput = _S672;
    var _S673 : f32 = refractPDF(dot(sample_1.unit_direction, ggx_n_3), pdf_h_3, w_15, eta_i_7, eta_o_7);
    sample_1.pdf = _S673;
    return sample_1;
}

fn reflectSample( in_dir_7 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_13 : vec3<f32>,  alpha_9 : f32,  frame_7 : AnisotropicFrame,  w_16 : Weights,  pdf_h_4 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S674 : vec3<f32> = vec3<f32>(1.0f);
    var _S675 : SampleBSDF = SampleBSDF_x24init_0(_S674, _S674, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S675;
    var _S676 : vec3<f32> = (normalize((reflect(in_dir_7, ggx_n_4))));
    sample_2.unit_direction = _S676;
    sample_2.random_state = random_state_14;
    sample_2.lobe = u32(2);
    var _S677 : vec3<f32> = reflectBSDF(sample_2.unit_direction, n_i_13, alpha_9, frame_7, w_16);
    sample_2.throughput = _S677;
    var _S678 : f32 = reflectPDF(pdf_h_4, w_16);
    sample_2.pdf = _S678;
    return sample_2;
}

fn sampleBSDF( in_dir_8 : vec3<f32>,  n_8 : vec3<f32>,  material_23 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S679 : vec3<f32> = ((-(in_dir_8)));
    var _S680 : f32 = dot(n_8, _S679);
    var _S681 : f32 = (sign((_S680)));
    var n_i_14 : vec3<f32> = n_8 * vec3<f32>(_S681);
    var _S682 : f32 = abs(_S680);
    var _S683 : f32 = material_23.roughness;
    var _S684 : f32 = _S683 * _S683;
    var _S685 : AnisotropicFrame = anisotropicFrame(material_23, n_i_14);
    var _S686 : SheenProfile = sheenProfile(_S679, n_i_14, material_23);
    var _S687 : vec3<f32> = sampleHalfVector(_S679, n_i_14, _S684, _S685, &(random_state_15));
    var _S688 : Weights = lobeWeights(in_dir_8, _S679, n_i_14, _S687, _S685, _S686, material_23, eta_i_8, eta_o_8);
    var _S689 : Random = draw(random_state_15, u32(2));
    random_state_15 = _S689.state;
    var _S690 : bool = (_S689.value) < (_S688.p_sheen_velvet);
    if(_S690)
    {
        var _S691 : SampleBSDF = sheenVelvetSample(_S679, n_i_14, _S682, material_23, _S688, random_state_15);
        return _S691;
    }
    var _S692 : f32 = _S689.value - _S688.p_sheen_velvet;
    var _S693 : bool = _S692 < (_S688.p_diffuse);
    if(_S693)
    {
        var _S694 : SampleBSDF = diffuseSample(_S692, n_i_14, _S682, material_23, _S688, random_state_15);
        return _S694;
    }
    var _S695 : f32 = vndfPDF(_S679, _S687, n_i_14, _S682, _S684, _S685, _S688.v_dot_h);
    var _S696 : bool = _S692 < (_S688.p_diffuse + _S688.p_refract);
    if(_S696)
    {
        var _S697 : SampleBSDF = refractSample(_S687, n_i_14, _S684, _S685, material_23, _S688, _S695, eta_i_8, eta_o_8, random_state_15);
        return _S697;
    }
    var _S698 : SampleBSDF = reflectSample(in_dir_8, _S687, n_i_14, _S684, _S685, _S688, _S695, random_state_15);
    return _S698;
}

fn escapeWeight_0( pdf_5 : f32,  dir_11 : vec3<f32>) -> f32
{
    var _S699 : bool = pdf_5 <= 0.0f;
    var _S700 : bool;
    if(_S699)
    {
        _S700 = true;
    }
    else
    {
        var _S701 : bool = environmentMapped_0();
        _S700 = !_S701;
    }
    if(_S700)
    {
        return 1.0f;
    }
    var _S702 : f32 = environmentPdf_0(dir_11);
    return pdf_5 / (pdf_5 + _S702);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S703 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S703.x, max(_S703.y, _S703.z)), 0.0f, 1.0f);
}

fn environment_0( dir_12 : vec3<f32>) -> vec3<f32>
{
    var _S704 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S705 : bool = (all((_S704 > vec2<u32>(u32(1)))));
    if(_S705)
    {
        var _S706 : vec3<f32> = (env_map_sample((dir_12)));
        return _S706;
    }
    var _S707 : vec3<f32> = (uniforms_float.ambient);
    return _S707;
}

fn escape_0( r_2 : Reservoir,  replay_0 : bool,  stop_0 : u32,  rc_1 : u32,  end_1 : u32,  end_type_1 : u32,  scale_1 : f32,  strata_0 : u32,  chain_0 : Reservoir,  chain_throughput_0 : vec3<f32>,  b_2 : u32,  ray_2 : Ray,  throughput_2 : vec3<f32>,  density_2 : f32,  prev_0 : Vertex,  nee_vertex_0 : NEEVertex,  sky_pdf_0 : f32,  spectral_weight_0 : vec3<f32>,  wavelength_8 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S708 : Shift = Shift_x24init_0(vec3<f32>(0.0f), 0.0f);
    var _S709 : bool = !nee_vertex_0.none;
    var _S710 : f32 = select(0.0f, sky_pdf_0, _S709);
    var _S711 : f32 = escapeWeight_0(_S710, ray_2.unit_direction);
    var _S712 : vec3<f32> = environment_0(ray_2.unit_direction);
    var _S713 : vec3<f32> = pathColor(throughput_2 * _S712, spectral_weight_0, wavelength_8);
    if(replay_0)
    {
        var _S714 : bool = b_2 == stop_0;
        var _S715 : bool;
        if(_S714)
        {
            _S715 = rc_1 == u32(3);
        }
        else
        {
            _S715 = false;
        }
        if(_S715)
        {
            return Shift_x24init_0(_S713 * vec3<f32>(_S711) / vec3<f32>(r_2.jac), density_2 / r_2.jac);
        }
        var _S716 : bool = rc_1 == u32(0);
        if(_S716)
        {
            _S715 = end_type_1 == u32(3);
        }
        else
        {
            _S715 = false;
        }
        if(_S715)
        {
            _S715 = b_2 == end_1;
        }
        else
        {
            _S715 = false;
        }
        if(_S715)
        {
            _S715 = !prev_0.rough;
        }
        else
        {
            _S715 = false;
        }
        if(_S715)
        {
            return Shift_x24init_0(_S713 * vec3<f32>(_S711), 1.0f);
        }
        return _S708;
    }
    var candidate_2 : Reservoir = chain_0;
    var _S717 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
    var _S718 : bool = _S717 == u32(1);
    if(_S718)
    {
        var _S719 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
        var _S720 : bool = _S719 == b_2;
        var _S721 : f32 = select(_S711, 1.0f, _S720);
        var _S722 : vec3<f32> = safeDivide(_S713 * vec3<f32>(_S721), chain_throughput_0);
        candidate_2.radiance = _S722;
    }
    else
    {
        if(prev_0.rough)
        {
            var _S723 : u32 = (insertBits((strata_0), (b_2 + u32(1)), (u32(5)), (u32(5))));
            var _S724 : u32 = (insertBits((_S723), (u32(3)), (u32(10)), (u32(2))));
            var _S725 : u32 = (insertBits((_S724), (prev_0.lobe), (u32(15)), (u32(3))));
            var _S726 : u32 = select(u32(0), u32(1), prev_0.inside);
            var _S727 : u32 = (insertBits((_S725), (_S726), (u32(22)), (u32(1))));
            candidate_2.path = _S727;
            candidate_2.jac = prev_0.pdf;
            candidate_2.dir = ray_2.unit_direction;
        }
    }
    var _S728 : vec3<f32> = _S713 * vec3<f32>(_S711);
    var _S729 : Reservoir = withEnd(candidate_2, u32(3), b_2, _S728);
    offer(&((*sel_1)), _S729, _S728 * vec3<f32>(scale_1) / vec3<f32>(density_2));
    return _S708;
}

fn walk_0( dom_0 : Domain,  r_3 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_2 : ptr<function, Selection>) -> Shift
{
    var _S730 : vec3<f32> = vec3<f32>(0.0f);
    var _S731 : Shift = Shift_x24init_0(_S730, 0.0f);
    var _S732 : u32 = (extractBits((r_3.path), (u32(0)), (u32(5))));
    var _S733 : u32 = (extractBits((r_3.path), (u32(5)), (u32(5))));
    var _S734 : u32 = (extractBits((r_3.path), (u32(10)), (u32(2))));
    var _S735 : u32 = (extractBits((r_3.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_1)
    {
        var _S736 : bool = _S735 >= u32(3);
        var _S737 : u32 = select(u32(0), u32(1), _S736);
        var _S738 : u32 = _S732 + _S737;
        var _S739 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S738 > _S739;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S731;
    }
    var _S740 : u32 = _S733 - u32(1);
    var _S741 : bool = _S735 == u32(3);
    var _S742 : u32 = select(u32(0), u32(1), _S741);
    var _S743 : u32 = _S732 + _S742;
    var _S744 : bool = _S734 == u32(0);
    var _S745 : u32 = select(_S740, _S743, _S744);
    var _S746 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_3.rc.zw))), r_3.rc.x, r_3.rc.y, u32(0), 0.0f);
    var _S747 : vec3<f32> = (normalize((dom_0.x1 - dom_0.x0)));
    var _S748 : Ray = Ray_x24init_0(dom_0.x1, _S747);
    var ray_3 : Ray = _S748;
    var hit_1 : Hit = dom_0.hit;
    var _S749 : vec3<f32> = vec3<f32>(1.0f);
    var _S750 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S730, _S730, _S730);
    var nee_vertex_1 : NEEVertex = _S750;
    var _S751 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_1 : Vertex = _S751;
    var _S752 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S730, 0.0f, vec4<u32>(u32(0)), _S730, _S730);
    var chain_1 : Reservoir = _S752;
    chain_1.seed = r_3.seed;
    var _S753 : u32 = (extractBits((r_3.path), (u32(24)), (u32(8))));
    var _S754 : u32 = (insertBits((u32(0)), (_S753), (u32(24)), (u32(8))));
    chain_1.path = _S754;
    is_inside_5 = false;
    var wavelength_9 : f32 = 0.0f;
    var threshold_0 : f32 = 0.0f;
    var spectral_weight_1 : vec3<f32> = _S749;
    var chain_throughput_1 : vec3<f32> = _S730;
    var reconnection_0 : vec3<f32> = _S730;
    var b_3 : u32 = u32(0);
    var throughput_3 : vec3<f32> = _S749;
    var scatter_in_0 : vec3<f32> = _S730;
    var extinction_in_0 : vec3<f32> = _S730;
    var density_3 : f32 = 1.0f;
    var sky_pdf_1 : f32 = 0.0f;
    loop
    {
        var _S755 : bool = (hit_1.is_point_light) == u32(1);
        var _S756 : bool;
        if(replay_1)
        {
            _S756 = _S734 == u32(1);
        }
        else
        {
            _S756 = false;
        }
        var _S757 : bool;
        if(_S756)
        {
            _S757 = b_3 == _S733;
        }
        else
        {
            _S757 = false;
        }
        var _S758 : bool;
        if(_S757)
        {
            var _S759 : bool = (hit_1.instance_index) != (_S746.instance_index);
            if(_S759)
            {
                _S758 = true;
            }
            else
            {
                _S758 = (hit_1.triangle_index) != (_S746.triangle_index);
            }
        }
        else
        {
            _S758 = false;
        }
        if(_S758)
        {
            return _S731;
        }
        var _S760 : Surface = Surface_x24init_0(_S730, _S730, 0.0f, Material_x24init_0(_S730, _S730, 0.0f, 0.0f, 0.0f, 0.0f, _S730, _S749, 1.0f, _S730, _S730, 0.5f, 0.0f, 0.0f, _S730, 0.0f, 0.0f), false, u32(0));
        var _S761 : bool = !_S755;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_4 : vec3<f32>;
        var surface_5 : Surface;
        if(_S761)
        {
            var _S762 : u32 = noiseAddress(r_3.seed, b_3);
            var _S763 : Surface = (surfaceAt((hit_1), (ray_3.origin), (_S762)));
            var surface_6 : Surface = facingRay_0(_S763, ray_3.unit_direction);
            if(is_inside_5)
            {
                var _S764 : f32 = hit_1.distance;
                var _S765 : f32 = upsample(surface_6.material.absorption, wavelength_9);
                var _S766 : vec3<f32> = vec3<f32>(_S765);
                var _S767 : bool = wavelength_9 > 0.0f;
                var _S768 : vec3<f32> = select(surface_6.material.absorption, _S766, _S767);
                var _S769 : vec3<f32> = beerLambert(_S764, _S768);
                var _S770 : vec3<f32> = throughput_3 * _S769;
                front_n_0 = _S770;
            }
            else
            {
                front_n_0 = throughput_3;
            }
            var _S771 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_3.unit_direction)) / (hit_1.distance * hit_1.distance);
            var _S772 : bool = b_3 == u32(0);
            if(_S772)
            {
                var _S773 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S773;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S774 : vec3<f32> = front_n_0;
            var _S775 : f32 = geometry_density_0;
            scatter_0 = _S771;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S775;
            surface_5 = surface_6;
            front_n_0 = _S763.smooth_n;
            throughput_4 = _S774;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S760;
            front_n_0 = _S730;
            throughput_4 = throughput_3;
        }
        var _S776 : bool;
        if(scatter_0)
        {
            _S776 = prev_1.rough;
        }
        else
        {
            _S776 = false;
        }
        var _S777 : bool;
        if(_S776)
        {
            _S777 = (prev_1.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S777 = false;
        }
        var _S778 : Surface = surface_5;
        var _S779 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_3.unit_direction));
        var _S780 : bool = ((true));
        var _S781 : bool;
        if(_S780)
        {
            _S781 = wavelength_9 == 0.0f;
        }
        else
        {
            _S781 = false;
        }
        var _S782 : bool;
        if(_S781)
        {
            _S782 = scatter_0;
        }
        else
        {
            _S782 = false;
        }
        var _S783 : bool;
        if(_S782)
        {
            var _S784 : bool = dispersive(surface_5.material);
            _S783 = _S784;
        }
        else
        {
            _S783 = false;
        }
        var throughput_5 : vec3<f32>;
        if(_S783)
        {
            var _S785 : u32 = stream(r_3.seed, u32(512));
            var _S786 : Random = pcg(_S785);
            var _S787 : u32 = (extractBits((r_3.path), (u32(25)), (u32(7))));
            var _S788 : f32 = (f32(_S787) + _S786.value) / 128.0f;
            var _S789 : u32 = (extractBits((r_3.path), (u32(24)), (u32(1))));
            var _S790 : bool = _S789 == u32(1);
            var _S791 : f32 = select(_S786.value, _S788, _S790);
            var _S792 : vec2<f32> = sampleWavelength(_S791);
            var wavelength_10 : f32 = _S792.x;
            var _S793 : vec3<f32> = wavelengthWeights(wavelength_10);
            var _S794 : vec3<f32> = _S793 / vec3<f32>(_S792.y);
            var _S795 : f32 = upsample(throughput_4, wavelength_10);
            var _S796 : vec3<f32> = vec3<f32>(_S795);
            var _S797 : f32 = upsample(scatter_in_0, wavelength_10);
            var _S798 : vec3<f32> = vec3<f32>(_S797);
            var _S799 : f32 = upsample(extinction_in_0, wavelength_10);
            var _S800 : vec3<f32> = vec3<f32>(_S799);
            wavelength_9 = wavelength_10;
            spectral_weight_1 = _S794;
            throughput_5 = _S796;
            scatter_in_0 = _S798;
            extinction_in_0 = _S800;
        }
        else
        {
            throughput_5 = throughput_4;
        }
        var _S801 : Material = pathMaterial(surface_5.material, wavelength_9);
        var _S802 : vec2<f32> = wavelengthEta(_S801, _S779, wavelength_9);
        var _S803 : bool;
        if(scatter_0)
        {
            var _S804 : u32 = (uniforms_uint.max_bounces);
            var _S805 : bool = b_3 >= _S804;
            if(_S805)
            {
                _S803 = true;
            }
            else
            {
                var _S806 : bool = neeDecision(_S801, _S779, _S802.x, _S802.y);
                _S803 = _S806;
            }
        }
        else
        {
            _S803 = false;
        }
        var _S807 : bool = isTranslucent_0(_S801);
        var _S808 : vec3<f32> = emitted_0(_S801.emissive, ray_3.unit_direction, front_n_0);
        var emission_0 : vec3<f32>;
        if(_S755)
        {
            var _S809 : vec3<f32> = (calculatePointLightContrib((hit_1.instance_index)));
            emission_0 = _S809;
        }
        else
        {
            emission_0 = _S808;
        }
        var _S810 : bool = !replay_1;
        var _S811 : bool;
        if(_S810)
        {
            _S811 = true;
        }
        else
        {
            _S811 = b_3 >= _S745;
        }
        var _S812 : bool;
        if(_S811)
        {
            var _S813 : f32 = rgb_to_greyscale(emission_0);
            _S812 = _S813 > 0.0f;
        }
        else
        {
            _S812 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S812)
        {
            var _S814 : f32 = emissionWeight_0(nee_vertex_1, hit_1, ray_3.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S814);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S815 : bool;
        if(replay_1)
        {
            _S815 = _S734 == u32(1);
        }
        else
        {
            _S815 = false;
        }
        var _S816 : bool;
        if(_S815)
        {
            _S816 = b_3 > _S733;
        }
        else
        {
            _S816 = false;
        }
        var _S817 : bool;
        if(_S816)
        {
            _S817 = b_3 == _S732;
        }
        else
        {
            _S817 = false;
        }
        var _S818 : bool;
        if(_S817)
        {
            var _S819 : bool = _S735 == u32(1);
            if(_S819)
            {
                _S818 = true;
            }
            else
            {
                _S818 = _S735 == u32(2);
            }
        }
        else
        {
            _S818 = false;
        }
        if(_S818)
        {
            var _S820 : bool = _S755 != (_S735 == u32(2));
            if(_S820)
            {
                return _S731;
            }
            var _S821 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S821 / vec3<f32>(r_3.jac), density_3 / r_3.jac);
        }
        var _S822 : u32 = (extractBits((chain_1.path), (u32(10)), (u32(2))));
        var _S823 : bool = _S822 == u32(1);
        var here_0 : Reservoir = chain_1;
        var _S824 : u32 = (insertBits((_S754), (b_3), (u32(5)), (u32(5))));
        var _S825 : u32 = (insertBits((_S824), (u32(1)), (u32(10)), (u32(2))));
        var _S826 : u32 = (insertBits((_S825), (prev_1.lobe), (u32(15)), (u32(3))));
        var _S827 : bool = prev_1.inside;
        var _S828 : u32 = select(u32(0), u32(1), _S827);
        var _S829 : u32 = (insertBits((_S826), (_S828), (u32(22)), (u32(1))));
        here_0.path = _S829;
        var _S830 : u32 = here_0.path;
        var _S831 : bool = wavelength_9 > 0.0f;
        var _S832 : u32 = select(u32(0), u32(1), _S831);
        var _S833 : u32 = (insertBits((_S830), (_S832), (u32(23)), (u32(1))));
        here_0.path = _S833;
        var _S834 : f32 = prev_1.pdf * geometry_density_0;
        here_0.jac = _S834;
        var _S835 : vec4<u32> = vec4<u32>(hit_1.instance_index, hit_1.triangle_index, (bitcast<vec2<u32>>((hit_1.uv))));
        here_0.rc = _S835;
        var _S836 : bool;
        if(replay_1)
        {
            _S836 = _S734 == u32(1);
        }
        else
        {
            _S836 = false;
        }
        var _S837 : bool;
        if(_S836)
        {
            _S837 = b_3 == _S733;
        }
        else
        {
            _S837 = false;
        }
        var _S838 : bool = b_3 == _S745;
        var _S839 : bool;
        if(_S838)
        {
            var _S840 : bool = !scatter_0;
            if(_S840)
            {
                _S839 = true;
            }
            else
            {
                var _S841 : bool = _S734 != u32(1);
                if(_S841)
                {
                    _S839 = _S734 != u32(3);
                }
                else
                {
                    _S839 = false;
                }
            }
        }
        else
        {
            _S839 = false;
        }
        var _S842 : bool;
        if(_S839)
        {
            _S842 = _S734 == u32(2);
        }
        else
        {
            _S842 = false;
        }
        var _S843 : bool;
        if(_S842)
        {
            _S843 = !_S777;
        }
        else
        {
            _S843 = false;
        }
        var _S844 : bool;
        if(_S843)
        {
            _S844 = _S735 != u32(4);
        }
        else
        {
            _S844 = false;
        }
        var _S845 : bool = _S733 == _S732;
        var _S846 : bool;
        if(_S845)
        {
            _S846 = _S735 == u32(0);
        }
        else
        {
            _S846 = false;
        }
        var _S847 : bool;
        if(_S846)
        {
            _S847 = (hit_1.instance_index) == (_S746.instance_index);
        }
        else
        {
            _S847 = false;
        }
        var _S848 : bool;
        if(_S847)
        {
            _S848 = (hit_1.triangle_index) == (_S746.triangle_index);
        }
        else
        {
            _S848 = false;
        }
        var _S849 : bool;
        if(_S848)
        {
            _S849 = _S777;
        }
        else
        {
            _S849 = false;
        }
        var _S850 : bool = select(_S844, _S849, _S837);
        var _S851 : bool;
        if(_S803)
        {
            _S851 = select(scatter_0, _S850, replay_1);
        }
        else
        {
            _S851 = false;
        }
        var _S852 : TreeSample = TreeSample_x24init_0(_S730, _S730, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S851)
        {
            var _S853 : Surface = surface_5;
            var _S854 : u32 = noiseAddress(r_3.seed, b_3);
            var _S855 : TreeSample = sampleLightTree_0(ray_3.origin, _S778.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S807, _S854);
            var _S856 : bool = (any(((_S855.radiance) != _S730)));
            if(_S856)
            {
                var _S857 : f32 = _S802.x;
                var _S858 : f32 = _S802.y;
                var _S859 : u32 = (uniforms_uint.max_bounces);
                var _S860 : vec3<f32> = lightBSDF_0(ray_3.unit_direction, _S855, _S778.smooth_n, _S853.geometry_n, _S801, _S857, _S858, b_3 < _S859, surface_5.random_state);
                lit_0 = _S860;
            }
            else
            {
                lit_0 = _S730;
            }
            light_1 = _S855;
        }
        else
        {
            light_1 = _S852;
            lit_0 = _S730;
        }
        var _S861 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S862 : bool;
        var _S863 : bool;
        var density_4 : f32;
        var throughput_6 : vec3<f32>;
        if(_S837)
        {
            var _S864 : bool = !_S777;
            if(_S864)
            {
                return _S731;
            }
            var _S865 : u32 = (extractBits((r_3.path), (u32(23)), (u32(1))));
            var _S866 : bool = _S831 != (_S865 == u32(1));
            if(_S866)
            {
                return _S731;
            }
            var throughput_7 : vec3<f32> = throughput_5 * vec3<f32>(geometry_density_0);
            var density_5 : f32 = density_3 * geometry_density_0;
            if(_S845)
            {
                _S861 = _S735 == u32(1);
            }
            else
            {
                _S861 = false;
            }
            if(_S861)
            {
                var _S867 : vec3<f32> = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S867 / vec3<f32>(r_3.jac), density_5 / r_3.jac);
            }
            if(_S845)
            {
                wrong_side_0 = _S735 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S868 : bool = !_S803;
                if(_S868)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S869 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S869 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S731;
                }
                var _S870 : vec3<f32> = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S870 / vec3<f32>(r_3.jac), density_5 / r_3.jac);
            }
            if(_S845)
            {
                refracted_4 = _S735 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S871 : bool = !_S803;
                if(_S871)
                {
                    return _S731;
                }
                var _S872 : f32 = environmentPdf_0(r_3.dir);
                var _S873 : vec3<f32> = skyBSDF(ray_3.unit_direction, r_3.dir, surface_5, _S801, _S802, is_inside_5, _S872, surface_5.random_state);
                var _S874 : vec3<f32> = pathColor(throughput_7 * _S873 * r_3.radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S874 / vec3<f32>(r_3.jac), density_5 / r_3.jac);
            }
            var _S875 : u32 = (extractBits((r_3.path), (u32(21)), (u32(1))));
            var _S876 : bool = _S803 != (_S875 == u32(1));
            if(_S876)
            {
                return _S731;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S861 = _S838;
            }
            else
            {
                _S861 = false;
            }
            if(_S861)
            {
                var _S877 : bool = !scatter_0;
                if(_S877)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S878 : bool = _S734 != u32(1);
                    if(_S878)
                    {
                        wrong_side_0 = _S734 != u32(3);
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
                var _S879 : bool = _S734 == u32(2);
                if(_S879)
                {
                    _S756 = _S803;
                }
                else
                {
                    _S756 = false;
                }
                if(_S756)
                {
                    _S756 = !_S777;
                }
                else
                {
                    _S756 = false;
                }
                if(_S756)
                {
                    _S756 = _S735 == u32(4);
                }
                else
                {
                    _S756 = false;
                }
                if(_S756)
                {
                    var _S880 : u32 = noiseAddress(r_3.seed, b_3);
                    var _S881 : SkySample = sampleSky_0(ray_3, surface_5, wavelength_9, _S802, is_inside_5, _S880, surface_5.random_state);
                    var _S882 : vec3<f32> = pathColor(throughput_5 * _S881.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S882, 1.0f);
                }
                if(_S879)
                {
                    is_inside_5 = _S803;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S777;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S883 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S884 : bool = !(_S883 > 0.0f);
                    if(_S884)
                    {
                        return _S731;
                    }
                    var _S885 : vec3<f32> = pathColor(throughput_5 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S885, 1.0f);
                }
                if(_S744)
                {
                    is_inside_5 = _S735 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S755;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S886 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S886, 1.0f);
                }
                if(_S744)
                {
                    is_inside_5 = _S735 == u32(1);
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
                    is_inside_5 = !_S777;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S887 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S887, 1.0f);
                }
                return _S731;
            }
            else
            {
                if(_S810)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S888 : bool = b_3 > u32(0);
                    if(_S888)
                    {
                        var candidate_3 : Reservoir = chain_1;
                        if(_S823)
                        {
                            var _S889 : vec3<f32> = safeDivide(throughput_5 * emission_1, chain_throughput_1);
                            candidate_3.radiance = _S889;
                        }
                        else
                        {
                            if(_S777)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S890 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                        var _S891 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S890);
                        offer(&((*sel_2)), _S891, _S890 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                    if(_S803)
                    {
                        var _S892 : vec3<f32> = pathColor(throughput_5 * lit_0, spectral_weight_1, wavelength_9);
                        var candidate_4 : Reservoir = chain_1;
                        if(_S823)
                        {
                            var _S893 : vec3<f32> = safeDivide(_S892, chain_throughput_1);
                            candidate_4.radiance = _S893;
                        }
                        else
                        {
                            if(_S777)
                            {
                                candidate_4 = here_0;
                                var _S894 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S894;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S895 : u32 = (insertBits((_S754), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S896 : u32 = (insertBits((_S895), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S896;
                            }
                        }
                        var _S897 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S892);
                        offer(&((*sel_2)), _S897, _S892 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                    if(_S803)
                    {
                        var _S898 : bool = environmentMapped_0();
                        _S862 = _S898;
                    }
                    else
                    {
                        _S862 = false;
                    }
                    if(_S862)
                    {
                        var _S899 : u32 = (uniforms_uint.max_bounces);
                        _S863 = b_3 < _S899;
                    }
                    else
                    {
                        _S863 = false;
                    }
                    if(_S863)
                    {
                        var _S900 : u32 = noiseAddress(r_3.seed, b_3);
                        var _S901 : SkySample = sampleSky_0(ray_3, surface_5, wavelength_9, _S802, is_inside_5, _S900, surface_5.random_state);
                        var _S902 : vec3<f32> = pathColor(throughput_5 * _S901.color, spectral_weight_1, wavelength_9);
                        var candidate_5 : Reservoir = chain_1;
                        if(_S823)
                        {
                            var _S903 : vec3<f32> = safeDivide(_S902, chain_throughput_1);
                            candidate_5.radiance = _S903;
                        }
                        else
                        {
                            if(_S777)
                            {
                                candidate_5 = here_0;
                                var _S904 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S904;
                                candidate_5.dir = _S901.dir;
                                candidate_5.radiance = _S901.radiance;
                            }
                            else
                            {
                                var _S905 : u32 = (insertBits((_S754), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S906 : u32 = (insertBits((_S905), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S906;
                            }
                        }
                        var _S907 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S902);
                        offer(&((*sel_2)), _S907, _S902 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_3;
        }
        var _S908 : bool;
        var _S909 : bool;
        var straight_0 : bool;
        var _S910 : bool;
        var _S911 : bool;
        var density_6 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_1)
            {
                _S861 = _S838;
            }
            else
            {
                _S861 = false;
            }
            var _S912 : u32 = (extractBits((r_3.path), (u32(15)), (u32(3))));
            var _S913 : u32 = (extractBits((r_3.path), (u32(18)), (u32(3))));
            var _S914 : u32 = select(_S912, _S913, _S837);
            var refracted_5 : bool = _S914 == u32(1);
            var _S915 : SampleBSDF = SampleBSDF_x24init_0(_S730, _S730, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S915;
            var dir_13 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S861)
            {
                var _S916 : u32 = (extractBits((r_3.path), (u32(22)), (u32(1))));
                var _S917 : bool = is_inside_5 != (_S916 == u32(1));
                if(_S917)
                {
                    return _S731;
                }
                var _S918 : bool = _S734 == u32(1);
                if(_S918)
                {
                    var _S919 : vec3<f32> = (hitPosition((_S746)));
                    dir_13 = _S919;
                }
                else
                {
                    dir_13 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    var _S920 : bool = isTranslucent_0(_S801);
                    if(_S920)
                    {
                        wrong_side_0 = _S914 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S921 : vec3<f32> = dir_13 - ray_3.origin;
                        var _S922 : vec3<f32> = select(r_3.dir, _S921, _S918);
                        refracted_4 = (dot(_S778.smooth_n, _S922) * _S779) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S918)
                {
                    var _S923 : vec3<f32> = ray_3.origin;
                    var _S924 : Surface = surface_5;
                    var _S925 : vec3<f32> = (vec3<f32>(0) - _S778.smooth_n);
                    var _S926 : bool = is_inside_5 != refracted_4;
                    var _S927 : vec3<f32> = select(_S778.smooth_n, _S925, _S926);
                    var _S928 : vec3<f32> = (normalize((dir_13 - (_S923 + vec3<f32>(_S924.geometry_offset) * _S927))));
                    reconnection_1 = _S928;
                }
                else
                {
                    reconnection_1 = r_3.dir;
                }
                var _S929 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S929)
                {
                    return _S731;
                }
                var _S930 : vec3<f32> = dir_13;
                dir_13 = reconnection_1;
                lobe_index_0 = _S914;
                wrong_side_0 = false;
                reconnection_1 = _S930;
            }
            else
            {
                var _S931 : bool = !_S837;
                if(_S931)
                {
                    var _S932 : f32 = _S802.x;
                    var _S933 : f32 = _S802.y;
                    var _S934 : vec2<f32> = vec2<f32>(0.0f);
                    var _S935 : SampleBSDF = sampleBSDF(ray_3.unit_direction, _S778.smooth_n, _S801, _S932, _S933, surface_5.random_state, _S934);
                    var bsdf_sampled_0 : SampleBSDF = _S935;
                    var _S936 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S801.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S937 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S936.geometry_n, _S801, _S932, _S933, bsdf_sampled_0.random_state, _S934);
                        bsdf_sampled_0.unit_direction = _S937.unit_direction;
                        bsdf_sampled_0.refracted = _S937.refracted;
                        bsdf_sampled_0.throughput = _S937.throughput;
                        bsdf_sampled_0.lobe = _S937.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S938 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S936.geometry_n))) * _S936.geometry_n;
                            bsdf_sampled_0.unit_direction = _S938;
                        }
                    }
                    var _S939 : u32 = bsdf_sampled_0.lobe;
                    var _S940 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S941 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S942 : f32 = bsdf_sampled_0.pdf;
                    var _S943 : f32 = select(_S942, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S943;
                    dir_13 = _S940;
                    lobe_index_0 = _S939;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S941;
                }
                else
                {
                    dir_13 = r_3.dir;
                    lobe_index_0 = _S914;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S861)
            {
                _S862 = true;
            }
            else
            {
                _S862 = _S837;
            }
            var throughput_8 : vec3<f32>;
            var throughput_9 : vec3<f32>;
            var chain_throughput_2 : vec3<f32>;
            if(_S862)
            {
                var _S944 : vec3<f32> = ray_3.unit_direction;
                var _S945 : vec3<f32> = ((-(_S944)));
                var _S946 : f32 = (sign((_S779)));
                var _S947 : vec3<f32> = _S778.smooth_n * vec3<f32>(_S946);
                var _S948 : f32 = dot(_S947, dir_13);
                var _S949 : f32 = _S801.roughness;
                var _S950 : f32 = _S949 * _S949;
                var _S951 : AnisotropicFrame = anisotropicFrame(_S801, _S947);
                var _S952 : SheenProfile = sheenProfile(_S945, _S947, _S801);
                var _S953 : vec3<f32> = reflectedHalf(_S944, dir_13);
                var _S954 : bool = lobe_index_0 == u32(1);
                if(_S954)
                {
                    var _S955 : vec3<f32> = refractedHalf(_S944, dir_13, _S778.smooth_n, _S802.x, _S802.y);
                    throughput_8 = _S955;
                }
                else
                {
                    throughput_8 = _S953;
                }
                var _S956 : bool = lobe_index_0 == u32(0);
                if(_S956)
                {
                    _S863 = true;
                }
                else
                {
                    _S863 = lobe_index_0 == u32(6);
                }
                if(_S863)
                {
                    var _S957 : vec3<f32> = sampledHalf(_S945, _S947, _S950, _S951, surface_5.random_state);
                    throughput_9 = _S957;
                }
                else
                {
                    throughput_9 = throughput_8;
                }
                var _S958 : f32 = _S802.x;
                var _S959 : f32 = _S802.y;
                var _S960 : Weights = lobeWeights(_S944, _S945, _S947, throughput_9, _S951, _S952, _S801, _S958, _S959);
                var _S961 : f32 = abs(_S779);
                var _S962 : f32 = vndfPDF(_S945, throughput_9, _S947, _S961, _S950, _S951, _S960.v_dot_h);
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S963 : f32 = diffusePDF(_S948, _S961, _S801, _S960);
                        var _S964 : vec3<f32> = diffuseBSDF(dir_13, _S947, _S801, _S960);
                        density_6 = _S963;
                        chain_throughput_2 = _S964;
                    }
                case u32(1):
                    {
                        var _S965 : f32 = refractPDF(dot(dir_13, throughput_9), _S962, _S960, _S958, _S959);
                        var _S966 : vec3<f32> = refractBSDF(dir_13, _S947, _S950, _S951, _S801, _S960);
                        density_6 = _S965;
                        chain_throughput_2 = _S966;
                    }
                case u32(4):
                    {
                        var _S967 : f32 = sheenVelvetPDF(_S948, _S961, _S960);
                        var _S968 : vec3<f32> = sheenVelvetBSDF(dir_13, _S945, _S947, _S801, _S960);
                        density_6 = _S967;
                        chain_throughput_2 = _S968;
                    }
                default :
                    {
                        var _S969 : f32 = reflectPDF(_S962, _S960);
                        var _S970 : vec3<f32> = reflectBSDF(dir_13, _S947, _S950, _S951, _S960);
                        density_6 = _S969;
                        chain_throughput_2 = _S970;
                    }
                }
                var _S971 : bool = density_6 > 0.0f;
                if(_S971)
                {
                    var _S972 : SampleBSDF = SampleBSDF_x24init_0(dir_13, chain_throughput_2, surface_5.random_state, _S954, lobe_index_0, density_6);
                    lobe_2 = _S972;
                }
            }
            var _S973 : bool = lobe_index_0 == u32(0);
            if(_S973)
            {
                _S863 = true;
            }
            else
            {
                _S863 = lobe_index_0 == u32(4);
            }
            if(_S863)
            {
                _S908 = true;
            }
            else
            {
                _S908 = lobe_index_0 == u32(6);
            }
            var _S974 : bool = !_S908;
            if(_S974)
            {
                var _S975 : bool = (_S801.roughness) == 0.0f;
                if(_S975)
                {
                    _S909 = true;
                }
                else
                {
                    var _S976 : bool = lobe_index_0 == u32(1);
                    if(_S976)
                    {
                        _S909 = (_S802.x) == (_S802.y);
                    }
                    else
                    {
                        _S909 = false;
                    }
                }
            }
            else
            {
                _S909 = false;
            }
            var _S977 : bool = lobe_index_0 == u32(1);
            if(_S977)
            {
                straight_0 = (_S801.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S978 : bool = isTranslucent_0(_S801);
            if(_S978)
            {
                _S910 = _S973;
            }
            else
            {
                _S910 = false;
            }
            if(_S910)
            {
                _S911 = (dot(dir_13, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S911 = false;
            }
            var _S979 : bool;
            if(_S803)
            {
                _S979 = !_S909;
            }
            else
            {
                _S979 = false;
            }
            var _S980 : bool;
            if(_S979)
            {
                _S980 = !wrong_side_0;
            }
            else
            {
                _S980 = false;
            }
            var _S981 : bool;
            if(_S980)
            {
                var _S982 : f32 = lobe_2.pdf;
                var _S983 : vec3<f32> = ray_3.origin;
                var _S984 : vec3<f32> = select(_S778.smooth_n, _S730, _S807);
                var _S985 : vec3<f32> = ray_3.origin;
                var _S986 : Surface = surface_5;
                var _S987 : vec3<f32> = (vec3<f32>(0) - _S778.smooth_n);
                var _S988 : vec3<f32> = select(_S778.smooth_n, _S987, _S911);
                var _S989 : NEEVertex = NEEVertex_x24init_0(false, _S982, _S983, _S984, _S985 + vec3<f32>(_S986.geometry_offset) * _S988);
                nee_vertex_1 = _S989;
            }
            else
            {
                var _S990 : bool = lobe_index_0 != u32(1);
                if(_S990)
                {
                    _S981 = true;
                }
                else
                {
                    _S981 = (_S802.x) != (_S802.y);
                }
                if(_S981)
                {
                    nee_vertex_1.none = true;
                }
            }
            var _S991 : bool = (lobe_2.pdf) > 0.0f;
            if(_S991)
            {
                if(_S908)
                {
                    _S981 = true;
                }
                else
                {
                    _S981 = (lobe_2.pdf * prev_1.cos / (hit_1.distance * hit_1.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S981 = false;
            }
            var _S992 : bool = (lobe_2.pdf) > 0.0f;
            var _S993 : bool;
            if(_S992)
            {
                if(_S908)
                {
                    _S993 = true;
                }
                else
                {
                    _S993 = (_S801.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S993 = false;
            }
            var _S994 : bool;
            if(_S837)
            {
                var _S995 : bool = !_S981;
                if(_S995)
                {
                    return _S731;
                }
                var _S996 : bool = _S735 != u32(1);
                if(_S996)
                {
                    _S994 = _S735 != u32(2);
                }
                else
                {
                    _S994 = false;
                }
                if(_S994)
                {
                    var _S997 : f32 = lobe_2.pdf;
                    var _S998 : f32 = select(0.0f, _S997, _S803);
                    var _S999 : f32 = escapeWeight_0(_S998, r_3.dir);
                    if(_S845)
                    {
                        is_inside_5 = _S741;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S1000 : f32 = select(1.0f, _S999, is_inside_5);
                    return Shift_x24init_0(throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_3.radiance * vec3<f32>(_S1000) / vec3<f32>(r_3.jac), density_4 * lobe_2.pdf / r_3.jac);
                }
                var _S1001 : vec3<f32> = throughput_6 * vec3<f32>(lobe_2.pdf);
                var _S1002 : f32 = density_4 * lobe_2.pdf;
                throughput_8 = _S1001;
                density_6 = _S1002;
            }
            else
            {
                throughput_8 = throughput_6;
                density_6 = density_4;
            }
            if(replay_1)
            {
                _S994 = b_3 <= _S745;
            }
            else
            {
                _S994 = false;
            }
            var _S1003 : bool;
            if(_S994)
            {
                _S1003 = _S777;
            }
            else
            {
                _S1003 = false;
            }
            var _S1004 : bool;
            if(_S1003)
            {
                _S1004 = _S981;
            }
            else
            {
                _S1004 = false;
            }
            var _S1005 : bool;
            if(_S1004)
            {
                _S1005 = true;
            }
            else
            {
                if(_S861)
                {
                    _S1005 = !_S993;
                }
                else
                {
                    _S1005 = false;
                }
            }
            if(_S1005)
            {
                return _S731;
            }
            if(_S861)
            {
                var _S1006 : vec3<f32> = throughput_8 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1007 : f32 = lobe_2.pdf;
                throughput_9 = _S1006;
                survival_probability_0 = _S1007;
            }
            else
            {
                var _S1008 : vec3<f32> = throughput_8 * max(lobe_2.throughput, _S730);
                throughput_9 = _S1008;
                survival_probability_0 = density_6;
            }
            var _S1009 : bool;
            if(_S810)
            {
                _S1009 = !_S823;
            }
            else
            {
                _S1009 = false;
            }
            var _S1010 : bool;
            if(_S1009)
            {
                _S1010 = _S777;
            }
            else
            {
                _S1010 = false;
            }
            var _S1011 : bool;
            if(_S1010)
            {
                _S1011 = _S981;
            }
            else
            {
                _S1011 = false;
            }
            if(_S1011)
            {
                chain_1 = here_0;
                var _S1012 : u32 = (insertBits((chain_1.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1013 : u32 = select(u32(0), u32(1), _S803);
                var _S1014 : u32 = (insertBits((_S1012), (_S1013), (u32(21)), (u32(1))));
                chain_1.path = _S1014;
                var _S1015 : f32 = chain_1.jac * lobe_2.pdf;
                chain_1.jac = _S1015;
                chain_1.dir = dir_13;
                chain_throughput_2 = throughput_9;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            var _S1016 : Vertex = Vertex_x24init_0(_S993, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_13)), is_inside_5);
            prev_1 = _S1016;
            var _S1017 : f32 = lobe_2.pdf;
            var _S1018 : bool;
            if(_S977)
            {
                _S1018 = (_S802.x) == (_S802.y);
            }
            else
            {
                _S1018 = false;
            }
            var _S1019 : f32 = select(_S1017, sky_pdf_1, _S1018);
            var _S1020 : bool;
            if(refracted_4)
            {
                _S1020 = !_S911;
            }
            else
            {
                _S1020 = false;
            }
            var is_inside_6 : bool;
            if(_S1020)
            {
                var _S1021 : bool = !is_inside_5;
                is_inside_6 = _S1021;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_3.unit_direction = dir_13;
            var _S1022 : Surface = surface_5;
            var _S1023 : f32 = select(_S1022.geometry_offset, 0.0f, straight_0);
            var _S1024 : vec3<f32> = (vec3<f32>(0) - _S778.smooth_n);
            var _S1025 : bool = is_inside_6 != _S911;
            var _S1026 : vec3<f32> = select(_S778.smooth_n, _S1024, _S1025);
            var _S1027 : vec3<f32> = ray_3.origin + vec3<f32>(_S1023) * _S1026;
            ray_3.origin = _S1027;
            chain_throughput_1 = chain_throughput_2;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_3 = throughput_9;
            density_6 = survival_probability_0;
            sky_pdf_1 = _S1019;
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
        if(_S810)
        {
            if(_S755)
            {
                var _S1028 : vec3<f32> = pathColor(throughput_3 * emission_1, spectral_weight_1, wavelength_9);
                var candidate_6 : Reservoir = chain_1;
                var _S1029 : u32 = (extractBits((chain_1.path), (u32(10)), (u32(2))));
                var _S1030 : bool = _S1029 == u32(1);
                if(_S1030)
                {
                    var _S1031 : vec3<f32> = safeDivide(_S1028, chain_throughput_1);
                    candidate_6.radiance = _S1031;
                }
                var _S1032 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1028);
                offer(&((*sel_2)), _S1032, _S1028 * vec3<f32>(scale_2) / vec3<f32>(density_6));
            }
            if(_S755)
            {
                _S861 = true;
            }
            else
            {
                _S861 = scatter_0;
            }
            if(_S861)
            {
                var _S1033 : f32 = survivalProbability(abs(throughput_3), density_6);
                survival_probability_0 = _S1033;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1034 : u32 = (uniforms_uint.max_bounces);
            var _S1035 : bool = b_3 >= _S1034;
            if(_S1035)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1036 : bool = survival_probability_0 < 1.0f;
                if(_S1036)
                {
                    var _S1037 : u32 = noiseAddress(r_3.seed, b_3);
                    var _S1038 : Random = draw(_S1037, u32(8));
                    wrong_side_0 = survival_probability_0 < (_S1038.value);
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
            var _S1039 : f32 = density_6 * survival_probability_0;
            density_3 = _S1039;
        }
        else
        {
            density_3 = density_6;
        }
        var _S1040 : Ray = ray_3;
        var _S1041 : f32 = distance(reconnection_0, ray_3.origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S861 = _S838;
        }
        else
        {
            _S861 = false;
        }
        if(_S861)
        {
            wrong_side_0 = _S734 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1042 : f32 = select(4.294967296e+09f, _S1041, wrong_side_0);
        var _S1043 : Hit;
        if(straight_0)
        {
            _S1043 = hit_1;
        }
        else
        {
            _S1043 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1044 : Hit = (traverseInstanceBVH((_S1040), (_S761), (_S1042), (_S1043)));
        hit_1 = _S1044;
        if(replay_1)
        {
            refracted_4 = _S838;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S862 = _S734 == u32(1);
        }
        else
        {
            _S862 = false;
        }
        if(_S862)
        {
            _S863 = (hit_1.instance_index) == (_S746.instance_index);
        }
        else
        {
            _S863 = false;
        }
        if(_S863)
        {
            _S908 = (hit_1.triangle_index) == (_S746.triangle_index);
        }
        else
        {
            _S908 = false;
        }
        if(_S908)
        {
            hit_1.uv = _S746.uv;
            var _S1045 : f32 = distance(reconnection_0, ray_3.origin);
            hit_1.distance = _S1045;
        }
        if(replay_1)
        {
            _S909 = _S838;
        }
        else
        {
            _S909 = false;
        }
        if(_S909)
        {
            _S910 = _S734 == u32(3);
        }
        else
        {
            _S910 = false;
        }
        if(_S910)
        {
            _S911 = (hit_1.instance_index) != u32(4294967295);
        }
        else
        {
            _S911 = false;
        }
        if(_S911)
        {
            return _S731;
        }
        var _S1046 : bool = (hit_1.instance_index) == u32(4294967295);
        if(_S1046)
        {
            var _S1047 : Shift = escape_0(r_3, replay_1, _S745, _S734, _S732, _S735, scale_2, _S754, chain_1, chain_throughput_1, b_3, ray_3, throughput_3, density_3, prev_1, nee_vertex_1, sky_pdf_1, spectral_weight_1, wavelength_9, &((*sel_2)));
            return _S1047;
        }
        var _S1048 : Hit = hit_1;
        var _S1049 : vec3<f32> = ray_3.origin + vec3<f32>(_S1048.distance) * ray_3.unit_direction;
        ray_3.origin = _S1049;
        var _S1050 : u32 = b_3 + u32(1);
        b_3 = _S1050;
    }
    return _S731;
}

fn shift_0( dom_1 : Domain,  r_4 : Reservoir) -> Shift
{
    var _S1051 : vec3<f32> = vec3<f32>(0.0f);
    var _S1052 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1051, 0.0f, vec4<u32>(u32(0)), _S1051, _S1051), 0.0f, _S1051, u32(0), _S1051, false);
    var sel_3 : Selection = _S1052;
    var _S1053 : bool = (r_4.w) <= 0.0f;
    if(_S1053)
    {
        return Shift_x24init_0(_S1051, 0.0f);
    }
    var _S1054 : Shift = walk_0(dom_1, r_4, true, 0.0f, &(sel_3));
    return _S1054;
}

fn partner_0( p_5 : vec2<i32>,  t_1 : u32) -> vec2<i32>
{
    var sizes_0 : array<i32, i32(3)> = array<i32, i32(3)>( i32(254), i32(230), i32(210) );
    var _S1055 : u32 = (uniforms_uint.frame);
    var _S1056 : u32 = hash(_S1055 * u32(3) + t_1);
    var _S1057 : vec2<i32> = vec2<i32>(i32(1));
    var _S1058 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1059 : vec2<bool> = vec2<bool>(((_S1056 & (u32(1)))) != u32(0), ((_S1056 & (u32(2)))) != u32(0));
    var _S1060 : vec2<i32> = select(_S1057, _S1058, _S1059);
    var _S1061 : bool = ((_S1056 & (u32(4)))) != u32(0);
    var _S1062 : vec2<i32> = vec2<i32>(i32((((_S1056 >> (u32(8)))) & (u32(255)))), i32((((_S1056 >> (u32(16)))) & (u32(255)))));
    var _S1063 : vec2<i32> = p_5.yx;
    var _S1064 : vec2<i32> = select(p_5, _S1063, _S1061);
    var _S1065 : vec2<i32> = vec2<i32>(sizes_0[t_1]);
    var _S1066 : vec2<i32> = _S1064 % _S1065;
    var _S1067 : vec2<i32> = _S1065 - _S1066;
    var _S1068 : vec2<bool> = _S1060 < vec2<i32>(i32(0));
    var _S1069 : vec2<i32> = select(_S1066, _S1067, _S1068);
    var _S1070 : vec2<i32> = (_S1069 + _S1062) % _S1065;
    var _S1071 : vec4<i32> = (textureLoad(pairing, (_S1070), (t_1), 0));
    var _S1072 : vec2<i32> = _S1071.xy * _S1060;
    var _S1073 : vec2<i32> = _S1072.yx;
    var _S1074 : vec2<i32> = select(_S1072, _S1073, _S1061);
    return p_5 + _S1074;
}

struct ShiftJob
{
     dom : Domain,
     r : Reservoir,
};

fn spatialJob_0( p_6 : vec2<i32>,  t_2 : u32,  job_0 : ptr<function, ShiftJob>) -> bool
{
    var _S1075 : bool = t_2 > u32(2);
    var _S1076 : bool;
    if(_S1075)
    {
        _S1076 = true;
    }
    else
    {
        var _S1077 : vec2<u32> = (uniforms_uint.render_size);
        _S1076 = (any((p_6 >= vec2<i32>(_S1077))));
    }
    if(_S1076)
    {
        return false;
    }
    var _S1078 : Reservoir = (loadReservoir(reservoir_temp, (p_6)));
    (*job_0).r = _S1078;
    var _S1079 : bool = ((*job_0).r.w) > 0.0f;
    if(_S1079)
    {
        var _S1080 : vec2<i32> = partner_0(p_6, t_2);
        var _S1081 : Domain = (*job_0).dom;
        var _S1082 : bool = (storedDomain(reservoir_temp, (_S1080), &(_S1081)));
        (*job_0).dom = _S1081;
        _S1076 = _S1082;
    }
    else
    {
        _S1076 = false;
    }
    return _S1076;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_2 : Hit) -> Domain
{
    var _S1083 : Domain;
    _S1083.x0 = x0_0;
    _S1083.x1 = x1_0;
    _S1083.hit = hit_2;
    return _S1083;
}

fn ShiftJob_x24init_0( dom_2 : Domain,  r_5 : Reservoir) -> ShiftJob
{
    var _S1084 : ShiftJob;
    _S1084.dom = dom_2;
    _S1084.r = r_5;
    return _S1084;
}

fn shiftBin_0( r_6 : Reservoir) -> u32
{
    var _S1085 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S1086 : bool = _S1085 == u32(2);
    var _S1087 : bool;
    if(_S1086)
    {
        var _S1088 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
        _S1087 = _S1088 == u32(4);
    }
    else
    {
        _S1087 = false;
    }
    var _S1089 : u32 = select(_S1085, u32(4), _S1087);
    var _S1090 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S1091 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S1092 : u32 = _S1091 + u32(1);
    var _S1093 : bool = _S1085 == u32(0);
    var _S1094 : u32 = select(_S1090, _S1092, _S1093);
    return _S1089 * u32(8) + clamp(_S1094, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_7 : vec2<i32>,  _S1095 : ptr<function, array<u32, i32(3)>>)
{
    var _S1096 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_3 : u32 = u32(0);
    loop
    {
        var _S1097 : u32 = (uniforms_uint.restir_neighbours);
        if(t_3 < _S1097)
        {
        }
        else
        {
            break;
        }
        var _S1098 : vec3<f32> = vec3<f32>(0.0f);
        var _S1099 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1098, _S1098, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1098, 0.0f, vec4<u32>(u32(0)), _S1098, _S1098));
        var job_1 : ShiftJob = _S1099;
        var _S1100 : bool = spatialJob_0(p_7, t_3, &(job_1));
        if(_S1100)
        {
            var _S1101 : u32 = shiftBin_0(job_1.r);
            bins_0[t_3] = _S1101;
        }
        var t_4 : u32 = t_3 + u32(1);
        t_3 = t_4;
    }
    (*_S1095) = bins_0;
    return;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S1102 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S1102;
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
        var _S1103 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S1104 : u32 = (_S1103 + u32(63)) / u32(64);
        var _S1105 : bool = group_0 < _S1104;
        if(_S1105)
        {
            var _S1106 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S1107 : bool = _S1106 < _S1103;
            if(_S1107)
            {
                var _S1108 : u32 = (queued_shifts[(u32(83) + start_4 + _S1106)]);
                return _S1108;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S1104;
        var start_5 : u32 = start_4 + _S1103;
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
    var _S1109 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S1110 : u32 = t_5;
        var _S1111 : bool = (bins_1[t_5]) < u32(40);
        if(_S1111)
        {
            var _S1112 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S1110]]), u32(1));
            slots_0[t_5] = _S1112;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S1113 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S1113)
    {
        var _S1114 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S1115 : bool = _S1114 > u32(0);
        if(_S1115)
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
                var _S1116 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S1116;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S1117 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S1114)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S1117;
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
        var _S1118 : u32 = t_5;
        var _S1119 : bool = (bins_1[t_5]) < u32(40);
        if(_S1119)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S1118]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S1120 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S1120)
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
            var _S1121 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S1121 + u32(63)) / u32(64);
            var bin_4 : u32 = bin_2 + u32(1);
            bin_2 = bin_4;
            groups_0 = groups_1;
        }
        shift_queue.dispatch = array<u32, 3>((min(groups_0, u32(65535))), ((groups_0 + u32(65534)) / u32(65535)), (u32(1)));
    }
    return;
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S1122 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S1123 : bool;
    if(_S1122)
    {
        var _S1124 : vec2<u32> = (uniforms_uint.render_size);
        _S1123 = (all((q_0 < vec2<i32>(_S1124))));
    }
    else
    {
        _S1123 = false;
    }
    if(_S1123)
    {
        var _S1125 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S1123 = (bitcast<f32>((_S1125.w))) > 0.0f;
    }
    else
    {
        _S1123 = false;
    }
    return _S1123;
}

fn sameDomain_0( a_6 : Domain,  b_4 : Domain) -> bool
{
    var _S1126 : bool = (all(((a_6.x0) == (b_4.x0))));
    var _S1127 : bool;
    if(_S1126)
    {
        _S1127 = (a_6.hit.instance_index) == (b_4.hit.instance_index);
    }
    else
    {
        _S1127 = false;
    }
    if(_S1127)
    {
        _S1127 = (a_6.hit.triangle_index) == (b_4.hit.triangle_index);
    }
    else
    {
        _S1127 = false;
    }
    if(_S1127)
    {
        _S1127 = (all(((a_6.hit.uv) == (b_4.hit.uv))));
    }
    else
    {
        _S1127 = false;
    }
    return _S1127;
}

fn project_0( view_0 : mat3x3<f32>,  camera_0 : vec3<f32>,  position_0 : vec3<f32>) -> vec2<f32>
{
    var _S1128 : vec3<f32> = (((view_0) * (position_0 - camera_0)));
    var _S1129 : vec2<f32> = vec2<f32>(0.5f);
    var _S1130 : vec2<f32> = _S1128.xy / vec2<f32>(_S1128.z) * _S1129 + _S1129;
    var _S1131 : vec2<f32> = vec2<f32>(_S1130.x, 1.0f - _S1130.y);
    var _S1132 : vec2<u32> = (uniforms_uint.render_size);
    return _S1131 * vec2<f32>(_S1132);
}

fn pixelOf_0( position_1 : vec3<f32>,  previous_0 : bool) -> vec2<f32>
{
    var _S1133 : mat3x3<f32>;
    if(previous_0)
    {
        var _S1134 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
        _S1133 = _S1134;
    }
    else
    {
        var _S1135 : mat3x3<f32> = (uniforms_float.view_matrix);
        _S1133 = _S1135;
    }
    var _S1136 : vec3<f32> = (uniforms_float.camera_position);
    var _S1137 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1138 : vec2<f32> = project_0(_S1133, select(_S1136, _S1137, previous_0), position_1);
    return _S1138;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain,  seed_2 : u32) -> vec2<i32>
{
    var _S1139 : bool = previousValid_0(p_9);
    var _S1140 : bool;
    if(_S1139)
    {
        var _S1141 : Domain = (previousDomain((p_9)));
        var _S1142 : bool = sameDomain_0(_S1141, dom_3);
        _S1140 = _S1142;
    }
    else
    {
        _S1140 = false;
    }
    if(_S1140)
    {
        return p_9;
    }
    var _S1143 : bool = (dom_3.hit.instance_index) == u32(4294967295);
    if(_S1143)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1144 : vec2<f32> = pixelOf_0(dom_3.x1, true);
    var _S1145 : vec2<i32> = vec2<i32>(floor(_S1144));
    var _S1146 : bool = previousValid_0(_S1145);
    var _S1147 : bool = !_S1146;
    if(_S1147)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1148 : vec4<u32> = (textureLoad(reservoir_prev, (_S1145), (u32(0)), 0));
    var _S1149 : Domain = (previousDomain((_S1145)));
    var _S1150 : bool = (_S1149.hit.instance_index) == (dom_3.hit.instance_index);
    if(_S1150)
    {
        var _S1151 : f32 = distance(_S1149.x1, dom_3.x1);
        var _S1152 : f32 = dom_3.hit.distance * 8.0f;
        var _S1153 : vec2<u32> = (uniforms_uint.render_size);
        _S1140 = _S1151 <= (_S1152 / f32(_S1153.x));
    }
    else
    {
        _S1140 = false;
    }
    if(_S1140)
    {
        return _S1145;
    }
    var _S1154 : vec2<f32> = vec2<f32>(p_9 + _S1145) + vec2<f32>(1.0f);
    var _S1155 : vec2<f32> = pixelOf_0(_S1149.x1, false);
    var _S1156 : vec2<i32> = vec2<i32>(floor(_S1154 - _S1155));
    var _S1157 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1158 : bool = previousValid_0(_S1156);
    var _S1159 : vec2<i32> = select(_S1157, _S1156, _S1158);
    return _S1159;
}

fn sampleNeighbor_0( p_10 : vec2<i32>,  seed_3 : u32) -> vec2<i32>
{
    var _S1160 : bool = ((false));
    if(_S1160)
    {
        var _S1161 : vec2<i32> = vec2<i32>(i32(-1));
        var _S1162 : bool = previousValid_0(p_10);
        var _S1163 : vec2<i32> = select(_S1161, p_10, _S1162);
        return _S1163;
    }
    var _S1164 : vec3<f32> = vec3<f32>(0.0f);
    var _S1165 : Domain = Domain_x24init_0(_S1164, _S1164, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1165;
    var _S1166 : vec2<u32> = (uniforms_uint.render_size);
    var _S1167 : bool = (any((p_10 >= vec2<i32>(_S1166))));
    var _S1168 : bool;
    if(_S1167)
    {
        _S1168 = true;
    }
    else
    {
        var _S1169 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1168 = !_S1169;
    }
    if(_S1168)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1170 : vec2<i32> = temporalNeighbor_0(p_10, dom_4, seed_3);
    return _S1170;
}

fn storedNeighbor_0( p_11 : vec2<i32>) -> vec2<i32>
{
    var _S1171 : Reservoir = (loadReservoir(reservoir_initial, (p_11)));
    var _S1172 : vec2<i32> = sampleNeighbor_0(p_11, _S1171.seed);
    return _S1172;
}

fn temporalJob_0( p_12 : vec2<i32>,  q_1 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>,  target_0 : bool) -> bool
{
    var _S1173 : bool = t_8 > u32(1);
    var _S1174 : bool;
    if(_S1173)
    {
        _S1174 = true;
    }
    else
    {
        var _S1175 : vec2<u32> = (uniforms_uint.render_size);
        _S1174 = (any((p_12 >= vec2<i32>(_S1175))));
    }
    if(_S1174)
    {
        _S1174 = true;
    }
    else
    {
        var _S1176 : bool = ((false));
        _S1174 = _S1176;
    }
    if(_S1174)
    {
        _S1174 = true;
    }
    else
    {
        _S1174 = (q_1.x) < i32(0);
    }
    if(_S1174)
    {
        return false;
    }
    var _S1177 : bool = t_8 == u32(0);
    if(_S1177)
    {
        var _S1178 : Reservoir = (loadReservoir(reservoir_prev, (q_1)));
        (*job_2).r = _S1178;
        var _S1179 : bool = ((*job_2).r.w) > 0.0f;
        if(_S1179)
        {
            var _S1180 : bool = !target_0;
            if(_S1180)
            {
                _S1174 = true;
            }
            else
            {
                var _S1181 : Domain = (*job_2).dom;
                var _S1182 : bool = (storedDomain(reservoir_initial, (p_12), &(_S1181)));
                (*job_2).dom = _S1181;
                _S1174 = _S1182;
            }
        }
        else
        {
            _S1174 = false;
        }
        return _S1174;
    }
    var _S1183 : Reservoir = (loadReservoir(reservoir_initial, (p_12)));
    (*job_2).r = _S1183;
    var _S1184 : bool = !target_0;
    if(_S1184)
    {
        var _S1185 : bool = ((false));
        _S1174 = _S1185;
    }
    else
    {
        _S1174 = false;
    }
    if(_S1174)
    {
        return ((*job_2).r.w) > 0.0f;
    }
    var _S1186 : Domain = (previousDomain((q_1)));
    (*job_2).dom = _S1186;
    var _S1187 : vec3<f32> = vec3<f32>(0.0f);
    var _S1188 : Domain = Domain_x24init_0(_S1187, _S1187, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var own_0 : Domain = _S1188;
    var _S1189 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1189)
    {
        var _S1190 : bool = ((false));
        if(_S1190)
        {
            _S1174 = true;
        }
        else
        {
            var _S1191 : bool = (storedDomain(reservoir_initial, (p_12), &(own_0)));
            if(_S1191)
            {
                var _S1192 : bool = sameDomain_0((*job_2).dom, own_0);
                _S1174 = _S1192;
            }
            else
            {
                _S1174 = false;
            }
            _S1174 = !_S1174;
        }
    }
    else
    {
        _S1174 = false;
    }
    return _S1174;
}

fn temporalBins_0( p_13 : vec2<i32>,  _S1193 : ptr<function, array<u32, i32(3)>>)
{
    var _S1194 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_2 : array<u32, i32(3)>;
    bins_2[i32(0)] = u32(40);
    bins_2[i32(1)] = u32(40);
    bins_2[i32(2)] = u32(40);
    var _S1195 : vec2<i32> = storedNeighbor_0(p_13);
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
        var _S1196 : vec3<f32> = vec3<f32>(0.0f);
        var _S1197 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1196, _S1196, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1196, 0.0f, vec4<u32>(u32(0)), _S1196, _S1196));
        var job_3 : ShiftJob = _S1197;
        var _S1198 : bool = temporalJob_0(p_13, _S1195, t_9, &(job_3), false);
        if(_S1198)
        {
            var _S1199 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1199;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1193) = bins_2;
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
        var _S1200 : u32 = t_11;
        var _S1201 : bool = (bins_3[t_11]) < u32(40);
        if(_S1201)
        {
            var _S1202 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1200]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1203 : bool = local_invocation_index_2 < u32(40);
    if(_S1203)
    {
        var _S1204 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1205 : bool = _S1204 > u32(0);
        if(_S1205)
        {
            var _S1206 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1204)));
        }
    }
    return;
}

fn passWalk_0( dom_5 : Domain,  r_7 : Reservoir,  replay_2 : bool,  scale_3 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S1207 : Shift = walk_0(dom_5, r_7, replay_2, scale_3, &((*sel_4)));
    return _S1207;
}

fn passShift_0( dom_6 : Domain,  r_8 : Reservoir) -> Shift
{
    var _S1208 : vec3<f32> = vec3<f32>(0.0f);
    var _S1209 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1208, 0.0f, vec4<u32>(u32(0)), _S1208, _S1208), 0.0f, _S1208, u32(0), _S1208, false);
    var sel_5 : Selection = _S1209;
    var _S1210 : bool = (r_8.w) <= 0.0f;
    if(_S1210)
    {
        return Shift_x24init_0(_S1208, 0.0f);
    }
    var _S1211 : Shift = passWalk_0(dom_6, r_8, true, 0.0f, &(sel_5));
    return _S1211;
}

fn temporalShiftAt_0( p_14 : vec2<i32>,  q_2 : vec2<i32>,  t_13 : u32) -> Shift
{
    var _S1212 : vec3<f32> = vec3<f32>(0.0f);
    var _S1213 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1212, _S1212, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1212, 0.0f, vec4<u32>(u32(0)), _S1212, _S1212));
    var job_4 : ShiftJob = _S1213;
    var _S1214 : bool = temporalJob_0(p_14, q_2, t_13, &(job_4), true);
    var _S1215 : bool = !_S1214;
    if(_S1215)
    {
        return Shift_x24init_0(_S1212, 0.0f);
    }
    var _S1216 : Shift = passShift_0(job_4.dom, job_4.r);
    return _S1216;
}

fn seedDomain_0( p_15 : vec2<i32>,  seed_4 : u32,  dom_7 : ptr<function, Domain>) -> bool
{
    return true;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_5 : u32;
    var _S1217 : vec2<u32> = global_invocation_id_1.xy;
    var _S1218 : vec2<i32> = vec2<i32>(_S1217 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_8 : u32 = local_invocation_index_3;
    loop
    {
        if(i_8 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S1219 : vec2<i32> = _S1218 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1220 : bool = (all((_S1219 >= vec2<i32>(i32(0)))));
        var _S1221 : bool;
        if(_S1220)
        {
            var _S1222 : vec2<u32> = (uniforms_uint.render_size);
            _S1221 = (all((_S1219 < vec2<i32>(_S1222))));
        }
        else
        {
            _S1221 = false;
        }
        if(_S1221)
        {
            var _S1223 : vec4<u32> = (textureLoad(reservoir_prev, (_S1219), (u32(0)), 0));
            var _S1224 : u32 = _S1223.x;
            var _S1225 : bool = (bitcast<f32>((_S1223.z))) > 0.0f;
            var _S1226 : u32 = select(u32(0), _S1224, _S1225);
            seed_5 = _S1226;
        }
        else
        {
            seed_5 = u32(0);
        }
        duplication_seeds_0[i_8] = seed_5;
        var i_9 : u32 = i_8 + u32(64);
        i_8 = i_9;
    }
    workgroupBarrier();
    var _S1227 : u32 = local_invocation_id_0.y;
    var _S1228 : u32 = local_invocation_id_0.x;
    var _S1229 : u32 = duplication_seeds_0[(_S1227 + u32(8)) * u32(24) + _S1228 + u32(8)];
    seed_5 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(seed_5 < u32(17))
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
            var _S1230 : bool = (duplication_seeds_0[(_S1227 + seed_5) * u32(24) + _S1228 + x_1]) == _S1229;
            var _S1231 : u32 = select(u32(0), u32(1), _S1230);
            var count_2 : u32 = count_1 + _S1231;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_5 + u32(1);
        seed_5 = y_0;
    }
    var _S1232 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1233 : bool = _S1229 != u32(0);
    var _S1234 : f32 = select(0.0f, _S1232, _S1233);
    textureStore(duplication_out, (vec2<i32>(_S1217)), 0, (vec4<u32>((bitcast<u32>((_S1234))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_6 : ptr<function, Selection>,  r_9 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_9;
    var _S1235 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1235;
    var _S1236 : f32 = r_9.jac * shifted_0.jac;
    candidate_7.jac = _S1236;
    offer(&((*sel_6)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_9.w));
    return;
}

fn finalize( sel_7 : Selection,  c_2 : f32) -> Reservoir
{
    var r_10 : Reservoir = sel_7.r;
    var _S1237 : f32 = resamplingTarget(r_10.f);
    var _S1238 : f32 = sel_7.w_sum / _S1237;
    var _S1239 : bool = _S1237 > 0.0f;
    var _S1240 : f32 = select(0.0f, _S1238, _S1239);
    r_10.w = _S1240;
    r_10.c = c_2;
    return r_10;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1241 : vec2<u32> = global_invocation_id_2.xy;
    var _S1242 : vec2<i32> = vec2<i32>(_S1241);
    var _S1243 : vec3<f32> = vec3<f32>(0.0f);
    var _S1244 : Domain = Domain_x24init_0(_S1243, _S1243, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_8 : Domain = _S1244;
    var _S1245 : bool = (currentDomain((_S1242), &(dom_8)));
    var _S1246 : bool = !_S1245;
    if(_S1246)
    {
        var _S1247 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1243, 0.0f, vec4<u32>(u32(0)), _S1243, _S1243);
        storeReservoir(reservoir_prev_out, (_S1242), (_S1247), (dom_8.hit));
        var _S1248 : vec2<f32> = vec2<f32>(_S1241);
        var _S1249 : vec2<u32> = (uniforms_uint.render_size);
        var _S1250 : vec2<f32> = _S1248 / vec2<f32>(_S1249.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1251 : vec3<f32> = vec3<f32>(_S1250, 1.0f);
        var _S1252 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1253 : vec3<f32> = (normalize(((((_S1252) * (_S1251))))));
        var _S1254 : vec3<f32> = environment_0(_S1253);
        textureStore(compute_out, (_S1242), (u32(0)), (vec4<f32>(_S1254, 1.0f)));
        var _S1255 : u32 = (uniforms_uint.is_temporal);
        var _S1256 : bool = _S1255 == u32(1);
        if(_S1256)
        {
            textureStore(compute_out, (_S1242), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1257 : Reservoir = (loadReservoir(reservoir_temp, (_S1242)));
    var t_14 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1257.c;
    loop
    {
        var _S1258 : u32 = (uniforms_uint.restir_neighbours);
        if(t_14 < _S1258)
        {
        }
        else
        {
            break;
        }
        var _S1259 : vec2<i32> = partner_0(_S1242, t_14);
        var neighbor_0 : Domain = _S1244;
        var _S1260 : bool = (currentDomain((_S1259), &(neighbor_0)));
        if(_S1260)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1261 : vec4<u32> = (textureLoad(reservoir_temp, (_S1259), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1261.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_15 : u32 = t_14 + u32(1);
        t_14 = t_15;
    }
    var _S1262 : f32 = _S1257.c / max(count_3, 1.0f);
    var _S1263 : f32 = resamplingTarget(_S1257.f);
    var _S1264 : bool = count_3 == 0.0f;
    var _S1265 : f32 = select(0.0f, 1.0f, _S1264);
    var _S1266 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1243, 0.0f, vec4<u32>(u32(0)), _S1243, _S1243), 0.0f, _S1243, u32(0), _S1243, false);
    var sel_8 : Selection = _S1266;
    var _S1267 : u32 = (uniforms_uint.frame);
    var _S1268 : u32 = hash(_S1267);
    var _S1269 : u32 = global_invocation_id_2.x;
    var _S1270 : vec2<u32> = (uniforms_uint.render_size);
    var _S1271 : u32 = stream(_S1268, _S1269 + _S1270.x * global_invocation_id_2.y);
    var _S1272 : u32 = stream(_S1271, u32(195));
    sel_8.random_state = _S1272;
    t_14 = u32(0);
    var canonical_mis_0 : f32 = _S1265;
    loop
    {
        var _S1273 : u32 = (uniforms_uint.restir_neighbours);
        if(t_14 < _S1273)
        {
        }
        else
        {
            break;
        }
        var _S1274 : vec2<i32> = partner_0(_S1242, t_14);
        var neighbor_dom_0 : Domain = _S1244;
        var _S1275 : bool = (currentDomain((_S1274), &(neighbor_dom_0)));
        if(_S1275)
        {
            var _S1276 : Reservoir = (loadReservoir(reservoir_temp, (_S1274)));
            var _S1277 : vec4<u32> = (textureLoad(shift_data, (_S1274), (t_14), 0));
            var _S1278 : vec4<f32> = (bitcast<vec4<f32>>((_S1277)));
            var _S1279 : vec4<u32> = (textureLoad(shift_data, (_S1242), (t_14), 0));
            var _S1280 : vec4<f32> = (bitcast<vec4<f32>>((_S1279)));
            var _S1281 : f32 = (_S1276.c + _S1262) / c_sum_0;
            var _S1282 : bool = _S1263 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1282)
            {
                var _S1283 : f32 = _S1281 * _S1262 * _S1263;
                var _S1284 : f32 = _S1262 * _S1263;
                var _S1285 : f32 = resamplingTarget(_S1280.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1283 / (_S1284 + _S1276.c * _S1285);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1286 : f32 = resamplingTarget(_S1276.f);
            var _S1287 : vec3<f32> = _S1278.xyz;
            var _S1288 : Shift = Shift_x24init_0(_S1287, _S1278.w);
            var _S1289 : f32 = _S1281 * _S1276.c * _S1286;
            var _S1290 : f32 = _S1276.c * _S1286;
            var _S1291 : f32 = resamplingTarget(_S1287);
            offerShifted(&(sel_8), _S1276, _S1288, _S1289 / (_S1290 + _S1262 * _S1291));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_16 : u32 = t_14 + u32(1);
        t_14 = t_16;
    }
    offerShifted(&(sel_8), _S1257, Shift_x24init_0(_S1257.f, 1.0f), canonical_mis_0);
    var _S1292 : Reservoir = finalize(sel_8, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1242), (_S1292), (dom_8.hit));
    textureStore(reservoir_prev_out, (_S1242), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_8.hit.uv))), u32(0), u32(0))));
    var _S1293 : Surface = (surfaceAt((dom_8.hit), (dom_8.x1), (sel_8.random_state)));
    var _S1294 : vec3<f32> = (normalize((dom_8.x0 - dom_8.x1)));
    var _S1295 : f32 = (sign((dot(_S1294, _S1293.smooth_n))));
    var _S1296 : vec3<f32> = _S1293.material.emissive * vec3<f32>(max(_S1295, 0.0f));
    var _S1297 : vec3<f32> = select(_S1296, _S1243, _S1293.skip);
    var _S1298 : vec3<f32> = clamp(sel_8.color + _S1297, vec3<f32>(-65519.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1242), (u32(0)), (vec4<f32>(_S1298, 1.0f)));
    var _S1299 : u32 = (uniforms_uint.is_temporal);
    var _S1300 : bool = _S1299 == u32(1);
    if(_S1300)
    {
        textureStore(compute_out, (_S1242), (u32(1)), (vec4<f32>(dom_8.x1, f32(dom_8.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1301 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1302 : bool = _S1301 != u32(4294967295);
    if(_S1302)
    {
        var _S1303 : vec2<i32> = vec2<i32>((vec2<u32>(_S1301, (_S1301 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1304 : vec3<f32> = vec3<f32>(0.0f);
        var _S1305 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1304, _S1304, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1304, 0.0f, vec4<u32>(u32(0)), _S1304, _S1304));
        var shift_job_0 : ShiftJob = _S1305;
        var _S1306 : u32 = (_S1301 >> (u32(28)));
        var _S1307 : bool = spatialJob_0(_S1303, _S1306, &(shift_job_0));
        var _S1308 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1303), (_S1306), (vec4<u32>((bitcast<vec3<u32>>((_S1308.f))), (bitcast<u32>((_S1308.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1309 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1310 : array<u32, i32(3)>;
    spatialBins_0(_S1309, &(_S1310));
    var _S1311 : array<u32, i32(3)> = _S1310;
    var t_17 : u32 = u32(0);
    loop
    {
        if(t_17 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S1312 : bool = (_S1311[t_17]) == u32(40);
        if(_S1312)
        {
            textureStore(shift_data_out, (_S1309), (t_17), (vec4<u32>(u32(0))));
        }
        var t_18 : u32 = t_17 + u32(1);
        t_17 = t_18;
    }
    queueShifts_0(_S1309, _S1311, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1313 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1313));
    countShifts_0(_S1313, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1314 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1315 : bool = _S1314 != u32(4294967295);
    if(_S1315)
    {
        var _S1316 : vec2<i32> = vec2<i32>((vec2<u32>(_S1314, (_S1314 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1317 : vec2<i32> = storedNeighbor_0(_S1316);
        var _S1318 : u32 = (_S1314 >> (u32(28)));
        var _S1319 : Shift = temporalShiftAt_0(_S1316, _S1317, _S1318);
        textureStore(temporal_shifts_out, (_S1316), (_S1318), (vec4<u32>((bitcast<vec3<u32>>((_S1319.f))), (bitcast<u32>((_S1319.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1320 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1321 : array<u32, i32(3)>;
    temporalBins_0(_S1320, &(_S1321));
    var _S1322 : array<u32, i32(3)> = _S1321;
    var t_19 : u32 = u32(0);
    loop
    {
        if(t_19 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S1323 : bool = (_S1322[t_19]) == u32(40);
        if(_S1323)
        {
            textureStore(temporal_shifts_out, (_S1320), (t_19), (vec4<u32>(u32(0))));
        }
        var t_20 : u32 = t_19 + u32(1);
        t_19 = t_20;
    }
    queueShifts_0(_S1320, _S1322, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1324 : vec2<i32> = vec2<i32>(global_invocation_id_6.xy);
    var _S1325 : array<u32, i32(3)>;
    temporalBins_0(_S1324, &(_S1325));
    countShifts_0(_S1325, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1326 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1327 : vec3<f32> = vec3<f32>(0.0f);
    var _S1328 : Domain = Domain_x24init_0(_S1327, _S1327, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_9 : Domain = _S1328;
    var _S1329 : bool = (currentDomain((_S1326), &(dom_9)));
    var _S1330 : bool = !_S1329;
    if(_S1330)
    {
        var _S1331 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1327, 0.0f, vec4<u32>(u32(0)), _S1327, _S1327);
        storeReservoir(reservoir_temp_out, (_S1326), (_S1331), (dom_9.hit));
        return;
    }
    var _S1332 : Reservoir = (loadReservoir(reservoir_initial, (_S1326)));
    var _S1333 : bool = ((true));
    var _S1334 : bool = ((false));
    var _S1335 : bool;
    if(_S1334)
    {
        _S1335 = true;
    }
    else
    {
        _S1335 = !_S1333;
    }
    var _S1336 : vec2<i32>;
    if(_S1335)
    {
        var _S1337 : vec2<i32> = sampleNeighbor_0(_S1326, _S1332.seed);
        _S1336 = _S1337;
    }
    else
    {
        var _S1338 : vec2<i32> = storedNeighbor_0(_S1326);
        _S1336 = _S1338;
    }
    var _S1339 : bool = (_S1336.x) >= i32(0);
    var r_11 : Reservoir;
    if(_S1339)
    {
        var _S1340 : Reservoir = (loadReservoir(reservoir_prev, (_S1336)));
        var _S1341 : vec4<u32> = (textureLoad(duplication, (_S1336), 0, 0));
        var _S1342 : f32 = (bitcast<f32>((_S1341.x)));
        var _S1343 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1344 : bool = _S1343 == u32(1);
        var _S1345 : f32 = select(0.0f, _S1342, _S1344);
        var _S1346 : f32 = (mix((20.0f), (1.0f), (pow(_S1345, 0.10000000149011612f))));
        var _S1347 : f32 = min(_S1340.c, _S1346);
        var _S1348 : bool = ((false));
        var _S1349 : vec4<f32> = vec4<f32>(_S1340.f, 1.0f);
        var _S1350 : bool = !_S1348;
        if(_S1350)
        {
            _S1335 = _S1333;
        }
        else
        {
            _S1335 = false;
        }
        var to_current_0 : vec4<f32>;
        if(_S1335)
        {
            var _S1351 : vec4<u32> = (textureLoad(temporal_shifts, (_S1326), (u32(0)), 0));
            var _S1352 : vec4<f32> = (bitcast<vec4<f32>>((_S1351)));
            to_current_0 = _S1352;
        }
        else
        {
            if(_S1350)
            {
                var _S1353 : Shift = temporalShiftAt_0(_S1326, _S1336, u32(0));
                var _S1354 : vec4<f32> = vec4<f32>(_S1353.f, _S1353.jac);
                to_current_0 = _S1354;
            }
            else
            {
                to_current_0 = _S1349;
            }
        }
        var own_1 : Domain = _S1328;
        if(_S1348)
        {
            _S1335 = true;
        }
        else
        {
            var _S1355 : bool = ((false));
            var _S1356 : bool = !_S1355;
            if(_S1356)
            {
                _S1335 = (_S1332.w) > 0.0f;
            }
            else
            {
                _S1335 = false;
            }
            if(_S1335)
            {
                var _S1357 : bool = (storedDomain(reservoir_initial, (_S1326), &(own_1)));
                _S1335 = _S1357;
            }
            else
            {
                _S1335 = false;
            }
            if(_S1335)
            {
                var _S1358 : Domain = (previousDomain((_S1336)));
                var _S1359 : bool = sameDomain_0(_S1358, own_1);
                _S1335 = _S1359;
            }
            else
            {
                _S1335 = false;
            }
        }
        var _S1360 : vec4<f32> = vec4<f32>(_S1332.f, 1.0f);
        var _S1361 : bool = !_S1335;
        if(_S1361)
        {
            _S1335 = _S1333;
        }
        else
        {
            _S1335 = false;
        }
        var to_previous_0 : vec4<f32>;
        if(_S1335)
        {
            var _S1362 : vec4<u32> = (textureLoad(temporal_shifts, (_S1326), (u32(1)), 0));
            var _S1363 : vec4<f32> = (bitcast<vec4<f32>>((_S1362)));
            to_previous_0 = _S1363;
        }
        else
        {
            if(_S1361)
            {
                var _S1364 : Shift = temporalShiftAt_0(_S1326, _S1336, u32(1));
                var _S1365 : vec4<f32> = vec4<f32>(_S1364.f, _S1364.jac);
                to_previous_0 = _S1365;
            }
            else
            {
                to_previous_0 = _S1360;
            }
        }
        var _S1366 : f32 = resamplingTarget(_S1332.f);
        var _S1367 : f32 = resamplingTarget(_S1340.f);
        var _S1368 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1327, 0.0f, vec4<u32>(u32(0)), _S1327, _S1327), 0.0f, _S1327, u32(0), _S1327, false);
        var sel_9 : Selection = _S1368;
        var _S1369 : u32 = (uniforms_uint.frame);
        var _S1370 : u32 = hash(_S1369);
        var _S1371 : u32 = global_invocation_id_7.x;
        var _S1372 : vec2<u32> = (uniforms_uint.render_size);
        var _S1373 : u32 = stream(_S1370, _S1371 + _S1372.x * global_invocation_id_7.y);
        var _S1374 : u32 = stream(_S1373, u32(194));
        sel_9.random_state = _S1374;
        var _S1375 : f32 = _S1332.c * _S1366;
        var _S1376 : f32 = resamplingTarget(to_previous_0.xyz);
        var _S1377 : f32 = _S1375 / (_S1375 + _S1347 * _S1376);
        var _S1378 : f32 = _S1347 * _S1367;
        var _S1379 : vec3<f32> = to_current_0.xyz;
        var _S1380 : f32 = resamplingTarget(_S1379);
        var _S1381 : f32 = _S1378 / (_S1378 + _S1332.c * _S1380);
        var _S1382 : vec2<f32> = vec2<f32>(_S1377, _S1381);
        offerShifted(&(sel_9), _S1332, Shift_x24init_0(_S1332.f, 1.0f), _S1377);
        offerShifted(&(sel_9), _S1340, Shift_x24init_0(_S1379, to_current_0.w), _S1381);
        var _S1383 : Reservoir = finalize(sel_9, _S1332.c + _S1347);
        r_11 = _S1383;
    }
    else
    {
        r_11 = _S1332;
    }
    storeReservoir(reservoir_temp_out, (_S1326), (r_11), (dom_9.hit));
    return;
}

fn noiseOrigin( p_16 : vec2<u32>,  k_1 : u32) -> u32
{
    var _S1384 : u32 = ((((p_16.x) >> (u32(11)))) | ((((((p_16.y) >> (u32(11)))) << (u32(4))))));
    var _S1385 : vec2<u32> = noiseOffset(u32(8192) + ((k_1 >> (u32(10)))) + ((_S1384 << (u32(20)))));
    var _S1386 : vec2<u32> = ((p_16 + _S1385) & (vec2<u32>(u32(2047))));
    return ((((_S1386.x) | ((((_S1386.y) << (u32(11))))))) | (((((k_1 & (u32(1023)))) << (u32(22))))));
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1387 : vec2<u32> = global_invocation_id_8.xy;
    var _S1388 : vec2<i32> = vec2<i32>(_S1387);
    var _S1389 : vec3<f32> = vec3<f32>(0.0f);
    var _S1390 : Domain = Domain_x24init_0(_S1389, _S1389, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_10 : Domain = _S1390;
    var _S1391 : bool = (currentDomain((_S1388), &(dom_10)));
    var _S1392 : bool = !_S1391;
    if(_S1392)
    {
        var _S1393 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1389, 0.0f, vec4<u32>(u32(0)), _S1389, _S1389);
        storeReservoir(reservoir_initial_out, (_S1388), (_S1393), (dom_10.hit));
        return;
    }
    var _S1394 : u32 = (uniforms_uint.frame);
    var _S1395 : u32 = hash(_S1394);
    var _S1396 : u32 = global_invocation_id_8.x;
    var _S1397 : vec2<u32> = (uniforms_uint.render_size);
    var _S1398 : u32 = global_invocation_id_8.y;
    var _S1399 : u32 = stream(_S1395, _S1396 + _S1397.x * _S1398);
    var _S1400 : vec2<u32> = (uniforms_uint.render_size);
    var _S1401 : u32 = stream(_S1396 + _S1400.x * _S1398, u32(512));
    var _S1402 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1389, 0.0f, vec4<u32>(u32(0)), _S1389, _S1389);
    var _S1403 : Selection = Selection_x24init_0(_S1402, 0.0f, _S1389, u32(0), _S1389, false);
    var initial_0 : Selection = _S1403;
    var _S1404 : u32 = stream(_S1399, u32(193));
    initial_0.random_state = _S1404;
    var _S1405 : bool = ((true));
    var _S1406 : bool = !_S1405;
    initial_0.sums = _S1406;
    var _S1407 : u32 = stream(_S1399, u32(0));
    initial_0.r.seed = _S1407;
    var _S1408 : Hit = dom_10.hit;
    var _S1409 : u32 = (uniforms_uint.samples);
    var _S1410 : f32 = 1.0f / f32(_S1409);
    var hit_3 : Hit = _S1408;
    var i_10 : u32 = u32(0);
    var seen_0 : vec3<f32> = _S1389;
    loop
    {
        var _S1411 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1411)
        {
        }
        else
        {
            break;
        }
        var r_12 : Reservoir = _S1402;
        var _S1412 : u32 = (uniforms_uint.frame);
        var _S1413 : u32 = (uniforms_uint.samples);
        var _S1414 : u32 = _S1412 * _S1413 + i_10;
        var _S1415 : u32 = noiseOrigin(_S1387, _S1414);
        r_12.seed = _S1415;
        var _S1416 : u32 = (insertBits((u32(0)), (u32(1)), (u32(24)), (u32(1))));
        var _S1417 : u32 = (insertBits((_S1416), (((_S1401 + _S1414 * u32(2654435769)) >> (u32(25)))), (u32(25)), (u32(7))));
        r_12.path = _S1417;
        var path_1 : Domain = dom_10;
        var _S1418 : bool = seedDomain_0(_S1388, r_12.seed, &(path_1));
        var _S1419 : bool = !_S1418;
        if(_S1419)
        {
            var _S1420 : vec3<f32> = (vec3<f32>(0.0f));
            var seen_1 : vec3<f32> = seen_0 + _S1420;
            seen_0 = seen_1;
            var i_11 : u32 = i_10 + u32(1);
            i_10 = i_11;
            continue;
        }
        var _S1421 : Shift = passWalk_0(path_1, r_12, false, _S1410, &(initial_0));
        var _S1422 : bool = (initial_0.r.seed) == (r_12.seed);
        var hit_4 : Hit;
        if(_S1422)
        {
            var _S1423 : Hit = path_1.hit;
            hit_4 = _S1423;
        }
        else
        {
            hit_4 = hit_3;
        }
        hit_3 = hit_4;
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1424 : u32 = (uniforms_uint.samples);
    var seen_2 : vec3<f32> = seen_0 + initial_0.glow / vec3<f32>(f32(_S1424));
    var _S1425 : vec3<f32> = seen_2 + initial_0.color;
    var _S1426 : bool = initial_0.sums;
    var _S1427 : vec3<f32> = select(seen_2, _S1425, _S1426);
    _ = (vec4<f32>(_S1427, 1.0f));
    var _S1428 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1388), (_S1428), (hit_3));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1429 : Random = pcg(state_3);
    var _S1430 : Random = pcg(_S1429.state);
    var _S1431 : f32 = 6.28318548202514648f * _S1429.value;
    var _S1432 : f32 = sqrt(-2.0f * clamp(log(_S1430.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1430.state, _S1432 * cos(_S1431));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1433 : RandomSphere;
    _S1433.state = state_4;
    _S1433.value = value_1;
    return _S1433;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1434 : Random = normal_distribution(state_5);
    var _S1435 : Random = normal_distribution(_S1434.state);
    var _S1436 : Random = normal_distribution(_S1435.state);
    var _S1437 : vec3<f32> = (normalize((vec3<f32>(_S1434.value, _S1435.value, _S1436.value))));
    return RandomSphere_x24init_0(_S1436.state, _S1437);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1438 : vec3<f32> = p1_0 - p0_0;
    var _S1439 : vec3<f32> = p2_0 - p0_0;
    var _S1440 : vec2<f32> = uv1_0 - uv0_0;
    var _S1441 : vec2<f32> = uv2_0 - uv0_0;
    var _S1442 : f32 = _S1440.x;
    var _S1443 : f32 = _S1441.y;
    var _S1444 : f32 = _S1440.y;
    var _S1445 : f32 = _S1441.x;
    var _S1446 : f32 = _S1442 * _S1443 - _S1444 * _S1445;
    var _S1447 : f32 = 1.0f / _S1446;
    var _S1448 : vec3<f32> = vec3<f32>(_S1447);
    var t_21 : vec3<f32> = (_S1438 * vec3<f32>(_S1443) - _S1439 * vec3<f32>(_S1444)) * _S1448;
    var _S1449 : vec3<f32> = (_S1439 * vec3<f32>(_S1442) - _S1438 * vec3<f32>(_S1445)) * _S1448;
    var _S1450 : vec3<f32> = t_21 - n_9 * vec3<f32>(dot(n_9, t_21));
    var _S1451 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_9);
    var _S1452 : bool = (dot(_S1450, _S1450)) > 0.0f;
    var _S1453 : vec3<f32> = select(_S1451, _S1450, _S1452);
    var _S1454 : vec3<f32> = (normalize((_S1453)));
    var _S1455 : bool = (dot(cross(n_9, _S1454), _S1449)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1455)
    {
        var _S1456 : vec3<f32> = ((-(_S1454)));
        t_22 = _S1456;
    }
    else
    {
        t_22 = _S1454;
    }
    var _S1457 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1457, n_9);
}

fn tangentToWorldNormalMap( v_9 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_9)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_2 : vec3<f32>) -> f32
{
    var _S1458 : vec3<f32> = t1_0 - t0_0;
    var _S1459 : vec3<f32> = t2_2 - t0_0;
    var _S1460 : vec3<f32> = t2_2 - t1_0;
    var _S1461 : f32 = min(length(_S1458), min(length(_S1459), length(_S1460)));
    var _S1462 : vec3<f32> = vec3<f32>(distance(position_2, t0_0), distance(position_2, t1_0), distance(position_2, t2_2));
    var _S1463 : vec3<f32> = (normalize((n0_0)));
    var _S1464 : f32 = dot(geometry_n_4, _S1463);
    var _S1465 : vec3<f32> = (normalize((n1_0)));
    var _S1466 : f32 = dot(geometry_n_4, _S1465);
    var _S1467 : vec3<f32> = (normalize((n2_0)));
    var _S1468 : vec3<f32> = acos(abs(vec3<f32>(_S1464, _S1466, dot(geometry_n_4, _S1467))));
    var _S1469 : vec3<f32> = clamp(tan(_S1468), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1462 * _S1469, uvw_0), 0.0f, _S1461 * 0.125f);
}

fn straightThrough( material_24 : Material) -> vec3<f32>
{
    return vec3<f32>((material_24.transmission * (1.0f - material_24.metallic))) * material_24.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_10 : vec3<f32>,  material_25 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1470 : vec3<f32>;
    if((material_25.ior) == 1.0f)
    {
        var _S1471 : vec3<f32> = straightThrough(material_25);
        _S1470 = _S1471;
    }
    else
    {
        _S1470 = vec3<f32>(0.0f);
    }
    return _S1470 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_11 : Domain,  r_13 : Reservoir,  replay_3 : bool,  scale_4 : f32,  sel_10 : ptr<function, Selection>) -> Shift
{
    var _S1472 : Shift = walk_0(dom_11, r_13, replay_3, scale_4, &((*sel_10)));
    return _S1472;
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
    var i_12 : u32 = u32(0);
    loop
    {
        if(i_12 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S1473 : u32 = size_0 - u32(1);
        var _S1474 : u32 = ((x_3 + size_0 / u32(2)) & (_S1473));
        var _S1475 : bool = i_12 < u32(2);
        var _S1476 : u32 = select(_S1474, x_3, _S1475);
        var l_4 : u32 = _S1476;
        var r_14 : u32 = y_1;
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
            var _S1477 : u32 = hash((((((r_14 ^ (((t_23 << (u32(16))))))) ^ (((k_2 << (u32(28))))))) ^ (((((i_12 & (u32(1)))) << (u32(31)))))));
            var _S1478 : u32 = (l_4 ^ (((_S1477 & (_S1473)))));
            var k_3 : u32 = k_2 + u32(1);
            l_4 = r_14;
            r_14 = _S1478;
            k_2 = k_3;
        }
        var _S1479 : u32 = l_4 + r_14 * size_0;
        var _S1480 : u32 = size_0 * size_0;
        var _S1481 : u32;
        if(_S1480 >= u32(65536))
        {
            var _S1482 : u32 = _S1479 / (_S1480 / u32(65536));
            _S1481 = _S1482;
        }
        else
        {
            var _S1483 : u32 = u32(65536) / _S1480;
            _S1481 = _S1479 * _S1483;
        }
        ranks_0[i_12] = _S1481;
        var i_13 : u32 = i_12 + u32(1);
        i_12 = i_13;
    }
    var _S1484 : bool = (ranks_0[i32(0)]) == u32(65535);
    var _S1485 : bool;
    if(_S1484)
    {
        _S1485 = (ranks_0[i32(1)]) == u32(65535);
    }
    else
    {
        _S1485 = false;
    }
    var _S1486 : bool = (ranks_0[i32(2)]) == u32(65535);
    var _S1487 : bool;
    if(_S1486)
    {
        _S1487 = (ranks_0[i32(3)]) == u32(65535);
    }
    else
    {
        _S1487 = false;
    }
    if(_S1485)
    {
        _S1485 = (ranks_0[i32(3)]) != u32(65535);
    }
    else
    {
        _S1485 = false;
    }
    if(_S1485)
    {
        _S1485 = true;
    }
    else
    {
        if(_S1487)
        {
            _S1485 = (ranks_0[i32(1)]) != u32(65535);
        }
        else
        {
            _S1485 = false;
        }
    }
    var _S1488 : u32 = ranks_0[i32(0)];
    var _S1489 : u32 = ranks_0[i32(1)];
    var _S1490 : u32 = ranks_0[i32(3)];
    var _S1491 : u32 = select(_S1489, _S1490, _S1485);
    return (_S1488 | (((_S1491 << (u32(16))))));
}

fn noiseBlock( sweep_0 : u32,  colour_0 : u32,  block_0 : u32,  size_1 : u32) -> vec3<u32>
{
    var _S1492 : u32 = hash(sweep_0 * u32(7919) + u32(1));
    var _S1493 : u32 = size_1 / u32(16);
    var _S1494 : u32 = block_0 % _S1493;
    var _S1495 : u32 = block_0 / _S1493;
    var _S1496 : u32 = _S1495 % _S1493;
    var _S1497 : u32 = block_0 / (_S1493 * _S1493);
    var _S1498 : vec3<u32> = vec3<u32>(_S1494, _S1496, _S1497);
    var _S1499 : vec3<u32> = vec3<u32>((colour_0 & (u32(1))), (((colour_0 >> (u32(1)))) & (u32(1))), (colour_0 >> (u32(2))));
    return _S1498 * vec3<u32>(u32(16)) + _S1499 * vec3<u32>(u32(8)) + vec3<u32>((_S1492 & (u32(7))), (((_S1492 >> (u32(3)))) & (u32(7))), (((_S1492 >> (u32(6)))) & (u32(7))));
}

