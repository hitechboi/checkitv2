local players = game:GetService("Players")
local localplayer = players.LocalPlayer

local espmod = {}
espmod.__index = espmod
espmod.trackers = {}

local colours = {
	bone       = Color3.fromRGB(255, 255, 255),
	head       = Color3.fromRGB(255, 255, 255),
	box        = Color3.fromRGB(255, 255, 255),
	text       = Color3.fromRGB(255, 255, 255),
	tracer     = Color3.fromRGB(255, 255, 255),
	healthhigh = Color3.fromRGB(158, 230, 158),
	healthlow  = Color3.fromRGB(114, 56, 56),
	healthbg   = Color3.fromRGB(  0,   0,   0),
}

local bonedefs = {
	-- torso vertical
	{ a = { "Torso", 0.4, 0 },  b = { "Torso", -0.5, 0 } },
	-- collar
	{ a = { "Torso", 0.4, 0 },  b = { "Left Arm",  0.5, 0 } },
	{ a = { "Torso", 0.4, 0 },  b = { "Right Arm", 0.5, 0 } },
	-- left arm upper/lower
	{ a = { "Left Arm",  0.5, 0 },  b = { "Left Arm",  0.0, -0.2 } },
	{ a = { "Left Arm",  0.0, -0.2 },  b = { "Left Arm", -0.5, -0.35 } },
	-- right arm upper/lower
	{ a = { "Right Arm", 0.5, 0 },  b = { "Right Arm", 0.0, 0.2 } },
	{ a = { "Right Arm", 0.0, 0.2 },  b = { "Right Arm",-0.5, 0.35 } },
	-- pelvis
	{ a = { "Torso", -0.5, 0 }, b = { "Left Leg",  0.5, 0 } },
	{ a = { "Torso", -0.5, 0 }, b = { "Right Leg", 0.5, 0 } },
	-- left leg upper/lower
	{ a = { "Left Leg",  0.5, 0 },  b = { "Left Leg",  0.0, -0.1 } },
	{ a = { "Left Leg",  0.0, -0.1 },  b = { "Left Leg", -0.5, -0.2 } },
	-- right leg upper/lower
	{ a = { "Right Leg", 0.5, 0 },  b = { "Right Leg", 0.0, 0.1 } },
	{ a = { "Right Leg", 0.0, 0.1 },  b = { "Right Leg",-0.5, 0.2 } },
}

local basepart_types = {
	Part           = "BasePart",
	MeshPart       = "BasePart",
	UnionOperation = "BasePart",
	Model          = "Model",
}

local corner_offsets = {
	Vector3.new(-1,-1,-1), Vector3.new( 1,-1,-1),
	Vector3.new( 1,-1, 1), Vector3.new(-1,-1, 1),
	Vector3.new(-1, 1,-1), Vector3.new( 1, 1,-1),
	Vector3.new( 1, 1, 1), Vector3.new(-1, 1, 1),
}

local studs_per_unit = 9

