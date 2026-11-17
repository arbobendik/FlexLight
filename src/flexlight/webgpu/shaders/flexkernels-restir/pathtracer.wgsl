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

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S250 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S251 : f32 = _S250.x;
    var _S252 : f32 = _S250.y;
    var _S253 : f32 = _S251 * _S251 + _S252 * _S252;
    const _S254 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S255 : vec3<f32> = vec3<f32>(- _S252, _S251, 0.0f);
    var _S256 : f32 = (inverseSqrt((_S253)));
    var _S257 : vec3<f32> = _S255 * vec3<f32>(_S256);
    var _S258 : bool = _S253 > 0.0f;
    var _S259 : vec3<f32> = select(_S254, _S257, _S258);
    var _S260 : vec3<f32> = cross(_S250, _S259);
    var _S261 : f32 = sqrt(U1_0);
    var _S262 : f32 = 6.28318548202514648f * U2_0;
    var _S263 : f32 = _S261 * cos(_S262);
    var t2_0 : f32 = _S261 * sin(_S262);
    var _S264 : f32 = 0.5f * (1.0f + _S250.z);
    var t2_1 : f32 = (1.0f - _S264) * sqrt(max(0.0f, 1.0f - _S263 * _S263)) + _S264 * t2_0;
    var _S265 : vec3<f32> = vec3<f32>(_S263) * _S259 + vec3<f32>(t2_1) * _S260;
    var _S266 : f32 = ((_S263));
    var _S267 : f32 = ((_S263));
    var _S268 : vec3<f32> = _S265 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S266 * _S267 - t2_1 * t2_1))) * _S250;
    var _S269 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S268.x, alpha_0 * _S268.y, max(0.0f, _S268.z)))));
    return _S269;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S270 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S270)
    {
        const _S271 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S271;
    }
    else
    {
        a_4 = a_3;
    }
    var _S272 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S273 : vec3<f32> = cross(n_3, _S272);
    return vec3<f32>(dot(v_1, _S272), dot(v_1, n_3), dot(v_1, _S273));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S274 : Random = pcg((*random_state_0));
    var _S275 : Random = pcg(_S274.state);
    (*random_state_0) = _S275.state;
    var _S276 : f32 = frame_0.alphas.x;
    var _S277 : bool = _S276 > 0.0f;
    if(_S277)
    {
        var _S278 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S279 : f32 = frame_0.alphas.y;
        var _S280 : vec3<f32> = (normalize((vec3<f32>(_S276 * _S278.x, _S279 * _S278.y, _S278.z))));
        var _S281 : vec3<f32> = sampleGGXVNDF(_S280, 1.0f, _S274.value, _S275.value);
        var _S282 : vec3<f32> = (normalize((vec3<f32>(_S276 * _S281.x, _S279 * _S281.y, _S281.z))));
        return vec3<f32>(_S282.x) * frame_0.tangent + vec3<f32>(_S282.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S282.z) * n_i_1;
    }
    var _S283 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S284 : vec3<f32> = sampleGGXVNDF(_S283.xzy, alpha_1, _S274.value, _S275.value);
    var _S285 : vec3<f32> = _S284.xzy;
    var _S286 : vec3<f32> = tangentToWorld(_S285, n_i_1);
    return _S286;
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

fn fresnel( cos_theta_0 : f32,  eta_i_0 : f32,  eta_o_0 : f32) -> f32
{
    var _S287 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S288 : f32 = eta_i_0 / eta_o_0 * _S287;
    var _S289 : bool = _S288 < 1.0f;
    var kr_0 : f32;
    if(_S289)
    {
        var _S290 : f32 = sqrt(max(0.0f, 1.0f - _S288 * _S288));
        var _S291 : f32 = eta_o_0 * cos_theta_0;
        var _S292 : f32 = eta_i_0 * _S290;
        var _S293 : f32 = (_S291 - _S292) / (_S291 + _S292);
        var _S294 : f32 = eta_i_0 * cos_theta_0;
        var _S295 : f32 = eta_o_0 * _S290;
        var _S296 : f32 = (_S294 - _S295) / (_S294 + _S295);
        var _S297 : f32 = (_S293 * _S293 + _S296 * _S296) / 2.0f;
        kr_0 = _S297;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenAlbedo( mu_0 : f32,  r_2 : f32) -> f32
{
    var _S298 : f32 = sqrt(0.05000000074505806f);
    var _S299 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S300 : f32 = (clamp(sqrt(max(r_2, 0.0f)), _S298, 1.0f) - _S298) / (1.0f - _S298) * 23.0f;
    var _S301 : u32 = min(u32(_S299), u32(22));
    var _S302 : u32 = min(u32(_S300), u32(22));
    var _S303 : f32 = _S299 - f32(_S301);
    var _S304 : f32 = _S300 - f32(_S302);
    var _S305 : u32 = _S301 * u32(24) + _S302;
    var _S306 : u32 = _S305 + u32(24);
    var _S307 : f32 = SHEEN_ALBEDO_0[_S305] + (SHEEN_ALBEDO_0[_S306] - SHEEN_ALBEDO_0[_S305]) * _S303;
    var _S308 : u32 = _S305 + u32(1);
    var _S309 : f32 = SHEEN_ALBEDO_0[_S308] + (SHEEN_ALBEDO_0[_S306 + u32(1)] - SHEEN_ALBEDO_0[_S308]) * _S303;
    return exp(_S307 + (_S309 - _S307) * _S304);
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S310 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S310 / (_S310 + length(vec3<f32>(alphas_1.x * w_2.x, alphas_1.y * w_2.y, _S310)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S311 : f32 = alphas_2.x;
    var _S312 : f32 = h_0.x / _S311;
    var _S313 : f32 = alphas_2.y;
    var _S314 : f32 = h_0.y / _S313;
    var _S315 : f32 = h_0.z;
    var _S316 : f32 = _S312 * _S312 + _S314 * _S314 + _S315 * _S315;
    return 1.0f / max(3.14159274101257324f * _S311 * _S313 * _S316 * _S316, 1.17549435082228751e-38f);
}

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_3 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S317 : BSDFLobes;
    _S317.v_dot_h = v_dot_h_0;
    _S317.n_dot_h = n_dot_h_0;
    _S317.refracted = refracted_1;
    _S317.F = F_0;
    _S317.F_greyscale = F_greyscale_0;
    _S317.reflect_weight = reflect_weight_0;
    _S317.diffuse_weight = diffuse_weight_0;
    _S317.refract_weight = refract_weight_0;
    _S317.p_diffuse = p_diffuse_0;
    _S317.p_reflect = p_reflect_0;
    _S317.p_refract = p_refract_0;
    _S317.translucent_share = translucent_share_0;
    _S317.sheen = sheen_0;
    _S317.view = view_1;
    _S317.tangent = tangent_1;
    _S317.alphas = alphas_3;
    _S317.visible = visible_0;
    return _S317;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S318 : f32 = dot(ggx_n_0, v_3);
    var _S319 : f32 = dot(n_i_2, ggx_n_0);
    var _S320 : f32 = eta_i_1 / eta_o_1;
    var _S321 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S320))));
    var _S322 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S323 : f32 = _S322 * _S322;
    var _S324 : f32 = (1.0f + _S322) / (1.0f - _S322);
    var _S325 : f32 = abs(_S318);
    var _S326 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S326)
    {
        sheen_component_0 = _S324;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S326)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S324;
    }
    var _S327 : f32 = fresnel(_S325, sheen_component_0, visible_1);
    var _S328 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S318 * _S318)) >= (eta_o_1 * eta_o_1);
    var _S329 : vec3<f32>;
    if(_S328)
    {
        _S329 = vec3<f32>(1.0f);
    }
    else
    {
        var _S330 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S323);
        _S329 = _S330 + (vec3<f32>(1.0f) - _S330) * vec3<f32>((_S327 - _S323)) / vec3<f32>((1.0f - _S323));
    }
    var _S331 : vec3<f32> = vec3<f32>(1.0f);
    var _S332 : vec3<f32> = vec3<f32>(0.0f);
    var _S333 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S334 : bool = _S333 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S334)
    {
        var _S335 : f32 = sheenAlbedo(dot(n_i_2, v_3), material_1.sheen_roughness);
        var _S336 : f32 = min(_S335, 1.0f);
        var _S337 : vec3<f32> = vec3<f32>(1.0f) - material_1.sheen * vec3<f32>(_S336);
        var _S338 : f32 = rgb_to_greyscale(material_1.sheen);
        var _S339 : f32 = _S338 * _S336;
        var _S340 : vec3<f32> = material_1.sheen / vec3<f32>(max(_S335, 1.0f));
        scale_0 = _S337;
        sheen_component_0 = _S339;
        sheen_1 = _S340;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S331;
        sheen_component_0 = 0.0f;
        sheen_1 = _S332;
        view_2 = _S332;
    }
    var _S341 : vec3<f32> = (mix((_S329), (material_1.albedo), (material_1.metallic)));
    var F_1 : vec3<f32> = _S341 * scale_0;
    var _S342 : f32 = rgb_to_greyscale(F_1);
    var _S343 : f32 = 1.0f - material_1.metallic;
    var _S344 : vec3<f32> = vec3<f32>(1.0f) - _S329;
    var _S345 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S343)) * _S344 * scale_0;
    var _S346 : vec3<f32> = vec3<f32>((material_1.transmission * _S343)) * _S344 * scale_0;
    var _S347 : f32 = max(_S342, 0.0f);
    var _S348 : f32 = rgb_to_greyscale(_S345);
    var _S349 : f32 = max(_S348, 0.0f);
    var _S350 : f32 = rgb_to_greyscale(_S346);
    var _S351 : f32 = (sign((length(_S321))));
    var _S352 : f32 = max(_S350 * _S351, 0.0f);
    var _S353 : f32 = _S347 + _S349 + _S352 + sheen_component_0;
    var _S354 : f32 = 1.0f / max(_S353, 0.0000152587890625f);
    var _S355 : f32 = (_S349 + sheen_component_0) * _S354;
    var _S356 : f32 = _S347 * _S354;
    var _S357 : f32 = _S352 * _S354;
    var _S358 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S358)
    {
        var _S359 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S360 : f32 = anisotropicG1(_S359, frame_1.alphas);
        var _S361 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S362 : f32 = anisotropicD(_S361, frame_1.alphas);
        var _S363 : f32 = _S360 * _S362;
        visible_1 = _S363;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S318, _S319, _S321, F_1, _S342, 1.0f, _S345, _S346, _S355, _S356, _S357, 0.0f, sheen_1, view_2, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S364 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S365 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S366 : f32 = _S364 / (_S365 + _S364);
    var _S367 : bool = _S364 > 0.0f;
    var _S368 : f32 = select(0.0f, _S366, _S367);
    return _S368;
}

fn smithG1( alpha_2 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S369 : f32 = alpha_2 * alpha_2;
    var _S370 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S369 + (1.0f - _S369) * n_dot_x_0 * n_dot_x_0));
    var _S371 : bool = alpha_2 > 0.0f;
    var _S372 : f32 = select(1.0f, _S370, _S371);
    return _S372;
}

