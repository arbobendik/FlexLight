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

struct SheenProfile
{
     on : bool,
     albedo : f32,
};

fn SheenProfile_x24init_0( on_0 : bool,  albedo_0 : f32) -> SheenProfile
{
    var _S247 : SheenProfile;
    _S247.on = on_0;
    _S247.albedo = albedo_0;
    return _S247;
}

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

var<private> VELVET_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f );
var<private> SHEEN_ALBEDO_0 : array<f32, i32(576)> = array<f32, i32(576)>( 0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f );
fn sheenProfile( v_1 : vec3<f32>,  n_i_1 : vec3<f32>,  material_1 : Material) -> SheenProfile
{
    var _S248 : SheenProfile = SheenProfile_x24init_0(false, 0.0f);
    var _S249 : f32 = rgb_to_greyscale(material_1.sheen);
    var _S250 : bool = _S249 > 0.0f;
    var profile_0 : SheenProfile;
    if(_S250)
    {
        var _S251 : f32 = clamp(sqrt(max(dot(n_i_1, v_1), 0.0f)), 0.0f, 1.0f) * 23.0f;
        var _S252 : u32 = min(u32(_S251), u32(22));
        var _S253 : f32 = sqrt(0.05000000074505806f);
        var _S254 : f32 = sqrt(0.10000000149011612f);
        var _S255 : bool = (material_1.velvet) > 0.0f;
        var _S256 : f32 = select(_S253, _S254, _S255);
        var _S257 : f32 = (clamp(sqrt(max(material_1.sheen_roughness, 0.0f)), _S256, 1.0f) - _S256) / (1.0f - _S256) * 23.0f;
        var _S258 : u32 = min(u32(_S257), u32(22));
        var _S259 : u32 = _S252 * u32(24) + _S258;
        var _S260 : f32 = _S251 - f32(_S252);
        var _S261 : f32 = _S257 - f32(_S258);
        if(_S255)
        {
            var _S262 : u32 = _S259 + u32(24);
            var _S263 : f32 = VELVET_ALBEDO_0[_S259] + (VELVET_ALBEDO_0[_S262] - VELVET_ALBEDO_0[_S259]) * _S260;
            var _S264 : u32 = _S259 + u32(1);
            var _S265 : f32 = VELVET_ALBEDO_0[_S264] + (VELVET_ALBEDO_0[_S262 + u32(1)] - VELVET_ALBEDO_0[_S264]) * _S260;
            var _S266 : SheenProfile = SheenProfile_x24init_0(true, _S263 + (_S265 - _S263) * _S261);
            profile_0 = _S266;
        }
        else
        {
            var _S267 : u32 = _S259 + u32(24);
            var _S268 : f32 = SHEEN_ALBEDO_0[_S259] + (SHEEN_ALBEDO_0[_S267] - SHEEN_ALBEDO_0[_S259]) * _S260;
            var _S269 : u32 = _S259 + u32(1);
            var _S270 : f32 = SHEEN_ALBEDO_0[_S269] + (SHEEN_ALBEDO_0[_S267 + u32(1)] - SHEEN_ALBEDO_0[_S269]) * _S260;
            var _S271 : SheenProfile = SheenProfile_x24init_0(true, exp(_S268 + (_S270 - _S268) * _S261));
            profile_0 = _S271;
        }
    }
    else
    {
        profile_0 = _S248;
    }
    return profile_0;
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
    var _S272 : BSDFLobes;
    _S272.v_dot_h = v_dot_h_0;
    _S272.n_dot_h = n_dot_h_0;
    _S272.refracted = refracted_1;
    _S272.F = F_0;
    _S272.F_greyscale = F_greyscale_0;
    _S272.reflect_weight = reflect_weight_0;
    _S272.diffuse_weight = diffuse_weight_0;
    _S272.refract_weight = refract_weight_0;
    _S272.p_diffuse = p_diffuse_0;
    _S272.p_reflect = p_reflect_0;
    _S272.p_refract = p_refract_0;
    _S272.translucent_share = translucent_share_0;
    _S272.sheen = sheen_0;
    _S272.p_sheen_velvet = p_sheen_velvet_0;
    _S272.view = view_1;
    _S272.tangent = tangent_1;
    _S272.alphas = alphas_1;
    _S272.visible = visible_0;
    return _S272;
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S273 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S274 : f32 = _S273.x;
    var _S275 : f32 = _S273.y;
    var _S276 : f32 = _S274 * _S274 + _S275 * _S275;
    const _S277 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S278 : vec3<f32> = vec3<f32>(- _S275, _S274, 0.0f);
    var _S279 : f32 = (inverseSqrt((_S276)));
    var _S280 : vec3<f32> = _S278 * vec3<f32>(_S279);
    var _S281 : bool = _S276 > 0.0f;
    var _S282 : vec3<f32> = select(_S277, _S280, _S281);
    var _S283 : vec3<f32> = cross(_S273, _S282);
    var _S284 : f32 = sqrt(U1_0);
    var _S285 : f32 = 6.28318548202514648f * U2_0;
    var _S286 : f32 = _S284 * cos(_S285);
    var t2_0 : f32 = _S284 * sin(_S285);
    var _S287 : f32 = 0.5f * (1.0f + _S273.z);
    var t2_1 : f32 = (1.0f - _S287) * sqrt(max(0.0f, 1.0f - _S286 * _S286)) + _S287 * t2_0;
    var _S288 : vec3<f32> = vec3<f32>(_S286) * _S282 + vec3<f32>(t2_1) * _S283;
    var _S289 : f32 = ((_S286));
    var _S290 : f32 = ((_S286));
    var _S291 : vec3<f32> = _S288 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S289 * _S290 - t2_1 * t2_1))) * _S273;
    var _S292 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S291.x, alpha_0 * _S291.y, max(0.0f, _S291.z)))));
    return _S292;
}

fn worldToTangent( v_2 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S293 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S293)
    {
        const _S294 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S294;
    }
    else
    {
        a_4 = a_3;
    }
    var _S295 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S296 : vec3<f32> = cross(n_3, _S295);
    return vec3<f32>(dot(v_2, _S295), dot(v_2, n_3), dot(v_2, _S296));
}

fn sampleHalfVector( v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S297 : Random = pcg((*random_state_0));
    var _S298 : Random = pcg(_S297.state);
    (*random_state_0) = _S298.state;
    var _S299 : f32 = frame_0.alphas.x;
    var _S300 : bool = _S299 > 0.0f;
    if(_S300)
    {
        var _S301 : vec3<f32> = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        var _S302 : f32 = frame_0.alphas.y;
        var _S303 : vec3<f32> = (normalize((vec3<f32>(_S299 * _S301.x, _S302 * _S301.y, _S301.z))));
        var _S304 : vec3<f32> = sampleGGXVNDF(_S303, 1.0f, _S297.value, _S298.value);
        var _S305 : vec3<f32> = (normalize((vec3<f32>(_S299 * _S304.x, _S302 * _S304.y, _S304.z))));
        return vec3<f32>(_S305.x) * frame_0.tangent + vec3<f32>(_S305.y) * cross(n_i_2, frame_0.tangent) + vec3<f32>(_S305.z) * n_i_2;
    }
    var _S306 : vec3<f32> = worldToTangent(v_3, n_i_2);
    var _S307 : vec3<f32> = sampleGGXVNDF(_S306.xzy, alpha_1, _S297.value, _S298.value);
    var _S308 : vec3<f32> = _S307.xzy;
    var _S309 : vec3<f32> = tangentToWorld(_S308, n_i_2);
    return _S309;
}

fn sampledHalf( in_dir_0 : vec3<f32>,  n_4 : vec3<f32>,  material_2 : Material,  random_state_1 : u32,  frame_1 : AnisotropicFrame) -> vec3<f32>
{
    var state_2 : u32 = random_state_1;
    var _S310 : vec3<f32> = ((-(in_dir_0)));
    var _S311 : f32 = (sign((dot(n_4, _S310))));
    var _S312 : f32 = material_2.roughness;
    var _S313 : vec3<f32> = sampleHalfVector(_S310, n_4 * vec3<f32>(_S311), _S312 * _S312, frame_1, &(state_2));
    return _S313;
}

fn refractedHalf( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  eta_i_0 : f32,  eta_o_0 : f32) -> vec3<f32>
{
    var _S314 : vec3<f32> = ((-(in_dir_1)));
    var _S315 : vec3<f32> = ((-(vec3<f32>(eta_i_0) * _S314 + vec3<f32>(eta_o_0) * out_dir_0)));
    var _S316 : vec3<f32> = (normalize((_S315)));
    var _S317 : f32 = (sign((dot(n_5, _S314))));
    var _S318 : f32 = (sign((dot(_S315, n_5 * vec3<f32>(_S317)))));
    return _S316 * vec3<f32>(_S318);
}

fn reflectedHalf( in_dir_2 : vec3<f32>,  out_dir_1 : vec3<f32>) -> vec3<f32>
{
    var _S319 : vec3<f32> = ((-(in_dir_2)));
    var _S320 : vec3<f32> = (normalize((_S319 + out_dir_1)));
    return _S320;
}

fn fresnel( cos_theta_0 : f32,  eta_i_1 : f32,  eta_o_1 : f32) -> f32
{
    var _S321 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S322 : f32 = eta_i_1 / eta_o_1 * _S321;
    var _S323 : bool = _S322 < 1.0f;
    var kr_0 : f32;
    if(_S323)
    {
        var _S324 : f32 = sqrt(max(0.0f, 1.0f - _S322 * _S322));
        var _S325 : f32 = eta_o_1 * cos_theta_0;
        var _S326 : f32 = eta_i_1 * _S324;
        var _S327 : f32 = (_S325 - _S326) / (_S325 + _S326);
        var _S328 : f32 = eta_i_1 * cos_theta_0;
        var _S329 : f32 = eta_o_1 * _S324;
        var _S330 : f32 = (_S328 - _S329) / (_S328 + _S329);
        var _S331 : f32 = (_S327 * _S327 + _S330 * _S330) / 2.0f;
        kr_0 = _S331;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S332 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S332 / (_S332 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S332)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S333 : f32 = alphas_3.x;
    var _S334 : f32 = h_0.x / _S333;
    var _S335 : f32 = alphas_3.y;
    var _S336 : f32 = h_0.y / _S335;
    var _S337 : f32 = h_0.z;
    var _S338 : f32 = _S334 * _S334 + _S336 * _S336 + _S337 * _S337;
    return 1.0f / max(3.14159274101257324f * _S333 * _S335 * _S338 * _S338, 1.17549435082228751e-38f);
}

fn bsdfLobes( in_dir_3 : vec3<f32>,  v_4 : vec3<f32>,  n_i_3 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_3 : Material,  eta_i_2 : f32,  eta_o_2 : f32,  frame_2 : AnisotropicFrame,  sheen_profile_0 : SheenProfile) -> BSDFLobes
{
    var _S339 : f32 = dot(ggx_n_0, v_4);
    var _S340 : f32 = dot(n_i_3, ggx_n_0);
    var _S341 : f32 = eta_i_2 / eta_o_2;
    var _S342 : vec3<f32> = (normalize((refract(in_dir_3, ggx_n_0, _S341))));
    var _S343 : f32 = min(sqrt(material_3.specular_level) * abs(eta_i_2 - eta_o_2) / (eta_i_2 + eta_o_2), 0.9999847412109375f);
    var _S344 : f32 = _S343 * _S343;
    var _S345 : f32 = (1.0f + _S343) / (1.0f - _S343);
    var _S346 : f32 = abs(_S339);
    var _S347 : bool = eta_i_2 > eta_o_2;
    var sheen_component_0 : f32;
    if(_S347)
    {
        sheen_component_0 = _S345;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S347)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S345;
    }
    var _S348 : f32 = fresnel(_S346, sheen_component_0, visible_1);
    var _S349 : bool = (eta_i_2 * eta_i_2 * (1.0f - _S339 * _S339)) >= (eta_o_2 * eta_o_2);
    var _S350 : vec3<f32>;
    if(_S349)
    {
        _S350 = vec3<f32>(1.0f);
    }
    else
    {
        var _S351 : vec3<f32> = material_3.specular_tint * vec3<f32>(_S344);
        _S350 = _S351 + (vec3<f32>(1.0f) - _S351) * vec3<f32>((_S348 - _S344)) / vec3<f32>((1.0f - _S344));
    }
    var _S352 : vec3<f32> = vec3<f32>(1.0f);
    var _S353 : vec3<f32> = vec3<f32>(0.0f);
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(sheen_profile_0.on)
    {
        var _S354 : f32 = min(sheen_profile_0.albedo, 1.0f);
        var _S355 : vec3<f32> = vec3<f32>(1.0f) - material_3.sheen * vec3<f32>(_S354);
        var _S356 : f32 = rgb_to_greyscale(material_3.sheen);
        var _S357 : f32 = _S356 * _S354;
        var _S358 : vec3<f32> = material_3.sheen / vec3<f32>(max(sheen_profile_0.albedo, 1.0f));
        scale_0 = _S355;
        sheen_component_0 = _S357;
        sheen_1 = _S358;
        view_2 = v_4;
    }
    else
    {
        scale_0 = _S352;
        sheen_component_0 = 0.0f;
        sheen_1 = _S353;
        view_2 = _S353;
    }
    var _S359 : vec3<f32> = (mix((_S350), (material_3.albedo), (material_3.metallic)));
    var F_1 : vec3<f32> = _S359 * scale_0;
    var _S360 : f32 = rgb_to_greyscale(F_1);
    var _S361 : f32 = 1.0f - material_3.metallic;
    var _S362 : vec3<f32> = vec3<f32>(1.0f) - _S350;
    var _S363 : vec3<f32> = vec3<f32>(((1.0f - material_3.transmission) * _S361)) * _S362 * scale_0;
    var _S364 : vec3<f32> = vec3<f32>((material_3.transmission * _S361)) * _S362 * scale_0;
    var _S365 : f32 = max(_S360, 0.0f);
    var _S366 : f32 = rgb_to_greyscale(_S363);
    var _S367 : f32 = max(_S366, 0.0f);
    var _S368 : f32 = rgb_to_greyscale(_S364);
    var _S369 : f32 = (sign((length(_S342))));
    var _S370 : f32 = max(_S368 * _S369, 0.0f);
    var _S371 : f32 = _S365 + _S367 + _S370;
    var _S372 : f32 = min(sheen_component_0, 1.0f);
    var _S373 : bool = sheen_component_0 > 0.0f;
    var _S374 : bool;
    if(_S373)
    {
        _S374 = !(_S371 > 0.0f);
    }
    else
    {
        _S374 = false;
    }
    var _S375 : f32 = select(_S372, 1.0f, _S374);
    var _S376 : f32 = (1.0f - _S375) / max(_S371, 0.0000152587890625f);
    var _S377 : f32 = _S367 * _S376;
    var _S378 : f32 = _S365 * _S376;
    var _S379 : f32 = _S370 * _S376;
    var _S380 : bool = (frame_2.alphas.x) > 0.0f;
    if(_S380)
    {
        var _S381 : vec3<f32> = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        var _S382 : f32 = anisotropicG1(_S381, frame_2.alphas);
        var _S383 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        var _S384 : f32 = anisotropicD(_S383, frame_2.alphas);
        var _S385 : f32 = _S382 * _S384;
        visible_1 = _S385;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S339, _S340, _S342, F_1, _S360, 1.0f, _S363, _S364, _S377, _S378, _S379, 0.0f, sheen_1, _S375, view_2, frame_2.tangent, frame_2.alphas, visible_1);
}

