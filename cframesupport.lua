local offsets = {
    base_part = {
        primitive = 0x148,
    },
    primitive = {
        cframe = 0xC0,
        size   = 0xAC,
    },
    flags = {
        Anchored   = 0x12C,
        CanCollide = 0x12D,
        CanTouch   = 0x12E,
        CanQuery   = 0x12F,
        CastShadow = 0x130,
    },
}

local function read_fvector3(address, offset)
    return {
        X = memory_read("float", address + offset),
        Y = memory_read("float", address + offset + 4),
        Z = memory_read("float", address + offset + 8),
    }
end

local function write_fvector3(address, offset, v)
    memory_write("float", address + offset,     v.X)
    memory_write("float", address + offset + 4, v.Y)
    memory_write("float", address + offset + 8, v.Z)
end

local function get_primitive(instance)
    return memory_read("uintptr_t", instance.Address + offsets.base_part.primitive)
end

local function is_part(instance)
    local ok = pcall(function() get_primitive(instance) end)
    return ok
end

local function read_cframe(instance)
    local prim = get_primitive(instance)
    local cf_base = prim + offsets.primitive.cframe
    return {
        rot = {
            r00 = memory_read("float", cf_base),
            r01 = memory_read("float", cf_base + 4),
            r02 = memory_read("float", cf_base + 8),
            r10 = memory_read("float", cf_base + 12),
            r11 = memory_read("float", cf_base + 16),
            r12 = memory_read("float", cf_base + 20),
            r20 = memory_read("float", cf_base + 24),
            r21 = memory_read("float", cf_base + 28),
            r22 = memory_read("float", cf_base + 32),
        },
        pos = read_fvector3(cf_base, 36),
    }
end

local function write_cframe(instance, cf)
    local prim = get_primitive(instance)
    local cf_base = prim + offsets.primitive.cframe
    memory_write("float", cf_base,      cf.rot.r00)
    memory_write("float", cf_base + 4,  cf.rot.r01)
    memory_write("float", cf_base + 8,  cf.rot.r02)
    memory_write("float", cf_base + 12, cf.rot.r10)
    memory_write("float", cf_base + 16, cf.rot.r11)
    memory_write("float", cf_base + 20, cf.rot.r12)
    memory_write("float", cf_base + 24, cf.rot.r20)
    memory_write("float", cf_base + 28, cf.rot.r21)
    memory_write("float", cf_base + 32, cf.rot.r22)
    memory_write("float", cf_base + 36, cf.pos.X)
    memory_write("float", cf_base + 40, cf.pos.Y)
    memory_write("float", cf_base + 44, cf.pos.Z)
end

local function read_size(instance)
    local prim = get_primitive(instance)
    return read_fvector3(prim, offsets.primitive.size)
end

local function write_size(instance, size)
    local prim = get_primitive(instance)
    write_fvector3(prim, offsets.primitive.size, size)
end

local function scale_part(part, scale)
    if not is_part(part) then return end
    local s = read_size(part)
    write_size(part, { X = s.X * scale, Y = s.Y * scale, Z = s.Z * scale })
end

local function set_part_size(part, x, y, z)
    if not is_part(part) then return end
    write_size(part, { X = x, Y = y, Z = z })
end

local function scale_model(model, scale)
    pcall(function()
        for _, p in ipairs(model:GetDescendants()) do
            if is_part(p) then
                scale_part(p, scale)
            end
        end
    end)
end

local function read_model_cframe(model)
    local primary = model:FindFirstChild("PrimaryPart")
    if not primary then
        for _, p in ipairs(model:GetChildren()) do
            if is_part(p) then
                primary = p
                break
            end
        end
    end
    if not primary then return nil end
    return read_cframe(primary)
end

