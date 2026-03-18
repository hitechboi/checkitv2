local UIS=game:GetService("UserInputService")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local mouse=lp:GetMouse()
local function scr()local c=workspace.CurrentCamera;return c.ViewportSize.X,c.ViewportSize.Y end
local SX,SY=scr()

local C={
	ACCENT=Color3.fromRGB(70,120,255),
	BG=Color3.fromRGB(9,11,20),
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

local FONT=Drawing.Fonts.Monospace
local FS=13
local FSS=11
local FSX=10
local TH=28
local TAH=22
local RH=26
local PAD=10
local CW=330
local WH=480
local CR=5

local objects={}
local tabObjs={}
local activeTabObjs={}
local elements={}
local win={}

local state={
	visible=true,dragging=false,
	dragox=0,dragoy=0,
	wx=SX/2-330,wy=SY/2-210,
	ww=660,activeTab=nil,tabs={},
	menuKeyLabel="INSERT",
	toggleCallbacks={},sliderCallbacks={},
	rebinding=false,rebindTarget=nil,built=false,
}

local function clamp(v,a,b)return math.max(a,math.min(b,v))end
local function inside(x,y,rx,ry,rw,rh)return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh end
local function truncate(s,max)return #s>max and s:sub(1,max-1).."." or s end

local function mkObj(pool,t,p)
	local o=Drawing.new(t)
	for k,v in pairs(p)do o[k]=v end
	table.insert(pool,o)
	return o
end

local function wSq(x,y,w,h,col,filled,zi)return mkObj(objects,"Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 1,Visible=state.visible})end
local function wLn(x1,y1,x2,y2,col,thick,zi)return mkObj(objects,"Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})end
local function wTx(str,x,y,col,sz,ctr,zi)return mkObj(objects,"Text",{Text=str,Position=Vector2.new(x,y),Color=col,Size=sz or FS,Font=FONT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})end
local function wCi(x,y,r,col,filled,zi)return mkObj(objects,"Circle",{Position=Vector2.new(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=16,ZIndex=zi or 1,Visible=state.visible})end

local function tSq(x,y,w,h,col,filled,zi)return mkObj(activeTabObjs,"Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 1,Visible=state.visible})end
local function tLn(x1,y1,x2,y2,col,thick,zi)return mkObj(activeTabObjs,"Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})end
local function tTx(str,x,y,col,sz,ctr,zi)return mkObj(activeTabObjs,"Text",{Text=str,Position=Vector2.new(x,y),Color=col,Size=sz or FS,Font=FONT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})end
local function tCi(x,y,r,col,filled,zi)return mkObj(activeTabObjs,"Circle",{Position=Vector2.new(x,y),Radius=r,Color=col,Transparency=1,Filled=filled~=false,Thickness=1,NumSides=16,ZIndex=zi or 1,Visible=state.visible})end

local function tbSq(x,y,w,h,col,filled,zi)return mkObj(tabObjs,"Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled~=false,ZIndex=zi or 1,Visible=state.visible})end
local function tbLn(x1,y1,x2,y2,col,thick,zi)return mkObj(tabObjs,"Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})end
local function tbTx(str,x,y,col,sz,ctr,zi)return mkObj(tabObjs,"Text",{Text=str,Position=Vector2.new(x,y),Color=col,Size=sz or FS,Font=FONT,Center=ctr or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})end

local function tRoundFill(x,y,w,h,col,zi)
	local r=CR
	tSq(x+r,y,w-r*2,h,col,true,zi)
	tSq(x,y+r,w,h-r*2,col,true,zi)
	tCi(x+r,y+r,r,col,true,zi)
	tCi(x+w-r,y+r,r,col,true,zi)
	tCi(x+r,y+h-r,r,col,true,zi)
	tCi(x+w-r,y+h-r,r,col,true,zi)
end
local function tRoundBorder(x,y,w,h,col,zi)
	local r=CR
	tLn(x+r,y,x+w-r,y,col,1,zi)
	tLn(x+r,y+h,x+w-r,y+h,col,1,zi)
	tLn(x,y+r,x,y+h-r,col,1,zi)
	tLn(x+w,y+r,x+w,y+h-r,col,1,zi)
	tCi(x+r,y+r,r,col,false,zi)
	tCi(x+w-r,y+r,r,col,false,zi)
	tCi(x+r,y+h-r,r,col,false,zi)
	tCi(x+w-r,y+h-r,r,col,false,zi)
end
local function wRoundFill(x,y,w,h,col,zi)
	local r=CR
	wSq(x+r,y,w-r*2,h,col,true,zi)
	wSq(x,y+r,w,h-r*2,col,true,zi)
	wCi(x+r,y+r,r,col,true,zi)
	wCi(x+w-r,y+r,r,col,true,zi)
	wCi(x+r,y+h-r,r,col,true,zi)
	wCi(x+w-r,y+h-r,r,col,true,zi)
end
local function wRoundBorder(x,y,w,h,col,zi)
	local r=CR
	wLn(x+r,y,x+w-r,y,col,1,zi)
	wLn(x+r,y+h,x+w-r,y+h,col,1,zi)
	wLn(x,y+r,x,y+h-r,col,1,zi)
	wLn(x+w,y+r,x+w,y+h-r,col,1,zi)
	wCi(x+r,y+r,r,col,false,zi)
	wCi(x+w-r,y+r,r,col,false,zi)
	wCi(x+r,y+h-r,r,col,false,zi)
	wCi(x+w-r,y+h-r,r,col,false,zi)
end

local function pill(x,y,w,h,zi)
	tRoundFill(x,y,w,h,C.CONTENT,zi or 3)
	tRoundBorder(x,y,w,h,C.BORDER,(zi or 3)+1)
end

local function divLine(x,y,w,zi)
	tLn(x,y,x+w,y,C.DIV,1,zi or 4)
end

local function secLabel(x,y,w,txt,zi)
	tTx(txt,x+PAD,y+5,C.GRAY,FSX,false,zi or 4)
	tLn(x,y+18,x+w,y+18,C.DIV,1,(zi or 4)-1)
end

local function drawToggle(x,y,on,zi)
	local bz=zi or 6
	local bg=tSq(x,y,28,14,on and C.ON or C.OFF,true,bz)
	local bdr=tSq(x,y,28,14,C.BORDER,false,bz+1)
	local dot=tCi(x+(on and 19 or 9),y+7,5,on and C.ONDOT or C.OFFDOT,true,bz+2)
	return bg,bdr,dot
end

local function drawSlider(x,y,w,val,mn,mx,zi)
	local sz=zi or 6
	local pct=clamp((val-mn)/(mx-mn),0,1)
	local fw=math.max(2,w*pct)
	tSq(x,y,w,4,C.DIMGRAY,true,sz)
	local fill=tSq(x,y,fw,4,C.ON,true,sz+1)
	local knob=tCi(x+fw,y+2,6,C.ONDOT,true,sz+2)
	local kring=tCi(x+fw,y+2,6,C.ACCENT,false,sz+3)
	return fill,knob,kring
end

local function buildWindow()
	local wx,wy,ww=state.wx,state.wy,state.ww
	wRoundFill(wx,wy,ww,WH,C.SIDEBAR,1)
	wRoundBorder(wx,wy,ww,WH,C.BORDER,2)
	wSq(wx,wy+CR,ww,TH-CR,C.TOPBAR,true,2)
	wSq(wx+CR,wy,ww-CR*2,TH,C.TOPBAR,true,2)
	win.topbar=wSq(wx,wy,ww,TH,C.TOPBAR,true,2)
	win.topbarLine=wLn(wx,wy+TH,wx+ww,wy+TH,C.BORDER,1,3)
	win.t1=wTx("Check",wx+PAD,wy+8,C.WHITE,FS,false,4)
	win.t2=wTx(" · ",wx+PAD+48,wy+8,C.BORDER,FS,false,4)
	win.t3=wTx("It",wx+PAD+68,wy+8,C.ACCENT,FS,false,4)
	win.t4=wTx(" · ",wx+PAD+82,wy+8,C.BORDER,FS,false,4)
	win.t5=wTx("v2",wx+PAD+102,wy+10,C.GRAY,FSS,false,4)
	win.kLabel=wTx("menu key",wx+ww-118,wy+9,C.GRAY,FSX,false,4)
	win.kBadgeBg=wSq(wx+ww-60,wy+6,54,16,C.DIMGRAY,true,3)
	win.kBadgeBr=wSq(wx+ww-60,wy+6,54,16,C.BORDER,false,4)
	win.kBadgeTx=wTx(state.menuKeyLabel,wx+ww-33,wy+8,C.ONDOT,FSX,true,5)
	win.tabsBg=wSq(wx,wy+TH,ww,TAH,C.TOPBAR,true,2)
	win.tabsLine=wLn(wx,wy+TH+TAH,wx+ww,wy+TH+TAH,C.BORDER,1,3)
	win.colDiv=wLn(wx+CW,wy+TH+TAH,wx+CW,wy+WH,C.BORDER,1,2)
	state.built=true
end

local function setAllVis(v)
	for _,o in ipairs(objects)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(tabObjs)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(activeTabObjs)do pcall(function()o.Visible=v end)end
end

local function clearActive()
	for _,o in ipairs(activeTabObjs)do pcall(function()o:Remove()end)end
	table.clear(activeTabObjs)
	table.clear(elements)
end

local function clearTabBtns()
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
	table.clear(tabObjs)
end

local function buildTabs()
	clearTabBtns()
	if not state.built then return end
	local wx,wy,ww=state.wx,state.wy,state.ww
	local tx=wx+PAD
	local ty=wy+TH+2
	local names={}
	for _,t in ipairs(state.tabs)do table.insert(names,t.name)end
	table.insert(names,"settings")
	for i,name in ipairs(names)do
		local tw=math.max(56,#name*7+14)
		local isA=state.activeTab and state.activeTab.name==name
		local bx=i==#names and wx+ww-tw-PAD or tx
		tbSq(bx,ty,tw,TAH-2,isA and C.TABSEL or C.TOPBAR,true,3)
		if isA then tbLn(bx,ty+TAH-2,bx+tw,ty+TAH-2,C.ACCENT,2,4)end
		tbTx(name,bx+tw/2,ty+4,isA and C.WHITE or C.GRAY,FSX,true,4)
		table.insert(tabObjs,{_click={x=bx,y=ty,w=tw,h=TAH-2,name=name}})
		if i<#names then tx=tx+tw+2 end
	end
end

local function renderSettings()
	local wx,wy,ww=state.wx,state.wy,state.ww
	local cy=wy+TH+TAH+6
	local sx=wx+PAD
	local sw=ww-PAD*2
	secLabel(sx,cy,sw,"keybinds",4)
	local ky=cy+20
	pill(sx,ky,sw,44,4)
	tTx("menu key",sx+PAD+4,ky+14,C.WHITE,FSX,false,6)
	local kbx=sx+sw-130
	tSq(kbx,ky+12,64,20,C.DIMGRAY,true,6)
	tSq(kbx,ky+12,64,20,C.BORDER,false,7)
	local kbt=tTx(state.menuKeyLabel,kbx+32,ky+14,C.ONDOT,FSX,true,8)
	local rbx=kbx+70
	tSq(rbx,ky+12,42,20,C.DIMGRAY,true,6)
	tSq(rbx,ky+12,42,20,C.BORDER,false,7)
	local rbt=tTx("rebind",rbx+21,ky+14,C.GRAY,FSX,true,8)
	table.insert(elements,{type="rebind",x=rbx,y=ky+12,w=42,h=20,keyDisplay=kbt,rebindText=rbt})
	local dy=ky+54
	secLabel(sx,dy,sw,"danger zone",4)
	local dby=dy+20
	pill(sx,dby,sw,42,4)
	tTx("destroy menu",sx+PAD+4,dby+8,C.WHITE,FSX,false,6)
	tTx("unloads the menu permanently",sx+PAD+4,dby+20,C.GRAY,FSX,false,6)
	tSq(sx+sw-68,dby+9,60,24,Color3.fromRGB(40,10,10),true,6)
	tSq(sx+sw-68,dby+9,60,24,Color3.fromRGB(72,22,22),false,7)
	tTx("destroy",sx+sw-38,dby+14,Color3.fromRGB(220,80,80),FSX,true,8)
	table.insert(elements,{type="destroy",x=sx+sw-68,y=dby+9,w=60,h=24})
end

local function renderCol(colX,colW,items,startY)
	local cur=startY
	local pItems={}
	local pStart=nil

	local function flush()
		if #pItems==0 then return end
		local ph=0
		for _,it in ipairs(pItems)do
			ph=ph+(it.type=="slider" and 42 or RH)
		end
		local px=colX+PAD
		local pw=colW-PAD*2
		local txtMax=math.floor((pw-PAD*2-40)/7)
		pill(px,pStart,pw,ph,4)
		local iy=pStart
		for _,it in ipairs(pItems)do
			if it.type=="toggle"then
				tSq(px,iy,pw,RH,C.ROWBG,true,4)
				divLine(px,iy+RH,pw,5)
				local lbl=truncate(it.label,txtMax)
				tTx(lbl,px+PAD+4,iy+7,C.WHITE,FSX,false,6)
				local tbg,tbdr,tdot=drawToggle(px+pw-38,iy+6,it.value,6)
				table.insert(elements,{
					type="toggle",x=px+pw-38,y=iy+6,w=28,h=14,
					bg=tbg,bdr=tbdr,dot=tdot,on=it.value,id=it.id
				})
				if it.callback then state.toggleCallbacks[it.id]=it.callback end
				iy=iy+RH
			elseif it.type=="slider"then
				tSq(px,iy,pw,42,C.MINIBAR,true,4)
				divLine(px,iy+42,pw,5)
				local lbl=truncate(it.label,math.floor(txtMax*0.6))
				local valStr=tostring(math.floor(it.value*10+0.5)/10)..(it.suffix or"")
				tTx(lbl,px+PAD+4,iy+5,C.GRAY,FSX,false,6)
				local vtx=tTx(valStr,px+pw-PAD-4,iy+5,C.WHITE,FSX,false,6)
				local slx=px+PAD+4
				local slw=pw-PAD*2-8
				local fill,knob,kring=drawSlider(slx,iy+26,slw,it.value,it.min,it.max,6)
				table.insert(elements,{
					type="slider",x=slx,y=iy+18,w=slw,h=24,
					fill=fill,knob=knob,kring=kring,
					min=it.min,max=it.max,value=it.value,
					id=it.id,valTxt=vtx,suffix=it.suffix or"",
					slx=slx,slw=slw,ky=iy+28
				})
				if it.callback then state.sliderCallbacks[it.id]=it.callback end
				iy=iy+42
			end
		end
		tRoundFill(px,pStart,pw,ph,C.CONTENT,3)
		tRoundBorder(px,pStart,pw,ph,C.BORDER,4)
		cur=pStart+ph+8
		table.clear(pItems)
		pStart=nil
	end

	for _,it in ipairs(items)do
		if it.type=="section"then
			flush()
			secLabel(colX,cur,colW,it.label,4)
			cur=cur+20
		elseif it.type=="toggle" or it.type=="slider"then
			if not pStart then pStart=cur end
			table.insert(pItems,it)
		end
	end
	flush()
end

local function renderTab(tab)
	clearActive()
	if not tab or not state.built then return end
	local wx,wy,ww=state.wx,state.wy,state.ww
	local cy=wy+TH+TAH+4
	if tab.name=="settings"then renderSettings();return end
	local left,right={},{}
	for _,it in ipairs(tab.items or{})do
		if it.col==2 then table.insert(right,it)
		else table.insert(left,it)end
	end
	renderCol(wx,CW,left,cy)
	renderCol(wx+CW,ww-CW,right,cy)
end

local function reposition()
	if not state.built then return end
	local wx,wy,ww=state.wx,state.wy,state.ww
	win.topbar.Position=Vector2.new(wx,wy);win.topbar.Size=Vector2.new(ww,TH)
	win.topbarLine.From=Vector2.new(wx,wy+TH);win.topbarLine.To=Vector2.new(wx+ww,wy+TH)
	win.t1.Position=Vector2.new(wx+PAD,wy+8)
	win.t2.Position=Vector2.new(wx+PAD+48,wy+8)
	win.t3.Position=Vector2.new(wx+PAD+68,wy+8)
	win.t4.Position=Vector2.new(wx+PAD+82,wy+8)
	win.t5.Position=Vector2.new(wx+PAD+102,wy+10)
	win.kLabel.Position=Vector2.new(wx+ww-118,wy+9)
	win.kBadgeBg.Position=Vector2.new(wx+ww-60,wy+6)
	win.kBadgeBr.Position=Vector2.new(wx+ww-60,wy+6)
	win.kBadgeTx.Position=Vector2.new(wx+ww-33,wy+8)
	win.tabsBg.Position=Vector2.new(wx,wy+TH);win.tabsBg.Size=Vector2.new(ww,TAH)
	win.tabsLine.From=Vector2.new(wx,wy+TH+TAH);win.tabsLine.To=Vector2.new(wx+ww,wy+TH+TAH)
	win.colDiv.From=Vector2.new(wx+CW,wy+TH+TAH);win.colDiv.To=Vector2.new(wx+CW,wy+WH)
	buildTabs()
	renderTab(state.activeTab)
end

local draggingSlider=nil
local pressed=false

local function sliderDrag(mx)
	if not draggingSlider then return end
	local el=draggingSlider
	local pct=clamp((mx-el.slx)/el.slw,0,1)
	local val=math.floor((el.min+(el.max-el.min)*pct)*10+0.5)/10
	el.value=val
	local fw=math.max(2,el.slw*pct)
	pcall(function()el.fill.Size=Vector2.new(fw,4)end)
	pcall(function()el.knob.Position=Vector2.new(el.slx+fw,el.ky)end)
	pcall(function()el.kring.Position=Vector2.new(el.slx+fw,el.ky)end)
	el.valTxt.Text=tostring(val)..(el.suffix)
	local cb=state.sliderCallbacks[el.id]
	if cb then pcall(cb,val)end
end

local function onClick(mx,my)
	for _,el in ipairs(elements)do
		if el.type=="toggle" and inside(mx,my,el.x,el.y,el.w,el.h)then
			el.on=not el.on
			pcall(function()el.bg.Color=el.on and C.ON or C.OFF end)
			pcall(function()el.dot.Color=el.on and C.ONDOT or C.OFFDOT end)
			pcall(function()el.dot.Position=Vector2.new(el.x+(el.on and 19 or 9),el.y+7)end)
			local cb=state.toggleCallbacks[el.id]
			if cb then pcall(cb,el.on)end
			return
		elseif el.type=="rebind" and inside(mx,my,el.x,el.y,el.w,el.h)then
			state.rebinding=true;state.rebindTarget=el
			pcall(function()el.rebindText.Text="...";el.rebindText.Color=C.ACCENT end)
			pcall(function()el.keyDisplay.Text="...";el.keyDisplay.Color=C.ACCENT end)
			pcall(function()win.kBadgeTx.Text="..."end)
			return
		elseif el.type=="destroy" and inside(mx,my,el.x,el.y,el.w,el.h)then
			for _,o in ipairs(objects)do pcall(function()o:Remove()end)end
			for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
			for _,o in ipairs(activeTabObjs)do pcall(function()o:Remove()end)end
			notify("Menu destroyed","Check It v2",3)
			return
		end
	end
	for _,to in ipairs(tabObjs)do
		if to._click and inside(mx,my,to._click.x,to._click.y,to._click.w,to._click.h)then
			local n=to._click.name
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
		pcall(function()win.kBadgeTx.Text=kn end)
		if state.rebindTarget then
			pcall(function()
				state.rebindTarget.keyDisplay.Text=kn
				state.rebindTarget.keyDisplay.Color=C.ONDOT
				state.rebindTarget.rebindText.Text="rebind"
				state.rebindTarget.rebindText.Color=C.GRAY
			end)
		end
		state.rebinding=false;state.rebindTarget=nil
		return
	end
	if inp.KeyCode==Enum.KeyCode.Insert then
		state.visible=not state.visible
		setAllVis(state.visible)
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
			local wx,wy,ww=state.wx,state.wy,state.ww
			if inside(mx,my,wx,wy,ww,TH) and not inside(mx,my,wx+ww-140,wy,140,TH)then
				state.dragging=true;state.dragox=mx-wx;state.dragoy=my-wy
			else
				local fs=false
				for _,el in ipairs(elements)do
					if el.type=="slider" and inside(mx,my,el.x,el.y,el.w,el.h)then
						draggingSlider=el;fs=true;break
					end
				end
				if not fs then onClick(mx,my)end
			end
		elseif m1 and pressed then
			if state.dragging then
				state.wx=mx-state.dragox;state.wy=my-state.dragoy;reposition()
			elseif draggingSlider then
				sliderDrag(mx)
			end
		elseif not m1 then
			pressed=false;state.dragging=false;draggingSlider=nil
		end
	end
end)

local lib={}
lib.__index=lib

function lib:Window()
	buildWindow()
	local w={}
	function w:Tab(name)
		local tab={name=name,items={}}
		table.insert(state.tabs,tab)
		if #state.tabs==1 then state.activeTab=tab end
		buildTabs();renderTab(state.activeTab)
		local t={}
		function t:Section(label)
			table.insert(tab.items,{type="section",label=label,col=1})
			local s={}
			function s:Toggle(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="toggle",label=opts.label,value=opts.default or false,id=id,callback=opts.callback,col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then renderTab(tab)end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="toggle" and el.id==id then
							el.on=v
							pcall(function()el.bg.Color=v and C.ON or C.OFF end)
							pcall(function()el.dot.Color=v and C.ONDOT or C.OFFDOT end)
							pcall(function()el.dot.Position=Vector2.new(el.x+(v and 19 or 9),el.y+7)end)
						end
					end
				end
				return ctrl
			end
			function s:Slider(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="slider",label=opts.label,value=opts.default or opts.min,min=opts.min,max=opts.max,suffix=opts.suffix or"",id=id,callback=opts.callback,col=opts.col or 1})
				if state.activeTab and state.activeTab.name==tab.name then renderTab(tab)end
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="slider" and el.id==id then
							local pct=clamp((v-el.min)/(el.max-el.min),0,1)
							local fw=math.max(2,el.slw*pct)
							el.value=v
							pcall(function()el.fill.Size=Vector2.new(fw,4)end)
							pcall(function()el.knob.Position=Vector2.new(el.slx+fw,el.ky)end)
							pcall(function()el.kring.Position=Vector2.new(el.slx+fw,el.ky)end)
							el.valTxt.Text=tostring(v)..(el.suffix)
						end
					end
				end
				return ctrl
			end
			return s
		end
		return t
	end
	return w
end

function lib:Destroy()
	for _,o in ipairs(objects)do pcall(function()o:Remove()end)end
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
	for _,o in ipairs(activeTabObjs)do pcall(function()o:Remove()end)end
	table.clear(objects);table.clear(tabObjs);table.clear(activeTabObjs)
end

_G.lib=lib
