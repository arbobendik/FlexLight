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

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_0 : f32) -> SheenProfile
{
    var _S92 : SheenProfile;
    _S92.on = on_0;
    _S92.albedo = albedo_0;
    return _S92;
}

fn sheenProfile( v_3 : vec3<f32>,  n_i_0 : vec3<f32>,  material_0 : Material) -> SheenProfile
{
    var _S93 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S94 : f32 = rgb_to_greyscale(material_0.sheen);
    var _S95 : bool = _S94 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S95)
    {
        var _S96 : f32 = clamp(sqrt(max(dot(n_i_0, v_3), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S97 : u32 = min(u32(_S96), u32(22));
        var _S98 : f32 = sqrt(0.05000000074505806f);
        var _S99 : f32 = (clamp(sqrt(max(material_0.sheen_roughness, 0.0f)), _S98, 1.0f) - _S98) / (1.0f - _S98) * 23.0f;
        var _S100 : u32 = min(u32(_S99), u32(22));
        var _S101 : u32 = _S97 * u32(24) + _S100;
        var _S102 : f32 = _S96 - f32(_S97);
        var _S103 : f32 = _S99 - f32(_S100);
        var _S104 : u32 = _S101 + u32(24);
        var _S105 : f32 = SHEEN_ALBEDO_0[_S101] + (SHEEN_ALBEDO_0[_S104] - SHEEN_ALBEDO_0[_S101]) * _S102;
        var _S106 : u32 = _S101 + u32(1);
        var _S107 : f32 = SHEEN_ALBEDO_0[_S106] + (SHEEN_ALBEDO_0[_S104 + u32(1)] - SHEEN_ALBEDO_0[_S106]) * _S102;
        var _S108 : SheenProfile = SheenProfile_x24init_0(true, exp(_S105 + (_S107 - _S105) * _S103));
        profile_0 = _S108;
    }
    else
    {
        profile_0 = _S93;
    }
    return profile_0;
}

fn sampleHalfVector( v_4 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_3 : f32,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S109 : Random = pcg((*random_state_0));
    var _S110 : Random = pcg(_S109.state);
    (*random_state_0) = _S110.state;
    var _S111 : vec3<f32> = worldToTangent(v_4, n_i_1);
    var _S112 : vec3<f32> = sampleGGXVNDF(_S111.xzy, alpha_3, _S109.value, _S110.value);
    var _S113 : vec3<f32> = _S112.xzy;
    var _S114 : vec3<f32> = tangentToWorld(_S113, n_i_1);
    return _S114;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_3 : vec3<f32>,  material_1 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S115 : vec3<f32> = ((-(in_dir_0)));
    var _S116 : f32 = (sign((dot(n_3, _S115))));
    var _S117 : f32 = material_1.roughness;
    var _S118 : vec3<f32> = sampleHalfVector(_S115, n_3 * vec3<f32>(_S116), _S117 * _S117, &(state_5));
    return _S118;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S119 : vec3<f32> = ((-(in_dir_1)));
    var _S120 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S119 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S121 : vec3<f32> = (normalize((_S120)));
    var _S122 : f32 = (sign((dot(n_4, _S119))));
    var _S123 : f32 = (sign((dot(_S120, n_4 * vec3<f32>(_S122)))));
    return _S121 * vec3<f32>(_S123);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S124 : vec3<f32> = ((-(in_dir_2)));
    var _S125 : vec3<f32> = (normalize((_S124 + out_dir_1)));
    return _S125;
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
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  p_sheen_velvet_0 : f32,  view_0 : vec3<f32>) -> BSDFLobes
{
    var _S126 : BSDFLobes;
    _S126.v_dot_h = v_dot_h_0;
    _S126.n_dot_h = n_dot_h_1;
    _S126.refracted = refracted_0;
    _S126.F = F_0;
    _S126.F_greyscale = F_greyscale_0;
    _S126.reflect_weight = reflect_weight_0;
    _S126.diffuse_weight = diffuse_weight_0;
    _S126.refract_weight = refract_weight_0;
    _S126.p_diffuse = p_diffuse_0;
    _S126.p_reflect = p_reflect_0;
    _S126.p_refract = p_refract_0;
    _S126.translucent_share = translucent_share_0;
    _S126.sheen = sheen_0;
    _S126.p_sheen_velvet = p_sheen_velvet_0;
    _S126.view = view_0;
    return _S126;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_5 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_2 : Material,  eta_i_2 : f32,  eta_o_2 : f32,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S127 : f32 = dot(ggx_n_0, v_5);
    var _S128 : f32 = dot(n_i_2, ggx_n_0);
    var _S129 : f32 = eta_i_2 / eta_o_2;
    var _S130 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S129))));
    var _S131 : f32 = min(sqrt(material_2.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S132 : f32 = _S131 * _S131;
    var _S133 : f32 = (1.0f + _S131) / (1.0f - _S131);
    var _S134 : f32 = abs(_S127);
    var _S135 : bool = eta_i_2 > eta_o_2;
    var sheen_component_0 : f32;
    if(_S135)
    {
        sheen_component_0 = _S133;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var _S136 : f32;
    if(_S135)
    {
        _S136 = 1.0f;
    }
    else
    {
        _S136 = _S133;
    }
    var _S137 : f32 = fresnel(_S134, sheen_component_0, _S136);
    var _S138 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S127 * _S127)) >= (eta_o_2 * eta_o_2);
    var _S139 : vec3<f32>;
    if(_S138)
    {
        _S139 = vec3<f32>(1.0f);
    }
    else
    {
        var _S140 : vec3<f32> = material_2.specular_tint * vec3<f32>(_S132);
        _S139 = _S140 + (vec3<f32>(1.0f) - _S140) * vec3<f32>((_S137 - _S132)) / vec3<f32>((1.0f - _S132));
    }
    var _S141 : vec3<f32> = vec3<f32>(1.0f);
    var _S142 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_1 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S143 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S144 : vec3<f32> = vec3<f32>(1.0f) - material_2.sheen * vec3<f32>(_S143);
        var _S145 : f32 = rgb_to_greyscale(material_2.sheen);
        var _S146 : f32 = _S145 * _S143;
        var _S147 : vec3<f32> = material_2.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S144;
        sheen_component_0 = _S146;
        sheen_1 = _S147;
        view_1 = v_5;
    }
    else
    {
        scale_0 = _S141;
        sheen_component_0 = 0.0f;
        sheen_1 = _S142;
        view_1 = _S142;
    }
    var _S148 : vec3<f32> = (mix((_S139), (material_2.albedo), (material_2.metallic)));
    var F_1 : vec3<f32> = _S148 * scale_0;
    var _S149 : f32 = rgb_to_greyscale(F_1);
    var _S150 : f32 = 1.0f - material_2.metallic;
    var _S151 : vec3<f32> = vec3<f32>(1.0f) - _S139;
    var _S152 : vec3<f32> = vec3<f32>(((1.0f - material_2.transmission) * _S150)) * _S151 * scale_0;
    var _S153 : vec3<f32> = vec3<f32>((material_2.transmission * _S150)) * _S151 * scale_0;
    var _S154 : f32 = max(_S149, 0.0f);
    var _S155 : f32 = rgb_to_greyscale(_S152);
    var _S156 : f32 = max(_S155, 0.0f);
    var _S157 : f32 = rgb_to_greyscale(_S153);
    var _S158 : f32 = (sign((length(_S130))));
    var _S159 : f32 = max(_S157 * _S158, 0.0f);
    var _S160 : f32 = _S154 + _S156 + _S159;
    var _S161 : f32 = min(sheen_component_0, 1.0f);
    var _S162 : bool = sheen_component_0 > 0.0f;
    var _S163 : bool;
    if(_S162)
    {
        _S163 = !(_S160 > 0.0f);
    }
    else
    {
        _S163 = false;
    }
    var _S164 : f32 = select(_S161, 1.0f, _S163);
    var _S165 : f32 = (1.0f - _S164) / max(_S160, 0.0000152587890625f);
    var _S166 : f32 = _S156 * _S165;
    var _S167 : f32 = _S154 * _S165;
    var _S168 : f32 = _S159 * _S165;
    return BSDFLobes_x24init_0(_S127, _S128, _S130, F_1, _S149, 1.0f, _S152, _S153, _S166, _S167, _S168, 0.0f, sheen_1, _S164, view_1);
}

