local UILib = {}
local _collapseSections = {}
local tick = tick or os.clock
local warn = warn or function() end
if not task then
    task = {
        spawn = function(fn) coroutine.wrap(fn)() end,
        wait = function(t) local start = tick(); while (tick() - start) < (t or 0) do end end,
        delay = function(t, fn) task.spawn(function() task.wait(t); fn() end) end
    }
end
local THEMES = {
    ["Check it"] = {
        ACCENT=Color3.fromRGB(70,120,255),  BG=Color3.fromRGB(9,11,20),
        SIDEBAR=Color3.fromRGB(12,15,27),   CONTENT=Color3.fromRGB(11,13,23),
        TOPBAR=Color3.fromRGB(7,9,17),      BORDER=Color3.fromRGB(30,40,72),
        ROWBG=Color3.fromRGB(14,18,33),     TABSEL=Color3.fromRGB(20,35,85),
        WHITE=Color3.fromRGB(215,220,240),  GRAY=Color3.fromRGB(100,112,145),
        DIMGRAY=Color3.fromRGB(28,33,52),
        ON=Color3.fromRGB(45,85,195),       OFF=Color3.fromRGB(20,24,42),
        ONDOT=Color3.fromRGB(175,198,255),  OFFDOT=Color3.fromRGB(55,65,95),
        DIV=Color3.fromRGB(22,27,48),     MINIBAR=Color3.fromRGB(11,13,22),
    },
    ["Moon"] = {
        ACCENT=Color3.fromRGB(150,150,165),  BG=Color3.fromRGB(12,12,14),
        SIDEBAR=Color3.fromRGB(16,16,18),    CONTENT=Color3.fromRGB(14,14,16),
        TOPBAR=Color3.fromRGB(10,10,12),     BORDER=Color3.fromRGB(40,40,46),
        ROWBG=Color3.fromRGB(18,18,22),      TABSEL=Color3.fromRGB(30,30,36),
        WHITE=Color3.fromRGB(220,220,225),   GRAY=Color3.fromRGB(120,120,130),
        DIMGRAY=Color3.fromRGB(40,40,45),
        ON=Color3.fromRGB(100,100,115),      OFF=Color3.fromRGB(25,25,30),
        ONDOT=Color3.fromRGB(200,200,215),   OFFDOT=Color3.fromRGB(70,70,80),
        DIV=Color3.fromRGB(30,30,36),        MINIBAR=Color3.fromRGB(16,16,20),
    },
    ["Grass"] = {
        ACCENT=Color3.fromRGB(60,200,100),  BG=Color3.fromRGB(8,14,10),
        SIDEBAR=Color3.fromRGB(10,18,13),   CONTENT=Color3.fromRGB(9,16,11),
        TOPBAR=Color3.fromRGB(6,11,8),      BORDER=Color3.fromRGB(25,55,35),
        ROWBG=Color3.fromRGB(11,20,14),     TABSEL=Color3.fromRGB(18,45,25),
        WHITE=Color3.fromRGB(200,235,210),  GRAY=Color3.fromRGB(90,130,105),
        DIMGRAY=Color3.fromRGB(20,40,28),
        ON=Color3.fromRGB(30,140,65),       OFF=Color3.fromRGB(15,30,20),
        ONDOT=Color3.fromRGB(150,240,180),  OFFDOT=Color3.fromRGB(45,80,58),
        DIV=Color3.fromRGB(18,35,24),     MINIBAR=Color3.fromRGB(10,18,13),
    },
    ["Light"] = {
        ACCENT=Color3.fromRGB(50,100,255),  BG=Color3.fromRGB(230,233,245),
        SIDEBAR=Color3.fromRGB(215,220,235),CONTENT=Color3.fromRGB(220,224,238),
        TOPBAR=Color3.fromRGB(200,205,225), BORDER=Color3.fromRGB(170,178,210),
        ROWBG=Color3.fromRGB(210,214,230),  TABSEL=Color3.fromRGB(190,205,240),
        WHITE=Color3.fromRGB(25,30,60),     GRAY=Color3.fromRGB(90,100,140),
        DIMGRAY=Color3.fromRGB(180,185,210),
        ON=Color3.fromRGB(60,120,255),      OFF=Color3.fromRGB(180,185,210),
        ONDOT=Color3.fromRGB(255,255,255),  OFFDOT=Color3.fromRGB(130,140,175),
        DIV=Color3.fromRGB(185,190,215),  MINIBAR=Color3.fromRGB(205,210,228),
    },
    ["Dark"] = {
        ACCENT=Color3.fromRGB(180,180,180), BG=Color3.fromRGB(4,4,6),
        SIDEBAR=Color3.fromRGB(6,6,9),      CONTENT=Color3.fromRGB(5,5,8),
        TOPBAR=Color3.fromRGB(3,3,5),       BORDER=Color3.fromRGB(20,20,28),
        ROWBG=Color3.fromRGB(7,7,10),       TABSEL=Color3.fromRGB(15,15,22),
        WHITE=Color3.fromRGB(190,190,195),  GRAY=Color3.fromRGB(80,80,90),
        DIMGRAY=Color3.fromRGB(15,15,20),
        ON=Color3.fromRGB(100,100,110),     OFF=Color3.fromRGB(12,12,16),
        ONDOT=Color3.fromRGB(220,220,225),  OFFDOT=Color3.fromRGB(45,45,55),
        DIV=Color3.fromRGB(14,14,18),     MINIBAR=Color3.fromRGB(6,6,8),
    },
}
UILib.Themes = THEMES
UILib.Colors = THEMES["Check it"] 
_G.UILib = UILib
print("[UILib] v1.7.0 loaded")
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerpC(a,b,t)
    return Color3.fromRGB(
        math.floor(a.R*255+(b.R*255-a.R*255)*t),
        math.floor(a.G*255+(b.G*255-a.G*255)*t),
        math.floor(a.B*255+(b.B*255-a.B*255)*t))
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
local function mkSq(x,y,w,h,col,filled,transp,zi,thick,corner)
    local s = Drawing.new("Square")
    s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h)
    s.Color=col; s.Filled=filled; s.Transparency=transp or 1
    s.ZIndex=zi or 1; s.Visible=true
    if not filled then s.Thickness=thick or 1 end
    if corner and corner>0 then pcall(function() s.Corner=corner end) end
    return s
end
local function mkTx(txt,x,y,sz,col,ctr,zi,bold)
    local t = Drawing.new("Text")
    t.Text=txt; t.Position=Vector2.new(x,y); t.Size=sz or 13
    t.Color=col or C.WHITE; t.Center=ctr or false; t.Outline=false
    t.Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System
    t.Transparency=1; t.ZIndex=zi or 3; t.Visible=true
    return t
end
local function mkLn(x1,y1,x2,y2,col,zi,thick)
    local l = Drawing.new("Line")
    l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2)
    l.Color=col or C.ACCENT; l.Transparency=1
    l.Thickness=thick or 1; l.ZIndex=zi or 2; l.Visible=true
    return l