local function write_model_cframe(model, cf)
    local primary = model:FindFirstChild("PrimaryPart")
    local parts = {}
    pcall(function()
        for _, p in ipairs(model:GetDescendants()) do
            if is_part(p) then
                table.insert(parts, { part = p, cf = read_cframe(p) })
            end
        end
    end)
    if #parts == 0 then return end
    local baseCF = primary and read_cframe(primary) or parts[1].cf
    for _, entry in ipairs(parts) do
        local rel = {
            pos = {
                X = entry.cf.pos.X - baseCF.pos.X,
                Y = entry.cf.pos.Y - baseCF.pos.Y,
                Z = entry.cf.pos.Z - baseCF.pos.Z,
            },
        }
        local newCF = {
            rot = cf.rot,
            pos = {
                X = cf.pos.X + (cf.rot.r00*rel.pos.X + cf.rot.r10*rel.pos.Y + cf.rot.r20*rel.pos.Z),
                Y = cf.pos.Y + (cf.rot.r01*rel.pos.X + cf.rot.r11*rel.pos.Y + cf.rot.r21*rel.pos.Z),
                Z = cf.pos.Z + (cf.rot.r02*rel.pos.X + cf.rot.r12*rel.pos.Y + cf.rot.r22*rel.pos.Z),
            }
        }
        write_cframe(entry.part, newCF)
    end
end

local _lockedPlayers = {}
local _lockThreads = {}

local function cframe_player_to_me(targetPlayer, offset, lock)
    offset = offset or { X = 0, Y = 0, Z = 2 }
    lock = lock ~= false
    local myChar = game.Players.LocalPlayer.Character
    local targetChar = targetPlayer.Character
    if not myChar or not targetChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not targetHRP then return end

    if _lockedPlayers[targetPlayer] then
        _lockedPlayers[targetPlayer] = false
        task.wait(0.05)
    end

    if not lock then
        local myCF = read_cframe(myHRP)
        write_cframe(targetHRP, {
            rot = myCF.rot,
            pos = { X = myCF.pos.X + offset.X, Y = myCF.pos.Y + offset.Y, Z = myCF.pos.Z + offset.Z }
        })
        return
    end

    _lockedPlayers[targetPlayer] = true

    _lockThreads[targetPlayer] = task.spawn(function()
        while _lockedPlayers[targetPlayer] do
            task.wait(0.016)
            pcall(function()
                local mc = game.Players.LocalPlayer.Character
                local tc = targetPlayer.Character
                if not mc or not tc then return end
                local mh = mc:FindFirstChild("HumanoidRootPart")
                local th = tc:FindFirstChild("HumanoidRootPart")
                if not mh or not th then return end
                local myCF = read_cframe(mh)
                write_cframe(th, {
                    rot = myCF.rot,
                    pos = { X = myCF.pos.X + offset.X, Y = myCF.pos.Y + offset.Y, Z = myCF.pos.Z + offset.Z }
                })
            end)
        end
    end)
end

local function stop_cframe_player(targetPlayer)
    if _lockedPlayers[targetPlayer] then
        _lockedPlayers[targetPlayer] = false
    end
end

local function cframe_all_players_to_me(offset, lock)
    offset = offset or { X = 0, Y = 0, Z = 2 }
    local i = 0
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            cframe_player_to_me(p, {
                X = offset.X + i * 2,
                Y = offset.Y,
                Z = offset.Z,
            }, lock)
            i = i + 1
        end
    end
end

local function stop_cframe_all_players()
    for p in pairs(_lockedPlayers) do
        _lockedPlayers[p] = false
    end
end

local function cframe_player_to_username(sourceUsername, targetUsername, offset, lock)
    offset = offset or { X = 0, Y = 0, Z = 3 }
    local source = nil
    local target = nil
    for _, p in ipairs(game.Players:GetPlayers()) do
        if string.lower(p.Name) == string.lower(sourceUsername) then source = p end
        if string.lower(p.Name) == string.lower(targetUsername) then target = p end
    end
    if not source or not target then return end
    local targetChar = target.Character
    local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local targetCF = read_cframe(targetHRP)
    local destCF = {
        rot = targetCF.rot,
        pos = { X = targetCF.pos.X + offset.X, Y = targetCF.pos.Y + offset.Y, Z = targetCF.pos.Z + offset.Z }
    }

    if _lockedPlayers[source] then
        _lockedPlayers[source] = false
        task.wait(0.05)
    end

    if not lock then
        local sourceChar = source.Character
        local sourceHRP = sourceChar and sourceChar:FindFirstChild("HumanoidRootPart")
        if sourceHRP then write_cframe(sourceHRP, destCF) end
        return
    end

    _lockedPlayers[source] = true
    _lockThreads[source] = task.spawn(function()
        while _lockedPlayers[source] do
            task.wait(0.016)
            pcall(function()
                local tc = target.Character
                local sc = source.Character
                if not tc or not sc then return end
                local th = tc:FindFirstChild("HumanoidRootPart")
                local sh = sc:FindFirstChild("HumanoidRootPart")
                if not th or not sh then return end
                local cf = read_cframe(th)
                write_cframe(sh, {
                    rot = cf.rot,
                    pos = { X = cf.pos.X + offset.X, Y = cf.pos.Y + offset.Y, Z = cf.pos.Z + offset.Z }
                })
            end)
        end
    end)
