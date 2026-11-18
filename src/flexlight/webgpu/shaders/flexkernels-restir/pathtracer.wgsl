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

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_0 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_0 : vec3<f32>,  velvet_0 : f32,  dispersion_0 : f32) -> Material
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

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S59 : u32 = hash(index_0);
    var _S60 : u32 = hash((seed_1 ^ (_S59)));
    return _S60;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S61 : bool = transmission_1 > 0.0f;
    var _S62 : bool;
    if(_S61)
    {
        _S62 = true;
    }
    else
    {
        _S62 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S63 : f32;
    if(_S62)
    {
        _S63 = 1.0f;
    }
    else
    {
        _S63 = -1.0f;
    }
    return _S63;
}

fn facingRay_0( surface_0 : Surface,  dir_1 : vec3<f32>) -> Surface
{
    var _S64 : f32 = facingSign(surface_0.material.transmission, surface_0.geometry_n, dir_1);
    var _S65 : vec3<f32> = vec3<f32>(_S64);
    return Surface_x24init_0(surface_0.smooth_n * _S65, surface_0.geometry_n * _S65, surface_0.geometry_offset, surface_0.material, surface_0.skip, surface_0.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S66 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S66));
}

fn dispersive( material_1 : Material) -> bool
{
    var _S67 : bool = (material_1.dispersion) > 0.0f;
    var _S68 : bool;
    if(_S67)
    {
        _S68 = (material_1.ior) != 1.0f;
    }
    else
    {
        _S68 = false;
    }
    return _S68;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S69 : Random;
    _S69.state = state_0;
    _S69.value = value_0;
    return _S69;
}

fn pcg( state_1 : u32) -> Random
{
    var _S70 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S71 : u32 = hash(state_1);
    return Random_x24init_0(_S70, f32(_S71) / 4.294967296e+09f);
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
        var _S72 : u32 = (low_0 + high_0 + u32(1)) / u32(2);
        var _S73 : bool = (WAVELENGTH_CDF_0[_S72]) <= u_0;
        if(_S73)
        {
            low_0 = _S72;
        }
        else
        {
            var _S74 : u32 = _S72 - u32(1);
            high_0 = _S74;
        }
    }
    var _S75 : u32 = low_0;
    var _S76 : f32 = WAVELENGTH_CDF_0[low_0 + u32(1)] - WAVELENGTH_CDF_0[low_0];
    return vec2<f32>(0.37999999523162842f + 0.00499999988824129f * (f32(low_0) + (u_0 - WAVELENGTH_CDF_0[_S75]) / _S76), _S76 / 0.00499999988824129f);
}

var<private> WAVELENGTH_WEIGHTS_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f );
fn wavelengthWeights( wavelength_0 : f32) -> vec3<f32>
{
    var _S77 : f32 = clamp((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S78 : u32 = min(u32(_S77), u32(79));
    var _S79 : u32 = u32(3) * _S78;
    var _S80 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S79], WAVELENGTH_WEIGHTS_0[_S79 + u32(1)], WAVELENGTH_WEIGHTS_0[_S79 + u32(2)]);
    var _S81 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S79 + u32(3)], WAVELENGTH_WEIGHTS_0[_S79 + u32(4)], WAVELENGTH_WEIGHTS_0[_S79 + u32(5)]);
    return _S80 + (_S81 - _S80) * vec3<f32>((_S77 - f32(_S78)));
}

fn dispersedIor( ior_1 : f32,  dispersion_1 : f32,  wavelength_1 : f32) -> f32
{
    var _S82 : f32 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    var _S83 : f32 = _S82 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    var _S84 : bool = dispersion_1 > 0.0f;
    var _S85 : f32 = select(0.0f, _S83, _S84);
    return ior_1 + _S85;
}

fn vertexEta( material_2 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S86 : bool = n_dot_v_0 < 0.0f;
    var _S87 : f32 = select(1.0f, material_2.ior, _S86);
    var _S88 : f32 = select(material_2.ior, 1.0f, _S86);
    return vec2<f32>(_S87, _S88);
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S89 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S90 : f32 = eta_i_0 / eta_o_0 * _S89;
    var _S91 : bool = _S90 < 1.0f;
    var kr_0 : f32;
    if(_S91)
    {
        var _S92 : f32 = sqrt(max(0.0f, 1.0f - _S90 * _S90));
        var _S93 : f32 = eta_o_0 * cos_theta_0;
        var _S94 : f32 = eta_i_0 * _S92;
        var _S95 : f32 = (_S93 - _S94) / (_S93 + _S94);
        var _S96 : f32 = eta_i_0 * cos_theta_0;
        var _S97 : f32 = eta_o_0 * _S92;
        var _S98 : f32 = (_S96 - _S97) / (_S96 + _S97);
        var _S99 : f32 = (_S95 * _S95 + _S98 * _S98) / 2.0f;
        kr_0 = _S99;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn neeDecision( material_3 : Material,  n_dot_v_1 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> bool
{
    var _S100 : f32 = fresnel(abs(n_dot_v_1), eta_i_1, eta_o_1);
    var _S101 : vec3<f32> = (mix((vec3<f32>(_S100)), (material_3.albedo), (material_3.metallic)));
    var _S102 : f32 = rgb_to_greyscale(_S101);
    var _S103 : f32 = max((1.0f - _S102) * (1.0f - material_3.metallic) * (1.0f - material_3.transmission), 0.0f);
    var _S104 : bool = _S103 > 0.03999999910593033f;
    var _S105 : bool;
    if(_S104)
    {
        _S105 = true;
    }
    else
    {
        _S105 = (material_3.roughness) > 0.20000000298023224f;
    }
    return _S105;
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
    var _S106 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S107 : bool = cos_a_0 > cos_b_0;
    var _S108 : f32 = select(_S106, 1.0f, _S107);
    return _S108;
}

fn importance( node_0 : LightBounds,  p_3 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S109 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S110 : vec3<f32> = node_0.high - node_0.low;
    var _S111 : vec3<f32> = p_3 - _S109;
    var _S112 : vec3<f32> = (normalize((_S111)));
    var _S113 : f32 = dot(_S111, _S111);
    var _S114 : f32 = dot(_S110, _S110) / 4.0f;
    var _S115 : f32 = abs(dot(node_0.w, _S112));
    var _S116 : f32 = sine(node_0.cos_theta_o);
    var _S117 : f32 = sqrt(max(1.0f - _S114 / _S113, 0.0f));
    var _S118 : bool = _S113 < _S114;
    var _S119 : f32 = select(_S117, -1.0f, _S118);
    var _S120 : f32 = sine(_S119);
    var _S121 : f32 = sine(_S115);
    var _S122 : f32 = cosSubClamped(_S121, _S115, _S116, node_0.cos_theta_o);
    var _S123 : f32 = sine(_S115);
    var _S124 : f32 = _S123 * node_0.cos_theta_o - _S115 * _S116;
    var _S125 : bool = _S115 > (node_0.cos_theta_o);
    var _S126 : f32 = select(_S124, 0.0f, _S125);
    var _S127 : f32 = cosSubClamped(_S126, _S122, _S120, _S119);
    var _S128 : bool = _S127 <= 0.0f;
    if(_S128)
    {
        return 0.0f;
    }
    var _S129 : f32 = - dot(_S112, normal_0);
    var _S130 : f32 = node_0.phi * _S127 / max(_S113, length(_S110) / 2.0f);
    var _S131 : f32 = sine(_S129);
    var _S132 : f32 = cosSubClamped(_S131, _S129, _S120, _S119);
    var _S133 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S134 : f32 = select(_S132, 1.0f, _S133);
    return max(_S130 * _S134, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_4 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S135 : f32 = importance(first_0, p_4, normal_1);
    var _S136 : f32 = importance(second_0, p_4, normal_1);
    var _S137 : vec2<f32> = vec2<f32>(_S135, _S136);
    var _S138 : f32 = _S137[child_0] / (_S135 + _S136);
    var _S139 : bool = (_S137[child_0]) > 0.0f;
    var _S140 : f32 = select(0.0f, _S138, _S139);
    return _S140;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_5 : vec3<f32>) -> f32
{
    var _S141 : vec3<f32> = center_0 - p_5;
    var _S142 : f32 = radius_0 * radius_0 / dot(_S141, _S141);
    var _S143 : bool = _S142 >= 1.0f;
    if(_S143)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S142)) / (6.28318548202514648f * _S142);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_2 : vec3<f32>,  smooth_n_2 : vec3<f32>,  start_1 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S144 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S145 : vec2<u32> = _S144.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S145;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S146 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S146.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S147 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S148 : u32 = n_0 + u32(1);
        var _S149 : LightBounds = (lightBounds((_S148)));
        var _S150 : LightBounds = (lightBounds((_S147)));
        var _S151 : u32 = trail_0.x;
        var _S152 : u32 = (_S151 & (u32(1)));
        var _S153 : f32 = childShare(_S149, _S150, origin_2, smooth_n_2, _S152);
        var probability_2 : f32 = probability_1 * _S153;
        var _S154 : bool = _S152 == u32(1);
        var _S155 : u32 = select(_S148, _S147, _S154);
        var _S156 : u32 = trail_0.y;
        var _S157 : vec2<u32> = vec2<u32>((((_S151 >> (u32(1)))) | (((_S156 << (u32(31)))))), (_S156 >> (u32(1))));
        n_0 = _S155;
        trail_0 = _S157;
        probability_1 = probability_2;
    }
    var _S158 : bool = (((_S144).z == (n_0)));
    var _S159 : bool = !_S158;
    var _S160 : bool;
    if(_S159)
    {
        _S160 = true;
    }
    else
    {
        var _S161 : LightBounds = (lightBounds((n_0)));
        var _S162 : f32 = importance(_S161, origin_2, smooth_n_2);
        _S160 = !(_S162 > 0.0f);
    }
    if(_S160)
    {
        _S160 = true;
    }
    else
    {
        var _S163 : bool = (dot(smooth_n_2, smooth_n_2)) > 0.0f;
        if(_S163)
        {
            _S160 = !((dot(smooth_n_2, light_point_0 - origin_2)) > 0.0f);
        }
        else
        {
            _S160 = false;
        }
    }
    if(_S160)
    {
        return 0.0f;
    }
    var _S164 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S165 : bool = (_S164.x) == u32(2);
    if(_S165)
    {
        var _S166 : u32 = _S164.y;
        var _S167 : Light = (lights[(_S166)]);
        var _S168 : Light = (lights[(_S166)]);
        var _S169 : f32 = sphereDensity(_S167.position, _S168.variance, start_1);
        return probability_1 * _S169;
    }
    var _S170 : u32 = _S164.y;
    var _S171 : u32 = ((instance_uint[(_S170) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S172 : mat3x3<f32> = (worldTriangle((_S170), (_S171 + _S164.z)));
    var _S173 : f32 = solidAngle(probability_1, cross(_S172[i32(1)] - _S172[i32(0)], _S172[i32(2)] - _S172[i32(0)]), light_point_0 - start_1);
    return _S173;
}

fn powerHeuristic( a_0 : f32,  b_0 : f32) -> f32
{
    var _S174 : f32 = 1.0f / (1.0f + b_0 / a_0 * (b_0 / a_0));
    var _S175 : bool = b_0 > 0.0f;
    var _S176 : f32 = select(1.0f, _S174, _S175);
    return _S176;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S177 : u32 = (lightSlot((hit_1)));
    var _S178 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S177, light_point_1);
    var _S179 : f32 = powerHeuristic(vertex_0.pdf, _S178);
    return _S179;
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
    var _S180 : TreeSample;
    _S180.dir = dir_2;
    _S180.radiance = radiance_1;
    _S180.density = density_0;
    _S180.random_state = random_state_2;
    return _S180;
}

fn isTranslucent_0( material_4 : Material) -> bool
{
    var _S181 : f32 = rgb_to_greyscale(material_4.translucent);
    return _S181 > 0.0f;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_6 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S182 : f32 = importance(first_1, p_6, normal_3);
    var _S183 : f32 = importance(second_1, p_6, normal_3);
    var _S184 : vec2<f32> = vec2<f32>(_S182, _S183);
    var _S185 : bool = _S182 == 0.0f;
    var _S186 : bool;
    if(_S185)
    {
        _S186 = _S183 == 0.0f;
    }
    else
    {
        _S186 = false;
    }
    if(_S186)
    {
        return u32(2);
    }
    var _S187 : f32 = _S182 + _S183;
    var _S188 : bool = _S183 > 0.0f;
    if(_S188)
    {
        _S186 = ((*pick_0) * _S187) >= _S182;
    }
    else
    {
        _S186 = false;
    }
    var _S189 : u32 = select(u32(0), u32(1), _S186);
    var _S190 : f32 = min(((*pick_0) * _S187 - f32(_S189) * _S182) / _S184[_S189], 0.99999994039535522f);
    (*pick_0) = _S190;
    var _S191 : f32 = (*probability_3) * (_S184[_S189] / _S187);
    (*probability_3) = _S191;
    return _S189;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S192 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S192)
    {
        const _S193 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S193;
    }
    else
    {
        a_2 = a_1;
    }
    var _S194 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S195 : vec3<f32> = cross(n_1, _S194);
    return vec3<f32>(v_0.x) * _S194 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S195;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_7 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S196 : vec3<f32> = center_1 - p_7;
    var _S197 : f32 = radius_1 * radius_1 / dot(_S196, _S196);
    var _S198 : f32 = u1_0 * _S197 / (1.0f + sqrt(max(1.0f - _S197, 0.0f)));
    var _S199 : f32 = 2.0f * u1_0;
    var _S200 : bool = _S197 >= 1.0f;
    var _S201 : f32 = select(_S198, _S199, _S200);
    var _S202 : f32 = sqrt(max(_S201 * (2.0f - _S201), 0.0f));
    var _S203 : f32 = 6.28318548202514648f * u2_0;
    var _S204 : vec3<f32> = vec3<f32>(_S202 * cos(_S203), 1.0f - _S201, _S202 * sin(_S203));
    var _S205 : vec3<f32> = (normalize((_S196)));
    var _S206 : vec3<f32> = tangentToWorld(_S204, _S205);
    return _S206;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_0 : Ray,  max_len_0 : f32) -> f32
{
    var _S207 : vec3<f32> = center_2 - ray_0.origin;
    var _S208 : f32 = dot(_S207, ray_0.unit_direction);
    var _S209 : f32 = dot(_S207, _S207) - _S208 * _S208;
    var _S210 : f32 = radius_3 * radius_3;
    var _S211 : bool = _S209 > _S210;
    if(_S211)
    {
        return 4.294967296e+09f;
    }
    var _S212 : f32 = sqrt(_S210 - _S209);
    var _S213 : f32 = _S208 - _S212;
    var _S214 : f32 = _S208 + _S212;
    var _S215 : bool = _S213 > 0.0000152587890625f;
    var _S216 : bool;
    if(_S215)
    {
        _S216 = _S213 < max_len_0;
    }
    else
    {
        _S216 = false;
    }
    if(_S216)
    {
        return _S213;
    }
    var _S217 : bool = _S214 > 0.0000152587890625f;
    if(_S217)
    {
        _S216 = _S214 < max_len_0;
    }
    else
    {
        _S216 = false;
    }
    if(_S216)
    {
        return _S214;
    }
    return 4.294967296e+09f;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_3 : vec3<f32>,  smooth_n_3 : vec3<f32>,  geometry_offset_1 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S218 : vec3<f32> = (normalize((light_dir_0)));
    var _S219 : bool = (dot(smooth_n_3, _S218)) < 0.0f;
    if(_S219)
    {
        return vec3<f32>(0.0f);
    }
    var _S220 : vec3<f32> = origin_3 + vec3<f32>(geometry_offset_1) * smooth_n_3;
    var _S221 : Ray = Ray_x24init_0(_S220, _S218);
    var _S222 : f32 = shadowLength(light_dir_0);
    var _S223 : vec3<f32> = (shadowTransmittance((_S221), (_S222)));
    return _S223;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_4 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_2 : f32,  sided_0 : bool,  init_random_state_0 : u32) -> TreeSample
{
    var _S224 : Random = pcg(init_random_state_0);
    var _S225 : Random = pcg(_S224.state);
    var _S226 : Random = pcg(_S225.state);
    var _S227 : vec3<f32> = vec3<f32>(0.0f);
    var _S228 : TreeSample = TreeSample_x24init_0(_S227, _S227, 0.0f, _S226.state);
    var sample_0 : TreeSample = _S228;
    var _S229 : vec3<f32> = select(smooth_n_4, _S227, sided_0);
    var _S230 : vec3<f32> = vec3<f32>(geometry_offset_2);
    var _S231 : vec3<f32> = origin_4 + _S230 * smooth_n_4;
    var pick_1 : f32 = _S224.value;
    var probability_4 : f32 = 1.0f;
    var n_2 : u32 = u32(0);
    loop
    {
        var _S232 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
        if((_S232.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S233 : u32 = (access_light_tree(3u + 4u * (n_2)).w);
        var _S234 : u32 = n_2 + u32(1);
        var _S235 : LightBounds = (lightBounds((_S234)));
        var _S236 : LightBounds = (lightBounds((_S233)));
        var _S237 : u32 = pickChild(_S235, _S236, origin_4, _S229, &(pick_1), &(probability_4));
        var _S238 : bool = _S237 > u32(1);
        if(_S238)
        {
            return sample_0;
        }
        var _S239 : bool = _S237 == u32(1);
        var _S240 : u32 = select(_S234, _S233, _S239);
        n_2 = _S240;
    }
    var _S241 : bool = n_2 == u32(0);
    var _S242 : bool;
    if(_S241)
    {
        var _S243 : LightBounds = (lightBounds((u32(0))));
        var _S244 : f32 = importance(_S243, origin_4, _S229);
        _S242 = !(_S244 > 0.0f);
    }
    else
    {
        _S242 = false;
    }
    if(_S242)
    {
        return sample_0;
    }
    var _S245 : vec4<u32> = (access_light_tree(4u + 4u * (n_2)));
    var _S246 : bool = (_S245.x) == u32(2);
    var start_2 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S246)
    {
        var _S247 : Light = (lights[(_S245.y)]);
        if(sided_0)
        {
            var _S248 : f32 = (sign((dot(geometry_n_1, _S247.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_4 * vec3<f32>(_S248);
            var _S249 : vec3<f32> = origin_4 + _S230 * lift_n_1;
            start_2 = _S249;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_2 = _S231;
            lift_n_0 = smooth_n_4;
        }
        var _S250 : bool = (_S247.variance) == 0.0f;
        if(_S250)
        {
            var _S251 : vec3<f32> = _S247.position - start_2;
            var _S252 : vec3<f32> = (normalize((_S251)));
            sample_0.dir = _S252;
            var _S253 : vec3<f32> = _S247.color * vec3<f32>(_S247.intensity) / vec3<f32>((dot(_S251, _S251) * probability_4));
            sample_0.radiance = _S253;
            shadow_1 = _S251;
        }
        else
        {
            var _S254 : vec3<f32> = sampleSphere(_S247.position, _S247.variance, start_2, _S225.value, _S226.value);
            sample_0.dir = _S254;
            var _S255 : f32 = sphereDensity(_S247.position, _S247.variance, start_2);
            var _S256 : f32 = probability_4 * _S255;
            sample_0.density = _S256;
            var _S257 : vec3<f32> = pointLightRadiance(_S247.color, _S247.intensity, _S247.variance);
            var _S258 : vec3<f32> = _S257 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S258;
            var _S259 : f32 = raySphere_0(_S247.position, _S247.variance, Ray_x24init_0(start_2, sample_0.dir), 4.294967296e+09f);
            var _S260 : vec3<f32> = sample_0.dir * vec3<f32>(_S259);
            shadow_1 = _S260;
        }
    }
    else
    {
        var _S261 : u32 = _S245.y;
        var _S262 : u32 = ((instance_uint[(_S261) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S263 : u32 = _S262 + _S245.z;
        var _S264 : mat3x3<f32> = (worldTriangle((_S261), (_S263)));
        var _S265 : f32 = sqrt(_S225.value);
        var _S266 : vec2<f32> = vec2<f32>(_S265 * (1.0f - _S226.value), _S265 * _S226.value);
        var _S267 : vec3<f32> = (((_S264) * (vec3<f32>(1.0f - _S265, _S266))));
        if(sided_0)
        {
            var _S268 : f32 = (sign((dot(geometry_n_1, _S267 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_4 * vec3<f32>(_S268);
            var _S269 : vec3<f32> = origin_4 + _S230 * lift_n_2;
            start_2 = _S269;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S270 : bool = !((dot(smooth_n_4, _S267 - origin_4)) > 0.0f);
            if(_S270)
            {
                return sample_0;
            }
            start_2 = _S231;
            lift_n_0 = smooth_n_4;
        }
        var _S271 : Surface = (surfaceAt((Hit_x24init_0(_S266, _S261, _S263, u32(0), 0.0f)), (_S267), (_S226.state)));
        sample_0.random_state = _S271.random_state;
        var _S272 : vec3<f32> = _S267 - start_2;
        var _S273 : vec3<f32> = (normalize((_S272)));
        sample_0.dir = _S273;
        var _S274 : f32 = solidAngle(probability_4, cross(_S264[i32(1)] - _S264[i32(0)], _S264[i32(2)] - _S264[i32(0)]), _S272);
        sample_0.density = _S274;
        var _S275 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S271.smooth_n))));
        var _S276 : vec3<f32> = _S271.material.emissive * vec3<f32>(max(_S275, 0.0f));
        var _S277 : vec3<f32> = select(_S276, _S227, _S271.skip);
        var _S278 : vec3<f32> = _S277 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S278;
        shadow_1 = _S272;
    }
    var _S279 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_2, shadow_1);
    var _S280 : vec3<f32> = sample_0.radiance * _S279;
    var _S281 : bool = (all((_S279 == _S227)));
    var _S282 : vec3<f32> = select(_S280, _S227, _S281);
    sample_0.radiance = _S282;
    return sample_0;
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_1 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S283 : AnisotropicFrame;
    _S283.tangent = tangent_1;
    _S283.alphas = alphas_0;
    return _S283;
}

fn anisotropicFrame( material_5 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S284 : f32 = material_5.roughness;
    var _S285 : f32 = _S284 * _S284;
    var _S286 : bool = (material_5.anisotropy) == 0.0f;
    var _S287 : bool;
    if(_S286)
    {
        _S287 = true;
    }
    else
    {
        _S287 = !(_S285 > 0.0f);
    }
    if(_S287)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S288 : vec3<f32> = material_5.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_5.tangent));
    var _S289 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S290 : bool = (dot(_S288, _S288)) > 0.0f;
    var _S291 : vec3<f32> = select(_S289, _S288, _S290);
    var _S292 : vec3<f32> = (normalize((_S291)));
    var _S293 : f32 = 6.28318548202514648f * material_5.anisotropic_rotation;
    var _S294 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_5.anisotropy));
    var _S295 : f32 = 1.0f / _S294;
    var _S296 : bool = (material_5.anisotropy) < 0.0f;
    var _S297 : f32 = select(_S294, _S295, _S296);
    return AnisotropicFrame_x24init_0(_S292 * vec3<f32>(cos(_S293)) + cross(n_i_0, _S292) * vec3<f32>(sin(_S293)), vec2<f32>(_S285 / _S297, _S285 * _S297));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_1 : f32) -> SheenProfile
{
    var _S298 : SheenProfile;
    _S298.on = on_0;
    _S298.albedo = albedo_1;
    return _S298;
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_6 : Material) -> SheenProfile
{
    var _S299 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S300 : f32 = rgb_to_greyscale(material_6.sheen);
    var _S301 : bool = _S300 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S301)
    {
        var _S302 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S303 : u32 = min(u32(_S302), u32(22));
        var _S304 : f32 = sqrt(0.05000000074505806f);
        var _S305 : f32 = sqrt(0.10000000149011612f);
        var _S306 : bool = (material_6.velvet) > 0.0f;
        var _S307 : f32 = select(_S304, _S305, _S306);
        var _S308 : f32 = (clamp(sqrt(max(material_6.sheen_roughness, 0.0f)), _S307, 1.0f) - _S307) / (1.0f - _S307) * 23.0f;
        var _S309 : u32 = min(u32(_S308), u32(22));
        var _S310 : u32 = _S303 * u32(24) + _S309;
        var _S311 : f32 = _S302 - f32(_S303);
        var _S312 : f32 = _S308 - f32(_S309);
        if(_S306)
        {
            var _S313 : u32 = _S310 + u32(24);
            var _S314 : f32 = VELVET_ALBEDO_0[_S310] + (VELVET_ALBEDO_0[_S313] - VELVET_ALBEDO_0[_S310]) * _S311;
            var _S315 : u32 = _S310 + u32(1);
            var _S316 : f32 = VELVET_ALBEDO_0[_S315] + (VELVET_ALBEDO_0[_S313 + u32(1)] - VELVET_ALBEDO_0[_S315]) * _S311;
            var _S317 : SheenProfile = SheenProfile_x24init_0(true, _S314 + (_S316 - _S314) * _S312);
            profile_0 = _S317;
        }
        else
        {
            var _S318 : u32 = _S310 + u32(24);
            var _S319 : f32 = SHEEN_ALBEDO_0[_S310] + (SHEEN_ALBEDO_0[_S318] - SHEEN_ALBEDO_0[_S310]) * _S311;
            var _S320 : u32 = _S310 + u32(1);
            var _S321 : f32 = SHEEN_ALBEDO_0[_S320] + (SHEEN_ALBEDO_0[_S318 + u32(1)] - SHEEN_ALBEDO_0[_S320]) * _S311;
            var _S322 : SheenProfile = SheenProfile_x24init_0(true, exp(_S319 + (_S321 - _S319) * _S312));
            profile_0 = _S322;
        }
    }
    else
    {
        profile_0 = _S299;
    }
    return profile_0;
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
     sheen : vec3<f32>,
     p_sheen_velvet : f32,
     view : vec3<f32>,
     tangent : vec3<f32>,
     alphas : vec2<f32>,
     visible : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_1 : vec3<f32>,  p_sheen_velvet_0 : f32,  view_0 : vec3<f32>,  tangent_2 : vec3<f32>,  alphas_1 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S323 : BSDFLobes;
    _S323.v_dot_h = v_dot_h_0;
    _S323.n_dot_h = n_dot_h_0;
    _S323.refracted = refracted_0;
    _S323.F = F_0;
    _S323.F_greyscale = F_greyscale_0;
    _S323.reflect_weight = reflect_weight_0;
    _S323.diffuse_weight = diffuse_weight_0;
    _S323.refract_weight = refract_weight_0;
    _S323.p_diffuse = p_diffuse_0;
    _S323.p_reflect = p_reflect_0;
    _S323.p_refract = p_refract_0;
    _S323.translucent_share = translucent_share_0;
    _S323.sheen = sheen_1;
    _S323.p_sheen_velvet = p_sheen_velvet_0;
    _S323.view = view_0;
    _S323.tangent = tangent_2;
    _S323.alphas = alphas_1;
    _S323.visible = visible_0;
    return _S323;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_4 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_4), dot(w_1, cross(n_3, t_4)), dot(w_1, n_3));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S324 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S325 : f32 = _S324.x;
    var _S326 : f32 = _S324.y;
    var _S327 : f32 = _S325 * _S325 + _S326 * _S326;
    const _S328 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S329 : vec3<f32> = vec3<f32>(- _S326, _S325, 0.0f);
    var _S330 : f32 = (inverseSqrt((_S327)));
    var _S331 : vec3<f32> = _S329 * vec3<f32>(_S330);
    var _S332 : bool = _S327 > 0.0f;
    var _S333 : vec3<f32> = select(_S328, _S331, _S332);
    var _S334 : vec3<f32> = cross(_S324, _S333);
    var _S335 : f32 = sqrt(U1_0);
    var _S336 : f32 = 6.28318548202514648f * U2_0;
    var _S337 : f32 = _S335 * cos(_S336);
    var t2_0 : f32 = _S335 * sin(_S336);
    var _S338 : f32 = 0.5f * (1.0f + _S324.z);
    var t2_1 : f32 = (1.0f - _S338) * sqrt(max(0.0f, 1.0f - _S337 * _S337)) + _S338 * t2_0;
    var _S339 : vec3<f32> = vec3<f32>(_S337) * _S333 + vec3<f32>(t2_1) * _S334;
    var _S340 : f32 = ((_S337));
    var _S341 : f32 = ((_S337));
    var _S342 : vec3<f32> = _S339 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S340 * _S341 - t2_1 * t2_1))) * _S324;
    var _S343 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S342.x, alpha_0 * _S342.y, max(0.0f, _S342.z)))));
    return _S343;
}

