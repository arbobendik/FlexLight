var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
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
    var new_state_0 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S4 : u32 = ((((new_state_0 >> ((((new_state_0 >> (u32(28)))) + u32(4))))) ^ (new_state_0))) * u32(277803737);
    var _S5 : u32 = (((_S4 >> (u32(22)))) ^ (_S4));
    var _S6 : f32 = f32(_S5) / 4.294967296e+09f;
    return Random_x24init_0(new_state_0, _S6);
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S7 : Random = pcg(state_2);
    var _S8 : Random = pcg(_S7.state);
    var _S9 : f32 = 6.28318548202514648f * _S7.value;
    var _S10 : f32 = sqrt(-2.0f * clamp(log(_S8.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S8.state, _S10 * cos(_S9));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S11 : RandomSphere;
    _S11.state = state_3;
    _S11.value = value_1;
    return _S11;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S12 : Random = normal_distribution(state_4);
    var _S13 : Random = normal_distribution(_S12.state);
    var _S14 : Random = normal_distribution(_S13.state);
    var _S15 : vec3<f32> = (normalize((vec3<f32>(_S12.value, _S13.value, _S14.value))));
    return RandomSphere_x24init_0(_S14.state, _S15);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S16 : RandomHemisphere;
    _S16.state = state_5;
    _S16.value = value_2;
    return _S16;
}

fn random_hemisphere( state_6 : u32,  normal_0 : vec3<f32>) -> RandomHemisphere
{
    var _S17 : RandomSphere = random_sphere(state_6);
    var _S18 : bool = (dot(_S17.value, normal_0)) > 0.0f;
    if(_S18)
    {
        return RandomHemisphere_x24init_0(_S17.state, _S17.value);
    }
    else
    {
        var _S19 : vec3<f32> = ((-(_S17.value)));
        return RandomHemisphere_x24init_0(_S17.state, _S19);
    }
}

fn trowbridgeReitz( alpha_0 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S20 : f32 = alpha_0 * alpha_0;
    var _S21 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S20 * n_dot_h_0 * n_dot_h_0;
    return _S20 / max(3.14159274101257324f * _S21 * _S21, 1.17549435082228751e-38f);
}

fn smithG1( alpha_1 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S22 : f32 = alpha_1 * alpha_1;
    var _S23 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S22 + (1.0f - _S22) * n_dot_x_0 * n_dot_x_0));
    var _S24 : bool = alpha_1 > 0.0f;
    var _S25 : f32 = select(1.0f, _S23, _S24);
    return _S25;
}

fn G1( alpha_2 : f32,  n_dot_x_1 : f32) -> f32
{
    var _S26 : f32 = smithG1(alpha_2, n_dot_x_1);
    return _S26;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S27 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S28 : f32 = eta_i_0 / eta_o_0 * _S27;
    var _S29 : bool = _S28 < 1.0f;
    var kr_0 : f32;
    if(_S29)
    {
        var _S30 : f32 = sqrt(max(0.0f, 1.0f - _S28 * _S28));
        var _S31 : f32 = eta_o_0 * cos_theta_0;
        var _S32 : f32 = eta_i_0 * _S30;
        var _S33 : f32 = (_S31 - _S32) / (_S31 + _S32);
        var _S34 : f32 = eta_i_0 * cos_theta_0;
        var _S35 : f32 = eta_o_0 * _S30;
        var _S36 : f32 = (_S34 - _S35) / (_S34 + _S35);
        var _S37 : f32 = (_S33 * _S33 + _S36 * _S36) / 2.0f;
        kr_0 = _S37;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_3 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S38 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z))));
    var _S39 : f32 = _S38.x;
    var _S40 : f32 = _S38.y;
    var _S41 : f32 = _S39 * _S39 + _S40 * _S40;
    const _S42 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S43 : vec3<f32> = vec3<f32>(- _S40, _S39, 0.0f);
    var _S44 : f32 = (inverseSqrt((_S41)));
    var _S45 : vec3<f32> = _S43 * vec3<f32>(_S44);
    var _S46 : bool = _S41 > 0.0f;
    var _S47 : vec3<f32> = select(_S42, _S45, _S46);
    var _S48 : vec3<f32> = cross(_S38, _S47);
    var _S49 : f32 = sqrt(U1_0);
    var _S50 : f32 = 6.28318548202514648f * U2_0;
    var _S51 : f32 = _S49 * cos(_S50);
    var t2_0 : f32 = _S49 * sin(_S50);
    var _S52 : f32 = 0.5f * (1.0f + _S38.z);
    var t2_1 : f32 = (1.0f - _S52) * sqrt(max(0.0f, 1.0f - _S51 * _S51)) + _S52 * t2_0;
    var _S53 : vec3<f32> = vec3<f32>(_S51) * _S47 + vec3<f32>(t2_1) * _S48;
    var _S54 : f32 = ((_S51));
    var _S55 : f32 = ((_S51));
    var _S56 : vec3<f32> = _S53 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S54 * _S55 - t2_1 * t2_1))) * _S38;
    var _S57 : vec3<f32> = (normalize((vec3<f32>(alpha_3 * _S56.x, alpha_3 * _S56.y, max(0.0f, _S56.z)))));
    return _S57;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S58 : f32 = sqrt(random_1_0);
    var _S59 : f32 = 6.28318548202514648f * random_2_0;
    var _S60 : f32 = _S58 * cos(_S59);
    var _S61 : f32 = _S58 * sin(_S59);
    var _S62 : f32 = sqrt(max(0.0f, 1.0f - _S60 * _S60 - _S61 * _S61));
    return vec3<f32>(_S60, _S62, _S61);
}

