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

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_0 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S99 : AnisotropicFrame;
    _S99.tangent = tangent_0;
    _S99.alphas = alphas_0;
    return _S99;
}

fn anisotropicFrame( material_0 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S100 : f32 = material_0.roughness;
    var _S101 : f32 = _S100 * _S100;
    var _S102 : bool = (material_0.anisotropy) == 0.0f;
    var _S103 : bool;
    if(_S102)
    {
        _S103 = true;
    }
    else
    {
        _S103 = !(_S101 > 0.0f);
    }
    if(_S103)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S104 : vec3<f32> = material_0.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_0.tangent));
    var _S105 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S106 : bool = (dot(_S104, _S104)) > 0.0f;
    var _S107 : vec3<f32> = select(_S105, _S104, _S106);
    var _S108 : vec3<f32> = (normalize((_S107)));
    var _S109 : f32 = 6.28318548202514648f * material_0.anisotropic_rotation;
    var _S110 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_0.anisotropy));
    var _S111 : f32 = 1.0f / _S110;
    var _S112 : bool = (material_0.anisotropy) < 0.0f;
    var _S113 : f32 = select(_S110, _S111, _S112);
    return AnisotropicFrame_x24init_0(_S108 * vec3<f32>(cos(_S109)) + cross(n_i_0, _S108) * vec3<f32>(sin(_S109)), vec2<f32>(_S101 / _S113, _S101 * _S113));
}

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_0 : f32) -> SheenProfile
{
    var _S114 : SheenProfile;
    _S114.on = on_0;
    _S114.albedo = albedo_0;
    return _S114;
}

fn sheenProfile( v_3 : vec3<f32>,  n_i_1 : vec3<f32>,  material_1 : Material) -> SheenProfile
{
    var _S115 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S116 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S117 : bool = _S116 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S117)
    {
        var _S118 : f32 = clamp(sqrt(max(dot(n_i_1, v_3), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S119 : u32 = min(u32(_S118), u32(22));
        var _S120 : f32 = sqrt(0.05000000074505806f);
        var _S121 : f32 = (clamp(sqrt(max(material_1.sheen_roughness, 0.0f)), _S120, 1.0f) - _S120) / (1.0f - _S120) * 23.0f;
        var _S122 : u32 = min(u32(_S121), u32(22));
        var _S123 : u32 = _S119 * u32(24) + _S122;
        var _S124 : f32 = _S118 - f32(_S119);
        var _S125 : f32 = _S121 - f32(_S122);
        var _S126 : u32 = _S123 + u32(24);
        var _S127 : f32 = SHEEN_ALBEDO_0[_S123] + (SHEEN_ALBEDO_0[_S126] - SHEEN_ALBEDO_0[_S123]) * _S124;
        var _S128 : u32 = _S123 + u32(1);
        var _S129 : f32 = SHEEN_ALBEDO_0[_S128] + (SHEEN_ALBEDO_0[_S126 + u32(1)] - SHEEN_ALBEDO_0[_S128]) * _S124;
        var _S130 : SheenProfile = SheenProfile_x24init_0(true, exp(_S127 + (_S129 - _S127) * _S125));
        profile_0 = _S130;
    }
    else
    {
        profile_0 = _S115;
    }
    return profile_0;
}

fn anisotropicLocal( w_0 : vec3<f32>,  t_2 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_0, t_2), dot(w_0, cross(n_3, t_2)), dot(w_0, n_3));
}

fn sampleHalfVector( v_4 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_3 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S131 : Random = pcg((*random_state_0));
    var _S132 : Random = pcg(_S131.state);
    (*random_state_0) = _S132.state;
    var _S133 : f32 = frame_0.alphas.x;
    var _S134 : bool = _S133 > 0.0f;
    if(_S134)
    {
        var _S135 : vec3<f32> = anisotropicLocal(v_4, frame_0.tangent, n_i_2);
        var _S136 : f32 = frame_0.alphas.y;
        var _S137 : vec3<f32> = (normalize((vec3<f32>(_S133 * _S135.x, _S136 * _S135.y, _S135.z))));
        var _S138 : vec3<f32> = sampleGGXVNDF(_S137, 1.0f, _S131.value, _S132.value);
        var _S139 : vec3<f32> = (normalize((vec3<f32>(_S133 * _S138.x, _S136 * _S138.y, _S138.z))));
        return vec3<f32>(_S139.x) * frame_0.tangent + vec3<f32>(_S139.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S139.z) * n_i_2;
    }
    var _S140 : vec3<f32> = worldToTangent(v_4, n_i_2);
    var _S141 : vec3<f32> = sampleGGXVNDF(_S140.xzy, alpha_3, _S131.value, _S132.value);
    var _S142 : vec3<f32> = _S141.xzy;
    var _S143 : vec3<f32> = tangentToWorld(_S142, n_i_2);
    return _S143;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_2 : Material,  random_state_1 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_5 : u32 = random_state_1;
    var _S144 : vec3<f32> = ((-(in_dir_0)));
    var _S145 : f32 = (sign((dot(n_4, _S144))));
    var _S146 : f32 = material_2.roughness;
    var _S147 : vec3<f32> = sampleHalfVector(_S144, n_4 * vec3<f32>(_S145), _S146 * _S146, frame_1, &(state_5));
    return _S147;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  eta_i_1 : f32,  eta_o_1 : f32) -> vec3<f32>
{
    var _S148 : vec3<f32> = ((-(in_dir_1)));
    var _S149 : vec3<f32> = ((-(vec3<f32>(eta_i_1) * _S148 + vec3<f32>(eta_o_1) * out_dir_0)));
    var _S150 : vec3<f32> = (normalize((_S149)));
    var _S151 : f32 = (sign((dot(n_5, _S148))));
    var _S152 : f32 = (sign((dot(_S149, n_5 * vec3<f32>(_S151)))));
    return _S150 * vec3<f32>(_S152);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S153 : vec3<f32> = ((-(in_dir_2)));
    var _S154 : vec3<f32> = (normalize((_S153 + out_dir_1)));
    return _S154;
}

