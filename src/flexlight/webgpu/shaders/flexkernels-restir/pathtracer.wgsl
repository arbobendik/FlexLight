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
     p_sheen_velvet : f32,
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
var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
fn anisotropicG1( w_2 : vec3<f32>,  alphas_1 : vec2<f32>) -> f32
{
    var _S295 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S295 / (_S295 + length(vec3<f32>(alphas_1.x * w_2.x, alphas_1.y * w_2.y, _S295)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S296 : f32 = alphas_2.x;
    var _S297 : f32 = h_0.x / _S296;
    var _S298 : f32 = alphas_2.y;
    var _S299 : f32 = h_0.y / _S298;
    var _S300 : f32 = h_0.z;
    var _S301 : f32 = _S297 * _S297 + _S299 * _S299 + _S300 * _S300;
    return 1.0f / max(3.14159274101257324f * _S296 * _S298 * _S301 * _S301, 1.17549435082228751e-38f);
}

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  p_sheen_velvet_0 : f32,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_3 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S302 : BSDFLobes;
    _S302.v_dot_h = v_dot_h_0;
    _S302.n_dot_h = n_dot_h_0;
    _S302.refracted = refracted_1;
    _S302.F = F_0;
    _S302.F_greyscale = F_greyscale_0;
    _S302.reflect_weight = reflect_weight_0;
    _S302.diffuse_weight = diffuse_weight_0;
    _S302.refract_weight = refract_weight_0;
    _S302.p_diffuse = p_diffuse_0;
    _S302.p_reflect = p_reflect_0;
    _S302.p_refract = p_refract_0;
    _S302.translucent_share = translucent_share_0;
    _S302.sheen = sheen_0;
    _S302.p_sheen_velvet = p_sheen_velvet_0;
    _S302.view = view_1;
    _S302.tangent = tangent_1;
    _S302.alphas = alphas_3;
    _S302.visible = visible_0;
    return _S302;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_1 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S303 : f32 = dot(ggx_n_0, v_3);
    var _S304 : f32 = dot(n_i_2, ggx_n_0);
    var _S305 : f32 = eta_i_1 / eta_o_1;
    var _S306 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S305))));
    var _S307 : f32 = min(sqrt(material_1.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S308 : f32 = _S307 * _S307;
    var _S309 : f32 = (1.0f + _S307) / (1.0f - _S307);
    var _S310 : f32 = abs(_S303);
    var _S311 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S311)
    {
        sheen_component_0 = _S309;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S311)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S309;
    }
    var _S312 : f32 = fresnel(_S310, sheen_component_0, visible_1);
    var _S313 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S303 * _S303)) >= (eta_o_1 * eta_o_1);
    var _S314 : vec3<f32>;
    if(_S313)
    {
        _S314 = vec3<f32>(1.0f);
    }
    else
    {
        var _S315 : vec3<f32> = material_1.specular_tint * vec3<f32>(_S308);
        _S314 = _S315 + (vec3<f32>(1.0f) - _S315) * vec3<f32>((_S312 - _S308)) / vec3<f32>((1.0f - _S308));
    }
    var _S316 : vec3<f32> = vec3<f32>(1.0f);
    var _S317 : vec3<f32> = vec3<f32>(0.0f);
    var _S318 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S319 : bool = _S318 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S319)
    {
        var _S320 : f32 = clamp(sqrt(max(dot(n_i_2, v_3), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S321 : u32 = min(u32(_S320), u32(22));
        var least_0 : f32 = sqrt(0.05000000074505806f);
        var _S322 : f32 = sqrt(0.10000000149011612f);
        var _S323 : bool = (material_1.velvet) > 0.0f;
        var _S324 : f32 = select(least_0, _S322, _S323);
        var _S325 : f32 = (clamp(sqrt(max(material_1.sheen_roughness, 0.0f)), _S324, 1.0f) - _S324) / (1.0f - _S324) * 23.0f;
        var _S326 : u32 = min(u32(_S325), u32(22));
        var _S327 : u32 = _S321 * u32(24) + _S326;
        var _S328 : f32 = _S320 - f32(_S321);
        var _S329 : f32 = _S325 - f32(_S326);
        var _S330 : u32 = _S327 + u32(24);
        var a_5 : f32 = SHEEN_ALBEDO_0[_S327] + (SHEEN_ALBEDO_0[_S330] - SHEEN_ALBEDO_0[_S327]) * _S328;
        var _S331 : u32 = _S327 + u32(1);
        var _S332 : u32 = _S330 + u32(1);
        var b_1 : f32 = SHEEN_ALBEDO_0[_S331] + (SHEEN_ALBEDO_0[_S332] - SHEEN_ALBEDO_0[_S331]) * _S328;
        var _S333 : f32 = exp(a_5 + (b_1 - a_5) * _S329);
        if(_S323)
        {
            var a_6 : f32 = VELVET_ALBEDO_0[_S327] + (VELVET_ALBEDO_0[_S330] - VELVET_ALBEDO_0[_S327]) * _S328;
            var b_2 : f32 = VELVET_ALBEDO_0[_S331] + (VELVET_ALBEDO_0[_S332] - VELVET_ALBEDO_0[_S331]) * _S328;
            var _S334 : f32 = a_6 + (b_2 - a_6) * _S329;
            sheen_component_0 = _S334;
        }
        else
        {
            sheen_component_0 = _S333;
        }
        var _S335 : f32 = min(sheen_component_0, 1.0f);
        var _S336 : vec3<f32> = vec3<f32>(1.0f) - material_1.sheen * vec3<f32>(_S335);
        var _S337 : f32 = rgb_to_greyscale(material_1.sheen);
        var _S338 : f32 = _S337 * _S335;
        var _S339 : vec3<f32> = material_1.sheen / vec3<f32>(max(sheen_component_0, 1.0f));
        scale_0 = _S336;
        sheen_component_0 = _S338;
        sheen_1 = _S339;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S316;
        sheen_component_0 = 0.0f;
        sheen_1 = _S317;
        view_2 = _S317;
    }
    var _S340 : vec3<f32> = (mix((_S314), (material_1.albedo), (material_1.metallic)));
    var F_1 : vec3<f32> = _S340 * scale_0;
    var _S341 : f32 = rgb_to_greyscale(F_1);
    var _S342 : f32 = 1.0f - material_1.metallic;
    var _S343 : vec3<f32> = vec3<f32>(1.0f) - _S314;
    var _S344 : vec3<f32> = vec3<f32>(((1.0f - material_1.transmission) * _S342)) * _S343 * scale_0;
    var _S345 : vec3<f32> = vec3<f32>((material_1.transmission * _S342)) * _S343 * scale_0;
    var _S346 : f32 = max(_S341, 0.0f);
    var _S347 : f32 = rgb_to_greyscale(_S344);
    var _S348 : f32 = max(_S347, 0.0f);
    var _S349 : f32 = rgb_to_greyscale(_S345);
    var _S350 : f32 = (sign((length(_S306))));
    var _S351 : f32 = max(_S349 * _S350, 0.0f);
    var _S352 : f32 = _S346 + _S348 + _S351;
    var _S353 : f32 = min(sheen_component_0, 1.0f);
    var _S354 : bool = sheen_component_0 > 0.0f;
    var _S355 : bool;
    if(_S354)
    {
        _S355 = !(_S352 > 0.0f);
    }
    else
    {
        _S355 = false;
    }
    var _S356 : f32 = select(_S353, 1.0f, _S355);
    var _S357 : f32 = (1.0f - _S356) / max(_S352, 0.0000152587890625f);
    var _S358 : f32 = _S348 * _S357;
    var _S359 : f32 = _S346 * _S357;
    var _S360 : f32 = _S351 * _S357;
    var _S361 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S361)
    {
        var _S362 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S363 : f32 = anisotropicG1(_S362, frame_1.alphas);
        var _S364 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S365 : f32 = anisotropicD(_S364, frame_1.alphas);
        var _S366 : f32 = _S363 * _S365;
        visible_1 = _S366;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S303, _S304, _S306, F_1, _S341, 1.0f, _S344, _S345, _S358, _S359, _S360, 0.0f, sheen_1, _S356, view_2, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_2 : Material) -> f32
{
    var _S367 : f32 = rgb_to_greyscale(material_2.translucent);
    var _S368 : f32 = rgb_to_greyscale(material_2.albedo);
    var _S369 : f32 = _S367 / (_S368 + _S367);
    var _S370 : bool = _S367 > 0.0f;
    var _S371 : f32 = select(0.0f, _S369, _S370);
    return _S371;
}

fn smithG1( alpha_2 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S372 : f32 = alpha_2 * alpha_2;
    var _S373 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S372 + (1.0f - _S372) * n_dot_x_0 * n_dot_x_0));
    var _S374 : bool = alpha_2 > 0.0f;
    var _S375 : f32 = select(1.0f, _S373, _S374);
    return _S375;
}

fn trowbridgeReitz( alpha_3 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S376 : f32 = alpha_3 * alpha_3;
    var _S377 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S376 * n_dot_h_1 * n_dot_h_1;
    return _S376 / max(3.14159274101257324f * _S377 * _S377, 1.17549435082228751e-38f);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S378 : bool = lobe_0 == u32(0);
    if(_S378)
    {
        var _S379 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S380 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S381 : f32 = 1.0f - lobes_0.translucent_share;
        var _S382 : bool = n_i_dot_l_0 < 0.0f;
        var _S383 : f32 = select(_S381, lobes_0.translucent_share, _S382);
        var _S384 : f32 = _S380 * _S383;
        var _S385 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S386 : f32 = select(_S379, _S384, _S385);
        var _S387 : bool = n_i_dot_v_0 > 0.0f;
        var _S388 : f32 = select(0.0f, _S386, _S387);
        return _S388;
    }
    var _S389 : bool = lobe_0 == u32(4);
    var _S390 : bool;
    if(_S389)
    {
        var _S391 : f32 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        var _S392 : bool = n_i_dot_l_0 > 0.0f;
        if(_S392)
        {
            _S390 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S390 = false;
        }
        var _S393 : f32 = select(0.0f, _S391, _S390);
        return _S393;
    }
    var _S394 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S395 : f32 = _S394 * lobes_0.v_dot_h;
    var _S396 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S397 : f32 = _S395 * _S396 / n_i_dot_v_0;
    var _S398 : bool = alpha_4 > 0.0f;
    if(_S398)
    {
        _S390 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        _S390 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        _S390 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S390 = false;
    }
    var _S399 : f32 = select(0.0f, _S397, _S390);
    var _S400 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S400)
    {
        var _S401 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S402 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S402)
        {
            _S390 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S390 = false;
        }
        if(_S390)
        {
            _S390 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S390 = false;
        }
        var _S403 : f32 = select(0.0f, _S401, _S390);
        pdf_h_0 = _S403;
    }
    else
    {
        pdf_h_0 = _S399;
    }
    var _S404 : bool = lobe_0 == u32(1);
    if(_S404)
    {
        var _S405 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S406 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S405 * _S405);
        var _S407 : bool = eta_i_2 != eta_o_2;
        if(_S407)
        {
            _S390 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S390 = false;
        }
        var _S408 : f32 = select(0.0f, _S406, _S390);
        return _S408;
    }
    var _S409 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S410 : bool = pdf_h_0 > 0.0f;
    var _S411 : f32 = select(0.0f, _S409, _S410);
    return _S411;
}

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_1 : u32,  pdf_0 : f32) -> SampleBSDF
{
    var _S412 : SampleBSDF;
    _S412.unit_direction = unit_direction_1;
    _S412.throughput = throughput_0;
    _S412.random_state = random_state_1;
    _S412.refracted = refracted_2;
    _S412.lobe = lobe_1;
    _S412.pdf = pdf_0;
    return _S412;
}