fn tangentToWorld( v_0 : vec3<f32>,  n_0 : vec3<f32>) -> vec3<f32>
{
    const a_0 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S63 : bool = (abs(dot(n_0, a_0))) > 0.9999847412109375f;
    var a_1 : vec3<f32>;
    if(_S63)
    {
        const _S64 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_1 = _S64;
    }
    else
    {
        a_1 = a_0;
    }
    var _S65 : vec3<f32> = (normalize((cross(n_0, a_1))));
    var _S66 : vec3<f32> = cross(n_0, _S65);
    return vec3<f32>(v_0.x) * _S65 + vec3<f32>(v_0.y) * n_0 + vec3<f32>(v_0.z) * _S66;
}

fn worldToTangent( v_1 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_2 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S67 : bool = (abs(dot(n_1, a_2))) > 0.9999847412109375f;
    var a_3 : vec3<f32>;
    if(_S67)
    {
        const _S68 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_3 = _S68;
    }
    else
    {
        a_3 = a_2;
    }
    var _S69 : vec3<f32> = (normalize((cross(n_1, a_3))));
    var _S70 : vec3<f32> = cross(n_1, _S69);
    return vec3<f32>(dot(v_1, _S69), dot(v_1, n_1), dot(v_1, _S70));
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_2 : vec3<f32>) -> mat3x3<f32>
{
    var _S71 : vec3<f32> = p1_0 - p0_0;
    var _S72 : vec3<f32> = p2_0 - p0_0;
    var _S73 : vec2<f32> = uv1_0 - uv0_0;
    var _S74 : vec2<f32> = uv2_0 - uv0_0;
    var _S75 : f32 = _S73.x;
    var _S76 : f32 = _S74.y;
    var _S77 : f32 = _S73.y;
    var _S78 : f32 = _S74.x;
    var _S79 : f32 = _S75 * _S76 - _S77 * _S78;
    var _S80 : f32 = 1.0f / _S79;
    var _S81 : vec3<f32> = vec3<f32>(_S80);
    var t_0 : vec3<f32> = (_S71 * vec3<f32>(_S76) - _S72 * vec3<f32>(_S77)) * _S81;
    var _S82 : vec3<f32> = (_S72 * vec3<f32>(_S75) - _S71 * vec3<f32>(_S78)) * _S81;
    var t_1 : vec3<f32> = (normalize((t_0 - n_2 * vec3<f32>(dot(n_2, t_0)))));
    var _S83 : bool = (dot(cross(n_2, t_1), _S82)) > 0.0f;
    var t_2 : vec3<f32>;
    if(_S83)
    {
        var _S84 : vec3<f32> = ((-(t_1)));
        t_2 = _S84;
    }
    else
    {
        t_2 = t_1;
    }
    var _S85 : vec3<f32> = cross(n_2, t_2);
    return mat3x3<f32>(t_2, _S85, n_2);
}

