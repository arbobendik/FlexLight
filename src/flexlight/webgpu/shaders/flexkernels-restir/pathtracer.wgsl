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
    var _S14 : vec2<i32> = (_S12 * _S8 + _S10) % _S13;
    var _S15 : vec2<i32> = (_S14 + _S13) % _S13;
    var _S16 : vec4<i32> = (textureLoad(pairing, (_S15), (t_0), 0));
    var _S17 : vec2<i32> = _S16.xy * _S8;
    var _S18 : vec2<i32> = _S17.yx;
    var _S19 : vec2<i32> = select(_S17, _S18, _S9);
    return p_0 + _S19;
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
    var _S20 : bool = t_1 > u32(2);
    var _S21 : bool;
    if(_S20)
    {
        _S21 = true;
    }
    else
    {
        var _S22 : vec2<u32> = (uniforms_uint.render_size);
        _S21 = (any((p_1 >= vec2<i32>(_S22))));
    }
    if(_S21)
    {
        return false;
    }
    var _S23 : Reservoir = (loadReservoir(reservoir_temp, (p_1)));
    (*job_0).r = _S23;
    var _S24 : bool = ((*job_0).r.w) > 0.0f;
    if(_S24)
    {
        var _S25 : vec2<i32> = partner_0(p_1, t_1);
        var _S26 : Domain = (*job_0).dom;
        var _S27 : bool = (storedDomain(reservoir_temp, (_S25), &(_S26)));
        (*job_0).dom = _S26;
        _S21 = _S27;
    }
    else
    {
        _S21 = false;
    }
    return _S21;
}

fn Hit_x24init_0( uv_0 : vec2<f32>,  instance_index_0 : u32,  triangle_index_0 : u32,  is_point_light_0 : u32,  distance_0 : f32) -> Hit
{
    var _S28 : Hit;
    _S28.uv = uv_0;
    _S28.instance_index = instance_index_0;
    _S28.triangle_index = triangle_index_0;
    _S28.is_point_light = is_point_light_0;
    _S28.distance = distance_0;
    return _S28;
}

fn Domain_x24init_0( x0_0 : vec3<f32>,  x1_0 : vec3<f32>,  hit_0 : Hit) -> Domain
{
    var _S29 : Domain;
    _S29.x0 = x0_0;
    _S29.x1 = x1_0;
    _S29.hit = hit_0;
    return _S29;
}

fn Reservoir_x24init_0( seed_0 : u32,  path_0 : u32,  w_0 : f32,  c_0 : f32,  f_0 : vec3<f32>,  jac_0 : f32,  rc_0 : vec4<u32>,  dir_0 : vec3<f32>,  radiance_0 : vec3<f32>) -> Reservoir
{
    var _S30 : Reservoir;
    _S30.seed = seed_0;
    _S30.path = path_0;
    _S30.w = w_0;
    _S30.c = c_0;
    _S30.f = f_0;
    _S30.jac = jac_0;
    _S30.rc = rc_0;
    _S30.dir = dir_0;
    _S30.radiance = radiance_0;
    return _S30;
}

fn ShiftJob_x24init_0( dom_0 : Domain,  r_0 : Reservoir) -> ShiftJob
{
    var _S31 : ShiftJob;
    _S31.dom = dom_0;
    _S31.r = r_0;
    return _S31;
}

fn shiftBin_0( r_1 : Reservoir) -> u32
{
    var _S32 : u32 = (extractBits((r_1.path), (u32(10)), (u32(2))));
    var _S33 : bool = _S32 == u32(2);
    var _S34 : bool;
    if(_S33)
    {
        var _S35 : u32 = (extractBits((r_1.path), (u32(12)), (u32(3))));
        _S34 = _S35 == u32(4);
    }
    else
    {
        _S34 = false;
    }
    var _S36 : u32 = select(_S32, u32(4), _S34);
    var _S37 : u32 = (extractBits((r_1.path), (u32(5)), (u32(5))));
    var _S38 : u32 = (extractBits((r_1.path), (u32(0)), (u32(5))));
    var _S39 : u32 = _S38 + u32(1);
    var _S40 : bool = _S32 == u32(0);
    var _S41 : u32 = select(_S37, _S39, _S40);
    return _S36 * u32(8) + clamp(_S41, u32(1), u32(8)) - u32(1);
}

fn spatialBins_0( p_2 : vec2<i32>,  _S42 : ptr<function, array<u32, i32(3)>>)
{
    var _S43 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
    var bins_0 : array<u32, i32(3)>;
    bins_0[i32(0)] = u32(40);
    bins_0[i32(1)] = u32(40);
    bins_0[i32(2)] = u32(40);
    var t_2 : u32 = u32(0);
    loop
    {
        var _S44 : u32 = (uniforms_uint.restir_neighbours);
        if(t_2 < _S44)
        {
        }
        else
        {
            break;
        }
        var _S45 : vec3<f32> = vec3<f32>(0.0f);
        var _S46 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S45, _S45, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S45, 0.0f, vec4<u32>(u32(0)), _S45, _S45));
        var job_1 : ShiftJob = _S46;
        var _S47 : bool = spatialJob_0(p_2, t_2, &(job_1));
        if(_S47)
        {
            var _S48 : u32 = shiftBin_0(job_1.r);
            bins_0[t_2] = _S48;
        }
        var t_3 : u32 = t_2 + u32(1);
        t_2 = t_3;
    }
    (*_S42) = bins_0;
    return;
}

fn queuedShift_0( workgroup_id_0 : vec3<u32>,  local_invocation_index_0 : u32) -> u32
{
    var _S49 : u32 = workgroup_id_0.y * u32(65535) + workgroup_id_0.x;
    var bin_0 : u32 = u32(0);
    var group_0 : u32 = _S49;
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
        var _S50 : u32 = (queued_shifts[(u32(3) + bin_0)]);
        var _S51 : u32 = (_S50 + u32(63)) / u32(64);
        var _S52 : bool = group_0 < _S51;
        if(_S52)
        {
            var _S53 : u32 = group_0 * u32(64) + local_invocation_index_0;
            var _S54 : bool = _S53 < _S50;
            if(_S54)
            {
                var _S55 : u32 = (queued_shifts[(u32(83) + start_0 + _S53)]);
                return _S55;
            }
            return u32(4294967295);
        }
        var group_1 : u32 = group_0 - _S51;
        var start_1 : u32 = start_0 + _S50;
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
    var _S56 : array<u32, i32(3)> = array<u32, i32(3)>(u32(0), u32(0), u32(0));
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
        var _S57 : u32 = t_4;
        var _S58 : bool = (bins_1[t_4]) < u32(40);
        if(_S58)
        {
            var _S59 : u32 = atomicAdd(&(bin_jobs_0[bins_1[_S57]]), u32(1));
            slots_0[t_4] = _S59;
        }
        var t_5 : u32 = t_4 + u32(1);
        t_4 = t_5;
    }
    workgroupBarrier();
    var _S60 : bool = local_invocation_index_1 < u32(40);
    var bin_2 : u32;
    var groups_0 : u32;
    if(_S60)
    {
        var _S61 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_1]));
        var _S62 : bool = _S61 > u32(0);
        if(_S62)
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
                var _S63 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
                var start_2 : u32 = groups_0 + _S63;
                var bin_3 : u32 = bin_2 + u32(1);
                bin_2 = bin_3;
                groups_0 = start_2;
            }
            var _S64 : u32 = (atomicAdd(&shift_queue.cursors[(local_invocation_index_1)], (_S61)));
            bin_offsets_0[local_invocation_index_1] = groups_0 + _S64;
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
        var _S65 : u32 = t_4;
        var _S66 : bool = (bins_1[t_4]) < u32(40);
        if(_S66)
        {
            shift_queue.jobs[(bin_offsets_0[bins_1[_S65]] + slots_0[t_4])] = ((((u32(p_3.x) | (((u32(p_3.y) << (u32(14))))))) | (((t_4 << (u32(28)))))));
        }
        var t_6 : u32 = t_4 + u32(1);
        t_4 = t_6;
    }
    var _S67 : bool = (all(((global_invocation_id_0.xy) == vec2<u32>(u32(0)))));
    if(_S67)
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
            var _S68 : u32 = (atomicLoad(&shift_queue.counts[(bin_2)]));
            var groups_1 : u32 = groups_0 + (_S68 + u32(63)) / u32(64);
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
    var _S69 : vec3<f32> = (((view_0) * (position_0 - camera_0)));
    var _S70 : vec2<f32> = vec2<f32>(0.5f);
    var _S71 : vec2<f32> = _S69.xy / vec2<f32>(_S69.z) * _S70 + _S70;
    var _S72 : vec2<f32> = vec2<f32>(_S71.x, 1.0f - _S71.y);
    var _S73 : vec2<u32> = (uniforms_uint.render_size);
    return _S72 * vec2<f32>(_S73);
}

fn previousValid_0( q_0 : vec2<i32>) -> bool
{
    var _S74 : bool = (all((q_0 >= vec2<i32>(i32(0)))));
    var _S75 : bool;
    if(_S74)
    {
        var _S76 : vec2<u32> = (uniforms_uint.render_size);
        _S75 = (all((q_0 < vec2<i32>(_S76))));
    }
    else
    {
        _S75 = false;
    }
    if(_S75)
    {
        var _S77 : vec4<u32> = (textureLoad(reservoir_prev, (q_0), (u32(0)), 0));
        _S75 = (bitcast<f32>((_S77.w))) > 0.0f;
    }
    else
    {
        _S75 = false;
    }
    return _S75;
}

fn temporalNeighbor_0( p_4 : vec2<i32>,  dom_1 : Domain) -> vec2<i32>
{
    var _S78 : mat3x3<f32> = (uniforms_float.prev_view_matrix);
    var _S79 : vec3<f32> = (uniforms_float.prev_camera_position);
    var _S80 : vec2<f32> = project_0(_S78, _S79, dom_1.x1);
    var _S81 : vec2<i32> = vec2<i32>(floor(_S80));
    var _S82 : bool = previousValid_0(_S81);
    var _S83 : bool = !_S82;
    if(_S83)
    {
        return vec2<i32>(i32(-1));
    }
    var _S84 : Domain = (previousDomain((_S81)));
    var _S85 : bool = (_S84.hit.instance_index) == (dom_1.hit.instance_index);
    var _S86 : bool;
    if(_S85)
    {
        var _S87 : f32 = distance(_S84.x1, dom_1.x1);
        var _S88 : f32 = dom_1.hit.distance * 8.0f;
        var _S89 : vec2<u32> = (uniforms_uint.render_size);
        _S86 = _S87 <= (_S88 / f32(_S89.x));
    }
    else
    {
        _S86 = false;
    }
    if(_S86)
    {
        return _S81;
    }
    var _S90 : vec2<f32> = vec2<f32>(p_4 + _S81) + vec2<f32>(1.0f);
    var _S91 : mat3x3<f32> = (uniforms_float.view_matrix);
    var _S92 : vec3<f32> = (uniforms_float.camera_position);
    var _S93 : vec2<f32> = project_0(_S91, _S92, _S84.x1);
    var _S94 : vec2<i32> = vec2<i32>(floor(_S90 - _S93));
    var _S95 : vec2<i32> = vec2<i32>(i32(-1));
    var _S96 : bool = previousValid_0(_S94);
    var _S97 : vec2<i32> = select(_S95, _S94, _S96);
    return _S97;
}

fn sameDomain_0( a_0 : Domain,  b_0 : Domain) -> bool
{
    var _S98 : bool = (all(((a_0.x0) == (b_0.x0))));
    var _S99 : bool;
    if(_S98)
    {
        _S99 = (a_0.hit.instance_index) == (b_0.hit.instance_index);
    }
    else
    {
        _S99 = false;
    }
    if(_S99)
    {
        _S99 = (a_0.hit.triangle_index) == (b_0.hit.triangle_index);
    }
    else
    {
        _S99 = false;
    }
    if(_S99)
    {
        _S99 = (all(((a_0.hit.uv) == (b_0.hit.uv))));
    }
    else
    {
        _S99 = false;
    }
    return _S99;
}

