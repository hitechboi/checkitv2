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
local FONTSZ=13
local FONTSZ_SM=11
local FONTSZ_XS=10
local TOPBAR_H=28
local TABS_H=22
local ROW_H=26
local PAD=10
local COL_W=330
local WIN_H=500

local objects={}
local tabObjs={}
local activeTabObjs={}
local elements={}
local win={}

local state={
	visible=true,
	dragging=false,
	dragox=0,dragoy=0,
	wx=SX/2-330,wy=SY/2-220,
	ww=660,
	activeTab=nil,
	tabs={},
	menuKeyLabel="INSERT",
	toggleCallbacks={},
	sliderCallbacks={},
	rebinding=false,
	rebindTarget=nil,
	built=false,
}

local function clamp(v,a,b)return math.max(a,math.min(b,v))end
local function inside(x,y,rx,ry,rw,rh)return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh end

local function D(t,p)
	local o=Drawing.new(t)
	for k,v in pairs(p)do o[k]=v end
	table.insert(objects,o)
	return o
end

local function tD(t,p)
	local o=Drawing.new(t)
	for k,v in pairs(p)do o[k]=v end
	table.insert(activeTabObjs,o)
	return o
end

local function tabD(t,p)
	local o=Drawing.new(t)
	for k,v in pairs(p)do o[k]=v end
	table.insert(tabObjs,o)
	return o
end

