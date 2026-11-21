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

fn Selection_x24init_0( r_0 : Reservoir,  w_sum_0 : f32,  color_0 : vec3<f32>,  random_state_0 : u32) -> Selection
{
    var _S2 : Selection;
    _S2.r = r_0;
    _S2.w_sum = w_sum_0;
    _S2.color = color_0;
    _S2.random_state = random_state_0;
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

fn hash( x_0 : u32) -> u32
{
    var _S10 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S11 : u32 = ((((_S10 >> ((((_S10 >> (u32(28)))) + u32(4))))) ^ (_S10))) * u32(277803737);
    return (((_S11 >> (u32(22)))) ^ (_S11));
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S12 : u32 = hash(index_0);
    var _S13 : u32 = hash((seed_1 ^ (_S12)));
    return _S13;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S14 : bool = transmission_1 > 0.0f;
    var _S15 : bool;
    if(_S14)
    {
        _S15 = true;
    }
    else
    {
        _S15 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S16 : f32 = select(-1.0f, 1.0f, _S15);
    return _S16;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S17 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S18 : vec3<f32> = vec3<f32>(_S17);
    return Surface_x24init_0(surface_0.smooth_n * _S18, surface_0.geometry_n * _S18, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

var<private> SPECTRAL_PRIMARIES_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f );
fn upsample( rgb_0 : vec3<f32>,  wavelength_0 : f32) -> f32
{
    var _S19 : f32 = clamp((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S20 : u32 = min(u32(_S19), u32(79));
    var _S21 : u32 = u32(3) * _S20;
    var _S22 : vec3<f32> = vec3<f32>(SPECTRAL_PRIMARIES_0[_S21], SPECTRAL_PRIMARIES_0[_S21 + u32(1)], SPECTRAL_PRIMARIES_0[_S21 + u32(2)]);
    var _S23 : vec3<f32> = vec3<f32>(SPECTRAL_PRIMARIES_0[_S21 + u32(3)], SPECTRAL_PRIMARIES_0[_S21 + u32(4)], SPECTRAL_PRIMARIES_0[_S21 + u32(5)]);
    return dot(rgb_0, _S22 + (_S23 - _S22) * vec3<f32>((_S19 - f32(_S20))));
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S24 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S24));
}

fn dispersive( material_1 : Material) -> bool
{
    var _S25 : bool = (material_1.dispersion) > 0.0f;
    var _S26 : bool;
    if(_S25)
    {
        _S26 = (material_1.ior) != 1.0f;
    }
    else
    {
        _S26 = false;
    }
    return _S26;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S27 : Random;
    _S27.state = state_0;
    _S27.value = value_0;
    return _S27;
}

fn pcg( state_1 : u32) -> Random
{
    var _S28 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S29 : u32 = hash(state_1);
    return Random_x24init_0(_S28, f32(_S29) / 4.294967296e+09f);
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
        var _S30 : u32 = (low_0 + high_0 + u32(1)) / u32(2);
        var _S31 : bool = (WAVELENGTH_CDF_0[_S30]) <= u_0;
        if(_S31)
        {
            low_0 = _S30;
        }
        else
        {
            var _S32 : u32 = _S30 - u32(1);
            high_0 = _S32;
        }
    }
    var _S33 : u32 = low_0;
    var _S34 : f32 = WAVELENGTH_CDF_0[low_0 + u32(1)] - WAVELENGTH_CDF_0[low_0];
    return vec2<f32>(0.37999999523162842f + 0.00499999988824129f * (f32(low_0) + (u_0 - WAVELENGTH_CDF_0[_S33]) / _S34), _S34 / 0.00499999988824129f);
}

var<private> WAVELENGTH_WEIGHTS_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f );
fn wavelengthWeights( wavelength_1 : f32) -> vec3<f32>
{
    var _S35 : f32 = clamp((wavelength_1 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S36 : u32 = min(u32(_S35), u32(79));
    var _S37 : u32 = u32(3) * _S36;
    var _S38 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S37], WAVELENGTH_WEIGHTS_0[_S37 + u32(1)], WAVELENGTH_WEIGHTS_0[_S37 + u32(2)]);
    var _S39 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S37 + u32(3)], WAVELENGTH_WEIGHTS_0[_S37 + u32(4)], WAVELENGTH_WEIGHTS_0[_S37 + u32(5)]);
    return _S38 + (_S39 - _S38) * vec3<f32>((_S35 - f32(_S36)));
}

fn atWavelength( material_2 : Material,  wavelength_2 : f32) -> Material
{
    var at_0 : Material = material_2;
    var _S40 : f32 = upsample(material_2.albedo, wavelength_2);
    var _S41 : vec3<f32> = vec3<f32>(_S40);
    at_0.albedo = _S41;
    var _S42 : f32 = upsample(material_2.emissive, wavelength_2);
    var _S43 : vec3<f32> = vec3<f32>(_S42);
    at_0.emissive = _S43;
    var _S44 : f32 = upsample(material_2.absorption, wavelength_2);
    var _S45 : vec3<f32> = vec3<f32>(_S44);
    at_0.absorption = _S45;
    var _S46 : f32 = upsample(material_2.specular_tint, wavelength_2);
    var _S47 : vec3<f32> = vec3<f32>(_S46);
    at_0.specular_tint = _S47;
    var _S48 : f32 = upsample(material_2.translucent, wavelength_2);
    var _S49 : vec3<f32> = vec3<f32>(_S48);
    at_0.translucent = _S49;
    var _S50 : f32 = upsample(material_2.sheen, wavelength_2);
    var _S51 : vec3<f32> = vec3<f32>(_S50);
    at_0.sheen = _S51;
    return at_0;
}

fn pathMaterial( material_3 : Material,  wavelength_3 : f32) -> Material
{
    var _S52 : Material;
    if(wavelength_3 > 0.0f)
    {
        var _S53 : Material = atWavelength(material_3, wavelength_3);
        _S52 = _S53;
    }
    else
    {
        _S52 = material_3;
    }
    return _S52;
}

fn dispersedIor( ior_1 : f32,  dispersion_1 : f32,  wavelength_4 : f32) -> f32
{
    var _S54 : f32 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    var _S55 : f32 = _S54 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    var _S56 : bool = dispersion_1 > 0.0f;
    var _S57 : f32 = select(0.0f, _S55, _S56);
    return ior_1 + _S57;
}

fn vertexEta( material_4 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S58 : bool = n_dot_v_0 < 0.0f;
    var _S59 : f32 = select(1.0f, material_4.ior, _S58);
    var _S60 : f32 = select(material_4.ior, 1.0f, _S58);
    return vec2<f32>(_S59, _S60);
}

