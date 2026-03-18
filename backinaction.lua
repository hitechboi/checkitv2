local UIS=game:GetService("UserInputService")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local mouse=lp:GetMouse()
local function scr()local c=workspace.CurrentCamera;return c.ViewportSize.X,c.ViewportSize.Y end
local SX,SY=scr()

local T={}
T.__index=T

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

local objects={}
local function D(t,p)
	local o=Drawing.new(t)
	for k,v in pairs(p)do o[k]=v end
	table.insert(objects,o)
	return o
end

local function destroy_all()
	for _,o in ipairs(objects)do pcall(function()o:Remove()end)end
	table.clear(objects)
end

local function lerp(a,b,t)return a+(b-a)*t end
local function clamp(v,a,b)return math.max(a,math.min(b,v))end
local function inside(x,y,rx,ry,rw,rh)return x>=rx and x<=rx+rw and y>=ry and y<=ry+rh end

local function mpos()return mouse.X,mouse.Y end
local function m1()return ismouse1pressed()end

local state={
	visible=true,
	dragging=false,
	dragox=0,dragoy=0,
	wx=SX/2-330,wy=SY/2-220,
	ww=660,
	activeTab=nil,
	tabs={},
	menuKey=0x2D,
	menuKeyLabel="INSERT",
	toggleCallbacks={},
	sliderCallbacks={},
	dropdownCallbacks={},
	bindCallbacks={},
	rebinding=false,
	rebindTarget=nil,
}

local TOPBAR_H=28
local TABS_H=22
local ROW_H=26
local PILL_R=6
local PAD=10
local COL_W=330

local function drawRect(x,y,w,h,col,tr,filled,zi)
	return D("Square",{
		Position=Vector2.new(x,y),
		Size=Vector2.new(w,h),
		Color=col,
		Transparency=tr or 1,
		Filled=filled==nil and true or filled,
		ZIndex=zi or 1,
		Visible=state.visible,
	})
end

local function drawLine(x1,y1,x2,y2,col,thick,tr,zi)
	return D("Line",{
		From=Vector2.new(x1,y1),
		To=Vector2.new(x2,y2),
		Color=col,
		Thickness=thick or 1,
		Transparency=tr or 1,
		ZIndex=zi or 1,
		Visible=state.visible,
	})
end

local function drawText(txt,x,y,col,sz,center,outline,zi)
	return D("Text",{
		Text=tostring(txt),
		Position=Vector2.new(x,y),
		Color=col,
		FontSize=sz or FONTSZ,
		Font=FONT,
		Center=center or false,
		Outline=outline or false,
		Transparency=1,
		ZIndex=zi or 2,
		Visible=state.visible,
	})
end

local function drawCircle(x,y,r,col,tr,filled,thick,zi)
	return D("Circle",{
		Position=Vector2.new(x,y),
		Radius=r,
		Color=col,
		Transparency=tr or 1,
		Filled=filled==nil and true or filled,
		Thickness=thick or 1,
		NumSides=20,
		ZIndex=zi or 1,
		Visible=state.visible,
	})
end

local win={}

local function buildWindow()
	local wx,wy,ww=state.wx,state.wy,state.ww
	win.bg=drawRect(wx,wy,ww,500,C.SIDEBAR,1,true,1)
	win.border=drawRect(wx,wy,ww,500,C.BORDER,1,false,2)
	win.topbar=drawRect(wx,wy,ww,TOPBAR_H,C.TOPBAR,1,true,2)
	win.topbarBorder=drawLine(wx,wy+TOPBAR_H,wx+ww,wy+TOPBAR_H,C.BORDER,1,1,3)
	win.title1=drawText("Check",wx+PAD,wy+7,C.WHITE,FONTSZ,false,false,4)
	win.titleDot1=drawText("·",wx+PAD+46,wy+7,C.BORDER,FONTSZ,false,false,4)
	win.title2=drawText("It",wx+PAD+58,wy+7,C.ACCENT,FONTSZ,false,false,4)
	win.titleDot2=drawText("·",wx+PAD+74,wy+7,C.BORDER,FONTSZ,false,false,4)
	win.title3=drawText("v2",wx+PAD+86,wy+9,C.GRAY,FONTSZ_SM,false,false,4)
	win.keyLabel=drawText("menu key",wx+ww-110,wy+8,C.GRAY,FONTSZ_XS,false,false,4)
	win.keyBadgeBg=drawRect(wx+ww-55,wy+5,50,18,C.DIMGRAY,1,true,3)
	win.keyBadgeBorder=drawRect(wx+ww-55,wy+5,50,18,C.BORDER,1,false,4)
	win.keyBadgeText=drawText(state.menuKeyLabel,wx+ww-30,wy+7,C.ONDOT,FONTSZ_XS,true,false,5)
	win.tabsBg=drawRect(wx,wy+TOPBAR_H,ww,TABS_H,C.TOPBAR,1,true,2)
	win.tabsBorder=drawLine(wx,wy+TOPBAR_H+TABS_H,wx+ww,wy+TOPBAR_H+TABS_H,C.BORDER,1,1,3)
	win.colDiv=drawLine(wx+COL_W,wy+TOPBAR_H+TABS_H,wx+COL_W,wy+500,C.BORDER,1,1,2)
