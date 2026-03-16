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
    ["Fatal Frame"] = { -- no need to change i did it for you
        ACCENT=Color3.fromRGB(122,30,44),  BG=Color3.fromRGB(12,10,10),
        SIDEBAR=Color3.fromRGB(16,12,12),  CONTENT=Color3.fromRGB(14,11,11),
        TOPBAR=Color3.fromRGB(10,8,8),     BORDER=Color3.fromRGB(50,20,25),
        ROWBG=Color3.fromRGB(18,14,14),    TABSEL=Color3.fromRGB(50,18,24),
        WHITE=Color3.fromRGB(220,210,210), GRAY=Color3.fromRGB(120,100,100),
        DIMGRAY=Color3.fromRGB(35,25,25),
        ON=Color3.fromRGB(122,30,44),      OFF=Color3.fromRGB(28,18,18),
        ONDOT=Color3.fromRGB(220,160,170), OFFDOT=Color3.fromRGB(70,50,50),
        DIV=Color3.fromRGB(30,20,20),      MINIBAR=Color3.fromRGB(14,11,11),
    },
    ["Dark"] = {
        ACCENT=Color3.fromRGB(180,180,180), BG=Color3.fromRGB(4,4,6),
        SIDEBAR=Color3.fromRGB(6,6,9),     CONTENT=Color3.fromRGB(5,5,8),
        TOPBAR=Color3.fromRGB(3,3,5),      BORDER=Color3.fromRGB(20,20,28),
        ROWBG=Color3.fromRGB(7,7,10),      TABSEL=Color3.fromRGB(15,15,22),
        WHITE=Color3.fromRGB(190,190,195), GRAY=Color3.fromRGB(80,80,90),
        DIMGRAY=Color3.fromRGB(15,15,20),
        ON=Color3.fromRGB(100,100,110),    OFF=Color3.fromRGB(12,12,16),
        ONDOT=Color3.fromRGB(220,220,225), OFFDOT=Color3.fromRGB(45,45,55),
        DIV=Color3.fromRGB(14,14,18),      MINIBAR=Color3.fromRGB(6,6,8),
    },
    ["Moon"] = {
        ACCENT=Color3.fromRGB(150,150,165), BG=Color3.fromRGB(12,12,14),
        SIDEBAR=Color3.fromRGB(16,16,18),  CONTENT=Color3.fromRGB(14,14,16),
        TOPBAR=Color3.fromRGB(10,10,12),   BORDER=Color3.fromRGB(40,40,46),
        ROWBG=Color3.fromRGB(18,18,22),    TABSEL=Color3.fromRGB(30,30,36),
        WHITE=Color3.fromRGB(220,220,225), GRAY=Color3.fromRGB(120,120,130),
        DIMGRAY=Color3.fromRGB(40,40,45),
        ON=Color3.fromRGB(100,100,115),    OFF=Color3.fromRGB(25,25,30),
        ONDOT=Color3.fromRGB(200,200,215), OFFDOT=Color3.fromRGB(70,70,80),
        DIV=Color3.fromRGB(30,30,36),      MINIBAR=Color3.fromRGB(16,16,20),
    },
    ["Grass"] = {
        ACCENT=Color3.fromRGB(60,200,100), BG=Color3.fromRGB(8,14,10),
        SIDEBAR=Color3.fromRGB(10,18,13),  CONTENT=Color3.fromRGB(9,16,11),
        TOPBAR=Color3.fromRGB(6,11,8),     BORDER=Color3.fromRGB(25,55,35),
        ROWBG=Color3.fromRGB(11,20,14),    TABSEL=Color3.fromRGB(18,45,25),
        WHITE=Color3.fromRGB(200,235,210), GRAY=Color3.fromRGB(90,130,105),
        DIMGRAY=Color3.fromRGB(20,40,28),
        ON=Color3.fromRGB(30,140,65),      OFF=Color3.fromRGB(15,30,20),
        ONDOT=Color3.fromRGB(150,240,180), OFFDOT=Color3.fromRGB(45,80,58),
        DIV=Color3.fromRGB(18,35,24),      MINIBAR=Color3.fromRGB(10,18,13),
    },
    ["Light"] = {
        ACCENT=Color3.fromRGB(122,30,44),  BG=Color3.fromRGB(230,225,225),
        SIDEBAR=Color3.fromRGB(215,210,210),CONTENT=Color3.fromRGB(220,215,215),
        TOPBAR=Color3.fromRGB(200,195,195),BORDER=Color3.fromRGB(170,160,165),
        ROWBG=Color3.fromRGB(210,205,205), TABSEL=Color3.fromRGB(200,185,190),
        WHITE=Color3.fromRGB(25,20,20),    GRAY=Color3.fromRGB(100,85,85),
        DIMGRAY=Color3.fromRGB(185,175,175),
        ON=Color3.fromRGB(122,30,44),      OFF=Color3.fromRGB(180,170,170),
        ONDOT=Color3.fromRGB(255,255,255), OFFDOT=Color3.fromRGB(140,130,130),
        DIV=Color3.fromRGB(185,175,175),   MINIBAR=Color3.fromRGB(205,200,200),
    },
}
local ok, _ = pcall(function() return THEMES["Crimson"].ACCENT end)
if not ok then THEMES = {} end
UILib.Themes = THEMES
local C = {
    ACCENT  = Color3.fromRGB(122,30,44),  BG      = Color3.fromRGB(12,10,10),
    SIDEBAR = Color3.fromRGB(16,12,12),   CONTENT = Color3.fromRGB(14,11,11),
    TOPBAR  = Color3.fromRGB(10,8,8),     BORDER  = Color3.fromRGB(50,20,25),
    ROWBG   = Color3.fromRGB(18,14,14),   TABSEL  = Color3.fromRGB(50,18,24),
    WHITE   = Color3.fromRGB(220,210,210),GRAY    = Color3.fromRGB(120,100,100),
    DIMGRAY = Color3.fromRGB(35,25,25),
    ON      = Color3.fromRGB(122,30,44),  OFF     = Color3.fromRGB(28,18,18),
    ONDOT   = Color3.fromRGB(220,160,170),OFFDOT  = Color3.fromRGB(70,50,50),
    DIV     = Color3.fromRGB(30,20,20),   MINIBAR = Color3.fromRGB(14,11,11),
    GREEN   = Color3.fromRGB(45,190,95),
    RED     = Color3.fromRGB(210,55,55),
    SHADOW  = Color3.fromRGB(0,0,5),
    ORANGE  = Color3.fromRGB(255,175,80),
    YELLOW  = Color3.fromRGB(190,148,0),
}
UILib.Colors = C
_G.UILib = UILib
print("[UILib] v2.0.0 loaded")


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

local L = {
    W=560, H=490,
    TOPBAR=32, TABBAR=28,
    FOOTER=28, ROW_H=36,
    ROW_PAD=8, TOG_W=34,
    TOG_H=17, HDL=8,
    MINI_H=80, COL_GAP=10,
}
L.CONTENT_TOP = L.TOPBAR + L.TABBAR
L.CONTENT_H = L.H - L.CONTENT_TOP - L.FOOTER
L.COL_W = math.floor((L.W - L.ROW_PAD*3 - L.COL_GAP) / 2)

