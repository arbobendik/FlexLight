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

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S52 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S52;
    var start_0 : u32 = u32(0);
    loop
    {
        if(bin_0 < u32(40))
        {
        }
        else
        {
            break;
        }
        var _S53 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S54 : u32 = (_S53 + u32(63)) / u32(64);
        var _S55 : bool = group_0 < _S54;
        if(_S55)
        {
            var _S56 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S57 : bool = _S56 < _S53;
            if(_S57)
            {
                var _S58 : u32 = (queued_shifts[(u32(83) + start_0 + _S56)]);
                return _S58;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S54;
        var start_1 : u32 = start_0 + _S53;
        var bin_1 : u32 = bin_0 + u32(1);
        bin_0 = bin_1;
        group_0 = group_1;
        start_0 = start_1;
    }
    return u32(4294967295);
}

var<workgroup> bin_jobs_0 : array<atomic<u32>, i32(40)>;

var<workgroup> bin_offsets_0 : array<u32, i32(40)>;

fn queueShifts_0( p_3 : vec2<i32>,  bins_1 : array<u32, i32(3)>,  global_invocation_id_0 : vec3<u32>,  local_invocation_index_1 : u32)
{
    var _S59 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
    var slots_0 : array<u32, i32(3)>;
    slots_0[i32(0)] = u32(0);
    slots_0[i32(1)] = u32(0);
    slots_0[i32(2)] = u32(0);
    var t_4 : u32 = u32(0);
    loop
    {
        if(t_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S60 : u32 = t_4;
        var _S61 : bool = (bins_1[t_4]) < u32(40);
        if(_S61)
        {
            var _S62 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S60]]), u32(1));
            slots_0[t_4] = _S62;
        }
        var t_5 : u32 = t_4 + u32(1);
        t_4 = t_5;
    }
    workgroupBarrier();
    var _S63 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S63)
    {
        var _S64 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S65 : bool = _S64 > u32(0);
        if(_S65)
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
                var _S66 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_2 : u32 = groups_0 + _S66;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_2;
            }
            var _S67 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S64)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S67;
        }
    }
    workgroupBarrier();
    t_4 = u32(0);
    loop
    {
        if(t_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S68 : u32 = t_4;
        var _S69 : bool = (bins_1[t_4]) < u32(40);
        if(_S69)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S68]] + slots_0[t_4])] = ((((u32(p_3.x) | (((u32(p_3.y) << (u32(14))))))) | (((t_4 << (u32(28)))))));
        }
        var t_6 : u32 = t_4 + u32(1);
        t_4 = t_6;
    }
    var _S70 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S70)
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
            var _S71 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S71 + u32(63)) / u32(64);
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
    var _S72 : vec3<f32> = (((view_0) * (position_0 - camera_0)));
    var _S73 : vec2<f32> = vec2<f32>(0.5f);
    var _S74 : vec2<f32> = _S72.xy / vec2<f32>(_S72.z) * _S73 + _S73;
    var _S75 : vec2<f32> = vec2<f32>(_S74.x, 1.0f - _S74.y);
    var _S76 : vec2<u32> = (uniforms_uint.render_size);
    return _S75 * vec2<f32>(_S76);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S77 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S78 : bool;
    if(_S77)
    {
        var _S79 : vec2<u32> = (uniforms_uint.render_size);
        _S78 = (all((q_0 < vec2<i32>(_S79))));
    }
    else
    {
        _S78 = false;
    }
    if(_S78)
    {
        var _S80 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S78 = (bitcast<f32>((_S80.w))) > 0.0f;
    }
    else
    {
        _S78 = false;
    }
    return _S78;
}

fn temporalNeighbor_0( p_4 : vec2<i32>,  dom_1 : Domain) -> vec2<i32>
{
    var _S81 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S82 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S83 : vec2<f32> = project_0(_S81, _S82, dom_1.x1);
    var _S84 : vec2<i32> = vec2<i32>(floor(_S83));
    var _S85 : bool = previousValid_0(_S84);
    var _S86 : bool = !_S85;
    if(_S86)
    {
        return vec2<i32>(i32(-1));
    }
    var _S87 : Domain = (previousDomain((_S84)));
    var _S88 : bool = (_S87.hit.instance_index) == (dom_1.hit.instance_index);
    var _S89 : bool;
    if(_S88)
    {
        var _S90 : f32 = distance(_S87.x1, dom_1.x1);
        var _S91 : f32 = dom_1.hit.distance * 8.0f;
        var _S92 : vec2<u32> = (uniforms_uint.render_size);
        _S89 = _S90 <= (_S91 / f32(_S92.x));
    }
    else
    {
        _S89 = false;
    }
    if(_S89)
    {
        return _S84;
    }
    var _S93 : vec2<f32> = vec2<f32>(p_4 + _S84) + vec2<f32>(1.0f);
    var _S94 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S95 : vec3<f32> = (uniforms_float.camera_position);
    var _S96 : vec2<f32> = project_0(_S94, _S95, _S87.x1);
    var _S97 : vec2<i32> = vec2<i32>(floor(_S93 - _S96));
    var _S98 : vec2<i32> = vec2<i32>(i32(-1));
    var _S99 : bool = previousValid_0(_S97);
    var _S100 : vec2<i32> = select(_S98, _S97, _S99);
    return _S100;
}

fn sameDomain_0( a_0 : Domain,  b_0 : Domain) -> bool
{
    var _S101 : bool = (all(((a_0.x0) == (b_0.x0))));
    var _S102 : bool;
    if(_S101)
    {
        _S102 = (a_0.hit.instance_index) == (b_0.hit.instance_index);
    }
    else
    {
        _S102 = false;
    }
    if(_S102)
    {
        _S102 = (a_0.hit.triangle_index) == (b_0.hit.triangle_index);
    }
    else
    {
        _S102 = false;
    }
    if(_S102)
    {
        _S102 = (all(((a_0.hit.uv) == (b_0.hit.uv))));
    }
    else
    {
        _S102 = false;
    }
    return _S102;
}

fn temporalJob_0( p_5 : vec2<i32>,  t_7 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S103 : vec3<f32> = vec3<f32>(0.0f);
    var _S104 : Domain = Domain_x24init_0(_S103, _S103, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_2 : Domain = _S104;
    var _S105 : bool = t_7 > u32(1);
    var _S106 : bool;
    if(_S105)
    {
        _S106 = true;
    }
    else
    {
        var _S107 : bool = (storedDomain(reservoir_initial, (p_5), &(dom_2)));
        _S106 = !_S107;
    }
    if(_S106)
    {
        return false;
    }
    var _S108 : vec2<i32> = temporalNeighbor_0(p_5, dom_2);
    var _S109 : bool = (_S108.x) < i32(0);
    if(_S109)
    {
        return false;
    }
    var _S110 : bool = t_7 == u32(0);
    if(_S110)
    {
        var _S111 : Reservoir = (loadReservoir(reservoir_prev, (_S108)));
        var _S112 : ShiftJob = ShiftJob_x24init_0(dom_2, _S111);
        (*job_2) = _S112;
    }
    else
    {
        var _S113 : Domain = (previousDomain((_S108)));
        var _S114 : Reservoir = (loadReservoir(reservoir_initial, (p_5)));
        var _S115 : ShiftJob = ShiftJob_x24init_0(_S113, _S114);
        (*job_2) = _S115;
    }
    var _S116 : bool = ((*job_2).r.w) > 0.0f;
    if(_S116)
    {
        if(_S110)
        {
            _S106 = true;
        }
        else
        {
            var _S117 : bool = sameDomain_0((*job_2).dom, dom_2);
            _S106 = !_S117;
        }
    }
    else
    {
        _S106 = false;
    }
    return _S106;
}

fn temporalBins_0( p_6 : vec2<i32>,  _S118 : ptr<function, array<u32, i32(3)>>)
{
    var _S119 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_2 : array<u32, i32(3)>;
    bins_2[i32(0)] = u32(40);
    bins_2[i32(1)] = u32(40);
    bins_2[i32(2)] = u32(40);
    var t_8 : u32 = u32(0);
    loop
    {
        if(t_8 < u32(2))
        {
        }
        else
        {
            break;
        }
        var _S120 : vec3<f32> = vec3<f32>(0.0f);
        var _S121 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S120, _S120, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S120, 0.0f, vec4<u32>(u32(0)), _S120, _S120));
        var job_3 : ShiftJob = _S121;
        var _S122 : bool = temporalJob_0(p_6, t_8, &(job_3));
        if(_S122)
        {
            var _S123 : u32 = shiftBin_0(job_3.r);
            bins_2[t_8] = _S123;
        }
        var t_9 : u32 = t_8 + u32(1);
        t_8 = t_9;
    }
    (*_S118) = bins_2;
    return;
}

fn countShifts_0( bins_3 : array<u32, i32(3)>,  local_invocation_index_2 : u32)
{
    var t_10 : u32 = u32(0);
    loop
    {
        if(t_10 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S124 : u32 = t_10;
        var _S125 : bool = (bins_3[t_10]) < u32(40);
        if(_S125)
        {
            var _S126 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S124]]), u32(1));
        }
        var t_11 : u32 = t_10 + u32(1);
        t_10 = t_11;
    }
    workgroupBarrier();
    var _S127 : bool = local_invocation_index_2 < u32(40);
    if(_S127)
    {
        var _S128 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S129 : bool = _S128 > u32(0);
        if(_S129)
        {
            var _S130 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S128)));
        }
    }
    return;
}

fn wrongSide_0( is_inside_0 : bool,  refracted_0 : bool,  dir_1 : vec3<f32>,  geometry_n_0 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_0) != ((dot(dir_1, geometry_n_0)) > 0.0f);
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S131 : Ray;
    _S131.origin = origin_0;
    _S131.unit_direction = unit_direction_0;
    return _S131;
}

fn skyRadiance_0( origin_1 : vec3<f32>,  surface_0 : Surface,  is_inside_1 : bool,  dir_2 : vec3<f32>) -> vec3<f32>
{
    var _S132 : bool = wrongSide_0(is_inside_1, false, dir_2, surface_0.geometry_n);
    var _S133 : bool = is_inside_1 != _S132;
    var _S134 : vec3<f32> = (vec3<f32>(0) - surface_0.smooth_n);
    var _S135 : vec3<f32> = select(surface_0.smooth_n, _S134, _S133);
    var _S136 : Ray = Ray_x24init_0(origin_1 + vec3<f32>(surface_0.geometry_offset) * _S135, dir_2);
    var _S137 : vec3<f32> = (env_map_sample((dir_2)));
    var _S138 : vec3<f32> = (shadowTransmittance((_S136), (4.294967296e+09f)));
    return _S137 * _S138;
}

fn searchCDF_0( start_3 : vec2<u32>,  step_0 : vec2<u32>,  count_0 : u32,  u_0 : f32) -> u32
{
    var _S139 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S139;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S140 : u32 = (low_0 + high_0) / u32(2);
        var _S141 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S140)), 0));
        var _S142 : bool = (_S141.x) > u_0;
        if(_S142)
        {
            high_0 = _S140;
        }
        else
        {
            var _S143 : u32 = _S140 + u32(1);
            low_0 = _S143;
        }
    }
    return low_0;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_2 : vec3<f32>,  smooth_n_0 : vec3<f32>,  geometry_offset_0 : f32,  light_dir_0 : vec3<f32>) -> vec3<f32>
{
    var _S144 : vec3<f32> = (normalize((light_dir_0)));
    var _S145 : bool = (dot(smooth_n_0, _S144)) < 0.0f;
    if(_S145)
    {
        return vec3<f32>(0.0f);
    }
    var _S146 : vec3<f32> = origin_2 + vec3<f32>(geometry_offset_0) * smooth_n_0;
    var _S147 : Ray = Ray_x24init_0(_S146, _S144);
    var _S148 : f32 = shadowLength(light_dir_0);
    var _S149 : vec3<f32> = (shadowTransmittance((_S147), (_S148)));
    return _S149;
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
    var _S150 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S151 : bool = cos_a_0 > cos_b_0;
    var _S152 : f32 = select(_S150, 1.0f, _S151);
    return _S152;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S153 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S154 : bool = cos_a_1 > cos_b_1;
    var _S155 : f32 = select(_S153, 0.0f, _S154);
    return _S155;
}

fn importance( node_0 : LightBounds,  p_7 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S156 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S157 : vec3<f32> = node_0.high - node_0.low;
    var _S158 : vec3<f32> = p_7 - _S156;
    var _S159 : vec3<f32> = (normalize((_S158)));
    var _S160 : f32 = dot(_S158, _S158);
    var _S161 : f32 = dot(_S157, _S157) / 4.0f;
    var _S162 : f32 = abs(dot(node_0.w, _S159));
    var _S163 : f32 = sine(node_0.cos_theta_o);
    var _S164 : f32 = sqrt(max(1.0f - _S161 / _S160, 0.0f));
    var _S165 : bool = _S160 < _S161;
    var _S166 : f32 = select(_S164, -1.0f, _S165);
    var _S167 : f32 = sine(_S166);
    var _S168 : f32 = sine(_S162);
    var _S169 : f32 = cosSubClamped(_S168, _S162, _S163, node_0.cos_theta_o);
    var _S170 : f32 = sine(_S162);
    var _S171 : f32 = sinSubClamped(_S170, _S162, _S163, node_0.cos_theta_o);
    var _S172 : f32 = cosSubClamped(_S171, _S169, _S167, _S166);
    var _S173 : bool = _S172 <= 0.0f;
    if(_S173)
    {
        return 0.0f;
    }
    var _S174 : f32 = - dot(_S159, normal_0);
    var _S175 : f32 = node_0.phi * _S172 / max(_S160, length(_S157) / 2.0f);
    var _S176 : f32 = sine(_S174);
    var _S177 : f32 = cosSubClamped(_S176, _S174, _S167, _S166);
    var _S178 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S179 : f32 = select(_S177, 1.0f, _S178);
    return max(_S175 * _S179, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_8 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S180 : f32 = importance(first_0, p_8, normal_1);
    var _S181 : f32 = importance(second_0, p_8, normal_1);
    var _S182 : vec2<f32> = vec2<f32>(_S180, _S181);
    var _S183 : f32 = _S182[child_0] / (_S180 + _S181);
    var _S184 : bool = (_S182[child_0]) > 0.0f;
    var _S185 : f32 = select(0.0f, _S183, _S184);
    return _S185;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_9 : vec3<f32>) -> f32
{
    var _S186 : vec3<f32> = center_0 - p_9;
    var _S187 : f32 = radius_0 * radius_0 / dot(_S186, _S186);
    var _S188 : bool = _S187 >= 1.0f;
    if(_S188)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S187)) / (6.28318548202514648f * _S187);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_3 : vec3<f32>,  smooth_n_1 : vec3<f32>,  start_4 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S189 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S190 : vec2<u32> = _S189.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S190;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S191 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S191.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S192 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S193 : u32 = n_0 + u32(1);
        var _S194 : LightBounds = (lightBounds((_S193)));
        var _S195 : LightBounds = (lightBounds((_S192)));
        var _S196 : u32 = trail_0.x;
        var _S197 : u32 = (_S196 & (u32(1)));
        var _S198 : f32 = childShare(_S194, _S195, origin_3, smooth_n_1, _S197);
        var probability_2 : f32 = probability_1 * _S198;
        var _S199 : bool = _S197 == u32(1);
        var _S200 : u32 = select(_S193, _S192, _S199);
        var _S201 : u32 = trail_0.y;
        var _S202 : vec2<u32> = vec2<u32>((((_S196 >> (u32(1)))) | (((_S201 << (u32(31)))))), (_S201 >> (u32(1))));
        n_0 = _S200;
        trail_0 = _S202;
        probability_1 = probability_2;
    }
    var _S203 : bool = (((_S189).z == (n_0)));
    var _S204 : bool = !_S203;
    var _S205 : bool;
    if(_S204)
    {
        _S205 = true;
    }
    else
    {
        var _S206 : LightBounds = (lightBounds((n_0)));
        var _S207 : f32 = importance(_S206, origin_3, smooth_n_1);
        _S205 = !(_S207 > 0.0f);
    }
    if(_S205)
    {
        _S205 = true;
    }
    else
    {
        var _S208 : bool = (dot(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S208)
        {
            _S205 = !((dot(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S205 = false;
        }
    }
    if(_S205)
    {
        return 0.0f;
    }
    var _S209 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S210 : bool = (_S209.x) == u32(2);
    if(_S210)
    {
        var _S211 : u32 = _S209.y;
        var _S212 : Light = (lights[(_S211)]);
        var _S213 : Light = (lights[(_S211)]);
        var _S214 : f32 = sphereDensity(_S212.position, _S213.variance, start_4);
        return probability_1 * _S214;
    }
    var _S215 : u32 = _S209.y;
    var _S216 : u32 = ((instance_uint[(_S215) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S217 : mat3x3<f32> = (worldTriangle((_S215), (_S216 + _S209.z)));
    var _S218 : f32 = solidAngle(probability_1, cross(_S217[i32(1)] - _S217[i32(0)], _S217[i32(2)] - _S217[i32(0)]), light_point_0 - start_4);
    return _S218;
}

struct SkySample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     color : vec3<f32>,
     random_state : u32,
};

struct Random
{
     state : u32,
     value : f32,
};

fn noiseOffset( k_0 : u32) -> vec2<u32>
{
    var _S219 : vec2<u32> = vec2<u32>(u32(16));
    var _S220 : vec2<u32> = (vec2<u32>(k_0 * u32(3242174889), k_0 * u32(2447445414)) >> (_S219));
    var _S221 : u32 = (fkBlueNoiseSize());
    return ((_S220 * vec2<u32>(_S221)) >> (_S219));
}

fn stream( seed_1 : u32,  index_0 : u32) -> u32
{
    var _S222 : u32 = hash(index_0);
    var _S223 : u32 = hash((seed_1 ^ (_S222)));
    return _S223;
}

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S224 : Random;
    _S224.state = state_0;
    _S224.value = value_0;
    return _S224;
}

fn pcg( state_1 : u32) -> Random
{
    var _S225 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S226 : u32 = hash(state_1);
    return Random_x24init_0(_S225, f32(_S226) / 4.294967296e+09f);
}

fn draw( address_0 : u32,  variable_0 : u32) -> Random
{
    var _S227 : u32 = (address_0 >> (u32(22)));
    var _S228 : u32 = _S227 / u32(32);
    var _S229 : vec2<u32> = vec2<u32>((address_0 & (u32(2047))), (((address_0 >> (u32(11)))) & (u32(2047))));
    var _S230 : u32 = (variable_0 & (u32(2147483647)));
    var _S231 : vec2<u32> = noiseOffset(_S230);
    var _S232 : vec2<u32> = _S229 + _S231;
    var _S233 : vec2<u32> = noiseOffset(u32(4096) + _S228);
    var _S234 : vec2<u32> = _S232 + _S233;
    var _S235 : u32 = (fkBlueNoiseSize());
    var _S236 : vec2<u32> = (_S234 & (vec2<u32>((_S235 - u32(1)))));
    var _S237 : u32 = (fkBlueNoise((_S236.x), (_S236.y), ((_S227 + (((_S228 * u32(2654435769)) >> (u32(27))))) % u32(32))));
    var _S238 : bool = ((variable_0 & (u32(2147483648)))) != u32(0);
    var _S239 : u32 = stream(address_0, _S230);
    var _S240 : Random = pcg(_S239);
    var _S241 : f32;
    if(_S237 == u32(4294967295))
    {
        if(_S238)
        {
            var _S242 : Random = pcg(_S240.state);
            _S241 = _S242.value;
        }
        else
        {
            _S241 = _S240.value;
        }
    }
    else
    {
        var _S243 : u32;
        if(_S238)
        {
            _S243 = (_S237 >> (u32(16)));
        }
        else
        {
            _S243 = (_S237 & (u32(65535)));
        }
        _S241 = (f32(_S243) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S241);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S244 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S245 : vec2<u32> = _S244 - vec2<u32>(u32(1), u32(0));
    var _S246 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S247 : vec2<u32> = min(vec2<u32>(_S246 * vec2<f32>(_S245)), _S245 - vec2<u32>(u32(1)));
    var _S248 : vec4<f32> = (textureLoad(environment_cdf, (_S247), 0));
    var _S249 : f32 = _S248.y;
    var _S250 : u32 = _S245.x;
    var _S251 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S250, _S247.y)), 0));
    var _S252 : f32 = _S249 * _S251.y;
    return _S252 * f32(_S250 * _S245.y) / (19.73921012878417969f * length(dir_3.xz));
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_0 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S253 : AnisotropicFrame;
    _S253.tangent = tangent_0;
    _S253.alphas = alphas_0;
    return _S253;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S254 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S254)
    {
        const _S255 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S255;
    }
    else
    {
        a_2 = a_1;
    }
    var _S256 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S257 : vec3<f32> = cross(n_1, _S256);
    return vec3<f32>(v_0.x) * _S256 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S257;
}