end

local tabObjs={}
local activeTabObjs={}

local function clearTabObjs()
	for _,o in ipairs(activeTabObjs)do pcall(function()o:Remove()end)end
	table.clear(activeTabObjs)
end

local function tD(t,p)
	local o=Drawing.new(t)
	for k,v in pairs(p)do o[k]=v end
	table.insert(activeTabObjs,o)
	return o
end

local function tRect(x,y,w,h,col,tr,filled,zi)
	return tD("Square",{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=col,Transparency=tr or 1,Filled=filled==nil and true or filled,ZIndex=zi or 3,Visible=state.visible})
end
local function tLine(x1,y1,x2,y2,col,thick,zi)
	return tD("Line",{From=Vector2.new(x1,y1),To=Vector2.new(x2,y2),Color=col,Thickness=thick or 1,Transparency=1,ZIndex=zi or 3,Visible=state.visible})
end
local function tText(txt,x,y,col,sz,center,zi)
	return tD("Text",{Text=tostring(txt),Position=Vector2.new(x,y),Color=col,FontSize=sz or FONTSZ,Font=FONT,Center=center or false,Outline=false,Transparency=1,ZIndex=zi or 4,Visible=state.visible})
end

local function drawToggle(x,y,on,zi)
	local bg=tRect(x,y,30,15,on and C.ON or C.OFF,1,true,zi or 5)
	local bdr=tRect(x,y,30,15,C.BORDER,1,false,zi and zi+1 or 6)
	local dot=tRect(x+(on and 17 or 3),y+3,10,10,on and C.ONDOT or C.OFFDOT,1,true,zi and zi+2 or 7)
	return bg,bdr,dot
end

local function drawSlider(x,y,w,val,min,max,zi)
	local pct=(val-min)/(max-min)
	local fillW=math.max(0,w*pct)
	local bg=tRect(x,y,w,4,C.DIMGRAY,1,true,zi or 5)
	local fill=tRect(x,y,fillW,4,C.ON,1,true,zi and zi+1 or 6)
	local knob=tRect(x+fillW-6,y-4,12,12,C.ONDOT,1,true,zi and zi+2 or 7)
	local kbdr=tRect(x+fillW-6,y-4,12,12,C.ACCENT,1,false,zi and zi+3 or 8)
	return bg,fill,knob,kbdr,fillW
end

local function pillBorder(x,y,w,h,zi)
	tRect(x,y,w,h,C.CONTENT,1,true,zi or 3)
	tRect(x,y,w,h,C.BORDER,1,false,(zi or 3)+1)
end

local function sectionLabel(x,y,w,txt,zi)
	tText(txt,x+PAD,y+5,C.GRAY,FONTSZ_XS,false,zi or 4)
	tLine(x,y+18,x+w,y+18,C.DIV,1,zi or 3)
end

local function rowBg(x,y,w,zi)
	tRect(x,y,w,ROW_H,C.ROWBG,1,true,zi or 3)
	tLine(x,y+ROW_H,x+w,y+ROW_H,C.DIV,1,(zi or 3)+1)
end

local elements={}

