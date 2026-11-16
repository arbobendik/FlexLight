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
    var _S247 : BSDFLobes;
    _S247.v_dot_h = v_dot_h_0;
    _S247.n_dot_h = n_dot_h_0;
    _S247.refracted = refracted_1;
    _S247.F = F_0;
    _S247.F_greyscale = F_greyscale_0;
    _S247.reflect_weight = reflect_weight_0;
    _S247.diffuse_weight = diffuse_weight_0;
    _S247.refract_weight = refract_weight_0;
    _S247.p_diffuse = p_diffuse_0;
    _S247.p_reflect = p_reflect_0;
    _S247.p_refract = p_refract_0;
    _S247.translucent_share = translucent_share_0;
    _S247.sheen = sheen_0;
    _S247.p_sheen_velvet = p_sheen_velvet_0;
    _S247.view = view_1;
    _S247.tangent = tangent_1;
    _S247.alphas = alphas_1;
    _S247.visible = visible_0;
    return _S247;
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
    var _S248 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S249 : f32 = _S248.x;
    var _S250 : f32 = _S248.y;
    var _S251 : f32 = _S249 * _S249 + _S250 * _S250;
    const _S252 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S253 : vec3<f32> = vec3<f32>(- _S250, _S249, 0.0f);
    var _S254 : f32 = (inverseSqrt((_S251)));
    var _S255 : vec3<f32> = _S253 * vec3<f32>(_S254);
    var _S256 : bool = _S251 > 0.0f;
    var _S257 : vec3<f32> = select(_S252, _S255, _S256);
    var _S258 : vec3<f32> = cross(_S248, _S257);
    var _S259 : f32 = sqrt(U1_0);
    var _S260 : f32 = 6.28318548202514648f * U2_0;
    var _S261 : f32 = _S259 * cos(_S260);
    var t2_0 : f32 = _S259 * sin(_S260);
    var _S262 : f32 = 0.5f * (1.0f + _S248.z);
    var t2_1 : f32 = (1.0f - _S262) * sqrt(max(0.0f, 1.0f - _S261 * _S261)) + _S262 * t2_0;
    var _S263 : vec3<f32> = vec3<f32>(_S261) * _S257 + vec3<f32>(t2_1) * _S258;
    var _S264 : f32 = ((_S261));
    var _S265 : f32 = ((_S261));
    var _S266 : vec3<f32> = _S263 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S264 * _S265 - t2_1 * t2_1))) * _S248;
    var _S267 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S266.x, alpha_0 * _S266.y, max(0.0f, _S266.z)))));
    return _S267;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S268 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S268)
    {
        const _S269 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S269;
    }
    else
    {
        a_4 = a_3;
    }
    var _S270 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S271 : vec3<f32> = cross(n_3, _S270);
    return vec3<f32>(dot(v_1, _S270), dot(v_1, n_3), dot(v_1, _S271));
}

fn sampleHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S272 : Random = pcg((*random_state_0));
    var _S273 : Random = pcg(_S272.state);
    (*random_state_0) = _S273.state;
    var _S274 : f32 = frame_0.alphas.x;
    var _S275 : bool = _S274 > 0.0f;
    if(_S275)
    {
        var _S276 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S277 : f32 = frame_0.alphas.y;
        var _S278 : vec3<f32> = (normalize((vec3<f32>(_S274 * _S276.x, _S277 * _S276.y, _S276.z))));
        var _S279 : vec3<f32> = sampleGGXVNDF(_S278, 1.0f, _S272.value, _S273.value);
        var _S280 : vec3<f32> = (normalize((vec3<f32>(_S274 * _S279.x, _S277 * _S279.y, _S279.z))));
        return vec3<f32>(_S280.x) * frame_0.tangent + vec3<f32>(_S280.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S280.z) * n_i_1;
    }
    var _S281 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S282 : vec3<f32> = sampleGGXVNDF(_S281.xzy, alpha_1, _S272.value, _S273.value);
    var _S283 : vec3<f32> = _S282.xzy;
    var _S284 : vec3<f32> = tangentToWorld(_S283, n_i_1);
    return _S284;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_1 : Material,  random_state_1 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_1;
    var _S285 : vec3<f32> = ((-(in_dir_0)));
    var _S286 : f32 = (sign((dot(n_4, _S285))));
    var _S287 : f32 = material_1.roughness;
    var _S288 : vec3<f32> = sampleHalfVector(_S285, n_4 * vec3<f32>(_S286), _S287 * _S287, frame_1, &(state_2));
    return _S288;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  eta_i_0 : f32,  eta_o_0 : f32) -> vec3<f32>
{
    var _S289 : vec3<f32> = ((-(in_dir_1)));
    var _S290 : vec3<f32> = ((-(vec3<f32>(eta_i_0) * _S289 + vec3<f32>(eta_o_0) * out_dir_0)));
    var _S291 : vec3<f32> = (normalize((_S290)));
    var _S292 : f32 = (sign((dot(n_5, _S289))));
    var _S293 : f32 = (sign((dot(_S290, n_5 * vec3<f32>(_S292)))));
    return _S291 * vec3<f32>(_S293);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S294 : vec3<f32> = ((-(in_dir_2)));
    var _S295 : vec3<f32> = (normalize((_S294 + out_dir_1)));
    return _S295;
}