fn anisotropicFrame( material_0 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S258 : f32 = material_0.roughness;
    var _S259 : f32 = _S258 * _S258;
    var _S260 : bool = (material_0.anisotropy) == 0.0f;
    var _S261 : bool;
    if(_S260)
    {
        _S261 = true;
    }
    else
    {
        _S261 = !(_S259 > 0.0f);
    }
    if(_S261)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S262 : vec3<f32> = material_0.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_0.tangent));
    var _S263 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S264 : bool = (dot(_S262, _S262)) > 0.0f;
    var _S265 : vec3<f32> = select(_S263, _S262, _S264);
    var _S266 : vec3<f32> = (normalize((_S265)));
    var _S267 : f32 = 6.28318548202514648f * material_0.anisotropic_rotation;
    var _S268 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_0.anisotropy));
    var _S269 : f32 = 1.0f / _S268;
    var _S270 : bool = (material_0.anisotropy) < 0.0f;
    var _S271 : f32 = select(_S268, _S269, _S270);
    return AnisotropicFrame_x24init_0(_S266 * vec3<f32>(cos(_S267)) + cross(n_i_0, _S266) * vec3<f32>(sin(_S267)), vec2<f32>(_S259 / _S271, _S259 * _S271));
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn coatNormal( material_1 : Material,  n_2 : vec3<f32>) -> vec3<f32>
{
    var _S272 : vec3<f32> = material_1.coat_normal;
    var _S273 : bool = (dot(_S272, _S272)) > 0.0f;
    var _S274 : vec3<f32> = (normalize((material_1.coat_normal)));
    var _S275 : vec3<f32> = select(n_2, _S274, _S273);
    var _S276 : f32 = (sign((dot(_S275, n_2))));
    return _S275 * vec3<f32>(_S276);
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_3, t_12)), dot(w_1, n_3));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S277 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S278 : f32 = _S277.x;
    var _S279 : f32 = _S277.y;
    var _S280 : f32 = _S278 * _S278 + _S279 * _S279;
    const _S281 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S282 : vec3<f32> = vec3<f32>(- _S279, _S278, 0.0f);
    var _S283 : f32 = (inverseSqrt((_S280)));
    var _S284 : vec3<f32> = _S282 * vec3<f32>(_S283);
    var _S285 : bool = _S280 > 0.0f;
    var _S286 : vec3<f32> = select(_S281, _S284, _S285);
    var _S287 : vec3<f32> = cross(_S277, _S286);
    var _S288 : f32 = sqrt(U1_0);
    var _S289 : f32 = 6.28318548202514648f * U2_0;
    var _S290 : f32 = _S288 * cos(_S289);
    var t2_0 : f32 = _S288 * sin(_S289);
    var _S291 : f32 = 0.5f * (1.0f + _S277.z);
    var t2_1 : f32 = (1.0f - _S291) * sqrt(max(0.0f, 1.0f - _S290 * _S290)) + _S291 * t2_0;
    var _S292 : vec3<f32> = vec3<f32>(_S290) * _S286 + vec3<f32>(t2_1) * _S287;
    var _S293 : f32 = ((_S290));
    var _S294 : f32 = ((_S290));
    var _S295 : vec3<f32> = _S292 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S293 * _S294 - t2_1 * t2_1))) * _S277;
    var _S296 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S295.x, alpha_0 * _S295.y, max(0.0f, _S295.z)))));
    return _S296;
}

fn worldToTangent( v_1 : vec3<f32>,  n_4 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S297 : bool = (abs(dot(n_4, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S297)
    {
        const _S298 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S298;
    }
    else
    {
        a_4 = a_3;
    }
    var _S299 : vec3<f32> = (normalize((cross(n_4, a_4))));
    var _S300 : vec3<f32> = cross(n_4, _S299);
    return vec3<f32>(dot(v_1, _S299), dot(v_1, n_4), dot(v_1, _S300));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>,  first_1 : u32) -> vec3<f32>
{
    var _S301 : Random = draw((*random_state_0), first_1);
    var _S302 : Random = draw((*random_state_0), (first_1 | (u32(2147483648))));
    (*random_state_0) = _S302.state;
    var _S303 : f32 = frame_0.alphas.x;
    var _S304 : bool = _S303 > 0.0f;
    if(_S304)
    {
        var _S305 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S306 : f32 = frame_0.alphas.y;
        var _S307 : vec3<f32> = (normalize((vec3<f32>(_S303 * _S305.x, _S306 * _S305.y, _S305.z))));
        var _S308 : vec3<f32> = sampleGGXVNDF(_S307, 1.0f, _S301.value, _S302.value);
        var _S309 : vec3<f32> = (normalize((vec3<f32>(_S303 * _S308.x, _S306 * _S308.y, _S308.z))));
        return vec3<f32>(_S309.x) * frame_0.tangent + vec3<f32>(_S309.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S309.z) * n_i_1;
    }
    var _S310 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S311 : vec3<f32> = sampleGGXVNDF(_S310.xzy, alpha_1, _S301.value, _S302.value);
    var _S312 : vec3<f32> = _S311.xzy;
    var _S313 : vec3<f32> = tangentToWorld(_S312, n_i_1);
    return _S313;
}

fn coatHalf( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  material_2 : Material,  random_state_1 : u32) -> vec3<f32>
{
    var _S314 : vec3<f32> = coatNormal(material_2, n_i_2);
    var _S315 : bool = (material_2.coat) > 0.0f;
    var _S316 : bool;
    if(_S315)
    {
        _S316 = (dot(_S314, v_3)) > 0.0f;
    }
    else
    {
        _S316 = false;
    }
    var _S317 : bool = !_S316;
    if(_S317)
    {
        return vec3<f32>(0.0f);
    }
    var state_2 : u32 = random_state_1;
    var _S318 : f32 = material_2.coat_roughness;
    var _S319 : vec3<f32> = sampleHalfVector(v_3, _S314, _S318 * _S318, AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f)), &(state_2), u32(1));
    return _S319;
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
     coat : vec3<f32>,
     p_coat : f32,
     coat_pdf : f32,
};

fn Weights_x24init_0( v_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  p_sheen_velvet_0 : f32,  p_toon_0 : f32,  sheen_0 : vec3<f32>,  coat_0 : vec3<f32>,  p_coat_0 : f32,  coat_pdf_0 : f32) -> Weights
{
    var _S320 : Weights;
    _S320.v_dot_h = v_dot_h_0;
    _S320.refracted = refracted_1;
    _S320.F = F_0;
    _S320.reflect_weight = reflect_weight_0;
    _S320.diffuse_weight = diffuse_weight_0;
    _S320.refract_weight = refract_weight_0;
    _S320.p_diffuse = p_diffuse_0;
    _S320.p_reflect = p_reflect_0;
    _S320.p_refract = p_refract_0;
    _S320.p_sheen_velvet = p_sheen_velvet_0;
    _S320.p_toon = p_toon_0;
    _S320.sheen = sheen_0;
    _S320.coat = coat_0;
    _S320.p_coat = p_coat_0;
    _S320.coat_pdf = coat_pdf_0;
    return _S320;
}

fn sampledHalf( v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_2 : f32,  frame_1 : AnisotropicFrame,  random_state_2 : u32) -> vec3<f32>
{
    var state_3 : u32 = random_state_2;
    var _S321 : vec3<f32> = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &(state_3), u32(0));
    return _S321;
}

fn refractedHalf( in_dir_0 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  eta_i_0 : f32,  eta_o_0 : f32) -> vec3<f32>
{
    var _S322 : vec3<f32> = ((-(in_dir_0)));
    var _S323 : vec3<f32> = ((-(vec3<f32>(eta_i_0) * _S322 + vec3<f32>(eta_o_0) * out_dir_0)));
    var _S324 : vec3<f32> = (normalize((_S323)));
    var _S325 : f32 = (sign((dot(n_5, _S322))));
    var _S326 : f32 = (sign((dot(_S323, n_5 * vec3<f32>(_S325)))));
    return _S324 * vec3<f32>(_S326);
}

fn reflectedHalf( in_dir_1 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S327 : vec3<f32> = ((-(in_dir_1)));
    var _S328 : vec3<f32> = (normalize((_S327 + out_dir_1)));
    return _S328;
}