fn worldToTangent( v_2 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S344 : bool = (abs(dot(n_4, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S344)
    {
        const _S345 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S345;
    }
    else
    {
        a_4 = a_3;
    }
    var _S346 : vec3<f32> = (normalize((cross(n_4, a_4))));
    var _S347 : vec3<f32> = cross(n_4, _S346);
    return vec3<f32>(dot(v_2, _S346), dot(v_2, n_4), dot(v_2, _S347));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_3 : ptr<function, u32>) -> vec3<f32>
{
    var _S348 : Random = pcg((*random_state_3));
    var _S349 : Random = pcg(_S348.state);
    (*random_state_3) = _S349.state;
    var _S350 : f32 = frame_0.alphas.x;
    var _S351 : bool = _S350 > 0.0f;
    if(_S351)
    {
        var _S352 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S353 : f32 = frame_0.alphas.y;
        var _S354 : vec3<f32> = (normalize((vec3<f32>(_S350 * _S352.x, _S353 * _S352.y, _S352.z))));
        var _S355 : vec3<f32> = sampleGGXVNDF(_S354, 1.0f, _S348.value, _S349.value);
        var _S356 : vec3<f32> = (normalize((vec3<f32>(_S350 * _S355.x, _S353 * _S355.y, _S355.z))));
        return vec3<f32>(_S356.x) * frame_0.tangent + vec3<f32>(_S356.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S356.z) * n_i_2;
    }
    var _S357 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S358 : vec3<f32> = sampleGGXVNDF(_S357.xzy, alpha_1, _S348.value, _S349.value);
    var _S359 : vec3<f32> = _S358.xzy;
    var _S360 : vec3<f32> = tangentToWorld(_S359, n_i_2);
    return _S360;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_7 : Material,  random_state_4 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_4;
    var _S361 : vec3<f32> = ((-(in_dir_0)));
    var _S362 : f32 = (sign((dot(n_5, _S361))));
    var _S363 : f32 = material_7.roughness;
    var _S364 : vec3<f32> = sampleHalfVector(_S361, n_5 * vec3<f32>(_S362), _S363 * _S363, frame_1, &(state_2));
    return _S364;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_6 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S365 : vec3<f32> = ((-(in_dir_1)));
    var _S366 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S365 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S367 : vec3<f32> = (normalize((_S366)));
    var _S368 : f32 = (sign((dot(n_6, _S365))));
    var _S369 : f32 = (sign((dot(_S366, n_6 * vec3<f32>(_S368)))));
    return _S367 * vec3<f32>(_S369);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S370 : vec3<f32> = ((-(in_dir_2)));
    var _S371 : vec3<f32> = (normalize((_S370 + out_dir_1)));
    return _S371;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S372 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S372 / (_S372 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S372)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S373 : f32 = alphas_3.x;
    var _S374 : f32 = h_0.x / _S373;
    var _S375 : f32 = alphas_3.y;
    var _S376 : f32 = h_0.y / _S375;
    var _S377 : f32 = h_0.z;
    var _S378 : f32 = _S374 * _S374 + _S376 * _S376 + _S377 * _S377;
    return 1.0f / max(3.14159274101257324f * _S373 * _S375 * _S378 * _S378, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_8 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S379 : f32 = dot(ggx_n_0, v_4);
    var _S380 : f32 = dot(n_i_3, ggx_n_0);
    var _S381 : f32 = eta_i_3 / eta_o_3;
    var _S382 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S381))));
    var _S383 : f32 = min(sqrt(material_8.specular_level) * abs(eta_i_3 - eta_o_3) / (eta_i_3 + eta_o_3), 0.9999847412109375f);
    var _S384 : f32 = _S383 * _S383;
    var _S385 : f32 = (1.0f + _S383) / (1.0f - _S383);
    var _S386 : f32 = abs(_S379);
    var _S387 : bool = eta_i_3 > eta_o_3;
    var sheen_component_0 : f32;
    if(_S387)
    {
        sheen_component_0 = _S385;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S387)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S385;
    }
    var _S388 : f32 = fresnel(_S386, sheen_component_0, visible_1);
    var _S389 : bool = (eta_i_3 * eta_i_3 * (1.0f - _S379 * _S379)) >= (eta_o_3 * eta_o_3);
    var _S390 : vec3<f32>;
    if(_S389)
    {
        _S390 = vec3<f32>(1.0f);
    }
    else
    {
        var _S391 : vec3<f32> = material_8.specular_tint * vec3<f32>(_S384);
        _S390 = _S391 + (vec3<f32>(1.0f) - _S391) * vec3<f32>((_S388 - _S384)) / vec3<f32>((1.0f - _S384));
    }
    var _S392 : vec3<f32> = vec3<f32>(1.0f);
    var _S393 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_2 : vec3<f32>;
    var view_1 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S394 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S395 : vec3<f32> = vec3<f32>(1.0f) - material_8.sheen * vec3<f32>(_S394);
        var _S396 : f32 = rgb_to_greyscale(material_8.sheen);
        var _S397 : f32 = _S396 * _S394;
        var _S398 : vec3<f32> = material_8.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S395;
        sheen_component_0 = _S397;
        sheen_2 = _S398;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S392;
        sheen_component_0 = 0.0f;
        sheen_2 = _S393;
        view_1 = _S393;
    }
    var _S399 : f32 = frame_2.alphas.x;
    var _S400 : f32 = sqrt(min(_S399, frame_2.alphas.y));
    var _S401 : bool = _S399 > 0.0f;
    var _S402 : f32 = select(material_8.roughness, _S400, _S401);
    var _S403 : f32 = _S402 * _S402;
    var _S404 : f32 = pow(_S403, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S403) / (1.0f + 1.28094995021820068f * _S403);
    var _S405 : bool = _S403 > 0.0f;
    var _S406 : f32 = select(0.0f, _S404, _S405);
    var _S407 : f32 = clamp(dot(n_i_3, v_4), 0.0f, 1.0f);
    var _S408 : f32 = _S403 * _S402;
    var _S409 : f32 = min(1.00064504146575928f - _S402 * (0.00375499995425344f + _S407 * (-0.04133399948477745f + _S407 * (-0.90938502550125122f + _S407 * 0.35275399684906006f))) - _S403 * (0.27602800726890564f + _S407 * (1.27023398876190186f + _S407 * 0.04740000143647194f)) - _S408 * (0.31452900171279907f - _S407 * 0.34830701351165771f) + _S408 * _S402 * 0.27229699492454529f, 1.0f);
    var _S410 : vec3<f32> = vec3<f32>(1.0f);
    var _S411 : vec3<f32> = min(_S410 / (_S410 - material_8.albedo * vec3<f32>(_S406)), vec3<f32>((1.0f / max(_S409, 0.0000152587890625f))));
    var _S412 : vec3<f32> = (mix((_S390), (material_8.albedo * _S411), (material_8.metallic)));
    var F_1 : vec3<f32> = _S412 * scale_0;
    var _S413 : f32 = rgb_to_greyscale(F_1);
    var _S414 : f32 = 1.0f - material_8.metallic;
    var _S415 : vec3<f32> = _S410 - _S390;
    var _S416 : vec3<f32> = vec3<f32>(((1.0f - material_8.transmission) * _S414)) * _S415 * scale_0;
    var _S417 : vec3<f32> = vec3<f32>((material_8.transmission * _S414)) * _S415 * scale_0;
    var _S418 : f32 = max(_S413, 0.0f);
    var _S419 : f32 = rgb_to_greyscale(_S416);
    var _S420 : f32 = max(_S419, 0.0f);
    var _S421 : f32 = rgb_to_greyscale(_S417);
    var _S422 : f32 = (sign((length(_S382))));
    var _S423 : f32 = max(_S421 * _S422, 0.0f);
    var _S424 : f32 = _S418 + _S420 + _S423;
    var _S425 : f32 = min(sheen_component_0, 1.0f);
    var _S426 : bool = sheen_component_0 > 0.0f;
    var _S427 : bool;
    if(_S426)
    {
        _S427 = !(_S424 > 0.0f);
    }
    else
    {
        _S427 = false;
    }
    var _S428 : f32 = select(_S425, 1.0f, _S427);
    var _S429 : f32 = (1.0f - _S428) / max(_S424, 0.0000152587890625f);
    var _S430 : f32 = _S420 * _S429;
    var _S431 : f32 = _S418 * _S429;
    var _S432 : f32 = _S423 * _S429;
    if(_S401)
    {
        var _S433 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S434 : f32 = anisotropicG1(_S433, frame_2.alphas);
        var _S435 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S436 : f32 = anisotropicD(_S435, frame_2.alphas);
        var _S437 : f32 = _S434 * _S436;
        visible_1 = _S437;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S379, _S380, _S382, F_1, _S413, 1.0f, _S416, _S417, _S430, _S431, _S432, 0.0f, sheen_2, _S428, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_9 : Material) -> f32
{
    var _S438 : f32 = rgb_to_greyscale(material_9.translucent);
    var _S439 : f32 = rgb_to_greyscale(material_9.albedo);
    var _S440 : f32 = _S438 / (_S439 + _S438);
    var _S441 : bool = _S438 > 0.0f;
    var _S442 : f32 = select(0.0f, _S440, _S441);
    return _S442;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S443 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S444 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S445 : f32 = 1.0f - lobes_0.translucent_share;
    var _S446 : bool = n_i_dot_l_0 < 0.0f;
    var _S447 : f32 = select(_S445, lobes_0.translucent_share, _S446);
    var _S448 : f32 = _S444 * _S447;
    var _S449 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S450 : f32 = select(_S443, _S448, _S449);
    var _S451 : bool = n_i_dot_v_0 > 0.0f;
    var _S452 : f32 = select(0.0f, _S450, _S451);
    return _S452;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_10 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S453 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S454 : vec3<f32> = select(material_10.albedo, material_10.translucent, _S453);
    var _S455 : f32 = 1.0f - lobes_1.translucent_share;
    var _S456 : f32 = select(_S455, lobes_1.translucent_share, _S453);
    var _S457 : vec3<f32> = _S454 / vec3<f32>(_S456);
    var _S458 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S459 : vec3<f32> = select(material_10.albedo, _S457, _S458);
    return lobes_1.diffuse_weight * _S459 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S460 : f32 = alpha_4 * alpha_4;
    var _S461 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S460 + (1.0f - _S460) * n_dot_x_0 * n_dot_x_0));
    var _S462 : bool = alpha_4 > 0.0f;
    var _S463 : f32 = select(1.0f, _S461, _S462);
    return _S463;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S464 : f32 = alpha_5 * alpha_5;
    var _S465 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S464 * n_dot_h_1 * n_dot_h_1;
    return _S464 / max(3.14159274101257324f * _S465 * _S465, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S466 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S467 : f32 = _S466 * lobes_2.v_dot_h;
    var _S468 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S469 : f32 = _S467 * _S468 / n_i_dot_v_1;
    var _S470 : bool = alpha_6 > 0.0f;
    var _S471 : bool;
    if(_S470)
    {
        _S471 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S471 = false;
    }
    if(_S471)
    {
        _S471 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S471 = false;
    }
    if(_S471)
    {
        _S471 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S471 = false;
    }
    var _S472 : f32 = select(0.0f, _S469, _S471);
    var _S473 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S473)
    {
        var _S474 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S475 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S475)
        {
            _S471 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S471 = false;
        }
        if(_S471)
        {
            _S471 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S471 = false;
        }
        var _S476 : f32 = select(0.0f, _S474, _S471);
        pdf_h_0 = _S476;
    }
    else
    {
        pdf_h_0 = _S472;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S477 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S478 : f32 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    var _S479 : f32 = lobes_3.p_refract * _S477 * eta_o_5 * eta_o_5 * abs(l_dot_h_1) / (_S478 * _S478);
    var _S480 : bool = eta_i_5 != eta_o_5;
    var _S481 : bool;
    if(_S480)
    {
        _S481 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S481 = false;
    }
    var _S482 : f32 = select(0.0f, _S479, _S481);
    return _S482;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_11 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S483 : f32 = - dot(n_i_5, l_1);
    var _S484 : f32 = smithG1(alpha_8, max(_S483, 0.0f));
    var _S485 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S485)
    {
        var _S486 : vec3<f32> = ((-(n_i_5)));
        var _S487 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S486);
        var _S488 : f32 = anisotropicG1(_S487, lobes_4.alphas);
        G1_l_0 = _S488;
    }
    else
    {
        G1_l_0 = _S484;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_11.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S489 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S490 : bool = n_i_dot_l_2 > 0.0f;
    var _S491 : bool;
    if(_S490)
    {
        _S491 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S491 = false;
    }
    var _S492 : f32 = select(0.0f, _S489, _S491);
    return _S492;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_12 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S493 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S494 : f32 = dot(n_i_6, _S493);
    var _S495 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S496 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S497 : f32 = 1.0f / max(material_12.sheen_roughness, 0.05000000074505806f);
    var _S498 : f32 = 1.0f - _S494 * _S494;
    var _S499 : f32 = (2.0f + _S497) * pow(max(_S498, 0.0f), 0.5f * _S497) * 0.5f * 0.31830987334251404f / max(4.0f * (_S495 + _S496 - _S495 * _S496), 0.0000152587890625f);
    var _S500 : bool = (material_12.velvet) > 0.0f;
    var f_2 : f32;
    if(_S500)
    {
        var _S501 : f32 = max(material_12.sheen_roughness, 0.00999999977648258f);
        var _S502 : f32 = _S501 * _S501;
        var _S503 : f32 = max(_S498, 0.0000152587890625f);
        var _S504 : f32 = exp(- _S494 * _S494 / (_S503 * _S502)) / (3.14159274101257324f * _S502 * _S503 * _S503) * min(1.0f, 2.0f * _S494 * min(_S495, _S496) / max(abs(dot(_S493, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S495 * _S496, 0.0000152587890625f);
        f_2 = _S504;
    }
    else
    {
        f_2 = _S499;
    }
    return lobes_6.sheen * vec3<f32>((f_2 * _S495 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_7 : f32,  eta_o_7 : f32) -> f32
{
    var _S505 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S506 : f32 = lobes_7.p_reflect * _S505 / (4.0f * lobes_7.v_dot_h);
    var _S507 : bool = _S505 > 0.0f;
    var _S508 : f32 = select(0.0f, _S506, _S507);
    return _S508;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_13 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S509 : f32 = dot(n_i_7, l_3);
    var _S510 : f32 = smithG1(alpha_12, max(_S509, 0.0f));
    var _S511 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S511)
    {
        var _S512 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S513 : f32 = anisotropicG1(_S512, lobes_8.alphas);
        G1_l_1 = _S513;
    }
    else
    {
        G1_l_1 = _S510;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  material_14 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_1 : bool,  random_state_5 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S514 : vec3<f32> = ((-(in_dir_4)));
    var _S515 : f32 = dot(n_7, _S514);
    var _S516 : f32 = (sign((_S515)));
    var _S517 : vec3<f32> = n_7 * vec3<f32>(_S516);
    var _S518 : AnisotropicFrame = anisotropicFrame(material_14, _S517);
    var _S519 : f32 = dot(_S517, out_dir_2);
    var _S520 : f32 = material_14.roughness;
    var _S521 : f32 = _S520 * _S520;
    var _S522 : SheenProfile = sheenProfile(_S514, _S517, material_14);
    var _S523 : f32 = rgb_to_greyscale(material_14.translucent);
    var _S524 : bool = _S523 > 0.0f;
    var _S525 : bool = (dot(n_7, out_dir_2) * _S515) < 0.0f;
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
        var _S526 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S526;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S527 : vec3<f32> = vec3<f32>(0.0f);
    var _S528 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S527, _S527, 0.0f, 0.0f, _S527, _S527, 0.0f, 0.0f, 0.0f, 0.0f, _S527, 0.0f, _S527, _S527, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S528;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S527;
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
        var _S529 : u32;
        if(i_0 == u32(3))
        {
            _S529 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S529 = u32(6);
            }
            else
            {
                _S529 = i_0;
            }
        }
        var _S530 : bool = _S529 == u32(0);
        var _S531 : bool;
        if(_S530)
        {
            _S531 = _S524;
        }
        else
        {
            _S531 = false;
        }
        var _S532 : bool;
        if(_S531)
        {
            _S532 = _S525;
        }
        else
        {
            _S532 = _S529 == u32(1);
        }
        var _S533 : bool = _S532 != refracted_1;
        if(_S533)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S534 : u32;
        if(_S529 == u32(6))
        {
            _S534 = u32(0);
        }
        else
        {
            if(_S529 == u32(4))
            {
                _S534 = u32(2);
            }
            else
            {
                _S534 = _S529;
            }
        }
        var _S535 : bool = _S534 != half_of_0;
        var half_of_1 : u32;
        if(_S535)
        {
            var _S536 : bool = _S534 == u32(0);
            if(_S536)
            {
                var _S537 : vec3<f32> = sampledHalf(in_dir_4, n_7, material_14, random_state_5, _S518);
                ggx_n_1 = _S537;
            }
            else
            {
                var _S538 : bool = _S534 == u32(1);
                if(_S538)
                {
                    var _S539 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S539;
                }
                else
                {
                    var _S540 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S540;
                }
            }
            var _S541 : vec3<f32> = ((-(in_dir_4)));
            var _S542 : BSDFLobes = bsdfLobes(in_dir_4, _S541, _S517, ggx_n_1, material_14, eta_i_8, eta_o_8, _S518, _S522);
            lobe_terms_0 = _S542;
            var _S543 : f32 = translucentShare(material_14);
            lobe_terms_0.translucent_share = _S543;
            half_of_1 = _S534;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S529)
        {
        case u32(0):
            {
                var _S544 : f32 = diffusePDF(_S519, 0.0f, abs(_S515), _S521, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(0)] = _S544;
                var _S545 : vec3<f32> = diffuseBSDF(out_dir_2, _S517, _S521, material_14, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S545;
            }
        case u32(1):
            {
                var _S546 : f32 = refractPDF(_S519, dot(out_dir_2, ggx_n_1), abs(_S515), _S521, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(1)] = _S546;
                var _S547 : vec3<f32> = refractBSDF(out_dir_2, _S517, _S521, material_14, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S547;
            }
        case u32(4):
            {
                var _S548 : f32 = sheenVelvetPDF(_S519, 0.0f, abs(_S515), _S521, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(3)] = _S548;
                var _S549 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S517, _S521, material_14, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S549;
            }
        default :
            {
                var _S550 : f32 = reflectPDF(_S519, 0.0f, abs(_S515), _S521, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[i32(2)] = _S550;
                var _S551 : vec3<f32> = reflectBSDF(out_dir_2, _S517, _S521, material_14, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S551;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S527;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S552 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S552)
        {
            var f_3 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_3;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
}

fn lightBSDF_0( in_dir_5 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_2 : vec3<f32>,  material_15 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  competing_0 : bool,  random_state_6 : u32) -> vec3<f32>
{
    var _S553 : bool = (dot(geometry_n_2, (vec3<f32>(0) - in_dir_5)) * dot(geometry_n_2, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S554 : vec3<f32> = BSDF(in_dir_5, light_0.dir, smooth_n_5, material_15, eta_i_9, eta_o_9, _S553, random_state_6, &(throughputs_1), &(pdfs_1));
    var _S555 : bool = !competing_0;
    var _S556 : bool;
    if(_S555)
    {
        _S556 = true;
    }
    else
    {
        _S556 = (light_0.density) == 0.0f;
    }
    if(_S556)
    {
        return _S554 * light_0.radiance;
    }
    var _S557 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S557;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S558 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S558)
        {
            var _S559 : f32 = pdfs_1[i_4] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((light_0.density * (1.0f + _S559 * _S559)));
            weighted_0 = weighted_1;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S560 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S561 : vec2<u32> = _S560 - vec2<u32>(u32(1), u32(0));
    var _S562 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S563 : vec2<u32> = min(vec2<u32>(_S562 * vec2<f32>(_S561)), _S561 - vec2<u32>(u32(1)));
    var _S564 : vec4<f32> = (textureLoad(environment_cdf, (_S563), 0));
    var _S565 : f32 = _S564.y;
    var _S566 : u32 = _S561.x;
    var _S567 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S566, _S563.y)), 0));
    var _S568 : f32 = _S565 * _S567.y;
    return _S568 * f32(_S566 * _S561.y) / (19.73921012878417969f * length(dir_3.xz));
}

fn wrongSide_0( is_inside_0 : bool,  refracted_2 : bool,  dir_4 : vec3<f32>,  geometry_n_3 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_2) != ((dot(dir_4, geometry_n_3)) > 0.0f);
}

fn skyLobes_0( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_1 : bool,  pdf_2 : f32,  random_state_7 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_2 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S569 : bool = wrongSide_0(is_inside_1, false, dir_5, surface_1.geometry_n);
    var _S570 : vec3<f32> = BSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S569, random_state_7, &((*terms_0)), &((*pdfs_2)));
    var _S571 : vec3<f32> = vec3<f32>(0.0f);
    var i_6 : u32 = u32(0);
    var f_4 : vec3<f32> = _S571;
    loop
    {
        if(i_6 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S572 : bool = ((*pdfs_2)[i_6]) > 0.0f;
        if(_S572)
        {
            var _S573 : vec3<f32> = (*terms_0)[i_6] * vec3<f32>((*pdfs_2)[i_6]) / vec3<f32>(((*pdfs_2)[i_6] + pdf_2));
            (*terms_0)[i_6] = _S573;
            var f_5 : vec3<f32> = f_4 + (*terms_0)[i_6];
            f_4 = f_5;
        }
        var i_7 : u32 = i_6 + u32(1);
        i_6 = i_7;
    }
    return f_4;
}

fn skyBSDF( in_dir_7 : vec3<f32>,  dir_6 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_8 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(5)>;
    var pdfs_3 : array<f32, i32(5)>;
    var _S574 : vec3<f32> = skyLobes_0(in_dir_7, dir_6, surface_2, eta_1, is_inside_2, pdf_3, random_state_8, &(terms_1), &(pdfs_3));
    return _S574;
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
    var _S575 : u32 = count_0 - u32(1);
    var low_1 : u32 = u32(0);
    var high_1 : u32 = _S575;
    loop
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        var _S576 : u32 = (low_1 + high_1) / u32(2);
        var _S577 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S576)), 0));
        var _S578 : bool = (_S577.x) > u_1;
        if(_S578)
        {
            high_1 = _S576;
        }
        else
        {
            var _S579 : u32 = _S576 + u32(1);
            low_1 = _S579;
        }
    }
    return low_1;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  color_2 : vec3<f32>,  random_state_9 : u32) -> SkySample
{
    var _S580 : SkySample;
    _S580.dir = dir_7;
    _S580.radiance = radiance_2;
    _S580.color = color_2;
    _S580.random_state = random_state_9;
    return _S580;
}

fn skyRadiance_0( origin_5 : vec3<f32>,  surface_3 : Surface,  is_inside_3 : bool,  dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S581 : bool = wrongSide_0(is_inside_3, false, dir_8, surface_3.geometry_n);
    var _S582 : bool = is_inside_3 != _S581;
    var _S583 : vec3<f32> = (vec3<f32>(0) - surface_3.smooth_n);
    var _S584 : vec3<f32> = select(surface_3.smooth_n, _S583, _S582);
    var _S585 : Ray = Ray_x24init_0(origin_5 + vec3<f32>(surface_3.geometry_offset) * _S584, dir_8);
    var _S586 : vec3<f32> = (env_map_sample((dir_8)));
    var _S587 : vec3<f32> = (shadowTransmittance((_S585), (4.294967296e+09f)));
    return _S586 * _S587;
}

fn sampleSky_0( ray_1 : Ray,  surface_4 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_1 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S588 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S589 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S590 : vec2<u32> = _S588 - _S589;
    var _S591 : Random = pcg(init_random_state_1);
    var _S592 : Random = pcg(_S591.state);
    var _S593 : Random = pcg(_S592.state);
    var _S594 : Random = pcg(_S593.state);
    var _S595 : u32 = _S590.x;
    var _S596 : u32 = searchCDF_0(vec2<u32>(_S595, u32(0)), vec2<u32>(u32(0), u32(1)), _S590.y, _S591.value);
    var _S597 : u32 = searchCDF_0(vec2<u32>(u32(0), _S596), _S589, _S595, _S592.value);
    var _S598 : vec2<f32> = (vec2<f32>(f32(_S597), f32(_S596)) + vec2<f32>(_S593.value, _S594.value)) / vec2<f32>(_S590) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S599 : f32 = _S598.y;
    var _S600 : f32 = sin(_S599);
    var _S601 : f32 = _S598.x;
    var _S602 : vec3<f32> = vec3<f32>(_S600 * cos(_S601), cos(_S599), _S600 * sin(_S601));
    var _S603 : f32 = environmentPdf_0(_S602);
    var _S604 : vec3<f32> = skyBSDF(ray_1.unit_direction, _S602, surface_4, eta_2, is_inside_4, _S603, lobe_state_0);
    var _S605 : bool = !(_S603 > 0.0f);
    var _S606 : bool;
    if(_S605)
    {
        _S606 = true;
    }
    else
    {
        _S606 = (all((_S604 == vec3<f32>(0.0f))));
    }
    if(_S606)
    {
        var _S607 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S602, _S607, _S607, _S594.state);
    }
    var _S608 : vec3<f32> = skyRadiance_0(ray_1.origin, surface_4, is_inside_4, _S602);
    return SkySample_x24init_0(_S602, _S608, _S604 * _S608, _S594.state);
}

fn safeDivide( a_5 : vec3<f32>,  b_1 : vec3<f32>) -> vec3<f32>
{
    var _S609 : vec3<f32> = a_5 / b_1;
    var _S610 : vec3<f32> = vec3<f32>(0.0f);
    var _S611 : vec3<bool> = b_1 == _S610;
    var _S612 : vec3<f32> = select(_S609, _S610, _S611);
    return _S612;
}

fn withEnd( r_3 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_0 : Reservoir = r_3;
    var _S613 : u32 = (insertBits((r_3.path), (end_0), (u32(0)), (u32(5))));
    var _S614 : u32 = (insertBits((_S613), (end_type_0), (u32(12)), (u32(3))));
    candidate_0.path = _S614;
    candidate_0.f = f_6;
    return candidate_0;
}

fn resamplingTarget( f_7 : vec3<f32>) -> f32
{
    var _S615 : f32 = rgb_to_greyscale(abs(f_7));
    return _S615;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_1 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S616 : f32 = resamplingTarget(weight_0);
    var _S617 : bool = _S616 > 0.0f;
    var _S618 : bool;
    if(_S617)
    {
        _S618 = _S616 < 3.00000000549775576e+38f;
    }
    else
    {
        _S618 = false;
    }
    var _S619 : bool = !_S618;
    if(_S619)
    {
        return;
    }
    var _S620 : f32 = (*sel_0).w_sum + _S616;
    (*sel_0).w_sum = _S620;
    var _S621 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S621;
    var _S622 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S622.state;
    var _S623 : bool = (_S622.value * (*sel_0).w_sum) <= _S616;
    if(_S623)
    {
        (*sel_0).r = candidate_1;
    }
    return;
}

fn environmentMapped_0() -> bool
{
    var _S624 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S625 : bool = (_S624.x) > u32(1);
    var _S626 : bool;
    if(_S625)
    {
        var _S627 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S626 = (_S627.y) > u32(1);
    }
    else
    {
        _S626 = false;
    }
    return _S626;
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
    var _S628 : SampleBSDF;
    _S628.unit_direction = unit_direction_1;
    _S628.throughput = throughput_0;
    _S628.random_state = random_state_10;
    _S628.refracted = refracted_3;
    _S628.lobe = lobe_1;
    _S628.pdf = pdf_4;
    return _S628;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_16 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S629 : vec3<f32> = vec3<f32>(1.0f);
    var _S630 : SampleBSDF = SampleBSDF_x24init_0(_S629, _S629, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S630;
    var _S631 : Random = pcg(random_state_11);
    var _S632 : Random = pcg(_S631.state);
    sample_1.random_state = _S632.state;
    var _S633 : f32 = _S631.value;
    var _S634 : f32 = sqrt(max(0.0f, 1.0f - _S633 * _S633));
    var _S635 : f32 = 6.28318548202514648f * _S632.value;
    var _S636 : vec3<f32> = tangentToWorld(vec3<f32>(_S634 * cos(_S635), _S631.value, _S634 * sin(_S635)), n_i_8);
    sample_1.unit_direction = _S636;
    sample_1.lobe = u32(4);
    var _S637 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    sample_1.throughput = _S637;
    var _S638 : f32 = sheenVelvetPDF(_S631.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S638;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S639 : f32 = sqrt(random_1_0);
    var _S640 : f32 = 6.28318548202514648f * random_2_0;
    var _S641 : f32 = _S639 * cos(_S640);
    var _S642 : f32 = _S639 * sin(_S640);
    var _S643 : f32 = sqrt(max(0.0f, 1.0f - _S641 * _S641 - _S642 * _S642));
    return vec3<f32>(_S641, _S643, _S642);
}

fn diffuseSample( u_2 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_17 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S644 : vec3<f32> = vec3<f32>(1.0f);
    var _S645 : SampleBSDF = SampleBSDF_x24init_0(_S644, _S644, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S645;
    var _S646 : Random = pcg(random_state_12);
    var _S647 : Random = pcg(_S646.state);
    sample_2.random_state = _S647.state;
    var _S648 : vec3<f32> = sampleCosWeightedHemisphere(_S646.value, _S647.value);
    var _S649 : bool = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S650 : f32 = _S648.y;
    var _S651 : f32 = - _S650;
    var _S652 : f32 = select(_S650, _S651, _S649);
    var _S653 : vec3<f32> = tangentToWorld(vec3<f32>(_S648.x, _S652, _S648.z), n_i_9);
    sample_2.unit_direction = _S653;
    sample_2.refracted = _S649;
    sample_2.lobe = u32(0);
    var _S654 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    sample_2.throughput = _S654;
    var _S655 : f32 = diffusePDF(_S652, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S655;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_18 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S656 : vec3<f32> = vec3<f32>(1.0f);
    var _S657 : SampleBSDF = SampleBSDF_x24init_0(_S656, _S656, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S657;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S658 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    sample_3.throughput = _S658;
    var _S659 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S659;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_19 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S660 : vec3<f32> = vec3<f32>(1.0f);
    var _S661 : SampleBSDF = SampleBSDF_x24init_0(_S660, _S660, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S661;
    var _S662 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S662;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S663 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    sample_4.throughput = _S663;
    var _S664 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S664;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_20 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S665 : vec3<f32> = ((-(in_dir_9)));
    var _S666 : f32 = dot(n_8, _S665);
    var _S667 : f32 = (sign((_S666)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S667);
    var _S668 : f32 = abs(_S666);
    var _S669 : f32 = material_20.roughness;
    var _S670 : f32 = _S669 * _S669;
    var _S671 : AnisotropicFrame = anisotropicFrame(material_20, n_i_12);
    var _S672 : SheenProfile = sheenProfile(_S665, n_i_12, material_20);
    var _S673 : vec3<f32> = sampleHalfVector(_S665, n_i_12, _S670, _S671, &(random_state_15));
    var _S674 : BSDFLobes = bsdfLobes(in_dir_9, _S665, n_i_12, _S673, material_20, eta_i_14, eta_o_14, _S671, _S672);
    var lobes_13 : BSDFLobes = _S674;
    var _S675 : f32 = translucentShare(material_20);
    lobes_13.translucent_share = _S675;
    var _S676 : Random = pcg(random_state_15);
    random_state_15 = _S676.state;
    var _S677 : bool = (_S676.value) < (lobes_13.p_sheen_velvet);
    if(_S677)
    {
        var _S678 : SampleBSDF = sheenVelvetSample(n_i_12, _S668, _S670, material_20, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S678;
    }
    var _S679 : f32 = _S676.value - lobes_13.p_sheen_velvet;
    var _S680 : bool = _S679 < (lobes_13.p_diffuse);
    if(_S680)
    {
        var _S681 : SampleBSDF = diffuseSample(_S679, n_i_12, _S668, _S670, material_20, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S681;
    }
    var _S682 : bool = _S679 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S682)
    {
        var _S683 : SampleBSDF = refractSample(_S673, n_i_12, _S668, _S670, material_20, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S683;
    }
    var _S684 : SampleBSDF = reflectSample(in_dir_9, _S673, n_i_12, _S668, _S670, material_20, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S684;
}

fn escapeWeight_0( pdf_5 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S685 : bool = pdf_5 <= 0.0f;
    var _S686 : bool;
    if(_S685)
    {
        _S686 = true;
    }
    else
    {
        var _S687 : bool = environmentMapped_0();
        _S686 = !_S687;
    }
    if(_S686)
    {
        return 1.0f;
    }
    var _S688 : f32 = environmentPdf_0(dir_9);
    return pdf_5 / (pdf_5 + _S688);
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S689 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S689.x, max(_S689.y, _S689.z)), 0.0f, 1.0f);
}

fn environment_0( dir_10 : vec3<f32>) -> vec3<f32>
{
    var _S690 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S691 : bool = (_S690.x) > u32(1);
    var _S692 : bool;
    if(_S691)
    {
        var _S693 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S692 = (_S693.y) > u32(1);
    }
    else
    {
        _S692 = false;
    }
    if(_S692)
    {
        var _S694 : vec3<f32> = (env_map_sample((dir_10)));
        return _S694;
    }
    var _S695 : vec3<f32> = (uniforms_float.ambient);
    return _S695;
}

fn walk_0( dom_1 : Domain,  r_4 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_1 : ptr<function, Selection>) -> Shift
{
    var _S696 : vec3<f32> = vec3<f32>(0.0f);
    var _S697 : Shift = Shift_x24init_0(_S696, 0.0f);
    var _S698 : u32 = (extractBits((r_4.path), (u32(0)), (u32(5))));
    var _S699 : u32 = (extractBits((r_4.path), (u32(5)), (u32(5))));
    var _S700 : u32 = (extractBits((r_4.path), (u32(10)), (u32(2))));
    var _S701 : u32 = (extractBits((r_4.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S702 : bool = _S701 >= u32(3);
        var _S703 : u32 = select(u32(0), u32(1), _S702);
        var _S704 : u32 = _S698 + _S703;
        var _S705 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S704 > _S705;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S697;
    }
    var _S706 : u32 = _S699 - u32(1);
    var _S707 : bool = _S701 == u32(3);
    var _S708 : u32 = select(u32(0), u32(1), _S707);
    var _S709 : u32 = _S698 + _S708;
    var _S710 : bool = _S700 == u32(0);
    var _S711 : u32 = select(_S706, _S709, _S710);
    var _S712 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_4.rc.zw))), r_4.rc.x, r_4.rc.y, u32(0), 0.0f);
    var _S713 : vec3<f32> = (normalize((dom_1.x1 - dom_1.x0)));
    var _S714 : Ray = Ray_x24init_0(dom_1.x1, _S713);
    var ray_2 : Ray = _S714;
    var hit_2 : Hit = dom_1.hit;
    var _S715 : vec3<f32> = vec3<f32>(1.0f);
    var _S716 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S696, _S696, _S696);
    var nee_vertex_0 : NEEVertex = _S716;
    var _S717 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S717;
    var _S718 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S696, 0.0f, vec4<u32>(u32(0)), _S696, _S696);
    var chain_0 : Reservoir = _S718;
    chain_0.seed = r_4.seed;
    is_inside_5 = false;
    var threshold_0 : f32 = 0.0f;
    var wavelength_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S696;
    var reconnection_0 : vec3<f32> = _S696;
    var b_2 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S715;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S719 : bool = (hit_2.is_point_light) == u32(1);
        var _S720 : bool;
        if(replay_0)
        {
            _S720 = _S700 == u32(1);
        }
        else
        {
            _S720 = false;
        }
        var _S721 : bool;
        if(_S720)
        {
            _S721 = b_2 == _S699;
        }
        else
        {
            _S721 = false;
        }
        var _S722 : bool;
        if(_S721)
        {
            var _S723 : bool = (hit_2.instance_index) != (_S712.instance_index);
            if(_S723)
            {
                _S722 = true;
            }
            else
            {
                _S722 = (hit_2.triangle_index) != (_S712.triangle_index);
            }
        }
        else
        {
            _S722 = false;
        }
        if(_S722)
        {
            return _S697;
        }
        var _S724 : Surface = Surface_x24init_0(_S696, _S696, 0.0f, Material_x24init_0(_S696, _S696, 0.0f, 0.0f, 0.0f, 0.0f, _S696, _S715, 1.0f, _S696, _S696, 0.5f, 0.0f, 0.0f, _S696, 0.0f, 0.0f), false, u32(0));
        var _S725 : bool = !_S719;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S725)
        {
            var _S726 : u32 = stream(r_4.seed, b_2);
            var _S727 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S726)));
            var surface_6 : Surface = facingRay_0(_S727, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S728 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S729 : vec3<f32> = throughput_2 * _S728;
                front_n_0 = _S729;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S730 : bool = !surface_6.skip;
            var geometry_density_1 : f32 = abs(dot(surface_6.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S731 : bool = b_2 == u32(0);
            if(_S731)
            {
                var _S732 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S732;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S733 : vec3<f32> = front_n_0;
            var _S734 : f32 = geometry_density_0;
            scatter_0 = _S730;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S734;
            surface_5 = surface_6;
            front_n_0 = _S727.smooth_n;
            throughput_3 = _S733;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            surface_5 = _S724;
            front_n_0 = _S696;
            throughput_3 = throughput_2;
        }
        var _S735 : bool;
        if(scatter_0)
        {
            _S735 = prev_0.rough;
        }
        else
        {
            _S735 = false;
        }
        var _S736 : bool;
        if(_S735)
        {
            _S736 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S736 = false;
        }
        var _S737 : Surface = surface_5;
        var _S738 : Surface = surface_5;
        var _S739 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S740 : bool = ((true));
        var _S741 : bool;
        if(_S740)
        {
            _S741 = wavelength_2 == 0.0f;
        }
        else
        {
            _S741 = false;
        }
        var _S742 : bool;
        if(_S741)
        {
            _S742 = scatter_0;
        }
        else
        {
            _S742 = false;
        }
        var _S743 : bool;
        if(_S742)
        {
            var _S744 : bool = dispersive(_S737.material);
            _S743 = _S744;
        }
        else
        {
            _S743 = false;
        }
        var throughput_4 : vec3<f32>;
        if(_S743)
        {
            var _S745 : u32 = stream(r_4.seed, u32(512));
            var _S746 : Random = pcg(_S745);
            var _S747 : vec2<f32> = sampleWavelength(_S746.value);
            var _S748 : f32 = _S747.x;
            var _S749 : vec3<f32> = wavelengthWeights(_S748);
            var _S750 : vec3<f32> = throughput_3 * (_S749 / vec3<f32>(_S747.y));
            wavelength_2 = _S748;
            throughput_4 = _S750;
        }
        else
        {
            throughput_4 = throughput_3;
        }
        var refractive_0 : Material = _S737.material;
        var _S751 : f32 = dispersedIor(_S737.material.ior, _S737.material.dispersion, wavelength_2);
        var _S752 : bool = wavelength_2 > 0.0f;
        var _S753 : f32 = select(_S737.material.ior, _S751, _S752);
        refractive_0.ior = _S753;
        var _S754 : vec2<f32> = vertexEta(refractive_0, _S739);
        var _S755 : bool;
        if(scatter_0)
        {
            var _S756 : bool = neeDecision(_S737.material, _S739, _S754.x, _S754.y);
            _S755 = _S756;
        }
        else
        {
            _S755 = false;
        }
        var _S757 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S758 : vec3<f32> = _S737.material.emissive * vec3<f32>(max(_S757, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S719)
        {
            var _S759 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S759;
        }
        else
        {
            emission_0 = _S758;
        }
        var _S760 : bool = !replay_0;
        var _S761 : bool;
        if(_S760)
        {
            _S761 = true;
        }
        else
        {
            _S761 = b_2 >= _S711;
        }
        var _S762 : bool;
        if(_S761)
        {
            var _S763 : f32 = rgb_to_greyscale(emission_0);
            _S762 = _S763 > 0.0f;
        }
        else
        {
            _S762 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S762)
        {
            var _S764 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S764);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S765 : bool;
        if(replay_0)
        {
            _S765 = _S700 == u32(1);
        }
        else
        {
            _S765 = false;
        }
        var _S766 : bool;
        if(_S765)
        {
            _S766 = b_2 > _S699;
        }
        else
        {
            _S766 = false;
        }
        var _S767 : bool;
        if(_S766)
        {
            _S767 = b_2 == _S698;
        }
        else
        {
            _S767 = false;
        }
        var _S768 : bool;
        if(_S767)
        {
            var _S769 : bool = _S701 == u32(1);
            if(_S769)
            {
                _S768 = true;
            }
            else
            {
                _S768 = _S701 == u32(2);
            }
        }
        else
        {
            _S768 = false;
        }
        if(_S768)
        {
            var _S770 : bool = _S719 != (_S701 == u32(2));
            if(_S770)
            {
                return _S697;
            }
            return Shift_x24init_0(throughput_4 * emission_1 / vec3<f32>(r_4.jac), density_2 / r_4.jac);
        }
        var _S771 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S772 : bool = _S771 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S773 : u32 = (insertBits((u32(0)), (b_2), (u32(5)), (u32(5))));
        var _S774 : u32 = (insertBits((_S773), (u32(1)), (u32(10)), (u32(2))));
        var _S775 : u32 = (insertBits((_S774), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S776 : bool = prev_0.inside;
        var _S777 : u32 = select(u32(0), u32(1), _S776);
        var _S778 : u32 = (insertBits((_S775), (_S777), (u32(22)), (u32(1))));
        here_0.path = _S778;
        var _S779 : u32 = here_0.path;
        var _S780 : u32 = select(u32(0), u32(1), _S752);
        var _S781 : u32 = (insertBits((_S779), (_S780), (u32(23)), (u32(1))));
        here_0.path = _S781;
        var _S782 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S782;
        var _S783 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S783;
        var _S784 : bool;
        if(replay_0)
        {
            _S784 = _S700 == u32(1);
        }
        else
        {
            _S784 = false;
        }
        var _S785 : bool;
        if(_S784)
        {
            _S785 = b_2 == _S699;
        }
        else
        {
            _S785 = false;
        }
        var _S786 : bool = b_2 == _S711;
        var _S787 : bool;
        if(_S786)
        {
            var _S788 : bool = !scatter_0;
            if(_S788)
            {
                _S787 = true;
            }
            else
            {
                var _S789 : bool = _S700 != u32(1);
                if(_S789)
                {
                    _S787 = _S700 != u32(3);
                }
                else
                {
                    _S787 = false;
                }
            }
        }
        else
        {
            _S787 = false;
        }
        var _S790 : bool;
        if(_S787)
        {
            _S790 = _S700 == u32(2);
        }
        else
        {
            _S790 = false;
        }
        var _S791 : bool;
        if(_S790)
        {
            _S791 = !_S736;
        }
        else
        {
            _S791 = false;
        }
        var _S792 : bool;
        if(_S791)
        {
            _S792 = _S701 != u32(4);
        }
        else
        {
            _S792 = false;
        }
        var _S793 : bool = _S699 == _S698;
        var _S794 : bool;
        if(_S793)
        {
            _S794 = _S701 == u32(0);
        }
        else
        {
            _S794 = false;
        }
        var _S795 : bool;
        if(_S794)
        {
            _S795 = (hit_2.instance_index) == (_S712.instance_index);
        }
        else
        {
            _S795 = false;
        }
        var _S796 : bool;
        if(_S795)
        {
            _S796 = (hit_2.triangle_index) == (_S712.triangle_index);
        }
        else
        {
            _S796 = false;
        }
        var _S797 : bool;
        if(_S796)
        {
            _S797 = _S736;
        }
        else
        {
            _S797 = false;
        }
        var _S798 : bool = select(_S792, _S797, _S785);
        var _S799 : bool;
        if(_S755)
        {
            _S799 = select(scatter_0, _S798, replay_0);
        }
        else
        {
            _S799 = false;
        }
        var _S800 : TreeSample = TreeSample_x24init_0(_S696, _S696, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S799)
        {
            var _S801 : Surface = surface_5;
            var _S802 : bool = isTranslucent_0(_S737.material);
            var _S803 : u32 = stream(r_4.seed, b_2 + u32(64));
            var _S804 : TreeSample = sampleLightTree_0(ray_2.origin, _S738.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S802, _S803);
            var _S805 : bool = (any(((_S804.radiance) != _S696)));
            if(_S805)
            {
                var _S806 : f32 = _S754.x;
                var _S807 : f32 = _S754.y;
                var _S808 : u32 = (uniforms_uint.max_bounces);
                var _S809 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S804, _S738.smooth_n, _S801.geometry_n, _S737.material, _S806, _S807, b_2 < _S808, surface_5.random_state);
                lit_0 = _S809;
            }
            else
            {
                lit_0 = _S696;
            }
            light_1 = _S804;
        }
        else
        {
            light_1 = _S800;
            lit_0 = _S696;
        }
        var _S810 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S811 : bool;
        var _S812 : bool;
        var density_3 : f32;
        var throughput_5 : vec3<f32>;
        if(_S785)
        {
            var _S813 : bool = !_S736;
            if(_S813)
            {
                return _S697;
            }
            var _S814 : u32 = (extractBits((r_4.path), (u32(23)), (u32(1))));
            var _S815 : bool = _S752 != (_S814 == u32(1));
            if(_S815)
            {
                return _S697;
            }
            var throughput_6 : vec3<f32> = throughput_4 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S793)
            {
                _S810 = _S701 == u32(1);
            }
            else
            {
                _S810 = false;
            }
            if(_S810)
            {
                return Shift_x24init_0(throughput_6 * emission_1 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S793)
            {
                wrong_side_0 = _S701 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S816 : bool = !_S755;
                if(_S816)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S817 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S817 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S697;
                }
                return Shift_x24init_0(throughput_6 * lit_0 / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            if(_S793)
            {
                refracted_4 = _S701 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S818 : bool = !_S755;
                if(_S818)
                {
                    return _S697;
                }
                var _S819 : f32 = environmentPdf_0(r_4.dir);
                var _S820 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_4.dir, surface_5, _S754, is_inside_5, _S819, surface_5.random_state);
                return Shift_x24init_0(throughput_6 * _S820 * r_4.radiance / vec3<f32>(r_4.jac), density_4 / r_4.jac);
            }
            var _S821 : u32 = (extractBits((r_4.path), (u32(21)), (u32(1))));
            var _S822 : bool = _S755 != (_S821 == u32(1));
            if(_S822)
            {
                return _S697;
            }
            throughput_5 = throughput_6;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S810 = _S786;
            }
            else
            {
                _S810 = false;
            }
            if(_S810)
            {
                var _S823 : bool = !scatter_0;
                if(_S823)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S824 : bool = _S700 != u32(1);
                    if(_S824)
                    {
                        wrong_side_0 = _S700 != u32(3);
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
                var _S825 : bool = _S700 == u32(2);
                if(_S825)
                {
                    _S720 = _S755;
                }
                else
                {
                    _S720 = false;
                }
                if(_S720)
                {
                    _S720 = !_S736;
                }
                else
                {
                    _S720 = false;
                }
                if(_S720)
                {
                    _S720 = _S701 == u32(4);
                }
                else
                {
                    _S720 = false;
                }
                if(_S720)
                {
                    var _S826 : u32 = stream(r_4.seed, b_2 + u32(256));
                    var _S827 : SkySample = sampleSky_0(ray_2, surface_5, _S754, is_inside_5, _S826, surface_5.random_state);
                    return Shift_x24init_0(throughput_4 * _S827.color, 1.0f);
                }
                if(_S825)
                {
                    is_inside_5 = _S755;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S736;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S828 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S829 : bool = !(_S828 > 0.0f);
                    if(_S829)
                    {
                        return _S697;
                    }
                    return Shift_x24init_0(throughput_4 * lit_0, 1.0f);
                }
                if(_S710)
                {
                    is_inside_5 = _S701 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S719;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_4 * emission_1, 1.0f);
                }
                if(_S710)
                {
                    is_inside_5 = _S701 == u32(1);
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
                    is_inside_5 = !_S736;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_4 * emission_1, 1.0f);
                }
                return _S697;
            }
            else
            {
                if(_S760)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S830 : bool = b_2 > u32(0);
                    if(_S830)
                    {
                        var candidate_2 : Reservoir = chain_0;
                        if(_S772)
                        {
                            var _S831 : vec3<f32> = safeDivide(throughput_4 * emission_1, chain_throughput_0);
                            candidate_2.radiance = _S831;
                        }
                        else
                        {
                            if(_S736)
                            {
                                candidate_2 = here_0;
                            }
                        }
                        var _S832 : vec3<f32> = throughput_4 * emission_1;
                        var _S833 : Reservoir = withEnd(candidate_2, u32(1), b_2, _S832);
                        offer(&((*sel_1)), _S833, _S832 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S755)
                    {
                        var _S834 : vec3<f32> = throughput_4 * lit_0;
                        var candidate_3 : Reservoir = chain_0;
                        if(_S772)
                        {
                            var _S835 : vec3<f32> = safeDivide(_S834, chain_throughput_0);
                            candidate_3.radiance = _S835;
                        }
                        else
                        {
                            if(_S736)
                            {
                                candidate_3 = here_0;
                                var _S836 : u32 = (insertBits((candidate_3.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_3.path = _S836;
                                candidate_3.dir = light_1.dir;
                                candidate_3.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S837 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S838 : u32 = (insertBits((_S837), (u32(2)), (u32(10)), (u32(2))));
                                candidate_3.path = _S838;
                            }
                        }
                        var _S839 : Reservoir = withEnd(candidate_3, u32(0), b_2, _S834);
                        offer(&((*sel_1)), _S839, _S834 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S755)
                    {
                        var _S840 : bool = environmentMapped_0();
                        _S811 = _S840;
                    }
                    else
                    {
                        _S811 = false;
                    }
                    if(_S811)
                    {
                        var _S841 : u32 = (uniforms_uint.max_bounces);
                        _S812 = b_2 < _S841;
                    }
                    else
                    {
                        _S812 = false;
                    }
                    if(_S812)
                    {
                        var _S842 : u32 = stream(r_4.seed, b_2 + u32(256));
                        var _S843 : SkySample = sampleSky_0(ray_2, surface_5, _S754, is_inside_5, _S842, surface_5.random_state);
                        var _S844 : vec3<f32> = throughput_4 * _S843.color;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S772)
                        {
                            var _S845 : vec3<f32> = safeDivide(_S844, chain_throughput_0);
                            candidate_4.radiance = _S845;
                        }
                        else
                        {
                            if(_S736)
                            {
                                candidate_4 = here_0;
                                var _S846 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S846;
                                candidate_4.dir = _S843.dir;
                                candidate_4.radiance = _S843.radiance;
                            }
                            else
                            {
                                var _S847 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                                var _S848 : u32 = (insertBits((_S847), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S848;
                            }
                        }
                        var _S849 : Reservoir = withEnd(candidate_4, u32(4), b_2, _S844);
                        offer(&((*sel_1)), _S849, _S844 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_5 = throughput_4;
            density_3 = density_2;
        }
        var _S850 : bool;
        var _S851 : bool;
        var straight_0 : bool;
        var _S852 : bool;
        var _S853 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S810 = _S786;
            }
            else
            {
                _S810 = false;
            }
            var _S854 : u32 = (extractBits((r_4.path), (u32(15)), (u32(3))));
            var _S855 : u32 = (extractBits((r_4.path), (u32(18)), (u32(3))));
            var _S856 : u32 = select(_S854, _S855, _S785);
            var refracted_5 : bool = _S856 == u32(1);
            var _S857 : SampleBSDF = SampleBSDF_x24init_0(_S696, _S696, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S857;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S810)
            {
                var _S858 : u32 = (extractBits((r_4.path), (u32(22)), (u32(1))));
                var _S859 : bool = is_inside_5 != (_S858 == u32(1));
                if(_S859)
                {
                    return _S697;
                }
                var _S860 : bool = _S700 == u32(1);
                if(_S860)
                {
                    var _S861 : vec3<f32> = (hitPosition((_S712)));
                    dir_11 = _S861;
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
                    var _S862 : bool = isTranslucent_0(_S737.material);
                    if(_S862)
                    {
                        wrong_side_0 = _S856 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S863 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S864 : vec3<f32> = select(r_4.dir, _S863, _S860);
                        refracted_4 = (dot(_S738.smooth_n, _S864) * _S739) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S860)
                {
                    var _S865 : vec3<f32> = ray_2.origin;
                    var _S866 : Surface = surface_5;
                    var _S867 : vec3<f32> = (vec3<f32>(0) - _S738.smooth_n);
                    var _S868 : bool = is_inside_5 != refracted_4;
                    var _S869 : vec3<f32> = select(_S738.smooth_n, _S867, _S868);
                    var _S870 : vec3<f32> = (normalize((dir_11 - (_S865 + vec3<f32>(_S866.geometry_offset) * _S869))));
                    reconnection_1 = _S870;
                }
                else
                {
                    reconnection_1 = r_4.dir;
                }
                var _S871 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S871)
                {
                    return _S697;
                }
                var _S872 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S856;
                wrong_side_0 = false;
                reconnection_1 = _S872;
            }
            else
            {
                var _S873 : bool = !_S785;
                if(_S873)
                {
                    var _S874 : f32 = _S754.x;
                    var _S875 : f32 = _S754.y;
                    var _S876 : vec2<f32> = vec2<f32>(0.0f);
                    var _S877 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S738.smooth_n, _S737.material, _S874, _S875, surface_5.random_state, _S876);
                    var bsdf_sampled_0 : SampleBSDF = _S877;
                    var _S878 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S737.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S879 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S878.geometry_n, _S737.material, _S874, _S875, bsdf_sampled_0.random_state, _S876);
                        bsdf_sampled_0.unit_direction = _S879.unit_direction;
                        bsdf_sampled_0.refracted = _S879.refracted;
                        bsdf_sampled_0.throughput = _S879.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S880 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S878.geometry_n))) * _S878.geometry_n;
                            bsdf_sampled_0.unit_direction = _S880;
                        }
                    }
                    var _S881 : u32 = bsdf_sampled_0.lobe;
                    var _S882 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S883 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S884 : f32 = bsdf_sampled_0.pdf;
                    var _S885 : f32 = select(_S884, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S885;
                    dir_11 = _S882;
                    lobe_index_0 = _S881;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S883;
                }
                else
                {
                    dir_11 = r_4.dir;
                    lobe_index_0 = _S856;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S810)
            {
                _S811 = true;
            }
            else
            {
                _S811 = _S785;
            }
            var throughput_7 : vec3<f32>;
            var throughput_8 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S811)
            {
                var _S886 : vec3<f32> = ray_2.unit_direction;
                var _S887 : f32 = (sign((_S739)));
                var _S888 : vec3<f32> = _S738.smooth_n * vec3<f32>(_S887);
                var _S889 : f32 = dot(_S888, dir_11);
                var _S890 : f32 = _S737.material.roughness;
                var _S891 : f32 = _S890 * _S890;
                var _S892 : AnisotropicFrame = anisotropicFrame(_S737.material, _S888);
                var _S893 : vec3<f32> = ((-(_S886)));
                var _S894 : SheenProfile = sheenProfile(_S893, _S888, _S737.material);
                var _S895 : vec3<f32> = reflectedHalf(_S886, dir_11);
                var _S896 : bool = lobe_index_0 == u32(1);
                if(_S896)
                {
                    var _S897 : vec3<f32> = refractedHalf(_S886, dir_11, _S738.smooth_n, _S754.x, _S754.y);
                    throughput_7 = _S897;
                }
                else
                {
                    throughput_7 = _S895;
                }
                var _S898 : bool = lobe_index_0 == u32(0);
                if(_S898)
                {
                    _S812 = true;
                }
                else
                {
                    _S812 = lobe_index_0 == u32(6);
                }
                if(_S812)
                {
                    var _S899 : vec3<f32> = sampledHalf(_S886, _S738.smooth_n, _S737.material, surface_5.random_state, _S892);
                    throughput_8 = _S899;
                }
                else
                {
                    throughput_8 = throughput_7;
                }
                var _S900 : vec3<f32> = ((-(_S886)));
                var _S901 : f32 = _S754.x;
                var _S902 : f32 = _S754.y;
                var _S903 : BSDFLobes = bsdfLobes(_S886, _S900, _S888, throughput_8, _S737.material, _S901, _S902, _S892, _S894);
                var lobe_terms_1 : BSDFLobes = _S903;
                var _S904 : f32 = translucentShare(_S737.material);
                lobe_terms_1.translucent_share = _S904;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S905 : f32 = diffusePDF(_S889, 0.0f, abs(_S739), _S891, lobe_terms_1, _S901, _S902);
                        var _S906 : vec3<f32> = diffuseBSDF(dir_11, _S888, _S891, _S737.material, lobe_terms_1);
                        density_5 = _S905;
                        chain_throughput_1 = _S906;
                    }
                case u32(1):
                    {
                        var _S907 : f32 = refractPDF(_S889, dot(dir_11, throughput_8), abs(_S739), _S891, lobe_terms_1, _S901, _S902);
                        var _S908 : vec3<f32> = refractBSDF(dir_11, _S888, _S891, _S737.material, lobe_terms_1);
                        density_5 = _S907;
                        chain_throughput_1 = _S908;
                    }
                case u32(4):
                    {
                        var _S909 : f32 = sheenVelvetPDF(_S889, 0.0f, abs(_S739), _S891, lobe_terms_1, _S901, _S902);
                        var _S910 : vec3<f32> = sheenVelvetBSDF(dir_11, _S888, _S891, _S737.material, lobe_terms_1);
                        density_5 = _S909;
                        chain_throughput_1 = _S910;
                    }
                default :
                    {
                        var _S911 : f32 = reflectPDF(_S889, 0.0f, abs(_S739), _S891, lobe_terms_1, _S901, _S902);
                        var _S912 : vec3<f32> = reflectBSDF(dir_11, _S888, _S891, _S737.material, lobe_terms_1);
                        density_5 = _S911;
                        chain_throughput_1 = _S912;
                    }
                }
                var _S913 : bool = density_5 > 0.0f;
                if(_S913)
                {
                    var _S914 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, surface_5.random_state, _S896, lobe_index_0, density_5);
                    lobe_2 = _S914;
                }
            }
            var _S915 : bool = lobe_index_0 == u32(0);
            if(_S915)
            {
                _S812 = true;
            }
            else
            {
                _S812 = lobe_index_0 == u32(4);
            }
            if(_S812)
            {
                _S850 = true;
            }
            else
            {
                _S850 = lobe_index_0 == u32(6);
            }
            var _S916 : bool = !_S850;
            if(_S916)
            {
                var _S917 : bool = (_S737.material.roughness) == 0.0f;
                if(_S917)
                {
                    _S851 = true;
                }
                else
                {
                    var _S918 : bool = lobe_index_0 == u32(1);
                    if(_S918)
                    {
                        _S851 = (_S754.x) == (_S754.y);
                    }
                    else
                    {
                        _S851 = false;
                    }
                }
            }
            else
            {
                _S851 = false;
            }
            var _S919 : bool = lobe_index_0 == u32(1);
            if(_S919)
            {
                straight_0 = (_S737.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S920 : bool = isTranslucent_0(_S737.material);
            if(_S920)
            {
                _S852 = _S915;
            }
            else
            {
                _S852 = false;
            }
            if(_S852)
            {
                _S853 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S853 = false;
            }
            var _S921 : bool;
            if(_S755)
            {
                _S921 = !_S851;
            }
            else
            {
                _S921 = false;
            }
            var _S922 : bool;
            if(_S921)
            {
                _S922 = !wrong_side_0;
            }
            else
            {
                _S922 = false;
            }
            var _S923 : bool;
            if(_S922)
            {
                var _S924 : f32 = lobe_2.pdf;
                var _S925 : vec3<f32> = ray_2.origin;
                var _S926 : bool = isTranslucent_0(_S737.material);
                var _S927 : vec3<f32> = select(_S738.smooth_n, _S696, _S926);
                var _S928 : vec3<f32> = ray_2.origin;
                var _S929 : Surface = surface_5;
                var _S930 : vec3<f32> = (vec3<f32>(0) - _S738.smooth_n);
                var _S931 : vec3<f32> = select(_S738.smooth_n, _S930, _S853);
                var _S932 : NEEVertex = NEEVertex_x24init_0(false, _S924, _S925, _S927, _S928 + vec3<f32>(_S929.geometry_offset) * _S931);
                nee_vertex_0 = _S932;
            }
            else
            {
                var _S933 : bool = lobe_index_0 != u32(1);
                if(_S933)
                {
                    _S923 = true;
                }
                else
                {
                    _S923 = (_S754.x) != (_S754.y);
                }
                if(_S923)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S934 : bool = (lobe_2.pdf) > 0.0f;
            if(_S934)
            {
                if(_S850)
                {
                    _S923 = true;
                }
                else
                {
                    _S923 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S923 = false;
            }
            var _S935 : bool = (lobe_2.pdf) > 0.0f;
            var _S936 : bool;
            if(_S935)
            {
                if(_S850)
                {
                    _S936 = true;
                }
                else
                {
                    _S936 = (_S737.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S936 = false;
            }
            var _S937 : bool;
            if(_S785)
            {
                var _S938 : bool = !_S923;
                if(_S938)
                {
                    return _S697;
                }
                var _S939 : bool = _S701 != u32(1);
                if(_S939)
                {
                    _S937 = _S701 != u32(2);
                }
                else
                {
                    _S937 = false;
                }
                if(_S937)
                {
                    var _S940 : f32 = lobe_2.pdf;
                    var _S941 : f32 = select(0.0f, _S940, _S755);
                    var _S942 : f32 = escapeWeight_0(_S941, r_4.dir);
                    if(_S793)
                    {
                        is_inside_5 = _S707;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S943 : f32 = select(1.0f, _S942, is_inside_5);
                    return Shift_x24init_0(throughput_5 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_4.radiance * vec3<f32>(_S943) / vec3<f32>(r_4.jac), density_3 * lobe_2.pdf / r_4.jac);
                }
                var _S944 : vec3<f32> = throughput_5 * vec3<f32>(lobe_2.pdf);
                var _S945 : f32 = density_3 * lobe_2.pdf;
                throughput_7 = _S944;
                density_5 = _S945;
            }
            else
            {
                throughput_7 = throughput_5;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S937 = b_2 <= _S711;
            }
            else
            {
                _S937 = false;
            }
            var _S946 : bool;
            if(_S937)
            {
                _S946 = _S736;
            }
            else
            {
                _S946 = false;
            }
            var _S947 : bool;
            if(_S946)
            {
                _S947 = _S923;
            }
            else
            {
                _S947 = false;
            }
            var _S948 : bool;
            if(_S947)
            {
                _S948 = true;
            }
            else
            {
                if(_S810)
                {
                    _S948 = !_S936;
                }
                else
                {
                    _S948 = false;
                }
            }
            if(_S948)
            {
                return _S697;
            }
            if(_S810)
            {
                var _S949 : vec3<f32> = throughput_7 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S950 : f32 = lobe_2.pdf;
                throughput_8 = _S949;
                survival_probability_0 = _S950;
            }
            else
            {
                var _S951 : vec3<f32> = throughput_7 * max(lobe_2.throughput, _S696);
                throughput_8 = _S951;
                survival_probability_0 = density_5;
            }
            var _S952 : bool;
            if(_S760)
            {
                _S952 = !_S772;
            }
            else
            {
                _S952 = false;
            }
            var _S953 : bool;
            if(_S952)
            {
                _S953 = _S736;
            }
            else
            {
                _S953 = false;
            }
            var _S954 : bool;
            if(_S953)
            {
                _S954 = _S923;
            }
            else
            {
                _S954 = false;
            }
            if(_S954)
            {
                chain_0 = here_0;
                var _S955 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S956 : u32 = select(u32(0), u32(1), _S755);
                var _S957 : u32 = (insertBits((_S955), (_S956), (u32(21)), (u32(1))));
                chain_0.path = _S957;
                var _S958 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S958;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_8;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S959 : Vertex = Vertex_x24init_0(_S936, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S959;
            var _S960 : f32 = lobe_2.pdf;
            var _S961 : bool;
            if(_S919)
            {
                _S961 = (_S754.x) == (_S754.y);
            }
            else
            {
                _S961 = false;
            }
            var _S962 : f32 = select(_S960, sky_pdf_0, _S961);
            var _S963 : bool;
            if(refracted_4)
            {
                _S963 = !_S853;
            }
            else
            {
                _S963 = false;
            }
            var is_inside_6 : bool;
            if(_S963)
            {
                var _S964 : bool = !is_inside_5;
                is_inside_6 = _S964;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S965 : Surface = surface_5;
            var _S966 : f32 = select(_S965.geometry_offset, 0.0f, straight_0);
            var _S967 : vec3<f32> = (vec3<f32>(0) - _S738.smooth_n);
            var _S968 : bool = is_inside_6 != _S853;
            var _S969 : vec3<f32> = select(_S738.smooth_n, _S967, _S968);
            var _S970 : vec3<f32> = ray_2.origin + vec3<f32>(_S966) * _S969;
            ray_2.origin = _S970;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_8;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S962;
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
        if(_S760)
        {
            if(_S719)
            {
                var _S971 : vec3<f32> = throughput_2 * emission_1;
                var candidate_5 : Reservoir = chain_0;
                var _S972 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S973 : bool = _S972 == u32(1);
                if(_S973)
                {
                    var _S974 : vec3<f32> = safeDivide(_S971, chain_throughput_0);
                    candidate_5.radiance = _S974;
                }
                var _S975 : Reservoir = withEnd(candidate_5, u32(2), b_2, _S971);
                offer(&((*sel_1)), _S975, _S971 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S719)
            {
                _S810 = true;
            }
            else
            {
                _S810 = scatter_0;
            }
            if(_S810)
            {
                var _S976 : f32 = survivalProbability(abs(throughput_2), density_5);
                survival_probability_0 = _S976;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S977 : u32 = stream(r_4.seed, b_2 + u32(128));
            var _S978 : Random = pcg(_S977);
            var _S979 : bool = survival_probability_0 < (_S978.value);
            if(_S979)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S980 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_2 >= _S980;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S981 : f32 = density_5 * survival_probability_0;
            density_2 = _S981;
        }
        else
        {
            density_2 = density_5;
        }
        var _S982 : Ray = ray_2;
        var _S983 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S810 = _S786;
        }
        else
        {
            _S810 = false;
        }
        if(_S810)
        {
            wrong_side_0 = _S700 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S984 : f32 = select(4.294967296e+09f, _S983, wrong_side_0);
        var _S985 : Hit;
        if(straight_0)
        {
            _S985 = hit_2;
        }
        else
        {
            _S985 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S986 : Hit = (traverseInstanceBVH((_S982), (_S725), (_S984), (_S985)));
        hit_2 = _S986;
        if(replay_0)
        {
            refracted_4 = _S786;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S811 = _S700 == u32(1);
        }
        else
        {
            _S811 = false;
        }
        if(_S811)
        {
            _S812 = (hit_2.instance_index) == (_S712.instance_index);
        }
        else
        {
            _S812 = false;
        }
        if(_S812)
        {
            _S850 = (hit_2.triangle_index) == (_S712.triangle_index);
        }
        else
        {
            _S850 = false;
        }
        if(_S850)
        {
            hit_2.uv = _S712.uv;
            var _S987 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S987;
        }
        if(replay_0)
        {
            _S851 = _S786;
        }
        else
        {
            _S851 = false;
        }
        if(_S851)
        {
            _S852 = _S700 == u32(3);
        }
        else
        {
            _S852 = false;
        }
        if(_S852)
        {
            _S853 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S853 = false;
        }
        if(_S853)
        {
            return _S697;
        }
        var _S988 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S988)
        {
            var _S989 : bool = !nee_vertex_0.none;
            var _S990 : f32 = select(0.0f, sky_pdf_0, _S989);
            var _S991 : f32 = escapeWeight_0(_S990, ray_2.unit_direction);
            var _S992 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S993 : vec3<f32> = throughput_2 * _S992;
            if(replay_0)
            {
                if(_S786)
                {
                    is_inside_5 = _S700 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S993 * vec3<f32>(_S991) / vec3<f32>(r_4.jac), density_2 / r_4.jac);
                }
                if(_S710)
                {
                    is_inside_5 = _S707;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_2 == _S698;
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
                    return Shift_x24init_0(_S993 * vec3<f32>(_S991), 1.0f);
                }
                return _S697;
            }
            var candidate_6 : Reservoir = chain_0;
            var _S994 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S995 : bool = _S994 == u32(1);
            if(_S995)
            {
                var _S996 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S997 : bool = _S996 == b_2;
                var _S998 : f32 = select(_S991, 1.0f, _S997);
                var _S999 : vec3<f32> = safeDivide(_S993 * vec3<f32>(_S998), chain_throughput_0);
                candidate_6.radiance = _S999;
            }
            else
            {
                var _S1000 : bool = prev_0.rough;
                if(_S1000)
                {
                    var _S1001 : u32 = (insertBits((u32(0)), (b_2 + u32(1)), (u32(5)), (u32(5))));
                    var _S1002 : u32 = (insertBits((_S1001), (u32(3)), (u32(10)), (u32(2))));
                    var _S1003 : u32 = (insertBits((_S1002), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1004 : bool = prev_0.inside;
                    var _S1005 : u32 = select(u32(0), u32(1), _S1004);
                    var _S1006 : u32 = (insertBits((_S1003), (_S1005), (u32(22)), (u32(1))));
                    candidate_6.path = _S1006;
                    candidate_6.jac = prev_0.pdf;
                    candidate_6.dir = ray_2.unit_direction;
                }
            }
            var _S1007 : vec3<f32> = _S993 * vec3<f32>(_S991);
            var _S1008 : Reservoir = withEnd(candidate_6, u32(3), b_2, _S1007);
            offer(&((*sel_1)), _S1008, _S1007 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1009 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1009;
        var _S1010 : u32 = b_2 + u32(1);
        b_2 = _S1010;
    }
    return _S697;
}

fn shift_0( dom_2 : Domain,  r_5 : Reservoir) -> Shift
{
    var _S1011 : vec3<f32> = vec3<f32>(0.0f);
    var _S1012 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1011, 0.0f, vec4<u32>(u32(0)), _S1011, _S1011), 0.0f, _S1011, u32(0));
    var sel_2 : Selection = _S1012;
    var _S1013 : bool = (r_5.w) <= 0.0f;
    if(_S1013)
    {
        return Shift_x24init_0(_S1011, 0.0f);
    }
    var _S1014 : Shift = walk_0(dom_2, r_5, true, 0.0f, &(sel_2));
    return _S1014;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S1015 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S1015;
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
        var _S1016 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S1017 : u32 = (_S1016 + u32(63)) / u32(64);
        var _S1018 : bool = group_0 < _S1017;
        if(_S1018)
        {
            var _S1019 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S1020 : bool = _S1019 < _S1016;
            if(_S1020)
            {
                var _S1021 : u32 = (queued_shifts[(u32(83) + start_4 + _S1019)]);
                return _S1021;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S1017;
        var start_5 : u32 = start_4 + _S1016;
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
    var _S1022 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S1023 : u32 = t_5;
        var _S1024 : bool = (bins_1[t_5]) < u32(40);
        if(_S1024)
        {
            var _S1025 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S1023]]), u32(1));
            slots_0[t_5] = _S1025;
        }
        var t_6 : u32 = t_5 + u32(1);
        t_5 = t_6;
    }
    workgroupBarrier();
    var _S1026 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S1026)
    {
        var _S1027 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S1028 : bool = _S1027 > u32(0);
        if(_S1028)
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
                var _S1029 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_6 : u32 = groups_0 + _S1029;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_6;
            }
            var _S1030 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S1027)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S1030;
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
        var _S1031 : u32 = t_5;
        var _S1032 : bool = (bins_1[t_5]) < u32(40);
        if(_S1032)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S1031]] + slots_0[t_5])] = ((((u32(p_8.x) | (((u32(p_8.y) << (u32(14))))))) | (((t_5 << (u32(28)))))));
        }
        var t_7 : u32 = t_5 + u32(1);
        t_5 = t_7;
    }
    var _S1033 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S1033)
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
            var _S1034 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S1034 + u32(63)) / u32(64);
            var bin_4 : u32 = bin_2 + u32(1);
            bin_2 = bin_4;
            groups_0 = groups_1;
        }
        shift_queue.dispatch = array<u32, 3>((min(groups_0, u32(65535))), ((groups_0 + u32(65534)) / u32(65535)), (u32(1)));
    }
    return;
}

fn project_0( view_2 : mat3x3<f32>,  camera_0 : vec3<f32>,  position_0 : vec3<f32>) -> vec2<f32>
{
    var _S1035 : vec3<f32> = (((view_2) * (position_0 - camera_0)));
    var _S1036 : vec2<f32> = vec2<f32>(0.5f);
    var _S1037 : vec2<f32> = _S1035.xy / vec2<f32>(_S1035.z) * _S1036 + _S1036;
    var _S1038 : vec2<f32> = vec2<f32>(_S1037.x, 1.0f - _S1037.y);
    var _S1039 : vec2<u32> = (uniforms_uint.render_size);
    return _S1038 * vec2<f32>(_S1039);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S1040 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S1041 : bool;
    if(_S1040)
    {
        var _S1042 : vec2<u32> = (uniforms_uint.render_size);
        _S1041 = (all((q_0 < vec2<i32>(_S1042))));
    }
    else
    {
        _S1041 = false;
    }
    if(_S1041)
    {
        var _S1043 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S1041 = (bitcast<f32>((_S1043.w))) > 0.0f;
    }
    else
    {
        _S1041 = false;
    }
    return _S1041;
}

fn temporalNeighbor_0( p_9 : vec2<i32>,  dom_3 : Domain) -> vec2<i32>
{
    var _S1044 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S1045 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S1046 : vec2<f32> = project_0(_S1044, _S1045, dom_3.x1);
    var _S1047 : vec2<i32> = vec2<i32>(floor(_S1046));
    var _S1048 : bool = previousValid_0(_S1047);
    var _S1049 : bool = !_S1048;
    if(_S1049)
    {
        return vec2<i32>(i32(-1));
    }
    var _S1050 : Domain = (previousDomain((_S1047)));
    var _S1051 : bool = (_S1050.hit.instance_index) == (dom_3.hit.instance_index);
    var _S1052 : bool;
    if(_S1051)
    {
        var _S1053 : f32 = distance(_S1050.x1, dom_3.x1);
        var _S1054 : f32 = dom_3.hit.distance * 8.0f;
        var _S1055 : vec2<u32> = (uniforms_uint.render_size);
        _S1052 = _S1053 <= (_S1054 / f32(_S1055.x));
    }
    else
    {
        _S1052 = false;
    }
    if(_S1052)
    {
        return _S1047;
    }
    var _S1056 : vec2<f32> = vec2<f32>(p_9 + _S1047) + vec2<f32>(1.0f);
    var _S1057 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S1058 : vec3<f32> = (uniforms_float.camera_position);
    var _S1059 : vec2<f32> = project_0(_S1057, _S1058, _S1050.x1);
    var _S1060 : vec2<i32> = vec2<i32>(floor(_S1056 - _S1059));
    var _S1061 : vec2<i32> = vec2<i32>(i32(-1));
    var _S1062 : bool = previousValid_0(_S1060);
    var _S1063 : vec2<i32> = select(_S1061, _S1060, _S1062);
    return _S1063;
}

fn sameDomain_0( a_6 : Domain,  b_3 : Domain) -> bool
{
    var _S1064 : bool = (all(((a_6.x0) == (b_3.x0))));
    var _S1065 : bool;
    if(_S1064)
    {
        _S1065 = (a_6.hit.instance_index) == (b_3.hit.instance_index);
    }
    else
    {
        _S1065 = false;
    }
    if(_S1065)
    {
        _S1065 = (a_6.hit.triangle_index) == (b_3.hit.triangle_index);
    }
    else
    {
        _S1065 = false;
    }
    if(_S1065)
    {
        _S1065 = (all(((a_6.hit.uv) == (b_3.hit.uv))));
    }
    else
    {
        _S1065 = false;
    }
    return _S1065;
}

fn temporalJob_0( p_10 : vec2<i32>,  t_8 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S1066 : vec3<f32> = vec3<f32>(0.0f);
    var _S1067 : Domain = Domain_x24init_0(_S1066, _S1066, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_4 : Domain = _S1067;
    var _S1068 : bool = t_8 > u32(1);
    var _S1069 : bool;
    if(_S1068)
    {
        _S1069 = true;
    }
    else
    {
        var _S1070 : bool = (storedDomain(reservoir_initial, (p_10), &(dom_4)));
        _S1069 = !_S1070;
    }
    if(_S1069)
    {
        return false;
    }
    var _S1071 : vec2<i32> = temporalNeighbor_0(p_10, dom_4);
    var _S1072 : bool = (_S1071.x) < i32(0);
    if(_S1072)
    {
        return false;
    }
    var _S1073 : bool = t_8 == u32(0);
    if(_S1073)
    {
        var _S1074 : Reservoir = (loadReservoir(reservoir_prev, (_S1071)));
        var _S1075 : ShiftJob = ShiftJob_x24init_0(dom_4, _S1074);
        (*job_2) = _S1075;
    }
    else
    {
        var _S1076 : Domain = (previousDomain((_S1071)));
        var _S1077 : Reservoir = (loadReservoir(reservoir_initial, (p_10)));
        var _S1078 : ShiftJob = ShiftJob_x24init_0(_S1076, _S1077);
        (*job_2) = _S1078;
    }
    var _S1079 : bool = ((*job_2).r.w) > 0.0f;
    if(_S1079)
    {
        if(_S1073)
        {
            _S1069 = true;
        }
        else
        {
            var _S1080 : bool = sameDomain_0((*job_2).dom, dom_4);
            _S1069 = !_S1080;
        }
    }
    else
    {
        _S1069 = false;
    }
    return _S1069;
}

fn temporalBins_0( p_11 : vec2<i32>,  _S1081 : ptr<function, array<u32, i32(3)>>)
{
    var _S1082 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S1083 : vec3<f32> = vec3<f32>(0.0f);
        var _S1084 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1083, _S1083, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1083, 0.0f, vec4<u32>(u32(0)), _S1083, _S1083));
        var job_3 : ShiftJob = _S1084;
        var _S1085 : bool = temporalJob_0(p_11, t_9, &(job_3));
        if(_S1085)
        {
            var _S1086 : u32 = shiftBin_0(job_3.r);
            bins_2[t_9] = _S1086;
        }
        var t_10 : u32 = t_9 + u32(1);
        t_9 = t_10;
    }
    (*_S1081) = bins_2;
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
        var _S1087 : u32 = t_11;
        var _S1088 : bool = (bins_3[t_11]) < u32(40);
        if(_S1088)
        {
            var _S1089 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S1087]]), u32(1));
        }
        var t_12 : u32 = t_11 + u32(1);
        t_11 = t_12;
    }
    workgroupBarrier();
    var _S1090 : bool = local_invocation_index_2 < u32(40);
    if(_S1090)
    {
        var _S1091 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S1092 : bool = _S1091 > u32(0);
        if(_S1092)
        {
            var _S1093 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S1091)));
        }
    }
    return;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S1094 : vec2<u32> = global_invocation_id_1.xy;
    var _S1095 : vec2<i32> = vec2<i32>(_S1094 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S1096 : vec2<i32> = _S1095 + vec2<i32>(i32(i_8 % u32(24)), i32(i_8 / u32(24)));
        var _S1097 : bool = (all((_S1096 >= vec2<i32>(i32(0)))));
        var _S1098 : bool;
        if(_S1097)
        {
            var _S1099 : vec2<u32> = (uniforms_uint.render_size);
            _S1098 = (all((_S1096 < vec2<i32>(_S1099))));
        }
        else
        {
            _S1098 = false;
        }
        if(_S1098)
        {
            var _S1100 : vec4<u32> = (textureLoad(reservoir_prev, (_S1096), (u32(0)), 0));
            var _S1101 : u32 = _S1100.x;
            var _S1102 : bool = (bitcast<f32>((_S1100.z))) > 0.0f;
            var _S1103 : u32 = select(u32(0), _S1101, _S1102);
            seed_2 = _S1103;
        }
        else
        {
            seed_2 = u32(0);
        }
        duplication_seeds_0[i_8] = seed_2;
        var i_9 : u32 = i_8 + u32(64);
        i_8 = i_9;
    }
    workgroupBarrier();
    var _S1104 : u32 = local_invocation_id_0.y;
    var _S1105 : u32 = local_invocation_id_0.x;
    var _S1106 : u32 = duplication_seeds_0[(_S1104 + u32(8)) * u32(24) + _S1105 + u32(8)];
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
            var _S1107 : bool = (duplication_seeds_0[(_S1104 + seed_2) * u32(24) + _S1105 + x_1]) == _S1106;
            var _S1108 : u32 = select(u32(0), u32(1), _S1107);
            var count_2 : u32 = count_1 + _S1108;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S1109 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S1110 : bool = _S1106 != u32(0);
    var _S1111 : f32 = select(0.0f, _S1109, _S1110);
    textureStore(duplication_out, (vec2<i32>(_S1094)), 0, (vec4<u32>((bitcast<u32>((_S1111))), u32(0), u32(0), u32(0))));
    return;
}

