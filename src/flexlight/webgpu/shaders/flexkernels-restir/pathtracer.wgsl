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

fn sampleAnisotropicVNDF( Ve_1 : vec3<f32>,  alphas_1 : vec2<f32>,  U1_1 : f32,  U2_1 : f32) -> vec3<f32>
{
    var _S267 : f32 = alphas_1.x;
    var _S268 : f32 = alphas_1.y;
    var _S269 : vec3<f32> = (normalize((vec3<f32>(_S267 * Ve_1.x, _S268 * Ve_1.y, Ve_1.z))));
    var _S270 : vec3<f32> = sampleGGXVNDF(_S269, 1.0f, U1_1, U2_1);
    var _S271 : vec3<f32> = (normalize((vec3<f32>(_S267 * _S270.x, _S268 * _S270.y, _S270.z))));
    return _S271;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S272 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S272)
    {
        const _S273 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S273;
    }
    else
    {
        a_4 = a_3;
    }
    var _S274 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S275 : vec3<f32> = cross(n_3, _S274);
    return vec3<f32>(dot(v_1, _S274), dot(v_1, n_3), dot(v_1, _S275));
}

fn sampleMaterialHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S276 : Random = pcg((*random_state_0));
    var _S277 : Random = pcg(_S276.state);
    (*random_state_0) = _S277.state;
    var _S278 : bool = (frame_0.alphas.x) > 0.0f;
    if(_S278)
    {
        var _S279 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S280 : vec3<f32> = sampleAnisotropicVNDF(_S279, frame_0.alphas, _S276.value, _S277.value);
        return vec3<f32>(_S280.x) * frame_0.tangent + vec3<f32>(_S280.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S280.z) * n_i_1;
    }
    var _S281 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S282 : vec3<f32> = sampleGGXVNDF(_S281.xzy, alpha_1, _S276.value, _S277.value);
    var _S283 : vec3<f32> = _S282.xzy;
    var _S284 : vec3<f32> = tangentToWorld(_S283, n_i_1);
    return _S284;
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
    var _S285 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S286 : f32 = eta_i_0 / eta_o_0 * _S285;
    var _S287 : bool = _S286 < 1.0f;
    var kr_0 : f32;
    if(_S287)
    {
        var _S288 : f32 = sqrt(max(0.0f, 1.0f - _S286 * _S286));
        var _S289 : f32 = eta_o_0 * cos_theta_0;
        var _S290 : f32 = eta_i_0 * _S288;
        var _S291 : f32 = (_S289 - _S290) / (_S289 + _S290);
        var _S292 : f32 = eta_i_0 * cos_theta_0;
        var _S293 : f32 = eta_o_0 * _S288;
        var _S294 : f32 = (_S292 - _S293) / (_S292 + _S293);
        var _S295 : f32 = (_S291 * _S291 + _S294 * _S294) / 2.0f;
        kr_0 = _S295;
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
    var _S296 : f32 = sqrt(0.05000000074505806f);
    var _S297 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S298 : f32 = (clamp(sqrt(max(r_2, 0.0f)), _S296, 1.0f) - _S296) / (1.0f - _S296) * 23.0f;
    var _S299 : u32 = min(u32(_S297), u32(22));
    var _S300 : u32 = min(u32(_S298), u32(22));
    var _S301 : f32 = _S297 - f32(_S299);
    var _S302 : f32 = _S298 - f32(_S300);
    var _S303 : u32 = _S299 * u32(24) + _S300;
    var _S304 : u32 = _S303 + u32(24);
    var _S305 : f32 = SHEEN_ALBEDO_0[_S303] + (SHEEN_ALBEDO_0[_S304] - SHEEN_ALBEDO_0[_S303]) * _S301;
    var _S306 : u32 = _S303 + u32(1);
    var _S307 : f32 = SHEEN_ALBEDO_0[_S306] + (SHEEN_ALBEDO_0[_S304 + u32(1)] - SHEEN_ALBEDO_0[_S306]) * _S301;
    return exp(_S305 + (_S307 - _S305) * _S302);
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S308 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S308 / (_S308 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S308)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S309 : f32 = alphas_3.x;
    var _S310 : f32 = h_0.x / _S309;
    var _S311 : f32 = alphas_3.y;
    var _S312 : f32 = h_0.y / _S311;
    var _S313 : f32 = h_0.z;
    var _S314 : f32 = _S310 * _S310 + _S312 * _S312 + _S313 * _S313;
    return 1.0f / max(3.14159274101257324f * _S309 * _S311 * _S314 * _S314, 1.17549435082228751e-38f);
}

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_4 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S315 : BSDFLobes;
    _S315.v_dot_h = v_dot_h_0;
    _S315.n_dot_h = n_dot_h_0;
    _S315.refracted = refracted_1;
    _S315.F = F_0;
    _S315.F_greyscale = F_greyscale_0;
    _S315.reflect_weight = reflect_weight_0;
    _S315.diffuse_weight = diffuse_weight_0;
    _S315.refract_weight = refract_weight_0;
    _S315.p_diffuse = p_diffuse_0;
    _S315.p_reflect = p_reflect_0;
    _S315.p_refract = p_refract_0;
    _S315.translucent_share = translucent_share_0;
    _S315.sheen = sheen_0;
    _S315.view = view_1;
    _S315.tangent = tangent_1;
    _S315.alphas = alphas_4;
    _S315.visible = visible_0;
    return _S315;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S316 : f32 = dot(ggx_n_0, v_3);
    var _S317 : f32 = dot(n_i_2, ggx_n_0);
    var _S318 : f32 = eta_i_1 / eta_o_1;
    var _S319 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S318))));
    var _S320 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S321 : f32 = _S320 * _S320;
    var _S322 : f32 = (1.0f + _S320) / (1.0f - _S320);
    var _S323 : f32 = abs(_S316);
    var _S324 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S324)
    {
        sheen_component_0 = _S322;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S324)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S322;
    }
    var _S325 : f32 = fresnel(_S323, sheen_component_0, visible_1);
    var _S326 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S316 * _S316)) >= (eta_o_1 * eta_o_1);
    var _S327 : vec3<f32>;
    if(_S326)
    {
        _S327 = vec3<f32>(1.0f);
    }
    else
    {
        var _S328 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S321);
        _S327 = _S328 + (vec3<f32>(1.0f) - _S328) * vec3<f32>((_S325 - _S321)) / vec3<f32>((1.0f - _S321));
    }
    var _S329 : vec3<f32> = vec3<f32>(1.0f);
    var _S330 : vec3<f32> = vec3<f32>(0.0f);
    var _S331 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S332 : bool = _S331 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S332)
    {
        var _S333 : f32 = sheenAlbedo(dot(n_i_2, v_3), material_1.sheen_roughness);
        var _S334 : f32 = min(_S333, 1.0f);
        var _S335 : vec3<f32> = vec3<f32>(1.0f) - material_1.sheen * vec3<f32>(_S334);
        var _S336 : f32 = rgb_to_greyscale(material_1.sheen);
        var _S337 : f32 = _S336 * _S334;
        var _S338 : vec3<f32> = material_1.sheen / vec3<f32>(max(_S333, 1.0f));
        scale_0 = _S335;
        sheen_component_0 = _S337;
        sheen_1 = _S338;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S329;
        sheen_component_0 = 0.0f;
        sheen_1 = _S330;
        view_2 = _S330;
    }
    var _S339 : vec3<f32> = (mix((_S327), (material_1.albedo), (material_1.metallic)));
    var F_1 : vec3<f32> = _S339 * scale_0;
    var _S340 : f32 = rgb_to_greyscale(F_1);
    var _S341 : f32 = 1.0f - material_1.metallic;
    var _S342 : vec3<f32> = vec3<f32>(1.0f) - _S327;
    var _S343 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S341)) * _S342 * scale_0;
    var _S344 : vec3<f32> = vec3<f32>((material_1.transmission * _S341)) * _S342 * scale_0;
    var _S345 : f32 = max(_S340, 0.0f);
    var _S346 : f32 = rgb_to_greyscale(_S343);
    var _S347 : f32 = max(_S346, 0.0f);
    var _S348 : f32 = rgb_to_greyscale(_S344);
    var _S349 : f32 = (sign((length(_S319))));
    var _S350 : f32 = max(_S348 * _S349, 0.0f);
    var _S351 : f32 = _S345 + _S347 + _S350 + sheen_component_0;
    var _S352 : f32 = 1.0f / max(_S351, 0.0000152587890625f);
    var _S353 : f32 = (_S347 + sheen_component_0) * _S352;
    var _S354 : f32 = _S345 * _S352;
    var _S355 : f32 = _S350 * _S352;
    var _S356 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S356)
    {
        var _S357 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S358 : f32 = anisotropicG1(_S357, frame_1.alphas);
        var _S359 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S360 : f32 = anisotropicD(_S359, frame_1.alphas);
        var _S361 : f32 = _S358 * _S360;
        visible_1 = _S361;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S316, _S317, _S319, F_1, _S340, 1.0f, _S343, _S344, _S353, _S354, _S355, 0.0f, sheen_1, view_2, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S362 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S363 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S364 : f32 = _S362 / (_S363 + _S362);
    var _S365 : bool = _S362 > 0.0f;
    var _S366 : f32 = select(0.0f, _S364, _S365);
    return _S366;
}

fn smithG1( alpha_2 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S367 : f32 = alpha_2 * alpha_2;
    var _S368 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S367 + (1.0f - _S367) * n_dot_x_0 * n_dot_x_0));
    var _S369 : bool = alpha_2 > 0.0f;
    var _S370 : f32 = select(1.0f, _S368, _S369);
    return _S370;
}

