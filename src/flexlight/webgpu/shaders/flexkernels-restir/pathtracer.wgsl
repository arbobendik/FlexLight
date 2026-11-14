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

fn skyRadiance_0( origin_1 : vec3<f32>,  surface_0 : Surface,  side_n_0 : vec3<f32>,  is_inside_1 : bool,  dir_2 : vec3<f32>) -> vec3<f32>
{
    var _S129 : bool = wrongSide_0(is_inside_1, false, dir_2, side_n_0);
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
            _S202 = !((dot(smooth_n_1, light_point_0 - start_4)) > 0.0f);
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

fn environment_0( dir_3 : vec3<f32>) -> vec3<f32>
{
    var _S216 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S217 : bool = (_S216.x) > u32(1);
    var _S218 : bool;
    if(_S217)
    {
        var _S219 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S218 = (_S219.y) > u32(1);
    }
    else
    {
        _S218 = false;
    }
    if(_S218)
    {
        var _S220 : vec3<f32> = (env_map_sample((dir_3)));
        return _S220;
    }
    var _S221 : vec3<f32> = (uniforms_float.ambient);
    return _S221;
}

fn environmentMapped_0() -> bool
{
    var _S222 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S223 : bool = (_S222.x) > u32(1);
    var _S224 : bool;
    if(_S223)
    {
        var _S225 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S224 = (_S225.y) > u32(1);
    }
    else
    {
        _S224 = false;
    }
    return _S224;
}

fn environmentPdf_0( dir_4 : vec3<f32>) -> f32
{
    var _S226 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S227 : vec2<u32> = _S226 - vec2<u32>(u32(1), u32(0));
    var _S228 : vec2<f32> = vec2<f32>(atan2(- dir_4.z, - dir_4.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_4.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S229 : vec2<u32> = min(vec2<u32>(_S228 * vec2<f32>(_S227)), _S227 - vec2<u32>(u32(1)));
    var _S230 : vec4<f32> = (textureLoad(environment_cdf, (_S229), 0));
    var _S231 : f32 = _S230.y;
    var _S232 : u32 = _S227.x;
    var _S233 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S232, _S229.y)), 0));
    var _S234 : f32 = _S231 * _S233.y;
    return _S234 * f32(_S232 * _S227.y) / (19.73921012878417969f * length(dir_4.xz));
}

fn escapeWeight_0( pdf_0 : f32,  dir_5 : vec3<f32>) -> f32
{
    var _S235 : bool = pdf_0 <= 0.0f;
    var _S236 : bool;
    if(_S235)
    {
        _S236 = true;
    }
    else
    {
        var _S237 : bool = environmentMapped_0();
        _S236 = !_S237;
    }
    if(_S236)
    {
        return 1.0f;
    }
    var _S238 : f32 = environmentPdf_0(dir_5);
    return pdf_0 / (pdf_0 + _S238);
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
    var _S239 : Random;
    _S239.state = state_0;
    _S239.value = value_0;
    return _S239;
}

fn pcg( state_1 : u32) -> Random
{
    var _S240 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S241 : u32 = hash(state_1);
    return Random_x24init_0(_S240, f32(_S241) / 4.294967296e+09f);
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
    var _S242 : AnisotropicFrame;
    _S242.tangent = tangent_0;
    _S242.alphas = alphas_0;
    return _S242;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S243 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S243)
    {
        const _S244 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S244;
    }
    else
    {
        a_2 = a_1;
    }
    var _S245 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S246 : vec3<f32> = cross(n_1, _S245);
    return vec3<f32>(v_0.x) * _S245 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S246;
}

fn anisotropicFrame( material_0 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S247 : f32 = material_0.roughness;
    var _S248 : f32 = _S247 * _S247;
    var _S249 : bool = (material_0.anisotropy) == 0.0f;
    var _S250 : bool;
    if(_S249)
    {
        _S250 = true;
    }
    else
    {
        _S250 = !(_S248 > 0.0f);
    }
    if(_S250)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S251 : vec3<f32> = material_0.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_0.tangent));
    var _S252 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S253 : bool = (dot(_S251, _S251)) > 0.0f;
    var _S254 : vec3<f32> = select(_S252, _S251, _S253);
    var _S255 : vec3<f32> = (normalize((_S254)));
    var _S256 : f32 = 6.28318548202514648f * material_0.anisotropic_rotation;
    var _S257 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_0.anisotropy));
    var _S258 : f32 = 1.0f / _S257;
    var _S259 : bool = (material_0.anisotropy) < 0.0f;
    var _S260 : f32 = select(_S257, _S258, _S259);
    return AnisotropicFrame_x24init_0(_S255 * vec3<f32>(cos(_S256)) + cross(n_i_0, _S255) * vec3<f32>(sin(_S256)), vec2<f32>(_S248 / _S260, _S248 * _S260));
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S261 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S262 : f32 = _S261.x;
    var _S263 : f32 = _S261.y;
    var _S264 : f32 = _S262 * _S262 + _S263 * _S263;
    const _S265 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S266 : vec3<f32> = vec3<f32>(- _S263, _S262, 0.0f);
    var _S267 : f32 = (inverseSqrt((_S264)));
    var _S268 : vec3<f32> = _S266 * vec3<f32>(_S267);
    var _S269 : bool = _S264 > 0.0f;
    var _S270 : vec3<f32> = select(_S265, _S268, _S269);
    var _S271 : vec3<f32> = cross(_S261, _S270);
    var _S272 : f32 = sqrt(U1_0);
    var _S273 : f32 = 6.28318548202514648f * U2_0;
    var _S274 : f32 = _S272 * cos(_S273);
    var t2_0 : f32 = _S272 * sin(_S273);
    var _S275 : f32 = 0.5f * (1.0f + _S261.z);
    var t2_1 : f32 = (1.0f - _S275) * sqrt(max(0.0f, 1.0f - _S274 * _S274)) + _S275 * t2_0;
    var _S276 : vec3<f32> = vec3<f32>(_S274) * _S270 + vec3<f32>(t2_1) * _S271;
    var _S277 : f32 = ((_S274));
    var _S278 : f32 = ((_S274));
    var _S279 : vec3<f32> = _S276 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S277 * _S278 - t2_1 * t2_1))) * _S261;
    var _S280 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S279.x, alpha_0 * _S279.y, max(0.0f, _S279.z)))));
    return _S280;
}

fn sampleAnisotropicVNDF( Ve_1 : vec3<f32>,  alphas_1 : vec2<f32>,  U1_1 : f32,  U2_1 : f32) -> vec3<f32>
{
    var _S281 : f32 = alphas_1.x;
    var _S282 : f32 = alphas_1.y;
    var _S283 : vec3<f32> = (normalize((vec3<f32>(_S281 * Ve_1.x, _S282 * Ve_1.y, Ve_1.z))));
    var _S284 : vec3<f32> = sampleGGXVNDF(_S283, 1.0f, U1_1, U2_1);
    var _S285 : vec3<f32> = (normalize((vec3<f32>(_S281 * _S284.x, _S282 * _S284.y, _S284.z))));
    return _S285;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S286 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S286)
    {
        const _S287 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S287;
    }
    else
    {
        a_4 = a_3;
    }
    var _S288 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S289 : vec3<f32> = cross(n_3, _S288);
    return vec3<f32>(dot(v_1, _S288), dot(v_1, n_3), dot(v_1, _S289));
}

fn sampleMaterialHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S290 : Random = pcg((*random_state_0));
    var _S291 : Random = pcg(_S290.state);
    (*random_state_0) = _S291.state;
    var _S292 : bool = (frame_0.alphas.x) > 0.0f;
    if(_S292)
    {
        var _S293 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S294 : vec3<f32> = sampleAnisotropicVNDF(_S293, frame_0.alphas, _S290.value, _S291.value);
        return vec3<f32>(_S294.x) * frame_0.tangent + vec3<f32>(_S294.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S294.z) * n_i_1;
    }
    var _S295 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S296 : vec3<f32> = sampleGGXVNDF(_S295.xzy, alpha_1, _S290.value, _S291.value);
    var _S297 : vec3<f32> = _S296.xzy;
    var _S298 : vec3<f32> = tangentToWorld(_S297, n_i_1);
    return _S298;
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
    var _S299 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S300 : f32 = eta_i_0 / eta_o_0 * _S299;
    var _S301 : bool = _S300 < 1.0f;
    var kr_0 : f32;
    if(_S301)
    {
        var _S302 : f32 = sqrt(max(0.0f, 1.0f - _S300 * _S300));
        var _S303 : f32 = eta_o_0 * cos_theta_0;
        var _S304 : f32 = eta_i_0 * _S302;
        var _S305 : f32 = (_S303 - _S304) / (_S303 + _S304);
        var _S306 : f32 = eta_i_0 * cos_theta_0;
        var _S307 : f32 = eta_o_0 * _S302;
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
fn sheenAlbedo( mu_0 : f32,  r_2 : f32) -> f32
{
    var _S310 : f32 = sqrt(0.05000000074505806f);
    var _S311 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S312 : f32 = (clamp(sqrt(max(r_2, 0.0f)), _S310, 1.0f) - _S310) / (1.0f - _S310) * 23.0f;
    var _S313 : u32 = min(u32(_S311), u32(22));
    var _S314 : u32 = min(u32(_S312), u32(22));
    var _S315 : f32 = _S311 - f32(_S313);
    var _S316 : f32 = _S312 - f32(_S314);
    var _S317 : u32 = _S313 * u32(24) + _S314;
    var _S318 : u32 = _S317 + u32(24);
    var _S319 : f32 = SHEEN_ALBEDO_0[_S317] + (SHEEN_ALBEDO_0[_S318] - SHEEN_ALBEDO_0[_S317]) * _S315;
    var _S320 : u32 = _S317 + u32(1);
    var _S321 : f32 = SHEEN_ALBEDO_0[_S320] + (SHEEN_ALBEDO_0[_S318 + u32(1)] - SHEEN_ALBEDO_0[_S320]) * _S315;
    return exp(_S319 + (_S321 - _S319) * _S316);
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S322 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S322 / (_S322 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S322)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S323 : f32 = alphas_3.x;
    var _S324 : f32 = h_0.x / _S323;
    var _S325 : f32 = alphas_3.y;
    var _S326 : f32 = h_0.y / _S325;
    var _S327 : f32 = h_0.z;
    var _S328 : f32 = _S324 * _S324 + _S326 * _S326 + _S327 * _S327;
    return 1.0f / max(3.14159274101257324f * _S323 * _S325 * _S328 * _S328, 1.17549435082228751e-38f);
}

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_4 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S329 : BSDFLobes;
    _S329.v_dot_h = v_dot_h_0;
    _S329.n_dot_h = n_dot_h_0;
    _S329.refracted = refracted_1;
    _S329.F = F_0;
    _S329.F_greyscale = F_greyscale_0;
    _S329.reflect_weight = reflect_weight_0;
    _S329.diffuse_weight = diffuse_weight_0;
    _S329.refract_weight = refract_weight_0;
    _S329.p_diffuse = p_diffuse_0;
    _S329.p_reflect = p_reflect_0;
    _S329.p_refract = p_refract_0;
    _S329.translucent_share = translucent_share_0;
    _S329.sheen = sheen_0;
    _S329.view = view_1;
    _S329.tangent = tangent_1;
    _S329.alphas = alphas_4;
    _S329.visible = visible_0;
    return _S329;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S330 : f32 = dot(ggx_n_0, v_3);
    var _S331 : f32 = dot(n_i_2, ggx_n_0);
    var _S332 : f32 = eta_i_1 / eta_o_1;
    var _S333 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S332))));
    var _S334 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S335 : f32 = _S334 * _S334;
    var _S336 : f32 = (1.0f + _S334) / (1.0f - _S334);
    var _S337 : f32 = abs(_S330);
    var _S338 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S338)
    {
        sheen_component_0 = _S336;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S338)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S336;
    }
    var _S339 : f32 = fresnel(_S337, sheen_component_0, visible_1);
    var _S340 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S330 * _S330)) >= (eta_o_1 * eta_o_1);
    var _S341 : vec3<f32>;
    if(_S340)
    {
        _S341 = vec3<f32>(1.0f);
    }
    else
    {
        var _S342 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S335);
        _S341 = _S342 + (vec3<f32>(1.0f) - _S342) * vec3<f32>((_S339 - _S335)) / vec3<f32>((1.0f - _S335));
    }
    var _S343 : vec3<f32> = vec3<f32>(1.0f);
    var _S344 : vec3<f32> = vec3<f32>(0.0f);
    var _S345 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S346 : bool = _S345 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S346)
    {
        var _S347 : f32 = sheenAlbedo(dot(n_i_2, v_3), material_1.sheen_roughness);
        var _S348 : f32 = min(_S347, 1.0f);
        var _S349 : vec3<f32> = vec3<f32>(1.0f) - material_1.sheen * vec3<f32>(_S348);
        var _S350 : f32 = rgb_to_greyscale(material_1.sheen);
        var _S351 : f32 = _S350 * _S348;
        var _S352 : vec3<f32> = material_1.sheen / vec3<f32>(max(_S347, 1.0f));
        scale_0 = _S349;
        sheen_component_0 = _S351;
        sheen_1 = _S352;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S343;
        sheen_component_0 = 0.0f;
        sheen_1 = _S344;
        view_2 = _S344;
    }
    var _S353 : vec3<f32> = (mix((_S341), (material_1.albedo), (material_1.metallic)));
    var F_1 : vec3<f32> = _S353 * scale_0;
    var _S354 : f32 = rgb_to_greyscale(F_1);
    var _S355 : f32 = 1.0f - material_1.metallic;
    var _S356 : vec3<f32> = vec3<f32>(1.0f) - _S341;
    var _S357 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S355)) * _S356 * scale_0;
    var _S358 : vec3<f32> = vec3<f32>((material_1.transmission * _S355)) * _S356 * scale_0;
    var _S359 : f32 = max(_S354, 0.0f);
    var _S360 : f32 = rgb_to_greyscale(_S357);
    var _S361 : f32 = max(_S360, 0.0f);
    var _S362 : f32 = rgb_to_greyscale(_S358);
    var _S363 : f32 = (sign((length(_S333))));
    var _S364 : f32 = max(_S362 * _S363, 0.0f);
    var _S365 : f32 = _S359 + _S361 + _S364 + sheen_component_0;
    var _S366 : f32 = 1.0f / max(_S365, 0.0000152587890625f);
    var _S367 : f32 = (_S361 + sheen_component_0) * _S366;
    var _S368 : f32 = _S359 * _S366;
    var _S369 : f32 = _S364 * _S366;
    var _S370 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S370)
    {
        var _S371 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S372 : f32 = anisotropicG1(_S371, frame_1.alphas);
        var _S373 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S374 : f32 = anisotropicD(_S373, frame_1.alphas);
        var _S375 : f32 = _S372 * _S374;
        visible_1 = _S375;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S330, _S331, _S333, F_1, _S354, 1.0f, _S357, _S358, _S367, _S368, _S369, 0.0f, sheen_1, view_2, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S376 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S377 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S378 : f32 = _S376 / (_S377 + _S376);
    var _S379 : bool = _S376 > 0.0f;
    var _S380 : f32 = select(0.0f, _S378, _S379);
    return _S380;
}