local function mkRect(pool,x,y,w,h,col,filled,zi)
	return pool("Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=1,Filled=filled==nil and true or filled,ZIndex=zi or 1,Visible=state.visible})
end
local function mkLine(pool,x1,y1,x2,y2,col,thick,zi)
	return pool("Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 1,Visible=state.visible})
end
local function mkText(pool,txt,x,y,col,sz,center,zi)
	return pool("Text",{Text=tostring(txt),Position=Vector2.new(x,y),Color=col,Size=sz or FONTSZ,Font=FONT,Center=center or false,Outline=false,Transparency=1,ZIndex=zi or 2,Visible=state.visible})
end

local function wRect(x,y,w,h,col,filled,zi)return mkRect(D,x,y,w,h,col,filled,zi)end
local function wLine(x1,y1,x2,y2,col,thick,zi)return mkLine(D,x1,y1,x2,y2,col,thick,zi)end
local function wText(txt,x,y,col,sz,center,zi)return mkText(D,txt,x,y,col,sz,center,zi)end

local function tRect(x,y,w,h,col,filled,zi)return mkRect(tD,x,y,w,h,col,filled,zi)end
local function tLine(x1,y1,x2,y2,col,thick,zi)return mkLine(tD,x1,y1,x2,y2,col,thick,zi)end
local function tText(txt,x,y,col,sz,center,zi)return mkText(tD,txt,x,y,col,sz,center,zi)end

local function drawToggle(x,y,on,zi)
	local bg=tRect(x,y,30,15,on and C.ON or C.OFF,true,zi or 5)
	local bdr=tRect(x,y,30,15,C.BORDER,false,(zi or 5)+1)
	local dot=tRect(x+(on and 17 or 3),y+3,10,10,on and C.ONDOT or C.OFFDOT,true,(zi or 5)+2)
	return bg,bdr,dot
end

local function drawSlider(x,y,w,val,mn,mx,zi)
	local pct=clamp((val-mn)/(mx-mn),0,1)
	local fw=math.max(0,w*pct)
	local bg=tRect(x,y,w,4,C.DIMGRAY,true,zi or 5)
	local fill=tRect(x,y,math.max(1,fw),4,C.ON,true,(zi or 5)+1)
	local knob=tRect(x+fw-6,y-4,12,12,C.ONDOT,true,(zi or 5)+2)
	local kbdr=tRect(x+fw-6,y-4,12,12,C.ACCENT,false,(zi or 5)+3)
	return bg,fill,knob,kbdr
end

local function pillBorder(x,y,w,h,zi)
	tRect(x,y,w,h,C.CONTENT,true,zi or 3)
	tRect(x,y,w,h,C.BORDER,false,(zi or 3)+1)
end

local function sectionLabel(x,y,w,txt,zi)
	tText(txt,x+PAD,y+5,C.GRAY,FONTSZ_XS,false,zi or 4)
	tLine(x,y+18,x+w,y+18,C.DIV,1,zi or 3)
end

local function buildWindow()
	local wx,wy,ww=state.wx,state.wy,state.ww
	win.bg=wRect(wx,wy,ww,WIN_H,C.SIDEBAR,true,1)
	win.border=wRect(wx,wy,ww,WIN_H,C.BORDER,false,2)
	win.topbar=wRect(wx,wy,ww,TOPBAR_H,C.TOPBAR,true,2)
	win.topbarBorder=wLine(wx,wy+TOPBAR_H,wx+ww,wy+TOPBAR_H,C.BORDER,1,3)
	win.title1=wText("Check",wx+PAD,wy+7,C.WHITE,FONTSZ,false,4)
	win.titleDot1=wText(".",wx+PAD+46,wy+7,C.BORDER,FONTSZ,false,4)
	win.title2=wText("It",wx+PAD+58,wy+7,C.ACCENT,FONTSZ,false,4)
	win.titleDot2=wText(".",wx+PAD+74,wy+7,C.BORDER,FONTSZ,false,4)
	win.title3=wText("v2",wx+PAD+86,wy+9,C.GRAY,FONTSZ_SM,false,4)
	win.keyLabel=wText("menu key",wx+ww-115,wy+8,C.GRAY,FONTSZ_XS,false,4)
	win.keyBadgeBg=wRect(wx+ww-58,wy+5,52,18,C.DIMGRAY,true,3)
	win.keyBadgeBorder=wRect(wx+ww-58,wy+5,52,18,C.BORDER,false,4)
	win.keyBadgeText=wText(state.menuKeyLabel,wx+ww-32,wy+8,C.ONDOT,FONTSZ_XS,true,5)
	win.tabsBg=wRect(wx,wy+TOPBAR_H,ww,TABS_H,C.TOPBAR,true,2)
	win.tabsBorder=wLine(wx,wy+TOPBAR_H+TABS_H,wx+ww,wy+TOPBAR_H+TABS_H,C.BORDER,1,3)
	win.colDiv=wLine(wx+COL_W,wy+TOPBAR_H+TABS_H,wx+COL_W,wy+WIN_H,C.BORDER,1,2)
	state.built=true
end

local function setAllVisible(v)
	for _,o in ipairs(objects)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(tabObjs)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(activeTabObjs)do pcall(function()o.Visible=v end)end
end

local function clearActiveTab()
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
	local ty=wy+TOPBAR_H+3
	local names={}
	for _,tab in ipairs(state.tabs)do table.insert(names,tab.name)end
	table.insert(names,"settings")
	for i,name in ipairs(names)do
		local tw=math.max(60,#name*7+16)
		local isActive=state.activeTab and state.activeTab.name==name
		local bx=tx
		if i==#names then bx=wx+ww-tw-PAD end
		tabD("Square",{Position=Vector2.new(bx,ty),Size=Vector2.new(tw,TABS_H-3),Color=isActive and C.TABSEL or C.TOPBAR,Transparency=1,Filled=true,ZIndex=3,Visible=state.visible})
		if isActive then
			tabD("Line",{From=Vector2.new(bx,ty+TABS_H-3),To=Vector2.new(bx+tw,ty+TABS_H-3),Color=C.ACCENT,Thickness=2,Transparency=1,ZIndex=4,Visible=state.visible})
		end
		tabD("Text",{Text=name,Position=Vector2.new(bx+tw/2,ty+4),Color=isActive and C.WHITE or C.GRAY,Size=FONTSZ_XS,Font=FONT,Center=true,Outline=false,Transparency=1,ZIndex=4,Visible=state.visible})
		local cl={x=bx,y=ty,w=tw,h=TABS_H-3,name=name}
		table.insert(tabObjs,{_click=cl})
		if i<#names then tx=tx+tw+2 end
	end
end

local function renderSettings()
	local wx,wy,ww=state.wx,state.wy,state.ww
	local cy=wy+TOPBAR_H+TABS_H
	local sx=wx+PAD
	local sw=ww-PAD*2
	sectionLabel(sx,cy+4,sw,"keybinds",4)
	local ky=cy+24
	pillBorder(sx,ky,sw,46,4)
	tText("menu key",sx+PAD,ky+14,C.WHITE,FONTSZ_XS,false,5)
	local kbx=sx+sw-128
	tRect(kbx,ky+12,62,20,C.DIMGRAY,true,5)
	tRect(kbx,ky+12,62,20,C.BORDER,false,6)
	local kbt=tText(state.menuKeyLabel,kbx+31,ky+14,C.ONDOT,FONTSZ_XS,true,7)
	local rbx=kbx+68
	tRect(rbx,ky+12,40,20,C.DIMGRAY,true,5)
	tRect(rbx,ky+12,40,20,C.BORDER,false,6)
	local rbt=tText("rebind",rbx+20,ky+14,C.GRAY,FONTSZ_XS,true,7)
	table.insert(elements,{type="rebind",x=rbx,y=ky+12,w=40,h=20,keyDisplay=kbt,rebindText=rbt})
	local dy=ky+56
	sectionLabel(sx,dy,sw,"danger zone",4)
	local dby=dy+24
	pillBorder(sx,dby,sw,44,4)
	tText("destroy menu",sx+PAD,dby+8,C.WHITE,FONTSZ_XS,false,5)
	tText("unloads the menu permanently",sx+PAD,dby+20,C.GRAY,FONTSZ_XS,false,5)
	tRect(sx+sw-66,dby+10,58,22,Color3.fromRGB(40,10,10),true,5)
	tRect(sx+sw-66,dby+10,58,22,Color3.fromRGB(72,22,22),false,6)
	tText("destroy",sx+sw-37,dby+14,Color3.fromRGB(220,80,80),FONTSZ_XS,true,7)
	table.insert(elements,{type="destroy",x=sx+sw-66,y=dby+10,w=58,h=22})
end

local function renderCol(colX,colW,colItems,startY)
	local cur=startY
	local pillItems={}
	local pillStart=nil

	local function flushPill()
		if #pillItems==0 then return end
		local ph=0
		for _,pit in ipairs(pillItems)do
			if pit.type=="toggle"then ph=ph+ROW_H
			elseif pit.type=="slider"then ph=ph+40
			end
		end
		local px=colX+PAD
		local pw=colW-PAD*2
		pillBorder(px,pillStart,pw,ph,4)
		local iy=pillStart
		for _,pit in ipairs(pillItems)do
			if pit.type=="toggle"then
				tRect(px,iy,pw,ROW_H,C.ROWBG,true,4)
				tLine(px,iy+ROW_H,px+pw,iy+ROW_H,C.DIV,1,4)
				tText(pit.label,px+PAD,iy+7,C.WHITE,FONTSZ_XS,false,5)
				local tbg,tbdr,tdot=drawToggle(px+pw-36,iy+5,pit.value,5)
				table.insert(elements,{type="toggle",x=px+pw-36,y=iy+5,w=30,h=15,bg=tbg,bdr=tbdr,dot=tdot,on=pit.value,id=pit.id})
				if pit.callback then state.toggleCallbacks[pit.id]=pit.callback end
				iy=iy+ROW_H
			elseif pit.type=="slider"then
				tRect(px,iy,pw,40,C.MINIBAR,true,4)
				tLine(px,iy+40,px+pw,iy+40,C.DIV,1,4)
				local valStr=tostring(math.floor(pit.value*10+0.5)/10)..(pit.suffix or"")
				tText(pit.label,px+PAD,iy+5,C.GRAY,FONTSZ_XS,false,5)
				local valTxt=tText(valStr,px+pw-PAD,iy+5,C.WHITE,FONTSZ_XS,false,5)
				local slx=px+PAD
				local slw=pw-PAD*2
				local sbg,sfill,sknob,skbdr=drawSlider(slx,iy+24,slw,pit.value,pit.min,pit.max,5)
				table.insert(elements,{type="slider",x=slx,y=iy+16,w=slw,h=24,sbg=sbg,sfill=sfill,sknob=sknob,skbdr=skbdr,
					min=pit.min,max=pit.max,value=pit.value,id=pit.id,valTxt=valTxt,suffix=pit.suffix or"",slx=slx,slw=slw})
				if pit.callback then state.sliderCallbacks[pit.id]=pit.callback end
				iy=iy+40
			end
		end
		cur=pillStart+ph+6
		table.clear(pillItems)
		pillStart=nil
	end

	for _,it in ipairs(colItems)do
		if it.type=="section"then
			flushPill()
			sectionLabel(colX,cur,colW,it.label,4)
			cur=cur+20
		elseif it.type=="toggle" or it.type=="slider"then
			if not pillStart then pillStart=cur end
			table.insert(pillItems,it)
		end
	end
	flushPill()
end

local function renderTab(tab)
	clearActiveTab()
	if not tab or not state.built then return end
	local wx,wy,ww=state.wx,state.wy,state.ww
	local cy=wy+TOPBAR_H+TABS_H+2
	if tab.name=="settings"then
		renderSettings()
		return
	end
	local leftItems={}
	local rightItems={}
	for _,it in ipairs(tab.items or{})do
		if it.col==2 then table.insert(rightItems,it)
		else table.insert(leftItems,it)end
	end
	renderCol(wx,COL_W,leftItems,cy)
	renderCol(wx+COL_W,ww-COL_W,rightItems,cy)
end

local function reposition()
	if not state.built then return end
	local wx,wy,ww=state.wx,state.wy,state.ww
	win.bg.Position=Vector2.new(wx,wy);win.bg.Size=Vector2.new(ww,WIN_H)
	win.border.Position=Vector2.new(wx,wy);win.border.Size=Vector2.new(ww,WIN_H)
	win.topbar.Position=Vector2.new(wx,wy);win.topbar.Size=Vector2.new(ww,TOPBAR_H)
	win.topbarBorder.From=Vector2.new(wx,wy+TOPBAR_H);win.topbarBorder.To=Vector2.new(wx+ww,wy+TOPBAR_H)
	win.title1.Position=Vector2.new(wx+PAD,wy+7)
	win.titleDot1.Position=Vector2.new(wx+PAD+46,wy+7)
	win.title2.Position=Vector2.new(wx+PAD+58,wy+7)
	win.titleDot2.Position=Vector2.new(wx+PAD+74,wy+7)
	win.title3.Position=Vector2.new(wx+PAD+86,wy+9)
	win.keyLabel.Position=Vector2.new(wx+ww-115,wy+8)
	win.keyBadgeBg.Position=Vector2.new(wx+ww-58,wy+5)
	win.keyBadgeBorder.Position=Vector2.new(wx+ww-58,wy+5)
	win.keyBadgeText.Position=Vector2.new(wx+ww-32,wy+8)
	win.tabsBg.Position=Vector2.new(wx,wy+TOPBAR_H);win.tabsBg.Size=Vector2.new(ww,TABS_H)
	win.tabsBorder.From=Vector2.new(wx,wy+TOPBAR_H+TABS_H);win.tabsBorder.To=Vector2.new(wx+ww,wy+TOPBAR_H+TABS_H)
	win.colDiv.From=Vector2.new(wx+COL_W,wy+TOPBAR_H+TABS_H);win.colDiv.To=Vector2.new(wx+COL_W,wy+WIN_H)
	buildTabs()
	renderTab(state.activeTab)
end

local draggingSlider=nil
local pressed=false

local function handleSliderDrag(mx)
	if not draggingSlider then return end
	local el=draggingSlider
	local pct=clamp((mx-el.slx)/el.slw,0,1)
	local val=el.min+(el.max-el.min)*pct
	val=math.floor(val*10+0.5)/10
	el.value=val
	local fw=math.max(1,el.slw*pct)
	pcall(function()el.sfill.Size=Vector2.new(fw,4)end)
	pcall(function()el.sknob.Position=Vector2.new(el.slx+fw-6,el.sknob.Position.Y)end)
	pcall(function()el.skbdr.Position=Vector2.new(el.slx+fw-6,el.skbdr.Position.Y)end)
	el.valTxt.Text=tostring(math.floor(val*10+0.5)/10)..(el.suffix)
	local cb=state.sliderCallbacks[el.id]
	if cb then pcall(cb,val)end
end

local function handleClick(mx,my)
	for _,el in ipairs(elements)do
		if el.type=="toggle" and inside(mx,my,el.x,el.y,el.w,el.h)then
			el.on=not el.on
			pcall(function()el.bg.Color=el.on and C.ON or C.OFF end)
			pcall(function()el.dot.Color=el.on and C.ONDOT or C.OFFDOT end)
			pcall(function()el.dot.Position=Vector2.new(el.x+(el.on and 17 or 3),el.y+3)end)
			local cb=state.toggleCallbacks[el.id]
			if cb then pcall(cb,el.on)end
			return
		elseif el.type=="rebind" and inside(mx,my,el.x,el.y,el.w,el.h)then
			state.rebinding=true
			state.rebindTarget=el
			pcall(function()el.rebindText.Text="...";el.rebindText.Color=C.ACCENT end)
			pcall(function()el.keyDisplay.Text="...";el.keyDisplay.Color=C.ACCENT end)
			pcall(function()win.keyBadgeText.Text="..."end)
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
		if to._click then
			local cl=to._click
			if inside(mx,my,cl.x,cl.y,cl.w,cl.h)then
				if cl.name=="settings"then
					state.activeTab={name="settings",items={}}
				else
					for _,tab in ipairs(state.tabs)do
						if tab.name==cl.name then state.activeTab=tab;break end
					end
				end
				buildTabs()
				renderTab(state.activeTab)
				return
			end
		end
	end
end

UIS.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if state.rebinding then
		local kn=tostring(inp.KeyCode):gsub("Enum%.KeyCode%.","")
		if kn=="Unknown"then kn=tostring(inp.UserInputType):gsub("Enum%.UserInputType%.","")end
		state.menuKeyLabel=kn
		pcall(function()win.keyBadgeText.Text=kn end)
		if state.rebindTarget then
			pcall(function()
				state.rebindTarget.keyDisplay.Text=kn
				state.rebindTarget.keyDisplay.Color=C.ONDOT
				state.rebindTarget.rebindText.Text="rebind"
				state.rebindTarget.rebindText.Color=C.GRAY
			end)
		end
		state.rebinding=false
		state.rebindTarget=nil
		return
	end
	if inp.KeyCode==Enum.KeyCode.Insert then
		state.visible=not state.visible
		setAllVisible(state.visible)
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
			if inside(mx,my,wx,wy,ww,TOPBAR_H) and not inside(mx,my,wx+ww-130,wy,130,TOPBAR_H)then
				state.dragging=true
				state.dragox=mx-wx
				state.dragoy=my-wy
			else
				local foundSlider=false
				for _,el in ipairs(elements)do
					if el.type=="slider" and inside(mx,my,el.x,el.y,el.w,el.h)then
						draggingSlider=el
						foundSlider=true
						break
					end
				end
				if not foundSlider then handleClick(mx,my)end
			end
		elseif m1 and pressed then
			if state.dragging then
				state.wx=mx-state.dragox
				state.wy=my-state.dragoy
				reposition()
			elseif draggingSlider then
				handleSliderDrag(mx)
			end
		elseif not m1 then
			pressed=false
			state.dragging=false
			draggingSlider=nil
		end
	end
end)

local lib={}
lib.__index=lib

function lib:Window(title)
	buildWindow()
	local w={}
	function w:Tab(name)
		local tab={name=name,items={}}
		table.insert(state.tabs,tab)
		if #state.tabs==1 then state.activeTab=tab end
		buildTabs()
		renderTab(state.activeTab)
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
							pcall(function()el.dot.Position=Vector2.new(el.x+(v and 17 or 3),el.y+3)end)
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
							local fw=math.max(1,el.slw*pct)
							el.value=v
							pcall(function()el.sfill.Size=Vector2.new(fw,4)end)
							pcall(function()el.sknob.Position=Vector2.new(el.slx+fw-6,el.sknob.Position.Y)end)
							pcall(function()el.skbdr.Position=Vector2.new(el.slx+fw-6,el.skbdr.Position.Y)end)
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
