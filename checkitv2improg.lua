-- ═══════════════════════════════════════════════════════
--  Check it  UI Library  v5.0
--  Matcha-native | ismouse1pressed polling | no goto/continue
-- ═══════════════════════════════════════════════════════
local UILib = {}
local _sectionCollapse = {}

-- ── Themes ────────────────────────────────────────────────
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
        DIV=Color3.fromRGB(22,27,48),       MINIBAR=Color3.fromRGB(11,13,22),
    },
    ["Moon"] = {
        ACCENT=Color3.fromRGB(150,150,165), BG=Color3.fromRGB(12,12,14),
        SIDEBAR=Color3.fromRGB(16,16,18),   CONTENT=Color3.fromRGB(14,14,16),
        TOPBAR=Color3.fromRGB(10,10,12),    BORDER=Color3.fromRGB(40,40,46),
        ROWBG=Color3.fromRGB(18,18,22),     TABSEL=Color3.fromRGB(30,30,36),
        WHITE=Color3.fromRGB(220,220,225),  GRAY=Color3.fromRGB(120,120,130),
        DIMGRAY=Color3.fromRGB(40,40,45),
        ON=Color3.fromRGB(100,100,115),     OFF=Color3.fromRGB(25,25,30),
        ONDOT=Color3.fromRGB(200,200,215),  OFFDOT=Color3.fromRGB(70,70,80),
        DIV=Color3.fromRGB(30,30,36),       MINIBAR=Color3.fromRGB(16,16,20),
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
        DIV=Color3.fromRGB(18,35,24),       MINIBAR=Color3.fromRGB(10,18,13),
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
        DIV=Color3.fromRGB(185,190,215),    MINIBAR=Color3.fromRGB(205,210,228),
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
        DIV=Color3.fromRGB(14,14,18),       MINIBAR=Color3.fromRGB(6,6,8),
    },
}
UILib.Themes = THEMES

-- ── Helpers ───────────────────────────────────────────────
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerpC(a,b,t)
    return Color3.fromRGB(
        math.floor(a.R*255+(b.R*255-a.R*255)*t+0.5),
        math.floor(a.G*255+(b.G*255-a.G*255)*t+0.5),
        math.floor(a.B*255+(b.B*255-a.B*255)*t+0.5))
end
local function getVP()
    local ok,vp=pcall(function() return workspace.CurrentCamera.ViewportSize end)
    if ok and vp then return vp.X,vp.Y end
    return 1920,1080
end

-- key name table
local kn={}
for i=0x41,0x5A do kn[i]=string.char(i) end
for i=0x30,0x39 do kn[i]=tostring(i-0x30) end
for i=0x70,0x7B do kn[i]="F"..(i-0x6F) end
kn[0x20]="Space"; kn[0x09]="Tab"; kn[0x1B]="Esc"; kn[0x0D]="Enter"
local function kname(k) return kn[k] or ("Key"..k) end

-- ── Drawing helpers ───────────────────────────────────────
local function mkSq(x,y,w,h,col,filled,zi,thick)
    local s=Drawing.new("Square")
    s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h)
    s.Color=col; s.Filled=filled~=false; s.Transparency=1
    s.ZIndex=zi or 1; s.Visible=false
    if not(filled~=false) then s.Thickness=thick or 1 end
    return s
end
local function mkTx(txt,x,y,sz,col,ctr,zi,bold)
    local t=Drawing.new("Text")
    t.Text=txt; t.Position=Vector2.new(x,y); t.Size=sz or 13
    t.Color=col; t.Center=ctr or false; t.Outline=false
    t.Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System
    t.Transparency=1; t.ZIndex=zi or 3; t.Visible=false
    return t
end
local function mkLn(x1,y1,x2,y2,col,zi,thick)
    local l=Drawing.new("Line")
    l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2)
    l.Color=col; l.Transparency=1
    l.Thickness=thick or 1; l.ZIndex=zi or 2; l.Visible=false
    return l
end
local function mkTri(x1,y1,x2,y2,x3,y3,col,zi)
    local t=Drawing.new("Triangle")
    t.PointA=Vector2.new(x1,y1); t.PointB=Vector2.new(x2,y2); t.PointC=Vector2.new(x3,y3)
    t.Color=col; t.Filled=true; t.Transparency=1; t.ZIndex=zi or 8; t.Visible=false
    return t
end

-- ── Layout ────────────────────────────────────────────────
local L = {
    W=440, H=400, SIDEBAR=128, TOPBAR=40,
    FOOTER=34, ROW_H=40, ROW_PAD=10,
    TOG_W=34, TOG_H=17, HDL=8, MINI_H=86,
}
L.CONTENT_W = L.W - L.SIDEBAR

