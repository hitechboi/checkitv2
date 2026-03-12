-- ═══════════════════════════════════════════════════════
--  Check it  UI Library  v4.0
--  Matcha-native: ismouse1pressed + iskeypressed polling
--  RunService VM for animation, no UIS dependency
-- ═══════════════════════════════════════════════════════
local UILib = {}

-- ── Services ─────────────────────────────────────────────
local Players = game:GetService("Players")
local lp      = Players.LocalPlayer
local mouse   = lp:GetMouse()

-- ── RunService VM ────────────────────────────────────────
local RunService = (function()
    local RS = {}
    local _running = true
    local _lastT   = os.clock()

    local function Signal()
        local s = {_c={}}
        function s:Connect(fn)
            local c={fn=fn,on=true}
            table.insert(s._c,c)
            return {Disconnect=function() c.on=false end}
        end
        function s:Fire(...)
            local i=1
            while i<=#s._c do
                local c=s._c[i]
                if c.on then pcall(c.fn,...); i=i+1
                else table.remove(s._c,i) end
            end
        end
        return s
    end

    RS.Heartbeat     = Signal()
    RS.RenderStepped = Signal()

    task.spawn(function()
        while _running do
            local now = os.clock()
            local dt  = math.min(now - _lastT, 0.1)
            _lastT    = now
            RS.RenderStepped:Fire(dt)
            RS.Heartbeat:Fire(dt)
            task.wait()
        end
    end)

    return RS
end)()

-- ── Themes ───────────────────────────────────────────────
local THEMES = {
    ["Check it"]={
        ACC=Color3.fromRGB(70,120,255),  BG=Color3.fromRGB(9,11,20),
        SIDE=Color3.fromRGB(12,15,27),   CONT=Color3.fromRGB(11,13,23),
        TOP=Color3.fromRGB(7,9,17),      BOR=Color3.fromRGB(30,40,72),
        ROW=Color3.fromRGB(14,18,33),    TSEL=Color3.fromRGB(20,35,85),
        TXT=Color3.fromRGB(215,220,240), GRY=Color3.fromRGB(100,112,145),
        DIM=Color3.fromRGB(28,33,52),    ON=Color3.fromRGB(45,85,195),
        OFF=Color3.fromRGB(20,24,42),    ONDOT=Color3.fromRGB(175,198,255),
        OFFDOT=Color3.fromRGB(55,65,95), DIV=Color3.fromRGB(22,27,48),
        MINI=Color3.fromRGB(11,13,22)
    },
    ["Moon"]={
        ACC=Color3.fromRGB(150,150,165), BG=Color3.fromRGB(12,12,14),
        SIDE=Color3.fromRGB(16,16,18),   CONT=Color3.fromRGB(14,14,16),
        TOP=Color3.fromRGB(10,10,12),    BOR=Color3.fromRGB(40,40,46),
        ROW=Color3.fromRGB(18,18,22),    TSEL=Color3.fromRGB(30,30,36),
        TXT=Color3.fromRGB(220,220,225), GRY=Color3.fromRGB(120,120,130),
        DIM=Color3.fromRGB(40,40,45),    ON=Color3.fromRGB(100,100,115),
        OFF=Color3.fromRGB(25,25,30),    ONDOT=Color3.fromRGB(200,200,215),
        OFFDOT=Color3.fromRGB(70,70,80), DIV=Color3.fromRGB(30,30,36),
        MINI=Color3.fromRGB(16,16,20)
    },
    ["Grass"]={
        ACC=Color3.fromRGB(60,200,100),  BG=Color3.fromRGB(8,14,10),
        SIDE=Color3.fromRGB(10,18,13),   CONT=Color3.fromRGB(9,16,11),
        TOP=Color3.fromRGB(6,11,8),      BOR=Color3.fromRGB(25,55,35),
        ROW=Color3.fromRGB(11,20,14),    TSEL=Color3.fromRGB(18,45,25),
        TXT=Color3.fromRGB(200,235,210), GRY=Color3.fromRGB(90,130,105),
        DIM=Color3.fromRGB(20,40,28),    ON=Color3.fromRGB(30,140,65),
        OFF=Color3.fromRGB(15,30,20),    ONDOT=Color3.fromRGB(150,240,180),
        OFFDOT=Color3.fromRGB(45,80,58), DIV=Color3.fromRGB(18,35,24),
        MINI=Color3.fromRGB(10,18,13)
    },
    ["Light"]={
        ACC=Color3.fromRGB(50,100,255),  BG=Color3.fromRGB(230,233,245),
        SIDE=Color3.fromRGB(215,220,235),CONT=Color3.fromRGB(220,224,238),
        TOP=Color3.fromRGB(200,205,225), BOR=Color3.fromRGB(170,178,210),
        ROW=Color3.fromRGB(210,214,230), TSEL=Color3.fromRGB(190,205,240),
        TXT=Color3.fromRGB(25,30,60),    GRY=Color3.fromRGB(90,100,140),
        DIM=Color3.fromRGB(180,185,210), ON=Color3.fromRGB(60,120,255),
        OFF=Color3.fromRGB(180,185,210), ONDOT=Color3.fromRGB(255,255,255),
        OFFDOT=Color3.fromRGB(130,140,175),DIV=Color3.fromRGB(185,190,215),
        MINI=Color3.fromRGB(205,210,228)
    },
    ["Dark"]={
        ACC=Color3.fromRGB(180,180,180), BG=Color3.fromRGB(4,4,6),
        SIDE=Color3.fromRGB(6,6,9),      CONT=Color3.fromRGB(5,5,8),
        TOP=Color3.fromRGB(3,3,5),       BOR=Color3.fromRGB(20,20,28),
        ROW=Color3.fromRGB(7,7,10),      TSEL=Color3.fromRGB(15,15,22),
        TXT=Color3.fromRGB(190,190,195), GRY=Color3.fromRGB(80,80,90),
        DIM=Color3.fromRGB(15,15,20),    ON=Color3.fromRGB(100,100,110),
        OFF=Color3.fromRGB(12,12,16),    ONDOT=Color3.fromRGB(220,220,225),
        OFFDOT=Color3.fromRGB(45,45,55), DIV=Color3.fromRGB(14,14,18),
        MINI=Color3.fromRGB(6,6,8)
    },
}
UILib.Themes = THEMES

-- ── Helpers ───────────────────────────────────────────────
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerp(a,b,t)    return a+(b-a)*t end
local function easeOut(t)     return 1-(1-t)^3 end
local function easeInOut(t)   return t<.5 and 4*t^3 or 1-(-2*t+2)^3/2 end
local function lerpC(a,b,t)
    return Color3.fromRGB(
        math.floor(lerp(a.R*255,b.R*255,t)+.5),
        math.floor(lerp(a.G*255,b.G*255,t)+.5),
        math.floor(lerp(a.B*255,b.B*255,t)+.5))
end
local function getVP()
    local ok,c=pcall(function() return workspace.CurrentCamera.ViewportSize end)
    if ok and c then return c.X,c.Y end
    return 1920,1080
end
local function hit(x,y,w,h) -- mouse inside box?
    local mx,my=mouse.X,mouse.Y
    return mx>=x and mx<x+w and my>=y and my<y+h
end

-- ── Drawing factories ─────────────────────────────────────
local function sq(x,y,w,h,col,filled,zi,thick)
    local s=Drawing.new("Square")
    s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h)
    s.Color=col or Color3.new(1,1,1); s.Filled=(filled~=false)
    s.ZIndex=zi or 1; s.Transparency=1; s.Visible=true
    if not(filled~=false) then s.Thickness=thick or 1 end
    return s
end
local function tx(str,x,y,sz,col,ctr,zi,font)
    local t=Drawing.new("Text")
    t.Text=str; t.Position=Vector2.new(x,y); t.Size=sz or 12
    t.Color=col or Color3.new(1,1,1); t.Center=ctr or false
    t.Outline=false; t.ZIndex=zi or 3; t.Transparency=1
    t.Font=font or Drawing.Fonts.System; t.Visible=true
    return t
end
local function ln(x1,y1,x2,y2,col,zi,thick)
    local l=Drawing.new("Line")
    l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2)
    l.Color=col or Color3.new(1,1,1); l.Transparency=1
    l.Thickness=thick or 1; l.ZIndex=zi or 2; l.Visible=true
    return l