local function renderTab(tab)
	clearTabObjs()
	table.clear(elements)
	if not tab then return end
	local wx,wy,ww=state.wx,state.wy,state.ww
	local cy=wy+TOPBAR_H+TABS_H
	local items=tab.items or {}

	if tab.name=="settings" then
		local sx=wx+PAD
		local sw2=ww-PAD*2
		sectionLabel(sx,cy+2,sw2,"keybinds",4)
		local ky=cy+22
		pillBorder(sx,ky,sw2,50,4)
		tText("menu key",sx+PAD,ky+8,C.WHITE,FONTSZ_XS,false,5)
		local kbx=sx+sw2-120
		tRect(kbx,ky+7,60,18,C.DIMGRAY,1,true,5)
		tRect(kbx,ky+7,60,18,C.BORDER,1,false,6)
		local kbt=tText(state.menuKeyLabel,kbx+30,ky+9,C.ONDOT,FONTSZ_XS,true,7)
		local rbx=kbx+66
		tRect(rbx,ky+7,40,18,C.DIMGRAY,1,true,5)
		tRect(rbx,ky+7,40,18,C.BORDER,1,false,6)
		local rbt=tText("rebind",rbx+20,ky+9,C.GRAY,FONTSZ_XS,true,7)
		table.insert(elements,{type="rebind",x=rbx,y=ky+7,w=40,h=18,keyDisplay=kbt,rebindText=rbt})

		local dy=ky+58
		sectionLabel(sx,dy,sw2,"danger zone",4)
		local dby=dy+22
		pillBorder(sx,dby,sw2,44,4)
		tText("destroy menu",sx+PAD,dby+8,C.WHITE,FONTSZ_XS,false,5)
		tText("unloads the menu permanently",sx+PAD,dby+20,C.GRAY,FONTSZ_XS,false,5)
		tRect(sx+sw2-65,dby+10,58,22,Color3.fromRGB(40,10,10),1,true,5)
		tRect(sx+sw2-65,dby+10,58,22,Color3.fromRGB(72,22,22),1,false,6)
		tText("destroy",sx+sw2-36,dby+14,Color3.fromRGB(220,80,80),FONTSZ_XS,true,7)
		table.insert(elements,{type="destroy",x=sx+sw2-65,y=dby+10,w=58,h=22})

		local thy=dby+52
		sectionLabel(sx,thy,sw2,"themes",4)
		local tby=thy+22
		pillBorder(sx,tby,sw2,38,4)
		tText("theme",sx+PAD,tby+11,C.WHITE,FONTSZ_XS,false,5)
		tText("v  main",sx+sw2-70,tby+11,C.ACCENT,FONTSZ_XS,false,5)
		table.insert(elements,{type="themeDrop",x=sx,y=tby,w=sw2,h=38})
		return
	end

	local lx=wx
	local rx=wx+COL_W
	local lcw=COL_W
	local rcw=ww-COL_W

	local leftItems={}
	local rightItems={}
	for _,it in ipairs(items)do
		if it.col==2 then table.insert(rightItems,it)
		else table.insert(leftItems,it)end
	end

	local function renderCol(colX,colW,colItems,startY)
		local cur=startY
		local pi=nil
		local pillStart=nil
		local pillItems={}

		local function flushPill()
			if #pillItems==0 then return end
			local ph=0
			for _,pit in ipairs(pillItems)do
				if pit.type=="toggle"then ph=ph+ROW_H
				elseif pit.type=="slider"then ph=ph+38
				elseif pit.type=="label"then ph=ph+18
				end
			end
			local px=colX+PAD
			local pw=colW-PAD*2
			pillBorder(px,pillStart,pw,ph,4)
			local iy=pillStart
			for _,pit in ipairs(pillItems)do
				if pit.type=="toggle"then
					tRect(px,iy,pw,ROW_H,Color3.fromRGB(0,0,0),0,true,4)
					tLine(px,iy+ROW_H,px+pw,iy+ROW_H,C.DIV,1,4)
					tText(pit.label,px+PAD,iy+6,C.WHITE,FONTSZ_XS,false,5)
					local tbg,tbdr,tdot=drawToggle(px+pw-36,iy+5,pit.value,5)
					local el={type="toggle",x=px+pw-36,y=iy+5,w=30,h=15,bg=tbg,bdr=tbdr,dot=tdot,on=pit.value,id=pit.id}
					table.insert(elements,el)
					if pit.callback then state.toggleCallbacks[pit.id]=pit.callback end
					iy=iy+ROW_H
				elseif pit.type=="slider"then
					tRect(px,iy,pw,38,Color3.fromRGB(0,0,0),0,true,4)
					tLine(px,iy+38,px+pw,iy+38,C.DIV,1,4)
					local valStr=tostring(pit.value)..(pit.suffix or"")
					tText(pit.label,px+PAD,iy+5,C.GRAY,FONTSZ_XS,false,5)
					local valTxt=tText(valStr,px+pw-PAD,iy+5,C.WHITE,FONTSZ_XS,false,5)
					local slx=px+PAD
					local slw=pw-PAD*2
					local sbg,sfill,sknob,skbdr=drawSlider(slx,iy+22,slw,pit.value,pit.min,pit.max,5)
					local el={type="slider",x=slx,y=iy+14,w=slw,h=20,sbg=sbg,sfill=sfill,sknob=sknob,skbdr=skbdr,
						min=pit.min,max=pit.max,value=pit.value,id=pit.id,valTxt=valTxt,suffix=pit.suffix or"",slx=slx,slw=slw}
					table.insert(elements,el)
					if pit.callback then state.sliderCallbacks[pit.id]=pit.callback end
					iy=iy+38
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
			elseif it.type=="toggle"or it.type=="slider"then
				if not pillStart then
					pillStart=cur
					cur=cur
				end
				table.insert(pillItems,it)
			end
		end
		flushPill()
	end

	renderCol(lx,lcw,leftItems,cy+2)
	renderCol(rx,rcw,rightItems,cy+2)