fn translucentShare( material_3 : Material) -> f32
{
    var _S169 : f32 = rgb_to_greyscale(material_3.translucent);
    var _S170 : f32 = rgb_to_greyscale(material_3.albedo);
    var _S171 : f32 = _S169 / (_S170 + _S169);
    var _S172 : bool = _S169 > 0.0f;
    var _S173 : f32 = select(0.0f, _S171, _S172);
    return _S173;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S174 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S175 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S176 : f32 = 1.0f - lobes_0.translucent_share;
    var _S177 : bool = n_i_dot_l_0 < 0.0f;
    var _S178 : f32 = select(_S176, lobes_0.translucent_share, _S177);
    var _S179 : f32 = _S175 * _S178;
    var _S180 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S181 : f32 = select(_S174, _S179, _S180);
    var _S182 : bool = n_i_dot_v_0 > 0.0f;
    var _S183 : f32 = select(0.0f, _S181, _S182);
    return _S183;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_4 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S184 : bool = (dot(n_i_3, l_0)) < 0.0f;
    var _S185 : vec3<f32> = select(material_4.albedo, material_4.translucent, _S184);
    var _S186 : f32 = 1.0f - lobes_1.translucent_share;
    var _S187 : f32 = select(_S186, lobes_1.translucent_share, _S184);
    var _S188 : vec3<f32> = _S185 / vec3<f32>(_S187);
    var _S189 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S190 : vec3<f32> = select(material_4.albedo, _S188, _S189);
    return lobes_1.diffuse_weight * _S190 / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S191 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S192 : f32 = _S191 * lobes_2.v_dot_h;
    var _S193 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S194 : f32 = _S192 * _S193 / n_i_dot_v_1;
    var _S195 : bool = alpha_6 > 0.0f;
    var _S196 : bool;
    if(_S195)
    {
        _S196 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S196 = false;
    }
    if(_S196)
    {
        _S196 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S196 = false;
    }
    if(_S196)
    {
        _S196 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S196 = false;
    }
    var _S197 : f32 = select(0.0f, _S194, _S196);
    return _S197;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S198 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S199 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S200 : f32 = lobes_3.p_refract * _S198 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S199 * _S199);
    var _S201 : bool = eta_i_4 != eta_o_4;
    var _S202 : bool;
    if(_S201)
    {
        _S202 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S202 = false;
    }
    var _S203 : f32 = select(0.0f, _S200, _S202);
    return _S203;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_8 : f32,  material_5 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S204 : f32 = - dot(n_i_4, l_1);
    var _S205 : f32 = smithG1(alpha_8, max(_S204, 0.0f));
    return lobes_4.refract_weight * vec3<f32>(_S205) * material_5.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S206 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S207 : bool = n_i_dot_l_2 > 0.0f;
    var _S208 : bool;
    if(_S207)
    {
        _S208 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S208 = false;
    }
    var _S209 : f32 = select(0.0f, _S206, _S208);
    return _S209;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_10 : f32,  material_6 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S210 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S211 : f32 = dot(n_i_5, _S210);
    var _S212 : f32 = max(dot(n_i_5, l_2), 0.0f);
    var _S213 : f32 = max(dot(n_i_5, lobes_6.view), 0.0f);
    var _S214 : f32 = 1.0f / max(material_6.sheen_roughness, 0.05000000074505806f);
    var _S215 : f32 = (2.0f + _S214) * pow(max(1.0f - _S211 * _S211, 0.0f), 0.5f * _S214) * 0.5f * 0.31830987334251404f / max(4.0f * (_S212 + _S213 - _S212 * _S213), 0.0000152587890625f);
    return lobes_6.sheen * vec3<f32>((_S215 * _S212 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S216 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S217 : f32 = lobes_7.p_reflect * _S216 / (4.0f * lobes_7.v_dot_h);
    var _S218 : bool = _S216 > 0.0f;
    var _S219 : f32 = select(0.0f, _S217, _S218);
    return _S219;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_12 : f32,  material_7 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S220 : f32 = dot(n_i_6, l_3);
    var _S221 : f32 = smithG1(alpha_12, max(_S220, 0.0f));
    return vec3<f32>((lobes_8.reflect_weight * _S221)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_5 : vec3<f32>,  material_8 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_0 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S222 : vec3<f32> = ((-(in_dir_4)));
    var _S223 : f32 = dot(n_5, _S222);
    var _S224 : f32 = (sign((_S223)));
    var _S225 : vec3<f32> = n_5 * vec3<f32>(_S224);
    var _S226 : f32 = dot(_S225, out_dir_2);
    var _S227 : f32 = material_8.roughness;
    var _S228 : f32 = _S227 * _S227;
    var _S229 : SheenProfile = sheenProfile(_S222, _S225, material_8);
    var _S230 : f32 = rgb_to_greyscale(material_8.translucent);
    var _S231 : bool = _S230 > 0.0f;
    var _S232 : bool = (dot(n_5, out_dir_2) * _S223) < 0.0f;
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S233 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S233;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S234 : vec3<f32> = vec3<f32>(0.0f);
    var _S235 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S234, _S234, 0.0f, 0.0f, _S234, _S234, 0.0f, 0.0f, 0.0f, 0.0f, _S234, 0.0f, _S234);
    var lobe_terms_0 : BSDFLobes = _S235;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S234;
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
        var _S236 : u32;
        if(i_0 == u32(3))
        {
            _S236 = u32(4);
        }
        else
        {
            _S236 = i_0;
        }
        var _S237 : bool = _S236 == u32(0);
        var _S238 : bool;
        if(_S237)
        {
            _S238 = _S231;
        }
        else
        {
            _S238 = false;
        }
        var _S239 : bool;
        if(_S238)
        {
            _S239 = _S232;
        }
        else
        {
            _S239 = _S236 == u32(1);
        }
        var _S240 : bool = _S239 != refracted_1;
        if(_S240)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S241 : u32;
        if(_S236 == u32(4))
        {
            _S241 = u32(2);
        }
        else
        {
            _S241 = _S236;
        }
        var _S242 : bool = _S241 != half_of_0;
        var half_of_1 : u32;
        if(_S242)
        {
            var _S243 : bool = _S241 == u32(0);
            if(_S243)
            {
                var _S244 : vec3<f32> = sampledHalf(in_dir_4, n_5, material_8, random_state_2);
                ggx_n_1 = _S244;
            }
            else
            {
                var _S245 : bool = _S241 == u32(1);
                if(_S245)
                {
                    var _S246 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_5, eta_i_7, eta_o_7);
                    ggx_n_1 = _S246;
                }
                else
                {
                    var _S247 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S247;
                }
            }
            var _S248 : vec3<f32> = ((-(in_dir_4)));
            var _S249 : BSDFLobes = bsdfLobes(in_dir_4, _S248, _S225, ggx_n_1, material_8, eta_i_7, eta_o_7, _S229);
            lobe_terms_0 = _S249;
            var _S250 : f32 = translucentShare(material_8);
            lobe_terms_0.translucent_share = _S250;
            half_of_1 = _S241;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S236)
        {
        case u32(0):
            {
                var _S251 : f32 = diffusePDF(_S226, 0.0f, abs(_S223), _S228, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(0)] = _S251;
                var _S252 : vec3<f32> = diffuseBSDF(out_dir_2, _S225, _S228, material_8, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S252;
            }
        case u32(1):
            {
                var _S253 : f32 = refractPDF(_S226, dot(out_dir_2, ggx_n_1), abs(_S223), _S228, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(1)] = _S253;
                var _S254 : vec3<f32> = refractBSDF(out_dir_2, _S225, _S228, material_8, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S254;
            }
        case u32(4):
            {
                var _S255 : f32 = sheenVelvetPDF(_S226, 0.0f, abs(_S223), _S228, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(3)] = _S255;
                var _S256 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S225, _S228, material_8, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S256;
            }
        default :
            {
                var _S257 : f32 = reflectPDF(_S226, 0.0f, abs(_S223), _S228, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(2)] = _S257;
                var _S258 : vec3<f32> = reflectBSDF(out_dir_2, _S225, _S228, material_8, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S258;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S234;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S259 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S259)
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
    var _S260 : SampleBSDF;
    _S260.unit_direction = unit_direction_0;
    _S260.throughput = throughput_0;
    _S260.random_state = random_state_3;
    _S260.refracted = refracted_2;
    _S260.lobe = lobe_0;
    _S260.pdf = pdf_0;
    return _S260;
}

fn diffuseSample( u_0 : f32,  n_i_7 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_9 : Material,  lobes_9 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S261 : vec3<f32> = vec3<f32>(1.0f);
    var _S262 : SampleBSDF = SampleBSDF_x24init_0(_S261, _S261, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S262;
    var _S263 : Random = pcg(random_state_4);
    var _S264 : Random = pcg(_S263.state);
    sample_0.random_state = _S264.state;
    var _S265 : vec3<f32> = sampleCosWeightedHemisphere(_S263.value, _S264.value);
    var _S266 : bool = u_0 < (lobes_9.p_diffuse * lobes_9.translucent_share);
    var _S267 : f32 = _S265.y;
    var _S268 : f32 = - _S267;
    var _S269 : f32 = select(_S267, _S268, _S266);
    var _S270 : vec3<f32> = tangentToWorld(vec3<f32>(_S265.x, _S269, _S265.z), n_i_7);
    sample_0.unit_direction = _S270;
    sample_0.refracted = _S266;
    sample_0.lobe = u32(0);
    var _S271 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    sample_0.throughput = _S271;
    var _S272 : f32 = diffusePDF(_S269, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_8, eta_o_8);
    sample_0.pdf = _S272;
    return sample_0;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_10 : Material,  lobes_10 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S273 : vec3<f32> = vec3<f32>(1.0f);
    var _S274 : SampleBSDF = SampleBSDF_x24init_0(_S273, _S273, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S274;
    var _S275 : Random = pcg(random_state_5);
    var _S276 : Random = pcg(_S275.state);
    sample_1.random_state = _S276.state;
    var _S277 : f32 = _S275.value;
    var _S278 : f32 = sqrt(max(0.0f, 1.0f - _S277 * _S277));
    var _S279 : f32 = 6.28318548202514648f * _S276.value;
    var _S280 : vec3<f32> = tangentToWorld(vec3<f32>(_S278 * cos(_S279), _S275.value, _S278 * sin(_S279)), n_i_8);
    sample_1.unit_direction = _S280;
    sample_1.lobe = u32(4);
    var _S281 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_14, material_10, lobes_10);
    sample_1.throughput = _S281;
    var _S282 : f32 = sheenVelvetPDF(_S275.value, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_9, eta_o_9);
    sample_1.pdf = _S282;
    return sample_1;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_9 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_11 : Material,  lobes_11 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S283 : vec3<f32> = vec3<f32>(1.0f);
    var _S284 : SampleBSDF = SampleBSDF_x24init_0(_S283, _S283, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S284;
    sample_2.unit_direction = lobes_11.refracted;
    sample_2.random_state = random_state_6;
    sample_2.refracted = true;
    sample_2.lobe = u32(1);
    var _S285 : vec3<f32> = refractBSDF(sample_2.unit_direction, n_i_9, alpha_15, material_11, lobes_11);
    sample_2.throughput = _S285;
    var _S286 : f32 = refractPDF(0.0f, dot(sample_2.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_10, eta_o_10);
    sample_2.pdf = _S286;
    return sample_2;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_12 : Material,  lobes_12 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_7 : u32) -> SampleBSDF
{
    var _S287 : vec3<f32> = vec3<f32>(1.0f);
    var _S288 : SampleBSDF = SampleBSDF_x24init_0(_S287, _S287, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S288;
    var _S289 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_3.unit_direction = _S289;
    sample_3.random_state = random_state_7;
    sample_3.lobe = u32(2);
    var _S290 : vec3<f32> = reflectBSDF(sample_3.unit_direction, n_i_10, alpha_16, material_12, lobes_12);
    sample_3.throughput = _S290;
    var _S291 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_11, eta_o_11);
    sample_3.pdf = _S291;
    return sample_3;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_13 : Material,  eta_i_12 : f32,  eta_o_12 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_8 : u32 = random_init_0;
    var _S292 : vec3<f32> = ((-(in_dir_6)));
    var _S293 : f32 = dot(n_6, _S292);
    var _S294 : f32 = (sign((_S293)));
    var n_i_11 : vec3<f32> = n_6 * vec3<f32>(_S294);
    var _S295 : f32 = abs(_S293);
    var _S296 : f32 = material_13.roughness;
    var _S297 : f32 = _S296 * _S296;
    var _S298 : SheenProfile = sheenProfile(_S292, n_i_11, material_13);
    var _S299 : vec3<f32> = sampleHalfVector(_S292, n_i_11, _S297, &(random_state_8));
    var _S300 : BSDFLobes = bsdfLobes(in_dir_6, _S292, n_i_11, _S299, material_13, eta_i_12, eta_o_12, _S298);
    var lobes_13 : BSDFLobes = _S300;
    var _S301 : f32 = translucentShare(material_13);
    lobes_13.translucent_share = _S301;
    var _S302 : Random = pcg(random_state_8);
    random_state_8 = _S302.state;
    var _S303 : bool = (_S302.value) < (lobes_13.p_sheen_velvet);
    if(_S303)
    {
        var _S304 : SampleBSDF = sheenVelvetSample(n_i_11, _S295, _S297, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S304;
    }
    var _S305 : f32 = _S302.value - lobes_13.p_sheen_velvet;
    var _S306 : bool = _S305 < (lobes_13.p_diffuse);
    if(_S306)
    {
        var _S307 : SampleBSDF = diffuseSample(_S305, n_i_11, _S295, _S297, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S307;
    }
    var _S308 : bool = _S305 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S308)
    {
        var _S309 : SampleBSDF = refractSample(_S299, n_i_11, _S295, _S297, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S309;
    }
    var _S310 : SampleBSDF = reflectSample(in_dir_6, _S299, n_i_11, _S295, _S297, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
    return _S310;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S311 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S311));
}

fn neeDecision( material_14 : Material,  n_dot_v_0 : f32,  eta_i_13 : f32,  eta_o_13 : f32) -> bool
{
    var _S312 : f32 = fresnel(abs(n_dot_v_0), eta_i_13, eta_o_13);
    var _S313 : vec3<f32> = (mix((vec3<f32>(_S312)), (material_14.albedo), (material_14.metallic)));
    var _S314 : f32 = rgb_to_greyscale(_S313);
    var _S315 : f32 = max((1.0f - _S314) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission), 0.0f);
    var _S316 : bool = _S315 > 0.03999999910593033f;
    var _S317 : bool;
    if(_S316)
    {
        _S317 = true;
    }
    else
    {
        _S317 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S317;
}

fn straightThrough( dir_0 : vec3<f32>,  n_7 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S318 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S319 : f32 = material_15.roughness;
    var _S320 : f32 = smithG1(_S319 * _S319, abs(dot(n_7, dir_0)));
    return vec3<f32>((_S318 * _S320)) * material_15.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S321 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S321 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_8 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S322 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S323 : vec3<f32> = straightThrough(toward_0, n_8, material_16);
        _S322 = _S323;
    }
    else
    {
        _S322 = vec3<f32>(0.0f);
    }
    return _S322 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S324 : u32 = hash(index_0);
    var _S325 : u32 = hash((seed_0 ^ (_S324)));
    return _S325;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S326 : vec3<f32> = a_4 / b_0;
    var _S327 : vec3<f32> = vec3<f32>(0.0f);
    var _S328 : vec3<bool> = b_0 == _S327;
    var _S329 : vec3<f32> = select(_S326, _S327, _S328);
    return _S329;
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
    var _S330 : f32 = rgb_to_greyscale(weight_0);
    var _S331 : bool = _S330 > 0.0f;
    var _S332 : bool;
    if(_S331)
    {
        _S332 = _S330 < 3.00000000549775576e+38f;
    }
    else
    {
        _S332 = false;
    }
    var _S333 : bool = !_S332;
    if(_S333)
    {
        return;
    }
    var _S334 : f32 = (*sel_0).w_sum + _S330;
    (*sel_0).w_sum = _S334;
    var _S335 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S335;
    var _S336 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S336.state;
    var _S337 : bool = (_S336.value * (*sel_0).w_sum) <= _S330;
    if(_S337)
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
    var _S338 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S338;
    var _S339 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S339;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S340 : f32 = rgb_to_greyscale(r_1.f);
    var _S341 : f32 = sel_2.w_sum / _S340;
    var _S342 : bool = _S340 > 0.0f;
    var _S343 : f32 = select(0.0f, _S341, _S342);
    r_1.w = _S343;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S344 : u32 = (insertBits((r_2.path), (end_1), (u32(0)), (u32(5))));
    var _S345 : u32 = (insertBits((_S344), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S345;
    candidate_2.f = f_1;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S346 : bool = transmission_0 > 0.0f;
    var _S347 : bool;
    if(_S346)
    {
        _S347 = true;
    }
    else
    {
        _S347 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S348 : f32;
    if(_S347)
    {
        _S348 = 1.0f;
    }
    else
    {
        _S348 = -1.0f;
    }
    return _S348;
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
    var _S349 : bool;
    if(open_0)
    {
        _S349 = prev_rough_0;
    }
    else
    {
        _S349 = false;
    }
    if(_S349)
    {
        _S349 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S349 = false;
    }
    return _S349;
}

fn withinInverseFootprint( pdf_1 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S350 : bool = pdf_1 > 0.0f;
    var _S351 : bool;
    if(_S350)
    {
        if(diffuse_0)
        {
            _S351 = true;
        }
        else
        {
            _S351 = (pdf_1 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S351 = false;
    }
    return _S351;
}

fn roughLobe( pdf_2 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S352 : bool = pdf_2 > 0.0f;
    var _S353 : bool;
    if(_S352)
    {
        if(diffuse_1)
        {
            _S353 = true;
        }
        else
        {
            _S353 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S353 = false;
    }
    return _S353;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S354 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S354.x, max(_S354.y, _S354.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S355 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S355;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S356 : f32 = c_1 * p_c_0;
    var _S357 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S356 / (_S356 + c_t_0 * g_previous_0), _S357 / (_S357 + c_1 * g_current_0));
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
    var _S358 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S359 : bool = cos_a_0 > cos_b_0;
    var _S360 : f32 = select(_S358, 1.0f, _S359);
    return _S360;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S361 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S362 : bool = cos_a_1 > cos_b_1;
    var _S363 : f32 = select(_S361, 0.0f, _S362);
    return _S363;
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
    var _S364 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S365 : vec3<f32> = node_0.high - node_0.low;
    var _S366 : vec3<f32> = p_0 - _S364;
    var _S367 : vec3<f32> = (normalize((_S366)));
    var _S368 : f32 = dot(_S366, _S366);
    var _S369 : f32 = dot(_S365, _S365) / 4.0f;
    var _S370 : f32 = abs(dot(node_0.w, _S367));
    var _S371 : f32 = sine(node_0.cos_theta_o);
    var _S372 : f32 = sqrt(max(1.0f - _S369 / _S368, 0.0f));
    var _S373 : bool = _S368 < _S369;
    var _S374 : f32 = select(_S372, -1.0f, _S373);
    var _S375 : f32 = sine(_S374);
    var _S376 : f32 = sine(_S370);
    var _S377 : f32 = cosSubClamped(_S376, _S370, _S371, node_0.cos_theta_o);
    var _S378 : f32 = sine(_S370);
    var _S379 : f32 = sinSubClamped(_S378, _S370, _S371, node_0.cos_theta_o);
    var _S380 : f32 = cosSubClamped(_S379, _S377, _S375, _S374);
    var _S381 : bool = _S380 <= 0.0f;
    if(_S381)
    {
        return 0.0f;
    }
    var _S382 : f32 = - dot(_S367, normal_0);
    var _S383 : f32 = node_0.phi * _S380 / max(_S368, length(_S365) / 2.0f);
    var _S384 : f32 = sine(_S382);
    var _S385 : f32 = cosSubClamped(_S384, _S382, _S375, _S374);
    var _S386 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S387 : f32 = select(_S385, 1.0f, _S386);
    return max(_S383 * _S387, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S388 : f32 = importance(first_0, p_1, normal_2);
    var _S389 : f32 = importance(second_0, p_1, normal_2);
    var _S390 : vec2<f32> = vec2<f32>(_S388, _S389);
    var _S391 : bool = _S388 == 0.0f;
    var _S392 : bool;
    if(_S391)
    {
        _S392 = _S389 == 0.0f;
    }
    else
    {
        _S392 = false;
    }
    if(_S392)
    {
        return u32(2);
    }
    var _S393 : f32 = _S388 + _S389;
    var _S394 : bool = _S389 > 0.0f;
    if(_S394)
    {
        _S392 = ((*pick_0) * _S393) >= _S388;
    }
    else
    {
        _S392 = false;
    }
    var _S395 : u32 = select(u32(0), u32(1), _S392);
    var _S396 : f32 = min(((*pick_0) * _S393 - f32(_S395) * _S388) / _S390[_S395], 0.99999994039535522f);
    (*pick_0) = _S396;
    var _S397 : f32 = (*probability_1) * (_S390[_S395] / _S393);
    (*probability_1) = _S397;
    return _S395;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S398 : f32 = importance(first_1, p_2, normal_3);
    var _S399 : f32 = importance(second_1, p_2, normal_3);
    var _S400 : vec2<f32> = vec2<f32>(_S398, _S399);
    var _S401 : f32 = _S400[child_0] / (_S398 + _S399);
    var _S402 : bool = (_S400[child_0]) > 0.0f;
    var _S403 : f32 = select(0.0f, _S401, _S402);
    return _S403;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S404 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S405 : bool = b_1 > 0.0f;
    var _S406 : f32 = select(1.0f, _S404, _S405);
    return _S406;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S407 : vec3<f32> = center_0 - p_3;
    var _S408 : f32 = radius_1 * radius_1 / dot(_S407, _S407);
    var _S409 : bool = _S408 >= 1.0f;
    if(_S409)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S408)) / (6.28318548202514648f * _S408);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S410 : vec3<f32> = center_1 - p_4;
    var _S411 : f32 = radius_2 * radius_2 / dot(_S410, _S410);
    var _S412 : f32 = u1_0 * _S411 / (1.0f + sqrt(max(1.0f - _S411, 0.0f)));
    var _S413 : f32 = 2.0f * u1_0;
    var _S414 : bool = _S411 >= 1.0f;
    var _S415 : f32 = select(_S412, _S413, _S414);
    var _S416 : f32 = sqrt(max(_S415 * (2.0f - _S415), 0.0f));
    var _S417 : f32 = 6.28318548202514648f * u2_0;
    var _S418 : vec3<f32> = vec3<f32>(_S416 * cos(_S417), 1.0f - _S415, _S416 * sin(_S417));
    var _S419 : vec3<f32> = (normalize((_S410)));
    var _S420 : vec3<f32> = tangentToWorld(_S418, _S419);
    return _S420;
}

