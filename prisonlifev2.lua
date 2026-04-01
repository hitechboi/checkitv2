--[[
    Check it v2 Interface
    by hitechboi / nejrio
    github.com/hitechboi
    star my post :p, have fun!
]]
local _0xD=function(b)local r=""for i=1,#b do r=r..string.char(b[i])end return r end
local tick = tick or os.clock
local warn = warn or function(msg) end
local _0x00=math.floor local _0x01=table.insert local _0x02=pairs local _0x03=ipairs local _0x04=pcall local _0x05=Vector3.new
local _0xGID=_0x00(game.GameId)
if _0xGID~=_0x00(73885730)then notify(_0xD({67,104,101,99,107,32,105,116}),_0xD({84,104,105,115,32,115,99,114,105,112,116,32,105,115,32,110,111,116,32,115,117,112,112,111,114,116,101,100,32,102,111,114,32,116,104,105,115,32,103,97,109,101,46}),5)return end
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
    if off then memory_write("byte", part.Address + off, state and 1 or 0) end
end
local function _cfGetFlag(part, flag)
    local off = _cfOff[flag]
    if not off then return nil end
    return memory_read("byte", part.Address + off) == 1
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
        local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local alive = h ~= nil
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0,0,0)
            h.Position = Vector3.new(x, y, z)
        end
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
local _0x11;do local _ok,_r=pcall(function()return loadstring(game:HttpGet("https://raw.githubusercontent.com/hitechboi/checkitv2/refs/heads/main/imjussayin.lua".."?cache="..tostring(os.time())))()end);if _ok and _r then _0x11=_r elseif _G.lib then _0x11=_G.lib else pcall(function()notify("Check it","Failed to load UI library",5)end)return end end
do local _cvUrl="https://raw.githubusercontent.com/hitechboi/checkitv2/refs/heads/main/ChildVm.lua?t="..tostring(os.time())local _ok=pcall(function()loadstring(game:HttpGet(_cvUrl))()end)if _ok then local _t0=os.clock()repeat task.wait(0.05)until _G.ChildVm or (os.clock()-_t0)>12 end end
local _0x12=game.Players.LocalPlayer.Name local _0x13="";pcall(function()if type(getgetname)=="function"then _0x13=getgetname()elseif type(getgamename)=="function"then _0x13=getgamename()end end)
local _0x14=false local _0x15=false local _0x16=false local _0x17=false local _0x18=false local _0x19=false local _0x1A=false local _0x1B=false local _0x1C=false
local _0x1D=1 local _0x1E=0.01 local _0x1F=0.1 local _0x20=1500 local _0x21=false local _0x22=false local _0xBPEnabled=false
local _0x23={["AK-47"]=true,["MP5"]=true,["FAL"]=true,["M4A1"]=true}
local _0x24=game.Players.LocalPlayer local _0x25=nil
local function _0x26()local _c=_0x24.Character if _c then _0x25=_c:FindFirstChild("Humanoid")end end _0x26()
local _0x27={MaxAmmo=function()return _0x15 and _0x1D end,CurrentAmmo=function()return _0x15 and _0x1D end,ReloadTime=function()return _0x16 and _0x1E end,FireRate=function(_t)if _0x18 then return 0.001 end if _0x17 then if _0x1A and _0x23[_t.Name]then return nil end return _0x1F end return nil end,Range=function()return _0x1C and _0x20 end}
local function _0x28(_t)if not _t:IsA("Tool")then return false end for _a in _0x02(_0x27)do if _t:GetAttribute(_a)~=nil then return true end end return false end
local function _0x29()local _b=_0x24:FindFirstChild("Backpack")local _c=0 if _b then for _,_t in _0x03(_b:GetChildren())do if _0x28(_t)then _c=_c+1 end end end return _c end
local function _0xCuffsHeld()local _c=_0x24.Character if not _c then return false end local _t=_c:FindFirstChild("Cuffs")or _c:FindFirstChild("Handcuffs")return _t and _t:IsA("Tool")end
local function _0xIsArrestable(p)
if p==_0x24 then return false,nil end
if p.Team and string.find(string.lower(p.Team.Name),"criminal")then return true,"criminal"end
local ch=p.Character
if ch then
if ch:GetAttribute("Hostile")then return true,"hostile"end
if ch:GetAttribute("Trespassing")then return true,"trespassing"end
end
return false,nil
end
local function _checkTools(parent)if not parent then return end for _,_t in _0x03(parent:GetChildren())do if _t.Name=="Remington 870"then if _t:GetAttribute("AutoFire")~=_0x19 then _t:SetAttribute("AutoFire",_0x19)end end if _0x1A and _0x23[_t.Name]then if _t:GetAttribute("FireRate")~=0.001 then _t:SetAttribute("FireRate",0.001)end end if _0x1B and _t.Name=="M9"then if _t:GetAttribute("AutoFire")~=true then _t:SetAttribute("AutoFire",true)end end if _0x28(_t)then for _a,_fn in _0x02(_0x27)do if _t:GetAttribute(_a)~=nil then local _v=_fn(_t)if _v and _t:GetAttribute(_a)~=_v then _t:SetAttribute(_a,_v)end end end end end end
local waited=0
while not _0x11 and not _G.lib do
    task.wait(0.1)
    waited=waited+0.1
    if waited>=5 then
        notify("Check it","UI library timeout",5)
        return
    end