local function magnitude(p1, p2)
	local dx = p2.X - p1.X
	local dy = p2.Y - p1.Y
	local dz = p2.Z - p1.Z
	return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function lerp_color(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

local function isvalidobject(obj)
	if type(obj) == "userdata" and obj and obj.ClassName then
		return basepart_types[obj.ClassName]
	end
	return nil
end

local function getmodelsource(model)
	local commonnames = { "HumanoidRootPart", "Root", "RootPart", "Core" }
	local children = model:GetChildren()
	for _, name in commonnames do
		for _, child in children do
			if string.lower(child.Name) == string.lower(name) and basepart_types[child.ClassName] == "BasePart" then
				return child
			end
		end
	end
	if model.ClassName == "Model" then
		local pp = model.PrimaryPart
		if pp then return pp end
	end
	local largest, maxvol = nil, 0
	for _, child in model:GetChildren() do
		if basepart_types[child.ClassName] then
			local vol = child.Size.X * child.Size.Y * child.Size.Z
			if vol > maxvol then maxvol = vol largest = child end
		end
	end
	return largest
end

local partmap = {
	["Torso"] = {"Torso", "UpperTorso"},
	["Left Arm"] = {"Left Arm", "LeftUpperArm"},
	["Right Arm"] = {"Right Arm", "RightUpperArm"},
	["Left Leg"] = {"Left Leg", "LeftUpperLeg"},
	["Right Leg"] = {"Right Leg", "RightUpperLeg"}
}

-- gets a world position from an r6/r15 part + vertical offset fraction
local function getr6pos(character, partname, oyfrac, oxfrac)
	local partnames = partmap[partname] or {partname}
	local part
	for _, pname in partnames do
		part = character:FindFirstChild(pname)
		if part then break end
	end
	if not part or not part:IsA("BasePart") then return nil end
	local size = part.Size
	
	-- Base position + Y offset
	local pos = (part.CFrame * CFrame.new(0, oyfrac * size.Y, 0)).Position
	
	-- Apply strict X displacement based on root right vector so limbs don't screw up the slant while animating
	if oxfrac and oxfrac ~= 0 then
		local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
		if root then
			pos = pos + root.CFrame.RightVector * (oxfrac * size.X)
		end
	end
	
	return pos
end

local function getscreensize()
	local cam = game.Workspace.CurrentCamera
	if cam then return cam.ViewportSize end
	return Vector2.new(1920, 1080)
end

local function newline(col, thickness)
	local l = Drawing.new("Line")
	l.Thickness = thickness or 1
	l.Color = col
	l.Visible = false
	return l
end

local function newcircle(col, radius)
	local c = Drawing.new("Circle")
	c.Radius = radius or 6
	c.NumSides = 16
	c.Thickness = 1
	c.Filled = false
	c.Color = col
	c.Visible = false
	return c
end

local function newsquare(col, filled, thickness)
	local s = Drawing.new("Square")
	s.Filled = filled or false
	s.Color = col
	s.Thickness = thickness or 1
	s.Visible = false
	return s
end

local function newtext(col, size)
	local t = Drawing.new("Text")
	t.Color = col
	t.Outline = true
	t.Center = true
	t.Size = size or 13
	t.Visible = false
	return t
end

local function setline(l, from, to, visible)
	l.From    = from
	l.To      = to
	l.Visible = visible
end

function espmod.newtracker(object, customname, color, gethealth, getmaxhealth)
	local objtype = isvalidobject(object)
	if not objtype then warn("[espmod] invalid object:", object) return end

	local srcobj = object
	local displayname = customname

	if objtype == "Model" then
		displayname = customname or object.Name
		srcobj = getmodelsource(object)
		if not srcobj then return end
	end

	if espmod.trackers[srcobj] then return espmod.trackers[srcobj] end

	local self = setmetatable({}, espmod)
	self.name         = displayname or srcobj.Name
	self.object       = srcobj
	self.model        = (objtype == "Model") and object or nil
	self.color        = color or colours.box
	self.objtype      = objtype
	self.visible      = true
	self.gethealth    = gethealth
	self.getmaxhealth = getmaxhealth

	self.boxoutline  = newsquare(Color3.fromRGB(0,0,0), false, 3)
	self.box         = newsquare(self.color, false, 1)
	self.healthoutline = newsquare(Color3.fromRGB(0,0,0), false, 1)
	self.healthbg    = newsquare(Color3.fromRGB(0,0,0), true)
	self.healthbar   = newsquare(colours.healthhigh, true)
	self.namelabel   = newtext(self.color, 13)
	self.namelabel.Text = self.name
	self.distlabel   = newtext(Color3.fromRGB(180,180,180), 12)
	self.traceroutline = newline(Color3.fromRGB(0,0,0), 3)
	self.tracer        = newline(self.color, 1)

	self.headcircle        = newcircle(colours.head, 6)
	self.headcircleoutline = newcircle(Color3.fromRGB(0,0,0), 6)
	
	self.displayhpfrac = 1

	self.bones = {}
	for _, def in bonedefs do
		table.insert(self.bones, {
			outline = newline(Color3.fromRGB(0,0,0), 3),
			line    = newline(colours.bone, 1),
			a       = def.a,
			b       = def.b,
		})
	end

	espmod.trackers[srcobj] = self
	return self
end

function espmod:_isalive()
	if not self.object then return false end
	return self.object:IsDescendantOf(game.Workspace)
end

function espmod:_getdistance()
	local char = localplayer.Character
	if not char then return 0 end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return 0 end
	return magnitude(hrp.Position, self.object.Position) / studs_per_unit
end

function espmod:_gethp()
	if self.gethealth and self.getmaxhealth then
		return self.gethealth(), self.getmaxhealth()
	end
	if self.model then
		local hum = self.model:FindFirstChildOfClass("Humanoid")
		if hum then return hum.Health, hum.MaxHealth end
	end
	return 100, 100
end

function espmod:_get2dbounds()
	local pos  = self.object.Position
	local size = self.object.Size
	local half = size * 0.5

	if self.objtype ~= "Model" then
		local minx, miny =  math.huge,  math.huge
		local maxx, maxy = -math.huge, -math.huge
		for i = 1, 8 do
			local o = corner_offsets[i]
			local wp = Vector3.new(
				pos.X + o.X * half.X,
				pos.Y + o.Y * half.Y,
				pos.Z + o.Z * half.Z
			)
			local sp, on = WorldToScreen(wp)
			if not on then return nil end
			if sp.X < minx then minx = sp.X end
			if sp.Y < miny then miny = sp.Y end
			if sp.X > maxx then maxx = sp.X end
			if sp.Y > maxy then maxy = sp.Y end
		end
		return minx, miny, maxx, maxy
	end

	local sc, cv = WorldToScreen(pos)
	local st, tv = WorldToScreen(pos + Vector3.new(0, size.Y * 0.5, 0))
	if not cv or not tv then return nil end

	local h = math.abs(sc.Y - st.Y) * 5
	local w = h * 0.6
	local hw, hh = w * 0.5, h * 0.5
	return sc.X - hw, sc.Y - hh, sc.X + hw, sc.Y + hh
end

function espmod:_updateskeleton(bh)
	if not self.model then
		if self.headcircle then
			self.headcircle.Visible = false
			self.headcircleoutline.Visible = false
		end
		for _, b in self.bones do
			b.line.Visible = false
			b.outline.Visible = false
		end
		return
	end

	local char = self.model

	-- head dot: slightly lowered (0.25)
	local headpart = char:FindFirstChild("Head")
	if headpart then
		local headwp = headpart.Position + Vector3.new(0, headpart.Size.Y * 0.25, 0)
		local sp, on = WorldToScreen(headwp)
		self.headcircleoutline.Position = sp
		self.headcircleoutline.Visible  = on
		self.headcircle.Position = sp
		self.headcircle.Visible  = on
		
		-- scale radius based on precise bounding box height so it never exceeds proper proportions
		if bh then
			local radius = math.clamp(bh * 0.05, 1, 10)
			self.headcircle.Radius = radius
			self.headcircleoutline.Radius = radius + 1
		end
	else
		self.headcircle.Visible = false
		self.headcircleoutline.Visible = false
	end

	-- bones: use raw world Position + Y offset, never CFrame
	for _, b in self.bones do
		local wa = getr6pos(char, b.a[1], b.a[2], b.a[3])
		local wb = getr6pos(char, b.b[1], b.b[2], b.b[3])

		if wa and wb then
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

function espmod:_update()
	if not self:_isalive() then
		self:destroy()
		return
	end

	local minx, miny, maxx, maxy = self:_get2dbounds()
	local offscreen = (minx == nil)

	if not self.visible or offscreen then
		-- hide everything without destroying drawings
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
		for _, b in self.bones do
			b.line.Visible    = false
			b.outline.Visible = false
		end
		return
	end

	local bw  = maxx - minx
	local bh  = maxy - miny
	local cx  = minx + bw * 0.5
	local pad = 2

	-- box
	self.boxoutline.Position = Vector2.new(minx, miny)
	self.boxoutline.Size     = Vector2.new(bw, bh)
	self.boxoutline.Visible  = true
	self.box.Position = Vector2.new(minx, miny)
	self.box.Size     = Vector2.new(bw, bh)
	self.box.Color    = self.color
	self.box.Visible  = true

	-- healthbar
	local hp, maxhp = self:_gethp()
	local targethpfrac = math.clamp(hp / math.max(maxhp, 1), 0, 1)
	
	-- smooth tween
	self.displayhpfrac = self.displayhpfrac + (targethpfrac - self.displayhpfrac) * 0.15
	if math.abs(self.displayhpfrac - targethpfrac) < 0.005 then
		self.displayhpfrac = targethpfrac
	end
	
	local hpfrac    = self.displayhpfrac
	local barw      = 4
	local barx      = minx - barw - pad - 2
	local filledh   = bh * hpfrac
	local hpcol     = lerp_color(colours.healthlow, colours.healthhigh, hpfrac)
	
	self.healthoutline.Position = Vector2.new(barx - 1, miny - 1)
	self.healthoutline.Size     = Vector2.new(barw + 2, bh + 2)
	self.healthoutline.Visible  = true

	self.healthbg.Position  = Vector2.new(barx, miny)
	self.healthbg.Size      = Vector2.new(barw, bh)
	self.healthbg.Visible   = true
	self.healthbar.Position = Vector2.new(barx, miny + (bh - filledh))
	self.healthbar.Size     = Vector2.new(barw, filledh)
	self.healthbar.Color    = hpcol
	self.healthbar.Visible  = true

	-- name
	self.namelabel.Text     = string.format("%s | (%d)", self.name, hp)
	self.namelabel.Color    = self.color
	self.namelabel.Position = Vector2.new(cx, miny - 16)
	self.namelabel.Visible  = true

	-- distance
	local islocal = false
	if localplayer.Character and self.object:IsDescendantOf(localplayer.Character) then
		islocal = true
	end
	
	if islocal then
		self.distlabel.Visible = false
	else
		self.distlabel.Text     = string.format("<%.1f stu>", self:_getdistance())
		self.distlabel.Position = Vector2.new(cx, maxy + pad + 2)
		self.distlabel.Visible  = true
	end

	-- tracer
	local ss           = getscreensize()
	local tracerorigin = Vector2.new(ss.X * 0.5, ss.Y)
	local tracertarget = Vector2.new(cx, maxy)
	self.traceroutline.From    = tracerorigin
	self.traceroutline.To      = tracertarget
	self.traceroutline.Visible = true
	self.tracer.From    = tracerorigin
	self.tracer.To      = tracertarget
	self.tracer.Color   = self.color
	self.tracer.Visible = true

	-- skeleton
	self:_updateskeleton(bh)
end

function espmod:setvisible(state)
	self.visible = state
end

function espmod:setcolor(color)
	self.color = color
	self.box.Color       = color
	self.tracer.Color    = color
	self.namelabel.Color = color
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

	for _, b in self.bones do
		b.line:Remove()
		b.outline:Remove()
	end

	for k in self do self[k] = nil end
	setmetatable(self, nil)
end

_G.espmod = espmod

notify("espmod loaded", "espmod", 3)
print("[espmod] ready")

return espmod