end

local function stop_cframe_player_to_username(sourceUsername)
    for p in pairs(_lockedPlayers) do
        if string.lower(p.Name) == string.lower(sourceUsername) then
            _lockedPlayers[p] = false
        end
    end
end

local function rotation_from_pitch_yaw(pitch, yaw)
    local p = math.rad(pitch)
    local y = math.rad(yaw)
    local cp, sp = math.cos(p), math.sin(p)
    local cy, sy = math.cos(y), math.sin(y)
    return {
        r00 = cy,       r01 = 0,  r02 = sy,
        r10 = sy * sp,  r11 = cp, r12 = -cy * sp,
        r20 = -sy * cp, r21 = sp, r22 = cy * cp,
    }
end

local function lerp_float(a, b, t)
    return a + (b - a) * t
end

local function ease_in_out_sine(t)
    return -(math.cos(math.pi * t) - 1) / 2
end

local function ease_out_expo(t)
    return t == 1 and 1 or 1 - math.pow(2, -10 * t)
end

local function lerp_cframe(a, b, t, easing)
    local et = easing and easing(t) or t
    return {
        rot = {
            r00 = lerp_float(a.rot.r00, b.rot.r00, et),
            r01 = lerp_float(a.rot.r01, b.rot.r01, et),
            r02 = lerp_float(a.rot.r02, b.rot.r02, et),
            r10 = lerp_float(a.rot.r10, b.rot.r10, et),
            r11 = lerp_float(a.rot.r11, b.rot.r11, et),
            r12 = lerp_float(a.rot.r12, b.rot.r12, et),
            r20 = lerp_float(a.rot.r20, b.rot.r20, et),
            r21 = lerp_float(a.rot.r21, b.rot.r21, et),
            r22 = lerp_float(a.rot.r22, b.rot.r22, et),
        },
        pos = {
            X = lerp_float(a.pos.X, b.pos.X, et),
            Y = lerp_float(a.pos.Y, b.pos.Y, et),
            Z = lerp_float(a.pos.Z, b.pos.Z, et),
        }
    }
end

local function rot_to_quat(rot)
    local trace = rot.r00 + rot.r11 + rot.r22
    local qw, qx, qy, qz
    if trace > 0 then
        local s = 0.5 / math.sqrt(trace + 1)
        qw = 0.25 / s
        qx = (rot.r21 - rot.r12) * s
        qy = (rot.r02 - rot.r20) * s
        qz = (rot.r10 - rot.r01) * s
    elseif rot.r00 > rot.r11 and rot.r00 > rot.r22 then
        local s = 2 * math.sqrt(1 + rot.r00 - rot.r11 - rot.r22)
        qw = (rot.r21 - rot.r12) / s
        qx = 0.25 * s
        qy = (rot.r01 + rot.r10) / s
        qz = (rot.r02 + rot.r20) / s
    elseif rot.r11 > rot.r22 then
        local s = 2 * math.sqrt(1 + rot.r11 - rot.r00 - rot.r22)
        qw = (rot.r02 - rot.r20) / s
        qx = (rot.r01 + rot.r10) / s
        qy = 0.25 * s
        qz = (rot.r12 + rot.r21) / s
    else
        local s = 2 * math.sqrt(1 + rot.r22 - rot.r00 - rot.r11)
        qw = (rot.r10 - rot.r01) / s
        qx = (rot.r02 + rot.r20) / s
        qy = (rot.r12 + rot.r21) / s
        qz = 0.25 * s
    end
    return { w = qw, x = qx, y = qy, z = qz }