end
local kn={}
for i=0x41,0x5A do kn[i]=string.char(i) end
for i=0x30,0x39 do kn[i]=tostring(i-0x30) end
for i=0x60,0x69 do kn[i]="Num"..tostring(i-0x60) end
kn[0x70]="F1"
kn[0x71]="F2"
kn[0x72]="F3"
kn[0x73]="F4"
kn[0x74]="F5"
kn[0x75]="F6"
kn[0x76]="F7"
kn[0x77]="F8"
kn[0x78]="F9"
kn[0x79]="F10"
kn[0x7A]="F11"
kn[0x7B]="F12"
kn[0x20]="Space"
kn[0x09]="Tab"
kn[0x0D]="Enter"
kn[0x1B]="Esc"
kn[0x08]="Back"
kn[0x24]="Home"
kn[0x23]="End"
kn[0x2E]="Del"
kn[0x2D]="Ins"
kn[0x21]="PgUp"
kn[0x22]="PgDn"
kn[0x26]="Up"
kn[0x28]="Down"
kn[0x25]="Left"
kn[0x27]="Right"
kn[0xBC]=","
kn[0xBE]="."
kn[0xBF]="/"
kn[0xBA]=";"
kn[0xBB]="="
kn[0xBD]="-"
kn[0xDB]="["
kn[0xDD]="]"
kn[0xDC]="\\"
kn[0xDE]="'"
kn[0xC0]="`"
local function kname(k) return kn[k] or ("Key"..k) end
function UILib.Window(titleA, titleB, gameName)
    local win = {}
    local mouse = game.Players.LocalPlayer:GetMouse()
    local _scrollDelta = 0
    local lastKey = nil
    pcall(function() mouse.WheelForward:Connect(function() _scrollDelta = _scrollDelta - 1 end) end)
    pcall(function() mouse.WheelBackward:Connect(function() _scrollDelta = _scrollDelta + 1 end) end)
    pcall(function()
        local uis = game:GetService("UserInputService")
        local kb = Enum and Enum.UserInputType and Enum.UserInputType.Keyboard
        if uis and uis.InputBegan and kb then
            uis.InputBegan:Connect(function(inp)
                if inp.UserInputType == kb then lastKey = inp.KeyCode end
            end)
        end
    end)
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
    local DROPDOWN_MAX_VISIBLE = 6
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
            if b.panelBg then setShow(b.panelBg, yes and b.open) end
            if b.panelBorder then setShow(b.panelBorder, yes and b.open) end
            for _,o in ipairs(b.optBgs) do
                setShow(o.bg, yes and b.open)
                setShow(o.ln, yes and b.open)
                setShow(o.lb, yes and b.open)
            end
        end
        if b.isMultiDropdown then
            if b.panelBg then setShow(b.panelBg, yes and b.open) end
            if b.panelBorder then setShow(b.panelBorder, yes and b.open) end
            if b.headerBg then setShow(b.headerBg, yes and b.open) end
            if b.headerLn then setShow(b.headerLn, yes and b.open) end
            if b.selAllLbl then setShow(b.selAllLbl, yes and b.open) end
            if b.clearLbl then setShow(b.clearLbl, yes and b.open) end
            for _,o in ipairs(b.optBgs) do
                setShow(o.bg, yes and b.open)
                setShow(o.ln, yes and b.open)
                setShow(o.lb, yes and b.open)
                if o.check then setShow(o.check, yes and b.open) end
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
            local nIdx=0
            for i,lb in ipairs(b.lbls) do
                if b.wrappedLines and b.wrappedLines[i] and b.wrappedLines[i].star then
                    lb.Position=Vector2.new(ax+b.cw/2,ay+b.pad)
                else
                    local off=b.starH+b.pad+nIdx*b.lineH
                    lb.Position=Vector2.new(ax+8,ay+off)
                    nIdx=nIdx+1
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
            local scrollOff=b.scrollOffset or 0
            local maxVis=math.min(DROPDOWN_MAX_VISIBLE,b.options and #b.options or 0)
            if b.panelBg then setShow(b.panelBg, b.open) end
            if b.panelBorder then setShow(b.panelBorder, b.open) end
            if b.open and b.panelBg and b.panelBorder then
                local py=ay+b.ch
                local ph=maxVis*b.ch
                b.panelBg.Position=Vector2.new(ax,py)
                b.panelBg.Size=Vector2.new(b.cw,ph)
                b.panelBorder.Position=Vector2.new(ax,py)
                b.panelBorder.Size=Vector2.new(b.cw,ph)
            end
            for i,o in ipairs(b.optBgs) do
                local vi=i-scrollOff
                local visible = vi>=1 and vi<=maxVis
                if visible then
                    local oy2=ay+b.ch+((vi-1)*b.ch)
                    o.bg.Position=Vector2.new(ax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                    o.ln.From=Vector2.new(ax,oy2+b.ch); o.ln.To=Vector2.new(ax+b.cw,oy2+b.ch)
                    o.lb.Position=Vector2.new(ax+12,oy2+b.ch/2-6)
                    o.ry=animY-sc+b.ch+((vi-1)*b.ch)
                    o.visibleIdx=i
                    o.bg.Color=lerpC(C.ROWBG,C.WHITE,(o.hoverAlpha or 0)*0.12)
                end
                setShow(o.bg, b.open and visible)
                setShow(o.ln, b.open and visible)
                setShow(o.lb, b.open and visible)
            end
        elseif b.isUserList then
            b.bg.Position=Vector2.new(ax,ay)
        elseif b.isMultiDropdown then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.valLbl.Position=Vector2.new(ax+b.cw-28-(#b.valLbl.Text*5.5),ay+b.ch/2-6)
            if b.arrow then b.arrow.Position=Vector2.new(ax+b.cw-11,ay+b.ch/2-6) b.arrow.Text=b.open and "^" or "v" end
            if b.panelBg then setShow(b.panelBg, b.open) end
            if b.panelBorder then setShow(b.panelBorder, b.open) end
            if b.headerBg then setShow(b.headerBg, b.open) end
            if b.headerLn then setShow(b.headerLn, b.open) end
            if b.selAllLbl then setShow(b.selAllLbl, b.open) end
            if b.clearLbl then setShow(b.clearLbl, b.open) end
            if b.open and b.panelBg and b.panelBorder then
                local py=ay+b.ch
                local ph=(1+#b.options)*b.ch
                b.panelBg.Position=Vector2.new(ax,py) b.panelBg.Size=Vector2.new(b.cw,ph)
                b.panelBorder.Position=Vector2.new(ax,py) b.panelBorder.Size=Vector2.new(b.cw,ph)
            end
            if b.open and b.headerBg then
                local hy=ay+b.ch
                b.headerBg.Position=Vector2.new(ax,hy) b.headerBg.Size=Vector2.new(b.cw,b.ch)
                b.headerLn.From=Vector2.new(ax,hy+b.ch) b.headerLn.To=Vector2.new(ax+b.cw,hy+b.ch)
                b.selAllLbl.Position=Vector2.new(ax+14,hy+b.ch/2-5)
                b.clearLbl.Position=Vector2.new(ax+b.cw/2+8,hy+b.ch/2-5)
            end
            for i,o in ipairs(b.optBgs) do
                local oy2=ay+b.ch+b.ch+((i-1)*b.ch)
                o.bg.Position=Vector2.new(ax,oy2) o.bg.Size=Vector2.new(b.cw,b.ch)
                o.bg.Color=lerpC(C.ROWBG,C.WHITE,(o.hoverAlpha or 0)*0.12)
                o.ln.From=Vector2.new(ax,oy2+b.ch) o.ln.To=Vector2.new(ax+b.cw,oy2+b.ch)
                o.lb.Position=Vector2.new(ax+22,oy2+b.ch/2-6)
                if o.check then o.check.Text=b.selected[o.idx] and "x" or "" o.check.Position=Vector2.new(ax+8,oy2+b.ch/2-5) end
                o.ry=animY-sc+b.ch+b.ch+((i-1)*b.ch)
                setShow(o.bg, b.open)
                setShow(o.ln, b.open)
                setShow(o.lb, b.open)
                if o.check then setShow(o.check, b.open) end
            end
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
            local range=b.maxV-b.minV
            local frac=range and range>0 and clamp((b.value-b.minV)/range,0,1) or 0
            local fx=tx+frac*b.trackW
            b.fill.From=Vector2.new(tx,ty)
            b.fill.To=Vector2.new(fx,ty)
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
                if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+4) end
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
            if b.panelBg then tabSet[b.panelBg]=group end
            if b.panelBorder then tabSet[b.panelBorder]=group end
            for _,o in ipairs(b.optBgs) do
                tabSet[o.bg]=group; tabSet[o.ln]=group; tabSet[o.lb]=group
            end
        end
        if b.isMultiDropdown then
            if b.panelBg then tabSet[b.panelBg]=group end
            if b.panelBorder then tabSet[b.panelBorder]=group end
            if b.headerBg then tabSet[b.headerBg]=group end
            if b.headerLn then tabSet[b.headerLn]=group end
            if b.selAllLbl then tabSet[b.selAllLbl]=group end
            if b.clearLbl then tabSet[b.clearLbl]=group end
            for _,o in ipairs(b.optBgs) do
                tabSet[o.bg]=group; tabSet[o.ln]=group; tabSet[o.lb]=group
                if o.check then tabSet[o.check]=group end
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
            if openDropdown.isMultiDropdown and resizeForMultiDropdown then resizeForMultiDropdown(openDropdown,false) else resizeForDropdown(openDropdown,false) end
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
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dBtnMinimize,dBtnClose
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
    local TIP_DELAY = 0.2
    local hoverDelayBtn = nil
    local hoverDelayAt = 0
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
            -- Red dot LEFT of "Online:" text
            dOnlineDot.Position = Vector2.new(tx + 4, uiY+20)
            dOnlineTxt.Position = Vector2.new(tx + 12, uiY+14)
        end
        -- Yellow and red circles LEFT of F1 key label
        dBtnMinimize.Position = Vector2.new(uiX+L.W-52, uiY+19)
        dBtnClose.Position    = Vector2.new(uiX+L.W-38, uiY+19)
        dKeyLbl.Position      = Vector2.new(uiX+L.W-22, uiY+14)
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
    local function addToggle(tab,lbl,relY,init,cb,desc)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local ox=rx+cw-L.TOG_W-8; local oy=ry+ch/2-L.TOG_H/2
        local bg  =mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl  =mkD(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb  =mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local tog =mkD(mkSq(uiX+ox,uiY+oy,L.TOG_W,L.TOG_H,init and C.ON or C.OFF,true,1,4,nil,L.TOG_H))
        local dot =mkD(mkSq(uiX+ox+(init and L.TOG_W-L.TOG_H+2 or 2),uiY+oy+2,L.TOG_H-4,L.TOG_H-4,init and C.ONDOT or C.OFFDOT,true,1,5,nil,L.TOG_H))
        local qbg, qlb
        if desc then
            local qx=uiX+ox-22; local qy=uiY+ry+ch/2-7
            qbg=mkD(mkSq(qx,qy,14,14,Color3.fromRGB(16,20,38),true,1,6,nil,3))
            qlb=mkD(mkTx("?",qx+7,qy+4,9,C.GRAY,true,7,true))
        end
        local b={tab=tab,isTog=true,state=init,bg=bg,lbl=lb,ln=dl,tog=tog,dot=dot,outGlow=mkD(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,ox=ox,oy=oy,lt=init and 1 or 0,cb=cb,toggleName=lbl,
                 desc=desc,qbg=qbg,qlb=qlb,qox=ox-22,qch=ch,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end
    local function addDiv(tab,lbl,relY,collapsible)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2
        local lb=mkD(mkTx(lbl,uiX+rx+6,uiY+ry,9,C.GRAY,false,8))
        local dl=mkD(mkLn(uiX+rx,uiY+ry+13,uiX+rx+cw,uiY+ry+13,C.DIV,4,1))
        local arrow
        if collapsible then
            arrow=mkD(mkTx("v",uiX+rx+cw-6,uiY+ry,9,C.GRAY,false,8))
            if _collapseSections[lbl]==nil then _collapseSections[lbl]=false end
        end
        local db={tab=tab,isDiv=true,bg=lb,lbl=lb,ln=dl,rx=rx,ry=ry,cw=cw,ch=14,
                  collapsible=collapsible,sectionName=lbl,arrow=arrow,currentRY=ry,baseRY=ry}
        table.insert(btns,db); return #btns
    end
    local function addAct(tab,lbl,relY,col,cb,lblCol)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local outBg = col or C.ROWBG
        local outColor = Color3.new(math.min(1, outBg.R*1.5), math.min(1, outBg.G*1.5), math.min(1, outBg.B*1.5))
        local out=mkD(mkSq(uiX+rx,uiY+ry,cw,ch,outColor,true,1,3,nil,4))
        local bg=mkD(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,col or C.ROWBG,true,1,4,nil,4))
        local lb=mkD(mkTx(lbl,uiX+rx+cw/2,uiY+ry+ch/2-6,12,lblCol or C.WHITE,true,8))
        local outGlow=mkD(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,0,5,1,4))
        local b={tab=tab,isAct=true,customCol=col~=nil,out=out,bg=bg,lbl=lb,outGlow=outGlow,ln=nil,rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,cb=cb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end
    local function addSlider(tab,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H+6
        local trackW=cw-16
        local initLbl=isFloat and string.format("%.1f",initV) or math.floor(initV)
        local bg  =mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl  =mkD(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb  =mkD(mkTx(lbl..": "..initLbl,uiX+rx+8,uiY+ry+7,12,C.WHITE,false,8))
        local dlb = desc and mkD(mkTx(desc,uiX+rx+8,uiY+ry+21,9,C.GRAY,false,8)) or nil
        local ty  =uiY+ry+ch-11
        local trk =mkD(mkLn(uiX+rx+8,ty,uiX+rx+8+trackW,ty,C.DIMGRAY,5,3))
        local frac=(initV-minV)/(maxV-minV)
        local fx  =uiX+rx+8+frac*trackW
        local fil =mkD(mkLn(uiX+rx+8,ty,fx,ty,C.ACCENT,6,3))
        local hdl =mkD(mkSq(fx-4,ty-4,L.HDL,L.HDL,C.WHITE,true,1,7,nil,3))
        local b={tab=tab,isSlider=true,bg=bg,lbl=lb,ln=dl,track=trk,fill=fil,handle=hdl,outGlow=mkD(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,trackW=trackW,minV=minV,maxV=maxV,
                 value=initV,baseLbl=lbl,dragging=false,cb=cb,isFloat=isFloat or false,dlb=dlb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end
    local function addColorPicker(tab,lbl,relY,initCol,cb)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local bg =mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl =mkD(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb =mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local swatchW=14; local swatchH=14; local swatchPad=5
        local swatches={
            Color3.fromRGB(70,120,255),
            Color3.fromRGB(210,55,55),
            Color3.fromRGB(45,190,95),
            Color3.fromRGB(255,175,80),
            Color3.fromRGB(180,80,255),
            Color3.fromRGB(215,220,240),
        }
        local totalW=(#swatches*(swatchW+swatchPad))-swatchPad
        local startX=uiX+rx+cw-totalW-10
        local swatchBgs={}
        local selected=1
        for i,col in ipairs(swatches) do
            local sx=startX+(i-1)*(swatchW+swatchPad)
            local sy=uiY+ry+ch/2-swatchH/2
            local s=mkD(mkSq(sx,sy,swatchW,swatchH,col,true,1,6,nil,3))
            local border=mkD(mkSq(sx-1,sy-1,swatchW+2,swatchH+2,i==1 and C.WHITE or C.BORDER,false,1,7,1,3))
            table.insert(swatchBgs,{sq=s,border=border,col=col,x=sx,y=sy})
        end
        local b={tab=tab,isColorPicker=true,bg=bg,lbl=lb,ln=dl,outGlow=mkD(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,swatches=swatchBgs,
                 selected=selected,value=swatches[1],cb=cb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end
    local openDropdown = nil
    local function applyWindowH(h)
        if not dMainBg then return end
        dMainBg.Size=Vector2.new(L.W,h)
        dShadow.Size=Vector2.new(L.W+4,h+4)
        dGlow1.Size=Vector2.new(L.W+2,h+2)
        dGlow2.Size=Vector2.new(L.W+4,h+4)
        dBorder.Size=Vector2.new(L.W,h)
        dSide.Size=Vector2.new(L.SIDEBAR-1,h-L.TOPBAR-L.FOOTER-1)
        dContent.Size=Vector2.new(L.CONTENT_W-1,h-L.TOPBAR-L.FOOTER-1)
        dScrollBg.Size=Vector2.new(4,h-L.TOPBAR-L.FOOTER-4)
        dFooter.Position=Vector2.new(uiX+1,uiY+h-L.FOOTER)
        dFotLine.From=Vector2.new(uiX+1,uiY+h-L.FOOTER)
        dFotLine.To=Vector2.new(uiX+L.W-1,uiY+h-L.FOOTER)
        dSideLn.To=Vector2.new(uiX+L.SIDEBAR,uiY+h-L.FOOTER)
        if dCharLbl then
            local nW = dNameTxt and #dNameTxt.Text * 6 or 0
            dCharLbl.Position = Vector2.new(uiX+42+64+nW+8, uiY+h-L.FOOTER+9)
        end
    end
    local function resizeForDropdown(dd, expanding)
        local n = #dd.options
        local vis = math.min(DROPDOWN_MAX_VISIBLE, n)
        local extra = expanding and (vis * dd.ch) or 0
        uiTargetH = L.H + extra
    end
    local function addDropdown(tab,lbl,relY,options,initIdx,cb)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local outBg = C.ROWBG
        local outColor = Color3.new(math.min(1, outBg.R*1.5), math.min(1, outBg.G*1.5), math.min(1, outBg.B*1.5))
        local out=mkD(mkSq(uiX+rx,uiY+ry,cw,ch,outColor,true,1,3,nil,4))
        local bg=mkD(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROWBG,true,1,4,nil,4))
        local dl=nil
        local lb=mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local valIdx=initIdx or 1
        local val=mkD(mkTx(options[valIdx] or "",uiX+rx+cw-60,uiY+ry+ch/2-6,11,C.ACCENT,false,8))
        local arrow=mkD(mkTx("v",uiX+rx+cw-14,uiY+ry+ch/2-6,9,C.GRAY,false,8))
        local panelBg=mkD(mkSq(0,0,1,1,Color3.fromRGB(10,12,22),true,0,9,nil,6))
        local panelBorder=mkD(mkSq(0,0,1,1,C.BORDER,false,0.6,9,1,6))
        panelBg.Visible=false; panelBorder.Visible=false
        pcall(function() panelBg.Corner=6 end) pcall(function() panelBorder.Corner=6 end)
        local optBgs={}
        for i,opt in ipairs(options) do
            local oy2=ry+ch+((i-1)*ch)
            local obg=mkD(mkSq(uiX+rx,uiY+oy2,cw,ch,C.ROWBG,true,0,10,nil,4))
            local oln=mkD(mkLn(uiX+rx,uiY+oy2+ch,uiX+rx+cw,uiY+oy2+ch,C.DIV,11,1))
            local olb=mkD(mkTx(opt,uiX+rx+14,oy2+ch/2-6,11,i==valIdx and C.ACCENT or C.WHITE,false,11))
            obg.Visible=false; oln.Visible=false; olb.Visible=false
            pcall(function() obg.Corner=2 end)
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,ry=oy2,alpha=0,targetAlpha=0,hoverAlpha=0,targetHoverAlpha=0})
        end
        local b={tab=tab,isDropdown=true,out=out,bg=bg,lbl=lb,ln=dl,valLbl=val,arrow=arrow,currentRY=ry,baseRY=ry,outGlow=mkD(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=rx,ry=ry,cw=cw,ch=ch,options=options,optBgs=optBgs,panelBg=panelBg,panelBorder=panelBorder,
                 selected=valIdx,open=false,openedAt=0,cb=cb,hoverAlpha=0,targetHoverAlpha=0,scrollOffset=0,highlightIdx=1}
        table.insert(btns,b); return #btns
    end
    if not _G.UILib_Save then _G.UILib_Save={} end
    local function addMultiDropdown(tab,lbl,relY,options,initIndices,cb,saveKey)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local selected={}
        if saveKey and _G.UILib_Save[saveKey] then
            for _,i in ipairs(_G.UILib_Save[saveKey]) do selected[i]=true end
        end
        if not next(selected) and initIndices then
            for i,v in ipairs(initIndices) do if v then selected[i]=true end end
            for _,i in ipairs(initIndices) do if type(i)=="number" then selected[i]=true end end
        end
        local outBg=C.ROWBG
        local outColor=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=mkD(mkSq(uiX+rx,uiY+ry,cw,ch,outColor,true,1,3,nil,4))
        local bg=mkD(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROWBG,true,1,4,nil,4))
        local lb=mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local val=mkD(mkTx("None",uiX+rx+cw-60,uiY+ry+ch/2-6,11,C.ACCENT,false,8))
        local arrow=mkD(mkTx("v",uiX+rx+cw-14,uiY+ry+ch/2-6,9,C.GRAY,false,8))
        local panelBg=mkD(mkSq(0,0,1,1,Color3.fromRGB(10,12,22),true,0,9,nil,6))
        local panelBorder=mkD(mkSq(0,0,1,1,C.BORDER,false,0.6,9,1,6))
        panelBg.Visible=false; panelBorder.Visible=false
        pcall(function() panelBg.Corner=6 end) pcall(function() panelBorder.Corner=6 end)
        local headerBg=mkD(mkSq(0,0,cw,ch,C.DIMGRAY,true,0,10,nil,2))
        local headerLn=mkD(mkLn(uiX+rx,0,uiX+rx+cw,0,C.DIV,11,1))
        local selAllLbl=mkD(mkTx("Select all",uiX+rx+14,0,10,C.WHITE,false,11))
        local clearLbl=mkD(mkTx("Clear",uiX+rx+cw/2+8,0,10,C.GRAY,false,11))
        headerBg.Visible=false; headerLn.Visible=false; selAllLbl.Visible=false; clearLbl.Visible=false
        local optBgs={}
        for i,opt in ipairs(options) do
            local oy2=ry+ch+ch+((i-1)*ch)
            local obg=mkD(mkSq(uiX+rx,uiY+oy2,cw,ch,C.ROWBG,true,0,10,nil,4))
            local oln=mkD(mkLn(uiX+rx,uiY+oy2+ch,uiX+rx+cw,uiY+oy2+ch,C.DIV,11,1))
            local check=mkD(mkTx(selected[i] and "x" or "",uiX+rx+8,oy2+ch/2-5,10,C.ACCENT,false,11))
            local olb=mkD(mkTx(opt,uiX+rx+22,oy2+ch/2-6,11,C.WHITE,false,11))
            obg.Visible=false; oln.Visible=false; olb.Visible=false; check.Visible=false
            pcall(function() obg.Corner=2 end)
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,check=check,ry=oy2,alpha=0,targetAlpha=0,hoverAlpha=0,targetHoverAlpha=0,idx=i})
        end
        local b={tab=tab,isMultiDropdown=true,out=out,bg=bg,lbl=lb,ln=nil,valLbl=val,arrow=arrow,currentRY=ry,baseRY=ry,outGlow=mkD(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=rx,ry=ry,cw=cw,ch=ch,options=options,optBgs=optBgs,panelBg=panelBg,panelBorder=panelBorder,
                 headerBg=headerBg,headerLn=headerLn,selAllLbl=selAllLbl,clearLbl=clearLbl,
                 selected=selected,open=false,cb=cb,saveKey=saveKey,scrollOffset=0}
        function b.updateValLbl()
            local n=0 for i=1,#options do if selected[i] then n=n+1 end end
            if n==0 then b.valLbl.Text="None" return end
            if n<=2 then local t={} for i=1,#options do if selected[i] then table.insert(t,options[i]) end end b.valLbl.Text=table.concat(t, ", ") else b.valLbl.Text=n.." selected" end
        end
        function b.fireCb()
            local idx={} local lbls={} for i=1,#options do if selected[i] then table.insert(idx,i) table.insert(lbls,options[i]) end end
            if b.cb then b.cb(idx,lbls) end
            if saveKey then _G.UILib_Save[saveKey]=idx end
        end
        table.insert(btns,b)
        b.updateValLbl()
        return #btns
    end
    local function resizeForMultiDropdown(md,expanding)
        local n=#md.options+1
        local vis=math.min(DROPDOWN_MAX_VISIBLE+1,n)
        local extra=expanding and (vis*md.ch) or 0
        uiTargetH=L.H+extra
    end
    local function wrapLogText(text, maxChars)
        if #text <= maxChars then return {text} end
        local wrapped = {}
        local remaining = text
        while #remaining > 0 do
            if #remaining <= maxChars then
                table.insert(wrapped, remaining)
                break
            end
            local cut = maxChars
            local spaceAt = nil
            for j = cut, 1, -1 do
                if remaining:sub(j,j) == " " then spaceAt = j; break end
            end
            if spaceAt and spaceAt > 1 then
                table.insert(wrapped, remaining:sub(1, spaceAt - 1))
                remaining = remaining:sub(spaceAt + 1)
            else
                table.insert(wrapped, remaining:sub(1, cut))
                remaining = remaining:sub(cut + 1)
            end
        end
        return wrapped
    end
    local function addLog(tab,lines,relY,starFirst)
        local rx=L.SIDEBAR+L.ROW_PAD
        local cw=L.CONTENT_W-L.ROW_PAD*2
        local lineH=18; local starH=starFirst and 26 or 0; local pad=10
        local maxChars=math.floor((cw-16)/6)
        local wrappedLines={}
        local wrappedMap={}
        for i,line in ipairs(lines) do
            if starFirst and i==1 then
                table.insert(wrappedLines,{text=line,star=true})
            else
                local parts=wrapLogText(line,maxChars)
                for _,p in ipairs(parts) do
                    table.insert(wrappedLines,{text=p,star=false})
                end
            end
        end
        local normalCount=0
        for _,wl in ipairs(wrappedLines) do if not wl.star then normalCount=normalCount+1 end end
        local ch=starH+normalCount*lineH+pad*2
        local ry=L.TOPBAR+relY
        local bg=mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,1,3,nil,6))
        local lbls={}
        local normalIdx=0
        for _,wl in ipairs(wrappedLines) do
            local lb=mkD(Drawing.new("Text"))
            if wl.star then
                lb.Text=wl.text; lb.Position=Vector2.new(uiX+rx+cw/2,uiY+ry+pad)
                lb.Size=14; lb.Color=Color3.fromRGB(255,200,40); lb.Center=true
                lb.Outline=true; lb.Font=Drawing.Fonts.Minecraft
            else
                local off=starH+pad+normalIdx*lineH
                lb.Text=wl.text; lb.Position=Vector2.new(uiX+rx+8,uiY+ry+off)
                lb.Size=11; lb.Color=C.WHITE; lb.Center=false
                lb.Outline=true; lb.Font=Drawing.Fonts.Minecraft
                normalIdx=normalIdx+1
            end
            lb.Transparency=1; lb.ZIndex=8; lb.Visible=false
            table.insert(lbls,lb)
        end
        local b={tab=tab,isLog=true,bg=bg,lbl=bg,ln=nil,lbls=lbls,
                 rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,lines=lines,lineH=lineH,pad=pad,
                 starFirst=starFirst,starH=starH,wrappedLines=wrappedLines}
        table.insert(btns,b); return #btns
    end
    local function addUserList(tab, maxUsers, relY)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local rowH=44; local pad=0
        local ch = (maxUsers*rowH)+pad*2
        local bg = mkD(mkSq(uiX+rx, uiY+ry, cw, ch, C.CONTENT, true, 0, 1, nil, 0))
        local users = {}
        for i=1,maxUsers do
            local yOff = (i-1)*rowH
            local uBgOut = C.ROWBG
            local uOutColor = Color3.new(math.min(1, uBgOut.R*1.5), math.min(1, uBgOut.G*1.5), math.min(1, uBgOut.B*1.5))
            local uOut = mkSq(uiX+rx+18, uiY+ry+yOff+10, cw-18, 38, uOutColor, true, 0, 3, nil, 4)
            local uBg = mkSq(uiX+rx+19, uiY+ry+yOff+11, cw-20, 36, C.ROWBG, true, 0, 4, nil, 4)
            local uName = mkTx("", uiX+rx+52, uiY+ry+yOff+10+38/2-7, 13, C.WHITE, false, 8)
            local uYouTag = mkTx(" <-- you", uiX+rx+52, uiY+ry+yOff+10+38/2-7, 13, C.GRAY, false, 8)
            uOut.Visible = false; uBg.Visible = false; uName.Visible = false; uYouTag.Visible = false
            table.insert(users, {out=uOut, bg=uBg, name=uName, youTag=uYouTag, ryOff=yOff, 
                avatarPixels={}, activePixelsCount=0, _active=false, _isYou=false, targetAlpha=0, alpha=0, 
                slideY=20})
        end
        local b={tab=tab,isUserList=true,bg=bg,lbl=bg,ln=nil,users=users,
                 rx=rx,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,maxUsers=maxUsers,pad=pad,rowH=rowH}
        table.insert(btns,b); return #btns
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
                            currentY = currentY + (math.min(DROPDOWN_MAX_VISIBLE,#b.options) * b.ch)
                        end
                        if b.isMultiDropdown and b.open then
                            currentY = currentY + ((#b.options+1) * b.ch)
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
            local togApi = {}
            function togApi:SetState(newState, skipCallback)
                local b = btns[idx]
                if not b then return end
                if b.state == newState then return end
                b.state = newState
                b.lt = newState and 1 or 0
                if b.tog then b.tog.Color = newState and C.ON or C.OFF end
                if b.dot then b.dot.Color = newState and C.ONDOT or C.OFFDOT end
                if not skipCallback and b.cb then pcall(b.cb, newState) end
            end
            return togApi
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
            local ddApi = {}
            function ddApi:SetOptions(newOpts)
                local b = btns[idx]
                if not b then return end
                if b.open then return end
                local maxO = #b.optBgs
                local trimmed = {}
                for i = 1, math.min(#newOpts, maxO) do trimmed[i] = newOpts[i] end
                b.options = trimmed
                for i = 1, maxO do
                    if i <= #trimmed then
                        b.optBgs[i].lb.Text = trimmed[i]
                        b.optBgs[i].lb.Color = (i == b.selected) and C.ACCENT or C.WHITE
                    else
                        b.optBgs[i].lb.Text = ""
                        b.optBgs[i].targetAlpha = 0
                        setShow(b.optBgs[i].bg, false)
                        setShow(b.optBgs[i].ln, false)
                        setShow(b.optBgs[i].lb, false)
                    end
                end
                if b.selected > #trimmed then b.selected = 1 end
                b.valLbl.Text = b.options[b.selected] or ""
                if b.open then
                    b.open = false
                    if b.arrow then b.arrow.Text = "v" end
                    openDropdown = nil
                    resizeForDropdown(b, false)
                    recalculateLayout(currentTab)
                end
            end
            function ddApi:IsOpen()
                local b = btns[idx]
                return b and b.open or false
            end
            function ddApi:GetSelected()
                local b = btns[idx]
                if not b then return 1, "" end
                return b.selected, b.options[b.selected] or ""
            end
            return ddApi
        end
        function api:MultiDropdown(lbl, options, initIndices, cb, saveKey)
            local h = (#options + 1) * L.ROW_H + 12
            local y = nextY(h)
            local idx = addMultiDropdown(tabName, lbl, y, options, initIndices, cb, saveKey)
            if currentSection and btns[idx] then btns[idx].section = currentSection end
        end
        function api:Log(lines, starFirst)
            local lineH = 18
            local starH = starFirst and 26 or 0
            local cw=L.CONTENT_W-L.ROW_PAD*2
            local maxChars=math.floor((cw-16)/6)
            local normalCount=0
            for i,line in ipairs(lines) do
                if starFirst and i==1 then
                else
                    local parts=wrapLogText(line,maxChars)
                    normalCount=normalCount+#parts
                end
            end
            local h = starH + normalCount * lineH + 20 + 6
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
        local t=THEMES[name]; if not t then return end
        C.ACCENT=t.ACCENT;  C.BG=t.BG;       C.SIDEBAR=t.SIDEBAR
        C.CONTENT=t.CONTENT; C.TOPBAR=t.TOPBAR; C.BORDER=t.BORDER
        C.ROWBG=t.ROWBG;    C.TABSEL=t.TABSEL
        if t.WHITE   then C.WHITE=t.WHITE     end
        if t.GRAY    then C.GRAY=t.GRAY       end
        if t.DIMGRAY then C.DIMGRAY=t.DIMGRAY end
        if t.ON      then C.ON=t.ON           end
        if t.OFF     then C.OFF=t.OFF         end
        if t.ONDOT   then C.ONDOT=t.ONDOT     end
        if t.OFFDOT  then C.OFFDOT=t.OFFDOT   end
        if t.DIV     then C.DIV=t.DIV         end
        if t.MINIBAR then C.MINIBAR=t.MINIBAR   end
        if dMainBg then
            dMainBg.Color=C.BG;     dMiniBg.Color=C.BG
            dTopBar.Color=C.TOPBAR; dMiniTopBar.Color=C.TOPBAR
            dSide.Color=C.SIDEBAR;  dContent.Color=C.CONTENT
            dFooter.Color=C.TOPBAR
            dBorder.Color=C.BORDER; dMiniBorder.Color=C.BORDER
            dTopLine.Color=C.BORDER; dMiniDivLn.Color=C.BORDER
            dSideLn.Color=C.BORDER; dFotLine.Color=C.BORDER
            if dGlow1 then dGlow1.Color=C.ACCENT end
            if dGlow2 then dGlow2.Color=C.ACCENT end
            if dMiniGlow1 then dMiniGlow1.Color=C.ACCENT end
            if dMiniGlow2 then dMiniGlow2.Color=C.ACCENT end
            if dScrollBg then dScrollBg.Color=Color3.fromRGB(18, 20, 28) end
            if dScrollThumb then dScrollThumb.Color=C.ACCENT end
            dTitleA.Color=C.ACCENT;     dMiniTitleA.Color=C.ACCENT
            dMiniDotG.Color=C.ACCENT
            dTitleW.Color=C.WHITE;      dMiniTitleW.Color=C.WHITE
            dTitleG.Color=C.ORANGE;     dMiniTitleG.Color=C.ORANGE
            dKeyLbl.Color=C.GRAY;       dMiniKeyLbl.Color=C.GRAY
            if dCharLbl then dCharLbl.Color=C.GRAY end
            if dMiniActiveBg then dMiniActiveBg.Color=C.MINIBAR end
            for _,lb in ipairs(miniActiveLbls) do lb.Color=C.WHITE end
            for _,t2 in ipairs(tabObjs) do
                t2.bg.Color=t2.sel and C.TABSEL or C.SIDEBAR
                t2.acc.Color=t2.sel and C.ACCENT or C.SIDEBAR
                t2.lbl.Color=C.WHITE; t2.lblG.Color=C.GRAY
            end
            for _,b in ipairs(btns) do
                if b.bg and not b.isDiv then b.bg.Color=C.ROWBG end
                if b.ln then b.ln.Color=C.DIV end
                if b.isTog then
                    b.lbl.Color=C.WHITE
                    b.tog.Color=b.state and C.ON or C.OFF
                    b.dot.Color=b.state and C.ONDOT or C.OFFDOT
                    if b.qlb  then b.qlb.Color=C.GRAY end
                    if b.qbg  then b.qbg.Color=Color3.fromRGB(16,20,38) end
                elseif b.isSlider then
                    b.lbl.Color=C.WHITE
                    if b.dlb   then b.dlb.Color=C.GRAY end
                    if b.track then b.track.Color=C.ACCENT end
                elseif b.isAct then
                    if not b.customCol then
                        b.bg.Color=C.ROWBG
                        local outBg = C.ROWBG
                        local outColor = Color3.new(math.min(1, outBg.R*1.5), math.min(1, outBg.G*1.5), math.min(1, outBg.B*1.5))
                        if b.out then b.out.Color=outColor end
                    end
                elseif b.isDiv then
                    b.lbl.Color=C.GRAY
                    if b.ln    then b.ln.Color=C.DIV end
                    if b.arrow then b.arrow.Color=C.GRAY end
                elseif b.isDropdown then
                    b.lbl.Color=C.WHITE
                    b.arrow.Color=C.GRAY
                    b.valLbl.Color=C.ACCENT
                    for j,o in ipairs(b.optBgs) do
                        o.bg.Color=C.ROWBG
                        o.ln.Color=C.DIV
                        o.lb.Color=j==b.selected and C.ACCENT or C.WHITE
                    end
                elseif b.isColorPicker then
                    b.lbl.Color=C.WHITE
                elseif b.isLog then
                end
            end
        end
    end
    function win:Init(defaultTab, charLabelFn, notifFn)
        local notif = notifFn or function(msg,title,dur)
            pcall(function() notify(msg, title or titleA.." "..titleB, dur or 3) end)
        end
        dShadow  = mkD(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,   C.SHADOW,true,0.5,0,nil,12))
        dMainBg  = mkD(mkSq(uiX,uiY,L.W,L.H,            C.BG,    true,1,1,nil,10))
        dGlow1   = mkD(mkSq(uiX-1,uiY-1,L.W+2,L.H+2,   C.ACCENT,false,0.9,1,1,11))
        dGlow2   = mkD(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,   C.ACCENT,false,0.35,0,2,12))
        glowLines= {dGlow1,dGlow2}
        dBorder  = mkD(mkSq(uiX,uiY,L.W,L.H,            C.BORDER,false,0.2,3,1,10))
        dTopBar  = mkD(mkSq(uiX+1,uiY+1,L.W-2,L.TOPBAR, C.TOPBAR,true,1,3,nil,9))
        dTopFill = mkD(mkSq(uiX+1,uiY+L.TOPBAR-5,L.W-2,7,C.TOPBAR,true,1,3))
        dTopLine = mkD(mkLn(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4,1))
        dTitleW  = mkD(mkTx(titleA,  uiX+14,     uiY+12,14,C.WHITE, false,9,true))
        dTitleA  = mkD(mkTx(titleB,  uiX+14+(#titleA*8)+3, uiY+12,14,C.ACCENT,false,9,true))
        local gameNameShort = gameName or ""
        dTitleG  = mkD(mkTx(gameNameShort, uiX+100, uiY+12,13,C.ORANGE,false,9,false))
        -- Online dot (circle) positioned LEFT of "Online:" text
        dOnlineDot = Drawing.new("Circle")
        dOnlineDot.Radius = 3; dOnlineDot.Color = Color3.new(0.9, 0.1, 0.1); dOnlineDot.Filled = true
        dOnlineDot.Transparency = 1; dOnlineDot.ZIndex = 9; dOnlineDot.NumSides = 20; dOnlineDot.Visible = false
        table.insert(allDrawings, dOnlineDot)
        dOnlineTxt = mkD(mkTx("Online:", uiX+200, uiY+14, 11, C.GRAY, false, 9, false))
        
        local function posOnline(gn)
            local tx = uiX + 100 + #gn * 7.5 + 15
            -- Red dot LEFT of "Online:" text
            if dOnlineDot then dOnlineDot.Position = Vector2.new(tx + 4, uiY+20) end
            if dOnlineTxt then dOnlineTxt.Position = Vector2.new(tx + 12, uiY+14) end
        end
        posOnline(gameNameShort)

        if gameNameShort == "" or gameNameShort == "Game Name" then
            dTitleG.Text = ""
            posOnline("")
            task.spawn(function()
                pcall(function()
                    local gn
                    if type(getgamename) == "function" then
                        gn = getgamename()
                    else
                        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                        gn = info and info.Name
                    end
                    if gn then
                        dTitleG.Text = gn
                        posOnline(gn)
                        if dMiniTitleG then dMiniTitleG.Text = gn end
                    end
                end)
            end)
        end
        -- Yellow and Red circle buttons LEFT of F1 key label
        dBtnMinimize = Drawing.new("Circle")
        dBtnMinimize.Radius = 4; dBtnMinimize.Color = Color3.fromRGB(230,180,50); dBtnMinimize.Filled = true
        dBtnMinimize.Transparency = 1; dBtnMinimize.ZIndex = 10; dBtnMinimize.Visible = false
        dBtnMinimize.Position = Vector2.new(uiX+L.W-52, uiY+19)
        table.insert(allDrawings, dBtnMinimize)
        
        dBtnClose = Drawing.new("Circle")
        dBtnClose.Radius = 4; dBtnClose.Color = Color3.fromRGB(200,60,60); dBtnClose.Filled = true
        dBtnClose.Transparency = 1; dBtnClose.ZIndex = 10; dBtnClose.Visible = false
        dBtnClose.Position = Vector2.new(uiX+L.W-38, uiY+19)
        table.insert(allDrawings, dBtnClose)
        
        dKeyLbl  = mkD(mkTx("F1",    uiX+L.W-22, uiY+14,11,C.GRAY,  false,9))
        dSide    = mkD(mkSq(uiX+1,uiY+L.TOPBAR,L.SIDEBAR-1,L.H-L.TOPBAR-L.FOOTER-1,C.SIDEBAR,true,1,2,nil,8))
        dSideLn  = mkD(mkLn(uiX+L.SIDEBAR,uiY+L.TOPBAR,uiX+L.SIDEBAR,uiY+L.H-L.FOOTER,C.BORDER,4,1))
        dContent = mkD(mkSq(uiX+L.SIDEBAR,uiY+L.TOPBAR,L.CONTENT_W-1,L.H-L.TOPBAR-L.FOOTER-1,C.CONTENT,true,1,2,nil,8))
        dFooter  = mkD(mkSq(uiX+1,uiY+L.H-L.FOOTER,L.W-2,L.FOOTER-1,C.TOPBAR,true,1,3,nil,6))
        dFotLine = mkD(mkLn(uiX+1,uiY+L.H-L.FOOTER,uiX+L.W-1,uiY+L.H-L.FOOTER,C.BORDER,4,1))
        dCharLbl = mkD(mkTx("",0,0,11,C.GRAY,false,9))
        dScrollBg = mkSq(uiX+L.W-6,uiY+L.TOPBAR+2,4,L.H-L.TOPBAR-L.FOOTER-4,Color3.fromRGB(18,20,28),true,1,4,nil,2)
        dScrollBg.Visible = false
        dScrollThumb = mkSq(uiX+L.W-6,uiY+L.TOPBAR+2,4,20,C.ACCENT,true,1,5,nil,2)
        dScrollThumb.Visible = false
        tipBg   = mkSq(0,0,10,10,Color3.fromRGB(10,13,24),true,1,12,nil,4)
        pcall(function() tipBg.Corner=4 end)
        tipBg.Visible=false
        local tipBorder=mkSq(0,0,10,10,C.ACCENT,false,0.7,12,1,4)
        pcall(function() tipBorder.Corner=4 end)
        tipBorder.Visible=false
        tipLbl  = mkTx("",0,0,11,Color3.fromRGB(70,120,255),false,13,true)
        tipLbl.Visible=false
        tipDesc = mkTx("",0,0,10,Color3.fromRGB(130,140,170),false,13,false)
        tipDesc.Visible=false
        baseUI={dShadow,dGlow2,dGlow1,dMainBg,dBorder,dTopBar,dTopFill,dTopLine,
                dTitleW,dTitleA,dTitleG,dOnlineTxt,dOnlineDot,dKeyLbl,dActiveCountLbl,dBtnMinimize,dBtnClose,dSide,dSideLn,dContent,
                dFooter,dFotLine,dCharLbl}
        local tabNames = {}
        for name,_ in pairs(tabAPI) do table.insert(tabNames,name) end
        for i,name in ipairs(win._tabOrder) do
            local relTY=L.TOPBAR+8+(i-1)*34
            local isSel=name==defaultTab
            local tbg =mkD(mkSq(uiX+7,uiY+relTY,L.SIDEBAR-14,26,isSel and C.TABSEL or C.SIDEBAR,true,1,3,nil,5))
            local tacc=mkD(mkSq(uiX+7,uiY+relTY,3,26,isSel and C.ACCENT or C.SIDEBAR,true,1,4,nil,2))
            local tlW =mkD(mkTx(name,uiX+18,uiY+relTY+7,11,C.WHITE,false,8))
            local tlG =mkD(mkTx(name,uiX+18,uiY+relTY+7,11,C.GRAY, false,8))
            setShow(tbg,false); setShow(tacc,false)
            setShow(tlW,false); setShow(tlG,false)
            table.insert(tabObjs,{bg=tbg,acc=tacc,lbl=tlW,lblG=tlG,name=name,sel=isSel,lt=isSel and 1 or 0,relTY=relTY})
        end
        dMiniShadow  = mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,C.SHADOW,true,0.5,0,nil,12)
        dMiniBg      = mkSq(uiX,uiY,L.W,L.MINI_H,         C.BG,    true,1,1,nil,10)
        dMiniGlow1   = mkSq(uiX-1,uiY-1,L.W+2,L.MINI_H+2, C.ACCENT,false,0.9,1,1,11)
        dMiniGlow2   = mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4, C.ACCENT,false,0.35,0,2,12)
        miniGlowLines= {dMiniGlow1,dMiniGlow2}
        dMiniBorder  = mkSq(uiX,uiY,L.W,L.MINI_H,         C.BORDER,false,0.2,3,1,10)
        dMiniTopBar  = mkSq(uiX+1,uiY+1,L.W-2,L.TOPBAR,   C.TOPBAR,true,1,3,nil,9)
        dMiniTitleW  = mkTx(titleA,  uiX+14,    uiY+12,14,C.WHITE, false,9,true)
        dMiniTitleA  = mkTx(titleB,  uiX+14+(#titleA*8)+3, uiY+12,14,C.ACCENT,false,9,true)
        dMiniTitleG  = mkTx(dTitleG.Text, uiX+100,  uiY+12,13,C.ORANGE,false,9,false)
        dMiniKeyLbl  = mkTx("F1",    uiX+L.W-22,uiY+14,11,C.GRAY,  false,9)
        dMiniDotG    = mkSq(uiX+L.W-55,uiY+15,8,8,C.ACCENT,true,1,9,nil,3)
        dMiniDotR    = mkSq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,1,9,nil,3)
        dMiniDivLn   = mkLn(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4,1)
        dMiniActiveBg= mkSq(uiX+1,uiY+L.TOPBAR,L.W-2,L.MINI_H-L.TOPBAR-1,C.MINIBAR,true,1,2,nil,8)
        pcall(function() dMiniShadow.Corner=12 end)
        pcall(function() dMiniBg.Corner=10 end)
        pcall(function() dMiniGlow1.Corner=11 end)
        pcall(function() dMiniGlow2.Corner=12 end)
        pcall(function() dMiniBorder.Corner=10 end)
        miniDrawings={dMiniShadow,dMiniBg,dMiniGlow2,dMiniGlow1,dMiniBorder,
                      dMiniTopBar,dMiniTitleW,dMiniTitleA,dMiniTitleG,
                      dMiniKeyLbl,dMiniDotG,dMiniDotR,dMiniDivLn,dMiniActiveBg}
        for _,d in ipairs(miniDrawings) do d.Visible=false end
        currentTab=defaultTab
        notif("Loaded on "..(gameName or ""),"Check it Interface",4)
        updateLoaderFrame = nil
        local uname = game:GetService("Players").LocalPlayer.Name
        dWelcomeTxt = mkTx("Welcome, ", 0, 0, 13, C.WHITE, false, 5, true)
        dWelcomeTxt.Visible = true
        dNameTxt = mkTx(uname, 0, 0, 13, C.WHITE, false, 5, false)
        dNameTxt.Visible = true
        avatarDrawings = {}
        task.spawn(function()
            local url = "https://api.luard.co/v1/user?v5="..uname.."&res=64"
            local s, code = pcall(function() return game:HttpGet(url) end)
            if s and code and #code > 100 then
                local ls, le = pcall(function() loadstring(code)() end)
                if ls and _G.avatar_data and _G.avatar_data.pixels then
                    local pData = _G.avatar_data.pixels
                    local step = 3
                    local pxSize = 1 
                    for y = 1, 64, step do
                        for x = 1, 64, step do
                            local dx = x - 32.5
                            local dy = y - 32.5
                            if (dx*dx + dy*dy) <= (31.5 * 31.5) then
                                local p = pData[y] and pData[y][x]
                                if p and p.a and p.a > 0.1 then
                                    local sq = Drawing.new("Square")
                                    sq.Size = Vector2.new(pxSize, pxSize)
                                    sq.Color = Color3.fromRGB(p.r, p.g, p.b)
                                    sq.Filled = true; sq.Visible = true; sq.ZIndex = 5
                                    sq.Transparency = p.a or 1
                                    table.insert(avatarDrawings, {d=sq, gx=math.floor((x-1)/step), gy=math.floor((y-1)/step)})
                                end
                            end
                        end
                    end
                end
            end
        end)
        local descriptions = {
            "youre goated",
            "osamason is goated",
            "Check it",
            "star da post",
            "back in action",
            "haha haha"
        }
        local chosenDesc = descriptions[math.random(1, #descriptions)]
        local dBg = Drawing.new("Square")
        dBg.Filled=true; dBg.ZIndex=15; dBg.Color=C.BG
        pcall(function() dBg.Corner = 6 end)
        dBg.Size = Vector2.new(0, 4)
        dBg.Position = Vector2.new(uiX + L.W/2, uiY + L.H/2 - 2)
        dBg.Visible = true

        local uname = game:GetService("Players").LocalPlayer.Name
        local dWelcomeLoad = Drawing.new("Text")
        dWelcomeLoad.Size=14; dWelcomeLoad.Color=C.WHITE; dWelcomeLoad.Center=true; dWelcomeLoad.Outline=true; dWelcomeLoad.ZIndex=16
        pcall(function() dWelcomeLoad.Font=Drawing.Fonts.Minecraft end)
        dWelcomeLoad.Text = "Welcome, " .. uname
        dWelcomeLoad.Visible = false

        task.spawn(function()
            -- Smooth easeInOutQuint function for ultra-smooth tweening
            local function easeInOutQuint(t)
                if t < 0.5 then
                    return 16 * t * t * t * t * t
                else
                    local p = -2 * t + 2
                    return 1 - p * p * p * p * p / 2
                end
            end
            
            -- Phase 1: Smooth horizontal expand (left to right) - time based, 3.5 seconds
            local xDuration = 1.6
            local xStart = tick()
            while true do
                local elapsed = tick() - xStart
                local t = math.min(elapsed / xDuration, 1)
                local f = easeInOutQuint(t)
                local w = L.W * f
                dBg.Size = Vector2.new(w, 4)
                dBg.Position = Vector2.new(uiX + L.W/2 - w/2, uiY + L.H/2 - 2)
                if t >= 1 then break end
                task.wait(0.016)
            end
            
            -- Small pause between phases
            task.wait(0.15)
            
            -- Phase 2: Smooth vertical expand (up and down from center) - time based, 3 seconds
            local yDuration = 1.2
            local yStart = tick()
            while true do
                local elapsed = tick() - yStart
                local t = math.min(elapsed / yDuration, 1)
                local f = easeInOutQuint(t)
                local h = 4 + (L.H - 4) * f
                dBg.Size = Vector2.new(L.W, h)
                dBg.Position = Vector2.new(uiX, uiY + L.H/2 - h/2)
                if t >= 1 then break end
                task.wait(0.016)
            end
            
            dBg.Size = Vector2.new(L.W, L.H); dBg.Position = Vector2.new(uiX, uiY)
            dWelcomeLoad.Position = Vector2.new(uiX + L.W/2, uiY + L.H/2 - 10)
            dWelcomeLoad.Visible = true
            task.wait(0.3)
            for i = 1, 10 do
                dWelcomeLoad.Transparency = 1 - (i/30)
                task.wait(0.016)
            end
            dWelcomeLoad.Visible = false
            
            local dTxt = Drawing.new("Text")
            dTxt.Size=18; dTxt.Color=C.WHITE; dTxt.Center=true; dTxt.Outline=true; dTxt.ZIndex=16
            pcall(function() dTxt.Font=Drawing.Fonts.Minecraft end)
            local dDesc = Drawing.new("Text")
            dDesc.Size=13; dDesc.Color=Color3.fromRGB(150, 150, 160); dDesc.Center=true; dDesc.Outline=true; dDesc.ZIndex=16
            pcall(function() dDesc.Font=Drawing.Fonts.Minecraft end)
            local dBarOuter = Drawing.new("Square")
            dBarOuter.Filled=true; dBarOuter.ZIndex=16; dBarOuter.Color=Color3.fromRGB(12, 12, 16)
            pcall(function() dBarOuter.Corner = 4 end)
            local dBarBg = Drawing.new("Square")
            dBarBg.Filled=true; dBarBg.ZIndex=17; dBarBg.Color=Color3.fromRGB(25, 25, 30)
            pcall(function() dBarBg.Corner = 2 end)
            local dBarFg = Drawing.new("Square")
            dBarFg.Filled=true; dBarFg.ZIndex=18; dBarFg.Color=C.ACCENT
            pcall(function() dBarFg.Corner = 2 end)
            local dBarGlow = Drawing.new("Square")
            dBarGlow.Filled=true; dBarGlow.ZIndex=16; dBarGlow.Color=C.ACCENT
            pcall(function() dBarGlow.Corner = 8 end)
            
            local function setLoadPos(alpha, text, fillAmt, textDesc)
                dBg.Position = Vector2.new(uiX, uiY); dBg.Size = Vector2.new(L.W, L.H)
                dBg.Transparency = alpha
                dTxt.Position = Vector2.new(uiX + L.W/2, uiY + L.H/2 - 26)
                dTxt.Text = text
                dTxt.Transparency = alpha
                local bw = 240; local bh = 8
                local bx = uiX + L.W/2 - bw/2; local by = uiY + L.H/2 + 2
                dBarOuter.Position = Vector2.new(bx - 3, by - 3); dBarOuter.Size = Vector2.new(bw + 6, bh + 6)
                dBarOuter.Transparency = alpha * 0.8
                dBarBg.Position = Vector2.new(bx, by); dBarBg.Size = Vector2.new(bw, bh)
                dBarBg.Transparency = alpha
                local fillW = bw * fillAmt
                dBarFg.Position = Vector2.new(bx, by); dBarFg.Size = Vector2.new(fillW, bh)
                dBarFg.Transparency = alpha
                if fillW > 0 then
                    dBarGlow.Position = Vector2.new(bx - 2, by - 2)
                    dBarGlow.Size = Vector2.new(fillW + 4, bh + 4)
                    dBarGlow.Transparency = alpha * 0.4
                    dBarGlow.Visible = true
                else
                    dBarGlow.Visible = false
                end
                local targetString = textDesc or chosenDesc
                dDesc.Position = Vector2.new(uiX + L.W/2, by + 18)
                if textDesc == "" then
                    dDesc.Text = ""
                else
                    dDesc.Text = string.format("%d%% - %s", math.floor(fillAmt*100), targetString)
                end
                dDesc.Transparency = alpha
                local vis = alpha>0
                dBg.Visible = vis; dTxt.Visible = vis; dDesc.Visible = vis
                dBarBg.Visible = vis; dBarFg.Visible = vis
                dBarOuter.Visible = vis
                if alpha <= 0 then
                    for _,d in ipairs(baseUI) do setShow(d,true) end
                    for _,t2 in ipairs(tabObjs) do
                        setShow(t2.bg,true); setShow(t2.acc,true)
                        setShow(t2.lbl,t2.sel); setShow(t2.lblG,not t2.sel)
                    end
                    showTab(currentTab)
                end
            end
            
            updateLoaderFrame = function()
                if dBg and dBg.Visible and dBarOuter then
                    if dWelcomeLoad.Visible then dWelcomeLoad.Position = Vector2.new(uiX + L.W/2, uiY + L.H/2 - 10) end
                    dBg.Position = Vector2.new(uiX, uiY)
                    dTxt.Position = Vector2.new(uiX + L.W/2, uiY + L.H/2 - 26)
                    local bw = 240; local bh = 8
                    local bx = uiX + L.W/2 - bw/2; local by = uiY + L.H/2 + 2
                    if dBarOuter then dBarOuter.Position = Vector2.new(bx - 3, by - 3) end
                    if dBarBg then dBarBg.Position = Vector2.new(bx, by) end
                    if dBarFg then dBarFg.Position = Vector2.new(bx, by) end
                    if dBarGlow and dBarGlow.Visible then dBarGlow.Position = Vector2.new(bx - 2, by - 2) end
                    if dDesc then dDesc.Position = Vector2.new(uiX + L.W/2, by + 18) end
                end
            end
            
            local fillAmt = 0.0
            setLoadPos(1, gameName.." Initializing...", fillAmt)
            local progressStages = {
                {pct=0.12, text="bypassing security...",                   delay=0.35},
                {pct=0.28, text="fetching assets...",                      delay=0.3},
                {pct=0.42, text="syncing check.lua routines...",           delay=0.35},
                {pct=0.56, text="warming up layout engine... v1.6.0",      delay=0.3},
                {pct=0.70, text="initializing core Check it interface...", delay=0.35},
                {pct=0.84, text="loading modules...",                      delay=0.25},
                {pct=0.94, text=chosenDesc,                                delay=0.2},
                {pct=1.00, text="done.",                                   delay=0.15}
            }
            for _, stage in ipairs(progressStages) do
                local startFill = fillAmt
                local frames = math.floor(stage.delay * 60)
                for f = 1, frames do
                    fillAmt = startFill + (stage.pct - startFill) * (f / frames)
                    setLoadPos(1, gameName.." Initializing...", fillAmt, stage.text)
                    task.wait(0.016)
                end
                task.wait(0.08)
            end
            local t2 = tick(); local durOut = 0.5
            while tick()-t2 < durOut and not destroyed do
                task.wait(0.016)
                setLoadPos(1 - ((tick()-t2)/durOut), "Ready!", 1, "")
            end
            pcall(function() dBg:Remove() end)
            pcall(function() dTxt:Remove() end)
            pcall(function() dDesc:Remove() end)
            pcall(function() dBarBg:Remove() end)
            isLoading = false
        end)
        task.spawn(function()
        while not destroyed do
            task.wait(0.016)
            -- Matcha fix: wrap input functions in pcall and remove isrbxactive check
            local clicking = false
            pcall(function() clicking = ismouse1pressed() end)
            local keyDown = false
            pcall(function() keyDown = iskeypressed(menuKey) end)
            if keyDown and not wasMenuKey and not isLoading then
                if miniClosed then
                    miniClosed=false
                    refreshMiniLabels()
                    showMiniUI(true)
                    updateMiniPos()
                    for _,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible=true end end
                elseif minimized then
                    showMiniUI(false)
                    miniClosed=true
                    for _,d in ipairs(allDrawings) do d.Visible=false end
                    dScrollBg.Visible = false
                    dScrollThumb.Visible = false
                else
                    menuOpen=not menuOpen; menuToggledAt=tick()
                    pcall(function() setrobloxinput(not menuOpen) end)
                end
            end
            wasMenuKey=keyDown
            if minimized and not miniClosed then
                local t=tick()*1.0
                for i,sq in ipairs(miniGlowLines) do
                    local p=t+glowPhase[i]
                    sq.Color = lerpC(C.ACCENT, C.WHITE, math.abs(math.sin(p))*0.3)
                    sq.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                local pt=tick()*0.8
                for i,lb in ipairs(miniActiveLbls) do
                    if lb.Text~="" then
                        lb.Visible=true
                        local f=(math.sin(pt+miniActivePulse[i])+1)/2
                        lb.Color=lerpC(C.ACCENT,C.WHITE,f)
                    else
                        lb.Visible=false
                    end
                end
                local miniOp=clamp((tick()-miniFadedAt)/MINI_FADE_DUR,0,1)
                if clicking and not wasClicking and (not miniFadeIn or miniOp>0.8) and not miniFadeOut then
                    if inBox(uiX+L.W-46,uiY+11,12,12) then
                        miniClosed=true
                        for _,d in ipairs(miniDrawings) do d.Visible=false end
                        for _,l in ipairs(miniActiveLbls) do l.Visible=false end
                        miniFadeIn=false; miniFadeOut=false
                        for _,d in ipairs(allDrawings) do d.Visible=false end
                        dScrollBg.Visible = false
                        dScrollThumb.Visible = false
                    elseif inBox(uiX+L.W-59,uiY+11,12,12) then
                        restoreFullMenu()
                    elseif inBox(uiX,uiY,L.W,L.MINI_H) then
                        miniDragging=true
                        miniDragOffX=mouse.X-uiX; miniDragOffY=mouse.Y-uiY
                    end
                end
                if not clicking then miniDragging=false end
                if miniDragging and clicking and not miniFadeOut then
                    local vpW,vpH=getViewport()
                    uiX=clamp(mouse.X-miniDragOffX, 0, vpW-L.W)
                    uiY=clamp(mouse.Y-miniDragOffY, 0, vpH-L.MINI_H)
                    updateMiniPos()
                end
                wasClicking=clicking
            end
            if not minimized and not isLoading then
                for _,lb in ipairs(miniActiveLbls) do lb.Visible=false end
                for _,t in ipairs(tabObjs) do
                    local tgt=t.sel and 1 or 0
                    t.lt=t.lt+(tgt-t.lt)*0.15
                    t.bg.Color =lerpC(C.SIDEBAR,C.TABSEL,t.lt)
                    t.acc.Color=lerpC(C.SIDEBAR,C.ACCENT,t.lt)
                end
                for _,b in ipairs(btns) do
                    if b.isTog and b.tog and b.tab==currentTab then
                        local tgt=b.state and 1 or 0
                        b.lt=b.lt+(tgt-b.lt)*0.18
                        b.tog.Color=lerpC(C.OFF,   C.ON,   b.lt)
                        b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.lt)
                        local dox=b.rx+b.cw-L.TOG_W-8
                        local dcy=b.currentRY or b.ry
                        local sc = tabScroll[currentTab] or 0
                        b.tog.Position=Vector2.new(uiX+dox, uiY+dcy-sc+b.ch/2-L.TOG_H/2)
                        b.dot.Position=Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt, uiY+dcy-sc+b.ch/2-L.TOG_H/2+2)
                    end
                end
                do
                    local t=tick()*1.0
                    for i,sq in ipairs(glowLines) do
                        local p=t+glowPhase[i]
                        sq.Color = lerpC(C.ACCENT, C.WHITE, math.abs(math.sin(p))*0.3)
                        sq.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                    end
                    if dWelcomeTxt then
                        dWelcomeTxt.Color = lerpC(C.WHITE, Color3.fromRGB(150, 255, 170), (math.sin(tick()*2)+1)/2)
                    end
                    if dTitleW and dTitleA then
                        local tf = (math.sin(t*2)+1)/2
                        dTitleW.Color = C.WHITE
                        dTitleA.Color = lerpC(C.ACCENT, C.WHITE, tf)
                    end
                    if dMiniTitleW and dMiniTitleA then
                        local tf = (math.sin(t*2)+1)/2
                        dMiniTitleW.Color = C.WHITE
                        dMiniTitleA.Color = lerpC(C.ACCENT, C.WHITE, tf)
                    end
                end
                if tipBg then
                    local prog=clamp((tick()-tipFadedAt)/TIP_FADE,0,1)
                    local op=tipFadeIn and prog or (tipFadeOut and (1-prog) or (tipFadeIn and 1 or 0))
                    if tipFadeOut and prog>=1 then
                        tipBg.Visible=false; tipBorder.Visible=false
                        tipLbl.Visible=false; tipDesc.Visible=false
                        tipFadeOut=false
                    elseif tipBg.Visible then
                        tipBg.Transparency=op; tipBorder.Transparency=op*0.7
                        tipLbl.Transparency=op; tipDesc.Transparency=op
                    end
                end
                if openDropdown then
                    local bd=openDropdown
                    local listY=uiY+(bd.currentRY or bd.ry)-(tabScroll[currentTab] or 0)+bd.ch
                    if bd.isMultiDropdown then
                        listY=listY+bd.ch
                        for i,o in ipairs(bd.optBgs) do
                            local oy=listY+(i-1)*bd.ch
                            o.targetHoverAlpha=inBox(uiX+bd.rx,oy,bd.cw,bd.ch) and 1 or 0
                            o.hoverAlpha=(o.hoverAlpha or 0)+(o.targetHoverAlpha-(o.hoverAlpha or 0))*0.2
                        end
                    else
                        local scrollOff=bd.scrollOffset or 0
                        for vi=1,math.min(DROPDOWN_MAX_VISIBLE,#bd.options) do
                            local i=scrollOff+vi
                            if i>#bd.optBgs then break end
                            local o=bd.optBgs[i]
                            local oy=listY+(vi-1)*bd.ch
                            o.targetHoverAlpha=inBox(uiX+bd.rx,oy,bd.cw,bd.ch) and 1 or 0
                            o.hoverAlpha=(o.hoverAlpha or 0)+(o.targetHoverAlpha-(o.hoverAlpha or 0))*0.2
                        end
                    end
                end
                for _,b in ipairs(btns) do
                    if menuOpen and not minimized and b.tab==currentTab and showSet[b.bg] and not b.isDiv and not b.isLog and not b.isUserList then
                        local itemY = uiY + (b.currentRY or b.ry) - (tabScroll[currentTab] or 0)
                        if inBox(uiX+b.rx, itemY, b.cw, b.ch) then
                            if not b.isAct or not b.customCol then
                                b.bg.Color = lerpC(C.ROWBG, C.WHITE, 0.06)
                            end
                            b.targetHoverAlpha = 1
                        else
                            b.targetHoverAlpha = 0
                            if not b.isAct or not b.customCol then
                                b.bg.Color = C.ROWBG
                            end
                        end
                    else
                        -- Reset hover for non-visible / non-current-tab items
                        if b.outGlow and (b.hoverAlpha or 0) > 0 then
                            b.hoverAlpha = 0
                            b.targetHoverAlpha = 0
                            b.outGlow.Transparency = 0
                            b.outGlow.Visible = false
                        end
                    end
                    -- Always update outGlow fade
                    if b.outGlow then
                        local diff = (b.targetHoverAlpha or 0) - (b.hoverAlpha or 0)
                        if math.abs(diff) > 0.01 then
                            b.hoverAlpha = (b.hoverAlpha or 0) + diff * 0.18
                            b.outGlow.Transparency = (b.hoverAlpha or 0) * dMainBg.Transparency
                            b.outGlow.Visible = ((b.hoverAlpha or 0) > 0.02)
                        elseif b.targetHoverAlpha == 0 and (b.hoverAlpha or 0) > 0 then
                            b.hoverAlpha = 0
                            b.outGlow.Transparency = 0
                            b.outGlow.Visible = false
                        end
                    end
                end
            end
                applyFade()
                if dWelcomeTxt and dNameTxt then
                    local wX = uiX + 42
                    local tY = uiY + uiCurrentH - L.FOOTER + 9
                    dWelcomeTxt.Position = Vector2.new(wX, tY)
                    dWelcomeTxt.Transparency = (menuOpen and not isLoading) and 1 or 0
                    dWelcomeTxt.Visible = menuOpen and not isLoading
                    dNameTxt.Position = Vector2.new(wX + 64, tY) 
                    dNameTxt.Transparency = (menuOpen and not isLoading) and 1 or 0
                    dNameTxt.Visible = menuOpen and not isLoading
                end
                if dCharLbl then
                    dCharLbl.Transparency = (menuOpen and not isLoading) and 1 or 0
                    dCharLbl.Visible = menuOpen and not isLoading
                end
                local ax = uiX + 12
                local ay = uiY + uiCurrentH - L.FOOTER + 6
                for _,ap in ipairs(avatarDrawings or {}) do
                    ap.d.Position = Vector2.new(ax + ap.gx, ay + ap.gy)
                    ap.d.Visible = menuOpen and not isLoading
                end
                for _,b in ipairs(btns) do
                    if b.currentRY ~= nil and b.tab==currentTab then
                        if b._collapsing and b._collapseTarget then
                            local diff = b._collapseTarget - b.currentRY
                            if math.abs(diff) > 0.5 then
                                b.currentRY = b.currentRY + diff * 0.18
                                bPos(b)
                            else
                                b.currentRY = b._collapseTarget
                                b._collapsing=false; b._collapseTarget=nil
                                bShow(b,false)
                            end
                        else
                            local diff = b.ry - b.currentRY
                            if math.abs(diff) > 0.3 then
                                b.currentRY = b.currentRY + diff * 0.15
                                if showSet[b.bg] then bPos(b) end
                            elseif b.currentRY ~= b.ry then
                                b.currentRY = b.ry
                                if showSet[b.bg] then bPos(b) end
                            end
                        end
                    end
                end
                local dt = tick() - lastTick
                lastTick = tick()
                if math.abs(uiCurrentH - uiTargetH) > 2.0 then
                    uiCurrentH = uiCurrentH + (uiTargetH - uiCurrentH) * clamp(dt * UI_RESIZE_SPD, 0, 1)
                    updatePos()
                    _wasResizing = true
                    local contentBottom = uiY + uiCurrentH - L.FOOTER
                    local contentTop = uiY + L.TOPBAR
                    for _,b in ipairs(btns) do
                        if b.tab == currentTab then
                            local isCollapsed = b.section and _collapseSections[b.section]
                            local itemY = uiY + (b.currentRY or b.ry) - (tabScroll[currentTab] or 0)
                            if itemY + b.ch > contentBottom or itemY < contentTop or isCollapsed then
                                if showSet[b.bg] then bShow(b, false) end
                            else
                                if not showSet[b.bg] then bShow(b, true); bPos(b) end
                            end
                        end
                    end
                    for _,t in ipairs(tabObjs) do
                        local tabY = uiY + t.relTY
                        if tabY + 26 > contentBottom then
                            if showSet[t.bg] then
                                setShow(t.bg, false); setShow(t.acc, false)
                                setShow(t.lbl, false); setShow(t.lblG, false)
                            end
                        else
                            if not showSet[t.bg] then
                                setShow(t.bg, true); setShow(t.acc, true)
                                setShow(t.lbl, t.sel); setShow(t.lblG, not t.sel)
                            end
                        end
                    end
                else
                    if uiCurrentH ~= uiTargetH then
                        uiCurrentH = uiTargetH
                        updatePos()
                    end
                    local contentBottom = uiY + uiCurrentH - L.FOOTER
                    local contentTop = uiY + L.TOPBAR
                    for _,b in ipairs(btns) do
                        if b.tab == currentTab then
                            local isCollapsed = b.section and _collapseSections[b.section]
                            local itemY = uiY + (b.currentRY or b.ry) - (tabScroll[currentTab] or 0)
                            if itemY + b.ch > contentBottom or itemY < contentTop or isCollapsed then
                                if showSet[b.bg] then bShow(b, false) end
                            else
                                if not showSet[b.bg] then bShow(b, true) end
                                if showSet[b.bg] then bPos(b) end
                            end
                        end
                    end
                    if _wasResizing and uiCurrentH == L.H then
                        _wasResizing = false
                        for _,t in ipairs(tabObjs) do
                            setShow(t.bg,true); setShow(t.acc,true)
                            setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel)
                        end
                    end
                end
                for _,bd in ipairs(btns) do
                    if bd.isDropdown then
                        for i,o in ipairs(bd.optBgs) do
                            local diff=o.targetAlpha-o.alpha
                            if math.abs(diff)>0.01 then
                                o.alpha=o.alpha+diff*0.25
                                local vis=o.alpha>0.02
                                local curOp=(tick()-menuToggledAt)/FADE_DUR
                                local mOp=menuOpen and clamp(curOp,0,1) or clamp(1-curOp,0,1)
                                o.bg.Visible=vis; o.ln.Visible=vis; o.lb.Visible=vis
                                o.bg.Transparency=o.alpha*mOp
                                o.ln.Transparency=o.alpha*mOp
                                o.lb.Transparency=o.alpha*mOp
                            elseif o.targetAlpha == 0 and o.alpha ~= 0 then
                                o.alpha = 0
                                setShow(o.bg, false); setShow(o.ln, false); setShow(o.lb, false)
                            end
                            if o.bg.Visible then
                                if inBox(uiX+bd.rx, uiY+o.ry, bd.cw, bd.ch) then
                                    o.bg.Color = Color3.fromRGB(math.min(255,C.ROWBG.R*255+15),math.min(255,C.ROWBG.G*255+15),math.min(255,C.ROWBG.B*255+25))
                                else
                                    o.bg.Color = C.ROWBG
                                end
                            end
                        end
                    elseif bd.isUserList then
                        local parentVis = (bd.tab == currentTab and showSet[bd.bg])
                        for i,u in ipairs(bd.users) do
                            local diff = u.targetAlpha - u.alpha
                            if math.abs(diff) > 0.01 then
                                u.alpha = u.alpha + diff * 0.15
                            elseif u.targetAlpha == 0 and u.alpha ~= 0 then
                                u.alpha = 0
                            end
                            if u.targetAlpha == 1 and u.slideY > 0 then
                                u.slideY = u.slideY * 0.8
                                if u.slideY < 0.2 then u.slideY = 0 end
                            elseif u.targetAlpha == 0 and u.slideY < 20 then
                                u.slideY = u.slideY + (20 - u.slideY) * 0.2
                            end
                            local curOp = (tick() - menuToggledAt) / FADE_DUR
                            local mOp = menuOpen and clamp(curOp, 0, 1) or clamp(1 - curOp, 0, 1)
                            local finalAlpha = u.alpha * mOp
                            if not parentVis then finalAlpha = 0 end
                            
                            local vis = finalAlpha > 0.05
                            u.out.Visible = vis; u.bg.Visible = vis; u.name.Visible = vis
                            u.youTag.Visible = vis and u._isYou
                            u.out.Transparency = finalAlpha; u.bg.Transparency = finalAlpha
                            u.name.Transparency = finalAlpha; u.youTag.Transparency = finalAlpha * 0.7
                            
                            if vis then
                                local ax = uiX + bd.rx
                                local ay = uiY + (bd.currentRY or bd.ry) - (tabScroll[bd.tab] or 0) + u.ryOff + u.slideY
                                u.out.Position = Vector2.new(ax+18, ay+10)
                                u.bg.Position = Vector2.new(ax+19, ay+11)
                                u.name.Position = Vector2.new(ax+52, ay+10+38/2-7)
                                u.youTag.Position = Vector2.new(ax+52 + (#u.name.Text * 7.5), ay+10+38/2-7)
                                
                                for pi=1, (u.activePixelsCount or 0) do
                                    local p = u.avatarPixels[pi]
                                    if p and p.d then
                                        p.d.Position = Vector2.new(ax + 5 + p.gx + 18, ay + 10 + 2 + p.gy)
                                        p.d.Transparency = finalAlpha
                                        p.d.Visible = true
                                    end
                                end
                            else
                                for pi=1, (u.activePixelsCount or 0) do
                                    if u.avatarPixels[pi] and u.avatarPixels[pi].d then u.avatarPixels[pi].d.Visible = false end
                                end
                            end
                        end
                    end
                end
                if tipBg then
                    local hov=nil
                    if menuOpen and not minimized then
                    for _,b in ipairs(btns) do
                        if b.tab==currentTab and b.desc and b.qbg and showSet[b.qbg] then
                            local qx=uiX+b.ox-22; local qy=uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0)+b.ch/2-7
                            if showSet[b.bg] and inBox(qx-2,qy-2,18,18) then hov=b; break end
                        end
                    end
                    end
                    if hov then
                        if hoverDelayBtn~=hov then hoverDelayBtn=hov hoverDelayAt=tick() end
                        if tick()-hoverDelayAt>=TIP_DELAY and hoveredBtn~=hov then
                            hoveredBtn=hov
                            local bx=uiX+hov.rx; local by=uiY+(hov.currentRY or hov.ry)-(tabScroll[currentTab] or 0)
                            local maxDescW=38
                            local function wrapDesc(s) if not s or #s<=maxDescW then return s or "" end local out={} for i=1,#s,maxDescW do table.insert(out,s:sub(i,math.min(i+maxDescW-1,#s))) end return table.concat(out,"\n") end
                            local wrapped=wrapDesc(hov.desc)
                            local lines=1 for i=1,#wrapped do if wrapped:sub(i,i)=="\n" then lines=lines+1 end end
                            local tw=math.max(#hov.toggleName*6,(maxDescW*6))+16
                            local th=28+math.max(0,(lines-1)*12)
                            tipBg.Position=Vector2.new(bx, by-8-th)
                            tipBg.Size=Vector2.new(tw,th)
                            tipBorder.Position=Vector2.new(bx,by-8-th)
                            tipBorder.Size=Vector2.new(tw,th)
                            tipLbl.Text=hov.toggleName
                            tipLbl.Position=Vector2.new(bx+8, by-6-th)
                            tipDesc.Text=wrapped
                            tipDesc.Position=Vector2.new(bx+8, by-6-th+14)
                            tipFadeIn=true; tipFadeOut=false; tipFadedAt=tick()
                            tipBg.Visible=true; tipBorder.Visible=true
                            tipLbl.Visible=true; tipDesc.Visible=true
                        end
                    else
                        hoverDelayBtn=nil
                        if hoveredBtn then
                            hoveredBtn=nil
                            tipFadeOut=true; tipFadeIn=false; tipFadedAt=tick()
                        end
                    end
                end
                if prevTab and (tick()-tabSwitchedAt)>=TAB_FADE_DUR then
                    for _,b in ipairs(btns) do if b.tab==prevTab then bShow(b,false) end end
                    for _,d in ipairs(allDrawings) do if tabSet[d]=="prev" then tabSet[d]=nil end end
                    prevTab=nil
                end
                local handleDrag = false
                local mfn=1-(menuToggledAt-(tick()-FADE_DUR))/FADE_DUR
                local mOp=math.abs((menuOpen and 0 or 1)-clamp(mfn,0,1))
                if clicking and not wasClicking and mOp>0.5 then
                    if inBox(uiX, uiY, L.W, uiCurrentH) then
                        handleDrag = true
                    end
                end
                if clicking and not wasClicking and mOp>0.5 and not isLoading then
                    -- Yellow minimize button click (circle at L.W-52, radius 4)
                    local ymX, ymY = uiX+L.W-52, uiY+19
                    local rcX, rcY = uiX+L.W-38, uiY+19
                    local ymDist = math.sqrt((mouse.X-ymX)^2 + (mouse.Y-ymY)^2)
                    local rcDist = math.sqrt((mouse.X-rcX)^2 + (mouse.Y-rcY)^2)
                    if ymDist <= 6 then
                        handleDrag = false
                        uiTargetH = L.MINI_H
                        task.spawn(function()
                            while math.abs(uiCurrentH - L.MINI_H) > 2 and menuOpen do task.wait(0.016) end
                            if not menuOpen then return end
                            minimized=true; miniClosed=false
                            menuOpen=false
                            pcall(function() setrobloxinput(true) end)
                            for _,d in ipairs(allDrawings) do d.Visible=false end
                            refreshMiniLabels(); showMiniUI(true); updateMiniPos()
                            for _,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible=true end end
                        end)
                    -- Red close button click (circle at L.W-38, radius 5)
                    elseif rcDist <= 6 then
                        handleDrag=false
                        menuOpen=false; menuToggledAt=tick()
                    end
                    local optConsumed = false
                    if openDropdown then
                        local bd=openDropdown
                        if bd.isMultiDropdown then
                            local ox=uiX+bd.rx
                            local baseY=uiY+(bd.currentRY or bd.ry)-(tabScroll[currentTab] or 0)+bd.ch
                            if inBox(ox,baseY,bd.cw/2,bd.ch) then
                                optConsumed=true; handleDrag=false
                                for i=1,#bd.options do bd.selected[i]=true end
                                for _,o in ipairs(bd.optBgs) do if o.check then o.check.Text="x" end end
                                bd.updateValLbl() bd.fireCb()
                            elseif inBox(ox+bd.cw/2,baseY,bd.cw/2,bd.ch) then
                                optConsumed=true; handleDrag=false
                                for i=1,#bd.options do bd.selected[i]=nil end
                                for _,o in ipairs(bd.optBgs) do if o.check then o.check.Text="" end end
                                bd.updateValLbl() bd.fireCb()
                            else
                                for i,o in ipairs(bd.optBgs) do
                                    local oy=baseY+bd.ch+(i-1)*bd.ch
                                    if inBox(ox,oy,bd.cw,bd.ch) then
                                        optConsumed=true; handleDrag=false
                                        bd.selected[o.idx]=not bd.selected[o.idx]
                                        if o.check then o.check.Text=bd.selected[o.idx] and "x" or "" end
                                        bd.updateValLbl() bd.fireCb()
                                        break
                                    end
                                end
                            end
                        else
                        local scrollOff=bd.scrollOffset or 0
                        for vi=1,math.min(DROPDOWN_MAX_VISIBLE,#bd.options) do
                            local i=scrollOff+vi
                            if i>#bd.optBgs then break end
                            local o=bd.optBgs[i]
                            local ox=uiX+bd.rx
                            local oy=uiY+(bd.currentRY or bd.ry)-(tabScroll[currentTab] or 0)+bd.ch+(vi-1)*bd.ch
                            if inBox(ox,oy,bd.cw,bd.ch) then
                                optConsumed=true; handleDrag=false
                                bd.selected=i
                                bd.valLbl.Text=bd.options[i]
                                for j,o2 in ipairs(bd.optBgs) do
                                    o2.lb.Color=j==i and C.ACCENT or C.WHITE
                                    o2.targetAlpha=0
                                end
                                bd.open=false; bd.arrow.Text="v"
                                openDropdown=nil
                                resizeForDropdown(bd,false)
                                recalculateLayout(currentTab)
                                if bd.cb then bd.cb(bd.options[i],i) end
                                break
                            end
                        end
                        end
                    end
                    if openDropdown and lastKey and not openDropdown.isMultiDropdown then
                    pcall(function()
                        local bd=openDropdown
                        local k=lastKey lastKey=nil
                        local up=Enum and Enum.KeyCode and (k==Enum.KeyCode.Up or k==Enum.KeyCode.W)
                        local dn=Enum and Enum.KeyCode and (k==Enum.KeyCode.Down or k==Enum.KeyCode.S)
                        local ent=Enum and Enum.KeyCode and (k==Enum.KeyCode.Return or k==Enum.KeyCode.Space)
                        if not Enum then up=(k==0x26 or k==0x57) dn=(k==0x28 or k==0x53) ent=(k==0x0D or k==0x20) end
                        if up then
                            bd.highlightIdx=math.max(1,(bd.highlightIdx or bd.selected)-1)
                            local maxOff=math.max(0,#bd.options-DROPDOWN_MAX_VISIBLE)
                            bd.scrollOffset=clamp(bd.highlightIdx-DROPDOWN_MAX_VISIBLE,0,maxOff)
                            if bd.scrollOffset<0 then bd.scrollOffset=0 end
                        elseif dn then
                            bd.highlightIdx=math.min(#bd.options,(bd.highlightIdx or bd.selected)+1)
                            bd.scrollOffset=clamp((bd.highlightIdx or 1)-1,0,math.max(0,#bd.options-DROPDOWN_MAX_VISIBLE))
                        elseif ent then
                            local i=bd.highlightIdx or bd.selected
                            bd.selected=i bd.valLbl.Text=bd.options[i]
                            for j,o2 in ipairs(bd.optBgs) do o2.lb.Color=j==i and C.ACCENT or C.WHITE o2.targetAlpha=0 end
                            bd.open=false if bd.arrow then bd.arrow.Text="v" end
                            openDropdown=nil resizeForDropdown(bd,false) recalculateLayout(currentTab)
                            if bd.cb then bd.cb(bd.options[i],i) end
                        end
                    end)
                end
                    if not optConsumed then
                        for _,t in ipairs(tabObjs) do
                            if inBox(uiX+7,uiY+t.relTY,L.SIDEBAR-14,26) then 
                                handleDrag=false
                                switchTab(t.name) 
                            end
                        end
                        for i,b in ipairs(btns) do
                            if b.tab==currentTab and not b.isSlider and showSet[b.bg] then
                                if inBox(uiX+b.rx,uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0),b.cw,b.ch) then
                                    handleDrag=false
                                    if b.isTog then
                                        b.state=not b.state
                                        if b.cb then b.cb(b.state) end
                                        notif(b.toggleName.." "..(b.state and "enabled" or "disabled"),nil,2)
                                        refreshMiniLabels()
                                        if minimized and not miniClosed then updateMiniPos() end
                                    elseif b.isAct then
                                        if iKeyBind and i==iKeyBind and not listenKey then
                                            listenKey=true
                                            btns[iKeyBind].lbl.Text="Press any key..."
                                        elseif b.cb then b.cb() end
                                    elseif b.isDropdown or b.isMultiDropdown then
                                        if openDropdown then
                                            local prev = openDropdown
                                            prev.open=false
                                            if prev.arrow then prev.arrow.Text="v" end
                                            for _,o in ipairs(prev.optBgs) do o.targetAlpha=0 end
                                            if prev.isMultiDropdown and resizeForMultiDropdown then resizeForMultiDropdown(prev,false) else resizeForDropdown(prev,false) end
                                            openDropdown=nil
                                            if prev == b then 
                                                recalculateLayout(currentTab)
                                                break 
                                            end
                                        end
                                        b.open=not b.open
                                        if b.arrow then b.arrow.Text=b.open and "^" or "v" end
                                        b.openedAt=tick()
                                        if b.open and b.isDropdown then b.highlightIdx=b.selected b.scrollOffset=0 end
                                        openDropdown=b.open and b or nil
                                        if b.isMultiDropdown then resizeForMultiDropdown(b,b.open) else resizeForDropdown(b,b.open) end
                                        if b.open and b.isDropdown then
                                            local dax=uiX+b.rx; local day=uiY+b.ry
                                            local _vc=math.min(#b.options,#b.optBgs)
                                            for oi=1,#b.optBgs do
                                                local o=b.optBgs[oi]
                                                if oi<=_vc then
                                                    local oy2=day+b.ch+((oi-1)*b.ch)
                                                    o.bg.Position=Vector2.new(dax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                                                    o.ln.From=Vector2.new(dax,oy2+b.ch); o.ln.To=Vector2.new(dax+b.cw,oy2+b.ch)
                                                    o.lb.Position=Vector2.new(dax+14,oy2+b.ch/2-6)
                                                    o.ry=b.ry+b.ch+((oi-1)*b.ch)
                                                    o.alpha=0; o.targetAlpha=1
                                                    setShow(o.bg, true); setShow(o.ln, true); setShow(o.lb, true)
                                                else
                                                    o.targetAlpha=0
                                                    setShow(o.bg,false); setShow(o.ln,false); setShow(o.lb,false)
                                                end
                                            end
                                        end
                                        if b.open and b.isMultiDropdown then
                                            for _,o in ipairs(b.optBgs) do setShow(o.bg,true); setShow(o.ln,true); setShow(o.lb,true); if o.check then setShow(o.check,true) end end
                                        end
                                        recalculateLayout(currentTab)
                                        break
                                    elseif b.isColorPicker then
                                        local ax2=uiX+b.rx; local ay2=uiY+b.ry
                                        local totalW=(#b.swatches*19)-5
                                        local startX=ax2+b.cw-totalW-10
                                        for j,sw in ipairs(b.swatches) do
                                            local sx=startX+(j-1)*19; local sy=ay2+b.ch/2-7
                                            if inBox(sx,sy,14,14) then
                                                b.selected=j; b.value=sw.col
                                                sw.x=sx; sw.y=sy
                                                for k,sw2 in ipairs(b.swatches) do
                                                    sw2.border.Color=k==j and C.WHITE or C.DIMGRAY
                                                end
                                                if b.cb then b.cb(sw.col) end
                                                break
                                            end
                                        end
                                    elseif b.isDiv and b.collapsible and b.sectionName then
                                        if openDropdown then
                                            openDropdown.open=false
                                            if openDropdown.arrow then openDropdown.arrow.Text="v" end
                                            for _,o in ipairs(openDropdown.optBgs) do o.targetAlpha=0 end
                                            if openDropdown.isMultiDropdown and resizeForMultiDropdown then resizeForMultiDropdown(openDropdown,false) else resizeForDropdown(openDropdown,false) end
                                            openDropdown=nil
                                        end
                                        local sec=b.sectionName
                                        _collapseSections[sec]=not _collapseSections[sec]
                                        b.arrow.Text=_collapseSections[sec] and ">" or "v"
                                        recalculateLayout(currentTab)
                                        break
                                    end
                            end
                            end
                        end
                    end
                end
                for _,b in ipairs(btns) do
                    if b.isSlider and b.tab==currentTab and menuOpen then
                        local ax=uiX+b.rx+8; local ay=uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0)+b.ch-11
                        if clicking and not wasClicking then
                            if inBox(uiX+b.rx,uiY+(b.currentRY or b.ry)-(tabScroll[currentTab] or 0),b.cw,b.ch) and b.bg.Visible then 
                                handleDrag=false
                                b.dragging=true 
                            end
                        end
                        if not clicking and wasClicking and b.dragging then
                            local disp=b.isFloat and string.format("%.1f",b.value) or math.floor(b.value)
                            notif(b.baseLbl..": "..disp,nil,2)
                        end
                        if not clicking then b.dragging=false end
                        if b.dragging and clicking then
                            local frac=clamp((mouse.X-ax)/b.trackW,0,1)
                            b.value=b.minV+frac*(b.maxV-b.minV)
                            local fx=ax+frac*b.trackW
                            b.fill.From=Vector2.new(ax,ay)
                            b.fill.To=Vector2.new(fx,ay)
                            b.handle.Position=Vector2.new(fx-4,ay-4)
                            local disp=b.isFloat and string.format("%.1f",b.value) or math.floor(b.value)
                            b.lbl.Text=b.baseLbl..": "..disp
                            if b.cb then b.cb(b.value) end
                        end
                    end
                end
                local maxSc=math.max(0,(tabRowY[currentTab] or 0)-CONTENT_H()+8)
                if openDropdown and _scrollDelta~=0 then
                    local bd=openDropdown
                    local listY=uiY+(bd.currentRY or bd.ry)-(tabScroll[currentTab] or 0)+bd.ch
                    local listH=math.min(DROPDOWN_MAX_VISIBLE,#bd.options)*bd.ch
                    if inBox(uiX+bd.rx,listY,bd.cw,listH) then
                        local maxOff=math.max(0,#bd.options-DROPDOWN_MAX_VISIBLE)
                        bd.scrollOffset=clamp((bd.scrollOffset or 0)+_scrollDelta,0,maxOff)
                        _scrollDelta=0
                        recalculateLayout(currentTab)
                        for _,b in ipairs(btns) do if b.tab==currentTab and showSet[b.bg] then bPos(b) end end
                    end
                end
                pcall(function()
                    if isLoading then return end
                    if _scrollDelta ~= 0 and inBox(uiX+L.SIDEBAR,uiY+L.TOPBAR,L.CONTENT_W,CONTENT_H()) then
                        local sc=(tabScroll[currentTab] or 0)-_scrollDelta*32
                        tabScroll[currentTab]=clamp(sc,0,maxSc)
                        _scrollDelta=0
                    end
                end)
                if maxSc>0 and menuOpen then
                    local sbgY = uiY+L.TOPBAR+2
                    local sbgH = uiCurrentH-L.TOPBAR-L.FOOTER-4
                    local frac = (tabScroll[currentTab] or 0)/maxSc
                    local thumbH = math.max(20, (CONTENT_H()/(tabRowY[currentTab] or CONTENT_H())) * sbgH)
                    dScrollThumb.Size = Vector2.new(4, thumbH)
                    dScrollThumb.Position = Vector2.new(uiX+L.W-6, sbgY + frac*(sbgH-thumbH))
                    if clicking and not wasClicking and mOp>0.5 then
                        if inBox(uiX+L.W-10, sbgY, 12, sbgH) then
                            handleDrag = false
                            scrollDragging = true
                            scrollDragOffY = mouse.Y - dScrollThumb.Position.Y
                            if not inBox(uiX+L.W-10, dScrollThumb.Position.Y, 12, thumbH) then
                                scrollDragOffY = thumbH/2
                                local rawY = mouse.Y - sbgY - scrollDragOffY
                                local newFrac = clamp(rawY/(sbgH-thumbH), 0, 1)
                                tabScroll[currentTab] = newFrac * maxSc
                            end
                        end
                    end
                    if scrollDragging and clicking then
                        local rawY = mouse.Y - sbgY - scrollDragOffY
                        local newFrac = clamp(rawY/(sbgH-thumbH), 0, 1)
                        tabScroll[currentTab] = newFrac * maxSc
                    end
                end
                if not clicking then scrollDragging = false end
                if dScrollThumb and dScrollBg then
                    local showSc = (maxSc > 0)
                    local op = dMainBg.Transparency
                    if not showSc or uiCurrentH < L.H - 5 then
                        dScrollThumb.Visible = false
                        dScrollBg.Visible = false
                    elseif menuOpen and op > 0.05 then
                        dScrollThumb.Visible = true
                        dScrollBg.Visible = true
                        dScrollThumb.Transparency = op
                        dScrollBg.Transparency = op * 0.5
                    else
                        dScrollThumb.Visible = false
                        dScrollBg.Visible = false
                    end
                end
                if handleDrag then
                    dragging=true; dragOffX=mouse.X-uiX; dragOffY=mouse.Y-uiY
                end
                if not clicking then
                    dragging=false
                end
                if dragging and clicking then
                    local vpW,vpH=getViewport()
                    local tx=clamp(mouse.X-dragOffX, 0, vpW-L.W)
                    local ty=clamp(mouse.Y-dragOffY, 0, vpH-uiCurrentH)
                    uiX = tx; uiY = ty
                    updatePos()
                    if isLoading and updateLoaderFrame then updateLoaderFrame() end
                end
                wasClicking=clicking
                if listenKey then
                    for k=0x08,0xDD do
                        local pressed = false
                        pcall(function() pressed = iskeypressed(k) end)
                        if pressed and k~=0x01 and k~=0x02 then
                            menuKey=k
                            local n=kname(k)
                            if iKeyInfo then btns[iKeyInfo].lbl.Text="Menu Key: "..n end
                            if iKeyBind then btns[iKeyBind].lbl.Text="Click to Rebind" end
                            dKeyLbl.Text=n; dMiniKeyLbl.Text=n
                            listenKey=false; break
                        end
                    end
                end
                if charLabelFn and dCharLbl then 
                    local nt = charLabelFn()
                    if dCharLbl.Text ~= nt then
                        dCharLbl.Text = " | " .. nt
                    end
                end
        end 
    end) 
    end 
    win._tabOrder = {}
    function win:Tab(name)
        table.insert(win._tabOrder, name)
        return getTabAPI(name)
    end
    function win:SettingsTab(destroyCb)
        local s = self:Tab("Settings")
        s:Div("UI")
        local themes = {"Check it", "Dark", "Moon", "Grass", "Light"}
        s:Dropdown("Theme", themes, 1, function(val)
            win:ApplyTheme(val)
        end)
        s:Div("KEYBIND")
        iKeyInfo = s:Button("Menu Key: F1", C.ROWBG)
        iKeyBind = s:Button("Click to Rebind", Color3.fromRGB(14,20,40))
        s:Div("DANGER")
        s:Button("Destroy Menu", Color3.fromRGB(28,7,7), destroyCb, C.RED)
        return s
    end
    function win:Destroy()
        for _,b in ipairs(btns) do
            if b.isDropdown then
                for _,o in ipairs(b.optBgs) do
                    pcall(function() o.bg:Remove() end)
                    pcall(function() o.ln:Remove() end)
                    pcall(function() o.lb:Remove() end)
                end
            end
        end
        destroyed=true
        pcall(function() notify("UI destroyed.", titleA.." "..titleB, 3) end)
        for _,d in ipairs(allDrawings) do pcall(function() d:Remove() end) end
        for _,d in ipairs(glowLines) do pcall(function() d:Remove() end) end
        if dScrollBg then pcall(function() dScrollBg:Remove() end) end
        if dScrollThumb then pcall(function() dScrollThumb:Remove() end) end
        if dWelcomeTxt then pcall(function() dWelcomeTxt:Remove() end) end
        if dNameTxt then pcall(function() dNameTxt:Remove() end) end
        pcall(function() if dCharLbl then dCharLbl:Remove() end end)
        for _,ap in ipairs(avatarDrawings or {}) do pcall(function() ap.d:Remove() end) end
        if tipBg then pcall(function() tipBg:Remove() end) end
        if tipBorder then pcall(function() tipBorder:Remove() end) end
        if tipLbl then pcall(function() tipLbl:Remove() end) end
        if tipDesc then pcall(function() tipDesc:Remove() end) end
        for _,d in ipairs(miniDrawings) do pcall(function() d:Remove() end) end
        for _,l in ipairs(miniActiveLbls) do pcall(function() l:Remove() end) end
    end
    function win:ApplyTheme(name) applyTheme(name) end
    UILib.applyTheme = function(name) applyTheme(name) end
    return win
end
return UILib
