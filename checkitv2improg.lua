-- Check it UI Library v2.0
-- Rewritten for brevity, clarity, and crash safety
local UILib = {}
local _sections = {}

-- ── THEMES ──────────────────────────────────────────────────────────────────
local THEMES = {
    ["Check it"] = {
        ACCENT=Color3.fromRGB(70,120,255),  BG=Color3.fromRGB(9,11,20),
        SIDEBAR=Color3.fromRGB(12,15,27),   CONTENT=Color3.fromRGB(11,13,23),
        TOPBAR=Color3.fromRGB(7,9,17),      BORDER=Color3.fromRGB(30,40,72),
        ROWBG=Color3.fromRGB(14,18,33),     TABSEL=Color3.fromRGB(20,35,85),
        WHITE=Color3.fromRGB(215,220,240),  GRAY=Color3.fromRGB(100,112,145),
        DIMGRAY=Color3.fromRGB(28,33,52),   ON=Color3.fromRGB(45,85,195),
        OFF=Color3.fromRGB(20,24,42),       ONDOT=Color3.fromRGB(175,198,255),
        OFFDOT=Color3.fromRGB(55,65,95),    DIV=Color3.fromRGB(22,27,48),
        MINIBAR=Color3.fromRGB(11,13,22),
    },
    ["Moon"] = {
        ACCENT=Color3.fromRGB(150,150,165),  BG=Color3.fromRGB(12,12,14),
        SIDEBAR=Color3.fromRGB(16,16,18),    CONTENT=Color3.fromRGB(14,14,16),
        TOPBAR=Color3.fromRGB(10,10,12),     BORDER=Color3.fromRGB(40,40,46),
        ROWBG=Color3.fromRGB(18,18,22),      TABSEL=Color3.fromRGB(30,30,36),
        WHITE=Color3.fromRGB(220,220,225),   GRAY=Color3.fromRGB(120,120,130),
        DIMGRAY=Color3.fromRGB(40,40,45),    ON=Color3.fromRGB(100,100,115),
        OFF=Color3.fromRGB(25,25,30),        ONDOT=Color3.fromRGB(200,200,215),
        OFFDOT=Color3.fromRGB(70,70,80),     DIV=Color3.fromRGB(30,30,36),
        MINIBAR=Color3.fromRGB(16,16,20),
    },
    ["Grass"] = {
        ACCENT=Color3.fromRGB(60,200,100),  BG=Color3.fromRGB(8,14,10),
        SIDEBAR=Color3.fromRGB(10,18,13),   CONTENT=Color3.fromRGB(9,16,11),
        TOPBAR=Color3.fromRGB(6,11,8),      BORDER=Color3.fromRGB(25,55,35),
        ROWBG=Color3.fromRGB(11,20,14),     TABSEL=Color3.fromRGB(18,45,25),
        WHITE=Color3.fromRGB(200,235,210),  GRAY=Color3.fromRGB(90,130,105),
        DIMGRAY=Color3.fromRGB(20,40,28),   ON=Color3.fromRGB(30,140,65),
        OFF=Color3.fromRGB(15,30,20),       ONDOT=Color3.fromRGB(150,240,180),
        OFFDOT=Color3.fromRGB(45,80,58),    DIV=Color3.fromRGB(18,35,24),
        MINIBAR=Color3.fromRGB(10,18,13),
    },
    ["Light"] = {
        ACCENT=Color3.fromRGB(50,100,255),  BG=Color3.fromRGB(230,233,245),
        SIDEBAR=Color3.fromRGB(215,220,235),CONTENT=Color3.fromRGB(220,224,238),
        TOPBAR=Color3.fromRGB(200,205,225), BORDER=Color3.fromRGB(170,178,210),
        ROWBG=Color3.fromRGB(210,214,230),  TABSEL=Color3.fromRGB(190,205,240),
        WHITE=Color3.fromRGB(25,30,60),     GRAY=Color3.fromRGB(90,100,140),
        DIMGRAY=Color3.fromRGB(180,185,210),ON=Color3.fromRGB(60,120,255),
        OFF=Color3.fromRGB(180,185,210),    ONDOT=Color3.fromRGB(255,255,255),
        OFFDOT=Color3.fromRGB(130,140,175), DIV=Color3.fromRGB(185,190,215),
        MINIBAR=Color3.fromRGB(205,210,228),
    },
    ["Dark"] = {
        ACCENT=Color3.fromRGB(180,180,180), BG=Color3.fromRGB(4,4,6),
        SIDEBAR=Color3.fromRGB(6,6,9),      CONTENT=Color3.fromRGB(5,5,8),
        TOPBAR=Color3.fromRGB(3,3,5),       BORDER=Color3.fromRGB(20,20,28),
        ROWBG=Color3.fromRGB(7,7,10),       TABSEL=Color3.fromRGB(15,15,22),
        WHITE=Color3.fromRGB(190,190,195),  GRAY=Color3.fromRGB(80,80,90),
        DIMGRAY=Color3.fromRGB(15,15,20),   ON=Color3.fromRGB(100,100,110),
        OFF=Color3.fromRGB(12,12,16),       ONDOT=Color3.fromRGB(220,220,225),
        OFFDOT=Color3.fromRGB(45,45,55),    DIV=Color3.fromRGB(14,14,18),
        MINIBAR=Color3.fromRGB(6,6,8),
    },
}
UILib.Themes = THEMES

-- ── HELPERS ─────────────────────────────────────────────────────────────────
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerpC(a,b,t)
    return Color3.fromRGB(
        math.floor(a.R*255+(b.R*255-a.R*255)*t),
        math.floor(a.G*255+(b.G*255-a.G*255)*t),
        math.floor(a.B*255+(b.B*255-a.B*255)*t))
end
local function vp()
    local ok,s = pcall(function() return workspace.CurrentCamera.ViewportSize end)
    return ok and s and s.X or 1920, ok and s and s.Y or 1080
end

-- ── DRAWING FACTORIES ────────────────────────────────────────────────────────
local function sq(x,y,w,h,col,filled,zi,transp,thick,corner)
    local s = Drawing.new("Square")
    s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h)
    s.Color=col; s.Filled=filled~=false; s.ZIndex=zi or 1
    s.Transparency=transp or 1; s.Visible=true
    if not (filled~=false) then s.Thickness=thick or 1 end
    if corner and corner>0 then pcall(function() s.Corner=corner end) end
    return s
end
local function tx(txt,x,y,sz,col,center,zi,bold)
    local t = Drawing.new("Text")
    t.Text=txt; t.Position=Vector2.new(x,y); t.Size=sz or 12
    t.Color=col; t.Center=center or false; t.Outline=false
    t.Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System
    t.Transparency=1; t.ZIndex=zi or 3; t.Visible=true
    return t
end
local function ln(x1,y1,x2,y2,col,zi,thick)
    local l = Drawing.new("Line")
    l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2)
    l.Color=col; l.Transparency=1; l.Thickness=thick or 1
    l.ZIndex=zi or 2; l.Visible=true
    return l
end

-- ── KEY NAME MAP ─────────────────────────────────────────────────────────────
local KN = {}
for i=0x41,0x5A do KN[i]=string.char(i) end
for i=0x30,0x39 do KN[i]=tostring(i-0x30) end
for k,v in pairs({[0x70]="F1",[0x71]="F2",[0x72]="F3",[0x73]="F4",[0x74]="F5",
    [0x75]="F6",[0x76]="F7",[0x77]="F8",[0x78]="F9",[0x79]="F10",[0x7A]="F11",[0x7B]="F12",
    [0x20]="Space",[0x09]="Tab",[0x0D]="Enter",[0x1B]="Esc",[0x08]="Back",
    [0x24]="Home",[0x23]="End",[0x2E]="Del",[0x2D]="Ins",[0x21]="PgUp",[0x22]="PgDn",
    [0x26]="Up",[0x28]="Down",[0x25]="Left",[0x27]="Right",
    [0xBC]=",",[0xBE]=".",[0xBF]="/",[0xBA]=";",[0xBB]="=",[0xBD]="-",
    [0xDB]="[",[0xDD]="]",[0xDC]="\\",[0xDE]="'",[0xC0]="`"}) do KN[k]=v end
local function kname(k) return KN[k] or ("Key"..k) end

-- ── LAYOUT CONSTANTS ─────────────────────────────────────────────────────────
local L = {
    W=440, H=400, SIDEBAR=128, TOPBAR=40, FOOTER=34,
    ROW_H=40, PAD=10, TOG_W=34, TOG_H=17, HDL=8, MINI_H=86,
}
L.CW = L.W - L.SIDEBAR  -- content width

