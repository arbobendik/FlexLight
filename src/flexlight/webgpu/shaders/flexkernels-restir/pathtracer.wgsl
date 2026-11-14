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

fn rgb_to_greyscale( rgb_0 : vec3<f32>) -> f32
{
    return dot(rgb_0, vec3<f32>(0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

fn isTranslucent_0( material_0 : Material) -> bool
{
    var _S128 : f32 = rgb_to_greyscale(material_0.translucent);
    return _S128 > 0.0f;
}

fn wrongSide_0( is_inside_0 : bool,  refracted_0 : bool,  dir_1 : vec3<f32>,  geometry_n_0 : vec3<f32>) -> bool
{
    return (is_inside_0 == refracted_0) != ((dot(dir_1, geometry_n_0)) > 0.0f);
}

fn Ray_x24init_0( origin_0 : vec3<f32>,  unit_direction_0 : vec3<f32>) -> Ray
{
    var _S129 : Ray;
    _S129.origin = origin_0;
    _S129.unit_direction = unit_direction_0;
    return _S129;
}

fn skyRadiance_0( origin_1 : vec3<f32>,  surface_0 : Surface,  side_n_0 : vec3<f32>,  is_inside_1 : bool,  dir_2 : vec3<f32>) -> vec3<f32>
{
    var _S130 : bool = !((surface_0.material.transmission) > 0.0f);
    var _S131 : bool;
    if(_S130)
    {
        var _S132 : bool = isTranslucent_0(surface_0.material);
        _S131 = !_S132;
    }
    else
    {
        _S131 = false;
    }
    if(_S131)
    {
        _S131 = !((dot(surface_0.geometry_n, dir_2)) > 0.0f);
    }
    else
    {
        _S131 = false;
    }
    if(_S131)
    {
        return vec3<f32>(0.0f);
    }
    var _S133 : bool = wrongSide_0(is_inside_1, false, dir_2, side_n_0);
    var _S134 : bool = is_inside_1 != _S133;
    var _S135 : vec3<f32> = (vec3<f32>(0) - surface_0.smooth_n);
    var _S136 : vec3<f32> = select(surface_0.smooth_n, _S135, _S134);
    var _S137 : Ray = Ray_x24init_0(origin_1 + vec3<f32>(surface_0.geometry_offset) * _S136, dir_2);
    var _S138 : vec3<f32> = (env_map_sample((dir_2)));
    var _S139 : vec3<f32> = (shadowTransmittance((_S137), (4.294967296e+09f)));
    return _S138 * _S139;
}

fn searchCDF_0( start_3 : vec2<u32>,  step_0 : vec2<u32>,  count_0 : u32,  u_0 : f32) -> u32
{
    var _S140 : u32 = count_0 - u32(1);
    var low_0 : u32 = u32(0);
    var high_0 : u32 = _S140;
    loop
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        var _S141 : u32 = (low_0 + high_0) / u32(2);
        var _S142 : vec4<f32> = (textureLoad(environment_cdf, (start_3 + step_0 * vec2<u32>(_S141)), 0));
        var _S143 : bool = (_S142.x) > u_0;
        if(_S143)
        {
            high_0 = _S141;
        }
        else
        {
            var _S144 : u32 = _S141 + u32(1);
            low_0 = _S144;
        }
    }
    return low_0;
}

fn shadowLength( shadow_0 : vec3<f32>) -> f32
{
    return length(shadow_0) * 0.99989998340606689f;
}

fn lightTransmittance_0( origin_2 : vec3<f32>,  smooth_n_0 : vec3<f32>,  geometry_offset_0 : f32,  light_dir_0 : vec3<f32>,  face_0 : vec3<f32>) -> vec3<f32>
{
    var _S145 : vec3<f32> = (normalize((light_dir_0)));
    var _S146 : bool = (dot(smooth_n_0, _S145)) < 0.0f;
    if(_S146)
    {
        return vec3<f32>(0.0f);
    }
    var _S147 : bool = (dot(face_0, face_0)) > 0.0f;
    var _S148 : bool;
    if(_S147)
    {
        _S148 = !((dot(face_0, light_dir_0)) > 0.0f);
    }
    else
    {
        _S148 = false;
    }
    if(_S148)
    {
        return vec3<f32>(0.0f);
    }
    var _S149 : vec3<f32> = origin_2 + vec3<f32>(geometry_offset_0) * smooth_n_0;
    var _S150 : Ray = Ray_x24init_0(_S149, _S145);
    var _S151 : f32 = shadowLength(light_dir_0);
    var _S152 : vec3<f32> = (shadowTransmittance((_S150), (_S151)));
    return _S152;
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
    var _S153 : f32 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    var _S154 : bool = cos_a_0 > cos_b_0;
    var _S155 : f32 = select(_S153, 1.0f, _S154);
    return _S155;
}

fn sinSubClamped( sin_a_1 : f32,  cos_a_1 : f32,  sin_b_1 : f32,  cos_b_1 : f32) -> f32
{
    var _S156 : f32 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    var _S157 : bool = cos_a_1 > cos_b_1;
    var _S158 : f32 = select(_S156, 0.0f, _S157);
    return _S158;
}

fn importance( node_0 : LightBounds,  p_7 : vec3<f32>,  normal_0 : vec3<f32>) -> f32
{
    var _S159 : vec3<f32> = (node_0.low + node_0.high) * vec3<f32>(0.5f);
    var _S160 : vec3<f32> = node_0.high - node_0.low;
    var _S161 : vec3<f32> = p_7 - _S159;
    var _S162 : vec3<f32> = (normalize((_S161)));
    var _S163 : f32 = dot(_S161, _S161);
    var _S164 : f32 = dot(_S160, _S160) / 4.0f;
    var _S165 : f32 = abs(dot(node_0.w, _S162));
    var _S166 : f32 = sine(node_0.cos_theta_o);
    var _S167 : f32 = sqrt(max(1.0f - _S164 / _S163, 0.0f));
    var _S168 : bool = _S163 < _S164;
    var _S169 : f32 = select(_S167, -1.0f, _S168);
    var _S170 : f32 = sine(_S169);
    var _S171 : f32 = sine(_S165);
    var _S172 : f32 = cosSubClamped(_S171, _S165, _S166, node_0.cos_theta_o);
    var _S173 : f32 = sine(_S165);
    var _S174 : f32 = sinSubClamped(_S173, _S165, _S166, node_0.cos_theta_o);
    var _S175 : f32 = cosSubClamped(_S174, _S172, _S170, _S169);
    var _S176 : bool = _S175 <= 0.0f;
    if(_S176)
    {
        return 0.0f;
    }
    var _S177 : f32 = - dot(_S162, normal_0);
    var _S178 : f32 = node_0.phi * _S175 / max(_S163, length(_S160) / 2.0f);
    var _S179 : f32 = sine(_S177);
    var _S180 : f32 = cosSubClamped(_S179, _S177, _S170, _S169);
    var _S181 : bool = (dot(normal_0, normal_0)) == 0.0f;
    var _S182 : f32 = select(_S180, 1.0f, _S181);
    return max(_S178 * _S182, 0.0f);
}

fn childShare( first_0 : LightBounds,  second_0 : LightBounds,  p_8 : vec3<f32>,  normal_1 : vec3<f32>,  child_0 : u32) -> f32
{
    var _S183 : f32 = importance(first_0, p_8, normal_1);
    var _S184 : f32 = importance(second_0, p_8, normal_1);
    var _S185 : vec2<f32> = vec2<f32>(_S183, _S184);
    var _S186 : f32 = _S185[child_0] / (_S183 + _S184);
    var _S187 : bool = (_S185[child_0]) > 0.0f;
    var _S188 : f32 = select(0.0f, _S186, _S187);
    return _S188;
}

fn sphereDensity( center_0 : vec3<f32>,  radius_0 : f32,  p_9 : vec3<f32>) -> f32
{
    var _S189 : vec3<f32> = center_0 - p_9;
    var _S190 : f32 = radius_0 * radius_0 / dot(_S189, _S189);
    var _S191 : bool = _S190 >= 1.0f;
    if(_S191)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + sqrt(1.0f - _S190)) / (6.28318548202514648f * _S190);
}

fn solidAngle( probability_0 : f32,  normal_2 : vec3<f32>,  toward_0 : vec3<f32>) -> f32
{
    return 2.0f * probability_0 * pow(length(toward_0), 3.0f) / abs(dot(normal_2, toward_0));
}

fn lightPdf_0( origin_3 : vec3<f32>,  smooth_n_1 : vec3<f32>,  start_4 : vec3<f32>,  j_0 : u32,  light_point_0 : vec3<f32>) -> f32
{
    var _S192 : vec4<u32> = (access_light_tree(access_light_tree(0u).y + (j_0)));
    var _S193 : vec2<u32> = _S192.xy;
    var n_0 : u32 = u32(0);
    var trail_0 : vec2<u32> = _S193;
    var probability_1 : f32 = 1.0f;
    loop
    {
        var _S194 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
        if((_S194.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S195 : u32 = (access_light_tree(3u + 4u * (n_0)).w);
        var _S196 : u32 = n_0 + u32(1);
        var _S197 : LightBounds = (lightBounds((_S196)));
        var _S198 : LightBounds = (lightBounds((_S195)));
        var _S199 : u32 = trail_0.x;
        var _S200 : u32 = (_S199 & (u32(1)));
        var _S201 : f32 = childShare(_S197, _S198, origin_3, smooth_n_1, _S200);
        var probability_2 : f32 = probability_1 * _S201;
        var _S202 : bool = _S200 == u32(1);
        var _S203 : u32 = select(_S196, _S195, _S202);
        var _S204 : u32 = trail_0.y;
        var _S205 : vec2<u32> = vec2<u32>((((_S199 >> (u32(1)))) | (((_S204 << (u32(31)))))), (_S204 >> (u32(1))));
        n_0 = _S203;
        trail_0 = _S205;
        probability_1 = probability_2;
    }
    var _S206 : bool = (((_S192).z == (n_0)));
    var _S207 : bool = !_S206;
    var _S208 : bool;
    if(_S207)
    {
        _S208 = true;
    }
    else
    {
        var _S209 : LightBounds = (lightBounds((n_0)));
        var _S210 : f32 = importance(_S209, origin_3, smooth_n_1);
        _S208 = !(_S210 > 0.0f);
    }
    if(_S208)
    {
        _S208 = true;
    }
    else
    {
        var _S211 : bool = (dot(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S211)
        {
            _S208 = !((dot(smooth_n_1, light_point_0 - start_4)) > 0.0f);
        }
        else
        {
            _S208 = false;
        }
    }
    if(_S208)
    {
        return 0.0f;
    }
    var _S212 : vec4<u32> = (access_light_tree(4u + 4u * (n_0)));
    var _S213 : bool = (_S212.x) == u32(2);
    if(_S213)
    {
        var _S214 : u32 = _S212.y;
        var _S215 : Light = (lights[(_S214)]);
        var _S216 : Light = (lights[(_S214)]);
        var _S217 : f32 = sphereDensity(_S215.position, _S216.variance, start_4);
        return probability_1 * _S217;
    }
    var _S218 : u32 = _S212.y;
    var _S219 : u32 = ((instance_uint[(_S218) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
    var _S220 : mat3x3<f32> = (worldTriangle((_S218), (_S219 + _S212.z)));
    var _S221 : f32 = solidAngle(probability_1, cross(_S220[i32(1)] - _S220[i32(0)], _S220[i32(2)] - _S220[i32(0)]), light_point_0 - start_4);
    return _S221;
}

fn environment_0( dir_3 : vec3<f32>) -> vec3<f32>
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
    if(_S224)
    {
        var _S226 : vec3<f32> = (env_map_sample((dir_3)));
        return _S226;
    }
    var _S227 : vec3<f32> = (uniforms_float.ambient);
    return _S227;
}

fn environmentMapped_0() -> bool
{
    var _S228 : vec2<u32> = (uniforms_uint.environment_map_size);
    var _S229 : bool = (_S228.x) > u32(1);
    var _S230 : bool;
    if(_S229)
    {
        var _S231 : vec2<u32> = (uniforms_uint.environment_map_size);
        _S230 = (_S231.y) > u32(1);
    }
    else
    {
        _S230 = false;
    }
    return _S230;
}

fn environmentPdf_0( dir_4 : vec3<f32>) -> f32
{
    var _S232 : vec2<u32> = (textureDimensions(environment_cdf));
    var _S233 : vec2<u32> = _S232 - vec2<u32>(u32(1), u32(0));
    var _S234 : vec2<f32> = vec2<f32>(atan2(- dir_4.z, - dir_4.x) / 6.28318548202514648f + 0.5f, acos(clamp(dir_4.y, -1.0f, 1.0f)) / 3.14159274101257324f);
    var _S235 : vec2<u32> = min(vec2<u32>(_S234 * vec2<f32>(_S233)), _S233 - vec2<u32>(u32(1)));
    var _S236 : vec4<f32> = (textureLoad(environment_cdf, (_S235), 0));
    var _S237 : f32 = _S236.y;
    var _S238 : u32 = _S233.x;
    var _S239 : vec4<f32> = (textureLoad(environment_cdf, (vec2<u32>(_S238, _S235.y)), 0));
    var _S240 : f32 = _S237 * _S239.y;
    return _S240 * f32(_S238 * _S233.y) / (19.73921012878417969f * length(dir_4.xz));
}

fn escapeWeight_0( pdf_0 : f32,  dir_5 : vec3<f32>) -> f32
{
    var _S241 : bool = pdf_0 <= 0.0f;
    var _S242 : bool;
    if(_S241)
    {
        _S242 = true;
    }
    else
    {
        var _S243 : bool = environmentMapped_0();
        _S242 = !_S243;
    }
    if(_S242)
    {
        return 1.0f;
    }
    var _S244 : f32 = environmentPdf_0(dir_5);
    return pdf_0 / (pdf_0 + _S244);
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
    var _S245 : Random;
    _S245.state = state_0;
    _S245.value = value_0;
    return _S245;
}

fn pcg( state_1 : u32) -> Random
{
    var _S246 : u32 = state_1 * u32(747796405) + u32(2891336453);
    var _S247 : u32 = hash(state_1);
    return Random_x24init_0(_S246, f32(_S247) / 4.294967296e+09f);
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
    var _S248 : AnisotropicFrame;
    _S248.tangent = tangent_0;
    _S248.alphas = alphas_0;
    return _S248;
}

fn tangentToWorld( v_0 : vec3<f32>,  n_1 : vec3<f32>) -> vec3<f32>
{
    const a_1 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S249 : bool = (abs(dot(n_1, a_1))) > 0.9999847412109375f;
    var a_2 : vec3<f32>;
    if(_S249)
    {
        const _S250 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_2 = _S250;
    }
    else
    {
        a_2 = a_1;
    }
    var _S251 : vec3<f32> = (normalize((cross(n_1, a_2))));
    var _S252 : vec3<f32> = cross(n_1, _S251);
    return vec3<f32>(v_0.x) * _S251 + vec3<f32>(v_0.y) * n_1 + vec3<f32>(v_0.z) * _S252;
}

fn anisotropicFrame( material_1 : Material,  n_i_0 : vec3<f32>) -> AnisotropicFrame
{
    var _S253 : f32 = material_1.roughness;
    var _S254 : f32 = _S253 * _S253;
    var _S255 : bool = (material_1.anisotropy) == 0.0f;
    var _S256 : bool;
    if(_S255)
    {
        _S256 = true;
    }
    else
    {
        _S256 = !(_S254 > 0.0f);
    }
    if(_S256)
    {
        return AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f));
    }
    var _S257 : vec3<f32> = material_1.tangent - n_i_0 * vec3<f32>(dot(n_i_0, material_1.tangent));
    var _S258 : vec3<f32> = tangentToWorld(vec3<f32>(1.0f, 0.0f, 0.0f), n_i_0);
    var _S259 : bool = (dot(_S257, _S257)) > 0.0f;
    var _S260 : vec3<f32> = select(_S258, _S257, _S259);
    var _S261 : vec3<f32> = (normalize((_S260)));
    var _S262 : f32 = 6.28318548202514648f * material_1.anisotropic_rotation;
    var _S263 : f32 = sqrt(1.0f - 0.89999997615814209f * abs(material_1.anisotropy));
    var _S264 : f32 = 1.0f / _S263;
    var _S265 : bool = (material_1.anisotropy) < 0.0f;
    var _S266 : f32 = select(_S263, _S264, _S265);
    return AnisotropicFrame_x24init_0(_S261 * vec3<f32>(cos(_S262)) + cross(n_i_0, _S261) * vec3<f32>(sin(_S262)), vec2<f32>(_S254 / _S266, _S254 * _S266));
}

fn anisotropicLocal( w_1 : vec3<f32>,  t_12 : vec3<f32>,  n_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(w_1, t_12), dot(w_1, cross(n_2, t_12)), dot(w_1, n_2));
}

fn sampleGGXVNDF( Ve_0 : vec3<f32>,  alpha_0 : f32,  U1_0 : f32,  U2_0 : f32) -> vec3<f32>
{
    var _S267 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z))));
    var _S268 : f32 = _S267.x;
    var _S269 : f32 = _S267.y;
    var _S270 : f32 = _S268 * _S268 + _S269 * _S269;
    const _S271 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
    var _S272 : vec3<f32> = vec3<f32>(- _S269, _S268, 0.0f);
    var _S273 : f32 = (inverseSqrt((_S270)));
    var _S274 : vec3<f32> = _S272 * vec3<f32>(_S273);
    var _S275 : bool = _S270 > 0.0f;
    var _S276 : vec3<f32> = select(_S271, _S274, _S275);
    var _S277 : vec3<f32> = cross(_S267, _S276);
    var _S278 : f32 = sqrt(U1_0);
    var _S279 : f32 = 6.28318548202514648f * U2_0;
    var _S280 : f32 = _S278 * cos(_S279);
    var t2_0 : f32 = _S278 * sin(_S279);
    var _S281 : f32 = 0.5f * (1.0f + _S267.z);
    var t2_1 : f32 = (1.0f - _S281) * sqrt(max(0.0f, 1.0f - _S280 * _S280)) + _S281 * t2_0;
    var _S282 : vec3<f32> = vec3<f32>(_S280) * _S276 + vec3<f32>(t2_1) * _S277;
    var _S283 : f32 = ((_S280));
    var _S284 : f32 = ((_S280));
    var _S285 : vec3<f32> = _S282 + vec3<f32>(sqrt(max(0.0f, 1.0f - _S283 * _S284 - t2_1 * t2_1))) * _S267;
    var _S286 : vec3<f32> = (normalize((vec3<f32>(alpha_0 * _S285.x, alpha_0 * _S285.y, max(0.0f, _S285.z)))));
    return _S286;
}