end

local function buildTabs()
	for _,o in ipairs(tabObjs)do pcall(function()o:Remove()end)end
	table.clear(tabObjs)
	local wx,wy,ww=state.wx,state.wy,state.ww
	local tx=wx+PAD
	local ty=wy+TOPBAR_H+3
	local names={}
	for _,tab in ipairs(state.tabs)do table.insert(names,tab.name)end
	table.insert(names,"settings")
	for i,name in ipairs(names)do
		local tw=math.max(60,#name*8+16)
		local isActive=(state.activeTab and state.activeTab.name==name)or(name=="settings" and state.activeTab and state.activeTab.name=="settings")
		local bg=D("Square",{Position=Vector2.new(tx,ty),Size=Vector2.new(tw,TABS_H-3),Color=isActive and C.TABSEL or C.TOPBAR,Transparency=1,Filled=true,ZIndex=3,Visible=state.visible})
		if isActive then
			D("Line",{From=Vector2.new(tx,ty+TABS_H-3),To=Vector2.new(tx+tw,ty+TABS_H-3),Color=C.ACCENT,Thickness=2,Transparency=1,ZIndex=4,Visible=state.visible})
		end
		local lbl=D("Text",{Text=name,Position=Vector2.new(tx+tw/2,ty+4),Color=isActive and C.WHITE or C.GRAY,FontSize=FONTSZ_XS,Font=FONT,Center=true,Outline=false,Transparency=1,ZIndex=4,Visible=state.visible})
		table.insert(tabObjs,bg)
		table.insert(tabObjs,lbl)
		if i==#names and i>1 then
			local spacer=D("Square",{Position=Vector2.new(wx+ww-tw-PAD,ty),Size=Vector2.new(tw,TABS_H-3),Color=C.TOPBAR,Transparency=1,Filled=true,ZIndex=3,Visible=state.visible})
			spacer.Position=Vector2.new(wx+ww-tw-PAD,ty)
			bg.Position=Vector2.new(wx+ww-tw-PAD,ty)
			lbl.Position=Vector2.new(wx+ww-PAD-tw/2,ty+4)
			local cl={x=wx+ww-tw-PAD,y=ty,w=tw,h=TABS_H-3,name=name}
			table.insert(tabObjs,{_clickable=cl})
		else
			local cl={x=tx,y=ty,w=tw,h=TABS_H-3,name=name}
			table.insert(tabObjs,{_clickable=cl})
			tx=tx+tw+2
		end
	end
end

local function setVisible(v)
	state.visible=v
	for _,o in ipairs(objects)do pcall(function()o.Visible=v end)end
	for _,o in ipairs(tabObjs)do if o.Visible~=nil then o.Visible=v end end
	for _,o in ipairs(activeTabObjs)do pcall(function()o.Visible=v end)end
end

local function reposition()
	local wx,wy,ww=state.wx,state.wy,state.ww
	win.bg.Position=Vector2.new(wx,wy)
	win.bg.Size=Vector2.new(ww,500)
	win.border.Position=Vector2.new(wx,wy)
	win.border.Size=Vector2.new(ww,500)
	win.topbar.Position=Vector2.new(wx,wy)
	win.topbar.Size=Vector2.new(ww,TOPBAR_H)
	win.topbarBorder.From=Vector2.new(wx,wy+TOPBAR_H)
	win.topbarBorder.To=Vector2.new(wx+ww,wy+TOPBAR_H)
	win.title1.Position=Vector2.new(wx+PAD,wy+7)
	win.titleDot1.Position=Vector2.new(wx+PAD+46,wy+7)
	win.title2.Position=Vector2.new(wx+PAD+58,wy+7)
	win.titleDot2.Position=Vector2.new(wx+PAD+74,wy+7)
	win.title3.Position=Vector2.new(wx+PAD+86,wy+9)
	win.keyLabel.Position=Vector2.new(wx+ww-110,wy+8)
	win.keyBadgeBg.Position=Vector2.new(wx+ww-55,wy+5)
	win.keyBadgeBorder.Position=Vector2.new(wx+ww-55,wy+5)
	win.keyBadgeText.Position=Vector2.new(wx+ww-30,wy+7)
	win.tabsBg.Position=Vector2.new(wx,wy+TOPBAR_H)
	win.tabsBg.Size=Vector2.new(ww,TABS_H)
	win.tabsBorder.From=Vector2.new(wx,wy+TOPBAR_H+TABS_H)
	win.tabsBorder.To=Vector2.new(wx+ww,wy+TOPBAR_H+TABS_H)
	win.colDiv.From=Vector2.new(wx+COL_W,wy+TOPBAR_H+TABS_H)
	win.colDiv.To=Vector2.new(wx+COL_W,wy+500)
	buildTabs()
	renderTab(state.activeTab)
end

local draggingSlider=nil
local clickConsumed=false

local function handleClick(mx,my)
	for _,el in ipairs(elements)do
		if el.type=="toggle" and inside(mx,my,el.x,el.y,el.w,el.h)then
			el.on=not el.on
			el.bg.Color=el.on and C.ON or C.OFF
			el.dot.Color=el.on and C.ONDOT or C.OFFDOT
			el.dot.Position=Vector2.new(el.x+(el.on and 17 or 3),el.y+3)
			local cb=state.toggleCallbacks[el.id]
			if cb then cb(el.on)end
			return true
		elseif el.type=="rebind" and inside(mx,my,el.x,el.y,el.w,el.h)then
			state.rebinding=true
			el.rebindText.Text="..."
			el.rebindText.Color=C.ACCENT
			el.keyDisplay.Text="..."
			el.keyDisplay.Color=C.ACCENT
			state.rebindTarget=el
			return true
		elseif el.type=="destroy" and inside(mx,my,el.x,el.y,el.w,el.h)then
			destroy_all()
			notify("Menu destroyed","Check It v2",3)
			return true
		end
	end
	for _,to in ipairs(tabObjs)do
		if to._clickable then
			local cl=to._clickable
			if inside(mx,my,cl.x,cl.y,cl.w,cl.h)then
				if cl.name=="settings"then
					local fakeSTab={name="settings",items={}}
					state.activeTab=fakeSTab
				else
					for _,tab in ipairs(state.tabs)do
						if tab.name==cl.name then state.activeTab=tab break end
					end
				end
				buildTabs()
				renderTab(state.activeTab)
				return true
			end
		end
	end
	return false
end

local function handleSliderDrag(mx)
	if not draggingSlider then return end
	local el=draggingSlider
	local pct=clamp((mx-el.slx)/el.slw,0,1)
	local val=el.min+(el.max-el.min)*pct
	val=math.floor(val*10+0.5)/10
	el.value=val
	local fillW=math.max(0,el.slw*pct)
	el.sfill.Size=Vector2.new(fillW,4)
	el.sknob.Position=Vector2.new(el.slx+fillW-6,el.sknob.Position.Y)
	el.skbdr.Position=Vector2.new(el.slx+fillW-6,el.skbdr.Position.Y)
	el.valTxt.Text=tostring(math.floor(val*10+0.5)/10)..(el.suffix or"")
	local cb=state.sliderCallbacks[el.id]
	if cb then cb(val)end
end

local running=true
UIS.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if state.rebinding then
		local kc=inp.KeyCode
		local kn=tostring(kc):gsub("Enum.KeyCode.","")
		state.menuKeyLabel=kn
		win.keyBadgeText.Text=kn
		if state.rebindTarget then
			state.rebindTarget.keyDisplay.Text=kn
			state.rebindTarget.keyDisplay.Color=C.ONDOT
			state.rebindTarget.rebindText.Text="rebind"
			state.rebindTarget.rebindText.Color=C.GRAY
		end
		state.rebinding=false
		state.rebindTarget=nil
		return
	end
	if inp.KeyCode==Enum.KeyCode.Insert then
		setVisible(not state.visible)
	end
end)

