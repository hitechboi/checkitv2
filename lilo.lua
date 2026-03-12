-- ═══════════════════════════════════════════════════════
--  Check it  UI Library  v3.0
--  Event-driven input (UIS) + RenderStepped animations
--  Smooth tweens: loading, open/close, minimize, tabs, dropdowns
-- ═══════════════════════════════════════════════════════
local UILib = {}

-- ── Services ─────────────────────────────────────────────
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local lp      = Players.LocalPlayer
local mouse   = lp:GetMouse()

-- ── RunService VM (os.clock based, Matcha compatible) ────
local RunService = (function()
    local RS = {}
    local _bindings = {}
    local _running = true
    local _lastT = os.clock()
    local _sortedBinds = {}
    local _bindCount = 0

    local function Signal()
        local s = {_conns={}}
        function s:Connect(fn)
            local c = {fn=fn, active=true}
            table.insert(s._conns, c)
            return {Disconnect=function() c.active=false; c.fn=nil end}
        end
        function s:Fire(...)
            local i=1
            while i<=#s._conns do
                local c=s._conns[i]
                if c.active then pcall(c.fn,...); i=i+1
                else table.remove(s._conns,i) end
            end
        end
        return s
    end

    RS.Heartbeat     = Signal()
    RS.RenderStepped = Signal()
    RS.Stepped       = Signal()

    function RS:BindToRenderStep(name,pri,fn)
        _bindings[name]={Priority=pri or 0,Function=fn}; _bindCount=-1
    end
    function RS:UnbindFromRenderStep(name)
        _bindings[name]=nil; _bindCount=-1
    end
    function RS:IsRunning() return _running end

    task.spawn(function()
        while _running do
            local now=os.clock()
            local dt=math.min(now-_lastT,1)
            _lastT=now

            RS.Stepped:Fire(now,dt)

            -- rebuild sorted bind cache if dirty
            local cnt=0; for _ in pairs(_bindings) do cnt=cnt+1 end
            if cnt~=_bindCount then
                _sortedBinds={}
                for _,bd in pairs(_bindings) do
                    if type(bd.Function)=="function" then table.insert(_sortedBinds,bd) end
                end
                table.sort(_sortedBinds,function(a,b) return a.Priority<b.Priority end)
                _bindCount=cnt
            end
            for _,bd in ipairs(_sortedBinds) do pcall(bd.Function,dt) end

            RS.RenderStepped:Fire(dt)
            RS.Heartbeat:Fire(dt)
            task.wait()
        end
    end)

    return RS
end)()

-- ── Themes ───────────────────────────────────────────────
local THEMES = {
    ["Check it"]={ACC=Color3.fromRGB(70,120,255), BG=Color3.fromRGB(9,11,20),
        SIDE=Color3.fromRGB(12,15,27),  CONT=Color3.fromRGB(11,13,23),
        TOP=Color3.fromRGB(7,9,17),     BOR=Color3.fromRGB(30,40,72),
        ROW=Color3.fromRGB(14,18,33),   TSEL=Color3.fromRGB(20,35,85),
        TXT=Color3.fromRGB(215,220,240),GRY=Color3.fromRGB(100,112,145),
        DIM=Color3.fromRGB(28,33,52),   ON=Color3.fromRGB(45,85,195),
        OFF=Color3.fromRGB(20,24,42),   ONDOT=Color3.fromRGB(175,198,255),
        OFFDOT=Color3.fromRGB(55,65,95),DIV=Color3.fromRGB(22,27,48),
        MINI=Color3.fromRGB(11,13,22)},
    ["Moon"]={ACC=Color3.fromRGB(150,150,165),BG=Color3.fromRGB(12,12,14),
        SIDE=Color3.fromRGB(16,16,18),  CONT=Color3.fromRGB(14,14,16),
        TOP=Color3.fromRGB(10,10,12),   BOR=Color3.fromRGB(40,40,46),
        ROW=Color3.fromRGB(18,18,22),   TSEL=Color3.fromRGB(30,30,36),
        TXT=Color3.fromRGB(220,220,225),GRY=Color3.fromRGB(120,120,130),
        DIM=Color3.fromRGB(40,40,45),   ON=Color3.fromRGB(100,100,115),
        OFF=Color3.fromRGB(25,25,30),   ONDOT=Color3.fromRGB(200,200,215),
        OFFDOT=Color3.fromRGB(70,70,80),DIV=Color3.fromRGB(30,30,36),
        MINI=Color3.fromRGB(16,16,20)},
    ["Grass"]={ACC=Color3.fromRGB(60,200,100),BG=Color3.fromRGB(8,14,10),
        SIDE=Color3.fromRGB(10,18,13),  CONT=Color3.fromRGB(9,16,11),
        TOP=Color3.fromRGB(6,11,8),     BOR=Color3.fromRGB(25,55,35),
        ROW=Color3.fromRGB(11,20,14),   TSEL=Color3.fromRGB(18,45,25),
        TXT=Color3.fromRGB(200,235,210),GRY=Color3.fromRGB(90,130,105),
        DIM=Color3.fromRGB(20,40,28),   ON=Color3.fromRGB(30,140,65),
        OFF=Color3.fromRGB(15,30,20),   ONDOT=Color3.fromRGB(150,240,180),
        OFFDOT=Color3.fromRGB(45,80,58),DIV=Color3.fromRGB(18,35,24),
        MINI=Color3.fromRGB(10,18,13)},
    ["Light"]={ACC=Color3.fromRGB(50,100,255),BG=Color3.fromRGB(230,233,245),
        SIDE=Color3.fromRGB(215,220,235),CONT=Color3.fromRGB(220,224,238),
        TOP=Color3.fromRGB(200,205,225),BOR=Color3.fromRGB(170,178,210),
        ROW=Color3.fromRGB(210,214,230),TSEL=Color3.fromRGB(190,205,240),
        TXT=Color3.fromRGB(25,30,60),   GRY=Color3.fromRGB(90,100,140),
        DIM=Color3.fromRGB(180,185,210),ON=Color3.fromRGB(60,120,255),
        OFF=Color3.fromRGB(180,185,210),ONDOT=Color3.fromRGB(255,255,255),
        OFFDOT=Color3.fromRGB(130,140,175),DIV=Color3.fromRGB(185,190,215),
        MINI=Color3.fromRGB(205,210,228)},
    ["Dark"]={ACC=Color3.fromRGB(180,180,180),BG=Color3.fromRGB(4,4,6),
        SIDE=Color3.fromRGB(6,6,9),     CONT=Color3.fromRGB(5,5,8),
        TOP=Color3.fromRGB(3,3,5),      BOR=Color3.fromRGB(20,20,28),
        ROW=Color3.fromRGB(7,7,10),     TSEL=Color3.fromRGB(15,15,22),
        TXT=Color3.fromRGB(190,190,195),GRY=Color3.fromRGB(80,80,90),
        DIM=Color3.fromRGB(15,15,20),   ON=Color3.fromRGB(100,100,110),
        OFF=Color3.fromRGB(12,12,16),   ONDOT=Color3.fromRGB(220,220,225),
        OFFDOT=Color3.fromRGB(45,45,55),DIV=Color3.fromRGB(14,14,18),
        MINI=Color3.fromRGB(6,6,8)},
}
UILib.Themes = THEMES

-- ── Math helpers ─────────────────────────────────────────
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerp(a,b,t)   return a+(b-a)*t end
local function easeOut(t)    return 1-(1-t)^3 end          -- cubic ease-out
local function easeInOut(t)  return t<.5 and 4*t^3 or 1-(-2*t+2)^3/2 end
local function lerpC(a,b,t)
    return Color3.fromRGB(
        math.floor(lerp(a.R*255,b.R*255,t)),
        math.floor(lerp(a.G*255,b.G*255,t)),
        math.floor(lerp(a.B*255,b.B*255,t)))
end
local function getVP()
    local ok,s=pcall(function() return workspace.CurrentCamera.ViewportSize end)
    return (ok and s) and s.X or 1920,(ok and s) and s.Y or 1080
end

-- ── Drawing factories ────────────────────────────────────
local function sq(x,y,w,h,col,filled,zi,alpha,thick)
    local s=Drawing.new("Square")
    s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h)
    s.Color=col or Color3.new(1,1,1); s.Filled=filled~=false
    s.ZIndex=zi or 1; s.Transparency=alpha or 1
    if not(filled~=false) then s.Thickness=thick or 1 end
    s.Visible=true; return s
end
local function tx(str,x,y,sz,col,ctr,zi,bold)
    local t=Drawing.new("Text")
    t.Text=str; t.Position=Vector2.new(x,y); t.Size=sz or 12
    t.Color=col or Color3.new(1,1,1); t.Center=ctr or false
    t.Outline=false; t.ZIndex=zi or 3; t.Transparency=1
    t.Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System
    t.Visible=true; return t
end
local function ln(x1,y1,x2,y2,col,zi,thick)
    local l=Drawing.new("Line")
    l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2)
    l.Color=col or Color3.new(1,1,1); l.Transparency=1
    l.Thickness=thick or 1; l.ZIndex=zi or 2
    l.Visible=true; return l
end

-- ── Tween engine ─────────────────────────────────────────
-- A lightweight per-frame tween list.
-- Each entry: {obj, prop, from, to, dur, elapsed, ease, onDone}
-- For "h" (window height) we use a special key stored on the win state.
local tweens={}
local function tween(obj,prop,from,to,dur,ease,onDone)
    -- remove existing tween on same obj+prop
    for i=#tweens,1,-1 do
        local tw=tweens[i]
        if tw.obj==obj and tw.prop==prop then table.remove(tweens,i) end
    end
    table.insert(tweens,{obj=obj,prop=prop,from=from,to=to,dur=dur or 0.25,elapsed=0,ease=ease or easeOut,onDone=onDone})