fn trowbridgeReitz( alpha_3 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S371 : f32 = alpha_3 * alpha_3;
    var _S372 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S371 * n_dot_h_1 * n_dot_h_1;
    return _S371 / max(3.14159274101257324f * _S372 * _S372, 1.17549435082228751e-38f);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S373 : bool = lobe_0 == u32(0);
    if(_S373)
    {
        var _S374 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S375 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S376 : f32 = 1.0f - lobes_0.translucent_share;
        var _S377 : bool = n_i_dot_l_0 < 0.0f;
        var _S378 : f32 = select(_S376, lobes_0.translucent_share, _S377);
        var _S379 : f32 = _S375 * _S378;
        var _S380 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S381 : f32 = select(_S374, _S379, _S380);
        var _S382 : bool = n_i_dot_v_0 > 0.0f;
        var _S383 : f32 = select(0.0f, _S381, _S382);
        return _S383;
    }
    var _S384 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S385 : f32 = _S384 * lobes_0.v_dot_h;
    var _S386 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S387 : f32 = _S385 * _S386 / n_i_dot_v_0;
    var _S388 : bool = alpha_4 > 0.0f;
    var _S389 : bool;
    if(_S388)
    {
        _S389 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S389 = false;
    }
    if(_S389)
    {
        _S389 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S389 = false;
    }
    if(_S389)
    {
        _S389 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S389 = false;
    }
    var _S390 : f32 = select(0.0f, _S387, _S389);
    var _S391 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S391)
    {
        var _S392 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S393 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S393)
        {
            _S389 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S389 = false;
        }
        if(_S389)
        {
            _S389 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S389 = false;
        }
        var _S394 : f32 = select(0.0f, _S392, _S389);
        pdf_h_0 = _S394;
    }
    else
    {
        pdf_h_0 = _S390;
    }
    var _S395 : bool = lobe_0 == u32(1);
    if(_S395)
    {
        var _S396 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S397 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S396 * _S396);
        var _S398 : bool = eta_i_2 != eta_o_2;
        if(_S398)
        {
            _S389 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S389 = false;
        }
        var _S399 : f32 = select(0.0f, _S397, _S389);
        return _S399;
    }
    var _S400 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S401 : bool = pdf_h_0 > 0.0f;
    var _S402 : f32 = select(0.0f, _S400, _S401);
    return _S402;
}

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_1 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S403 : SampleBSDF;
    _S403.unit_direction = unit_direction_1;
    _S403.throughput = throughput_0;
    _S403.random_state = random_state_1;
    _S403.refracted = refracted_2;
    _S403.lobe = lobe_1;
    _S403.pdf = pdf_0;
    return _S403;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_4 : vec3<f32>,  n_4 : vec3<f32>,  r_3 : f32) -> f32
{
    var _S404 : f32 = 1.0f / max(r_3, 0.05000000074505806f);
    var _S405 : vec3<f32> = (normalize((l_0 + v_4)));
    var _S406 : f32 = dot(n_4, _S405);
    var _S407 : f32 = max(dot(n_4, l_0), 0.0f);
    var _S408 : f32 = max(dot(n_4, v_4), 0.0f);
    return (2.0f + _S404) * pow(max(1.0f - _S406 * _S406, 0.0f), 0.5f * _S404) * 0.5f * 0.31830987334251404f / max(4.0f * (_S407 + _S408 - _S407 * _S408), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes,  lobe_2 : u32) -> vec3<f32>
{
    var _S409 : bool = lobe_2 == u32(0);
    if(_S409)
    {
        var _S410 : bool = (dot(n_i_3, l_1)) < 0.0f;
        var _S411 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S410);
        var _S412 : f32 = 1.0f - lobes_1.translucent_share;
        var _S413 : f32 = select(_S412, lobes_1.translucent_share, _S410);
        var _S414 : vec3<f32> = _S411 / vec3<f32>(_S413);
        var _S415 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S416 : vec3<f32> = select(material_3.albedo, _S414, _S415);
        var _S417 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S418 : bool = _S417 > 0.0f;
        var _S419 : bool;
        if(_S418)
        {
            _S419 = !_S410;
        }
        else
        {
            _S419 = false;
        }
        if(_S419)
        {
            var _S420 : vec3<f32> = lobes_1.diffuse_weight * _S416;
            var _S421 : vec3<f32> = lobes_1.sheen * vec3<f32>(3.14159274101257324f);
            var _S422 : f32 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            var _S423 : vec3<f32> = _S421 * vec3<f32>(_S422);
            var _S424 : f32 = select(1.0f, _S412, _S415);
            return (_S420 + _S423 / vec3<f32>(_S424)) / vec3<f32>(lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S416 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S425 : bool = lobe_2 == u32(1);
    var G1_l_0 : f32;
    if(_S425)
    {
        var _S426 : f32 = - dot(n_i_3, l_1);
        var _S427 : f32 = smithG1(alpha_5, max(_S426, 0.0f));
        var _S428 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S428)
        {
            var _S429 : vec3<f32> = ((-(n_i_3)));
            var _S430 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, _S429);
            var _S431 : f32 = anisotropicG1(_S430, lobes_1.alphas);
            G1_l_0 = _S431;
        }
        else
        {
            G1_l_0 = _S427;
        }
        return lobes_1.refract_weight * vec3<f32>(G1_l_0) * material_3.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S432 : f32 = dot(n_i_3, l_1);
    var _S433 : f32 = smithG1(alpha_5, max(_S432, 0.0f));
    var _S434 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S434)
    {
        var _S435 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        var _S436 : f32 = anisotropicG1(_S435, lobes_1.alphas);
        G1_l_0 = _S436;
    }
    else
    {
        G1_l_0 = _S433;
    }
    return vec3<f32>((lobes_1.reflect_weight * G1_l_0)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S437 : vec3<f32> = ((-(in_dir_1)));
    var _S438 : f32 = dot(n_5, _S437);
    var _S439 : f32 = (sign((_S438)));
    var _S440 : vec3<f32> = n_5 * vec3<f32>(_S439);
    var _S441 : f32 = material_4.roughness;
    var _S442 : f32 = _S441 * _S441;
    var _S443 : AnisotropicFrame = anisotropicFrame(material_4, _S440);
    var _S444 : vec3<f32> = (normalize((_S437 + out_dir_0)));
    var _S445 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S445)
    {
        var _S446 : vec3<f32> = sampleMaterialHalfVector(_S437, _S440, _S442, _S443, &(random_state_2));
        ggx_n_1 = _S446;
    }
    else
    {
        var _S447 : bool = lobe_3 == u32(1);
        if(_S447)
        {
            var _S448 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S437 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S449 : vec3<f32> = (normalize((_S448)));
            var _S450 : f32 = (sign((dot(_S448, _S440))));
            var _S451 : vec3<f32> = _S449 * vec3<f32>(_S450);
            ggx_n_1 = _S451;
        }
        else
        {
            ggx_n_1 = _S444;
        }
    }
    var _S452 : BSDFLobes = bsdfLobes(in_dir_1, _S437, _S440, ggx_n_1, material_4, eta_i_3, eta_o_3, _S443);
    var lobes_2 : BSDFLobes = _S452;
    var _S453 : f32 = translucentShare(material_4);
    lobes_2.translucent_share = _S453;
    var _S454 : f32 = lobeDensity(dot(_S440, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S438), _S442, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S455 : bool = !(_S454 > 0.0f);
    if(_S455)
    {
        var _S456 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S456, _S456, u32(0), false, u32(0), 0.0f);
    }
    var _S457 : vec3<f32> = lobeThroughput(out_dir_0, _S440, _S442, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S457, random_state_2, lobe_3 == u32(1), lobe_3, _S454);
}

fn neeBSDF( in_dir_2 : vec3<f32>,  dir_4 : vec3<f32>,  n_6 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_3 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var _S458 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_1 : vec3<f32> = _S458;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S459 : bool = lobe_4 == u32(0);
        if(_S459)
        {
        }
        var _S460 : bool;
        if(_S459)
        {
            var _S461 : f32 = rgb_to_greyscale(material_5.translucent);
            _S460 = _S461 > 0.0f;
        }
        else
        {
            _S460 = false;
        }
        var _S462 : bool;
        if(_S460)
        {
            var _S463 : f32 = dot(n_6, dir_4);
            var _S464 : vec3<f32> = ((-(in_dir_2)));
            _S462 = ((_S463 * dot(n_6, _S464)) < 0.0f) == refracted_3;
        }
        else
        {
            _S462 = (lobe_4 == u32(1)) == refracted_3;
        }
        var f_2 : vec3<f32>;
        if(_S462)
        {
            var _S465 : SampleBSDF = connectBSDF(in_dir_2, dir_4, n_6, material_5, eta_i_4, eta_o_4, lobe_4, random_state_3);
            var _S466 : bool = (_S465.pdf) > 0.0f;
            if(_S466)
            {
                if(power_0)
                {
                    var _S467 : f32 = _S465.pdf / pdf_1;
                    var f_3 : vec3<f32> = f_1 + _S465.throughput * vec3<f32>(_S465.pdf) / vec3<f32>((pdf_1 * (1.0f + _S467 * _S467)));
                    f_2 = f_3;
                }
                else
                {
                    var f_4 : vec3<f32> = f_1 + _S465.throughput * vec3<f32>(_S465.pdf) / vec3<f32>((_S465.pdf + pdf_1));
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
    var _S468 : bool = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    var _S469 : vec3<f32> = neeBSDF(in_dir_3, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S468, pdf_2, false, random_state_4);
    return _S469;
}

fn SkySample_x24init_0( dir_6 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S470 : SkySample;
    _S470.dir = dir_6;
    _S470.radiance = radiance_1;
    _S470.color = color_0;
    _S470.random_state = random_state_5;
    return _S470;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S471 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S472 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S473 : vec2<u32> = _S471 - _S472;
    var _S474 : Random = pcg(init_random_state_0);
    var _S475 : Random = pcg(_S474.state);
    var _S476 : Random = pcg(_S475.state);
    var _S477 : Random = pcg(_S476.state);
    var _S478 : u32 = _S473.x;
    var _S479 : u32 = searchCDF_0(vec2<u32>(_S478, u32(0)), vec2<u32>(u32(0), u32(1)), _S473.y, _S474.value);
    var _S480 : u32 = searchCDF_0(vec2<u32>(u32(0), _S479), _S472, _S478, _S475.value);
    var _S481 : vec2<f32> = (vec2<f32>(f32(_S480), f32(_S479)) + vec2<f32>(_S476.value, _S477.value)) / vec2<f32>(_S473) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S482 : f32 = _S481.y;
    var _S483 : f32 = sin(_S482);
    var _S484 : f32 = _S481.x;
    var _S485 : vec3<f32> = vec3<f32>(_S483 * cos(_S484), cos(_S482), _S483 * sin(_S484));
    var _S486 : f32 = environmentPdf_0(_S485);
    var _S487 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S485, surface_2, eta_1, is_inside_3, _S486, lobe_state_0);
    var _S488 : bool = !(_S486 > 0.0f);
    var _S489 : bool;
    if(_S488)
    {
        _S489 = true;
    }
    else
    {
        _S489 = (all((_S487 == vec3<f32>(0.0f))));
    }
    if(_S489)
    {
        var _S490 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S485, _S490, _S490, _S477.state);
    }
    var _S491 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S485);
    return SkySample_x24init_0(_S485, _S491, _S487 * _S491, _S477.state);
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
    var _S492 : TreeSample;
    _S492.dir = dir_7;
    _S492.radiance = radiance_2;
    _S492.density = density_0;
    _S492.random_state = random_state_6;
    return _S492;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S493 : f32 = importance(first_1, p_10, normal_3);
    var _S494 : f32 = importance(second_1, p_10, normal_3);
    var _S495 : vec2<f32> = vec2<f32>(_S493, _S494);
    var _S496 : bool = _S493 == 0.0f;
    var _S497 : bool;
    if(_S496)
    {
        _S497 = _S494 == 0.0f;
    }
    else
    {
        _S497 = false;
    }
    if(_S497)
    {
        return u32(2);
    }
    var _S498 : f32 = _S493 + _S494;
    var _S499 : bool = _S494 > 0.0f;
    if(_S499)
    {
        _S497 = ((*pick_0) * _S498) >= _S493;
    }
    else
    {
        _S497 = false;
    }
    var _S500 : u32 = select(u32(0), u32(1), _S497);
    var _S501 : f32 = min(((*pick_0) * _S498 - f32(_S500) * _S493) / _S495[_S500], 0.99999994039535522f);
    (*pick_0) = _S501;
    var _S502 : f32 = (*probability_3) * (_S495[_S500] / _S498);
    (*probability_3) = _S502;
    return _S500;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S503 : vec3<f32> = center_1 - p_11;
    var _S504 : f32 = radius_1 * radius_1 / dot(_S503, _S503);
    var _S505 : f32 = u1_0 * _S504 / (1.0f + sqrt(max(1.0f - _S504, 0.0f)));
    var _S506 : f32 = 2.0f * u1_0;
    var _S507 : bool = _S504 >= 1.0f;
    var _S508 : f32 = select(_S505, _S506, _S507);
    var _S509 : f32 = sqrt(max(_S508 * (2.0f - _S508), 0.0f));
    var _S510 : f32 = 6.28318548202514648f * u2_0;
    var _S511 : vec3<f32> = vec3<f32>(_S509 * cos(_S510), 1.0f - _S508, _S509 * sin(_S510));
    var _S512 : vec3<f32> = (normalize((_S503)));
    var _S513 : vec3<f32> = tangentToWorld(_S511, _S512);
    return _S513;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S514 : vec3<f32> = center_2 - ray_1.origin;
    var _S515 : f32 = dot(_S514, ray_1.unit_direction);
    var _S516 : f32 = dot(_S514, _S514) - _S515 * _S515;
    var _S517 : f32 = radius_3 * radius_3;
    var _S518 : bool = _S516 > _S517;
    if(_S518)
    {
        return 4.294967296e+09f;
    }
    var _S519 : f32 = sqrt(_S517 - _S516);
    var _S520 : f32 = _S515 - _S519;
    var _S521 : f32 = _S515 + _S519;
    var _S522 : bool = _S520 > 0.0000152587890625f;
    var _S523 : bool;
    if(_S522)
    {
        _S523 = _S520 < max_len_0;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        return _S520;
    }
    var _S524 : bool = _S521 > 0.0000152587890625f;
    if(_S524)
    {
        _S523 = _S521 < max_len_0;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        return _S521;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S525 : Random = pcg(init_random_state_1);
    var _S526 : Random = pcg(_S525.state);
    var _S527 : Random = pcg(_S526.state);
    var _S528 : vec3<f32> = vec3<f32>(0.0f);
    var _S529 : TreeSample = TreeSample_x24init_0(_S528, _S528, 0.0f, _S527.state);
    var sample_0 : TreeSample = _S529;
    var _S530 : vec3<f32> = select(smooth_n_2, _S528, sided_0);
    var _S531 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S532 : vec3<f32> = origin_4 + _S531 * smooth_n_2;
    var pick_1 : f32 = _S525.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S533 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S533.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S534 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S535 : u32 = n_7 + u32(1);
        var _S536 : LightBounds = (lightBounds((_S535)));
        var _S537 : LightBounds = (lightBounds((_S534)));
        var _S538 : u32 = pickChild(_S536, _S537, origin_4, _S530, &(pick_1), &(probability_4));
        var _S539 : bool = _S538 > u32(1);
        if(_S539)
        {
            return sample_0;
        }
        var _S540 : bool = _S538 == u32(1);
        var _S541 : u32 = select(_S535, _S534, _S540);
        n_7 = _S541;
    }
    var _S542 : bool = n_7 == u32(0);
    var _S543 : bool;
    if(_S542)
    {
        var _S544 : LightBounds = (lightBounds((u32(0))));
        var _S545 : f32 = importance(_S544, origin_4, _S530);
        _S543 = !(_S545 > 0.0f);
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        return sample_0;
    }
    var _S546 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S547 : bool = (_S546.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S547)
    {
        var _S548 : Light = (lights[(_S546.y)]);
        if(sided_0)
        {
            var _S549 : f32 = (sign((dot(geometry_n_1, _S548.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S549);
            var _S550 : vec3<f32> = origin_4 + _S531 * lift_n_1;
            start_5 = _S550;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S532;
            lift_n_0 = smooth_n_2;
        }
        var _S551 : bool = (_S548.variance) == 0.0f;
        if(_S551)
        {
            var _S552 : vec3<f32> = _S548.position - start_5;
            var _S553 : vec3<f32> = (normalize((_S552)));
            sample_0.dir = _S553;
            var _S554 : vec3<f32> = _S548.color * vec3<f32>(_S548.intensity) / vec3<f32>((dot(_S552, _S552) * probability_4));
            sample_0.radiance = _S554;
            shadow_1 = _S552;
        }
        else
        {
            var _S555 : vec3<f32> = sampleSphere(_S548.position, _S548.variance, start_5, _S526.value, _S527.value);
            sample_0.dir = _S555;
            var _S556 : f32 = sphereDensity(_S548.position, _S548.variance, start_5);
            var _S557 : f32 = probability_4 * _S556;
            sample_0.density = _S557;
            var _S558 : vec3<f32> = pointLightRadiance(_S548.color, _S548.intensity, _S548.variance);
            var _S559 : vec3<f32> = _S558 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S559;
            var _S560 : f32 = raySphere_0(_S548.position, _S548.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S561 : vec3<f32> = sample_0.dir * vec3<f32>(_S560);
            shadow_1 = _S561;
        }
    }
    else
    {
        var _S562 : u32 = _S546.y;
        var _S563 : u32 = ((instance_uint[(_S562) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S564 : u32 = _S563 + _S546.z;
        var _S565 : mat3x3<f32> = (worldTriangle((_S562), (_S564)));
        var _S566 : f32 = sqrt(_S526.value);
        var _S567 : vec2<f32> = vec2<f32>(_S566 * (1.0f - _S527.value), _S566 * _S527.value);
        var _S568 : vec3<f32> = (((_S565) * (vec3<f32>(1.0f - _S566, _S567))));
        if(sided_0)
        {
            var _S569 : f32 = (sign((dot(geometry_n_1, _S568 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S569);
            var _S570 : vec3<f32> = origin_4 + _S531 * lift_n_2;
            start_5 = _S570;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S571 : bool = !((dot(smooth_n_2, _S568 - origin_4)) > 0.0f);
            if(_S571)
            {
                return sample_0;
            }
            start_5 = _S532;
            lift_n_0 = smooth_n_2;
        }
        var _S572 : Surface = (surfaceAt((Hit_x24init_0(_S567, _S562, _S564, u32(0), 0.0f)), (_S568), (_S527.state)));
        sample_0.random_state = _S572.random_state;
        var _S573 : vec3<f32> = _S568 - start_5;
        var _S574 : vec3<f32> = (normalize((_S573)));
        sample_0.dir = _S574;
        var _S575 : f32 = solidAngle(probability_4, cross(_S565[i32(1)] - _S565[i32(0)], _S565[i32(2)] - _S565[i32(0)]), _S573);
        sample_0.density = _S575;
        var _S576 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S572.smooth_n))));
        var _S577 : vec3<f32> = _S572.material.emissive * vec3<f32>(max(_S576, 0.0f));
        var _S578 : vec3<f32> = select(_S577, _S528, _S572.skip);
        var _S579 : vec3<f32> = _S578 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S579;
        shadow_1 = _S573;
    }
    var _S580 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S581 : vec3<f32> = sample_0.radiance * _S580;
    var _S582 : bool = (all((_S580 == _S528)));
    var _S583 : vec3<f32> = select(_S581, _S528, _S582);
    sample_0.radiance = _S583;
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
    var _S584 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S585 : bool = b_1 > 0.0f;
    var _S586 : f32 = select(1.0f, _S584, _S585);
    return _S586;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S587 : u32 = (lightSlot((hit_1)));
    var _S588 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S587, light_point_1);
    var _S589 : f32 = powerHeuristic(vertex_0.pdf, _S588);
    return _S589;
}

fn environment_0( dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S590 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S591 : bool = (_S590.x) > u32(1);
    var _S592 : bool;
    if(_S591)
    {
        var _S593 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S592 = (_S593.y) > u32(1);
    }
    else
    {
        _S592 = false;
    }
    if(_S592)
    {
        var _S594 : vec3<f32> = (env_map_sample((dir_8)));
        return _S594;
    }
    var _S595 : vec3<f32> = (uniforms_float.ambient);
    return _S595;
}

fn environmentMapped_0() -> bool
{
    var _S596 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S597 : bool = (_S596.x) > u32(1);
    var _S598 : bool;
    if(_S597)
    {
        var _S599 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S598 = (_S599.y) > u32(1);
    }
    else
    {
        _S598 = false;
    }
    return _S598;
}

fn escapeWeight_0( pdf_3 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S600 : bool = pdf_3 <= 0.0f;
    var _S601 : bool;
    if(_S600)
    {
        _S601 = true;
    }
    else
    {
        var _S602 : bool = environmentMapped_0();
        _S601 = !_S602;
    }
    if(_S601)
    {
        return 1.0f;
    }
    var _S603 : f32 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S603);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S604 : vec2<u32> = global_invocation_id_1.xy;
    var _S605 : vec2<i32> = vec2<i32>(_S604 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S606 : vec2<i32> = _S605 + vec2<i32>(i32(i_0 % u32(24)), i32(i_0 / u32(24)));
        var _S607 : bool = (all((_S606 >= vec2<i32>(i32(0)))));
        var _S608 : bool;
        if(_S607)
        {
            var _S609 : vec2<u32> = (uniforms_uint.render_size);
            _S608 = (all((_S606 < vec2<i32>(_S609))));
        }
        else
        {
            _S608 = false;
        }
        if(_S608)
        {
            var _S610 : vec4<u32> = (textureLoad(reservoir_prev, (_S606), (u32(0)), 0));
            var _S611 : u32 = _S610.x;
            var _S612 : bool = (bitcast<f32>((_S610.z))) > 0.0f;
            var _S613 : u32 = select(u32(0), _S611, _S612);
            seed_1 = _S613;
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
    var _S614 : u32 = local_invocation_id_0.y;
    var _S615 : u32 = local_invocation_id_0.x;
    var _S616 : u32 = duplication_seeds_0[(_S614 + u32(8)) * u32(24) + _S615 + u32(8)];
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
            var _S617 : bool = (duplication_seeds_0[(_S614 + seed_1) * u32(24) + _S615 + x_1]) == _S616;
            var _S618 : u32 = select(u32(0), u32(1), _S617);
            var count_2 : u32 = count_1 + _S618;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S619 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S620 : bool = _S616 != u32(0);
    var _S621 : f32 = select(0.0f, _S619, _S620);
    textureStore(duplication_out, (vec2<i32>(_S604)), 0, (vec4<u32>((bitcast<u32>((_S621))), u32(0), u32(0), u32(0))));
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
    var _S622 : Selection;
    _S622.r = r_4;
    _S622.w_sum = w_sum_0;
    _S622.color = color_2;
    _S622.random_state = random_state_7;
    return _S622;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S623 : u32 = hash(index_0);
    var _S624 : u32 = hash((seed_2 ^ (_S623)));
    return _S624;
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
    var _S625 : Shift;
    _S625.f = f_5;
    _S625.jac = jac_1;
    return _S625;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S626 : f32 = rgb_to_greyscale(weight_0);
    var _S627 : bool = _S626 > 0.0f;
    var _S628 : bool;
    if(_S627)
    {
        _S628 = _S626 < 3.00000000549775576e+38f;
    }
    else
    {
        _S628 = false;
    }
    var _S629 : bool = !_S628;
    if(_S629)
    {
        return;
    }
    var _S630 : f32 = (*sel_0).w_sum + _S626;
    (*sel_0).w_sum = _S630;
    var _S631 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S631;
    var _S632 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S632.state;
    var _S633 : bool = (_S632.value * (*sel_0).w_sum) <= _S626;
    if(_S633)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_5 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_5;
    var _S634 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S634;
    var _S635 : f32 = r_5.jac * shifted_0.jac;
    candidate_1.jac = _S635;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_5.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_6 : Reservoir = sel_2.r;
    var _S636 : f32 = rgb_to_greyscale(r_6.f);
    var _S637 : f32 = sel_2.w_sum / _S636;
    var _S638 : bool = _S636 > 0.0f;
    var _S639 : f32 = select(0.0f, _S637, _S638);
    r_6.w = _S639;
    r_6.c = c_2;
    return r_6;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S640 : vec2<u32> = global_invocation_id_2.xy;
    var _S641 : vec2<i32> = vec2<i32>(_S640);
    var _S642 : vec3<f32> = vec3<f32>(0.0f);
    var _S643 : Domain = Domain_x24init_0(_S642, _S642, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S643;
    var _S644 : bool = (currentDomain((_S641), &(dom_3)));
    var _S645 : bool = !_S644;
    if(_S645)
    {
        storeReservoir(reservoir_prev_out, (_S641), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S642, 0.0f, vec4<u32>(u32(0)), _S642, _S642)), (dom_3.hit));
        var _S646 : vec2<f32> = vec2<f32>(_S640);
        var _S647 : vec2<u32> = (uniforms_uint.render_size);
        var _S648 : vec2<f32> = _S646 / vec2<f32>(_S647.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S649 : vec3<f32> = vec3<f32>(_S648, 1.0f);
        var _S650 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S651 : vec3<f32> = (normalize(((((_S650) * (_S649))))));
        var _S652 : vec3<f32> = environment_0(_S651);
        textureStore(compute_out, (_S641), (u32(0)), (vec4<f32>(_S652, 1.0f)));
        var _S653 : u32 = (uniforms_uint.is_temporal);
        var _S654 : bool = _S653 == u32(1);
        if(_S654)
        {
            textureStore(compute_out, (_S641), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S655 : Reservoir = (loadReservoir(reservoir_temp, (_S641)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S655.c;
    loop
    {
        var _S656 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S656)
        {
        }
        else
        {
            break;
        }
        var _S657 : vec2<i32> = partner_0(_S641, t_13);
        var neighbor_0 : Domain = _S643;
        var _S658 : bool = (currentDomain((_S657), &(neighbor_0)));
        if(_S658)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S659 : vec4<u32> = (textureLoad(reservoir_temp, (_S657), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S659.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S660 : f32 = _S655.c / max(count_3, 1.0f);
    var _S661 : f32 = rgb_to_greyscale(_S655.f);
    var _S662 : bool = count_3 == 0.0f;
    var _S663 : f32 = select(0.0f, 1.0f, _S662);
    var _S664 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S642, 0.0f, vec4<u32>(u32(0)), _S642, _S642), 0.0f, _S642, u32(0));
    var sel_3 : Selection = _S664;
    var _S665 : u32 = (uniforms_uint.frame);
    var _S666 : u32 = hash(_S665);
    var _S667 : u32 = global_invocation_id_2.x;
    var _S668 : vec2<u32> = (uniforms_uint.render_size);
    var _S669 : u32 = stream(_S666, _S667 + _S668.x * global_invocation_id_2.y);
    var _S670 : u32 = stream(_S669, u32(195));
    sel_3.random_state = _S670;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S663;
    loop
    {
        var _S671 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S671)
        {
        }
        else
        {
            break;
        }
        var _S672 : vec2<i32> = partner_0(_S641, t_13);
        var neighbor_dom_0 : Domain = _S643;
        var _S673 : bool = (currentDomain((_S672), &(neighbor_dom_0)));
        if(_S673)
        {
            var _S674 : Reservoir = (loadReservoir(reservoir_temp, (_S672)));
            var _S675 : vec4<u32> = (textureLoad(shift_data, (_S672), (t_13), 0));
            var _S676 : vec4<f32> = (bitcast<vec4<f32>>((_S675)));
            var _S677 : vec4<u32> = (textureLoad(shift_data, (_S641), (t_13), 0));
            var _S678 : vec4<f32> = (bitcast<vec4<f32>>((_S677)));
            var _S679 : f32 = pairShare(_S674.c, _S660, c_sum_1);
            var _S680 : bool = _S661 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S680)
            {
                var _S681 : f32 = rgb_to_greyscale(_S678.xyz);
                var _S682 : f32 = canonicalWeight(_S679, _S660, _S661, _S674.c, _S681);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S682;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S683 : vec3<f32> = _S676.xyz;
            var _S684 : Shift = Shift_x24init_0(_S683, _S676.w);
            var _S685 : f32 = rgb_to_greyscale(_S674.f);
            var _S686 : f32 = rgb_to_greyscale(_S683);
            var _S687 : f32 = neighborWeight(_S679, _S674.c, _S685, _S660, _S686);
            offerShifted(&(sel_3), _S674, _S684, _S687);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S655, Shift_x24init_0(_S655.f, 1.0f), canonical_mis_0);
    var _S688 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S641), (_S688), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S641), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S689 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S690 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S691 : f32 = (sign((dot(_S690, _S689.smooth_n))));
    var _S692 : vec3<f32> = _S689.material.emissive * vec3<f32>(max(_S691, 0.0f));
    var _S693 : vec3<f32> = select(_S692, _S642, _S689.skip);
    var _S694 : vec3<f32> = clamp(sel_3.color + _S693, _S642, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S641), (u32(0)), (vec4<f32>(_S694, 1.0f)));
    var _S695 : u32 = (uniforms_uint.is_temporal);
    var _S696 : bool = _S695 == u32(1);
    if(_S696)
    {
        textureStore(compute_out, (_S641), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_4 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S697 : NEEVertex;
    _S697.none = none_0;
    _S697.pdf = pdf_4;
    _S697.origin = origin_5;
    _S697.smooth_n = smooth_n_3;
    _S697.start = start_6;
    return _S697;
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
    var _S698 : Vertex;
    _S698.rough = rough_0;
    _S698.lobe = lobe_6;
    _S698.pdf = pdf_5;
    _S698.cos = cos_0;
    _S698.inside = inside_0;
    return _S698;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>) -> Material
{
    var _S699 : Material;
    _S699.albedo = albedo_0;
    _S699.emissive = emissive_0;
    _S699.roughness = roughness_0;
    _S699.metallic = metallic_0;
    _S699.transmission = transmission_0;
    _S699.ior = ior_0;
    _S699.absorption = absorption_0;
    _S699.specular_tint = specular_tint_0;
    _S699.specular_level = specular_level_0;
    _S699.translucent = translucent_0;
    _S699.sheen = sheen_2;
    _S699.sheen_roughness = sheen_roughness_0;
    _S699.anisotropy = anisotropy_0;
    _S699.anisotropic_rotation = anisotropic_rotation_0;
    _S699.tangent = tangent_2;
    return _S699;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_6 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S700 : Surface;
    _S700.smooth_n = smooth_n_4;
    _S700.geometry_n = geometry_n_2;
    _S700.geometry_offset = geometry_offset_2;
    _S700.material = material_6;
    _S700.skip = skip_0;
    _S700.random_state = random_state_8;
    return _S700;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S701 : bool = transmission_1 > 0.0f;
    var _S702 : bool;
    if(_S701)
    {
        _S702 = true;
    }
    else
    {
        _S702 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S703 : f32;
    if(_S702)
    {
        _S703 = 1.0f;
    }
    else
    {
        _S703 = -1.0f;
    }
    return _S703;
}

fn facingRay_0( surface_3 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S704 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_10);
    var _S705 : vec3<f32> = vec3<f32>(_S704);
    return Surface_x24init_0(surface_3.smooth_n * _S705, surface_3.geometry_n * _S705, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S706 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S706));
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
    var _S707 : bool;
    if(open_0)
    {
        _S707 = prev_rough_0;
    }
    else
    {
        _S707 = false;
    }
    if(_S707)
    {
        _S707 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S707 = false;
    }
    return _S707;
}

fn vertexEta_0( material_7 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S708 : bool = n_dot_v_0 < 0.0f;
    var _S709 : f32 = select(1.0f, material_7.ior, _S708);
    var _S710 : f32 = select(material_7.ior, 1.0f, _S708);
    return vec2<f32>(_S709, _S710);
}

fn samplesLights( material_8 : Material) -> bool
{
    var _S711 : bool = (material_8.roughness) > 0.0f;
    var _S712 : bool;
    if(_S711)
    {
        _S712 = true;
    }
    else
    {
        var _S713 : bool = (material_8.metallic) < 1.0f;
        if(_S713)
        {
            _S712 = (material_8.transmission) < 1.0f;
        }
        else
        {
            _S712 = false;
        }
    }
    return _S712;
}

fn isTranslucent_0( material_9 : Material) -> bool
{
    var _S714 : f32 = rgb_to_greyscale(material_9.translucent);
    return _S714 > 0.0f;
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_8 : vec3<f32>,  g_n_0 : vec3<f32>,  material_10 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S715 : vec3<f32> = ((-(in_dir_4)));
    var _S716 : bool = (dot(g_n_0, _S715) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S716)
    {
        var _S717 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(0), random_state_9);
        var _S718 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(2), random_state_9);
        return _S717.throughput * vec3<f32>(_S717.pdf) + _S718.throughput * vec3<f32>(_S718.pdf);
    }
    var _S719 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(1), random_state_9);
    return _S719.throughput * vec3<f32>(_S719.pdf);
}

fn translucentCorrection( in_dir_5 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_1 : vec3<f32>,  material_11 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S720 : f32 = dot(n_9, out_dir_2);
    var _S721 : vec3<f32> = ((-(in_dir_5)));
    var _S722 : bool = (_S720 * dot(n_9, _S721)) < 0.0f;
    var _S723 : SampleBSDF = connectBSDF(in_dir_5, out_dir_2, n_9, material_11, eta_i_6, eta_o_6, u32(0), random_state_10);
    var _S724 : vec3<f32> = ((-(in_dir_5)));
    var _S725 : bool = (dot(g_n_1, _S724) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S726 : vec3<f32> = vec3<f32>(0.0f);
    var _S727 : vec3<f32> = _S723.throughput * vec3<f32>(_S723.pdf);
    var _S728 : f32 = select(1.0f, -1.0f, _S725);
    var _S729 : vec3<f32> = _S727 * vec3<f32>(_S728);
    var _S730 : vec3<f32> = select(_S726, _S729, _S722);
    return _S730;
}

fn translucentBSDF( in_dir_6 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_2 : vec3<f32>,  material_12 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S731 : vec3<f32> = BSDF(in_dir_6, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    var _S732 : vec3<f32> = translucentCorrection(in_dir_6, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    return _S731 + _S732;
}

fn lightBSDF_0( in_dir_7 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S733 : bool = !competing_0;
    var _S734 : bool;
    if(_S733)
    {
        _S734 = true;
    }
    else
    {
        _S734 = (light_0.density) == 0.0f;
    }
    if(_S734)
    {
        var _S735 : bool = isTranslucent_0(material_13);
        if(_S735)
        {
            var _S736 : vec3<f32> = translucentBSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
            return _S736 * light_0.radiance;
        }
        var _S737 : vec3<f32> = BSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
        return _S737 * light_0.radiance;
    }
    var _S738 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_7)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S739 : vec3<f32> = neeBSDF(in_dir_7, light_0.dir, smooth_n_5, material_13, eta_i_8, eta_o_8, _S738, light_0.density, true, random_state_12);
    return _S739 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S740 : vec3<f32> = a_6 / b_2;
    var _S741 : vec3<f32> = vec3<f32>(0.0f);
    var _S742 : vec3<bool> = b_2 == _S741;
    var _S743 : vec3<f32> = select(_S740, _S741, _S742);
    return _S743;
}

fn withEnd( r_7 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_7;
    var _S744 : u32 = (insertBits((r_7.path), (end_0), (u32(0)), (u32(5))));
    var _S745 : u32 = (insertBits((_S744), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S745;
    candidate_2.f = f_6;
    return candidate_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S746 : f32 = sqrt(random_1_0);
    var _S747 : f32 = 6.28318548202514648f * random_2_0;
    var _S748 : f32 = _S746 * cos(_S747);
    var _S749 : f32 = _S746 * sin(_S747);
    var _S750 : f32 = sqrt(max(0.0f, 1.0f - _S748 * _S748 - _S749 * _S749));
    return vec3<f32>(_S748, _S750, _S749);
}

fn sampleBSDF( in_dir_8 : vec3<f32>,  n_11 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_1;
    var _S751 : vec3<f32> = ((-(in_dir_8)));
    var _S752 : f32 = dot(n_11, _S751);
    var _S753 : f32 = (sign((_S752)));
    var n_i_4 : vec3<f32> = n_11 * vec3<f32>(_S753);
    var _S754 : f32 = abs(_S752);
    var _S755 : f32 = material_14.roughness;
    var _S756 : f32 = _S755 * _S755;
    var _S757 : AnisotropicFrame = anisotropicFrame(material_14, n_i_4);
    var _S758 : vec3<f32> = sampleMaterialHalfVector(_S751, n_i_4, _S756, _S757, &(random_state_13));
    var _S759 : BSDFLobes = bsdfLobes(in_dir_8, _S751, n_i_4, _S758, material_14, eta_i_9, eta_o_9, _S757);
    var lobes_3 : BSDFLobes = _S759;
    var _S760 : f32 = translucentShare(material_14);
    lobes_3.translucent_share = _S760;
    var _S761 : vec3<f32> = vec3<f32>(1.0f);
    var _S762 : SampleBSDF = SampleBSDF_x24init_0(_S761, _S761, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S762;
    var _S763 : Random = pcg(random_state_13);
    random_state_13 = _S763.state;
    var _S764 : bool = (_S763.value) < (lobes_3.p_diffuse);
    if(_S764)
    {
        var _S765 : Random = pcg(random_state_13);
        var _S766 : Random = pcg(_S765.state);
        sample_1.random_state = _S766.state;
        var _S767 : vec3<f32> = sampleCosWeightedHemisphere(_S765.value, _S766.value);
        var _S768 : bool = (_S763.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S769 : f32 = _S767.y;
        var _S770 : f32 = - _S769;
        var _S771 : f32 = select(_S769, _S770, _S768);
        var _S772 : vec3<f32> = tangentToWorld(vec3<f32>(_S767.x, _S771, _S767.z), n_i_4);
        sample_1.unit_direction = _S772;
        var _S773 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S756, material_14, lobes_3, u32(0));
        sample_1.throughput = _S773;
        var _S774 : f32 = lobeDensity(_S771, 0.0f, _S754, _S756, lobes_3, eta_i_9, eta_o_9, u32(0));
        sample_1.pdf = _S774;
        sample_1.refracted = _S768;
        return sample_1;
    }
    var _S775 : bool = (_S763.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S775)
    {
        sample_1.unit_direction = lobes_3.refracted;
        var _S776 : f32 = lobeDensity(0.0f, dot(sample_1.unit_direction, _S758), _S754, _S756, lobes_3, eta_i_9, eta_o_9, u32(1));
        sample_1.pdf = _S776;
        var _S777 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S756, material_14, lobes_3, u32(1));
        sample_1.throughput = _S777;
        sample_1.random_state = random_state_13;
        sample_1.refracted = true;
        sample_1.lobe = u32(1);
        return sample_1;
    }
    var _S778 : vec3<f32> = (normalize((reflect(in_dir_8, _S758))));
    sample_1.unit_direction = _S778;
    var _S779 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S756, material_14, lobes_3, u32(2));
    sample_1.throughput = _S779;
    sample_1.random_state = random_state_13;
    sample_1.lobe = u32(2);
    var _S780 : f32 = lobeDensity(0.0f, 0.0f, _S754, _S756, lobes_3, eta_i_9, eta_o_9, u32(2));
    sample_1.pdf = _S780;
    return sample_1;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S781 : bool = pdf_6 > 0.0f;
    var _S782 : bool;
    if(_S781)
    {
        if(diffuse_0)
        {
            _S782 = true;
        }
        else
        {
            _S782 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S782 = false;
    }
    return _S782;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S783 : bool = pdf_7 > 0.0f;
    var _S784 : bool;
    if(_S783)
    {
        if(diffuse_1)
        {
            _S784 = true;
        }
        else
        {
            _S784 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S784 = false;
    }
    return _S784;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S785 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S785.x, max(_S785.y, _S785.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_8 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S786 : vec3<f32> = vec3<f32>(0.0f);
    var _S787 : Shift = Shift_x24init_0(_S786, 0.0f);
    var _S788 : u32 = (extractBits((r_8.path), (u32(0)), (u32(5))));
    var _S789 : u32 = (extractBits((r_8.path), (u32(5)), (u32(5))));
    var _S790 : u32 = (extractBits((r_8.path), (u32(10)), (u32(2))));
    var _S791 : u32 = (extractBits((r_8.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S792 : bool = _S791 >= u32(3);
        var _S793 : u32 = select(u32(0), u32(1), _S792);
        var _S794 : u32 = _S788 + _S793;
        var _S795 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S794 > _S795;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S787;
    }
    var _S796 : u32 = _S789 - u32(1);
    var _S797 : bool = _S791 == u32(3);
    var _S798 : u32 = select(u32(0), u32(1), _S797);
    var _S799 : u32 = _S788 + _S798;
    var _S800 : bool = _S790 == u32(0);
    var _S801 : u32 = select(_S796, _S799, _S800);
    var _S802 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_8.rc.zw))), r_8.rc.x, r_8.rc.y, u32(0), 0.0f);
    var _S803 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S804 : Ray = Ray_x24init_0(dom_4.x1, _S803);
    var ray_2 : Ray = _S804;
    var hit_2 : Hit = dom_4.hit;
    var _S805 : vec3<f32> = vec3<f32>(1.0f);
    var _S806 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S786, _S786, _S786);
    var nee_vertex_0 : NEEVertex = _S806;
    var _S807 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S807;
    var _S808 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S786, 0.0f, vec4<u32>(u32(0)), _S786, _S786);
    var chain_0 : Reservoir = _S808;
    chain_0.seed = r_8.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S786;
    var reconnection_0 : vec3<f32> = _S786;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S805;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S809 : bool = (hit_2.is_point_light) == u32(1);
        var _S810 : Surface = Surface_x24init_0(_S786, _S786, 0.0f, Material_x24init_0(_S786, _S786, 0.0f, 0.0f, 0.0f, 0.0f, _S786, _S805, 1.0f, _S786, _S786, 0.5f, 0.0f, 0.0f, _S786), false, u32(0));
        var _S811 : bool = !_S809;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_4 : Surface;
        if(_S811)
        {
            var _S812 : u32 = stream(r_8.seed, b_3);
            var _S813 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S812)));
            var surface_5 : Surface = facingRay_0(_S813, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S814 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S815 : vec3<f32> = throughput_2 * _S814;
                front_n_0 = _S815;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S816 : bool = !surface_5.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_5.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S817 : bool = b_3 == u32(0);
            if(_S817)
            {
                var _S818 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S818;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S819 : vec3<f32> = front_n_0;
            var _S820 : f32 = geometry_density_2;
            scatter_0 = _S816;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S820;
            surface_4 = surface_5;
            front_n_0 = _S813.smooth_n;
            throughput_3 = _S819;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_4 = _S810;
            front_n_0 = _S786;
            throughput_3 = throughput_2;
        }
        var _S821 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S822 : Surface = surface_4;
        var _S823 : Surface = surface_4;
        var _S824 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S825 : vec2<f32> = vertexEta_0(_S822.material, _S824);
        var _S826 : bool;
        if(scatter_0)
        {
            var _S827 : bool = samplesLights(_S822.material);
            _S826 = _S827;
        }
        else
        {
            _S826 = false;
        }
        var _S828 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S829 : vec3<f32> = _S822.material.emissive * vec3<f32>(max(_S828, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S809)
        {
            var _S830 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S830;
        }
        else
        {
            emission_0 = _S829;
        }
        var _S831 : f32 = rgb_to_greyscale(emission_0);
        var _S832 : bool = _S831 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S832)
        {
            var _S833 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S833);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S834 : bool;
        if(replay_0)
        {
            _S834 = _S790 == u32(1);
        }
        else
        {
            _S834 = false;
        }
        var _S835 : bool;
        if(_S834)
        {
            _S835 = b_3 > _S789;
        }
        else
        {
            _S835 = false;
        }
        var _S836 : bool;
        if(_S835)
        {
            _S836 = b_3 == _S788;
        }
        else
        {
            _S836 = false;
        }
        var _S837 : bool;
        if(_S836)
        {
            var _S838 : bool = _S791 == u32(1);
            if(_S838)
            {
                _S837 = true;
            }
            else
            {
                _S837 = _S791 == u32(2);
            }
        }
        else
        {
            _S837 = false;
        }
        if(_S837)
        {
            var _S839 : bool = _S809 != (_S791 == u32(2));
            if(_S839)
            {
                return _S787;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_8.jac), density_2 / r_8.jac);
        }
        var _S840 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S841 : bool = _S840 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S842 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S843 : u32 = (insertBits((_S842), (u32(1)), (u32(10)), (u32(2))));
        var _S844 : u32 = (insertBits((_S843), (prev_0.lobe), (u32(15)), (u32(2))));
        var _S845 : bool = prev_0.inside;
        var _S846 : u32 = select(u32(0), u32(1), _S845);
        var _S847 : u32 = (insertBits((_S844), (_S846), (u32(20)), (u32(1))));
        here_0.path = _S847;
        var _S848 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S848;
        var _S849 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S849;
        var _S850 : bool;
        if(replay_0)
        {
            _S850 = _S790 == u32(1);
        }
        else
        {
            _S850 = false;
        }
        var _S851 : bool;
        if(_S850)
        {
            _S851 = b_3 == _S789;
        }
        else
        {
            _S851 = false;
        }
        var _S852 : bool = b_3 == _S801;
        var _S853 : bool;
        if(_S852)
        {
            var _S854 : bool = !scatter_0;
            if(_S854)
            {
                _S853 = true;
            }
            else
            {
                var _S855 : bool = _S790 != u32(1);
                if(_S855)
                {
                    _S853 = _S790 != u32(3);
                }
                else
                {
                    _S853 = false;
                }
            }
        }
        else
        {
            _S853 = false;
        }
        var _S856 : bool;
        if(_S853)
        {
            _S856 = _S790 == u32(2);
        }
        else
        {
            _S856 = false;
        }
        var _S857 : bool;
        if(_S856)
        {
            _S857 = !_S821;
        }
        else
        {
            _S857 = false;
        }
        var _S858 : bool;
        if(_S857)
        {
            _S858 = _S791 != u32(4);
        }
        else
        {
            _S858 = false;
        }
        var _S859 : bool = _S789 == _S788;
        var _S860 : bool;
        if(_S859)
        {
            _S860 = _S791 == u32(0);
        }
        else
        {
            _S860 = false;
        }
        var _S861 : bool;
        if(_S860)
        {
            _S861 = (hit_2.instance_index) == (_S802.instance_index);
        }
        else
        {
            _S861 = false;
        }
        var _S862 : bool;
        if(_S861)
        {
            _S862 = (hit_2.triangle_index) == (_S802.triangle_index);
        }
        else
        {
            _S862 = false;
        }
        var _S863 : bool;
        if(_S862)
        {
            _S863 = _S821;
        }
        else
        {
            _S863 = false;
        }
        var _S864 : bool = select(_S858, _S863, _S851);
        var _S865 : bool;
        if(_S826)
        {
            _S865 = select(scatter_0, _S864, replay_0);
        }
        else
        {
            _S865 = false;
        }
        var _S866 : TreeSample = TreeSample_x24init_0(_S786, _S786, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S865)
        {
            var _S867 : Surface = surface_4;
            var _S868 : bool = isTranslucent_0(_S822.material);
            var _S869 : u32 = stream(r_8.seed, b_3 + u32(64));
            var _S870 : TreeSample = sampleLightTree_0(ray_2.origin, _S823.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S868, _S869);
            var _S871 : bool = (any(((_S870.radiance) != _S786)));
            if(_S871)
            {
                var _S872 : f32 = _S825.x;
                var _S873 : f32 = _S825.y;
                var _S874 : u32 = (uniforms_uint.max_bounces);
                var _S875 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S870, _S823.smooth_n, _S867.geometry_n, _S822.material, _S872, _S873, b_3 < _S874, surface_4.random_state);
                lit_0 = _S875;
            }
            else
            {
                lit_0 = _S786;
            }
            light_1 = _S870;
        }
        else
        {
            light_1 = _S866;
            lit_0 = _S786;
        }
        var _S876 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S877 : bool;
        var _S878 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S851)
        {
            var _S879 : bool = (hit_2.instance_index) != (_S802.instance_index);
            if(_S879)
            {
                _S876 = true;
            }
            else
            {
                _S876 = (hit_2.triangle_index) != (_S802.triangle_index);
            }
            if(_S876)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S821;
            }
            if(wrong_side_0)
            {
                return _S787;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S859)
            {
                refracted_4 = _S791 == u32(1);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S859)
            {
                _S877 = _S791 == u32(0);
            }
            else
            {
                _S877 = false;
            }
            if(_S877)
            {
                var _S880 : bool = !_S826;
                if(_S880)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S881 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S881 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S787;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S859)
            {
                _S878 = _S791 == u32(4);
            }
            else
            {
                _S878 = false;
            }
            if(_S878)
            {
                var _S882 : bool = !_S826;
                if(_S882)
                {
                    return _S787;
                }
                var _S883 : f32 = environmentPdf_0(r_8.dir);
                var _S884 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_8.dir, surface_4, _S825, is_inside_4, _S883, surface_4.random_state);
                return Shift_x24init_0(throughput_5 * _S884 * r_8.radiance / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            var _S885 : u32 = (extractBits((r_8.path), (u32(19)), (u32(1))));
            var _S886 : bool = _S826 != (_S885 == u32(1));
            if(_S886)
            {
                return _S787;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S876 = _S852;
            }
            else
            {
                _S876 = false;
            }
            if(_S876)
            {
                var _S887 : bool = !scatter_0;
                if(_S887)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S888 : bool = _S790 != u32(1);
                    if(_S888)
                    {
                        wrong_side_0 = _S790 != u32(3);
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
                var _S889 : bool = _S790 == u32(2);
                if(_S889)
                {
                    _S834 = _S826;
                }
                else
                {
                    _S834 = false;
                }
                if(_S834)
                {
                    _S834 = !_S821;
                }
                else
                {
                    _S834 = false;
                }
                if(_S834)
                {
                    _S834 = _S791 == u32(4);
                }
                else
                {
                    _S834 = false;
                }
                if(_S834)
                {
                    var _S890 : u32 = stream(r_8.seed, b_3 + u32(256));
                    var _S891 : SkySample = sampleSky_0(ray_2, surface_4, _S825, is_inside_4, _S890, surface_4.random_state);
                    return Shift_x24init_0(throughput_3 * _S891.color, 1.0f);
                }
                if(_S889)
                {
                    is_inside_4 = _S826;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S821;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S892 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S893 : bool = !(_S892 > 0.0f);
                    if(_S893)
                    {
                        return _S787;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S800)
                {
                    is_inside_4 = _S791 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S809;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S800)
                {
                    is_inside_4 = _S791 == u32(1);
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
                    is_inside_4 = !_S821;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S787;
            }
            else
            {
                var _S894 : bool = !replay_0;
                if(_S894)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S895 : bool = b_3 > u32(0);
                    if(_S895)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S841)
                        {
                            var _S896 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S896;
                        }
                        else
                        {
                            if(_S821)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S897 : vec3<f32> = throughput_3 * emission_1;
                        var _S898 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S897);
                        offer(&((*sel_4)), _S898, _S897 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S826)
                    {
                        var _S899 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S841)
                        {
                            var _S900 : vec3<f32> = safeDivide(_S899, chain_throughput_0);
                            candidate_4.radiance = _S900;
                        }
                        else
                        {
                            if(_S821)
                            {
                                candidate_4 = here_0;
                                var _S901 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_4.path = _S901;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S902 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S903 : u32 = (insertBits((_S902), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S903;
                            }
                        }
                        var _S904 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S899);
                        offer(&((*sel_4)), _S904, _S899 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S826)
                    {
                        var _S905 : bool = environmentMapped_0();
                        _S877 = _S905;
                    }
                    else
                    {
                        _S877 = false;
                    }
                    if(_S877)
                    {
                        var _S906 : u32 = (uniforms_uint.max_bounces);
                        _S878 = b_3 < _S906;
                    }
                    else
                    {
                        _S878 = false;
                    }
                    if(_S878)
                    {
                        var _S907 : u32 = stream(r_8.seed, b_3 + u32(256));
                        var _S908 : SkySample = sampleSky_0(ray_2, surface_4, _S825, is_inside_4, _S907, surface_4.random_state);
                        var _S909 : vec3<f32> = throughput_3 * _S908.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S841)
                        {
                            var _S910 : vec3<f32> = safeDivide(_S909, chain_throughput_0);
                            candidate_5.radiance = _S910;
                        }
                        else
                        {
                            if(_S821)
                            {
                                candidate_5 = here_0;
                                var _S911 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_5.path = _S911;
                                candidate_5.dir = _S908.dir;
                                candidate_5.radiance = _S908.radiance;
                            }
                            else
                            {
                                var _S912 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S913 : u32 = (insertBits((_S912), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S913;
                            }
                        }
                        var _S914 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S909);
                        offer(&((*sel_4)), _S914, _S909 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S915 : bool;
        var _S916 : bool;
        var _S917 : bool;
        var _S918 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S876 = _S852;
            }
            else
            {
                _S876 = false;
            }
            var _S919 : u32 = (extractBits((r_8.path), (u32(15)), (u32(2))));
            var _S920 : u32 = (extractBits((r_8.path), (u32(17)), (u32(2))));
            var _S921 : u32 = select(_S919, _S920, _S851);
            var refracted_5 : bool = _S921 == u32(1);
            var _S922 : SampleBSDF = SampleBSDF_x24init_0(_S786, _S786, u32(0), false, u32(0), 0.0f);
            var lobe_7 : SampleBSDF = _S922;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S876)
            {
                var _S923 : u32 = (extractBits((r_8.path), (u32(20)), (u32(1))));
                var _S924 : bool = is_inside_4 != (_S923 == u32(1));
                if(_S924)
                {
                    return _S787;
                }
                var _S925 : bool = _S790 == u32(1);
                if(_S925)
                {
                    var _S926 : vec3<f32> = (hitPosition((_S802)));
                    dir_11 = _S926;
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
                    var _S927 : bool = isTranslucent_0(_S822.material);
                    if(_S927)
                    {
                        wrong_side_0 = _S921 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S928 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S929 : vec3<f32> = select(r_8.dir, _S928, _S925);
                        refracted_4 = (dot(_S823.smooth_n, _S929) * _S824) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S925)
                {
                    var _S930 : vec3<f32> = ray_2.origin;
                    var _S931 : Surface = surface_4;
                    var _S932 : vec3<f32> = (vec3<f32>(0) - _S823.smooth_n);
                    var _S933 : bool = is_inside_4 != refracted_4;
                    var _S934 : vec3<f32> = select(_S823.smooth_n, _S932, _S933);
                    var _S935 : vec3<f32> = (normalize((dir_11 - (_S930 + vec3<f32>(_S931.geometry_offset) * _S934))));
                    reconnection_1 = _S935;
                }
                else
                {
                    reconnection_1 = r_8.dir;
                }
                var _S936 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, surface_4.geometry_n);
                if(_S936)
                {
                    return _S787;
                }
                var _S937 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S921;
                wrong_side_0 = false;
                reconnection_1 = _S937;
            }
            else
            {
                var _S938 : bool = !_S851;
                if(_S938)
                {
                    var _S939 : f32 = _S825.x;
                    var _S940 : f32 = _S825.y;
                    var _S941 : vec2<f32> = vec2<f32>(0.0f);
                    var _S942 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S823.smooth_n, _S822.material, _S939, _S940, surface_4.random_state, _S941);
                    var bsdf_sampled_0 : SampleBSDF = _S942;
                    var _S943 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S822.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S944 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S943.geometry_n, _S822.material, _S939, _S940, bsdf_sampled_0.random_state, _S941);
                        bsdf_sampled_0.unit_direction = _S944.unit_direction;
                        bsdf_sampled_0.refracted = _S944.refracted;
                        bsdf_sampled_0.throughput = _S944.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S945 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S943.geometry_n))) * _S943.geometry_n;
                            bsdf_sampled_0.unit_direction = _S945;
                        }
                    }
                    var _S946 : u32 = bsdf_sampled_0.lobe;
                    var _S947 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S948 : bool = bsdf_sampled_0.refracted;
                    lobe_7 = bsdf_sampled_0;
                    var _S949 : f32 = bsdf_sampled_0.pdf;
                    var _S950 : f32 = select(_S949, 0.0f, wrong_side_1);
                    lobe_7.pdf = _S950;
                    dir_11 = _S947;
                    lobe_index_0 = _S946;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S948;
                }
                else
                {
                    dir_11 = r_8.dir;
                    lobe_index_0 = _S921;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S876)
            {
                _S877 = true;
            }
            else
            {
                _S877 = _S851;
            }
            if(_S877)
            {
                var _S951 : SampleBSDF = connectBSDF(ray_2.unit_direction, dir_11, _S823.smooth_n, _S822.material, _S825.x, _S825.y, lobe_index_0, surface_4.random_state);
                lobe_7 = _S951;
            }
            var _S952 : bool = lobe_index_0 != u32(0);
            if(_S952)
            {
                var _S953 : bool = (_S822.material.roughness) == 0.0f;
                if(_S953)
                {
                    _S878 = true;
                }
                else
                {
                    var _S954 : bool = lobe_index_0 == u32(1);
                    if(_S954)
                    {
                        _S878 = (_S825.x) == (_S825.y);
                    }
                    else
                    {
                        _S878 = false;
                    }
                }
            }
            else
            {
                _S878 = false;
            }
            var _S955 : bool = isTranslucent_0(_S822.material);
            if(_S955)
            {
                _S915 = lobe_index_0 == u32(0);
            }
            else
            {
                _S915 = false;
            }
            if(_S915)
            {
                _S916 = (dot(dir_11, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S916 = false;
            }
            if(_S826)
            {
                _S917 = !_S878;
            }
            else
            {
                _S917 = false;
            }
            if(_S917)
            {
                _S918 = !wrong_side_0;
            }
            else
            {
                _S918 = false;
            }
            var _S956 : bool;
            if(_S918)
            {
                var _S957 : f32 = lobe_7.pdf;
                var _S958 : vec3<f32> = ray_2.origin;
                var _S959 : bool = isTranslucent_0(_S822.material);
                var _S960 : vec3<f32> = select(_S823.smooth_n, _S786, _S959);
                var _S961 : vec3<f32> = ray_2.origin;
                var _S962 : Surface = surface_4;
                var _S963 : vec3<f32> = (vec3<f32>(0) - _S823.smooth_n);
                var _S964 : vec3<f32> = select(_S823.smooth_n, _S963, _S916);
                var _S965 : NEEVertex = NEEVertex_x24init_0(false, _S957, _S958, _S960, _S961 + vec3<f32>(_S962.geometry_offset) * _S964);
                nee_vertex_0 = _S965;
            }
            else
            {
                var _S966 : bool = lobe_index_0 != u32(1);
                if(_S966)
                {
                    _S956 = true;
                }
                else
                {
                    _S956 = (_S825.x) != (_S825.y);
                }
                if(_S956)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S967 : bool = lobe_index_0 == u32(0);
            var _S968 : bool = withinInverseFootprint(lobe_7.pdf, _S967, prev_0.cos, hit_2.distance, threshold_2);
            var _S969 : bool = roughLobe(lobe_7.pdf, _S967, _S822.material.roughness);
            var throughput_6 : vec3<f32>;
            if(_S851)
            {
                var _S970 : bool = !_S968;
                if(_S970)
                {
                    return _S787;
                }
                var _S971 : bool = _S791 != u32(1);
                if(_S971)
                {
                    _S956 = _S791 != u32(2);
                }
                else
                {
                    _S956 = false;
                }
                if(_S956)
                {
                    var _S972 : f32 = lobe_7.pdf;
                    var _S973 : f32 = select(0.0f, _S972, _S826);
                    var _S974 : f32 = escapeWeight_0(_S973, r_8.dir);
                    if(_S859)
                    {
                        is_inside_4 = _S797;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S975 : f32 = select(1.0f, _S974, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf)) * r_8.radiance * vec3<f32>(_S975) / vec3<f32>(r_8.jac), density_3 * lobe_7.pdf / r_8.jac);
                }
                var _S976 : vec3<f32> = throughput_4 * vec3<f32>(lobe_7.pdf);
                var _S977 : f32 = density_3 * lobe_7.pdf;
                throughput_6 = _S976;
                density_5 = _S977;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S956 = b_3 <= _S801;
            }
            else
            {
                _S956 = false;
            }
            var _S978 : bool;
            if(_S956)
            {
                _S978 = _S821;
            }
            else
            {
                _S978 = false;
            }
            var _S979 : bool;
            if(_S978)
            {
                _S979 = _S968;
            }
            else
            {
                _S979 = false;
            }
            var _S980 : bool;
            if(_S979)
            {
                _S980 = true;
            }
            else
            {
                if(_S876)
                {
                    _S980 = !_S969;
                }
                else
                {
                    _S980 = false;
                }
            }
            if(_S980)
            {
                return _S787;
            }
            var throughput_7 : vec3<f32>;
            if(_S876)
            {
                var _S981 : vec3<f32> = throughput_6 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf));
                var _S982 : f32 = lobe_7.pdf;
                throughput_7 = _S981;
                survival_probability_0 = _S982;
            }
            else
            {
                var _S983 : vec3<f32> = throughput_6 * max(lobe_7.throughput, _S786);
                throughput_7 = _S983;
                survival_probability_0 = density_5;
            }
            var _S984 : bool = !replay_0;
            var _S985 : bool;
            if(_S984)
            {
                _S985 = !_S841;
            }
            else
            {
                _S985 = false;
            }
            var _S986 : bool;
            if(_S985)
            {
                _S986 = _S821;
            }
            else
            {
                _S986 = false;
            }
            var _S987 : bool;
            if(_S986)
            {
                _S987 = _S968;
            }
            else
            {
                _S987 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S987)
            {
                chain_0 = here_0;
                var _S988 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(17)), (u32(2))));
                var _S989 : u32 = select(u32(0), u32(1), _S826);
                var _S990 : u32 = (insertBits((_S988), (_S989), (u32(19)), (u32(1))));
                chain_0.path = _S990;
                var _S991 : f32 = chain_0.jac * lobe_7.pdf;
                chain_0.jac = _S991;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S992 : Vertex = Vertex_x24init_0(_S969, lobe_index_0, lobe_7.pdf, abs(dot(surface_4.geometry_n, dir_11)), is_inside_4);
            prev_0 = _S992;
            var _S993 : f32 = lobe_7.pdf;
            var _S994 : bool = lobe_index_0 == u32(1);
            var _S995 : bool;
            if(_S994)
            {
                _S995 = (_S825.x) == (_S825.y);
            }
            else
            {
                _S995 = false;
            }
            var _S996 : f32 = select(_S993, sky_pdf_0, _S995);
            var _S997 : bool;
            if(refracted_4)
            {
                _S997 = !_S916;
            }
            else
            {
                _S997 = false;
            }
            var is_inside_5 : bool;
            if(_S997)
            {
                var _S998 : bool = !is_inside_4;
                is_inside_5 = _S998;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_11;
            var _S999 : Surface = surface_4;
            var _S1000 : vec3<f32> = (vec3<f32>(0) - _S823.smooth_n);
            var _S1001 : bool = is_inside_5 != _S916;
            var _S1002 : vec3<f32> = select(_S823.smooth_n, _S1000, _S1001);
            var _S1003 : vec3<f32> = ray_2.origin + vec3<f32>(_S999.geometry_offset) * _S1002;
            ray_2.origin = _S1003;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S996;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        var _S1004 : bool = !replay_0;
        if(_S1004)
        {
            if(_S809)
            {
                var _S1005 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1006 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1007 : bool = _S1006 == u32(1);
                if(_S1007)
                {
                    var _S1008 : vec3<f32> = safeDivide(_S1005, chain_throughput_0);
                    candidate_6.radiance = _S1008;
                }
                var _S1009 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1005);
                offer(&((*sel_4)), _S1009, _S1005 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S809)
            {
                _S876 = true;
            }
            else
            {
                _S876 = scatter_0;
            }
            if(_S876)
            {
                var _S1010 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1010;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1011 : u32 = stream(r_8.seed, b_3 + u32(128));
            var _S1012 : Random = pcg(_S1011);
            var _S1013 : bool = survival_probability_0 < (_S1012.value);
            if(_S1013)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1014 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1014;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1015 : f32 = density_5 * survival_probability_0;
            density_2 = _S1015;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1016 : Ray = ray_2;
        var _S1017 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S876 = _S852;
        }
        else
        {
            _S876 = false;
        }
        if(_S876)
        {
            wrong_side_0 = _S790 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1018 : f32 = select(4.294967296e+09f, _S1017, wrong_side_0);
        var _S1019 : Hit = (traverseInstanceBVH((_S1016), (_S811), (_S1018)));
        hit_2 = _S1019;
        if(replay_0)
        {
            refracted_4 = _S852;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S877 = _S790 == u32(1);
        }
        else
        {
            _S877 = false;
        }
        if(_S877)
        {
            _S878 = (hit_2.instance_index) == (_S802.instance_index);
        }
        else
        {
            _S878 = false;
        }
        if(_S878)
        {
            _S915 = (hit_2.triangle_index) == (_S802.triangle_index);
        }
        else
        {
            _S915 = false;
        }
        if(_S915)
        {
            hit_2.uv = _S802.uv;
            var _S1020 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1020;
        }
        if(replay_0)
        {
            _S916 = _S852;
        }
        else
        {
            _S916 = false;
        }
        if(_S916)
        {
            _S917 = _S790 == u32(3);
        }
        else
        {
            _S917 = false;
        }
        if(_S917)
        {
            _S918 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S918 = false;
        }
        if(_S918)
        {
            return _S787;
        }
        var _S1021 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1021)
        {
            var _S1022 : bool = !nee_vertex_0.none;
            var _S1023 : f32 = select(0.0f, sky_pdf_0, _S1022);
            var _S1024 : f32 = escapeWeight_0(_S1023, ray_2.unit_direction);
            var _S1025 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1026 : vec3<f32> = throughput_2 * _S1025;
            if(replay_0)
            {
                if(_S852)
                {
                    is_inside_4 = _S790 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1026 * vec3<f32>(_S1024) / vec3<f32>(r_8.jac), density_2 / r_8.jac);
                }
                if(_S800)
                {
                    is_inside_4 = _S797;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_3 == _S788;
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
                    return Shift_x24init_0(_S1026 * vec3<f32>(_S1024), 1.0f);
                }
                return _S787;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1027 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1028 : bool = _S1027 == u32(1);
            if(_S1028)
            {
                var _S1029 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1030 : bool = _S1029 == b_3;
                var _S1031 : f32 = select(_S1024, 1.0f, _S1030);
                var _S1032 : vec3<f32> = safeDivide(_S1026 * vec3<f32>(_S1031), chain_throughput_0);
                candidate_7.radiance = _S1032;
            }
            else
            {
                var _S1033 : bool = prev_0.rough;
                if(_S1033)
                {
                    var _S1034 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                    var _S1035 : u32 = (insertBits((_S1034), (u32(3)), (u32(10)), (u32(2))));
                    var _S1036 : u32 = (insertBits((_S1035), (prev_0.lobe), (u32(15)), (u32(2))));
                    var _S1037 : bool = prev_0.inside;
                    var _S1038 : u32 = select(u32(0), u32(1), _S1037);
                    var _S1039 : u32 = (insertBits((_S1036), (_S1038), (u32(20)), (u32(1))));
                    candidate_7.path = _S1039;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1040 : vec3<f32> = _S1026 * vec3<f32>(_S1024);
            var _S1041 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1040);
            offer(&((*sel_4)), _S1041, _S1040 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1042 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1042;
        var _S1043 : u32 = b_3 + u32(1);
        b_3 = _S1043;
    }
    return _S787;
}

fn shift_0( dom_5 : Domain,  r_9 : Reservoir) -> Shift
{
    var _S1044 : vec3<f32> = vec3<f32>(0.0f);
    var _S1045 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1044, 0.0f, vec4<u32>(u32(0)), _S1044, _S1044), 0.0f, _S1044, u32(0));
    var sel_5 : Selection = _S1045;
    var _S1046 : bool = (r_9.w) <= 0.0f;
    if(_S1046)
    {
        return Shift_x24init_0(_S1044, 0.0f);
    }
    var _S1047 : Shift = walk_0(dom_5, r_9, true, 0.0f, &(sel_5));
    return _S1047;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1048 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1049 : bool = _S1048 != u32(4294967295);
    if(_S1049)
    {
        var _S1050 : vec2<i32> = vec2<i32>((vec2<u32>(_S1048, (_S1048 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1051 : vec3<f32> = vec3<f32>(0.0f);
        var _S1052 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1051, _S1051, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1051, 0.0f, vec4<u32>(u32(0)), _S1051, _S1051));
        var shift_job_0 : ShiftJob = _S1052;
        var _S1053 : u32 = (_S1048 >> (u32(28)));
        var _S1054 : bool = spatialJob_0(_S1050, _S1053, &(shift_job_0));
        var _S1055 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1050), (_S1053), (vec4<u32>((bitcast<vec3<u32>>((_S1055.f))), (bitcast<u32>((_S1055.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1056 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1057 : array<u32, i32(3)>;
    spatialBins_0(_S1056, &(_S1057));
    var _S1058 : array<u32, i32(3)> = _S1057;
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
        var _S1059 : bool = (_S1058[t_16]) == u32(40);
        if(_S1059)
        {
            textureStore(shift_data_out, (_S1056), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1056, _S1058, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1060 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1060));
    countShifts_0(_S1060, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1061 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1062 : bool = _S1061 != u32(4294967295);
    if(_S1062)
    {
        var _S1063 : vec2<i32> = vec2<i32>((vec2<u32>(_S1061, (_S1061 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1064 : vec3<f32> = vec3<f32>(0.0f);
        var _S1065 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1064, _S1064, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1064, 0.0f, vec4<u32>(u32(0)), _S1064, _S1064));
        var shift_job_1 : ShiftJob = _S1065;
        var _S1066 : u32 = (_S1061 >> (u32(28)));
        var _S1067 : bool = temporalJob_0(_S1063, _S1066, &(shift_job_1));
        var _S1068 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1063), (_S1066), (vec4<u32>((bitcast<vec3<u32>>((_S1068.f))), (bitcast<u32>((_S1068.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1069 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1070 : array<u32, i32(3)>;
    temporalBins_0(_S1069, &(_S1070));
    var _S1071 : array<u32, i32(3)> = _S1070;
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
        var _S1072 : bool = (_S1071[t_18]) == u32(40);
        if(_S1072)
        {
            textureStore(temporal_shifts_out, (_S1069), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1069, _S1071, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1073 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1073));
    countShifts_0(_S1073, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1074 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1074;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1075 : f32 = c_3 * p_c_1;
    var _S1076 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1075 / (_S1075 + c_t_0 * g_previous_0), _S1076 / (_S1076 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1077 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1078 : vec3<f32> = vec3<f32>(0.0f);
    var _S1079 : Domain = Domain_x24init_0(_S1078, _S1078, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1079;
    var _S1080 : bool = (currentDomain((_S1077), &(dom_6)));
    var _S1081 : bool = !_S1080;
    if(_S1081)
    {
        storeReservoir(reservoir_temp_out, (_S1077), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1078, 0.0f, vec4<u32>(u32(0)), _S1078, _S1078)), (dom_6.hit));
        return;
    }
    var _S1082 : Reservoir = (loadReservoir(reservoir_initial, (_S1077)));
    var _S1083 : vec2<i32> = temporalNeighbor_0(_S1077, dom_6);
    var _S1084 : bool = (_S1083.x) >= i32(0);
    var r_10 : Reservoir;
    if(_S1084)
    {
        var _S1085 : Reservoir = (loadReservoir(reservoir_prev, (_S1083)));
        var _S1086 : vec4<u32> = (textureLoad(duplication, (_S1083), 0, 0));
        var _S1087 : f32 = (bitcast<f32>((_S1086.x)));
        var _S1088 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1089 : bool = _S1088 == u32(1);
        var _S1090 : f32 = select(0.0f, _S1087, _S1089);
        var _S1091 : f32 = confidenceCap(_S1090);
        var _S1092 : f32 = min(_S1085.c, _S1091);
        var _S1093 : vec4<u32> = (textureLoad(temporal_shifts, (_S1077), (u32(0)), 0));
        var _S1094 : vec4<f32> = (bitcast<vec4<f32>>((_S1093)));
        var _S1095 : vec4<f32> = vec4<f32>(_S1082.f, 1.0f);
        var _S1096 : Domain = (previousDomain((_S1083)));
        var _S1097 : bool = sameDomain_0(_S1096, dom_6);
        var _S1098 : bool = !_S1097;
        var to_previous_0 : vec4<f32>;
        if(_S1098)
        {
            var _S1099 : vec4<u32> = (textureLoad(temporal_shifts, (_S1077), (u32(1)), 0));
            var _S1100 : vec4<f32> = (bitcast<vec4<f32>>((_S1099)));
            to_previous_0 = _S1100;
        }
        else
        {
            to_previous_0 = _S1095;
        }
        var _S1101 : f32 = rgb_to_greyscale(_S1082.f);
        var _S1102 : f32 = rgb_to_greyscale(_S1085.f);
        var _S1103 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1078, 0.0f, vec4<u32>(u32(0)), _S1078, _S1078), 0.0f, _S1078, u32(0));
        var sel_6 : Selection = _S1103;
        var _S1104 : u32 = (uniforms_uint.frame);
        var _S1105 : u32 = hash(_S1104);
        var _S1106 : u32 = global_invocation_id_7.x;
        var _S1107 : vec2<u32> = (uniforms_uint.render_size);
        var _S1108 : u32 = stream(_S1105, _S1106 + _S1107.x * global_invocation_id_7.y);
        var _S1109 : u32 = stream(_S1108, u32(194));
        sel_6.random_state = _S1109;
        var _S1110 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1111 : vec3<f32> = _S1094.xyz;
        var _S1112 : f32 = rgb_to_greyscale(_S1111);
        var _S1113 : vec2<f32> = temporalWeights(_S1082.c, _S1101, _S1092, _S1102, _S1110, _S1112);
        offerShifted(&(sel_6), _S1082, Shift_x24init_0(_S1082.f, 1.0f), _S1113.x);
        offerShifted(&(sel_6), _S1085, Shift_x24init_0(_S1111, _S1094.w), _S1113.y);
        var _S1114 : Reservoir = finalize(sel_6, _S1082.c + _S1092);
        r_10 = _S1114;
    }
    else
    {
        r_10 = _S1082;
    }
    storeReservoir(reservoir_temp_out, (_S1077), (r_10), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1115 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1116 : vec3<f32> = vec3<f32>(0.0f);
    var _S1117 : Domain = Domain_x24init_0(_S1116, _S1116, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1117;
    var _S1118 : bool = (currentDomain((_S1115), &(dom_7)));
    var _S1119 : bool = !_S1118;
    if(_S1119)
    {
        storeReservoir(reservoir_initial_out, (_S1115), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1116, 0.0f, vec4<u32>(u32(0)), _S1116, _S1116)), (dom_7.hit));
        return;
    }
    var _S1120 : u32 = (uniforms_uint.frame);
    var _S1121 : u32 = hash(_S1120);
    var _S1122 : u32 = global_invocation_id_8.x;
    var _S1123 : vec2<u32> = (uniforms_uint.render_size);
    var _S1124 : u32 = stream(_S1121, _S1122 + _S1123.x * global_invocation_id_8.y);
    var _S1125 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1116, 0.0f, vec4<u32>(u32(0)), _S1116, _S1116);
    var _S1126 : Selection = Selection_x24init_0(_S1125, 0.0f, _S1116, u32(0));
    var initial_0 : Selection = _S1126;
    var _S1127 : u32 = stream(_S1124, u32(193));
    initial_0.random_state = _S1127;
    var i_2 : u32 = u32(0);
    loop
    {
        var _S1128 : u32 = (uniforms_uint.samples);
        if(i_2 < _S1128)
        {
        }
        else
        {
            break;
        }
        var r_11 : Reservoir = _S1125;
        var _S1129 : u32 = stream(_S1124, i_2);
        r_11.seed = _S1129;
        var _S1130 : u32 = (uniforms_uint.samples);
        var _S1131 : Shift = walk_0(dom_7, r_11, false, 1.0f / f32(_S1130), &(initial_0));
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var _S1132 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1115), (_S1132), (dom_7.hit));
    return;
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S1133 : Random = pcg(state_2);
    var _S1134 : Random = pcg(_S1133.state);
    var _S1135 : f32 = 6.28318548202514648f * _S1133.value;
    var _S1136 : f32 = sqrt(-2.0f * clamp(log(_S1134.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1134.state, _S1136 * cos(_S1135));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1137 : RandomSphere;
    _S1137.state = state_3;
    _S1137.value = value_1;
    return _S1137;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S1138 : Random = normal_distribution(state_4);
    var _S1139 : Random = normal_distribution(_S1138.state);
    var _S1140 : Random = normal_distribution(_S1139.state);
    var _S1141 : vec3<f32> = (normalize((vec3<f32>(_S1138.value, _S1139.value, _S1140.value))));
    return RandomSphere_x24init_0(_S1140.state, _S1141);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S1142 : RandomHemisphere;
    _S1142.state = state_5;
    _S1142.value = value_2;
    return _S1142;
}

fn random_hemisphere( state_6 : u32,  normal_4 : vec3<f32>) -> RandomHemisphere
{
    var _S1143 : RandomSphere = random_sphere(state_6);
    var _S1144 : bool = (dot(_S1143.value, normal_4)) > 0.0f;
    if(_S1144)
    {
        return RandomHemisphere_x24init_0(_S1143.state, _S1143.value);
    }
    else
    {
        var _S1145 : vec3<f32> = ((-(_S1143.value)));
        return RandomHemisphere_x24init_0(_S1143.state, _S1145);
    }
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_12 : vec3<f32>) -> mat3x3<f32>
{
    var _S1146 : vec3<f32> = p1_0 - p0_0;
    var _S1147 : vec3<f32> = p2_0 - p0_0;
    var _S1148 : vec2<f32> = uv1_0 - uv0_0;
    var _S1149 : vec2<f32> = uv2_0 - uv0_0;
    var _S1150 : f32 = _S1148.x;
    var _S1151 : f32 = _S1149.y;
    var _S1152 : f32 = _S1148.y;
    var _S1153 : f32 = _S1149.x;
    var _S1154 : f32 = _S1150 * _S1151 - _S1152 * _S1153;
    var _S1155 : f32 = 1.0f / _S1154;
    var _S1156 : vec3<f32> = vec3<f32>(_S1155);
    var t_20 : vec3<f32> = (_S1146 * vec3<f32>(_S1151) - _S1147 * vec3<f32>(_S1152)) * _S1156;
    var _S1157 : vec3<f32> = (_S1147 * vec3<f32>(_S1150) - _S1146 * vec3<f32>(_S1153)) * _S1156;
    var t_21 : vec3<f32> = (normalize((t_20 - n_12 * vec3<f32>(dot(n_12, t_20)))));
    var _S1158 : bool = (dot(cross(n_12, t_21), _S1157)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1158)
    {
        var _S1159 : vec3<f32> = ((-(t_21)));
        t_22 = _S1159;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1160 : vec3<f32> = cross(n_12, t_22);
    return mat3x3<f32>(t_22, _S1160, n_12);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1161 : vec3<f32> = t1_0 - t0_0;
    var _S1162 : vec3<f32> = t2_2 - t0_0;
    var _S1163 : vec3<f32> = t2_2 - t1_0;
    var _S1164 : f32 = min(length(_S1161), min(length(_S1162), length(_S1163)));
    var _S1165 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1166 : vec3<f32> = (normalize((n0_0)));
    var _S1167 : f32 = dot(geometry_n_5, _S1166);
    var _S1168 : vec3<f32> = (normalize((n1_0)));
    var _S1169 : f32 = dot(geometry_n_5, _S1168);
    var _S1170 : vec3<f32> = (normalize((n2_0)));
    var _S1171 : vec3<f32> = acos(abs(vec3<f32>(_S1167, _S1169, dot(geometry_n_5, _S1170))));
    var _S1172 : vec3<f32> = clamp(tan(_S1171), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1165 * _S1172, uvw_0), 0.0f, _S1164 * 0.125f);
}

fn sampleHalfVector( v_6 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_6 : f32,  random_state_14 : ptr<function, u32>) -> vec3<f32>
{
    var _S1173 : vec3<f32> = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f)), &((*random_state_14)));
    return _S1173;
}

fn straightThrough( dir_12 : vec3<f32>,  n_13 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S1174 : vec3<f32> = ((-(dir_12)));
    var _S1175 : f32 = (sign((dot(n_13, _S1174))));
    var _S1176 : vec3<f32> = n_13 * vec3<f32>(_S1175);
    var _S1177 : AnisotropicFrame = anisotropicFrame(material_15, _S1176);
    var _S1178 : bool = (_S1177.alphas.x) > 0.0f;
    if(_S1178)
    {
        var _S1179 : f32 = material_15.transmission * (1.0f - material_15.metallic);
        var _S1180 : vec3<f32> = ((-(_S1176)));
        var _S1181 : vec3<f32> = anisotropicLocal(dir_12, _S1177.tangent, _S1180);
        var _S1182 : f32 = anisotropicG1(_S1181, _S1177.alphas);
        return vec3<f32>((_S1179 * _S1182)) * material_15.albedo;
    }
    var _S1183 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S1184 : f32 = material_15.roughness;
    var _S1185 : f32 = smithG1(_S1184 * _S1184, abs(dot(n_13, dir_12)));
    return vec3<f32>((_S1183 * _S1185)) * material_15.albedo;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_7 : vec3<f32>,  end_1 : vec3<f32>) -> vec3<f32>
{
    var _S1186 : f32 = (sign((dot(light_n_0, start_7 - end_1))));
    return light_n_0 * vec3<f32>((_S1186 * light_offset_0));
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_14 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1187 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S1188 : vec3<f32> = straightThrough(toward_1, n_14, material_16);
        _S1187 = _S1188;
    }
    else
    {
        _S1187 = vec3<f32>(0.0f);
    }
    return _S1187 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_12 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1189 : Shift = walk_0(dom_8, r_12, replay_1, scale_2, &((*sel_7)));
    return _S1189;
}

fn shift_hook( dom_9 : Domain,  r_13 : Reservoir) -> Shift
{
    var _S1190 : Shift = shift_0(dom_9, r_13);
    return _S1190;
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

