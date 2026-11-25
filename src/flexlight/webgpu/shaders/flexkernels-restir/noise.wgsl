struct EntryPointParams_std140_0
{
    @align(16) size_0 : u32,
};

@binding(0) @group(0) var<uniform> entryPointParams_0 : EntryPointParams_std140_0;
@binding(1) @group(0) var<storage, read_write> entryPointParams_tensor_0 : array<u32>;

struct EntryPointParams_std140_1
{
    @align(16) size_1 : u32,
    @align(4) sweep_0 : u32,
    @align(8) colour_0 : u32,
};

@binding(2) @group(0) var<uniform> entryPointParams_1 : EntryPointParams_std140_1;
@binding(3) @group(0) var<storage, read_write> entryPointParams_tensor_1 : array<u32>;

fn hash( x_0 : u32) -> u32
{
    var _S1 : u32 = x_0 * u32(747796405) + u32(2891336453);
    var _S2 : u32 = ((((_S1 >> ((((_S1 >> (u32(28)))) + u32(4))))) ^ (_S1))) * u32(277803737);
    return (((_S2 >> (u32(22)))) ^ (_S2));
}

fn noiseWhite( x_1 : u32,  y_0 : u32,  t_0 : u32,  size_2 : u32) -> u32
{
    var ranks_0 : array<u32, i32(4)>;
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
        var _S3 : u32 = size_2 - u32(1);
        var _S4 : u32 = ((x_1 + size_2 / u32(2)) & (_S3));
        var _S5 : bool = i_0 < u32(2);
        var _S6 : u32 = select(_S4, x_1, _S5);
        var l_0 : u32 = _S6;
        var r_0 : u32 = y_0;
        var k_0 : u32 = u32(0);
        loop
        {
            if(k_0 < u32(4))
            {
            }
            else
            {
                break;
            }
            var _S7 : u32 = hash((((((r_0 ^ (((t_0 << (u32(16))))))) ^ (((k_0 << (u32(28))))))) ^ (((((i_0 & (u32(1)))) << (u32(31)))))));
            var _S8 : u32 = (l_0 ^ (((_S7 & (_S3)))));
            var k_1 : u32 = k_0 + u32(1);
            l_0 = r_0;
            r_0 = _S8;
            k_0 = k_1;
        }
        var _S9 : u32 = l_0 + r_0 * size_2;
        var _S10 : u32 = size_2 * size_2;
        var _S11 : u32;
        if(_S10 >= u32(65536))
        {
            var _S12 : u32 = _S9 / (_S10 / u32(65536));
            _S11 = _S12;
        }
        else
        {
            var _S13 : u32 = u32(65536) / _S10;
            _S11 = _S9 * _S13;
        }
        ranks_0[i_0] = _S11;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S14 : bool = (ranks_0[i32(0)]) == u32(65535);
    var _S15 : bool;
    if(_S14)
    {
        _S15 = (ranks_0[i32(1)]) == u32(65535);
    }
    else
    {
        _S15 = false;
    }
    var _S16 : bool = (ranks_0[i32(2)]) == u32(65535);
    var _S17 : bool;
    if(_S16)
    {
        _S17 = (ranks_0[i32(3)]) == u32(65535);
    }
    else
    {
        _S17 = false;
    }
    if(_S15)
    {
        _S15 = (ranks_0[i32(3)]) != u32(65535);
    }
    else
    {
        _S15 = false;
    }
    if(_S15)
    {
        _S15 = true;
    }
    else
    {
        if(_S17)
        {
            _S15 = (ranks_0[i32(1)]) != u32(65535);
        }
        else
        {
            _S15 = false;
        }
    }
    var _S18 : u32 = ranks_0[i32(0)];
    var _S19 : u32 = ranks_0[i32(1)];
    var _S20 : u32 = ranks_0[i32(3)];
    var _S21 : u32 = select(_S19, _S20, _S15);
    return (_S18 | (((_S21 << (u32(16))))));
}

@compute
@workgroup_size(64, 1, 1)
fn noiseStart(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var _S22 : u32 = id_0.x;
    var _S23 : bool = _S22 < (entryPointParams_0.size_0 * entryPointParams_0.size_0 * u32(32));
    if(_S23)
    {
        var _S24 : u32 = _S22 % entryPointParams_0.size_0;
        var _S25 : u32 = _S22 / entryPointParams_0.size_0;
        var _S26 : u32 = _S25 % entryPointParams_0.size_0;
        var _S27 : u32 = _S22 / (entryPointParams_0.size_0 * entryPointParams_0.size_0);
        var _S28 : u32 = noiseWhite(_S24, _S26, _S27, entryPointParams_0.size_0);
        entryPointParams_tensor_0[_S22] = _S28;
    }
    return;
}