fn translucentShare( material_4 : Material) -> f32
{
    var _S386 : f32 = rgb_to_greyscale(material_4.translucent);
    var _S387 : f32 = rgb_to_greyscale(material_4.albedo);
    var _S388 : f32 = _S386 / (_S387 + _S386);
    var _S389 : bool = _S386 > 0.0f;
    var _S390 : f32 = select(0.0f, _S388, _S389);
    return _S390;
}

fn diffusePDF( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_2 : f32,  lobes_0 : BSDFLobes,  eta_i_3 : f32,  eta_o_3 : f32) -> f32
{
    var _S391 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    var _S392 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
    var _S393 : f32 = 1.0f - lobes_0.translucent_share;
    var _S394 : bool = n_i_dot_l_0 < 0.0f;
    var _S395 : f32 = select(_S393, lobes_0.translucent_share, _S394);
    var _S396 : f32 = _S392 * _S395;
    var _S397 : bool = (lobes_0.translucent_share) > 0.0f;
    var _S398 : f32 = select(_S391, _S396, _S397);
    var _S399 : bool = n_i_dot_v_0 > 0.0f;
    var _S400 : f32 = select(0.0f, _S398, _S399);
    return _S400;
}

fn diffuseBSDF( l_0 : vec3<f32>,  n_i_4 : vec3<f32>,  alpha_3 : f32,  material_5 : Material,  lobes_1 : BSDFLobes) -> vec3<f32>
{
    var _S401 : bool = (dot(n_i_4, l_0)) < 0.0f;
    var _S402 : vec3<f32> = select(material_5.albedo, material_5.translucent, _S401);
    var _S403 : f32 = 1.0f - lobes_1.translucent_share;
    var _S404 : f32 = select(_S403, lobes_1.translucent_share, _S401);
    var _S405 : vec3<f32> = _S402 / vec3<f32>(_S404);
    var _S406 : bool = (lobes_1.translucent_share) > 0.0f;
    var _S407 : vec3<f32> = select(material_5.albedo, _S405, _S406);
    return lobes_1.diffuse_weight * _S407 / vec3<f32>(lobes_1.p_diffuse);
}

fn smithG1( alpha_4 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S408 : f32 = alpha_4 * alpha_4;
    var _S409 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S408 + (1.0f - _S408) * n_dot_x_0 * n_dot_x_0));
    var _S410 : bool = alpha_4 > 0.0f;
    var _S411 : f32 = select(1.0f, _S409, _S410);
    return _S411;
}

fn trowbridgeReitz( alpha_5 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S412 : f32 = alpha_5 * alpha_5;
    var _S413 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S412 * n_dot_h_1 * n_dot_h_1;
    return _S412 / max(3.14159274101257324f * _S413 * _S413, 1.17549435082228751e-38f);
}

fn vndfPDF( n_i_dot_v_1 : f32,  alpha_6 : f32,  lobes_2 : BSDFLobes) -> f32
{
    var _S414 : f32 = smithG1(alpha_6, n_i_dot_v_1);
    var _S415 : f32 = _S414 * lobes_2.v_dot_h;
    var _S416 : f32 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    var _S417 : f32 = _S415 * _S416 / n_i_dot_v_1;
    var _S418 : bool = alpha_6 > 0.0f;
    var _S419 : bool;
    if(_S418)
    {
        _S419 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S419 = false;
    }
    if(_S419)
    {
        _S419 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S419 = false;
    }
    if(_S419)
    {
        _S419 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S419 = false;
    }
    var _S420 : f32 = select(0.0f, _S417, _S419);
    var _S421 : bool = (lobes_2.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S421)
    {
        var _S422 : f32 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        var _S423 : bool = (lobes_2.v_dot_h) > 0.0f;
        if(_S423)
        {
            _S419 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S419 = false;
        }
        if(_S419)
        {
            _S419 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S419 = false;
        }
        var _S424 : f32 = select(0.0f, _S422, _S419);
        pdf_h_0 = _S424;
    }
    else
    {
        pdf_h_0 = _S420;
    }
    return pdf_h_0;
}

fn refractPDF( n_i_dot_l_1 : f32,  l_dot_h_1 : f32,  n_i_dot_v_2 : f32,  alpha_7 : f32,  lobes_3 : BSDFLobes,  eta_i_4 : f32,  eta_o_4 : f32) -> f32
{
    var _S425 : f32 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    var _S426 : f32 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    var _S427 : f32 = lobes_3.p_refract * _S425 * eta_o_4 * eta_o_4 * abs(l_dot_h_1) / (_S426 * _S426);
    var _S428 : bool = eta_i_4 != eta_o_4;
    var _S429 : bool;
    if(_S428)
    {
        _S429 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S429 = false;
    }
    var _S430 : f32 = select(0.0f, _S427, _S429);
    return _S430;
}

fn refractBSDF( l_1 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_8 : f32,  material_6 : Material,  lobes_4 : BSDFLobes) -> vec3<f32>
{
    var _S431 : f32 = - dot(n_i_5, l_1);
    var _S432 : f32 = smithG1(alpha_8, max(_S431, 0.0f));
    var _S433 : bool = (lobes_4.alphas.x) > 0.0f;
    var G1_l_0 : f32;
    if(_S433)
    {
        var _S434 : vec3<f32> = ((-(n_i_5)));
        var _S435 : vec3<f32> = anisotropicLocal(l_1, lobes_4.tangent, _S434);
        var _S436 : f32 = anisotropicG1(_S435, lobes_4.alphas);
        G1_l_0 = _S436;
    }
    else
    {
        G1_l_0 = _S432;
    }
    return lobes_4.refract_weight * vec3<f32>(G1_l_0) * material_6.albedo / vec3<f32>(lobes_4.p_refract);
}

fn sheenVelvetPDF( n_i_dot_l_2 : f32,  l_dot_h_2 : f32,  n_i_dot_v_3 : f32,  alpha_9 : f32,  lobes_5 : BSDFLobes,  eta_i_5 : f32,  eta_o_5 : f32) -> f32
{
    var _S437 : f32 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    var _S438 : bool = n_i_dot_l_2 > 0.0f;
    var _S439 : bool;
    if(_S438)
    {
        _S439 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S439 = false;
    }
    var _S440 : f32 = select(0.0f, _S437, _S439);
    return _S440;
}

fn sheenVelvetBSDF( l_2 : vec3<f32>,  n_i_6 : vec3<f32>,  alpha_10 : f32,  material_7 : Material,  lobes_6 : BSDFLobes) -> vec3<f32>
{
    var _S441 : vec3<f32> = (normalize((l_2 + lobes_6.view)));
    var _S442 : f32 = dot(n_i_6, _S441);
    var _S443 : f32 = max(dot(n_i_6, l_2), 0.0f);
    var _S444 : f32 = max(dot(n_i_6, lobes_6.view), 0.0f);
    var _S445 : f32 = 1.0f / max(material_7.sheen_roughness, 0.05000000074505806f);
    var _S446 : f32 = 1.0f - _S442 * _S442;
    var _S447 : f32 = (2.0f + _S445) * pow(max(_S446, 0.0f), 0.5f * _S445) * 0.5f * 0.31830987334251404f / max(4.0f * (_S443 + _S444 - _S443 * _S444), 0.0000152587890625f);
    var _S448 : bool = (material_7.velvet) > 0.0f;
    var f_1 : f32;
    if(_S448)
    {
        var _S449 : f32 = max(material_7.sheen_roughness, 0.00999999977648258f);
        var _S450 : f32 = _S449 * _S449;
        var _S451 : f32 = max(_S446, 0.0000152587890625f);
        var _S452 : f32 = exp(- _S442 * _S442 / (_S451 * _S450)) / (3.14159274101257324f * _S450 * _S451 * _S451) * min(1.0f, 2.0f * _S442 * min(_S443, _S444) / max(abs(dot(_S441, lobes_6.view)), 0.0000152587890625f)) / max(4.0f * _S443 * _S444, 0.0000152587890625f);
        f_1 = _S452;
    }
    else
    {
        f_1 = _S447;
    }
    return lobes_6.sheen * vec3<f32>((f_1 * _S443 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet));
}

fn reflectPDF( n_i_dot_l_3 : f32,  l_dot_h_3 : f32,  n_i_dot_v_4 : f32,  alpha_11 : f32,  lobes_7 : BSDFLobes,  eta_i_6 : f32,  eta_o_6 : f32) -> f32
{
    var _S453 : f32 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    var _S454 : f32 = lobes_7.p_reflect * _S453 / (4.0f * lobes_7.v_dot_h);
    var _S455 : bool = _S453 > 0.0f;
    var _S456 : f32 = select(0.0f, _S454, _S455);
    return _S456;
}

fn reflectBSDF( l_3 : vec3<f32>,  n_i_7 : vec3<f32>,  alpha_12 : f32,  material_8 : Material,  lobes_8 : BSDFLobes) -> vec3<f32>
{
    var _S457 : f32 = dot(n_i_7, l_3);
    var _S458 : f32 = smithG1(alpha_12, max(_S457, 0.0f));
    var _S459 : bool = (lobes_8.alphas.x) > 0.0f;
    var G1_l_1 : f32;
    if(_S459)
    {
        var _S460 : vec3<f32> = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        var _S461 : f32 = anisotropicG1(_S460, lobes_8.alphas);
        G1_l_1 = _S461;
    }
    else
    {
        G1_l_1 = _S458;
    }
    return vec3<f32>((lobes_8.reflect_weight * G1_l_1)) * lobes_8.F / vec3<f32>(lobes_8.p_reflect);
}

fn BSDF( in_dir_4 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_6 : vec3<f32>,  material_9 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  refracted_2 : bool,  random_state_2 : u32,  throughputs_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_0 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var ggx_n_1 : vec3<f32>;
    var _S462 : vec3<f32> = ((-(in_dir_4)));
    var _S463 : f32 = dot(n_6, _S462);
    var _S464 : f32 = (sign((_S463)));
    var _S465 : vec3<f32> = n_6 * vec3<f32>(_S464);
    var _S466 : AnisotropicFrame = anisotropicFrame(material_9, _S465);
    var _S467 : f32 = dot(_S465, out_dir_2);
    var _S468 : f32 = material_9.roughness;
    var _S469 : f32 = _S468 * _S468;
    var _S470 : SheenProfile = sheenProfile(_S462, _S465, material_9);
    var _S471 : f32 = rgb_to_greyscale(material_9.translucent);
    var _S472 : bool = _S471 > 0.0f;
    var _S473 : bool = (dot(n_6, out_dir_2) * _S463) < 0.0f;
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
        var _S474 : vec3<f32> = vec3<f32>(0.0f);
        (*throughputs_0)[i_0] = _S474;
        (*pdfs_0)[i_0] = 0.0f;
        var i_1 : u32 = i_0 + u32(1);
        i_0 = i_1;
    }
    var _S475 : vec3<f32> = vec3<f32>(0.0f);
    var _S476 : BSDFLobes = BSDFLobes_x24init_0(0.0f, 0.0f, _S475, _S475, 0.0f, 0.0f, _S475, _S475, 0.0f, 0.0f, 0.0f, 0.0f, _S475, 0.0f, _S475, _S475, vec2<f32>(0.0f), 0.0f);
    var lobe_terms_0 : BSDFLobes = _S476;
    var half_of_0 : u32 = u32(4294967295);
    var ggx_n_2 : vec3<f32> = _S475;
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
        var _S477 : u32;
        if(i_0 == u32(3))
        {
            _S477 = u32(4);
        }
        else
        {
            _S477 = i_0;
        }
        var _S478 : bool = _S477 == u32(0);
        var _S479 : bool;
        if(_S478)
        {
            _S479 = _S472;
        }
        else
        {
            _S479 = false;
        }
        var _S480 : bool;
        if(_S479)
        {
            _S480 = _S473;
        }
        else
        {
            _S480 = _S477 == u32(1);
        }
        var _S481 : bool = _S480 != refracted_2;
        if(_S481)
        {
            ggx_n_1 = ggx_n_2;
            var i_2 : u32 = i_0 + u32(1);
            ggx_n_2 = ggx_n_1;
            i_0 = i_2;
            continue;
        }
        var _S482 : u32;
        if(_S477 == u32(4))
        {
            _S482 = u32(2);
        }
        else
        {
            _S482 = _S477;
        }
        var _S483 : bool = _S482 != half_of_0;
        var half_of_1 : u32;
        if(_S483)
        {
            var _S484 : bool = _S482 == u32(0);
            if(_S484)
            {
                var _S485 : vec3<f32> = sampledHalf(in_dir_4, n_6, material_9, random_state_2, _S466);
                ggx_n_1 = _S485;
            }
            else
            {
                var _S486 : bool = _S482 == u32(1);
                if(_S486)
                {
                    var _S487 : vec3<f32> = refractedHalf(in_dir_4, out_dir_2, n_6, eta_i_7, eta_o_7);
                    ggx_n_1 = _S487;
                }
                else
                {
                    var _S488 : vec3<f32> = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S488;
                }
            }
            var _S489 : vec3<f32> = ((-(in_dir_4)));
            var _S490 : BSDFLobes = bsdfLobes(in_dir_4, _S489, _S465, ggx_n_1, material_9, eta_i_7, eta_o_7, _S466, _S470);
            lobe_terms_0 = _S490;
            var _S491 : f32 = translucentShare(material_9);
            lobe_terms_0.translucent_share = _S491;
            half_of_1 = _S482;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S477)
        {
        case u32(0):
            {
                var _S492 : f32 = diffusePDF(_S467, 0.0f, abs(_S463), _S469, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(0)] = _S492;
                var _S493 : vec3<f32> = diffuseBSDF(out_dir_2, _S465, _S469, material_9, lobe_terms_0);
                (*throughputs_0)[i32(0)] = _S493;
            }
        case u32(1):
            {
                var _S494 : f32 = refractPDF(_S467, dot(out_dir_2, ggx_n_1), abs(_S463), _S469, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(1)] = _S494;
                var _S495 : vec3<f32> = refractBSDF(out_dir_2, _S465, _S469, material_9, lobe_terms_0);
                (*throughputs_0)[i32(1)] = _S495;
            }
        case u32(4):
            {
                var _S496 : f32 = sheenVelvetPDF(_S467, 0.0f, abs(_S463), _S469, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(3)] = _S496;
                var _S497 : vec3<f32> = sheenVelvetBSDF(out_dir_2, _S465, _S469, material_9, lobe_terms_0);
                (*throughputs_0)[i32(3)] = _S497;
            }
        default :
            {
                var _S498 : f32 = reflectPDF(_S467, 0.0f, abs(_S463), _S469, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[i32(2)] = _S498;
                var _S499 : vec3<f32> = reflectBSDF(out_dir_2, _S465, _S469, material_9, lobe_terms_0);
                (*throughputs_0)[i32(2)] = _S499;
            }
        }
        half_of_0 = half_of_1;
        var i_2 : u32 = i_0 + u32(1);
        ggx_n_2 = ggx_n_1;
        i_0 = i_2;
    }
    i_0 = u32(0);
    ggx_n_1 = _S475;
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S500 : bool = ((*pdfs_0)[i_0]) > 0.0f;
        if(_S500)
        {
            var f_2 : vec3<f32> = ggx_n_1 + (*throughputs_0)[i_0] * vec3<f32>((*pdfs_0)[i_0]);
            ggx_n_1 = f_2;
        }
        var i_3 : u32 = i_0 + u32(1);
        i_0 = i_3;
    }
    return ggx_n_1;
}