end

local function quat_to_rot(q)
    return {
        r00 = 1 - 2*(q.y*q.y + q.z*q.z),
        r01 = 2*(q.x*q.y - q.z*q.w),
        r02 = 2*(q.x*q.z + q.y*q.w),
        r10 = 2*(q.x*q.y + q.z*q.w),
        r11 = 1 - 2*(q.x*q.x + q.z*q.z),
        r12 = 2*(q.y*q.z - q.x*q.w),
        r20 = 2*(q.x*q.z - q.y*q.w),
        r21 = 2*(q.y*q.z + q.x*q.w),
        r22 = 1 - 2*(q.x*q.x + q.y*q.y),
    }
end

local function slerp_cframe(a, b, t)
    local qa = rot_to_quat(a.rot)
    local qb = rot_to_quat(b.rot)
    local dot = qa.w*qb.w + qa.x*qb.x + qa.y*qb.y + qa.z*qb.z
    if dot < 0 then
        qb = { w = -qb.w, x = -qb.x, y = -qb.y, z = -qb.z }
        dot = -dot
    end
    dot = math.min(dot, 1)
    local theta = math.acos(dot)
    local sinTheta = math.sin(theta)
    local wa, wb
    if sinTheta < 0.001 then
        wa = 1 - t
        wb = t
    else
        wa = math.sin((1 - t) * theta) / sinTheta
        wb = math.sin(t * theta) / sinTheta
    end
    local qr = {
        w = wa*qa.w + wb*qb.w,
        x = wa*qa.x + wb*qb.x,
        y = wa*qa.y + wb*qb.y,
        z = wa*qa.z + wb*qb.z,
    }
    local len = math.sqrt(qr.w^2 + qr.x^2 + qr.y^2 + qr.z^2)
    qr.w = qr.w/len qr.x = qr.x/len qr.y = qr.y/len qr.z = qr.z/len
    return {
        rot = quat_to_rot(qr),
        pos = {
            X = lerp_float(a.pos.X, b.pos.X, t),
            Y = lerp_float(a.pos.Y, b.pos.Y, t),
            Z = lerp_float(a.pos.Z, b.pos.Z, t),
        }
    }
end

local function create_spring(stiffness, damping, mass)
    return {
        stiffness = stiffness or 150,
        damping   = damping   or 20,
        mass      = mass      or 1,
        pos       = { X = 0, Y = 0, Z = 0 },
        vel       = { X = 0, Y = 0, Z = 0 },
        target    = { X = 0, Y = 0, Z = 0 },
    }
end

local function update_spring(spring, dt)
    local function step(p, v, tgt)
        local force = (tgt - p) * spring.stiffness - v * spring.damping
        local acc = force / spring.mass
        local nv = v + acc * dt
        local np = p + nv * dt
        return np, nv
    end
    spring.pos.X, spring.vel.X = step(spring.pos.X, spring.vel.X, spring.target.X)
    spring.pos.Y, spring.vel.Y = step(spring.pos.Y, spring.vel.Y, spring.target.Y)
    spring.pos.Z, spring.vel.Z = step(spring.pos.Z, spring.vel.Z, spring.target.Z)
    return spring.pos
end

local function set_spring_target(spring, pos)
    spring.target.X = pos.X
    spring.target.Y = pos.Y
    spring.target.Z = pos.Z
end

local function point_to_screen(worldPos)
    local result = nil
    pcall(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local camCF = cam.CFrame
        local dx = worldPos.X - camCF.Position.X
        local dy = worldPos.Y - camCF.Position.Y
        local dz = worldPos.Z - camCF.Position.Z
        local vp = cam.ViewportSize
        local fov = math.rad(cam.FieldOfView)
        local aspect = vp.X / vp.Y
        local tanHalfFov = math.tan(fov / 2)
        local lookX = camCF.RightVector.X*dx + camCF.RightVector.Y*dy + camCF.RightVector.Z*dz
        local lookY = camCF.UpVector.X*dx    + camCF.UpVector.Y*dy    + camCF.UpVector.Z*dz
        local lookZ = -(camCF.LookVector.X*dx + camCF.LookVector.Y*dy + camCF.LookVector.Z*dz)
        if lookZ <= 0 then return end
        local screenX = (lookX / (lookZ * tanHalfFov * aspect)) * (vp.X / 2) + (vp.X / 2)
        local screenY = -(lookY / (lookZ * tanHalfFov)) * (vp.Y / 2) + (vp.Y / 2)
        result = { X = screenX, Y = screenY, visible = true }
    end)
    return result
