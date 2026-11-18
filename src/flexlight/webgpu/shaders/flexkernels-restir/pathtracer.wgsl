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

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenAlbedo( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_1 : Material) -> f32
{
    var _S250 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S251 : bool = _S250 > 0.0f;
    var albedo_0 : f32;
    if(_S251)
    {
        var _S252 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S253 : u32 = min(u32(_S252), u32(22));
        var _S254 : f32 = sqrt(0.05000000074505806f);
        var _S255 : f32 = sqrt(0.10000000149011612f);
        var _S256 : bool = (material_1.velvet) > 0.0f;
        var _S257 : f32 = select(_S254, _S255, _S256);
        var _S258 : f32 = (clamp(sqrt(max(material_1.sheen_roughness, 0.0f)), _S257, 1.0f) - _S257) / (1.0f - _S257) * 23.0f;
        var _S259 : u32 = min(u32(_S258), u32(22));
        var _S260 : u32 = _S253 * u32(24) + _S259;
        var _S261 : f32 = _S252 - f32(_S253);
        var _S262 : f32 = _S258 - f32(_S259);
        if(_S256)
        {
            var _S263 : u32 = _S260 + u32(24);
            var _S264 : f32 = VELVET_ALBEDO_0[_S260] + (VELVET_ALBEDO_0[_S263] - VELVET_ALBEDO_0[_S260]) * _S261;
            var _S265 : u32 = _S260 + u32(1);
            var _S266 : f32 = VELVET_ALBEDO_0[_S265] + (VELVET_ALBEDO_0[_S263 + u32(1)] - VELVET_ALBEDO_0[_S265]) * _S261;
            var _S267 : f32 = _S264 + (_S266 - _S264) * _S262;
            albedo_0 = _S267;
        }
        else
        {
            var _S268 : u32 = _S260 + u32(24);
            var _S269 : f32 = SHEEN_ALBEDO_0[_S260] + (SHEEN_ALBEDO_0[_S268] - SHEEN_ALBEDO_0[_S260]) * _S261;
            var _S270 : u32 = _S260 + u32(1);
            var _S271 : f32 = SHEEN_ALBEDO_0[_S270] + (SHEEN_ALBEDO_0[_S268 + u32(1)] - SHEEN_ALBEDO_0[_S270]) * _S261;
            var _S272 : f32 = exp(_S269 + (_S271 - _S269) * _S262);
            albedo_0 = _S272;
        }
    }
    else
    {
        albedo_0 = 0.0f;
    }
    return albedo_0;
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
    var _S273 : BSDFLobes;
    _S273.v_dot_h = v_dot_h_0;
    _S273.n_dot_h = n_dot_h_0;
    _S273.refracted = refracted_1;
    _S273.F = F_0;
    _S273.F_greyscale = F_greyscale_0;
    _S273.reflect_weight = reflect_weight_0;
    _S273.diffuse_weight = diffuse_weight_0;
    _S273.refract_weight = refract_weight_0;
    _S273.p_diffuse = p_diffuse_0;
    _S273.p_reflect = p_reflect_0;
    _S273.p_refract = p_refract_0;
    _S273.translucent_share = translucent_share_0;
    _S273.sheen = sheen_0;
    _S273.p_sheen_velvet = p_sheen_velvet_0;
    _S273.view = view_1;
    _S273.tangent = tangent_1;
    _S273.alphas = alphas_1;
    _S273.visible = visible_0;
    return _S273;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S274 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S275 : f32 = _S274.x;
    var _S276 : f32 = _S274.y;
    var _S277 : f32 = _S275 * _S275 + _S276 * _S276;
    const _S278 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S279 : vec3<f32> = vec3<f32>(- _S276, _S275, 0.0f);
    var _S280 : f32 = (inverseSqrt((_S277)));
    var _S281 : vec3<f32> = _S279 * vec3<f32>(_S280);
    var _S282 : bool = _S277 > 0.0f;
    var _S283 : vec3<f32> = select(_S278, _S281, _S282);
    var _S284 : vec3<f32> = cross(_S274, _S283);
    var _S285 : f32 = sqrt(U1_0);
    var _S286 : f32 = 6.28318548202514648f * U2_0;
    var _S287 : f32 = _S285 * cos(_S286);
    var t2_0 : f32 = _S285 * sin(_S286);
    var _S288 : f32 = 0.5f * (1.0f + _S274.z);
    var t2_1 : f32 = (1.0f - _S288) * sqrt(max(0.0f, 1.0f - _S287 * _S287)) + _S288 * t2_0;
    var _S289 : vec3<f32> = vec3<f32>(_S287) * _S283 + vec3<f32>(t2_1) * _S284;
    var _S290 : f32 = ((_S287));
    var _S291 : f32 = ((_S287));
    var _S292 : vec3<f32> = _S289 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S290 * _S291 - t2_1 * t2_1))) * _S274;
    var _S293 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S292.x, alpha_0 * _S292.y, max(0.0f, _S292.z)))));
    return _S293;
}

fn worldToTangent( v_2 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S294 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S294)
    {
        const _S295 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S295;
    }
    else
    {
        a_4 = a_3;
    }
    var _S296 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S297 : vec3<f32> = cross(n_3, _S296);
    return vec3<f32>(dot(v_2, _S296), dot(v_2, n_3), dot(v_2, _S297));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S298 : Random = pcg((*random_state_0));
    var _S299 : Random = pcg(_S298.state);
    (*random_state_0) = _S299.state;
    var _S300 : f32 = frame_0.alphas.x;
    var _S301 : bool = _S300 > 0.0f;
    if(_S301)
    {
        var _S302 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S303 : f32 = frame_0.alphas.y;
        var _S304 : vec3<f32> = (normalize((vec3<f32>(_S300 * _S302.x, _S303 * _S302.y, _S302.z))));
        var _S305 : vec3<f32> = sampleGGXVNDF(_S304, 1.0f, _S298.value, _S299.value);
        var _S306 : vec3<f32> = (normalize((vec3<f32>(_S300 * _S305.x, _S303 * _S305.y, _S305.z))));
        return vec3<f32>(_S306.x) * frame_0.tangent + vec3<f32>(_S306.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S306.z) * n_i_2;
    }
    var _S307 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S308 : vec3<f32> = sampleGGXVNDF(_S307.xzy, alpha_1, _S298.value, _S299.value);
    var _S309 : vec3<f32> = _S308.xzy;
    var _S310 : vec3<f32> = tangentToWorld(_S309, n_i_2);
    return _S310;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_2 : Material,  random_state_1 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_1;
    var _S311 : vec3<f32> = ((-(in_dir_0)));
    var _S312 : f32 = (sign((dot(n_4, _S311))));
    var _S313 : f32 = material_2.roughness;
    var _S314 : vec3<f32> = sampleHalfVector(_S311, n_4 * vec3<f32>(_S312), _S313 * _S313, frame_1, &(state_2));
    return _S314;
}

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S315 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S316 : f32 = eta_i_0 / eta_o_0 * _S315;
    var _S317 : bool = _S316 < 1.0f;
    var kr_0 : f32;
    if(_S317)
    {
        var _S318 : f32 = sqrt(max(0.0f, 1.0f - _S316 * _S316));
        var _S319 : f32 = eta_o_0 * cos_theta_0;
        var _S320 : f32 = eta_i_0 * _S318;
        var _S321 : f32 = (_S319 - _S320) / (_S319 + _S320);
        var _S322 : f32 = eta_i_0 * cos_theta_0;
        var _S323 : f32 = eta_o_0 * _S318;
        var _S324 : f32 = (_S322 - _S323) / (_S322 + _S323);
        var _S325 : f32 = (_S321 * _S321 + _S324 * _S324) / 2.0f;
        kr_0 = _S325;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S326 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S326 / (_S326 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S326)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S327 : f32 = alphas_3.x;
    var _S328 : f32 = h_0.x / _S327;
    var _S329 : f32 = alphas_3.y;
    var _S330 : f32 = h_0.y / _S329;
    var _S331 : f32 = h_0.z;
    var _S332 : f32 = _S328 * _S328 + _S330 * _S330 + _S331 * _S331;
    return 1.0f / max(3.14159274101257324f * _S327 * _S329 * _S332 * _S332, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_1 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_3 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_2 : AnisotropicFrame,  sheen_albedo_0 : f32) -> BSDFLobes
{
    var _S333 : f32 = dot(ggx_n_0, v_4);
    var _S334 : f32 = dot(n_i_3, ggx_n_0);
    var _S335 : f32 = eta_i_1 / eta_o_1;
    var _S336 : vec3<f32> = (normalize((refract(in_dir_1, ggx_n_0, _S335))));
    var _S337 : f32 = min(sqrt(material_3.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S338 : f32 = _S337 * _S337;
    var _S339 : f32 = (1.0f + _S337) / (1.0f - _S337);
    var _S340 : f32 = abs(_S333);
    var _S341 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S341)
    {
        sheen_component_0 = _S339;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S341)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S339;
    }
    var _S342 : f32 = fresnel(_S340, sheen_component_0, visible_1);
    var _S343 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S333 * _S333)) >= (eta_o_1 * eta_o_1);
    var _S344 : vec3<f32>;
    if(_S343)
    {
        _S344 = vec3<f32>(1.0f);
    }
    else
    {
        var _S345 : vec3<f32> = material_3.specular_tint * vec3<f32>(_S338);
        _S344 = _S345 + (vec3<f32>(1.0f) - _S345) * vec3<f32>((_S342 - _S338)) / vec3<f32>((1.0f - _S338));
    }
    var _S346 : vec3<f32> = vec3<f32>(1.0f);
    var _S347 : vec3<f32> = vec3<f32>(0.0f);
    var _S348 : f32 = rgb_to_greyscale(material_3.sheen);
    var _S349 : bool = _S348 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S349)
    {
        var _S350 : f32 = min(sheen_albedo_0, 1.0f);
        var _S351 : vec3<f32> = vec3<f32>(1.0f) - material_3.sheen * vec3<f32>(_S350);
        var _S352 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S353 : f32 = _S352 * _S350;
        var _S354 : vec3<f32> = material_3.sheen / vec3<f32>(max(sheen_albedo_0, 1.0f));
        scale_0 = _S351;
        sheen_component_0 = _S353;
        sheen_1 = _S354;
        view_2 = v_4;
    }
    else
    {
        scale_0 = _S346;
        sheen_component_0 = 0.0f;
        sheen_1 = _S347;
        view_2 = _S347;
    }
    var _S355 : f32 = frame_2.alphas.x;
    var _S356 : f32 = sqrt(min(_S355, frame_2.alphas.y));
    var _S357 : bool = _S355 > 0.0f;
    var _S358 : f32 = select(material_3.roughness, _S356, _S357);
    var _S359 : f32 = _S358 * _S358;
    var _S360 : f32 = pow(_S359, 1.81585001945495605f) * (2.15371990203857422f - 0.73285001516342163f * _S359) / (1.0f + 1.28094995021820068f * _S359);
    var _S361 : bool = _S359 > 0.0f;
    var _S362 : f32 = select(0.0f, _S360, _S361);
    var _S363 : f32 = clamp(dot(n_i_3, v_4), 0.0f, 1.0f);
    var _S364 : f32 = _S359 * _S358;
    var _S365 : f32 = min(1.00064504146575928f - _S358 * (0.00375499995425344f + _S363 * (-0.04133399948477745f + _S363 * (-0.90938502550125122f + _S363 * 0.35275399684906006f))) - _S359 * (0.27602800726890564f + _S363 * (1.27023398876190186f + _S363 * 0.04740000143647194f)) - _S364 * (0.31452900171279907f - _S363 * 0.34830701351165771f) + _S364 * _S358 * 0.27229699492454529f, 1.0f);
    var _S366 : vec3<f32> = vec3<f32>(1.0f);
    var _S367 : vec3<f32> = min(_S366 / (_S366 - material_3.albedo * vec3<f32>(_S362)), vec3<f32>((1.0f / max(_S365, 0.0000152587890625f))));
    var _S368 : vec3<f32> = (mix((_S344), (material_3.albedo * _S367), (material_3.metallic)));
    var F_1 : vec3<f32> = _S368 * scale_0;
    var _S369 : f32 = rgb_to_greyscale(F_1);
    var _S370 : f32 = 1.0f - material_3.metallic;
    var _S371 : vec3<f32> = _S366 - _S344;
    var _S372 : vec3<f32> = vec3<f32>(((1.0f - material_3.transmission) * _S370)) * _S371 * scale_0;
    var _S373 : vec3<f32> = vec3<f32>((material_3.transmission * _S370)) * _S371 * scale_0;
    var _S374 : f32 = max(_S369, 0.0f);
    var _S375 : f32 = rgb_to_greyscale(_S372);
    var _S376 : f32 = max(_S375, 0.0f);
    var _S377 : f32 = rgb_to_greyscale(_S373);
    var _S378 : f32 = (sign((length(_S336))));
    var _S379 : f32 = max(_S377 * _S378, 0.0f);
    var _S380 : f32 = _S374 + _S376 + _S379;
    var _S381 : f32 = min(sheen_component_0, 1.0f);
    var _S382 : bool = sheen_component_0 > 0.0f;
    var _S383 : bool;
    if(_S382)
    {
        _S383 = !(_S380 > 0.0f);
    }
    else
    {
        _S383 = false;
    }
    var _S384 : f32 = select(_S381, 1.0f, _S383);
    var _S385 : f32 = (1.0f - _S384) / max(_S380, 0.0000152587890625f);
    var _S386 : f32 = _S376 * _S385;
    var _S387 : f32 = _S374 * _S385;
    var _S388 : f32 = _S379 * _S385;
    if(_S357)
    {
        var _S389 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S390 : f32 = anisotropicG1(_S389, frame_2.alphas);
        var _S391 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S392 : f32 = anisotropicD(_S391, frame_2.alphas);
        var _S393 : f32 = _S390 * _S392;
        visible_1 = _S393;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S333, _S334, _S336, F_1, _S369, 1.0f, _S372, _S373, _S386, _S387, _S388, 0.0f, sheen_1, _S384, view_2, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_4 : Material) -> f32
{
    var _S394 : f32 = rgb_to_greyscale(material_4.translucent);
    var _S395 : f32 = rgb_to_greyscale(material_4.albedo);
    var _S396 : f32 = _S394 / (_S395 + _S394);
    var _S397 : bool = _S394 > 0.0f;
    var _S398 : f32 = select(0.0f, _S396, _S397);
    return _S398;
}