fn fresnel( cos_theta_0 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> f32
{
    var _S329 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S330 : f32 = eta_i_1 / eta_o_1 * _S329;
    var _S331 : bool = _S330 < 1.0f;
    var kr_0 : f32;
    if(_S331)
    {
        var _S332 : f32 = sqrt(max(0.0f, 1.0f - _S330 * _S330));
        var _S333 : f32 = eta_o_1 * cos_theta_0;
        var _S334 : f32 = eta_i_1 * _S332;
        var _S335 : f32 = (_S333 - _S334) / (_S333 + _S334);
        var _S336 : f32 = eta_i_1 * cos_theta_0;
        var _S337 : f32 = eta_o_1 * _S332;
        var _S338 : f32 = (_S336 - _S337) / (_S336 + _S337);
        var _S339 : f32 = (_S335 * _S335 + _S338 * _S338) / 2.0f;
        kr_0 = _S339;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
fn smithG1( alpha_3 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S340 : f32 = alpha_3 * alpha_3;
    var _S341 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S340 + (1.0f - _S340) * n_dot_x_0 * n_dot_x_0));
    var _S342 : bool = alpha_3 > 0.0f;
    var _S343 : f32 = select(1.0f, _S341, _S342);
    return _S343;
}

fn trowbridgeReitz( alpha_4 : f32,  n_dot_h_0 : f32) -> f32
{
    var _S344 : f32 = alpha_4 * alpha_4;
    var _S345 : f32 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S344 * n_dot_h_0 * n_dot_h_0;
    return _S344 / max(3.14159274101257324f * _S345 * _S345, 1.17549435082228751e-38f);
}

fn lobeWeights( in_dir_2 : vec3<f32>,  v_5 : vec3<f32>,  n_i_4 : vec3<f32>,  ggx_n_0 : vec3<f32>,  coat_h_0 : vec3<f32>,  frame_2 : AnisotropicFrame,  material_3 : Material,  eta_i_2 : f32,  eta_o_2 : f32) -> Weights
{
    var _S346 : f32 = dot(ggx_n_0, v_5);
    var _S347 : f32 = eta_i_2 / eta_o_2;
    var _S348 : vec3<f32> = (normalize((refract(in_dir_2, ggx_n_0, _S347))));
    var _S349 : f32 = min(sqrt(material_3.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S350 : f32 = _S349 * _S349;
    var _S351 : f32 = (1.0f + _S349) / (1.0f - _S349);
    var _S352 : f32 = abs(_S346);
    var _S353 : bool = eta_i_2 > eta_o_2;
    var sheen_component_0 : f32;
    if(_S353)
    {
        sheen_component_0 = _S351;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var coat_pdf_1 : f32;
    if(_S353)
    {
        coat_pdf_1 = 1.0f;
    }
    else
    {
        coat_pdf_1 = _S351;
    }
    var _S354 : f32 = fresnel(_S352, sheen_component_0, coat_pdf_1);
    var _S355 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S346 * _S346)) >= (eta_o_2 * eta_o_2);
    var _S356 : vec3<f32>;
    if(_S355)
    {
        _S356 = vec3<f32>(1.0f);
    }
    else
    {
        var _S357 : vec3<f32> = material_3.specular_tint * vec3<f32>(_S350);
        _S356 = _S357 + (vec3<f32>(1.0f) - _S357) * vec3<f32>((_S354 - _S350)) / vec3<f32>((1.0f - _S350));
    }
    var _S358 : vec3<f32> = vec3<f32>(1.0f);
    var _S359 : vec3<f32> = vec3<f32>(0.0f);
    var _S360 : f32 = rgb_to_greyscale(material_3.sheen);
    var _S361 : bool = _S360 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    if(_S361)
    {
        var _S362 : f32 = clamp(sqrt(max(dot(n_i_4, v_5), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S363 : u32 = min(u32(_S362), u32(22));
        var least_0 : f32 = sqrt(0.05000000074505806f);
        var _S364 : f32 = sqrt(0.10000000149011612f);
        var _S365 : bool = (material_3.velvet) > 0.0f;
        var _S366 : f32 = select(least_0, _S364, _S365);
        var _S367 : f32 = (clamp(sqrt(max(material_3.sheen_roughness, 0.0f)), _S366, 1.0f) - _S366) / (1.0f - _S366) * 23.0f;
        var _S368 : u32 = min(u32(_S367), u32(22));
        var _S369 : u32 = _S363 * u32(24) + _S368;
        var _S370 : f32 = _S362 - f32(_S363);
        var _S371 : f32 = _S367 - f32(_S368);
        var _S372 : u32 = _S369 + u32(24);
        var a_5 : f32 = SHEEN_ALBEDO_0[_S369] + (SHEEN_ALBEDO_0[_S372] - SHEEN_ALBEDO_0[_S369]) * _S370;
        var _S373 : u32 = _S369 + u32(1);
        var _S374 : u32 = _S372 + u32(1);
        var b_1 : f32 = SHEEN_ALBEDO_0[_S373] + (SHEEN_ALBEDO_0[_S374] - SHEEN_ALBEDO_0[_S373]) * _S370;
        var _S375 : f32 = exp(a_5 + (b_1 - a_5) * _S371);
        if(_S365)
        {
            var a_6 : f32 = VELVET_ALBEDO_0[_S369] + (VELVET_ALBEDO_0[_S372] - VELVET_ALBEDO_0[_S369]) * _S370;
            var b_2 : f32 = VELVET_ALBEDO_0[_S373] + (VELVET_ALBEDO_0[_S374] - VELVET_ALBEDO_0[_S373]) * _S370;
            var _S376 : f32 = a_6 + (b_2 - a_6) * _S371;
            sheen_component_0 = _S376;
        }
        else
        {
            sheen_component_0 = _S375;
        }
        var _S377 : f32 = min(sheen_component_0, 1.0f);
        var _S378 : vec3<f32> = vec3<f32>(1.0f) - material_3.sheen * vec3<f32>(_S377);
        var _S379 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S380 : f32 = _S379 * _S377;
        var _S381 : vec3<f32> = material_3.sheen / vec3<f32>(max(sheen_component_0, 1.0f));
        scale_0 = _S378;
        sheen_component_0 = _S380;
        sheen_1 = _S381;
    }
    else
    {
        scale_0 = _S358;
        sheen_component_0 = 0.0f;
        sheen_1 = _S359;
    }
    var _S382 : bool = (material_3.metallic) > 0.0f;
    var rebounce_0 : vec3<f32>;
    if(_S382)
    {
        var _S383 : f32 = frame_2.alphas.x;
        var _S384 : f32 = sqrt(min(_S383, frame_2.alphas.y));
        var _S385 : bool = _S383 > 0.0f;
        var _S386 : f32 = select(material_3.roughness, _S384, _S385);
        var _S387 : f32 = _S386 * _S386;
        var _S388 : f32 = pow(_S387, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S387) / (1.0f + 1.28094995021820068f * _S387);
        var _S389 : bool = _S387 > 0.0f;
        var _S390 : f32 = select(0.0f, _S388, _S389);
        var _S391 : f32 = clamp(dot(n_i_4, v_5), 0.0f, 1.0f);
        var _S392 : f32 = _S387 * _S386;
        var _S393 : f32 = min(1.00064504146575928f - _S386 * (0.00375499995425344f + _S391 * (-0.04133399948477745f + _S391 * (-0.90938502550125122f + _S391 * 0.35275399684906006f))) - _S387 * (0.27602800726890564f + _S391 * (1.27023398876190186f + _S391 * 0.04740000143647194f)) - _S392 * (0.31452900171279907f - _S391 * 0.34830701351165771f) + _S392 * _S386 * 0.27229699492454529f, 1.0f);
        var _S394 : vec3<f32> = vec3<f32>(1.0f);
        var _S395 : vec3<f32> = min(_S394 / (_S394 - material_3.albedo * vec3<f32>(_S390)), vec3<f32>((1.0f / max(_S393, 0.0000152587890625f))));
        rebounce_0 = _S395;
    }
    else
    {
        rebounce_0 = _S358;
    }
    var _S396 : bool = (dot(coat_h_0, coat_h_0)) > 0.0f;
    var coat_1 : vec3<f32>;
    var up_0 : vec3<f32>;
    var through_0 : vec3<f32>;
    if(_S396)
    {
        var _S397 : vec3<f32> = coatNormal(material_3, n_i_4);
        var _S398 : f32 = material_3.coat_roughness;
        var _S399 : f32 = _S398 * _S398;
        var _S400 : f32 = max(material_3.coat_ior, 1.00999999046325684f);
        var _S401 : f32 = dot(_S397, reflect(in_dir_2, coat_h_0));
        var _S402 : f32 = abs(dot(v_5, coat_h_0));
        var _S403 : f32 = eta_i_2 / _S400 * sqrt(max(1.0f - _S402 * _S402, 0.0f));
        var _S404 : f32 = sqrt(max(1.0f - _S403 * _S403, 0.0f));
        var _S405 : f32 = select(_S402, _S404, _S353);
        var _S406 : f32 = select(1.0f, _S400, _S353);
        var _S407 : f32 = select(_S400, 1.0f, _S353);
        var _S408 : f32 = fresnel(_S405, _S406, _S407);
        var _S409 : f32 = smithG1(_S399, _S401);
        var _S410 : f32 = _S408 * _S409;
        var _S411 : bool = _S401 > 0.0f;
        var _S412 : f32 = select(0.0f, _S410, _S411);
        var _S413 : f32 = material_3.coat * _S412;
        var _S414 : vec3<f32> = material_3.coat_tint;
        var _S415 : vec3<f32> = _S414 * _S414;
        var _S416 : vec3<f32> = select(_S358, _S415, _S353);
        var _S417 : vec3<f32> = vec3<f32>(_S413) * _S416;
        var _S418 : f32 = dot(_S397, v_5);
        var _S419 : f32 = smithG1(_S399, _S418);
        var _S420 : f32 = trowbridgeReitz(_S399, dot(_S397, coat_h_0));
        var _S421 : f32 = _S419 * _S420 / (4.0f * _S418);
        var _S422 : bool = _S399 > 0.0f;
        var _S423 : f32 = select(0.0f, _S421, _S422);
        var _S424 : bool = !_S353;
        if(_S424)
        {
            var _S425 : f32 = _S400 * _S400;
            var _S426 : f32 = _S425 * _S425;
            var _S427 : f32 = _S400 - 1.0f;
            var _S428 : f32 = _S400 + 1.0f;
            var _S429 : f32 = _S425 - 1.0f;
            var _S430 : f32 = _S425 + 1.0f;
            var _S431 : f32 = _S426 - 1.0f;
            var _S432 : f32 = _S430 * _S431;
            var _S433 : f32 = 0.5f + _S427 * (3.0f * _S400 + 1.0f) / (6.0f * _S428 * _S428) + _S425 * _S429 * _S429 / (_S430 * _S430 * _S430) * log(_S427 / _S428) - 2.0f * _S425 * _S400 * (_S425 + 2.0f * _S400 - 1.0f) / _S432 + 8.0f * _S426 * (_S426 + 1.0f) / (_S432 * _S431) * log(_S400);
            var _S434 : f32 = 1.0f - (1.0f - _S433) / _S425;
            var _S435 : vec3<f32> = _S415 * vec3<f32>((1.0f - _S434)) / (vec3<f32>(1.0f) - material_3.albedo * vec3<f32>(_S434));
            coat_1 = _S435;
        }
        else
        {
            coat_1 = _S358;
        }
        var _S436 : vec3<f32> = vec3<f32>((1.0f - _S412));
        var _S437 : vec3<f32> = (mix((_S358), (_S436 * coat_1), (material_3.coat)));
        var _S438 : vec3<f32> = (mix((_S358), (_S436 * material_3.coat_tint), (material_3.coat)));
        coat_1 = _S417;
        up_0 = _S437;
        through_0 = _S438;
        coat_pdf_1 = _S423;
    }
    else
    {
        coat_1 = _S359;
        up_0 = _S358;
        through_0 = _S358;
        coat_pdf_1 = 0.0f;
    }
    var _S439 : vec3<f32> = scale_0 * coat_1;
    var _S440 : f32 = rgb_to_greyscale(_S439);
    var _S441 : vec3<f32> = (mix((_S356), (material_3.albedo * rebounce_0), (material_3.metallic)));
    var F_1 : vec3<f32> = _S441 * scale_0 * up_0;
    var _S442 : f32 = rgb_to_greyscale(F_1);
    var _S443 : f32 = 1.0f - material_3.metallic;
    var _S444 : vec3<f32> = vec3<f32>(1.0f) - _S356;
    var _S445 : vec3<f32> = vec3<f32>(((1.0f - material_3.transmission) * _S443)) * _S444 * scale_0 * up_0;
    var _S446 : vec3<f32> = vec3<f32>((material_3.transmission * _S443)) * _S444 * scale_0 * through_0;
    var _S447 : f32 = max(_S442, 0.0f);
    var _S448 : f32 = rgb_to_greyscale(_S445);
    var _S449 : f32 = max(_S448, 0.0f);
    var _S450 : f32 = rgb_to_greyscale(_S446);
    var _S451 : f32 = (sign((length(_S348))));
    var _S452 : f32 = max(_S450 * _S451, 0.0f);
    var _S453 : f32 = _S447 + _S449 + _S452 + _S440;
    var _S454 : f32 = min(sheen_component_0, 1.0f);
    var _S455 : bool = sheen_component_0 > 0.0f;
    var _S456 : bool;
    if(_S455)
    {
        _S456 = !(_S453 > 0.0f);
    }
    else
    {
        _S456 = false;
    }
    var _S457 : f32 = select(_S454, 1.0f, _S456);
    var _S458 : f32 = (1.0f - _S457) / max(_S453, 0.0000152587890625f);
    var _S459 : f32 = _S449 * _S458;
    var _S460 : f32 = _S447 * _S458;
    var _S461 : f32 = _S452 * _S458;
    return Weights_x24init_0(_S346, _S348, F_1, 1.0f, _S445, _S446, _S459, _S460, _S461, _S457, 0.0f * _S458, sheen_1, _S439, _S440 * _S458, coat_pdf_1);
}

fn translucentShare( material_4 : Material) -> f32
{
    var _S462 : f32 = rgb_to_greyscale(material_4.translucent);
    var _S463 : f32 = rgb_to_greyscale(material_4.albedo);
    var _S464 : f32 = _S462 / (_S463 + _S462);
    var _S465 : bool = _S462 > 0.0f;
    var _S466 : f32 = select(0.0f, _S464, _S465);
    return _S466;
}

fn diffusePDF( n_i_dot_l_0 : f32,  n_i_dot_v_0 : f32,  material_5 : Material,  w_2 : Weights) -> f32
{
    var _S467 : f32 = translucentShare(material_5);
    var _S468 : f32 = w_2.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S469 : f32 = w_2.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S470 : f32 = 1.0f - _S467;
    var _S471 : bool = n_i_dot_l_0 < 0.0f;
    var _S472 : f32 = select(_S470, _S467, _S471);
    var _S473 : f32 = _S469 * _S472;
    var _S474 : bool = _S467 > 0.0f;
    var _S475 : f32 = select(_S468, _S473, _S474);
    var _S476 : bool = n_i_dot_v_0 > 0.0f;
    var _S477 : f32 = select(0.0f, _S475, _S476);
    return _S477;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_5 : vec3<f32>,  material_6 : Material,  w_3 : Weights) -> vec3<f32>
{
    var _S478 : f32 = translucentShare(material_6);
    var _S479 : bool = (dot(n_i_5, l_0)) < 0.0f;
    var _S480 : vec3<f32> = select(material_6.albedo, material_6.translucent, _S479);
    var _S481 : f32 = 1.0f - _S478;
    var _S482 : f32 = select(_S481, _S478, _S479);
    var _S483 : vec3<f32> = _S480 / vec3<f32>(_S482);
    var _S484 : bool = _S478 > 0.0f;
    var _S485 : vec3<f32> = select(material_6.albedo, _S483, _S484);
    return w_3.diffuse_weight * _S485 / vec3<f32>(w_3.p_diffuse);
}

fn anisotropicG1( w_4 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S486 : f32 = max(w_4.z, 0.0f);
    return 2.0f * _S486 / (_S486 + length(vec3<f32>(alphas_1.x * w_4.x, alphas_1.y * w_4.y, _S486)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S487 : f32 = alphas_2.x;
    var _S488 : f32 = h_0.x / _S487;
    var _S489 : f32 = alphas_2.y;
    var _S490 : f32 = h_0.y / _S489;
    var _S491 : f32 = h_0.z;
    var _S492 : f32 = _S488 * _S488 + _S490 * _S490 + _S491 * _S491;
    return 1.0f / max(3.14159274101257324f * _S487 * _S489 * _S492 * _S492, 1.17549435082228751e-38f);
}

fn vndfPDF( v_6 : vec3<f32>,  h_1 : vec3<f32>,  n_i_6 : vec3<f32>,  n_i_dot_v_1 : f32,  alpha_5 : f32,  frame_3 : AnisotropicFrame,  v_dot_h_1 : f32) -> f32
{
    var _S493 : f32 = dot(n_i_6, h_1);
    var _S494 : f32 = smithG1(alpha_5, n_i_dot_v_1);
    var _S495 : f32 = _S494 * v_dot_h_1;
    var _S496 : f32 = trowbridgeReitz(alpha_5, _S493);
    var _S497 : f32 = _S495 * _S496 / n_i_dot_v_1;
    var _S498 : bool = alpha_5 > 0.0f;
    var _S499 : bool;
    if(_S498)
    {
        _S499 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S499 = false;
    }
    if(_S499)
    {
        _S499 = _S493 > 0.0f;
    }
    else
    {
        _S499 = false;
    }
    if(_S499)
    {
        _S499 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S499 = false;
    }
    var _S500 : f32 = select(0.0f, _S497, _S499);
    var _S501 : bool = (frame_3.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S501)
    {
        var _S502 : vec3<f32> = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        var _S503 : f32 = anisotropicG1(_S502, frame_3.alphas);
        var _S504 : vec3<f32> = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        var _S505 : f32 = anisotropicD(_S504, frame_3.alphas);
        var _S506 : f32 = _S503 * _S505;
        var _S507 : f32 = _S506 * v_dot_h_1 / n_i_dot_v_1;
        var _S508 : bool = v_dot_h_1 > 0.0f;
        if(_S508)
        {
            _S499 = _S493 > 0.0f;
        }
        else
        {
            _S499 = false;
        }
        if(_S499)
        {
            _S499 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S499 = false;
        }
        var _S509 : f32 = select(0.0f, _S507, _S499);
        pdf_h_0 = _S509;
    }
    else
    {
        pdf_h_0 = _S500;
    }
    return pdf_h_0;
}

fn refractPDF( l_dot_h_0 : f32,  pdf_h_1 : f32,  w_5 : Weights,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S510 : f32 = eta_i_3 * w_5.v_dot_h + eta_o_3 * l_dot_h_0;
    var _S511 : f32 = w_5.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * abs(l_dot_h_0) / (_S510 * _S510);
    var _S512 : bool = eta_i_3 != eta_o_3;
    var _S513 : bool;
    if(_S512)
    {
        _S513 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S513 = false;
    }
    var _S514 : f32 = select(0.0f, _S511, _S513);
    return _S514;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_6 : f32,  frame_4 : AnisotropicFrame,  material_7 : Material,  w_6 : Weights) -> vec3<f32>
{
    var _S515 : f32 = - dot(n_i_7, l_1);
    var _S516 : f32 = smithG1(alpha_6, max(_S515, 0.0f));
    var _S517 : bool = (frame_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S517)
    {
        var _S518 : vec3<f32> = ((-(n_i_7)));
        var _S519 : vec3<f32> = anisotropicLocal(l_1, frame_4.tangent, _S518);
        var _S520 : f32 = anisotropicG1(_S519, frame_4.alphas);
        G1_l_0 = _S520;
    }
    else
    {
        G1_l_0 = _S516;
    }
    return w_6.refract_weight * vec3<f32>(G1_l_0) * material_7.albedo / vec3<f32>(w_6.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_1 : f32,  n_i_dot_v_2 : f32,  w_7 : Weights) -> f32
{
    var _S521 : f32 = w_7.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S522 : bool = n_i_dot_l_1 > 0.0f;
    var _S523 : bool;
    if(_S522)
    {
        _S523 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    var _S524 : f32 = select(0.0f, _S521, _S523);
    return _S524;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  v_7 : vec3<f32>,  n_i_8 : vec3<f32>,  material_8 : Material,  w_8 : Weights) -> vec3<f32>
{
    var _S525 : vec3<f32> = (normalize((l_2 + v_7)));
    var _S526 : f32 = dot(n_i_8, _S525);
    var _S527 : f32 = max(dot(n_i_8, l_2), 0.0f);
    var _S528 : f32 = max(dot(n_i_8, v_7), 0.0f);
    var _S529 : f32 = 1.0f / max(material_8.sheen_roughness, 0.05000000074505806f);
    var _S530 : f32 = 1.0f - _S526 * _S526;
    var _S531 : f32 = (2.0f + _S529) * pow(max(_S530, 0.0f), 0.5f * _S529) * 0.5f * 0.31830987334251404f / max(4.0f * (_S527 + _S528 - _S527 * _S528), 0.0000152587890625f);
    var _S532 : bool = (material_8.velvet) > 0.0f;
    var f_1 : f32;
    if(_S532)
    {
        var _S533 : f32 = max(material_8.sheen_roughness, 0.00999999977648258f);
        var _S534 : f32 = _S533 * _S533;
        var _S535 : f32 = max(_S530, 0.0000152587890625f);
        var _S536 : f32 = exp(- _S526 * _S526 / (_S535 * _S534)) / (3.14159274101257324f * _S534 * _S535 * _S535) * min(1.0f, 2.0f * _S526 * min(_S527, _S528) / max(abs(dot(_S525, v_7)), 0.0000152587890625f)) / max(4.0f * _S527 * _S528, 0.0000152587890625f);
        f_1 = _S536;
    }
    else
    {
        f_1 = _S531;
    }
    return w_8.sheen * vec3<f32>((f_1 * _S527 * 2.0f * 3.14159274101257324f / w_8.p_sheen_velvet));
}

fn coatPDF( w_9 : Weights) -> f32
{
    return w_9.p_coat * w_9.coat_pdf;
}

fn coatBSDF( w_10 : Weights) -> vec3<f32>
{
    return w_10.coat / vec3<f32>(w_10.p_coat);
}

fn reflectPDF( pdf_h_2 : f32,  w_11 : Weights) -> f32
{
    var _S537 : f32 = w_11.p_reflect * pdf_h_2 / (4.0f * w_11.v_dot_h);
    var _S538 : bool = pdf_h_2 > 0.0f;
    var _S539 : f32 = select(0.0f, _S537, _S538);
    return _S539;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_9 : vec3<f32>,  alpha_7 : f32,  frame_5 : AnisotropicFrame,  w_12 : Weights) -> vec3<f32>
{
    var _S540 : f32 = dot(n_i_9, l_3);
    var _S541 : f32 = smithG1(alpha_7, max(_S540, 0.0f));
    var _S542 : bool = (frame_5.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S542)
    {
        var _S543 : vec3<f32> = anisotropicLocal(l_3, frame_5.tangent, n_i_9);
        var _S544 : f32 = anisotropicG1(_S543, frame_5.alphas);
        G1_l_1 = _S544;
    }
    else
    {
        G1_l_1 = _S541;
    }
    return vec3<f32>((w_12.reflect_weight * G1_l_1)) * w_12.F / vec3<f32>(w_12.p_reflect);
}

fn BSDF( in_dir_3 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_2 : bool,  random_state_3 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(6)>>,  pdfs_0 : ptr<function, array<f32, i32(6)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S545 : vec3<f32> = ((-(in_dir_3)));
    var _S546 : f32 = dot(n_6, _S545);
    var _S547 : f32 = (sign((_S546)));
    var _S548 : vec3<f32> = n_6 * vec3<f32>(_S547);
    var _S549 : f32 = dot(_S548, out_dir_2);
    var _S550 : f32 = material_9.roughness;
    var _S551 : f32 = _S550 * _S550;
    var _S552 : AnisotropicFrame = anisotropicFrame(material_9, _S548);
    var _S553 : f32 = rgb_to_greyscale(material_9.translucent);
    var _S554 : bool = _S553 > 0.0f;
    var _S555 : bool = (dot(n_6, out_dir_2) * _S546) < 0.0f;
    var _S556 : bool = (material_9.coat) > 0.0f;
    var _S557 : u32;
    if(_S556)
    {
        _S557 = u32(6);
    }
    else
    {
        _S557 = u32(4);
    }
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
        var _S558 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S558;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S559 : vec3<f32> = coatHalf(_S545, _S548, material_9, random_state_3);
    var _S560 : vec3<f32> = vec3<f32>(0.0f);
    var _S561 : Weights = Weights_x24init_0(0.0f, _S560, _S560, 0.0f, _S560, _S560, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S560, _S560, 0.0f, 0.0f);
    var half_of_0 : u32 = u32(4294967295);
    var w_13 : Weights = _S561;
    var ggx_n_2 : vec3<f32> = _S560;
    i_0 = u32(0);
    loop
    {
        if(i_0 < _S557)
        {
        }
        else
        {
            break;
        }
        var _S562 : u32;
        if(i_0 == u32(3))
        {
            _S562 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S562 = u32(6);
            }
            else
            {
                if(i_0 == u32(5))
                {
                    _S562 = u32(5);
                }
                else
                {
                    _S562 = i_0;
                }
            }
        }
        var _S563 : bool = _S562 == u32(0);
        var _S564 : bool;
        if(_S563)
        {
            _S564 = _S554;
        }
        else
        {
            _S564 = false;
        }
        var _S565 : bool;
        if(_S564)
        {
            _S565 = _S555;
        }
        else
        {
            _S565 = _S562 == u32(1);
        }
        var _S566 : bool = _S565 != refracted_2;
        var _S567 : bool;
        if(_S566)
        {
            _S567 = true;
        }
        else
        {
            var _S568 : bool = _S562 == u32(6);
            _S567 = _S568;
        }
        if(_S567)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S569 : u32;
        if(_S562 == u32(6))
        {
            _S569 = u32(0);
        }
        else
        {
            if(_S562 == u32(4))
            {
                _S569 = u32(2);
            }
            else
            {
                _S569 = _S562;
            }
        }
        var _S570 : bool = _S569 != half_of_0;
        var half_of_1 : u32;
        var w_14 : Weights;
        if(_S570)
        {
            var _S571 : bool = _S569 == u32(0);
            var _S572 : bool;
            if(_S571)
            {
                _S572 = true;
            }
            else
            {
                _S572 = _S569 == u32(5);
            }
            if(_S572)
            {
                var _S573 : vec3<f32> = sampledHalf(_S545, _S548, _S551, _S552, random_state_3);
                ggx_n_1 = _S573;
            }
            else
            {
                var _S574 : bool = _S569 == u32(1);
                if(_S574)
                {
                    var _S575 : vec3<f32> = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S575;
                }
                else
                {
                    var _S576 : vec3<f32> = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S576;
                }
            }
            var _S577 : vec3<f32> = reflectedHalf(in_dir_3, out_dir_2);
            var _S578 : bool = _S562 == u32(5);
            var _S579 : vec3<f32> = select(_S559, _S577, _S578);
            var _S580 : Weights = lobeWeights(in_dir_3, _S545, _S548, ggx_n_1, _S579, _S552, material_9, eta_i_4, eta_o_4);
            w_14 = _S580;
            half_of_1 = _S569;
        }
        else
        {
            w_14 = w_13;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S562)
        {
        case u32(0):
            {
                var _S581 : f32 = diffusePDF(_S549, abs(_S546), material_9, w_14);
                (*pdfs_0)[i32(0)] = _S581;
                var _S582 : vec3<f32> = diffuseBSDF(out_dir_2, _S548, material_9, w_14);
                (*throughputs_0)[i32(0)] = _S582;
            }
        case u32(1):
            {
                var _S583 : f32 = dot(out_dir_2, ggx_n_1);
                var _S584 : f32 = vndfPDF(_S545, ggx_n_1, _S548, abs(_S546), _S551, _S552, w_14.v_dot_h);
                var _S585 : f32 = refractPDF(_S583, _S584, w_14, eta_i_4, eta_o_4);
                (*pdfs_0)[i32(1)] = _S585;
                var _S586 : vec3<f32> = refractBSDF(out_dir_2, _S548, _S551, _S552, material_9, w_14);
                (*throughputs_0)[i32(1)] = _S586;
            }
        case u32(4):
            {
                var _S587 : f32 = sheenVelvetPDF(_S549, abs(_S546), w_14);
                (*pdfs_0)[i32(3)] = _S587;
                var _S588 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S545, _S548, material_9, w_14);
                (*throughputs_0)[i32(3)] = _S588;
            }
        case u32(5):
            {
                var _S589 : f32 = coatPDF(w_14);
                (*pdfs_0)[i32(5)] = _S589;
                var _S590 : vec3<f32> = coatBSDF(w_14);
                (*throughputs_0)[i32(5)] = _S590;
            }
        default :
            {
                var _S591 : f32 = vndfPDF(_S545, ggx_n_1, _S548, abs(_S546), _S551, _S552, w_14.v_dot_h);
                var _S592 : f32 = reflectPDF(_S591, w_14);
                (*pdfs_0)[i32(2)] = _S592;
                var _S593 : vec3<f32> = reflectBSDF(out_dir_2, _S548, _S551, _S552, w_14);
                (*throughputs_0)[i32(2)] = _S593;
            }
        }
        half_of_0 = half_of_1;
        w_13 = w_14;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S560;
    loop
    {
        if(i_0 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S594 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S594)
        {
            var f_2 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_2;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
}

fn skyLobes_0( in_dir_4 : vec3<f32>,  dir_4 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_0 : f32,  random_state_4 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(6)>>,  pdfs_1 : ptr<function, array<f32, i32(6)>>) -> vec3<f32>
{
    var _S595 : bool = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    var _S596 : vec3<f32> = BSDF(in_dir_4, dir_4, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S595, random_state_4, &((*terms_0)), &((*pdfs_1)));
    var _S597 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var f_3 : vec3<f32> = _S597;
    loop
    {
        if(i_4 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S598 : bool = ((*pdfs_1)[i_4]) > 0.0f;
        if(_S598)
        {
            var _S599 : vec3<f32> = (*terms_0)[i_4] * vec3<f32>((*pdfs_1)[i_4]) / vec3<f32>(((*pdfs_1)[i_4] + pdf_0));
            (*terms_0)[i_4] = _S599;
            var f_4 : vec3<f32> = f_3 + (*terms_0)[i_4];
            f_3 = f_4;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return f_3;
}

fn skyBSDF( in_dir_5 : vec3<f32>,  dir_5 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  pdf_1 : f32,  random_state_5 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(6)>;
    var pdfs_2 : array<f32, i32(6)>;
    var _S600 : vec3<f32> = skyLobes_0(in_dir_5, dir_5, surface_2, eta_1, is_inside_3, pdf_1, random_state_5, &(terms_1), &(pdfs_2));
    return _S600;
}

fn SkySample_x24init_0( dir_6 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_6 : u32) -> SkySample
{
    var _S601 : SkySample;
    _S601.dir = dir_6;
    _S601.radiance = radiance_1;
    _S601.color = color_0;
    _S601.random_state = random_state_6;
    return _S601;
}

fn sampleSky_0( ray_0 : Ray,  surface_3 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S602 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S603 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S604 : vec2<u32> = _S602 - _S603;
    var _S605 : Random = draw(init_random_state_0, u32(6));
    var _S606 : Random = draw(init_random_state_0, u32(2147483654));
    var _S607 : Random = draw(init_random_state_0, u32(7));
    var _S608 : Random = draw(init_random_state_0, u32(2147483655));
    var _S609 : u32 = _S604.x;
    var _S610 : u32 = searchCDF_0(vec2<u32>(_S609, u32(0)), vec2<u32>(u32(0), u32(1)), _S604.y, _S605.value);
    var _S611 : u32 = searchCDF_0(vec2<u32>(u32(0), _S610), _S603, _S609, _S606.value);
    var _S612 : vec2<f32> = (vec2<f32>(f32(_S611), f32(_S610)) + vec2<f32>(_S607.value, _S608.value)) / vec2<f32>(_S604) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S613 : f32 = _S612.y;
    var _S614 : f32 = sin(_S613);
    var _S615 : f32 = _S612.x;
    var _S616 : vec3<f32> = vec3<f32>(_S614 * cos(_S615), cos(_S613), _S614 * sin(_S615));
    var _S617 : f32 = environmentPdf_0(_S616);
    var _S618 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S616, surface_3, eta_2, is_inside_4, _S617, lobe_state_0);
    var _S619 : bool = !(_S617 > 0.0f);
    var _S620 : bool;
    if(_S619)
    {
        _S620 = true;
    }
    else
    {
        _S620 = (all((_S618 == vec3<f32>(0.0f))));
    }
    if(_S620)
    {
        var _S621 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S616, _S621, _S621, _S608.state);
    }
    var _S622 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_3, is_inside_4, _S616);
    return SkySample_x24init_0(_S616, _S622, _S618 * _S622, _S608.state);
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  density_0 : f32,  random_state_7 : u32) -> TreeSample
{
    var _S623 : TreeSample;
    _S623.dir = dir_7;
    _S623.radiance = radiance_2;
    _S623.density = density_0;
    _S623.random_state = random_state_7;
    return _S623;
}

fn pickChild( first_2 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S624 : f32 = importance(first_2, p_10, normal_3);
    var _S625 : f32 = importance(second_1, p_10, normal_3);
    var _S626 : vec2<f32> = vec2<f32>(_S624, _S625);
    var _S627 : bool = _S624 == 0.0f;
    var _S628 : bool;
    if(_S627)
    {
        _S628 = _S625 == 0.0f;
    }
    else
    {
        _S628 = false;
    }
    if(_S628)
    {
        return u32(2);
    }
    var _S629 : f32 = _S624 + _S625;
    var _S630 : bool = _S625 > 0.0f;
    if(_S630)
    {
        _S628 = ((*pick_0) * _S629) >= _S624;
    }
    else
    {
        _S628 = false;
    }
    var _S631 : u32 = select(u32(0), u32(1), _S628);
    var _S632 : f32 = min(((*pick_0) * _S629 - f32(_S631) * _S624) / _S626[_S631], 0.99999994039535522f);
    (*pick_0) = _S632;
    var _S633 : f32 = (*probability_3) * (_S626[_S631] / _S629);
    (*probability_3) = _S633;
    return _S631;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S634 : vec3<f32> = center_1 - p_11;
    var _S635 : f32 = radius_1 * radius_1 / dot(_S634, _S634);
    var _S636 : f32 = u1_0 * _S635 / (1.0f + sqrt(max(1.0f - _S635, 0.0f)));
    var _S637 : f32 = 2.0f * u1_0;
    var _S638 : bool = _S635 >= 1.0f;
    var _S639 : f32 = select(_S636, _S637, _S638);
    var _S640 : f32 = sqrt(max(_S639 * (2.0f - _S639), 0.0f));
    var _S641 : f32 = 6.28318548202514648f * u2_0;
    var _S642 : vec3<f32> = vec3<f32>(_S640 * cos(_S641), 1.0f - _S639, _S640 * sin(_S641));
    var _S643 : vec3<f32> = (normalize((_S634)));
    var _S644 : vec3<f32> = tangentToWorld(_S642, _S643);
    return _S644;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S645 : vec3<f32> = center_2 - ray_1.origin;
    var _S646 : f32 = dot(_S645, ray_1.unit_direction);
    var _S647 : f32 = dot(_S645, _S645) - _S646 * _S646;
    var _S648 : f32 = radius_3 * radius_3;
    var _S649 : bool = _S647 > _S648;
    if(_S649)
    {
        return 4.294967296e+09f;
    }
    var _S650 : f32 = sqrt(_S648 - _S647);
    var _S651 : f32 = _S646 - _S650;
    var _S652 : f32 = _S646 + _S650;
    var _S653 : bool = _S651 > 0.0000152587890625f;
    var _S654 : bool;
    if(_S653)
    {
        _S654 = _S651 < max_len_0;
    }
    else
    {
        _S654 = false;
    }
    if(_S654)
    {
        return _S651;
    }
    var _S655 : bool = _S652 > 0.0000152587890625f;
    if(_S655)
    {
        _S654 = _S652 < max_len_0;
    }
    else
    {
        _S654 = false;
    }
    if(_S654)
    {
        return _S652;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S656 : Random = draw(init_random_state_1, u32(4));
    var _S657 : Random = draw(init_random_state_1, u32(5));
    var _S658 : Random = draw(init_random_state_1, u32(2147483653));
    var _S659 : vec3<f32> = vec3<f32>(0.0f);
    var _S660 : TreeSample = TreeSample_x24init_0(_S659, _S659, 0.0f, _S658.state);
    var sample_0 : TreeSample = _S660;
    var _S661 : vec3<f32> = select(smooth_n_2, _S659, sided_0);
    var _S662 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S663 : vec3<f32> = origin_4 + _S662 * smooth_n_2;
    var pick_1 : f32 = _S656.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S664 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S664.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S665 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S666 : u32 = n_7 + u32(1);
        var _S667 : LightBounds = (lightBounds((_S666)));
        var _S668 : LightBounds = (lightBounds((_S665)));
        var _S669 : u32 = pickChild(_S667, _S668, origin_4, _S661, &(pick_1), &(probability_4));
        var _S670 : bool = _S669 > u32(1);
        if(_S670)
        {
            return sample_0;
        }
        var _S671 : bool = _S669 == u32(1);
        var _S672 : u32 = select(_S666, _S665, _S671);
        n_7 = _S672;
    }
    var _S673 : bool = n_7 == u32(0);
    var _S674 : bool;
    if(_S673)
    {
        var _S675 : LightBounds = (lightBounds((u32(0))));
        var _S676 : f32 = importance(_S675, origin_4, _S661);
        _S674 = !(_S676 > 0.0f);
    }
    else
    {
        _S674 = false;
    }
    if(_S674)
    {
        return sample_0;
    }
    var _S677 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S678 : bool = (_S677.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S678)
    {
        var _S679 : Light = (lights[(_S677.y)]);
        if(sided_0)
        {
            var _S680 : f32 = (sign((dot(geometry_n_1, _S679.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S680);
            var _S681 : vec3<f32> = origin_4 + _S662 * lift_n_1;
            start_5 = _S681;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S663;
            lift_n_0 = smooth_n_2;
        }
        var _S682 : bool = (_S679.variance) == 0.0f;
        if(_S682)
        {
            var _S683 : vec3<f32> = _S679.position - start_5;
            var _S684 : vec3<f32> = (normalize((_S683)));
            sample_0.dir = _S684;
            var _S685 : vec3<f32> = _S679.color * vec3<f32>(_S679.intensity) / vec3<f32>((dot(_S683, _S683) * probability_4));
            sample_0.radiance = _S685;
            shadow_1 = _S683;
        }
        else
        {
            var _S686 : vec3<f32> = sampleSphere(_S679.position, _S679.variance, start_5, _S657.value, _S658.value);
            sample_0.dir = _S686;
            var _S687 : f32 = sphereDensity(_S679.position, _S679.variance, start_5);
            var _S688 : f32 = probability_4 * _S687;
            sample_0.density = _S688;
            var _S689 : vec3<f32> = pointLightRadiance(_S679.color, _S679.intensity, _S679.variance);
            var _S690 : vec3<f32> = _S689 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S690;
            var _S691 : f32 = raySphere_0(_S679.position, _S679.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S692 : vec3<f32> = sample_0.dir * vec3<f32>(_S691);
            shadow_1 = _S692;
        }
    }
    else
    {
        var _S693 : u32 = _S677.y;
        var _S694 : u32 = ((instance_uint[(_S693) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S695 : u32 = _S694 + _S677.z;
        var _S696 : mat3x3<f32> = (worldTriangle((_S693), (_S695)));
        var _S697 : f32 = sqrt(_S657.value);
        var _S698 : vec2<f32> = vec2<f32>(_S697 * (1.0f - _S658.value), _S697 * _S658.value);
        var _S699 : vec3<f32> = (((_S696) * (vec3<f32>(1.0f - _S697, _S698))));
        if(sided_0)
        {
            var _S700 : f32 = (sign((dot(geometry_n_1, _S699 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S700);
            var _S701 : vec3<f32> = origin_4 + _S662 * lift_n_2;
            start_5 = _S701;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S702 : bool = !((dot(smooth_n_2, _S699 - origin_4)) > 0.0f);
            if(_S702)
            {
                return sample_0;
            }
            start_5 = _S663;
            lift_n_0 = smooth_n_2;
        }
        var _S703 : Surface = (surfaceAt((Hit_x24init_0(_S698, _S693, _S695, u32(0), 0.0f)), (_S699), (_S658.state)));
        sample_0.random_state = _S703.random_state;
        var _S704 : vec3<f32> = _S699 - start_5;
        var _S705 : vec3<f32> = (normalize((_S704)));
        sample_0.dir = _S705;
        var _S706 : f32 = solidAngle(probability_4, cross(_S696[i32(1)] - _S696[i32(0)], _S696[i32(2)] - _S696[i32(0)]), _S704);
        sample_0.density = _S706;
        var _S707 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S703.smooth_n))));
        var _S708 : vec3<f32> = _S703.material.emissive * vec3<f32>(max(_S707, 0.0f));
        var _S709 : vec3<f32> = select(_S708, _S659, _S703.skip);
        var _S710 : vec3<f32> = _S709 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S710;
        shadow_1 = _S704;
    }
    var _S711 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S712 : vec3<f32> = sample_0.radiance * _S711;
    var _S713 : bool = (all((_S711 == _S659)));
    var _S714 : vec3<f32> = select(_S712, _S659, _S713);
    sample_0.radiance = _S714;
    return sample_0;
}

struct NEEVertex
{
     none : bool,
     pdf : f32,
     origin : vec3<f32>,
     smooth_n : vec3<f32>,
     start : vec3<f32>,
};

fn powerHeuristic( a_7 : f32,  b_3 : f32) -> f32
{
    var _S715 : f32 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    var _S716 : bool = b_3 > 0.0f;
    var _S717 : f32 = select(1.0f, _S715, _S716);
    return _S717;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S718 : u32 = (lightSlot((hit_1)));
    var _S719 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S718, light_point_1);
    var _S720 : f32 = powerHeuristic(vertex_0.pdf, _S719);
    return _S720;
}

fn environment_0( dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S721 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S722 : bool = (_S721.x) > u32(1);
    var _S723 : bool;
    if(_S722)
    {
        var _S724 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S723 = (_S724.y) > u32(1);
    }
    else
    {
        _S723 = false;
    }
    if(_S723)
    {
        var _S725 : vec3<f32> = (env_map_sample((dir_8)));
        return _S725;
    }
    var _S726 : vec3<f32> = (uniforms_float.ambient);
    return _S726;
}

fn environmentMapped_0() -> bool
{
    var _S727 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S728 : bool = (_S727.x) > u32(1);
    var _S729 : bool;
    if(_S728)
    {
        var _S730 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S729 = (_S730.y) > u32(1);
    }
    else
    {
        _S729 = false;
    }
    return _S729;
}

fn escapeWeight_0( pdf_2 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S731 : bool = pdf_2 <= 0.0f;
    var _S732 : bool;
    if(_S731)
    {
        _S732 = true;
    }
    else
    {
        var _S733 : bool = environmentMapped_0();
        _S732 = !_S733;
    }
    if(_S732)
    {
        return 1.0f;
    }
    var _S734 : f32 = environmentPdf_0(dir_9);
    return pdf_2 / (pdf_2 + _S734);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_2 : u32;
    var _S735 : vec2<u32> = global_invocation_id_1.xy;
    var _S736 : vec2<i32> = vec2<i32>(_S735 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_6 : u32 = local_invocation_index_3;
    loop
    {
        if(i_6 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S737 : vec2<i32> = _S736 + vec2<i32>(i32(i_6 % u32(24)), i32(i_6 / u32(24)));
        var _S738 : bool = (all((_S737 >= vec2<i32>(i32(0)))));
        var _S739 : bool;
        if(_S738)
        {
            var _S740 : vec2<u32> = (uniforms_uint.render_size);
            _S739 = (all((_S737 < vec2<i32>(_S740))));
        }
        else
        {
            _S739 = false;
        }
        if(_S739)
        {
            var _S741 : vec4<u32> = (textureLoad(reservoir_prev, (_S737), (u32(0)), 0));
            var _S742 : u32 = _S741.x;
            var _S743 : bool = (bitcast<f32>((_S741.z))) > 0.0f;
            var _S744 : u32 = select(u32(0), _S742, _S743);
            seed_2 = _S744;
        }
        else
        {
            seed_2 = u32(0);
        }
        duplication_seeds_0[i_6] = seed_2;
        var i_7 : u32 = i_6 + u32(64);
        i_6 = i_7;
    }
    workgroupBarrier();
    var _S745 : u32 = local_invocation_id_0.y;
    var _S746 : u32 = local_invocation_id_0.x;
    var _S747 : u32 = duplication_seeds_0[(_S745 + u32(8)) * u32(24) + _S746 + u32(8)];
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
            var _S748 : bool = (duplication_seeds_0[(_S745 + seed_2) * u32(24) + _S746 + x_1]) == _S747;
            var _S749 : u32 = select(u32(0), u32(1), _S748);
            var count_2 : u32 = count_1 + _S749;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_2 + u32(1);
        seed_2 = y_0;
    }
    var _S750 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S751 : bool = _S747 != u32(0);
    var _S752 : f32 = select(0.0f, _S750, _S751);
    textureStore(duplication_out, (vec2<i32>(_S735)), 0, (vec4<u32>((bitcast<u32>((_S752))), u32(0), u32(0), u32(0))));
    return;
}

fn resamplingTarget( f_5 : vec3<f32>) -> f32
{
    var _S753 : f32 = rgb_to_greyscale(abs(f_5));
    return _S753;
}

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Selection_x24init_0( r_2 : Reservoir,  w_sum_0 : f32,  color_2 : vec3<f32>,  random_state_8 : u32) -> Selection
{
    var _S754 : Selection;
    _S754.r = r_2;
    _S754.w_sum = w_sum_0;
    _S754.color = color_2;
    _S754.random_state = random_state_8;
    return _S754;
}

fn pairShare( c_n_0 : f32,  c_pair_0 : f32,  c_sum_0 : f32) -> f32
{
    return (c_n_0 + c_pair_0) / c_sum_0;
}

fn canonicalWeight( share_0 : f32,  c_pair_1 : f32,  p_c_0 : f32,  c_n_1 : f32,  g_there_0 : f32) -> f32
{
    return share_0 * c_pair_1 * p_c_0 / (c_pair_1 * p_c_0 + c_n_1 * g_there_0);
}

struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

fn Shift_x24init_0( f_6 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S755 : Shift;
    _S755.f = f_6;
    _S755.jac = jac_1;
    return _S755;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S756 : f32 = resamplingTarget(weight_0);
    var _S757 : bool = _S756 > 0.0f;
    var _S758 : bool;
    if(_S757)
    {
        _S758 = _S756 < 3.00000000549775576e+38f;
    }
    else
    {
        _S758 = false;
    }
    var _S759 : bool = !_S758;
    if(_S759)
    {
        return;
    }
    var _S760 : f32 = (*sel_0).w_sum + _S756;
    (*sel_0).w_sum = _S760;
    var _S761 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S761;
    var _S762 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S762.state;
    var _S763 : bool = (_S762.value * (*sel_0).w_sum) <= _S756;
    if(_S763)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_3 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_3;
    var _S764 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S764;
    var _S765 : f32 = r_3.jac * shifted_0.jac;
    candidate_1.jac = _S765;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_3.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_4 : Reservoir = sel_2.r;
    var _S766 : f32 = resamplingTarget(r_4.f);
    var _S767 : f32 = sel_2.w_sum / _S766;
    var _S768 : bool = _S766 > 0.0f;
    var _S769 : f32 = select(0.0f, _S767, _S768);
    r_4.w = _S769;
    r_4.c = c_2;
    return r_4;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S770 : vec2<u32> = global_invocation_id_2.xy;
    var _S771 : vec2<i32> = vec2<i32>(_S770);
    var _S772 : vec3<f32> = vec3<f32>(0.0f);
    var _S773 : Domain = Domain_x24init_0(_S772, _S772, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S773;
    var _S774 : bool = (currentDomain((_S771), &(dom_3)));
    var _S775 : bool = !_S774;
    if(_S775)
    {
        storeReservoir(reservoir_prev_out, (_S771), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S772, 0.0f, vec4<u32>(u32(0)), _S772, _S772)), (dom_3.hit));
        var _S776 : vec2<f32> = vec2<f32>(_S770);
        var _S777 : vec2<u32> = (uniforms_uint.render_size);
        var _S778 : vec2<f32> = _S776 / vec2<f32>(_S777.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S779 : vec3<f32> = vec3<f32>(_S778, 1.0f);
        var _S780 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S781 : vec3<f32> = (normalize(((((_S780) * (_S779))))));
        var _S782 : vec3<f32> = environment_0(_S781);
        textureStore(compute_out, (_S771), (u32(0)), (vec4<f32>(_S782, 1.0f)));
        var _S783 : u32 = (uniforms_uint.is_temporal);
        var _S784 : bool = _S783 == u32(1);
        if(_S784)
        {
            textureStore(compute_out, (_S771), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S785 : Reservoir = (loadReservoir(reservoir_temp, (_S771)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S785.c;
    loop
    {
        var _S786 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S786)
        {
        }
        else
        {
            break;
        }
        var _S787 : vec2<i32> = partner_0(_S771, t_13);
        var neighbor_0 : Domain = _S773;
        var _S788 : bool = (currentDomain((_S787), &(neighbor_0)));
        if(_S788)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S789 : vec4<u32> = (textureLoad(reservoir_temp, (_S787), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S789.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S790 : f32 = _S785.c / max(count_3, 1.0f);
    var _S791 : f32 = resamplingTarget(_S785.f);
    var _S792 : bool = count_3 == 0.0f;
    var _S793 : f32 = select(0.0f, 1.0f, _S792);
    var _S794 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S772, 0.0f, vec4<u32>(u32(0)), _S772, _S772), 0.0f, _S772, u32(0));
    var sel_3 : Selection = _S794;
    var _S795 : u32 = (uniforms_uint.frame);
    var _S796 : u32 = hash(_S795);
    var _S797 : u32 = global_invocation_id_2.x;
    var _S798 : vec2<u32> = (uniforms_uint.render_size);
    var _S799 : u32 = stream(_S796, _S797 + _S798.x * global_invocation_id_2.y);
    var _S800 : u32 = stream(_S799, u32(195));
    sel_3.random_state = _S800;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S793;
    loop
    {
        var _S801 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S801)
        {
        }
        else
        {
            break;
        }
        var _S802 : vec2<i32> = partner_0(_S771, t_13);
        var neighbor_dom_0 : Domain = _S773;
        var _S803 : bool = (currentDomain((_S802), &(neighbor_dom_0)));
        if(_S803)
        {
            var _S804 : Reservoir = (loadReservoir(reservoir_temp, (_S802)));
            var _S805 : vec4<u32> = (textureLoad(shift_data, (_S802), (t_13), 0));
            var _S806 : vec4<f32> = (bitcast<vec4<f32>>((_S805)));
            var _S807 : vec4<u32> = (textureLoad(shift_data, (_S771), (t_13), 0));
            var _S808 : vec4<f32> = (bitcast<vec4<f32>>((_S807)));
            var _S809 : f32 = pairShare(_S804.c, _S790, c_sum_1);
            var _S810 : bool = _S791 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S810)
            {
                var _S811 : f32 = resamplingTarget(_S808.xyz);
                var _S812 : f32 = canonicalWeight(_S809, _S790, _S791, _S804.c, _S811);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S812;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S813 : vec3<f32> = _S806.xyz;
            var _S814 : Shift = Shift_x24init_0(_S813, _S806.w);
            var _S815 : f32 = resamplingTarget(_S804.f);
            var _S816 : f32 = resamplingTarget(_S813);
            var _S817 : f32 = neighborWeight(_S809, _S804.c, _S815, _S790, _S816);
            offerShifted(&(sel_3), _S804, _S814, _S817);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S785, Shift_x24init_0(_S785.f, 1.0f), canonical_mis_0);
    var _S818 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S771), (_S818), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S771), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S819 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S820 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S821 : f32 = (sign((dot(_S820, _S819.smooth_n))));
    var _S822 : vec3<f32> = _S819.material.emissive * vec3<f32>(max(_S821, 0.0f));
    var _S823 : vec3<f32> = select(_S822, _S772, _S819.skip);
    var _S824 : vec3<f32> = clamp(sel_3.color + _S823, vec3<f32>(-65519.0f), vec3<f32>(65519.0f));
    textureStore(compute_out, (_S771), (u32(0)), (vec4<f32>(_S824, 1.0f)));
    var _S825 : u32 = (uniforms_uint.is_temporal);
    var _S826 : bool = _S825 == u32(1);
    if(_S826)
    {
        textureStore(compute_out, (_S771), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_3 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S827 : NEEVertex;
    _S827.none = none_0;
    _S827.pdf = pdf_3;
    _S827.origin = origin_5;
    _S827.smooth_n = smooth_n_3;
    _S827.start = start_6;
    return _S827;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_0 : u32,  pdf_4 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S828 : Vertex;
    _S828.rough = rough_0;
    _S828.lobe = lobe_0;
    _S828.pdf = pdf_4;
    _S828.cos = cos_0;
    _S828.inside = inside_0;
    return _S828;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_1 : vec3<f32>,  velvet_0 : f32,  dispersion_0 : f32,  coat_2 : f32,  coat_roughness_0 : f32,  coat_ior_0 : f32,  coat_tint_0 : vec3<f32>,  coat_normal_0 : vec3<f32>) -> Material
{
    var _S829 : Material;
    _S829.albedo = albedo_0;
    _S829.emissive = emissive_0;
    _S829.roughness = roughness_0;
    _S829.metallic = metallic_0;
    _S829.transmission = transmission_0;
    _S829.ior = ior_0;
    _S829.absorption = absorption_0;
    _S829.specular_tint = specular_tint_0;
    _S829.specular_level = specular_level_0;
    _S829.translucent = translucent_0;
    _S829.sheen = sheen_2;
    _S829.sheen_roughness = sheen_roughness_0;
    _S829.anisotropy = anisotropy_0;
    _S829.anisotropic_rotation = anisotropic_rotation_0;
    _S829.tangent = tangent_1;
    _S829.velvet = velvet_0;
    _S829.dispersion = dispersion_0;
    _S829.coat = coat_2;
    _S829.coat_roughness = coat_roughness_0;
    _S829.coat_ior = coat_ior_0;
    _S829.coat_tint = coat_tint_0;
    _S829.coat_normal = coat_normal_0;
    return _S829;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_10 : Material,  skip_0 : bool,  random_state_9 : u32) -> Surface
{
    var _S830 : Surface;
    _S830.smooth_n = smooth_n_4;
    _S830.geometry_n = geometry_n_2;
    _S830.geometry_offset = geometry_offset_2;
    _S830.material = material_10;
    _S830.skip = skip_0;
    _S830.random_state = random_state_9;
    return _S830;
}

fn noiseAddress( origin_6 : u32,  bounce_0 : u32) -> u32
{
    var _S831 : vec2<u32> = vec2<u32>((origin_6 & (u32(2047))), (((origin_6 >> (u32(11)))) & (u32(2047))));
    var _S832 : vec2<u32> = noiseOffset(u32(64) + bounce_0 * u32(17));
    var _S833 : vec2<u32> = ((_S831 + _S832) & (vec2<u32>(u32(2047))));
    return ((((_S833.x) | ((((_S833.y) << (u32(11))))))) | (((((origin_6 >> (u32(22)))) << (u32(22))))));
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S834 : bool = transmission_1 > 0.0f;
    var _S835 : bool;
    if(_S834)
    {
        _S835 = true;
    }
    else
    {
        _S835 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S836 : f32;
    if(_S835)
    {
        _S836 = 1.0f;
    }
    else
    {
        _S836 = -1.0f;
    }
    return _S836;
}

fn facingRay_0( surface_4 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S837 : f32 = facingSign(surface_4.material.transmission, surface_4.geometry_n, dir_10);
    var _S838 : vec3<f32> = vec3<f32>(_S837);
    return Surface_x24init_0(surface_4.smooth_n * _S838, surface_4.geometry_n * _S838, surface_4.geometry_offset, surface_4.material, surface_4.skip, surface_4.random_state);
}

fn upsample( rgb_1 : vec3<f32>,  wavelength_0 : f32) -> f32
{
    var _S839 : f32 = dot(vec3<f32>(-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_1);
    var _S840 : f32 = dot(vec3<f32>(0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_1);
    var _S841 : f32 = dot(vec3<f32>(1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_1);
    var _S842 : vec3<f32> = vec3<f32>(_S839, _S840, _S841);
    var _S843 : f32 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    var _S844 : f32 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S839 + _S840 * exp(-0.5f * _S843 * _S843) + _S841 * exp(-0.5f * _S844 * _S844);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S845 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S845));
}

fn geometryDensity( geometry_n_3 : vec3<f32>,  direction_1 : vec3<f32>,  distance_2 : f32) -> f32
{
    return abs(dot(geometry_n_3, direction_1)) / (distance_2 * distance_2);
}

fn footprintThreshold( geometry_density_0 : f32) -> f32
{
    return 0.00251327408477664f / geometry_density_0;
}

fn withinFootprint( open_0 : bool,  prev_rough_0 : bool,  prev_pdf_0 : f32,  geometry_density_1 : f32,  threshold_0 : f32) -> bool
{
    var _S846 : bool;
    if(open_0)
    {
        _S846 = prev_rough_0;
    }
    else
    {
        _S846 = false;
    }
    if(_S846)
    {
        _S846 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S846 = false;
    }
    return _S846;
}

fn dispersive( material_11 : Material) -> bool
{
    var _S847 : bool = (material_11.dispersion) > 0.0f;
    var _S848 : bool;
    if(_S847)
    {
        _S848 = (material_11.ior) != 1.0f;
    }
    else
    {
        _S848 = false;
    }
    return _S848;
}

var<private> WAVELENGTH_CDF_0 : array<f32, i32(81)> = array<f32, i32(81)>( 0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996000528335571f, 0.99997997283935547f, 0.99998998641967773f, 0.99998998641967773f, 0.99998998641967773f, 1.0f, 1.0f, 1.0f, 1.0f );
fn sampleWavelength( u_1 : f32) -> vec2<f32>
{
    var low_1 : u32 = u32(0);
    var high_1 : u32 = u32(79);
    loop
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        var _S849 : u32 = (low_1 + high_1 + u32(1)) / u32(2);
        var _S850 : bool = (WAVELENGTH_CDF_0[_S849]) <= u_1;
        if(_S850)
        {
            low_1 = _S849;
        }
        else
        {
            var _S851 : u32 = _S849 - u32(1);
            high_1 = _S851;
        }
    }
    var _S852 : u32 = low_1;
    var _S853 : f32 = WAVELENGTH_CDF_0[low_1 + u32(1)] - WAVELENGTH_CDF_0[low_1];
    return vec2<f32>(0.37999999523162842f + 0.00499999988824129f * (f32(low_1) + (u_1 - WAVELENGTH_CDF_0[_S852]) / _S853), _S853 / 0.00499999988824129f);
}

var<private> WAVELENGTH_WEIGHTS_0 : array<f32, i32(243)> = array<f32, i32(243)>( 0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f );
fn wavelengthWeights( wavelength_1 : f32) -> vec3<f32>
{
    var _S854 : f32 = clamp((wavelength_1 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    var _S855 : u32 = min(u32(_S854), u32(79));
    var _S856 : u32 = u32(3) * _S855;
    var _S857 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S856], WAVELENGTH_WEIGHTS_0[_S856 + u32(1)], WAVELENGTH_WEIGHTS_0[_S856 + u32(2)]);
    var _S858 : vec3<f32> = vec3<f32>(WAVELENGTH_WEIGHTS_0[_S856 + u32(3)], WAVELENGTH_WEIGHTS_0[_S856 + u32(4)], WAVELENGTH_WEIGHTS_0[_S856 + u32(5)]);
    return _S857 + (_S858 - _S857) * vec3<f32>((_S854 - f32(_S855)));
}

fn atWavelength( material_12 : Material,  wavelength_2 : f32) -> Material
{
    var at_0 : Material = material_12;
    var _S859 : f32 = upsample(material_12.albedo, wavelength_2);
    var _S860 : vec3<f32> = vec3<f32>(_S859);
    at_0.albedo = _S860;
    var _S861 : f32 = upsample(material_12.emissive, wavelength_2);
    var _S862 : vec3<f32> = vec3<f32>(_S861);
    at_0.emissive = _S862;
    var _S863 : f32 = upsample(material_12.absorption, wavelength_2);
    var _S864 : vec3<f32> = vec3<f32>(_S863);
    at_0.absorption = _S864;
    var _S865 : f32 = upsample(material_12.specular_tint, wavelength_2);
    var _S866 : vec3<f32> = vec3<f32>(_S865);
    at_0.specular_tint = _S866;
    var _S867 : f32 = upsample(material_12.translucent, wavelength_2);
    var _S868 : vec3<f32> = vec3<f32>(_S867);
    at_0.translucent = _S868;
    var _S869 : f32 = upsample(material_12.sheen, wavelength_2);
    var _S870 : vec3<f32> = vec3<f32>(_S869);
    at_0.sheen = _S870;
    var _S871 : f32 = upsample(material_12.coat_tint, wavelength_2);
    var _S872 : vec3<f32> = vec3<f32>(_S871);
    at_0.coat_tint = _S872;
    return at_0;
}

fn dispersedIor( ior_1 : f32,  dispersion_1 : f32,  wavelength_3 : f32) -> f32
{
    var _S873 : f32 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    var _S874 : f32 = _S873 * (1.0f / (wavelength_3 * wavelength_3) - 2.89662933349609375f);
    var _S875 : bool = dispersion_1 > 0.0f;
    var _S876 : f32 = select(0.0f, _S874, _S875);
    return ior_1 + _S876;
}

fn vertexEta( material_13 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S877 : bool = n_dot_v_0 < 0.0f;
    var _S878 : f32 = select(1.0f, material_13.ior, _S877);
    var _S879 : f32 = select(material_13.ior, 1.0f, _S877);
    return vec2<f32>(_S878, _S879);
}

fn wavelengthEta( material_14 : Material,  n_dot_v_1 : f32,  wavelength_4 : f32) -> vec2<f32>
{
    var refractive_0 : Material = material_14;
    var _S880 : f32 = dispersedIor(material_14.ior, material_14.dispersion, wavelength_4);
    var _S881 : bool = wavelength_4 > 0.0f;
    var _S882 : f32 = select(material_14.ior, _S880, _S881);
    refractive_0.ior = _S882;
    var _S883 : vec2<f32> = vertexEta(refractive_0, n_dot_v_1);
    return _S883;
}

fn neeDecision( material_15 : Material,  n_dot_v_2 : f32,  eta_i_5 : f32,  eta_o_5 : f32) -> bool
{
    var _S884 : f32 = fresnel(abs(n_dot_v_2), eta_i_5, eta_o_5);
    var _S885 : vec3<f32> = (mix((vec3<f32>(_S884)), (material_15.albedo), (material_15.metallic)));
    var _S886 : f32 = rgb_to_greyscale(_S885);
    var _S887 : f32 = max((1.0f - _S886) * (1.0f - material_15.metallic) * (1.0f - material_15.transmission), 0.0f);
    var _S888 : bool = _S887 > 0.03999999910593033f;
    var _S889 : bool;
    if(_S888)
    {
        _S889 = true;
    }
    else
    {
        _S889 = (material_15.roughness) > 0.20000000298023224f;
    }
    return _S889;
}

fn pathColor( f_7 : vec3<f32>,  weight_1 : vec3<f32>,  wavelength_5 : f32) -> vec3<f32>
{
    var _S890 : vec3<f32>;
    if(wavelength_5 > 0.0f)
    {
        var _S891 : f32 = upsample(f_7, wavelength_5);
        _S890 = weight_1 * vec3<f32>(_S891);
    }
    else
    {
        _S890 = f_7;
    }
    return _S890;
}

fn isTranslucent_0( material_16 : Material) -> bool
{
    var _S892 : f32 = rgb_to_greyscale(material_16.translucent);
    return _S892 > 0.0f;
}

fn lightBSDF_0( in_dir_6 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_17 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  competing_0 : bool,  random_state_10 : u32) -> vec3<f32>
{
    var _S893 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_6)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(6)>;
    var pdfs_3 : array<f32, i32(6)>;
    var _S894 : vec3<f32> = BSDF(in_dir_6, light_0.dir, smooth_n_5, material_17, eta_i_6, eta_o_6, _S893, random_state_10, &(throughputs_1), &(pdfs_3));
    var _S895 : bool = !competing_0;
    var _S896 : bool;
    if(_S895)
    {
        _S896 = true;
    }
    else
    {
        _S896 = (light_0.density) == 0.0f;
    }
    if(_S896)
    {
        return _S894 * light_0.radiance;
    }
    var _S897 : vec3<f32> = vec3<f32>(0.0f);
    var i_8 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S897;
    loop
    {
        if(i_8 < u32(6))
        {
        }
        else
        {
            break;
        }
        var _S898 : bool = (pdfs_3[i_8]) > 0.0f;
        if(_S898)
        {
            var _S899 : f32 = pdfs_3[i_8] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_8] * vec3<f32>(pdfs_3[i_8]) / vec3<f32>((light_0.density * (1.0f + _S899 * _S899)));
            weighted_0 = weighted_1;
        }
        var i_9 : u32 = i_8 + u32(1);
        i_8 = i_9;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_8 : vec3<f32>,  b_4 : vec3<f32>) -> vec3<f32>
{
    var _S900 : vec3<f32> = a_8 / b_4;
    var _S901 : vec3<f32> = vec3<f32>(0.0f);
    var _S902 : vec3<bool> = b_4 == _S901;
    var _S903 : vec3<f32> = select(_S900, _S901, _S902);
    return _S903;
}

fn withEnd( r_5 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_8 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_5;
    var _S904 : u32 = (insertBits((r_5.path), (end_0), (u32(0)), (u32(5))));
    var _S905 : u32 = (insertBits((_S904), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S905;
    candidate_2.f = f_8;
    return candidate_2;
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_11 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_5 : f32) -> SampleBSDF
{
    var _S906 : SampleBSDF;
    _S906.unit_direction = unit_direction_1;
    _S906.throughput = throughput_0;
    _S906.random_state = random_state_11;
    _S906.refracted = refracted_3;
    _S906.lobe = lobe_1;
    _S906.pdf = pdf_5;
    return _S906;
}

fn sheenVelvetSample( v_8 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_3 : f32,  material_18 : Material,  w_15 : Weights,  random_state_12 : u32) -> SampleBSDF
{
    var _S907 : vec3<f32> = vec3<f32>(1.0f);
    var _S908 : SampleBSDF = SampleBSDF_x24init_0(_S907, _S907, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S908;
    var _S909 : Random = draw(random_state_12, u32(3));
    var _S910 : Random = draw(random_state_12, u32(2147483651));
    sample_1.random_state = _S910.state;
    var _S911 : f32 = _S909.value;
    var _S912 : f32 = sqrt(max(0.0f, 1.0f - _S911 * _S911));
    var _S913 : f32 = 6.28318548202514648f * _S910.value;
    var _S914 : vec3<f32> = tangentToWorld(vec3<f32>(_S912 * cos(_S913), _S909.value, _S912 * sin(_S913)), n_i_10);
    sample_1.unit_direction = _S914;
    sample_1.lobe = u32(4);
    var _S915 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, v_8, n_i_10, material_18, w_15);
    sample_1.throughput = _S915;
    var _S916 : f32 = sheenVelvetPDF(_S909.value, n_i_dot_v_3, w_15);
    sample_1.pdf = _S916;
    return sample_1;
}

fn coatSample( in_dir_7 : vec3<f32>,  coat_h_1 : vec3<f32>,  w_16 : Weights,  random_state_13 : u32) -> SampleBSDF
{
    var _S917 : vec3<f32> = vec3<f32>(1.0f);
    var _S918 : SampleBSDF = SampleBSDF_x24init_0(_S917, _S917, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S918;
    var _S919 : vec3<f32> = (normalize((reflect(in_dir_7, coat_h_1))));
    sample_2.unit_direction = _S919;
    sample_2.random_state = random_state_13;
    sample_2.lobe = u32(5);
    var _S920 : vec3<f32> = coatBSDF(w_16);
    sample_2.throughput = _S920;
    var _S921 : f32 = coatPDF(w_16);
    sample_2.pdf = _S921;
    return sample_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S922 : f32 = sqrt(random_1_0);
    var _S923 : f32 = 6.28318548202514648f * random_2_0;
    var _S924 : f32 = _S922 * cos(_S923);
    var _S925 : f32 = _S922 * sin(_S923);
    var _S926 : f32 = sqrt(max(0.0f, 1.0f - _S924 * _S924 - _S925 * _S925));
    return vec3<f32>(_S924, _S926, _S925);
}

fn diffuseSample( u_2 : f32,  n_i_11 : vec3<f32>,  n_i_dot_v_4 : f32,  material_19 : Material,  w_17 : Weights,  random_state_14 : u32) -> SampleBSDF
{
    var _S927 : vec3<f32> = vec3<f32>(1.0f);
    var _S928 : SampleBSDF = SampleBSDF_x24init_0(_S927, _S927, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S928;
    var _S929 : Random = draw(random_state_14, u32(3));
    var _S930 : Random = draw(random_state_14, u32(2147483651));
    sample_3.random_state = _S930.state;
    var _S931 : vec3<f32> = sampleCosWeightedHemisphere(_S929.value, _S930.value);
    var _S932 : f32 = translucentShare(material_19);
    var _S933 : bool = u_2 < (w_17.p_diffuse * _S932);
    var _S934 : f32 = _S931.y;
    var _S935 : f32 = - _S934;
    var _S936 : f32 = select(_S934, _S935, _S933);
    var _S937 : vec3<f32> = tangentToWorld(vec3<f32>(_S931.x, _S936, _S931.z), n_i_11);
    sample_3.unit_direction = _S937;
    sample_3.refracted = _S933;
    sample_3.lobe = u32(0);
    var _S938 : vec3<f32> = diffuseBSDF(sample_3.unit_direction, n_i_11, material_19, w_17);
    sample_3.throughput = _S938;
    var _S939 : f32 = diffusePDF(_S936, n_i_dot_v_4, material_19, w_17);
    sample_3.pdf = _S939;
    return sample_3;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_12 : vec3<f32>,  alpha_8 : f32,  frame_6 : AnisotropicFrame,  material_20 : Material,  w_18 : Weights,  pdf_h_3 : f32,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_15 : u32) -> SampleBSDF
{
    var _S940 : vec3<f32> = vec3<f32>(1.0f);
    var _S941 : SampleBSDF = SampleBSDF_x24init_0(_S940, _S940, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S941;
    sample_4.unit_direction = w_18.refracted;
    sample_4.random_state = random_state_15;
    sample_4.refracted = true;
    sample_4.lobe = u32(1);
    var _S942 : vec3<f32> = refractBSDF(sample_4.unit_direction, n_i_12, alpha_8, frame_6, material_20, w_18);
    sample_4.throughput = _S942;
    var _S943 : f32 = refractPDF(dot(sample_4.unit_direction, ggx_n_3), pdf_h_3, w_18, eta_i_7, eta_o_7);
    sample_4.pdf = _S943;
    return sample_4;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_13 : vec3<f32>,  alpha_9 : f32,  frame_7 : AnisotropicFrame,  w_19 : Weights,  pdf_h_4 : f32,  random_state_16 : u32) -> SampleBSDF
{
    var _S944 : vec3<f32> = vec3<f32>(1.0f);
    var _S945 : SampleBSDF = SampleBSDF_x24init_0(_S944, _S944, u32(0), false, u32(0), 0.0f);
    var sample_5 : SampleBSDF = _S945;
    var _S946 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_5.unit_direction = _S946;
    sample_5.random_state = random_state_16;
    sample_5.lobe = u32(2);
    var _S947 : vec3<f32> = reflectBSDF(sample_5.unit_direction, n_i_13, alpha_9, frame_7, w_19);
    sample_5.throughput = _S947;
    var _S948 : f32 = reflectPDF(pdf_h_4, w_19);
    sample_5.pdf = _S948;
    return sample_5;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_21 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_17 : u32 = random_init_0;
    var _S949 : vec3<f32> = ((-(in_dir_9)));
    var _S950 : f32 = dot(n_8, _S949);
    var _S951 : f32 = (sign((_S950)));
    var n_i_14 : vec3<f32> = n_8 * vec3<f32>(_S951);
    var _S952 : f32 = abs(_S950);
    var _S953 : f32 = material_21.roughness;
    var _S954 : f32 = _S953 * _S953;
    var _S955 : AnisotropicFrame = anisotropicFrame(material_21, n_i_14);
    var _S956 : vec3<f32> = sampleHalfVector(_S949, n_i_14, _S954, _S955, &(random_state_17), u32(0));
    var _S957 : vec3<f32> = coatHalf(_S949, n_i_14, material_21, random_init_0);
    var _S958 : Weights = lobeWeights(in_dir_9, _S949, n_i_14, _S956, _S957, _S955, material_21, eta_i_8, eta_o_8);
    var _S959 : Random = draw(random_state_17, u32(2));
    random_state_17 = _S959.state;
    var _S960 : bool = (_S959.value) < (_S958.p_sheen_velvet);
    if(_S960)
    {
        var _S961 : SampleBSDF = sheenVelvetSample(_S949, n_i_14, _S952, material_21, _S958, random_state_17);
        return _S961;
    }
    var _S962 : f32 = _S959.value - _S958.p_sheen_velvet;
    var _S963 : bool = _S962 < (_S958.p_coat);
    if(_S963)
    {
        var _S964 : SampleBSDF = coatSample(in_dir_9, _S957, _S958, random_state_17);
        return _S964;
    }
    var _S965 : f32 = _S962 - _S958.p_coat;
    var _S966 : bool = _S965 < (_S958.p_diffuse);
    if(_S966)
    {
        var _S967 : SampleBSDF = diffuseSample(_S965, n_i_14, _S952, material_21, _S958, random_state_17);
        return _S967;
    }
    var _S968 : f32 = vndfPDF(_S949, _S956, n_i_14, _S952, _S954, _S955, _S958.v_dot_h);
    var _S969 : bool = _S965 < (_S958.p_diffuse + _S958.p_refract);
    if(_S969)
    {
        var _S970 : SampleBSDF = refractSample(_S956, n_i_14, _S954, _S955, material_21, _S958, _S968, eta_i_8, eta_o_8, random_state_17);
        return _S970;
    }
    var _S971 : SampleBSDF = reflectSample(in_dir_9, _S956, n_i_14, _S954, _S955, _S958, _S968, random_state_17);
    return _S971;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S972 : bool = pdf_6 > 0.0f;
    var _S973 : bool;
    if(_S972)
    {
        if(diffuse_0)
        {
            _S973 = true;
        }
        else
        {
            _S973 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S973 = false;
    }
    return _S973;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S974 : bool = pdf_7 > 0.0f;
    var _S975 : bool;
    if(_S974)
    {
        if(diffuse_1)
        {
            _S975 = true;
        }
        else
        {
            _S975 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S975 = false;
    }
    return _S975;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S976 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S976.x, max(_S976.y, _S976.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_6 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S977 : vec3<f32> = vec3<f32>(0.0f);
    var _S978 : Shift = Shift_x24init_0(_S977, 0.0f);
    var _S979 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S980 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S981 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S982 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S983 : bool = _S982 >= u32(3);
        var _S984 : u32 = select(u32(0), u32(1), _S983);
        var _S985 : u32 = _S979 + _S984;
        var _S986 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S985 > _S986;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S978;
    }
    var _S987 : u32 = _S980 - u32(1);
    var _S988 : bool = _S982 == u32(3);
    var _S989 : u32 = select(u32(0), u32(1), _S988);
    var _S990 : u32 = _S979 + _S989;
    var _S991 : bool = _S981 == u32(0);
    var _S992 : u32 = select(_S987, _S990, _S991);
    var _S993 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_6.rc.zw))), r_6.rc.x, r_6.rc.y, u32(0), 0.0f);
    var _S994 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S995 : Ray = Ray_x24init_0(dom_4.x1, _S994);
    var ray_2 : Ray = _S995;
    var hit_2 : Hit = dom_4.hit;
    var _S996 : vec3<f32> = vec3<f32>(1.0f);
    var _S997 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S977, _S977, _S977);
    var nee_vertex_0 : NEEVertex = _S997;
    var _S998 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S998;
    var _S999 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S977, 0.0f, vec4<u32>(u32(0)), _S977, _S977);
    var chain_0 : Reservoir = _S999;
    chain_0.seed = r_6.seed;
    var _S1000 : u32 = (extractBits((r_6.path), (u32(24)), (u32(8))));
    var _S1001 : u32 = (insertBits((u32(0)), (_S1000), (u32(24)), (u32(8))));
    chain_0.path = _S1001;
    is_inside_5 = false;
    var wavelength_6 : f32 = 0.0f;
    var threshold_2 : f32 = 0.0f;
    var spectral_weight_0 : vec3<f32> = _S996;
    var chain_throughput_0 : vec3<f32> = _S977;
    var reconnection_0 : vec3<f32> = _S977;
    var b_5 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S996;
    var scatter_in_0 : vec3<f32> = _S977;
    var extinction_in_0 : vec3<f32> = _S977;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S1002 : bool = (hit_2.is_point_light) == u32(1);
        var _S1003 : bool;
        if(replay_0)
        {
            _S1003 = _S981 == u32(1);
        }
        else
        {
            _S1003 = false;
        }
        var _S1004 : bool;
        if(_S1003)
        {
            _S1004 = b_5 == _S980;
        }
        else
        {
            _S1004 = false;
        }
        var _S1005 : bool;
        if(_S1004)
        {
            var _S1006 : bool = (hit_2.instance_index) != (_S993.instance_index);
            if(_S1006)
            {
                _S1005 = true;
            }
            else
            {
                _S1005 = (hit_2.triangle_index) != (_S993.triangle_index);
            }
        }
        else
        {
            _S1005 = false;
        }
        if(_S1005)
        {
            return _S978;
        }
        var _S1007 : Surface = Surface_x24init_0(_S977, _S977, 0.0f, Material_x24init_0(_S977, _S977, 0.0f, 0.0f, 0.0f, 0.0f, _S977, _S996, 1.0f, _S977, _S977, 0.5f, 0.0f, 0.0f, _S977, 0.0f, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S996, _S977), false, u32(0));
        var _S1008 : bool = !_S1002;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S1008)
        {
            var _S1009 : u32 = noiseAddress(r_6.seed, b_5);
            var _S1010 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S1009)));
            var surface_6 : Surface = facingRay_0(_S1010, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S1011 : f32 = hit_2.distance;
                var _S1012 : f32 = upsample(surface_6.material.absorption, wavelength_6);
                var _S1013 : vec3<f32> = vec3<f32>(_S1012);
                var _S1014 : bool = wavelength_6 > 0.0f;
                var _S1015 : vec3<f32> = select(surface_6.material.absorption, _S1013, _S1014);
                var _S1016 : vec3<f32> = beerLambert(_S1011, _S1015);
                var _S1017 : vec3<f32> = throughput_2 * _S1016;
                front_n_0 = _S1017;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S1018 : bool = !surface_6.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_6.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S1019 : bool = b_5 == u32(0);
            if(_S1019)
            {
                var _S1020 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1020;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S1021 : vec3<f32> = front_n_0;
            var _S1022 : f32 = geometry_density_2;
            scatter_0 = _S1018;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1022;
            surface_5 = surface_6;
            front_n_0 = _S1010.smooth_n;
            throughput_3 = _S1021;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_5 = _S1007;
            front_n_0 = _S977;
            throughput_3 = throughput_2;
        }
        var _S1023 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S1024 : Surface = surface_5;
        var _S1025 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S1026 : bool = ((true));
        var _S1027 : bool;
        if(_S1026)
        {
            _S1027 = wavelength_6 == 0.0f;
        }
        else
        {
            _S1027 = false;
        }
        var _S1028 : bool;
        if(_S1027)
        {
            _S1028 = scatter_0;
        }
        else
        {
            _S1028 = false;
        }
        var _S1029 : bool;
        if(_S1028)
        {
            var _S1030 : bool = dispersive(surface_5.material);
            _S1029 = _S1030;
        }
        else
        {
            _S1029 = false;
        }
        var throughput_4 : vec3<f32>;
        if(_S1029)
        {
            var _S1031 : u32 = stream(r_6.seed, u32(512));
            var _S1032 : Random = pcg(_S1031);
            var _S1033 : u32 = (extractBits((r_6.path), (u32(25)), (u32(7))));
            var _S1034 : f32 = (f32(_S1033) + _S1032.value) / 128.0f;
            var _S1035 : u32 = (extractBits((r_6.path), (u32(24)), (u32(1))));
            var _S1036 : bool = _S1035 == u32(1);
            var _S1037 : f32 = select(_S1032.value, _S1034, _S1036);
            var _S1038 : vec2<f32> = sampleWavelength(_S1037);
            var wavelength_7 : f32 = _S1038.x;
            var _S1039 : vec3<f32> = wavelengthWeights(wavelength_7);
            var _S1040 : vec3<f32> = _S1039 / vec3<f32>(_S1038.y);
            var _S1041 : f32 = upsample(throughput_3, wavelength_7);
            var _S1042 : vec3<f32> = vec3<f32>(_S1041);
            var _S1043 : f32 = upsample(scatter_in_0, wavelength_7);
            var _S1044 : vec3<f32> = vec3<f32>(_S1043);
            var _S1045 : f32 = upsample(extinction_in_0, wavelength_7);
            var _S1046 : vec3<f32> = vec3<f32>(_S1045);
            wavelength_6 = wavelength_7;
            spectral_weight_0 = _S1040;
            throughput_4 = _S1042;
            scatter_in_0 = _S1044;
            extinction_in_0 = _S1046;
        }
        else
        {
            throughput_4 = throughput_3;
        }
        var _S1047 : bool = wavelength_6 > 0.0f;
        var _S1048 : Material;
        if(_S1047)
        {
            var _S1049 : Material = atWavelength(surface_5.material, wavelength_6);
            _S1048 = _S1049;
        }
        else
        {
            _S1048 = surface_5.material;
        }
        var _S1050 : vec2<f32> = wavelengthEta(_S1048, _S1025, wavelength_6);
        var _S1051 : bool;
        if(scatter_0)
        {
            var _S1052 : bool = neeDecision(_S1048, _S1025, _S1050.x, _S1050.y);
            _S1051 = _S1052;
        }
        else
        {
            _S1051 = false;
        }
        var _S1053 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S1054 : vec3<f32> = _S1048.emissive * vec3<f32>(max(_S1053, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S1002)
        {
            var _S1055 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S1055;
        }
        else
        {
            emission_0 = _S1054;
        }
        var _S1056 : f32 = rgb_to_greyscale(emission_0);
        var _S1057 : bool = _S1056 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S1057)
        {
            var _S1058 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S1058);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S1059 : bool;
        if(replay_0)
        {
            _S1059 = _S981 == u32(1);
        }
        else
        {
            _S1059 = false;
        }
        var _S1060 : bool;
        if(_S1059)
        {
            _S1060 = b_5 > _S980;
        }
        else
        {
            _S1060 = false;
        }
        var _S1061 : bool;
        if(_S1060)
        {
            _S1061 = b_5 == _S979;
        }
        else
        {
            _S1061 = false;
        }
        var _S1062 : bool;
        if(_S1061)
        {
            var _S1063 : bool = _S982 == u32(1);
            if(_S1063)
            {
                _S1062 = true;
            }
            else
            {
                _S1062 = _S982 == u32(2);
            }
        }
        else
        {
            _S1062 = false;
        }
        if(_S1062)
        {
            var _S1064 : bool = _S1002 != (_S982 == u32(2));
            if(_S1064)
            {
                return _S978;
            }
            var _S1065 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_6);
            return Shift_x24init_0(_S1065 / vec3<f32>(r_6.jac), density_2 / r_6.jac);
        }
        var _S1066 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S1067 : bool = _S1066 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S1068 : u32 = (insertBits((_S1001), (b_5), (u32(5)), (u32(5))));
        var _S1069 : u32 = (insertBits((_S1068), (u32(1)), (u32(10)), (u32(2))));
        var _S1070 : u32 = (insertBits((_S1069), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S1071 : bool = prev_0.inside;
        var _S1072 : u32 = select(u32(0), u32(1), _S1071);
        var _S1073 : u32 = (insertBits((_S1070), (_S1072), (u32(22)), (u32(1))));
        here_0.path = _S1073;
        var _S1074 : u32 = here_0.path;
        var _S1075 : u32 = select(u32(0), u32(1), _S1047);
        var _S1076 : u32 = (insertBits((_S1074), (_S1075), (u32(23)), (u32(1))));
        here_0.path = _S1076;
        var _S1077 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S1077;
        var _S1078 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S1078;
        var _S1079 : bool;
        if(replay_0)
        {
            _S1079 = _S981 == u32(1);
        }
        else
        {
            _S1079 = false;
        }
        var _S1080 : bool;
        if(_S1079)
        {
            _S1080 = b_5 == _S980;
        }
        else
        {
            _S1080 = false;
        }
        var _S1081 : bool = b_5 == _S992;
        var _S1082 : bool;
        if(_S1081)
        {
            var _S1083 : bool = !scatter_0;
            if(_S1083)
            {
                _S1082 = true;
            }
            else
            {
                var _S1084 : bool = _S981 != u32(1);
                if(_S1084)
                {
                    _S1082 = _S981 != u32(3);
                }
                else
                {
                    _S1082 = false;
                }
            }
        }
        else
        {
            _S1082 = false;
        }
        var _S1085 : bool;
        if(_S1082)
        {
            _S1085 = _S981 == u32(2);
        }
        else
        {
            _S1085 = false;
        }
        var _S1086 : bool;
        if(_S1085)
        {
            _S1086 = !_S1023;
        }
        else
        {
            _S1086 = false;
        }
        var _S1087 : bool;
        if(_S1086)
        {
            _S1087 = _S982 != u32(4);
        }
        else
        {
            _S1087 = false;
        }
        var _S1088 : bool = _S980 == _S979;
        var _S1089 : bool;
        if(_S1088)
        {
            _S1089 = _S982 == u32(0);
        }
        else
        {
            _S1089 = false;
        }
        var _S1090 : bool;
        if(_S1089)
        {
            _S1090 = (hit_2.instance_index) == (_S993.instance_index);
        }
        else
        {
            _S1090 = false;
        }
        var _S1091 : bool;
        if(_S1090)
        {
            _S1091 = (hit_2.triangle_index) == (_S993.triangle_index);
        }
        else
        {
            _S1091 = false;
        }
        var _S1092 : bool;
        if(_S1091)
        {
            _S1092 = _S1023;
        }
        else
        {
            _S1092 = false;
        }
        var _S1093 : bool = select(_S1087, _S1092, _S1080);
        var _S1094 : bool;
        if(_S1051)
        {
            _S1094 = select(scatter_0, _S1093, replay_0);
        }
        else
        {
            _S1094 = false;
        }
        var _S1095 : TreeSample = TreeSample_x24init_0(_S977, _S977, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S1094)
        {
            var _S1096 : Surface = surface_5;
            var _S1097 : bool = isTranslucent_0(_S1048);
            var _S1098 : u32 = noiseAddress(r_6.seed, b_5);
            var _S1099 : TreeSample = sampleLightTree_0(ray_2.origin, _S1024.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S1097, _S1098);
            var _S1100 : bool = (any(((_S1099.radiance) != _S977)));
            if(_S1100)
            {
                var _S1101 : f32 = _S1050.x;
                var _S1102 : f32 = _S1050.y;
                var _S1103 : u32 = (uniforms_uint.max_bounces);
                var _S1104 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S1099, _S1024.smooth_n, _S1096.geometry_n, _S1048, _S1101, _S1102, b_5 < _S1103, surface_5.random_state);
                lit_0 = _S1104;
            }
            else
            {
                lit_0 = _S977;
            }
            light_1 = _S1099;
        }
        else
        {
            light_1 = _S1095;
            lit_0 = _S977;
        }
        var _S1105 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S1106 : bool;
        var _S1107 : bool;
        var density_3 : f32;
        var throughput_5 : vec3<f32>;
        if(_S1080)
        {
            var _S1108 : bool = !_S1023;
            if(_S1108)
            {
                return _S978;
            }
            var _S1109 : u32 = (extractBits((r_6.path), (u32(23)), (u32(1))));
            var _S1110 : bool = _S1047 != (_S1109 == u32(1));
            if(_S1110)
            {
                return _S978;
            }
            var throughput_6 : vec3<f32> = throughput_4 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S1088)
            {
                _S1105 = _S982 == u32(1);
            }
            else
            {
                _S1105 = false;
            }
            if(_S1105)
            {
                var _S1111 : vec3<f32> = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1111 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S1088)
            {
                wrong_side_0 = _S982 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S1112 : bool = !_S1051;
                if(_S1112)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S1113 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S1113 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S978;
                }
                var _S1114 : vec3<f32> = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1114 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S1088)
            {
                refracted_4 = _S982 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S1115 : bool = !_S1051;
                if(_S1115)
                {
                    return _S978;
                }
                var _S1116 : f32 = environmentPdf_0(r_6.dir);
                var _S1117 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_6.dir, surface_5, _S1050, is_inside_5, _S1116, surface_5.random_state);
                var _S1118 : vec3<f32> = pathColor(throughput_6 * _S1117 * r_6.radiance, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1118 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            var _S1119 : u32 = (extractBits((r_6.path), (u32(21)), (u32(1))));
            var _S1120 : bool = _S1051 != (_S1119 == u32(1));
            if(_S1120)
            {
                return _S978;
            }
            throughput_5 = throughput_6;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S1105 = _S1081;
            }
            else
            {
                _S1105 = false;
            }
            if(_S1105)
            {
                var _S1121 : bool = !scatter_0;
                if(_S1121)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S1122 : bool = _S981 != u32(1);
                    if(_S1122)
                    {
                        wrong_side_0 = _S981 != u32(3);
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
                var _S1123 : bool = _S981 == u32(2);
                if(_S1123)
                {
                    _S1003 = _S1051;
                }
                else
                {
                    _S1003 = false;
                }
                if(_S1003)
                {
                    _S1003 = !_S1023;
                }
                else
                {
                    _S1003 = false;
                }
                if(_S1003)
                {
                    _S1003 = _S982 == u32(4);
                }
                else
                {
                    _S1003 = false;
                }
                if(_S1003)
                {
                    var _S1124 : u32 = noiseAddress(r_6.seed, b_5);
                    var _S1125 : SkySample = sampleSky_0(ray_2, surface_5, _S1050, is_inside_5, _S1124, surface_5.random_state);
                    var _S1126 : vec3<f32> = pathColor(throughput_4 * _S1125.color, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1126, 1.0f);
                }
                if(_S1123)
                {
                    is_inside_5 = _S1051;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S1023;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S1127 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S1128 : bool = !(_S1127 > 0.0f);
                    if(_S1128)
                    {
                        return _S978;
                    }
                    var _S1129 : vec3<f32> = pathColor(throughput_4 * lit_0, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1129, 1.0f);
                }
                if(_S991)
                {
                    is_inside_5 = _S982 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S1002;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S1130 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1130, 1.0f);
                }
                if(_S991)
                {
                    is_inside_5 = _S982 == u32(1);
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
                    is_inside_5 = !_S1023;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S1131 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1131, 1.0f);
                }
                return _S978;
            }
            else
            {
                var _S1132 : bool = !replay_0;
                if(_S1132)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S1133 : bool = b_5 > u32(0);
                    if(_S1133)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S1067)
                        {
                            var _S1134 : vec3<f32> = safeDivide(throughput_4 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S1134;
                        }
                        else
                        {
                            if(_S1023)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S1135 : vec3<f32> = pathColor(throughput_4 * emission_1, spectral_weight_0, wavelength_6);
                        var _S1136 : Reservoir = withEnd(candidate_3, u32(1), b_5, _S1135);
                        offer(&((*sel_4)), _S1136, _S1135 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S1051)
                    {
                        var _S1137 : vec3<f32> = pathColor(throughput_4 * lit_0, spectral_weight_0, wavelength_6);
                        var candidate_4 : Reservoir = chain_0;
                        if(_S1067)
                        {
                            var _S1138 : vec3<f32> = safeDivide(_S1137, chain_throughput_0);
                            candidate_4.radiance = _S1138;
                        }
                        else
                        {
                            if(_S1023)
                            {
                                candidate_4 = here_0;
                                var _S1139 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S1139;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S1140 : u32 = (insertBits((_S1001), (b_5 + u32(1)), (u32(5)), (u32(5))));
                                var _S1141 : u32 = (insertBits((_S1140), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S1141;
                            }
                        }
                        var _S1142 : Reservoir = withEnd(candidate_4, u32(0), b_5, _S1137);
                        offer(&((*sel_4)), _S1142, _S1137 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S1051)
                    {
                        var _S1143 : bool = environmentMapped_0();
                        _S1106 = _S1143;
                    }
                    else
                    {
                        _S1106 = false;
                    }
                    if(_S1106)
                    {
                        var _S1144 : u32 = (uniforms_uint.max_bounces);
                        _S1107 = b_5 < _S1144;
                    }
                    else
                    {
                        _S1107 = false;
                    }
                    if(_S1107)
                    {
                        var _S1145 : u32 = noiseAddress(r_6.seed, b_5);
                        var _S1146 : SkySample = sampleSky_0(ray_2, surface_5, _S1050, is_inside_5, _S1145, surface_5.random_state);
                        var _S1147 : vec3<f32> = pathColor(throughput_4 * _S1146.color, spectral_weight_0, wavelength_6);
                        var candidate_5 : Reservoir = chain_0;
                        if(_S1067)
                        {
                            var _S1148 : vec3<f32> = safeDivide(_S1147, chain_throughput_0);
                            candidate_5.radiance = _S1148;
                        }
                        else
                        {
                            if(_S1023)
                            {
                                candidate_5 = here_0;
                                var _S1149 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S1149;
                                candidate_5.dir = _S1146.dir;
                                candidate_5.radiance = _S1146.radiance;
                            }
                            else
                            {
                                var _S1150 : u32 = (insertBits((_S1001), (b_5 + u32(1)), (u32(5)), (u32(5))));
                                var _S1151 : u32 = (insertBits((_S1150), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S1151;
                            }
                        }
                        var _S1152 : Reservoir = withEnd(candidate_5, u32(4), b_5, _S1147);
                        offer(&((*sel_4)), _S1152, _S1147 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_5 = throughput_4;
            density_3 = density_2;
        }
        var _S1153 : bool;
        var _S1154 : bool;
        var straight_0 : bool;
        var _S1155 : bool;
        var _S1156 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S1105 = _S1081;
            }
            else
            {
                _S1105 = false;
            }
            var _S1157 : u32 = (extractBits((r_6.path), (u32(15)), (u32(3))));
            var _S1158 : u32 = (extractBits((r_6.path), (u32(18)), (u32(3))));
            var _S1159 : u32 = select(_S1157, _S1158, _S1080);
            var refracted_5 : bool = _S1159 == u32(1);
            var _S1160 : SampleBSDF = SampleBSDF_x24init_0(_S977, _S977, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S1160;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S1105)
            {
                var _S1161 : u32 = (extractBits((r_6.path), (u32(22)), (u32(1))));
                var _S1162 : bool = is_inside_5 != (_S1161 == u32(1));
                if(_S1162)
                {
                    return _S978;
                }
                var _S1163 : bool = _S981 == u32(1);
                if(_S1163)
                {
                    var _S1164 : vec3<f32> = (hitPosition((_S993)));
                    dir_11 = _S1164;
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
                    var _S1165 : bool = isTranslucent_0(_S1048);
                    if(_S1165)
                    {
                        wrong_side_0 = _S1159 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1166 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S1167 : vec3<f32> = select(r_6.dir, _S1166, _S1163);
                        refracted_4 = (dot(_S1024.smooth_n, _S1167) * _S1025) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S1163)
                {
                    var _S1168 : vec3<f32> = ray_2.origin;
                    var _S1169 : Surface = surface_5;
                    var _S1170 : vec3<f32> = (vec3<f32>(0) - _S1024.smooth_n);
                    var _S1171 : bool = is_inside_5 != refracted_4;
                    var _S1172 : vec3<f32> = select(_S1024.smooth_n, _S1170, _S1171);
                    var _S1173 : vec3<f32> = (normalize((dir_11 - (_S1168 + vec3<f32>(_S1169.geometry_offset) * _S1172))));
                    reconnection_1 = _S1173;
                }
                else
                {
                    reconnection_1 = r_6.dir;
                }
                var _S1174 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S1174)
                {
                    return _S978;
                }
                var _S1175 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S1159;
                wrong_side_0 = false;
                reconnection_1 = _S1175;
            }
            else
            {
                var _S1176 : bool = !_S1080;
                if(_S1176)
                {
                    var _S1177 : f32 = _S1050.x;
                    var _S1178 : f32 = _S1050.y;
                    var _S1179 : vec2<f32> = vec2<f32>(0.0f);
                    var _S1180 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S1024.smooth_n, _S1048, _S1177, _S1178, surface_5.random_state, _S1179);
                    var bsdf_sampled_0 : SampleBSDF = _S1180;
                    var _S1181 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S1048.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1182 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S1181.geometry_n, _S1048, _S1177, _S1178, bsdf_sampled_0.random_state, _S1179);
                        bsdf_sampled_0.unit_direction = _S1182.unit_direction;
                        bsdf_sampled_0.refracted = _S1182.refracted;
                        bsdf_sampled_0.throughput = _S1182.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S1183 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S1181.geometry_n))) * _S1181.geometry_n;
                            bsdf_sampled_0.unit_direction = _S1183;
                        }
                    }
                    var _S1184 : u32 = bsdf_sampled_0.lobe;
                    var _S1185 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S1186 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S1187 : f32 = bsdf_sampled_0.pdf;
                    var _S1188 : f32 = select(_S1187, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S1188;
                    dir_11 = _S1185;
                    lobe_index_0 = _S1184;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1186;
                }
                else
                {
                    dir_11 = r_6.dir;
                    lobe_index_0 = _S1159;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S1105)
            {
                _S1106 = true;
            }
            else
            {
                _S1106 = _S1080;
            }
            var throughput_7 : vec3<f32>;
            var throughput_8 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S1106)
            {
                var _S1189 : vec3<f32> = ray_2.unit_direction;
                var _S1190 : vec3<f32> = ((-(_S1189)));
                var _S1191 : f32 = (sign((_S1025)));
                var _S1192 : vec3<f32> = _S1024.smooth_n * vec3<f32>(_S1191);
                var _S1193 : f32 = dot(_S1192, dir_11);
                var _S1194 : f32 = _S1048.roughness;
                var _S1195 : f32 = _S1194 * _S1194;
                var _S1196 : AnisotropicFrame = anisotropicFrame(_S1048, _S1192);
                var _S1197 : vec3<f32> = reflectedHalf(_S1189, dir_11);
                var _S1198 : bool = lobe_index_0 == u32(1);
                if(_S1198)
                {
                    var _S1199 : vec3<f32> = refractedHalf(_S1189, dir_11, _S1024.smooth_n, _S1050.x, _S1050.y);
                    throughput_7 = _S1199;
                }
                else
                {
                    throughput_7 = _S1197;
                }
                var _S1200 : Surface = surface_5;
                var _S1201 : vec3<f32> = coatHalf(_S1190, _S1192, _S1048, surface_5.random_state);
                var _S1202 : bool = lobe_index_0 == u32(5);
                var _S1203 : vec3<f32> = select(_S1201, throughput_7, _S1202);
                var _S1204 : bool = lobe_index_0 == u32(0);
                if(_S1204)
                {
                    _S1107 = true;
                }
                else
                {
                    _S1107 = lobe_index_0 == u32(6);
                }
                if(_S1107)
                {
                    _S1153 = true;
                }
                else
                {
                    _S1153 = _S1202;
                }
                if(_S1153)
                {
                    var _S1205 : vec3<f32> = sampledHalf(_S1190, _S1192, _S1195, _S1196, _S1200.random_state);
                    throughput_8 = _S1205;
                }
                else
                {
                    throughput_8 = throughput_7;
                }
                var _S1206 : f32 = _S1050.x;
                var _S1207 : f32 = _S1050.y;
                var _S1208 : Weights = lobeWeights(_S1189, _S1190, _S1192, throughput_8, _S1203, _S1196, _S1048, _S1206, _S1207);
                var _S1209 : f32 = abs(_S1025);
                var _S1210 : f32 = vndfPDF(_S1190, throughput_8, _S1192, _S1209, _S1195, _S1196, _S1208.v_dot_h);
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S1211 : f32 = diffusePDF(_S1193, _S1209, _S1048, _S1208);
                        var _S1212 : vec3<f32> = diffuseBSDF(dir_11, _S1192, _S1048, _S1208);
                        density_5 = _S1211;
                        chain_throughput_1 = _S1212;
                    }
                case u32(1):
                    {
                        var _S1213 : f32 = refractPDF(dot(dir_11, throughput_8), _S1210, _S1208, _S1206, _S1207);
                        var _S1214 : vec3<f32> = refractBSDF(dir_11, _S1192, _S1195, _S1196, _S1048, _S1208);
                        density_5 = _S1213;
                        chain_throughput_1 = _S1214;
                    }
                case u32(4):
                    {
                        var _S1215 : f32 = sheenVelvetPDF(_S1193, _S1209, _S1208);
                        var _S1216 : vec3<f32> = sheenVelvetBSDF(dir_11, _S1190, _S1192, _S1048, _S1208);
                        density_5 = _S1215;
                        chain_throughput_1 = _S1216;
                    }
                case u32(5):
                    {
                        var _S1217 : f32 = coatPDF(_S1208);
                        var _S1218 : vec3<f32> = coatBSDF(_S1208);
                        density_5 = _S1217;
                        chain_throughput_1 = _S1218;
                    }
                default :
                    {
                        var _S1219 : f32 = reflectPDF(_S1210, _S1208);
                        var _S1220 : vec3<f32> = reflectBSDF(dir_11, _S1192, _S1195, _S1196, _S1208);
                        density_5 = _S1219;
                        chain_throughput_1 = _S1220;
                    }
                }
                var _S1221 : bool = density_5 > 0.0f;
                if(_S1221)
                {
                    var _S1222 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, _S1200.random_state, _S1198, lobe_index_0, density_5);
                    lobe_2 = _S1222;
                }
            }
            var _S1223 : bool = lobe_index_0 == u32(0);
            if(_S1223)
            {
                _S1107 = true;
            }
            else
            {
                _S1107 = lobe_index_0 == u32(4);
            }
            if(_S1107)
            {
                _S1153 = true;
            }
            else
            {
                _S1153 = lobe_index_0 == u32(6);
            }
            var _S1224 : Material = _S1048;
            var _S1225 : Material = _S1048;
            var _S1226 : bool = lobe_index_0 == u32(5);
            var _S1227 : f32 = select(_S1224.roughness, _S1225.coat_roughness, _S1226);
            var _S1228 : bool = !_S1153;
            if(_S1228)
            {
                var _S1229 : bool = _S1227 == 0.0f;
                if(_S1229)
                {
                    _S1154 = true;
                }
                else
                {
                    var _S1230 : bool = lobe_index_0 == u32(1);
                    if(_S1230)
                    {
                        _S1154 = (_S1050.x) == (_S1050.y);
                    }
                    else
                    {
                        _S1154 = false;
                    }
                }
            }
            else
            {
                _S1154 = false;
            }
            var _S1231 : bool = lobe_index_0 == u32(1);
            if(_S1231)
            {
                straight_0 = (_S1048.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S1232 : bool = isTranslucent_0(_S1048);
            if(_S1232)
            {
                _S1155 = _S1223;
            }
            else
            {
                _S1155 = false;
            }
            if(_S1155)
            {
                _S1156 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S1156 = false;
            }
            var _S1233 : bool;
            if(_S1051)
            {
                _S1233 = !_S1154;
            }
            else
            {
                _S1233 = false;
            }
            var _S1234 : bool;
            if(_S1233)
            {
                _S1234 = !wrong_side_0;
            }
            else
            {
                _S1234 = false;
            }
            var _S1235 : bool;
            if(_S1234)
            {
                var _S1236 : f32 = lobe_2.pdf;
                var _S1237 : vec3<f32> = ray_2.origin;
                var _S1238 : bool = isTranslucent_0(_S1048);
                var _S1239 : vec3<f32> = select(_S1024.smooth_n, _S977, _S1238);
                var _S1240 : vec3<f32> = ray_2.origin;
                var _S1241 : Surface = surface_5;
                var _S1242 : vec3<f32> = (vec3<f32>(0) - _S1024.smooth_n);
                var _S1243 : vec3<f32> = select(_S1024.smooth_n, _S1242, _S1156);
                var _S1244 : NEEVertex = NEEVertex_x24init_0(false, _S1236, _S1237, _S1239, _S1240 + vec3<f32>(_S1241.geometry_offset) * _S1243);
                nee_vertex_0 = _S1244;
            }
            else
            {
                var _S1245 : bool = lobe_index_0 != u32(1);
                if(_S1245)
                {
                    _S1235 = true;
                }
                else
                {
                    _S1235 = (_S1050.x) != (_S1050.y);
                }
                if(_S1235)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S1246 : bool = withinInverseFootprint(lobe_2.pdf, _S1153, prev_0.cos, hit_2.distance, threshold_2);
            var _S1247 : bool = roughLobe(lobe_2.pdf, _S1153, _S1227);
            if(_S1080)
            {
                var _S1248 : bool = !_S1246;
                if(_S1248)
                {
                    return _S978;
                }
                var _S1249 : bool = _S982 != u32(1);
                if(_S1249)
                {
                    _S1235 = _S982 != u32(2);
                }
                else
                {
                    _S1235 = false;
                }
                if(_S1235)
                {
                    var _S1250 : f32 = lobe_2.pdf;
                    var _S1251 : f32 = select(0.0f, _S1250, _S1051);
                    var _S1252 : f32 = escapeWeight_0(_S1251, r_6.dir);
                    if(_S1088)
                    {
                        is_inside_5 = _S988;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S1253 : f32 = select(1.0f, _S1252, is_inside_5);
                    return Shift_x24init_0(throughput_5 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_6.radiance * vec3<f32>(_S1253) / vec3<f32>(r_6.jac), density_3 * lobe_2.pdf / r_6.jac);
                }
                var _S1254 : vec3<f32> = throughput_5 * vec3<f32>(lobe_2.pdf);
                var _S1255 : f32 = density_3 * lobe_2.pdf;
                throughput_7 = _S1254;
                density_5 = _S1255;
            }
            else
            {
                throughput_7 = throughput_5;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S1235 = b_5 <= _S992;
            }
            else
            {
                _S1235 = false;
            }
            var _S1256 : bool;
            if(_S1235)
            {
                _S1256 = _S1023;
            }
            else
            {
                _S1256 = false;
            }
            var _S1257 : bool;
            if(_S1256)
            {
                _S1257 = _S1246;
            }
            else
            {
                _S1257 = false;
            }
            var _S1258 : bool;
            if(_S1257)
            {
                _S1258 = true;
            }
            else
            {
                if(_S1105)
                {
                    _S1258 = !_S1247;
                }
                else
                {
                    _S1258 = false;
                }
            }
            if(_S1258)
            {
                return _S978;
            }
            if(_S1105)
            {
                var _S1259 : vec3<f32> = throughput_7 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1260 : f32 = lobe_2.pdf;
                throughput_8 = _S1259;
                survival_probability_0 = _S1260;
            }
            else
            {
                var _S1261 : vec3<f32> = throughput_7 * max(lobe_2.throughput, _S977);
                throughput_8 = _S1261;
                survival_probability_0 = density_5;
            }
            var _S1262 : bool = !replay_0;
            var _S1263 : bool;
            if(_S1262)
            {
                _S1263 = !_S1067;
            }
            else
            {
                _S1263 = false;
            }
            var _S1264 : bool;
            if(_S1263)
            {
                _S1264 = _S1023;
            }
            else
            {
                _S1264 = false;
            }
            var _S1265 : bool;
            if(_S1264)
            {
                _S1265 = _S1246;
            }
            else
            {
                _S1265 = false;
            }
            if(_S1265)
            {
                chain_0 = here_0;
                var _S1266 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1267 : u32 = select(u32(0), u32(1), _S1051);
                var _S1268 : u32 = (insertBits((_S1266), (_S1267), (u32(21)), (u32(1))));
                chain_0.path = _S1268;
                var _S1269 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S1269;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_8;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1270 : Vertex = Vertex_x24init_0(_S1247, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S1270;
            var _S1271 : f32 = lobe_2.pdf;
            var _S1272 : bool;
            if(_S1231)
            {
                _S1272 = (_S1050.x) == (_S1050.y);
            }
            else
            {
                _S1272 = false;
            }
            var _S1273 : f32 = select(_S1271, sky_pdf_0, _S1272);
            var _S1274 : bool;
            if(refracted_4)
            {
                _S1274 = !_S1156;
            }
            else
            {
                _S1274 = false;
            }
            var is_inside_6 : bool;
            if(_S1274)
            {
                var _S1275 : bool = !is_inside_5;
                is_inside_6 = _S1275;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S1276 : Surface = surface_5;
            var _S1277 : f32 = select(_S1276.geometry_offset, 0.0f, straight_0);
            var _S1278 : vec3<f32> = (vec3<f32>(0) - _S1024.smooth_n);
            var _S1279 : bool = is_inside_6 != _S1156;
            var _S1280 : vec3<f32> = select(_S1024.smooth_n, _S1278, _S1279);
            var _S1281 : vec3<f32> = ray_2.origin + vec3<f32>(_S1277) * _S1280;
            ray_2.origin = _S1281;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_8;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1273;
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
        var _S1282 : bool = !replay_0;
        if(_S1282)
        {
            if(_S1002)
            {
                var _S1283 : vec3<f32> = pathColor(throughput_2 * emission_1, spectral_weight_0, wavelength_6);
                var candidate_6 : Reservoir = chain_0;
                var _S1284 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1285 : bool = _S1284 == u32(1);
                if(_S1285)
                {
                    var _S1286 : vec3<f32> = safeDivide(_S1283, chain_throughput_0);
                    candidate_6.radiance = _S1286;
                }
                var _S1287 : Reservoir = withEnd(candidate_6, u32(2), b_5, _S1283);
                offer(&((*sel_4)), _S1287, _S1283 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S1002)
            {
                _S1105 = true;
            }
            else
            {
                _S1105 = scatter_0;
            }
            if(_S1105)
            {
                var _S1288 : f32 = survivalProbability(abs(throughput_2), density_5);
                survival_probability_0 = _S1288;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1289 : u32 = noiseAddress(r_6.seed, b_5);
            var _S1290 : Random = draw(_S1289, u32(8));
            var _S1291 : bool = survival_probability_0 < (_S1290.value);
            if(_S1291)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1292 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_5 >= _S1292;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1293 : f32 = density_5 * survival_probability_0;
            density_2 = _S1293;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1294 : Ray = ray_2;
        var _S1295 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S1105 = _S1081;
        }
        else
        {
            _S1105 = false;
        }
        if(_S1105)
        {
            wrong_side_0 = _S981 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1296 : f32 = select(4.294967296e+09f, _S1295, wrong_side_0);
        var _S1297 : Hit;
        if(straight_0)
        {
            _S1297 = hit_2;
        }
        else
        {
            _S1297 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1298 : Hit = (traverseInstanceBVH((_S1294), (_S1008), (_S1296), (_S1297)));
        hit_2 = _S1298;
        if(replay_0)
        {
            refracted_4 = _S1081;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S1106 = _S981 == u32(1);
        }
        else
        {
            _S1106 = false;
        }
        if(_S1106)
        {
            _S1107 = (hit_2.instance_index) == (_S993.instance_index);
        }
        else
        {
            _S1107 = false;
        }
        if(_S1107)
        {
            _S1153 = (hit_2.triangle_index) == (_S993.triangle_index);
        }
        else
        {
            _S1153 = false;
        }
        if(_S1153)
        {
            hit_2.uv = _S993.uv;
            var _S1299 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1299;
        }
        if(replay_0)
        {
            _S1154 = _S1081;
        }
        else
        {
            _S1154 = false;
        }
        if(_S1154)
        {
            _S1155 = _S981 == u32(3);
        }
        else
        {
            _S1155 = false;
        }
        if(_S1155)
        {
            _S1156 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S1156 = false;
        }
        if(_S1156)
        {
            return _S978;
        }
        var _S1300 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1300)
        {
            var _S1301 : bool = !nee_vertex_0.none;
            var _S1302 : f32 = select(0.0f, sky_pdf_0, _S1301);
            var _S1303 : f32 = escapeWeight_0(_S1302, ray_2.unit_direction);
            var _S1304 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1305 : vec3<f32> = pathColor(throughput_2 * _S1304, spectral_weight_0, wavelength_6);
            if(replay_0)
            {
                if(_S1081)
                {
                    is_inside_5 = _S981 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S1305 * vec3<f32>(_S1303) / vec3<f32>(r_6.jac), density_2 / r_6.jac);
                }
                if(_S991)
                {
                    is_inside_5 = _S988;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_5 == _S979;
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
                    return Shift_x24init_0(_S1305 * vec3<f32>(_S1303), 1.0f);
                }
                return _S978;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1306 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1307 : bool = _S1306 == u32(1);
            if(_S1307)
            {
                var _S1308 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1309 : bool = _S1308 == b_5;
                var _S1310 : f32 = select(_S1303, 1.0f, _S1309);
                var _S1311 : vec3<f32> = safeDivide(_S1305 * vec3<f32>(_S1310), chain_throughput_0);
                candidate_7.radiance = _S1311;
            }
            else
            {
                var _S1312 : bool = prev_0.rough;
                if(_S1312)
                {
                    var _S1313 : u32 = (insertBits((_S1001), (b_5 + u32(1)), (u32(5)), (u32(5))));
                    var _S1314 : u32 = (insertBits((_S1313), (u32(3)), (u32(10)), (u32(2))));
                    var _S1315 : u32 = (insertBits((_S1314), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1316 : bool = prev_0.inside;
                    var _S1317 : u32 = select(u32(0), u32(1), _S1316);
                    var _S1318 : u32 = (insertBits((_S1315), (_S1317), (u32(22)), (u32(1))));
                    candidate_7.path = _S1318;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1319 : vec3<f32> = _S1305 * vec3<f32>(_S1303);
            var _S1320 : Reservoir = withEnd(candidate_7, u32(3), b_5, _S1319);
            offer(&((*sel_4)), _S1320, _S1319 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1321 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1321;
        var _S1322 : u32 = b_5 + u32(1);
        b_5 = _S1322;
    }
    return _S978;
}

fn shift_0( dom_5 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S1323 : vec3<f32> = vec3<f32>(0.0f);
    var _S1324 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1323, 0.0f, vec4<u32>(u32(0)), _S1323, _S1323), 0.0f, _S1323, u32(0));
    var sel_5 : Selection = _S1324;
    var _S1325 : bool = (r_7.w) <= 0.0f;
    if(_S1325)
    {
        return Shift_x24init_0(_S1323, 0.0f);
    }
    var _S1326 : Shift = walk_0(dom_5, r_7, true, 0.0f, &(sel_5));
    return _S1326;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1327 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1328 : bool = _S1327 != u32(4294967295);
    if(_S1328)
    {
        var _S1329 : vec2<i32> = vec2<i32>((vec2<u32>(_S1327, (_S1327 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1330 : vec3<f32> = vec3<f32>(0.0f);
        var _S1331 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1330, _S1330, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1330, 0.0f, vec4<u32>(u32(0)), _S1330, _S1330));
        var shift_job_0 : ShiftJob = _S1331;
        var _S1332 : u32 = (_S1327 >> (u32(28)));
        var _S1333 : bool = spatialJob_0(_S1329, _S1332, &(shift_job_0));
        var _S1334 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1329), (_S1332), (vec4<u32>((bitcast<vec3<u32>>((_S1334.f))), (bitcast<u32>((_S1334.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1335 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1336 : array<u32, i32(3)>;
    spatialBins_0(_S1335, &(_S1336));
    var _S1337 : array<u32, i32(3)> = _S1336;
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
        var _S1338 : bool = (_S1337[t_16]) == u32(40);
        if(_S1338)
        {
            textureStore(shift_data_out, (_S1335), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1335, _S1337, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1339 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1339));
    countShifts_0(_S1339, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1340 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1341 : bool = _S1340 != u32(4294967295);
    if(_S1341)
    {
        var _S1342 : vec2<i32> = vec2<i32>((vec2<u32>(_S1340, (_S1340 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1343 : vec3<f32> = vec3<f32>(0.0f);
        var _S1344 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1343, _S1343, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1343, 0.0f, vec4<u32>(u32(0)), _S1343, _S1343));
        var shift_job_1 : ShiftJob = _S1344;
        var _S1345 : u32 = (_S1340 >> (u32(28)));
        var _S1346 : bool = temporalJob_0(_S1342, _S1345, &(shift_job_1));
        var _S1347 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1342), (_S1345), (vec4<u32>((bitcast<vec3<u32>>((_S1347.f))), (bitcast<u32>((_S1347.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1348 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1349 : array<u32, i32(3)>;
    temporalBins_0(_S1348, &(_S1349));
    var _S1350 : array<u32, i32(3)> = _S1349;
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
        var _S1351 : bool = (_S1350[t_18]) == u32(40);
        if(_S1351)
        {
            textureStore(temporal_shifts_out, (_S1348), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1348, _S1350, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1352 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1352));
    countShifts_0(_S1352, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1353 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1353;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1354 : f32 = c_3 * p_c_1;
    var _S1355 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1354 / (_S1354 + c_t_0 * g_previous_0), _S1355 / (_S1355 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1356 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1357 : vec3<f32> = vec3<f32>(0.0f);
    var _S1358 : Domain = Domain_x24init_0(_S1357, _S1357, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1358;
    var _S1359 : bool = (currentDomain((_S1356), &(dom_6)));
    var _S1360 : bool = !_S1359;
    if(_S1360)
    {
        storeReservoir(reservoir_temp_out, (_S1356), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1357, 0.0f, vec4<u32>(u32(0)), _S1357, _S1357)), (dom_6.hit));
        return;
    }
    var _S1361 : Reservoir = (loadReservoir(reservoir_initial, (_S1356)));
    var _S1362 : vec2<i32> = temporalNeighbor_0(_S1356, dom_6);
    var _S1363 : bool = (_S1362.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1363)
    {
        var _S1364 : Reservoir = (loadReservoir(reservoir_prev, (_S1362)));
        var _S1365 : vec4<u32> = (textureLoad(duplication, (_S1362), 0, 0));
        var _S1366 : f32 = (bitcast<f32>((_S1365.x)));
        var _S1367 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1368 : bool = _S1367 == u32(1);
        var _S1369 : f32 = select(0.0f, _S1366, _S1368);
        var _S1370 : f32 = confidenceCap(_S1369);
        var _S1371 : f32 = min(_S1364.c, _S1370);
        var _S1372 : vec4<u32> = (textureLoad(temporal_shifts, (_S1356), (u32(0)), 0));
        var _S1373 : vec4<f32> = (bitcast<vec4<f32>>((_S1372)));
        var _S1374 : vec4<f32> = vec4<f32>(_S1361.f, 1.0f);
        var _S1375 : Domain = (previousDomain((_S1362)));
        var _S1376 : bool = sameDomain_0(_S1375, dom_6);
        var _S1377 : bool = !_S1376;
        var to_previous_0 : vec4<f32>;
        if(_S1377)
        {
            var _S1378 : vec4<u32> = (textureLoad(temporal_shifts, (_S1356), (u32(1)), 0));
            var _S1379 : vec4<f32> = (bitcast<vec4<f32>>((_S1378)));
            to_previous_0 = _S1379;
        }
        else
        {
            to_previous_0 = _S1374;
        }
        var _S1380 : f32 = resamplingTarget(_S1361.f);
        var _S1381 : f32 = resamplingTarget(_S1364.f);
        var _S1382 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1357, 0.0f, vec4<u32>(u32(0)), _S1357, _S1357), 0.0f, _S1357, u32(0));
        var sel_6 : Selection = _S1382;
        var _S1383 : u32 = (uniforms_uint.frame);
        var _S1384 : u32 = hash(_S1383);
        var _S1385 : u32 = global_invocation_id_7.x;
        var _S1386 : vec2<u32> = (uniforms_uint.render_size);
        var _S1387 : u32 = stream(_S1384, _S1385 + _S1386.x * global_invocation_id_7.y);
        var _S1388 : u32 = stream(_S1387, u32(194));
        sel_6.random_state = _S1388;
        var _S1389 : f32 = resamplingTarget(to_previous_0.xyz);
        var _S1390 : vec3<f32> = _S1373.xyz;
        var _S1391 : f32 = resamplingTarget(_S1390);
        var _S1392 : vec2<f32> = temporalWeights(_S1361.c, _S1380, _S1371, _S1381, _S1389, _S1391);
        offerShifted(&(sel_6), _S1361, Shift_x24init_0(_S1361.f, 1.0f), _S1392.x);
        offerShifted(&(sel_6), _S1364, Shift_x24init_0(_S1390, _S1373.w), _S1392.y);
        var _S1393 : Reservoir = finalize(sel_6, _S1361.c + _S1371);
        r_8 = _S1393;
    }
    else
    {
        r_8 = _S1361;
    }
    storeReservoir(reservoir_temp_out, (_S1356), (r_8), (dom_6.hit));
    return;
}

fn noiseOrigin( p_12 : vec2<u32>,  k_1 : u32) -> u32
{
    var _S1394 : u32 = ((((p_12.x) >> (u32(11)))) | ((((((p_12.y) >> (u32(11)))) << (u32(4))))));
    var _S1395 : vec2<u32> = noiseOffset(u32(8192) + ((k_1 >> (u32(10)))) + ((_S1394 << (u32(20)))));
    var _S1396 : vec2<u32> = ((p_12 + _S1395) & (vec2<u32>(u32(2047))));
    return ((((_S1396.x) | ((((_S1396.y) << (u32(11))))))) | (((((k_1 & (u32(1023)))) << (u32(22))))));
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1397 : vec2<u32> = global_invocation_id_8.xy;
    var _S1398 : vec2<i32> = vec2<i32>(_S1397);
    var _S1399 : vec3<f32> = vec3<f32>(0.0f);
    var _S1400 : Domain = Domain_x24init_0(_S1399, _S1399, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1400;
    var _S1401 : bool = (currentDomain((_S1398), &(dom_7)));
    var _S1402 : bool = !_S1401;
    if(_S1402)
    {
        storeReservoir(reservoir_initial_out, (_S1398), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1399, 0.0f, vec4<u32>(u32(0)), _S1399, _S1399)), (dom_7.hit));
        return;
    }
    var _S1403 : u32 = (uniforms_uint.frame);
    var _S1404 : u32 = hash(_S1403);
    var _S1405 : u32 = global_invocation_id_8.x;
    var _S1406 : vec2<u32> = (uniforms_uint.render_size);
    var _S1407 : u32 = global_invocation_id_8.y;
    var _S1408 : u32 = stream(_S1404, _S1405 + _S1406.x * _S1407);
    var _S1409 : vec2<u32> = (uniforms_uint.render_size);
    var _S1410 : u32 = stream(_S1405 + _S1409.x * _S1407, u32(512));
    var _S1411 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1399, 0.0f, vec4<u32>(u32(0)), _S1399, _S1399);
    var _S1412 : Selection = Selection_x24init_0(_S1411, 0.0f, _S1399, u32(0));
    var initial_0 : Selection = _S1412;
    var _S1413 : u32 = stream(_S1408, u32(193));
    initial_0.random_state = _S1413;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1414 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1414)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1411;
        var _S1415 : u32 = (uniforms_uint.frame);
        var _S1416 : u32 = (uniforms_uint.samples);
        var _S1417 : u32 = _S1415 * _S1416 + i_10;
        var _S1418 : u32 = noiseOrigin(_S1397, _S1417);
        r_9.seed = _S1418;
        var _S1419 : u32 = (insertBits((u32(0)), (u32(1)), (u32(24)), (u32(1))));
        var _S1420 : u32 = (insertBits((_S1419), (((_S1410 + _S1417 * u32(2654435769)) >> (u32(25)))), (u32(25)), (u32(7))));
        r_9.path = _S1420;
        var _S1421 : u32 = (uniforms_uint.samples);
        var _S1422 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1421), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1423 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1398), (_S1423), (dom_7.hit));
    return;
}

fn normal_distribution( state_4 : u32) -> Random
{
    var _S1424 : Random = pcg(state_4);
    var _S1425 : Random = pcg(_S1424.state);
    var _S1426 : f32 = 6.28318548202514648f * _S1424.value;
    var _S1427 : f32 = sqrt(-2.0f * clamp(log(_S1425.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1425.state, _S1427 * cos(_S1426));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_5 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1428 : RandomSphere;
    _S1428.state = state_5;
    _S1428.value = value_1;
    return _S1428;
}

fn random_sphere( state_6 : u32) -> RandomSphere
{
    var _S1429 : Random = normal_distribution(state_6);
    var _S1430 : Random = normal_distribution(_S1429.state);
    var _S1431 : Random = normal_distribution(_S1430.state);
    var _S1432 : vec3<f32> = (normalize((vec3<f32>(_S1429.value, _S1430.value, _S1431.value))));
    return RandomSphere_x24init_0(_S1431.state, _S1432);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1433 : vec3<f32> = p1_0 - p0_0;
    var _S1434 : vec3<f32> = p2_0 - p0_0;
    var _S1435 : vec2<f32> = uv1_0 - uv0_0;
    var _S1436 : vec2<f32> = uv2_0 - uv0_0;
    var _S1437 : f32 = _S1435.x;
    var _S1438 : f32 = _S1436.y;
    var _S1439 : f32 = _S1435.y;
    var _S1440 : f32 = _S1436.x;
    var _S1441 : f32 = _S1437 * _S1438 - _S1439 * _S1440;
    var _S1442 : f32 = 1.0f / _S1441;
    var _S1443 : vec3<f32> = vec3<f32>(_S1442);
    var t_20 : vec3<f32> = (_S1433 * vec3<f32>(_S1438) - _S1434 * vec3<f32>(_S1439)) * _S1443;
    var _S1444 : vec3<f32> = (_S1434 * vec3<f32>(_S1437) - _S1433 * vec3<f32>(_S1440)) * _S1443;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1445 : bool = (dot(cross(n_9, t_21), _S1444)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1445)
    {
        var _S1446 : vec3<f32> = ((-(t_21)));
        t_22 = _S1446;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1447 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1447, n_9);
}

fn tangentToWorldNormalMap( v_9 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_9)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1448 : vec3<f32> = t1_0 - t0_0;
    var _S1449 : vec3<f32> = t2_2 - t0_0;
    var _S1450 : vec3<f32> = t2_2 - t1_0;
    var _S1451 : f32 = min(length(_S1448), min(length(_S1449), length(_S1450)));
    var _S1452 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1453 : vec3<f32> = (normalize((n0_0)));
    var _S1454 : f32 = dot(geometry_n_5, _S1453);
    var _S1455 : vec3<f32> = (normalize((n1_0)));
    var _S1456 : f32 = dot(geometry_n_5, _S1455);
    var _S1457 : vec3<f32> = (normalize((n2_0)));
    var _S1458 : vec3<f32> = acos(abs(vec3<f32>(_S1454, _S1456, dot(geometry_n_5, _S1457))));
    var _S1459 : vec3<f32> = clamp(tan(_S1458), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1452 * _S1459, uvw_0), 0.0f, _S1451 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_10 : vec3<f32>,  material_22 : Material) -> vec3<f32>
{
    var _S1460 : vec3<f32> = ((-(dir_12)));
    var _S1461 : f32 = (sign((dot(n_10, _S1460))));
    var _S1462 : vec3<f32> = n_10 * vec3<f32>(_S1461);
    var _S1463 : AnisotropicFrame = anisotropicFrame(material_22, _S1462);
    var _S1464 : bool = (_S1463.alphas.x) > 0.0f;
    if(_S1464)
    {
        var _S1465 : f32 = material_22.transmission * (1.0f - material_22.metallic);
        var _S1466 : vec3<f32> = ((-(_S1462)));
        var _S1467 : vec3<f32> = anisotropicLocal(dir_12, _S1463.tangent, _S1466);
        var _S1468 : f32 = anisotropicG1(_S1467, _S1463.alphas);
        return vec3<f32>((_S1465 * _S1468)) * material_22.albedo;
    }
    var _S1469 : f32 = material_22.transmission * (1.0f - material_22.metallic);
    var _S1470 : f32 = material_22.roughness;
    var _S1471 : f32 = smithG1(_S1470 * _S1470, abs(dot(n_10, dir_12)));
    return vec3<f32>((_S1469 * _S1471)) * material_22.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_23 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var through_1 : vec3<f32>;
    if((material_23.ior) == 1.0f)
    {
        var _S1472 : vec3<f32> = straightThrough(toward_1, n_11, material_23);
        through_1 = _S1472;
    }
    else
    {
        through_1 = vec3<f32>(0.0f);
    }
    var _S1473 : bool = (material_23.coat) > 0.0f;
    if(_S1473)
    {
        var _S1474 : vec3<f32> = coatNormal(material_23, n_11);
        var _S1475 : f32 = fresnel(abs(dot(_S1474, toward_1)), 1.0f, max(material_23.coat_ior, 1.00999999046325684f));
        var _S1476 : vec3<f32> = (mix((vec3<f32>(1.0f)), (vec3<f32>((1.0f - _S1475)) * material_23.coat_tint), (material_23.coat)));
        var through_2 : vec3<f32> = through_1 * _S1476;
        through_1 = through_2;
    }
    return through_1 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1477 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1477;
}

fn shift_hook( dom_9 : Domain,  r_11 : Reservoir) -> Shift
{
    var _S1478 : Shift = shift_0(dom_9, r_11);
    return _S1478;
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
        var _S1479 : u32;
        if(i_12 < u32(2))
        {
            _S1479 = x_3;
        }
        else
        {
            _S1479 = ((x_3 + size_0 / u32(2)) & ((size_0 - u32(1))));
        }
        var l_4 : u32 = _S1479;
        var r_12 : u32 = y_1;
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
            var _S1480 : u32 = hash((((((r_12 ^ (((t_23 << (u32(16))))))) ^ (((k_2 << (u32(28))))))) ^ (((((i_12 & (u32(1)))) << (u32(31)))))));
            var _S1481 : u32 = (l_4 ^ (((_S1480 & ((size_0 - u32(1)))))));
            var k_3 : u32 = k_2 + u32(1);
            l_4 = r_12;
            r_12 = _S1481;
            k_2 = k_3;
        }
        var _S1482 : u32 = l_4 + r_12 * size_0;
        var _S1483 : u32 = size_0 * size_0;
        var _S1484 : u32;
        if(_S1483 >= u32(65536))
        {
            var _S1485 : u32 = _S1482 / (_S1483 / u32(65536));
            _S1484 = _S1485;
        }
        else
        {
            var _S1486 : u32 = u32(65536) / _S1483;
            _S1484 = _S1482 * _S1486;
        }
        ranks_0[i_12] = _S1484;
        var i_13 : u32 = i_12 + u32(1);
        i_12 = i_13;
    }
    var _S1487 : bool = (ranks_0[i32(0)]) == u32(65535);
    var _S1488 : bool;
    if(_S1487)
    {
        _S1488 = (ranks_0[i32(1)]) == u32(65535);
    }
    else
    {
        _S1488 = false;
    }
    var _S1489 : bool = (ranks_0[i32(2)]) == u32(65535);
    var _S1490 : bool;
    if(_S1489)
    {
        _S1490 = (ranks_0[i32(3)]) == u32(65535);
    }
    else
    {
        _S1490 = false;
    }
    if(_S1488)
    {
        _S1488 = (ranks_0[i32(3)]) != u32(65535);
    }
    else
    {
        _S1488 = false;
    }
    if(_S1488)
    {
        _S1488 = true;
    }
    else
    {
        if(_S1490)
        {
            _S1488 = (ranks_0[i32(1)]) != u32(65535);
        }
        else
        {
            _S1488 = false;
        }
    }
    var _S1491 : u32 = ranks_0[i32(0)];
    if(_S1488)
    {
        i_12 = ranks_0[i32(3)];
    }
    else
    {
        i_12 = ranks_0[i32(1)];
    }
    return (_S1491 | (((i_12 << (u32(16))))));
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