fn wavelengthEta( material_5 : Material,  n_dot_v_1 : f32,  wavelength_5 : f32) -> vec2<f32>
{
    var refractive_0 : Material = material_5;
    var _S61 : f32 = dispersedIor(material_5.ior, material_5.dispersion, wavelength_5);
    var _S62 : bool = wavelength_5 > 0.0f;
    var _S63 : f32 = select(material_5.ior, _S61, _S62);
    refractive_0.ior = _S63;
    var _S64 : vec2<f32> = vertexEta(refractive_0, n_dot_v_1);
    return _S64;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S65 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S66 : f32 = eta_i_0 / eta_o_0 * _S65;
    var _S67 : bool = _S66 < 1.0f;
    var kr_0 : f32;
    if(_S67)
    {
        var _S68 : f32 = sqrt(max(0.0f, 1.0f - _S66 * _S66));
        var _S69 : bool = eta_i_0 == eta_o_0;
        var _S70 : f32 = select(_S68, cos_theta_0, _S69);
        var _S71 : f32 = eta_o_0 * cos_theta_0;
        var _S72 : f32 = eta_i_0 * _S70;
        var _S73 : f32 = (_S71 - _S72) / (_S71 + _S72);
        var _S74 : f32 = eta_i_0 * cos_theta_0;
        var _S75 : f32 = eta_o_0 * _S70;
        var _S76 : f32 = (_S74 - _S75) / (_S74 + _S75);
        var _S77 : f32 = (_S73 * _S73 + _S76 * _S76) / 2.0f;
        kr_0 = _S77;
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
    var _S78 : f32 = fresnel(abs(n_dot_v_2), eta_i_1, eta_o_1);
    var _S79 : vec3<f32> = (mix((vec3<f32>(_S78)), (material_6.albedo), (material_6.metallic)));
    var _S80 : f32 = rgb_to_greyscale(_S79);
    var _S81 : f32 = max((1.0f - _S80) * (1.0f - material_6.metallic) * (1.0f - material_6.transmission), 0.0f);
    var _S82 : bool = _S81 > 0.03999999910593033f;
    var _S83 : bool;
    if(_S82)
    {
        _S83 = true;
    }
    else
    {
        _S83 = (material_6.roughness) > 0.20000000298023224f;
    }
    return _S83;
}

fn isTranslucent_0( material_7 : Material) -> bool
{
    var _S84 : f32 = rgb_to_greyscale(material_7.translucent);
    return _S84 > 0.0f;
}

fn emitted_0( emissive_1 : vec3<f32>,  dir_2 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    var _S85 : f32 = (sign((dot((vec3<f32>(0) - dir_2), n_0))));
    var _S86 : vec3<f32> = emissive_1 * vec3<f32>(max(_S85, 0.0f));
    var _S87 : bool = ((false));
    var _S88 : vec3<f32> = select(_S86, emissive_1, _S87);
    return _S88;
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
    var _S89 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S90 : bool = cos_a_0 > cos_b_0;
    var _S91 : f32 = select(_S89, 1.0f, _S90);
    return _S91;
}

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S92 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S93 : vec3<f32> = node_0.high - node_0.low;
    var _S94 : vec3<f32> = p_0 - _S92;
    var _S95 : vec3<f32> = (normalize((_S94)));
    var _S96 : f32 = dot(_S94, _S94);
    var _S97 : f32 = dot(_S93, _S93) / 4.0f;
    var _S98 : f32 = abs(dot(node_0.w, _S95));
    var _S99 : f32 = sine(node_0.cos_theta_o);
    var _S100 : f32 = sqrt(max(1.0f - _S97 / _S96, 0.0f));
    var _S101 : bool = _S96 < _S97;
    var _S102 : f32 = select(_S100, -1.0f, _S101);
    var _S103 : f32 = sine(_S102);
    var _S104 : f32 = sine(_S98);
    var _S105 : f32 = cosSubClamped(_S104, _S98, _S99, node_0.cos_theta_o);
    var _S106 : f32 = sine(_S98);
    var _S107 : f32 = _S106 * node_0.cos_theta_o - _S98 * _S99;
    var _S108 : bool = _S98 > (node_0.cos_theta_o);
    var _S109 : f32 = select(_S107, 0.0f, _S108);
    var _S110 : f32 = cosSubClamped(_S109, _S105, _S103, _S102);
    var _S111 : bool = _S110 <= 0.0f;
    if(_S111)
    {
        return 0.0f;
    }
    var _S112 : f32 = - dot(_S95, normal_0);
    var _S113 : f32 = node_0.phi * _S110 / max(_S96, length(_S93) / 2.0f);
    var _S114 : f32 = sine(_S112);
    var _S115 : f32 = cosSubClamped(_S114, _S112, _S103, _S102);
    var _S116 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S117 : f32 = select(_S115, 1.0f, _S116);
    return max(_S113 * _S117, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S118 : f32 = importance(first_0, p_1, normal_1);
    var _S119 : f32 = importance(second_0, p_1, normal_1);
    var _S120 : vec2<f32> = vec2<f32>(_S118, _S119);
    var _S121 : f32 = _S120[child_0] / (_S118 + _S119);
    var _S122 : bool = (_S120[child_0]) > 0.0f;
    var _S123 : f32 = select(0.0f, _S121, _S122);
    return _S123;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_2 : vec3<f32>) -> f32
{
    var _S124 : vec3<f32> = center_0 - p_2;
    var _S125 : f32 = radius_0 * radius_0 / dot(_S124, _S124);
    var _S126 : bool = _S125 >= 1.0f;
    if(_S126)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S125)) / (6.28318548202514648f * _S125);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S127 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S128 : vec2<u32> = _S127.xy;
    var n_1 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S128;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S129 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
        if((_S129.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S130 : u32 = (access_light_tree(3u + 4u * (n_1)).w);
        var _S131 : u32 = n_1 + u32(1);
        var _S132 : LightBounds = (lightBounds((_S131)));
        var _S133 : LightBounds = (lightBounds((_S130)));
        var _S134 : u32 = trail_0.x;
        var _S135 : u32 = (_S134 & (u32(1)));
        var _S136 : f32 = childShare(_S132, _S133, origin_2, smooth_n_2, _S135);
        var probability_2 : f32 = probability_1 * _S136;
        var _S137 : bool = _S135 == u32(1);
        var _S138 : u32 = select(_S131, _S130, _S137);
        var _S139 : u32 = trail_0.y;
        var _S140 : vec2<u32> = vec2<u32>((((_S134 >> (u32(1)))) | (((_S139 << (u32(31)))))), (_S139 >> (u32(1))));
        n_1 = _S138;
        trail_0 = _S140;
        probability_1 = probability_2;
    }
    var _S141 : bool = (((_S127).z == (n_1)));
    var _S142 : bool = !_S141;
    var _S143 : bool;
    if(_S142)
    {
        _S143 = true;
    }
    else
    {
        var _S144 : LightBounds = (lightBounds((n_1)));
        var _S145 : f32 = importance(_S144, origin_2, smooth_n_2);
        _S143 = !(_S145 > 0.0f);
    }
    if(_S143)
    {
        _S143 = true;
    }
    else
    {
        var _S146 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S146)
        {
            _S143 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S143 = false;
        }
    }
    if(_S143)
    {
        return 0.0f;
    }
    var _S147 : vec4<u32> = (access_light_tree(4u + 4u * (n_1)));
    var _S148 : bool = (_S147.x) == u32(2);
    if(_S148)
    {
        var _S149 : Light = (lights[(_S147.y)]);
        var _S150 : f32 = sphereDensity(_S149.position, _S149.variance, start_1);
        return probability_1 * _S150;
    }
    var _S151 : u32 = _S147.y;
    var _S152 : u32 = ((instance_uint[(_S151) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S153 : mat3x3<f32> = (worldTriangle((_S151), (_S152 + _S147.z)));
    var _S154 : f32 = solidAngle(probability_1, cross(_S153[i32(1)] - _S153[i32(0)], _S153[i32(2)] - _S153[i32(0)]), light_point_0 - start_1);
    return _S154;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S155 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S156 : bool = b_0 > 0.0f;
    var _S157 : f32 = select(1.0f, _S155, _S156);
    return _S157;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_0 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S158 : u32 = (lightSlot((hit_0)));
    var _S159 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S158, light_point_1);
    var _S160 : f32 = powerHeuristic(vertex_0.pdf, _S159);
    return _S160;
}

fn pathColor( f_2 : vec3<f32>,  weight_0 : vec3<f32>,  wavelength_6 : f32) -> vec3<f32>
{
    var _S161 : f32 = upsample(f_2, wavelength_6);
    var _S162 : vec3<f32> = weight_0 * vec3<f32>(_S161);
    var _S163 : bool = wavelength_6 > 0.0f;
    var _S164 : vec3<f32> = select(f_2, _S162, _S163);
    return _S164;
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
    var _S165 : TreeSample;
    _S165.dir = dir_3;
    _S165.radiance = radiance_1;
    _S165.density = density_0;
    _S165.random_state = random_state_2;
    return _S165;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_3 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S166 : f32 = importance(first_1, p_3, normal_3);
    var _S167 : f32 = importance(second_1, p_3, normal_3);
    var _S168 : vec2<f32> = vec2<f32>(_S166, _S167);
    var _S169 : bool = _S166 == 0.0f;
    var _S170 : bool;
    if(_S169)
    {
        _S170 = _S167 == 0.0f;
    }
    else
    {
        _S170 = false;
    }
    if(_S170)
    {
        return u32(2);
    }
    var _S171 : f32 = _S166 + _S167;
    var _S172 : bool = _S167 > 0.0f;
    if(_S172)
    {
        _S170 = ((*pick_0) * _S171) >= _S166;
    }
    else
    {
        _S170 = false;
    }
    var _S173 : u32 = select(u32(0), u32(1), _S170);
    var _S174 : f32 = min(((*pick_0) * _S171 - f32(_S173) * _S166) / _S168[_S173], 0.99999994039535522f);
    (*pick_0) = _S174;
    var _S175 : f32 = (*probability_3) * (_S168[_S173] / _S171);
    (*probability_3) = _S175;
    return _S173;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S176 : bool = (abs(dot(n_2, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S176)
    {
        const _S177 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S177;
    }
    else
    {
        a_2 = a_1;
    }
    var _S178 : vec3<f32> = (normalize((cross(n_2, a_2))));
    var _S179 : vec3<f32> = cross(n_2, _S178);
    return vec3<f32>(v_0.x) * _S178 + vec3<f32>(v_0.y) * n_2 + vec3<f32>(v_0.z) * _S179;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S180 : vec3<f32> = center_1 - p_4;
    var _S181 : f32 = radius_1 * radius_1 / dot(_S180, _S180);
    var _S182 : f32 = u1_0 * _S181 / (1.0f + sqrt(max(1.0f - _S181, 0.0f)));
    var _S183 : f32 = 2.0f * u1_0;
    var _S184 : bool = _S181 >= 1.0f;
    var _S185 : f32 = select(_S182, _S183, _S184);
    var _S186 : f32 = sqrt(max(_S185 * (2.0f - _S185), 0.0f));
    var _S187 : f32 = 6.28318548202514648f * u2_0;
    var _S188 : vec3<f32> = vec3<f32>(_S186 * cos(_S187), 1.0f - _S185, _S186 * sin(_S187));
    var _S189 : vec3<f32> = (normalize((_S180)));
    var _S190 : vec3<f32> = tangentToWorld(_S188, _S189);
    return _S190;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S191 : vec3<f32> = center_2 - ray_0.origin;
    var _S192 : f32 = dot(_S191, ray_0.unit_direction);
    var _S193 : f32 = dot(_S191, _S191) - _S192 * _S192;
    var _S194 : f32 = radius_3 * radius_3;
    var _S195 : bool = _S193 > _S194;
    if(_S195)
    {
        return 4.294967296e+09f;
    }
    var _S196 : f32 = sqrt(_S194 - _S193);
    var _S197 : f32 = _S192 - _S196;
    var _S198 : f32 = _S192 + _S196;
    var _S199 : bool = _S197 > 0.0000152587890625f;
    var _S200 : bool;
    if(_S199)
    {
        _S200 = _S197 < max_len_0;
    }
    else
    {
        _S200 = false;
    }
    if(_S200)
    {
        return _S197;
    }
    var _S201 : bool = _S198 > 0.0000152587890625f;
    if(_S201)
    {
        _S200 = _S198 < max_len_0;
    }
    else
    {
        _S200 = false;
    }
    if(_S200)
    {
        return _S198;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S202 : vec3<f32> = (normalize((light_dir_0)));
    var _S203 : bool = (dot(smooth_n_3, _S202)) < 0.0f;
    if(_S203)
    {
        return vec3<f32>(0.0f);
    }
    var _S204 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S205 : Ray = Ray_x24init_0(_S204, _S202);
    var _S206 : f32 = shadowLength(light_dir_0);
    var _S207 : vec3<f32> = (shadowTransmittance((_S205), (_S206)));
    return _S207;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S208 : Random = pcg(init_random_state_0);
    var _S209 : Random = pcg(_S208.state);
    var _S210 : Random = pcg(_S209.state);
    var _S211 : vec3<f32> = vec3<f32>(0.0f);
    var _S212 : TreeSample = TreeSample_x24init_0(_S211, _S211, 0.0f, _S210.state);
    var sample_0 : TreeSample = _S212;
    var _S213 : vec3<f32> = select(smooth_n_4, _S211, sided_0);
    var _S214 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S215 : vec3<f32> = origin_4 + _S214 * smooth_n_4;
    var pick_1 : f32 = _S208.value;
    var probability_4 : f32 = 1.0f;
    var n_3 : u32 = u32(0);
    loop
    {
        var _S216 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
        if((_S216.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S217 : u32 = (access_light_tree(3u + 4u * (n_3)).w);
        var _S218 : u32 = n_3 + u32(1);
        var _S219 : LightBounds = (lightBounds((_S218)));
        var _S220 : LightBounds = (lightBounds((_S217)));
        var _S221 : u32 = pickChild(_S219, _S220, origin_4, _S213, &(pick_1), &(probability_4));
        var _S222 : bool = _S221 > u32(1);
        if(_S222)
        {
            return sample_0;
        }
        var _S223 : bool = _S221 == u32(1);
        var _S224 : u32 = select(_S218, _S217, _S223);
        n_3 = _S224;
    }
    var _S225 : bool = n_3 == u32(0);
    var _S226 : bool;
    if(_S225)
    {
        var _S227 : LightBounds = (lightBounds((u32(0))));
        var _S228 : f32 = importance(_S227, origin_4, _S213);
        _S226 = !(_S228 > 0.0f);
    }
    else
    {
        _S226 = false;
    }
    if(_S226)
    {
        return sample_0;
    }
    var _S229 : vec4<u32> = (access_light_tree(4u + 4u * (n_3)));
    var _S230 : bool = (_S229.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S230)
    {
        var _S231 : Light = (lights[(_S229.y)]);
        if(sided_0)
        {
            var _S232 : f32 = (sign((dot(geometry_n_1, _S231.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S232);
            var _S233 : vec3<f32> = origin_4 + _S214 * lift_n_1;
            start_2 = _S233;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S215;
            lift_n_0 = smooth_n_4;
        }
        var _S234 : bool = (_S231.variance) == 0.0f;
        if(_S234)
        {
            var _S235 : vec3<f32> = _S231.position - start_2;
            var _S236 : vec3<f32> = (normalize((_S235)));
            sample_0.dir = _S236;
            var _S237 : vec3<f32> = _S231.color * vec3<f32>(_S231.intensity) / vec3<f32>((dot(_S235, _S235) * probability_4));
            sample_0.radiance = _S237;
            shadow_1 = _S235;
        }
        else
        {
            var _S238 : vec3<f32> = sampleSphere(_S231.position, _S231.variance, start_2, _S209.value, _S210.value);
            sample_0.dir = _S238;
            var _S239 : f32 = sphereDensity(_S231.position, _S231.variance, start_2);
            var _S240 : f32 = probability_4 * _S239;
            sample_0.density = _S240;
            var _S241 : vec3<f32> = pointLightRadiance(_S231.color, _S231.intensity, _S231.variance);
            var _S242 : vec3<f32> = _S241 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S242;
            var _S243 : f32 = raySphere_0(_S231.position, _S231.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S244 : vec3<f32> = sample_0.dir * vec3<f32>(_S243);
            shadow_1 = _S244;
        }
    }
    else
    {
        var _S245 : u32 = _S229.y;
        var _S246 : u32 = ((instance_uint[(_S245) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S247 : u32 = _S246 + _S229.z;
        var _S248 : mat3x3<f32> = (worldTriangle((_S245), (_S247)));
        var _S249 : f32 = sqrt(_S209.value);
        var _S250 : vec2<f32> = vec2<f32>(_S249 * (1.0f - _S210.value), _S249 * _S210.value);
        var _S251 : vec3<f32> = (((_S248) * (vec3<f32>(1.0f - _S249, _S250))));
        if(sided_0)
        {
            var _S252 : f32 = (sign((dot(geometry_n_1, _S251 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S252);
            var _S253 : vec3<f32> = origin_4 + _S214 * lift_n_2;
            start_2 = _S253;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S254 : bool = !((dot(smooth_n_4, _S251 - origin_4)) > 0.0f);
            if(_S254)
            {
                return sample_0;
            }
            start_2 = _S215;
            lift_n_0 = smooth_n_4;
        }
        var _S255 : Surface = (surfaceAt((Hit_x24init_0(_S250, _S245, _S247, u32(0), 0.0f)), (_S251), (_S210.state)));
        sample_0.random_state = _S255.random_state;
        var _S256 : vec3<f32> = _S251 - start_2;
        var _S257 : vec3<f32> = (normalize((_S256)));
        sample_0.dir = _S257;
        var _S258 : f32 = solidAngle(probability_4, cross(_S248[i32(1)] - _S248[i32(0)], _S248[i32(2)] - _S248[i32(0)]), _S256);
        sample_0.density = _S258;
        var _S259 : vec3<f32> = emitted_0(_S255.material.emissive, sample_0.dir, _S255.smooth_n);
        var _S260 : vec3<f32> = select(_S259, _S211, _S255.skip);
        var _S261 : vec3<f32> = _S260 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S261;
        shadow_1 = _S256;
    }
    var _S262 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S263 : vec3<f32> = sample_0.radiance * _S262;
    var _S264 : bool = (all((_S262 == _S211)));
    var _S265 : vec3<f32> = select(_S263, _S211, _S264);
    sample_0.radiance = _S265;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S266 : AnisotropicFrame;
    _S266.tangent = tangent_1;
    _S266.alphas = alphas_0;
    return _S266;
}

fn anisotropicFrame( material_8 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S267 : f32 = material_8.roughness;
    var _S268 : f32 = _S267 * _S267;
    var _S269 : bool = (material_8.anisotropy) == 0.0f;
    var _S270 : bool;
    if(_S269)
    {
        _S270 = true;
    }
    else
    {
        _S270 = !(_S268 > 0.0f);
    }
    if(_S270)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S271 : vec3<f32> = material_8.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_8.tangent));
    var _S272 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S273 : bool = (dot(_S271, _S271)) > 0.0f;
    var _S274 : vec3<f32> = select(_S272, _S271, _S273);
    var _S275 : vec3<f32> = (normalize((_S274)));
    var _S276 : f32 = 6.28318548202514648f * material_8.anisotropic_rotation;
    var _S277 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_8.anisotropy));
    var _S278 : f32 = 1.0f / _S277;
    var _S279 : bool = (material_8.anisotropy) < 0.0f;
    var _S280 : f32 = select(_S277, _S278, _S279);
    return AnisotropicFrame_x24init_0(_S275 * vec3<f32>(cos(_S276)) + cross(n_i_0, _S275) * vec3<f32>(sin(_S276)), vec2<f32>(_S268 / _S280, _S268 * _S280));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S281 : SheenProfile;
    _S281.on = on_0;
    _S281.albedo = albedo_1;
    return _S281;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_9 : Material) -> SheenProfile
{
    var _S282 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S283 : f32 = rgb_to_greyscale(material_9.sheen);
    var _S284 : bool = _S283 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S284)
    {
        var _S285 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S286 : u32 = min(u32(_S285), u32(22));
        var _S287 : f32 = sqrt(0.05000000074505806f);
        var _S288 : f32 = sqrt(0.00999999977648258f);
        var _S289 : bool = (material_9.velvet) > 0.0f;
        var _S290 : f32 = select(_S287, _S288, _S289);
        var _S291 : f32 = (clamp(sqrt(max(material_9.sheen_roughness, 0.0f)), _S290, 1.0f) - _S290) / (1.0f - _S290) * 23.0f;
        var _S292 : u32 = min(u32(_S291), u32(22));
        var _S293 : u32 = _S286 * u32(24) + _S292;
        var _S294 : f32 = _S285 - f32(_S286);
        var _S295 : f32 = _S291 - f32(_S292);
        if(_S289)
        {
            var _S296 : u32 = _S293 + u32(24);
            var _S297 : f32 = VELVET_ALBEDO_0[_S293] + (VELVET_ALBEDO_0[_S296] - VELVET_ALBEDO_0[_S293]) * _S294;
            var _S298 : u32 = _S293 + u32(1);
            var _S299 : f32 = VELVET_ALBEDO_0[_S298] + (VELVET_ALBEDO_0[_S296 + u32(1)] - VELVET_ALBEDO_0[_S298]) * _S294;
            var _S300 : SheenProfile = SheenProfile_x24init_0(true, _S297 + (_S299 - _S297) * _S295);
            profile_0 = _S300;
        }
        else
        {
            var _S301 : u32 = _S293 + u32(24);
            var _S302 : f32 = SHEEN_ALBEDO_0[_S293] + (SHEEN_ALBEDO_0[_S301] - SHEEN_ALBEDO_0[_S293]) * _S294;
            var _S303 : u32 = _S293 + u32(1);
            var _S304 : f32 = SHEEN_ALBEDO_0[_S303] + (SHEEN_ALBEDO_0[_S301 + u32(1)] - SHEEN_ALBEDO_0[_S303]) * _S294;
            var _S305 : SheenProfile = SheenProfile_x24init_0(true, exp(_S302 + (_S304 - _S302) * _S295));
            profile_0 = _S305;
        }
    }
    else
    {
        profile_0 = _S282;
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
    var _S306 : Weights;
    _S306.v_dot_h = v_dot_h_0;
    _S306.refracted = refracted_0;
    _S306.F = F_0;
    _S306.reflect_weight = reflect_weight_0;
    _S306.diffuse_weight = diffuse_weight_0;
    _S306.refract_weight = refract_weight_0;
    _S306.p_diffuse = p_diffuse_0;
    _S306.p_reflect = p_reflect_0;
    _S306.p_refract = p_refract_0;
    _S306.p_sheen_velvet = p_sheen_velvet_0;
    _S306.p_toon = p_toon_0;
    _S306.sheen = sheen_1;
    _S306.toon = toon_0;
    return _S306;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_0 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_0), dot(w_1, cross(n_4, t_0)), dot(w_1, n_4));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S307 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S308 : f32 = _S307.x;
    var _S309 : f32 = _S307.y;
    var _S310 : f32 = _S308 * _S308 + _S309 * _S309;
    const _S311 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S312 : vec3<f32> = vec3<f32>(- _S309, _S308, 0.0f);
    var _S313 : f32 = (inverseSqrt((_S310)));
    var _S314 : vec3<f32> = _S312 * vec3<f32>(_S313);
    var _S315 : bool = _S310 > 0.0f;
    var _S316 : vec3<f32> = select(_S311, _S314, _S315);
    var _S317 : vec3<f32> = cross(_S307, _S316);
    var _S318 : f32 = sqrt(U1_0);
    var _S319 : f32 = 6.28318548202514648f * U2_0;
    var _S320 : f32 = _S318 * cos(_S319);
    var t2_0 : f32 = _S318 * sin(_S319);
    var _S321 : f32 = 0.5f * (1.0f + _S307.z);
    var t2_1 : f32 = (1.0f - _S321) * sqrt(max(0.0f, 1.0f - _S320 * _S320)) + _S321 * t2_0;
    var _S322 : vec3<f32> = vec3<f32>(_S320) * _S316 + vec3<f32>(t2_1) * _S317;
    var _S323 : f32 = ((_S320));
    var _S324 : f32 = ((_S320));
    var _S325 : vec3<f32> = _S322 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S323 * _S324 - t2_1 * t2_1))) * _S307;
    var _S326 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S325.x, alpha_0 * _S325.y, max(0.0f, _S325.z)))));
    return _S326;
}

fn worldToTangent( v_2 : vec3<f32>,  n_5 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S327 : bool = (abs(dot(n_5, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S327)
    {
        const _S328 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S328;
    }
    else
    {
        a_4 = a_3;
    }
    var _S329 : vec3<f32> = (normalize((cross(n_5, a_4))));
    var _S330 : vec3<f32> = cross(n_5, _S329);
    return vec3<f32>(dot(v_2, _S329), dot(v_2, n_5), dot(v_2, _S330));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S331 : Random = pcg((*random_state_3));
    var _S332 : Random = pcg(_S331.state);
    (*random_state_3) = _S332.state;
    var _S333 : f32 = frame_0.alphas.x;
    var _S334 : bool = _S333 > 0.0f;
    if(_S334)
    {
        var _S335 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S336 : f32 = frame_0.alphas.y;
        var _S337 : vec3<f32> = (normalize((vec3<f32>(_S333 * _S335.x, _S336 * _S335.y, _S335.z))));
        var _S338 : vec3<f32> = sampleGGXVNDF(_S337, 1.0f, _S331.value, _S332.value);
        var _S339 : vec3<f32> = (normalize((vec3<f32>(_S333 * _S338.x, _S336 * _S338.y, _S338.z))));
        return vec3<f32>(_S339.x) * frame_0.tangent + vec3<f32>(_S339.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S339.z) * n_i_2;
    }
    var _S340 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S341 : vec3<f32> = sampleGGXVNDF(_S340.xzy, alpha_1, _S331.value, _S332.value);
    var _S342 : vec3<f32> = _S341.xzy;
    var _S343 : vec3<f32> = tangentToWorld(_S342, n_i_2);
    return _S343;
}

fn sampledHalf( v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_2 : f32,  frame_1 : AnisotropicFrame,  random_state_4 : u32) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S344 : vec3<f32> = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &(state_2));
    return _S344;
}

fn refractedHalf( in_dir_0 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S345 : vec3<f32> = ((-(in_dir_0)));
    var _S346 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S345 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S347 : vec3<f32> = (normalize((_S346)));
    var _S348 : f32 = (sign((dot(n_6, _S345))));
    var _S349 : f32 = (sign((dot(_S346, n_6 * vec3<f32>(_S348)))));
    return _S347 * vec3<f32>(_S349);
}

fn reflectedHalf( in_dir_1 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S350 : vec3<f32> = ((-(in_dir_1)));
    var _S351 : vec3<f32> = (normalize((_S350 + out_dir_1)));
    return _S351;
}

fn lobeWeights( in_dir_2 : vec3<f32>,  v_5 : vec3<f32>,  n_i_4 : vec3<f32>,  ggx_n_0 : vec3<f32>,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile,  material_10 : Material,  eta_i_3 : f32,  eta_o_3 : f32) -> Weights
{
    var _S352 : f32 = dot(ggx_n_0, v_5);
    var _S353 : f32 = eta_i_3 / eta_o_3;
    var _S354 : vec3<f32> = (normalize((refract(in_dir_2, ggx_n_0, _S353))));
    var _S355 : f32 = min(sqrt(material_10.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S356 : f32 = _S355 * _S355;
    var _S357 : f32 = (1.0f + _S355) / (1.0f - _S355);
    var _S358 : f32 = abs(_S352);
    var _S359 : bool = eta_i_3 > eta_o_3;
    var _S360 : f32 = select(1.0f, _S357, _S359);
    var _S361 : f32 = select(_S357, 1.0f, _S359);
    var _S362 : f32 = fresnel(_S358, _S360, _S361);
    var _S363 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S352 * _S352)) >= (eta_o_3 * eta_o_3);
    var _S364 : vec3<f32> = material_10.specular_tint * vec3<f32>(_S356);
    var _S365 : vec3<f32> = vec3<f32>(1.0f);
    var _S366 : vec3<f32> = _S364 + (_S365 - _S364) * vec3<f32>((_S362 - _S356)) / vec3<f32>((1.0f - _S356));
    var _S367 : vec3<f32> = vec3<f32>(1.0f);
    var _S368 : vec3<f32> = select(_S366, _S367, _S363);
    var _S369 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S370 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S371 : vec3<f32> = _S365 - material_10.sheen * vec3<f32>(_S370);
        var _S372 : f32 = rgb_to_greyscale(material_10.sheen);
        var _S373 : f32 = _S372 * _S370;
        var _S374 : vec3<f32> = material_10.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S371;
        sheen_component_0 = _S373;
        sheen_2 = _S374;
    }
    else
    {
        scale_0 = _S367;
        sheen_component_0 = 0.0f;
        sheen_2 = _S369;
    }
    var _S375 : bool = (material_10.metallic) > 0.0f;
    var rebounce_0 : vec3<f32>;
    if(_S375)
    {
        var _S376 : f32 = frame_2.alphas.x;
        var _S377 : f32 = sqrt(min(_S376, frame_2.alphas.y));
        var _S378 : bool = _S376 > 0.0f;
        var _S379 : f32 = select(material_10.roughness, _S377, _S378);
        var _S380 : f32 = _S379 * _S379;
        var _S381 : f32 = pow(_S380, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S380) / (1.0f + 1.28094995021820068f * _S380);
        var _S382 : bool = _S380 > 0.0f;
        var _S383 : f32 = select(0.0f, _S381, _S382);
        var _S384 : f32 = clamp(dot(n_i_4, v_5), 0.0f, 1.0f);
        var _S385 : f32 = _S380 * _S379;
        var _S386 : f32 = min(1.00064504146575928f - _S379 * (0.00375499995425344f + _S384 * (-0.04133399948477745f + _S384 * (-0.90938502550125122f + _S384 * 0.35275399684906006f))) - _S380 * (0.27602800726890564f + _S384 * (1.27023398876190186f + _S384 * 0.04740000143647194f)) - _S385 * (0.31452900171279907f - _S384 * 0.34830701351165771f) + _S385 * _S379 * 0.27229699492454529f, 1.0f);
        var _S387 : vec3<f32> = min(_S365 / (_S365 - material_10.albedo * vec3<f32>(_S383)), vec3<f32>((1.0f / max(_S386, 0.0000152587890625f))));
        rebounce_0 = _S387;
    }
    else
    {
        rebounce_0 = _S367;
    }
    var _S388 : vec3<f32> = (mix((_S368), (material_10.albedo * rebounce_0), (material_10.metallic)));
    var F_1 : vec3<f32> = _S388 * scale_0;
    var _S389 : f32 = rgb_to_greyscale(F_1);
    var _S390 : f32 = 1.0f - material_10.metallic;
    var _S391 : vec3<f32> = _S365 - _S368;
    var _S392 : vec3<f32> = vec3<f32>(((1.0f - material_10.transmission) * _S390)) * _S391 * scale_0;
    var _S393 : vec3<f32> = vec3<f32>((material_10.transmission * _S390)) * _S391 * scale_0;
    var _S394 : f32 = max(_S389, 0.0f);
    var _S395 : f32 = rgb_to_greyscale(_S392);
    var _S396 : f32 = max(_S395, 0.0f);
    var _S397 : f32 = rgb_to_greyscale(_S393);
    var _S398 : f32 = (sign((length(_S354))));
    var _S399 : f32 = max(_S397 * _S398, 0.0f);
    var _S400 : f32 = _S394 + _S396 + _S399;
    var _S401 : f32 = min(sheen_component_0, 1.0f);
    var _S402 : bool = sheen_component_0 > 0.0f;
    var _S403 : bool;
    if(_S402)
    {
        _S403 = !(_S400 > 0.0f);
    }
    else
    {
        _S403 = false;
    }
    var _S404 : f32 = select(_S401, 1.0f, _S403);
    var _S405 : f32 = (1.0f - _S404) / max(_S400, 0.0000152587890625f);
    var _S406 : f32 = _S396 * _S405;
    var _S407 : f32 = _S394 * _S405;
    var _S408 : f32 = _S399 * _S405;
    return Weights_x24init_0(_S352, _S354, F_1, 1.0f, _S392, _S393, _S406, _S407, _S408, _S404, 0.0f * _S405, sheen_2, _S369);
}

fn translucentShare( material_11 : Material) -> f32
{
    var _S409 : f32 = rgb_to_greyscale(material_11.translucent);
    var _S410 : f32 = rgb_to_greyscale(material_11.albedo);
    var _S411 : f32 = _S409 / (_S410 + _S409);
    var _S412 : bool = _S409 > 0.0f;
    var _S413 : f32 = select(0.0f, _S411, _S412);
    return _S413;
}

fn diffusePDF( n_i_dot_l_0 : f32,  n_i_dot_v_0 : f32,  material_12 : Material,  w_2 : Weights) -> f32
{
    var _S414 : f32 = translucentShare(material_12);
    var _S415 : f32 = w_2.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S416 : f32 = w_2.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S417 : f32 = 1.0f - _S414;
    var _S418 : bool = n_i_dot_l_0 < 0.0f;
    var _S419 : f32 = select(_S417, _S414, _S418);
    var _S420 : f32 = _S416 * _S419;
    var _S421 : bool = _S414 > 0.0f;
    var _S422 : f32 = select(_S415, _S420, _S421);
    var _S423 : bool = n_i_dot_v_0 > 0.0f;
    var _S424 : f32 = select(0.0f, _S422, _S423);
    return _S424;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_5 : vec3<f32>,  material_13 : Material,  w_3 : Weights) -> vec3<f32>
{
    var _S425 : f32 = translucentShare(material_13);
    var _S426 : bool = (dot(n_i_5, l_0)) < 0.0f;
    var _S427 : vec3<f32> = select(material_13.albedo, material_13.translucent, _S426);
    var _S428 : f32 = 1.0f - _S425;
    var _S429 : f32 = select(_S428, _S425, _S426);
    var _S430 : vec3<f32> = _S427 / vec3<f32>(_S429);
    var _S431 : bool = _S425 > 0.0f;
    var _S432 : vec3<f32> = select(material_13.albedo, _S430, _S431);
    return w_3.diffuse_weight * _S432 / vec3<f32>(w_3.p_diffuse);
}

fn smithG1( alpha_3 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S433 : f32 = alpha_3 * alpha_3;
    var _S434 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S433 + (1.0f - _S433) * n_dot_x_0 * n_dot_x_0));
    var _S435 : bool = alpha_3 > 0.0f;
    var _S436 : f32 = select(1.0f, _S434, _S435);
    return _S436;
}

