local runservice = game:GetService("RunService")
local players = game:GetService("Players")
local localplayer = players.LocalPlayer

local espmod = {}
espmod.__index = espmod
espmod.trackers = {}

local colours = {
	head       = Color3.fromRGB(255, 120,  30),
	collarbone = Color3.fromRGB(255, 255, 255),
	torso      = Color3.fromRGB( 80, 200, 255),
	upperarml  = Color3.fromRGB(255, 220,  50),
	lowerarml  = Color3.fromRGB( 80, 200, 255),
	upperarmr  = Color3.fromRGB(100, 220, 100),
	lowerarmr  = Color3.fromRGB(255,  80,  80),
	pelvis     = Color3.fromRGB(180, 100, 220),
	upperlegl  = Color3.fromRGB(180, 100, 220),
	lowerlegl  = Color3.fromRGB(255,  80,  80),
	upperlegr  = Color3.fromRGB(180, 100, 220),
	lowerlegr  = Color3.fromRGB(255, 220,  50),
	box        = Color3.fromRGB(255, 255, 255),
	text       = Color3.fromRGB(200, 200, 200),
}

local bonedefs = {
	{ from = "Head",          to = "UpperTorso",    col = "collarbone" },
	{ from = "UpperTorso",    to = "LeftUpperArm",  col = "collarbone" },
	{ from = "UpperTorso",    to = "RightUpperArm", col = "collarbone" },
	{ from = "UpperTorso",    to = "LowerTorso",    col = "torso"      },
	{ from = "LeftUpperArm",  to = "LeftLowerArm",  col = "upperarml"  },
	{ from = "LeftLowerArm",  to = "LeftHand",      col = "lowerarml"  },
	{ from = "RightUpperArm", to = "RightLowerArm", col = "upperarmr"  },
	{ from = "RightLowerArm", to = "RightHand",     col = "lowerarmr"  },
	{ from = "LowerTorso",    to = "LeftUpperLeg",  col = "pelvis"     },
	{ from = "LowerTorso",    to = "RightUpperLeg", col = "pelvis"     },
	{ from = "LeftUpperLeg",  to = "LeftLowerLeg",  col = "upperlegl"  },
	{ from = "LeftLowerLeg",  to = "LeftFoot",      col = "lowerlegl"  },
	{ from = "RightUpperLeg", to = "RightLowerLeg", col = "upperlegr"  },
	{ from = "RightLowerLeg", to = "RightFoot",     col = "lowerlegr"  },
}