spawn(function()
	while running do
		local mx,my=mpos()
		if m1()then
			if not clickConsumed then
				clickConsumed=true
				if state.visible then
					local wx,wy,ww=state.wx,state.wy,state.ww
					if inside(mx,my,wx,wy,ww,TOPBAR_H)and not inside(mx,my,wx+ww-120,wy,120,TOPBAR_H)then
						state.dragging=true
						state.dragox=mx-wx
						state.dragoy=my-wy
					else
						for _,el in ipairs(elements)do
							if el.type=="slider" and inside(mx,my,el.x,el.y,el.w,el.h)then
								draggingSlider=el
								break
							end
						end
						if not draggingSlider then
							handleClick(mx,my)
						end
					end
				end
			else
				if state.dragging then
					state.wx=mx-state.dragox
					state.wy=my-state.dragoy
					reposition()
				end
				if draggingSlider then
					handleSliderDrag(mx)
				end
			end
		else
			clickConsumed=false
			state.dragging=false
			draggingSlider=nil
		end
		task.wait(0.016)
	end
end)

local lib={}
lib.__index=lib

function lib:SetTheme(t)
	for k,v in pairs(t)do C[k]=v end
end

function lib:SetMenuKey(keycode,label)
	state.menuKey=keycode
	state.menuKeyLabel=label or tostring(keycode)
	win.keyBadgeText.Text=state.menuKeyLabel