fn trowbridgeReitz( alpha_4 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S437 : f32 = alpha_4 * alpha_4;
    var _S438 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S437 * n_dot_h_0 * n_dot_h_0;
    return _S437 / max(3.14159274101257324f * _S438 * _S438, 1.17549435082228751e-38f);
}

fn anisotropicG1( w_4 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S439 : f32 = max(w_4.z, 0.0f);
    return 2.0f * _S439 / (_S439 + length(vec3<f32>(alphas_1.x * w_4.x, alphas_1.y * w_4.y, _S439)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S440 : f32 = alphas_2.x;
    var _S441 : f32 = h_0.x / _S440;
    var _S442 : f32 = alphas_2.y;
    var _S443 : f32 = h_0.y / _S442;
    var _S444 : f32 = h_0.z;
    var _S445 : f32 = _S441 * _S441 + _S443 * _S443 + _S444 * _S444;
    return 1.0f / max(3.14159274101257324f * _S440 * _S442 * _S445 * _S445, 1.17549435082228751e-38f);
}

fn vndfPDF( v_6 : vec3<f32>,  h_1 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_1 : f32,  alpha_5 : f32,  frame_3 : AnisotropicFrame,  v_dot_h_1 : f32) -> f32
{
    var _S446 : f32 = dot(n_i_6, h_1);
    var _S447 : f32 = smithG1(alpha_5, n_i_dot_v_1);
    var _S448 : f32 = _S447 * v_dot_h_1;
    var _S449 : f32 = trowbridgeReitz(alpha_5, _S446);
    var _S450 : f32 = _S448 * _S449 / n_i_dot_v_1;
    var _S451 : bool = alpha_5 > 0.0f;
    var _S452 : bool;
    if(_S451)
    {
        _S452 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S452 = false;
    }
    if(_S452)
    {
        _S452 = _S446 > 0.0f;
    }
    else
    {
        _S452 = false;
    }
    if(_S452)
    {
        _S452 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S452 = false;
    }
    var _S453 : f32 = select(0.0f, _S450, _S452);
    var _S454 : bool = (frame_3.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S454)
    {
        var _S455 : vec3<f32> = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        var _S456 : f32 = anisotropicG1(_S455, frame_3.alphas);
        var _S457 : vec3<f32> = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        var _S458 : f32 = anisotropicD(_S457, frame_3.alphas);
        var _S459 : f32 = _S456 * _S458;
        var _S460 : f32 = _S459 * v_dot_h_1 / n_i_dot_v_1;
        var _S461 : bool = v_dot_h_1 > 0.0f;
        if(_S461)
        {
            _S452 = _S446 > 0.0f;
        }
        else
        {
            _S452 = false;
        }
        if(_S452)
        {
            _S452 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S452 = false;
        }
        var _S462 : f32 = select(0.0f, _S460, _S452);
        pdf_h_0 = _S462;
    }
    else
    {
        pdf_h_0 = _S453;
    }
    return pdf_h_0;
}

fn refractPDF( l_dot_h_0 : f32,  pdf_h_1 : f32,  w_5 : Weights,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S463 : f32 = eta_i_4 * w_5.v_dot_h + eta_o_4 * l_dot_h_0;
    var _S464 : f32 = w_5.p_refract * pdf_h_1 * eta_o_4 * eta_o_4 * abs(l_dot_h_0) / (_S463 * _S463);
    var _S465 : bool = eta_i_4 != eta_o_4;
    var _S466 : bool;
    if(_S465)
    {
        _S466 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S466 = false;
    }
    var _S467 : f32 = select(0.0f, _S464, _S466);
    return _S467;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_6 : f32,  frame_4 : AnisotropicFrame,  material_14 : Material,  w_6 : Weights) -> vec3<f32>
{
    var _S468 : f32 = - dot(n_i_7, l_1);
    var _S469 : f32 = smithG1(alpha_6, max(_S468, 0.0f));
    var _S470 : bool = (frame_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S470)
    {
        var _S471 : vec3<f32> = ((-(n_i_7)));
        var _S472 : vec3<f32> = anisotropicLocal(l_1, frame_4.tangent, _S471);
        var _S473 : f32 = anisotropicG1(_S472, frame_4.alphas);
        G1_l_0 = _S473;
    }
    else
    {
        G1_l_0 = _S469;
    }
    var _S474 : bool = (material_14.ior) == 1.0f;
    var _S475 : f32 = select(G1_l_0, 1.0f, _S474);
    return w_6.refract_weight * vec3<f32>(_S475) * material_14.albedo / vec3<f32>(w_6.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_1 : f32,  n_i_dot_v_2 : f32,  w_7 : Weights) -> f32
{
    var _S476 : f32 = w_7.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S477 : bool = n_i_dot_l_1 > 0.0f;
    var _S478 : bool;
    if(_S477)
    {
        _S478 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S478 = false;
    }
    var _S479 : f32 = select(0.0f, _S476, _S478);
    return _S479;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  v_7 : vec3<f32>,  n_i_8 : vec3<f32>,  material_15 : Material,  w_8 : Weights) -> vec3<f32>
{
    var _S480 : vec3<f32> = (normalize((l_2 + v_7)));
    var _S481 : f32 = dot(n_i_8, _S480);
    var _S482 : f32 = max(dot(n_i_8, l_2), 0.0f);
    var _S483 : f32 = max(dot(n_i_8, v_7), 0.0f);
    var _S484 : f32 = 1.0f / max(material_15.sheen_roughness, 0.05000000074505806f);
    var _S485 : f32 = 1.0f - _S481 * _S481;
    var _S486 : f32 = (2.0f + _S484) * pow(max(_S485, 0.0f), 0.5f * _S484) * 0.5f * 0.31830987334251404f / max(4.0f * (_S482 + _S483 - _S482 * _S483), 0.0000152587890625f);
    var _S487 : bool = (material_15.velvet) > 0.0f;
    var f_3 : f32;
    if(_S487)
    {
        var _S488 : f32 = max(material_15.sheen_roughness, 0.00999999977648258f);
        var _S489 : f32 = _S488 * _S488;
        var _S490 : f32 = max(_S485, 0.0000152587890625f);
        var _S491 : f32 = exp(- _S481 * _S481 / (_S490 * _S489)) / (3.14159274101257324f * _S489 * _S490 * _S490) * min(1.0f, 2.0f * _S481 * min(_S482, _S483) / max(abs(dot(_S480, v_7)), 0.0000152587890625f)) / max(4.0f * _S482 * _S483, 0.0000152587890625f);
        f_3 = _S491;
    }
    else
    {
        f_3 = _S486;
    }
    return w_8.sheen * vec3<f32>((f_3 * _S482 * 2.0f * 3.14159274101257324f / w_8.p_sheen_velvet));
}

fn reflectPDF( pdf_h_2 : f32,  w_9 : Weights) -> f32
{
    var _S492 : f32 = w_9.p_reflect * pdf_h_2 / (4.0f * w_9.v_dot_h);
    var _S493 : bool = pdf_h_2 > 0.0f;
    var _S494 : f32 = select(0.0f, _S492, _S493);
    return _S494;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_9 : vec3<f32>,  alpha_7 : f32,  frame_5 : AnisotropicFrame,  w_10 : Weights) -> vec3<f32>
{
    var _S495 : f32 = dot(n_i_9, l_3);
    var _S496 : f32 = smithG1(alpha_7, max(_S495, 0.0f));
    var _S497 : bool = (frame_5.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S497)
    {
        var _S498 : vec3<f32> = anisotropicLocal(l_3, frame_5.tangent, n_i_9);
        var _S499 : f32 = anisotropicG1(_S498, frame_5.alphas);
        G1_l_1 = _S499;
    }
    else
    {
        G1_l_1 = _S496;
    }
    return vec3<f32>((w_10.reflect_weight * G1_l_1)) * w_10.F / vec3<f32>(w_10.p_reflect);
}

fn BSDF( in_dir_3 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_16 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S500 : vec3<f32> = ((-(in_dir_3)));
    var _S501 : f32 = dot(n_7, _S500);
    var _S502 : f32 = (sign((_S501)));
    var _S503 : vec3<f32> = n_7 * vec3<f32>(_S502);
    var _S504 : f32 = dot(_S503, out_dir_2);
    var _S505 : f32 = material_16.roughness;
    var _S506 : f32 = _S505 * _S505;
    var _S507 : AnisotropicFrame = anisotropicFrame(material_16, _S503);
    var _S508 : SheenProfile = sheenProfile(_S500, _S503, material_16);
    var _S509 : f32 = rgb_to_greyscale(material_16.translucent);
    var _S510 : bool = _S509 > 0.0f;
    var _S511 : bool = (dot(n_7, out_dir_2) * _S501) < 0.0f;
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
        var _S512 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S512;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S513 : vec3<f32> = vec3<f32>(0.0f);
    var _S514 : Weights = Weights_x24init_0(0.0f, _S513, _S513, 0.0f, _S513, _S513, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S513, _S513);
    var half_of_0 : u32 = u32(4294967295);
    var w_11 : Weights = _S514;
    var ggx_n_2 : vec3<f32> = _S513;
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
        var _S515 : u32;
        if(i_0 == u32(3))
        {
            _S515 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S515 = u32(6);
            }
            else
            {
                _S515 = i_0;
            }
        }
        var _S516 : bool = _S515 == u32(0);
        var _S517 : bool;
        if(_S516)
        {
            _S517 = _S510;
        }
        else
        {
            _S517 = false;
        }
        var _S518 : bool;
        if(_S517)
        {
            _S518 = _S511;
        }
        else
        {
            _S518 = _S515 == u32(1);
        }
        var _S519 : bool = _S518 != refracted_1;
        if(_S519)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S520 : u32;
        if(_S515 == u32(6))
        {
            _S520 = u32(0);
        }
        else
        {
            if(_S515 == u32(4))
            {
                _S520 = u32(2);
            }
            else
            {
                _S520 = _S515;
            }
        }
        var _S521 : bool = _S520 != half_of_0;
        var half_of_1 : u32;
        var w_12 : Weights;
        if(_S521)
        {
            var _S522 : bool = _S520 == u32(0);
            if(_S522)
            {
                var _S523 : vec3<f32> = sampledHalf(_S500, _S503, _S506, _S507, random_state_5);
                ggx_n_1 = _S523;
            }
            else
            {
                var _S524 : bool = _S520 == u32(1);
                if(_S524)
                {
                    var _S525 : vec3<f32> = refractedHalf(in_dir_3, out_dir_2, n_7, eta_i_5, eta_o_5);
                    ggx_n_1 = _S525;
                }
                else
                {
                    var _S526 : vec3<f32> = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S526;
                }
            }
            var _S527 : Weights = lobeWeights(in_dir_3, _S500, _S503, ggx_n_1, _S507, _S508, material_16, eta_i_5, eta_o_5);
            w_12 = _S527;
            half_of_1 = _S520;
        }
        else
        {
            w_12 = w_11;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S515)
        {
        case u32(0):
            {
                var _S528 : f32 = diffusePDF(_S504, abs(_S501), material_16, w_12);
                (*pdfs_0)[i32(0)] = _S528;
                var _S529 : vec3<f32> = diffuseBSDF(out_dir_2, _S503, material_16, w_12);
                (*throughputs_0)[i32(0)] = _S529;
            }
        case u32(1):
            {
                var _S530 : f32 = dot(out_dir_2, ggx_n_1);
                var _S531 : f32 = vndfPDF(_S500, ggx_n_1, _S503, abs(_S501), _S506, _S507, w_12.v_dot_h);
                var _S532 : f32 = refractPDF(_S530, _S531, w_12, eta_i_5, eta_o_5);
                (*pdfs_0)[i32(1)] = _S532;
                var _S533 : vec3<f32> = refractBSDF(out_dir_2, _S503, _S506, _S507, material_16, w_12);
                (*throughputs_0)[i32(1)] = _S533;
            }
        case u32(4):
            {
                var _S534 : f32 = sheenVelvetPDF(_S504, abs(_S501), w_12);
                (*pdfs_0)[i32(3)] = _S534;
                var _S535 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S500, _S503, material_16, w_12);
                (*throughputs_0)[i32(3)] = _S535;
            }
        default :
            {
                var _S536 : f32 = vndfPDF(_S500, ggx_n_1, _S503, abs(_S501), _S506, _S507, w_12.v_dot_h);
                var _S537 : f32 = reflectPDF(_S536, w_12);
                (*pdfs_0)[i32(2)] = _S537;
                var _S538 : vec3<f32> = reflectBSDF(out_dir_2, _S503, _S506, _S507, w_12);
                (*throughputs_0)[i32(2)] = _S538;
            }
        }
        half_of_0 = half_of_1;
        w_11 = w_12;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S513;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S539 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S539)
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
    var _S540 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_4)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S541 : vec3<f32> = BSDF(in_dir_4, light_0.dir, smooth_n_5, material_17, eta_i_6, eta_o_6, _S540, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S542 : bool = !competing_0;
    var _S543 : bool;
    if(_S542)
    {
        _S543 = true;
    }
    else
    {
        _S543 = (light_0.density) == 0.0f;
    }
    if(_S543)
    {
        return _S541 * light_0.radiance;
    }
    var _S544 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S544;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S545 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S545)
        {
            var _S546 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S546 * _S546)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn skyFrame_0( dir_4 : vec3<f32>) -> vec3<f32>
{
    var _S547 : vec3<f32> = vec3<f32>(- dir_4.x, dir_4.z, dir_4.y);
    var _S548 : bool = ((false));
    var _S549 : vec3<f32> = select(dir_4, _S547, _S548);
    return _S549;
}

fn environmentPdf_0( dir_5 : vec3<f32>) -> f32
{
    var _S550 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S551 : vec2<u32> = _S550 - vec2<u32>(u32(1), u32(0));
    var _S552 : vec3<f32> = skyFrame_0(dir_5);
    var _S553 : vec2<f32> = vec2<f32>(atan2(- _S552.z, - _S552.x) / 6.28318548202514648f + 0.5f, acos(clamp(_S552.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S554 : vec2<u32> = min(vec2<u32>(_S553 * vec2<f32>(_S551)), _S551 - vec2<u32>(u32(1)));
    var _S555 : vec4<f32> = (textureLoad(environment_cdf, (_S554), 0));
    var _S556 : f32 = _S555.y;
    var _S557 : u32 = _S551.x;
    var _S558 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S557, _S554.y)), 0));
    var _S559 : f32 = _S556 * _S558.y;
    return _S559 * f32(_S557 * _S551.y) / (19.73921012878417969f * length(_S552.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_6 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_6, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_5 : vec3<f32>,  dir_7 : vec3<f32>,  surface_1 : Surface,  material_18 : Material,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_2 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S560 : bool = wrongSide_0(is_inside_1, false, dir_7, surface_1.geometry_n);
    var _S561 : vec3<f32> = BSDF(in_dir_5, dir_7, surface_1.smooth_n, material_18, eta_0.x, eta_0.y, _S560, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S562 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_5 : vec3<f32> = _S562;
    loop
    {
        if(i_6 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S563 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S563)
        {
            var _S564 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S564;
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
    var _S565 : vec3<f32> = skyLobes_0(in_dir_6, dir_8, surface_2, material_19, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S565;
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
    var _S566 : u32 = count_0 - u32(1);
    var low_1 : u32 = u32(0);
    var high_1 : u32 = _S566;
    loop
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        var _S567 : u32 = (low_1 + high_1) / u32(2);
        var _S568 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S567)), 0));
        var _S569 : bool = (_S568.x) > u_1;
        if(_S569)
        {
            high_1 = _S567;
        }
        else
        {
            var _S570 : u32 = _S567 + u32(1);
            low_1 = _S570;
        }
    }
    return low_1;
}

fn SkySample_x24init_0( dir_9 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S571 : SkySample;
    _S571.dir = dir_9;
    _S571.radiance = radiance_2;
    _S571.color = color_2;
    _S571.random_state = random_state_9;
    return _S571;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S572 : bool = wrongSide_0(is_inside_3, false, dir_10, surface_3.geometry_n);
    var _S573 : bool = is_inside_3 != _S572;
    var _S574 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S575 : vec3<f32> = select(surface_3.smooth_n, _S574, _S573);
    var _S576 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S575, dir_10);
    var _S577 : vec3<f32> = (env_map_sample((dir_10)));
    var _S578 : vec3<f32> = (shadowTransmittance((_S576), (4.294967296e+09f)));
    return _S577 * _S578;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  wavelength_7 : f32,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S579 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S580 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S581 : vec2<u32> = _S579 - _S580;
    var _S582 : Random = pcg(init_random_state_1);
    var _S583 : Random = pcg(_S582.state);
    var _S584 : Random = pcg(_S583.state);
    var _S585 : Random = pcg(_S584.state);
    var _S586 : u32 = _S581.x;
    var _S587 : u32 = searchCDF_0(vec2<u32>(_S586, u32(0)), vec2<u32>(u32(0), u32(1)), _S581.y, _S582.value);
    var _S588 : u32 = searchCDF_0(vec2<u32>(u32(0), _S587), _S580, _S586, _S583.value);
    var _S589 : vec2<f32> = (vec2<f32>(f32(_S588), f32(_S587)) + vec2<f32>(_S584.value, _S585.value)) / vec2<f32>(_S581) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S590 : f32 = _S589.y;
    var _S591 : f32 = sin(_S590);
    var _S592 : f32 = _S589.x;
    var _S593 : vec3<f32> = skyFrame_0(vec3<f32>(_S591 * cos(_S592), cos(_S590), _S591 * sin(_S592)));
    var _S594 : f32 = environmentPdf_0(_S593);
    var _S595 : Material = pathMaterial(surface_4.material, wavelength_7);
    var _S596 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S593, surface_4, _S595, eta_2, is_inside_4, _S594, lobe_state_0);
    var _S597 : bool = !(_S594 > 0.0f);
    var _S598 : bool;
    if(_S597)
    {
        _S598 = true;
    }
    else
    {
        _S598 = (all((_S596 == vec3<f32>(0.0f))));
    }
    if(_S598)
    {
        var _S599 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S593, _S599, _S599, _S585.state);
    }
    var _S600 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S593);
    return SkySample_x24init_0(_S593, _S600, _S596 * _S600, _S585.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S601 : vec3<f32> = a_5 / b_1;
    var _S602 : vec3<f32> = vec3<f32>(0.0f);
    var _S603 : vec3<bool> = b_1 == _S602;
    var _S604 : vec3<f32> = select(_S601, _S602, _S603);
    return _S604;
}

