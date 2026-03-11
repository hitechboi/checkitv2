local UILib = {}
local _collapseSections = {}
local THEMES = {
    ["Check it"] = {ACCENT=Color3.fromRGB(70,120,255),BG=Color3.fromRGB(9,11,20),SIDEBAR=Color3.fromRGB(12,15,27),CONTENT=Color3.fromRGB(11,13,23),TOPBAR=Color3.fromRGB(7,9,17),BORDER=Color3.fromRGB(30,40,72),ROWBG=Color3.fromRGB(14,18,33),TABSEL=Color3.fromRGB(20,35,85),WHITE=Color3.fromRGB(215,220,240),GRAY=Color3.fromRGB(100,112,145),DIMGRAY=Color3.fromRGB(28,33,52),ON=Color3.fromRGB(45,85,195),OFF=Color3.fromRGB(20,24,42),ONDOT=Color3.fromRGB(175,198,255),OFFDOT=Color3.fromRGB(55,65,95),DIV=Color3.fromRGB(22,27,48),MINIBAR=Color3.fromRGB(11,13,22)},
    Moon = {ACCENT=Color3.fromRGB(150,150,165),BG=Color3.fromRGB(12,12,14),SIDEBAR=Color3.fromRGB(16,16,18),CONTENT=Color3.fromRGB(14,14,16),TOPBAR=Color3.fromRGB(10,10,12),BORDER=Color3.fromRGB(40,40,46),ROWBG=Color3.fromRGB(18,18,22),TABSEL=Color3.fromRGB(30,30,36),WHITE=Color3.fromRGB(220,220,225),GRAY=Color3.fromRGB(120,120,130),DIMGRAY=Color3.fromRGB(40,40,45),ON=Color3.fromRGB(100,100,115),OFF=Color3.fromRGB(25,25,30),ONDOT=Color3.fromRGB(200,200,215),OFFDOT=Color3.fromRGB(70,70,80),DIV=Color3.fromRGB(30,30,36),MINIBAR=Color3.fromRGB(16,16,20)},
    Grass = {ACCENT=Color3.fromRGB(60,200,100),BG=Color3.fromRGB(8,14,10),SIDEBAR=Color3.fromRGB(10,18,13),CONTENT=Color3.fromRGB(9,16,11),TOPBAR=Color3.fromRGB(6,11,8),BORDER=Color3.fromRGB(25,55,35),ROWBG=Color3.fromRGB(11,20,14),TABSEL=Color3.fromRGB(18,45,25),WHITE=Color3.fromRGB(200,235,210),GRAY=Color3.fromRGB(90,130,105),DIMGRAY=Color3.fromRGB(20,40,28),ON=Color3.fromRGB(30,140,65),OFF=Color3.fromRGB(15,30,20),ONDOT=Color3.fromRGB(150,240,180),OFFDOT=Color3.fromRGB(45,80,58),DIV=Color3.fromRGB(18,35,24),MINIBAR=Color3.fromRGB(10,18,13)},
    Light = {ACCENT=Color3.fromRGB(50,100,255),BG=Color3.fromRGB(230,233,245),SIDEBAR=Color3.fromRGB(215,220,235),CONTENT=Color3.fromRGB(220,224,238),TOPBAR=Color3.fromRGB(200,205,225),BORDER=Color3.fromRGB(170,178,210),ROWBG=Color3.fromRGB(210,214,230),TABSEL=Color3.fromRGB(190,205,240),WHITE=Color3.fromRGB(25,30,60),GRAY=Color3.fromRGB(90,100,140),DIMGRAY=Color3.fromRGB(180,185,210),ON=Color3.fromRGB(60,120,255),OFF=Color3.fromRGB(180,185,210),ONDOT=Color3.fromRGB(255,255,255),OFFDOT=Color3.fromRGB(130,140,175),DIV=Color3.fromRGB(185,190,215),MINIBAR=Color3.fromRGB(205,210,228)},
    Dark = {ACCENT=Color3.fromRGB(180,180,180),BG=Color3.fromRGB(4,4,6),SIDEBAR=Color3.fromRGB(6,6,9),CONTENT=Color3.fromRGB(5,5,8),TOPBAR=Color3.fromRGB(3,3,5),BORDER=Color3.fromRGB(20,20,28),ROWBG=Color3.fromRGB(7,7,10),TABSEL=Color3.fromRGB(15,15,22),WHITE=Color3.fromRGB(190,190,195),GRAY=Color3.fromRGB(80,80,90),DIMGRAY=Color3.fromRGB(15,15,20),ON=Color3.fromRGB(100,100,110),OFF=Color3.fromRGB(12,12,16),ONDOT=Color3.fromRGB(220,220,225),OFFDOT=Color3.fromRGB(45,45,55),DIV=Color3.fromRGB(14,14,18),MINIBAR=Color3.fromRGB(6,6,8)}
}
UILib.Themes, UILib.Colors = THEMES, THEMES["Check it"]
 