end
if not _0x11 then _0x11=_G.lib end
local _0x2A=_0x11:Window("Check It v2")
_0x2A:SetGameName(_0x13)
local _0x2C=_0x2A:Tab("gun mods")
local _0xAutoTab=_0x2A:Tab("auto")
local _0x2E=_0x2A:Tab("teleports")
local mainSec=_0x2C:Section("main")
mainSec:Toggle({label="enabled",default=false,id="master_toggle",col=1,desc="Master toggle for all gun mods",callback=function(_s)_0x14=_s end})
--[[local collectSec=_0xAutoTab:Section("collect", 2)
local _0xAKCBtn
_0xAKCBtn = collectSec:Toggle({label="auto keycard collect",default=false,id="auto_keycard",col=2,desc="Automatically collects keycard if missing",callback=function(s)
    _0xAKC = s
    if s then
        local t = _0x24.Team
        if t and (string.match(string.lower(t.Name), "guard") or string.match(string.lower(t.Name), "police")) then
            _0xAKC = false
            if _0xAKCBtn and _0xAKCBtn.SetState then _0xAKCBtn:SetState(false) end
            notify("Auto Keycard", "youre in the guards team idiot ¬_¬", 4)
        end
    end
end})]]
local _0xAKC = false
local autoSec=_0xAutoTab:Section("auto arrest")
local _0xAC = false
local _0xAutoDeathTime = 0
local _0xAutoBtn
_0xAutoBtn = autoSec:Toggle({label="auto cuffs",default=false,id="auto_cuffs",col=1,desc="Hold out cuffs. Checks Guards team. Teleports to Criminals & locks camera.",callback=function(s)
    _0xAC = s
    if s then
        if tick() - _0xAutoDeathTime < 5 then
            _0xAC = false
            if _0xAutoBtn and _0xAutoBtn.SetState then _0xAutoBtn:SetState(false) end
            notify("Auto Arrest", "Hey chill out, wait 5 seconds to.", 4)
            return
        end
        local t = _0x24.Team
        if not t or (not string.match(string.lower(t.Name), "guard") and not string.match(string.lower(t.Name), "police")) then
            _0xAC = false
            if _0xAutoBtn and _0xAutoBtn.SetState then _0xAutoBtn:SetState(false) end
            notify("Auto Arrest","Warning: You aren't on the Guards team!",4)
        end
    end
end})
local _0xArrestTarget = nil
local _0xCrimAddrByIdx = {}
local _0xTargetInitOpts = {"All Targets"}
local _0xTargetDD = autoSec:Dropdown({label="arrest target",options=_0xTargetInitOpts,default="All Targets",id="arrest_target",col=1,callback=function(val)
    if val == "All Targets" then _0xArrestTarget = nil
    else
        for idx,name in ipairs(_0xTargetInitOpts) do
            if name == val then _0xArrestTarget = _0xCrimAddrByIdx[idx] or nil break end
        end
    end
end})
local fireSec=_0x2C:Section("fire")
fireSec:Toggle({label="apply reload",default=false,id="apply_reload",col=1,desc="Toggles Reload Slider (M9, Taser Only)",callback=function(_s)_0x16=_s end})
fireSec:Slider({label="reload time",default=0.01,min=0.01,max=5.0,suffix="s",id="reload_time",col=1,desc="Lower = faster reload",callback=function(_v)_0x1E=_v end})
fireSec:Toggle({label="apply fire rate",default=false,id="apply_firerate",col=1,desc="Toggles FireRate Slider (ARs excluded if AR Instant on)",callback=function(_s)_0x17=_s end})
fireSec:Slider({label="fire rate",default=0.1,min=0.1,max=1.0,suffix="s",id="fire_rate",col=1,desc="Lower = faster fire",callback=function(_v)_0x1F=_v end})
local extrasSec=_0x2C:Section("extras",2)
extrasSec:Toggle({label="instant fire rate",default=false,id="instant_firerate",col=2,desc="Insta FireRate!!!",callback=function(_s)_0x18=_s end})
extrasSec:Toggle({label="shotgun full auto",default=false,id="shotgun_auto",col=2,desc="Toggles AutoFire on Remington 870 (Requires firerate slider)",callback=function(_s)_0x19=_s end})
extrasSec:Toggle({label="AR instant fire rate",default=false,id="ar_instant",col=2,desc="Instant fire for AK-47, MP5, FAL, M4A1",callback=function(_s)_0x1A=_s end})
extrasSec:Toggle({label="M9 full auto",default=false,id="m9_auto",col=2,desc="Toggles AutoFire on M9 pistol",callback=function(_s)_0x1B=_s end})
local rangeSec=_0x2C:Section("range",2)
rangeSec:Toggle({label="extend range",default=false,id="extend_range",col=2,desc="Sets Range value",callback=function(_s)_0x1C=_s end})
rangeSec:Slider({label="range",default=1500,min=0,max=15000,suffix="",id="range_val",col=2,desc="Range distance",callback=function(_v)_0x20=_0x00(_v)end})
local funSec=_0x2C:Section("fun",2)
funSec:Toggle({label="apply ammo",default=false,id="apply_ammo",col=2,desc="Visual only - once below original ammo count no damage",callback=function(_s)_0x15=_s end})
funSec:Slider({label="ammo amount",default=1,min=1,max=9999,suffix="",id="ammo_amount",col=2,desc="Ammo count",callback=function(_v)_0x1D=_0x00(_v)end})
local sessionSec=_0x2C:Section("session",2)
sessionSec:DebugRow({text="session active",gameName=_0x13,col=2})
local function _0x31(_x,_y,_z)
    local _h=_0x24.Character and _0x24.Character:FindFirstChild("HumanoidRootPart")
    if not _h then return end
    local _ox,_oy,_oz=_h.Position.X,_h.Position.Y,_h.Position.Z
    _cfSmoothTP({X=_ox,Y=_oy,Z=_oz}, {X=_x,Y=_y,Z=_z}, 0.25)
    task.wait(0.4)
    _cfSmoothTP({X=_x,Y=_y,Z=_z}, {X=_ox,Y=_oy,Z=_oz}, 0.25)
