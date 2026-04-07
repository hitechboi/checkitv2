--[[
  	bbn more like bnb from osamason ):
]]
if _G._BBN_CLEANUP then pcall(_G._BBN_CLEANUP) end

if not _G.espmod then
	local url = "https://raw.githubusercontent.com/hitechboi/checkitv2/refs/heads/main/espmodule.lua"
	local src = game:HttpGet(url)
	
	local patched = {}
	for line in src:gmatch("[^\n]+") do
		local skip = false
		if line:find("RenderStepped") and line:find("Connect") then skip = true end
		if line:find("Heartbeat")     and line:find("Connect") then skip = true end
		if line:find("Stepped")       and line:find("Connect") then skip = true end
		if not skip then table.insert(patched, line) end
		if line:find("self.visible      = true") then
			table.insert(patched, "self.config = config or {}")
			table.insert(patched, "self.isObject = self.config.isObject or false")
		end
	end
	loadstring(table.concat(patched, "\n"))()
end
local espmod = _G.espmod

local localplayer=game.Players.LocalPlayer
local state = {
    playerenabled = false, playerdata = {}, playercolor = Color3.fromRGB(120,200,255), playerboxcolor = Color3.fromRGB(80,160,220),
    killerenabled = false, killerdata = {}, killercolor = Color3.fromRGB(255,80,80), killerboxcolor = Color3.fromRGB(200,50,50),
    genenabled = false, gendata = {}, gencolor = Color3.fromRGB(80,255,120),
    trapenabled = false, trapdata = {},
    batteryenabled = false, batterydata = {},
    miniondata = {},
    gencount = 0, alivefolder = nil, killerfolder = nil, genfolder = nil, trapfolder = nil, fuseboxfolder = nil,
    optself = false, optskeleton = true, opttracers = true,
    staminalock = false, staminamin = 30,
    infinitestamina = false, shiftheld = false, origspeed = 16,
    deletetraps = false,
    globaltick = 0, steptick = 0, myroot = nil, dangercolor = nil,
	Team = "Survivor" or "Killer", Stun = false, Ragdoll = false, Iframes = false,
	tagopen="<", tagclose=">", usecustomhpcolor=false, hpcolor=Color3.fromRGB(150,255,150),
	autogen_enabled=false
}
local Connection={}
Connection.__index=Connection
function Connection.new(fn)return setmetatable({Connected=true,_disconnect=fn},Connection)end
function Connection:Disconnect()if not self.Connected then return end;self.Connected=false;if self._disconnect then self._disconnect()end end
local Signal={}
Signal.__index=Signal
function Signal.new()return setmetatable({_entries={}},Signal)end
function Signal:Connect(cb)local e={callback=cb,connected=true};table.insert(self._entries,e);return Connection.new(function()e.connected=false end)end
function Signal:Once(cb)local c;c=self:Connect(function(...)c:Disconnect();cb(...)end);return c end
function Signal:Fire(...)local e=self._entries;local j=0;for i=1,#e do local en=e[i];if en.connected then j=j+1;e[j]=en;pcall(en.callback,...)end end;for i=j+1,#e do e[i]=nil end end
function Signal:Wait()local co=coroutine.running();self:Once(function(...)coroutine.resume(co,...)end);return coroutine.yield()end
function Signal:DisconnectAll()for _,e in ipairs(self._entries)do e.connected=false end;self._entries={}end
function Signal:GetConnectionCount()local n=0;for _,e in ipairs(self._entries)do if e.connected then n=n+1 end end;return n end
local runservice=game:GetService("RunService")
local connections={}
local function connectsignal(sig,fn)local c=sig:Connect(fn);table.insert(connections,c);return c end
local mfloor,mabs,msin,mmax,mmin=math.floor,math.abs,math.sin,math.max,math.min
local offsettop,offsetbottom=Vector3.new(0,2.5,0),Vector3.new(0,3,0)

local function valuesequal(a,b)
	if typeof(a)~=typeof(b)then return false end
	local t=typeof(a)
	if t=="Vector3"then local ok=false;pcall(function()ok=mabs(b.X-a.X)<0.001 and mabs(b.Y-a.Y)<0.001 and mabs(b.Z-a.Z)<0.001 end);return ok end
	if t=="Vector2"then local ok=false;pcall(function()ok=mabs(b.X-a.X)<0.001 and mabs(b.Y-a.Y)<0.001 end);return ok end
	if t=="table"and a.X and a.Y and a.Z then return mabs(b.X-a.X)<0.001 and mabs(b.Y-a.Y)<0.001 and mabs(b.Z-a.Z)<0.001 end
	return a==b
end

local ChildVm={}
ChildVm.__index=ChildVm
ChildVm.Signal=Signal
ChildVm.Connection=Connection
ChildVm._VERSION="1.0.0"
function ChildVm.new(cfg)
	cfg=cfg or {}
	local self=setmetatable({_watchers={},_running=false,_pollRate=cfg.PollRate or 0.05},ChildVm)
	self:_startEngine()
	return self
end

function ChildVm:_startEngine()
	if self._running then return end
	self._running=true
	task.spawn(function()
		while self._running do
			local w=self._watchers
			local alive={}
			for i=1,#w do local wt=w[i];if wt.active then table.insert(alive,wt);pcall(wt.poll)end end
			self._watchers=alive
			task.wait(self._pollRate)
		end
	end)
end

local function snapshotchildren(parent)
	local s={}
	pcall(function()for _,c in ipairs(parent:GetChildren())do local a=c.Address;if a then s[a]=c end end end)
	return s
end