fn lobeThroughput( l_0 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_3 : Material,  lobes_1 : BSDFLobes,  lobe_2 : u32) -> vec3<f32>
{
    var _S413 : bool = lobe_2 == u32(0);
    if(_S413)
    {
        var _S414 : bool = (dot(n_i_3, l_0)) < 0.0f;
        var _S415 : vec3<f32> = select(material_3.albedo, material_3.translucent, _S414);
        var _S416 : f32 = 1.0f - lobes_1.translucent_share;
        var _S417 : f32 = select(_S416, lobes_1.translucent_share, _S414);
        var _S418 : vec3<f32> = _S415 / vec3<f32>(_S417);
        var _S419 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S420 : vec3<f32> = select(material_3.albedo, _S418, _S419);
        return lobes_1.diffuse_weight * _S420 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S421 : bool = lobe_2 == u32(4);
    var f_1 : f32;
    if(_S421)
    {
        var _S422 : vec3<f32> = (normalize((l_0 + lobes_1.view)));
        var _S423 : f32 = dot(n_i_3, _S422);
        var _S424 : f32 = max(dot(n_i_3, l_0), 0.0f);
        var _S425 : f32 = max(dot(n_i_3, lobes_1.view), 0.0f);
        var _S426 : f32 = 1.0f / max(material_3.sheen_roughness, 0.05000000074505806f);
        var _S427 : f32 = 1.0f - _S423 * _S423;
        var _S428 : f32 = (2.0f + _S426) * pow(max(_S427, 0.0f), 0.5f * _S426) * 0.5f * 0.31830987334251404f / max(4.0f * (_S424 + _S425 - _S424 * _S425), 0.0000152587890625f);
        var _S429 : bool = (material_3.velvet) > 0.0f;
        if(_S429)
        {
            var _S430 : f32 = max(material_3.sheen_roughness, 0.00999999977648258f);
            var _S431 : f32 = _S430 * _S430;
            var _S432 : f32 = max(_S427, 0.0000152587890625f);
            var _S433 : f32 = exp(- _S423 * _S423 / (_S432 * _S431)) / (3.14159274101257324f * _S431 * _S432 * _S432) * min(1.0f, 2.0f * _S423 * min(_S424, _S425) / max(abs(dot(_S422, lobes_1.view)), 0.0000152587890625f)) / max(4.0f * _S424 * _S425, 0.0000152587890625f);
            f_1 = _S433;
        }
        else
        {
            f_1 = _S428;
        }
        return lobes_1.sheen * vec3<f32>((f_1 * _S424 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet));
    }
    var _S434 : bool = lobe_2 == u32(1);
    if(_S434)
    {
        var _S435 : f32 = - dot(n_i_3, l_0);
        var _S436 : f32 = smithG1(alpha_5, max(_S435, 0.0f));
        var _S437 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S437)
        {
            var _S438 : vec3<f32> = ((-(n_i_3)));
            var _S439 : vec3<f32> = anisotropicLocal(l_0, lobes_1.tangent, _S438);
            var _S440 : f32 = anisotropicG1(_S439, lobes_1.alphas);
            f_1 = _S440;
        }
        else
        {
            f_1 = _S436;
        }
        return lobes_1.refract_weight * vec3<f32>(f_1) * material_3.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S441 : f32 = dot(n_i_3, l_0);
    var _S442 : f32 = smithG1(alpha_5, max(_S441, 0.0f));
    var _S443 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S443)
    {
        var _S444 : vec3<f32> = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        var _S445 : f32 = anisotropicG1(_S444, lobes_1.alphas);
        f_1 = _S445;
    }
    else
    {
        f_1 = _S442;
    }
    return vec3<f32>((lobes_1.reflect_weight * f_1)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_4 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S446 : vec3<f32> = ((-(in_dir_1)));
    var _S447 : f32 = dot(n_4, _S446);
    var _S448 : f32 = (sign((_S447)));
    var _S449 : vec3<f32> = n_4 * vec3<f32>(_S448);
    var _S450 : f32 = material_4.roughness;
    var _S451 : f32 = _S450 * _S450;
    var _S452 : AnisotropicFrame = anisotropicFrame(material_4, _S449);
    var _S453 : vec3<f32> = (normalize((_S446 + out_dir_0)));
    var _S454 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S454)
    {
        var _S455 : vec3<f32> = sampleHalfVector(_S446, _S449, _S451, _S452, &(random_state_2));
        ggx_n_1 = _S455;
    }
    else
    {
        var _S456 : bool = lobe_3 == u32(1);
        if(_S456)
        {
            var _S457 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S446 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S458 : vec3<f32> = (normalize((_S457)));
            var _S459 : f32 = (sign((dot(_S457, _S449))));
            var _S460 : vec3<f32> = _S458 * vec3<f32>(_S459);
            ggx_n_1 = _S460;
        }
        else
        {
            ggx_n_1 = _S453;
        }
    }
    var _S461 : BSDFLobes = bsdfLobes(in_dir_1, _S446, _S449, ggx_n_1, material_4, eta_i_3, eta_o_3, _S452);
    var lobes_2 : BSDFLobes = _S461;
    var _S462 : f32 = translucentShare(material_4);
    lobes_2.translucent_share = _S462;
    var _S463 : f32 = lobeDensity(dot(_S449, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S447), _S451, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S464 : bool = !(_S463 > 0.0f);
    if(_S464)
    {
        var _S465 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S465, _S465, u32(0), false, u32(0), 0.0f);
    }
    var _S466 : vec3<f32> = lobeThroughput(out_dir_0, _S449, _S451, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S466, random_state_2, lobe_3 == u32(1), lobe_3, _S463);
}

fn neeBSDF( in_dir_2 : vec3<f32>,  dir_4 : vec3<f32>,  n_5 : vec3<f32>,  material_5 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_3 : bool,  pdf_1 : f32,  power_0 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var _S467 : vec3<f32> = vec3<f32>(0.0f);
    var i_0 : u32 = u32(0);
    var f_2 : vec3<f32> = _S467;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S468 : u32;
        if(i_0 == u32(3))
        {
            _S468 = u32(4);
        }
        else
        {
            _S468 = i_0;
        }
        var _S469 : bool = _S468 == u32(0);
        if(_S469)
        {
        }
        var _S470 : bool;
        if(_S469)
        {
            var _S471 : f32 = rgb_to_greyscale(material_5.translucent);
            _S470 = _S471 > 0.0f;
        }
        else
        {
            _S470 = false;
        }
        var _S472 : bool;
        if(_S470)
        {
            var _S473 : f32 = dot(n_5, dir_4);
            var _S474 : vec3<f32> = ((-(in_dir_2)));
            _S472 = ((_S473 * dot(n_5, _S474)) < 0.0f) == refracted_3;
        }
        else
        {
            _S472 = (_S468 == u32(1)) == refracted_3;
        }
        var f_3 : vec3<f32>;
        if(_S472)
        {
            var _S475 : SampleBSDF = connectBSDF(in_dir_2, dir_4, n_5, material_5, eta_i_4, eta_o_4, _S468, random_state_3);
            var _S476 : bool = (_S475.pdf) > 0.0f;
            if(_S476)
            {
                if(power_0)
                {
                    var _S477 : f32 = _S475.pdf / pdf_1;
                    var f_4 : vec3<f32> = f_2 + _S475.throughput * vec3<f32>(_S475.pdf) / vec3<f32>((pdf_1 * (1.0f + _S477 * _S477)));
                    f_3 = f_4;
                }
                else
                {
                    var f_5 : vec3<f32> = f_2 + _S475.throughput * vec3<f32>(_S475.pdf) / vec3<f32>((_S475.pdf + pdf_1));
                    f_3 = f_5;
                }
            }
            else
            {
                f_3 = f_2;
            }
        }
        else
        {
            f_3 = f_2;
        }
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
        f_2 = f_3;
    }
    return f_2;
}

fn skyBSDF( in_dir_3 : vec3<f32>,  dir_5 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_2 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var _S478 : bool = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    var _S479 : vec3<f32> = neeBSDF(in_dir_3, dir_5, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S478, pdf_2, false, random_state_4);
    return _S479;
}