local r6map = {
	UpperTorso    = { part = "Torso",      ox = 0,     oy = 0      },
	LowerTorso    = { part = "Torso",      ox = 0,     oy = -0.55  },
	LeftUpperArm  = { part = "Torso",      ox = -0.65, oy = 0.2    },
	LeftLowerArm  = { part = "Left Arm",   ox = 0,     oy = 0      },
	LeftHand      = { part = "Left Arm",   ox = 0,     oy = -0.55  },
	RightUpperArm = { part = "Torso",      ox = 0.65,  oy = 0.2    },
	RightLowerArm = { part = "Right Arm",  ox = 0,     oy = 0      },
	RightHand     = { part = "Right Arm",  ox = 0,     oy = -0.55  },
	LeftUpperLeg  = { part = "Torso",      ox = -0.3,  oy = -0.8   },
	LeftLowerLeg  = { part = "Left Leg",   ox = 0,     oy = 0      },
	LeftFoot      = { part = "Left Leg",   ox = 0,     oy = -0.55  },
	RightUpperLeg = { part = "Torso",      ox = 0.3,   oy = -0.8   },
	RightLowerLeg = { part = "Right Leg",  ox = 0,     oy = 0      },
	RightFoot     = { part = "Right Leg",  ox = 0,     oy = -0.55  },
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

local function magnitude(p1, p2)
	local dx = p2.X - p1.X
	local dy = p2.Y - p1.Y
	local dz = p2.Z - p1.Z
	return math.sqrt(dx*dx + dy*dy + dz*dz)
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
			if vol > maxvol then
				maxvol = vol
				largest = child
			end
		end
	end

	return largest
end

local function getpartpos(character, partname)
	local part = character:FindFirstChild(partname)
	if part and part:IsA("BasePart") then
		return part.CFrame.p
	end

	local fb = r6map[partname]
	if fb then
		local src = character:FindFirstChild(fb.part)
		if src and src:IsA("BasePart") then
			local sz = src.Size
			return src.CFrame.p + Vector3.new(fb.ox * sz.X, fb.oy * sz.Y, 0)
		end
	end

	return nil
end

local function newline(col)
	local l = Drawing.new("Line")
	l.Thickness = 2
	l.Color = col
	l.Visible = false
	return l
end

local function newcircle(col)
	local c = Drawing.new("Circle")
	c.Radius = 8
	c.NumSides = 20
	c.Thickness = 2
	c.Filled = false
	c.Color = col
	c.Visible = false
	return c
end

local function newsquare(col)
	local s = Drawing.new("Square")
	s.Filled = false
	s.Color = col
	s.Visible = false
	return s
end

local function newtext(col)
	local t = Drawing.new("Text")
	t.Color = col
	t.Outline = true
	t.Center = false
	t.Size = 14
	t.Visible = false
	return t
end

function espmod.newtracker(object, customname, color)
	local objtype = isvalidobject(object)
	if not objtype then
		warn("[espmod] invalid object:", object)
		return
	end

	local srcobj = object
	local displayname = customname

	if objtype == "Model" then
		displayname = customname or object.Name
		srcobj = getmodelsource(object)
		if not srcobj then
			warn("[espmod] model had no valid parts:", object.Name)
			return
		end
	end

	if espmod.trackers[srcobj] then
		return espmod.trackers[srcobj]
	end

	local self = setmetatable({}, espmod)
	self.name = displayname or srcobj.Name
	self.object = srcobj
	self.model = (objtype == "Model") and object or nil
	self.color = color or colours.box
	self.objtype = objtype
	self.visible = true
	self.offscreen = false
	self.session = {}

	self.drawings = {
		box = { d = newsquare(self.color), vis = true },
	}

	self.texts = {}
	self.textorder = {}

	self.bones = {}
	self.headcircle = nil

	self:_buildtexts()

	if objtype == "Model" then
		self:_buildskeleton()
	end

	espmod.trackers[srcobj] = self
	return self
end

function espmod:_buildtexts()
	self:addtext("distance", colours.text, "0m", function()
		return "[" .. math.floor(self:_getdistance()) .. "m]"
	end)
	self:addtext("name", self.color, self.name)
end

function espmod:_buildskeleton()
	self.headcircle = newcircle(colours.head)
	for _, def in bonedefs do
		table.insert(self.bones, {
			line = newline(colours[def.col] or colours.text),
			from = def.from,
			to   = def.to,
		})
	end
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
	return magnitude(hrp.Position, self.object.Position)
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
	local w = h * 1.2
	local hw, hh = w * 0.5, h * 0.5

	return sc.X - hw, sc.Y - hh, sc.X + hw, sc.Y + hh
end

function espmod:_settextpos(drawing, yoffset)
	local fontsize = drawing.Size or 14
	local padding  = 4

	local maxlen = 0
	for line in string.gmatch(drawing.Text, "[^\n]+") do
		if #line > maxlen then maxlen = #line end
	end

	local estwidth = maxlen * (fontsize * 0.45)
	local cx = self.session.centerx or 0
	local ty = self.session.topy or 0

	drawing.Center   = false
	drawing.Position = Vector2.new(
		cx - (estwidth / 2),
		ty - padding - ((yoffset + 1) * fontsize)
	)
end

function espmod:_setalldrawings(state)
	for key, data in self.drawings do
		data.d.Visible = state and data.vis
	end
	for key, data in self.texts do
		data.d.Visible = state and data.vis
	end
	if self.headcircle then
		self.headcircle.Visible = false
	end
	for _, b in self.bones do
		b.line.Visible = false
	end
end

function espmod:_updateskeleton()
	if not self.model then return end
	local char = self.model

	local headpart = char:FindFirstChild("Head")
	if headpart and self.headcircle then
		local sp, on = WorldToScreen(headpart.Position + Vector3.new(0, headpart.Size.Y * 0.5, 0))
		self.headcircle.Visible  = on
		self.headcircle.Position = sp
	elseif self.headcircle then
		self.headcircle.Visible = false
	end

	for _, b in self.bones do
		local pa = getpartpos(char, b.from)
		local pb = getpartpos(char, b.to)
		if pa and pb then
			local sa, oa = WorldToScreen(pa)
			local sb, ob = WorldToScreen(pb)
			if oa and ob then
				b.line.From    = sa
				b.line.To      = sb
				b.line.Visible = true
			else
				b.line.Visible = false
			end
		else
			b.line.Visible = false
		end
	end
end

function espmod:_update()
	if not self:_isalive() then
		self:destroy()
		return
	end

	local minx, miny, maxx, maxy = self:_get2dbounds()
	self.offscreen = (minx == nil)

	local shouldrender = self.visible and not self.offscreen

	self:_setalldrawings(shouldrender)
	if not shouldrender then return end

	local bw = maxx - minx
	local bh = maxy - miny

	self.session = {
		centerx = minx + bw * 0.5,
		topy    = miny,
	}

	local box = self.drawings.box.d
	box.Position = Vector2.new(minx, miny)
	box.Size     = Vector2.new(bw, bh)
	box.Visible  = self.drawings.box.vis

	for _, ref in self.textorder do
		local data = self.texts[ref]
		local d    = data.d
		if data.fn then
			d.Text = data.fn()
		end
		d.Visible = data.vis
		self:_settextpos(d, data.yoffset)
	end

	if self.model then
		self:_updateskeleton()
	end
end

function espmod:addtext(ref, color, value, callback)
	if self.texts[ref] then return end

	local d = newtext(color or colours.text)
	d.Text = value or ""

	local currenttext = tostring((callback and callback()) or value or "")
	local _, nlcount = string.gsub(currenttext, "\n", "")
	local linecount = nlcount + 1

	local totaloffset = 0
	for _, k in self.textorder do
		local existing = self.texts[k]
		if existing then
			totaloffset = totaloffset + existing.linecount
		end
	end

	self.texts[ref] = {
		d         = d,
		fn        = callback or nil,
		yoffset   = totaloffset + linecount - 1,
		linecount = linecount,
		vis       = true,
	}

	table.insert(self.textorder, ref)
end

function espmod:changetext(ref, value, color)
	local data = self.texts[ref]
	if not data then warn("[espmod] no text:", ref) return end
	if data.fn then warn("[espmod] text has callback, remove it first:", ref) return end
	if value then data.d.Text  = value end
	if color then data.d.Color = color end
end

function espmod:setvisible(state)
	self.visible = state
end

function espmod:destroy()
	espmod.trackers[self.object] = nil

	for _, data in self.drawings do
		data.d:Remove()
	end
	for _, data in self.texts do
		data.d:Remove()
	end
	if self.headcircle then
		self.headcircle:Remove()
	end
	for _, b in self.bones do
		b.line:Remove()
	end

	for k in self do self[k] = nil end
	setmetatable(self, nil)
end

runservice.RenderStepped:Connect(function()
	for _, tracker in espmod.trackers do
		tracker:_update()
	end
end)

notify("espmod loaded", "espmod", 3)
print("[espmod] ready")

_G.espmod = espmod
return espmod