fn anisotropicG1( w_1 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S155 : f32 = max(w_1.z, 0.0f);
    return 2.0f * _S155 / (_S155 + length(vec3<f32>(alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S155)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S156 : f32 = alphas_2.x;
    var _S157 : f32 = h_0.x / _S156;
    var _S158 : f32 = alphas_2.y;
    var _S159 : f32 = h_0.y / _S158;
    var _S160 : f32 = h_0.z;
    var _S161 : f32 = _S157 * _S157 + _S159 * _S159 + _S160 * _S160;
    return 1.0f / max(3.14159274101257324f * _S156 * _S158 * _S161 * _S161, 1.17549435082228751e-38f);
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

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_1 : f32,  refracted_0 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  p_sheen_velvet_0 : f32,  view_0 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_3 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S162 : BSDFLobes;
    _S162.v_dot_h = v_dot_h_0;
    _S162.n_dot_h = n_dot_h_1;
    _S162.refracted = refracted_0;
    _S162.F = F_0;
    _S162.F_greyscale = F_greyscale_0;
    _S162.reflect_weight = reflect_weight_0;
    _S162.diffuse_weight = diffuse_weight_0;
    _S162.refract_weight = refract_weight_0;
    _S162.p_diffuse = p_diffuse_0;
    _S162.p_reflect = p_reflect_0;
    _S162.p_refract = p_refract_0;
    _S162.translucent_share = translucent_share_0;
    _S162.sheen = sheen_0;
    _S162.p_sheen_velvet = p_sheen_velvet_0;
    _S162.view = view_0;
    _S162.tangent = tangent_1;
    _S162.alphas = alphas_3;
    _S162.visible = visible_0;
    return _S162;
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_5 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_3 : Material,  eta_i_2 : f32,  eta_o_2 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S163 : f32 = dot(ggx_n_0, v_5);
    var _S164 : f32 = dot(n_i_3, ggx_n_0);
    var _S165 : f32 = eta_i_2 / eta_o_2;
    var _S166 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S165))));
    var _S167 : f32 = min(sqrt(material_3.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S168 : f32 = _S167 * _S167;
    var _S169 : f32 = (1.0f + _S167) / (1.0f - _S167);
    var _S170 : f32 = abs(_S163);
    var _S171 : bool = eta_i_2 > eta_o_2;
    var _S172 : f32 = select(1.0f, _S169, _S171);
    var _S173 : f32 = select(_S169, 1.0f, _S171);
    var _S174 : f32 = fresnel(_S170, _S172, _S173);
    var _S175 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S163 * _S163)) >= (eta_o_2 * eta_o_2);
    var _S176 : vec3<f32> = material_3.specular_tint * vec3<f32>(_S168);
    var _S177 : vec3<f32> = vec3<f32>(1.0f);
    var _S178 : vec3<f32> = _S176 + (_S177 - _S176) * vec3<f32>((_S174 - _S168)) / vec3<f32>((1.0f - _S168));
    var _S179 : vec3<f32> = vec3<f32>(1.0f);
    var _S180 : vec3<f32> = select(_S178, _S179, _S175);
    var _S181 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_1 : vec3<f32>;
    var sheen_component_0 : f32;
    if(sheen_profile_0.on)
    {
        var _S182 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S183 : vec3<f32> = _S177 - material_3.sheen * vec3<f32>(_S182);
        var _S184 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S185 : f32 = _S184 * _S182;
        var _S186 : vec3<f32> = material_3.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S183;
        sheen_component_0 = _S185;
        sheen_1 = _S186;
        view_1 = v_5;
    }
    else
    {
        scale_0 = _S179;
        sheen_component_0 = 0.0f;
        sheen_1 = _S181;
        view_1 = _S181;
    }
    var _S187 : vec3<f32> = (mix((_S180), (material_3.albedo), (material_3.metallic)));
    var F_1 : vec3<f32> = _S187 * scale_0;
    var _S188 : f32 = rgb_to_greyscale(F_1);
    var _S189 : f32 = 1.0f - material_3.metallic;
    var _S190 : vec3<f32> = _S177 - _S180;
    var _S191 : vec3<f32> = vec3<f32>(((1.0f - material_3.transmission) * _S189)) * _S190 * scale_0;
    var _S192 : vec3<f32> = vec3<f32>((material_3.transmission * _S189)) * _S190 * scale_0;
    var _S193 : f32 = max(_S188, 0.0f);
    var _S194 : f32 = rgb_to_greyscale(_S191);
    var _S195 : f32 = max(_S194, 0.0f);
    var _S196 : f32 = rgb_to_greyscale(_S192);
    var _S197 : f32 = (sign((length(_S166))));
    var _S198 : f32 = max(_S196 * _S197, 0.0f);
    var _S199 : f32 = _S193 + _S195 + _S198;
    var _S200 : f32 = min(sheen_component_0, 1.0f);
    var _S201 : bool = sheen_component_0 > 0.0f;
    var _S202 : bool;
    if(_S201)
    {
        _S202 = !(_S199 > 0.0f);
    }
    else
    {
        _S202 = false;
    }
    var _S203 : f32 = select(_S200, 1.0f, _S202);
    var _S204 : f32 = (1.0f - _S203) / max(_S199, 0.0000152587890625f);
    var _S205 : f32 = _S195 * _S204;
    var _S206 : f32 = _S193 * _S204;
    var _S207 : f32 = _S198 * _S204;
    var _S208 : bool = (frame_2.alphas.x) > 0.0f;
    var visible_1 : f32;
    if(_S208)
    {
        var _S209 : vec3<f32> = anisotropicLocal(v_5, frame_2.tangent, n_i_3);
        var _S210 : f32 = anisotropicG1(_S209, frame_2.alphas);
        var _S211 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S212 : f32 = anisotropicD(_S211, frame_2.alphas);
        var _S213 : f32 = _S210 * _S212;
        visible_1 = _S213;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S163, _S164, _S166, F_1, _S188, 1.0f, _S191, _S192, _S205, _S206, _S207, 0.0f, sheen_1, _S203, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_4 : Material) -> f32
{
    var _S214 : f32 = rgb_to_greyscale(material_4.translucent);
    var _S215 : f32 = rgb_to_greyscale(material_4.albedo);
    var _S216 : f32 = _S214 / (_S215 + _S214);
    var _S217 : bool = _S214 > 0.0f;
    var _S218 : f32 = select(0.0f, _S216, _S217);
    return _S218;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S219 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S220 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S221 : f32 = 1.0f - lobes_0.translucent_share;
    var _S222 : bool = n_i_dot_l_0 < 0.0f;
    var _S223 : f32 = select(_S221, lobes_0.translucent_share, _S222);
    var _S224 : f32 = _S220 * _S223;
    var _S225 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S226 : f32 = select(_S219, _S224, _S225);
    var _S227 : bool = n_i_dot_v_0 > 0.0f;
    var _S228 : f32 = select(0.0f, _S226, _S227);
    return _S228;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_5 : f32,  material_5 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S229 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S230 : vec3<f32> = select(material_5.albedo, material_5.translucent, _S229);
    var _S231 : f32 = 1.0f - lobes_1.translucent_share;
    var _S232 : f32 = select(_S231, lobes_1.translucent_share, _S229);
    var _S233 : vec3<f32> = _S230 / vec3<f32>(_S232);
    var _S234 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S235 : vec3<f32> = select(material_5.albedo, _S233, _S234);
    return lobes_1.diffuse_weight * _S235 / vec3<f32>(lobes_1.p_diffuse);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S236 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S237 : f32 = _S236 * lobes_2.v_dot_h;
    var _S238 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S239 : f32 = _S237 * _S238 / n_i_dot_v_1;
    var _S240 : bool = alpha_6 > 0.0f;
    var _S241 : bool;
    if(_S240)
    {
        _S241 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S241 = false;
    }
    if(_S241)
    {
        _S241 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S241 = false;
    }
    if(_S241)
    {
        _S241 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S241 = false;
    }
    var _S242 : f32 = select(0.0f, _S239, _S241);
    var _S243 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S243)
    {
        var _S244 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S245 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S245)
        {
            _S241 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S241 = false;
        }
        if(_S241)
        {
            _S241 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S241 = false;
        }
        var _S246 : f32 = select(0.0f, _S244, _S241);
        pdf_h_0 = _S246;
    }
    else
    {
        pdf_h_0 = _S242;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S247 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S248 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S249 : f32 = lobes_3.p_refract * _S247 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S248 * _S248);
    var _S250 : bool = eta_i_4 != eta_o_4;
    var _S251 : bool;
    if(_S250)
    {
        _S251 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S251 = false;
    }
    var _S252 : f32 = select(0.0f, _S249, _S251);
    return _S252;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_6 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S253 : f32 = - dot(n_i_5, l_1);
    var _S254 : f32 = smithG1(alpha_8, max(_S253, 0.0f));
    var _S255 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S255)
    {
        var _S256 : vec3<f32> = ((-(n_i_5)));
        var _S257 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S256);
        var _S258 : f32 = anisotropicG1(_S257, lobes_4.alphas);
        G1_l_0 = _S258;
    }
    else
    {
        G1_l_0 = _S254;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_6.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S259 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S260 : bool = n_i_dot_l_2 > 0.0f;
    var _S261 : bool;
    if(_S260)
    {
        _S261 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S261 = false;
    }
    var _S262 : f32 = select(0.0f, _S259, _S261);
    return _S262;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_7 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S263 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S264 : f32 = dot(n_i_6, _S263);
    var _S265 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S266 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S267 : f32 = 1.0f / max(material_7.sheen_roughness, 0.05000000074505806f);
    var _S268 : f32 = (2.0f + _S267) * pow(max(1.0f - _S264 * _S264, 0.0f), 0.5f * _S267) * 0.5f * 0.31830987334251404f / max(4.0f * (_S265 + _S266 - _S265 * _S266), 0.0000152587890625f);
    return lobes_6.sheen * vec3<f32>((_S268 * _S265 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S269 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S270 : f32 = lobes_7.p_reflect * _S269 / (4.0f * lobes_7.v_dot_h);
    var _S271 : bool = _S269 > 0.0f;
    var _S272 : f32 = select(0.0f, _S270, _S271);
    return _S272;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_8 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S273 : f32 = dot(n_i_7, l_3);
    var _S274 : f32 = smithG1(alpha_12, max(_S273, 0.0f));
    var _S275 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S275)
    {
        var _S276 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S277 : f32 = anisotropicG1(_S276, lobes_8.alphas);
        G1_l_1 = _S277;
    }
    else
    {
        G1_l_1 = _S274;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_1 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_0 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S278 : vec3<f32> = ((-(in_dir_4)));
    var _S279 : f32 = dot(n_6, _S278);
    var _S280 : f32 = (sign((_S279)));
    var _S281 : vec3<f32> = n_6 * vec3<f32>(_S280);
    var _S282 : AnisotropicFrame = anisotropicFrame(material_9, _S281);
    var _S283 : f32 = dot(_S281, out_dir_2);
    var _S284 : f32 = material_9.roughness;
    var _S285 : f32 = _S284 * _S284;
    var _S286 : SheenProfile = sheenProfile(_S278, _S281, material_9);
    var _S287 : f32 = rgb_to_greyscale(material_9.translucent);
    var _S288 : bool = _S287 > 0.0f;
    var _S289 : bool = (dot(n_6, out_dir_2) * _S279) < 0.0f;
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
        var _S290 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S290;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S291 : vec3<f32> = vec3<f32>(0.0f);
    var _S292 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S291, _S291, 0.0f, 0.0f, _S291, _S291, 0.0f, 0.0f, 0.0f, 0.0f, _S291, 0.0f, _S291, _S291, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S292;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S291;
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
        var _S293 : u32;
        if(i_0 == u32(3))
        {
            _S293 = u32(4);
        }
        else
        {
            _S293 = i_0;
        }
        var _S294 : bool = _S293 == u32(0);
        var _S295 : bool;
        if(_S294)
        {
            _S295 = _S288;
        }
        else
        {
            _S295 = false;
        }
        var _S296 : bool;
        if(_S295)
        {
            _S296 = _S289;
        }
        else
        {
            _S296 = _S293 == u32(1);
        }
        var _S297 : bool = _S296 != refracted_1;
        if(_S297)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S298 : u32;
        if(_S293 == u32(4))
        {
            _S298 = u32(2);
        }
        else
        {
            _S298 = _S293;
        }
        var _S299 : bool = _S298 != half_of_0;
        var half_of_1 : u32;
        if(_S299)
        {
            var _S300 : bool = _S298 == u32(0);
            if(_S300)
            {
                var _S301 : vec3<f32> = sampledHalf(in_dir_4, n_6, material_9, random_state_2, _S282);
                ggx_n_1 = _S301;
            }
            else
            {
                var _S302 : bool = _S298 == u32(1);
                if(_S302)
                {
                    var _S303 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_6, eta_i_7, eta_o_7);
                    ggx_n_1 = _S303;
                }
                else
                {
                    var _S304 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S304;
                }
            }
            var _S305 : vec3<f32> = ((-(in_dir_4)));
            var _S306 : BSDFLobes = bsdfLobes(in_dir_4, _S305, _S281, ggx_n_1, material_9, eta_i_7, eta_o_7, _S282, _S286);
            lobe_terms_0 = _S306;
            var _S307 : f32 = translucentShare(material_9);
            lobe_terms_0.translucent_share = _S307;
            half_of_1 = _S298;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S293)
        {
        case u32(0):
            {
                var _S308 : f32 = diffusePDF(_S283, 0.0f, abs(_S279), _S285, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(0)] = _S308;
                var _S309 : vec3<f32> = diffuseBSDF(out_dir_2, _S281, _S285, material_9, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S309;
            }
        case u32(1):
            {
                var _S310 : f32 = refractPDF(_S283, dot(out_dir_2, ggx_n_1), abs(_S279), _S285, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(1)] = _S310;
                var _S311 : vec3<f32> = refractBSDF(out_dir_2, _S281, _S285, material_9, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S311;
            }
        case u32(4):
            {
                var _S312 : f32 = sheenVelvetPDF(_S283, 0.0f, abs(_S279), _S285, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(3)] = _S312;
                var _S313 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S281, _S285, material_9, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S313;
            }
        default :
            {
                var _S314 : f32 = reflectPDF(_S283, 0.0f, abs(_S279), _S285, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(2)] = _S314;
                var _S315 : vec3<f32> = reflectBSDF(out_dir_2, _S281, _S285, material_9, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S315;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S291;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S316 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S316)
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
    var _S317 : SampleBSDF;
    _S317.unit_direction = unit_direction_0;
    _S317.throughput = throughput_0;
    _S317.random_state = random_state_3;
    _S317.refracted = refracted_2;
    _S317.lobe = lobe_0;
    _S317.pdf = pdf_0;
    return _S317;
}

fn diffuseSample( u_0 : f32,  n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_10 : Material,  lobes_9 : BSDFLobes,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_4 : u32) -> SampleBSDF
{
    var _S318 : vec3<f32> = vec3<f32>(1.0f);
    var _S319 : SampleBSDF = SampleBSDF_x24init_0(_S318, _S318, u32(0), false, u32(0), 0.0f);
    var sample_0 : SampleBSDF = _S319;
    var _S320 : Random = pcg(random_state_4);
    var _S321 : Random = pcg(_S320.state);
    sample_0.random_state = _S321.state;
    var _S322 : vec3<f32> = sampleCosWeightedHemisphere(_S320.value, _S321.value);
    var _S323 : bool = u_0 < (lobes_9.p_diffuse * lobes_9.translucent_share);
    var _S324 : f32 = _S322.y;
    var _S325 : f32 = - _S324;
    var _S326 : f32 = select(_S324, _S325, _S323);
    var _S327 : vec3<f32> = tangentToWorld(vec3<f32>(_S322.x, _S326, _S322.z), n_i_8);
    sample_0.unit_direction = _S327;
    sample_0.refracted = _S323;
    sample_0.lobe = u32(0);
    var _S328 : vec3<f32> = diffuseBSDF(sample_0.unit_direction, n_i_8, alpha_13, material_10, lobes_9);
    sample_0.throughput = _S328;
    var _S329 : f32 = diffusePDF(_S326, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_8, eta_o_8);
    sample_0.pdf = _S329;
    return sample_0;
}

fn sheenVelvetSample( n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_11 : Material,  lobes_10 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_5 : u32) -> SampleBSDF
{
    var _S330 : vec3<f32> = vec3<f32>(1.0f);
    var _S331 : SampleBSDF = SampleBSDF_x24init_0(_S330, _S330, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S331;
    var _S332 : Random = pcg(random_state_5);
    var _S333 : Random = pcg(_S332.state);
    sample_1.random_state = _S333.state;
    var _S334 : f32 = _S332.value;
    var _S335 : f32 = sqrt(max(0.0f, 1.0f - _S334 * _S334));
    var _S336 : f32 = 6.28318548202514648f * _S333.value;
    var _S337 : vec3<f32> = tangentToWorld(vec3<f32>(_S335 * cos(_S336), _S332.value, _S335 * sin(_S336)), n_i_9);
    sample_1.unit_direction = _S337;
    sample_1.lobe = u32(4);
    var _S338 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_9, alpha_14, material_11, lobes_10);
    sample_1.throughput = _S338;
    var _S339 : f32 = sheenVelvetPDF(_S332.value, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_9, eta_o_9);
    sample_1.pdf = _S339;
    return sample_1;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_12 : Material,  lobes_11 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_6 : u32) -> SampleBSDF
{
    var _S340 : vec3<f32> = vec3<f32>(1.0f);
    var _S341 : SampleBSDF = SampleBSDF_x24init_0(_S340, _S340, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S341;
    sample_2.unit_direction = lobes_11.refracted;
    sample_2.random_state = random_state_6;
    sample_2.refracted = true;
    sample_2.lobe = u32(1);
    var _S342 : vec3<f32> = refractBSDF(sample_2.unit_direction, n_i_10, alpha_15, material_12, lobes_11);
    sample_2.throughput = _S342;
    var _S343 : f32 = refractPDF(0.0f, dot(sample_2.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_10, eta_o_10);
    sample_2.pdf = _S343;
    return sample_2;
}

fn reflectSample( in_dir_5 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_13 : Material,  lobes_12 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_7 : u32) -> SampleBSDF
{
    var _S344 : vec3<f32> = vec3<f32>(1.0f);
    var _S345 : SampleBSDF = SampleBSDF_x24init_0(_S344, _S344, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S345;
    var _S346 : vec3<f32> = (normalize((reflect(in_dir_5, ggx_n_4))));
    sample_3.unit_direction = _S346;
    sample_3.random_state = random_state_7;
    sample_3.lobe = u32(2);
    var _S347 : vec3<f32> = reflectBSDF(sample_3.unit_direction, n_i_11, alpha_16, material_13, lobes_12);
    sample_3.throughput = _S347;
    var _S348 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_11, eta_o_11);
    sample_3.pdf = _S348;
    return sample_3;
}

fn sampleBSDF( in_dir_6 : vec3<f32>,  n_7 : vec3<f32>,  material_14 : Material,  eta_i_12 : f32,  eta_o_12 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_8 : u32 = random_init_0;
    var _S349 : vec3<f32> = ((-(in_dir_6)));
    var _S350 : f32 = dot(n_7, _S349);
    var _S351 : f32 = (sign((_S350)));
    var n_i_12 : vec3<f32> = n_7 * vec3<f32>(_S351);
    var _S352 : f32 = abs(_S350);
    var _S353 : f32 = material_14.roughness;
    var _S354 : f32 = _S353 * _S353;
    var _S355 : AnisotropicFrame = anisotropicFrame(material_14, n_i_12);
    var _S356 : SheenProfile = sheenProfile(_S349, n_i_12, material_14);
    var _S357 : vec3<f32> = sampleHalfVector(_S349, n_i_12, _S354, _S355, &(random_state_8));
    var _S358 : BSDFLobes = bsdfLobes(in_dir_6, _S349, n_i_12, _S357, material_14, eta_i_12, eta_o_12, _S355, _S356);
    var lobes_13 : BSDFLobes = _S358;
    var _S359 : f32 = translucentShare(material_14);
    lobes_13.translucent_share = _S359;
    var _S360 : Random = pcg(random_state_8);
    random_state_8 = _S360.state;
    var _S361 : bool = (_S360.value) < (lobes_13.p_sheen_velvet);
    if(_S361)
    {
        var _S362 : SampleBSDF = sheenVelvetSample(n_i_12, _S352, _S354, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S362;
    }
    var _S363 : f32 = _S360.value - lobes_13.p_sheen_velvet;
    var _S364 : bool = _S363 < (lobes_13.p_diffuse);
    if(_S364)
    {
        var _S365 : SampleBSDF = diffuseSample(_S363, n_i_12, _S352, _S354, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S365;
    }
    var _S366 : bool = _S363 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S366)
    {
        var _S367 : SampleBSDF = refractSample(_S357, n_i_12, _S352, _S354, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S367;
    }
    var _S368 : SampleBSDF = reflectSample(in_dir_6, _S357, n_i_12, _S352, _S354, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
    return _S368;
}

fn pointLightRadiance( color_0 : vec3<f32>,  intensity_0 : f32,  radius_0 : f32) -> vec3<f32>
{
    return color_0 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_0 * radius_0));
}

fn beerLambert( distance_0 : f32,  absorption_0 : vec3<f32>) -> vec3<f32>
{
    var _S369 : vec3<f32> = max(absorption_0, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_0) * log(_S369));
}

fn vertexEta( material_15 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S370 : bool = n_dot_v_0 < 0.0f;
    var _S371 : f32 = select(1.0f, material_15.ior, _S370);
    var _S372 : f32 = select(material_15.ior, 1.0f, _S370);
    return vec2<f32>(_S371, _S372);
}

fn neeDecision( material_16 : Material,  n_dot_v_1 : f32,  eta_i_13 : f32,  eta_o_13 : f32) -> bool
{
    var _S373 : f32 = fresnel(abs(n_dot_v_1), eta_i_13, eta_o_13);
    var _S374 : vec3<f32> = (mix((vec3<f32>(_S373)), (material_16.albedo), (material_16.metallic)));
    var _S375 : f32 = rgb_to_greyscale(_S374);
    var _S376 : f32 = max((1.0f - _S375) * (1.0f - material_16.metallic) * (1.0f - material_16.transmission), 0.0f);
    var _S377 : bool = _S376 > 0.03999999910593033f;
    var _S378 : bool;
    if(_S377)
    {
        _S378 = true;
    }
    else
    {
        _S378 = (material_16.roughness) > 0.20000000298023224f;
    }
    return _S378;
}

fn straightThrough( material_17 : Material) -> vec3<f32>
{
    return vec3<f32>((material_17.transmission * (1.0f - material_17.metallic))) * material_17.albedo;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn occluderTransmittance( toward_0 : vec3<f32>,  n_8 : vec3<f32>,  material_18 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S379 : vec3<f32>;
    if((material_18.ior) == 1.0f)
    {
        var _S380 : vec3<f32> = straightThrough(material_18);
        _S379 = _S380;
    }
    else
    {
        _S379 = vec3<f32>(0.0f);
    }
    return _S379 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S381 : u32 = hash(index_0);
    var _S382 : u32 = hash((seed_0 ^ (_S381)));
    return _S382;
}

fn safeDivide( a_4 : vec3<f32>,  b_0 : vec3<f32>) -> vec3<f32>
{
    var _S383 : vec3<f32> = a_4 / b_0;
    var _S384 : vec3<f32> = vec3<f32>(0.0f);
    var _S385 : vec3<bool> = b_0 == _S384;
    var _S386 : vec3<f32> = select(_S383, _S384, _S385);
    return _S386;
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
    var _S387 : f32 = rgb_to_greyscale(weight_0);
    var _S388 : bool = _S387 > 0.0f;
    var _S389 : bool;
    if(_S388)
    {
        _S389 = _S387 < 3.00000000549775576e+38f;
    }
    else
    {
        _S389 = false;
    }
    var _S390 : bool = !_S389;
    if(_S390)
    {
        return;
    }
    var _S391 : f32 = (*sel_0).w_sum + _S387;
    (*sel_0).w_sum = _S391;
    var _S392 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S392;
    var _S393 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S393.state;
    var _S394 : bool = (_S393.value * (*sel_0).w_sum) <= _S387;
    if(_S394)
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
    var _S395 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S395;
    var _S396 : f32 = r_0.jac * shifted_0.jac;
    candidate_1.jac = _S396;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_0.w));
    return;
}

fn finalize( sel_2 : Selection,  c_0 : f32) -> Reservoir
{
    var r_1 : Reservoir = sel_2.r;
    var _S397 : f32 = rgb_to_greyscale(r_1.f);
    var _S398 : f32 = sel_2.w_sum / _S397;
    var _S399 : bool = _S397 > 0.0f;
    var _S400 : f32 = select(0.0f, _S398, _S399);
    r_1.w = _S400;
    r_1.c = c_0;
    return r_1;
}

fn withEnd( r_2 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_1 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_2;
    var _S401 : u32 = (insertBits((r_2.path), (end_0), (u32(0)), (u32(5))));
    var _S402 : u32 = (insertBits((_S401), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S402;
    candidate_2.f = f_1;
    return candidate_2;
}

fn facingSign( transmission_0 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S403 : bool = transmission_0 > 0.0f;
    var _S404 : bool;
    if(_S403)
    {
        _S404 = true;
    }
    else
    {
        _S404 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S405 : f32 = select(-1.0f, 1.0f, _S404);
    return _S405;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_0 : f32) -> f32
{
    var _S406 : vec3<f32> = throughput_1 / vec3<f32>(density_0);
    return clamp(max(_S406.x, max(_S406.y, _S406.z)), 0.0f, 1.0f);
}

fn cosSubClamped( sin_a_0 : f32,  cos_a_0 : f32,  sin_b_0 : f32,  cos_b_0 : f32) -> f32
{
    var _S407 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S408 : bool = cos_a_0 > cos_b_0;
    var _S409 : f32 = select(_S407, 1.0f, _S408);
    return _S409;
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
    var _S410 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S411 : vec3<f32> = node_0.high - node_0.low;
    var _S412 : vec3<f32> = p_0 - _S410;
    var _S413 : vec3<f32> = (normalize((_S412)));
    var _S414 : f32 = dot(_S412, _S412);
    var _S415 : f32 = dot(_S411, _S411) / 4.0f;
    var _S416 : f32 = abs(dot(node_0.w, _S413));
    var _S417 : f32 = sine(node_0.cos_theta_o);
    var _S418 : f32 = sqrt(max(1.0f - _S415 / _S414, 0.0f));
    var _S419 : bool = _S414 < _S415;
    var _S420 : f32 = select(_S418, -1.0f, _S419);
    var _S421 : f32 = sine(_S420);
    var _S422 : f32 = sine(_S416);
    var _S423 : f32 = cosSubClamped(_S422, _S416, _S417, node_0.cos_theta_o);
    var _S424 : f32 = sine(_S416);
    var _S425 : f32 = _S424 * node_0.cos_theta_o - _S416 * _S417;
    var _S426 : bool = _S416 > (node_0.cos_theta_o);
    var _S427 : f32 = select(_S425, 0.0f, _S426);
    var _S428 : f32 = cosSubClamped(_S427, _S423, _S421, _S420);
    var _S429 : bool = _S428 <= 0.0f;
    if(_S429)
    {
        return 0.0f;
    }
    var _S430 : f32 = - dot(_S413, normal_0);
    var _S431 : f32 = node_0.phi * _S428 / max(_S414, length(_S411) / 2.0f);
    var _S432 : f32 = sine(_S430);
    var _S433 : f32 = cosSubClamped(_S432, _S430, _S421, _S420);
    var _S434 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S435 : f32 = select(_S433, 1.0f, _S434);
    return max(_S431 * _S435, 0.0f);
}

fn solidAngle( probability_0 : f32,  normal_1 : vec3<f32>,  toward_1 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_1), 3.0f) / abs(dot(normal_1, toward_1));
}

fn pickChild( first_0 : LightBounds,  second_0 : LightBounds,  p_1 : vec3<f32>,  normal_2 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_1 : ptr<function, f32>) -> u32
{
    var _S436 : f32 = importance(first_0, p_1, normal_2);
    var _S437 : f32 = importance(second_0, p_1, normal_2);
    var _S438 : vec2<f32> = vec2<f32>(_S436, _S437);
    var _S439 : bool = _S436 == 0.0f;
    var _S440 : bool;
    if(_S439)
    {
        _S440 = _S437 == 0.0f;
    }
    else
    {
        _S440 = false;
    }
    if(_S440)
    {
        return u32(2);
    }
    var _S441 : f32 = _S436 + _S437;
    var _S442 : bool = _S437 > 0.0f;
    if(_S442)
    {
        _S440 = ((*pick_0) * _S441) >= _S436;
    }
    else
    {
        _S440 = false;
    }
    var _S443 : u32 = select(u32(0), u32(1), _S440);
    var _S444 : f32 = min(((*pick_0) * _S441 - f32(_S443) * _S436) / _S438[_S443], 0.99999994039535522f);
    (*pick_0) = _S444;
    var _S445 : f32 = (*probability_1) * (_S438[_S443] / _S441);
    (*probability_1) = _S445;
    return _S443;
}

fn childShare( first_1 : LightBounds,  second_1 : LightBounds,  p_2 : vec3<f32>,  normal_3 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S446 : f32 = importance(first_1, p_2, normal_3);
    var _S447 : f32 = importance(second_1, p_2, normal_3);
    var _S448 : vec2<f32> = vec2<f32>(_S446, _S447);
    var _S449 : f32 = _S448[child_0] / (_S446 + _S447);
    var _S450 : bool = (_S448[child_0]) > 0.0f;
    var _S451 : f32 = select(0.0f, _S449, _S450);
    return _S451;
}

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S452 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S453 : bool = b_1 > 0.0f;
    var _S454 : f32 = select(1.0f, _S452, _S453);
    return _S454;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_1 : f32,  p_3 : vec3<f32>) -> f32
{
    var _S455 : vec3<f32> = center_0 - p_3;
    var _S456 : f32 = radius_1 * radius_1 / dot(_S455, _S455);
    var _S457 : bool = _S456 >= 1.0f;
    if(_S457)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S456)) / (6.28318548202514648f * _S456);
}

fn sampleSphere( center_1 : vec3<f32>,  radius_2 : f32,  p_4 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S458 : vec3<f32> = center_1 - p_4;
    var _S459 : f32 = radius_2 * radius_2 / dot(_S458, _S458);
    var _S460 : f32 = u1_0 * _S459 / (1.0f + sqrt(max(1.0f - _S459, 0.0f)));
    var _S461 : f32 = 2.0f * u1_0;
    var _S462 : bool = _S459 >= 1.0f;
    var _S463 : f32 = select(_S460, _S461, _S462);
    var _S464 : f32 = sqrt(max(_S463 * (2.0f - _S463), 0.0f));
    var _S465 : f32 = 6.28318548202514648f * u2_0;
    var _S466 : vec3<f32> = vec3<f32>(_S464 * cos(_S465), 1.0f - _S463, _S464 * sin(_S465));
    var _S467 : vec3<f32> = (normalize((_S458)));
    var _S468 : vec3<f32> = tangentToWorld(_S466, _S467);
    return _S468;
}

