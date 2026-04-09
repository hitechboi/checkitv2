--[[
    espmodule.lua
    made by nejrio/hhitechboi/besosme
    osamason da goat
    optimized: batched dirty flags, throttled skeleton, character-aware glow anims
]]
local players    = game:GetService("Players")
local localplayer = players.LocalPlayer
local espmod = {
    show_skeleton       = true,
    show_tracers        = true,
    tag_open            = "<",
    tag_close           = ">",
    use_custom_hp_color = false,
    custom_hp_color     = Color3.fromRGB(150, 255, 150),
    danger_color        = nil,
}
espmod.__index = espmod
espmod.trackers = {}

local colours = {
    bone       = Color3.fromRGB(255, 255, 255),
    head       = Color3.fromRGB(255, 255, 255),
    box        = Color3.fromRGB(255, 255, 255),
    text       = Color3.fromRGB(255, 255, 255),
    tracer     = Color3.fromRGB(255, 255, 255),
    healthhigh = Color3.fromRGB(158, 230, 158),
    healthlow  = Color3.fromRGB(114,  56,  56),
    healthbg   = Color3.fromRGB(  0,   0,   0),
}


local killer_glows = { -- bbn support
    ["Ennard"]     = { Color3.fromRGB(0,0,0),       Color3.fromRGB(200,200,200), 1.2 }, 
    ["Springtrap"] = { Color3.fromRGB(40,80,20),    Color3.fromRGB(120,10,10),   1.0 },
    ["Mimic"]      = { Color3.fromRGB(100,200,255),  Color3.fromRGB(240,240,255), 1.5 }, 
}

local r6_bones = {
    { a={"Torso",0.4},    b={"Torso",-0.5}     },
    { a={"Torso",0.4},    b={"Left Arm",0.5}   },
    { a={"Torso",0.4},    b={"Right Arm",0.5}  },
    { a={"Left Arm",0.5}, b={"Left Arm",0.0}   },
    { a={"Left Arm",0.0}, b={"Left Arm",-0.5}  },
    { a={"Right Arm",0.5},b={"Right Arm",0.0}  },
    { a={"Right Arm",0.0},b={"Right Arm",-0.5} },
    { a={"Torso",-0.5},   b={"Left Leg",0.5}   },
    { a={"Torso",-0.5},   b={"Right Leg",0.5}  },
    { a={"Left Leg",0.5}, b={"Left Leg",0.0}   },
    { a={"Left Leg",0.0}, b={"Left Leg",-0.5}  },
    { a={"Right Leg",0.5},b={"Right Leg",0.0}  },
    { a={"Right Leg",0.0},b={"Right Leg",-0.5} },
}
local r15_bones = {
    { a={"UpperTorso",0.4},   b={"LowerTorso",-0.5}    },
    { a={"UpperTorso",0.4},   b={"LeftUpperArm",0.0}   },
    { a={"UpperTorso",0.4},   b={"RightUpperArm",0.0}  },
    { a={"LeftUpperArm",0.0}, b={"LeftLowerArm",0.0}   },
    { a={"LeftLowerArm",0.0}, b={"LeftHand",0.0}       },
    { a={"RightUpperArm",0.0},b={"RightLowerArm",0.0}  },
    { a={"RightLowerArm",0.0},b={"RightHand",0.0}      },
    { a={"LowerTorso",-0.5},  b={"LeftUpperLeg",0.0}   },
    { a={"LowerTorso",-0.5},  b={"RightUpperLeg",0.0}  },
    { a={"LeftUpperLeg",0.0}, b={"LeftLowerLeg",0.0}   },
    { a={"LeftLowerLeg",0.0}, b={"LeftFoot",0.0}       },
    { a={"RightUpperLeg",0.0},b={"RightLowerLeg",0.0}  },
    { a={"RightLowerLeg",0.0},b={"RightFoot",0.0}      },
}