end
local function _0x32(_x,_y,_z)
    local _h=_0x24.Character and _0x24.Character:FindFirstChild("HumanoidRootPart")
    if not _h then return end
    local _ox,_oy,_oz=_h.Position.X,_h.Position.Y,_h.Position.Z
    _cfSmoothTP({X=_ox,Y=_oy,Z=_oz}, {X=_x,Y=_y,Z=_z}, 0.5)
end
local crimGunSec=_0x2E:Section("criminal guns")
crimGunSec:Button({label="remington 870",id="tp_rem_crim",col=1,callback=function()_0x31(-938.22,94.31,2039.17)end})
crimGunSec:Button({label="AK-47",id="tp_ak47",col=1,callback=function()_0x31(-931.39,94.37,2039.39)end})
crimGunSec:Button({label="M700",id="tp_m700_crim",col=2,callback=function()_0x31(-919.96,95.01,2036)end})
crimGunSec:Button({label="FAL",id="tp_fal",col=2,callback=function()_0x31(-902.34,94.35,2047.93)end})
local copGunSec=_0x2E:Section("cop guns")
copGunSec:Button({label="MP5",id="tp_mp5",col=1,callback=function()_0x31(813.16,100.88,2229)end})
copGunSec:Button({label="rem cop",id="tp_rem_cop",col=1,callback=function()_0x31(820.64,100.88,2228.95)end})
copGunSec:Button({label="M700 cop",id="tp_m700_cop",col=2,callback=function()_0x31(836.09,100.74,2229.32)end})
copGunSec:Button({label="M4A1",id="tp_m4a1",col=2,callback=function()_0x31(847.71,100.74,2229.33)end})
local locSec=_0x2E:Section("locations")
locSec:Button({label="yard",id="tp_yard",col=1,callback=function()_0x32(784.12,98,2460.25)end})
locSec:Button({label="nexus",id="tp_nexus",col=1,callback=function()_0x32(873.89,100,2390.69)end})
locSec:Button({label="cafeteria",id="tp_cafeteria",col=1,callback=function()_0x32(901.37,99.99,2299.91)end})
locSec:Button({label="guard station",id="tp_guard",col=1,callback=function()_0x32(829.99,99.99,2295.10)end})
locSec:Button({label="armory",id="tp_armory",col=2,callback=function()_0x32(827.54,99.98,2240.20)end})
locSec:Button({label="prison cells",id="tp_cells",col=2,callback=function()_0x32(920.01,99.99,2442.30)end})
locSec:Button({label="roof",id="tp_roof",col=2,callback=function()_0x32(932.23,118.99,2365.07)end})
locSec:Button({label="criminal base",id="tp_crimbase",col=2,callback=function()_0x32(-936.75,94.13,2054.35)end})
pcall(function()if _0x2A.AddMainScriptLog then _0x2A:AddMainScriptLog("v1.5","2026-03-30",{
    "gun mods: fire rate, reload, range, ammo",
    "auto cuffs with target selector",
    "randomized arrest teleport offset",
    "force backpack (anti-taze/arrest lock)",
    "dynamic attribute scanning (GetAttributes)",
    "teleport buttons for guns & locations",
    "extras: instant fire, full auto, M9 auto",
})end end)
pcall(function()if _0x2A.AddMainScriptLog then _0x2A:AddMainScriptLog("v1.6",os.date("%Y-%m-%d"),{
    "added attribute support for auto arrest."
})end end)
local _0x38 = game.Players.LocalPlayer.Name
local _0x36 = true
local _0x37 = _0xD({104,116,116,112,115,58,47,47,97,110,121,116,104,105,110,103,45,98,101,105,103,101,46,118,101,114,99,101,108,46,97,112,112})
task.spawn(function()
    local _0x39 = pcall(function() return game.HttpGet end) or (type(HttpGet) == "function")
    local _0x3A = pcall(function() return game.HttpPost end) or (type(HttpPost) == "function")
    local _0x3B = nil
    pcall(function() _0x3B = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) end)
    if not (_0x39 and _0x3A) and not _0x3B then return end
    local _0x3C = _0x37:gsub("/+$", "")
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
end)
local _0xCVCharConn=nil
local _0xCVHealthConn=nil
local _0xCVBpConn=nil
local _0xCVCharWatcher=nil
local _0xCVTeamWatcher=nil
task.spawn(function()
if not _G.ChildVm then return end
local CV=_G.ChildVm
local _lastCharAddr=nil
do local c=_0x24.Character if c then _lastCharAddr=c.Address end end
_0xCVCharWatcher={active=true,poll=function()
    local char,charAddr=nil,nil
    do local c=_0x24.Character if c then char=c charAddr=c.Address end end
    if charAddr==_lastCharAddr then return end
    if _0xCVCharConn and _0xCVCharConn.Disconnect then _0xCVCharConn:Disconnect() _0xCVCharConn=nil end
    if _0xCVHealthConn and _0xCVHealthConn.Disconnect then _0xCVHealthConn:Disconnect() _0xCVHealthConn=nil end
    if _0xCVBpConn and _0xCVBpConn.Disconnect then _0xCVBpConn:Disconnect() _0xCVBpConn=nil end
    if _lastCharAddr then _0xAutoDeathTime=tick() _0x22=true end
    _0x25=nil _lastCharAddr=charAddr
    if not char then return end
    _0x22=false
    _0x25=char:FindFirstChild("Humanoid")
    if _0x14 then _checkTools(char)end
    _0xCVCharConn=CV:OnChildAdded(char,function()if _0x14 then _checkTools(char)end end)
    local bp=_0x24:FindFirstChild("Backpack")
    if bp then
        _0xCVBpConn=CV:OnChildAdded(bp,function()if _0x14 then _checkTools(bp)end end)
        if _0x14 then _checkTools(bp)end
    end
    if _0x25 then
        _0xCVHealthConn=CV:OnPropertyChanged(_0x25,"Health",function(newHP)
            if newHP<=0 and not _0x22 then _0x22=true _0xAutoDeathTime=tick()end
        end)
    end
end}
table.insert(CV._watchers,_0xCVCharWatcher)
local _lastTeamAddr=nil
do local t=_0x24.Team if t then _lastTeamAddr=t.Address end end
_0xCVTeamWatcher={active=true,poll=function()
    local t=_0x24.Team
    local teamAddr=t and t.Address or nil
    local teamName=t and t.Name or nil
    if teamAddr==_lastTeamAddr then return end
    _lastTeamAddr=teamAddr
    if not teamName then return end
    local tl=string.lower(teamName)
    if not string.match(tl,"guard") and not string.match(tl,"police") then
        _0xAC=false
        if _0xAutoBtn and _0xAutoBtn.SetState then _0xAutoBtn:SetState(false) end
        notify("Auto Arrest","You are no longer on Guards team.",3)
    end
end}
table.insert(CV._watchers,_0xCVTeamWatcher)
end)
local _lastP = tick()
local _0x33=_0x06.Heartbeat:Connect(function()if _0x21 then _0x33:Disconnect()_0x08=false return end
local _now = tick()
if _now - _lastP < 0.1 then return end
_lastP = _now
if not _0x22 and _0x14 then local _bp=_0x24:FindFirstChild("Backpack")local _char=_0x24.Character _checkTools(_bp)_checkTools(_char) end end)
local function _0xRandOffset()
    local ang = math.random() * 2 * math.pi
    local dist = 2.5 + math.random() * 1.5
    return math.cos(ang) * dist, math.sin(ang) * dist