fn sampleAnisotropicVNDF( Ve_1 : vec3<f32>,  alphas_1 : vec2<f32>,  U1_1 : f32,  U2_1 : f32) -> vec3<f32>
{
    var _S287 : f32 = alphas_1.x;
    var _S288 : f32 = alphas_1.y;
    var _S289 : vec3<f32> = (normalize((vec3<f32>(_S287 * Ve_1.x, _S288 * Ve_1.y, Ve_1.z))));
    var _S290 : vec3<f32> = sampleGGXVNDF(_S289, 1.0f, U1_1, U2_1);
    var _S291 : vec3<f32> = (normalize((vec3<f32>(_S287 * _S290.x, _S288 * _S290.y, _S290.z))));
    return _S291;
}

fn worldToTangent( v_1 : vec3<f32>,  n_3 : vec3<f32>) -> vec3<f32>
{
    const a_3 : vec3<f32> = vec3<f32>(0.0f, 1.0f, 0.0f);
    var _S292 : bool = (abs(dot(n_3, a_3))) > 0.9999847412109375f;
    var a_4 : vec3<f32>;
    if(_S292)
    {
        const _S293 : vec3<f32> = vec3<f32>(1.0f, 0.0f, 0.0f);
        a_4 = _S293;
    }
    else
    {
        a_4 = a_3;
    }
    var _S294 : vec3<f32> = (normalize((cross(n_3, a_4))));
    var _S295 : vec3<f32> = cross(n_3, _S294);
    return vec3<f32>(dot(v_1, _S294), dot(v_1, n_3), dot(v_1, _S295));
}