_G.UILib = UILib
print("[UILib] v1.6.0 loaded")
local clamp = math.clamp or function(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local abs, sin, cos, floor, ceil, min, max = math.abs, math.sin, math.cos, math.floor, math.ceil, math.min, math.max
local function lerpC(a,b,t)
    return Color3.fromRGB(
        floor(a.R*255+(b.R*255-a.R*255)*t),
        floor(a.G*255+(b.G*255-a.G*255)*t),
        floor(a.B*255+(b.B*255-a.B*255)*t))
end
local function getViewport()
    local ok,vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
    if ok and vp then return vp.X, vp.Y end
    return 1920, 1080
end
local function mkTri(x1,y1,x2,y2,x3,y3,col,filled,zi)
    local t = Drawing.new("Triangle")
    t.PointA=Vector2.new(x1,y1); t.PointB=Vector2.new(x2,y2); t.PointC=Vector2.new(x3,y3)
    t.Color=col or C.GRAY; t.Filled=filled~=false; t.Transparency=1
    t.ZIndex=zi or 8; t.Visible=true
    return t
end
local function setTriDir(tri,cx,cy,dir)
    if dir=="v" then
        tri.PointA=Vector2.new(cx-4,cy-3); tri.PointB=Vector2.new(cx+4,cy-3); tri.PointC=Vector2.new(cx,cy+3)
    elseif dir=="^" then
        tri.PointA=Vector2.new(cx-4,cy+3); tri.PointB=Vector2.new(cx+4,cy+3); tri.PointC=Vector2.new(cx,cy-3)
    elseif dir==">" then
        tri.PointA=Vector2.new(cx-3,cy-4); tri.PointB=Vector2.new(cx-3,cy+4); tri.PointC=Vector2.new(cx+3,cy)
    end
end
local C = {
    BG      = Color3.fromRGB(9,  11, 20),
    SIDEBAR = Color3.fromRGB(12, 15, 27),
    CONTENT = Color3.fromRGB(11, 13, 23),
    TOPBAR  = Color3.fromRGB(7,  9,  17),
    ACCENT  = Color3.fromRGB(70, 120,255),
    TABSEL  = Color3.fromRGB(20, 35, 85),
    WHITE   = Color3.fromRGB(215,220,240),
    GRAY    = Color3.fromRGB(100,112,145),
    DIMGRAY = Color3.fromRGB(28, 33, 52),
    ON      = Color3.fromRGB(45, 85, 195),
    OFF     = Color3.fromRGB(20, 24, 42),
    ONDOT   = Color3.fromRGB(175,198,255),
    OFFDOT  = Color3.fromRGB(55, 65, 95),
    GREEN   = Color3.fromRGB(45, 190,95),
    RED     = Color3.fromRGB(210,55, 55),
    BORDER  = Color3.fromRGB(30, 40, 72),
    ROWBG   = Color3.fromRGB(14, 18, 33),
    DIV     = Color3.fromRGB(22, 27, 48),
    SHADOW  = Color3.fromRGB(0,  0,  5),
    ORANGE  = Color3.fromRGB(255,175,80),
    YELLOW  = Color3.fromRGB(190,148,0),
    MINIBAR = Color3.fromRGB(11, 13, 22),
}
UILib.Colors = C
local L = {
    W        = 440, H        = 400,
    SIDEBAR  = 128, TOPBAR   = 40,
    FOOTER   = 34,  ROW_H    = 40,
    ROW_PAD  = 10,  TOG_W    = 34,
    TOG_H    = 17,  HDL      = 8,
    MINI_H   = 86,
}
L.CONTENT_W = L.W - L.SIDEBAR
local function setProps(obj, props)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end
local function mkSq(x,y,w,h,col,filled,transp,zi,thick,corner)
    local s = Drawing.new("Square")
    setProps(s, {Position=Vector2.new(x,y), Size=Vector2.new(w,h), Color=col, Filled=filled, Transparency=transp or 1, ZIndex=zi or 1, Visible=true})
    if not filled then s.Thickness=thick or 1 end
    if corner and corner>0 then pcall(function() s.Corner=corner end) end
    return s
end
local function mkTx(txt,x,y,sz,col,ctr,zi,bold)
    return setProps(Drawing.new("Text"), {Text=txt, Position=Vector2.new(x,y), Size=sz or 13, Color=col or C.WHITE, Center=ctr or false, Outline=false, Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System, Transparency=1, ZIndex=zi or 3, Visible=true})
end
local function mkLn(x1,y1,x2,y2,col,zi,thick)
    return setProps(Drawing.new("Line"), {From=Vector2.new(x1,y1), To=Vector2.new(x2,y2), Color=col or C.ACCENT, Transparency=1, Thickness=thick or 1, ZIndex=zi or 2, Visible=true})
end
local kn = {[0x20]="Space",[0x09]="Tab",[0x0D]="Enter",[0x1B]="Esc",[0x08]="Back",[0x24]="Home",[0x23]="End",[0x2E]="Del",[0x2D]="Ins",[0x21]="PgUp",[0x22]="PgDn",[0x26]="Up",[0x28]="Down",[0x25]="Left",[0x27]="Right",[0xBC]=",",[0xBE]=".",[0xBF]="/",[0xBA]=";",[0xBB]="=",[0xBD]="-",[0xDB]="[",[0xDD]="]",[0xDC]="\\",[0xDE]="'",[0xC0]="`"}
for i=0x41,0x5A do kn[i]=string.char(i) end
for i=0x30,0x39 do kn[i]=tostring(i-0x30) end
for i=0x60,0x69 do kn[i]="Num"..(i-0x60) end
for i=0x70,0x7B do kn[i]="F"..(i-0x6F) end
local function kname(k) return kn[k] or ("Key"..k) end
function UILib.Window(titleA, titleB, gameName)
    local win = {}
    local mouse = game.Players.LocalPlayer:GetMouse()
    local _scrollDelta = 0
    pcall(function() mouse.WheelForward:Connect(function() _scrollDelta = _scrollDelta - 1 end) end)
    pcall(function() mouse.WheelBackward:Connect(function() _scrollDelta = _scrollDelta + 1 end) end)
    local PAD = 10
    local uiX, uiY       = 300, 200
    local dragging        = false
    local dragOffX, dragOffY = 0, 0
    local wasClicking     = false
    local currentTab      = nil
    local menuKey         = 0x70
    local listenKey       = false
    local destroyed       = false
    local isLoading       = true
    local wasMenuKey      = false
    local menuOpen        = true
    local menuToggledAt   = tick() - 1
    local FADE_DUR        = 0.4
    local TAB_FADE_DUR    = 0.2
    local tabSwitchedAt   = tick() - 1
    local prevTab         = nil
    local minimized       = false
    local miniClosed      = false
    local miniDragging    = false
    local miniDragOffX, miniDragOffY = 0, 0
    local miniFadeIn      = false
    local miniFadeOut     = false
    local miniFadedAt     = tick() - 1
    local MINI_FADE_DUR   = 0.25
    local TIP_FADE        = 0.35
    local UI_RESIZE_SPD   = 12.0
    local lastTick        = tick()
    local glowPhase       = {0, math.pi*0.6}
    local _wasResizing    = false
    local scrollDragging  = false
    local scrollDragOffY  = 0
    local allDrawings = {}
    local _twCache, _taCache = 0, 0
    local showSet     = {}
    local tabSet      = {}
    local baseUI      = {}
    local tabObjs     = {}
    local btns        = {}
    local tabAPI      = {}
    local tabRowY     = {}
    local tabScroll   = {}
    local miniDrawings= {}
    local miniActiveLbls = {}
    local miniActivePulse= {}
    local MAX_MINI_LBLS  = 12
    for i=1,MAX_MINI_LBLS do
        local lb = mkTx("",0,0,13,C.WHITE,false,9,false)
        lb.Outline=true
        lb.Visible=false
        lb.Transparency=1
        table.insert(miniActiveLbls,lb)
        table.insert(miniActivePulse,i*0.7)
    end
    local function mkD(d)
        table.insert(allDrawings,d)
        d.Visible=false
        return d
    end
    local function setShow(d,yes)
        showSet[d]=yes or nil
        d.Visible=yes and true or false
    end
    local function inBox(x,y,w,h)
        return mouse.X>=x and mouse.X<=x+w and mouse.Y>=y and mouse.Y<=y+h
    end
    local uiTargetH = L.H
    local uiCurrentH = L.H
    local function applyFade()
        if isLoading then
            for _,d in ipairs(allDrawings) do d.Visible=false end
            if dScrollBg then dScrollBg.Visible=false end
            if dScrollThumb then dScrollThumb.Visible=false end
            if dWelcomeTxt then dWelcomeTxt.Visible=false end
            if dNameTxt then dNameTxt.Visible=false end
            if dCharLbl then dCharLbl.Visible=false end
            for _,ap in ipairs(avatarDrawings or {}) do pcall(function() ap.d.Visible=false end) end
            for _,lb in ipairs(miniActiveLbls) do lb.Visible=false end
            for _,d in ipairs(miniDrawings) do d.Visible=false end
            if tipBg then
                tipBg.Visible=false; tipBorder.Visible=false
                tipLbl.Visible=false; tipDesc.Visible=false
            end
            return
        end
        if minimized then
            for _,d in ipairs(allDrawings) do d.Visible=false end
            return
        end
        if not minimized then
            for _,lb in ipairs(miniActiveLbls) do lb.Visible=false end
        end
        local mf=1-(menuToggledAt-(tick()-FADE_DUR))/FADE_DUR
        if not menuOpen and mf>=1.1 then
            for _,d in ipairs(allDrawings) do d.Visible=false end
            return
        end
        local mOp=mf<1.1
            and math.abs((menuOpen and 0 or 1)-clamp(mf,0,1))
            or  (menuOpen and 1 or 0)
        local tp=clamp((tick()-tabSwitchedAt)/TAB_FADE_DUR,0,1)
        for _,d in ipairs(allDrawings) do
            if showSet[d] then
                local tOp=tabSet[d]=="next" and tp or tabSet[d]=="prev" and (1-tp) or 1
                local op=mOp*tOp
                d.Visible=op>0.01
                d.Transparency=op
            else
                d.Visible=false
            end
        end
    end
    local function bShow(b,yes)
        setShow(b.bg,yes)
        if b.out    then setShow(b.out,yes) end
        if b.outGlow then setShow(b.outGlow, yes and (b.hoverAlpha or 0) > 0.02) end
        if not b.isLog then setShow(b.lbl,yes) end
        if b.ln     then setShow(b.ln,    yes) end
        if b.tog    then setShow(b.tog,   yes) end
        if b.dot    then setShow(b.dot,   yes) end
        if b.track  then setShow(b.track, yes) end
        if b.fill   then setShow(b.fill,  yes) end
        if b.handle then setShow(b.handle,yes) end
        if b.lbls   then for _,l in ipairs(b.lbls) do setShow(l,yes) end end
        if b.qbg    then setShow(b.qbg,  yes) end
        if b.qlb    then setShow(b.qlb,  yes) end
        if b.dlb    then setShow(b.dlb,  yes) end
        if b.arrow  then setShow(b.arrow, yes) end
        if b.valLbl  then setShow(b.valLbl, yes) end
        if b.swatches then
            for _,sw in ipairs(b.swatches) do setShow(sw.sq,yes); setShow(sw.border,yes) end
        end
        if b.isDropdown then
            for _,o in ipairs(b.optBgs) do
                setShow(o.bg, yes and b.open)
                setShow(o.ln, yes and b.open)
                setShow(o.lb, yes and b.open)
            end
        end
        if b.isUserList then
            for _,u in ipairs(b.users) do
                local uvis = yes and (u.alpha > 0.05)
                setShow(u.out, uvis)
                setShow(u.bg, uvis)
                setShow(u.name, uvis)
                setShow(u.youTag, uvis and u._isYou)
            end
        end
    end
    local function bPos(b)
        local animY = b.currentRY ~= nil and b.currentRY or b.ry
        local sc = tabScroll[b.tab] or 0
        local ax,ay=uiX+b.rx,uiY+animY-sc
        b.bg.Position=Vector2.new(ax,ay)
        if b.outGlow then b.outGlow.Position=Vector2.new(ax-1, ay-1) end
        if b.isLog then
            for i,lb in ipairs(b.lbls) do
                if b.starFirst and i==1 then
                    lb.Position=Vector2.new(ax+b.cw/2,ay+b.pad)
                else
                    local off=b.starFirst and (b.starH+b.pad+(i-2)*b.lineH) or (b.pad+(i-1)*b.lineH)
                    lb.Position=Vector2.new(ax+8,ay+off)
                end
            end
            return
        end
        if b.isDiv then
            b.lbl.Position=Vector2.new(ax+6,ay)
            if b.ln then b.ln.From=Vector2.new(ax,ay+13); b.ln.To=Vector2.new(ax+b.cw,ay+13) end
            if b.arrow then
                b.arrow.Position=Vector2.new(ax+b.cw-6,ay)
                b.arrow.Text=_collapseSections[b.sectionName] and ">" or "v"
            end
        elseif b.isAct then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+b.cw/2,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
        elseif b.isDropdown then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.valLbl.Position=Vector2.new(ax+b.cw-28-(#b.valLbl.Text*5.5),ay+b.ch/2-6)
            if b.arrow then
                b.arrow.Position=Vector2.new(ax+b.cw-11,ay+b.ch/2-6)
                b.arrow.Text=b.open and "^" or "v"
            end
            for i,o in ipairs(b.optBgs) do
                local oy2=ay+b.ch+((i-1)*b.ch)
                o.bg.Position=Vector2.new(ax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                o.ln.From=Vector2.new(ax,oy2+b.ch); o.ln.To=Vector2.new(ax+b.cw,oy2+b.ch)
                o.lb.Position=Vector2.new(ax+12,oy2+b.ch/2-6)
                o.ry=animY-sc+b.ch+((i-1)*b.ch)
            end
        elseif b.isUserList then
            b.bg.Position=Vector2.new(ax,ay)
        elseif b.isColorPicker then
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            local totalW=(#b.swatches*19)-5
            local startX=ax+b.cw-totalW-10
            for i,sw in ipairs(b.swatches) do
                local sx=startX+(i-1)*19; local sy=ay+b.ch/2-7
                sw.sq.Position=Vector2.new(sx,sy)
                sw.border.Position=Vector2.new(sx-1,sy-1)
                sw.x=sx; sw.y=sy
            end
        elseif b.isSlider then
            b.lbl.Position=Vector2.new(ax+8,ay+7)
            if b.dlb then b.dlb.Position=Vector2.new(ax+8,ay+21) end
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            local tx=ax+8; local ty=ay+b.ch-11
            b.track.From=Vector2.new(tx,ty); b.track.To=Vector2.new(tx+b.trackW,ty)
            local frac=(b.value-b.minV)/(b.maxV-b.minV)
            local fx=tx+frac*b.trackW
            b.fill.From=Vector2.new(tx,ty); b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
        else
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            if b.tog then
                local dox=b.rx+b.cw-L.TOG_W-8
                local doy=b.ry+b.ch/2-L.TOG_H/2
                local dcy=b.currentRY or b.ry
                b.tog.Position=Vector2.new(uiX+dox, uiY+dcy-sc+b.ch/2-L.TOG_H/2)
                b.dot.Position=Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt, uiY+dcy-sc+b.ch/2-L.TOG_H/2+2)
            end
            if b.qbg then
                local dox2=b.rx+b.cw-L.TOG_W-8
                local qx=uiX+dox2-22; local qy=uiY+(b.currentRY or b.ry)-sc+b.ch/2-7
                b.qbg.Position=Vector2.new(qx,qy)
                if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+2) end
            end
        end
    end
    local function tagBtnFade(b,group)
        tabSet[b.bg]=group
        if not b.isLog then tabSet[b.lbl]=group end
        if b.outGlow then tabSet[b.outGlow]=group end
        if b.ln     then tabSet[b.ln]=group    end
        if b.tog    then tabSet[b.tog]=group   end
        if b.dot    then tabSet[b.dot]=group   end
        if b.track  then tabSet[b.track]=group end
        if b.fill   then tabSet[b.fill]=group  end
        if b.handle then tabSet[b.handle]=group end
        if b.lbls   then for _,l in ipairs(b.lbls) do tabSet[l]=group end end
        if b.qbg    then tabSet[b.qbg]=group end
        if b.qlb    then tabSet[b.qlb]=group end
        if b.dlb    then tabSet[b.dlb]=group end
        if b.arrow  then tabSet[b.arrow]=group end
        if b.valLbl  then tabSet[b.valLbl]=group end
        if b.swatches then
            for _,sw in ipairs(b.swatches) do tabSet[sw.sq]=group; tabSet[sw.border]=group end
        end
        if b.isDropdown then
            for _,o in ipairs(b.optBgs) do
                tabSet[o.bg]=group; tabSet[o.ln]=group; tabSet[o.lb]=group
            end
        end
    end
    local function showTab(tab)
        for _,b in ipairs(btns) do
            local yes=b.tab==tab; bShow(b,yes)
            if yes then bPos(b) end
        end
    end
    local recalculateLayout
    local function switchTab(name)
        if name==currentTab then return end
        if openDropdown then
            openDropdown.open=false
            if openDropdown.arrow then openDropdown.arrow.Text="v" end
            for _,o in ipairs(openDropdown.optBgs) do o.targetAlpha=0 end
            openDropdown=nil
        end
        uiTargetH=L.H
        prevTab=currentTab; currentTab=name; tabSwitchedAt=tick()
        for _,t in ipairs(tabObjs) do
            t.sel=t.name==name
            setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel)
        end
        for _,d in ipairs(allDrawings) do tabSet[d]=nil end
        for _,b in ipairs(btns) do
            if b.tab==prevTab then bShow(b,true); bPos(b); tagBtnFade(b,"prev") end
        end
        for _,b in ipairs(btns) do
            if b.tab==name then
                if b.isDiv and b.collapsible and b.sectionName then
                    _collapseSections[b.sectionName]=false
                    if b.arrow then b.arrow.Text="v" end
                end
                bShow(b,true)
            end
        end
        recalculateLayout(name)
        for _,b in ipairs(btns) do
            if b.tab==name then
                b.currentRY=b.ry
                bPos(b); tagBtnFade(b,"next")
            end
        end
    end
    local dShadow,dMainBg,dGlow1,dGlow2,dBorder
    local dTopBar,dTopFill,dTopLine
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dDotY,dDotR
    local dSide,dSideLn,dContent,dFooter,dFotLine,dCharLbl
    local dScrollBg, dScrollThumb
    local glowLines
    local dMiniShadow,dMiniBg,dMiniGlow1,dMiniGlow2,dMiniBorder
    local dMiniTopBar,dMiniTitleW,dMiniTitleA,dMiniTitleG
    local dMiniKeyLbl,dMiniDotG,dMiniDotR,dMiniDivLn,dMiniActiveBg
    local miniGlowLines
    local iKeyInfo, iKeyBind
    local tipBg, tipBorder, tipLbl, tipDesc
    local hoveredBtn = nil
    local tipFadeIn = false
    local tipFadeOut = false
    local tipFadedAt = tick()-1
    local TIP_FADE = 0.35
    local dWelcomeTxt, dNameTxt
    local avatarDrawings
    local function updatePos()
        local curH = uiCurrentH
        dShadow.Size      =Vector2.new(L.W+4,curH+4)
        dMainBg.Size      =Vector2.new(L.W,curH)
        dBorder.Size      =Vector2.new(L.W,curH)
        dGlow1.Size       =Vector2.new(L.W+2,curH+2)
        dGlow2.Size       =Vector2.new(L.W+4,curH+4)
        dShadow.Position  =Vector2.new(uiX-2,uiY-2)
        dMainBg.Position  =Vector2.new(uiX,uiY)
        dBorder.Position  =Vector2.new(uiX,uiY)
        dGlow1.Position   =Vector2.new(uiX-1,uiY-1)
        dGlow2.Position   =Vector2.new(uiX-2,uiY-2)
        dTopBar.Position  =Vector2.new(uiX+1,uiY+1)
        dTopFill.Position =Vector2.new(uiX+1,uiY+L.TOPBAR-5)
        dTopLine.From     =Vector2.new(uiX+1,uiY+L.TOPBAR)
        dTopLine.To       =Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dTitleW.Position  =Vector2.new(uiX+14,uiY+12)
        if dTitleW.TextBounds and dTitleW.TextBounds.X > 0 and dTitleW.TextBounds.X > _twCache then _twCache = dTitleW.TextBounds.X end
        local tw = _twCache > 0 and _twCache or (#titleA*8)
        dTitleA.Position  =Vector2.new(uiX+14+tw+3,uiY+12)
        if dTitleA.TextBounds and dTitleA.TextBounds.X > 0 and dTitleA.TextBounds.X > _taCache then _taCache = dTitleA.TextBounds.X end
        local ta = _taCache > 0 and _taCache or (#titleB*8)
        dTitleG.Position  =Vector2.new(uiX+14+tw+3+ta+10,uiY+12)
        if dOnlineTxt and dOnlineDot then
            local tx = dTitleG.Position.X + #(dTitleG.Text)*7.5 + 15
            dOnlineTxt.Position = Vector2.new(tx, uiY+14)
            dOnlineDot.Position = Vector2.new(tx + #("Online:")*6.5 + 4, uiY+16)
        end
        dKeyLbl.Position  =Vector2.new(uiX+L.W-22,uiY+14)
        dDotY.Position    =Vector2.new(uiX+L.W-55,uiY+15)
        dDotR.Position    =Vector2.new(uiX+L.W-42,uiY+15)
        dSide.Position    =Vector2.new(uiX+1,uiY+L.TOPBAR)
        dSideLn.From      =Vector2.new(uiX+L.SIDEBAR,uiY+L.TOPBAR)
        dSideLn.To        =Vector2.new(uiX+L.SIDEBAR,uiY+curH-L.FOOTER)
        dContent.Position =Vector2.new(uiX+L.SIDEBAR,uiY+L.TOPBAR)
        dFooter.Position  =Vector2.new(uiX+1,uiY+curH-L.FOOTER)
        dScrollBg.Position =Vector2.new(uiX+L.W-6,uiY+L.TOPBAR+2)
        dScrollBg.Size    =Vector2.new(4,curH-L.TOPBAR-L.FOOTER-4)
        dFotLine.From     =Vector2.new(uiX+1,uiY+curH-L.FOOTER)
        dFotLine.To       =Vector2.new(uiX+L.W-1,uiY+curH-L.FOOTER)
        if dCharLbl then
            local nW = dNameTxt and #dNameTxt.Text * 6 or 0
            dCharLbl.Position = Vector2.new(uiX+42+64+nW+8, uiY+curH-L.FOOTER+9)
        end
        dTopBar.Size  =Vector2.new(L.W-2,L.TOPBAR)
        dTopFill.Size =Vector2.new(L.W-2,7)
        dSide.Size    =Vector2.new(L.SIDEBAR-1,curH-L.TOPBAR-L.FOOTER-1)
        dContent.Size =Vector2.new(L.CONTENT_W-1,curH-L.TOPBAR-L.FOOTER-1)
        dFooter.Size  =Vector2.new(L.W-2,L.FOOTER-1)
        for _,t in ipairs(tabObjs) do
            t.bg.Position =Vector2.new(uiX+7,uiY+t.relTY)
            t.acc.Position=Vector2.new(uiX+7,uiY+t.relTY)
            t.lbl.Position=Vector2.new(uiX+18,uiY+t.relTY+7)
            t.lblG.Position=Vector2.new(uiX+18,uiY+t.relTY+7)
        end
        for _,b in ipairs(btns) do
            if showSet[b.bg] then bPos(b) end
        end
    end
    local function updateMiniPos()
        dMiniShadow.Position =Vector2.new(uiX-2,uiY-2)
        dMiniShadow.Size     =Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBg.Position     =Vector2.new(uiX,uiY)
        dMiniBg.Size         =Vector2.new(L.W,L.MINI_H)
        dMiniGlow1.Position  =Vector2.new(uiX-1,uiY-1)
        dMiniGlow1.Size      =Vector2.new(L.W+2,L.MINI_H+2)
        dMiniGlow2.Position  =Vector2.new(uiX-2,uiY-2)
        dMiniGlow2.Size      =Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBorder.Position =Vector2.new(uiX,uiY)
        dMiniBorder.Size     =Vector2.new(L.W,L.MINI_H)
        dMiniTopBar.Position =Vector2.new(uiX+1,uiY+1)
        dMiniTitleW.Position =Vector2.new(uiX+14,uiY+12)
        if dMiniTitleW.TextBounds and dMiniTitleW.TextBounds.X > 0 and dMiniTitleW.TextBounds.X > _twCache then _twCache = dMiniTitleW.TextBounds.X end
        local mtw = _twCache > 0 and _twCache or (#titleA*8)
        dMiniTitleA.Position =Vector2.new(uiX+14+mtw+3,uiY+12)
        if dMiniTitleA.TextBounds and dMiniTitleA.TextBounds.X > 0 and dMiniTitleA.TextBounds.X > _taCache then _taCache = dMiniTitleA.TextBounds.X end
        local mta = _taCache > 0 and _taCache or (#titleB*8)
        dMiniTitleG.Position =Vector2.new(uiX+14+mtw+3+mta+10,uiY+12)
        dMiniKeyLbl.Position =Vector2.new(uiX+L.W-22,uiY+14)
        dMiniDotG.Position   =Vector2.new(uiX+L.W-55,uiY+15)
        dMiniDotR.Position   =Vector2.new(uiX+L.W-42,uiY+15)
        dMiniDivLn.From      =Vector2.new(uiX+1,uiY+L.TOPBAR)
        dMiniDivLn.To        =Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dMiniActiveBg.Position=Vector2.new(uiX+1,uiY+L.TOPBAR)
        dMiniActiveBg.Size   =Vector2.new(L.W-2,L.MINI_H-L.TOPBAR-1)
        local PAD=10; local SEP=14; local charW=7
        local ROW_H2=18
        local ROW1_Y=uiY+L.TOPBAR+6
        local ROW2_Y=uiY+L.TOPBAR+6+ROW_H2
        local curX=uiX+PAD; local row=1
        for _,lb in ipairs(miniActiveLbls) do
            if lb.Visible and lb.Text~="" then
                local w=#lb.Text*charW
                if curX+w>uiX+L.W-PAD then
                    if row==1 then row=2; curX=uiX+PAD else break end
                end
                lb.Position=Vector2.new(curX,row==1 and ROW1_Y or ROW2_Y)
                curX=curX+w+SEP
            end
        end
    end
    local function showMiniUI(show)
        if show then
            for _,d in ipairs(miniDrawings) do d.Visible=true; d.Transparency=1 end
            for _,l in ipairs(miniActiveLbls) do if l.Text~="" then l.Visible=true; l.Transparency=1 end end
        else
            for _,d in ipairs(miniDrawings) do d.Visible=false end
            for _,l in ipairs(miniActiveLbls) do l.Visible=false end
        end
        miniFadeIn=false; miniFadeOut=false
    end
    local function refreshMiniLabels()
        local active={}
        for _,b in ipairs(btns) do
            if b.isTog and b.state then table.insert(active,b.toggleName) end
        end
        if #active==0 then
            miniActiveLbls[1].Text="no active toggles"
            miniActiveLbls[1].Position=Vector2.new(uiX+10, uiY+L.TOPBAR+6)
            miniActiveLbls[1].Visible=true
            for i=2,MAX_MINI_LBLS do miniActiveLbls[i].Text=""; miniActiveLbls[i].Visible=false end
            return
        end
        local PAD=10; local SEP=14; local charW=7
        local ROW_H2=18
        local ROW1_Y=uiY+L.TOPBAR+6
        local ROW2_Y=uiY+L.TOPBAR+6+ROW_H2
        local slots={}
        local curX=uiX+PAD; local row=1
        for _,name in ipairs(active) do
            local w=#name*charW
            if curX+w>uiX+L.W-PAD then
                if row==1 then row=2; curX=uiX+PAD else break end
            end
            table.insert(slots,{name=name,x=curX,y=(row==1 and ROW1_Y or ROW2_Y)})
            curX=curX+w+SEP
        end
        for i,lb in ipairs(miniActiveLbls) do
            if slots[i] then
                lb.Text=slots[i].name
                lb.Position=Vector2.new(slots[i].x,slots[i].y)
                lb.Visible=true
            else
                lb.Text=""; lb.Visible=false
            end
        end
    end
    local function restoreFullMenu()
        minimized=false; miniClosed=false
        showMiniUI(false)
        for _,d in ipairs(allDrawings) do d.Visible=false end
        dScrollBg.Visible = false
        dScrollThumb.Visible = false
        for _,d in ipairs(allDrawings) do tabSet[d]=nil end
        for _,d in ipairs(baseUI) do setShow(d,true) end
        for _,t in ipairs(tabObjs) do
            setShow(t.bg,true); setShow(t.acc,true)
            setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel)
        end
        uiCurrentH = L.MINI_H + 5
        updatePos()
        uiTargetH = L.H
        _wasResizing = true
        lastTick = tick()
        menuOpen=true; menuToggledAt=tick()-FADE_DUR-0.01
        showTab(currentTab)
        local contentBottom = uiY + uiCurrentH - L.FOOTER
        for _,b in ipairs(btns) do
            if b.tab == currentTab then
                local itemY = uiY + (b.currentRY or b.ry)
                if itemY + 4 > contentBottom then
                    bShow(b, false)
                end
            end
        end
    end
    local function mkR(tab, lbl, relY, h, isDiv)
        local rx, ry = L.SIDEBAR+L.ROW_PAD, L.TOPBAR+relY
        local cw, ch = L.CONTENT_W-L.ROW_PAD*2, h or L.ROW_H-2
        local bg = mkD(mkSq(uiX+rx, uiY+ry, cw, ch, isDiv and C.GRAY or C.ROWBG, not isDiv, 1, 3, nil, isDiv and 0 or 4))
        local lb = mkD(mkTx(lbl, uiX+rx+(isDiv and 6 or 10), uiY+ry+(isDiv and 0 or ch/2-6), isDiv and 9 or 12, isDiv and C.GRAY or C.WHITE, false, 8))
        local ln = mkD(mkLn(uiX+rx, uiY+ry+(isDiv and 13 or ch), uiX+rx+cw, uiY+ry+(isDiv and 13 or ch), C.DIV, 4, 1))
        local glow = not isDiv and mkD(mkSq(uiX+rx-1, uiY+ry-1, cw+2, ch+2, C.ACCENT, false, 0, 5, 1, 4)) or nil
        return {tab=tab,bg=bg,lbl=lb,ln=ln,outGlow=glow,rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,hoverAlpha=0,targetHoverAlpha=0}, rx, ry, cw, ch
    end
    local function addToggle(tab,lbl,relY,init,cb,desc)
        local b, rx, ry, cw, ch = mkR(tab, lbl, relY)
        local ox, oy = rx+cw-L.TOG_W-8, ry+ch/2-L.TOG_H/2
        b.isTog, b.state, b.cb, b.toggleName, b.desc, b.lt = true, init, cb, lbl, desc, init and 1 or 0
        b.tog = mkD(mkSq(uiX+ox, uiY+oy, L.TOG_W, L.TOG_H, init and C.ON or C.OFF, true, 1, 4, nil, L.TOG_H))
        b.dot = mkD(mkSq(uiX+ox+(init and L.TOG_W-L.TOG_H+2 or 2), uiY+oy+2, L.TOG_H-4, L.TOG_H-4, init and C.ONDOT or C.OFFDOT, true, 1, 5, nil, L.TOG_H))
        if desc then b.qbg=mkD(mkSq(uiX+ox-22,uiY+ry+ch/2-7,14,14,Color3.fromRGB(16,20,38),true,1,6,nil,3)); b.qlb=mkD(mkTx("?",uiX+ox-15,uiY+ry+ch/2-5,9,C.GRAY,true,7,true)) end
        b.ox, b.oy = ox, oy
        table.insert(btns, b); return #btns
    end
    local function addDiv(tab,lbl,relY,collapsible)
        local b = mkR(tab, lbl, relY, 14, true); b.isDiv, b.sectionName, b.collapsible = true, lbl, collapsible
        if collapsible then b.arrow=mkD(mkTx("v",uiX+b.rx+b.cw-6,uiY+b.ry,9,C.GRAY,false,8)); _collapseSections[lbl]=_collapseSections[lbl] or false end
        table.insert(btns, b); return #btns
    end
    local function addAct(tab,lbl,relY,col,cb,lblCol)
        local b, rx, ry, cw, ch = mkR(tab, lbl, relY)
        b.isAct, b.cb, b.customCol = true, cb, col~=nil
        if col then b.bg.Color = col end
        local outC = Color3.new(math.min(1, b.bg.Color.R*1.5), math.min(1, b.bg.Color.G*1.5), math.min(1, b.bg.Color.B*1.5))
        b.out = mkD(mkSq(uiX+rx, uiY+ry, cw, ch, outC, true, 1, 3, nil, 4))
        setProps(b.bg, {Position=Vector2.new(uiX+rx+1, uiY+ry+1), Size=Vector2.new(cw-2, ch-2), ZIndex=4})
        setProps(b.lbl, {Position=Vector2.new(uiX+rx+cw/2, uiY+ry+ch/2-6), Center=true, Color=lblCol or C.WHITE})
        table.insert(btns, b); return #btns
    end
    local function addSlider(tab,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local b, rx, ry, cw, ch = mkR(tab, lbl, relY, L.ROW_H+6)
        local trackW, ty = cw-16, uiY+ry+ch-11
        local fx = uiX+rx+8+(initV-minV)/(maxV-minV)*trackW
        b.isSlider, b.minV, b.maxV, b.value, b.cb, b.isFloat, b.baseLbl, b.trackW = true, minV, maxV, initV, cb, isFloat, lbl, trackW
        b.lbl.Text = lbl..": "..(isFloat and string.format("%.1f",initV) or math.floor(initV))
        b.dlb, b.track = desc and mkD(mkTx(desc, uiX+rx+8, uiY+ry+21, 9, C.GRAY, false, 8)) or nil, mkD(mkLn(uiX+rx+8, ty, uiX+rx+8+trackW, ty, C.DIMGRAY, 5, 3))
        b.fill, b.handle = mkD(mkLn(uiX+rx+8, ty, fx, ty, C.ACCENT, 6, 3)), mkD(mkSq(fx-4, ty-4, L.HDL, L.HDL, C.WHITE, true, 1, 7, nil, 3))
        table.insert(btns, b); return #btns
    end
    local function addColorPicker(tab,lbl,relY,initCol,cb)
        local b, rx, ry, cw, ch = mkR(tab, lbl, relY); b.isColorPicker, b.cb, b.swatches = true, cb, {}
        local cols, totalW = {Color3.fromRGB(70,120,255), Color3.fromRGB(210,55,55), Color3.fromRGB(45,190,95), Color3.fromRGB(255,175,80), Color3.fromRGB(180,80,255), Color3.fromRGB(215,220,240)}, 6*19-5
        for i, col in ipairs(cols) do
            local sx, sy = uiX+rx+cw-totalW-10+(i-1)*19, uiY+ry+ch/2-7
            table.insert(b.swatches, {sq=mkD(mkSq(sx,sy,14,14,col,true,1,6,nil,3)), border=mkD(mkSq(sx-1,sy-1,16,16,i==1 and C.WHITE or C.BORDER,false,1,7,1,3)), col=col, x=sx, y=sy})
        end
        table.insert(btns, b); return #btns
    end
    local openDropdown = nil
    local function resizeForDropdown(dd, expanding) uiTargetH = L.H + (expanding and (#dd.options * dd.ch) or 0) end
    local function addDropdown(tab,lbl,relY,options,initIdx,cb)
        local b, rx, ry, cw, ch = mkR(tab, lbl, relY); local outC = Color3.new(math.min(1, C.ROWBG.R*1.5), math.min(1, C.ROWBG.G*1.5), math.min(1, C.ROWBG.B*1.5))
        b.isDropdown, b.options, b.optBgs, b.selected, b.cb, b.out = true, options, {}, initIdx or 1, cb, mkD(mkSq(uiX+rx, uiY+ry, cw, ch, outC, true, 1, 3, nil, 4))
        setProps(b.bg, {Position=Vector2.new(uiX+rx+1, uiY+ry+1), Size=Vector2.new(cw-2, ch-2), ZIndex=4})
        b.valLbl, b.arrow = mkD(mkTx(options[b.selected] or "", uiX+rx+cw-60, uiY+ry+ch/2-6, 11, C.ACCENT, false, 8)), mkD(mkTx("v", uiX+rx+cw-14, uiY+ry+ch/2-6, 9, C.GRAY, false, 8))
        for i, opt in ipairs(options) do
            local oy = ry+ch+(i-1)*ch
            table.insert(b.optBgs, {bg=mkD(mkSq(uiX+rx,uiY+oy,cw,ch,C.ROWBG,true,0,10,nil,0)), ln=mkD(mkLn(uiX+rx,uiY+oy+ch,uiX+rx+cw,uiY+oy+ch,C.DIV,11,1)), lb=mkD(mkTx(opt,uiX+rx+14,oy+ch/2-6,11,i==b.selected and C.ACCENT or C.WHITE,false,11)), ry=oy, alpha=0, targetAlpha=0})
        end
        table.insert(btns, b); return #btns
    end
    local function addLog(tab, lines, relY, starFirst)
        local b, rx, ry, cw, ch = mkR(tab, "", relY, (starFirst and 26 or 0)+(#lines-(starFirst and 1 or 0))*18+20)
        b.isLog, b.lbls = true, {}
        for i, line in ipairs(lines) do
            local isS = starFirst and i==1; local off = isS and 10 or (starFirst and (26+10+(i-2)*18) or (10+(i-1)*18))
            table.insert(b.lbls, setProps(mkTx(line, uiX+rx+(isS and cw/2 or 8), uiY+ry+off, isS and 14 or 11, isS and Color3.fromRGB(255,200,40) or C.WHITE, isS, 8, isS), {Outline=true, Font=Drawing.Fonts.Minecraft, Visible=false}))
        end
        table.insert(btns, b); return #btns
    end
    local function addUserList(tab, maxUsers, relY)
        local b, rx, ry, cw, ch = mkR(tab, "", relY, maxUsers*44)
        b.isUserList, b.users = true, {}
        for i=1, maxUsers do
            local yOff = (i-1)*44; local uOutC = C.ROWBG; local uOutColor = Color3.new(math.min(1, uOutC.R*1.5), math.min(1, uOutC.G*1.5), math.min(1, uOutC.B*1.5))
            table.insert(b.users, {out=setProps(mkSq(uiX+rx+18, uiY+ry+yOff+10, cw-18, 38, uOutColor, true, 0, 3, nil, 4), {Visible=false}), bg=setProps(mkSq(uiX+rx+19, uiY+ry+yOff+11, cw-20, 36, C.ROWBG, true, 0, 4, nil, 4), {Visible=false}), name=setProps(mkTx("", uiX+rx+52, uiY+ry+yOff+22, 13, C.WHITE, false, 8), {Visible=false}), youTag=setProps(mkTx(" <-- you", uiX+rx+52, uiY+ry+yOff+22, 13, C.GRAY, false, 8), {Visible=false}), ryOff=yOff, avatarPixels={}, activePixelsCount=0, _active=false, _isYou=false, targetAlpha=0, alpha=0, slideY=20})
        end
        table.insert(btns, b); return #btns
    end
    local function CONTENT_H() return uiCurrentH - L.TOPBAR - L.FOOTER end
    recalculateLayout = function(tname)
        local currentY = 10 
        local lastHeaderY = 0
        for _, b in ipairs(btns) do
            if b.tab == tname then
                if b.isDiv then
                    local ry = L.TOPBAR + currentY
                    b.ry = ry
                    b.baseRY = ry
                    lastHeaderY = ry
                    bShow(b, true)
                    currentY = currentY + b.ch + 10
                else
                    local isCollapsed = b.section and _collapseSections[b.section]
                    if isCollapsed then
                        b._collapsing = true
                        b._collapseTarget = lastHeaderY + 14
                    else
                        local ry = L.TOPBAR + currentY
                        b.ry = ry
                        b.baseRY = ry
                        if b._collapsing then
                            b._collapsing = false
                            b._collapseTarget = nil
                            b.currentRY = b.currentRY + (ry - b.currentRY) * 0.6
                        end
                        bShow(b, true)
                        bPos(b)
                        currentY = currentY + b.ch + 8
                        if b.isDropdown and b.open then
                            currentY = currentY + (#b.options * b.ch)
                        end
                    end
                end
            else
                if showSet[b.bg] then bShow(b, false) end
            end
        end
        local lastY = 0
        for _, b in ipairs(btns) do
            if b.tab == tname and showSet[b.bg] then
                local bottom = b.ry + b.ch
                if bottom > lastY then lastY = bottom end
            end
        end
        tabRowY[tname] = lastY + 36
        local newMax = math.max(0, (tabRowY[tname] or 0) - CONTENT_H() + 8)
        tabScroll[tname] = clamp(tabScroll[tname] or 0, 0, newMax)
    end
    local function getTabAPI(tabName)
        if tabAPI[tabName] then return tabAPI[tabName] end
        local api = {}
        tabRowY[tabName] = 10 
        local currentSection = nil
        local function nextY(h)
            local y = tabRowY[tabName]
            tabRowY[tabName] = y + h
            return y
        end
        function api:Div(lbl, collapsible)
            if collapsible == nil then collapsible = true end
            local idx = addDiv(tabName, lbl, nextY(22), collapsible)
            if collapsible then
                btns[idx]._sectionStart = idx
                currentSection = lbl
            else
                currentSection = nil
            end
        end
        function api:Toggle(lbl, init, cb, desc)
            local y = nextY(L.ROW_H + 4)
            local idx = addToggle(tabName, lbl, y, init, cb, desc)
            if currentSection then btns[idx].section = currentSection end
        end
        function api:Slider(lbl, minV, maxV, initV, cb, isFloat, desc)
            local y = nextY(L.ROW_H + 10)
            local idx = addSlider(tabName, lbl, y, minV, maxV, initV, cb, isFloat, desc)
            if currentSection then btns[idx].section = currentSection end
        end
        function api:Button(lbl, col, cb, lblCol)
            local y = nextY(L.ROW_H + 4)
            local idx = addAct(tabName, lbl, y, col, cb, lblCol)
            if currentSection then btns[idx].section = currentSection end
            return idx
        end
        function api:ColorPicker(lbl, initCol, cb)
            local y = nextY(L.ROW_H + 4)
            local idx = addColorPicker(tabName, lbl, y, initCol, cb)
            if currentSection then btns[idx].section = currentSection end
        end
        function api:Dropdown(lbl, options, initIdx, cb)
            local y = nextY(L.ROW_H + 4)
            local idx = addDropdown(tabName, lbl, y, options, initIdx, cb)
            if currentSection and btns[idx] then btns[idx].section = currentSection end
        end
        function api:Log(lines, starFirst)
            local lineH = 18
            local starH = starFirst and 26 or 0
            local h = starH + (#lines - (starFirst and 1 or 0)) * lineH + 20 + 6
            local y = nextY(h)
            local idx = addLog(tabName, lines, y, starFirst)
            if currentSection and btns[idx] then btns[idx].section = currentSection end
            
            local logApi = {}
            function logApi:SetLines(newLines)
                if not btns[idx] or not btns[idx].lbls then return end
                for i = 1, #btns[idx].lbls do
                    local lb = btns[idx].lbls[i]
                    if newLines[i] then
                        lb.Text = newLines[i]
                        lb.Visible = showSet[btns[idx].bg] and true or false
                    else
                        lb.Text = ""
                        lb.Visible = false
                    end
                end
            end
            return logApi
        end
        function api:UserList(maxUsers)
            maxUsers = maxUsers or 10
            local h = (maxUsers * 44) + 10
            local y = nextY(h)
            local idx = addUserList(tabName, maxUsers, y)
            if currentSection and btns[idx] then btns[idx].section = currentSection end
            local ulApi = {}
            function ulApi:SetUsers(names, localName)
                if not btns[idx] or not btns[idx].users then return end
                local b = btns[idx]
                local ac = 0
                for i, u in ipairs(b.users) do
                    if names[i] then
                        ac = ac + 1
                        u._active = true
                        u._isYou = (localName and names[i] == localName)
                        if u.lastName ~= names[i] then
                            u.lastName = names[i]
                            u.name.Text = names[i]
                            u.alpha = 0
                            u.slideY = 20
                        end
                        u.targetAlpha = 1
                    else
                        u._active = false
                        u.targetAlpha = 0
                    end
                end
                if dOnlineDot then
                    dOnlineDot.Color = ac > 0 and Color3.new(0.1, 0.9, 0.1) or Color3.new(0.9, 0.1, 0.1)
                end
            end
            function ulApi:LoadAvatar(userIndex, pixelsData)
                if not btns[idx] or not btns[idx].users then return end
                local u = btns[idx].users[userIndex]
                if u then
                    for pi=1, (u.activePixelsCount or 0) do if u.avatarPixels[pi] then u.avatarPixels[pi].d.Visible = false end end
                    local pIdx = 1; local step = 3; local pxSize = 2; local mapInterval = 1
                    local offsetX = -13; local offsetY = 4
                    for py = 1, 64, step do
                        for px = 1, 64, step do
                            local dx = px - 32.5; local dy = py - 32.5
                            if (dx*dx + dy*dy) <= (31.5 * 31.5) then
                                local pData = pixelsData[py] and pixelsData[py][px]
                                if pData and pData.a and pData.a > 0.1 then
                                    local sq
                                    if pIdx <= #u.avatarPixels then sq = u.avatarPixels[pIdx].d
                                    else
                                        sq = Drawing.new("Square"); sq.Size = Vector2.new(pxSize, pxSize)
                                        sq.Filled = true; sq.ZIndex = 8
                                        table.insert(u.avatarPixels, {d=sq, gx=offsetX + math.floor((px-1)/step)*mapInterval, gy=offsetY + math.floor((py-1)/step)*mapInterval})
                                    end
                                    sq.Color = Color3.fromRGB(pData.r, pData.g, pData.b)
                                    sq.Transparency = (pData.a or 1) * u.alpha
                                    sq.Visible = u.alpha > 0.05
                                    pIdx = pIdx + 1
                                end
                            end
                        end
                    end
                    u.activePixelsCount = pIdx - 1
                end
            end
            return ulApi
        end
        tabAPI[tabName] = api
        return api
    end
    local function applyTheme(name)
        local t = THEMES[name]; if not t then return end
        for k, v in pairs(t) do C[k] = v end
        if not dMainBg then return end
        local mapping = {
            [dMainBg]="BG",[dMiniBg]="BG",[dTopBar]="TOPBAR",[dMiniTopBar]="TOPBAR",[dSide]="SIDEBAR",[dContent]="CONTENT",[dFooter]="TOPBAR",[dBorder]="BORDER",[dMiniBorder]="BORDER",[dTopLine]="BORDER",[dMiniDivLn]="BORDER",[dSideLn]="BORDER",[dFotLine]="BORDER",[dTitleA]="ACCENT",[dMiniTitleA]="ACCENT",[dMiniDotG]="ACCENT",[dTitleW]="WHITE",[dMiniTitleW]="WHITE",[dTitleG]="ORANGE",[dKeyLbl]="GRAY",[dMiniKeyLbl]="GRAY",[dCharLbl]="GRAY",[dMiniActiveBg]="MINIBAR"
        }
        for obj, key in pairs(mapping) do if obj then obj.Color = C[key] end end
        if dScrollThumb then dScrollThumb.Color = C.ACCENT end
        for _, lb in ipairs(miniActiveLbls) do lb.Color = C.WHITE end
        for _, t2 in ipairs(tabObjs) do
            t2.bg.Color, t2.acc.Color = t2.sel and C.TABSEL or C.SIDEBAR, t2.sel and C.ACCENT or C.SIDEBAR
            t2.lbl.Color, t2.lblG.Color = C.WHITE, C.GRAY
        end
        for _, b in ipairs(btns) do
            if b.bg and not b.isDiv then b.bg.Color = C.ROWBG end
            if b.ln then b.ln.Color = C.DIV end
            if b.isTog then b.lbl.Color, b.tog.Color, b.dot.Color = C.WHITE, b.state and C.ON or C.OFF, b.state and C.ONDOT or C.OFFDOT; if b.qlb then b.qlb.Color = C.GRAY end
            elseif b.isSlider then b.lbl.Color = C.WHITE; if b.dlb then b.dlb.Color = C.GRAY end; if b.track then b.track.Color = C.ACCENT end
            elseif b.isAct and not b.customCol then b.bg.Color = C.ROWBG; if b.out then b.out.Color = Color3.new(math.min(1, C.ROWBG.R*1.5), math.min(1, C.ROWBG.G*1.5), math.min(1, C.ROWBG.B*1.5)) end
            elseif b.isDiv then b.lbl.Color = C.GRAY; if b.arrow then b.arrow.Color = C.GRAY end
            elseif b.isDropdown then b.lbl.Color, b.arrow.Color, b.valLbl.Color = C.WHITE, C.GRAY, C.ACCENT; for j, o in ipairs(b.optBgs) do o.bg.Color, o.ln.Color, o.lb.Color = C.ROWBG, C.DIV, j==b.selected and C.ACCENT or C.WHITE end
            end
        end
    end
    function win:Init(defaultTab, charLabelFn, notifFn)
        local notif = notifFn or function(msg, title, dur) pcall(function() notify(msg, title or titleA.." "..titleB, dur or 3) end) end
        dShadow = mkD(mkSq(uiX-2, uiY-2, L.W+4, L.H+4, C.SHADOW, true, 0.5, 0, nil, 12))
        dMainBg = mkD(mkSq(uiX, uiY, L.W, L.H, C.BG, true, 1, 1, nil, 10))
        dGlow1 = mkD(mkSq(uiX-1, uiY-1, L.W+2, L.H+2, C.ACCENT, false, 0.9, 1, 1, 11))
        dGlow2 = mkD(mkSq(uiX-2, uiY-2, L.W+4, L.H+4, C.ACCENT, false, 0.35, 0, 2, 12)); glowLines = {dGlow1, dGlow2}
        dBorder = mkD(mkSq(uiX, uiY, L.W, L.H, C.BORDER, false, 0.2, 3, 1, 10))
        dTopBar = mkD(mkSq(uiX+1, uiY+1, L.W-2, L.TOPBAR, C.TOPBAR, true, 1, 3, nil, 9))
        dTopFill = mkD(mkSq(uiX+1, uiY+L.TOPBAR-5, L.W-2, 7, C.TOPBAR, true, 1, 3))
        dTopLine = mkD(mkLn(uiX+1, uiY+L.TOPBAR, uiX+L.W-1, uiY+L.TOPBAR, C.BORDER, 4, 1))
        dTitleW = mkD(mkTx(titleA, uiX+14, uiY+12, 14, C.WHITE, false, 9, true))
        dTitleA = mkD(mkTx(titleB, uiX+14+(#titleA*8)+3, uiY+12, 14, C.ACCENT, false, 9, true))
        local gn = gameName or ""
        dTitleG = mkD(mkTx(gn, uiX+100, uiY+12, 13, C.ORANGE, false, 9, false))
        dOnlineTxt = mkD(mkTx("Online:", uiX+200, uiY+14, 11, C.GRAY, false, 9, false))
        dOnlineDot = mkD(mkSq(uiX+240, uiY+16, 6, 6, Color3.new(0.9, 0.1, 0.1), true, 1, 9, nil, 3))
        local function posOnline(n) local tx = uiX+100+#n*7.5+15; if dOnlineTxt then dOnlineTxt.Position=Vector2.new(tx, uiY+14) end; if dOnlineDot then dOnlineDot.Position=Vector2.new(tx+#("Online:")*6.5+4, uiY+16) end end
        posOnline(gn)
        if gn=="" or gn=="Game Name" then dTitleG.Text=""; posOnline(""); task.spawn(function() pcall(function() local g; if type(getgamename)=="function" then g=getgamename() else local i=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId); g=i and i.Name end; if g then dTitleG.Text=g; posOnline(g); if dMiniTitleG then dMiniTitleG.Text=g end end end) end) end
        dKeyLbl = mkD(mkTx("F1", uiX+L.W-22, uiY+14, 11, C.GRAY, false, 9))
        dDotY = mkD(mkSq(uiX+L.W-55, uiY+15, 8, 8, C.YELLOW, true, 1, 9, nil, 3))
        dDotR = mkD(mkSq(uiX+L.W-42, uiY+15, 8, 8, Color3.fromRGB(170,44,44), true, 1, 9, nil, 3))
        dSide = mkD(mkSq(uiX+1, uiY+L.TOPBAR, L.SIDEBAR-1, L.H-L.TOPBAR-L.FOOTER-1, C.SIDEBAR, true, 1, 2, nil, 8))
        dSideLn = mkD(mkLn(uiX+L.SIDEBAR, uiY+L.TOPBAR, uiX+L.SIDEBAR, uiY+L.H-L.FOOTER, C.BORDER, 4, 1))
        dContent = mkD(mkSq(uiX+L.SIDEBAR, uiY+L.TOPBAR, L.CONTENT_W-1, L.H-L.TOPBAR-L.FOOTER-1, C.CONTENT, true, 1, 2, nil, 8))
        dFooter = mkD(mkSq(uiX+1, uiY+L.H-L.FOOTER, L.W-2, L.FOOTER-1, C.TOPBAR, true, 1, 3, nil, 6))
        dFotLine = mkD(mkLn(uiX+1, uiY+L.H-L.FOOTER, uiX+L.W-1, uiY+L.H-L.FOOTER, C.BORDER, 4, 1))
        dCharLbl = mkD(mkTx("", 0, 0, 11, C.GRAY, false, 9))
        dScrollBg = setProps(mkSq(uiX+L.W-6, uiY+L.TOPBAR+2, 4, L.H-L.TOPBAR-L.FOOTER-4, Color3.fromRGB(18,20,28), true, 1, 4, nil, 2), {Visible=false})
        dScrollThumb = setProps(mkSq(uiX+L.W-6, uiY+L.TOPBAR+2, 4, 20, C.ACCENT, true, 1, 5, nil, 2), {Visible=false})
        tipBg = setProps(mkSq(0,0,10,10,Color3.fromRGB(10,13,24),true,1,12,nil,4), {Visible=false})
        tipBorder = setProps(mkSq(0,0,10,10,C.ACCENT,false,0.7,12,1,4), {Visible=false})
        tipLbl = setProps(mkTx("",0,0,11,Color3.fromRGB(70,120,255),false,13,true), {Visible=false})
        tipDesc = setProps(mkTx("",0,0,10,Color3.fromRGB(130,140,170),false,13,false), {Visible=false})
        baseUI = {dShadow, dGlow2, dGlow1, dMainBg, dBorder, dTopBar, dTopFill, dTopLine, dTitleW, dTitleA, dTitleG, dOnlineTxt, dOnlineDot, dKeyLbl, dDotY, dDotR, dSide, dSideLn, dContent, dFooter, dFotLine, dCharLbl}
        for i, name in ipairs(win._tabOrder) do
            local ry = L.TOPBAR+8+(i-1)*34; local isS = name==defaultTab
            local tbg = mkD(mkSq(uiX+7, uiY+ry, L.SIDEBAR-14, 26, isS and C.TABSEL or C.SIDEBAR, true, 1, 3, nil, 5))
            local tacc = mkD(mkSq(uiX+7, uiY+ry, 3, 26, isS and C.ACCENT or C.SIDEBAR, true, 1, 4, nil, 2))
            local tw, tg = mkD(mkTx(name, uiX+18, uiY+ry+7, 11, C.WHITE, false, 8)), mkD(mkTx(name, uiX+18, uiY+ry+7, 11, C.GRAY, false, 8))
            setShow(tbg, false); setShow(tacc, false); setShow(tw, false); setShow(tg, false)
            table.insert(tabObjs, {bg=tbg, acc=tacc, lbl=tw, lblG=tg, name=name, sel=isS, lt=isS and 1 or 0, relTY=ry})
        end
        dMiniShadow = setProps(mkSq(uiX-2, uiY-2, L.W+4, L.MINI_H+4, C.SHADOW, true, 0.5, 0, nil, 12), {Visible=false})
        dMiniBg = setProps(mkSq(uiX, uiY, L.W, L.MINI_H, C.BG, true, 1, 1, nil, 10), {Visible=false})
        dMiniGlow1 = setProps(mkSq(uiX-1, uiY-1, L.W+2, L.MINI_H+2, C.ACCENT, false, 0.9, 1, 1, 11), {Visible=false})
        dMiniGlow2 = setProps(mkSq(uiX-2, uiY-2, L.W+4, L.MINI_H+4, C.ACCENT, false, 0.35, 0, 2, 12), {Visible=false}); miniGlowLines = {dMiniGlow1, dMiniGlow2}
        dMiniBorder = setProps(mkSq(uiX, uiY, L.W, L.MINI_H, C.BORDER, false, 0.2, 3, 1, 10), {Visible=false})
        dMiniTopBar = setProps(mkSq(uiX+1, uiY+1, L.W-2, L.TOPBAR, C.TOPBAR, true, 1, 3, nil, 9), {Visible=false})
        dMiniTitleW = setProps(mkTx(titleA, uiX+14, uiY+12, 14, C.WHITE, false, 9, true), {Visible=false})
        dMiniTitleA = setProps(mkTx(titleB, uiX+14+(#titleA*8)+3, uiY+12, 14, C.ACCENT, false, 9, true), {Visible=false})
        dMiniTitleG = setProps(mkTx(dTitleG.Text, uiX+100, uiY+12, 13, C.ORANGE, false, 9, false), {Visible=false})
        dMiniKeyLbl = setProps(mkTx("F1", uiX+L.W-22, uiY+14, 11, C.GRAY, false, 9), {Visible=false})
        dMiniDotG = setProps(mkSq(uiX+L.W-55, uiY+15, 8, 8, C.ACCENT, true, 1, 9, nil, 3), {Visible=false})
        dMiniDotR = setProps(mkSq(uiX+L.W-42, uiY+15, 8, 8, Color3.fromRGB(170,44,44), true, 1, 9, nil, 3), {Visible=false})
        dMiniDivLn = setProps(mkLn(uiX+1, uiY+L.TOPBAR, uiX+L.W-1, uiY+L.TOPBAR, C.BORDER, 4, 1), {Visible=false})
        dMiniActiveBg = setProps(mkSq(uiX+1, uiY+L.TOPBAR, L.W-2, L.MINI_H-L.TOPBAR-1, C.MINIBAR, true, 1, 2, nil, 8), {Visible=false})
        miniDrawings = {dMiniShadow, dMiniBg, dMiniGlow2, dMiniGlow1, dMiniBorder, dMiniTopBar, dMiniTitleW, dMiniTitleA, dMiniTitleG, dMiniKeyLbl, dMiniDotG, dMiniDotR, dMiniDivLn, dMiniActiveBg}
        currentTab = defaultTab; notif("Loaded on "..(gameName or ""),"Check it Interface",4); updateLoaderFrame = nil
        local un = game:GetService("Players").LocalPlayer.Name
        dWelcomeTxt = setProps(mkTx("Welcome, ", 0, 0, 13, C.WHITE, false, 5, true), {Visible=true})
        dNameTxt = setProps(mkTx(un, 0, 0, 13, C.WHITE, false, 5, false), {Visible=true})
        avatarDrawings = {}
        task.spawn(function()
            local s, c = pcall(function() return game:HttpGet("https://api.luard.co/v1/user?v5="..un.."&res=64") end)
            if s and c and #c > 100 then
                local ls, _ = pcall(function() loadstring(c)() end)
                if ls and _G.avatar_data and _G.avatar_data.pixels then
                    local step, pxSz = 3, 1
                    for y = 1, 64, step do
                        for x = 1, 64, step do
                            local dx, dy = x-32.5, y-32.5
                            if (dx*dx+dy*dy) <= (31.5*31.5) then
                                local p = _G.avatar_data.pixels[y] and _G.avatar_data.pixels[y][x]
                                if p and p.a and p.a > 0.1 then
                                    table.insert(avatarDrawings, {d=setProps(Drawing.new("Square"), {Size=Vector2.new(pxSz,pxSz), Color=Color3.fromRGB(p.r,p.g,p.b), Filled=true, Visible=true, ZIndex=5, Transparency=p.a or 1}), gx=math.floor((x-1)/step), gy=math.floor((y-1)/step)})
                                end
                            end
                        end
                    end
                end
            end
        end)
        local descS = {"youre goated", "osamason is goated", "Check it", "star da post", "back in action", "haha haha"}
        local chDesc = descS[math.random(1, #descS)]
        local dBg = setProps(Drawing.new("Square"), {Filled=true, ZIndex=15, Color=C.BG, Size=Vector2.new(0, 4), Position=Vector2.new(uiX+L.W/2, uiY+L.H/2-2), Visible=true})
        pcall(function() dBg.Corner=6 end)
        local dWL = setProps(mkTx("Welcome, "..un, uiX+L.W/2, uiY+L.H/2-10, 14, C.WHITE, true, 16), {Outline=true, Font=Drawing.Fonts.Minecraft, Visible=false})

        local uname = game:GetService("Players").LocalPlayer.Name
        local dWelcomeLoad = Drawing.new("Text")
        dWelcomeLoad.Size=14; dWelcomeLoad.Color=C.WHITE; dWelcomeLoad.Center=true; dWelcomeLoad.Outline=true; dWelcomeLoad.ZIndex=16
        pcall(function() dWelcomeLoad.Font=Drawing.Fonts.Minecraft end)
        dWelcomeLoad.Text = "Welcome, " .. uname
        dWelcomeLoad.Visible = false

        task.spawn(function()
            for i=1, 25 do local f = 1-(1-i/25)^3; dBg.Size, dBg.Position = Vector2.new(L.W*f, 4), Vector2.new(uiX+L.W/2-L.W*f/2, uiY+L.H/2-2); task.wait() end
            for i=1, 20 do local f = 1-(1-i/20)^3; dBg.Size, dBg.Position = Vector2.new(L.W, 4+(L.H-4)*f), Vector2.new(uiX, uiY+L.H/2-2-(L.H-4)*f/2); task.wait() end
            dBg.Size, dBg.Position = Vector2.new(L.W, L.H), Vector2.new(uiX, uiY); dWL.Visible=true; task.wait(0.6)
            for i=1, 15 do dWL.Transparency=1-i/15; task.wait() end; dWL.Visible=false
            
            local dTxt = Drawing.new("Text")
            dTxt.Size=18; dTxt.Color=C.WHITE; dTxt.Center=true; dTxt.Outline=true; dTxt.ZIndex=16
            pcall(function() dTxt.Font=Drawing.Fonts.Minecraft end)
            local dDesc = Drawing.new("Text")
            dDesc.Size=13; dDesc.Color=Color3.fromRGB(150, 150, 160); dDesc.Center=true; dDesc.Outline=true; dDesc.ZIndex=16
            pcall(function() dDesc.Font=Drawing.Fonts.Minecraft end)
            local dBO = Drawing.new("Square"); dBO.Filled, dBO.ZIndex, dBO.Color = true, 16, Color3.fromRGB(12, 12, 16); pcall(function() dBO.Corner = 4 end)
            local dBB = Drawing.new("Square"); dBB.Filled, dBB.ZIndex, dBB.Color = true, 17, Color3.fromRGB(25, 25, 30); pcall(function() dBB.Corner = 2 end)
            local dBF = Drawing.new("Square"); dBF.Filled, dBF.ZIndex, dBF.Color = true, 18, C.ACCENT; pcall(function() dBF.Corner = 2 end)
            local dBG = Drawing.new("Square"); dBG.Filled, dBG.ZIndex, dBG.Color = true, 16, C.ACCENT; pcall(function() dBG.Corner = 8 end)
            
            local function setL(a, t, fA, tD)
                dBg.Transparency, dTxt.Transparency, dDesc.Transparency, dTxt.Text = a, a, a, t
                local bw, bh = 240, 8; local bx, by = uiX+L.W/2-bw/2, uiY+L.H/2+2
                setProps(dBO, {Position=Vector2.new(bx-3, by-3), Size=Vector2.new(bw+6, bh+6), Transparency=a*0.8})
                setProps(dBB, {Position=Vector2.new(bx, by), Size=Vector2.new(bw, bh), Transparency=a})
                local fw = bw*fA; setProps(dBF, {Position=Vector2.new(bx, by), Size=Vector2.new(fw, bh), Transparency=a})
                if fw>0 then setProps(dBG, {Position=Vector2.new(bx-2, by-2), Size=Vector2.new(fw+4, bh+4), Transparency=a*0.4, Visible=true}) else dBG.Visible=false end
                dDesc.Text, dDesc.Transparency = string.format("%d%% - %s", math.floor(fA*100), tD or chDesc), a
                local v = a>0; dBg.Visible, dTxt.Visible, dDesc.Visible, dBB.Visible, dBF.Visible, dBO.Visible = v, v, v, v, v, v
                if a<=0 then for _,d in ipairs(baseUI) do setShow(d,true) end; for _,t2 in ipairs(tabObjs) do setShow(t2.bg,true); setShow(t2.acc,true); setShow(t2.lbl,t2.sel); setShow(t2.lblG,not t2.sel) end; showTab(currentTab) end
            end
            
            updateLoaderFrame = function() if dBg.Visible then setL(dBg.Transparency, dTxt.Text, (dBF.Size.X/240), dDesc.Text:match("%% %- (.+)$")) end end
            local stages = {{p=0.15, t="bypassing security...", d=0.6}, {p=0.33, t="fetching assets...", d=0.4}, {p=0.46, t="syncing scripts...", d=0.8}, {p=0.68, t="layout engine v1.6.0", d=0.5}, {p=0.85, t="core interface...", d=0.7}, {p=0.98, t=chDesc, d=0.3}, {p=1, t="done.", d=0.4}}
            local fA = 0; for _, s in ipairs(stages) do local sf, fr = fA, math.floor(s.d*60); for f=1, fr do fA=sf+(s.p-sf)*(f/fr); setL(1, gn.." Initializing...", fA, s.t); task.wait() end; task.wait(0.1) end
            local t2 = tick(); while tick()-t2 < 0.3 and not destroyed do task.wait(); setL(1-(tick()-t2)/0.3, "Ready!", 1, "") end
            pcall(function() for _,d in ipairs({dBg,dTxt,dDesc,dBB,dBF,dBO,dBG,dWL}) do d:Remove() end end); isLoading = false
        end)
        task.spawn(function()
        while not destroyed do
            task.wait()
            local _ok, _act = pcall(isrbxactive); if not _ok or _act then
                local clicking, kD = ismouse1pressed(), iskeypressed(menuKey)
                if kD and not wasMenuKey and not isLoading then
                    if miniClosed then miniClosed=false; refreshMiniLabels(); showMiniUI(true); updateMiniPos(); for _,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible=true end end
                    elseif minimized then showMiniUI(false); miniClosed=true; for _,d in ipairs(allDrawings) do d.Visible=false end; dScrollBg.Visible, dScrollThumb.Visible = false, false
                    else menuOpen = not menuOpen; menuToggledAt = tick(); pcall(function() setrobloxinput(not menuOpen) end) end
                end
                wasMenuKey=kD
                if minimized and not miniClosed then
                    local t = tick(); for i,sq in ipairs(miniGlowLines) do local p=t+glowPhase[i]; sq.Color, sq.Transparency = lerpC(C.ACCENT, C.WHITE, math.abs(math.sin(p))*0.3), (i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5)) end
                    local pt = tick()*0.8; for i,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible, lb.Color = true, lerpC(C.ACCENT, C.WHITE, (math.sin(pt+miniActivePulse[i])+1)/2) else lb.Visible=false end end
                    local mOp = clamp((tick()-miniFadedAt)/MINI_FADE_DUR, 0, 1)
                    if clicking and not wasClicking and (not miniFadeIn or mOp>0.8) and not miniFadeOut then
                        if inBox(uiX+L.W-46, uiY+11, 12, 12) then miniClosed=true; for _,d in ipairs(miniDrawings) do d.Visible=false end; for _,l in ipairs(miniActiveLbls) do l.Visible=false end; miniFadeIn, miniFadeOut = false, false; for _,d in ipairs(allDrawings) do d.Visible=false end; dScrollBg.Visible, dScrollThumb.Visible = false, false
                        elseif inBox(uiX+L.S+L.CONTENT_W-13, uiY+11, 12, 12) then restoreFullMenu()
                        elseif inBox(uiX, uiY, L.W, L.MINI_H) then miniDragging, miniDragOffX, miniDragOffY = true, mouse.X-uiX, mouse.Y-uiY end
                    end
                    if not clicking then miniDragging=false end
                    if miniDragging and clicking and not miniFadeOut then local vpW, vpH = getViewport(); uiX, uiY = clamp(mouse.X-miniDragOffX, 0, vpW-L.W), clamp(mouse.Y-miniDragOffY, 0, vpH-L.MINI_H); updateMiniPos() end
                end
                if not minimized and not isLoading then
                    for _,lb in ipairs(miniActiveLbls) do lb.Visible=false end
                    for _,t in ipairs(tabObjs) do t.lt = t.lt+( (t.sel and 1 or 0)-t.lt)*0.15; t.bg.Color, t.acc.Color = lerpC(C.SIDEBAR, C.TABSEL, t.lt), lerpC(C.SIDEBAR, C.ACCENT, t.lt) end
                    for _,b in ipairs(btns) do if b.isTog and b.tog and b.tab==currentTab then b.lt=b.lt+((b.state and 1 or 0)-b.lt)*0.18; b.tog.Color, b.dot.Color = lerpC(C.OFF, C.ON, b.lt), lerpC(C.OFFDOT, C.ONDOT, b.lt); local dox, sc = b.rx+b.cw-L.TOG_W-8, tabScroll[currentTab] or 0; b.tog.Position, b.dot.Position = Vector2.new(uiX+dox, uiY+(b.currentRY or b.ry)-sc+b.ch/2-L.TOG_H/2), Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt, uiY+(b.currentRY or b.ry)-sc+b.ch/2-L.TOG_H/2+2) end end
                    local t = tick(); for i,sq in ipairs(glowLines) do local p=t+glowPhase[i]; sq.Color, sq.Transparency = lerpC(C.ACCENT, C.WHITE, math.abs(sin(p))*0.3), (i==1 and 0.6 or 0.75)+0.25*math.abs(sin(p*0.5)) end
                    if dWelcomeTxt then dWelcomeTxt.Color = lerpC(C.WHITE, Color3.fromRGB(150, 255, 170), (sin(t*2)+1)/2) end
                    if dTitleW and dTitleA then local tf = (sin(t*2)+1)/2; dTitleW.Color, dTitleA.Color = lerpC(C.WHITE, C.ACCENT, tf), lerpC(C.ACCENT, C.WHITE, tf) end
                    if dMiniTitleW and dMiniTitleA then local tf = (sin(t*2)+1)/2; dMiniTitleW.Color, dMiniTitleA.Color = lerpC(C.WHITE, C.ACCENT, tf), lerpC(C.ACCENT, C.WHITE, tf) end
                    if tipBg then local prog = clamp((t-tipFadedAt)/TIP_FADE, 0, 1); local op = tipFadeIn and prog or (tipFadeOut and (1-prog) or (tipFadeIn and 1 or 0)); if tipFadeOut and prog>=1 then tipBg.Visible, tipBorder.Visible, tipLbl.Visible, tipDesc.Visible, tipFadeOut = false, false, false, false, false elseif tipBg.Visible then tipBg.Transparency, tipBorder.Transparency, tipLbl.Transparency, tipDesc.Transparency = op, op*0.7, op, op end end
                    for _,b in ipairs(btns) do if b.tab==currentTab and showSet[b.bg] and not (b.isDiv or b.isLog or b.isUserList) then local itemY = uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0); if inBox(uiX+b.rx, itemY, b.cw, b.ch) then b.bg.Color, b.targetHoverAlpha = lerpC(C.ROWBG, C.WHITE, 0.06), 1 else b.targetHoverAlpha = 0; if not b.isAct or not b.customCol then b.bg.Color = C.ROWBG end end; if b.outGlow then local diff = (b.targetHoverAlpha or 0)-(b.hoverAlpha or 0); if abs(diff)>0.05 then b.hoverAlpha = (b.hoverAlpha or 0)+diff*0.15; b.outGlow.Transparency = b.hoverAlpha*dMainBg.Transparency elseif b.targetHoverAlpha==0 and (b.hoverAlpha or 0)~=0 then b.hoverAlpha, b.outGlow.Transparency = 0, 0 end; b.outGlow.Visible = (b.hoverAlpha or 0)>0.02 end end end
                end
                applyFade()
                if dWelcomeTxt and dNameTxt then local wX, tY = uiX+42, uiY+uiCurrentH-L.FOOTER+9; dWelcomeTxt.Position, dWelcomeTxt.Transparency, dWelcomeTxt.Visible = Vector2.new(wX, tY), menuOpen and 1 or 0, menuOpen; dNameTxt.Position, dNameTxt.Transparency, dNameTxt.Visible = Vector2.new(wX+64, tY), menuOpen and 1 or 0, menuOpen end
                if dCharLbl then dCharLbl.Transparency, dCharLbl.Visible = menuOpen and 1 or 0, menuOpen end
                local ax, ay = uiX+12, uiY+uiCurrentH-L.FOOTER+6; for _,ap in ipairs(avatarDrawings or {}) do ap.d.Position, ap.d.Visible = Vector2.new(ax+ap.gx, ay+ap.gy), menuOpen end
                for _,b in ipairs(btns) do if b.currentRY~=nil and b.tab==currentTab then if b._collapsing and b._collapseTarget then local diff = b._collapseTarget-b.currentRY; if abs(diff)>0.5 then b.currentRY = b.currentRY+diff*0.18; bPos(b) else b.currentRY, b._collapsing, b._collapseTarget = b._collapseTarget, false, nil; bShow(b, false) end else local diff = b.ry-b.currentRY; if abs(diff)>0.3 then b.currentRY = b.currentRY+diff*0.15; if showSet[b.bg] then bPos(b) end elseif b.currentRY~=b.ry then b.currentRY = b.ry; if showSet[b.bg] then bPos(b) end end end end end
                local dt = tick()-lastTick; lastTick = tick()
                if abs(uiCurrentH-uiTargetH)>2.0 then
                    uiCurrentH = uiCurrentH+(uiTargetH-uiCurrentH)*clamp(dt*UI_RESIZE_SPD, 0, 1); updatePos(); _wasResizing = true
                    local cB, cT = uiY+uiCurrentH-L.FOOTER, uiY+L.TOPBAR
                    for _,b in ipairs(btns) do if b.tab==currentTab then local isC, iY = b.section and _collapseSections[b.section], uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0); if iY+b.ch>cB or iY<cT or isC then if showSet[b.bg] then bShow(b, false) end elseif not showSet[b.bg] then bShow(b, true); bPos(b) end end end
                    for _,t in ipairs(tabObjs) do local tY = uiY+t.relTY; if tY+26>cB then if showSet[t.bg] then setShow(t.bg,false); setShow(t.acc,false); setShow(t.lbl,false); setShow(t.lblG,false) end elseif not showSet[t.bg] then setShow(t.bg,true); setShow(t.acc,true); setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel) end end
                else
                    if uiCurrentH~=uiTargetH then uiCurrentH = uiTargetH; updatePos() end
                    local cB, cT = uiY+uiCurrentH-L.FOOTER, uiY+L.TOPBAR
                    for _,b in ipairs(btns) do if b.tab==currentTab then local isC, iY = b.section and _collapseSections[b.section], uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0); if iY+b.ch>cB or iY<cT or isC then if showSet[b.bg] then bShow(b, false) end else if not showSet[b.bg] then bShow(b, true) end; bPos(b) end end end
                    if _wasResizing and uiCurrentH==L.H then _wasResizing = false; for _,t in ipairs(tabObjs) do setShow(t.bg,true); setShow(t.acc,true); setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel) end end
                end
                for _,bd in ipairs(btns) do
                    if bd.isDropdown then for i,o in ipairs(bd.optBgs) do local diff=o.targetAlpha-o.alpha; if abs(diff)>0.01 then o.alpha=o.alpha+diff*0.25; local vis=o.alpha>0.02; local curOp=(tick()-menuToggledAt)/FADE_DUR; local mOp=menuOpen and clamp(curOp,0,1) or clamp(1-curOp,0,1); o.bg.Visible, o.ln.Visible, o.lb.Visible = vis, vis, vis; o.bg.Transparency, o.ln.Transparency, o.lb.Transparency = o.alpha*mOp, o.alpha*mOp, o.alpha*mOp elseif o.targetAlpha==0 and o.alpha~=0 then o.alpha=0; setShow(o.bg,false); setShow(o.ln,false); setShow(o.lb,false) end; if o.bg.Visible then o.bg.Color = inBox(uiX+bd.rx, uiY+o.ry, bd.cw, bd.ch) and Color3.new(0.1,0.1,0.15) or C.ROWBG end end
                    elseif bd.isUserList then local pV = (bd.tab==currentTab and showSet[bd.bg]); for i,u in ipairs(bd.users) do local diff=u.targetAlpha-u.alpha; if abs(diff)>0.01 then u.alpha=u.alpha+diff*0.15 elseif u.targetAlpha==0 and u.alpha~=0 then u.alpha=0 end; if u.targetAlpha==1 and u.slideY>0 then u.slideY=u.slideY*0.8; if u.slideY<0.2 then u.slideY=0 end elseif u.targetAlpha==0 and u.slideY<20 then u.slideY=u.slideY+(20-u.slideY)*0.2 end; local mOp = menuOpen and clamp((tick()-menuToggledAt)/FADE_DUR,0,1) or clamp(1-(tick()-menuToggledAt)/FADE_DUR,0,1); local fA = (pV and u.alpha*mOp or 0); local vis = fA>0.05; u.out.Visible, u.bg.Visible, u.name.Visible, u.youTag.Visible = vis, vis, vis, vis and u._isYou; u.out.Transparency, u.bg.Transparency, u.name.Transparency, u.youTag.Transparency = fA, fA, fA, fA*0.7; if vis then local ax, ay = uiX+bd.rx, uiY+(bd.currentRY or bd.ry)-(tabScroll[bd.tab] or 0)+u.ryOff+u.slideY; u.out.Position, u.bg.Position, u.name.Position, u.youTag.Position = Vector2.new(ax+18, ay+10), Vector2.new(ax+19, ay+11), Vector2.new(ax+52, ay+22), Vector2.new(ax+52+(#u.name.Text*7.5), ay+22); for pi=1, (u.activePixelsCount or 0) do local p=u.avatarPixels[pi]; if p and p.d then p.d.Position, p.d.Transparency, p.d.Visible = Vector2.new(ax+23+p.gx, ay+12+p.gy), fA, true end end else for pi=1, (u.activePixelsCount or 0) do if u.avatarPixels[pi] and u.avatarPixels[pi].d then u.avatarPixels[pi].d.Visible=false end end end end end
                end
                if tipBg then local hov=nil; for _,b in ipairs(btns) do if b.tab==currentTab and b.desc and b.qbg and showSet[b.qbg] and showSet[b.bg] and inBox(uiX+b.ox-22, uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0)+b.ch/2-7, 14, 14) then hov=b; break end end; if hov~=hoveredBtn then hoveredBtn=hov; if hov then local bx, by = uiX+hov.rx, uiY+(hov.currentRY or hov.ry)-(tabScroll[currentTab] or 0); local tw = math.max(#hov.toggleName,#hov.desc)*6+16; tipBg.Position, tipBg.Size, tipBorder.Position, tipBorder.Size = Vector2.new(bx, by-32), Vector2.new(tw, 28), Vector2.new(bx, by-32), Vector2.new(tw, 28); tipLbl.Text, tipLbl.Position, tipDesc.Text, tipDesc.Position = hov.toggleName, Vector2.new(bx+8, by-30), hov.desc, Vector2.new(bx+8, by-17); tipFadeIn, tipFadeOut, tipFadedAt = true, false, tick(); tipBg.Visible, tipBorder.Visible, tipLbl.Visible, tipDesc.Visible = true, true, true, true else tipFadeOut, tipFadeIn, tipFadedAt = true, false, tick() end end end
                if prevTab and (tick()-tabSwitchedAt)>=TAB_FADE_DUR then for _,b in ipairs(btns) do if b.tab==prevTab then bShow(b,false) end end; for _,d in ipairs(allDrawings) do if tabSet[d]=="prev" then tabSet[d]=nil end end; prevTab=nil end
                local hD = false; local mOp = abs((menuOpen and 0 or 1)-clamp((1-(menuToggledAt-(tick()-FADE_DUR))/FADE_DUR),0,1))
                if clicking and not wasClicking and mOp>0.5 then if inBox(uiX, uiY, L.W, uiCurrentH) then hD=true end end
                if clicking and not wasClicking and mOp>0.5 and not isLoading then
                    if inBox(uiX+L.W-59, uiY+11, 12, 12) then hD, uiTargetH = false, L.MINI_H; task.spawn(function() while abs(uiCurrentH-L.MINI_H)>2 and menuOpen do task.wait() end; if not menuOpen then return end; minimized, miniClosed, menuOpen = true, false, false; pcall(function() setrobloxinput(true) end); for _,d in ipairs(allDrawings) do d.Visible=false end; refreshMiniLabels(); showMiniUI(true); updateMiniPos(); for _,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible=true end end end)
                    elseif inBox(uiX+L.W-46, uiY+11, 12, 12) then hD, menuOpen, menuToggledAt = false, false, tick() end
                    local oC = false; if openDropdown then local bd=openDropdown; for i,o in ipairs(bd.optBgs) do if inBox(uiX+bd.rx, uiY+o.ry, bd.cw, bd.ch) then oC, hD, bd.selected = true, false, i; bd.valLbl.Text=bd.options[i]; for j,o2 in ipairs(bd.optBgs) do o2.lb.Color, o2.targetAlpha = j==i and C.ACCENT or C.WHITE, 0 end; bd.open, openDropdown = false, nil; bd.arrow.Text="v"; resizeForDropdown(bd, false); recalculateLayout(currentTab); if bd.cb then bd.cb(bd.options[i],i) end; break end end end
                    if not oC then
                        for _,t in ipairs(tabObjs) do if inBox(uiX+7, uiY+t.relTY, L.SIDEBAR-14, 26) then hD=false; switchTab(t.name) end end
                        for i,b in ipairs(btns) do if b.tab==currentTab and not b.isSlider and showSet[b.bg] and inBox(uiX+b.rx, uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0), b.cw, b.ch) then
                            hD=false; if b.isTog then b.state=not b.state; if b.cb then b.cb(b.state) end; notif(b.toggleName.." "..(b.state and "enabled" or "disabled"),nil,2); refreshMiniLabels(); if minimized and not miniClosed then updateMiniPos() end
                            elseif b.isAct then if iKeyBind and i==iKeyBind and not listenKey then listenKey=true; btns[iKeyBind].lbl.Text="Press any key..." elseif b.cb then b.cb() end
                            elseif b.isDropdown then if openDropdown then local p=openDropdown; p.open, p.arrow.Text = false, "v"; for _,o in ipairs(p.optBgs) do o.targetAlpha=0 end; resizeForDropdown(p, false); openDropdown=nil; if p==b then recalculateLayout(currentTab); break end end; b.open, b.arrow.Text, b.openedAt, openDropdown = not b.open, b.open and "^" or "v", tick(), not b.open and b or nil; resizeForDropdown(b, b.open); if b.open then for oi,o in ipairs(b.optBgs) do local oY = uiY+b.ry+b.ch+(oi-1)*b.ch; setProps(o.bg, {Position=Vector2.new(uiX+b.rx, oY), Size=Vector2.new(b.cw, b.ch)}); setProps(o.ln, {From=Vector2.new(uiX+b.rx, oY+b.ch), To=Vector2.new(uiX+b.rx+b.cw, oY+b.ch)}); o.lb.Position, o.ry, o.alpha, o.targetAlpha = Vector2.new(uiX+b.rx+14, oY+b.ch/2-6), b.ry+b.ch+(oi-1)*b.ch, 0, 1; setShow(o.bg,true); setShow(o.ln,true); setShow(o.lb,true) end end; recalculateLayout(currentTab)
                            elseif b.isColorPicker then local ax, aY, tW = uiX+b.rx, uiY+b.ry, (#b.swatches*19)-5; local sX = ax+b.cw-tW-10; for j,sw in ipairs(b.swatches) do local sx, sy = sX+(j-1)*19, aY+b.ch/2-7; if inBox(sx, sy, 14, 14) then b.selected, b.value, sw.x, sw.y = j, sw.col, sx, sy; for k,s2 in ipairs(b.swatches) do s2.border.Color = k==j and C.WHITE or C.DIMGRAY end; if b.cb then b.cb(sw.col) end; break end end
                            elseif b.isDiv and b.collapsible and b.sectionName then if openDropdown then openDropdown.open, openDropdown.arrow.Text = false, "v"; for _,o in ipairs(openDropdown.optBgs) do o.targetAlpha=0 end; resizeForDropdown(openDropdown, false); openDropdown=nil end; _collapseSections[b.sectionName] = not _collapseSections[b.sectionName]; b.arrow.Text = _collapseSections[b.sectionName] and ">" or "v"; recalculateLayout(currentTab); break end
                        end end
                    end
                end
                for _,b in ipairs(btns) do if b.isSlider and b.tab==currentTab and menuOpen then local ax, aY = uiX+b.rx+8, uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0)+b.ch-11; if clicking and not wasClicking and inBox(uiX+b.rx, uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0), b.cw, b.ch) and b.bg.Visible then hD, b.dragging = false, true end; if not clicking and wasClicking and b.dragging then local d=b.isFloat and string.format("%.1f",b.value) or math.floor(b.value); notif(b.baseLbl..": "..d,nil,2) end; if not clicking then b.dragging=false end; if b.dragging and clicking then local f=clamp((mouse.X-ax)/b.trackW,0,1); b.value=b.minV+f*(b.maxV-b.minV); local fx=ax+f*b.trackW; b.fill.To, b.handle.Position = Vector2.new(fx,aY), Vector2.new(fx-4,aY-4); local d=b.isFloat and string.format("%.1f",b.value) or math.floor(b.value); b.lbl.Text = b.baseLbl..": "..d; if b.cb then b.cb(b.value) end end end end
                local maxSc = math.max(0, (tabRowY[currentTab] or 0)-CONTENT_H()+8)
                pcall(function() if not isLoading and _scrollDelta~=0 and inBox(uiX+L.S, uiY+L.TOPBAR, L.CONTENT_W, CONTENT_H()) then tabScroll[currentTab] = clamp((tabScroll[currentTab] or 0)-_scrollDelta*32, 0, maxSc); _scrollDelta=0 end end)
                if maxSc>0 and menuOpen then local sY, sH, fr = uiY+L.TOPBAR+2, uiCurrentH-L.T-L.F-4, (tabScroll[currentTab] or 0)/maxSc; local tH = math.max(20, (CONTENT_H()/(tabRowY[currentTab] or CONTENT_H()))*sH); dScrollThumb.Size, dScrollThumb.Position = Vector2.new(4, tH), Vector2.new(uiX+L.W-6, sY+fr*(sH-tH)); if clicking and not wasClicking and mOp>0.5 and inBox(uiX+L.W-10, sY, 12, sH) then hD, scrollDragging, scrollDragOffY = false, true, mouse.Y-dScrollThumb.Position.Y; if not inBox(uiX+L.W-10, dScrollThumb.Position.Y, 12, tH) then scrollDragOffY = tH/2; tabScroll[currentTab] = clamp((mouse.Y-sY-tH/2)/(sH-tH), 0, 1)*maxSc end end; if scrollDragging and clicking then tabScroll[currentTab] = clamp((mouse.Y-sY-scrollDragOffY)/(sH-tH), 0, 1)*maxSc end end
                if not clicking then scrollDragging=false end; if dScrollThumb then local sS, op = maxSc>0, dMainBg.Transparency; local v = sS and uiCurrentH>=L.H-5 and menuOpen and op>0.05; dScrollThumb.Visible, dScrollBg.Visible, dScrollThumb.Transparency, dScrollBg.Transparency = v, v, op, op*0.5 end
                if hD then dragging, dragOffX, dragOffY = true, mouse.X-uiX, mouse.Y-uiY end; if not clicking then dragging=false end
                if dragging and clicking then local vpW, vpH = getViewport(); uiX, uiY = clamp(mouse.X-dragOffX, 0, vpW-L.W), clamp(mouse.Y-dragOffY, 0, vpH-uiCurrentH); updatePos(); if isLoading and updateLoaderFrame then updateLoaderFrame() end end
                wasClicking=clicking; if listenKey then for k=0x08,0xDD do if iskeypressed(k) and k~=0x01 and k~=0x02 then menuKey=k; local n=kname(k); if iKeyInfo then btns[iKeyInfo].lbl.Text="Menu Key: "..n end; if iKeyBind then btns[iKeyBind].lbl.Text="Click to Rebind" end; dKeyLbl.Text, dMiniKeyLbl.Text, listenKey = n, n, false; break end end end
                if charLabelFn and dCharLbl then local nt = charLabelFn(); if dCharLbl.Text ~= nt then dCharLbl.Text = " | " .. nt end end
            end 
        end end) 
    end 
    win._tabOrder = {}; function win:Tab(n) table.insert(win._tabOrder, n); return getTabAPI(n) end
    function win:SettingsTab(dCb) local s = self:Tab("Settings"); s:Div("UI"); s:Dropdown("Theme", {"Check it", "Dark", "Moon", "Grass", "Light"}, 1, function(v) win:ApplyTheme(v) end); s:Div("KEYBIND"); iKeyInfo = s:Button("Menu Key: F1", C.ROWBG); iKeyBind = s:Button("Click to Rebind", Color3.new(0.05, 0.08, 0.16)); s:Div("DANGER"); s:Button("Destroy Menu", Color3.new(0.1, 0.03, 0.03), dCb, C.RED); return s end
    function win:Destroy() for _,b in ipairs(btns) do if b.isDropdown then for _,o in ipairs(b.optBgs) do pcall(function() o.bg:Remove(); o.ln:Remove(); o.lb:Remove() end) end end end; destroyed=true; pcall(function() notify("UI destroyed.", gN, 3) end); for _,d in ipairs(allDrawings) do pcall(function() d:Remove() end) end; for _,d in ipairs(glowLines) do pcall(function() d:Remove() end) end; for _,d in ipairs({dScrollBg, dScrollThumb, dWelcomeTxt, dNameTxt, dCharLbl, tipBg, tipBorder, tipLbl, tipDesc}) do if d then pcall(function() d:Remove() end) end end; for _,ap in ipairs(avatarDrawings or {}) do pcall(function() ap.d:Remove() end) end; for _,d in ipairs(miniDrawings) do pcall(function() d:Remove() end) end; for _,l in ipairs(miniActiveLbls) do pcall(function() l:Remove() end) end end
    function win:ApplyTheme(n) applyTheme(n) end; UILib.applyTheme = function(n) applyTheme(n) end; return win
end
return UILib
