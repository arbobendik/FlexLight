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
        var _S3 : u32;
        if(i_0 < u32(2))
        {
            _S3 = x_1;
        }
        else
        {
            _S3 = ((x_1 + size_2 / u32(2)) & ((size_2 - u32(1))));
        }
        var l_0 : u32 = _S3;
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
            var _S4 : u32 = hash((((((r_0 ^ (((t_0 << (u32(16))))))) ^ (((k_0 << (u32(28))))))) ^ (((((i_0 & (u32(1)))) << (u32(31)))))));
            var _S5 : u32 = (l_0 ^ (((_S4 & ((size_2 - u32(1)))))));
            var k_1 : u32 = k_0 + u32(1);
            l_0 = r_0;
            r_0 = _S5;
            k_0 = k_1;
        }
        var _S6 : u32 = l_0 + r_0 * size_2;
        var _S7 : u32 = size_2 * size_2;
        var _S8 : u32;
        if(_S7 >= u32(65536))
        {
            var _S9 : u32 = _S6 / (_S7 / u32(65536));
            _S8 = _S9;
        }
        else
        {
            var _S10 : u32 = u32(65536) / _S7;
            _S8 = _S6 * _S10;
        }
        ranks_0[i_0] = _S8;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S11 : bool = (ranks_0[i32(0)]) == u32(65535);
    var _S12 : bool;
    if(_S11)
    {
        _S12 = (ranks_0[i32(1)]) == u32(65535);
    }
    else
    {
        _S12 = false;
    }
    var _S13 : bool = (ranks_0[i32(2)]) == u32(65535);
    var _S14 : bool;
    if(_S13)
    {
        _S14 = (ranks_0[i32(3)]) == u32(65535);
    }
    else
    {
        _S14 = false;
    }
    if(_S12)
    {
        _S12 = (ranks_0[i32(3)]) != u32(65535);
    }
    else
    {
        _S12 = false;
    }
    if(_S12)
    {
        _S12 = true;
    }
    else
    {
        if(_S14)
        {
            _S12 = (ranks_0[i32(1)]) != u32(65535);
        }
        else
        {
            _S12 = false;
        }
    }
    var _S15 : u32 = ranks_0[i32(0)];
    if(_S12)
    {
        i_0 = ranks_0[i32(3)];
    }
    else
    {
        i_0 = ranks_0[i32(1)];
    }
    return (_S15 | (((i_0 << (u32(16))))));
}

@compute
@workgroup_size(64, 1, 1)
fn noiseStart(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var _S16 : u32 = id_0.x;
    var _S17 : bool = _S16 < (entryPointParams_0.size_0 * entryPointParams_0.size_0 * u32(32));
    if(_S17)
    {
        var _S18 : u32 = _S16 % entryPointParams_0.size_0;
        var _S19 : u32 = _S16 / entryPointParams_0.size_0;
        var _S20 : u32 = _S19 % entryPointParams_0.size_0;
        var _S21 : u32 = _S16 / (entryPointParams_0.size_0 * entryPointParams_0.size_0);
        var _S22 : u32 = noiseWhite(_S18, _S20, _S21, entryPointParams_0.size_0);
        entryPointParams_tensor_0[_S16] = _S22;
    }
    return;
}

fn noiseBlock( sweep_1 : u32,  colour_1 : u32,  block_0 : u32,  size_3 : u32) -> vec3<u32>
{
    var _S23 : u32 = hash(sweep_1 * u32(7919) + u32(1));
    var _S24 : u32 = size_3 / u32(16);
    var _S25 : u32 = block_0 % _S24;
    var _S26 : u32 = block_0 / _S24;
    var _S27 : u32 = _S26 % _S24;
    var _S28 : u32 = block_0 / (_S24 * _S24);
    var _S29 : vec3<u32> = vec3<u32>(_S25, _S27, _S28);
    var _S30 : vec3<u32> = vec3<u32>((colour_1 & (u32(1))), (((colour_1 >> (u32(1)))) & (u32(1))), (colour_1 >> (u32(2))));
    return _S29 * vec3<u32>(u32(16)) + _S30 * vec3<u32>(u32(8)) + vec3<u32>((_S23 & (u32(7))), (((_S23 >> (u32(3)))) & (u32(7))), (((_S23 >> (u32(6)))) & (u32(7))));
}

