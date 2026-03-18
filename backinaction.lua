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

local FNT=Drawing.Fonts.Monospace
local FS,FSS,FSX=13,11,10
local TH,TAH,RH,SRH=26,20,26,40
local PAD,CW,WW,CR=10,330,660,6

local objs,tabObjs,actObjs,elements,win={},{},{},{},{}
local allDrawObjs={}

local state={
	visible=true,dragging=false,
	dragox=0,dragoy=0,
	ox=0,oy=0,
	wx=math.floor(SX/2-WW/2),
	wy=math.floor(SY/2-180),
	wh=300,
	activeTab=nil,tabs={},
	menuKeyLabel="INSERT",
	tCbs={},sCbs={},
	rebinding=false,rebindTarget=nil,
	built=false,
}

local function clamp(v,a,b)return math.max(a,math.min(b,v))end
local function inside(x,y,rx,ry,rw,rh)return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh end
local function trunc(s,n)if #s>n then return s:sub(1,n-1).."~"end return s end

local function newObj(pool,typ,props)
	local o=Drawing.new(typ)
	for k,v in pairs(props)do o[k]=v end
	table.insert(pool,o)
	table.insert(allDrawObjs,o)
	return o
end

local function wSq(x,y,w,h,col,filled,zi)
	return newObj(objs,"Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 1,Visible=state.visible})
end
local function wLn(x1,y1,x2,y2,col,thick,zi)
	return newObj(objs,"Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})
end
local function wTx(s,x,y,col,sz,ctr,zi)
	return newObj(objs,"Text",{Text=s,Position=Vector2.new(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})
end
local function wCi(x,y,r,col,filled,zi)
	return newObj(objs,"Circle",{Position=Vector2.new(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=20,ZIndex=zi or 1,Visible=state.visible})
end
local function tSq(x,y,w,h,col,filled,zi)
	return newObj(actObjs,"Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 3,Visible=state.visible})
end
local function tLn(x1,y1,x2,y2,col,thick,zi)
	return newObj(actObjs,"Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function tTx(s,x,y,col,sz,ctr,zi)
	return newObj(actObjs,"Text",{Text=s,Position=Vector2.new(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end
local function tCi(x,y,r,col,filled,zi)
	return newObj(actObjs,"Circle",{Position=Vector2.new(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=20,ZIndex=zi or 3,Visible=state.visible})
end
local function tbSq(x,y,w,h,col,filled,zi)
	return newObj(tabObjs,"Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 3,Visible=state.visible})
end
local function tbLn(x1,y1,x2,y2,col,thick,zi)
	return newObj(tabObjs,"Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function tbTx(s,x,y,col,sz,ctr,zi)
	return newObj(tabObjs,"Text",{Text=s,Position=Vector2.new(x,y),Color=col,Size=sz or FS,Font=FNT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end

local function rFill(fn,fnCi,x,y,w,h,col,zi)
	local r=CR
	fn(x+r,y,w-r*2,h,col,true,zi)
	fn(x,y+r,w,h-r*2,col,true,zi)
	fnCi(x+r,y+r,r,col,true,zi)
	fnCi(x+w-r,y+r,r,col,true,zi)
	fnCi(x+r,y+h-r,r,col,true,zi)
	fnCi(x+w-r,y+h-r,r,col,true,zi)
end
local function rBorder(fnCi,fnLn,x,y,w,h,col,zi)
	local r=CR
	fnLn(x+r,y,x+w-r,y,col,1,zi)
	fnLn(x+r,y+h,x+w-r,y+h,col,1,zi)
	fnLn(x,y+r,x,y+h-r,col,1,zi)
	fnLn(x+w,y+r,x+w,y+h-r,col,1,zi)
	fnCi(x+r,y+r,r,col,false,zi)
	fnCi(x+w-r,y+r,r,col,false,zi)
	fnCi(x+r,y+h-r,r,col,false,zi)
	fnCi(x+w-r,y+h-r,r,col,false,zi)
end

local function wRF(x,y,w,h,col,zi)rFill(wSq,wCi,x,y,w,h,col,zi)end
local function wRB(x,y,w,h,col,zi)rBorder(wCi,wLn,x,y,w,h,col,zi)end
local function tRF(x,y,w,h,col,zi)rFill(tSq,tCi,x,y,w,h,col,zi)end
local function tRB(x,y,w,h,col,zi)rBorder(tCi,tLn,x,y,w,h,col,zi)end

local function pill(x,y,w,h,zi)
	tRF(x,y,w,h,C.CONTENT,zi or 3)
	tRB(x,y,w,h,C.BORDER,(zi or 3)+1)
end

local function divln(x,y,w,zi)tLn(x,y,x+w,y,C.DIV,1,zi or 5)end
local function secLbl(x,y,w,txt,zi)
	tTx(txt,x+PAD,y+4,C.GRAY,FSX,false,zi or 5)
	tLn(x,y+17,x+w,y+17,C.DIV,1,(zi or 5)-1)
end

local function togDraw(x,y,on,zi)
	local z=zi or 6
	local bg=tSq(x,y,28,14,on and C.ON or C.OFF,true,z)
	tSq(x,y,28,14,C.BORDER,false,z+1)
	local dot=tCi(x+(on and 21 or 7),y+7,5,on and C.ONDOT or C.OFFDOT,true,z+2)
	return bg,dot
end

local function sliderDraw(x,y,w,val,mn,mx,zi)
	local z=zi or 6
	local pct=clamp((val-mn)/(mx-mn),0,1)
	local fw=math.max(2,w*pct)
	tSq(x,y,w,4,C.DIMGRAY,true,z)
	local fill=tSq(x,y,fw,4,C.ON,true,z+1)
	local knob=tCi(x+fw,y+2,6,C.ONDOT,true,z+2)
	tCi(x+fw,y+2,6,C.ACCENT,false,z+3)
	return fill,knob
end

local function calcWH()
	local maxH=0
	for _,tab in ipairs(state.tabs)do
		local lH,rH,lP,rP=0,0,0,0
		for _,it in ipairs(tab.items or{})do
			local c=it.col or 1
			local rh=it.type=="slider" and SRH or RH
			if it.type=="section"then
				if c==2 then if rP>0 then rH=rH+rP+8;rP=0 end;rH=rH+19
				else if lP>0 then lH=lH+lP+8;lP=0 end;lH=lH+19 end
			elseif it.type=="toggle" or it.type=="slider"then
				if c==2 then rP=rP+rh else lP=lP+rh end
			end
		end
		if lP>0 then lH=lH+lP+8 end
		if rP>0 then rH=rH+rP+8 end
		local h=math.max(lH,rH)+12
		if h>maxH then maxH=h end
	end
	return math.max(180,maxH)+TH+TAH+8
end

local function buildWindow()
	for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
	table.clear(objs)
	local wx,wy=state.wx,state.wy
	local wh=calcWH()
	state.wh=wh
	wRF(wx,wy,WW,wh,C.SIDEBAR,1)
	wRB(wx,wy,WW,wh,C.BORDER,2)
	wSq(wx+CR,wy,WW-CR*2,TH,C.TOPBAR,true,2)
	wSq(wx,wy+CR,WW,TH-CR,C.TOPBAR,true,2)
	win.tLine=wLn(wx,wy+TH,wx+WW,wy+TH,C.BORDER,1,3)
	win.t1=wTx("Check",wx+PAD+2,wy+6,C.WHITE,FS,false,4)
	win.t2=wTx("·",wx+PAD+54,wy+6,C.BORDER,FS,false,4)
	win.t3=wTx("It",wx+PAD+66,wy+6,C.ACCENT,FS,false,4)
	win.t4=wTx("·",wx+PAD+82,wy+6,C.BORDER,FS,false,4)
	win.t5=wTx("v2",wx+PAD+94,wy+8,C.GRAY,FSS,false,4)
	win.kLbl=wTx("menu key",wx+WW-120,wy+8,C.GRAY,FSX,false,4)
	win.kBg=wSq(wx+WW-64,wy+5,58,16,C.DIMGRAY,true,3)
	win.kBr=wSq(wx+WW-64,wy+5,58,16,C.BORDER,false,4)
	win.kTx=wTx(state.menuKeyLabel,wx+WW-35,wy+7,C.ONDOT,FSX,true,5)
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
		local tw=math.max(54,#name*7+12)
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
	local cy=wy+TH+TAH+6
	local sx=wx+PAD
	local sw=WW-PAD*2
	secLbl(sx,cy,sw,"keybinds",5)
	local ky=cy+19
	pill(sx,ky,sw,44,4)
	tTx("menu key",sx+PAD+4,ky+14,C.WHITE,FSX,false,6)
	local kbx=sx+sw-132
	tSq(kbx,ky+12,64,20,C.DIMGRAY,true,6)
	tSq(kbx,ky+12,64,20,C.BORDER,false,7)
	local kbt=tTx(state.menuKeyLabel,kbx+32,ky+14,C.ONDOT,FSX,true,8)
	local rbx=kbx+70
	tSq(rbx,ky+12,44,20,C.DIMGRAY,true,6)
	tSq(rbx,ky+12,44,20,C.BORDER,false,7)
	local rbt=tTx("rebind",rbx+22,ky+14,C.GRAY,FSX,true,8)
	table.insert(elements,{type="rebind",x=rbx,y=ky+12,w=44,h=20,kd=kbt,rt=rbt})
	local dy=ky+54
	secLbl(sx,dy,sw,"danger zone",5)
	local dby=dy+19
	pill(sx,dby,sw,42,4)
	tTx("destroy menu",sx+PAD+4,dby+8,C.WHITE,FSX,false,6)
	tTx("unloads the menu permanently",sx+PAD+4,dby+20,C.GRAY,FSX,false,6)
	tSq(sx+sw-70,dby+9,62,24,Color3.fromRGB(40,10,10),true,6)
	tSq(sx+sw-70,dby+9,62,24,Color3.fromRGB(72,22,22),false,7)
	tTx("destroy",sx+sw-39,dby+14,Color3.fromRGB(220,80,80),FSX,true,8)
	table.insert(elements,{type="destroy",x=sx+sw-70,y=dby+9,w=62,h=24})
end

local function renderCol(colX,colW,items,startY)
	local cur=startY
	local pItems,pStart={},nil
	local innerW=colW-PAD*2
	local maxChars=math.floor((innerW-PAD*2-42)/7)

	local function flush()
		if #pItems==0 then return end
		local ph=0
		for _,it in ipairs(pItems)do ph=ph+(it.type=="slider" and SRH or RH)end
		local px=colX+PAD
		local pw=innerW
		local iy=pStart
		for _,it in ipairs(pItems)do
			if it.type=="toggle"then
				tSq(px,iy,pw,RH,C.ROWBG,true,5)
				divln(px,iy+RH,pw,5)
				tTx(trunc(it.label,maxChars),px+PAD+4,iy+7,C.WHITE,FSX,false,6)
				local bg,dot=togDraw(px+pw-38,iy+6,it.value,6)
				table.insert(elements,{type="toggle",x=px+pw-38,y=iy+6,w=28,h=14,bg=bg,dot=dot,on=it.value,id=it.id})
				if it.callback then state.tCbs[it.id]=it.callback end
				iy=iy+RH
			elseif it.type=="slider"then
				tSq(px,iy,pw,SRH,C.MINIBAR,true,5)
				divln(px,iy+SRH,pw,5)
				local slx=px+PAD+4
				local slw=pw-PAD*2-8
				tTx(trunc(it.label,math.floor(maxChars*0.55)),slx,iy+5,C.GRAY,FSX,false,6)
				local vstr=tostring(math.floor(it.value*10+0.5)/10)..(it.suffix)
				local vtx=tTx(vstr,px+pw-PAD-4,iy+5,C.WHITE,FSX,false,6)
				local fill,knob=sliderDraw(slx,iy+24,slw,it.value,it.min,it.max,6)
				table.insert(elements,{type="slider",x=slx-4,y=iy+16,w=slw+8,h=22,fill=fill,knob=knob,min=it.min,max=it.max,value=it.value,id=it.id,vtx=vtx,suffix=it.suffix,slx=slx,slw=slw,ky=iy+26})
				if it.callback then state.sCbs[it.id]=it.callback end
				iy=iy+SRH
			end
		end
		tRF(px,pStart,pw,ph,C.CONTENT,4)
		tRB(px,pStart,pw,ph,C.BORDER,5)
		cur=pStart+ph+8
		table.clear(pItems)
		pStart=nil
	end

	for _,it in ipairs(items)do
		if it.type=="section"then
			flush()
			secLbl(colX,cur,colW,it.label,5)
			cur=cur+19
		elseif it.type=="toggle" or it.type=="slider"then
			if not pStart then pStart=cur end
			table.insert(pItems,it)
		end
	end
	flush()
end

local function renderTab(tab)
	clearAct()
	if not tab or not state.built then return end
	if tab.name=="settings"then renderSettings();return end
	local wx,wy=state.wx,state.wy
	local cy=wy+TH+TAH+4
	local left,right={},{}
	for _,it in ipairs(tab.items or{})do
		if it.col==2 then table.insert(right,it)
		else table.insert(left,it)end
	end
	renderCol(wx,CW,left,cy)
	renderCol(wx+CW,WW-CW,right,cy)
end

local function fullRebuild()
	buildWindow()
	buildTabs()
	renderTab(state.activeTab)
end

local function nudgeAll(dx,dy)
	local function mv(o)
		if o.Position then o.Position=o.Position+Vector2.new(dx,dy)
		elseif o.From then
			o.From=o.From+Vector2.new(dx,dy)
			o.To=o.To+Vector2.new(dx,dy)
		end
	end
	for _,o in ipairs(objs)do pcall(mv,o)end
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then mv(o)end end)end
	for _,o in ipairs(actObjs)do pcall(mv,o)end
	for _,el in ipairs(elements)do
		el.x=el.x+dx;el.y=el.y+dy
		if el.slx then el.slx=el.slx+dx end
		if el.ky then el.ky=el.ky+dy end
	end
	for _,to in ipairs(tabObjs)do
		if to._c then
			to._c.x=to._c.x+dx
			to._c.y=to._c.y+dy
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
	local fw=math.max(2,el.slw*pct)
	pcall(function()el.fill.Size=Vector2.new(fw,4)end)
	pcall(function()el.knob.Position=Vector2.new(el.slx+fw,el.ky)end)
	el.vtx.Text=tostring(val)..el.suffix
	local cb=state.sCbs[el.id]
	if cb then pcall(cb,val)end
end

local function doClick(mx,my)
	for _,el in ipairs(elements)do
		if el.type=="toggle" and inside(mx,my,el.x,el.y,el.w,el.h)then
			el.on=not el.on
			pcall(function()el.bg.Color=el.on and C.ON or C.OFF end)
			pcall(function()el.dot.Color=el.on and C.ONDOT or C.OFFDOT end)
			pcall(function()el.dot.Position=Vector2.new(el.x+(el.on and 21 or 7),el.y+7)end)
			local cb=state.tCbs[el.id]
			if cb then pcall(cb,el.on)end
			return
		elseif el.type=="rebind" and inside(mx,my,el.x,el.y,el.w,el.h)then
			state.rebinding=true;state.rebindTarget=el
			pcall(function()el.rt.Text="...";el.rt.Color=C.ACCENT end)
			pcall(function()el.kd.Text="...";el.kd.Color=C.ACCENT end)
			pcall(function()win.kTx.Text="..."end)
			return
		elseif el.type=="destroy" and inside(mx,my,el.x,el.y,el.w,el.h)then
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
		local kn=tostring(inp.KeyCode):gsub("Enum%.KeyCode%.","")
		if kn=="Unknown"then kn=tostring(inp.UserInputType):gsub("Enum%.UserInputType%.","")end
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
		return
	end
	if inp.KeyCode==Enum.KeyCode.Insert then
		state.visible=not state.visible
		setVis(state.visible)
	end
end)

spawn(function()
	while true do
		task.wait(0.016)
		if not state.visible then continue end
		local mx,my=mouse.X,mouse.Y
		local m1=ismouse1pressed()
		if m1 and not pressed then
			pressed=true
			local wx,wy=state.wx,state.wy
			if inside(mx,my,wx,wy,WW,TH) and not inside(mx,my,wx+WW-150,wy,150,TH)then
				state.dragging=true
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
					nudgeAll(dx,dy)
				end
			elseif dSlider then
				doDrag(mx)
			end
		elseif not m1 then
			pressed=false
			state.dragging=false
			dSlider=nil
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
							pcall(function()el.bg.Color=v and C.ON or C.OFF end)
							pcall(function()el.dot.Color=v and C.ONDOT or C.OFFDOT end)
							pcall(function()el.dot.Position=Vector2.new(el.x+(v and 21 or 7),el.y+7)end)
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
							local fw=math.max(2,el.slw*pct)
							el.value=v
							pcall(function()el.fill.Size=Vector2.new(fw,4)end)
							pcall(function()el.knob.Position=Vector2.new(el.slx+fw,el.ky)end)
							el.vtx.Text=tostring(v)..el.suffix
						end
					end
				end
				return ctrl
			end
			return s
		end
		return t
	end
	fullRebuild()
	return w
end

function lib:Destroy()
	for _,o in ipairs(objs)do pcall(function()o:Remove()end)end
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
	for _,o in ipairs(actObjs)do pcall(function()o:Remove()end)end
	table.clear(objs);table.clear(tabObjs);table.clear(actObjs)
end

_G.lib=lib