local basepart_types = {
    Part="BasePart", MeshPart="BasePart",
    UnionOperation="BasePart", Model="Model",
}
local corner_offsets = {
    Vector3.new(-1,-1,-1), Vector3.new( 1,-1,-1),
    Vector3.new( 1,-1, 1), Vector3.new(-1,-1, 1),
    Vector3.new(-1, 1,-1), Vector3.new( 1, 1,-1),
    Vector3.new( 1, 1, 1), Vector3.new(-1, 1, 1),
}
local studs_per_unit = 9

local mabs, msin, mfloor, mclamp = math.abs, math.sin, math.floor, math.clamp
local function magnitude(p1, p2)
    local dx,dy,dz = p2.X-p1.X, p2.Y-p1.Y, p2.Z-p1.Z
    return math.sqrt(dx*dx+dy*dy+dz*dz)
end
local function lerp_color(a, b, t)
    return Color3.new(
        a.R+(b.R-a.R)*t,
        a.G+(b.G-a.G)*t,
        a.B+(b.B-a.B)*t
    )
end

local function glowfactor(clock, speed)
    return (msin(clock * speed * math.pi) + 1) * 0.5
end

local function isvalidobject(obj)
    if type(obj)=="userdata" and obj and obj.ClassName then
        return basepart_types[obj.ClassName]
    end
end
local function getmodelsource(model)
    local commonnames = {"HumanoidRootPart","Root","RootPart","Core"}
    local children = model:GetChildren()
    for _,name in commonnames do
        for _,child in children do
            if string.lower(child.Name)==string.lower(name) and basepart_types[child.ClassName]=="BasePart" then
                return child
            end
        end
    end
    if model.ClassName=="Model" then
        local pp = model.PrimaryPart
        if pp then return pp end
    end
    local largest, maxvol = nil, 0
    for _,child in model:GetChildren() do
        if basepart_types[child.ClassName] then
            local vol = child.Size.X*child.Size.Y*child.Size.Z
            if vol>maxvol then maxvol=vol; largest=child end
        end
    end
    return largest
end
local function getscreensize()
    local cam = game.Workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    return Vector2.new(1920,1080)
end

local function newline(col, thickness)
    local l = Drawing.new("Line")
    l.Thickness = thickness or 1
    l.Color     = col
    l.Visible   = false
    return l
end
local function newcircle(col, radius)
    local c = Drawing.new("Circle")
    c.Radius   = radius or 6
    c.NumSides = 16
    c.Thickness= 1
    c.Filled   = false
    c.Color    = col
    c.Visible  = false
    return c
end
local function newsquare(col, filled, thickness)
    local s = Drawing.new("Square")
    s.Filled    = filled or false
    s.Color     = col
    s.Thickness = thickness or 1
    s.Visible   = false
    return s
end
local function newtext(col, size)
    local t = Drawing.new("Text")
    t.Color   = col
    t.Outline = true
    t.Center  = true
    t.Size    = size or 13
    t.Visible = false
    return t
end
local function setline(l, from, to, visible)
    l.From    = from
    l.To      = to
    l.Visible = visible
end

