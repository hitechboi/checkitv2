local UIS=game:GetService("UserInputService")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local mouse=lp:GetMouse()
local cam=workspace.CurrentCamera
local SX,SY=cam.ViewportSize.X,cam.ViewportSize.Y

local C={
	ACCENT=Color3.fromRGB(70,120,255),
	SIDEBAR=Color3.fromRGB(12,15,27),
	CONTENT=Color3.fromRGB(11,13,23),
	TOPBAR=Color3.fromRGB(7,9,17),
	BORDER=Color3.fromRGB(30,40,72),
	ROWBG=Color3.fromRGB(14,18,33),
	TABSEL=Color3.fromRGB(20,35,85),
	WHITE=Color3.fromRGB(215,220,240),
	GRAY=Color3.fromRGB(100,112,145),
	DIMGRAY=Color3.fromRGB(28,33,52),
	ON=Color3.fromRGB(45,85,195),
	OFF=Color3.fromRGB(20,24,42),
	ONDOT=Color3.fromRGB(175,198,255),
	OFFDOT=Color3.fromRGB(55,65,95),
	DIV=Color3.fromRGB(22,27,48),
	MINIBAR=Color3.fromRGB(11,13,22),
}

local THEMES={
	midnight={ACCENT=Color3.fromRGB(70,120,255),SIDEBAR=Color3.fromRGB(12,15,27),CONTENT=Color3.fromRGB(11,13,23),TOPBAR=Color3.fromRGB(7,9,17),BORDER=Color3.fromRGB(30,40,72),ROWBG=Color3.fromRGB(14,18,33),TABSEL=Color3.fromRGB(20,35,85),WHITE=Color3.fromRGB(215,220,240),GRAY=Color3.fromRGB(100,112,145),DIMGRAY=Color3.fromRGB(28,33,52),ON=Color3.fromRGB(45,85,195),OFF=Color3.fromRGB(20,24,42),ONDOT=Color3.fromRGB(175,198,255),OFFDOT=Color3.fromRGB(55,65,95),DIV=Color3.fromRGB(22,27,48),MINIBAR=Color3.fromRGB(11,13,22)},
	emerald={ACCENT=Color3.fromRGB(50,205,120),SIDEBAR=Color3.fromRGB(10,20,15),CONTENT=Color3.fromRGB(8,18,12),TOPBAR=Color3.fromRGB(5,12,8),BORDER=Color3.fromRGB(25,60,40),ROWBG=Color3.fromRGB(12,24,18),TABSEL=Color3.fromRGB(15,50,35),WHITE=Color3.fromRGB(210,240,220),GRAY=Color3.fromRGB(90,130,110),DIMGRAY=Color3.fromRGB(20,40,30),ON=Color3.fromRGB(30,140,80),OFF=Color3.fromRGB(15,30,22),ONDOT=Color3.fromRGB(150,240,180),OFFDOT=Color3.fromRGB(45,80,60),DIV=Color3.fromRGB(18,36,26),MINIBAR=Color3.fromRGB(8,16,11)},
	crimson={ACCENT=Color3.fromRGB(220,60,80),SIDEBAR=Color3.fromRGB(20,10,12),CONTENT=Color3.fromRGB(18,8,10),TOPBAR=Color3.fromRGB(12,5,7),BORDER=Color3.fromRGB(60,25,30),ROWBG=Color3.fromRGB(24,12,15),TABSEL=Color3.fromRGB(50,18,25),WHITE=Color3.fromRGB(240,215,220),GRAY=Color3.fromRGB(130,95,100),DIMGRAY=Color3.fromRGB(40,22,26),ON=Color3.fromRGB(160,40,55),OFF=Color3.fromRGB(30,15,18),ONDOT=Color3.fromRGB(255,170,180),OFFDOT=Color3.fromRGB(80,50,55),DIV=Color3.fromRGB(36,18,22),MINIBAR=Color3.fromRGB(16,7,9)},
	confetti={ACCENT=Color3.fromRGB(255,100,200),SIDEBAR=Color3.fromRGB(15,10,20),CONTENT=Color3.fromRGB(12,8,18),TOPBAR=Color3.fromRGB(8,5,14),BORDER=Color3.fromRGB(50,30,65),ROWBG=Color3.fromRGB(18,12,26),TABSEL=Color3.fromRGB(40,20,60),WHITE=Color3.fromRGB(240,220,250),GRAY=Color3.fromRGB(120,100,140),DIMGRAY=Color3.fromRGB(32,22,42),ON=Color3.fromRGB(180,50,140),OFF=Color3.fromRGB(25,15,35),ONDOT=Color3.fromRGB(255,180,230),OFFDOT=Color3.fromRGB(70,50,85),DIV=Color3.fromRGB(28,18,38),MINIBAR=Color3.fromRGB(10,7,16)},
}
local THEME_NAMES={"midnight","emerald","crimson","confetti"}

local FNT=Drawing.Fonts.Plex or Drawing.Fonts.Monospace
local FS=16
local FSS=14
local FSX=13
local TH=30
local TAH=22
local RH=30
local SRH=46
local PAD=10
local CW=330
local WW=660

local objs,tabObjs,actObjs,elements,win={},{},{},{},{}
local loaderObjs={}

local state={
	visible=true,dragging=false,
	dragox=0,dragoy=0,
	wx=math.floor(SX/2-WW/2),
	wy=math.floor(SY/2-180),
	wh=300,
	activeTab=nil,tabs={},
	menuKeyLabel="INSERT",
	menuKeyCode=Enum.KeyCode.Insert,
	tCbs={},sCbs={},
	rebinding=false,rebindTarget=nil,
	built=false,
	loaderDone=false,
	destroyConfirm=false,
	currentTheme="midnight",
}