fn stream( seed_0 : u32,  index_0 : u32) -> u32
{
    var _S31 : u32 = hash(index_0);
    var _S32 : u32 = hash((seed_0 ^ (_S31)));
    return _S32;
}

fn noiseExp_0( q_0 : u32) -> u32
{
    var _S33 : u32 = ((q_0 * u32(23637)) >> (u32(14)));
    var _S34 : i32 = i32((_S33 & (u32(4095))));
    var e_0 : i32 = i32(-3486) + (((i32(448) * _S34) >> (u32(12))));
    var e_1 : i32 = i32(15688) + (((e_0 * _S34) >> (u32(12))));
    var e_2 : i32 = i32(-45418) + (((e_1 * _S34) >> (u32(12))));
    var e_3 : i32 = i32(65536) + (((e_2 * _S34) >> (u32(12))));
    var _S35 : u32 = (_S33 >> (u32(12)));
    var _S36 : u32;
    if(_S35 < u32(31))
    {
        _S36 = (u32(e_3) >> (_S35));
    }
    else
    {
        _S36 = u32(0);
    }
    return _S36;
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
        var _S37 : u32 = root_0 + bit_0;
        var _S38 : bool = rest_0 >= _S37;
        var _S39 : u32;
        if(_S38)
        {
            _S39 = _S37;
        }
        else
        {
            _S39 = u32(0);
        }
        var rest_1 : u32 = rest_0 - _S39;
        var _S40 : u32 = (root_0 >> (u32(1)));
        var _S41 : u32;
        if(_S38)
        {
            _S41 = bit_0;
        }
        else
        {
            _S41 = u32(0);
        }
        var _S42 : u32 = _S40 + _S41;
        var bit_1 : u32 = (bit_0 >> (u32(2)));
        root_0 = _S42;
        bit_0 = bit_1;
        rest_0 = rest_1;
    }
    return root_0;
}

fn noiseFalloff_0( a_0 : u32,  v_0 : u32) -> u32
{
    var _S43 : u32 = (a_0 & (u32(65535)));
    var _S44 : u32 = (v_0 & (u32(65535)));
    var _S45 : u32 = ((max(_S43, _S44) - min(_S43, _S44)) >> (u32(2)));
    var _S46 : u32 = (a_0 >> (u32(16)));
    var _S47 : u32 = (v_0 >> (u32(16)));
    var _S48 : u32 = ((max(_S46, _S47) - min(_S46, _S47)) >> (u32(2)));
    var _S49 : u32 = noiseRoot_0(_S45 * _S45 + _S48 * _S48);
    var _S50 : u32 = noiseExp_0((_S49 >> (u32(2))));
    return _S50;
}

fn noiseNear_0( _S51 : vec3<u32>,  _S52 : u32,  _S53 : u32,  _S54 : u32,  _S55 : u32) -> vec2<u32>
{
    var _S56 : u32 = entryPointParams_tensor_1[(_S51.z * _S55 + _S51.y) * _S55 + _S51.x];
    var _S57 : u32 = noiseExp_0(_S52 * u32(929));
    var _S58 : u32 = (_S57 >> (u32(8)));
    var _S59 : u32 = noiseFalloff_0(_S53, _S56);
    var _S60 : u32 = noiseFalloff_0(_S54, _S56);
    return vec2<u32>(_S58) * vec2<u32>(_S59, _S60);
}