function espmod.newtracker(object, customname, color, config)
    local objtype = isvalidobject(object)
    if not objtype then return end

    local srcobj = object
    local displayname = customname
    if objtype=="Model" then
        displayname = customname or object.Name
        srcobj = getmodelsource(object)
        if not srcobj then return end
    end

    if espmod.trackers[srcobj] then return espmod.trackers[srcobj] end

    local self = setmetatable({}, espmod)
    self.name       = displayname or srcobj.Name
    self.object     = srcobj
    self.model      = (objtype=="Model") and object or nil
    self.isOwner    = false

    if self.name=="besosme" or (self.model and self.model.Name=="besosme") then
        self.isOwner = true
        self.name    = "checkit owner"
    end

    self.color        = color or colours.box
    self.objtype      = objtype
    self.visible      = true
    self.config       = config or {}
    self.isObject     = self.config.isObject or false
    self.gethealth    = self.config.gethealth or nil
    self.getmaxhealth = self.config.getmaxhealth or nil
    self.killerGlow = nil
    if self.config.isKiller and self.model then
        local charAttr = pcall(function() return self.model:GetAttribute("Character") end)
    end


    self.boxoutline        = newsquare(Color3.fromRGB(0,0,0), false, 3)
    self.box               = newsquare(self.color, false, 1)
    self.healthoutline     = newsquare(Color3.fromRGB(0,0,0), false, 1)
    self.healthbg          = newsquare(Color3.fromRGB(0,0,0), true)
    self.healthbar         = newsquare(colours.healthhigh, true)
    self.namelabel         = newtext(self.color, 13)
    self.namelabel.Text    = self.name
    self.distlabel         = newtext(Color3.fromRGB(180,180,180), 12)
    self.traceroutline     = newline(Color3.fromRGB(0,0,0), 3)
    self.tracer            = newline(self.color, 1)
    self.headcircle        = newcircle(colours.head, 6)
    self.headcircleoutline = newcircle(Color3.fromRGB(0,0,0), 6)
    self.displayhpfrac = 1
    self.killerLabel_name = nil
    self.killerLabel_char = nil
    self.killerLabel_hp   = nil
    if self.config.isKiller then
        self.killerLabel_name = newtext(self.color, 13)
        self.killerLabel_char = newtext(self.color, 13)
        self.killerLabel_hp   = newtext(self.color, 13)
        self.namelabel.Visible = false
    end

    self.hum      = self.model and self.model:FindFirstChildOfClass("Humanoid") or nil
    self.headpart = self.model and self.model:FindFirstChild("Head") or nil
    if self.hum then
        local hs = self.hum:FindFirstChild("BodyHeightScale")
        self.charHeight = hs and hs:IsA("NumberValue") and (5*hs.Value) or 5
        local ws = self.hum:FindFirstChild("BodyWidthScale")
        self.charWidth  = ws and ws:IsA("NumberValue") and (3*ws.Value) or 3
    else
        self.charHeight = 5
        self.charWidth  = 3
    end

    self._lastColor  = nil
    self._skelFrame  = 0 
    self.bones = {}
    local isR15 = (object and object:FindFirstChild("UpperTorso") ~= nil)
    local defs  = isR15 and r15_bones or r6_bones
    for _,def in defs do
        local pA = self.model and self.model:FindFirstChild(def.a[1]) or nil
        local pB = self.model and self.model:FindFirstChild(def.b[1]) or nil
        table.insert(self.bones, {
            outline = newline(Color3.fromRGB(0,0,0), 3),
            line    = newline(colours.bone, 1),
            partA   = pA, partB   = pB,
            oyA     = def.a[2], oyB = def.b[2],
        })
    end

    espmod.trackers[srcobj] = self
    return self
end

function espmod:_isalive()
    if self.model then return self.model:IsDescendantOf(game.Workspace) end
    if not self.object then return false end
    return self.object:IsDescendantOf(game.Workspace)
end

function espmod:_rebuild_cache()
    self.hum      = self.model and self.model:FindFirstChildOfClass("Humanoid") or nil
    self.headpart = self.model and self.model:FindFirstChild("Head") or nil
    if self.hum then
        local hs = self.hum:FindFirstChild("BodyHeightScale")
        self.charHeight = hs and hs:IsA("NumberValue") and (5*hs.Value) or 5
        local ws = self.hum:FindFirstChild("BodyWidthScale")
        self.charWidth  = ws and ws:IsA("NumberValue") and (3*ws.Value) or 3
    else
        self.charHeight = 5
        self.charWidth  = 3
    end

    if self.bones then
        for _,b in ipairs(self.bones) do
            if b.line    then pcall(function() b.line:Remove()    end) end
            if b.outline then pcall(function() b.outline:Remove() end) end
        end
    end
    self.bones = {}

    local isR15 = (self.model and self.model:FindFirstChild("UpperTorso") ~= nil)
    local defs  = isR15 and r15_bones or r6_bones
    for _,def in ipairs(defs) do
        local pA = self.model and self.model:FindFirstChild(def.a[1]) or nil
        local pB = self.model and self.model:FindFirstChild(def.b[1]) or nil
        table.insert(self.bones, {
            outline = newline(Color3.fromRGB(0,0,0), 3),
            line    = newline(colours.bone, 1),
            partA   = pA, partB   = pB,
            oyA     = def.a[2], oyB = def.b[2],
        })
    end