local function applyTheme(name)
	local t=THEMES[name]
	if not t then return end
	for k,v in pairs(t) do C[k]=v end
	state.currentTheme=name
end

local function clamp(v,a,b)return math.max(a,math.min(b,v))end
local function inside(x,y,rx,ry,rw,rh)return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh end
local function trunc(s,n)if #s>n then return s:sub(1,n-1).."~"end return s end

local function newObj(pool,typ,props)
	local o=Drawing.new(typ)
	for k,v in pairs(props)do o[k]=v end
	table.insert(pool,o)
	return o
end

local V2=Vector2.new

local function wSq(x,y,w,h,col,filled,zi)
	return newObj(objs,"Square",{Position=V2(x,y),Size=V2(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 1,Visible=state.visible})
end
local function wLn(x1,y1,x2,y2,col,thick,zi)
	return newObj(objs,"Line",{From=V2(x1,y1),To=V2(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})
end
local function wTx(s,x,y,col,sz,ctr,zi)
	return newObj(objs,"Text",{Text=s,Position=V2(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})
end
local function wCi(x,y,r,col,filled,zi)
	return newObj(objs,"Circle",{Position=V2(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=24,ZIndex=zi or 1,Visible=state.visible})
end
local function tSq(x,y,w,h,col,filled,zi)
	return newObj(actObjs,"Square",{Position=V2(x,y),Size=V2(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 3,Visible=state.visible})
end
local function tLn(x1,y1,x2,y2,col,thick,zi)
	return newObj(actObjs,"Line",{From=V2(x1,y1),To=V2(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function tTx(s,x,y,col,sz,ctr,zi)
	return newObj(actObjs,"Text",{Text=s,Position=V2(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end
local function tCi(x,y,r,col,filled,zi)
	return newObj(actObjs,"Circle",{Position=V2(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=24,ZIndex=zi or 3,Visible=state.visible})
end
local function tbSq(x,y,w,h,col,filled,zi)
	return newObj(tabObjs,"Square",{Position=V2(x,y),Size=V2(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 3,Visible=state.visible})
end
local function tbLn(x1,y1,x2,y2,col,thick,zi)
	return newObj(tabObjs,"Line",{From=V2(x1,y1),To=V2(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function tbTx(s,x,y,col,sz,ctr,zi)
	return newObj(tabObjs,"Text",{Text=s,Position=V2(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end

-- ── LOADER ──
local function lObj(typ,props)
	local o=Drawing.new(typ)
	for k,v in pairs(props)do o[k]=v end
	table.insert(loaderObjs,o)
	return o
end

local function showLoader()
	local wh=state.wh or 300
	local wx,wy=state.wx,state.wy
	local cx=wx+math.floor(WW/2)
	local cy=wy+math.floor(wh/2)
	-- rounded pill bg matching menu size
	local r=8
	lObj("Square",{Position=V2(wx+r,wy),Size=V2(WW-r*2,wh),Color=C.TOPBAR,Filled=true,Transparency=1,ZIndex=50,Visible=true})
	lObj("Square",{Position=V2(wx,wy+r),Size=V2(WW,wh-r*2),Color=C.TOPBAR,Filled=true,Transparency=1,ZIndex=50,Visible=true})
	lObj("Circle",{Position=V2(wx+r,wy+r),Radius=r,Color=C.TOPBAR,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	lObj("Circle",{Position=V2(wx+WW-r,wy+r),Radius=r,Color=C.TOPBAR,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	lObj("Circle",{Position=V2(wx+r,wy+wh-r),Radius=r,Color=C.TOPBAR,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	lObj("Circle",{Position=V2(wx+WW-r,wy+wh-r),Radius=r,Color=C.TOPBAR,Filled=true,Transparency=1,NumSides=24,ZIndex=50,Visible=true})
	-- each text element: {obj, baseX, baseY, delay}
	local slideOff=20
	local parts={
		{txt="Check", col=C.WHITE,  sz=28, bx=cx-80, by=cy-10, delay=0},
		{txt=".",     col=C.BORDER, sz=20, bx=cx-18, by=cy-10, delay=0.08},
		{txt="It",    col=C.ACCENT, sz=28, bx=cx-4,  by=cy-10, delay=0.16},
		{txt=".",     col=C.BORDER, sz=20, bx=cx+28, by=cy-10, delay=0.24},
		{txt="v2",    col=C.GRAY,   sz=14, bx=cx+42, by=cy-2,  delay=0.32},
	}
	local textObjs={}
	for _,p in ipairs(parts)do
		local o=lObj("Text",{Text=p.txt,Position=V2(p.bx,p.by+slideOff),Color=p.col,Size=p.sz,Font=FNT,Center=false,Outline=false,Transparency=0,ZIndex=52,Visible=true})
		table.insert(textObjs,{obj=o,bx=p.bx,by=p.by,delay=p.delay})
	end
	-- progress bar
	local barW=math.min(220,WW-60)
	local barX=cx-barW/2
	local barY=cy+30
	lObj("Square",{Position=V2(barX,barY),Size=V2(barW,2),Color=C.DIMGRAY,Filled=true,Transparency=1,ZIndex=52,Visible=true})
	local barFill=lObj("Square",{Position=V2(barX,barY),Size=V2(0,2),Color=C.ACCENT,Filled=true,Transparency=0,ZIndex=53,Visible=true})
	-- status text
	local statusTx=lObj("Text",{Text="initializing modules_",Position=V2(cx,cy+46),Color=C.GRAY,Size=10,Font=FNT,Center=true,Outline=false,Transparency=0,ZIndex=52,Visible=true})
	-- animate INLINE (no nested task.spawn — runs in caller's coroutine)
	pcall(function()
		local t0=tick()
		local slideDur=0.35
		local totalTextDur=slideDur+0.32
		-- phase 1: staggered slide up + fade in per word
		while tick()-t0<totalTextDur+slideDur do
			local elapsed=tick()-t0
			for _,te in ipairs(textObjs)do
				local t=elapsed-te.delay
				if t<0 then
					pcall(function()te.obj.Transparency=0 end)
				elseif t<slideDur then
					local p=clamp(t/slideDur,0,1)
					local ep=1-(1-p)*(1-p)*(1-p)
					local yOff=math.floor(slideOff*(1-ep))
					pcall(function()te.obj.Position=V2(te.bx,te.by+yOff)end)
					pcall(function()te.obj.Transparency=ep end)
				else
					pcall(function()te.obj.Position=V2(te.bx,te.by)end)
					pcall(function()te.obj.Transparency=1 end)
				end
			end
			task.wait(0.016)
		end
		for _,te in ipairs(textObjs)do
			pcall(function()te.obj.Position=V2(te.bx,te.by)end)
			pcall(function()te.obj.Transparency=1 end)
		end
		-- phase 2: progress bar fill (1.4s)
		local barStart=tick()
		local barDur=1.4
		local blink=true
		pcall(function()barFill.Transparency=1 end)
		pcall(function()statusTx.Transparency=1 end)
		while tick()-barStart<barDur do
			local pct=clamp((tick()-barStart)/barDur,0,1)
			local ep=pct<0.3 and pct/0.3*0.45 or pct<0.6 and 0.45+(pct-0.3)/0.3*0.27 or pct<0.85 and 0.72+(pct-0.6)/0.25*0.18 or 0.9+(pct-0.85)/0.15*0.1
			pcall(function()barFill.Size=V2(math.floor(barW*ep),2)end)
			local nb=math.floor((tick()-barStart)/0.5)%2==0
			if nb~=blink then
				blink=nb
				pcall(function()statusTx.Text=blink and "initializing modules_" or "initializing modules "end)
			end
			task.wait(0.016)
		end
		pcall(function()barFill.Size=V2(barW,2)end)
		task.wait(0.3)
		-- fade out loader
		for i=10,0,-1 do
			local a=i/10
			for _,o in ipairs(loaderObjs)do pcall(function()o.Transparency=a end)end
			task.wait(0.03)
		end
	end)
	-- always cleanup and signal done, even if animation errored
	for _,o in ipairs(loaderObjs)do pcall(function()o:Remove()end)end
	table.clear(loaderObjs)
	state.loaderDone=true
end

local function hideLoader()
	for _,o in ipairs(loaderObjs)do pcall(function()o:Remove()end)end
	table.clear(loaderObjs)
	state.loaderDone=false
end

local confettiObjs={}
local confettiActive=false
local CONFETTI_COLORS={
	Color3.fromRGB(255,100,200),Color3.fromRGB(100,220,255),
	Color3.fromRGB(255,220,80),Color3.fromRGB(120,255,140),
	Color3.fromRGB(200,140,255),Color3.fromRGB(255,140,100),
}

local function startConfetti()
	if confettiActive then return end
	confettiActive=true
	task.spawn(function()
		local particles={}
		while confettiActive and state.currentTheme=="confetti" do
			-- spawn a new particle every few frames
			if #particles<40 then
				local px=state.wx+math.random(0,WW)
				local py=state.wy-math.random(5,15)
				local col=CONFETTI_COLORS[math.random(1,#CONFETTI_COLORS)]
				local sz=math.random(2,5)
				local o=Drawing.new("Square")
				o.Position=V2(px,py)
				o.Size=V2(sz,sz)
				o.Color=col
				o.Filled=true
				o.Transparency=1
				o.ZIndex=1
				o.Visible=state.visible
				table.insert(confettiObjs,o)
				table.insert(particles,{obj=o,x=px,y=py,vx=(math.random()-0.5)*1.5,vy=math.random()*1.5+0.5,life=0,maxLife=math.random(40,90)})
			end
			-- update particles
			local i=1
			while i<=#particles do
				local p=particles[i]
				p.life=p.life+1
				p.x=p.x+p.vx
				p.y=p.y+p.vy
				local alpha=1-p.life/p.maxLife
				if alpha<=0 or p.life>=p.maxLife then
					pcall(function()p.obj:Remove()end)
					for j,co in ipairs(confettiObjs)do
						if co==p.obj then table.remove(confettiObjs,j);break end
					end
					table.remove(particles,i)
				else
					pcall(function()
						p.obj.Position=V2(p.x,p.y)
						p.obj.Transparency=alpha
						p.obj.Visible=state.visible
					end)
					i=i+1
				end
			end
			task.wait(0.03)
		end
		-- cleanup remaining
		for _,p in ipairs(particles)do pcall(function()p.obj:Remove()end)end
		for _,o in ipairs(confettiObjs)do pcall(function()o:Remove()end)end
		table.clear(confettiObjs)
		confettiActive=false
	end)
end

local function stopConfetti()
	confettiActive=false
end

-- hook into applyTheme to auto-start/stop confetti
local _origApplyTheme=applyTheme
applyTheme=function(name)
	_origApplyTheme(name)
	if name=="confetti" then startConfetti()
	else stopConfetti() end
end

-- Rounded pill: cross rects + filled circles at corners
local function drawPillFill(sqFn,ciFn,x,y,w,h,col,zi)
	local r=8
	sqFn(x+r,y,w-r*2,h,col,true,zi)
	sqFn(x,y+r,w,h-r*2,col,true,zi)
	ciFn(x+r,y+r,r,col,true,zi)
	ciFn(x+w-r,y+r,r,col,true,zi)
	ciFn(x+r,y+h-r,r,col,true,zi)
	ciFn(x+w-r,y+h-r,r,col,true,zi)
end

local function drawPillBorder(lnFn,x,y,w,h,col,zi)
	local r=8
	lnFn(x+r,y,x+w-r,y,col,1,zi)
	lnFn(x+r,y+h,x+w-r,y+h,col,1,zi)
	lnFn(x,y+r,x,y+h-r,col,1,zi)
	lnFn(x+w,y+r,x+w,y+h-r,col,1,zi)
end

local function wPillFill(x,y,w,h,col,zi)drawPillFill(wSq,wCi,x,y,w,h,col,zi)end
local function wPillBorder(x,y,w,h,col,zi)drawPillBorder(wLn,x,y,w,h,col,zi)end
local function tPillFill(x,y,w,h,col,zi)drawPillFill(tSq,tCi,x,y,w,h,col,zi)end
local function tPillBorder(x,y,w,h,col,zi)drawPillBorder(tLn,x,y,w,h,col,zi)end

local function pill(x,y,w,h,zi)
	tPillFill(x,y,w,h,C.CONTENT,zi or 3)
	tPillBorder(x,y,w,h,C.BORDER,(zi or 3)+1)
end

local function divln(x,y,w,zi)tLn(x,y,x+w,y,C.DIV,1,zi or 5)end
local function secLbl(x,y,w,txt,zi)
	tTx(txt,x+PAD,y+4,C.GRAY,FSX,false,zi or 5)
	tLn(x,y+18,x+w,y+18,C.DIV,1,(zi or 5)-1)
end

-- Toggle: pill-shaped with circle end caps for smooth rounding
local function togDraw(x,y,on,zi)
	local z=zi or 6
	local col=on and C.ON or C.OFF
	-- pill body: center rect + 2 circle end caps (w=32 h=16, r=8)
	local r=8
	local bg1=tSq(x+r,y,32-r*2,16,col,true,z)
	local bg2=tSq(x,y+r,32,16-r*2,col,true,z)
	tCi(x+r,y+r,r,col,true,z)
	tCi(x+32-r,y+r,r,col,true,z)
	tCi(x+r,y+16-r,r,col,true,z)
	tCi(x+32-r,y+16-r,r,col,true,z)
	-- dot
	local dot=tCi(x+(on and 24 or 8),y+8,6,on and C.ONDOT or C.OFFDOT,true,z+2)
	return bg1,bg2,dot
end

-- Slider: track + fill rect + knob circle (ONE circle only, no ring)
local function sliderDraw(x,y,w,val,mn,mx,zi)
	local z=zi or 6
	local pct=clamp((val-mn)/(mx-mn),0,1)
	local fw=math.max(2,math.floor(w*pct))
	tSq(x,y,w,5,C.DIMGRAY,true,z)
	local fill=tSq(x,y,fw,5,C.ACCENT,true,z+1)
	local knob=tCi(x+fw,y+2,8,C.ONDOT,true,z+2)
	return fill,knob
end

local DDH=26
local DTH=30
local PTH=30

local function itemH(it)
	if it.type=="slider" then return SRH
	elseif it.type=="dropdown" then return DDH*(1+#(it.options or{})) + PTH
	elseif it.type=="debug" then return DTH
	elseif it.type=="profiletag" then return PTH
	else return RH end
end

local function groupItems(items)
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
		else
			i=i+1
		end
	end
	return groups
end

local function calcWH()
	local maxH=0
	for _,tab in ipairs(state.tabs)do
		local left,right={},{}
		for _,it in ipairs(tab.items or{})do
			if it.col==2 then table.insert(right,it)
			else table.insert(left,it) end
		end
		local function colH(citems)
			local h=0
			for _,grp in ipairs(groupItems(citems))do
				local f=grp[1]
				if f.type=="section" then h=h+22
				elseif f.type=="debug" then h=h+DTH
				else
					local ph=0
					for _,it in ipairs(grp)do ph=ph+itemH(it) end
					h=h+ph+8
				end
			end
			return h
		end
		local h=math.max(colH(left),colH(right))+16
		if h>maxH then maxH=h end
	end
	return math.max(200,maxH)+TH+TAH+10
end

local function buildWindow()
	for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
	table.clear(objs)
	local wx,wy=state.wx,state.wy
	local wh=calcWH()
	state.wh=wh
	-- main bg pill
	wPillFill(wx,wy,WW,wh,C.SIDEBAR,1)
	wPillBorder(wx,wy,WW,wh,C.BORDER,2)
	-- topbar fill (use cross rects, no circles)
	wSq(wx+5,wy,WW-10,TH,C.TOPBAR,true,2)
	wSq(wx,wy+5,WW,TH-5,C.TOPBAR,true,2)
	win.tLine=wLn(wx,wy+TH,wx+WW,wy+TH,C.BORDER,1,3)
	win.t1=wTx("Check",wx+PAD+2,wy+7,C.WHITE,FS,false,4)
	win.t2=wTx("·",wx+PAD+60,wy+7,C.BORDER,FS,false,4)
	win.t3=wTx("It",wx+PAD+72,wy+7,C.ACCENT,FS,false,4)
	win.t4=wTx("·",wx+PAD+90,wy+7,C.BORDER,FS,false,4)
	win.t5=wTx("v2",wx+PAD+102,wy+9,C.GRAY,FSS,false,4)
	win.kLbl=wTx("menu key",wx+WW-128,wy+9,C.GRAY,FSX,false,4)
	win.kBg=wSq(wx+WW-70,wy+6,64,18,C.DIMGRAY,true,3)
	win.kBr=wSq(wx+WW-70,wy+6,64,18,C.BORDER,false,4)
	win.kTx=wTx(state.menuKeyLabel,wx+WW-38,wy+8,C.ONDOT,FSX,true,5)
	win.tabBg=wSq(wx,wy+TH,WW,TAH,C.TOPBAR,true,2)
	win.tabLn=wLn(wx,wy+TH+TAH,wx+WW,wy+TH+TAH,C.BORDER,1,3)
	win.colDiv=wLn(wx+CW,wy+TH+TAH,wx+CW,wy+wh,C.BORDER,1,2)
	state.built=true
end

local function setVis(v)
	for _,o in ipairs(objs)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(tabObjs)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(actObjs)do pcall(function()o.Visible=v end)end
end

local function clearAct()
	for _,o in ipairs(actObjs)do pcall(function()o:Remove()end)end
	table.clear(actObjs)
	table.clear(elements)
end

local function clearTabBtns()
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
	table.clear(tabObjs)
end

local function buildTabs()
	clearTabBtns()
	if not state.built then return end
	local wx,wy=state.wx,state.wy
	local tx=wx+PAD
	local ty=wy+TH+2
	local names={}
	for _,t in ipairs(state.tabs)do table.insert(names,t.name)end
	table.insert(names,"settings")
	for i,name in ipairs(names)do
		local tw=math.max(60,#name*8+14)
		local isA=state.activeTab and state.activeTab.name==name
		local bx=i==#names and wx+WW-tw-PAD or tx
		tbSq(bx,ty,tw,TAH-2,isA and C.TABSEL or C.TOPBAR,true,3)
		if isA then tbLn(bx,ty+TAH-2,bx+tw,ty+TAH-2,C.ACCENT,2,4)end
		tbTx(name,bx+tw/2,ty+3,isA and C.WHITE or C.GRAY,FSX,true,5)
		table.insert(tabObjs,{_c={x=bx,y=ty,w=tw,h=TAH-2,name=name}})
		if i<#names then tx=tx+tw+2 end
	end
end

local function renderSettings()
	local wx,wy=state.wx,state.wy
	local cy=wy+TH+TAH+8
	local sx=wx+PAD
	local sw=WW-PAD*2
	-- keybinds section
	secLbl(sx,cy,sw,"keybinds",5)
	local ky=cy+22
	pill(sx,ky,sw,46,4)
	tTx("menu key",sx+PAD+4,ky+14,C.WHITE,FSX,false,6)
	local kbx=sx+sw-138
	tSq(kbx,ky+12,66,22,C.DIMGRAY,true,6)
	tSq(kbx,ky+12,66,22,C.BORDER,false,7)
	local kbt=tTx(state.menuKeyLabel,kbx+33,ky+14,C.ONDOT,FSX,true,8)
	local rbx=kbx+72
	tSq(rbx,ky+12,46,22,C.DIMGRAY,true,6)
	tSq(rbx,ky+12,46,22,C.BORDER,false,7)
	local rbt=tTx("rebind",rbx+23,ky+14,C.GRAY,FSX,true,8)
	table.insert(elements,{type="rebind",x=rbx,y=ky+12,w=46,h=22,kd=kbt,rt=rbt})
	-- keybind hint
	tTx("click rebind then press any key to change the menu toggle",sx+PAD,ky+48,C.GRAY,10,false,5)
	-- themes section
	local ty=ky+68
	secLbl(sx,ty,sw,"themes",5)
	local tpy=ty+22
	local thH=DDH*#THEME_NAMES+6
	pill(sx,tpy,sw,thH,4)
	local tiy=tpy+3
	local thOptEls={}
	for ti,tn in ipairs(THEME_NAMES)do
		local isSel=(tn==state.currentTheme)
		local tbg=tSq(sx+4,tiy,sw-8,DDH,isSel and C.TABSEL or C.CONTENT,true,5)
		if ti<#THEME_NAMES then divln(sx+4,tiy+DDH,sw-8,6)end
		-- color swatch circle
		local swCol=THEMES[tn] and THEMES[tn].ACCENT or C.ACCENT
		tCi(sx+PAD+12,tiy+DDH/2,5,swCol,true,7)
		local ttx=tTx(tn,sx+PAD+26,tiy+6,isSel and C.ONDOT or C.GRAY,FSX,false,7)
		if isSel then tTx("active",sx+sw-60,tiy+6,C.ACCENT,FSX,false,7)end
		table.insert(thOptEls,{bg=tbg,tx=ttx,name=tn,x=sx+4,y=tiy,w=sw-8,h=DDH})
		tiy=tiy+DDH
	end
	table.insert(elements,{type="theme",optEls=thOptEls,x=sx,y=tpy,w=sw,h=thH})
	-- danger zone section
	local dy=tpy+thH+10
	secLbl(sx,dy,sw,"danger zone",5)
	local dby=dy+22
	pill(sx,dby,sw,44,4)
	tTx("destroy menu",sx+PAD+4,dby+9,C.WHITE,FSX,false,6)
	tTx("unloads the menu permanently",sx+PAD+4,dby+22,C.GRAY,FSX,false,6)
	tSq(sx+sw-72,dby+10,64,24,Color3.fromRGB(40,10,10),true,6)
	tSq(sx+sw-72,dby+10,64,24,Color3.fromRGB(72,22,22),false,7)
	local dtxt=tTx("destroy",sx+sw-40,dby+15,Color3.fromRGB(220,80,80),FSX,true,8)
	table.insert(elements,{type="destroy",x=sx+sw-72,y=dby+10,w=64,h=24,txt=dtxt})
end

local function renderCol(colX,colW,items,startY)
	local cur=startY
	local innerW=colW-PAD*2
	local maxChars=math.floor((innerW-PAD*2-46)/8)
	local px=colX+PAD
	local pw=innerW

	local function drawItems(pitems,iy)
		for _,it in ipairs(pitems)do
			if it.type=="toggle"then
				tSq(px,iy,pw,RH,C.ROWBG,true,5)
				divln(px,iy+RH,pw,6)
				tTx(trunc(it.label,maxChars),px+PAD+4,iy+7,C.WHITE,FSX,false,7)
				if it.rowvalue then
					tTx(it.rowvalue,px+pw-52,iy+8,C.GRAY,FSX,false,7)
				end
				local bg1,bg2,dot=togDraw(px+pw-42,iy+7,it.value,7)
				table.insert(elements,{
					type="toggle",x=px+pw-42,y=iy+7,w=32,h=16,
					bg1=bg1,bg2=bg2,dot=dot,on=it.value,id=it.id
				})
				if it.callback then state.tCbs[it.id]=it.callback end
				iy=iy+RH
			elseif it.type=="slider"then
				tSq(px,iy,pw,SRH,C.MINIBAR,true,5)
				divln(px,iy+SRH,pw,6)
				local slx=px+PAD+4
				local slw=pw-PAD*2-8
				tTx(trunc(it.label,math.floor(maxChars*0.6)),slx,iy+6,C.GRAY,FSX,false,7)
				local vstr=tostring(math.floor(it.value*10+0.5)/10)..(it.suffix)
				local vtx=tTx(vstr,px+pw-PAD-4,iy+6,C.WHITE,FSX,false,7)
				local fill,knob=sliderDraw(slx,iy+28,slw,it.value,it.min,it.max,7)
				table.insert(elements,{
					type="slider",
					x=slx-6,y=iy+18,w=slw+12,h=26,
					fill=fill,knob=knob,
					min=it.min,max=it.max,value=it.value,
					id=it.id,vtx=vtx,suffix=it.suffix,
					slx=slx,slw=slw,ky=iy+30
				})
				if it.callback then state.sCbs[it.id]=it.callback end
				iy=iy+SRH
			elseif it.type=="dropdown"then
				local ddStart=iy
				tSq(px,iy,pw,DDH,C.ROWBG,true,5)
				divln(px,iy+DDH,pw,6)
				tTx(it.label or "preset",px+PAD+4,iy+6,C.WHITE,FSX,false,7)
				local selName=it.selected or (it.options and it.options[1]) or ""
				local valTx=tTx("v "..selName,px+pw-PAD-4,iy+6,C.ACCENT,FSX,false,7)
				iy=iy+DDH
				local optEls={}
				for _,opt in ipairs(it.options or{})do
					local isSel=(opt==selName)
					local obg=tSq(px,iy,pw,DDH,isSel and C.TABSEL or C.CONTENT,true,5)
					divln(px,iy+DDH,pw,6)
					local otx=tTx(opt,px+PAD+4,iy+6,isSel and C.ONDOT or C.GRAY,FSX,false,7)
					table.insert(optEls,{bg=obg,tx=otx,name=opt,x=px,y=iy,w=pw,h=DDH})
					iy=iy+DDH
				end
				tSq(px,iy,pw,PTH,C.CONTENT,true,5)
				divln(px,iy+PTH,pw,6)
				tSq(px+PAD,iy+5,#selName*8+16,20,C.DIMGRAY,true,6)
				tSq(px+PAD,iy+5,#selName*8+16,20,C.BORDER,false,7)
				local tagTx=tTx(selName,px+PAD+8,iy+8,C.ACCENT,FSX,false,8)
				iy=iy+PTH
				table.insert(elements,{
					type="dropdown",id=it.id,
					x=px,y=ddStart,w=pw,h=iy-ddStart,
					valTx=valTx,tagTx=tagTx,
					options=it.options,selected=selName,
					optEls=optEls,callback=it.callback
				})
			end
		end
	end

	local groups=groupItems(items)
	for _,grp in ipairs(groups)do
		local f=grp[1]
		if f.type=="section"then
			secLbl(colX,cur,colW,f.label,5)
			cur=cur+22
		elseif f.type=="debug"then
			local dx=colX+PAD+4
			local dy=cur+8
			local hbDot=tCi(dx+3,dy+3,3,C.ACCENT,true,5)
			local dtxt=f.text or "session active"
			tTx(dtxt,dx+14,dy-2,C.GRAY,FSX,false,5)
			tTx("v2.0",dx+14+#dtxt*7+6,dy-2,C.ACCENT,FSX,false,5)
			-- heartbeat pulsing dot
			task.spawn(function()
				while hbDot and state.visible and state.built do
					-- pulse: grow to 5, shrink to 3, pause
					for _,r in ipairs({4,5,4,3,4,5,4,3})do
						pcall(function()hbDot.Radius=r end)
						task.wait(0.12)
					end
					task.wait(0.6)
				end
			end)
			cur=cur+DTH
		else
			local ph=0
			for _,it in ipairs(grp)do ph=ph+itemH(it)end
			tPillFill(px,cur,pw,ph,C.CONTENT,4)
			tPillBorder(px,cur,pw,ph,C.BORDER,5)
			drawItems(grp,cur)
			cur=cur+ph+8
		end
	end
end

local function renderTabContent(tab)
	if tab.name=="settings"then renderSettings();return end
	local wx,wy=state.wx,state.wy
	local cy=wy+TH+TAH+6
	local left,right={},{}
	for _,it in ipairs(tab.items or{})do
		if it.col==2 then table.insert(right,it)
		else table.insert(left,it)end
	end
	renderCol(wx,CW,left,cy)
	renderCol(wx+CW,WW-CW,right,cy)
end

local function renderTab(tab)
	if not tab or not state.built then clearAct();return end
	-- fade out old content
	if #actObjs>0 then
		for i=8,0,-1 do
			local a=i/8
			for _,o in ipairs(actObjs)do pcall(function()o.Transparency=a end)end
			task.wait(0.012)
		end
	end
	clearAct()
	renderTabContent(tab)
	-- fade in new content
	for _,o in ipairs(actObjs)do pcall(function()o.Transparency=0 end)end
	for i=0,8 do
		local a=i/8
		for _,o in ipairs(actObjs)do pcall(function()o.Transparency=a end)end
		task.wait(0.012)
	end
end

local function fullRebuild()
	if not state.loaderDone then return end
	buildWindow()
	buildTabs()
	renderTab(state.activeTab)
end

-- nudge moves ALL drawing objects by delta without recreating anything
local function nudgeAll(dx,dy)
	local dv=V2(dx,dy)
	local function mv(o)
		local ok,t=pcall(function()return o.Position end)
		if ok and t then
			o.Position=t+dv
		else
			pcall(function()o.From=o.From+dv end)
			pcall(function()o.To=o.To+dv end)
		end
	end
	for _,o in ipairs(objs)do pcall(mv,o)end
	for _,o in ipairs(actObjs)do pcall(mv,o)end
	for _,o in ipairs(tabObjs)do
		if o.Remove then pcall(mv,o)end
		if o._c then
			o._c.x=o._c.x+dx
			o._c.y=o._c.y+dy
		end
	end
	for _,el in ipairs(elements)do
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

local dSlider=nil
local pressed=false

local function doDrag(mx)
	if not dSlider then return end
	local el=dSlider
	local pct=clamp((mx-el.slx)/el.slw,0,1)
	local val=math.floor((el.min+(el.max-el.min)*pct)*10+0.5)/10
	el.value=val
	local fw=math.max(2,math.floor(el.slw*pct))
	pcall(function()el.fill.Size=V2(fw,5)end)
	pcall(function()el.knob.Position=V2(el.slx+fw,el.ky)end)
	el.vtx.Text=tostring(val)..el.suffix
	local cb=state.sCbs[el.id]
	if cb then pcall(cb,val)end
end

local function doClick(mx,my)
	for _,el in ipairs(elements)do
		if el.type=="toggle" and inside(mx,my,el.x,el.y,el.w,el.h)then
			el.on=not el.on
			local col=el.on and C.ON or C.OFF
			pcall(function()el.bg1.Color=col end)
			pcall(function()el.bg2.Color=col end)
			pcall(function()el.dot.Color=el.on and C.ONDOT or C.OFFDOT end)
			pcall(function()el.dot.Position=V2(el.x+(el.on and 24 or 8),el.y+8)end)
			local cb=state.tCbs[el.id]
			if cb then pcall(cb,el.on)end
			return
		elseif el.type=="rebind" and inside(mx,my,el.x,el.y,el.w,el.h)then
			state.rebinding=true;state.rebindTarget=el
			state._rebindAnim=true
			pcall(function()el.rt.Text=".";el.rt.Color=C.ACCENT end)
			pcall(function()el.kd.Text=".";el.kd.Color=C.ACCENT end)
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
		elseif el.type=="dropdown" and el.optEls then
			for _,opt in ipairs(el.optEls)do
				if inside(mx,my,opt.x,opt.y,opt.w,opt.h) and opt.name~=el.selected then
					el.selected=opt.name
					for _,tab in ipairs(state.tabs)do
						for _,it in ipairs(tab.items or{})do
							if it.type=="dropdown" and it.id==el.id then it.selected=opt.name end
						end
					end
					if el.callback then pcall(el.callback,opt.name)end
					renderTab(state.activeTab)
					return
				end
			end
		elseif el.type=="theme" and el.optEls then
			for _,opt in ipairs(el.optEls)do
				if inside(mx,my,opt.x,opt.y,opt.w,opt.h) and opt.name~=state.currentTheme then
					applyTheme(opt.name)
					fullRebuild()
					return
				end
			end
		elseif el.type=="destroy" and inside(mx,my,el.x,el.y,el.w,el.h)then
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
			for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
			for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
			for _,o in ipairs(actObjs)do pcall(function()o:Remove()end)end
			notify("Menu destroyed","Check It v2",3)
			return
		end
	end
	for _,to in ipairs(tabObjs)do
		if to._c and inside(mx,my,to._c.x,to._c.y,to._c.w,to._c.h)then
			local n=to._c.name
			if n=="settings"then state.activeTab={name="settings",items={}}
			else for _,t in ipairs(state.tabs)do if t.name==n then state.activeTab=t;break end end end
			buildTabs();renderTab(state.activeTab)
			return
		end
	end
end

UIS.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if state.rebinding then
		local kc=inp.KeyCode
		local kn=tostring(kc):gsub("Enum%.KeyCode%.","")
		if kn=="Unknown" then
			kn=tostring(inp.UserInputType):gsub("Enum%.UserInputType%.","")
			state.menuKeyCode=nil
			state.menuKeyType=inp.UserInputType
		else
			state.menuKeyCode=kc
			state.menuKeyType=nil
		end
		state.menuKeyLabel=kn
		pcall(function()win.kTx.Text=kn end)
		if state.rebindTarget then
			pcall(function()
				state.rebindTarget.kd.Text=kn
				state.rebindTarget.kd.Color=C.ONDOT
				state.rebindTarget.rt.Text="rebind"
				state.rebindTarget.rt.Color=C.GRAY
			end)
		end
		state.rebinding=false;state.rebindTarget=nil
		if state._rebindAnim then state._rebindAnim=false end
		return
	end
	local match=false
	if state.menuKeyCode then
		match=(inp.KeyCode==state.menuKeyCode)
	elseif state.menuKeyType then
		match=(inp.UserInputType==state.menuKeyType)
	end
	if match then
		state.visible=not state.visible
		setVis(state.visible)
	end
end)

spawn(function()
	local wasDragging=false
	while true do
		task.wait(0.016)
		if state.visible then
			local mx,my=mouse.X,mouse.Y
			local m1=ismouse1pressed()
			if m1 and not pressed then
				pressed=true
				local wx,wy=state.wx,state.wy
				if inside(mx,my,wx,wy,WW,TH) and not inside(mx,my,wx+WW-160,wy,160,TH)then
					state.dragging=true
					wasDragging=false
					state.dragox=mx
					state.dragoy=my
				elseif inside(mx,my,wx,wy,WW,state.wh)then
					local fs=false
					for _,el in ipairs(elements)do
						if el.type=="slider" and inside(mx,my,el.x,el.y,el.w,el.h)then
							dSlider=el;fs=true;break
						end
					end
					if not fs then doClick(mx,my)end
				end
			elseif m1 and pressed then
				if state.dragging then
					local dx=mx-state.dragox
					local dy=my-state.dragoy
					if dx~=0 or dy~=0 then
						state.wx=state.wx+dx
						state.wy=state.wy+dy
						state.dragox=mx
						state.dragoy=my
						wasDragging=true
						nudgeAll(dx,dy)
					end
				elseif dSlider then
					doDrag(mx)
				end
			elseif not m1 then
				wasDragging=false
				pressed=false
				state.dragging=false
				dSlider=nil
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
		fullRebuild()
		local t={}
		function t:Section(label)
			table.insert(tab.items,{type="section",label=label})
			local s={}
			function s:Toggle(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="toggle",label=opts.label,value=opts.default or false,id=id,callback=opts.callback,col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then fullRebuild()end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="toggle" and el.id==id then
							el.on=v
							local col=v and C.ON or C.OFF
							pcall(function()el.bg1.Color=col end)
							pcall(function()el.bg2.Color=col end)
							pcall(function()el.dot.Color=v and C.ONDOT or C.OFFDOT end)
							pcall(function()el.dot.Position=V2(el.x+(v and 24 or 8),el.y+8)end)
						end
					end
				end
				return ctrl
			end
			function s:Slider(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="slider",label=opts.label,value=opts.default or opts.min,min=opts.min,max=opts.max,suffix=opts.suffix or"",id=id,callback=opts.callback,col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then fullRebuild()end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="slider" and el.id==id then
							local pct=clamp((v-el.min)/(el.max-el.min),0,1)
							local fw=math.max(2,math.floor(el.slw*pct))
							el.value=v
							pcall(function()el.fill.Size=V2(fw,5)end)
							pcall(function()el.knob.Position=V2(el.slx+fw,el.ky)end)
							el.vtx.Text=tostring(v)..el.suffix
						end
					end
				end
				return ctrl
			end
			function s:Dropdown(opts)
				local id=opts.id or opts.label
				local sel=opts.default or (opts.options and opts.options[1]) or ""
				table.insert(tab.items,{type="dropdown",label=opts.label,options=opts.options or{},selected=sel,id=id,callback=opts.callback,col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then fullRebuild()end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="dropdown" and el.id==id then
							el.selected=v
							for _,t2 in ipairs(state.tabs)do
								for _,it in ipairs(t2.items or{})do
									if it.type=="dropdown" and it.id==id then it.selected=v end
								end
							end
							renderTab(state.activeTab)
						end
					end
				end
				return ctrl
			end
			function s:DebugRow(opts)
				table.insert(tab.items,{type="debug",text=opts.text or "session active",col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then fullRebuild()end
			end
			return s
		end
		function t:SettingsTab()
			state.activeTab={name="settings",items={}}
			buildTabs();renderTab(state.activeTab)
		end
		return t
	end
	task.spawn(function()
		-- wait for user script to finish adding tabs/items
		task.wait(0.1)
		-- compute actual menu height before showing loader
		state.wh=calcWH()
		showLoader()
		-- wait for loader animation to finish
		while not state.loaderDone do task.wait(0.05) end
		-- build the menu
		fullRebuild()
		-- hide everything first (Transparency 0 = invisible in Drawing API)
		for _,o in ipairs(objs)do pcall(function()o.Transparency=0 end)end
		for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o.Transparency=0 end end)end
		for _,o in ipairs(actObjs)do pcall(function()o.Transparency=0 end)end
		-- fade in: 0→1 (invisible→visible)
		for i=1,10 do
			local a=i/10
			for _,o in ipairs(objs)do pcall(function()o.Transparency=a end)end
			for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o.Transparency=a end end)end
			for _,o in ipairs(actObjs)do pcall(function()o.Transparency=a end)end
			task.wait(0.03)
		end
	end)
	return w
end

function lib:Destroy()
	stopConfetti()
	for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
	for _,o in ipairs(actObjs)do pcall(function()o:Remove()end)end
	for _,o in ipairs(loaderObjs)do pcall(function()o:Remove()end)end
	for _,o in ipairs(confettiObjs)do pcall(function()o:Remove()end)end
	table.clear(objs);table.clear(tabObjs);table.clear(actObjs);table.clear(loaderObjs);table.clear(confettiObjs)
end

_G.lib=lib