fn withEnd( r_1 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_7 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_1;
    var _S605 : u32 = (insertBits((r_1.path), (end_0), (u32(0)), (u32(5))));
    var _S606 : u32 = (insertBits((_S605), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S606;
    candidate_0.f = f_7;
    return candidate_0;
}

fn resamplingTarget( f_8 : vec3<f32>) -> f32
{
    var _S607 : f32 = rgb_to_greyscale(abs(f_8));
    return _S607;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_1 : vec3<f32>)
{
    var _S608 : f32 = resamplingTarget(weight_1);
    var _S609 : bool = _S608 > 0.0f;
    var _S610 : bool;
    if(_S609)
    {
        _S610 = _S608 < 3.00000000549775576e+38f;
    }
    else
    {
        _S610 = false;
    }
    var _S611 : bool = !_S610;
    if(_S611)
    {
        return;
    }
    var _S612 : f32 = (*sel_0).w_sum + _S608;
    (*sel_0).w_sum = _S612;
    var _S613 : vec3<f32> = (*sel_0).color + weight_1;
    (*sel_0).color = _S613;
    var _S614 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S614.state;
    var _S615 : bool = (_S614.value * (*sel_0).w_sum) <= _S608;
    if(_S615)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S616 : vec2<u32> = (uniforms_uint.environment_map_size);
    return (all((_S616 > vec2<u32>(u32(1)))));
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
    var _S617 : SampleBSDF;
    _S617.unit_direction = unit_direction_1;
    _S617.throughput = throughput_0;
    _S617.random_state = random_state_10;
    _S617.refracted = refracted_3;
    _S617.lobe = lobe_1;
    _S617.pdf = pdf_4;
    return _S617;
}

fn sheenVelvetSample( v_8 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_3 : f32,  material_20 : Material,  w_13 : Weights,  random_state_11 : u32) -> SampleBSDF
{
    var _S618 : vec3<f32> = vec3<f32>(1.0f);
    var _S619 : SampleBSDF = SampleBSDF_x24init_0(_S618, _S618, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S619;
    var _S620 : Random = pcg(random_state_11);
    var _S621 : Random = pcg(_S620.state);
    sample_1.random_state = _S621.state;
    var _S622 : f32 = _S620.value;
    var _S623 : f32 = sqrt(max(0.0f, 1.0f - _S622 * _S622));
    var _S624 : f32 = 6.28318548202514648f * _S621.value;
    var _S625 : vec3<f32> = tangentToWorld(vec3<f32>(_S623 * cos(_S624), _S620.value, _S623 * sin(_S624)), n_i_10);
    sample_1.unit_direction = _S625;
    sample_1.lobe = u32(4);
    var _S626 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, v_8, n_i_10, material_20, w_13);
    sample_1.throughput = _S626;
    var _S627 : f32 = sheenVelvetPDF(_S620.value, n_i_dot_v_3, w_13);
    sample_1.pdf = _S627;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S628 : f32 = sqrt(random_1_0);
    var _S629 : f32 = 6.28318548202514648f * random_2_0;
    var _S630 : f32 = _S628 * cos(_S629);
    var _S631 : f32 = _S628 * sin(_S629);
    var _S632 : f32 = sqrt(max(0.0f, 1.0f - _S630 * _S630 - _S631 * _S631));
    return vec3<f32>(_S630, _S632, _S631);
}

fn diffuseSample( u_2 : f32,  n_i_11 : vec3<f32>,  n_i_dot_v_4 : f32,  material_21 : Material,  w_14 : Weights,  random_state_12 : u32) -> SampleBSDF
{
    var _S633 : vec3<f32> = vec3<f32>(1.0f);
    var _S634 : SampleBSDF = SampleBSDF_x24init_0(_S633, _S633, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S634;
    var _S635 : Random = pcg(random_state_12);
    var _S636 : Random = pcg(_S635.state);
    sample_2.random_state = _S636.state;
    var _S637 : vec3<f32> = sampleCosWeightedHemisphere(_S635.value, _S636.value);
    var _S638 : f32 = translucentShare(material_21);
    var _S639 : bool = u_2 < (w_14.p_diffuse * _S638);
    var _S640 : f32 = _S637.y;
    var _S641 : f32 = - _S640;
    var _S642 : f32 = select(_S640, _S641, _S639);
    var _S643 : vec3<f32> = tangentToWorld(vec3<f32>(_S637.x, _S642, _S637.z), n_i_11);
    sample_2.unit_direction = _S643;
    sample_2.refracted = _S639;
    sample_2.lobe = u32(0);
    var _S644 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_11, material_21, w_14);
    sample_2.throughput = _S644;
    var _S645 : f32 = diffusePDF(_S642, n_i_dot_v_4, material_21, w_14);
    sample_2.pdf = _S645;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_12 : vec3<f32>,  alpha_8 : f32,  frame_6 : AnisotropicFrame,  material_22 : Material,  w_15 : Weights,  pdf_h_3 : f32,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S646 : vec3<f32> = vec3<f32>(1.0f);
    var _S647 : SampleBSDF = SampleBSDF_x24init_0(_S646, _S646, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S647;
    sample_3.unit_direction = w_15.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S648 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_12, alpha_8, frame_6, material_22, w_15);
    sample_3.throughput = _S648;
    var _S649 : f32 = refractPDF(dot(sample_3.unit_direction, ggx_n_3), pdf_h_3, w_15, eta_i_7, eta_o_7);
    sample_3.pdf = _S649;
    return sample_3;
}

fn reflectSample( in_dir_7 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_13 : vec3<f32>,  alpha_9 : f32,  frame_7 : AnisotropicFrame,  w_16 : Weights,  pdf_h_4 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S650 : vec3<f32> = vec3<f32>(1.0f);
    var _S651 : SampleBSDF = SampleBSDF_x24init_0(_S650, _S650, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S651;
    var _S652 : vec3<f32> = (normalize((reflect(in_dir_7, ggx_n_4))));
    sample_4.unit_direction = _S652;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S653 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_13, alpha_9, frame_7, w_16);
    sample_4.throughput = _S653;
    var _S654 : f32 = reflectPDF(pdf_h_4, w_16);
    sample_4.pdf = _S654;
    return sample_4;
}

fn sampleBSDF( in_dir_8 : vec3<f32>,  n_8 : vec3<f32>,  material_23 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S655 : vec3<f32> = ((-(in_dir_8)));
    var _S656 : f32 = dot(n_8, _S655);
    var _S657 : f32 = (sign((_S656)));
    var n_i_14 : vec3<f32> = n_8 * vec3<f32>(_S657);
    var _S658 : f32 = abs(_S656);
    var _S659 : f32 = material_23.roughness;
    var _S660 : f32 = _S659 * _S659;
    var _S661 : AnisotropicFrame = anisotropicFrame(material_23, n_i_14);
    var _S662 : SheenProfile = sheenProfile(_S655, n_i_14, material_23);
    var _S663 : vec3<f32> = sampleHalfVector(_S655, n_i_14, _S660, _S661, &(random_state_15));
    var _S664 : Weights = lobeWeights(in_dir_8, _S655, n_i_14, _S663, _S661, _S662, material_23, eta_i_8, eta_o_8);
    var _S665 : Random = pcg(random_state_15);
    random_state_15 = _S665.state;
    var _S666 : bool = (_S665.value) < (_S664.p_sheen_velvet);
    if(_S666)
    {
        var _S667 : SampleBSDF = sheenVelvetSample(_S655, n_i_14, _S658, material_23, _S664, random_state_15);
        return _S667;
    }
    var _S668 : f32 = _S665.value - _S664.p_sheen_velvet;
    var _S669 : bool = _S668 < (_S664.p_diffuse);
    if(_S669)
    {
        var _S670 : SampleBSDF = diffuseSample(_S668, n_i_14, _S658, material_23, _S664, random_state_15);
        return _S670;
    }
    var _S671 : f32 = vndfPDF(_S655, _S663, n_i_14, _S658, _S660, _S661, _S664.v_dot_h);
    var _S672 : bool = _S668 < (_S664.p_diffuse + _S664.p_refract);
    if(_S672)
    {
        var _S673 : SampleBSDF = refractSample(_S663, n_i_14, _S660, _S661, material_23, _S664, _S671, eta_i_8, eta_o_8, random_state_15);
        return _S673;
    }
    var _S674 : SampleBSDF = reflectSample(in_dir_8, _S663, n_i_14, _S660, _S661, _S664, _S671, random_state_15);
    return _S674;
}

fn escapeWeight_0( pdf_5 : f32,  dir_11 : vec3<f32>) -> f32
{
    var _S675 : bool = pdf_5 <= 0.0f;
    var _S676 : bool;
    if(_S675)
    {
        _S676 = true;
    }
    else
    {
        var _S677 : bool = environmentMapped_0();
        _S676 = !_S677;
    }
    if(_S676)
    {
        return 1.0f;
    }
    var _S678 : f32 = environmentPdf_0(dir_11);
    return pdf_5 / (pdf_5 + _S678);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S679 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S679.x, max(_S679.y, _S679.z)), 0.0f, 1.0f);
}

fn environment_0( dir_12 : vec3<f32>) -> vec3<f32>
{
    var _S680 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S681 : bool = (all((_S680 > vec2<u32>(u32(1)))));
    if(_S681)
    {
        var _S682 : vec3<f32> = (env_map_sample((dir_12)));
        return _S682;
    }
    var _S683 : vec3<f32> = (uniforms_float.ambient);
    return _S683;
}

fn escape_0( r_2 : Reservoir,  replay_0 : bool,  stop_0 : u32,  rc_1 : u32,  end_1 : u32,  end_type_1 : u32,  scale_1 : f32,  strata_0 : u32,  chain_0 : Reservoir,  chain_throughput_0 : vec3<f32>,  b_2 : u32,  ray_2 : Ray,  throughput_2 : vec3<f32>,  density_2 : f32,  prev_0 : Vertex,  nee_vertex_0 : NEEVertex,  sky_pdf_0 : f32,  spectral_weight_0 : vec3<f32>,  wavelength_8 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S684 : Shift = Shift_x24init_0(vec3<f32>(0.0f), 0.0f);
    var _S685 : bool = !nee_vertex_0.none;
    var _S686 : f32 = select(0.0f, sky_pdf_0, _S685);
    var _S687 : f32 = escapeWeight_0(_S686, ray_2.unit_direction);
    var _S688 : vec3<f32> = environment_0(ray_2.unit_direction);
    var _S689 : vec3<f32> = pathColor(throughput_2 * _S688, spectral_weight_0, wavelength_8);
    if(replay_0)
    {
        var _S690 : bool = b_2 == stop_0;
        var _S691 : bool;
        if(_S690)
        {
            _S691 = rc_1 == u32(3);
        }
        else
        {
            _S691 = false;
        }
        if(_S691)
        {
            return Shift_x24init_0(_S689 * vec3<f32>(_S687) / vec3<f32>(r_2.jac), density_2 / r_2.jac);
        }
        var _S692 : bool = rc_1 == u32(0);
        if(_S692)
        {
            _S691 = end_type_1 == u32(3);
        }
        else
        {
            _S691 = false;
        }
        if(_S691)
        {
            _S691 = b_2 == end_1;
        }
        else
        {
            _S691 = false;
        }
        if(_S691)
        {
            _S691 = !prev_0.rough;
        }
        else
        {
            _S691 = false;
        }
        if(_S691)
        {
            return Shift_x24init_0(_S689 * vec3<f32>(_S687), 1.0f);
        }
        return _S684;
    }
    var candidate_2 : Reservoir = chain_0;
    var _S693 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
    var _S694 : bool = _S693 == u32(1);
    if(_S694)
    {
        var _S695 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
        var _S696 : bool = _S695 == b_2;
        var _S697 : f32 = select(_S687, 1.0f, _S696);
        var _S698 : vec3<f32> = safeDivide(_S689 * vec3<f32>(_S697), chain_throughput_0);
        candidate_2.radiance = _S698;
    }
    else
    {
        if(prev_0.rough)
        {
            var _S699 : u32 = (insertBits((strata_0), (b_2 + u32(1)), (u32(5)), (u32(5))));
            var _S700 : u32 = (insertBits((_S699), (u32(3)), (u32(10)), (u32(2))));
            var _S701 : u32 = (insertBits((_S700), (prev_0.lobe), (u32(15)), (u32(3))));
            var _S702 : u32 = select(u32(0), u32(1), prev_0.inside);
            var _S703 : u32 = (insertBits((_S701), (_S702), (u32(22)), (u32(1))));
            candidate_2.path = _S703;
            candidate_2.jac = prev_0.pdf;
            candidate_2.dir = ray_2.unit_direction;
        }
    }
    var _S704 : vec3<f32> = _S689 * vec3<f32>(_S687);
    var _S705 : Reservoir = withEnd(candidate_2, u32(3), b_2, _S704);
    offer(&((*sel_1)), _S705, _S704 * vec3<f32>(scale_1) / vec3<f32>(density_2));
    return _S684;
}