fn temporalJob_0( p_5 : vec2<i32>,  t_7 : u32,  job_2 : ptr<function, ShiftJob>) -> bool
{
    var _S100 : vec3<f32> = vec3<f32>(0.0f);
    var _S101 : Domain = Domain_x24init_0(_S100, _S100, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_2 : Domain = _S101;
    var _S102 : bool = t_7 > u32(1);
    var _S103 : bool;
    if(_S102)
    {
        _S103 = true;
    }
    else
    {
        var _S104 : bool = (storedDomain(reservoir_initial, (p_5), &(dom_2)));
        _S103 = !_S104;
    }
    if(_S103)
    {
        return false;
    }
    var _S105 : vec2<i32> = temporalNeighbor_0(p_5, dom_2);
    var _S106 : bool = (_S105.x) < i32(0);
    if(_S106)
    {
        return false;
    }
    var _S107 : bool = t_7 == u32(0);
    if(_S107)
    {
        var _S108 : Reservoir = (loadReservoir(reservoir_prev, (_S105)));
        var _S109 : ShiftJob = ShiftJob_x24init_0(dom_2, _S108);
        (*job_2) = _S109;
    }
    else
    {
        var _S110 : Domain = (previousDomain((_S105)));
        var _S111 : Reservoir = (loadReservoir(reservoir_initial, (p_5)));
        var _S112 : ShiftJob = ShiftJob_x24init_0(_S110, _S111);
        (*job_2) = _S112;
    }
    var _S113 : bool = ((*job_2).r.w) > 0.0f;
    if(_S113)
    {
        if(_S107)
        {
            _S103 = true;
        }
        else
        {
            var _S114 : bool = sameDomain_0((*job_2).dom, dom_2);
            _S103 = !_S114;
        }
    }
    else
    {
        _S103 = false;
    }
    return _S103;
}

fn temporalBins_0( p_6 : vec2<i32>,  _S115 : ptr<function, array<u32, i32(3)>>)
{
    var _S116 : array<u32, i32(3)> = array<u32, i32(3)>( u32(40), u32(40), u32(40) );
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
        var _S117 : vec3<f32> = vec3<f32>(0.0f);
        var _S118 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S117, _S117, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S117, 0.0f, vec4<u32>(u32(0)), _S117, _S117));
        var job_3 : ShiftJob = _S118;
        var _S119 : bool = temporalJob_0(p_6, t_8, &(job_3));
        if(_S119)
        {
            var _S120 : u32 = shiftBin_0(job_3.r);
            bins_2[t_8] = _S120;
        }
        var t_9 : u32 = t_8 + u32(1);
        t_8 = t_9;
    }
    (*_S115) = bins_2;
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
        var _S121 : u32 = t_10;
        var _S122 : bool = (bins_3[t_10]) < u32(40);
        if(_S122)
        {
            var _S123 : u32 = atomicAdd(&(bin_jobs_0[bins_3[_S121]]), u32(1));
        }
        var t_11 : u32 = t_10 + u32(1);
        t_10 = t_11;
    }
    workgroupBarrier();
    var _S124 : bool = local_invocation_index_2 < u32(40);
    if(_S124)
    {
        var _S125 : u32 = atomicLoad(&(bin_jobs_0[local_invocation_index_2]));
        var _S126 : bool = _S125 > u32(0);
        if(_S126)
        {
            var _S127 : u32 = (atomicAdd(&shift_queue.counts[(local_invocation_index_2)], (_S125)));
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
    var _S128 : Ray;
    _S128.origin = origin_0;
    _S128.unit_direction = unit_direction_0;
    return _S128;
}

fn skyRadiance_0( origin_1 : vec3<f32>,  surface_0 : Surface,  is_inside_1 : bool,  dir_2 : vec3<f32>) -> vec3<f32>
{
    var _S129 : bool = wrongSide_0(is_inside_1, false, dir_2, surface_0.geometry_n);
    var _S130 : bool = is_inside_1 != _S129;
    var _S131 : vec3<f32> = (vec3<f32>(0) - surface_0.smooth_n);
    var _S132 : vec3<f32> = select(surface_0.smooth_n, _S131, _S130);
    var _S133 : Ray = Ray_x24init_0(origin_1 + vec3<f32>(surface_0.geometry_offset) * _S132, dir_2);
    var _S134 : vec3<f32> = (env_map_sample((dir_2)));
    var _S135 : vec3<f32> = (shadowTransmittance((_S133), (4.294967296e+09f)));
    return _S134 * _S135;
}

fn searchCDF_0( start_3 : vec2<u32>,  step_0 : vec2<u32>,  count_0 : u32,  u_0 : f32) -> u32
{
    var _S136 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S136;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S137 : u32 = (low_0 + high_0) / u32(2);
        var _S138 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S137)), 0));
        var _S139 : bool = (_S138.x) > u_0;
        if(_S139)
        {
            high_0 = _S137;
        }
        else
        {
            var _S140 : u32 = _S137 + u32(1);
            low_0 = _S140;
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
    var _S141 : vec3<f32> = (normalize((light_dir_0)));
    var _S142 : bool = (dot(smooth_n_0, _S141)) < 0.0f;
    if(_S142)
    {
        return vec3<f32>(0.0f);
    }
    var _S143 : vec3<f32> = origin_2 + vec3<f32>(geometry_offset_0) * smooth_n_0;
    var _S144 : Ray = Ray_x24init_0(_S143, _S141);
    var _S145 : f32 = shadowLength(light_dir_0);
    var _S146 : vec3<f32> = (shadowTransmittance((_S144), (_S145)));
    return _S146;
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
    var _S147 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S148 : bool = cos_a_0 > cos_b_0;
    var _S149 : f32 = select(_S147, 1.0f, _S148);
    return _S149;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S150 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S151 : bool = cos_a_1 > cos_b_1;
    var _S152 : f32 = select(_S150, 0.0f, _S151);
    return _S152;
}

fn importance( node_0 : LightBounds,  p_7 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S153 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S154 : vec3<f32> = node_0.high - node_0.low;
    var _S155 : vec3<f32> = p_7 - _S153;
    var _S156 : vec3<f32> = (normalize((_S155)));
    var _S157 : f32 = dot(_S155, _S155);
    var _S158 : f32 = dot(_S154, _S154) / 4.0f;
    var _S159 : f32 = abs(dot(node_0.w, _S156));
    var _S160 : f32 = sine(node_0.cos_theta_o);
    var _S161 : f32 = sqrt(max(1.0f - _S158 / _S157, 0.0f));
    var _S162 : bool = _S157 < _S158;
    var _S163 : f32 = select(_S161, -1.0f, _S162);
    var _S164 : f32 = sine(_S163);
    var _S165 : f32 = sine(_S159);
    var _S166 : f32 = cosSubClamped(_S165, _S159, _S160, node_0.cos_theta_o);
    var _S167 : f32 = sine(_S159);
    var _S168 : f32 = sinSubClamped(_S167, _S159, _S160, node_0.cos_theta_o);
    var _S169 : f32 = cosSubClamped(_S168, _S166, _S164, _S163);
    var _S170 : bool = _S169 <= 0.0f;
    if(_S170)
    {
        return 0.0f;
    }
    var _S171 : f32 = - dot(_S156, normal_0);
    var _S172 : f32 = node_0.phi * _S169 / max(_S157, length(_S154) / 2.0f);
    var _S173 : f32 = sine(_S171);
    var _S174 : f32 = cosSubClamped(_S173, _S171, _S164, _S163);
    var _S175 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S176 : f32 = select(_S174, 1.0f, _S175);
    return max(_S172 * _S176, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_8 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S177 : f32 = importance(first_0, p_8, normal_1);
    var _S178 : f32 = importance(second_0, p_8, normal_1);
    var _S179 : vec2<f32> = vec2<f32>(_S177, _S178);
    var _S180 : f32 = _S179[child_0] / (_S177 + _S178);
    var _S181 : bool = (_S179[child_0]) > 0.0f;
    var _S182 : f32 = select(0.0f, _S180, _S181);
    return _S182;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_9 : vec3<f32>) -> f32
{
    var _S183 : vec3<f32> = center_0 - p_9;
    var _S184 : f32 = radius_0 * radius_0 / dot(_S183, _S183);
    var _S185 : bool = _S184 >= 1.0f;
    if(_S185)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S184)) / (6.28318548202514648f * _S184);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_3 : vec3<f32>,  smooth_n_1 : vec3<f32>,  start_4 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S186 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S187 : vec2<u32> = _S186.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S187;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S188 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S188.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S189 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S190 : u32 = n_0 + u32(1);
        var _S191 : LightBounds = (lightBounds((_S190)));
        var _S192 : LightBounds = (lightBounds((_S189)));
        var _S193 : u32 = trail_0.x;
        var _S194 : u32 = (_S193 & (u32(1)));
        var _S195 : f32 = childShare(_S191, _S192, origin_3, smooth_n_1, _S194);
        var probability_2 : f32 = probability_1 * _S195;
        var _S196 : bool = _S194 == u32(1);
        var _S197 : u32 = select(_S190, _S189, _S196);
        var _S198 : u32 = trail_0.y;
        var _S199 : vec2<u32> = vec2<u32>((((_S193 >> (u32(1)))) | (((_S198 << (u32(31)))))), (_S198 >> (u32(1))));
        n_0 = _S197;
        trail_0 = _S199;
        probability_1 = probability_2;
    }
    var _S200 : bool = (((_S186).z == (n_0)));
    var _S201 : bool = !_S200;
    var _S202 : bool;
    if(_S201)
    {
        _S202 = true;
    }
    else
    {
        var _S203 : LightBounds = (lightBounds((n_0)));
        var _S204 : f32 = importance(_S203, origin_3, smooth_n_1);
        _S202 = !(_S204 > 0.0f);
    }
    if(_S202)
    {
        _S202 = true;
    }
    else
    {
        var _S205 : bool = (dot(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S205)
        {
            _S202 = !((dot(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S202 = false;
        }
    }
    if(_S202)
    {
        return 0.0f;
    }
    var _S206 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S207 : bool = (_S206.x) == u32(2);
    if(_S207)
    {
        var _S208 : u32 = _S206.y;
        var _S209 : Light = (lights[(_S208)]);
        var _S210 : Light = (lights[(_S208)]);
        var _S211 : f32 = sphereDensity(_S209.position, _S210.variance, start_4);
        return probability_1 * _S211;
    }
    var _S212 : u32 = _S206.y;
    var _S213 : u32 = ((instance_uint[(_S212) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S214 : mat3x3<f32> = (worldTriangle((_S212), (_S213 + _S206.z)));
    var _S215 : f32 = solidAngle(probability_1, cross(_S214[i32(1)] - _S214[i32(0)], _S214[i32(2)] - _S214[i32(0)]), light_point_0 - start_4);
    return _S215;
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
    var _S216 : Random;
    _S216.state = state_0;
    _S216.value = value_0;
    return _S216;
}

fn pcg( state_1 : u32) -> Random
{
    var _S217 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S218 : u32 = hash(state_1);
    return Random_x24init_0(_S217, f32(_S218) / 4.294967296e+09f);
}

fn environmentPdf_0( dir_3 : vec3<f32>) -> f32
{
    var _S219 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S220 : vec2<u32> = _S219 - vec2<u32>(u32(1), u32(0));
    var _S221 : vec2<f32> = vec2<f32>(atan2(- dir_3.z, - dir_3.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_3.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S222 : vec2<u32> = min(vec2<u32>(_S221 * vec2<f32>(_S220)), _S220 - vec2<u32>(u32(1)));
    var _S223 : vec4<f32> = (textureLoad(environment_cdf, (_S222), 0));
    var _S224 : f32 = _S223.y;
    var _S225 : u32 = _S220.x;
    var _S226 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S225, _S222.y)), 0));
    var _S227 : f32 = _S224 * _S226.y;
    return _S227 * f32(_S225 * _S220.y) / (19.73921012878417969f * length(dir_3.xz));
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
    var _S228 : AnisotropicFrame;
    _S228.tangent = tangent_0;
    _S228.alphas = alphas_0;
    return _S228;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S229 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S229)
    {
        const _S230 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S230;
    }
    else
    {
        a_2 = a_1;
    }
    var _S231 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S232 : vec3<f32> = cross(n_1, _S231);
    return vec3<f32>(v_0.x) * _S231 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S232;
}

fn anisotropicFrame( material_0 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S233 : f32 = material_0.roughness;
    var _S234 : f32 = _S233 * _S233;
    var _S235 : bool = (material_0.anisotropy) == 0.0f;
    var _S236 : bool;
    if(_S235)
    {
        _S236 = true;
    }
    else
    {
        _S236 = !(_S234 > 0.0f);
    }
    if(_S236)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S237 : vec3<f32> = material_0.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_0.tangent));
    var _S238 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S239 : bool = (dot(_S237, _S237)) > 0.0f;
    var _S240 : vec3<f32> = select(_S238, _S237, _S239);
    var _S241 : vec3<f32> = (normalize((_S240)));
    var _S242 : f32 = 6.28318548202514648f * material_0.anisotropic_rotation;
    var _S243 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_0.anisotropy));
    var _S244 : f32 = 1.0f / _S243;
    var _S245 : bool = (material_0.anisotropy) < 0.0f;
    var _S246 : f32 = select(_S243, _S244, _S245);
    return AnisotropicFrame_x24init_0(_S241 * vec3<f32>(cos(_S242)) + cross(n_i_0, _S241) * vec3<f32>(sin(_S242)), vec2<f32>(_S234 / _S246, _S234 * _S246));
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S247 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S248 : f32 = _S247.x;
    var _S249 : f32 = _S247.y;
    var _S250 : f32 = _S248 * _S248 + _S249 * _S249;
    const _S251 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S252 : vec3<f32> = vec3<f32>(- _S249, _S248, 0.0f);
    var _S253 : f32 = (inverseSqrt((_S250)));
    var _S254 : vec3<f32> = _S252 * vec3<f32>(_S253);
    var _S255 : bool = _S250 > 0.0f;
    var _S256 : vec3<f32> = select(_S251, _S254, _S255);
    var _S257 : vec3<f32> = cross(_S247, _S256);
    var _S258 : f32 = sqrt(U1_0);
    var _S259 : f32 = 6.28318548202514648f * U2_0;
    var _S260 : f32 = _S258 * cos(_S259);
    var t2_0 : f32 = _S258 * sin(_S259);
    var _S261 : f32 = 0.5f * (1.0f + _S247.z);
    var t2_1 : f32 = (1.0f - _S261) * sqrt(max(0.0f, 1.0f - _S260 * _S260)) + _S261 * t2_0;
    var _S262 : vec3<f32> = vec3<f32>(_S260) * _S256 + vec3<f32>(t2_1) * _S257;
    var _S263 : f32 = ((_S260));
    var _S264 : f32 = ((_S260));
    var _S265 : vec3<f32> = _S262 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S263 * _S264 - t2_1 * t2_1))) * _S247;
    var _S266 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S265.x, alpha_0 * _S265.y, max(0.0f, _S265.z)))));
    return _S266;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S267 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S267)
    {
        const _S268 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S268;
    }
    else
    {
        a_4 = a_3;
    }
    var _S269 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S270 : vec3<f32> = cross(n_3, _S269);
    return vec3<f32>(dot(v_1, _S269), dot(v_1, n_3), dot(v_1, _S270));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S271 : Random = pcg((*random_state_0));
    var _S272 : Random = pcg(_S271.state);
    (*random_state_0) = _S272.state;
    var _S273 : f32 = frame_0.alphas.x;
    var _S274 : bool = _S273 > 0.0f;
    if(_S274)
    {
        var _S275 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S276 : f32 = frame_0.alphas.y;
        var _S277 : vec3<f32> = (normalize((vec3<f32>(_S273 * _S275.x, _S276 * _S275.y, _S275.z))));
        var _S278 : vec3<f32> = sampleGGXVNDF(_S277, 1.0f, _S271.value, _S272.value);
        var _S279 : vec3<f32> = (normalize((vec3<f32>(_S273 * _S278.x, _S276 * _S278.y, _S278.z))));
        return vec3<f32>(_S279.x) * frame_0.tangent + vec3<f32>(_S279.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S279.z) * n_i_1;
    }
    var _S280 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S281 : vec3<f32> = sampleGGXVNDF(_S280.xzy, alpha_1, _S271.value, _S272.value);
    var _S282 : vec3<f32> = _S281.xzy;
    var _S283 : vec3<f32> = tangentToWorld(_S282, n_i_1);
    return _S283;
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
    var _S284 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S285 : f32 = eta_i_0 / eta_o_0 * _S284;
    var _S286 : bool = _S285 < 1.0f;
    var kr_0 : f32;
    if(_S286)
    {
        var _S287 : f32 = sqrt(max(0.0f, 1.0f - _S285 * _S285));
        var _S288 : f32 = eta_o_0 * cos_theta_0;
        var _S289 : f32 = eta_i_0 * _S287;
        var _S290 : f32 = (_S288 - _S289) / (_S288 + _S289);
        var _S291 : f32 = eta_i_0 * cos_theta_0;
        var _S292 : f32 = eta_o_0 * _S287;
        var _S293 : f32 = (_S291 - _S292) / (_S291 + _S292);
        var _S294 : f32 = (_S290 * _S290 + _S293 * _S293) / 2.0f;
        kr_0 = _S294;
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
    var _S295 : f32 = sqrt(0.05000000074505806f);
    var _S296 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S297 : f32 = (clamp(sqrt(max(r_2, 0.0f)), _S295, 1.0f) - _S295) / (1.0f - _S295) * 23.0f;
    var _S298 : u32 = min(u32(_S296), u32(22));
    var _S299 : u32 = min(u32(_S297), u32(22));
    var _S300 : f32 = _S296 - f32(_S298);
    var _S301 : f32 = _S297 - f32(_S299);
    var _S302 : u32 = _S298 * u32(24) + _S299;
    var _S303 : u32 = _S302 + u32(24);
    var _S304 : f32 = SHEEN_ALBEDO_0[_S302] + (SHEEN_ALBEDO_0[_S303] - SHEEN_ALBEDO_0[_S302]) * _S300;
    var _S305 : u32 = _S302 + u32(1);
    var _S306 : f32 = SHEEN_ALBEDO_0[_S305] + (SHEEN_ALBEDO_0[_S303 + u32(1)] - SHEEN_ALBEDO_0[_S305]) * _S300;
    return exp(_S304 + (_S306 - _S304) * _S301);
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S307 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S307 / (_S307 + length(vec3<f32>(alphas_1.x * w_2.x, alphas_1.y * w_2.y, _S307)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S308 : f32 = alphas_2.x;
    var _S309 : f32 = h_0.x / _S308;
    var _S310 : f32 = alphas_2.y;
    var _S311 : f32 = h_0.y / _S310;
    var _S312 : f32 = h_0.z;
    var _S313 : f32 = _S309 * _S309 + _S311 * _S311 + _S312 * _S312;
    return 1.0f / max(3.14159274101257324f * _S308 * _S310 * _S313 * _S313, 1.17549435082228751e-38f);
}

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_3 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S314 : BSDFLobes;
    _S314.v_dot_h = v_dot_h_0;
    _S314.n_dot_h = n_dot_h_0;
    _S314.refracted = refracted_1;
    _S314.F = F_0;
    _S314.F_greyscale = F_greyscale_0;
    _S314.reflect_weight = reflect_weight_0;
    _S314.diffuse_weight = diffuse_weight_0;
    _S314.refract_weight = refract_weight_0;
    _S314.p_diffuse = p_diffuse_0;
    _S314.p_reflect = p_reflect_0;
    _S314.p_refract = p_refract_0;
    _S314.translucent_share = translucent_share_0;
    _S314.sheen = sheen_0;
    _S314.view = view_1;
    _S314.tangent = tangent_1;
    _S314.alphas = alphas_3;
    _S314.visible = visible_0;
    return _S314;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S315 : f32 = dot(ggx_n_0, v_3);
    var _S316 : f32 = dot(n_i_2, ggx_n_0);
    var _S317 : f32 = eta_i_1 / eta_o_1;
    var _S318 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S317))));
    var _S319 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S320 : f32 = _S319 * _S319;
    var _S321 : f32 = (1.0f + _S319) / (1.0f - _S319);
    var _S322 : f32 = abs(_S315);
    var _S323 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S323)
    {
        sheen_component_0 = _S321;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S323)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S321;
    }
    var _S324 : f32 = fresnel(_S322, sheen_component_0, visible_1);
    var _S325 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S315 * _S315)) >= (eta_o_1 * eta_o_1);
    var _S326 : vec3<f32>;
    if(_S325)
    {
        _S326 = vec3<f32>(1.0f);
    }
    else
    {
        var _S327 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S320);
        _S326 = _S327 + (vec3<f32>(1.0f) - _S327) * vec3<f32>((_S324 - _S320)) / vec3<f32>((1.0f - _S320));
    }
    var _S328 : vec3<f32> = vec3<f32>(1.0f);
    var _S329 : vec3<f32> = vec3<f32>(0.0f);
    var _S330 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S331 : bool = _S330 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S331)
    {
        var _S332 : f32 = sheenAlbedo(dot(n_i_2, v_3), material_1.sheen_roughness);
        var _S333 : f32 = min(_S332, 1.0f);
        var _S334 : vec3<f32> = vec3<f32>(1.0f) - material_1.sheen * vec3<f32>(_S333);
        var _S335 : f32 = rgb_to_greyscale(material_1.sheen);
        var _S336 : f32 = _S335 * _S333;
        var _S337 : vec3<f32> = material_1.sheen / vec3<f32>(max(_S332, 1.0f));
        scale_0 = _S334;
        sheen_component_0 = _S336;
        sheen_1 = _S337;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S328;
        sheen_component_0 = 0.0f;
        sheen_1 = _S329;
        view_2 = _S329;
    }
    var _S338 : vec3<f32> = (mix((_S326), (material_1.albedo), (material_1.metallic)));
    var F_1 : vec3<f32> = _S338 * scale_0;
    var _S339 : f32 = rgb_to_greyscale(F_1);
    var _S340 : f32 = 1.0f - material_1.metallic;
    var _S341 : vec3<f32> = vec3<f32>(1.0f) - _S326;
    var _S342 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S340)) * _S341 * scale_0;
    var _S343 : vec3<f32> = vec3<f32>((material_1.transmission * _S340)) * _S341 * scale_0;
    var _S344 : f32 = max(_S339, 0.0f);
    var _S345 : f32 = rgb_to_greyscale(_S342);
    var _S346 : f32 = max(_S345, 0.0f);
    var _S347 : f32 = rgb_to_greyscale(_S343);
    var _S348 : f32 = (sign((length(_S318))));
    var _S349 : f32 = max(_S347 * _S348, 0.0f);
    var _S350 : f32 = _S344 + _S346 + _S349 + sheen_component_0;
    var _S351 : f32 = 1.0f / max(_S350, 0.0000152587890625f);
    var _S352 : f32 = (_S346 + sheen_component_0) * _S351;
    var _S353 : f32 = _S344 * _S351;
    var _S354 : f32 = _S349 * _S351;
    var _S355 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S355)
    {
        var _S356 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S357 : f32 = anisotropicG1(_S356, frame_1.alphas);
        var _S358 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S359 : f32 = anisotropicD(_S358, frame_1.alphas);
        var _S360 : f32 = _S357 * _S359;
        visible_1 = _S360;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S315, _S316, _S318, F_1, _S339, 1.0f, _S342, _S343, _S352, _S353, _S354, 0.0f, sheen_1, view_2, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S361 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S362 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S363 : f32 = _S361 / (_S362 + _S361);
    var _S364 : bool = _S361 > 0.0f;
    var _S365 : f32 = select(0.0f, _S363, _S364);
    return _S365;
}