fn trowbridgeReitz( alpha_3 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S373 : f32 = alpha_3 * alpha_3;
    var _S374 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S373 * n_dot_h_1 * n_dot_h_1;
    return _S373 / max(3.14159274101257324f * _S374 * _S374, 1.17549435082228751e-38f);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S375 : bool = lobe_0 == u32(0);
    if(_S375)
    {
        var _S376 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S377 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S378 : f32 = 1.0f - lobes_0.translucent_share;
        var _S379 : bool = n_i_dot_l_0 < 0.0f;
        var _S380 : f32 = select(_S378, lobes_0.translucent_share, _S379);
        var _S381 : f32 = _S377 * _S380;
        var _S382 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S383 : f32 = select(_S376, _S381, _S382);
        var _S384 : bool = n_i_dot_v_0 > 0.0f;
        var _S385 : f32 = select(0.0f, _S383, _S384);
        return _S385;
    }
    var _S386 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S387 : f32 = _S386 * lobes_0.v_dot_h;
    var _S388 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S389 : f32 = _S387 * _S388 / n_i_dot_v_0;
    var _S390 : bool = alpha_4 > 0.0f;
    var _S391 : bool;
    if(_S390)
    {
        _S391 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S391 = false;
    }
    if(_S391)
    {
        _S391 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S391 = false;
    }
    if(_S391)
    {
        _S391 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S391 = false;
    }
    var _S392 : f32 = select(0.0f, _S389, _S391);
    var _S393 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S393)
    {
        var _S394 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S395 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S395)
        {
            _S391 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S391 = false;
        }
        if(_S391)
        {
            _S391 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S391 = false;
        }
        var _S396 : f32 = select(0.0f, _S394, _S391);
        pdf_h_0 = _S396;
    }
    else
    {
        pdf_h_0 = _S392;
    }
    var _S397 : bool = lobe_0 == u32(1);
    if(_S397)
    {
        var _S398 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S399 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S398 * _S398);
        var _S400 : bool = eta_i_2 != eta_o_2;
        if(_S400)
        {
            _S391 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S391 = false;
        }
        var _S401 : f32 = select(0.0f, _S399, _S391);
        return _S401;
    }
    var _S402 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S403 : bool = pdf_h_0 > 0.0f;
    var _S404 : f32 = select(0.0f, _S402, _S403);
    return _S404;
}

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_1 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S405 : SampleBSDF;
    _S405.unit_direction = unit_direction_1;
    _S405.throughput = throughput_0;
    _S405.random_state = random_state_1;
    _S405.refracted = refracted_2;
    _S405.lobe = lobe_1;
    _S405.pdf = pdf_0;
    return _S405;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_4 : vec3<f32>,  n_4 : vec3<f32>,  r_3 : f32) -> f32
{
    var _S406 : f32 = 1.0f / max(r_3, 0.05000000074505806f);
    var _S407 : vec3<f32> = (normalize((l_0 + v_4)));
    var _S408 : f32 = dot(n_4, _S407);
    var _S409 : f32 = max(dot(n_4, l_0), 0.0f);
    var _S410 : f32 = max(dot(n_4, v_4), 0.0f);
    return (2.0f + _S406) * pow(max(1.0f - _S408 * _S408, 0.0f), 0.5f * _S406) * 0.5f * 0.31830987334251404f / max(4.0f * (_S409 + _S410 - _S409 * _S410), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes,  lobe_2 : u32) -> vec3<f32>
{
    var _S411 : bool = lobe_2 == u32(0);
    if(_S411)
    {
        var _S412 : bool = (dot(n_i_3, l_1)) < 0.0f;
        var _S413 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S412);
        var _S414 : f32 = 1.0f - lobes_1.translucent_share;
        var _S415 : f32 = select(_S414, lobes_1.translucent_share, _S412);
        var _S416 : vec3<f32> = _S413 / vec3<f32>(_S415);
        var _S417 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S418 : vec3<f32> = select(material_3.albedo, _S416, _S417);
        var _S419 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S420 : bool = _S419 > 0.0f;
        var _S421 : bool;
        if(_S420)
        {
            _S421 = !_S412;
        }
        else
        {
            _S421 = false;
        }
        if(_S421)
        {
            var _S422 : vec3<f32> = lobes_1.diffuse_weight * _S418;
            var _S423 : vec3<f32> = lobes_1.sheen * vec3<f32>(3.14159274101257324f);
            var _S424 : f32 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            var _S425 : vec3<f32> = _S423 * vec3<f32>(_S424);
            var _S426 : f32 = select(1.0f, _S414, _S417);
            return (_S422 + _S425 / vec3<f32>(_S426)) / vec3<f32>(lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S418 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S427 : bool = lobe_2 == u32(1);
    var G1_l_0 : f32;
    if(_S427)
    {
        var _S428 : f32 = - dot(n_i_3, l_1);
        var _S429 : f32 = smithG1(alpha_5, max(_S428, 0.0f));
        var _S430 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S430)
        {
            var _S431 : vec3<f32> = ((-(n_i_3)));
            var _S432 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, _S431);
            var _S433 : f32 = anisotropicG1(_S432, lobes_1.alphas);
            G1_l_0 = _S433;
        }
        else
        {
            G1_l_0 = _S429;
        }
        return lobes_1.refract_weight * vec3<f32>(G1_l_0) * material_3.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S434 : f32 = dot(n_i_3, l_1);
    var _S435 : f32 = smithG1(alpha_5, max(_S434, 0.0f));
    var _S436 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S436)
    {
        var _S437 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        var _S438 : f32 = anisotropicG1(_S437, lobes_1.alphas);
        G1_l_0 = _S438;
    }
    else
    {
        G1_l_0 = _S435;
    }
    return vec3<f32>((lobes_1.reflect_weight * G1_l_0)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S439 : vec3<f32> = ((-(in_dir_1)));
    var _S440 : f32 = dot(n_5, _S439);
    var _S441 : f32 = (sign((_S440)));
    var _S442 : vec3<f32> = n_5 * vec3<f32>(_S441);
    var _S443 : f32 = material_4.roughness;
    var _S444 : f32 = _S443 * _S443;
    var _S445 : AnisotropicFrame = anisotropicFrame(material_4, _S442);
    var _S446 : vec3<f32> = (normalize((_S439 + out_dir_0)));
    var _S447 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S447)
    {
        var _S448 : vec3<f32> = sampleHalfVector(_S439, _S442, _S444, _S445, &(random_state_2));
        ggx_n_1 = _S448;
    }
    else
    {
        var _S449 : bool = lobe_3 == u32(1);
        if(_S449)
        {
            var _S450 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S439 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S451 : vec3<f32> = (normalize((_S450)));
            var _S452 : f32 = (sign((dot(_S450, _S442))));
            var _S453 : vec3<f32> = _S451 * vec3<f32>(_S452);
            ggx_n_1 = _S453;
        }
        else
        {
            ggx_n_1 = _S446;
        }
    }
    var _S454 : BSDFLobes = bsdfLobes(in_dir_1, _S439, _S442, ggx_n_1, material_4, eta_i_3, eta_o_3, _S445);
    var lobes_2 : BSDFLobes = _S454;
    var _S455 : f32 = translucentShare(material_4);
    lobes_2.translucent_share = _S455;
    var _S456 : f32 = lobeDensity(dot(_S442, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S440), _S444, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S457 : bool = !(_S456 > 0.0f);
    if(_S457)
    {
        var _S458 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S458, _S458, u32(0), false, u32(0), 0.0f);
    }
    var _S459 : vec3<f32> = lobeThroughput(out_dir_0, _S442, _S444, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S459, random_state_2, lobe_3 == u32(1), lobe_3, _S456);
}

fn neeBSDF( in_dir_2 : vec3<f32>,  dir_4 : vec3<f32>,  n_6 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_3 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var _S460 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_1 : vec3<f32> = _S460;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S461 : bool = lobe_4 == u32(0);
        if(_S461)
        {
        }
        var _S462 : bool;
        if(_S461)
        {
            var _S463 : f32 = rgb_to_greyscale(material_5.translucent);
            _S462 = _S463 > 0.0f;
        }
        else
        {
            _S462 = false;
        }
        var _S464 : bool;
        if(_S462)
        {
            var _S465 : f32 = dot(n_6, dir_4);
            var _S466 : vec3<f32> = ((-(in_dir_2)));
            _S464 = ((_S465 * dot(n_6, _S466)) < 0.0f) == refracted_3;
        }
        else
        {
            _S464 = (lobe_4 == u32(1)) == refracted_3;
        }
        var f_2 : vec3<f32>;
        if(_S464)
        {
            var _S467 : SampleBSDF = connectBSDF(in_dir_2, dir_4, n_6, material_5, eta_i_4, eta_o_4, lobe_4, random_state_3);
            var _S468 : bool = (_S467.pdf) > 0.0f;
            if(_S468)
            {
                if(power_0)
                {
                    var _S469 : f32 = _S467.pdf / pdf_1;
                    var f_3 : vec3<f32> = f_1 + _S467.throughput * vec3<f32>(_S467.pdf) / vec3<f32>((pdf_1 * (1.0f + _S469 * _S469)));
                    f_2 = f_3;
                }
                else
                {
                    var f_4 : vec3<f32> = f_1 + _S467.throughput * vec3<f32>(_S467.pdf) / vec3<f32>((_S467.pdf + pdf_1));
                    f_2 = f_4;
                }
            }
            else
            {
                f_2 = f_1;
            }
        }
        else
        {
            f_2 = f_1;
        }
        var lobe_5 : u32 = lobe_4 + u32(1);
        lobe_4 = lobe_5;
        f_1 = f_2;
    }
    return f_1;
}

fn skyBSDF( in_dir_3 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_2 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S470 : bool = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    var _S471 : vec3<f32> = neeBSDF(in_dir_3, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S470, pdf_2, false, random_state_4);
    return _S471;
}