fn fresnel( cos_theta_0 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> f32
{
    var _S296 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S297 : f32 = eta_i_1 / eta_o_1 * _S296;
    var _S298 : bool = _S297 < 1.0f;
    var kr_0 : f32;
    if(_S298)
    {
        var _S299 : f32 = sqrt(max(0.0f, 1.0f - _S297 * _S297));
        var _S300 : f32 = eta_o_1 * cos_theta_0;
        var _S301 : f32 = eta_i_1 * _S299;
        var _S302 : f32 = (_S300 - _S301) / (_S300 + _S301);
        var _S303 : f32 = eta_i_1 * cos_theta_0;
        var _S304 : f32 = eta_o_1 * _S299;
        var _S305 : f32 = (_S303 - _S304) / (_S303 + _S304);
        var _S306 : f32 = (_S302 * _S302 + _S305 * _S305) / 2.0f;
        kr_0 = _S306;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S307 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S307 / (_S307 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S307)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S308 : f32 = alphas_3.x;
    var _S309 : f32 = h_0.x / _S308;
    var _S310 : f32 = alphas_3.y;
    var _S311 : f32 = h_0.y / _S310;
    var _S312 : f32 = h_0.z;
    var _S313 : f32 = _S309 * _S309 + _S311 * _S311 + _S312 * _S312;
    return 1.0f / max(3.14159274101257324f * _S308 * _S310 * _S313 * _S313, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_2 : Material,  eta_i_2 : f32,  eta_o_2 : f32,  frame_2 : AnisotropicFrame) -> BSDFLobes
{
    var _S314 : f32 = dot(ggx_n_0, v_3);
    var _S315 : f32 = dot(n_i_2, ggx_n_0);
    var _S316 : f32 = eta_i_2 / eta_o_2;
    var _S317 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S316))));
    var _S318 : f32 = min(sqrt(material_2.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S319 : f32 = _S318 * _S318;
    var _S320 : f32 = (1.0f + _S318) / (1.0f - _S318);
    var _S321 : f32 = abs(_S314);
    var _S322 : bool = eta_i_2 > eta_o_2;
    var sheen_component_0 : f32;
    if(_S322)
    {
        sheen_component_0 = _S320;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S322)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S320;
    }
    var _S323 : f32 = fresnel(_S321, sheen_component_0, visible_1);
    var _S324 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S314 * _S314)) >= (eta_o_2 * eta_o_2);
    var _S325 : vec3<f32>;
    if(_S324)
    {
        _S325 = vec3<f32>(1.0f);
    }
    else
    {
        var _S326 : vec3<f32> = material_2.specular_tint * vec3<f32>(_S319);
        _S325 = _S326 + (vec3<f32>(1.0f) - _S326) * vec3<f32>((_S323 - _S319)) / vec3<f32>((1.0f - _S319));
    }
    var _S327 : vec3<f32> = vec3<f32>(1.0f);
    var _S328 : vec3<f32> = vec3<f32>(0.0f);
    var _S329 : f32 = rgb_to_greyscale(material_2.sheen);
    var _S330 : bool = _S329 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S330)
    {
        var _S331 : f32 = clamp(sqrt(max(dot(n_i_2, v_3), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S332 : u32 = min(u32(_S331), u32(22));
        var _S333 : f32 = sqrt(0.05000000074505806f);
        var _S334 : f32 = (clamp(sqrt(max(material_2.sheen_roughness, 0.0f)), _S333, 1.0f) - _S333) / (1.0f - _S333) * 23.0f;
        var _S335 : u32 = min(u32(_S334), u32(22));
        var _S336 : u32 = _S332 * u32(24) + _S335;
        var _S337 : f32 = _S331 - f32(_S332);
        var _S338 : f32 = _S334 - f32(_S335);
        var _S339 : u32 = _S336 + u32(24);
        var _S340 : f32 = SHEEN_ALBEDO_0[_S336] + (SHEEN_ALBEDO_0[_S339] - SHEEN_ALBEDO_0[_S336]) * _S337;
        var _S341 : u32 = _S336 + u32(1);
        var _S342 : f32 = SHEEN_ALBEDO_0[_S341] + (SHEEN_ALBEDO_0[_S339 + u32(1)] - SHEEN_ALBEDO_0[_S341]) * _S337;
        var _S343 : f32 = exp(_S340 + (_S342 - _S340) * _S338);
        var _S344 : f32 = min(_S343, 1.0f);
        var _S345 : vec3<f32> = vec3<f32>(1.0f) - material_2.sheen * vec3<f32>(_S344);
        var _S346 : f32 = rgb_to_greyscale(material_2.sheen);
        var _S347 : f32 = _S346 * _S344;
        var _S348 : vec3<f32> = material_2.sheen / vec3<f32>(max(_S343, 1.0f));
        scale_0 = _S345;
        sheen_component_0 = _S347;
        sheen_1 = _S348;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S327;
        sheen_component_0 = 0.0f;
        sheen_1 = _S328;
        view_2 = _S328;
    }
    var _S349 : vec3<f32> = (mix((_S325), (material_2.albedo), (material_2.metallic)));
    var F_1 : vec3<f32> = _S349 * scale_0;
    var _S350 : f32 = rgb_to_greyscale(F_1);
    var _S351 : f32 = 1.0f - material_2.metallic;
    var _S352 : vec3<f32> = vec3<f32>(1.0f) - _S325;
    var _S353 : vec3<f32> = vec3<f32>(((1.0f - material_2.transmission) * _S351)) * _S352 * scale_0;
    var _S354 : vec3<f32> = vec3<f32>((material_2.transmission * _S351)) * _S352 * scale_0;
    var _S355 : f32 = max(_S350, 0.0f);
    var _S356 : f32 = rgb_to_greyscale(_S353);
    var _S357 : f32 = max(_S356, 0.0f);
    var _S358 : f32 = rgb_to_greyscale(_S354);
    var _S359 : f32 = (sign((length(_S317))));
    var _S360 : f32 = max(_S358 * _S359, 0.0f);
    var _S361 : f32 = _S355 + _S357 + _S360;
    var _S362 : f32 = min(sheen_component_0, 1.0f);
    var _S363 : bool = sheen_component_0 > 0.0f;
    var _S364 : bool;
    if(_S363)
    {
        _S364 = !(_S361 > 0.0f);
    }
    else
    {
        _S364 = false;
    }
    var _S365 : f32 = select(_S362, 1.0f, _S364);
    var _S366 : f32 = (1.0f - _S365) / max(_S361, 0.0000152587890625f);
    var _S367 : f32 = _S357 * _S366;
    var _S368 : f32 = _S355 * _S366;
    var _S369 : f32 = _S360 * _S366;
    var _S370 : bool = (frame_2.alphas.x) > 0.0f;
    if(_S370)
    {
        var _S371 : vec3<f32> = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        var _S372 : f32 = anisotropicG1(_S371, frame_2.alphas);
        var _S373 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        var _S374 : f32 = anisotropicD(_S373, frame_2.alphas);
        var _S375 : f32 = _S372 * _S374;
        visible_1 = _S375;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S314, _S315, _S317, F_1, _S350, 1.0f, _S353, _S354, _S367, _S368, _S369, 0.0f, sheen_1, _S365, view_2, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_3 : Material) -> f32
{
    var _S376 : f32 = rgb_to_greyscale(material_3.translucent);
    var _S377 : f32 = rgb_to_greyscale(material_3.albedo);
    var _S378 : f32 = _S376 / (_S377 + _S376);
    var _S379 : bool = _S376 > 0.0f;
    var _S380 : f32 = select(0.0f, _S378, _S379);
    return _S380;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S381 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S382 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S383 : f32 = 1.0f - lobes_0.translucent_share;
    var _S384 : bool = n_i_dot_l_0 < 0.0f;
    var _S385 : f32 = select(_S383, lobes_0.translucent_share, _S384);
    var _S386 : f32 = _S382 * _S385;
    var _S387 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S388 : f32 = select(_S381, _S386, _S387);
    var _S389 : bool = n_i_dot_v_0 > 0.0f;
    var _S390 : f32 = select(0.0f, _S388, _S389);
    return _S390;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_3 : f32,  material_4 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S391 : bool = (dot(n_i_3, l_0)) < 0.0f;
    var _S392 : vec3<f32> = select(material_4.albedo, material_4.translucent, _S391);
    var _S393 : f32 = 1.0f - lobes_1.translucent_share;
    var _S394 : f32 = select(_S393, lobes_1.translucent_share, _S391);
    var _S395 : vec3<f32> = _S392 / vec3<f32>(_S394);
    var _S396 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S397 : vec3<f32> = select(material_4.albedo, _S395, _S396);
    return lobes_1.diffuse_weight * _S397 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S398 : f32 = alpha_4 * alpha_4;
    var _S399 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S398 + (1.0f - _S398) * n_dot_x_0 * n_dot_x_0));
    var _S400 : bool = alpha_4 > 0.0f;
    var _S401 : f32 = select(1.0f, _S399, _S400);
    return _S401;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S402 : f32 = alpha_5 * alpha_5;
    var _S403 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S402 * n_dot_h_1 * n_dot_h_1;
    return _S402 / max(3.14159274101257324f * _S403 * _S403, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S404 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S405 : f32 = _S404 * lobes_2.v_dot_h;
    var _S406 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S407 : f32 = _S405 * _S406 / n_i_dot_v_1;
    var _S408 : bool = alpha_6 > 0.0f;
    var _S409 : bool;
    if(_S408)
    {
        _S409 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    if(_S409)
    {
        _S409 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    if(_S409)
    {
        _S409 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    var _S410 : f32 = select(0.0f, _S407, _S409);
    var _S411 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S411)
    {
        var _S412 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S413 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S413)
        {
            _S409 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S409 = false;
        }
        if(_S409)
        {
            _S409 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S409 = false;
        }
        var _S414 : f32 = select(0.0f, _S412, _S409);
        pdf_h_0 = _S414;
    }
    else
    {
        pdf_h_0 = _S410;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S415 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S416 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S417 : f32 = lobes_3.p_refract * _S415 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S416 * _S416);
    var _S418 : bool = eta_i_4 != eta_o_4;
    var _S419 : bool;
    if(_S418)
    {
        _S419 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S419 = false;
    }
    var _S420 : f32 = select(0.0f, _S417, _S419);
    return _S420;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_8 : f32,  material_5 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S421 : f32 = - dot(n_i_4, l_1);
    var _S422 : f32 = smithG1(alpha_8, max(_S421, 0.0f));
    var _S423 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S423)
    {
        var _S424 : vec3<f32> = ((-(n_i_4)));
        var _S425 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S424);
        var _S426 : f32 = anisotropicG1(_S425, lobes_4.alphas);
        G1_l_0 = _S426;
    }
    else
    {
        G1_l_0 = _S422;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_5.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S427 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S428 : bool = n_i_dot_l_2 > 0.0f;
    var _S429 : bool;
    if(_S428)
    {
        _S429 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S429 = false;
    }
    var _S430 : f32 = select(0.0f, _S427, _S429);
    return _S430;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_10 : f32,  material_6 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S431 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S432 : f32 = dot(n_i_5, _S431);
    var _S433 : f32 = max(dot(n_i_5, l_2), 0.0f);
    var _S434 : f32 = max(dot(n_i_5, lobes_6.view), 0.0f);
    var _S435 : f32 = 1.0f / max(material_6.sheen_roughness, 0.05000000074505806f);
    var _S436 : f32 = (2.0f + _S435) * pow(max(1.0f - _S432 * _S432, 0.0f), 0.5f * _S435) * 0.5f * 0.31830987334251404f / max(4.0f * (_S433 + _S434 - _S433 * _S434), 0.0000152587890625f);
    return lobes_6.sheen * vec3<f32>((_S436 * _S433 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S437 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S438 : f32 = lobes_7.p_reflect * _S437 / (4.0f * lobes_7.v_dot_h);
    var _S439 : bool = _S437 > 0.0f;
    var _S440 : f32 = select(0.0f, _S438, _S439);
    return _S440;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_12 : f32,  material_7 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S441 : f32 = dot(n_i_6, l_3);
    var _S442 : f32 = smithG1(alpha_12, max(_S441, 0.0f));
    var _S443 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S443)
    {
        var _S444 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_6);
        var _S445 : f32 = anisotropicG1(_S444, lobes_8.alphas);
        G1_l_1 = _S445;
    }
    else
    {
        G1_l_1 = _S442;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn misWeighted( throughput_0 : vec3<f32>,  lobe_pdf_0 : f32,  pdf_0 : f32,  power_0 : bool) -> vec3<f32>
{
    if(power_0)
    {
        var _S446 : f32 = lobe_pdf_0 / pdf_0;
        return throughput_0 * vec3<f32>(lobe_pdf_0) / vec3<f32>((pdf_0 * (1.0f + _S446 * _S446)));
    }
    return throughput_0 * vec3<f32>(lobe_pdf_0) / vec3<f32>((lobe_pdf_0 + pdf_0));
}

fn neeLobes_0( in_dir_4 : vec3<f32>,  dir_4 : vec3<f32>,  n_6 : vec3<f32>,  material_8 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_2 : bool,  pdf_1 : f32,  power_1 : bool,  random_state_2 : u32,  each_0 : ptr<function, array<vec3<f32>, i32(4)>>,  reached_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S447 : vec3<f32> = ((-(in_dir_4)));
    var _S448 : f32 = dot(n_6, _S447);
    var _S449 : f32 = (sign((_S448)));
    var _S450 : vec3<f32> = n_6 * vec3<f32>(_S449);
    var _S451 : AnisotropicFrame = anisotropicFrame(material_8, _S450);
    var _S452 : f32 = dot(_S450, dir_4);
    var _S453 : f32 = material_8.roughness;
    var _S454 : f32 = _S453 * _S453;
    var _S455 : vec3<f32> = vec3<f32>(0.0f);
    (*reached_0) = u32(0);
    var _S456 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S455, _S455, 0.0f, 0.0f, _S455, _S455, 0.0f, 0.0f, 0.0f, 0.0f, _S455, 0.0f, _S455, _S455, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S456;
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
        (*each_0)[i_0] = _S455;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_1 : vec3<f32> = _S455;
    i_0 = u32(0);
    var f_1 : vec3<f32> = _S455;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S457 : u32;
        if(i_0 == u32(3))
        {
            _S457 = u32(4);
        }
        else
        {
            _S457 = i_0;
        }
        var _S458 : bool = _S457 == u32(0);
        if(_S458)
        {
        }
        var _S459 : bool;
        if(_S458)
        {
            var _S460 : f32 = rgb_to_greyscale(material_8.translucent);
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
            var _S463 : vec3<f32> = ((-(in_dir_4)));
            _S461 = ((_S462 * dot(n_6, _S463)) < 0.0f) == refracted_2;
        }
        else
        {
            _S461 = (_S457 == u32(1)) == refracted_2;
        }
        var ggx_n_2 : vec3<f32>;
        if(_S461)
        {
            var _S464 : u32;
            if(_S457 == u32(4))
            {
                _S464 = u32(2);
            }
            else
            {
                _S464 = _S457;
            }
            var _S465 : bool = _S464 != half_of_0;
            var half_of_1 : u32;
            if(_S465)
            {
                var _S466 : bool = _S464 == u32(0);
                if(_S466)
                {
                    var _S467 : vec3<f32> = sampledHalf(in_dir_4, n_6, material_8, random_state_2, _S451);
                    ggx_n_2 = _S467;
                }
                else
                {
                    var _S468 : bool = _S464 == u32(1);
                    if(_S468)
                    {
                        var _S469 : vec3<f32> = refractedHalf(in_dir_4, dir_4, n_6, eta_i_7, eta_o_7);
                        ggx_n_2 = _S469;
                    }
                    else
                    {
                        var _S470 : vec3<f32> = reflectedHalf(in_dir_4, dir_4);
                        ggx_n_2 = _S470;
                    }
                }
                var _S471 : vec3<f32> = ((-(in_dir_4)));
                var _S472 : BSDFLobes = bsdfLobes(in_dir_4, _S471, _S450, ggx_n_2, material_8, eta_i_7, eta_o_7, _S451);
                lobe_terms_0 = _S472;
                var _S473 : f32 = translucentShare(material_8);
                lobe_terms_0.translucent_share = _S473;
                half_of_1 = _S464;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            var throughput_1 : vec3<f32>;
            var lobe_pdf_1 : f32;
            switch(_S457)
            {
            case u32(0):
                {
                    var _S474 : f32 = diffusePDF(_S452, 0.0f, abs(_S448), _S454, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S475 : vec3<f32> = diffuseBSDF(dir_4, _S450, _S454, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S474;
                    throughput_1 = _S475;
                }
            case u32(1):
                {
                    var _S476 : f32 = refractPDF(_S452, dot(dir_4, ggx_n_2), abs(_S448), _S454, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S477 : vec3<f32> = refractBSDF(dir_4, _S450, _S454, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S476;
                    throughput_1 = _S477;
                }
            case u32(4):
                {
                    var _S478 : f32 = sheenVelvetPDF(_S452, 0.0f, abs(_S448), _S454, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S479 : vec3<f32> = sheenVelvetBSDF(dir_4, _S450, _S454, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S478;
                    throughput_1 = _S479;
                }
            default :
                {
                    var _S480 : f32 = reflectPDF(_S452, 0.0f, abs(_S448), _S454, lobe_terms_0, eta_i_7, eta_o_7);
                    var _S481 : vec3<f32> = reflectBSDF(dir_4, _S450, _S454, material_8, lobe_terms_0);
                    lobe_pdf_1 = _S480;
                    throughput_1 = _S481;
                }
            }
            var _S482 : bool = lobe_pdf_1 > 0.0f;
            var f_2 : vec3<f32>;
            if(_S482)
            {
                var _S483 : vec3<f32> = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_0] = _S483;
                var _S484 : u32 = ((*reached_0) | (((u32(1) << (i_0)))));
                (*reached_0) = _S484;
                var f_3 : vec3<f32> = f_1 + (*each_0)[i_0];
                f_2 = f_3;
            }
            else
            {
                f_2 = f_1;
            }
            half_of_0 = half_of_1;
            f_1 = f_2;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_1 = ggx_n_2;
        i_0 = i_2;
    }
    return f_1;
}

fn neeBSDF( in_dir_5 : vec3<f32>,  dir_5 : vec3<f32>,  n_7 : vec3<f32>,  material_9 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  refracted_3 : bool,  pdf_2 : f32,  power_2 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var reached_1 : u32 = u32(0);
    var each_1 : array<vec3<f32>, i32(4)>;
    var _S485 : vec3<f32> = neeLobes_0(in_dir_5, dir_5, n_7, material_9, eta_i_8, eta_o_8, refracted_3, pdf_2, power_2, random_state_3, &(each_1), &(reached_1));
    return _S485;
}

fn skyBSDF( in_dir_6 : vec3<f32>,  dir_6 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_3 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S486 : bool = wrongSide_0(is_inside_2, false, dir_6, surface_1.geometry_n);
    var _S487 : vec3<f32> = neeBSDF(in_dir_6, dir_6, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S486, pdf_3, false, random_state_4);
    return _S487;
}

fn SkySample_x24init_0( dir_7 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S488 : SkySample;
    _S488.dir = dir_7;
    _S488.radiance = radiance_1;
    _S488.color = color_0;
    _S488.random_state = random_state_5;
    return _S488;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S489 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S490 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S491 : vec2<u32> = _S489 - _S490;
    var _S492 : Random = pcg(init_random_state_0);
    var _S493 : Random = pcg(_S492.state);
    var _S494 : Random = pcg(_S493.state);
    var _S495 : Random = pcg(_S494.state);
    var _S496 : u32 = _S491.x;
    var _S497 : u32 = searchCDF_0(vec2<u32>(_S496, u32(0)), vec2<u32>(u32(0), u32(1)), _S491.y, _S492.value);
    var _S498 : u32 = searchCDF_0(vec2<u32>(u32(0), _S497), _S490, _S496, _S493.value);
    var _S499 : vec2<f32> = (vec2<f32>(f32(_S498), f32(_S497)) + vec2<f32>(_S494.value, _S495.value)) / vec2<f32>(_S491) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S500 : f32 = _S499.y;
    var _S501 : f32 = sin(_S500);
    var _S502 : f32 = _S499.x;
    var _S503 : vec3<f32> = vec3<f32>(_S501 * cos(_S502), cos(_S500), _S501 * sin(_S502));
    var _S504 : f32 = environmentPdf_0(_S503);
    var _S505 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S503, surface_2, eta_1, is_inside_3, _S504, lobe_state_0);
    var _S506 : bool = !(_S504 > 0.0f);
    var _S507 : bool;
    if(_S506)
    {
        _S507 = true;
    }
    else
    {
        _S507 = (all((_S505 == vec3<f32>(0.0f))));
    }
    if(_S507)
    {
        var _S508 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S503, _S508, _S508, _S495.state);
    }
    var _S509 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S503);
    return SkySample_x24init_0(_S503, _S509, _S505 * _S509, _S495.state);
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
    var _S510 : TreeSample;
    _S510.dir = dir_8;
    _S510.radiance = radiance_2;
    _S510.density = density_0;
    _S510.random_state = random_state_6;
    return _S510;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S511 : f32 = importance(first_1, p_10, normal_3);
    var _S512 : f32 = importance(second_1, p_10, normal_3);
    var _S513 : vec2<f32> = vec2<f32>(_S511, _S512);
    var _S514 : bool = _S511 == 0.0f;
    var _S515 : bool;
    if(_S514)
    {
        _S515 = _S512 == 0.0f;
    }
    else
    {
        _S515 = false;
    }
    if(_S515)
    {
        return u32(2);
    }
    var _S516 : f32 = _S511 + _S512;
    var _S517 : bool = _S512 > 0.0f;
    if(_S517)
    {
        _S515 = ((*pick_0) * _S516) >= _S511;
    }
    else
    {
        _S515 = false;
    }
    var _S518 : u32 = select(u32(0), u32(1), _S515);
    var _S519 : f32 = min(((*pick_0) * _S516 - f32(_S518) * _S511) / _S513[_S518], 0.99999994039535522f);
    (*pick_0) = _S519;
    var _S520 : f32 = (*probability_3) * (_S513[_S518] / _S516);
    (*probability_3) = _S520;
    return _S518;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S521 : vec3<f32> = center_1 - p_11;
    var _S522 : f32 = radius_1 * radius_1 / dot(_S521, _S521);
    var _S523 : f32 = u1_0 * _S522 / (1.0f + sqrt(max(1.0f - _S522, 0.0f)));
    var _S524 : f32 = 2.0f * u1_0;
    var _S525 : bool = _S522 >= 1.0f;
    var _S526 : f32 = select(_S523, _S524, _S525);
    var _S527 : f32 = sqrt(max(_S526 * (2.0f - _S526), 0.0f));
    var _S528 : f32 = 6.28318548202514648f * u2_0;
    var _S529 : vec3<f32> = vec3<f32>(_S527 * cos(_S528), 1.0f - _S526, _S527 * sin(_S528));
    var _S530 : vec3<f32> = (normalize((_S521)));
    var _S531 : vec3<f32> = tangentToWorld(_S529, _S530);
    return _S531;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S532 : vec3<f32> = center_2 - ray_1.origin;
    var _S533 : f32 = dot(_S532, ray_1.unit_direction);
    var _S534 : f32 = dot(_S532, _S532) - _S533 * _S533;
    var _S535 : f32 = radius_3 * radius_3;
    var _S536 : bool = _S534 > _S535;
    if(_S536)
    {
        return 4.294967296e+09f;
    }
    var _S537 : f32 = sqrt(_S535 - _S534);
    var _S538 : f32 = _S533 - _S537;
    var _S539 : f32 = _S533 + _S537;
    var _S540 : bool = _S538 > 0.0000152587890625f;
    var _S541 : bool;
    if(_S540)
    {
        _S541 = _S538 < max_len_0;
    }
    else
    {
        _S541 = false;
    }
    if(_S541)
    {
        return _S538;
    }
    var _S542 : bool = _S539 > 0.0000152587890625f;
    if(_S542)
    {
        _S541 = _S539 < max_len_0;
    }
    else
    {
        _S541 = false;
    }
    if(_S541)
    {
        return _S539;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S543 : Random = pcg(init_random_state_1);
    var _S544 : Random = pcg(_S543.state);
    var _S545 : Random = pcg(_S544.state);
    var _S546 : vec3<f32> = vec3<f32>(0.0f);
    var _S547 : TreeSample = TreeSample_x24init_0(_S546, _S546, 0.0f, _S545.state);
    var sample_0 : TreeSample = _S547;
    var _S548 : vec3<f32> = select(smooth_n_2, _S546, sided_0);
    var _S549 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S550 : vec3<f32> = origin_4 + _S549 * smooth_n_2;
    var pick_1 : f32 = _S543.value;
    var probability_4 : f32 = 1.0f;
    var n_8 : u32 = u32(0);
    loop
    {
        var _S551 : vec4<u32> = (access_light_tree(4u + 4u * (n_8)));
        if((_S551.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S552 : u32 = (access_light_tree(3u + 4u * (n_8)).w);
        var _S553 : u32 = n_8 + u32(1);
        var _S554 : LightBounds = (lightBounds((_S553)));
        var _S555 : LightBounds = (lightBounds((_S552)));
        var _S556 : u32 = pickChild(_S554, _S555, origin_4, _S548, &(pick_1), &(probability_4));
        var _S557 : bool = _S556 > u32(1);
        if(_S557)
        {
            return sample_0;
        }
        var _S558 : bool = _S556 == u32(1);
        var _S559 : u32 = select(_S553, _S552, _S558);
        n_8 = _S559;
    }
    var _S560 : bool = n_8 == u32(0);
    var _S561 : bool;
    if(_S560)
    {
        var _S562 : LightBounds = (lightBounds((u32(0))));
        var _S563 : f32 = importance(_S562, origin_4, _S548);
        _S561 = !(_S563 > 0.0f);
    }
    else
    {
        _S561 = false;
    }
    if(_S561)
    {
        return sample_0;
    }
    var _S564 : vec4<u32> = (access_light_tree(4u + 4u * (n_8)));
    var _S565 : bool = (_S564.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S565)
    {
        var _S566 : Light = (lights[(_S564.y)]);
        if(sided_0)
        {
            var _S567 : f32 = (sign((dot(geometry_n_1, _S566.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S567);
            var _S568 : vec3<f32> = origin_4 + _S549 * lift_n_1;
            start_5 = _S568;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S550;
            lift_n_0 = smooth_n_2;
        }
        var _S569 : bool = (_S566.variance) == 0.0f;
        if(_S569)
        {
            var _S570 : vec3<f32> = _S566.position - start_5;
            var _S571 : vec3<f32> = (normalize((_S570)));
            sample_0.dir = _S571;
            var _S572 : vec3<f32> = _S566.color * vec3<f32>(_S566.intensity) / vec3<f32>((dot(_S570, _S570) * probability_4));
            sample_0.radiance = _S572;
            shadow_1 = _S570;
        }
        else
        {
            var _S573 : vec3<f32> = sampleSphere(_S566.position, _S566.variance, start_5, _S544.value, _S545.value);
            sample_0.dir = _S573;
            var _S574 : f32 = sphereDensity(_S566.position, _S566.variance, start_5);
            var _S575 : f32 = probability_4 * _S574;
            sample_0.density = _S575;
            var _S576 : vec3<f32> = pointLightRadiance(_S566.color, _S566.intensity, _S566.variance);
            var _S577 : vec3<f32> = _S576 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S577;
            var _S578 : f32 = raySphere_0(_S566.position, _S566.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S579 : vec3<f32> = sample_0.dir * vec3<f32>(_S578);
            shadow_1 = _S579;
        }
    }
    else
    {
        var _S580 : u32 = _S564.y;
        var _S581 : u32 = ((instance_uint[(_S580) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S582 : u32 = _S581 + _S564.z;
        var _S583 : mat3x3<f32> = (worldTriangle((_S580), (_S582)));
        var _S584 : f32 = sqrt(_S544.value);
        var _S585 : vec2<f32> = vec2<f32>(_S584 * (1.0f - _S545.value), _S584 * _S545.value);
        var _S586 : vec3<f32> = (((_S583) * (vec3<f32>(1.0f - _S584, _S585))));
        if(sided_0)
        {
            var _S587 : f32 = (sign((dot(geometry_n_1, _S586 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S587);
            var _S588 : vec3<f32> = origin_4 + _S549 * lift_n_2;
            start_5 = _S588;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S589 : bool = !((dot(smooth_n_2, _S586 - origin_4)) > 0.0f);
            if(_S589)
            {
                return sample_0;
            }
            start_5 = _S550;
            lift_n_0 = smooth_n_2;
        }
        var _S590 : Surface = (surfaceAt((Hit_x24init_0(_S585, _S580, _S582, u32(0), 0.0f)), (_S586), (_S545.state)));
        sample_0.random_state = _S590.random_state;
        var _S591 : vec3<f32> = _S586 - start_5;
        var _S592 : vec3<f32> = (normalize((_S591)));
        sample_0.dir = _S592;
        var _S593 : f32 = solidAngle(probability_4, cross(_S583[i32(1)] - _S583[i32(0)], _S583[i32(2)] - _S583[i32(0)]), _S591);
        sample_0.density = _S593;
        var _S594 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S590.smooth_n))));
        var _S595 : vec3<f32> = _S590.material.emissive * vec3<f32>(max(_S594, 0.0f));
        var _S596 : vec3<f32> = select(_S595, _S546, _S590.skip);
        var _S597 : vec3<f32> = _S596 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S597;
        shadow_1 = _S591;
    }
    var _S598 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S599 : vec3<f32> = sample_0.radiance * _S598;
    var _S600 : bool = (all((_S598 == _S546)));
    var _S601 : vec3<f32> = select(_S599, _S546, _S600);
    sample_0.radiance = _S601;
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
    var _S602 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S603 : bool = b_1 > 0.0f;
    var _S604 : f32 = select(1.0f, _S602, _S603);
    return _S604;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S605 : u32 = (lightSlot((hit_1)));
    var _S606 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S605, light_point_1);
    var _S607 : f32 = powerHeuristic(vertex_0.pdf, _S606);
    return _S607;
}

fn environment_0( dir_9 : vec3<f32>) -> vec3<f32>
{
    var _S608 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S609 : bool = (_S608.x) > u32(1);
    var _S610 : bool;
    if(_S609)
    {
        var _S611 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S610 = (_S611.y) > u32(1);
    }
    else
    {
        _S610 = false;
    }
    if(_S610)
    {
        var _S612 : vec3<f32> = (env_map_sample((dir_9)));
        return _S612;
    }
    var _S613 : vec3<f32> = (uniforms_float.ambient);
    return _S613;
}

fn environmentMapped_0() -> bool
{
    var _S614 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S615 : bool = (_S614.x) > u32(1);
    var _S616 : bool;
    if(_S615)
    {
        var _S617 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S616 = (_S617.y) > u32(1);
    }
    else
    {
        _S616 = false;
    }
    return _S616;
}

fn escapeWeight_0( pdf_4 : f32,  dir_10 : vec3<f32>) -> f32
{
    var _S618 : bool = pdf_4 <= 0.0f;
    var _S619 : bool;
    if(_S618)
    {
        _S619 = true;
    }
    else
    {
        var _S620 : bool = environmentMapped_0();
        _S619 = !_S620;
    }
    if(_S619)
    {
        return 1.0f;
    }
    var _S621 : f32 = environmentPdf_0(dir_10);
    return pdf_4 / (pdf_4 + _S621);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S622 : vec2<u32> = global_invocation_id_1.xy;
    var _S623 : vec2<i32> = vec2<i32>(_S622 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S624 : vec2<i32> = _S623 + vec2<i32>(i32(i_3 % u32(24)), i32(i_3 / u32(24)));
        var _S625 : bool = (all((_S624 >= vec2<i32>(i32(0)))));
        var _S626 : bool;
        if(_S625)
        {
            var _S627 : vec2<u32> = (uniforms_uint.render_size);
            _S626 = (all((_S624 < vec2<i32>(_S627))));
        }
        else
        {
            _S626 = false;
        }
        if(_S626)
        {
            var _S628 : vec4<u32> = (textureLoad(reservoir_prev, (_S624), (u32(0)), 0));
            var _S629 : u32 = _S628.x;
            var _S630 : bool = (bitcast<f32>((_S628.z))) > 0.0f;
            var _S631 : u32 = select(u32(0), _S629, _S630);
            seed_1 = _S631;
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
    var _S632 : u32 = local_invocation_id_0.y;
    var _S633 : u32 = local_invocation_id_0.x;
    var _S634 : u32 = duplication_seeds_0[(_S632 + u32(8)) * u32(24) + _S633 + u32(8)];
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
            var _S635 : bool = (duplication_seeds_0[(_S632 + seed_1) * u32(24) + _S633 + x_1]) == _S634;
            var _S636 : u32 = select(u32(0), u32(1), _S635);
            var count_2 : u32 = count_1 + _S636;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S637 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S638 : bool = _S634 != u32(0);
    var _S639 : f32 = select(0.0f, _S637, _S638);
    textureStore(duplication_out, (vec2<i32>(_S622)), 0, (vec4<u32>((bitcast<u32>((_S639))), u32(0), u32(0), u32(0))));
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
    var _S640 : Selection;
    _S640.r = r_2;
    _S640.w_sum = w_sum_0;
    _S640.color = color_2;
    _S640.random_state = random_state_7;
    return _S640;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S641 : u32 = hash(index_0);
    var _S642 : u32 = hash((seed_2 ^ (_S641)));
    return _S642;
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

fn Shift_x24init_0( f_4 : vec3<f32>,  jac_1 : f32) -> Shift
{
    var _S643 : Shift;
    _S643.f = f_4;
    _S643.jac = jac_1;
    return _S643;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S644 : f32 = rgb_to_greyscale(weight_0);
    var _S645 : bool = _S644 > 0.0f;
    var _S646 : bool;
    if(_S645)
    {
        _S646 = _S644 < 3.00000000549775576e+38f;
    }
    else
    {
        _S646 = false;
    }
    var _S647 : bool = !_S646;
    if(_S647)
    {
        return;
    }
    var _S648 : f32 = (*sel_0).w_sum + _S644;
    (*sel_0).w_sum = _S648;
    var _S649 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S649;
    var _S650 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S650.state;
    var _S651 : bool = (_S650.value * (*sel_0).w_sum) <= _S644;
    if(_S651)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_3 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_3;
    var _S652 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S652;
    var _S653 : f32 = r_3.jac * shifted_0.jac;
    candidate_1.jac = _S653;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_3.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_4 : Reservoir = sel_2.r;
    var _S654 : f32 = rgb_to_greyscale(r_4.f);
    var _S655 : f32 = sel_2.w_sum / _S654;
    var _S656 : bool = _S654 > 0.0f;
    var _S657 : f32 = select(0.0f, _S655, _S656);
    r_4.w = _S657;
    r_4.c = c_2;
    return r_4;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S658 : vec2<u32> = global_invocation_id_2.xy;
    var _S659 : vec2<i32> = vec2<i32>(_S658);
    var _S660 : vec3<f32> = vec3<f32>(0.0f);
    var _S661 : Domain = Domain_x24init_0(_S660, _S660, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S661;
    var _S662 : bool = (currentDomain((_S659), &(dom_3)));
    var _S663 : bool = !_S662;
    if(_S663)
    {
        storeReservoir(reservoir_prev_out, (_S659), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S660, 0.0f, vec4<u32>(u32(0)), _S660, _S660)), (dom_3.hit));
        var _S664 : vec2<f32> = vec2<f32>(_S658);
        var _S665 : vec2<u32> = (uniforms_uint.render_size);
        var _S666 : vec2<f32> = _S664 / vec2<f32>(_S665.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S667 : vec3<f32> = vec3<f32>(_S666, 1.0f);
        var _S668 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S669 : vec3<f32> = (normalize(((((_S668) * (_S667))))));
        var _S670 : vec3<f32> = environment_0(_S669);
        textureStore(compute_out, (_S659), (u32(0)), (vec4<f32>(_S670, 1.0f)));
        var _S671 : u32 = (uniforms_uint.is_temporal);
        var _S672 : bool = _S671 == u32(1);
        if(_S672)
        {
            textureStore(compute_out, (_S659), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S673 : Reservoir = (loadReservoir(reservoir_temp, (_S659)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S673.c;
    loop
    {
        var _S674 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S674)
        {
        }
        else
        {
            break;
        }
        var _S675 : vec2<i32> = partner_0(_S659, t_13);
        var neighbor_0 : Domain = _S661;
        var _S676 : bool = (currentDomain((_S675), &(neighbor_0)));
        if(_S676)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S677 : vec4<u32> = (textureLoad(reservoir_temp, (_S675), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S677.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S678 : f32 = _S673.c / max(count_3, 1.0f);
    var _S679 : f32 = rgb_to_greyscale(_S673.f);
    var _S680 : bool = count_3 == 0.0f;
    var _S681 : f32 = select(0.0f, 1.0f, _S680);
    var _S682 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S660, 0.0f, vec4<u32>(u32(0)), _S660, _S660), 0.0f, _S660, u32(0));
    var sel_3 : Selection = _S682;
    var _S683 : u32 = (uniforms_uint.frame);
    var _S684 : u32 = hash(_S683);
    var _S685 : u32 = global_invocation_id_2.x;
    var _S686 : vec2<u32> = (uniforms_uint.render_size);
    var _S687 : u32 = stream(_S684, _S685 + _S686.x * global_invocation_id_2.y);
    var _S688 : u32 = stream(_S687, u32(195));
    sel_3.random_state = _S688;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S681;
    loop
    {
        var _S689 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S689)
        {
        }
        else
        {
            break;
        }
        var _S690 : vec2<i32> = partner_0(_S659, t_13);
        var neighbor_dom_0 : Domain = _S661;
        var _S691 : bool = (currentDomain((_S690), &(neighbor_dom_0)));
        if(_S691)
        {
            var _S692 : Reservoir = (loadReservoir(reservoir_temp, (_S690)));
            var _S693 : vec4<u32> = (textureLoad(shift_data, (_S690), (t_13), 0));
            var _S694 : vec4<f32> = (bitcast<vec4<f32>>((_S693)));
            var _S695 : vec4<u32> = (textureLoad(shift_data, (_S659), (t_13), 0));
            var _S696 : vec4<f32> = (bitcast<vec4<f32>>((_S695)));
            var _S697 : f32 = pairShare(_S692.c, _S678, c_sum_1);
            var _S698 : bool = _S679 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S698)
            {
                var _S699 : f32 = rgb_to_greyscale(_S696.xyz);
                var _S700 : f32 = canonicalWeight(_S697, _S678, _S679, _S692.c, _S699);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S700;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S701 : vec3<f32> = _S694.xyz;
            var _S702 : Shift = Shift_x24init_0(_S701, _S694.w);
            var _S703 : f32 = rgb_to_greyscale(_S692.f);
            var _S704 : f32 = rgb_to_greyscale(_S701);
            var _S705 : f32 = neighborWeight(_S697, _S692.c, _S703, _S678, _S704);
            offerShifted(&(sel_3), _S692, _S702, _S705);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S673, Shift_x24init_0(_S673.f, 1.0f), canonical_mis_0);
    var _S706 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S659), (_S706), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S659), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S707 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S708 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S709 : f32 = (sign((dot(_S708, _S707.smooth_n))));
    var _S710 : vec3<f32> = _S707.material.emissive * vec3<f32>(max(_S709, 0.0f));
    var _S711 : vec3<f32> = select(_S710, _S660, _S707.skip);
    var _S712 : vec3<f32> = clamp(sel_3.color + _S711, _S660, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S659), (u32(0)), (vec4<f32>(_S712, 1.0f)));
    var _S713 : u32 = (uniforms_uint.is_temporal);
    var _S714 : bool = _S713 == u32(1);
    if(_S714)
    {
        textureStore(compute_out, (_S659), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_5 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S715 : NEEVertex;
    _S715.none = none_0;
    _S715.pdf = pdf_5;
    _S715.origin = origin_5;
    _S715.smooth_n = smooth_n_3;
    _S715.start = start_6;
    return _S715;
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
    var _S716 : Vertex;
    _S716.rough = rough_0;
    _S716.lobe = lobe_0;
    _S716.pdf = pdf_6;
    _S716.cos = cos_0;
    _S716.inside = inside_0;
    return _S716;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>) -> Material
{
    var _S717 : Material;
    _S717.albedo = albedo_0;
    _S717.emissive = emissive_0;
    _S717.roughness = roughness_0;
    _S717.metallic = metallic_0;
    _S717.transmission = transmission_0;
    _S717.ior = ior_0;
    _S717.absorption = absorption_0;
    _S717.specular_tint = specular_tint_0;
    _S717.specular_level = specular_level_0;
    _S717.translucent = translucent_0;
    _S717.sheen = sheen_2;
    _S717.sheen_roughness = sheen_roughness_0;
    _S717.anisotropy = anisotropy_0;
    _S717.anisotropic_rotation = anisotropic_rotation_0;
    _S717.tangent = tangent_2;
    return _S717;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_10 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S718 : Surface;
    _S718.smooth_n = smooth_n_4;
    _S718.geometry_n = geometry_n_2;
    _S718.geometry_offset = geometry_offset_2;
    _S718.material = material_10;
    _S718.skip = skip_0;
    _S718.random_state = random_state_8;
    return _S718;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S719 : bool = transmission_1 > 0.0f;
    var _S720 : bool;
    if(_S719)
    {
        _S720 = true;
    }
    else
    {
        _S720 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S721 : f32;
    if(_S720)
    {
        _S721 = 1.0f;
    }
    else
    {
        _S721 = -1.0f;
    }
    return _S721;
}

fn facingRay_0( surface_3 : Surface,  dir_11 : vec3<f32>) -> Surface
{
    var _S722 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_11);
    var _S723 : vec3<f32> = vec3<f32>(_S722);
    return Surface_x24init_0(surface_3.smooth_n * _S723, surface_3.geometry_n * _S723, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S724 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S724));
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
    var _S725 : bool;
    if(open_0)
    {
        _S725 = prev_rough_0;
    }
    else
    {
        _S725 = false;
    }
    if(_S725)
    {
        _S725 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S725 = false;
    }
    return _S725;
}

fn vertexEta( material_11 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S726 : bool = n_dot_v_0 < 0.0f;
    var _S727 : f32 = select(1.0f, material_11.ior, _S726);
    var _S728 : f32 = select(material_11.ior, 1.0f, _S726);
    return vec2<f32>(_S727, _S728);
}

fn neeDecision( material_12 : Material,  n_dot_v_1 : f32,  eta_i_9 : f32,  eta_o_9 : f32) -> bool
{
    var _S729 : f32 = fresnel(abs(n_dot_v_1), eta_i_9, eta_o_9);
    var _S730 : vec3<f32> = (mix((vec3<f32>(_S729)), (material_12.albedo), (material_12.metallic)));
    var _S731 : f32 = rgb_to_greyscale(_S730);
    var _S732 : f32 = max((1.0f - _S731) * (1.0f - material_12.metallic) * (1.0f - material_12.transmission), 0.0f);
    var _S733 : bool = _S732 > 0.03999999910593033f;
    var _S734 : bool;
    if(_S733)
    {
        _S734 = true;
    }
    else
    {
        _S734 = (material_12.roughness) > 0.20000000298023224f;
    }
    return _S734;
}

fn isTranslucent_0( material_13 : Material) -> bool
{
    var _S735 : f32 = rgb_to_greyscale(material_13.translucent);
    return _S735 > 0.0f;
}

fn BSDF( in_dir_7 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_0 : vec3<f32>,  material_14 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S736 : vec3<f32> = ((-(in_dir_7)));
    var _S737 : f32 = dot(n_9, _S736);
    var _S738 : f32 = (sign((_S737)));
    var _S739 : vec3<f32> = n_9 * vec3<f32>(_S738);
    var _S740 : AnisotropicFrame = anisotropicFrame(material_14, _S739);
    var _S741 : f32 = dot(_S739, out_dir_2);
    var _S742 : f32 = material_14.roughness;
    var _S743 : f32 = _S742 * _S742;
    var _S744 : bool = (dot(g_n_0, _S736) * dot(g_n_0, out_dir_2)) > 0.0f;
    var _S745 : u32;
    if(_S744)
    {
        _S745 = u32(3);
    }
    else
    {
        _S745 = u32(1);
    }
    var _S746 : vec3<f32> = vec3<f32>(0.0f);
    var _S747 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S746, _S746, 0.0f, 0.0f, _S746, _S746, 0.0f, 0.0f, 0.0f, 0.0f, _S746, 0.0f, _S746, _S746, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_1 : BSDFLobes = _S747;
    var half_of_2 : u32 = u32(4294967295);
    var ggx_n_3 : vec3<f32> = _S746;
    var f_5 : vec3<f32> = _S746;
    var i_5 : u32 = u32(0);
    loop
    {
        if(i_5 < _S745)
        {
        }
        else
        {
            break;
        }
        var _S748 : u32;
        if(!_S744)
        {
            _S748 = u32(1);
        }
        else
        {
            if(i_5 == u32(0))
            {
                _S748 = u32(0);
            }
            else
            {
                if(i_5 == u32(1))
                {
                    _S748 = u32(2);
                }
                else
                {
                    _S748 = u32(4);
                }
            }
        }
        var _S749 : u32;
        if(_S748 == u32(4))
        {
            _S749 = u32(2);
        }
        else
        {
            _S749 = _S748;
        }
        var _S750 : bool = _S749 != half_of_2;
        var ggx_n_4 : vec3<f32>;
        if(_S750)
        {
            var _S751 : bool = _S749 == u32(0);
            if(_S751)
            {
                var _S752 : vec3<f32> = sampledHalf(in_dir_7, n_9, material_14, random_state_9, _S740);
                ggx_n_4 = _S752;
            }
            else
            {
                var _S753 : bool = _S749 == u32(1);
                if(_S753)
                {
                    var _S754 : vec3<f32> = refractedHalf(in_dir_7, out_dir_2, n_9, eta_i_10, eta_o_10);
                    ggx_n_4 = _S754;
                }
                else
                {
                    var _S755 : vec3<f32> = reflectedHalf(in_dir_7, out_dir_2);
                    ggx_n_4 = _S755;
                }
            }
            var _S756 : vec3<f32> = ((-(in_dir_7)));
            var _S757 : BSDFLobes = bsdfLobes(in_dir_7, _S756, _S739, ggx_n_4, material_14, eta_i_10, eta_o_10, _S740);
            lobe_terms_1 = _S757;
            var _S758 : f32 = translucentShare(material_14);
            lobe_terms_1.translucent_share = _S758;
            half_of_2 = _S749;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        var throughput_2 : vec3<f32>;
        var pdf_7 : f32;
        switch(_S748)
        {
        case u32(0):
            {
                var _S759 : f32 = diffusePDF(_S741, 0.0f, abs(_S737), _S743, lobe_terms_1, eta_i_10, eta_o_10);
                var _S760 : vec3<f32> = diffuseBSDF(out_dir_2, _S739, _S743, material_14, lobe_terms_1);
                pdf_7 = _S759;
                throughput_2 = _S760;
            }
        case u32(1):
            {
                var _S761 : f32 = refractPDF(_S741, dot(out_dir_2, ggx_n_4), abs(_S737), _S743, lobe_terms_1, eta_i_10, eta_o_10);
                var _S762 : vec3<f32> = refractBSDF(out_dir_2, _S739, _S743, material_14, lobe_terms_1);
                pdf_7 = _S761;
                throughput_2 = _S762;
            }
        case u32(4):
            {
                var _S763 : f32 = sheenVelvetPDF(_S741, 0.0f, abs(_S737), _S743, lobe_terms_1, eta_i_10, eta_o_10);
                var _S764 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S739, _S743, material_14, lobe_terms_1);
                pdf_7 = _S763;
                throughput_2 = _S764;
            }
        default :
            {
                var _S765 : f32 = reflectPDF(_S741, 0.0f, abs(_S737), _S743, lobe_terms_1, eta_i_10, eta_o_10);
                var _S766 : vec3<f32> = reflectBSDF(out_dir_2, _S739, _S743, material_14, lobe_terms_1);
                pdf_7 = _S765;
                throughput_2 = _S766;
            }
        }
        var _S767 : vec3<f32>;
        if(pdf_7 > 0.0f)
        {
            _S767 = throughput_2 * vec3<f32>(pdf_7);
        }
        else
        {
            _S767 = _S746;
        }
        if(i_5 == u32(0))
        {
            f_5 = _S767;
        }
        else
        {
            f_5 = f_5 + _S767;
        }
        var i_6 : u32 = i_5 + u32(1);
        ggx_n_3 = ggx_n_4;
        i_5 = i_6;
    }
    return f_5;
}

fn translucentCorrection( in_dir_8 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_1 : vec3<f32>,  material_15 : Material,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S768 : f32 = dot(n_10, out_dir_3);
    var _S769 : vec3<f32> = ((-(in_dir_8)));
    var _S770 : bool = (_S768 * dot(n_10, _S769)) < 0.0f;
    var _S771 : vec3<f32> = ((-(in_dir_8)));
    var _S772 : f32 = dot(n_10, _S771);
    var _S773 : f32 = (sign((_S772)));
    var _S774 : vec3<f32> = n_10 * vec3<f32>(_S773);
    var _S775 : AnisotropicFrame = anisotropicFrame(material_15, _S774);
    var _S776 : f32 = material_15.roughness;
    var _S777 : f32 = _S776 * _S776;
    var _S778 : vec3<f32> = ((-(in_dir_8)));
    var _S779 : vec3<f32> = sampledHalf(in_dir_8, n_10, material_15, random_state_10, _S775);
    var _S780 : BSDFLobes = bsdfLobes(in_dir_8, _S778, _S774, _S779, material_15, eta_i_11, eta_o_11, _S775);
    var sampled_0 : BSDFLobes = _S780;
    var _S781 : f32 = translucentShare(material_15);
    sampled_0.translucent_share = _S781;
    var _S782 : f32 = diffusePDF(dot(_S774, out_dir_3), 0.0f, abs(_S772), _S777, sampled_0, eta_i_11, eta_o_11);
    var _S783 : vec3<f32>;
    if(_S782 > 0.0f)
    {
        var _S784 : vec3<f32> = diffuseBSDF(out_dir_3, _S774, _S777, material_15, sampled_0);
        _S783 = _S784 * vec3<f32>(_S782);
    }
    else
    {
        _S783 = vec3<f32>(0.0f);
    }
    var _S785 : vec3<f32> = ((-(in_dir_8)));
    var _S786 : bool = (dot(g_n_1, _S785) * dot(g_n_1, out_dir_3)) > 0.0f;
    var _S787 : vec3<f32> = vec3<f32>(0.0f);
    var _S788 : f32 = select(1.0f, -1.0f, _S786);
    var _S789 : vec3<f32> = _S783 * vec3<f32>(_S788);
    var _S790 : vec3<f32> = select(_S787, _S789, _S770);
    return _S790;
}

fn translucentBSDF( in_dir_9 : vec3<f32>,  out_dir_4 : vec3<f32>,  n_11 : vec3<f32>,  g_n_2 : vec3<f32>,  material_16 : Material,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S791 : vec3<f32> = BSDF(in_dir_9, out_dir_4, n_11, g_n_2, material_16, eta_i_12, eta_o_12, random_state_11);
    var _S792 : vec3<f32> = translucentCorrection(in_dir_9, out_dir_4, n_11, g_n_2, material_16, eta_i_12, eta_o_12, random_state_11);
    return _S791 + _S792;
}

fn lightBSDF_0( in_dir_10 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_17 : Material,  eta_i_13 : f32,  eta_o_13 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S793 : bool = !competing_0;
    var _S794 : bool;
    if(_S793)
    {
        _S794 = true;
    }
    else
    {
        _S794 = (light_0.density) == 0.0f;
    }
    if(_S794)
    {
        var _S795 : bool = isTranslucent_0(material_17);
        if(_S795)
        {
            var _S796 : vec3<f32> = translucentBSDF(in_dir_10, light_0.dir, smooth_n_5, geometry_n_4, material_17, eta_i_13, eta_o_13, random_state_12);
            return _S796 * light_0.radiance;
        }
        var _S797 : vec3<f32> = BSDF(in_dir_10, light_0.dir, smooth_n_5, geometry_n_4, material_17, eta_i_13, eta_o_13, random_state_12);
        return _S797 * light_0.radiance;
    }
    var _S798 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_10)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S799 : vec3<f32> = neeBSDF(in_dir_10, light_0.dir, smooth_n_5, material_17, eta_i_13, eta_o_13, _S798, light_0.density, true, random_state_12);
    return _S799 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S800 : vec3<f32> = a_6 / b_2;
    var _S801 : vec3<f32> = vec3<f32>(0.0f);
    var _S802 : vec3<bool> = b_2 == _S801;
    var _S803 : vec3<f32> = select(_S800, _S801, _S802);
    return _S803;
}

fn withEnd( r_5 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_5;
    var _S804 : u32 = (insertBits((r_5.path), (end_0), (u32(0)), (u32(5))));
    var _S805 : u32 = (insertBits((_S804), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S805;
    candidate_2.f = f_6;
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
    var _S806 : SampleBSDF;
    _S806.unit_direction = unit_direction_1;
    _S806.throughput = throughput_3;
    _S806.random_state = random_state_13;
    _S806.refracted = refracted_4;
    _S806.lobe = lobe_1;
    _S806.pdf = pdf_8;
    return _S806;
}

fn sheenVelvetSample( n_i_7 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_18 : Material,  lobes_9 : BSDFLobes,  eta_i_14 : f32,  eta_o_14 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S807 : vec3<f32> = vec3<f32>(1.0f);
    var _S808 : SampleBSDF = SampleBSDF_x24init_0(_S807, _S807, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S808;
    var _S809 : Random = pcg(random_state_14);
    var _S810 : Random = pcg(_S809.state);
    sample_1.random_state = _S810.state;
    var _S811 : f32 = _S809.value;
    var _S812 : f32 = sqrt(max(0.0f, 1.0f - _S811 * _S811));
    var _S813 : f32 = 6.28318548202514648f * _S810.value;
    var _S814 : vec3<f32> = tangentToWorld(vec3<f32>(_S812 * cos(_S813), _S809.value, _S812 * sin(_S813)), n_i_7);
    sample_1.unit_direction = _S814;
    sample_1.lobe = u32(4);
    var _S815 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_7, alpha_13, material_18, lobes_9);
    sample_1.throughput = _S815;
    var _S816 : f32 = sheenVelvetPDF(_S809.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_14, eta_o_14);
    sample_1.pdf = _S816;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S817 : f32 = sqrt(random_1_0);
    var _S818 : f32 = 6.28318548202514648f * random_2_0;
    var _S819 : f32 = _S817 * cos(_S818);
    var _S820 : f32 = _S817 * sin(_S818);
    var _S821 : f32 = sqrt(max(0.0f, 1.0f - _S819 * _S819 - _S820 * _S820));
    return vec3<f32>(_S819, _S821, _S820);
}

fn diffuseSample( u_1 : f32,  n_i_8 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_19 : Material,  lobes_10 : BSDFLobes,  eta_i_15 : f32,  eta_o_15 : f32,  random_state_15 : u32) -> SampleBSDF
{
    var _S822 : vec3<f32> = vec3<f32>(1.0f);
    var _S823 : SampleBSDF = SampleBSDF_x24init_0(_S822, _S822, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S823;
    var _S824 : Random = pcg(random_state_15);
    var _S825 : Random = pcg(_S824.state);
    sample_2.random_state = _S825.state;
    var _S826 : vec3<f32> = sampleCosWeightedHemisphere(_S824.value, _S825.value);
    var _S827 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S828 : f32 = _S826.y;
    var _S829 : f32 = - _S828;
    var _S830 : f32 = select(_S828, _S829, _S827);
    var _S831 : vec3<f32> = tangentToWorld(vec3<f32>(_S826.x, _S830, _S826.z), n_i_8);
    sample_2.unit_direction = _S831;
    sample_2.refracted = _S827;
    sample_2.lobe = u32(0);
    var _S832 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_8, alpha_14, material_19, lobes_10);
    sample_2.throughput = _S832;
    var _S833 : f32 = diffusePDF(_S830, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_15, eta_o_15);
    sample_2.pdf = _S833;
    return sample_2;
}

fn refractSample( ggx_n_5 : vec3<f32>,  n_i_9 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_20 : Material,  lobes_11 : BSDFLobes,  eta_i_16 : f32,  eta_o_16 : f32,  random_state_16 : u32) -> SampleBSDF
{
    var _S834 : vec3<f32> = vec3<f32>(1.0f);
    var _S835 : SampleBSDF = SampleBSDF_x24init_0(_S834, _S834, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S835;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_16;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S836 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_9, alpha_15, material_20, lobes_11);
    sample_3.throughput = _S836;
    var _S837 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_5), n_i_dot_v_7, alpha_15, lobes_11, eta_i_16, eta_o_16);
    sample_3.pdf = _S837;
    return sample_3;
}

fn reflectSample( in_dir_11 : vec3<f32>,  ggx_n_6 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_21 : Material,  lobes_12 : BSDFLobes,  eta_i_17 : f32,  eta_o_17 : f32,  random_state_17 : u32) -> SampleBSDF
{
    var _S838 : vec3<f32> = vec3<f32>(1.0f);
    var _S839 : SampleBSDF = SampleBSDF_x24init_0(_S838, _S838, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S839;
    var _S840 : vec3<f32> = (normalize((reflect(in_dir_11, ggx_n_6))));
    sample_4.unit_direction = _S840;
    sample_4.random_state = random_state_17;
    sample_4.lobe = u32(2);
    var _S841 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_10, alpha_16, material_21, lobes_12);
    sample_4.throughput = _S841;
    var _S842 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_17, eta_o_17);
    sample_4.pdf = _S842;
    return sample_4;
}

fn sampleBSDF( in_dir_12 : vec3<f32>,  n_12 : vec3<f32>,  material_22 : Material,  eta_i_18 : f32,  eta_o_18 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_18 : u32 = random_init_0;
    var _S843 : vec3<f32> = ((-(in_dir_12)));
    var _S844 : f32 = dot(n_12, _S843);
    var _S845 : f32 = (sign((_S844)));
    var n_i_11 : vec3<f32> = n_12 * vec3<f32>(_S845);
    var _S846 : f32 = abs(_S844);
    var _S847 : f32 = material_22.roughness;
    var _S848 : f32 = _S847 * _S847;
    var _S849 : AnisotropicFrame = anisotropicFrame(material_22, n_i_11);
    var _S850 : vec3<f32> = sampleHalfVector(_S843, n_i_11, _S848, _S849, &(random_state_18));
    var _S851 : BSDFLobes = bsdfLobes(in_dir_12, _S843, n_i_11, _S850, material_22, eta_i_18, eta_o_18, _S849);
    var lobes_13 : BSDFLobes = _S851;
    var _S852 : f32 = translucentShare(material_22);
    lobes_13.translucent_share = _S852;
    var _S853 : Random = pcg(random_state_18);
    random_state_18 = _S853.state;
    var _S854 : bool = (_S853.value) < (lobes_13.p_sheen_velvet);
    if(_S854)
    {
        var _S855 : SampleBSDF = sheenVelvetSample(n_i_11, _S846, _S848, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
        return _S855;
    }
    var _S856 : f32 = _S853.value - lobes_13.p_sheen_velvet;
    var _S857 : bool = _S856 < (lobes_13.p_diffuse);
    if(_S857)
    {
        var _S858 : SampleBSDF = diffuseSample(_S856, n_i_11, _S846, _S848, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
        return _S858;
    }
    var _S859 : bool = _S856 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S859)
    {
        var _S860 : SampleBSDF = refractSample(_S850, n_i_11, _S846, _S848, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
        return _S860;
    }
    var _S861 : SampleBSDF = reflectSample(in_dir_12, _S850, n_i_11, _S846, _S848, material_22, lobes_13, eta_i_18, eta_o_18, random_state_18);
    return _S861;
}

fn withinInverseFootprint( pdf_9 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S862 : bool = pdf_9 > 0.0f;
    var _S863 : bool;
    if(_S862)
    {
        if(diffuse_0)
        {
            _S863 = true;
        }
        else
        {
            _S863 = (pdf_9 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S863 = false;
    }
    return _S863;
}

fn roughLobe( pdf_10 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S864 : bool = pdf_10 > 0.0f;
    var _S865 : bool;
    if(_S864)
    {
        if(diffuse_1)
        {
            _S865 = true;
        }
        else
        {
            _S865 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S865 = false;
    }
    return _S865;
}

fn survivalProbability( throughput_4 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S866 : vec3<f32> = throughput_4 / vec3<f32>(density_1);
    return clamp(max(_S866.x, max(_S866.y, _S866.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_6 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S867 : vec3<f32> = vec3<f32>(0.0f);
    var _S868 : Shift = Shift_x24init_0(_S867, 0.0f);
    var _S869 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S870 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S871 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S872 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S873 : bool = _S872 >= u32(3);
        var _S874 : u32 = select(u32(0), u32(1), _S873);
        var _S875 : u32 = _S869 + _S874;
        var _S876 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S875 > _S876;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S868;
    }
    var _S877 : u32 = _S870 - u32(1);
    var _S878 : bool = _S872 == u32(3);
    var _S879 : u32 = select(u32(0), u32(1), _S878);
    var _S880 : u32 = _S869 + _S879;
    var _S881 : bool = _S871 == u32(0);
    var _S882 : u32 = select(_S877, _S880, _S881);
    var _S883 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_6.rc.zw))), r_6.rc.x, r_6.rc.y, u32(0), 0.0f);
    var _S884 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S885 : Ray = Ray_x24init_0(dom_4.x1, _S884);
    var ray_2 : Ray = _S885;
    var hit_2 : Hit = dom_4.hit;
    var _S886 : vec3<f32> = vec3<f32>(1.0f);
    var _S887 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S867, _S867, _S867);
    var nee_vertex_0 : NEEVertex = _S887;
    var _S888 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S888;
    var _S889 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S867, 0.0f, vec4<u32>(u32(0)), _S867, _S867);
    var chain_0 : Reservoir = _S889;
    chain_0.seed = r_6.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S867;
    var reconnection_0 : vec3<f32> = _S867;
    var b_3 : u32 = u32(0);
    var throughput_5 : vec3<f32> = _S886;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S890 : bool = (hit_2.is_point_light) == u32(1);
        var _S891 : bool;
        if(replay_0)
        {
            _S891 = _S871 == u32(1);
        }
        else
        {
            _S891 = false;
        }
        var _S892 : bool;
        if(_S891)
        {
            _S892 = b_3 == _S870;
        }
        else
        {
            _S892 = false;
        }
        var _S893 : bool;
        if(_S892)
        {
            var _S894 : bool = (hit_2.instance_index) != (_S883.instance_index);
            if(_S894)
            {
                _S893 = true;
            }
            else
            {
                _S893 = (hit_2.triangle_index) != (_S883.triangle_index);
            }
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            return _S868;
        }
        var _S895 : Surface = Surface_x24init_0(_S867, _S867, 0.0f, Material_x24init_0(_S867, _S867, 0.0f, 0.0f, 0.0f, 0.0f, _S867, _S886, 1.0f, _S867, _S867, 0.5f, 0.0f, 0.0f, _S867), false, u32(0));
        var _S896 : bool = !_S890;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_6 : vec3<f32>;
        var surface_4 : Surface;
        if(_S896)
        {
            var _S897 : u32 = stream(r_6.seed, b_3);
            var _S898 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S897)));
            var surface_5 : Surface = facingRay_0(_S898, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S899 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S900 : vec3<f32> = throughput_5 * _S899;
                front_n_0 = _S900;
            }
            else
            {
                front_n_0 = throughput_5;
            }
            var _S901 : bool = !surface_5.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_5.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S902 : bool = b_3 == u32(0);
            if(_S902)
            {
                var _S903 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S903;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S904 : vec3<f32> = front_n_0;
            var _S905 : f32 = geometry_density_2;
            scatter_0 = _S901;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S905;
            surface_4 = surface_5;
            front_n_0 = _S898.smooth_n;
            throughput_6 = _S904;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_4 = _S895;
            front_n_0 = _S867;
            throughput_6 = throughput_5;
        }
        var _S906 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S907 : Surface = surface_4;
        var _S908 : Surface = surface_4;
        var _S909 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S910 : vec2<f32> = vertexEta(_S907.material, _S909);
        var _S911 : bool;
        if(scatter_0)
        {
            var _S912 : bool = neeDecision(_S907.material, _S909, _S910.x, _S910.y);
            _S911 = _S912;
        }
        else
        {
            _S911 = false;
        }
        var _S913 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S914 : vec3<f32> = _S907.material.emissive * vec3<f32>(max(_S913, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S890)
        {
            var _S915 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S915;
        }
        else
        {
            emission_0 = _S914;
        }
        var _S916 : bool = !replay_0;
        var _S917 : bool;
        if(_S916)
        {
            _S917 = true;
        }
        else
        {
            _S917 = b_3 >= _S882;
        }
        var _S918 : bool;
        if(_S917)
        {
            var _S919 : f32 = rgb_to_greyscale(emission_0);
            _S918 = _S919 > 0.0f;
        }
        else
        {
            _S918 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S918)
        {
            var _S920 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S920);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S921 : bool;
        if(replay_0)
        {
            _S921 = _S871 == u32(1);
        }
        else
        {
            _S921 = false;
        }
        var _S922 : bool;
        if(_S921)
        {
            _S922 = b_3 > _S870;
        }
        else
        {
            _S922 = false;
        }
        var _S923 : bool;
        if(_S922)
        {
            _S923 = b_3 == _S869;
        }
        else
        {
            _S923 = false;
        }
        var _S924 : bool;
        if(_S923)
        {
            var _S925 : bool = _S872 == u32(1);
            if(_S925)
            {
                _S924 = true;
            }
            else
            {
                _S924 = _S872 == u32(2);
            }
        }
        else
        {
            _S924 = false;
        }
        if(_S924)
        {
            var _S926 : bool = _S890 != (_S872 == u32(2));
            if(_S926)
            {
                return _S868;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / vec3<f32>(r_6.jac), density_2 / r_6.jac);
        }
        var _S927 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S928 : bool = _S927 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S929 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S930 : u32 = (insertBits((_S929), (u32(1)), (u32(10)), (u32(2))));
        var _S931 : u32 = (insertBits((_S930), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S932 : bool = prev_0.inside;
        var _S933 : u32 = select(u32(0), u32(1), _S932);
        var _S934 : u32 = (insertBits((_S931), (_S933), (u32(22)), (u32(1))));
        here_0.path = _S934;
        var _S935 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S935;
        var _S936 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S936;
        var _S937 : bool;
        if(replay_0)
        {
            _S937 = _S871 == u32(1);
        }
        else
        {
            _S937 = false;
        }
        var _S938 : bool;
        if(_S937)
        {
            _S938 = b_3 == _S870;
        }
        else
        {
            _S938 = false;
        }
        var _S939 : bool = b_3 == _S882;
        var _S940 : bool;
        if(_S939)
        {
            var _S941 : bool = !scatter_0;
            if(_S941)
            {
                _S940 = true;
            }
            else
            {
                var _S942 : bool = _S871 != u32(1);
                if(_S942)
                {
                    _S940 = _S871 != u32(3);
                }
                else
                {
                    _S940 = false;
                }
            }
        }
        else
        {
            _S940 = false;
        }
        var _S943 : bool;
        if(_S940)
        {
            _S943 = _S871 == u32(2);
        }
        else
        {
            _S943 = false;
        }
        var _S944 : bool;
        if(_S943)
        {
            _S944 = !_S906;
        }
        else
        {
            _S944 = false;
        }
        var _S945 : bool;
        if(_S944)
        {
            _S945 = _S872 != u32(4);
        }
        else
        {
            _S945 = false;
        }
        var _S946 : bool = _S870 == _S869;
        var _S947 : bool;
        if(_S946)
        {
            _S947 = _S872 == u32(0);
        }
        else
        {
            _S947 = false;
        }
        var _S948 : bool;
        if(_S947)
        {
            _S948 = (hit_2.instance_index) == (_S883.instance_index);
        }
        else
        {
            _S948 = false;
        }
        var _S949 : bool;
        if(_S948)
        {
            _S949 = (hit_2.triangle_index) == (_S883.triangle_index);
        }
        else
        {
            _S949 = false;
        }
        var _S950 : bool;
        if(_S949)
        {
            _S950 = _S906;
        }
        else
        {
            _S950 = false;
        }
        var _S951 : bool = select(_S945, _S950, _S938);
        var _S952 : bool;
        if(_S911)
        {
            _S952 = select(scatter_0, _S951, replay_0);
        }
        else
        {
            _S952 = false;
        }
        var _S953 : TreeSample = TreeSample_x24init_0(_S867, _S867, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S952)
        {
            var _S954 : Surface = surface_4;
            var _S955 : bool = isTranslucent_0(_S907.material);
            var _S956 : u32 = stream(r_6.seed, b_3 + u32(64));
            var _S957 : TreeSample = sampleLightTree_0(ray_2.origin, _S908.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S955, _S956);
            var _S958 : bool = (any(((_S957.radiance) != _S867)));
            if(_S958)
            {
                var _S959 : f32 = _S910.x;
                var _S960 : f32 = _S910.y;
                var _S961 : u32 = (uniforms_uint.max_bounces);
                var _S962 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S957, _S908.smooth_n, _S954.geometry_n, _S907.material, _S959, _S960, b_3 < _S961, surface_4.random_state);
                lit_0 = _S962;
            }
            else
            {
                lit_0 = _S867;
            }
            light_1 = _S957;
        }
        else
        {
            light_1 = _S953;
            lit_0 = _S867;
        }
        var _S963 : bool;
        var wrong_side_0 : bool;
        var refracted_5 : bool;
        var _S964 : bool;
        var _S965 : bool;
        var density_3 : f32;
        var throughput_7 : vec3<f32>;
        if(_S938)
        {
            var _S966 : bool = !_S906;
            if(_S966)
            {
                return _S868;
            }
            var throughput_8 : vec3<f32> = throughput_6 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S946)
            {
                _S963 = _S872 == u32(1);
            }
            else
            {
                _S963 = false;
            }
            if(_S963)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S946)
            {
                wrong_side_0 = _S872 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S967 : bool = !_S911;
                if(_S967)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S968 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S968 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S868;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S946)
            {
                refracted_5 = _S872 == u32(4);
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                var _S969 : bool = !_S911;
                if(_S969)
                {
                    return _S868;
                }
                var _S970 : f32 = environmentPdf_0(r_6.dir);
                var _S971 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_6.dir, surface_4, _S910, is_inside_4, _S970, surface_4.random_state);
                return Shift_x24init_0(throughput_8 * _S971 * r_6.radiance / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            var _S972 : u32 = (extractBits((r_6.path), (u32(21)), (u32(1))));
            var _S973 : bool = _S911 != (_S972 == u32(1));
            if(_S973)
            {
                return _S868;
            }
            throughput_7 = throughput_8;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S963 = _S939;
            }
            else
            {
                _S963 = false;
            }
            if(_S963)
            {
                var _S974 : bool = !scatter_0;
                if(_S974)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S975 : bool = _S871 != u32(1);
                    if(_S975)
                    {
                        wrong_side_0 = _S871 != u32(3);
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
                var _S976 : bool = _S871 == u32(2);
                if(_S976)
                {
                    _S891 = _S911;
                }
                else
                {
                    _S891 = false;
                }
                if(_S891)
                {
                    _S891 = !_S906;
                }
                else
                {
                    _S891 = false;
                }
                if(_S891)
                {
                    _S891 = _S872 == u32(4);
                }
                else
                {
                    _S891 = false;
                }
                if(_S891)
                {
                    var _S977 : u32 = stream(r_6.seed, b_3 + u32(256));
                    var _S978 : SkySample = sampleSky_0(ray_2, surface_4, _S910, is_inside_4, _S977, surface_4.random_state);
                    return Shift_x24init_0(throughput_6 * _S978.color, 1.0f);
                }
                if(_S976)
                {
                    is_inside_4 = _S911;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S906;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S979 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S980 : bool = !(_S979 > 0.0f);
                    if(_S980)
                    {
                        return _S868;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S881)
                {
                    is_inside_4 = _S872 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S890;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S881)
                {
                    is_inside_4 = _S872 == u32(1);
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
                    is_inside_4 = !_S906;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S868;
            }
            else
            {
                if(_S916)
                {
                    refracted_5 = scatter_0;
                }
                else
                {
                    refracted_5 = false;
                }
                if(refracted_5)
                {
                    var _S981 : bool = b_3 > u32(0);
                    if(_S981)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S928)
                        {
                            var _S982 : vec3<f32> = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S982;
                        }
                        else
                        {
                            if(_S906)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S983 : vec3<f32> = throughput_6 * emission_1;
                        var _S984 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S983);
                        offer(&((*sel_4)), _S984, _S983 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S911)
                    {
                        var _S985 : vec3<f32> = throughput_6 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S928)
                        {
                            var _S986 : vec3<f32> = safeDivide(_S985, chain_throughput_0);
                            candidate_4.radiance = _S986;
                        }
                        else
                        {
                            if(_S906)
                            {
                                candidate_4 = here_0;
                                var _S987 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S987;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S988 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S989 : u32 = (insertBits((_S988), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S989;
                            }
                        }
                        var _S990 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S985);
                        offer(&((*sel_4)), _S990, _S985 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S911)
                    {
                        var _S991 : bool = environmentMapped_0();
                        _S964 = _S991;
                    }
                    else
                    {
                        _S964 = false;
                    }
                    if(_S964)
                    {
                        var _S992 : u32 = (uniforms_uint.max_bounces);
                        _S965 = b_3 < _S992;
                    }
                    else
                    {
                        _S965 = false;
                    }
                    if(_S965)
                    {
                        var _S993 : u32 = stream(r_6.seed, b_3 + u32(256));
                        var _S994 : SkySample = sampleSky_0(ray_2, surface_4, _S910, is_inside_4, _S993, surface_4.random_state);
                        var _S995 : vec3<f32> = throughput_6 * _S994.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S928)
                        {
                            var _S996 : vec3<f32> = safeDivide(_S995, chain_throughput_0);
                            candidate_5.radiance = _S996;
                        }
                        else
                        {
                            if(_S906)
                            {
                                candidate_5 = here_0;
                                var _S997 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S997;
                                candidate_5.dir = _S994.dir;
                                candidate_5.radiance = _S994.radiance;
                            }
                            else
                            {
                                var _S998 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S999 : u32 = (insertBits((_S998), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S999;
                            }
                        }
                        var _S1000 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S995);
                        offer(&((*sel_4)), _S1000, _S995 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_3 = density_2;
        }
        var _S1001 : bool;
        var _S1002 : bool;
        var _S1003 : bool;
        var _S1004 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S963 = _S939;
            }
            else
            {
                _S963 = false;
            }
            var _S1005 : u32 = (extractBits((r_6.path), (u32(15)), (u32(3))));
            var _S1006 : u32 = (extractBits((r_6.path), (u32(18)), (u32(3))));
            var _S1007 : u32 = select(_S1005, _S1006, _S938);
            var refracted_6 : bool = _S1007 == u32(1);
            var _S1008 : SampleBSDF = SampleBSDF_x24init_0(_S867, _S867, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S1008;
            var dir_12 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S963)
            {
                var _S1009 : u32 = (extractBits((r_6.path), (u32(22)), (u32(1))));
                var _S1010 : bool = is_inside_4 != (_S1009 == u32(1));
                if(_S1010)
                {
                    return _S868;
                }
                var _S1011 : bool = _S871 == u32(1);
                if(_S1011)
                {
                    var _S1012 : vec3<f32> = (hitPosition((_S883)));
                    dir_12 = _S1012;
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
                    var _S1013 : bool = isTranslucent_0(_S907.material);
                    if(_S1013)
                    {
                        wrong_side_0 = _S1007 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1014 : vec3<f32> = dir_12 - ray_2.origin;
                        var _S1015 : vec3<f32> = select(r_6.dir, _S1014, _S1011);
                        refracted_5 = (dot(_S908.smooth_n, _S1015) * _S909) < 0.0f;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                }
                if(_S1011)
                {
                    var _S1016 : vec3<f32> = ray_2.origin;
                    var _S1017 : Surface = surface_4;
                    var _S1018 : vec3<f32> = (vec3<f32>(0) - _S908.smooth_n);
                    var _S1019 : bool = is_inside_4 != refracted_5;
                    var _S1020 : vec3<f32> = select(_S908.smooth_n, _S1018, _S1019);
                    var _S1021 : vec3<f32> = (normalize((dir_12 - (_S1016 + vec3<f32>(_S1017.geometry_offset) * _S1020))));
                    reconnection_1 = _S1021;
                }
                else
                {
                    reconnection_1 = r_6.dir;
                }
                var _S1022 : bool = wrongSide_0(is_inside_4, refracted_5, reconnection_1, surface_4.geometry_n);
                if(_S1022)
                {
                    return _S868;
                }
                var _S1023 : vec3<f32> = dir_12;
                dir_12 = reconnection_1;
                lobe_index_0 = _S1007;
                wrong_side_0 = false;
                reconnection_1 = _S1023;
            }
            else
            {
                var _S1024 : bool = !_S938;
                if(_S1024)
                {
                    var _S1025 : f32 = _S910.x;
                    var _S1026 : f32 = _S910.y;
                    var _S1027 : vec2<f32> = vec2<f32>(0.0f);
                    var _S1028 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S908.smooth_n, _S907.material, _S1025, _S1026, surface_4.random_state, _S1027);
                    var bsdf_sampled_0 : SampleBSDF = _S1028;
                    var _S1029 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S907.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S1030 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S1029.geometry_n, _S907.material, _S1025, _S1026, bsdf_sampled_0.random_state, _S1027);
                        bsdf_sampled_0.unit_direction = _S1030.unit_direction;
                        bsdf_sampled_0.refracted = _S1030.refracted;
                        bsdf_sampled_0.throughput = _S1030.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S1031 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S1029.geometry_n))) * _S1029.geometry_n;
                            bsdf_sampled_0.unit_direction = _S1031;
                        }
                    }
                    var _S1032 : u32 = bsdf_sampled_0.lobe;
                    var _S1033 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S1034 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S1035 : f32 = bsdf_sampled_0.pdf;
                    var _S1036 : f32 = select(_S1035, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S1036;
                    dir_12 = _S1033;
                    lobe_index_0 = _S1032;
                    wrong_side_0 = wrong_side_1;
                    refracted_5 = _S1034;
                }
                else
                {
                    dir_12 = r_6.dir;
                    lobe_index_0 = _S1007;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S963)
            {
                _S964 = true;
            }
            else
            {
                _S964 = _S938;
            }
            var throughput_9 : vec3<f32>;
            var throughput_10 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S964)
            {
                var _S1037 : vec3<f32> = ray_2.unit_direction;
                var _S1038 : f32 = (sign((_S909)));
                var _S1039 : vec3<f32> = _S908.smooth_n * vec3<f32>(_S1038);
                var _S1040 : f32 = dot(_S1039, dir_12);
                var _S1041 : f32 = _S907.material.roughness;
                var _S1042 : f32 = _S1041 * _S1041;
                var _S1043 : AnisotropicFrame = anisotropicFrame(_S907.material, _S1039);
                var _S1044 : vec3<f32> = reflectedHalf(_S1037, dir_12);
                var _S1045 : bool = lobe_index_0 == u32(1);
                if(_S1045)
                {
                    var _S1046 : vec3<f32> = refractedHalf(_S1037, dir_12, _S908.smooth_n, _S910.x, _S910.y);
                    throughput_9 = _S1046;
                }
                else
                {
                    throughput_9 = _S1044;
                }
                var _S1047 : bool = lobe_index_0 == u32(0);
                if(_S1047)
                {
                    var _S1048 : vec3<f32> = sampledHalf(_S1037, _S908.smooth_n, _S907.material, surface_4.random_state, _S1043);
                    throughput_10 = _S1048;
                }
                else
                {
                    throughput_10 = throughput_9;
                }
                var _S1049 : vec3<f32> = ((-(_S1037)));
                var _S1050 : f32 = _S910.x;
                var _S1051 : f32 = _S910.y;
                var _S1052 : BSDFLobes = bsdfLobes(_S1037, _S1049, _S1039, throughput_10, _S907.material, _S1050, _S1051, _S1043);
                var lobe_terms_2 : BSDFLobes = _S1052;
                var _S1053 : f32 = translucentShare(_S907.material);
                lobe_terms_2.translucent_share = _S1053;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S1054 : f32 = diffusePDF(_S1040, 0.0f, abs(_S909), _S1042, lobe_terms_2, _S1050, _S1051);
                        var _S1055 : vec3<f32> = diffuseBSDF(dir_12, _S1039, _S1042, _S907.material, lobe_terms_2);
                        density_5 = _S1054;
                        chain_throughput_1 = _S1055;
                    }
                case u32(1):
                    {
                        var _S1056 : f32 = refractPDF(_S1040, dot(dir_12, throughput_10), abs(_S909), _S1042, lobe_terms_2, _S1050, _S1051);
                        var _S1057 : vec3<f32> = refractBSDF(dir_12, _S1039, _S1042, _S907.material, lobe_terms_2);
                        density_5 = _S1056;
                        chain_throughput_1 = _S1057;
                    }
                case u32(4):
                    {
                        var _S1058 : f32 = sheenVelvetPDF(_S1040, 0.0f, abs(_S909), _S1042, lobe_terms_2, _S1050, _S1051);
                        var _S1059 : vec3<f32> = sheenVelvetBSDF(dir_12, _S1039, _S1042, _S907.material, lobe_terms_2);
                        density_5 = _S1058;
                        chain_throughput_1 = _S1059;
                    }
                default :
                    {
                        var _S1060 : f32 = reflectPDF(_S1040, 0.0f, abs(_S909), _S1042, lobe_terms_2, _S1050, _S1051);
                        var _S1061 : vec3<f32> = reflectBSDF(dir_12, _S1039, _S1042, _S907.material, lobe_terms_2);
                        density_5 = _S1060;
                        chain_throughput_1 = _S1061;
                    }
                }
                var _S1062 : bool = density_5 > 0.0f;
                if(_S1062)
                {
                    var _S1063 : SampleBSDF = SampleBSDF_x24init_0(dir_12, chain_throughput_1, surface_4.random_state, _S1045, lobe_index_0, density_5);
                    lobe_2 = _S1063;
                }
            }
            var _S1064 : bool = lobe_index_0 == u32(0);
            if(_S1064)
            {
                _S965 = true;
            }
            else
            {
                _S965 = lobe_index_0 == u32(4);
            }
            var _S1065 : bool = !_S965;
            if(_S1065)
            {
                var _S1066 : bool = (_S907.material.roughness) == 0.0f;
                if(_S1066)
                {
                    _S1001 = true;
                }
                else
                {
                    var _S1067 : bool = lobe_index_0 == u32(1);
                    if(_S1067)
                    {
                        _S1001 = (_S910.x) == (_S910.y);
                    }
                    else
                    {
                        _S1001 = false;
                    }
                }
            }
            else
            {
                _S1001 = false;
            }
            var _S1068 : bool = isTranslucent_0(_S907.material);
            if(_S1068)
            {
                _S1002 = _S1064;
            }
            else
            {
                _S1002 = false;
            }
            if(_S1002)
            {
                _S1003 = (dot(dir_12, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S1003 = false;
            }
            if(_S911)
            {
                _S1004 = !_S1001;
            }
            else
            {
                _S1004 = false;
            }
            var _S1069 : bool;
            if(_S1004)
            {
                _S1069 = !wrong_side_0;
            }
            else
            {
                _S1069 = false;
            }
            var _S1070 : bool;
            if(_S1069)
            {
                var _S1071 : f32 = lobe_2.pdf;
                var _S1072 : vec3<f32> = ray_2.origin;
                var _S1073 : bool = isTranslucent_0(_S907.material);
                var _S1074 : vec3<f32> = select(_S908.smooth_n, _S867, _S1073);
                var _S1075 : vec3<f32> = ray_2.origin;
                var _S1076 : Surface = surface_4;
                var _S1077 : vec3<f32> = (vec3<f32>(0) - _S908.smooth_n);
                var _S1078 : vec3<f32> = select(_S908.smooth_n, _S1077, _S1003);
                var _S1079 : NEEVertex = NEEVertex_x24init_0(false, _S1071, _S1072, _S1074, _S1075 + vec3<f32>(_S1076.geometry_offset) * _S1078);
                nee_vertex_0 = _S1079;
            }
            else
            {
                var _S1080 : bool = lobe_index_0 != u32(1);
                if(_S1080)
                {
                    _S1070 = true;
                }
                else
                {
                    _S1070 = (_S910.x) != (_S910.y);
                }
                if(_S1070)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S1081 : bool = withinInverseFootprint(lobe_2.pdf, _S965, prev_0.cos, hit_2.distance, threshold_2);
            var _S1082 : bool = roughLobe(lobe_2.pdf, _S965, _S907.material.roughness);
            if(_S938)
            {
                var _S1083 : bool = !_S1081;
                if(_S1083)
                {
                    return _S868;
                }
                var _S1084 : bool = _S872 != u32(1);
                if(_S1084)
                {
                    _S1070 = _S872 != u32(2);
                }
                else
                {
                    _S1070 = false;
                }
                if(_S1070)
                {
                    var _S1085 : f32 = lobe_2.pdf;
                    var _S1086 : f32 = select(0.0f, _S1085, _S911);
                    var _S1087 : f32 = escapeWeight_0(_S1086, r_6.dir);
                    if(_S946)
                    {
                        is_inside_4 = _S878;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S1088 : f32 = select(1.0f, _S1087, is_inside_4);
                    return Shift_x24init_0(throughput_7 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_6.radiance * vec3<f32>(_S1088) / vec3<f32>(r_6.jac), density_3 * lobe_2.pdf / r_6.jac);
                }
                var _S1089 : vec3<f32> = throughput_7 * vec3<f32>(lobe_2.pdf);
                var _S1090 : f32 = density_3 * lobe_2.pdf;
                throughput_9 = _S1089;
                density_5 = _S1090;
            }
            else
            {
                throughput_9 = throughput_7;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S1070 = b_3 <= _S882;
            }
            else
            {
                _S1070 = false;
            }
            var _S1091 : bool;
            if(_S1070)
            {
                _S1091 = _S906;
            }
            else
            {
                _S1091 = false;
            }
            var _S1092 : bool;
            if(_S1091)
            {
                _S1092 = _S1081;
            }
            else
            {
                _S1092 = false;
            }
            var _S1093 : bool;
            if(_S1092)
            {
                _S1093 = true;
            }
            else
            {
                if(_S963)
                {
                    _S1093 = !_S1082;
                }
                else
                {
                    _S1093 = false;
                }
            }
            if(_S1093)
            {
                return _S868;
            }
            if(_S963)
            {
                var _S1094 : vec3<f32> = throughput_9 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1095 : f32 = lobe_2.pdf;
                throughput_10 = _S1094;
                survival_probability_0 = _S1095;
            }
            else
            {
                var _S1096 : vec3<f32> = throughput_9 * max(lobe_2.throughput, _S867);
                throughput_10 = _S1096;
                survival_probability_0 = density_5;
            }
            var _S1097 : bool;
            if(_S916)
            {
                _S1097 = !_S928;
            }
            else
            {
                _S1097 = false;
            }
            var _S1098 : bool;
            if(_S1097)
            {
                _S1098 = _S906;
            }
            else
            {
                _S1098 = false;
            }
            var _S1099 : bool;
            if(_S1098)
            {
                _S1099 = _S1081;
            }
            else
            {
                _S1099 = false;
            }
            if(_S1099)
            {
                chain_0 = here_0;
                var _S1100 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1101 : u32 = select(u32(0), u32(1), _S911);
                var _S1102 : u32 = (insertBits((_S1100), (_S1101), (u32(21)), (u32(1))));
                chain_0.path = _S1102;
                var _S1103 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S1103;
                chain_0.dir = dir_12;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1104 : Vertex = Vertex_x24init_0(_S1082, lobe_index_0, lobe_2.pdf, abs(dot(surface_4.geometry_n, dir_12)), is_inside_4);
            prev_0 = _S1104;
            var _S1105 : f32 = lobe_2.pdf;
            var _S1106 : bool = lobe_index_0 == u32(1);
            var _S1107 : bool;
            if(_S1106)
            {
                _S1107 = (_S910.x) == (_S910.y);
            }
            else
            {
                _S1107 = false;
            }
            var _S1108 : f32 = select(_S1105, sky_pdf_0, _S1107);
            var _S1109 : bool;
            if(refracted_5)
            {
                _S1109 = !_S1003;
            }
            else
            {
                _S1109 = false;
            }
            var is_inside_5 : bool;
            if(_S1109)
            {
                var _S1110 : bool = !is_inside_4;
                is_inside_5 = _S1110;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_12;
            var _S1111 : Surface = surface_4;
            var _S1112 : vec3<f32> = (vec3<f32>(0) - _S908.smooth_n);
            var _S1113 : bool = is_inside_5 != _S1003;
            var _S1114 : vec3<f32> = select(_S908.smooth_n, _S1112, _S1113);
            var _S1115 : vec3<f32> = ray_2.origin + vec3<f32>(_S1111.geometry_offset) * _S1114;
            ray_2.origin = _S1115;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_5 = throughput_10;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1108;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_5 = throughput_7;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S916)
        {
            if(_S890)
            {
                var _S1116 : vec3<f32> = throughput_5 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1117 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1118 : bool = _S1117 == u32(1);
                if(_S1118)
                {
                    var _S1119 : vec3<f32> = safeDivide(_S1116, chain_throughput_0);
                    candidate_6.radiance = _S1119;
                }
                var _S1120 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1116);
                offer(&((*sel_4)), _S1120, _S1116 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S890)
            {
                _S963 = true;
            }
            else
            {
                _S963 = scatter_0;
            }
            if(_S963)
            {
                var _S1121 : f32 = survivalProbability(throughput_5, density_5);
                survival_probability_0 = _S1121;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1122 : u32 = stream(r_6.seed, b_3 + u32(128));
            var _S1123 : Random = pcg(_S1122);
            var _S1124 : bool = survival_probability_0 < (_S1123.value);
            if(_S1124)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1125 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1125;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1126 : f32 = density_5 * survival_probability_0;
            density_2 = _S1126;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1127 : Ray = ray_2;
        var _S1128 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S963 = _S939;
        }
        else
        {
            _S963 = false;
        }
        if(_S963)
        {
            wrong_side_0 = _S871 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1129 : f32 = select(4.294967296e+09f, _S1128, wrong_side_0);
        var _S1130 : Hit = (traverseInstanceBVH((_S1127), (_S896), (_S1129)));
        hit_2 = _S1130;
        if(replay_0)
        {
            refracted_5 = _S939;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            _S964 = _S871 == u32(1);
        }
        else
        {
            _S964 = false;
        }
        if(_S964)
        {
            _S965 = (hit_2.instance_index) == (_S883.instance_index);
        }
        else
        {
            _S965 = false;
        }
        if(_S965)
        {
            _S1001 = (hit_2.triangle_index) == (_S883.triangle_index);
        }
        else
        {
            _S1001 = false;
        }
        if(_S1001)
        {
            hit_2.uv = _S883.uv;
            var _S1131 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1131;
        }
        if(replay_0)
        {
            _S1002 = _S939;
        }
        else
        {
            _S1002 = false;
        }
        if(_S1002)
        {
            _S1003 = _S871 == u32(3);
        }
        else
        {
            _S1003 = false;
        }
        if(_S1003)
        {
            _S1004 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S1004 = false;
        }
        if(_S1004)
        {
            return _S868;
        }
        var _S1132 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1132)
        {
            var _S1133 : bool = !nee_vertex_0.none;
            var _S1134 : f32 = select(0.0f, sky_pdf_0, _S1133);
            var _S1135 : f32 = escapeWeight_0(_S1134, ray_2.unit_direction);
            var _S1136 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1137 : vec3<f32> = throughput_5 * _S1136;
            if(replay_0)
            {
                if(_S939)
                {
                    is_inside_4 = _S871 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1137 * vec3<f32>(_S1135) / vec3<f32>(r_6.jac), density_2 / r_6.jac);
                }
                if(_S881)
                {
                    is_inside_4 = _S878;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_3 == _S869;
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
                    return Shift_x24init_0(_S1137 * vec3<f32>(_S1135), 1.0f);
                }
                return _S868;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1138 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1139 : bool = _S1138 == u32(1);
            if(_S1139)
            {
                var _S1140 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1141 : bool = _S1140 == b_3;
                var _S1142 : f32 = select(_S1135, 1.0f, _S1141);
                var _S1143 : vec3<f32> = safeDivide(_S1137 * vec3<f32>(_S1142), chain_throughput_0);
                candidate_7.radiance = _S1143;
            }
            else
            {
                var _S1144 : bool = prev_0.rough;
                if(_S1144)
                {
                    var _S1145 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                    var _S1146 : u32 = (insertBits((_S1145), (u32(3)), (u32(10)), (u32(2))));
                    var _S1147 : u32 = (insertBits((_S1146), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1148 : bool = prev_0.inside;
                    var _S1149 : u32 = select(u32(0), u32(1), _S1148);
                    var _S1150 : u32 = (insertBits((_S1147), (_S1149), (u32(22)), (u32(1))));
                    candidate_7.path = _S1150;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1151 : vec3<f32> = _S1137 * vec3<f32>(_S1135);
            var _S1152 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1151);
            offer(&((*sel_4)), _S1152, _S1151 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1153 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1153;
        var _S1154 : u32 = b_3 + u32(1);
        b_3 = _S1154;
    }
    return _S868;
}

fn shift_0( dom_5 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S1155 : vec3<f32> = vec3<f32>(0.0f);
    var _S1156 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1155, 0.0f, vec4<u32>(u32(0)), _S1155, _S1155), 0.0f, _S1155, u32(0));
    var sel_5 : Selection = _S1156;
    var _S1157 : bool = (r_7.w) <= 0.0f;
    if(_S1157)
    {
        return Shift_x24init_0(_S1155, 0.0f);
    }
    var _S1158 : Shift = walk_0(dom_5, r_7, true, 0.0f, &(sel_5));
    return _S1158;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1159 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1160 : bool = _S1159 != u32(4294967295);
    if(_S1160)
    {
        var _S1161 : vec2<i32> = vec2<i32>((vec2<u32>(_S1159, (_S1159 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1162 : vec3<f32> = vec3<f32>(0.0f);
        var _S1163 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1162, _S1162, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1162, 0.0f, vec4<u32>(u32(0)), _S1162, _S1162));
        var shift_job_0 : ShiftJob = _S1163;
        var _S1164 : u32 = (_S1159 >> (u32(28)));
        var _S1165 : bool = spatialJob_0(_S1161, _S1164, &(shift_job_0));
        var _S1166 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1161), (_S1164), (vec4<u32>((bitcast<vec3<u32>>((_S1166.f))), (bitcast<u32>((_S1166.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1167 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1168 : array<u32, i32(3)>;
    spatialBins_0(_S1167, &(_S1168));
    var _S1169 : array<u32, i32(3)> = _S1168;
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
        var _S1170 : bool = (_S1169[t_16]) == u32(40);
        if(_S1170)
        {
            textureStore(shift_data_out, (_S1167), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1167, _S1169, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1171 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1171));
    countShifts_0(_S1171, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1172 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1173 : bool = _S1172 != u32(4294967295);
    if(_S1173)
    {
        var _S1174 : vec2<i32> = vec2<i32>((vec2<u32>(_S1172, (_S1172 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1175 : vec3<f32> = vec3<f32>(0.0f);
        var _S1176 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1175, _S1175, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1175, 0.0f, vec4<u32>(u32(0)), _S1175, _S1175));
        var shift_job_1 : ShiftJob = _S1176;
        var _S1177 : u32 = (_S1172 >> (u32(28)));
        var _S1178 : bool = temporalJob_0(_S1174, _S1177, &(shift_job_1));
        var _S1179 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1174), (_S1177), (vec4<u32>((bitcast<vec3<u32>>((_S1179.f))), (bitcast<u32>((_S1179.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1180 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1181 : array<u32, i32(3)>;
    temporalBins_0(_S1180, &(_S1181));
    var _S1182 : array<u32, i32(3)> = _S1181;
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
        var _S1183 : bool = (_S1182[t_18]) == u32(40);
        if(_S1183)
        {
            textureStore(temporal_shifts_out, (_S1180), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1180, _S1182, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1184 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1184));
    countShifts_0(_S1184, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1185 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1185;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1186 : f32 = c_3 * p_c_1;
    var _S1187 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1186 / (_S1186 + c_t_0 * g_previous_0), _S1187 / (_S1187 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1188 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1189 : vec3<f32> = vec3<f32>(0.0f);
    var _S1190 : Domain = Domain_x24init_0(_S1189, _S1189, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1190;
    var _S1191 : bool = (currentDomain((_S1188), &(dom_6)));
    var _S1192 : bool = !_S1191;
    if(_S1192)
    {
        storeReservoir(reservoir_temp_out, (_S1188), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1189, 0.0f, vec4<u32>(u32(0)), _S1189, _S1189)), (dom_6.hit));
        return;
    }
    var _S1193 : Reservoir = (loadReservoir(reservoir_initial, (_S1188)));
    var _S1194 : vec2<i32> = temporalNeighbor_0(_S1188, dom_6);
    var _S1195 : bool = (_S1194.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1195)
    {
        var _S1196 : Reservoir = (loadReservoir(reservoir_prev, (_S1194)));
        var _S1197 : vec4<u32> = (textureLoad(duplication, (_S1194), 0, 0));
        var _S1198 : f32 = (bitcast<f32>((_S1197.x)));
        var _S1199 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1200 : bool = _S1199 == u32(1);
        var _S1201 : f32 = select(0.0f, _S1198, _S1200);
        var _S1202 : f32 = confidenceCap(_S1201);
        var _S1203 : f32 = min(_S1196.c, _S1202);
        var _S1204 : vec4<u32> = (textureLoad(temporal_shifts, (_S1188), (u32(0)), 0));
        var _S1205 : vec4<f32> = (bitcast<vec4<f32>>((_S1204)));
        var _S1206 : vec4<f32> = vec4<f32>(_S1193.f, 1.0f);
        var _S1207 : Domain = (previousDomain((_S1194)));
        var _S1208 : bool = sameDomain_0(_S1207, dom_6);
        var _S1209 : bool = !_S1208;
        var to_previous_0 : vec4<f32>;
        if(_S1209)
        {
            var _S1210 : vec4<u32> = (textureLoad(temporal_shifts, (_S1188), (u32(1)), 0));
            var _S1211 : vec4<f32> = (bitcast<vec4<f32>>((_S1210)));
            to_previous_0 = _S1211;
        }
        else
        {
            to_previous_0 = _S1206;
        }
        var _S1212 : f32 = rgb_to_greyscale(_S1193.f);
        var _S1213 : f32 = rgb_to_greyscale(_S1196.f);
        var _S1214 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1189, 0.0f, vec4<u32>(u32(0)), _S1189, _S1189), 0.0f, _S1189, u32(0));
        var sel_6 : Selection = _S1214;
        var _S1215 : u32 = (uniforms_uint.frame);
        var _S1216 : u32 = hash(_S1215);
        var _S1217 : u32 = global_invocation_id_7.x;
        var _S1218 : vec2<u32> = (uniforms_uint.render_size);
        var _S1219 : u32 = stream(_S1216, _S1217 + _S1218.x * global_invocation_id_7.y);
        var _S1220 : u32 = stream(_S1219, u32(194));
        sel_6.random_state = _S1220;
        var _S1221 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1222 : vec3<f32> = _S1205.xyz;
        var _S1223 : f32 = rgb_to_greyscale(_S1222);
        var _S1224 : vec2<f32> = temporalWeights(_S1193.c, _S1212, _S1203, _S1213, _S1221, _S1223);
        offerShifted(&(sel_6), _S1193, Shift_x24init_0(_S1193.f, 1.0f), _S1224.x);
        offerShifted(&(sel_6), _S1196, Shift_x24init_0(_S1222, _S1205.w), _S1224.y);
        var _S1225 : Reservoir = finalize(sel_6, _S1193.c + _S1203);
        r_8 = _S1225;
    }
    else
    {
        r_8 = _S1193;
    }
    storeReservoir(reservoir_temp_out, (_S1188), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1226 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1227 : vec3<f32> = vec3<f32>(0.0f);
    var _S1228 : Domain = Domain_x24init_0(_S1227, _S1227, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1228;
    var _S1229 : bool = (currentDomain((_S1226), &(dom_7)));
    var _S1230 : bool = !_S1229;
    if(_S1230)
    {
        storeReservoir(reservoir_initial_out, (_S1226), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1227, 0.0f, vec4<u32>(u32(0)), _S1227, _S1227)), (dom_7.hit));
        return;
    }
    var _S1231 : u32 = (uniforms_uint.frame);
    var _S1232 : u32 = hash(_S1231);
    var _S1233 : u32 = global_invocation_id_8.x;
    var _S1234 : vec2<u32> = (uniforms_uint.render_size);
    var _S1235 : u32 = stream(_S1232, _S1233 + _S1234.x * global_invocation_id_8.y);
    var _S1236 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1227, 0.0f, vec4<u32>(u32(0)), _S1227, _S1227);
    var _S1237 : Selection = Selection_x24init_0(_S1236, 0.0f, _S1227, u32(0));
    var initial_0 : Selection = _S1237;
    var _S1238 : u32 = stream(_S1235, u32(193));
    initial_0.random_state = _S1238;
    var i_7 : u32 = u32(0);
    loop
    {
        var _S1239 : u32 = (uniforms_uint.samples);
        if(i_7 < _S1239)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1236;
        var _S1240 : u32 = stream(_S1235, i_7);
        r_9.seed = _S1240;
        var _S1241 : u32 = (uniforms_uint.samples);
        var _S1242 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1241), &(initial_0));
        var i_8 : u32 = i_7 + u32(1);
        i_7 = i_8;
    }
    var _S1243 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1226), (_S1243), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1244 : Random = pcg(state_3);
    var _S1245 : Random = pcg(_S1244.state);
    var _S1246 : f32 = 6.28318548202514648f * _S1244.value;
    var _S1247 : f32 = sqrt(-2.0f * clamp(log(_S1245.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1245.state, _S1247 * cos(_S1246));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1248 : RandomSphere;
    _S1248.state = state_4;
    _S1248.value = value_1;
    return _S1248;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1249 : Random = normal_distribution(state_5);
    var _S1250 : Random = normal_distribution(_S1249.state);
    var _S1251 : Random = normal_distribution(_S1250.state);
    var _S1252 : vec3<f32> = (normalize((vec3<f32>(_S1249.value, _S1250.value, _S1251.value))));
    return RandomSphere_x24init_0(_S1251.state, _S1252);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_13 : vec3<f32>) -> mat3x3<f32>
{
    var _S1253 : vec3<f32> = p1_0 - p0_0;
    var _S1254 : vec3<f32> = p2_0 - p0_0;
    var _S1255 : vec2<f32> = uv1_0 - uv0_0;
    var _S1256 : vec2<f32> = uv2_0 - uv0_0;
    var _S1257 : f32 = _S1255.x;
    var _S1258 : f32 = _S1256.y;
    var _S1259 : f32 = _S1255.y;
    var _S1260 : f32 = _S1256.x;
    var _S1261 : f32 = _S1257 * _S1258 - _S1259 * _S1260;
    var _S1262 : f32 = 1.0f / _S1261;
    var _S1263 : vec3<f32> = vec3<f32>(_S1262);
    var t_20 : vec3<f32> = (_S1253 * vec3<f32>(_S1258) - _S1254 * vec3<f32>(_S1259)) * _S1263;
    var _S1264 : vec3<f32> = (_S1254 * vec3<f32>(_S1257) - _S1253 * vec3<f32>(_S1260)) * _S1263;
    var t_21 : vec3<f32> = (normalize((t_20 - n_13 * vec3<f32>(dot(n_13, t_20)))));
    var _S1265 : bool = (dot(cross(n_13, t_21), _S1264)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1265)
    {
        var _S1266 : vec3<f32> = ((-(t_21)));
        t_22 = _S1266;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1267 : vec3<f32> = cross(n_13, t_22);
    return mat3x3<f32>(t_22, _S1267, n_13);
}

fn tangentToWorldNormalMap( v_4 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_4)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1268 : vec3<f32> = t1_0 - t0_0;
    var _S1269 : vec3<f32> = t2_2 - t0_0;
    var _S1270 : vec3<f32> = t2_2 - t1_0;
    var _S1271 : f32 = min(length(_S1268), min(length(_S1269), length(_S1270)));
    var _S1272 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1273 : vec3<f32> = (normalize((n0_0)));
    var _S1274 : f32 = dot(geometry_n_5, _S1273);
    var _S1275 : vec3<f32> = (normalize((n1_0)));
    var _S1276 : f32 = dot(geometry_n_5, _S1275);
    var _S1277 : vec3<f32> = (normalize((n2_0)));
    var _S1278 : vec3<f32> = acos(abs(vec3<f32>(_S1274, _S1276, dot(geometry_n_5, _S1277))));
    var _S1279 : vec3<f32> = clamp(tan(_S1278), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1272 * _S1279, uvw_0), 0.0f, _S1271 * 0.125f);
}

fn straightThrough( dir_13 : vec3<f32>,  n_14 : vec3<f32>,  material_23 : Material) -> vec3<f32>
{
    var _S1280 : vec3<f32> = ((-(dir_13)));
    var _S1281 : f32 = (sign((dot(n_14, _S1280))));
    var _S1282 : vec3<f32> = n_14 * vec3<f32>(_S1281);
    var _S1283 : AnisotropicFrame = anisotropicFrame(material_23, _S1282);
    var _S1284 : bool = (_S1283.alphas.x) > 0.0f;
    if(_S1284)
    {
        var _S1285 : f32 = material_23.transmission * (1.0f - material_23.metallic);
        var _S1286 : vec3<f32> = ((-(_S1282)));
        var _S1287 : vec3<f32> = anisotropicLocal(dir_13, _S1283.tangent, _S1286);
        var _S1288 : f32 = anisotropicG1(_S1287, _S1283.alphas);
        return vec3<f32>((_S1285 * _S1288)) * material_23.albedo;
    }
    var _S1289 : f32 = material_23.transmission * (1.0f - material_23.metallic);
    var _S1290 : f32 = material_23.roughness;
    var _S1291 : f32 = smithG1(_S1290 * _S1290, abs(dot(n_14, dir_13)));
    return vec3<f32>((_S1289 * _S1291)) * material_23.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_15 : vec3<f32>,  material_24 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1292 : vec3<f32>;
    if((material_24.ior) == 1.0f)
    {
        var _S1293 : vec3<f32> = straightThrough(toward_1, n_15, material_24);
        _S1292 = _S1293;
    }
    else
    {
        _S1292 = vec3<f32>(0.0f);
    }
    return _S1292 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1294 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1294;
}

fn shift_hook( dom_9 : Domain,  r_11 : Reservoir) -> Shift
{
    var _S1295 : Shift = shift_0(dom_9, r_11);
    return _S1295;
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