end
local function corner(d,r) pcall(function() d.Corner=r end) end

-- ── Layout constants ──────────────────────────────────────
local W=440; local FH=400; local MH=86
local SB=128; local TOP=40; local FOT=34
local RH=38;  local PAD=10; local TW=34; local TH=17; local HDL=8
local CW=W-SB

-- ══════════════════════════════════════════════════════════
function UILib.Window(titleA,titleB,gameName)
    local win={}
    gameName=gameName or ""

    -- theme copy
    local C={}; for k,v in pairs(THEMES["Check it"]) do C[k]=v end

    -- position/state
    local uiX,uiY=280,180
    local destroyed=false
    local isOpen=true
    local isMini=false
    local isLoading=true
    local menuKeyCode=0x70 -- F1

    -- all drawings for cleanup
    local allD={}
    local function d(dr) table.insert(allD,dr); return dr end

    -- tabs
    local tabOrder={}
    local tabRows={}    -- {name -> total content height}
    local tabScroll={}  -- {name -> scroll offset}
    local tabAPI={}
    local curTab=nil
    local tabObjs={}    -- sidebar drawing groups
    local btns={}       -- all element records
    local sections={}   -- {label -> collapsed bool}
    local openDD=nil

    -- ── content geometry ──────────────────────────────────
    local function cH()   return FH-TOP-FOT end
    local function ctTop() return uiY+TOP end
    local function ctBot() return uiY+FH-FOT end

    -- ── clip test ─────────────────────────────────────────
    local function isClipped(b)
        local sc=tabScroll[b.tab] or 0
        local top=uiY+b.ry-sc
        return (top+b.ch<=ctTop()) or (top>=ctBot())
    end

    -- ── show/hide all drawings for a button ───────────────
    local function bShow(b,vis)
        local v=vis and not isClipped(b)
        local function sv(dr) if dr then dr.Visible=v end end
        sv(b.bg); sv(b.outline); sv(b.sep); sv(b.lbl)
        sv(b.tog); sv(b.dot); sv(b.qbg); sv(b.qlb)
        sv(b.track); sv(b.fill); sv(b.handle); sv(b.dlbl)
        sv(b.valLbl); sv(b.arrow)
        if b.swatches then for _,sw in ipairs(b.swatches) do sv(sw.s); sv(sw.b) end end
        if b.logs then for _,l in ipairs(b.logs) do sv(l) end end
        if b.opts then
            for _,o in ipairs(b.opts) do
                local ov=v and b.ddOpen
                o.bg.Visible=ov; o.sep.Visible=ov; o.lbl.Visible=ov
            end
        end
    end

    -- ── position all drawings for a button ────────────────
    local function posBtn(b)
        local sc=tabScroll[b.tab] or 0
        local ax=uiX+b.rx; local ay=uiY+b.ry-sc

        b.bg.Position=Vector2.new(ax,ay)
        if b.outline then b.outline.Position=Vector2.new(ax,ay) end

        if b.isLog then
            for i,l in ipairs(b.logs) do
                local off= (b.starFirst and i==1) and b.pad
                    or (b.starFirst and (b.starH+b.pad+(i-2)*b.lnH))
                    or (b.pad+(i-1)*b.lnH)
                l.Position=Vector2.new(
                    (b.starFirst and i==1) and (ax+b.cw/2) or (ax+8),
                    ay+off)
            end
            return
        end

        if b.sep then b.sep.From=Vector2.new(ax,ay+b.ch); b.sep.To=Vector2.new(ax+b.cw,ay+b.ch) end

        if b.isDiv then
            b.lbl.Position=Vector2.new(ax+6,ay+2)
            b.sep.From=Vector2.new(ax,ay+14); b.sep.To=Vector2.new(ax+b.cw,ay+14)
            if b.arrow then b.arrow.Position=Vector2.new(ax+b.cw-12,ay+2) end
            return
        end

        if b.isSlider then
            b.lbl.Position=Vector2.new(ax+8,ay+7)
            if b.dlbl then b.dlbl.Position=Vector2.new(ax+8,ay+21) end
            local ty=ay+b.ch-12
            local frac=clamp((b.value-b.minV)/(b.maxV-b.minV),0,1)
            local fx=ax+8+frac*b.trkW
            b.track.From=Vector2.new(ax+8,ty); b.track.To=Vector2.new(ax+8+b.trkW,ty)
            b.fill.From=Vector2.new(ax+8,ty);  b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
            return
        end

        -- toggle / button / dropdown / colorpicker
        b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
        if b.tog then
            local dox=b.rx+b.cw-TW-8
            b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-TH/2)
            b.dot.Position=Vector2.new(uiX+dox+2+(TW-TH)*b.selT,ay+b.ch/2-TH/2+2)
        end
        if b.qbg then
            local qx=uiX+b.rx+b.cw-TW-30; local qy=ay+b.ch/2-7
            b.qbg.Position=Vector2.new(qx,qy)
            if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+2) end
        end
        if b.valLbl then b.valLbl.Position=Vector2.new(ax+b.cw-62,ay+b.ch/2-6) end
        if b.arrow  then b.arrow.Position=Vector2.new(ax+b.cw-16,ay+b.ch/2-6) end
        if b.swatches then
            local sw2=(#b.swatches*19)-5; local sx0=ax+b.cw-sw2-10
            for i,sw in ipairs(b.swatches) do
                local sx=sx0+(i-1)*19; local sy=ay+b.ch/2-7
                sw.s.Position=Vector2.new(sx,sy); sw.b.Position=Vector2.new(sx-1,sy-1)
            end
        end
        if b.opts then
            local sc2=tabScroll[b.tab] or 0
            for i,o in ipairs(b.opts) do
                local oy=uiY+b.ry-sc2+b.ch+((i-1)*b.ch)
                o.bg.Position=Vector2.new(ax,oy)
                o.sep.From=Vector2.new(ax,oy+b.ch); o.sep.To=Vector2.new(ax+b.cw,oy+b.ch)
                o.lbl.Position=Vector2.new(ax+14,oy+b.ch/2-6)
            end
        end
    end

    -- ── chrome drawings ───────────────────────────────────
    local dShad,dMain,dBor,dGlow1,dGlow2
    local dTop,dTopLn
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dDotY,dDotR
    local dSide,dSideLn,dCont,dFoot,dFotLn,dCharLbl,dWelcome,dName
    local dScrBg,dScrThumb
    -- mini bar
    local dMS,dMB,dMBor,dMG1,dMG2,dMTop,dMLn,dMAct
    local dMTW,dMTA,dMTG,dMKey,dMDY,dMDR
    local miniLbls={}

    local function showAll(vis)
        local function sv(dr) if dr then dr.Visible=vis end end
        sv(dShad);sv(dMain);sv(dBor);sv(dGlow1);sv(dGlow2)
        sv(dTop);sv(dTopLn);sv(dTitleW);sv(dTitleA);sv(dTitleG)
        sv(dKeyLbl);sv(dDotY);sv(dDotR)
        sv(dSide);sv(dSideLn);sv(dCont);sv(dFoot);sv(dFotLn)
        sv(dCharLbl);sv(dWelcome);sv(dName)
        for _,tb in ipairs(tabObjs) do sv(tb.bg);sv(tb.acc);sv(tb.lbl);sv(tb.lblG) end
        for _,b in ipairs(btns) do bShow(b,vis and b.tab==curTab) end
        if dScrBg then sv(dScrBg);sv(dScrThumb) end
    end

    local function showMini(vis)
        local function sv(dr) if dr then dr.Visible=vis end end
        sv(dMS);sv(dMB);sv(dMBor);sv(dMG1);sv(dMG2)
        sv(dMTop);sv(dMLn);sv(dMAct)
        sv(dMTW);sv(dMTA);sv(dMTG);sv(dMKey);sv(dMDY);sv(dMDR)
        for _,l in ipairs(miniLbls) do sv(l) end
    end

    -- ── scrollbar ─────────────────────────────────────────
    local function updScr()
        if not(dScrBg and curTab) then return end
        local total=tabRows[curTab] or 0
        local maxSc=math.max(0,total-cH()+8)
        if maxSc<=0 then dScrBg.Visible=false; dScrThumb.Visible=false; return end
        local sbH=FH-TOP-FOT-4
        local sc=tabScroll[curTab] or 0
        local tH=math.max(20,math.min(sbH,(cH()/(total+1))*sbH))
        dScrBg.Visible=true; dScrThumb.Visible=true
        dScrBg.Position=Vector2.new(uiX+W-6,uiY+TOP+2); dScrBg.Size=Vector2.new(4,sbH)
        dScrThumb.Position=Vector2.new(uiX+W-6,uiY+TOP+2+clamp(sc/maxSc,0,1)*(sbH-tH))
        dScrThumb.Size=Vector2.new(4,tH)
    end

    -- ── reposition chrome ─────────────────────────────────
    local function reposChrome()
        dShad.Position=Vector2.new(uiX-2,uiY-2);    dShad.Size=Vector2.new(W+4,FH+4)
        dMain.Position=Vector2.new(uiX,uiY);          dMain.Size=Vector2.new(W,FH)
        dBor.Position=Vector2.new(uiX,uiY);            dBor.Size=Vector2.new(W,FH)
        dGlow1.Position=Vector2.new(uiX-1,uiY-1);   dGlow1.Size=Vector2.new(W+2,FH+2)
        dGlow2.Position=Vector2.new(uiX-2,uiY-2);   dGlow2.Size=Vector2.new(W+4,FH+4)
        dTop.Position=Vector2.new(uiX+1,uiY+1);      dTop.Size=Vector2.new(W-2,TOP)
        dTopLn.From=Vector2.new(uiX+1,uiY+TOP);      dTopLn.To=Vector2.new(uiX+W-1,uiY+TOP)
        dTitleW.Position=Vector2.new(uiX+14,uiY+12)
        dTitleA.Position=Vector2.new(uiX+86,uiY+12)
        dTitleG.Position=Vector2.new(uiX+86+#(titleB or "")*8+14,uiY+12)
        dKeyLbl.Position=Vector2.new(uiX+W-24,uiY+14)
        dDotY.Position=Vector2.new(uiX+W-57,uiY+15)
        dDotR.Position=Vector2.new(uiX+W-44,uiY+15)
        dSide.Position=Vector2.new(uiX+1,uiY+TOP);   dSide.Size=Vector2.new(SB-1,FH-TOP-FOT-1)
        dSideLn.From=Vector2.new(uiX+SB,uiY+TOP);    dSideLn.To=Vector2.new(uiX+SB,uiY+FH-FOT)
        dCont.Position=Vector2.new(uiX+SB,uiY+TOP);  dCont.Size=Vector2.new(CW-1,FH-TOP-FOT-1)
        dFoot.Position=Vector2.new(uiX+1,uiY+FH-FOT);dFoot.Size=Vector2.new(W-2,FOT-1)
        dFotLn.From=Vector2.new(uiX+1,uiY+FH-FOT);  dFotLn.To=Vector2.new(uiX+W-1,uiY+FH-FOT)
        dWelcome.Position=Vector2.new(uiX+14,uiY+FH-FOT+10)
        dName.Position=Vector2.new(uiX+80,uiY+FH-FOT+10)
        dCharLbl.Position=Vector2.new(uiX+80+#lp.Name*8+4,uiY+FH-FOT+10)
        for _,tb in ipairs(tabObjs) do
            tb.bg.Position=Vector2.new(uiX+7,uiY+tb.tY)
            tb.acc.Position=Vector2.new(uiX+7,uiY+tb.tY)
            tb.lbl.Position=Vector2.new(uiX+18,uiY+tb.tY+7)
            tb.lblG.Position=Vector2.new(uiX+18,uiY+tb.tY+7)
        end
        if curTab then
            for _,b in ipairs(btns) do
                if b.tab==curTab then posBtn(b) end
            end
        end
        updScr()
    end

    local function reposMini()
        dMS.Position=Vector2.new(uiX-2,uiY-2);  dMS.Size=Vector2.new(W+4,MH+4)
        dMB.Position=Vector2.new(uiX,uiY);       dMB.Size=Vector2.new(W,MH)
        dMBor.Position=Vector2.new(uiX,uiY);     dMBor.Size=Vector2.new(W,MH)
        dMG1.Position=Vector2.new(uiX-1,uiY-1); dMG1.Size=Vector2.new(W+2,MH+2)
        dMG2.Position=Vector2.new(uiX-2,uiY-2); dMG2.Size=Vector2.new(W+4,MH+4)
        dMTop.Position=Vector2.new(uiX+1,uiY+1);dMTop.Size=Vector2.new(W-2,TOP)
        dMLn.From=Vector2.new(uiX+1,uiY+TOP);   dMLn.To=Vector2.new(uiX+W-1,uiY+TOP)
        dMAct.Position=Vector2.new(uiX+1,uiY+TOP);dMAct.Size=Vector2.new(W-2,MH-TOP-1)
        dMTW.Position=Vector2.new(uiX+14,uiY+12)
        dMTA.Position=Vector2.new(uiX+86,uiY+12)
        dMTG.Position=Vector2.new(uiX+86+#(titleB or "")*8+14,uiY+12)
        dMKey.Position=Vector2.new(uiX+W-24,uiY+14)
        dMDY.Position=Vector2.new(uiX+W-57,uiY+15)
        dMDR.Position=Vector2.new(uiX+W-44,uiY+15)
        local cx=uiX+10; local r1=uiY+TOP+6; local r2=r1+18; local row=1
        for _,lb in ipairs(miniLbls) do
            if lb.Text~="" then
                local w=#lb.Text*7
                if cx+w>uiX+W-10 then
                    if row==1 then row=2; cx=uiX+10 else break end
                end
                lb.Position=Vector2.new(cx,row==1 and r1 or r2)
                cx=cx+w+12
            end
        end
    end

    local function refreshMiniLbls()
        local act={}
        for _,b in ipairs(btns) do if b.isTog and b.state then table.insert(act,b.name) end end
        for i=1,12 do
            local lb=miniLbls[i]
            if lb then
                lb.Text=act[i] or ""
                lb.Visible=isMini and lb.Text~=""
            end
        end
        if #act==0 and miniLbls[1] then
            miniLbls[1].Text="no active toggles"
            miniLbls[1].Visible=isMini
        end
        if isMini then reposMini() end
    end

    -- ── recalculate tab layout ────────────────────────────
    local function recalcTab(tname)
        local cy=10
        for _,b in ipairs(btns) do
            if b.tab~=tname then continue end
            local col=b.section and sections[b.section]
            if col then
                b.ry=TOP+cy; b.ch=b.baseCh
            else
                b.ry=TOP+cy; b.ch=b.baseCh
                cy=cy+b.baseCh+6
                if b.isDD and b.ddOpen then cy=cy+(#b.opts*b.ch) end
            end
        end
        local maxY=0
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local bot=(b.ry or 0)+b.ch
                if bot>maxY then maxY=bot end
            end
        end
        tabRows[tname]=maxY+36
        local maxSc=math.max(0,(tabRows[tname] or 0)-cH()+8)
        tabScroll[tname]=clamp(tabScroll[tname] or 0,0,maxSc)
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local col=b.section and sections[b.section]
                if col then bShow(b,false)
                else posBtn(b); bShow(b,b.tab==curTab) end
            end
        end
        updScr()
    end

    local function doScroll(delta)
        if not curTab then return end
        local maxSc=math.max(0,(tabRows[curTab] or 0)-cH()+8)
        tabScroll[curTab]=clamp((tabScroll[curTab] or 0)+delta,0,maxSc)
        for _,b in ipairs(btns) do
            if b.tab==curTab then posBtn(b); bShow(b,not(b.section and sections[b.section])) end
        end
        updScr()
    end

    -- ── tab switch ────────────────────────────────────────
    local function switchTab(name)
        if name==curTab then return end
        if openDD then
            openDD.ddOpen=false; openDD.arrow.Text="v"
            for _,o in ipairs(openDD.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
            openDD=nil
        end
        if curTab then
            for _,b in ipairs(btns) do if b.tab==curTab then bShow(b,false) end end
        end
        curTab=name
        recalcTab(name)
        for _,tb in ipairs(tabObjs) do
            tb.sel=tb.name==name
            tb.bg.Color=tb.sel and C.TSEL or C.SIDE
            tb.acc.Color=tb.sel and C.ACC or C.SIDE
            tb.lbl.Visible=tb.sel
            tb.lblG.Visible=not tb.sel
        end
    end

    -- ── applyTheme ────────────────────────────────────────
    local function applyTheme(name)
        local t=THEMES[name]; if not t then return end
        for k,v in pairs(t) do C[k]=v end
        if not dMain then return end
        dMain.Color=C.BG; dTop.Color=C.TOP; dSide.Color=C.SIDE; dCont.Color=C.CONT
        dFoot.Color=C.TOP; dBor.Color=C.BOR; dTopLn.Color=C.BOR; dSideLn.Color=C.BOR
        dFotLn.Color=C.BOR; dGlow1.Color=C.ACC; dGlow2.Color=C.ACC
        dScrBg.Color=Color3.fromRGB(18,20,28); dScrThumb.Color=C.ACC
        dTitleA.Color=C.ACC; dTitleW.Color=C.TXT; dTitleG.Color=Color3.fromRGB(255,175,80)
        dKeyLbl.Color=C.GRY; dCharLbl.Color=C.GRY; dWelcome.Color=C.TXT
        dName.Color=Color3.fromRGB(45,190,95)
        dMB.Color=C.BG; dMTop.Color=C.TOP; dMBor.Color=C.BOR
        dMG1.Color=C.ACC; dMG2.Color=C.ACC; dMAct.Color=C.MINI
        dMTA.Color=C.ACC; dMTW.Color=C.TXT; dMLn.Color=C.BOR; dMKey.Color=C.GRY
        for _,tb in ipairs(tabObjs) do
            tb.bg.Color=tb.sel and C.TSEL or C.SIDE
            tb.acc.Color=tb.sel and C.ACC or C.SIDE
            tb.lbl.Color=C.TXT; tb.lblG.Color=C.GRY
        end
        for _,b in ipairs(btns) do
            if b.sep then b.sep.Color=C.DIV end
            if b.isTog then
                b.bg.Color=C.ROW; b.lbl.Color=C.TXT
                b.tog.Color=b.state and C.ON or C.OFF
                b.dot.Color=b.state and C.ONDOT or C.OFFDOT
            elseif b.isSlider then
                b.bg.Color=C.ROW; b.lbl.Color=C.TXT
                b.track.Color=C.DIM; b.fill.Color=C.ACC
                if b.dlbl then b.dlbl.Color=C.GRY end
            elseif b.isBtn and not b.customCol then b.bg.Color=C.ROW
            elseif b.isDiv then
                b.lbl.Color=C.GRY; if b.arrow then b.arrow.Color=C.GRY end
            elseif b.isDD then
                b.lbl.Color=C.TXT; b.arrow.Color=C.GRY; b.valLbl.Color=C.ACC
                for j,o in ipairs(b.opts) do
                    o.bg.Color=C.ROW; o.sep.Color=C.DIV
                    o.lbl.Color=j==b.selected and C.ACC or C.TXT
                end
            elseif b.isCP then b.bg.Color=C.ROW; b.lbl.Color=C.TXT
            end
        end
    end

    -- ── element builders ──────────────────────────────────
    local function rx0() return SB+PAD end
    local function cw0() return CW-PAD*2 end

    local function mkToggle(tname,name,ry,init,cb,desc)
        local rx=rx0(); local cw=cw0(); local ch=RH
        local bg2=d(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3)); corner(bg2,4)
        local sep2=d(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4))
        local lbl2=d(tx(name,uiX+rx+10,uiY+ry+ch/2-6,12,C.TXT,false,8))
        local ox=rx+cw-TW-8
        local tog2=d(sq(uiX+ox,uiY+ry+ch/2-TH/2,TW,TH,init and C.ON or C.OFF,true,4)); corner(tog2,TH)
        local dot2=d(sq(uiX+ox+(init and TW-TH+2 or 2),uiY+ry+ch/2-TH/2+2,TH-4,TH-4,init and C.ONDOT or C.OFFDOT,true,5)); corner(dot2,TH)
        local qbg2,qlb2
        if desc then
            local qx=uiX+ox-26; local qy=uiY+ry+ch/2-7
            qbg2=d(sq(qx,qy,14,14,C.DIM,true,6)); corner(qbg2,3)
            qlb2=d(tx("?",qx+7,qy+2,9,C.GRY,true,7,Drawing.Fonts.SystemBold))
        end
        local b={tab=tname,isTog=true,name=name,state=init or false,
            bg=bg2,sep=sep2,lbl=lbl2,tog=tog2,dot=dot2,qbg=qbg2,qlb=qlb2,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,selT=init and 1 or 0,cb=cb,desc=desc}
        table.insert(btns,b); return b
    end

    local function mkDiv(tname,label,ry,collapsible)
        local rx=rx0(); local cw=cw0(); local ch=16
        local lbl2=d(tx(label,uiX+rx+6,uiY+ry+2,9,C.GRY,false,8))
        local sep2=d(ln(uiX+rx,uiY+ry+14,uiX+rx+cw,uiY+ry+14,C.DIV,4))
        local arrow2
        if collapsible then
            arrow2=d(tx("v",uiX+rx+cw-12,uiY+ry+2,9,C.GRY,false,8))
            if sections[label]==nil then sections[label]=false end
        end
        local b={tab=tname,isDiv=true,label=label,bg=lbl2,lbl=lbl2,sep=sep2,arrow=arrow2,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,collapsible=collapsible}
        table.insert(btns,b); return b
    end

    local function mkSlider(tname,label,ry,mn,mx,iv,cb,isFloat,desc)
        local rx=rx0(); local cw=cw0(); local ch=RH+8; local trkW=cw-16
        local frac=clamp((iv-mn)/(mx-mn),0,1); local fx=uiX+rx+8+frac*trkW
        local disp=isFloat and string.format("%.1f",iv) or tostring(math.floor(iv))
        local bg2=d(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3)); corner(bg2,4)
        local sep2=d(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4))
        local lbl2=d(tx(label..": "..disp,uiX+rx+8,uiY+ry+7,12,C.TXT,false,8))
        local dlbl2=desc and d(tx(desc,uiX+rx+8,uiY+ry+21,9,C.GRY,false,7)) or nil
        local ty=uiY+ry+ch-12
        local trk2=d(ln(uiX+rx+8,ty,uiX+rx+8+trkW,ty,C.DIM,5,3))
        local fil2=d(ln(uiX+rx+8,ty,fx,ty,C.ACC,6,3))
        local hdl2=d(sq(fx-4,ty-4,HDL,HDL,C.TXT,true,7)); corner(hdl2,3)
        local b={tab=tname,isSlider=true,bg=bg2,sep=sep2,lbl=lbl2,dlbl=dlbl2,
            track=trk2,fill=fil2,handle=hdl2,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,trkW=trkW,
            minV=mn,maxV=mx,value=iv,baseLbl=label,isFloat=isFloat or false,cb=cb}
        table.insert(btns,b); return b
    end

    local function mkButton(tname,label,ry,col,cb,lc)
        local rx=rx0(); local cw=cw0(); local ch=RH
        local bc=col or C.ROW
        local oc=Color3.fromRGB(math.min(255,bc.R*255*1.6),math.min(255,bc.G*255*1.6),math.min(255,bc.B*255*1.6))
        local out2=d(sq(uiX+rx,uiY+ry,cw,ch,oc,true,3)); corner(out2,4)
        local bg2=d(sq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,bc,true,4)); corner(bg2,4)
        local lbl2=d(tx(label,uiX+rx+cw/2,uiY+ry+ch/2-6,12,lc or C.TXT,true,8))
        local b={tab=tname,isBtn=true,customCol=col~=nil,outline=out2,bg=bg2,lbl=lbl2,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,cb=cb}
        table.insert(btns,b); return b
    end

    local function mkDropdown(tname,label,ry,opts,initIdx,cb)
        local rx=rx0(); local cw=cw0(); local ch=RH
        local bc=C.ROW
        local oc=Color3.fromRGB(math.min(255,bc.R*255*1.6),math.min(255,bc.G*255*1.6),math.min(255,bc.B*255*1.6))
        local out2=d(sq(uiX+rx,uiY+ry,cw,ch,oc,true,3)); corner(out2,4)
        local bg2=d(sq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROW,true,4)); corner(bg2,4)
        local lbl2=d(tx(label,uiX+rx+10,uiY+ry+ch/2-6,12,C.TXT,false,8))
        local vi=initIdx or 1
        local val2=d(tx(opts[vi] or "",uiX+rx+cw-62,uiY+ry+ch/2-6,11,C.ACC,false,8))
        local arr2=d(tx("v",uiX+rx+cw-16,uiY+ry+ch/2-6,9,C.GRY,false,8))
        local optRecs={}
        for i,opt in ipairs(opts) do
            local oy=uiY+ry+ch+((i-1)*ch)
            local obg=d(sq(uiX+rx,oy,cw,ch,C.ROW,true,10)); obg.Visible=false
            local osep=d(ln(uiX+rx,oy+ch,uiX+rx+cw,oy+ch,C.DIV,11)); osep.Visible=false
            local olbl=d(tx(opt,uiX+rx+14,oy+ch/2-6,11,i==vi and C.ACC or C.TXT,false,11)); olbl.Visible=false
            table.insert(optRecs,{bg=obg,sep=osep,lbl=olbl})
        end
        local b={tab=tname,isDD=true,outline=out2,bg=bg2,lbl=lbl2,valLbl=val2,arrow=arr2,
            opts=optRecs,options=opts,selected=vi,ddOpen=false,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,cb=cb}
        table.insert(btns,b); return b
    end

    local function mkColorPicker(tname,label,ry,initCol,cb)
        local rx=rx0(); local cw=cw0(); local ch=RH
        local bg2=d(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3)); corner(bg2,4)
        local sep2=d(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4))
        local lbl2=d(tx(label,uiX+rx+10,uiY+ry+ch/2-6,12,C.TXT,false,8))
        local cols={
            Color3.fromRGB(70,120,255),Color3.fromRGB(210,55,55),Color3.fromRGB(45,190,95),
            Color3.fromRGB(255,175,80),Color3.fromRGB(180,80,255),Color3.fromRGB(215,220,240)
        }
        local tw2=(#cols*19)-5; local sx0=uiX+rx+cw-tw2-10; local sws={}
        for i,col in ipairs(cols) do
            local sx=sx0+(i-1)*19; local sy=uiY+ry+ch/2-7
            local sw=d(sq(sx,sy,14,14,col,true,6)); corner(sw,3)
            local sb=d(sq(sx-1,sy-1,16,16,i==1 and C.TXT or C.BOR,false,7,1)); corner(sb,3)
            table.insert(sws,{s=sw,b=sb,col=col})
        end
        local b={tab=tname,isCP=true,bg=bg2,sep=sep2,lbl=lbl2,swatches=sws,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,selected=1,value=cols[1],cb=cb}
        table.insert(btns,b); return b
    end

    local function mkLog(tname,lines,ry,starFirst)
        local rx=rx0(); local cw=cw0()
        local lnH=18; local starH=starFirst and 26 or 0; local pad=10
        local ch=starH+(#lines-(starFirst and 1 or 0))*lnH+pad*2
        local bg2=d(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3)); corner(bg2,6)
        local lbls={}
        for i,line in ipairs(lines) do
            local l=Drawing.new("Text"); d(l)
            if starFirst and i==1 then
                l.Text=line; l.Position=Vector2.new(uiX+rx+cw/2,uiY+ry+pad)
                l.Size=14; l.Color=Color3.fromRGB(255,200,40); l.Center=true
                l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            else
                local off=starFirst and (starH+pad+(i-2)*lnH) or (pad+(i-1)*lnH)
                l.Text=line; l.Position=Vector2.new(uiX+rx+8,uiY+ry+off)
                l.Size=11; l.Color=C.TXT; l.Outline=false; l.Font=Drawing.Fonts.Minecraft
            end
            l.Transparency=1; l.ZIndex=8; l.Visible=true
            table.insert(lbls,l)
        end
        local b={tab=tname,isLog=true,bg=bg2,lbl=bg2,logs=lbls,
            rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,
            starFirst=starFirst,starH=starH,lnH=lnH,pad=pad}
        table.insert(btns,b); return b
    end

    -- ── tab API factory ───────────────────────────────────
    local function makeTabAPI(tname)
        if tabAPI[tname] then return tabAPI[tname] end
        tabRows[tname]=10; tabScroll[tname]=0
        local api={}
        local curSec=nil
        local function nextY(h)
            local y=tabRows[tname]; tabRows[tname]=y+h; return y
        end
        local function tag(b) if curSec then b.section=curSec end end

        function api:Div(lbl,collapsible)
            if collapsible==nil then collapsible=true end
            local b=mkDiv(tname,lbl,nextY(22),collapsible); tag(b)
            curSec=collapsible and lbl or nil
        end
        function api:Toggle(lbl,init,cb,desc)   tag(mkToggle(tname,lbl,nextY(RH+6),init,cb,desc)) end
        function api:Slider(lbl,mn,mx,iv,cb,fl,desc) tag(mkSlider(tname,lbl,nextY(RH+14),mn,mx,iv,cb,fl,desc)) end
        function api:Button(lbl,col,cb,lc)      tag(mkButton(tname,lbl,nextY(RH+6),col,cb,lc)) end
        function api:Dropdown(lbl,opts,ii,cb)   tag(mkDropdown(tname,lbl,nextY(RH+6),opts,ii,cb)) end
        function api:ColorPicker(lbl,ic,cb)     tag(mkColorPicker(tname,lbl,nextY(RH+6),ic,cb)) end
        function api:Log(lines,sf)
            local lnH=18; local starH=sf and 26 or 0
            local h=starH+(#lines-(sf and 1 or 0))*lnH+20+6
            local bRef=mkLog(tname,lines,nextY(h),sf); tag(bRef)
            local la={}
            function la:SetLines(nl)
                for i,l in ipairs(bRef.logs) do
                    l.Text=nl[i] or ""; l.Visible=nl[i]~=nil and bRef.bg.Visible
                end
            end
            return la
        end
        tabAPI[tname]=api; return api
    end

    -- ════════════════════════════════════════════════════════
    function win:Tab(name)
        table.insert(tabOrder,name); return makeTabAPI(name)
    end

    function win:SettingsTab(destroyCb)
        local s=self:Tab("Settings")
        s:Div("Appearance",false)
        s:Dropdown("Theme",{"Check it","Dark","Moon","Grass","Light"},1,function(v)
            applyTheme(v)
        end)
        s:Div("Keybind",false)
        s:Button("Menu Key: F1",nil,nil)
        local keyBtnIdx=#btns
        s:Button("Click to Rebind",Color3.fromRGB(14,20,40),nil)
        local rebindBtnIdx=#btns
        s:Div("Danger",false)
        s:Button("Destroy Menu",Color3.fromRGB(28,7,7),destroyCb,Color3.fromRGB(210,55,55))
        -- wire rebind
        btns[rebindBtnIdx].rebind=true
        btns[rebindBtnIdx].keyInfoIdx=keyBtnIdx
        return s
    end

    function win:ApplyTheme(name) applyTheme(name) end

    function win:Destroy()
        destroyed=true
        for _,dr in ipairs(allD) do pcall(function() dr:Remove() end) end
    end

    -- ════════════════════════════════════════════════════════
    function win:Init(defaultTab,charLabelFn)

        -- ── build chrome ─────────────────────────────────
        dShad  =d(sq(uiX-2,uiY-2,W+4,FH+4,Color3.fromRGB(0,0,4),true,0))
        dMain  =d(sq(uiX,uiY,W,FH,C.BG,true,1))
        dGlow1 =d(sq(uiX-1,uiY-1,W+2,FH+2,C.ACC,false,1,1)); dGlow1.Transparency=0.88
        dGlow2 =d(sq(uiX-2,uiY-2,W+4,FH+4,C.ACC,false,0,2)); dGlow2.Transparency=0.35
        dBor   =d(sq(uiX,uiY,W,FH,C.BOR,false,3,1)); dBor.Transparency=0.22
        dTop   =d(sq(uiX+1,uiY+1,W-2,TOP,C.TOP,true,3))
        dTopLn =d(ln(uiX+1,uiY+TOP,uiX+W-1,uiY+TOP,C.BOR,4))
        dTitleW=d(tx(titleA,uiX+14,uiY+12,14,C.TXT,false,9,Drawing.Fonts.SystemBold))
        dTitleA=d(tx(titleB,uiX+86,uiY+12,14,C.ACC,false,9,Drawing.Fonts.SystemBold))
        dTitleG=d(tx(gameName,uiX+86+#(titleB or "")*8+14,uiY+12,13,Color3.fromRGB(255,175,80),false,9))
        dKeyLbl=d(tx("F1",uiX+W-24,uiY+14,11,C.GRY,false,9))
        dDotY  =d(sq(uiX+W-57,uiY+15,8,8,Color3.fromRGB(190,148,0),true,9)); corner(dDotY,4)
        dDotR  =d(sq(uiX+W-44,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9)); corner(dDotR,4)
        dSide  =d(sq(uiX+1,uiY+TOP,SB-1,FH-TOP-FOT-1,C.SIDE,true,2))
        dSideLn=d(ln(uiX+SB,uiY+TOP,uiX+SB,uiY+FH-FOT,C.BOR,4))
        dCont  =d(sq(uiX+SB,uiY+TOP,CW-1,FH-TOP-FOT-1,C.CONT,true,2))
        dFoot  =d(sq(uiX+1,uiY+FH-FOT,W-2,FOT-1,C.TOP,true,3))
        dFotLn =d(ln(uiX+1,uiY+FH-FOT,uiX+W-1,uiY+FH-FOT,C.BOR,4))
        dWelcome=d(tx("welcome,",uiX+14,uiY+FH-FOT+10,11,C.TXT,false,9))
        dName  =d(tx(lp.Name,uiX+80,uiY+FH-FOT+10,11,Color3.fromRGB(45,190,95),false,9,Drawing.Fonts.SystemBold))
        dCharLbl=d(tx("",uiX+80+#lp.Name*8+4,uiY+FH-FOT+10,11,C.GRY,false,9))
        -- scrollbar
        dScrBg   =d(sq(uiX+W-6,uiY+TOP+2,4,FH-TOP-FOT-4,Color3.fromRGB(18,20,28),true,4)); dScrBg.Visible=false
        dScrThumb=d(sq(uiX+W-6,uiY+TOP+2,4,20,C.ACC,true,5)); dScrThumb.Visible=false

        -- sidebar tab buttons
        for i,name in ipairs(tabOrder) do
            local tY=TOP+8+(i-1)*34
            local isSel=name==defaultTab
            local tbg=d(sq(uiX+7,uiY+tY,SB-14,26,isSel and C.TSEL or C.SIDE,true,3)); corner(tbg,5)
            local tacc=d(sq(uiX+7,uiY+tY,3,26,isSel and C.ACC or C.SIDE,true,4)); corner(tacc,2)
            local tlW=d(tx(name,uiX+18,uiY+tY+7,11,C.TXT,false,8)); tlW.Visible=isSel
            local tlG=d(tx(name,uiX+18,uiY+tY+7,11,C.GRY,false,8)); tlG.Visible=not isSel
            table.insert(tabObjs,{bg=tbg,acc=tacc,lbl=tlW,lblG=tlG,name=name,sel=isSel,tY=tY,selT=isSel and 1 or 0})
        end

        -- mini bar chrome
        dMS  =d(sq(uiX-2,uiY-2,W+4,MH+4,Color3.fromRGB(0,0,4),true,0)); dMS.Visible=false
        dMB  =d(sq(uiX,uiY,W,MH,C.BG,true,1)); dMB.Visible=false
        dMG1 =d(sq(uiX-1,uiY-1,W+2,MH+2,C.ACC,false,1,1)); dMG1.Visible=false
        dMG2 =d(sq(uiX-2,uiY-2,W+4,MH+4,C.ACC,false,0,2)); dMG2.Visible=false
        dMBor=d(sq(uiX,uiY,W,MH,C.BOR,false,3,1)); dMBor.Visible=false
        dMTop=d(sq(uiX+1,uiY+1,W-2,TOP,C.TOP,true,3)); dMTop.Visible=false
        dMLn =d(ln(uiX+1,uiY+TOP,uiX+W-1,uiY+TOP,C.BOR,4)); dMLn.Visible=false
        dMAct=d(sq(uiX+1,uiY+TOP,W-2,MH-TOP-1,C.MINI,true,2)); dMAct.Visible=false
        dMTW =d(tx(titleA,uiX+14,uiY+12,14,C.TXT,false,9,Drawing.Fonts.SystemBold)); dMTW.Visible=false
        dMTA =d(tx(titleB,uiX+86,uiY+12,14,C.ACC,false,9,Drawing.Fonts.SystemBold)); dMTA.Visible=false
        dMTG =d(tx(gameName,uiX+86+#(titleB or "")*8+14,uiY+12,13,Color3.fromRGB(255,175,80),false,9)); dMTG.Visible=false
        dMKey=d(tx("F1",uiX+W-24,uiY+14,11,C.GRY,false,9)); dMKey.Visible=false
        dMDY =d(sq(uiX+W-57,uiY+15,8,8,C.ACC,true,9)); corner(dMDY,4); dMDY.Visible=false
        dMDR =d(sq(uiX+W-44,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9)); corner(dMDR,4); dMDR.Visible=false
        for i=1,12 do
            local lb=d(Drawing.new("Text"))
            lb.Text=""; lb.Size=13; lb.Color=C.TXT; lb.Center=false
            lb.Outline=true; lb.Font=Drawing.Fonts.System
            lb.Transparency=1; lb.ZIndex=9; lb.Visible=false
            table.insert(miniLbls,lb)
        end

        -- set default tab
        curTab=defaultTab
        recalcTab(defaultTab)
        for _,tb in ipairs(tabObjs) do
            tb.sel=tb.name==defaultTab
            tb.lbl.Visible=tb.sel; tb.lblG.Visible=not tb.sel
        end

        -- ── LOADING SCREEN (synchronous, ZIndex 50+) ─────
        -- Create these BEFORE hiding chrome so they're on top
        local _lt=(gameName~="" and gameName~="Game Name" and gameName) or (titleA.." "..titleB)

        local lBg=d(sq(uiX,uiY,W,FH,Color3.fromRGB(7,9,17),true,50)); corner(lBg,12)
        local lTitle=d(tx(_lt.." Loading",uiX+W/2,uiY+FH/2-30,14,C.TXT,true,51,Drawing.Fonts.Minecraft))
        lTitle.Outline=true
        local lDesc=d(tx("Connecting...",uiX+W/2,uiY+FH/2-10,10,C.GRY,true,51,Drawing.Fonts.Minecraft))
        local lBarBg=d(sq(uiX+W/2-80,uiY+FH/2+12,160,6,C.DIM,true,51)); corner(lBarBg,3)
        local lBar=d(sq(uiX+W/2-80,uiY+FH/2+12,1,6,C.ACC,true,52)); corner(lBar,3)
        local lPct=d(tx("0%",uiX+W/2,uiY+FH/2+26,9,C.GRY,true,51,Drawing.Fonts.Minecraft))

        -- hide all chrome (loading screen is already visible above)
        showAll(false)

        -- ── animation loop ────────────────────────────────
        local animConn
        local togAnimT={}  -- per-toggle selT for dot slide

        animConn=RunService.RenderStepped:Connect(function(dt)
            if destroyed then animConn.Disconnect(); return end
            local t=os.clock()

            -- glow pulse (only when menu open)
            if isOpen and not isLoading and dGlow1 then
                local p=math.abs(math.sin(t*1.1))
                dGlow1.Transparency=0.82+0.12*p
                dGlow2.Transparency=0.28+0.08*p
            end
            if isMini and dMG1 then
                local p=math.abs(math.sin(t*1.3))
                dMG1.Transparency=0.82+0.12*p
            end

            -- tab button lerp
            for _,tb in ipairs(tabObjs) do
                local tgt=tb.sel and 1 or 0
                tb.selT=tb.selT+((tgt-tb.selT)*math.min(dt*10,1))
                tb.bg.Color=lerpC(C.SIDE,C.TSEL,tb.selT)
                tb.acc.Color=lerpC(C.SIDE,C.ACC,tb.selT)
            end

            -- toggle dot slide
            for _,b in ipairs(btns) do
                if b.isTog and b.tab==curTab and b.tog and b.tog.Visible then
                    local tgt=b.state and 1 or 0
                    b.selT=b.selT+((tgt-b.selT)*math.min(dt*12,1))
                    b.tog.Color=lerpC(C.OFF,C.ON,b.selT)
                    b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.selT)
                    local sc=tabScroll[b.tab] or 0; local ay=uiY+b.ry-sc
                    local dox=b.rx+b.cw-TW-8
                    b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-TH/2)
                    b.dot.Position=Vector2.new(uiX+dox+2+(TW-TH)*b.selT,ay+b.ch/2-TH/2+2)
                end
            end

            -- char label
            if charLabelFn and dCharLbl and isOpen then
                local v=pcall(function()
                    local s=charLabelFn(); if s and s~="" then dCharLbl.Text=" | "..s end
                end)
            end
        end)

        -- ── loading animation (task.spawn) ────────────────
        task.spawn(function()
            local stages={
                {"Connecting...",     0.25, 0.5},
                {"Building UI...",    0.55, 0.45},
                {"Almost ready...",   0.85, 0.4},
                {"Done!",             1.0,  0.25},
            }
            local barPct=0
            for _,stage in ipairs(stages) do
                local label,target,hold=stage[1],stage[2],stage[3]
                lDesc.Text=label
                local sv=barPct; local dur=0.4; local t0=os.clock()
                repeat
                    task.wait()
                    local tf=math.min((os.clock()-t0)/dur,1)
                    local et=tf<0.5 and 4*tf^3 or 1-(-2*tf+2)^3/2
                    barPct=sv+(target-sv)*et
                    lBar.Size=Vector2.new(math.max(1,barPct*160),6)
                    lPct.Text=math.floor(barPct*100).."%"
                until tf>=1 or destroyed
                barPct=target; lBar.Size=Vector2.new(target*160,6); lPct.Text=math.floor(target*100).."%"
                task.wait(hold)
            end
            task.wait(0.2)

            -- fade out loading screen
            local t1=os.clock(); local dur2=0.35
            repeat
                task.wait()
                local a=math.max(0,1-(os.clock()-t1)/dur2)
                lBg.Transparency=a; lTitle.Transparency=a; lDesc.Transparency=a
                lBarBg.Transparency=a; lBar.Transparency=a; lPct.Transparency=a
                lBg.Visible=a>0.01; lTitle.Visible=a>0.01; lDesc.Visible=a>0.01
                lBarBg.Visible=a>0.01; lBar.Visible=a>0.01; lPct.Visible=a>0.01
            until os.clock()-t1>=dur2 or destroyed

            -- remove loading drawings
            for _,dr in ipairs({lBg,lTitle,lDesc,lBarBg,lBar,lPct}) do
                dr.Visible=false; pcall(function() dr:Remove() end)
            end

            isLoading=false
            isOpen=true

            -- show menu immediately, no fade (fade can be added later once confirmed working)
            showAll(true)
            reposChrome()
            updScr()
            pcall(function() setrobloxinput(false) end)
            print("[UILib] menu ready")
        end)

        -- ═══════════════════════════════════════════════════
        -- INPUT LOOP — ismouse1pressed + iskeypressed polling
        -- This is the ONLY correct way on Matcha
        -- ═══════════════════════════════════════════════════
        local wasDown=false        -- previous frame mouse state
        local listenKey=false
        local scrDrag=false; local scrDragOY=0
        local winDrag=false; local winDOX,winDOY=0,0
        local miniDrag=false; local miniDOX,miniDOY=0,0
        local slDrag=nil           -- slider being dragged
        local prevScroll=0         -- for scroll detection via mousescroll
        local keyWas={}            -- previous frame key states

        task.spawn(function()
            while not destroyed do
                task.wait()

                local mx,my=mouse.X,mouse.Y
                local isDown=ismouse1pressed()
                local clicked=isDown and not wasDown   -- rising edge = click
                local released=not isDown and wasDown  -- falling edge = release

                -- ── KEY: toggle menu ─────────────────────
                local keyNow=iskeypressed(menuKeyCode)
                if keyNow and not keyWas[menuKeyCode] then
                    if not isLoading then
                        if isMini then
                            -- restore
                            isMini=false; showMini(false); isOpen=true; showAll(true); reposChrome(); updScr()
                            pcall(function() setrobloxinput(false) end)
                        elseif isOpen then
                            isOpen=false; showAll(false)
                            pcall(function() setrobloxinput(true) end)
                        else
                            isOpen=true; showAll(true); reposChrome(); updScr()
                            pcall(function() setrobloxinput(false) end)
                        end
                    end
                end
                keyWas[menuKeyCode]=keyNow

                -- ── SCROLL ───────────────────────────────
                -- use mouse.WheelForward/Backward if they exist
                if isOpen and not isLoading and hit(uiX+SB,uiY+TOP,CW,cH()) then
                    pcall(function()
                        if mouse.WheelForward then
                            -- handled via event if connected
                        end
                    end)
                end

                -- ── DRAG: window ──────────────────────────
                if winDrag then
                    if isDown then
                        local vW,vH=getVP()
                        uiX=clamp(mx-winDOX,0,vW-W)
                        uiY=clamp(my-winDOY,0,vH-FH)
                        reposChrome()
                    else
                        winDrag=false
                    end
                end

                -- ── DRAG: mini bar ────────────────────────
                if miniDrag then
                    if isDown then
                        local vW,vH=getVP()
                        uiX=clamp(mx-miniDOX,0,vW-W)
                        uiY=clamp(my-miniDOY,0,vH-MH)
                        reposMini()
                    else
                        miniDrag=false
                    end
                end

                -- ── DRAG: scrollbar ───────────────────────
                if scrDrag and curTab then
                    if isDown then
                        local total=tabRows[curTab] or 0
                        local maxSc=math.max(0,total-cH()+8)
                        if maxSc>0 then
                            local sbH=FH-TOP-FOT-4
                            local tH=math.max(20,math.min(sbH,(cH()/(total+1))*sbH))
                            local rf=clamp((my-uiY-TOP-2-scrDragOY)/(sbH-tH),0,1)
                            doScroll(rf*maxSc-(tabScroll[curTab] or 0))
                        end
                    else
                        scrDrag=false
                    end
                end

                -- ── DRAG: slider ──────────────────────────
                if slDrag then
                    if isDown then
                        local b=slDrag
                        local ax=uiX+b.rx+8
                        local frac=clamp((mx-ax)/b.trkW,0,1)
                        b.value=b.minV+frac*(b.maxV-b.minV)
                        local sc=tabScroll[b.tab] or 0
                        local ty=uiY+b.ry-sc+b.ch-12
                        local fx=ax+frac*b.trkW
                        b.fill.To=Vector2.new(fx,ty)
                        b.handle.Position=Vector2.new(fx-4,ty-4)
                        b.lbl.Text=b.baseLbl..": "..(b.isFloat and string.format("%.1f",b.value) or tostring(math.floor(b.value)))
                        if b.cb then pcall(b.cb,b.value) end
                    else
                        slDrag=nil
                    end
                end

                -- ── CLICK handling ────────────────────────
                if clicked then
                  (function()

                    -- MINI BAR clicks
                    if isMini then
                        if hit(uiX+W-47,uiY+11,13,13) then
                            isMini=false; showMini(false)
                        elseif hit(uiX+W-60,uiY+11,13,13) then
                            isMini=false; showMini(false); isOpen=true; showAll(true); reposChrome(); updScr()
                            pcall(function() setrobloxinput(false) end)
                        elseif hit(uiX,uiY,W,MH) then
                            miniDrag=true; miniDOX=mx-uiX; miniDOY=my-uiY
                        end
                        return
                    end

                    if not isOpen or isLoading then return end

                    -- CLOSE dot (red)
                    if hit(uiX+W-47,uiY+11,13,13) then
                        isOpen=false; showAll(false)
                        pcall(function() setrobloxinput(true) end)
                        return
                    end
                    -- MINIMIZE dot (yellow)
                    if hit(uiX+W-60,uiY+11,13,13) then
                        isOpen=false; showAll(false)
                        isMini=true; showMini(true); reposMini(); refreshMiniLbls()
                        pcall(function() setrobloxinput(true) end)
                        return
                    end

                    -- SCROLLBAR click
                    if curTab then
                        local total=tabRows[curTab] or 0
                        local maxSc=math.max(0,total-cH()+8)
                        if maxSc>0 and hit(uiX+W-10,uiY+TOP,12,FH-TOP-FOT) then
                            local sbH=FH-TOP-FOT-4
                            local tH=math.max(20,math.min(sbH,(cH()/(total+1))*sbH))
                            local sc=tabScroll[curTab] or 0
                            local thumbY=uiY+TOP+2+clamp(sc/maxSc,0,1)*(sbH-tH)
                            if hit(uiX+W-10,thumbY,12,tH) then
                                scrDrag=true; scrDragOY=my-thumbY
                            else
                                doScroll((clamp((my-uiY-TOP-2-tH/2)/(sbH-tH),0,1)*maxSc)-(sc))
                            end
                            return
                        end
                    end

                    -- WINDOW DRAG (topbar)
                    if hit(uiX,uiY,W,TOP) then
                        winDrag=true; winDOX=mx-uiX; winDOY=my-uiY; return
                    end

                    -- SIDEBAR tab buttons
                    for _,tb in ipairs(tabObjs) do
                        if hit(uiX+7,uiY+tb.tY,SB-14,26) then
                            switchTab(tb.name); return
                        end
                    end

                    if not curTab then return end

                    -- close open DD if clicking outside
                    if openDD then
                        local sc2=tabScroll[curTab] or 0
                        local inH=hit(uiX+openDD.rx,uiY+openDD.ry-sc2,openDD.cw,openDD.ch)
                        local inO=false
                        for _,o in ipairs(openDD.opts) do
                            if o.bg.Visible and hit(o.bg.Position.X,o.bg.Position.Y,openDD.cw,openDD.ch) then inO=true end
                        end
                        if not inH and not inO then
                            openDD.ddOpen=false; openDD.arrow.Text="v"
                            for _,o in ipairs(openDD.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
                            openDD=nil; recalcTab(curTab)
                        end
                    end

                    -- ELEMENT clicks
                    local sc3=tabScroll[curTab] or 0
                    for _,b in ipairs(btns) do
                        if b.tab~=curTab then continue end
                        if b.section and sections[b.section] then continue end
                        local bx=uiX+b.rx; local by=uiY+b.ry-sc3

                        -- slider: start drag on whole row
                        if b.isSlider then
                            if hit(bx,by,b.cw,b.ch) then slDrag=b; break end
                            continue
                        end

                        if not hit(bx,by,b.cw,b.ch) then continue end

                        -- TOGGLE
                        if b.isTog then
                            b.state=not b.state
                            if b.cb then pcall(b.cb,b.state) end
                            refreshMiniLbls()
                            break
                        end

                        -- BUTTON
                        if b.isBtn then
                            if b.rebind then
                                listenKey=true
                                b.lbl.Text="Press any key..."
                                -- poll for next keypress
                                task.spawn(function()
                                    task.wait(0.1)
                                    while not destroyed do
                                        task.wait()
                                        for kc=0x08,0x7F do
                                            if iskeypressed(kc) and not keyWas[kc] then
                                                menuKeyCode=kc
                                                -- build key name
                                                local kn
                                                if kc>=0x41 and kc<=0x5A then kn=string.char(kc)
                                                elseif kc>=0x30 and kc<=0x39 then kn=tostring(kc-0x30)
                                                elseif kc>=0x70 and kc<=0x7B then kn="F"..(kc-0x6F)
                                                else kn="0x"..string.format("%02X",kc) end
                                                dKeyLbl.Text=kn; dMKey.Text=kn
                                                b.lbl.Text="Click to Rebind"
                                                if b.keyInfoIdx and btns[b.keyInfoIdx] then
                                                    btns[b.keyInfoIdx].lbl.Text="Menu Key: "..kn
                                                end
                                                listenKey=false; return
                                            end
                                        end
                                    end
                                end)
                            elseif b.cb then pcall(b.cb) end
                            break
                        end

                        -- DROPDOWN
                        if b.isDD then
                            -- check if clicking an open option
                            if b.ddOpen then
                                local picked=false
                                for i,o in ipairs(b.opts) do
                                    if o.bg.Visible and hit(o.bg.Position.X,o.bg.Position.Y,b.cw,b.ch) then
                                        b.selected=i; b.valLbl.Text=b.options[i]
                                        for j,o2 in ipairs(b.opts) do o2.lbl.Color=j==i and C.ACC or C.TXT end
                                        b.ddOpen=false; b.arrow.Text="v"
                                        for _,o2 in ipairs(b.opts) do o2.bg.Visible=false; o2.sep.Visible=false; o2.lbl.Visible=false end
                                        openDD=nil; recalcTab(curTab)
                                        if b.cb then pcall(b.cb,b.options[i],i) end
                                        picked=true; break
                                    end
                                end
                                if picked then break end
                            end
                            -- close other open DD
                            if openDD and openDD~=b then
                                openDD.ddOpen=false; openDD.arrow.Text="v"
                                for _,o in ipairs(openDD.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
                                openDD=nil; recalcTab(curTab)
                            end
                            -- toggle this DD
                            b.ddOpen=not b.ddOpen; b.arrow.Text=b.ddOpen and "^" or "v"
                            openDD=b.ddOpen and b or nil
                            if b.ddOpen then
                                for i,o in ipairs(b.opts) do
                                    local oy=uiY+b.ry-sc3+b.ch+((i-1)*b.ch)
                                    o.bg.Position=Vector2.new(uiX+b.rx,oy)
                                    o.bg.Size=Vector2.new(b.cw,b.ch)
                                    o.sep.From=Vector2.new(uiX+b.rx,oy+b.ch); o.sep.To=Vector2.new(uiX+b.rx+b.cw,oy+b.ch)
                                    o.lbl.Position=Vector2.new(uiX+b.rx+14,oy+b.ch/2-6)
                                    o.bg.Visible=true; o.sep.Visible=true; o.lbl.Visible=true
                                end
                            else
                                for _,o in ipairs(b.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
                            end
                            recalcTab(curTab); break
                        end

                        -- COLOR PICKER
                        if b.isCP then
                            for j,sw in ipairs(b.swatches) do
                                if hit(sw.s.Position.X,sw.s.Position.Y,14,14) then
                                    b.selected=j; b.value=sw.col
                                    for k,sw2 in ipairs(b.swatches) do sw2.b.Color=k==j and C.TXT or C.BOR end
                                    if b.cb then pcall(b.cb,sw.col) end; break
                                end
                            end
                            break
                        end

                        -- SECTION DIV collapse
                        if b.isDiv and b.collapsible then
                            sections[b.label]=not sections[b.label]
                            b.arrow.Text=sections[b.label] and ">" or "v"
                            recalcTab(curTab); break
                        end
                    end

                  end)()
                end -- clicked

                -- scroll wheel via polling iskeypressed not available,
                -- try mouse WheelForward signal if exists
                wasDown=isDown
            end -- while
        end)

        -- wire up scroll via mouse events (pcall so non-existent signals don't crash)
        pcall(function()
            mouse.WheelForward:Connect(function()
                if not isOpen or isLoading then return end
                if hit(uiX+SB,uiY+TOP,CW,cH()) then doScroll(-36) end
            end)
        end)
        pcall(function()
            mouse.WheelBackward:Connect(function()
                if not isOpen or isLoading then return end
                if hit(uiX+SB,uiY+TOP,CW,cH()) then doScroll(36) end
            end)
        end)

    end -- Init

    return win
end

_G.UILib=UILib
print("[UILib] v4.0 loaded")
return UILib