fn walk_0( dom_0 : Domain,  r_3 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_2 : ptr<function, Selection>) -> Shift
{
    var _S706 : vec3<f32> = vec3<f32>(0.0f);
    var _S707 : Shift = Shift_x24init_0(_S706, 0.0f);
    var _S708 : u32 = (extractBits((r_3.path), (u32(0)), (u32(5))));
    var _S709 : u32 = (extractBits((r_3.path), (u32(5)), (u32(5))));
    var _S710 : u32 = (extractBits((r_3.path), (u32(10)), (u32(2))));
    var _S711 : u32 = (extractBits((r_3.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_1)
    {
        var _S712 : bool = _S711 >= u32(3);
        var _S713 : u32 = select(u32(0), u32(1), _S712);
        var _S714 : u32 = _S708 + _S713;
        var _S715 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S714 > _S715;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S707;
    }
    var _S716 : u32 = _S709 - u32(1);
    var _S717 : bool = _S711 == u32(3);
    var _S718 : u32 = select(u32(0), u32(1), _S717);
    var _S719 : u32 = _S708 + _S718;
    var _S720 : bool = _S710 == u32(0);
    var _S721 : u32 = select(_S716, _S719, _S720);
    var _S722 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_3.rc.zw))), r_3.rc.x, r_3.rc.y, u32(0), 0.0f);
    var _S723 : vec3<f32> = (normalize((dom_0.x1 - dom_0.x0)));
    var _S724 : Ray = Ray_x24init_0(dom_0.x1, _S723);
    var ray_3 : Ray = _S724;
    var hit_1 : Hit = dom_0.hit;
    var _S725 : vec3<f32> = vec3<f32>(1.0f);
    var _S726 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S706, _S706, _S706);
    var nee_vertex_1 : NEEVertex = _S726;
    var _S727 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_1 : Vertex = _S727;
    var _S728 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S706, 0.0f, vec4<u32>(u32(0)), _S706, _S706);
    var chain_1 : Reservoir = _S728;
    chain_1.seed = r_3.seed;
    var _S729 : u32 = (extractBits((r_3.path), (u32(24)), (u32(8))));
    var _S730 : u32 = (insertBits((u32(0)), (_S729), (u32(24)), (u32(8))));
    chain_1.path = _S730;
    is_inside_5 = false;
    var wavelength_9 : f32 = 0.0f;
    var threshold_0 : f32 = 0.0f;
    var spectral_weight_1 : vec3<f32> = _S725;
    var chain_throughput_1 : vec3<f32> = _S706;
    var reconnection_0 : vec3<f32> = _S706;
    var b_3 : u32 = u32(0);
    var throughput_3 : vec3<f32> = _S725;
    var scatter_in_0 : vec3<f32> = _S706;
    var extinction_in_0 : vec3<f32> = _S706;
    var density_3 : f32 = 1.0f;
    var sky_pdf_1 : f32 = 0.0f;
    loop
    {
        var _S731 : bool = (hit_1.is_point_light) == u32(1);
        var _S732 : bool;
        if(replay_1)
        {
            _S732 = _S710 == u32(1);
        }
        else
        {
            _S732 = false;
        }
        var _S733 : bool;
        if(_S732)
        {
            _S733 = b_3 == _S709;
        }
        else
        {
            _S733 = false;
        }
        var _S734 : bool;
        if(_S733)
        {
            var _S735 : bool = (hit_1.instance_index) != (_S722.instance_index);
            if(_S735)
            {
                _S734 = true;
            }
            else
            {
                _S734 = (hit_1.triangle_index) != (_S722.triangle_index);
            }
        }
        else
        {
            _S734 = false;
        }
        if(_S734)
        {
            return _S707;
        }
        var _S736 : Surface = Surface_x24init_0(_S706, _S706, 0.0f, Material_x24init_0(_S706, _S706, 0.0f, 0.0f, 0.0f, 0.0f, _S706, _S725, 1.0f, _S706, _S706, 0.5f, 0.0f, 0.0f, _S706, 0.0f, 0.0f), false, u32(0));
        var _S737 : bool = !_S731;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_4 : vec3<f32>;
        var surface_5 : Surface;
        if(_S737)
        {
            var _S738 : u32 = stream(r_3.seed, b_3);
            var _S739 : Surface = (surfaceAt((hit_1), (ray_3.origin), (_S738)));
            var surface_6 : Surface = facingRay_0(_S739, ray_3.unit_direction);
            if(is_inside_5)
            {
                var _S740 : f32 = hit_1.distance;
                var _S741 : f32 = upsample(surface_6.material.absorption, wavelength_9);
                var _S742 : vec3<f32> = vec3<f32>(_S741);
                var _S743 : bool = wavelength_9 > 0.0f;
                var _S744 : vec3<f32> = select(surface_6.material.absorption, _S742, _S743);
                var _S745 : vec3<f32> = beerLambert(_S740, _S744);
                var _S746 : vec3<f32> = throughput_3 * _S745;
                front_n_0 = _S746;
            }
            else
            {
                front_n_0 = throughput_3;
            }
            var _S747 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_3.unit_direction)) / (hit_1.distance * hit_1.distance);
            var _S748 : bool = b_3 == u32(0);
            if(_S748)
            {
                var _S749 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S749;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S750 : vec3<f32> = front_n_0;
            var _S751 : f32 = geometry_density_0;
            scatter_0 = _S747;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S751;
            surface_5 = surface_6;
            front_n_0 = _S739.smooth_n;
            throughput_4 = _S750;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S736;
            front_n_0 = _S706;
            throughput_4 = throughput_3;
        }
        var _S752 : bool;
        if(scatter_0)
        {
            _S752 = prev_1.rough;
        }
        else
        {
            _S752 = false;
        }
        var _S753 : bool;
        if(_S752)
        {
            _S753 = (prev_1.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S753 = false;
        }
        var _S754 : Surface = surface_5;
        var _S755 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_3.unit_direction));
        var _S756 : bool = ((true));
        var _S757 : bool;
        if(_S756)
        {
            _S757 = wavelength_9 == 0.0f;
        }
        else
        {
            _S757 = false;
        }
        var _S758 : bool;
        if(_S757)
        {
            _S758 = scatter_0;
        }
        else
        {
            _S758 = false;
        }
        var _S759 : bool;
        if(_S758)
        {
            var _S760 : bool = dispersive(surface_5.material);
            _S759 = _S760;
        }
        else
        {
            _S759 = false;
        }
        var throughput_5 : vec3<f32>;
        if(_S759)
        {
            var _S761 : u32 = stream(r_3.seed, u32(512));
            var _S762 : Random = pcg(_S761);
            var _S763 : u32 = (extractBits((r_3.path), (u32(25)), (u32(7))));
            var _S764 : f32 = (f32(_S763) + _S762.value) / 128.0f;
            var _S765 : u32 = (extractBits((r_3.path), (u32(24)), (u32(1))));
            var _S766 : bool = _S765 == u32(1);
            var _S767 : f32 = select(_S762.value, _S764, _S766);
            var _S768 : vec2<f32> = sampleWavelength(_S767);
            var wavelength_10 : f32 = _S768.x;
            var _S769 : vec3<f32> = wavelengthWeights(wavelength_10);
            var _S770 : vec3<f32> = _S769 / vec3<f32>(_S768.y);
            var _S771 : f32 = upsample(throughput_4, wavelength_10);
            var _S772 : vec3<f32> = vec3<f32>(_S771);
            var _S773 : f32 = upsample(scatter_in_0, wavelength_10);
            var _S774 : vec3<f32> = vec3<f32>(_S773);
            var _S775 : f32 = upsample(extinction_in_0, wavelength_10);
            var _S776 : vec3<f32> = vec3<f32>(_S775);
            wavelength_9 = wavelength_10;
            spectral_weight_1 = _S770;
            throughput_5 = _S772;
            scatter_in_0 = _S774;
            extinction_in_0 = _S776;
        }
        else
        {
            throughput_5 = throughput_4;
        }
        var _S777 : Material = pathMaterial(surface_5.material, wavelength_9);
        var _S778 : vec2<f32> = wavelengthEta(_S777, _S755, wavelength_9);
        var _S779 : bool;
        if(scatter_0)
        {
            var _S780 : u32 = (uniforms_uint.max_bounces);
            var _S781 : bool = b_3 >= _S780;
            if(_S781)
            {
                _S779 = true;
            }
            else
            {
                var _S782 : bool = neeDecision(_S777, _S755, _S778.x, _S778.y);
                _S779 = _S782;
            }
        }
        else
        {
            _S779 = false;
        }
        var _S783 : bool = isTranslucent_0(_S777);
        var _S784 : vec3<f32> = emitted_0(_S777.emissive, ray_3.unit_direction, front_n_0);
        var emission_0 : vec3<f32>;
        if(_S731)
        {
            var _S785 : vec3<f32> = (calculatePointLightContrib((hit_1.instance_index)));
            emission_0 = _S785;
        }
        else
        {
            emission_0 = _S784;
        }
        var _S786 : bool = !replay_1;
        var _S787 : bool;
        if(_S786)
        {
            _S787 = true;
        }
        else
        {
            _S787 = b_3 >= _S721;
        }
        var _S788 : bool;
        if(_S787)
        {
            var _S789 : f32 = rgb_to_greyscale(emission_0);
            _S788 = _S789 > 0.0f;
        }
        else
        {
            _S788 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S788)
        {
            var _S790 : f32 = emissionWeight_0(nee_vertex_1, hit_1, ray_3.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S790);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S791 : bool;
        if(replay_1)
        {
            _S791 = _S710 == u32(1);
        }
        else
        {
            _S791 = false;
        }
        var _S792 : bool;
        if(_S791)
        {
            _S792 = b_3 > _S709;
        }
        else
        {
            _S792 = false;
        }
        var _S793 : bool;
        if(_S792)
        {
            _S793 = b_3 == _S708;
        }
        else
        {
            _S793 = false;
        }
        var _S794 : bool;
        if(_S793)
        {
            var _S795 : bool = _S711 == u32(1);
            if(_S795)
            {
                _S794 = true;
            }
            else
            {
                _S794 = _S711 == u32(2);
            }
        }
        else
        {
            _S794 = false;
        }
        if(_S794)
        {
            var _S796 : bool = _S731 != (_S711 == u32(2));
            if(_S796)
            {
                return _S707;
            }
            var _S797 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S797 / vec3<f32>(r_3.jac), density_3 / r_3.jac);
        }
        var _S798 : u32 = (extractBits((chain_1.path), (u32(10)), (u32(2))));
        var _S799 : bool = _S798 == u32(1);
        var here_0 : Reservoir = chain_1;
        var _S800 : u32 = (insertBits((_S730), (b_3), (u32(5)), (u32(5))));
        var _S801 : u32 = (insertBits((_S800), (u32(1)), (u32(10)), (u32(2))));
        var _S802 : u32 = (insertBits((_S801), (prev_1.lobe), (u32(15)), (u32(3))));
        var _S803 : bool = prev_1.inside;
        var _S804 : u32 = select(u32(0), u32(1), _S803);
        var _S805 : u32 = (insertBits((_S802), (_S804), (u32(22)), (u32(1))));
        here_0.path = _S805;
        var _S806 : u32 = here_0.path;
        var _S807 : bool = wavelength_9 > 0.0f;
        var _S808 : u32 = select(u32(0), u32(1), _S807);
        var _S809 : u32 = (insertBits((_S806), (_S808), (u32(23)), (u32(1))));
        here_0.path = _S809;
        var _S810 : f32 = prev_1.pdf * geometry_density_0;
        here_0.jac = _S810;
        var _S811 : vec4<u32> = vec4<u32>(hit_1.instance_index, hit_1.triangle_index, (bitcast<vec2<u32>>((hit_1.uv))));
        here_0.rc = _S811;
        var _S812 : bool;
        if(replay_1)
        {
            _S812 = _S710 == u32(1);
        }
        else
        {
            _S812 = false;
        }
        var _S813 : bool;
        if(_S812)
        {
            _S813 = b_3 == _S709;
        }
        else
        {
            _S813 = false;
        }
        var _S814 : bool = b_3 == _S721;
        var _S815 : bool;
        if(_S814)
        {
            var _S816 : bool = !scatter_0;
            if(_S816)
            {
                _S815 = true;
            }
            else
            {
                var _S817 : bool = _S710 != u32(1);
                if(_S817)
                {
                    _S815 = _S710 != u32(3);
                }
                else
                {
                    _S815 = false;
                }
            }
        }
        else
        {
            _S815 = false;
        }
        var _S818 : bool;
        if(_S815)
        {
            _S818 = _S710 == u32(2);
        }
        else
        {
            _S818 = false;
        }
        var _S819 : bool;
        if(_S818)
        {
            _S819 = !_S753;
        }
        else
        {
            _S819 = false;
        }
        var _S820 : bool;
        if(_S819)
        {
            _S820 = _S711 != u32(4);
        }
        else
        {
            _S820 = false;
        }
        var _S821 : bool = _S709 == _S708;
        var _S822 : bool;
        if(_S821)
        {
            _S822 = _S711 == u32(0);
        }
        else
        {
            _S822 = false;
        }
        var _S823 : bool;
        if(_S822)
        {
            _S823 = (hit_1.instance_index) == (_S722.instance_index);
        }
        else
        {
            _S823 = false;
        }
        var _S824 : bool;
        if(_S823)
        {
            _S824 = (hit_1.triangle_index) == (_S722.triangle_index);
        }
        else
        {
            _S824 = false;
        }
        var _S825 : bool;
        if(_S824)
        {
            _S825 = _S753;
        }
        else
        {
            _S825 = false;
        }
        var _S826 : bool = select(_S820, _S825, _S813);
        var _S827 : bool;
        if(_S779)
        {
            _S827 = select(scatter_0, _S826, replay_1);
        }
        else
        {
            _S827 = false;
        }
        var _S828 : TreeSample = TreeSample_x24init_0(_S706, _S706, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S827)
        {
            var _S829 : Surface = surface_5;
            var _S830 : bool = isTranslucent_0(_S777);
            var _S831 : u32 = stream(r_3.seed, b_3 + u32(64));
            var _S832 : TreeSample = sampleLightTree_0(ray_3.origin, _S754.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S830, _S831);
            var _S833 : bool = (any(((_S832.radiance) != _S706)));
            if(_S833)
            {
                var _S834 : f32 = _S778.x;
                var _S835 : f32 = _S778.y;
                var _S836 : u32 = (uniforms_uint.max_bounces);
                var _S837 : vec3<f32> = lightBSDF_0(ray_3.unit_direction, _S832, _S754.smooth_n, _S829.geometry_n, _S777, _S834, _S835, b_3 < _S836, surface_5.random_state);
                lit_0 = _S837;
            }
            else
            {
                lit_0 = _S706;
            }
            light_1 = _S832;
        }
        else
        {
            light_1 = _S828;
            lit_0 = _S706;
        }
        var _S838 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S839 : bool;
        var _S840 : bool;
        var density_4 : f32;
        var throughput_6 : vec3<f32>;
        if(_S813)
        {
            var _S841 : bool = !_S753;
            if(_S841)
            {
                return _S707;
            }
            var _S842 : u32 = (extractBits((r_3.path), (u32(23)), (u32(1))));
            var _S843 : bool = _S807 != (_S842 == u32(1));
            if(_S843)
            {
                return _S707;
            }
            var throughput_7 : vec3<f32> = throughput_5 * vec3<f32>(geometry_density_0);
            var density_5 : f32 = density_3 * geometry_density_0;
            if(_S821)
            {
                _S838 = _S711 == u32(1);
            }
            else
            {
                _S838 = false;
            }
            if(_S838)
            {
                var _S844 : vec3<f32> = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S844 / vec3<f32>(r_3.jac), density_5 / r_3.jac);
            }
            if(_S821)
            {
                wrong_side_0 = _S711 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S845 : bool = !_S779;
                if(_S845)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S846 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S846 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S707;
                }
                var _S847 : vec3<f32> = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S847 / vec3<f32>(r_3.jac), density_5 / r_3.jac);
            }
            if(_S821)
            {
                refracted_4 = _S711 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S848 : bool = !_S779;
                if(_S848)
                {
                    return _S707;
                }
                var _S849 : f32 = environmentPdf_0(r_3.dir);
                var _S850 : vec3<f32> = skyBSDF(ray_3.unit_direction, r_3.dir, surface_5, _S777, _S778, is_inside_5, _S849, surface_5.random_state);
                var _S851 : vec3<f32> = pathColor(throughput_7 * _S850 * r_3.radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S851 / vec3<f32>(r_3.jac), density_5 / r_3.jac);
            }
            var _S852 : u32 = (extractBits((r_3.path), (u32(21)), (u32(1))));
            var _S853 : bool = _S779 != (_S852 == u32(1));
            if(_S853)
            {
                return _S707;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S838 = _S814;
            }
            else
            {
                _S838 = false;
            }
            if(_S838)
            {
                var _S854 : bool = !scatter_0;
                if(_S854)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S855 : bool = _S710 != u32(1);
                    if(_S855)
                    {
                        wrong_side_0 = _S710 != u32(3);
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
                var _S856 : bool = _S710 == u32(2);
                if(_S856)
                {
                    _S732 = _S779;
                }
                else
                {
                    _S732 = false;
                }
                if(_S732)
                {
                    _S732 = !_S753;
                }
                else
                {
                    _S732 = false;
                }
                if(_S732)
                {
                    _S732 = _S711 == u32(4);
                }
                else
                {
                    _S732 = false;
                }
                if(_S732)
                {
                    var _S857 : u32 = stream(r_3.seed, b_3 + u32(256));
                    var _S858 : SkySample = sampleSky_0(ray_3, surface_5, wavelength_9, _S778, is_inside_5, _S857, surface_5.random_state);
                    var _S859 : vec3<f32> = pathColor(throughput_5 * _S858.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S859, 1.0f);
                }
                if(_S856)
                {
                    is_inside_5 = _S779;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S753;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S860 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S861 : bool = !(_S860 > 0.0f);
                    if(_S861)
                    {
                        return _S707;
                    }
                    var _S862 : vec3<f32> = pathColor(throughput_5 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S862, 1.0f);
                }
                if(_S720)
                {
                    is_inside_5 = _S711 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S731;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S863 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S863, 1.0f);
                }
                if(_S720)
                {
                    is_inside_5 = _S711 == u32(1);
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
                    is_inside_5 = !_S753;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S864 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S864, 1.0f);
                }
                return _S707;
            }
            else
            {
                if(_S786)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S865 : bool = b_3 > u32(0);
                    if(_S865)
                    {
                        var candidate_3 : Reservoir = chain_1;
                        if(_S799)
                        {
                            var _S866 : vec3<f32> = safeDivide(throughput_5 * emission_1, chain_throughput_1);
                            candidate_3.radiance = _S866;
                        }
                        else
                        {
                            if(_S753)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S867 : vec3<f32> = pathColor(throughput_5 * emission_1, spectral_weight_1, wavelength_9);
                        var _S868 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S867);
                        offer(&((*sel_2)), _S868, _S867 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                    if(_S779)
                    {
                        var _S869 : vec3<f32> = pathColor(throughput_5 * lit_0, spectral_weight_1, wavelength_9);
                        var candidate_4 : Reservoir = chain_1;
                        if(_S799)
                        {
                            var _S870 : vec3<f32> = safeDivide(_S869, chain_throughput_1);
                            candidate_4.radiance = _S870;
                        }
                        else
                        {
                            if(_S753)
                            {
                                candidate_4 = here_0;
                                var _S871 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S871;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S872 : u32 = (insertBits((_S730), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S873 : u32 = (insertBits((_S872), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S873;
                            }
                        }
                        var _S874 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S869);
                        offer(&((*sel_2)), _S874, _S869 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                    if(_S779)
                    {
                        var _S875 : bool = environmentMapped_0();
                        _S839 = _S875;
                    }
                    else
                    {
                        _S839 = false;
                    }
                    if(_S839)
                    {
                        var _S876 : u32 = (uniforms_uint.max_bounces);
                        _S840 = b_3 < _S876;
                    }
                    else
                    {
                        _S840 = false;
                    }
                    if(_S840)
                    {
                        var _S877 : u32 = stream(r_3.seed, b_3 + u32(256));
                        var _S878 : SkySample = sampleSky_0(ray_3, surface_5, wavelength_9, _S778, is_inside_5, _S877, surface_5.random_state);
                        var _S879 : vec3<f32> = pathColor(throughput_5 * _S878.color, spectral_weight_1, wavelength_9);
                        var candidate_5 : Reservoir = chain_1;
                        if(_S799)
                        {
                            var _S880 : vec3<f32> = safeDivide(_S879, chain_throughput_1);
                            candidate_5.radiance = _S880;
                        }
                        else
                        {
                            if(_S753)
                            {
                                candidate_5 = here_0;
                                var _S881 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S881;
                                candidate_5.dir = _S878.dir;
                                candidate_5.radiance = _S878.radiance;
                            }
                            else
                            {
                                var _S882 : u32 = (insertBits((_S730), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S883 : u32 = (insertBits((_S882), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S883;
                            }
                        }
                        var _S884 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S879);
                        offer(&((*sel_2)), _S884, _S879 * vec3<f32>(scale_2) / vec3<f32>(density_3));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_3;
        }
        var _S885 : bool;
        var _S886 : bool;
        var straight_0 : bool;
        var _S887 : bool;
        var _S888 : bool;
        var density_6 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_1)
            {
                _S838 = _S814;
            }
            else
            {
                _S838 = false;
            }
            var _S889 : u32 = (extractBits((r_3.path), (u32(15)), (u32(3))));
            var _S890 : u32 = (extractBits((r_3.path), (u32(18)), (u32(3))));
            var _S891 : u32 = select(_S889, _S890, _S813);
            var refracted_5 : bool = _S891 == u32(1);
            var _S892 : SampleBSDF = SampleBSDF_x24init_0(_S706, _S706, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S892;
            var dir_13 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S838)
            {
                var _S893 : u32 = (extractBits((r_3.path), (u32(22)), (u32(1))));
                var _S894 : bool = is_inside_5 != (_S893 == u32(1));
                if(_S894)
                {
                    return _S707;
                }
                var _S895 : bool = _S710 == u32(1);
                if(_S895)
                {
                    var _S896 : vec3<f32> = (hitPosition((_S722)));
                    dir_13 = _S896;
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
                    var _S897 : bool = isTranslucent_0(_S777);
                    if(_S897)
                    {
                        wrong_side_0 = _S891 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S898 : vec3<f32> = dir_13 - ray_3.origin;
                        var _S899 : vec3<f32> = select(r_3.dir, _S898, _S895);
                        refracted_4 = (dot(_S754.smooth_n, _S899) * _S755) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S895)
                {
                    var _S900 : vec3<f32> = ray_3.origin;
                    var _S901 : Surface = surface_5;
                    var _S902 : vec3<f32> = (vec3<f32>(0) - _S754.smooth_n);
                    var _S903 : bool = is_inside_5 != refracted_4;
                    var _S904 : vec3<f32> = select(_S754.smooth_n, _S902, _S903);
                    var _S905 : vec3<f32> = (normalize((dir_13 - (_S900 + vec3<f32>(_S901.geometry_offset) * _S904))));
                    reconnection_1 = _S905;
                }
                else
                {
                    reconnection_1 = r_3.dir;
                }
                var _S906 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S906)
                {
                    return _S707;
                }
                var _S907 : vec3<f32> = dir_13;
                dir_13 = reconnection_1;
                lobe_index_0 = _S891;
                wrong_side_0 = false;
                reconnection_1 = _S907;
            }
            else
            {
                var _S908 : bool = !_S813;
                if(_S908)
                {
                    var _S909 : f32 = _S778.x;
                    var _S910 : f32 = _S778.y;
                    var _S911 : vec2<f32> = vec2<f32>(0.0f);
                    var _S912 : SampleBSDF = sampleBSDF(ray_3.unit_direction, _S754.smooth_n, _S777, _S909, _S910, surface_5.random_state, _S911);
                    var bsdf_sampled_0 : SampleBSDF = _S912;
                    var _S913 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S777.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S914 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S913.geometry_n, _S777, _S909, _S910, bsdf_sampled_0.random_state, _S911);
                        bsdf_sampled_0.unit_direction = _S914.unit_direction;
                        bsdf_sampled_0.refracted = _S914.refracted;
                        bsdf_sampled_0.throughput = _S914.throughput;
                        bsdf_sampled_0.lobe = _S914.lobe;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S915 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S913.geometry_n))) * _S913.geometry_n;
                            bsdf_sampled_0.unit_direction = _S915;
                        }
                    }
                    var _S916 : u32 = bsdf_sampled_0.lobe;
                    var _S917 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S918 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S919 : f32 = bsdf_sampled_0.pdf;
                    var _S920 : f32 = select(_S919, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S920;
                    dir_13 = _S917;
                    lobe_index_0 = _S916;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S918;
                }
                else
                {
                    dir_13 = r_3.dir;
                    lobe_index_0 = _S891;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S838)
            {
                _S839 = true;
            }
            else
            {
                _S839 = _S813;
            }
            var throughput_8 : vec3<f32>;
            var throughput_9 : vec3<f32>;
            var chain_throughput_2 : vec3<f32>;
            if(_S839)
            {
                var _S921 : vec3<f32> = ray_3.unit_direction;
                var _S922 : vec3<f32> = ((-(_S921)));
                var _S923 : f32 = (sign((_S755)));
                var _S924 : vec3<f32> = _S754.smooth_n * vec3<f32>(_S923);
                var _S925 : f32 = dot(_S924, dir_13);
                var _S926 : f32 = _S777.roughness;
                var _S927 : f32 = _S926 * _S926;
                var _S928 : AnisotropicFrame = anisotropicFrame(_S777, _S924);
                var _S929 : SheenProfile = sheenProfile(_S922, _S924, _S777);
                var _S930 : vec3<f32> = reflectedHalf(_S921, dir_13);
                var _S931 : bool = lobe_index_0 == u32(1);
                if(_S931)
                {
                    var _S932 : vec3<f32> = refractedHalf(_S921, dir_13, _S754.smooth_n, _S778.x, _S778.y);
                    throughput_8 = _S932;
                }
                else
                {
                    throughput_8 = _S930;
                }
                var _S933 : bool = lobe_index_0 == u32(0);
                if(_S933)
                {
                    _S840 = true;
                }
                else
                {
                    _S840 = lobe_index_0 == u32(6);
                }
                if(_S840)
                {
                    var _S934 : vec3<f32> = sampledHalf(_S922, _S924, _S927, _S928, surface_5.random_state);
                    throughput_9 = _S934;
                }
                else
                {
                    throughput_9 = throughput_8;
                }
                var _S935 : f32 = _S778.x;
                var _S936 : f32 = _S778.y;
                var _S937 : Weights = lobeWeights(_S921, _S922, _S924, throughput_9, _S928, _S929, _S777, _S935, _S936);
                var _S938 : f32 = abs(_S755);
                var _S939 : f32 = vndfPDF(_S922, throughput_9, _S924, _S938, _S927, _S928, _S937.v_dot_h);
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S940 : f32 = diffusePDF(_S925, _S938, _S777, _S937);
                        var _S941 : vec3<f32> = diffuseBSDF(dir_13, _S924, _S777, _S937);
                        density_6 = _S940;
                        chain_throughput_2 = _S941;
                    }
                case u32(1):
                    {
                        var _S942 : f32 = refractPDF(dot(dir_13, throughput_9), _S939, _S937, _S935, _S936);
                        var _S943 : vec3<f32> = refractBSDF(dir_13, _S924, _S927, _S928, _S777, _S937);
                        density_6 = _S942;
                        chain_throughput_2 = _S943;
                    }
                case u32(4):
                    {
                        var _S944 : f32 = sheenVelvetPDF(_S925, _S938, _S937);
                        var _S945 : vec3<f32> = sheenVelvetBSDF(dir_13, _S922, _S924, _S777, _S937);
                        density_6 = _S944;
                        chain_throughput_2 = _S945;
                    }
                default :
                    {
                        var _S946 : f32 = reflectPDF(_S939, _S937);
                        var _S947 : vec3<f32> = reflectBSDF(dir_13, _S924, _S927, _S928, _S937);
                        density_6 = _S946;
                        chain_throughput_2 = _S947;
                    }
                }
                var _S948 : bool = density_6 > 0.0f;
                if(_S948)
                {
                    var _S949 : SampleBSDF = SampleBSDF_x24init_0(dir_13, chain_throughput_2, surface_5.random_state, _S931, lobe_index_0, density_6);
                    lobe_2 = _S949;
                }
            }
            var _S950 : bool = lobe_index_0 == u32(0);
            if(_S950)
            {
                _S840 = true;
            }
            else
            {
                _S840 = lobe_index_0 == u32(4);
            }
            if(_S840)
            {
                _S885 = true;
            }
            else
            {
                _S885 = lobe_index_0 == u32(6);
            }
            var _S951 : bool = !_S885;
            if(_S951)
            {
                var _S952 : bool = (_S777.roughness) == 0.0f;
                if(_S952)
                {
                    _S886 = true;
                }
                else
                {
                    var _S953 : bool = lobe_index_0 == u32(1);
                    if(_S953)
                    {
                        _S886 = (_S778.x) == (_S778.y);
                    }
                    else
                    {
                        _S886 = false;
                    }
                }
            }
            else
            {
                _S886 = false;
            }
            var _S954 : bool = lobe_index_0 == u32(1);
            if(_S954)
            {
                straight_0 = (_S777.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S955 : bool = isTranslucent_0(_S777);
            if(_S955)
            {
                _S887 = _S950;
            }
            else
            {
                _S887 = false;
            }
            if(_S887)
            {
                _S888 = (dot(dir_13, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S888 = false;
            }
            var _S956 : bool;
            if(_S779)
            {
                _S956 = !_S886;
            }
            else
            {
                _S956 = false;
            }
            var _S957 : bool;
            if(_S956)
            {
                _S957 = !wrong_side_0;
            }
            else
            {
                _S957 = false;
            }
            var _S958 : bool;
            if(_S957)
            {
                var _S959 : f32 = lobe_2.pdf;
                var _S960 : vec3<f32> = ray_3.origin;
                var _S961 : vec3<f32> = select(_S754.smooth_n, _S706, _S783);
                var _S962 : vec3<f32> = ray_3.origin;
                var _S963 : Surface = surface_5;
                var _S964 : vec3<f32> = (vec3<f32>(0) - _S754.smooth_n);
                var _S965 : vec3<f32> = select(_S754.smooth_n, _S964, _S888);
                var _S966 : NEEVertex = NEEVertex_x24init_0(false, _S959, _S960, _S961, _S962 + vec3<f32>(_S963.geometry_offset) * _S965);
                nee_vertex_1 = _S966;
            }
            else
            {
                var _S967 : bool = lobe_index_0 != u32(1);
                if(_S967)
                {
                    _S958 = true;
                }
                else
                {
                    _S958 = (_S778.x) != (_S778.y);
                }
                if(_S958)
                {
                    nee_vertex_1.none = true;
                }
            }
            var _S968 : bool = (lobe_2.pdf) > 0.0f;
            if(_S968)
            {
                if(_S885)
                {
                    _S958 = true;
                }
                else
                {
                    _S958 = (lobe_2.pdf * prev_1.cos / (hit_1.distance * hit_1.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S958 = false;
            }
            var _S969 : bool = (lobe_2.pdf) > 0.0f;
            var _S970 : bool;
            if(_S969)
            {
                if(_S885)
                {
                    _S970 = true;
                }
                else
                {
                    _S970 = (_S777.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S970 = false;
            }
            var _S971 : bool;
            if(_S813)
            {
                var _S972 : bool = !_S958;
                if(_S972)
                {
                    return _S707;
                }
                var _S973 : bool = _S711 != u32(1);
                if(_S973)
                {
                    _S971 = _S711 != u32(2);
                }
                else
                {
                    _S971 = false;
                }
                if(_S971)
                {
                    var _S974 : f32 = lobe_2.pdf;
                    var _S975 : f32 = select(0.0f, _S974, _S779);
                    var _S976 : f32 = escapeWeight_0(_S975, r_3.dir);
                    if(_S821)
                    {
                        is_inside_5 = _S717;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S977 : f32 = select(1.0f, _S976, is_inside_5);
                    return Shift_x24init_0(throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_3.radiance * vec3<f32>(_S977) / vec3<f32>(r_3.jac), density_4 * lobe_2.pdf / r_3.jac);
                }
                var _S978 : vec3<f32> = throughput_6 * vec3<f32>(lobe_2.pdf);
                var _S979 : f32 = density_4 * lobe_2.pdf;
                throughput_8 = _S978;
                density_6 = _S979;
            }
            else
            {
                throughput_8 = throughput_6;
                density_6 = density_4;
            }
            if(replay_1)
            {
                _S971 = b_3 <= _S721;
            }
            else
            {
                _S971 = false;
            }
            var _S980 : bool;
            if(_S971)
            {
                _S980 = _S753;
            }
            else
            {
                _S980 = false;
            }
            var _S981 : bool;
            if(_S980)
            {
                _S981 = _S958;
            }
            else
            {
                _S981 = false;
            }
            var _S982 : bool;
            if(_S981)
            {
                _S982 = true;
            }
            else
            {
                if(_S838)
                {
                    _S982 = !_S970;
                }
                else
                {
                    _S982 = false;
                }
            }
            if(_S982)
            {
                return _S707;
            }
            if(_S838)
            {
                var _S983 : vec3<f32> = throughput_8 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S984 : f32 = lobe_2.pdf;
                throughput_9 = _S983;
                survival_probability_0 = _S984;
            }
            else
            {
                var _S985 : vec3<f32> = throughput_8 * max(lobe_2.throughput, _S706);
                throughput_9 = _S985;
                survival_probability_0 = density_6;
            }
            var _S986 : bool;
            if(_S786)
            {
                _S986 = !_S799;
            }
            else
            {
                _S986 = false;
            }
            var _S987 : bool;
            if(_S986)
            {
                _S987 = _S753;
            }
            else
            {
                _S987 = false;
            }
            var _S988 : bool;
            if(_S987)
            {
                _S988 = _S958;
            }
            else
            {
                _S988 = false;
            }
            if(_S988)
            {
                chain_1 = here_0;
                var _S989 : u32 = (insertBits((chain_1.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S990 : u32 = select(u32(0), u32(1), _S779);
                var _S991 : u32 = (insertBits((_S989), (_S990), (u32(21)), (u32(1))));
                chain_1.path = _S991;
                var _S992 : f32 = chain_1.jac * lobe_2.pdf;
                chain_1.jac = _S992;
                chain_1.dir = dir_13;
                chain_throughput_2 = throughput_9;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            var _S993 : Vertex = Vertex_x24init_0(_S970, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_13)), is_inside_5);
            prev_1 = _S993;
            var _S994 : f32 = lobe_2.pdf;
            var _S995 : bool;
            if(_S954)
            {
                _S995 = (_S778.x) == (_S778.y);
            }
            else
            {
                _S995 = false;
            }
            var _S996 : f32 = select(_S994, sky_pdf_1, _S995);
            var _S997 : bool;
            if(refracted_4)
            {
                _S997 = !_S888;
            }
            else
            {
                _S997 = false;
            }
            var is_inside_6 : bool;
            if(_S997)
            {
                var _S998 : bool = !is_inside_5;
                is_inside_6 = _S998;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_3.unit_direction = dir_13;
            var _S999 : Surface = surface_5;
            var _S1000 : f32 = select(_S999.geometry_offset, 0.0f, straight_0);
            var _S1001 : vec3<f32> = (vec3<f32>(0) - _S754.smooth_n);
            var _S1002 : bool = is_inside_6 != _S888;
            var _S1003 : vec3<f32> = select(_S754.smooth_n, _S1001, _S1002);
            var _S1004 : vec3<f32> = ray_3.origin + vec3<f32>(_S1000) * _S1003;
            ray_3.origin = _S1004;
            chain_throughput_1 = chain_throughput_2;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_3 = throughput_9;
            density_6 = survival_probability_0;
            sky_pdf_1 = _S996;
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
        if(_S786)
        {
            if(_S731)
            {
                var _S1005 : vec3<f32> = pathColor(throughput_3 * emission_1, spectral_weight_1, wavelength_9);
                var candidate_6 : Reservoir = chain_1;
                var _S1006 : u32 = (extractBits((chain_1.path), (u32(10)), (u32(2))));
                var _S1007 : bool = _S1006 == u32(1);
                if(_S1007)
                {
                    var _S1008 : vec3<f32> = safeDivide(_S1005, chain_throughput_1);
                    candidate_6.radiance = _S1008;
                }
                var _S1009 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1005);
                offer(&((*sel_2)), _S1009, _S1005 * vec3<f32>(scale_2) / vec3<f32>(density_6));
            }
            if(_S731)
            {
                _S838 = true;
            }
            else
            {
                _S838 = scatter_0;
            }
            if(_S838)
            {
                var _S1010 : f32 = survivalProbability(abs(throughput_3), density_6);
                survival_probability_0 = _S1010;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1011 : u32 = stream(r_3.seed, b_3 + u32(128));
            var _S1012 : Random = pcg(_S1011);
            var _S1013 : bool = survival_probability_0 < (_S1012.value);
            if(_S1013)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1014 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1014;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1015 : f32 = density_6 * survival_probability_0;
            density_3 = _S1015;
        }
        else
        {
            density_3 = density_6;
        }
        var _S1016 : Ray = ray_3;
        var _S1017 : f32 = distance(reconnection_0, ray_3.origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S838 = _S814;
        }
        else
        {
            _S838 = false;
        }
        if(_S838)
        {
            wrong_side_0 = _S710 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1018 : f32 = select(4.294967296e+09f, _S1017, wrong_side_0);
        var _S1019 : Hit;
        if(straight_0)
        {
            _S1019 = hit_1;
        }
        else
        {
            _S1019 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1020 : Hit = (traverseInstanceBVH((_S1016), (_S737), (_S1018), (_S1019)));
        hit_1 = _S1020;
        if(replay_1)
        {
            refracted_4 = _S814;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S839 = _S710 == u32(1);
        }
        else
        {
            _S839 = false;
        }
        if(_S839)
        {
            _S840 = (hit_1.instance_index) == (_S722.instance_index);
        }
        else
        {
            _S840 = false;
        }
        if(_S840)
        {
            _S885 = (hit_1.triangle_index) == (_S722.triangle_index);
        }
        else
        {
            _S885 = false;
        }
        if(_S885)
        {
            hit_1.uv = _S722.uv;
            var _S1021 : f32 = distance(reconnection_0, ray_3.origin);
            hit_1.distance = _S1021;
        }
        if(replay_1)
        {
            _S886 = _S814;
        }
        else
        {
            _S886 = false;
        }
        if(_S886)
        {
            _S887 = _S710 == u32(3);
        }
        else
        {
            _S887 = false;
        }
        if(_S887)
        {
            _S888 = (hit_1.instance_index) != u32(4294967295);
        }
        else
        {
            _S888 = false;
        }
        if(_S888)
        {
            return _S707;
        }
        var _S1022 : bool = (hit_1.instance_index) == u32(4294967295);
        if(_S1022)
        {
            var _S1023 : Shift = escape_0(r_3, replay_1, _S721, _S710, _S708, _S711, scale_2, _S730, chain_1, chain_throughput_1, b_3, ray_3, throughput_3, density_3, prev_1, nee_vertex_1, sky_pdf_1, spectral_weight_1, wavelength_9, &((*sel_2)));
            return _S1023;
        }
        var _S1024 : vec3<f32> = ray_3.origin + vec3<f32>(hit_1.distance) * ray_3.unit_direction;
        ray_3.origin = _S1024;
        var _S1025 : u32 = b_3 + u32(1);
        b_3 = _S1025;
    }
    return _S707;
}

fn shift_0( dom_1 : Domain,  r_4 : Reservoir) -> Shift
{
    var _S1026 : vec3<f32> = vec3<f32>(0.0f);
    var _S1027 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1026, 0.0f, vec4<u32>(u32(0)), _S1026, _S1026), 0.0f, _S1026, u32(0));
    var sel_3 : Selection = _S1027;
    var _S1028 : bool = (r_4.w) <= 0.0f;
    if(_S1028)
    {
        return Shift_x24init_0(_S1026, 0.0f);
    }
    var _S1029 : Shift = walk_0(dom_1, r_4, true, 0.0f, &(sel_3));
    return _S1029;
}

fn partner_0( p_5 : vec2<i32>,  t_1 : u32) -> vec2<i32>
{
    var sizes_0 : array<i32, i32(3)> = array<i32, i32(3)>( i32(254), i32(230), i32(210) );
    var _S1030 : u32 = (uniforms_uint.frame);
    var _S1031 : u32 = hash(_S1030 * u32(3) + t_1);
    var _S1032 : vec2<i32> = vec2<i32>(i32(1));
    var _S1033 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1034 : vec2<bool> = vec2<bool>(((_S1031 & (u32(1)))) != u32(0), ((_S1031 & (u32(2)))) != u32(0));
    var _S1035 : vec2<i32> = select(_S1032, _S1033, _S1034);
    var _S1036 : bool = ((_S1031 & (u32(4)))) != u32(0);
    var _S1037 : vec2<i32> = vec2<i32>(i32((((_S1031 >> (u32(8)))) & (u32(255)))), i32((((_S1031 >> (u32(16)))) & (u32(255)))));
    var _S1038 : vec2<i32> = p_5.yx;
    var _S1039 : vec2<i32> = select(p_5, _S1038, _S1036);
    var _S1040 : vec2<i32> = vec2<i32>(sizes_0[t_1]);
    var _S1041 : vec2<i32> = _S1039 % _S1040;
    var _S1042 : vec2<i32> = _S1040 - _S1041;
    var _S1043 : vec2<bool> = _S1035 < vec2<i32>(i32(0));
    var _S1044 : vec2<i32> = select(_S1041, _S1042, _S1043);
    var _S1045 : vec2<i32> = (_S1044 + _S1037) % _S1040;
    var _S1046 : vec4<i32> = (textureLoad(pairing, (_S1045), (t_1), 0));
    var _S1047 : vec2<i32> = _S1046.xy * _S1035;
    var _S1048 : vec2<i32> = _S1047.yx;
    var _S1049 : vec2<i32> = select(_S1047, _S1048, _S1036);
    return p_5 + _S1049;
}

struct ShiftJob
{
     dom : Domain,
     r : Reservoir,
};

fn spatialJob_0( p_6 : vec2<i32>,  t_2 : u32,  job_0 : ptr<function, ShiftJob>) -> bool
{
    var _S1050 : bool = t_2 > u32(2);
    var _S1051 : bool;
    if(_S1050)
    {
        _S1051 = true;
    }
    else
    {
        var _S1052 : vec2<u32> = (uniforms_uint.render_size);
        _S1051 = (any((p_6 >= vec2<i32>(_S1052))));
    }
    if(_S1051)
    {
        return false;
    }
    var _S1053 : Reservoir = (loadReservoir(reservoir_temp, (p_6)));
    (*job_0).r = _S1053;
    var _S1054 : bool = ((*job_0).r.w) > 0.0f;
    if(_S1054)
    {
        var _S1055 : vec2<i32> = partner_0(p_6, t_2);
        var _S1056 : Domain = (*job_0).dom;
        var _S1057 : bool = (storedDomain(reservoir_temp, (_S1055), &(_S1056)));
        (*job_0).dom = _S1056;
        _S1051 = _S1057;
    }
    else
    {
        _S1051 = false;
    }
    return _S1051;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_2 : Hit) -> Domain
{
    var _S1058 : Domain;
    _S1058.x0 = x0_0;
    _S1058.x1 = x1_0;
    _S1058.hit = hit_2;
    return _S1058;
}

fn ShiftJob_x24init_0( dom_2 : Domain,  r_5 : Reservoir) -> ShiftJob
{
    var _S1059 : ShiftJob;
    _S1059.dom = dom_2;
    _S1059.r = r_5;
    return _S1059;
}

fn shiftBin_0( r_6 : Reservoir) -> u32
{
    var _S1060 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S1061 : bool = _S1060 == u32(2);
    var _S1062 : bool;
    if(_S1061)
    {
        var _S1063 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
        _S1062 = _S1063 == u32(4);
    }
    else
    {
        _S1062 = false;
    }
    var _S1064 : u32 = select(_S1060, u32(4), _S1062);
    var _S1065 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S1066 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S1067 : u32 = _S1066 + u32(1);
    var _S1068 : bool = _S1060 == u32(0);
    var _S1069 : u32 = select(_S1065, _S1067, _S1068);
    return _S1064 * u32(8) + clamp(_S1069, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_7 : vec2<i32>,  _S1070 : ptr<function, array<u32, i32(3)>>)
{
    var _S1071 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_3 : u32 = u32(0);
    loop
    {
        var _S1072 : u32 = (uniforms_uint.restir_neighbours);
        if(t_3 < _S1072)
        {
        }
        else
        {
            break;
        }
        var _S1073 : vec3<f32> = vec3<f32>(0.0f);
        var _S1074 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1073, _S1073, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1073, 0.0f, vec4<u32>(u32(0)), _S1073, _S1073));
        var job_1 : ShiftJob = _S1074;
        var _S1075 : bool = spatialJob_0(p_7, t_3, &(job_1));
        if(_S1075)
        {
            var _S1076 : u32 = shiftBin_0(job_1.r);
            bins_0[t_3] = _S1076;
        }
        var t_4 : u32 = t_3 + u32(1);
        t_3 = t_4;
    }
    (*_S1070) = bins_0;
    return;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S1077 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S1077;
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
        var _S1078 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S1079 : u32 = (_S1078 + u32(63)) / u32(64);
        var _S1080 : bool = group_0 < _S1079;
        if(_S1080)
        {
            var _S1081 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S1082 : bool = _S1081 < _S1078;
            if(_S1082)
            {
                var _S1083 : u32 = (queued_shifts[(u32(83) + start_4 + _S1081)]);
                return _S1083;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S1079;
        var start_5 : u32 = start_4 + _S1078;
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
    var _S1084 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S1085 : u32 = t_5;
        var _S1086 : bool = (bins_1[t_5]) < u32(40);
        if(_S1086)
        {
            var _S1087 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S1085]]), u32(1));
            slots_0[t_5] = _S1087;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S1088 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S1088)
    {
        var _S1089 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S1090 : bool = _S1089 > u32(0);
        if(_S1090)
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
                var _S1091 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S1091;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S1092 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S1089)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S1092;
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
        var _S1093 : u32 = t_5;
        var _S1094 : bool = (bins_1[t_5]) < u32(40);
        if(_S1094)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S1093]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S1095 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S1095)
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
            var _S1096 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S1096 + u32(63)) / u32(64);
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
    var _S1097 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S1098 : bool;
    if(_S1097)
    {
        var _S1099 : vec2<u32> = (uniforms_uint.render_size);
        _S1098 = (all((q_0 < vec2<i32>(_S1099))));
    }
    else
    {
        _S1098 = false;
    }
    if(_S1098)
    {
        var _S1100 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S1098 = (bitcast<f32>((_S1100.w))) > 0.0f;
    }
    else
    {
        _S1098 = false;
    }
    return _S1098;
}

fn sameDomain_0( a_6 : Domain,  b_4 : Domain) -> bool
{
    var _S1101 : bool = (all(((a_6.x0) == (b_4.x0))));
    var _S1102 : bool;
    if(_S1101)
    {
        _S1102 = (a_6.hit.instance_index) == (b_4.hit.instance_index);
    }
    else
    {
        _S1102 = false;
    }
    if(_S1102)
    {
        _S1102 = (a_6.hit.triangle_index) == (b_4.hit.triangle_index);
    }
    else
    {
        _S1102 = false;
    }
    if(_S1102)
    {
        _S1102 = (all(((a_6.hit.uv) == (b_4.hit.uv))));
    }
    else
    {
        _S1102 = false;
    }
    return _S1102;
}

fn project_0( view_0 : mat3x3<f32>,  camera_0 : vec3<f32>,  position_0 : vec3<f32>) -> vec2<f32>
{
    var _S1103 : vec3<f32> = (((view_0) * (position_0 - camera_0)));
    var _S1104 : vec2<f32> = vec2<f32>(0.5f);
    var _S1105 : vec2<f32> = _S1103.xy / vec2<f32>(_S1103.z) * _S1104 + _S1104;
    var _S1106 : vec2<f32> = vec2<f32>(_S1105.x, 1.0f - _S1105.y);
    var _S1107 : vec2<u32> = (uniforms_uint.render_size);
    return _S1106 * vec2<f32>(_S1107);
}

fn pixelOf_0( position_1 : vec3<f32>,  previous_0 : bool) -> vec2<f32>
{
    var _S1108 : mat3x3<f32>;
    if(previous_0)
    {
        var _S1109 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
        _S1108 = _S1109;
    }
    else
    {
        var _S1110 : mat3x3<f32> = (uniforms_float.view_matrix);
        _S1108 = _S1110;
    }
    var _S1111 : vec3<f32> = (uniforms_float.camera_position);
    var _S1112 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1113 : vec2<f32> = project_0(_S1108, select(_S1111, _S1112, previous_0), position_1);
    return _S1113;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain,  seed_2 : u32) -> vec2<i32>
{
    var _S1114 : bool = previousValid_0(p_9);
    var _S1115 : bool;
    if(_S1114)
    {
        var _S1116 : Domain = (previousDomain((p_9)));
        var _S1117 : bool = sameDomain_0(_S1116, dom_3);
        _S1115 = _S1117;
    }
    else
    {
        _S1115 = false;
    }
    if(_S1115)
    {
        return p_9;
    }
    var _S1118 : bool = (dom_3.hit.instance_index) == u32(4294967295);
    if(_S1118)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1119 : vec2<f32> = pixelOf_0(dom_3.x1, true);
    var _S1120 : vec2<i32> = vec2<i32>(floor(_S1119));
    var _S1121 : bool = previousValid_0(_S1120);
    var _S1122 : bool = !_S1121;
    if(_S1122)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1123 : vec4<u32> = (textureLoad(reservoir_prev, (_S1120), (u32(0)), 0));
    var _S1124 : Domain = (previousDomain((_S1120)));
    var _S1125 : bool = (_S1124.hit.instance_index) == (dom_3.hit.instance_index);
    if(_S1125)
    {
        var _S1126 : f32 = distance(_S1124.x1, dom_3.x1);
        var _S1127 : f32 = dom_3.hit.distance * 8.0f;
        var _S1128 : vec2<u32> = (uniforms_uint.render_size);
        _S1115 = _S1126 <= (_S1127 / f32(_S1128.x));
    }
    else
    {
        _S1115 = false;
    }
    if(_S1115)
    {
        return _S1120;
    }
    var _S1129 : vec2<f32> = vec2<f32>(p_9 + _S1120) + vec2<f32>(1.0f);
    var _S1130 : vec2<f32> = pixelOf_0(_S1124.x1, false);
    var _S1131 : vec2<i32> = vec2<i32>(floor(_S1129 - _S1130));
    var _S1132 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1133 : bool = previousValid_0(_S1131);
    var _S1134 : vec2<i32> = select(_S1132, _S1131, _S1133);
    return _S1134;
}

fn sampleNeighbor_0( p_10 : vec2<i32>,  seed_3 : u32) -> vec2<i32>
{
    var _S1135 : bool = ((false));
    if(_S1135)
    {
        var _S1136 : vec2<i32> = vec2<i32>(i32(-1));
        var _S1137 : bool = previousValid_0(p_10);
        var _S1138 : vec2<i32> = select(_S1136, p_10, _S1137);
        return _S1138;
    }
    var _S1139 : vec3<f32> = vec3<f32>(0.0f);
    var _S1140 : Domain = Domain_x24init_0(_S1139, _S1139, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1140;
    var _S1141 : vec2<u32> = (uniforms_uint.render_size);
    var _S1142 : bool = (any((p_10 >= vec2<i32>(_S1141))));
    var _S1143 : bool;
    if(_S1142)
    {
        _S1143 = true;
    }
    else
    {
        var _S1144 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1143 = !_S1144;
    }
    if(_S1143)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1145 : vec2<i32> = temporalNeighbor_0(p_10, dom_4, seed_3);
    return _S1145;
}

fn storedNeighbor_0( p_11 : vec2<i32>) -> vec2<i32>
{
    var _S1146 : Reservoir = (loadReservoir(reservoir_initial, (p_11)));
    var _S1147 : vec2<i32> = sampleNeighbor_0(p_11, _S1146.seed);
    return _S1147;
}

fn temporalJob_0( p_12 : vec2<i32>,  q_1 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>,  target_0 : bool) -> bool
{
    var _S1148 : bool = t_8 > u32(1);
    var _S1149 : bool;
    if(_S1148)
    {
        _S1149 = true;
    }
    else
    {
        var _S1150 : vec2<u32> = (uniforms_uint.render_size);
        _S1149 = (any((p_12 >= vec2<i32>(_S1150))));
    }
    if(_S1149)
    {
        _S1149 = true;
    }
    else
    {
        var _S1151 : bool = ((false));
        _S1149 = _S1151;
    }
    if(_S1149)
    {
        _S1149 = true;
    }
    else
    {
        _S1149 = (q_1.x) < i32(0);
    }
    if(_S1149)
    {
        return false;
    }
    var _S1152 : bool = t_8 == u32(0);
    if(_S1152)
    {
        var _S1153 : Reservoir = (loadReservoir(reservoir_prev, (q_1)));
        (*job_2).r = _S1153;
        var _S1154 : bool = ((*job_2).r.w) > 0.0f;
        if(_S1154)
        {
            var _S1155 : bool = !target_0;
            if(_S1155)
            {
                _S1149 = true;
            }
            else
            {
                var _S1156 : Domain = (*job_2).dom;
                var _S1157 : bool = (storedDomain(reservoir_initial, (p_12), &(_S1156)));
                (*job_2).dom = _S1156;
                _S1149 = _S1157;
            }
        }
        else
        {
            _S1149 = false;
        }
        return _S1149;
    }
    var _S1158 : Reservoir = (loadReservoir(reservoir_initial, (p_12)));
    (*job_2).r = _S1158;
    var _S1159 : bool = !target_0;
    if(_S1159)
    {
        var _S1160 : bool = ((false));
        _S1149 = _S1160;
    }
    else
    {
        _S1149 = false;
    }
    if(_S1149)
    {
        return ((*job_2).r.w) > 0.0f;
    }
    var _S1161 : Domain = (previousDomain((q_1)));
    (*job_2).dom = _S1161;
    var _S1162 : vec3<f32> = vec3<f32>(0.0f);
    var _S1163 : Domain = Domain_x24init_0(_S1162, _S1162, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var own_0 : Domain = _S1163;
    var _S1164 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1164)
    {
        var _S1165 : bool = ((false));
        if(_S1165)
        {
            _S1149 = true;
        }
        else
        {
            var _S1166 : bool = (storedDomain(reservoir_initial, (p_12), &(own_0)));
            if(_S1166)
            {
                var _S1167 : bool = sameDomain_0((*job_2).dom, own_0);
                _S1149 = _S1167;
            }
            else
            {
                _S1149 = false;
            }
            _S1149 = !_S1149;
        }
    }
    else
    {
        _S1149 = false;
    }
    return _S1149;
}

fn temporalBins_0( p_13 : vec2<i32>,  _S1168 : ptr<function, array<u32, i32(3)>>)
{
    var _S1169 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_2 : array<u32, i32(3)>;
    bins_2[i32(0)] = u32(40);
    bins_2[i32(1)] = u32(40);
    bins_2[i32(2)] = u32(40);
    var _S1170 : vec2<i32> = storedNeighbor_0(p_13);
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
        var _S1171 : vec3<f32> = vec3<f32>(0.0f);
        var _S1172 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1171, _S1171, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1171, 0.0f, vec4<u32>(u32(0)), _S1171, _S1171));
        var job_3 : ShiftJob = _S1172;
        var _S1173 : bool = temporalJob_0(p_13, _S1170, t_9, &(job_3), false);
        if(_S1173)
        {
            var _S1174 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1174;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1168) = bins_2;
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
        var _S1175 : u32 = t_11;
        var _S1176 : bool = (bins_3[t_11]) < u32(40);
        if(_S1176)
        {
            var _S1177 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1175]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1178 : bool = local_invocation_index_2 < u32(40);
    if(_S1178)
    {
        var _S1179 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1180 : bool = _S1179 > u32(0);
        if(_S1180)
        {
            var _S1181 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1179)));
        }
    }
    return;
}

fn passWalk_0( dom_5 : Domain,  r_7 : Reservoir,  replay_2 : bool,  scale_3 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S1182 : Shift = walk_0(dom_5, r_7, replay_2, scale_3, &((*sel_4)));
    return _S1182;
}

fn passShift_0( dom_6 : Domain,  r_8 : Reservoir) -> Shift
{
    var _S1183 : vec3<f32> = vec3<f32>(0.0f);
    var _S1184 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1183, 0.0f, vec4<u32>(u32(0)), _S1183, _S1183), 0.0f, _S1183, u32(0));
    var sel_5 : Selection = _S1184;
    var _S1185 : bool = (r_8.w) <= 0.0f;
    if(_S1185)
    {
        return Shift_x24init_0(_S1183, 0.0f);
    }
    var _S1186 : Shift = passWalk_0(dom_6, r_8, true, 0.0f, &(sel_5));
    return _S1186;
}

fn temporalShiftAt_0( p_14 : vec2<i32>,  q_2 : vec2<i32>,  t_13 : u32) -> Shift
{
    var _S1187 : vec3<f32> = vec3<f32>(0.0f);
    var _S1188 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1187, _S1187, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1187, 0.0f, vec4<u32>(u32(0)), _S1187, _S1187));
    var job_4 : ShiftJob = _S1188;
    var _S1189 : bool = temporalJob_0(p_14, q_2, t_13, &(job_4), true);
    var _S1190 : bool = !_S1189;
    if(_S1190)
    {
        return Shift_x24init_0(_S1187, 0.0f);
    }
    var _S1191 : Shift = passShift_0(job_4.dom, job_4.r);
    return _S1191;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_4 : u32;
    var _S1192 : vec2<u32> = global_invocation_id_1.xy;
    var _S1193 : vec2<i32> = vec2<i32>(_S1192 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1194 : vec2<i32> = _S1193 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1195 : bool = (all((_S1194 >= vec2<i32>(i32(0)))));
        var _S1196 : bool;
        if(_S1195)
        {
            var _S1197 : vec2<u32> = (uniforms_uint.render_size);
            _S1196 = (all((_S1194 < vec2<i32>(_S1197))));
        }
        else
        {
            _S1196 = false;
        }
        if(_S1196)
        {
            var _S1198 : vec4<u32> = (textureLoad(reservoir_prev, (_S1194), (u32(0)), 0));
            var _S1199 : u32 = _S1198.x;
            var _S1200 : bool = (bitcast<f32>((_S1198.z))) > 0.0f;
            var _S1201 : u32 = select(u32(0), _S1199, _S1200);
            seed_4 = _S1201;
        }
        else
        {
            seed_4 = u32(0);
        }
        duplication_seeds_0[i_8] = seed_4;
        var i_9 : u32 = i_8 + u32(64);
        i_8 = i_9;
    }
    workgroupBarrier();
    var _S1202 : u32 = local_invocation_id_0.y;
    var _S1203 : u32 = local_invocation_id_0.x;
    var _S1204 : u32 = duplication_seeds_0[(_S1202 + u32(8)) * u32(24) + _S1203 + u32(8)];
    seed_4 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(seed_4 < u32(17))
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
            var _S1205 : bool = (duplication_seeds_0[(_S1202 + seed_4) * u32(24) + _S1203 + x_1]) == _S1204;
            var _S1206 : u32 = select(u32(0), u32(1), _S1205);
            var count_2 : u32 = count_1 + _S1206;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_4 + u32(1);
        seed_4 = y_0;
    }
    var _S1207 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1208 : bool = _S1204 != u32(0);
    var _S1209 : f32 = select(0.0f, _S1207, _S1208);
    textureStore(duplication_out, (vec2<i32>(_S1192)), 0, (vec4<u32>((bitcast<u32>((_S1209))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_6 : ptr<function, Selection>,  r_9 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_9;
    var _S1210 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1210;
    var _S1211 : f32 = r_9.jac * shifted_0.jac;
    candidate_7.jac = _S1211;
    offer(&((*sel_6)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_9.w));
    return;
}

fn finalize( sel_7 : Selection,  c_2 : f32) -> Reservoir
{
    var r_10 : Reservoir = sel_7.r;
    var _S1212 : f32 = resamplingTarget(r_10.f);
    var _S1213 : f32 = sel_7.w_sum / _S1212;
    var _S1214 : bool = _S1212 > 0.0f;
    var _S1215 : f32 = select(0.0f, _S1213, _S1214);
    r_10.w = _S1215;
    r_10.c = c_2;
    return r_10;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1216 : vec2<u32> = global_invocation_id_2.xy;
    var _S1217 : vec2<i32> = vec2<i32>(_S1216);
    var _S1218 : vec3<f32> = vec3<f32>(0.0f);
    var _S1219 : Domain = Domain_x24init_0(_S1218, _S1218, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1219;
    var _S1220 : bool = (currentDomain((_S1217), &(dom_7)));
    var _S1221 : bool = !_S1220;
    if(_S1221)
    {
        var _S1222 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1218, 0.0f, vec4<u32>(u32(0)), _S1218, _S1218);
        storeReservoir(reservoir_prev_out, (_S1217), (_S1222), (dom_7.hit));
        var _S1223 : vec2<f32> = vec2<f32>(_S1216);
        var _S1224 : vec2<u32> = (uniforms_uint.render_size);
        var _S1225 : vec2<f32> = _S1223 / vec2<f32>(_S1224.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1226 : vec3<f32> = vec3<f32>(_S1225, 1.0f);
        var _S1227 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1228 : vec3<f32> = (normalize(((((_S1227) * (_S1226))))));
        var _S1229 : vec3<f32> = environment_0(_S1228);
        textureStore(compute_out, (_S1217), (u32(0)), (vec4<f32>(_S1229, 1.0f)));
        var _S1230 : u32 = (uniforms_uint.is_temporal);
        var _S1231 : bool = _S1230 == u32(1);
        if(_S1231)
        {
            textureStore(compute_out, (_S1217), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1232 : Reservoir = (loadReservoir(reservoir_temp, (_S1217)));
    var t_14 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1232.c;
    loop
    {
        var _S1233 : u32 = (uniforms_uint.restir_neighbours);
        if(t_14 < _S1233)
        {
        }
        else
        {
            break;
        }
        var _S1234 : vec2<i32> = partner_0(_S1217, t_14);
        var neighbor_0 : Domain = _S1219;
        var _S1235 : bool = (currentDomain((_S1234), &(neighbor_0)));
        if(_S1235)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1236 : vec4<u32> = (textureLoad(reservoir_temp, (_S1234), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1236.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_15 : u32 = t_14 + u32(1);
        t_14 = t_15;
    }
    var _S1237 : f32 = _S1232.c / max(count_3, 1.0f);
    var _S1238 : f32 = resamplingTarget(_S1232.f);
    var _S1239 : bool = count_3 == 0.0f;
    var _S1240 : f32 = select(0.0f, 1.0f, _S1239);
    var _S1241 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1218, 0.0f, vec4<u32>(u32(0)), _S1218, _S1218), 0.0f, _S1218, u32(0));
    var sel_8 : Selection = _S1241;
    var _S1242 : u32 = (uniforms_uint.frame);
    var _S1243 : u32 = hash(_S1242);
    var _S1244 : u32 = global_invocation_id_2.x;
    var _S1245 : vec2<u32> = (uniforms_uint.render_size);
    var _S1246 : u32 = stream(_S1243, _S1244 + _S1245.x * global_invocation_id_2.y);
    var _S1247 : u32 = stream(_S1246, u32(195));
    sel_8.random_state = _S1247;
    t_14 = u32(0);
    var canonical_mis_0 : f32 = _S1240;
    loop
    {
        var _S1248 : u32 = (uniforms_uint.restir_neighbours);
        if(t_14 < _S1248)
        {
        }
        else
        {
            break;
        }
        var _S1249 : vec2<i32> = partner_0(_S1217, t_14);
        var neighbor_dom_0 : Domain = _S1219;
        var _S1250 : bool = (currentDomain((_S1249), &(neighbor_dom_0)));
        if(_S1250)
        {
            var _S1251 : Reservoir = (loadReservoir(reservoir_temp, (_S1249)));
            var _S1252 : vec4<u32> = (textureLoad(shift_data, (_S1249), (t_14), 0));
            var _S1253 : vec4<f32> = (bitcast<vec4<f32>>((_S1252)));
            var _S1254 : vec4<u32> = (textureLoad(shift_data, (_S1217), (t_14), 0));
            var _S1255 : vec4<f32> = (bitcast<vec4<f32>>((_S1254)));
            var _S1256 : f32 = (_S1251.c + _S1237) / c_sum_0;
            var _S1257 : bool = _S1238 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1257)
            {
                var _S1258 : f32 = _S1256 * _S1237 * _S1238;
                var _S1259 : f32 = _S1237 * _S1238;
                var _S1260 : f32 = resamplingTarget(_S1255.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1258 / (_S1259 + _S1251.c * _S1260);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1261 : f32 = resamplingTarget(_S1251.f);
            var _S1262 : vec3<f32> = _S1253.xyz;
            var _S1263 : Shift = Shift_x24init_0(_S1262, _S1253.w);
            var _S1264 : f32 = _S1256 * _S1251.c * _S1261;
            var _S1265 : f32 = _S1251.c * _S1261;
            var _S1266 : f32 = resamplingTarget(_S1262);
            offerShifted(&(sel_8), _S1251, _S1263, _S1264 / (_S1265 + _S1237 * _S1266));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_16 : u32 = t_14 + u32(1);
        t_14 = t_16;
    }
    offerShifted(&(sel_8), _S1232, Shift_x24init_0(_S1232.f, 1.0f), canonical_mis_0);
    var _S1267 : Reservoir = finalize(sel_8, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1217), (_S1267), (dom_7.hit));
    textureStore(reservoir_prev_out, (_S1217), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_7.hit.uv))), u32(0), u32(0))));
    var _S1268 : Surface = (surfaceAt((dom_7.hit), (dom_7.x1), (sel_8.random_state)));
    var _S1269 : vec3<f32> = (normalize((dom_7.x0 - dom_7.x1)));
    var _S1270 : f32 = (sign((dot(_S1269, _S1268.smooth_n))));
    var _S1271 : vec3<f32> = _S1268.material.emissive * vec3<f32>(max(_S1270, 0.0f));
    var _S1272 : vec3<f32> = select(_S1271, _S1218, _S1268.skip);
    var _S1273 : vec3<f32> = clamp(sel_8.color + _S1272, vec3<f32>(-65519.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1217), (u32(0)), (vec4<f32>(_S1273, 1.0f)));
    var _S1274 : u32 = (uniforms_uint.is_temporal);
    var _S1275 : bool = _S1274 == u32(1);
    if(_S1275)
    {
        textureStore(compute_out, (_S1217), (u32(1)), (vec4<f32>(dom_7.x1, f32(dom_7.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1276 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1277 : bool = _S1276 != u32(4294967295);
    if(_S1277)
    {
        var _S1278 : vec2<i32> = vec2<i32>((vec2<u32>(_S1276, (_S1276 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1279 : vec3<f32> = vec3<f32>(0.0f);
        var _S1280 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1279, _S1279, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1279, 0.0f, vec4<u32>(u32(0)), _S1279, _S1279));
        var shift_job_0 : ShiftJob = _S1280;
        var _S1281 : u32 = (_S1276 >> (u32(28)));
        var _S1282 : bool = spatialJob_0(_S1278, _S1281, &(shift_job_0));
        var _S1283 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1278), (_S1281), (vec4<u32>((bitcast<vec3<u32>>((_S1283.f))), (bitcast<u32>((_S1283.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1284 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1285 : array<u32, i32(3)>;
    spatialBins_0(_S1284, &(_S1285));
    var _S1286 : array<u32, i32(3)> = _S1285;
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
        var _S1287 : bool = (_S1286[t_17]) == u32(40);
        if(_S1287)
        {
            textureStore(shift_data_out, (_S1284), (t_17), (vec4<u32>(u32(0))));
        }
        var t_18 : u32 = t_17 + u32(1);
        t_17 = t_18;
    }
    queueShifts_0(_S1284, _S1286, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1288 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1288));
    countShifts_0(_S1288, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1289 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1290 : bool = _S1289 != u32(4294967295);
    if(_S1290)
    {
        var _S1291 : vec2<i32> = vec2<i32>((vec2<u32>(_S1289, (_S1289 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1292 : vec2<i32> = storedNeighbor_0(_S1291);
        var _S1293 : u32 = (_S1289 >> (u32(28)));
        var _S1294 : Shift = temporalShiftAt_0(_S1291, _S1292, _S1293);
        textureStore(temporal_shifts_out, (_S1291), (_S1293), (vec4<u32>((bitcast<vec3<u32>>((_S1294.f))), (bitcast<u32>((_S1294.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1295 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1296 : array<u32, i32(3)>;
    temporalBins_0(_S1295, &(_S1296));
    var _S1297 : array<u32, i32(3)> = _S1296;
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
        var _S1298 : bool = (_S1297[t_19]) == u32(40);
        if(_S1298)
        {
            textureStore(temporal_shifts_out, (_S1295), (t_19), (vec4<u32>(u32(0))));
        }
        var t_20 : u32 = t_19 + u32(1);
        t_19 = t_20;
    }
    queueShifts_0(_S1295, _S1297, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1299 : vec2<i32> = vec2<i32>(global_invocation_id_6.xy);
    var _S1300 : array<u32, i32(3)>;
    temporalBins_0(_S1299, &(_S1300));
    countShifts_0(_S1300, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1301 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1302 : vec3<f32> = vec3<f32>(0.0f);
    var _S1303 : Domain = Domain_x24init_0(_S1302, _S1302, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_8 : Domain = _S1303;
    var _S1304 : bool = (currentDomain((_S1301), &(dom_8)));
    var _S1305 : bool = !_S1304;
    if(_S1305)
    {
        var _S1306 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1302, 0.0f, vec4<u32>(u32(0)), _S1302, _S1302);
        storeReservoir(reservoir_temp_out, (_S1301), (_S1306), (dom_8.hit));
        return;
    }
    var _S1307 : Reservoir = (loadReservoir(reservoir_initial, (_S1301)));
    var _S1308 : bool = ((true));
    var _S1309 : bool = ((false));
    var _S1310 : bool;
    if(_S1309)
    {
        _S1310 = true;
    }
    else
    {
        _S1310 = !_S1308;
    }
    var _S1311 : vec2<i32>;
    if(_S1310)
    {
        var _S1312 : vec2<i32> = sampleNeighbor_0(_S1301, _S1307.seed);
        _S1311 = _S1312;
    }
    else
    {
        var _S1313 : vec2<i32> = storedNeighbor_0(_S1301);
        _S1311 = _S1313;
    }
    var _S1314 : bool = (_S1311.x) >= i32(0);
    var r_11 : Reservoir;
    if(_S1314)
    {
        var _S1315 : Reservoir = (loadReservoir(reservoir_prev, (_S1311)));
        var _S1316 : vec4<u32> = (textureLoad(duplication, (_S1311), 0, 0));
        var _S1317 : f32 = (bitcast<f32>((_S1316.x)));
        var _S1318 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1319 : bool = _S1318 == u32(1);
        var _S1320 : f32 = select(0.0f, _S1317, _S1319);
        var _S1321 : f32 = (mix((20.0f), (1.0f), (pow(_S1320, 0.10000000149011612f))));
        var _S1322 : f32 = min(_S1315.c, _S1321);
        var _S1323 : bool = ((false));
        var _S1324 : vec4<f32> = vec4<f32>(_S1315.f, 1.0f);
        var _S1325 : bool = !_S1323;
        if(_S1325)
        {
            _S1310 = _S1308;
        }
        else
        {
            _S1310 = false;
        }
        var to_current_0 : vec4<f32>;
        if(_S1310)
        {
            var _S1326 : vec4<u32> = (textureLoad(temporal_shifts, (_S1301), (u32(0)), 0));
            var _S1327 : vec4<f32> = (bitcast<vec4<f32>>((_S1326)));
            to_current_0 = _S1327;
        }
        else
        {
            if(_S1325)
            {
                var _S1328 : Shift = temporalShiftAt_0(_S1301, _S1311, u32(0));
                var _S1329 : vec4<f32> = vec4<f32>(_S1328.f, _S1328.jac);
                to_current_0 = _S1329;
            }
            else
            {
                to_current_0 = _S1324;
            }
        }
        var own_1 : Domain = _S1303;
        if(_S1323)
        {
            _S1310 = true;
        }
        else
        {
            var _S1330 : bool = ((false));
            var _S1331 : bool = !_S1330;
            if(_S1331)
            {
                _S1310 = (_S1307.w) > 0.0f;
            }
            else
            {
                _S1310 = false;
            }
            if(_S1310)
            {
                var _S1332 : bool = (storedDomain(reservoir_initial, (_S1301), &(own_1)));
                _S1310 = _S1332;
            }
            else
            {
                _S1310 = false;
            }
            if(_S1310)
            {
                var _S1333 : Domain = (previousDomain((_S1311)));
                var _S1334 : bool = sameDomain_0(_S1333, own_1);
                _S1310 = _S1334;
            }
            else
            {
                _S1310 = false;
            }
        }
        var _S1335 : vec4<f32> = vec4<f32>(_S1307.f, 1.0f);
        var _S1336 : bool = !_S1310;
        if(_S1336)
        {
            _S1310 = _S1308;
        }
        else
        {
            _S1310 = false;
        }
        var to_previous_0 : vec4<f32>;
        if(_S1310)
        {
            var _S1337 : vec4<u32> = (textureLoad(temporal_shifts, (_S1301), (u32(1)), 0));
            var _S1338 : vec4<f32> = (bitcast<vec4<f32>>((_S1337)));
            to_previous_0 = _S1338;
        }
        else
        {
            if(_S1336)
            {
                var _S1339 : Shift = temporalShiftAt_0(_S1301, _S1311, u32(1));
                var _S1340 : vec4<f32> = vec4<f32>(_S1339.f, _S1339.jac);
                to_previous_0 = _S1340;
            }
            else
            {
                to_previous_0 = _S1335;
            }
        }
        var _S1341 : f32 = resamplingTarget(_S1307.f);
        var _S1342 : f32 = resamplingTarget(_S1315.f);
        var _S1343 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1302, 0.0f, vec4<u32>(u32(0)), _S1302, _S1302), 0.0f, _S1302, u32(0));
        var sel_9 : Selection = _S1343;
        var _S1344 : u32 = (uniforms_uint.frame);
        var _S1345 : u32 = hash(_S1344);
        var _S1346 : u32 = global_invocation_id_7.x;
        var _S1347 : vec2<u32> = (uniforms_uint.render_size);
        var _S1348 : u32 = stream(_S1345, _S1346 + _S1347.x * global_invocation_id_7.y);
        var _S1349 : u32 = stream(_S1348, u32(194));
        sel_9.random_state = _S1349;
        var _S1350 : f32 = _S1307.c * _S1341;
        var _S1351 : f32 = resamplingTarget(to_previous_0.xyz);
        var _S1352 : f32 = _S1350 / (_S1350 + _S1322 * _S1351);
        var _S1353 : f32 = _S1322 * _S1342;
        var _S1354 : vec3<f32> = to_current_0.xyz;
        var _S1355 : f32 = resamplingTarget(_S1354);
        var _S1356 : f32 = _S1353 / (_S1353 + _S1307.c * _S1355);
        var _S1357 : vec2<f32> = vec2<f32>(_S1352, _S1356);
        offerShifted(&(sel_9), _S1307, Shift_x24init_0(_S1307.f, 1.0f), _S1352);
        offerShifted(&(sel_9), _S1315, Shift_x24init_0(_S1354, to_current_0.w), _S1356);
        var _S1358 : Reservoir = finalize(sel_9, _S1307.c + _S1322);
        r_11 = _S1358;
    }
    else
    {
        r_11 = _S1307;
    }
    storeReservoir(reservoir_temp_out, (_S1301), (r_11), (dom_8.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1359 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1360 : vec3<f32> = vec3<f32>(0.0f);
    var _S1361 : Domain = Domain_x24init_0(_S1360, _S1360, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_9 : Domain = _S1361;
    var _S1362 : bool = (currentDomain((_S1359), &(dom_9)));
    var _S1363 : bool = !_S1362;
    if(_S1363)
    {
        storeReservoir(reservoir_initial_out, (_S1359), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1360, 0.0f, vec4<u32>(u32(0)), _S1360, _S1360)), (dom_9.hit));
        return;
    }
    var _S1364 : u32 = (uniforms_uint.frame);
    var _S1365 : u32 = hash(_S1364);
    var _S1366 : u32 = global_invocation_id_8.x;
    var _S1367 : vec2<u32> = (uniforms_uint.render_size);
    var _S1368 : u32 = global_invocation_id_8.y;
    var _S1369 : u32 = stream(_S1365, _S1366 + _S1367.x * _S1368);
    var _S1370 : vec2<u32> = (uniforms_uint.render_size);
    var _S1371 : u32 = stream(_S1366 + _S1370.x * _S1368, u32(512));
    var _S1372 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1360, 0.0f, vec4<u32>(u32(0)), _S1360, _S1360);
    var _S1373 : Selection = Selection_x24init_0(_S1372, 0.0f, _S1360, u32(0));
    var initial_0 : Selection = _S1373;
    var _S1374 : u32 = stream(_S1369, u32(193));
    initial_0.random_state = _S1374;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1375 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1375)
        {
        }
        else
        {
            break;
        }
        var r_12 : Reservoir = _S1372;
        var _S1376 : u32 = stream(_S1369, i_10);
        r_12.seed = _S1376;
        var _S1377 : u32 = (uniforms_uint.frame);
        var _S1378 : u32 = (uniforms_uint.samples);
        var _S1379 : u32 = _S1377 * _S1378 + i_10;
        var _S1380 : u32 = (insertBits((u32(0)), (u32(1)), (u32(24)), (u32(1))));
        var _S1381 : u32 = (insertBits((_S1380), (((_S1371 + _S1379 * u32(2654435769)) >> (u32(25)))), (u32(25)), (u32(7))));
        r_12.path = _S1381;
        var _S1382 : u32 = (uniforms_uint.samples);
        var _S1383 : Shift = walk_0(dom_9, r_12, false, 1.0f / f32(_S1382), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1384 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1359), (_S1384), (dom_9.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1385 : Random = pcg(state_3);
    var _S1386 : Random = pcg(_S1385.state);
    var _S1387 : f32 = 6.28318548202514648f * _S1385.value;
    var _S1388 : f32 = sqrt(-2.0f * clamp(log(_S1386.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1386.state, _S1388 * cos(_S1387));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1389 : RandomSphere;
    _S1389.state = state_4;
    _S1389.value = value_1;
    return _S1389;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1390 : Random = normal_distribution(state_5);
    var _S1391 : Random = normal_distribution(_S1390.state);
    var _S1392 : Random = normal_distribution(_S1391.state);
    var _S1393 : vec3<f32> = (normalize((vec3<f32>(_S1390.value, _S1391.value, _S1392.value))));
    return RandomSphere_x24init_0(_S1392.state, _S1393);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1394 : vec3<f32> = p1_0 - p0_0;
    var _S1395 : vec3<f32> = p2_0 - p0_0;
    var _S1396 : vec2<f32> = uv1_0 - uv0_0;
    var _S1397 : vec2<f32> = uv2_0 - uv0_0;
    var _S1398 : f32 = _S1396.x;
    var _S1399 : f32 = _S1397.y;
    var _S1400 : f32 = _S1396.y;
    var _S1401 : f32 = _S1397.x;
    var _S1402 : f32 = _S1398 * _S1399 - _S1400 * _S1401;
    var _S1403 : f32 = 1.0f / _S1402;
    var _S1404 : vec3<f32> = vec3<f32>(_S1403);
    var t_21 : vec3<f32> = (_S1394 * vec3<f32>(_S1399) - _S1395 * vec3<f32>(_S1400)) * _S1404;
    var _S1405 : vec3<f32> = (_S1395 * vec3<f32>(_S1398) - _S1394 * vec3<f32>(_S1401)) * _S1404;
    var _S1406 : vec3<f32> = t_21 - n_9 * vec3<f32>(dot(n_9, t_21));
    var _S1407 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_9);
    var _S1408 : bool = (dot(_S1406, _S1406)) > 0.0f;
    var _S1409 : vec3<f32> = select(_S1407, _S1406, _S1408);
    var _S1410 : vec3<f32> = (normalize((_S1409)));
    var _S1411 : bool = (dot(cross(n_9, _S1410), _S1405)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1411)
    {
        var _S1412 : vec3<f32> = ((-(_S1410)));
        t_22 = _S1412;
    }
    else
    {
        t_22 = _S1410;
    }
    var _S1413 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1413, n_9);
}

fn tangentToWorldNormalMap( v_9 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_9)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_2 : vec3<f32>) -> f32
{
    var _S1414 : vec3<f32> = t1_0 - t0_0;
    var _S1415 : vec3<f32> = t2_2 - t0_0;
    var _S1416 : vec3<f32> = t2_2 - t1_0;
    var _S1417 : f32 = min(length(_S1414), min(length(_S1415), length(_S1416)));
    var _S1418 : vec3<f32> = vec3<f32>(distance(position_2, t0_0), distance(position_2, t1_0), distance(position_2, t2_2));
    var _S1419 : vec3<f32> = (normalize((n0_0)));
    var _S1420 : f32 = dot(geometry_n_4, _S1419);
    var _S1421 : vec3<f32> = (normalize((n1_0)));
    var _S1422 : f32 = dot(geometry_n_4, _S1421);
    var _S1423 : vec3<f32> = (normalize((n2_0)));
    var _S1424 : vec3<f32> = acos(abs(vec3<f32>(_S1420, _S1422, dot(geometry_n_4, _S1423))));
    var _S1425 : vec3<f32> = clamp(tan(_S1424), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1418 * _S1425, uvw_0), 0.0f, _S1417 * 0.125f);
}

fn straightThrough( material_24 : Material) -> vec3<f32>
{
    return vec3<f32>((material_24.transmission * (1.0f - material_24.metallic))) * material_24.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_10 : vec3<f32>,  material_25 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1426 : vec3<f32>;
    if((material_25.ior) == 1.0f)
    {
        var _S1427 : vec3<f32> = straightThrough(material_25);
        _S1426 = _S1427;
    }
    else
    {
        _S1426 = vec3<f32>(0.0f);
    }
    return _S1426 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_10 : Domain,  r_13 : Reservoir,  replay_3 : bool,  scale_4 : f32,  sel_10 : ptr<function, Selection>) -> Shift
{
    var _S1428 : Shift = walk_0(dom_10, r_13, replay_3, scale_4, &((*sel_10)));
    return _S1428;
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