fn skyLobes_0( in_dir_5 : vec3<f32>,  dir_4 : vec3<f32>,  surface_1 : Surface,  eta_0 : vec2<f32>,  is_inside_2 : bool,  pdf_0 : f32,  random_state_3 : u32,  terms_0 : ptr<function, array<vec3<f32>, i32(4)>>,  pdfs_1 : ptr<function, array<f32, i32(4)>>) -> vec3<f32>
{
    var _S501 : bool = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    var _S502 : vec3<f32> = BSDF(in_dir_5, dir_4, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S501, random_state_3, &((*terms_0)), &((*pdfs_1)));
    var _S503 : vec3<f32> = vec3<f32>(0.0f);
    var i_4 : u32 = u32(0);
    var f_3 : vec3<f32> = _S503;
    loop
    {
        if(i_4 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S504 : bool = ((*pdfs_1)[i_4]) > 0.0f;
        if(_S504)
        {
            var _S505 : vec3<f32> = (*terms_0)[i_4] * vec3<f32>((*pdfs_1)[i_4]) / vec3<f32>(((*pdfs_1)[i_4] + pdf_0));
            (*terms_0)[i_4] = _S505;
            var f_4 : vec3<f32> = f_3 + (*terms_0)[i_4];
            f_3 = f_4;
        }
        var i_5 : u32 = i_4 + u32(1);
        i_4 = i_5;
    }
    return f_3;
}

fn skyBSDF( in_dir_6 : vec3<f32>,  dir_5 : vec3<f32>,  surface_2 : Surface,  eta_1 : vec2<f32>,  is_inside_3 : bool,  pdf_1 : f32,  random_state_4 : u32) -> vec3<f32>
{
    var terms_1 : array<vec3<f32>, i32(4)>;
    var pdfs_2 : array<f32, i32(4)>;
    var _S506 : vec3<f32> = skyLobes_0(in_dir_6, dir_5, surface_2, eta_1, is_inside_3, pdf_1, random_state_4, &(terms_1), &(pdfs_2));
    return _S506;
}

fn SkySample_x24init_0( dir_6 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S507 : SkySample;
    _S507.dir = dir_6;
    _S507.radiance = radiance_1;
    _S507.color = color_0;
    _S507.random_state = random_state_5;
    return _S507;
}

fn sampleSky_0( ray_0 : Ray,  surface_3 : Surface,  eta_2 : vec2<f32>,  is_inside_4 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S508 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S509 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S510 : vec2<u32> = _S508 - _S509;
    var _S511 : Random = pcg(init_random_state_0);
    var _S512 : Random = pcg(_S511.state);
    var _S513 : Random = pcg(_S512.state);
    var _S514 : Random = pcg(_S513.state);
    var _S515 : u32 = _S510.x;
    var _S516 : u32 = searchCDF_0(vec2<u32>(_S515, u32(0)), vec2<u32>(u32(0), u32(1)), _S510.y, _S511.value);
    var _S517 : u32 = searchCDF_0(vec2<u32>(u32(0), _S516), _S509, _S515, _S512.value);
    var _S518 : vec2<f32> = (vec2<f32>(f32(_S517), f32(_S516)) + vec2<f32>(_S513.value, _S514.value)) / vec2<f32>(_S510) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S519 : f32 = _S518.y;
    var _S520 : f32 = sin(_S519);
    var _S521 : f32 = _S518.x;
    var _S522 : vec3<f32> = vec3<f32>(_S520 * cos(_S521), cos(_S519), _S520 * sin(_S521));
    var _S523 : f32 = environmentPdf_0(_S522);
    var _S524 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S522, surface_3, eta_2, is_inside_4, _S523, lobe_state_0);
    var _S525 : bool = !(_S523 > 0.0f);
    var _S526 : bool;
    if(_S525)
    {
        _S526 = true;
    }
    else
    {
        _S526 = (all((_S524 == vec3<f32>(0.0f))));
    }
    if(_S526)
    {
        var _S527 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S522, _S527, _S527, _S514.state);
    }
    var _S528 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_3, is_inside_4, _S522);
    return SkySample_x24init_0(_S522, _S528, _S524 * _S528, _S514.state);
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
    var _S529 : TreeSample;
    _S529.dir = dir_7;
    _S529.radiance = radiance_2;
    _S529.density = density_0;
    _S529.random_state = random_state_6;
    return _S529;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S530 : f32 = importance(first_1, p_10, normal_3);
    var _S531 : f32 = importance(second_1, p_10, normal_3);
    var _S532 : vec2<f32> = vec2<f32>(_S530, _S531);
    var _S533 : bool = _S530 == 0.0f;
    var _S534 : bool;
    if(_S533)
    {
        _S534 = _S531 == 0.0f;
    }
    else
    {
        _S534 = false;
    }
    if(_S534)
    {
        return u32(2);
    }
    var _S535 : f32 = _S530 + _S531;
    var _S536 : bool = _S531 > 0.0f;
    if(_S536)
    {
        _S534 = ((*pick_0) * _S535) >= _S530;
    }
    else
    {
        _S534 = false;
    }
    var _S537 : u32 = select(u32(0), u32(1), _S534);
    var _S538 : f32 = min(((*pick_0) * _S535 - f32(_S537) * _S530) / _S532[_S537], 0.99999994039535522f);
    (*pick_0) = _S538;
    var _S539 : f32 = (*probability_3) * (_S532[_S537] / _S535);
    (*probability_3) = _S539;
    return _S537;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S540 : vec3<f32> = center_1 - p_11;
    var _S541 : f32 = radius_1 * radius_1 / dot(_S540, _S540);
    var _S542 : f32 = u1_0 * _S541 / (1.0f + sqrt(max(1.0f - _S541, 0.0f)));
    var _S543 : f32 = 2.0f * u1_0;
    var _S544 : bool = _S541 >= 1.0f;
    var _S545 : f32 = select(_S542, _S543, _S544);
    var _S546 : f32 = sqrt(max(_S545 * (2.0f - _S545), 0.0f));
    var _S547 : f32 = 6.28318548202514648f * u2_0;
    var _S548 : vec3<f32> = vec3<f32>(_S546 * cos(_S547), 1.0f - _S545, _S546 * sin(_S547));
    var _S549 : vec3<f32> = (normalize((_S540)));
    var _S550 : vec3<f32> = tangentToWorld(_S548, _S549);
    return _S550;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S551 : vec3<f32> = center_2 - ray_1.origin;
    var _S552 : f32 = dot(_S551, ray_1.unit_direction);
    var _S553 : f32 = dot(_S551, _S551) - _S552 * _S552;
    var _S554 : f32 = radius_3 * radius_3;
    var _S555 : bool = _S553 > _S554;
    if(_S555)
    {
        return 4.294967296e+09f;
    }
    var _S556 : f32 = sqrt(_S554 - _S553);
    var _S557 : f32 = _S552 - _S556;
    var _S558 : f32 = _S552 + _S556;
    var _S559 : bool = _S557 > 0.0000152587890625f;
    var _S560 : bool;
    if(_S559)
    {
        _S560 = _S557 < max_len_0;
    }
    else
    {
        _S560 = false;
    }
    if(_S560)
    {
        return _S557;
    }
    var _S561 : bool = _S558 > 0.0000152587890625f;
    if(_S561)
    {
        _S560 = _S558 < max_len_0;
    }
    else
    {
        _S560 = false;
    }
    if(_S560)
    {
        return _S558;
    }
    return 4.294967296e+09f;
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32) -> TreeSample
{
    var _S562 : Random = pcg(init_random_state_1);
    var _S563 : Random = pcg(_S562.state);
    var _S564 : Random = pcg(_S563.state);
    var _S565 : vec3<f32> = vec3<f32>(0.0f);
    var _S566 : TreeSample = TreeSample_x24init_0(_S565, _S565, 0.0f, _S564.state);
    var sample_0 : TreeSample = _S566;
    var _S567 : vec3<f32> = select(smooth_n_2, _S565, sided_0);
    var _S568 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var _S569 : vec3<f32> = origin_4 + _S568 * smooth_n_2;
    var pick_1 : f32 = _S562.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S570 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S570.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S571 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S572 : u32 = n_7 + u32(1);
        var _S573 : LightBounds = (lightBounds((_S572)));
        var _S574 : LightBounds = (lightBounds((_S571)));
        var _S575 : u32 = pickChild(_S573, _S574, origin_4, _S567, &(pick_1), &(probability_4));
        var _S576 : bool = _S575 > u32(1);
        if(_S576)
        {
            return sample_0;
        }
        var _S577 : bool = _S575 == u32(1);
        var _S578 : u32 = select(_S572, _S571, _S577);
        n_7 = _S578;
    }
    var _S579 : bool = n_7 == u32(0);
    var _S580 : bool;
    if(_S579)
    {
        var _S581 : LightBounds = (lightBounds((u32(0))));
        var _S582 : f32 = importance(_S581, origin_4, _S567);
        _S580 = !(_S582 > 0.0f);
    }
    else
    {
        _S580 = false;
    }
    if(_S580)
    {
        return sample_0;
    }
    var _S583 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S584 : bool = (_S583.x) == u32(2);
    var start_5 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S584)
    {
        var _S585 : Light = (lights[(_S583.y)]);
        if(sided_0)
        {
            var _S586 : f32 = (sign((dot(geometry_n_1, _S585.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S586);
            var _S587 : vec3<f32> = origin_4 + _S568 * lift_n_1;
            start_5 = _S587;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_5 = _S569;
            lift_n_0 = smooth_n_2;
        }
        var _S588 : bool = (_S585.variance) == 0.0f;
        if(_S588)
        {
            var _S589 : vec3<f32> = _S585.position - start_5;
            var _S590 : vec3<f32> = (normalize((_S589)));
            sample_0.dir = _S590;
            var _S591 : vec3<f32> = _S585.color * vec3<f32>(_S585.intensity) / vec3<f32>((dot(_S589, _S589) * probability_4));
            sample_0.radiance = _S591;
            shadow_1 = _S589;
        }
        else
        {
            var _S592 : vec3<f32> = sampleSphere(_S585.position, _S585.variance, start_5, _S563.value, _S564.value);
            sample_0.dir = _S592;
            var _S593 : f32 = sphereDensity(_S585.position, _S585.variance, start_5);
            var _S594 : f32 = probability_4 * _S593;
            sample_0.density = _S594;
            var _S595 : vec3<f32> = pointLightRadiance(_S585.color, _S585.intensity, _S585.variance);
            var _S596 : vec3<f32> = _S595 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S596;
            var _S597 : f32 = raySphere_0(_S585.position, _S585.variance, Ray_x24init_0(start_5, sample_0.dir), 4.294967296e+09f);
            var _S598 : vec3<f32> = sample_0.dir * vec3<f32>(_S597);
            shadow_1 = _S598;
        }
    }
    else
    {
        var _S599 : u32 = _S583.y;
        var _S600 : u32 = ((instance_uint[(_S599) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S601 : u32 = _S600 + _S583.z;
        var _S602 : mat3x3<f32> = (worldTriangle((_S599), (_S601)));
        var _S603 : f32 = sqrt(_S563.value);
        var _S604 : vec2<f32> = vec2<f32>(_S603 * (1.0f - _S564.value), _S603 * _S564.value);
        var _S605 : vec3<f32> = (((_S602) * (vec3<f32>(1.0f - _S603, _S604))));
        if(sided_0)
        {
            var _S606 : f32 = (sign((dot(geometry_n_1, _S605 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S606);
            var _S607 : vec3<f32> = origin_4 + _S568 * lift_n_2;
            start_5 = _S607;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S608 : bool = !((dot(smooth_n_2, _S605 - origin_4)) > 0.0f);
            if(_S608)
            {
                return sample_0;
            }
            start_5 = _S569;
            lift_n_0 = smooth_n_2;
        }
        var _S609 : Surface = (surfaceAt((Hit_x24init_0(_S604, _S599, _S601, u32(0), 0.0f)), (_S605), (_S564.state)));
        sample_0.random_state = _S609.random_state;
        var _S610 : vec3<f32> = _S605 - start_5;
        var _S611 : vec3<f32> = (normalize((_S610)));
        sample_0.dir = _S611;
        var _S612 : f32 = solidAngle(probability_4, cross(_S602[i32(1)] - _S602[i32(0)], _S602[i32(2)] - _S602[i32(0)]), _S610);
        sample_0.density = _S612;
        var _S613 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S609.smooth_n))));
        var _S614 : vec3<f32> = _S609.material.emissive * vec3<f32>(max(_S613, 0.0f));
        var _S615 : vec3<f32> = select(_S614, _S565, _S609.skip);
        var _S616 : vec3<f32> = _S615 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S616;
        shadow_1 = _S610;
    }
    var _S617 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1);
    var _S618 : vec3<f32> = sample_0.radiance * _S617;
    var _S619 : bool = (all((_S617 == _S565)));
    var _S620 : vec3<f32> = select(_S618, _S565, _S619);
    sample_0.radiance = _S620;
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
    var _S621 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S622 : bool = b_1 > 0.0f;
    var _S623 : f32 = select(1.0f, _S621, _S622);
    return _S623;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S624 : u32 = (lightSlot((hit_1)));
    var _S625 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S624, light_point_1);
    var _S626 : f32 = powerHeuristic(vertex_0.pdf, _S625);
    return _S626;
}

fn environment_0( dir_8 : vec3<f32>) -> vec3<f32>
{
    var _S627 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S628 : bool = (_S627.x) > u32(1);
    var _S629 : bool;
    if(_S628)
    {
        var _S630 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S629 = (_S630.y) > u32(1);
    }
    else
    {
        _S629 = false;
    }
    if(_S629)
    {
        var _S631 : vec3<f32> = (env_map_sample((dir_8)));
        return _S631;
    }
    var _S632 : vec3<f32> = (uniforms_float.ambient);
    return _S632;
}

fn environmentMapped_0() -> bool
{
    var _S633 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S634 : bool = (_S633.x) > u32(1);
    var _S635 : bool;
    if(_S634)
    {
        var _S636 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S635 = (_S636.y) > u32(1);
    }
    else
    {
        _S635 = false;
    }
    return _S635;
}

fn escapeWeight_0( pdf_2 : f32,  dir_9 : vec3<f32>) -> f32
{
    var _S637 : bool = pdf_2 <= 0.0f;
    var _S638 : bool;
    if(_S637)
    {
        _S638 = true;
    }
    else
    {
        var _S639 : bool = environmentMapped_0();
        _S638 = !_S639;
    }
    if(_S638)
    {
        return 1.0f;
    }
    var _S640 : f32 = environmentPdf_0(dir_9);
    return pdf_2 / (pdf_2 + _S640);
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S641 : vec2<u32> = global_invocation_id_1.xy;
    var _S642 : vec2<i32> = vec2<i32>(_S641 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S643 : vec2<i32> = _S642 + vec2<i32>(i32(i_6 % u32(24)), i32(i_6 / u32(24)));
        var _S644 : bool = (all((_S643 >= vec2<i32>(i32(0)))));
        var _S645 : bool;
        if(_S644)
        {
            var _S646 : vec2<u32> = (uniforms_uint.render_size);
            _S645 = (all((_S643 < vec2<i32>(_S646))));
        }
        else
        {
            _S645 = false;
        }
        if(_S645)
        {
            var _S647 : vec4<u32> = (textureLoad(reservoir_prev, (_S643), (u32(0)), 0));
            var _S648 : u32 = _S647.x;
            var _S649 : bool = (bitcast<f32>((_S647.z))) > 0.0f;
            var _S650 : u32 = select(u32(0), _S648, _S649);
            seed_1 = _S650;
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
    var _S651 : u32 = local_invocation_id_0.y;
    var _S652 : u32 = local_invocation_id_0.x;
    var _S653 : u32 = duplication_seeds_0[(_S651 + u32(8)) * u32(24) + _S652 + u32(8)];
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
            var _S654 : bool = (duplication_seeds_0[(_S651 + seed_1) * u32(24) + _S652 + x_1]) == _S653;
            var _S655 : u32 = select(u32(0), u32(1), _S654);
            var count_2 : u32 = count_1 + _S655;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S656 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S657 : bool = _S653 != u32(0);
    var _S658 : f32 = select(0.0f, _S656, _S657);
    textureStore(duplication_out, (vec2<i32>(_S641)), 0, (vec4<u32>((bitcast<u32>((_S658))), u32(0), u32(0), u32(0))));
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
    var _S659 : Selection;
    _S659.r = r_2;
    _S659.w_sum = w_sum_0;
    _S659.color = color_2;
    _S659.random_state = random_state_7;
    return _S659;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S660 : u32 = hash(index_0);
    var _S661 : u32 = hash((seed_2 ^ (_S660)));
    return _S661;
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
    var _S662 : Shift;
    _S662.f = f_5;
    _S662.jac = jac_1;
    return _S662;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S663 : f32 = rgb_to_greyscale(weight_0);
    var _S664 : bool = _S663 > 0.0f;
    var _S665 : bool;
    if(_S664)
    {
        _S665 = _S663 < 3.00000000549775576e+38f;
    }
    else
    {
        _S665 = false;
    }
    var _S666 : bool = !_S665;
    if(_S666)
    {
        return;
    }
    var _S667 : f32 = (*sel_0).w_sum + _S663;
    (*sel_0).w_sum = _S667;
    var _S668 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S668;
    var _S669 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S669.state;
    var _S670 : bool = (_S669.value * (*sel_0).w_sum) <= _S663;
    if(_S670)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_3 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_3;
    var _S671 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S671;
    var _S672 : f32 = r_3.jac * shifted_0.jac;
    candidate_1.jac = _S672;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_3.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_4 : Reservoir = sel_2.r;
    var _S673 : f32 = rgb_to_greyscale(r_4.f);
    var _S674 : f32 = sel_2.w_sum / _S673;
    var _S675 : bool = _S673 > 0.0f;
    var _S676 : f32 = select(0.0f, _S674, _S675);
    r_4.w = _S676;
    r_4.c = c_2;
    return r_4;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S677 : vec2<u32> = global_invocation_id_2.xy;
    var _S678 : vec2<i32> = vec2<i32>(_S677);
    var _S679 : vec3<f32> = vec3<f32>(0.0f);
    var _S680 : Domain = Domain_x24init_0(_S679, _S679, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S680;
    var _S681 : bool = (currentDomain((_S678), &(dom_3)));
    var _S682 : bool = !_S681;
    if(_S682)
    {
        storeReservoir(reservoir_prev_out, (_S678), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S679, 0.0f, vec4<u32>(u32(0)), _S679, _S679)), (dom_3.hit));
        var _S683 : vec2<f32> = vec2<f32>(_S677);
        var _S684 : vec2<u32> = (uniforms_uint.render_size);
        var _S685 : vec2<f32> = _S683 / vec2<f32>(_S684.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S686 : vec3<f32> = vec3<f32>(_S685, 1.0f);
        var _S687 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S688 : vec3<f32> = (normalize(((((_S687) * (_S686))))));
        var _S689 : vec3<f32> = environment_0(_S688);
        textureStore(compute_out, (_S678), (u32(0)), (vec4<f32>(_S689, 1.0f)));
        var _S690 : u32 = (uniforms_uint.is_temporal);
        var _S691 : bool = _S690 == u32(1);
        if(_S691)
        {
            textureStore(compute_out, (_S678), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S692 : Reservoir = (loadReservoir(reservoir_temp, (_S678)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S692.c;
    loop
    {
        var _S693 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S693)
        {
        }
        else
        {
            break;
        }
        var _S694 : vec2<i32> = partner_0(_S678, t_13);
        var neighbor_0 : Domain = _S680;
        var _S695 : bool = (currentDomain((_S694), &(neighbor_0)));
        if(_S695)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S696 : vec4<u32> = (textureLoad(reservoir_temp, (_S694), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S696.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S697 : f32 = _S692.c / max(count_3, 1.0f);
    var _S698 : f32 = rgb_to_greyscale(_S692.f);
    var _S699 : bool = count_3 == 0.0f;
    var _S700 : f32 = select(0.0f, 1.0f, _S699);
    var _S701 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S679, 0.0f, vec4<u32>(u32(0)), _S679, _S679), 0.0f, _S679, u32(0));
    var sel_3 : Selection = _S701;
    var _S702 : u32 = (uniforms_uint.frame);
    var _S703 : u32 = hash(_S702);
    var _S704 : u32 = global_invocation_id_2.x;
    var _S705 : vec2<u32> = (uniforms_uint.render_size);
    var _S706 : u32 = stream(_S703, _S704 + _S705.x * global_invocation_id_2.y);
    var _S707 : u32 = stream(_S706, u32(195));
    sel_3.random_state = _S707;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S700;
    loop
    {
        var _S708 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S708)
        {
        }
        else
        {
            break;
        }
        var _S709 : vec2<i32> = partner_0(_S678, t_13);
        var neighbor_dom_0 : Domain = _S680;
        var _S710 : bool = (currentDomain((_S709), &(neighbor_dom_0)));
        if(_S710)
        {
            var _S711 : Reservoir = (loadReservoir(reservoir_temp, (_S709)));
            var _S712 : vec4<u32> = (textureLoad(shift_data, (_S709), (t_13), 0));
            var _S713 : vec4<f32> = (bitcast<vec4<f32>>((_S712)));
            var _S714 : vec4<u32> = (textureLoad(shift_data, (_S678), (t_13), 0));
            var _S715 : vec4<f32> = (bitcast<vec4<f32>>((_S714)));
            var _S716 : f32 = pairShare(_S711.c, _S697, c_sum_1);
            var _S717 : bool = _S698 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S717)
            {
                var _S718 : f32 = rgb_to_greyscale(_S715.xyz);
                var _S719 : f32 = canonicalWeight(_S716, _S697, _S698, _S711.c, _S718);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S719;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S720 : vec3<f32> = _S713.xyz;
            var _S721 : Shift = Shift_x24init_0(_S720, _S713.w);
            var _S722 : f32 = rgb_to_greyscale(_S711.f);
            var _S723 : f32 = rgb_to_greyscale(_S720);
            var _S724 : f32 = neighborWeight(_S716, _S711.c, _S722, _S697, _S723);
            offerShifted(&(sel_3), _S711, _S721, _S724);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S692, Shift_x24init_0(_S692.f, 1.0f), canonical_mis_0);
    var _S725 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S678), (_S725), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S678), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S726 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S727 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S728 : f32 = (sign((dot(_S727, _S726.smooth_n))));
    var _S729 : vec3<f32> = _S726.material.emissive * vec3<f32>(max(_S728, 0.0f));
    var _S730 : vec3<f32> = select(_S729, _S679, _S726.skip);
    var _S731 : vec3<f32> = clamp(sel_3.color + _S730, _S679, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S678), (u32(0)), (vec4<f32>(_S731, 1.0f)));
    var _S732 : u32 = (uniforms_uint.is_temporal);
    var _S733 : bool = _S732 == u32(1);
    if(_S733)
    {
        textureStore(compute_out, (_S678), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_3 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_6 : vec3<f32>) -> NEEVertex
{
    var _S734 : NEEVertex;
    _S734.none = none_0;
    _S734.pdf = pdf_3;
    _S734.origin = origin_5;
    _S734.smooth_n = smooth_n_3;
    _S734.start = start_6;
    return _S734;
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
    var _S735 : Vertex;
    _S735.rough = rough_0;
    _S735.lobe = lobe_0;
    _S735.pdf = pdf_4;
    _S735.cos = cos_0;
    _S735.inside = inside_0;
    return _S735;
}

fn Material_x24init_0( albedo_1 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>,  velvet_0 : f32) -> Material
{
    var _S736 : Material;
    _S736.albedo = albedo_1;
    _S736.emissive = emissive_0;
    _S736.roughness = roughness_0;
    _S736.metallic = metallic_0;
    _S736.transmission = transmission_0;
    _S736.ior = ior_0;
    _S736.absorption = absorption_0;
    _S736.specular_tint = specular_tint_0;
    _S736.specular_level = specular_level_0;
    _S736.translucent = translucent_0;
    _S736.sheen = sheen_2;
    _S736.sheen_roughness = sheen_roughness_0;
    _S736.anisotropy = anisotropy_0;
    _S736.anisotropic_rotation = anisotropic_rotation_0;
    _S736.tangent = tangent_2;
    _S736.velvet = velvet_0;
    return _S736;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_10 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S737 : Surface;
    _S737.smooth_n = smooth_n_4;
    _S737.geometry_n = geometry_n_2;
    _S737.geometry_offset = geometry_offset_2;
    _S737.material = material_10;
    _S737.skip = skip_0;
    _S737.random_state = random_state_8;
    return _S737;
}

fn facingSign( transmission_1 : f32,  face_0 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S738 : bool = transmission_1 > 0.0f;
    var _S739 : bool;
    if(_S738)
    {
        _S739 = true;
    }
    else
    {
        _S739 = (dot(face_0, direction_0)) < 0.0f;
    }
    var _S740 : f32;
    if(_S739)
    {
        _S740 = 1.0f;
    }
    else
    {
        _S740 = -1.0f;
    }
    return _S740;
}

fn facingRay_0( surface_4 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S741 : f32 = facingSign(surface_4.material.transmission, surface_4.geometry_n, dir_10);
    var _S742 : vec3<f32> = vec3<f32>(_S741);
    return Surface_x24init_0(surface_4.smooth_n * _S742, surface_4.geometry_n * _S742, surface_4.geometry_offset, surface_4.material, surface_4.skip, surface_4.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S743 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S743));
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
    var _S744 : bool;
    if(open_0)
    {
        _S744 = prev_rough_0;
    }
    else
    {
        _S744 = false;
    }
    if(_S744)
    {
        _S744 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S744 = false;
    }
    return _S744;
}

fn vertexEta( material_11 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S745 : bool = n_dot_v_0 < 0.0f;
    var _S746 : f32 = select(1.0f, material_11.ior, _S745);
    var _S747 : f32 = select(material_11.ior, 1.0f, _S745);
    return vec2<f32>(_S746, _S747);
}

fn neeDecision( material_12 : Material,  n_dot_v_1 : f32,  eta_i_8 : f32,  eta_o_8 : f32) -> bool
{
    var _S748 : f32 = fresnel(abs(n_dot_v_1), eta_i_8, eta_o_8);
    var _S749 : vec3<f32> = (mix((vec3<f32>(_S748)), (material_12.albedo), (material_12.metallic)));
    var _S750 : f32 = rgb_to_greyscale(_S749);
    var _S751 : f32 = max((1.0f - _S750) * (1.0f - material_12.metallic) * (1.0f - material_12.transmission), 0.0f);
    var _S752 : bool = _S751 > 0.03999999910593033f;
    var _S753 : bool;
    if(_S752)
    {
        _S753 = true;
    }
    else
    {
        _S753 = (material_12.roughness) > 0.20000000298023224f;
    }
    return _S753;
}

fn isTranslucent_0( material_13 : Material) -> bool
{
    var _S754 : f32 = rgb_to_greyscale(material_13.translucent);
    return _S754 > 0.0f;
}

fn lightBSDF_0( in_dir_7 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  competing_0 : bool,  random_state_9 : u32) -> vec3<f32>
{
    var _S755 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_7)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var throughputs_1 : array<vec3<f32>, i32(4)>;
    var pdfs_3 : array<f32, i32(4)>;
    var _S756 : vec3<f32> = BSDF(in_dir_7, light_0.dir, smooth_n_5, material_14, eta_i_9, eta_o_9, _S755, random_state_9, &(throughputs_1), &(pdfs_3));
    var _S757 : bool = !competing_0;
    var _S758 : bool;
    if(_S757)
    {
        _S758 = true;
    }
    else
    {
        _S758 = (light_0.density) == 0.0f;
    }
    if(_S758)
    {
        return _S756 * light_0.radiance;
    }
    var _S759 : vec3<f32> = vec3<f32>(0.0f);
    var i_8 : u32 = u32(0);
    var weighted_0 : vec3<f32> = _S759;
    loop
    {
        if(i_8 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S760 : bool = (pdfs_3[i_8]) > 0.0f;
        if(_S760)
        {
            var _S761 : f32 = pdfs_3[i_8] / light_0.density;
            var weighted_1 : vec3<f32> = weighted_0 + throughputs_1[i_8] * vec3<f32>(pdfs_3[i_8]) / vec3<f32>((light_0.density * (1.0f + _S761 * _S761)));
            weighted_0 = weighted_1;
        }
        var i_9 : u32 = i_8 + u32(1);
        i_8 = i_9;
    }
    return weighted_0 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S762 : vec3<f32> = a_6 / b_2;
    var _S763 : vec3<f32> = vec3<f32>(0.0f);
    var _S764 : vec3<bool> = b_2 == _S763;
    var _S765 : vec3<f32> = select(_S762, _S763, _S764);
    return _S765;
}

fn withEnd( r_5 : Reservoir,  end_type_0 : u32,  end_0 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_5;
    var _S766 : u32 = (insertBits((r_5.path), (end_0), (u32(0)), (u32(5))));
    var _S767 : u32 = (insertBits((_S766), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S767;
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

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_10 : u32,  refracted_3 : bool,  lobe_1 : u32,  pdf_5 : f32) -> SampleBSDF
{
    var _S768 : SampleBSDF;
    _S768.unit_direction = unit_direction_1;
    _S768.throughput = throughput_0;
    _S768.random_state = random_state_10;
    _S768.refracted = refracted_3;
    _S768.lobe = lobe_1;
    _S768.pdf = pdf_5;
    return _S768;
}

fn sheenVelvetSample( n_i_8 : vec3<f32>,  n_i_dot_v_5 : f32,  alpha_13 : f32,  material_15 : Material,  lobes_9 : BSDFLobes,  eta_i_10 : f32,  eta_o_10 : f32,  random_state_11 : u32) -> SampleBSDF
{
    var _S769 : vec3<f32> = vec3<f32>(1.0f);
    var _S770 : SampleBSDF = SampleBSDF_x24init_0(_S769, _S769, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S770;
    var _S771 : Random = pcg(random_state_11);
    var _S772 : Random = pcg(_S771.state);
    sample_1.random_state = _S772.state;
    var _S773 : f32 = _S771.value;
    var _S774 : f32 = sqrt(max(0.0f, 1.0f - _S773 * _S773));
    var _S775 : f32 = 6.28318548202514648f * _S772.value;
    var _S776 : vec3<f32> = tangentToWorld(vec3<f32>(_S774 * cos(_S775), _S771.value, _S774 * sin(_S775)), n_i_8);
    sample_1.unit_direction = _S776;
    sample_1.lobe = u32(4);
    var _S777 : vec3<f32> = sheenVelvetBSDF(sample_1.unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    sample_1.throughput = _S777;
    var _S778 : f32 = sheenVelvetPDF(_S771.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    sample_1.pdf = _S778;
    return sample_1;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S779 : f32 = sqrt(random_1_0);
    var _S780 : f32 = 6.28318548202514648f * random_2_0;
    var _S781 : f32 = _S779 * cos(_S780);
    var _S782 : f32 = _S779 * sin(_S780);
    var _S783 : f32 = sqrt(max(0.0f, 1.0f - _S781 * _S781 - _S782 * _S782));
    return vec3<f32>(_S781, _S783, _S782);
}

fn diffuseSample( u_1 : f32,  n_i_9 : vec3<f32>,  n_i_dot_v_6 : f32,  alpha_14 : f32,  material_16 : Material,  lobes_10 : BSDFLobes,  eta_i_11 : f32,  eta_o_11 : f32,  random_state_12 : u32) -> SampleBSDF
{
    var _S784 : vec3<f32> = vec3<f32>(1.0f);
    var _S785 : SampleBSDF = SampleBSDF_x24init_0(_S784, _S784, u32(0), false, u32(0), 0.0f);
    var sample_2 : SampleBSDF = _S785;
    var _S786 : Random = pcg(random_state_12);
    var _S787 : Random = pcg(_S786.state);
    sample_2.random_state = _S787.state;
    var _S788 : vec3<f32> = sampleCosWeightedHemisphere(_S786.value, _S787.value);
    var _S789 : bool = u_1 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    var _S790 : f32 = _S788.y;
    var _S791 : f32 = - _S790;
    var _S792 : f32 = select(_S790, _S791, _S789);
    var _S793 : vec3<f32> = tangentToWorld(vec3<f32>(_S788.x, _S792, _S788.z), n_i_9);
    sample_2.unit_direction = _S793;
    sample_2.refracted = _S789;
    sample_2.lobe = u32(0);
    var _S794 : vec3<f32> = diffuseBSDF(sample_2.unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    sample_2.throughput = _S794;
    var _S795 : f32 = diffusePDF(_S792, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    sample_2.pdf = _S795;
    return sample_2;
}

fn refractSample( ggx_n_3 : vec3<f32>,  n_i_10 : vec3<f32>,  n_i_dot_v_7 : f32,  alpha_15 : f32,  material_17 : Material,  lobes_11 : BSDFLobes,  eta_i_12 : f32,  eta_o_12 : f32,  random_state_13 : u32) -> SampleBSDF
{
    var _S796 : vec3<f32> = vec3<f32>(1.0f);
    var _S797 : SampleBSDF = SampleBSDF_x24init_0(_S796, _S796, u32(0), false, u32(0), 0.0f);
    var sample_3 : SampleBSDF = _S797;
    sample_3.unit_direction = lobes_11.refracted;
    sample_3.random_state = random_state_13;
    sample_3.refracted = true;
    sample_3.lobe = u32(1);
    var _S798 : vec3<f32> = refractBSDF(sample_3.unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    sample_3.throughput = _S798;
    var _S799 : f32 = refractPDF(0.0f, dot(sample_3.unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    sample_3.pdf = _S799;
    return sample_3;
}

fn reflectSample( in_dir_8 : vec3<f32>,  ggx_n_4 : vec3<f32>,  n_i_11 : vec3<f32>,  n_i_dot_v_8 : f32,  alpha_16 : f32,  material_18 : Material,  lobes_12 : BSDFLobes,  eta_i_13 : f32,  eta_o_13 : f32,  random_state_14 : u32) -> SampleBSDF
{
    var _S800 : vec3<f32> = vec3<f32>(1.0f);
    var _S801 : SampleBSDF = SampleBSDF_x24init_0(_S800, _S800, u32(0), false, u32(0), 0.0f);
    var sample_4 : SampleBSDF = _S801;
    var _S802 : vec3<f32> = (normalize((reflect(in_dir_8, ggx_n_4))));
    sample_4.unit_direction = _S802;
    sample_4.random_state = random_state_14;
    sample_4.lobe = u32(2);
    var _S803 : vec3<f32> = reflectBSDF(sample_4.unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    sample_4.throughput = _S803;
    var _S804 : f32 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    sample_4.pdf = _S804;
    return sample_4;
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_8 : vec3<f32>,  material_19 : Material,  eta_i_14 : f32,  eta_o_14 : f32,  random_init_0 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_15 : u32 = random_init_0;
    var _S805 : vec3<f32> = ((-(in_dir_9)));
    var _S806 : f32 = dot(n_8, _S805);
    var _S807 : f32 = (sign((_S806)));
    var n_i_12 : vec3<f32> = n_8 * vec3<f32>(_S807);
    var _S808 : f32 = abs(_S806);
    var _S809 : f32 = material_19.roughness;
    var _S810 : f32 = _S809 * _S809;
    var _S811 : AnisotropicFrame = anisotropicFrame(material_19, n_i_12);
    var _S812 : SheenProfile = sheenProfile(_S805, n_i_12, material_19);
    var _S813 : vec3<f32> = sampleHalfVector(_S805, n_i_12, _S810, _S811, &(random_state_15));
    var _S814 : BSDFLobes = bsdfLobes(in_dir_9, _S805, n_i_12, _S813, material_19, eta_i_14, eta_o_14, _S811, _S812);
    var lobes_13 : BSDFLobes = _S814;
    var _S815 : f32 = translucentShare(material_19);
    lobes_13.translucent_share = _S815;
    var _S816 : Random = pcg(random_state_15);
    random_state_15 = _S816.state;
    var _S817 : bool = (_S816.value) < (lobes_13.p_sheen_velvet);
    if(_S817)
    {
        var _S818 : SampleBSDF = sheenVelvetSample(n_i_12, _S808, _S810, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S818;
    }
    var _S819 : f32 = _S816.value - lobes_13.p_sheen_velvet;
    var _S820 : bool = _S819 < (lobes_13.p_diffuse);
    if(_S820)
    {
        var _S821 : SampleBSDF = diffuseSample(_S819, n_i_12, _S808, _S810, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S821;
    }
    var _S822 : bool = _S819 < (lobes_13.p_diffuse + lobes_13.p_refract);
    if(_S822)
    {
        var _S823 : SampleBSDF = refractSample(_S813, n_i_12, _S808, _S810, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
        return _S823;
    }
    var _S824 : SampleBSDF = reflectSample(in_dir_9, _S813, n_i_12, _S808, _S810, material_19, lobes_13, eta_i_14, eta_o_14, random_state_15);
    return _S824;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S825 : bool = pdf_6 > 0.0f;
    var _S826 : bool;
    if(_S825)
    {
        if(diffuse_0)
        {
            _S826 = true;
        }
        else
        {
            _S826 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S826 = false;
    }
    return _S826;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S827 : bool = pdf_7 > 0.0f;
    var _S828 : bool;
    if(_S827)
    {
        if(diffuse_1)
        {
            _S828 = true;
        }
        else
        {
            _S828 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S828 = false;
    }
    return _S828;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S829 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S829.x, max(_S829.y, _S829.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_6 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var _S830 : vec3<f32> = vec3<f32>(0.0f);
    var _S831 : Shift = Shift_x24init_0(_S830, 0.0f);
    var _S832 : u32 = (extractBits((r_6.path), (u32(0)), (u32(5))));
    var _S833 : u32 = (extractBits((r_6.path), (u32(5)), (u32(5))));
    var _S834 : u32 = (extractBits((r_6.path), (u32(10)), (u32(2))));
    var _S835 : u32 = (extractBits((r_6.path), (u32(12)), (u32(3))));
    var is_inside_5 : bool;
    if(replay_0)
    {
        var _S836 : bool = _S835 >= u32(3);
        var _S837 : u32 = select(u32(0), u32(1), _S836);
        var _S838 : u32 = _S832 + _S837;
        var _S839 : u32 = (uniforms_uint.max_bounces);
        is_inside_5 = _S838 > _S839;
    }
    else
    {
        is_inside_5 = false;
    }
    if(is_inside_5)
    {
        return _S831;
    }
    var _S840 : u32 = _S833 - u32(1);
    var _S841 : bool = _S835 == u32(3);
    var _S842 : u32 = select(u32(0), u32(1), _S841);
    var _S843 : u32 = _S832 + _S842;
    var _S844 : bool = _S834 == u32(0);
    var _S845 : u32 = select(_S840, _S843, _S844);
    var _S846 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_6.rc.zw))), r_6.rc.x, r_6.rc.y, u32(0), 0.0f);
    var _S847 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S848 : Ray = Ray_x24init_0(dom_4.x1, _S847);
    var ray_2 : Ray = _S848;
    var hit_2 : Hit = dom_4.hit;
    var _S849 : vec3<f32> = vec3<f32>(1.0f);
    var _S850 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S830, _S830, _S830);
    var nee_vertex_0 : NEEVertex = _S850;
    var _S851 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S851;
    var _S852 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S830, 0.0f, vec4<u32>(u32(0)), _S830, _S830);
    var chain_0 : Reservoir = _S852;
    chain_0.seed = r_6.seed;
    is_inside_5 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S830;
    var reconnection_0 : vec3<f32> = _S830;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S849;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S853 : bool = (hit_2.is_point_light) == u32(1);
        var _S854 : bool;
        if(replay_0)
        {
            _S854 = _S834 == u32(1);
        }
        else
        {
            _S854 = false;
        }
        var _S855 : bool;
        if(_S854)
        {
            _S855 = b_3 == _S833;
        }
        else
        {
            _S855 = false;
        }
        var _S856 : bool;
        if(_S855)
        {
            var _S857 : bool = (hit_2.instance_index) != (_S846.instance_index);
            if(_S857)
            {
                _S856 = true;
            }
            else
            {
                _S856 = (hit_2.triangle_index) != (_S846.triangle_index);
            }
        }
        else
        {
            _S856 = false;
        }
        if(_S856)
        {
            return _S831;
        }
        var _S858 : Surface = Surface_x24init_0(_S830, _S830, 0.0f, Material_x24init_0(_S830, _S830, 0.0f, 0.0f, 0.0f, 0.0f, _S830, _S849, 1.0f, _S830, _S830, 0.5f, 0.0f, 0.0f, _S830, 0.0f), false, u32(0));
        var _S859 : bool = !_S853;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S859)
        {
            var _S860 : u32 = stream(r_6.seed, b_3);
            var _S861 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S860)));
            var surface_6 : Surface = facingRay_0(_S861, ray_2.unit_direction);
            if(is_inside_5)
            {
                var _S862 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S863 : vec3<f32> = throughput_2 * _S862;
                front_n_0 = _S863;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S864 : bool = !surface_6.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_6.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S865 : bool = b_3 == u32(0);
            if(_S865)
            {
                var _S866 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S866;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S867 : vec3<f32> = front_n_0;
            var _S868 : f32 = geometry_density_2;
            scatter_0 = _S864;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S868;
            surface_5 = surface_6;
            front_n_0 = _S861.smooth_n;
            throughput_3 = _S867;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_5 = _S858;
            front_n_0 = _S830;
            throughput_3 = throughput_2;
        }
        var _S869 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S870 : Surface = surface_5;
        var _S871 : Surface = surface_5;
        var _S872 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S873 : vec2<f32> = vertexEta(_S870.material, _S872);
        var _S874 : bool;
        if(scatter_0)
        {
            var _S875 : bool = neeDecision(_S870.material, _S872, _S873.x, _S873.y);
            _S874 = _S875;
        }
        else
        {
            _S874 = false;
        }
        var _S876 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S877 : vec3<f32> = _S870.material.emissive * vec3<f32>(max(_S876, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S853)
        {
            var _S878 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S878;
        }
        else
        {
            emission_0 = _S877;
        }
        var _S879 : bool = !replay_0;
        var _S880 : bool;
        if(_S879)
        {
            _S880 = true;
        }
        else
        {
            _S880 = b_3 >= _S845;
        }
        var _S881 : bool;
        if(_S880)
        {
            var _S882 : f32 = rgb_to_greyscale(emission_0);
            _S881 = _S882 > 0.0f;
        }
        else
        {
            _S881 = false;
        }
        var emission_1 : vec3<f32>;
        if(_S881)
        {
            var _S883 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S883);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S884 : bool;
        if(replay_0)
        {
            _S884 = _S834 == u32(1);
        }
        else
        {
            _S884 = false;
        }
        var _S885 : bool;
        if(_S884)
        {
            _S885 = b_3 > _S833;
        }
        else
        {
            _S885 = false;
        }
        var _S886 : bool;
        if(_S885)
        {
            _S886 = b_3 == _S832;
        }
        else
        {
            _S886 = false;
        }
        var _S887 : bool;
        if(_S886)
        {
            var _S888 : bool = _S835 == u32(1);
            if(_S888)
            {
                _S887 = true;
            }
            else
            {
                _S887 = _S835 == u32(2);
            }
        }
        else
        {
            _S887 = false;
        }
        if(_S887)
        {
            var _S889 : bool = _S853 != (_S835 == u32(2));
            if(_S889)
            {
                return _S831;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_6.jac), density_2 / r_6.jac);
        }
        var _S890 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S891 : bool = _S890 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S892 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S893 : u32 = (insertBits((_S892), (u32(1)), (u32(10)), (u32(2))));
        var _S894 : u32 = (insertBits((_S893), (prev_0.lobe), (u32(15)), (u32(3))));
        var _S895 : bool = prev_0.inside;
        var _S896 : u32 = select(u32(0), u32(1), _S895);
        var _S897 : u32 = (insertBits((_S894), (_S896), (u32(22)), (u32(1))));
        here_0.path = _S897;
        var _S898 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S898;
        var _S899 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S899;
        var _S900 : bool;
        if(replay_0)
        {
            _S900 = _S834 == u32(1);
        }
        else
        {
            _S900 = false;
        }
        var _S901 : bool;
        if(_S900)
        {
            _S901 = b_3 == _S833;
        }
        else
        {
            _S901 = false;
        }
        var _S902 : bool = b_3 == _S845;
        var _S903 : bool;
        if(_S902)
        {
            var _S904 : bool = !scatter_0;
            if(_S904)
            {
                _S903 = true;
            }
            else
            {
                var _S905 : bool = _S834 != u32(1);
                if(_S905)
                {
                    _S903 = _S834 != u32(3);
                }
                else
                {
                    _S903 = false;
                }
            }
        }
        else
        {
            _S903 = false;
        }
        var _S906 : bool;
        if(_S903)
        {
            _S906 = _S834 == u32(2);
        }
        else
        {
            _S906 = false;
        }
        var _S907 : bool;
        if(_S906)
        {
            _S907 = !_S869;
        }
        else
        {
            _S907 = false;
        }
        var _S908 : bool;
        if(_S907)
        {
            _S908 = _S835 != u32(4);
        }
        else
        {
            _S908 = false;
        }
        var _S909 : bool = _S833 == _S832;
        var _S910 : bool;
        if(_S909)
        {
            _S910 = _S835 == u32(0);
        }
        else
        {
            _S910 = false;
        }
        var _S911 : bool;
        if(_S910)
        {
            _S911 = (hit_2.instance_index) == (_S846.instance_index);
        }
        else
        {
            _S911 = false;
        }
        var _S912 : bool;
        if(_S911)
        {
            _S912 = (hit_2.triangle_index) == (_S846.triangle_index);
        }
        else
        {
            _S912 = false;
        }
        var _S913 : bool;
        if(_S912)
        {
            _S913 = _S869;
        }
        else
        {
            _S913 = false;
        }
        var _S914 : bool = select(_S908, _S913, _S901);
        var _S915 : bool;
        if(_S874)
        {
            _S915 = select(scatter_0, _S914, replay_0);
        }
        else
        {
            _S915 = false;
        }
        var _S916 : TreeSample = TreeSample_x24init_0(_S830, _S830, 0.0f, u32(0));
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S915)
        {
            var _S917 : Surface = surface_5;
            var _S918 : bool = isTranslucent_0(_S870.material);
            var _S919 : u32 = stream(r_6.seed, b_3 + u32(64));
            var _S920 : TreeSample = sampleLightTree_0(ray_2.origin, _S871.smooth_n, surface_5.geometry_n, surface_5.geometry_offset, _S918, _S919);
            var _S921 : bool = (any(((_S920.radiance) != _S830)));
            if(_S921)
            {
                var _S922 : f32 = _S873.x;
                var _S923 : f32 = _S873.y;
                var _S924 : u32 = (uniforms_uint.max_bounces);
                var _S925 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S920, _S871.smooth_n, _S917.geometry_n, _S870.material, _S922, _S923, b_3 < _S924, surface_5.random_state);
                lit_0 = _S925;
            }
            else
            {
                lit_0 = _S830;
            }
            light_1 = _S920;
        }
        else
        {
            light_1 = _S916;
            lit_0 = _S830;
        }
        var _S926 : bool;
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S927 : bool;
        var _S928 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S901)
        {
            var _S929 : bool = !_S869;
            if(_S929)
            {
                return _S831;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S909)
            {
                _S926 = _S835 == u32(1);
            }
            else
            {
                _S926 = false;
            }
            if(_S926)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S909)
            {
                wrong_side_0 = _S835 == u32(0);
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                var _S930 : bool = !_S874;
                if(_S930)
                {
                    is_inside_5 = true;
                }
                else
                {
                    var _S931 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_5 = !(_S931 > 0.0f);
                }
                if(is_inside_5)
                {
                    return _S831;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            if(_S909)
            {
                refracted_4 = _S835 == u32(4);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                var _S932 : bool = !_S874;
                if(_S932)
                {
                    return _S831;
                }
                var _S933 : f32 = environmentPdf_0(r_6.dir);
                var _S934 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_6.dir, surface_5, _S873, is_inside_5, _S933, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S934 * r_6.radiance / vec3<f32>(r_6.jac), density_4 / r_6.jac);
            }
            var _S935 : u32 = (extractBits((r_6.path), (u32(21)), (u32(1))));
            var _S936 : bool = _S874 != (_S935 == u32(1));
            if(_S936)
            {
                return _S831;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S926 = _S902;
            }
            else
            {
                _S926 = false;
            }
            if(_S926)
            {
                var _S937 : bool = !scatter_0;
                if(_S937)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S938 : bool = _S834 != u32(1);
                    if(_S938)
                    {
                        wrong_side_0 = _S834 != u32(3);
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
                var _S939 : bool = _S834 == u32(2);
                if(_S939)
                {
                    _S854 = _S874;
                }
                else
                {
                    _S854 = false;
                }
                if(_S854)
                {
                    _S854 = !_S869;
                }
                else
                {
                    _S854 = false;
                }
                if(_S854)
                {
                    _S854 = _S835 == u32(4);
                }
                else
                {
                    _S854 = false;
                }
                if(_S854)
                {
                    var _S940 : u32 = stream(r_6.seed, b_3 + u32(256));
                    var _S941 : SkySample = sampleSky_0(ray_2, surface_5, _S873, is_inside_5, _S940, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S941.color, 1.0f);
                }
                if(_S939)
                {
                    is_inside_5 = _S874;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = !_S869;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    var _S942 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S943 : bool = !(_S942 > 0.0f);
                    if(_S943)
                    {
                        return _S831;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S844)
                {
                    is_inside_5 = _S835 == u32(2);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = _S853;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S844)
                {
                    is_inside_5 = _S835 == u32(1);
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
                    is_inside_5 = !_S869;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S831;
            }
            else
            {
                if(_S879)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S944 : bool = b_3 > u32(0);
                    if(_S944)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S891)
                        {
                            var _S945 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S945;
                        }
                        else
                        {
                            if(_S869)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S946 : vec3<f32> = throughput_3 * emission_1;
                        var _S947 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S946);
                        offer(&((*sel_4)), _S947, _S946 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S874)
                    {
                        var _S948 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S891)
                        {
                            var _S949 : vec3<f32> = safeDivide(_S948, chain_throughput_0);
                            candidate_4.radiance = _S949;
                        }
                        else
                        {
                            if(_S869)
                            {
                                candidate_4 = here_0;
                                var _S950 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_4.path = _S950;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S951 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S952 : u32 = (insertBits((_S951), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S952;
                            }
                        }
                        var _S953 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S948);
                        offer(&((*sel_4)), _S953, _S948 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S874)
                    {
                        var _S954 : bool = environmentMapped_0();
                        _S927 = _S954;
                    }
                    else
                    {
                        _S927 = false;
                    }
                    if(_S927)
                    {
                        var _S955 : u32 = (uniforms_uint.max_bounces);
                        _S928 = b_3 < _S955;
                    }
                    else
                    {
                        _S928 = false;
                    }
                    if(_S928)
                    {
                        var _S956 : u32 = stream(r_6.seed, b_3 + u32(256));
                        var _S957 : SkySample = sampleSky_0(ray_2, surface_5, _S873, is_inside_5, _S956, surface_5.random_state);
                        var _S958 : vec3<f32> = throughput_3 * _S957.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S891)
                        {
                            var _S959 : vec3<f32> = safeDivide(_S958, chain_throughput_0);
                            candidate_5.radiance = _S959;
                        }
                        else
                        {
                            if(_S869)
                            {
                                candidate_5 = here_0;
                                var _S960 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(21)), (u32(1))));
                                candidate_5.path = _S960;
                                candidate_5.dir = _S957.dir;
                                candidate_5.radiance = _S957.radiance;
                            }
                            else
                            {
                                var _S961 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S962 : u32 = (insertBits((_S961), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S962;
                            }
                        }
                        var _S963 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S958);
                        offer(&((*sel_4)), _S963, _S958 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S964 : bool;
        var _S965 : bool;
        var _S966 : bool;
        var _S967 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S926 = _S902;
            }
            else
            {
                _S926 = false;
            }
            var _S968 : u32 = (extractBits((r_6.path), (u32(15)), (u32(3))));
            var _S969 : u32 = (extractBits((r_6.path), (u32(18)), (u32(3))));
            var _S970 : u32 = select(_S968, _S969, _S901);
            var refracted_5 : bool = _S970 == u32(1);
            var _S971 : SampleBSDF = SampleBSDF_x24init_0(_S830, _S830, u32(0), false, u32(0), 0.0f);
            var lobe_2 : SampleBSDF = _S971;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S926)
            {
                var _S972 : u32 = (extractBits((r_6.path), (u32(22)), (u32(1))));
                var _S973 : bool = is_inside_5 != (_S972 == u32(1));
                if(_S973)
                {
                    return _S831;
                }
                var _S974 : bool = _S834 == u32(1);
                if(_S974)
                {
                    var _S975 : vec3<f32> = (hitPosition((_S846)));
                    dir_11 = _S975;
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
                    var _S976 : bool = isTranslucent_0(_S870.material);
                    if(_S976)
                    {
                        wrong_side_0 = _S970 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S977 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S978 : vec3<f32> = select(r_6.dir, _S977, _S974);
                        refracted_4 = (dot(_S871.smooth_n, _S978) * _S872) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S974)
                {
                    var _S979 : vec3<f32> = ray_2.origin;
                    var _S980 : Surface = surface_5;
                    var _S981 : vec3<f32> = (vec3<f32>(0) - _S871.smooth_n);
                    var _S982 : bool = is_inside_5 != refracted_4;
                    var _S983 : vec3<f32> = select(_S871.smooth_n, _S981, _S982);
                    var _S984 : vec3<f32> = (normalize((dir_11 - (_S979 + vec3<f32>(_S980.geometry_offset) * _S983))));
                    reconnection_1 = _S984;
                }
                else
                {
                    reconnection_1 = r_6.dir;
                }
                var _S985 : bool = wrongSide_0(is_inside_5, refracted_4, reconnection_1, surface_5.geometry_n);
                if(_S985)
                {
                    return _S831;
                }
                var _S986 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S970;
                wrong_side_0 = false;
                reconnection_1 = _S986;
            }
            else
            {
                var _S987 : bool = !_S901;
                if(_S987)
                {
                    var _S988 : f32 = _S873.x;
                    var _S989 : f32 = _S873.y;
                    var _S990 : vec2<f32> = vec2<f32>(0.0f);
                    var _S991 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S871.smooth_n, _S870.material, _S988, _S989, surface_5.random_state, _S990);
                    var bsdf_sampled_0 : SampleBSDF = _S991;
                    var _S992 : Surface = surface_5;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_5, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, surface_5.geometry_n);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S870.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S993 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, _S992.geometry_n, _S870.material, _S988, _S989, bsdf_sampled_0.random_state, _S990);
                        bsdf_sampled_0.unit_direction = _S993.unit_direction;
                        bsdf_sampled_0.refracted = _S993.refracted;
                        bsdf_sampled_0.throughput = _S993.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S994 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, _S992.geometry_n))) * _S992.geometry_n;
                            bsdf_sampled_0.unit_direction = _S994;
                        }
                    }
                    var _S995 : u32 = bsdf_sampled_0.lobe;
                    var _S996 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S997 : bool = bsdf_sampled_0.refracted;
                    lobe_2 = bsdf_sampled_0;
                    var _S998 : f32 = bsdf_sampled_0.pdf;
                    var _S999 : f32 = select(_S998, 0.0f, wrong_side_1);
                    lobe_2.pdf = _S999;
                    dir_11 = _S996;
                    lobe_index_0 = _S995;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S997;
                }
                else
                {
                    dir_11 = r_6.dir;
                    lobe_index_0 = _S970;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S926)
            {
                _S927 = true;
            }
            else
            {
                _S927 = _S901;
            }
            var throughput_6 : vec3<f32>;
            var throughput_7 : vec3<f32>;
            var chain_throughput_1 : vec3<f32>;
            if(_S927)
            {
                var _S1000 : vec3<f32> = ray_2.unit_direction;
                var _S1001 : f32 = (sign((_S872)));
                var _S1002 : vec3<f32> = _S871.smooth_n * vec3<f32>(_S1001);
                var _S1003 : f32 = dot(_S1002, dir_11);
                var _S1004 : f32 = _S870.material.roughness;
                var _S1005 : f32 = _S1004 * _S1004;
                var _S1006 : AnisotropicFrame = anisotropicFrame(_S870.material, _S1002);
                var _S1007 : vec3<f32> = ((-(_S1000)));
                var _S1008 : SheenProfile = sheenProfile(_S1007, _S1002, _S870.material);
                var _S1009 : vec3<f32> = reflectedHalf(_S1000, dir_11);
                var _S1010 : bool = lobe_index_0 == u32(1);
                if(_S1010)
                {
                    var _S1011 : vec3<f32> = refractedHalf(_S1000, dir_11, _S871.smooth_n, _S873.x, _S873.y);
                    throughput_6 = _S1011;
                }
                else
                {
                    throughput_6 = _S1009;
                }
                var _S1012 : bool = lobe_index_0 == u32(0);
                if(_S1012)
                {
                    var _S1013 : vec3<f32> = sampledHalf(_S1000, _S871.smooth_n, _S870.material, surface_5.random_state, _S1006);
                    throughput_7 = _S1013;
                }
                else
                {
                    throughput_7 = throughput_6;
                }
                var _S1014 : vec3<f32> = ((-(_S1000)));
                var _S1015 : f32 = _S873.x;
                var _S1016 : f32 = _S873.y;
                var _S1017 : BSDFLobes = bsdfLobes(_S1000, _S1014, _S1002, throughput_7, _S870.material, _S1015, _S1016, _S1006, _S1008);
                var lobe_terms_1 : BSDFLobes = _S1017;
                var _S1018 : f32 = translucentShare(_S870.material);
                lobe_terms_1.translucent_share = _S1018;
                switch(lobe_index_0)
                {
                case u32(0):
                    {
                        var _S1019 : f32 = diffusePDF(_S1003, 0.0f, abs(_S872), _S1005, lobe_terms_1, _S1015, _S1016);
                        var _S1020 : vec3<f32> = diffuseBSDF(dir_11, _S1002, _S1005, _S870.material, lobe_terms_1);
                        density_5 = _S1019;
                        chain_throughput_1 = _S1020;
                    }
                case u32(1):
                    {
                        var _S1021 : f32 = refractPDF(_S1003, dot(dir_11, throughput_7), abs(_S872), _S1005, lobe_terms_1, _S1015, _S1016);
                        var _S1022 : vec3<f32> = refractBSDF(dir_11, _S1002, _S1005, _S870.material, lobe_terms_1);
                        density_5 = _S1021;
                        chain_throughput_1 = _S1022;
                    }
                case u32(4):
                    {
                        var _S1023 : f32 = sheenVelvetPDF(_S1003, 0.0f, abs(_S872), _S1005, lobe_terms_1, _S1015, _S1016);
                        var _S1024 : vec3<f32> = sheenVelvetBSDF(dir_11, _S1002, _S1005, _S870.material, lobe_terms_1);
                        density_5 = _S1023;
                        chain_throughput_1 = _S1024;
                    }
                default :
                    {
                        var _S1025 : f32 = reflectPDF(_S1003, 0.0f, abs(_S872), _S1005, lobe_terms_1, _S1015, _S1016);
                        var _S1026 : vec3<f32> = reflectBSDF(dir_11, _S1002, _S1005, _S870.material, lobe_terms_1);
                        density_5 = _S1025;
                        chain_throughput_1 = _S1026;
                    }
                }
                var _S1027 : bool = density_5 > 0.0f;
                if(_S1027)
                {
                    var _S1028 : SampleBSDF = SampleBSDF_x24init_0(dir_11, chain_throughput_1, surface_5.random_state, _S1010, lobe_index_0, density_5);
                    lobe_2 = _S1028;
                }
            }
            var _S1029 : bool = lobe_index_0 == u32(0);
            if(_S1029)
            {
                _S928 = true;
            }
            else
            {
                _S928 = lobe_index_0 == u32(4);
            }
            var _S1030 : bool = !_S928;
            if(_S1030)
            {
                var _S1031 : bool = (_S870.material.roughness) == 0.0f;
                if(_S1031)
                {
                    _S964 = true;
                }
                else
                {
                    var _S1032 : bool = lobe_index_0 == u32(1);
                    if(_S1032)
                    {
                        _S964 = (_S873.x) == (_S873.y);
                    }
                    else
                    {
                        _S964 = false;
                    }
                }
            }
            else
            {
                _S964 = false;
            }
            var _S1033 : bool = isTranslucent_0(_S870.material);
            if(_S1033)
            {
                _S965 = _S1029;
            }
            else
            {
                _S965 = false;
            }
            if(_S965)
            {
                _S966 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S966 = false;
            }
            if(_S874)
            {
                _S967 = !_S964;
            }
            else
            {
                _S967 = false;
            }
            var _S1034 : bool;
            if(_S967)
            {
                _S1034 = !wrong_side_0;
            }
            else
            {
                _S1034 = false;
            }
            var _S1035 : bool;
            if(_S1034)
            {
                var _S1036 : f32 = lobe_2.pdf;
                var _S1037 : vec3<f32> = ray_2.origin;
                var _S1038 : bool = isTranslucent_0(_S870.material);
                var _S1039 : vec3<f32> = select(_S871.smooth_n, _S830, _S1038);
                var _S1040 : vec3<f32> = ray_2.origin;
                var _S1041 : Surface = surface_5;
                var _S1042 : vec3<f32> = (vec3<f32>(0) - _S871.smooth_n);
                var _S1043 : vec3<f32> = select(_S871.smooth_n, _S1042, _S966);
                var _S1044 : NEEVertex = NEEVertex_x24init_0(false, _S1036, _S1037, _S1039, _S1040 + vec3<f32>(_S1041.geometry_offset) * _S1043);
                nee_vertex_0 = _S1044;
            }
            else
            {
                var _S1045 : bool = lobe_index_0 != u32(1);
                if(_S1045)
                {
                    _S1035 = true;
                }
                else
                {
                    _S1035 = (_S873.x) != (_S873.y);
                }
                if(_S1035)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S1046 : bool = withinInverseFootprint(lobe_2.pdf, _S928, prev_0.cos, hit_2.distance, threshold_2);
            var _S1047 : bool = roughLobe(lobe_2.pdf, _S928, _S870.material.roughness);
            if(_S901)
            {
                var _S1048 : bool = !_S1046;
                if(_S1048)
                {
                    return _S831;
                }
                var _S1049 : bool = _S835 != u32(1);
                if(_S1049)
                {
                    _S1035 = _S835 != u32(2);
                }
                else
                {
                    _S1035 = false;
                }
                if(_S1035)
                {
                    var _S1050 : f32 = lobe_2.pdf;
                    var _S1051 : f32 = select(0.0f, _S1050, _S874);
                    var _S1052 : f32 = escapeWeight_0(_S1051, r_6.dir);
                    if(_S909)
                    {
                        is_inside_5 = _S841;
                    }
                    else
                    {
                        is_inside_5 = false;
                    }
                    var _S1053 : f32 = select(1.0f, _S1052, is_inside_5);
                    return Shift_x24init_0(throughput_4 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf)) * r_6.radiance * vec3<f32>(_S1053) / vec3<f32>(r_6.jac), density_3 * lobe_2.pdf / r_6.jac);
                }
                var _S1054 : vec3<f32> = throughput_4 * vec3<f32>(lobe_2.pdf);
                var _S1055 : f32 = density_3 * lobe_2.pdf;
                throughput_6 = _S1054;
                density_5 = _S1055;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S1035 = b_3 <= _S845;
            }
            else
            {
                _S1035 = false;
            }
            var _S1056 : bool;
            if(_S1035)
            {
                _S1056 = _S869;
            }
            else
            {
                _S1056 = false;
            }
            var _S1057 : bool;
            if(_S1056)
            {
                _S1057 = _S1046;
            }
            else
            {
                _S1057 = false;
            }
            var _S1058 : bool;
            if(_S1057)
            {
                _S1058 = true;
            }
            else
            {
                if(_S926)
                {
                    _S1058 = !_S1047;
                }
                else
                {
                    _S1058 = false;
                }
            }
            if(_S1058)
            {
                return _S831;
            }
            if(_S926)
            {
                var _S1059 : vec3<f32> = throughput_6 * (lobe_2.throughput * vec3<f32>(lobe_2.pdf));
                var _S1060 : f32 = lobe_2.pdf;
                throughput_7 = _S1059;
                survival_probability_0 = _S1060;
            }
            else
            {
                var _S1061 : vec3<f32> = throughput_6 * max(lobe_2.throughput, _S830);
                throughput_7 = _S1061;
                survival_probability_0 = density_5;
            }
            var _S1062 : bool;
            if(_S879)
            {
                _S1062 = !_S891;
            }
            else
            {
                _S1062 = false;
            }
            var _S1063 : bool;
            if(_S1062)
            {
                _S1063 = _S869;
            }
            else
            {
                _S1063 = false;
            }
            var _S1064 : bool;
            if(_S1063)
            {
                _S1064 = _S1046;
            }
            else
            {
                _S1064 = false;
            }
            if(_S1064)
            {
                chain_0 = here_0;
                var _S1065 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(18)), (u32(3))));
                var _S1066 : u32 = select(u32(0), u32(1), _S874);
                var _S1067 : u32 = (insertBits((_S1065), (_S1066), (u32(21)), (u32(1))));
                chain_0.path = _S1067;
                var _S1068 : f32 = chain_0.jac * lobe_2.pdf;
                chain_0.jac = _S1068;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1069 : Vertex = Vertex_x24init_0(_S1047, lobe_index_0, lobe_2.pdf, abs(dot(surface_5.geometry_n, dir_11)), is_inside_5);
            prev_0 = _S1069;
            var _S1070 : f32 = lobe_2.pdf;
            var _S1071 : bool = lobe_index_0 == u32(1);
            var _S1072 : bool;
            if(_S1071)
            {
                _S1072 = (_S873.x) == (_S873.y);
            }
            else
            {
                _S1072 = false;
            }
            var _S1073 : f32 = select(_S1070, sky_pdf_0, _S1072);
            var _S1074 : bool;
            if(refracted_4)
            {
                _S1074 = !_S966;
            }
            else
            {
                _S1074 = false;
            }
            var is_inside_6 : bool;
            if(_S1074)
            {
                var _S1075 : bool = !is_inside_5;
                is_inside_6 = _S1075;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            ray_2.unit_direction = dir_11;
            var _S1076 : Surface = surface_5;
            var _S1077 : vec3<f32> = (vec3<f32>(0) - _S871.smooth_n);
            var _S1078 : bool = is_inside_6 != _S966;
            var _S1079 : vec3<f32> = select(_S871.smooth_n, _S1077, _S1078);
            var _S1080 : vec3<f32> = ray_2.origin + vec3<f32>(_S1076.geometry_offset) * _S1079;
            ray_2.origin = _S1080;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_6;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1073;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        if(_S879)
        {
            if(_S853)
            {
                var _S1081 : vec3<f32> = throughput_2 * emission_1;
                var candidate_6 : Reservoir = chain_0;
                var _S1082 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
                var _S1083 : bool = _S1082 == u32(1);
                if(_S1083)
                {
                    var _S1084 : vec3<f32> = safeDivide(_S1081, chain_throughput_0);
                    candidate_6.radiance = _S1084;
                }
                var _S1085 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1081);
                offer(&((*sel_4)), _S1085, _S1081 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S853)
            {
                _S926 = true;
            }
            else
            {
                _S926 = scatter_0;
            }
            if(_S926)
            {
                var _S1086 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1086;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1087 : u32 = stream(r_6.seed, b_3 + u32(128));
            var _S1088 : Random = pcg(_S1087);
            var _S1089 : bool = survival_probability_0 < (_S1088.value);
            if(_S1089)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1090 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1090;
            }
            if(wrong_side_0)
            {
                break;
            }
            var _S1091 : f32 = density_5 * survival_probability_0;
            density_2 = _S1091;
        }
        else
        {
            density_2 = density_5;
        }
        var _S1092 : Ray = ray_2;
        var _S1093 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S926 = _S902;
        }
        else
        {
            _S926 = false;
        }
        if(_S926)
        {
            wrong_side_0 = _S834 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1094 : f32 = select(4.294967296e+09f, _S1093, wrong_side_0);
        var _S1095 : Hit = (traverseInstanceBVH((_S1092), (_S859), (_S1094)));
        hit_2 = _S1095;
        if(replay_0)
        {
            refracted_4 = _S902;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S927 = _S834 == u32(1);
        }
        else
        {
            _S927 = false;
        }
        if(_S927)
        {
            _S928 = (hit_2.instance_index) == (_S846.instance_index);
        }
        else
        {
            _S928 = false;
        }
        if(_S928)
        {
            _S964 = (hit_2.triangle_index) == (_S846.triangle_index);
        }
        else
        {
            _S964 = false;
        }
        if(_S964)
        {
            hit_2.uv = _S846.uv;
            var _S1096 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1096;
        }
        if(replay_0)
        {
            _S965 = _S902;
        }
        else
        {
            _S965 = false;
        }
        if(_S965)
        {
            _S966 = _S834 == u32(3);
        }
        else
        {
            _S966 = false;
        }
        if(_S966)
        {
            _S967 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S967 = false;
        }
        if(_S967)
        {
            return _S831;
        }
        var _S1097 : bool = (hit_2.instance_index) == u32(4294967295);
        if(_S1097)
        {
            var _S1098 : bool = !nee_vertex_0.none;
            var _S1099 : f32 = select(0.0f, sky_pdf_0, _S1098);
            var _S1100 : f32 = escapeWeight_0(_S1099, ray_2.unit_direction);
            var _S1101 : vec3<f32> = environment_0(ray_2.unit_direction);
            var _S1102 : vec3<f32> = throughput_2 * _S1101;
            if(replay_0)
            {
                if(_S902)
                {
                    is_inside_5 = _S834 == u32(3);
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    return Shift_x24init_0(_S1102 * vec3<f32>(_S1100) / vec3<f32>(r_6.jac), density_2 / r_6.jac);
                }
                if(_S844)
                {
                    is_inside_5 = _S841;
                }
                else
                {
                    is_inside_5 = false;
                }
                if(is_inside_5)
                {
                    is_inside_5 = b_3 == _S832;
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
                    return Shift_x24init_0(_S1102 * vec3<f32>(_S1100), 1.0f);
                }
                return _S831;
            }
            var candidate_7 : Reservoir = chain_0;
            var _S1103 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
            var _S1104 : bool = _S1103 == u32(1);
            if(_S1104)
            {
                var _S1105 : u32 = (extractBits((chain_0.path), (u32(5)), (u32(5))));
                var _S1106 : bool = _S1105 == b_3;
                var _S1107 : f32 = select(_S1100, 1.0f, _S1106);
                var _S1108 : vec3<f32> = safeDivide(_S1102 * vec3<f32>(_S1107), chain_throughput_0);
                candidate_7.radiance = _S1108;
            }
            else
            {
                var _S1109 : bool = prev_0.rough;
                if(_S1109)
                {
                    var _S1110 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                    var _S1111 : u32 = (insertBits((_S1110), (u32(3)), (u32(10)), (u32(2))));
                    var _S1112 : u32 = (insertBits((_S1111), (prev_0.lobe), (u32(15)), (u32(3))));
                    var _S1113 : bool = prev_0.inside;
                    var _S1114 : u32 = select(u32(0), u32(1), _S1113);
                    var _S1115 : u32 = (insertBits((_S1112), (_S1114), (u32(22)), (u32(1))));
                    candidate_7.path = _S1115;
                    candidate_7.jac = prev_0.pdf;
                    candidate_7.dir = ray_2.unit_direction;
                }
            }
            var _S1116 : vec3<f32> = _S1102 * vec3<f32>(_S1100);
            var _S1117 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1116);
            offer(&((*sel_4)), _S1117, _S1116 * vec3<f32>(scale_1) / vec3<f32>(density_2));
            break;
        }
        var _S1118 : vec3<f32> = ray_2.origin + vec3<f32>(hit_2.distance) * ray_2.unit_direction;
        ray_2.origin = _S1118;
        var _S1119 : u32 = b_3 + u32(1);
        b_3 = _S1119;
    }
    return _S831;
}

fn shift_0( dom_5 : Domain,  r_7 : Reservoir) -> Shift
{
    var _S1120 : vec3<f32> = vec3<f32>(0.0f);
    var _S1121 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1120, 0.0f, vec4<u32>(u32(0)), _S1120, _S1120), 0.0f, _S1120, u32(0));
    var sel_5 : Selection = _S1121;
    var _S1122 : bool = (r_7.w) <= 0.0f;
    if(_S1122)
    {
        return Shift_x24init_0(_S1120, 0.0f);
    }
    var _S1123 : Shift = walk_0(dom_5, r_7, true, 0.0f, &(sel_5));
    return _S1123;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1124 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1125 : bool = _S1124 != u32(4294967295);
    if(_S1125)
    {
        var _S1126 : vec2<i32> = vec2<i32>((vec2<u32>(_S1124, (_S1124 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1127 : vec3<f32> = vec3<f32>(0.0f);
        var _S1128 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1127, _S1127, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1127, 0.0f, vec4<u32>(u32(0)), _S1127, _S1127));
        var shift_job_0 : ShiftJob = _S1128;
        var _S1129 : u32 = (_S1124 >> (u32(28)));
        var _S1130 : bool = spatialJob_0(_S1126, _S1129, &(shift_job_0));
        var _S1131 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1126), (_S1129), (vec4<u32>((bitcast<vec3<u32>>((_S1131.f))), (bitcast<u32>((_S1131.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1132 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1133 : array<u32, i32(3)>;
    spatialBins_0(_S1132, &(_S1133));
    var _S1134 : array<u32, i32(3)> = _S1133;
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
        var _S1135 : bool = (_S1134[t_16]) == u32(40);
        if(_S1135)
        {
            textureStore(shift_data_out, (_S1132), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1132, _S1134, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1136 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1136));
    countShifts_0(_S1136, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1137 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1138 : bool = _S1137 != u32(4294967295);
    if(_S1138)
    {
        var _S1139 : vec2<i32> = vec2<i32>((vec2<u32>(_S1137, (_S1137 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1140 : vec3<f32> = vec3<f32>(0.0f);
        var _S1141 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1140, _S1140, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1140, 0.0f, vec4<u32>(u32(0)), _S1140, _S1140));
        var shift_job_1 : ShiftJob = _S1141;
        var _S1142 : u32 = (_S1137 >> (u32(28)));
        var _S1143 : bool = temporalJob_0(_S1139, _S1142, &(shift_job_1));
        var _S1144 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1139), (_S1142), (vec4<u32>((bitcast<vec3<u32>>((_S1144.f))), (bitcast<u32>((_S1144.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1145 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1146 : array<u32, i32(3)>;
    temporalBins_0(_S1145, &(_S1146));
    var _S1147 : array<u32, i32(3)> = _S1146;
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
        var _S1148 : bool = (_S1147[t_18]) == u32(40);
        if(_S1148)
        {
            textureStore(temporal_shifts_out, (_S1145), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1145, _S1147, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1149 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1149));
    countShifts_0(_S1149, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1150 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1150;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1151 : f32 = c_3 * p_c_1;
    var _S1152 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1151 / (_S1151 + c_t_0 * g_previous_0), _S1152 / (_S1152 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1153 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1154 : vec3<f32> = vec3<f32>(0.0f);
    var _S1155 : Domain = Domain_x24init_0(_S1154, _S1154, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1155;
    var _S1156 : bool = (currentDomain((_S1153), &(dom_6)));
    var _S1157 : bool = !_S1156;
    if(_S1157)
    {
        storeReservoir(reservoir_temp_out, (_S1153), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1154, 0.0f, vec4<u32>(u32(0)), _S1154, _S1154)), (dom_6.hit));
        return;
    }
    var _S1158 : Reservoir = (loadReservoir(reservoir_initial, (_S1153)));
    var _S1159 : vec2<i32> = temporalNeighbor_0(_S1153, dom_6);
    var _S1160 : bool = (_S1159.x) >= i32(0);
    var r_8 : Reservoir;
    if(_S1160)
    {
        var _S1161 : Reservoir = (loadReservoir(reservoir_prev, (_S1159)));
        var _S1162 : vec4<u32> = (textureLoad(duplication, (_S1159), 0, 0));
        var _S1163 : f32 = (bitcast<f32>((_S1162.x)));
        var _S1164 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1165 : bool = _S1164 == u32(1);
        var _S1166 : f32 = select(0.0f, _S1163, _S1165);
        var _S1167 : f32 = confidenceCap(_S1166);
        var _S1168 : f32 = min(_S1161.c, _S1167);
        var _S1169 : vec4<u32> = (textureLoad(temporal_shifts, (_S1153), (u32(0)), 0));
        var _S1170 : vec4<f32> = (bitcast<vec4<f32>>((_S1169)));
        var _S1171 : vec4<f32> = vec4<f32>(_S1158.f, 1.0f);
        var _S1172 : Domain = (previousDomain((_S1159)));
        var _S1173 : bool = sameDomain_0(_S1172, dom_6);
        var _S1174 : bool = !_S1173;
        var to_previous_0 : vec4<f32>;
        if(_S1174)
        {
            var _S1175 : vec4<u32> = (textureLoad(temporal_shifts, (_S1153), (u32(1)), 0));
            var _S1176 : vec4<f32> = (bitcast<vec4<f32>>((_S1175)));
            to_previous_0 = _S1176;
        }
        else
        {
            to_previous_0 = _S1171;
        }
        var _S1177 : f32 = rgb_to_greyscale(_S1158.f);
        var _S1178 : f32 = rgb_to_greyscale(_S1161.f);
        var _S1179 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1154, 0.0f, vec4<u32>(u32(0)), _S1154, _S1154), 0.0f, _S1154, u32(0));
        var sel_6 : Selection = _S1179;
        var _S1180 : u32 = (uniforms_uint.frame);
        var _S1181 : u32 = hash(_S1180);
        var _S1182 : u32 = global_invocation_id_7.x;
        var _S1183 : vec2<u32> = (uniforms_uint.render_size);
        var _S1184 : u32 = stream(_S1181, _S1182 + _S1183.x * global_invocation_id_7.y);
        var _S1185 : u32 = stream(_S1184, u32(194));
        sel_6.random_state = _S1185;
        var _S1186 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1187 : vec3<f32> = _S1170.xyz;
        var _S1188 : f32 = rgb_to_greyscale(_S1187);
        var _S1189 : vec2<f32> = temporalWeights(_S1158.c, _S1177, _S1168, _S1178, _S1186, _S1188);
        offerShifted(&(sel_6), _S1158, Shift_x24init_0(_S1158.f, 1.0f), _S1189.x);
        offerShifted(&(sel_6), _S1161, Shift_x24init_0(_S1187, _S1170.w), _S1189.y);
        var _S1190 : Reservoir = finalize(sel_6, _S1158.c + _S1168);
        r_8 = _S1190;
    }
    else
    {
        r_8 = _S1158;
    }
    storeReservoir(reservoir_temp_out, (_S1153), (r_8), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1191 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1192 : vec3<f32> = vec3<f32>(0.0f);
    var _S1193 : Domain = Domain_x24init_0(_S1192, _S1192, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1193;
    var _S1194 : bool = (currentDomain((_S1191), &(dom_7)));
    var _S1195 : bool = !_S1194;
    if(_S1195)
    {
        storeReservoir(reservoir_initial_out, (_S1191), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1192, 0.0f, vec4<u32>(u32(0)), _S1192, _S1192)), (dom_7.hit));
        return;
    }
    var _S1196 : u32 = (uniforms_uint.frame);
    var _S1197 : u32 = hash(_S1196);
    var _S1198 : u32 = global_invocation_id_8.x;
    var _S1199 : vec2<u32> = (uniforms_uint.render_size);
    var _S1200 : u32 = stream(_S1197, _S1198 + _S1199.x * global_invocation_id_8.y);
    var _S1201 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1192, 0.0f, vec4<u32>(u32(0)), _S1192, _S1192);
    var _S1202 : Selection = Selection_x24init_0(_S1201, 0.0f, _S1192, u32(0));
    var initial_0 : Selection = _S1202;
    var _S1203 : u32 = stream(_S1200, u32(193));
    initial_0.random_state = _S1203;
    var i_10 : u32 = u32(0);
    loop
    {
        var _S1204 : u32 = (uniforms_uint.samples);
        if(i_10 < _S1204)
        {
        }
        else
        {
            break;
        }
        var r_9 : Reservoir = _S1201;
        var _S1205 : u32 = stream(_S1200, i_10);
        r_9.seed = _S1205;
        var _S1206 : u32 = (uniforms_uint.samples);
        var _S1207 : Shift = walk_0(dom_7, r_9, false, 1.0f / f32(_S1206), &(initial_0));
        var i_11 : u32 = i_10 + u32(1);
        i_10 = i_11;
    }
    var _S1208 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1191), (_S1208), (dom_7.hit));
    return;
}

fn normal_distribution( state_3 : u32) -> Random
{
    var _S1209 : Random = pcg(state_3);
    var _S1210 : Random = pcg(_S1209.state);
    var _S1211 : f32 = 6.28318548202514648f * _S1209.value;
    var _S1212 : f32 = sqrt(-2.0f * clamp(log(_S1210.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1210.state, _S1212 * cos(_S1211));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_4 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1213 : RandomSphere;
    _S1213.state = state_4;
    _S1213.value = value_1;
    return _S1213;
}

fn random_sphere( state_5 : u32) -> RandomSphere
{
    var _S1214 : Random = normal_distribution(state_5);
    var _S1215 : Random = normal_distribution(_S1214.state);
    var _S1216 : Random = normal_distribution(_S1215.state);
    var _S1217 : vec3<f32> = (normalize((vec3<f32>(_S1214.value, _S1215.value, _S1216.value))));
    return RandomSphere_x24init_0(_S1216.state, _S1217);
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_9 : vec3<f32>) -> mat3x3<f32>
{
    var _S1218 : vec3<f32> = p1_0 - p0_0;
    var _S1219 : vec3<f32> = p2_0 - p0_0;
    var _S1220 : vec2<f32> = uv1_0 - uv0_0;
    var _S1221 : vec2<f32> = uv2_0 - uv0_0;
    var _S1222 : f32 = _S1220.x;
    var _S1223 : f32 = _S1221.y;
    var _S1224 : f32 = _S1220.y;
    var _S1225 : f32 = _S1221.x;
    var _S1226 : f32 = _S1222 * _S1223 - _S1224 * _S1225;
    var _S1227 : f32 = 1.0f / _S1226;
    var _S1228 : vec3<f32> = vec3<f32>(_S1227);
    var t_20 : vec3<f32> = (_S1218 * vec3<f32>(_S1223) - _S1219 * vec3<f32>(_S1224)) * _S1228;
    var _S1229 : vec3<f32> = (_S1219 * vec3<f32>(_S1222) - _S1218 * vec3<f32>(_S1225)) * _S1228;
    var t_21 : vec3<f32> = (normalize((t_20 - n_9 * vec3<f32>(dot(n_9, t_20)))));
    var _S1230 : bool = (dot(cross(n_9, t_21), _S1229)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1230)
    {
        var _S1231 : vec3<f32> = ((-(t_21)));
        t_22 = _S1231;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1232 : vec3<f32> = cross(n_9, t_22);
    return mat3x3<f32>(t_22, _S1232, n_9);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1233 : vec3<f32> = t1_0 - t0_0;
    var _S1234 : vec3<f32> = t2_2 - t0_0;
    var _S1235 : vec3<f32> = t2_2 - t1_0;
    var _S1236 : f32 = min(length(_S1233), min(length(_S1234), length(_S1235)));
    var _S1237 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1238 : vec3<f32> = (normalize((n0_0)));
    var _S1239 : f32 = dot(geometry_n_5, _S1238);
    var _S1240 : vec3<f32> = (normalize((n1_0)));
    var _S1241 : f32 = dot(geometry_n_5, _S1240);
    var _S1242 : vec3<f32> = (normalize((n2_0)));
    var _S1243 : vec3<f32> = acos(abs(vec3<f32>(_S1239, _S1241, dot(geometry_n_5, _S1242))));
    var _S1244 : vec3<f32> = clamp(tan(_S1243), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1237 * _S1244, uvw_0), 0.0f, _S1236 * 0.125f);
}

fn straightThrough( dir_12 : vec3<f32>,  n_10 : vec3<f32>,  material_20 : Material) -> vec3<f32>
{
    var _S1245 : vec3<f32> = ((-(dir_12)));
    var _S1246 : f32 = (sign((dot(n_10, _S1245))));
    var _S1247 : vec3<f32> = n_10 * vec3<f32>(_S1246);
    var _S1248 : AnisotropicFrame = anisotropicFrame(material_20, _S1247);
    var _S1249 : bool = (_S1248.alphas.x) > 0.0f;
    if(_S1249)
    {
        var _S1250 : f32 = material_20.transmission * (1.0f - material_20.metallic);
        var _S1251 : vec3<f32> = ((-(_S1247)));
        var _S1252 : vec3<f32> = anisotropicLocal(dir_12, _S1248.tangent, _S1251);
        var _S1253 : f32 = anisotropicG1(_S1252, _S1248.alphas);
        return vec3<f32>((_S1250 * _S1253)) * material_20.albedo;
    }
    var _S1254 : f32 = material_20.transmission * (1.0f - material_20.metallic);
    var _S1255 : f32 = material_20.roughness;
    var _S1256 : f32 = smithG1(_S1255 * _S1255, abs(dot(n_10, dir_12)));
    return vec3<f32>((_S1254 * _S1256)) * material_20.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_11 : vec3<f32>,  material_21 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1257 : vec3<f32>;
    if((material_21.ior) == 1.0f)
    {
        var _S1258 : vec3<f32> = straightThrough(toward_1, n_11, material_21);
        _S1257 = _S1258;
    }
    else
    {
        _S1257 = vec3<f32>(0.0f);
    }
    return _S1257 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_10 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1259 : Shift = walk_0(dom_8, r_10, replay_1, scale_2, &((*sel_7)));
    return _S1259;
}

fn shift_hook( dom_9 : Domain,  r_11 : Reservoir) -> Shift
{
    var _S1260 : Shift = shift_0(dom_9, r_11);
    return _S1260;
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