end
local function stepTweens(dt)
    for i=#tweens,1,-1 do
        local tw=tweens[i]
        tw.elapsed=tw.elapsed+dt
        local t=clamp(tw.elapsed/tw.dur,0,1)
        local et=tw.ease(t)
        -- value interpolation
        local val
        if type(tw.from)=="number" then
            val=lerp(tw.from,tw.to,et)
        elseif typeof(tw.from)=="Color3" then
            val=lerpC(tw.from,tw.to,et)
        elseif typeof(tw.from)=="Vector2" then
            val=Vector2.new(lerp(tw.from.X,tw.to.X,et),lerp(tw.from.Y,tw.to.Y,et))
        end
        if val~=nil then
            pcall(function() tw.obj[tw.prop]=val end)
        end
        if t>=1 then
            if tw.onDone then pcall(tw.onDone) end
            table.remove(tweens,i)
        end
    end
end

-- Key name table
local KN={}
for i=0x41,0x5A do KN[i]=string.char(i) end
for i=0x30,0x39 do KN[i]=tostring(i-0x30) end
for k,v in pairs({[0x70]="F1",[0x71]="F2",[0x72]="F3",[0x73]="F4",[0x74]="F5",[0x75]="F6",[0x76]="F7",[0x77]="F8",[0x79]="F10",[0x7A]="F11",[0x7B]="F12",[0x20]="Space",[0x0D]="Enter",[0x1B]="Esc",[0x08]="Back"}) do KN[k]=v end
local function kname(k) return KN[k] or ("Key"..k) end

-- ── Layout ───────────────────────────────────────────────
local W=440; local FULL_H=400; local MINI_H=86
local SB=128; local TOP=40; local FOT=34
local RH=38; local PAD=10; local TW=34; local TH=17; local HDL=8
local CW=W-SB  -- content panel width