fn noiseEnergy_0( _S61 : vec3<u32>,  _S62 : u32,  _S63 : u32,  _S64 : vec3<u32>,  _S65 : u32) -> vec2<u32>
{
    var _S66 : bool;
    var _S67 : vec2<u32> = vec2<u32>(u32(0));
    var d_0 : i32 = i32(-3);
    var e_4 : vec2<u32> = _S67;
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
            var _S68 : i32 = i32(_S65);
            var _S69 : u32 = _S65 - u32(1);
            var _S70 : vec3<u32> = vec3<u32>(((_S61.x + u32(dx_0 + _S68)) & (_S69)), ((_S61.y + u32(d_0 + _S68)) & (_S69)), _S61.z);
            var _S71 : bool = dx_0 != i32(0);
            if(_S71)
            {
                _S66 = true;
            }
            else
            {
                _S66 = d_0 != i32(0);
            }
            var _S72 : bool;
            if(_S66)
            {
                _S72 = !(all((_S70 == _S64)));
            }
            else
            {
                _S72 = false;
            }
            if(_S72)
            {
                var _S73 : vec2<u32> = noiseNear_0(_S70, u32(dx_0 * dx_0 + d_0 * d_0), _S62, _S63, _S65);
                var e_6 : vec2<u32> = e_5 + _S73;
                e_5 = e_6;
            }
            var dx_1 : i32 = dx_0 + i32(1);
            dx_0 = dx_1;
        }
        var _S74 : vec3<u32> = vec3<u32>(_S61.x, _S61.y, (_S61.z + u32(d_0 + i32(32))) % u32(32));
        var _S75 : bool = d_0 != i32(0);
        if(_S75)
        {
            _S66 = !(all((_S74 == _S64)));
        }
        else
        {
            _S66 = false;
        }
        if(_S66)
        {
            var _S76 : vec2<u32> = noiseNear_0(_S74, u32(d_0 * d_0), _S62, _S63, _S65);
            var e_7 : vec2<u32> = e_5 + _S76;
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

fn noiseSweepBlock_0( _S77 : u32,  _S78 : u32,  _S79 : u32,  _S80 : u32)
{
    var _S81 : vec3<u32> = noiseBlock(_S77, _S78, _S79, _S80);
    var _S82 : u32 = _S80 - u32(1);
    var _S83 : vec3<u32> = vec3<u32>(_S82, _S82, u32(31));
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
        var _S84 : u32 = _S81.x;
        var _S85 : u32 = _S81.y;
        var _S86 : u32 = stream((((_S84 | (((_S85 << (u32(11))))))) | ((((_S81.z) << (u32(22)))))), _S77 * u32(4096) + attempt_0);
        var _S87 : u32 = hash(_S86);
        var _S88 : vec3<u32> = ((_S81 + vec3<u32>((_S87 & (u32(7))), (((_S87 >> (u32(3)))) & (u32(7))), (((_S87 >> (u32(6)))) & (u32(7))))) & (_S83));
        var _S89 : u32 = ((_S84 + ((((_S87 >> (u32(9)))) & (u32(7))))) & (_S82));
        var _S90 : u32 = ((_S85 + ((((_S87 >> (u32(12)))) & (u32(7))))) & (_S82));
        var _S91 : u32 = _S88.z;
        var _S92 : vec3<u32> = vec3<u32>(_S89, _S90, _S91);
        var _S93 : u32 = _S91 * _S80;
        var _S94 : u32 = (_S93 + _S88.y) * _S80 + _S88.x;
        var _S95 : u32 = (_S93 + _S90) * _S80 + _S89;
        var _S96 : u32 = entryPointParams_tensor_1[_S94];
        var _S97 : u32 = entryPointParams_tensor_1[_S95];
        var _S98 : vec2<u32> = noiseEnergy_0(_S88, _S96, _S97, _S92, _S80);
        var _S99 : vec2<u32> = noiseEnergy_0(_S92, _S97, _S96, _S88, _S80);
        var _S100 : bool = _S94 != _S95;
        var _S101 : bool;
        if(_S100)
        {
            _S101 = (_S98.y + _S99.y) < (_S98.x + _S99.x);
        }
        else
        {
            _S101 = false;
        }
        if(_S101)
        {
            entryPointParams_tensor_1[_S94] = _S97;
            entryPointParams_tensor_1[_S95] = _S96;
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
    var _S102 : u32 = id_1.x;
    var _S103 : bool = _S102 < (entryPointParams_1.size_1 / u32(16) * (entryPointParams_1.size_1 / u32(16)) * u32(2));
    if(_S103)
    {
        noiseSweepBlock_0(entryPointParams_1.sweep_0, entryPointParams_1.colour_0, _S102, entryPointParams_1.size_1);
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
    var _S104 : Random;
    _S104.state = state_0;
    _S104.value = value_0;
    return _S104;
}

fn pcg( state_1 : u32) -> Random
{
    var _S105 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S106 : u32 = hash(state_1);
    return Random_x24init_0(_S105, f32(_S106) / 4.294967296e+09f);
}

fn noiseOffset( k_2 : u32) -> vec2<u32>
{
    var _S107 : vec2<u32> = vec2<u32>(u32(16));
    var _S108 : vec2<u32> = (vec2<u32>(k_2 * u32(3242174889), k_2 * u32(2447445414)) >> (_S107));
    var _S109 : u32 = (fkBlueNoiseSize());
    return ((_S108 * vec2<u32>(_S109)) >> (_S107));
}

fn noiseOrigin( p_0 : vec2<u32>,  k_3 : u32) -> u32
{
    var _S110 : u32 = ((((p_0.x) >> (u32(11)))) | ((((((p_0.y) >> (u32(11)))) << (u32(4))))));
    var _S111 : vec2<u32> = noiseOffset(u32(8192) + ((k_3 >> (u32(10)))) + ((_S110 << (u32(20)))));
    var _S112 : vec2<u32> = ((p_0 + _S111) & (vec2<u32>(u32(2047))));
    return ((((_S112.x) | ((((_S112.y) << (u32(11))))))) | (((((k_3 & (u32(1023)))) << (u32(22))))));
}

fn noiseAddress( origin_0 : u32,  bounce_0 : u32) -> u32
{
    var _S113 : vec2<u32> = vec2<u32>((origin_0 & (u32(2047))), (((origin_0 >> (u32(11)))) & (u32(2047))));
    var _S114 : vec2<u32> = noiseOffset(u32(64) + bounce_0 * u32(17));
    var _S115 : vec2<u32> = ((_S113 + _S114) & (vec2<u32>(u32(2047))));
    return ((((_S115.x) | ((((_S115.y) << (u32(11))))))) | (((((origin_0 >> (u32(22)))) << (u32(22))))));
}

fn draw( address_0 : u32,  variable_0 : u32) -> Random
{
    var _S116 : u32 = (address_0 >> (u32(22)));
    var _S117 : u32 = _S116 / u32(32);
    var _S118 : vec2<u32> = vec2<u32>((address_0 & (u32(2047))), (((address_0 >> (u32(11)))) & (u32(2047))));
    var _S119 : u32 = (variable_0 & (u32(2147483647)));
    var _S120 : vec2<u32> = noiseOffset(_S119);
    var _S121 : vec2<u32> = _S118 + _S120;
    var _S122 : vec2<u32> = noiseOffset(u32(4096) + _S117);
    var _S123 : vec2<u32> = _S121 + _S122;
    var _S124 : u32 = (fkBlueNoiseSize());
    var _S125 : vec2<u32> = (_S123 & (vec2<u32>((_S124 - u32(1)))));
    var _S126 : u32 = (fkBlueNoise((_S125.x), (_S125.y), ((_S116 + (((_S117 * u32(2654435769)) >> (u32(27))))) % u32(32))));
    var _S127 : bool = ((variable_0 & (u32(2147483648)))) != u32(0);
    var _S128 : u32 = stream(address_0, _S119);
    var _S129 : Random = pcg(_S128);
    var _S130 : f32;
    if(_S126 == u32(4294967295))
    {
        if(_S127)
        {
            var _S131 : Random = pcg(_S129.state);
            _S130 = _S131.value;
        }
        else
        {
            _S130 = _S129.value;
        }
    }
    else
    {
        var _S132 : u32;
        if(_S127)
        {
            _S132 = (_S126 >> (u32(16)));
        }
        else
        {
            _S132 = (_S126 & (u32(65535)));
        }
        _S130 = (f32(_S132) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S130);
}

