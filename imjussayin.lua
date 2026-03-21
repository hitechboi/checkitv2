local UIS=game:GetService("UserInputService")
local _pl=game:GetService("Players")
local _lp=_pl.LocalPlayer
local _ms=_lp:GetMouse()
local _cm=workspace.CurrentCamera
local _sx,_sy=_cm.ViewportSize.X,_cm.ViewportSize.Y

local C={
	a=Color3.fromRGB(70,120,255),
	sb=Color3.fromRGB(12,15,27),
	ct=Color3.fromRGB(11,13,23),
	tb=Color3.fromRGB(7,9,17),
	bd=Color3.fromRGB(30,40,72),
	rb=Color3.fromRGB(14,18,33),
	ts=Color3.fromRGB(20,35,85),
	w=Color3.fromRGB(215,220,240),
	g=Color3.fromRGB(100,112,145),
	dg=Color3.fromRGB(28,33,52),
	on=Color3.fromRGB(45,85,195),
	of=Color3.fromRGB(20,24,42),
	od=Color3.fromRGB(175,198,255),
	fd=Color3.fromRGB(55,65,95),
	dv=Color3.fromRGB(22,27,48),
	mb=Color3.fromRGB(11,13,22),
}

local _thm={
	["check it"]={a=Color3.fromRGB(70,120,255),sb=Color3.fromRGB(12,15,27),ct=Color3.fromRGB(11,13,23),tb=Color3.fromRGB(7,9,17),bd=Color3.fromRGB(30,40,72),rb=Color3.fromRGB(14,18,33),ts=Color3.fromRGB(20,35,85),w=Color3.fromRGB(215,220,240),g=Color3.fromRGB(100,112,145),dg=Color3.fromRGB(28,33,52),on=Color3.fromRGB(45,85,195),of=Color3.fromRGB(20,24,42),od=Color3.fromRGB(175,198,255),fd=Color3.fromRGB(55,65,95),dv=Color3.fromRGB(22,27,48),mb=Color3.fromRGB(11,13,22)},
	moon={a=Color3.fromRGB(255,170,190),sb=Color3.fromRGB(35,35,40),ct=Color3.fromRGB(32,32,37),tb=Color3.fromRGB(28,28,33),bd=Color3.fromRGB(55,55,65),rb=Color3.fromRGB(38,38,44),ts=Color3.fromRGB(55,45,55),w=Color3.fromRGB(230,230,235),g=Color3.fromRGB(130,130,140),dg=Color3.fromRGB(45,45,52),on=Color3.fromRGB(180,120,140),of=Color3.fromRGB(38,38,44),od=Color3.fromRGB(255,200,215),fd=Color3.fromRGB(80,80,90),dv=Color3.fromRGB(48,48,55),mb=Color3.fromRGB(30,30,35)},
	confetti={a=Color3.fromRGB(255,210,60),sb=Color3.fromRGB(12,15,27),ct=Color3.fromRGB(11,13,23),tb=Color3.fromRGB(7,9,17),bd=Color3.fromRGB(30,40,72),rb=Color3.fromRGB(14,18,33),ts=Color3.fromRGB(40,35,15),w=Color3.fromRGB(215,220,240),g=Color3.fromRGB(100,112,145),dg=Color3.fromRGB(28,33,52),on=Color3.fromRGB(180,155,30),of=Color3.fromRGB(20,24,42),od=Color3.fromRGB(255,230,140),fd=Color3.fromRGB(55,65,95),dv=Color3.fromRGB(22,27,48),mb=Color3.fromRGB(11,13,22)},
}
local _thn={"check it","moon","confetti"}
local FNT=Drawing.Fonts.Monospace
pcall(function()FNT=Drawing.Fonts.System end)
local FNTB=FNT
pcall(function()FNTB=Drawing.Fonts.SystemBold end)
local FS=18
local FSS=16
local FSX=14
local CHW=7
local TH=32
local TAH=24
local RH=32
local SRH=56
local PAD=10
local CW=330
local WW=660

local objs,_tbo,_aco,_els,win={},{},{},{},{}
local _ldo={}
local _tpo={}
local _tps={visible=false,el=nil}
local _glo={}

local state={
	visible=true,dragging=false,
	dragox=0,dragoy=0,
	wx=math.floor(_sx/2-WW/2),
	wy=math.floor(_sy/2-180),
	wh=300,
	activeTab=nil,tabs={},
	menuKeyLabel="F1",
	menuVK=0x70,
	tCbs={},sCbs={},
	rebinding=false,rebindTarget=nil,
	built=false,
	loaderDone=false,
	destroyConfirm=false,destroyed=false,
	currentTheme="confetti",
	ddExpanded={},
	logScrollY=0,
}

local _avd=nil
task.spawn(function()
	pcall(function()
		local uname=_lp.Name
		local raw=game:HttpGet("https://api.luard.co/v1/user?v5="..uname.."&res=64")
		if raw and #raw>100 then
			_G.avatar_data=nil
			loadstring(raw)()
			if _G.avatar_data and _G.avatar_data.pixels and _G.avatar_data.width then
				_avd=_G.avatar_data
			end
		end
	end)
end)

local _vkn={}
do
	for i=0x41,0x5A do _vkn[i]=string.char(i) end
	_vkn[0x2D]="Insert" _vkn[0x23]="End"
	_vkn[0x70]="F1"  _vkn[0x71]="F2"  _vkn[0x72]="F3"  _vkn[0x73]="F4"
	_vkn[0x74]="F5"  _vkn[0x75]="F6"  _vkn[0x76]="F7"  _vkn[0x77]="F8"
	_vkn[0x78]="F9"  _vkn[0x79]="F10" _vkn[0x7A]="F11" _vkn[0x7B]="F12"
end
local function _vkn2(k) return _vkn[k] or ("Key"..k) end

local function _ath(name)
	local t=_thm[name]
	if not t then return end
	for k,v in pairs(t) do C[k]=v end
	state.currentTheme=name
end
_ath("confetti")

local function _clp(v,a,b)return math.max(a,math.min(b,v))end
local function _ins(x,y,rx,ry,rw,rh)return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh end
local function _trc(s,n)if #s>n then return s:sub(1,n-1).."~"end return s end

local function _nob(pool,typ,props)
	local o=Drawing.new(typ)
	for k,v in pairs(props)do o[k]=v end
	table.insert(pool,o)
	return o
end

local _v2=Vector2.new

