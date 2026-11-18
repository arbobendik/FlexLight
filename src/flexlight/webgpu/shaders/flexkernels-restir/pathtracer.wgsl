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

fn Random_x24init_0( state_0 : u32,  value_0 : f32) -> Random
{
    var _S219 : Random;
    _S219.state = state_0;
    _S219.value = value_0;
    return _S219;
}

fn pcg( state_1 : u32) -> Random
{
    var _S220 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S221 : u32 = hash(state_1);
    return Random_x24init_0(_S220, f32(_S221) / 4.294967296e+09f);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S222 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S223 : vec2<u32> = _S222 - vec2<u32>(u32(1), u32(0));
    var _S224 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S225 : vec2<u32> = min(vec2<u32>(_S224 * vec2<f32>(_S223)), _S223 - vec2<u32>(u32(1)));
    var _S226 : vec4<f32> = (textureLoad(environment_cdf, (_S225), 0));
    var _S227 : f32 = _S226.y;
    var _S228 : u32 = _S223.x;
    var _S229 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S228, _S225.y)), 0));
    var _S230 : f32 = _S227 * _S229.y;
    return _S230 * f32(_S228 * _S223.y) / (19.73921012878417969f * length(dir_3.xz));
}

struct AnisotropicFrame
{
     tangent : vec3<f32>,
     alphas : vec2<f32>,
};

fn AnisotropicFrame_x24init_0( tangent_0 : vec3<f32>,  alphas_0 : vec2<f32>) -> AnisotropicFrame
{
    var _S231 : AnisotropicFrame;
    _S231.tangent = tangent_0;
    _S231.alphas = alphas_0;
    return _S231;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S232 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S232)
    {
        const _S233 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S233;
    }
    else
    {
        a_2 = a_1;
    }
    var _S234 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S235 : vec3<f32> = cross(n_1, _S234);
    return vec3<f32>(v_0.x) * _S234 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S235;
}

fn anisotropicFrame( material_0 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S236 : f32 = material_0.roughness;
    var _S237 : f32 = _S236 * _S236;
    var _S238 : bool = (material_0.anisotropy) == 0.0f;
    var _S239 : bool;
    if(_S238)
    {
        _S239 = true;
    }
    else
    {
        _S239 = !(_S237 > 0.0f);
    }
    if(_S239)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S240 : vec3<f32> = material_0.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_0.tangent));
    var _S241 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S242 : bool = (dot(_S240, _S240)) > 0.0f;
    var _S243 : vec3<f32> = select(_S241, _S240, _S242);
    var _S244 : vec3<f32> = (normalize((_S243)));
    var _S245 : f32 = 6.28318548202514648f * material_0.anisotropic_rotation;
    var _S246 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_0.anisotropy));
    var _S247 : f32 = 1.0f / _S246;
    var _S248 : bool = (material_0.anisotropy) < 0.0f;
    var _S249 : f32 = select(_S246, _S247, _S248);
    return AnisotropicFrame_x24init_0(_S244 * vec3<f32>(cos(_S245)) + cross(n_i_0, _S244) * vec3<f32>(sin(_S245)), vec2<f32>(_S237 / _S249, _S237 * _S249));
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

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  p_sheen_velvet_0 : f32,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_1 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S250 : BSDFLobes;
    _S250.v_dot_h = v_dot_h_0;
    _S250.n_dot_h = n_dot_h_0;
    _S250.refracted = refracted_1;
    _S250.F = F_0;
    _S250.F_greyscale = F_greyscale_0;
    _S250.reflect_weight = reflect_weight_0;
    _S250.diffuse_weight = diffuse_weight_0;
    _S250.refract_weight = refract_weight_0;
    _S250.p_diffuse = p_diffuse_0;
    _S250.p_reflect = p_reflect_0;
    _S250.p_refract = p_refract_0;
    _S250.translucent_share = translucent_share_0;
    _S250.sheen = sheen_0;
    _S250.p_sheen_velvet = p_sheen_velvet_0;
    _S250.view = view_1;
    _S250.tangent = tangent_1;
    _S250.alphas = alphas_1;
    _S250.visible = visible_0;
    return _S250;
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S251 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S252 : f32 = _S251.x;
    var _S253 : f32 = _S251.y;
    var _S254 : f32 = _S252 * _S252 + _S253 * _S253;
    const _S255 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S256 : vec3<f32> = vec3<f32>(- _S253, _S252, 0.0f);
    var _S257 : f32 = (inverseSqrt((_S254)));
    var _S258 : vec3<f32> = _S256 * vec3<f32>(_S257);
    var _S259 : bool = _S254 > 0.0f;
    var _S260 : vec3<f32> = select(_S255, _S258, _S259);
    var _S261 : vec3<f32> = cross(_S251, _S260);
    var _S262 : f32 = sqrt(U1_0);
    var _S263 : f32 = 6.28318548202514648f * U2_0;
    var _S264 : f32 = _S262 * cos(_S263);
    var t2_0 : f32 = _S262 * sin(_S263);
    var _S265 : f32 = 0.5f * (1.0f + _S251.z);
    var t2_1 : f32 = (1.0f - _S265) * sqrt(max(0.0f, 1.0f - _S264 * _S264)) + _S265 * t2_0;
    var _S266 : vec3<f32> = vec3<f32>(_S264) * _S260 + vec3<f32>(t2_1) * _S261;
    var _S267 : f32 = ((_S264));
    var _S268 : f32 = ((_S264));
    var _S269 : vec3<f32> = _S266 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S267 * _S268 - t2_1 * t2_1))) * _S251;
    var _S270 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S269.x, alpha_0 * _S269.y, max(0.0f, _S269.z)))));
    return _S270;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S271 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S271)
    {
        const _S272 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S272;
    }
    else
    {
        a_4 = a_3;
    }
    var _S273 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S274 : vec3<f32> = cross(n_3, _S273);
    return vec3<f32>(dot(v_1, _S273), dot(v_1, n_3), dot(v_1, _S274));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S275 : Random = pcg((*random_state_0));
    var _S276 : Random = pcg(_S275.state);
    (*random_state_0) = _S276.state;
    var _S277 : f32 = frame_0.alphas.x;
    var _S278 : bool = _S277 > 0.0f;
    if(_S278)
    {
        var _S279 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S280 : f32 = frame_0.alphas.y;
        var _S281 : vec3<f32> = (normalize((vec3<f32>(_S277 * _S279.x, _S280 * _S279.y, _S279.z))));
        var _S282 : vec3<f32> = sampleGGXVNDF(_S281, 1.0f, _S275.value, _S276.value);
        var _S283 : vec3<f32> = (normalize((vec3<f32>(_S277 * _S282.x, _S280 * _S282.y, _S282.z))));
        return vec3<f32>(_S283.x) * frame_0.tangent + vec3<f32>(_S283.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S283.z) * n_i_1;
    }
    var _S284 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S285 : vec3<f32> = sampleGGXVNDF(_S284.xzy, alpha_1, _S275.value, _S276.value);
    var _S286 : vec3<f32> = _S285.xzy;
    var _S287 : vec3<f32> = tangentToWorld(_S286, n_i_1);
    return _S287;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_1 : Material,  random_state_1 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_1;
    var _S288 : vec3<f32> = ((-(in_dir_0)));
    var _S289 : f32 = (sign((dot(n_4, _S288))));
    var _S290 : f32 = material_1.roughness;
    var _S291 : vec3<f32> = sampleHalfVector(_S288, n_4 * vec3<f32>(_S289), _S290 * _S290, frame_1, &(state_2));
    return _S291;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  eta_i_0 : f32,  eta_o_0 : f32) -> vec3<f32>
{
    var _S292 : vec3<f32> = ((-(in_dir_1)));
    var _S293 : vec3<f32> = ((-(vec3<f32>(eta_i_0) * _S292 + vec3<f32>(eta_o_0) * out_dir_0)));
    var _S294 : vec3<f32> = (normalize((_S293)));
    var _S295 : f32 = (sign((dot(n_5, _S292))));
    var _S296 : f32 = (sign((dot(_S293, n_5 * vec3<f32>(_S295)))));
    return _S294 * vec3<f32>(_S296);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S297 : vec3<f32> = ((-(in_dir_2)));
    var _S298 : vec3<f32> = (normalize((_S297 + out_dir_1)));
    return _S298;
}