-- ══════════════════════════════════════════════════════════
function UILib.Window(titleA, titleB, gameName)
    local win = {}
    gameName = gameName or ""
    local mouse = game.Players.LocalPlayer:GetMouse()
    local lp    = game.Players.LocalPlayer

    -- scroll via mouse events
    local _scrollDelta = 0
    pcall(function() mouse.WheelForward:Connect(function()  _scrollDelta = _scrollDelta - 1 end) end)
    pcall(function() mouse.WheelBackward:Connect(function() _scrollDelta = _scrollDelta + 1 end) end)

    -- live color table (copy of default theme)
    local C = {}
    for k,v in pairs(THEMES["Check it"]) do C[k]=v end

    -- state
    local uiX,uiY      = 300,200
    local destroyed    = false
    local isLoading    = true
    local menuOpen     = true
    local menuKey      = 0x70
    local wasMenuKey   = false
    local wasClicking  = false
    local dragging     = false
    local dragOffX,dragOffY = 0,0
    local listenKey    = false
    local minimized    = false
    local miniClosed   = false
    local miniDragging = false
    local miniDragOX,miniDragOY = 0,0
    local scrollDragging = false
    local scrollDragOffY = 0
    local currentTab   = nil
    local openDropdown = nil
    local iKeyInfo,iKeyBind = nil,nil

    -- drawing lists
    local allDrawings  = {}  -- main menu drawings
    local miniDrawings = {}  -- mini bar drawings
    local showSet      = {}  -- d -> true if should be visible
    local tabSet       = {}  -- d -> "next"|"prev"|nil  for tab fade
    local baseUI       = {}  -- chrome drawings always shown

    local tabObjs      = {}
    local btns         = {}
    local tabAPI       = {}
    local tabRowY      = {}
    local tabScroll    = {}
    local tabOrder     = {}

    -- mini active labels
    local MAX_MINI = 12
    local miniLbls = {}
    for i=1,MAX_MINI do
        local lb=mkTx("",0,0,13,C.WHITE,false,9,false)
        lb.Outline=true; lb.Visible=false; lb.Transparency=1
        table.insert(miniLbls,lb)
    end

    -- ── drawing registration ──────────────────────────────
    local function mkD(d)
        table.insert(allDrawings,d)
        d.Visible=false
        return d
    end
    local function mkBase(d)
        table.insert(allDrawings,d)
        table.insert(baseUI,d)
        d.Visible=false
        return d
    end
    local function mkMini(d)
        table.insert(miniDrawings,d)
        d.Visible=false
        return d
    end
    local function setShow(d,yes)
        showSet[d] = yes or nil
        d.Visible  = yes and true or false
    end
    local function inBox(x,y,w,h)
        return mouse.X>=x and mouse.X<x+w and mouse.Y>=y and mouse.Y<y+h
    end

    -- ── visibility pass ───────────────────────────────────
    local function applyShow()
        if isLoading then
            for _,d in ipairs(allDrawings)  do d.Visible=false end
            for _,d in ipairs(miniDrawings) do d.Visible=false end
            for _,l in ipairs(miniLbls)     do l.Visible=false end
            return
        end
        if minimized then
            for _,d in ipairs(allDrawings) do d.Visible=false end
            return
        end
        for _,l in ipairs(miniLbls) do l.Visible=false end
        if not menuOpen then
            for _,d in ipairs(allDrawings) do d.Visible=false end
            return
        end
        for _,d in ipairs(allDrawings) do
            d.Visible = showSet[d] and true or false
            d.Transparency = 1
        end
    end

    -- ── bShow / bPos ──────────────────────────────────────
    local function bShow(b,yes)
        setShow(b.bg,yes)
        if b.out    then setShow(b.out,yes)    end
        if b.lbl and not b.isLog then setShow(b.lbl,yes) end
        if b.ln     then setShow(b.ln,yes)     end
        if b.tog    then setShow(b.tog,yes)    end
        if b.dot    then setShow(b.dot,yes)    end
        if b.track  then setShow(b.track,yes)  end
        if b.fill   then setShow(b.fill,yes)   end
        if b.handle then setShow(b.handle,yes) end
        if b.dlb    then setShow(b.dlb,yes)    end
        if b.qbg    then setShow(b.qbg,yes)    end
        if b.qlb    then setShow(b.qlb,yes)    end
        if b.arrow  then setShow(b.arrow,yes)  end
        if b.valLbl then setShow(b.valLbl,yes) end
        if b.lbls   then for _,l in ipairs(b.lbls) do setShow(l,yes) end end
        if b.swatches then
            for _,sw in ipairs(b.swatches) do setShow(sw.sq,yes); setShow(sw.border,yes) end
        end
        if b.isDropdown then
            for _,o in ipairs(b.optBgs) do
                local ov = yes and b.open
                setShow(o.bg,ov); setShow(o.ln,ov); setShow(o.lb,ov)
            end
        end
    end

    local function bPos(b)
        local sc = tabScroll[b.tab] or 0
        local ax = uiX + b.rx
        local ay = uiY + b.ry - sc
        b.bg.Position = Vector2.new(ax,ay)
        if b.out then b.out.Position = Vector2.new(ax,ay) end

        if b.isLog then
            for i,lb in ipairs(b.lbls) do
                if b.starFirst and i==1 then
                    lb.Position = Vector2.new(ax+b.cw/2, ay+b.pad)
                else
                    local off = b.starFirst and (b.starH+b.pad+(i-2)*b.lineH) or (b.pad+(i-1)*b.lineH)
                    lb.Position = Vector2.new(ax+8, ay+off)
                end
            end
            return
        end

        if b.isDiv then
            b.lbl.Position = Vector2.new(ax+6, ay)
            if b.ln then b.ln.From=Vector2.new(ax,ay+13); b.ln.To=Vector2.new(ax+b.cw,ay+13) end
            if b.arrow then b.arrow.PointA=Vector2.new(ax+b.cw-9,ay+4); b.arrow.PointB=Vector2.new(ax+b.cw-5,ay+4); b.arrow.PointC=Vector2.new(ax+b.cw-7,ay+9) end
            return
        end

        if b.isSlider then
            b.lbl.Position = Vector2.new(ax+8, ay+7)
            if b.dlb then b.dlb.Position = Vector2.new(ax+8, ay+21) end
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            local ty = ay+b.ch-11
            b.track.From=Vector2.new(ax+8,ty); b.track.To=Vector2.new(ax+8+b.trackW,ty)
            local frac = (b.value-b.minV)/(b.maxV-b.minV)
            local fx = ax+8+frac*b.trackW
            b.fill.From=Vector2.new(ax+8,ty); b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
            return
        end

        if b.isDropdown then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.valLbl.Position=Vector2.new(ax+b.cw-62,ay+b.ch/2-6)
            if b.arrow then b.arrow.PointA=Vector2.new(ax+b.cw-9,ay+b.ch/2-3); b.arrow.PointB=Vector2.new(ax+b.cw-5,ay+b.ch/2-3); b.arrow.PointC=Vector2.new(ax+b.cw-7,ay+b.ch/2+3) end
            for i,o in ipairs(b.optBgs) do
                local oy = uiY+b.ry-sc+b.ch+((i-1)*b.ch)
                o.bg.Position=Vector2.new(ax,oy); o.bg.Size=Vector2.new(b.cw,b.ch)
                o.ln.From=Vector2.new(ax,oy+b.ch); o.ln.To=Vector2.new(ax+b.cw,oy+b.ch)
                o.lb.Position=Vector2.new(ax+12,oy+b.ch/2-6)
                o.ry = b.ry+b.ch+((i-1)*b.ch)
            end
            return
        end

        if b.isAct then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+b.cw/2,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            return
        end

        if b.isColorPicker then
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            local totalW=(#b.swatches*19)-5
            local startX=ax+b.cw-totalW-10
            for i,sw in ipairs(b.swatches) do
                local sx=startX+(i-1)*19; local sy=ay+b.ch/2-7
                sw.sq.Position=Vector2.new(sx,sy); sw.border.Position=Vector2.new(sx-1,sy-1)
                sw.x=sx; sw.y=sy
            end
            return
        end

        -- toggle
        b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
        if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
        if b.tog then
            local dox=b.rx+b.cw-L.TOG_W-8
            b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-L.TOG_H/2)
            b.dot.Position=Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt,ay+b.ch/2-L.TOG_H/2+2)
        end
        if b.qbg then
            local dox2=b.rx+b.cw-L.TOG_W-8
            local qx=uiX+dox2-22; local qy=ay+b.ch/2-7
            b.qbg.Position=Vector2.new(qx,qy)
            if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+2) end
        end
    end

    -- ── layout / scroll ───────────────────────────────────
    local function CONTENT_H() return L.H - L.TOPBAR - L.FOOTER end

    local recalcLayout
    recalcLayout = function(tname)
        local cy = 10
        for _,b in ipairs(btns) do
            if b.tab == tname then
                if b.isDiv then
                    b.ry = L.TOPBAR + cy
                    bShow(b,true)
                    cy = cy + b.ch + 10
                else
                    local collapsed = b.section and _sectionCollapse[b.section]
                    if collapsed then
                        bShow(b,false)
                    else
                        b.ry = L.TOPBAR + cy
                        bShow(b,true)
                        bPos(b)
                        cy = cy + b.ch + 8
                        if b.isDropdown and b.open then
                            cy = cy + (#b.options * b.ch)
                        end
                    end
                end
            end
        end
        local lastY = 0
        for _,b in ipairs(btns) do
            if b.tab==tname and showSet[b.bg] then
                local bot = b.ry + b.ch
                if bot > lastY then lastY = bot end
            end
        end
        tabRowY[tname] = lastY + 36
        local maxSc = math.max(0,(tabRowY[tname] or 0)-CONTENT_H()+8)
        tabScroll[tname] = clamp(tabScroll[tname] or 0,0,maxSc)
    end

    local function doScroll(delta)
        if not currentTab then return end
        local maxSc = math.max(0,(tabRowY[currentTab] or 0)-CONTENT_H()+8)
        tabScroll[currentTab] = clamp((tabScroll[currentTab] or 0)+delta, 0, maxSc)
        for _,b in ipairs(btns) do
            if b.tab==currentTab then bPos(b) end
        end
    end

    -- ── chrome drawings (forward declared) ────────────────
    local dShadow,dMainBg,dGlow1,dGlow2,dBorder
    local dTopBar,dTopLine
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dDotY,dDotR
    local dSide,dSideLn,dContent,dFooter,dFotLine
    local dWelcome,dName,dCharLbl
    local dScrollBg,dScrollThumb
    -- mini
    local dMShadow,dMBg,dMGlow1,dMGlow2,dMBorder
    local dMTop,dMLine,dMActBg
    local dMTitleW,dMTitleA,dMTitleG,dMKeyLbl,dMDotY,dMDotR

    -- ── updatePos ─────────────────────────────────────────
    local function updatePos()
        dShadow.Position  = Vector2.new(uiX-2,uiY-2);    dShadow.Size    = Vector2.new(L.W+4,L.H+4)
        dMainBg.Position  = Vector2.new(uiX,uiY);         dMainBg.Size    = Vector2.new(L.W,L.H)
        dBorder.Position  = Vector2.new(uiX,uiY);         dBorder.Size    = Vector2.new(L.W,L.H)
        dGlow1.Position   = Vector2.new(uiX-1,uiY-1);    dGlow1.Size     = Vector2.new(L.W+2,L.H+2)
        dGlow2.Position   = Vector2.new(uiX-2,uiY-2);    dGlow2.Size     = Vector2.new(L.W+4,L.H+4)
        dTopBar.Position  = Vector2.new(uiX+1,uiY+1);    dTopBar.Size    = Vector2.new(L.W-2,L.TOPBAR)
        dTopLine.From     = Vector2.new(uiX+1,uiY+L.TOPBAR); dTopLine.To = Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dTitleW.Position  = Vector2.new(uiX+14,uiY+12)
        dTitleA.Position  = Vector2.new(uiX+14+#titleA*8+3,uiY+12)
        dTitleG.Position  = Vector2.new(uiX+14+#titleA*8+3+#titleB*8+10,uiY+12)
        dKeyLbl.Position  = Vector2.new(uiX+L.W-22,uiY+14)
        dDotY.Position    = Vector2.new(uiX+L.W-55,uiY+15)
        dDotR.Position    = Vector2.new(uiX+L.W-42,uiY+15)
        dSide.Position    = Vector2.new(uiX+1,uiY+L.TOPBAR);    dSide.Size    = Vector2.new(L.SIDEBAR-1,L.H-L.TOPBAR-L.FOOTER-1)
        dSideLn.From      = Vector2.new(uiX+L.SIDEBAR,uiY+L.TOPBAR); dSideLn.To = Vector2.new(uiX+L.SIDEBAR,uiY+L.H-L.FOOTER)
        dContent.Position = Vector2.new(uiX+L.SIDEBAR,uiY+L.TOPBAR); dContent.Size = Vector2.new(L.CONTENT_W-1,L.H-L.TOPBAR-L.FOOTER-1)
        dFooter.Position  = Vector2.new(uiX+1,uiY+L.H-L.FOOTER); dFooter.Size = Vector2.new(L.W-2,L.FOOTER-1)
        dFotLine.From     = Vector2.new(uiX+1,uiY+L.H-L.FOOTER); dFotLine.To = Vector2.new(uiX+L.W-1,uiY+L.H-L.FOOTER)
        dWelcome.Position = Vector2.new(uiX+14,uiY+L.H-L.FOOTER+10)
        dName.Position    = Vector2.new(uiX+80,uiY+L.H-L.FOOTER+10)
        dCharLbl.Position = Vector2.new(uiX+80+#lp.Name*7+4,uiY+L.H-L.FOOTER+10)
        dScrollBg.Position = Vector2.new(uiX+L.W-6,uiY+L.TOPBAR+2); dScrollBg.Size = Vector2.new(4,L.H-L.TOPBAR-L.FOOTER-4)
        for _,t in ipairs(tabObjs) do
            t.bg.Position  = Vector2.new(uiX+7,uiY+t.relTY)
            t.acc.Position = Vector2.new(uiX+7,uiY+t.relTY)
            t.lbl.Position = Vector2.new(uiX+18,uiY+t.relTY+7)
            t.lblG.Position= Vector2.new(uiX+18,uiY+t.relTY+7)
        end
        for _,b in ipairs(btns) do
            if showSet[b.bg] then bPos(b) end
        end
    end

    local function updateMiniPos()
        dMShadow.Position = Vector2.new(uiX-2,uiY-2); dMShadow.Size = Vector2.new(L.W+4,L.MINI_H+4)
        dMBg.Position     = Vector2.new(uiX,uiY);     dMBg.Size     = Vector2.new(L.W,L.MINI_H)
        dMBorder.Position = Vector2.new(uiX,uiY);     dMBorder.Size = Vector2.new(L.W,L.MINI_H)
        dMGlow1.Position  = Vector2.new(uiX-1,uiY-1); dMGlow1.Size  = Vector2.new(L.W+2,L.MINI_H+2)
        dMGlow2.Position  = Vector2.new(uiX-2,uiY-2); dMGlow2.Size  = Vector2.new(L.W+4,L.MINI_H+4)
        dMTop.Position    = Vector2.new(uiX+1,uiY+1); dMTop.Size    = Vector2.new(L.W-2,L.TOPBAR)
        dMLine.From       = Vector2.new(uiX+1,uiY+L.TOPBAR); dMLine.To = Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dMActBg.Position  = Vector2.new(uiX+1,uiY+L.TOPBAR); dMActBg.Size = Vector2.new(L.W-2,L.MINI_H-L.TOPBAR-1)
        dMTitleW.Position = Vector2.new(uiX+14,uiY+12)
        dMTitleA.Position = Vector2.new(uiX+14+#titleA*8+3,uiY+12)
        dMTitleG.Position = Vector2.new(uiX+14+#titleA*8+3+#titleB*8+10,uiY+12)
        dMKeyLbl.Position = Vector2.new(uiX+L.W-22,uiY+14)
        dMDotY.Position   = Vector2.new(uiX+L.W-55,uiY+15)
        dMDotR.Position   = Vector2.new(uiX+L.W-42,uiY+15)
        -- mini labels
        local cx=uiX+10; local r1=uiY+L.TOPBAR+6; local r2=r1+18; local row=1
        for _,lb in ipairs(miniLbls) do
            if lb.Visible and lb.Text~="" then
                local w=#lb.Text*7
                if cx+w>uiX+L.W-10 then
                    if row==1 then row=2; cx=uiX+10 else break end
                end
                lb.Position=Vector2.new(cx, row==1 and r1 or r2); cx=cx+w+12
            end
        end
    end

    -- ── tab switch ────────────────────────────────────────
    local function switchTab(name)
        if name==currentTab then return end
        if openDropdown then
            openDropdown.open=false
            for _,o in ipairs(openDropdown.optBgs) do setShow(o.bg,false); setShow(o.ln,false); setShow(o.lb,false) end
            openDropdown=nil
        end
        if currentTab then
            for _,b in ipairs(btns) do if b.tab==currentTab then bShow(b,false) end end
        end
        currentTab=name
        for _,t in ipairs(tabObjs) do
            t.sel=(t.name==name)
            setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel)
            t.bg.Color  = t.sel and C.TABSEL or C.SIDEBAR
            t.acc.Color = t.sel and C.ACCENT or C.SIDEBAR
        end
        recalcLayout(name)
        applyShow()
    end

    -- ── mini labels ───────────────────────────────────────
    local function refreshMiniLbls()
        local active={}
        for _,b in ipairs(btns) do
            if b.isTog and b.state then table.insert(active,b.toggleName) end
        end
        if #active==0 then
            miniLbls[1].Text="no active toggles"
            miniLbls[1].Visible=minimized
            for i=2,MAX_MINI do miniLbls[i].Text=""; miniLbls[i].Visible=false end
            return
        end
        for i,lb in ipairs(miniLbls) do
            lb.Text=active[i] or ""
            lb.Visible=minimized and lb.Text~=""
        end
        if minimized then updateMiniPos() end
    end

    -- ── mini show/hide ────────────────────────────────────
    local function showMiniUI(yes)
        for _,d in ipairs(miniDrawings) do d.Visible=yes; d.Transparency=1 end
        for _,l in ipairs(miniLbls) do l.Visible = yes and l.Text~="" end
    end

    -- ── applyTheme ────────────────────────────────────────
    local function applyTheme(name)
        local t=THEMES[name]; if not t then return end
        for k,v in pairs(t) do C[k]=v end
        if not dMainBg then return end
        dMainBg.Color=C.BG;    dTopBar.Color=C.TOPBAR; dSide.Color=C.SIDEBAR
        dContent.Color=C.CONTENT; dFooter.Color=C.TOPBAR; dBorder.Color=C.BORDER
        dTopLine.Color=C.BORDER; dSideLn.Color=C.BORDER; dFotLine.Color=C.BORDER
        dGlow1.Color=C.ACCENT; dGlow2.Color=C.ACCENT
        dScrollBg.Color=Color3.fromRGB(18,20,28); dScrollThumb.Color=C.ACCENT
        dTitleA.Color=C.ACCENT; dTitleW.Color=C.WHITE; dKeyLbl.Color=C.GRAY
        dMBg.Color=C.BG; dMTop.Color=C.TOPBAR; dMBorder.Color=C.BORDER
        dMGlow1.Color=C.ACCENT; dMGlow2.Color=C.ACCENT; dMActBg.Color=C.MINIBAR
        dMTitleW.Color=C.WHITE; dMTitleA.Color=C.ACCENT; dMKeyLbl.Color=C.GRAY
        dMLine.Color=C.BORDER
        for _,t in ipairs(tabObjs) do
            t.bg.Color  = t.sel and C.TABSEL or C.SIDEBAR
            t.acc.Color = t.sel and C.ACCENT or C.SIDEBAR
            t.lbl.Color =C.WHITE; t.lblG.Color=C.GRAY
        end
        for _,b in ipairs(btns) do
            if b.ln  then b.ln.Color=C.DIV end
            if b.isTog then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
                b.tog.Color=b.state and C.ON or C.OFF
                b.dot.Color=b.state and C.ONDOT or C.OFFDOT
            elseif b.isSlider then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
                b.track.Color=C.DIMGRAY; b.fill.Color=C.ACCENT
                if b.dlb then b.dlb.Color=C.GRAY end
            elseif b.isAct then
                if not b.customCol then b.bg.Color=C.ROWBG end
            elseif b.isDiv then
                b.lbl.Color=C.GRAY
            elseif b.isDropdown then
                b.lbl.Color=C.WHITE; b.valLbl.Color=C.ACCENT
                for j,o in ipairs(b.optBgs) do
                    o.bg.Color=C.ROWBG; o.ln.Color=C.DIV
                    o.lb.Color=j==b.selected and C.ACCENT or C.WHITE
                end
            elseif b.isColorPicker then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
            end
        end
    end

    -- ══════════════════════════════════════════════════════
    -- Element builders
    -- ══════════════════════════════════════════════════════
    local function addToggle(tab,lbl,relY,init,cb,desc)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local ox=rx+cw-L.TOG_W-8
        local bg  = mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3))
        local dl  = mkD(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4))
        local lb  = mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local tog = mkD(mkSq(uiX+ox,uiY+ry+ch/2-L.TOG_H/2,L.TOG_W,L.TOG_H,init and C.ON or C.OFF,true,4))
        local dot = mkD(mkSq(uiX+ox+(init and L.TOG_W-L.TOG_H+2 or 2),uiY+ry+ch/2-L.TOG_H/2+2,L.TOG_H-4,L.TOG_H-4,init and C.ONDOT or C.OFFDOT,true,5))
        local qbg,qlb
        if desc then
            local qx=uiX+ox-22; local qy=uiY+ry+ch/2-7
            qbg=mkD(mkSq(qx,qy,14,14,C.DIMGRAY,true,6))
            qlb=mkD(mkTx("?",qx+7,qy+2,9,C.GRAY,true,7,true))
        end
        local b={tab=tab,isTog=true,state=init or false,bg=bg,lbl=lb,ln=dl,tog=tog,dot=dot,qbg=qbg,qlb=qlb,
                 rx=rx,ry=ry,cw=cw,ch=ch,lt=init and 1 or 0,cb=cb,toggleName=lbl,desc=desc}
        table.insert(btns,b); return #btns
    end

    local function addDiv(tab,lbl,relY,collapsible)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2
        local lb  = mkD(mkTx(lbl,uiX+rx+6,uiY+ry,9,C.GRAY,false,8))
        local dl  = mkD(mkLn(uiX+rx,uiY+ry+13,uiX+rx+cw,uiY+ry+13,C.DIV,4))
        local arrow
        if collapsible then
            -- use triangle as arrow indicator
            arrow = mkD(mkTri(uiX+rx+cw-9,uiY+ry+4,uiX+rx+cw-5,uiY+ry+4,uiX+rx+cw-7,uiY+ry+9,C.GRAY,8))
            if _sectionCollapse[lbl]==nil then _sectionCollapse[lbl]=false end
        end
        local b={tab=tab,isDiv=true,bg=lb,lbl=lb,ln=dl,arrow=arrow,
                 rx=rx,ry=ry,cw=cw,ch=14,collapsible=collapsible,sectionName=lbl}
        table.insert(btns,b); return #btns
    end

    local function addSlider(tab,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H+6
        local trackW=cw-16
        local disp=isFloat and string.format("%.1f",initV) or tostring(math.floor(initV))
        local frac=(initV-minV)/(maxV-minV); local fx=uiX+rx+8+frac*trackW
        local ty=uiY+ry+ch-11
        local bg  = mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3))
        local dl  = mkD(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4))
        local lb  = mkD(mkTx(lbl..": "..disp,uiX+rx+8,uiY+ry+7,12,C.WHITE,false,8))
        local dlb = desc and mkD(mkTx(desc,uiX+rx+8,uiY+ry+21,9,C.GRAY,false,8)) or nil
        local trk = mkD(mkLn(uiX+rx+8,ty,uiX+rx+8+trackW,ty,C.DIMGRAY,5,3))
        local fil = mkD(mkLn(uiX+rx+8,ty,fx,ty,C.ACCENT,6,3))
        local hdl = mkD(mkSq(fx-4,ty-4,L.HDL,L.HDL,C.WHITE,true,7))
        local b={tab=tab,isSlider=true,bg=bg,lbl=lb,ln=dl,track=trk,fill=fil,handle=hdl,dlb=dlb,
                 rx=rx,ry=ry,cw=cw,ch=ch,trackW=trackW,minV=minV,maxV=maxV,value=initV,
                 baseLbl=lbl,dragging=false,cb=cb,isFloat=isFloat or false}
        table.insert(btns,b); return #btns
    end

    local function addAct(tab,lbl,relY,col,cb,lblCol)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local outBg=col or C.ROWBG
        local outC=Color3.new(math.min(1,outBg.R*1.6),math.min(1,outBg.G*1.6),math.min(1,outBg.B*1.6))
        local out= mkD(mkSq(uiX+rx,uiY+ry,cw,ch,outC,true,3))
        local bg = mkD(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,col or C.ROWBG,true,4))
        local lb = mkD(mkTx(lbl,uiX+rx+cw/2,uiY+ry+ch/2-6,12,lblCol or C.WHITE,true,8))
        local b={tab=tab,isAct=true,customCol=col~=nil,out=out,bg=bg,lbl=lb,
                 rx=rx,ry=ry,cw=cw,ch=ch,cb=cb}
        table.insert(btns,b); return #btns
    end

    local function addDropdown(tab,lbl,relY,options,initIdx,cb)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local outBg=C.ROWBG
        local outC=Color3.new(math.min(1,outBg.R*1.6),math.min(1,outBg.G*1.6),math.min(1,outBg.B*1.6))
        local out = mkD(mkSq(uiX+rx,uiY+ry,cw,ch,outC,true,3))
        local bg  = mkD(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROWBG,true,4))
        local lb  = mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local vi  = initIdx or 1
        local val = mkD(mkTx(options[vi] or "",uiX+rx+cw-62,uiY+ry+ch/2-6,11,C.ACCENT,false,8))
        local arr = mkD(mkTri(uiX+rx+cw-9,uiY+ry+ch/2-3,uiX+rx+cw-5,uiY+ry+ch/2-3,uiX+rx+cw-7,uiY+ry+ch/2+3,C.GRAY,8))
        local optBgs={}
        for i,opt in ipairs(options) do
            local oy=ry+ch+((i-1)*ch)
            local obg=mkD(mkSq(uiX+rx,uiY+oy,cw,ch,C.ROWBG,true,10))
            local oln=mkD(mkLn(uiX+rx,uiY+oy+ch,uiX+rx+cw,uiY+oy+ch,C.DIV,11))
            local olb=mkD(mkTx(opt,uiX+rx+12,uiY+oy+ch/2-6,11,i==vi and C.ACCENT or C.WHITE,false,11))
            obg.Visible=false; oln.Visible=false; olb.Visible=false
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,ry=oy})
        end
        local b={tab=tab,isDropdown=true,out=out,bg=bg,lbl=lb,valLbl=val,arrow=arr,optBgs=optBgs,
                 rx=rx,ry=ry,cw=cw,ch=ch,options=options,selected=vi,open=false,cb=cb}
        table.insert(btns,b); return #btns
    end

    local function addColorPicker(tab,lbl,relY,initCol,cb)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2; local ch=L.ROW_H-2
        local bg = mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3))
        local dl = mkD(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4))
        local lb = mkD(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local cols={Color3.fromRGB(70,120,255),Color3.fromRGB(210,55,55),Color3.fromRGB(45,190,95),
                    Color3.fromRGB(255,175,80),Color3.fromRGB(180,80,255),Color3.fromRGB(215,220,240)}
        local totalW=(#cols*19)-5; local startX=uiX+rx+cw-totalW-10
        local sws={}
        for i,col in ipairs(cols) do
            local sx=startX+(i-1)*19; local sy=uiY+ry+ch/2-7
            local s=mkD(mkSq(sx,sy,14,14,col,true,6))
            local border=mkD(mkSq(sx-1,sy-1,16,16,i==1 and C.WHITE or C.BORDER,false,7,1))
            table.insert(sws,{sq=s,border=border,col=col,x=sx,y=sy})
        end
        local b={tab=tab,isColorPicker=true,bg=bg,lbl=lb,ln=dl,swatches=sws,
                 rx=rx,ry=ry,cw=cw,ch=ch,selected=1,value=cols[1],cb=cb}
        table.insert(btns,b); return #btns
    end

    local function addLog(tab,lines,relY,starFirst)
        local rx=L.SIDEBAR+L.ROW_PAD; local ry=L.TOPBAR+relY
        local cw=L.CONTENT_W-L.ROW_PAD*2
        local lineH=18; local starH=starFirst and 26 or 0; local pad=10
        local ch=starH+(#lines-(starFirst and 1 or 0))*lineH+pad*2
        local bg=mkD(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3))
        local lbls={}
        for i,line in ipairs(lines) do
            local lb=mkD(Drawing.new("Text"))
            if starFirst and i==1 then
                lb.Text=line; lb.Position=Vector2.new(uiX+rx+cw/2,uiY+ry+pad)
                lb.Size=14; lb.Color=Color3.fromRGB(255,200,40); lb.Center=true
                lb.Outline=true; lb.Font=Drawing.Fonts.Minecraft
            else
                local off=starFirst and (starH+pad+(i-2)*lineH) or (pad+(i-1)*lineH)
                lb.Text=line; lb.Position=Vector2.new(uiX+rx+8,uiY+ry+off)
                lb.Size=11; lb.Color=C.WHITE; lb.Outline=false; lb.Font=Drawing.Fonts.Minecraft
            end
            lb.Transparency=1; lb.ZIndex=8; lb.Visible=false
            table.insert(lbls,lb)
        end
        local b={tab=tab,isLog=true,bg=bg,lbl=bg,lbls=lbls,
                 rx=rx,ry=ry,cw=cw,ch=ch,lineH=lineH,pad=pad,starFirst=starFirst,starH=starH}
        table.insert(btns,b); return #btns
    end

    -- ── tab API factory ───────────────────────────────────
    local function getTabAPI(tabName)
        if tabAPI[tabName] then return tabAPI[tabName] end
        tabRowY[tabName]=10; tabScroll[tabName]=0
        local api={}
        local curSection=nil
        local function nextY(h) local y=tabRowY[tabName]; tabRowY[tabName]=y+h; return y end
        local function tag(idx) if curSection and btns[idx] then btns[idx].section=curSection end end

        function api:Div(lbl,collapsible)
            if collapsible==nil then collapsible=true end
            local idx=addDiv(tabName,lbl,nextY(22),collapsible)
            curSection = collapsible and lbl or nil
        end
        function api:Toggle(lbl,init,cb,desc)
            tag(addToggle(tabName,lbl,nextY(L.ROW_H+4),init,cb,desc))
        end
        function api:Slider(lbl,mn,mx,iv,cb,fl,desc)
            tag(addSlider(tabName,lbl,nextY(L.ROW_H+10),mn,mx,iv,cb,fl,desc))
        end
        function api:Button(lbl,col,cb,lc)
            local idx=addAct(tabName,lbl,nextY(L.ROW_H+4),col,cb,lc)
            tag(idx); return idx
        end
        function api:Dropdown(lbl,opts,ii,cb)
            tag(addDropdown(tabName,lbl,nextY(L.ROW_H+4),opts,ii,cb))
        end
        function api:ColorPicker(lbl,ic,cb)
            tag(addColorPicker(tabName,lbl,nextY(L.ROW_H+4),ic,cb))
        end
        function api:Log(lines,sf)
            local lineH=18; local starH=sf and 26 or 0
            local h=starH+(#lines-(sf and 1 or 0))*lineH+20+6
            local idx=addLog(tabName,lines,nextY(h),sf); tag(idx)
            local la={}
            function la:SetLines(nl)
                if not btns[idx] then return end
                for i,l in ipairs(btns[idx].lbls) do
                    l.Text=nl[i] or ""; l.Visible=nl[i]~=nil and showSet[btns[idx].bg] and true or false
                end
            end
            return la
        end
        tabAPI[tabName]=api; return api
    end

    -- ══════════════════════════════════════════════════════
    function win:Tab(name)
        table.insert(tabOrder,name); return getTabAPI(name)
    end

    function win:SettingsTab(destroyCb)
        local s=self:Tab("Settings")
        s:Div("UI",false)
        s:Dropdown("Theme",{"Check it","Dark","Moon","Grass","Light"},1,function(v) applyTheme(v) end)
        s:Div("Keybind",false)
        iKeyInfo = s:Button("Menu Key: F1",nil,nil)
        iKeyBind = s:Button("Click to Rebind",Color3.fromRGB(14,20,40),nil)
        s:Div("Danger",false)
        s:Button("Destroy Menu",Color3.fromRGB(28,7,7),destroyCb,Color3.fromRGB(210,55,55))
        return s
    end

    function win:ApplyTheme(name) applyTheme(name) end

    function win:Destroy()
        destroyed=true
        for _,d in ipairs(allDrawings)  do pcall(function() d:Remove() end) end
        for _,d in ipairs(miniDrawings) do pcall(function() d:Remove() end) end
        for _,l in ipairs(miniLbls)     do pcall(function() l:Remove() end) end
    end

    -- ══════════════════════════════════════════════════════
    function win:Init(defaultTab, charLabelFn)

        -- ── build chrome ──────────────────────────────────
        dShadow  = mkBase(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,Color3.fromRGB(0,0,4),true,0))
        dMainBg  = mkBase(mkSq(uiX,uiY,L.W,L.H,C.BG,true,1))
        dGlow1   = mkBase(mkSq(uiX-1,uiY-1,L.W+2,L.H+2,C.ACCENT,false,1,1)); dGlow1.Transparency=0.85
        dGlow2   = mkBase(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,C.ACCENT,false,0,2)); dGlow2.Transparency=0.3
        dBorder  = mkBase(mkSq(uiX,uiY,L.W,L.H,C.BORDER,false,3,1)); dBorder.Transparency=0.25
        dTopBar  = mkBase(mkSq(uiX+1,uiY+1,L.W-2,L.TOPBAR,C.TOPBAR,true,3))
        dTopLine = mkBase(mkLn(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4))
        dTitleW  = mkBase(mkTx(titleA,uiX+14,uiY+12,14,C.WHITE,false,9,true))
        dTitleA  = mkBase(mkTx(titleB,uiX+14+#titleA*8+3,uiY+12,14,C.ACCENT,false,9,true))
        dTitleG  = mkBase(mkTx(gameName,uiX+14+#titleA*8+3+#titleB*8+10,uiY+12,13,Color3.fromRGB(255,175,80),false,9))
        dKeyLbl  = mkBase(mkTx("F1",uiX+L.W-22,uiY+14,11,C.GRAY,false,9))
        dDotY    = mkBase(mkSq(uiX+L.W-55,uiY+15,8,8,Color3.fromRGB(190,148,0),true,9))
        dDotR    = mkBase(mkSq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9))
        dSide    = mkBase(mkSq(uiX+1,uiY+L.TOPBAR,L.SIDEBAR-1,L.H-L.TOPBAR-L.FOOTER-1,C.SIDEBAR,true,2))
        dSideLn  = mkBase(mkLn(uiX+L.SIDEBAR,uiY+L.TOPBAR,uiX+L.SIDEBAR,uiY+L.H-L.FOOTER,C.BORDER,4))
        dContent = mkBase(mkSq(uiX+L.SIDEBAR,uiY+L.TOPBAR,L.CONTENT_W-1,L.H-L.TOPBAR-L.FOOTER-1,C.CONTENT,true,2))
        dFooter  = mkBase(mkSq(uiX+1,uiY+L.H-L.FOOTER,L.W-2,L.FOOTER-1,C.TOPBAR,true,3))
        dFotLine = mkBase(mkLn(uiX+1,uiY+L.H-L.FOOTER,uiX+L.W-1,uiY+L.H-L.FOOTER,C.BORDER,4))
        dWelcome = mkBase(mkTx("welcome,",uiX+14,uiY+L.H-L.FOOTER+10,11,C.WHITE,false,9))
        dName    = mkBase(mkTx(lp.Name,uiX+80,uiY+L.H-L.FOOTER+10,11,Color3.fromRGB(45,190,95),false,9,true))
        dCharLbl = mkBase(mkTx("",uiX+80+#lp.Name*7+4,uiY+L.H-L.FOOTER+10,11,C.GRAY,false,9))
        dScrollBg    = mkBase(mkSq(uiX+L.W-6,uiY+L.TOPBAR+2,4,L.H-L.TOPBAR-L.FOOTER-4,Color3.fromRGB(18,20,28),true,4))
        dScrollThumb = mkBase(mkSq(uiX+L.W-6,uiY+L.TOPBAR+2,4,20,C.ACCENT,true,5))

        -- sidebar tab buttons
        for i,name in ipairs(tabOrder) do
            local tY=L.TOPBAR+8+(i-1)*34
            local sel=(name==defaultTab)
            local tbg  = mkBase(mkSq(uiX+7,uiY+tY,L.SIDEBAR-14,26,sel and C.TABSEL or C.SIDEBAR,true,3))
            local tacc = mkBase(mkSq(uiX+7,uiY+tY,3,26,sel and C.ACCENT or C.SIDEBAR,true,4))
            local tlW  = mkBase(mkTx(name,uiX+18,uiY+tY+7,11,C.WHITE,false,8))
            local tlG  = mkBase(mkTx(name,uiX+18,uiY+tY+7,11,C.GRAY,false,8))
            tlW.Visible=sel; tlG.Visible=not sel
            table.insert(tabObjs,{bg=tbg,acc=tacc,lbl=tlW,lblG=tlG,name=name,sel=sel,relTY=tY})
        end

        -- mini bar chrome
        dMShadow = mkMini(mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,Color3.fromRGB(0,0,4),true,0))
        dMBg     = mkMini(mkSq(uiX,uiY,L.W,L.MINI_H,C.BG,true,1))
        dMGlow1  = mkMini(mkSq(uiX-1,uiY-1,L.W+2,L.MINI_H+2,C.ACCENT,false,1,1))
        dMGlow2  = mkMini(mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,C.ACCENT,false,0,2))
        dMBorder = mkMini(mkSq(uiX,uiY,L.W,L.MINI_H,C.BORDER,false,3,1))
        dMTop    = mkMini(mkSq(uiX+1,uiY+1,L.W-2,L.TOPBAR,C.TOPBAR,true,3))
        dMLine   = mkMini(mkLn(uiX+1,uiY+L.TOPBAR,uiX+L.W-1,uiY+L.TOPBAR,C.BORDER,4))
        dMActBg  = mkMini(mkSq(uiX+1,uiY+L.TOPBAR,L.W-2,L.MINI_H-L.TOPBAR-1,C.MINIBAR,true,2))
        dMTitleW = mkMini(mkTx(titleA,uiX+14,uiY+12,14,C.WHITE,false,9,true))
        dMTitleA = mkMini(mkTx(titleB,uiX+14+#titleA*8+3,uiY+12,14,C.ACCENT,false,9,true))
        dMTitleG = mkMini(mkTx(gameName,uiX+14+#titleA*8+3+#titleB*8+10,uiY+12,13,Color3.fromRGB(255,175,80),false,9))
        dMKeyLbl = mkMini(mkTx("F1",uiX+L.W-22,uiY+14,11,C.GRAY,false,9))
        dMDotY   = mkMini(mkSq(uiX+L.W-55,uiY+15,8,8,Color3.fromRGB(190,148,0),true,9))
        dMDotR   = mkMini(mkSq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9))

        -- set default tab and show it
        currentTab = defaultTab
        recalcLayout(defaultTab)

        -- ── LOADING SCREEN ────────────────────────────────
        local lBg    = mkSq(uiX,uiY,L.W,L.H,Color3.fromRGB(7,9,17),true,50)
        local lTitle = mkTx("Loading...",uiX+L.W/2,uiY+L.H/2-30,14,C.WHITE,true,51,false)
        lTitle.Font=Drawing.Fonts.Minecraft; lTitle.Outline=true
        local lDesc  = mkTx("Connecting...",uiX+L.W/2,uiY+L.H/2-10,10,C.GRAY,true,51,false)
        lDesc.Font=Drawing.Fonts.Minecraft
        local lBarBg = mkSq(uiX+L.W/2-80,uiY+L.H/2+12,160,6,C.DIMGRAY,true,51)
        local lBar   = mkSq(uiX+L.W/2-80,uiY+L.H/2+12,1,6,C.ACCENT,true,52)
        local lPct   = mkTx("0%",uiX+L.W/2,uiY+L.H/2+26,9,C.GRAY,true,51,false)
        lPct.Font=Drawing.Fonts.Minecraft
        -- show loading drawings immediately
        lBg.Visible=true; lTitle.Visible=true; lDesc.Visible=true
        lBarBg.Visible=true; lBar.Visible=true; lPct.Visible=true
        lTitle.Text = (gameName~="" and gameName~="Game Name" and gameName or (titleA.." "..titleB)).." Loading"

        -- main menu stays hidden during loading
        for _,d in ipairs(allDrawings) do d.Visible=false end

        -- ── loading animation ─────────────────────────────
        task.spawn(function()
            local stages={
                {"Connecting...",0.25,0.5},
                {"Building UI...",0.55,0.45},
                {"Almost ready...",0.85,0.4},
                {"Done!",1.0,0.25},
            }
            local pct=0
            for _,stage in ipairs(stages) do
                local label,target,hold=stage[1],stage[2],stage[3]
                lDesc.Text=label
                local sv=pct; local dur=0.4; local t0=os.clock()
                repeat
                    task.wait()
                    local tf=math.min((os.clock()-t0)/dur,1)
                    local et=tf<0.5 and 4*tf*tf*tf or 1-(-2*tf+2)*(-2*tf+2)*(-2*tf+2)/2
                    pct=sv+(target-sv)*et
                    lBar.Size=Vector2.new(math.max(1,pct*160),6)
                    lPct.Text=math.floor(pct*100).."%"
                until tf>=1 or destroyed
                pct=target; lBar.Size=Vector2.new(target*160,6); lPct.Text=math.floor(target*100).."%"
                task.wait(hold)
                if destroyed then return end
            end
            task.wait(0.15)
            -- fade out loader
            local t1=os.clock(); local fdur=0.3
            repeat
                task.wait()
                local a=math.max(0,1-(os.clock()-t1)/fdur)
                lBg.Transparency=a; lTitle.Transparency=a; lDesc.Transparency=a
                lBarBg.Transparency=a; lBar.Transparency=a; lPct.Transparency=a
            until os.clock()-t1>=fdur or destroyed
            lBg.Visible=false; lTitle.Visible=false; lDesc.Visible=false
            lBarBg.Visible=false; lBar.Visible=false; lPct.Visible=false
            pcall(function() lBg:Remove() lTitle:Remove() lDesc:Remove() lBarBg:Remove() lBar:Remove() lPct:Remove() end)

            isLoading=false
            menuOpen=true
            -- show all base chrome + current tab
            for _,d in ipairs(baseUI) do setShow(d,true) end
            for _,t in ipairs(tabObjs) do
                setShow(t.bg,true); setShow(t.acc,true)
                setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel)
            end
            recalcLayout(currentTab)
            applyShow()
            updatePos()
            print("[UILib] v5.0 ready")
        end)

        -- ── toggle animation loop ─────────────────────────
        task.spawn(function()
            while not destroyed do
                task.wait()
                if not isLoading and menuOpen and not minimized then
                    -- toggle dot lerp
                    for _,b in ipairs(btns) do
                        if b.isTog and b.tab==currentTab and b.tog and b.tog.Visible then
                            local tgt=b.state and 1 or 0
                            b.lt=b.lt+((tgt-b.lt)*0.2)
                            b.tog.Color=lerpC(C.OFF,C.ON,b.lt)
                            b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.lt)
                            local sc=tabScroll[b.tab] or 0
                            local dox=b.rx+b.cw-L.TOG_W-8
                            b.tog.Position=Vector2.new(uiX+dox,uiY+b.ry-sc+b.ch/2-L.TOG_H/2)
                            b.dot.Position=Vector2.new(uiX+dox+2+(L.TOG_W-L.TOG_H)*b.lt,uiY+b.ry-sc+b.ch/2-L.TOG_H/2+2)
                        end
                    end
                    -- char label
                    if charLabelFn and dCharLbl then
                        pcall(function()
                            local s=charLabelFn()
                            if s and s~="" then dCharLbl.Text=" | "..s end
                        end)
                    end
                end
            end
        end)

        -- ══════════════════════════════════════════════════
        -- INPUT LOOP — ismouse1pressed polling, no UIS
        -- ══════════════════════════════════════════════════
        task.spawn(function()
            while not destroyed do
                task.wait()

                local clicking = ismouse1pressed()

                -- ── menu toggle key ───────────────────────
                local menuKeyNow = iskeypressed(menuKey)
                if menuKeyNow and not wasMenuKey and not isLoading then
                    if minimized then
                        minimized=false; showMiniUI(false)
                        menuOpen=true
                        for _,d in ipairs(baseUI) do setShow(d,true) end
                        for _,t in ipairs(tabObjs) do setShow(t.bg,true); setShow(t.acc,true); setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel) end
                        recalcLayout(currentTab); applyShow(); updatePos()
                    elseif menuOpen then
                        menuOpen=false; applyShow()
                    else
                        menuOpen=true
                        for _,d in ipairs(baseUI) do setShow(d,true) end
                        recalcLayout(currentTab); applyShow(); updatePos()
                    end
                end
                wasMenuKey=menuKeyNow

                -- ── rebind key listen ─────────────────────
                if listenKey then
                    for k=0x08,0xDD do
                        if iskeypressed(k) and k~=0x01 and k~=0x02 then
                            menuKey=k
                            local n=kname(k)
                            dKeyLbl.Text=n; dMKeyLbl.Text=n
                            if iKeyInfo and btns[iKeyInfo] then btns[iKeyInfo].lbl.Text="Menu Key: "..n end
                            if iKeyBind and btns[iKeyBind] then btns[iKeyBind].lbl.Text="Click to Rebind" end
                            listenKey=false; break
                        end
                    end
                end

                -- ── scroll ────────────────────────────────
                if not isLoading and menuOpen and _scrollDelta~=0 then
                    if inBox(uiX+L.SIDEBAR,uiY+L.TOPBAR,L.CONTENT_W,CONTENT_H()) then
                        doScroll(_scrollDelta*32)
                        _scrollDelta=0
                    else
                        _scrollDelta=0
                    end
                end

                -- ── mini drag ─────────────────────────────
                if miniDragging then
                    if clicking then
                        local vW,vH=getVP()
                        uiX=clamp(mouse.X-miniDragOX,0,vW-L.W)
                        uiY=clamp(mouse.Y-miniDragOY,0,vH-L.MINI_H)
                        updateMiniPos()
                    else
                        miniDragging=false
                    end
                end

                -- ── window drag ───────────────────────────
                if dragging then
                    if clicking then
                        local vW,vH=getVP()
                        uiX=clamp(mouse.X-dragOffX,0,vW-L.W)
                        uiY=clamp(mouse.Y-dragOffY,0,vH-L.H)
                        updatePos()
                    else
                        dragging=false
                    end
                end

                -- ── scroll bar drag ───────────────────────
                if scrollDragging then
                    if clicking and currentTab then
                        local maxSc=math.max(0,(tabRowY[currentTab] or 0)-CONTENT_H()+8)
                        local sbH=L.H-L.TOPBAR-L.FOOTER-4
                        local tH=math.max(20,math.min(sbH,(CONTENT_H()/(tabRowY[currentTab] or CONTENT_H()))*sbH))
                        local rawY=mouse.Y-(uiY+L.TOPBAR+2)-scrollDragOffY
                        tabScroll[currentTab]=clamp(rawY/(sbH-tH),0,1)*maxSc
                        for _,b in ipairs(btns) do if b.tab==currentTab then bPos(b) end end
                    else
                        scrollDragging=false
                    end
                end

                -- ── slider drag ───────────────────────────
                for _,b in ipairs(btns) do
                    if b.isSlider and b.dragging then
                        if clicking then
                            local ax=uiX+b.rx+8
                            local frac=clamp((mouse.X-ax)/b.trackW,0,1)
                            b.value=b.minV+frac*(b.maxV-b.minV)
                            local sc=tabScroll[b.tab] or 0
                            local ty=uiY+b.ry-sc+b.ch-11
                            local fx=ax+frac*b.trackW
                            b.fill.To=Vector2.new(fx,ty); b.handle.Position=Vector2.new(fx-4,ty-4)
                            b.lbl.Text=b.baseLbl..": "..(b.isFloat and string.format("%.1f",b.value) or tostring(math.floor(b.value)))
                            if b.cb then pcall(b.cb,b.value) end
                        else
                            b.dragging=false
                        end
                    end
                end

                -- scrollbar thumb position update
                if not isLoading and menuOpen and currentTab then
                    local maxSc=math.max(0,(tabRowY[currentTab] or 0)-CONTENT_H()+8)
                    if maxSc>0 then
                        local sbH=L.H-L.TOPBAR-L.FOOTER-4
                        local tH=math.max(20,math.min(sbH,(CONTENT_H()/(tabRowY[currentTab] or CONTENT_H()))*sbH))
                        dScrollThumb.Size=Vector2.new(4,tH)
                        dScrollThumb.Position=Vector2.new(uiX+L.W-6,uiY+L.TOPBAR+2+clamp((tabScroll[currentTab] or 0)/maxSc,0,1)*(sbH-tH))
                        dScrollThumb.Visible=true; dScrollBg.Visible=true
                    else
                        dScrollThumb.Visible=false; dScrollBg.Visible=false
                    end
                end

                -- ── click: new press only ─────────────────
                if clicking and not wasClicking then

                    -- MINI BAR
                    if minimized then
                        if inBox(uiX+L.W-46,uiY+11,12,12) then
                            -- red dot: close mini
                            minimized=false; miniClosed=true; showMiniUI(false)
                        elseif inBox(uiX+L.W-59,uiY+11,12,12) then
                            -- yellow dot: restore
                            minimized=false; showMiniUI(false)
                            menuOpen=true
                            for _,d in ipairs(baseUI) do setShow(d,true) end
                            for _,t in ipairs(tabObjs) do setShow(t.bg,true); setShow(t.acc,true); setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel) end
                            recalcLayout(currentTab); applyShow(); updatePos()
                        elseif inBox(uiX,uiY,L.W,L.MINI_H) then
                            miniDragging=true; miniDragOX=mouse.X-uiX; miniDragOY=mouse.Y-uiY
                        end
                    elseif menuOpen and not isLoading then
                        -- RED DOT: close
                        if inBox(uiX+L.W-46,uiY+11,12,12) then
                            menuOpen=false; applyShow()
                        -- YELLOW DOT: minimize
                        elseif inBox(uiX+L.W-59,uiY+11,12,12) then
                            menuOpen=false; applyShow()
                            minimized=true
                            refreshMiniLbls(); showMiniUI(true); updateMiniPos()
                        -- SCROLLBAR
                        elseif currentTab and inBox(uiX+L.W-10,uiY+L.TOPBAR,12,L.H-L.TOPBAR-L.FOOTER) then
                            local maxSc=math.max(0,(tabRowY[currentTab] or 0)-CONTENT_H()+8)
                            if maxSc>0 then
                                local sbH=L.H-L.TOPBAR-L.FOOTER-4
                                local tH=math.max(20,math.min(sbH,(CONTENT_H()/(tabRowY[currentTab] or CONTENT_H()))*sbH))
                                local sc=tabScroll[currentTab] or 0
                                local thumbY=uiY+L.TOPBAR+2+clamp(sc/maxSc,0,1)*(sbH-tH)
                                if inBox(uiX+L.W-10,thumbY,12,tH) then
                                    scrollDragging=true; scrollDragOffY=mouse.Y-thumbY
                                else
                                    tabScroll[currentTab]=clamp((mouse.Y-uiY-L.TOPBAR-2-tH/2)/(sbH-tH),0,1)*maxSc
                                    for _,b in ipairs(btns) do if b.tab==currentTab then bPos(b) end end
                                end
                            end
                        -- TOPBAR DRAG
                        elseif inBox(uiX,uiY,L.W,L.TOPBAR) then
                            dragging=true; dragOffX=mouse.X-uiX; dragOffY=mouse.Y-uiY
                        else
                            -- SIDEBAR TABS
                            local tabHit=false
                            for _,t in ipairs(tabObjs) do
                                if inBox(uiX+7,uiY+t.relTY,L.SIDEBAR-14,26) then
                                    switchTab(t.name); tabHit=true; break
                                end
                            end
                            -- ELEMENTS
                            if not tabHit and currentTab then
                                -- close open dropdown if click outside
                                if openDropdown then
                                    local sc=tabScroll[currentTab] or 0
                                    local inH=inBox(uiX+openDropdown.rx,uiY+openDropdown.ry-sc,openDropdown.cw,openDropdown.ch)
                                    local inO=false
                                    for _,o in ipairs(openDropdown.optBgs) do
                                        if o.bg.Visible and inBox(o.bg.Position.X,o.bg.Position.Y,openDropdown.cw,openDropdown.ch) then inO=true end
                                    end
                                    if not inH and not inO then
                                        openDropdown.open=false
                                        for _,o in ipairs(openDropdown.optBgs) do setShow(o.bg,false); setShow(o.ln,false); setShow(o.lb,false) end
                                        if openDropdown.arrow then openDropdown.arrow.Color=C.GRAY end
                                        openDropdown=nil; recalcLayout(currentTab); applyShow()
                                    end
                                end
                                -- hit test each element
                                local sc=tabScroll[currentTab] or 0
                                for _,b in ipairs(btns) do
                                    if b.tab==currentTab and not(b.section and _sectionCollapse[b.section]) then
                                        local bx=uiX+b.rx; local by=uiY+b.ry-sc
                                        if b.isSlider then
                                            if inBox(bx,by,b.cw,b.ch) then b.dragging=true end
                                        elseif inBox(bx,by,b.cw,b.ch) then
                                            if b.isTog then
                                                b.state=not b.state
                                                if b.cb then pcall(b.cb,b.state) end
                                                refreshMiniLbls()
                                            elseif b.isAct then
                                                if iKeyBind and btns[iKeyBind]==b then
                                                    listenKey=true
                                                    b.lbl.Text="Press any key..."
                                                elseif b.cb then
                                                    pcall(b.cb)
                                                end
                                            elseif b.isDropdown then
                                                -- check option click first
                                                local optPicked=false
                                                if b.open then
                                                    for i,o in ipairs(b.optBgs) do
                                                        if o.bg.Visible and inBox(o.bg.Position.X,o.bg.Position.Y,b.cw,b.ch) then
                                                            b.selected=i; b.valLbl.Text=b.options[i]
                                                            for j,o2 in ipairs(b.optBgs) do o2.lb.Color=j==i and C.ACCENT or C.WHITE end
                                                            b.open=false
                                                            for _,o2 in ipairs(b.optBgs) do setShow(o2.bg,false); setShow(o2.ln,false); setShow(o2.lb,false) end
                                                            openDropdown=nil; recalcLayout(currentTab); applyShow()
                                                            if b.cb then pcall(b.cb,b.options[i],i) end
                                                            optPicked=true; break
                                                        end
                                                    end
                                                end
                                                if not optPicked then
                                                    -- close other open DD
                                                    if openDropdown and openDropdown~=b then
                                                        openDropdown.open=false
                                                        for _,o in ipairs(openDropdown.optBgs) do setShow(o.bg,false); setShow(o.ln,false); setShow(o.lb,false) end
                                                        openDropdown=nil; recalcLayout(currentTab)
                                                    end
                                                    b.open=not b.open
                                                    openDropdown=b.open and b or nil
                                                    if b.open then
                                                        local dsc=tabScroll[currentTab] or 0
                                                        for i,o in ipairs(b.optBgs) do
                                                            local oy=uiY+b.ry-dsc+b.ch+((i-1)*b.ch)
                                                            o.bg.Position=Vector2.new(bx,oy); o.bg.Size=Vector2.new(b.cw,b.ch)
                                                            o.ln.From=Vector2.new(bx,oy+b.ch); o.ln.To=Vector2.new(bx+b.cw,oy+b.ch)
                                                            o.lb.Position=Vector2.new(bx+12,oy+b.ch/2-6)
                                                            o.ry=b.ry-dsc+b.ch+((i-1)*b.ch)
                                                            setShow(o.bg,true); setShow(o.ln,true); setShow(o.lb,true)
                                                        end
                                                    else
                                                        for _,o in ipairs(b.optBgs) do setShow(o.bg,false); setShow(o.ln,false); setShow(o.lb,false) end
                                                    end
                                                    recalcLayout(currentTab); applyShow()
                                                end
                                            elseif b.isColorPicker then
                                                for j,sw in ipairs(b.swatches) do
                                                    if inBox(sw.x,sw.y,14,14) then
                                                        b.selected=j; b.value=sw.col
                                                        for k,sw2 in ipairs(b.swatches) do sw2.border.Color=k==j and C.WHITE or C.BORDER end
                                                        if b.cb then pcall(b.cb,sw.col) end; break
                                                    end
                                                end
                                            elseif b.isDiv and b.collapsible and b.sectionName then
                                                _sectionCollapse[b.sectionName]=not _sectionCollapse[b.sectionName]
                                                recalcLayout(currentTab); applyShow()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                end -- clicking and not wasClicking

                wasClicking=clicking
            end -- while
        end)

    end -- Init

    win._tabOrder = tabOrder
    return win
end

_G.UILib = UILib
print("[UILib] v5.0 loaded")
return UILib