fn tangentToWorldNormalMap( v_2 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_2)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_0 : vec3<f32>,  uvw_0 : vec3<f32>,  position_0 : vec3<f32>) -> f32
{
    var _S86 : vec3<f32> = t1_0 - t0_0;
    var _S87 : vec3<f32> = t2_2 - t0_0;
    var _S88 : vec3<f32> = t2_2 - t1_0;
    var _S89 : f32 = min(length(_S86), min(length(_S87), length(_S88)));
    var _S90 : vec3<f32> = vec3<f32>(distance(position_0, t0_0), distance(position_0, t1_0), distance(position_0, t2_2));
    var _S91 : vec3<f32> = (normalize((n0_0)));
    var _S92 : f32 = dot(geometry_n_0, _S91);
    var _S93 : vec3<f32> = (normalize((n1_0)));
    var _S94 : f32 = dot(geometry_n_0, _S93);
    var _S95 : vec3<f32> = (normalize((n2_0)));
    var _S96 : vec3<f32> = acos(abs(vec3<f32>(_S92, _S94, dot(geometry_n_0, _S95))));
    var _S97 : vec3<f32> = clamp(tan(_S96), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S90 * _S97, uvw_0), 0.0f, _S89 * 0.125f);
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  alpha_4 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S98 : Random = pcg((*random_state_0));
    var _S99 : Random = pcg(_S98.state);
    (*random_state_0) = _S99.state;
    var _S100 : vec3<f32> = worldToTangent(v_3, n_i_0);
    var _S101 : vec3<f32> = sampleGGXVNDF(_S100.xzy, alpha_4, _S98.value, _S99.value);
    var _S102 : vec3<f32> = _S101.xzy;
    var _S103 : vec3<f32> = tangentToWorld(_S102, n_i_0);
    return _S103;
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
     view : vec3<f32>,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_0 : vec3<f32>) -> BSDFLobes
{
    var _S104 : BSDFLobes;
    _S104.v_dot_h = v_dot_h_0;
    _S104.n_dot_h = n_dot_h_1;
    _S104.refracted = refracted_0;
    _S104.F = F_0;
    _S104.F_greyscale = F_greyscale_0;
    _S104.reflect_weight = reflect_weight_0;
    _S104.diffuse_weight = diffuse_weight_0;
    _S104.refract_weight = refract_weight_0;
    _S104.p_diffuse = p_diffuse_0;
    _S104.p_reflect = p_reflect_0;
    _S104.p_refract = p_refract_0;
    _S104.translucent_share = translucent_share_0;
    _S104.sheen = sheen_0;
    _S104.view = view_0;
    return _S104;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_0 : Material,  eta_i_1 : f32,  eta_o_1 : f32) -> BSDFLobes
{
    var _S105 : f32 = dot(ggx_n_0, v_4);
    var _S106 : f32 = dot(n_i_1, ggx_n_0);
    var _S107 : f32 = eta_i_1 / eta_o_1;
    var _S108 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S107))));
    var _S109 : f32 = min(sqrt(material_0.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S110 : f32 = _S109 * _S109;
    var _S111 : f32 = (1.0f + _S109) / (1.0f - _S109);
    var _S112 : f32 = abs(_S105);
    var _S113 : bool = eta_i_1 > eta_o_1;
    var _S114 : f32;
    if(_S113)
    {
        _S114 = _S111;
    }
    else
    {
        _S114 = 1.0f;
    }
    var _S115 : f32;
    if(_S113)
    {
        _S115 = 1.0f;
    }
    else
    {
        _S115 = _S111;
    }
    var _S116 : f32 = fresnel(_S112, _S114, _S115);
    var _S117 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S105 * _S105)) >= (eta_o_1 * eta_o_1);
    var _S118 : vec3<f32>;
    if(_S117)
    {
        _S118 = vec3<f32>(1.0f);
    }
    else
    {
        var _S119 : vec3<f32> = material_0.specular_tint * vec3<f32>(_S110);
        _S118 = _S119 + (vec3<f32>(1.0f) - _S119) * vec3<f32>((_S116 - _S110)) / vec3<f32>((1.0f - _S110));
    }
    var F_1 : vec3<f32> = (mix((_S118), (material_0.albedo), (material_0.metallic)));
    var _S120 : f32 = rgb_to_greyscale(F_1);
    var _S121 : f32 = 1.0f - material_0.metallic;
    var _S122 : vec3<f32> = vec3<f32>(1.0f) - _S118;
    var _S123 : vec3<f32> = vec3<f32>(((1.0f - material_0.transmission) * _S121)) * _S122;
    var _S124 : vec3<f32> = vec3<f32>((material_0.transmission * _S121)) * _S122;
    var _S125 : f32 = max(_S120, 0.0f);
    var _S126 : f32 = rgb_to_greyscale(_S123);
    var _S127 : f32 = max(_S126, 0.0f);
    var _S128 : f32 = rgb_to_greyscale(_S124);
    var _S129 : f32 = (sign((length(_S108))));
    var _S130 : f32 = max(_S128 * _S129, 0.0f);
    var _S131 : f32 = _S125 + _S127 + _S130;
    var _S132 : f32 = 1.0f / max(_S131, 0.0000152587890625f);
    var _S133 : f32 = _S127 * _S132;
    var _S134 : f32 = _S125 * _S132;
    var _S135 : f32 = _S130 * _S132;
    var _S136 : vec3<f32> = vec3<f32>(0.0f);
    return BSDFLobes_x24init_0(_S105, _S106, _S108, F_1, _S120, 1.0f, _S123, _S124, _S133, _S134, _S135, 0.0f, _S136, _S136);
}

fn translucentShare( material_1 : Material) -> f32
{
    var _S137 : f32 = rgb_to_greyscale(material_1.translucent);
    var _S138 : f32 = rgb_to_greyscale(material_1.albedo);
    var _S139 : f32 = _S137 / (_S138 + _S137);
    var _S140 : bool = _S137 > 0.0f;
    var _S141 : f32 = select(0.0f, _S139, _S140);
    return _S141;
}

fn sheenAlbedo( mu_0 : f32,  r_0 : f32) -> f32
{
    var _S142 : f32 = sqrt(0.05000000074505806f);
    var _S143 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S144 : f32 = (clamp(sqrt(max(r_0, 0.0f)), _S142, 1.0f) - _S142) / (1.0f - _S142) * 23.0f;
    var _S145 : u32 = min(u32(_S143), u32(22));
    var _S146 : u32 = min(u32(_S144), u32(22));
    var _S147 : f32 = _S143 - f32(_S145);
    var _S148 : f32 = _S144 - f32(_S146);
    var _S149 : u32 = _S145 * u32(24) + _S146;
    var _S150 : u32 = _S149 + u32(24);
    var _S151 : f32 = SHEEN_ALBEDO_0[_S149] + (SHEEN_ALBEDO_0[_S150] - SHEEN_ALBEDO_0[_S149]) * _S147;
    var _S152 : u32 = _S149 + u32(1);
    var _S153 : f32 = SHEEN_ALBEDO_0[_S152] + (SHEEN_ALBEDO_0[_S150 + u32(1)] - SHEEN_ALBEDO_0[_S152]) * _S147;
    return exp(_S151 + (_S153 - _S151) * _S148);
}