function ChildVm:OnChildAdded(parent,cb)
	local cur=snapshotchildren(parent)
	local pending={}
	local w={active=true,poll=function()
		if not parent or not parent.Parent then return end
		local now=snapshotchildren(parent)
		for a,c in pairs(now)do if not cur[a]then if not pending[a]then pending[a]=true;pcall(cb,c)end else pending[a]=nil end end
		cur=now
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OnceChildAdded(parent,cb)local c;c=self:OnChildAdded(parent,function(ch)c:Disconnect();cb(ch)end);return c end
function ChildVm:OnChildRemoved(parent,cb)
	local cur=snapshotchildren(parent)
	local missing={}
	local w={active=true,poll=function()
		local now=snapshotchildren(parent)
		for a,c in pairs(cur)do
			if not now[a]then
				missing[a]=(missing[a]or 0)+1
				if missing[a]>=2 then missing[a]=nil;cur[a]=nil;pcall(cb,c)end
			else missing[a]=nil end
		end
		for a,c in pairs(now)do if not cur[a]then cur[a]=c end end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OnceChildRemoved(parent,cb)local c;c=self:OnChildRemoved(parent,function(ch)c:Disconnect();cb(ch)end);return c end
function ChildVm:OnAttributeChanged(inst,attr,cb)
	local cur;pcall(function()cur=inst:GetAttribute(attr)end)
	local w={active=true,poll=function()
		if not inst or not inst.Parent then return end
		local new;pcall(function()new=inst:GetAttribute(attr)end)
		if new~=cur then local old=cur;cur=new;pcall(cb,new,old)end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OnceAttributeChanged(inst,attr,cb)local c;c=self:OnAttributeChanged(inst,attr,function(n,o)c:Disconnect();cb(n,o)end);return c end
function ChildVm:OnPropertyChanged(inst,prop,cb)
	local cur;pcall(function()cur=inst[prop]end)
	local w={active=true,poll=function()
		if not inst or not inst.Parent then return end
		local new;local ok=pcall(function()new=inst[prop]end)
		if not ok then return end
		if not valuesequal(cur,new)then local old=cur;cur=new;pcall(cb,new,old)end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OncePropertyChanged(inst,prop,cb)local c;c=self:OnPropertyChanged(inst,prop,function(n,o)c:Disconnect();cb(n,o)end);return c end
function ChildVm:OnChanged(inst,cb,props)
	props=props or{"Name","Parent","Visible","Text","Value","Position","Size","Health","MaxHealth","WalkSpeed","Transparency","Enabled","Anchored","CFrame"}
	local conns={}
	for _,prop in ipairs(props)do
		local readable=pcall(function()local _=inst[prop]end)
		if readable then table.insert(conns,self:OnPropertyChanged(inst,prop,function(n,o)pcall(cb,prop,n,o)end))end
	end
	return Connection.new(function()for _,c in ipairs(conns)do c:Disconnect()end end)
end

function ChildVm:WaitForChild(parent,name,timeout)
	timeout=timeout or 10
	local ex;pcall(function()ex=parent:FindFirstChild(name)end)
	if ex then return ex end
	local result,done=nil,false
	local c=self:OnChildAdded(parent,function(ch)pcall(function()if ch.Name==name then result=ch;done=true end end)end)
	local s=tick()
	while not done and(tick()-s)<timeout do task.wait(self._pollRate)end
	c:Disconnect()
	return result
end

function ChildVm:OnDescendantAdded(anc,cb)
	local conns={}
	local function watch(par)local c=self:OnChildAdded(par,function(ch)pcall(cb,ch);watch(ch)end);table.insert(conns,c)end
	watch(anc)
	pcall(function()local function walk(par)for _,ch in ipairs(par:GetChildren())do watch(ch);walk(ch)end end;walk(anc)end)
	return Connection.new(function()for _,c in ipairs(conns)do c:Disconnect()end end)
end

function ChildVm:OnDescendantRemoved(anc,cb)
	local conns={}
	local function watch(par)local c=self:OnChildRemoved(par,function(ch)pcall(cb,ch)end);table.insert(conns,c)end
	watch(anc)
	pcall(function()local function walk(par)for _,ch in ipairs(par:GetChildren())do watch(ch);walk(ch)end end;walk(anc)end)
	return Connection.new(function()for _,c in ipairs(conns)do c:Disconnect()end end)
end

function ChildVm:SetPollRate(r)self._pollRate=mmax(0.01,r)end
function ChildVm:GetPollRate()return self._pollRate end
function ChildVm:GetWatcherCount()local n=0;for _,w in ipairs(self._watchers)do if w.active then n=n+1 end end;return n end
function ChildVm:Destroy()self._running=false;for _,w in ipairs(self._watchers)do w.active=false end;self._watchers={}end

local childvm=ChildVm.new({PollRate=0.3})
_G.ChildVm=childvm

local noblock,noragdoll=false,false

local heartbeattick=0
connectsignal(runservice.Heartbeat,function()
	heartbeattick=heartbeattick+1
	if heartbeattick%6~=0 then return end
	if not state.staminalock and not noragdoll and not noblock and not state.infinitestamina then return end
	pcall(function()
		local c=localplayer.Character
		if not c then return end
		if state.staminalock then
			local st=c:GetAttribute("Stamina")or 100
			if st<state.staminamin then c:SetAttribute("Running",false)end
		end
		if state.Iframes then
			local c = localplayer.Character
			if c then c:SetAttribute("IFrames", true) end
		end
	end)
end)

local function setupcharacter(c)
	if not c then return end
	if childvm then
		childvm:OnAttributeChanged(c,"Stamina",function(v)
			if state.staminalock and v<state.staminamin then pcall(function()c:SetAttribute("Running",false)end)end
		end)
	end
end

if localplayer.Character then setupcharacter(localplayer.Character)end
pcall(function()localplayer.CharacterAdded:Connect(setupcharacter)end)
local function makedrawing(t)local d=Drawing.new(t);d.Visible=false;return d end
local hitmarkersenabled=false
local camera=workspace.CurrentCamera
local damagetexts={}
local damagecolors={Color3.fromRGB(0,255,255),Color3.fromRGB(255,255,255),Color3.fromRGB(255,50,50)}
local function showhitmarker(dmg,pos)
	if not dmg or not pos then return end
	local ok,startP=pcall(function()return pos+Vector3.new(0,math.random(),0)end)
	if not ok or not startP then return end
	local txt=makedrawing("Text")
	txt.Text=tostring(mfloor(dmg))
	txt.Size=28
	txt.Center=true
	txt.Outline=true
	pcall(function()txt.OutlineColor=Color3.fromRGB(0,0,0)end)
	txt.Color=damagecolors[math.random(1,#damagecolors)]
	txt.Font=3
	table.insert(damagetexts,{t=os.clock(),d=1.5,txt=txt,p=startP,vx=(math.random()-0.5)*8,vy=3.5+math.random()*2,vz=(math.random()-0.5)*8})
end

local function updatehitmarkers()
	if #damagetexts==0 then return end
	local now=os.clock()
	local k=1
	while k<=#damagetexts do
		local d=damagetexts[k]
		local el=now-d.t
		if el>d.d then
			pcall(function()d.txt:Remove()end)
			table.remove(damagetexts,k)
		else
			if not hitmarkersenabled then
				d.txt.Visible=false
				k=k+1
			else
				d.p=d.p+Vector3.new(d.vx*0.05,d.vy*0.05,d.vz*0.05)
				d.vy=d.vy-0.2
				local sp,on
				pcall(function()sp,on=WorldToScreen(d.p)end)
				if on and sp then
					local a=1
					if el>(d.d-0.5)then a=1-(el-(d.d-0.5))/0.5 end
					d.txt.Position=Vector2.new(sp.X,sp.Y)
					d.txt.Transparency=a
					d.txt.Visible=true
				else
					d.txt.Visible=false
				end
				k=k+1
			end
		end
	end
end

local function getalivefolder()if state.alivefolder and state.alivefolder.Parent then return state.alivefolder end;pcall(function()local p=workspace:FindFirstChild("PLAYERS");if p then state.alivefolder=p:FindFirstChild("ALIVE")end end);return state.alivefolder end
local function getkillerfolder()if state.killerfolder and state.killerfolder.Parent then return state.killerfolder end;pcall(function()local p=workspace:FindFirstChild("PLAYERS");if p then state.killerfolder=p:FindFirstChild("KILLER")end end);return state.killerfolder end
local function getgenfolder()if state.genfolder and state.genfolder.Parent then return state.genfolder end;pcall(function()local m=workspace:FindFirstChild("MAPS");if m then local g=m:FindFirstChild("GAME MAP");if g then state.genfolder=g:FindFirstChild("Generators")end end end);return state.genfolder end
local function gettrapfolder()if state.trapfolder and state.trapfolder.Parent then return state.trapfolder end;pcall(function()state.trapfolder=workspace:FindFirstChild("IGNORE")end);return state.trapfolder end
local function getfuseboxfolder()if state.fuseboxfolder and state.fuseboxfolder.Parent then return state.fuseboxfolder end;pcall(function()local m=workspace:FindFirstChild("MAPS");if m then local g=m:FindFirstChild("GAME MAP");if g then state.fuseboxfolder=g:FindFirstChild("FuseBoxes")end end end);return state.fuseboxfolder end
local function getroot(mdl,ig)
	if not mdl then return nil end
	if ig then
		local rt
		pcall(function()rt=mdl:FindFirstChild("Point1")end)
		if rt and pcall(function()return rt:IsA("BasePart")end)then return rt end
		for _,n in ipairs({"PrimaryPart","Main","Hitbox","Root","Base","Core","Engine","Middle","Center","Body","Model","Union","Part"})do
			local x;pcall(function()x=mdl:FindFirstChild(n,true)end)
			if x then local isB;pcall(function()isB=x:IsA("BasePart")end);if isB then return x end end
		end
		local best,bestVol=nil,0
		pcall(function()for _,x in ipairs(mdl:GetDescendants())do if x:IsA("BasePart")then local sz=x.Size;local vol=(sz.X or 0)*(sz.Y or 0)*(sz.Z or 0);if vol>bestVol then bestVol=vol;best=x end end end end)
		return best
	end
	local rt;pcall(function()rt=mdl:FindFirstChild("Torso")or mdl:FindFirstChild("HumanoidRootPart")or mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart",true)end)
	return rt
end

local function getname(mdl,ig,e)
	if not mdl then return "",false end
	if ig then return(e and e.genLabel or mdl.Name),false end
	if e and e._nameCache then return e._nameCache, false end
	local n=mdl.Name
	pcall(function()
		for _,plr in ipairs(game.Players:GetPlayers())do
			if plr.Character==mdl then n=plr.Name;break end
		end
	end)
	if n==""or n=="bloodsplat"or n=="BloodSplat"or n=="Model"then
		pcall(function()local hum=mdl:FindFirstChildOfClass("Humanoid");if hum and hum.DisplayName and hum.DisplayName~=""then n=hum.DisplayName end end)
	end
	if n==""or n=="bloodsplat"or n=="BloodSplat"or n=="Model"then
		pcall(function()local h=mdl:FindFirstChild("HumanoidRootPart")or mdl:FindFirstChild("Torso");if h then local own=h:FindFirstChild("Owner")or h:FindFirstChild("owner");if own and own.Value and tostring(own.Value)~=""then n=tostring(own.Value)end end end)
	end
	if e and n~="" and n~="bloodsplat" and n~="BloodSplat" and n~="Model" then
		e._nameCache=n
	end
	return n,false
end

local function getprogress(mdl)
	local v=0
	pcall(function()local a=mdl:GetAttribute("Progress");if type(a)=="number"then v=a end end)
	if v==0 then pcall(function()for _,x in ipairs(mdl:GetChildren())do if x:IsA("NumberValue")and(x.Name=="Progress"or x.Name=="progress")then local xv=x.Value;if type(xv)=="number"then v=xv end;break end end end)end
	if type(v)~="number"then v=0 end
	return mfloor(v)
end

local function deletetrap(m)
	if not m then return end
	pcall(function()
		for _,p in ipairs(m:GetDescendants())do
			if p:IsA("BasePart")then p.CanCollide=false;p.Transparency=1 end
		end
		if m:IsA("BasePart")then m.CanCollide=false;m.Transparency=1 end
	end)
	pcall(function()m.Parent=nil end)
end

local function scanplayer(m)if not m then return end;local isSelf=(m.Name==localplayer.Name or m==localplayer.Character);if not state.optself and isSelf then return end;if not m:FindFirstChildOfClass("Humanoid") then return end;local a=m.Address;if not a or state.playerdata[a]then return end;local nm=getname(m,false,nil);local e=espmod.newtracker(m,nm,state.playercolor,{isSelf=isSelf});if e then state.playerdata[a]=e end end
local function scankiller(m)if not m then return end;if not m:FindFirstChildOfClass("Humanoid") then return end;local a=m.Address;if not a or state.killerdata[a]then return end;local nm=getname(m,false,nil);local e=espmod.newtracker(m,nm,state.killercolor,{isKiller=true});if e then state.killerdata[a]=e end end

local function scangenerator(m)
	if not m then return end
	local a=m.Address
	if not a or state.gendata[a] then return end
	local e=espmod.newtracker(m, "Generator", state.gencolor, {
		isObject = true,
		isGen = true,
		custom_update = function(t, minx, miny, maxx, maxy)
			local pv = getprogress(t.model or t.object)
			local dn = (pv >= 100)
			local clk = os.clock()
			local ps = (math.sin(clk * 3) + 1) / 2
			local gv = math.floor(140 + ps * 115)
			local gg = Color3.fromRGB(gv, gv, gv)
			local dg = Color3.fromRGB(math.floor(100 + ps * 155), math.floor(180 + ps * 75), 255)

			local cx = minx + (maxx - minx) * 0.5
			local pad = 2

			t.distlabel.Position = Vector2.new(cx, maxy + pad + 2)

			if dn then
				t.distlabel.Text = espmod.tag_open .. "done" .. espmod.tag_close
				t.box.Color = dg
				t.namelabel.Color = dg
				t.distlabel.Color = dg
			else
				t.distlabel.Text = espmod.tag_open .. "prog: " .. tostring(pv) .. "%" .. espmod.tag_close
				t.distlabel.Color = gg
				t.namelabel.Color = state.gencolor
				t.box.Color = state.gencolor
			end
		end
	})
	if e then state.gendata[a]=e end
end

local function scantrap(m)if not m then return end;local a=m.Address;if not a or state.trapdata[a]then return end;local e=espmod.newtracker(m,"Trap",Color3.fromRGB(180,40,40),{isObject=true,isDanger=true});if e then state.trapdata[a]=e end end
local function scanminion(m)if not m then return end;local a=m.Address;if not a or state.miniondata[a]then return end;local e=espmod.newtracker(m,"Minion",Color3.fromRGB(200,200,200),{isObject=true});if e then state.miniondata[a]=e end end
local function scanbattery(m)if not m then return end;local a=m.Address;if not a or state.batterydata[a]then return end;local e=espmod.newtracker(m,"Battery",Color3.fromRGB(240,240,80),{isObject=true});if e then state.batterydata[a]=e end end

local function cleanupplayer(m)if not m then return end;local a=m.Address;if a and state.playerdata[a]then pcall(function()if state.playerdata[a].destroy then state.playerdata[a]:destroy()end end);state.playerdata[a]=nil end end
local function cleanupkiller(m)if not m then return end;local a=m.Address;if a and state.killerdata[a]then pcall(function()if state.killerdata[a].destroy then state.killerdata[a]:destroy()end end);state.killerdata[a]=nil end end
local function cleanupgenerator(m)if not m then return end;local a=m.Address;if a and state.gendata[a]then pcall(function()if state.gendata[a].destroy then state.gendata[a]:destroy()end end);state.gendata[a]=nil end end
local function cleanuptrap(m)if not m then return end;local a=m.Address;if a and state.trapdata[a]then pcall(function()if state.trapdata[a].destroy then state.trapdata[a]:destroy()end end);state.trapdata[a]=nil end end
local function cleanupminion(m)if not m then return end;local a=m.Address;if a and state.miniondata[a]then pcall(function()if state.miniondata[a].destroy then state.miniondata[a]:destroy()end end);state.miniondata[a]=nil end end
local function cleanupbattery(m)if not m then return end;local a=m.Address;if a and state.batterydata[a]then pcall(function()if state.batterydata[a].destroy then state.batterydata[a]:destroy()end end);state.batterydata[a]=nil end end

local function clearallplayers()for _,e in pairs(state.playerdata)do pcall(function()if e.destroy then e:destroy()end end)end;state.playerdata={}end
local function clearallkillers()for _,e in pairs(state.killerdata)do pcall(function()if e.destroy then e:destroy()end end)end;state.killerdata={}end
local function clearallgenerators()for _,e in pairs(state.gendata)do pcall(function()if e.destroy then e:destroy()end end)end;state.gendata={};state.gencount=0 end
local function clearalltraps()for _,e in pairs(state.trapdata)do pcall(function()if e.destroy then e:destroy()end end)end;state.trapdata={};for _,e in pairs(state.miniondata)do pcall(function()if e.destroy then e:destroy()end end)end;state.miniondata={}end
local function clearallbatteries()for _,e in pairs(state.batterydata)do pcall(function()if e.destroy then e:destroy()end end)end;state.batterydata={}end
local function queryplayers()local f=getalivefolder();if not f then return end;for _,c in ipairs(f:GetChildren())do if c:IsA("Model")then scanplayer(c)end end end
local function querykillers()local f=getkillerfolder();if not f then return end;for _,c in ipairs(f:GetChildren())do if c:IsA("Model")then scankiller(c)end end end
local function querygenerators()
	local f=getgenfolder()
	if not f then return end
	local seen={}
	local changed = false
	local scanned_pos={}

	local function checkgen(c)
		if not c then return end
		local p = c.Parent
		local isInner = false
		while p and p ~= game do
			if p:IsA("Model") and (p.Name == "Generator" or p:GetAttribute("Progress") ~= nil) then isInner = true break end
			p = p.Parent
		end
		if isInner then return end

		local pv
		pcall(function()pv=c:GetPivot().Position end)
		if not pv then pcall(function()pv=c.PrimaryPart and c.PrimaryPart.Position end)end
		if pv then
			for _, sp in ipairs(scanned_pos) do
				if (sp - pv).Magnitude < 40 then 
					if state.gendata[c.Address] then pcall(function()if state.gendata[c.Address].destroy then state.gendata[c.Address]:destroy()end end);state.gendata[c.Address]=nil;changed=true end
					return 
				end
			end
			table.insert(scanned_pos, pv)
		end
		if not state.gendata[c.Address] then changed=true end
		seen[c.Address]=true;scangenerator(c)
	end

	for _,c in ipairs(f:GetChildren())do
		if c:IsA("Model")or c.Name=="Generator"then
			checkgen(c)
		end
	end
	pcall(function()
		for _,c in ipairs(f:GetDescendants())do
			if c:IsA("Model")and(c.Name=="Generator"or c:GetAttribute("Progress")~=nil or c:FindFirstChild("Point1",true)or c:FindFirstChild("Progress",true))then
				if not seen[c.Address]then 
					checkgen(c)
				end
			end
		end
	end)
	for a,e in pairs(state.gendata)do
		if not seen[a]and(not e.object or not e.object.Parent)then pcall(function()if e.destroy then e:destroy()end end);state.gendata[a]=nil;changed=true end
	end
	if changed then
		local gList={}
		for a,e in pairs(state.gendata)do
			local p; pcall(function() p=(e.object and e.object.PrimaryPart and e.object.PrimaryPart.Position) or (e.object and e.object:FindFirstChild("HumanoidRootPart") and e.object.HumanoidRootPart.Position) or (e.object and e.object:IsA("BasePart") and e.object.Position) end)
			table.insert(gList,{e=e,px=p and p.X or 0,pz=p and p.Z or 0})
		end
		table.sort(gList,function(a,b)
			if mabs(a.px-b.px) < 10 then return a.pz < b.pz end
			return a.px < b.px
		end)
		for i,v in ipairs(gList)do
			v.e.genLabel="Gen"..tostring(i)
			if v.e.namelabel then v.e.namelabel.Text=v.e.genLabel end
		end
	end
end
local scanactive = false
local function scanignorefolder()
	local f=gettrapfolder()
	if not f then return end
	if not state.trapenabled and not state.batteryenabled and not state.deletetraps and not state._forcescan then return end
	if scanactive then return end
	scanactive = true
	pcall(function()
		local function checkscan(c)
			if not c then return end
			local n = c.Name:lower()
			if n == "trap" then
				if state.deletetraps then deletetrap(c)
				elseif state.trapenabled then scantrap(c) end
			elseif n == "minion" then
				if state.trapenabled then scanminion(c) end
			elseif n == "battery" then
				if state.batteryenabled or state._forcescan then scanbattery(c) end
			end
		end
		for _, c in ipairs(f:GetChildren()) do
			checkscan(c)
			if c:IsA("Folder") or c:IsA("Model") then
				pcall(function() for _, sub in ipairs(c:GetChildren()) do checkscan(sub) end end)
			end
		end
	end)
	scanactive = false
end
local function querytraps()scanignorefolder()end
local function querybatteries()scanignorefolder()end
local function onmatchend()
	state.gencount=0
end

local function watchkillerFolder()
	local kf=getkillerfolder()
	if not kf then return end
	childvm:OnChildRemoved(kf,function(m)
		cleanupkiller(m)
		local stillHas=false
		pcall(function()
			for _,c in ipairs(kf:GetChildren())do
				if c:IsA("Model")then stillHas=true;break end
			end
		end)
		if not stillHas then onmatchend()end
	end)
end

local function teleporttoposition(hrp,pos,label)
	pcall(function() 
		local tgt = CFrame.new(pos.X, pos.Y+3, pos.Z)
		local char = hrp.Parent
		if char and char:IsA("Model") then char:PivotTo(tgt) else hrp.CFrame = tgt end
		task.spawn(function()
			for i=1, 5 do
				task.wait(0.05)
				if char and char:IsA("Model") then char:PivotTo(tgt) else hrp.CFrame = tgt end
			end
		end)
	end)
	pcall(function()notify("TP",label,3)end)
end

local function getbatterypos(hrpP)
	local f = gettrapfolder()
	if not f or not hrpP then return nil end
	local bp, bd
	local function check(c)
		if c.Name:lower() == "battery" then
			local p; pcall(function() p = c:IsA("BasePart") and c.Position or c:FindFirstChildWhichIsA("BasePart", true).Position end)
			if p then
				local d = (p - hrpP).Magnitude
				if not bd or d < bd then bd = d; bp = p end
			end
		end
	end
	pcall(function()
		for _, c in ipairs(f:GetChildren()) do
			check(c)
			if c:IsA("Folder") or c:IsA("Model") then
				for _, sub in ipairs(c:GetChildren()) do check(sub) end
			end
		end
	end)
	return bp, bd
end

local function teleporttogenerator()
	pcall(function()
		local c=localplayer.Character
		if not c then return end
		local hrp=c:FindFirstChild("HumanoidRootPart")or c:FindFirstChild("Torso")
		if not hrp then return end
		local hrpP = hrp.Position
		local mgp, mgd
		local gf = getgenfolder()
		if gf then
			for _, c in ipairs(gf:GetDescendants()) do
				if c:IsA("Model") and (c.Name == "Generator" or c:GetAttribute("Progress") ~= nil or c:FindFirstChild("Progress", true)) then
					local prog = getprogress(c)
					if prog < 100 then
						local p; pcall(function() p = c:IsA("BasePart") and c.Position or c:FindFirstChildWhichIsA("BasePart", true).Position end)
						if p then
							local d = (p - hrpP).Magnitude
							if not mgd or d < mgd then mgd = d; mgp = p end
						end
					end
				end
			end
		end
		if not mgp then pcall(function()notify("Gen TP","No incomplete generators found",3)end);return end
		teleporttoposition(hrp,mgp,"Teleported to nearest generator")
	end)
end

local function teleporttobattery()
	pcall(function()
		local c=localplayer.Character
		if not c then return end
		local hrp=c:FindFirstChild("HumanoidRootPart")or c:FindFirstChild("Torso")
		if not hrp then return end
		local bp = getbatterypos(hrp.Position)
		if not bp then pcall(function()notify("Battery TP","No batteries found",3)end);return end
		teleporttoposition(hrp,bp,"Teleported to nearest battery")
	end)
end

local function teleporttofusebox()
	pcall(function()
		local c=localplayer.Character
		if not c then return end
		local hrp=c:FindFirstChild("HumanoidRootPart")or c:FindFirstChild("Torso")
		if not hrp then return end
		local fbf=getfuseboxfolder()
		if not fbf then pcall(function()notify("FuseBox TP","FuseBoxes folder not found",3)end);return end
		local bestPos, bestD
		for _,fb in ipairs(fbf:GetChildren())do
			if fb.Name=="FuseBox"then
				local ins=fb:GetAttribute("Inserted")
				if not ins then
					local pos;pcall(function()pos=fb.Position end)
					if not pos then pcall(function()local p=fb:FindFirstChildWhichIsA("BasePart",true);if p then pos=p.Position end end)end
					if pos then 
						local d = (pos - hrp.Position).Magnitude
						if not bestD or d < bestD then bestD, bestPos = d, pos end
					end
				end
			end
		end
		if not bestPos then pcall(function()notify("FuseBox TP","No available fuseboxes",3)end);return end
		teleporttoposition(hrp,bestPos,"Teleported to nearest fusebox")
	end)
end

local ignorewatching=false
local function watchignoreFolder()
	if ignorewatching then return end
	local f=gettrapfolder()
	if not f then return end
	ignorewatching=true
	childvm:OnChildAdded(f,function(c)
		local n=c.Name:lower()
		if n=="trap" then
			if state.deletetraps then deletetrap(c)
			elseif state.trapenabled then scantrap(c)end
		elseif n=="minion" then
			if state.trapenabled then scanminion(c)end
		elseif n=="battery" then
			if state.batteryenabled then scanbattery(c)end
		end
	end)
	childvm:OnChildRemoved(f,function(c)
		local n=c.Name:lower()
		if n=="trap" then cleanuptrap(c)
		elseif n=="minion" then cleanupminion(c)
		elseif n=="battery" then cleanupbattery(c)
		end
	end)
end

local defaultgray=Color3.fromRGB(180,180,180)
local function updateentityesp(dr, en, col, bc)
	if not en then return end
	local mr = state.myroot
	local mrP
	if mr then pcall(function() mrP = mr.Position end) end
	local vs
	pcall(function() vs = camera.ViewportSize end)
	local clk = os.clock()
	local v2 = Vector2.new
	local gg, dg
	for a, e in pairs(dr) do
		local mdl, rt, ig = e.model, e.root, e.isGen
		if not mdl or not mdl.Parent then
			removeentity(e)
			dr[a] = nil
		elseif mdl == localplayer.Character and not state.optself then
			hideentity(e)
		else
			rt = getroot(mdl, ig) or rt
			e.root = rt
			local rPos
			if rt then pcall(function() rPos = rt.Position end) end

			if not rPos then
				hideentity(e)
			else
				local sp, on
				pcall(function() sp, on = WorldToScreen(rPos) end)
				local onScreen = on and sp and vs
					and sp.X > -200 and sp.Y > -200
					and sp.X < vs.X + 200 and sp.Y < vs.Y + 200

				if not onScreen then
					hideentity(e)
				elseif ig then
					e._hid = nil
					if not gg then
						local ps = (msin(clk * 3) + 1) / 2
						local gv = mfloor(140 + ps * 115)
						gg = Color3.fromRGB(gv, gv, gv)
						dg = Color3.fromRGB(mfloor(100 + ps * 155), mfloor(180 + ps * 75), 255)
					end

					local ny = sp.Y - 20
					e.nm.Position = v2(sp.X, ny)
					e.nm.Visible = true
					if col and e._col ~= col then e._col = col; e.nm.Color = col end
					if e.gp then
						local pv = e.gp()
						local dn = pv >= 100
						e.pg.Text = dn and (state.tagopen.."done"..state.tagclose) or (state.tagopen.."prog: " .. tostring(pv) .. "%"..state.tagclose)
						e.pg.Color = dn and dg or gg
						if dn then e.nm.Color = dg end
						e.pg.Position = v2(sp.X, ny + 16)
						e.pg.Visible = true
					end
				else
					local nm, _ = getname(mdl, false, e)
					e.nm.Text = nm
					local ecol, ebc = col, bc
					local d = 0
					if mrP then d = mfloor((rPos - mrP).Magnitude) end
					local top, bot
					pcall(function() top = rPos + offsettop; bot = rPos - offsetbottom end)
					if not top then top = rPos end
					if not bot then bot = rPos end
					local ts, ton, bs, bon
					pcall(function()
						ts, ton = WorldToScreen(top)
						bs, bon = WorldToScreen(bot)
					end)
					local bh, bw = 70, 40
					if ton and bon then
						bh = mabs(ts.Y - bs.Y)
						bw = bh / 1.5
					end
					local x, y = sp.X - bw / 2, sp.Y - bh / 2
					e._hid = nil
					if ecol and e._col ~= ecol then
						e._col = ecol
						e.nm.Color = ecol; e.tr.Color = ecol
						e.skHead.Color = ecol; e.skCollar.Color = ecol; e.skTorso.Color = ecol; e.skPelvis.Color = ecol
						e.skLUA.Color = ecol; e.skLLA.Color = ecol; e.skRUA.Color = ecol; e.skRLA.Color = ecol
						e.skLUL.Color = ecol; e.skLLL.Color = ecol; e.skRUL.Color = ecol; e.skRLL.Color = ecol
						if ebc then e.box.Color = ebc end
					end
					e.box.Position = v2(x, y); e.box.Size = v2(bw, bh); e.box.Visible = true
					if state.opttracers and vs then
						e.tr.From = v2(vs.X / 2, vs.Y)
						e.tr.To = v2(sp.X, y + bh)
						e.tr.Visible = true
					else
						e.tr.Visible = false
					end
					if state.optskeleton then
						if not e._limbs or clk - (e._limbT or 0) > 2 then
							pcall(function()
								e._limbs = {
									hd = mdl:FindFirstChild("Head"),
									la = mdl:FindFirstChild("Left Arm"),
									ra = mdl:FindFirstChild("Right Arm"),
									ll = mdl:FindFirstChild("Left Leg"),
									rl = mdl:FindFirstChild("Right Leg")
								}
							end)
							e._limbT = clk
						end

						local lb = e._limbs or {}
						local hd, la, ra, ll, rl = lb.hd, lb.la, lb.ra, lb.ll, lb.rl
						if hd and la and ra and ll and rl then
							local hdP, laP, raP, llP, rlP
							pcall(function()
								hdP = hd.Position; laP = la.Position
								raP = ra.Position; llP = ll.Position; rlP = rl.Position
							end)

							if hdP and laP and raP and llP and rlP then
								local hdSp, hdOn, laSp, laOn, raSp, raOn, llSp, llOn, rlSp, rlOn
								pcall(function()
									hdSp, hdOn = WorldToScreen(hdP)
									laSp, laOn = WorldToScreen(laP)
									raSp, raOn = WorldToScreen(raP)
									llSp, llOn = WorldToScreen(llP)
									rlSp, rlOn = WorldToScreen(rlP)
								end)
								if hdOn and laOn and raOn and llOn and rlOn then
									local cx = sp.X
									local slaX, slaY = laSp.X, laSp.Y
									local sraX, sraY = raSp.X, raSp.Y
									local sllX, sllY = llSp.X, llSp.Y
									local srlX, srlY = rlSp.X, rlSp.Y
									if slaX > sraX then slaX, slaY, sraX, sraY = sraX, sraY, slaX, slaY end
									if sllX > srlX then sllX, sllY, srlX, srlY = srlX, srlY, sllX, sllY end
									local headRad = mmax(4, mmin(12, bh / 10))
									e.skHead.Radius = headRad
									e.skHead.Position = v2(hdSp.X, hdSp.Y)
									e.skHead.Visible = true
									local neckY = hdSp.Y + headRad + bh * 0.02
									local collarW = bw * 0.35
									local lShX, rShX = cx - collarW, cx + collarW
									e.skCollar.From = v2(lShX, neckY); e.skCollar.To = v2(rShX, neckY); e.skCollar.Visible = true
									local pelvisY = y + bh * 0.58
									e.skTorso.From = v2(cx, neckY); e.skTorso.To = v2(cx, pelvisY); e.skTorso.Visible = true
									local hipW = bw * 0.1
									local lHipX, rHipX = cx - hipW, cx + hipW
									e.skPelvis.From = v2(lHipX, pelvisY); e.skPelvis.To = v2(rHipX, pelvisY); e.skPelvis.Visible = true
									local laClampX = mmin(slaX, cx - bw * 0.05)
									local raClampX = mmax(sraX, cx + bw * 0.05)
									local lElbowX = lShX + (laClampX - lShX) * 0.5
									local lElbowY = neckY + (slaY - neckY) * 0.5
									local rElbowX = rShX + (raClampX - rShX) * 0.5
									local rElbowY = neckY + (sraY - neckY) * 0.5
									e.skLUA.From = v2(lShX, neckY); e.skLUA.To = v2(lElbowX, lElbowY); e.skLUA.Visible = true
									e.skRUA.From = v2(rShX, neckY); e.skRUA.To = v2(rElbowX, rElbowY); e.skRUA.Visible = true
									e.skLLA.From = v2(lElbowX, lElbowY); e.skLLA.To = v2(laClampX - bw * 0.03, slaY); e.skLLA.Visible = true
									e.skRLA.From = v2(rElbowX, rElbowY); e.skRLA.To = v2(raClampX + bw * 0.03, sraY); e.skRLA.Visible = true
									local llClampX = mmin(sllX, cx - bw * 0.02)
									local rlClampX = mmax(srlX, cx + bw * 0.02)
									local lKneeX = lHipX + (llClampX - lHipX) * 0.5
									local lKneeY = pelvisY + (sllY - pelvisY) * 0.5
									local rKneeX = rHipX + (rlClampX - rHipX) * 0.5
									local rKneeY = pelvisY + (srlY - pelvisY) * 0.5
									e.skLUL.From = v2(lHipX, pelvisY); e.skLUL.To = v2(lKneeX, lKneeY); e.skLUL.Visible = true
									e.skRUL.From = v2(rHipX, pelvisY); e.skRUL.To = v2(rKneeX, rKneeY); e.skRUL.Visible = true
									e.skLLL.From = v2(lKneeX, lKneeY); e.skLLL.To = v2(llClampX - bw * 0.02, sllY); e.skLLL.Visible = true
									e.skRLL.From = v2(rKneeX, rKneeY); e.skRLL.To = v2(rlClampX + bw * 0.02, srlY); e.skRLL.Visible = true
								else
									e.skHead.Visible=false;e.skCollar.Visible=false;e.skTorso.Visible=false;e.skPelvis.Visible=false
									e.skLUA.Visible=false;e.skLLA.Visible=false;e.skRUA.Visible=false;e.skRLA.Visible=false
									e.skLUL.Visible=false;e.skLLL.Visible=false;e.skRUL.Visible=false;e.skRLL.Visible=false
								end
							else
								e.skHead.Visible=false;e.skCollar.Visible=false;e.skTorso.Visible=false;e.skPelvis.Visible=false
								e.skLUA.Visible=false;e.skLLA.Visible=false;e.skRUA.Visible=false;e.skRLA.Visible=false
								e.skLUL.Visible=false;e.skLLL.Visible=false;e.skRUL.Visible=false;e.skRLL.Visible=false
							end
						else
							e.skHead.Visible=false;e.skCollar.Visible=false;e.skTorso.Visible=false;e.skPelvis.Visible=false
							e.skLUA.Visible=false;e.skLLA.Visible=false;e.skRUA.Visible=false;e.skRLA.Visible=false
							e.skLUL.Visible=false;e.skLLL.Visible=false;e.skRUL.Visible=false;e.skRLL.Visible=false
						end
					else
						e.skHead.Visible=false;e.skCollar.Visible=false;e.skTorso.Visible=false;e.skPelvis.Visible=false
						e.skLUA.Visible=false;e.skLLA.Visible=false;e.skRUA.Visible=false;e.skRLA.Visible=false
						e.skLUL.Visible=false;e.skLLL.Visible=false;e.skRUL.Visible=false;e.skRLL.Visible=false
					end
					local ny = y - 16
					e.nm.Position = v2(sp.X, ny)
					e.nm.Visible = true
					e.dt.Text = state.tagopen .. tostring(d) .. " st" .. state.tagclose
					e.dt.Position = v2(sp.X, y + bh + 8)
					local isKiller = (dr == state.killerdata)
					local isSelf = (mdl == localplayer.Character)
					e.dt.Color = ((isKiller or isSelf) and state.dangercolor) and state.dangercolor or defaultgray
					e.dt.Visible = true
					local desiredHpColor = state.usecustomhpcolor and state.hpcolor or Color3.fromRGB(150,255,150)
					if e.hpFill.Color ~= desiredHpColor then e.hpFill.Color = desiredHpColor end
					local hp = e.targetHp or 100
					local mhp = e.maxHp or 100
					if e.humanoid then
						pcall(function()
							local h = e.humanoid.Health
							local m = e.humanoid.MaxHealth
							if type(h) == "number" then hp = h end
							if type(m) == "number" and m > 0 then mhp = m; e.maxHp = m end
						end)
					end
					if type(hp) == "number" and type(e.hpLast) == "number" and hp < e.hpLast and (e.hpLast - hp) > 0.1 and hitmarkersenabled then
						showhitmarker(e.hpLast - hp, rPos)
					end
					e.targetHp = hp
					if type(mhp) ~= "number" or mhp <= 0 then mhp = 100 end
					local pct = mmax(0, mmin(hp / mhp, 1))
					e.hpLast = hp
					e.hpSmooth = e.hpSmooth + ((e.hpVis or 100) - e.hpSmooth) * 0.08
					e.hpVis = (e.hpVis or 100) + (pct * 100 - (e.hpVis or 100)) * 0.15
					local hbW, hbH = 4, bh
					local hx = x - hbW - 3
					e.hpBg.Position = v2(hx - 1, y - 1); e.hpBg.Size = v2(hbW + 2, hbH + 2); e.hpBg.Visible = true
					local dmgH = mfloor(hbH * (e.hpSmooth / 100))
					local fillH = mfloor(hbH * (e.hpVis / 100))
					if dmgH > fillH and dmgH > 0 then
						e.hpDmg.Position = v2(hx, y + (hbH - dmgH)); e.hpDmg.Size = v2(hbW, dmgH); e.hpDmg.Visible = true
					else
						e.hpDmg.Visible = false
					end
					if fillH > 0 then
						e.hpFill.Position = v2(hx, y + (hbH - fillH)); e.hpFill.Size = v2(hbW, fillH); e.hpFill.Visible = true
					else
						e.hpFill.Visible = false
					end
					e.hpBor.Position = v2(hx - 1, y - 1); e.hpBor.Size = v2(hbW + 2, hbH + 2); e.hpBor.Visible = true
				end
			end
		end
	end
end
local function updateobjectesp(dr, en, c)
	if not en then return end
	local mr = state.myroot
	local mrP
	if mr then pcall(function() mrP = mr.Position end) end
	local vs
	pcall(function() vs = camera.ViewportSize end)
	local v2 = Vector2.new
	for a, e in pairs(dr) do
		local mdl, rt = e.model, e.root
		if not mdl or not mdl.Parent then
			removeobject(e)
			dr[a] = nil
		else
			if not rt or not rt.Parent then
				if e._noRoot then
					if e.nm then e.nm.Visible = false end
					if e.dt then e.dt.Visible = false end
				else
					pcall(function()
						rt = mdl:IsA("BasePart") and mdl
							or mdl:FindFirstChild("HumanoidRootPart")
							or mdl:FindFirstChild("Core")
							or mdl.PrimaryPart
							or mdl:FindFirstChildWhichIsA("BasePart", true)
					end)
					if rt then e.root = rt else e._noRoot = true end
				end
			end

			local rPos
			if e.root then pcall(function() rPos = e.root.Position end) end
			
			if not rPos then
				if e.nm then e.nm.Visible = false end
				if e.dt then e.dt.Visible = false end
			else
				local sp, on
				pcall(function() sp, on = WorldToScreen(rPos) end)

				local onScreen = on and sp and vs
					and sp.X > -200 and sp.Y > -200
					and sp.X < vs.X + 200 and sp.Y < vs.Y + 200

				if onScreen then
					local d = 0
					if mrP then d = mfloor((rPos - mrP).Magnitude) end
					if e.nm then e.nm.Position = v2(sp.X, sp.Y); e.nm.Color = c; e.nm.Visible = true end
					if e.dt then
						e.dt.Text = state.tagopen .. tostring(d) .. " st" .. state.tagclose
						e.dt.Position = v2(sp.X, sp.Y + 18)
						e.dt.Color = (dr == state.trapdata and state.dangercolor) and state.dangercolor or defaultgray
						e.dt.Visible = true
					end
				else
					if e.nm then e.nm.Visible = false end
					if e.dt then e.dt.Visible = false end
				end
			end
		end
	end
end
local agv = {
    waitInit=0.2, waitWireMove=0.006, waitWireSteps=6, waitWireRelease=0.05,
    waitWirePost=0.06, waitWireRetry=0.08, waitWiresPhase=1.0,
    waitSwitchClick=0.02, waitSwitchPost=0.08, waitSwitchPhase=0.3,
    waitLeverPhase=1.0, waitPullMove=0.01, waitPullHold=0.06,
    waitPullRelease=0.03, wireMaxAttempts=6, wireSnapDist=15,
    switchMaxRounds=20, pullMax=15, pullSafety=5,
    leverThreshold=10, frameThreshold=20,
}

local function ag_centerof(obj)
    local ap,sz=obj.AbsolutePosition,obj.AbsoluteSize
    return ap.X+sz.X*0.5, ap.Y+sz.Y*0.5
end
local function ag_dragwire(sx,sy,tx,ty)
    mousemoveabs(sx,sy);      task.wait(agv.waitWireMove)
    mouse1press();             task.wait(agv.waitWireMove)
    for i=1,agv.waitWireSteps do
        local t=i/agv.waitWireSteps
        mousemoveabs(sx+(tx-sx)*t, sy+(ty-sy)*t); task.wait(agv.waitWireMove)
    end
    mousemoveabs(tx,ty);      task.wait(agv.waitWireRelease)
    mouse1release();           task.wait(agv.waitWirePost)
end
local function ag_wiresnapped(name,wiresend,wireboxes)
    local en=wiresend:FindFirstChild(name)
    local bx=wireboxes:FindFirstChild(name)
    if not en or not bx then return false end
    local ch=bx:FindFirstChild("ConnectHitbox")
    if not ch then return false end
    local ep=en.AbsolutePosition+en.AbsoluteSize*0.5
    local cp=ch.AbsolutePosition+ch.AbsoluteSize*0.5
    return (ep.X-cp.X)^2+(ep.Y-cp.Y)^2 < agv.wireSnapDist^2
end

local ag_leverStart, ag_frameStart, ag_leverRef, ag_frameRef
local function ag_levermoved()
    if not ag_leverStart or not ag_leverRef then return false end
    local cur=ag_leverRef.AbsolutePosition
    return mabs(cur.X-ag_leverStart.X)>agv.leverThreshold
        or mabs(cur.Y-ag_leverStart.Y)>agv.leverThreshold
end
local function ag_puzzledone()
    if not ag_frameStart or not ag_frameRef then return false end
    local cur=ag_frameRef.AbsolutePosition
    return mabs(cur.Y-ag_frameStart.Y)>agv.frameThreshold
end

local function ag_findgengui(gui)
    local g=gui:FindFirstChild("Gen")
    if g and g:FindFirstChild("MainFrame") then
        local mf=g:FindFirstChild("MainFrame")
        if mf and mf:FindFirstChild("Generator") then return g,mf end
    end
    for _,sg in ipairs(gui:GetChildren()) do
        if sg:IsA("ScreenGui") then
            local mf=sg:FindFirstChild("MainFrame")
            if mf and mf:FindFirstChild("Generator") then return sg,mf end
        end
    end
    return nil,nil
end

local autogen_active=false
local ag_was_visible=false
local ag_solved=false

local function handle_autogen_loop()
    if autogen_active then return end
    autogen_active=true
    task.spawn(function()
        while state.autogen_enabled do
            pcall(function()
                local gui=localplayer:FindFirstChild("PlayerGui")
                if not gui then return end

                local gen,mainframe=ag_findgengui(gui)
                if not gen or not mainframe then
                    ag_was_visible=false; ag_solved=false; return
                end

                local visible=mainframe.Visible
                    and (not gen:IsA("ScreenGui") or gen.Enabled)

                if not visible then
                    ag_was_visible=false; ag_solved=false; return
                end

                if not ag_was_visible then
                    ag_was_visible=true; ag_solved=false
                end
                if ag_solved then return end 

                ag_frameRef   = mainframe
                ag_frameStart = mainframe.AbsolutePosition

                local generator = mainframe:WaitForChild("Generator",5)
                if not generator then return end
                local lever  = generator:WaitForChild("Lever",5)
                local switch = generator:WaitForChild("Switch",5)
                local wires  = generator:WaitForChild("Wires",5)
                if not lever or not switch or not wires then return end
                ag_leverRef=lever

                task.wait(agv.waitInit)
                if not state.autogen_enabled or not gen.Enabled then return end

                local wiresstart=wires:WaitForChild("WiresStart",5)
                local wiresend  =wires:WaitForChild("WiresEnd",5)
                local wireboxes =wires:WaitForChild("WireBoxes",5)
                if not wiresstart or not wiresend or not wireboxes then return end

                local deadline=os.clock()+8
                repeat task.wait(0.05) until #wireboxes:GetChildren()>=4 or os.clock()>deadline or not state.autogen_enabled
                deadline=os.clock()+8
                repeat task.wait(0.05) until #wiresend:GetChildren()>=4   or os.clock()>deadline or not state.autogen_enabled
                task.wait(0.05)
                if not state.autogen_enabled or not gen.Enabled then return end

                for _,node in next,wiresstart:GetChildren() do
                    if not state.autogen_enabled or not gen.Enabled or ag_puzzledone() then break end
                    local name=node.Name
                    local en=wiresend:FindFirstChild(name)
                    local bx=wireboxes:FindFirstChild(name)
                    if not en or not bx then continue end
                    local hb    =bx:FindFirstChild("ConnectHitbox") or bx
                    local hitbox=en:FindFirstChild("Hitbox") or en
                    local tx,ty =ag_centerof(hb)
                    local attempts=0
                    repeat
                        attempts+=1
                        if attempts>1 then task.wait(agv.waitWireRetry) end
                        local sx,sy=ag_centerof(hitbox)
                        ag_dragwire(sx,sy,tx,ty)
                        task.wait(agv.waitWireRetry)
                    until ag_wiresnapped(name,wiresend,wireboxes)
                        or attempts>=agv.wireMaxAttempts
                        or not gen.Enabled or not state.autogen_enabled
                end

                task.wait(agv.waitWiresPhase)
                if not gen.Enabled or not state.autogen_enabled then return end

                local switchlist=switch:WaitForChild("Switches",5)
                if not switchlist then return end
                local buttons={}
                local sdl=os.clock()+8
                repeat
                    task.wait(0.05); buttons={}
                    for _,c in next,switchlist:GetChildren() do
                        if c:IsA("ImageButton") then buttons[#buttons+1]=c end
                    end
                until #buttons>=5 or os.clock()>sdl or not state.autogen_enabled
                if not state.autogen_enabled or #buttons<5 then return end

                table.sort(buttons,function(a,b) return tonumber(a.Name)<tonumber(b.Name) end)
                ag_leverStart=lever.AbsolutePosition

                local st={}
                for _,sw in next,buttons do st[sw.Name]=false end
                local function clickswitch(sw)
                    local cx,cy=ag_centerof(sw)
                    mousemoveabs(cx,cy); task.wait(agv.waitSwitchClick)
                    mouse1press();       task.wait(agv.waitSwitchClick)
                    mouse1release();     task.wait(agv.waitSwitchPost)
                    st[sw.Name]=not st[sw.Name]
                end

                for _,sw in next,buttons do
                    if not gen.Enabled or not state.autogen_enabled then break end
                    clickswitch(sw)
                end
                task.wait(agv.waitSwitchPhase)

                if not ag_levermoved() and gen.Enabled and state.autogen_enabled then
                    local round=0
                    repeat
                        round+=1
                        local clicked=0
                        for _,sw in next,buttons do
                            if not st[sw.Name] and gen.Enabled and state.autogen_enabled then
                                clickswitch(sw); clicked+=1
                            end
                        end
                        task.wait(agv.waitSwitchPhase)
                        if not ag_levermoved() and clicked==0 and gen.Enabled and state.autogen_enabled then
                            for _,sw in next,buttons do clickswitch(sw) end
                            task.wait(agv.waitSwitchPhase)
                        end
                    until ag_levermoved() or round>=agv.switchMaxRounds
                        or not gen.Enabled or not state.autogen_enabled
                end

                if not ag_levermoved() then return end
                task.wait(agv.waitLeverPhase)
                if not gen.Enabled or not state.autogen_enabled then return end

                local rope  =lever:WaitForChild("Rope",5)
                if not rope then return end
                local button=rope:WaitForChild("Button",5)
                if not button then return end

                local function dopull()
                    if not gen.Enabled or not state.autogen_enabled then return end
                    local bx,by=ag_centerof(button)
                    mousemoveabs(bx,by); task.wait(agv.waitPullMove)
                    mouse1press();        task.wait(agv.waitPullMove)
                    mousemoverel(0,35);   task.wait(agv.waitPullHold)
                    mouse1release();      task.wait(agv.waitPullRelease)
                end

                local pulls=0
                repeat
                    dopull(); pulls+=1
                until ag_puzzledone() or pulls>=agv.pullMax
                    or not gen.Enabled or not state.autogen_enabled

                if not ag_puzzledone() and gen.Enabled and state.autogen_enabled then
                    for _=1,agv.pullSafety do dopull() end
                end

                ag_solved=true 
            end)
            task.wait(0.1)
        end
        autogen_active=false
    end)
end

UI.AddTab("Bite By Night",function(tab)
	local esp=tab:Section("esp","Left")
	esp:Toggle("esp_player","Player",function(s)state.playerenabled=s;if s then queryplayers()else clearallplayers()end end)
	esp:ColorPicker("cp_player",0.47,0.78,1,1,function(c)
		state.playercolor=c;
		state.playerboxcolor=Color3.fromRGB(mfloor(c.R*0.67*255),mfloor(c.G*0.8*255),mfloor(c.B*0.87*255))
		for _, e in pairs(state.playerdata) do pcall(function() e:setcolor(c) end) end
	end)
	esp:Toggle("esp_killer","Killer",function(s)state.killerenabled=s;if s then querykillers();watchkillerFolder()else clearallkillers()end end)
	esp:ColorPicker("cp_killer",1,0.31,0.31,1,function(c)
		state.killercolor=c;
		state.killerboxcolor=Color3.fromRGB(mfloor(c.R*0.78*255),mfloor(c.G*0.63*255),mfloor(c.B*0.63*255))
		for _, e in pairs(state.killerdata) do pcall(function() e:setcolor(c) end) end
	end)
	esp:Toggle("esp_gen","Generator",function(s)state.genenabled=s;if s then querygenerators()else clearallgenerators()end end)
	esp:ColorPicker("cp_gen",0.31,1,0.47,1,function(c)state.gencolor=c end)
	esp:Toggle("esp_trap","Trap",function(s)state.trapenabled=s;if s then querytraps();watchignoreFolder()else clearalltraps()end end)
	esp:Toggle("esp_bat","Battery",function(s)state.batteryenabled=s;if s then querybatteries();watchignoreFolder()else clearallbatteries()end end)
	local opts=tab:Section("stuff","Left")
	opts:Toggle("esp_self","Self esp",function(s)state.optself=s;if s then if state.playerenabled then queryplayers()end else local f=getalivefolder();if f then cleanupplayer(f:FindFirstChild(localplayer.Name))end end end)
	opts:Toggle("esp_skeleton","Skeleton",true,function(s)state.optskeleton=s;espmod.show_skeleton=s end)
	opts:Toggle("esp_tracers","Tracers",true,function(s)state.opttracers=s;espmod.show_tracers=s end)
	opts:Toggle("hm_toggle","Reticles",function(s)hitmarkersenabled=s;if not s then updatehitmarkers()end end)
	opts:Toggle("tag_brackets","Use Brackets [ ]",function(s)if s then state.tagopen="[";state.tagclose="]";espmod.tag_open="[";espmod.tag_close="]"else state.tagopen="<";state.tagclose=">";espmod.tag_open="<";espmod.tag_close=">"end end)
	opts:Toggle("custom_hp_toggle","Change HP Color",function(s)state.usecustomhpcolor=s;espmod.use_custom_hp_color=s end)
	opts:ColorPicker("cp_hpBar","HP Color",0.39,1,0.59,1,function(c)state.hpcolor=c;espmod.custom_hp_color=c end)
	local tps=tab:Section("Teleports","Right")
	tps:Button("Gen tp",function()teleporttogenerator()end)
	tps:Button("Battery tp",function()teleporttobattery()end)
	tps:Button("FuseBox tp",function()teleporttofusebox()end)
	local tweaks=tab:Section("tweaks","Right")
	tweaks:Toggle("stam_lock","Stamina Lock",function(s)state.staminalock=s end)
	tweaks:SliderInt("stam_min","Stamina",0,100,30,function(v)state.staminamin=v end)
	local t_ag, t_dt, t_if
	t_ag = tweaks:Toggle("auto_gen","Auto Gen (not finished)",function(s)
		if s and localplayer.Name ~= "besosme" then
			pcall(function() notify("Bite By Night", "not done read", 3) end)
			if t_ag then t_ag:SetValue(false) end
			return
		end
		state.autogen_enabled=s;if s then handle_autogen_loop()end
	end)
	t_dt = tweaks:Toggle("del_traps","Delete Traps(not finished)",function(s)
		if s and localplayer.Name ~= "besosme" then
			pcall(function() notify("Bite By Night", "not done read", 3) end)
			if t_dt then t_dt:SetValue(false) end
			return
		end
		state.deletetraps=s;if s then scanignorefolder();watchignoreFolder()end
	end)
	t_if = tweaks:Toggle("I_frames", "Iframes (experimental)", function(s)
		if s and localplayer.Name ~= "besosme" then
			pcall(function() notify("Bite By Night", "not done read", 3) end)
			if t_if then t_if:SetValue(false) end
			return
		end
		state.Iframes=s
	end)
end)
local af=getalivefolder()
if af then
	childvm:OnChildAdded(af,function(c)if c:IsA("Model")and state.playerenabled then scanplayer(c)end end)
	childvm:OnChildRemoved(af,function(c)cleanupplayer(c)end)
end

local kf=getkillerfolder()
if kf then
	childvm:OnChildAdded(kf,function(c)if c:IsA("Model")and state.killerenabled then scankiller(c)end end)
end

local gf=getgenfolder()
if gf then
	childvm:OnChildAdded(gf,function(c)if state.genenabled and(c:IsA("Model")or c.Name=="Generator")then scangenerator(c)end end)
	childvm:OnChildRemoved(gf,function(c)cleanupgenerator(c)end)
end

local batterycolor=Color3.fromRGB(240,240,80)
connectsignal(runservice.RenderStepped,function()
	state.steptick=state.steptick+1
	if state.steptick%2==0 then pcall(function()if localplayer.Character then state.myroot=localplayer.Character:FindFirstChild("Torso")or localplayer.Character:FindFirstChild("HumanoidRootPart")end end)end
	if state.steptick>=180 then
		state.steptick=0
		if state.playerenabled then queryplayers()end
		if state.killerenabled then querykillers()end
		if state.genenabled then querygenerators()end
		scanignorefolder()
	end
	if state.steptick%3==0 then
		state.dangercolor=nil
		espmod.danger_color=nil
		local mrP;if state.myroot then pcall(function()mrP=state.myroot.Position end)end
		if mrP then
			local nd=math.huge
			for _,e in pairs(state.killerdata)do pcall(function()if e.root and e.root.Position then local dd=(e.root.Position-mrP).Magnitude;if dd<nd then nd=dd end end end)end
			if nd<60 then 
				local dp=(msin(os.clock()*5)+1)/2
				state.dangercolor=Color3.fromRGB(255,mfloor(dp*255),mfloor(dp*255))
				espmod.danger_color=state.dangercolor
			end
		end
	end

	for _, tracker in pairs(espmod.trackers) do
		pcall(tracker._update, tracker)
	end

	if state.steptick%3==0 then
		local ps=(msin(os.clock()*4)+1)/2
		local tCol=Color3.fromRGB(mfloor(120+ps*135),mfloor(40+ps*110),mfloor(20+ps*20))
		local mv=mfloor(100+ps*155)
		local mCol=Color3.fromRGB(mv,mv,mv)
		for _, e in pairs(state.trapdata) do pcall(function() e:setcolor(tCol) end) end
		for _, e in pairs(state.miniondata) do pcall(function() e:setcolor(mCol) end) end
	end
	updatehitmarkers()
end)
_G._BBN_CLEANUP = function()
	for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end;connections={}
	if childvm then pcall(function() childvm:Destroy() end) end
	pcall(clearallplayers); pcall(clearallkillers); pcall(clearallgenerators); pcall(clearalltraps); pcall(clearallbatteries)
	return function() UI.RemoveTab("Bite By Night") end
end