end

local function is_in_front(origin_cf, target_pos)
    local fwd = { X = -origin_cf.rot.r02, Y = -origin_cf.rot.r12, Z = -origin_cf.rot.r22 }
    local dx = target_pos.X - origin_cf.pos.X
    local dy = target_pos.Y - origin_cf.pos.Y
    local dz = target_pos.Z - origin_cf.pos.Z
    return (fwd.X*dx + fwd.Y*dy + fwd.Z*dz) > 0
end

local function face_camera(instance)
    local result = nil
    pcall(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local cf = read_cframe(instance)
        local camPos = cam.CFrame.Position
        local rot = cframe_look_at(cf.pos, { X = camPos.X, Y = camPos.Y, Z = camPos.Z })
        result = { rot = rot, pos = cf.pos }
    end)
    return result
end

local function from_axes(right, up, back)
    return {
        rot = {
            r00 = right.X, r01 = up.X, r02 = back.X,
            r10 = right.Y, r11 = up.Y, r12 = back.Y,
            r20 = right.Z, r21 = up.Z, r22 = back.Z,
        },
        pos = { X = 0, Y = 0, Z = 0 }
    }
end

local function closest_point_on_line(lineStart, lineEnd, point)
    local dx = lineEnd.X - lineStart.X
    local dy = lineEnd.Y - lineStart.Y
    local dz = lineEnd.Z - lineStart.Z
    local lenSq = dx*dx + dy*dy + dz*dz
    if lenSq == 0 then return lineStart end
    local t = math.clamp(
        ((point.X - lineStart.X)*dx + (point.Y - lineStart.Y)*dy + (point.Z - lineStart.Z)*dz) / lenSq,
        0, 1
    )
    return { X = lineStart.X + t*dx, Y = lineStart.Y + t*dy, Z = lineStart.Z + t*dz }
end

local function swing_twist(cf, twistAxis)
    local q = rot_to_quat(cf.rot)
    local proj = {
        x = twistAxis.X * (twistAxis.X*q.x + twistAxis.Y*q.y + twistAxis.Z*q.z),
        y = twistAxis.Y * (twistAxis.X*q.x + twistAxis.Y*q.y + twistAxis.Z*q.z),
        z = twistAxis.Z * (twistAxis.X*q.x + twistAxis.Y*q.y + twistAxis.Z*q.z),
    }
    local twist_q = { w = q.w, x = proj.x, y = proj.y, z = proj.z }
    local tlen = math.sqrt(twist_q.w^2 + twist_q.x^2 + twist_q.y^2 + twist_q.z^2)
    if tlen > 0.0001 then
        twist_q.w = twist_q.w/tlen twist_q.x = twist_q.x/tlen
        twist_q.y = twist_q.y/tlen twist_q.z = twist_q.z/tlen
    else
        twist_q = { w = 1, x = 0, y = 0, z = 0 }
    end
    local inv_twist = { w = twist_q.w, x = -twist_q.x, y = -twist_q.y, z = -twist_q.z }
    local swing_q = {
        w = q.w*inv_twist.w - q.x*inv_twist.x - q.y*inv_twist.y - q.z*inv_twist.z,
        x = q.w*inv_twist.x + q.x*inv_twist.w + q.y*inv_twist.z - q.z*inv_twist.y,
        y = q.w*inv_twist.y - q.x*inv_twist.z + q.y*inv_twist.w + q.z*inv_twist.x,
        z = q.w*inv_twist.z + q.x*inv_twist.y - q.y*inv_twist.x + q.z*inv_twist.w,
    }
    return {
        swing = { rot = quat_to_rot(swing_q), pos = cf.pos },
        twist = { rot = quat_to_rot(twist_q), pos = cf.pos },
    }