fn sheenLobes( lobes_0 : BSDFLobes,  v_5 : vec3<f32>,  n_i_dot_v_0 : f32,  material_2 : Material) -> BSDFLobes
{
    var _S154 : f32 = rgb_to_greyscale(material_2.sheen);
    var sheened_0 : BSDFLobes = lobes_0;
    var _S155 : bool = _S154 > 0.0f;
    if(_S155)
    {
        var _S156 : f32 = sheenAlbedo(n_i_dot_v_0, material_2.sheen_roughness);
        var _S157 : f32 = min(_S156, 1.0f);
        var _S158 : vec3<f32> = vec3<f32>(1.0f) - material_2.sheen * vec3<f32>(_S157);
        var _S159 : vec3<f32> = lobes_0.F * _S158;
        var _S160 : f32 = rgb_to_greyscale(_S159);
        var _S161 : f32 = max(lobes_0.reflect_weight * _S160, 0.0f);
        var _S162 : vec3<f32> = lobes_0.diffuse_weight * _S158;
        var _S163 : f32 = rgb_to_greyscale(_S162);
        var _S164 : f32 = max(_S163, 0.0f);
        var _S165 : vec3<f32> = lobes_0.refract_weight * _S158;
        var _S166 : f32 = rgb_to_greyscale(_S165);
        var _S167 : f32 = (sign((length(lobes_0.refracted))));
        var _S168 : f32 = max(_S166 * _S167, 0.0f);
        var _S169 : f32 = _S154 * _S157;
        var _S170 : f32 = 1.0f / max(_S161 + _S164 + _S168 + _S169, 0.0000152587890625f);
        sheened_0.F = _S159;
        var _S171 : f32 = rgb_to_greyscale(sheened_0.F);
        sheened_0.F_greyscale = _S171;
        sheened_0.diffuse_weight = _S162;
        sheened_0.refract_weight = _S165;
        var _S172 : f32 = (_S164 + _S169) * _S170;
        sheened_0.p_diffuse = _S172;
        var _S173 : f32 = _S161 * _S170;
        sheened_0.p_reflect = _S173;
        var _S174 : f32 = _S168 * _S170;
        sheened_0.p_refract = _S174;
        var _S175 : vec3<f32> = material_2.sheen / vec3<f32>(max(_S156, 1.0f));
        sheened_0.sheen = _S175;
        sheened_0.view = v_5;
    }
    return sheened_0;
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_1 : f32,  alpha_5 : f32,  lobes_1 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S176 : bool = lobe_0 == u32(0);
    if(_S176)
    {
        var _S177 : f32 = lobes_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S178 : f32 = lobes_1.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S179 : f32 = 1.0f - lobes_1.translucent_share;
        var _S180 : bool = n_i_dot_l_0 < 0.0f;
        var _S181 : f32 = select(_S179, lobes_1.translucent_share, _S180);
        var _S182 : f32 = _S178 * _S181;
        var _S183 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S184 : f32 = select(_S177, _S182, _S183);
        var _S185 : bool = n_i_dot_v_1 > 0.0f;
        var _S186 : f32 = select(0.0f, _S184, _S185);
        return _S186;
    }
    var _S187 : f32 = smithG1(alpha_5, n_i_dot_v_1);
    var _S188 : f32 = _S187 * lobes_1.v_dot_h;
    var _S189 : f32 = trowbridgeReitz(alpha_5, lobes_1.n_dot_h);
    var _S190 : f32 = _S188 * _S189 / n_i_dot_v_1;
    var _S191 : bool = alpha_5 > 0.0f;
    var _S192 : bool;
    if(_S191)
    {
        _S192 = (lobes_1.v_dot_h) > 0.0f;
    }
    else
    {
        _S192 = false;
    }
    if(_S192)
    {
        _S192 = (lobes_1.n_dot_h) > 0.0f;
    }
    else
    {
        _S192 = false;
    }
    if(_S192)
    {
        _S192 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S192 = false;
    }
    var _S193 : f32 = select(0.0f, _S190, _S192);
    var _S194 : bool = lobe_0 == u32(1);
    if(_S194)
    {
        var _S195 : f32 = eta_i_2 * lobes_1.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S196 : f32 = lobes_1.p_refract * _S193 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S195 * _S195);
        var _S197 : bool = eta_i_2 != eta_o_2;
        if(_S197)
        {
            _S192 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S192 = false;
        }
        var _S198 : f32 = select(0.0f, _S196, _S192);
        return _S198;
    }
    var _S199 : f32 = lobes_1.p_reflect * _S193 / (4.0f * lobes_1.v_dot_h);
    var _S200 : bool = _S193 > 0.0f;
    var _S201 : f32 = select(0.0f, _S199, _S200);
    return _S201;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_6 : vec3<f32>,  n_3 : vec3<f32>,  r_1 : f32) -> f32
{
    var _S202 : f32 = 1.0f / max(r_1, 0.05000000074505806f);
    var _S203 : vec3<f32> = (normalize((l_0 + v_6)));
    var _S204 : f32 = dot(n_3, _S203);
    var _S205 : f32 = max(dot(n_3, l_0), 0.0f);
    var _S206 : f32 = max(dot(n_3, v_6), 0.0f);
    return (2.0f + _S202) * pow(max(1.0f - _S204 * _S204, 0.0f), 0.5f * _S202) * 0.5f * 0.31830987334251404f / max(4.0f * (_S205 + _S206 - _S205 * _S206), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_6 : f32,  material_3 : Material,  lobes_2 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S207 : bool = lobe_1 == u32(0);
    if(_S207)
    {
        var _S208 : bool = (dot(n_i_2, l_1)) < 0.0f;
        var _S209 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S208);
        var _S210 : f32 = 1.0f - lobes_2.translucent_share;
        var _S211 : f32 = select(_S210, lobes_2.translucent_share, _S208);
        var _S212 : vec3<f32> = _S209 / vec3<f32>(_S211);
        var _S213 : bool = (lobes_2.translucent_share) > 0.0f;
        var _S214 : vec3<f32> = select(material_3.albedo, _S212, _S213);
        var _S215 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S216 : bool = _S215 > 0.0f;
        var _S217 : bool;
        if(_S216)
        {
            _S217 = !_S208;
        }
        else
        {
            _S217 = false;
        }
        if(_S217)
        {
            var _S218 : vec3<f32> = lobes_2.diffuse_weight * _S214;
            var _S219 : vec3<f32> = lobes_2.sheen * vec3<f32>(3.14159274101257324f);
            var _S220 : f32 = sheenBRDF(l_1, lobes_2.view, n_i_2, material_3.sheen_roughness);
            var _S221 : vec3<f32> = _S219 * vec3<f32>(_S220);
            var _S222 : f32 = select(1.0f, _S210, _S213);
            return (_S218 + _S221 / vec3<f32>(_S222)) / vec3<f32>(lobes_2.p_diffuse);
        }
        return lobes_2.diffuse_weight * _S214 / vec3<f32>(lobes_2.p_diffuse);
    }
    var _S223 : bool = lobe_1 == u32(1);
    if(_S223)
    {
        var _S224 : f32 = - dot(n_i_2, l_1);
        var _S225 : f32 = G1(alpha_6, max(_S224, 0.0f));
        return lobes_2.refract_weight * vec3<f32>(_S225) * material_3.albedo / vec3<f32>(lobes_2.p_refract);
    }
    var _S226 : f32 = dot(n_i_2, l_1);
    var _S227 : f32 = G1(alpha_6, max(_S226, 0.0f));
    return vec3<f32>((lobes_2.reflect_weight * _S227)) * lobes_2.F / vec3<f32>(lobes_2.p_reflect);
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

fn SampleBSDF_x24init_0( unit_direction_0 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_1 : bool,  lobe_2 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S228 : SampleBSDF;
    _S228.unit_direction = unit_direction_0;
    _S228.throughput = throughput_0;
    _S228.random_state = random_state_1;
    _S228.refracted = refracted_1;
    _S228.lobe = lobe_2;
    _S228.pdf = pdf_0;
    return _S228;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S229 : vec3<f32> = ((-(in_dir_1)));
    var _S230 : f32 = dot(n_4, _S229);
    var _S231 : f32 = (sign((_S230)));
    var _S232 : vec3<f32> = n_4 * vec3<f32>(_S231);
    var _S233 : f32 = material_4.roughness;
    var _S234 : f32 = _S233 * _S233;
    var _S235 : vec3<f32> = (normalize((_S229 + out_dir_0)));
    var _S236 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S236)
    {
        var _S237 : vec3<f32> = sampleHalfVector(_S229, _S232, _S234, &(random_state_2));
        ggx_n_1 = _S237;
    }
    else
    {
        var _S238 : bool = lobe_3 == u32(1);
        if(_S238)
        {
            var _S239 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S229 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S240 : vec3<f32> = (normalize((_S239)));
            var _S241 : f32 = (sign((dot(_S239, _S232))));
            var _S242 : vec3<f32> = _S240 * vec3<f32>(_S241);
            ggx_n_1 = _S242;
        }
        else
        {
            ggx_n_1 = _S235;
        }
    }
    var _S243 : BSDFLobes = bsdfLobes(in_dir_1, _S229, _S232, ggx_n_1, material_4, eta_i_3, eta_o_3);
    var lobes_3 : BSDFLobes = _S243;
    var _S244 : f32 = translucentShare(material_4);
    lobes_3.translucent_share = _S244;
    var _S245 : f32 = abs(_S230);
    var _S246 : BSDFLobes = sheenLobes(lobes_3, _S229, _S245, material_4);
    lobes_3 = _S246;
    var _S247 : f32 = lobeDensity(dot(_S232, out_dir_0), dot(out_dir_0, ggx_n_1), _S245, _S234, lobes_3, eta_i_3, eta_o_3, lobe_3);
    var _S248 : bool = !(_S247 > 0.0f);
    if(_S248)
    {
        var _S249 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S249, _S249, u32(0), false, u32(0), 0.0f);
    }
    var _S250 : vec3<f32> = lobeThroughput(out_dir_0, _S232, _S234, material_4, lobes_3, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S250, random_state_2, lobe_3 == u32(1), lobe_3, _S247);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_5 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S251 : vec3<f32> = ((-(in_dir_2)));
    var _S252 : bool = (dot(g_n_0, _S251) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S252)
    {
        var _S253 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_5, material_5, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S254 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_5, material_5, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S253.throughput * vec3<f32>(_S253.pdf) + _S254.throughput * vec3<f32>(_S254.pdf);
    }
    var _S255 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_5, material_5, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S255.throughput * vec3<f32>(_S255.pdf);
}