end

function espmod:_getdistance()
    local char = localplayer.Character
    if not char then return 0 end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    return magnitude(hrp.Position, self.object.Position) / studs_per_unit
end

function espmod:_gethp()
    if self.gethealth and self.getmaxhealth then
        return self.gethealth(), self.getmaxhealth()
    end
    if self.hum then return self.hum.Health, self.hum.MaxHealth end
    return 100, 100
end

function espmod:_get2dbounds()
    local pos  = self.object.Position
    local size = self.object.Size
    local sc, cv = WorldToScreen(pos)
    local st, tv = WorldToScreen(pos + Vector3.new(0,1,0))
    if not cv or not tv then return nil end
    local unitH = math.abs(sc.Y - st.Y)
    local h  = unitH * self.charHeight
    local w  = unitH * self.charWidth
    local hw, hh = w*0.5, h*0.5
    return sc.X-hw, sc.Y-hh, sc.X+hw, sc.Y+hh
end

function espmod:_updateskeleton(bh)
    if not self.model then
        self.headcircle.Visible        = false
        self.headcircleoutline.Visible = false
        for _,b in self.bones do b.line.Visible=false; b.outline.Visible=false end
        return
    end

    if self.headpart then
        local headwp = self.headpart.Position + Vector3.new(0, self.headpart.Size.Y*0.25, 0)
        local sp, on = WorldToScreen(headwp)
        self.headcircleoutline.Position = sp
        self.headcircleoutline.Visible  = on
        self.headcircle.Position = sp
        self.headcircle.Visible  = on
        if bh then
            local radius = mclamp(bh*0.05, 1, 10)
            self.headcircle.Radius        = radius
            self.headcircleoutline.Radius = radius + 1
        end
    else
        self.headcircle.Visible        = false
        self.headcircleoutline.Visible = false
    end

    for _,b in self.bones do
        if b.partA and b.partA:IsA("BasePart") and b.partB and b.partB:IsA("BasePart") then
            local wa = (b.partA.CFrame * CFrame.new(0, b.oyA*b.partA.Size.Y, 0)).Position
            local wb = (b.partB.CFrame * CFrame.new(0, b.oyB*b.partB.Size.Y, 0)).Position
            local sa, oa = WorldToScreen(wa)
            local sb, ob = WorldToScreen(wb)
            if oa and ob then
                setline(b.outline, sa, sb, true)
                setline(b.line,    sa, sb, true)
            else
                b.outline.Visible = false
                b.line.Visible    = false
            end
        else
            b.outline.Visible = false
            b.line.Visible    = false
        end
    end
end


local function _hideall(self)
    self.box.Visible           = false
    self.boxoutline.Visible    = false
    self.healthoutline.Visible = false
    self.healthbg.Visible      = false
    self.healthbar.Visible     = false
    self.namelabel.Visible     = false
    self.distlabel.Visible     = false
    self.tracer.Visible        = false
    self.traceroutline.Visible = false
    self.headcircle.Visible        = false
    self.headcircleoutline.Visible = false
    if self.killerLabel_name then self.killerLabel_name.Visible = false end
    if self.killerLabel_char then self.killerLabel_char.Visible = false end
    if self.killerLabel_hp   then self.killerLabel_hp.Visible   = false end
    for _,b in self.bones do b.line.Visible=false; b.outline.Visible=false end
end

function espmod:_getKillerGlowColor(clk)
    if not self.config.isKiller then return nil end
    if not self._charStr and self.model then
        local ok, v = pcall(function() return self.model:GetAttribute("Character") end)
        if ok and type(v)=="string" and v~="" then
            self._charStr = v
        end
    end

    local cs = self._charStr
    if not cs then return nil end

    for key, cfg in pairs(killer_glows) do
        if string.lower(cs):find(string.lower(key)) then
            local t = glowfactor(clk, cfg[3])
            return lerp_color(cfg[1], cfg[2], t)
        end
    end
    return nil
end