fn fresnel( cos_theta_0 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> f32
{
    var _S299 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S300 : f32 = eta_i_1 / eta_o_1 * _S299;
    var _S301 : bool = _S300 < 1.0f;
    var kr_0 : f32;
    if(_S301)
    {
        var _S302 : f32 = sqrt(max(0.0f, 1.0f - _S300 * _S300));
        var _S303 : f32 = eta_o_1 * cos_theta_0;
        var _S304 : f32 = eta_i_1 * _S302;
        var _S305 : f32 = (_S303 - _S304) / (_S303 + _S304);
        var _S306 : f32 = eta_i_1 * cos_theta_0;
        var _S307 : f32 = eta_o_1 * _S302;
        var _S308 : f32 = (_S306 - _S307) / (_S306 + _S307);
        var _S309 : f32 = (_S305 * _S305 + _S308 * _S308) / 2.0f;
        kr_0 = _S309;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S310 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S310 / (_S310 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S310)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S311 : f32 = alphas_3.x;
    var _S312 : f32 = h_0.x / _S311;
    var _S313 : f32 = alphas_3.y;
    var _S314 : f32 = h_0.y / _S313;
    var _S315 : f32 = h_0.z;
    var _S316 : f32 = _S312 * _S312 + _S314 * _S314 + _S315 * _S315;
    return 1.0f / max(3.14159274101257324f * _S311 * _S313 * _S316 * _S316, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_2 : Material,  eta_i_2 : f32,  eta_o_2 : f32,  frame_2 : AnisotropicFrame) -> BSDFLobes
{
    var _S317 : f32 = dot(ggx_n_0, v_3);
    var _S318 : f32 = dot(n_i_2, ggx_n_0);
    var _S319 : f32 = eta_i_2 / eta_o_2;
    var _S320 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S319))));
    var _S321 : f32 = min(sqrt(material_2.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S322 : f32 = _S321 * _S321;
    var _S323 : f32 = (1.0f + _S321) / (1.0f - _S321);
    var _S324 : f32 = abs(_S317);
    var _S325 : bool = eta_i_2 > eta_o_2;
    var sheen_component_0 : f32;
    if(_S325)
    {
        sheen_component_0 = _S323;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S325)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S323;
    }
    var _S326 : f32 = fresnel(_S324, sheen_component_0, visible_1);
    var _S327 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S317 * _S317)) >= (eta_o_2 * eta_o_2);
    var _S328 : vec3<f32>;
    if(_S327)
    {
        _S328 = vec3<f32>(1.0f);
    }
    else
    {
        var _S329 : vec3<f32> = material_2.specular_tint * vec3<f32>(_S322);
        _S328 = _S329 + (vec3<f32>(1.0f) - _S329) * vec3<f32>((_S326 - _S322)) / vec3<f32>((1.0f - _S322));
    }
    var _S330 : vec3<f32> = vec3<f32>(1.0f);
    var _S331 : vec3<f32> = vec3<f32>(0.0f);
    var _S332 : f32 = rgb_to_greyscale(material_2.sheen);
    var _S333 : bool = _S332 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S333)
    {
        var _S334 : f32 = clamp(sqrt(max(dot(n_i_2, v_3), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S335 : u32 = min(u32(_S334), u32(22));
        var least_0 : f32 = sqrt(0.05000000074505806f);
        var _S336 : f32 = sqrt(0.10000000149011612f);
        var _S337 : bool = (material_2.velvet) > 0.0f;
        var _S338 : f32 = select(least_0, _S336, _S337);
        var _S339 : f32 = (clamp(sqrt(max(material_2.sheen_roughness, 0.0f)), _S338, 1.0f) - _S338) / (1.0f - _S338) * 23.0f;
        var _S340 : u32 = min(u32(_S339), u32(22));
        var _S341 : u32 = _S335 * u32(24) + _S340;
        var _S342 : f32 = _S334 - f32(_S335);
        var _S343 : f32 = _S339 - f32(_S340);
        var _S344 : u32 = _S341 + u32(24);
        var a_5 : f32 = SHEEN_ALBEDO_0[_S341] + (SHEEN_ALBEDO_0[_S344] - SHEEN_ALBEDO_0[_S341]) * _S342;
        var _S345 : u32 = _S341 + u32(1);
        var _S346 : u32 = _S344 + u32(1);
        var b_1 : f32 = SHEEN_ALBEDO_0[_S345] + (SHEEN_ALBEDO_0[_S346] - SHEEN_ALBEDO_0[_S345]) * _S342;
        var _S347 : f32 = exp(a_5 + (b_1 - a_5) * _S343);
        if(_S337)
        {
            var a_6 : f32 = VELVET_ALBEDO_0[_S341] + (VELVET_ALBEDO_0[_S344] - VELVET_ALBEDO_0[_S341]) * _S342;
            var b_2 : f32 = VELVET_ALBEDO_0[_S345] + (VELVET_ALBEDO_0[_S346] - VELVET_ALBEDO_0[_S345]) * _S342;
            var _S348 : f32 = a_6 + (b_2 - a_6) * _S343;
            sheen_component_0 = _S348;
        }
        else
        {
            sheen_component_0 = _S347;
        }
        var _S349 : f32 = min(sheen_component_0, 1.0f);
        var _S350 : vec3<f32> = vec3<f32>(1.0f) - material_2.sheen * vec3<f32>(_S349);
        var _S351 : f32 = rgb_to_greyscale(material_2.sheen);
        var _S352 : f32 = _S351 * _S349;
        var _S353 : vec3<f32> = material_2.sheen / vec3<f32>(max(sheen_component_0, 1.0f));
        scale_0 = _S350;
        sheen_component_0 = _S352;
        sheen_1 = _S353;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S330;
        sheen_component_0 = 0.0f;
        sheen_1 = _S331;
        view_2 = _S331;
    }
    var _S354 : f32 = frame_2.alphas.x;
    var _S355 : f32 = sqrt(min(_S354, frame_2.alphas.y));
    var _S356 : bool = _S354 > 0.0f;
    var _S357 : f32 = select(material_2.roughness, _S355, _S356);
    var _S358 : f32 = _S357 * _S357;
    var _S359 : f32 = pow(_S358, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S358) / (1.0f + 1.28094995021820068f * _S358);
    var _S360 : bool = _S358 > 0.0f;
    var _S361 : f32 = select(0.0f, _S359, _S360);
    var _S362 : f32 = clamp(dot(n_i_2, v_3), 0.0f, 1.0f);
    var _S363 : f32 = _S358 * _S357;
    var _S364 : f32 = min(1.00064504146575928f - _S357 * (0.00375499995425344f + _S362 * (-0.04133399948477745f + _S362 * (-0.90938502550125122f + _S362 * 0.35275399684906006f))) - _S358 * (0.27602800726890564f + _S362 * (1.27023398876190186f + _S362 * 0.04740000143647194f)) - _S363 * (0.31452900171279907f - _S362 * 0.34830701351165771f) + _S363 * _S357 * 0.27229699492454529f, 1.0f);
    var _S365 : vec3<f32> = vec3<f32>(1.0f);
    var _S366 : vec3<f32> = min(_S365 / (_S365 - material_2.albedo * vec3<f32>(_S361)), vec3<f32>((1.0f / max(_S364, 0.0000152587890625f))));
    var _S367 : vec3<f32> = (mix((_S328), (material_2.albedo * _S366), (material_2.metallic)));
    var F_1 : vec3<f32> = _S367 * scale_0;
    var _S368 : f32 = rgb_to_greyscale(F_1);
    var _S369 : f32 = 1.0f - material_2.metallic;
    var _S370 : vec3<f32> = _S365 - _S328;
    var _S371 : vec3<f32> = vec3<f32>(((1.0f - material_2.transmission) * _S369)) * _S370 * scale_0;
    var _S372 : vec3<f32> = vec3<f32>((material_2.transmission * _S369)) * _S370 * scale_0;
    var _S373 : f32 = max(_S368, 0.0f);
    var _S374 : f32 = rgb_to_greyscale(_S371);
    var _S375 : f32 = max(_S374, 0.0f);
    var _S376 : f32 = rgb_to_greyscale(_S372);
    var _S377 : f32 = (sign((length(_S320))));
    var _S378 : f32 = max(_S376 * _S377, 0.0f);
    var _S379 : f32 = _S373 + _S375 + _S378;
    var _S380 : f32 = min(sheen_component_0, 1.0f);
    var _S381 : bool = sheen_component_0 > 0.0f;
    var _S382 : bool;
    if(_S381)
    {
        _S382 = !(_S379 > 0.0f);
    }
    else
    {
        _S382 = false;
    }
    var _S383 : f32 = select(_S380, 1.0f, _S382);
    var _S384 : f32 = (1.0f - _S383) / max(_S379, 0.0000152587890625f);
    var _S385 : f32 = _S375 * _S384;
    var _S386 : f32 = _S373 * _S384;
    var _S387 : f32 = _S378 * _S384;
    if(_S356)
    {
        var _S388 : vec3<f32> = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        var _S389 : f32 = anisotropicG1(_S388, frame_2.alphas);
        var _S390 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        var _S391 : f32 = anisotropicD(_S390, frame_2.alphas);
        var _S392 : f32 = _S389 * _S391;
        visible_1 = _S392;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S317, _S318, _S320, F_1, _S368, 1.0f, _S371, _S372, _S385, _S386, _S387, 0.0f, sheen_1, _S383, view_2, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_3 : Material) -> f32
{
    var _S393 : f32 = rgb_to_greyscale(material_3.translucent);
    var _S394 : f32 = rgb_to_greyscale(material_3.albedo);
    var _S395 : f32 = _S393 / (_S394 + _S393);
    var _S396 : bool = _S393 > 0.0f;
    var _S397 : f32 = select(0.0f, _S395, _S396);
    return _S397;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S398 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S399 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S400 : f32 = 1.0f - lobes_0.translucent_share;
    var _S401 : bool = n_i_dot_l_0 < 0.0f;
    var _S402 : f32 = select(_S400, lobes_0.translucent_share, _S401);
    var _S403 : f32 = _S399 * _S402;
    var _S404 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S405 : f32 = select(_S398, _S403, _S404);
    var _S406 : bool = n_i_dot_v_0 > 0.0f;
    var _S407 : f32 = select(0.0f, _S405, _S406);
    return _S407;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_3 : f32,  material_4 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S408 : bool = (dot(n_i_3, l_0)) < 0.0f;
    var _S409 : vec3<f32> = select(material_4.albedo, material_4.translucent, _S408);
    var _S410 : f32 = 1.0f - lobes_1.translucent_share;
    var _S411 : f32 = select(_S410, lobes_1.translucent_share, _S408);
    var _S412 : vec3<f32> = _S409 / vec3<f32>(_S411);
    var _S413 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S414 : vec3<f32> = select(material_4.albedo, _S412, _S413);
    return lobes_1.diffuse_weight * _S414 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S415 : f32 = alpha_4 * alpha_4;
    var _S416 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S415 + (1.0f - _S415) * n_dot_x_0 * n_dot_x_0));
    var _S417 : bool = alpha_4 > 0.0f;
    var _S418 : f32 = select(1.0f, _S416, _S417);
    return _S418;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S419 : f32 = alpha_5 * alpha_5;
    var _S420 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S419 * n_dot_h_1 * n_dot_h_1;
    return _S419 / max(3.14159274101257324f * _S420 * _S420, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S421 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S422 : f32 = _S421 * lobes_2.v_dot_h;
    var _S423 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S424 : f32 = _S422 * _S423 / n_i_dot_v_1;
    var _S425 : bool = alpha_6 > 0.0f;
    var _S426 : bool;
    if(_S425)
    {
        _S426 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S426 = false;
    }
    if(_S426)
    {
        _S426 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S426 = false;
    }
    if(_S426)
    {
        _S426 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S426 = false;
    }
    var _S427 : f32 = select(0.0f, _S424, _S426);
    var _S428 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S428)
    {
        var _S429 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S430 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S430)
        {
            _S426 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S426 = false;
        }
        if(_S426)
        {
            _S426 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S426 = false;
        }
        var _S431 : f32 = select(0.0f, _S429, _S426);
        pdf_h_0 = _S431;
    }
    else
    {
        pdf_h_0 = _S427;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S432 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S433 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S434 : f32 = lobes_3.p_refract * _S432 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S433 * _S433);
    var _S435 : bool = eta_i_4 != eta_o_4;
    var _S436 : bool;
    if(_S435)
    {
        _S436 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S436 = false;
    }
    var _S437 : f32 = select(0.0f, _S434, _S436);
    return _S437;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_8 : f32,  material_5 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S438 : f32 = - dot(n_i_4, l_1);
    var _S439 : f32 = smithG1(alpha_8, max(_S438, 0.0f));
    var _S440 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S440)
    {
        var _S441 : vec3<f32> = ((-(n_i_4)));
        var _S442 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S441);
        var _S443 : f32 = anisotropicG1(_S442, lobes_4.alphas);
        G1_l_0 = _S443;
    }
    else
    {
        G1_l_0 = _S439;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_5.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S444 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S445 : bool = n_i_dot_l_2 > 0.0f;
    var _S446 : bool;
    if(_S445)
    {
        _S446 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S446 = false;
    }
    var _S447 : f32 = select(0.0f, _S444, _S446);
    return _S447;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_10 : f32,  material_6 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S448 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S449 : f32 = dot(n_i_5, _S448);
    var _S450 : f32 = max(dot(n_i_5, l_2), 0.0f);
    var _S451 : f32 = max(dot(n_i_5, lobes_6.view), 0.0f);
    var _S452 : f32 = 1.0f / max(material_6.sheen_roughness, 0.05000000074505806f);
    var _S453 : f32 = 1.0f - _S449 * _S449;
    var _S454 : f32 = (2.0f + _S452) * pow(max(_S453, 0.0f), 0.5f * _S452) * 0.5f * 0.31830987334251404f / max(4.0f * (_S450 + _S451 - _S450 * _S451), 0.0000152587890625f);
    var _S455 : bool = (material_6.velvet) > 0.0f;
    var f_1 : f32;
    if(_S455)
    {
        var _S456 : f32 = max(material_6.sheen_roughness, 0.00999999977648258f);
        var _S457 : f32 = _S456 * _S456;
        var _S458 : f32 = max(_S453, 0.0000152587890625f);
        var _S459 : f32 = exp(- _S449 * _S449 / (_S458 * _S457)) / (3.14159274101257324f * _S457 * _S458 * _S458) * min(1.0f, 2.0f * _S449 * min(_S450, _S451) / max(abs(dot(_S448, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S450 * _S451, 0.0000152587890625f);
        f_1 = _S459;
    }
    else
    {
        f_1 = _S454;
    }
    return lobes_6.sheen * vec3<f32>((f_1 * _S450 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S460 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S461 : f32 = lobes_7.p_reflect * _S460 / (4.0f * lobes_7.v_dot_h);
    var _S462 : bool = _S460 > 0.0f;
    var _S463 : f32 = select(0.0f, _S461, _S462);
    return _S463;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_12 : f32,  material_7 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S464 : f32 = dot(n_i_6, l_3);
    var _S465 : f32 = smithG1(alpha_12, max(_S464, 0.0f));
    var _S466 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S466)
    {
        var _S467 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_6);
        var _S468 : f32 = anisotropicG1(_S467, lobes_8.alphas);
        G1_l_1 = _S468;
    }
    else
    {
        G1_l_1 = _S465;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn misWeighted( throughput_0 : vec3<f32>,  lobe_pdf_0 : f32,  pdf_0 : f32,  power_0 : bool) -> vec3<f32>
{
    if(power_0)
    {
        var _S469 : f32 = lobe_pdf_0 / pdf_0;
        return throughput_0 * vec3<f32>(lobe_pdf_0) / vec3<f32>((pdf_0 * (1.0f + _S469 * _S469)));
    }
    return throughput_0 * vec3<f32>(lobe_pdf_0) / vec3<f32>((lobe_pdf_0 + pdf_0));
}

fn neeLobes_0( in_dir_4 : vec3<f32>,  dir_4 : vec3<f32>,  n_6 : vec3<f32>,  material_8 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_1 : bool,  random_state_2 : u32,  each_0 : ptr<function, array<vec3<f32>, i32(5)>>,  reached_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S470 : vec3<f32> = ((-(in_dir_4)));
    var _S471 : f32 = dot(n_6, _S470);
    var _S472 : f32 = (sign((_S471)));
    var _S473 : vec3<f32> = n_6 * vec3<f32>(_S472);
    var _S474 : AnisotropicFrame = anisotropicFrame(material_8, _S473);
    var _S475 : f32 = dot(_S473, dir_4);
    var _S476 : f32 = material_8.roughness;
    var _S477 : f32 = _S476 * _S476;
    var _S478 : vec3<f32> = vec3<f32>(0.0f);
    (*reached_0) = u32(0);
    var _S479 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S478, _S478, 0.0f, 0.0f, _S478, _S478, 0.0f, 0.0f, 0.0f, 0.0f, _S478, 0.0f, _S478, _S478, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S479;
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
        (*each_0)[i_0] = _S478;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_1 : vec3<f32> = _S478;
    i_0 = u32(0);
    var f_2 : vec3<f32> = _S478;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S480 : u32;
        if(i_0 == u32(3))
        {
            _S480 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S480 = u32(6);
            }
            else
            {
                _S480 = i_0;
            }
        }
        var _S481 : bool = _S480 == u32(0);
        if(_S481)
        {
        }
        var _S482 : bool;
        if(_S481)
        {
            var _S483 : f32 = rgb_to_greyscale(material_8.translucent);
            _S482 = _S483 > 0.0f;
        }
        else
        {
            _S482 = false;
        }
        var _S484 : bool;
        if(_S482)
        {
            var _S485 : f32 = dot(n_6, dir_4);
            var _S486 : vec3<f32> = ((-(in_dir_4)));
            _S484 = ((_S485 * dot(n_6, _S486)) < 0.0f) == refracted_2;
        }
        else
        {
            _S484 = (_S480 == u32(1)) == refracted_2;
        }
        var ggx_n_2 : vec3<f32>;
        if(_S484)
        {
            var _S487 : u32;
            if(_S480 == u32(6))
            {
                _S487 = u32(0);
            }
            else
            {
                if(_S480 == u32(4))
                {
                    _S487 = u32(2);
                }
                else
                {
                    _S487 = _S480;
                }
            }
            var _S488 : bool = _S487 != half_of_0;
            var half_of_1 : u32;
            if(_S488)
            {
                var _S489 : bool = _S487 == u32(0);
                if(_S489)
                {
                    var _S490 : vec3<f32> = sampledHalf(in_dir_4, n_6, material_8, random_state_2, _S474);
                    ggx_n_2 = _S490;
                }
                else
                {
                    var _S491 : bool = _S487 == u32(1);
                    if(_S491)
                    {
                        var _S492 : vec3<f32> = refractedHalf(in_dir_4, dir_4, n_6, eta_i_7, eta_o_7);
                        ggx_n_2 = _S492;
                    }
                    else
                    {
                        var _S493 : vec3<f32> = reflectedHalf(in_dir_4, dir_4);
                        ggx_n_2 = _S493;
                    }
                }
                var _S494 : vec3<f32> = ((-(in_dir_4)));
                var _S495 : BSDFLobes = bsdfLobes(in_dir_4, _S494, _S473, ggx_n_2, material_8, eta_i_7, eta_o_7, _S474);
                lobe_terms_0 = _S495;
                var _S496 : f32 = translucentShare(material_8);
                lobe_terms_0.translucent_share = _S496;
                half_of_1 = _S487;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            var throughput_1 : vec3<f32>;
            var lobe_pdf_1 : f32;
            switch(_S480)
            {
            case u32(0):
                {
                    var _S497 : f32 = diffusePDF(_S475, 0.0f, abs(_S471), _S477, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S498 : vec3<f32> = diffuseBSDF(dir_4, _S473, _S477, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S497;
                    throughput_1 = _S498;
                }
            case u32(1):
                {
                    var _S499 : f32 = refractPDF(_S475, dot(dir_4, ggx_n_2), abs(_S471), _S477, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S500 : vec3<f32> = refractBSDF(dir_4, _S473, _S477, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S499;
                    throughput_1 = _S500;
                }
            case u32(4):
                {
                    var _S501 : f32 = sheenVelvetPDF(_S475, 0.0f, abs(_S471), _S477, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S502 : vec3<f32> = sheenVelvetBSDF(dir_4, _S473, _S477, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S501;
                    throughput_1 = _S502;
                }
            default :
                {
                    var _S503 : f32 = reflectPDF(_S475, 0.0f, abs(_S471), _S477, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S504 : vec3<f32> = reflectBSDF(dir_4, _S473, _S477, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S503;
                    throughput_1 = _S504;
                }
            }
            var _S505 : bool = lobe_pdf_1 > 0.0f;
            var f_3 : vec3<f32>;
            if(_S505)
            {
                var _S506 : vec3<f32> = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_0] = _S506;
                var _S507 : u32 = ((*reached_0) | (((u32(1) << (i_0)))));
                (*reached_0) = _S507;
                var f_4 : vec3<f32> = f_2 + (*each_0)[i_0];
                f_3 = f_4;
            }
            else
            {
                f_3 = f_2;
            }
            half_of_0 = half_of_1;
            f_2 = f_3;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_1 = ggx_n_2;
        i_0 = i_2;
    }
    return f_2;
}

fn neeBSDF( in_dir_5 : vec3<f32>,  dir_5 : vec3<f32>,  n_7 : vec3<f32>,  material_9 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_3 : bool,  pdf_2 : f32,  power_2 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var reached_1 : u32 = u32(0);
    var each_1 : array<vec3<f32>, i32(5)>;
    var _S508 : vec3<f32> = neeLobes_0(in_dir_5, dir_5, n_7, material_9, eta_i_8, eta_o_8, refracted_3, pdf_2, power_2, random_state_3, &(each_1), &(reached_1));
    return _S508;
}

fn skyBSDF( in_dir_6 : vec3<f32>,  dir_6 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S509 : bool = wrongSide_0(is_inside_2, false, dir_6, surface_1.geometry_n);
    var _S510 : vec3<f32> = neeBSDF(in_dir_6, dir_6, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S509, pdf_3, false, random_state_4);
    return _S510;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S511 : SkySample;
    _S511.dir = dir_7;
    _S511.radiance = radiance_1;
    _S511.color = color_0;
    _S511.random_state = random_state_5;
    return _S511;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S512 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S513 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S514 : vec2<u32> = _S512 - _S513;
    var _S515 : Random = pcg(init_random_state_0);
    var _S516 : Random = pcg(_S515.state);
    var _S517 : Random = pcg(_S516.state);
    var _S518 : Random = pcg(_S517.state);
    var _S519 : u32 = _S514.x;
    var _S520 : u32 = searchCDF_0(vec2<u32>(_S519, u32(0)), vec2<u32>(u32(0), u32(1)), _S514.y, _S515.value);
    var _S521 : u32 = searchCDF_0(vec2<u32>(u32(0), _S520), _S513, _S519, _S516.value);
    var _S522 : vec2<f32> = (vec2<f32>(f32(_S521), f32(_S520)) + vec2<f32>(_S517.value, _S518.value)) / vec2<f32>(_S514) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S523 : f32 = _S522.y;
    var _S524 : f32 = sin(_S523);
    var _S525 : f32 = _S522.x;
    var _S526 : vec3<f32> = vec3<f32>(_S524 * cos(_S525), cos(_S523), _S524 * sin(_S525));
    var _S527 : f32 = environmentPdf_0(_S526);
    var _S528 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S526, surface_2, eta_1, is_inside_3, _S527, lobe_state_0);
    var _S529 : bool = !(_S527 > 0.0f);
    var _S530 : bool;
    if(_S529)
    {
        _S530 = true;
    }
    else
    {
        _S530 = (all((_S528 == vec3<f32>(0.0f))));
    }
    if(_S530)
    {
        var _S531 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S526, _S531, _S531, _S518.state);
    }
    var _S532 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S526);
    return SkySample_x24init_0(_S526, _S532, _S528 * _S532, _S518.state);
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_8 : vec3<f32>,  radiance_2 : vec3<f32>,  density_0 : f32,  random_state_6 : u32) -> TreeSample
{
    var _S533 : TreeSample;
    _S533.dir = dir_8;
    _S533.radiance = radiance_2;
    _S533.density = density_0;
    _S533.random_state = random_state_6;
    return _S533;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S534 : f32 = importance(first_1, p_10, normal_3);
    var _S535 : f32 = importance(second_1, p_10, normal_3);
    var _S536 : vec2<f32> = vec2<f32>(_S534, _S535);
    var _S537 : bool = _S534 == 0.0f;
    var _S538 : bool;
    if(_S537)
    {
        _S538 = _S535 == 0.0f;
    }
    else
    {
        _S538 = false;
    }
    if(_S538)
    {
        return u32(2);
    }
    var _S539 : f32 = _S534 + _S535;
    var _S540 : bool = _S535 > 0.0f;
    if(_S540)
    {
        _S538 = ((*pick_0) * _S539) >= _S534;
    }
    else
    {
        _S538 = false;
    }
    var _S541 : u32 = select(u32(0), u32(1), _S538);
    var _S542 : f32 = min(((*pick_0) * _S539 - f32(_S541) * _S534) / _S536[_S541], 0.99999994039535522f);
    (*pick_0) = _S542;
    var _S543 : f32 = (*probability_3) * (_S536[_S541] / _S539);
    (*probability_3) = _S543;
    return _S541;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S544 : vec3<f32> = center_1 - p_11;
    var _S545 : f32 = radius_1 * radius_1 / dot(_S544, _S544);
    var _S546 : f32 = u1_0 * _S545 / (1.0f + sqrt(max(1.0f - _S545, 0.0f)));
    var _S547 : f32 = 2.0f * u1_0;
    var _S548 : bool = _S545 >= 1.0f;
    var _S549 : f32 = select(_S546, _S547, _S548);
    var _S550 : f32 = sqrt(max(_S549 * (2.0f - _S549), 0.0f));
    var _S551 : f32 = 6.28318548202514648f * u2_0;
    var _S552 : vec3<f32> = vec3<f32>(_S550 * cos(_S551), 1.0f - _S549, _S550 * sin(_S551));
    var _S553 : vec3<f32> = (normalize((_S544)));
    var _S554 : vec3<f32> = tangentToWorld(_S552, _S553);
    return _S554;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S555 : vec3<f32> = center_2 - ray_1.origin;
    var _S556 : f32 = dot(_S555, ray_1.unit_direction);
    var _S557 : f32 = dot(_S555, _S555) - _S556 * _S556;
    var _S558 : f32 = radius_3 * radius_3;
    var _S559 : bool = _S557 > _S558;
    if(_S559)
    {
        return 4.294967296e+09f;
    }
    var _S560 : f32 = sqrt(_S558 - _S557);
    var _S561 : f32 = _S556 - _S560;
    var _S562 : f32 = _S556 + _S560;
    var _S563 : bool = _S561 > 0.0000152587890625f;
    var _S564 : bool;
    if(_S563)
    {
        _S564 = _S561 < max_len_0;
    }
    else
    {
        _S564 = false;
    }
    if(_S564)
    {
        return _S561;
    }
    var _S565 : bool = _S562 > 0.0000152587890625f;
    if(_S565)
    {
        _S564 = _S562 < max_len_0;
    }
    else
    {
        _S564 = false;
    }
    if(_S564)
    {
        return _S562;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S566 : Random = pcg(init_random_state_1);
    var _S567 : Random = pcg(_S566.state);
    var _S568 : Random = pcg(_S567.state);
    var _S569 : vec3<f32> = vec3<f32>(0.0f);
    var _S570 : TreeSample = TreeSample_x24init_0(_S569, _S569, 0.0f, _S568.state);
    var sample_0 : TreeSample = _S570;
    var _S571 : vec3<f32> = select(smooth_n_2, _S569, sided_0);
    var _S572 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S573 : vec3<f32> = origin_4 + _S572 * smooth_n_2;
    var pick_1 : f32 = _S566.value;
    var probability_4 : f32 = 1.0f;
    var n_8 : u32 = u32(0);
    loop
    {
        var _S574 : vec4<u32> = (access_light_tree(4u + 4u * (n_8)));
        if((_S574.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S575 : u32 = (access_light_tree(3u + 4u * (n_8)).w);
        var _S576 : u32 = n_8 + u32(1);
        var _S577 : LightBounds = (lightBounds((_S576)));
        var _S578 : LightBounds = (lightBounds((_S575)));
        var _S579 : u32 = pickChild(_S577, _S578, origin_4, _S571, &(pick_1), &(probability_4));
        var _S580 : bool = _S579 > u32(1);
        if(_S580)
        {
            return sample_0;
        }
        var _S581 : bool = _S579 == u32(1);
        var _S582 : u32 = select(_S576, _S575, _S581);
        n_8 = _S582;
    }
    var _S583 : bool = n_8 == u32(0);
    var _S584 : bool;
    if(_S583)
    {
        var _S585 : LightBounds = (lightBounds((u32(0))));
        var _S586 : f32 = importance(_S585, origin_4, _S571);
        _S584 = !(_S586 > 0.0f);
    }
    else
    {
        _S584 = false;
    }
    if(_S584)
    {
        return sample_0;
    }
    var _S587 : vec4<u32> = (access_light_tree(4u + 4u * (n_8)));
    var _S588 : bool = (_S587.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S588)
    {
        var _S589 : Light = (lights[(_S587.y)]);
        if(sided_0)
        {
            var _S590 : f32 = (sign((dot(geometry_n_1, _S589.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S590);
            var _S591 : vec3<f32> = origin_4 + _S572 * lift_n_1;
            start_5 = _S591;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S573;
            lift_n_0 = smooth_n_2;
        }
        var _S592 : bool = (_S589.variance) == 0.0f;
        if(_S592)
        {
            var _S593 : vec3<f32> = _S589.position - start_5;
            var _S594 : vec3<f32> = (normalize((_S593)));
            sample_0.dir = _S594;
            var _S595 : vec3<f32> = _S589.color * vec3<f32>(_S589.intensity) / vec3<f32>((dot(_S593, _S593) * probability_4));
            sample_0.radiance = _S595;
            shadow_1 = _S593;
        }
        else
        {
            var _S596 : vec3<f32> = sampleSphere(_S589.position, _S589.variance, start_5, _S567.value, _S568.value);
            sample_0.dir = _S596;
            var _S597 : f32 = sphereDensity(_S589.position, _S589.variance, start_5);
            var _S598 : f32 = probability_4 * _S597;
            sample_0.density = _S598;
            var _S599 : vec3<f32> = pointLightRadiance(_S589.color, _S589.intensity, _S589.variance);
            var _S600 : vec3<f32> = _S599 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S600;
            var _S601 : f32 = raySphere_0(_S589.position, _S589.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S602 : vec3<f32> = sample_0.dir * vec3<f32>(_S601);
            shadow_1 = _S602;
        }
    }
    else
    {
        var _S603 : u32 = _S587.y;
        var _S604 : u32 = ((instance_uint[(_S603) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S605 : u32 = _S604 + _S587.z;
        var _S606 : mat3x3<f32> = (worldTriangle((_S603), (_S605)));
        var _S607 : f32 = sqrt(_S567.value);
        var _S608 : vec2<f32> = vec2<f32>(_S607 * (1.0f - _S568.value), _S607 * _S568.value);
        var _S609 : vec3<f32> = (((_S606) * (vec3<f32>(1.0f - _S607, _S608))));
        if(sided_0)
        {
            var _S610 : f32 = (sign((dot(geometry_n_1, _S609 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S610);
            var _S611 : vec3<f32> = origin_4 + _S572 * lift_n_2;
            start_5 = _S611;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S612 : bool = !((dot(smooth_n_2, _S609 - origin_4)) > 0.0f);
            if(_S612)
            {
                return sample_0;
            }
            start_5 = _S573;
            lift_n_0 = smooth_n_2;
        }
        var _S613 : Surface = (surfaceAt((Hit_x24init_0(_S608, _S603, _S605, u32(0), 0.0f)), (_S609), (_S568.state)));
        sample_0.random_state = _S613.random_state;
        var _S614 : vec3<f32> = _S609 - start_5;
        var _S615 : vec3<f32> = (normalize((_S614)));
        sample_0.dir = _S615;
        var _S616 : f32 = solidAngle(probability_4, cross(_S606[i32(1)] - _S606[i32(0)], _S606[i32(2)] - _S606[i32(0)]), _S614);
        sample_0.density = _S616;
        var _S617 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S613.smooth_n))));
        var _S618 : vec3<f32> = _S613.material.emissive * vec3<f32>(max(_S617, 0.0f));
        var _S619 : vec3<f32> = select(_S618, _S569, _S613.skip);
        var _S620 : vec3<f32> = _S619 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S620;
        shadow_1 = _S614;
    }
    var _S621 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S622 : vec3<f32> = sample_0.radiance * _S621;
    var _S623 : bool = (all((_S621 == _S569)));
    var _S624 : vec3<f32> = select(_S622, _S569, _S623);
    sample_0.radiance = _S624;
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
    var _S625 : f32 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    var _S626 : bool = b_3 > 0.0f;
    var _S627 : f32 = select(1.0f, _S625, _S626);
    return _S627;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S628 : u32 = (lightSlot((hit_1)));
    var _S629 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S628, light_point_1);
    var _S630 : f32 = powerHeuristic(vertex_0.pdf, _S629);
    return _S630;
}

fn environment_0( dir_9 : vec3<f32>) -> vec3<f32>
{
    var _S631 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S632 : bool = (_S631.x) > u32(1);
    var _S633 : bool;
    if(_S632)
    {
        var _S634 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S633 = (_S634.y) > u32(1);
    }
    else
    {
        _S633 = false;
    }
    if(_S633)
    {
        var _S635 : vec3<f32> = (env_map_sample((dir_9)));
        return _S635;
    }
    var _S636 : vec3<f32> = (uniforms_float.ambient);
    return _S636;
}

fn environmentMapped_0() -> bool
{
    var _S637 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S638 : bool = (_S637.x) > u32(1);
    var _S639 : bool;
    if(_S638)
    {
        var _S640 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S639 = (_S640.y) > u32(1);
    }
    else
    {
        _S639 = false;
    }
    return _S639;
}

fn escapeWeight_0( pdf_4 : f32,  dir_10 : vec3<f32>) -> f32
{
    var _S641 : bool = pdf_4 <= 0.0f;
    var _S642 : bool;
    if(_S641)
    {
        _S642 = true;
    }
    else
    {
        var _S643 : bool = environmentMapped_0();
        _S642 = !_S643;
    }
    if(_S642)
    {
        return 1.0f;
    }
    var _S644 : f32 = environmentPdf_0(dir_10);
    return pdf_4 / (pdf_4 + _S644);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S645 : vec2<u32> = global_invocation_id_1.xy;
    var _S646 : vec2<i32> = vec2<i32>(_S645 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_3 : u32 = local_invocation_index_3;
    loop
    {
        if(i_3 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S647 : vec2<i32> = _S646 + vec2<i32>(i32(i_3 % u32(24)), i32(i_3 / u32(24)));
        var _S648 : bool = (all((_S647 >= vec2<i32>(i32(0)))));
        var _S649 : bool;
        if(_S648)
        {
            var _S650 : vec2<u32> = (uniforms_uint.render_size);
            _S649 = (all((_S647 < vec2<i32>(_S650))));
        }
        else
        {
            _S649 = false;
        }
        if(_S649)
        {
            var _S651 : vec4<u32> = (textureLoad(reservoir_prev, (_S647), (u32(0)), 0));
            var _S652 : u32 = _S651.x;
            var _S653 : bool = (bitcast<f32>((_S651.z))) > 0.0f;
            var _S654 : u32 = select(u32(0), _S652, _S653);
            seed_1 = _S654;
        }
        else
        {
            seed_1 = u32(0);
        }
        duplication_seeds_0[i_3] = seed_1;
        var i_4 : u32 = i_3 + u32(64);
        i_3 = i_4;
    }
    workgroupBarrier();
    var _S655 : u32 = local_invocation_id_0.y;
    var _S656 : u32 = local_invocation_id_0.x;
    var _S657 : u32 = duplication_seeds_0[(_S655 + u32(8)) * u32(24) + _S656 + u32(8)];
    seed_1 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(seed_1 < u32(17))
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
            var _S658 : bool = (duplication_seeds_0[(_S655 + seed_1) * u32(24) + _S656 + x_1]) == _S657;
            var _S659 : u32 = select(u32(0), u32(1), _S658);
            var count_2 : u32 = count_1 + _S659;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S660 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S661 : bool = _S657 != u32(0);
    var _S662 : f32 = select(0.0f, _S660, _S661);
    textureStore(duplication_out, (vec2<i32>(_S645)), 0, (vec4<u32>((bitcast<u32>((_S662))), u32(0), u32(0), u32(0))));
    return;
}

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Selection_x24init_0( r_2 : Reservoir,  w_sum_0 : f32,  color_2 : vec3<f32>,  random_state_7 : u32) -> Selection
{
    var _S663 : Selection;
    _S663.r = r_2;
    _S663.w_sum = w_sum_0;
    _S663.color = color_2;
    _S663.random_state = random_state_7;
    return _S663;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S664 : u32 = hash(index_0);
    var _S665 : u32 = hash((seed_2 ^ (_S664)));
    return _S665;
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

fn Shift_x24init_0( f_5 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S666 : Shift;
    _S666.f = f_5;
    _S666.jac = jac_1;
    return _S666;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S667 : f32 = rgb_to_greyscale(weight_0);
    var _S668 : bool = _S667 > 0.0f;
    var _S669 : bool;
    if(_S668)
    {
        _S669 = _S667 < 3.00000000549775576e+38f;
    }
    else
    {
        _S669 = false;
    }
    var _S670 : bool = !_S669;
    if(_S670)
    {
        return;
    }
    var _S671 : f32 = (*sel_0).w_sum + _S667;
    (*sel_0).w_sum = _S671;
    var _S672 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S672;
    var _S673 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S673.state;
    var _S674 : bool = (_S673.value * (*sel_0).w_sum) <= _S667;
    if(_S674)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_3 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_3;
    var _S675 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S675;
    var _S676 : f32 = r_3.jac * shifted_0.jac;
    candidate_1.jac = _S676;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_3.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_4 : Reservoir = sel_2.r;
    var _S677 : f32 = rgb_to_greyscale(r_4.f);
    var _S678 : f32 = sel_2.w_sum / _S677;
    var _S679 : bool = _S677 > 0.0f;
    var _S680 : f32 = select(0.0f, _S678, _S679);
    r_4.w = _S680;
    r_4.c = c_2;
    return r_4;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S681 : vec2<u32> = global_invocation_id_2.xy;
    var _S682 : vec2<i32> = vec2<i32>(_S681);
    var _S683 : vec3<f32> = vec3<f32>(0.0f);
    var _S684 : Domain = Domain_x24init_0(_S683, _S683, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S684;
    var _S685 : bool = (currentDomain((_S682), &(dom_3)));
    var _S686 : bool = !_S685;
    if(_S686)
    {
        storeReservoir(reservoir_prev_out, (_S682), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S683, 0.0f, vec4<u32>(u32(0)), _S683, _S683)), (dom_3.hit));
        var _S687 : vec2<f32> = vec2<f32>(_S681);
        var _S688 : vec2<u32> = (uniforms_uint.render_size);
        var _S689 : vec2<f32> = _S687 / vec2<f32>(_S688.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S690 : vec3<f32> = vec3<f32>(_S689, 1.0f);
        var _S691 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S692 : vec3<f32> = (normalize(((((_S691) * (_S690))))));
        var _S693 : vec3<f32> = environment_0(_S692);
        textureStore(compute_out, (_S682), (u32(0)), (vec4<f32>(_S693, 1.0f)));
        var _S694 : u32 = (uniforms_uint.is_temporal);
        var _S695 : bool = _S694 == u32(1);
        if(_S695)
        {
            textureStore(compute_out, (_S682), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S696 : Reservoir = (loadReservoir(reservoir_temp, (_S682)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S696.c;
    loop
    {
        var _S697 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S697)
        {
        }
        else
        {
            break;
        }
        var _S698 : vec2<i32> = partner_0(_S682, t_13);
        var neighbor_0 : Domain = _S684;
        var _S699 : bool = (currentDomain((_S698), &(neighbor_0)));
        if(_S699)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S700 : vec4<u32> = (textureLoad(reservoir_temp, (_S698), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S700.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S701 : f32 = _S696.c / max(count_3, 1.0f);
    var _S702 : f32 = rgb_to_greyscale(_S696.f);
    var _S703 : bool = count_3 == 0.0f;
    var _S704 : f32 = select(0.0f, 1.0f, _S703);
    var _S705 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S683, 0.0f, vec4<u32>(u32(0)), _S683, _S683), 0.0f, _S683, u32(0));
    var sel_3 : Selection = _S705;
    var _S706 : u32 = (uniforms_uint.frame);
    var _S707 : u32 = hash(_S706);
    var _S708 : u32 = global_invocation_id_2.x;
    var _S709 : vec2<u32> = (uniforms_uint.render_size);
    var _S710 : u32 = stream(_S707, _S708 + _S709.x * global_invocation_id_2.y);
    var _S711 : u32 = stream(_S710, u32(195));
    sel_3.random_state = _S711;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S704;
    loop
    {
        var _S712 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S712)
        {
        }
        else
        {
            break;
        }
        var _S713 : vec2<i32> = partner_0(_S682, t_13);
        var neighbor_dom_0 : Domain = _S684;
        var _S714 : bool = (currentDomain((_S713), &(neighbor_dom_0)));
        if(_S714)
        {
            var _S715 : Reservoir = (loadReservoir(reservoir_temp, (_S713)));
            var _S716 : vec4<u32> = (textureLoad(shift_data, (_S713), (t_13), 0));
            var _S717 : vec4<f32> = (bitcast<vec4<f32>>((_S716)));
            var _S718 : vec4<u32> = (textureLoad(shift_data, (_S682), (t_13), 0));
            var _S719 : vec4<f32> = (bitcast<vec4<f32>>((_S718)));
            var _S720 : f32 = pairShare(_S715.c, _S701, c_sum_1);
            var _S721 : bool = _S702 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S721)
            {
                var _S722 : f32 = rgb_to_greyscale(_S719.xyz);
                var _S723 : f32 = canonicalWeight(_S720, _S701, _S702, _S715.c, _S722);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S723;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S724 : vec3<f32> = _S717.xyz;
            var _S725 : Shift = Shift_x24init_0(_S724, _S717.w);
            var _S726 : f32 = rgb_to_greyscale(_S715.f);
            var _S727 : f32 = rgb_to_greyscale(_S724);
            var _S728 : f32 = neighborWeight(_S720, _S715.c, _S726, _S701, _S727);
            offerShifted(&(sel_3), _S715, _S725, _S728);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S696, Shift_x24init_0(_S696.f, 1.0f), canonical_mis_0);
    var _S729 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S682), (_S729), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S682), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S730 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S731 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S732 : f32 = (sign((dot(_S731, _S730.smooth_n))));
    var _S733 : vec3<f32> = _S730.material.emissive * vec3<f32>(max(_S732, 0.0f));
    var _S734 : vec3<f32> = select(_S733, _S683, _S730.skip);
    var _S735 : vec3<f32> = clamp(sel_3.color + _S734, _S683, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S682), (u32(0)), (vec4<f32>(_S735, 1.0f)));
    var _S736 : u32 = (uniforms_uint.is_temporal);
    var _S737 : bool = _S736 == u32(1);
    if(_S737)
    {
        textureStore(compute_out, (_S682), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_5 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S738 : NEEVertex;
    _S738.none = none_0;
    _S738.pdf = pdf_5;
    _S738.origin = origin_5;
    _S738.smooth_n = smooth_n_3;
    _S738.start = start_6;
    return _S738;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_0 : u32,  pdf_6 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S739 : Vertex;
    _S739.rough = rough_0;
    _S739.lobe = lobe_0;
    _S739.pdf = pdf_6;
    _S739.cos = cos_0;
    _S739.inside = inside_0;
    return _S739;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>,  velvet_0 : f32) -> Material
{
    var _S740 : Material;
    _S740.albedo = albedo_0;
    _S740.emissive = emissive_0;
    _S740.roughness = roughness_0;
    _S740.metallic = metallic_0;
    _S740.transmission = transmission_0;
    _S740.ior = ior_0;
    _S740.absorption = absorption_0;
    _S740.specular_tint = specular_tint_0;
    _S740.specular_level = specular_level_0;
    _S740.translucent = translucent_0;
    _S740.sheen = sheen_2;
    _S740.sheen_roughness = sheen_roughness_0;
    _S740.anisotropy = anisotropy_0;
    _S740.anisotropic_rotation = anisotropic_rotation_0;
    _S740.tangent = tangent_2;
    _S740.velvet = velvet_0;
    return _S740;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_10 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S741 : Surface;
    _S741.smooth_n = smooth_n_4;
    _S741.geometry_n = geometry_n_2;
    _S741.geometry_offset = geometry_offset_2;
    _S741.material = material_10;
    _S741.skip = skip_0;
    _S741.random_state = random_state_8;
    return _S741;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S742 : bool = transmission_1 > 0.0f;
    var _S743 : bool;
    if(_S742)
    {
        _S743 = true;
    }
    else
    {
        _S743 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S744 : f32;
    if(_S743)
    {
        _S744 = 1.0f;
    }
    else
    {
        _S744 = -1.0f;
    }
    return _S744;
}

fn facingRay_0( surface_3 : Surface,  dir_11 : vec3<f32>) -> Surface
{
    var _S745 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_11);
    var _S746 : vec3<f32> = vec3<f32>(_S745);
    return Surface_x24init_0(surface_3.smooth_n * _S746, surface_3.geometry_n * _S746, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S747 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S747));
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
    var _S748 : bool;
    if(open_0)
    {
        _S748 = prev_rough_0;
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        _S748 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S748 = false;
    }
    return _S748;
}

fn vertexEta( material_11 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S749 : bool = n_dot_v_0 < 0.0f;
    var _S750 : f32 = select(1.0f, material_11.ior, _S749);
    var _S751 : f32 = select(material_11.ior, 1.0f, _S749);
    return vec2<f32>(_S750, _S751);
}

fn neeDecision( material_12 : Material,  n_dot_v_1 : f32,  eta_i_9 : f32,  eta_o_9 : f32) -> bool
{
    var _S752 : f32 = fresnel(abs(n_dot_v_1), eta_i_9, eta_o_9);
    var _S753 : vec3<f32> = (mix((vec3<f32>(_S752)), (material_12.albedo), (material_12.metallic)));
    var _S754 : f32 = rgb_to_greyscale(_S753);
    var _S755 : f32 = max((1.0f - _S754) * (1.0f - material_12.metallic) * (1.0f - material_12.transmission), 0.0f);
    var _S756 : bool = _S755 > 0.03999999910593033f;
    var _S757 : bool;
    if(_S756)
    {
        _S757 = true;
    }
    else
    {
        _S757 = (material_12.roughness) > 0.20000000298023224f;
    }
    return _S757;
}

fn isTranslucent_0( material_13 : Material) -> bool
{
    var _S758 : f32 = rgb_to_greyscale(material_13.translucent);
    return _S758 > 0.0f;
}

fn BSDF( in_dir_7 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_0 : vec3<f32>,  material_14 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S759 : vec3<f32> = ((-(in_dir_7)));
    var _S760 : f32 = dot(n_9, _S759);
    var _S761 : f32 = (sign((_S760)));
    var _S762 : vec3<f32> = n_9 * vec3<f32>(_S761);
    var _S763 : AnisotropicFrame = anisotropicFrame(material_14, _S762);
    var _S764 : f32 = dot(_S762, out_dir_2);
    var _S765 : f32 = material_14.roughness;
    var _S766 : f32 = _S765 * _S765;
    var _S767 : bool = (dot(g_n_0, _S759) * dot(g_n_0, out_dir_2)) > 0.0f;
    var _S768 : u32;
    if(_S767)
    {
        _S768 = u32(3);
    }
    else
    {
        _S768 = u32(1);
    }
    var _S769 : vec3<f32> = vec3<f32>(0.0f);
    var _S770 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S769, _S769, 0.0f, 0.0f, _S769, _S769, 0.0f, 0.0f, 0.0f, 0.0f, _S769, 0.0f, _S769, _S769, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_1 : BSDFLobes = _S770;
    var half_of_2 : u32 = u32(4294967295);
    var ggx_n_3 : vec3<f32> = _S769;
    var f_6 : vec3<f32> = _S769;
    var i_5 : u32 = u32(0);
    loop
    {
        if(i_5 < _S768)
        {
        }
        else
        {
            break;
        }
        var _S771 : u32;
        if(!_S767)
        {
            _S771 = u32(1);
        }
        else
        {
            if(i_5 == u32(0))
            {
                _S771 = u32(0);
            }
            else
            {
                if(i_5 == u32(1))
                {
                    _S771 = u32(2);
                }
                else
                {
                    if(i_5 == u32(2))
                    {
                        _S771 = u32(4);
                    }
                    else
                    {
                        _S771 = u32(6);
                    }
                }
            }
        }
        var _S772 : u32;
        if(_S771 == u32(6))
        {
            _S772 = u32(0);
        }
        else
        {
            if(_S771 == u32(4))
            {
                _S772 = u32(2);
            }
            else
            {
                _S772 = _S771;
            }
        }
        var _S773 : bool = _S772 != half_of_2;
        var ggx_n_4 : vec3<f32>;
        if(_S773)
        {
            var _S774 : bool = _S772 == u32(0);
            if(_S774)
            {
                var _S775 : vec3<f32> = sampledHalf(in_dir_7, n_9, material_14, random_state_9, _S763);
                ggx_n_4 = _S775;
            }
            else
            {
                var _S776 : bool = _S772 == u32(1);
                if(_S776)
                {
                    var _S777 : vec3<f32> = refractedHalf(in_dir_7, out_dir_2, n_9, eta_i_10, eta_o_10);
                    ggx_n_4 = _S777;
                }
                else
                {
                    var _S778 : vec3<f32> = reflectedHalf(in_dir_7, out_dir_2);
                    ggx_n_4 = _S778;
                }
            }
            var _S779 : vec3<f32> = ((-(in_dir_7)));
            var _S780 : BSDFLobes = bsdfLobes(in_dir_7, _S779, _S762, ggx_n_4, material_14, eta_i_10, eta_o_10, _S763);
            lobe_terms_1 = _S780;
            var _S781 : f32 = translucentShare(material_14);
            lobe_terms_1.translucent_share = _S781;
            half_of_2 = _S772;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        var throughput_2 : vec3<f32>;
        var pdf_7 : f32;
        switch(_S771)
        {
        case u32(0):
            {
                var _S782 : f32 = diffusePDF(_S764, 0.0f, abs(_S760), _S766, lobe_terms_1, eta_i_10, eta_o_10);
                var _S783 : vec3<f32> = diffuseBSDF(out_dir_2, _S762, _S766, material_14, lobe_terms_1);
                pdf_7 = _S782;
                throughput_2 = _S783;
            }
        case u32(1):
            {
                var _S784 : f32 = refractPDF(_S764, dot(out_dir_2, ggx_n_4), abs(_S760), _S766, lobe_terms_1, eta_i_10, eta_o_10);
                var _S785 : vec3<f32> = refractBSDF(out_dir_2, _S762, _S766, material_14, lobe_terms_1);
                pdf_7 = _S784;
                throughput_2 = _S785;
            }
        case u32(4):
            {
                var _S786 : f32 = sheenVelvetPDF(_S764, 0.0f, abs(_S760), _S766, lobe_terms_1, eta_i_10, eta_o_10);
                var _S787 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S762, _S766, material_14, lobe_terms_1);
                pdf_7 = _S786;
                throughput_2 = _S787;
            }
        default :
            {
                var _S788 : f32 = reflectPDF(_S764, 0.0f, abs(_S760), _S766, lobe_terms_1, eta_i_10, eta_o_10);
                var _S789 : vec3<f32> = reflectBSDF(out_dir_2, _S762, _S766, material_14, lobe_terms_1);
                pdf_7 = _S788;
                throughput_2 = _S789;
            }
        }
        var _S790 : vec3<f32>;
        if(pdf_7 > 0.0f)
        {
            _S790 = throughput_2 * vec3<f32>(pdf_7);
        }
        else
        {
            _S790 = _S769;
        }
        if(i_5 == u32(0))
        {
            f_6 = _S790;
        }
        else
        {
            f_6 = f_6 + _S790;
        }
        var i_6 : u32 = i_5 + u32(1);
        ggx_n_3 = ggx_n_4;
        i_5 = i_6;
    }
    return f_6;
}

fn translucentCorrection( in_dir_8 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_1 : vec3<f32>,  material_15 : Material,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S791 : f32 = dot(n_10, out_dir_3);
    var _S792 : vec3<f32> = ((-(in_dir_8)));
    var _S793 : bool = (_S791 * dot(n_10, _S792)) < 0.0f;
    var _S794 : vec3<f32> = ((-(in_dir_8)));
    var _S795 : f32 = dot(n_10, _S794);
    var _S796 : f32 = (sign((_S795)));
    var _S797 : vec3<f32> = n_10 * vec3<f32>(_S796);
    var _S798 : AnisotropicFrame = anisotropicFrame(material_15, _S797);
    var _S799 : f32 = material_15.roughness;
    var _S800 : f32 = _S799 * _S799;
    var _S801 : vec3<f32> = ((-(in_dir_8)));
    var _S802 : vec3<f32> = sampledHalf(in_dir_8, n_10, material_15, random_state_10, _S798);
    var _S803 : BSDFLobes = bsdfLobes(in_dir_8, _S801, _S797, _S802, material_15, eta_i_11, eta_o_11, _S798);
    var sampled_0 : BSDFLobes = _S803;
    var _S804 : f32 = translucentShare(material_15);
    sampled_0.translucent_share = _S804;
    var _S805 : f32 = diffusePDF(dot(_S797, out_dir_3), 0.0f, abs(_S795), _S800, sampled_0, eta_i_11, eta_o_11);
    var _S806 : vec3<f32>;
    if(_S805 > 0.0f)
    {
        var _S807 : vec3<f32> = diffuseBSDF(out_dir_3, _S797, _S800, material_15, sampled_0);
        _S806 = _S807 * vec3<f32>(_S805);
    }
    else
    {
        _S806 = vec3<f32>(0.0f);
    }
    var _S808 : vec3<f32> = ((-(in_dir_8)));
    var _S809 : bool = (dot(g_n_1, _S808) * dot(g_n_1, out_dir_3)) > 0.0f;
    var _S810 : vec3<f32> = vec3<f32>(0.0f);
    var _S811 : f32 = select(1.0f, -1.0f, _S809);
    var _S812 : vec3<f32> = _S806 * vec3<f32>(_S811);
    var _S813 : vec3<f32> = select(_S810, _S812, _S793);
    return _S813;
}

fn translucentBSDF( in_dir_9 : vec3<f32>,  out_dir_4 : vec3<f32>,  n_11 : vec3<f32>,  g_n_2 : vec3<f32>,  material_16 : Material,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S814 : vec3<f32> = BSDF(in_dir_9, out_dir_4, n_11, g_n_2, material_16, eta_i_12, eta_o_12, random_state_11);
    var _S815 : vec3<f32> = translucentCorrection(in_dir_9, out_dir_4, n_11, g_n_2, material_16, eta_i_12, eta_o_12, random_state_11);
    return _S814 + _S815;
}

fn lightBSDF_0( in_dir_10 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_17 : Material,  eta_i_13 : f32,  eta_o_13 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S816 : bool = !competing_0;
    var _S817 : bool;
    if(_S816)
    {
        _S817 = true;
    }
    else
    {
        _S817 = (light_0.density) == 0.0f;
    }
    if(_S817)
    {
        var _S818 : bool = isTranslucent_0(material_17);
        if(_S818)
        {
            var _S819 : vec3<f32> = translucentBSDF(in_dir_10, light_0.dir, smooth_n_5, geometry_n_4, material_17, eta_i_13, eta_o_13, random_state_12);
            return _S819 * light_0.radiance;
        }
        var _S820 : vec3<f32> = BSDF(in_dir_10, light_0.dir, smooth_n_5, geometry_n_4, material_17, eta_i_13, eta_o_13, random_state_12);
        return _S820 * light_0.radiance;
    }
    var _S821 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_10)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S822 : vec3<f32> = neeBSDF(in_dir_10, light_0.dir, smooth_n_5, material_17, eta_i_13, eta_o_13, _S821, light_0.density, true, random_state_12);
    return _S822 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_8 : vec3<f32>,  b_4 : vec3<f32>) -> vec3<f32>
{
    var _S823 : vec3<f32> = a_8 / b_4;
    var _S824 : vec3<f32> = vec3<f32>(0.0f);
    var _S825 : vec3<bool> = b_4 == _S824;
    var _S826 : vec3<f32> = select(_S823, _S824, _S825);
    return _S826;
}

fn withEnd( r_5 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_7 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_5;
    var _S827 : u32 = (insertBits((r_5.path), (end_0), (u32(0)), (u32(5))));
    var _S828 : u32 = (insertBits((_S827), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S828;
    candidate_2.f = f_7;
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_3 : vec3<f32>,  random_state_13 : u32,  refracted_4 : bool,  lobe_1 : u32,  pdf_8 : f32) -> SampleBSDF
{
    var _S829 : SampleBSDF;
    _S829.unit_direction = unit_direction_1;
    _S829.throughput = throughput_3;
    _S829.random_state = random_state_13;
    _S829.refracted = refracted_4;
    _S829.lobe = lobe_1;
    _S829.pdf = pdf_8;
    return _S829;
}

fn sheenVelvetSample( n_i_7 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_18 : Material,  lobes_9 : BSDFLobes,  eta_i_14 : f32,  eta_o_14 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S830 : vec3<f32> = vec3<f32>(1.0f);
    var _S831 : SampleBSDF = SampleBSDF_x24init_0(_S830, _S830, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S831;
    var _S832 : Random = pcg(random_state_14);
    var _S833 : Random = pcg(_S832.state);
    sample_1.random_state = _S833.state;
    var _S834 : f32 = _S832.value;
    var _S835 : f32 = sqrt(max(0.0f, 1.0f - _S834 * _S834));
    var _S836 : f32 = 6.28318548202514648f * _S833.value;
    var _S837 : vec3<f32> = tangentToWorld(vec3<f32>(_S835 * cos(_S836), _S832.value, _S835 * sin(_S836)), n_i_7);
    sample_1.unit_direction = _S837;
    sample_1.lobe = u32(4);
    var _S838 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_7, alpha_13, material_18, lobes_9);
    sample_1.throughput = _S838;
    var _S839 : f32 = sheenVelvetPDF(_S832.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_14, eta_o_14);
    sample_1.pdf = _S839;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S840 : f32 = sqrt(random_1_0);
    var _S841 : f32 = 6.28318548202514648f * random_2_0;
    var _S842 : f32 = _S840 * cos(_S841);
    var _S843 : f32 = _S840 * sin(_S841);
    var _S844 : f32 = sqrt(max(0.0f, 1.0f - _S842 * _S842 - _S843 * _S843));
    return vec3<f32>(_S842, _S844, _S843);
}

fn diffuseSample( u_1 : f32,  n_i_8 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_19 : Material,  lobes_10 : BSDFLobes,  eta_i_15 : f32,  eta_o_15 : f32,  random_state_15 : u32) -> SampleBSDF
{
    var _S845 : vec3<f32> = vec3<f32>(1.0f);
    var _S846 : SampleBSDF = SampleBSDF_x24init_0(_S845, _S845, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S846;
    var _S847 : Random = pcg(random_state_15);
    var _S848 : Random = pcg(_S847.state);
    sample_2.random_state = _S848.state;
    var _S849 : vec3<f32> = sampleCosWeightedHemisphere(_S847.value, _S848.value);
    var _S850 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S851 : f32 = _S849.y;
    var _S852 : f32 = - _S851;
    var _S853 : f32 = select(_S851, _S852, _S850);
    var _S854 : vec3<f32> = tangentToWorld(vec3<f32>(_S849.x, _S853, _S849.z), n_i_8);
    sample_2.unit_direction = _S854;
    sample_2.refracted = _S850;
    sample_2.lobe = u32(0);
    var _S855 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_8, alpha_14, material_19, lobes_10);
    sample_2.throughput = _S855;
    var _S856 : f32 = diffusePDF(_S853, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_15, eta_o_15);
    sample_2.pdf = _S856;
    return sample_2;
}

fn refractSample( ggx_n_5 : vec3<f32>,  n_i_9 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_20 : Material,  lobes_11 : BSDFLobes,  eta_i_16 : f32,  eta_o_16 : f32,  random_state_16 : u32) -> SampleBSDF
{
    var _S857 : vec3<f32> = vec3<f32>(1.0f);
    var _S858 : SampleBSDF = SampleBSDF_x24init_0(_S857, _S857, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S858;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_16;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S859 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_9, alpha_15, material_20, lobes_11);
    sample_3.throughput = _S859;
    var _S860 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_5), n_i_dot_v_7, alpha_15, lobes_11, eta_i_16, eta_o_16);
    sample_3.pdf = _S860;
    return sample_3;
}

fn reflectSample( in_dir_11 : vec3<f32>,  ggx_n_6 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_21 : Material,  lobes_12 : BSDFLobes,  eta_i_17 : f32,  eta_o_17 : f32,  random_state_17 : u32) -> SampleBSDF
{
    var _S861 : vec3<f32> = vec3<f32>(1.0f);
    var _S862 : SampleBSDF = SampleBSDF_x24init_0(_S861, _S861, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S862;
    var _S863 : vec3<f32> = (normalize((reflect(in_dir_11, ggx_n_6))));
    sample_4.unit_direction = _S863;
    sample_4.random_state = random_state_17;
    sample_4.lobe = u32(2);
    var _S864 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_10, alpha_16, material_21, lobes_12);
    sample_4.throughput = _S864;
    var _S865 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_17, eta_o_17);
    sample_4.pdf = _S865;
    return sample_4;
}

fn sampleBSDF( in_dir_12 : vec3<f32>,  n_12 : vec3<f32>,  material_22 : Material,  eta_i_18 : f32,  eta_o_18 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_18 : u32 = random_init_0;
    var _S866 : vec3<f32> = ((-(in_dir_12)));
    var _S867 : f32 = dot(n_12, _S866);
    var _S868 : f32 = (sign((_S867)));
    var n_i_11 : vec3<f32> = n_12 * vec3<f32>(_S868);
    var _S869 : f32 = abs(_S867);
    var _S870 : f32 = material_22.roughness;
    var _S871 : f32 = _S870 * _S870;
    var _S872 : AnisotropicFrame = anisotropicFrame(material_22, n_i_11);
    var _S873 : vec3<f32> = sampleHalfVector(_S866, n_i_11, _S871, _S872, &(random_state_18));
    var _S874 : BSDFLobes = bsdfLobes(in_dir_12, _S866, n_i_11, _S873, material_22, eta_i_18, eta_o_18, _S872);
    var lobes_13 : BSDFLobes = _S874;
    var _S875 : f32 = translucentShare(material_22);
    lobes_13.translucent_share = _S875;
    var _S876 : Random = pcg(random_state_18);
    random_state_18 = _S876.state;
    var _S877 : bool = (_S876.value) < (lobes_13.p_sheen_velvet);
    if(_S877)
    {
        var _S878 : SampleBSDF = sheenVelvetSample(n_i_11, _S869, _S871, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
        return _S878;
    }
    var _S879 : f32 = _S876.value - lobes_13.p_sheen_velvet;
    var _S880 : bool = _S879 < (lobes_13.p_diffuse);
    if(_S880)
    {
        var _S881 : SampleBSDF = diffuseSample(_S879, n_i_11, _S869, _S871, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
        return _S881;
    }
    var _S882 : bool = _S879 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S882)
    {
        var _S883 : SampleBSDF = refractSample(_S873, n_i_11, _S869, _S871, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
        return _S883;
    }
    var _S884 : SampleBSDF = reflectSample(in_dir_12, _S873, n_i_11, _S869, _S871, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
    return _S884;
}

fn withinInverseFootprint( pdf_9 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S885 : bool = pdf_9 > 0.0f;
    var _S886 : bool;
    if(_S885)
    {
        if(diffuse_0)
        {
            _S886 = true;
        }
        else
        {
            _S886 = (pdf_9 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S886 = false;
    }
    return _S886;
}

fn roughLobe( pdf_10 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S887 : bool = pdf_10 > 0.0f;
    var _S888 : bool;
    if(_S887)
    {
        if(diffuse_1)
        {
            _S888 = true;
        }
        else
        {
            _S888 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S888 = false;
    }
    return _S888;
}

fn survivalProbability( throughput_4 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S889 : vec3<f32> = throughput_4 / vec3<f32>(density_1);
    return clamp(max(_S889.x, max(_S889.y, _S889.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_6 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S890 : vec3<f32> = vec3<f32>(0.0f);
    var _S891 : Shift = Shift_x24init_0(_S890, 0.0f);
    var _S892 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S893 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S894 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S895 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S896 : bool = _S895 >= u32(3);
        var _S897 : u32 = select(u32(0), u32(1), _S896);
        var _S898 : u32 = _S892 + _S897;
        var _S899 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S898 > _S899;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S891;
    }
    var _S900 : u32 = _S893 - u32(1);
    var _S901 : bool = _S895 == u32(3);
    var _S902 : u32 = select(u32(0), u32(1), _S901);
    var _S903 : u32 = _S892 + _S902;
    var _S904 : bool = _S894 == u32(0);
    var _S905 : u32 = select(_S900, _S903, _S904);
    var _S906 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_6.rc.zw))), r_6.rc.x, r_6.rc.y, u32(0), 0.0f);
    var _S907 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S908 : Ray = Ray_x24init_0(dom_4.x1, _S907);
    var ray_2 : Ray = _S908;
    var hit_2 : Hit = dom_4.hit;
    var _S909 : vec3<f32> = vec3<f32>(1.0f);
    var _S910 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S890, _S890, _S890);
    var nee_vertex_0 : NEEVertex = _S910;
    var _S911 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S911;
    var _S912 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S890, 0.0f, vec4<u32>(u32(0)), _S890, _S890);
    var chain_0 : Reservoir = _S912;
    chain_0.seed = r_6.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S890;
    var reconnection_0 : vec3<f32> = _S890;
    var b_5 : u32 = u32(0);
    var throughput_5 : vec3<f32> = _S909;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S913 : bool = (hit_2.is_point_light) == u32(1);
        var _S914 : bool;
        if(replay_0)
        {
            _S914 = _S894 == u32(1);
        }
        else
        {
            _S914 = false;
        }
        var _S915 : bool;
        if(_S914)
        {
            _S915 = b_5 == _S893;
        }
        else
        {
            _S915 = false;
        }
        var _S916 : bool;
        if(_S915)
        {
            var _S917 : bool = (hit_2.instance_index) != (_S906.instance_index);
            if(_S917)
            {
                _S916 = true;
            }
            else
            {
                _S916 = (hit_2.triangle_index) != (_S906.triangle_index);
            }
        }
        else
        {
            _S916 = false;
        }
        if(_S916)
        {
            return _S891;
        }
        var _S918 : Surface = Surface_x24init_0(_S890, _S890, 0.0f, Material_x24init_0(_S890, _S890, 0.0f, 0.0f, 0.0f, 0.0f, _S890, _S909, 1.0f, _S890, _S890, 0.5f, 0.0f, 0.0f, _S890, 0.0f), false, u32(0));
        var _S919 : bool = !_S913;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_6 : vec3<f32>;
        var surface_4 : Surface;
        if(_S919)
        {
            var _S920 : u32 = stream(r_6.seed, b_5);
            var _S921 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S920)));
            var surface_5 : Surface = facingRay_0(_S921, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S922 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S923 : vec3<f32> = throughput_5 * _S922;
                front_n_0 = _S923;
            }
            else
            {
                front_n_0 = throughput_5;
            }
            var _S924 : bool = !surface_5.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_5.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S925 : bool = b_5 == u32(0);
            if(_S925)
            {
                var _S926 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S926;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S927 : vec3<f32> = front_n_0;
            var _S928 : f32 = geometry_density_2;
            scatter_0 = _S924;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S928;
            surface_4 = surface_5;
            front_n_0 = _S921.smooth_n;
            throughput_6 = _S927;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_4 = _S918;
            front_n_0 = _S890;
            throughput_6 = throughput_5;
        }
        var _S929 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S930 : Surface = surface_4;
        var _S931 : Surface = surface_4;
        var _S932 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S933 : vec2<f32> = vertexEta(_S930.material, _S932);
        var _S934 : bool;
        if(scatter_0)
        {
            var _S935 : bool = neeDecision(_S930.material, _S932, _S933.x, _S933.y);
            _S934 = _S935;
        }
        else
        {
            _S934 = false;
        }
        var _S936 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S937 : vec3<f32> = _S930.material.emissive * vec3<f32>(max(_S936, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S913)
        {
            var _S938 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S938;
        }
        else
        {
            emission_0 = _S937;
        }
        var _S939 : bool = !replay_0;
        var _S940 : bool;
        if(_S939)
        {
            _S940 = true;
        }
        else
        {
            _S940 = b_5 >= _S905;
        }
        var _S941 : bool;
        if(_S940)
        {
            var _S942 : f32 = rgb_to_greyscale(emission_0);
            _S941 = _S942 > 0.0f;
        }
        else
        {
            _S941 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S941)
        {
            var _S943 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S943);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S944 : bool;
        if(replay_0)
        {
            _S944 = _S894 == u32(1);
        }
        else
        {
            _S944 = false;
        }
        var _S945 : bool;
        if(_S944)
        {
            _S945 = b_5 > _S893;
        }
        else
        {
            _S945 = false;
        }
        var _S946 : bool;
        if(_S945)
        {
            _S946 = b_5 == _S892;
        }
        else
        {
            _S946 = false;
        }
        var _S947 : bool;
        if(_S946)
        {
            var _S948 : bool = _S895 == u32(1);
            if(_S948)
            {
                _S947 = true;
            }
            else
            {
                _S947 = _S895 == u32(2);
            }
        }
        else
        {
            _S947 = false;
        }
        if(_S947)
        {
            var _S949 : bool = _S913 != (_S895 == u32(2));
            if(_S949)
            {
                return _S891;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / vec3<f32>(r_6.jac), density_2 / r_6.jac);
        }
        var _S950 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S951 : bool = _S950 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S952 : u32 = (insertBits((u32(0)), (b_5), (u32(5)), (u32(5))));
        var _S953 : u32 = (insertBits((_S952), (u32(1)), (u32(10)), (u32(2))));
        var _S954 : u32 = (insertBits((_S953), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S955 : bool = prev_0.inside;
        var _S956 : u32 = select(u32(0), u32(1), _S955);
        var _S957 : u32 = (insertBits((_S954), (_S956), (u32(22)), (u32(1))));
        here_0.path = _S957;
        var _S958 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S958;
        var _S959 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S959;
        var _S960 : bool;
        if(replay_0)
        {
            _S960 = _S894 == u32(1);
        }
        else
        {
            _S960 = false;
        }
        var _S961 : bool;
        if(_S960)
        {
            _S961 = b_5 == _S893;
        }
        else
        {
            _S961 = false;
        }
        var _S962 : bool = b_5 == _S905;
        var _S963 : bool;
        if(_S962)
        {
            var _S964 : bool = !scatter_0;
            if(_S964)
            {
                _S963 = true;
            }
            else
            {
                var _S965 : bool = _S894 != u32(1);
                if(_S965)
                {
                    _S963 = _S894 != u32(3);
                }
                else
                {
                    _S963 = false;
                }
            }
        }
        else
        {
            _S963 = false;
        }
        var _S966 : bool;
        if(_S963)
        {
            _S966 = _S894 == u32(2);
        }
        else
        {
            _S966 = false;
        }
        var _S967 : bool;
        if(_S966)
        {
            _S967 = !_S929;
        }
        else
        {
            _S967 = false;
        }
        var _S968 : bool;
        if(_S967)
        {
            _S968 = _S895 != u32(4);
        }
        else
        {
            _S968 = false;
        }
        var _S969 : bool = _S893 == _S892;
        var _S970 : bool;
        if(_S969)
        {
            _S970 = _S895 == u32(0);
        }
        else
        {
            _S970 = false;
        }
        var _S971 : bool;
        if(_S970)
        {
            _S971 = (hit_2.instance_index) == (_S906.instance_index);
        }
        else
        {
            _S971 = false;
        }
        var _S972 : bool;
        if(_S971)
        {
            _S972 = (hit_2.triangle_index) == (_S906.triangle_index);
        }
        else
        {
            _S972 = false;
        }
        var _S973 : bool;
        if(_S972)
        {
            _S973 = _S929;
        }
        else
        {
            _S973 = false;
        }
        var _S974 : bool = select(_S968, _S973, _S961);
        var _S975 : bool;
        if(_S934)
        {
            _S975 = select(scatter_0, _S974, replay_0);
        }
        else
        {
            _S975 = false;
        }
        var _S976 : TreeSample = TreeSample_x24init_0(_S890, _S890, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S975)
        {
            var _S977 : Surface = surface_4;
            var _S978 : bool = isTranslucent_0(_S930.material);
            var _S979 : u32 = stream(r_6.seed, b_5 + u32(64));
            var _S980 : TreeSample = sampleLightTree_0(ray_2.origin, _S931.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S978, _S979);
            var _S981 : bool = (any(((_S980.radiance) != _S890)));
            if(_S981)
            {
                var _S982 : f32 = _S933.x;
                var _S983 : f32 = _S933.y;
                var _S984 : u32 = (uniforms_uint.max_bounces);
                var _S985 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S980, _S931.smooth_n, _S977.geometry_n, _S930.material, _S982, _S983, b_5 < _S984, surface_4.random_state);
                lit_0 = _S985;
            }
            else
            {
                lit_0 = _S890;
            }
            light_1 = _S980;
        }
        else
        {
            light_1 = _S976;
            lit_0 = _S890;
        }
        var _S986 : bool;
        var wrong_side_0 : bool;
        var refracted_5 : bool;
        var _S987 : bool;
        var _S988 : bool;
        var density_3 : f32;
        var throughput_7 : vec3<f32>;
        if(_S961)
        {
            var _S989 : bool = !_S929;
            if(_S989)
            {
                return _S891;
            }
            var throughput_8 : vec3<f32> = throughput_6 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S969)
            {
                _S986 = _S895 == u32(1);
            }
            else
            {
                _S986 = false;
            }
            if(_S986)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S969)
            {
                wrong_side_0 = _S895 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S990 : bool = !_S934;
                if(_S990)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S991 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S991 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S891;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S969)
            {
                refracted_5 = _S895 == u32(4);
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                var _S992 : bool = !_S934;
                if(_S992)
                {
                    return _S891;
                }
                var _S993 : f32 = environmentPdf_0(r_6.dir);
                var _S994 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_6.dir, surface_4, _S933, is_inside_4, _S993, surface_4.random_state);
                return Shift_x24init_0(throughput_8 * _S994 * r_6.radiance / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            var _S995 : u32 = (extractBits((r_6.path), (u32(21)), (u32(1))));
            var _S996 : bool = _S934 != (_S995 == u32(1));
            if(_S996)
            {
                return _S891;
            }
            throughput_7 = throughput_8;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S986 = _S962;
            }
            else
            {
                _S986 = false;
            }
            if(_S986)
            {
                var _S997 : bool = !scatter_0;
                if(_S997)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S998 : bool = _S894 != u32(1);
                    if(_S998)
                    {
                        wrong_side_0 = _S894 != u32(3);
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
                var _S999 : bool = _S894 == u32(2);
                if(_S999)
                {
                    _S914 = _S934;
                }
                else
                {
                    _S914 = false;
                }
                if(_S914)
                {
                    _S914 = !_S929;
                }
                else
                {
                    _S914 = false;
                }
                if(_S914)
                {
                    _S914 = _S895 == u32(4);
                }
                else
                {
                    _S914 = false;
                }
                if(_S914)
                {
                    var _S1000 : u32 = stream(r_6.seed, b_5 + u32(256));
                    var _S1001 : SkySample = sampleSky_0(ray_2, surface_4, _S933, is_inside_4, _S1000, surface_4.random_state);
                    return Shift_x24init_0(throughput_6 * _S1001.color, 1.0f);
                }
                if(_S999)
                {
                    is_inside_4 = _S934;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S929;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S1002 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S1003 : bool = !(_S1002 > 0.0f);
                    if(_S1003)
                    {
                        return _S891;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S904)
                {
                    is_inside_4 = _S895 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S913;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S904)
                {
                    is_inside_4 = _S895 == u32(1);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = scatter_0;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S929;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S891;
            }
            else
            {
                if(_S939)
                {
                    refracted_5 = scatter_0;
                }
                else
                {
                    refracted_5 = false;
                }
                if(refracted_5)
                {
                    var _S1004 : bool = b_5 > u32(0);
                    if(_S1004)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S951)
                        {
                            var _S1005 : vec3<f32> = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S1005;
                        }
                        else
                        {
                            if(_S929)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S1006 : vec3<f32> = throughput_6 * emission_1;
                        var _S1007 : Reservoir = withEnd(candidate_3, u32(1), b_5, _S1006);
                        offer(&((*sel_4)), _S1007, _S1006 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S934)
                    {
                        var _S1008 : vec3<f32> = throughput_6 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S951)
                        {
                            var _S1009 : vec3<f32> = safeDivide(_S1008, chain_throughput_0);
                            candidate_4.radiance = _S1009;
                        }
                        else
                        {
                            if(_S929)
                            {
                                candidate_4 = here_0;
                                var _S1010 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S1010;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S1011 : u32 = (insertBits((u32(0)), (b_5 + u32(1)), (u32(5)), (u32(5))));
                                var _S1012 : u32 = (insertBits((_S1011), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S1012;
                            }
                        }
                        var _S1013 : Reservoir = withEnd(candidate_4, u32(0), b_5, _S1008);
                        offer(&((*sel_4)), _S1013, _S1008 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S934)
                    {
                        var _S1014 : bool = environmentMapped_0();
                        _S987 = _S1014;
                    }
                    else
                    {
                        _S987 = false;
                    }
                    if(_S987)
                    {
                        var _S1015 : u32 = (uniforms_uint.max_bounces);
                        _S988 = b_5 < _S1015;
                    }
                    else
                    {
                        _S988 = false;
                    }
                    if(_S988)
                    {
                        var _S1016 : u32 = stream(r_6.seed, b_5 + u32(256));
                        var _S1017 : SkySample = sampleSky_0(ray_2, surface_4, _S933, is_inside_4, _S1016, surface_4.random_state);
                        var _S1018 : vec3<f32> = throughput_6 * _S1017.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S951)
                        {
                            var _S1019 : vec3<f32> = safeDivide(_S1018, chain_throughput_0);
                            candidate_5.radiance = _S1019;
                        }
                        else
                        {
                            if(_S929)
                            {
                                candidate_5 = here_0;
                                var _S1020 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S1020;
                                candidate_5.dir = _S1017.dir;
                                candidate_5.radiance = _S1017.radiance;
                            }
                            else
                            {
                                var _S1021 : u32 = (insertBits((u32(0)), (b_5 + u32(1)), (u32(5)), (u32(5))));
                                var _S1022 : u32 = (insertBits((_S1021), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S1022;
                            }
                        }
                        var _S1023 : Reservoir = withEnd(candidate_5, u32(4), b_5, _S1018);
                        offer(&((*sel_4)), _S1023, _S1018 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_3 = density_2;
        }
        var _S1024 : bool;
        var _S1025 : bool;
        var straight_0 : bool;
        var _S1026 : bool;
        var _S1027 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S986 = _S962;
            }
            else
            {
                _S986 = false;
            }
            var _S1028 : u32 = (extractBits((r_6.path), (u32(15)), (u32(3))));
            var _S1029 : u32 = (extractBits((r_6.path), (u32(18)), (u32(3))));
            var _S1030 : u32 = select(_S1028, _S1029, _S961);
            var refracted_6 : bool = _S1030 == u32(1);
            var _S1031 : SampleBSDF = SampleBSDF_x24init_0(_S890, _S890, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S1031;
            var dir_12 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S986)
            {
                var _S1032 : u32 = (extractBits((r_6.path), (u32(22)), (u32(1))));
                var _S1033 : bool = is_inside_4 != (_S1032 == u32(1));
                if(_S1033)
                {
                    return _S891;
                }
                var _S1034 : bool = _S894 == u32(1);
                if(_S1034)
                {
                    var _S1035 : vec3<f32> = (hitPosition((_S906)));
                    dir_12 = _S1035;
                }
                else
                {
                    dir_12 = reconnection_0;
                }
                if(refracted_6)
                {
                    refracted_5 = true;
                }
                else
                {
                    var _S1036 : bool = isTranslucent_0(_S930.material);
                    if(_S1036)
                    {
                        wrong_side_0 = _S1030 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1037 : vec3<f32> = dir_12 - ray_2.origin;
                        var _S1038 : vec3<f32> = select(r_6.dir, _S1037, _S1034);
                        refracted_5 = (dot(_S931.smooth_n, _S1038) * _S932) < 0.0f;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                }
                if(_S1034)
                {
                    var _S1039 : vec3<f32> = ray_2.origin;
                    var _S1040 : Surface = surface_4;
                    var _S1041 : vec3<f32> = (vec3<f32>(0) - _S931.smooth_n);
                    var _S1042 : bool = is_inside_4 != refracted_5;
                    var _S1043 : vec3<f32> = select(_S931.smooth_n, _S1041, _S1042);
                    var _S1044 : vec3<f32> = (normalize((dir_12 - (_S1039 + vec3<f32>(_S1040.geometry_offset) * _S1043))));
                    reconnection_1 = _S1044;
                }
                else
                {
                    reconnection_1 = r_6.dir;
                }
                var _S1045 : bool = wrongSide_0(is_inside_4, refracted_5, reconnection_1, surface_4.geometry_n);
                if(_S1045)
                {
                    return _S891;
                }
                var _S1046 : vec3<f32> = dir_12;
                dir_12 = reconnection_1;
                lobe_index_0 = _S1030;
                wrong_side_0 = false;
                reconnection_1 = _S1046;
            }
            else
            {
                var _S1047 : bool = !_S961;
                if(_S1047)
                {
                    var _S1048 : f32 = _S933.x;
                    var _S1049 : f32 = _S933.y;
                    var _S1050 : vec2<f32> = vec2<f32>(0.0f);
                    var _S1051 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S931.smooth_n, _S930.material, _S1048, _S1049, surface_4.random_state, _S1050);
                    var bsdf_sampled_0 : SampleBSDF = _S1051;
                    var _S1052 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S930.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1053 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S1052.geometry_n, _S930.material, _S1048, _S1049, bsdf_sampled_0.random_state, _S1050);
                        bsdf_sampled_0.unit_direction = _S1053.unit_direction;
                        bsdf_sampled_0.refracted = _S1053.refracted;
                        bsdf_sampled_0.throughput = _S1053.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S1054 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S1052.geometry_n))) * _S1052.geometry_n;
                            bsdf_sampled_0.unit_direction = _S1054;
                        }
                    }
                    var _S1055 : u32 = bsdf_sampled_0.lobe;
                    var _S1056 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S1057 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S1058 : f32 = bsdf_sampled_0.pdf;
                    var _S1059 : f32 = select(_S1058, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S1059;
                    dir_12 = _S1056;
                    lobe_index_0 = _S1055;
                    wrong_side_0 = wrong_side_1;
                    refracted_5 = _S1057;
                }
                else
                {
                    dir_12 = r_6.dir;
                    lobe_index_0 = _S1030;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S986)
            {
                _S987 = true;
            }
            else
            {
                _S987 = _S961;
            }
            var throughput_9 : vec3<f32>;
            var throughput_10 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S987)
            {
                var _S1060 : vec3<f32> = ray_2.unit_direction;
                var _S1061 : f32 = (sign((_S932)));
                var _S1062 : vec3<f32> = _S931.smooth_n * vec3<f32>(_S1061);
                var _S1063 : f32 = dot(_S1062, dir_12);
                var _S1064 : f32 = _S930.material.roughness;
                var _S1065 : f32 = _S1064 * _S1064;
                var _S1066 : AnisotropicFrame = anisotropicFrame(_S930.material, _S1062);
                var _S1067 : vec3<f32> = reflectedHalf(_S1060, dir_12);
                var _S1068 : bool = lobe_index_0 == u32(1);
                if(_S1068)
                {
                    var _S1069 : vec3<f32> = refractedHalf(_S1060, dir_12, _S931.smooth_n, _S933.x, _S933.y);
                    throughput_9 = _S1069;
                }
                else
                {
                    throughput_9 = _S1067;
                }
                var _S1070 : bool = lobe_index_0 == u32(0);
                if(_S1070)
                {
                    _S988 = true;
                }
                else
                {
                    _S988 = lobe_index_0 == u32(6);
                }
                if(_S988)
                {
                    var _S1071 : vec3<f32> = sampledHalf(_S1060, _S931.smooth_n, _S930.material, surface_4.random_state, _S1066);
                    throughput_10 = _S1071;
                }
                else
                {
                    throughput_10 = throughput_9;
                }
                var _S1072 : vec3<f32> = ((-(_S1060)));
                var _S1073 : f32 = _S933.x;
                var _S1074 : f32 = _S933.y;
                var _S1075 : BSDFLobes = bsdfLobes(_S1060, _S1072, _S1062, throughput_10, _S930.material, _S1073, _S1074, _S1066);
                var lobe_terms_2 : BSDFLobes = _S1075;
                var _S1076 : f32 = translucentShare(_S930.material);
                lobe_terms_2.translucent_share = _S1076;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S1077 : f32 = diffusePDF(_S1063, 0.0f, abs(_S932), _S1065, lobe_terms_2, _S1073, _S1074);
                        var _S1078 : vec3<f32> = diffuseBSDF(dir_12, _S1062, _S1065, _S930.material, lobe_terms_2);
                        density_5 = _S1077;
                        chain_throughput_1 = _S1078;
                    }
                case u32(1):
                    {
                        var _S1079 : f32 = refractPDF(_S1063, dot(dir_12, throughput_10), abs(_S932), _S1065, lobe_terms_2, _S1073, _S1074);
                        var _S1080 : vec3<f32> = refractBSDF(dir_12, _S1062, _S1065, _S930.material, lobe_terms_2);
                        density_5 = _S1079;
                        chain_throughput_1 = _S1080;
                    }
                case u32(4):
                    {
                        var _S1081 : f32 = sheenVelvetPDF(_S1063, 0.0f, abs(_S932), _S1065, lobe_terms_2, _S1073, _S1074);
                        var _S1082 : vec3<f32> = sheenVelvetBSDF(dir_12, _S1062, _S1065, _S930.material, lobe_terms_2);
                        density_5 = _S1081;
                        chain_throughput_1 = _S1082;
                    }
                default :
                    {
                        var _S1083 : f32 = reflectPDF(_S1063, 0.0f, abs(_S932), _S1065, lobe_terms_2, _S1073, _S1074);
                        var _S1084 : vec3<f32> = reflectBSDF(dir_12, _S1062, _S1065, _S930.material, lobe_terms_2);
                        density_5 = _S1083;
                        chain_throughput_1 = _S1084;
                    }
                }
                var _S1085 : bool = density_5 > 0.0f;
                if(_S1085)
                {
                    var _S1086 : SampleBSDF = SampleBSDF_x24init_0(dir_12, chain_throughput_1, surface_4.random_state, _S1068, lobe_index_0, density_5);
                    lobe_2 = _S1086;
                }
            }
            var _S1087 : bool = lobe_index_0 == u32(0);
            if(_S1087)
            {
                _S988 = true;
            }
            else
            {
                _S988 = lobe_index_0 == u32(4);
            }
            if(_S988)
            {
                _S1024 = true;
            }
            else
            {
                _S1024 = lobe_index_0 == u32(6);
            }
            var _S1088 : bool = !_S1024;
            if(_S1088)
            {
                var _S1089 : bool = (_S930.material.roughness) == 0.0f;
                if(_S1089)
                {
                    _S1025 = true;
                }
                else
                {
                    var _S1090 : bool = lobe_index_0 == u32(1);
                    if(_S1090)
                    {
                        _S1025 = (_S933.x) == (_S933.y);
                    }
                    else
                    {
                        _S1025 = false;
                    }
                }
            }
            else
            {
                _S1025 = false;
            }
            var _S1091 : bool = lobe_index_0 == u32(1);
            if(_S1091)
            {
                straight_0 = (_S930.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S1092 : bool = isTranslucent_0(_S930.material);
            if(_S1092)
            {
                _S1026 = _S1087;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                _S1027 = (dot(dir_12, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S1027 = false;
            }
            var _S1093 : bool;
            if(_S934)
            {
                _S1093 = !_S1025;
            }
            else
            {
                _S1093 = false;
            }
            var _S1094 : bool;
            if(_S1093)
            {
                _S1094 = !wrong_side_0;
            }
            else
            {
                _S1094 = false;
            }
            var _S1095 : bool;
            if(_S1094)
            {
                var _S1096 : f32 = lobe_2.pdf;
                var _S1097 : vec3<f32> = ray_2.origin;
                var _S1098 : bool = isTranslucent_0(_S930.material);
                var _S1099 : vec3<f32> = select(_S931.smooth_n, _S890, _S1098);
                var _S1100 : vec3<f32> = ray_2.origin;
                var _S1101 : Surface = surface_4;
                var _S1102 : vec3<f32> = (vec3<f32>(0) - _S931.smooth_n);
                var _S1103 : vec3<f32> = select(_S931.smooth_n, _S1102, _S1027);
                var _S1104 : NEEVertex = NEEVertex_x24init_0(false, _S1096, _S1097, _S1099, _S1100 + vec3<f32>(_S1101.geometry_offset) * _S1103);
                nee_vertex_0 = _S1104;
            }
            else
            {
                var _S1105 : bool = lobe_index_0 != u32(1);
                if(_S1105)
                {
                    _S1095 = true;
                }
                else
                {
                    _S1095 = (_S933.x) != (_S933.y);
                }
                if(_S1095)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S1106 : bool = withinInverseFootprint(lobe_2.pdf, _S1024, prev_0.cos, hit_2.distance, threshold_2);
            var _S1107 : bool = roughLobe(lobe_2.pdf, _S1024, _S930.material.roughness);
            if(_S961)
            {
                var _S1108 : bool = !_S1106;
                if(_S1108)
                {
                    return _S891;
                }
                var _S1109 : bool = _S895 != u32(1);
                if(_S1109)
                {
                    _S1095 = _S895 != u32(2);
                }
                else
                {
                    _S1095 = false;
                }
                if(_S1095)
                {
                    var _S1110 : f32 = lobe_2.pdf;
                    var _S1111 : f32 = select(0.0f, _S1110, _S934);
                    var _S1112 : f32 = escapeWeight_0(_S1111, r_6.dir);
                    if(_S969)
                    {
                        is_inside_4 = _S901;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S1113 : f32 = select(1.0f, _S1112, is_inside_4);
                    return Shift_x24init_0(throughput_7 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_6.radiance * vec3<f32>(_S1113) / vec3<f32>(r_6.jac), density_3 * lobe_2.pdf / r_6.jac);
                }
                var _S1114 : vec3<f32> = throughput_7 * vec3<f32>(lobe_2.pdf);
                var _S1115 : f32 = density_3 * lobe_2.pdf;
                throughput_9 = _S1114;
                density_5 = _S1115;
            }
            else
            {
                throughput_9 = throughput_7;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S1095 = b_5 <= _S905;
            }
            else
            {
                _S1095 = false;
            }
            var _S1116 : bool;
            if(_S1095)
            {
                _S1116 = _S929;
            }
            else
            {
                _S1116 = false;
            }
            var _S1117 : bool;
            if(_S1116)
            {
                _S1117 = _S1106;
            }
            else
            {
                _S1117 = false;
            }
            var _S1118 : bool;
            if(_S1117)
            {
                _S1118 = true;
            }
            else
            {
                if(_S986)
                {
                    _S1118 = !_S1107;
                }
                else
                {
                    _S1118 = false;
                }
            }
            if(_S1118)
            {
                return _S891;
            }
            if(_S986)
            {
                var _S1119 : vec3<f32> = throughput_9 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1120 : f32 = lobe_2.pdf;
                throughput_10 = _S1119;
                survival_probability_0 = _S1120;
            }
            else
            {
                var _S1121 : vec3<f32> = throughput_9 * max(lobe_2.throughput, _S890);
                throughput_10 = _S1121;
                survival_probability_0 = density_5;
            }
            var _S1122 : bool;
            if(_S939)
            {
                _S1122 = !_S951;
            }
            else
            {
                _S1122 = false;
            }
            var _S1123 : bool;
            if(_S1122)
            {
                _S1123 = _S929;
            }
            else
            {
                _S1123 = false;
            }
            var _S1124 : bool;
            if(_S1123)
            {
                _S1124 = _S1106;
            }
            else
            {
                _S1124 = false;
            }
            if(_S1124)
            {
                chain_0 = here_0;
                var _S1125 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1126 : u32 = select(u32(0), u32(1), _S934);
                var _S1127 : u32 = (insertBits((_S1125), (_S1126), (u32(21)), (u32(1))));
                chain_0.path = _S1127;
                var _S1128 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S1128;
                chain_0.dir = dir_12;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1129 : Vertex = Vertex_x24init_0(_S1107, lobe_index_0, lobe_2.pdf, abs(dot(surface_4.geometry_n, dir_12)), is_inside_4);
            prev_0 = _S1129;
            var _S1130 : f32 = lobe_2.pdf;
            var _S1131 : bool;
            if(_S1091)
            {
                _S1131 = (_S933.x) == (_S933.y);
            }
            else
            {
                _S1131 = false;
            }
            var _S1132 : f32 = select(_S1130, sky_pdf_0, _S1131);
            var _S1133 : bool;
            if(refracted_5)
            {
                _S1133 = !_S1027;
            }
            else
            {
                _S1133 = false;
            }
            var is_inside_5 : bool;
            if(_S1133)
            {
                var _S1134 : bool = !is_inside_4;
                is_inside_5 = _S1134;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_12;
            var _S1135 : Surface = surface_4;
            var _S1136 : f32 = select(_S1135.geometry_offset, 0.0f, straight_0);
            var _S1137 : vec3<f32> = (vec3<f32>(0) - _S931.smooth_n);
            var _S1138 : bool = is_inside_5 != _S1027;
            var _S1139 : vec3<f32> = select(_S931.smooth_n, _S1137, _S1138);
            var _S1140 : vec3<f32> = ray_2.origin + vec3<f32>(_S1136) * _S1139;
            ray_2.origin = _S1140;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_5 = throughput_10;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1132;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            straight_0 = false;
            throughput_5 = throughput_7;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S939)
        {
            if(_S913)
            {
                var _S1141 : vec3<f32> = throughput_5 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1142 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1143 : bool = _S1142 == u32(1);
                if(_S1143)
                {
                    var _S1144 : vec3<f32> = safeDivide(_S1141, chain_throughput_0);
                    candidate_6.radiance = _S1144;
                }
                var _S1145 : Reservoir = withEnd(candidate_6, u32(2), b_5, _S1141);
                offer(&((*sel_4)), _S1145, _S1141 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S913)
            {
                _S986 = true;
            }
            else
            {
                _S986 = scatter_0;
            }
            if(_S986)
            {
                var _S1146 : f32 = survivalProbability(throughput_5, density_5);
                survival_probability_0 = _S1146;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1147 : u32 = stream(r_6.seed, b_5 + u32(128));
            var _S1148 : Random = pcg(_S1147);
            var _S1149 : bool = survival_probability_0 < (_S1148.value);
            if(_S1149)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1150 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_5 >= _S1150;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1151 : f32 = density_5 * survival_probability_0;
            density_2 = _S1151;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1152 : Ray = ray_2;
        var _S1153 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S986 = _S962;
        }
        else
        {
            _S986 = false;
        }
        if(_S986)
        {
            wrong_side_0 = _S894 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1154 : f32 = select(4.294967296e+09f, _S1153, wrong_side_0);
        var _S1155 : Hit;
        if(straight_0)
        {
            _S1155 = hit_2;
        }
        else
        {
            _S1155 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1156 : Hit = (traverseInstanceBVH((_S1152), (_S919), (_S1154), (_S1155)));
        hit_2 = _S1156;
        if(replay_0)
        {
            refracted_5 = _S962;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            _S987 = _S894 == u32(1);
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            _S988 = (hit_2.instance_index) == (_S906.instance_index);
        }
        else
        {
            _S988 = false;
        }
        if(_S988)
        {
            _S1024 = (hit_2.triangle_index) == (_S906.triangle_index);
        }
        else
        {
            _S1024 = false;
        }
        if(_S1024)
        {
            hit_2.uv = _S906.uv;
            var _S1157 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1157;
        }
        if(replay_0)
        {
            _S1025 = _S962;
        }
        else
        {
            _S1025 = false;
        }
        if(_S1025)
        {
            _S1026 = _S894 == u32(3);
        }
        else
        {
            _S1026 = false;
        }
        if(_S1026)
        {
            _S1027 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            return _S891;
        }
        var _S1158 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1158)
        {
            var _S1159 : bool = !nee_vertex_0.none;
            var _S1160 : f32 = select(0.0f, sky_pdf_0, _S1159);
            var _S1161 : f32 = escapeWeight_0(_S1160, ray_2.unit_direction);
            var _S1162 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1163 : vec3<f32> = throughput_5 * _S1162;
            if(replay_0)
            {
                if(_S962)
                {
                    is_inside_4 = _S894 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1163 * vec3<f32>(_S1161) / vec3<f32>(r_6.jac), density_2 / r_6.jac);
                }
                if(_S904)
                {
                    is_inside_4 = _S901;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_5 == _S892;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !prev_0.rough;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1163 * vec3<f32>(_S1161), 1.0f);
                }
                return _S891;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1164 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1165 : bool = _S1164 == u32(1);
            if(_S1165)
            {
                var _S1166 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1167 : bool = _S1166 == b_5;
                var _S1168 : f32 = select(_S1161, 1.0f, _S1167);
                var _S1169 : vec3<f32> = safeDivide(_S1163 * vec3<f32>(_S1168), chain_throughput_0);
                candidate_7.radiance = _S1169;
            }
            else
            {
                var _S1170 : bool = prev_0.rough;
                if(_S1170)
                {
                    var _S1171 : u32 = (insertBits((u32(0)), (b_5 + u32(1)), (u32(5)), (u32(5))));
                    var _S1172 : u32 = (insertBits((_S1171), (u32(3)), (u32(10)), (u32(2))));
                    var _S1173 : u32 = (insertBits((_S1172), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1174 : bool = prev_0.inside;
                    var _S1175 : u32 = select(u32(0), u32(1), _S1174);
                    var _S1176 : u32 = (insertBits((_S1173), (_S1175), (u32(22)), (u32(1))));
                    candidate_7.path = _S1176;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1177 : vec3<f32> = _S1163 * vec3<f32>(_S1161);
            var _S1178 : Reservoir = withEnd(candidate_7, u32(3), b_5, _S1177);
            offer(&((*sel_4)), _S1178, _S1177 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1179 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1179;
        var _S1180 : u32 = b_5 + u32(1);
        b_5 = _S1180;
    }
    return _S891;
}

fn shift_0( dom_5 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S1181 : vec3<f32> = vec3<f32>(0.0f);
    var _S1182 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1181, 0.0f, vec4<u32>(u32(0)), _S1181, _S1181), 0.0f, _S1181, u32(0));
    var sel_5 : Selection = _S1182;
    var _S1183 : bool = (r_7.w) <= 0.0f;
    if(_S1183)
    {
        return Shift_x24init_0(_S1181, 0.0f);
    }
    var _S1184 : Shift = walk_0(dom_5, r_7, true, 0.0f, &(sel_5));
    return _S1184;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1185 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1186 : bool = _S1185 != u32(4294967295);
    if(_S1186)
    {
        var _S1187 : vec2<i32> = vec2<i32>((vec2<u32>(_S1185, (_S1185 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1188 : vec3<f32> = vec3<f32>(0.0f);
        var _S1189 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1188, _S1188, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1188, 0.0f, vec4<u32>(u32(0)), _S1188, _S1188));
        var shift_job_0 : ShiftJob = _S1189;
        var _S1190 : u32 = (_S1185 >> (u32(28)));
        var _S1191 : bool = spatialJob_0(_S1187, _S1190, &(shift_job_0));
        var _S1192 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1187), (_S1190), (vec4<u32>((bitcast<vec3<u32>>((_S1192.f))), (bitcast<u32>((_S1192.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1193 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1194 : array<u32, i32(3)>;
    spatialBins_0(_S1193, &(_S1194));
    var _S1195 : array<u32, i32(3)> = _S1194;
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
        var _S1196 : bool = (_S1195[t_16]) == u32(40);
        if(_S1196)
        {
            textureStore(shift_data_out, (_S1193), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1193, _S1195, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1197 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1197));
    countShifts_0(_S1197, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1198 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1199 : bool = _S1198 != u32(4294967295);
    if(_S1199)
    {
        var _S1200 : vec2<i32> = vec2<i32>((vec2<u32>(_S1198, (_S1198 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1201 : vec3<f32> = vec3<f32>(0.0f);
        var _S1202 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1201, _S1201, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1201, 0.0f, vec4<u32>(u32(0)), _S1201, _S1201));
        var shift_job_1 : ShiftJob = _S1202;
        var _S1203 : u32 = (_S1198 >> (u32(28)));
        var _S1204 : bool = temporalJob_0(_S1200, _S1203, &(shift_job_1));
        var _S1205 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1200), (_S1203), (vec4<u32>((bitcast<vec3<u32>>((_S1205.f))), (bitcast<u32>((_S1205.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1206 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1207 : array<u32, i32(3)>;
    temporalBins_0(_S1206, &(_S1207));
    var _S1208 : array<u32, i32(3)> = _S1207;
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
        var _S1209 : bool = (_S1208[t_18]) == u32(40);
        if(_S1209)
        {
            textureStore(temporal_shifts_out, (_S1206), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1206, _S1208, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1210 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1210));
    countShifts_0(_S1210, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1211 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1211;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1212 : f32 = c_3 * p_c_1;
    var _S1213 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1212 / (_S1212 + c_t_0 * g_previous_0), _S1213 / (_S1213 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1214 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1215 : vec3<f32> = vec3<f32>(0.0f);
    var _S1216 : Domain = Domain_x24init_0(_S1215, _S1215, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1216;
    var _S1217 : bool = (currentDomain((_S1214), &(dom_6)));
    var _S1218 : bool = !_S1217;
    if(_S1218)
    {
        storeReservoir(reservoir_temp_out, (_S1214), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1215, 0.0f, vec4<u32>(u32(0)), _S1215, _S1215)), (dom_6.hit));
        return;
    }
    var _S1219 : Reservoir = (loadReservoir(reservoir_initial, (_S1214)));
    var _S1220 : vec2<i32> = temporalNeighbor_0(_S1214, dom_6);
    var _S1221 : bool = (_S1220.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1221)
    {
        var _S1222 : Reservoir = (loadReservoir(reservoir_prev, (_S1220)));
        var _S1223 : vec4<u32> = (textureLoad(duplication, (_S1220), 0, 0));
        var _S1224 : f32 = (bitcast<f32>((_S1223.x)));
        var _S1225 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1226 : bool = _S1225 == u32(1);
        var _S1227 : f32 = select(0.0f, _S1224, _S1226);
        var _S1228 : f32 = confidenceCap(_S1227);
        var _S1229 : f32 = min(_S1222.c, _S1228);
        var _S1230 : vec4<u32> = (textureLoad(temporal_shifts, (_S1214), (u32(0)), 0));
        var _S1231 : vec4<f32> = (bitcast<vec4<f32>>((_S1230)));
        var _S1232 : vec4<f32> = vec4<f32>(_S1219.f, 1.0f);
        var _S1233 : Domain = (previousDomain((_S1220)));
        var _S1234 : bool = sameDomain_0(_S1233, dom_6);
        var _S1235 : bool = !_S1234;
        var to_previous_0 : vec4<f32>;
        if(_S1235)
        {
            var _S1236 : vec4<u32> = (textureLoad(temporal_shifts, (_S1214), (u32(1)), 0));
            var _S1237 : vec4<f32> = (bitcast<vec4<f32>>((_S1236)));
            to_previous_0 = _S1237;
        }
        else
        {
            to_previous_0 = _S1232;
        }
        var _S1238 : f32 = rgb_to_greyscale(_S1219.f);
        var _S1239 : f32 = rgb_to_greyscale(_S1222.f);
        var _S1240 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1215, 0.0f, vec4<u32>(u32(0)), _S1215, _S1215), 0.0f, _S1215, u32(0));
        var sel_6 : Selection = _S1240;
        var _S1241 : u32 = (uniforms_uint.frame);
        var _S1242 : u32 = hash(_S1241);
        var _S1243 : u32 = global_invocation_id_7.x;
        var _S1244 : vec2<u32> = (uniforms_uint.render_size);
        var _S1245 : u32 = stream(_S1242, _S1243 + _S1244.x * global_invocation_id_7.y);
        var _S1246 : u32 = stream(_S1245, u32(194));
        sel_6.random_state = _S1246;
        var _S1247 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1248 : vec3<f32> = _S1231.xyz;
        var _S1249 : f32 = rgb_to_greyscale(_S1248);
        var _S1250 : vec2<f32> = temporalWeights(_S1219.c, _S1238, _S1229, _S1239, _S1247, _S1249);
        offerShifted(&(sel_6), _S1219, Shift_x24init_0(_S1219.f, 1.0f), _S1250.x);
        offerShifted(&(sel_6), _S1222, Shift_x24init_0(_S1248, _S1231.w), _S1250.y);
        var _S1251 : Reservoir = finalize(sel_6, _S1219.c + _S1229);
        r_8 = _S1251;
    }
    else
    {
        r_8 = _S1219;
    }
    storeReservoir(reservoir_temp_out, (_S1214), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1252 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1253 : vec3<f32> = vec3<f32>(0.0f);
    var _S1254 : Domain = Domain_x24init_0(_S1253, _S1253, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1254;
    var _S1255 : bool = (currentDomain((_S1252), &(dom_7)));
    var _S1256 : bool = !_S1255;
    if(_S1256)
    {
        storeReservoir(reservoir_initial_out, (_S1252), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1253, 0.0f, vec4<u32>(u32(0)), _S1253, _S1253)), (dom_7.hit));
        return;
    }
    var _S1257 : u32 = (uniforms_uint.frame);
    var _S1258 : u32 = hash(_S1257);
    var _S1259 : u32 = global_invocation_id_8.x;
    var _S1260 : vec2<u32> = (uniforms_uint.render_size);
    var _S1261 : u32 = stream(_S1258, _S1259 + _S1260.x * global_invocation_id_8.y);
    var _S1262 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1253, 0.0f, vec4<u32>(u32(0)), _S1253, _S1253);
    var _S1263 : Selection = Selection_x24init_0(_S1262, 0.0f, _S1253, u32(0));
    var initial_0 : Selection = _S1263;
    var _S1264 : u32 = stream(_S1261, u32(193));
    initial_0.random_state = _S1264;
    var i_7 : u32 = u32(0);
    loop
    {
        var _S1265 : u32 = (uniforms_uint.samples);
        if(i_7 < _S1265)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1262;
        var _S1266 : u32 = stream(_S1261, i_7);
        r_9.seed = _S1266;
        var _S1267 : u32 = (uniforms_uint.samples);
        var _S1268 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1267), &(initial_0));
        var i_8 : u32 = i_7 + u32(1);
        i_7 = i_8;
    }
    var _S1269 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1252), (_S1269), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1270 : Random = pcg(state_3);
    var _S1271 : Random = pcg(_S1270.state);
    var _S1272 : f32 = 6.28318548202514648f * _S1270.value;
    var _S1273 : f32 = sqrt(-2.0f * clamp(log(_S1271.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1271.state, _S1273 * cos(_S1272));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1274 : RandomSphere;
    _S1274.state = state_4;
    _S1274.value = value_1;
    return _S1274;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1275 : Random = normal_distribution(state_5);
    var _S1276 : Random = normal_distribution(_S1275.state);
    var _S1277 : Random = normal_distribution(_S1276.state);
    var _S1278 : vec3<f32> = (normalize((vec3<f32>(_S1275.value, _S1276.value, _S1277.value))));
    return RandomSphere_x24init_0(_S1277.state, _S1278);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_13 : vec3<f32>) -> mat3x3<f32>
{
    var _S1279 : vec3<f32> = p1_0 - p0_0;
    var _S1280 : vec3<f32> = p2_0 - p0_0;
    var _S1281 : vec2<f32> = uv1_0 - uv0_0;
    var _S1282 : vec2<f32> = uv2_0 - uv0_0;
    var _S1283 : f32 = _S1281.x;
    var _S1284 : f32 = _S1282.y;
    var _S1285 : f32 = _S1281.y;
    var _S1286 : f32 = _S1282.x;
    var _S1287 : f32 = _S1283 * _S1284 - _S1285 * _S1286;
    var _S1288 : f32 = 1.0f / _S1287;
    var _S1289 : vec3<f32> = vec3<f32>(_S1288);
    var t_20 : vec3<f32> = (_S1279 * vec3<f32>(_S1284) - _S1280 * vec3<f32>(_S1285)) * _S1289;
    var _S1290 : vec3<f32> = (_S1280 * vec3<f32>(_S1283) - _S1279 * vec3<f32>(_S1286)) * _S1289;
    var t_21 : vec3<f32> = (normalize((t_20 - n_13 * vec3<f32>(dot(n_13, t_20)))));
    var _S1291 : bool = (dot(cross(n_13, t_21), _S1290)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1291)
    {
        var _S1292 : vec3<f32> = ((-(t_21)));
        t_22 = _S1292;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1293 : vec3<f32> = cross(n_13, t_22);
    return mat3x3<f32>(t_22, _S1293, n_13);
}

fn tangentToWorldNormalMap( v_4 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_4)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1294 : vec3<f32> = t1_0 - t0_0;
    var _S1295 : vec3<f32> = t2_2 - t0_0;
    var _S1296 : vec3<f32> = t2_2 - t1_0;
    var _S1297 : f32 = min(length(_S1294), min(length(_S1295), length(_S1296)));
    var _S1298 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1299 : vec3<f32> = (normalize((n0_0)));
    var _S1300 : f32 = dot(geometry_n_5, _S1299);
    var _S1301 : vec3<f32> = (normalize((n1_0)));
    var _S1302 : f32 = dot(geometry_n_5, _S1301);
    var _S1303 : vec3<f32> = (normalize((n2_0)));
    var _S1304 : vec3<f32> = acos(abs(vec3<f32>(_S1300, _S1302, dot(geometry_n_5, _S1303))));
    var _S1305 : vec3<f32> = clamp(tan(_S1304), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1298 * _S1305, uvw_0), 0.0f, _S1297 * 0.125f);
}

fn straightThrough( dir_13 : vec3<f32>,  n_14 : vec3<f32>,  material_23 : Material) -> vec3<f32>
{
    var _S1306 : vec3<f32> = ((-(dir_13)));
    var _S1307 : f32 = (sign((dot(n_14, _S1306))));
    var _S1308 : vec3<f32> = n_14 * vec3<f32>(_S1307);
    var _S1309 : AnisotropicFrame = anisotropicFrame(material_23, _S1308);
    var _S1310 : bool = (_S1309.alphas.x) > 0.0f;
    if(_S1310)
    {
        var _S1311 : f32 = material_23.transmission * (1.0f - material_23.metallic);
        var _S1312 : vec3<f32> = ((-(_S1308)));
        var _S1313 : vec3<f32> = anisotropicLocal(dir_13, _S1309.tangent, _S1312);
        var _S1314 : f32 = anisotropicG1(_S1313, _S1309.alphas);
        return vec3<f32>((_S1311 * _S1314)) * material_23.albedo;
    }
    var _S1315 : f32 = material_23.transmission * (1.0f - material_23.metallic);
    var _S1316 : f32 = material_23.roughness;
    var _S1317 : f32 = smithG1(_S1316 * _S1316, abs(dot(n_14, dir_13)));
    return vec3<f32>((_S1315 * _S1317)) * material_23.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_15 : vec3<f32>,  material_24 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1318 : vec3<f32>;
    if((material_24.ior) == 1.0f)
    {
        var _S1319 : vec3<f32> = straightThrough(toward_1, n_15, material_24);
        _S1318 = _S1319;
    }
    else
    {
        _S1318 = vec3<f32>(0.0f);
    }
    return _S1318 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1320 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1320;
}

fn shift_hook( dom_9 : Domain,  r_11 : Reservoir) -> Shift
{
    var _S1321 : Shift = shift_0(dom_9, r_11);
    return _S1321;
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