fn translucentCorrection( in_dir_3 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_6 : vec3<f32>,  g_n_1 : vec3<f32>,  material_6 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S256 : f32 = dot(n_6, out_dir_2);
    var _S257 : vec3<f32> = ((-(in_dir_3)));
    var _S258 : bool = (_S256 * dot(n_6, _S257)) < 0.0f;
    var _S259 : SampleBSDF = connectBSDF(in_dir_3, out_dir_2, n_6, material_6, eta_i_5, eta_o_5, u32(0), random_state_4);
    var _S260 : vec3<f32> = ((-(in_dir_3)));
    var _S261 : bool = (dot(g_n_1, _S260) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S262 : vec3<f32> = vec3<f32>(0.0f);
    var _S263 : vec3<f32> = _S259.throughput * vec3<f32>(_S259.pdf);
    var _S264 : f32 = select(1.0f, -1.0f, _S261);
    var _S265 : vec3<f32> = _S263 * vec3<f32>(_S264);
    var _S266 : vec3<f32> = select(_S262, _S265, _S258);
    return _S266;
}

fn translucentBSDF( in_dir_4 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_7 : vec3<f32>,  g_n_2 : vec3<f32>,  material_7 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_5 : u32) -> vec3<f32>
{
    var _S267 : vec3<f32> = BSDF(in_dir_4, out_dir_3, n_7, g_n_2, material_7, eta_i_6, eta_o_6, random_state_5);
    var _S268 : vec3<f32> = translucentCorrection(in_dir_4, out_dir_3, n_7, g_n_2, material_7, eta_i_6, eta_o_6, random_state_5);
    return _S267 + _S268;
}

fn sampleBSDF( in_dir_5 : vec3<f32>,  n_8 : vec3<f32>,  material_8 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_6 : u32 = random_init_1;
    var _S269 : vec3<f32> = ((-(in_dir_5)));
    var _S270 : f32 = dot(n_8, _S269);
    var _S271 : f32 = (sign((_S270)));
    var n_i_3 : vec3<f32> = n_8 * vec3<f32>(_S271);
    var _S272 : f32 = abs(_S270);
    var _S273 : f32 = material_8.roughness;
    var _S274 : f32 = _S273 * _S273;
    var _S275 : vec3<f32> = sampleHalfVector(_S269, n_i_3, _S274, &(random_state_6));
    var _S276 : BSDFLobes = bsdfLobes(in_dir_5, _S269, n_i_3, _S275, material_8, eta_i_7, eta_o_7);
    var lobes_4 : BSDFLobes = _S276;
    var _S277 : f32 = translucentShare(material_8);
    lobes_4.translucent_share = _S277;
    var _S278 : BSDFLobes = sheenLobes(lobes_4, _S269, _S272, material_8);
    lobes_4 = _S278;
    var _S279 : vec3<f32> = vec3<f32>(1.0f);
    var _S280 : SampleBSDF = SampleBSDF_x24init_0(_S279, _S279, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S280;
    var _S281 : Random = pcg(random_state_6);
    random_state_6 = _S281.state;
    var _S282 : bool = (_S281.value) < (lobes_4.p_diffuse);
    if(_S282)
    {
        var _S283 : Random = pcg(random_state_6);
        var _S284 : Random = pcg(_S283.state);
        sample_0.random_state = _S284.state;
        var _S285 : vec3<f32> = sampleCosWeightedHemisphere(_S283.value, _S284.value);
        var _S286 : bool = (_S281.value) < (lobes_4.p_diffuse * lobes_4.translucent_share);
        var _S287 : f32 = _S285.y;
        var _S288 : f32 = - _S287;
        var _S289 : f32 = select(_S287, _S288, _S286);
        var _S290 : vec3<f32> = tangentToWorld(vec3<f32>(_S285.x, _S289, _S285.z), n_i_3);
        sample_0.unit_direction = _S290;
        var _S291 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S274, material_8, lobes_4, u32(0));
        sample_0.throughput = _S291;
        var _S292 : f32 = lobeDensity(_S289, 0.0f, _S272, _S274, lobes_4, eta_i_7, eta_o_7, u32(0));
        sample_0.pdf = _S292;
        sample_0.refracted = _S286;
        return sample_0;
    }
    var _S293 : bool = (_S281.value) < (lobes_4.p_diffuse + lobes_4.p_refract);
    if(_S293)
    {
        sample_0.unit_direction = lobes_4.refracted;
        var _S294 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S275), _S272, _S274, lobes_4, eta_i_7, eta_o_7, u32(1));
        sample_0.pdf = _S294;
        var _S295 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S274, material_8, lobes_4, u32(1));
        sample_0.throughput = _S295;
        sample_0.random_state = random_state_6;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S296 : vec3<f32> = (normalize((reflect(in_dir_5, _S275))));
    sample_0.unit_direction = _S296;
    var _S297 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_3, _S274, material_8, lobes_4, u32(2));
    sample_0.throughput = _S297;
    sample_0.random_state = random_state_6;
    sample_0.lobe = u32(2);
    var _S298 : f32 = lobeDensity(0.0f, 0.0f, _S272, _S274, lobes_4, eta_i_7, eta_o_7, u32(2));
    sample_0.pdf = _S298;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S299 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S299));
}