fn smithG1( alpha_2 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S366 : f32 = alpha_2 * alpha_2;
    var _S367 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S366 + (1.0f - _S366) * n_dot_x_0 * n_dot_x_0));
    var _S368 : bool = alpha_2 > 0.0f;
    var _S369 : f32 = select(1.0f, _S367, _S368);
    return _S369;
}

fn trowbridgeReitz( alpha_3 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S370 : f32 = alpha_3 * alpha_3;
    var _S371 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S370 * n_dot_h_1 * n_dot_h_1;
    return _S370 / max(3.14159274101257324f * _S371 * _S371, 1.17549435082228751e-38f);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S372 : bool = lobe_0 == u32(0);
    if(_S372)
    {
        var _S373 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S374 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S375 : f32 = 1.0f - lobes_0.translucent_share;
        var _S376 : bool = n_i_dot_l_0 < 0.0f;
        var _S377 : f32 = select(_S375, lobes_0.translucent_share, _S376);
        var _S378 : f32 = _S374 * _S377;
        var _S379 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S380 : f32 = select(_S373, _S378, _S379);
        var _S381 : bool = n_i_dot_v_0 > 0.0f;
        var _S382 : f32 = select(0.0f, _S380, _S381);
        return _S382;
    }
    var _S383 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S384 : f32 = _S383 * lobes_0.v_dot_h;
    var _S385 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S386 : f32 = _S384 * _S385 / n_i_dot_v_0;
    var _S387 : bool = alpha_4 > 0.0f;
    var _S388 : bool;
    if(_S387)
    {
        _S388 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S388 = false;
    }
    if(_S388)
    {
        _S388 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S388 = false;
    }
    if(_S388)
    {
        _S388 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S388 = false;
    }
    var _S389 : f32 = select(0.0f, _S386, _S388);
    var _S390 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S390)
    {
        var _S391 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S392 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S392)
        {
            _S388 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S388 = false;
        }
        if(_S388)
        {
            _S388 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S388 = false;
        }
        var _S393 : f32 = select(0.0f, _S391, _S388);
        pdf_h_0 = _S393;
    }
    else
    {
        pdf_h_0 = _S389;
    }
    var _S394 : bool = lobe_0 == u32(1);
    if(_S394)
    {
        var _S395 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S396 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S395 * _S395);
        var _S397 : bool = eta_i_2 != eta_o_2;
        if(_S397)
        {
            _S388 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S388 = false;
        }
        var _S398 : f32 = select(0.0f, _S396, _S388);
        return _S398;
    }
    var _S399 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S400 : bool = pdf_h_0 > 0.0f;
    var _S401 : f32 = select(0.0f, _S399, _S400);
    return _S401;
}

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_1 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S402 : SampleBSDF;
    _S402.unit_direction = unit_direction_1;
    _S402.throughput = throughput_0;
    _S402.random_state = random_state_1;
    _S402.refracted = refracted_2;
    _S402.lobe = lobe_1;
    _S402.pdf = pdf_0;
    return _S402;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_4 : vec3<f32>,  n_4 : vec3<f32>,  r_3 : f32) -> f32
{
    var _S403 : f32 = 1.0f / max(r_3, 0.05000000074505806f);
    var _S404 : vec3<f32> = (normalize((l_0 + v_4)));
    var _S405 : f32 = dot(n_4, _S404);
    var _S406 : f32 = max(dot(n_4, l_0), 0.0f);
    var _S407 : f32 = max(dot(n_4, v_4), 0.0f);
    return (2.0f + _S403) * pow(max(1.0f - _S405 * _S405, 0.0f), 0.5f * _S403) * 0.5f * 0.31830987334251404f / max(4.0f * (_S406 + _S407 - _S406 * _S407), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes,  lobe_2 : u32) -> vec3<f32>
{
    var _S408 : bool = lobe_2 == u32(0);
    if(_S408)
    {
        var _S409 : bool = (dot(n_i_3, l_1)) < 0.0f;
        var _S410 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S409);
        var _S411 : f32 = 1.0f - lobes_1.translucent_share;
        var _S412 : f32 = select(_S411, lobes_1.translucent_share, _S409);
        var _S413 : vec3<f32> = _S410 / vec3<f32>(_S412);
        var _S414 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S415 : vec3<f32> = select(material_3.albedo, _S413, _S414);
        var _S416 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S417 : bool = _S416 > 0.0f;
        var _S418 : bool;
        if(_S417)
        {
            _S418 = !_S409;
        }
        else
        {
            _S418 = false;
        }
        if(_S418)
        {
            var _S419 : vec3<f32> = lobes_1.diffuse_weight * _S415;
            var _S420 : vec3<f32> = lobes_1.sheen * vec3<f32>(3.14159274101257324f);
            var _S421 : f32 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            var _S422 : vec3<f32> = _S420 * vec3<f32>(_S421);
            var _S423 : f32 = select(1.0f, _S411, _S414);
            return (_S419 + _S422 / vec3<f32>(_S423)) / vec3<f32>(lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S415 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S424 : bool = lobe_2 == u32(1);
    var G1_l_0 : f32;
    if(_S424)
    {
        var _S425 : f32 = - dot(n_i_3, l_1);
        var _S426 : f32 = smithG1(alpha_5, max(_S425, 0.0f));
        var _S427 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S427)
        {
            var _S428 : vec3<f32> = ((-(n_i_3)));
            var _S429 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, _S428);
            var _S430 : f32 = anisotropicG1(_S429, lobes_1.alphas);
            G1_l_0 = _S430;
        }
        else
        {
            G1_l_0 = _S426;
        }
        return lobes_1.refract_weight * vec3<f32>(G1_l_0) * material_3.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S431 : f32 = dot(n_i_3, l_1);
    var _S432 : f32 = smithG1(alpha_5, max(_S431, 0.0f));
    var _S433 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S433)
    {
        var _S434 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        var _S435 : f32 = anisotropicG1(_S434, lobes_1.alphas);
        G1_l_0 = _S435;
    }
    else
    {
        G1_l_0 = _S432;
    }
    return vec3<f32>((lobes_1.reflect_weight * G1_l_0)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S436 : vec3<f32> = ((-(in_dir_1)));
    var _S437 : f32 = dot(n_5, _S436);
    var _S438 : f32 = (sign((_S437)));
    var _S439 : vec3<f32> = n_5 * vec3<f32>(_S438);
    var _S440 : f32 = material_4.roughness;
    var _S441 : f32 = _S440 * _S440;
    var _S442 : AnisotropicFrame = anisotropicFrame(material_4, _S439);
    var _S443 : vec3<f32> = (normalize((_S436 + out_dir_0)));
    var _S444 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S444)
    {
        var _S445 : vec3<f32> = sampleHalfVector(_S436, _S439, _S441, _S442, &(random_state_2));
        ggx_n_1 = _S445;
    }
    else
    {
        var _S446 : bool = lobe_3 == u32(1);
        if(_S446)
        {
            var _S447 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S436 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S448 : vec3<f32> = (normalize((_S447)));
            var _S449 : f32 = (sign((dot(_S447, _S439))));
            var _S450 : vec3<f32> = _S448 * vec3<f32>(_S449);
            ggx_n_1 = _S450;
        }
        else
        {
            ggx_n_1 = _S443;
        }
    }
    var _S451 : BSDFLobes = bsdfLobes(in_dir_1, _S436, _S439, ggx_n_1, material_4, eta_i_3, eta_o_3, _S442);
    var lobes_2 : BSDFLobes = _S451;
    var _S452 : f32 = translucentShare(material_4);
    lobes_2.translucent_share = _S452;
    var _S453 : f32 = lobeDensity(dot(_S439, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S437), _S441, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S454 : bool = !(_S453 > 0.0f);
    if(_S454)
    {
        var _S455 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S455, _S455, u32(0), false, u32(0), 0.0f);
    }
    var _S456 : vec3<f32> = lobeThroughput(out_dir_0, _S439, _S441, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S456, random_state_2, lobe_3 == u32(1), lobe_3, _S453);
}

fn neeBSDF( in_dir_2 : vec3<f32>,  dir_4 : vec3<f32>,  n_6 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_3 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var _S457 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_1 : vec3<f32> = _S457;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S458 : bool = lobe_4 == u32(0);
        if(_S458)
        {
        }
        var _S459 : bool;
        if(_S458)
        {
            var _S460 : f32 = rgb_to_greyscale(material_5.translucent);
            _S459 = _S460 > 0.0f;
        }
        else
        {
            _S459 = false;
        }
        var _S461 : bool;
        if(_S459)
        {
            var _S462 : f32 = dot(n_6, dir_4);
            var _S463 : vec3<f32> = ((-(in_dir_2)));
            _S461 = ((_S462 * dot(n_6, _S463)) < 0.0f) == refracted_3;
        }
        else
        {
            _S461 = (lobe_4 == u32(1)) == refracted_3;
        }
        var f_2 : vec3<f32>;
        if(_S461)
        {
            var _S464 : SampleBSDF = connectBSDF(in_dir_2, dir_4, n_6, material_5, eta_i_4, eta_o_4, lobe_4, random_state_3);
            var _S465 : bool = (_S464.pdf) > 0.0f;
            if(_S465)
            {
                if(power_0)
                {
                    var _S466 : f32 = _S464.pdf / pdf_1;
                    var f_3 : vec3<f32> = f_1 + _S464.throughput * vec3<f32>(_S464.pdf) / vec3<f32>((pdf_1 * (1.0f + _S466 * _S466)));
                    f_2 = f_3;
                }
                else
                {
                    var f_4 : vec3<f32> = f_1 + _S464.throughput * vec3<f32>(_S464.pdf) / vec3<f32>((_S464.pdf + pdf_1));
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
    var _S467 : bool = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    var _S468 : vec3<f32> = neeBSDF(in_dir_3, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S467, pdf_2, false, random_state_4);
    return _S468;
}

fn SkySample_x24init_0( dir_6 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S469 : SkySample;
    _S469.dir = dir_6;
    _S469.radiance = radiance_1;
    _S469.color = color_0;
    _S469.random_state = random_state_5;
    return _S469;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S470 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S471 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S472 : vec2<u32> = _S470 - _S471;
    var _S473 : Random = pcg(init_random_state_0);
    var _S474 : Random = pcg(_S473.state);
    var _S475 : Random = pcg(_S474.state);
    var _S476 : Random = pcg(_S475.state);
    var _S477 : u32 = _S472.x;
    var _S478 : u32 = searchCDF_0(vec2<u32>(_S477, u32(0)), vec2<u32>(u32(0), u32(1)), _S472.y, _S473.value);
    var _S479 : u32 = searchCDF_0(vec2<u32>(u32(0), _S478), _S471, _S477, _S474.value);
    var _S480 : vec2<f32> = (vec2<f32>(f32(_S479), f32(_S478)) + vec2<f32>(_S475.value, _S476.value)) / vec2<f32>(_S472) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S481 : f32 = _S480.y;
    var _S482 : f32 = sin(_S481);
    var _S483 : f32 = _S480.x;
    var _S484 : vec3<f32> = vec3<f32>(_S482 * cos(_S483), cos(_S481), _S482 * sin(_S483));
    var _S485 : f32 = environmentPdf_0(_S484);
    var _S486 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S484, surface_2, eta_1, is_inside_3, _S485, lobe_state_0);
    var _S487 : bool = !(_S485 > 0.0f);
    var _S488 : bool;
    if(_S487)
    {
        _S488 = true;
    }
    else
    {
        _S488 = (all((_S486 == vec3<f32>(0.0f))));
    }
    if(_S488)
    {
        var _S489 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S484, _S489, _S489, _S476.state);
    }
    var _S490 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S484);
    return SkySample_x24init_0(_S484, _S490, _S486 * _S490, _S476.state);
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
    var _S491 : TreeSample;
    _S491.dir = dir_7;
    _S491.radiance = radiance_2;
    _S491.density = density_0;
    _S491.random_state = random_state_6;
    return _S491;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S492 : f32 = importance(first_1, p_10, normal_3);
    var _S493 : f32 = importance(second_1, p_10, normal_3);
    var _S494 : vec2<f32> = vec2<f32>(_S492, _S493);
    var _S495 : bool = _S492 == 0.0f;
    var _S496 : bool;
    if(_S495)
    {
        _S496 = _S493 == 0.0f;
    }
    else
    {
        _S496 = false;
    }
    if(_S496)
    {
        return u32(2);
    }
    var _S497 : f32 = _S492 + _S493;
    var _S498 : bool = _S493 > 0.0f;
    if(_S498)
    {
        _S496 = ((*pick_0) * _S497) >= _S492;
    }
    else
    {
        _S496 = false;
    }
    var _S499 : u32 = select(u32(0), u32(1), _S496);
    var _S500 : f32 = min(((*pick_0) * _S497 - f32(_S499) * _S492) / _S494[_S499], 0.99999994039535522f);
    (*pick_0) = _S500;
    var _S501 : f32 = (*probability_3) * (_S494[_S499] / _S497);
    (*probability_3) = _S501;
    return _S499;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S502 : vec3<f32> = center_1 - p_11;
    var _S503 : f32 = radius_1 * radius_1 / dot(_S502, _S502);
    var _S504 : f32 = u1_0 * _S503 / (1.0f + sqrt(max(1.0f - _S503, 0.0f)));
    var _S505 : f32 = 2.0f * u1_0;
    var _S506 : bool = _S503 >= 1.0f;
    var _S507 : f32 = select(_S504, _S505, _S506);
    var _S508 : f32 = sqrt(max(_S507 * (2.0f - _S507), 0.0f));
    var _S509 : f32 = 6.28318548202514648f * u2_0;
    var _S510 : vec3<f32> = vec3<f32>(_S508 * cos(_S509), 1.0f - _S507, _S508 * sin(_S509));
    var _S511 : vec3<f32> = (normalize((_S502)));
    var _S512 : vec3<f32> = tangentToWorld(_S510, _S511);
    return _S512;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S513 : vec3<f32> = center_2 - ray_1.origin;
    var _S514 : f32 = dot(_S513, ray_1.unit_direction);
    var _S515 : f32 = dot(_S513, _S513) - _S514 * _S514;
    var _S516 : f32 = radius_3 * radius_3;
    var _S517 : bool = _S515 > _S516;
    if(_S517)
    {
        return 4.294967296e+09f;
    }
    var _S518 : f32 = sqrt(_S516 - _S515);
    var _S519 : f32 = _S514 - _S518;
    var _S520 : f32 = _S514 + _S518;
    var _S521 : bool = _S519 > 0.0000152587890625f;
    var _S522 : bool;
    if(_S521)
    {
        _S522 = _S519 < max_len_0;
    }
    else
    {
        _S522 = false;
    }
    if(_S522)
    {
        return _S519;
    }
    var _S523 : bool = _S520 > 0.0000152587890625f;
    if(_S523)
    {
        _S522 = _S520 < max_len_0;
    }
    else
    {
        _S522 = false;
    }
    if(_S522)
    {
        return _S520;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S524 : Random = pcg(init_random_state_1);
    var _S525 : Random = pcg(_S524.state);
    var _S526 : Random = pcg(_S525.state);
    var _S527 : vec3<f32> = vec3<f32>(0.0f);
    var _S528 : TreeSample = TreeSample_x24init_0(_S527, _S527, 0.0f, _S526.state);
    var sample_0 : TreeSample = _S528;
    var _S529 : vec3<f32> = select(smooth_n_2, _S527, sided_0);
    var _S530 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S531 : vec3<f32> = origin_4 + _S530 * smooth_n_2;
    var pick_1 : f32 = _S524.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S532 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S532.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S533 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S534 : u32 = n_7 + u32(1);
        var _S535 : LightBounds = (lightBounds((_S534)));
        var _S536 : LightBounds = (lightBounds((_S533)));
        var _S537 : u32 = pickChild(_S535, _S536, origin_4, _S529, &(pick_1), &(probability_4));
        var _S538 : bool = _S537 > u32(1);
        if(_S538)
        {
            return sample_0;
        }
        var _S539 : bool = _S537 == u32(1);
        var _S540 : u32 = select(_S534, _S533, _S539);
        n_7 = _S540;
    }
    var _S541 : bool = n_7 == u32(0);
    var _S542 : bool;
    if(_S541)
    {
        var _S543 : LightBounds = (lightBounds((u32(0))));
        var _S544 : f32 = importance(_S543, origin_4, _S529);
        _S542 = !(_S544 > 0.0f);
    }
    else
    {
        _S542 = false;
    }
    if(_S542)
    {
        return sample_0;
    }
    var _S545 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S546 : bool = (_S545.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S546)
    {
        var _S547 : Light = (lights[(_S545.y)]);
        if(sided_0)
        {
            var _S548 : f32 = (sign((dot(geometry_n_1, _S547.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S548);
            var _S549 : vec3<f32> = origin_4 + _S530 * lift_n_1;
            start_5 = _S549;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S531;
            lift_n_0 = smooth_n_2;
        }
        var _S550 : bool = (_S547.variance) == 0.0f;
        if(_S550)
        {
            var _S551 : vec3<f32> = _S547.position - start_5;
            var _S552 : vec3<f32> = (normalize((_S551)));
            sample_0.dir = _S552;
            var _S553 : vec3<f32> = _S547.color * vec3<f32>(_S547.intensity) / vec3<f32>((dot(_S551, _S551) * probability_4));
            sample_0.radiance = _S553;
            shadow_1 = _S551;
        }
        else
        {
            var _S554 : vec3<f32> = sampleSphere(_S547.position, _S547.variance, start_5, _S525.value, _S526.value);
            sample_0.dir = _S554;
            var _S555 : f32 = sphereDensity(_S547.position, _S547.variance, start_5);
            var _S556 : f32 = probability_4 * _S555;
            sample_0.density = _S556;
            var _S557 : vec3<f32> = pointLightRadiance(_S547.color, _S547.intensity, _S547.variance);
            var _S558 : vec3<f32> = _S557 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S558;
            var _S559 : f32 = raySphere_0(_S547.position, _S547.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S560 : vec3<f32> = sample_0.dir * vec3<f32>(_S559);
            shadow_1 = _S560;
        }
    }
    else
    {
        var _S561 : u32 = _S545.y;
        var _S562 : u32 = ((instance_uint[(_S561) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S563 : u32 = _S562 + _S545.z;
        var _S564 : mat3x3<f32> = (worldTriangle((_S561), (_S563)));
        var _S565 : f32 = sqrt(_S525.value);
        var _S566 : vec2<f32> = vec2<f32>(_S565 * (1.0f - _S526.value), _S565 * _S526.value);
        var _S567 : vec3<f32> = (((_S564) * (vec3<f32>(1.0f - _S565, _S566))));
        if(sided_0)
        {
            var _S568 : f32 = (sign((dot(geometry_n_1, _S567 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S568);
            var _S569 : vec3<f32> = origin_4 + _S530 * lift_n_2;
            start_5 = _S569;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S570 : bool = !((dot(smooth_n_2, _S567 - origin_4)) > 0.0f);
            if(_S570)
            {
                return sample_0;
            }
            start_5 = _S531;
            lift_n_0 = smooth_n_2;
        }
        var _S571 : Surface = (surfaceAt((Hit_x24init_0(_S566, _S561, _S563, u32(0), 0.0f)), (_S567), (_S526.state)));
        sample_0.random_state = _S571.random_state;
        var _S572 : vec3<f32> = _S567 - start_5;
        var _S573 : vec3<f32> = (normalize((_S572)));
        sample_0.dir = _S573;
        var _S574 : f32 = solidAngle(probability_4, cross(_S564[i32(1)] - _S564[i32(0)], _S564[i32(2)] - _S564[i32(0)]), _S572);
        sample_0.density = _S574;
        var _S575 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S571.smooth_n))));
        var _S576 : vec3<f32> = _S571.material.emissive * vec3<f32>(max(_S575, 0.0f));
        var _S577 : vec3<f32> = select(_S576, _S527, _S571.skip);
        var _S578 : vec3<f32> = _S577 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S578;
        shadow_1 = _S572;
    }
    var _S579 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S580 : vec3<f32> = sample_0.radiance * _S579;
    var _S581 : bool = (all((_S579 == _S527)));
    var _S582 : vec3<f32> = select(_S580, _S527, _S581);
    sample_0.radiance = _S582;
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
    var _S583 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S584 : bool = b_1 > 0.0f;
    var _S585 : f32 = select(1.0f, _S583, _S584);
    return _S585;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S586 : u32 = (lightSlot((hit_1)));
    var _S587 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S586, light_point_1);
    var _S588 : f32 = powerHeuristic(vertex_0.pdf, _S587);
    return _S588;
}

fn environment_0( dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S589 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S590 : bool = (_S589.x) > u32(1);
    var _S591 : bool;
    if(_S590)
    {
        var _S592 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S591 = (_S592.y) > u32(1);
    }
    else
    {
        _S591 = false;
    }
    if(_S591)
    {
        var _S593 : vec3<f32> = (env_map_sample((dir_8)));
        return _S593;
    }
    var _S594 : vec3<f32> = (uniforms_float.ambient);
    return _S594;
}

fn environmentMapped_0() -> bool
{
    var _S595 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S596 : bool = (_S595.x) > u32(1);
    var _S597 : bool;
    if(_S596)
    {
        var _S598 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S597 = (_S598.y) > u32(1);
    }
    else
    {
        _S597 = false;
    }
    return _S597;
}

fn escapeWeight_0( pdf_3 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S599 : bool = pdf_3 <= 0.0f;
    var _S600 : bool;
    if(_S599)
    {
        _S600 = true;
    }
    else
    {
        var _S601 : bool = environmentMapped_0();
        _S600 = !_S601;
    }
    if(_S600)
    {
        return 1.0f;
    }
    var _S602 : f32 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S602);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S603 : vec2<u32> = global_invocation_id_1.xy;
    var _S604 : vec2<i32> = vec2<i32>(_S603 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S605 : vec2<i32> = _S604 + vec2<i32>(i32(i_0 % u32(24)), i32(i_0 / u32(24)));
        var _S606 : bool = (all((_S605 >= vec2<i32>(i32(0)))));
        var _S607 : bool;
        if(_S606)
        {
            var _S608 : vec2<u32> = (uniforms_uint.render_size);
            _S607 = (all((_S605 < vec2<i32>(_S608))));
        }
        else
        {
            _S607 = false;
        }
        if(_S607)
        {
            var _S609 : vec4<u32> = (textureLoad(reservoir_prev, (_S605), (u32(0)), 0));
            var _S610 : u32 = _S609.x;
            var _S611 : bool = (bitcast<f32>((_S609.z))) > 0.0f;
            var _S612 : u32 = select(u32(0), _S610, _S611);
            seed_1 = _S612;
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
    var _S613 : u32 = local_invocation_id_0.y;
    var _S614 : u32 = local_invocation_id_0.x;
    var _S615 : u32 = duplication_seeds_0[(_S613 + u32(8)) * u32(24) + _S614 + u32(8)];
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
            var _S616 : bool = (duplication_seeds_0[(_S613 + seed_1) * u32(24) + _S614 + x_1]) == _S615;
            var _S617 : u32 = select(u32(0), u32(1), _S616);
            var count_2 : u32 = count_1 + _S617;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S618 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S619 : bool = _S615 != u32(0);
    var _S620 : f32 = select(0.0f, _S618, _S619);
    textureStore(duplication_out, (vec2<i32>(_S603)), 0, (vec4<u32>((bitcast<u32>((_S620))), u32(0), u32(0), u32(0))));
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
    var _S621 : Selection;
    _S621.r = r_4;
    _S621.w_sum = w_sum_0;
    _S621.color = color_2;
    _S621.random_state = random_state_7;
    return _S621;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S622 : u32 = hash(index_0);
    var _S623 : u32 = hash((seed_2 ^ (_S622)));
    return _S623;
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
    var _S624 : Shift;
    _S624.f = f_5;
    _S624.jac = jac_1;
    return _S624;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S625 : f32 = rgb_to_greyscale(weight_0);
    var _S626 : bool = _S625 > 0.0f;
    var _S627 : bool;
    if(_S626)
    {
        _S627 = _S625 < 3.00000000549775576e+38f;
    }
    else
    {
        _S627 = false;
    }
    var _S628 : bool = !_S627;
    if(_S628)
    {
        return;
    }
    var _S629 : f32 = (*sel_0).w_sum + _S625;
    (*sel_0).w_sum = _S629;
    var _S630 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S630;
    var _S631 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S631.state;
    var _S632 : bool = (_S631.value * (*sel_0).w_sum) <= _S625;
    if(_S632)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_5 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_5;
    var _S633 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S633;
    var _S634 : f32 = r_5.jac * shifted_0.jac;
    candidate_1.jac = _S634;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_5.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_6 : Reservoir = sel_2.r;
    var _S635 : f32 = rgb_to_greyscale(r_6.f);
    var _S636 : f32 = sel_2.w_sum / _S635;
    var _S637 : bool = _S635 > 0.0f;
    var _S638 : f32 = select(0.0f, _S636, _S637);
    r_6.w = _S638;
    r_6.c = c_2;
    return r_6;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S639 : vec2<u32> = global_invocation_id_2.xy;
    var _S640 : vec2<i32> = vec2<i32>(_S639);
    var _S641 : vec3<f32> = vec3<f32>(0.0f);
    var _S642 : Domain = Domain_x24init_0(_S641, _S641, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S642;
    var _S643 : bool = (currentDomain((_S640), &(dom_3)));
    var _S644 : bool = !_S643;
    if(_S644)
    {
        storeReservoir(reservoir_prev_out, (_S640), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S641, 0.0f, vec4<u32>(u32(0)), _S641, _S641)), (dom_3.hit));
        var _S645 : vec2<f32> = vec2<f32>(_S639);
        var _S646 : vec2<u32> = (uniforms_uint.render_size);
        var _S647 : vec2<f32> = _S645 / vec2<f32>(_S646.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S648 : vec3<f32> = vec3<f32>(_S647, 1.0f);
        var _S649 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S650 : vec3<f32> = (normalize(((((_S649) * (_S648))))));
        var _S651 : vec3<f32> = environment_0(_S650);
        textureStore(compute_out, (_S640), (u32(0)), (vec4<f32>(_S651, 1.0f)));
        var _S652 : u32 = (uniforms_uint.is_temporal);
        var _S653 : bool = _S652 == u32(1);
        if(_S653)
        {
            textureStore(compute_out, (_S640), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S654 : Reservoir = (loadReservoir(reservoir_temp, (_S640)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S654.c;
    loop
    {
        var _S655 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S655)
        {
        }
        else
        {
            break;
        }
        var _S656 : vec2<i32> = partner_0(_S640, t_13);
        var neighbor_0 : Domain = _S642;
        var _S657 : bool = (currentDomain((_S656), &(neighbor_0)));
        if(_S657)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S658 : vec4<u32> = (textureLoad(reservoir_temp, (_S656), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S658.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S659 : f32 = _S654.c / max(count_3, 1.0f);
    var _S660 : f32 = rgb_to_greyscale(_S654.f);
    var _S661 : bool = count_3 == 0.0f;
    var _S662 : f32 = select(0.0f, 1.0f, _S661);
    var _S663 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S641, 0.0f, vec4<u32>(u32(0)), _S641, _S641), 0.0f, _S641, u32(0));
    var sel_3 : Selection = _S663;
    var _S664 : u32 = (uniforms_uint.frame);
    var _S665 : u32 = hash(_S664);
    var _S666 : u32 = global_invocation_id_2.x;
    var _S667 : vec2<u32> = (uniforms_uint.render_size);
    var _S668 : u32 = stream(_S665, _S666 + _S667.x * global_invocation_id_2.y);
    var _S669 : u32 = stream(_S668, u32(195));
    sel_3.random_state = _S669;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S662;
    loop
    {
        var _S670 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S670)
        {
        }
        else
        {
            break;
        }
        var _S671 : vec2<i32> = partner_0(_S640, t_13);
        var neighbor_dom_0 : Domain = _S642;
        var _S672 : bool = (currentDomain((_S671), &(neighbor_dom_0)));
        if(_S672)
        {
            var _S673 : Reservoir = (loadReservoir(reservoir_temp, (_S671)));
            var _S674 : vec4<u32> = (textureLoad(shift_data, (_S671), (t_13), 0));
            var _S675 : vec4<f32> = (bitcast<vec4<f32>>((_S674)));
            var _S676 : vec4<u32> = (textureLoad(shift_data, (_S640), (t_13), 0));
            var _S677 : vec4<f32> = (bitcast<vec4<f32>>((_S676)));
            var _S678 : f32 = pairShare(_S673.c, _S659, c_sum_1);
            var _S679 : bool = _S660 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S679)
            {
                var _S680 : f32 = rgb_to_greyscale(_S677.xyz);
                var _S681 : f32 = canonicalWeight(_S678, _S659, _S660, _S673.c, _S680);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S681;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S682 : vec3<f32> = _S675.xyz;
            var _S683 : Shift = Shift_x24init_0(_S682, _S675.w);
            var _S684 : f32 = rgb_to_greyscale(_S673.f);
            var _S685 : f32 = rgb_to_greyscale(_S682);
            var _S686 : f32 = neighborWeight(_S678, _S673.c, _S684, _S659, _S685);
            offerShifted(&(sel_3), _S673, _S683, _S686);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S654, Shift_x24init_0(_S654.f, 1.0f), canonical_mis_0);
    var _S687 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S640), (_S687), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S640), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S688 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S689 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S690 : f32 = (sign((dot(_S689, _S688.smooth_n))));
    var _S691 : vec3<f32> = _S688.material.emissive * vec3<f32>(max(_S690, 0.0f));
    var _S692 : vec3<f32> = select(_S691, _S641, _S688.skip);
    var _S693 : vec3<f32> = clamp(sel_3.color + _S692, _S641, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S640), (u32(0)), (vec4<f32>(_S693, 1.0f)));
    var _S694 : u32 = (uniforms_uint.is_temporal);
    var _S695 : bool = _S694 == u32(1);
    if(_S695)
    {
        textureStore(compute_out, (_S640), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_4 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S696 : NEEVertex;
    _S696.none = none_0;
    _S696.pdf = pdf_4;
    _S696.origin = origin_5;
    _S696.smooth_n = smooth_n_3;
    _S696.start = start_6;
    return _S696;
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
    var _S697 : Vertex;
    _S697.rough = rough_0;
    _S697.lobe = lobe_6;
    _S697.pdf = pdf_5;
    _S697.cos = cos_0;
    _S697.inside = inside_0;
    return _S697;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>) -> Material
{
    var _S698 : Material;
    _S698.albedo = albedo_0;
    _S698.emissive = emissive_0;
    _S698.roughness = roughness_0;
    _S698.metallic = metallic_0;
    _S698.transmission = transmission_0;
    _S698.ior = ior_0;
    _S698.absorption = absorption_0;
    _S698.specular_tint = specular_tint_0;
    _S698.specular_level = specular_level_0;
    _S698.translucent = translucent_0;
    _S698.sheen = sheen_2;
    _S698.sheen_roughness = sheen_roughness_0;
    _S698.anisotropy = anisotropy_0;
    _S698.anisotropic_rotation = anisotropic_rotation_0;
    _S698.tangent = tangent_2;
    return _S698;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_6 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S699 : Surface;
    _S699.smooth_n = smooth_n_4;
    _S699.geometry_n = geometry_n_2;
    _S699.geometry_offset = geometry_offset_2;
    _S699.material = material_6;
    _S699.skip = skip_0;
    _S699.random_state = random_state_8;
    return _S699;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S700 : bool = transmission_1 > 0.0f;
    var _S701 : bool;
    if(_S700)
    {
        _S701 = true;
    }
    else
    {
        _S701 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S702 : f32;
    if(_S701)
    {
        _S702 = 1.0f;
    }
    else
    {
        _S702 = -1.0f;
    }
    return _S702;
}

fn facingRay_0( surface_3 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S703 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_10);
    var _S704 : vec3<f32> = vec3<f32>(_S703);
    return Surface_x24init_0(surface_3.smooth_n * _S704, surface_3.geometry_n * _S704, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S705 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S705));
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
    var _S706 : bool;
    if(open_0)
    {
        _S706 = prev_rough_0;
    }
    else
    {
        _S706 = false;
    }
    if(_S706)
    {
        _S706 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S706 = false;
    }
    return _S706;
}

fn vertexEta_0( material_7 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S707 : bool = n_dot_v_0 < 0.0f;
    var _S708 : f32 = select(1.0f, material_7.ior, _S707);
    var _S709 : f32 = select(material_7.ior, 1.0f, _S707);
    return vec2<f32>(_S708, _S709);
}

fn samplesLights( material_8 : Material) -> bool
{
    var _S710 : bool = (material_8.roughness) > 0.0f;
    var _S711 : bool;
    if(_S710)
    {
        _S711 = true;
    }
    else
    {
        var _S712 : bool = (material_8.metallic) < 1.0f;
        if(_S712)
        {
            _S711 = (material_8.transmission) < 1.0f;
        }
        else
        {
            _S711 = false;
        }
    }
    return _S711;
}

fn isTranslucent_0( material_9 : Material) -> bool
{
    var _S713 : f32 = rgb_to_greyscale(material_9.translucent);
    return _S713 > 0.0f;
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_8 : vec3<f32>,  g_n_0 : vec3<f32>,  material_10 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S714 : vec3<f32> = ((-(in_dir_4)));
    var _S715 : bool = (dot(g_n_0, _S714) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S715)
    {
        var _S716 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(0), random_state_9);
        var _S717 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(2), random_state_9);
        return _S716.throughput * vec3<f32>(_S716.pdf) + _S717.throughput * vec3<f32>(_S717.pdf);
    }
    var _S718 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(1), random_state_9);
    return _S718.throughput * vec3<f32>(_S718.pdf);
}

fn translucentCorrection( in_dir_5 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_1 : vec3<f32>,  material_11 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S719 : f32 = dot(n_9, out_dir_2);
    var _S720 : vec3<f32> = ((-(in_dir_5)));
    var _S721 : bool = (_S719 * dot(n_9, _S720)) < 0.0f;
    var _S722 : SampleBSDF = connectBSDF(in_dir_5, out_dir_2, n_9, material_11, eta_i_6, eta_o_6, u32(0), random_state_10);
    var _S723 : vec3<f32> = ((-(in_dir_5)));
    var _S724 : bool = (dot(g_n_1, _S723) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S725 : vec3<f32> = vec3<f32>(0.0f);
    var _S726 : vec3<f32> = _S722.throughput * vec3<f32>(_S722.pdf);
    var _S727 : f32 = select(1.0f, -1.0f, _S724);
    var _S728 : vec3<f32> = _S726 * vec3<f32>(_S727);
    var _S729 : vec3<f32> = select(_S725, _S728, _S721);
    return _S729;
}

fn translucentBSDF( in_dir_6 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_2 : vec3<f32>,  material_12 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S730 : vec3<f32> = BSDF(in_dir_6, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    var _S731 : vec3<f32> = translucentCorrection(in_dir_6, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    return _S730 + _S731;
}

fn lightBSDF_0( in_dir_7 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S732 : bool = !competing_0;
    var _S733 : bool;
    if(_S732)
    {
        _S733 = true;
    }
    else
    {
        _S733 = (light_0.density) == 0.0f;
    }
    if(_S733)
    {
        var _S734 : bool = isTranslucent_0(material_13);
        if(_S734)
        {
            var _S735 : vec3<f32> = translucentBSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
            return _S735 * light_0.radiance;
        }
        var _S736 : vec3<f32> = BSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
        return _S736 * light_0.radiance;
    }
    var _S737 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_7)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S738 : vec3<f32> = neeBSDF(in_dir_7, light_0.dir, smooth_n_5, material_13, eta_i_8, eta_o_8, _S737, light_0.density, true, random_state_12);
    return _S738 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S739 : vec3<f32> = a_6 / b_2;
    var _S740 : vec3<f32> = vec3<f32>(0.0f);
    var _S741 : vec3<bool> = b_2 == _S740;
    var _S742 : vec3<f32> = select(_S739, _S740, _S741);
    return _S742;
}

fn withEnd( r_7 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_7;
    var _S743 : u32 = (insertBits((r_7.path), (end_0), (u32(0)), (u32(5))));
    var _S744 : u32 = (insertBits((_S743), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S744;
    candidate_2.f = f_6;
    return candidate_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S745 : f32 = sqrt(random_1_0);
    var _S746 : f32 = 6.28318548202514648f * random_2_0;
    var _S747 : f32 = _S745 * cos(_S746);
    var _S748 : f32 = _S745 * sin(_S746);
    var _S749 : f32 = sqrt(max(0.0f, 1.0f - _S747 * _S747 - _S748 * _S748));
    return vec3<f32>(_S747, _S749, _S748);
}

fn sampleBSDF( in_dir_8 : vec3<f32>,  n_11 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_1;
    var _S750 : vec3<f32> = ((-(in_dir_8)));
    var _S751 : f32 = dot(n_11, _S750);
    var _S752 : f32 = (sign((_S751)));
    var n_i_4 : vec3<f32> = n_11 * vec3<f32>(_S752);
    var _S753 : f32 = abs(_S751);
    var _S754 : f32 = material_14.roughness;
    var _S755 : f32 = _S754 * _S754;
    var _S756 : AnisotropicFrame = anisotropicFrame(material_14, n_i_4);
    var _S757 : vec3<f32> = sampleHalfVector(_S750, n_i_4, _S755, _S756, &(random_state_13));
    var _S758 : BSDFLobes = bsdfLobes(in_dir_8, _S750, n_i_4, _S757, material_14, eta_i_9, eta_o_9, _S756);
    var lobes_3 : BSDFLobes = _S758;
    var _S759 : f32 = translucentShare(material_14);
    lobes_3.translucent_share = _S759;
    var _S760 : vec3<f32> = vec3<f32>(1.0f);
    var _S761 : SampleBSDF = SampleBSDF_x24init_0(_S760, _S760, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S761;
    var _S762 : Random = pcg(random_state_13);
    random_state_13 = _S762.state;
    var _S763 : bool = (_S762.value) < (lobes_3.p_diffuse);
    if(_S763)
    {
        var _S764 : Random = pcg(random_state_13);
        var _S765 : Random = pcg(_S764.state);
        sample_1.random_state = _S765.state;
        var _S766 : vec3<f32> = sampleCosWeightedHemisphere(_S764.value, _S765.value);
        var _S767 : bool = (_S762.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S768 : f32 = _S766.y;
        var _S769 : f32 = - _S768;
        var _S770 : f32 = select(_S768, _S769, _S767);
        var _S771 : vec3<f32> = tangentToWorld(vec3<f32>(_S766.x, _S770, _S766.z), n_i_4);
        sample_1.unit_direction = _S771;
        var _S772 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S755, material_14, lobes_3, u32(0));
        sample_1.throughput = _S772;
        var _S773 : f32 = lobeDensity(_S770, 0.0f, _S753, _S755, lobes_3, eta_i_9, eta_o_9, u32(0));
        sample_1.pdf = _S773;
        sample_1.refracted = _S767;
        return sample_1;
    }
    var _S774 : bool = (_S762.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S774)
    {
        sample_1.unit_direction = lobes_3.refracted;
        var _S775 : f32 = lobeDensity(0.0f, dot(sample_1.unit_direction, _S757), _S753, _S755, lobes_3, eta_i_9, eta_o_9, u32(1));
        sample_1.pdf = _S775;
        var _S776 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S755, material_14, lobes_3, u32(1));
        sample_1.throughput = _S776;
        sample_1.random_state = random_state_13;
        sample_1.refracted = true;
        sample_1.lobe = u32(1);
        return sample_1;
    }
    var _S777 : vec3<f32> = (normalize((reflect(in_dir_8, _S757))));
    sample_1.unit_direction = _S777;
    var _S778 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S755, material_14, lobes_3, u32(2));
    sample_1.throughput = _S778;
    sample_1.random_state = random_state_13;
    sample_1.lobe = u32(2);
    var _S779 : f32 = lobeDensity(0.0f, 0.0f, _S753, _S755, lobes_3, eta_i_9, eta_o_9, u32(2));
    sample_1.pdf = _S779;
    return sample_1;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S780 : bool = pdf_6 > 0.0f;
    var _S781 : bool;
    if(_S780)
    {
        if(diffuse_0)
        {
            _S781 = true;
        }
        else
        {
            _S781 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S781 = false;
    }
    return _S781;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S782 : bool = pdf_7 > 0.0f;
    var _S783 : bool;
    if(_S782)
    {
        if(diffuse_1)
        {
            _S783 = true;
        }
        else
        {
            _S783 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S783 = false;
    }
    return _S783;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S784 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S784.x, max(_S784.y, _S784.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_8 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S785 : vec3<f32> = vec3<f32>(0.0f);
    var _S786 : Shift = Shift_x24init_0(_S785, 0.0f);
    var _S787 : u32 = (extractBits((r_8.path), (u32(0)), (u32(5))));
    var _S788 : u32 = (extractBits((r_8.path), (u32(5)), (u32(5))));
    var _S789 : u32 = (extractBits((r_8.path), (u32(10)), (u32(2))));
    var _S790 : u32 = (extractBits((r_8.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S791 : bool = _S790 >= u32(3);
        var _S792 : u32 = select(u32(0), u32(1), _S791);
        var _S793 : u32 = _S787 + _S792;
        var _S794 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S793 > _S794;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S786;
    }
    var _S795 : u32 = _S788 - u32(1);
    var _S796 : bool = _S790 == u32(3);
    var _S797 : u32 = select(u32(0), u32(1), _S796);
    var _S798 : u32 = _S787 + _S797;
    var _S799 : bool = _S789 == u32(0);
    var _S800 : u32 = select(_S795, _S798, _S799);
    var _S801 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_8.rc.zw))), r_8.rc.x, r_8.rc.y, u32(0), 0.0f);
    var _S802 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S803 : Ray = Ray_x24init_0(dom_4.x1, _S802);
    var ray_2 : Ray = _S803;
    var hit_2 : Hit = dom_4.hit;
    var _S804 : vec3<f32> = vec3<f32>(1.0f);
    var _S805 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S785, _S785, _S785);
    var nee_vertex_0 : NEEVertex = _S805;
    var _S806 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S806;
    var _S807 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S785, 0.0f, vec4<u32>(u32(0)), _S785, _S785);
    var chain_0 : Reservoir = _S807;
    chain_0.seed = r_8.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S785;
    var reconnection_0 : vec3<f32> = _S785;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S804;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S808 : bool = (hit_2.is_point_light) == u32(1);
        var _S809 : Surface = Surface_x24init_0(_S785, _S785, 0.0f, Material_x24init_0(_S785, _S785, 0.0f, 0.0f, 0.0f, 0.0f, _S785, _S804, 1.0f, _S785, _S785, 0.5f, 0.0f, 0.0f, _S785), false, u32(0));
        var _S810 : bool = !_S808;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_4 : Surface;
        if(_S810)
        {
            var _S811 : u32 = stream(r_8.seed, b_3);
            var _S812 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S811)));
            var surface_5 : Surface = facingRay_0(_S812, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S813 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S814 : vec3<f32> = throughput_2 * _S813;
                front_n_0 = _S814;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S815 : bool = !surface_5.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_5.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S816 : bool = b_3 == u32(0);
            if(_S816)
            {
                var _S817 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S817;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S818 : vec3<f32> = front_n_0;
            var _S819 : f32 = geometry_density_2;
            scatter_0 = _S815;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S819;
            surface_4 = surface_5;
            front_n_0 = _S812.smooth_n;
            throughput_3 = _S818;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_4 = _S809;
            front_n_0 = _S785;
            throughput_3 = throughput_2;
        }
        var _S820 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S821 : Surface = surface_4;
        var _S822 : Surface = surface_4;
        var _S823 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S824 : vec2<f32> = vertexEta_0(_S821.material, _S823);
        var _S825 : bool;
        if(scatter_0)
        {
            var _S826 : bool = samplesLights(_S821.material);
            _S825 = _S826;
        }
        else
        {
            _S825 = false;
        }
        var _S827 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S828 : vec3<f32> = _S821.material.emissive * vec3<f32>(max(_S827, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S808)
        {
            var _S829 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S829;
        }
        else
        {
            emission_0 = _S828;
        }
        var _S830 : f32 = rgb_to_greyscale(emission_0);
        var _S831 : bool = _S830 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S831)
        {
            var _S832 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S832);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S833 : bool;
        if(replay_0)
        {
            _S833 = _S789 == u32(1);
        }
        else
        {
            _S833 = false;
        }
        var _S834 : bool;
        if(_S833)
        {
            _S834 = b_3 > _S788;
        }
        else
        {
            _S834 = false;
        }
        var _S835 : bool;
        if(_S834)
        {
            _S835 = b_3 == _S787;
        }
        else
        {
            _S835 = false;
        }
        var _S836 : bool;
        if(_S835)
        {
            var _S837 : bool = _S790 == u32(1);
            if(_S837)
            {
                _S836 = true;
            }
            else
            {
                _S836 = _S790 == u32(2);
            }
        }
        else
        {
            _S836 = false;
        }
        if(_S836)
        {
            var _S838 : bool = _S808 != (_S790 == u32(2));
            if(_S838)
            {
                return _S786;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_8.jac), density_2 / r_8.jac);
        }
        var _S839 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S840 : bool = _S839 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S841 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S842 : u32 = (insertBits((_S841), (u32(1)), (u32(10)), (u32(2))));
        var _S843 : u32 = (insertBits((_S842), (prev_0.lobe), (u32(15)), (u32(2))));
        var _S844 : bool = prev_0.inside;
        var _S845 : u32 = select(u32(0), u32(1), _S844);
        var _S846 : u32 = (insertBits((_S843), (_S845), (u32(20)), (u32(1))));
        here_0.path = _S846;
        var _S847 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S847;
        var _S848 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S848;
        var _S849 : bool;
        if(replay_0)
        {
            _S849 = _S789 == u32(1);
        }
        else
        {
            _S849 = false;
        }
        var _S850 : bool;
        if(_S849)
        {
            _S850 = b_3 == _S788;
        }
        else
        {
            _S850 = false;
        }
        var _S851 : bool = b_3 == _S800;
        var _S852 : bool;
        if(_S851)
        {
            var _S853 : bool = !scatter_0;
            if(_S853)
            {
                _S852 = true;
            }
            else
            {
                var _S854 : bool = _S789 != u32(1);
                if(_S854)
                {
                    _S852 = _S789 != u32(3);
                }
                else
                {
                    _S852 = false;
                }
            }
        }
        else
        {
            _S852 = false;
        }
        var _S855 : bool;
        if(_S852)
        {
            _S855 = _S789 == u32(2);
        }
        else
        {
            _S855 = false;
        }
        var _S856 : bool;
        if(_S855)
        {
            _S856 = !_S820;
        }
        else
        {
            _S856 = false;
        }
        var _S857 : bool;
        if(_S856)
        {
            _S857 = _S790 != u32(4);
        }
        else
        {
            _S857 = false;
        }
        var _S858 : bool = _S788 == _S787;
        var _S859 : bool;
        if(_S858)
        {
            _S859 = _S790 == u32(0);
        }
        else
        {
            _S859 = false;
        }
        var _S860 : bool;
        if(_S859)
        {
            _S860 = (hit_2.instance_index) == (_S801.instance_index);
        }
        else
        {
            _S860 = false;
        }
        var _S861 : bool;
        if(_S860)
        {
            _S861 = (hit_2.triangle_index) == (_S801.triangle_index);
        }
        else
        {
            _S861 = false;
        }
        var _S862 : bool;
        if(_S861)
        {
            _S862 = _S820;
        }
        else
        {
            _S862 = false;
        }
        var _S863 : bool = select(_S857, _S862, _S850);
        var _S864 : bool;
        if(_S825)
        {
            _S864 = select(scatter_0, _S863, replay_0);
        }
        else
        {
            _S864 = false;
        }
        var _S865 : TreeSample = TreeSample_x24init_0(_S785, _S785, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S864)
        {
            var _S866 : Surface = surface_4;
            var _S867 : bool = isTranslucent_0(_S821.material);
            var _S868 : u32 = stream(r_8.seed, b_3 + u32(64));
            var _S869 : TreeSample = sampleLightTree_0(ray_2.origin, _S822.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S867, _S868);
            var _S870 : bool = (any(((_S869.radiance) != _S785)));
            if(_S870)
            {
                var _S871 : f32 = _S824.x;
                var _S872 : f32 = _S824.y;
                var _S873 : u32 = (uniforms_uint.max_bounces);
                var _S874 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S869, _S822.smooth_n, _S866.geometry_n, _S821.material, _S871, _S872, b_3 < _S873, surface_4.random_state);
                lit_0 = _S874;
            }
            else
            {
                lit_0 = _S785;
            }
            light_1 = _S869;
        }
        else
        {
            light_1 = _S865;
            lit_0 = _S785;
        }
        var _S875 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S876 : bool;
        var _S877 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S850)
        {
            var _S878 : bool = (hit_2.instance_index) != (_S801.instance_index);
            if(_S878)
            {
                _S875 = true;
            }
            else
            {
                _S875 = (hit_2.triangle_index) != (_S801.triangle_index);
            }
            if(_S875)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S820;
            }
            if(wrong_side_0)
            {
                return _S786;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S858)
            {
                refracted_4 = _S790 == u32(1);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S858)
            {
                _S876 = _S790 == u32(0);
            }
            else
            {
                _S876 = false;
            }
            if(_S876)
            {
                var _S879 : bool = !_S825;
                if(_S879)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S880 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S880 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S786;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S858)
            {
                _S877 = _S790 == u32(4);
            }
            else
            {
                _S877 = false;
            }
            if(_S877)
            {
                var _S881 : bool = !_S825;
                if(_S881)
                {
                    return _S786;
                }
                var _S882 : f32 = environmentPdf_0(r_8.dir);
                var _S883 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_8.dir, surface_4, _S824, is_inside_4, _S882, surface_4.random_state);
                return Shift_x24init_0(throughput_5 * _S883 * r_8.radiance / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            var _S884 : u32 = (extractBits((r_8.path), (u32(19)), (u32(1))));
            var _S885 : bool = _S825 != (_S884 == u32(1));
            if(_S885)
            {
                return _S786;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S875 = _S851;
            }
            else
            {
                _S875 = false;
            }
            if(_S875)
            {
                var _S886 : bool = !scatter_0;
                if(_S886)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S887 : bool = _S789 != u32(1);
                    if(_S887)
                    {
                        wrong_side_0 = _S789 != u32(3);
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
                var _S888 : bool = _S789 == u32(2);
                if(_S888)
                {
                    _S833 = _S825;
                }
                else
                {
                    _S833 = false;
                }
                if(_S833)
                {
                    _S833 = !_S820;
                }
                else
                {
                    _S833 = false;
                }
                if(_S833)
                {
                    _S833 = _S790 == u32(4);
                }
                else
                {
                    _S833 = false;
                }
                if(_S833)
                {
                    var _S889 : u32 = stream(r_8.seed, b_3 + u32(256));
                    var _S890 : SkySample = sampleSky_0(ray_2, surface_4, _S824, is_inside_4, _S889, surface_4.random_state);
                    return Shift_x24init_0(throughput_3 * _S890.color, 1.0f);
                }
                if(_S888)
                {
                    is_inside_4 = _S825;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S820;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S891 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S892 : bool = !(_S891 > 0.0f);
                    if(_S892)
                    {
                        return _S786;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S799)
                {
                    is_inside_4 = _S790 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S808;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S799)
                {
                    is_inside_4 = _S790 == u32(1);
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
                    is_inside_4 = !_S820;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S786;
            }
            else
            {
                var _S893 : bool = !replay_0;
                if(_S893)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S894 : bool = b_3 > u32(0);
                    if(_S894)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S840)
                        {
                            var _S895 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S895;
                        }
                        else
                        {
                            if(_S820)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S896 : vec3<f32> = throughput_3 * emission_1;
                        var _S897 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S896);
                        offer(&((*sel_4)), _S897, _S896 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S825)
                    {
                        var _S898 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S840)
                        {
                            var _S899 : vec3<f32> = safeDivide(_S898, chain_throughput_0);
                            candidate_4.radiance = _S899;
                        }
                        else
                        {
                            if(_S820)
                            {
                                candidate_4 = here_0;
                                var _S900 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_4.path = _S900;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S901 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S902 : u32 = (insertBits((_S901), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S902;
                            }
                        }
                        var _S903 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S898);
                        offer(&((*sel_4)), _S903, _S898 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S825)
                    {
                        var _S904 : bool = environmentMapped_0();
                        _S876 = _S904;
                    }
                    else
                    {
                        _S876 = false;
                    }
                    if(_S876)
                    {
                        var _S905 : u32 = (uniforms_uint.max_bounces);
                        _S877 = b_3 < _S905;
                    }
                    else
                    {
                        _S877 = false;
                    }
                    if(_S877)
                    {
                        var _S906 : u32 = stream(r_8.seed, b_3 + u32(256));
                        var _S907 : SkySample = sampleSky_0(ray_2, surface_4, _S824, is_inside_4, _S906, surface_4.random_state);
                        var _S908 : vec3<f32> = throughput_3 * _S907.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S840)
                        {
                            var _S909 : vec3<f32> = safeDivide(_S908, chain_throughput_0);
                            candidate_5.radiance = _S909;
                        }
                        else
                        {
                            if(_S820)
                            {
                                candidate_5 = here_0;
                                var _S910 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_5.path = _S910;
                                candidate_5.dir = _S907.dir;
                                candidate_5.radiance = _S907.radiance;
                            }
                            else
                            {
                                var _S911 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S912 : u32 = (insertBits((_S911), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S912;
                            }
                        }
                        var _S913 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S908);
                        offer(&((*sel_4)), _S913, _S908 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S914 : bool;
        var _S915 : bool;
        var _S916 : bool;
        var _S917 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S875 = _S851;
            }
            else
            {
                _S875 = false;
            }
            var _S918 : u32 = (extractBits((r_8.path), (u32(15)), (u32(2))));
            var _S919 : u32 = (extractBits((r_8.path), (u32(17)), (u32(2))));
            var _S920 : u32 = select(_S918, _S919, _S850);
            var refracted_5 : bool = _S920 == u32(1);
            var _S921 : SampleBSDF = SampleBSDF_x24init_0(_S785, _S785, u32(0), false, u32(0), 0.0f);
            var lobe_7 : SampleBSDF = _S921;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S875)
            {
                var _S922 : u32 = (extractBits((r_8.path), (u32(20)), (u32(1))));
                var _S923 : bool = is_inside_4 != (_S922 == u32(1));
                if(_S923)
                {
                    return _S786;
                }
                var _S924 : bool = _S789 == u32(1);
                if(_S924)
                {
                    var _S925 : vec3<f32> = (hitPosition((_S801)));
                    dir_11 = _S925;
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
                    var _S926 : bool = isTranslucent_0(_S821.material);
                    if(_S926)
                    {
                        wrong_side_0 = _S920 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S927 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S928 : vec3<f32> = select(r_8.dir, _S927, _S924);
                        refracted_4 = (dot(_S822.smooth_n, _S928) * _S823) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S924)
                {
                    var _S929 : vec3<f32> = ray_2.origin;
                    var _S930 : Surface = surface_4;
                    var _S931 : vec3<f32> = (vec3<f32>(0) - _S822.smooth_n);
                    var _S932 : bool = is_inside_4 != refracted_4;
                    var _S933 : vec3<f32> = select(_S822.smooth_n, _S931, _S932);
                    var _S934 : vec3<f32> = (normalize((dir_11 - (_S929 + vec3<f32>(_S930.geometry_offset) * _S933))));
                    reconnection_1 = _S934;
                }
                else
                {
                    reconnection_1 = r_8.dir;
                }
                var _S935 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, surface_4.geometry_n);
                if(_S935)
                {
                    return _S786;
                }
                var _S936 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S920;
                wrong_side_0 = false;
                reconnection_1 = _S936;
            }
            else
            {
                var _S937 : bool = !_S850;
                if(_S937)
                {
                    var _S938 : f32 = _S824.x;
                    var _S939 : f32 = _S824.y;
                    var _S940 : vec2<f32> = vec2<f32>(0.0f);
                    var _S941 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S822.smooth_n, _S821.material, _S938, _S939, surface_4.random_state, _S940);
                    var bsdf_sampled_0 : SampleBSDF = _S941;
                    var _S942 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S821.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S943 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S942.geometry_n, _S821.material, _S938, _S939, bsdf_sampled_0.random_state, _S940);
                        bsdf_sampled_0.unit_direction = _S943.unit_direction;
                        bsdf_sampled_0.refracted = _S943.refracted;
                        bsdf_sampled_0.throughput = _S943.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S944 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S942.geometry_n))) * _S942.geometry_n;
                            bsdf_sampled_0.unit_direction = _S944;
                        }
                    }
                    var _S945 : u32 = bsdf_sampled_0.lobe;
                    var _S946 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S947 : bool = bsdf_sampled_0.refracted;
                    lobe_7 = bsdf_sampled_0;
                    var _S948 : f32 = bsdf_sampled_0.pdf;
                    var _S949 : f32 = select(_S948, 0.0f, wrong_side_1);
                    lobe_7.pdf = _S949;
                    dir_11 = _S946;
                    lobe_index_0 = _S945;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S947;
                }
                else
                {
                    dir_11 = r_8.dir;
                    lobe_index_0 = _S920;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S875)
            {
                _S876 = true;
            }
            else
            {
                _S876 = _S850;
            }
            if(_S876)
            {
                var _S950 : SampleBSDF = connectBSDF(ray_2.unit_direction, dir_11, _S822.smooth_n, _S821.material, _S824.x, _S824.y, lobe_index_0, surface_4.random_state);
                lobe_7 = _S950;
            }
            var _S951 : bool = lobe_index_0 != u32(0);
            if(_S951)
            {
                var _S952 : bool = (_S821.material.roughness) == 0.0f;
                if(_S952)
                {
                    _S877 = true;
                }
                else
                {
                    var _S953 : bool = lobe_index_0 == u32(1);
                    if(_S953)
                    {
                        _S877 = (_S824.x) == (_S824.y);
                    }
                    else
                    {
                        _S877 = false;
                    }
                }
            }
            else
            {
                _S877 = false;
            }
            var _S954 : bool = isTranslucent_0(_S821.material);
            if(_S954)
            {
                _S914 = lobe_index_0 == u32(0);
            }
            else
            {
                _S914 = false;
            }
            if(_S914)
            {
                _S915 = (dot(dir_11, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S915 = false;
            }
            if(_S825)
            {
                _S916 = !_S877;
            }
            else
            {
                _S916 = false;
            }
            if(_S916)
            {
                _S917 = !wrong_side_0;
            }
            else
            {
                _S917 = false;
            }
            var _S955 : bool;
            if(_S917)
            {
                var _S956 : f32 = lobe_7.pdf;
                var _S957 : vec3<f32> = ray_2.origin;
                var _S958 : bool = isTranslucent_0(_S821.material);
                var _S959 : vec3<f32> = select(_S822.smooth_n, _S785, _S958);
                var _S960 : vec3<f32> = ray_2.origin;
                var _S961 : Surface = surface_4;
                var _S962 : vec3<f32> = (vec3<f32>(0) - _S822.smooth_n);
                var _S963 : vec3<f32> = select(_S822.smooth_n, _S962, _S915);
                var _S964 : NEEVertex = NEEVertex_x24init_0(false, _S956, _S957, _S959, _S960 + vec3<f32>(_S961.geometry_offset) * _S963);
                nee_vertex_0 = _S964;
            }
            else
            {
                var _S965 : bool = lobe_index_0 != u32(1);
                if(_S965)
                {
                    _S955 = true;
                }
                else
                {
                    _S955 = (_S824.x) != (_S824.y);
                }
                if(_S955)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S966 : bool = lobe_index_0 == u32(0);
            var _S967 : bool = withinInverseFootprint(lobe_7.pdf, _S966, prev_0.cos, hit_2.distance, threshold_2);
            var _S968 : bool = roughLobe(lobe_7.pdf, _S966, _S821.material.roughness);
            var throughput_6 : vec3<f32>;
            if(_S850)
            {
                var _S969 : bool = !_S967;
                if(_S969)
                {
                    return _S786;
                }
                var _S970 : bool = _S790 != u32(1);
                if(_S970)
                {
                    _S955 = _S790 != u32(2);
                }
                else
                {
                    _S955 = false;
                }
                if(_S955)
                {
                    var _S971 : f32 = lobe_7.pdf;
                    var _S972 : f32 = select(0.0f, _S971, _S825);
                    var _S973 : f32 = escapeWeight_0(_S972, r_8.dir);
                    if(_S858)
                    {
                        is_inside_4 = _S796;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S974 : f32 = select(1.0f, _S973, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf)) * r_8.radiance * vec3<f32>(_S974) / vec3<f32>(r_8.jac), density_3 * lobe_7.pdf / r_8.jac);
                }
                var _S975 : vec3<f32> = throughput_4 * vec3<f32>(lobe_7.pdf);
                var _S976 : f32 = density_3 * lobe_7.pdf;
                throughput_6 = _S975;
                density_5 = _S976;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S955 = b_3 <= _S800;
            }
            else
            {
                _S955 = false;
            }
            var _S977 : bool;
            if(_S955)
            {
                _S977 = _S820;
            }
            else
            {
                _S977 = false;
            }
            var _S978 : bool;
            if(_S977)
            {
                _S978 = _S967;
            }
            else
            {
                _S978 = false;
            }
            var _S979 : bool;
            if(_S978)
            {
                _S979 = true;
            }
            else
            {
                if(_S875)
                {
                    _S979 = !_S968;
                }
                else
                {
                    _S979 = false;
                }
            }
            if(_S979)
            {
                return _S786;
            }
            var throughput_7 : vec3<f32>;
            if(_S875)
            {
                var _S980 : vec3<f32> = throughput_6 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf));
                var _S981 : f32 = lobe_7.pdf;
                throughput_7 = _S980;
                survival_probability_0 = _S981;
            }
            else
            {
                var _S982 : vec3<f32> = throughput_6 * max(lobe_7.throughput, _S785);
                throughput_7 = _S982;
                survival_probability_0 = density_5;
            }
            var _S983 : bool = !replay_0;
            var _S984 : bool;
            if(_S983)
            {
                _S984 = !_S840;
            }
            else
            {
                _S984 = false;
            }
            var _S985 : bool;
            if(_S984)
            {
                _S985 = _S820;
            }
            else
            {
                _S985 = false;
            }
            var _S986 : bool;
            if(_S985)
            {
                _S986 = _S967;
            }
            else
            {
                _S986 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S986)
            {
                chain_0 = here_0;
                var _S987 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(17)), (u32(2))));
                var _S988 : u32 = select(u32(0), u32(1), _S825);
                var _S989 : u32 = (insertBits((_S987), (_S988), (u32(19)), (u32(1))));
                chain_0.path = _S989;
                var _S990 : f32 = chain_0.jac * lobe_7.pdf;
                chain_0.jac = _S990;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S991 : Vertex = Vertex_x24init_0(_S968, lobe_index_0, lobe_7.pdf, abs(dot(surface_4.geometry_n, dir_11)), is_inside_4);
            prev_0 = _S991;
            var _S992 : f32 = lobe_7.pdf;
            var _S993 : bool = lobe_index_0 == u32(1);
            var _S994 : bool;
            if(_S993)
            {
                _S994 = (_S824.x) == (_S824.y);
            }
            else
            {
                _S994 = false;
            }
            var _S995 : f32 = select(_S992, sky_pdf_0, _S994);
            var _S996 : bool;
            if(refracted_4)
            {
                _S996 = !_S915;
            }
            else
            {
                _S996 = false;
            }
            var is_inside_5 : bool;
            if(_S996)
            {
                var _S997 : bool = !is_inside_4;
                is_inside_5 = _S997;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_11;
            var _S998 : Surface = surface_4;
            var _S999 : vec3<f32> = (vec3<f32>(0) - _S822.smooth_n);
            var _S1000 : bool = is_inside_5 != _S915;
            var _S1001 : vec3<f32> = select(_S822.smooth_n, _S999, _S1000);
            var _S1002 : vec3<f32> = ray_2.origin + vec3<f32>(_S998.geometry_offset) * _S1001;
            ray_2.origin = _S1002;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S995;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        var _S1003 : bool = !replay_0;
        if(_S1003)
        {
            if(_S808)
            {
                var _S1004 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1005 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1006 : bool = _S1005 == u32(1);
                if(_S1006)
                {
                    var _S1007 : vec3<f32> = safeDivide(_S1004, chain_throughput_0);
                    candidate_6.radiance = _S1007;
                }
                var _S1008 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1004);
                offer(&((*sel_4)), _S1008, _S1004 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S808)
            {
                _S875 = true;
            }
            else
            {
                _S875 = scatter_0;
            }
            if(_S875)
            {
                var _S1009 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1009;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1010 : u32 = stream(r_8.seed, b_3 + u32(128));
            var _S1011 : Random = pcg(_S1010);
            var _S1012 : bool = survival_probability_0 < (_S1011.value);
            if(_S1012)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1013 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1013;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1014 : f32 = density_5 * survival_probability_0;
            density_2 = _S1014;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1015 : Ray = ray_2;
        var _S1016 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S875 = _S851;
        }
        else
        {
            _S875 = false;
        }
        if(_S875)
        {
            wrong_side_0 = _S789 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1017 : f32 = select(4.294967296e+09f, _S1016, wrong_side_0);
        var _S1018 : Hit = (traverseInstanceBVH((_S1015), (_S810), (_S1017)));
        hit_2 = _S1018;
        if(replay_0)
        {
            refracted_4 = _S851;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S876 = _S789 == u32(1);
        }
        else
        {
            _S876 = false;
        }
        if(_S876)
        {
            _S877 = (hit_2.instance_index) == (_S801.instance_index);
        }
        else
        {
            _S877 = false;
        }
        if(_S877)
        {
            _S914 = (hit_2.triangle_index) == (_S801.triangle_index);
        }
        else
        {
            _S914 = false;
        }
        if(_S914)
        {
            hit_2.uv = _S801.uv;
            var _S1019 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1019;
        }
        if(replay_0)
        {
            _S915 = _S851;
        }
        else
        {
            _S915 = false;
        }
        if(_S915)
        {
            _S916 = _S789 == u32(3);
        }
        else
        {
            _S916 = false;
        }
        if(_S916)
        {
            _S917 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S917 = false;
        }
        if(_S917)
        {
            return _S786;
        }
        var _S1020 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1020)
        {
            var _S1021 : bool = !nee_vertex_0.none;
            var _S1022 : f32 = select(0.0f, sky_pdf_0, _S1021);
            var _S1023 : f32 = escapeWeight_0(_S1022, ray_2.unit_direction);
            var _S1024 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1025 : vec3<f32> = throughput_2 * _S1024;
            if(replay_0)
            {
                if(_S851)
                {
                    is_inside_4 = _S789 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1025 * vec3<f32>(_S1023) / vec3<f32>(r_8.jac), density_2 / r_8.jac);
                }
                if(_S799)
                {
                    is_inside_4 = _S796;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_3 == _S787;
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
                    return Shift_x24init_0(_S1025 * vec3<f32>(_S1023), 1.0f);
                }
                return _S786;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1026 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1027 : bool = _S1026 == u32(1);
            if(_S1027)
            {
                var _S1028 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1029 : bool = _S1028 == b_3;
                var _S1030 : f32 = select(_S1023, 1.0f, _S1029);
                var _S1031 : vec3<f32> = safeDivide(_S1025 * vec3<f32>(_S1030), chain_throughput_0);
                candidate_7.radiance = _S1031;
            }
            else
            {
                var _S1032 : bool = prev_0.rough;
                if(_S1032)
                {
                    var _S1033 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                    var _S1034 : u32 = (insertBits((_S1033), (u32(3)), (u32(10)), (u32(2))));
                    var _S1035 : u32 = (insertBits((_S1034), (prev_0.lobe), (u32(15)), (u32(2))));
                    var _S1036 : bool = prev_0.inside;
                    var _S1037 : u32 = select(u32(0), u32(1), _S1036);
                    var _S1038 : u32 = (insertBits((_S1035), (_S1037), (u32(20)), (u32(1))));
                    candidate_7.path = _S1038;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1039 : vec3<f32> = _S1025 * vec3<f32>(_S1023);
            var _S1040 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1039);
            offer(&((*sel_4)), _S1040, _S1039 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1041 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1041;
        var _S1042 : u32 = b_3 + u32(1);
        b_3 = _S1042;
    }
    return _S786;
}

fn shift_0( dom_5 : Domain,  r_9 : Reservoir) -> Shift
{
    var _S1043 : vec3<f32> = vec3<f32>(0.0f);
    var _S1044 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1043, 0.0f, vec4<u32>(u32(0)), _S1043, _S1043), 0.0f, _S1043, u32(0));
    var sel_5 : Selection = _S1044;
    var _S1045 : bool = (r_9.w) <= 0.0f;
    if(_S1045)
    {
        return Shift_x24init_0(_S1043, 0.0f);
    }
    var _S1046 : Shift = walk_0(dom_5, r_9, true, 0.0f, &(sel_5));
    return _S1046;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1047 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1048 : bool = _S1047 != u32(4294967295);
    if(_S1048)
    {
        var _S1049 : vec2<i32> = vec2<i32>((vec2<u32>(_S1047, (_S1047 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1050 : vec3<f32> = vec3<f32>(0.0f);
        var _S1051 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1050, _S1050, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1050, 0.0f, vec4<u32>(u32(0)), _S1050, _S1050));
        var shift_job_0 : ShiftJob = _S1051;
        var _S1052 : u32 = (_S1047 >> (u32(28)));
        var _S1053 : bool = spatialJob_0(_S1049, _S1052, &(shift_job_0));
        var _S1054 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1049), (_S1052), (vec4<u32>((bitcast<vec3<u32>>((_S1054.f))), (bitcast<u32>((_S1054.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1055 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1056 : array<u32, i32(3)>;
    spatialBins_0(_S1055, &(_S1056));
    var _S1057 : array<u32, i32(3)> = _S1056;
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
        var _S1058 : bool = (_S1057[t_16]) == u32(40);
        if(_S1058)
        {
            textureStore(shift_data_out, (_S1055), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1055, _S1057, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1059 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1059));
    countShifts_0(_S1059, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1060 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1061 : bool = _S1060 != u32(4294967295);
    if(_S1061)
    {
        var _S1062 : vec2<i32> = vec2<i32>((vec2<u32>(_S1060, (_S1060 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1063 : vec3<f32> = vec3<f32>(0.0f);
        var _S1064 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1063, _S1063, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1063, 0.0f, vec4<u32>(u32(0)), _S1063, _S1063));
        var shift_job_1 : ShiftJob = _S1064;
        var _S1065 : u32 = (_S1060 >> (u32(28)));
        var _S1066 : bool = temporalJob_0(_S1062, _S1065, &(shift_job_1));
        var _S1067 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1062), (_S1065), (vec4<u32>((bitcast<vec3<u32>>((_S1067.f))), (bitcast<u32>((_S1067.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1068 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1069 : array<u32, i32(3)>;
    temporalBins_0(_S1068, &(_S1069));
    var _S1070 : array<u32, i32(3)> = _S1069;
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
        var _S1071 : bool = (_S1070[t_18]) == u32(40);
        if(_S1071)
        {
            textureStore(temporal_shifts_out, (_S1068), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1068, _S1070, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1072 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1072));
    countShifts_0(_S1072, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1073 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1073;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1074 : f32 = c_3 * p_c_1;
    var _S1075 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1074 / (_S1074 + c_t_0 * g_previous_0), _S1075 / (_S1075 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1076 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1077 : vec3<f32> = vec3<f32>(0.0f);
    var _S1078 : Domain = Domain_x24init_0(_S1077, _S1077, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1078;
    var _S1079 : bool = (currentDomain((_S1076), &(dom_6)));
    var _S1080 : bool = !_S1079;
    if(_S1080)
    {
        storeReservoir(reservoir_temp_out, (_S1076), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1077, 0.0f, vec4<u32>(u32(0)), _S1077, _S1077)), (dom_6.hit));
        return;
    }
    var _S1081 : Reservoir = (loadReservoir(reservoir_initial, (_S1076)));
    var _S1082 : vec2<i32> = temporalNeighbor_0(_S1076, dom_6);
    var _S1083 : bool = (_S1082.x) >= i32(0);
    var r_10 : Reservoir;
    if(_S1083)
    {
        var _S1084 : Reservoir = (loadReservoir(reservoir_prev, (_S1082)));
        var _S1085 : vec4<u32> = (textureLoad(duplication, (_S1082), 0, 0));
        var _S1086 : f32 = (bitcast<f32>((_S1085.x)));
        var _S1087 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1088 : bool = _S1087 == u32(1);
        var _S1089 : f32 = select(0.0f, _S1086, _S1088);
        var _S1090 : f32 = confidenceCap(_S1089);
        var _S1091 : f32 = min(_S1084.c, _S1090);
        var _S1092 : vec4<u32> = (textureLoad(temporal_shifts, (_S1076), (u32(0)), 0));
        var _S1093 : vec4<f32> = (bitcast<vec4<f32>>((_S1092)));
        var _S1094 : vec4<f32> = vec4<f32>(_S1081.f, 1.0f);
        var _S1095 : Domain = (previousDomain((_S1082)));
        var _S1096 : bool = sameDomain_0(_S1095, dom_6);
        var _S1097 : bool = !_S1096;
        var to_previous_0 : vec4<f32>;
        if(_S1097)
        {
            var _S1098 : vec4<u32> = (textureLoad(temporal_shifts, (_S1076), (u32(1)), 0));
            var _S1099 : vec4<f32> = (bitcast<vec4<f32>>((_S1098)));
            to_previous_0 = _S1099;
        }
        else
        {
            to_previous_0 = _S1094;
        }
        var _S1100 : f32 = rgb_to_greyscale(_S1081.f);
        var _S1101 : f32 = rgb_to_greyscale(_S1084.f);
        var _S1102 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1077, 0.0f, vec4<u32>(u32(0)), _S1077, _S1077), 0.0f, _S1077, u32(0));
        var sel_6 : Selection = _S1102;
        var _S1103 : u32 = (uniforms_uint.frame);
        var _S1104 : u32 = hash(_S1103);
        var _S1105 : u32 = global_invocation_id_7.x;
        var _S1106 : vec2<u32> = (uniforms_uint.render_size);
        var _S1107 : u32 = stream(_S1104, _S1105 + _S1106.x * global_invocation_id_7.y);
        var _S1108 : u32 = stream(_S1107, u32(194));
        sel_6.random_state = _S1108;
        var _S1109 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1110 : vec3<f32> = _S1093.xyz;
        var _S1111 : f32 = rgb_to_greyscale(_S1110);
        var _S1112 : vec2<f32> = temporalWeights(_S1081.c, _S1100, _S1091, _S1101, _S1109, _S1111);
        offerShifted(&(sel_6), _S1081, Shift_x24init_0(_S1081.f, 1.0f), _S1112.x);
        offerShifted(&(sel_6), _S1084, Shift_x24init_0(_S1110, _S1093.w), _S1112.y);
        var _S1113 : Reservoir = finalize(sel_6, _S1081.c + _S1091);
        r_10 = _S1113;
    }
    else
    {
        r_10 = _S1081;
    }
    storeReservoir(reservoir_temp_out, (_S1076), (r_10), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1114 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1115 : vec3<f32> = vec3<f32>(0.0f);
    var _S1116 : Domain = Domain_x24init_0(_S1115, _S1115, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1116;
    var _S1117 : bool = (currentDomain((_S1114), &(dom_7)));
    var _S1118 : bool = !_S1117;
    if(_S1118)
    {
        storeReservoir(reservoir_initial_out, (_S1114), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1115, 0.0f, vec4<u32>(u32(0)), _S1115, _S1115)), (dom_7.hit));
        return;
    }
    var _S1119 : u32 = (uniforms_uint.frame);
    var _S1120 : u32 = hash(_S1119);
    var _S1121 : u32 = global_invocation_id_8.x;
    var _S1122 : vec2<u32> = (uniforms_uint.render_size);
    var _S1123 : u32 = stream(_S1120, _S1121 + _S1122.x * global_invocation_id_8.y);
    var _S1124 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1115, 0.0f, vec4<u32>(u32(0)), _S1115, _S1115);
    var _S1125 : Selection = Selection_x24init_0(_S1124, 0.0f, _S1115, u32(0));
    var initial_0 : Selection = _S1125;
    var _S1126 : u32 = stream(_S1123, u32(193));
    initial_0.random_state = _S1126;
    var i_2 : u32 = u32(0);
    loop
    {
        var _S1127 : u32 = (uniforms_uint.samples);
        if(i_2 < _S1127)
        {
        }
        else
        {
            break;
        }
        var r_11 : Reservoir = _S1124;
        var _S1128 : u32 = stream(_S1123, i_2);
        r_11.seed = _S1128;
        var _S1129 : u32 = (uniforms_uint.samples);
        var _S1130 : Shift = walk_0(dom_7, r_11, false, 1.0f / f32(_S1129), &(initial_0));
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var _S1131 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1114), (_S1131), (dom_7.hit));
    return;
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S1132 : Random = pcg(state_2);
    var _S1133 : Random = pcg(_S1132.state);
    var _S1134 : f32 = 6.28318548202514648f * _S1132.value;
    var _S1135 : f32 = sqrt(-2.0f * clamp(log(_S1133.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1133.state, _S1135 * cos(_S1134));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1136 : RandomSphere;
    _S1136.state = state_3;
    _S1136.value = value_1;
    return _S1136;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S1137 : Random = normal_distribution(state_4);
    var _S1138 : Random = normal_distribution(_S1137.state);
    var _S1139 : Random = normal_distribution(_S1138.state);
    var _S1140 : vec3<f32> = (normalize((vec3<f32>(_S1137.value, _S1138.value, _S1139.value))));
    return RandomSphere_x24init_0(_S1139.state, _S1140);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_12 : vec3<f32>) -> mat3x3<f32>
{
    var _S1141 : vec3<f32> = p1_0 - p0_0;
    var _S1142 : vec3<f32> = p2_0 - p0_0;
    var _S1143 : vec2<f32> = uv1_0 - uv0_0;
    var _S1144 : vec2<f32> = uv2_0 - uv0_0;
    var _S1145 : f32 = _S1143.x;
    var _S1146 : f32 = _S1144.y;
    var _S1147 : f32 = _S1143.y;
    var _S1148 : f32 = _S1144.x;
    var _S1149 : f32 = _S1145 * _S1146 - _S1147 * _S1148;
    var _S1150 : f32 = 1.0f / _S1149;
    var _S1151 : vec3<f32> = vec3<f32>(_S1150);
    var t_20 : vec3<f32> = (_S1141 * vec3<f32>(_S1146) - _S1142 * vec3<f32>(_S1147)) * _S1151;
    var _S1152 : vec3<f32> = (_S1142 * vec3<f32>(_S1145) - _S1141 * vec3<f32>(_S1148)) * _S1151;
    var t_21 : vec3<f32> = (normalize((t_20 - n_12 * vec3<f32>(dot(n_12, t_20)))));
    var _S1153 : bool = (dot(cross(n_12, t_21), _S1152)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1153)
    {
        var _S1154 : vec3<f32> = ((-(t_21)));
        t_22 = _S1154;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1155 : vec3<f32> = cross(n_12, t_22);
    return mat3x3<f32>(t_22, _S1155, n_12);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1156 : vec3<f32> = t1_0 - t0_0;
    var _S1157 : vec3<f32> = t2_2 - t0_0;
    var _S1158 : vec3<f32> = t2_2 - t1_0;
    var _S1159 : f32 = min(length(_S1156), min(length(_S1157), length(_S1158)));
    var _S1160 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1161 : vec3<f32> = (normalize((n0_0)));
    var _S1162 : f32 = dot(geometry_n_5, _S1161);
    var _S1163 : vec3<f32> = (normalize((n1_0)));
    var _S1164 : f32 = dot(geometry_n_5, _S1163);
    var _S1165 : vec3<f32> = (normalize((n2_0)));
    var _S1166 : vec3<f32> = acos(abs(vec3<f32>(_S1162, _S1164, dot(geometry_n_5, _S1165))));
    var _S1167 : vec3<f32> = clamp(tan(_S1166), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1160 * _S1167, uvw_0), 0.0f, _S1159 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_13 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S1168 : vec3<f32> = ((-(dir_12)));
    var _S1169 : f32 = (sign((dot(n_13, _S1168))));
    var _S1170 : vec3<f32> = n_13 * vec3<f32>(_S1169);
    var _S1171 : AnisotropicFrame = anisotropicFrame(material_15, _S1170);
    var _S1172 : bool = (_S1171.alphas.x) > 0.0f;
    if(_S1172)
    {
        var _S1173 : f32 = material_15.transmission * (1.0f - material_15.metallic);
        var _S1174 : vec3<f32> = ((-(_S1170)));
        var _S1175 : vec3<f32> = anisotropicLocal(dir_12, _S1171.tangent, _S1174);
        var _S1176 : f32 = anisotropicG1(_S1175, _S1171.alphas);
        return vec3<f32>((_S1173 * _S1176)) * material_15.albedo;
    }
    var _S1177 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S1178 : f32 = material_15.roughness;
    var _S1179 : f32 = smithG1(_S1178 * _S1178, abs(dot(n_13, dir_12)));
    return vec3<f32>((_S1177 * _S1179)) * material_15.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_14 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1180 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S1181 : vec3<f32> = straightThrough(toward_1, n_14, material_16);
        _S1180 = _S1181;
    }
    else
    {
        _S1180 = vec3<f32>(0.0f);
    }
    return _S1180 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_12 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1182 : Shift = walk_0(dom_8, r_12, replay_1, scale_2, &((*sel_7)));
    return _S1182;
}

fn shift_hook( dom_9 : Domain,  r_13 : Reservoir) -> Shift
{
    var _S1183 : Shift = shift_0(dom_9, r_13);
    return _S1183;
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