fn noiseBlock( sweep_1 : u32,  colour_1 : u32,  block_0 : u32,  size_3 : u32) -> vec3<u32>
{
    var _S29 : u32 = hash(sweep_1 * u32(7919) + u32(1));
    var _S30 : u32 = size_3 / u32(16);
    var _S31 : u32 = block_0 % _S30;
    var _S32 : u32 = block_0 / _S30;
    var _S33 : u32 = _S32 % _S30;
    var _S34 : u32 = block_0 / (_S30 * _S30);
    var _S35 : vec3<u32> = vec3<u32>(_S31, _S33, _S34);
    var _S36 : vec3<u32> = vec3<u32>((colour_1 & (u32(1))), (((colour_1 >> (u32(1)))) & (u32(1))), (colour_1 >> (u32(2))));
    return _S35 * vec3<u32>(u32(16)) + _S36 * vec3<u32>(u32(8)) + vec3<u32>((_S29 & (u32(7))), (((_S29 >> (u32(3)))) & (u32(7))), (((_S29 >> (u32(6)))) & (u32(7))));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S37 : u32 = hash(index_0);
    var _S38 : u32 = hash((seed_0 ^ (_S37)));
    return _S38;
}

fn noiseExp_0( q_0 : u32) -> u32
{
    var _S39 : u32 = ((q_0 * u32(23637)) >> (u32(14)));
    var _S40 : i32 = i32((_S39 & (u32(4095))));
    var e_0 : i32 = i32(-3486) + (((i32(448) * _S40) >> (u32(12))));
    var e_1 : i32 = i32(15688) + (((e_0 * _S40) >> (u32(12))));
    var e_2 : i32 = i32(-45418) + (((e_1 * _S40) >> (u32(12))));
    var e_3 : i32 = i32(65536) + (((e_2 * _S40) >> (u32(12))));
    return (u32(e_3) >> ((min((_S39 >> (u32(12))), u32(31)))));
}

fn noiseRoot_0( q_1 : u32) -> u32
{
    var root_0 : u32 = u32(0);
    var bit_0 : u32 = u32(268435456);
    var rest_0 : u32 = q_1;
    loop
    {
        if(bit_0 != u32(0))
        {
        }
        else
        {
            break;
        }
        var _S41 : u32 = root_0 + bit_0;
        var _S42 : bool = rest_0 >= _S41;
        var _S43 : u32 = select(u32(0), _S41, _S42);
        var rest_1 : u32 = rest_0 - _S43;
        var _S44 : u32 = (root_0 >> (u32(1)));
        var _S45 : u32 = select(u32(0), bit_0, _S42);
        var _S46 : u32 = _S44 + _S45;
        var bit_1 : u32 = (bit_0 >> (u32(2)));
        root_0 = _S46;
        bit_0 = bit_1;
        rest_0 = rest_1;
    }
    return root_0;
}

fn noiseFalloff_0( a_0 : u32,  v_0 : u32) -> u32
{
    var _S47 : u32 = (a_0 & (u32(65535)));
    var _S48 : u32 = (v_0 & (u32(65535)));
    var _S49 : u32 = ((max(_S47, _S48) - min(_S47, _S48)) >> (u32(2)));
    var _S50 : u32 = (a_0 >> (u32(16)));
    var _S51 : u32 = (v_0 >> (u32(16)));
    var _S52 : u32 = ((max(_S50, _S51) - min(_S50, _S51)) >> (u32(2)));
    var _S53 : u32 = noiseRoot_0(_S49 * _S49 + _S52 * _S52);
    var _S54 : u32 = noiseExp_0((_S53 >> (u32(2))));
    return _S54;
}

fn noiseNear_0( _S55 : vec3<u32>,  _S56 : u32,  _S57 : u32,  _S58 : u32,  _S59 : u32) -> vec2<u32>
{
    var _S60 : u32 = entryPointParams_tensor_1[(_S55.z * _S59 + _S55.y) * _S59 + _S55.x];
    var _S61 : u32 = noiseExp_0(_S56 * u32(929));
    var _S62 : u32 = (_S61 >> (u32(8)));
    var _S63 : u32 = noiseFalloff_0(_S57, _S60);
    var _S64 : u32 = noiseFalloff_0(_S58, _S60);
    return vec2<u32>(_S62) * vec2<u32>(_S63, _S64);
}

