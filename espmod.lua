--[[
    espmodule.lua
    made by nejrio/hhitechboi/besosme
    osamason da goat

]]
local players    = game:GetService("Players")
local localplayer = players.LocalPlayer
local espmod = {
    show_tracers        = true,
    tag_open            = "<",
    tag_close           = ">",
    use_custom_hp_color = false,
    custom_hp_color     = Color3.fromRGB(150, 255, 150),
}
espmod.__index = espmod
espmod.trackers = {}

local colours = {
    box        = Color3.fromRGB(255, 255, 255),
    text       = Color3.fromRGB(255, 255, 255),
    tracer     = Color3.fromRGB(255, 255, 255),
    healthhigh = Color3.fromRGB(158, 230, 158),
    healthlow  = Color3.fromRGB(114,  56,  56),
    healthbg   = Color3.fromRGB(  0,   0,   0),
}

local TACOCAT_FADE = {
    Color3.fromRGB(0,   0,   0),
    Color3.fromRGB(64,  64,  64),
    Color3.fromRGB(160, 160, 160),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0,   0,   180),
    Color3.fromRGB(255, 140, 0),
    Color3.fromRGB(210, 180, 140),
}

local function tacocat_color(clk)
    local n = #TACOCAT_FADE
    local total = clk % n
    local idx   = math.floor(total) + 1
    local nxt   = (idx % n) + 1
    local t     = total - math.floor(total)
    local a, b  = TACOCAT_FADE[idx], TACOCAT_FADE[nxt]
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

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

local partclasses = {
    BasePart = true,
    Part = true,
    MeshPart = true,
    UnionOperation = true,
    Seat = true,
    VehicleSeat = true,
    TrussPart = true,
    WedgePart = true,
    CornerWedgePart = true,
    SpawnLocation = true,
}
local function getclassname(obj)
    local success, result = pcall(function()
        return obj and obj.ClassName
    end)
    return success and result
end
local function isbasepart(obj)
    if partclasses[getclassname(obj)] then return true end
    local success, position, size = pcall(function()
        return obj.Position, obj.Size
    end)
    return success and position ~= nil and size ~= nil
end
local function ismodel(obj)
    return getclassname(obj) == "Model"
end
local function isvalidobject(obj)
    if isbasepart(obj) then return "BasePart" end
    if ismodel(obj) then return "Model" end
end
local function getmodelsource(model)
    local commonnames = {"HumanoidRootPart","Root","RootPart","Core","Point1","Engine","Middle","Center","Body","Base","Main","Hitbox"}
    local children = model:GetChildren()
    for _,name in commonnames do
        for _,child in children do
            if string.lower(child.Name)==string.lower(name) and isbasepart(child) then
                return child
            end
        end
    end
    if ismodel(model) then
        local pp = model.PrimaryPart
        if isbasepart(pp) then return pp end
    end
    local largest, maxvol = nil, 0
    for _,child in model:GetChildren() do
        if isbasepart(child) then
            local vol = child.Size.X*child.Size.Y*child.Size.Z
            if vol>maxvol then maxvol=vol; largest=child end
        end
    end
    if not largest then
        for _,child in model:GetDescendants() do
            if isbasepart(child) then
                local vol = child.Size.X*child.Size.Y*child.Size.Z
                if vol>maxvol then maxvol=vol; largest=child end
            end
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
    pcall(function() t.FontSize = size or 13 end)
    pcall(function() t.Size = size or 13 end)
    t.Visible = false
    return t
end
local function setline(l, from, to, visible)
    l.From    = from
    l.To      = to
    l.Visible = visible
end

local _objectPosRegistry = {}

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

    local cfg = config or {}

    local _posKey = nil
    if cfg.isObject and cfg.deduplicate_position then
        local pos
        pcall(function() pos = srcobj.Position end)
        if pos then
            _posKey = string.format("%.0f_%.0f_%.0f", pos.X, pos.Y, pos.Z)
            local existing = _objectPosRegistry[_posKey]
            if existing and type(existing) == "table" then
                return existing
            end
        end
    end

    local self = setmetatable({}, espmod)
    self._posKey    = _posKey
    self.name       = displayname or srcobj.Name
    self.object     = srcobj
    self.model      = (objtype=="Model") and object or nil
    self.isOwner    = false
    self._isTacocat = false

    local isOwnerName = (self.name == "besosme") or (self.model and self.model.Name == "besosme")
    if isOwnerName then
        self.isOwner = true
        if math.random() < 0.65 then
            self._isTacocat = true
            self.name = "tacocat"
        else
            self._isTacocat = false
            self.name = "check it owner"
        end
    end

    self.color        = color or colours.box
    self.objtype      = objtype
    self.visible      = true
    self.config       = cfg
    self.isObject     = cfg.isObject or false
    self.gethealth    = cfg.gethealth or nil
    self.getmaxhealth = cfg.getmaxhealth or nil

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
    self.displayhpfrac     = 1

    self.hum      = self.model and self.model:FindFirstChildOfClass("Humanoid") or nil
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

    espmod.trackers[srcobj] = self
    if _posKey then
        _objectPosRegistry[_posKey] = self
    end
    return self
end

function espmod:_isalive()
    if self.model then return self.model:IsDescendantOf(game.Workspace) end
    if not self.object then return false end
    return self.object:IsDescendantOf(game.Workspace)
end

function espmod:_rebuild_cache()
    self.hum      = self.model and self.model:FindFirstChildOfClass("Humanoid") or nil
    if self.hum then
        local hs = self.hum:FindFirstChild("BodyHeightScale")
        self.charHeight = hs and hs:IsA("NumberValue") and (5*hs.Value) or 5
        local ws = self.hum:FindFirstChild("BodyWidthScale")
        self.charWidth  = ws and ws:IsA("NumberValue") and (3*ws.Value) or 3
    else
        self.charHeight = 5
        self.charWidth  = 3
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
    local dist_color  = Color3.fromRGB(180,180,180)

    if self.isOwner then
        if self._isTacocat then
            final_color = tacocat_color(clk)
        else
            local gp = (msin(clk * 1.5) + 1) * 0.5
            final_color = Color3.fromRGB(mfloor(gp*30), mfloor(gp*10), mfloor(180+gp*75))
        end
        dist_color = final_color
    end

    if final_color ~= self._lastColor then
        self._lastColor       = final_color
        self.box.Color        = final_color
        self.tracer.Color     = final_color
        self.namelabel.Color  = final_color
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

        if self.isOwner then
            self.namelabel.Text  = string.format("%s | (%d)", self.name, mfloor(hp))
        else
            self.namelabel.Text  = string.format("%s | (%d)", self.name, mfloor(hp))
        end
        self.namelabel.Color    = final_color
        self.namelabel.Position = Vector2.new(cx, miny-16)
        self.namelabel.Visible  = true
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
end

function espmod:destroy()
    espmod.trackers[self.object] = nil

    if self._posKey then
        _objectPosRegistry[self._posKey] = nil
    end

    self.box:Remove()
    self.boxoutline:Remove()
    self.healthoutline:Remove()
    self.healthbg:Remove()
    self.healthbar:Remove()
    self.namelabel:Remove()
    self.distlabel:Remove()
    self.tracer:Remove()
    self.traceroutline:Remove()

    for k in self do self[k] = nil end
    setmetatable(self, nil)
end

_G.espmod = espmod
return espmod
