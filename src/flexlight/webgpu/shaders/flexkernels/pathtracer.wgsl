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

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_0 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S92 : AnisotropicFrame;
    _S92.tangent = tangent_0;
    _S92.alphas = alphas_0;
    return _S92;
}

fn anisotropicFrame( material_0 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S93 : f32 = material_0.roughness;
    var _S94 : f32 = _S93 * _S93;
    var _S95 : bool = (material_0.anisotropy) == 0.0f;
    var _S96 : bool;
    if(_S95)
    {
        _S96 = true;
    }
    else
    {
        _S96 = !(_S94 > 0.0f);
    }
    if(_S96)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S97 : vec3<f32> = material_0.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_0.tangent));
    var _S98 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S99 : bool = (dot(_S97, _S97)) > 0.0f;
    var _S100 : vec3<f32> = select(_S98, _S97, _S99);
    var _S101 : vec3<f32> = (normalize((_S100)));
    var _S102 : f32 = 6.28318548202514648f * material_0.anisotropic_rotation;
    var _S103 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_0.anisotropy));
    var _S104 : f32 = 1.0f / _S103;
    var _S105 : bool = (material_0.anisotropy) < 0.0f;
    var _S106 : f32 = select(_S103, _S104, _S105);
    return AnisotropicFrame_x24init_0(_S101 * vec3<f32>(cos(_S102)) + cross(n_i_0, _S101) * vec3<f32>(sin(_S102)), vec2<f32>(_S94 / _S106, _S94 * _S106));
}

fn anisotropicLocal( w_0 : vec3<f32>,  t_3 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_0, t_3), dot(w_0, cross(n_3, t_3)), dot(w_0, n_3));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_3 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S107 : Random = pcg((*random_state_0));
    var _S108 : Random = pcg(_S107.state);
    (*random_state_0) = _S108.state;
    var _S109 : f32 = frame_0.alphas.x;
    var _S110 : bool = _S109 > 0.0f;
    if(_S110)
    {
        var _S111 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_1);
        var _S112 : f32 = frame_0.alphas.y;
        var _S113 : vec3<f32> = (normalize((vec3<f32>(_S109 * _S111.x, _S112 * _S111.y, _S111.z))));
        var _S114 : vec3<f32> = sampleGGXVNDF(_S113, 1.0f, _S107.value, _S108.value);
        var _S115 : vec3<f32> = (normalize((vec3<f32>(_S109 * _S114.x, _S112 * _S114.y, _S114.z))));
        return vec3<f32>(_S115.x) * frame_0.tangent + vec3<f32>(_S115.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S115.z) * n_i_1;
    }
    var _S116 : vec3<f32> = worldToTangent(v_3, n_i_1);
    var _S117 : vec3<f32> = sampleGGXVNDF(_S116.xzy, alpha_3, _S107.value, _S108.value);
    var _S118 : vec3<f32> = _S117.xzy;
    var _S119 : vec3<f32> = tangentToWorld(_S118, n_i_1);
    return _S119;
}

fn sheenAlbedo( mu_0 : f32,  r_0 : f32) -> f32
{
    var _S120 : f32 = sqrt(0.05000000074505806f);
    var _S121 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S122 : f32 = (clamp(sqrt(max(r_0, 0.0f)), _S120, 1.0f) - _S120) / (1.0f - _S120) * 23.0f;
    var _S123 : u32 = min(u32(_S121), u32(22));
    var _S124 : u32 = min(u32(_S122), u32(22));
    var _S125 : f32 = _S121 - f32(_S123);
    var _S126 : f32 = _S122 - f32(_S124);
    var _S127 : u32 = _S123 * u32(24) + _S124;
    var _S128 : u32 = _S127 + u32(24);
    var _S129 : f32 = SHEEN_ALBEDO_0[_S127] + (SHEEN_ALBEDO_0[_S128] - SHEEN_ALBEDO_0[_S127]) * _S125;
    var _S130 : u32 = _S127 + u32(1);
    var _S131 : f32 = SHEEN_ALBEDO_0[_S130] + (SHEEN_ALBEDO_0[_S128 + u32(1)] - SHEEN_ALBEDO_0[_S130]) * _S125;
    return exp(_S129 + (_S131 - _S129) * _S126);
}