function espmod:_update()
    if not self:_isalive() then
        self:destroy()
        return
    end

    if self.model and (not self.object or not self.object:IsDescendantOf(game.Workspace)) then
        local newobj = getmodelsource(self.model)
        if newobj then
            self.object = newobj
            self:_rebuild_cache()
        else
            _hideall(self)
            return
        end
    end

    local minx, miny, maxx, maxy = self:_get2dbounds()
    if not self.visible or minx == nil then
        _hideall(self)
        return
    end

    local bw  = maxx - minx
    local bh  = maxy - miny
    local cx  = minx + bw * 0.5
    local pad = 2
    local clk = os.clock()
    local final_color = self.color 
    local glow_color  = nil         
    local dist_color  = Color3.fromRGB(180,180,180)
    if self.isOwner then
        local gp = (msin(clk * 2) + 1) * 0.5
        final_color = Color3.fromRGB(mfloor(gp*120), 0, mfloor(150+gp*105))
        dist_color  = final_color

    elseif self.config.isKiller then
        glow_color = self:_getKillerGlowColor(clk)
        if espmod.danger_color then
            final_color = espmod.danger_color
            dist_color  = espmod.danger_color
        end

    elseif espmod.danger_color and (self.config.isSelf or self.config.isDanger) then
        final_color = espmod.danger_color
        dist_color  = espmod.danger_color
    end

    if final_color ~= self._lastColor then
        self._lastColor       = final_color
        self.box.Color        = final_color
        self.tracer.Color     = final_color
        self.headcircle.Color = final_color
        for _,b in self.bones do
            if b.line then b.line.Color = final_color end
        end
        if not self.config.isKiller then
            self.namelabel.Color = final_color
        end
        if self.killerLabel_name then self.killerLabel_name.Color = final_color end
        if self.killerLabel_hp   then self.killerLabel_hp.Color   = final_color end
    end

    if self.killerLabel_char then
        self.killerLabel_char.Color = glow_color or final_color
    end
    self.boxoutline.Position = Vector2.new(minx, miny)
    self.boxoutline.Size     = Vector2.new(bw, bh)
    self.boxoutline.Visible  = true
    self.box.Position = Vector2.new(minx, miny)
    self.box.Size     = Vector2.new(bw, bh)
    self.box.Visible  = true
    local hp, maxhp     = self:_gethp()
    local targethpfrac  = mclamp(hp / math.max(maxhp,1), 0, 1)
    self.displayhpfrac  = self.displayhpfrac + (targethpfrac - self.displayhpfrac) * 0.15
    if mabs(self.displayhpfrac - targethpfrac) < 0.005 then
        self.displayhpfrac = targethpfrac
    end
    local hpfrac  = self.displayhpfrac
    local barw    = 4
    local barx    = minx - barw - pad - 2
    local filledh = bh * hpfrac
    local hpcol   = lerp_color(colours.healthlow, colours.healthhigh, hpfrac)
    if espmod.use_custom_hp_color then hpcol = espmod.custom_hp_color end
    if self.isObject then
        self.healthoutline.Visible = false
        self.healthbg.Visible      = false
        self.healthbar.Visible     = false
        self.namelabel.Text     = self.name
        self.namelabel.Color    = final_color
        self.namelabel.Position = Vector2.new(cx, miny-16)
        self.namelabel.Visible  = true
    else
        self.healthoutline.Position = Vector2.new(barx-1, miny-1)
        self.healthoutline.Size     = Vector2.new(barw+2, bh+2)
        self.healthoutline.Visible  = true
        self.healthbg.Position  = Vector2.new(barx, miny)
        self.healthbg.Size      = Vector2.new(barw, bh)
        self.healthbg.Visible   = true
        self.healthbar.Position = Vector2.new(barx, miny+(bh-filledh))
        self.healthbar.Size     = Vector2.new(barw, filledh)
        self.healthbar.Color    = hpcol
        self.healthbar.Visible  = true
        if self.config.isKiller then
            local charStr = self._charStr or "?"
            local hpStr   = string.format("(%d)", mfloor(hp))
            local fs         = 13
            local charW      = fs * 0.6
            local nameStr    = self.name .. " | "
            local charSegStr = charStr   .. " | "
            local nameW      = #nameStr    * charW
            local charSegW   = #charSegStr * charW
            local hpW        = #hpStr      * charW
            local totalW     = nameW + charSegW + hpW
            local startX     = cx - totalW * 0.5
            local labelY     = miny - 16
            self.killerLabel_name.Center   = false
            self.killerLabel_char.Center   = false
            self.killerLabel_hp.Center     = false
            self.killerLabel_name.Text     = nameStr
            self.killerLabel_name.Position = Vector2.new(startX, labelY)
            self.killerLabel_name.Visible  = true
            self.killerLabel_char.Text     = charSegStr
            self.killerLabel_char.Position = Vector2.new(startX + nameW, labelY)
            self.killerLabel_char.Visible  = true
            self.killerLabel_hp.Text       = hpStr
            self.killerLabel_hp.Position   = Vector2.new(startX + nameW + charSegW, labelY)
            self.killerLabel_hp.Visible    = true
            self.namelabel.Visible = false
        else
            self.namelabel.Text     = string.format("%s | (%d)", self.name, mfloor(hp))
            self.namelabel.Color    = final_color
            self.namelabel.Position = Vector2.new(cx, miny-16)
            self.namelabel.Visible  = true
        end
    end

    local islocal = false
    if localplayer.Character and self.object:IsDescendantOf(localplayer.Character) then
        islocal = true
    end
    if islocal then
        self.distlabel.Visible = false
    else
        self.distlabel.Text     = string.format("%s%.1f stu%s", espmod.tag_open, self:_getdistance(), espmod.tag_close)
        self.distlabel.Position = Vector2.new(cx, maxy+pad+2)
        self.distlabel.Color    = dist_color
        self.distlabel.Visible  = true
    end

    if espmod.show_tracers and not self.isObject then
        local ss           = getscreensize()
        local tracerorigin = Vector2.new(ss.X*0.5, ss.Y)
        local tracertarget = Vector2.new(cx, maxy)
        self.traceroutline.From    = tracerorigin
        self.traceroutline.To      = tracertarget
        self.traceroutline.Visible = true
        self.tracer.From    = tracerorigin
        self.tracer.To      = tracertarget
        self.tracer.Visible = true
    else
        self.traceroutline.Visible = false
        self.tracer.Visible        = false
    end

    if espmod.show_skeleton and not self.isObject then
        self._skelFrame = (self._skelFrame + 1) % 2
        if self._skelFrame == 0 then
            self:_updateskeleton(bh)
        end
        self.headcircle.Color = final_color
    else
        self.headcircle.Visible        = false
        self.headcircleoutline.Visible = false
        for _,b in self.bones do b.line.Visible=false; b.outline.Visible=false end
    end

    if self.config.custom_update then
        pcall(self.config.custom_update, self, minx, miny, maxx, maxy)
    end