fn sampleMaterialHalfVector( v_2 : vec3<f32>,  n_i_1 : vec3<f32>,  alpha_1 : f32,  frame_0 : AnisotropicFrame,  random_state_0 : ptr<function, u32>) -> vec3<f32>
{
    var _S296 : Random = pcg((*random_state_0));
    var _S297 : Random = pcg(_S296.state);
    (*random_state_0) = _S297.state;
    var _S298 : bool = (frame_0.alphas.x) > 0.0f;
    if(_S298)
    {
        var _S299 : vec3<f32> = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        var _S300 : vec3<f32> = sampleAnisotropicVNDF(_S299, frame_0.alphas, _S296.value, _S297.value);
        return vec3<f32>(_S300.x) * frame_0.tangent + vec3<f32>(_S300.y) * cross(n_i_1, frame_0.tangent) + vec3<f32>(_S300.z) * n_i_1;
    }
    var _S301 : vec3<f32> = worldToTangent(v_2, n_i_1);
    var _S302 : vec3<f32> = sampleGGXVNDF(_S301.xzy, alpha_1, _S296.value, _S297.value);
    var _S303 : vec3<f32> = _S302.xzy;
    var _S304 : vec3<f32> = tangentToWorld(_S303, n_i_1);
    return _S304;
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
    var _S305 : f32 = sqrt(max(0.0f, 1.0f - cos_theta_0 * cos_theta_0));
    var _S306 : f32 = eta_i_0 / eta_o_0 * _S305;
    var _S307 : bool = _S306 < 1.0f;
    var kr_0 : f32;
    if(_S307)
    {
        var _S308 : f32 = sqrt(max(0.0f, 1.0f - _S306 * _S306));
        var _S309 : f32 = eta_o_0 * cos_theta_0;
        var _S310 : f32 = eta_i_0 * _S308;
        var _S311 : f32 = (_S309 - _S310) / (_S309 + _S310);
        var _S312 : f32 = eta_i_0 * cos_theta_0;
        var _S313 : f32 = eta_o_0 * _S308;
        var _S314 : f32 = (_S312 - _S313) / (_S312 + _S313);
        var _S315 : f32 = (_S311 * _S311 + _S314 * _S314) / 2.0f;
        kr_0 = _S315;
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
    var _S316 : f32 = sqrt(0.05000000074505806f);
    var _S317 : f32 = clamp(sqrt(max(mu_0, 0.0f)), 0.0f, 1.0f) * 23.0f;
    var _S318 : f32 = (clamp(sqrt(max(r_2, 0.0f)), _S316, 1.0f) - _S316) / (1.0f - _S316) * 23.0f;
    var _S319 : u32 = min(u32(_S317), u32(22));
    var _S320 : u32 = min(u32(_S318), u32(22));
    var _S321 : f32 = _S317 - f32(_S319);
    var _S322 : f32 = _S318 - f32(_S320);
    var _S323 : u32 = _S319 * u32(24) + _S320;
    var _S324 : u32 = _S323 + u32(24);
    var _S325 : f32 = SHEEN_ALBEDO_0[_S323] + (SHEEN_ALBEDO_0[_S324] - SHEEN_ALBEDO_0[_S323]) * _S321;
    var _S326 : u32 = _S323 + u32(1);
    var _S327 : f32 = SHEEN_ALBEDO_0[_S326] + (SHEEN_ALBEDO_0[_S324 + u32(1)] - SHEEN_ALBEDO_0[_S326]) * _S321;
    return exp(_S325 + (_S327 - _S325) * _S322);
}

fn anisotropicG1( w_2 : vec3<f32>,  alphas_2 : vec2<f32>) -> f32
{
    var _S328 : f32 = max(w_2.z, 0.0f);
    return 2.0f * _S328 / (_S328 + length(vec3<f32>(alphas_2.x * w_2.x, alphas_2.y * w_2.y, _S328)));
}

fn anisotropicD( h_0 : vec3<f32>,  alphas_3 : vec2<f32>) -> f32
{
    var _S329 : f32 = alphas_3.x;
    var _S330 : f32 = h_0.x / _S329;
    var _S331 : f32 = alphas_3.y;
    var _S332 : f32 = h_0.y / _S331;
    var _S333 : f32 = h_0.z;
    var _S334 : f32 = _S330 * _S330 + _S332 * _S332 + _S333 * _S333;
    return 1.0f / max(3.14159274101257324f * _S329 * _S331 * _S334 * _S334, 1.17549435082228751e-38f);
}

fn BSDFLobes_x24init_0( v_dot_h_0 : f32,  n_dot_h_0 : f32,  refracted_1 : vec3<f32>,  F_0 : vec3<f32>,  F_greyscale_0 : f32,  reflect_weight_0 : f32,  diffuse_weight_0 : vec3<f32>,  refract_weight_0 : vec3<f32>,  p_diffuse_0 : f32,  p_reflect_0 : f32,  p_refract_0 : f32,  translucent_share_0 : f32,  sheen_0 : vec3<f32>,  view_1 : vec3<f32>,  tangent_1 : vec3<f32>,  alphas_4 : vec2<f32>,  visible_0 : f32) -> BSDFLobes
{
    var _S335 : BSDFLobes;
    _S335.v_dot_h = v_dot_h_0;
    _S335.n_dot_h = n_dot_h_0;
    _S335.refracted = refracted_1;
    _S335.F = F_0;
    _S335.F_greyscale = F_greyscale_0;
    _S335.reflect_weight = reflect_weight_0;
    _S335.diffuse_weight = diffuse_weight_0;
    _S335.refract_weight = refract_weight_0;
    _S335.p_diffuse = p_diffuse_0;
    _S335.p_reflect = p_reflect_0;
    _S335.p_refract = p_refract_0;
    _S335.translucent_share = translucent_share_0;
    _S335.sheen = sheen_0;
    _S335.view = view_1;
    _S335.tangent = tangent_1;
    _S335.alphas = alphas_4;
    _S335.visible = visible_0;
    return _S335;
}

fn bsdfLobes( in_dir_0 : vec3<f32>,  v_3 : vec3<f32>,  n_i_2 : vec3<f32>,  ggx_n_0 : vec3<f32>,  material_2 : Material,  eta_i_1 : f32,  eta_o_1 : f32,  frame_1 : AnisotropicFrame) -> BSDFLobes
{
    var _S336 : f32 = dot(ggx_n_0, v_3);
    var _S337 : f32 = dot(n_i_2, ggx_n_0);
    var _S338 : f32 = eta_i_1 / eta_o_1;
    var _S339 : vec3<f32> = (normalize((refract(in_dir_0, ggx_n_0, _S338))));
    var _S340 : f32 = min(sqrt(material_2.specular_level) * abs(eta_i_1 - eta_o_1) / (eta_i_1 + eta_o_1), 0.9999847412109375f);
    var _S341 : f32 = _S340 * _S340;
    var _S342 : f32 = (1.0f + _S340) / (1.0f - _S340);
    var _S343 : f32 = abs(_S336);
    var _S344 : bool = eta_i_1 > eta_o_1;
    var sheen_component_0 : f32;
    if(_S344)
    {
        sheen_component_0 = _S342;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    var visible_1 : f32;
    if(_S344)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S342;
    }
    var _S345 : f32 = fresnel(_S343, sheen_component_0, visible_1);
    var _S346 : bool = (eta_i_1 * eta_i_1 * (1.0f - _S336 * _S336)) >= (eta_o_1 * eta_o_1);
    var _S347 : vec3<f32>;
    if(_S346)
    {
        _S347 = vec3<f32>(1.0f);
    }
    else
    {
        var _S348 : vec3<f32> = material_2.specular_tint * vec3<f32>(_S341);
        _S347 = _S348 + (vec3<f32>(1.0f) - _S348) * vec3<f32>((_S345 - _S341)) / vec3<f32>((1.0f - _S341));
    }
    var _S349 : vec3<f32> = vec3<f32>(1.0f);
    var _S350 : vec3<f32> = vec3<f32>(0.0f);
    var _S351 : f32 = rgb_to_greyscale(material_2.sheen);
    var _S352 : bool = _S351 > 0.0f;
    var scale_0 : vec3<f32>;
    var sheen_1 : vec3<f32>;
    var view_2 : vec3<f32>;
    if(_S352)
    {
        var _S353 : f32 = sheenAlbedo(dot(n_i_2, v_3), material_2.sheen_roughness);
        var _S354 : f32 = min(_S353, 1.0f);
        var _S355 : vec3<f32> = vec3<f32>(1.0f) - material_2.sheen * vec3<f32>(_S354);
        var _S356 : f32 = rgb_to_greyscale(material_2.sheen);
        var _S357 : f32 = _S356 * _S354;
        var _S358 : vec3<f32> = material_2.sheen / vec3<f32>(max(_S353, 1.0f));
        scale_0 = _S355;
        sheen_component_0 = _S357;
        sheen_1 = _S358;
        view_2 = v_3;
    }
    else
    {
        scale_0 = _S349;
        sheen_component_0 = 0.0f;
        sheen_1 = _S350;
        view_2 = _S350;
    }
    var _S359 : vec3<f32> = (mix((_S347), (material_2.albedo), (material_2.metallic)));
    var F_1 : vec3<f32> = _S359 * scale_0;
    var _S360 : f32 = rgb_to_greyscale(F_1);
    var _S361 : f32 = 1.0f - material_2.metallic;
    var _S362 : vec3<f32> = vec3<f32>(1.0f) - _S347;
    var _S363 : vec3<f32> = vec3<f32>(((1.0f - material_2.transmission) * _S361)) * _S362 * scale_0;
    var _S364 : vec3<f32> = vec3<f32>((material_2.transmission * _S361)) * _S362 * scale_0;
    var _S365 : f32 = max(_S360, 0.0f);
    var _S366 : f32 = rgb_to_greyscale(_S363);
    var _S367 : f32 = max(_S366, 0.0f);
    var _S368 : f32 = rgb_to_greyscale(_S364);
    var _S369 : f32 = (sign((length(_S339))));
    var _S370 : f32 = max(_S368 * _S369, 0.0f);
    var _S371 : f32 = _S365 + _S367 + _S370 + sheen_component_0;
    var _S372 : f32 = 1.0f / max(_S371, 0.0000152587890625f);
    var _S373 : f32 = (_S367 + sheen_component_0) * _S372;
    var _S374 : f32 = _S365 * _S372;
    var _S375 : f32 = _S370 * _S372;
    var _S376 : bool = (frame_1.alphas.x) > 0.0f;
    if(_S376)
    {
        var _S377 : vec3<f32> = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        var _S378 : f32 = anisotropicG1(_S377, frame_1.alphas);
        var _S379 : vec3<f32> = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        var _S380 : f32 = anisotropicD(_S379, frame_1.alphas);
        var _S381 : f32 = _S378 * _S380;
        visible_1 = _S381;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S336, _S337, _S339, F_1, _S360, 1.0f, _S363, _S364, _S373, _S374, _S375, 0.0f, sheen_1, view_2, frame_1.tangent, frame_1.alphas, visible_1);
}

fn translucentShare( material_3 : Material) -> f32
{
    var _S382 : f32 = rgb_to_greyscale(material_3.translucent);
    var _S383 : f32 = rgb_to_greyscale(material_3.albedo);
    var _S384 : f32 = _S382 / (_S383 + _S382);
    var _S385 : bool = _S382 > 0.0f;
    var _S386 : f32 = select(0.0f, _S384, _S385);
    return _S386;
}

fn smithG1( alpha_2 : f32,  n_dot_x_0 : f32) -> f32
{
    var _S387 : f32 = alpha_2 * alpha_2;
    var _S388 : f32 = 2.0f * n_dot_x_0 / (n_dot_x_0 + sqrt(_S387 + (1.0f - _S387) * n_dot_x_0 * n_dot_x_0));
    var _S389 : bool = alpha_2 > 0.0f;
    var _S390 : f32 = select(1.0f, _S388, _S389);
    return _S390;
}

fn trowbridgeReitz( alpha_3 : f32,  n_dot_h_1 : f32) -> f32
{
    var _S391 : f32 = alpha_3 * alpha_3;
    var _S392 : f32 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S391 * n_dot_h_1 * n_dot_h_1;
    return _S391 / max(3.14159274101257324f * _S392 * _S392, 1.17549435082228751e-38f);
}

fn lobeDensity( n_i_dot_l_0 : f32,  l_dot_h_0 : f32,  n_i_dot_v_0 : f32,  alpha_4 : f32,  lobes_0 : BSDFLobes,  eta_i_2 : f32,  eta_o_2 : f32,  lobe_0 : u32) -> f32
{
    var _S393 : bool = lobe_0 == u32(0);
    if(_S393)
    {
        var _S394 : f32 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        var _S395 : f32 = lobes_0.p_diffuse * abs(n_i_dot_l_0) * 0.31830987334251404f;
        var _S396 : f32 = 1.0f - lobes_0.translucent_share;
        var _S397 : bool = n_i_dot_l_0 < 0.0f;
        var _S398 : f32 = select(_S396, lobes_0.translucent_share, _S397);
        var _S399 : f32 = _S395 * _S398;
        var _S400 : bool = (lobes_0.translucent_share) > 0.0f;
        var _S401 : f32 = select(_S394, _S399, _S400);
        var _S402 : bool = n_i_dot_v_0 > 0.0f;
        var _S403 : f32 = select(0.0f, _S401, _S402);
        return _S403;
    }
    var _S404 : f32 = smithG1(alpha_4, n_i_dot_v_0);
    var _S405 : f32 = _S404 * lobes_0.v_dot_h;
    var _S406 : f32 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    var _S407 : f32 = _S405 * _S406 / n_i_dot_v_0;
    var _S408 : bool = alpha_4 > 0.0f;
    var _S409 : bool;
    if(_S408)
    {
        _S409 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    if(_S409)
    {
        _S409 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    if(_S409)
    {
        _S409 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    var _S410 : f32 = select(0.0f, _S407, _S409);
    var _S411 : bool = (lobes_0.alphas.x) > 0.0f;
    var pdf_h_0 : f32;
    if(_S411)
    {
        var _S412 : f32 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        var _S413 : bool = (lobes_0.v_dot_h) > 0.0f;
        if(_S413)
        {
            _S409 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S409 = false;
        }
        if(_S409)
        {
            _S409 = n_i_dot_v_0 > 0.0f;
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
    var _S415 : bool = lobe_0 == u32(1);
    if(_S415)
    {
        var _S416 : f32 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        var _S417 : f32 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * abs(l_dot_h_0) / (_S416 * _S416);
        var _S418 : bool = eta_i_2 != eta_o_2;
        if(_S418)
        {
            _S409 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S409 = false;
        }
        var _S419 : f32 = select(0.0f, _S417, _S409);
        return _S419;
    }
    var _S420 : f32 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    var _S421 : bool = pdf_h_0 > 0.0f;
    var _S422 : f32 = select(0.0f, _S420, _S421);
    return _S422;
}

fn SampleBSDF_x24init_0( unit_direction_1 : vec3<f32>,  throughput_0 : vec3<f32>,  random_state_1 : u32,  refracted_2 : bool,  lobe_1 : u32,  pdf_1 : f32) -> SampleBSDF
{
    var _S423 : SampleBSDF;
    _S423.unit_direction = unit_direction_1;
    _S423.throughput = throughput_0;
    _S423.random_state = random_state_1;
    _S423.refracted = refracted_2;
    _S423.lobe = lobe_1;
    _S423.pdf = pdf_1;
    return _S423;
}

fn sheenBRDF( l_0 : vec3<f32>,  v_4 : vec3<f32>,  n_4 : vec3<f32>,  r_3 : f32) -> f32
{
    var _S424 : f32 = 1.0f / max(r_3, 0.05000000074505806f);
    var _S425 : vec3<f32> = (normalize((l_0 + v_4)));
    var _S426 : f32 = dot(n_4, _S425);
    var _S427 : f32 = max(dot(n_4, l_0), 0.0f);
    var _S428 : f32 = max(dot(n_4, v_4), 0.0f);
    return (2.0f + _S424) * pow(max(1.0f - _S426 * _S426, 0.0f), 0.5f * _S424) * 0.5f * 0.31830987334251404f / max(4.0f * (_S427 + _S428 - _S427 * _S428), 0.0000152587890625f);
}

fn lobeThroughput( l_1 : vec3<f32>,  n_i_3 : vec3<f32>,  alpha_5 : f32,  material_4 : Material,  lobes_1 : BSDFLobes,  lobe_2 : u32) -> vec3<f32>
{
    var _S429 : bool = lobe_2 == u32(0);
    if(_S429)
    {
        var _S430 : bool = (dot(n_i_3, l_1)) < 0.0f;
        var _S431 : vec3<f32> = select(material_4.albedo, material_4.translucent, _S430);
        var _S432 : f32 = 1.0f - lobes_1.translucent_share;
        var _S433 : f32 = select(_S432, lobes_1.translucent_share, _S430);
        var _S434 : vec3<f32> = _S431 / vec3<f32>(_S433);
        var _S435 : bool = (lobes_1.translucent_share) > 0.0f;
        var _S436 : vec3<f32> = select(material_4.albedo, _S434, _S435);
        var _S437 : f32 = rgb_to_greyscale(material_4.sheen);
        var _S438 : bool = _S437 > 0.0f;
        var _S439 : bool;
        if(_S438)
        {
            _S439 = !_S430;
        }
        else
        {
            _S439 = false;
        }
        if(_S439)
        {
            var _S440 : vec3<f32> = lobes_1.diffuse_weight * _S436;
            var _S441 : vec3<f32> = lobes_1.sheen * vec3<f32>(3.14159274101257324f);
            var _S442 : f32 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_4.sheen_roughness);
            var _S443 : vec3<f32> = _S441 * vec3<f32>(_S442);
            var _S444 : f32 = select(1.0f, _S432, _S435);
            return (_S440 + _S443 / vec3<f32>(_S444)) / vec3<f32>(lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S436 / vec3<f32>(lobes_1.p_diffuse);
    }
    var _S445 : bool = lobe_2 == u32(1);
    var G1_l_0 : f32;
    if(_S445)
    {
        var _S446 : f32 = - dot(n_i_3, l_1);
        var _S447 : f32 = smithG1(alpha_5, max(_S446, 0.0f));
        var _S448 : bool = (lobes_1.alphas.x) > 0.0f;
        if(_S448)
        {
            var _S449 : vec3<f32> = ((-(n_i_3)));
            var _S450 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, _S449);
            var _S451 : f32 = anisotropicG1(_S450, lobes_1.alphas);
            G1_l_0 = _S451;
        }
        else
        {
            G1_l_0 = _S447;
        }
        return lobes_1.refract_weight * vec3<f32>(G1_l_0) * material_4.albedo / vec3<f32>(lobes_1.p_refract);
    }
    var _S452 : f32 = dot(n_i_3, l_1);
    var _S453 : f32 = smithG1(alpha_5, max(_S452, 0.0f));
    var _S454 : bool = (lobes_1.alphas.x) > 0.0f;
    if(_S454)
    {
        var _S455 : vec3<f32> = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        var _S456 : f32 = anisotropicG1(_S455, lobes_1.alphas);
        G1_l_0 = _S456;
    }
    else
    {
        G1_l_0 = _S453;
    }
    return vec3<f32>((lobes_1.reflect_weight * G1_l_0)) * lobes_1.F / vec3<f32>(lobes_1.p_reflect);
}

fn connectBSDF( in_dir_1 : vec3<f32>,  out_dir_0 : vec3<f32>,  n_5 : vec3<f32>,  material_5 : Material,  eta_i_3 : f32,  eta_o_3 : f32,  lobe_3 : u32,  random_init_0 : u32) -> SampleBSDF
{
    var random_state_2 : u32 = random_init_0;
    var _S457 : vec3<f32> = ((-(in_dir_1)));
    var _S458 : f32 = dot(n_5, _S457);
    var _S459 : f32 = (sign((_S458)));
    var _S460 : vec3<f32> = n_5 * vec3<f32>(_S459);
    var _S461 : f32 = material_5.roughness;
    var _S462 : f32 = _S461 * _S461;
    var _S463 : AnisotropicFrame = anisotropicFrame(material_5, _S460);
    var _S464 : vec3<f32> = (normalize((_S457 + out_dir_0)));
    var _S465 : bool = lobe_3 == u32(0);
    var ggx_n_1 : vec3<f32>;
    if(_S465)
    {
        var _S466 : vec3<f32> = sampleMaterialHalfVector(_S457, _S460, _S462, _S463, &(random_state_2));
        ggx_n_1 = _S466;
    }
    else
    {
        var _S467 : bool = lobe_3 == u32(1);
        if(_S467)
        {
            var _S468 : vec3<f32> = ((-(vec3<f32>(eta_i_3) * _S457 + vec3<f32>(eta_o_3) * out_dir_0)));
            var _S469 : vec3<f32> = (normalize((_S468)));
            var _S470 : f32 = (sign((dot(_S468, _S460))));
            var _S471 : vec3<f32> = _S469 * vec3<f32>(_S470);
            ggx_n_1 = _S471;
        }
        else
        {
            ggx_n_1 = _S464;
        }
    }
    var _S472 : BSDFLobes = bsdfLobes(in_dir_1, _S457, _S460, ggx_n_1, material_5, eta_i_3, eta_o_3, _S463);
    var lobes_2 : BSDFLobes = _S472;
    var _S473 : f32 = translucentShare(material_5);
    lobes_2.translucent_share = _S473;
    var _S474 : f32 = lobeDensity(dot(_S460, out_dir_0), dot(out_dir_0, ggx_n_1), abs(_S458), _S462, lobes_2, eta_i_3, eta_o_3, lobe_3);
    var _S475 : bool = !(_S474 > 0.0f);
    if(_S475)
    {
        var _S476 : vec3<f32> = vec3<f32>(0.0f);
        return SampleBSDF_x24init_0(_S476, _S476, u32(0), false, u32(0), 0.0f);
    }
    var _S477 : vec3<f32> = lobeThroughput(out_dir_0, _S460, _S462, material_5, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S477, random_state_2, lobe_3 == u32(1), lobe_3, _S474);
}

fn neeBSDF( in_dir_2 : vec3<f32>,  dir_6 : vec3<f32>,  n_6 : vec3<f32>,  material_6 : Material,  eta_i_4 : f32,  eta_o_4 : f32,  refracted_3 : bool,  pdf_2 : f32,  power_0 : bool,  random_state_3 : u32) -> vec3<f32>
{
    var _S478 : vec3<f32> = vec3<f32>(0.0f);
    var lobe_4 : u32 = u32(0);
    var f_1 : vec3<f32> = _S478;
    loop
    {
        if(lobe_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var _S479 : bool = lobe_4 == u32(0);
        if(_S479)
        {
        }
        var _S480 : bool;
        if(_S479)
        {
            var _S481 : f32 = rgb_to_greyscale(material_6.translucent);
            _S480 = _S481 > 0.0f;
        }
        else
        {
            _S480 = false;
        }
        var _S482 : bool;
        if(_S480)
        {
            var _S483 : f32 = dot(n_6, dir_6);
            var _S484 : vec3<f32> = ((-(in_dir_2)));
            _S482 = ((_S483 * dot(n_6, _S484)) < 0.0f) == refracted_3;
        }
        else
        {
            _S482 = (lobe_4 == u32(1)) == refracted_3;
        }
        var f_2 : vec3<f32>;
        if(_S482)
        {
            var _S485 : SampleBSDF = connectBSDF(in_dir_2, dir_6, n_6, material_6, eta_i_4, eta_o_4, lobe_4, random_state_3);
            var _S486 : bool = (_S485.pdf) > 0.0f;
            if(_S486)
            {
                if(power_0)
                {
                    var _S487 : f32 = _S485.pdf / pdf_2;
                    var f_3 : vec3<f32> = f_1 + _S485.throughput * vec3<f32>(_S485.pdf) / vec3<f32>((pdf_2 * (1.0f + _S487 * _S487)));
                    f_2 = f_3;
                }
                else
                {
                    var f_4 : vec3<f32> = f_1 + _S485.throughput * vec3<f32>(_S485.pdf) / vec3<f32>((_S485.pdf + pdf_2));
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
    var _S488 : bool = wrongSide_0(is_inside_2, false, dir_7, side_n_1);
    var _S489 : vec3<f32> = neeBSDF(in_dir_3, dir_7, surface_1.smooth_n, surface_1.material, eta_0.x, eta_0.y, _S488, pdf_3, false, random_state_4);
    return _S489;
}

fn SkySample_x24init_0( dir_8 : vec3<f32>,  radiance_1 : vec3<f32>,  color_0 : vec3<f32>,  random_state_5 : u32) -> SkySample
{
    var _S490 : SkySample;
    _S490.dir = dir_8;
    _S490.radiance = radiance_1;
    _S490.color = color_0;
    _S490.random_state = random_state_5;
    return _S490;
}

fn sampleSky_0( ray_0 : Ray,  surface_2 : Surface,  side_n_2 : vec3<f32>,  eta_1 : vec2<f32>,  is_inside_3 : bool,  init_random_state_0 : u32,  lobe_state_0 : u32) -> SkySample
{
    var _S491 : vec2<u32> = (textureDimensions(environment_cdf));
    const _S492 : vec2<u32> = vec2<u32>(u32(1), u32(0));
    var _S493 : vec2<u32> = _S491 - _S492;
    var _S494 : Random = pcg(init_random_state_0);
    var _S495 : Random = pcg(_S494.state);
    var _S496 : Random = pcg(_S495.state);
    var _S497 : Random = pcg(_S496.state);
    var _S498 : u32 = _S493.x;
    var _S499 : u32 = searchCDF_0(vec2<u32>(_S498, u32(0)), vec2<u32>(u32(0), u32(1)), _S493.y, _S494.value);
    var _S500 : u32 = searchCDF_0(vec2<u32>(u32(0), _S499), _S492, _S498, _S495.value);
    var _S501 : vec2<f32> = (vec2<f32>(f32(_S500), f32(_S499)) + vec2<f32>(_S496.value, _S497.value)) / vec2<f32>(_S493) * vec2<f32>(6.28318548202514648f, 3.14159274101257324f);
    var _S502 : f32 = _S501.y;
    var _S503 : f32 = sin(_S502);
    var _S504 : f32 = _S501.x;
    var _S505 : vec3<f32> = vec3<f32>(_S503 * cos(_S504), cos(_S502), _S503 * sin(_S504));
    var _S506 : f32 = environmentPdf_0(_S505);
    var _S507 : vec3<f32> = skyBSDF(ray_0.unit_direction, _S505, surface_2, side_n_2, eta_1, is_inside_3, _S506, lobe_state_0);
    var _S508 : bool = !(_S506 > 0.0f);
    var _S509 : bool;
    if(_S508)
    {
        _S509 = true;
    }
    else
    {
        _S509 = (all((_S507 == vec3<f32>(0.0f))));
    }
    if(_S509)
    {
        var _S510 : vec3<f32> = vec3<f32>(0.0f);
        return SkySample_x24init_0(_S505, _S510, _S510, _S497.state);
    }
    var _S511 : vec3<f32> = skyRadiance_0(ray_0.origin, surface_2, side_n_2, is_inside_3, _S505);
    return SkySample_x24init_0(_S505, _S511, _S507 * _S511, _S497.state);
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
    var _S512 : TreeSample;
    _S512.dir = dir_9;
    _S512.radiance = radiance_2;
    _S512.density = density_0;
    _S512.random_state = random_state_6;
    return _S512;
}

fn pickChild( first_1 : LightBounds,  second_1 : LightBounds,  p_10 : vec3<f32>,  normal_3 : vec3<f32>,  pick_0 : ptr<function, f32>,  probability_3 : ptr<function, f32>) -> u32
{
    var _S513 : f32 = importance(first_1, p_10, normal_3);
    var _S514 : f32 = importance(second_1, p_10, normal_3);
    var _S515 : vec2<f32> = vec2<f32>(_S513, _S514);
    var _S516 : bool = _S513 == 0.0f;
    var _S517 : bool;
    if(_S516)
    {
        _S517 = _S514 == 0.0f;
    }
    else
    {
        _S517 = false;
    }
    if(_S517)
    {
        return u32(2);
    }
    var _S518 : f32 = _S513 + _S514;
    var _S519 : bool = _S514 > 0.0f;
    if(_S519)
    {
        _S517 = ((*pick_0) * _S518) >= _S513;
    }
    else
    {
        _S517 = false;
    }
    var _S520 : u32 = select(u32(0), u32(1), _S517);
    var _S521 : f32 = min(((*pick_0) * _S518 - f32(_S520) * _S513) / _S515[_S520], 0.99999994039535522f);
    (*pick_0) = _S521;
    var _S522 : f32 = (*probability_3) * (_S515[_S520] / _S518);
    (*probability_3) = _S522;
    return _S520;
}

fn sampleSphere( center_1 : vec3<f32>,  radius_1 : f32,  p_11 : vec3<f32>,  u1_0 : f32,  u2_0 : f32) -> vec3<f32>
{
    var _S523 : vec3<f32> = center_1 - p_11;
    var _S524 : f32 = radius_1 * radius_1 / dot(_S523, _S523);
    var _S525 : f32 = u1_0 * _S524 / (1.0f + sqrt(max(1.0f - _S524, 0.0f)));
    var _S526 : f32 = 2.0f * u1_0;
    var _S527 : bool = _S524 >= 1.0f;
    var _S528 : f32 = select(_S525, _S526, _S527);
    var _S529 : f32 = sqrt(max(_S528 * (2.0f - _S528), 0.0f));
    var _S530 : f32 = 6.28318548202514648f * u2_0;
    var _S531 : vec3<f32> = vec3<f32>(_S529 * cos(_S530), 1.0f - _S528, _S529 * sin(_S530));
    var _S532 : vec3<f32> = (normalize((_S523)));
    var _S533 : vec3<f32> = tangentToWorld(_S531, _S532);
    return _S533;
}

fn pointLightRadiance( color_1 : vec3<f32>,  intensity_0 : f32,  radius_2 : f32) -> vec3<f32>
{
    return color_1 * vec3<f32>(intensity_0) / vec3<f32>((3.14159274101257324f * radius_2 * radius_2));
}

fn raySphere_0( center_2 : vec3<f32>,  radius_3 : f32,  ray_1 : Ray,  max_len_0 : f32) -> f32
{
    var _S534 : vec3<f32> = center_2 - ray_1.origin;
    var _S535 : f32 = dot(_S534, ray_1.unit_direction);
    var _S536 : f32 = dot(_S534, _S534) - _S535 * _S535;
    var _S537 : f32 = radius_3 * radius_3;
    var _S538 : bool = _S536 > _S537;
    if(_S538)
    {
        return 4.294967296e+09f;
    }
    var _S539 : f32 = sqrt(_S537 - _S536);
    var _S540 : f32 = _S535 - _S539;
    var _S541 : f32 = _S535 + _S539;
    var _S542 : bool = _S540 > 0.0000152587890625f;
    var _S543 : bool;
    if(_S542)
    {
        _S543 = _S540 < max_len_0;
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        return _S540;
    }
    var _S544 : bool = _S541 > 0.0000152587890625f;
    if(_S544)
    {
        _S543 = _S541 < max_len_0;
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        return _S541;
    }
    return 4.294967296e+09f;
}

fn shadowLift( light_n_0 : vec3<f32>,  light_offset_0 : f32,  start_5 : vec3<f32>,  end_0 : vec3<f32>) -> vec3<f32>
{
    var _S545 : f32 = (sign((dot(light_n_0, start_5 - end_0))));
    return light_n_0 * vec3<f32>((_S545 * light_offset_0));
}

fn sampleLightTree_0( origin_4 : vec3<f32>,  smooth_n_2 : vec3<f32>,  geometry_n_1 : vec3<f32>,  geometry_offset_1 : f32,  sided_0 : bool,  init_random_state_1 : u32,  face_1 : vec3<f32>) -> TreeSample
{
    var _S546 : Random = pcg(init_random_state_1);
    var _S547 : Random = pcg(_S546.state);
    var _S548 : Random = pcg(_S547.state);
    var _S549 : vec3<f32> = vec3<f32>(0.0f);
    var _S550 : TreeSample = TreeSample_x24init_0(_S549, _S549, 0.0f, _S548.state);
    var sample_0 : TreeSample = _S550;
    var _S551 : vec3<f32> = select(smooth_n_2, _S549, sided_0);
    var _S552 : vec3<f32> = vec3<f32>(geometry_offset_1);
    var start_6 : vec3<f32> = origin_4 + _S552 * smooth_n_2;
    var pick_1 : f32 = _S546.value;
    var probability_4 : f32 = 1.0f;
    var n_7 : u32 = u32(0);
    loop
    {
        var _S553 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
        if((_S553.x) == u32(0))
        {
        }
        else
        {
            break;
        }
        var _S554 : u32 = (access_light_tree(3u + 4u * (n_7)).w);
        var _S555 : u32 = n_7 + u32(1);
        var _S556 : LightBounds = (lightBounds((_S555)));
        var _S557 : LightBounds = (lightBounds((_S554)));
        var _S558 : u32 = pickChild(_S556, _S557, origin_4, _S551, &(pick_1), &(probability_4));
        var _S559 : bool = _S558 > u32(1);
        if(_S559)
        {
            return sample_0;
        }
        var _S560 : bool = _S558 == u32(1);
        var _S561 : u32 = select(_S555, _S554, _S560);
        n_7 = _S561;
    }
    var _S562 : bool = n_7 == u32(0);
    var _S563 : bool;
    if(_S562)
    {
        var _S564 : LightBounds = (lightBounds((u32(0))));
        var _S565 : f32 = importance(_S564, origin_4, _S551);
        _S563 = !(_S565 > 0.0f);
    }
    else
    {
        _S563 = false;
    }
    if(_S563)
    {
        return sample_0;
    }
    var _S566 : vec4<u32> = (access_light_tree(4u + 4u * (n_7)));
    var _S567 : bool = (_S566.x) == u32(2);
    var start_7 : vec3<f32>;
    var lift_n_0 : vec3<f32>;
    var shadow_1 : vec3<f32>;
    if(_S567)
    {
        var _S568 : Light = (lights[(_S566.y)]);
        if(sided_0)
        {
            var _S569 : f32 = (sign((dot(geometry_n_1, _S568.position - origin_4))));
            var lift_n_1 : vec3<f32> = smooth_n_2 * vec3<f32>(_S569);
            var _S570 : vec3<f32> = origin_4 + _S552 * lift_n_1;
            start_7 = _S570;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_7 = start_6;
            lift_n_0 = smooth_n_2;
        }
        var _S571 : bool = (_S568.variance) == 0.0f;
        if(_S571)
        {
            var _S572 : vec3<f32> = _S568.position - start_7;
            var _S573 : vec3<f32> = (normalize((_S572)));
            sample_0.dir = _S573;
            var _S574 : vec3<f32> = _S568.color * vec3<f32>(_S568.intensity) / vec3<f32>((dot(_S572, _S572) * probability_4));
            sample_0.radiance = _S574;
            shadow_1 = _S572;
        }
        else
        {
            var _S575 : vec3<f32> = sampleSphere(_S568.position, _S568.variance, start_7, _S547.value, _S548.value);
            sample_0.dir = _S575;
            var _S576 : f32 = sphereDensity(_S568.position, _S568.variance, start_7);
            var _S577 : f32 = probability_4 * _S576;
            sample_0.density = _S577;
            var _S578 : vec3<f32> = pointLightRadiance(_S568.color, _S568.intensity, _S568.variance);
            var _S579 : vec3<f32> = _S578 / vec3<f32>(sample_0.density);
            sample_0.radiance = _S579;
            var _S580 : f32 = raySphere_0(_S568.position, _S568.variance, Ray_x24init_0(start_7, sample_0.dir), 4.294967296e+09f);
            var _S581 : vec3<f32> = sample_0.dir * vec3<f32>(_S580);
            shadow_1 = _S581;
        }
    }
    else
    {
        var _S582 : u32 = _S566.y;
        var _S583 : u32 = ((instance_uint[(_S582) * INSTANCE_UINT_SIZE] / TRIANGLE_SIZE));
        var _S584 : u32 = _S583 + _S566.z;
        var _S585 : mat3x3<f32> = (worldTriangle((_S582), (_S584)));
        var _S586 : f32 = sqrt(_S547.value);
        var _S587 : vec2<f32> = vec2<f32>(_S586 * (1.0f - _S548.value), _S586 * _S548.value);
        var _S588 : vec3<f32> = (((_S585) * (vec3<f32>(1.0f - _S586, _S587))));
        if(sided_0)
        {
            var _S589 : f32 = (sign((dot(geometry_n_1, _S588 - origin_4))));
            var lift_n_2 : vec3<f32> = smooth_n_2 * vec3<f32>(_S589);
            var _S590 : vec3<f32> = origin_4 + _S552 * lift_n_2;
            start_7 = _S590;
            lift_n_0 = lift_n_2;
        }
        else
        {
            var _S591 : bool = !((dot(smooth_n_2, _S588 - start_6)) > 0.0f);
            if(_S591)
            {
                return sample_0;
            }
            start_7 = start_6;
            lift_n_0 = smooth_n_2;
        }
        var _S592 : Surface = (surfaceAt((Hit_x24init_0(_S587, _S582, _S584, u32(0), 0.0f)), (_S588), (_S548.state)));
        sample_0.random_state = _S592.random_state;
        var _S593 : vec3<f32> = _S588 - start_7;
        var _S594 : vec3<f32> = (normalize((_S593)));
        sample_0.dir = _S594;
        var _S595 : f32 = solidAngle(probability_4, cross(_S585[i32(1)] - _S585[i32(0)], _S585[i32(2)] - _S585[i32(0)]), _S593);
        sample_0.density = _S595;
        var _S596 : f32 = (sign((dot((vec3<f32>(0) - sample_0.dir), _S592.smooth_n))));
        var _S597 : vec3<f32> = _S592.material.emissive * vec3<f32>(max(_S596, 0.0f));
        var _S598 : vec3<f32> = select(_S597, _S549, _S592.skip);
        var _S599 : vec3<f32> = _S598 / vec3<f32>(sample_0.density);
        sample_0.radiance = _S599;
        var _S600 : vec3<f32> = shadowLift(_S592.smooth_n, _S592.geometry_offset, start_7, _S588);
        var _S601 : vec3<f32> = _S588 + _S600 - start_7;
        shadow_1 = _S601;
    }
    var _S602 : vec3<f32> = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, face_1);
    var _S603 : vec3<f32> = sample_0.radiance * _S602;
    var _S604 : bool = (all((_S602 == _S549)));
    var _S605 : vec3<f32> = select(_S603, _S549, _S604);
    sample_0.radiance = _S605;
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
    var _S606 : f32 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    var _S607 : bool = b_1 > 0.0f;
    var _S608 : f32 = select(1.0f, _S606, _S607);
    return _S608;
}

fn emissionWeight_0( vertex_0 : NEEVertex,  hit_1 : Hit,  light_point_1 : vec3<f32>) -> f32
{
    if(vertex_0.none)
    {
        return 1.0f;
    }
    var _S609 : u32 = (lightSlot((hit_1)));
    var _S610 : f32 = lightPdf_0(vertex_0.origin, vertex_0.smooth_n, vertex_0.start, _S609, light_point_1);
    var _S611 : f32 = powerHeuristic(vertex_0.pdf, _S610);
    return _S611;
}

var<workgroup> duplication_seeds_0 : array<u32, i32(576)>;

fn restir_duplicates_0( global_invocation_id_1 : vec3<u32>,  local_invocation_id_0 : vec3<u32>,  local_invocation_index_3 : u32)
{
    var seed_1 : u32;
    var _S612 : vec2<u32> = global_invocation_id_1.xy;
    var _S613 : vec2<i32> = vec2<i32>(_S612 - local_invocation_id_0.xy) - vec2<i32>(i32(8));
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
        var _S614 : vec2<i32> = _S613 + vec2<i32>(i32(i_0 % u32(24)), i32(i_0 / u32(24)));
        var _S615 : bool = (all((_S614 >= vec2<i32>(i32(0)))));
        var _S616 : bool;
        if(_S615)
        {
            var _S617 : vec2<u32> = (uniforms_uint.render_size);
            _S616 = (all((_S614 < vec2<i32>(_S617))));
        }
        else
        {
            _S616 = false;
        }
        if(_S616)
        {
            var _S618 : vec4<u32> = (textureLoad(reservoir_prev, (_S614), (u32(0)), 0));
            var _S619 : u32 = _S618.x;
            var _S620 : bool = (bitcast<f32>((_S618.z))) > 0.0f;
            var _S621 : u32 = select(u32(0), _S619, _S620);
            seed_1 = _S621;
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
    var _S622 : u32 = local_invocation_id_0.y;
    var _S623 : u32 = local_invocation_id_0.x;
    var _S624 : u32 = duplication_seeds_0[(_S622 + u32(8)) * u32(24) + _S623 + u32(8)];
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
            var _S625 : bool = (duplication_seeds_0[(_S622 + seed_1) * u32(24) + _S623 + x_1]) == _S624;
            var _S626 : u32 = select(u32(0), u32(1), _S625);
            var count_2 : u32 = count_1 + _S626;
            var x_2 : u32 = x_1 + u32(1);
            x_1 = x_2;
            count_1 = count_2;
        }
        var y_0 : u32 = seed_1 + u32(1);
        seed_1 = y_0;
    }
    var _S627 : f32 = f32(count_1 - u32(1)) / 288.0f;
    var _S628 : bool = _S624 != u32(0);
    var _S629 : f32 = select(0.0f, _S627, _S628);
    textureStore(duplication_out, (vec2<i32>(_S612)), 0, (vec4<u32>((bitcast<u32>((_S629))), u32(0), u32(0), u32(0))));
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
    var _S630 : Selection;
    _S630.r = r_4;
    _S630.w_sum = w_sum_0;
    _S630.color = color_2;
    _S630.random_state = random_state_7;
    return _S630;
}

fn stream( seed_2 : u32,  index_0 : u32) -> u32
{
    var _S631 : u32 = hash(index_0);
    var _S632 : u32 = hash((seed_2 ^ (_S631)));
    return _S632;
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
    var _S633 : Shift;
    _S633.f = f_5;
    _S633.jac = jac_1;
    return _S633;
}

fn neighborWeight( share_1 : f32,  c_n_2 : f32,  p_n_0 : f32,  c_pair_2 : f32,  g_here_0 : f32) -> f32
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

fn offer( sel_0 : ptr<function, Selection>,  candidate_0 : Reservoir,  weight_0 : vec3<f32>)
{
    var _S634 : f32 = rgb_to_greyscale(weight_0);
    var _S635 : bool = _S634 > 0.0f;
    var _S636 : bool;
    if(_S635)
    {
        _S636 = _S634 < 3.00000000549775576e+38f;
    }
    else
    {
        _S636 = false;
    }
    var _S637 : bool = !_S636;
    if(_S637)
    {
        return;
    }
    var _S638 : f32 = (*sel_0).w_sum + _S634;
    (*sel_0).w_sum = _S638;
    var _S639 : vec3<f32> = (*sel_0).color + weight_0;
    (*sel_0).color = _S639;
    var _S640 : Random = pcg((*sel_0).random_state);
    (*sel_0).random_state = _S640.state;
    var _S641 : bool = (_S640.value * (*sel_0).w_sum) <= _S634;
    if(_S641)
    {
        (*sel_0).r = candidate_0;
    }
    return;
}

fn offerShifted( sel_1 : ptr<function, Selection>,  r_5 : Reservoir,  shifted_0 : Shift,  mis_0 : f32)
{
    var candidate_1 : Reservoir = r_5;
    var _S642 : vec3<f32> = shifted_0.f / vec3<f32>(shifted_0.jac);
    candidate_1.f = _S642;
    var _S643 : f32 = r_5.jac * shifted_0.jac;
    candidate_1.jac = _S643;
    offer(&((*sel_1)), candidate_1, vec3<f32>(mis_0) * shifted_0.f * vec3<f32>(r_5.w));
    return;
}

fn finalize( sel_2 : Selection,  c_2 : f32) -> Reservoir
{
    var r_6 : Reservoir = sel_2.r;
    var _S644 : f32 = rgb_to_greyscale(r_6.f);
    var _S645 : f32 = sel_2.w_sum / _S644;
    var _S646 : bool = _S644 > 0.0f;
    var _S647 : f32 = select(0.0f, _S645, _S646);
    r_6.w = _S647;
    r_6.c = c_2;
    return r_6;
}

fn restir_spatial_0( global_invocation_id_2 : vec3<u32>)
{
    var _S648 : vec2<u32> = global_invocation_id_2.xy;
    var _S649 : vec2<i32> = vec2<i32>(_S648);
    var _S650 : vec3<f32> = vec3<f32>(0.0f);
    var _S651 : Domain = Domain_x24init_0(_S650, _S650, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_3 : Domain = _S651;
    var _S652 : bool = (currentDomain((_S649), &(dom_3)));
    var _S653 : bool = !_S652;
    if(_S653)
    {
        storeReservoir(reservoir_prev_out, (_S649), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S650, 0.0f, vec4<u32>(u32(0)), _S650, _S650)), (dom_3.hit));
        var _S654 : vec2<f32> = vec2<f32>(_S648);
        var _S655 : vec2<u32> = (uniforms_uint.render_size);
        var _S656 : vec2<f32> = _S654 / vec2<f32>(_S655.xy) * vec2<f32>(2.0f, -2.0f) + vec2<f32>(-1.0f, 1.0f);
        var _S657 : vec3<f32> = vec3<f32>(_S656, 1.0f);
        var _S658 : mat3x3<f32> = (uniforms_float.inv_view_matrix);
        var _S659 : vec3<f32> = (normalize(((((_S658) * (_S657))))));
        var _S660 : vec3<f32> = environment_0(_S659);
        textureStore(compute_out, (_S649), (u32(0)), (vec4<f32>(_S660, 1.0f)));
        var _S661 : u32 = (uniforms_uint.is_temporal);
        var _S662 : bool = _S661 == u32(1);
        if(_S662)
        {
            textureStore(compute_out, (_S649), (u32(1)), (vec4<f32>(0.0f)));
        }
        return;
    }
    var _S663 : Reservoir = (loadReservoir(reservoir_temp, (_S649)));
    var t_13 : u32 = u32(0);
    var count_3 : f32 = 0.0f;
    var c_sum_1 : f32 = _S663.c;
    loop
    {
        var _S664 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S664)
        {
        }
        else
        {
            break;
        }
        var _S665 : vec2<i32> = partner_0(_S649, t_13);
        var neighbor_0 : Domain = _S651;
        var _S666 : bool = (currentDomain((_S665), &(neighbor_0)));
        if(_S666)
        {
            var count_4 : f32 = count_3 + 1.0f;
            var _S667 : vec4<u32> = (textureLoad(reservoir_temp, (_S665), (u32(0)), 0));
            var c_sum_2 : f32 = c_sum_1 + (bitcast<f32>((_S667.w)));
            count_3 = count_4;
            c_sum_1 = c_sum_2;
        }
        var t_14 : u32 = t_13 + u32(1);
        t_13 = t_14;
    }
    var _S668 : f32 = _S663.c / max(count_3, 1.0f);
    var _S669 : f32 = rgb_to_greyscale(_S663.f);
    var _S670 : bool = count_3 == 0.0f;
    var _S671 : f32 = select(0.0f, 1.0f, _S670);
    var _S672 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S650, 0.0f, vec4<u32>(u32(0)), _S650, _S650), 0.0f, _S650, u32(0));
    var sel_3 : Selection = _S672;
    var _S673 : u32 = (uniforms_uint.frame);
    var _S674 : u32 = hash(_S673);
    var _S675 : u32 = global_invocation_id_2.x;
    var _S676 : vec2<u32> = (uniforms_uint.render_size);
    var _S677 : u32 = stream(_S674, _S675 + _S676.x * global_invocation_id_2.y);
    var _S678 : u32 = stream(_S677, u32(195));
    sel_3.random_state = _S678;
    t_13 = u32(0);
    var canonical_mis_0 : f32 = _S671;
    loop
    {
        var _S679 : u32 = (uniforms_uint.restir_neighbours);
        if(t_13 < _S679)
        {
        }
        else
        {
            break;
        }
        var _S680 : vec2<i32> = partner_0(_S649, t_13);
        var neighbor_dom_0 : Domain = _S651;
        var _S681 : bool = (currentDomain((_S680), &(neighbor_dom_0)));
        if(_S681)
        {
            var _S682 : Reservoir = (loadReservoir(reservoir_temp, (_S680)));
            var _S683 : vec4<u32> = (textureLoad(shift_data, (_S680), (t_13), 0));
            var _S684 : vec4<f32> = (bitcast<vec4<f32>>((_S683)));
            var _S685 : vec4<u32> = (textureLoad(shift_data, (_S649), (t_13), 0));
            var _S686 : vec4<f32> = (bitcast<vec4<f32>>((_S685)));
            var _S687 : f32 = pairShare(_S682.c, _S668, c_sum_1);
            var _S688 : bool = _S669 > 0.0f;
            var canonical_mis_1 : f32;
            if(_S688)
            {
                var _S689 : f32 = rgb_to_greyscale(_S686.xyz);
                var _S690 : f32 = canonicalWeight(_S687, _S668, _S669, _S682.c, _S689);
                var canonical_mis_2 : f32 = canonical_mis_0 + _S690;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            var _S691 : vec3<f32> = _S684.xyz;
            var _S692 : Shift = Shift_x24init_0(_S691, _S684.w);
            var _S693 : f32 = rgb_to_greyscale(_S682.f);
            var _S694 : f32 = rgb_to_greyscale(_S691);
            var _S695 : f32 = neighborWeight(_S687, _S682.c, _S693, _S668, _S694);
            offerShifted(&(sel_3), _S682, _S692, _S695);
            canonical_mis_0 = canonical_mis_1;
        }
        var t_15 : u32 = t_13 + u32(1);
        t_13 = t_15;
    }
    offerShifted(&(sel_3), _S663, Shift_x24init_0(_S663.f, 1.0f), canonical_mis_0);
    var _S696 : Reservoir = finalize(sel_3, c_sum_1);
    storeReservoir(reservoir_prev_out, (_S649), (_S696), (dom_3.hit));
    textureStore(reservoir_prev_out, (_S649), (u32(5)), (vec4<u32>((bitcast<vec2<u32>>((dom_3.hit.uv))), u32(0), u32(0))));
    var _S697 : Surface = (surfaceAt((dom_3.hit), (dom_3.x1), (sel_3.random_state)));
    var _S698 : vec3<f32> = (normalize((dom_3.x0 - dom_3.x1)));
    var _S699 : f32 = (sign((dot(_S698, _S697.smooth_n))));
    var _S700 : vec3<f32> = _S697.material.emissive * vec3<f32>(max(_S699, 0.0f));
    var _S701 : vec3<f32> = select(_S700, _S650, _S697.skip);
    var _S702 : vec3<f32> = clamp(sel_3.color + _S701, _S650, vec3<f32>(65519.0f));
    textureStore(compute_out, (_S649), (u32(0)), (vec4<f32>(_S702, 1.0f)));
    var _S703 : u32 = (uniforms_uint.is_temporal);
    var _S704 : bool = _S703 == u32(1);
    if(_S704)
    {
        textureStore(compute_out, (_S649), (u32(1)), (vec4<f32>(dom_3.x1, f32(dom_3.hit.instance_index))));
    }
    return;
}

fn NEEVertex_x24init_0( none_0 : bool,  pdf_4 : f32,  origin_5 : vec3<f32>,  smooth_n_3 : vec3<f32>,  start_8 : vec3<f32>) -> NEEVertex
{
    var _S705 : NEEVertex;
    _S705.none = none_0;
    _S705.pdf = pdf_4;
    _S705.origin = origin_5;
    _S705.smooth_n = smooth_n_3;
    _S705.start = start_8;
    return _S705;
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
    var _S706 : Vertex;
    _S706.rough = rough_0;
    _S706.lobe = lobe_6;
    _S706.pdf = pdf_5;
    _S706.cos = cos_0;
    _S706.inside = inside_0;
    return _S706;
}

fn Material_x24init_0( albedo_0 : vec3<f32>,  emissive_0 : vec3<f32>,  roughness_0 : f32,  metallic_0 : f32,  transmission_0 : f32,  ior_0 : f32,  absorption_0 : vec3<f32>,  specular_tint_0 : vec3<f32>,  specular_level_0 : f32,  translucent_0 : vec3<f32>,  sheen_2 : vec3<f32>,  sheen_roughness_0 : f32,  anisotropy_0 : f32,  anisotropic_rotation_0 : f32,  tangent_2 : vec3<f32>) -> Material
{
    var _S707 : Material;
    _S707.albedo = albedo_0;
    _S707.emissive = emissive_0;
    _S707.roughness = roughness_0;
    _S707.metallic = metallic_0;
    _S707.transmission = transmission_0;
    _S707.ior = ior_0;
    _S707.absorption = absorption_0;
    _S707.specular_tint = specular_tint_0;
    _S707.specular_level = specular_level_0;
    _S707.translucent = translucent_0;
    _S707.sheen = sheen_2;
    _S707.sheen_roughness = sheen_roughness_0;
    _S707.anisotropy = anisotropy_0;
    _S707.anisotropic_rotation = anisotropic_rotation_0;
    _S707.tangent = tangent_2;
    return _S707;
}

fn Surface_x24init_0( smooth_n_4 : vec3<f32>,  geometry_n_2 : vec3<f32>,  geometry_offset_2 : f32,  material_7 : Material,  skip_0 : bool,  random_state_8 : u32) -> Surface
{
    var _S708 : Surface;
    _S708.smooth_n = smooth_n_4;
    _S708.geometry_n = geometry_n_2;
    _S708.geometry_offset = geometry_offset_2;
    _S708.material = material_7;
    _S708.skip = skip_0;
    _S708.random_state = random_state_8;
    return _S708;
}

fn facingSign( transmission_1 : f32,  face_2 : vec3<f32>,  direction_0 : vec3<f32>) -> f32
{
    var _S709 : bool = transmission_1 > 0.0f;
    var _S710 : bool;
    if(_S709)
    {
        _S710 = true;
    }
    else
    {
        _S710 = (dot(face_2, direction_0)) < 0.0f;
    }
    var _S711 : f32;
    if(_S710)
    {
        _S711 = 1.0f;
    }
    else
    {
        _S711 = -1.0f;
    }
    return _S711;
}

fn facingRay_0( surface_3 : Surface,  dir_10 : vec3<f32>) -> Surface
{
    var _S712 : f32 = facingSign(surface_3.material.transmission, surface_3.geometry_n, dir_10);
    var _S713 : vec3<f32> = vec3<f32>(_S712);
    return Surface_x24init_0(surface_3.smooth_n * _S713, surface_3.geometry_n * _S713, surface_3.geometry_offset, surface_3.material, surface_3.skip, surface_3.random_state);
}

fn beerLambert( distance_1 : f32,  absorption_1 : vec3<f32>) -> vec3<f32>
{
    var _S714 : vec3<f32> = max(absorption_1, vec3<f32>(0.0000152587890625f));
    return exp(vec3<f32>(distance_1) * log(_S714));
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
    var _S715 : bool;
    if(open_0)
    {
        _S715 = prev_rough_0;
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        _S715 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S715 = false;
    }
    return _S715;
}

fn vertexEta_0( material_8 : Material,  n_dot_v_0 : f32) -> vec2<f32>
{
    var _S716 : bool = n_dot_v_0 < 0.0f;
    var _S717 : f32 = select(1.0f, material_8.ior, _S716);
    var _S718 : f32 = select(material_8.ior, 1.0f, _S716);
    return vec2<f32>(_S717, _S718);
}

fn samplesLights( material_9 : Material) -> bool
{
    var _S719 : bool = (material_9.roughness) > 0.0f;
    var _S720 : bool;
    if(_S719)
    {
        _S720 = true;
    }
    else
    {
        var _S721 : bool = (material_9.metallic) < 1.0f;
        if(_S721)
        {
            _S720 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S720 = false;
        }
    }
    return _S720;
}

fn sideNormal( surface_4 : Surface,  in_dir_4 : vec3<f32>) -> vec3<f32>
{
    var _S722 : bool = !((surface_4.material.transmission) > 0.0f);
    var _S723 : bool;
    if(_S722)
    {
        var _S724 : bool = isTranslucent_0(surface_4.material);
        _S723 = !_S724;
    }
    else
    {
        _S723 = false;
    }
    if(_S723)
    {
        _S723 = (dot(surface_4.smooth_n, (vec3<f32>(0) - in_dir_4))) > 0.0f;
    }
    else
    {
        _S723 = false;
    }
    var _S725 : vec3<f32> = select(surface_4.geometry_n, surface_4.smooth_n, _S723);
    return _S725;
}

fn BSDF( in_dir_5 : vec3<f32>,  out_dir_1 : vec3<f32>,  n_8 : vec3<f32>,  g_n_0 : vec3<f32>,  material_10 : Material,  eta_i_5 : f32,  eta_o_5 : f32,  random_state_9 : u32) -> vec3<f32>
{
    var _S726 : vec3<f32> = ((-(in_dir_5)));
    var _S727 : bool = (dot(g_n_0, _S726) * dot(g_n_0, out_dir_1)) > 0.0f;
    if(_S727)
    {
        var _S728 : SampleBSDF = connectBSDF(in_dir_5, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(0), random_state_9);
        var _S729 : SampleBSDF = connectBSDF(in_dir_5, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(2), random_state_9);
        return _S728.throughput * vec3<f32>(_S728.pdf) + _S729.throughput * vec3<f32>(_S729.pdf);
    }
    var _S730 : SampleBSDF = connectBSDF(in_dir_5, out_dir_1, n_8, material_10, eta_i_5, eta_o_5, u32(1), random_state_9);
    return _S730.throughput * vec3<f32>(_S730.pdf);
}

fn translucentCorrection( in_dir_6 : vec3<f32>,  out_dir_2 : vec3<f32>,  n_9 : vec3<f32>,  g_n_1 : vec3<f32>,  material_11 : Material,  eta_i_6 : f32,  eta_o_6 : f32,  random_state_10 : u32) -> vec3<f32>
{
    var _S731 : f32 = dot(n_9, out_dir_2);
    var _S732 : vec3<f32> = ((-(in_dir_6)));
    var _S733 : bool = (_S731 * dot(n_9, _S732)) < 0.0f;
    var _S734 : SampleBSDF = connectBSDF(in_dir_6, out_dir_2, n_9, material_11, eta_i_6, eta_o_6, u32(0), random_state_10);
    var _S735 : vec3<f32> = ((-(in_dir_6)));
    var _S736 : bool = (dot(g_n_1, _S735) * dot(g_n_1, out_dir_2)) > 0.0f;
    var _S737 : vec3<f32> = vec3<f32>(0.0f);
    var _S738 : vec3<f32> = _S734.throughput * vec3<f32>(_S734.pdf);
    var _S739 : f32 = select(1.0f, -1.0f, _S736);
    var _S740 : vec3<f32> = _S738 * vec3<f32>(_S739);
    var _S741 : vec3<f32> = select(_S737, _S740, _S733);
    return _S741;
}

fn translucentBSDF( in_dir_7 : vec3<f32>,  out_dir_3 : vec3<f32>,  n_10 : vec3<f32>,  g_n_2 : vec3<f32>,  material_12 : Material,  eta_i_7 : f32,  eta_o_7 : f32,  random_state_11 : u32) -> vec3<f32>
{
    var _S742 : vec3<f32> = BSDF(in_dir_7, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    var _S743 : vec3<f32> = translucentCorrection(in_dir_7, out_dir_3, n_10, g_n_2, material_12, eta_i_7, eta_o_7, random_state_11);
    return _S742 + _S743;
}

fn lightBSDF_0( in_dir_8 : vec3<f32>,  light_0 : TreeSample,  smooth_n_5 : vec3<f32>,  geometry_n_4 : vec3<f32>,  material_13 : Material,  eta_i_8 : f32,  eta_o_8 : f32,  competing_0 : bool,  random_state_12 : u32) -> vec3<f32>
{
    var _S744 : bool = !competing_0;
    var _S745 : bool;
    if(_S744)
    {
        _S745 = true;
    }
    else
    {
        _S745 = (light_0.density) == 0.0f;
    }
    if(_S745)
    {
        var _S746 : bool = isTranslucent_0(material_13);
        if(_S746)
        {
            var _S747 : vec3<f32> = translucentBSDF(in_dir_8, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
            return _S747 * light_0.radiance;
        }
        var _S748 : vec3<f32> = BSDF(in_dir_8, light_0.dir, smooth_n_5, geometry_n_4, material_13, eta_i_8, eta_o_8, random_state_12);
        return _S748 * light_0.radiance;
    }
    var _S749 : bool = (dot(geometry_n_4, (vec3<f32>(0) - in_dir_8)) * dot(geometry_n_4, light_0.dir)) <= 0.0f;
    var _S750 : vec3<f32> = neeBSDF(in_dir_8, light_0.dir, smooth_n_5, material_13, eta_i_8, eta_o_8, _S749, light_0.density, true, random_state_12);
    return _S750 * light_0.radiance * vec3<f32>(light_0.density);
}

fn safeDivide( a_6 : vec3<f32>,  b_2 : vec3<f32>) -> vec3<f32>
{
    var _S751 : vec3<f32> = a_6 / b_2;
    var _S752 : vec3<f32> = vec3<f32>(0.0f);
    var _S753 : vec3<bool> = b_2 == _S752;
    var _S754 : vec3<f32> = select(_S751, _S752, _S753);
    return _S754;
}

fn withEnd( r_7 : Reservoir,  end_type_0 : u32,  end_1 : u32,  f_6 : vec3<f32>) -> Reservoir
{
    var candidate_2 : Reservoir = r_7;
    var _S755 : u32 = (insertBits((r_7.path), (end_1), (u32(0)), (u32(5))));
    var _S756 : u32 = (insertBits((_S755), (end_type_0), (u32(12)), (u32(3))));
    candidate_2.path = _S756;
    candidate_2.f = f_6;
    return candidate_2;
}

fn sampleCosWeightedHemisphere( random_1_0 : f32,  random_2_0 : f32) -> vec3<f32>
{
    var _S757 : f32 = sqrt(random_1_0);
    var _S758 : f32 = 6.28318548202514648f * random_2_0;
    var _S759 : f32 = _S757 * cos(_S758);
    var _S760 : f32 = _S757 * sin(_S758);
    var _S761 : f32 = sqrt(max(0.0f, 1.0f - _S759 * _S759 - _S760 * _S760));
    return vec3<f32>(_S759, _S761, _S760);
}

fn sampleBSDF( in_dir_9 : vec3<f32>,  n_11 : vec3<f32>,  material_14 : Material,  eta_i_9 : f32,  eta_o_9 : f32,  random_init_1 : u32,  screen_space_0 : vec2<f32>) -> SampleBSDF
{
    var random_state_13 : u32 = random_init_1;
    var _S762 : vec3<f32> = ((-(in_dir_9)));
    var _S763 : f32 = dot(n_11, _S762);
    var _S764 : f32 = (sign((_S763)));
    var n_i_4 : vec3<f32> = n_11 * vec3<f32>(_S764);
    var _S765 : f32 = abs(_S763);
    var _S766 : f32 = material_14.roughness;
    var _S767 : f32 = _S766 * _S766;
    var _S768 : AnisotropicFrame = anisotropicFrame(material_14, n_i_4);
    var _S769 : vec3<f32> = sampleMaterialHalfVector(_S762, n_i_4, _S767, _S768, &(random_state_13));
    var _S770 : BSDFLobes = bsdfLobes(in_dir_9, _S762, n_i_4, _S769, material_14, eta_i_9, eta_o_9, _S768);
    var lobes_3 : BSDFLobes = _S770;
    var _S771 : f32 = translucentShare(material_14);
    lobes_3.translucent_share = _S771;
    var _S772 : vec3<f32> = vec3<f32>(1.0f);
    var _S773 : SampleBSDF = SampleBSDF_x24init_0(_S772, _S772, u32(0), false, u32(0), 0.0f);
    var sample_1 : SampleBSDF = _S773;
    var _S774 : Random = pcg(random_state_13);
    random_state_13 = _S774.state;
    var _S775 : bool = (_S774.value) < (lobes_3.p_diffuse);
    if(_S775)
    {
        var _S776 : Random = pcg(random_state_13);
        var _S777 : Random = pcg(_S776.state);
        sample_1.random_state = _S777.state;
        var _S778 : vec3<f32> = sampleCosWeightedHemisphere(_S776.value, _S777.value);
        var _S779 : bool = (_S774.value) < (lobes_3.p_diffuse * lobes_3.translucent_share);
        var _S780 : f32 = _S778.y;
        var _S781 : f32 = - _S780;
        var _S782 : f32 = select(_S780, _S781, _S779);
        var _S783 : vec3<f32> = tangentToWorld(vec3<f32>(_S778.x, _S782, _S778.z), n_i_4);
        sample_1.unit_direction = _S783;
        var _S784 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S767, material_14, lobes_3, u32(0));
        sample_1.throughput = _S784;
        var _S785 : f32 = lobeDensity(_S782, 0.0f, _S765, _S767, lobes_3, eta_i_9, eta_o_9, u32(0));
        sample_1.pdf = _S785;
        sample_1.refracted = _S779;
        return sample_1;
    }
    var _S786 : bool = (_S774.value) < (lobes_3.p_diffuse + lobes_3.p_refract);
    if(_S786)
    {
        sample_1.unit_direction = lobes_3.refracted;
        var _S787 : f32 = lobeDensity(0.0f, dot(sample_1.unit_direction, _S769), _S765, _S767, lobes_3, eta_i_9, eta_o_9, u32(1));
        sample_1.pdf = _S787;
        var _S788 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S767, material_14, lobes_3, u32(1));
        sample_1.throughput = _S788;
        sample_1.random_state = random_state_13;
        sample_1.refracted = true;
        sample_1.lobe = u32(1);
        return sample_1;
    }
    var _S789 : vec3<f32> = (normalize((reflect(in_dir_9, _S769))));
    sample_1.unit_direction = _S789;
    var _S790 : vec3<f32> = lobeThroughput(sample_1.unit_direction, n_i_4, _S767, material_14, lobes_3, u32(2));
    sample_1.throughput = _S790;
    sample_1.random_state = random_state_13;
    sample_1.lobe = u32(2);
    var _S791 : f32 = lobeDensity(0.0f, 0.0f, _S765, _S767, lobes_3, eta_i_9, eta_o_9, u32(2));
    sample_1.pdf = _S791;
    return sample_1;
}

fn withinInverseFootprint( pdf_6 : f32,  diffuse_0 : bool,  prev_cos_0 : f32,  distance_3 : f32,  threshold_1 : f32) -> bool
{
    var _S792 : bool = pdf_6 > 0.0f;
    var _S793 : bool;
    if(_S792)
    {
        if(diffuse_0)
        {
            _S793 = true;
        }
        else
        {
            _S793 = (pdf_6 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S793 = false;
    }
    return _S793;
}

fn roughLobe( pdf_7 : f32,  diffuse_1 : bool,  roughness_1 : f32) -> bool
{
    var _S794 : bool = pdf_7 > 0.0f;
    var _S795 : bool;
    if(_S794)
    {
        if(diffuse_1)
        {
            _S795 = true;
        }
        else
        {
            _S795 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S795 = false;
    }
    return _S795;
}

fn survivalProbability( throughput_1 : vec3<f32>,  density_1 : f32) -> f32
{
    var _S796 : vec3<f32> = throughput_1 / vec3<f32>(density_1);
    return clamp(max(_S796.x, max(_S796.y, _S796.z)), 0.0f, 1.0f);
}

fn walk_0( dom_4 : Domain,  r_8 : Reservoir,  replay_0 : bool,  scale_1 : f32,  sel_4 : ptr<function, Selection>) -> Shift
{
    var arrived_end_0 : Shift;
    var _S797 : vec3<f32> = vec3<f32>(0.0f);
    var _S798 : Shift = Shift_x24init_0(_S797, 0.0f);
    var _S799 : u32 = (extractBits((r_8.path), (u32(0)), (u32(5))));
    var _S800 : u32 = (extractBits((r_8.path), (u32(5)), (u32(5))));
    var _S801 : u32 = (extractBits((r_8.path), (u32(10)), (u32(2))));
    var _S802 : u32 = (extractBits((r_8.path), (u32(12)), (u32(3))));
    var is_inside_4 : bool;
    if(replay_0)
    {
        var _S803 : bool = _S802 >= u32(3);
        var _S804 : u32 = select(u32(0), u32(1), _S803);
        var _S805 : u32 = _S799 + _S804;
        var _S806 : u32 = (uniforms_uint.max_bounces);
        is_inside_4 = _S805 > _S806;
    }
    else
    {
        is_inside_4 = false;
    }
    if(is_inside_4)
    {
        return _S798;
    }
    var _S807 : u32 = _S800 - u32(1);
    var _S808 : bool = _S802 == u32(3);
    var _S809 : u32 = select(u32(0), u32(1), _S808);
    var _S810 : u32 = _S799 + _S809;
    var _S811 : bool = _S801 == u32(0);
    var _S812 : u32 = select(_S807, _S810, _S811);
    var _S813 : Hit = Hit_x24init_0((bitcast<vec2<f32>>((r_8.rc.zw))), r_8.rc.x, r_8.rc.y, u32(0), 0.0f);
    var _S814 : vec3<f32> = (normalize((dom_4.x1 - dom_4.x0)));
    var _S815 : Ray = Ray_x24init_0(dom_4.x1, _S814);
    var ray_2 : Ray = _S815;
    var hit_2 : Hit = dom_4.hit;
    var _S816 : vec3<f32> = vec3<f32>(1.0f);
    var _S817 : NEEVertex = NEEVertex_x24init_0(true, 0.0f, _S797, _S797, _S797);
    var nee_vertex_0 : NEEVertex = _S817;
    var _S818 : Vertex = Vertex_x24init_0(false, u32(0), 0.0f, 0.0f, false);
    var prev_0 : Vertex = _S818;
    var _S819 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S797, 0.0f, vec4<u32>(u32(0)), _S797, _S797);
    var chain_0 : Reservoir = _S819;
    chain_0.seed = r_8.seed;
    is_inside_4 = false;
    var threshold_2 : f32 = 0.0f;
    var chain_throughput_0 : vec3<f32> = _S797;
    var reconnection_0 : vec3<f32> = _S797;
    var b_3 : u32 = u32(0);
    var throughput_2 : vec3<f32> = _S816;
    var density_2 : f32 = 1.0f;
    var sky_pdf_0 : f32 = 0.0f;
    loop
    {
        var _S820 : bool = (hit_2.is_point_light) == u32(1);
        var _S821 : Surface = Surface_x24init_0(_S797, _S797, 0.0f, Material_x24init_0(_S797, _S797, 0.0f, 0.0f, 0.0f, 0.0f, _S797, _S816, 1.0f, _S797, _S797, 0.5f, 0.0f, 0.0f, _S797), false, u32(0));
        var _S822 : bool = !_S820;
        var scatter_0 : bool;
        var geometry_density_2 : f32;
        var front_n_0 : vec3<f32>;
        var throughput_3 : vec3<f32>;
        var surface_5 : Surface;
        if(_S822)
        {
            var _S823 : u32 = stream(r_8.seed, b_3);
            var _S824 : Surface = (surfaceAt((hit_2), (ray_2.origin), (_S823)));
            var surface_6 : Surface = facingRay_0(_S824, ray_2.unit_direction);
            if(is_inside_4)
            {
                var _S825 : vec3<f32> = beerLambert(hit_2.distance, surface_6.material.absorption);
                var _S826 : vec3<f32> = throughput_2 * _S825;
                front_n_0 = _S826;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            var _S827 : bool = !surface_6.skip;
            var geometry_density_3 : f32 = geometryDensity(surface_6.geometry_n, ray_2.unit_direction, hit_2.distance);
            var _S828 : bool = b_3 == u32(0);
            if(_S828)
            {
                var _S829 : f32 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S829;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            var _S830 : vec3<f32> = front_n_0;
            var _S831 : f32 = geometry_density_2;
            scatter_0 = _S827;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S831;
            surface_5 = surface_6;
            front_n_0 = _S824.smooth_n;
            throughput_3 = _S830;
        }
        else
        {
            scatter_0 = false;
            geometry_density_2 = 0.0f;
            surface_5 = _S821;
            front_n_0 = _S797;
            throughput_3 = throughput_2;
        }
        var _S832 : bool = withinFootprint(scatter_0, prev_0.rough, prev_0.pdf, geometry_density_2, threshold_2);
        var _S833 : Surface = surface_5;
        var _S834 : Surface = surface_5;
        var _S835 : f32 = dot(surface_5.smooth_n, (vec3<f32>(0) - ray_2.unit_direction));
        var _S836 : vec2<f32> = vertexEta_0(_S833.material, _S835);
        var _S837 : bool;
        if(scatter_0)
        {
            var _S838 : bool = samplesLights(_S833.material);
            _S837 = _S838;
        }
        else
        {
            _S837 = false;
        }
        var _S839 : vec3<f32> = sideNormal(surface_5, ray_2.unit_direction);
        var _S840 : f32 = (sign((dot((vec3<f32>(0) - ray_2.unit_direction), front_n_0))));
        var _S841 : vec3<f32> = _S833.material.emissive * vec3<f32>(max(_S840, 0.0f));
        var emission_0 : vec3<f32>;
        if(_S820)
        {
            var _S842 : vec3<f32> = (calculatePointLightContrib((hit_2.instance_index)));
            emission_0 = _S842;
        }
        else
        {
            emission_0 = _S841;
        }
        var _S843 : f32 = rgb_to_greyscale(emission_0);
        var _S844 : bool = _S843 > 0.0f;
        var emission_1 : vec3<f32>;
        if(_S844)
        {
            var _S845 : f32 = emissionWeight_0(nee_vertex_0, hit_2, ray_2.origin);
            var emission_2 : vec3<f32> = emission_0 * vec3<f32>(_S845);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        var _S846 : bool;
        if(replay_0)
        {
            _S846 = _S801 == u32(1);
        }
        else
        {
            _S846 = false;
        }
        var _S847 : bool;
        if(_S846)
        {
            _S847 = b_3 > _S800;
        }
        else
        {
            _S847 = false;
        }
        var _S848 : bool;
        if(_S847)
        {
            _S848 = b_3 == _S799;
        }
        else
        {
            _S848 = false;
        }
        var _S849 : bool;
        if(_S848)
        {
            var _S850 : bool = _S802 == u32(1);
            if(_S850)
            {
                _S849 = true;
            }
            else
            {
                _S849 = _S802 == u32(2);
            }
        }
        else
        {
            _S849 = false;
        }
        if(_S849)
        {
            var _S851 : bool = _S820 != (_S802 == u32(2));
            if(_S851)
            {
                return _S798;
            }
            return Shift_x24init_0(throughput_3 * emission_1 / vec3<f32>(r_8.jac), density_2 / r_8.jac);
        }
        var _S852 : u32 = (extractBits((chain_0.path), (u32(10)), (u32(2))));
        var _S853 : bool = _S852 == u32(1);
        var here_0 : Reservoir = chain_0;
        var _S854 : u32 = (insertBits((u32(0)), (b_3), (u32(5)), (u32(5))));
        var _S855 : u32 = (insertBits((_S854), (u32(1)), (u32(10)), (u32(2))));
        var _S856 : u32 = (insertBits((_S855), (prev_0.lobe), (u32(15)), (u32(2))));
        var _S857 : bool = prev_0.inside;
        var _S858 : u32 = select(u32(0), u32(1), _S857);
        var _S859 : u32 = (insertBits((_S856), (_S858), (u32(20)), (u32(1))));
        here_0.path = _S859;
        var _S860 : f32 = prev_0.pdf * geometry_density_2;
        here_0.jac = _S860;
        var _S861 : vec4<u32> = vec4<u32>(hit_2.instance_index, hit_2.triangle_index, (bitcast<vec2<u32>>((hit_2.uv))));
        here_0.rc = _S861;
        var _S862 : bool;
        if(replay_0)
        {
            _S862 = _S801 == u32(1);
        }
        else
        {
            _S862 = false;
        }
        var _S863 : bool;
        if(_S862)
        {
            _S863 = b_3 == _S800;
        }
        else
        {
            _S863 = false;
        }
        var _S864 : bool = b_3 == _S812;
        var _S865 : bool;
        if(_S864)
        {
            var _S866 : bool = !scatter_0;
            if(_S866)
            {
                _S865 = true;
            }
            else
            {
                var _S867 : bool = _S801 != u32(1);
                if(_S867)
                {
                    _S865 = _S801 != u32(3);
                }
                else
                {
                    _S865 = false;
                }
            }
        }
        else
        {
            _S865 = false;
        }
        var _S868 : bool;
        if(_S865)
        {
            _S868 = _S801 == u32(2);
        }
        else
        {
            _S868 = false;
        }
        var _S869 : bool;
        if(_S868)
        {
            _S869 = !_S832;
        }
        else
        {
            _S869 = false;
        }
        var _S870 : bool;
        if(_S869)
        {
            _S870 = _S802 != u32(4);
        }
        else
        {
            _S870 = false;
        }
        var _S871 : bool = _S800 == _S799;
        var _S872 : bool;
        if(_S871)
        {
            _S872 = _S802 == u32(0);
        }
        else
        {
            _S872 = false;
        }
        var _S873 : bool;
        if(_S872)
        {
            _S873 = (hit_2.instance_index) == (_S813.instance_index);
        }
        else
        {
            _S873 = false;
        }
        var _S874 : bool;
        if(_S873)
        {
            _S874 = (hit_2.triangle_index) == (_S813.triangle_index);
        }
        else
        {
            _S874 = false;
        }
        var _S875 : bool;
        if(_S874)
        {
            _S875 = _S832;
        }
        else
        {
            _S875 = false;
        }
        var _S876 : bool = select(_S870, _S875, _S863);
        var _S877 : bool;
        if(_S837)
        {
            _S877 = select(scatter_0, _S876, replay_0);
        }
        else
        {
            _S877 = false;
        }
        var _S878 : TreeSample = TreeSample_x24init_0(_S797, _S797, 0.0f, u32(0));
        var _S879 : bool;
        var lit_0 : vec3<f32>;
        var light_1 : TreeSample;
        if(_S877)
        {
            var _S880 : vec3<f32> = ray_2.origin;
            var _S881 : Surface = surface_5;
            var _S882 : Surface = surface_5;
            var _S883 : bool = isTranslucent_0(_S833.material);
            var _S884 : u32 = stream(r_8.seed, b_3 + u32(64));
            var _S885 : bool = !((_S833.material.transmission) > 0.0f);
            if(_S885)
            {
                var _S886 : bool = isTranslucent_0(_S833.material);
                _S879 = !_S886;
            }
            else
            {
                _S879 = false;
            }
            var _S887 : vec3<f32> = select(_S797, _S881.geometry_n, _S879);
            var _S888 : TreeSample = sampleLightTree_0(_S880, _S834.smooth_n, _S881.geometry_n, _S882.geometry_offset, _S883, _S884, _S887);
            var _S889 : bool = (any(((_S888.radiance) != _S797)));
            if(_S889)
            {
                var _S890 : f32 = _S836.x;
                var _S891 : f32 = _S836.y;
                var _S892 : u32 = (uniforms_uint.max_bounces);
                var _S893 : vec3<f32> = lightBSDF_0(ray_2.unit_direction, _S888, _S834.smooth_n, _S839, _S833.material, _S890, _S891, b_3 < _S892, surface_5.random_state);
                lit_0 = _S893;
            }
            else
            {
                lit_0 = _S797;
            }
            light_1 = _S888;
        }
        else
        {
            light_1 = _S878;
            lit_0 = _S797;
        }
        var wrong_side_0 : bool;
        var refracted_4 : bool;
        var _S894 : bool;
        var _S895 : bool;
        var density_3 : f32;
        var throughput_4 : vec3<f32>;
        if(_S863)
        {
            var _S896 : bool = (hit_2.instance_index) != (_S813.instance_index);
            if(_S896)
            {
                _S879 = true;
            }
            else
            {
                _S879 = (hit_2.triangle_index) != (_S813.triangle_index);
            }
            if(_S879)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S832;
            }
            if(wrong_side_0)
            {
                return _S798;
            }
            var throughput_5 : vec3<f32> = throughput_3 * vec3<f32>(geometry_density_2);
            var density_4 : f32 = density_2 * geometry_density_2;
            if(_S871)
            {
                refracted_4 = _S802 == u32(1);
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_5 * emission_1 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S871)
            {
                _S894 = _S802 == u32(0);
            }
            else
            {
                _S894 = false;
            }
            if(_S894)
            {
                var _S897 : bool = !_S837;
                if(_S897)
                {
                    is_inside_4 = true;
                }
                else
                {
                    var _S898 : f32 = rgb_to_greyscale(light_1.radiance);
                    is_inside_4 = !(_S898 > 0.0f);
                }
                if(is_inside_4)
                {
                    return _S798;
                }
                return Shift_x24init_0(throughput_5 * lit_0 / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            if(_S871)
            {
                _S895 = _S802 == u32(4);
            }
            else
            {
                _S895 = false;
            }
            if(_S895)
            {
                var _S899 : bool = !_S837;
                if(_S899)
                {
                    return _S798;
                }
                var _S900 : f32 = environmentPdf_0(r_8.dir);
                var _S901 : vec3<f32> = skyBSDF(ray_2.unit_direction, r_8.dir, surface_5, _S839, _S836, is_inside_4, _S900, surface_5.random_state);
                return Shift_x24init_0(throughput_5 * _S901 * r_8.radiance / vec3<f32>(r_8.jac), density_4 / r_8.jac);
            }
            var _S902 : u32 = (extractBits((r_8.path), (u32(19)), (u32(1))));
            var _S903 : bool = _S837 != (_S902 == u32(1));
            if(_S903)
            {
                return _S798;
            }
            throughput_4 = throughput_5;
            density_3 = density_4;
        }
        else
        {
            if(replay_0)
            {
                _S879 = _S864;
            }
            else
            {
                _S879 = false;
            }
            if(_S879)
            {
                var _S904 : bool = !scatter_0;
                if(_S904)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    var _S905 : bool = _S801 != u32(1);
                    if(_S905)
                    {
                        wrong_side_0 = _S801 != u32(3);
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
                var _S906 : bool = _S801 == u32(2);
                if(_S906)
                {
                    _S846 = _S837;
                }
                else
                {
                    _S846 = false;
                }
                if(_S846)
                {
                    _S846 = !_S832;
                }
                else
                {
                    _S846 = false;
                }
                if(_S846)
                {
                    _S846 = _S802 == u32(4);
                }
                else
                {
                    _S846 = false;
                }
                if(_S846)
                {
                    var _S907 : u32 = stream(r_8.seed, b_3 + u32(256));
                    var _S908 : SkySample = sampleSky_0(ray_2, surface_5, _S839, _S836, is_inside_4, _S907, surface_5.random_state);
                    return Shift_x24init_0(throughput_3 * _S908.color, 1.0f);
                }
                if(_S906)
                {
                    is_inside_4 = _S837;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = !_S832;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    var _S909 : f32 = rgb_to_greyscale(light_1.radiance);
                    var _S910 : bool = !(_S909 > 0.0f);
                    if(_S910)
                    {
                        return _S798;
                    }
                    return Shift_x24init_0(throughput_3 * lit_0, 1.0f);
                }
                if(_S811)
                {
                    is_inside_4 = _S802 == u32(2);
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    is_inside_4 = _S820;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                if(_S811)
                {
                    is_inside_4 = _S802 == u32(1);
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
                    is_inside_4 = !_S832;
                }
                else
                {
                    is_inside_4 = false;
                }
                if(is_inside_4)
                {
                    return Shift_x24init_0(throughput_3 * emission_1, 1.0f);
                }
                return _S798;
            }
            else
            {
                var _S911 : bool = !replay_0;
                if(_S911)
                {
                    refracted_4 = scatter_0;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    var _S912 : bool = b_3 > u32(0);
                    if(_S912)
                    {
                        var candidate_3 : Reservoir = chain_0;
                        if(_S853)
                        {
                            var _S913 : vec3<f32> = safeDivide(throughput_3 * emission_1, chain_throughput_0);
                            candidate_3.radiance = _S913;
                        }
                        else
                        {
                            if(_S832)
                            {
                                candidate_3 = here_0;
                            }
                        }
                        var _S914 : vec3<f32> = throughput_3 * emission_1;
                        var _S915 : Reservoir = withEnd(candidate_3, u32(1), b_3, _S914);
                        offer(&((*sel_4)), _S915, _S914 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S837)
                    {
                        var _S916 : vec3<f32> = throughput_3 * lit_0;
                        var candidate_4 : Reservoir = chain_0;
                        if(_S853)
                        {
                            var _S917 : vec3<f32> = safeDivide(_S916, chain_throughput_0);
                            candidate_4.radiance = _S917;
                        }
                        else
                        {
                            if(_S832)
                            {
                                candidate_4 = here_0;
                                var _S918 : u32 = (insertBits((candidate_4.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_4.path = _S918;
                                candidate_4.dir = light_1.dir;
                                candidate_4.radiance = light_1.radiance;
                            }
                            else
                            {
                                var _S919 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S920 : u32 = (insertBits((_S919), (u32(2)), (u32(10)), (u32(2))));
                                candidate_4.path = _S920;
                            }
                        }
                        var _S921 : Reservoir = withEnd(candidate_4, u32(0), b_3, _S916);
                        offer(&((*sel_4)), _S921, _S916 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                    if(_S837)
                    {
                        var _S922 : bool = environmentMapped_0();
                        _S894 = _S922;
                    }
                    else
                    {
                        _S894 = false;
                    }
                    if(_S894)
                    {
                        var _S923 : u32 = (uniforms_uint.max_bounces);
                        _S895 = b_3 < _S923;
                    }
                    else
                    {
                        _S895 = false;
                    }
                    if(_S895)
                    {
                        var _S924 : u32 = stream(r_8.seed, b_3 + u32(256));
                        var _S925 : SkySample = sampleSky_0(ray_2, surface_5, _S839, _S836, is_inside_4, _S924, surface_5.random_state);
                        var _S926 : vec3<f32> = throughput_3 * _S925.color;
                        var candidate_5 : Reservoir = chain_0;
                        if(_S853)
                        {
                            var _S927 : vec3<f32> = safeDivide(_S926, chain_throughput_0);
                            candidate_5.radiance = _S927;
                        }
                        else
                        {
                            if(_S832)
                            {
                                candidate_5 = here_0;
                                var _S928 : u32 = (insertBits((candidate_5.path), (u32(1)), (u32(19)), (u32(1))));
                                candidate_5.path = _S928;
                                candidate_5.dir = _S925.dir;
                                candidate_5.radiance = _S925.radiance;
                            }
                            else
                            {
                                var _S929 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                                var _S930 : u32 = (insertBits((_S929), (u32(2)), (u32(10)), (u32(2))));
                                candidate_5.path = _S930;
                            }
                        }
                        var _S931 : Reservoir = withEnd(candidate_5, u32(4), b_3, _S926);
                        offer(&((*sel_4)), _S931, _S926 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                    }
                }
            }
            throughput_4 = throughput_3;
            density_3 = density_2;
        }
        var _S932 : bool;
        var _S933 : bool;
        var _S934 : bool;
        var _S935 : bool;
        var _S936 : bool;
        var _S937 : bool;
        var _S938 : bool;
        var _S939 : bool;
        var again_0 : bool;
        var density_5 : f32;
        var survival_probability_0 : f32;
        if(scatter_0)
        {
            if(replay_0)
            {
                _S879 = _S864;
            }
            else
            {
                _S879 = false;
            }
            var _S940 : u32 = (extractBits((r_8.path), (u32(15)), (u32(2))));
            var _S941 : u32 = (extractBits((r_8.path), (u32(17)), (u32(2))));
            var _S942 : u32 = select(_S940, _S941, _S863);
            var refracted_5 : bool = _S942 == u32(1);
            var _S943 : SampleBSDF = SampleBSDF_x24init_0(_S797, _S797, u32(0), false, u32(0), 0.0f);
            var lobe_7 : SampleBSDF = _S943;
            var dir_11 : vec3<f32>;
            var reconnection_1 : vec3<f32>;
            var lobe_index_0 : u32;
            if(_S879)
            {
                var _S944 : u32 = (extractBits((r_8.path), (u32(20)), (u32(1))));
                var _S945 : bool = is_inside_4 != (_S944 == u32(1));
                if(_S945)
                {
                    return _S798;
                }
                var _S946 : bool = _S801 == u32(1);
                if(_S946)
                {
                    var _S947 : vec3<f32> = (hitPosition((_S813)));
                    dir_11 = _S947;
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
                    var _S948 : bool = isTranslucent_0(_S833.material);
                    if(_S948)
                    {
                        wrong_side_0 = _S942 == u32(0);
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S949 : vec3<f32> = dir_11 - ray_2.origin;
                        var _S950 : vec3<f32> = select(r_8.dir, _S949, _S946);
                        refracted_4 = (dot(_S834.smooth_n, _S950) * _S835) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S946)
                {
                    var _S951 : vec3<f32> = ray_2.origin;
                    var _S952 : Surface = surface_5;
                    var _S953 : vec3<f32> = (vec3<f32>(0) - _S834.smooth_n);
                    var _S954 : bool = is_inside_4 != refracted_4;
                    var _S955 : vec3<f32> = select(_S834.smooth_n, _S953, _S954);
                    var _S956 : vec3<f32> = (normalize((dir_11 - (_S951 + vec3<f32>(_S952.geometry_offset) * _S955))));
                    reconnection_1 = _S956;
                }
                else
                {
                    reconnection_1 = r_8.dir;
                }
                var _S957 : bool = wrongSide_0(is_inside_4, refracted_4, reconnection_1, _S839);
                if(_S957)
                {
                    return _S798;
                }
                var _S958 : vec3<f32> = dir_11;
                dir_11 = reconnection_1;
                lobe_index_0 = _S942;
                wrong_side_0 = false;
                reconnection_1 = _S958;
            }
            else
            {
                var _S959 : bool = !_S863;
                if(_S959)
                {
                    var _S960 : f32 = _S836.x;
                    var _S961 : f32 = _S836.y;
                    var _S962 : vec2<f32> = vec2<f32>(0.0f);
                    var _S963 : SampleBSDF = sampleBSDF(ray_2.unit_direction, _S834.smooth_n, _S833.material, _S960, _S961, surface_5.random_state, _S962);
                    var bsdf_sampled_0 : SampleBSDF = _S963;
                    var wrong_side_1 : bool = wrongSide_0(is_inside_4, bsdf_sampled_0.refracted, bsdf_sampled_0.unit_direction, _S839);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S833.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        var _S964 : SampleBSDF = sampleBSDF(bsdf_sampled_0.unit_direction, surface_5.geometry_n, _S833.material, _S960, _S961, bsdf_sampled_0.random_state, _S962);
                        bsdf_sampled_0.unit_direction = _S964.unit_direction;
                        bsdf_sampled_0.refracted = _S964.refracted;
                        bsdf_sampled_0.throughput = _S964.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            var _S965 : vec3<f32> = bsdf_sampled_0.unit_direction - vec3<f32>((2.0f * dot(bsdf_sampled_0.unit_direction, surface_5.geometry_n))) * surface_5.geometry_n;
                            bsdf_sampled_0.unit_direction = _S965;
                        }
                    }
                    var _S966 : u32 = bsdf_sampled_0.lobe;
                    var _S967 : vec3<f32> = bsdf_sampled_0.unit_direction;
                    var _S968 : bool = bsdf_sampled_0.refracted;
                    lobe_7 = bsdf_sampled_0;
                    var _S969 : f32 = bsdf_sampled_0.pdf;
                    var _S970 : f32 = select(_S969, 0.0f, wrong_side_1);
                    lobe_7.pdf = _S970;
                    dir_11 = _S967;
                    lobe_index_0 = _S966;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S968;
                }
                else
                {
                    dir_11 = r_8.dir;
                    lobe_index_0 = _S942;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S879)
            {
                _S894 = true;
            }
            else
            {
                _S894 = _S863;
            }
            if(_S894)
            {
                var _S971 : SampleBSDF = connectBSDF(ray_2.unit_direction, dir_11, _S834.smooth_n, _S833.material, _S836.x, _S836.y, lobe_index_0, surface_5.random_state);
                lobe_7 = _S971;
            }
            var _S972 : bool = lobe_index_0 != u32(0);
            if(_S972)
            {
                var _S973 : bool = (_S833.material.roughness) == 0.0f;
                if(_S973)
                {
                    _S895 = true;
                }
                else
                {
                    var _S974 : bool = lobe_index_0 == u32(1);
                    if(_S974)
                    {
                        _S895 = (_S836.x) == (_S836.y);
                    }
                    else
                    {
                        _S895 = false;
                    }
                }
            }
            else
            {
                _S895 = false;
            }
            var _S975 : bool = isTranslucent_0(_S833.material);
            if(_S975)
            {
                _S932 = lobe_index_0 == u32(0);
            }
            else
            {
                _S932 = false;
            }
            if(_S932)
            {
                _S933 = (dot(dir_11, surface_5.geometry_n)) < 0.0f;
            }
            else
            {
                _S933 = false;
            }
            if(_S837)
            {
                _S934 = !_S895;
            }
            else
            {
                _S934 = false;
            }
            if(_S934)
            {
                _S935 = !wrong_side_0;
            }
            else
            {
                _S935 = false;
            }
            if(_S935)
            {
                var _S976 : f32 = lobe_7.pdf;
                var _S977 : vec3<f32> = ray_2.origin;
                var _S978 : bool = isTranslucent_0(_S833.material);
                var _S979 : vec3<f32> = select(_S834.smooth_n, _S797, _S978);
                var _S980 : vec3<f32> = ray_2.origin;
                var _S981 : Surface = surface_5;
                var _S982 : vec3<f32> = (vec3<f32>(0) - _S834.smooth_n);
                var _S983 : vec3<f32> = select(_S834.smooth_n, _S982, _S933);
                var _S984 : NEEVertex = NEEVertex_x24init_0(false, _S976, _S977, _S979, _S980 + vec3<f32>(_S981.geometry_offset) * _S983);
                nee_vertex_0 = _S984;
            }
            else
            {
                var _S985 : bool = lobe_index_0 != u32(1);
                if(_S985)
                {
                    _S936 = true;
                }
                else
                {
                    _S936 = (_S836.x) != (_S836.y);
                }
                if(_S936)
                {
                    nee_vertex_0.none = true;
                }
            }
            var _S986 : bool = lobe_index_0 == u32(0);
            var _S987 : bool = withinInverseFootprint(lobe_7.pdf, _S986, prev_0.cos, hit_2.distance, threshold_2);
            var _S988 : Surface = surface_5;
            var _S989 : f32 = dot(dir_11, surface_5.geometry_n);
            var _S990 : bool = (dot(dir_11, _S834.smooth_n) * _S989) < 0.0f;
            var _S991 : bool = !_S990;
            if(_S991)
            {
                var _S992 : bool = roughLobe(lobe_7.pdf, _S986, _S833.material.roughness);
                _S936 = _S992;
            }
            else
            {
                _S936 = false;
            }
            var throughput_6 : vec3<f32>;
            if(_S863)
            {
                var _S993 : bool = !_S987;
                if(_S993)
                {
                    return _S798;
                }
                var _S994 : bool = _S802 != u32(1);
                if(_S994)
                {
                    _S937 = _S802 != u32(2);
                }
                else
                {
                    _S937 = false;
                }
                if(_S937)
                {
                    var _S995 : f32 = lobe_7.pdf;
                    var _S996 : f32 = select(0.0f, _S995, _S837);
                    var _S997 : f32 = escapeWeight_0(_S996, r_8.dir);
                    if(_S871)
                    {
                        is_inside_4 = _S808;
                    }
                    else
                    {
                        is_inside_4 = false;
                    }
                    var _S998 : f32 = select(1.0f, _S997, is_inside_4);
                    return Shift_x24init_0(throughput_4 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf)) * r_8.radiance * vec3<f32>(_S998) / vec3<f32>(r_8.jac), density_3 * lobe_7.pdf / r_8.jac);
                }
                var _S999 : vec3<f32> = throughput_4 * vec3<f32>(lobe_7.pdf);
                var _S1000 : f32 = density_3 * lobe_7.pdf;
                throughput_6 = _S999;
                density_5 = _S1000;
            }
            else
            {
                throughput_6 = throughput_4;
                density_5 = density_3;
            }
            if(replay_0)
            {
                _S937 = b_3 <= _S812;
            }
            else
            {
                _S937 = false;
            }
            if(_S937)
            {
                _S938 = _S832;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                _S939 = _S987;
            }
            else
            {
                _S939 = false;
            }
            var _S1001 : bool;
            if(_S939)
            {
                _S1001 = true;
            }
            else
            {
                if(_S879)
                {
                    _S1001 = !_S936;
                }
                else
                {
                    _S1001 = false;
                }
            }
            if(_S1001)
            {
                return _S798;
            }
            var throughput_7 : vec3<f32>;
            if(_S879)
            {
                var _S1002 : vec3<f32> = throughput_6 * (lobe_7.throughput * vec3<f32>(lobe_7.pdf));
                var _S1003 : f32 = lobe_7.pdf;
                throughput_7 = _S1002;
                survival_probability_0 = _S1003;
            }
            else
            {
                var _S1004 : vec3<f32> = throughput_6 * max(lobe_7.throughput, _S797);
                throughput_7 = _S1004;
                survival_probability_0 = density_5;
            }
            var _S1005 : bool = !replay_0;
            var _S1006 : bool;
            if(_S1005)
            {
                _S1006 = !_S853;
            }
            else
            {
                _S1006 = false;
            }
            var _S1007 : bool;
            if(_S1006)
            {
                _S1007 = _S832;
            }
            else
            {
                _S1007 = false;
            }
            var _S1008 : bool;
            if(_S1007)
            {
                _S1008 = _S987;
            }
            else
            {
                _S1008 = false;
            }
            var chain_throughput_1 : vec3<f32>;
            if(_S1008)
            {
                chain_0 = here_0;
                var _S1009 : u32 = (insertBits((chain_0.path), (lobe_index_0), (u32(17)), (u32(2))));
                var _S1010 : u32 = select(u32(0), u32(1), _S837);
                var _S1011 : u32 = (insertBits((_S1009), (_S1010), (u32(19)), (u32(1))));
                chain_0.path = _S1011;
                var _S1012 : f32 = chain_0.jac * lobe_7.pdf;
                chain_0.jac = _S1012;
                chain_0.dir = dir_11;
                chain_throughput_1 = throughput_7;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            var _S1013 : Vertex = Vertex_x24init_0(_S936, lobe_index_0, lobe_7.pdf, abs(dot(_S988.geometry_n, dir_11)), is_inside_4);
            prev_0 = _S1013;
            var _S1014 : f32 = lobe_7.pdf;
            var _S1015 : bool = lobe_index_0 == u32(1);
            var _S1016 : bool;
            if(_S1015)
            {
                _S1016 = (_S836.x) == (_S836.y);
            }
            else
            {
                _S1016 = false;
            }
            var _S1017 : f32 = select(_S1014, sky_pdf_0, _S1016);
            var _S1018 : bool;
            if(refracted_4)
            {
                _S1018 = !_S933;
            }
            else
            {
                _S1018 = false;
            }
            var is_inside_5 : bool;
            if(_S1018)
            {
                var _S1019 : bool = !is_inside_4;
                is_inside_5 = _S1019;
            }
            else
            {
                is_inside_5 = is_inside_4;
            }
            ray_2.unit_direction = dir_11;
            var _S1020 : bool = !((_S833.material.transmission) > 0.0f);
            var _S1021 : bool;
            if(_S1020)
            {
                var _S1022 : bool = isTranslucent_0(_S833.material);
                _S1021 = !_S1022;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                again_0 = _S989 < 0.0f;
            }
            else
            {
                again_0 = false;
            }
            var _S1023 : Surface = surface_5;
            var _S1024 : f32 = select(_S1023.geometry_offset, 0.0f, again_0);
            var _S1025 : vec3<f32> = (vec3<f32>(0) - _S834.smooth_n);
            var _S1026 : bool = is_inside_5 != _S933;
            var _S1027 : vec3<f32> = select(_S834.smooth_n, _S1025, _S1026);
            var _S1028 : vec3<f32> = ray_2.origin + vec3<f32>(_S1024) * _S1027;
            ray_2.origin = _S1028;
            chain_throughput_0 = chain_throughput_1;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_5;
            throughput_2 = throughput_7;
            density_5 = survival_probability_0;
            sky_pdf_0 = _S1017;
        }
        else
        {
            prev_0.rough = false;
            prev_0.pdf = 0.0f;
            again_0 = false;
            throughput_2 = throughput_4;
            density_5 = density_3;
            sky_pdf_0 = 0.0f;
        }
        var _S1029 : bool = !replay_0;
        if(_S1029)
        {
            if(_S820)
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
                var _S1034 : Reservoir = withEnd(candidate_6, u32(2), b_3, _S1030);
                offer(&((*sel_4)), _S1034, _S1030 * vec3<f32>(scale_1) / vec3<f32>(density_5));
            }
            if(_S820)
            {
                _S879 = true;
            }
            else
            {
                _S879 = scatter_0;
            }
            if(_S879)
            {
                var _S1035 : f32 = survivalProbability(throughput_2, density_5);
                survival_probability_0 = _S1035;
            }
            else
            {
                survival_probability_0 = 1.0f;
            }
            var _S1036 : u32 = stream(r_8.seed, b_3 + u32(128));
            var _S1037 : Random = pcg(_S1036);
            var _S1038 : bool = survival_probability_0 < (_S1037.value);
            if(_S1038)
            {
                wrong_side_0 = true;
            }
            else
            {
                var _S1039 : u32 = (uniforms_uint.max_bounces);
                wrong_side_0 = b_3 >= _S1039;
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
        if(again_0)
        {
            var _S1041 : u32 = b_3 + u32(1);
            b_3 = _S1041;
            continue;
        }
        var _S1042 : Ray = ray_2;
        var _S1043 : f32 = distance(reconnection_0, ray_2.origin) * 1.0010000467300415f;
        if(replay_0)
        {
            _S879 = _S864;
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
        {
            wrong_side_0 = _S801 == u32(1);
        }
        else
        {
            wrong_side_0 = false;
        }
        var _S1044 : f32 = select(4.294967296e+09f, _S1043, wrong_side_0);
        var _S1045 : Hit = (traverseInstanceBVH((_S1042), (_S822), (_S1044)));
        hit_2 = _S1045;
        if(replay_0)
        {
            refracted_4 = _S864;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S894 = _S801 == u32(1);
        }
        else
        {
            _S894 = false;
        }
        if(_S894)
        {
            _S895 = (hit_2.instance_index) == (_S813.instance_index);
        }
        else
        {
            _S895 = false;
        }
        if(_S895)
        {
            _S932 = (hit_2.triangle_index) == (_S813.triangle_index);
        }
        else
        {
            _S932 = false;
        }
        if(_S932)
        {
            hit_2.uv = _S813.uv;
            var _S1046 : f32 = distance(reconnection_0, ray_2.origin);
            hit_2.distance = _S1046;
        }
        if(replay_0)
        {
            _S933 = _S864;
        }
        else
        {
            _S933 = false;
        }
        if(_S933)
        {
            _S934 = _S801 == u32(3);
        }
        else
        {
            _S934 = false;
        }
        if(_S934)
        {
            _S935 = (hit_2.instance_index) != u32(4294967295);
        }
        else
        {
            _S935 = false;
        }
        if(_S935)
        {
            return _S798;
        }
        var _S1047 : Reservoir = chain_0;
        var _S1048 : NEEVertex = nee_vertex_0;
        var _S1049 : Vertex = prev_0;
        var _S1050 : Hit = hit_2;
        loop
        {
            var _S1051 : bool = (_S1050.instance_index) == u32(4294967295);
            if(_S1051)
            {
                var _S1052 : bool = !_S1048.none;
                var _S1053 : f32 = select(0.0f, sky_pdf_0, _S1052);
                var _S1054 : f32 = escapeWeight_0(_S1053, ray_2.unit_direction);
                var _S1055 : vec3<f32> = environment_0(ray_2.unit_direction);
                var _S1056 : vec3<f32> = throughput_2 * _S1055;
                if(replay_0)
                {
                    if(_S864)
                    {
                        _S936 = _S801 == u32(3);
                    }
                    else
                    {
                        _S936 = false;
                    }
                    if(_S936)
                    {
                        var _S1057 : Shift = Shift_x24init_0(_S1056 * vec3<f32>(_S1054) / vec3<f32>(r_8.jac), density_2 / r_8.jac);
                        _S936 = true;
                        arrived_end_0 = _S1057;
                        break;
                    }
                    if(_S811)
                    {
                        _S937 = _S808;
                    }
                    else
                    {
                        _S937 = false;
                    }
                    if(_S937)
                    {
                        _S938 = b_3 == _S799;
                    }
                    else
                    {
                        _S938 = false;
                    }
                    if(_S938)
                    {
                        _S939 = !_S1049.rough;
                    }
                    else
                    {
                        _S939 = false;
                    }
                    if(_S939)
                    {
                        var _S1058 : Shift = Shift_x24init_0(_S1056 * vec3<f32>(_S1054), 1.0f);
                        _S936 = true;
                        arrived_end_0 = _S1058;
                        break;
                    }
                    _S936 = true;
                    arrived_end_0 = _S798;
                    break;
                }
                var candidate_7 : Reservoir = _S1047;
                var _S1059 : u32 = (extractBits((_S1047.path), (u32(10)), (u32(2))));
                var _S1060 : bool = _S1059 == u32(1);
                if(_S1060)
                {
                    var _S1061 : u32 = (extractBits((_S1047.path), (u32(5)), (u32(5))));
                    var _S1062 : bool = _S1061 == b_3;
                    var _S1063 : f32 = select(_S1054, 1.0f, _S1062);
                    var _S1064 : vec3<f32> = safeDivide(_S1056 * vec3<f32>(_S1063), chain_throughput_0);
                    candidate_7.radiance = _S1064;
                }
                else
                {
                    if(_S1049.rough)
                    {
                        var _S1065 : u32 = (insertBits((u32(0)), (b_3 + u32(1)), (u32(5)), (u32(5))));
                        var _S1066 : u32 = (insertBits((_S1065), (u32(3)), (u32(10)), (u32(2))));
                        var _S1067 : u32 = (insertBits((_S1066), (_S1049.lobe), (u32(15)), (u32(2))));
                        var _S1068 : u32 = select(u32(0), u32(1), _S1049.inside);
                        var _S1069 : u32 = (insertBits((_S1067), (_S1068), (u32(20)), (u32(1))));
                        candidate_7.path = _S1069;
                        candidate_7.jac = _S1049.pdf;
                        candidate_7.dir = ray_2.unit_direction;
                    }
                    else
                    {
                    }
                }
                var _S1070 : vec3<f32> = _S1056 * vec3<f32>(_S1054);
                var _S1071 : Reservoir = withEnd(candidate_7, u32(3), b_3, _S1070);
                offer(&((*sel_4)), _S1071, _S1070 * vec3<f32>(scale_1) / vec3<f32>(density_2));
                _S936 = true;
                arrived_end_0 = _S798;
                break;
            }
            var _S1072 : vec3<f32> = ray_2.origin + vec3<f32>(_S1050.distance) * ray_2.unit_direction;
            ray_2.origin = _S1072;
            _S936 = false;
            arrived_end_0 = _S798;
            break;
        }
        if(_S936)
        {
            return arrived_end_0;
        }
        var _S1041 : u32 = b_3 + u32(1);
        b_3 = _S1041;
    }
    return _S798;
}

fn shift_0( dom_5 : Domain,  r_9 : Reservoir) -> Shift
{
    var _S1073 : vec3<f32> = vec3<f32>(0.0f);
    var _S1074 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1073, 0.0f, vec4<u32>(u32(0)), _S1073, _S1073), 0.0f, _S1073, u32(0));
    var sel_5 : Selection = _S1074;
    var _S1075 : bool = (r_9.w) <= 0.0f;
    if(_S1075)
    {
        return Shift_x24init_0(_S1073, 0.0f);
    }
    var _S1076 : Shift = walk_0(dom_5, r_9, true, 0.0f, &(sel_5));
    return _S1076;
}

fn restir_shift_0( workgroup_id_1 : vec3<u32>,  local_invocation_index_4 : u32)
{
    var _S1077 : u32 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    var _S1078 : bool = _S1077 != u32(4294967295);
    if(_S1078)
    {
        var _S1079 : vec2<i32> = vec2<i32>((vec2<u32>(_S1077, (_S1077 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1080 : vec3<f32> = vec3<f32>(0.0f);
        var _S1081 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1080, _S1080, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1080, 0.0f, vec4<u32>(u32(0)), _S1080, _S1080));
        var shift_job_0 : ShiftJob = _S1081;
        var _S1082 : u32 = (_S1077 >> (u32(28)));
        var _S1083 : bool = spatialJob_0(_S1079, _S1082, &(shift_job_0));
        var _S1084 : Shift = shift_0(shift_job_0.dom, shift_job_0.r);
        textureStore(shift_data_out, (_S1079), (_S1082), (vec4<u32>((bitcast<vec3<u32>>((_S1084.f))), (bitcast<u32>((_S1084.jac))))));
    }
    return;
}

fn restir_prepass_0( global_invocation_id_3 : vec3<u32>,  local_invocation_index_5 : u32)
{
    var _S1085 : vec2<i32> = vec2<i32>(global_invocation_id_3.xy);
    var _S1086 : array<u32, i32(3)>;
    spatialBins_0(_S1085, &(_S1086));
    var _S1087 : array<u32, i32(3)> = _S1086;
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
        var _S1088 : bool = (_S1087[t_16]) == u32(40);
        if(_S1088)
        {
            textureStore(shift_data_out, (_S1085), (t_16), (vec4<u32>(u32(0))));
        }
        var t_17 : u32 = t_16 + u32(1);
        t_16 = t_17;
    }
    queueShifts_0(_S1085, _S1087, global_invocation_id_3, local_invocation_index_5);
    return;
}

fn restir_count_0( global_invocation_id_4 : vec3<u32>,  local_invocation_index_6 : u32)
{
    var _S1089 : array<u32, i32(3)>;
    spatialBins_0(vec2<i32>(global_invocation_id_4.xy), &(_S1089));
    countShifts_0(_S1089, local_invocation_index_6);
    return;
}

fn restir_temporal_shift_0( workgroup_id_2 : vec3<u32>,  local_invocation_index_7 : u32)
{
    var _S1090 : u32 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    var _S1091 : bool = _S1090 != u32(4294967295);
    if(_S1091)
    {
        var _S1092 : vec2<i32> = vec2<i32>((vec2<u32>(_S1090, (_S1090 >> (u32(14)))) & (vec2<u32>(u32(16383)))));
        var _S1093 : vec3<f32> = vec3<f32>(0.0f);
        var _S1094 : ShiftJob = ShiftJob_x24init_0(Domain_x24init_0(_S1093, _S1093, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f)), Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1093, 0.0f, vec4<u32>(u32(0)), _S1093, _S1093));
        var shift_job_1 : ShiftJob = _S1094;
        var _S1095 : u32 = (_S1090 >> (u32(28)));
        var _S1096 : bool = temporalJob_0(_S1092, _S1095, &(shift_job_1));
        var _S1097 : Shift = shift_0(shift_job_1.dom, shift_job_1.r);
        textureStore(temporal_shifts_out, (_S1092), (_S1095), (vec4<u32>((bitcast<vec3<u32>>((_S1097.f))), (bitcast<u32>((_S1097.jac))))));
    }
    return;
}

fn restir_temporal_prepass_0( global_invocation_id_5 : vec3<u32>,  local_invocation_index_8 : u32)
{
    var _S1098 : vec2<i32> = vec2<i32>(global_invocation_id_5.xy);
    var _S1099 : array<u32, i32(3)>;
    temporalBins_0(_S1098, &(_S1099));
    var _S1100 : array<u32, i32(3)> = _S1099;
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
        var _S1101 : bool = (_S1100[t_18]) == u32(40);
        if(_S1101)
        {
            textureStore(temporal_shifts_out, (_S1098), (t_18), (vec4<u32>(u32(0))));
        }
        var t_19 : u32 = t_18 + u32(1);
        t_18 = t_19;
    }
    queueShifts_0(_S1098, _S1100, global_invocation_id_5, local_invocation_index_8);
    return;
}

fn restir_temporal_count_0( global_invocation_id_6 : vec3<u32>,  local_invocation_index_9 : u32)
{
    var _S1102 : array<u32, i32(3)>;
    temporalBins_0(vec2<i32>(global_invocation_id_6.xy), &(_S1102));
    countShifts_0(_S1102, local_invocation_index_9);
    return;
}

fn confidenceCap( duplicated_0 : f32) -> f32
{
    var _S1103 : f32 = (mix((20.0f), (1.0f), (pow(duplicated_0, 0.10000000149011612f))));
    return _S1103;
}

fn temporalWeights( c_3 : f32,  p_c_1 : f32,  c_t_0 : f32,  p_t_0 : f32,  g_previous_0 : f32,  g_current_0 : f32) -> vec2<f32>
{
    var _S1104 : f32 = c_3 * p_c_1;
    var _S1105 : f32 = c_t_0 * p_t_0;
    return vec2<f32>(_S1104 / (_S1104 + c_t_0 * g_previous_0), _S1105 / (_S1105 + c_3 * g_current_0));
}

fn restir_temporal_0( global_invocation_id_7 : vec3<u32>)
{
    var _S1106 : vec2<i32> = vec2<i32>(global_invocation_id_7.xy);
    var _S1107 : vec3<f32> = vec3<f32>(0.0f);
    var _S1108 : Domain = Domain_x24init_0(_S1107, _S1107, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_6 : Domain = _S1108;
    var _S1109 : bool = (currentDomain((_S1106), &(dom_6)));
    var _S1110 : bool = !_S1109;
    if(_S1110)
    {
        storeReservoir(reservoir_temp_out, (_S1106), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1107, 0.0f, vec4<u32>(u32(0)), _S1107, _S1107)), (dom_6.hit));
        return;
    }
    var _S1111 : Reservoir = (loadReservoir(reservoir_initial, (_S1106)));
    var _S1112 : vec2<i32> = temporalNeighbor_0(_S1106, dom_6);
    var _S1113 : bool = (_S1112.x) >= i32(0);
    var r_10 : Reservoir;
    if(_S1113)
    {
        var _S1114 : Reservoir = (loadReservoir(reservoir_prev, (_S1112)));
        var _S1115 : vec4<u32> = (textureLoad(duplication, (_S1112), 0, 0));
        var _S1116 : f32 = (bitcast<f32>((_S1115.x)));
        var _S1117 : u32 = (uniforms_uint.restir_decorrelation);
        var _S1118 : bool = _S1117 == u32(1);
        var _S1119 : f32 = select(0.0f, _S1116, _S1118);
        var _S1120 : f32 = confidenceCap(_S1119);
        var _S1121 : f32 = min(_S1114.c, _S1120);
        var _S1122 : vec4<u32> = (textureLoad(temporal_shifts, (_S1106), (u32(0)), 0));
        var _S1123 : vec4<f32> = (bitcast<vec4<f32>>((_S1122)));
        var _S1124 : vec4<f32> = vec4<f32>(_S1111.f, 1.0f);
        var _S1125 : Domain = (previousDomain((_S1112)));
        var _S1126 : bool = sameDomain_0(_S1125, dom_6);
        var _S1127 : bool = !_S1126;
        var to_previous_0 : vec4<f32>;
        if(_S1127)
        {
            var _S1128 : vec4<u32> = (textureLoad(temporal_shifts, (_S1106), (u32(1)), 0));
            var _S1129 : vec4<f32> = (bitcast<vec4<f32>>((_S1128)));
            to_previous_0 = _S1129;
        }
        else
        {
            to_previous_0 = _S1124;
        }
        var _S1130 : f32 = rgb_to_greyscale(_S1111.f);
        var _S1131 : f32 = rgb_to_greyscale(_S1114.f);
        var _S1132 : Selection = Selection_x24init_0(Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1107, 0.0f, vec4<u32>(u32(0)), _S1107, _S1107), 0.0f, _S1107, u32(0));
        var sel_6 : Selection = _S1132;
        var _S1133 : u32 = (uniforms_uint.frame);
        var _S1134 : u32 = hash(_S1133);
        var _S1135 : u32 = global_invocation_id_7.x;
        var _S1136 : vec2<u32> = (uniforms_uint.render_size);
        var _S1137 : u32 = stream(_S1134, _S1135 + _S1136.x * global_invocation_id_7.y);
        var _S1138 : u32 = stream(_S1137, u32(194));
        sel_6.random_state = _S1138;
        var _S1139 : f32 = rgb_to_greyscale(to_previous_0.xyz);
        var _S1140 : vec3<f32> = _S1123.xyz;
        var _S1141 : f32 = rgb_to_greyscale(_S1140);
        var _S1142 : vec2<f32> = temporalWeights(_S1111.c, _S1130, _S1121, _S1131, _S1139, _S1141);
        offerShifted(&(sel_6), _S1111, Shift_x24init_0(_S1111.f, 1.0f), _S1142.x);
        offerShifted(&(sel_6), _S1114, Shift_x24init_0(_S1140, _S1123.w), _S1142.y);
        var _S1143 : Reservoir = finalize(sel_6, _S1111.c + _S1121);
        r_10 = _S1143;
    }
    else
    {
        r_10 = _S1111;
    }
    storeReservoir(reservoir_temp_out, (_S1106), (r_10), (dom_6.hit));
    return;
}

fn restir_initial_0( global_invocation_id_8 : vec3<u32>)
{
    var _S1144 : vec2<i32> = vec2<i32>(global_invocation_id_8.xy);
    var _S1145 : vec3<f32> = vec3<f32>(0.0f);
    var _S1146 : Domain = Domain_x24init_0(_S1145, _S1145, Hit_x24init_0(vec2<f32>(0.0f), u32(0), u32(0), u32(0), 0.0f));
    var dom_7 : Domain = _S1146;
    var _S1147 : bool = (currentDomain((_S1144), &(dom_7)));
    var _S1148 : bool = !_S1147;
    if(_S1148)
    {
        storeReservoir(reservoir_initial_out, (_S1144), (Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1145, 0.0f, vec4<u32>(u32(0)), _S1145, _S1145)), (dom_7.hit));
        return;
    }
    var _S1149 : u32 = (uniforms_uint.frame);
    var _S1150 : u32 = hash(_S1149);
    var _S1151 : u32 = global_invocation_id_8.x;
    var _S1152 : vec2<u32> = (uniforms_uint.render_size);
    var _S1153 : u32 = stream(_S1150, _S1151 + _S1152.x * global_invocation_id_8.y);
    var _S1154 : Reservoir = Reservoir_x24init_0(u32(0), u32(0), 0.0f, 0.0f, _S1145, 0.0f, vec4<u32>(u32(0)), _S1145, _S1145);
    var _S1155 : Selection = Selection_x24init_0(_S1154, 0.0f, _S1145, u32(0));
    var initial_0 : Selection = _S1155;
    var _S1156 : u32 = stream(_S1153, u32(193));
    initial_0.random_state = _S1156;
    var i_2 : u32 = u32(0);
    loop
    {
        var _S1157 : u32 = (uniforms_uint.samples);
        if(i_2 < _S1157)
        {
        }
        else
        {
            break;
        }
        var r_11 : Reservoir = _S1154;
        var _S1158 : u32 = stream(_S1153, i_2);
        r_11.seed = _S1158;
        var _S1159 : u32 = (uniforms_uint.samples);
        var _S1160 : Shift = walk_0(dom_7, r_11, false, 1.0f / f32(_S1159), &(initial_0));
        var i_3 : u32 = i_2 + u32(1);
        i_2 = i_3;
    }
    var _S1161 : Reservoir = finalize(initial_0, 1.0f);
    storeReservoir(reservoir_initial_out, (_S1144), (_S1161), (dom_7.hit));
    return;
}

fn normal_distribution( state_2 : u32) -> Random
{
    var _S1162 : Random = pcg(state_2);
    var _S1163 : Random = pcg(_S1162.state);
    var _S1164 : f32 = 6.28318548202514648f * _S1162.value;
    var _S1165 : f32 = sqrt(-2.0f * clamp(log(_S1163.value), -8.388607e+06f, 0.0f));
    return Random_x24init_0(_S1163.state, _S1165 * cos(_S1164));
}

struct RandomSphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomSphere_x24init_0( state_3 : u32,  value_1 : vec3<f32>) -> RandomSphere
{
    var _S1166 : RandomSphere;
    _S1166.state = state_3;
    _S1166.value = value_1;
    return _S1166;
}

fn random_sphere( state_4 : u32) -> RandomSphere
{
    var _S1167 : Random = normal_distribution(state_4);
    var _S1168 : Random = normal_distribution(_S1167.state);
    var _S1169 : Random = normal_distribution(_S1168.state);
    var _S1170 : vec3<f32> = (normalize((vec3<f32>(_S1167.value, _S1168.value, _S1169.value))));
    return RandomSphere_x24init_0(_S1169.state, _S1170);
}

struct RandomHemisphere
{
     state : u32,
     value : vec3<f32>,
};

fn RandomHemisphere_x24init_0( state_5 : u32,  value_2 : vec3<f32>) -> RandomHemisphere
{
    var _S1171 : RandomHemisphere;
    _S1171.state = state_5;
    _S1171.value = value_2;
    return _S1171;
}

fn random_hemisphere( state_6 : u32,  normal_4 : vec3<f32>) -> RandomHemisphere
{
    var _S1172 : RandomSphere = random_sphere(state_6);
    var _S1173 : bool = (dot(_S1172.value, normal_4)) > 0.0f;
    if(_S1173)
    {
        return RandomHemisphere_x24init_0(_S1172.state, _S1172.value);
    }
    else
    {
        var _S1174 : vec3<f32> = ((-(_S1172.value)));
        return RandomHemisphere_x24init_0(_S1172.state, _S1174);
    }
}

fn normalMapTBN( p0_0 : vec3<f32>,  p1_0 : vec3<f32>,  p2_0 : vec3<f32>,  uv0_0 : vec2<f32>,  uv1_0 : vec2<f32>,  uv2_0 : vec2<f32>,  n_12 : vec3<f32>) -> mat3x3<f32>
{
    var _S1175 : vec3<f32> = p1_0 - p0_0;
    var _S1176 : vec3<f32> = p2_0 - p0_0;
    var _S1177 : vec2<f32> = uv1_0 - uv0_0;
    var _S1178 : vec2<f32> = uv2_0 - uv0_0;
    var _S1179 : f32 = _S1177.x;
    var _S1180 : f32 = _S1178.y;
    var _S1181 : f32 = _S1177.y;
    var _S1182 : f32 = _S1178.x;
    var _S1183 : f32 = _S1179 * _S1180 - _S1181 * _S1182;
    var _S1184 : f32 = 1.0f / _S1183;
    var _S1185 : vec3<f32> = vec3<f32>(_S1184);
    var t_20 : vec3<f32> = (_S1175 * vec3<f32>(_S1180) - _S1176 * vec3<f32>(_S1181)) * _S1185;
    var _S1186 : vec3<f32> = (_S1176 * vec3<f32>(_S1179) - _S1175 * vec3<f32>(_S1182)) * _S1185;
    var t_21 : vec3<f32> = (normalize((t_20 - n_12 * vec3<f32>(dot(n_12, t_20)))));
    var _S1187 : bool = (dot(cross(n_12, t_21), _S1186)) > 0.0f;
    var t_22 : vec3<f32>;
    if(_S1187)
    {
        var _S1188 : vec3<f32> = ((-(t_21)));
        t_22 = _S1188;
    }
    else
    {
        t_22 = t_21;
    }
    var _S1189 : vec3<f32> = cross(n_12, t_22);
    return mat3x3<f32>(t_22, _S1189, n_12);
}

fn tangentToWorldNormalMap( v_5 : vec3<f32>,  tbn_0 : mat3x3<f32>) -> vec3<f32>
{
    return (((tbn_0) * (v_5)));
}

fn geometryOffset( t0_0 : vec3<f32>,  t1_0 : vec3<f32>,  t2_2 : vec3<f32>,  n0_0 : vec3<f32>,  n1_0 : vec3<f32>,  n2_0 : vec3<f32>,  geometry_n_5 : vec3<f32>,  uvw_0 : vec3<f32>,  position_1 : vec3<f32>) -> f32
{
    var _S1190 : vec3<f32> = t1_0 - t0_0;
    var _S1191 : vec3<f32> = t2_2 - t0_0;
    var _S1192 : vec3<f32> = t2_2 - t1_0;
    var _S1193 : f32 = min(length(_S1190), min(length(_S1191), length(_S1192)));
    var _S1194 : vec3<f32> = vec3<f32>(distance(position_1, t0_0), distance(position_1, t1_0), distance(position_1, t2_2));
    var _S1195 : vec3<f32> = (normalize((n0_0)));
    var _S1196 : f32 = dot(geometry_n_5, _S1195);
    var _S1197 : vec3<f32> = (normalize((n1_0)));
    var _S1198 : f32 = dot(geometry_n_5, _S1197);
    var _S1199 : vec3<f32> = (normalize((n2_0)));
    var _S1200 : vec3<f32> = acos(abs(vec3<f32>(_S1196, _S1198, dot(geometry_n_5, _S1199))));
    var _S1201 : vec3<f32> = clamp(tan(_S1200), vec3<f32>(0.0f), vec3<f32>(0.78539818525314331f));
    return clamp(dot(_S1194 * _S1201, uvw_0), 0.0f, _S1193 * 0.125f);
}

fn sampleHalfVector( v_6 : vec3<f32>,  n_i_5 : vec3<f32>,  alpha_6 : f32,  random_state_14 : ptr<function, u32>) -> vec3<f32>
{
    var _S1202 : vec3<f32> = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(vec3<f32>(0.0f), vec2<f32>(0.0f)), &((*random_state_14)));
    return _S1202;
}

fn straightThrough( dir_12 : vec3<f32>,  n_13 : vec3<f32>,  material_15 : Material) -> vec3<f32>
{
    var _S1203 : vec3<f32> = ((-(dir_12)));
    var _S1204 : f32 = (sign((dot(n_13, _S1203))));
    var _S1205 : vec3<f32> = n_13 * vec3<f32>(_S1204);
    var _S1206 : AnisotropicFrame = anisotropicFrame(material_15, _S1205);
    var _S1207 : bool = (_S1206.alphas.x) > 0.0f;
    if(_S1207)
    {
        var _S1208 : f32 = material_15.transmission * (1.0f - material_15.metallic);
        var _S1209 : vec3<f32> = ((-(_S1205)));
        var _S1210 : vec3<f32> = anisotropicLocal(dir_12, _S1206.tangent, _S1209);
        var _S1211 : f32 = anisotropicG1(_S1210, _S1206.alphas);
        return vec3<f32>((_S1208 * _S1211)) * material_15.albedo;
    }
    var _S1212 : f32 = material_15.transmission * (1.0f - material_15.metallic);
    var _S1213 : f32 = material_15.roughness;
    var _S1214 : f32 = smithG1(_S1213 * _S1213, abs(dot(n_13, dir_12)));
    return vec3<f32>((_S1212 * _S1214)) * material_15.albedo;
}

fn occluderTransmittance( toward_1 : vec3<f32>,  n_14 : vec3<f32>,  material_16 : Material,  coverage_0 : f32) -> vec3<f32>
{
    var _S1215 : vec3<f32>;
    if((material_16.ior) == 1.0f)
    {
        var _S1216 : vec3<f32> = straightThrough(toward_1, n_14, material_16);
        _S1215 = _S1216;
    }
    else
    {
        _S1215 = vec3<f32>(0.0f);
    }
    return _S1215 * vec3<f32>(coverage_0) + vec3<f32>((1.0f - coverage_0));
}

fn walk_hook( dom_8 : Domain,  r_12 : Reservoir,  replay_1 : bool,  scale_2 : f32,  sel_7 : ptr<function, Selection>) -> Shift
{
    var _S1217 : Shift = walk_0(dom_8, r_12, replay_1, scale_2, &((*sel_7)));
    return _S1217;
}

fn shift_hook( dom_9 : Domain,  r_13 : Reservoir) -> Shift
{
    var _S1218 : Shift = shift_0(dom_9, r_13);
    return _S1218;
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