fn smithG1( alpha_2 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S381 : f32 = alpha_2 * alpha_2;
    var _S382 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S381 + (1.0f - _S381) * n_dot_x_0 * n_dot_x_0));
    var _S383 : bool = alpha_2 > 0.0f;
    var _S384 : f32 = select(1.0f, _S382, _S383);
    return _S384;
}

fn trowbridgeReitz( alpha_3 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S385 : f32 = alpha_3 * alpha_3;
    var _S386 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S385 * n_dot_h_1 * n_dot_h_1;
    return _S385 / max(3.14159274101257324f * _S386 * _S386, 1.17549435082228751e-38f);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S387 : bool = lobe_0 == u32(0);
    if(_S387)
    {
        var _S388 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S389 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S390 : f32 = 1.0f - lobes_0.translucent_share;
        var _S391 : bool = n_i_dot_l_0 < 0.0f;
        var _S392 : f32 = select(_S390, lobes_0.translucent_share, _S391);
        var _S393 : f32 = _S389 * _S392;
        var _S394 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S395 : f32 = select(_S388, _S393, _S394);
        var _S396 : bool = n_i_dot_v_0 > 0.0f;
        var _S397 : f32 = select(0.0f, _S395, _S396);
        return _S397;
    }
    var _S398 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S399 : f32 = _S398 * lobes_0.v_dot_h;
    var _S400 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S401 : f32 = _S399 * _S400 / n_i_dot_v_0;
    var _S402 : bool = alpha_4 > 0.0f;
    var _S403 : bool;
    if(_S402)
    {
        _S403 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S403 = false;
    }
    if(_S403)
    {
        _S403 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S403 = false;
    }
    if(_S403)
    {
        _S403 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S403 = false;
    }
    var _S404 : f32 = select(0.0f, _S401, _S403);
    var _S405 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S405)
    {
        var _S406 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S407 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S407)
        {
            _S403 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S403 = false;
        }
        if(_S403)
        {
            _S403 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S403 = false;
        }
        var _S408 : f32 = select(0.0f, _S406, _S403);
        pdf_h_0 = _S408;
    }
    else
    {
        pdf_h_0 = _S404;
    }
    var _S409 : bool = lobe_0 == u32(1);
    if(_S409)
    {
        var _S410 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S411 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S410 * _S410);
        var _S412 : bool = eta_i_2 != eta_o_2;
        if(_S412)
        {
            _S403 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S403 = false;
        }
        var _S413 : f32 = select(0.0f, _S411, _S403);
        return _S413;
    }
    var _S414 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S415 : bool = pdf_h_0 > 0.0f;
    var _S416 : f32 = select(0.0f, _S414, _S415);
    return _S416;
}

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_1 : u32,  pdf_1 : f32) -> SampleBSDF
{
    var _S417 : SampleBSDF;
    _S417.unit_direction = unit_direction_1;
    _S417.throughput = throughput_0;
    _S417.random_state = random_state_1;
    _S417.refracted = refracted_2;
    _S417.lobe = lobe_1;
    _S417.pdf = pdf_1;
    return _S417;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_4 : vec3<f32>,  n_4 : vec3<f32>,  r_3 : f32) -> f32
{
    var _S418 : f32 = 1.0f / max(r_3, 0.05000000074505806f);
    var _S419 : vec3<f32> = (normalize((l_0 + v_4)));
    var _S420 : f32 = dot(n_4, _S419);
    var _S421 : f32 = max(dot(n_4, l_0), 0.0f);
    var _S422 : f32 = max(dot(n_4, v_4), 0.0f);
    return (2.0f + _S418) * pow(max(1.0f - _S420 * _S420, 0.0f), 0.5f * _S418) * 0.5f * 0.31830987334251404f / max(4.0f * (_S421 + _S422 - _S421 * _S422), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes,  lobe_2 : u32) -> vec3<f32>
{
    var _S423 : bool = lobe_2 == u32(0);
    if(_S423)
    {
        var _S424 : bool = (dot(n_i_3, l_1)) < 0.0f;
        var _S425 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S424);
        var _S426 : f32 = 1.0f - lobes_1.translucent_share;
        var _S427 : f32 = select(_S426, lobes_1.translucent_share, _S424);
        var _S428 : vec3<f32> = _S425 / vec3<f32>(_S427);
        var _S429 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S430 : vec3<f32> = select(material_3.albedo, _S428, _S429);
        var _S431 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S432 : bool = _S431 > 0.0f;
        var _S433 : bool;
        if(_S432)
        {
            _S433 = !_S424;
        }
        else
        {
            _S433 = false;
        }
        if(_S433)
        {
            var _S434 : vec3<f32> = lobes_1.diffuse_weight * _S430;
            var _S435 : vec3<f32> = lobes_1.sheen * vec3<f32>(3.14159274101257324f);
            var _S436 : f32 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            var _S437 : vec3<f32> = _S435 * vec3<f32>(_S436);
            var _S438 : f32 = select(1.0f, _S426, _S429);
            return (_S434 + _S437 / vec3<f32>(_S438)) / vec3<f32>(lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S430 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S439 : bool = lobe_2 == u32(1);
    var G1_l_0 : f32;
    if(_S439)
    {
        var _S440 : f32 = - dot(n_i_3, l_1);
        var _S441 : f32 = smithG1(alpha_5, max(_S440, 0.0f));
        var _S442 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S442)
        {
            var _S443 : vec3<f32> = ((-(n_i_3)));
            var _S444 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, _S443);
            var _S445 : f32 = anisotropicG1(_S444, lobes_1.alphas);
            G1_l_0 = _S445;
        }
        else
        {
            G1_l_0 = _S441;
        }
        return lobes_1.refract_weight * vec3<f32>(G1_l_0) * material_3.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S446 : f32 = dot(n_i_3, l_1);
    var _S447 : f32 = smithG1(alpha_5, max(_S446, 0.0f));
    var _S448 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S448)
    {
        var _S449 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        var _S450 : f32 = anisotropicG1(_S449, lobes_1.alphas);
        G1_l_0 = _S450;
    }
    else
    {
        G1_l_0 = _S447;
    }
    return vec3<f32>((lobes_1.reflect_weight * G1_l_0)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S451 : vec3<f32> = ((-(in_dir_1)));
    var _S452 : f32 = dot(n_5, _S451);
    var _S453 : f32 = (sign((_S452)));
    var _S454 : vec3<f32> = n_5 * vec3<f32>(_S453);
    var _S455 : f32 = material_4.roughness;
    var _S456 : f32 = _S455 * _S455;
    var _S457 : AnisotropicFrame = anisotropicFrame(material_4, _S454);
    var _S458 : vec3<f32> = (normalize((_S451 + out_dir_0)));
    var _S459 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S459)
    {
        var _S460 : vec3<f32> = sampleMaterialHalfVector(_S451, _S454, _S456, _S457, &(random_state_2));
        ggx_n_1 = _S460;
    }
    else
    {
        var _S461 : bool = lobe_3 == u32(1);
        if(_S461)
        {
            var _S462 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S451 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S463 : vec3<f32> = (normalize((_S462)));
            var _S464 : f32 = (sign((dot(_S462, _S454))));
            var _S465 : vec3<f32> = _S463 * vec3<f32>(_S464);
            ggx_n_1 = _S465;
        }
        else
        {
            ggx_n_1 = _S458;
        }
    }
    var _S466 : BSDFLobes = bsdfLobes(in_dir_1, _S451, _S454, ggx_n_1, material_4, eta_i_3, eta_o_3, _S457);
    var lobes_2 : BSDFLobes = _S466;
    var _S467 : f32 = translucentShare(material_4);
    lobes_2.translucent_share = _S467;
    var _S468 : f32 = lobeDensity(dot(_S454, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S452), _S456, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S469 : bool = !(_S468 > 0.0f);
    if(_S469)
    {
        var _S470 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S470, _S470, u32(0), false, u32(0), 0.0f);
    }
    var _S471 : vec3<f32> = lobeThroughput(out_dir_0, _S454, _S456, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S471, random_state_2, lobe_3 == u32(1), lobe_3, _S468);
}

fn neeBSDF( in_dir_2 : vec3<f32>,  dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_3 : bool,  pdf_2 : f32,  power_0 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var _S472 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_1 : vec3<f32> = _S472;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S473 : bool = lobe_4 == u32(0);
        if(_S473)
        {
        }
        var _S474 : bool;
        if(_S473)
        {
            var _S475 : f32 = rgb_to_greyscale(material_5.translucent);
            _S474 = _S475 > 0.0f;
        }
        else
        {
            _S474 = false;
        }
        var _S476 : bool;
        if(_S474)
        {
            var _S477 : f32 = dot(n_6, dir_6);
            var _S478 : vec3<f32> = ((-(in_dir_2)));
            _S476 = ((_S477 * dot(n_6, _S478)) < 0.0f) == refracted_3;
        }
        else
        {
            _S476 = (lobe_4 == u32(1)) == refracted_3;
        }
        var f_2 : vec3<f32>;
        if(_S476)
        {
            var _S479 : SampleBSDF = connectBSDF(in_dir_2, dir_6, n_6, material_5, eta_i_4, eta_o_4, lobe_4, random_state_3);
            var _S480 : bool = (_S479.pdf) > 0.0f;
            if(_S480)
            {
                if(power_0)
                {
                    var _S481 : f32 = _S479.pdf / pdf_2;
                    var f_3 : vec3<f32> = f_1 + _S479.throughput * vec3<f32>(_S479.pdf) / vec3<f32>((pdf_2 * (1.0f + _S481 * _S481)));
                    f_2 = f_3;
                }
                else
                {
                    var f_4 : vec3<f32> = f_1 + _S479.throughput * vec3<f32>(_S479.pdf) / vec3<f32>((_S479.pdf + pdf_2));
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

fn skyBSDF( in_dir_3 : vec3<f32>,  dir_7 : vec3<f32>,  surface_1 : Surface,  side_n_1 : vec3<f32>,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S482 : bool = wrongSide_0(is_inside_2, false, dir_7, side_n_1);
    var _S483 : vec3<f32> = neeBSDF(in_dir_3, dir_7, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S482, pdf_3, false, random_state_4);
    return _S483;
}

fn SkySample_x24init_0( dir_8 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S484 : SkySample;
    _S484.dir = dir_8;
    _S484.radiance = radiance_1;
    _S484.color = color_0;
    _S484.random_state = random_state_5;
    return _S484;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  side_n_2 : vec3<f32>,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S485 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S486 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S487 : vec2<u32> = _S485 - _S486;
    var _S488 : Random = pcg(init_random_state_0);
    var _S489 : Random = pcg(_S488.state);
    var _S490 : Random = pcg(_S489.state);
    var _S491 : Random = pcg(_S490.state);
    var _S492 : u32 = _S487.x;
    var _S493 : u32 = searchCDF_0(vec2<u32>(_S492, u32(0)), vec2<u32>(u32(0), u32(1)), _S487.y, _S488.value);
    var _S494 : u32 = searchCDF_0(vec2<u32>(u32(0), _S493), _S486, _S492, _S489.value);
    var _S495 : vec2<f32> = (vec2<f32>(f32(_S494), f32(_S493)) + vec2<f32>(_S490.value, _S491.value)) / vec2<f32>(_S487) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S496 : f32 = _S495.y;
    var _S497 : f32 = sin(_S496);
    var _S498 : f32 = _S495.x;
    var _S499 : vec3<f32> = vec3<f32>(_S497 * cos(_S498), cos(_S496), _S497 * sin(_S498));
    var _S500 : f32 = environmentPdf_0(_S499);
    var _S501 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S499, surface_2, side_n_2, eta_1, is_inside_3, _S500, lobe_state_0);
    var _S502 : bool = !(_S500 > 0.0f);
    var _S503 : bool;
    if(_S502)
    {
        _S503 = true;
    }
    else
    {
        _S503 = (all((_S501 == vec3<f32>(0.0f))));
    }
    if(_S503)
    {
        var _S504 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S499, _S504, _S504, _S491.state);
    }
    var _S505 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, side_n_2, is_inside_3, _S499);
    return SkySample_x24init_0(_S499, _S505, _S501 * _S505, _S491.state);
}

struct TreeSample
{
     dir : vec3<f32>,
     radiance : vec3<f32>,
     density : f32,
     random_state : u32,
};

fn TreeSample_x24init_0( dir_9 : vec3<f32>,  radiance_2 : vec3<f32>,  density_0 : f32,  random_state_6 : u32) -> TreeSample
{
    var _S506 : TreeSample;
    _S506.dir = dir_9;
    _S506.radiance = radiance_2;
    _S506.density = density_0;
    _S506.random_state = random_state_6;
    return _S506;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S507 : f32 = importance(first_1, p_10, normal_3);
    var _S508 : f32 = importance(second_1, p_10, normal_3);
    var _S509 : vec2<f32> = vec2<f32>(_S507, _S508);
    var _S510 : bool = _S507 == 0.0f;
    var _S511 : bool;
    if(_S510)
    {
        _S511 = _S508 == 0.0f;
    }
    else
    {
        _S511 = false;
    }
    if(_S511)
    {
        return u32(2);
    }
    var _S512 : f32 = _S507 + _S508;
    var _S513 : bool = _S508 > 0.0f;
    if(_S513)
    {
        _S511 = ((*pick_0) * _S512) >= _S507;
    }
    else
    {
        _S511 = false;
    }
    var _S514 : u32 = select(u32(0), u32(1), _S511);
    var _S515 : f32 = min(((*pick_0) * _S512 - f32(_S514) * _S507) / _S509[_S514], 0.99999994039535522f);
    (*pick_0) = _S515;
    var _S516 : f32 = (*probability_3) * (_S509[_S514] / _S512);
    (*probability_3) = _S516;
    return _S514;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S517 : vec3<f32> = center_1 - p_11;
    var _S518 : f32 = radius_1 * radius_1 / dot(_S517, _S517);
    var _S519 : f32 = u1_0 * _S518 / (1.0f + sqrt(max(1.0f - _S518, 0.0f)));
    var _S520 : f32 = 2.0f * u1_0;
    var _S521 : bool = _S518 >= 1.0f;
    var _S522 : f32 = select(_S519, _S520, _S521);
    var _S523 : f32 = sqrt(max(_S522 * (2.0f - _S522), 0.0f));
    var _S524 : f32 = 6.28318548202514648f * u2_0;
    var _S525 : vec3<f32> = vec3<f32>(_S523 * cos(_S524), 1.0f - _S522, _S523 * sin(_S524));
    var _S526 : vec3<f32> = (normalize((_S517)));
    var _S527 : vec3<f32> = tangentToWorld(_S525, _S526);
    return _S527;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S528 : vec3<f32> = center_2 - ray_1.origin;
    var _S529 : f32 = dot(_S528, ray_1.unit_direction);
    var _S530 : f32 = dot(_S528, _S528) - _S529 * _S529;
    var _S531 : f32 = radius_3 * radius_3;
    var _S532 : bool = _S530 > _S531;
    if(_S532)
    {
        return 4.294967296e+09f;
    }
    var _S533 : f32 = sqrt(_S531 - _S530);
    var _S534 : f32 = _S529 - _S533;
    var _S535 : f32 = _S529 + _S533;
    var _S536 : bool = _S534 > 0.0000152587890625f;
    var _S537 : bool;
    if(_S536)
    {
        _S537 = _S534 < max_len_0;
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        return _S534;
    }
    var _S538 : bool = _S535 > 0.0000152587890625f;
    if(_S538)
    {
        _S537 = _S535 < max_len_0;
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        return _S535;
    }
    return 4.294967296e+09f;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_5 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S539 : f32 = (sign((dot(light_n_0, start_5 - end_0))));
    return light_n_0 * vec3<f32>((_S539 * light_offset_0));
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S540 : Random = pcg(init_random_state_1);
    var _S541 : Random = pcg(_S540.state);
    var _S542 : Random = pcg(_S541.state);
    var _S543 : vec3<f32> = vec3<f32>(0.0f);
    var _S544 : TreeSample = TreeSample_x24init_0(_S543, _S543, 0.0f, _S542.state);
    var sample_0 : TreeSample = _S544;
    var _S545 : vec3<f32> = select(smooth_n_2, _S543, sided_0);
    var _S546 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var start_6 : vec3<f32> = origin_4 + _S546 * smooth_n_2;
    var pick_1 : f32 = _S540.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S547 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S547.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S548 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S549 : u32 = n_7 + u32(1);
        var _S550 : LightBounds = (lightBounds((_S549)));
        var _S551 : LightBounds = (lightBounds((_S548)));
        var _S552 : u32 = pickChild(_S550, _S551, origin_4, _S545, &(pick_1), &(probability_4));
        var _S553 : bool = _S552 > u32(1);
        if(_S553)
        {
            return sample_0;
        }
        var _S554 : bool = _S552 == u32(1);
        var _S555 : u32 = select(_S549, _S548, _S554);
        n_7 = _S555;
    }
    var _S556 : bool = n_7 == u32(0);
    var _S557 : bool;
    if(_S556)
    {
        var _S558 : LightBounds = (lightBounds((u32(0))));
        var _S559 : f32 = importance(_S558, origin_4, _S545);
        _S557 = !(_S559 > 0.0f);
    }
    else
    {
        _S557 = false;
    }
    if(_S557)
    {
        return sample_0;
    }
    var _S560 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S561 : bool = (_S560.x) == u32(2);
    var start_7 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S561)
    {
        var _S562 : Light = (lights[(_S560.y)]);
        if(sided_0)
        {
            var _S563 : f32 = (sign((dot(geometry_n_1, _S562.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S563);
            var _S564 : vec3<f32> = origin_4 + _S546 * lift_n_1;
            start_7 = _S564;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_7 = start_6;
            lift_n_0 = smooth_n_2;
        }
        var _S565 : bool = (_S562.variance) == 0.0f;
        if(_S565)
        {
            var _S566 : vec3<f32> = _S562.position - start_7;
            var _S567 : vec3<f32> = (normalize((_S566)));
            sample_0.dir = _S567;
            var _S568 : vec3<f32> = _S562.color * vec3<f32>(_S562.intensity) / vec3<f32>((dot(_S566, _S566) * probability_4));
            sample_0.radiance = _S568;
            shadow_1 = _S566;
        }
        else
        {
            var _S569 : vec3<f32> = sampleSphere(_S562.position, _S562.variance, start_7, _S541.value, _S542.value);
            sample_0.dir = _S569;
            var _S570 : f32 = sphereDensity(_S562.position, _S562.variance, start_7);
            var _S571 : f32 = probability_4 * _S570;
            sample_0.density = _S571;
            var _S572 : vec3<f32> = pointLightRadiance(_S562.color, _S562.intensity, _S562.variance);
            var _S573 : vec3<f32> = _S572 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S573;
            var _S574 : f32 = raySphere_0(_S562.position, _S562.variance, Ray_x24init_0(start_7, sample_0.dir), 4.294967296e+09f);
            var _S575 : vec3<f32> = sample_0.dir * vec3<f32>(_S574);
            shadow_1 = _S575;
        }
    }
    else
    {
        var _S576 : u32 = _S560.y;
        var _S577 : u32 = ((instance_uint[(_S576) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S578 : u32 = _S577 + _S560.z;
        var _S579 : mat3x3<f32> = (worldTriangle((_S576), (_S578)));
        var _S580 : f32 = sqrt(_S541.value);
        var _S581 : vec2<f32> = vec2<f32>(_S580 * (1.0f - _S542.value), _S580 * _S542.value);
        var _S582 : vec3<f32> = (((_S579) * (vec3<f32>(1.0f - _S580, _S581))));
        if(sided_0)
        {
            var _S583 : f32 = (sign((dot(geometry_n_1, _S582 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S583);
            var _S584 : vec3<f32> = origin_4 + _S546 * lift_n_2;
            start_7 = _S584;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S585 : bool = !((dot(smooth_n_2, _S582 - start_6)) > 0.0f);
            if(_S585)
            {
                return sample_0;
            }
            start_7 = start_6;
            lift_n_0 = smooth_n_2;
        }
        var _S586 : Surface = (surfaceAt((Hit_x24init_0(_S581, _S576, _S578, u32(0), 0.0f)), (_S582), (_S542.state)));
        sample_0.random_state = _S586.random_state;
        var _S587 : vec3<f32> = _S582 - start_7;
        var _S588 : vec3<f32> = (normalize((_S587)));
        sample_0.dir = _S588;
        var _S589 : f32 = solidAngle(probability_4, cross(_S579[i32(1)] - _S579[i32(0)], _S579[i32(2)] - _S579[i32(0)]), _S587);
        sample_0.density = _S589;
        var _S590 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S586.smooth_n))));
        var _S591 : vec3<f32> = _S586.material.emissive * vec3<f32>(max(_S590, 0.0f));
        var _S592 : vec3<f32> = select(_S591, _S543, _S586.skip);
        var _S593 : vec3<f32> = _S592 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S593;
        var _S594 : vec3<f32> = shadowLift(_S586.smooth_n, _S586.geometry_offset, start_7, _S582);
        var _S595 : vec3<f32> = _S582 + _S594 - start_7;
        shadow_1 = _S595;
    }
    var _S596 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S597 : vec3<f32> = sample_0.radiance * _S596;
    var _S598 : bool = (all((_S596 == _S543)));
    var _S599 : vec3<f32> = select(_S597, _S543, _S598);
    sample_0.radiance = _S599;
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
    var _S600 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S601 : bool = b_1 > 0.0f;
    var _S602 : f32 = select(1.0f, _S600, _S601);
    return _S602;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S603 : u32 = (lightSlot((hit_1)));
    var _S604 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S603, light_point_1);
    var _S605 : f32 = powerHeuristic(vertex_0.pdf, _S604);
    return _S605;
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

fn NEEVertex_x24init_0( none_0 : bool,  pdf_4 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_8 : vec3<f32>) -> NEEVertex
{
    var _S699 : NEEVertex;
    _S699.none = none_0;
    _S699.pdf = pdf_4;
    _S699.origin = origin_5;
    _S699.smooth_n = smooth_n_3;
    _S699.start = start_8;
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

fn sideNormal( surface_4 : Surface,  in_dir_4 : vec3<f32>) -> vec3<f32>
{
    var _S717 : bool = !((surface_4.material.transmission) > 0.0f);
    var _S718 : bool;
    if(_S717)
    {
        var _S719 : bool = isTranslucent_0(surface_4.material);
        _S718 = !_S719;
    }
    else
    {
        _S718 = false;
    }
    if(_S718)
    {
        _S718 = (dot(surface_4.smooth_n, (vec3<f32>(0) - in_dir_4))) > 0.0f;
    }
    else
    {
        _S718 = false;
    }
    var _S720 : vec3<f32> = select(surface_4.geometry_n, surface_4.smooth_n, _S718);
    return _S720;
}

fn BSDF( in_dir_5 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_8 : vec3<f32>,  g_n_0 : vec3<f32>,  material_10 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S721 : vec3<f32> = ((-(in_dir_5)));
    var _S722 : bool = (dot(g_n_0, _S721) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S722)
    {
        var _S723 : SampleBSDF = connectBSDF(in_dir_5, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(0), random_state_9);
        var _S724 : SampleBSDF = connectBSDF(in_dir_5, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(2), random_state_9);
        return _S723.throughput * vec3<f32>(_S723.pdf) + _S724.throughput * vec3<f32>(_S724.pdf);
    }
    var _S725 : SampleBSDF = connectBSDF(in_dir_5, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(1), random_state_9);
    return _S725.throughput * vec3<f32>(_S725.pdf);
}

fn translucentCorrection( in_dir_6 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_1 : vec3<f32>,  material_11 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S726 : f32 = dot(n_9, out_dir_2);
    var _S727 : vec3<f32> = ((-(in_dir_6)));
    var _S728 : bool = (_S726 * dot(n_9, _S727)) < 0.0f;
    var _S729 : SampleBSDF = connectBSDF(in_dir_6, out_dir_2, n_9, material_11, eta_i_6, eta_o_6, u32(0), random_state_10);
    var _S730 : vec3<f32> = ((-(in_dir_6)));
    var _S731 : bool = (dot(g_n_1, _S730) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S732 : vec3<f32> = vec3<f32>(0.0f);
    var _S733 : vec3<f32> = _S729.throughput * vec3<f32>(_S729.pdf);
    var _S734 : f32 = select(1.0f, -1.0f, _S731);
    var _S735 : vec3<f32> = _S733 * vec3<f32>(_S734);
    var _S736 : vec3<f32> = select(_S732, _S735, _S728);
    return _S736;
}

fn translucentBSDF( in_dir_7 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_2 : vec3<f32>,  material_12 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S737 : vec3<f32> = BSDF(in_dir_7, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    var _S738 : vec3<f32> = translucentCorrection(in_dir_7, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    return _S737 + _S738;
}

fn lightBSDF_0( in_dir_8 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S739 : bool = !competing_0;
    var _S740 : bool;
    if(_S739)
    {
        _S740 = true;
    }
    else
    {
        _S740 = (light_0.density) == 0.0f;
    }
    if(_S740)
    {
        var _S741 : bool = isTranslucent_0(material_13);
        if(_S741)
        {
            var _S742 : vec3<f32> = translucentBSDF(in_dir_8, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
            return _S742 * light_0.radiance;
        }
        var _S743 : vec3<f32> = BSDF(in_dir_8, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
        return _S743 * light_0.radiance;
    }
    var _S744 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_8)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S745 : vec3<f32> = neeBSDF(in_dir_8, light_0.dir, smooth_n_5, material_13, eta_i_8, eta_o_8, _S744, light_0.density, true, random_state_12);
    return _S745 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S746 : vec3<f32> = a_6 / b_2;
    var _S747 : vec3<f32> = vec3<f32>(0.0f);
    var _S748 : vec3<bool> = b_2 == _S747;
    var _S749 : vec3<f32> = select(_S746, _S747, _S748);
    return _S749;
}

fn withEnd( r_7 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_7;
    var _S750 : u32 = (insertBits((r_7.path), (end_1), (u32(0)), (u32(5))));
    var _S751 : u32 = (insertBits((_S750), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S751;
    candidate_2.f = f_6;
    return candidate_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S752 : f32 = sqrt(random_1_0);
    var _S753 : f32 = 6.28318548202514648f * random_2_0;
    var _S754 : f32 = _S752 * cos(_S753);
    var _S755 : f32 = _S752 * sin(_S753);
    var _S756 : f32 = sqrt(max(0.0f, 1.0f - _S754 * _S754 - _S755 * _S755));
    return vec3<f32>(_S754, _S756, _S755);
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_11 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_1;
    var _S757 : vec3<f32> = ((-(in_dir_9)));
    var _S758 : f32 = dot(n_11, _S757);
    var _S759 : f32 = (sign((_S758)));
    var n_i_4 : vec3<f32> = n_11 * vec3<f32>(_S759);
    var _S760 : f32 = abs(_S758);
    var _S761 : f32 = material_14.roughness;
    var _S762 : f32 = _S761 * _S761;
    var _S763 : AnisotropicFrame = anisotropicFrame(material_14, n_i_4);
    var _S764 : vec3<f32> = sampleMaterialHalfVector(_S757, n_i_4, _S762, _S763, &(random_state_13));
    var _S765 : BSDFLobes = bsdfLobes(in_dir_9, _S757, n_i_4, _S764, material_14, eta_i_9, eta_o_9, _S763);
    var lobes_3 : BSDFLobes = _S765;
    var _S766 : f32 = translucentShare(material_14);
    lobes_3.translucent_share = _S766;
    var _S767 : vec3<f32> = vec3<f32>(1.0f);
    var _S768 : SampleBSDF = SampleBSDF_x24init_0(_S767, _S767, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S768;
    var _S769 : Random = pcg(random_state_13);
    random_state_13 = _S769.state;
    var _S770 : bool = (_S769.value) < (lobes_3.p_diffuse);
    if(_S770)
    {
        var _S771 : Random = pcg(random_state_13);
        var _S772 : Random = pcg(_S771.state);
        sample_1.random_state = _S772.state;
        var _S773 : vec3<f32> = sampleCosWeightedHemisphere(_S771.value, _S772.value);
        var _S774 : bool = (_S769.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S775 : f32 = _S773.y;
        var _S776 : f32 = - _S775;
        var _S777 : f32 = select(_S775, _S776, _S774);
        var _S778 : vec3<f32> = tangentToWorld(vec3<f32>(_S773.x, _S777, _S773.z), n_i_4);
        sample_1.unit_direction = _S778;
        var _S779 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S762, material_14, lobes_3, u32(0));
        sample_1.throughput = _S779;
        var _S780 : f32 = lobeDensity(_S777, 0.0f, _S760, _S762, lobes_3, eta_i_9, eta_o_9, u32(0));
        sample_1.pdf = _S780;
        sample_1.refracted = _S774;
        return sample_1;
    }
    var _S781 : bool = (_S769.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S781)
    {
        sample_1.unit_direction = lobes_3.refracted;
        var _S782 : f32 = lobeDensity(0.0f, dot(sample_1.unit_direction, _S764), _S760, _S762, lobes_3, eta_i_9, eta_o_9, u32(1));
        sample_1.pdf = _S782;
        var _S783 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S762, material_14, lobes_3, u32(1));
        sample_1.throughput = _S783;
        sample_1.random_state = random_state_13;
        sample_1.refracted = true;
        sample_1.lobe = u32(1);
        return sample_1;
    }
    var _S784 : vec3<f32> = (normalize((reflect(in_dir_9, _S764))));
    sample_1.unit_direction = _S784;
    var _S785 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S762, material_14, lobes_3, u32(2));
    sample_1.throughput = _S785;
    sample_1.random_state = random_state_13;
    sample_1.lobe = u32(2);
    var _S786 : f32 = lobeDensity(0.0f, 0.0f, _S760, _S762, lobes_3, eta_i_9, eta_o_9, u32(2));
    sample_1.pdf = _S786;
    return sample_1;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S787 : bool = pdf_6 > 0.0f;
    var _S788 : bool;
    if(_S787)
    {
        if(diffuse_0)
        {
            _S788 = true;
        }
        else
        {
            _S788 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S788 = false;
    }
    return _S788;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S789 : bool = pdf_7 > 0.0f;
    var _S790 : bool;
    if(_S789)
    {
        if(diffuse_1)
        {
            _S790 = true;
        }
        else
        {
            _S790 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S790 = false;
    }
    return _S790;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S791 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S791.x, max(_S791.y, _S791.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_8 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var arrived_end_0 : Shift;
    var _S792 : vec3<f32> = vec3<f32>(0.0f);
    var _S793 : Shift = Shift_x24init_0(_S792, 0.0f);
    var _S794 : u32 = (extractBits((r_8.path), (u32(0)), (u32(5))));
    var _S795 : u32 = (extractBits((r_8.path), (u32(5)), (u32(5))));
    var _S796 : u32 = (extractBits((r_8.path), (u32(10)), (u32(2))));
    var _S797 : u32 = (extractBits((r_8.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S798 : bool = _S797 >= u32(3);
        var _S799 : u32 = select(u32(0), u32(1), _S798);
        var _S800 : u32 = _S794 + _S799;
        var _S801 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S800 > _S801;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S793;
    }
    var _S802 : u32 = _S795 - u32(1);
    var _S803 : bool = _S797 == u32(3);
    var _S804 : u32 = select(u32(0), u32(1), _S803);
    var _S805 : u32 = _S794 + _S804;
    var _S806 : bool = _S796 == u32(0);
    var _S807 : u32 = select(_S802, _S805, _S806);
    var _S808 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_8.rc.zw))), r_8.rc.x, r_8.rc.y, u32(0), 0.0f);
    var _S809 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S810 : Ray = Ray_x24init_0(dom_4.x1, _S809);
    var ray_2 : Ray = _S810;
    var hit_2 : Hit = dom_4.hit;
    var _S811 : vec3<f32> = vec3<f32>(1.0f);
    var _S812 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S792, _S792, _S792);
    var nee_vertex_0 : NEEVertex = _S812;
    var _S813 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S813;
    var _S814 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S792, 0.0f, vec4<u32>(u32(0)), _S792, _S792);
    var chain_0 : Reservoir = _S814;
    chain_0.seed = r_8.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S792;
    var reconnection_0 : vec3<f32> = _S792;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S811;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S815 : bool = (hit_2.is_point_light) == u32(1);
        var _S816 : Surface = Surface_x24init_0(_S792, _S792, 0.0f, Material_x24init_0(_S792, _S792, 0.0f, 0.0f, 0.0f, 0.0f, _S792, _S811, 1.0f, _S792, _S792, 0.5f, 0.0f, 0.0f, _S792), false, u32(0));
        var _S817 : bool = !_S815;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S817)
        {
            var _S818 : u32 = stream(r_8.seed, b_3);
            var _S819 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S818)));
            var surface_6 : Surface = facingRay_0(_S819, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S820 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S821 : vec3<f32> = throughput_2 * _S820;
                front_n_0 = _S821;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S822 : bool = !surface_6.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_6.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S823 : bool = b_3 == u32(0);
            if(_S823)
            {
                var _S824 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S824;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S825 : vec3<f32> = front_n_0;
            var _S826 : f32 = geometry_density_2;
            scatter_0 = _S822;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S826;
            surface_5 = surface_6;
            front_n_0 = _S819.smooth_n;
            throughput_3 = _S825;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_5 = _S816;
            front_n_0 = _S792;
            throughput_3 = throughput_2;
        }
        var _S827 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S828 : Surface = surface_5;
        var _S829 : Surface = surface_5;
        var _S830 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S831 : vec2<f32> = vertexEta_0(_S828.material, _S830);
        var _S832 : bool;
        if(scatter_0)
        {
            var _S833 : bool = samplesLights(_S828.material);
            _S832 = _S833;
        }
        else
        {
            _S832 = false;
        }
        var _S834 : vec3<f32> = sideNormal(surface_5, ray_2.unit_direction);
        var _S835 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S836 : vec3<f32> = _S828.material.emissive * vec3<f32>(max(_S835, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S815)
        {
            var _S837 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S837;
        }
        else
        {
            emission_0 = _S836;
        }
        var _S838 : f32 = rgb_to_greyscale(emission_0);
        var _S839 : bool = _S838 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S839)
        {
            var _S840 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S840);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S841 : bool;
        if(replay_0)
        {
            _S841 = _S796 == u32(1);
        }
        else
        {
            _S841 = false;
        }
        var _S842 : bool;
        if(_S841)
        {
            _S842 = b_3 > _S795;
        }
        else
        {
            _S842 = false;
        }
        var _S843 : bool;
        if(_S842)
        {
            _S843 = b_3 == _S794;
        }
        else
        {
            _S843 = false;
        }
        var _S844 : bool;
        if(_S843)
        {
            var _S845 : bool = _S797 == u32(1);
            if(_S845)
            {
                _S844 = true;
            }
            else
            {
                _S844 = _S797 == u32(2);
            }
        }
        else
        {
            _S844 = false;
        }
        if(_S844)
        {
            var _S846 : bool = _S815 != (_S797 == u32(2));
            if(_S846)
            {
                return _S793;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_8.jac), density_2 / r_8.jac);
        }
        var _S847 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S848 : bool = _S847 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S849 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S850 : u32 = (insertBits((_S849), (u32(1)), (u32(10)), (u32(2))));
        var _S851 : u32 = (insertBits((_S850), (prev_0.lobe), (u32(15)), (u32(2))));
        var _S852 : bool = prev_0.inside;
        var _S853 : u32 = select(u32(0), u32(1), _S852);
        var _S854 : u32 = (insertBits((_S851), (_S853), (u32(20)), (u32(1))));
        here_0.path = _S854;
        var _S855 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S855;
        var _S856 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S856;
        var _S857 : bool;
        if(replay_0)
        {
            _S857 = _S796 == u32(1);
        }
        else
        {
            _S857 = false;
        }
        var _S858 : bool;
        if(_S857)
        {
            _S858 = b_3 == _S795;
        }
        else
        {
            _S858 = false;
        }
        var _S859 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S860 : bool;
        var _S861 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S858)
        {
            var _S862 : bool = (hit_2.instance_index) != (_S808.instance_index);
            if(_S862)
            {
                _S859 = true;
            }
            else
            {
                _S859 = (hit_2.triangle_index) != (_S808.triangle_index);
            }
            if(_S859)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S827;
            }
            if(wrong_side_0)
            {
                return _S793;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            var _S863 : bool = _S795 == _S794;
            if(_S863)
            {
                refracted_4 = _S797 == u32(1);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S863)
            {
                _S860 = _S797 == u32(0);
            }
            else
            {
                _S860 = false;
            }
            if(_S860)
            {
                var _S864 : bool = isTranslucent_0(_S828.material);
                var _S865 : u32 = stream(r_8.seed, b_3 + u32(64));
                var _S866 : TreeSample = sampleLightTree_0(ray_2.origin, _S829.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S864, _S865);
                var _S867 : bool = !_S832;
                if(_S867)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S868 : f32 = rgb_to_greyscale(_S866.radiance);
                    is_inside_4 = !(_S868 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S793;
                }
                var _S869 : f32 = _S831.x;
                var _S870 : f32 = _S831.y;
                var _S871 : u32 = (uniforms_uint.max_bounces);
                var _S872 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S866, _S829.smooth_n, _S834, _S828.material, _S869, _S870, b_3 < _S871, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S872 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S863)
            {
                _S861 = _S797 == u32(4);
            }
            else
            {
                _S861 = false;
            }
            if(_S861)
            {
                var _S873 : bool = !_S832;
                if(_S873)
                {
                    return _S793;
                }
                var _S874 : f32 = environmentPdf_0(r_8.dir);
                var _S875 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_8.dir, surface_5, _S834, _S831, is_inside_4, _S874, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S875 * r_8.radiance / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            var _S876 : u32 = (extractBits((r_8.path), (u32(19)), (u32(1))));
            var _S877 : bool = _S832 != (_S876 == u32(1));
            if(_S877)
            {
                return _S793;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S859 = b_3 == _S807;
            }
            else
            {
                _S859 = false;
            }
            if(_S859)
            {
                var _S878 : bool = !scatter_0;
                if(_S878)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S879 : bool = _S796 != u32(1);
                    if(_S879)
                    {
                        wrong_side_0 = _S796 != u32(3);
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
                var _S880 : bool = _S796 == u32(2);
                if(_S880)
                {
                    _S841 = _S832;
                }
                else
                {
                    _S841 = false;
                }
                if(_S841)
                {
                    _S841 = !_S827;
                }
                else
                {
                    _S841 = false;
                }
                if(_S841)
                {
                    _S841 = _S797 == u32(4);
                }
                else
                {
                    _S841 = false;
                }
                if(_S841)
                {
                    var _S881 : u32 = stream(r_8.seed, b_3 + u32(256));
                    var _S882 : SkySample = sampleSky_0(ray_2, surface_5, _S834, _S831, is_inside_4, _S881, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S882.color, 1.0f);
                }
                if(_S880)
                {
                    is_inside_4 = _S832;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S827;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S883 : bool = isTranslucent_0(_S828.material);
                    var _S884 : u32 = stream(r_8.seed, b_3 + u32(64));
                    var _S885 : TreeSample = sampleLightTree_0(ray_2.origin, _S829.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S883, _S884);
                    var _S886 : f32 = rgb_to_greyscale(_S885.radiance);
                    var _S887 : bool = !(_S886 > 0.0f);
                    if(_S887)
                    {
                        return _S793;
                    }
                    var _S888 : f32 = _S831.x;
                    var _S889 : f32 = _S831.y;
                    var _S890 : u32 = (uniforms_uint.max_bounces);
                    var _S891 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S885, _S829.smooth_n, _S834, _S828.material, _S888, _S889, b_3 < _S890, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S891, 1.0f);
                }
                if(_S806)
                {
                    is_inside_4 = _S797 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S815;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S806)
                {
                    is_inside_4 = _S797 == u32(1);
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
                    is_inside_4 = !_S827;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S793;
            }
            else
            {
                var _S892 : bool = !replay_0;
                if(_S892)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S893 : bool = b_3 > u32(0);
                    if(_S893)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S848)
                        {
                            var _S894 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S894;
                        }
                        else
                        {
                            if(_S827)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S895 : vec3<f32> = throughput_3 * emission_1;
                        var _S896 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S895);
                        offer(&((*sel_4)), _S896, _S895 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S832)
                    {
                        var _S897 : bool = isTranslucent_0(_S828.material);
                        var _S898 : u32 = stream(r_8.seed, b_3 + u32(64));
                        var _S899 : TreeSample = sampleLightTree_0(ray_2.origin, _S829.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S897, _S898);
                        var _S900 : f32 = _S831.x;
                        var _S901 : f32 = _S831.y;
                        var _S902 : u32 = (uniforms_uint.max_bounces);
                        var _S903 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S899, _S829.smooth_n, _S834, _S828.material, _S900, _S901, b_3 < _S902, surface_5.random_state);
                        var _S904 : vec3<f32> = throughput_3 * _S903;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S848)
                        {
                            var _S905 : vec3<f32> = safeDivide(_S904, chain_throughput_0);
                            candidate_4.radiance = _S905;
                        }
                        else
                        {
                            if(_S827)
                            {
                                candidate_4 = here_0;
                                var _S906 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_4.path = _S906;
                                candidate_4.dir = _S899.dir;
                                candidate_4.radiance = _S899.radiance;
                            }
                            else
                            {
                                var _S907 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S908 : u32 = (insertBits((_S907), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S908;
                            }
                        }
                        var _S909 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S904);
                        offer(&((*sel_4)), _S909, _S904 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S832)
                    {
                        var _S910 : bool = environmentMapped_0();
                        _S860 = _S910;
                    }
                    else
                    {
                        _S860 = false;
                    }
                    if(_S860)
                    {
                        var _S911 : u32 = (uniforms_uint.max_bounces);
                        _S861 = b_3 < _S911;
                    }
                    else
                    {
                        _S861 = false;
                    }
                    if(_S861)
                    {
                        var _S912 : u32 = stream(r_8.seed, b_3 + u32(256));
                        var _S913 : SkySample = sampleSky_0(ray_2, surface_5, _S834, _S831, is_inside_4, _S912, surface_5.random_state);
                        var _S914 : vec3<f32> = throughput_3 * _S913.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S848)
                        {
                            var _S915 : vec3<f32> = safeDivide(_S914, chain_throughput_0);
                            candidate_5.radiance = _S915;
                        }
                        else
                        {
                            if(_S827)
                            {
                                candidate_5 = here_0;
                                var _S916 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_5.path = _S916;
                                candidate_5.dir = _S913.dir;
                                candidate_5.radiance = _S913.radiance;
                            }
                            else
                            {
                                var _S917 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S918 : u32 = (insertBits((_S917), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S918;
                            }
                        }
                        var _S919 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S914);
                        offer(&((*sel_4)), _S919, _S914 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S920 : bool;
        var _S921 : bool;
        var _S922 : bool;
        var _S923 : bool;
        var _S924 : bool;
        var _S925 : bool;
        var _S926 : bool;
        var _S927 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S859 = b_3 == _S807;
            }
            else
            {
                _S859 = false;
            }
            var _S928 : u32 = (extractBits((r_8.path), (u32(15)), (u32(2))));
            var _S929 : u32 = (extractBits((r_8.path), (u32(17)), (u32(2))));
            var _S930 : u32 = select(_S928, _S929, _S858);
            var refracted_5 : bool = _S930 == u32(1);
            var _S931 : SampleBSDF = SampleBSDF_x24init_0(_S792, _S792, u32(0), false, u32(0), 0.0f);
            var lobe_7 : SampleBSDF = _S931;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S859)
            {
                var _S932 : u32 = (extractBits((r_8.path), (u32(20)), (u32(1))));
                var _S933 : bool = is_inside_4 != (_S932 == u32(1));
                if(_S933)
                {
                    return _S793;
                }
                var _S934 : bool = _S796 == u32(1);
                if(_S934)
                {
                    var _S935 : vec3<f32> = (hitPosition((_S808)));
                    dir_11 = _S935;
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
                    var _S936 : bool = isTranslucent_0(_S828.material);
                    if(_S936)
                    {
                        wrong_side_0 = _S930 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S937 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S938 : vec3<f32> = select(r_8.dir, _S937, _S934);
                        refracted_4 = (dot(_S829.smooth_n, _S938) * _S830) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S934)
                {
                    var _S939 : vec3<f32> = ray_2.origin;
                    var _S940 : Surface = surface_5;
                    var _S941 : vec3<f32> = (vec3<f32>(0) - _S829.smooth_n);
                    var _S942 : bool = is_inside_4 != refracted_4;
                    var _S943 : vec3<f32> = select(_S829.smooth_n, _S941, _S942);
                    var _S944 : vec3<f32> = (normalize((dir_11 - (_S939 + vec3<f32>(_S940.geometry_offset) * _S943))));
                    reconnection_1 = _S944;
                }
                else
                {
                    reconnection_1 = r_8.dir;
                }
                var _S945 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, _S834);
                if(_S945)
                {
                    return _S793;
                }
                var _S946 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S930;
                wrong_side_0 = false;
                reconnection_1 = _S946;
            }
            else
            {
                var _S947 : bool = !_S858;
                if(_S947)
                {
                    var _S948 : f32 = _S831.x;
                    var _S949 : f32 = _S831.y;
                    var _S950 : vec2<f32> = vec2<f32>(0.0f);
                    var _S951 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S829.smooth_n, _S828.material, _S948, _S949, surface_5.random_state, _S950);
                    var bsdf_sampled_0 : SampleBSDF = _S951;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, _S834);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S828.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S952 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, surface_5.geometry_n, _S828.material, _S948, _S949, bsdf_sampled_0.random_state, _S950);
                        bsdf_sampled_0.unit_direction = _S952.unit_direction;
                        bsdf_sampled_0.refracted = _S952.refracted;
                        bsdf_sampled_0.throughput = _S952.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S953 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, surface_5.geometry_n))) * surface_5.geometry_n;
                            bsdf_sampled_0.unit_direction = _S953;
                        }
                    }
                    var _S954 : u32 = bsdf_sampled_0.lobe;
                    var _S955 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S956 : bool = bsdf_sampled_0.refracted;
                    lobe_7 = bsdf_sampled_0;
                    var _S957 : f32 = bsdf_sampled_0.pdf;
                    var _S958 : f32 = select(_S957, 0.0f, wrong_side_1);
                    lobe_7.pdf = _S958;
                    dir_11 = _S955;
                    lobe_index_0 = _S954;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S956;
                }
                else
                {
                    dir_11 = r_8.dir;
                    lobe_index_0 = _S930;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S859)
            {
                _S860 = true;
            }
            else
            {
                _S860 = _S858;
            }
            if(_S860)
            {
                var _S959 : SampleBSDF = connectBSDF(ray_2.unit_direction, dir_11, _S829.smooth_n, _S828.material, _S831.x, _S831.y, lobe_index_0, surface_5.random_state);
                lobe_7 = _S959;
            }
            var _S960 : bool = lobe_index_0 != u32(0);
            if(_S960)
            {
                var _S961 : bool = (_S828.material.roughness) == 0.0f;
                if(_S961)
                {
                    _S861 = true;
                }
                else
                {
                    var _S962 : bool = lobe_index_0 == u32(1);
                    if(_S962)
                    {
                        _S861 = (_S831.x) == (_S831.y);
                    }
                    else
                    {
                        _S861 = false;
                    }
                }
            }
            else
            {
                _S861 = false;
            }
            var _S963 : bool = isTranslucent_0(_S828.material);
            if(_S963)
            {
                _S920 = lobe_index_0 == u32(0);
            }
            else
            {
                _S920 = false;
            }
            if(_S920)
            {
                _S921 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S921 = false;
            }
            if(_S832)
            {
                _S922 = !_S861;
            }
            else
            {
                _S922 = false;
            }
            if(_S922)
            {
                _S923 = !wrong_side_0;
            }
            else
            {
                _S923 = false;
            }
            if(_S923)
            {
                var _S964 : f32 = lobe_7.pdf;
                var _S965 : vec3<f32> = ray_2.origin;
                var _S966 : bool = isTranslucent_0(_S828.material);
                var _S967 : vec3<f32> = select(_S829.smooth_n, _S792, _S966);
                var _S968 : vec3<f32> = ray_2.origin;
                var _S969 : Surface = surface_5;
                var _S970 : vec3<f32> = (vec3<f32>(0) - _S829.smooth_n);
                var _S971 : vec3<f32> = select(_S829.smooth_n, _S970, _S921);
                var _S972 : NEEVertex = NEEVertex_x24init_0(false, _S964, _S965, _S967, _S968 + vec3<f32>(_S969.geometry_offset) * _S971);
                nee_vertex_0 = _S972;
            }
            else
            {
                var _S973 : bool = lobe_index_0 != u32(1);
                if(_S973)
                {
                    _S924 = true;
                }
                else
                {
                    _S924 = (_S831.x) != (_S831.y);
                }
                if(_S924)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S974 : bool = lobe_index_0 == u32(0);
            var _S975 : bool = withinInverseFootprint(lobe_7.pdf, _S974, prev_0.cos, hit_2.distance, threshold_2);
            var _S976 : Surface = surface_5;
            var _S977 : bool = (dot(dir_11, _S829.smooth_n) * dot(dir_11, surface_5.geometry_n)) < 0.0f;
            var _S978 : bool = !_S977;
            if(_S978)
            {
                var _S979 : bool = roughLobe(lobe_7.pdf, _S974, _S828.material.roughness);
                _S924 = _S979;
            }
            else
            {
                _S924 = false;
            }
            var throughput_6 : vec3<f32>;
            if(_S858)
            {
                var _S980 : bool = !_S975;
                if(_S980)
                {
                    return _S793;
                }
                var _S981 : bool = _S797 != u32(1);
                if(_S981)
                {
                    _S925 = _S797 != u32(2);
                }
                else
                {
                    _S925 = false;
                }
                if(_S925)
                {
                    var _S982 : f32 = lobe_7.pdf;
                    var _S983 : f32 = select(0.0f, _S982, _S832);
                    var _S984 : f32 = escapeWeight_0(_S983, r_8.dir);
                    var _S985 : bool = _S795 == _S794;
                    if(_S985)
                    {
                        is_inside_4 = _S803;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S986 : f32 = select(1.0f, _S984, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf)) * r_8.radiance * vec3<f32>(_S986) / vec3<f32>(r_8.jac), density_3 * lobe_7.pdf / r_8.jac);
                }
                var _S987 : vec3<f32> = throughput_4 * vec3<f32>(lobe_7.pdf);
                var _S988 : f32 = density_3 * lobe_7.pdf;
                throughput_6 = _S987;
                density_5 = _S988;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S925 = b_3 <= _S807;
            }
            else
            {
                _S925 = false;
            }
            if(_S925)
            {
                _S926 = _S827;
            }
            else
            {
                _S926 = false;
            }
            if(_S926)
            {
                _S927 = _S975;
            }
            else
            {
                _S927 = false;
            }
            var _S989 : bool;
            if(_S927)
            {
                _S989 = true;
            }
            else
            {
                if(_S859)
                {
                    _S989 = !_S924;
                }
                else
                {
                    _S989 = false;
                }
            }
            if(_S989)
            {
                return _S793;
            }
            var throughput_7 : vec3<f32>;
            if(_S859)
            {
                var _S990 : vec3<f32> = throughput_6 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf));
                var _S991 : f32 = lobe_7.pdf;
                throughput_7 = _S990;
                survival_probability_0 = _S991;
            }
            else
            {
                var _S992 : vec3<f32> = throughput_6 * max(lobe_7.throughput, _S792);
                throughput_7 = _S992;
                survival_probability_0 = density_5;
            }
            var _S993 : bool = !replay_0;
            var _S994 : bool;
            if(_S993)
            {
                _S994 = !_S848;
            }
            else
            {
                _S994 = false;
            }
            var _S995 : bool;
            if(_S994)
            {
                _S995 = _S827;
            }
            else
            {
                _S995 = false;
            }
            var _S996 : bool;
            if(_S995)
            {
                _S996 = _S975;
            }
            else
            {
                _S996 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S996)
            {
                chain_0 = here_0;
                var _S997 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(17)), (u32(2))));
                var _S998 : u32 = select(u32(0), u32(1), _S832);
                var _S999 : u32 = (insertBits((_S997), (_S998), (u32(19)), (u32(1))));
                chain_0.path = _S999;
                var _S1000 : f32 = chain_0.jac * lobe_7.pdf;
                chain_0.jac = _S1000;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1001 : Vertex = Vertex_x24init_0(_S924, lobe_index_0, lobe_7.pdf, abs(dot(_S976.geometry_n, dir_11)), is_inside_4);
            prev_0 = _S1001;
            var _S1002 : f32 = lobe_7.pdf;
            var _S1003 : bool = lobe_index_0 == u32(1);
            var _S1004 : bool;
            if(_S1003)
            {
                _S1004 = (_S831.x) == (_S831.y);
            }
            else
            {
                _S1004 = false;
            }
            var _S1005 : f32 = select(_S1002, sky_pdf_0, _S1004);
            var _S1006 : bool;
            if(refracted_4)
            {
                _S1006 = !_S921;
            }
            else
            {
                _S1006 = false;
            }
            var is_inside_5 : bool;
            if(_S1006)
            {
                var _S1007 : bool = !is_inside_4;
                is_inside_5 = _S1007;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_11;
            var _S1008 : Surface = surface_5;
            var _S1009 : vec3<f32> = (vec3<f32>(0) - _S829.smooth_n);
            var _S1010 : bool = is_inside_5 != _S921;
            var _S1011 : vec3<f32> = select(_S829.smooth_n, _S1009, _S1010);
            var _S1012 : vec3<f32> = ray_2.origin + vec3<f32>(_S1008.geometry_offset) * _S1011;
            ray_2.origin = _S1012;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1005;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        var _S1013 : bool = !replay_0;
        if(_S1013)
        {
            if(_S815)
            {
                var _S1014 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1015 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1016 : bool = _S1015 == u32(1);
                if(_S1016)
                {
                    var _S1017 : vec3<f32> = safeDivide(_S1014, chain_throughput_0);
                    candidate_6.radiance = _S1017;
                }
                var _S1018 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1014);
                offer(&((*sel_4)), _S1018, _S1014 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S815)
            {
                _S859 = true;
            }
            else
            {
                _S859 = scatter_0;
            }
            if(_S859)
            {
                var _S1019 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1019;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1020 : u32 = stream(r_8.seed, b_3 + u32(128));
            var _S1021 : Random = pcg(_S1020);
            var _S1022 : bool = survival_probability_0 < (_S1021.value);
            if(_S1022)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1023 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1023;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1024 : f32 = density_5 * survival_probability_0;
            density_2 = _S1024;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1025 : Ray = ray_2;
        var _S1026 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S859 = b_3 == _S807;
        }
        else
        {
            _S859 = false;
        }
        if(_S859)
        {
            wrong_side_0 = _S796 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1027 : f32 = select(4.294967296e+09f, _S1026, wrong_side_0);
        var _S1028 : Hit = (traverseInstanceBVH((_S1025), (_S817), (_S1027)));
        hit_2 = _S1028;
        if(replay_0)
        {
            refracted_4 = b_3 == _S807;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S860 = _S796 == u32(1);
        }
        else
        {
            _S860 = false;
        }
        if(_S860)
        {
            _S861 = (hit_2.instance_index) == (_S808.instance_index);
        }
        else
        {
            _S861 = false;
        }
        if(_S861)
        {
            _S920 = (hit_2.triangle_index) == (_S808.triangle_index);
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            hit_2.uv = _S808.uv;
            var _S1029 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1029;
        }
        if(replay_0)
        {
            _S921 = b_3 == _S807;
        }
        else
        {
            _S921 = false;
        }
        if(_S921)
        {
            _S922 = _S796 == u32(3);
        }
        else
        {
            _S922 = false;
        }
        if(_S922)
        {
            _S923 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S923 = false;
        }
        if(_S923)
        {
            return _S793;
        }
        var _S1030 : Reservoir = chain_0;
        var _S1031 : NEEVertex = nee_vertex_0;
        var _S1032 : Vertex = prev_0;
        var _S1033 : Hit = hit_2;
        loop
        {
            var _S1034 : bool = (_S1033.instance_index) == u32(4294967295);
            if(_S1034)
            {
                var _S1035 : bool = !_S1031.none;
                var _S1036 : f32 = select(0.0f, sky_pdf_0, _S1035);
                var _S1037 : f32 = escapeWeight_0(_S1036, ray_2.unit_direction);
                var _S1038 : vec3<f32> = environment_0(ray_2.unit_direction);
                var _S1039 : vec3<f32> = throughput_2 * _S1038;
                if(replay_0)
                {
                    var _S1040 : bool = b_3 == _S807;
                    if(_S1040)
                    {
                        _S924 = _S796 == u32(3);
                    }
                    else
                    {
                        _S924 = false;
                    }
                    if(_S924)
                    {
                        var _S1041 : Shift = Shift_x24init_0(_S1039 * vec3<f32>(_S1037) / vec3<f32>(r_8.jac), density_2 / r_8.jac);
                        _S924 = true;
                        arrived_end_0 = _S1041;
                        break;
                    }
                    if(_S806)
                    {
                        _S925 = _S803;
                    }
                    else
                    {
                        _S925 = false;
                    }
                    if(_S925)
                    {
                        _S926 = b_3 == _S794;
                    }
                    else
                    {
                        _S926 = false;
                    }
                    if(_S926)
                    {
                        _S927 = !_S1032.rough;
                    }
                    else
                    {
                        _S927 = false;
                    }
                    if(_S927)
                    {
                        var _S1042 : Shift = Shift_x24init_0(_S1039 * vec3<f32>(_S1037), 1.0f);
                        _S924 = true;
                        arrived_end_0 = _S1042;
                        break;
                    }
                    _S924 = true;
                    arrived_end_0 = _S793;
                    break;
                }
                var candidate_7 : Reservoir = _S1030;
                var _S1043 : u32 = (extractBits((_S1030.path), (u32(10)), (u32(2))));
                var _S1044 : bool = _S1043 == u32(1);
                if(_S1044)
                {
                    var _S1045 : u32 = (extractBits((_S1030.path), (u32(5)), (u32(5))));
                    var _S1046 : bool = _S1045 == b_3;
                    var _S1047 : f32 = select(_S1037, 1.0f, _S1046);
                    var _S1048 : vec3<f32> = safeDivide(_S1039 * vec3<f32>(_S1047), chain_throughput_0);
                    candidate_7.radiance = _S1048;
                }
                else
                {
                    if(_S1032.rough)
                    {
                        var _S1049 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                        var _S1050 : u32 = (insertBits((_S1049), (u32(3)), (u32(10)), (u32(2))));
                        var _S1051 : u32 = (insertBits((_S1050), (_S1032.lobe), (u32(15)), (u32(2))));
                        var _S1052 : u32 = select(u32(0), u32(1), _S1032.inside);
                        var _S1053 : u32 = (insertBits((_S1051), (_S1052), (u32(20)), (u32(1))));
                        candidate_7.path = _S1053;
                        candidate_7.jac = _S1032.pdf;
                        candidate_7.dir = ray_2.unit_direction;
                    }
                    else
                    {
                    }
                }
                var _S1054 : vec3<f32> = _S1039 * vec3<f32>(_S1037);
                var _S1055 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1054);
                offer(&((*sel_4)), _S1055, _S1054 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                _S924 = true;
                arrived_end_0 = _S793;
                break;
            }
            var _S1056 : vec3<f32> = ray_2.origin + vec3<f32>(_S1033.distance) * ray_2.unit_direction;
            ray_2.origin = _S1056;
            _S924 = false;
            arrived_end_0 = _S793;
            break;
        }
        if(_S924)
        {
            return arrived_end_0;
        }
        var _S1057 : u32 = b_3 + u32(1);
        b_3 = _S1057;
    }
    return _S793;
}

fn shift_0( dom_5 : Domain,  r_9 : Reservoir) -> Shift
{
    var _S1058 : vec3<f32> = vec3<f32>(0.0f);
    var _S1059 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1058, 0.0f, vec4<u32>(u32(0)), _S1058, _S1058), 0.0f, _S1058, u32(0));
    var sel_5 : Selection = _S1059;
    var _S1060 : bool = (r_9.w) <= 0.0f;
    if(_S1060)
    {
        return Shift_x24init_0(_S1058, 0.0f);
    }
    var _S1061 : Shift = walk_0(dom_5, r_9, true, 0.0f, &(sel_5));
    return _S1061;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1062 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1063 : bool = _S1062 != u32(4294967295);
    if(_S1063)
    {
        var _S1064 : vec2<i32> = vec2<i32>((vec2<u32>(_S1062, (_S1062 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1065 : vec3<f32> = vec3<f32>(0.0f);
        var _S1066 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1065, _S1065, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1065, 0.0f, vec4<u32>(u32(0)), _S1065, _S1065));
        var shift_job_0 : ShiftJob = _S1066;
        var _S1067 : u32 = (_S1062 >> (u32(28)));
        var _S1068 : bool = spatialJob_0(_S1064, _S1067, &(shift_job_0));
        var _S1069 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1064), (_S1067), (vec4<u32>((bitcast<vec3<u32>>((_S1069.f))), (bitcast<u32>((_S1069.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1070 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1071 : array<u32, i32(3)>;
    spatialBins_0(_S1070, &(_S1071));
    var _S1072 : array<u32, i32(3)> = _S1071;
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
        var _S1073 : bool = (_S1072[t_16]) == u32(40);
        if(_S1073)
        {
            textureStore(shift_data_out, (_S1070), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1070, _S1072, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1074 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1074));
    countShifts_0(_S1074, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1075 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1076 : bool = _S1075 != u32(4294967295);
    if(_S1076)
    {
        var _S1077 : vec2<i32> = vec2<i32>((vec2<u32>(_S1075, (_S1075 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1078 : vec3<f32> = vec3<f32>(0.0f);
        var _S1079 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1078, _S1078, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1078, 0.0f, vec4<u32>(u32(0)), _S1078, _S1078));
        var shift_job_1 : ShiftJob = _S1079;
        var _S1080 : u32 = (_S1075 >> (u32(28)));
        var _S1081 : bool = temporalJob_0(_S1077, _S1080, &(shift_job_1));
        var _S1082 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1077), (_S1080), (vec4<u32>((bitcast<vec3<u32>>((_S1082.f))), (bitcast<u32>((_S1082.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1083 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1084 : array<u32, i32(3)>;
    temporalBins_0(_S1083, &(_S1084));
    var _S1085 : array<u32, i32(3)> = _S1084;
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
        var _S1086 : bool = (_S1085[t_18]) == u32(40);
        if(_S1086)
        {
            textureStore(temporal_shifts_out, (_S1083), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1083, _S1085, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1087 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1087));
    countShifts_0(_S1087, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1088 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1088;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1089 : f32 = c_3 * p_c_1;
    var _S1090 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1089 / (_S1089 + c_t_0 * g_previous_0), _S1090 / (_S1090 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1091 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1092 : vec3<f32> = vec3<f32>(0.0f);
    var _S1093 : Domain = Domain_x24init_0(_S1092, _S1092, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1093;
    var _S1094 : bool = (currentDomain((_S1091), &(dom_6)));
    var _S1095 : bool = !_S1094;
    if(_S1095)
    {
        storeReservoir(reservoir_temp_out, (_S1091), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1092, 0.0f, vec4<u32>(u32(0)), _S1092, _S1092)), (dom_6.hit));
        return;
    }
    var _S1096 : Reservoir = (loadReservoir(reservoir_initial, (_S1091)));
    var _S1097 : vec2<i32> = temporalNeighbor_0(_S1091, dom_6);
    var _S1098 : bool = (_S1097.x) >= i32(0);
    var r_10 : Reservoir;
    if(_S1098)
    {
        var _S1099 : Reservoir = (loadReservoir(reservoir_prev, (_S1097)));
        var _S1100 : vec4<u32> = (textureLoad(duplication, (_S1097), 0, 0));
        var _S1101 : f32 = (bitcast<f32>((_S1100.x)));
        var _S1102 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1103 : bool = _S1102 == u32(1);
        var _S1104 : f32 = select(0.0f, _S1101, _S1103);
        var _S1105 : f32 = confidenceCap(_S1104);
        var _S1106 : f32 = min(_S1099.c, _S1105);
        var _S1107 : vec4<u32> = (textureLoad(temporal_shifts, (_S1091), (u32(0)), 0));
        var _S1108 : vec4<f32> = (bitcast<vec4<f32>>((_S1107)));
        var _S1109 : vec4<f32> = vec4<f32>(_S1096.f, 1.0f);
        var _S1110 : Domain = (previousDomain((_S1097)));
        var _S1111 : bool = sameDomain_0(_S1110, dom_6);
        var _S1112 : bool = !_S1111;
        var to_previous_0 : vec4<f32>;
        if(_S1112)
        {
            var _S1113 : vec4<u32> = (textureLoad(temporal_shifts, (_S1091), (u32(1)), 0));
            var _S1114 : vec4<f32> = (bitcast<vec4<f32>>((_S1113)));
            to_previous_0 = _S1114;
        }
        else
        {
            to_previous_0 = _S1109;
        }
        var _S1115 : f32 = rgb_to_greyscale(_S1096.f);
        var _S1116 : f32 = rgb_to_greyscale(_S1099.f);
        var _S1117 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1092, 0.0f, vec4<u32>(u32(0)), _S1092, _S1092), 0.0f, _S1092, u32(0));
        var sel_6 : Selection = _S1117;
        var _S1118 : u32 = (uniforms_uint.frame);
        var _S1119 : u32 = hash(_S1118);
        var _S1120 : u32 = global_invocation_id_7.x;
        var _S1121 : vec2<u32> = (uniforms_uint.render_size);
        var _S1122 : u32 = stream(_S1119, _S1120 + _S1121.x * global_invocation_id_7.y);
        var _S1123 : u32 = stream(_S1122, u32(194));
        sel_6.random_state = _S1123;
        var _S1124 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1125 : vec3<f32> = _S1108.xyz;
        var _S1126 : f32 = rgb_to_greyscale(_S1125);
        var _S1127 : vec2<f32> = temporalWeights(_S1096.c, _S1115, _S1106, _S1116, _S1124, _S1126);
        offerShifted(&(sel_6), _S1096, Shift_x24init_0(_S1096.f, 1.0f), _S1127.x);
        offerShifted(&(sel_6), _S1099, Shift_x24init_0(_S1125, _S1108.w), _S1127.y);
        var _S1128 : Reservoir = finalize(sel_6, _S1096.c + _S1106);
        r_10 = _S1128;
    }
    else
    {
        r_10 = _S1096;
    }
    storeReservoir(reservoir_temp_out, (_S1091), (r_10), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1129 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1130 : vec3<f32> = vec3<f32>(0.0f);
    var _S1131 : Domain = Domain_x24init_0(_S1130, _S1130, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1131;
    var _S1132 : bool = (currentDomain((_S1129), &(dom_7)));
    var _S1133 : bool = !_S1132;
    if(_S1133)
    {
        storeReservoir(reservoir_initial_out, (_S1129), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1130, 0.0f, vec4<u32>(u32(0)), _S1130, _S1130)), (dom_7.hit));
        return;
    }
    var _S1134 : u32 = (uniforms_uint.frame);
    var _S1135 : u32 = hash(_S1134);
    var _S1136 : u32 = global_invocation_id_8.x;
    var _S1137 : vec2<u32> = (uniforms_uint.render_size);
    var _S1138 : u32 = stream(_S1135, _S1136 + _S1137.x * global_invocation_id_8.y);
    var _S1139 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1130, 0.0f, vec4<u32>(u32(0)), _S1130, _S1130);
    var _S1140 : Selection = Selection_x24init_0(_S1139, 0.0f, _S1130, u32(0));
    var initial_0 : Selection = _S1140;
    var _S1141 : u32 = stream(_S1138, u32(193));
    initial_0.random_state = _S1141;
    var i_2 : u32 = u32(0);
    loop
    {
        var _S1142 : u32 = (uniforms_uint.samples);
        if(i_2 < _S1142)
        {
        }
        else
        {
            break;
        }
        var r_11 : Reservoir = _S1139;
        var _S1143 : u32 = stream(_S1138, i_2);
        r_11.seed = _S1143;
        var _S1144 : u32 = (uniforms_uint.samples);
        var _S1145 : Shift = walk_0(dom_7, r_11, false, 1.0f / f32(_S1144), &(initial_0));
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var _S1146 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1129), (_S1146), (dom_7.hit));
    return;
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S1147 : Random = pcg(state_2);
    var _S1148 : Random = pcg(_S1147.state);
    var _S1149 : f32 = 6.28318548202514648f * _S1147.value;
    var _S1150 : f32 = sqrt(-2.0f * clamp(log(_S1148.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1148.state, _S1150 * cos(_S1149));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1151 : RandomSphere;
    _S1151.state = state_3;
    _S1151.value = value_1;
    return _S1151;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S1152 : Random = normal_distribution(state_4);
    var _S1153 : Random = normal_distribution(_S1152.state);
    var _S1154 : Random = normal_distribution(_S1153.state);
    var _S1155 : vec3<f32> = (normalize((vec3<f32>(_S1152.value, _S1153.value, _S1154.value))));
    return RandomSphere_x24init_0(_S1154.state, _S1155);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S1156 : RandomHemisphere;
    _S1156.state = state_5;
    _S1156.value = value_2;
    return _S1156;
}

fn random_hemisphere( state_6 : u32,  normal_4 : vec3<f32>) -> RandomHemisphere
{
    var _S1157 : RandomSphere = random_sphere(state_6);
    var _S1158 : bool = (dot(_S1157.value, normal_4)) > 0.0f;
    if(_S1158)
    {
        return RandomHemisphere_x24init_0(_S1157.state, _S1157.value);
    }
    else
    {
        var _S1159 : vec3<f32> = ((-(_S1157.value)));
        return RandomHemisphere_x24init_0(_S1157.state, _S1159);
    }
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_12 : vec3<f32>) -> mat3x3<f32>
{
    var _S1160 : vec3<f32> = p1_0 - p0_0;
    var _S1161 : vec3<f32> = p2_0 - p0_0;
    var _S1162 : vec2<f32> = uv1_0 - uv0_0;
    var _S1163 : vec2<f32> = uv2_0 - uv0_0;
    var _S1164 : f32 = _S1162.x;
    var _S1165 : f32 = _S1163.y;
    var _S1166 : f32 = _S1162.y;
    var _S1167 : f32 = _S1163.x;
    var _S1168 : f32 = _S1164 * _S1165 - _S1166 * _S1167;
    var _S1169 : f32 = 1.0f / _S1168;
    var _S1170 : vec3<f32> = vec3<f32>(_S1169);
    var t_20 : vec3<f32> = (_S1160 * vec3<f32>(_S1165) - _S1161 * vec3<f32>(_S1166)) * _S1170;
    var _S1171 : vec3<f32> = (_S1161 * vec3<f32>(_S1164) - _S1160 * vec3<f32>(_S1167)) * _S1170;
    var t_21 : vec3<f32> = (normalize((t_20 - n_12 * vec3<f32>(dot(n_12, t_20)))));
    var _S1172 : bool = (dot(cross(n_12, t_21), _S1171)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1172)
    {
        var _S1173 : vec3<f32> = ((-(t_21)));
        t_22 = _S1173;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1174 : vec3<f32> = cross(n_12, t_22);
    return mat3x3<f32>(t_22, _S1174, n_12);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1175 : vec3<f32> = t1_0 - t0_0;
    var _S1176 : vec3<f32> = t2_2 - t0_0;
    var _S1177 : vec3<f32> = t2_2 - t1_0;
    var _S1178 : f32 = min(length(_S1175), min(length(_S1176), length(_S1177)));
    var _S1179 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1180 : vec3<f32> = (normalize((n0_0)));
    var _S1181 : f32 = dot(geometry_n_5, _S1180);
    var _S1182 : vec3<f32> = (normalize((n1_0)));
    var _S1183 : f32 = dot(geometry_n_5, _S1182);
    var _S1184 : vec3<f32> = (normalize((n2_0)));
    var _S1185 : vec3<f32> = acos(abs(vec3<f32>(_S1181, _S1183, dot(geometry_n_5, _S1184))));
    var _S1186 : vec3<f32> = clamp(tan(_S1185), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1179 * _S1186, uvw_0), 0.0f, _S1178 * 0.125f);
}

fn sampleHalfVector( v_6 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_6 : f32,  random_state_14 : ptr<function, u32>) -> vec3<f32>
{
    var _S1187 : vec3<f32> = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f)), &((*random_state_14)));
    return _S1187;
}

fn straightThrough( dir_12 : vec3<f32>,  n_13 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S1188 : vec3<f32> = ((-(dir_12)));
    var _S1189 : f32 = (sign((dot(n_13, _S1188))));
    var _S1190 : vec3<f32> = n_13 * vec3<f32>(_S1189);
    var _S1191 : AnisotropicFrame = anisotropicFrame(material_15, _S1190);
    var _S1192 : bool = (_S1191.alphas.x) > 0.0f;
    if(_S1192)
    {
        var _S1193 : f32 = material_15.transmission * (1.0f - material_15.metallic);
        var _S1194 : vec3<f32> = ((-(_S1190)));
        var _S1195 : vec3<f32> = anisotropicLocal(dir_12, _S1191.tangent, _S1194);
        var _S1196 : f32 = anisotropicG1(_S1195, _S1191.alphas);
        return vec3<f32>((_S1193 * _S1196)) * material_15.albedo;
    }
    var _S1197 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S1198 : f32 = material_15.roughness;
    var _S1199 : f32 = smithG1(_S1198 * _S1198, abs(dot(n_13, dir_12)));
    return vec3<f32>((_S1197 * _S1199)) * material_15.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_14 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1200 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S1201 : vec3<f32> = straightThrough(toward_1, n_14, material_16);
        _S1200 = _S1201;
    }
    else
    {
        _S1200 = vec3<f32>(0.0f);
    }
    return _S1200 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_12 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1202 : Shift = walk_0(dom_8, r_12, replay_1, scale_2, &((*sel_7)));
    return _S1202;
}

fn shift_hook( dom_9 : Domain,  r_13 : Reservoir) -> Shift
{
    var _S1203 : Shift = shift_0(dom_9, r_13);
    return _S1203;
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