end

function lib:Window(title)
	buildWindow()
	local w={}
	w._tabs={}
	function w:Tab(name)
		local tab={name=name,items={}}
		table.insert(state.tabs,tab)
		if #state.tabs==1 then
			state.activeTab=tab
		end
		buildTabs()
		renderTab(state.activeTab)
		local t={}
		function t:Section(label)
			table.insert(tab.items,{type="section",label=label,col=1})
			local s={}
			function s:SectionR(lbl)
				table.insert(tab.items,{type="section",label=lbl,col=2})
			end
			function s:Toggle(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="toggle",label=opts.label,value=opts.default or false,id=id,callback=opts.callback,col=opts.col or 1})
				renderTab(state.activeTab)
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="toggle" and el.id==id then
							el.on=v
							el.bg.Color=v and C.ON or C.OFF
							el.dot.Color=v and C.ONDOT or C.OFFDOT
							el.dot.Position=Vector2.new(el.x+(v and 17 or 3),el.y+3)
						end
					end
				end
				return ctrl
			end
			function s:Slider(opts)
				local id=opts.id or opts.label
				table.insert(tab.items,{type="slider",label=opts.label,value=opts.default or opts.min,min=opts.min,max=opts.max,suffix=opts.suffix,id=id,callback=opts.callback,col=opts.col or 1})
				renderTab(state.activeTab)
				local ctrl={}
				function ctrl:Set(v)
					for _,el in ipairs(elements)do
						if el.type=="slider" and el.id==id then
							local pct=clamp((v-el.min)/(el.max-el.min),0,1)
							local fw=el.slw*pct
							el.value=v
							el.sfill.Size=Vector2.new(fw,4)
							el.sknob.Position=Vector2.new(el.slx+fw-6,el.sknob.Position.Y)
							el.skbdr.Position=Vector2.new(el.slx+fw-6,el.skbdr.Position.Y)
							el.valTxt.Text=tostring(v)..(el.suffix or"")
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
	running=false
	destroy_all()
	for _,o in ipairs(tabObjs)do pcall(function()if o.Remove then o:Remove()end end)end
	for _,o in ipairs(activeTabObjs)do pcall(function()o:Remove()end)end
end

setmetatable(lib,{__call=function(self,...)return self end})
_G.lib=lib