fn anisotropicG1( w_1 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S132 : f32 = max(w_1.z, 0.0f);
    return 2.0f * _S132 / (_S132 + length(vec3<f32>(alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S132)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S133 : f32 = alphas_2.x;
    var _S134 : f32 = h_0.x / _S133;
    var _S135 : f32 = alphas_2.y;
    var _S136 : f32 = h_0.y / _S135;
    var _S137 : f32 = h_0.z;
    var _S138 : f32 = _S134 * _S134 + _S136 * _S136 + _S137 * _S137;
    return 1.0f / max(3.14159274101257324f * _S133 * _S135 * _S138 * _S138, 1.17549435082228751e-38f);
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
     tangent : vec3<f32>,
     alphas : vec2<f32>,
     visible : f32,
};

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_0 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_3 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S139 : BSDFLobes;
    _S139.v_dot_h = v_dot_h_0;
    _S139.n_dot_h = n_dot_h_1;
    _S139.refracted = refracted_0;
    _S139.F = F_0;
    _S139.F_greyscale = F_greyscale_0;
    _S139.reflect_weight = reflect_weight_0;
    _S139.diffuse_weight = diffuse_weight_0;
    _S139.refract_weight = refract_weight_0;
    _S139.p_diffuse = p_diffuse_0;
    _S139.p_reflect = p_reflect_0;
    _S139.p_refract = p_refract_0;
    _S139.translucent_share = translucent_share_0;
    _S139.sheen = sheen_0;
    _S139.view = view_0;
    _S139.tangent = tangent_1;
    _S139.alphas = alphas_3;
    _S139.visible = visible_0;
    return _S139;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_4 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S140 : f32 = dot(ggx_n_0, v_4);
    var _S141 : f32 = dot(n_i_2, ggx_n_0);
    var _S142 : f32 = eta_i_1 / eta_o_1;
    var _S143 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S142))));
    var _S144 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S145 : f32 = _S144 * _S144;
    var _S146 : f32 = (1.0f + _S144) / (1.0f - _S144);
    var _S147 : f32 = abs(_S140);
    var _S148 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S148)
    {
        sheen_component_0 = _S146;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S148)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S146;
    }
    var _S149 : f32 = fresnel(_S147, sheen_component_0, visible_1);
    var _S150 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S140 * _S140)) >= (eta_o_1 * eta_o_1);
    var _S151 : vec3<f32>;
    if(_S150)
    {
        _S151 = vec3<f32>(1.0f);
    }
    else
    {
        var _S152 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S145);
        _S151 = _S152 + (vec3<f32>(1.0f) - _S152) * vec3<f32>((_S149 - _S145)) / vec3<f32>((1.0f - _S145));
    }
    var _S153 : vec3<f32> = vec3<f32>(1.0f);
    var _S154 : vec3<f32> = vec3<f32>(0.0f);
    var _S155 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S156 : bool = _S155 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_1 : vec3<f32>;
    if(_S156)
    {
        var _S157 : f32 = sheenAlbedo(dot(n_i_2, v_4), material_1.sheen_roughness);
        var _S158 : f32 = min(_S157, 1.0f);
        var _S159 : vec3<f32> = vec3<f32>(1.0f) - material_1.sheen * vec3<f32>(_S158);
        var _S160 : f32 = rgb_to_greyscale(material_1.sheen);
        var _S161 : f32 = _S160 * _S158;
        var _S162 : vec3<f32> = material_1.sheen / vec3<f32>(max(_S157, 1.0f));
        scale_0 = _S159;
        sheen_component_0 = _S161;
        sheen_1 = _S162;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S153;
        sheen_component_0 = 0.0f;
        sheen_1 = _S154;
        view_1 = _S154;
    }
    var _S163 : vec3<f32> = (mix((_S151), (material_1.albedo), (material_1.metallic)));
    var F_1 : vec3<f32> = _S163 * scale_0;
    var _S164 : f32 = rgb_to_greyscale(F_1);
    var _S165 : f32 = 1.0f - material_1.metallic;
    var _S166 : vec3<f32> = vec3<f32>(1.0f) - _S151;
    var _S167 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S165)) * _S166 * scale_0;
    var _S168 : vec3<f32> = vec3<f32>((material_1.transmission * _S165)) * _S166 * scale_0;
    var _S169 : f32 = max(_S164, 0.0f);
    var _S170 : f32 = rgb_to_greyscale(_S167);
    var _S171 : f32 = max(_S170, 0.0f);
    var _S172 : f32 = rgb_to_greyscale(_S168);
    var _S173 : f32 = (sign((length(_S143))));
    var _S174 : f32 = max(_S172 * _S173, 0.0f);
    var _S175 : f32 = _S169 + _S171 + _S174 + sheen_component_0;
    var _S176 : f32 = 1.0f / max(_S175, 0.0000152587890625f);
    var _S177 : f32 = (_S171 + sheen_component_0) * _S176;
    var _S178 : f32 = _S169 * _S176;
    var _S179 : f32 = _S174 * _S176;
    var _S180 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S180)
    {
        var _S181 : vec3<f32> = anisotropicLocal(v_4, frame_1.tangent, n_i_2);
        var _S182 : f32 = anisotropicG1(_S181, frame_1.alphas);
        var _S183 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S184 : f32 = anisotropicD(_S183, frame_1.alphas);
        var _S185 : f32 = _S182 * _S184;
        visible_1 = _S185;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S140, _S141, _S143, F_1, _S164, 1.0f, _S167, _S168, _S177, _S178, _S179, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S186 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S187 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S188 : f32 = _S186 / (_S187 + _S186);
    var _S189 : bool = _S186 > 0.0f;
    var _S190 : f32 = select(0.0f, _S188, _S189);
    return _S190;
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S191 : bool = lobe_0 == u32(0);
    if(_S191)
    {
        var _S192 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S193 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S194 : f32 = 1.0f - lobes_0.translucent_share;
        var _S195 : bool = n_i_dot_l_0 < 0.0f;
        var _S196 : f32 = select(_S194, lobes_0.translucent_share, _S195);
        var _S197 : f32 = _S193 * _S196;
        var _S198 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S199 : f32 = select(_S192, _S197, _S198);
        var _S200 : bool = n_i_dot_v_0 > 0.0f;
        var _S201 : f32 = select(0.0f, _S199, _S200);
        return _S201;
    }
    var _S202 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S203 : f32 = _S202 * lobes_0.v_dot_h;
    var _S204 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S205 : f32 = _S203 * _S204 / n_i_dot_v_0;
    var _S206 : bool = alpha_4 > 0.0f;
    var _S207 : bool;
    if(_S206)
    {
        _S207 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S207 = false;
    }
    if(_S207)
    {
        _S207 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S207 = false;
    }
    if(_S207)
    {
        _S207 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S207 = false;
    }
    var _S208 : f32 = select(0.0f, _S205, _S207);
    var _S209 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S209)
    {
        var _S210 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S211 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S211)
        {
            _S207 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S207 = false;
        }
        if(_S207)
        {
            _S207 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S207 = false;
        }
        var _S212 : f32 = select(0.0f, _S210, _S207);
        pdf_h_0 = _S212;
    }
    else
    {
        pdf_h_0 = _S208;
    }
    var _S213 : bool = lobe_0 == u32(1);
    if(_S213)
    {
        var _S214 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S215 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S214 * _S214);
        var _S216 : bool = eta_i_2 != eta_o_2;
        if(_S216)
        {
            _S207 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S207 = false;
        }
        var _S217 : f32 = select(0.0f, _S215, _S207);
        return _S217;
    }
    var _S218 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S219 : bool = pdf_h_0 > 0.0f;
    var _S220 : f32 = select(0.0f, _S218, _S219);
    return _S220;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_5 : vec3<f32>,  n_4 : vec3<f32>,  r_1 : f32) -> f32
{
    var _S221 : f32 = 1.0f / max(r_1, 0.05000000074505806f);
    var _S222 : vec3<f32> = (normalize((l_0 + v_5)));
    var _S223 : f32 = dot(n_4, _S222);
    var _S224 : f32 = max(dot(n_4, l_0), 0.0f);
    var _S225 : f32 = max(dot(n_4, v_5), 0.0f);
    return (2.0f + _S221) * pow(max(1.0f - _S223 * _S223, 0.0f), 0.5f * _S221) * 0.5f * 0.31830987334251404f / max(4.0f * (_S224 + _S225 - _S224 * _S225), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes,  lobe_1 : u32) -> vec3<f32>
{
    var _S226 : bool = lobe_1 == u32(0);
    if(_S226)
    {
        var _S227 : bool = (dot(n_i_3, l_1)) < 0.0f;
        var _S228 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S227);
        var _S229 : f32 = 1.0f - lobes_1.translucent_share;
        var _S230 : f32 = select(_S229, lobes_1.translucent_share, _S227);
        var _S231 : vec3<f32> = _S228 / vec3<f32>(_S230);
        var _S232 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S233 : vec3<f32> = select(material_3.albedo, _S231, _S232);
        var _S234 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S235 : bool = _S234 > 0.0f;
        var _S236 : bool;
        if(_S235)
        {
            _S236 = !_S227;
        }
        else
        {
            _S236 = false;
        }
        if(_S236)
        {
            var _S237 : vec3<f32> = lobes_1.diffuse_weight * _S233;
            var _S238 : vec3<f32> = lobes_1.sheen * vec3<f32>(3.14159274101257324f);
            var _S239 : f32 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            var _S240 : vec3<f32> = _S238 * vec3<f32>(_S239);
            var _S241 : f32 = select(1.0f, _S229, _S232);
            return (_S237 + _S240 / vec3<f32>(_S241)) / vec3<f32>(lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S233 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S242 : bool = lobe_1 == u32(1);
    var G1_l_0 : f32;
    if(_S242)
    {
        var _S243 : f32 = - dot(n_i_3, l_1);
        var _S244 : f32 = smithG1(alpha_5, max(_S243, 0.0f));
        var _S245 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S245)
        {
            var _S246 : vec3<f32> = ((-(n_i_3)));
            var _S247 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, _S246);
            var _S248 : f32 = anisotropicG1(_S247, lobes_1.alphas);
            G1_l_0 = _S248;
        }
        else
        {
            G1_l_0 = _S244;
        }
        return lobes_1.refract_weight * vec3<f32>(G1_l_0) * material_3.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S249 : f32 = dot(n_i_3, l_1);
    var _S250 : f32 = smithG1(alpha_5, max(_S249, 0.0f));
    var _S251 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S251)
    {
        var _S252 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        var _S253 : f32 = anisotropicG1(_S252, lobes_1.alphas);
        G1_l_0 = _S253;
    }
    else
    {
        G1_l_0 = _S250;
    }
    return vec3<f32>((lobes_1.reflect_weight * G1_l_0)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
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
    var _S254 : SampleBSDF;
    _S254.unit_direction = unit_direction_0;
    _S254.throughput = throughput_0;
    _S254.random_state = random_state_1;
    _S254.refracted = refracted_1;
    _S254.lobe = lobe_2;
    _S254.pdf = pdf_0;
    return _S254;
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S255 : vec3<f32> = ((-(in_dir_1)));
    var _S256 : f32 = dot(n_5, _S255);
    var _S257 : f32 = (sign((_S256)));
    var _S258 : vec3<f32> = n_5 * vec3<f32>(_S257);
    var _S259 : f32 = material_4.roughness;
    var _S260 : f32 = _S259 * _S259;
    var _S261 : AnisotropicFrame = anisotropicFrame(material_4, _S258);
    var _S262 : vec3<f32> = (normalize((_S255 + out_dir_0)));
    var _S263 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S263)
    {
        var _S264 : vec3<f32> = sampleHalfVector(_S255, _S258, _S260, _S261, &(random_state_2));
        ggx_n_1 = _S264;
    }
    else
    {
        var _S265 : bool = lobe_3 == u32(1);
        if(_S265)
        {
            var _S266 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S255 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S267 : vec3<f32> = (normalize((_S266)));
            var _S268 : f32 = (sign((dot(_S266, _S258))));
            var _S269 : vec3<f32> = _S267 * vec3<f32>(_S268);
            ggx_n_1 = _S269;
        }
        else
        {
            ggx_n_1 = _S262;
        }
    }
    var _S270 : BSDFLobes = bsdfLobes(in_dir_1, _S255, _S258, ggx_n_1, material_4, eta_i_3, eta_o_3, _S261);
    var lobes_2 : BSDFLobes = _S270;
    var _S271 : f32 = translucentShare(material_4);
    lobes_2.translucent_share = _S271;
    var _S272 : f32 = lobeDensity(dot(_S258, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S256), _S260, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S273 : bool = !(_S272 > 0.0f);
    if(_S273)
    {
        var _S274 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S274, _S274, u32(0), false, u32(0), 0.0f);
    }
    var _S275 : vec3<f32> = lobeThroughput(out_dir_0, _S258, _S260, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S275, random_state_2, lobe_3 == u32(1), lobe_3, _S272);
}

fn BSDF( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_6 : vec3<f32>,  g_n_0 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S276 : vec3<f32> = ((-(in_dir_2)));
    var _S277 : bool = (dot(g_n_0, _S276) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S277)
    {
        var _S278 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_6, material_5, eta_i_4, eta_o_4, u32(0), random_state_3);
        var _S279 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_6, material_5, eta_i_4, eta_o_4, u32(2), random_state_3);
        return _S278.throughput * vec3<f32>(_S278.pdf) + _S279.throughput * vec3<f32>(_S279.pdf);
    }
    var _S280 : SampleBSDF = connectBSDF(in_dir_2, out_dir_1, n_6, material_5, eta_i_4, eta_o_4, u32(1), random_state_3);
    return _S280.throughput * vec3<f32>(_S280.pdf);
}