-- ═══════════════════════════════════════════════════════
function UILib.Window(titleA,titleB,gameName)
    local win={}
    local C={}; for k,v in pairs(THEMES["Check it"]) do C[k]=v end

    -- ── position / state ─────────────────────────────────
    local uiX,uiY=280,180
    local uiH=FULL_H                 -- actual current height (tweened)
    local uiHtgt=FULL_H
    local destroyed=false
    local isOpen=true                -- full menu visible
    local isMini=false               -- mini-bar mode
    local isLoading=true
    local menuKey=0x70               -- F1

    -- drag state
    local dragging=false; local dragOX,dragOY=0,0
    local miniDragging=false; local miniDOX,miniDOY=0,0
    local scrDragging=false; local scrDOY=0
    local sliderDrag=nil             -- ref to slider btn being dragged

    -- keybind listen
    local listenKey=false
    local iKeyInfoIdx,iKeyBindIdx

    -- ── drawing list ─────────────────────────────────────
    local allD={}   -- all drawings (for batch destroy)
    local function d(drawing) table.insert(allD,drawing); return drawing end

    -- ── tabs / elements ──────────────────────────────────
    local tabOrder={}    -- ordered tab names
    local tabObjs={}     -- sidebar tab drawing groups: {bg,acc,lbl,lblG,name,sel,selT}
    local tabAPI={}      -- tab builder APIs
    local tabRowH={}     -- total content height per tab (for scroll)
    local tabScroll={}   -- scroll offset per tab
    local btns={}        -- all element records
    local curTab=nil
    local openDD=nil
    local sections={}    -- section collapse state

    -- ── content area helpers ─────────────────────────────
    local function cH() return uiH-TOP-FOT end
    local function ctTop() return uiY+TOP end
    local function ctBot() return uiY+uiH-FOT end

    -- ── in-box hit test ──────────────────────────────────
    local function hit(x,y,w,h) return mouse.X>=x and mouse.X<x+w and mouse.Y>=y and mouse.Y<y+h end

    -- ── visibility: hide drawings outside content clip ───
    local function isClipped(b)
        local sc=tabScroll[b.tab] or 0
        local top=uiY+b.ry-sc
        return top+b.ch<=ctTop() or top>=ctBot()
    end

    local function setDrawings(b,vis)
        local v=vis and not isClipped(b)
        local function sv(dr) if dr then dr.Visible=v end end
        sv(b.bg); sv(b.outline); sv(b.lbl); sv(b.sep)
        sv(b.tog); sv(b.dot); sv(b.qbg); sv(b.qlb)
        sv(b.track); sv(b.fill); sv(b.handle); sv(b.dlbl)
        sv(b.valLbl); sv(b.arrow)
        if b.swatches then for _,sw in ipairs(b.swatches) do sv(sw.sq); sv(sw.bor) end end
        if b.logs then for _,l in ipairs(b.logs) do sv(l) end end
        if b.opts then for _,o in ipairs(b.opts) do
            local ov=v and b.ddOpen
            o.bg.Visible=ov; o.sep.Visible=ov; o.lbl.Visible=ov
        end end
    end

    -- ── position all drawings of a button ────────────────
    local function posBtn(b)
        local sc=tabScroll[b.tab] or 0
        local ax=uiX+b.rx; local ay=uiY+b.ry-sc
        b.bg.Position=Vector2.new(ax,ay)
        if b.outline then b.outline.Position=Vector2.new(ax,ay) end

        if b.isLog then
            for i,l in ipairs(b.logs) do
                if b.starFirst and i==1 then
                    l.Position=Vector2.new(ax+b.cw/2,ay+b.pad)
                else
                    local off=b.starFirst and (b.starH+b.pad+(i-2)*b.lnH) or (b.pad+(i-1)*b.lnH)
                    l.Position=Vector2.new(ax+8,ay+off)
                end
            end
            return
        end

        if b.sep then b.sep.From=Vector2.new(ax,ay+b.ch); b.sep.To=Vector2.new(ax+b.cw,ay+b.ch) end

        if b.isSlider then
            b.lbl.Position=Vector2.new(ax+8,ay+7)
            if b.dlbl then b.dlbl.Position=Vector2.new(ax+8,ay+21) end
            local ty=ay+b.ch-12
            local frac=clamp((b.value-b.minV)/(b.maxV-b.minV),0,1)
            local fx=ax+8+frac*b.trkW
            b.track.From=Vector2.new(ax+8,ty); b.track.To=Vector2.new(ax+8+b.trkW,ty)
            b.fill.From=Vector2.new(ax+8,ty);  b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
        elseif b.isDiv then
            b.lbl.Position=Vector2.new(ax+6,ay)
            b.sep.From=Vector2.new(ax,ay+13); b.sep.To=Vector2.new(ax+b.cw,ay+13)
            if b.arrow then b.arrow.Position=Vector2.new(ax+b.cw-8,ay) end
        else
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            if b.tog then
                local dox=b.rx+b.cw-TW-8
                b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-TH/2)
                -- dot position animated by selT
                local dx=uiX+dox+2+(TW-TH)*b.selT
                b.dot.Position=Vector2.new(dx,ay+b.ch/2-TH/2+2)
            end
            if b.qbg then
                local qx=uiX+b.rx+b.cw-TW-30; local qy=ay+b.ch/2-7
                b.qbg.Position=Vector2.new(qx,qy)
                if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+2) end
            end
            if b.valLbl then b.valLbl.Position=Vector2.new(ax+b.cw-62,ay+b.ch/2-6) end
            if b.arrow  then b.arrow.Position=Vector2.new(ax+b.cw-16,ay+b.ch/2-6) end
            if b.outline then b.outline.Position=Vector2.new(ax,ay) end
            if b.swatches then
                local tw2=(#b.swatches*19)-5; local sx0=ax+b.cw-tw2-10
                for i,sw in ipairs(b.swatches) do
                    local sx=sx0+(i-1)*19; local sy=ay+b.ch/2-7
                    sw.sq.Position=Vector2.new(sx,sy); sw.bor.Position=Vector2.new(sx-1,sy-1)
                end
            end
            -- dropdown options
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
    end

    -- ── chrome refs ──────────────────────────────────────
    local dShad,dMain,dBor,dGlow1,dGlow2
    local dTop,dTopLn
    local dTitleW,dTitleA,dTitleG
    local dKeyLbl,dDotY,dDotR
    local dSide,dSideLn,dCont,dFoot,dFotLn,dCharLbl
    local dWelcome,dNameTxt
    local dScrBg,dScrThumb
    local dMiniShad,dMiniBg,dMiniBor,dMiniGlow1,dMiniGlow2
    local dMiniTop,dMiniLn,dMiniActBg
    local dMiniTW,dMiniTA,dMiniTG,dMiniKey,dMiniDotY,dMiniDotR
    local miniActLbls={}

    -- ── global fade (menu open/close) ────────────────────
    local globalAlpha=1.0    -- 1=fully open, 0=fully closed

    -- drawings that belong to the full menu chrome
    local chromeD={}
    local function creg(drawing) d(drawing); table.insert(chromeD,drawing); return drawing end
    -- per-tab drawing alpha groups
    local tabAlpha={}  -- {[tabName]=alpha 0..1}

    -- apply globalAlpha * tabAlpha to all drawings
    local function flushAlpha()
        local ga=globalAlpha
        for _,dr in ipairs(chromeD) do
            dr.Visible=ga>0.01; if ga>0.01 then dr.Transparency=ga end
        end
        for _,b in ipairs(btns) do
            local ta=tabAlpha[b.tab] or 0
            local a=ga*ta
            local vis=a>0.01 and not isClipped(b)
            local function sv(dr,override)
                if not dr then return end
                dr.Visible=(override==nil and vis) or (override==true and vis)
                if dr.Visible then dr.Transparency=a end
            end
            sv(b.bg); sv(b.outline); sv(b.sep)
            if not b.isLog then sv(b.lbl) end
            sv(b.tog); sv(b.dot); sv(b.qbg); sv(b.qlb)
            sv(b.track); sv(b.fill); sv(b.handle); sv(b.dlbl)
            sv(b.valLbl); sv(b.arrow)
            if b.swatches then for _,sw in ipairs(b.swatches) do sv(sw.sq); sv(sw.bor) end end
            if b.logs then for _,l in ipairs(b.logs) do sv(l) end end
            if b.opts then for _,o in ipairs(b.opts) do
                local ov=vis and b.ddOpen
                o.bg.Visible=ov; o.sep.Visible=ov; o.lbl.Visible=ov
                if ov then o.bg.Transparency=a; o.sep.Transparency=a; o.lbl.Transparency=a end
            end end
        end
        -- tab buttons
        for _,t in ipairs(tabObjs) do
            local function sv2(dr) if dr then dr.Visible=ga>0.01; if ga>0.01 then dr.Transparency=ga end end end
            sv2(t.bg); sv2(t.acc)
            -- selected tab shows white label, unselected shows gray
            if t.lbl then t.lbl.Visible=ga>0.01 and t.sel; if t.lbl.Visible then t.lbl.Transparency=ga end end
            if t.lblG then t.lblG.Visible=ga>0.01 and not t.sel; if t.lblG.Visible then t.lblG.Transparency=ga end end
        end
        -- scrollbar
        if dScrBg then
            local total=tabRowH[curTab] or 0
            local maxSc=math.max(0,total-cH()+8)
            local show=ga>0.01 and maxSc>0 and isOpen
            dScrBg.Visible=show; dScrThumb.Visible=show
        end
    end

    -- ── scrollbar update ─────────────────────────────────
    local function updateScrollbar()
        if not (dScrBg and curTab) then return end
        local total=tabRowH[curTab] or 0
        local maxSc=math.max(0,total-cH()+8)
        if maxSc<=0 then dScrBg.Visible=false; dScrThumb.Visible=false; return end
        local sbgH=uiH-TOP-FOT-4
        local sc=tabScroll[curTab] or 0
        local thumbH=math.max(20,math.min(sbgH,(cH()/(total+1))*sbgH))
        dScrThumb.Size=Vector2.new(4,thumbH)
        dScrThumb.Position=Vector2.new(uiX+W-6, uiY+TOP+2+clamp(sc/maxSc,0,1)*(sbgH-thumbH))
        dScrBg.Position=Vector2.new(uiX+W-6,uiY+TOP+2); dScrBg.Size=Vector2.new(4,sbgH)
    end

    -- ── reposition chrome after uiX/uiY/uiH change ───────
    local function reposChrome()
        local h=uiH
        dShad.Position=Vector2.new(uiX-2,uiY-2);   dShad.Size=Vector2.new(W+4,h+4)
        dMain.Position=Vector2.new(uiX,uiY);         dMain.Size=Vector2.new(W,h)
        dBor.Position=Vector2.new(uiX,uiY);           dBor.Size=Vector2.new(W,h)
        dGlow1.Position=Vector2.new(uiX-1,uiY-1);  dGlow1.Size=Vector2.new(W+2,h+2)
        dGlow2.Position=Vector2.new(uiX-2,uiY-2);  dGlow2.Size=Vector2.new(W+4,h+4)
        dTop.Position=Vector2.new(uiX+1,uiY+1);     dTop.Size=Vector2.new(W-2,TOP)
        dTopLn.From=Vector2.new(uiX+1,uiY+TOP);     dTopLn.To=Vector2.new(uiX+W-1,uiY+TOP)
        dTitleW.Position=Vector2.new(uiX+14,uiY+12)
        dTitleA.Position=Vector2.new(uiX+14+72,uiY+12)
        dTitleG.Position=Vector2.new(uiX+14+72+#(titleB or "")*8+14,uiY+12)
        dKeyLbl.Position=Vector2.new(uiX+W-24,uiY+14)
        dDotY.Position=Vector2.new(uiX+W-57,uiY+15); dDotR.Position=Vector2.new(uiX+W-44,uiY+15)
        dSide.Position=Vector2.new(uiX+1,uiY+TOP);   dSide.Size=Vector2.new(SB-1,h-TOP-FOT-1)
        dSideLn.From=Vector2.new(uiX+SB,uiY+TOP);   dSideLn.To=Vector2.new(uiX+SB,uiY+h-FOT)
        dCont.Position=Vector2.new(uiX+SB,uiY+TOP);  dCont.Size=Vector2.new(CW-1,h-TOP-FOT-1)
        dFoot.Position=Vector2.new(uiX+1,uiY+h-FOT); dFoot.Size=Vector2.new(W-2,FOT-1)
        dFotLn.From=Vector2.new(uiX+1,uiY+h-FOT);   dFotLn.To=Vector2.new(uiX+W-1,uiY+h-FOT)
        if dCharLbl then
            dCharLbl.Position=Vector2.new(uiX+42+76+8,uiY+h-FOT+9)
        end
        if dWelcome then dWelcome.Position=Vector2.new(uiX+42,uiY+h-FOT+9) end
        if dNameTxt then dNameTxt.Position=Vector2.new(uiX+42+64,uiY+h-FOT+9) end
        for _,t in ipairs(tabObjs) do
            t.bg.Position=Vector2.new(uiX+7,uiY+t.tY)
            t.acc.Position=Vector2.new(uiX+7,uiY+t.tY)
            t.lbl.Position=Vector2.new(uiX+18,uiY+t.tY+7)
            t.lblG.Position=Vector2.new(uiX+18,uiY+t.tY+7)
        end
        for _,b in ipairs(btns) do
            if b.tab==curTab then posBtn(b) end
        end
        updateScrollbar()
    end

    local function reposMini()
        dMiniShad.Position=Vector2.new(uiX-2,uiY-2); dMiniShad.Size=Vector2.new(W+4,MINI_H+4)
        dMiniBg.Position=Vector2.new(uiX,uiY);         dMiniBg.Size=Vector2.new(W,MINI_H)
        dMiniBor.Position=Vector2.new(uiX,uiY);        dMiniBor.Size=Vector2.new(W,MINI_H)
        dMiniGlow1.Position=Vector2.new(uiX-1,uiY-1); dMiniGlow1.Size=Vector2.new(W+2,MINI_H+2)
        dMiniGlow2.Position=Vector2.new(uiX-2,uiY-2); dMiniGlow2.Size=Vector2.new(W+4,MINI_H+4)
        dMiniTop.Position=Vector2.new(uiX+1,uiY+1);   dMiniTop.Size=Vector2.new(W-2,TOP)
        dMiniLn.From=Vector2.new(uiX+1,uiY+TOP);      dMiniLn.To=Vector2.new(uiX+W-1,uiY+TOP)
        dMiniActBg.Position=Vector2.new(uiX+1,uiY+TOP); dMiniActBg.Size=Vector2.new(W-2,MINI_H-TOP-1)
        dMiniTW.Position=Vector2.new(uiX+14,uiY+12)
        dMiniTA.Position=Vector2.new(uiX+14+72,uiY+12)
        dMiniTG.Position=Vector2.new(uiX+14+72+#(titleB or "")*8+14,uiY+12)
        dMiniKey.Position=Vector2.new(uiX+W-24,uiY+14)
        dMiniDotY.Position=Vector2.new(uiX+W-57,uiY+15)
        dMiniDotR.Position=Vector2.new(uiX+W-44,uiY+15)
        -- layout active labels
        local PAD2=10; local SEP=14; local RH2=18
        local R1=uiY+TOP+6; local R2=R1+RH2; local cx=uiX+PAD2; local row=1
        for _,lb in ipairs(miniActLbls) do
            if lb.Text~="" then
                local w=#lb.Text*7
                if cx+w>uiX+W-PAD2 then
                    if row==1 then row=2; cx=uiX+PAD2 else break end
                end
                lb.Position=Vector2.new(cx,row==1 and R1 or R2)
                cx=cx+w+SEP
            end
        end
    end

    local function showMiniBar(yes)
        for _,dr in ipairs({dMiniShad,dMiniBg,dMiniBor,dMiniGlow1,dMiniGlow2,dMiniTop,dMiniLn,dMiniActBg,dMiniTW,dMiniTA,dMiniTG,dMiniKey,dMiniDotY,dMiniDotR}) do
            dr.Visible=yes
        end
        for _,lb in ipairs(miniActLbls) do lb.Visible=yes and lb.Text~="" end
    end

    local function refreshMiniLabels()
        local act={}
        for _,b in ipairs(btns) do if b.isTog and b.state then table.insert(act,b.name) end end
        local n=math.min(#act,12)
        for i=1,12 do
            local lb=miniActLbls[i]
            if lb then lb.Text=i<=n and act[i] or ""; lb.Visible=lb.Text~="" and isMini end
        end
        if n==0 and miniActLbls[1] then
            miniActLbls[1].Text="no active toggles"; miniActLbls[1].Visible=isMini
        end
        reposMini()
    end

    -- ── recalculate tab layout ────────────────────────────
    local function recalcTab(tname)
        local cy=10
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local col=b.section and sections[b.section]
                if col then
                    b.ry=TOP+cy; b.ch=b.baseCh
                    -- don't advance cy for collapsed items (they are hidden)
                else
                    b.ry=TOP+cy; b.ch=b.baseCh
                    cy=cy+b.baseCh+8
                    if b.isDD and b.ddOpen then cy=cy+(#b.opts*b.ch) end
                end
            end
        end
        -- total scrollable height
        local maxY=0
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local bot=(b.ry or 0)+b.ch
                if bot>maxY then maxY=bot end
            end
        end
        tabRowH[tname]=(maxY+36)
        -- clamp scroll
        local maxSc=math.max(0,(tabRowH[tname] or 0)-cH()+8)
        tabScroll[tname]=clamp(tabScroll[tname] or 0,0,maxSc)
        -- reposition + show/hide
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local col=b.section and sections[b.section]
                if col then setDrawings(b,false)
                else posBtn(b); setDrawings(b,b.tab==curTab) end
            end
        end
        updateScrollbar()
    end

    -- ── tab switch with fade ──────────────────────────────
    local prevTab=nil
    local function switchTab(name)
        if name==curTab then return end
        -- close any open DD
        if openDD then
            openDD.ddOpen=false
            if openDD.arrow then openDD.arrow.Text="v" end
            for _,o in ipairs(openDD.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
            openDD=nil
        end
        prevTab=curTab; curTab=name
        -- hide previous tab items by tweening tabAlpha
        if prevTab then
            tween(tabAlpha,prevTab,tabAlpha[prevTab] or 1,0,0.18,easeOut,function()
                for _,b in ipairs(btns) do if b.tab==prevTab then setDrawings(b,false) end end
            end)
        end
        -- show new tab items
        tabAlpha[name]=0
        recalcTab(name)
        tween(tabAlpha,name,0,1,0.22,easeOut)
        -- update sidebar
        for _,t in ipairs(tabObjs) do
            t.sel=t.name==name
            t.lbl.Visible=t.sel and globalAlpha>0.01
            t.lblG.Visible=not t.sel and globalAlpha>0.01
        end
    end

    -- ── open/close the full menu ──────────────────────────
    local function openMenu()
        isOpen=true; isMini=false; showMiniBar(false)
        -- tween height from current to FULL_H
        local startH=uiH
        tween({},{},0,1,0.3,easeOut)  -- placeholder: height driven by special tween below
        -- use a proxy table for height
        local proxy={v=startH}
        tween(proxy,"v",startH,FULL_H,0.32,easeOut,function() uiH=FULL_H end)
        -- fade chrome in
        tween({v=0},{},{},1,0,1)  -- won't work; do it directly:
        local gProxy={v=0}
        tween(gProxy,"v",0,1,0.28,easeOut,function() globalAlpha=1 end)
        -- per-frame: proxy drives uiH and globalAlpha
        task.spawn(function()
            while not destroyed do
                task.wait()
                uiH=proxy.v; globalAlpha=gProxy.v
                reposChrome(); flushAlpha()
                if proxy.v>=FULL_H-0.5 and gProxy.v>=0.99 then break end
            end
            uiH=FULL_H; globalAlpha=1; reposChrome(); flushAlpha()
        end)
        pcall(function() setrobloxinput(false) end)
    end

    local function closeMenu()
        isOpen=false
        local proxy={v=globalAlpha}
        tween(proxy,"v",globalAlpha,0,0.25,easeOut,function() globalAlpha=0 end)
        task.spawn(function()
            while not destroyed do
                task.wait(); globalAlpha=proxy.v; flushAlpha()
                if proxy.v<=0.01 then break end
            end
            globalAlpha=0; flushAlpha()
        end)
        pcall(function() setrobloxinput(true) end)
    end

    local function minimizeToBar()
        isOpen=false; isMini=true
        showMiniBar(true); reposMini(); refreshMiniLabels()
        -- hide full chrome
        globalAlpha=0; flushAlpha()
        pcall(function() setrobloxinput(true) end)
    end

    local function restoreFromBar()
        isMini=false; showMiniBar(false)
        openMenu()
    end

    -- ── scrolling ────────────────────────────────────────
    local function doScroll(delta)
        if not curTab then return end
        local maxSc=math.max(0,(tabRowH[curTab] or 0)-cH()+8)
        tabScroll[curTab]=clamp((tabScroll[curTab] or 0)+delta,0,maxSc)
        for _,b in ipairs(btns) do
            if b.tab==curTab then posBtn(b); setDrawings(b,not(b.section and sections[b.section])) end
        end
        updateScrollbar()
    end

    -- ── element record factories ──────────────────────────
    local function rxBase() return SB+PAD end
    local function cwBase() return CW-PAD*2 end

    local function makeToggle(tname,name,ry,init,cb,desc)
        local rx=rxBase(); local cw=cwBase(); local ch=RH; local ox=rx+cw-TW-8
        local bg2=creg(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3,1))
        local sep2=creg(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lbl2=creg(tx(name,uiX+rx+10,uiY+ry+ch/2-6,12,C.TXT,false,8))
        local tog2=creg(sq(uiX+ox,uiY+ry+ch/2-TH/2,TW,TH,init and C.ON or C.OFF,true,4,1))
        local dot2=creg(sq(uiX+ox+(init and TW-TH+2 or 2),uiY+ry+ch/2-TH/2+2,TH-4,TH-4,init and C.ONDOT or C.OFFDOT,true,5,1))
        pcall(function() tog2.Corner=TH end)
        pcall(function() dot2.Corner=TH end)
        local qbg2,qlb2
        if desc then
            local qx=uiX+ox-26; local qy=uiY+ry+ch/2-7
            qbg2=creg(sq(qx,qy,14,14,C.DIM,true,6,1)); pcall(function() qbg2.Corner=3 end)
            qlb2=creg(tx("?",qx+7,qy+2,9,C.GRY,true,7,true))
        end
        local b={tab=tname,isTog=true,name=name,state=init or false,
                 bg=bg2,sep=sep2,lbl=lbl2,tog=tog2,dot=dot2,qbg=qbg2,qlb=qlb2,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,selT=init and 1 or 0,cb=cb,desc=desc}
        table.insert(btns,b); return b
    end

    local function makeDiv(tname,label,ry,collapsible)
        local rx=rxBase(); local cw=cwBase(); local ch=14
        local lbl2=creg(tx(label,uiX+rx+6,uiY+ry,9,C.GRY,false,8))
        local sep2=creg(ln(uiX+rx,uiY+ry+13,uiX+rx+cw,uiY+ry+13,C.DIV,4,1))
        local arrow2
        if collapsible then
            arrow2=creg(tx("v",uiX+rx+cw-8,uiY+ry,9,C.GRY,false,8))
            if sections[label]==nil then sections[label]=false end
        end
        local b={tab=tname,isDiv=true,label=label,bg=lbl2,lbl=lbl2,sep=sep2,arrow=arrow2,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,collapsible=collapsible,section=label}
        table.insert(btns,b); return b
    end

    local function makeButton(tname,label,ry,col,cb,lc)
        local rx=rxBase(); local cw=cwBase(); local ch=RH
        local outBg=col or C.ROW
        local outCol=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local outline2=creg(sq(uiX+rx,uiY+ry,cw,ch,outCol,true,3,1)); pcall(function() outline2.Corner=4 end)
        local bg2=creg(sq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,col or C.ROW,true,4,1)); pcall(function() bg2.Corner=4 end)
        local lbl2=creg(tx(label,uiX+rx+cw/2,uiY+ry+ch/2-6,12,lc or C.TXT,true,8))
        local b={tab=tname,isBtn=true,customCol=col~=nil,outline=outline2,bg=bg2,lbl=lbl2,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,cb=cb}
        table.insert(btns,b); return b
    end

    local function makeSlider(tname,label,ry,mn,mx,iv,cb,isFloat,desc)
        local rx=rxBase(); local cw=cwBase(); local ch=RH+8
        local trkW=cw-16
        local disp=isFloat and string.format("%.1f",iv) or math.floor(iv)
        local bg2=creg(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3,1)); pcall(function() bg2.Corner=4 end)
        local sep2=creg(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lbl2=creg(tx(label..": "..disp,uiX+rx+8,uiY+ry+7,12,C.TXT,false,8))
        local dlbl2=desc and creg(tx(desc,uiX+rx+8,uiY+ry+21,9,C.GRY,false,7)) or nil
        local ty=uiY+ry+ch-12
        local frac=clamp((iv-mn)/(mx-mn),0,1); local fx=uiX+rx+8+frac*trkW
        local trk2=creg(ln(uiX+rx+8,ty,uiX+rx+8+trkW,ty,C.DIM,5,3))
        local fil2=creg(ln(uiX+rx+8,ty,fx,ty,C.ACC,6,3))
        local hdl2=creg(sq(fx-4,ty-4,HDL,HDL,C.TXT,true,7,1)); pcall(function() hdl2.Corner=3 end)
        local b={tab=tname,isSlider=true,bg=bg2,sep=sep2,lbl=lbl2,dlbl=dlbl2,
                 track=trk2,fill=fil2,handle=hdl2,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,trkW=trkW,
                 minV=mn,maxV=mx,value=iv,baseLbl=label,isFloat=isFloat or false,cb=cb}
        table.insert(btns,b); return b
    end

    local function makeDropdown(tname,label,ry,opts,initIdx,cb)
        local rx=rxBase(); local cw=cwBase(); local ch=RH
        local outBg=C.ROW
        local outCol=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local outline2=creg(sq(uiX+rx,uiY+ry,cw,ch,outCol,true,3,1)); pcall(function() outline2.Corner=4 end)
        local bg2=creg(sq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROW,true,4,1)); pcall(function() bg2.Corner=4 end)
        local lbl2=creg(tx(label,uiX+rx+10,uiY+ry+ch/2-6,12,C.TXT,false,8))
        local vi=initIdx or 1
        local valLbl2=creg(tx(opts[vi] or "",uiX+rx+cw-62,uiY+ry+ch/2-6,11,C.ACC,false,8))
        local arrow2=creg(tx("v",uiX+rx+cw-16,uiY+ry+ch/2-6,9,C.GRY,false,8))
        local optRecs={}
        for i,opt in ipairs(opts) do
            local oy=uiY+ry+ch+((i-1)*ch)
            local obg=creg(sq(uiX+rx,oy,cw,ch,C.ROW,true,10,1)); obg.Visible=false
            local osep=creg(ln(uiX+rx,oy+ch,uiX+rx+cw,oy+ch,C.DIV,11,1)); osep.Visible=false
            local olbl=creg(tx(opt,uiX+rx+14,oy+ch/2-6,11,i==vi and C.ACC or C.TXT,false,11)); olbl.Visible=false
            table.insert(optRecs,{bg=obg,sep=osep,lbl=olbl})
        end
        local b={tab=tname,isDD=true,outline=outline2,bg=bg2,lbl=lbl2,valLbl=valLbl2,arrow=arrow2,
                 opts=optRecs,options=opts,selected=vi,ddOpen=false,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,cb=cb}
        table.insert(btns,b); return b
    end

    local function makeColorPicker(tname,label,ry,initCol,cb)
        local rx=rxBase(); local cw=cwBase(); local ch=RH
        local bg2=creg(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3,1)); pcall(function() bg2.Corner=4 end)
        local sep2=creg(ln(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lbl2=creg(tx(label,uiX+rx+10,uiY+ry+ch/2-6,12,C.TXT,false,8))
        local cols={Color3.fromRGB(70,120,255),Color3.fromRGB(210,55,55),Color3.fromRGB(45,190,95),Color3.fromRGB(255,175,80),Color3.fromRGB(180,80,255),Color3.fromRGB(215,220,240)}
        local tw2=(#cols*19)-5; local sx0=uiX+rx+cw-tw2-10; local sws={}
        for i,col in ipairs(cols) do
            local sx=sx0+(i-1)*19; local sy=uiY+ry+ch/2-7
            local sw=creg(sq(sx,sy,14,14,col,true,6,1)); pcall(function() sw.Corner=3 end)
            local sbor=creg(sq(sx-1,sy-1,16,16,i==1 and C.TXT or C.BOR,false,7,1,1)); pcall(function() sbor.Corner=3 end)
            table.insert(sws,{sq=sw,bor=sbor,col=col})
        end
        local b={tab=tname,isCP=true,bg=bg2,sep=sep2,lbl=lbl2,swatches=sws,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,selected=1,value=cols[1],cb=cb}
        table.insert(btns,b); return b
    end

    local function makeLog(tname,lines,ry,starFirst)
        local rx=rxBase(); local cw=cwBase()
        local lnH=18; local starH=starFirst and 26 or 0; local pad=10
        local ch=starH+(#lines-(starFirst and 1 or 0))*lnH+pad*2
        local bg2=creg(sq(uiX+rx,uiY+ry,cw,ch,C.ROW,true,3,1)); pcall(function() bg2.Corner=6 end)
        local lbls={}
        for i,line in ipairs(lines) do
            local l=Drawing.new("Text"); d(l); table.insert(chromeD,l)
            if starFirst and i==1 then
                l.Text=line; l.Position=Vector2.new(uiX+rx+cw/2,uiY+ry+pad); l.Size=14
                l.Color=Color3.fromRGB(255,200,40); l.Center=true; l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            else
                local off=starFirst and (starH+pad+(i-2)*lnH) or (pad+(i-1)*lnH)
                l.Text=line; l.Position=Vector2.new(uiX+rx+8,uiY+ry+off); l.Size=11
                l.Color=C.TXT; l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            end
            l.Transparency=1; l.ZIndex=8; l.Visible=true; table.insert(lbls,l)
        end
        local b={tab=tname,isLog=true,bg=bg2,lbl=bg2,logs=lbls,
                 rx=rx,ry=ry,baseCh=ch,ch=ch,cw=cw,starFirst=starFirst,starH=starH,lnH=lnH,pad=pad}
        table.insert(btns,b); return b
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
        dTitleA.Color=C.ACC; dTitleW.Color=C.TXT
        dMiniBg.Color=C.BG; dMiniTop.Color=C.TOP; dMiniBor.Color=C.BOR
        dMiniGlow1.Color=C.ACC; dMiniGlow2.Color=C.ACC; dMiniActBg.Color=C.MINI
        dMiniTA.Color=C.ACC; dMiniTW.Color=C.TXT; dMiniLn.Color=C.BOR
        if dKeyLbl then dKeyLbl.Color=C.GRY end
        if dMiniKey then dMiniKey.Color=C.GRY end
        for _,l in ipairs(miniActLbls) do l.Color=C.TXT end
        for _,t2 in ipairs(tabObjs) do
            t2.bg.Color=t2.sel and C.TSEL or C.SIDE; t2.acc.Color=t2.sel and C.ACC or C.SIDE
            t2.lbl.Color=C.TXT; t2.lblG.Color=C.GRY
        end
        for _,b in ipairs(btns) do
            if b.sep then b.sep.Color=C.DIV end
            if b.isTog then
                b.bg.Color=C.ROW; b.lbl.Color=C.TXT
                b.tog.Color=b.state and C.ON or C.OFF; b.dot.Color=b.state and C.ONDOT or C.OFFDOT
                if b.qlb then b.qlb.Color=C.GRY end
            elseif b.isSlider then
                b.bg.Color=C.ROW; b.lbl.Color=C.TXT; b.track.Color=C.DIM; b.fill.Color=C.ACC
                if b.dlbl then b.dlbl.Color=C.GRY end
            elseif b.isBtn and not b.customCol then b.bg.Color=C.ROW
            elseif b.isDiv then b.lbl.Color=C.GRY; if b.arrow then b.arrow.Color=C.GRY end
            elseif b.isDD then
                b.lbl.Color=C.TXT; b.arrow.Color=C.GRY; b.valLbl.Color=C.ACC
                for j,o in ipairs(b.opts) do o.bg.Color=C.ROW; o.sep.Color=C.DIV; o.lbl.Color=j==b.selected and C.ACC or C.TXT end
            elseif b.isCP then b.bg.Color=C.ROW; b.lbl.Color=C.TXT end
        end
    end

    -- ── tab API factory ───────────────────────────────────
    local function makeTabAPI(tname)
        if tabAPI[tname] then return tabAPI[tname] end
        local api={}; tabRowH[tname]=10; tabScroll[tname]=0; tabAlpha[tname]=0
        local curSec=nil
        local function nextY(h) local y=tabRowH[tname]; tabRowH[tname]=y+h; return y end
        local function tag(b) if curSec then b.section=curSec end end

        function api:Div(lbl,collapsible)
            if collapsible==nil then collapsible=true end
            tag(makeDiv(tname,lbl,nextY(22),collapsible))
            curSec=collapsible and lbl or nil
        end
        function api:Toggle(lbl,init,cb,desc) tag(makeToggle(tname,lbl,nextY(RH+6),init,cb,desc)) end
        function api:Slider(lbl,mn,mx,iv,cb,fl,desc) tag(makeSlider(tname,lbl,nextY(RH+14),mn,mx,iv,cb,fl,desc)) end
        function api:Button(lbl,col,cb,lc) local b=makeButton(tname,lbl,nextY(RH+6),col,cb,lc); tag(b); return b end
        function api:Dropdown(lbl,opts,ii,cb) tag(makeDropdown(tname,lbl,nextY(RH+6),opts,ii,cb)) end
        function api:ColorPicker(lbl,ic,cb) tag(makeColorPicker(tname,lbl,nextY(RH+6),ic,cb)) end
        function api:Log(lines,sf)
            local lnH=18; local starH=sf and 26 or 0
            local h=starH+(#lines-(sf and 1 or 0))*lnH+20+6
            local bRef=makeLog(tname,lines,nextY(h),sf); tag(bRef)
            local la={}
            function la:SetLines(nl)
                if not bRef.logs then return end
                for i,l in ipairs(bRef.logs) do l.Text=nl[i] or ""; l.Visible=nl[i]~=nil and bRef.bg.Visible end
            end
            return la
        end
        tabAPI[tname]=api; return api
    end

    -- ═══════════════════════════════════════════════════
    function win:Init(defaultTab,charLabelFn,notifFn)
        local notify=notifFn or function(msg,title2,dur)
            pcall(function() _G.notify(msg,title2 or (titleA.." "..titleB),dur or 3) end)
        end

        -- ── build chrome ──────────────────────────────────
        dShad   =creg(sq(uiX-2,uiY-2,W+4,FULL_H+4,Color3.fromRGB(0,0,4),true,0,0.45))
        dMain   =creg(sq(uiX,uiY,W,FULL_H,C.BG,true,1,1))
        dGlow1  =creg(sq(uiX-1,uiY-1,W+2,FULL_H+2,C.ACC,false,1,0.92,1))
        dGlow2  =creg(sq(uiX-2,uiY-2,W+4,FULL_H+4,C.ACC,false,0,0.38,2))
        dBor    =creg(sq(uiX,uiY,W,FULL_H,C.BOR,false,3,0.22,1))
        dTop    =creg(sq(uiX+1,uiY+1,W-2,TOP,C.TOP,true,3,1))
        dTopLn  =creg(ln(uiX+1,uiY+TOP,uiX+W-1,uiY+TOP,C.BOR,4,1))
        dTitleW =creg(tx(titleA,uiX+14,uiY+12,14,C.TXT,false,9,true))
        dTitleA =creg(tx(titleB,uiX+14+72,uiY+12,14,C.ACC,false,9,true))
        local gn=gameName or ""
        dTitleG =creg(tx(gn,uiX+14+72+#(titleB or "")*8+14,uiY+12,13,Color3.fromRGB(255,175,80),false,9))
        dKeyLbl =creg(tx("F1",uiX+W-24,uiY+14,11,C.GRY,false,9))
        dDotY   =creg(sq(uiX+W-57,uiY+15,8,8,Color3.fromRGB(190,148,0),true,9,1)); pcall(function() dDotY.Corner=4 end)
        dDotR   =creg(sq(uiX+W-44,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9,1)); pcall(function() dDotR.Corner=4 end)
        dSide   =creg(sq(uiX+1,uiY+TOP,SB-1,FULL_H-TOP-FOT-1,C.SIDE,true,2,1))
        dSideLn =creg(ln(uiX+SB,uiY+TOP,uiX+SB,uiY+FULL_H-FOT,C.BOR,4,1))
        dCont   =creg(sq(uiX+SB,uiY+TOP,CW-1,FULL_H-TOP-FOT-1,C.CONT,true,2,1))
        dFoot   =creg(sq(uiX+1,uiY+FULL_H-FOT,W-2,FOT-1,C.TOP,true,3,1))
        dFotLn  =creg(ln(uiX+1,uiY+FULL_H-FOT,uiX+W-1,uiY+FULL_H-FOT,C.BOR,4,1))
        dCharLbl=creg(tx("",uiX+42+76+8,uiY+FULL_H-FOT+9,11,C.GRY,false,9))
        dWelcome=creg(tx("welcome,",uiX+42,uiY+FULL_H-FOT+9,11,C.TXT,false,9))
        dNameTxt=creg(tx(lp.Name,uiX+42+64,uiY+FULL_H-FOT+9,11,Color3.fromRGB(45,190,95),false,9,true))
        -- scrollbar (not in allD, managed manually)
        dScrBg   =sq(uiX+W-6,uiY+TOP+2,4,FULL_H-TOP-FOT-4,Color3.fromRGB(18,20,28),true,4,1); dScrBg.Visible=false
        dScrThumb=sq(uiX+W-6,uiY+TOP+2,4,20,C.ACC,true,5,1); dScrThumb.Visible=false
        d(dScrBg); d(dScrThumb)

        -- sidebar tab buttons
        for i,name in ipairs(tabOrder) do
            local tY=TOP+8+(i-1)*34; local isSel=name==defaultTab
            local tbg=creg(sq(uiX+7,uiY+tY,SB-14,26,isSel and C.TSEL or C.SIDE,true,3,1)); pcall(function() tbg.Corner=5 end)
            local tacc=creg(sq(uiX+7,uiY+tY,3,26,isSel and C.ACC or C.SIDE,true,4,1)); pcall(function() tacc.Corner=2 end)
            local tlW=creg(tx(name,uiX+18,uiY+tY+7,11,C.TXT,false,8))
            local tlG=creg(tx(name,uiX+18,uiY+tY+7,11,C.GRY,false,8))
            tlW.Visible=isSel; tlG.Visible=not isSel
            table.insert(tabObjs,{bg=tbg,acc=tacc,lbl=tlW,lblG=tlG,name=name,sel=isSel,tY=tY})
        end

        -- mini bar chrome (NOT in creg - managed separately)
        dMiniShad =d(sq(uiX-2,uiY-2,W+4,MINI_H+4,Color3.fromRGB(0,0,4),true,0,0.45)); dMiniShad.Visible=false
        dMiniBg   =d(sq(uiX,uiY,W,MINI_H,C.BG,true,1,1)); dMiniBg.Visible=false
        dMiniGlow1=d(sq(uiX-1,uiY-1,W+2,MINI_H+2,C.ACC,false,1,0.92,1)); dMiniGlow1.Visible=false
        dMiniGlow2=d(sq(uiX-2,uiY-2,W+4,MINI_H+4,C.ACC,false,0,0.38,2)); dMiniGlow2.Visible=false
        dMiniBor  =d(sq(uiX,uiY,W,MINI_H,C.BOR,false,3,0.22,1)); dMiniBor.Visible=false
        dMiniTop  =d(sq(uiX+1,uiY+1,W-2,TOP,C.TOP,true,3,1)); dMiniTop.Visible=false
        dMiniLn   =d(ln(uiX+1,uiY+TOP,uiX+W-1,uiY+TOP,C.BOR,4,1)); dMiniLn.Visible=false
        dMiniActBg=d(sq(uiX+1,uiY+TOP,W-2,MINI_H-TOP-1,C.MINI,true,2,1)); dMiniActBg.Visible=false
        dMiniTW   =d(tx(titleA,uiX+14,uiY+12,14,C.TXT,false,9,true)); dMiniTW.Visible=false
        dMiniTA   =d(tx(titleB,uiX+14+72,uiY+12,14,C.ACC,false,9,true)); dMiniTA.Visible=false
        dMiniTG   =d(tx(gn,uiX+14+72+#(titleB or "")*8+14,uiY+12,13,Color3.fromRGB(255,175,80),false,9)); dMiniTG.Visible=false
        dMiniKey  =d(tx("F1",uiX+W-24,uiY+14,11,C.GRY,false,9)); dMiniKey.Visible=false
        dMiniDotY =d(sq(uiX+W-57,uiY+15,8,8,C.ACC,true,9,1)); pcall(function() dMiniDotY.Corner=4 end); dMiniDotY.Visible=false
        dMiniDotR =d(sq(uiX+W-44,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9,1)); pcall(function() dMiniDotR.Corner=4 end); dMiniDotR.Visible=false
        for i=1,12 do
            local lb=Drawing.new("Text"); d(lb)
            lb.Text=""; lb.Size=13; lb.Color=C.TXT; lb.Center=false; lb.Outline=true
            lb.Font=Drawing.Fonts.System; lb.Transparency=1; lb.ZIndex=9; lb.Visible=false
            table.insert(miniActLbls,lb)
        end

        -- switch to default tab
        tabAlpha[defaultTab]=1; curTab=defaultTab
        for _,t in ipairs(tabObjs) do
            t.sel=t.name==defaultTab; t.lbl.Visible=t.sel; t.lblG.Visible=not t.sel
        end
        recalcTab(defaultTab)
        for _,b in ipairs(btns) do if b.tab==defaultTab then setDrawings(b,true) end end

        -- ── auto fetch game name ──────────────────────────
        if gn=="" or gn=="Game Name" then
            task.spawn(function() pcall(function()
                local nm
                if type(getgamename)=="function" then nm=getgamename()
                else local info=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId); nm=info and info.Name end
                if nm then dTitleG.Text=nm; dMiniTG.Text=nm end
            end) end)
        end

        -- ── Loading screen ────────────────────────────────────
        -- Create overlay SYNCHRONOUSLY (before task.spawn) so it's
        -- immediately visible. NOT added to allD so flushAlpha never hides it.
        local _loadTitle = (gameName~="" and gameName~="Game Name" and gameName) or (titleA.." "..titleB)
        local oBg    = Drawing.new("Square")
        oBg.Position=Vector2.new(uiX,uiY); oBg.Size=Vector2.new(W,FULL_H)
        oBg.Color=Color3.fromRGB(7,9,17); oBg.Filled=true; oBg.ZIndex=50; oBg.Transparency=1; oBg.Visible=true
        pcall(function() oBg.Corner=12 end)

        local oTitle = Drawing.new("Text")
        oTitle.Text=_loadTitle.." Loading"; oTitle.Position=Vector2.new(uiX+W/2,uiY+FULL_H/2-28)
        oTitle.Size=14; oTitle.Color=C.TXT; oTitle.Center=true; oTitle.Outline=true
        oTitle.Font=Drawing.Fonts.Minecraft; oTitle.ZIndex=51; oTitle.Transparency=1; oTitle.Visible=true

        local oDesc = Drawing.new("Text")
        oDesc.Text="Connecting..."; oDesc.Position=Vector2.new(uiX+W/2,uiY+FULL_H/2-8)
        oDesc.Size=10; oDesc.Color=C.GRY; oDesc.Center=true; oDesc.Outline=false
        oDesc.Font=Drawing.Fonts.Minecraft; oDesc.ZIndex=51; oDesc.Transparency=1; oDesc.Visible=true

        local oBarBg = Drawing.new("Square")
        oBarBg.Position=Vector2.new(uiX+W/2-80,uiY+FULL_H/2+10); oBarBg.Size=Vector2.new(160,5)
        oBarBg.Color=C.DIM; oBarBg.Filled=true; oBarBg.ZIndex=51; oBarBg.Transparency=1; oBarBg.Visible=true
        pcall(function() oBarBg.Corner=3 end)

        local oBar = Drawing.new("Square")
        oBar.Position=Vector2.new(uiX+W/2-80,uiY+FULL_H/2+10); oBar.Size=Vector2.new(0,5)
        oBar.Color=C.ACC; oBar.Filled=true; oBar.ZIndex=52; oBar.Transparency=1; oBar.Visible=true
        pcall(function() oBar.Corner=3 end)

        local oPct = Drawing.new("Text")
        oPct.Text="0%"; oPct.Position=Vector2.new(uiX+W/2,uiY+FULL_H/2+22)
        oPct.Size=9; oPct.Color=C.GRY; oPct.Center=true; oPct.Outline=false
        oPct.Font=Drawing.Fonts.Minecraft; oPct.ZIndex=51; oPct.Transparency=1; oPct.Visible=true

        local _loadDrawings={oBg,oTitle,oDesc,oBarBg,oBar,oPct}
        -- register for cleanup on Destroy
        for _,dr in ipairs(_loadDrawings) do d(dr) end

        task.spawn(function()
            local stages={"Connecting...","Building UI...","Almost ready...","Done!"}
            local stageT={0.25,0.55,0.85,1.0}
            local barPct=0

            for si,target in ipairs(stageT) do
                oDesc.Text=stages[si]
                local startV=barPct; local dur=0.38
                local t0=os.clock()
                while not destroyed do
                    local elapsed=os.clock()-t0
                    local tf=math.min(elapsed/dur,1)
                    -- easeInOut
                    local et=tf<0.5 and 4*tf^3 or 1-(-2*tf+2)^3/2
                    barPct=startV+(target-startV)*et
                    oBar.Size=Vector2.new(barPct*160,5)
                    oPct.Text=math.floor(barPct*100).."%"
                    if tf>=1 then break end
                    task.wait()
                end
                barPct=target; oBar.Size=Vector2.new(target*160,5)
                oPct.Text=math.floor(target*100).."%"
                task.wait(0.06)
            end
            task.wait(0.2)

            -- Smooth fade out
            local dur2=0.3; local t1=os.clock()
            while not destroyed do
                local elapsed=os.clock()-t1
                local a=1-(elapsed/dur2)
                if a<=0 then a=0 end
                for _,dr in ipairs(_loadDrawings) do
                    dr.Transparency=a; dr.Visible=a>0.005
                end
                if a<=0 then break end
                task.wait()
            end
            for _,dr in ipairs(_loadDrawings) do
                dr.Visible=false; pcall(function() dr:Remove() end)
            end
            isLoading=false
        end)

        -- ══════════════════════════════════════════════════
        -- RENDER LOOP  (RenderStepped for smooth animation)
        -- ══════════════════════════════════════════════════
        local renderConn; renderConn=RunService.RenderStepped:Connect(function(dt)
            if destroyed then if renderConn then renderConn.Disconnect() end; return end
            stepTweens(dt)

            local t=os.clock()
            -- Glow pulse
            if dGlow1 and isOpen then
                local p1=math.abs(math.sin(t))
                dGlow1.Transparency=0.85+0.12*p1; dGlow1.Color=lerpC(C.ACC,C.TXT,p1*0.2)
                dGlow2.Transparency=0.3+0.08*p1
            end
            if isMini and dMiniGlow1 then
                local p2=math.abs(math.sin(t*1.3))
                dMiniGlow1.Transparency=0.85+0.12*p2; dMiniGlow1.Color=lerpC(C.ACC,C.TXT,p2*0.2)
                dMiniGlow2.Transparency=0.3+0.08*p2
            end
            -- Title shimmer
            if dTitleW and isOpen and globalAlpha>0.1 then
                local sh=(math.sin(t*1.8)+1)/2
                dTitleW.Color=lerpC(C.TXT,C.ACC,sh*0.3)
                dTitleA.Color=lerpC(C.ACC,C.TXT,sh*0.3)
            end
            -- Tab button color lerp
            for _,tb in ipairs(tabObjs) do
                local tgt=tb.sel and 1 or 0
                tb.selT=(tb.selT or 0)+((tgt-(tb.selT or 0))*math.min(dt*10,1))
                tb.bg.Color=lerpC(C.SIDE,C.TSEL,tb.selT)
                tb.acc.Color=lerpC(C.SIDE,C.ACC,tb.selT)
            end
            -- Toggle dot + color lerp
            for _,b in ipairs(btns) do
                if b.isTog and b.tab==curTab and b.tog then
                    local tgt=b.state and 1 or 0
                    b.selT=b.selT+((tgt-b.selT)*math.min(dt*12,1))
                    b.tog.Color=lerpC(C.OFF,C.ON,b.selT)
                    b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.selT)
                    -- slide dot
                    local sc=tabScroll[b.tab] or 0; local ay=uiY+b.ry-sc
                    local dox=b.rx+b.cw-TW-8
                    b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-TH/2)
                    b.dot.Position=Vector2.new(uiX+dox+2+(TW-TH)*b.selT,ay+b.ch/2-TH/2+2)
                end
            end
            -- Tab alpha flush (for cross-fades)
            if curTab then flushAlpha() end
            -- Char label
            if charLabelFn and dCharLbl then
                local v=charLabelFn(); if v then dCharLbl.Text=" | "..v end
            end
            -- Mini active label pulse
            if isMini then
                for i,lb in ipairs(miniActLbls) do
                    if lb.Text~="" then
                        lb.Color=lerpC(C.ACC,C.TXT,(math.sin(t*0.9+i*0.6)+1)/2*0.5+0.5)
                    end
                end
            end
        end)

        -- ══════════════════════════════════════════════════
        -- INPUT  (event-driven via UserInputService)
        -- ══════════════════════════════════════════════════
        local connections={}
        local function conn(sig,fn)
            local ok,c=pcall(function() return sig:Connect(fn) end)
            if ok and c then table.insert(connections,c) end
        end

        -- Mouse wheel scroll: use WheelForward/Backward events with pcall guards
        -- and also try UIS.InputChanged as fallback
        pcall(function()
            conn(mouse.WheelForward, function()
                if not isOpen or isLoading then return end
                if hit(uiX+SB,uiY+TOP,CW,cH()) then doScroll(-30) end
            end)
        end)
        pcall(function()
            conn(mouse.WheelBackward, function()
                if not isOpen or isLoading then return end
                if hit(uiX+SB,uiY+TOP,CW,cH()) then doScroll(30) end
            end)
        end)
        pcall(function()
            conn(UIS.InputChanged,function(inp)
                local uit=tostring(inp.UserInputType)
                if not(uit=="MouseWheel" or uit:find("MouseWheel")) then return end
                if not isOpen or isLoading then return end
                if not hit(uiX+SB,uiY+TOP,CW,cH()) then return end
                local z=inp.Position and inp.Position.Z or 0
                doScroll(z < 0 and 30 or -30)
            end)
        end)

        -- InputBegan: clicks + key presses
        conn(UIS.InputBegan,function(inp,gp)
            if destroyed then return end

            -- ── MENU TOGGLE KEY ───────────────────────────
            if tostring(inp.UserInputType):find("Keyboard") or inp.UserInputType=="Keyboard" then
                local kc=type(inp.KeyCode)=="number" and inp.KeyCode or (inp.KeyCode and inp.KeyCode.Value) or 0
                if listenKey then
                    menuKey=kc; local n=kname(kc)
                    dKeyLbl.Text=n; dMiniKey.Text=n
                    if iKeyInfoIdx and btns[iKeyInfoIdx] then btns[iKeyInfoIdx].lbl.Text="Menu Key: "..n end
                    if iKeyBindIdx and btns[iKeyBindIdx] then btns[iKeyBindIdx].lbl.Text="Click to Rebind" end
                    listenKey=false; return
                end
                if kc==menuKey then
                    if isLoading then return end  -- block during loading
                    if isMini then
                        restoreFromBar()
                    elseif isOpen then
                        closeMenu()
                    else
                        openMenu()
                    end
                    return
                end
                return
            end

            -- ── MOUSE BUTTON 1 ────────────────────────────
            local uit2=tostring(inp.UserInputType); if not(uit2=="MouseButton1" or uit2:find("MouseButton1")) then return end
            if isLoading then return end

            local mx,my=mouse.X,mouse.Y

            -- MINI BAR clicks
            if isMini then
                if hit(uiX+W-47,uiY+11,13,13) then showMiniBar(false); isMini=false; return end -- close X dot
                if hit(uiX+W-60,uiY+11,13,13) then restoreFromBar(); return end                 -- restore Y dot
                -- start mini drag
                if hit(uiX,uiY,W,MINI_H) then
                    miniDragging=true; miniDOX=mx-uiX; miniDOY=my-uiY
                end
                return
            end

            if not isOpen then return end

            -- CLOSE dot
            if hit(uiX+W-47,uiY+11,13,13) then closeMenu(); return end
            -- MINIMIZE dot
            if hit(uiX+W-60,uiY+11,13,13) then minimizeToBar(); return end

            -- SCROLLBAR click/drag start
            if curTab then
                local total=tabRowH[curTab] or 0
                local maxSc=math.max(0,total-cH()+8)
                if maxSc>0 and hit(uiX+W-10,uiY+TOP+2,12,uiH-TOP-FOT-4) then
                    local sbgH=uiH-TOP-FOT-4
                    local thumbH=math.max(20,math.min(sbgH,(cH()/(total+1))*sbgH))
                    local sc=tabScroll[curTab] or 0
                    local thumbTop=uiY+TOP+2+clamp(sc/maxSc,0,1)*(sbgH-thumbH)
                    if hit(uiX+W-10,thumbTop,12,thumbH) then
                        scrDragging=true; scrDOY=my-thumbTop
                    else
                        local rf=clamp((my-uiY-TOP-2-thumbH/2)/(sbgH-thumbH),0,1)
                        local newSc=rf*maxSc; doScroll(newSc-(tabScroll[curTab] or 0))
                        scrDragging=true; scrDOY=thumbH/2
                    end
                    return
                end
            end

            -- WINDOW DRAG (topbar only)
            if hit(uiX,uiY,W,TOP) then
                dragging=true; dragOX=mx-uiX; dragOY=my-uiY; return
            end

            -- SIDEBAR tab buttons
            for _,tb in ipairs(tabObjs) do
                if hit(uiX+7,uiY+tb.tY,SB-14,26) then
                    switchTab(tb.name); return
                end
            end

            -- ELEMENT clicks
            if not curTab then return end
            local sc=tabScroll[curTab] or 0

            -- close open DD if clicking outside it
            if openDD then
                local inMain=hit(uiX+openDD.rx,uiY+openDD.ry-sc,openDD.cw,openDD.ch)
                local inOpts=false
                for _,o in ipairs(openDD.opts) do
                    if hit(o.bg.Position.X,o.bg.Position.Y,openDD.cw,openDD.ch) then inOpts=true end
                end
                if not inMain and not inOpts then
                    openDD.ddOpen=false; openDD.arrow.Text="v"
                    for _,o in ipairs(openDD.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
                    openDD=nil; recalcTab(curTab)
                end
            end

            for _,b in ipairs(btns) do
                if b.tab~=curTab then continue end
                if b.section and sections[b.section] then continue end
                local bx=uiX+b.rx; local by=uiY+b.ry-sc

                -- SLIDER: start drag
                if b.isSlider and hit(bx,by,b.cw,b.ch) then
                    sliderDrag=b; return
                end

                if not hit(bx,by,b.cw,b.ch) then continue end

                -- TOGGLE
                if b.isTog then
                    b.state=not b.state
                    if b.cb then pcall(b.cb,b.state) end
                    notify(b.name.." "..(b.state and "enabled" or "disabled"),nil,2)
                    refreshMiniLabels()
                    return
                end

                -- BUTTON
                if b.isBtn then
                    -- keybind bind button
                    if iKeyBindIdx and b==btns[iKeyBindIdx] then
                        listenKey=true; b.lbl.Text="Press any key..."; return
                    end
                    if b.cb then pcall(b.cb) end
                    return
                end

                -- DROPDOWN toggle
                if b.isDD then
                    -- check option rows first
                    if b.ddOpen then
                        for i,o in ipairs(b.opts) do
                            if hit(o.bg.Position.X,o.bg.Position.Y,b.cw,b.ch) then
                                -- select this option
                                b.selected=i; b.valLbl.Text=b.options[i]
                                for j,o2 in ipairs(b.opts) do o2.lbl.Color=j==i and C.ACC or C.TXT end
                                b.ddOpen=false; b.arrow.Text="v"
                                for _,o2 in ipairs(b.opts) do
                                    -- smooth fade out
                                    local proxy={v=1}
                                    local o2ref=o2
                                    tween(proxy,"v",1,0,0.15,easeOut,function()
                                        o2ref.bg.Visible=false; o2ref.sep.Visible=false; o2ref.lbl.Visible=false
                                    end)
                                    task.spawn(function()
                                        while proxy.v>0.01 and not destroyed do task.wait()
                                            o2ref.bg.Transparency=proxy.v; o2ref.sep.Transparency=proxy.v; o2ref.lbl.Transparency=proxy.v
                                        end
                                    end)
                                end
                                openDD=nil; recalcTab(curTab)
                                if b.cb then pcall(b.cb,b.options[i],i) end; return
                            end
                        end
                    end
                    -- close other open DD
                    if openDD and openDD~=b then
                        openDD.ddOpen=false; openDD.arrow.Text="v"
                        for _,o in ipairs(openDD.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
                        openDD=nil; recalcTab(curTab)
                    end
                    b.ddOpen=not b.ddOpen; b.arrow.Text=b.ddOpen and "^" or "v"
                    openDD=b.ddOpen and b or nil
                    if b.ddOpen then
                        -- position and fade in options
                        for i,o in ipairs(b.opts) do
                            local oy=uiY+b.ry-sc+b.ch+((i-1)*b.ch)
                            o.bg.Position=Vector2.new(uiX+b.rx,oy)
                            o.bg.Size=Vector2.new(b.cw,b.ch)
                            o.sep.From=Vector2.new(uiX+b.rx,oy+b.ch); o.sep.To=Vector2.new(uiX+b.rx+b.cw,oy+b.ch)
                            o.lbl.Position=Vector2.new(uiX+b.rx+14,oy+b.ch/2-6)
                            o.bg.Transparency=0; o.sep.Transparency=0; o.lbl.Transparency=0
                            o.bg.Visible=true; o.sep.Visible=true; o.lbl.Visible=true
                            -- fade in
                            local proxy={v=0}; local oref=o
                            tween(proxy,"v",0,1,0.18,easeOut)
                            task.spawn(function()
                                while proxy.v<0.99 and not destroyed do task.wait()
                                    oref.bg.Transparency=proxy.v; oref.sep.Transparency=proxy.v; oref.lbl.Transparency=proxy.v
                                end
                                oref.bg.Transparency=1; oref.sep.Transparency=1; oref.lbl.Transparency=1
                            end)
                        end
                    else
                        for _,o in ipairs(b.opts) do o.bg.Visible=false; o.sep.Visible=false; o.lbl.Visible=false end
                    end
                    recalcTab(curTab); return
                end

                -- COLOR PICKER
                if b.isCP then
                    for j,sw in ipairs(b.swatches) do
                        if hit(sw.sq.Position.X,sw.sq.Position.Y,14,14) then
                            b.selected=j; b.value=sw.col
                            for k,sw2 in ipairs(b.swatches) do sw2.bor.Color=k==j and C.TXT or C.BOR end
                            if b.cb then pcall(b.cb,sw.col) end; return
                        end
                    end
                    return
                end

                -- DIV collapse
                if b.isDiv and b.collapsible then
                    sections[b.label]=not sections[b.label]
                    b.arrow.Text=sections[b.label] and ">" or "v"
                    recalcTab(curTab); return
                end
            end
        end)

        -- InputEnded: release drags
        conn(UIS.InputEnded,function(inp,gp)
            if tostring(inp.UserInputType):find("MouseButton1") or inp.UserInputType=="MouseButton1" then
                if sliderDrag then
                    local b=sliderDrag
                    notify(b.baseLbl..": "..(b.isFloat and string.format("%.1f",b.value) or tostring(math.floor(b.value))),nil,2)
                    sliderDrag=nil
                end
                dragging=false; miniDragging=false; scrDragging=false
            end
        end)

        -- MouseMove (drag logic via RenderStepped polling of mouse pos)
        local dragConn; dragConn=RunService.RenderStepped:Connect(function(dt)
            if destroyed then if dragConn then dragConn.Disconnect() end; return end
            local mx,my=mouse.X,mouse.Y
            local vpW,vpH=getVP()

            -- window drag
            if dragging then
                uiX=clamp(mx-dragOX,0,vpW-W); uiY=clamp(my-dragOY,0,vpH-uiH)
                reposChrome()
            end
            -- mini drag
            if miniDragging then
                uiX=clamp(mx-miniDOX,0,vpW-W); uiY=clamp(my-miniDOY,0,vpH-MINI_H)
                reposMini()
            end
            -- scrollbar drag
            if scrDragging and curTab then
                local total=tabRowH[curTab] or 0
                local maxSc=math.max(0,total-cH()+8)
                if maxSc>0 then
                    local sbgH=uiH-TOP-FOT-4
                    local thumbH=math.max(20,math.min(sbgH,(cH()/(total+1))*sbgH))
                    local rf=clamp((my-uiY-TOP-2-scrDOY)/(sbgH-thumbH),0,1)
                    local newSc=rf*maxSc; doScroll(newSc-(tabScroll[curTab] or 0))
                end
            end
            -- slider drag
            if sliderDrag then
                local b=sliderDrag
                local ax=uiX+b.rx+8
                local frac=clamp((mx-ax)/b.trkW,0,1)
                b.value=b.minV+frac*(b.maxV-b.minV)
                local sc=tabScroll[b.tab] or 0
                local ty=uiY+b.ry-sc+b.ch-12; local fx=ax+frac*b.trkW
                b.fill.To=Vector2.new(fx,ty); b.handle.Position=Vector2.new(fx-4,ty-4)
                b.lbl.Text=b.baseLbl..": "..(b.isFloat and string.format("%.1f",b.value) or tostring(math.floor(b.value)))
                if b.cb then pcall(b.cb,b.value) end
            end
        end)
        table.insert(connections,dragConn)

        -- Hide everything until loading screen finishes
        globalAlpha=0
        for _,dr in ipairs(chromeD) do dr.Visible=false end
        for _,tb in ipairs(tabObjs) do tb.bg.Visible=false; tb.acc.Visible=false; tb.lbl.Visible=false; tb.lblG.Visible=false end
        dScrBg.Visible=false; dScrThumb.Visible=false
        reposChrome()
        -- After loading finishes, fade the menu in (manual loop, no tween engine dependency)
        task.spawn(function()
            repeat task.wait() until not isLoading or destroyed
            if destroyed then return end
            isOpen=true
            local dur=0.35; local t0=os.clock()
            while not destroyed do
                local elapsed=os.clock()-t0
                local tf=math.min(elapsed/dur,1)
                -- easeOut cubic
                globalAlpha=1-(1-tf)^3
                flushAlpha()
                if tf>=1 then break end
                task.wait()
            end
            globalAlpha=1; flushAlpha()
            pcall(function() setrobloxinput(false) end)
        end)
    end -- Init

    -- ── Public API ────────────────────────────────────────
    win._tabOrder=tabOrder

    function win:Tab(name)
        table.insert(tabOrder,name); return makeTabAPI(name)
    end

    function win:SettingsTab(destroyCb)
        local s=self:Tab("Settings")
        s:Div("UI")
        s:Dropdown("Theme",{"Check it","Dark","Moon","Grass","Light"},1,function(v) applyTheme(v) end)
        s:Div("KEYBIND")
        local ib=s:Button("Menu Key: F1",nil,nil)
        iKeyInfoIdx=#btns
        local bb=s:Button("Click to Rebind",Color3.fromRGB(14,20,40),nil)
        iKeyBindIdx=#btns
        s:Div("DANGER")
        s:Button("Destroy Menu",Color3.fromRGB(28,7,7),destroyCb,Color3.fromRGB(210,55,55))
        return s
    end

    function win:ApplyTheme(name) applyTheme(name) end
    UILib.applyTheme=function(name) applyTheme(name) end

    function win:Destroy()
        destroyed=true
        for _,dr in ipairs(allD) do pcall(function() dr:Remove() end) end
        if dScrBg then pcall(function() dScrBg:Remove() end) end
        if dScrThumb then pcall(function() dScrThumb:Remove() end) end
        for _,lb in ipairs(miniActLbls) do pcall(function() lb:Remove() end) end
        tweens={}
    end

    return win
end

_G.UILib=UILib
print("[UILib] v3.0 loaded - event driven")
return UILib