fn SkySample_x24init_0( dir_6 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S480 : SkySample;
    _S480.dir = dir_6;
    _S480.radiance = radiance_1;
    _S480.color = color_0;
    _S480.random_state = random_state_5;
    return _S480;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S481 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S482 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S483 : vec2<u32> = _S481 - _S482;
    var _S484 : Random = pcg(init_random_state_0);
    var _S485 : Random = pcg(_S484.state);
    var _S486 : Random = pcg(_S485.state);
    var _S487 : Random = pcg(_S486.state);
    var _S488 : u32 = _S483.x;
    var _S489 : u32 = searchCDF_0(vec2<u32>(_S488, u32(0)), vec2<u32>(u32(0), u32(1)), _S483.y, _S484.value);
    var _S490 : u32 = searchCDF_0(vec2<u32>(u32(0), _S489), _S482, _S488, _S485.value);
    var _S491 : vec2<f32> = (vec2<f32>(f32(_S490), f32(_S489)) + vec2<f32>(_S486.value, _S487.value)) / vec2<f32>(_S483) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S492 : f32 = _S491.y;
    var _S493 : f32 = sin(_S492);
    var _S494 : f32 = _S491.x;
    var _S495 : vec3<f32> = vec3<f32>(_S493 * cos(_S494), cos(_S492), _S493 * sin(_S494));
    var _S496 : f32 = environmentPdf_0(_S495);
    var _S497 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S495, surface_2, eta_1, is_inside_3, _S496, lobe_state_0);
    var _S498 : bool = !(_S496 > 0.0f);
    var _S499 : bool;
    if(_S498)
    {
        _S499 = true;
    }
    else
    {
        _S499 = (all((_S497 == vec3<f32>(0.0f))));
    }
    if(_S499)
    {
        var _S500 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S495, _S500, _S500, _S487.state);
    }
    var _S501 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, is_inside_3, _S495);
    return SkySample_x24init_0(_S495, _S501, _S497 * _S501, _S487.state);
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
    var _S502 : TreeSample;
    _S502.dir = dir_7;
    _S502.radiance = radiance_2;
    _S502.density = density_0;
    _S502.random_state = random_state_6;
    return _S502;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S503 : f32 = importance(first_1, p_10, normal_3);
    var _S504 : f32 = importance(second_1, p_10, normal_3);
    var _S505 : vec2<f32> = vec2<f32>(_S503, _S504);
    var _S506 : bool = _S503 == 0.0f;
    var _S507 : bool;
    if(_S506)
    {
        _S507 = _S504 == 0.0f;
    }
    else
    {
        _S507 = false;
    }
    if(_S507)
    {
        return u32(2);
    }
    var _S508 : f32 = _S503 + _S504;
    var _S509 : bool = _S504 > 0.0f;
    if(_S509)
    {
        _S507 = ((*pick_0) * _S508) >= _S503;
    }
    else
    {
        _S507 = false;
    }
    var _S510 : u32 = select(u32(0), u32(1), _S507);
    var _S511 : f32 = min(((*pick_0) * _S508 - f32(_S510) * _S503) / _S505[_S510], 0.99999994039535522f);
    (*pick_0) = _S511;
    var _S512 : f32 = (*probability_3) * (_S505[_S510] / _S508);
    (*probability_3) = _S512;
    return _S510;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S513 : vec3<f32> = center_1 - p_11;
    var _S514 : f32 = radius_1 * radius_1 / dot(_S513, _S513);
    var _S515 : f32 = u1_0 * _S514 / (1.0f + sqrt(max(1.0f - _S514, 0.0f)));
    var _S516 : f32 = 2.0f * u1_0;
    var _S517 : bool = _S514 >= 1.0f;
    var _S518 : f32 = select(_S515, _S516, _S517);
    var _S519 : f32 = sqrt(max(_S518 * (2.0f - _S518), 0.0f));
    var _S520 : f32 = 6.28318548202514648f * u2_0;
    var _S521 : vec3<f32> = vec3<f32>(_S519 * cos(_S520), 1.0f - _S518, _S519 * sin(_S520));
    var _S522 : vec3<f32> = (normalize((_S513)));
    var _S523 : vec3<f32> = tangentToWorld(_S521, _S522);
    return _S523;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S524 : vec3<f32> = center_2 - ray_1.origin;
    var _S525 : f32 = dot(_S524, ray_1.unit_direction);
    var _S526 : f32 = dot(_S524, _S524) - _S525 * _S525;
    var _S527 : f32 = radius_3 * radius_3;
    var _S528 : bool = _S526 > _S527;
    if(_S528)
    {
        return 4.294967296e+09f;
    }
    var _S529 : f32 = sqrt(_S527 - _S526);
    var _S530 : f32 = _S525 - _S529;
    var _S531 : f32 = _S525 + _S529;
    var _S532 : bool = _S530 > 0.0000152587890625f;
    var _S533 : bool;
    if(_S532)
    {
        _S533 = _S530 < max_len_0;
    }
    else
    {
        _S533 = false;
    }
    if(_S533)
    {
        return _S530;
    }
    var _S534 : bool = _S531 > 0.0000152587890625f;
    if(_S534)
    {
        _S533 = _S531 < max_len_0;
    }
    else
    {
        _S533 = false;
    }
    if(_S533)
    {
        return _S531;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S535 : Random = pcg(init_random_state_1);
    var _S536 : Random = pcg(_S535.state);
    var _S537 : Random = pcg(_S536.state);
    var _S538 : vec3<f32> = vec3<f32>(0.0f);
    var _S539 : TreeSample = TreeSample_x24init_0(_S538, _S538, 0.0f, _S537.state);
    var sample_0 : TreeSample = _S539;
    var _S540 : vec3<f32> = select(smooth_n_2, _S538, sided_0);
    var _S541 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S542 : vec3<f32> = origin_4 + _S541 * smooth_n_2;
    var pick_1 : f32 = _S535.value;
    var probability_4 : f32 = 1.0f;
    var n_6 : u32 = u32(0);
    loop
    {
        var _S543 : vec4<u32> = (access_light_tree(4u + 4u * (n_6)));
        if((_S543.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S544 : u32 = (access_light_tree(3u + 4u * (n_6)).w);
        var _S545 : u32 = n_6 + u32(1);
        var _S546 : LightBounds = (lightBounds((_S545)));
        var _S547 : LightBounds = (lightBounds((_S544)));
        var _S548 : u32 = pickChild(_S546, _S547, origin_4, _S540, &(pick_1), &(probability_4));
        var _S549 : bool = _S548 > u32(1);
        if(_S549)
        {
            return sample_0;
        }
        var _S550 : bool = _S548 == u32(1);
        var _S551 : u32 = select(_S545, _S544, _S550);
        n_6 = _S551;
    }
    var _S552 : bool = n_6 == u32(0);
    var _S553 : bool;
    if(_S552)
    {
        var _S554 : LightBounds = (lightBounds((u32(0))));
        var _S555 : f32 = importance(_S554, origin_4, _S540);
        _S553 = !(_S555 > 0.0f);
    }
    else
    {
        _S553 = false;
    }
    if(_S553)
    {
        return sample_0;
    }
    var _S556 : vec4<u32> = (access_light_tree(4u + 4u * (n_6)));
    var _S557 : bool = (_S556.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S557)
    {
        var _S558 : Light = (lights[(_S556.y)]);
        if(sided_0)
        {
            var _S559 : f32 = (sign((dot(geometry_n_1, _S558.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S559);
            var _S560 : vec3<f32> = origin_4 + _S541 * lift_n_1;
            start_5 = _S560;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S542;
            lift_n_0 = smooth_n_2;
        }
        var _S561 : bool = (_S558.variance) == 0.0f;
        if(_S561)
        {
            var _S562 : vec3<f32> = _S558.position - start_5;
            var _S563 : vec3<f32> = (normalize((_S562)));
            sample_0.dir = _S563;
            var _S564 : vec3<f32> = _S558.color * vec3<f32>(_S558.intensity) / vec3<f32>((dot(_S562, _S562) * probability_4));
            sample_0.radiance = _S564;
            shadow_1 = _S562;
        }
        else
        {
            var _S565 : vec3<f32> = sampleSphere(_S558.position, _S558.variance, start_5, _S536.value, _S537.value);
            sample_0.dir = _S565;
            var _S566 : f32 = sphereDensity(_S558.position, _S558.variance, start_5);
            var _S567 : f32 = probability_4 * _S566;
            sample_0.density = _S567;
            var _S568 : vec3<f32> = pointLightRadiance(_S558.color, _S558.intensity, _S558.variance);
            var _S569 : vec3<f32> = _S568 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S569;
            var _S570 : f32 = raySphere_0(_S558.position, _S558.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S571 : vec3<f32> = sample_0.dir * vec3<f32>(_S570);
            shadow_1 = _S571;
        }
    }
    else
    {
        var _S572 : u32 = _S556.y;
        var _S573 : u32 = ((instance_uint[(_S572) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S574 : u32 = _S573 + _S556.z;
        var _S575 : mat3x3<f32> = (worldTriangle((_S572), (_S574)));
        var _S576 : f32 = sqrt(_S536.value);
        var _S577 : vec2<f32> = vec2<f32>(_S576 * (1.0f - _S537.value), _S576 * _S537.value);
        var _S578 : vec3<f32> = (((_S575) * (vec3<f32>(1.0f - _S576, _S577))));
        if(sided_0)
        {
            var _S579 : f32 = (sign((dot(geometry_n_1, _S578 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S579);
            var _S580 : vec3<f32> = origin_4 + _S541 * lift_n_2;
            start_5 = _S580;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S581 : bool = !((dot(smooth_n_2, _S578 - origin_4)) > 0.0f);
            if(_S581)
            {
                return sample_0;
            }
            start_5 = _S542;
            lift_n_0 = smooth_n_2;
        }
        var _S582 : Surface = (surfaceAt((Hit_x24init_0(_S577, _S572, _S574, u32(0), 0.0f)), (_S578), (_S537.state)));
        sample_0.random_state = _S582.random_state;
        var _S583 : vec3<f32> = _S578 - start_5;
        var _S584 : vec3<f32> = (normalize((_S583)));
        sample_0.dir = _S584;
        var _S585 : f32 = solidAngle(probability_4, cross(_S575[i32(1)] - _S575[i32(0)], _S575[i32(2)] - _S575[i32(0)]), _S583);
        sample_0.density = _S585;
        var _S586 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S582.smooth_n))));
        var _S587 : vec3<f32> = _S582.material.emissive * vec3<f32>(max(_S586, 0.0f));
        var _S588 : vec3<f32> = select(_S587, _S538, _S582.skip);
        var _S589 : vec3<f32> = _S588 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S589;
        shadow_1 = _S583;
    }
    var _S590 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S591 : vec3<f32> = sample_0.radiance * _S590;
    var _S592 : bool = (all((_S590 == _S538)));
    var _S593 : vec3<f32> = select(_S591, _S538, _S592);
    sample_0.radiance = _S593;
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
    var _S594 : f32 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    var _S595 : bool = b_3 > 0.0f;
    var _S596 : f32 = select(1.0f, _S594, _S595);
    return _S596;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S597 : u32 = (lightSlot((hit_1)));
    var _S598 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S597, light_point_1);
    var _S599 : f32 = powerHeuristic(vertex_0.pdf, _S598);
    return _S599;
}

fn environment_0( dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S600 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S601 : bool = (_S600.x) > u32(1);
    var _S602 : bool;
    if(_S601)
    {
        var _S603 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S602 = (_S603.y) > u32(1);
    }
    else
    {
        _S602 = false;
    }
    if(_S602)
    {
        var _S604 : vec3<f32> = (env_map_sample((dir_8)));
        return _S604;
    }
    var _S605 : vec3<f32> = (uniforms_float.ambient);
    return _S605;
}

fn environmentMapped_0() -> bool
{
    var _S606 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S607 : bool = (_S606.x) > u32(1);
    var _S608 : bool;
    if(_S607)
    {
        var _S609 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S608 = (_S609.y) > u32(1);
    }
    else
    {
        _S608 = false;
    }
    return _S608;
}

fn escapeWeight_0( pdf_3 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S610 : bool = pdf_3 <= 0.0f;
    var _S611 : bool;
    if(_S610)
    {
        _S611 = true;
    }
    else
    {
        var _S612 : bool = environmentMapped_0();
        _S611 = !_S612;
    }
    if(_S611)
    {
        return 1.0f;
    }
    var _S613 : f32 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S613);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S614 : vec2<u32> = global_invocation_id_1.xy;
    var _S615 : vec2<i32> = vec2<i32>(_S614 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
    var i_2 : u32 = local_invocation_index_3;
    loop
    {
        if(i_2 < u32(576))
        {
        }
        else
        {
            break;
        }
        var _S616 : vec2<i32> = _S615 + vec2<i32>(i32(i_2 % u32(24)), i32(i_2 / u32(24)));
        var _S617 : bool = (all((_S616 >= vec2<i32>(i32(0)))));
        var _S618 : bool;
        if(_S617)
        {
            var _S619 : vec2<u32> = (uniforms_uint.render_size);
            _S618 = (all((_S616 < vec2<i32>(_S619))));
        }
        else
        {
            _S618 = false;
        }
        if(_S618)
        {
            var _S620 : vec4<u32> = (textureLoad(reservoir_prev, (_S616), (u32(0)), 0));
            var _S621 : u32 = _S620.x;
            var _S622 : bool = (bitcast<f32>((_S620.z))) > 0.0f;
            var _S623 : u32 = select(u32(0), _S621, _S622);
            seed_1 = _S623;
        }
        else
        {
            seed_1 = u32(0);
        }
        duplication_seeds_0[i_2] = seed_1;
        var i_3 : u32 = i_2 + u32(64);
        i_2 = i_3;
    }
    workgroupBarrier();
    var _S624 : u32 = local_invocation_id_0.y;
    var _S625 : u32 = local_invocation_id_0.x;
    var _S626 : u32 = duplication_seeds_0[(_S624 + u32(8)) * u32(24) + _S625 + u32(8)];
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
            var _S627 : bool = (duplication_seeds_0[(_S624 + seed_1) * u32(24) + _S625 + x_1]) == _S626;
            var _S628 : u32 = select(u32(0), u32(1), _S627);
            var count_2 : u32 = count_1 + _S628;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S629 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S630 : bool = _S626 != u32(0);
    var _S631 : f32 = select(0.0f, _S629, _S630);
    textureStore(duplication_out, (vec2<i32>(_S614)), 0, (vec4<u32>((bitcast<u32>((_S631))), u32(0), u32(0), u32(0))));
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
    var _S632 : Selection;
    _S632.r = r_2;
    _S632.w_sum = w_sum_0;
    _S632.color = color_2;
    _S632.random_state = random_state_7;
    return _S632;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S633 : u32 = hash(index_0);
    var _S634 : u32 = hash((seed_2 ^ (_S633)));
    return _S634;
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
    var _S635 : Shift;
    _S635.f = f_6;
    _S635.jac = jac_1;
    return _S635;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S636 : f32 = rgb_to_greyscale(weight_0);
    var _S637 : bool = _S636 > 0.0f;
    var _S638 : bool;
    if(_S637)
    {
        _S638 = _S636 < 3.00000000549775576e+38f;
    }
    else
    {
        _S638 = false;
    }
    var _S639 : bool = !_S638;
    if(_S639)
    {
        return;
    }
    var _S640 : f32 = (*sel_0).w_sum + _S636;
    (*sel_0).w_sum = _S640;
    var _S641 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S641;
    var _S642 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S642.state;
    var _S643 : bool = (_S642.value * (*sel_0).w_sum) <= _S636;
    if(_S643)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_3 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_3;
    var _S644 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S644;
    var _S645 : f32 = r_3.jac * shifted_0.jac;
    candidate_1.jac = _S645;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_3.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_4 : Reservoir = sel_2.r;
    var _S646 : f32 = rgb_to_greyscale(r_4.f);
    var _S647 : f32 = sel_2.w_sum / _S646;
    var _S648 : bool = _S646 > 0.0f;
    var _S649 : f32 = select(0.0f, _S647, _S648);
    r_4.w = _S649;
    r_4.c = c_2;
    return r_4;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S650 : vec2<u32> = global_invocation_id_2.xy;
    var _S651 : vec2<i32> = vec2<i32>(_S650);
    var _S652 : vec3<f32> = vec3<f32>(0.0f);
    var _S653 : Domain = Domain_x24init_0(_S652, _S652, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S653;
    var _S654 : bool = (currentDomain((_S651), &(dom_3)));
    var _S655 : bool = !_S654;
    if(_S655)
    {
        storeReservoir(reservoir_prev_out, (_S651), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S652, 0.0f, vec4<u32>(u32(0)), _S652, _S652)), (dom_3.hit));
        var _S656 : vec2<f32> = vec2<f32>(_S650);
        var _S657 : vec2<u32> = (uniforms_uint.render_size);
        var _S658 : vec2<f32> = _S656 / vec2<f32>(_S657.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S659 : vec3<f32> = vec3<f32>(_S658, 1.0f);
        var _S660 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S661 : vec3<f32> = (normalize(((((_S660) * (_S659))))));
        var _S662 : vec3<f32> = environment_0(_S661);
        textureStore(compute_out, (_S651), (u32(0)), (vec4<f32>(_S662, 1.0f)));
        var _S663 : u32 = (uniforms_uint.is_temporal);
        var _S664 : bool = _S663 == u32(1);
        if(_S664)
        {
            textureStore(compute_out, (_S651), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S665 : Reservoir = (loadReservoir(reservoir_temp, (_S651)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S665.c;
    loop
    {
        var _S666 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S666)
        {
        }
        else
        {
            break;
        }
        var _S667 : vec2<i32> = partner_0(_S651, t_13);
        var neighbor_0 : Domain = _S653;
        var _S668 : bool = (currentDomain((_S667), &(neighbor_0)));
        if(_S668)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S669 : vec4<u32> = (textureLoad(reservoir_temp, (_S667), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S669.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S670 : f32 = _S665.c / max(count_3, 1.0f);
    var _S671 : f32 = rgb_to_greyscale(_S665.f);
    var _S672 : bool = count_3 == 0.0f;
    var _S673 : f32 = select(0.0f, 1.0f, _S672);
    var _S674 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S652, 0.0f, vec4<u32>(u32(0)), _S652, _S652), 0.0f, _S652, u32(0));
    var sel_3 : Selection = _S674;
    var _S675 : u32 = (uniforms_uint.frame);
    var _S676 : u32 = hash(_S675);
    var _S677 : u32 = global_invocation_id_2.x;
    var _S678 : vec2<u32> = (uniforms_uint.render_size);
    var _S679 : u32 = stream(_S676, _S677 + _S678.x * global_invocation_id_2.y);
    var _S680 : u32 = stream(_S679, u32(195));
    sel_3.random_state = _S680;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S673;
    loop
    {
        var _S681 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S681)
        {
        }
        else
        {
            break;
        }
        var _S682 : vec2<i32> = partner_0(_S651, t_13);
        var neighbor_dom_0 : Domain = _S653;
        var _S683 : bool = (currentDomain((_S682), &(neighbor_dom_0)));
        if(_S683)
        {
            var _S684 : Reservoir = (loadReservoir(reservoir_temp, (_S682)));
            var _S685 : vec4<u32> = (textureLoad(shift_data, (_S682), (t_13), 0));
            var _S686 : vec4<f32> = (bitcast<vec4<f32>>((_S685)));
            var _S687 : vec4<u32> = (textureLoad(shift_data, (_S651), (t_13), 0));
            var _S688 : vec4<f32> = (bitcast<vec4<f32>>((_S687)));
            var _S689 : f32 = pairShare(_S684.c, _S670, c_sum_1);
            var _S690 : bool = _S671 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S690)
            {
                var _S691 : f32 = rgb_to_greyscale(_S688.xyz);
                var _S692 : f32 = canonicalWeight(_S689, _S670, _S671, _S684.c, _S691);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S692;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S693 : vec3<f32> = _S686.xyz;
            var _S694 : Shift = Shift_x24init_0(_S693, _S686.w);
            var _S695 : f32 = rgb_to_greyscale(_S684.f);
            var _S696 : f32 = rgb_to_greyscale(_S693);
            var _S697 : f32 = neighborWeight(_S689, _S684.c, _S695, _S670, _S696);
            offerShifted(&(sel_3), _S684, _S694, _S697);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S665, Shift_x24init_0(_S665.f, 1.0f), canonical_mis_0);
    var _S698 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S651), (_S698), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S651), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S699 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S700 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S701 : f32 = (sign((dot(_S700, _S699.smooth_n))));
    var _S702 : vec3<f32> = _S699.material.emissive * vec3<f32>(max(_S701, 0.0f));
    var _S703 : vec3<f32> = select(_S702, _S652, _S699.skip);
    var _S704 : vec3<f32> = clamp(sel_3.color + _S703, _S652, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S651), (u32(0)), (vec4<f32>(_S704, 1.0f)));
    var _S705 : u32 = (uniforms_uint.is_temporal);
    var _S706 : bool = _S705 == u32(1);
    if(_S706)
    {
        textureStore(compute_out, (_S651), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_4 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S707 : NEEVertex;
    _S707.none = none_0;
    _S707.pdf = pdf_4;
    _S707.origin = origin_5;
    _S707.smooth_n = smooth_n_3;
    _S707.start = start_6;
    return _S707;
}

struct Vertex
{
     rough : bool,
     lobe : u32,
     pdf : f32,
     cos : f32,
     inside : bool,
};

fn Vertex_x24init_0( rough_0 : bool,  lobe_4 : u32,  pdf_5 : f32,  cos_0 : f32,  inside_0 : bool) -> Vertex
{
    var _S708 : Vertex;
    _S708.rough = rough_0;
    _S708.lobe = lobe_4;
    _S708.pdf = pdf_5;
    _S708.cos = cos_0;
    _S708.inside = inside_0;
    return _S708;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>,  velvet_0 : f32) -> Material
{
    var _S709 : Material;
    _S709.albedo = albedo_0;
    _S709.emissive = emissive_0;
    _S709.roughness = roughness_0;
    _S709.metallic = metallic_0;
    _S709.transmission = transmission_0;
    _S709.ior = ior_0;
    _S709.absorption = absorption_0;
    _S709.specular_tint = specular_tint_0;
    _S709.specular_level = specular_level_0;
    _S709.translucent = translucent_0;
    _S709.sheen = sheen_2;
    _S709.sheen_roughness = sheen_roughness_0;
    _S709.anisotropy = anisotropy_0;
    _S709.anisotropic_rotation = anisotropic_rotation_0;
    _S709.tangent = tangent_2;
    _S709.velvet = velvet_0;
    return _S709;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_6 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S710 : Surface;
    _S710.smooth_n = smooth_n_4;
    _S710.geometry_n = geometry_n_2;
    _S710.geometry_offset = geometry_offset_2;
    _S710.material = material_6;
    _S710.skip = skip_0;
    _S710.random_state = random_state_8;
    return _S710;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S711 : bool = transmission_1 > 0.0f;
    var _S712 : bool;
    if(_S711)
    {
        _S712 = true;
    }
    else
    {
        _S712 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S713 : f32;
    if(_S712)
    {
        _S713 = 1.0f;
    }
    else
    {
        _S713 = -1.0f;
    }
    return _S713;
}

fn facingRay_0( surface_3 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S714 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_10);
    var _S715 : vec3<f32> = vec3<f32>(_S714);
    return Surface_x24init_0(surface_3.smooth_n * _S715, surface_3.geometry_n * _S715, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S716 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S716));
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
    var _S717 : bool;
    if(open_0)
    {
        _S717 = prev_rough_0;
    }
    else
    {
        _S717 = false;
    }
    if(_S717)
    {
        _S717 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S717 = false;
    }
    return _S717;
}

fn vertexEta( material_7 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S718 : bool = n_dot_v_0 < 0.0f;
    var _S719 : f32 = select(1.0f, material_7.ior, _S718);
    var _S720 : f32 = select(material_7.ior, 1.0f, _S718);
    return vec2<f32>(_S719, _S720);
}

fn neeDecision( material_8 : Material,  n_dot_v_1 : f32,  eta_i_5 : f32,  eta_o_5 : f32) -> bool
{
    var _S721 : f32 = fresnel(abs(n_dot_v_1), eta_i_5, eta_o_5);
    var _S722 : vec3<f32> = (mix((vec3<f32>(_S721)), (material_8.albedo), (material_8.metallic)));
    var _S723 : f32 = rgb_to_greyscale(_S722);
    var _S724 : f32 = max((1.0f - _S723) * (1.0f - material_8.metallic) * (1.0f - material_8.transmission), 0.0f);
    var _S725 : bool = _S724 > 0.03999999910593033f;
    var _S726 : bool;
    if(_S725)
    {
        _S726 = true;
    }
    else
    {
        _S726 = (material_8.roughness) > 0.20000000298023224f;
    }
    return _S726;
}

fn isTranslucent_0( material_9 : Material) -> bool
{
    var _S727 : f32 = rgb_to_greyscale(material_9.translucent);
    return _S727 > 0.0f;
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_7 : vec3<f32>,  g_n_0 : vec3<f32>,  material_10 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S728 : vec3<f32> = ((-(in_dir_4)));
    var _S729 : bool = (dot(g_n_0, _S728) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S729)
    {
        var _S730 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_7, material_10, eta_i_6, eta_o_6, u32(0), random_state_9);
        var _S731 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_7, material_10, eta_i_6, eta_o_6, u32(2), random_state_9);
        var _S732 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_7, material_10, eta_i_6, eta_o_6, u32(4), random_state_9);
        return _S730.throughput * vec3<f32>(_S730.pdf) + _S731.throughput * vec3<f32>(_S731.pdf) + _S732.throughput * vec3<f32>(_S732.pdf);
    }
    var _S733 : SampleBSDF = connectBSDF(in_dir_4, out_dir_1, n_7, material_10, eta_i_6, eta_o_6, u32(1), random_state_9);
    return _S733.throughput * vec3<f32>(_S733.pdf);
}

fn translucentCorrection( in_dir_5 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_8 : vec3<f32>,  g_n_1 : vec3<f32>,  material_11 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S734 : f32 = dot(n_8, out_dir_2);
    var _S735 : vec3<f32> = ((-(in_dir_5)));
    var _S736 : bool = (_S734 * dot(n_8, _S735)) < 0.0f;
    var _S737 : SampleBSDF = connectBSDF(in_dir_5, out_dir_2, n_8, material_11, eta_i_7, eta_o_7, u32(0), random_state_10);
    var _S738 : vec3<f32> = ((-(in_dir_5)));
    var _S739 : bool = (dot(g_n_1, _S738) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S740 : vec3<f32> = vec3<f32>(0.0f);
    var _S741 : vec3<f32> = _S737.throughput * vec3<f32>(_S737.pdf);
    var _S742 : f32 = select(1.0f, -1.0f, _S739);
    var _S743 : vec3<f32> = _S741 * vec3<f32>(_S742);
    var _S744 : vec3<f32> = select(_S740, _S743, _S736);
    return _S744;
}

fn translucentBSDF( in_dir_6 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_9 : vec3<f32>,  g_n_2 : vec3<f32>,  material_12 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S745 : vec3<f32> = BSDF(in_dir_6, out_dir_3, n_9, g_n_2, material_12, eta_i_8, eta_o_8, random_state_11);
    var _S746 : vec3<f32> = translucentCorrection(in_dir_6, out_dir_3, n_9, g_n_2, material_12, eta_i_8, eta_o_8, random_state_11);
    return _S745 + _S746;
}

fn lightBSDF_0( in_dir_7 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_13 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S747 : bool = !competing_0;
    var _S748 : bool;
    if(_S747)
    {
        _S748 = true;
    }
    else
    {
        _S748 = (light_0.density) == 0.0f;
    }
    if(_S748)
    {
        var _S749 : bool = isTranslucent_0(material_13);
        if(_S749)
        {
            var _S750 : vec3<f32> = translucentBSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_9, eta_o_9, random_state_12);
            return _S750 * light_0.radiance;
        }
        var _S751 : vec3<f32> = BSDF(in_dir_7, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_9, eta_o_9, random_state_12);
        return _S751 * light_0.radiance;
    }
    var _S752 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_7)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S753 : vec3<f32> = neeBSDF(in_dir_7, light_0.dir, smooth_n_5, material_13, eta_i_9, eta_o_9, _S752, light_0.density, true, random_state_12);
    return _S753 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_8 : vec3<f32>,  b_4 : vec3<f32>) -> vec3<f32>
{
    var _S754 : vec3<f32> = a_8 / b_4;
    var _S755 : vec3<f32> = vec3<f32>(0.0f);
    var _S756 : vec3<bool> = b_4 == _S755;
    var _S757 : vec3<f32> = select(_S754, _S755, _S756);
    return _S757;
}

fn withEnd( r_5 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_7 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_5;
    var _S758 : u32 = (insertBits((r_5.path), (end_0), (u32(0)), (u32(5))));
    var _S759 : u32 = (insertBits((_S758), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S759;
    candidate_2.f = f_7;
    return candidate_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S760 : f32 = sqrt(random_1_0);
    var _S761 : f32 = 6.28318548202514648f * random_2_0;
    var _S762 : f32 = _S760 * cos(_S761);
    var _S763 : f32 = _S760 * sin(_S761);
    var _S764 : f32 = sqrt(max(0.0f, 1.0f - _S762 * _S762 - _S763 * _S763));
    return vec3<f32>(_S762, _S764, _S763);
}

fn sampleBSDF( in_dir_8 : vec3<f32>,  n_10 : vec3<f32>,  material_14 : Material,  eta_i_10 : f32,  eta_o_10 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_1;
    var _S765 : vec3<f32> = ((-(in_dir_8)));
    var _S766 : f32 = dot(n_10, _S765);
    var _S767 : f32 = (sign((_S766)));
    var n_i_4 : vec3<f32> = n_10 * vec3<f32>(_S767);
    var _S768 : f32 = abs(_S766);
    var _S769 : f32 = material_14.roughness;
    var _S770 : f32 = _S769 * _S769;
    var _S771 : AnisotropicFrame = anisotropicFrame(material_14, n_i_4);
    var _S772 : vec3<f32> = sampleHalfVector(_S765, n_i_4, _S770, _S771, &(random_state_13));
    var _S773 : BSDFLobes = bsdfLobes(in_dir_8, _S765, n_i_4, _S772, material_14, eta_i_10, eta_o_10, _S771);
    var lobes_3 : BSDFLobes = _S773;
    var _S774 : f32 = translucentShare(material_14);
    lobes_3.translucent_share = _S774;
    var _S775 : vec3<f32> = vec3<f32>(1.0f);
    var _S776 : SampleBSDF = SampleBSDF_x24init_0(_S775, _S775, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S776;
    var _S777 : Random = pcg(random_state_13);
    random_state_13 = _S777.state;
    var _S778 : bool = (_S777.value) < (lobes_3.p_sheen_velvet);
    if(_S778)
    {
        var _S779 : Random = pcg(random_state_13);
        var _S780 : Random = pcg(_S779.state);
        sample_1.random_state = _S780.state;
        var _S781 : f32 = _S779.value;
        var _S782 : f32 = sqrt(max(0.0f, 1.0f - _S781 * _S781));
        var _S783 : f32 = 6.28318548202514648f * _S780.value;
        var _S784 : vec3<f32> = tangentToWorld(vec3<f32>(_S782 * cos(_S783), _S779.value, _S782 * sin(_S783)), n_i_4);
        sample_1.unit_direction = _S784;
        var _S785 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S770, material_14, lobes_3, u32(4));
        sample_1.throughput = _S785;
        var _S786 : f32 = lobeDensity(_S779.value, 0.0f, _S768, _S770, lobes_3, eta_i_10, eta_o_10, u32(4));
        sample_1.pdf = _S786;
        sample_1.lobe = u32(4);
        return sample_1;
    }
    var _S787 : f32 = _S777.value - lobes_3.p_sheen_velvet;
    var _S788 : bool = _S787 < (lobes_3.p_diffuse);
    if(_S788)
    {
        var _S789 : Random = pcg(random_state_13);
        var _S790 : Random = pcg(_S789.state);
        sample_1.random_state = _S790.state;
        var _S791 : vec3<f32> = sampleCosWeightedHemisphere(_S789.value, _S790.value);
        var _S792 : bool = _S787 < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S793 : f32 = _S791.y;
        var _S794 : f32 = - _S793;
        var _S795 : f32 = select(_S793, _S794, _S792);
        var _S796 : vec3<f32> = tangentToWorld(vec3<f32>(_S791.x, _S795, _S791.z), n_i_4);
        sample_1.unit_direction = _S796;
        var _S797 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S770, material_14, lobes_3, u32(0));
        sample_1.throughput = _S797;
        var _S798 : f32 = lobeDensity(_S795, 0.0f, _S768, _S770, lobes_3, eta_i_10, eta_o_10, u32(0));
        sample_1.pdf = _S798;
        sample_1.refracted = _S792;
        return sample_1;
    }
    var _S799 : bool = _S787 < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S799)
    {
        sample_1.unit_direction = lobes_3.refracted;
        var _S800 : f32 = lobeDensity(0.0f, dot(sample_1.unit_direction, _S772), _S768, _S770, lobes_3, eta_i_10, eta_o_10, u32(1));
        sample_1.pdf = _S800;
        var _S801 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S770, material_14, lobes_3, u32(1));
        sample_1.throughput = _S801;
        sample_1.random_state = random_state_13;
        sample_1.refracted = true;
        sample_1.lobe = u32(1);
        return sample_1;
    }
    var _S802 : vec3<f32> = (normalize((reflect(in_dir_8, _S772))));
    sample_1.unit_direction = _S802;
    var _S803 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S770, material_14, lobes_3, u32(2));
    sample_1.throughput = _S803;
    sample_1.random_state = random_state_13;
    sample_1.lobe = u32(2);
    var _S804 : f32 = lobeDensity(0.0f, 0.0f, _S768, _S770, lobes_3, eta_i_10, eta_o_10, u32(2));
    sample_1.pdf = _S804;
    return sample_1;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S805 : bool = pdf_6 > 0.0f;
    var _S806 : bool;
    if(_S805)
    {
        if(diffuse_0)
        {
            _S806 = true;
        }
        else
        {
            _S806 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S806 = false;
    }
    return _S806;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S807 : bool = pdf_7 > 0.0f;
    var _S808 : bool;
    if(_S807)
    {
        if(diffuse_1)
        {
            _S808 = true;
        }
        else
        {
            _S808 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S808 = false;
    }
    return _S808;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S809 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S809.x, max(_S809.y, _S809.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_6 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S810 : vec3<f32> = vec3<f32>(0.0f);
    var _S811 : Shift = Shift_x24init_0(_S810, 0.0f);
    var _S812 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S813 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S814 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S815 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S816 : bool = _S815 >= u32(3);
        var _S817 : u32 = select(u32(0), u32(1), _S816);
        var _S818 : u32 = _S812 + _S817;
        var _S819 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S818 > _S819;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S811;
    }
    var _S820 : u32 = _S813 - u32(1);
    var _S821 : bool = _S815 == u32(3);
    var _S822 : u32 = select(u32(0), u32(1), _S821);
    var _S823 : u32 = _S812 + _S822;
    var _S824 : bool = _S814 == u32(0);
    var _S825 : u32 = select(_S820, _S823, _S824);
    var _S826 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_6.rc.zw))), r_6.rc.x, r_6.rc.y, u32(0), 0.0f);
    var _S827 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S828 : Ray = Ray_x24init_0(dom_4.x1, _S827);
    var ray_2 : Ray = _S828;
    var hit_2 : Hit = dom_4.hit;
    var _S829 : vec3<f32> = vec3<f32>(1.0f);
    var _S830 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S810, _S810, _S810);
    var nee_vertex_0 : NEEVertex = _S830;
    var _S831 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S831;
    var _S832 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S810, 0.0f, vec4<u32>(u32(0)), _S810, _S810);
    var chain_0 : Reservoir = _S832;
    chain_0.seed = r_6.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S810;
    var reconnection_0 : vec3<f32> = _S810;
    var b_5 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S829;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S833 : bool = (hit_2.is_point_light) == u32(1);
        var _S834 : Surface = Surface_x24init_0(_S810, _S810, 0.0f, Material_x24init_0(_S810, _S810, 0.0f, 0.0f, 0.0f, 0.0f, _S810, _S829, 1.0f, _S810, _S810, 0.5f, 0.0f, 0.0f, _S810, 0.0f), false, u32(0));
        var _S835 : bool = !_S833;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_4 : Surface;
        if(_S835)
        {
            var _S836 : u32 = stream(r_6.seed, b_5);
            var _S837 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S836)));
            var surface_5 : Surface = facingRay_0(_S837, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S838 : vec3<f32> = beerLambert(hit_2.distance, surface_5.material.absorption);
                var _S839 : vec3<f32> = throughput_2 * _S838;
                front_n_0 = _S839;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S840 : bool = !surface_5.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_5.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S841 : bool = b_5 == u32(0);
            if(_S841)
            {
                var _S842 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S842;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S843 : vec3<f32> = front_n_0;
            var _S844 : f32 = geometry_density_2;
            scatter_0 = _S840;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S844;
            surface_4 = surface_5;
            front_n_0 = _S837.smooth_n;
            throughput_3 = _S843;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_4 = _S834;
            front_n_0 = _S810;
            throughput_3 = throughput_2;
        }
        var _S845 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S846 : Surface = surface_4;
        var _S847 : Surface = surface_4;
        var _S848 : f32 = dot(surface_4.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S849 : vec2<f32> = vertexEta(_S846.material, _S848);
        var _S850 : bool;
        if(scatter_0)
        {
            var _S851 : bool = neeDecision(_S846.material, _S848, _S849.x, _S849.y);
            _S850 = _S851;
        }
        else
        {
            _S850 = false;
        }
        var _S852 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S853 : vec3<f32> = _S846.material.emissive * vec3<f32>(max(_S852, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S833)
        {
            var _S854 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S854;
        }
        else
        {
            emission_0 = _S853;
        }
        var _S855 : f32 = rgb_to_greyscale(emission_0);
        var _S856 : bool = _S855 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S856)
        {
            var _S857 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S857);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S858 : bool;
        if(replay_0)
        {
            _S858 = _S814 == u32(1);
        }
        else
        {
            _S858 = false;
        }
        var _S859 : bool;
        if(_S858)
        {
            _S859 = b_5 > _S813;
        }
        else
        {
            _S859 = false;
        }
        var _S860 : bool;
        if(_S859)
        {
            _S860 = b_5 == _S812;
        }
        else
        {
            _S860 = false;
        }
        var _S861 : bool;
        if(_S860)
        {
            var _S862 : bool = _S815 == u32(1);
            if(_S862)
            {
                _S861 = true;
            }
            else
            {
                _S861 = _S815 == u32(2);
            }
        }
        else
        {
            _S861 = false;
        }
        if(_S861)
        {
            var _S863 : bool = _S833 != (_S815 == u32(2));
            if(_S863)
            {
                return _S811;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_6.jac), density_2 / r_6.jac);
        }
        var _S864 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S865 : bool = _S864 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S866 : u32 = (insertBits((u32(0)), (b_5), (u32(5)), (u32(5))));
        var _S867 : u32 = (insertBits((_S866), (u32(1)), (u32(10)), (u32(2))));
        var _S868 : u32 = (insertBits((_S867), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S869 : bool = prev_0.inside;
        var _S870 : u32 = select(u32(0), u32(1), _S869);
        var _S871 : u32 = (insertBits((_S868), (_S870), (u32(22)), (u32(1))));
        here_0.path = _S871;
        var _S872 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S872;
        var _S873 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S873;
        var _S874 : bool;
        if(replay_0)
        {
            _S874 = _S814 == u32(1);
        }
        else
        {
            _S874 = false;
        }
        var _S875 : bool;
        if(_S874)
        {
            _S875 = b_5 == _S813;
        }
        else
        {
            _S875 = false;
        }
        var _S876 : bool = b_5 == _S825;
        var _S877 : bool;
        if(_S876)
        {
            var _S878 : bool = !scatter_0;
            if(_S878)
            {
                _S877 = true;
            }
            else
            {
                var _S879 : bool = _S814 != u32(1);
                if(_S879)
                {
                    _S877 = _S814 != u32(3);
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
        var _S880 : bool;
        if(_S877)
        {
            _S880 = _S814 == u32(2);
        }
        else
        {
            _S880 = false;
        }
        var _S881 : bool;
        if(_S880)
        {
            _S881 = !_S845;
        }
        else
        {
            _S881 = false;
        }
        var _S882 : bool;
        if(_S881)
        {
            _S882 = _S815 != u32(4);
        }
        else
        {
            _S882 = false;
        }
        var _S883 : bool = _S813 == _S812;
        var _S884 : bool;
        if(_S883)
        {
            _S884 = _S815 == u32(0);
        }
        else
        {
            _S884 = false;
        }
        var _S885 : bool;
        if(_S884)
        {
            _S885 = (hit_2.instance_index) == (_S826.instance_index);
        }
        else
        {
            _S885 = false;
        }
        var _S886 : bool;
        if(_S885)
        {
            _S886 = (hit_2.triangle_index) == (_S826.triangle_index);
        }
        else
        {
            _S886 = false;
        }
        var _S887 : bool;
        if(_S886)
        {
            _S887 = _S845;
        }
        else
        {
            _S887 = false;
        }
        var _S888 : bool = select(_S882, _S887, _S875);
        var _S889 : bool;
        if(_S850)
        {
            _S889 = select(scatter_0, _S888, replay_0);
        }
        else
        {
            _S889 = false;
        }
        var _S890 : TreeSample = TreeSample_x24init_0(_S810, _S810, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S889)
        {
            var _S891 : Surface = surface_4;
            var _S892 : bool = isTranslucent_0(_S846.material);
            var _S893 : u32 = stream(r_6.seed, b_5 + u32(64));
            var _S894 : TreeSample = sampleLightTree_0(ray_2.origin, _S847.smooth_n, surface_4.geometry_n, surface_4.geometry_offset, _S892, _S893);
            var _S895 : bool = (any(((_S894.radiance) != _S810)));
            if(_S895)
            {
                var _S896 : f32 = _S849.x;
                var _S897 : f32 = _S849.y;
                var _S898 : u32 = (uniforms_uint.max_bounces);
                var _S899 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S894, _S847.smooth_n, _S891.geometry_n, _S846.material, _S896, _S897, b_5 < _S898, surface_4.random_state);
                lit_0 = _S899;
            }
            else
            {
                lit_0 = _S810;
            }
            light_1 = _S894;
        }
        else
        {
            light_1 = _S890;
            lit_0 = _S810;
        }
        var _S900 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S901 : bool;
        var _S902 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S875)
        {
            var _S903 : bool = (hit_2.instance_index) != (_S826.instance_index);
            if(_S903)
            {
                _S900 = true;
            }
            else
            {
                _S900 = (hit_2.triangle_index) != (_S826.triangle_index);
            }
            if(_S900)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S845;
            }
            if(wrong_side_0)
            {
                return _S811;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S883)
            {
                refracted_4 = _S815 == u32(1);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S883)
            {
                _S901 = _S815 == u32(0);
            }
            else
            {
                _S901 = false;
            }
            if(_S901)
            {
                var _S904 : bool = !_S850;
                if(_S904)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S905 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S905 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S811;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S883)
            {
                _S902 = _S815 == u32(4);
            }
            else
            {
                _S902 = false;
            }
            if(_S902)
            {
                var _S906 : bool = !_S850;
                if(_S906)
                {
                    return _S811;
                }
                var _S907 : f32 = environmentPdf_0(r_6.dir);
                var _S908 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_6.dir, surface_4, _S849, is_inside_4, _S907, surface_4.random_state);
                return Shift_x24init_0(throughput_5 * _S908 * r_6.radiance / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            var _S909 : u32 = (extractBits((r_6.path), (u32(21)), (u32(1))));
            var _S910 : bool = _S850 != (_S909 == u32(1));
            if(_S910)
            {
                return _S811;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S900 = _S876;
            }
            else
            {
                _S900 = false;
            }
            if(_S900)
            {
                var _S911 : bool = !scatter_0;
                if(_S911)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S912 : bool = _S814 != u32(1);
                    if(_S912)
                    {
                        wrong_side_0 = _S814 != u32(3);
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
                var _S913 : bool = _S814 == u32(2);
                if(_S913)
                {
                    _S858 = _S850;
                }
                else
                {
                    _S858 = false;
                }
                if(_S858)
                {
                    _S858 = !_S845;
                }
                else
                {
                    _S858 = false;
                }
                if(_S858)
                {
                    _S858 = _S815 == u32(4);
                }
                else
                {
                    _S858 = false;
                }
                if(_S858)
                {
                    var _S914 : u32 = stream(r_6.seed, b_5 + u32(256));
                    var _S915 : SkySample = sampleSky_0(ray_2, surface_4, _S849, is_inside_4, _S914, surface_4.random_state);
                    return Shift_x24init_0(throughput_3 * _S915.color, 1.0f);
                }
                if(_S913)
                {
                    is_inside_4 = _S850;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S845;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S916 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S917 : bool = !(_S916 > 0.0f);
                    if(_S917)
                    {
                        return _S811;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S824)
                {
                    is_inside_4 = _S815 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S833;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S824)
                {
                    is_inside_4 = _S815 == u32(1);
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
                    is_inside_4 = !_S845;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S811;
            }
            else
            {
                var _S918 : bool = !replay_0;
                if(_S918)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S919 : bool = b_5 > u32(0);
                    if(_S919)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S865)
                        {
                            var _S920 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S920;
                        }
                        else
                        {
                            if(_S845)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S921 : vec3<f32> = throughput_3 * emission_1;
                        var _S922 : Reservoir = withEnd(candidate_3, u32(1), b_5, _S921);
                        offer(&((*sel_4)), _S922, _S921 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S850)
                    {
                        var _S923 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S865)
                        {
                            var _S924 : vec3<f32> = safeDivide(_S923, chain_throughput_0);
                            candidate_4.radiance = _S924;
                        }
                        else
                        {
                            if(_S845)
                            {
                                candidate_4 = here_0;
                                var _S925 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S925;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S926 : u32 = (insertBits((u32(0)), (b_5 + u32(1)), (u32(5)), (u32(5))));
                                var _S927 : u32 = (insertBits((_S926), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S927;
                            }
                        }
                        var _S928 : Reservoir = withEnd(candidate_4, u32(0), b_5, _S923);
                        offer(&((*sel_4)), _S928, _S923 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S850)
                    {
                        var _S929 : bool = environmentMapped_0();
                        _S901 = _S929;
                    }
                    else
                    {
                        _S901 = false;
                    }
                    if(_S901)
                    {
                        var _S930 : u32 = (uniforms_uint.max_bounces);
                        _S902 = b_5 < _S930;
                    }
                    else
                    {
                        _S902 = false;
                    }
                    if(_S902)
                    {
                        var _S931 : u32 = stream(r_6.seed, b_5 + u32(256));
                        var _S932 : SkySample = sampleSky_0(ray_2, surface_4, _S849, is_inside_4, _S931, surface_4.random_state);
                        var _S933 : vec3<f32> = throughput_3 * _S932.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S865)
                        {
                            var _S934 : vec3<f32> = safeDivide(_S933, chain_throughput_0);
                            candidate_5.radiance = _S934;
                        }
                        else
                        {
                            if(_S845)
                            {
                                candidate_5 = here_0;
                                var _S935 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S935;
                                candidate_5.dir = _S932.dir;
                                candidate_5.radiance = _S932.radiance;
                            }
                            else
                            {
                                var _S936 : u32 = (insertBits((u32(0)), (b_5 + u32(1)), (u32(5)), (u32(5))));
                                var _S937 : u32 = (insertBits((_S936), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S937;
                            }
                        }
                        var _S938 : Reservoir = withEnd(candidate_5, u32(4), b_5, _S933);
                        offer(&((*sel_4)), _S938, _S933 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S939 : bool;
        var _S940 : bool;
        var _S941 : bool;
        var _S942 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S900 = _S876;
            }
            else
            {
                _S900 = false;
            }
            var _S943 : u32 = (extractBits((r_6.path), (u32(15)), (u32(3))));
            var _S944 : u32 = (extractBits((r_6.path), (u32(18)), (u32(3))));
            var _S945 : u32 = select(_S943, _S944, _S875);
            var refracted_5 : bool = _S945 == u32(1);
            var _S946 : SampleBSDF = SampleBSDF_x24init_0(_S810, _S810, u32(0), false, u32(0), 0.0f);
            var lobe_5 : SampleBSDF = _S946;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S900)
            {
                var _S947 : u32 = (extractBits((r_6.path), (u32(22)), (u32(1))));
                var _S948 : bool = is_inside_4 != (_S947 == u32(1));
                if(_S948)
                {
                    return _S811;
                }
                var _S949 : bool = _S814 == u32(1);
                if(_S949)
                {
                    var _S950 : vec3<f32> = (hitPosition((_S826)));
                    dir_11 = _S950;
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
                    var _S951 : bool = isTranslucent_0(_S846.material);
                    if(_S951)
                    {
                        wrong_side_0 = _S945 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S952 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S953 : vec3<f32> = select(r_6.dir, _S952, _S949);
                        refracted_4 = (dot(_S847.smooth_n, _S953) * _S848) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S949)
                {
                    var _S954 : vec3<f32> = ray_2.origin;
                    var _S955 : Surface = surface_4;
                    var _S956 : vec3<f32> = (vec3<f32>(0) - _S847.smooth_n);
                    var _S957 : bool = is_inside_4 != refracted_4;
                    var _S958 : vec3<f32> = select(_S847.smooth_n, _S956, _S957);
                    var _S959 : vec3<f32> = (normalize((dir_11 - (_S954 + vec3<f32>(_S955.geometry_offset) * _S958))));
                    reconnection_1 = _S959;
                }
                else
                {
                    reconnection_1 = r_6.dir;
                }
                var _S960 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, surface_4.geometry_n);
                if(_S960)
                {
                    return _S811;
                }
                var _S961 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S945;
                wrong_side_0 = false;
                reconnection_1 = _S961;
            }
            else
            {
                var _S962 : bool = !_S875;
                if(_S962)
                {
                    var _S963 : f32 = _S849.x;
                    var _S964 : f32 = _S849.y;
                    var _S965 : vec2<f32> = vec2<f32>(0.0f);
                    var _S966 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S847.smooth_n, _S846.material, _S963, _S964, surface_4.random_state, _S965);
                    var bsdf_sampled_0 : SampleBSDF = _S966;
                    var _S967 : Surface = surface_4;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_4.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S846.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S968 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S967.geometry_n, _S846.material, _S963, _S964, bsdf_sampled_0.random_state, _S965);
                        bsdf_sampled_0.unit_direction = _S968.unit_direction;
                        bsdf_sampled_0.refracted = _S968.refracted;
                        bsdf_sampled_0.throughput = _S968.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S969 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S967.geometry_n))) * _S967.geometry_n;
                            bsdf_sampled_0.unit_direction = _S969;
                        }
                    }
                    var _S970 : u32 = bsdf_sampled_0.lobe;
                    var _S971 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S972 : bool = bsdf_sampled_0.refracted;
                    lobe_5 = bsdf_sampled_0;
                    var _S973 : f32 = bsdf_sampled_0.pdf;
                    var _S974 : f32 = select(_S973, 0.0f, wrong_side_1);
                    lobe_5.pdf = _S974;
                    dir_11 = _S971;
                    lobe_index_0 = _S970;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S972;
                }
                else
                {
                    dir_11 = r_6.dir;
                    lobe_index_0 = _S945;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S900)
            {
                _S901 = true;
            }
            else
            {
                _S901 = _S875;
            }
            if(_S901)
            {
                var _S975 : SampleBSDF = connectBSDF(ray_2.unit_direction, dir_11, _S847.smooth_n, _S846.material, _S849.x, _S849.y, lobe_index_0, surface_4.random_state);
                lobe_5 = _S975;
            }
            var _S976 : bool = lobe_index_0 == u32(0);
            if(_S976)
            {
                _S902 = true;
            }
            else
            {
                _S902 = lobe_index_0 == u32(4);
            }
            var _S977 : bool = !_S902;
            if(_S977)
            {
                var _S978 : bool = (_S846.material.roughness) == 0.0f;
                if(_S978)
                {
                    _S939 = true;
                }
                else
                {
                    var _S979 : bool = lobe_index_0 == u32(1);
                    if(_S979)
                    {
                        _S939 = (_S849.x) == (_S849.y);
                    }
                    else
                    {
                        _S939 = false;
                    }
                }
            }
            else
            {
                _S939 = false;
            }
            var _S980 : bool = isTranslucent_0(_S846.material);
            if(_S980)
            {
                _S940 = _S976;
            }
            else
            {
                _S940 = false;
            }
            if(_S940)
            {
                _S941 = (dot(dir_11, surface_4.geometry_n)) < 0.0f;
            }
            else
            {
                _S941 = false;
            }
            if(_S850)
            {
                _S942 = !_S939;
            }
            else
            {
                _S942 = false;
            }
            var _S981 : bool;
            if(_S942)
            {
                _S981 = !wrong_side_0;
            }
            else
            {
                _S981 = false;
            }
            var _S982 : bool;
            if(_S981)
            {
                var _S983 : f32 = lobe_5.pdf;
                var _S984 : vec3<f32> = ray_2.origin;
                var _S985 : bool = isTranslucent_0(_S846.material);
                var _S986 : vec3<f32> = select(_S847.smooth_n, _S810, _S985);
                var _S987 : vec3<f32> = ray_2.origin;
                var _S988 : Surface = surface_4;
                var _S989 : vec3<f32> = (vec3<f32>(0) - _S847.smooth_n);
                var _S990 : vec3<f32> = select(_S847.smooth_n, _S989, _S941);
                var _S991 : NEEVertex = NEEVertex_x24init_0(false, _S983, _S984, _S986, _S987 + vec3<f32>(_S988.geometry_offset) * _S990);
                nee_vertex_0 = _S991;
            }
            else
            {
                var _S992 : bool = lobe_index_0 != u32(1);
                if(_S992)
                {
                    _S982 = true;
                }
                else
                {
                    _S982 = (_S849.x) != (_S849.y);
                }
                if(_S982)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S993 : bool = withinInverseFootprint(lobe_5.pdf, _S902, prev_0.cos, hit_2.distance, threshold_2);
            var _S994 : bool = roughLobe(lobe_5.pdf, _S902, _S846.material.roughness);
            var throughput_6 : vec3<f32>;
            if(_S875)
            {
                var _S995 : bool = !_S993;
                if(_S995)
                {
                    return _S811;
                }
                var _S996 : bool = _S815 != u32(1);
                if(_S996)
                {
                    _S982 = _S815 != u32(2);
                }
                else
                {
                    _S982 = false;
                }
                if(_S982)
                {
                    var _S997 : f32 = lobe_5.pdf;
                    var _S998 : f32 = select(0.0f, _S997, _S850);
                    var _S999 : f32 = escapeWeight_0(_S998, r_6.dir);
                    if(_S883)
                    {
                        is_inside_4 = _S821;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S1000 : f32 = select(1.0f, _S999, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_5.throughput * vec3<f32>(lobe_5.pdf)) * r_6.radiance * vec3<f32>(_S1000) / vec3<f32>(r_6.jac), density_3 * lobe_5.pdf / r_6.jac);
                }
                var _S1001 : vec3<f32> = throughput_4 * vec3<f32>(lobe_5.pdf);
                var _S1002 : f32 = density_3 * lobe_5.pdf;
                throughput_6 = _S1001;
                density_5 = _S1002;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S982 = b_5 <= _S825;
            }
            else
            {
                _S982 = false;
            }
            var _S1003 : bool;
            if(_S982)
            {
                _S1003 = _S845;
            }
            else
            {
                _S1003 = false;
            }
            var _S1004 : bool;
            if(_S1003)
            {
                _S1004 = _S993;
            }
            else
            {
                _S1004 = false;
            }
            var _S1005 : bool;
            if(_S1004)
            {
                _S1005 = true;
            }
            else
            {
                if(_S900)
                {
                    _S1005 = !_S994;
                }
                else
                {
                    _S1005 = false;
                }
            }
            if(_S1005)
            {
                return _S811;
            }
            var throughput_7 : vec3<f32>;
            if(_S900)
            {
                var _S1006 : vec3<f32> = throughput_6 * (lobe_5.throughput * vec3<f32>(lobe_5.pdf));
                var _S1007 : f32 = lobe_5.pdf;
                throughput_7 = _S1006;
                survival_probability_0 = _S1007;
            }
            else
            {
                var _S1008 : vec3<f32> = throughput_6 * max(lobe_5.throughput, _S810);
                throughput_7 = _S1008;
                survival_probability_0 = density_5;
            }
            var _S1009 : bool = !replay_0;
            var _S1010 : bool;
            if(_S1009)
            {
                _S1010 = !_S865;
            }
            else
            {
                _S1010 = false;
            }
            var _S1011 : bool;
            if(_S1010)
            {
                _S1011 = _S845;
            }
            else
            {
                _S1011 = false;
            }
            var _S1012 : bool;
            if(_S1011)
            {
                _S1012 = _S993;
            }
            else
            {
                _S1012 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S1012)
            {
                chain_0 = here_0;
                var _S1013 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1014 : u32 = select(u32(0), u32(1), _S850);
                var _S1015 : u32 = (insertBits((_S1013), (_S1014), (u32(21)), (u32(1))));
                chain_0.path = _S1015;
                var _S1016 : f32 = chain_0.jac * lobe_5.pdf;
                chain_0.jac = _S1016;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1017 : Vertex = Vertex_x24init_0(_S994, lobe_index_0, lobe_5.pdf, abs(dot(surface_4.geometry_n, dir_11)), is_inside_4);
            prev_0 = _S1017;
            var _S1018 : f32 = lobe_5.pdf;
            var _S1019 : bool = lobe_index_0 == u32(1);
            var _S1020 : bool;
            if(_S1019)
            {
                _S1020 = (_S849.x) == (_S849.y);
            }
            else
            {
                _S1020 = false;
            }
            var _S1021 : f32 = select(_S1018, sky_pdf_0, _S1020);
            var _S1022 : bool;
            if(refracted_4)
            {
                _S1022 = !_S941;
            }
            else
            {
                _S1022 = false;
            }
            var is_inside_5 : bool;
            if(_S1022)
            {
                var _S1023 : bool = !is_inside_4;
                is_inside_5 = _S1023;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_11;
            var _S1024 : Surface = surface_4;
            var _S1025 : vec3<f32> = (vec3<f32>(0) - _S847.smooth_n);
            var _S1026 : bool = is_inside_5 != _S941;
            var _S1027 : vec3<f32> = select(_S847.smooth_n, _S1025, _S1026);
            var _S1028 : vec3<f32> = ray_2.origin + vec3<f32>(_S1024.geometry_offset) * _S1027;
            ray_2.origin = _S1028;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1021;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        var _S1029 : bool = !replay_0;
        if(_S1029)
        {
            if(_S833)
            {
                var _S1030 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1031 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1032 : bool = _S1031 == u32(1);
                if(_S1032)
                {
                    var _S1033 : vec3<f32> = safeDivide(_S1030, chain_throughput_0);
                    candidate_6.radiance = _S1033;
                }
                var _S1034 : Reservoir = withEnd(candidate_6, u32(2), b_5, _S1030);
                offer(&((*sel_4)), _S1034, _S1030 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S833)
            {
                _S900 = true;
            }
            else
            {
                _S900 = scatter_0;
            }
            if(_S900)
            {
                var _S1035 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1035;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1036 : u32 = stream(r_6.seed, b_5 + u32(128));
            var _S1037 : Random = pcg(_S1036);
            var _S1038 : bool = survival_probability_0 < (_S1037.value);
            if(_S1038)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1039 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_5 >= _S1039;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1040 : f32 = density_5 * survival_probability_0;
            density_2 = _S1040;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1041 : Ray = ray_2;
        var _S1042 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S900 = _S876;
        }
        else
        {
            _S900 = false;
        }
        if(_S900)
        {
            wrong_side_0 = _S814 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1043 : f32 = select(4.294967296e+09f, _S1042, wrong_side_0);
        var _S1044 : Hit = (traverseInstanceBVH((_S1041), (_S835), (_S1043)));
        hit_2 = _S1044;
        if(replay_0)
        {
            refracted_4 = _S876;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S901 = _S814 == u32(1);
        }
        else
        {
            _S901 = false;
        }
        if(_S901)
        {
            _S902 = (hit_2.instance_index) == (_S826.instance_index);
        }
        else
        {
            _S902 = false;
        }
        if(_S902)
        {
            _S939 = (hit_2.triangle_index) == (_S826.triangle_index);
        }
        else
        {
            _S939 = false;
        }
        if(_S939)
        {
            hit_2.uv = _S826.uv;
            var _S1045 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1045;
        }
        if(replay_0)
        {
            _S940 = _S876;
        }
        else
        {
            _S940 = false;
        }
        if(_S940)
        {
            _S941 = _S814 == u32(3);
        }
        else
        {
            _S941 = false;
        }
        if(_S941)
        {
            _S942 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S942 = false;
        }
        if(_S942)
        {
            return _S811;
        }
        var _S1046 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1046)
        {
            var _S1047 : bool = !nee_vertex_0.none;
            var _S1048 : f32 = select(0.0f, sky_pdf_0, _S1047);
            var _S1049 : f32 = escapeWeight_0(_S1048, ray_2.unit_direction);
            var _S1050 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1051 : vec3<f32> = throughput_2 * _S1050;
            if(replay_0)
            {
                if(_S876)
                {
                    is_inside_4 = _S814 == u32(3);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(_S1051 * vec3<f32>(_S1049) / vec3<f32>(r_6.jac), density_2 / r_6.jac);
                }
                if(_S824)
                {
                    is_inside_4 = _S821;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = b_5 == _S812;
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
                    return Shift_x24init_0(_S1051 * vec3<f32>(_S1049), 1.0f);
                }
                return _S811;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1052 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1053 : bool = _S1052 == u32(1);
            if(_S1053)
            {
                var _S1054 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1055 : bool = _S1054 == b_5;
                var _S1056 : f32 = select(_S1049, 1.0f, _S1055);
                var _S1057 : vec3<f32> = safeDivide(_S1051 * vec3<f32>(_S1056), chain_throughput_0);
                candidate_7.radiance = _S1057;
            }
            else
            {
                var _S1058 : bool = prev_0.rough;
                if(_S1058)
                {
                    var _S1059 : u32 = (insertBits((u32(0)), (b_5 + u32(1)), (u32(5)), (u32(5))));
                    var _S1060 : u32 = (insertBits((_S1059), (u32(3)), (u32(10)), (u32(2))));
                    var _S1061 : u32 = (insertBits((_S1060), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1062 : bool = prev_0.inside;
                    var _S1063 : u32 = select(u32(0), u32(1), _S1062);
                    var _S1064 : u32 = (insertBits((_S1061), (_S1063), (u32(22)), (u32(1))));
                    candidate_7.path = _S1064;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1065 : vec3<f32> = _S1051 * vec3<f32>(_S1049);
            var _S1066 : Reservoir = withEnd(candidate_7, u32(3), b_5, _S1065);
            offer(&((*sel_4)), _S1066, _S1065 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1067 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1067;
        var _S1068 : u32 = b_5 + u32(1);
        b_5 = _S1068;
    }
    return _S811;
}

fn shift_0( dom_5 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S1069 : vec3<f32> = vec3<f32>(0.0f);
    var _S1070 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1069, 0.0f, vec4<u32>(u32(0)), _S1069, _S1069), 0.0f, _S1069, u32(0));
    var sel_5 : Selection = _S1070;
    var _S1071 : bool = (r_7.w) <= 0.0f;
    if(_S1071)
    {
        return Shift_x24init_0(_S1069, 0.0f);
    }
    var _S1072 : Shift = walk_0(dom_5, r_7, true, 0.0f, &(sel_5));
    return _S1072;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1073 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1074 : bool = _S1073 != u32(4294967295);
    if(_S1074)
    {
        var _S1075 : vec2<i32> = vec2<i32>((vec2<u32>(_S1073, (_S1073 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1076 : vec3<f32> = vec3<f32>(0.0f);
        var _S1077 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1076, _S1076, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1076, 0.0f, vec4<u32>(u32(0)), _S1076, _S1076));
        var shift_job_0 : ShiftJob = _S1077;
        var _S1078 : u32 = (_S1073 >> (u32(28)));
        var _S1079 : bool = spatialJob_0(_S1075, _S1078, &(shift_job_0));
        var _S1080 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1075), (_S1078), (vec4<u32>((bitcast<vec3<u32>>((_S1080.f))), (bitcast<u32>((_S1080.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1081 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1082 : array<u32, i32(3)>;
    spatialBins_0(_S1081, &(_S1082));
    var _S1083 : array<u32, i32(3)> = _S1082;
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
        var _S1084 : bool = (_S1083[t_16]) == u32(40);
        if(_S1084)
        {
            textureStore(shift_data_out, (_S1081), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1081, _S1083, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1085 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1085));
    countShifts_0(_S1085, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1086 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1087 : bool = _S1086 != u32(4294967295);
    if(_S1087)
    {
        var _S1088 : vec2<i32> = vec2<i32>((vec2<u32>(_S1086, (_S1086 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1089 : vec3<f32> = vec3<f32>(0.0f);
        var _S1090 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1089, _S1089, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1089, 0.0f, vec4<u32>(u32(0)), _S1089, _S1089));
        var shift_job_1 : ShiftJob = _S1090;
        var _S1091 : u32 = (_S1086 >> (u32(28)));
        var _S1092 : bool = temporalJob_0(_S1088, _S1091, &(shift_job_1));
        var _S1093 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1088), (_S1091), (vec4<u32>((bitcast<vec3<u32>>((_S1093.f))), (bitcast<u32>((_S1093.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1094 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1095 : array<u32, i32(3)>;
    temporalBins_0(_S1094, &(_S1095));
    var _S1096 : array<u32, i32(3)> = _S1095;
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
        var _S1097 : bool = (_S1096[t_18]) == u32(40);
        if(_S1097)
        {
            textureStore(temporal_shifts_out, (_S1094), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1094, _S1096, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1098 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1098));
    countShifts_0(_S1098, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1099 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1099;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1100 : f32 = c_3 * p_c_1;
    var _S1101 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1100 / (_S1100 + c_t_0 * g_previous_0), _S1101 / (_S1101 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1102 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1103 : vec3<f32> = vec3<f32>(0.0f);
    var _S1104 : Domain = Domain_x24init_0(_S1103, _S1103, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1104;
    var _S1105 : bool = (currentDomain((_S1102), &(dom_6)));
    var _S1106 : bool = !_S1105;
    if(_S1106)
    {
        storeReservoir(reservoir_temp_out, (_S1102), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1103, 0.0f, vec4<u32>(u32(0)), _S1103, _S1103)), (dom_6.hit));
        return;
    }
    var _S1107 : Reservoir = (loadReservoir(reservoir_initial, (_S1102)));
    var _S1108 : vec2<i32> = temporalNeighbor_0(_S1102, dom_6);
    var _S1109 : bool = (_S1108.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1109)
    {
        var _S1110 : Reservoir = (loadReservoir(reservoir_prev, (_S1108)));
        var _S1111 : vec4<u32> = (textureLoad(duplication, (_S1108), 0, 0));
        var _S1112 : f32 = (bitcast<f32>((_S1111.x)));
        var _S1113 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1114 : bool = _S1113 == u32(1);
        var _S1115 : f32 = select(0.0f, _S1112, _S1114);
        var _S1116 : f32 = confidenceCap(_S1115);
        var _S1117 : f32 = min(_S1110.c, _S1116);
        var _S1118 : vec4<u32> = (textureLoad(temporal_shifts, (_S1102), (u32(0)), 0));
        var _S1119 : vec4<f32> = (bitcast<vec4<f32>>((_S1118)));
        var _S1120 : vec4<f32> = vec4<f32>(_S1107.f, 1.0f);
        var _S1121 : Domain = (previousDomain((_S1108)));
        var _S1122 : bool = sameDomain_0(_S1121, dom_6);
        var _S1123 : bool = !_S1122;
        var to_previous_0 : vec4<f32>;
        if(_S1123)
        {
            var _S1124 : vec4<u32> = (textureLoad(temporal_shifts, (_S1102), (u32(1)), 0));
            var _S1125 : vec4<f32> = (bitcast<vec4<f32>>((_S1124)));
            to_previous_0 = _S1125;
        }
        else
        {
            to_previous_0 = _S1120;
        }
        var _S1126 : f32 = rgb_to_greyscale(_S1107.f);
        var _S1127 : f32 = rgb_to_greyscale(_S1110.f);
        var _S1128 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1103, 0.0f, vec4<u32>(u32(0)), _S1103, _S1103), 0.0f, _S1103, u32(0));
        var sel_6 : Selection = _S1128;
        var _S1129 : u32 = (uniforms_uint.frame);
        var _S1130 : u32 = hash(_S1129);
        var _S1131 : u32 = global_invocation_id_7.x;
        var _S1132 : vec2<u32> = (uniforms_uint.render_size);
        var _S1133 : u32 = stream(_S1130, _S1131 + _S1132.x * global_invocation_id_7.y);
        var _S1134 : u32 = stream(_S1133, u32(194));
        sel_6.random_state = _S1134;
        var _S1135 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1136 : vec3<f32> = _S1119.xyz;
        var _S1137 : f32 = rgb_to_greyscale(_S1136);
        var _S1138 : vec2<f32> = temporalWeights(_S1107.c, _S1126, _S1117, _S1127, _S1135, _S1137);
        offerShifted(&(sel_6), _S1107, Shift_x24init_0(_S1107.f, 1.0f), _S1138.x);
        offerShifted(&(sel_6), _S1110, Shift_x24init_0(_S1136, _S1119.w), _S1138.y);
        var _S1139 : Reservoir = finalize(sel_6, _S1107.c + _S1117);
        r_8 = _S1139;
    }
    else
    {
        r_8 = _S1107;
    }
    storeReservoir(reservoir_temp_out, (_S1102), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1140 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1141 : vec3<f32> = vec3<f32>(0.0f);
    var _S1142 : Domain = Domain_x24init_0(_S1141, _S1141, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1142;
    var _S1143 : bool = (currentDomain((_S1140), &(dom_7)));
    var _S1144 : bool = !_S1143;
    if(_S1144)
    {
        storeReservoir(reservoir_initial_out, (_S1140), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1141, 0.0f, vec4<u32>(u32(0)), _S1141, _S1141)), (dom_7.hit));
        return;
    }
    var _S1145 : u32 = (uniforms_uint.frame);
    var _S1146 : u32 = hash(_S1145);
    var _S1147 : u32 = global_invocation_id_8.x;
    var _S1148 : vec2<u32> = (uniforms_uint.render_size);
    var _S1149 : u32 = stream(_S1146, _S1147 + _S1148.x * global_invocation_id_8.y);
    var _S1150 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1141, 0.0f, vec4<u32>(u32(0)), _S1141, _S1141);
    var _S1151 : Selection = Selection_x24init_0(_S1150, 0.0f, _S1141, u32(0));
    var initial_0 : Selection = _S1151;
    var _S1152 : u32 = stream(_S1149, u32(193));
    initial_0.random_state = _S1152;
    var i_4 : u32 = u32(0);
    loop
    {
        var _S1153 : u32 = (uniforms_uint.samples);
        if(i_4 < _S1153)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1150;
        var _S1154 : u32 = stream(_S1149, i_4);
        r_9.seed = _S1154;
        var _S1155 : u32 = (uniforms_uint.samples);
        var _S1156 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1155), &(initial_0));
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    var _S1157 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1140), (_S1157), (dom_7.hit));
    return;
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S1158 : Random = pcg(state_2);
    var _S1159 : Random = pcg(_S1158.state);
    var _S1160 : f32 = 6.28318548202514648f * _S1158.value;
    var _S1161 : f32 = sqrt(-2.0f * clamp(log(_S1159.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1159.state, _S1161 * cos(_S1160));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1162 : RandomSphere;
    _S1162.state = state_3;
    _S1162.value = value_1;
    return _S1162;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S1163 : Random = normal_distribution(state_4);
    var _S1164 : Random = normal_distribution(_S1163.state);
    var _S1165 : Random = normal_distribution(_S1164.state);
    var _S1166 : vec3<f32> = (normalize((vec3<f32>(_S1163.value, _S1164.value, _S1165.value))));
    return RandomSphere_x24init_0(_S1165.state, _S1166);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_11 : vec3<f32>) -> mat3x3<f32>
{
    var _S1167 : vec3<f32> = p1_0 - p0_0;
    var _S1168 : vec3<f32> = p2_0 - p0_0;
    var _S1169 : vec2<f32> = uv1_0 - uv0_0;
    var _S1170 : vec2<f32> = uv2_0 - uv0_0;
    var _S1171 : f32 = _S1169.x;
    var _S1172 : f32 = _S1170.y;
    var _S1173 : f32 = _S1169.y;
    var _S1174 : f32 = _S1170.x;
    var _S1175 : f32 = _S1171 * _S1172 - _S1173 * _S1174;
    var _S1176 : f32 = 1.0f / _S1175;
    var _S1177 : vec3<f32> = vec3<f32>(_S1176);
    var t_20 : vec3<f32> = (_S1167 * vec3<f32>(_S1172) - _S1168 * vec3<f32>(_S1173)) * _S1177;
    var _S1178 : vec3<f32> = (_S1168 * vec3<f32>(_S1171) - _S1167 * vec3<f32>(_S1174)) * _S1177;
    var t_21 : vec3<f32> = (normalize((t_20 - n_11 * vec3<f32>(dot(n_11, t_20)))));
    var _S1179 : bool = (dot(cross(n_11, t_21), _S1178)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1179)
    {
        var _S1180 : vec3<f32> = ((-(t_21)));
        t_22 = _S1180;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1181 : vec3<f32> = cross(n_11, t_22);
    return mat3x3<f32>(t_22, _S1181, n_11);
}

fn tangentToWorldNormalMap( v_4 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_4)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1182 : vec3<f32> = t1_0 - t0_0;
    var _S1183 : vec3<f32> = t2_2 - t0_0;
    var _S1184 : vec3<f32> = t2_2 - t1_0;
    var _S1185 : f32 = min(length(_S1182), min(length(_S1183), length(_S1184)));
    var _S1186 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1187 : vec3<f32> = (normalize((n0_0)));
    var _S1188 : f32 = dot(geometry_n_5, _S1187);
    var _S1189 : vec3<f32> = (normalize((n1_0)));
    var _S1190 : f32 = dot(geometry_n_5, _S1189);
    var _S1191 : vec3<f32> = (normalize((n2_0)));
    var _S1192 : vec3<f32> = acos(abs(vec3<f32>(_S1188, _S1190, dot(geometry_n_5, _S1191))));
    var _S1193 : vec3<f32> = clamp(tan(_S1192), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1186 * _S1193, uvw_0), 0.0f, _S1185 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_12 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S1194 : vec3<f32> = ((-(dir_12)));
    var _S1195 : f32 = (sign((dot(n_12, _S1194))));
    var _S1196 : vec3<f32> = n_12 * vec3<f32>(_S1195);
    var _S1197 : AnisotropicFrame = anisotropicFrame(material_15, _S1196);
    var _S1198 : bool = (_S1197.alphas.x) > 0.0f;
    if(_S1198)
    {
        var _S1199 : f32 = material_15.transmission * (1.0f - material_15.metallic);
        var _S1200 : vec3<f32> = ((-(_S1196)));
        var _S1201 : vec3<f32> = anisotropicLocal(dir_12, _S1197.tangent, _S1200);
        var _S1202 : f32 = anisotropicG1(_S1201, _S1197.alphas);
        return vec3<f32>((_S1199 * _S1202)) * material_15.albedo;
    }
    var _S1203 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S1204 : f32 = material_15.roughness;
    var _S1205 : f32 = smithG1(_S1204 * _S1204, abs(dot(n_12, dir_12)));
    return vec3<f32>((_S1203 * _S1205)) * material_15.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_13 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1206 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S1207 : vec3<f32> = straightThrough(toward_1, n_13, material_16);
        _S1206 = _S1207;
    }
    else
    {
        _S1206 = vec3<f32>(0.0f);
    }
    return _S1206 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1208 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1208;
}

fn shift_hook( dom_9 : Domain,  r_11 : Reservoir) -> Shift
{
    var _S1209 : Shift = shift_0(dom_9, r_11);
    return _S1209;
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