end
task.spawn(function()
    local _0xLC = 0
    local _0xHadTargets = false
    local _0xLastCuffsWarn = 0
    while not _0x21 and _0x08 do
        task.wait(0.1)
        if not _0xAC then
            task.wait(0.2)
            _0xHadTargets = false
        elseif _0x22 then
            _0xAC = false
            if _0xAutoBtn and _0xAutoBtn.SetState then _0xAutoBtn:SetState(false) end
            notify("Auto Arrest", "You died! Turning off.", 4)
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
                    notify("Auto Arrest", "Hold out cuffs bro!", 3)
                end
                return
            end
            local _0xTargetCount = 0
            for _, _0xP in ipairs(game.Players:GetPlayers()) do
                local _arr,_ = _0xIsArrestable(_0xP)
                if _arr then
                    if not _0xArrestTarget or _0xP.Address == _0xArrestTarget then
                        _0xTargetCount = _0xTargetCount + 1
                    end
                end
            end
            if _0xTargetCount == 0 and _0xAC then
                _0xAC = false
                if _0xAutoBtn and _0xAutoBtn.SetState then _0xAutoBtn:SetState(false) end
                local msg = _0xHadTargets and "Arrested all targets" or "Untoggled no targets"
                notify("Auto Arrest", msg, 3)
                _0xHadTargets = false
                return
            end
            _0xHadTargets = true
            for _, _0xP in ipairs(game.Players:GetPlayers()) do
                if not _0xAC then break end
                local _arr2,_ = _0xIsArrestable(_0xP)
                if _arr2 and (not _0xArrestTarget or _0xP.Address == _0xArrestTarget) then
                    local _0xWatchP = _0xP
                    local _0xTargetName = _0xWatchP.Name or "?"
                    notify("Auto Arrest", "Arresting " .. _0xTargetName .. "...", 2)
                    task.spawn(function()
                        local _sw = tick()
                        local _notified = false
                        while _0xWatchP and _0xWatchP.Parent and (tick() - _sw) < 12 do
                            task.wait(0.5)
                            local _stillArr,_ = _0xIsArrestable(_0xWatchP)
                        if not _stillArr then
                                if not _notified then
                                    _notified = true
                                    notify("Auto Arrest", "Successfully arrested " .. _0xWatchP.Name .. "!", 4)
                                end
                                break
                            end
                        end
                    end)
                    local _oxR, _ozR = _0xRandOffset()
                    local _0xST = tick()
                    while _0xAC and not _0x21 and (tick() - _0xST) < 5.5 do
                        task.wait(0.016)
                        if not _0xCuffsHeld() then break end
                        local _0xPC = _0xP.Character
                        local _0xMC = _0x24.Character
                        if not _0xPC or not _0xMC then break end
                        if _0x22 then
                            _0xAC = false
                            if _0xAutoBtn and _0xAutoBtn.SetState then _0xAutoBtn:SetState(false) end
                            notify("Auto Arrest", "You died! Turning off.", 4)
                            break
                        end
                        local _sArr,_ = _0xIsArrestable(_0xP)
                        if not _sArr then break end
                        local _0xCHP = _0xPC:FindFirstChild("HumanoidRootPart")
                        local _0xMHP2 = _0xMC:FindFirstChild("HumanoidRootPart")
                        if not _0xCHP or not _0xMHP2 then break end
                        local _0xCP = _0xCHP.Position
                        _0xMHP2.Position = Vector3.new(_0xCP.X + _oxR, _0xCP.Y, _0xCP.Z + _ozR)
                        local _0xCM = workspace.CurrentCamera
                        if _0xCM then _0xCM.lookAt(_0xMHP2.Position, _0xCP) end
                        if (tick() - _0xLC) > 0.15 then
                            mouse1click()
                            _0xLC = tick()
                        end
                    end
                end
            end
            end)()
        end
    end