-- ════════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ════════════════════════════════════════════════════════════════════════════
function UILib.Window(titleA, titleB, gameName)
    local win = {}
    local C = {}
    for k,v in pairs(THEMES["Check it"]) do C[k]=v end

    -- state
    local uiX, uiY = 300, 200
    local mouse = game.Players.LocalPlayer:GetMouse()
    local _scroll = 0
    pcall(function() mouse.WheelForward:Connect(function() _scroll = _scroll-1 end) end)
    pcall(function() mouse.WheelBackward:Connect(function() _scroll = _scroll+1 end) end)

    local destroyed = false
    local menuOpen  = true
    local minimized = false
    local miniClosed= false
    local isLoading = true
    local menuKey   = 0x70
    local listenKey = false
    local wasClick  = false
    local wasMenuKey= false
    local dragging  = false
    local dragOX, dragOY = 0,0
    local miniDragging = false
    local miniDOX, miniDOY = 0,0
    local scrollDrag= false
    local scrollDOY = 0
    local openDD    = nil
    local currentTab= nil
    local prevTab   = nil

    -- timing / animation
    local lastTick  = tick()
    local toggledAt = tick()-1
    local tabAt     = tick()-1
    local FADE      = 0.4
    local TFADE     = 0.2
    local MINI_FADE = 0.25
    local glowPh    = {0, math.pi*0.6}
    local uiH       = L.H  -- current animated height
    local uiHtgt    = L.H  -- target height

    -- drawing pools
    local all   = {}  -- all main drawings
    local miniD = {}  -- mini-bar drawings
    local base  = {}  -- always-visible base ui drawings
    local show  = {}  -- visibility set
    local fade  = {}  -- tab fade group ("next"/"prev")
    local glowL = {}
    local miniGL= {}
    local btns  = {}
    local tabObjs={}
    local tabAPI = {}
    local tabRowY= {}
    local tabScroll={}
    local tabOrder = {}
    local iKeyInfo, iKeyBind
    local charFn = nil

    -- scrollbar
    local dScrBg, dScrThumb

    -- mini active labels
    local MAXM = 12
    local miniLbls = {}
    local miniPulse= {}
    for i=1,MAXM do
        local lb = tx("",0,0,13,C.WHITE,false,9)
        lb.Outline=true; lb.Visible=false
        table.insert(miniLbls,lb)
        table.insert(miniPulse,i*0.7)
    end

    -- frames (declared forward so helpers can reference)
    local dShadow,dMain,dGlow1,dGlow2,dBorder
    local dTop,dTopFill,dTopLn
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dDotY,dDotR
    local dOnlineTxt,dOnlineDot
    local dSide,dSideLn,dContent,dFooter,dFotLn,dCharLbl
    local dMiniShadow,dMiniBg,dMiniGlow1,dMiniGlow2,dMiniBorder
    local dMiniTop,dMiniTitleW,dMiniTitleA,dMiniTitleG
    local dMiniKeyLbl,dMiniDotG,dMiniDotR,dMiniDivLn,dMiniActBg
    local dWelcome,dNameTxt
    local tipBg,tipBorder,tipLbl,tipDesc
    local tipIn,tipOut,tipAt = false,false,tick()-1
    local TIP_FADE = 0.35
    local hoveredBtn = nil

    -- ── internal helpers ───────────────────────────────────────────────────
    local _twc,_tac = 0,0

    local function mkD(d) table.insert(all,d); d.Visible=false; return d end
    local function vis(d,yes) show[d]=yes or nil; d.Visible=yes and true or false end

    local function inBox(x,y,w,h)
        return mouse.X>=x and mouse.X<=x+w and mouse.Y>=y and mouse.Y<=y+h
    end

    local function contentH() return uiH - L.TOPBAR - L.FOOTER end

    -- show/hide all drawing parts of a button
    local function bShow(b,yes)
        vis(b.bg,yes)
        if b.out     then vis(b.out,yes) end
        if b.outGlow then vis(b.outGlow, yes and (b.hA or 0)>0.02) end
        if not b.isLog then vis(b.lbl,yes) end
        if b.ln      then vis(b.ln,yes) end
        if b.tog     then vis(b.tog,yes); vis(b.dot,yes) end
        if b.track   then vis(b.track,yes); vis(b.fill,yes); vis(b.handle,yes) end
        if b.lbls    then for _,l in ipairs(b.lbls) do vis(l,yes) end end
        if b.qbg     then vis(b.qbg,yes); vis(b.qlb,yes) end
        if b.dlb     then vis(b.dlb,yes) end
        if b.arrow   then vis(b.arrow,yes) end
        if b.valLbl  then vis(b.valLbl,yes) end
        if b.swatches then
            for _,sw in ipairs(b.swatches) do vis(sw.sq,yes); vis(sw.border,yes) end
        end
        if b.isDD then
            for _,o in ipairs(b.opts) do
                vis(o.bg,yes and b.open); vis(o.ln,yes and b.open); vis(o.lb,yes and b.open)
            end
        end
    end

    -- position all parts of a button
    local function bPos(b)
        local sc = tabScroll[b.tab] or 0
        local ry = b.cRY ~= nil and b.cRY or b.ry
        local ax,ay = uiX+b.rx, uiY+ry-sc

        b.bg.Position = Vector2.new(ax,ay)
        if b.outGlow then b.outGlow.Position=Vector2.new(ax-1,ay-1) end

        if b.isLog then
            for i,l in ipairs(b.lbls) do
                if b.starFirst and i==1 then
                    l.Position=Vector2.new(ax+b.cw/2, ay+b.pad)
                else
                    local off = b.starFirst and (b.starH+b.pad+(i-2)*b.lnH) or (b.pad+(i-1)*b.lnH)
                    l.Position=Vector2.new(ax+8, ay+off)
                end
            end
            return
        end

        if b.isSlider then
            b.lbl.Position=Vector2.new(ax+8, ay+7)
            if b.dlb then b.dlb.Position=Vector2.new(ax+8, ay+21) end
            local ty = ay+b.ch-11
            local frac = (b.value-b.minV)/(b.maxV-b.minV)
            local fx = ax+8+frac*b.trkW
            b.track.From=Vector2.new(ax+8,ty); b.track.To=Vector2.new(ax+8+b.trkW,ty)
            b.fill.From=Vector2.new(ax+8,ty); b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
        else
            b.lbl.Position=Vector2.new(ax+10, ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            if b.tog then
                local dox=b.rx+b.cw-L.TOG_W-8
                b.tog.Position=Vector2.new(uiX+dox, uiY+ry-sc+b.ch/2-L.TOG_H/2)
                b.dot.Position=Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt, uiY+ry-sc+b.ch/2-L.TOG_H/2+2)
            end
            if b.qbg then
                local dox2=b.rx+b.cw-L.TOG_W-8
                local qx=uiX+dox2-22; local qy=uiY+ry-sc+b.ch/2-7
                b.qbg.Position=Vector2.new(qx,qy)
                if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+2) end
            end
            if b.valLbl then b.valLbl.Position=Vector2.new(ax+b.cw-60, ay+b.ch/2-6) end
            if b.arrow  then b.arrow.Position=Vector2.new(ax+b.cw-14, ay+b.ch/2-6) end
            if b.swatches then
                local totalW=(#b.swatches*19)-5
                local sx0=ax+b.cw-totalW-10
                for i,sw in ipairs(b.swatches) do
                    local sx=sx0+(i-1)*19; local sy=ay+b.ch/2-7
                    sw.sq.Position=Vector2.new(sx,sy); sw.border.Position=Vector2.new(sx-1,sy-1)
                end
            end
            if b.out then b.out.Position=Vector2.new(ax,ay) end
        end
    end

    -- tag buttons for tab-switch fade
    local function tagFade(b,grp)
        local function tf(d) if d then fade[d]=grp end end
        tf(b.bg); tf(b.outGlow); tf(b.lbl); tf(b.ln); tf(b.tog); tf(b.dot)
        tf(b.track); tf(b.fill); tf(b.handle); tf(b.dlb); tf(b.arrow); tf(b.valLbl); tf(b.out)
        if b.qbg then tf(b.qbg); tf(b.qlb) end
        if b.lbls then for _,l in ipairs(b.lbls) do tf(l) end end
        if b.swatches then for _,sw in ipairs(b.swatches) do tf(sw.sq); tf(sw.border) end end
        if b.isDD then for _,o in ipairs(b.opts) do tf(o.bg); tf(o.ln); tf(o.lb) end end
    end

    -- update all positions after uiX/uiY change
    local function updatePos()
        local h = uiH
        dShadow.Size=Vector2.new(L.W+4,h+4);  dShadow.Position=Vector2.new(uiX-2,uiY-2)
        dMain.Size=Vector2.new(L.W,h);         dMain.Position=Vector2.new(uiX,uiY)
        dBorder.Size=Vector2.new(L.W,h);       dBorder.Position=Vector2.new(uiX,uiY)
        dGlow1.Size=Vector2.new(L.W+2,h+2);   dGlow1.Position=Vector2.new(uiX-1,uiY-1)
        dGlow2.Size=Vector2.new(L.W+4,h+4);   dGlow2.Position=Vector2.new(uiX-2,uiY-2)
        dTop.Position=Vector2.new(uiX+1,uiY+1)
        dTopFill.Position=Vector2.new(uiX+1,uiY+L.TOPBAR-5)
        dTopLn.From=Vector2.new(uiX+1,uiY+L.TOPBAR); dTopLn.To=Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dTitleW.Position=Vector2.new(uiX+14,uiY+12)
        if dTitleW.TextBounds and dTitleW.TextBounds.X>0 and dTitleW.TextBounds.X>_twc then _twc=dTitleW.TextBounds.X end
        local tw=_twc>0 and _twc or (#titleA*8)
        dTitleA.Position=Vector2.new(uiX+14+tw+3,uiY+12)
        if dTitleA.TextBounds and dTitleA.TextBounds.X>0 and dTitleA.TextBounds.X>_tac then _tac=dTitleA.TextBounds.X end
        local ta=_tac>0 and _tac or (#titleB*8)
        dTitleG.Position=Vector2.new(uiX+14+tw+3+ta+10,uiY+12)
        if dOnlineTxt then
            local ox=dTitleG.Position.X + #(dTitleG.Text)*7.5+15
            dOnlineTxt.Position=Vector2.new(ox,uiY+14)
            dOnlineDot.Position=Vector2.new(ox+#("Online:")*6.5+4,uiY+16)
        end
        dKeyLbl.Position=Vector2.new(uiX+L.W-22,uiY+14)
        dDotY.Position=Vector2.new(uiX+L.W-55,uiY+15)
        dDotR.Position=Vector2.new(uiX+L.W-42,uiY+15)
        dSide.Position=Vector2.new(uiX+1,uiY+L.TOPBAR)
        dSide.Size=Vector2.new(L.SIDEBAR-1,h-L.TOPBAR-L.FOOTER-1)
        dSideLn.From=Vector2.new(uiX+L.SIDEBAR,uiY+L.TOPBAR)
        dSideLn.To=Vector2.new(uiX+L.SIDEBAR,uiY+h-L.FOOTER)
        dContent.Position=Vector2.new(uiX+L.SIDEBAR,uiY+L.TOPBAR)
        dContent.Size=Vector2.new(L.CW-1,h-L.TOPBAR-L.FOOTER-1)
        dFooter.Position=Vector2.new(uiX+1,uiY+h-L.FOOTER)
        dFotLn.From=Vector2.new(uiX+1,uiY+h-L.FOOTER); dFotLn.To=Vector2.new(uiX+L.W-1,uiY+h-L.FOOTER)
        dScrBg.Position=Vector2.new(uiX+L.W-6,uiY+L.TOPBAR+2)
        dScrBg.Size=Vector2.new(4,h-L.TOPBAR-L.FOOTER-4)
        if dCharLbl then
            local nW = dNameTxt and #dNameTxt.Text*6 or 0
            dCharLbl.Position=Vector2.new(uiX+42+64+nW+8, uiY+h-L.FOOTER+9)
        end
        for _,t in ipairs(tabObjs) do
            t.bg.Position=Vector2.new(uiX+7,uiY+t.tY)
            t.acc.Position=Vector2.new(uiX+7,uiY+t.tY)
            t.lbl.Position=Vector2.new(uiX+18,uiY+t.tY+7)
            t.lblG.Position=Vector2.new(uiX+18,uiY+t.tY+7)
        end
        for _,b in ipairs(btns) do if show[b.bg] then bPos(b) end end
    end

    local function updateMiniPos()
        dMiniShadow.Position=Vector2.new(uiX-2,uiY-2); dMiniShadow.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBg.Position=Vector2.new(uiX,uiY);          dMiniBg.Size=Vector2.new(L.W,L.MINI_H)
        dMiniGlow1.Position=Vector2.new(uiX-1,uiY-1);  dMiniGlow1.Size=Vector2.new(L.W+2,L.MINI_H+2)
        dMiniGlow2.Position=Vector2.new(uiX-2,uiY-2);  dMiniGlow2.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBorder.Position=Vector2.new(uiX,uiY);      dMiniBorder.Size=Vector2.new(L.W,L.MINI_H)
        dMiniTop.Position=Vector2.new(uiX+1,uiY+1)
        dMiniTitleW.Position=Vector2.new(uiX+14,uiY+12)
        local mtw=_twc>0 and _twc or (#titleA*8)
        dMiniTitleA.Position=Vector2.new(uiX+14+mtw+3,uiY+12)
        local mta=_tac>0 and _tac or (#titleB*8)
        dMiniTitleG.Position=Vector2.new(uiX+14+mtw+3+mta+10,uiY+12)
        dMiniKeyLbl.Position=Vector2.new(uiX+L.W-22,uiY+14)
        dMiniDotG.Position=Vector2.new(uiX+L.W-55,uiY+15)
        dMiniDotR.Position=Vector2.new(uiX+L.W-42,uiY+15)
        dMiniDivLn.From=Vector2.new(uiX+1,uiY+L.TOPBAR); dMiniDivLn.To=Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dMiniActBg.Position=Vector2.new(uiX+1,uiY+L.TOPBAR); dMiniActBg.Size=Vector2.new(L.W-2,L.MINI_H-L.TOPBAR-1)
        -- layout active labels
        local PAD=10; local SEP=14; local CW=7; local RH=18
        local R1=uiY+L.TOPBAR+6; local R2=R1+RH
        local cx=uiX+PAD; local row=1
        for _,lb in ipairs(miniLbls) do
            if lb.Visible and lb.Text~="" then
                local w=#lb.Text*CW
                if cx+w>uiX+L.W-PAD then
                    if row==1 then row=2; cx=uiX+PAD else break end
                end
                lb.Position=Vector2.new(cx, row==1 and R1 or R2)
                cx=cx+w+SEP
            end
        end
    end

    local function showMini(yes)
        for _,d in ipairs(miniD) do d.Visible=yes end
        for _,l in ipairs(miniLbls) do l.Visible=yes and l.Text~="" end
    end

    local function refreshMini()
        local act={}
        for _,b in ipairs(btns) do if b.isTog and b.state then table.insert(act,b.name) end end
        if #act==0 then
            miniLbls[1].Text="no active toggles"; miniLbls[1].Visible=true
            for i=2,MAXM do miniLbls[i].Text=""; miniLbls[i].Visible=false end
            return
        end
        local PAD=10; local SEP=14; local CW=7; local RH=18
        local R1=uiY+L.TOPBAR+6; local R2=R1+RH
        local slots={}; local cx=uiX+PAD; local row=1
        for _,name in ipairs(act) do
            local w=#name*CW
            if cx+w>uiX+L.W-PAD then
                if row==1 then row=2; cx=uiX+PAD else break end
            end
            table.insert(slots,{name=name,x=cx,y=(row==1 and R1 or R2)}); cx=cx+w+SEP
        end
        for i,lb in ipairs(miniLbls) do
            if slots[i] then lb.Text=slots[i].name; lb.Position=Vector2.new(slots[i].x,slots[i].y); lb.Visible=true
            else lb.Text=""; lb.Visible=false end
        end
    end

    -- apply fade opacity to all drawings each frame
    local function applyFade()
        if isLoading or minimized then
            for _,d in ipairs(all) do d.Visible=false end
            if dScrBg then dScrBg.Visible=false; dScrThumb.Visible=false end
            return
        end
        for _,l in ipairs(miniLbls) do l.Visible=false end
        local mf=1-(toggledAt-(tick()-FADE))/FADE
        if not menuOpen and mf>=1.1 then
            for _,d in ipairs(all) do d.Visible=false end
            return
        end
        local mOp=mf<1.1
            and math.abs((menuOpen and 0 or 1)-clamp(mf,0,1))
            or (menuOpen and 1 or 0)
        local tp=clamp((tick()-tabAt)/TFADE,0,1)
        for _,d in ipairs(all) do
            if show[d] then
                local tOp=fade[d]=="next" and tp or fade[d]=="prev" and (1-tp) or 1
                local op=mOp*tOp
                d.Visible=op>0.01; d.Transparency=op
            else
                d.Visible=false
            end
        end
    end

    -- ── layout ────────────────────────────────────────────────────────────
    local recalcLayout
    recalcLayout = function(tname)
        local cy=10; local lastHY=0
        for _,b in ipairs(btns) do
            if b.tab==tname then
                if b.isDiv then
                    b.ry=L.TOPBAR+cy; b.baseRY=b.ry; lastHY=b.ry
                    bShow(b,true); cy=cy+b.ch+10
                else
                    local collapsed = b.section and _sections[b.section]
                    if collapsed then
                        b._collapsing=true; b._collapseTarget=lastHY+14
                    else
                        b.ry=L.TOPBAR+cy; b.baseRY=b.ry
                        if b._collapsing then b._collapsing=false; b._collapseTarget=nil end
                        bShow(b,true); bPos(b)
                        cy=cy+b.ch+8
                        if b.isDD and b.open then cy=cy+(#b.opts*b.ch) end
                    end
                end
            else
                if show[b.bg] then bShow(b,false) end
            end
        end
        local lastY=0
        for _,b in ipairs(btns) do
            if b.tab==tname and show[b.bg] then
                local bot=b.ry+b.ch; if bot>lastY then lastY=bot end
            end
        end
        tabRowY[tname]=lastY+36
        tabScroll[tname]=clamp(tabScroll[tname] or 0,0,math.max(0,(tabRowY[tname] or 0)-contentH()+8))
    end

    local function switchTab(name)
        if name==currentTab then return end
        if openDD then
            openDD.open=false; if openDD.arrow then openDD.arrow.Text="v" end
            for _,o in ipairs(openDD.opts) do o.targetA=0 end; openDD=nil
        end
        uiHtgt=L.H; prevTab=currentTab; currentTab=name; tabAt=tick()
        for _,t in ipairs(tabObjs) do
            t.sel=t.name==name
            vis(t.lbl,t.sel); vis(t.lblG,not t.sel)
        end
        for _,d in ipairs(all) do fade[d]=nil end
        for _,b in ipairs(btns) do
            if b.tab==prevTab then bShow(b,true); bPos(b); tagFade(b,"prev") end
        end
        for _,b in ipairs(btns) do
            if b.tab==name then
                if b.isDiv and b.collapsible and b.section then
                    _sections[b.section]=false; if b.arrow then b.arrow.Text="v" end
                end
                bShow(b,true)
            end
        end
        recalcLayout(name)
        for _,b in ipairs(btns) do
            if b.tab==name then b.cRY=b.ry; bPos(b); tagFade(b,"next") end
        end
    end

    local function restoreFull()
        minimized=false; miniClosed=false; showMini(false)
        for _,d in ipairs(all) do d.Visible=false; fade[d]=nil end
        dScrBg.Visible=false; dScrThumb.Visible=false
        for _,d in ipairs(base) do vis(d,true) end
        for _,t in ipairs(tabObjs) do
            vis(t.bg,true); vis(t.acc,true); vis(t.lbl,t.sel); vis(t.lblG,not t.sel)
        end
        uiH=L.MINI_H+5; updatePos(); uiHtgt=L.H; lastTick=tick()
        menuOpen=true; toggledAt=tick()-FADE-0.01
        for _,b in ipairs(btns) do if b.tab==currentTab then bShow(b,true); bPos(b) end end
    end

    -- ── element constructors ───────────────────────────────────────────────
    local function rx0() return L.SIDEBAR+L.PAD end
    local function cw0() return L.CW-L.PAD*2 end

    local function newTog(tab,name,relY,init,cb,desc)
        local rx=rx0(); local cw=cw0(); local ch=L.ROW_H-2; local ry=L.TOPBAR+relY
        local ox=rx+cw-L.TOG_W-8
        local bg  =mkD(sq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,4))
        local dl  =mkD(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb  =mkD(tx(name,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local tog =mkD(sq(uiX+ox,uiY+ry+ch/2-L.TOG_H/2,L.TOG_W,L.TOG_H,init and C.ON or C.OFF,true,4,1,nil,L.TOG_H))
        local dot =mkD(sq(uiX+ox+(init and L.TOG_W-L.TOG_H+2 or 2),uiY+ry+ch/2-L.TOG_H/2+2,L.TOG_H-4,L.TOG_H-4,init and C.ONDOT or C.OFFDOT,true,5,1,nil,L.TOG_H))
        local qbg,qlb
        if desc then
            local qx=uiX+ox-22; local qy=uiY+ry+ch/2-7
            qbg=mkD(sq(qx,qy,14,14,Color3.fromRGB(16,20,38),true,6,1,nil,3))
            qlb=mkD(tx("?",qx+7,qy+2,9,C.GRAY,true,7,true))
        end
        local glow=mkD(sq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isTog=true,name=name,state=init,bg=bg,lbl=lb,ln=dl,tog=tog,dot=dot,
                 outGlow=glow,qbg=qbg,qlb=qlb,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,
                 lt=init and 1 or 0,cb=cb,desc=desc,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newDiv(tab,lbl,relY,collapsible)
        local rx=rx0(); local cw=cw0(); local ry=L.TOPBAR+relY
        local lb=mkD(tx(lbl,uiX+rx+6,uiY+ry,9,C.GRAY,false,8))
        local dl=mkD(ln(uiX+rx,uiY+ry+13,uiX+rx+cw,uiY+ry+13,C.DIV,4,1))
        local arrow
        if collapsible then
            arrow=mkD(tx("v",uiX+rx+cw-6,uiY+ry,9,C.GRAY,false,8))
            if _sections[lbl]==nil then _sections[lbl]=false end
        end
        local b={tab=tab,isDiv=true,bg=lb,lbl=lb,ln=dl,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=14,
                 collapsible=collapsible,section=lbl,arrow=arrow}
        table.insert(btns,b); return #btns
    end

    local function newAct(tab,lbl,relY,col,cb,lblCol)
        local rx=rx0(); local cw=cw0(); local ch=L.ROW_H-2; local ry=L.TOPBAR+relY
        local outBg=col or C.ROWBG
        local outCol=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=mkD(sq(uiX+rx,uiY+ry,cw,ch,outCol,true,3,1,nil,4))
        local bg=mkD(sq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,col or C.ROWBG,true,4,1,nil,4))
        local lb=mkD(tx(lbl,uiX+rx+cw/2,uiY+ry+ch/2-6,12,lblCol or C.WHITE,true,8))
        local glow=mkD(sq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isAct=true,customCol=col~=nil,out=out,bg=bg,lbl=lb,outGlow=glow,
                 rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,cb=cb,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newSlider(tab,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local rx=rx0(); local cw=cw0(); local ch=L.ROW_H+6; local ry=L.TOPBAR+relY
        local trkW=cw-16
        local disp=isFloat and string.format("%.1f",initV) or math.floor(initV)
        local bg  =mkD(sq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,4))
        local dl  =mkD(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb  =mkD(tx(lbl..": "..disp,uiX+rx+8,uiY+ry+7,12,C.WHITE,false,8))
        local dlb = desc and mkD(tx(desc,uiX+rx+8,uiY+ry+21,9,C.GRAY,false,8)) or nil
        local ty  =uiY+ry+ch-11
        local frac=(initV-minV)/(maxV-minV)
        local fx  =uiX+rx+8+frac*trkW
        local trk =mkD(ln(uiX+rx+8,ty,uiX+rx+8+trkW,ty,C.DIMGRAY,5,3))
        local fil =mkD(ln(uiX+rx+8,ty,fx,ty,C.ACCENT,6,3))
        local hdl =mkD(sq(fx-4,ty-4,L.HDL,L.HDL,C.WHITE,true,7,1,nil,3))
        local glow=mkD(sq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isSlider=true,bg=bg,lbl=lb,ln=dl,track=trk,fill=fil,handle=hdl,
                 outGlow=glow,dlb=dlb,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,
                 trkW=trkW,minV=minV,maxV=maxV,value=initV,baseLbl=lbl,
                 dragging=false,cb=cb,isFloat=isFloat or false,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newDD(tab,lbl,relY,opts,initIdx,cb)
        local rx=rx0(); local cw=cw0(); local ch=L.ROW_H-2; local ry=L.TOPBAR+relY
        local outBg=C.ROWBG
        local outCol=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=mkD(sq(uiX+rx,uiY+ry,cw,ch,outCol,true,3,1,nil,4))
        local bg=mkD(sq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROWBG,true,4,1,nil,4))
        local lb=mkD(tx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local vi=initIdx or 1
        local val=mkD(tx(opts[vi] or "",uiX+rx+cw-60,uiY+ry+ch/2-6,11,C.ACCENT,false,8))
        local arrow=mkD(tx("v",uiX+rx+cw-14,uiY+ry+ch/2-6,9,C.GRAY,false,8))
        local glow=mkD(sq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local optBgs={}
        for i,opt in ipairs(opts) do
            local oy2=ry+ch+((i-1)*ch)
            local obg=mkD(sq(uiX+rx,uiY+oy2,cw,ch,C.ROWBG,true,10,0,nil,0))
            local oln=mkD(ln(uiX+rx,uiY+oy2+ch,uiX+rx+cw,uiY+oy2+ch,C.DIV,11,1))
            local olb=mkD(tx(opt,uiX+rx+14,uiY+oy2+ch/2-6,11,i==vi and C.ACCENT or C.WHITE,false,11))
            obg.Visible=false; oln.Visible=false; olb.Visible=false
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,ry=oy2,alpha=0,targetA=0})
        end
        local b={tab=tab,isDD=true,out=out,bg=bg,lbl=lb,valLbl=val,arrow=arrow,
                 outGlow=glow,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,
                 opts=optBgs,options=opts,selected=vi,open=false,cb=cb,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newColorPicker(tab,lbl,relY,initCol,cb)
        local rx=rx0(); local cw=cw0(); local ch=L.ROW_H-2; local ry=L.TOPBAR+relY
        local bg=mkD(sq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,4))
        local dl=mkD(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb=mkD(tx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local cols={Color3.fromRGB(70,120,255),Color3.fromRGB(210,55,55),Color3.fromRGB(45,190,95),
                    Color3.fromRGB(255,175,80),Color3.fromRGB(180,80,255),Color3.fromRGB(215,220,240)}
        local totalW=(#cols*19)-5; local sx0=uiX+rx+cw-totalW-10
        local sws={}
        for i,col in ipairs(cols) do
            local sx=sx0+(i-1)*19; local sy=uiY+ry+ch/2-7
            local s=mkD(sq(sx,sy,14,14,col,true,6,1,nil,3))
            local bord=mkD(sq(sx-1,sy-1,16,16,i==1 and C.WHITE or C.BORDER,false,7,1,1,3))
            table.insert(sws,{sq=s,border=bord,col=col})
        end
        local glow=mkD(sq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isColorPicker=true,bg=bg,lbl=lb,ln=dl,outGlow=glow,swatches=sws,
                 rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,selected=1,value=cols[1],cb=cb,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newLog(tab,lines,relY,starFirst)
        local rx=rx0(); local cw=cw0()
        local lnH=18; local starH=starFirst and 26 or 0; local pad=10
        local ch=starH+(#lines-(starFirst and 1 or 0))*lnH+pad*2
        local ry=L.TOPBAR+relY
        local bg=mkD(sq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,6))
        local lbls={}
        for i,line in ipairs(lines) do
            local l=Drawing.new("Text")
            if starFirst and i==1 then
                l.Text=line; l.Position=Vector2.new(uiX+rx+cw/2,uiY+ry+pad)
                l.Size=14; l.Color=Color3.fromRGB(255,200,40); l.Center=true
                l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            else
                local off=starFirst and (starH+pad+(i-2)*lnH) or (pad+(i-1)*lnH)
                l.Text=line; l.Position=Vector2.new(uiX+rx+8,uiY+ry+off)
                l.Size=11; l.Color=C.WHITE; l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            end
            l.Transparency=1; l.ZIndex=8; l.Visible=false
            table.insert(lbls,l)
        end
        local b={tab=tab,isLog=true,bg=bg,lbl=bg,lbls=lbls,rx=rx,ry=ry,baseRY=ry,cRY=ry,
                 cw=cw,ch=ch,starFirst=starFirst,starH=starH,lnH=lnH,pad=pad}
        table.insert(btns,b); return #btns
    end

    -- ── theme apply ────────────────────────────────────────────────────────
    local function applyTheme(name)
        local t=THEMES[name]; if not t then return end
        for k,v in pairs(t) do C[k]=v end
        if not dMain then return end
        dMain.Color=C.BG; dMiniBg.Color=C.BG
        dTop.Color=C.TOPBAR; dMiniTop.Color=C.TOPBAR
        dSide.Color=C.SIDEBAR; dContent.Color=C.CONTENT; dFooter.Color=C.TOPBAR
        dBorder.Color=C.BORDER; dMiniBorder.Color=C.BORDER
        dTopLn.Color=C.BORDER; dMiniDivLn.Color=C.BORDER
        dSideLn.Color=C.BORDER; dFotLn.Color=C.BORDER
        dGlow1.Color=C.ACCENT; dGlow2.Color=C.ACCENT
        dMiniGlow1.Color=C.ACCENT; dMiniGlow2.Color=C.ACCENT
        dScrBg.Color=Color3.fromRGB(18,20,28); dScrThumb.Color=C.ACCENT
        dTitleA.Color=C.ACCENT; dMiniTitleA.Color=C.ACCENT
        dTitleW.Color=C.WHITE; dMiniTitleW.Color=C.WHITE
        dKeyLbl.Color=C.GRAY; dMiniKeyLbl.Color=C.GRAY
        if dMiniActBg then dMiniActBg.Color=C.MINIBAR end
        if dCharLbl then dCharLbl.Color=C.GRAY end
        for _,l in ipairs(miniLbls) do l.Color=C.WHITE end
        for _,t2 in ipairs(tabObjs) do
            t2.bg.Color=t2.sel and C.TABSEL or C.SIDEBAR
            t2.acc.Color=t2.sel and C.ACCENT or C.SIDEBAR
            t2.lbl.Color=C.WHITE; t2.lblG.Color=C.GRAY
        end
        for _,b in ipairs(btns) do
            if b.ln then b.ln.Color=C.DIV end
            if b.isTog then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
                b.tog.Color=b.state and C.ON or C.OFF
                b.dot.Color=b.state and C.ONDOT or C.OFFDOT
                if b.qlb then b.qlb.Color=C.GRAY end
            elseif b.isSlider then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
                if b.dlb then b.dlb.Color=C.GRAY end
                b.track.Color=C.DIMGRAY; b.fill.Color=C.ACCENT
            elseif b.isAct then
                if not b.customCol then b.bg.Color=C.ROWBG
                    local ob=C.ROWBG
                    if b.out then b.out.Color=Color3.new(math.min(1,ob.R*1.5),math.min(1,ob.G*1.5),math.min(1,ob.B*1.5)) end
                end
            elseif b.isDiv then
                b.lbl.Color=C.GRAY; if b.arrow then b.arrow.Color=C.GRAY end
            elseif b.isDD then
                b.lbl.Color=C.WHITE; b.arrow.Color=C.GRAY; b.valLbl.Color=C.ACCENT
                for j,o in ipairs(b.opts) do
                    o.bg.Color=C.ROWBG; o.ln.Color=C.DIV
                    o.lb.Color=j==b.selected and C.ACCENT or C.WHITE
                end
            elseif b.isColorPicker then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
            end
        end
    end

    -- ── tab API factory ────────────────────────────────────────────────────
    local function getTabAPI(tname)
        if tabAPI[tname] then return tabAPI[tname] end
        local api={}; tabRowY[tname]=10; local curSec=nil
        local function nextY(h) local y=tabRowY[tname]; tabRowY[tname]=y+h; return y end
        local function tag(idx) if curSec and btns[idx] then btns[idx].section=curSec end end

        function api:Div(lbl,collapsible)
            if collapsible==nil then collapsible=true end
            local idx=newDiv(tname,lbl,nextY(22),collapsible)
            curSec=collapsible and lbl or nil
        end
        function api:Toggle(lbl,init,cb,desc)
            local idx=newTog(tname,lbl,nextY(L.ROW_H+4),init,cb,desc); tag(idx)
        end
        function api:Slider(lbl,minV,maxV,initV,cb,isFloat,desc)
            local idx=newSlider(tname,lbl,nextY(L.ROW_H+10),minV,maxV,initV,cb,isFloat,desc); tag(idx)
        end
        function api:Button(lbl,col,cb,lblCol)
            local idx=newAct(tname,lbl,nextY(L.ROW_H+4),col,cb,lblCol); tag(idx); return idx
        end
        function api:Dropdown(lbl,opts,initIdx,cb)
            local idx=newDD(tname,lbl,nextY(L.ROW_H+4),opts,initIdx,cb); tag(idx)
        end
        function api:ColorPicker(lbl,initCol,cb)
            local idx=newColorPicker(tname,lbl,nextY(L.ROW_H+4),initCol,cb); tag(idx)
        end
        function api:Log(lines,starFirst)
            local lnH=18; local starH=starFirst and 26 or 0
            local h=starH+(#lines-(starFirst and 1 or 0))*lnH+20+6
            local idx=newLog(tname,lines,nextY(h),starFirst); tag(idx)
            local la={}
            function la:SetLines(nl)
                if not btns[idx] then return end
                for i,l in ipairs(btns[idx].lbls) do
                    l.Text=nl[i] or ""; l.Visible=nl[i] and show[btns[idx].bg] or false
                end
            end
            return la
        end
        tabAPI[tname]=api; return api
    end

    -- ════════════════════════════════════════════════════════════════════
    -- INIT
    -- ════════════════════════════════════════════════════════════════════
    function win:Init(defaultTab, charLabelFn, notifFn)
        local notify = notifFn or function(msg,title,dur)
            pcall(function() notify(msg, title or titleA.." "..titleB, dur or 3) end)
        end
        charFn = charLabelFn

        -- main window frames
        dShadow  =mkD(sq(uiX-2,uiY-2,L.W+4,L.H+4,Color3.fromRGB(0,0,5),true,0,0.5,nil,12))
        dMain    =mkD(sq(uiX,uiY,L.W,L.H,C.BG,true,1,1,nil,10))
        dGlow1   =mkD(sq(uiX-1,uiY-1,L.W+2,L.H+2,C.ACCENT,false,1,0.9,1,11))
        dGlow2   =mkD(sq(uiX-2,uiY-2,L.W+4,L.H+4,C.ACCENT,false,0,0.35,2,12))
        glowL    ={dGlow1,dGlow2}
        dBorder  =mkD(sq(uiX,uiY,L.W,L.H,C.BORDER,false,3,0.2,1,10))
        dTop     =mkD(sq(uiX+1,uiY+1,L.W-2,L.TOPBAR,C.TOPBAR,true,3,1,nil,9))
        dTopFill =mkD(sq(uiX+1,uiY+L.TOPBAR-5,L.W-2,7,C.TOPBAR,true,3,1))
        dTopLn   =mkD(ln(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4,1))
        dTitleW  =mkD(tx(titleA,uiX+14,uiY+12,14,C.WHITE,false,9,true))
        dTitleA  =mkD(tx(titleB,uiX+14+(#titleA*8)+3,uiY+12,14,C.ACCENT,false,9,true))
        local gn = gameName or ""
        dTitleG  =mkD(tx(gn,uiX+100,uiY+12,13,Color3.fromRGB(255,175,80),false,9))
        dOnlineTxt=mkD(tx("Online:",uiX+200,uiY+14,11,C.GRAY,false,9))
        dOnlineDot=mkD(sq(uiX+240,uiY+16,6,6,Color3.new(0.9,0.1,0.1),true,9,1,nil,3))
        local function posOnline(s)
            local ox=uiX+100+#s*7.5+15
            dOnlineTxt.Position=Vector2.new(ox,uiY+14)
            dOnlineDot.Position=Vector2.new(ox+#("Online:")*6.5+4,uiY+16)
        end
        posOnline(gn)
        if gn=="" or gn=="Game Name" then
            dTitleG.Text=""
            task.spawn(function() pcall(function()
                local name
                if type(getgamename)=="function" then name=getgamename()
                else
                    local info=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                    name=info and info.Name
                end
                if name then dTitleG.Text=name; posOnline(name)
                    if dMiniTitleG then dMiniTitleG.Text=name end
                end
            end) end)
        end
        dKeyLbl  =mkD(tx("F1",uiX+L.W-22,uiY+14,11,C.GRAY,false,9))
        dDotY    =mkD(sq(uiX+L.W-55,uiY+15,8,8,Color3.fromRGB(190,148,0),true,9,1,nil,3))
        dDotR    =mkD(sq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9,1,nil,3))
        dSide    =mkD(sq(uiX+1,uiY+L.TOPBAR,L.SIDEBAR-1,L.H-L.TOPBAR-L.FOOTER-1,C.SIDEBAR,true,2,1,nil,8))
        dSideLn  =mkD(ln(uiX+L.SIDEBAR,uiY+L.TOPBAR,uiX+L.SIDEBAR,uiY+L.H-L.FOOTER,C.BORDER,4,1))
        dContent =mkD(sq(uiX+L.SIDEBAR,uiY+L.TOPBAR,L.CW-1,L.H-L.TOPBAR-L.FOOTER-1,C.CONTENT,true,2,1,nil,8))
        dFooter  =mkD(sq(uiX+1,uiY+L.H-L.FOOTER,L.W-2,L.FOOTER-1,C.TOPBAR,true,3,1,nil,6))
        dFotLn   =mkD(ln(uiX+1,uiY+L.H-L.FOOTER,uiX+L.W-1,uiY+L.H-L.FOOTER,C.BORDER,4,1))
        dCharLbl =mkD(tx("",0,0,11,C.GRAY,false,9))
        dScrBg   =sq(uiX+L.W-6,uiY+L.TOPBAR+2,4,L.H-L.TOPBAR-L.FOOTER-4,Color3.fromRGB(18,20,28),true,4,1,nil,2)
        dScrBg.Visible=false
        dScrThumb=sq(uiX+L.W-6,uiY+L.TOPBAR+2,4,20,C.ACCENT,true,5,1,nil,2)
        dScrThumb.Visible=false

        -- tooltip
        tipBg=sq(0,0,10,10,Color3.fromRGB(10,13,24),true,12,1,nil,4); pcall(function() tipBg.Corner=4 end); tipBg.Visible=false
        tipBorder=sq(0,0,10,10,C.ACCENT,false,12,0.7,1,4); pcall(function() tipBorder.Corner=4 end); tipBorder.Visible=false
        tipLbl=tx("",0,0,11,C.ACCENT,false,13,true); tipLbl.Visible=false
        tipDesc=tx("",0,0,10,Color3.fromRGB(130,140,170),false,13); tipDesc.Visible=false

        -- welcome / name footer labels
        dWelcome=mkD(tx("welcome,",uiX+42,uiY+L.H-L.FOOTER+9,11,C.WHITE,false,9))
        dNameTxt=mkD(tx(game.Players.LocalPlayer.Name,uiX+42+64,uiY+L.H-L.FOOTER+9,11,Color3.fromRGB(45,190,95),false,9,true))

        base={dShadow,dGlow2,dGlow1,dMain,dBorder,dTop,dTopFill,dTopLn,
              dTitleW,dTitleA,dTitleG,dOnlineTxt,dOnlineDot,dKeyLbl,dDotY,dDotR,
              dSide,dSideLn,dContent,dFooter,dFotLn,dCharLbl,dWelcome,dNameTxt}

        -- build tab buttons in sidebar
        for i,name in ipairs(tabOrder) do
            local tY=L.TOPBAR+8+(i-1)*34
            local isSel=name==defaultTab
            local tbg =mkD(sq(uiX+7,uiY+tY,L.SIDEBAR-14,26,isSel and C.TABSEL or C.SIDEBAR,true,3,1,nil,5))
            local tacc=mkD(sq(uiX+7,uiY+tY,3,26,isSel and C.ACCENT or C.SIDEBAR,true,4,1,nil,2))
            local tlW =mkD(tx(name,uiX+18,uiY+tY+7,11,C.WHITE,false,8))
            local tlG =mkD(tx(name,uiX+18,uiY+tY+7,11,C.GRAY,false,8))
            vis(tbg,false); vis(tacc,false); vis(tlW,false); vis(tlG,false)
            table.insert(tabObjs,{bg=tbg,acc=tacc,lbl=tlW,lblG=tlG,name=name,sel=isSel,lt=isSel and 1 or 0,tY=tY})
        end

        -- mini-bar frames
        dMiniShadow=sq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,Color3.fromRGB(0,0,5),true,0,0.5,nil,12)
        dMiniBg    =sq(uiX,uiY,L.W,L.MINI_H,C.BG,true,1,1,nil,10)
        dMiniGlow1 =sq(uiX-1,uiY-1,L.W+2,L.MINI_H+2,C.ACCENT,false,1,0.9,1,11)
        dMiniGlow2 =sq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,C.ACCENT,false,0,0.35,2,12)
        dMiniBorder=sq(uiX,uiY,L.W,L.MINI_H,C.BORDER,false,3,0.2,1,10)
        dMiniTop   =sq(uiX+1,uiY+1,L.W-2,L.TOPBAR,C.TOPBAR,true,3,1,nil,9)
        dMiniTitleW=tx(titleA,uiX+14,uiY+12,14,C.WHITE,false,9,true)
        dMiniTitleA=tx(titleB,uiX+14+(#titleA*8)+3,uiY+12,14,C.ACCENT,false,9,true)
        dMiniTitleG=tx(gameName or "",uiX+100,uiY+12,13,Color3.fromRGB(255,175,80),false,9)
        dMiniKeyLbl=tx("F1",uiX+L.W-22,uiY+14,11,C.GRAY,false,9)
        dMiniDotG  =sq(uiX+L.W-55,uiY+15,8,8,C.ACCENT,true,9,1,nil,3)
        dMiniDotR  =sq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9,1,nil,3)
        dMiniDivLn =ln(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4,1)
        dMiniActBg =sq(uiX+1,uiY+L.TOPBAR,L.W-2,L.MINI_H-L.TOPBAR-1,C.MINIBAR,true,2,1,nil,0)
        miniGL     ={dMiniGlow1,dMiniGlow2}
        for _,d in ipairs({dMiniShadow,dMiniBg,dMiniGlow1,dMiniGlow2,dMiniBorder,
            dMiniTop,dMiniTitleW,dMiniTitleA,dMiniTitleG,dMiniKeyLbl,dMiniDotG,dMiniDotR,dMiniDivLn,dMiniActBg}) do
            d.Visible=false; table.insert(miniD,d)
        end

        -- initialize to default tab and show base
        for _,d in ipairs(base) do vis(d,true) end
        switchTab(defaultTab)

        -- ── loading screen ────────────────────────────────────────────────
        task.spawn(function()
            local stages={
                {pct=0.15,text="Loading modules..."},
                {pct=0.35,text="Connecting..."},
                {pct=0.60,text="Building UI..."},
                {pct=0.80,text="Almost ready..."},
                {pct=1.00,text="Done!"},
            }
            local bBg=sq(uiX,uiY,L.W,L.H,Color3.fromRGB(7,9,17),true,20,1,nil,10)
            local bTxt=tx((gameName or titleA.." "..titleB).." Loading...",uiX+L.W/2,uiY+L.H/2-24,13,C.WHITE,true,21)
            local bDesc=tx("",uiX+L.W/2,uiY+L.H/2-6,10,C.GRAY,true,21)
            local bBarBg=sq(uiX+L.W/2-80,uiY+L.H/2+8,160,6,C.DIMGRAY,true,21,1,nil,3)
            local bBar=sq(uiX+L.W/2-80,uiY+L.H/2+8,0,6,C.ACCENT,true,22,1,nil,3)
            local fill=0
            local function setBar(opacity,lbl,pct,desc)
                bBg.Transparency=opacity; bTxt.Transparency=opacity
                bDesc.Transparency=opacity; bBarBg.Transparency=opacity; bBar.Transparency=opacity
                bTxt.Text=lbl; bDesc.Text=desc; bBar.Size=Vector2.new(160*pct,6)
                bBg.Visible=opacity>0.01; bTxt.Visible=opacity>0.01
                bDesc.Visible=opacity>0.01; bBarBg.Visible=opacity>0.01; bBar.Visible=opacity>0.01
            end
            for _,s in ipairs(stages) do
                local sf=fill; local frames=12
                for f=1,frames do
                    fill=sf+(s.pct-sf)*(f/frames); setBar(1,(gameName or titleA.." "..titleB).." Initializing...",fill,s.text); task.wait()
                end
                task.wait(0.1)
            end
            local t2=tick(); local dur=0.3
            while tick()-t2<dur and not destroyed do task.wait(); setBar(1-(tick()-t2)/dur,"Ready!",1,"") end
            for _,d in ipairs({bBg,bTxt,bDesc,bBarBg,bBar}) do pcall(function() d:Remove() end) end
            isLoading=false
        end)

        -- ── main loop ─────────────────────────────────────────────────────
        task.spawn(function()
        while not destroyed do
            task.wait()
            local _ok,_act=pcall(function() return isrbxactive() end)
            if not _ok or _act then
            local clicking=ismouse1pressed()
            local keyDown=iskeypressed(menuKey)

            if keyDown and not wasMenuKey and not isLoading then
                if miniClosed then
                    miniClosed=false; refreshMini(); showMini(true); updateMiniPos()
                elseif minimized then
                    showMini(false); miniClosed=true
                    for _,d in ipairs(all) do d.Visible=false end
                    dScrBg.Visible=false; dScrThumb.Visible=false
                else
                    menuOpen=not menuOpen; toggledAt=tick()
                    pcall(function() setrobloxinput(not menuOpen) end)
                end
            end
            wasMenuKey=keyDown

            -- mini bar mode
            if minimized and not miniClosed then
                local t=tick()
                for i,s in ipairs(miniGL) do
                    local p=t+glowPh[i]
                    s.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
                    s.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                local pt=t*0.8
                for i,lb in ipairs(miniLbls) do
                    if lb.Text~="" then
                        lb.Visible=true
                        lb.Color=lerpC(C.ACCENT,C.WHITE,(math.sin(pt+miniPulse[i])+1)/2)
                    else lb.Visible=false end
                end
                if clicking and not wasClick then
                    if inBox(uiX+L.W-46,uiY+11,12,12) then
                        miniClosed=true; showMini(false)
                    elseif inBox(uiX+L.W-59,uiY+11,12,12) then
                        restoreFull()
                    elseif inBox(uiX,uiY,L.W,L.MINI_H) then
                        miniDragging=true; miniDOX=mouse.X-uiX; miniDOY=mouse.Y-uiY
                    end
                end
                if not clicking then miniDragging=false end
                if miniDragging and clicking then
                    local vpW,vpH=vp()
                    uiX=clamp(mouse.X-miniDOX,0,vpW-L.W); uiY=clamp(mouse.Y-miniDOY,0,vpH-L.MINI_H)
                    updateMiniPos()
                end
                wasClick=clicking
            end

            if not minimized and not isLoading then
                -- tab indicator lerp
                for _,t in ipairs(tabObjs) do
                    local tgt=t.sel and 1 or 0
                    t.lt=t.lt+(tgt-t.lt)*0.15
                    t.bg.Color=lerpC(C.SIDEBAR,C.TABSEL,t.lt)
                    t.acc.Color=lerpC(C.SIDEBAR,C.ACCENT,t.lt)
                end
                -- toggle lerp
                for _,b in ipairs(btns) do
                    if b.isTog and b.tab==currentTab then
                        local tgt=b.state and 1 or 0
                        b.lt=b.lt+(tgt-b.lt)*0.18
                        b.tog.Color=lerpC(C.OFF,C.ON,b.lt)
                        b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.lt)
                        local sc=tabScroll[currentTab] or 0
                        local dox=b.rx+b.cw-L.TOG_W-8
                        local ry=b.cRY or b.ry
                        b.tog.Position=Vector2.new(uiX+dox, uiY+ry-sc+b.ch/2-L.TOG_H/2)
                        b.dot.Position=Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt, uiY+ry-sc+b.ch/2-L.TOG_H/2+2)
                    end
                end
                -- glow pulse
                local t=tick()
                for i,s in ipairs(glowL) do
                    local p=t+glowPh[i]
                    s.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
                    s.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                -- title shimmer
                local tf=(math.sin(t*2)+1)/2
                dTitleW.Color=lerpC(C.WHITE,C.ACCENT,tf); dTitleA.Color=lerpC(C.ACCENT,C.WHITE,tf)
                if dMiniTitleW then dMiniTitleW.Color=lerpC(C.WHITE,C.ACCENT,tf); dMiniTitleA.Color=lerpC(C.ACCENT,C.WHITE,tf) end
                -- tooltip fade
                if tipBg then
                    local prog=clamp((tick()-tipAt)/TIP_FADE,0,1)
                    local op=tipIn and prog or (tipOut and (1-prog) or 0)
                    if tipOut and prog>=1 then
                        tipBg.Visible=false; tipBorder.Visible=false; tipLbl.Visible=false; tipDesc.Visible=false; tipOut=false
                    elseif tipBg.Visible then
                        tipBg.Transparency=op; tipBorder.Transparency=op*0.7; tipLbl.Transparency=op; tipDesc.Transparency=op
                    end
                end
                -- hover glow
                for _,b in ipairs(btns) do
                    if b.tab==currentTab and show[b.bg] and not b.isDiv and not b.isLog then
                        local itemY=uiY+(b.cRY or b.ry)-(tabScroll[currentTab] or 0)
                        if inBox(uiX+b.rx,itemY,b.cw,b.ch) then
                            b.bg.Color=lerpC(C.ROWBG,C.WHITE,0.06); b.tHA=1
                        else
                            b.tHA=0
                            if not b.isAct or not b.customCol then b.bg.Color=C.ROWBG end
                        end
                        if b.outGlow then
                            local diff=(b.tHA or 0)-(b.hA or 0)
                            if math.abs(diff)>0.05 then
                                b.hA=(b.hA or 0)+diff*0.15
                                b.outGlow.Transparency=b.hA*dMain.Transparency
                            elseif b.tHA==0 then b.hA=0; b.outGlow.Transparency=0 end
                            b.outGlow.Visible=(b.hA or 0)>0.02
                        end
                    end
                end
                -- tooltip show/hide on hover
                hoveredBtn=nil
                for _,b in ipairs(btns) do
                    if b.tab==currentTab and b.desc and show[b.bg] then
                        local itemY=uiY+(b.cRY or b.ry)-(tabScroll[currentTab] or 0)
                        if inBox(uiX+b.rx,itemY,b.cw,b.ch) then hoveredBtn=b; break end
                    end
                end
                if hoveredBtn then
                    local itemY=uiY+(hoveredBtn.cRY or hoveredBtn.ry)-(tabScroll[currentTab] or 0)
                    local tx2=uiX+hoveredBtn.rx; local ty2=itemY-38
                    local tw=math.max(#hoveredBtn.name*7,#hoveredBtn.desc*6)+20
                    tipBg.Position=Vector2.new(tx2,ty2); tipBg.Size=Vector2.new(tw,36)
                    tipBorder.Position=Vector2.new(tx2,ty2); tipBorder.Size=Vector2.new(tw,36)
                    tipLbl.Position=Vector2.new(tx2+8,ty2+5); tipLbl.Text=hoveredBtn.name
                    tipDesc.Position=Vector2.new(tx2+8,ty2+18); tipDesc.Text=hoveredBtn.desc
                    if not tipIn then tipIn=true; tipOut=false; tipAt=tick()
                        tipBg.Visible=true; tipBorder.Visible=true; tipLbl.Visible=true; tipDesc.Visible=true end
                elseif tipIn then
                    tipIn=false; tipOut=true; tipAt=tick()
                end
            end

            applyFade()

            -- footer labels
            if dWelcome and dNameTxt then
                local fy=uiY+uiH-L.FOOTER+9
                dWelcome.Position=Vector2.new(uiX+42,fy); dNameTxt.Position=Vector2.new(uiX+42+64,fy)
                dWelcome.Visible=menuOpen; dNameTxt.Visible=menuOpen
            end
            if dCharLbl and charFn then
                local nt=charFn(); if dCharLbl.Text~=" | "..nt then dCharLbl.Text=" | "..nt end
            end

            -- dropdown option fade
            for _,b in ipairs(btns) do
                if b.isDD then
                    local mfn=1-(toggledAt-(tick()-FADE))/FADE
                    local mOp=menuOpen and clamp(mfn,0,1) or clamp(1-mfn,0,1)
                    for _,o in ipairs(b.opts) do
                        local diff=o.targetA-o.alpha
                        if math.abs(diff)>0.01 then
                            o.alpha=o.alpha+diff*0.25
                            local vis2=o.alpha>0.02
                            o.bg.Visible=vis2; o.ln.Visible=vis2; o.lb.Visible=vis2
                            o.bg.Transparency=o.alpha*mOp; o.ln.Transparency=o.alpha*mOp; o.lb.Transparency=o.alpha*mOp
                        end
                    end
                end
            end

            -- scroll
            local maxSc=math.max(0,(tabRowY[currentTab] or 0)-contentH()+8)
            if _scroll~=0 and inBox(uiX+L.SIDEBAR,uiY+L.TOPBAR,L.CW,contentH()) then
                tabScroll[currentTab]=clamp((tabScroll[currentTab] or 0)-_scroll*32,0,maxSc); _scroll=0
            end
            -- scrollbar display
            if dScrBg and dScrThumb then
                if maxSc>0 and menuOpen then
                    local sbgY=uiY+L.TOPBAR+2; local sbgH=uiH-L.TOPBAR-L.FOOTER-4
                    local frac=(tabScroll[currentTab] or 0)/maxSc
                    local thumbH=math.max(20,(contentH()/(tabRowY[currentTab] or contentH()))*sbgH)
                    dScrThumb.Size=Vector2.new(4,thumbH)
                    dScrThumb.Position=Vector2.new(uiX+L.W-6, sbgY+frac*(sbgH-thumbH))
                    dScrBg.Visible=true; dScrThumb.Visible=true
                    if clicking and not wasClick then
                        if inBox(uiX+L.W-10,uiY+L.TOPBAR+2,12,sbgH) then
                            scrollDrag=true; scrollDOY=mouse.Y-dScrThumb.Position.Y
                            if not inBox(uiX+L.W-10,dScrThumb.Position.Y,12,thumbH) then
                                scrollDOY=thumbH/2
                                local rf=clamp((mouse.Y-sbgY-thumbH/2)/(sbgH-thumbH),0,1)
                                tabScroll[currentTab]=rf*maxSc
                            end
                        end
                    end
                    if scrollDrag and clicking then
                        local rf=clamp((mouse.Y-sbgY-scrollDOY)/(sbgH-thumbH),0,1)
                        tabScroll[currentTab]=rf*maxSc
                    end
                else
                    dScrBg.Visible=false; dScrThumb.Visible=false
                end
            end
            if not clicking then scrollDrag=false end

            -- animate collapsing buttons
            for _,b in ipairs(btns) do
                if b.cRY~=nil and b.tab==currentTab then
                    if b._collapsing and b._collapseTarget then
                        local diff=b._collapseTarget-b.cRY
                        if math.abs(diff)>0.5 then b.cRY=b.cRY+diff*0.18; bPos(b)
                        else b.cRY=b._collapseTarget; b._collapsing=false; b._collapseTarget=nil; bShow(b,false) end
                    else
                        local diff=b.ry-b.cRY
                        if math.abs(diff)>0.3 then b.cRY=b.cRY+diff*0.15; if show[b.bg] then bPos(b) end
                        elseif b.cRY~=b.ry then b.cRY=b.ry; if show[b.bg] then bPos(b) end end
                    end
                end
            end

            -- UI height animation
            local dt=tick()-lastTick; lastTick=tick()
            if math.abs(uiH-uiHtgt)>2 then
                uiH=uiH+(uiHtgt-uiH)*clamp(dt*12,0,1); updatePos()
                local cB=uiY+uiH-L.FOOTER; local cT=uiY+L.TOPBAR
                for _,b in ipairs(btns) do
                    if b.tab==currentTab then
                        local iy=uiY+(b.cRY or b.ry)-(tabScroll[currentTab] or 0)
                        if iy+b.ch>cB or iy<cT then if show[b.bg] then bShow(b,false) end
                        else if not show[b.bg] then bShow(b,true); bPos(b) end end
                    end
                end
            elseif uiH~=uiHtgt then uiH=uiHtgt; updatePos() end

            -- tab fade cleanup
            if prevTab then
                local tp2=clamp((tick()-tabAt)/TFADE,0,1)
                if tp2>=1 then
                    for _,b in ipairs(btns) do if b.tab==prevTab then bShow(b,false) end end
                    for _,d in ipairs(all) do if fade[d]=="prev" then fade[d]=nil end end
                    prevTab=nil
                end
            end

            -- click handling
            local mfn=1-(toggledAt-(tick()-FADE))/FADE
            local mOp=math.abs((menuOpen and 0 or 1)-clamp(mfn,0,1))
            local handleDrag=false
            if clicking and not wasClick and mOp>0.5 then
                if inBox(uiX,uiY,L.W,uiH) then handleDrag=true end
            end
            if clicking and not wasClick and mOp>0.5 and not isLoading then
                -- minimize dot
                if inBox(uiX+L.W-59,uiY+11,12,12) then
                    handleDrag=false; uiHtgt=L.MINI_H
                    task.spawn(function()
                        while math.abs(uiH-L.MINI_H)>2 and menuOpen do task.wait() end
                        if not menuOpen then return end
                        minimized=true; miniClosed=false; menuOpen=false
                        pcall(function() setrobloxinput(true) end)
                        for _,d in ipairs(all) do d.Visible=false end
                        refreshMini(); showMini(true); updateMiniPos()
                    end)
                -- close dot
                elseif inBox(uiX+L.W-46,uiY+11,12,12) then
                    handleDrag=false; menuOpen=false; toggledAt=tick()
                else
                    -- dropdown option hit
                    local optHit=false
                    if openDD then
                        for i,o in ipairs(openDD.opts) do
                            local ox=uiX+openDD.rx; local oy=uiY+o.ry
                            if inBox(ox,oy,openDD.cw,openDD.ch) then
                                optHit=true; handleDrag=false
                                openDD.selected=i; openDD.valLbl.Text=openDD.options[i]
                                for j,o2 in ipairs(openDD.opts) do
                                    o2.lb.Color=j==i and C.ACCENT or C.WHITE; o2.targetA=0
                                end
                                openDD.open=false; openDD.arrow.Text="v"
                                local prev=openDD; openDD=nil
                                uiHtgt=L.H; recalcLayout(currentTab)
                                if prev.cb then prev.cb(prev.options[i],i) end
                                break
                            end
                        end
                    end
                    if not optHit then
                        -- tab clicks
                        for _,t in ipairs(tabObjs) do
                            if inBox(uiX+7,uiY+t.tY,L.SIDEBAR-14,26) then
                                handleDrag=false; switchTab(t.name)
                            end
                        end
                        -- element clicks
                        for idx,b in ipairs(btns) do
                            if b.tab==currentTab and not b.isSlider and show[b.bg] then
                                local itemY=uiY+(b.cRY or b.ry)-(tabScroll[currentTab] or 0)
                                if inBox(uiX+b.rx,itemY,b.cw,b.ch) then
                                    handleDrag=false
                                    if b.isTog then
                                        b.state=not b.state
                                        if b.cb then pcall(b.cb,b.state) end
                                        pcall(function() notify(b.name.." "..(b.state and "enabled" or "disabled"),nil,2) end)
                                        refreshMini()
                                    elseif b.isAct then
                                        if iKeyBind and idx==iKeyBind and not listenKey then
                                            listenKey=true; btns[iKeyBind].lbl.Text="Press any key..."
                                        elseif b.cb then pcall(b.cb) end
                                    elseif b.isDD then
                                        if openDD and openDD~=b then
                                            openDD.open=false; if openDD.arrow then openDD.arrow.Text="v" end
                                            for _,o in ipairs(openDD.opts) do o.targetA=0 end
                                            uiHtgt=L.H; openDD=nil; recalcLayout(currentTab)
                                        end
                                        b.open=not b.open
                                        b.arrow.Text=b.open and "^" or "v"
                                        openDD=b.open and b or nil
                                        uiHtgt=b.open and (L.H+#b.opts*b.ch) or L.H
                                        if b.open then
                                            local dax=uiX+b.rx; local day=uiY+b.ry
                                            for oi,o in ipairs(b.opts) do
                                                local oy2=day+b.ch+((oi-1)*b.ch)
                                                o.bg.Position=Vector2.new(dax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                                                o.ln.From=Vector2.new(dax,oy2+b.ch); o.ln.To=Vector2.new(dax+b.cw,oy2+b.ch)
                                                o.lb.Position=Vector2.new(dax+14,oy2+b.ch/2-6)
                                                o.ry=b.ry+b.ch+((oi-1)*b.ch)
                                                o.alpha=0; o.targetA=1
                                                vis(o.bg,true); vis(o.ln,true); vis(o.lb,true)
                                            end
                                        end
                                        recalcLayout(currentTab)
                                    elseif b.isColorPicker then
                                        local ax2=uiX+b.rx; local ay2=itemY
                                        local totalW=(#b.swatches*19)-5; local sx0=ax2+b.cw-totalW-10
                                        for j,sw in ipairs(b.swatches) do
                                            local sx=sx0+(j-1)*19; local sy=ay2+b.ch/2-7
                                            if inBox(sx,sy,14,14) then
                                                b.selected=j; b.value=sw.col
                                                for k,sw2 in ipairs(b.swatches) do
                                                    sw2.border.Color=k==j and C.WHITE or C.DIMGRAY
                                                end
                                                if b.cb then pcall(b.cb,sw.col) end; break
                                            end
                                        end
                                    elseif b.isDiv and b.collapsible and b.section then
                                        if openDD then
                                            openDD.open=false; if openDD.arrow then openDD.arrow.Text="v" end
                                            for _,o in ipairs(openDD.opts) do o.targetA=0 end
                                            uiHtgt=L.H; openDD=nil
                                        end
                                        local sec=b.section
                                        _sections[sec]=not _sections[sec]
                                        b.arrow.Text=_sections[sec] and ">" or "v"
                                        recalcLayout(currentTab); break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- slider drag
            for _,b in ipairs(btns) do
                if b.isSlider and b.tab==currentTab and menuOpen then
                    local ax=uiX+b.rx+8
                    local ay=uiY+(b.cRY or b.ry)-(tabScroll[currentTab] or 0)+b.ch-11
                    if clicking and not wasClick then
                        if inBox(uiX+b.rx,uiY+(b.cRY or b.ry)-(tabScroll[currentTab] or 0),b.cw,b.ch) and b.bg.Visible then
                            handleDrag=false; b.dragging=true
                        end
                    end
                    if not clicking and wasClick and b.dragging then
                        local disp=b.isFloat and string.format("%.1f",b.value) or math.floor(b.value)
                        pcall(function() notify(b.baseLbl..": "..disp,nil,2) end)
                    end
                    if not clicking then b.dragging=false end
                    if b.dragging and clicking then
                        local frac=clamp((mouse.X-ax)/b.trkW,0,1)
                        b.value=b.minV+frac*(b.maxV-b.minV)
                        local fx=ax+frac*b.trkW
                        b.fill.To=Vector2.new(fx,ay); b.handle.Position=Vector2.new(fx-4,ay-4)
                        local disp=b.isFloat and string.format("%.1f",b.value) or math.floor(b.value)
                        b.lbl.Text=b.baseLbl..": "..disp
                        if b.cb then pcall(b.cb,b.value) end
                    end
                end
            end

            -- drag window
            if handleDrag then dragging=true; dragOX=mouse.X-uiX; dragOY=mouse.Y-uiY end
            if not clicking then dragging=false end
            if dragging and clicking then
                local vpW,vpH=vp()
                uiX=clamp(mouse.X-dragOX,0,vpW-L.W); uiY=clamp(mouse.Y-dragOY,0,vpH-uiH)
                updatePos()
            end

            -- keybind listen
            if listenKey then
                for k=0x08,0xDD do
                    if iskeypressed(k) and k~=0x01 and k~=0x02 then
                        menuKey=k
                        local n=kname(k)
                        if iKeyInfo then btns[iKeyInfo].lbl.Text="Menu Key: "..n end
                        if iKeyBind then btns[iKeyBind].lbl.Text="Click to Rebind" end
                        dKeyLbl.Text=n; dMiniKeyLbl.Text=n
                        listenKey=false; break
                    end
                end
            end

            wasClick=clicking
            end -- isrbxactive
        end -- while
        end) -- task.spawn
    end -- Init

    -- ── public API ─────────────────────────────────────────────────────────
    win._tabOrder = tabOrder

    function win:Tab(name)
        table.insert(tabOrder,name)
        return getTabAPI(name)
    end

    function win:SettingsTab(destroyCb)
        local s=self:Tab("Settings")
        s:Div("UI")
        s:Dropdown("Theme",{"Check it","Dark","Moon","Grass","Light"},1,function(v) applyTheme(v) end)
        s:Div("KEYBIND")
        iKeyInfo=s:Button("Menu Key: F1",C.ROWBG)
        iKeyBind=s:Button("Click to Rebind",Color3.fromRGB(14,20,40))
        s:Div("DANGER")
        s:Button("Destroy Menu",Color3.fromRGB(28,7,7),destroyCb,Color3.fromRGB(210,55,55))
        return s
    end

    function win:ApplyTheme(name) applyTheme(name) end
    UILib.applyTheme = function(name) applyTheme(name) end

    function win:Destroy()
        destroyed=true
        pcall(function() notify("UI destroyed.", titleA.." "..titleB, 3) end)
        for _,d in ipairs(all) do pcall(function() d:Remove() end) end
        for _,d in ipairs(miniD) do pcall(function() d:Remove() end) end
        for _,l in ipairs(miniLbls) do pcall(function() l:Remove() end) end
        pcall(function() dScrBg:Remove() end); pcall(function() dScrThumb:Remove() end)
        pcall(function() tipBg:Remove() end); pcall(function() tipBorder:Remove() end)
        pcall(function() tipLbl:Remove() end); pcall(function() tipDesc:Remove() end)
        for _,b in ipairs(btns) do
            if b.isLog then for _,l in ipairs(b.lbls) do pcall(function() l:Remove() end) end end
        end
    end

    return win
end

_G.UILib = UILib
print("[UILib] v2.0 loaded")
return UILib