local kn={}
for i=0x41,0x5A do kn[i]=string.char(i) end
for i=0x30,0x39 do kn[i]=tostring(i-0x30) end
for i=0x60,0x69 do kn[i]="Num"..tostring(i-0x60) end
kn[0x70]="F1" kn[0x71]="F2" kn[0x72]="F3" kn[0x73]="F4"
kn[0x74]="F5" kn[0x75]="F6" kn[0x76]="F7" kn[0x77]="F8"
kn[0x78]="F9" kn[0x79]="F10" kn[0x7A]="F11" kn[0x7B]="F12"
kn[0x20]="Space" kn[0x09]="Tab" kn[0x0D]="Enter" kn[0x1B]="Esc"
kn[0x08]="Back" kn[0x24]="Home" kn[0x23]="End" kn[0x2E]="Del"
kn[0x2D]="Ins" kn[0x21]="PgUp" kn[0x22]="PgDn"
kn[0x26]="Up" kn[0x28]="Down" kn[0x25]="Left" kn[0x27]="Right"
kn[0xBC]="," kn[0xBE]="." kn[0xBF]="/" kn[0xBA]=";"
kn[0xBB]="=" kn[0xBD]="-" kn[0xDB]="[" kn[0xDD]="]"
kn[0xDC]="\\" kn[0xDE]="'" kn[0xC0]="`"
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
    local uiX, uiY = 300, 150
    local dragging, dragOffX, dragOffY = false, 0, 0
    local wasClicking = false
    local currentTab = nil
    local menuKey = 0x70
    local listenKey = false
    local destroyed = false
    local wasMenuKey = false
    local menuOpen = true
    local menuToggledAt = tick() - 1
    local FADE_DUR = 0.35
    local TAB_FADE_DUR = 0.18
    local tabSwitchedAt = tick() - 1
    local prevTab = nil
    local minimized = false
    local miniClosed = false
    local miniDragging = false
    local miniDragOffX, miniDragOffY = 0, 0
    local MINI_FADE_DUR = 0.25
    local UI_RESIZE_SPD = 12.0
    local lastTick = tick()
    local glowPhase = {0, math.pi*0.6}
    local scrollDragging = false
    local scrollDragOffY = 0
    local DROPDOWN_MAX_VISIBLE = 6
    local allDrawings = {}
    local showSet = {}
    local tabSet = {}
    local baseUI = {}
    local tabObjs = {}
    local btns = {}
    local tabAPI = {}
    local tabRowY = {}
    local tabScroll = {}
    local miniDrawings = {}
    local miniActiveLbls = {}
    local miniActivePulse = {}
    local MAX_MINI_LBLS = 12
    local openDropdown = nil
    local iKeyInfo, iKeyBind
    local tipBg, tipBorder, tipLbl, tipDesc
    local hoveredBtn = nil
    local tipFadeIn, tipFadeOut = false, false
    local tipFadedAt = tick()-1
    local TIP_FADE = 0.35
    local TIP_DELAY = 0.2
    local hoverDelayBtn, hoverDelayAt = nil, 0
    local dWelcomeTxt, dNameTxt
    local uiTargetH = L.H
    local uiCurrentH = L.H

    for i=1,MAX_MINI_LBLS do
        local lb = mkTx("",0,0,13,C.WHITE,false,9,false)
        lb.Outline=true; lb.Visible=false; lb.Transparency=1
        table.insert(miniActiveLbls,lb)
        table.insert(miniActivePulse,i*0.7)
    end

    local function mkD(d) table.insert(allDrawings,d); d.Visible=false; return d end
    local function setShow(d,yes) showSet[d]=yes or nil; d.Visible=yes and true or false end
    local function inBox(x,y,w,h) return mouse.X>=x and mouse.X<=x+w and mouse.Y>=y and mouse.Y<=y+h end

    local function bShow(b,yes)
        setShow(b.bg,yes)
        if b.out then setShow(b.out,yes) end
        if b.outGlow then setShow(b.outGlow, yes and (b.hoverAlpha or 0) > 0.02) end
        if not b.isLog then setShow(b.lbl,yes) end
        if b.ln then setShow(b.ln,yes) end
        if b.tog then setShow(b.tog,yes) end
        if b.dot then setShow(b.dot,yes) end
        if b.track then setShow(b.track,yes) end
        if b.fill then setShow(b.fill,yes) end
        if b.handle then setShow(b.handle,yes) end
        if b.lbls then for _,l in ipairs(b.lbls) do setShow(l,yes) end end
        if b.qbg then setShow(b.qbg,yes) end
        if b.qlb then setShow(b.qlb,yes) end
        if b.dlb then setShow(b.dlb,yes) end
        if b.arrow then setShow(b.arrow,yes) end
        if b.valLbl then setShow(b.valLbl,yes) end
        if b.inputBg then setShow(b.inputBg,yes) end
        if b.inputTx then setShow(b.inputTx,yes) end
        if b.swatches then
            for _,sw in ipairs(b.swatches) do setShow(sw.sq,yes); setShow(sw.border,yes) end
        end
        if b.isDropdown then
            if b.panelBg then setShow(b.panelBg, yes and b.open) end
            if b.panelBorder then setShow(b.panelBorder, yes and b.open) end
            for _,o in ipairs(b.optBgs) do
                setShow(o.bg, yes and b.open); setShow(o.ln, yes and b.open); setShow(o.lb, yes and b.open)
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
                setShow(o.bg, yes and b.open); setShow(o.ln, yes and b.open); setShow(o.lb, yes and b.open)
                if o.check then setShow(o.check, yes and b.open) end
            end
        end
    end

    local function bPos(b)
        local animY = b.currentRY or b.ry
        local sc = tabScroll[b.tab.."_"..b.col] or 0
        local colOff = b.col == "right" and (L.ROW_PAD + L.COL_W + L.COL_GAP) or L.ROW_PAD
        local ax, ay = uiX + colOff + (b.rxOff or 0), uiY + animY - sc
        b.bg.Position = Vector2.new(ax, ay)
        if b.outGlow then b.outGlow.Position = Vector2.new(ax-1, ay-1) end
        if b.isDiv then
            b.lbl.Position = Vector2.new(ax+6, ay)
            if b.ln then b.ln.From=Vector2.new(ax,ay+13); b.ln.To=Vector2.new(ax+b.cw,ay+13) end
            if b.arrow then b.arrow.Position=Vector2.new(ax+b.cw-6,ay); b.arrow.Text=_collapseSections[b.sectionName] and ">" or "v" end
        elseif b.isAct then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+b.cw/2,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
        elseif b.isSlider then
            b.lbl.Position=Vector2.new(ax+8,ay+5)
            if b.dlb then b.dlb.Position=Vector2.new(ax+8,ay+18) end
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            local tx,ty=ax+8,ay+b.ch-10
            b.track.From=Vector2.new(tx,ty); b.track.To=Vector2.new(tx+b.trackW,ty)
            local range=b.maxV-b.minV
            local frac=range>0 and clamp((b.value-b.minV)/range,0,1) or 0
            local fx=tx+frac*b.trackW
            b.fill.From=Vector2.new(tx,ty); b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
        elseif b.isDropdown then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.valLbl.Position=Vector2.new(ax+b.cw-28-(#b.valLbl.Text*5.5),ay+b.ch/2-6)
            if b.arrow then b.arrow.Position=Vector2.new(ax+b.cw-11,ay+b.ch/2-6); b.arrow.Text=b.open and "^" or "v" end
            local scrollOff=b.scrollOffset or 0
            local maxVis=math.min(DROPDOWN_MAX_VISIBLE,b.options and #b.options or 0)
            if b.panelBg then setShow(b.panelBg, b.open) end
            if b.panelBorder then setShow(b.panelBorder, b.open) end
            if b.open and b.panelBg then
                local py=ay+b.ch; local ph=maxVis*b.ch
                b.panelBg.Position=Vector2.new(ax,py); b.panelBg.Size=Vector2.new(b.cw,ph)
                b.panelBorder.Position=Vector2.new(ax,py); b.panelBorder.Size=Vector2.new(b.cw,ph)
            end
            for i,o in ipairs(b.optBgs) do
                local vi=i-scrollOff; local visible=vi>=1 and vi<=maxVis
                if visible then
                    local oy2=ay+b.ch+((vi-1)*b.ch)
                    o.bg.Position=Vector2.new(ax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                    o.ln.From=Vector2.new(ax,oy2+b.ch); o.ln.To=Vector2.new(ax+b.cw,oy2+b.ch)
                    o.lb.Position=Vector2.new(ax+12,oy2+b.ch/2-6)
                    o.bg.Color=lerpC(C.ROWBG,C.WHITE,(o.hoverAlpha or 0)*0.12)
                end
                setShow(o.bg, b.open and visible); setShow(o.ln, b.open and visible); setShow(o.lb, b.open and visible)
            end
        elseif b.isTextInput then
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            b.inputBg.Position=Vector2.new(ax+b.cw-b.inputW-8, ay+b.ch/2-9)
            b.inputTx.Position=Vector2.new(ax+b.cw-b.inputW-2, ay+b.ch/2-6)
        elseif b.isColorPicker then
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            local totalW=(#b.swatches*19)-5; local startX=ax+b.cw-totalW-10
            for i,sw in ipairs(b.swatches) do
                local sx=startX+(i-1)*19; local sy=ay+b.ch/2-7
                sw.sq.Position=Vector2.new(sx,sy); sw.border.Position=Vector2.new(sx-1,sy-1)
                sw.x=sx; sw.y=sy
            end
        else
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            if b.tog then
                local dox=b.cw-L.TOG_W-8; local dcy=b.currentRY or b.ry
                b.tog.Position=Vector2.new(ax+dox, ay+b.ch/2-L.TOG_H/2)
                b.dot.Position=Vector2.new(ax+dox+2+(L.TOG_W-L.TOG_H)*b.lt, ay+b.ch/2-L.TOG_H/2+2)
            end
            if b.qbg then
                local qx=ax+b.cw-L.TOG_W-30; local qy=ay+b.ch/2-7
                b.qbg.Position=Vector2.new(qx,qy)
                if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+4) end
            end
        end
    end

    local function tagBtnFade(b,group)
        tabSet[b.bg]=group
        if not b.isLog then tabSet[b.lbl]=group end
        if b.outGlow then tabSet[b.outGlow]=group end
        if b.ln then tabSet[b.ln]=group end
        if b.tog then tabSet[b.tog]=group end
        if b.dot then tabSet[b.dot]=group end
        if b.track then tabSet[b.track]=group end
        if b.fill then tabSet[b.fill]=group end
        if b.handle then tabSet[b.handle]=group end
        if b.qbg then tabSet[b.qbg]=group end
        if b.qlb then tabSet[b.qlb]=group end
        if b.dlb then tabSet[b.dlb]=group end
        if b.arrow then tabSet[b.arrow]=group end
        if b.valLbl then tabSet[b.valLbl]=group end
        if b.inputBg then tabSet[b.inputBg]=group end
        if b.inputTx then tabSet[b.inputTx]=group end
        if b.swatches then for _,sw in ipairs(b.swatches) do tabSet[sw.sq]=group; tabSet[sw.border]=group end end
        if b.isDropdown then
            if b.panelBg then tabSet[b.panelBg]=group end
            if b.panelBorder then tabSet[b.panelBorder]=group end
            for _,o in ipairs(b.optBgs) do tabSet[o.bg]=group; tabSet[o.ln]=group; tabSet[o.lb]=group end
        end
        if b.isMultiDropdown then
            if b.panelBg then tabSet[b.panelBg]=group end
            if b.panelBorder then tabSet[b.panelBorder]=group end
            if b.headerBg then tabSet[b.headerBg]=group end
            if b.headerLn then tabSet[b.headerLn]=group end
            if b.selAllLbl then tabSet[b.selAllLbl]=group end
            if b.clearLbl then tabSet[b.clearLbl]=group end
            for _,o in ipairs(b.optBgs) do tabSet[o.bg]=group; tabSet[o.ln]=group; tabSet[o.lb]=group
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
            openDropdown=nil
        end
        prevTab=currentTab; currentTab=name; tabSwitchedAt=tick()
        for _,t in ipairs(tabObjs) do t.sel=t.name==name end
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
        recalculateLayout(name,"left"); recalculateLayout(name,"right")
        for _,b in ipairs(btns) do
            if b.tab==name then b.currentRY=b.ry; bPos(b); tagBtnFade(b,"next") end
        end
    end

    local function CONTENT_H() return uiCurrentH - L.CONTENT_TOP - L.FOOTER end

    recalculateLayout = function(tname, col)
        local key = tname.."_"..col
        local currentY = 6
        local lastHeaderY = 0
        for _, b in ipairs(btns) do
            if b.tab == tname and b.col == col then
                if b.isDiv then
                    b.ry = L.CONTENT_TOP + currentY; b.baseRY = b.ry
                    lastHeaderY = b.ry; bShow(b, true)
                    currentY = currentY + b.ch + 8
                else
                    local isCollapsed = b.section and _collapseSections[b.section]
                    if isCollapsed then
                        b._collapsing = true; b._collapseTarget = lastHeaderY + 14
                    else
                        b.ry = L.CONTENT_TOP + currentY; b.baseRY = b.ry
                        if b._collapsing then b._collapsing = false; b._collapseTarget = nil end
                        bShow(b, true); bPos(b)
                        currentY = currentY + b.ch + 6
                        if b.isDropdown and b.open then currentY = currentY + math.min(DROPDOWN_MAX_VISIBLE,#b.options)*b.ch end
                        if b.isMultiDropdown and b.open then currentY = currentY + (#b.options+1)*b.ch end
                    end
                end
            end
        end
        local lastY = 0
        for _, b in ipairs(btns) do
            if b.tab==tname and b.col==col and showSet[b.bg] then
                local bottom = b.ry + b.ch
                if bottom > lastY then lastY = bottom end
            end
        end
        tabRowY[key] = lastY + 30
        local newMax = math.max(0, (tabRowY[key] or 0) - L.CONTENT_TOP - CONTENT_H() + 8)
        tabScroll[key] = clamp(tabScroll[key] or 0, 0, newMax)
    end

    -- Component adders
    local function addToggle(tab,col,lbl,relY,init,cb,desc)
        local cw=L.COL_W; local ch=L.ROW_H-2; local ry=relY
        local ox=cw-L.TOG_W-8; local oy=ch/2-L.TOG_H/2
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local tog=mkD(mkSq(0,0,L.TOG_W,L.TOG_H,init and C.ON or C.OFF,true,1,4,nil,L.TOG_H))
        local dot=mkD(mkSq(0,0,L.TOG_H-4,L.TOG_H-4,init and C.ONDOT or C.OFFDOT,true,1,5,nil,L.TOG_H))
        local qbg, qlb
        if desc then
            qbg=mkD(mkSq(0,0,14,14,Color3.fromRGB(20,14,14),true,1,6,nil,3))
            qlb=mkD(mkTx("?",0,0,9,C.GRAY,true,7,true))
        end
        local b={tab=tab,col=col,isTog=true,state=init,bg=bg,lbl=lb,ln=dl,tog=tog,dot=dot,
                 outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,lt=init and 1 or 0,cb=cb,toggleName=lbl,
                 desc=desc,qbg=qbg,qlb=qlb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end

    local function addDiv(tab,col,lbl,relY,collapsible)
        local cw=L.COL_W; local ry=relY
        local lb=mkD(mkTx(lbl,0,0,9,C.GRAY,false,8))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local arrow
        if collapsible then
            arrow=mkD(mkTx("v",0,0,9,C.GRAY,false,8))
            if _collapseSections[lbl]==nil then _collapseSections[lbl]=false end
        end
        local db={tab=tab,col=col,isDiv=true,bg=lb,lbl=lb,ln=dl,rx=0,ry=ry,cw=cw,ch=14,
                  collapsible=collapsible,sectionName=lbl,arrow=arrow,currentRY=ry,baseRY=ry}
        table.insert(btns,db); return #btns
    end

    local function addSlider(tab,col,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local cw=L.COL_W; local ch=L.ROW_H+4; local ry=relY
        local trackW=cw-16
        local initLbl=isFloat and string.format("%.2f",initV) or math.floor(initV)
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local lb=mkD(mkTx(lbl..": "..initLbl,0,0,11,C.WHITE,false,8))
        local dlb=desc and mkD(mkTx(desc,0,0,9,C.GRAY,false,8)) or nil
        local trk=mkD(mkLn(0,0,0,0,C.DIMGRAY,5,3))
        local fil=mkD(mkLn(0,0,0,0,C.ACCENT,6,3))
        local hdl=mkD(mkSq(0,0,L.HDL,L.HDL,C.WHITE,true,1,7,nil,3))
        local b={tab=tab,col=col,isSlider=true,bg=bg,lbl=lb,ln=dl,track=trk,fill=fil,handle=hdl,
                 outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,trackW=trackW,
                 minV=minV,maxV=maxV,value=initV,baseLbl=lbl,dragging=false,cb=cb,
                 isFloat=isFloat or false,dlb=dlb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end

    local function addAct(tab,col,lbl,relY,bgCol,cb,lblCol)
        local cw=L.COL_W; local ch=L.ROW_H-2; local ry=relY
        local outBg=bgCol or C.ROWBG
        local outColor=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=mkD(mkSq(0,0,cw,ch,outColor,true,1,3,nil,4))
        local bg=mkD(mkSq(0,0,cw-2,ch-2,bgCol or C.ROWBG,true,1,4,nil,4))
        local lb=mkD(mkTx(lbl,0,0,11,lblCol or C.WHITE,true,8))
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5,1,4))
        local b={tab=tab,col=col,isAct=true,customCol=bgCol~=nil,out=out,bg=bg,lbl=lb,outGlow=outGlow,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,cb=cb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end

    local function addDropdown(tab,col,lbl,relY,options,initIdx,cb)
        local cw=L.COL_W; local ch=L.ROW_H-2; local ry=relY
        local outBg=C.ROWBG
        local outColor=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=mkD(mkSq(0,0,cw,ch,outColor,true,1,3,nil,4))
        local bg=mkD(mkSq(0,0,cw-2,ch-2,C.ROWBG,true,1,4,nil,4))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local valIdx=initIdx or 1
        local val=mkD(mkTx(options[valIdx] or "",0,0,10,C.ACCENT,false,8))
        local arrow=mkD(mkTx("v",0,0,9,C.GRAY,false,8))
        local panelBg=mkD(mkSq(0,0,1,1,Color3.fromRGB(14,10,10),true,0,9,nil,6))
        local panelBorder=mkD(mkSq(0,0,1,1,C.BORDER,false,0.6,9,1,6))
        panelBg.Visible=false; panelBorder.Visible=false
        local optBgs={}
        for i,opt in ipairs(options) do
            local obg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,0,10,nil,4))
            local oln=mkD(mkLn(0,0,0,0,C.DIV,11,1))
            local olb=mkD(mkTx(opt,0,0,10,i==valIdx and C.ACCENT or C.WHITE,false,11))
            obg.Visible=false; oln.Visible=false; olb.Visible=false
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,alpha=0,targetAlpha=0,hoverAlpha=0,targetHoverAlpha=0})
        end
        local b={tab=tab,col=col,isDropdown=true,out=out,bg=bg,lbl=lb,valLbl=val,arrow=arrow,
                 outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 panelBg=panelBg,panelBorder=panelBorder,optBgs=optBgs,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,options=options,
                 selected=valIdx,open=false,cb=cb,hoverAlpha=0,targetHoverAlpha=0,scrollOffset=0,highlightIdx=1}
        table.insert(btns,b); return #btns
    end

    local function addTextInput(tab,col,lbl,relY,default,inputW,cb)
        local cw=L.COL_W; local ch=L.ROW_H-2; local ry=relY
        inputW = inputW or 80
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local ibg=mkD(mkSq(0,0,inputW,18,C.DIMGRAY,true,1,5,nil,3))
        local itx=mkD(mkTx(tostring(default or ""),0,0,11,C.ACCENT,false,8))
        local b={tab=tab,col=col,isTextInput=true,bg=bg,lbl=lb,ln=dl,inputBg=ibg,inputTx=itx,
                 outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,inputW=inputW,
                 value=tostring(default or ""),cb=cb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end

    local function addColorPicker(tab,col,lbl,relY,initCol,cb)
        local cw=L.COL_W; local ch=L.ROW_H-2; local ry=relY
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3,nil,4))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local swatches={
            Color3.fromRGB(122,30,44),Color3.fromRGB(210,55,55),Color3.fromRGB(45,190,95),
            Color3.fromRGB(255,175,80),Color3.fromRGB(180,80,255),Color3.fromRGB(215,220,240),
        }
        local swatchBgs={}; local selected=1
        for i,sCol in ipairs(swatches) do
            local s=mkD(mkSq(0,0,14,14,sCol,true,1,6,nil,3))
            local border=mkD(mkSq(0,0,16,16,i==1 and C.WHITE or C.BORDER,false,1,7,1,3))
            table.insert(swatchBgs,{sq=s,border=border,col=sCol,x=0,y=0})
        end
        local b={tab=tab,col=col,isColorPicker=true,bg=bg,lbl=lb,ln=dl,
                 outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5,1,4)),
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,swatches=swatchBgs,
                 selected=selected,value=swatches[1],cb=cb,hoverAlpha=0,targetHoverAlpha=0}
        table.insert(btns,b); return #btns
    end

    -- Tab API builder
    local function getTabAPI(tabName, col)
        local key = tabName.."_"..col
        if tabAPI[key] then return tabAPI[key] end
        local api = {}
        tabRowY[key] = 6
        tabScroll[key] = 0
        local currentSection = nil
        local function nextY(h) local y=tabRowY[key]; tabRowY[key]=y+h; return L.CONTENT_TOP+y end

        function api:Div(lbl, collapsible)
            if collapsible==nil then collapsible=true end
            local idx=addDiv(tabName,col,lbl,nextY(20),collapsible)
            if collapsible then currentSection=lbl else currentSection=nil end
        end
        function api:Toggle(lbl, init, cb, desc)
            local y=nextY(L.ROW_H+2)
            local idx=addToggle(tabName,col,lbl,y,init,cb,desc)
            if currentSection then btns[idx].section=currentSection end
            local togApi={}
            function togApi:SetState(newState, skipCb)
                local b=btns[idx]; if not b then return end
                if b.state==newState then return end
                b.state=newState; b.lt=newState and 1 or 0
                if b.tog then b.tog.Color=newState and C.ON or C.OFF end
                if b.dot then b.dot.Color=newState and C.ONDOT or C.OFFDOT end
                if not skipCb and b.cb then pcall(b.cb,newState) end
            end
            return togApi
        end
        function api:Slider(lbl, minV, maxV, initV, cb, isFloat, desc)
            local y=nextY(L.ROW_H+8)
            local idx=addSlider(tabName,col,lbl,y,minV,maxV,initV,cb,isFloat,desc)
            if currentSection then btns[idx].section=currentSection end
        end
        function api:Button(lbl, bgCol, cb, lblCol)
            local y=nextY(L.ROW_H+2)
            local idx=addAct(tabName,col,lbl,y,bgCol,cb,lblCol)
            if currentSection then btns[idx].section=currentSection end
            return idx
        end
        function api:Dropdown(lbl, options, initIdx, cb)
            local y=nextY(L.ROW_H+2)
            local idx=addDropdown(tabName,col,lbl,y,options,initIdx,cb)
            if currentSection and btns[idx] then btns[idx].section=currentSection end
            local ddApi={}
            function ddApi:SetOptions(newOpts)
                local b=btns[idx]; if not b or b.open then return end
                local maxO=#b.optBgs; local trimmed={}
                for i=1,math.min(#newOpts,maxO) do trimmed[i]=newOpts[i] end
                b.options=trimmed
                for i=1,maxO do
                    if i<=#trimmed then b.optBgs[i].lb.Text=trimmed[i]; b.optBgs[i].lb.Color=(i==b.selected) and C.ACCENT or C.WHITE
                    else b.optBgs[i].lb.Text=""; setShow(b.optBgs[i].bg,false); setShow(b.optBgs[i].ln,false); setShow(b.optBgs[i].lb,false) end
                end
                if b.selected>#trimmed then b.selected=1 end
                b.valLbl.Text=b.options[b.selected] or ""
            end
            function ddApi:GetSelected() local b=btns[idx]; if not b then return 1,"" end; return b.selected, b.options[b.selected] or "" end
            return ddApi
        end
        function api:TextInput(lbl, default, inputW, cb)
            local y=nextY(L.ROW_H+2)
            local idx=addTextInput(tabName,col,lbl,y,default,inputW,cb)
            if currentSection then btns[idx].section=currentSection end
            local tiApi={}
            function tiApi:SetValue(v) local b=btns[idx]; if b then b.value=tostring(v); b.inputTx.Text=tostring(v) end end
            function tiApi:GetValue() local b=btns[idx]; return b and b.value or "" end
            return tiApi
        end
        function api:ColorPicker(lbl, initCol, cb)
            local y=nextY(L.ROW_H+2)
            local idx=addColorPicker(tabName,col,lbl,y,initCol,cb)
            if currentSection then btns[idx].section=currentSection end
        end
        tabAPI[key]=api; return api
    end

    -- Theme application
    local function applyTheme(name)
        local t=THEMES[name]; if not t then return end
        for k2,v2 in pairs(t) do C[k2]=v2 end
        -- Recolor base UI and all components
        for _,b in ipairs(btns) do
            if b.bg and not b.isDiv then b.bg.Color=C.ROWBG end
            if b.ln then b.ln.Color=C.DIV end
            if b.isTog then b.lbl.Color=C.WHITE; b.tog.Color=b.state and C.ON or C.OFF; b.dot.Color=b.state and C.ONDOT or C.OFFDOT end
            if b.isSlider then b.lbl.Color=C.WHITE; if b.track then b.track.Color=C.DIMGRAY end; if b.fill then b.fill.Color=C.ACCENT end end
            if b.isDiv then b.lbl.Color=C.GRAY; if b.arrow then b.arrow.Color=C.GRAY end end
            if b.isDropdown then b.lbl.Color=C.WHITE; b.valLbl.Color=C.ACCENT; b.arrow.Color=C.GRAY end
            if b.isTextInput then b.lbl.Color=C.WHITE; b.inputTx.Color=C.ACCENT; b.inputBg.Color=C.DIMGRAY end
        end
    end

    -- Base UI drawing variables
    local dShadow,dMainBg,dGlow1,dGlow2,dBorder
    local dTopBar,dTopLine,dTabBar,dTabLine
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dBtnMinimize,dBtnClose
    local dContent,dFooter,dFotLine
    local dScrollBgL,dScrollThumbL,dScrollBgR,dScrollThumbR
    local glowLines
    local dMiniShadow,dMiniBg,dMiniGlow1,dMiniGlow2,dMiniBorder
    local dMiniTopBar,dMiniTitleW,dMiniTitleA,dMiniKeyLbl,dMiniDivLn,dMiniActiveBg
    local miniGlowLines

    local function updatePos()
        local curH=uiCurrentH
        dShadow.Position=Vector2.new(uiX-2,uiY-2); dShadow.Size=Vector2.new(L.W+4,curH+4)
        dMainBg.Position=Vector2.new(uiX,uiY); dMainBg.Size=Vector2.new(L.W,curH)
        dBorder.Position=Vector2.new(uiX,uiY); dBorder.Size=Vector2.new(L.W,curH)
        dGlow1.Position=Vector2.new(uiX-1,uiY-1); dGlow1.Size=Vector2.new(L.W+2,curH+2)
        dGlow2.Position=Vector2.new(uiX-2,uiY-2); dGlow2.Size=Vector2.new(L.W+4,curH+4)
        dTopBar.Position=Vector2.new(uiX+1,uiY+1); dTopBar.Size=Vector2.new(L.W-2,L.TOPBAR)
        dTopLine.From=Vector2.new(uiX+1,uiY+L.TOPBAR); dTopLine.To=Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dTabBar.Position=Vector2.new(uiX+1,uiY+L.TOPBAR); dTabBar.Size=Vector2.new(L.W-2,L.TABBAR)
        dTabLine.From=Vector2.new(uiX+1,uiY+L.CONTENT_TOP); dTabLine.To=Vector2.new(uiX+L.W-1,uiY+L.CONTENT_TOP)
        dTitleW.Position=Vector2.new(uiX+14,uiY+8)
        local tw=#titleA*8
        dTitleA.Position=Vector2.new(uiX+14+tw+3,uiY+8)
        local ta=#titleB*8
        dTitleG.Position=Vector2.new(uiX+14+tw+3+ta+10,uiY+8)
        dBtnMinimize.Position=Vector2.new(uiX+L.W-42,uiY+15)
        dBtnClose.Position=Vector2.new(uiX+L.W-28,uiY+15)
        dKeyLbl.Position=Vector2.new(uiX+L.W-16,uiY+10)
        dContent.Position=Vector2.new(uiX+1,uiY+L.CONTENT_TOP); dContent.Size=Vector2.new(L.W-2,curH-L.CONTENT_TOP-L.FOOTER-1)
        dFooter.Position=Vector2.new(uiX+1,uiY+curH-L.FOOTER); dFooter.Size=Vector2.new(L.W-2,L.FOOTER-1)
        dFotLine.From=Vector2.new(uiX+1,uiY+curH-L.FOOTER); dFotLine.To=Vector2.new(uiX+L.W-1,uiY+curH-L.FOOTER)
        -- Tab label positions
        local tabStartX=uiX+12
        for _,t in ipairs(tabObjs) do
            t.lbl.Position=Vector2.new(tabStartX,uiY+L.TOPBAR+7)
            t.lblG.Position=Vector2.new(tabStartX,uiY+L.TOPBAR+7)
            t.underline.From=Vector2.new(tabStartX,uiY+L.CONTENT_TOP-1)
            t.underline.To=Vector2.new(tabStartX+t.tw,uiY+L.CONTENT_TOP-1)
            tabStartX=tabStartX+t.tw+16
        end
        for _,b in ipairs(btns) do if showSet[b.bg] then bPos(b) end end
    end

    local function applyFade()
        if minimized then
            for _,d in ipairs(allDrawings) do d.Visible=false end; return
        end
        local mf=1-(menuToggledAt-(tick()-FADE_DUR))/FADE_DUR
        if not menuOpen and mf>=1.1 then
            for _,d in ipairs(allDrawings) do d.Visible=false end; return
        end
        local mOp=mf<1.1 and math.abs((menuOpen and 0 or 1)-clamp(mf,0,1)) or (menuOpen and 1 or 0)
        local tp=clamp((tick()-tabSwitchedAt)/TAB_FADE_DUR,0,1)
        for _,d in ipairs(allDrawings) do
            if showSet[d] then
                local tOp=tabSet[d]=="next" and tp or tabSet[d]=="prev" and (1-tp) or 1
                local op=mOp*tOp; d.Visible=op>0.01; d.Transparency=op
            else d.Visible=false end
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
    end

    local function refreshMiniLabels()
        local active={}
        for _,b in ipairs(btns) do if b.isTog and b.state then table.insert(active,b.toggleName) end end
        if #active==0 then
            miniActiveLbls[1].Text="no active toggles"; miniActiveLbls[1].Visible=true
            for i=2,MAX_MINI_LBLS do miniActiveLbls[i].Text=""; miniActiveLbls[i].Visible=false end; return
        end
        local curX=uiX+10; local row=1
        local slots={}
        for _,name in ipairs(active) do
            local w=#name*7
            if curX+w>uiX+L.W-10 then if row==1 then row=2; curX=uiX+10 else break end end
            table.insert(slots,{name=name,x=curX,y=uiY+L.TOPBAR+6+(row-1)*18}); curX=curX+w+14
        end
        for i,lb in ipairs(miniActiveLbls) do
            if slots[i] then lb.Text=slots[i].name; lb.Position=Vector2.new(slots[i].x,slots[i].y); lb.Visible=true
            else lb.Text=""; lb.Visible=false end
        end
    end

    local function updateMiniPos()
        dMiniShadow.Position=Vector2.new(uiX-2,uiY-2); dMiniShadow.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBg.Position=Vector2.new(uiX,uiY); dMiniBg.Size=Vector2.new(L.W,L.MINI_H)
        dMiniGlow1.Position=Vector2.new(uiX-1,uiY-1); dMiniGlow1.Size=Vector2.new(L.W+2,L.MINI_H+2)
        dMiniGlow2.Position=Vector2.new(uiX-2,uiY-2); dMiniGlow2.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBorder.Position=Vector2.new(uiX,uiY); dMiniBorder.Size=Vector2.new(L.W,L.MINI_H)
        dMiniTopBar.Position=Vector2.new(uiX+1,uiY+1)
        dMiniTitleW.Position=Vector2.new(uiX+14,uiY+8)
        local mtw=#titleA*8
        dMiniTitleA.Position=Vector2.new(uiX+14+mtw+3,uiY+8)
        dMiniKeyLbl.Position=Vector2.new(uiX+L.W-16,uiY+10)
        dMiniDivLn.From=Vector2.new(uiX+1,uiY+L.TOPBAR); dMiniDivLn.To=Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dMiniActiveBg.Position=Vector2.new(uiX+1,uiY+L.TOPBAR); dMiniActiveBg.Size=Vector2.new(L.W-2,L.MINI_H-L.TOPBAR-1)
        refreshMiniLabels()
    end

    local function restoreFullMenu()
        minimized=false; miniClosed=false
        showMiniUI(false)
        for _,d in ipairs(allDrawings) do d.Visible=false; tabSet[d]=nil end
        for _,d in ipairs(baseUI) do setShow(d,true) end
        for _,t in ipairs(tabObjs) do
            setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel); setShow(t.underline,t.sel)
        end
        menuOpen=true; menuToggledAt=tick()-FADE_DUR-0.01
        uiCurrentH=L.H; showTab(currentTab); updatePos()
    end

    function win:Init(defaultTab, charLabelFn, notifFn)
        local notif = notifFn or function(msg,title,dur) pcall(function() notify(msg, title or titleA.." "..titleB, dur or 3) end) end
        dShadow=mkD(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,C.SHADOW,true,0.5,0,nil,10))
        dMainBg=mkD(mkSq(uiX,uiY,L.W,L.H,C.BG,true,1,1,nil,8))
        dGlow1=mkD(mkSq(uiX-1,uiY-1,L.W+2,L.H+2,C.ACCENT,false,0.8,1,1,9))
        dGlow2=mkD(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,C.ACCENT,false,0.3,0,2,10))
        glowLines={dGlow1,dGlow2}
        dBorder=mkD(mkSq(uiX,uiY,L.W,L.H,C.BORDER,false,0.2,3,1,8))
        dTopBar=mkD(mkSq(uiX+1,uiY+1,L.W-2,L.TOPBAR,C.TOPBAR,true,1,3,nil,7))
        dTopLine=mkD(mkLn(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4,1))
        dTabBar=mkD(mkSq(uiX+1,uiY+L.TOPBAR,L.W-2,L.TABBAR,C.SIDEBAR,true,1,2))
        dTabLine=mkD(mkLn(uiX+1,uiY+L.CONTENT_TOP,uiX+L.W-1,uiY+L.CONTENT_TOP,C.BORDER,4,1))
        dTitleW=mkD(mkTx(titleA,uiX+14,uiY+8,14,C.WHITE,false,9,true))
        dTitleA=mkD(mkTx(titleB,uiX+60,uiY+8,14,C.ACCENT,false,9,true))
        local gameNameShort = gameName or ""
        dTitleG=mkD(mkTx(gameNameShort,uiX+120,uiY+8,12,C.ORANGE,false,9,false))
        if gameNameShort=="" or gameNameShort=="Game Name" then
            dTitleG.Text=""
            task.spawn(function() pcall(function()
                local gn; if type(getgamename)=="function" then gn=getgamename()
                else local info=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId); gn=info and info.Name end
                if gn then dTitleG.Text=gn end
            end) end)
        end
        dBtnMinimize=Drawing.new("Circle")
        dBtnMinimize.Radius=4; dBtnMinimize.Color=Color3.fromRGB(230,180,50); dBtnMinimize.Filled=true
        dBtnMinimize.Transparency=1; dBtnMinimize.ZIndex=10; dBtnMinimize.Visible=false
        dBtnMinimize.Position=Vector2.new(uiX+L.W-42,uiY+15); table.insert(allDrawings,dBtnMinimize)
        dBtnClose=Drawing.new("Circle")
        dBtnClose.Radius=4; dBtnClose.Color=Color3.fromRGB(200,60,60); dBtnClose.Filled=true
        dBtnClose.Transparency=1; dBtnClose.ZIndex=10; dBtnClose.Visible=false
        dBtnClose.Position=Vector2.new(uiX+L.W-28,uiY+15); table.insert(allDrawings,dBtnClose)
        dKeyLbl=mkD(mkTx("f1",uiX+L.W-16,uiY+10,10,C.GRAY,false,9))
        dContent=mkD(mkSq(uiX+1,uiY+L.CONTENT_TOP,L.W-2,L.CONTENT_H,C.CONTENT,true,1,2,nil,6))
        dFooter=mkD(mkSq(uiX+1,uiY+L.H-L.FOOTER,L.W-2,L.FOOTER-1,C.TOPBAR,true,1,3,nil,5))
        dFotLine=mkD(mkLn(uiX+1,uiY+L.H-L.FOOTER,uiX+L.W-1,uiY+L.H-L.FOOTER,C.BORDER,4,1))
        local uname=game:GetService("Players").LocalPlayer.Name
        dWelcomeTxt=mkD(mkTx("welcome, ",0,0,11,C.GRAY,false,5,false))
        dNameTxt=mkD(mkTx(uname,0,0,11,C.WHITE,false,5,true))
        dScrollBgL=mkSq(uiX+L.ROW_PAD+L.COL_W-2,uiY+L.CONTENT_TOP+2,3,L.CONTENT_H-4,Color3.fromRGB(18,14,14),true,0.5,4,nil,2)
        dScrollBgL.Visible=false
        dScrollThumbL=mkSq(0,0,3,20,C.ACCENT,true,1,5,nil,2); dScrollThumbL.Visible=false
        dScrollBgR=mkSq(uiX+L.W-L.ROW_PAD,uiY+L.CONTENT_TOP+2,3,L.CONTENT_H-4,Color3.fromRGB(18,14,14),true,0.5,4,nil,2)
        dScrollBgR.Visible=false
        dScrollThumbR=mkSq(0,0,3,20,C.ACCENT,true,1,5,nil,2); dScrollThumbR.Visible=false
        tipBg=mkSq(0,0,10,10,Color3.fromRGB(14,10,10),true,1,12,nil,4); tipBg.Visible=false
        tipBorder=mkSq(0,0,10,10,C.ACCENT,false,0.7,12,1,4); tipBorder.Visible=false
        tipLbl=mkTx("",0,0,11,C.ACCENT,false,13,true); tipLbl.Visible=false
        tipDesc=mkTx("",0,0,10,C.GRAY,false,13,false); tipDesc.Visible=false
        baseUI={dShadow,dGlow2,dGlow1,dMainBg,dBorder,dTopBar,dTopLine,dTabBar,dTabLine,
                dTitleW,dTitleA,dTitleG,dBtnMinimize,dBtnClose,dKeyLbl,dContent,dFooter,dFotLine,dWelcomeTxt,dNameTxt}
        -- Create horizontal tab labels
        local tabStartX=uiX+12
        for i,name in ipairs(win._tabOrder) do
            local isSel=name==defaultTab
            local tw=#name*7
            local tlW=mkD(mkTx(name,tabStartX,uiY+L.TOPBAR+7,10,C.WHITE,false,8,true))
            local tlG=mkD(mkTx(name,tabStartX,uiY+L.TOPBAR+7,10,C.GRAY,false,8))
            local ul=mkD(mkLn(tabStartX,uiY+L.CONTENT_TOP-1,tabStartX+tw,uiY+L.CONTENT_TOP-1,C.ACCENT,5,2))
            setShow(tlW,false); setShow(tlG,false); setShow(ul,false)
            table.insert(tabObjs,{lbl=tlW,lblG=tlG,underline=ul,name=name,sel=isSel,tw=tw,tabX=tabStartX})
            tabStartX=tabStartX+tw+16
        end
        -- Minibar
        dMiniShadow=mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,C.SHADOW,true,0.5,0,nil,10)
        dMiniBg=mkSq(uiX,uiY,L.W,L.MINI_H,C.BG,true,1,1,nil,8)
        dMiniGlow1=mkSq(uiX-1,uiY-1,L.W+2,L.MINI_H+2,C.ACCENT,false,0.8,1,1,9)
        dMiniGlow2=mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,C.ACCENT,false,0.3,0,2,10)
        miniGlowLines={dMiniGlow1,dMiniGlow2}
        dMiniBorder=mkSq(uiX,uiY,L.W,L.MINI_H,C.BORDER,false,0.2,3,1,8)
        dMiniTopBar=mkSq(uiX+1,uiY+1,L.W-2,L.TOPBAR,C.TOPBAR,true,1,3,nil,7)
        dMiniTitleW=mkTx(titleA,uiX+14,uiY+8,14,C.WHITE,false,9,true)
        dMiniTitleA=mkTx(titleB,uiX+60,uiY+8,14,C.ACCENT,false,9,true)
        dMiniKeyLbl=mkTx("f1",uiX+L.W-16,uiY+10,10,C.GRAY,false,9)
        dMiniDivLn=mkLn(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4,1)
        dMiniActiveBg=mkSq(uiX+1,uiY+L.TOPBAR,L.W-2,L.MINI_H-L.TOPBAR-1,C.MINIBAR,true,1,2,nil,6)
        miniDrawings={dMiniShadow,dMiniBg,dMiniGlow2,dMiniGlow1,dMiniBorder,dMiniTopBar,dMiniTitleW,dMiniTitleA,dMiniKeyLbl,dMiniDivLn,dMiniActiveBg}
        for _,d in ipairs(miniDrawings) do d.Visible=false end
        currentTab=defaultTab
        notif("Loaded on "..(gameName or ""),"check it v2",4)
        -- Show base UI immediately (no loading screen)
        for _,d in ipairs(baseUI) do setShow(d,true) end
        for _,t in ipairs(tabObjs) do setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel); setShow(t.underline,t.sel) end
        showTab(currentTab)
        updatePos()

        -- Main update loop
        task.spawn(function()
        while not destroyed do
            task.wait(0.016)
            local clicking = false
            pcall(function() clicking = ismouse1pressed() end)
            local keyDown = false
            pcall(function() keyDown = iskeypressed(menuKey) end)
            if keyDown and not wasMenuKey then
                if miniClosed then miniClosed=false; refreshMiniLabels(); showMiniUI(true); updateMiniPos()
                elseif minimized then showMiniUI(false); miniClosed=true; for _,d in ipairs(allDrawings) do d.Visible=false end
                else menuOpen=not menuOpen; menuToggledAt=tick(); pcall(function() setrobloxinput(not menuOpen) end) end
            end
            wasMenuKey=keyDown
            -- Minibar interaction
            if minimized and not miniClosed then
                local t=tick()*1.0
                for i,sq in ipairs(miniGlowLines) do
                    local p=t+glowPhase[i]; sq.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
                    sq.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                local pt=tick()*0.8
                for i,lb in ipairs(miniActiveLbls) do
                    if lb.Text~="" then lb.Visible=true; lb.Color=lerpC(C.ACCENT,C.WHITE,(math.sin(pt+miniActivePulse[i])+1)/2)
                    else lb.Visible=false end
                end
                if clicking and not wasClicking then
                    if inBox(uiX,uiY,L.W,L.TOPBAR) then
                        local rcDist=math.sqrt((mouse.X-(uiX+L.W-28))^2+(mouse.Y-(uiY+15))^2)
                        local ymDist=math.sqrt((mouse.X-(uiX+L.W-42))^2+(mouse.Y-(uiY+15))^2)
                        if rcDist<=6 then miniClosed=true; showMiniUI(false)
                        elseif ymDist<=6 then restoreFullMenu()
                        else miniDragging=true; miniDragOffX=mouse.X-uiX; miniDragOffY=mouse.Y-uiY end
                    end
                end
                if not clicking then miniDragging=false end
                if miniDragging and clicking then
                    local vpW,vpH=getViewport()
                    uiX=clamp(mouse.X-miniDragOffX,0,vpW-L.W); uiY=clamp(mouse.Y-miniDragOffY,0,vpH-L.MINI_H)
                    updateMiniPos()
                end
                wasClicking=clicking
            end
            -- Full UI logic
            if not minimized then
                for _,lb in ipairs(miniActiveLbls) do lb.Visible=false end
                -- Glow animation
                local t=tick()*1.0
                for i,sq in ipairs(glowLines) do
                    local p=t+glowPhase[i]; sq.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
                    sq.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                if dTitleW and dTitleA then
                    local tf=(math.sin(t*2)+1)/2; dTitleA.Color=lerpC(C.ACCENT,C.WHITE,tf)
                end
                -- Toggle animation
                for _,b in ipairs(btns) do
                    if b.isTog and b.tog and b.tab==currentTab then
                        local tgt=b.state and 1 or 0; b.lt=b.lt+(tgt-b.lt)*0.18
                        b.tog.Color=lerpC(C.OFF,C.ON,b.lt); b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.lt)
                        if showSet[b.bg] then bPos(b) end
                    end
                end
                -- Hover effects
                for _,b in ipairs(btns) do
                    if menuOpen and not minimized and b.tab==currentTab and showSet[b.bg] and not b.isDiv then
                        local sc=tabScroll[b.tab.."_"..b.col] or 0
                        local colOff=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                        local itemY=uiY+(b.currentRY or b.ry)-sc
                        if inBox(uiX+colOff,itemY,b.cw,b.ch) then
                            b.targetHoverAlpha=1
                            if not b.isAct or not b.customCol then b.bg.Color=lerpC(C.ROWBG,C.WHITE,0.06) end
                        else
                            b.targetHoverAlpha=0
                            if not b.isAct or not b.customCol then b.bg.Color=C.ROWBG end
                        end
                    end
                    if b.outGlow then
                        local diff=(b.targetHoverAlpha or 0)-(b.hoverAlpha or 0)
                        if math.abs(diff)>0.01 then
                            b.hoverAlpha=(b.hoverAlpha or 0)+diff*0.18
                            b.outGlow.Transparency=(b.hoverAlpha or 0)*dMainBg.Transparency
                            b.outGlow.Visible=((b.hoverAlpha or 0)>0.02)
                        elseif b.targetHoverAlpha==0 and (b.hoverAlpha or 0)>0 then
                            b.hoverAlpha=0; b.outGlow.Transparency=0; b.outGlow.Visible=false
                        end
                    end
                end
                -- Apply fade + position
                applyFade()
                -- Footer position
                if dWelcomeTxt and dNameTxt then
                    local wX=uiX+14; local tY=uiY+uiCurrentH-L.FOOTER+7
                    dWelcomeTxt.Position=Vector2.new(wX,tY); dWelcomeTxt.Visible=menuOpen
                    dNameTxt.Position=Vector2.new(wX+60,tY); dNameTxt.Visible=menuOpen
                end
                -- Smooth layout animation
                for _,b in ipairs(btns) do
                    if b.currentRY and b.tab==currentTab then
                        if b._collapsing and b._collapseTarget then
                            local diff=b._collapseTarget-b.currentRY
                            if math.abs(diff)>0.5 then b.currentRY=b.currentRY+diff*0.18; bPos(b)
                            else b.currentRY=b._collapseTarget; b._collapsing=false; b._collapseTarget=nil; bShow(b,false) end
                        else
                            local diff=b.ry-b.currentRY
                            if math.abs(diff)>0.3 then b.currentRY=b.currentRY+diff*0.15; if showSet[b.bg] then bPos(b) end
                            elseif b.currentRY~=b.ry then b.currentRY=b.ry; if showSet[b.bg] then bPos(b) end end
                        end
                    end
                end
                -- Content clipping
                local contentBottom=uiY+uiCurrentH-L.FOOTER; local contentTop=uiY+L.CONTENT_TOP
                for _,b in ipairs(btns) do
                    if b.tab==currentTab then
                        local sc=tabScroll[b.tab.."_"..b.col] or 0
                        local itemY=uiY+(b.currentRY or b.ry)-sc
                        local isCollapsed=b.section and _collapseSections[b.section]
                        if itemY+b.ch>contentBottom or itemY<contentTop or isCollapsed then
                            if showSet[b.bg] then bShow(b,false) end
                        else
                            if not showSet[b.bg] then bShow(b,true) end
                            if showSet[b.bg] then bPos(b) end
                        end
                    end
                end
                -- Prev tab cleanup
                if prevTab and (tick()-tabSwitchedAt)>=TAB_FADE_DUR then
                    for _,b in ipairs(btns) do if b.tab==prevTab then bShow(b,false) end end
                    for _,d in ipairs(allDrawings) do if tabSet[d]=="prev" then tabSet[d]=nil end end
                    prevTab=nil
                end
                -- Click handling
                local handleDrag=false
                local mfn=1-(menuToggledAt-(tick()-FADE_DUR))/FADE_DUR
                local mOp=math.abs((menuOpen and 0 or 1)-clamp(mfn,0,1))
                if clicking and not wasClicking and mOp>0.5 then
                    if inBox(uiX,uiY,L.W,uiCurrentH) then handleDrag=true end
                    -- Minimize / Close
                    local ymDist=math.sqrt((mouse.X-(uiX+L.W-42))^2+(mouse.Y-(uiY+15))^2)
                    local rcDist=math.sqrt((mouse.X-(uiX+L.W-28))^2+(mouse.Y-(uiY+15))^2)
                    if ymDist<=6 then
                        handleDrag=false; minimized=true; miniClosed=false; menuOpen=false
                        pcall(function() setrobloxinput(true) end)
                        for _,d in ipairs(allDrawings) do d.Visible=false end
                        refreshMiniLabels(); showMiniUI(true); updateMiniPos()
                    elseif rcDist<=6 then handleDrag=false; menuOpen=false; menuToggledAt=tick() end
                    -- Tab clicks
                    for _,tObj in ipairs(tabObjs) do
                        if inBox(tObj.tabX,uiY+L.TOPBAR,tObj.tw,L.TABBAR) then
                            handleDrag=false; switchTab(tObj.name)
                            for _,t2 in ipairs(tabObjs) do
                                setShow(t2.lbl,t2.sel); setShow(t2.lblG,not t2.sel); setShow(t2.underline,t2.sel)
                            end
                        end
                    end
                    -- Dropdown option clicks
                    if openDropdown then
                        local bd=openDropdown; local scrollOff=bd.scrollOffset or 0
                        local sc2=tabScroll[bd.tab.."_"..bd.col] or 0
                        local colOff2=bd.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                        local baseAx=uiX+colOff2; local baseAy=uiY+(bd.currentRY or bd.ry)-sc2+bd.ch
                        local optConsumed=false
                        for vi=1,math.min(DROPDOWN_MAX_VISIBLE,#bd.options) do
                            local i=scrollOff+vi; if i>#bd.optBgs then break end
                            local oy=baseAy+(vi-1)*bd.ch
                            if inBox(baseAx,oy,bd.cw,bd.ch) then
                                optConsumed=true; handleDrag=false; bd.selected=i; bd.valLbl.Text=bd.options[i]
                                for j,o2 in ipairs(bd.optBgs) do o2.lb.Color=j==i and C.ACCENT or C.WHITE; o2.targetAlpha=0 end
                                bd.open=false; bd.arrow.Text="v"; openDropdown=nil
                                recalculateLayout(currentTab,"left"); recalculateLayout(currentTab,"right")
                                if bd.cb then bd.cb(bd.options[i],i) end; break
                            end
                        end
                        if not optConsumed and not inBox(baseAx,uiY+(bd.currentRY or bd.ry)-sc2,bd.cw,bd.ch) then
                            bd.open=false; bd.arrow.Text="v"; openDropdown=nil
                            recalculateLayout(currentTab,"left"); recalculateLayout(currentTab,"right")
                        end
                    end
                    -- Component clicks
                    for _,b in ipairs(btns) do
                        if b.tab==currentTab and showSet[b.bg] and not b.isSlider then
                            local sc3=tabScroll[b.tab.."_"..b.col] or 0
                            local colOff3=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                            local itemY2=uiY+(b.currentRY or b.ry)-sc3
                            if inBox(uiX+colOff3,itemY2,b.cw,b.ch) then
                                handleDrag=false
                                if b.isTog then
                                    b.state=not b.state; if b.cb then b.cb(b.state) end
                                    notif(b.toggleName.." "..(b.state and "enabled" or "disabled"),nil,2)
                                    refreshMiniLabels()
                                elseif b.isAct then
                                    if iKeyBind and b==btns[iKeyBind] and not listenKey then listenKey=true; btns[iKeyBind].lbl.Text="Press any key..."
                                    elseif b.cb then b.cb() end
                                elseif b.isDropdown then
                                    if openDropdown and openDropdown~=b then
                                        openDropdown.open=false; openDropdown.arrow.Text="v"; openDropdown=nil
                                    end
                                    b.open=not b.open; b.arrow.Text=b.open and "^" or "v"
                                    if b.open then b.scrollOffset=0; openDropdown=b
                                        for _,o in ipairs(b.optBgs) do o.targetAlpha=1; setShow(o.bg,true); setShow(o.ln,true); setShow(o.lb,true) end
                                    else openDropdown=nil end
                                    recalculateLayout(currentTab,"left"); recalculateLayout(currentTab,"right")
                                elseif b.isColorPicker then
                                    local colOff4=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                                    local ax2=uiX+colOff4
                                    local totalW2=(#b.swatches*19)-5; local startX2=ax2+b.cw-totalW2-10
                                    for j,sw in ipairs(b.swatches) do
                                        local sx=startX2+(j-1)*19; local sy=itemY2+b.ch/2-7
                                        if inBox(sx,sy,14,14) then
                                            b.selected=j; b.value=sw.col
                                            for k2,sw2 in ipairs(b.swatches) do sw2.border.Color=k2==j and C.WHITE or C.BORDER end
                                            if b.cb then b.cb(sw.col) end; break
                                        end
                                    end
                                elseif b.isDiv and b.collapsible and b.sectionName then
                                    _collapseSections[b.sectionName]=not _collapseSections[b.sectionName]
                                    if b.arrow then b.arrow.Text=_collapseSections[b.sectionName] and ">" or "v" end
                                    recalculateLayout(currentTab,"left"); recalculateLayout(currentTab,"right"); break
                                end
                            end
                        end
                    end
                end
                -- Slider dragging
                for _,b in ipairs(btns) do
                    if b.isSlider and b.tab==currentTab and menuOpen then
                        local sc4=tabScroll[b.tab.."_"..b.col] or 0
                        local colOff5=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                        local ax3=uiX+colOff5+8; local itemY3=uiY+(b.currentRY or b.ry)-sc4
                        if clicking and not wasClicking and inBox(uiX+colOff5,itemY3,b.cw,b.ch) and b.bg.Visible then
                            handleDrag=false; b.dragging=true
                        end
                        if not clicking and b.dragging then
                            local disp=b.isFloat and string.format("%.2f",b.value) or math.floor(b.value)
                            notif(b.baseLbl..": "..disp,nil,2)
                        end
                        if not clicking then b.dragging=false end
                        if b.dragging and clicking then
                            local frac=clamp((mouse.X-ax3)/b.trackW,0,1)
                            b.value=b.minV+frac*(b.maxV-b.minV)
                            local disp=b.isFloat and string.format("%.2f",b.value) or math.floor(b.value)
                            b.lbl.Text=b.baseLbl..": "..disp
                            if b.cb then b.cb(b.value) end
                            bPos(b)
                        end
                    end
                end
                -- Scroll handling
                if _scrollDelta~=0 and menuOpen then
                    local inLeft=inBox(uiX+L.ROW_PAD,uiY+L.CONTENT_TOP,L.COL_W,CONTENT_H())
                    local inRight=inBox(uiX+L.ROW_PAD+L.COL_W+L.COL_GAP,uiY+L.CONTENT_TOP,L.COL_W,CONTENT_H())
                    local scrollCol=inLeft and "left" or inRight and "right" or nil
                    if scrollCol then
                        local key=currentTab.."_"..scrollCol
                        local maxSc=math.max(0,(tabRowY[key] or 0)-L.CONTENT_TOP-CONTENT_H()+8)
                        tabScroll[key]=clamp((tabScroll[key] or 0)-_scrollDelta*28,0,maxSc)
                    end
                    _scrollDelta=0
                end
                -- Dragging
                if clicking and not wasClicking and mOp>0.5 and handleDrag then
                    dragging=true; dragOffX=mouse.X-uiX; dragOffY=mouse.Y-uiY
                end
                if not clicking then dragging=false end
                if dragging and clicking then
                    local vpW,vpH=getViewport()
                    uiX=clamp(mouse.X-dragOffX,0,vpW-L.W); uiY=clamp(mouse.Y-dragOffY,0,vpH-uiCurrentH)
                    updatePos()
                end
                wasClicking=clicking
                -- Key rebinding
                if listenKey then
                    for k=0x08,0xDD do
                        local pressed=false; pcall(function() pressed=iskeypressed(k) end)
                        if pressed and k~=0x01 and k~=0x02 then
                            menuKey=k; local n=kname(k)
                            if iKeyInfo then btns[iKeyInfo].lbl.Text="Menu Key: "..n end
                            if iKeyBind then btns[iKeyBind].lbl.Text="Click to Rebind" end
                            dKeyLbl.Text=n; dMiniKeyLbl.Text=n; listenKey=false; break
                        end
                    end
                end
                -- Char label
                if charLabelFn then
                    local nt=charLabelFn()
                    -- Show info in footer right side
                end
            end
        end
        end)
    end

    win._tabOrder = {}
    function win:Tab(name)
        table.insert(win._tabOrder, name)
        local left = getTabAPI(name, "left")
        local right = getTabAPI(name, "right")
        return {Left=left, Right=right, left=left, right=right,
            Div=function(s,...) left:Div(...) end,
            Toggle=function(s,...) return left:Toggle(...) end,
            Slider=function(s,...) left:Slider(...) end,
            Button=function(s,...) return left:Button(...) end,
            Dropdown=function(s,...) return left:Dropdown(...) end,
            TextInput=function(s,...) return left:TextInput(...) end,
            ColorPicker=function(s,...) left:ColorPicker(...) end,
        }
    end

    function win:SettingsTab(destroyCb)
        local s = self:Tab("settings")
        s.Left:Div("UI")
        s.Left:Dropdown("Theme", {"Crimson","Dark","Moon","Grass","Light"}, 1, function(val)
            win:ApplyTheme(val)
        end)
        s.Left:Div("KEYBIND")
        iKeyInfo = s.Left:Button("Menu Key: F1", C.ROWBG)
        iKeyBind = s.Left:Button("Click to Rebind", Color3.fromRGB(20,14,14))
        s.Right:Div("DANGER")
        s.Right:Button("Destroy Menu", Color3.fromRGB(40,10,10), destroyCb, C.RED)
        return s
    end

    function win:Destroy()
        destroyed=true
        pcall(function() notify("UI destroyed.", titleA.." "..titleB, 3) end)
        for _,d in ipairs(allDrawings) do pcall(function() d:Remove() end) end
        for _,d in ipairs(glowLines or {}) do pcall(function() d:Remove() end) end
        if dScrollBgL then pcall(function() dScrollBgL:Remove() end) end
        if dScrollThumbL then pcall(function() dScrollThumbL:Remove() end) end
        if dScrollBgR then pcall(function() dScrollBgR:Remove() end) end
        if dScrollThumbR then pcall(function() dScrollThumbR:Remove() end) end
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