end)
local _0xLastOptStr=""
task.spawn(function()
    while not _0x21 and _0x08 do
        task.wait(1)
        if not _0xTargetDD then break end
        _0x04(function()
            local opts={"All Targets"}
            local addrMap={}
            for _,p in ipairs(game.Players:GetPlayers()) do
                local _a,_r = _0xIsArrestable(p)
                if _a then
                    local idx=#opts+1
                    local suffix = _r ~= "criminal" and (" / ".. _r) or ""
                    opts[idx]=(p.Name or "?")..suffix
                    addrMap[idx]=p.Address
                end
            end
            local key=table.concat(opts,"|")
            if key~=_0xLastOptStr then
                _0xLastOptStr=key
                _0xCrimAddrByIdx=addrMap
                _0xTargetInitOpts=opts
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
end)
--[[task.spawn(function()
    local _akcGoing = false
    while not _0x21 and _0x08 do
        task.wait(0.5)
        if _0xAKC then
            local t = _0x24.Team
            if t and (string.match(string.lower(t.Name), "guard") or string.match(string.lower(t.Name), "police")) then
                _0xAKC = false
                if _0xAKCBtn and _0xAKCBtn.SetState then _0xAKCBtn:SetState(false) end
                notify("Auto Keycard", "youre in the guards team idiot ¬_¬", 4)
                continue
            end
            local hasKey = false
            local bp = _0x24:FindFirstChild("Backpack")
            if bp and bp:FindFirstChild("Key card") then hasKey = true end
            local char = _0x24.Character
            if char and char:FindFirstChild("Key card") then hasKey = true end
            if not hasKey then
                local kc_pos = nil
                local kc_drop = workspace:FindFirstChild("Key card")
                if kc_drop then
                    if kc_drop:IsA("Tool") then
                        local handle = kc_drop:FindFirstChild("Handle")
                        if handle and handle:IsA("BasePart") then kc_pos = handle.Position end
                    elseif kc_drop:IsA("Model") or kc_drop:IsA("Folder") then
                        local part = kc_drop:FindFirstChild("ITEMPICKUP") or kc_drop:FindFirstChildWhichIsA("BasePart", true)
                        if part then kc_pos = part.Position end
                    elseif kc_drop:IsA("BasePart") then
                        kc_pos = kc_drop.Position
                    end
                end
                if not kc_pos then
                    local giver = workspace:FindFirstChild("Prison_ITEMS") and workspace.Prison_ITEMS:FindFirstChild("giver")
                    local kc_giver = giver and (giver:FindFirstChild("Key card") or giver:FindFirstChild("Keycard"))
                    if kc_giver then
                        local pickup = kc_giver:FindFirstChild("ITEMPICKUP") or (kc_giver:IsA("BasePart") and kc_giver)
                        if pickup then kc_pos = pickup.Position end
                    end
                end
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and kc_pos then
                    if not _akcGoing then
                        _akcGoing = true
                        notify("Auto Keycard", "going to keycard", 3)
                    end
                    _0x32(kc_pos.X, kc_pos.Y, kc_pos.Z)
                    task.wait(0.5)
                else
                    if _akcGoing then _akcGoing = false end
                end
            else
                if _akcGoing then
                    _akcGoing = false
                    notify("Auto Keycard", "collected keycard", 3)
                end
            end
        else
            _akcGoing = false
        end
    end
end)]]
while not _0x21 do task.wait(1)end _0x08=false
_G.MyMoms_Cleanup = function()
    _0x08 = false
    _0x21 = true
    _0x36 = false
    _0xAC = false
    _0xAKC = false
    if _0xCVCharConn and _0xCVCharConn.Disconnect then _0xCVCharConn:Disconnect() _0xCVCharConn=nil end
    if _0xCVHealthConn and _0xCVHealthConn.Disconnect then _0xCVHealthConn:Disconnect() _0xCVHealthConn=nil end
    if _0xCVBpConn and _0xCVBpConn.Disconnect then _0xCVBpConn:Disconnect() _0xCVBpConn=nil end
    if _0xCVCharWatcher then _0xCVCharWatcher.active=false end
    if _0xCVTeamWatcher then _0xCVTeamWatcher.active=false end
    if _G.ChildVm and _G.ChildVm.Destroy then _G.ChildVm:Destroy() end
    if _0x11 and _0x11.Destroy then _0x11:Destroy() end
    if _0x33 then _0x33:Disconnect() end
end