end

local function to_world_space(origin_cf, local_pos)
    return {
        X = origin_cf.pos.X + origin_cf.rot.r00*local_pos.X + origin_cf.rot.r10*local_pos.Y + origin_cf.rot.r20*local_pos.Z,
        Y = origin_cf.pos.Y + origin_cf.rot.r01*local_pos.X + origin_cf.rot.r11*local_pos.Y + origin_cf.rot.r21*local_pos.Z,
        Z = origin_cf.pos.Z + origin_cf.rot.r02*local_pos.X + origin_cf.rot.r12*local_pos.Y + origin_cf.rot.r22*local_pos.Z,
    }
end

local function to_object_space(origin_cf, world_pos)
    local dx = world_pos.X - origin_cf.pos.X
    local dy = world_pos.Y - origin_cf.pos.Y
    local dz = world_pos.Z - origin_cf.pos.Z
    return {
        X = origin_cf.rot.r00*dx + origin_cf.rot.r01*dy + origin_cf.rot.r02*dz,
        Y = origin_cf.rot.r10*dx + origin_cf.rot.r11*dy + origin_cf.rot.r12*dz,
        Z = origin_cf.rot.r20*dx + origin_cf.rot.r21*dy + origin_cf.rot.r22*dz,
    }
end

local function multiply_cframe(a, b)
    return {
        rot = {
            r00 = a.rot.r00*b.rot.r00 + a.rot.r01*b.rot.r10 + a.rot.r02*b.rot.r20,
            r01 = a.rot.r00*b.rot.r01 + a.rot.r01*b.rot.r11 + a.rot.r02*b.rot.r21,
            r02 = a.rot.r00*b.rot.r02 + a.rot.r01*b.rot.r12 + a.rot.r02*b.rot.r22,
            r10 = a.rot.r10*b.rot.r00 + a.rot.r11*b.rot.r10 + a.rot.r12*b.rot.r20,
            r11 = a.rot.r10*b.rot.r01 + a.rot.r11*b.rot.r11 + a.rot.r12*b.rot.r21,
            r12 = a.rot.r10*b.rot.r02 + a.rot.r11*b.rot.r12 + a.rot.r12*b.rot.r22,
            r20 = a.rot.r20*b.rot.r00 + a.rot.r21*b.rot.r10 + a.rot.r22*b.rot.r20,
            r21 = a.rot.r20*b.rot.r01 + a.rot.r21*b.rot.r11 + a.rot.r22*b.rot.r21,
            r22 = a.rot.r20*b.rot.r02 + a.rot.r21*b.rot.r12 + a.rot.r22*b.rot.r22,
        },
        pos = {
            X = a.pos.X + a.rot.r00*b.pos.X + a.rot.r10*b.pos.Y + a.rot.r20*b.pos.Z,
            Y = a.pos.Y + a.rot.r01*b.pos.X + a.rot.r11*b.pos.Y + a.rot.r21*b.pos.Z,
            Z = a.pos.Z + a.rot.r02*b.pos.X + a.rot.r12*b.pos.Y + a.rot.r22*b.pos.Z,
        }
    }
end

local function inverse_cframe(cf)
    local r = cf.rot
    return {
        rot = {
            r00 = r.r00, r01 = r.r10, r02 = r.r20,
            r10 = r.r01, r11 = r.r11, r12 = r.r21,
            r20 = r.r02, r21 = r.r12, r22 = r.r22,
        },
        pos = {
            X = -(r.r00*cf.pos.X + r.r01*cf.pos.Y + r.r02*cf.pos.Z),
            Y = -(r.r10*cf.pos.X + r.r11*cf.pos.Y + r.r12*cf.pos.Z),
            Z = -(r.r20*cf.pos.X + r.r21*cf.pos.Y + r.r22*cf.pos.Z),
        }
    }
end

