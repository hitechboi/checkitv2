--[[
    bbn more like bnb from osamason ahahahah - for matcha latte env
]]

if _G._BBN_CLEANUP then pcall(_G._BBN_CLEANUP) end
local _p=game.Players.LocalPlayer

local _v = {
    pe=false, pd={}, pc=Color3.fromRGB(120,200,255), pb=Color3.fromRGB(80,160,220),
    ke=false, kd={}, kc=Color3.fromRGB(255,80,80), kb=Color3.fromRGB(200,50,50),
    ge=false, gd={}, gc=Color3.fromRGB(80,255,120),
    te=false, td={},
    be=false, bd={},
    md={},
    gn=0, af=nil, kf=nil, gf=nil, tf=nil,
    optSelf=false, optSkeleton=true, optTracers=true,
    sLock=false, sMin=30,
    gt=0, st=0, mr=nil, dangerCol=nil
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
local _rs=game:GetService("RunService")
local _bbnConns={}
local function _bbnC(sig,fn)local c=sig:Connect(fn);table.insert(_bbnConns,c);return c end
local mfloor,mabs,msin,mmax,mmin=math.floor,math.abs,math.sin,math.max,math.min
local _v3Top,_v3Bot=Vector3.new(0,2.5,0),Vector3.new(0,3,0)

local function _valEq(a,b)
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

local function _snapChildren(parent)
	local s={}
	pcall(function()for _,c in ipairs(parent:GetChildren())do local a=c.Address;if a then s[a]=c end end end)
	return s
end

function ChildVm:OnChildAdded(parent,cb)
	local cur=_snapChildren(parent)
	local pending={}
	local w={active=true,poll=function()
		if not parent or not parent.Parent then return end
		local now=_snapChildren(parent)
		for a,c in pairs(now)do if not cur[a]then if not pending[a]then pending[a]=true;pcall(cb,c)end else pending[a]=nil end end
		cur=now
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OnceChildAdded(parent,cb)local c;c=self:OnChildAdded(parent,function(ch)c:Disconnect();cb(ch)end);return c end
function ChildVm:OnChildRemoved(parent,cb)
	local cur=_snapChildren(parent)
	local missing={}
	local w={active=true,poll=function()
		local now=_snapChildren(parent)
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
		if not _valEq(cur,new)then local old=cur;cur=new;pcall(cb,new,old)end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OncePropertyChanged(inst,prop,cb)local c;c=self:OnPropertyChanged(inst,prop,function(n,o)c:Disconnect();cb(n,o)end);return c end
function ChildVm:OnChanged(inst,cb,props)
	props=props or{"Name","Parent","Visible","Text","Value","Position","Size","Health","MaxHealth","WalkSpeed","Transparency","Enabled","Anchored","CFrame"}
	local conns={}
	for _,prop in ipairs(props)do
		if prop=="CFrame"then
			local ok=pcall(function()memory_read("uintptr_t",inst.Address+0x148)end)
			if ok then table.insert(conns,self:OnCFrameChanged(inst,function(n,o)pcall(cb,"CFrame",n,o)end))end
		elseif prop=="Size"then
			local ok=pcall(function()memory_read("uintptr_t",inst.Address+0x148)end)
			if ok then table.insert(conns,self:OnSizeChanged(inst,function(n,o)pcall(cb,"Size",n,o)end))end
		else
			local readable=pcall(function()local _=inst[prop]end)
			if readable then table.insert(conns,self:OnPropertyChanged(inst,prop,function(n,o)pcall(cb,prop,n,o)end))end
		end
	end
	return Connection.new(function()for _,c in ipairs(conns)do c:Disconnect()end end)
end

function ChildVm:OnCFrameChanged(inst,cb,thresh)
	thresh=thresh or 0.001
	local function read()
		local r;pcall(function()local p=memory_read("uintptr_t",inst.Address+0x148);local b=p+0xC0;r={X=memory_read("float",b+36),Y=memory_read("float",b+40),Z=memory_read("float",b+44),r00=memory_read("float",b),r01=memory_read("float",b+4),r02=memory_read("float",b+8),r10=memory_read("float",b+12),r11=memory_read("float",b+16),r12=memory_read("float",b+20),r20=memory_read("float",b+24),r21=memory_read("float",b+28),r22=memory_read("float",b+32)}end)
		return r
	end
	local cur=read()
	local w={active=true,poll=function()
		if not inst or not inst.Parent then return end
		local new=read()
		if not new or not cur then cur=new;return end
		if mabs(new.X-cur.X)>thresh or mabs(new.Y-cur.Y)>thresh or mabs(new.Z-cur.Z)>thresh or mabs(new.r00-cur.r00)>thresh or mabs(new.r11-cur.r11)>thresh or mabs(new.r22-cur.r22)>thresh then
			local old=cur;cur=new;pcall(cb,new,old)
		end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OnSizeChanged(inst,cb,thresh)
	thresh=thresh or 0.001
	local function read()
		local r;pcall(function()local p=memory_read("uintptr_t",inst.Address+0x148);local s=memory_read("uintptr_t",p+0x50);r={X=memory_read("float",s+0x20),Y=memory_read("float",s+0x24),Z=memory_read("float",s+0x28)}end)
		return r
	end
	local cur=read()
	local w={active=true,poll=function()
		if not inst or not inst.Parent then return end
		local new=read()
		if not new or not cur then cur=new;return end
		if mabs(new.X-cur.X)>thresh or mabs(new.Y-cur.Y)>thresh or mabs(new.Z-cur.Z)>thresh then local old=cur;cur=new;pcall(cb,new,old)end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
end

function ChildVm:OnOffsetValueChanged(inst,offsets,memType,cb,thresh)
	thresh=thresh or 0.001
	local function read()
		local r;pcall(function()
			local addr=inst.Address
			if type(offsets)=="table"then for i=1,#offsets-1 do addr=memory_read("uintptr_t",addr+offsets[i])end;r=memory_read(memType,addr+offsets[#offsets])else r=memory_read(memType,addr+offsets)end
		end)
		return r
	end
	local cur=read()
	local w={active=true,poll=function()
		if not inst or not inst.Parent then return end
		local new=read()
		if new==nil or cur==nil then cur=new;return end
		local changed=type(new)=="number"and mabs(new-cur)>thresh or new~=cur
		if changed then local old=cur;cur=new;pcall(cb,new,old)end
	end}
	table.insert(self._watchers,w)
	return Connection.new(function()w.active=false end)
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

local _cv=ChildVm.new({PollRate=0.3})
_G.ChildVm=_cv

local _nB,_nR=false,false

local _hbTk=0
_bbnC(_rs.Heartbeat,function()
	_hbTk=_hbTk+1
	if _hbTk%6~=0 then return end
	if not _v.sLock and not _nR and not _nB then return end
	pcall(function()
		local c=_p.Character
		if not c then return end
		if _v.sLock then
			local st=c:GetAttribute("Stamina")or 100
			if st<_v.sMin then c:SetAttribute("Running",false)end
		end
		if _nR then c:SetAttribute("Ragdoll",false)end
		if _nB then c:SetAttribute("CanRun",true)end
	end)
end)

local function _suC(c)
	if not c then return end
	if _cv then
		_cv:OnAttributeChanged(c,"Stamina",function(v)
			if _v.sLock and v<_v.sMin then pcall(function()c:SetAttribute("Running",false)end)end
		end)
	end
end

if _p.Character then _suC(_p.Character)end
pcall(function()_p.CharacterAdded:Connect(_suC)end)
local function _mkD(t)local d=Drawing.new(t);d.Visible=false;return d end
local _hmEnabled=false
local _cam=workspace.CurrentCamera
local _dmgT={}
local _dCol={Color3.fromRGB(0,255,255),Color3.fromRGB(255,255,255),Color3.fromRGB(255,50,50)}
local function _showHM(dmg,pos)
	if not dmg or not pos then return end
	local txt=_mkD("Text")
	txt.Text=tostring(mfloor(dmg))
	txt.Size=28
	txt.Center=true
	txt.Outline=true
	pcall(function()txt.OutlineColor=Color3.fromRGB(0,0,0)end)
	txt.Color=_dCol[math.random(1,#_dCol)]
	txt.Font=3
	table.insert(_dmgT,{t=os.clock(),d=1.5,txt=txt,p=pos+Vector3.new(0,math.random(),0),vx=(math.random()-0.5)*8,vy=3.5+math.random()*2,vz=(math.random()-0.5)*8})
end

local function _updateHM()
	if #_dmgT==0 then return end
	local now=os.clock()
	local k=1
	while k<=#_dmgT do
		local d=_dmgT[k]
		local el=now-d.t
		if el>d.d then
			pcall(function()d.txt:Remove()end)
			table.remove(_dmgT,k)
		else
			if not _hmEnabled then
				d.txt.Visible=false
				k=k+1
			else
				d.p=d.p+Vector3.new(d.vx*0.05,d.vy*0.05,d.vz*0.05)
				d.vy=d.vy-0.2
				local sp,on=WorldToScreen(d.p)
				if on then
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

local function _gAF()if _v.af and _v.af.Parent then return _v.af end;pcall(function()local p=workspace:FindFirstChild("PLAYERS");if p then _v.af=p:FindFirstChild("ALIVE")end end);return _v.af end
local function _gKF()if _v.kf and _v.kf.Parent then return _v.kf end;pcall(function()local p=workspace:FindFirstChild("PLAYERS");if p then _v.kf=p:FindFirstChild("KILLER")end end);return _v.kf end
local function _gGF()if _v.gf and _v.gf.Parent then return _v.gf end;pcall(function()local m=workspace:FindFirstChild("MAPS");if m then local g=m:FindFirstChild("GAME MAP");if g then _v.gf=g:FindFirstChild("Generators")end end end);return _v.gf end
local function _gTF()if _v.tf and _v.tf.Parent then return _v.tf end;pcall(function()_v.tf=workspace:FindFirstChild("IGNORE")end);return _v.tf end
local _allKeys={"box","tl","bl","nm","pg","dt","hpBg","hpDmg","hpFill","hpBor","skHead","skCollar","skTorso","skPelvis","skLUA","skLLA","skRUA","skRLA","skLUL","skLLL","skRUL","skRLL","tr"}
local function _cE(mdl,col,bc,ig)
	if not mdl then return nil end
	local ad=mdl.Address
	if not ad then return nil end
	local rt
	if ig then
		rt=mdl:FindFirstChild("Point1")
		if not rt then for _,x in ipairs(mdl:GetDescendants())do if x:IsA("BasePart")then rt=x;break end end end
	else
		rt=mdl:FindFirstChild("Torso")or mdl:FindFirstChild("HumanoidRootPart")
	end
	_v.gn=_v.gn+1
	local gl=ig and("Gen"..tostring(_v.gn))or nil
	local e={model=mdl,root=rt,isGen=ig,genLabel=gl}
	if ig then
		function e.gp()local v=0;pcall(function()v=mdl:GetAttribute("Progress")or 0 end);return mfloor(v)end
	end
	if not ig then
		e.box=_mkD("Square");e.box.Filled=false;e.box.Color=bc;e.box.Thickness=1;e.box.Size=Vector2.new(40,70);e.box.ZIndex=2
		e.tl=_mkD("Line");e.tl.Color=col;e.tl.Thickness=2;e.tl.ZIndex=3
		e.bl=_mkD("Line");e.bl.Color=col;e.bl.Thickness=1;e.bl.ZIndex=3
		e.hpBg=_mkD("Square");e.hpBg.Filled=true;e.hpBg.Color=Color3.fromRGB(15,15,15);e.hpBg.Transparency=1;e.hpBg.Size=Vector2.new(6,72);e.hpBg.ZIndex=1
		e.hpDmg=_mkD("Square");e.hpDmg.Filled=true;e.hpDmg.Color=Color3.fromRGB(200,60,60);e.hpDmg.Transparency=1;e.hpDmg.ZIndex=2
		e.hpFill=_mkD("Square");e.hpFill.Filled=true;e.hpFill.Color=Color3.fromRGB(150,255,150);e.hpFill.Transparency=1;e.hpFill.ZIndex=3
		e.hpBor=_mkD("Square");e.hpBor.Filled=false;e.hpBor.Color=Color3.fromRGB(50,50,50);e.hpBor.Thickness=1;e.hpBor.Transparency=1;e.hpBor.Size=Vector2.new(6,72);e.hpBor.ZIndex=4
		e.skHead=_mkD("Circle");e.skHead.Radius=8;e.skHead.NumSides=16;e.skHead.Thickness=2;e.skHead.Color=col;e.skHead.Filled=false;e.skHead.ZIndex=4
		e.skCollar=_mkD("Line");e.skCollar.Thickness=2;e.skCollar.Color=col;e.skCollar.ZIndex=4
		e.skTorso=_mkD("Line");e.skTorso.Thickness=2;e.skTorso.Color=col;e.skTorso.ZIndex=4
		e.skPelvis=_mkD("Line");e.skPelvis.Thickness=2;e.skPelvis.Color=col;e.skPelvis.ZIndex=4
		e.skLUA=_mkD("Line");e.skLUA.Thickness=2;e.skLUA.Color=col;e.skLUA.ZIndex=4
		e.skLLA=_mkD("Line");e.skLLA.Thickness=2;e.skLLA.Color=col;e.skLLA.ZIndex=4
		e.skRUA=_mkD("Line");e.skRUA.Thickness=2;e.skRUA.Color=col;e.skRUA.ZIndex=4
		e.skRLA=_mkD("Line");e.skRLA.Thickness=2;e.skRLA.Color=col;e.skRLA.ZIndex=4
		e.skLUL=_mkD("Line");e.skLUL.Thickness=2;e.skLUL.Color=col;e.skLUL.ZIndex=4
		e.skLLL=_mkD("Line");e.skLLL.Thickness=2;e.skLLL.Color=col;e.skLLL.ZIndex=4
		e.skRUL=_mkD("Line");e.skRUL.Thickness=2;e.skRUL.Color=col;e.skRUL.ZIndex=4
		e.skRLL=_mkD("Line");e.skRLL.Thickness=2;e.skRLL.Color=col;e.skRLL.ZIndex=4
		e._limbs={};pcall(function()e._limbs={hd=mdl:FindFirstChild("Head"),la=mdl:FindFirstChild("Left Arm"),ra=mdl:FindFirstChild("Right Arm"),ll=mdl:FindFirstChild("Left Leg"),rl=mdl:FindFirstChild("Right Leg")}end);e._limbT=os.clock()
		e.tr=_mkD("Line");e.tr.Thickness=1;e.tr.Color=col;e.tr.ZIndex=1
		e.hpVis=100;e.hpSmooth=100;e.hpLast=100;e.targetHp=100;e.maxHp=100
		local h=mdl:FindFirstChildOfClass("Humanoid")
		if h then
			e.humanoid=h
			e.targetHp=h.Health;e.maxHp=h.MaxHealth>0 and h.MaxHealth or 100
			e.hpVis=(e.targetHp/e.maxHp)*100;e.hpSmooth=e.hpVis;e.hpLast=e.targetHp
			e._hc=_cv:OnChanged(h,function(prop,new)
				if prop=="MaxHealth"and new>0 then
					e.maxHp=new
				end
			end,{"MaxHealth"})
		end
	end
	e.nm=_mkD("Text");e.nm.Text=ig and gl or(mdl.Name=="besosme"and"checkit owner"or mdl.Name);e.nm.Color=col;e.nm.Size=ig and 15 or 14;e.nm.Center=true;e.nm.Outline=true;e.nm.ZIndex=5
	if ig then
		e.pg=_mkD("Text");e.pg.Text="<prog: 0%>";e.pg.Color=Color3.fromRGB(180,180,180);e.pg.Size=13;e.pg.Center=true;e.pg.Outline=true;e.pg.ZIndex=5
	else
		e.dt=_mkD("Text");e.dt.Text="";e.dt.Color=Color3.fromRGB(180,180,180);e.dt.Size=11;e.dt.Center=true;e.dt.Outline=true;e.dt.ZIndex=5
	end
	return e
end

local function _rE(e)
	if not e then return end
	if e._hc then pcall(function()e._hc:Disconnect()end)end
	for _,k in ipairs(_allKeys)do pcall(function()if e[k]then e[k]:Remove()end end)end
end

local function _cO(mdl,lbl)
	if not mdl then return nil end
	local ad=mdl.Address;if not ad then return nil end
	local rt=mdl:IsA("BasePart")and mdl or mdl:FindFirstChild("HumanoidRootPart")or mdl:FindFirstChild("Core")or mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart",true)
	local e={model=mdl,root=rt}
	e.nm=_mkD("Text");e.nm.Text=lbl;e.nm.Size=15;e.nm.Center=true;e.nm.Outline=true;e.nm.ZIndex=5
	e.dt=_mkD("Text");e.dt.Text="";e.dt.Color=Color3.fromRGB(180,180,180);e.dt.Size=11;e.dt.Center=true;e.dt.Outline=true;e.dt.ZIndex=5
	return e
end
local function _rO(e)if not e then return end;pcall(function()if e.nm then e.nm:Remove()end;if e.dt then e.dt:Remove()end end)end
local function _hE(e)if e._hid then return end;e._hid=true;for _,k in ipairs(_allKeys)do if e[k]then e[k].Visible=false end end end
local function _sP(m)if not m then return end;if not _v.optSelf and m.Name==_p.Name then return end;if not m:FindFirstChildOfClass("Humanoid") then return end;local a=m.Address;if not a or _v.pd[a]then return end;local e=_cE(m,_v.pc,_v.pb,false);if e then _v.pd[a]=e end end
local function _sK(m)if not m then return end;if not m:FindFirstChildOfClass("Humanoid") then return end;local a=m.Address;if not a or _v.kd[a]then return end;local e=_cE(m,_v.kc,_v.kb,false);if e then _v.kd[a]=e end end
local function _sG(m)if not m then return end;local a=m.Address;if not a or _v.gd[a]then return end;local e=_cE(m,_v.gc,_v.gc,true);if e then _v.gd[a]=e end end
local function _sT(m)if not m then return end;local a=m.Address;if not a or _v.td[a]then return end;local e=_cO(m,"Trap");if e then _v.td[a]=e end end
local function _sM(m)if not m then return end;local a=m.Address;if not a or _v.md[a]then return end;local e=_cO(m,"Minion");if e then _v.md[a]=e end end
local function _sB(m)if not m then return end;local a=m.Address;if not a or _v.bd[a]then return end;local e=_cO(m,"Battery");if e then _v.bd[a]=e end end
local function _cP(m)if not m then return end;local a=m.Address;if a and _v.pd[a]then _rE(_v.pd[a]);_v.pd[a]=nil end end
local function _cK(m)if not m then return end;local a=m.Address;if a and _v.kd[a]then _rE(_v.kd[a]);_v.kd[a]=nil end end
local function _cG(m)if not m then return end;local a=m.Address;if a and _v.gd[a]then _rE(_v.gd[a]);_v.gd[a]=nil end end
local function _cRT(m)if not m then return end;local a=m.Address;if a and _v.td[a]then _rO(_v.td[a]);_v.td[a]=nil end end
local function _cRM(m)if not m then return end;local a=m.Address;if a and _v.md[a]then _rO(_v.md[a]);_v.md[a]=nil end end
local function _cRB(m)if not m then return end;local a=m.Address;if a and _v.bd[a]then _rO(_v.bd[a]);_v.bd[a]=nil end end
local function _xP()for _,e in pairs(_v.pd)do _rE(e)end;_v.pd={}end
local function _xK()for _,e in pairs(_v.kd)do _rE(e)end;_v.kd={}end
local function _xG()for _,e in pairs(_v.gd)do _rE(e)end;_v.gd={};_v.gn=0 end
local function _xT()for _,e in pairs(_v.td)do _rO(e)end;_v.td={};for _,e in pairs(_v.md)do _rO(e)end;_v.md={}end
local function _xB()for _,e in pairs(_v.bd)do _rO(e)end;_v.bd={}end
local function _qP()local f=_gAF();if not f then return end;for _,c in ipairs(f:GetChildren())do if c:IsA("Model")then _sP(c)end end end
local function _qK()local f=_gKF();if not f then return end;for _,c in ipairs(f:GetChildren())do if c:IsA("Model")then _sK(c)end end end
local function _qG()local f=_gGF();if not f then return end;_v.gn=0;for _,c in ipairs(f:GetChildren())do if c.Name=="Generator"or c:IsA("Model")then _sG(c)end end end
local _scanActive = false
local function _scanIgn()
	local f=_gTF()
	if not f then return end
	if not _v.te and not _v.be and not _v.ge then return end
	if _scanActive then return end
	_scanActive = true
	task.spawn(function()
		local desc = f:GetDescendants()
		for i, c in ipairs(desc) do
			if c:IsA("Model") or c:IsA("BasePart") then
				if _v.te and c.Name=="Trap" then _sT(c)
				elseif _v.te and(c.Name=="Minion" or c.Name=="minion") then _sM(c)
				elseif _v.be and c.Name=="Battery" then _sB(c)
				end
			end
			if i % 50 == 0 then task.wait() end
		end
		_scanActive = false
	end)
end
local function _qT()_scanIgn()end
local function _qB()_scanIgn()end
local function _onMatchEnd()
	_v.gn=0
end

local function _watchKillerFolder()
	local kf=_gKF()
	if not kf then return end
	_cv:OnChildRemoved(kf,function(m)
		_cK(m)
		local stillHas=false
		pcall(function()
			for _,c in ipairs(kf:GetChildren())do
				if c:IsA("Model")then stillHas=true;break end
			end
		end)
		if not stillHas then _onMatchEnd()end
	end)
end

local function _tpNearestGen()
	pcall(function()
		local c=_p.Character
		if not c then return end
		local hrp=c:FindFirstChild("HumanoidRootPart")or c:FindFirstChild("Torso")
		if not hrp then return end
		local best,bestD=nil,math.huge
		for _,e in pairs(_v.gd)do
			if e.root and e.root.Position then
				local d=(e.root.Position-hrp.Position).Magnitude
				if d<bestD then bestD=d;best=e end
			end
		end
		if best and best.root then
			local pos=best.root.Position
			local prim=memory_read("uintptr_t",hrp.Address+0x148)
			local cfb=prim+0xC0
			memory_write("float",cfb+36,pos.X)
			memory_write("float",cfb+40,pos.Y+3)
			memory_write("float",cfb+44,pos.Z)
			pcall(function()notify("Gen TP","Teleported to "..tostring(best.genLabel or"generator").." ("..mfloor(bestD).." studs)",3)end)
		end
	end)
end

local _ignWatching=false
local function _watchIgnoreFolder()
	if _ignWatching then return end
	local f=_gTF()
	if not f then return end
	_ignWatching=true
	_cv:OnChildAdded(f,function(c)
		pcall(function()
			if not(c:IsA("Model")or c:IsA("BasePart"))then return end
			if _v.te and c.Name=="Trap" then _sT(c)
			elseif _v.te and(c.Name=="Minion"or c.Name=="minion")then _sM(c)
			elseif _v.be and c.Name=="Battery" then _sB(c)
			end
		end)
	end)
	_cv:OnChildRemoved(f,function(c)
		pcall(function()
			if c.Name=="Trap" then _cRT(c)
			elseif c.Name=="Minion"or c.Name=="minion" then _cRM(c)
			elseif c.Name=="Battery" then _cRB(c)
			end
		end)
	end)
end

local _defGray=Color3.fromRGB(180,180,180)
local function _uE(dr,en,col,bc)
	if not en then return end
	local mr=_v.mr
	local clk=os.clock()
	local v2=Vector2.new
	local gg,dg
	for a,e in pairs(dr)do
		local mdl,rt,ig=e.model,e.root,e.isGen
		if not mdl or not mdl.Parent then
			_rE(e)
			dr[a]=nil
		elseif mdl==_p.Character and not _v.optSelf then
			_hE(e)
		else
			if not rt or not rt.Parent then
				if ig then
					for _,x in ipairs(mdl:GetDescendants())do if x:IsA("BasePart")then rt=x;e.root=rt;break end end
				else
					rt=mdl:FindFirstChild("Torso")or mdl:FindFirstChild("HumanoidRootPart");e.root=rt
				end
			end
			if rt and rt.Position then
				local sp,on=WorldToScreen(rt.Position)
				if on then
					if ig then
						e._hid=nil
						if not gg then local ps=(msin(clk*3)+1)/2;local gv=mfloor(140+ps*115);gg=Color3.fromRGB(gv,gv,gv);dg=Color3.fromRGB(mfloor(100+ps*155),mfloor(180+ps*75),255)end
						local ny=sp.Y-20
						e.nm.Position=v2(sp.X,ny);e.nm.Visible=true
						if col and e._col~=col then e._col=col;e.nm.Color=col end
						if e.gp then
							local pv=e.gp()
							local dn=pv>=100
							e.pg.Text=dn and"<done>"or"<prog: "..tostring(pv).."%>"
							e.pg.Color=dn and dg or gg
							if dn then e.nm.Color=dg end
							e.pg.Position=v2(sp.X,ny+16);e.pg.Visible=true
						end
					else
						local d=0
						if mr and mr.Position then
							local diff=rt.Position-mr.Position
							d=mfloor(diff.Magnitude)
						end
						local top,bot=rt.Position+_v3Top,rt.Position-_v3Bot
						local ts,ton=WorldToScreen(top)
						local bs,bon=WorldToScreen(bot)
						local bh,bw=70,40
						if ton and bon then
							bh=mabs(ts.Y-bs.Y)
							bw=ig and bh or bh/1.5
						end
						local x,y=sp.X-bw/2,sp.Y-bh/2
						e._hid=nil
						if col and e._col~=col then e._col=col;e.tl.Color=col;e.bl.Color=col;e.nm.Color=col;e.tr.Color=col;e.skHead.Color=col;e.skCollar.Color=col;e.skTorso.Color=col;e.skPelvis.Color=col;e.skLUA.Color=col;e.skLLA.Color=col;e.skRUA.Color=col;e.skRLA.Color=col;e.skLUL.Color=col;e.skLLL.Color=col;e.skRUL.Color=col;e.skRLL.Color=col;if bc then e.box.Color=bc end end
						e.box.Position=v2(x,y);e.box.Size=v2(bw,bh);e.box.Visible=true
						e.tl.From=v2(x,y);e.tl.To=v2(x+bw,y);e.tl.Visible=true
						e.bl.From=v2(x,y+bh);e.bl.To=v2(x+bw,y+bh);e.bl.Visible=true
						if _v.optTracers then
							local vs=_cam.ViewportSize
							e.tr.From=v2(vs.X/2,vs.Y)
							e.tr.To=v2(sp.X,y+bh)
							e.tr.Visible=true
						else
							e.tr.Visible=false
						end
						if _v.optSkeleton then
							if _v.st%2==0 then
							if not e._limbs or clk-(e._limbT or 0)>2 then pcall(function()e._limbs={hd=mdl:FindFirstChild("Head"),la=mdl:FindFirstChild("Left Arm"),ra=mdl:FindFirstChild("Right Arm"),ll=mdl:FindFirstChild("Left Leg"),rl=mdl:FindFirstChild("Right Leg")}end);e._limbT=clk end
							local _lb=e._limbs or {}
							local hd,la,ra,ll,rl=_lb.hd,_lb.la,_lb.ra,_lb.ll,_lb.rl
							if hd and la and ra and ll and rl and hd:IsA("BasePart")and la:IsA("BasePart")and ra:IsA("BasePart")and ll:IsA("BasePart")and rl:IsA("BasePart")then
								local hdSp,hdOn=WorldToScreen(hd.Position)
								local laSp,laOn=WorldToScreen(la.Position)
								local raSp,raOn=WorldToScreen(ra.Position)
								local llSp,llOn=WorldToScreen(ll.Position)
								local rlSp,rlOn=WorldToScreen(rl.Position)
								if hdOn and laOn and raOn and llOn and rlOn then
									local cx=sp.X
									local slaX,slaY,sraX,sraY=laSp.X,laSp.Y,raSp.X,raSp.Y
									local sllX,sllY,srlX,srlY=llSp.X,llSp.Y,rlSp.X,rlSp.Y
									if slaX>sraX then slaX,slaY,sraX,sraY=sraX,sraY,slaX,slaY end
									if sllX>srlX then sllX,sllY,srlX,srlY=srlX,srlY,sllX,sllY end
									local headRad=mmax(4,mmin(12,bh/10))
									e.skHead.Radius=headRad;e.skHead.Position=v2(hdSp.X,hdSp.Y);e.skHead.Visible=true
									local neckY=hdSp.Y+headRad+bh*0.02
									local collarW=bw*0.35
									local lShX,rShX=cx-collarW,cx+collarW
									e.skCollar.From=v2(lShX,neckY);e.skCollar.To=v2(rShX,neckY);e.skCollar.Visible=true
									local pelvisY=y+bh*0.58
									e.skTorso.From=v2(cx,neckY);e.skTorso.To=v2(cx,pelvisY);e.skTorso.Visible=true
									local hipW=bw*0.1
									local lHipX,rHipX=cx-hipW,cx+hipW
									e.skPelvis.From=v2(lHipX,pelvisY);e.skPelvis.To=v2(rHipX,pelvisY);e.skPelvis.Visible=true
									local laClampX=mmin(slaX,cx-bw*0.05)
									local raClampX=mmax(sraX,cx+bw*0.05)
									local lElbowX=lShX+(laClampX-lShX)*0.5
									local lElbowY=neckY+(slaY-neckY)*0.5
									local rElbowX=rShX+(raClampX-rShX)*0.5
									local rElbowY=neckY+(sraY-neckY)*0.5
									e.skLUA.From=v2(lShX,neckY);e.skLUA.To=v2(lElbowX,lElbowY);e.skLUA.Visible=true
									e.skRUA.From=v2(rShX,neckY);e.skRUA.To=v2(rElbowX,rElbowY);e.skRUA.Visible=true
									local lHandX=laClampX-bw*0.03
									local rHandX=raClampX+bw*0.03
									e.skLLA.From=v2(lElbowX,lElbowY);e.skLLA.To=v2(lHandX,slaY);e.skLLA.Visible=true
									e.skRLA.From=v2(rElbowX,rElbowY);e.skRLA.To=v2(rHandX,sraY);e.skRLA.Visible=true
									local llClampX=mmin(sllX,cx-bw*0.02)
									local rlClampX=mmax(srlX,cx+bw*0.02)
									local lKneeX=lHipX+(llClampX-lHipX)*0.5
									local lKneeY=pelvisY+(sllY-pelvisY)*0.5
									local rKneeX=rHipX+(rlClampX-rHipX)*0.5
									local rKneeY=pelvisY+(srlY-pelvisY)*0.5
									e.skLUL.From=v2(lHipX,pelvisY);e.skLUL.To=v2(lKneeX,lKneeY);e.skLUL.Visible=true
									e.skRUL.From=v2(rHipX,pelvisY);e.skRUL.To=v2(rKneeX,rKneeY);e.skRUL.Visible=true
									local lFootX=llClampX-bw*0.02
									local rFootX=rlClampX+bw*0.02
									e.skLLL.From=v2(lKneeX,lKneeY);e.skLLL.To=v2(lFootX,sllY);e.skLLL.Visible=true
									e.skRLL.From=v2(rKneeX,rKneeY);e.skRLL.To=v2(rFootX,srlY);e.skRLL.Visible=true
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
							end
						else
							e.skHead.Visible=false;e.skCollar.Visible=false;e.skTorso.Visible=false;e.skPelvis.Visible=false
							e.skLUA.Visible=false;e.skLLA.Visible=false;e.skRUA.Visible=false;e.skRLA.Visible=false
							e.skLUL.Visible=false;e.skLLL.Visible=false;e.skRUL.Visible=false;e.skRLL.Visible=false
						end
						local ny=y-16
						e.nm.Position=v2(sp.X,ny);e.nm.Visible=true
						e.dt.Text="<"..tostring(d).." st>";e.dt.Position=v2(sp.X,y+bh+8);e.dt.Color=_v.dangerCol or _defGray;e.dt.Visible=true
						local hp,mhp=e.targetHp or 100,e.maxHp or 100
						if e.humanoid then pcall(function()hp=e.humanoid.Health;mhp=e.humanoid.MaxHealth;e.maxHp=mhp end)end
						if hp < e.hpLast and (e.hpLast - hp) > 0.1 and _hmEnabled then _showHM(e.hpLast - hp, rt.Position) end
						e.targetHp=hp
						if mhp<=0 then mhp=100 end
						local pct=mmax(0,mmin(hp/mhp,1))
						e.hpLast=hp
						e.hpSmooth=e.hpSmooth+((e.hpVis or 100)-e.hpSmooth)*0.08
						e.hpVis=(e.hpVis or 100)+(pct*100-(e.hpVis or 100))*0.15
						local hbW,hbH=4,bh
						local hx=x-hbW-3
						e.hpBg.Position=v2(hx-1,y-1);e.hpBg.Size=v2(hbW+2,hbH+2);e.hpBg.Visible=true
						local dmgH=mfloor(hbH*(e.hpSmooth/100))
						local fillH=mfloor(hbH*(e.hpVis/100))
						if dmgH>fillH and dmgH>0 then
							e.hpDmg.Position=v2(hx,y+(hbH-dmgH));e.hpDmg.Size=v2(hbW,dmgH);e.hpDmg.Visible=true
						else
							e.hpDmg.Visible=false
						end
						if fillH>0 then
							e.hpFill.Position=v2(hx,y+(hbH-fillH));e.hpFill.Size=v2(hbW,fillH);e.hpFill.Visible=true
						else
							e.hpFill.Visible=false
						end
						e.hpBor.Position=v2(hx-1,y-1);e.hpBor.Size=v2(hbW+2,hbH+2);e.hpBor.Visible=true
					end
				else
					_hE(e)
				end
			else
				_hE(e)
			end
		end
	end
end

local function _uO(dr,en,cFunc)
	if not en then return end
	local mr = _v.mr
	local v2=Vector2.new
	local c=(type(cFunc)=="function")and cFunc()or cFunc
	for a,e in pairs(dr)do
		local mdl,rt=e.model,e.root
		if not mdl or not mdl.Parent then
			_rO(e);dr[a]=nil
		else
			if not rt or not rt.Parent then
				rt=mdl:IsA("BasePart")and mdl or mdl:FindFirstChild("HumanoidRootPart")or mdl:FindFirstChild("Core")or mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart",true)
				e.root=rt
			end
			if rt and rt.Position then
				local sp,on=WorldToScreen(rt.Position)
				if on then
					local d=0
					if mr and mr.Position then
						d=mfloor((rt.Position-mr.Position).Magnitude)
					end
					e.nm.Position=v2(sp.X,sp.Y);e.nm.Color=c;e.nm.Visible=true
					e.dt.Text="<"..tostring(d).." st>";e.dt.Position=v2(sp.X,sp.Y+18);e.dt.Visible=true
				else
					if e.nm then e.nm.Visible=false end;if e.dt then e.dt.Visible=false end
				end
			else
				if e.nm then e.nm.Visible=false end;if e.dt then e.dt.Visible=false end
			end
		end
	end
end

UI.AddTab("Bite By Night",function(tab)
	local esp=tab:Section("esp","Left")
	esp:Toggle("esp_player","Player",function(s)_v.pe=s;if s then _qP()else _xP()end end)
	esp:ColorPicker("cp_player",0.47,0.78,1,1,function(c)_v.pc=c;_v.pb=Color3.fromRGB(mfloor(c.R*0.67*255),mfloor(c.G*0.8*255),mfloor(c.B*0.87*255))end)
	esp:Toggle("esp_killer","Killer",function(s)_v.ke=s;if s then _qK();_watchKillerFolder()else _xK()end end)
	esp:ColorPicker("cp_killer",1,0.31,0.31,1,function(c)_v.kc=c;_v.kb=Color3.fromRGB(mfloor(c.R*0.78*255),mfloor(c.G*0.63*255),mfloor(c.B*0.63*255))end)
	esp:Toggle("esp_gen","Generator",function(s)_v.ge=s;if s then _qG()else _xG()end end)
	esp:ColorPicker("cp_gen",0.31,1,0.47,1,function(c)_v.gc=c end)
	esp:Toggle("esp_trap","Trap",function(s)_v.te=s;if s then _qT();_watchIgnoreFolder()else _xT()end end)
	esp:Toggle("esp_bat","Battery",function(s)_v.be=s;if s then _qB();_watchIgnoreFolder()else _xB()end end)
	local opts=tab:Section("stuff","Left")
	opts:Toggle("esp_self","Self esp",function(s)_v.optSelf=s;if s then if _v.pe then _qP()end else local f=_gAF();if f then _cP(f:FindFirstChild(_p.Name))end end end)
	opts:Toggle("esp_skeleton","Skeleton",true,function(s)_v.optSkeleton=s end)
	opts:Toggle("esp_tracers","Tracers",true,function(s)_v.optTracers=s end)
	opts:Toggle("hm_toggle","Reticles",function(s)_hmEnabled=s;if not s then _updateHM()end end)
	local tps=tab:Section("Teleports","Right")
	tps:Text("tp to the nearest generator ¬_¬")
	tps:Button("Gen tp",function()_tpNearestGen()end)
	local tweaks=tab:Section("tweaks","Right")
	tweaks:Toggle("stam_lock","Stamina Lock",function(s)_v.sLock=s end)
	tweaks:SliderInt("stam_min","Stamina",0,100,30,function(v)_v.sMin=v end)
end)
local af=_gAF()
if af then
	_cv:OnChildAdded(af,function(c)if c:IsA("Model")and _v.pe then _sP(c)end end)
	_cv:OnChildRemoved(af,function(c)_cP(c)end)
end

local kf=_gKF()
if kf then
	_cv:OnChildAdded(kf,function(c)if c:IsA("Model")and _v.ke then _sK(c)end end)
end

local gf=_gGF()
if gf then
	_cv:OnChildAdded(gf,function(c)if _v.ge then _sG(c)end end)
	_cv:OnChildRemoved(gf,function(c)_cG(c)end)
end

local _batCol=Color3.fromRGB(240,240,80)
_bbnC(_rs.RenderStepped,function()
	_v.st=_v.st+1
	if _v.st%2==0 then pcall(function()if _p.Character then _v.mr=_p.Character:FindFirstChild("Torso")or _p.Character:FindFirstChild("HumanoidRootPart")end end)end
	if _v.st>=360 then
		_v.st=0
		if _v.pe then _qP()end
		if _v.ke then _qK()end
		if _v.ge then _qG()end
		_scanIgn()
	end
	if _v.st%3==0 then
		_v.dangerCol=nil
		if _v.mr and _v.mr.Position then
			local nd=math.huge
			for _,e in pairs(_v.kd)do if e.root and e.root.Position then local dd=(e.root.Position-_v.mr.Position).Magnitude;if dd<nd then nd=dd end end end
			for _,e in pairs(_v.td)do if e.root and e.root.Position then local dd=(e.root.Position-_v.mr.Position).Magnitude;if dd<nd then nd=dd end end end
			if nd<60 then local dp=(msin(os.clock()*5)+1)/2;_v.dangerCol=Color3.fromRGB(255,mfloor(dp*255),mfloor(dp*255))end
		end
	end
	_uE(_v.pd,_v.pe,_v.pc,_v.pb)
	_uE(_v.kd,_v.ke,_v.kc,_v.kb)
	_uE(_v.gd,_v.ge,_v.gc,_v.gc)
	local ps=(msin(os.clock()*4)+1)/2
	local tCol=Color3.fromRGB(mfloor(120+ps*135),mfloor(40+ps*110),mfloor(20+ps*20))
	local mv=mfloor(100+ps*155)
	local mCol=Color3.fromRGB(mv,mv,mv)
	_uO(_v.td,_v.te,tCol)
	_uO(_v.md,_v.te,mCol)
	_uO(_v.bd,_v.be,_batCol)
	_updateHM()
end)

_G._BBN_CLEANUP = function()
	for _,c in ipairs(_bbnConns) do pcall(function() c:Disconnect() end) end;_bbnConns={}
	if _cv then pcall(function() _cv:Destroy() end) end
	pcall(_xP); pcall(_xK); pcall(_xG); pcall(_xT); pcall(_xB)
	pcall(function() UI.RemoveTab("Bite By Night") end)
end