fn offerShifted( sel_3 : ptr<function, Selection>,  r_6 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_7 : Reservoir = r_6;
    var _S1112 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_7.f = _S1112;
    var _S1113 : f32 = r_6.jac * shifted_0.jac;
    candidate_7.jac = _S1113;
    offer(&((*sel_3)), candidate_7, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_6.w));
    return;
}

fn finalize( sel_4 : Selection,  c_2 : f32) -> Reservoir
{
    var r_7 : Reservoir = sel_4.r;
    var _S1114 : f32 = resamplingTarget(r_7.f);
    var _S1115 : f32 = sel_4.w_sum / _S1114;
    var _S1116 : bool = _S1114 > 0.0f;
    var _S1117 : f32 = select(0.0f, _S1115, _S1116);
    r_7.w = _S1117;
    r_7.c = c_2;
    return r_7;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S1118 : vec2<u32> = global_invocation_id_2.xy;
    var _S1119 : vec2<i32> = vec2<i32>(_S1118);
    var _S1120 : vec3<f32> = vec3<f32>(0.0f);
    var _S1121 : Domain = Domain_x24init_0(_S1120, _S1120, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_5 : Domain = _S1121;
    var _S1122 : bool = (currentDomain((_S1119), &(dom_5)));
    var _S1123 : bool = !_S1122;
    if(_S1123)
    {
        storeReservoir(reservoir_prev_out, (_S1119), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1120, 0.0f, vec4<u32>(u32(0)), _S1120, _S1120)), (dom_5.hit));
        var _S1124 : vec2<f32> = vec2<f32>(_S1118);
        var _S1125 : vec2<u32> = (uniforms_uint.render_size);
        var _S1126 : vec2<f32> = _S1124 / vec2<f32>(_S1125.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S1127 : vec3<f32> = vec3<f32>(_S1126, 1.0f);
        var _S1128 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S1129 : vec3<f32> = (normalize(((((_S1128) * (_S1127))))));
        var _S1130 : vec3<f32> = environment_0(_S1129);
        textureStore(compute_out, (_S1119), (u32(0)), (vec4<f32>(_S1130, 1.0f)));
        var _S1131 : u32 = (uniforms_uint.is_temporal);
        var _S1132 : bool = _S1131 == u32(1);
        if(_S1132)
        {
            textureStore(compute_out, (_S1119), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S1133 : Reservoir = (loadReservoir(reservoir_temp, (_S1119)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S1133.c;
    loop
    {
        var _S1134 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1134)
        {
        }
        else
        {
            break;
        }
        var _S1135 : vec2<i32> = partner_0(_S1119, t_13);
        var neighbor_0 : Domain = _S1121;
        var _S1136 : bool = (currentDomain((_S1135), &(neighbor_0)));
        if(_S1136)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S1137 : vec4<u32> = (textureLoad(reservoir_temp, (_S1135), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S1137.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S1138 : f32 = _S1133.c / max(count_3, 1.0f);
    var _S1139 : f32 = resamplingTarget(_S1133.f);
    var _S1140 : bool = count_3 == 0.0f;
    var _S1141 : f32 = select(0.0f, 1.0f, _S1140);
    var _S1142 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1120, 0.0f, vec4<u32>(u32(0)), _S1120, _S1120), 0.0f, _S1120, u32(0));
    var sel_5 : Selection = _S1142;
    var _S1143 : u32 = (uniforms_uint.frame);
    var _S1144 : u32 = hash(_S1143);
    var _S1145 : u32 = global_invocation_id_2.x;
    var _S1146 : vec2<u32> = (uniforms_uint.render_size);
    var _S1147 : u32 = stream(_S1144, _S1145 + _S1146.x * global_invocation_id_2.y);
    var _S1148 : u32 = stream(_S1147, u32(195));
    sel_5.random_state = _S1148;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S1141;
    loop
    {
        var _S1149 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S1149)
        {
        }
        else
        {
            break;
        }
        var _S1150 : vec2<i32> = partner_0(_S1119, t_13);
        var neighbor_dom_0 : Domain = _S1121;
        var _S1151 : bool = (currentDomain((_S1150), &(neighbor_dom_0)));
        if(_S1151)
        {
            var _S1152 : Reservoir = (loadReservoir(reservoir_temp, (_S1150)));
            var _S1153 : vec4<u32> = (textureLoad(shift_data, (_S1150), (t_13), 0));
            var _S1154 : vec4<f32> = (bitcast<vec4<f32>>((_S1153)));
            var _S1155 : vec4<u32> = (textureLoad(shift_data, (_S1119), (t_13), 0));
            var _S1156 : vec4<f32> = (bitcast<vec4<f32>>((_S1155)));
            var _S1157 : f32 = (_S1152.c + _S1138) / c_sum_0;
            var _S1158 : bool = _S1139 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S1158)
            {
                var _S1159 : f32 = _S1157 * _S1138 * _S1139;
                var _S1160 : f32 = _S1138 * _S1139;
                var _S1161 : f32 = resamplingTarget(_S1156.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S1159 / (_S1160 + _S1152.c * _S1161);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S1162 : f32 = resamplingTarget(_S1152.f);
            var _S1163 : vec3<f32> = _S1154.xyz;
            var _S1164 : Shift = Shift_x24init_0(_S1163, _S1154.w);
            var _S1165 : f32 = _S1157 * _S1152.c * _S1162;
            var _S1166 : f32 = _S1152.c * _S1162;
            var _S1167 : f32 = resamplingTarget(_S1163);
            offerShifted(&(sel_5), _S1152, _S1164, _S1165 / (_S1166 + _S1138 * _S1167));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_5), _S1133, Shift_x24init_0(_S1133.f, 1.0f), canonical_mis_0);
    var _S1168 : Reservoir = finalize(sel_5, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S1119), (_S1168), (dom_5.hit));
    textureStore(reservoir_prev_out, (_S1119), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_5.hit.uv))), u32(0), u32(0))));
    var _S1169 : Surface = (surfaceAt((dom_5.hit), (dom_5.x1), (sel_5.random_state)));
    var _S1170 : vec3<f32> = (normalize((dom_5.x0 - dom_5.x1)));
    var _S1171 : f32 = (sign((dot(_S1170, _S1169.smooth_n))));
    var _S1172 : vec3<f32> = _S1169.material.emissive * vec3<f32>(max(_S1171, 0.0f));
    var _S1173 : vec3<f32> = select(_S1172, _S1120, _S1169.skip);
    var _S1174 : vec3<f32> = clamp(sel_5.color + _S1173, vec3<f32>(-65519.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, (_S1119), (u32(0)), (vec4<f32>(_S1174, 1.0f)));
    var _S1175 : u32 = (uniforms_uint.is_temporal);
    var _S1176 : bool = _S1175 == u32(1);
    if(_S1176)
    {
        textureStore(compute_out, (_S1119), (u32(1)), (vec4<f32>(dom_5.x1, f32(dom_5.hit.instance_index))));
    }
    return;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1177 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1178 : bool = _S1177 != u32(4294967295);
    if(_S1178)
    {
        var _S1179 : vec2<i32> = vec2<i32>((vec2<u32>(_S1177, (_S1177 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1180 : vec3<f32> = vec3<f32>(0.0f);
        var _S1181 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1180, _S1180, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1180, 0.0f, vec4<u32>(u32(0)), _S1180, _S1180));
        var shift_job_0 : ShiftJob = _S1181;
        var _S1182 : u32 = (_S1177 >> (u32(28)));
        var _S1183 : bool = spatialJob_0(_S1179, _S1182, &(shift_job_0));
        var _S1184 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1179), (_S1182), (vec4<u32>((bitcast<vec3<u32>>((_S1184.f))), (bitcast<u32>((_S1184.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1185 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1186 : array<u32, i32(3)>;
    spatialBins_0(_S1185, &(_S1186));
    var _S1187 : array<u32, i32(3)> = _S1186;
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
        var _S1188 : bool = (_S1187[t_16]) == u32(40);
        if(_S1188)
        {
            textureStore(shift_data_out, (_S1185), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1185, _S1187, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1189 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1189));
    countShifts_0(_S1189, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1190 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1191 : bool = _S1190 != u32(4294967295);
    if(_S1191)
    {
        var _S1192 : vec2<i32> = vec2<i32>((vec2<u32>(_S1190, (_S1190 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1193 : vec3<f32> = vec3<f32>(0.0f);
        var _S1194 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1193, _S1193, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1193, 0.0f, vec4<u32>(u32(0)), _S1193, _S1193));
        var shift_job_1 : ShiftJob = _S1194;
        var _S1195 : u32 = (_S1190 >> (u32(28)));
        var _S1196 : bool = temporalJob_0(_S1192, _S1195, &(shift_job_1));
        var _S1197 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1192), (_S1195), (vec4<u32>((bitcast<vec3<u32>>((_S1197.f))), (bitcast<u32>((_S1197.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1198 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1199 : array<u32, i32(3)>;
    temporalBins_0(_S1198, &(_S1199));
    var _S1200 : array<u32, i32(3)> = _S1199;
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
        var _S1201 : bool = (_S1200[t_18]) == u32(40);
        if(_S1201)
        {
            textureStore(temporal_shifts_out, (_S1198), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1198, _S1200, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1202 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1202));
    countShifts_0(_S1202, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1203 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1204 : vec3<f32> = vec3<f32>(0.0f);
    var _S1205 : Domain = Domain_x24init_0(_S1204, _S1204, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1205;
    var _S1206 : bool = (currentDomain((_S1203), &(dom_6)));
    var _S1207 : bool = !_S1206;
    if(_S1207)
    {
        storeReservoir(reservoir_temp_out, (_S1203), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1204, 0.0f, vec4<u32>(u32(0)), _S1204, _S1204)), (dom_6.hit));
        return;
    }
    var _S1208 : Reservoir = (loadReservoir(reservoir_initial, (_S1203)));
    var _S1209 : vec2<i32> = temporalNeighbor_0(_S1203, dom_6);
    var _S1210 : bool = (_S1209.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1210)
    {
        var _S1211 : Reservoir = (loadReservoir(reservoir_prev, (_S1209)));
        var _S1212 : vec4<u32> = (textureLoad(duplication, (_S1209), 0, 0));
        var _S1213 : f32 = (bitcast<f32>((_S1212.x)));
        var _S1214 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1215 : bool = _S1214 == u32(1);
        var _S1216 : f32 = select(0.0f, _S1213, _S1215);
        var _S1217 : f32 = (mix((20.0f), (1.0f), (pow(_S1216, 0.10000000149011612f))));
        var _S1218 : f32 = min(_S1211.c, _S1217);
        var _S1219 : vec4<u32> = (textureLoad(temporal_shifts, (_S1203), (u32(0)), 0));
        var _S1220 : vec4<f32> = (bitcast<vec4<f32>>((_S1219)));
        var _S1221 : vec4<f32> = vec4<f32>(_S1208.f, 1.0f);
        var _S1222 : Domain = (previousDomain((_S1209)));
        var _S1223 : bool = sameDomain_0(_S1222, dom_6);
        var _S1224 : bool = !_S1223;
        var to_previous_0 : vec4<f32>;
        if(_S1224)
        {
            var _S1225 : vec4<u32> = (textureLoad(temporal_shifts, (_S1203), (u32(1)), 0));
            var _S1226 : vec4<f32> = (bitcast<vec4<f32>>((_S1225)));
            to_previous_0 = _S1226;
        }
        else
        {
            to_previous_0 = _S1221;
        }
        var _S1227 : f32 = resamplingTarget(_S1208.f);
        var _S1228 : f32 = resamplingTarget(_S1211.f);
        var _S1229 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1204, 0.0f, vec4<u32>(u32(0)), _S1204, _S1204), 0.0f, _S1204, u32(0));
        var sel_6 : Selection = _S1229;
        var _S1230 : u32 = (uniforms_uint.frame);
        var _S1231 : u32 = hash(_S1230);
        var _S1232 : u32 = global_invocation_id_7.x;
        var _S1233 : vec2<u32> = (uniforms_uint.render_size);
        var _S1234 : u32 = stream(_S1231, _S1232 + _S1233.x * global_invocation_id_7.y);
        var _S1235 : u32 = stream(_S1234, u32(194));
        sel_6.random_state = _S1235;
        var _S1236 : f32 = _S1208.c * _S1227;
        var _S1237 : f32 = resamplingTarget(to_previous_0.xyz);
        var _S1238 : f32 = _S1236 / (_S1236 + _S1218 * _S1237);
        var _S1239 : f32 = _S1218 * _S1228;
        var _S1240 : vec3<f32> = _S1220.xyz;
        var _S1241 : f32 = resamplingTarget(_S1240);
        var _S1242 : f32 = _S1239 / (_S1239 + _S1208.c * _S1241);
        var _S1243 : vec2<f32> = vec2<f32>(_S1238, _S1242);
        offerShifted(&(sel_6), _S1208, Shift_x24init_0(_S1208.f, 1.0f), _S1238);
        offerShifted(&(sel_6), _S1211, Shift_x24init_0(_S1240, _S1220.w), _S1242);
        var _S1244 : Reservoir = finalize(sel_6, _S1208.c + _S1218);
        r_8 = _S1244;
    }
    else
    {
        r_8 = _S1208;
    }
    storeReservoir(reservoir_temp_out, (_S1203), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1245 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1246 : vec3<f32> = vec3<f32>(0.0f);
    var _S1247 : Domain = Domain_x24init_0(_S1246, _S1246, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1247;
    var _S1248 : bool = (currentDomain((_S1245), &(dom_7)));
    var _S1249 : bool = !_S1248;
    if(_S1249)
    {
        storeReservoir(reservoir_initial_out, (_S1245), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1246, 0.0f, vec4<u32>(u32(0)), _S1246, _S1246)), (dom_7.hit));
        return;
    }
    var _S1250 : u32 = (uniforms_uint.frame);
    var _S1251 : u32 = hash(_S1250);
    var _S1252 : u32 = global_invocation_id_8.x;
    var _S1253 : vec2<u32> = (uniforms_uint.render_size);
    var _S1254 : u32 = stream(_S1251, _S1252 + _S1253.x * global_invocation_id_8.y);
    var _S1255 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1246, 0.0f, vec4<u32>(u32(0)), _S1246, _S1246);
    var _S1256 : Selection = Selection_x24init_0(_S1255, 0.0f, _S1246, u32(0));
    var initial_0 : Selection = _S1256;
    var _S1257 : u32 = stream(_S1254, u32(193));
    initial_0.random_state = _S1257;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1258 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1258)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1255;
        var _S1259 : u32 = stream(_S1254, i_10);
        r_9.seed = _S1259;
        var _S1260 : u32 = (uniforms_uint.samples);
        var _S1261 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1260), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1262 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1245), (_S1262), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1263 : Random = pcg(state_3);
    var _S1264 : Random = pcg(_S1263.state);
    var _S1265 : f32 = 6.28318548202514648f * _S1263.value;
    var _S1266 : f32 = sqrt(-2.0f * clamp(log(_S1264.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1264.state, _S1266 * cos(_S1265));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1267 : RandomSphere;
    _S1267.state = state_4;
    _S1267.value = value_1;
    return _S1267;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1268 : Random = normal_distribution(state_5);
    var _S1269 : Random = normal_distribution(_S1268.state);
    var _S1270 : Random = normal_distribution(_S1269.state);
    var _S1271 : vec3<f32> = (normalize((vec3<f32>(_S1268.value, _S1269.value, _S1270.value))));
    return RandomSphere_x24init_0(_S1270.state, _S1271);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1272 : vec3<f32> = p1_0 - p0_0;
    var _S1273 : vec3<f32> = p2_0 - p0_0;
    var _S1274 : vec2<f32> = uv1_0 - uv0_0;
    var _S1275 : vec2<f32> = uv2_0 - uv0_0;
    var _S1276 : f32 = _S1274.x;
    var _S1277 : f32 = _S1275.y;
    var _S1278 : f32 = _S1274.y;
    var _S1279 : f32 = _S1275.x;
    var _S1280 : f32 = _S1276 * _S1277 - _S1278 * _S1279;
    var _S1281 : f32 = 1.0f / _S1280;
    var _S1282 : vec3<f32> = vec3<f32>(_S1281);
    var t_20 : vec3<f32> = (_S1272 * vec3<f32>(_S1277) - _S1273 * vec3<f32>(_S1278)) * _S1282;
    var _S1283 : vec3<f32> = (_S1273 * vec3<f32>(_S1276) - _S1272 * vec3<f32>(_S1279)) * _S1282;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1284 : bool = (dot(cross(n_9, t_21), _S1283)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1284)
    {
        var _S1285 : vec3<f32> = ((-(t_21)));
        t_22 = _S1285;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1286 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1286, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_4 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1287 : vec3<f32> = t1_0 - t0_0;
    var _S1288 : vec3<f32> = t2_2 - t0_0;
    var _S1289 : vec3<f32> = t2_2 - t1_0;
    var _S1290 : f32 = min(length(_S1287), min(length(_S1288), length(_S1289)));
    var _S1291 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1292 : vec3<f32> = (normalize((n0_0)));
    var _S1293 : f32 = dot(geometry_n_4, _S1292);
    var _S1294 : vec3<f32> = (normalize((n1_0)));
    var _S1295 : f32 = dot(geometry_n_4, _S1294);
    var _S1296 : vec3<f32> = (normalize((n2_0)));
    var _S1297 : vec3<f32> = acos(abs(vec3<f32>(_S1293, _S1295, dot(geometry_n_4, _S1296))));
    var _S1298 : vec3<f32> = clamp(tan(_S1297), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1291 * _S1298, uvw_0), 0.0f, _S1290 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_10 : vec3<f32>,  material_21 : Material) -> vec3<f32>
{
    var _S1299 : vec3<f32> = ((-(dir_12)));
    var _S1300 : f32 = (sign((dot(n_10, _S1299))));
    var _S1301 : vec3<f32> = n_10 * vec3<f32>(_S1300);
    var _S1302 : AnisotropicFrame = anisotropicFrame(material_21, _S1301);
    var _S1303 : bool = (_S1302.alphas.x) > 0.0f;
    if(_S1303)
    {
        var _S1304 : f32 = material_21.transmission * (1.0f - material_21.metallic);
        var _S1305 : vec3<f32> = ((-(_S1301)));
        var _S1306 : vec3<f32> = anisotropicLocal(dir_12, _S1302.tangent, _S1305);
        var _S1307 : f32 = anisotropicG1(_S1306, _S1302.alphas);
        return vec3<f32>((_S1304 * _S1307)) * material_21.albedo;
    }
    var _S1308 : f32 = material_21.transmission * (1.0f - material_21.metallic);
    var _S1309 : f32 = material_21.roughness;
    var _S1310 : f32 = smithG1(_S1309 * _S1309, abs(dot(n_10, dir_12)));
    return vec3<f32>((_S1308 * _S1310)) * material_21.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_22 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1311 : vec3<f32>;
    if((material_22.ior) == 1.0f)
    {
        var _S1312 : vec3<f32> = straightThrough(toward_1, n_11, material_22);
        _S1311 = _S1312;
    }
    else
    {
        _S1311 = vec3<f32>(0.0f);
    }
    return _S1311 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1313 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1313;
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