fn translucentCorrection( in_dir_3 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_7 : vec3<f32>,  g_n_1 : vec3<f32>,  material_6 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S281 : f32 = dot(n_7, out_dir_2);
    var _S282 : vec3<f32> = ((-(in_dir_3)));
    var _S283 : bool = (_S281 * dot(n_7, _S282)) < 0.0f;
    var _S284 : SampleBSDF = connectBSDF(in_dir_3, out_dir_2, n_7, material_6, eta_i_5, eta_o_5, u32(0), random_state_4);
    var _S285 : vec3<f32> = ((-(in_dir_3)));
    var _S286 : bool = (dot(g_n_1, _S285) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S287 : vec3<f32> = vec3<f32>(0.0f);
    var _S288 : vec3<f32> = _S284.throughput * vec3<f32>(_S284.pdf);
    var _S289 : f32 = select(1.0f, -1.0f, _S286);
    var _S290 : vec3<f32> = _S288 * vec3<f32>(_S289);
    var _S291 : vec3<f32> = select(_S287, _S290, _S283);
    return _S291;
}

fn translucentBSDF( in_dir_4 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_8 : vec3<f32>,  g_n_2 : vec3<f32>,  material_7 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_5 : u32) -> vec3<f32>
{
    var _S292 : vec3<f32> = BSDF(in_dir_4, out_dir_3, n_8, g_n_2, material_7, eta_i_6, eta_o_6, random_state_5);
    var _S293 : vec3<f32> = translucentCorrection(in_dir_4, out_dir_3, n_8, g_n_2, material_7, eta_i_6, eta_o_6, random_state_5);
    return _S292 + _S293;
}

fn sampleBSDF( in_dir_5 : vec3<f32>,  n_9 : vec3<f32>,  material_8 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_6 : u32 = random_init_1;
    var _S294 : vec3<f32> = ((-(in_dir_5)));
    var _S295 : f32 = dot(n_9, _S294);
    var _S296 : f32 = (sign((_S295)));
    var n_i_4 : vec3<f32> = n_9 * vec3<f32>(_S296);
    var _S297 : f32 = abs(_S295);
    var _S298 : f32 = material_8.roughness;
    var _S299 : f32 = _S298 * _S298;
    var _S300 : AnisotropicFrame = anisotropicFrame(material_8, n_i_4);
    var _S301 : vec3<f32> = sampleHalfVector(_S294, n_i_4, _S299, _S300, &(random_state_6));
    var _S302 : BSDFLobes = bsdfLobes(in_dir_5, _S294, n_i_4, _S301, material_8, eta_i_7, eta_o_7, _S300);
    var lobes_3 : BSDFLobes = _S302;
    var _S303 : f32 = translucentShare(material_8);
    lobes_3.translucent_share = _S303;
    var _S304 : vec3<f32> = vec3<f32>(1.0f);
    var _S305 : SampleBSDF = SampleBSDF_x24init_0(_S304, _S304, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S305;
    var _S306 : Random = pcg(random_state_6);
    random_state_6 = _S306.state;
    var _S307 : bool = (_S306.value) < (lobes_3.p_diffuse);
    if(_S307)
    {
        var _S308 : Random = pcg(random_state_6);
        var _S309 : Random = pcg(_S308.state);
        sample_0.random_state = _S309.state;
        var _S310 : vec3<f32> = sampleCosWeightedHemisphere(_S308.value, _S309.value);
        var _S311 : bool = (_S306.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S312 : f32 = _S310.y;
        var _S313 : f32 = - _S312;
        var _S314 : f32 = select(_S312, _S313, _S311);
        var _S315 : vec3<f32> = tangentToWorld(vec3<f32>(_S310.x, _S314, _S310.z), n_i_4);
        sample_0.unit_direction = _S315;
        var _S316 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_4, _S299, material_8, lobes_3, u32(0));
        sample_0.throughput = _S316;
        var _S317 : f32 = lobeDensity(_S314, 0.0f, _S297, _S299, lobes_3, eta_i_7, eta_o_7, u32(0));
        sample_0.pdf = _S317;
        sample_0.refracted = _S311;
        return sample_0;
    }
    var _S318 : bool = (_S306.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S318)
    {
        sample_0.unit_direction = lobes_3.refracted;
        var _S319 : f32 = lobeDensity(0.0f, dot(sample_0.unit_direction, _S301), _S297, _S299, lobes_3, eta_i_7, eta_o_7, u32(1));
        sample_0.pdf = _S319;
        var _S320 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_4, _S299, material_8, lobes_3, u32(1));
        sample_0.throughput = _S320;
        sample_0.random_state = random_state_6;
        sample_0.refracted = true;
        sample_0.lobe = u32(1);
        return sample_0;
    }
    var _S321 : vec3<f32> = (normalize((reflect(in_dir_5, _S301))));
    sample_0.unit_direction = _S321;
    var _S322 : vec3<f32> = lobeThroughput(sample_0.unit_direction, n_i_4, _S299, material_8, lobes_3, u32(2));
    sample_0.throughput = _S322;
    sample_0.random_state = random_state_6;
    sample_0.lobe = u32(2);
    var _S323 : f32 = lobeDensity(0.0f, 0.0f, _S297, _S299, lobes_3, eta_i_7, eta_o_7, u32(2));
    sample_0.pdf = _S323;
    return sample_0;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S324 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S324));
}