local function _wsq(x,y,w,h,col,filled,zi)
	return _nob(objs,"Square",{Position=_v2(x,y),Size=_v2(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 1,Visible=state.visible})
end
local function _wln(x1,y1,x2,y2,col,thick,zi)
	return _nob(objs,"Line",{From=_v2(x1,y1),To=_v2(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})
end
local function _wtx(s,x,y,col,sz,ctr,zi)
	return _nob(objs,"Text",{Text=s,Position=_v2(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})
end
local function _wtb(s,x,y,col,sz,ctr,zi)
	return _nob(objs,"Text",{Text=s,Position=_v2(x,y),Color=col,Size=sz or FS,Font=FNTB,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})
end
local function _wci(x,y,r,col,filled,zi)
	return _nob(objs,"Circle",{Position=_v2(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=48,ZIndex=zi or 1,Visible=state.visible})
end
local function _tsq(x,y,w,h,col,filled,zi)
	return _nob(_aco,"Square",{Position=_v2(x,y),Size=_v2(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 3,Visible=state.visible})
end
local function _tln(x1,y1,x2,y2,col,thick,zi)
	return _nob(_aco,"Line",{From=_v2(x1,y1),To=_v2(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function _ttx(s,x,y,col,sz,ctr,zi)
	return _nob(_aco,"Text",{Text=s,Position=_v2(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end
local function _ttb(s,x,y,col,sz,ctr,zi)
	return _nob(_aco,"Text",{Text=s,Position=_v2(x,y),Color=col,Size=sz or FS,Font=FNTB,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end
local function _tci(x,y,r,col,filled,zi)
	return _nob(_aco,"Circle",{Position=_v2(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=48,ZIndex=zi or 3,Visible=state.visible})
end
local function _tbsq(x,y,w,h,col,filled,zi)
	return _nob(_tbo,"Square",{Position=_v2(x,y),Size=_v2(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 3,Visible=state.visible})
end
local function _tbln(x1,y1,x2,y2,col,thick,zi)
	return _nob(_tbo,"Line",{From=_v2(x1,y1),To=_v2(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function _tbtx(s,x,y,col,sz,ctr,zi)
	return _nob(_tbo,"Text",{Text=s,Position=_v2(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end
local function _tbtb(s,x,y,col,sz,ctr,zi)
	return _nob(_tbo,"Text",{Text=s,Position=_v2(x,y),Color=col,Size=sz or FS,Font=FNTB,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end
local function _tbci(x,y,r,col,filled,zi)
	return _nob(_tbo,"Circle",{Position=_v2(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=48,ZIndex=zi or 3,Visible=state.visible})
end

local function _lob(typ,props)
	local o=Drawing.new(typ)
	for k,v in pairs(props)do o[k]=v end
	table.insert(_ldo,o)
	return o
end

local function _shl()
	local scx=math.floor(_sx/2)
	local scy=math.floor(_sy/2)
	local LW,LH=280,90
	local r=8
	local function layoutPill(cw,ch,bgS1,bgS2,bgC1,bgC2,bgC3,bgC4,brdL1,brdL2,brdL3,brdL4)
		local cx=scx-math.floor(cw/2)
		local cy2=scy-math.floor(ch/2)
		local cr=math.min(r,math.floor(math.min(cw,ch)/2))
		pcall(function()bgS1.Position=_v2(cx+cr,cy2);bgS1.Size=_v2(math.max(0,cw-cr*2),ch)end)
		pcall(function()bgS2.Position=_v2(cx,cy2+cr);bgS2.Size=_v2(cw,math.max(0,ch-cr*2))end)
		pcall(function()bgC1.Position=_v2(cx+cr,cy2+cr);bgC1.Radius=cr end)
		pcall(function()bgC2.Position=_v2(cx+cw-cr,cy2+cr);bgC2.Radius=cr end)
		pcall(function()bgC3.Position=_v2(cx+cr,cy2+ch-cr);bgC3.Radius=cr end)
		pcall(function()bgC4.Position=_v2(cx+cw-cr,cy2+ch-cr);bgC4.Radius=cr end)
		pcall(function()brdL1.From=_v2(cx+cr,cy2);brdL1.To=_v2(cx+cw-cr,cy2)end)
		pcall(function()brdL2.From=_v2(cx+cr,cy2+ch);brdL2.To=_v2(cx+cw-cr,cy2+ch)end)
		pcall(function()brdL3.From=_v2(cx,cy2+cr);brdL3.To=_v2(cx,cy2+ch-cr)end)
		pcall(function()brdL4.From=_v2(cx+cw,cy2+cr);brdL4.To=_v2(cx+cw,cy2+ch-cr)end)
	end
	local bgS1=_lob("Square",{Position=_v2(scx,scy),Size=_v2(0,0),Color=C.tb,Filled=true,Transparency=1,ZIndex=50,Visible=true})
	local bgS2=_lob("Square",{Position=_v2(scx,scy),Size=_v2(0,0),Color=C.tb,Filled=true,Transparency=1,ZIndex=50,Visible=true})
	local bgC1=_lob("Circle",{Position=_v2(scx,scy),Radius=1,Color=C.tb,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	local bgC2=_lob("Circle",{Position=_v2(scx,scy),Radius=1,Color=C.tb,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	local bgC3=_lob("Circle",{Position=_v2(scx,scy),Radius=1,Color=C.tb,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	local bgC4=_lob("Circle",{Position=_v2(scx,scy),Radius=1,Color=C.tb,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	local brdL1=_lob("Line",{From=_v2(scx,scy),To=_v2(scx,scy),Color=C.bd,Thickness=1,Transparency=1,ZIndex=51,Visible=true})
	local brdL2=_lob("Line",{From=_v2(scx,scy),To=_v2(scx,scy),Color=C.bd,Thickness=1,Transparency=1,ZIndex=51,Visible=true})
	local brdL3=_lob("Line",{From=_v2(scx,scy),To=_v2(scx,scy),Color=C.bd,Thickness=1,Transparency=1,ZIndex=51,Visible=true})
	local brdL4=_lob("Line",{From=_v2(scx,scy),To=_v2(scx,scy),Color=C.bd,Thickness=1,Transparency=1,ZIndex=51,Visible=true})
	local lx=scx-math.floor(LW/2)
	local ly=scy-math.floor(LH/2)
	local slideOff=12
	local parts={
		{txt="Check", col=C.w,  sz=22, bx=scx-56, by=scy-16, delay=0},
		{txt=".",     col=C.bd, sz=16, bx=scx+2,  by=scy-16, delay=0.06},
		{txt="It",    col=C.a, sz=22, bx=scx+12, by=scy-16, delay=0.12},
		{txt=".",     col=C.bd, sz=16, bx=scx+34, by=scy-16, delay=0.18},
		{txt="v2",    col=C.g,   sz=12, bx=scx+46, by=scy-10, delay=0.24},
	}
	local textObjs={}
	for _,p in ipairs(parts)do
		local o=_lob("Text",{Text=p.txt,Position=_v2(p.bx,p.by+slideOff),Color=p.col,Size=p.sz,Font=FNTB,Center=false,Outline=false,Transparency=0,ZIndex=52,Visible=true})
		table.insert(textObjs,{obj=o,bx=p.bx,by=p.by,delay=p.delay})
	end
	local barW=180
	local barX=scx-barW/2
	local barY=scy+18
	local barBg=_lob("Square",{Position=_v2(barX,barY),Size=_v2(barW,2),Color=C.dg,Filled=true,Transparency=0,ZIndex=52,Visible=true})
	local barFill=_lob("Square",{Position=_v2(barX,barY),Size=_v2(0,2),Color=C.a,Filled=true,Transparency=0,ZIndex=53,Visible=true})
	local statusTx=_lob("Text",{Text="initializing modules_",Position=_v2(scx,scy+30),Color=C.g,Size=11,Font=FNT,Center=true,Outline=false,Transparency=0,ZIndex=52,Visible=true})
	pcall(function()
		local scaleDur=0.4
		local s0=tick()
		while tick()-s0<scaleDur do
			local p=_clp((tick()-s0)/scaleDur,0,1)
			local ep=1-(1-p)*(1-p)*(1-p)
			local cw=math.floor(LW*ep)
			local ch=math.floor(LH*ep)
			layoutPill(math.max(2,cw),math.max(2,ch),bgS1,bgS2,bgC1,bgC2,bgC3,bgC4,brdL1,brdL2,brdL3,brdL4)
			task.wait(0.016)
		end
		layoutPill(LW,LH,bgS1,bgS2,bgC1,bgC2,bgC3,bgC4,brdL1,brdL2,brdL3,brdL4)
		local t0=tick()
		local slideDur=0.3
		local totalTextDur=slideDur+0.24
		while tick()-t0<totalTextDur+slideDur do
			local elapsed=tick()-t0
			for _,te in ipairs(textObjs)do
				local t=elapsed-te.delay
				if t<0 then
					pcall(function()te.obj.Transparency=0 end)
				elseif t<slideDur then
					local p2=_clp(t/slideDur,0,1)
					local ep=1-(1-p2)*(1-p2)*(1-p2)
					local yOff=math.floor(slideOff*(1-ep))
					pcall(function()te.obj.Position=_v2(te.bx,te.by+yOff)end)
					pcall(function()te.obj.Transparency=ep end)
				else
					pcall(function()te.obj.Position=_v2(te.bx,te.by)end)
					pcall(function()te.obj.Transparency=1 end)
				end
			end
			task.wait(0.016)
		end
		for _,te in ipairs(textObjs)do
			pcall(function()te.obj.Position=_v2(te.bx,te.by)end)
			pcall(function()te.obj.Transparency=1 end)
		end
		local barStart=tick()
		local barDur=1.2
		local blink=true
		pcall(function()barFill.Transparency=1 end)
		pcall(function()barBg.Transparency=1 end)
		pcall(function()statusTx.Transparency=1 end)
		while tick()-barStart<barDur do
			local pct=_clp((tick()-barStart)/barDur,0,1)
			local ep=pct<0.3 and pct/0.3*0.45 or pct<0.6 and 0.45+(pct-0.3)/0.3*0.27 or pct<0.85 and 0.72+(pct-0.6)/0.25*0.18 or 0.9+(pct-0.85)/0.15*0.1
			pcall(function()barFill.Size=_v2(math.floor(barW*ep),2)end)
			local nb=math.floor((tick()-barStart)/0.5)%2==0
			if nb~=blink then
				blink=nb
				pcall(function()statusTx.Text=blink and "initializing modules_" or "initializing modules "end)
			end
			task.wait(0.016)
		end
		pcall(function()barFill.Size=_v2(barW,2)end)
		task.wait(0.25)
		for i=10,0,-1 do
			local a=i/10
			for _,o in ipairs(_ldo)do pcall(function()o.Transparency=a end)end
			task.wait(0.025)
		end
	end)
	for _,o in ipairs(_ldo)do pcall(function()o:Remove()end)end
	table.clear(_ldo)
	state.loaderDone=true
end

local function _hdl()
	for _,o in ipairs(_ldo)do pcall(function()o:Remove()end)end
	table.clear(_ldo)
	state.loaderDone=false
end

local _cfo={}
local _cfa=false
local _ccl={
	Color3.fromRGB(255,220,60),Color3.fromRGB(100,180,255),
	Color3.fromRGB(255,180,40),Color3.fromRGB(80,160,255),
	Color3.fromRGB(255,240,120),Color3.fromRGB(60,120,220),
}

local function _scf()
	if _cfa then return end
	_cfa=true
	task.spawn(function()
		local particles={}
		while _cfa and state.currentTheme=="confetti" do
			if #particles<40 then
				local px=state.wx+math.random(0,WW)
				local py=state.wy-math.random(5,15)
				local col=_ccl[math.random(1,#_ccl)]
				local sz=math.random(2,5)
				local o=Drawing.new("Square")
				o.Position=_v2(px,py)
				o.Size=_v2(sz,sz)
				o.Color=col
				o.Filled=true
				o.Transparency=1
				o.ZIndex=1
				o.Visible=state.visible
				table.insert(_cfo,o)
				table.insert(particles,{obj=o,x=px,y=py,vx=(math.random()-0.5)*1.5,vy=math.random()*1.5+0.5,life=0,maxLife=math.random(40,90)})
			end
			local i=1
			while i<=#particles do
				local p=particles[i]
				p.life=p.life+1
				p.x=p.x+p.vx
				p.y=p.y+p.vy
				local alpha=1-p.life/p.maxLife
				if alpha<=0 or p.life>=p.maxLife then
					pcall(function()p.obj:Remove()end)
					for j,co in ipairs(_cfo)do
						if co==p.obj then table.remove(_cfo,j);break end
					end
					table.remove(particles,i)
				else
					pcall(function()
						p.obj.Position=_v2(p.x,p.y)
						p.obj.Transparency=alpha
						p.obj.Visible=state.visible
					end)
					i=i+1
				end
			end
			task.wait(0.03)
		end
		for _,p in ipairs(particles)do pcall(function()p.obj:Remove()end)end
		for _,o in ipairs(_cfo)do pcall(function()o:Remove()end)end
		table.clear(_cfo)
		_cfa=false
	end)
end

local function _stcf()
	_cfa=false
end

local function _scc(mx,my)
	if state.currentTheme~="confetti" then return end
	task.spawn(function()
		local parts={}
		for _=1,12 do
			local col=_ccl[math.random(1,#_ccl)]
			local sz=math.random(2,4)
			local ang=math.random()*math.pi*2
			local spd=math.random()*3+1.5
			local o=Drawing.new("Square")
			o.Position=_v2(mx,my);o.Size=_v2(sz,sz);o.Color=col
			o.Filled=true;o.Transparency=1;o.ZIndex=60;o.Visible=true
			table.insert(parts,{obj=o,x=mx,y=my,vx=math.cos(ang)*spd,vy=math.sin(ang)*spd-1,life=0,maxLife=math.random(20,40)})
		end
		while #parts>0 do
			local i=1
			while i<=#parts do
				local p=parts[i]
				p.life=p.life+1;p.x=p.x+p.vx;p.y=p.y+p.vy;p.vy=p.vy+0.08
				local alpha=1-p.life/p.maxLife
				if alpha<=0 then
					pcall(function()p.obj:Remove()end)
					table.remove(parts,i)
				else
					pcall(function()p.obj.Position=_v2(p.x,p.y);p.obj.Transparency=alpha end)
					i=i+1
				end
			end
			task.wait(0.016)
		end
	end)
end

local _origApplyTheme=_ath
_ath=function(name)
	_origApplyTheme(name)
	if name=="confetti" then _scf()
	else _stcf() end
end

local function _dpf(sqFn,ciFn,x,y,w,h,col,zi,cr)
	local r=cr or 8
	sqFn(x+r,y,w-r*2,h,col,true,zi)
	sqFn(x,y+r,w,h-r*2,col,true,zi)
	ciFn(x+r,y+r,r,col,true,zi)
	ciFn(x+w-r,y+r,r,col,true,zi)
	ciFn(x+r,y+h-r,r,col,true,zi)
	ciFn(x+w-r,y+h-r,r,col,true,zi)
end

local function _dpb(lnFn,x,y,w,h,col,zi,cr)
	local r=cr or 8
	lnFn(x+r,y,x+w-r,y,col,1,zi)
	lnFn(x+r,y+h,x+w-r,y+h,col,1,zi)
	lnFn(x,y+r,x,y+h-r,col,1,zi)
	lnFn(x+w,y+r,x+w,y+h-r,col,1,zi)
	local seg=6
	local pi2=math.pi/2
	local corners={
		{cx=x+r,  cy=y+r,  a0=math.pi,   a1=math.pi+pi2},
		{cx=x+w-r,cy=y+r,  a0=math.pi+pi2,a1=math.pi*2},
		{cx=x+w-r,cy=y+h-r,a0=0,          a1=pi2},
		{cx=x+r,  cy=y+h-r,a0=pi2,        a1=math.pi},
	}
	for _,c in ipairs(corners)do
		for s=0,seg-1 do
			local t0=c.a0+(c.a1-c.a0)*s/seg
			local t1=c.a0+(c.a1-c.a0)*(s+1)/seg
			lnFn(c.cx+math.cos(t0)*r,c.cy+math.sin(t0)*r,c.cx+math.cos(t1)*r,c.cy+math.sin(t1)*r,col,1,zi)
		end
	end
end

local function _wpf(x,y,w,h,col,zi)_dpf(_wsq,_wci,x,y,w,h,col,zi)end
local function _wpb(x,y,w,h,col,zi)_dpb(_wln,x,y,w,h,col,zi)end
local function _tpf(x,y,w,h,col,zi,cr)_dpf(_tsq,_tci,x,y,w,h,col,zi,cr)end
local function _tpb(x,y,w,h,col,zi,cr)_dpb(_tln,x,y,w,h,col,zi,cr)end
local function _tbpf(x,y,w,h,col,zi,cr)_dpf(_tbsq,_tbci,x,y,w,h,col,zi,cr)end

local function _pil(x,y,w,h,zi,cr)
	_tpf(x,y,w,h,C.ct,zi or 3,cr)
	_tpb(x,y,w,h,C.bd,(zi or 3)+1,cr)
end

local function _rbg(x,y,w,h,col,zi,isFirst,isLast)
	local r=8
	if isFirst and isLast then
		_tsq(x+r,y,w-r*2,h,col,true,zi);_tsq(x,y+r,w,h-r*2,col,true,zi)
		_tci(x+r,y+r,r,col,true,zi);_tci(x+w-r,y+r,r,col,true,zi)
		_tci(x+r,y+h-r,r,col,true,zi);_tci(x+w-r,y+h-r,r,col,true,zi)
	elseif isFirst then
		_tsq(x+r,y,w-r*2,h,col,true,zi);_tsq(x,y+r,w,h-r,col,true,zi)
		_tci(x+r,y+r,r,col,true,zi);_tci(x+w-r,y+r,r,col,true,zi)
	elseif isLast then
		_tsq(x+r,y,w-r*2,h,col,true,zi);_tsq(x,y,w,h-r,col,true,zi)
		_tci(x+r,y+h-r,r,col,true,zi);_tci(x+w-r,y+h-r,r,col,true,zi)
	else
		_tsq(x,y,w,h,col,true,zi)
	end
end
local function _dvl(x,y,w,zi)_tln(x+8,y,x+w-8,y,C.dv,1,zi or 5)end
local function _slb(x,y,w,txt,zi)
	_ttb(txt,x+PAD,y+5,C.g,FSX,false,zi or 5)
	_tln(x+8,y+18,x+w-8,y+18,C.dv,1,(zi or 5)-1)
end

local function _tgd(x,y,on,zi)
	local z=zi or 6
	local col=on and C.on or C.of
	local r=8
	local bg1=_tsq(x+r,y,32-r*2,16,col,true,z)
	local bg2=_tsq(x,y+r,32,16-r*2,col,true,z)
	local c1=_tci(x+r,y+r,r,col,true,z)
	local c2=_tci(x+32-r,y+r,r,col,true,z)
	local c3=_tci(x+r,y+16-r,r,col,true,z)
	local c4=_tci(x+32-r,y+16-r,r,col,true,z)
	local dot=_tci(x+(on and 24 or 8),y+8,6,on and C.od or C.fd,true,z+2)
	return bg1,bg2,dot,c1,c2,c3,c4
end

local function _sld(x,y,w,val,mn,mx,zi)
	local z=zi or 6
	local pct=_clp((val-mn)/(mx-mn),0,1)
	local fw=math.max(2,math.floor(w*pct))
	_tsq(x,y,w,3,C.dg,true,z)
	local fill=_tsq(x,y,fw,3,C.a,true,z+1)
	local knob=_tci(x+fw,y+1,5,C.od,true,z+2)
	return fill,knob
end

local DDH=28
local DTH=32
local PTH=32

local function _ith(it)
	if it.type=="slider" then return SRH
	elseif it.type=="dropdown" then
		if state.ddExpanded[it.id] then
			return DDH*(1+#(it.options or{}))
		end
		return DDH
	elseif it.type=="button" then return RH
	elseif it.type=="debug" then return DTH
	elseif it.type=="profiletag" then return PTH
	else return RH end
end

local function _gri(items)
	local groups={}
	local i=1
	while i<=#items do
		local it=items[i]
		if it.type=="section" or it.type=="debug" then
			table.insert(groups,{it})
			i=i+1
		elseif it.type=="dropdown" then
			table.insert(groups,{it})
			i=i+1
		elseif it.type=="slider" then
			table.insert(groups,{it})
			i=i+1
		elseif it.type=="toggle" then
			if i+1<=#items and items[i+1].type=="slider" then
				table.insert(groups,{items[i],items[i+1]})
				i=i+2
			else
				local grp={items[i]}
				i=i+1
				while i<=#items and items[i].type=="toggle" do
					if i+1<=#items and items[i+1].type=="slider" then break end
					table.insert(grp,items[i])
					i=i+1
				end
				table.insert(groups,grp)
			end
		elseif it.type=="button" then
			local grp={items[i]}
			i=i+1
			while i<=#items and items[i].type=="button" do
				table.insert(grp,items[i])
				i=i+1
			end
			table.insert(groups,grp)
		else
			i=i+1
		end
	end
	return groups
end

local function _cwh()
	local maxH=0
	for _,tab in ipairs(state.tabs)do
		local left,right={},{}
		for _,it in ipairs(tab.items or{})do
			if it.col==2 then table.insert(right,it)
			else table.insert(left,it)end
		end
		local function colH(citems)
			local h=0
			for _,grp in ipairs(_gri(citems))do
				local f=grp[1]
				if f.type=="section" then h=h+22
				elseif f.type=="debug" then h=h+DTH
				else
					local ph=0
					for _,it in ipairs(grp)do ph=ph+_ith(it)end
					h=h+ph+8
				end
			end
			return h
		end
		local h=math.max(colH(left),colH(right))+16
		if h>maxH then maxH=h end
	end
	local raw=math.max(200,maxH)+TH+TAH+10
	local maxScreen=math.floor(_sy*0.6)
	return math.min(raw,maxScreen)
end

local function _bwn()
	for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
	table.clear(objs)
	local wx,wy=state.wx,state.wy
	local wh=_cwh()
	state.wh=wh
	_wpf(wx,wy,WW,wh,C.sb,1)
	_wpb(wx,wy,WW,wh,C.bd,2)
	local tr=8
	_wsq(wx+tr,wy,WW-tr*2,TH,C.tb,true,2)
	_wsq(wx,wy+tr,WW,TH-tr,C.tb,true,2)
	_wci(wx+tr,wy+tr,tr,C.tb,true,2)
	_wci(wx+WW-tr,wy+tr,tr,C.tb,true,2)
	win.tLine=_wln(wx,wy+TH,wx+WW,wy+TH,C.bd,1,3)
	win.t1=_wtb("Check",wx+PAD+2,wy+9,C.w,FS,false,4)
	win.t2=_wtx("·",wx+PAD+64,wy+9,C.bd,FS,false,4)
	win.t3=_wtb("It",wx+PAD+76,wy+9,C.a,FS,false,4)
	win.t4=_wtx("·",wx+PAD+96,wy+9,C.bd,FS,false,4)
	win.t5=_wtx("v2",wx+PAD+108,wy+12,C.g,FSS,false,4)
	win.kLbl=_wtx("menu key",wx+WW-140,wy+11,C.g,FSX,false,4)
	local kbx=wx+WW-72
	local kby=wy+9
	local kbw=66
	local kbh=18
	local kr=5
	_wsq(kbx+kr,kby,kbw-kr*2,kbh,C.dg,true,3)
	_wsq(kbx,kby+kr,kbw,kbh-kr*2,C.dg,true,3)
	_wci(kbx+kr,kby+kr,kr,C.dg,true,3)
	_wci(kbx+kbw-kr,kby+kr,kr,C.dg,true,3)
	_wci(kbx+kr,kby+kbh-kr,kr,C.dg,true,3)
	_wci(kbx+kbw-kr,kby+kbh-kr,kr,C.dg,true,3)
	win.kTx=_wtb(state.menuKeyLabel,kbx+kbw/2,wy+16,C.od,FSX,true,5)
	win.tabBg=_wsq(wx,wy+TH,WW,TAH,C.tb,true,2)
	win.tabLn=_wln(wx,wy+TH+TAH,wx+WW,wy+TH+TAH,C.bd,1,3)
	win.colDiv=_wln(wx+CW,wy+TH+TAH,wx+CW,wy+wh-8,C.bd,1,2)
	state.built=true
	if not state._titleAnim then
		state._titleAnim=true
		task.spawn(function()
			local wave=1.8
			local speed=4.5
			local glowSpeed=2.0
			while state._titleAnim do
				if state.visible and state.built then
					local t=tick()
					local titles={win.t1,win.t2,win.t3,win.t4,win.t5}
					local baseY=state.wy+7
					local baseY5=state.wy+10
					for i,obj in ipairs(titles)do
						if obj then
							local phase=(i-1)*0.45
							local yOff=math.sin(t*speed+phase)*wave
							local by=i==5 and baseY5 or baseY
							pcall(function()obj.Position=_v2(obj.Position.X,by+yOff)end)
						end
					end
					if win.t3 then
						local g=(math.sin(t*glowSpeed)+1)/2
						local wr,wg2,wb=215/255,220/255,240/255
						local ar,ag,ab=C.a.R,C.a.G,C.a.B
						local cr=wr+(ar-wr)*g
						local cg=wg2+(ag-wg2)*g
						local cb=wb+(ab-wb)*g
						pcall(function()win.t3.Color=Color3.new(cr,cg,cb)end)
					end
				end
				task.wait(0.016)
			end
		end)
	end
end

local function _svs(v)
	local all={}
	for _,o in ipairs(objs)do table.insert(all,o)end
	for _,o in ipairs(_tbo)do if o.Remove then table.insert(all,o)end end
	for _,o in ipairs(_aco)do table.insert(all,o)end
	if v then
		for _,o in ipairs(all)do pcall(function()o.Visible=true;o.Transparency=0 end)end
		for i=1,10 do
			local a=i/10
			for _,o in ipairs(all)do pcall(function()o.Transparency=a end)end
			task.wait(0.016)
		end
	else
		for i=9,0,-1 do
			local a=i/10
			for _,o in ipairs(all)do pcall(function()o.Transparency=a end)end
			task.wait(0.016)
		end
		for _,o in ipairs(all)do pcall(function()o.Visible=false end)end
	end
end

local function _cla()
	for _,o in ipairs(_tpo)do pcall(function()o:Remove()end)end
	table.clear(_tpo)
	_tps.visible=false;_tps.el=nil;_tps.fade=nil
	for _,o in ipairs(_glo)do pcall(function()o:Remove()end)end
	table.clear(_glo)
	for _,o in ipairs(_aco)do pcall(function()o:Remove()end)end
	table.clear(_aco)
	table.clear(_els)
end

local function _ctb()
	for _,o in ipairs(_tbo)do pcall(function()if o.Remove then o:Remove()end end)end
	table.clear(_tbo)
end

local function _bts()
	_ctb()
	if not state.built then return end
	local wx,wy=state.wx,state.wy
	local ty=wy+TH+2
	local names={}
	for _,t in ipairs(state.tabs)do table.insert(names,t.name)end
	local sysTabs={"info","updatelogs","settings"}
	for _,sn in ipairs(sysTabs)do table.insert(names,sn)end
	local n=#names
	local availW=WW-PAD*2
	local gap=2
	local totalGap=gap*(n-1)
	local tw=math.floor((availW-totalGap)/n)
	local leftover=availW-totalGap-tw*n
	local tx=wx+PAD
	for i,name in ipairs(names)do
		local ew=tw+(i<=leftover and 1 or 0)
		local isA=state.activeTab and state.activeTab.name==name
		_tbpf(tx,ty,ew,TAH-2,isA and C.ts or C.tb,3,6)
		if isA then _tbln(tx+6,ty+TAH-2,tx+ew-6,ty+TAH-2,C.a,2,4)end
		_tbtb(name,tx+ew/2,ty+8,isA and C.w or C.g,FSX,true,5)
		table.insert(_tbo,{_c={x=tx,y=ty,w=ew,h=TAH-2,name=name}})
		tx=tx+ew+gap
	end
end

local function _rse()
	local wx,wy=state.wx,state.wy
	local cy=wy+TH+TAH+8
	local sx=wx+PAD
	local sw=WW-PAD*2
	_slb(sx,cy,sw,"keybinds",5)
	local ky=cy+24
	_pil(sx,ky,sw,48,4)
	_ttb("menu key",sx+PAD+4,ky+17,C.w,FSX,false,6)
	local kbx=sx+sw-142
	_tpf(kbx,ky+12,68,24,C.dg,6,5)
	_tpb(kbx,ky+12,68,24,C.bd,7,5)
	local kbt=_ttb(state.menuKeyLabel,kbx+34,ky+22,C.od,FSX,true,8)
	local rbx=kbx+74
	_tpf(rbx,ky+12,52,24,C.dg,6,5)
	_tpb(rbx,ky+12,52,24,C.bd,7,5)
	local rbt=_ttb("rebind",rbx+26,ky+21,C.g,FSX,true,8)
	table.insert(_els,{type="rebind",x=rbx,y=ky+12,w=52,h=24,kd=kbt,rt=rbt})
	local qrx=sx+PAD+4+#"menu key"*CHW+8
	_tci(qrx+6,ky+25,7,C.bd,false,8)
	_ttx("?",qrx+2,ky+18,C.g,11,false,9)
	table.insert(_els,{type="hoverTip",x=qrx-2,y=ky+15,w=16,h=20,desc="rebinds the menu key"})
	_ttx("letters, Insert, End, or F1-F12 to rebind",sx+PAD,ky+50,C.g,11,false,5)
	local ty=ky+70
	_slb(sx,ty,sw,"themes",5)
	local tpy=ty+24
	local thH=DDH*#_thn+6
	_pil(sx,tpy,sw,thH,4)
	local tiy=tpy+3
	local thOptEls={}
	for ti,tn in ipairs(_thn)do
		local isSel=(tn==state.currentTheme)
		if isSel then
			_tpf(sx+6,tiy+2,sw-12,DDH-4,C.ts,5,6)
		end
		if ti<#_thn then _dvl(sx+4,tiy+DDH,sw-8,6)end
		local swCol=_thm[tn] and _thm[tn].a or C.a
		_tci(sx+PAD+12,tiy+DDH/2,5,swCol,true,7)
		local ttx=_ttb(tn,sx+PAD+26,tiy+7,isSel and C.od or C.g,FSX,false,7)
		if isSel then _ttx("active",sx+sw-62,tiy+7,C.a,FSX,false,7)end
		table.insert(thOptEls,{tx=ttx,name=tn,x=sx+4,y=tiy,w=sw-8,h=DDH})
		tiy=tiy+DDH
	end
	table.insert(_els,{type="theme",optEls=thOptEls,x=sx,y=tpy,w=sw,h=thH})
	local dy=tpy+thH+10
	_slb(sx,dy,sw,"danger zone",5)
	local dby=dy+24
	_pil(sx,dby,sw,46,4)
	_ttb("destroy menu",sx+PAD+4,dby+12,C.w,FSX,false,6)
	_ttx("unloads the menu permanently",sx+PAD+4,dby+27,C.g,11,false,6)
	_tpf(sx+sw-76,dby+10,68,26,Color3.fromRGB(40,10,10),6,5)
	_tpb(sx+sw-76,dby+10,68,26,Color3.fromRGB(72,22,22),7,5)
	local dtxt=_ttb("destroy",sx+sw-42,dby+21,Color3.fromRGB(220,80,80),FSX,true,8)
	table.insert(_els,{type="destroy",x=sx+sw-76,y=dby+10,w=68,h=26,txt=dtxt})
end

local _ulg={
	{category="UI Updates",logs={
		{ver="v2.0",date="2026-03-18",entries={
			"new Drawing-based overlay UI library",
			"System/SystemBold font, bigger text",
			"loading screen scale-up animation",
			"title worm wave + It glow effect",
			"theme switcher (check it/moon/confetti)",
			"rounded pill sections with dividers",
			"smooth slide dropdown animations",
			"directional fade-swipe tab switching",
			"fade in/out menu animation",
			"scrollbar with click-and-hold",
			"heartbeat pulsing session dot",
			"hover tooltips with ? icons",
		}},
		{ver="v1.0",date="2026-03-10",entries={
			"initial UI release",
			"basic toggle/slider/dropdown controls",
			"two-column layout",
			"keybind system",
		}},
	}},
	{category="Main Script Updates",logs={
	}},
}

local function _lth()
	local h=0
	for _,cat in ipairs(_ulg)do
		h=h+26
		for _,log in ipairs(cat.logs)do
			h=h+24+#log.entries*22+8+10
		end
		if #cat.logs==0 then h=h+30 end
	end
	return h
end

local function _rul()
	local wx,wy=state.wx,state.wy
	local visTop=wy+TH+TAH
	local visBot=wy+state.wh-8
	local visH=visBot-visTop
	local cy=wy+TH+TAH+8
	local sx=wx+PAD
	local sbW=14
	local sw=WW-PAD*2-sbW
	local totalH=_lth()
	local maxScroll=math.max(0,totalH-visH+16)
	state.logScrollY=_clp(state.logScrollY,0,maxScroll)
	local iy=cy-state.logScrollY
	for _,cat in ipairs(_ulg)do
		if iy+20>visTop and iy<visBot then
			_ttb(cat.category,sx+PAD,iy+4,C.a,FSX,false,6)
			_tln(sx,iy+22,sx+sw,iy+22,C.bd,1,5)
		end
		iy=iy+26
		if #cat.logs==0 then
			if iy+24>visTop and iy<visBot then
				_ttx("no entries yet",sx+PAD+4,iy+6,C.g,FSX,false,5)
			end
			iy=iy+30
		end
		for _,log in ipairs(cat.logs)do
			local entryH=#log.entries*22+8
			local blockH=24+entryH+10
			local blockBot=iy+blockH
			if blockBot>visTop and iy<visBot then
				if iy+18>visTop and iy<visBot then
					_slb(sx,iy,sw,log.ver.."  "..log.date,5)
				end
				local pillY=iy+24
				if pillY+entryH>visTop and pillY<visBot then
					local clpY=math.max(pillY,visTop)
					local clpB=math.min(pillY+entryH,visBot)
					local clpH=clpB-clpY
					if clpH>0 then
						_tpf(sx,clpY,sw,clpH,C.ct,4)
						_tpb(sx,clpY,sw,clpH,C.bd,6)
					end
					local ey=pillY+4
					for ei,entry in ipairs(log.entries)do
						if ey+22>visTop and ey<visBot then
							_ttx("-  "..entry,sx+PAD+4,ey+4,C.g,FSX,false,7)
							if ei<#log.entries then _tln(sx+8,ey+22,sx+sw-8,ey+22,C.dv,1,5)end
						end
						ey=ey+22
					end
				end
			end
			iy=iy+blockH
		end
	end
	if totalH>visH then
		local sbx=wx+WW-PAD-8
		local sby=visTop+4
		local sbh=visH-8
		_ttb("^",sbx+1,sby+1,C.g,11,false,9)
		table.insert(_els,{type="logScrollBtn",dir=-1,x=sbx-2,y=sby,w=12,h=14,maxScroll=maxScroll,step=50})
		_ttb("v",sbx+1,sby+sbh-13,C.g,11,false,9)
		table.insert(_els,{type="logScrollBtn",dir=1,x=sbx-2,y=sby+sbh-14,w=12,h=14,maxScroll=maxScroll,step=50})
		local trackTop=sby+16
		local trackH=sbh-32
		_tsq(sbx+2,trackTop,2,trackH,C.dg,true,8)
		local thumbH=math.max(16,math.floor(trackH*visH/totalH))
		local scrollPct=maxScroll>0 and state.logScrollY/maxScroll or 0
		local thumbY=trackTop+math.floor((trackH-thumbH)*scrollPct)
		_tpf(sbx,thumbY,6,thumbH,C.a,9,3)
		table.insert(_els,{type="logScrollTrack",x=sbx-2,y=trackTop,w=10,h=trackH,trackTop=trackTop,trackH=trackH,thumbH=thumbH,maxScroll=maxScroll})
	end
end

local function _rcl(colX,colW,items,startY)
	local cur=startY
	local innerW=colW-PAD*2
	local maxChars=math.floor((innerW-PAD*2-50)/CHW)
	local px=colX+PAD
	local pw=innerW

	local function _dit(pitems,iy)
		local n=#pitems
		for idx,it in ipairs(pitems)do
			local isFirst=(idx==1)
			local isLast=(idx==n)
			if it.type=="toggle"then
				_rbg(px,iy,pw,RH,C.rb,5,isFirst,isLast)
				if not isLast then _dvl(px,iy+RH,pw,6) end
				_ttb(_trc(it.label,maxChars),px+PAD+4,iy+9,C.w,FSX,false,7)
				if it.rowvalue then
					_ttx(it.rowvalue,px+pw-56,iy+10,C.g,FSX,false,7)
				end
				local bg1,bg2,dot,c1,c2,c3,c4=_tgd(px+pw-42,iy+8,it.value,7)
				table.insert(_els,{
					type="toggle",x=px+pw-42,y=iy+8,w=32,h=16,
					bg1=bg1,bg2=bg2,dot=dot,c1=c1,c2=c2,c3=c3,c4=c4,on=it.value,id=it.id,label=it.label
				})
				if it.desc then
					local qx=px+pw-58
					_tci(qx+6,iy+16,7,C.bd,false,8)
					_ttx("?",qx+2,iy+9,C.g,11,false,9)
					table.insert(_els,{type="hoverTip",x=qx-2,y=iy+6,w=16,h=20,desc=it.desc})
				end
				if it.callback then state.tCbs[it.id]=it.callback end
				iy=iy+RH
			elseif it.type=="slider"then
				_rbg(px,iy,pw,SRH,C.mb,5,isFirst,isLast)
				if not isLast then _dvl(px,iy+SRH,pw,6) end
				local slx=px+PAD+4
				local slw=pw-PAD*2-8
				_ttb(_trc(it.label,math.floor(maxChars*0.5)),slx,iy+8,C.g,FSX,false,7)
				if it.desc then
					_ttx(it.desc,slx,iy+22,C.g,10,false,7)
				end
				local vstr=tostring(math.floor(it.value*10+0.5)/10)..(it.suffix)
				local vw=#vstr*CHW
				local vtx=_ttx(vstr,px+pw-PAD-vw,iy+8,C.w,FSX,false,7)
				local fill,knob=_sld(slx,iy+38,slw,it.value,it.min,it.max,7)
				table.insert(_els,{
					type="slider",
					x=slx-6,y=iy+28,w=slw+12,h=26,
					fill=fill,knob=knob,
					min=it.min,max=it.max,value=it.value,
					id=it.id,vtx=vtx,suffix=it.suffix,label=it.label,
					slx=slx,slw=slw,ky=iy+39
				})
				if it.callback then state.sCbs[it.id]=it.callback end
				iy=iy+SRH
			elseif it.type=="dropdown"then
				local ddStart=iy
				local selName=it.selected or (it.options and it.options[1]) or ""
				local expanded=state.ddExpanded[it.id]
				_rbg(px,iy,pw,DDH,C.rb,5,isFirst,not expanded and isLast)
				if it.label and it.label~="" then _ttb(it.label,px+PAD+4,iy+7,C.w,FSX,false,7) end
				local arrowCh=expanded and "v" or ">"
				local ddGray=Color3.fromRGB(100,112,145)
				_ttx(arrowCh,px+pw-PAD-8,iy+8,ddGray,11,false,7)
				local selW=#selName*CHW
				_ttx(selName,px+pw-PAD-14-selW,iy+7,C.a,FSX,false,7)
				table.insert(_els,{
					type="ddHeader",id=it.id,
					x=px,y=iy,w=pw,h=DDH
				})
				iy=iy+DDH
				if expanded then
					local optEls={}
					for oi,opt in ipairs(it.options or{})do
						local isSel=(opt==selName)
						local oIsLast=(oi==#(it.options or{}))
						if isSel then
							local cr=6
							_tpf(px+3,iy+2,pw-6,DDH-4,C.ts,5,cr)
						end
						if not oIsLast then _dvl(px,iy+DDH,pw,6) end
						local otx=_ttb(opt,px+PAD+4,iy+7,isSel and C.od or C.g,FSX,false,7)
						table.insert(optEls,{tx=otx,name=opt,x=px,y=iy,w=pw,h=DDH})
						iy=iy+DDH
					end
					table.insert(_els,{
						type="dropdown",id=it.id,
						x=px,y=ddStart+DDH,w=pw,h=iy-(ddStart+DDH),
						options=it.options,selected=selName,
						optEls=optEls,callback=it.callback
					})
				end
			elseif it.type=="button"then
				_rbg(px,iy,pw,RH,C.rb,5,isFirst,isLast)
				if not isLast then _dvl(px,iy+RH,pw,6) end
				_ttb(_trc(it.label,maxChars),px+PAD+4,iy+9,C.a,FSX,false,7)
				_ttx(">",px+pw-PAD-8,iy+10,C.g,11,false,7)
				table.insert(_els,{
					type="button",x=px,y=iy,w=pw,h=RH,
					id=it.id,label=it.label,callback=it.callback
				})
				iy=iy+RH
			end
		end
	end

	local groups=_gri(items)
	for _,grp in ipairs(groups)do
		local f=grp[1]
		if f.type=="section"then
			_slb(colX,cur,colW,f.label,5)
			cur=cur+22
		elseif f.type=="debug"then
			local dx=colX+4
			local dy=cur+4
			local hbDot=_tci(dx+4,dy+10,3,C.a,true,5)
			local dtxt=f.text or "session active"
			_ttx(dtxt,dx+14,dy+4,C.g,FSX,false,5)
			local nameX=dx+14+#dtxt*CHW+4
			if f.gameName and f.gameName~="" then
				_ttb(f.gameName,nameX,dy+4,C.a,FSX,false,5)
				nameX=nameX+#f.gameName*CHW+4
			end
			local avSz=20
			local avR=avSz/2
			if _avd and _avd.pixels then
				local aw=_avd.width or 64
				local ah=_avd.height or 64
				local stepX=math.floor(aw/avSz)
				local stepY=math.floor(ah/avSz)
				local avX=nameX
				local avY=dy
				for ay=0,avSz-1 do
					local row=_avd.pixels[ay*stepY+1]
					if row then
						for ax=0,avSz-1 do
							local ddx=ax-avR+0.5
							local ddy=ay-avR+0.5
							if ddx*ddx+ddy*ddy<=avR*avR then
								local px2=row[ax*stepX+1]
								if px2 and px2.a and px2.a>0.1 then
									local sq=_tsq(avX+ax,avY+ay,1,1,Color3.fromRGB(px2.r or 0,px2.g or 0,px2.b or 0),true,6)
									pcall(function()sq.Transparency=px2.a or 1 end)
								end
							end
						end
					end
				end
				nameX=nameX+avSz+3
			end
			local uName="User"
			pcall(function()uName=_lp.Name end)
			_ttb(uName,nameX,dy+4,C.a,FSX,false,5)
			task.spawn(function()
				local t0=tick()
				while hbDot and state.visible and state.built do
					local t=tick()-t0
					local s=math.sin(t*5)
					local r=3.5+1.5*s
					local a=0.5+0.5*s
					pcall(function()hbDot.Radius=r;hbDot.Transparency=a end)
					task.wait(0.016)
				end
			end)
			cur=cur+DTH
		else
			local ph=0
			for _,it in ipairs(grp)do ph=ph+_ith(it)end
			_tpf(px,cur,pw,ph,C.ct,4)
			_tpb(px,cur,pw,ph,C.bd,6)
			_dit(grp,cur)
			cur=cur+ph+8
		end
	end
end

local function _rin()
	local wx,wy=state.wx,state.wy
	local cy=wy+TH+TAH+8
	local sx=wx+PAD
	local sw=WW-PAD*2
	_slb(sx,cy,sw,"socials",5)
	local iy=cy+24
	local rows={
		{label="discord",value="nejrio",col=C.a},
		{label="github",value="hitechboi",col=C.a},
		{label="roblox",value="besosme",col=C.w,glow=true},
	}
	local rh=DDH*#rows+6
	_pil(sx,iy,sw,rh,4)
	local ry=iy+3
	for ri,row in ipairs(rows)do
		if ri<#rows then _dvl(sx+4,ry+DDH,sw-8,6) end
		_ttb(row.label,sx+PAD+4,ry+7,C.g,FSX,false,7)
		local vtx=_ttb(row.value,sx+sw-PAD-#row.value*CHW,ry+7,row.col,FSX,false,7)
		if row.glow then
			task.spawn(function()
				local t0=tick()
				while vtx and not state.destroyed and state.built and state.activeTab and state.activeTab.name=="info" do
					local g=(math.sin((tick()-t0)*2.0)+1)/2
					local wr,wg2,wb=215/255,220/255,240/255
					local tr,tg2,tb=210/255,180/255,140/255
					local cr=wr+(tr-wr)*g
					local cg=wg2+(tg2-wg2)*g
					local cb=wb+(tb-wb)*g
					pcall(function()vtx.Color=Color3.new(cr,cg,cb)end)
					task.wait(0.016)
				end
			end)
		end
		ry=ry+DDH
	end
	local cy2=iy+rh+10
	_slb(sx,cy2,sw,"Osamason - Check it <3",5)
	local ay=cy2+24
	_pil(sx,ay,sw,30,4)
	_ttx("ty guys.",sx+PAD+4,ay+8,C.w,FSX,false,6)
	local sy2=ay+30+10
	_slb(sx,sy2,sw,"session",5)
	local sdy=sy2+24
	local hbDot2=_tci(sx+8,sdy+10,3,C.a,true,5)
	local stxt="session active"
	_ttx(stxt,sx+18,sdy+4,C.g,FSX,false,5)
	local snX=sx+18+#stxt*CHW+4
	local gn=state.gameName or ""
	if gn~="" then
		_ttb(gn,snX,sdy+4,C.a,FSX,false,5)
		snX=snX+#gn*CHW+4
	end
	local avSz2=20
	local avR2=avSz2/2
	if _avd and _avd.pixels then
		local aw2=_avd.width or 64
		local ah2=_avd.height or 64
		local stepX2=math.floor(aw2/avSz2)
		local stepY2=math.floor(ah2/avSz2)
		for ay2=0,avSz2-1 do
			local row2=_avd.pixels[ay2*stepY2+1]
			if row2 then
				for ax2=0,avSz2-1 do
					local ddx2=ax2-avR2+0.5
					local ddy2=ay2-avR2+0.5
					if ddx2*ddx2+ddy2*ddy2<=avR2*avR2 then
						local px3=row2[ax2*stepX2+1]
						if px3 and px3.a and px3.a>0.1 then
							local sq2=_tsq(snX+ax2,sdy+ay2,1,1,Color3.fromRGB(px3.r or 0,px3.g or 0,px3.b or 0),true,6)
							pcall(function()sq2.Transparency=px3.a or 1 end)
						end
					end
				end
			end
		end
		snX=snX+avSz2+3
	end
	local uN2="User"
	pcall(function()uN2=_lp.Name end)
	_ttb(uN2,snX,sdy+4,C.a,FSX,false,5)
	task.spawn(function()
		local t0=tick()
		while hbDot2 and state.visible and state.built and state.activeTab and state.activeTab.name=="info" do
			local t=tick()-t0
			local s=math.sin(t*5)
			local r=3.5+1.5*s
			local a2=0.5+0.5*s
			pcall(function()hbDot2.Radius=r;hbDot2.Transparency=a2 end)
			task.wait(0.016)
		end
	end)
end

local function _rtc(tab)
	if tab.name=="settings"then
		pcall(function()win.colDiv.Visible=false end)
		_rse();return
	end
	if tab.name=="updatelogs"then
		pcall(function()win.colDiv.Visible=false end)
		_rul();return
	end
	if tab.name=="info"then
		pcall(function()win.colDiv.Visible=false end)
		_rin();return
	end
	local wx,wy=state.wx,state.wy
	local cy=wy+TH+TAH+6
	local left,right={},{}
	for _,it in ipairs(tab.items or{})do
		if it.col==2 then table.insert(right,it)
		else table.insert(left,it)end
	end
	local hasCol2=#right>0
	pcall(function()win.colDiv.Visible=hasCol2 end)
	_rcl(wx,CW,left,cy)
	if hasCol2 then _rcl(wx+CW,WW-CW,right,cy)end
end

local function _rtb(tab,skipAnim,swipeDir)
	if not tab or not state.built then _cla();return end
	if skipAnim or #_aco==0 then
		_cla()
		_rtc(tab)
		return
	end
	local slideOff=(swipeDir or 0)*40
	local useSwipe=swipeDir and swipeDir~=0
	local old={}
	for _,o in ipairs(_aco)do table.insert(old,o)end
	local dur=0.12
	local lastDx=0
	local t0=tick()
	while tick()-t0<dur do
		local p=_clp((tick()-t0)/dur,0,1)
		local ep=p*p
		local alpha=1-p
		for _,o in ipairs(old)do pcall(function()o.Transparency=alpha end)end
		if useSwipe then
			local curDx=-slideOff*ep
			local delta=curDx-lastDx;lastDx=curDx
			local dv=_v2(delta,0)
			for _,o in ipairs(old)do
				pcall(function()o.Position=o.Position+dv end)
				pcall(function()o.From=o.From+dv end)
				pcall(function()o.To=o.To+dv end)
			end
		end
		task.wait(0.016)
	end
	for _,o in ipairs(old)do pcall(function()o.Transparency=0 end)end
	_cla()
	_rtc(tab)
	if useSwipe then
		local dv2=_v2(slideOff,0)
		for _,o in ipairs(_aco)do
			pcall(function()o.Position=o.Position+dv2 end)
			pcall(function()o.From=o.From+dv2 end)
			pcall(function()o.To=o.To+dv2 end)
			pcall(function()o.Transparency=0 end)
		end
	else
		for _,o in ipairs(_aco)do pcall(function()o.Transparency=0 end)end
	end
	lastDx=useSwipe and slideOff or 0
	local t1=tick()
	while tick()-t1<dur do
		local p=_clp((tick()-t1)/dur,0,1)
		local ep=1-(1-p)*(1-p)
		for _,o in ipairs(_aco)do pcall(function()o.Transparency=ep end)end
		if useSwipe then
			local curDx=slideOff*(1-ep)
			local delta=curDx-lastDx;lastDx=curDx
			local dv=_v2(delta,0)
			for _,o in ipairs(_aco)do
				pcall(function()o.Position=o.Position+dv end)
				pcall(function()o.From=o.From+dv end)
				pcall(function()o.To=o.To+dv end)
			end
		end
		task.wait(0.016)
	end
	for _,o in ipairs(_aco)do pcall(function()o.Transparency=1 end)end
	if useSwipe and lastDx~=0 then
		local snap=_v2(-lastDx,0)
		for _,o in ipairs(_aco)do
			pcall(function()o.Position=o.Position+snap end)
			pcall(function()o.From=o.From+snap end)
			pcall(function()o.To=o.To+snap end)
		end
	end
end

local function _frb()
	if not state.loaderDone then return end
	_bwn()
	_bts()
	_rtb(state.activeTab,true)
end

local function _htp()
	for _,o in ipairs(_tpo)do pcall(function()o:Remove()end)end
	table.clear(_tpo)
	_tps.visible=false;_tps.el=nil
end

local function _stp(el,mx,my)
	_htp()
	local txt=el.desc or ""
	if txt=="" then return end
	local tw=math.max(80,#txt*CHW+16)
	local th=24
	local cr=4
	local tx2=el.x+el.w+6
	local ty2=el.y-2
	if tx2+tw>state.wx+WW-4 then tx2=el.x-tw-6 end
	if ty2<state.wy+TH then ty2=el.y+el.h+4 end
	local function tipSq(x,y,w,h,col,filled,zi)
		local o=Drawing.new("Square");o.Position=_v2(x,y);o.Size=_v2(w,h);o.Color=col;o.Filled=filled~=false;o.Transparency=0;o.ZIndex=zi;o.Visible=true
		table.insert(_tpo,o);return o
	end
	local function tipCi(x,y,r,col,filled,zi)
		local o=Drawing.new("Circle");o.Position=_v2(x,y);o.Radius=r;o.Color=col;o.Filled=filled~=false;o.Transparency=0;o.NumSides=32;o.ZIndex=zi;o.Visible=true
		table.insert(_tpo,o);return o
	end
	local function tipLn(x1,y1,x2,y2,col,thick,zi)
		local o=Drawing.new("Line");o.From=_v2(x1,y1);o.To=_v2(x2,y2);o.Color=col;o.Thickness=thick or 1;o.Transparency=0;o.ZIndex=zi;o.Visible=true
		table.insert(_tpo,o);return o
	end
	_dpf(tipSq,tipCi,tx2,ty2,tw,th,C.tb,20,cr)
	_dpb(tipLn,tx2,ty2,tw,th,C.a,21,cr)
	local tt=Drawing.new("Text")
	tt.Text=txt;tt.Position=_v2(tx2+8,ty2+5);tt.Color=C.w;tt.Size=FSX;tt.Font=FNT;tt.Center=false;tt.Outline=false;tt.Transparency=0;tt.ZIndex=22;tt.Visible=true
	table.insert(_tpo,tt)
	_tps.visible=true;_tps.el=el;_tps.fade=0;_tps.t0=tick()
end


local function _nda(dx,dy)
	local dv=_v2(dx,dy)
	local function mv(o)
		pcall(function()o.Position=o.Position+dv end)
		pcall(function()o.From=o.From+dv end)
		pcall(function()o.To=o.To+dv end)
	end
	for _,o in ipairs(objs)do pcall(mv,o)end
	for _,o in ipairs(_aco)do pcall(mv,o)end
	for _,o in ipairs(_tbo)do
		if o.Remove then pcall(mv,o)end
		if o._c then
			o._c.x=o._c.x+dx
			o._c.y=o._c.y+dy
		end
	end
	for _,el in ipairs(_els)do
		el.x=el.x+dx;el.y=el.y+dy
		if el.slx then el.slx=el.slx+dx end
		if el.ky then el.ky=el.ky+dy end
		if el.optEls then
			for _,opt in ipairs(el.optEls)do
				opt.x=opt.x+dx;opt.y=opt.y+dy
			end
		end
	end
end

local _dsl=nil
local _dsc=nil
local _prs=false

local function _ddg(mx)
	if not _dsl then return end
	local el=_dsl
	local pct=_clp((mx-el.slx)/el.slw,0,1)
	local val=math.floor((el.min+(el.max-el.min)*pct)*10+0.5)/10
	el.value=val
	local fw=math.max(2,math.floor(el.slw*pct))
	pcall(function()el.fill.Size=_v2(fw,3)end)
	pcall(function()el.knob.Position=_v2(el.slx+fw,el.ky)end)
	local vstr=tostring(val)..el.suffix
	el.vtx.Text=vstr
	pcall(function()
		local vw=#vstr*CHW
		el.vtx.Position=_v2(el.slx+el.slw+PAD-vw,el.vtx.Position.Y)
	end)
	for _,_tab in ipairs(state.tabs)do for _,_it in ipairs(_tab.items or{})do if _it.id==el.id and _it.type=="slider" then _it.value=val end end end
	local cb=state.sCbs[el.id]
	if cb then pcall(cb,val)end
end

local function _dck(mx,my)
	for _,el in ipairs(_els)do
		if el.type=="toggle" and _ins(mx,my,el.x,el.y,el.w,el.h)then
			el.on=not el.on
			local col=el.on and C.on or C.of
			pcall(function()el.bg1.Color=col end)
			pcall(function()el.bg2.Color=col end)
			pcall(function()el.c1.Color=col end)
			pcall(function()el.c2.Color=col end)
			pcall(function()el.c3.Color=col end)
			pcall(function()el.c4.Color=col end)
			pcall(function()el.dot.Color=el.on and C.od or C.fd end)
			local fromX=el.x+(el.on and 8 or 24)
			local toX=el.x+(el.on and 24 or 8)
			local tweenDot=el.dot
			local tweenY=el.y+8
			task.spawn(function()
				local dur=0.12
				local t0=tick()
				while tick()-t0<dur do
					local p=_clp((tick()-t0)/dur,0,1)
					local ep=1-(1-p)*(1-p)
					local cx=fromX+(toX-fromX)*ep
					pcall(function()tweenDot.Position=_v2(cx,tweenY)end)
					task.wait(0.016)
				end
				pcall(function()tweenDot.Position=_v2(toX,tweenY)end)
			end)
			for _,_tab in ipairs(state.tabs)do for _,_it in ipairs(_tab.items or{})do if _it.id==el.id and _it.type=="toggle" then _it.value=el.on end end end
			local cb=state.tCbs[el.id]
			if cb then pcall(cb,el.on)end
			pcall(function()notify((el.label or el.id)..": "..(el.on and "ON" or "OFF"),"Check It v2",2)end)
			_scc(mx,my)
			return
		elseif el.type=="button" and _ins(mx,my,el.x,el.y,el.w,el.h)then
			if el.callback then pcall(el.callback)end
			pcall(function()notify(el.label or el.id,"Check It v2",2)end)
			_scc(mx,my)
			return
		elseif el.type=="rebind" and _ins(mx,my,el.x,el.y,el.w,el.h)then
			state.rebinding=true;state.rebindTarget=el
			state._rebindAnim=true
			pcall(function()el.rt.Text=".";el.rt.Color=C.a end)
			pcall(function()el.kd.Text=".";el.kd.Color=C.a end)
			pcall(function()win.kTx.Text="."end)
			task.spawn(function()
				local dots={".","..",". . ."}
				local di=1
				while state._rebindAnim and state.rebinding do
					di=di%3+1
					local d=dots[di]
					pcall(function()if state.rebindTarget then state.rebindTarget.rt.Text=d end end)
					pcall(function()if state.rebindTarget then state.rebindTarget.kd.Text=d end end)
					pcall(function()win.kTx.Text=d end)
					task.wait(0.4)
				end
			end)
			return
		elseif el.type=="ddHeader" and _ins(mx,my,el.x,el.y,el.w,el.h)then
			local wasExp=state.ddExpanded[el.id]
			local headerBot=el.y+DDH
			local colL,colR=el.x,el.x+el.w
			local optC=0
			for _,tab in ipairs(state.tabs)do
				for _,it in ipairs(tab.items or{})do
					if it.type=="dropdown" and it.id==el.id then optC=#(it.options or{});break end
				end
				if optC>0 then break end
			end
			local slideH=DDH*optC
			local function inCol(ox) return ox and ox>=colL-2 and ox<=colR+2 end
			if wasExp then
				local tgts={}
				for _,o in ipairs(_aco)do
					local py,px2;pcall(function()py=o.Position and o.Position.Y;px2=o.Position and o.Position.X end)
					if py and inCol(px2) and py>=headerBot and py<headerBot+slideH then
						table.insert(tgts,{obj=o,origY=py,type="pos",isOpt=true})
					elseif py and inCol(px2) and py>=headerBot+slideH then
						table.insert(tgts,{obj=o,origY=py,type="pos",isOpt=false})
					else
						local fy,fx;pcall(function()fy=o.From and o.From.Y;fx=o.From and o.From.X end)
						if fy and inCol(fx) and fy>=headerBot and fy<headerBot+slideH then
							local ty2;pcall(function()ty2=o.To.Y end)
							table.insert(tgts,{obj=o,origFromY=fy,origToY=ty2,type="line",isOpt=true})
						elseif fy and inCol(fx) and fy>=headerBot+slideH then
							local ty2;pcall(function()ty2=o.To.Y end)
							table.insert(tgts,{obj=o,origFromY=fy,origToY=ty2,type="line",isOpt=false})
						end
					end
				end
				local dur=0.12;local t0=tick()
				while tick()-t0<dur do
					local p=_clp((tick()-t0)/dur,0,1);local ep=p*p
					for _,tg in ipairs(tgts)do
						if tg.type=="pos"then
							pcall(function()tg.obj.Position=_v2(tg.obj.Position.X,tg.origY-slideH*ep)end)
						else
							pcall(function()tg.obj.From=_v2(tg.obj.From.X,tg.origFromY-slideH*ep)end)
							pcall(function()tg.obj.To=_v2(tg.obj.To.X,tg.origToY-slideH*ep)end)
						end
						if tg.isOpt then pcall(function()tg.obj.Transparency=1-ep end)end
					end
					task.wait(0.016)
				end
				state.ddExpanded[el.id]=false
				_cla();_rtc(state.activeTab)
			else
				state.ddExpanded[el.id]=true
				_cla();_rtc(state.activeTab)
				local tgts={}
				for _,o in ipairs(_aco)do
					local py,px2;pcall(function()py=o.Position and o.Position.Y;px2=o.Position and o.Position.X end)
					if py and inCol(px2) and py>=headerBot and py<headerBot+slideH then
						table.insert(tgts,{obj=o,finalY=py,type="pos",isOpt=true})
						pcall(function()o.Position=_v2(o.Position.X,py-slideH)end)
						pcall(function()o.Transparency=0 end)
					elseif py and inCol(px2) and py>=headerBot+slideH then
						table.insert(tgts,{obj=o,finalY=py,type="pos",isOpt=false})
						pcall(function()o.Position=_v2(o.Position.X,py-slideH)end)
					else
						local fy,fx;pcall(function()fy=o.From and o.From.Y;fx=o.From and o.From.X end)
						if fy and inCol(fx) and fy>=headerBot and fy<headerBot+slideH then
							local ty2;pcall(function()ty2=o.To.Y end)
							table.insert(tgts,{obj=o,finalFromY=fy,finalToY=ty2,type="line",isOpt=true})
							pcall(function()o.From=_v2(o.From.X,fy-slideH)end)
							pcall(function()o.To=_v2(o.To.X,ty2-slideH)end)
							pcall(function()o.Transparency=0 end)
						elseif fy and inCol(fx) and fy>=headerBot+slideH then
							local ty2;pcall(function()ty2=o.To.Y end)
							table.insert(tgts,{obj=o,finalFromY=fy,finalToY=ty2,type="line",isOpt=false})
							pcall(function()o.From=_v2(o.From.X,fy-slideH)end)
							pcall(function()o.To=_v2(o.To.X,ty2-slideH)end)
						end
					end
				end
				local dur=0.12;local t0=tick()
				while tick()-t0<dur do
					local p=_clp((tick()-t0)/dur,0,1)
					local ep=1-(1-p)*(1-p)
					for _,tg in ipairs(tgts)do
						if tg.type=="pos"then
							pcall(function()tg.obj.Position=_v2(tg.obj.Position.X,(tg.finalY-slideH)+slideH*ep)end)
						else
							pcall(function()tg.obj.From=_v2(tg.obj.From.X,(tg.finalFromY-slideH)+slideH*ep)end)
							pcall(function()tg.obj.To=_v2(tg.obj.To.X,(tg.finalToY-slideH)+slideH*ep)end)
						end
						if tg.isOpt then pcall(function()tg.obj.Transparency=ep end)end
					end
					task.wait(0.016)
				end
				for _,tg in ipairs(tgts)do
					if tg.type=="pos"then pcall(function()tg.obj.Position=_v2(tg.obj.Position.X,tg.finalY)end)
					else pcall(function()tg.obj.From=_v2(tg.obj.From.X,tg.finalFromY);tg.obj.To=_v2(tg.obj.To.X,tg.finalToY)end)end
					if tg.isOpt then pcall(function()tg.obj.Transparency=1 end)end
				end
			end
			_scc(mx,my)
			return
		elseif el.type=="dropdown" and el.optEls then
			for _,opt in ipairs(el.optEls)do
				if _ins(mx,my,opt.x,opt.y,opt.w,opt.h) then
					if opt.name~=el.selected then
						el.selected=opt.name
						for _,tab in ipairs(state.tabs)do
							for _,it in ipairs(tab.items or{})do
								if it.type=="dropdown" and it.id==el.id then it.selected=opt.name end
							end
						end
						if el.callback then pcall(el.callback,opt.name)end
					end
					local hBot=el.y
					local sH=el.h
					local colL,colR=el.x,el.x+el.w
					local function inCol2(ox) return ox and ox>=colL-2 and ox<=colR+2 end
					local opts2={}
					for _,o in ipairs(_aco)do
						local py,px2;pcall(function()py=o.Position and o.Position.Y;px2=o.Position and o.Position.X end)
						if py and inCol2(px2) and py>=hBot and py<hBot+sH then
							table.insert(opts2,{obj=o,origY=py,type="pos",isOpt=true})
						elseif py and inCol2(px2) and py>=hBot+sH then
							table.insert(opts2,{obj=o,origY=py,type="pos",isOpt=false})
						else
							local fy,fx;pcall(function()fy=o.From and o.From.Y;fx=o.From and o.From.X end)
							if fy and inCol2(fx) and fy>=hBot and fy<hBot+sH then
								local ty2;pcall(function()ty2=o.To.Y end)
								table.insert(opts2,{obj=o,origFromY=fy,origToY=ty2,type="line",isOpt=true})
							elseif fy and inCol2(fx) and fy>=hBot+sH then
								local ty2;pcall(function()ty2=o.To.Y end)
								table.insert(opts2,{obj=o,origFromY=fy,origToY=ty2,type="line",isOpt=false})
							end
						end
					end
					local dur2=0.12;local t02=tick()
					while tick()-t02<dur2 do
						local p2=_clp((tick()-t02)/dur2,0,1);local ep2=p2*p2
						for _,tg in ipairs(opts2)do
							if tg.type=="pos"then
								pcall(function()tg.obj.Position=_v2(tg.obj.Position.X,tg.origY-sH*ep2)end)
							else
								pcall(function()tg.obj.From=_v2(tg.obj.From.X,tg.origFromY-sH*ep2)end)
								pcall(function()tg.obj.To=_v2(tg.obj.To.X,tg.origToY-sH*ep2)end)
							end
							if tg.isOpt then pcall(function()tg.obj.Transparency=1-ep2 end)end
						end
						task.wait(0.016)
					end
					state.ddExpanded[el.id]=false
					_cla();_rtc(state.activeTab)
					_scc(mx,my)
					return
				end
			end
		elseif el.type=="theme" and el.optEls then
			for _,opt in ipairs(el.optEls)do
				if _ins(mx,my,opt.x,opt.y,opt.w,opt.h) and opt.name~=state.currentTheme then
					_ath(opt.name)
					_frb()
					_scc(mx,my)
					return
				end
			end
		elseif el.type=="logScrollBtn" and _ins(mx,my,el.x,el.y,el.w,el.h)then
			state.logScrollY=_clp(state.logScrollY+el.dir*el.step,0,el.maxScroll)
			_cla();_rtc(state.activeTab)
			return
		elseif el.type=="destroy" and _ins(mx,my,el.x,el.y,el.w,el.h)then
			if not state.destroyConfirm then
				state.destroyConfirm=true
				pcall(function()el.txt.Text="confirm?"end)
				pcall(function()el.txt.Color=Color3.fromRGB(255,120,120)end)
				task.spawn(function()
					task.wait(2)
					if state.destroyConfirm then
						state.destroyConfirm=false
						pcall(function()el.txt.Text="destroy"end)
						pcall(function()el.txt.Color=Color3.fromRGB(220,80,80)end)
					end
				end)
				return
			end
			state.destroyConfirm=false
			state.destroyed=true
			for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
			for _,o in ipairs(_tbo)do pcall(function()if o.Remove then o:Remove()end end)end
			for _,o in ipairs(_aco)do pcall(function()o:Remove()end)end
			for _,o in ipairs(_ldo)do pcall(function()o:Remove()end)end
			for _,o in ipairs(_cfo)do pcall(function()o:Remove()end)end
			table.clear(objs);table.clear(_tbo);table.clear(_aco);table.clear(_ldo);table.clear(_cfo);table.clear(_els)
			_G.lib=nil
			notify("Menu destroyed","Check It v2",3)
			return
		end
	end
	for _,to in ipairs(_tbo)do
		if to._c and _ins(mx,my,to._c.x,to._c.y,to._c.w,to._c.h)then
			local n=to._c.name
			local oldName=state.activeTab and state.activeTab.name or ""
			if n==oldName then return end
			local allNames={}
			for _,t in ipairs(state.tabs)do table.insert(allNames,t.name)end
			for _,sn in ipairs({"info","updatelogs","settings"})do table.insert(allNames,sn)end
			local oldIdx,newIdx=0,0
			for i,nm in ipairs(allNames)do
				if nm==oldName then oldIdx=i end
				if nm==n then newIdx=i end
			end
			local dir=0
			if newIdx>oldIdx then dir=1
			elseif newIdx<oldIdx then dir=-1 end
			if n~="updatelogs" then state.logScrollY=0 end
			if n=="settings" or n=="updatelogs" or n=="info"then state.activeTab={name=n,items={}}
			else for _,t in ipairs(state.tabs)do if t.name==n then state.activeTab=t;break end end end
			_bts();_rtb(state.activeTab,false,dir)
			return
		end
	end
end

spawn(function()
	local wasDragging=false
	local wasMenuKey=false
	local _dscTrack=nil
	while true do
		task.wait(0.016)
		if state.destroyed then break end
		if state.rebinding then
			for k=0x08,0xDD do
				local kp2=false
				pcall(function()kp2=iskeypressed(k)end)
				if kp2 and k~=0x01 and k~=0x02 then
					local kn=_vkn[k]
					if kn then
						state.menuVK=k
						state.menuKeyLabel=kn
						pcall(function()win.kTx.Text=kn end)
						if state.rebindTarget then
							pcall(function()
								state.rebindTarget.kd.Text=kn
								state.rebindTarget.kd.Color=C.od
								state.rebindTarget.rt.Text="rebind"
								state.rebindTarget.rt.Color=C.g
							end)
						end
						state.rebinding=false;state.rebindTarget=nil
						if state._rebindAnim then state._rebindAnim=false end
						pcall(function()notify("Menu key â†’ "..kn,"Check It v2",2)end)
					end
					break
				end
			end
		end
		local menuDown=false
		pcall(function()menuDown=iskeypressed(state.menuVK)end)
		if menuDown and not wasMenuKey then
			state.visible=not state.visible
			task.spawn(function()_svs(state.visible)end)
		end
		wasMenuKey=menuDown
		if state.visible then
			local mx,my=_ms.X,_ms.Y
			local m1=ismouse1pressed()
			if m1 and not _prs then
				_prs=true
				local wx,wy=state.wx,state.wy
				if _ins(mx,my,wx,wy,WW,TH) and not _ins(mx,my,wx+WW-160,wy,160,TH)then
					state.dragging=true
					wasDragging=false
					state.dragox=mx
					state.dragoy=my
				elseif _ins(mx,my,wx,wy,WW,state.wh)then
					local fs=false
					for _,el in ipairs(_els)do
						if el.type=="slider" and _ins(mx,my,el.x,el.y,el.w,el.h)then
							_dsl=el;fs=true;break
						end
						if el.type=="logScrollBtn" and _ins(mx,my,el.x,el.y,el.w,el.h)then
							_dsc={dir=el.dir,step=el.step,timer=tick()}
							state.logScrollY=_clp(state.logScrollY+el.dir*el.step,0,el.maxScroll)
							_cla();_rtc(state.activeTab)
							fs=true;break
						end
						if el.type=="logScrollTrack" and _ins(mx,my,el.x,el.y,el.w,el.h)then
							_dscTrack={el=el,targetY=nil}
							local pct=_clp((my-el.trackTop)/(el.trackH-el.thumbH),0,1)
							_dscTrack.targetY=_clp(math.floor(pct*el.maxScroll),0,el.maxScroll)
							fs=true;break
						end
					end
					if not fs then _dck(mx,my)end
				end
			elseif m1 and _prs then
				if state.dragging then
					local dx=mx-state.dragox
					local dy=my-state.dragoy
					if dx~=0 or dy~=0 then
						state.wx=state.wx+dx
						state.wy=state.wy+dy
						state.dragox=mx
						state.dragoy=my
						wasDragging=true
						_nda(dx,dy)
					end
				elseif _dsl then
					_ddg(mx)
				elseif _dsc and state.activeTab and state.activeTab.name=="updatelogs" then
					if tick()-_dsc.timer>0.08 then
						_dsc.timer=tick()
						local totalH=_lth()
						local visH=state.wh-TH-TAH-16
						local maxS=math.max(0,totalH-visH+16)
						state.logScrollY=_clp(state.logScrollY+_dsc.dir*_dsc.step,0,maxS)
						_cla();_rtc(state.activeTab)
					end
				elseif _dscTrack then
					local el=_dscTrack.el
					local pct=_clp((my-el.trackTop)/(el.trackH-el.thumbH),0,1)
					_dscTrack.targetY=_clp(math.floor(pct*el.maxScroll),0,el.maxScroll)
				end
			elseif not m1 then
				if _dsl then
					pcall(function()notify((_dsl.label or _dsl.id)..": "..tostring(_dsl.value)..(_dsl.suffix or""),"Check It v2",2)end)
				end
				wasDragging=false
				_prs=false
				state.dragging=false
				_dsl=nil
				_dsc=nil
				_dscTrack=nil
			end
			local hovEl=nil
			for _,el in ipairs(_els)do
				if el.type=="hoverTip" and _ins(mx,my,el.x,el.y,el.w,el.h) then
					hovEl=el
				end
			end
			if hovEl then
				if _tps.el~=hovEl then _stp(hovEl,mx,my)end
			else
				if _tps.visible then _htp()end
			end
			if _tps.visible and _tps.fade and _tps.fade<1 then
				local elapsed=tick()-(_tps.t0 or tick())
				local alpha=_clp(elapsed/0.15,0,1)
				_tps.fade=alpha
				for _,o in ipairs(_tpo)do pcall(function()o.Transparency=alpha end)end
			end
			for _,el in ipairs(_els)do
				if el.type=="slider" then
					local hov=_ins(mx,my,el.x,el.y,el.w,el.h)
					if hov and not el._knobHov then
						el._knobHov=true
						pcall(function()el.knob.Radius=7 end)
					elseif not hov and el._knobHov then
						el._knobHov=false
						pcall(function()el.knob.Radius=5 end)
					end
				end
			end
			if _dscTrack and _dscTrack.targetY then
				local cur2=state.logScrollY
				local tgt=_dscTrack.targetY
				if math.abs(cur2-tgt)>1 then
					local newS=math.floor(cur2+(tgt-cur2)*0.25+0.5)
					if newS~=cur2 then
						state.logScrollY=newS
						_cla();_rtc(state.activeTab)
					end
				elseif cur2~=tgt then
					state.logScrollY=tgt
					_cla();_rtc(state.activeTab)
				end
			end
		end
	end
end)

local lib={}
lib.__index=lib

function lib:Window()
	local w={}
	function w:Tab(name)
		local tab={name=name,items={}}
		table.insert(state.tabs,tab)
		if #state.tabs==1 then state.activeTab=tab end
		_frb()
		local t={}
		function t:Section(label,col)
			table.insert(tab.items,{type="section",label=label,col=col or 1})
			local s={}
			function s:Toggle(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="toggle",label=opts.label,value=opts.default or false,id=id,callback=opts.callback,col=opts.col or 1,desc=opts.desc})
				if state.activeTab and state.activeTab.name==tab.name then _frb()end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(_els)do
						if el.type=="toggle" and el.id==id then
							local wasOn=el.on
							el.on=v
							local col=v and C.on or C.of
							pcall(function()el.bg1.Color=col end)
							pcall(function()el.bg2.Color=col end)
							pcall(function()el.c1.Color=col end)
							pcall(function()el.c2.Color=col end)
							pcall(function()el.c3.Color=col end)
							pcall(function()el.c4.Color=col end)
							pcall(function()el.dot.Color=v and C.od or C.fd end)
							if wasOn~=v then
								local fromX=el.x+(v and 8 or 24)
								local toX=el.x+(v and 24 or 8)
								local td=el.dot
								local ty2=el.y+8
								task.spawn(function()
									local dur=0.12
									local t0=tick()
									while tick()-t0<dur do
										local p=_clp((tick()-t0)/dur,0,1)
										local ep=1-(1-p)*(1-p)
										pcall(function()td.Position=_v2(fromX+(toX-fromX)*ep,ty2)end)
										task.wait(0.016)
									end
									pcall(function()td.Position=_v2(toX,ty2)end)
								end)
							else
								pcall(function()el.dot.Position=_v2(el.x+(v and 24 or 8),el.y+8)end)
							end
							for _,_t2 in ipairs(state.tabs)do for _,_it2 in ipairs(_t2.items or{})do if _it2.id==id and _it2.type=="toggle" then _it2.value=v end end end
						end
					end
				end
				ctrl.SetState=ctrl.Set
				return ctrl
			end
			function s:Slider(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="slider",label=opts.label,value=opts.default or opts.min,min=opts.min,max=opts.max,suffix=opts.suffix or"",id=id,callback=opts.callback,col=opts.col or 1,desc=opts.desc})
				if state.activeTab and state.activeTab.name==tab.name then _frb()end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(_els)do
						if el.type=="slider" and el.id==id then
							local pct=_clp((v-el.min)/(el.max-el.min),0,1)
							local fw=math.max(2,math.floor(el.slw*pct))
							el.value=v
							pcall(function()el.fill.Size=_v2(fw,3)end)
							pcall(function()el.knob.Position=_v2(el.slx+fw,el.ky)end)
							el.vtx.Text=tostring(v)..el.suffix
						end
					end
				end
				return ctrl
			end
			function s:Dropdown(opts)
				local id=opts.id or opts.label
				local sel=opts.default or (opts.options and opts.options[1]) or ""
				table.insert(tab.items,{type="dropdown",label=opts.label,options=opts.options or{},selected=sel,id=id,callback=opts.callback,col=opts.col or 1,desc=opts.desc})
				if state.activeTab and state.activeTab.name==tab.name then _frb()end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(_els)do
						if el.type=="dropdown" and el.id==id then
							el.selected=v
							for _,t2 in ipairs(state.tabs)do
								for _,it in ipairs(t2.items or{})do
									if it.type=="dropdown" and it.id==id then it.selected=v end
								end
							end
							_rtb(state.activeTab)
						end
					end
				end
				function ctrl:SetOptions(newOpts)
					for _,t2 in ipairs(state.tabs)do
						for _,it in ipairs(t2.items or{})do
							if it.type=="dropdown" and it.id==id then it.options=newOpts end
						end
					end
					if state.activeTab and state.activeTab.name==tab.name then _frb()end
				end
				return ctrl
			end
			function s:DebugRow(opts)
				table.insert(tab.items,{type="debug",text=opts.text or "session active",gameName=opts.gameName or "",col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then _frb()end
			end
			function s:Button(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="button",label=opts.label,id=id,callback=opts.callback,col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then _frb()end
			end
			return s
		end
		function t:SettingsTab()
			state.activeTab={name="settings",items={}}
			_bts();_rtb(state.activeTab)
		end
		return t
	end
	function w:SetGameName(gn)
		state.gameName=gn or ""
	end
	function w:AddMainScriptLog(ver,date,entries)
		for _,cat in ipairs(_ulg)do
			if cat.category=="Main Script Updates"then
				table.insert(cat.logs,1,{ver=ver,date=date,entries=entries})
				break
			end
		end
	end
	task.spawn(function()
		local ok,err=pcall(function()
			task.wait(0.1)
			state.wh=_cwh()
			_shl()
			while not state.loaderDone do task.wait(0.05) end
			local slideOff=20
			state.wy=state.wy-slideOff
			_frb()
			local function allO()
				local a={}
				for _,o in ipairs(objs)do table.insert(a,o)end
				for _,o in ipairs(_tbo)do if o.Remove then table.insert(a,o)end end
				for _,o in ipairs(_aco)do table.insert(a,o)end
				return a
			end
			for _,o in ipairs(allO())do pcall(function()o.Transparency=0 end)end
			local dur=0.3
			local t0=tick()
			local lastY=0
			while tick()-t0<dur do
				local p=_clp((tick()-t0)/dur,0,1)
				local ep=1-(1-p)*(1-p)*(1-p)
				local curY=math.floor(slideOff*ep)
				local dy=curY-lastY
				if dy~=0 then
					state.wy=state.wy+dy
					_nda(0,dy)
					lastY=curY
				end
				for _,o in ipairs(allO())do pcall(function()o.Transparency=ep end)end
				task.wait(0.016)
			end
			local rem=slideOff-lastY
			if rem~=0 then state.wy=state.wy+rem;_nda(0,rem)end
			for _,o in ipairs(allO())do pcall(function()o.Transparency=1 end)end
			local userName="User"
			pcall(function()userName=_lp.Name end)
			pcall(function()notify("Welcome, "..userName,"Check It v2",3)end)
			task.wait(0.3)
			pcall(function()notify("thank you guys for almost 100 stars have this special theme for the time being","Check It v2",5)end)
			task.wait(0.3)
			pcall(function()notify("reapply the theme to see a cool effect :)","Check It v2",5)end)
		end)
		if not ok then warn("[lib] ERROR in spawn: "..tostring(err)) end
	end)
	return w
end

function lib:Destroy()
	_stcf()
	for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
	for _,o in ipairs(_tbo)do pcall(function()if o.Remove then o:Remove()end end)end
	for _,o in ipairs(_aco)do pcall(function()o:Remove()end)end
	for _,o in ipairs(_ldo)do pcall(function()o:Remove()end)end
	for _,o in ipairs(_cfo)do pcall(function()o:Remove()end)end
	table.clear(objs);table.clear(_tbo);table.clear(_aco);table.clear(_ldo);table.clear(_cfo)
end
_G.lib=lib