fn samplesLights( material_9 : Material) -> bool
{
    var _S300 : bool = (material_9.roughness) > 0.0f;
    var _S301 : bool;
    if(_S300)
    {
        _S301 = true;
    }
    else
    {
        var _S302 : bool = (material_9.metallic) < 1.0f;
        if(_S302)
        {
            _S301 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S301 = false;
        }
    }
    return _S301;
}

fn neeBSDF( in_dir_6 : vec3<f32>,  dir_0 : vec3<f32>,  n_9 : vec3<f32>,  material_10 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_7 : u32) -> vec3<f32>
{
    var _S303 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S303;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S304 : bool = lobe_4 == u32(0);
        var _S305 : bool;
        if(_S304)
        {
            var _S306 : f32 = rgb_to_greyscale(material_10.translucent);
            _S305 = _S306 > 0.0f;
        }
        else
        {
            _S305 = false;
        }
        var _S307 : bool;
        if(_S305)
        {
            var _S308 : f32 = dot(n_9, dir_0);
            var _S309 : vec3<f32> = ((-(in_dir_6)));
            _S307 = ((_S308 * dot(n_9, _S309)) < 0.0f) == refracted_2;
        }
        else
        {
            _S307 = (lobe_4 == u32(1)) == refracted_2;
        }
        var f_1 : vec3<f32>;
        if(_S307)
        {
            var _S310 : SampleBSDF = connectBSDF(in_dir_6, dir_0, n_9, material_10, eta_i_8, eta_o_8, lobe_4, random_state_7);
            var _S311 : bool = (_S310.pdf) > 0.0f;
            if(_S311)
            {
                if(power_0)
                {
                    var _S312 : f32 = _S310.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S310.throughput * vec3<f32>(_S310.pdf) / vec3<f32>((pdf_1 * (1.0f + _S312 * _S312)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S310.throughput * vec3<f32>(_S310.pdf) / vec3<f32>((_S310.pdf + pdf_1));
                    f_1 = f_3;
                }
            }
            else
            {
                f_1 = f_0;
            }
        }
        else
        {
            f_1 = f_0;
        }
        var lobe_5 : u32 = lobe_4 + u32(1);
        lobe_4 = lobe_5;
        f_0 = f_1;
    }
    return f_0;
}

fn straightThrough( dir_1 : vec3<f32>,  n_10 : vec3<f32>,  material_11 : Material) -> vec3<f32>
{
    var _S313 : f32 = material_11.transmission * (1.0f - material_11.metallic);
    var _S314 : f32 = material_11.roughness;
    var _S315 : f32 = G1(_S314 * _S314, abs(dot(n_10, dir_1)));
    return vec3<f32>((_S313 * _S315)) * material_11.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S316 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S316 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_11 : vec3<f32>,  material_12 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S317 : vec3<f32>;
    if((material_12.ior) == 1.0f)
    {
        var _S318 : vec3<f32> = straightThrough(toward_0, n_11, material_12);
        _S317 = _S318;
    }
    else
    {
        _S317 = vec3<f32>(0.0f);
    }
    return _S317 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S319 : u32 = hash(index_0);
    var _S320 : u32 = hash((seed_0 ^ (_S319)));
    return _S320;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S321 : vec3<f32> = a_4 / b_0;
    var _S322 : vec3<f32> = vec3<f32>(0.0f);
    var _S323 : vec3<bool> = b_0 == _S322;
    var _S324 : vec3<f32> = select(_S321, _S322, _S323);
    return _S324;
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
    var _S325 : f32 = rgb_to_greyscale(weight_0);
    var _S326 : bool = _S325 > 0.0f;
    var _S327 : bool;
    if(_S326)
    {
        _S327 = _S325 < 3.00000000549775576e+38f;
    }
    else
    {
        _S327 = false;
    }
    var _S328 : bool = !_S327;
    if(_S328)
    {
        return;
    }
    var _S329 : f32 = (*sel_0).w_sum + _S325;
    (*sel_0).w_sum = _S329;
    var _S330 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S330;
    var _S331 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S331.state;
    var _S332 : bool = (_S331.value * (*sel_0).w_sum) <= _S325;
    if(_S332)
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

fn offerShifted( sel_1 : ptr<function, Selection>,  r_2 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_2;
    var _S333 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S333;
    var _S334 : f32 = r_2.jac * shifted_0.jac;
    candidate_1.jac = _S334;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_2.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_3 : Reservoir = sel_2.r;
    var _S335 : f32 = rgb_to_greyscale(r_3.f);
    var _S336 : f32 = sel_2.w_sum / _S335;
    var _S337 : bool = _S335 > 0.0f;
    var _S338 : f32 = select(0.0f, _S336, _S337);
    r_3.w = _S338;
    r_3.c = c_0;
    return r_3;
}

fn withEnd( r_4 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_4;
    var _S339 : u32 = (insertBits((r_4.path), (end_1), (u32(0)), (u32(5))));
    var _S340 : u32 = (insertBits((_S339), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S340;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S341 : bool = transmission_0 > 0.0f;
    var _S342 : bool;
    if(_S341)
    {
        _S342 = true;
    }
    else
    {
        _S342 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S343 : f32;
    if(_S342)
    {
        _S343 = 1.0f;
    }
    else
    {
        _S343 = -1.0f;
    }
    return _S343;
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
    var _S344 : bool;
    if(open_0)
    {
        _S344 = prev_rough_0;
    }
    else
    {
        _S344 = false;
    }
    if(_S344)
    {
        _S344 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S344 = false;
    }
    return _S344;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S345 : bool = pdf_2 > 0.0f;
    var _S346 : bool;
    if(_S345)
    {
        if(diffuse_0)
        {
            _S346 = true;
        }
        else
        {
            _S346 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S346 = false;
    }
    return _S346;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S347 : bool = pdf_3 > 0.0f;
    var _S348 : bool;
    if(_S347)
    {
        if(diffuse_1)
        {
            _S348 = true;
        }
        else
        {
            _S348 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S348 = false;
    }
    return _S348;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S349 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S349.x, max(_S349.y, _S349.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S350 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S350;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S351 : f32 = c_1 * p_c_0;
    var _S352 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S351 / (_S351 + c_t_0 * g_previous_0), _S352 / (_S352 + c_1 * g_current_0));
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
    var _S353 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S354 : bool = cos_a_0 > cos_b_0;
    var _S355 : f32 = select(_S353, 1.0f, _S354);
    return _S355;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S356 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S357 : bool = cos_a_1 > cos_b_1;
    var _S358 : f32 = select(_S356, 0.0f, _S357);
    return _S358;
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

fn importance( node_0 : LightBounds,  p_0 : vec3<f32>,  normal_1 : vec3<f32>) -> f32
{
    var _S359 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S360 : vec3<f32> = node_0.high - node_0.low;
    var _S361 : vec3<f32> = p_0 - _S359;
    var _S362 : vec3<f32> = (normalize((_S361)));
    var _S363 : f32 = dot(_S361, _S361);
    var _S364 : f32 = dot(_S360, _S360) / 4.0f;
    var _S365 : f32 = abs(dot(node_0.w, _S362));
    var _S366 : f32 = sine(node_0.cos_theta_o);
    var _S367 : f32 = sqrt(max(1.0f - _S364 / _S363, 0.0f));
    var _S368 : bool = _S363 < _S364;
    var _S369 : f32 = select(_S367, -1.0f, _S368);
    var _S370 : f32 = sine(_S369);
    var _S371 : f32 = sine(_S365);
    var _S372 : f32 = cosSubClamped(_S371, _S365, _S366, node_0.cos_theta_o);
    var _S373 : f32 = sine(_S365);
    var _S374 : f32 = sinSubClamped(_S373, _S365, _S366, node_0.cos_theta_o);
    var _S375 : f32 = cosSubClamped(_S374, _S372, _S370, _S369);
    var _S376 : bool = _S375 <= 0.0f;
    if(_S376)
    {
        return 0.0f;
    }
    var _S377 : f32 = - dot(_S362, normal_1);
    var _S378 : f32 = node_0.phi * _S375 / max(_S363, length(_S360) / 2.0f);
    var _S379 : f32 = sine(_S377);
    var _S380 : f32 = cosSubClamped(_S379, _S377, _S370, _S369);
    var _S381 : bool = (dot(normal_1, normal_1)) == 0.0f;
    var _S382 : f32 = select(_S380, 1.0f, _S381);
    return max(_S378 * _S382, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_2, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S383 : f32 = importance(first_0, p_1, normal_3);
    var _S384 : f32 = importance(second_0, p_1, normal_3);
    var _S385 : vec2<f32> = vec2<f32>(_S383, _S384);
    var _S386 : bool = _S383 == 0.0f;
    var _S387 : bool;
    if(_S386)
    {
        _S387 = _S384 == 0.0f;
    }
    else
    {
        _S387 = false;
    }
    if(_S387)
    {
        return u32(2);
    }
    var _S388 : f32 = _S383 + _S384;
    var _S389 : bool = _S384 > 0.0f;
    if(_S389)
    {
        _S387 = ((*pick_0) * _S388) >= _S383;
    }
    else
    {
        _S387 = false;
    }
    var _S390 : u32 = select(u32(0), u32(1), _S387);
    var _S391 : f32 = min(((*pick_0) * _S388 - f32(_S390) * _S383) / _S385[_S390], 0.99999994039535522f);
    (*pick_0) = _S391;
    var _S392 : f32 = (*probability_1) * (_S385[_S390] / _S388);
    (*probability_1) = _S392;
    return _S390;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_4 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S393 : f32 = importance(first_1, p_2, normal_4);
    var _S394 : f32 = importance(second_1, p_2, normal_4);
    var _S395 : vec2<f32> = vec2<f32>(_S393, _S394);
    var _S396 : f32 = _S395[child_0] / (_S393 + _S394);
    var _S397 : bool = (_S395[child_0]) > 0.0f;
    var _S398 : f32 = select(0.0f, _S396, _S397);
    return _S398;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S399 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S400 : bool = b_1 > 0.0f;
    var _S401 : f32 = select(1.0f, _S399, _S400);
    return _S401;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S402 : vec3<f32> = center_0 - p_3;
    var _S403 : f32 = radius_1 * radius_1 / dot(_S402, _S402);
    var _S404 : bool = _S403 >= 1.0f;
    if(_S404)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S403)) / (6.28318548202514648f * _S403);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S405 : vec3<f32> = center_1 - p_4;
    var _S406 : f32 = radius_2 * radius_2 / dot(_S405, _S405);
    var _S407 : f32 = u1_0 * _S406 / (1.0f + sqrt(max(1.0f - _S406, 0.0f)));
    var _S408 : f32 = 2.0f * u1_0;
    var _S409 : bool = _S406 >= 1.0f;
    var _S410 : f32 = select(_S407, _S408, _S409);
    var _S411 : f32 = sqrt(max(_S410 * (2.0f - _S410), 0.0f));
    var _S412 : f32 = 6.28318548202514648f * u2_0;
    var _S413 : vec3<f32> = vec3<f32>(_S411 * cos(_S412), 1.0f - _S410, _S411 * sin(_S412));
    var _S414 : vec3<f32> = (normalize((_S405)));
    var _S415 : vec3<f32> = tangentToWorld(_S413, _S414);
    return _S415;
}