local function get_forward(cf) return { X = -cf.rot.r02, Y = -cf.rot.r12, Z = -cf.rot.r22 } end
local function get_right(cf)   return { X =  cf.rot.r00, Y =  cf.rot.r10, Z =  cf.rot.r20 } end
local function get_up(cf)      return { X =  cf.rot.r01, Y =  cf.rot.r11, Z =  cf.rot.r21 } end
local function orbit_cframe(center, cf, angle, axis)
    axis = axis or "Y"
    local a = math.rad(angle)
    local ca, sa = math.cos(a), math.sin(a)
    local dx = cf.pos.X - center.pos.X
    local dy = cf.pos.Y - center.pos.Y
    local dz = cf.pos.Z - center.pos.Z
    local newPos = {}
    if axis == "Y" then
        newPos = { X = center.pos.X + dx*ca - dz*sa, Y = cf.pos.Y, Z = center.pos.Z + dx*sa + dz*ca }
    elseif axis == "X" then
        newPos = { X = cf.pos.X, Y = center.pos.Y + dy*ca - dz*sa, Z = center.pos.Z + dy*sa + dz*ca }
    elseif axis == "Z" then
        newPos = { X = center.pos.X + dx*ca - dy*sa, Y = center.pos.Y + dx*sa + dy*ca, Z = cf.pos.Z }
    end
    return { rot = cframe_look_at(newPos, center.pos), pos = newPos }
end

local function cframe_distance(a, b)
    local dx = b.pos.X - a.pos.X
    local dy = b.pos.Y - a.pos.Y
    local dz = b.pos.Z - a.pos.Z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function cframe_look_at(from, target)
    local dx = target.X - from.X
    local dy = target.Y - from.Y
    local dz = target.Z - from.Z
    local len = math.sqrt(dx*dx + dy*dy + dz*dz)
    if len == 0 then return rotation_from_pitch_yaw(0, 0) end
    dx, dy, dz = dx/len, dy/len, dz/len
    local yaw = math.deg(math.atan2(dx, dz))
    local pitch = math.deg(math.atan2(-dy, math.sqrt(dx*dx + dz*dz)))
    return rotation_from_pitch_yaw(pitch, yaw)
end

local function offset_cframe(cf, x, y, z)
    return {
        rot = cf.rot,
        pos = {
            X = cf.pos.X + (cf.rot.r00*x + cf.rot.r10*y + cf.rot.r20*z),
            Y = cf.pos.Y + (cf.rot.r01*x + cf.rot.r11*y + cf.rot.r21*z),
            Z = cf.pos.Z + (cf.rot.r02*x + cf.rot.r12*y + cf.rot.r22*z),
        }
    }
end

local Relative = {
    Front  = function(cf, dist) return offset_cframe(cf,  0,       0, -dist) end,
    Behind = function(cf, dist) return offset_cframe(cf,  0,       0,  dist) end,
    Above  = function(cf, dist) return offset_cframe(cf,  0,    dist,     0) end,
    Below  = function(cf, dist) return offset_cframe(cf,  0,   -dist,     0) end,
    Left   = function(cf, dist) return offset_cframe(cf, -dist,    0,     0) end,
    Right  = function(cf, dist) return offset_cframe(cf,  dist,    0,     0) end,
}

local function get_flag(part, flag)
    local offset = offsets.flags[flag]
    if not offset then return nil end
    local result = nil
    pcall(function()
        result = memory_read("byte", part.Address + offset) == 1
    end)
    return result
end

local function set_flag(part, flag, state)
    local offset = offsets.flags[flag]
    if not offset then return end
    pcall(function()
        memory_write("byte", part.Address + offset, state and 1 or 0)
    end)
end

local function get_flags(part)
    local result = {}
    for flag in pairs(offsets.flags) do
        result[flag] = get_flag(part, flag)
    end
    return result
end

local function set_flags(part, flags)
    for flag, state in pairs(flags) do
        set_flag(part, flag, state)
    end
end

local function update_camera(my_pos, target_pos)
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam and CFrame and CFrame.lookAt then
            cam.CFrame = CFrame.lookAt(
                Vector3.new(my_pos.X, my_pos.Y, my_pos.Z),
                Vector3.new(target_pos.X, target_pos.Y, target_pos.Z)
            )
        end
    end)
end

local function set_walkspeed(speed)
    pcall(function()
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = speed end
    end)
end

local function find_player(username)
    for _, p in ipairs(game.Players:GetPlayers()) do
        if string.lower(p.Name) == string.lower(username) then
            return p
        end
    end
    return nil