fn samplesLights( material_9 : Material) -> bool
{
    var _S325 : bool = (material_9.roughness) > 0.0f;
    var _S326 : bool;
    if(_S325)
    {
        _S326 = true;
    }
    else
    {
        var _S327 : bool = (material_9.metallic) < 1.0f;
        if(_S327)
        {
            _S326 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S326 = false;
        }
    }
    return _S326;
}

fn neeBSDF( in_dir_6 : vec3<f32>,  dir_0 : vec3<f32>,  n_10 : vec3<f32>,  material_10 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_7 : u32) -> vec3<f32>
{
    var _S328 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_0 : vec3<f32> = _S328;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S329 : bool = lobe_4 == u32(0);
        var _S330 : bool;
        if(_S329)
        {
            var _S331 : f32 = rgb_to_greyscale(material_10.translucent);
            _S330 = _S331 > 0.0f;
        }
        else
        {
            _S330 = false;
        }
        var _S332 : bool;
        if(_S330)
        {
            var _S333 : f32 = dot(n_10, dir_0);
            var _S334 : vec3<f32> = ((-(in_dir_6)));
            _S332 = ((_S333 * dot(n_10, _S334)) < 0.0f) == refracted_2;
        }
        else
        {
            _S332 = (lobe_4 == u32(1)) == refracted_2;
        }
        var f_1 : vec3<f32>;
        if(_S332)
        {
            var _S335 : SampleBSDF = connectBSDF(in_dir_6, dir_0, n_10, material_10, eta_i_8, eta_o_8, lobe_4, random_state_7);
            var _S336 : bool = (_S335.pdf) > 0.0f;
            if(_S336)
            {
                if(power_0)
                {
                    var _S337 : f32 = _S335.pdf / pdf_1;
                    var f_2 : vec3<f32> = f_0 + _S335.throughput * vec3<f32>(_S335.pdf) / vec3<f32>((pdf_1 * (1.0f + _S337 * _S337)));
                    f_1 = f_2;
                }
                else
                {
                    var f_3 : vec3<f32> = f_0 + _S335.throughput * vec3<f32>(_S335.pdf) / vec3<f32>((_S335.pdf + pdf_1));
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

fn straightThrough( dir_1 : vec3<f32>,  n_11 : vec3<f32>,  material_11 : Material) -> vec3<f32>
{
    var _S338 : vec3<f32> = ((-(dir_1)));
    var _S339 : f32 = (sign((dot(n_11, _S338))));
    var _S340 : vec3<f32> = n_11 * vec3<f32>(_S339);
    var _S341 : AnisotropicFrame = anisotropicFrame(material_11, _S340);
    var _S342 : bool = (_S341.alphas.x) > 0.0f;
    if(_S342)
    {
        var _S343 : f32 = material_11.transmission * (1.0f - material_11.metallic);
        var _S344 : vec3<f32> = ((-(_S340)));
        var _S345 : vec3<f32> = anisotropicLocal(dir_1, _S341.tangent, _S344);
        var _S346 : f32 = anisotropicG1(_S345, _S341.alphas);
        return vec3<f32>((_S343 * _S346)) * material_11.albedo;
    }
    var _S347 : f32 = material_11.transmission * (1.0f - material_11.metallic);
    var _S348 : f32 = material_11.roughness;
    var _S349 : f32 = smithG1(_S348 * _S348, abs(dot(n_11, dir_1)));
    return vec3<f32>((_S347 * _S349)) * material_11.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_0 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S350 : f32 = (sign((dot(light_n_0, start_0 - end_0))));
    return light_n_0 * vec3<f32>((_S350 * light_offset_0));
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_12 : vec3<f32>,  material_12 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S351 : vec3<f32>;
    if((material_12.ior) == 1.0f)
    {
        var _S352 : vec3<f32> = straightThrough(toward_0, n_12, material_12);
        _S351 = _S352;
    }
    else
    {
        _S351 = vec3<f32>(0.0f);
    }
    return _S351 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S353 : u32 = hash(index_0);
    var _S354 : u32 = hash((seed_0 ^ (_S353)));
    return _S354;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S355 : vec3<f32> = a_4 / b_0;
    var _S356 : vec3<f32> = vec3<f32>(0.0f);
    var _S357 : vec3<bool> = b_0 == _S356;
    var _S358 : vec3<f32> = select(_S355, _S356, _S357);
    return _S358;
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
    var _S359 : f32 = rgb_to_greyscale(weight_0);
    var _S360 : bool = _S359 > 0.0f;
    var _S361 : bool;
    if(_S360)
    {
        _S361 = _S359 < 3.00000000549775576e+38f;
    }
    else
    {
        _S361 = false;
    }
    var _S362 : bool = !_S361;
    if(_S362)
    {
        return;
    }
    var _S363 : f32 = (*sel_0).w_sum + _S359;
    (*sel_0).w_sum = _S363;
    var _S364 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S364;
    var _S365 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S365.state;
    var _S366 : bool = (_S365.value * (*sel_0).w_sum) <= _S359;
    if(_S366)
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
    var _S367 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S367;
    var _S368 : f32 = r_2.jac * shifted_0.jac;
    candidate_1.jac = _S368;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_2.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_3 : Reservoir = sel_2.r;
    var _S369 : f32 = rgb_to_greyscale(r_3.f);
    var _S370 : f32 = sel_2.w_sum / _S369;
    var _S371 : bool = _S369 > 0.0f;
    var _S372 : f32 = select(0.0f, _S370, _S371);
    r_3.w = _S372;
    r_3.c = c_0;
    return r_3;
}

fn withEnd( r_4 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_4 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_4;
    var _S373 : u32 = (insertBits((r_4.path), (end_1), (u32(0)), (u32(5))));
    var _S374 : u32 = (insertBits((_S373), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S374;
    candidate_2.f = f_4;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S375 : bool = transmission_0 > 0.0f;
    var _S376 : bool;
    if(_S375)
    {
        _S376 = true;
    }
    else
    {
        _S376 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S377 : f32;
    if(_S376)
    {
        _S377 = 1.0f;
    }
    else
    {
        _S377 = -1.0f;
    }
    return _S377;
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
    var _S378 : bool;
    if(open_0)
    {
        _S378 = prev_rough_0;
    }
    else
    {
        _S378 = false;
    }
    if(_S378)
    {
        _S378 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S378 = false;
    }
    return _S378;
}

fn withinInverseFootprint( pdf_2 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_2 : f32,  threshold_1 : f32) -> bool
{
    var _S379 : bool = pdf_2 > 0.0f;
    var _S380 : bool;
    if(_S379)
    {
        if(diffuse_0)
        {
            _S380 = true;
        }
        else
        {
            _S380 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S380 = false;
    }
    return _S380;
}

fn roughLobe( pdf_3 : f32,  diffuse_1 : bool,  roughness_0 : f32) -> bool
{
    var _S381 : bool = pdf_3 > 0.0f;
    var _S382 : bool;
    if(_S381)
    {
        if(diffuse_1)
        {
            _S382 = true;
        }
        else
        {
            _S382 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S382 = false;
    }
    return _S382;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S383 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S383.x, max(_S383.y, _S383.z)), 0.0f, 1.0f);
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S384 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S384;
}

fn temporalWeights( c_1 : f32,  p_c_0 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S385 : f32 = c_1 * p_c_0;
    var _S386 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S385 / (_S385 + c_t_0 * g_previous_0), _S386 / (_S386 + c_1 * g_current_0));
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
    var _S387 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S388 : bool = cos_a_0 > cos_b_0;
    var _S389 : f32 = select(_S387, 1.0f, _S388);
    return _S389;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S390 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S391 : bool = cos_a_1 > cos_b_1;
    var _S392 : f32 = select(_S390, 0.0f, _S391);
    return _S392;
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
    var _S393 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S394 : vec3<f32> = node_0.high - node_0.low;
    var _S395 : vec3<f32> = p_0 - _S393;
    var _S396 : vec3<f32> = (normalize((_S395)));
    var _S397 : f32 = dot(_S395, _S395);
    var _S398 : f32 = dot(_S394, _S394) / 4.0f;
    var _S399 : f32 = abs(dot(node_0.w, _S396));
    var _S400 : f32 = sine(node_0.cos_theta_o);
    var _S401 : f32 = sqrt(max(1.0f - _S398 / _S397, 0.0f));
    var _S402 : bool = _S397 < _S398;
    var _S403 : f32 = select(_S401, -1.0f, _S402);
    var _S404 : f32 = sine(_S403);
    var _S405 : f32 = sine(_S399);
    var _S406 : f32 = cosSubClamped(_S405, _S399, _S400, node_0.cos_theta_o);
    var _S407 : f32 = sine(_S399);
    var _S408 : f32 = sinSubClamped(_S407, _S399, _S400, node_0.cos_theta_o);
    var _S409 : f32 = cosSubClamped(_S408, _S406, _S404, _S403);
    var _S410 : bool = _S409 <= 0.0f;
    if(_S410)
    {
        return 0.0f;
    }
    var _S411 : f32 = - dot(_S396, normal_0);
    var _S412 : f32 = node_0.phi * _S409 / max(_S397, length(_S394) / 2.0f);
    var _S413 : f32 = sine(_S411);
    var _S414 : f32 = cosSubClamped(_S413, _S411, _S404, _S403);
    var _S415 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S416 : f32 = select(_S414, 1.0f, _S415);
    return max(_S412 * _S416, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S417 : f32 = importance(first_0, p_1, normal_2);
    var _S418 : f32 = importance(second_0, p_1, normal_2);
    var _S419 : vec2<f32> = vec2<f32>(_S417, _S418);
    var _S420 : bool = _S417 == 0.0f;
    var _S421 : bool;
    if(_S420)
    {
        _S421 = _S418 == 0.0f;
    }
    else
    {
        _S421 = false;
    }
    if(_S421)
    {
        return u32(2);
    }
    var _S422 : f32 = _S417 + _S418;
    var _S423 : bool = _S418 > 0.0f;
    if(_S423)
    {
        _S421 = ((*pick_0) * _S422) >= _S417;
    }
    else
    {
        _S421 = false;
    }
    var _S424 : u32 = select(u32(0), u32(1), _S421);
    var _S425 : f32 = min(((*pick_0) * _S422 - f32(_S424) * _S417) / _S419[_S424], 0.99999994039535522f);
    (*pick_0) = _S425;
    var _S426 : f32 = (*probability_1) * (_S419[_S424] / _S422);
    (*probability_1) = _S426;
    return _S424;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S427 : f32 = importance(first_1, p_2, normal_3);
    var _S428 : f32 = importance(second_1, p_2, normal_3);
    var _S429 : vec2<f32> = vec2<f32>(_S427, _S428);
    var _S430 : f32 = _S429[child_0] / (_S427 + _S428);
    var _S431 : bool = (_S429[child_0]) > 0.0f;
    var _S432 : f32 = select(0.0f, _S430, _S431);
    return _S432;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S433 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S434 : bool = b_1 > 0.0f;
    var _S435 : f32 = select(1.0f, _S433, _S434);
    return _S435;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S436 : vec3<f32> = center_0 - p_3;
    var _S437 : f32 = radius_1 * radius_1 / dot(_S436, _S436);
    var _S438 : bool = _S437 >= 1.0f;
    if(_S438)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S437)) / (6.28318548202514648f * _S437);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S439 : vec3<f32> = center_1 - p_4;
    var _S440 : f32 = radius_2 * radius_2 / dot(_S439, _S439);
    var _S441 : f32 = u1_0 * _S440 / (1.0f + sqrt(max(1.0f - _S440, 0.0f)));
    var _S442 : f32 = 2.0f * u1_0;
    var _S443 : bool = _S440 >= 1.0f;
    var _S444 : f32 = select(_S441, _S442, _S443);
    var _S445 : f32 = sqrt(max(_S444 * (2.0f - _S444), 0.0f));
    var _S446 : f32 = 6.28318548202514648f * u2_0;
    var _S447 : vec3<f32> = vec3<f32>(_S445 * cos(_S446), 1.0f - _S444, _S445 * sin(_S446));
    var _S448 : vec3<f32> = (normalize((_S439)));
    var _S449 : vec3<f32> = tangentToWorld(_S447, _S448);
    return _S449;
}