fn noiseEnergy_0( _S65 : vec3<u32>,  _S66 : u32,  _S67 : u32,  _S68 : vec3<u32>,  _S69 : u32) -> vec2<u32>
{
    var _S70 : bool;
    var _S71 : vec2<u32> = vec2<u32>(u32(0));
    var d_0 : i32 = i32(-3);
    var e_4 : vec2<u32> = _S71;
    loop
    {
        if(d_0 <= i32(3))
        {
        }
        else
        {
            break;
        }
        var dx_0 : i32 = i32(-3);
        var e_5 : vec2<u32> = e_4;
        loop
        {
            if(dx_0 <= i32(3))
            {
            }
            else
            {
                break;
            }
            var _S72 : i32 = i32(_S69);
            var _S73 : u32 = _S69 - u32(1);
            var _S74 : vec3<u32> = vec3<u32>(((_S65.x + u32(dx_0 + _S72)) & (_S73)), ((_S65.y + u32(d_0 + _S72)) & (_S73)), _S65.z);
            var _S75 : bool = dx_0 != i32(0);
            if(_S75)
            {
                _S70 = true;
            }
            else
            {
                _S70 = d_0 != i32(0);
            }
            var _S76 : bool;
            if(_S70)
            {
                _S76 = !(all((_S74 == _S68)));
            }
            else
            {
                _S76 = false;
            }
            if(_S76)
            {
                var _S77 : vec2<u32> = noiseNear_0(_S74, u32(dx_0 * dx_0 + d_0 * d_0), _S66, _S67, _S69);
                var e_6 : vec2<u32> = e_5 + _S77;
                e_5 = e_6;
            }
            var dx_1 : i32 = dx_0 + i32(1);
            dx_0 = dx_1;
        }
        var _S78 : vec3<u32> = vec3<u32>(_S65.x, _S65.y, (_S65.z + u32(d_0 + i32(32))) % u32(32));
        var _S79 : bool = d_0 != i32(0);
        if(_S79)
        {
            _S70 = !(all((_S78 == _S68)));
        }
        else
        {
            _S70 = false;
        }
        if(_S70)
        {
            var _S80 : vec2<u32> = noiseNear_0(_S78, u32(d_0 * d_0), _S66, _S67, _S69);
            var e_7 : vec2<u32> = e_5 + _S80;
            e_4 = e_7;
        }
        else
        {
            e_4 = e_5;
        }
        var d_1 : i32 = d_0 + i32(1);
        d_0 = d_1;
    }
    return e_4;
}

fn noiseSweepBlock_0( _S81 : u32,  _S82 : u32,  _S83 : u32,  _S84 : u32)
{
    var _S85 : vec3<u32> = noiseBlock(_S81, _S82, _S83, _S84);
    var _S86 : u32 = _S84 - u32(1);
    var _S87 : vec3<u32> = vec3<u32>(_S86, _S86, u32(31));
    var attempt_0 : u32 = u32(0);
    loop
    {
        if(attempt_0 < u32(512))
        {
        }
        else
        {
            break;
        }
        var _S88 : u32 = _S85.x;
        var _S89 : u32 = _S85.y;
        var _S90 : u32 = stream((((_S88 | (((_S89 << (u32(11))))))) | ((((_S85.z) << (u32(22)))))), _S81 * u32(4096) + attempt_0);
        var _S91 : u32 = hash(_S90);
        var _S92 : vec3<u32> = ((_S85 + vec3<u32>((_S91 & (u32(7))), (((_S91 >> (u32(3)))) & (u32(7))), (((_S91 >> (u32(6)))) & (u32(7))))) & (_S87));
        var _S93 : u32 = ((_S88 + ((((_S91 >> (u32(9)))) & (u32(7))))) & (_S86));
        var _S94 : u32 = ((_S89 + ((((_S91 >> (u32(12)))) & (u32(7))))) & (_S86));
        var _S95 : u32 = _S92.z;
        var _S96 : vec3<u32> = vec3<u32>(_S93, _S94, _S95);
        var _S97 : u32 = _S95 * _S84;
        var _S98 : u32 = (_S97 + _S92.y) * _S84 + _S92.x;
        var _S99 : u32 = (_S97 + _S94) * _S84 + _S93;
        var _S100 : u32 = entryPointParams_tensor_1[_S98];
        var _S101 : u32 = entryPointParams_tensor_1[_S99];
        var _S102 : vec2<u32> = noiseEnergy_0(_S92, _S100, _S101, _S96, _S84);
        var _S103 : vec2<u32> = noiseEnergy_0(_S96, _S101, _S100, _S92, _S84);
        var _S104 : bool = _S98 != _S99;
        var _S105 : bool;
        if(_S104)
        {
            _S105 = (_S102.y + _S103.y) < (_S102.x + _S103.x);
        }
        else
        {
            _S105 = false;
        }
        if(_S105)
        {
            entryPointParams_tensor_1[_S98] = _S101;
            entryPointParams_tensor_1[_S99] = _S100;
        }
        var attempt_1 : u32 = attempt_0 + u32(1);
        attempt_0 = attempt_1;
    }
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn noiseSweep(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var _S106 : u32 = id_1.x;
    var _S107 : bool = _S106 < (entryPointParams_1.size_1 / u32(16) * (entryPointParams_1.size_1 / u32(16)) * u32(2));
    if(_S107)
    {
        noiseSweepBlock_0(entryPointParams_1.sweep_0, entryPointParams_1.colour_0, _S106, entryPointParams_1.size_1);
    }
    return;
}

struct Random
{
     state : u32,
     value : f32,
};

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S108 : Random;
    _S108.state = state_0;
    _S108.value = value_0;
    return _S108;
}