end

local function get_hrps(username)
    local target = find_player(username)
    if not target then
        return nil, nil, nil
    end
    local myChar = game.Players.LocalPlayer.Character
    local targetChar = target.Character
    if not myChar or not targetChar then return nil, nil, nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not targetHRP then return nil, nil, nil end
    return myHRP, targetHRP, target
end

local function teleport_to_username(username, relative, dist)
    relative = relative or "Behind"
    dist = dist or 3
    local myHRP, targetHRP, target = get_hrps(username)
    if not myHRP or not targetHRP then return end
    local savedFlags = get_flags(myHRP)
    local savedSpeed = 16
    pcall(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then savedSpeed = hum.WalkSpeed end
        end
    end)

    set_flags(myHRP, { Anchored = true, CanCollide = false })
    set_walkspeed(0)
    local target_cf = read_cframe(targetHRP)
    local fn = Relative[relative]
    local to_cf = fn and fn(target_cf, dist) or offset_cframe(target_cf, 0, 0, dist)
    to_cf.rot = cframe_look_at(to_cf.pos, target_cf.pos)
    local from_cf = read_cframe(myHRP)
    local steps = 90
    local duration = 1.2
    local startTime = os.clock()
    for i = 1, steps do
        local t = i / steps
        local cf = slerp_cframe(from_cf, to_cf, ease_in_out_sine(t))
        write_cframe(myHRP, cf)
        update_camera(cf.pos, target_cf.pos)
        local expected = (i / steps) * duration
        local elapsed = os.clock() - startTime
        local drift = expected - elapsed
        if drift > 0 then task.wait(drift) end
    end

    write_cframe(myHRP, to_cf)
    set_flags(myHRP, savedFlags)
    set_walkspeed(savedSpeed)
    update_camera(to_cf.pos, target_cf.pos)
end

local _followActive = false
local _followThread = nil
local function follow_player(username, relative, dist, updateRate, lockCamera)
    relative = relative or "Behind"
    dist = dist or 3
    updateRate = updateRate or 0.05
    lockCamera = lockCamera ~= false
    local target = find_player(username)
    if not target then
        return
    end

    if _followActive then
        _followActive = false
        task.wait(0.1)
    end

    _followActive = true
    local savedSpeed = 16
    pcall(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then savedSpeed = hum.WalkSpeed end
        end
    end)
    set_walkspeed(0)
    local spring = create_spring(120, 18, 1)
    _followThread = task.spawn(function()
        local lastTime = os.clock()
        local currentRot = nil
        while _followActive do
            task.wait(updateRate)
            pcall(function()
                local now = os.clock()
                local dt = math.min(now - lastTime, 0.1)
                lastTime = now
                local myChar = game.Players.LocalPlayer.Character
                local targetChar = target.Character
                if not myChar or not targetChar then return end
                local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if not myHRP or not targetHRP then return end
                local target_cf = read_cframe(targetHRP)
                local fn = Relative[relative]
                local desired_cf = fn and fn(target_cf, dist) or offset_cframe(target_cf, 0, 0, dist)
                local desired_rot = cframe_look_at(desired_cf.pos, target_cf.pos)
                set_spring_target(spring, desired_cf.pos)
                local springPos = update_spring(spring, dt)
                if not currentRot then
                    currentRot = read_cframe(myHRP).rot
                end

                local rotA = { rot = currentRot, pos = springPos }
                local rotB = { rot = desired_rot, pos = springPos }
                local slerpedRot = slerp_cframe(rotA, rotB, math.clamp(dt * 8, 0, 1))
                currentRot = slerpedRot.rot
                local final_cf = { rot = currentRot, pos = springPos }
                set_flags(myHRP, { Anchored = true, CanCollide = false })
                write_cframe(myHRP, final_cf)
                if lockCamera then
                    update_camera(final_cf.pos, target_cf.pos)
                end
            end)
        end

        pcall(function()
            local myChar = game.Players.LocalPlayer.Character
            if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                set_flags(myHRP, { Anchored = false, CanCollide = true })
            end
        end)

        set_walkspeed(savedSpeed)
    end)
end

local function stop_follow()
    _followActive = false
end