fn refractedHalf( in_dir_2 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  eta_i_2 : f32,  eta_o_2 : f32) -> vec3<f32>
{
    var _S399 : vec3<f32> = ((-(in_dir_2)));
    var _S400 : vec3<f32> = ((-(vec3<f32>(eta_i_2) * _S399 + vec3<f32>(eta_o_2) * out_dir_0)));
    var _S401 : vec3<f32> = (normalize((_S400)));
    var _S402 : f32 = (sign((dot(n_5, _S399))));
    var _S403 : f32 = (sign((dot(_S400, n_5 * vec3<f32>(_S402)))));
    return _S401 * vec3<f32>(_S403);
}

fn reflectedHalf( in_dir_3 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S404 : vec3<f32> = ((-(in_dir_3)));
    var _S405 : vec3<f32> = (normalize((_S404 + out_dir_1)));
    return _S405;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S406 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S407 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S408 : f32 = 1.0f - lobes_0.translucent_share;
    var _S409 : bool = n_i_dot_l_0 < 0.0f;
    var _S410 : f32 = select(_S408, lobes_0.translucent_share, _S409);
    var _S411 : f32 = _S407 * _S410;
    var _S412 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S413 : f32 = select(_S406, _S411, _S412);
    var _S414 : bool = n_i_dot_v_0 > 0.0f;
    var _S415 : f32 = select(0.0f, _S413, _S414);
    return _S415;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_5 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S416 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S417 : vec3<f32> = select(material_5.albedo, material_5.translucent, _S416);
    var _S418 : f32 = 1.0f - lobes_1.translucent_share;
    var _S419 : f32 = select(_S418, lobes_1.translucent_share, _S416);
    var _S420 : vec3<f32> = _S417 / vec3<f32>(_S419);
    var _S421 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S422 : vec3<f32> = select(material_5.albedo, _S420, _S421);
    return lobes_1.diffuse_weight * _S422 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S423 : f32 = alpha_4 * alpha_4;
    var _S424 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S423 + (1.0f - _S423) * n_dot_x_0 * n_dot_x_0));
    var _S425 : bool = alpha_4 > 0.0f;
    var _S426 : f32 = select(1.0f, _S424, _S425);
    return _S426;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S427 : f32 = alpha_5 * alpha_5;
    var _S428 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S427 * n_dot_h_1 * n_dot_h_1;
    return _S427 / max(3.14159274101257324f * _S428 * _S428, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S429 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S430 : f32 = _S429 * lobes_2.v_dot_h;
    var _S431 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S432 : f32 = _S430 * _S431 / n_i_dot_v_1;
    var _S433 : bool = alpha_6 > 0.0f;
    var _S434 : bool;
    if(_S433)
    {
        _S434 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        _S434 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        _S434 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S434 = false;
    }
    var _S435 : f32 = select(0.0f, _S432, _S434);
    var _S436 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S436)
    {
        var _S437 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S438 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S438)
        {
            _S434 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S434 = false;
        }
        if(_S434)
        {
            _S434 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S434 = false;
        }
        var _S439 : f32 = select(0.0f, _S437, _S434);
        pdf_h_0 = _S439;
    }
    else
    {
        pdf_h_0 = _S435;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S440 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S441 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S442 : f32 = lobes_3.p_refract * _S440 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S441 * _S441);
    var _S443 : bool = eta_i_4 != eta_o_4;
    var _S444 : bool;
    if(_S443)
    {
        _S444 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S444 = false;
    }
    var _S445 : f32 = select(0.0f, _S442, _S444);
    return _S445;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_6 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S446 : f32 = - dot(n_i_5, l_1);
    var _S447 : f32 = smithG1(alpha_8, max(_S446, 0.0f));
    var _S448 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S448)
    {
        var _S449 : vec3<f32> = ((-(n_i_5)));
        var _S450 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S449);
        var _S451 : f32 = anisotropicG1(_S450, lobes_4.alphas);
        G1_l_0 = _S451;
    }
    else
    {
        G1_l_0 = _S447;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_6.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S452 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S453 : bool = n_i_dot_l_2 > 0.0f;
    var _S454 : bool;
    if(_S453)
    {
        _S454 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S454 = false;
    }
    var _S455 : f32 = select(0.0f, _S452, _S454);
    return _S455;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_7 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S456 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S457 : f32 = dot(n_i_6, _S456);
    var _S458 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S459 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S460 : f32 = 1.0f / max(material_7.sheen_roughness, 0.05000000074505806f);
    var _S461 : f32 = 1.0f - _S457 * _S457;
    var _S462 : f32 = (2.0f + _S460) * pow(max(_S461, 0.0f), 0.5f * _S460) * 0.5f * 0.31830987334251404f / max(4.0f * (_S458 + _S459 - _S458 * _S459), 0.0000152587890625f);
    var _S463 : bool = (material_7.velvet) > 0.0f;
    var f_1 : f32;
    if(_S463)
    {
        var _S464 : f32 = max(material_7.sheen_roughness, 0.00999999977648258f);
        var _S465 : f32 = _S464 * _S464;
        var _S466 : f32 = max(_S461, 0.0000152587890625f);
        var _S467 : f32 = exp(- _S457 * _S457 / (_S466 * _S465)) / (3.14159274101257324f * _S465 * _S466 * _S466) * min(1.0f, 2.0f * _S457 * min(_S458, _S459) / max(abs(dot(_S456, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S458 * _S459, 0.0000152587890625f);
        f_1 = _S467;
    }
    else
    {
        f_1 = _S462;
    }
    return lobes_6.sheen * vec3<f32>((f_1 * _S458 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S468 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S469 : f32 = lobes_7.p_reflect * _S468 / (4.0f * lobes_7.v_dot_h);
    var _S470 : bool = _S468 > 0.0f;
    var _S471 : f32 = select(0.0f, _S469, _S470);
    return _S471;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_8 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S472 : f32 = dot(n_i_7, l_3);
    var _S473 : f32 = smithG1(alpha_12, max(_S472, 0.0f));
    var _S474 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S474)
    {
        var _S475 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S476 : f32 = anisotropicG1(_S475, lobes_8.alphas);
        G1_l_1 = _S476;
    }
    else
    {
        G1_l_1 = _S473;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_2 : bool,  random_state_2 : u32,  mask_0 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(5)>>,  pdfs_0 : ptr<function, array<f32, i32(5)>>) -> vec3<f32>
{
    var _S477 : vec3<f32> = ((-(in_dir_4)));
    var _S478 : f32 = dot(n_6, _S477);
    var _S479 : f32 = (sign((_S478)));
    var _S480 : vec3<f32> = n_6 * vec3<f32>(_S479);
    var _S481 : AnisotropicFrame = anisotropicFrame(material_9, _S480);
    var _S482 : f32 = dot(_S480, out_dir_2);
    var _S483 : f32 = material_9.roughness;
    var _S484 : f32 = _S483 * _S483;
    var _S485 : f32 = sheenAlbedo(_S477, _S480, material_9);
    var _S486 : f32 = rgb_to_greyscale(material_9.translucent);
    var _S487 : bool = _S486 > 0.0f;
    var _S488 : bool = (dot(n_6, out_dir_2) * _S478) < 0.0f;
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
        var _S489 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S489;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S490 : vec3<f32> = vec3<f32>(0.0f);
    var _S491 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S490, _S490, 0.0f, 0.0f, _S490, _S490, 0.0f, 0.0f, 0.0f, 0.0f, _S490, 0.0f, _S490, _S490, vec2<f32>(0.0f), 0.0f);
    var sampled_terms_0 : BSDFLobes = _S491;
    var _S492 : bool = ((mask_0 & (u32(49)))) != u32(0);
    var _S493 : bool;
    if(_S492)
    {
        if(_S487)
        {
            _S493 = _S488;
        }
        else
        {
            _S493 = false;
        }
        var _S494 : bool = _S493 == refracted_2;
        _S493 = _S494;
    }
    else
    {
        _S493 = false;
    }
    if(_S493)
    {
        var sampled_n_0 : vec3<f32> = sampledHalf(in_dir_4, n_6, material_9, random_state_2, _S481);
        var _S495 : vec3<f32> = ((-(in_dir_4)));
        var _S496 : BSDFLobes = bsdfLobes(in_dir_4, _S495, _S480, sampled_n_0, material_9, eta_i_7, eta_o_7, _S481, _S485);
        sampled_terms_0 = _S496;
        var _S497 : f32 = translucentShare(material_9);
        sampled_terms_0.translucent_share = _S497;
    }
    var f_2 : vec3<f32>;
    if(refracted_2)
    {
        var _S498 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_6, eta_i_7, eta_o_7);
        f_2 = _S498;
    }
    else
    {
        var _S499 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
        f_2 = _S499;
    }
    var lobe_terms_0 : BSDFLobes = _S491;
    var _S500 : bool = ((mask_0 & (u32(14)))) != u32(0);
    if(_S500)
    {
        var _S501 : vec3<f32> = ((-(in_dir_4)));
        var _S502 : BSDFLobes = bsdfLobes(in_dir_4, _S501, _S480, f_2, material_9, eta_i_7, eta_o_7, _S481, _S485);
        lobe_terms_0 = _S502;
        var _S503 : f32 = translucentShare(material_9);
        lobe_terms_0.translucent_share = _S503;
    }
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
        var _S504 : u32;
        if(i_0 == u32(3))
        {
            _S504 = u32(4);
        }
        else
        {
            if(i_0 == u32(4))
            {
                _S504 = u32(6);
            }
            else
            {
                _S504 = i_0;
            }
        }
        var _S505 : bool = ((mask_0 & (((u32(1) << (i_0)))))) == u32(0);
        if(_S505)
        {
            _S493 = true;
        }
        else
        {
            var _S506 : bool = _S504 == u32(0);
            if(_S506)
            {
                _S493 = _S487;
            }
            else
            {
                _S493 = false;
            }
            var _S507 : bool;
            if(_S493)
            {
                _S507 = _S488;
            }
            else
            {
                _S507 = _S504 == u32(1);
            }
            _S493 = _S507 != refracted_2;
        }
        if(_S493)
        {
            var i_2 : u32 = i_0 + u32(1);
            i_0 = i_2;
            continue;
        }
        switch(_S504)
        {
        case u32(0):
            {
                var _S508 : f32 = diffusePDF(_S482, 0.0f, abs(_S478), _S484, sampled_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(0)] = _S508;
                var _S509 : vec3<f32> = diffuseBSDF(out_dir_2, _S480, _S484, material_9, sampled_terms_0);
                (*throughputs_0)[i32(0)] = _S509;
            }
        case u32(1):
            {
                var _S510 : f32 = refractPDF(_S482, dot(out_dir_2, f_2), abs(_S478), _S484, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(1)] = _S510;
                var _S511 : vec3<f32> = refractBSDF(out_dir_2, _S480, _S484, material_9, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S511;
            }
        case u32(4):
            {
                var _S512 : f32 = sheenVelvetPDF(_S482, 0.0f, abs(_S478), _S484, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(3)] = _S512;
                var _S513 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S480, _S484, material_9, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S513;
            }
        default :
            {
                var _S514 : f32 = reflectPDF(_S482, 0.0f, abs(_S478), _S484, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(2)] = _S514;
                var _S515 : vec3<f32> = reflectBSDF(out_dir_2, _S480, _S484, material_9, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S515;
            }
        }
        var i_2 : u32 = i_0 + u32(1);
        i_0 = i_2;
    }
    i_0 = u32(0);
    f_2 = _S490;
    loop
    {
        if(i_0 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S516 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S516)
        {
            var f_3 : vec3<f32> = f_2 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            f_2 = f_3;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return f_2;
}

fn skyBSDF( in_dir_5 : vec3<f32>,  dir_4 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_0 : f32,  random_state_3 : u32) -> vec3<f32>
{
    var _S517 : f32 = eta_0.x;
    var _S518 : f32 = eta_0.y;
    var _S519 : bool = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    var throughputs_1 : array<vec3<f32>, i32(5)>;
    var pdfs_1 : array<f32, i32(5)>;
    var _S520 : vec3<f32> = BSDF(in_dir_5, dir_4, surface_1.smooth_n, surface_1.material, _S517, _S518, _S519, random_state_3, u32(4294967295), &(throughputs_1), &(pdfs_1));
    var _S521 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var f_4 : vec3<f32> = _S521;
    loop
    {
        if(i_4 < u32(5))
        {
        }
        else
        {
            break;
        }
        var _S522 : bool = (pdfs_1[i_4]) > 0.0f;
        if(_S522)
        {
            var f_5 : vec3<f32> = f_4 + throughputs_1[i_4] * vec3<f32>(pdfs_1[i_4]) / vec3<f32>((pdfs_1[i_4] + pdf_0));
            f_4 = f_5;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return f_4;
}

fn SkySample_x24init_0( dir_5 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_4 : u32) -> SkySample
{
    var _S523 : SkySample;
    _S523.dir = dir_5;
    _S523.radiance = radiance_1;
    _S523.color = color_0;
    _S523.random_state = random_state_4;
    return _S523;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S524 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S525 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S526 : vec2<u32> = _S524 - _S525;
    var _S527 : Random = pcg(init_random_state_0);
    var _S528 : Random = pcg(_S527.state);
    var _S529 : Random = pcg(_S528.state);
    var _S530 : Random = pcg(_S529.state);
    var _S531 : u32 = _S526.x;
    var _S532 : u32 = searchCDF_0(vec2<u32>(_S531, u32(0)), vec2<u32>(u32(0), u32(1)), _S526.y, _S527.value);
    var _S533 : u32 = searchCDF_0(vec2<u32>(u32(0), _S532), _S525, _S531, _S528.value);
    var _S534 : vec2<f32> = (vec2<f32>(f32(_S533), f32(_S532)) + vec2<f32>(_S529.value, _S530.value)) / vec2<f32>(_S526) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S535 : f32 = _S534.y;
    var _S536 : f32 = sin(_S535);
    var _S537 : f32 = _S534.x;
    var _S538 : vec3<f32> = vec3<f32>(_S536 * cos(_S537), cos(_S535), _S536 * sin(_S537));
    var _S539 : f32 = environmentPdf_0(_S538);
    var _S540 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S538, surface_2, eta_1, is_inside_3, _S539, lobe_state_0);
    var _S541 : bool = !(_S539 > 0.0f);
    var _S542 : bool;
    if(_S541)
    {
        _S542 = true;
    }
    else
    {
        _S542 = (all((_S540 == vec3<f32>(0.0f))));
    }
    if(_S542)
    {
        var _S543 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S538, _S543, _S543, _S530.state);
    }
    var _S544 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S538);
    return SkySample_x24init_0(_S538, _S544, _S540 * _S544, _S530.state);
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_6 : vec3<f32>,  radiance_2 : vec3<f32>,  density_0 : f32,  random_state_5 : u32) -> TreeSample
{
    var _S545 : TreeSample;
    _S545.dir = dir_6;
    _S545.radiance = radiance_2;
    _S545.density = density_0;
    _S545.random_state = random_state_5;
    return _S545;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S546 : f32 = importance(first_1, p_10, normal_3);
    var _S547 : f32 = importance(second_1, p_10, normal_3);
    var _S548 : vec2<f32> = vec2<f32>(_S546, _S547);
    var _S549 : bool = _S546 == 0.0f;
    var _S550 : bool;
    if(_S549)
    {
        _S550 = _S547 == 0.0f;
    }
    else
    {
        _S550 = false;
    }
    if(_S550)
    {
        return u32(2);
    }
    var _S551 : f32 = _S546 + _S547;
    var _S552 : bool = _S547 > 0.0f;
    if(_S552)
    {
        _S550 = ((*pick_0) * _S551) >= _S546;
    }
    else
    {
        _S550 = false;
    }
    var _S553 : u32 = select(u32(0), u32(1), _S550);
    var _S554 : f32 = min(((*pick_0) * _S551 - f32(_S553) * _S546) / _S548[_S553], 0.99999994039535522f);
    (*pick_0) = _S554;
    var _S555 : f32 = (*probability_3) * (_S548[_S553] / _S551);
    (*probability_3) = _S555;
    return _S553;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S556 : vec3<f32> = center_1 - p_11;
    var _S557 : f32 = radius_1 * radius_1 / dot(_S556, _S556);
    var _S558 : f32 = u1_0 * _S557 / (1.0f + sqrt(max(1.0f - _S557, 0.0f)));
    var _S559 : f32 = 2.0f * u1_0;
    var _S560 : bool = _S557 >= 1.0f;
    var _S561 : f32 = select(_S558, _S559, _S560);
    var _S562 : f32 = sqrt(max(_S561 * (2.0f - _S561), 0.0f));
    var _S563 : f32 = 6.28318548202514648f * u2_0;
    var _S564 : vec3<f32> = vec3<f32>(_S562 * cos(_S563), 1.0f - _S561, _S562 * sin(_S563));
    var _S565 : vec3<f32> = (normalize((_S556)));
    var _S566 : vec3<f32> = tangentToWorld(_S564, _S565);
    return _S566;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S567 : vec3<f32> = center_2 - ray_1.origin;
    var _S568 : f32 = dot(_S567, ray_1.unit_direction);
    var _S569 : f32 = dot(_S567, _S567) - _S568 * _S568;
    var _S570 : f32 = radius_3 * radius_3;
    var _S571 : bool = _S569 > _S570;
    if(_S571)
    {
        return 4.294967296e+09f;
    }
    var _S572 : f32 = sqrt(_S570 - _S569);
    var _S573 : f32 = _S568 - _S572;
    var _S574 : f32 = _S568 + _S572;
    var _S575 : bool = _S573 > 0.0000152587890625f;
    var _S576 : bool;
    if(_S575)
    {
        _S576 = _S573 < max_len_0;
    }
    else
    {
        _S576 = false;
    }
    if(_S576)
    {
        return _S573;
    }
    var _S577 : bool = _S574 > 0.0000152587890625f;
    if(_S577)
    {
        _S576 = _S574 < max_len_0;
    }
    else
    {
        _S576 = false;
    }
    if(_S576)
    {
        return _S574;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S578 : Random = pcg(init_random_state_1);
    var _S579 : Random = pcg(_S578.state);
    var _S580 : Random = pcg(_S579.state);
    var _S581 : vec3<f32> = vec3<f32>(0.0f);
    var _S582 : TreeSample = TreeSample_x24init_0(_S581, _S581, 0.0f, _S580.state);
    var sample_0 : TreeSample = _S582;
    var _S583 : vec3<f32> = select(smooth_n_2, _S581, sided_0);
    var _S584 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S585 : vec3<f32> = origin_4 + _S584 * smooth_n_2;
    var pick_1 : f32 = _S578.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S586 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S586.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S587 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S588 : u32 = n_7 + u32(1);
        var _S589 : LightBounds = (lightBounds((_S588)));
        var _S590 : LightBounds = (lightBounds((_S587)));
        var _S591 : u32 = pickChild(_S589, _S590, origin_4, _S583, &(pick_1), &(probability_4));
        var _S592 : bool = _S591 > u32(1);
        if(_S592)
        {
            return sample_0;
        }
        var _S593 : bool = _S591 == u32(1);
        var _S594 : u32 = select(_S588, _S587, _S593);
        n_7 = _S594;
    }
    var _S595 : bool = n_7 == u32(0);
    var _S596 : bool;
    if(_S595)
    {
        var _S597 : LightBounds = (lightBounds((u32(0))));
        var _S598 : f32 = importance(_S597, origin_4, _S583);
        _S596 = !(_S598 > 0.0f);
    }
    else
    {
        _S596 = false;
    }
    if(_S596)
    {
        return sample_0;
    }
    var _S599 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S600 : bool = (_S599.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S600)
    {
        var _S601 : Light = (lights[(_S599.y)]);
        if(sided_0)
        {
            var _S602 : f32 = (sign((dot(geometry_n_1, _S601.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S602);
            var _S603 : vec3<f32> = origin_4 + _S584 * lift_n_1;
            start_5 = _S603;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S585;
            lift_n_0 = smooth_n_2;
        }
        var _S604 : bool = (_S601.variance) == 0.0f;
        if(_S604)
        {
            var _S605 : vec3<f32> = _S601.position - start_5;
            var _S606 : vec3<f32> = (normalize((_S605)));
            sample_0.dir = _S606;
            var _S607 : vec3<f32> = _S601.color * vec3<f32>(_S601.intensity) / vec3<f32>((dot(_S605, _S605) * probability_4));
            sample_0.radiance = _S607;
            shadow_1 = _S605;
        }
        else
        {
            var _S608 : vec3<f32> = sampleSphere(_S601.position, _S601.variance, start_5, _S579.value, _S580.value);
            sample_0.dir = _S608;
            var _S609 : f32 = sphereDensity(_S601.position, _S601.variance, start_5);
            var _S610 : f32 = probability_4 * _S609;
            sample_0.density = _S610;
            var _S611 : vec3<f32> = pointLightRadiance(_S601.color, _S601.intensity, _S601.variance);
            var _S612 : vec3<f32> = _S611 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S612;
            var _S613 : f32 = raySphere_0(_S601.position, _S601.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S614 : vec3<f32> = sample_0.dir * vec3<f32>(_S613);
            shadow_1 = _S614;
        }
    }
    else
    {
        var _S615 : u32 = _S599.y;
        var _S616 : u32 = ((instance_uint[(_S615) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S617 : u32 = _S616 + _S599.z;
        var _S618 : mat3x3<f32> = (worldTriangle((_S615), (_S617)));
        var _S619 : f32 = sqrt(_S579.value);
        var _S620 : vec2<f32> = vec2<f32>(_S619 * (1.0f - _S580.value), _S619 * _S580.value);
        var _S621 : vec3<f32> = (((_S618) * (vec3<f32>(1.0f - _S619, _S620))));
        if(sided_0)
        {
            var _S622 : f32 = (sign((dot(geometry_n_1, _S621 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S622);
            var _S623 : vec3<f32> = origin_4 + _S584 * lift_n_2;
            start_5 = _S623;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S624 : bool = !((dot(smooth_n_2, _S621 - origin_4)) > 0.0f);
            if(_S624)
            {
                return sample_0;
            }
            start_5 = _S585;
            lift_n_0 = smooth_n_2;
        }
        var _S625 : Surface = (surfaceAt((Hit_x24init_0(_S620, _S615, _S617, u32(0), 0.0f)), (_S621), (_S580.state)));
        sample_0.random_state = _S625.random_state;
        var _S626 : vec3<f32> = _S621 - start_5;
        var _S627 : vec3<f32> = (normalize((_S626)));
        sample_0.dir = _S627;
        var _S628 : f32 = solidAngle(probability_4, cross(_S618[i32(1)] - _S618[i32(0)], _S618[i32(2)] - _S618[i32(0)]), _S626);
        sample_0.density = _S628;
        var _S629 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S625.smooth_n))));
        var _S630 : vec3<f32> = _S625.material.emissive * vec3<f32>(max(_S629, 0.0f));
        var _S631 : vec3<f32> = select(_S630, _S581, _S625.skip);
        var _S632 : vec3<f32> = _S631 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S632;
        shadow_1 = _S626;
    }
    var _S633 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S634 : vec3<f32> = sample_0.radiance * _S633;
    var _S635 : bool = (all((_S633 == _S581)));
    var _S636 : vec3<f32> = select(_S634, _S581, _S635);
    sample_0.radiance = _S636;
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

fn powerHeuristic( a_5 : f32,  b_1 : f32) -> f32
{
    var _S637 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S638 : bool = b_1 > 0.0f;
    var _S639 : f32 = select(1.0f, _S637, _S638);
    return _S639;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S640 : u32 = (lightSlot((hit_1)));
    var _S641 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S640, light_point_1);
    var _S642 : f32 = powerHeuristic(vertex_0.pdf, _S641);
    return _S642;
}

fn environment_0( dir_7 : vec3<f32>) -> vec3<f32>
{
    var _S643 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S644 : bool = (_S643.x) > u32(1);
    var _S645 : bool;
    if(_S644)
    {
        var _S646 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S645 = (_S646.y) > u32(1);
    }
    else
    {
        _S645 = false;
    }
    if(_S645)
    {
        var _S647 : vec3<f32> = (env_map_sample((dir_7)));
        return _S647;
    }
    var _S648 : vec3<f32> = (uniforms_float.ambient);
    return _S648;
}

fn environmentMapped_0() -> bool
{
    var _S649 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S650 : bool = (_S649.x) > u32(1);
    var _S651 : bool;
    if(_S650)
    {
        var _S652 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S651 = (_S652.y) > u32(1);
    }
    else
    {
        _S651 = false;
    }
    return _S651;
}

fn escapeWeight_0( pdf_1 : f32,  dir_8 : vec3<f32>) -> f32
{
    var _S653 : bool = pdf_1 <= 0.0f;
    var _S654 : bool;
    if(_S653)
    {
        _S654 = true;
    }
    else
    {
        var _S655 : bool = environmentMapped_0();
        _S654 = !_S655;
    }
    if(_S654)
    {
        return 1.0f;
    }
    var _S656 : f32 = environmentPdf_0(dir_8);
    return pdf_1 / (pdf_1 + _S656);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S657 : vec2<u32> = global_invocation_id_1.xy;
    var _S658 : vec2<i32> = vec2<i32>(_S657 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S659 : vec2<i32> = _S658 + vec2<i32>(i32(i_6 % u32(24)), i32(i_6 / u32(24)));
        var _S660 : bool = (all((_S659 >= vec2<i32>(i32(0)))));
        var _S661 : bool;
        if(_S660)
        {
            var _S662 : vec2<u32> = (uniforms_uint.render_size);
            _S661 = (all((_S659 < vec2<i32>(_S662))));
        }
        else
        {
            _S661 = false;
        }
        if(_S661)
        {
            var _S663 : vec4<u32> = (textureLoad(reservoir_prev, (_S659), (u32(0)), 0));
            var _S664 : u32 = _S663.x;
            var _S665 : bool = (bitcast<f32>((_S663.z))) > 0.0f;
            var _S666 : u32 = select(u32(0), _S664, _S665);
            seed_1 = _S666;
        }
        else
        {
            seed_1 = u32(0);
        }
        duplication_seeds_0[i_6] = seed_1;
        var i_7 : u32 = i_6 + u32(64);
        i_6 = i_7;
    }
    workgroupBarrier();
    var _S667 : u32 = local_invocation_id_0.y;
    var _S668 : u32 = local_invocation_id_0.x;
    var _S669 : u32 = duplication_seeds_0[(_S667 + u32(8)) * u32(24) + _S668 + u32(8)];
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
            var _S670 : bool = (duplication_seeds_0[(_S667 + seed_1) * u32(24) + _S668 + x_1]) == _S669;
            var _S671 : u32 = select(u32(0), u32(1), _S670);
            var count_2 : u32 = count_1 + _S671;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S672 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S673 : bool = _S669 != u32(0);
    var _S674 : f32 = select(0.0f, _S672, _S673);
    textureStore(duplication_out, (vec2<i32>(_S657)), 0, (vec4<u32>((bitcast<u32>((_S674))), u32(0), u32(0), u32(0))));
    return;
}

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Selection_x24init_0( r_2 : Reservoir,  w_sum_0 : f32,  color_2 : vec3<f32>,  random_state_6 : u32) -> Selection
{
    var _S675 : Selection;
    _S675.r = r_2;
    _S675.w_sum = w_sum_0;
    _S675.color = color_2;
    _S675.random_state = random_state_6;
    return _S675;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S676 : u32 = hash(index_0);
    var _S677 : u32 = hash((seed_2 ^ (_S676)));
    return _S677;
}

struct Shift
{
     f : vec3<f32>,
     jac : f32,
};

fn Shift_x24init_0( f_6 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S678 : Shift;
    _S678.f = f_6;
    _S678.jac = jac_1;
    return _S678;
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S679 : f32 = rgb_to_greyscale(weight_0);
    var _S680 : bool = _S679 > 0.0f;
    var _S681 : bool;
    if(_S680)
    {
        _S681 = _S679 < 3.00000000549775576e+38f;
    }
    else
    {
        _S681 = false;
    }
    var _S682 : bool = !_S681;
    if(_S682)
    {
        return;
    }
    var _S683 : f32 = (*sel_0).w_sum + _S679;
    (*sel_0).w_sum = _S683;
    var _S684 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S684;
    var _S685 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S685.state;
    var _S686 : bool = (_S685.value * (*sel_0).w_sum) <= _S679;
    if(_S686)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_3 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_3;
    var _S687 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S687;
    var _S688 : f32 = r_3.jac * shifted_0.jac;
    candidate_1.jac = _S688;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_3.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_4 : Reservoir = sel_2.r;
    var _S689 : f32 = rgb_to_greyscale(r_4.f);
    var _S690 : f32 = sel_2.w_sum / _S689;
    var _S691 : bool = _S689 > 0.0f;
    var _S692 : f32 = select(0.0f, _S690, _S691);
    r_4.w = _S692;
    r_4.c = c_2;
    return r_4;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S693 : vec2<u32> = global_invocation_id_2.xy;
    var _S694 : vec2<i32> = vec2<i32>(_S693);
    var _S695 : vec3<f32> = vec3<f32>(0.0f);
    var _S696 : Domain = Domain_x24init_0(_S695, _S695, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S696;
    var _S697 : bool = (currentDomain((_S694), &(dom_3)));
    var _S698 : bool = !_S697;
    if(_S698)
    {
        storeReservoir(reservoir_prev_out, (_S694), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S695, 0.0f, vec4<u32>(u32(0)), _S695, _S695)), (dom_3.hit));
        var _S699 : vec2<f32> = vec2<f32>(_S693);
        var _S700 : vec2<u32> = (uniforms_uint.render_size);
        var _S701 : vec2<f32> = _S699 / vec2<f32>(_S700.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S702 : vec3<f32> = vec3<f32>(_S701, 1.0f);
        var _S703 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S704 : vec3<f32> = (normalize(((((_S703) * (_S702))))));
        var _S705 : vec3<f32> = environment_0(_S704);
        textureStore(compute_out, (_S694), (u32(0)), (vec4<f32>(_S705, 1.0f)));
        var _S706 : u32 = (uniforms_uint.is_temporal);
        var _S707 : bool = _S706 == u32(1);
        if(_S707)
        {
            textureStore(compute_out, (_S694), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S708 : Reservoir = (loadReservoir(reservoir_temp, (_S694)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_0 : f32 = _S708.c;
    loop
    {
        var _S709 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S709)
        {
        }
        else
        {
            break;
        }
        var _S710 : vec2<i32> = partner_0(_S694, t_13);
        var neighbor_0 : Domain = _S696;
        var _S711 : bool = (currentDomain((_S710), &(neighbor_0)));
        if(_S711)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S712 : vec4<u32> = (textureLoad(reservoir_temp, (_S710), (u32(0)), 0));
            var c_sum_1 : f32 = c_sum_0 + (bitcast<f32>((_S712.w)));
            count_3 = count_4;
            c_sum_0 = c_sum_1;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S713 : f32 = _S708.c / max(count_3, 1.0f);
    var _S714 : f32 = rgb_to_greyscale(_S708.f);
    var _S715 : bool = count_3 == 0.0f;
    var _S716 : f32 = select(0.0f, 1.0f, _S715);
    var _S717 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S695, 0.0f, vec4<u32>(u32(0)), _S695, _S695), 0.0f, _S695, u32(0));
    var sel_3 : Selection = _S717;
    var _S718 : u32 = (uniforms_uint.frame);
    var _S719 : u32 = hash(_S718);
    var _S720 : u32 = global_invocation_id_2.x;
    var _S721 : vec2<u32> = (uniforms_uint.render_size);
    var _S722 : u32 = stream(_S719, _S720 + _S721.x * global_invocation_id_2.y);
    var _S723 : u32 = stream(_S722, u32(195));
    sel_3.random_state = _S723;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S716;
    loop
    {
        var _S724 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S724)
        {
        }
        else
        {
            break;
        }
        var _S725 : vec2<i32> = partner_0(_S694, t_13);
        var neighbor_dom_0 : Domain = _S696;
        var _S726 : bool = (currentDomain((_S725), &(neighbor_dom_0)));
        if(_S726)
        {
            var _S727 : Reservoir = (loadReservoir(reservoir_temp, (_S725)));
            var _S728 : vec4<u32> = (textureLoad(shift_data, (_S725), (t_13), 0));
            var _S729 : vec4<f32> = (bitcast<vec4<f32>>((_S728)));
            var _S730 : vec4<u32> = (textureLoad(shift_data, (_S694), (t_13), 0));
            var _S731 : vec4<f32> = (bitcast<vec4<f32>>((_S730)));
            var _S732 : f32 = (_S727.c + _S713) / c_sum_0;
            var _S733 : bool = _S714 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S733)
            {
                var _S734 : f32 = _S732 * _S713 * _S714;
                var _S735 : f32 = _S713 * _S714;
                var _S736 : f32 = rgb_to_greyscale(_S731.xyz);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S734 / (_S735 + _S727.c * _S736);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S737 : vec3<f32> = _S729.xyz;
            var _S738 : Shift = Shift_x24init_0(_S737, _S729.w);
            var _S739 : f32 = _S732 * _S727.c;
            var _S740 : f32 = rgb_to_greyscale(_S727.f);
            var _S741 : f32 = _S739 * _S740;
            var _S742 : f32 = rgb_to_greyscale(_S727.f);
            var _S743 : f32 = _S727.c * _S742;
            var _S744 : f32 = rgb_to_greyscale(_S737);
            offerShifted(&(sel_3), _S727, _S738, _S741 / (_S743 + _S713 * _S744));
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S708, Shift_x24init_0(_S708.f, 1.0f), canonical_mis_0);
    var _S745 : Reservoir = finalize(sel_3, c_sum_0);
    storeReservoir(reservoir_prev_out, (_S694), (_S745), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S694), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S746 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S747 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S748 : f32 = (sign((dot(_S747, _S746.smooth_n))));
    var _S749 : vec3<f32> = _S746.material.emissive * vec3<f32>(max(_S748, 0.0f));
    var _S750 : vec3<f32> = select(_S749, _S695, _S746.skip);
    var _S751 : vec3<f32> = clamp(sel_3.color + _S750, _S695, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S694), (u32(0)), (vec4<f32>(_S751, 1.0f)));
    var _S752 : u32 = (uniforms_uint.is_temporal);
    var _S753 : bool = _S752 == u32(1);
    if(_S753)
    {
        textureStore(compute_out, (_S694), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_2 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S754 : NEEVertex;
    _S754.none = none_0;
    _S754.pdf = pdf_2;
    _S754.origin = origin_5;
    _S754.smooth_n = smooth_n_3;
    _S754.start = start_6;
    return _S754;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_0 : u32,  pdf_3 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S755 : Vertex;
    _S755.rough = rough_0;
    _S755.lobe = lobe_0;
    _S755.pdf = pdf_3;
    _S755.cos = cos_0;
    _S755.inside = inside_0;
    return _S755;
}

fn Material_x24init_0( albedo_1 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>,  velvet_0 : f32) -> Material
{
    var _S756 : Material;
    _S756.albedo = albedo_1;
    _S756.emissive = emissive_0;
    _S756.roughness = roughness_0;
    _S756.metallic = metallic_0;
    _S756.transmission = transmission_0;
    _S756.ior = ior_0;
    _S756.absorption = absorption_0;
    _S756.specular_tint = specular_tint_0;
    _S756.specular_level = specular_level_0;
    _S756.translucent = translucent_0;
    _S756.sheen = sheen_2;
    _S756.sheen_roughness = sheen_roughness_0;
    _S756.anisotropy = anisotropy_0;
    _S756.anisotropic_rotation = anisotropic_rotation_0;
    _S756.tangent = tangent_2;
    _S756.velvet = velvet_0;
    return _S756;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_10 : Material,  skip_0 : bool,  random_state_7 : u32) -> Surface
{
    var _S757 : Surface;
    _S757.smooth_n = smooth_n_4;
    _S757.geometry_n = geometry_n_2;
    _S757.geometry_offset = geometry_offset_2;
    _S757.material = material_10;
    _S757.skip = skip_0;
    _S757.random_state = random_state_7;
    return _S757;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S758 : bool = transmission_1 > 0.0f;
    var _S759 : bool;
    if(_S758)
    {
        _S759 = true;
    }
    else
    {
        _S759 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S760 : f32;
    if(_S759)
    {
        _S760 = 1.0f;
    }
    else
    {
        _S760 = -1.0f;
    }
    return _S760;
}

fn facingRay_0( surface_3 : Surface,  dir_9 : vec3<f32>) -> Surface
{
    var _S761 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_9);
    var _S762 : vec3<f32> = vec3<f32>(_S761);
    return Surface_x24init_0(surface_3.smooth_n * _S762, surface_3.geometry_n * _S762, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S763 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S763));
}

fn vertexEta( material_11 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S764 : bool = n_dot_v_0 < 0.0f;
    var _S765 : f32 = select(1.0f, material_11.ior, _S764);
    var _S766 : f32 = select(material_11.ior, 1.0f, _S764);
    return vec2<f32>(_S765, _S766);
}

fn neeDecision( material_12 : Material,  n_dot_v_1 : f32,  eta_i_8 : f32,  eta_o_8 : f32) -> bool
{
    var _S767 : f32 = fresnel(abs(n_dot_v_1), eta_i_8, eta_o_8);
    var _S768 : vec3<f32> = (mix((vec3<f32>(_S767)), (material_12.albedo), (material_12.metallic)));
    var _S769 : f32 = rgb_to_greyscale(_S768);
    var _S770 : f32 = max((1.0f - _S769) * (1.0f - material_12.metallic) * (1.0f - material_12.transmission), 0.0f);
    var _S771 : bool = _S770 > 0.03999999910593033f;
    var _S772 : bool;
    if(_S771)
    {
        _S772 = true;
    }
    else
    {
        _S772 = (material_12.roughness) > 0.20000000298023224f;
    }
    return _S772;
}

fn isTranslucent_0( material_13 : Material) -> bool
{
    var _S773 : f32 = rgb_to_greyscale(material_13.translucent);
    var _S774 : bool = _S773 > 0.0f;
    return _S774;
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S775 : vec3<f32> = a_6 / b_2;
    var _S776 : vec3<f32> = vec3<f32>(0.0f);
    var _S777 : vec3<bool> = b_2 == _S776;
    var _S778 : vec3<f32> = select(_S775, _S776, _S777);
    return _S778;
}

fn withEnd( r_5 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_7 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_5;
    var _S779 : u32 = (insertBits((r_5.path), (end_0), (u32(0)), (u32(5))));
    var _S780 : u32 = (insertBits((_S779), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S780;
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_8 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_4 : f32) -> SampleBSDF
{
    var _S781 : SampleBSDF;
    _S781.unit_direction = unit_direction_1;
    _S781.throughput = throughput_0;
    _S781.random_state = random_state_8;
    _S781.refracted = refracted_3;
    _S781.lobe = lobe_1;
    _S781.pdf = pdf_4;
    return _S781;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_14 : Material,  lobes_9 : BSDFLobes,  eta_i_9 : f32,  eta_o_9 : f32,  random_state_9 : u32) -> SampleBSDF
{
    var _S782 : vec3<f32> = vec3<f32>(1.0f);
    var _S783 : SampleBSDF = SampleBSDF_x24init_0(_S782, _S782, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S783;
    var _S784 : Random = pcg(random_state_9);
    var _S785 : Random = pcg(_S784.state);
    sample_1.random_state = _S785.state;
    var _S786 : f32 = _S784.value;
    var _S787 : f32 = sqrt(max(0.0f, 1.0f - _S786 * _S786));
    var _S788 : f32 = 6.28318548202514648f * _S785.value;
    var _S789 : vec3<f32> = tangentToWorld(vec3<f32>(_S787 * cos(_S788), _S784.value, _S787 * sin(_S788)), n_i_8);
    sample_1.unit_direction = _S789;
    sample_1.lobe = u32(4);
    var _S790 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_14, lobes_9);
    sample_1.throughput = _S790;
    var _S791 : f32 = sheenVelvetPDF(_S784.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_9, eta_o_9);
    sample_1.pdf = _S791;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S792 : f32 = sqrt(random_1_0);
    var _S793 : f32 = 6.28318548202514648f * random_2_0;
    var _S794 : f32 = _S792 * cos(_S793);
    var _S795 : f32 = _S792 * sin(_S793);
    var _S796 : f32 = sqrt(max(0.0f, 1.0f - _S794 * _S794 - _S795 * _S795));
    return vec3<f32>(_S794, _S796, _S795);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_15 : Material,  lobes_10 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_10 : u32) -> SampleBSDF
{
    var _S797 : vec3<f32> = vec3<f32>(1.0f);
    var _S798 : SampleBSDF = SampleBSDF_x24init_0(_S797, _S797, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S798;
    var _S799 : Random = pcg(random_state_10);
    var _S800 : Random = pcg(_S799.state);
    sample_2.random_state = _S800.state;
    var _S801 : vec3<f32> = sampleCosWeightedHemisphere(_S799.value, _S800.value);
    var _S802 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S803 : f32 = _S801.y;
    var _S804 : f32 = - _S803;
    var _S805 : f32 = select(_S803, _S804, _S802);
    var _S806 : vec3<f32> = tangentToWorld(vec3<f32>(_S801.x, _S805, _S801.z), n_i_9);
    sample_2.unit_direction = _S806;
    sample_2.refracted = _S802;
    sample_2.lobe = u32(0);
    var _S807 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_15, lobes_10);
    sample_2.throughput = _S807;
    var _S808 : f32 = diffusePDF(_S805, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_10, eta_o_10);
    sample_2.pdf = _S808;
    return sample_2;
}

fn refractSample( ggx_n_1 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_16 : Material,  lobes_11 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S809 : vec3<f32> = vec3<f32>(1.0f);
    var _S810 : SampleBSDF = SampleBSDF_x24init_0(_S809, _S809, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S810;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_11;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S811 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_16, lobes_11);
    sample_3.throughput = _S811;
    var _S812 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_1), n_i_dot_v_7, alpha_15, lobes_11, eta_i_11, eta_o_11);
    sample_3.pdf = _S812;
    return sample_3;
}

fn reflectSample( in_dir_6 : vec3<f32>,  ggx_n_2 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_17 : Material,  lobes_12 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S813 : vec3<f32> = vec3<f32>(1.0f);
    var _S814 : SampleBSDF = SampleBSDF_x24init_0(_S813, _S813, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S814;
    var _S815 : vec3<f32> = (normalize((reflect(in_dir_6, ggx_n_2))));
    sample_4.unit_direction = _S815;
    sample_4.random_state = random_state_12;
    sample_4.lobe = u32(2);
    var _S816 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_17, lobes_12);
    sample_4.throughput = _S816;
    var _S817 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_12, eta_o_12);
    sample_4.pdf = _S817;
    return sample_4;
}

fn sampleBSDF( in_dir_7 : vec3<f32>,  n_8 : vec3<f32>,  material_18 : Material,  eta_i_13 : f32,  eta_o_13 : f32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_0;
    var _S818 : vec3<f32> = ((-(in_dir_7)));
    var _S819 : f32 = dot(n_8, _S818);
    var _S820 : f32 = (sign((_S819)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S820);
    var _S821 : f32 = abs(_S819);
    var _S822 : f32 = material_18.roughness;
    var _S823 : f32 = _S822 * _S822;
    var _S824 : AnisotropicFrame = anisotropicFrame(material_18, n_i_12);
    var _S825 : f32 = sheenAlbedo(_S818, n_i_12, material_18);
    var _S826 : vec3<f32> = sampleHalfVector(_S818, n_i_12, _S823, _S824, &(random_state_13));
    var _S827 : BSDFLobes = bsdfLobes(in_dir_7, _S818, n_i_12, _S826, material_18, eta_i_13, eta_o_13, _S824, _S825);
    var lobes_13 : BSDFLobes = _S827;
    var _S828 : f32 = translucentShare(material_18);
    lobes_13.translucent_share = _S828;
    var _S829 : Random = pcg(random_state_13);
    random_state_13 = _S829.state;
    var _S830 : bool = (_S829.value) < (lobes_13.p_sheen_velvet);
    if(_S830)
    {
        var _S831 : SampleBSDF = sheenVelvetSample(n_i_12, _S821, _S823, material_18, lobes_13, eta_i_13, eta_o_13, random_state_13);
        return _S831;
    }
    var _S832 : f32 = _S829.value - lobes_13.p_sheen_velvet;
    var _S833 : bool = _S832 < (lobes_13.p_diffuse);
    if(_S833)
    {
        var _S834 : SampleBSDF = diffuseSample(_S832, n_i_12, _S821, _S823, material_18, lobes_13, eta_i_13, eta_o_13, random_state_13);
        return _S834;
    }
    var _S835 : bool = _S832 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S835)
    {
        var _S836 : SampleBSDF = refractSample(_S826, n_i_12, _S821, _S823, material_18, lobes_13, eta_i_13, eta_o_13, random_state_13);
        return _S836;
    }
    var _S837 : SampleBSDF = reflectSample(in_dir_7, _S826, n_i_12, _S821, _S823, material_18, lobes_13, eta_i_13, eta_o_13, random_state_13);
    return _S837;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S838 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S838.x, max(_S838.y, _S838.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_6 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S839 : vec3<f32> = vec3<f32>(0.0f);
    var _S840 : Shift = Shift_x24init_0(_S839, 0.0f);
    var _S841 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S842 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S843 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S844 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S845 : bool = _S844 >= u32(3);
        var _S846 : u32 = select(u32(0), u32(1), _S845);
        var _S847 : u32 = _S841 + _S846;
        var _S848 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S847 > _S848;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S840;
    }
    var _S849 : u32 = _S842 - u32(1);
    var _S850 : bool = _S844 == u32(3);
    var _S851 : u32 = select(u32(0), u32(1), _S850);
    var _S852 : u32 = _S841 + _S851;
    var _S853 : bool = _S843 == u32(0);
    var _S854 : u32 = select(_S849, _S852, _S853);
    var _S855 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_6.rc.zw))), r_6.rc.x, r_6.rc.y, u32(0), 0.0f);
    var _S856 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S857 : Ray = Ray_x24init_0(dom_4.x1, _S856);
    var ray_2 : Ray = _S857;
    var hit_2 : Hit = dom_4.hit;
    var _S858 : vec3<f32> = vec3<f32>(1.0f);
    var _S859 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S839, _S839, _S839);
    var nee_vertex_0 : NEEVertex = _S859;
    var _S860 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S860;
    var _S861 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S839, 0.0f, vec4<u32>(u32(0)), _S839, _S839);
    var chain_0 : Reservoir = _S861;
    chain_0.seed = r_6.seed;
    is_inside_4 = false;
    var threshold_0 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S839;
    var reconnection_0 : vec3<f32> = _S839;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S858;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S862 : bool = (hit_2.is_point_light) == u32(1);
        var _S863 : bool;
        if(replay_0)
        {
            _S863 = _S843 == u32(1);
        }
        else
        {
            _S863 = false;
        }
        var _S864 : bool;
        if(_S863)
        {
            _S864 = b_3 == _S842;
        }
        else
        {
            _S864 = false;
        }
        var _S865 : bool;
        if(_S864)
        {
            var _S866 : bool = (hit_2.instance_index) != (_S855.instance_index);
            if(_S866)
            {
                _S865 = true;
            }
            else
            {
                _S865 = (hit_2.triangle_index) != (_S855.triangle_index);
            }
        }
        else
        {
            _S865 = false;
        }
        if(_S865)
        {
            return _S840;
        }
        var _S867 : Surface = Surface_x24init_0(_S839, _S839, 0.0f, Material_x24init_0(_S839, _S839, 0.0f, 0.0f, 0.0f, 0.0f, _S839, _S858, 1.0f, _S839, _S839, 0.5f, 0.0f, 0.0f, _S839, 0.0f), false, u32(0));
        var _S868 : bool = !_S862;
        var scatter_0 : bool;
        var geometry_density_0 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_4 : Surface;
        if(_S868)
        {
            var _S869 : u32 = stream(r_6.seed, b_3);
            var _S870 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S869)));
            var surface_5 : Surface = facingRay_0(_S870, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S871 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S872 : vec3<f32> = throughput_2 * _S871;
                front_n_0 = _S872;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S873 : bool = !surface_5.skip;
            var geometry_density_1 : f32 = abs(dot(surface_5.geometry_n, ray_2.unit_direction)) / (hit_2.distance * hit_2.distance);
            var _S874 : bool = b_3 == u32(0);
            if(_S874)
            {
                var _S875 : f32 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S875;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            var _S876 : vec3<f32> = front_n_0;
            var _S877 : f32 = geometry_density_0;
            scatter_0 = _S873;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S877;
            front_n_0 = _S870.smooth_n;
            surface_4 = surface_5;
            throughput_3 = _S876;
        }
        else
        {
            scatter_0 = false;
            geometry_density_0 = 0.0f;
            front_n_0 = _S839;
            surface_4 = _S867;
            throughput_3 = throughput_2;
        }
        var _S878 : bool;
        if(scatter_0)
        {
            _S878 = prev_0.rough;
        }
        else
        {
            _S878 = false;
        }
        var _S879 : bool;
        if(_S878)
        {
            _S879 = (prev_0.pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S879 = false;
        }
        var _S880 : Surface = surface_4;
        var _S881 : Surface = surface_4;
        var _S882 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S883 : vec2<f32> = vertexEta(_S880.material, _S882);
        var _S884 : bool;
        if(scatter_0)
        {
            var _S885 : bool = neeDecision(_S880.material, _S882, _S883.x, _S883.y);
            _S884 = _S885;
        }
        else
        {
            _S884 = false;
        }
        var _S886 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S887 : vec3<f32> = _S880.material.emissive * vec3<f32>(max(_S886, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S862)
        {
            var _S888 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S888;
        }
        else
        {
            emission_0 = _S887;
        }
        var _S889 : bool = !replay_0;
        var _S890 : bool;
        if(_S889)
        {
            _S890 = true;
        }
        else
        {
            _S890 = b_3 >= _S854;
        }
        var _S891 : bool;
        if(_S890)
        {
            var _S892 : f32 = rgb_to_greyscale(emission_0);
            _S891 = _S892 > 0.0f;
        }
        else
        {
            _S891 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S891)
        {
            var _S893 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S893);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S894 : bool;
        if(replay_0)
        {
            _S894 = _S843 == u32(1);
        }
        else
        {
            _S894 = false;
        }
        var _S895 : bool;
        if(_S894)
        {
            _S895 = b_3 > _S842;
        }
        else
        {
            _S895 = false;
        }
        var _S896 : bool;
        if(_S895)
        {
            _S896 = b_3 == _S841;
        }
        else
        {
            _S896 = false;
        }
        var _S897 : bool;
        if(_S896)
        {
            var _S898 : bool = _S844 == u32(1);
            if(_S898)
            {
                _S897 = true;
            }
            else
            {
                _S897 = _S844 == u32(2);
            }
        }
        else
        {
            _S897 = false;
        }
        if(_S897)
        {
            var _S899 : bool = _S862 != (_S844 == u32(2));
            if(_S899)
            {
                return _S840;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_6.jac), density_2 / r_6.jac);
        }
        var _S900 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S901 : bool = _S900 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S902 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S903 : u32 = (insertBits((_S902), (u32(1)), (u32(10)), (u32(2))));
        var _S904 : u32 = (insertBits((_S903), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S905 : bool = prev_0.inside;
        var _S906 : u32 = select(u32(0), u32(1), _S905);
        var _S907 : u32 = (insertBits((_S904), (_S906), (u32(22)), (u32(1))));
        here_0.path = _S907;
        var _S908 : f32 = prev_0.pdf * geometry_density_0;
        here_0.jac = _S908;
        var _S909 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S909;
        var _S910 : bool;
        if(replay_0)
        {
            _S910 = _S843 == u32(1);
        }
        else
        {
            _S910 = false;
        }
        var _S911 : bool;
        if(_S910)
        {
            _S911 = b_3 == _S842;
        }
        else
        {
            _S911 = false;
        }
        var _S912 : bool = b_3 == _S854;
        var _S913 : bool;
        if(_S912)
        {
            var _S914 : bool = !scatter_0;
            if(_S914)
            {
                _S913 = true;
            }
            else
            {
                var _S915 : bool = _S843 != u32(1);
                if(_S915)
                {
                    _S913 = _S843 != u32(3);
                }
                else
                {
                    _S913 = false;
                }
            }
        }
        else
        {
            _S913 = false;
        }
        var _S916 : bool;
        if(_S913)
        {
            _S916 = _S843 == u32(2);
        }
        else
        {
            _S916 = false;
        }
        var _S917 : bool;
        if(_S916)
        {
            _S917 = !_S879;
        }
        else
        {
            _S917 = false;
        }
        var _S918 : bool;
        if(_S917)
        {
            _S918 = _S844 != u32(4);
        }
        else
        {
            _S918 = false;
        }
        var _S919 : bool = _S842 == _S841;
        var _S920 : bool;
        if(_S919)
        {
            _S920 = _S844 == u32(0);
        }
        else
        {
            _S920 = false;
        }
        var _S921 : bool;
        if(_S920)
        {
            _S921 = (hit_2.instance_index) == (_S855.instance_index);
        }
        else
        {
            _S921 = false;
        }
        var _S922 : bool;
        if(_S921)
        {
            _S922 = (hit_2.triangle_index) == (_S855.triangle_index);
        }
        else
        {
            _S922 = false;
        }
        var _S923 : bool;
        if(_S922)
        {
            _S923 = _S879;
        }
        else
        {
            _S923 = false;
        }
        var _S924 : bool = select(_S918, _S923, _S911);
        var _S925 : bool;
        if(_S884)
        {
            _S925 = select(scatter_0, _S924, replay_0);
        }
        else
        {
            _S925 = false;
        }
        var _S926 : TreeSample = TreeSample_x24init_0(_S839, _S839, 0.0f, u32(0));
        var _S927 : bool;
        var lit_0 : vec3<f32>;
        var lobe_index_0 : u32;
        var light_0 : TreeSample;
        if(_S925)
        {
            var _S928 : Surface = surface_4;
            var _S929 : bool = isTranslucent_0(_S880.material);
            var _S930 : u32 = stream(r_6.seed, b_3 + u32(64));
            var _S931 : TreeSample = sampleLightTree_0(ray_2.origin, _S881.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S929, _S930);
            var _S932 : bool = (any(((_S931.radiance) != _S839)));
            if(_S932)
            {
                var throughputs_2 : array<vec3<f32>, i32(5)>;
                var pdfs_2 : array<f32, i32(5)>;
                var _S933 : vec3<f32> = BSDF(ray_2.unit_direction, _S931.dir, _S881.smooth_n, _S880.material, _S883.x, _S883.y, (dot(_S928.geometry_n, (vec3<f32>(0) - ray_2.unit_direction)) * dot(_S928.geometry_n, _S931.dir)) <= 0.0f, surface_4.random_state, u32(4294967295), &(throughputs_2), &(pdfs_2));
                var _S934 : u32 = (uniforms_uint.max_bounces);
                var _S935 : bool = !(b_3 < _S934);
                if(_S935)
                {
                    _S927 = true;
                }
                else
                {
                    _S927 = (_S931.density) == 0.0f;
                }
                if(_S927)
                {
                    var _S936 : vec3<f32> = _S933 * _S931.radiance;
                    lit_0 = _S936;
                }
                else
                {
                    lobe_index_0 = u32(0);
                    lit_0 = _S839;
                    loop
                    {
                        if(lobe_index_0 < u32(5))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var _S937 : bool = (pdfs_2[lobe_index_0]) > 0.0f;
                        if(_S937)
                        {
                            var _S938 : f32 = pdfs_2[lobe_index_0] / _S931.density;
                            var lit_1 : vec3<f32> = lit_0 + throughputs_2[lobe_index_0] * vec3<f32>(pdfs_2[lobe_index_0]) / vec3<f32>((_S931.density * (1.0f + _S938 * _S938)));
                            lit_0 = lit_1;
                        }
                        var i_8 : u32 = lobe_index_0 + u32(1);
                        lobe_index_0 = i_8;
                    }
                    var _S939 : vec3<f32> = lit_0 * _S931.radiance * vec3<f32>(_S931.density);
                    lit_0 = _S939;
                }
            }
            else
            {
                lit_0 = _S839;
            }
            light_0 = _S931;
        }
        else
        {
            light_0 = _S926;
            lit_0 = _S839;
        }
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S940 : bool;
        var _S941 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S911)
        {
            var _S942 : bool = !_S879;
            if(_S942)
            {
                return _S840;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_0);
            var density_4 : f32 = density_2 * geometry_density_0;
            if(_S919)
            {
                _S927 = _S844 == u32(1);
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S919)
            {
                wrong_side_0 = _S844 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S943 : bool = !_S884;
                if(_S943)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S944 : f32 = rgb_to_greyscale(light_0.radiance);
                    is_inside_4 = !(_S944 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S840;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S919)
            {
                refracted_4 = _S844 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S945 : bool = !_S884;
                if(_S945)
                {
                    return _S840;
                }
                var _S946 : f32 = environmentPdf_0(r_6.dir);
                var _S947 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_6.dir, surface_4, _S883, is_inside_4, _S946, surface_4.random_state);
                return Shift_x24init_0(throughput_5 * _S947 * r_6.radiance / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            var _S948 : u32 = (extractBits((r_6.path), (u32(21)), (u32(1))));
            var _S949 : bool = _S884 != (_S948 == u32(1));
            if(_S949)
            {
                return _S840;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S927 = _S912;
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                var _S950 : bool = !scatter_0;
                if(_S950)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S951 : bool = _S843 != u32(1);
                    if(_S951)
                    {
                        wrong_side_0 = _S843 != u32(3);
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
                var _S952 : bool = _S843 == u32(2);
                if(_S952)
                {
                    _S863 = _S884;
                }
                else
                {
                    _S863 = false;
                }
                if(_S863)
                {
                    _S863 = !_S879;
                }
                else
                {
                    _S863 = false;
                }
                if(_S863)
                {
                    _S863 = _S844 == u32(4);
                }
                else
                {
                    _S863 = false;
                }
                if(_S863)
                {
                    var _S953 : u32 = stream(r_6.seed, b_3 + u32(256));
                    var _S954 : SkySample = sampleSky_0(ray_2, surface_4, _S883, is_inside_4, _S953, surface_4.random_state);
                    return Shift_x24init_0(throughput_3 * _S954.color, 1.0f);
                }
                if(_S952)
                {
                    is_inside_4 = _S884;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S879;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S955 : f32 = rgb_to_greyscale(light_0.radiance);
                    var _S956 : bool = !(_S955 > 0.0f);
                    if(_S956)
                    {
                        return _S840;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S853)
                {
                    is_inside_4 = _S844 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S862;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S853)
                {
                    is_inside_4 = _S844 == u32(1);
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
                    is_inside_4 = !_S879;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S840;
            }
            else
            {
                if(_S889)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S957 : bool = b_3 > u32(0);
                    if(_S957)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S901)
                        {
                            var _S958 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S958;
                        }
                        else
                        {
                            if(_S879)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S959 : vec3<f32> = throughput_3 * emission_1;
                        var _S960 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S959);
                        offer(&((*sel_4)), _S960, _S959 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S884)
                    {
                        var _S961 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S901)
                        {
                            var _S962 : vec3<f32> = safeDivide(_S961, chain_throughput_0);
                            candidate_4.radiance = _S962;
                        }
                        else
                        {
                            if(_S879)
                            {
                                candidate_4 = here_0;
                                var _S963 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S963;
                                candidate_4.dir = light_0.dir;
                                candidate_4.radiance = light_0.radiance;
                            }
                            else
                            {
                                var _S964 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S965 : u32 = (insertBits((_S964), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S965;
                            }
                        }
                        var _S966 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S961);
                        offer(&((*sel_4)), _S966, _S961 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S884)
                    {
                        var _S967 : bool = environmentMapped_0();
                        _S940 = _S967;
                    }
                    else
                    {
                        _S940 = false;
                    }
                    if(_S940)
                    {
                        var _S968 : u32 = (uniforms_uint.max_bounces);
                        _S941 = b_3 < _S968;
                    }
                    else
                    {
                        _S941 = false;
                    }
                    if(_S941)
                    {
                        var _S969 : u32 = stream(r_6.seed, b_3 + u32(256));
                        var _S970 : SkySample = sampleSky_0(ray_2, surface_4, _S883, is_inside_4, _S969, surface_4.random_state);
                        var _S971 : vec3<f32> = throughput_3 * _S970.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S901)
                        {
                            var _S972 : vec3<f32> = safeDivide(_S971, chain_throughput_0);
                            candidate_5.radiance = _S972;
                        }
                        else
                        {
                            if(_S879)
                            {
                                candidate_5 = here_0;
                                var _S973 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S973;
                                candidate_5.dir = _S970.dir;
                                candidate_5.radiance = _S970.radiance;
                            }
                            else
                            {
                                var _S974 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S975 : u32 = (insertBits((_S974), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S975;
                            }
                        }
                        var _S976 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S971);
                        offer(&((*sel_4)), _S976, _S971 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S977 : bool;
        var _S978 : bool;
        var straight_0 : bool;
        var _S979 : bool;
        var _S980 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S927 = _S912;
            }
            else
            {
                _S927 = false;
            }
            var _S981 : u32 = (extractBits((r_6.path), (u32(15)), (u32(3))));
            var _S982 : u32 = (extractBits((r_6.path), (u32(18)), (u32(3))));
            var _S983 : u32 = select(_S981, _S982, _S911);
            var refracted_5 : bool = _S983 == u32(1);
            var _S984 : SampleBSDF = SampleBSDF_x24init_0(_S839, _S839, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S984;
            var dir_10 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            if(_S927)
            {
                var _S985 : u32 = (extractBits((r_6.path), (u32(22)), (u32(1))));
                var _S986 : bool = is_inside_4 != (_S985 == u32(1));
                if(_S986)
                {
                    return _S840;
                }
                var _S987 : bool = _S843 == u32(1);
                if(_S987)
                {
                    var _S988 : vec3<f32> = (hitPosition((_S855)));
                    dir_10 = _S988;
                }
                else
                {
                    dir_10 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    var _S989 : bool = isTranslucent_0(_S880.material);
                    if(_S989)
                    {
                        wrong_side_0 = _S983 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S990 : vec3<f32> = dir_10 - ray_2.origin;
                        var _S991 : vec3<f32> = select(r_6.dir, _S990, _S987);
                        refracted_4 = (dot(_S881.smooth_n, _S991) * _S882) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S987)
                {
                    var _S992 : vec3<f32> = ray_2.origin;
                    var _S993 : Surface = surface_4;
                    var _S994 : vec3<f32> = (vec3<f32>(0) - _S881.smooth_n);
                    var _S995 : bool = is_inside_4 != refracted_4;
                    var _S996 : vec3<f32> = select(_S881.smooth_n, _S994, _S995);
                    var _S997 : vec3<f32> = (normalize((dir_10 - (_S992 + vec3<f32>(_S993.geometry_offset) * _S996))));
                    reconnection_1 = _S997;
                }
                else
                {
                    reconnection_1 = r_6.dir;
                }
                var _S998 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, surface_4.geometry_n);
                if(_S998)
                {
                    return _S840;
                }
                var _S999 : vec3<f32> = dir_10;
                lobe_index_0 = _S983;
                dir_10 = reconnection_1;
                wrong_side_0 = false;
                reconnection_1 = _S999;
            }
            else
            {
                var _S1000 : bool = !_S911;
                if(_S1000)
                {
                    var _S1001 : f32 = _S883.x;
                    var _S1002 : f32 = _S883.y;
                    var _S1003 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S881.smooth_n, _S880.material, _S1001, _S1002, surface_4.random_state);
                    var bsdf_sampled_0 : SampleBSDF = _S1003;
                    var _S1004 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S880.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1005 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S1004.geometry_n, _S880.material, _S1001, _S1002, bsdf_sampled_0.random_state);
                        bsdf_sampled_0.unit_direction = _S1005.unit_direction;
                        bsdf_sampled_0.refracted = _S1005.refracted;
                        bsdf_sampled_0.throughput = _S1005.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S1006 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S1004.geometry_n))) * _S1004.geometry_n;
                            bsdf_sampled_0.unit_direction = _S1006;
                        }
                    }
                    var _S1007 : u32 = bsdf_sampled_0.lobe;
                    var _S1008 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S1009 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S1010 : f32 = bsdf_sampled_0.pdf;
                    var _S1011 : f32 = select(_S1010, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S1011;
                    lobe_index_0 = _S1007;
                    dir_10 = _S1008;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1009;
                }
                else
                {
                    lobe_index_0 = _S983;
                    dir_10 = r_6.dir;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S927)
            {
                _S940 = true;
            }
            else
            {
                _S940 = _S911;
            }
            if(_S940)
            {
                var _S1012 : u32;
                if(lobe_index_0 == u32(4))
                {
                    _S1012 = u32(3);
                }
                else
                {
                    if(lobe_index_0 == u32(6))
                    {
                        _S1012 = u32(4);
                    }
                    else
                    {
                        _S1012 = lobe_index_0;
                    }
                }
                var _S1013 : f32 = _S883.x;
                var _S1014 : f32 = _S883.y;
                var _S1015 : bool = wrongSide_0(is_inside_4, false, dir_10, surface_4.geometry_n);
                var _S1016 : Surface = surface_4;
                var throughputs_3 : array<vec3<f32>, i32(5)>;
                var pdfs_3 : array<f32, i32(5)>;
                var _S1017 : vec3<f32> = BSDF(ray_2.unit_direction, dir_10, _S881.smooth_n, _S880.material, _S1013, _S1014, _S1015, surface_4.random_state, (u32(1) << (_S1012)), &(throughputs_3), &(pdfs_3));
                var _S1018 : bool = (pdfs_3[_S1012]) > 0.0f;
                if(_S1018)
                {
                    var _S1019 : SampleBSDF = SampleBSDF_x24init_0(dir_10, throughputs_3[_S1012], _S1016.random_state, lobe_index_0 == u32(1), lobe_index_0, pdfs_3[_S1012]);
                    lobe_2 = _S1019;
                }
            }
            var _S1020 : bool = lobe_index_0 == u32(0);
            if(_S1020)
            {
                _S941 = true;
            }
            else
            {
                _S941 = lobe_index_0 == u32(4);
            }
            if(_S941)
            {
                _S977 = true;
            }
            else
            {
                _S977 = lobe_index_0 == u32(6);
            }
            var _S1021 : bool = !_S977;
            if(_S1021)
            {
                var _S1022 : bool = (_S880.material.roughness) == 0.0f;
                if(_S1022)
                {
                    _S978 = true;
                }
                else
                {
                    var _S1023 : bool = lobe_index_0 == u32(1);
                    if(_S1023)
                    {
                        _S978 = (_S883.x) == (_S883.y);
                    }
                    else
                    {
                        _S978 = false;
                    }
                }
            }
            else
            {
                _S978 = false;
            }
            var _S1024 : bool = lobe_index_0 == u32(1);
            if(_S1024)
            {
                straight_0 = (_S880.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            var _S1025 : bool = isTranslucent_0(_S880.material);
            if(_S1025)
            {
                _S979 = _S1020;
            }
            else
            {
                _S979 = false;
            }
            if(_S979)
            {
                _S980 = (dot(dir_10, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S980 = false;
            }
            var _S1026 : bool;
            if(_S884)
            {
                _S1026 = !_S978;
            }
            else
            {
                _S1026 = false;
            }
            var _S1027 : bool;
            if(_S1026)
            {
                _S1027 = !wrong_side_0;
            }
            else
            {
                _S1027 = false;
            }
            var _S1028 : bool;
            if(_S1027)
            {
                var _S1029 : f32 = lobe_2.pdf;
                var _S1030 : vec3<f32> = ray_2.origin;
                var _S1031 : bool = isTranslucent_0(_S880.material);
                var _S1032 : vec3<f32> = select(_S881.smooth_n, _S839, _S1031);
                var _S1033 : vec3<f32> = ray_2.origin;
                var _S1034 : Surface = surface_4;
                var _S1035 : vec3<f32> = (vec3<f32>(0) - _S881.smooth_n);
                var _S1036 : vec3<f32> = select(_S881.smooth_n, _S1035, _S980);
                var _S1037 : NEEVertex = NEEVertex_x24init_0(false, _S1029, _S1030, _S1032, _S1033 + vec3<f32>(_S1034.geometry_offset) * _S1036);
                nee_vertex_0 = _S1037;
            }
            else
            {
                var _S1038 : bool = lobe_index_0 != u32(1);
                if(_S1038)
                {
                    _S1028 = true;
                }
                else
                {
                    _S1028 = (_S883.x) != (_S883.y);
                }
                if(_S1028)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S1039 : bool = (lobe_2.pdf) > 0.0f;
            if(_S1039)
            {
                if(_S977)
                {
                    _S1028 = true;
                }
                else
                {
                    _S1028 = (lobe_2.pdf * prev_0.cos / (hit_2.distance * hit_2.distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1028 = false;
            }
            var _S1040 : bool = (lobe_2.pdf) > 0.0f;
            var _S1041 : bool;
            if(_S1040)
            {
                if(_S977)
                {
                    _S1041 = true;
                }
                else
                {
                    _S1041 = (_S880.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1041 = false;
            }
            var _S1042 : bool;
            var throughput_6 : vec3<f32>;
            if(_S911)
            {
                var _S1043 : bool = !_S1028;
                if(_S1043)
                {
                    return _S840;
                }
                var _S1044 : bool = _S844 != u32(1);
                if(_S1044)
                {
                    _S1042 = _S844 != u32(2);
                }
                else
                {
                    _S1042 = false;
                }
                if(_S1042)
                {
                    var _S1045 : f32 = lobe_2.pdf;
                    var _S1046 : f32 = select(0.0f, _S1045, _S884);
                    var _S1047 : f32 = escapeWeight_0(_S1046, r_6.dir);
                    if(_S919)
                    {
                        is_inside_4 = _S850;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S1048 : f32 = select(1.0f, _S1047, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_6.radiance * vec3<f32>(_S1048) / vec3<f32>(r_6.jac), density_3 * lobe_2.pdf / r_6.jac);
                }
                var _S1049 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S1050 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S1049;
                density_5 = _S1050;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S1042 = b_3 <= _S854;
            }
            else
            {
                _S1042 = false;
            }
            var _S1051 : bool;
            if(_S1042)
            {
                _S1051 = _S879;
            }
            else
            {
                _S1051 = false;
            }
            var _S1052 : bool;
            if(_S1051)
            {
                _S1052 = _S1028;
            }
            else
            {
                _S1052 = false;
            }
            var _S1053 : bool;
            if(_S1052)
            {
                _S1053 = true;
            }
            else
            {
                if(_S927)
                {
                    _S1053 = !_S1041;
                }
                else
                {
                    _S1053 = false;
                }
            }
            if(_S1053)
            {
                return _S840;
            }
            var throughput_7 : vec3<f32>;
            if(_S927)
            {
                var _S1054 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1055 : f32 = lobe_2.pdf;
                throughput_7 = _S1054;
                survival_probability_0 = _S1055;
            }
            else
            {
                var _S1056 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S839);
                throughput_7 = _S1056;
                survival_probability_0 = density_5;
            }
            var _S1057 : bool;
            if(_S889)
            {
                _S1057 = !_S901;
            }
            else
            {
                _S1057 = false;
            }
            var _S1058 : bool;
            if(_S1057)
            {
                _S1058 = _S879;
            }
            else
            {
                _S1058 = false;
            }
            var _S1059 : bool;
            if(_S1058)
            {
                _S1059 = _S1028;
            }
            else
            {
                _S1059 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S1059)
            {
                chain_0 = here_0;
                var _S1060 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1061 : u32 = select(u32(0), u32(1), _S884);
                var _S1062 : u32 = (insertBits((_S1060), (_S1061), (u32(21)), (u32(1))));
                chain_0.path = _S1062;
                var _S1063 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S1063;
                chain_0.dir = dir_10;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1064 : Vertex = Vertex_x24init_0(_S1041, lobe_index_0, lobe_2.pdf, abs(dot(surface_4.geometry_n, dir_10)), is_inside_4);
            prev_0 = _S1064;
            var _S1065 : f32 = lobe_2.pdf;
            var _S1066 : bool;
            if(_S1024)
            {
                _S1066 = (_S883.x) == (_S883.y);
            }
            else
            {
                _S1066 = false;
            }
            var _S1067 : f32 = select(_S1065, sky_pdf_0, _S1066);
            var _S1068 : bool;
            if(refracted_4)
            {
                _S1068 = !_S980;
            }
            else
            {
                _S1068 = false;
            }
            var is_inside_5 : bool;
            if(_S1068)
            {
                var _S1069 : bool = !is_inside_4;
                is_inside_5 = _S1069;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_10;
            var _S1070 : Surface = surface_4;
            var _S1071 : f32 = select(_S1070.geometry_offset, 0.0f, straight_0);
            var _S1072 : vec3<f32> = (vec3<f32>(0) - _S881.smooth_n);
            var _S1073 : bool = is_inside_5 != _S980;
            var _S1074 : vec3<f32> = select(_S881.smooth_n, _S1072, _S1073);
            var _S1075 : vec3<f32> = ray_2.origin + vec3<f32>(_S1071) * _S1074;
            ray_2.origin = _S1075;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1067;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            straight_0 = false;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S889)
        {
            if(_S862)
            {
                var _S1076 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1077 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1078 : bool = _S1077 == u32(1);
                if(_S1078)
                {
                    var _S1079 : vec3<f32> = safeDivide(_S1076, chain_throughput_0);
                    candidate_6.radiance = _S1079;
                }
                var _S1080 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1076);
                offer(&((*sel_4)), _S1080, _S1076 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S862)
            {
                _S927 = true;
            }
            else
            {
                _S927 = scatter_0;
            }
            if(_S927)
            {
                var _S1081 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1081;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1082 : u32 = stream(r_6.seed, b_3 + u32(128));
            var _S1083 : Random = pcg(_S1082);
            var _S1084 : bool = survival_probability_0 < (_S1083.value);
            if(_S1084)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1085 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1085;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1086 : f32 = density_5 * survival_probability_0;
            density_2 = _S1086;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1087 : Ray = ray_2;
        var _S1088 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S927 = _S912;
        }
        else
        {
            _S927 = false;
        }
        if(_S927)
        {
            wrong_side_0 = _S843 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1089 : f32 = select(4.294967296e+09f, _S1088, wrong_side_0);
        var _S1090 : Hit;
        if(straight_0)
        {
            _S1090 = hit_2;
        }
        else
        {
            _S1090 = Hit_x24init_0(vec2<f32>(0.0f), u32(4294967295), u32(0), u32(0), 0.0f);
        }
        var _S1091 : Hit = (traverseInstanceBVH((_S1087), (_S868), (_S1089), (_S1090)));
        hit_2 = _S1091;
        if(replay_0)
        {
            refracted_4 = _S912;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S940 = _S843 == u32(1);
        }
        else
        {
            _S940 = false;
        }
        if(_S940)
        {
            _S941 = (hit_2.instance_index) == (_S855.instance_index);
        }
        else
        {
            _S941 = false;
        }
        if(_S941)
        {
            _S977 = (hit_2.triangle_index) == (_S855.triangle_index);
        }
        else
        {
            _S977 = false;
        }
        if(_S977)
        {
            hit_2.uv = _S855.uv;
            var _S1092 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1092;
        }
        if(replay_0)
        {
            _S978 = _S912;
        }
        else
        {
            _S978 = false;
        }
        if(_S978)
        {
            _S979 = _S843 == u32(3);
        }
        else
        {
            _S979 = false;
        }
        if(_S979)
        {
            _S980 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S980 = false;
        }
        if(_S980)
        {
            return _S840;
        }
        var _S1093 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1093)
        {
            var _S1094 : bool = !nee_vertex_0.none;
            var _S1095 : f32 = select(0.0f, sky_pdf_0, _S1094);
            var _S1096 : f32 = escapeWeight_0(_S1095, ray_2.unit_direction);
            var _S1097 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1098 : vec3<f32> = throughput_2 * _S1097;
            if(replay_0)
            {
                if(_S912)
                {
                    is_inside_4 = _S843 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1098 * vec3<f32>(_S1096) / vec3<f32>(r_6.jac), density_2 / r_6.jac);
                }
                if(_S853)
                {
                    is_inside_4 = _S850;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_3 == _S841;
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
                    return Shift_x24init_0(_S1098 * vec3<f32>(_S1096), 1.0f);
                }
                return _S840;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1099 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1100 : bool = _S1099 == u32(1);
            if(_S1100)
            {
                var _S1101 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1102 : bool = _S1101 == b_3;
                var _S1103 : f32 = select(_S1096, 1.0f, _S1102);
                var _S1104 : vec3<f32> = safeDivide(_S1098 * vec3<f32>(_S1103), chain_throughput_0);
                candidate_7.radiance = _S1104;
            }
            else
            {
                var _S1105 : bool = prev_0.rough;
                if(_S1105)
                {
                    var _S1106 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                    var _S1107 : u32 = (insertBits((_S1106), (u32(3)), (u32(10)), (u32(2))));
                    var _S1108 : u32 = (insertBits((_S1107), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1109 : bool = prev_0.inside;
                    var _S1110 : u32 = select(u32(0), u32(1), _S1109);
                    var _S1111 : u32 = (insertBits((_S1108), (_S1110), (u32(22)), (u32(1))));
                    candidate_7.path = _S1111;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1112 : vec3<f32> = _S1098 * vec3<f32>(_S1096);
            var _S1113 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1112);
            offer(&((*sel_4)), _S1113, _S1112 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1114 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1114;
        var _S1115 : u32 = b_3 + u32(1);
        b_3 = _S1115;
    }
    return _S840;
}

fn shift_0( dom_5 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S1116 : vec3<f32> = vec3<f32>(0.0f);
    var _S1117 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1116, 0.0f, vec4<u32>(u32(0)), _S1116, _S1116), 0.0f, _S1116, u32(0));
    var sel_5 : Selection = _S1117;
    var _S1118 : bool = (r_7.w) <= 0.0f;
    if(_S1118)
    {
        return Shift_x24init_0(_S1116, 0.0f);
    }
    var _S1119 : Shift = walk_0(dom_5, r_7, true, 0.0f, &(sel_5));
    return _S1119;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1120 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1121 : bool = _S1120 != u32(4294967295);
    if(_S1121)
    {
        var _S1122 : vec2<i32> = vec2<i32>((vec2<u32>(_S1120, (_S1120 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1123 : vec3<f32> = vec3<f32>(0.0f);
        var _S1124 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1123, _S1123, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1123, 0.0f, vec4<u32>(u32(0)), _S1123, _S1123));
        var shift_job_0 : ShiftJob = _S1124;
        var _S1125 : u32 = (_S1120 >> (u32(28)));
        var _S1126 : bool = spatialJob_0(_S1122, _S1125, &(shift_job_0));
        var _S1127 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1122), (_S1125), (vec4<u32>((bitcast<vec3<u32>>((_S1127.f))), (bitcast<u32>((_S1127.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1128 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1129 : array<u32, i32(3)>;
    spatialBins_0(_S1128, &(_S1129));
    var _S1130 : array<u32, i32(3)> = _S1129;
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
        var _S1131 : bool = (_S1130[t_16]) == u32(40);
        if(_S1131)
        {
            textureStore(shift_data_out, (_S1128), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1128, _S1130, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1132 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1132));
    countShifts_0(_S1132, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1133 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1134 : bool = _S1133 != u32(4294967295);
    if(_S1134)
    {
        var _S1135 : vec2<i32> = vec2<i32>((vec2<u32>(_S1133, (_S1133 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1136 : vec3<f32> = vec3<f32>(0.0f);
        var _S1137 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1136, _S1136, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1136, 0.0f, vec4<u32>(u32(0)), _S1136, _S1136));
        var shift_job_1 : ShiftJob = _S1137;
        var _S1138 : u32 = (_S1133 >> (u32(28)));
        var _S1139 : bool = temporalJob_0(_S1135, _S1138, &(shift_job_1));
        var _S1140 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1135), (_S1138), (vec4<u32>((bitcast<vec3<u32>>((_S1140.f))), (bitcast<u32>((_S1140.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1141 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1142 : array<u32, i32(3)>;
    temporalBins_0(_S1141, &(_S1142));
    var _S1143 : array<u32, i32(3)> = _S1142;
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
        var _S1144 : bool = (_S1143[t_18]) == u32(40);
        if(_S1144)
        {
            textureStore(temporal_shifts_out, (_S1141), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1141, _S1143, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1145 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1145));
    countShifts_0(_S1145, local_invocation_index_9);
    return;
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1146 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1147 : vec3<f32> = vec3<f32>(0.0f);
    var _S1148 : Domain = Domain_x24init_0(_S1147, _S1147, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1148;
    var _S1149 : bool = (currentDomain((_S1146), &(dom_6)));
    var _S1150 : bool = !_S1149;
    if(_S1150)
    {
        storeReservoir(reservoir_temp_out, (_S1146), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1147, 0.0f, vec4<u32>(u32(0)), _S1147, _S1147)), (dom_6.hit));
        return;
    }
    var _S1151 : Reservoir = (loadReservoir(reservoir_initial, (_S1146)));
    var _S1152 : vec2<i32> = temporalNeighbor_0(_S1146, dom_6);
    var _S1153 : bool = (_S1152.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1153)
    {
        var _S1154 : Reservoir = (loadReservoir(reservoir_prev, (_S1152)));
        var _S1155 : vec4<u32> = (textureLoad(duplication, (_S1152), 0, 0));
        var _S1156 : f32 = (bitcast<f32>((_S1155.x)));
        var _S1157 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1158 : bool = _S1157 == u32(1);
        var _S1159 : f32 = select(0.0f, _S1156, _S1158);
        var _S1160 : f32 = (mix((20.0f), (1.0f), (pow(_S1159, 0.10000000149011612f))));
        var _S1161 : f32 = min(_S1154.c, _S1160);
        var _S1162 : vec4<u32> = (textureLoad(temporal_shifts, (_S1146), (u32(0)), 0));
        var _S1163 : vec4<f32> = (bitcast<vec4<f32>>((_S1162)));
        var _S1164 : vec4<f32> = vec4<f32>(_S1151.f, 1.0f);
        var _S1165 : Domain = (previousDomain((_S1152)));
        var _S1166 : bool = sameDomain_0(_S1165, dom_6);
        var _S1167 : bool = !_S1166;
        var to_previous_0 : vec4<f32>;
        if(_S1167)
        {
            var _S1168 : vec4<u32> = (textureLoad(temporal_shifts, (_S1146), (u32(1)), 0));
            var _S1169 : vec4<f32> = (bitcast<vec4<f32>>((_S1168)));
            to_previous_0 = _S1169;
        }
        else
        {
            to_previous_0 = _S1164;
        }
        var _S1170 : f32 = rgb_to_greyscale(_S1151.f);
        var _S1171 : f32 = rgb_to_greyscale(_S1154.f);
        var _S1172 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1147, 0.0f, vec4<u32>(u32(0)), _S1147, _S1147), 0.0f, _S1147, u32(0));
        var sel_6 : Selection = _S1172;
        var _S1173 : u32 = (uniforms_uint.frame);
        var _S1174 : u32 = hash(_S1173);
        var _S1175 : u32 = global_invocation_id_7.x;
        var _S1176 : vec2<u32> = (uniforms_uint.render_size);
        var _S1177 : u32 = stream(_S1174, _S1175 + _S1176.x * global_invocation_id_7.y);
        var _S1178 : u32 = stream(_S1177, u32(194));
        sel_6.random_state = _S1178;
        var _S1179 : f32 = _S1151.c * _S1170;
        var _S1180 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1181 : f32 = _S1179 / (_S1179 + _S1161 * _S1180);
        var _S1182 : f32 = _S1161 * _S1171;
        var _S1183 : vec3<f32> = _S1163.xyz;
        var _S1184 : f32 = rgb_to_greyscale(_S1183);
        var _S1185 : f32 = _S1182 / (_S1182 + _S1151.c * _S1184);
        var _S1186 : vec2<f32> = vec2<f32>(_S1181, _S1185);
        offerShifted(&(sel_6), _S1151, Shift_x24init_0(_S1151.f, 1.0f), _S1181);
        offerShifted(&(sel_6), _S1154, Shift_x24init_0(_S1183, _S1163.w), _S1185);
        var _S1187 : Reservoir = finalize(sel_6, _S1151.c + _S1161);
        r_8 = _S1187;
    }
    else
    {
        r_8 = _S1151;
    }
    storeReservoir(reservoir_temp_out, (_S1146), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1188 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1189 : vec3<f32> = vec3<f32>(0.0f);
    var _S1190 : Domain = Domain_x24init_0(_S1189, _S1189, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1190;
    var _S1191 : bool = (currentDomain((_S1188), &(dom_7)));
    var _S1192 : bool = !_S1191;
    if(_S1192)
    {
        storeReservoir(reservoir_initial_out, (_S1188), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1189, 0.0f, vec4<u32>(u32(0)), _S1189, _S1189)), (dom_7.hit));
        return;
    }
    var _S1193 : u32 = (uniforms_uint.frame);
    var _S1194 : u32 = hash(_S1193);
    var _S1195 : u32 = global_invocation_id_8.x;
    var _S1196 : vec2<u32> = (uniforms_uint.render_size);
    var _S1197 : u32 = stream(_S1194, _S1195 + _S1196.x * global_invocation_id_8.y);
    var _S1198 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1189, 0.0f, vec4<u32>(u32(0)), _S1189, _S1189);
    var _S1199 : Selection = Selection_x24init_0(_S1198, 0.0f, _S1189, u32(0));
    var initial_0 : Selection = _S1199;
    var _S1200 : u32 = stream(_S1197, u32(193));
    initial_0.random_state = _S1200;
    var i_9 : u32 = u32(0);
    loop
    {
        var _S1201 : u32 = (uniforms_uint.samples);
        if(i_9 < _S1201)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1198;
        var _S1202 : u32 = stream(_S1197, i_9);
        r_9.seed = _S1202;
        var _S1203 : u32 = (uniforms_uint.samples);
        var _S1204 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1203), &(initial_0));
        var i_10 : u32 = i_9 + u32(1);
        i_9 = i_10;
    }
    var _S1205 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1188), (_S1205), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1206 : Random = pcg(state_3);
    var _S1207 : Random = pcg(_S1206.state);
    var _S1208 : f32 = 6.28318548202514648f * _S1206.value;
    var _S1209 : f32 = sqrt(-2.0f * clamp(log(_S1207.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1207.state, _S1209 * cos(_S1208));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1210 : RandomSphere;
    _S1210.state = state_4;
    _S1210.value = value_1;
    return _S1210;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1211 : Random = normal_distribution(state_5);
    var _S1212 : Random = normal_distribution(_S1211.state);
    var _S1213 : Random = normal_distribution(_S1212.state);
    var _S1214 : vec3<f32> = (normalize((vec3<f32>(_S1211.value, _S1212.value, _S1213.value))));
    return RandomSphere_x24init_0(_S1213.state, _S1214);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1215 : vec3<f32> = p1_0 - p0_0;
    var _S1216 : vec3<f32> = p2_0 - p0_0;
    var _S1217 : vec2<f32> = uv1_0 - uv0_0;
    var _S1218 : vec2<f32> = uv2_0 - uv0_0;
    var _S1219 : f32 = _S1217.x;
    var _S1220 : f32 = _S1218.y;
    var _S1221 : f32 = _S1217.y;
    var _S1222 : f32 = _S1218.x;
    var _S1223 : f32 = _S1219 * _S1220 - _S1221 * _S1222;
    var _S1224 : f32 = 1.0f / _S1223;
    var _S1225 : vec3<f32> = vec3<f32>(_S1224);
    var t_20 : vec3<f32> = (_S1215 * vec3<f32>(_S1220) - _S1216 * vec3<f32>(_S1221)) * _S1225;
    var _S1226 : vec3<f32> = (_S1216 * vec3<f32>(_S1219) - _S1215 * vec3<f32>(_S1222)) * _S1225;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1227 : bool = (dot(cross(n_9, t_21), _S1226)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1227)
    {
        var _S1228 : vec3<f32> = ((-(t_21)));
        t_22 = _S1228;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1229 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1229, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_3 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1230 : vec3<f32> = t1_0 - t0_0;
    var _S1231 : vec3<f32> = t2_2 - t0_0;
    var _S1232 : vec3<f32> = t2_2 - t1_0;
    var _S1233 : f32 = min(length(_S1230), min(length(_S1231), length(_S1232)));
    var _S1234 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1235 : vec3<f32> = (normalize((n0_0)));
    var _S1236 : f32 = dot(geometry_n_3, _S1235);
    var _S1237 : vec3<f32> = (normalize((n1_0)));
    var _S1238 : f32 = dot(geometry_n_3, _S1237);
    var _S1239 : vec3<f32> = (normalize((n2_0)));
    var _S1240 : vec3<f32> = acos(abs(vec3<f32>(_S1236, _S1238, dot(geometry_n_3, _S1239))));
    var _S1241 : vec3<f32> = clamp(tan(_S1240), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1234 * _S1241, uvw_0), 0.0f, _S1233 * 0.125f);
}

fn straightThrough( dir_11 : vec3<f32>,  n_10 : vec3<f32>,  material_19 : Material) -> vec3<f32>
{
    var _S1242 : vec3<f32> = ((-(dir_11)));
    var _S1243 : f32 = (sign((dot(n_10, _S1242))));
    var _S1244 : vec3<f32> = n_10 * vec3<f32>(_S1243);
    var _S1245 : AnisotropicFrame = anisotropicFrame(material_19, _S1244);
    var _S1246 : bool = (_S1245.alphas.x) > 0.0f;
    if(_S1246)
    {
        var _S1247 : f32 = material_19.transmission * (1.0f - material_19.metallic);
        var _S1248 : vec3<f32> = ((-(_S1244)));
        var _S1249 : vec3<f32> = anisotropicLocal(dir_11, _S1245.tangent, _S1248);
        var _S1250 : f32 = anisotropicG1(_S1249, _S1245.alphas);
        return vec3<f32>((_S1247 * _S1250)) * material_19.albedo;
    }
    var _S1251 : f32 = material_19.transmission * (1.0f - material_19.metallic);
    var _S1252 : f32 = material_19.roughness;
    var _S1253 : f32 = smithG1(_S1252 * _S1252, abs(dot(n_10, dir_11)));
    return vec3<f32>((_S1251 * _S1253)) * material_19.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_20 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1254 : vec3<f32>;
    if((material_20.ior) == 1.0f)
    {
        var _S1255 : vec3<f32> = straightThrough(toward_1, n_11, material_20);
        _S1254 = _S1255;
    }
    else
    {
        _S1254 = vec3<f32>(0.0f);
    }
    return _S1254 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1256 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1256;
}

fn shift_hook( dom_9 : Domain,  r_11 : Reservoir) -> Shift
{
    var _S1257 : Shift = shift_0(dom_9, r_11);
    return _S1257;
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