fn pcg( state_1 : u32) -> Random
{
    var _S109 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S110 : u32 = hash(state_1);
    return Random_x24init_0(_S109, f32(_S110) / 4.294967296e+09f);
}

fn noiseOffset( k_2 : u32) -> vec2<u32>
{
    var _S111 : vec2<u32> = vec2<u32>(u32(16));
    var _S112 : vec2<u32> = (vec2<u32>(k_2 * u32(3242174889), k_2 * u32(2447445414)) >> (_S111));
    var _S113 : u32 = (fkBlueNoiseSize());
    return ((_S112 * vec2<u32>(_S113)) >> (_S111));
}

fn noiseOrigin( p_0 : vec2<u32>,  k_3 : u32) -> u32
{
    var _S114 : u32 = ((((p_0.x) >> (u32(11)))) | ((((((p_0.y) >> (u32(11)))) << (u32(4))))));
    var _S115 : vec2<u32> = noiseOffset(u32(8192) + ((k_3 >> (u32(10)))) + ((_S114 << (u32(20)))));
    var _S116 : vec2<u32> = ((p_0 + _S115) & (vec2<u32>(u32(2047))));
    return ((((_S116.x) | ((((_S116.y) << (u32(11))))))) | (((((k_3 & (u32(1023)))) << (u32(22))))));
}

fn noiseAddress( origin_0 : u32,  bounce_0 : u32) -> u32
{
    var _S117 : vec2<u32> = vec2<u32>((origin_0 & (u32(2047))), (((origin_0 >> (u32(11)))) & (u32(2047))));
    var _S118 : vec2<u32> = noiseOffset(u32(64) + bounce_0 * u32(17));
    var _S119 : vec2<u32> = ((_S117 + _S118) & (vec2<u32>(u32(2047))));
    return ((((_S119.x) | ((((_S119.y) << (u32(11))))))) | (((((origin_0 >> (u32(22)))) << (u32(22))))));
}

fn draw( address_0 : u32,  variable_0 : u32) -> Random
{
    var _S120 : u32 = (address_0 >> (u32(22)));
    var _S121 : u32 = _S120 / u32(32);
    var _S122 : vec2<u32> = vec2<u32>((address_0 & (u32(2047))), (((address_0 >> (u32(11)))) & (u32(2047))));
    var _S123 : u32 = (variable_0 & (u32(2147483647)));
    var _S124 : vec2<u32> = noiseOffset(_S123);
    var _S125 : vec2<u32> = _S122 + _S124;
    var _S126 : vec2<u32> = noiseOffset(u32(4096) + _S121);
    var _S127 : vec2<u32> = _S125 + _S126;
    var _S128 : u32 = (fkBlueNoiseSize());
    var _S129 : vec2<u32> = (_S127 & (vec2<u32>((_S128 - u32(1)))));
    var _S130 : u32 = (fkBlueNoise((_S129.x), (_S129.y), ((_S120 + (((_S121 * u32(2654435769)) >> (u32(27))))) % u32(32))));
    var _S131 : bool = ((variable_0 & (u32(2147483648)))) != u32(0);
    var _S132 : u32 = stream(address_0, _S123);
    var _S133 : Random = pcg(_S132);
    var _S134 : f32;
    if(_S130 == u32(4294967295))
    {
        var _S135 : Random = pcg(_S133.state);
        _S134 = select(_S133.value, _S135.value, _S131);
    }
    else
    {
        var _S136 : u32 = (_S130 & (u32(65535)));
        var _S137 : u32 = (_S130 >> (u32(16)));
        _S134 = (f32(select(_S136, _S137, _S131)) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S134);
}