end

function espmod:setvisible(state)
    self.visible = state
end

function espmod:setcolor(color)
    self.color          = color
    self._lastColor     = nil 
    self.box.Color      = color
    self.tracer.Color   = color
    self.namelabel.Color= color
    if self.headcircle then self.headcircle.Color = color end
    for _,b in self.bones do if b.line then b.line.Color = color end end
end

function espmod:destroy()
    espmod.trackers[self.object] = nil

    self.box:Remove()
    self.boxoutline:Remove()
    self.healthoutline:Remove()
    self.healthbg:Remove()
    self.healthbar:Remove()
    self.namelabel:Remove()
    self.distlabel:Remove()
    self.tracer:Remove()
    self.traceroutline:Remove()
    self.headcircle:Remove()
    self.headcircleoutline:Remove()
    if self.killerLabel_name then pcall(function() self.killerLabel_name:Remove() end) end
    if self.killerLabel_char then pcall(function() self.killerLabel_char:Remove() end) end
    if self.killerLabel_hp   then pcall(function() self.killerLabel_hp:Remove()   end) end

    for _,b in self.bones do
        b.line:Remove()
        b.outline:Remove()
    end

    for k in self do self[k] = nil end
    setmetatable(self, nil)
end

_G.espmod = espmod
return espmod