fn SkySample_x24init_0( dir_6 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S472 : SkySample;
    _S472.dir = dir_6;
    _S472.radiance = radiance_1;
    _S472.color = color_0;
    _S472.random_state = random_state_5;
    return _S472;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S473 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S474 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S475 : vec2<u32> = _S473 - _S474;
    var _S476 : Random = pcg(init_random_state_0);
    var _S477 : Random = pcg(_S476.state);
    var _S478 : Random = pcg(_S477.state);
    var _S479 : Random = pcg(_S478.state);
    var _S480 : u32 = _S475.x;
    var _S481 : u32 = searchCDF_0(vec2<u32>(_S480, u32(0)), vec2<u32>(u32(0), u32(1)), _S475.y, _S476.value);
    var _S482 : u32 = searchCDF_0(vec2<u32>(u32(0), _S481), _S474, _S480, _S477.value);
    var _S483 : vec2<f32> = (vec2<f32>(f32(_S482), f32(_S481)) + vec2<f32>(_S478.value, _S479.value)) / vec2<f32>(_S475) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S484 : f32 = _S483.y;
    var _S485 : f32 = sin(_S484);
    var _S486 : f32 = _S483.x;
    var _S487 : vec3<f32> = vec3<f32>(_S485 * cos(_S486), cos(_S484), _S485 * sin(_S486));
    var _S488 : f32 = environmentPdf_0(_S487);
    var _S489 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S487, surface_2, eta_1, is_inside_3, _S488, lobe_state_0);
    var _S490 : bool = !(_S488 > 0.0f);
    var _S491 : bool;
    if(_S490)
    {
        _S491 = true;
    }
    else
    {
        _S491 = (all((_S489 == vec3<f32>(0.0f))));
    }
    if(_S491)
    {
        var _S492 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S487, _S492, _S492, _S479.state);
    }
    var _S493 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S487);
    return SkySample_x24init_0(_S487, _S493, _S489 * _S493, _S479.state);
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_7 : vec3<f32>,  radiance_2 : vec3<f32>,  density_0 : f32,  random_state_6 : u32) -> TreeSample
{
    var _S494 : TreeSample;
    _S494.dir = dir_7;
    _S494.radiance = radiance_2;
    _S494.density = density_0;
    _S494.random_state = random_state_6;
    return _S494;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S495 : f32 = importance(first_1, p_10, normal_3);
    var _S496 : f32 = importance(second_1, p_10, normal_3);
    var _S497 : vec2<f32> = vec2<f32>(_S495, _S496);
    var _S498 : bool = _S495 == 0.0f;
    var _S499 : bool;
    if(_S498)
    {
        _S499 = _S496 == 0.0f;
    }
    else
    {
        _S499 = false;
    }
    if(_S499)
    {
        return u32(2);
    }
    var _S500 : f32 = _S495 + _S496;
    var _S501 : bool = _S496 > 0.0f;
    if(_S501)
    {
        _S499 = ((*pick_0) * _S500) >= _S495;
    }
    else
    {
        _S499 = false;
    }
    var _S502 : u32 = select(u32(0), u32(1), _S499);
    var _S503 : f32 = min(((*pick_0) * _S500 - f32(_S502) * _S495) / _S497[_S502], 0.99999994039535522f);
    (*pick_0) = _S503;
    var _S504 : f32 = (*probability_3) * (_S497[_S502] / _S500);
    (*probability_3) = _S504;
    return _S502;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S505 : vec3<f32> = center_1 - p_11;
    var _S506 : f32 = radius_1 * radius_1 / dot(_S505, _S505);
    var _S507 : f32 = u1_0 * _S506 / (1.0f + sqrt(max(1.0f - _S506, 0.0f)));
    var _S508 : f32 = 2.0f * u1_0;
    var _S509 : bool = _S506 >= 1.0f;
    var _S510 : f32 = select(_S507, _S508, _S509);
    var _S511 : f32 = sqrt(max(_S510 * (2.0f - _S510), 0.0f));
    var _S512 : f32 = 6.28318548202514648f * u2_0;
    var _S513 : vec3<f32> = vec3<f32>(_S511 * cos(_S512), 1.0f - _S510, _S511 * sin(_S512));
    var _S514 : vec3<f32> = (normalize((_S505)));
    var _S515 : vec3<f32> = tangentToWorld(_S513, _S514);
    return _S515;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S516 : vec3<f32> = center_2 - ray_1.origin;
    var _S517 : f32 = dot(_S516, ray_1.unit_direction);
    var _S518 : f32 = dot(_S516, _S516) - _S517 * _S517;
    var _S519 : f32 = radius_3 * radius_3;
    var _S520 : bool = _S518 > _S519;
    if(_S520)
    {
        return 4.294967296e+09f;
    }
    var _S521 : f32 = sqrt(_S519 - _S518);
    var _S522 : f32 = _S517 - _S521;
    var _S523 : f32 = _S517 + _S521;
    var _S524 : bool = _S522 > 0.0000152587890625f;
    var _S525 : bool;
    if(_S524)
    {
        _S525 = _S522 < max_len_0;
    }
    else
    {
        _S525 = false;
    }
    if(_S525)
    {
        return _S522;
    }
    var _S526 : bool = _S523 > 0.0000152587890625f;
    if(_S526)
    {
        _S525 = _S523 < max_len_0;
    }
    else
    {
        _S525 = false;
    }
    if(_S525)
    {
        return _S523;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S527 : Random = pcg(init_random_state_1);
    var _S528 : Random = pcg(_S527.state);
    var _S529 : Random = pcg(_S528.state);
    var _S530 : vec3<f32> = vec3<f32>(0.0f);
    var _S531 : TreeSample = TreeSample_x24init_0(_S530, _S530, 0.0f, _S529.state);
    var sample_0 : TreeSample = _S531;
    var _S532 : vec3<f32> = select(smooth_n_2, _S530, sided_0);
    var _S533 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S534 : vec3<f32> = origin_4 + _S533 * smooth_n_2;
    var pick_1 : f32 = _S527.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S535 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S535.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S536 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S537 : u32 = n_7 + u32(1);
        var _S538 : LightBounds = (lightBounds((_S537)));
        var _S539 : LightBounds = (lightBounds((_S536)));
        var _S540 : u32 = pickChild(_S538, _S539, origin_4, _S532, &(pick_1), &(probability_4));
        var _S541 : bool = _S540 > u32(1);
        if(_S541)
        {
            return sample_0;
        }
        var _S542 : bool = _S540 == u32(1);
        var _S543 : u32 = select(_S537, _S536, _S542);
        n_7 = _S543;
    }
    var _S544 : bool = n_7 == u32(0);
    var _S545 : bool;
    if(_S544)
    {
        var _S546 : LightBounds = (lightBounds((u32(0))));
        var _S547 : f32 = importance(_S546, origin_4, _S532);
        _S545 = !(_S547 > 0.0f);
    }
    else
    {
        _S545 = false;
    }
    if(_S545)
    {
        return sample_0;
    }
    var _S548 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S549 : bool = (_S548.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S549)
    {
        var _S550 : Light = (lights[(_S548.y)]);
        if(sided_0)
        {
            var _S551 : f32 = (sign((dot(geometry_n_1, _S550.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S551);
            var _S552 : vec3<f32> = origin_4 + _S533 * lift_n_1;
            start_5 = _S552;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S534;
            lift_n_0 = smooth_n_2;
        }
        var _S553 : bool = (_S550.variance) == 0.0f;
        if(_S553)
        {
            var _S554 : vec3<f32> = _S550.position - start_5;
            var _S555 : vec3<f32> = (normalize((_S554)));
            sample_0.dir = _S555;
            var _S556 : vec3<f32> = _S550.color * vec3<f32>(_S550.intensity) / vec3<f32>((dot(_S554, _S554) * probability_4));
            sample_0.radiance = _S556;
            shadow_1 = _S554;
        }
        else
        {
            var _S557 : vec3<f32> = sampleSphere(_S550.position, _S550.variance, start_5, _S528.value, _S529.value);
            sample_0.dir = _S557;
            var _S558 : f32 = sphereDensity(_S550.position, _S550.variance, start_5);
            var _S559 : f32 = probability_4 * _S558;
            sample_0.density = _S559;
            var _S560 : vec3<f32> = pointLightRadiance(_S550.color, _S550.intensity, _S550.variance);
            var _S561 : vec3<f32> = _S560 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S561;
            var _S562 : f32 = raySphere_0(_S550.position, _S550.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S563 : vec3<f32> = sample_0.dir * vec3<f32>(_S562);
            shadow_1 = _S563;
        }
    }
    else
    {
        var _S564 : u32 = _S548.y;
        var _S565 : u32 = ((instance_uint[(_S564) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S566 : u32 = _S565 + _S548.z;
        var _S567 : mat3x3<f32> = (worldTriangle((_S564), (_S566)));
        var _S568 : f32 = sqrt(_S528.value);
        var _S569 : vec2<f32> = vec2<f32>(_S568 * (1.0f - _S529.value), _S568 * _S529.value);
        var _S570 : vec3<f32> = (((_S567) * (vec3<f32>(1.0f - _S568, _S569))));
        if(sided_0)
        {
            var _S571 : f32 = (sign((dot(geometry_n_1, _S570 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S571);
            var _S572 : vec3<f32> = origin_4 + _S533 * lift_n_2;
            start_5 = _S572;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S573 : bool = !((dot(smooth_n_2, _S570 - origin_4)) > 0.0f);
            if(_S573)
            {
                return sample_0;
            }
            start_5 = _S534;
            lift_n_0 = smooth_n_2;
        }
        var _S574 : Surface = (surfaceAt((Hit_x24init_0(_S569, _S564, _S566, u32(0), 0.0f)), (_S570), (_S529.state)));
        sample_0.random_state = _S574.random_state;
        var _S575 : vec3<f32> = _S570 - start_5;
        var _S576 : vec3<f32> = (normalize((_S575)));
        sample_0.dir = _S576;
        var _S577 : f32 = solidAngle(probability_4, cross(_S567[i32(1)] - _S567[i32(0)], _S567[i32(2)] - _S567[i32(0)]), _S575);
        sample_0.density = _S577;
        var _S578 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S574.smooth_n))));
        var _S579 : vec3<f32> = _S574.material.emissive * vec3<f32>(max(_S578, 0.0f));
        var _S580 : vec3<f32> = select(_S579, _S530, _S574.skip);
        var _S581 : vec3<f32> = _S580 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S581;
        shadow_1 = _S575;
    }
    var _S582 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S583 : vec3<f32> = sample_0.radiance * _S582;
    var _S584 : bool = (all((_S582 == _S530)));
    var _S585 : vec3<f32> = select(_S583, _S530, _S584);
    sample_0.radiance = _S585;
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
    var _S586 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S587 : bool = b_1 > 0.0f;
    var _S588 : f32 = select(1.0f, _S586, _S587);
    return _S588;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S589 : u32 = (lightSlot((hit_1)));
    var _S590 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S589, light_point_1);
    var _S591 : f32 = powerHeuristic(vertex_0.pdf, _S590);
    return _S591;
}

fn environment_0( dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S592 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S593 : bool = (_S592.x) > u32(1);
    var _S594 : bool;
    if(_S593)
    {
        var _S595 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S594 = (_S595.y) > u32(1);
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        var _S596 : vec3<f32> = (env_map_sample((dir_8)));
        return _S596;
    }
    var _S597 : vec3<f32> = (uniforms_float.ambient);
    return _S597;
}

fn environmentMapped_0() -> bool
{
    var _S598 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S599 : bool = (_S598.x) > u32(1);
    var _S600 : bool;
    if(_S599)
    {
        var _S601 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S600 = (_S601.y) > u32(1);
    }
    else
    {
        _S600 = false;
    }
    return _S600;
}

fn escapeWeight_0( pdf_3 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S602 : bool = pdf_3 <= 0.0f;
    var _S603 : bool;
    if(_S602)
    {
        _S603 = true;
    }
    else
    {
        var _S604 : bool = environmentMapped_0();
        _S603 = !_S604;
    }
    if(_S603)
    {
        return 1.0f;
    }
    var _S605 : f32 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S605);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S606 : vec2<u32> = global_invocation_id_1.xy;
    var _S607 : vec2<i32> = vec2<i32>(_S606 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_0 : u32 = local_invocation_index_3;
    loop
    {
        if(i_0 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S608 : vec2<i32> = _S607 + vec2<i32>(i32(i_0 % u32(24)), i32(i_0 / u32(24)));
        var _S609 : bool = (all((_S608 >= vec2<i32>(i32(0)))));
        var _S610 : bool;
        if(_S609)
        {
            var _S611 : vec2<u32> = (uniforms_uint.render_size);
            _S610 = (all((_S608 < vec2<i32>(_S611))));
        }
        else
        {
            _S610 = false;
        }
        if(_S610)
        {
            var _S612 : vec4<u32> = (textureLoad(reservoir_prev, (_S608), (u32(0)), 0));
            var _S613 : u32 = _S612.x;
            var _S614 : bool = (bitcast<f32>((_S612.z))) > 0.0f;
            var _S615 : u32 = select(u32(0), _S613, _S614);
            seed_1 = _S615;
        }
        else
        {
            seed_1 = u32(0);
        }
        duplication_seeds_0[i_0] = seed_1;
        var i_1 : u32 = i_0 + u32(64);
        i_0 = i_1;
    }
    workgroupBarrier();
    var _S616 : u32 = local_invocation_id_0.y;
    var _S617 : u32 = local_invocation_id_0.x;
    var _S618 : u32 = duplication_seeds_0[(_S616 + u32(8)) * u32(24) + _S617 + u32(8)];
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
            var _S619 : bool = (duplication_seeds_0[(_S616 + seed_1) * u32(24) + _S617 + x_1]) == _S618;
            var _S620 : u32 = select(u32(0), u32(1), _S619);
            var count_2 : u32 = count_1 + _S620;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S621 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S622 : bool = _S618 != u32(0);
    var _S623 : f32 = select(0.0f, _S621, _S622);
    textureStore(duplication_out, (vec2<i32>(_S606)), 0, (vec4<u32>((bitcast<u32>((_S623))), u32(0), u32(0), u32(0))));
    return;
}

struct Selection
{
     r : Reservoir,
     w_sum : f32,
     color : vec3<f32>,
     random_state : u32,
};

fn Selection_x24init_0( r_4 : Reservoir,  w_sum_0 : f32,  color_2 : vec3<f32>,  random_state_7 : u32) -> Selection
{
    var _S624 : Selection;
    _S624.r = r_4;
    _S624.w_sum = w_sum_0;
    _S624.color = color_2;
    _S624.random_state = random_state_7;
    return _S624;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S625 : u32 = hash(index_0);
    var _S626 : u32 = hash((seed_2 ^ (_S625)));
    return _S626;
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
    var _S627 : Shift;
    _S627.f = f_5;
    _S627.jac = jac_1;
    return _S627;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S628 : f32 = rgb_to_greyscale(weight_0);
    var _S629 : bool = _S628 > 0.0f;
    var _S630 : bool;
    if(_S629)
    {
        _S630 = _S628 < 3.00000000549775576e+38f;
    }
    else
    {
        _S630 = false;
    }
    var _S631 : bool = !_S630;
    if(_S631)
    {
        return;
    }
    var _S632 : f32 = (*sel_0).w_sum + _S628;
    (*sel_0).w_sum = _S632;
    var _S633 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S633;
    var _S634 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S634.state;
    var _S635 : bool = (_S634.value * (*sel_0).w_sum) <= _S628;
    if(_S635)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_5 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_5;
    var _S636 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S636;
    var _S637 : f32 = r_5.jac * shifted_0.jac;
    candidate_1.jac = _S637;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_5.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_6 : Reservoir = sel_2.r;
    var _S638 : f32 = rgb_to_greyscale(r_6.f);
    var _S639 : f32 = sel_2.w_sum / _S638;
    var _S640 : bool = _S638 > 0.0f;
    var _S641 : f32 = select(0.0f, _S639, _S640);
    r_6.w = _S641;
    r_6.c = c_2;
    return r_6;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S642 : vec2<u32> = global_invocation_id_2.xy;
    var _S643 : vec2<i32> = vec2<i32>(_S642);
    var _S644 : vec3<f32> = vec3<f32>(0.0f);
    var _S645 : Domain = Domain_x24init_0(_S644, _S644, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S645;
    var _S646 : bool = (currentDomain((_S643), &(dom_3)));
    var _S647 : bool = !_S646;
    if(_S647)
    {
        storeReservoir(reservoir_prev_out, (_S643), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S644, 0.0f, vec4<u32>(u32(0)), _S644, _S644)), (dom_3.hit));
        var _S648 : vec2<f32> = vec2<f32>(_S642);
        var _S649 : vec2<u32> = (uniforms_uint.render_size);
        var _S650 : vec2<f32> = _S648 / vec2<f32>(_S649.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S651 : vec3<f32> = vec3<f32>(_S650, 1.0f);
        var _S652 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S653 : vec3<f32> = (normalize(((((_S652) * (_S651))))));
        var _S654 : vec3<f32> = environment_0(_S653);
        textureStore(compute_out, (_S643), (u32(0)), (vec4<f32>(_S654, 1.0f)));
        var _S655 : u32 = (uniforms_uint.is_temporal);
        var _S656 : bool = _S655 == u32(1);
        if(_S656)
        {
            textureStore(compute_out, (_S643), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S657 : Reservoir = (loadReservoir(reservoir_temp, (_S643)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S657.c;
    loop
    {
        var _S658 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S658)
        {
        }
        else
        {
            break;
        }
        var _S659 : vec2<i32> = partner_0(_S643, t_13);
        var neighbor_0 : Domain = _S645;
        var _S660 : bool = (currentDomain((_S659), &(neighbor_0)));
        if(_S660)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S661 : vec4<u32> = (textureLoad(reservoir_temp, (_S659), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S661.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S662 : f32 = _S657.c / max(count_3, 1.0f);
    var _S663 : f32 = rgb_to_greyscale(_S657.f);
    var _S664 : bool = count_3 == 0.0f;
    var _S665 : f32 = select(0.0f, 1.0f, _S664);
    var _S666 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S644, 0.0f, vec4<u32>(u32(0)), _S644, _S644), 0.0f, _S644, u32(0));
    var sel_3 : Selection = _S666;
    var _S667 : u32 = (uniforms_uint.frame);
    var _S668 : u32 = hash(_S667);
    var _S669 : u32 = global_invocation_id_2.x;
    var _S670 : vec2<u32> = (uniforms_uint.render_size);
    var _S671 : u32 = stream(_S668, _S669 + _S670.x * global_invocation_id_2.y);
    var _S672 : u32 = stream(_S671, u32(195));
    sel_3.random_state = _S672;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S665;
    loop
    {
        var _S673 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S673)
        {
        }
        else
        {
            break;
        }
        var _S674 : vec2<i32> = partner_0(_S643, t_13);
        var neighbor_dom_0 : Domain = _S645;
        var _S675 : bool = (currentDomain((_S674), &(neighbor_dom_0)));
        if(_S675)
        {
            var _S676 : Reservoir = (loadReservoir(reservoir_temp, (_S674)));
            var _S677 : vec4<u32> = (textureLoad(shift_data, (_S674), (t_13), 0));
            var _S678 : vec4<f32> = (bitcast<vec4<f32>>((_S677)));
            var _S679 : vec4<u32> = (textureLoad(shift_data, (_S643), (t_13), 0));
            var _S680 : vec4<f32> = (bitcast<vec4<f32>>((_S679)));
            var _S681 : f32 = pairShare(_S676.c, _S662, c_sum_1);
            var _S682 : bool = _S663 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S682)
            {
                var _S683 : f32 = rgb_to_greyscale(_S680.xyz);
                var _S684 : f32 = canonicalWeight(_S681, _S662, _S663, _S676.c, _S683);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S684;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S685 : vec3<f32> = _S678.xyz;
            var _S686 : Shift = Shift_x24init_0(_S685, _S678.w);
            var _S687 : f32 = rgb_to_greyscale(_S676.f);
            var _S688 : f32 = rgb_to_greyscale(_S685);
            var _S689 : f32 = neighborWeight(_S681, _S676.c, _S687, _S662, _S688);
            offerShifted(&(sel_3), _S676, _S686, _S689);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S657, Shift_x24init_0(_S657.f, 1.0f), canonical_mis_0);
    var _S690 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S643), (_S690), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S643), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S691 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S692 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S693 : f32 = (sign((dot(_S692, _S691.smooth_n))));
    var _S694 : vec3<f32> = _S691.material.emissive * vec3<f32>(max(_S693, 0.0f));
    var _S695 : vec3<f32> = select(_S694, _S644, _S691.skip);
    var _S696 : vec3<f32> = clamp(sel_3.color + _S695, _S644, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S643), (u32(0)), (vec4<f32>(_S696, 1.0f)));
    var _S697 : u32 = (uniforms_uint.is_temporal);
    var _S698 : bool = _S697 == u32(1);
    if(_S698)
    {
        textureStore(compute_out, (_S643), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_4 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S699 : NEEVertex;
    _S699.none = none_0;
    _S699.pdf = pdf_4;
    _S699.origin = origin_5;
    _S699.smooth_n = smooth_n_3;
    _S699.start = start_6;
    return _S699;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_6 : u32,  pdf_5 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S700 : Vertex;
    _S700.rough = rough_0;
    _S700.lobe = lobe_6;
    _S700.pdf = pdf_5;
    _S700.cos = cos_0;
    _S700.inside = inside_0;
    return _S700;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>) -> Material
{
    var _S701 : Material;
    _S701.albedo = albedo_0;
    _S701.emissive = emissive_0;
    _S701.roughness = roughness_0;
    _S701.metallic = metallic_0;
    _S701.transmission = transmission_0;
    _S701.ior = ior_0;
    _S701.absorption = absorption_0;
    _S701.specular_tint = specular_tint_0;
    _S701.specular_level = specular_level_0;
    _S701.translucent = translucent_0;
    _S701.sheen = sheen_2;
    _S701.sheen_roughness = sheen_roughness_0;
    _S701.anisotropy = anisotropy_0;
    _S701.anisotropic_rotation = anisotropic_rotation_0;
    _S701.tangent = tangent_2;
    return _S701;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_6 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S702 : Surface;
    _S702.smooth_n = smooth_n_4;
    _S702.geometry_n = geometry_n_2;
    _S702.geometry_offset = geometry_offset_2;
    _S702.material = material_6;
    _S702.skip = skip_0;
    _S702.random_state = random_state_8;
    return _S702;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S703 : bool = transmission_1 > 0.0f;
    var _S704 : bool;
    if(_S703)
    {
        _S704 = true;
    }
    else
    {
        _S704 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S705 : f32;
    if(_S704)
    {
        _S705 = 1.0f;
    }
    else
    {
        _S705 = -1.0f;
    }
    return _S705;
}

fn facingRay_0( surface_3 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S706 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_10);
    var _S707 : vec3<f32> = vec3<f32>(_S706);
    return Surface_x24init_0(surface_3.smooth_n * _S707, surface_3.geometry_n * _S707, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S708 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S708));
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
    var _S709 : bool;
    if(open_0)
    {
        _S709 = prev_rough_0;
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        _S709 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S709 = false;
    }
    return _S709;
}

fn vertexEta_0( material_7 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S710 : bool = n_dot_v_0 < 0.0f;
    var _S711 : f32 = select(1.0f, material_7.ior, _S710);
    var _S712 : f32 = select(material_7.ior, 1.0f, _S710);
    return vec2<f32>(_S711, _S712);
}

fn samplesLights( material_8 : Material) -> bool
{
    var _S713 : bool = (material_8.roughness) > 0.0f;
    var _S714 : bool;
    if(_S713)
    {
        _S714 = true;
    }
    else
    {
        var _S715 : bool = (material_8.metallic) < 1.0f;
        if(_S715)
        {
            _S714 = (material_8.transmission) < 1.0f;
        }
        else
        {
            _S714 = false;
        }
    }
    return _S714;
}

fn isTranslucent_0( material_9 : Material) -> bool
{
    var _S716 : f32 = rgb_to_greyscale(material_9.translucent);
    return _S716 > 0.0f;
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_8 : vec3<f32>,  g_n_0 : vec3<f32>,  material_10 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S717 : vec3<f32> = ((-(in_dir_4)));
    var _S718 : bool = (dot(g_n_0, _S717) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S718)
    {
        var _S719 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(0), random_state_9);
        var _S720 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(2), random_state_9);
        return _S719.throughput * vec3<f32>(_S719.pdf) + _S720.throughput * vec3<f32>(_S720.pdf);
    }
    var _S721 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(1), random_state_9);
    return _S721.throughput * vec3<f32>(_S721.pdf);
}

fn translucentCorrection( in_dir_5 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_1 : vec3<f32>,  material_11 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S722 : f32 = dot(n_9, out_dir_2);
    var _S723 : vec3<f32> = ((-(in_dir_5)));
    var _S724 : bool = (_S722 * dot(n_9, _S723)) < 0.0f;
    var _S725 : SampleBSDF = connectBSDF(in_dir_5, out_dir_2, n_9, material_11, eta_i_6, eta_o_6, u32(0), random_state_10);
    var _S726 : vec3<f32> = ((-(in_dir_5)));
    var _S727 : bool = (dot(g_n_1, _S726) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S728 : vec3<f32> = vec3<f32>(0.0f);
    var _S729 : vec3<f32> = _S725.throughput * vec3<f32>(_S725.pdf);
    var _S730 : f32 = select(1.0f, -1.0f, _S727);
    var _S731 : vec3<f32> = _S729 * vec3<f32>(_S730);
    var _S732 : vec3<f32> = select(_S728, _S731, _S724);
    return _S732;
}

fn translucentBSDF( in_dir_6 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_2 : vec3<f32>,  material_12 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S733 : vec3<f32> = BSDF(in_dir_6, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    var _S734 : vec3<f32> = translucentCorrection(in_dir_6, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    return _S733 + _S734;
}

fn lightBSDF_0( in_dir_7 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S735 : bool = !competing_0;
    var _S736 : bool;
    if(_S735)
    {
        _S736 = true;
    }
    else
    {
        _S736 = (light_0.density) == 0.0f;
    }
    if(_S736)
    {
        var _S737 : bool = isTranslucent_0(material_13);
        if(_S737)
        {
            var _S738 : vec3<f32> = translucentBSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
            return _S738 * light_0.radiance;
        }
        var _S739 : vec3<f32> = BSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
        return _S739 * light_0.radiance;
    }
    var _S740 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_7)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S741 : vec3<f32> = neeBSDF(in_dir_7, light_0.dir, smooth_n_5, material_13, eta_i_8, eta_o_8, _S740, light_0.density, true, random_state_12);
    return _S741 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S742 : vec3<f32> = a_6 / b_2;
    var _S743 : vec3<f32> = vec3<f32>(0.0f);
    var _S744 : vec3<bool> = b_2 == _S743;
    var _S745 : vec3<f32> = select(_S742, _S743, _S744);
    return _S745;
}

fn withEnd( r_7 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_7;
    var _S746 : u32 = (insertBits((r_7.path), (end_0), (u32(0)), (u32(5))));
    var _S747 : u32 = (insertBits((_S746), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S747;
    candidate_2.f = f_6;
    return candidate_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S748 : f32 = sqrt(random_1_0);
    var _S749 : f32 = 6.28318548202514648f * random_2_0;
    var _S750 : f32 = _S748 * cos(_S749);
    var _S751 : f32 = _S748 * sin(_S749);
    var _S752 : f32 = sqrt(max(0.0f, 1.0f - _S750 * _S750 - _S751 * _S751));
    return vec3<f32>(_S750, _S752, _S751);
}

fn sampleBSDF( in_dir_8 : vec3<f32>,  n_11 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_1;
    var _S753 : vec3<f32> = ((-(in_dir_8)));
    var _S754 : f32 = dot(n_11, _S753);
    var _S755 : f32 = (sign((_S754)));
    var n_i_4 : vec3<f32> = n_11 * vec3<f32>(_S755);
    var _S756 : f32 = abs(_S754);
    var _S757 : f32 = material_14.roughness;
    var _S758 : f32 = _S757 * _S757;
    var _S759 : AnisotropicFrame = anisotropicFrame(material_14, n_i_4);
    var _S760 : vec3<f32> = sampleHalfVector(_S753, n_i_4, _S758, _S759, &(random_state_13));
    var _S761 : BSDFLobes = bsdfLobes(in_dir_8, _S753, n_i_4, _S760, material_14, eta_i_9, eta_o_9, _S759);
    var lobes_3 : BSDFLobes = _S761;
    var _S762 : f32 = translucentShare(material_14);
    lobes_3.translucent_share = _S762;
    var _S763 : vec3<f32> = vec3<f32>(1.0f);
    var _S764 : SampleBSDF = SampleBSDF_x24init_0(_S763, _S763, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S764;
    var _S765 : Random = pcg(random_state_13);
    random_state_13 = _S765.state;
    var _S766 : bool = (_S765.value) < (lobes_3.p_diffuse);
    if(_S766)
    {
        var _S767 : Random = pcg(random_state_13);
        var _S768 : Random = pcg(_S767.state);
        sample_1.random_state = _S768.state;
        var _S769 : vec3<f32> = sampleCosWeightedHemisphere(_S767.value, _S768.value);
        var _S770 : bool = (_S765.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S771 : f32 = _S769.y;
        var _S772 : f32 = - _S771;
        var _S773 : f32 = select(_S771, _S772, _S770);
        var _S774 : vec3<f32> = tangentToWorld(vec3<f32>(_S769.x, _S773, _S769.z), n_i_4);
        sample_1.unit_direction = _S774;
        var _S775 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S758, material_14, lobes_3, u32(0));
        sample_1.throughput = _S775;
        var _S776 : f32 = lobeDensity(_S773, 0.0f, _S756, _S758, lobes_3, eta_i_9, eta_o_9, u32(0));
        sample_1.pdf = _S776;
        sample_1.refracted = _S770;
        return sample_1;
    }
    var _S777 : bool = (_S765.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S777)
    {
        sample_1.unit_direction = lobes_3.refracted;
        var _S778 : f32 = lobeDensity(0.0f, dot(sample_1.unit_direction, _S760), _S756, _S758, lobes_3, eta_i_9, eta_o_9, u32(1));
        sample_1.pdf = _S778;
        var _S779 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S758, material_14, lobes_3, u32(1));
        sample_1.throughput = _S779;
        sample_1.random_state = random_state_13;
        sample_1.refracted = true;
        sample_1.lobe = u32(1);
        return sample_1;
    }
    var _S780 : vec3<f32> = (normalize((reflect(in_dir_8, _S760))));
    sample_1.unit_direction = _S780;
    var _S781 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S758, material_14, lobes_3, u32(2));
    sample_1.throughput = _S781;
    sample_1.random_state = random_state_13;
    sample_1.lobe = u32(2);
    var _S782 : f32 = lobeDensity(0.0f, 0.0f, _S756, _S758, lobes_3, eta_i_9, eta_o_9, u32(2));
    sample_1.pdf = _S782;
    return sample_1;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S783 : bool = pdf_6 > 0.0f;
    var _S784 : bool;
    if(_S783)
    {
        if(diffuse_0)
        {
            _S784 = true;
        }
        else
        {
            _S784 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S784 = false;
    }
    return _S784;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S785 : bool = pdf_7 > 0.0f;
    var _S786 : bool;
    if(_S785)
    {
        if(diffuse_1)
        {
            _S786 = true;
        }
        else
        {
            _S786 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S786 = false;
    }
    return _S786;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S787 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S787.x, max(_S787.y, _S787.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_8 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S788 : vec3<f32> = vec3<f32>(0.0f);
    var _S789 : Shift = Shift_x24init_0(_S788, 0.0f);
    var _S790 : u32 = (extractBits((r_8.path), (u32(0)), (u32(5))));
    var _S791 : u32 = (extractBits((r_8.path), (u32(5)), (u32(5))));
    var _S792 : u32 = (extractBits((r_8.path), (u32(10)), (u32(2))));
    var _S793 : u32 = (extractBits((r_8.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S794 : bool = _S793 >= u32(3);
        var _S795 : u32 = select(u32(0), u32(1), _S794);
        var _S796 : u32 = _S790 + _S795;
        var _S797 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S796 > _S797;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S789;
    }
    var _S798 : u32 = _S791 - u32(1);
    var _S799 : bool = _S793 == u32(3);
    var _S800 : u32 = select(u32(0), u32(1), _S799);
    var _S801 : u32 = _S790 + _S800;
    var _S802 : bool = _S792 == u32(0);
    var _S803 : u32 = select(_S798, _S801, _S802);
    var _S804 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_8.rc.zw))), r_8.rc.x, r_8.rc.y, u32(0), 0.0f);
    var _S805 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S806 : Ray = Ray_x24init_0(dom_4.x1, _S805);
    var ray_2 : Ray = _S806;
    var hit_2 : Hit = dom_4.hit;
    var _S807 : vec3<f32> = vec3<f32>(1.0f);
    var _S808 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S788, _S788, _S788);
    var nee_vertex_0 : NEEVertex = _S808;
    var _S809 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S809;
    var _S810 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S788, 0.0f, vec4<u32>(u32(0)), _S788, _S788);
    var chain_0 : Reservoir = _S810;
    chain_0.seed = r_8.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S788;
    var reconnection_0 : vec3<f32> = _S788;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S807;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S811 : bool = (hit_2.is_point_light) == u32(1);
        var _S812 : Surface = Surface_x24init_0(_S788, _S788, 0.0f, Material_x24init_0(_S788, _S788, 0.0f, 0.0f, 0.0f, 0.0f, _S788, _S807, 1.0f, _S788, _S788, 0.5f, 0.0f, 0.0f, _S788), false, u32(0));
        var _S813 : bool = !_S811;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_4 : Surface;
        if(_S813)
        {
            var _S814 : u32 = stream(r_8.seed, b_3);
            var _S815 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S814)));
            var surface_5 : Surface = facingRay_0(_S815, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S816 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S817 : vec3<f32> = throughput_2 * _S816;
                front_n_0 = _S817;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S818 : bool = !surface_5.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_5.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S819 : bool = b_3 == u32(0);
            if(_S819)
            {
                var _S820 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S820;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S821 : vec3<f32> = front_n_0;
            var _S822 : f32 = geometry_density_2;
            scatter_0 = _S818;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S822;
            surface_4 = surface_5;
            front_n_0 = _S815.smooth_n;
            throughput_3 = _S821;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_4 = _S812;
            front_n_0 = _S788;
            throughput_3 = throughput_2;
        }
        var _S823 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S824 : Surface = surface_4;
        var _S825 : Surface = surface_4;
        var _S826 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S827 : vec2<f32> = vertexEta_0(_S824.material, _S826);
        var _S828 : bool;
        if(scatter_0)
        {
            var _S829 : bool = samplesLights(_S824.material);
            _S828 = _S829;
        }
        else
        {
            _S828 = false;
        }
        var _S830 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S831 : vec3<f32> = _S824.material.emissive * vec3<f32>(max(_S830, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S811)
        {
            var _S832 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S832;
        }
        else
        {
            emission_0 = _S831;
        }
        var _S833 : f32 = rgb_to_greyscale(emission_0);
        var _S834 : bool = _S833 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S834)
        {
            var _S835 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S835);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S836 : bool;
        if(replay_0)
        {
            _S836 = _S792 == u32(1);
        }
        else
        {
            _S836 = false;
        }
        var _S837 : bool;
        if(_S836)
        {
            _S837 = b_3 > _S791;
        }
        else
        {
            _S837 = false;
        }
        var _S838 : bool;
        if(_S837)
        {
            _S838 = b_3 == _S790;
        }
        else
        {
            _S838 = false;
        }
        var _S839 : bool;
        if(_S838)
        {
            var _S840 : bool = _S793 == u32(1);
            if(_S840)
            {
                _S839 = true;
            }
            else
            {
                _S839 = _S793 == u32(2);
            }
        }
        else
        {
            _S839 = false;
        }
        if(_S839)
        {
            var _S841 : bool = _S811 != (_S793 == u32(2));
            if(_S841)
            {
                return _S789;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_8.jac), density_2 / r_8.jac);
        }
        var _S842 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S843 : bool = _S842 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S844 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S845 : u32 = (insertBits((_S844), (u32(1)), (u32(10)), (u32(2))));
        var _S846 : u32 = (insertBits((_S845), (prev_0.lobe), (u32(15)), (u32(2))));
        var _S847 : bool = prev_0.inside;
        var _S848 : u32 = select(u32(0), u32(1), _S847);
        var _S849 : u32 = (insertBits((_S846), (_S848), (u32(20)), (u32(1))));
        here_0.path = _S849;
        var _S850 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S850;
        var _S851 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S851;
        var _S852 : bool;
        if(replay_0)
        {
            _S852 = _S792 == u32(1);
        }
        else
        {
            _S852 = false;
        }
        var _S853 : bool;
        if(_S852)
        {
            _S853 = b_3 == _S791;
        }
        else
        {
            _S853 = false;
        }
        var _S854 : bool = b_3 == _S803;
        var _S855 : bool;
        if(_S854)
        {
            var _S856 : bool = !scatter_0;
            if(_S856)
            {
                _S855 = true;
            }
            else
            {
                var _S857 : bool = _S792 != u32(1);
                if(_S857)
                {
                    _S855 = _S792 != u32(3);
                }
                else
                {
                    _S855 = false;
                }
            }
        }
        else
        {
            _S855 = false;
        }
        var _S858 : bool;
        if(_S855)
        {
            _S858 = _S792 == u32(2);
        }
        else
        {
            _S858 = false;
        }
        var _S859 : bool;
        if(_S858)
        {
            _S859 = !_S823;
        }
        else
        {
            _S859 = false;
        }
        var _S860 : bool;
        if(_S859)
        {
            _S860 = _S793 != u32(4);
        }
        else
        {
            _S860 = false;
        }
        var _S861 : bool = _S791 == _S790;
        var _S862 : bool;
        if(_S861)
        {
            _S862 = _S793 == u32(0);
        }
        else
        {
            _S862 = false;
        }
        var _S863 : bool;
        if(_S862)
        {
            _S863 = (hit_2.instance_index) == (_S804.instance_index);
        }
        else
        {
            _S863 = false;
        }
        var _S864 : bool;
        if(_S863)
        {
            _S864 = (hit_2.triangle_index) == (_S804.triangle_index);
        }
        else
        {
            _S864 = false;
        }
        var _S865 : bool;
        if(_S864)
        {
            _S865 = _S823;
        }
        else
        {
            _S865 = false;
        }
        var _S866 : bool = select(_S860, _S865, _S853);
        var _S867 : bool;
        if(_S828)
        {
            _S867 = select(scatter_0, _S866, replay_0);
        }
        else
        {
            _S867 = false;
        }
        var _S868 : TreeSample = TreeSample_x24init_0(_S788, _S788, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S867)
        {
            var _S869 : Surface = surface_4;
            var _S870 : bool = isTranslucent_0(_S824.material);
            var _S871 : u32 = stream(r_8.seed, b_3 + u32(64));
            var _S872 : TreeSample = sampleLightTree_0(ray_2.origin, _S825.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S870, _S871);
            var _S873 : bool = (any(((_S872.radiance) != _S788)));
            if(_S873)
            {
                var _S874 : f32 = _S827.x;
                var _S875 : f32 = _S827.y;
                var _S876 : u32 = (uniforms_uint.max_bounces);
                var _S877 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S872, _S825.smooth_n, _S869.geometry_n, _S824.material, _S874, _S875, b_3 < _S876, surface_4.random_state);
                lit_0 = _S877;
            }
            else
            {
                lit_0 = _S788;
            }
            light_1 = _S872;
        }
        else
        {
            light_1 = _S868;
            lit_0 = _S788;
        }
        var _S878 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S879 : bool;
        var _S880 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S853)
        {
            var _S881 : bool = (hit_2.instance_index) != (_S804.instance_index);
            if(_S881)
            {
                _S878 = true;
            }
            else
            {
                _S878 = (hit_2.triangle_index) != (_S804.triangle_index);
            }
            if(_S878)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S823;
            }
            if(wrong_side_0)
            {
                return _S789;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S861)
            {
                refracted_4 = _S793 == u32(1);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S861)
            {
                _S879 = _S793 == u32(0);
            }
            else
            {
                _S879 = false;
            }
            if(_S879)
            {
                var _S882 : bool = !_S828;
                if(_S882)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S883 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S883 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S789;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S861)
            {
                _S880 = _S793 == u32(4);
            }
            else
            {
                _S880 = false;
            }
            if(_S880)
            {
                var _S884 : bool = !_S828;
                if(_S884)
                {
                    return _S789;
                }
                var _S885 : f32 = environmentPdf_0(r_8.dir);
                var _S886 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_8.dir, surface_4, _S827, is_inside_4, _S885, surface_4.random_state);
                return Shift_x24init_0(throughput_5 * _S886 * r_8.radiance / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            var _S887 : u32 = (extractBits((r_8.path), (u32(19)), (u32(1))));
            var _S888 : bool = _S828 != (_S887 == u32(1));
            if(_S888)
            {
                return _S789;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S878 = _S854;
            }
            else
            {
                _S878 = false;
            }
            if(_S878)
            {
                var _S889 : bool = !scatter_0;
                if(_S889)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S890 : bool = _S792 != u32(1);
                    if(_S890)
                    {
                        wrong_side_0 = _S792 != u32(3);
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
                var _S891 : bool = _S792 == u32(2);
                if(_S891)
                {
                    _S836 = _S828;
                }
                else
                {
                    _S836 = false;
                }
                if(_S836)
                {
                    _S836 = !_S823;
                }
                else
                {
                    _S836 = false;
                }
                if(_S836)
                {
                    _S836 = _S793 == u32(4);
                }
                else
                {
                    _S836 = false;
                }
                if(_S836)
                {
                    var _S892 : u32 = stream(r_8.seed, b_3 + u32(256));
                    var _S893 : SkySample = sampleSky_0(ray_2, surface_4, _S827, is_inside_4, _S892, surface_4.random_state);
                    return Shift_x24init_0(throughput_3 * _S893.color, 1.0f);
                }
                if(_S891)
                {
                    is_inside_4 = _S828;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S823;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S894 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S895 : bool = !(_S894 > 0.0f);
                    if(_S895)
                    {
                        return _S789;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S802)
                {
                    is_inside_4 = _S793 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S811;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S802)
                {
                    is_inside_4 = _S793 == u32(1);
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
                    is_inside_4 = !_S823;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S789;
            }
            else
            {
                var _S896 : bool = !replay_0;
                if(_S896)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S897 : bool = b_3 > u32(0);
                    if(_S897)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S843)
                        {
                            var _S898 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S898;
                        }
                        else
                        {
                            if(_S823)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S899 : vec3<f32> = throughput_3 * emission_1;
                        var _S900 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S899);
                        offer(&((*sel_4)), _S900, _S899 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S828)
                    {
                        var _S901 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S843)
                        {
                            var _S902 : vec3<f32> = safeDivide(_S901, chain_throughput_0);
                            candidate_4.radiance = _S902;
                        }
                        else
                        {
                            if(_S823)
                            {
                                candidate_4 = here_0;
                                var _S903 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_4.path = _S903;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S904 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S905 : u32 = (insertBits((_S904), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S905;
                            }
                        }
                        var _S906 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S901);
                        offer(&((*sel_4)), _S906, _S901 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S828)
                    {
                        var _S907 : bool = environmentMapped_0();
                        _S879 = _S907;
                    }
                    else
                    {
                        _S879 = false;
                    }
                    if(_S879)
                    {
                        var _S908 : u32 = (uniforms_uint.max_bounces);
                        _S880 = b_3 < _S908;
                    }
                    else
                    {
                        _S880 = false;
                    }
                    if(_S880)
                    {
                        var _S909 : u32 = stream(r_8.seed, b_3 + u32(256));
                        var _S910 : SkySample = sampleSky_0(ray_2, surface_4, _S827, is_inside_4, _S909, surface_4.random_state);
                        var _S911 : vec3<f32> = throughput_3 * _S910.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S843)
                        {
                            var _S912 : vec3<f32> = safeDivide(_S911, chain_throughput_0);
                            candidate_5.radiance = _S912;
                        }
                        else
                        {
                            if(_S823)
                            {
                                candidate_5 = here_0;
                                var _S913 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_5.path = _S913;
                                candidate_5.dir = _S910.dir;
                                candidate_5.radiance = _S910.radiance;
                            }
                            else
                            {
                                var _S914 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S915 : u32 = (insertBits((_S914), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S915;
                            }
                        }
                        var _S916 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S911);
                        offer(&((*sel_4)), _S916, _S911 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S917 : bool;
        var _S918 : bool;
        var _S919 : bool;
        var _S920 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S878 = _S854;
            }
            else
            {
                _S878 = false;
            }
            var _S921 : u32 = (extractBits((r_8.path), (u32(15)), (u32(2))));
            var _S922 : u32 = (extractBits((r_8.path), (u32(17)), (u32(2))));
            var _S923 : u32 = select(_S921, _S922, _S853);
            var refracted_5 : bool = _S923 == u32(1);
            var _S924 : SampleBSDF = SampleBSDF_x24init_0(_S788, _S788, u32(0), false, u32(0), 0.0f);
            var lobe_7 : SampleBSDF = _S924;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S878)
            {
                var _S925 : u32 = (extractBits((r_8.path), (u32(20)), (u32(1))));
                var _S926 : bool = is_inside_4 != (_S925 == u32(1));
                if(_S926)
                {
                    return _S789;
                }
                var _S927 : bool = _S792 == u32(1);
                if(_S927)
                {
                    var _S928 : vec3<f32> = (hitPosition((_S804)));
                    dir_11 = _S928;
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
                    var _S929 : bool = isTranslucent_0(_S824.material);
                    if(_S929)
                    {
                        wrong_side_0 = _S923 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S930 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S931 : vec3<f32> = select(r_8.dir, _S930, _S927);
                        refracted_4 = (dot(_S825.smooth_n, _S931) * _S826) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S927)
                {
                    var _S932 : vec3<f32> = ray_2.origin;
                    var _S933 : Surface = surface_4;
                    var _S934 : vec3<f32> = (vec3<f32>(0) - _S825.smooth_n);
                    var _S935 : bool = is_inside_4 != refracted_4;
                    var _S936 : vec3<f32> = select(_S825.smooth_n, _S934, _S935);
                    var _S937 : vec3<f32> = (normalize((dir_11 - (_S932 + vec3<f32>(_S933.geometry_offset) * _S936))));
                    reconnection_1 = _S937;
                }
                else
                {
                    reconnection_1 = r_8.dir;
                }
                var _S938 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, surface_4.geometry_n);
                if(_S938)
                {
                    return _S789;
                }
                var _S939 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S923;
                wrong_side_0 = false;
                reconnection_1 = _S939;
            }
            else
            {
                var _S940 : bool = !_S853;
                if(_S940)
                {
                    var _S941 : f32 = _S827.x;
                    var _S942 : f32 = _S827.y;
                    var _S943 : vec2<f32> = vec2<f32>(0.0f);
                    var _S944 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S825.smooth_n, _S824.material, _S941, _S942, surface_4.random_state, _S943);
                    var bsdf_sampled_0 : SampleBSDF = _S944;
                    var _S945 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S824.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S946 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S945.geometry_n, _S824.material, _S941, _S942, bsdf_sampled_0.random_state, _S943);
                        bsdf_sampled_0.unit_direction = _S946.unit_direction;
                        bsdf_sampled_0.refracted = _S946.refracted;
                        bsdf_sampled_0.throughput = _S946.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S947 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S945.geometry_n))) * _S945.geometry_n;
                            bsdf_sampled_0.unit_direction = _S947;
                        }
                    }
                    var _S948 : u32 = bsdf_sampled_0.lobe;
                    var _S949 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S950 : bool = bsdf_sampled_0.refracted;
                    lobe_7 = bsdf_sampled_0;
                    var _S951 : f32 = bsdf_sampled_0.pdf;
                    var _S952 : f32 = select(_S951, 0.0f, wrong_side_1);
                    lobe_7.pdf = _S952;
                    dir_11 = _S949;
                    lobe_index_0 = _S948;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S950;
                }
                else
                {
                    dir_11 = r_8.dir;
                    lobe_index_0 = _S923;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S878)
            {
                _S879 = true;
            }
            else
            {
                _S879 = _S853;
            }
            if(_S879)
            {
                var _S953 : SampleBSDF = connectBSDF(ray_2.unit_direction, dir_11, _S825.smooth_n, _S824.material, _S827.x, _S827.y, lobe_index_0, surface_4.random_state);
                lobe_7 = _S953;
            }
            var _S954 : bool = lobe_index_0 != u32(0);
            if(_S954)
            {
                var _S955 : bool = (_S824.material.roughness) == 0.0f;
                if(_S955)
                {
                    _S880 = true;
                }
                else
                {
                    var _S956 : bool = lobe_index_0 == u32(1);
                    if(_S956)
                    {
                        _S880 = (_S827.x) == (_S827.y);
                    }
                    else
                    {
                        _S880 = false;
                    }
                }
            }
            else
            {
                _S880 = false;
            }
            var _S957 : bool = isTranslucent_0(_S824.material);
            if(_S957)
            {
                _S917 = lobe_index_0 == u32(0);
            }
            else
            {
                _S917 = false;
            }
            if(_S917)
            {
                _S918 = (dot(dir_11, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S918 = false;
            }
            if(_S828)
            {
                _S919 = !_S880;
            }
            else
            {
                _S919 = false;
            }
            if(_S919)
            {
                _S920 = !wrong_side_0;
            }
            else
            {
                _S920 = false;
            }
            var _S958 : bool;
            if(_S920)
            {
                var _S959 : f32 = lobe_7.pdf;
                var _S960 : vec3<f32> = ray_2.origin;
                var _S961 : bool = isTranslucent_0(_S824.material);
                var _S962 : vec3<f32> = select(_S825.smooth_n, _S788, _S961);
                var _S963 : vec3<f32> = ray_2.origin;
                var _S964 : Surface = surface_4;
                var _S965 : vec3<f32> = (vec3<f32>(0) - _S825.smooth_n);
                var _S966 : vec3<f32> = select(_S825.smooth_n, _S965, _S918);
                var _S967 : NEEVertex = NEEVertex_x24init_0(false, _S959, _S960, _S962, _S963 + vec3<f32>(_S964.geometry_offset) * _S966);
                nee_vertex_0 = _S967;
            }
            else
            {
                var _S968 : bool = lobe_index_0 != u32(1);
                if(_S968)
                {
                    _S958 = true;
                }
                else
                {
                    _S958 = (_S827.x) != (_S827.y);
                }
                if(_S958)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S969 : bool = lobe_index_0 == u32(0);
            var _S970 : bool = withinInverseFootprint(lobe_7.pdf, _S969, prev_0.cos, hit_2.distance, threshold_2);
            var _S971 : bool = roughLobe(lobe_7.pdf, _S969, _S824.material.roughness);
            var throughput_6 : vec3<f32>;
            if(_S853)
            {
                var _S972 : bool = !_S970;
                if(_S972)
                {
                    return _S789;
                }
                var _S973 : bool = _S793 != u32(1);
                if(_S973)
                {
                    _S958 = _S793 != u32(2);
                }
                else
                {
                    _S958 = false;
                }
                if(_S958)
                {
                    var _S974 : f32 = lobe_7.pdf;
                    var _S975 : f32 = select(0.0f, _S974, _S828);
                    var _S976 : f32 = escapeWeight_0(_S975, r_8.dir);
                    if(_S861)
                    {
                        is_inside_4 = _S799;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S977 : f32 = select(1.0f, _S976, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf)) * r_8.radiance * vec3<f32>(_S977) / vec3<f32>(r_8.jac), density_3 * lobe_7.pdf / r_8.jac);
                }
                var _S978 : vec3<f32> = throughput_4 * vec3<f32>(lobe_7.pdf);
                var _S979 : f32 = density_3 * lobe_7.pdf;
                throughput_6 = _S978;
                density_5 = _S979;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S958 = b_3 <= _S803;
            }
            else
            {
                _S958 = false;
            }
            var _S980 : bool;
            if(_S958)
            {
                _S980 = _S823;
            }
            else
            {
                _S980 = false;
            }
            var _S981 : bool;
            if(_S980)
            {
                _S981 = _S970;
            }
            else
            {
                _S981 = false;
            }
            var _S982 : bool;
            if(_S981)
            {
                _S982 = true;
            }
            else
            {
                if(_S878)
                {
                    _S982 = !_S971;
                }
                else
                {
                    _S982 = false;
                }
            }
            if(_S982)
            {
                return _S789;
            }
            var throughput_7 : vec3<f32>;
            if(_S878)
            {
                var _S983 : vec3<f32> = throughput_6 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf));
                var _S984 : f32 = lobe_7.pdf;
                throughput_7 = _S983;
                survival_probability_0 = _S984;
            }
            else
            {
                var _S985 : vec3<f32> = throughput_6 * max(lobe_7.throughput, _S788);
                throughput_7 = _S985;
                survival_probability_0 = density_5;
            }
            var _S986 : bool = !replay_0;
            var _S987 : bool;
            if(_S986)
            {
                _S987 = !_S843;
            }
            else
            {
                _S987 = false;
            }
            var _S988 : bool;
            if(_S987)
            {
                _S988 = _S823;
            }
            else
            {
                _S988 = false;
            }
            var _S989 : bool;
            if(_S988)
            {
                _S989 = _S970;
            }
            else
            {
                _S989 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S989)
            {
                chain_0 = here_0;
                var _S990 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(17)), (u32(2))));
                var _S991 : u32 = select(u32(0), u32(1), _S828);
                var _S992 : u32 = (insertBits((_S990), (_S991), (u32(19)), (u32(1))));
                chain_0.path = _S992;
                var _S993 : f32 = chain_0.jac * lobe_7.pdf;
                chain_0.jac = _S993;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S994 : Vertex = Vertex_x24init_0(_S971, lobe_index_0, lobe_7.pdf, abs(dot(surface_4.geometry_n, dir_11)), is_inside_4);
            prev_0 = _S994;
            var _S995 : f32 = lobe_7.pdf;
            var _S996 : bool = lobe_index_0 == u32(1);
            var _S997 : bool;
            if(_S996)
            {
                _S997 = (_S827.x) == (_S827.y);
            }
            else
            {
                _S997 = false;
            }
            var _S998 : f32 = select(_S995, sky_pdf_0, _S997);
            var _S999 : bool;
            if(refracted_4)
            {
                _S999 = !_S918;
            }
            else
            {
                _S999 = false;
            }
            var is_inside_5 : bool;
            if(_S999)
            {
                var _S1000 : bool = !is_inside_4;
                is_inside_5 = _S1000;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_11;
            var _S1001 : Surface = surface_4;
            var _S1002 : vec3<f32> = (vec3<f32>(0) - _S825.smooth_n);
            var _S1003 : bool = is_inside_5 != _S918;
            var _S1004 : vec3<f32> = select(_S825.smooth_n, _S1002, _S1003);
            var _S1005 : vec3<f32> = ray_2.origin + vec3<f32>(_S1001.geometry_offset) * _S1004;
            ray_2.origin = _S1005;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S998;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        var _S1006 : bool = !replay_0;
        if(_S1006)
        {
            if(_S811)
            {
                var _S1007 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1008 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1009 : bool = _S1008 == u32(1);
                if(_S1009)
                {
                    var _S1010 : vec3<f32> = safeDivide(_S1007, chain_throughput_0);
                    candidate_6.radiance = _S1010;
                }
                var _S1011 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1007);
                offer(&((*sel_4)), _S1011, _S1007 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S811)
            {
                _S878 = true;
            }
            else
            {
                _S878 = scatter_0;
            }
            if(_S878)
            {
                var _S1012 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1012;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1013 : u32 = stream(r_8.seed, b_3 + u32(128));
            var _S1014 : Random = pcg(_S1013);
            var _S1015 : bool = survival_probability_0 < (_S1014.value);
            if(_S1015)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1016 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1016;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1017 : f32 = density_5 * survival_probability_0;
            density_2 = _S1017;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1018 : Ray = ray_2;
        var _S1019 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S878 = _S854;
        }
        else
        {
            _S878 = false;
        }
        if(_S878)
        {
            wrong_side_0 = _S792 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1020 : f32 = select(4.294967296e+09f, _S1019, wrong_side_0);
        var _S1021 : Hit = (traverseInstanceBVH((_S1018), (_S813), (_S1020)));
        hit_2 = _S1021;
        if(replay_0)
        {
            refracted_4 = _S854;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S879 = _S792 == u32(1);
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
        {
            _S880 = (hit_2.instance_index) == (_S804.instance_index);
        }
        else
        {
            _S880 = false;
        }
        if(_S880)
        {
            _S917 = (hit_2.triangle_index) == (_S804.triangle_index);
        }
        else
        {
            _S917 = false;
        }
        if(_S917)
        {
            hit_2.uv = _S804.uv;
            var _S1022 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1022;
        }
        if(replay_0)
        {
            _S918 = _S854;
        }
        else
        {
            _S918 = false;
        }
        if(_S918)
        {
            _S919 = _S792 == u32(3);
        }
        else
        {
            _S919 = false;
        }
        if(_S919)
        {
            _S920 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            return _S789;
        }
        var _S1023 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1023)
        {
            var _S1024 : bool = !nee_vertex_0.none;
            var _S1025 : f32 = select(0.0f, sky_pdf_0, _S1024);
            var _S1026 : f32 = escapeWeight_0(_S1025, ray_2.unit_direction);
            var _S1027 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1028 : vec3<f32> = throughput_2 * _S1027;
            if(replay_0)
            {
                if(_S854)
                {
                    is_inside_4 = _S792 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1028 * vec3<f32>(_S1026) / vec3<f32>(r_8.jac), density_2 / r_8.jac);
                }
                if(_S802)
                {
                    is_inside_4 = _S799;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_3 == _S790;
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
                    return Shift_x24init_0(_S1028 * vec3<f32>(_S1026), 1.0f);
                }
                return _S789;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1029 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1030 : bool = _S1029 == u32(1);
            if(_S1030)
            {
                var _S1031 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1032 : bool = _S1031 == b_3;
                var _S1033 : f32 = select(_S1026, 1.0f, _S1032);
                var _S1034 : vec3<f32> = safeDivide(_S1028 * vec3<f32>(_S1033), chain_throughput_0);
                candidate_7.radiance = _S1034;
            }
            else
            {
                var _S1035 : bool = prev_0.rough;
                if(_S1035)
                {
                    var _S1036 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                    var _S1037 : u32 = (insertBits((_S1036), (u32(3)), (u32(10)), (u32(2))));
                    var _S1038 : u32 = (insertBits((_S1037), (prev_0.lobe), (u32(15)), (u32(2))));
                    var _S1039 : bool = prev_0.inside;
                    var _S1040 : u32 = select(u32(0), u32(1), _S1039);
                    var _S1041 : u32 = (insertBits((_S1038), (_S1040), (u32(20)), (u32(1))));
                    candidate_7.path = _S1041;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1042 : vec3<f32> = _S1028 * vec3<f32>(_S1026);
            var _S1043 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1042);
            offer(&((*sel_4)), _S1043, _S1042 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1044 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1044;
        var _S1045 : u32 = b_3 + u32(1);
        b_3 = _S1045;
    }
    return _S789;
}

fn shift_0( dom_5 : Domain,  r_9 : Reservoir) -> Shift
{
    var _S1046 : vec3<f32> = vec3<f32>(0.0f);
    var _S1047 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1046, 0.0f, vec4<u32>(u32(0)), _S1046, _S1046), 0.0f, _S1046, u32(0));
    var sel_5 : Selection = _S1047;
    var _S1048 : bool = (r_9.w) <= 0.0f;
    if(_S1048)
    {
        return Shift_x24init_0(_S1046, 0.0f);
    }
    var _S1049 : Shift = walk_0(dom_5, r_9, true, 0.0f, &(sel_5));
    return _S1049;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1050 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1051 : bool = _S1050 != u32(4294967295);
    if(_S1051)
    {
        var _S1052 : vec2<i32> = vec2<i32>((vec2<u32>(_S1050, (_S1050 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1053 : vec3<f32> = vec3<f32>(0.0f);
        var _S1054 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1053, _S1053, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1053, 0.0f, vec4<u32>(u32(0)), _S1053, _S1053));
        var shift_job_0 : ShiftJob = _S1054;
        var _S1055 : u32 = (_S1050 >> (u32(28)));
        var _S1056 : bool = spatialJob_0(_S1052, _S1055, &(shift_job_0));
        var _S1057 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1052), (_S1055), (vec4<u32>((bitcast<vec3<u32>>((_S1057.f))), (bitcast<u32>((_S1057.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1058 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1059 : array<u32, i32(3)>;
    spatialBins_0(_S1058, &(_S1059));
    var _S1060 : array<u32, i32(3)> = _S1059;
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
        var _S1061 : bool = (_S1060[t_16]) == u32(40);
        if(_S1061)
        {
            textureStore(shift_data_out, (_S1058), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1058, _S1060, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1062 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1062));
    countShifts_0(_S1062, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1063 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1064 : bool = _S1063 != u32(4294967295);
    if(_S1064)
    {
        var _S1065 : vec2<i32> = vec2<i32>((vec2<u32>(_S1063, (_S1063 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1066 : vec3<f32> = vec3<f32>(0.0f);
        var _S1067 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1066, _S1066, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1066, 0.0f, vec4<u32>(u32(0)), _S1066, _S1066));
        var shift_job_1 : ShiftJob = _S1067;
        var _S1068 : u32 = (_S1063 >> (u32(28)));
        var _S1069 : bool = temporalJob_0(_S1065, _S1068, &(shift_job_1));
        var _S1070 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1065), (_S1068), (vec4<u32>((bitcast<vec3<u32>>((_S1070.f))), (bitcast<u32>((_S1070.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1071 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1072 : array<u32, i32(3)>;
    temporalBins_0(_S1071, &(_S1072));
    var _S1073 : array<u32, i32(3)> = _S1072;
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
        var _S1074 : bool = (_S1073[t_18]) == u32(40);
        if(_S1074)
        {
            textureStore(temporal_shifts_out, (_S1071), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1071, _S1073, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1075 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1075));
    countShifts_0(_S1075, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1076 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1076;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1077 : f32 = c_3 * p_c_1;
    var _S1078 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1077 / (_S1077 + c_t_0 * g_previous_0), _S1078 / (_S1078 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1079 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1080 : vec3<f32> = vec3<f32>(0.0f);
    var _S1081 : Domain = Domain_x24init_0(_S1080, _S1080, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1081;
    var _S1082 : bool = (currentDomain((_S1079), &(dom_6)));
    var _S1083 : bool = !_S1082;
    if(_S1083)
    {
        storeReservoir(reservoir_temp_out, (_S1079), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1080, 0.0f, vec4<u32>(u32(0)), _S1080, _S1080)), (dom_6.hit));
        return;
    }
    var _S1084 : Reservoir = (loadReservoir(reservoir_initial, (_S1079)));
    var _S1085 : vec2<i32> = temporalNeighbor_0(_S1079, dom_6);
    var _S1086 : bool = (_S1085.x) >= i32(0);
    var r_10 : Reservoir;
    if(_S1086)
    {
        var _S1087 : Reservoir = (loadReservoir(reservoir_prev, (_S1085)));
        var _S1088 : vec4<u32> = (textureLoad(duplication, (_S1085), 0, 0));
        var _S1089 : f32 = (bitcast<f32>((_S1088.x)));
        var _S1090 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1091 : bool = _S1090 == u32(1);
        var _S1092 : f32 = select(0.0f, _S1089, _S1091);
        var _S1093 : f32 = confidenceCap(_S1092);
        var _S1094 : f32 = min(_S1087.c, _S1093);
        var _S1095 : vec4<u32> = (textureLoad(temporal_shifts, (_S1079), (u32(0)), 0));
        var _S1096 : vec4<f32> = (bitcast<vec4<f32>>((_S1095)));
        var _S1097 : vec4<f32> = vec4<f32>(_S1084.f, 1.0f);
        var _S1098 : Domain = (previousDomain((_S1085)));
        var _S1099 : bool = sameDomain_0(_S1098, dom_6);
        var _S1100 : bool = !_S1099;
        var to_previous_0 : vec4<f32>;
        if(_S1100)
        {
            var _S1101 : vec4<u32> = (textureLoad(temporal_shifts, (_S1079), (u32(1)), 0));
            var _S1102 : vec4<f32> = (bitcast<vec4<f32>>((_S1101)));
            to_previous_0 = _S1102;
        }
        else
        {
            to_previous_0 = _S1097;
        }
        var _S1103 : f32 = rgb_to_greyscale(_S1084.f);
        var _S1104 : f32 = rgb_to_greyscale(_S1087.f);
        var _S1105 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1080, 0.0f, vec4<u32>(u32(0)), _S1080, _S1080), 0.0f, _S1080, u32(0));
        var sel_6 : Selection = _S1105;
        var _S1106 : u32 = (uniforms_uint.frame);
        var _S1107 : u32 = hash(_S1106);
        var _S1108 : u32 = global_invocation_id_7.x;
        var _S1109 : vec2<u32> = (uniforms_uint.render_size);
        var _S1110 : u32 = stream(_S1107, _S1108 + _S1109.x * global_invocation_id_7.y);
        var _S1111 : u32 = stream(_S1110, u32(194));
        sel_6.random_state = _S1111;
        var _S1112 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1113 : vec3<f32> = _S1096.xyz;
        var _S1114 : f32 = rgb_to_greyscale(_S1113);
        var _S1115 : vec2<f32> = temporalWeights(_S1084.c, _S1103, _S1094, _S1104, _S1112, _S1114);
        offerShifted(&(sel_6), _S1084, Shift_x24init_0(_S1084.f, 1.0f), _S1115.x);
        offerShifted(&(sel_6), _S1087, Shift_x24init_0(_S1113, _S1096.w), _S1115.y);
        var _S1116 : Reservoir = finalize(sel_6, _S1084.c + _S1094);
        r_10 = _S1116;
    }
    else
    {
        r_10 = _S1084;
    }
    storeReservoir(reservoir_temp_out, (_S1079), (r_10), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1117 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1118 : vec3<f32> = vec3<f32>(0.0f);
    var _S1119 : Domain = Domain_x24init_0(_S1118, _S1118, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1119;
    var _S1120 : bool = (currentDomain((_S1117), &(dom_7)));
    var _S1121 : bool = !_S1120;
    if(_S1121)
    {
        storeReservoir(reservoir_initial_out, (_S1117), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1118, 0.0f, vec4<u32>(u32(0)), _S1118, _S1118)), (dom_7.hit));
        return;
    }
    var _S1122 : u32 = (uniforms_uint.frame);
    var _S1123 : u32 = hash(_S1122);
    var _S1124 : u32 = global_invocation_id_8.x;
    var _S1125 : vec2<u32> = (uniforms_uint.render_size);
    var _S1126 : u32 = stream(_S1123, _S1124 + _S1125.x * global_invocation_id_8.y);
    var _S1127 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1118, 0.0f, vec4<u32>(u32(0)), _S1118, _S1118);
    var _S1128 : Selection = Selection_x24init_0(_S1127, 0.0f, _S1118, u32(0));
    var initial_0 : Selection = _S1128;
    var _S1129 : u32 = stream(_S1126, u32(193));
    initial_0.random_state = _S1129;
    var i_2 : u32 = u32(0);
    loop
    {
        var _S1130 : u32 = (uniforms_uint.samples);
        if(i_2 < _S1130)
        {
        }
        else
        {
            break;
        }
        var r_11 : Reservoir = _S1127;
        var _S1131 : u32 = stream(_S1126, i_2);
        r_11.seed = _S1131;
        var _S1132 : u32 = (uniforms_uint.samples);
        var _S1133 : Shift = walk_0(dom_7, r_11, false, 1.0f / f32(_S1132), &(initial_0));
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var _S1134 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1117), (_S1134), (dom_7.hit));
    return;
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S1135 : Random = pcg(state_2);
    var _S1136 : Random = pcg(_S1135.state);
    var _S1137 : f32 = 6.28318548202514648f * _S1135.value;
    var _S1138 : f32 = sqrt(-2.0f * clamp(log(_S1136.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1136.state, _S1138 * cos(_S1137));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1139 : RandomSphere;
    _S1139.state = state_3;
    _S1139.value = value_1;
    return _S1139;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S1140 : Random = normal_distribution(state_4);
    var _S1141 : Random = normal_distribution(_S1140.state);
    var _S1142 : Random = normal_distribution(_S1141.state);
    var _S1143 : vec3<f32> = (normalize((vec3<f32>(_S1140.value, _S1141.value, _S1142.value))));
    return RandomSphere_x24init_0(_S1142.state, _S1143);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_12 : vec3<f32>) -> mat3x3<f32>
{
    var _S1144 : vec3<f32> = p1_0 - p0_0;
    var _S1145 : vec3<f32> = p2_0 - p0_0;
    var _S1146 : vec2<f32> = uv1_0 - uv0_0;
    var _S1147 : vec2<f32> = uv2_0 - uv0_0;
    var _S1148 : f32 = _S1146.x;
    var _S1149 : f32 = _S1147.y;
    var _S1150 : f32 = _S1146.y;
    var _S1151 : f32 = _S1147.x;
    var _S1152 : f32 = _S1148 * _S1149 - _S1150 * _S1151;
    var _S1153 : f32 = 1.0f / _S1152;
    var _S1154 : vec3<f32> = vec3<f32>(_S1153);
    var t_20 : vec3<f32> = (_S1144 * vec3<f32>(_S1149) - _S1145 * vec3<f32>(_S1150)) * _S1154;
    var _S1155 : vec3<f32> = (_S1145 * vec3<f32>(_S1148) - _S1144 * vec3<f32>(_S1151)) * _S1154;
    var t_21 : vec3<f32> = (normalize((t_20 - n_12 * vec3<f32>(dot(n_12, t_20)))));
    var _S1156 : bool = (dot(cross(n_12, t_21), _S1155)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1156)
    {
        var _S1157 : vec3<f32> = ((-(t_21)));
        t_22 = _S1157;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1158 : vec3<f32> = cross(n_12, t_22);
    return mat3x3<f32>(t_22, _S1158, n_12);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1159 : vec3<f32> = t1_0 - t0_0;
    var _S1160 : vec3<f32> = t2_2 - t0_0;
    var _S1161 : vec3<f32> = t2_2 - t1_0;
    var _S1162 : f32 = min(length(_S1159), min(length(_S1160), length(_S1161)));
    var _S1163 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1164 : vec3<f32> = (normalize((n0_0)));
    var _S1165 : f32 = dot(geometry_n_5, _S1164);
    var _S1166 : vec3<f32> = (normalize((n1_0)));
    var _S1167 : f32 = dot(geometry_n_5, _S1166);
    var _S1168 : vec3<f32> = (normalize((n2_0)));
    var _S1169 : vec3<f32> = acos(abs(vec3<f32>(_S1165, _S1167, dot(geometry_n_5, _S1168))));
    var _S1170 : vec3<f32> = clamp(tan(_S1169), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1163 * _S1170, uvw_0), 0.0f, _S1162 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_13 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S1171 : vec3<f32> = ((-(dir_12)));
    var _S1172 : f32 = (sign((dot(n_13, _S1171))));
    var _S1173 : vec3<f32> = n_13 * vec3<f32>(_S1172);
    var _S1174 : AnisotropicFrame = anisotropicFrame(material_15, _S1173);
    var _S1175 : bool = (_S1174.alphas.x) > 0.0f;
    if(_S1175)
    {
        var _S1176 : f32 = material_15.transmission * (1.0f - material_15.metallic);
        var _S1177 : vec3<f32> = ((-(_S1173)));
        var _S1178 : vec3<f32> = anisotropicLocal(dir_12, _S1174.tangent, _S1177);
        var _S1179 : f32 = anisotropicG1(_S1178, _S1174.alphas);
        return vec3<f32>((_S1176 * _S1179)) * material_15.albedo;
    }
    var _S1180 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S1181 : f32 = material_15.roughness;
    var _S1182 : f32 = smithG1(_S1181 * _S1181, abs(dot(n_13, dir_12)));
    return vec3<f32>((_S1180 * _S1182)) * material_15.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_14 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1183 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S1184 : vec3<f32> = straightThrough(toward_1, n_14, material_16);
        _S1183 = _S1184;
    }
    else
    {
        _S1183 = vec3<f32>(0.0f);
    }
    return _S1183 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_12 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1185 : Shift = walk_0(dom_8, r_12, replay_1, scale_2, &((*sel_7)));
    return _S1185;
}

fn shift_hook( dom_9 : Domain,  r_13 : Reservoir) -> Shift
{
    var _S1186 : Shift = shift_0(dom_9, r_13);
    return _S1186;
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

