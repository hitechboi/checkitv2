-- Check it UI Library v2.1
-- Fixes: content clipping, scrollbar visibility, window dragging
local UILib = {}
local _sections = {}

local THEMES = {
    ["Check it"]={ACCENT=Color3.fromRGB(70,120,255),BG=Color3.fromRGB(9,11,20),SIDEBAR=Color3.fromRGB(12,15,27),CONTENT=Color3.fromRGB(11,13,23),TOPBAR=Color3.fromRGB(7,9,17),BORDER=Color3.fromRGB(30,40,72),ROWBG=Color3.fromRGB(14,18,33),TABSEL=Color3.fromRGB(20,35,85),WHITE=Color3.fromRGB(215,220,240),GRAY=Color3.fromRGB(100,112,145),DIMGRAY=Color3.fromRGB(28,33,52),ON=Color3.fromRGB(45,85,195),OFF=Color3.fromRGB(20,24,42),ONDOT=Color3.fromRGB(175,198,255),OFFDOT=Color3.fromRGB(55,65,95),DIV=Color3.fromRGB(22,27,48),MINIBAR=Color3.fromRGB(11,13,22)},
    ["Moon"]    ={ACCENT=Color3.fromRGB(150,150,165),BG=Color3.fromRGB(12,12,14),SIDEBAR=Color3.fromRGB(16,16,18),CONTENT=Color3.fromRGB(14,14,16),TOPBAR=Color3.fromRGB(10,10,12),BORDER=Color3.fromRGB(40,40,46),ROWBG=Color3.fromRGB(18,18,22),TABSEL=Color3.fromRGB(30,30,36),WHITE=Color3.fromRGB(220,220,225),GRAY=Color3.fromRGB(120,120,130),DIMGRAY=Color3.fromRGB(40,40,45),ON=Color3.fromRGB(100,100,115),OFF=Color3.fromRGB(25,25,30),ONDOT=Color3.fromRGB(200,200,215),OFFDOT=Color3.fromRGB(70,70,80),DIV=Color3.fromRGB(30,30,36),MINIBAR=Color3.fromRGB(16,16,20)},
    ["Grass"]   ={ACCENT=Color3.fromRGB(60,200,100),BG=Color3.fromRGB(8,14,10),SIDEBAR=Color3.fromRGB(10,18,13),CONTENT=Color3.fromRGB(9,16,11),TOPBAR=Color3.fromRGB(6,11,8),BORDER=Color3.fromRGB(25,55,35),ROWBG=Color3.fromRGB(11,20,14),TABSEL=Color3.fromRGB(18,45,25),WHITE=Color3.fromRGB(200,235,210),GRAY=Color3.fromRGB(90,130,105),DIMGRAY=Color3.fromRGB(20,40,28),ON=Color3.fromRGB(30,140,65),OFF=Color3.fromRGB(15,30,20),ONDOT=Color3.fromRGB(150,240,180),OFFDOT=Color3.fromRGB(45,80,58),DIV=Color3.fromRGB(18,35,24),MINIBAR=Color3.fromRGB(10,18,13)},
    ["Light"]   ={ACCENT=Color3.fromRGB(50,100,255),BG=Color3.fromRGB(230,233,245),SIDEBAR=Color3.fromRGB(215,220,235),CONTENT=Color3.fromRGB(220,224,238),TOPBAR=Color3.fromRGB(200,205,225),BORDER=Color3.fromRGB(170,178,210),ROWBG=Color3.fromRGB(210,214,230),TABSEL=Color3.fromRGB(190,205,240),WHITE=Color3.fromRGB(25,30,60),GRAY=Color3.fromRGB(90,100,140),DIMGRAY=Color3.fromRGB(180,185,210),ON=Color3.fromRGB(60,120,255),OFF=Color3.fromRGB(180,185,210),ONDOT=Color3.fromRGB(255,255,255),OFFDOT=Color3.fromRGB(130,140,175),DIV=Color3.fromRGB(185,190,215),MINIBAR=Color3.fromRGB(205,210,228)},
    ["Dark"]    ={ACCENT=Color3.fromRGB(180,180,180),BG=Color3.fromRGB(4,4,6),SIDEBAR=Color3.fromRGB(6,6,9),CONTENT=Color3.fromRGB(5,5,8),TOPBAR=Color3.fromRGB(3,3,5),BORDER=Color3.fromRGB(20,20,28),ROWBG=Color3.fromRGB(7,7,10),TABSEL=Color3.fromRGB(15,15,22),WHITE=Color3.fromRGB(190,190,195),GRAY=Color3.fromRGB(80,80,90),DIMGRAY=Color3.fromRGB(15,15,20),ON=Color3.fromRGB(100,100,110),OFF=Color3.fromRGB(12,12,16),ONDOT=Color3.fromRGB(220,220,225),OFFDOT=Color3.fromRGB(45,45,55),DIV=Color3.fromRGB(14,14,18),MINIBAR=Color3.fromRGB(6,6,8)},
}
UILib.Themes = THEMES

local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerpC(a,b,t)
    return Color3.fromRGB(
        math.floor(a.R*255+(b.R*255-a.R*255)*t),
        math.floor(a.G*255+(b.G*255-a.G*255)*t),
        math.floor(a.B*255+(b.B*255-a.B*255)*t))
end
local function getVP()
    local ok,s=pcall(function() return workspace.CurrentCamera.ViewportSize end)
    return (ok and s) and s.X or 1920,(ok and s) and s.Y or 1080
end

-- Drawing helpers (start invisible)
local function mkSq(x,y,w,h,col,filled,zi,transp,thick,corner)
    local s=Drawing.new("Square")
    s.Position=Vector2.new(x,y); s.Size=Vector2.new(w,h)
    s.Color=col; s.Filled=filled~=false; s.ZIndex=zi or 1
    s.Transparency=transp or 1; s.Visible=false
    if not(filled~=false) then s.Thickness=thick or 1 end
    if corner and corner>0 then pcall(function() s.Corner=corner end) end
    return s
end
local function mkTx(txt,x,y,sz,col,ctr,zi,bold)
    local t=Drawing.new("Text")
    t.Text=txt; t.Position=Vector2.new(x,y); t.Size=sz or 12
    t.Color=col; t.Center=ctr or false; t.Outline=false
    t.Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System
    t.Transparency=1; t.ZIndex=zi or 3; t.Visible=false
    return t
end
local function mkLn(x1,y1,x2,y2,col,zi,thick)
    local l=Drawing.new("Line")
    l.From=Vector2.new(x1,y1); l.To=Vector2.new(x2,y2)
    l.Color=col; l.Transparency=1; l.Thickness=thick or 1
    l.ZIndex=zi or 2; l.Visible=false
    return l
end

local KN={}
for i=0x41,0x5A do KN[i]=string.char(i) end
for i=0x30,0x39 do KN[i]=tostring(i-0x30) end
for k,v in pairs({[0x70]="F1",[0x71]="F2",[0x72]="F3",[0x73]="F4",[0x74]="F5",[0x75]="F6",[0x76]="F7",[0x77]="F8",[0x78]="F9",[0x79]="F10",[0x7A]="F11",[0x7B]="F12",[0x20]="Space",[0x09]="Tab",[0x0D]="Enter",[0x1B]="Esc",[0x08]="Back",[0x24]="Home",[0x23]="End",[0x2E]="Del",[0x2D]="Ins",[0x21]="PgUp",[0x22]="PgDn",[0x26]="Up",[0x28]="Down",[0x25]="Left",[0x27]="Right",[0xBC]=",",[0xBE]=".",[0xBF]="/",[0xBA]=";",[0xBB]="=",[0xBD]="-",[0xDB]="[",[0xDD]="]",[0xDC]="\\",[0xDE]="'",[0xC0]="`"}) do KN[k]=v end
local function kname(k) return KN[k] or ("Key"..k) end

-- Layout constants
local L={W=440,H=400,SB=128,TOP=40,FOT=34,RH=40,PAD=10,TW=34,TH=17,HDL=8,MINI_H=86}
L.CW=L.W-L.SB

function UILib.Window(titleA,titleB,gameName)
    local win={}
    local C={}; for k,v in pairs(THEMES["Check it"]) do C[k]=v end

    local uiX,uiY=300,200
    local mouse=game.Players.LocalPlayer:GetMouse()
    local _scrollDelta=0
    pcall(function() mouse.WheelForward:Connect(function() _scrollDelta=_scrollDelta-1 end) end)
    pcall(function() mouse.WheelBackward:Connect(function() _scrollDelta=_scrollDelta+1 end) end)

    local destroyed=false
    local menuOpen=true
    local minimized=false
    local miniClosed=false
    local isLoading=true
    local menuKey=0x70
    local listenKey=false
    local wasClick=false
    local wasMenuKey=false

    -- drag state
    local dragging=false; local dragOX,dragOY=0,0
    local miniDrag=false; local miniDOX,miniDOY=0,0
    local scrDrag=false;  local scrDOY=0

    local openDD=nil
    local curTab=nil
    local prevTab=nil
    local tabOrder={}
    local tabObjs={}
    local tabAPI={}
    local tabRowY={}   -- total scrollable height per tab
    local tabScroll={} -- current scroll offset per tab
    local btns={}

    local lastTick=tick()
    local toggledAt=tick()-1
    local tabAt=tick()-1
    local FADE=0.4; local TFADE=0.2
    local glowPh={0,math.pi*0.6}
    local uiH=L.H; local uiHtgt=L.H
    local iKeyInfo,iKeyBind
    local charFn=nil

    -- Drawing pools
    local allD={}    -- every main drawing (for fade + destroy)
    local baseD={}   -- chrome drawings always shown while open
    local miniD={}   -- mini-bar drawings (managed separately)
    local shown={}   -- visibility intent per drawing
    local tabFade={} -- cross-fade group per drawing
    local glowL={}; local miniGL={}

    -- Mini active labels
    local MAXM=12; local miniLbls={}; local miniPulse={}
    for i=1,MAXM do
        local lb=Drawing.new("Text")
        lb.Text=""; lb.Size=13; lb.Color=C.WHITE; lb.Center=false
        lb.Outline=true; lb.Font=Drawing.Fonts.System; lb.Transparency=1
        lb.ZIndex=9; lb.Visible=false
        table.insert(miniLbls,lb); table.insert(miniPulse,i*0.7)
    end

    -- Chrome frame references
    local dShadow,dMain,dGlow1,dGlow2,dBorder
    local dTop,dTopFill,dTopLn
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dDotY,dDotR
    local dOnlineTxt,dOnlineDot
    local dSide,dSideLn,dContent,dFoot,dFotLn,dCharLbl
    local dScrBg,dScrThumb
    local dWelcome,dNameTxt
    local dMiniShad,dMiniBg,dMiniG1,dMiniG2,dMiniBor
    local dMiniTop,dMiniTW,dMiniTA,dMiniTG
    local dMiniKey,dMiniDG,dMiniDR,dMiniDiv,dMiniActBg
    local tipBg,tipBor,tipLbl,tipDesc
    local tipIn,tipOut,tipAt=false,false,tick()-1
    local TIP_FADE=0.35
    local _twc,_tac=0,0

    -- ── Helpers ─────────────────────────────────────────────────────────────
    local function reg(d) table.insert(allD,d); return d end
    local function setVis(d,yes) shown[d]=yes or nil; d.Visible=yes and true or false end
    local function inBox(x,y,w,h) return mouse.X>=x and mouse.X<=x+w and mouse.Y>=y and mouse.Y<=y+h end
    local function cH() return uiH-L.TOP-L.FOT end

    -- Content area bounds
    local function ctTop() return uiY+L.TOP end
    local function ctBot() return uiY+uiH-L.FOT end

    -- Is this button fully outside the visible content area?
    local function isClipped(b)
        local sc=tabScroll[b.tab] or 0
        local ry=b.cRY~=nil and b.cRY or b.ry
        local sTop=uiY+ry-sc
        local sBot=sTop+b.ch
        return sBot<=ctTop() or sTop>=ctBot()
    end

    -- bShow: toggle button visibility, hiding if clipped
    local function bShow(b,yes)
        local actual=yes and not isClipped(b)
        setVis(b.bg,actual)
        if b.out     then setVis(b.out,actual) end
        if b.outGlow then setVis(b.outGlow,actual and (b.hA or 0)>0.02) end
        if not b.isLog then setVis(b.lbl,actual) end
        if b.ln      then setVis(b.ln,actual) end
        if b.tog     then setVis(b.tog,actual); setVis(b.dot,actual) end
        if b.track   then setVis(b.track,actual); setVis(b.fill,actual); setVis(b.handle,actual) end
        if b.lbls    then for _,l in ipairs(b.lbls) do setVis(l,actual) end end
        if b.qbg     then setVis(b.qbg,actual); setVis(b.qlb,actual) end
        if b.dlb     then setVis(b.dlb,actual) end
        if b.arrow   then setVis(b.arrow,actual) end
        if b.valLbl  then setVis(b.valLbl,actual) end
        if b.swatches then for _,sw in ipairs(b.swatches) do setVis(sw.sq,actual); setVis(sw.bor,actual) end end
        if b.isDD then
            for _,o in ipairs(b.opts) do
                setVis(o.bg,actual and b.open); setVis(o.ln,actual and b.open); setVis(o.lb,actual and b.open)
            end
        end
    end

    -- bPos: position all parts using current scroll
    local function bPos(b)
        local sc=tabScroll[b.tab] or 0
        local ry=b.cRY~=nil and b.cRY or b.ry
        local ax=uiX+b.rx; local ay=uiY+ry-sc
        b.bg.Position=Vector2.new(ax,ay)
        if b.outGlow then b.outGlow.Position=Vector2.new(ax-1,ay-1) end
        if b.out then b.out.Position=Vector2.new(ax,ay) end
        if b.isLog then
            for i,l in ipairs(b.lbls) do
                if b.starFirst and i==1 then l.Position=Vector2.new(ax+b.cw/2,ay+b.pad)
                else
                    local off=b.starFirst and (b.starH+b.pad+(i-2)*b.lnH) or (b.pad+(i-1)*b.lnH)
                    l.Position=Vector2.new(ax+8,ay+off)
                end
            end; return
        end
        if b.isSlider then
            b.lbl.Position=Vector2.new(ax+8,ay+7)
            if b.dlb then b.dlb.Position=Vector2.new(ax+8,ay+21) end
            local ty=ay+b.ch-11; local frac=(b.value-b.minV)/(b.maxV-b.minV); local fx=ax+8+frac*b.trkW
            b.track.From=Vector2.new(ax+8,ty); b.track.To=Vector2.new(ax+8+b.trkW,ty)
            b.fill.From=Vector2.new(ax+8,ty); b.fill.To=Vector2.new(fx,ty)
            b.handle.Position=Vector2.new(fx-4,ty-4)
        else
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            if b.tog then
                local dox=b.rx+b.cw-L.TW-8
                b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-L.TH/2)
                b.dot.Position=Vector2.new(uiX+dox+2+(L.TW-L.TH)*b.lt,ay+b.ch/2-L.TH/2+2)
            end
            if b.qbg then
                local dox2=b.rx+b.cw-L.TW-8; local qx=uiX+dox2-22; local qy=ay+b.ch/2-7
                b.qbg.Position=Vector2.new(qx,qy)
                if b.qlb then b.qlb.Position=Vector2.new(qx+7,qy+2) end
            end
            if b.valLbl then b.valLbl.Position=Vector2.new(ax+b.cw-60,ay+b.ch/2-6) end
            if b.arrow  then b.arrow.Position=Vector2.new(ax+b.cw-14,ay+b.ch/2-6) end
            if b.swatches then
                local tw=(#b.swatches*19)-5; local sx0=ax+b.cw-tw-10
                for i,sw in ipairs(b.swatches) do
                    local sx=sx0+(i-1)*19; local sy=ay+b.ch/2-7
                    sw.sq.Position=Vector2.new(sx,sy); sw.bor.Position=Vector2.new(sx-1,sy-1)
                end
            end
        end
    end

    local function tagFade(b,grp)
        local function tf(d) if d then tabFade[d]=grp end end
        tf(b.bg); tf(b.outGlow); tf(b.lbl); tf(b.ln); tf(b.tog); tf(b.dot)
        tf(b.track); tf(b.fill); tf(b.handle); tf(b.dlb); tf(b.arrow); tf(b.valLbl); tf(b.out)
        if b.qbg then tf(b.qbg); tf(b.qlb) end
        if b.lbls then for _,l in ipairs(b.lbls) do tf(l) end end
        if b.swatches then for _,sw in ipairs(b.swatches) do tf(sw.sq); tf(sw.bor) end end
        if b.isDD then for _,o in ipairs(b.opts) do tf(o.bg); tf(o.ln); tf(o.lb) end end
    end

    -- Reposition all chrome after position/size change
    local function updatePos()
        local h=uiH
        dShadow.Size=Vector2.new(L.W+4,h+4);  dShadow.Position=Vector2.new(uiX-2,uiY-2)
        dMain.Size=Vector2.new(L.W,h);          dMain.Position=Vector2.new(uiX,uiY)
        dBorder.Size=Vector2.new(L.W,h);        dBorder.Position=Vector2.new(uiX,uiY)
        dGlow1.Size=Vector2.new(L.W+2,h+2);    dGlow1.Position=Vector2.new(uiX-1,uiY-1)
        dGlow2.Size=Vector2.new(L.W+4,h+4);    dGlow2.Position=Vector2.new(uiX-2,uiY-2)
        dTop.Position=Vector2.new(uiX+1,uiY+1); dTop.Size=Vector2.new(L.W-2,L.TOP)
        dTopFill.Position=Vector2.new(uiX+1,uiY+L.TOP-5); dTopFill.Size=Vector2.new(L.W-2,7)
        dTopLn.From=Vector2.new(uiX+1,uiY+L.TOP); dTopLn.To=Vector2.new(uiX+L.W-1,uiY+L.TOP)
        dTitleW.Position=Vector2.new(uiX+14,uiY+12)
        if dTitleW.TextBounds and dTitleW.TextBounds.X>_twc then _twc=dTitleW.TextBounds.X end
        local tw=_twc>0 and _twc or (#titleA*8)
        dTitleA.Position=Vector2.new(uiX+14+tw+3,uiY+12)
        if dTitleA.TextBounds and dTitleA.TextBounds.X>_tac then _tac=dTitleA.TextBounds.X end
        local ta=_tac>0 and _tac or (#titleB*8)
        dTitleG.Position=Vector2.new(uiX+14+tw+3+ta+10,uiY+12)
        if dOnlineTxt then
            local ox=dTitleG.Position.X+#(dTitleG.Text)*7.5+15
            dOnlineTxt.Position=Vector2.new(ox,uiY+14); dOnlineDot.Position=Vector2.new(ox+53,uiY+16)
        end
        dKeyLbl.Position=Vector2.new(uiX+L.W-22,uiY+14)
        dDotY.Position=Vector2.new(uiX+L.W-55,uiY+15); dDotR.Position=Vector2.new(uiX+L.W-42,uiY+15)
        dSide.Position=Vector2.new(uiX+1,uiY+L.TOP); dSide.Size=Vector2.new(L.SB-1,h-L.TOP-L.FOT-1)
        dSideLn.From=Vector2.new(uiX+L.SB,uiY+L.TOP); dSideLn.To=Vector2.new(uiX+L.SB,uiY+h-L.FOT)
        dContent.Position=Vector2.new(uiX+L.SB,uiY+L.TOP); dContent.Size=Vector2.new(L.CW-1,h-L.TOP-L.FOT-1)
        dFoot.Position=Vector2.new(uiX+1,uiY+h-L.FOT); dFoot.Size=Vector2.new(L.W-2,L.FOT-1)
        dFotLn.From=Vector2.new(uiX+1,uiY+h-L.FOT); dFotLn.To=Vector2.new(uiX+L.W-1,uiY+h-L.FOT)
        dScrBg.Position=Vector2.new(uiX+L.W-6,uiY+L.TOP+2); dScrBg.Size=Vector2.new(4,h-L.TOP-L.FOT-4)
        if dCharLbl then
            local nW=dNameTxt and #dNameTxt.Text*6 or 0
            dCharLbl.Position=Vector2.new(uiX+42+64+nW+8,uiY+h-L.FOT+9)
        end
        for _,t in ipairs(tabObjs) do
            t.bg.Position=Vector2.new(uiX+7,uiY+t.tY); t.acc.Position=Vector2.new(uiX+7,uiY+t.tY)
            t.lbl.Position=Vector2.new(uiX+18,uiY+t.tY+7); t.lblG.Position=Vector2.new(uiX+18,uiY+t.tY+7)
        end
        for _,b in ipairs(btns) do if b.tab==curTab then bPos(b) end end
    end

    local function updateMiniPos()
        dMiniShad.Position=Vector2.new(uiX-2,uiY-2); dMiniShad.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBg.Position=Vector2.new(uiX,uiY); dMiniBg.Size=Vector2.new(L.W,L.MINI_H)
        dMiniG1.Position=Vector2.new(uiX-1,uiY-1); dMiniG1.Size=Vector2.new(L.W+2,L.MINI_H+2)
        dMiniG2.Position=Vector2.new(uiX-2,uiY-2); dMiniG2.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBor.Position=Vector2.new(uiX,uiY); dMiniBor.Size=Vector2.new(L.W,L.MINI_H)
        dMiniTop.Position=Vector2.new(uiX+1,uiY+1); dMiniTop.Size=Vector2.new(L.W-2,L.TOP)
        local mtw=_twc>0 and _twc or (#titleA*8)
        dMiniTW.Position=Vector2.new(uiX+14,uiY+12)
        dMiniTA.Position=Vector2.new(uiX+14+mtw+3,uiY+12)
        local mta=_tac>0 and _tac or (#titleB*8)
        dMiniTG.Position=Vector2.new(uiX+14+mtw+3+mta+10,uiY+12)
        dMiniKey.Position=Vector2.new(uiX+L.W-22,uiY+14)
        dMiniDG.Position=Vector2.new(uiX+L.W-55,uiY+15); dMiniDR.Position=Vector2.new(uiX+L.W-42,uiY+15)
        dMiniDiv.From=Vector2.new(uiX+1,uiY+L.TOP); dMiniDiv.To=Vector2.new(uiX+L.W-1,uiY+L.TOP)
        dMiniActBg.Position=Vector2.new(uiX+1,uiY+L.TOP); dMiniActBg.Size=Vector2.new(L.W-2,L.MINI_H-L.TOP-1)
        local PAD=10; local SEP=14; local CW=7; local RH=18
        local R1=uiY+L.TOP+6; local R2=R1+RH; local cx=uiX+PAD; local row=1
        for _,lb in ipairs(miniLbls) do
            if lb.Visible and lb.Text~="" then
                local w=#lb.Text*CW
                if cx+w>uiX+L.W-PAD then if row==1 then row=2; cx=uiX+PAD else break end end
                lb.Position=Vector2.new(cx,row==1 and R1 or R2); cx=cx+w+SEP
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
        local PAD=10; local SEP=14; local CW=7; local RH=18
        local R1=uiY+L.TOP+6; local R2=R1+RH; local cx=uiX+PAD; local row=1
        if #act==0 then
            miniLbls[1].Text="no active toggles"; miniLbls[1].Visible=true
            for i=2,MAXM do miniLbls[i].Text=""; miniLbls[i].Visible=false end; return
        end
        local slots={}
        for _,name in ipairs(act) do
            local w=#name*CW
            if cx+w>uiX+L.W-PAD then if row==1 then row=2; cx=uiX+PAD else break end end
            table.insert(slots,{name=name,x=cx,y=(row==1 and R1 or R2)}); cx=cx+w+SEP
        end
        for i,lb in ipairs(miniLbls) do
            if slots[i] then lb.Text=slots[i].name; lb.Position=Vector2.new(slots[i].x,slots[i].y); lb.Visible=true
            else lb.Text=""; lb.Visible=false end
        end
    end

    -- Master opacity fade
    local function applyFade()
        if isLoading or minimized then
            for _,d in ipairs(allD) do d.Visible=false end
            dScrBg.Visible=false; dScrThumb.Visible=false; return
        end
        for _,l in ipairs(miniLbls) do l.Visible=false end
        local mf=1-(toggledAt-(tick()-FADE))/FADE
        if not menuOpen and mf>=1.1 then
            for _,d in ipairs(allD) do d.Visible=false end
            dScrBg.Visible=false; dScrThumb.Visible=false; return
        end
        local mOp=mf<1.1 and math.abs((menuOpen and 0 or 1)-clamp(mf,0,1)) or (menuOpen and 1 or 0)
        local tp=clamp((tick()-tabAt)/TFADE,0,1)
        for _,d in ipairs(allD) do
            if shown[d] then
                local tOp=tabFade[d]=="next" and tp or tabFade[d]=="prev" and (1-tp) or 1
                local op=mOp*tOp; d.Visible=op>0.01; d.Transparency=op
            else d.Visible=false end
        end
    end

    -- Scrollbar update
    local function updateScrollbar()
        if not curTab or not dScrBg then return end
        local total=tabRowY[curTab] or 0
        local maxSc=math.max(0,total-cH()+8)
        if maxSc>0 and menuOpen then
            local sbgY=uiY+L.TOP+2; local sbgH=uiH-L.TOP-L.FOT-4
            local sc=tabScroll[curTab] or 0
            local thumbH=math.max(20,math.min(sbgH,(cH()/(total+0.001))*sbgH))
            dScrThumb.Size=Vector2.new(4,thumbH)
            dScrThumb.Position=Vector2.new(uiX+L.W-6,sbgY+clamp(sc/maxSc,0,1)*(sbgH-thumbH))
            dScrBg.Visible=true; dScrThumb.Visible=true
        else
            dScrBg.Visible=false; dScrThumb.Visible=false
        end
    end

    -- Scroll all buttons in current tab by delta, then reclip
    local function scrollTab(tname,delta)
        local total=tabRowY[tname] or 0
        local maxSc=math.max(0,total-cH()+8)
        tabScroll[tname]=clamp((tabScroll[tname] or 0)+delta,0,maxSc)
        for _,b in ipairs(btns) do
            if b.tab==tname then
                bPos(b); bShow(b,not(b.section and _sections[b.section]))
            end
        end
        updateScrollbar()
    end

    -- Rebuild layout Y positions for a tab
    local recalcLayout
    recalcLayout=function(tname)
        local cy=10; local lastHY=0
        for _,b in ipairs(btns) do
            if b.tab==tname then
                if b.isDiv then
                    b.ry=L.TOP+cy; b.baseRY=b.ry; b.cRY=b.ry; lastHY=b.ry
                    cy=cy+b.ch+10
                else
                    local collapsed=b.section and _sections[b.section]
                    if not collapsed then
                        b.ry=L.TOP+cy; b.baseRY=b.ry; b.cRY=b.ry
                        cy=cy+b.ch+8
                        if b.isDD and b.open then cy=cy+(#b.opts*b.ch) end
                    end
                end
            end
        end
        local maxY=0
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local bot=(b.ry or 0)+b.ch; if bot>maxY then maxY=bot end
            end
        end
        tabRowY[tname]=maxY+36
        local maxSc=math.max(0,(tabRowY[tname] or 0)-cH()+8)
        tabScroll[tname]=clamp(tabScroll[tname] or 0,0,maxSc)
        -- show/hide/position
        for _,b in ipairs(btns) do
            if b.tab==tname then
                local collapsed=b.section and _sections[b.section]
                if collapsed then bShow(b,false) else bPos(b); bShow(b,true) end
            else
                if shown[b.bg] then bShow(b,false) end
            end
        end
        updateScrollbar()
    end

    local function switchTab(name)
        if name==curTab then return end
        if openDD then
            openDD.open=false; if openDD.arrow then openDD.arrow.Text="v" end
            for _,o in ipairs(openDD.opts) do o.targetA=0 end; openDD=nil
        end
        uiHtgt=L.H; prevTab=curTab; curTab=name; tabAt=tick()
        for _,t in ipairs(tabObjs) do
            t.sel=t.name==name; setVis(t.lbl,t.sel); setVis(t.lblG,not t.sel)
        end
        for _,d in ipairs(allD) do tabFade[d]=nil end
        for _,b in ipairs(btns) do
            if b.tab==prevTab then bShow(b,true); bPos(b); tagFade(b,"prev") end
        end
        for _,b in ipairs(btns) do
            if b.tab==name then
                if b.isDiv and b.collapsible and b.section then
                    _sections[b.section]=false; if b.arrow then b.arrow.Text="v" end
                end
                b.cRY=b.ry
            end
        end
        recalcLayout(name)
        for _,b in ipairs(btns) do if b.tab==name then tagFade(b,"next") end end
    end

    local function restoreFull()
        minimized=false; miniClosed=false; showMini(false)
        for _,d in ipairs(allD) do d.Visible=false; tabFade[d]=nil end
        dScrBg.Visible=false; dScrThumb.Visible=false
        for _,d in ipairs(baseD) do setVis(d,true) end
        for _,t in ipairs(tabObjs) do
            setVis(t.bg,true); setVis(t.acc,true); setVis(t.lbl,t.sel); setVis(t.lblG,not t.sel)
        end
        uiH=L.MINI_H+5; updatePos(); uiHtgt=L.H; lastTick=tick()
        menuOpen=true; toggledAt=tick()-FADE-0.01
        recalcLayout(curTab)
    end

    -- Element constructors
    local function rxB() return L.SB+L.PAD end
    local function cwB() return L.CW-L.PAD*2 end

    local function newTog(tab,name,relY,init,cb,desc)
        local rx=rxB(); local cw=cwB(); local ch=L.RH-2; local ry=L.TOP+relY
        local ox=rx+cw-L.TW-8
        local bg =reg(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,4))
        local dl =reg(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb =reg(mkTx(name,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local tog=reg(mkSq(uiX+ox,uiY+ry+ch/2-L.TH/2,L.TW,L.TH,init and C.ON or C.OFF,true,4,1,nil,L.TH))
        local dot=reg(mkSq(uiX+ox+(init and L.TW-L.TH+2 or 2),uiY+ry+ch/2-L.TH/2+2,L.TH-4,L.TH-4,init and C.ONDOT or C.OFFDOT,true,5,1,nil,L.TH))
        local qbg,qlb
        if desc then
            local qx=uiX+ox-22; local qy=uiY+ry+ch/2-7
            qbg=reg(mkSq(qx,qy,14,14,Color3.fromRGB(16,20,38),true,6,1,nil,3))
            qlb=reg(mkTx("?",qx+7,qy+2,9,C.GRAY,true,7,true))
        end
        local glow=reg(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isTog=true,name=name,state=init,bg=bg,lbl=lb,ln=dl,tog=tog,dot=dot,
                 outGlow=glow,qbg=qbg,qlb=qlb,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,
                 lt=init and 1 or 0,cb=cb,desc=desc,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newDiv(tab,lbl,relY,collapsible)
        local rx=rxB(); local cw=cwB(); local ry=L.TOP+relY
        local lb=reg(mkTx(lbl,uiX+rx+6,uiY+ry,9,C.GRAY,false,8))
        local dl=reg(mkLn(uiX+rx,uiY+ry+13,uiX+rx+cw,uiY+ry+13,C.DIV,4,1))
        local arrow
        if collapsible then
            arrow=reg(mkTx("v",uiX+rx+cw-6,uiY+ry,9,C.GRAY,false,8))
            if _sections[lbl]==nil then _sections[lbl]=false end
        end
        local b={tab=tab,isDiv=true,bg=lb,lbl=lb,ln=dl,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=14,
                 collapsible=collapsible,section=lbl,arrow=arrow}
        table.insert(btns,b); return #btns
    end

    local function newAct(tab,lbl,relY,col,cb,lblCol)
        local rx=rxB(); local cw=cwB(); local ch=L.RH-2; local ry=L.TOP+relY
        local outBg=col or C.ROWBG
        local outCol=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=reg(mkSq(uiX+rx,uiY+ry,cw,ch,outCol,true,3,1,nil,4))
        local bg=reg(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,col or C.ROWBG,true,4,1,nil,4))
        local lb=reg(mkTx(lbl,uiX+rx+cw/2,uiY+ry+ch/2-6,12,lblCol or C.WHITE,true,8))
        local glow=reg(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isAct=true,customCol=col~=nil,out=out,bg=bg,lbl=lb,outGlow=glow,
                 rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,cb=cb,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newSlider(tab,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local rx=rxB(); local cw=cwB(); local ch=L.RH+6; local ry=L.TOP+relY
        local trkW=cw-16; local disp=isFloat and string.format("%.1f",initV) or math.floor(initV)
        local bg=reg(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,4))
        local dl=reg(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb=reg(mkTx(lbl..": "..disp,uiX+rx+8,uiY+ry+7,12,C.WHITE,false,8))
        local dlb=desc and reg(mkTx(desc,uiX+rx+8,uiY+ry+21,9,C.GRAY,false,8)) or nil
        local ty=uiY+ry+ch-11; local frac=(initV-minV)/(maxV-minV); local fx=uiX+rx+8+frac*trkW
        local trk=reg(mkLn(uiX+rx+8,ty,uiX+rx+8+trkW,ty,C.DIMGRAY,5,3))
        local fil=reg(mkLn(uiX+rx+8,ty,fx,ty,C.ACCENT,6,3))
        local hdl=reg(mkSq(fx-4,ty-4,L.HDL,L.HDL,C.WHITE,true,7,1,nil,3))
        local glow=reg(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isSlider=true,bg=bg,lbl=lb,ln=dl,track=trk,fill=fil,handle=hdl,
                 outGlow=glow,dlb=dlb,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,
                 trkW=trkW,minV=minV,maxV=maxV,value=initV,baseLbl=lbl,
                 dragging=false,cb=cb,isFloat=isFloat or false,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newDD(tab,lbl,relY,opts,initIdx,cb)
        local rx=rxB(); local cw=cwB(); local ch=L.RH-2; local ry=L.TOP+relY
        local outBg=C.ROWBG
        local outCol=Color3.new(math.min(1,outBg.R*1.5),math.min(1,outBg.G*1.5),math.min(1,outBg.B*1.5))
        local out=reg(mkSq(uiX+rx,uiY+ry,cw,ch,outCol,true,3,1,nil,4))
        local bg=reg(mkSq(uiX+rx+1,uiY+ry+1,cw-2,ch-2,C.ROWBG,true,4,1,nil,4))
        local lb=reg(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local vi=initIdx or 1
        local val=reg(mkTx(opts[vi] or "",uiX+rx+cw-60,uiY+ry+ch/2-6,11,C.ACCENT,false,8))
        local arrow=reg(mkTx("v",uiX+rx+cw-14,uiY+ry+ch/2-6,9,C.GRAY,false,8))
        local glow=reg(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local optBgs={}
        for i,opt in ipairs(opts) do
            local oy2=ry+ch+((i-1)*ch)
            local obg=reg(mkSq(uiX+rx,uiY+oy2,cw,ch,C.ROWBG,true,10,0,nil,0))
            local oln=reg(mkLn(uiX+rx,uiY+oy2+ch,uiX+rx+cw,uiY+oy2+ch,C.DIV,11,1))
            local olb=reg(mkTx(opt,uiX+rx+14,uiY+oy2+ch/2-6,11,i==vi and C.ACCENT or C.WHITE,false,11))
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,ry=oy2,alpha=0,targetA=0})
        end
        local b={tab=tab,isDD=true,out=out,bg=bg,lbl=lb,valLbl=val,arrow=arrow,
                 outGlow=glow,rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,
                 opts=optBgs,options=opts,selected=vi,open=false,cb=cb,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newColorPicker(tab,lbl,relY,initCol,cb)
        local rx=rxB(); local cw=cwB(); local ch=L.RH-2; local ry=L.TOP+relY
        local bg=reg(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,4))
        local dl=reg(mkLn(uiX+rx,uiY+ry+ch,uiX+rx+cw,uiY+ry+ch,C.DIV,4,1))
        local lb=reg(mkTx(lbl,uiX+rx+10,uiY+ry+ch/2-6,12,C.WHITE,false,8))
        local cols={Color3.fromRGB(70,120,255),Color3.fromRGB(210,55,55),Color3.fromRGB(45,190,95),Color3.fromRGB(255,175,80),Color3.fromRGB(180,80,255),Color3.fromRGB(215,220,240)}
        local tw=(#cols*19)-5; local sx0=uiX+rx+cw-tw-10; local sws={}
        for i,col in ipairs(cols) do
            local sx=sx0+(i-1)*19; local sy=uiY+ry+ch/2-7
            table.insert(sws,{sq=reg(mkSq(sx,sy,14,14,col,true,6,1,nil,3)),bor=reg(mkSq(sx-1,sy-1,16,16,i==1 and C.WHITE or C.BORDER,false,7,1,1,3)),col=col})
        end
        local glow=reg(mkSq(uiX+rx-1,uiY+ry-1,cw+2,ch+2,C.ACCENT,false,5,0,1,4))
        local b={tab=tab,isColorPicker=true,bg=bg,lbl=lb,ln=dl,outGlow=glow,swatches=sws,
                 rx=rx,ry=ry,baseRY=ry,cRY=ry,cw=cw,ch=ch,selected=1,value=cols[1],cb=cb,hA=0,tHA=0}
        table.insert(btns,b); return #btns
    end

    local function newLog(tab,lines,relY,starFirst)
        local rx=rxB(); local cw=cwB()
        local lnH=18; local starH=starFirst and 26 or 0; local pad=10
        local ch=starH+(#lines-(starFirst and 1 or 0))*lnH+pad*2; local ry=L.TOP+relY
        local bg=reg(mkSq(uiX+rx,uiY+ry,cw,ch,C.ROWBG,true,3,1,nil,6)); local lbls={}
        for i,line in ipairs(lines) do
            local l=Drawing.new("Text")
            if starFirst and i==1 then
                l.Text=line; l.Position=Vector2.new(uiX+rx+cw/2,uiY+ry+pad); l.Size=14
                l.Color=Color3.fromRGB(255,200,40); l.Center=true; l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            else
                local off=starFirst and (starH+pad+(i-2)*lnH) or (pad+(i-1)*lnH)
                l.Text=line; l.Position=Vector2.new(uiX+rx+8,uiY+ry+off); l.Size=11
                l.Color=C.WHITE; l.Outline=true; l.Font=Drawing.Fonts.Minecraft
            end
            l.Transparency=1; l.ZIndex=8; l.Visible=false; table.insert(lbls,l)
        end
        local b={tab=tab,isLog=true,bg=bg,lbl=bg,lbls=lbls,rx=rx,ry=ry,baseRY=ry,cRY=ry,
                 cw=cw,ch=ch,starFirst=starFirst,starH=starH,lnH=lnH,pad=pad}
        table.insert(btns,b); return #btns
    end

    local function applyTheme(name)
        local t=THEMES[name]; if not t then return end
        for k,v in pairs(t) do C[k]=v end
        if not dMain then return end
        dMain.Color=C.BG; dMiniBg.Color=C.BG; dTop.Color=C.TOPBAR; dMiniTop.Color=C.TOPBAR
        dTopFill.Color=C.TOPBAR; dSide.Color=C.SIDEBAR; dContent.Color=C.CONTENT; dFoot.Color=C.TOPBAR
        dBorder.Color=C.BORDER; dMiniBor.Color=C.BORDER; dTopLn.Color=C.BORDER; dMiniDiv.Color=C.BORDER
        dSideLn.Color=C.BORDER; dFotLn.Color=C.BORDER
        dGlow1.Color=C.ACCENT; dGlow2.Color=C.ACCENT; dMiniG1.Color=C.ACCENT; dMiniG2.Color=C.ACCENT
        dScrBg.Color=Color3.fromRGB(18,20,28); dScrThumb.Color=C.ACCENT
        dTitleA.Color=C.ACCENT; dMiniTA.Color=C.ACCENT; dTitleW.Color=C.WHITE; dMiniTW.Color=C.WHITE
        dKeyLbl.Color=C.GRAY; dMiniKey.Color=C.GRAY; dMiniActBg.Color=C.MINIBAR
        if dCharLbl then dCharLbl.Color=C.GRAY end
        for _,l in ipairs(miniLbls) do l.Color=C.WHITE end
        for _,t2 in ipairs(tabObjs) do
            t2.bg.Color=t2.sel and C.TABSEL or C.SIDEBAR; t2.acc.Color=t2.sel and C.ACCENT or C.SIDEBAR
            t2.lbl.Color=C.WHITE; t2.lblG.Color=C.GRAY
        end
        for _,b in ipairs(btns) do
            if b.ln then b.ln.Color=C.DIV end
            if b.isTog then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
                b.tog.Color=b.state and C.ON or C.OFF; b.dot.Color=b.state and C.ONDOT or C.OFFDOT
                if b.qlb then b.qlb.Color=C.GRAY end
            elseif b.isSlider then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE; b.track.Color=C.DIMGRAY; b.fill.Color=C.ACCENT
                if b.dlb then b.dlb.Color=C.GRAY end
            elseif b.isAct and not b.customCol then
                b.bg.Color=C.ROWBG
                local ob=C.ROWBG; if b.out then b.out.Color=Color3.new(math.min(1,ob.R*1.5),math.min(1,ob.G*1.5),math.min(1,ob.B*1.5)) end
            elseif b.isDiv then
                b.lbl.Color=C.GRAY; if b.arrow then b.arrow.Color=C.GRAY end
            elseif b.isDD then
                b.lbl.Color=C.WHITE; b.arrow.Color=C.GRAY; b.valLbl.Color=C.ACCENT
                for j,o in ipairs(b.opts) do o.bg.Color=C.ROWBG; o.ln.Color=C.DIV; o.lb.Color=j==b.selected and C.ACCENT or C.WHITE end
            elseif b.isColorPicker then
                b.bg.Color=C.ROWBG; b.lbl.Color=C.WHITE
            end
        end
    end

    local function getTabAPI(tname)
        if tabAPI[tname] then return tabAPI[tname] end
        local api={}; tabRowY[tname]=10; local curSec=nil
        local function nextY(h) local y=tabRowY[tname]; tabRowY[tname]=y+h; return y end
        local function tag(idx) if curSec and btns[idx] then btns[idx].section=curSec end end
        function api:Div(lbl,collapsible)
            if collapsible==nil then collapsible=true end
            newDiv(tname,lbl,nextY(22),collapsible); curSec=collapsible and lbl or nil
        end
        function api:Toggle(lbl,init,cb,desc) local i=newTog(tname,lbl,nextY(L.RH+4),init,cb,desc); tag(i) end
        function api:Slider(lbl,mn,mx,iv,cb,fl,desc) local i=newSlider(tname,lbl,nextY(L.RH+10),mn,mx,iv,cb,fl,desc); tag(i) end
        function api:Button(lbl,col,cb,lc) local i=newAct(tname,lbl,nextY(L.RH+4),col,cb,lc); tag(i); return i end
        function api:Dropdown(lbl,opts,ii,cb) local i=newDD(tname,lbl,nextY(L.RH+4),opts,ii,cb); tag(i) end
        function api:ColorPicker(lbl,ic,cb) local i=newColorPicker(tname,lbl,nextY(L.RH+4),ic,cb); tag(i) end
        function api:Log(lines,sf)
            local lnH=18; local starH=sf and 26 or 0
            local h=starH+(#lines-(sf and 1 or 0))*lnH+20+6
            local idx=newLog(tname,lines,nextY(h),sf); tag(idx)
            local la={}
            function la:SetLines(nl)
                if not btns[idx] then return end
                for i,l in ipairs(btns[idx].lbls) do l.Text=nl[i] or ""; l.Visible=(nl[i]~=nil) and shown[btns[idx].bg] or false end
            end
            return la
        end
        tabAPI[tname]=api; return api
    end

    -- ════════════════════════════════════════════════════════════════════════
    function win:Init(defaultTab,charLabelFn,notifFn)
        local notify=notifFn or function(msg,title,dur)
            pcall(function() _G.notify(msg,title or titleA.." "..titleB,dur or 3) end)
        end
        charFn=charLabelFn

        dShadow =reg(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,Color3.fromRGB(0,0,5),true,0,0.5,nil,12))
        dMain   =reg(mkSq(uiX,uiY,L.W,L.H,C.BG,true,1,1,nil,10))
        dGlow1  =reg(mkSq(uiX-1,uiY-1,L.W+2,L.H+2,C.ACCENT,false,1,0.9,1,11))
        dGlow2  =reg(mkSq(uiX-2,uiY-2,L.W+4,L.H+4,C.ACCENT,false,0,0.35,2,12))
        glowL   ={dGlow1,dGlow2}
        dBorder =reg(mkSq(uiX,uiY,L.W,L.H,C.BORDER,false,3,0.2,1,10))
        dTop    =reg(mkSq(uiX+1,uiY+1,L.W-2,L.TOP,C.TOPBAR,true,3,1,nil,9))
        dTopFill=reg(mkSq(uiX+1,uiY+L.TOP-5,L.W-2,7,C.TOPBAR,true,3,1))
        dTopLn  =reg(mkLn(uiX+1,uiY+L.TOP,uiX+L.W-1,uiY+L.TOP,C.BORDER,4,1))
        dTitleW =reg(mkTx(titleA,uiX+14,uiY+12,14,C.WHITE,false,9,true))
        dTitleA =reg(mkTx(titleB,uiX+14+(#titleA*8)+3,uiY+12,14,C.ACCENT,false,9,true))
        local gn=gameName or ""
        dTitleG =reg(mkTx(gn,uiX+100,uiY+12,13,Color3.fromRGB(255,175,80),false,9))
        dOnlineTxt=reg(mkTx("Online:",uiX+200,uiY+14,11,C.GRAY,false,9))
        dOnlineDot=reg(mkSq(uiX+253,uiY+16,6,6,Color3.new(0.9,0.1,0.1),true,9,1,nil,3))
        local function posOnline(s)
            local ox=uiX+100+#s*7.5+15; dOnlineTxt.Position=Vector2.new(ox,uiY+14); dOnlineDot.Position=Vector2.new(ox+53,uiY+16)
        end
        posOnline(gn)
        if gn=="" or gn=="Game Name" then
            dTitleG.Text=""
            task.spawn(function() pcall(function()
                local nm; if type(getgamename)=="function" then nm=getgamename()
                else local info=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId); nm=info and info.Name end
                if nm then dTitleG.Text=nm; posOnline(nm); if dMiniTG then dMiniTG.Text=nm end end
            end) end)
        end
        dKeyLbl =reg(mkTx("F1",uiX+L.W-22,uiY+14,11,C.GRAY,false,9))
        dDotY   =reg(mkSq(uiX+L.W-55,uiY+15,8,8,Color3.fromRGB(190,148,0),true,9,1,nil,3))
        dDotR   =reg(mkSq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9,1,nil,3))
        dSide   =reg(mkSq(uiX+1,uiY+L.TOP,L.SB-1,L.H-L.TOP-L.FOT-1,C.SIDEBAR,true,2,1,nil,8))
        dSideLn =reg(mkLn(uiX+L.SB,uiY+L.TOP,uiX+L.SB,uiY+L.H-L.FOT,C.BORDER,4,1))
        dContent=reg(mkSq(uiX+L.SB,uiY+L.TOP,L.CW-1,L.H-L.TOP-L.FOT-1,C.CONTENT,true,2,1,nil,8))
        dFoot   =reg(mkSq(uiX+1,uiY+L.H-L.FOT,L.W-2,L.FOT-1,C.TOPBAR,true,3,1,nil,6))
        dFotLn  =reg(mkLn(uiX+1,uiY+L.H-L.FOT,uiX+L.W-1,uiY+L.H-L.FOT,C.BORDER,4,1))
        dCharLbl=reg(mkTx("",0,0,11,C.GRAY,false,9))
        -- scrollbar NOT in allD (managed independently so fade doesn't control it)
        dScrBg   =mkSq(uiX+L.W-6,uiY+L.TOP+2,4,L.H-L.TOP-L.FOT-4,Color3.fromRGB(18,20,28),true,4,1,nil,2)
        dScrThumb=mkSq(uiX+L.W-6,uiY+L.TOP+2,4,20,C.ACCENT,true,5,1,nil,2)
        -- tooltip
        tipBg=mkSq(0,0,10,10,Color3.fromRGB(10,13,24),true,12,1,nil,4); pcall(function() tipBg.Corner=4 end)
        tipBor=mkSq(0,0,10,10,C.ACCENT,false,12,0.7,1,4); pcall(function() tipBor.Corner=4 end)
        tipLbl=mkTx("",0,0,11,C.ACCENT,false,13,true); tipDesc=mkTx("",0,0,10,Color3.fromRGB(130,140,170),false,13)
        -- footer
        dWelcome=reg(mkTx("welcome,",uiX+42,uiY+L.H-L.FOT+9,11,C.WHITE,false,9))
        dNameTxt=reg(mkTx(game.Players.LocalPlayer.Name,uiX+42+64,uiY+L.H-L.FOT+9,11,Color3.fromRGB(45,190,95),false,9,true))

        baseD={dShadow,dGlow2,dGlow1,dMain,dBorder,dTop,dTopFill,dTopLn,
               dTitleW,dTitleA,dTitleG,dOnlineTxt,dOnlineDot,dKeyLbl,dDotY,dDotR,
               dSide,dSideLn,dContent,dFoot,dFotLn,dCharLbl,dWelcome,dNameTxt}

        for i,name in ipairs(tabOrder) do
            local tY=L.TOP+8+(i-1)*34; local isSel=name==defaultTab
            local tbg =reg(mkSq(uiX+7,uiY+tY,L.SB-14,26,isSel and C.TABSEL or C.SIDEBAR,true,3,1,nil,5))
            local tacc=reg(mkSq(uiX+7,uiY+tY,3,26,isSel and C.ACCENT or C.SIDEBAR,true,4,1,nil,2))
            local tlW =reg(mkTx(name,uiX+18,uiY+tY+7,11,C.WHITE,false,8))
            local tlG =reg(mkTx(name,uiX+18,uiY+tY+7,11,C.GRAY,false,8))
            table.insert(tabObjs,{bg=tbg,acc=tacc,lbl=tlW,lblG=tlG,name=name,sel=isSel,lt=isSel and 1 or 0,tY=tY})
        end

        -- mini bar
        dMiniShad=mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,Color3.fromRGB(0,0,5),true,0,0.5,nil,12)
        dMiniBg  =mkSq(uiX,uiY,L.W,L.MINI_H,C.BG,true,1,1,nil,10)
        dMiniG1  =mkSq(uiX-1,uiY-1,L.W+2,L.MINI_H+2,C.ACCENT,false,1,0.9,1,11)
        dMiniG2  =mkSq(uiX-2,uiY-2,L.W+4,L.MINI_H+4,C.ACCENT,false,0,0.35,2,12)
        dMiniBor =mkSq(uiX,uiY,L.W,L.MINI_H,C.BORDER,false,3,0.2,1,10)
        dMiniTop =mkSq(uiX+1,uiY+1,L.W-2,L.TOP,C.TOPBAR,true,3,1,nil,9)
        dMiniTW  =mkTx(titleA,uiX+14,uiY+12,14,C.WHITE,false,9,true)
        dMiniTA  =mkTx(titleB,uiX+14+(#titleA*8)+3,uiY+12,14,C.ACCENT,false,9,true)
        dMiniTG  =mkTx(gameName or "",uiX+100,uiY+12,13,Color3.fromRGB(255,175,80),false,9)
        dMiniKey =mkTx("F1",uiX+L.W-22,uiY+14,11,C.GRAY,false,9)
        dMiniDG  =mkSq(uiX+L.W-55,uiY+15,8,8,C.ACCENT,true,9,1,nil,3)
        dMiniDR  =mkSq(uiX+L.W-42,uiY+15,8,8,Color3.fromRGB(170,44,44),true,9,1,nil,3)
        dMiniDiv =mkLn(uiX+1,uiY+L.TOP,uiX+L.W-1,uiY+L.TOP,C.BORDER,4,1)
        dMiniActBg=mkSq(uiX+1,uiY+L.TOP,L.W-2,L.MINI_H-L.TOP-1,C.MINIBAR,true,2,1,nil,0)
        miniGL={dMiniG1,dMiniG2}
        for _,d in ipairs({dMiniShad,dMiniBg,dMiniG1,dMiniG2,dMiniBor,dMiniTop,dMiniTW,dMiniTA,dMiniTG,dMiniKey,dMiniDG,dMiniDR,dMiniDiv,dMiniActBg}) do
            d.Visible=false; table.insert(miniD,d)
        end

        for _,d in ipairs(baseD) do setVis(d,true) end
        switchTab(defaultTab)

        -- Loading overlay
        task.spawn(function()
            local stages={{pct=0.2,text="Loading modules..."},{pct=0.5,text="Connecting..."},{pct=0.8,text="Building UI..."},{pct=1.0,text="Done!"}}
            local bBg=mkSq(uiX,uiY,L.W,L.H,Color3.fromRGB(7,9,17),true,20,1,nil,10)
            local bTxt=mkTx((gameName or titleA.." "..titleB).." Loading...",uiX+L.W/2,uiY+L.H/2-24,13,C.WHITE,true,21)
            local bDesc=mkTx("",uiX+L.W/2,uiY+L.H/2-6,10,C.GRAY,true,21)
            local bBBg=mkSq(uiX+L.W/2-80,uiY+L.H/2+8,160,6,C.DIMGRAY,true,21,1,nil,3)
            local bBar=mkSq(uiX+L.W/2-80,uiY+L.H/2+8,0,6,C.ACCENT,true,22,1,nil,3)
            for _,d in ipairs({bBg,bTxt,bDesc,bBBg,bBar}) do d.Visible=true end
            local fill=0
            local function setBar(op,lbl,pct,desc2)
                for _,d in ipairs({bBg,bTxt,bDesc,bBBg,bBar}) do d.Visible=op>0.01; d.Transparency=op end
                bTxt.Text=lbl; bDesc.Text=desc2; bBar.Size=Vector2.new(160*pct,6)
            end
            for _,s in ipairs(stages) do
                local sf=fill; local fr=12
                for f=1,fr do fill=sf+(s.pct-sf)*(f/fr); setBar(1,(gameName or titleA.." "..titleB).." Initializing...",fill,s.text); task.wait() end
                task.wait(0.08)
            end
            local t2=tick(); local dur=0.3
            while tick()-t2<dur and not destroyed do task.wait(); setBar(1-(tick()-t2)/dur,"Ready!",1,"") end
            for _,d in ipairs({bBg,bTxt,bDesc,bBBg,bBar}) do pcall(function() d:Remove() end) end
            isLoading=false
        end)

        -- ════════════════════════════ MAIN LOOP ════════════════════════════
        task.spawn(function()
        while not destroyed do
            task.wait()
            local clicking=ismouse1pressed()
            local keyDown=iskeypressed(menuKey)

            if keyDown and not wasMenuKey and not isLoading then
                if miniClosed then
                    miniClosed=false; refreshMini(); showMini(true); updateMiniPos()
                elseif minimized then
                    showMini(false); miniClosed=true
                    for _,d in ipairs(allD) do d.Visible=false end; dScrBg.Visible=false; dScrThumb.Visible=false
                else
                    menuOpen=not menuOpen; toggledAt=tick()
                    pcall(function() setrobloxinput(not menuOpen) end)
                end
            end
            wasMenuKey=keyDown

            -- MINI BAR
            if minimized and not miniClosed then
                local t=tick()
                for i,s in ipairs(miniGL) do
                    local p=t+glowPh[i]; s.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
                    s.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                local pt=t*0.8
                for i,lb in ipairs(miniLbls) do
                    if lb.Text~="" then lb.Visible=true; lb.Color=lerpC(C.ACCENT,C.WHITE,(math.sin(pt+miniPulse[i])+1)/2)
                    else lb.Visible=false end
                end
                if clicking and not wasClick then
                    if inBox(uiX+L.W-46,uiY+11,12,12) then miniClosed=true; showMini(false)
                    elseif inBox(uiX+L.W-59,uiY+11,12,12) then restoreFull()
                    elseif inBox(uiX,uiY,L.W,L.MINI_H) then miniDrag=true; miniDOX=mouse.X-uiX; miniDOY=mouse.Y-uiY end
                end
                if not clicking then miniDrag=false end
                if miniDrag and clicking then
                    local vpW,vpH=getVP()
                    uiX=clamp(mouse.X-miniDOX,0,vpW-L.W); uiY=clamp(mouse.Y-miniDOY,0,vpH-L.MINI_H)
                    updateMiniPos()
                end
            end

            -- FULL MENU
            if not minimized and not isLoading then
                -- Tab lerp
                for _,t in ipairs(tabObjs) do
                    local tgt=t.sel and 1 or 0; t.lt=t.lt+(tgt-t.lt)*0.15
                    t.bg.Color=lerpC(C.SIDEBAR,C.TABSEL,t.lt); t.acc.Color=lerpC(C.SIDEBAR,C.ACCENT,t.lt)
                end
                -- Toggle animation
                for _,b in ipairs(btns) do
                    if b.isTog and b.tab==curTab and shown[b.bg] then
                        local tgt=b.state and 1 or 0; b.lt=b.lt+(tgt-b.lt)*0.18
                        b.tog.Color=lerpC(C.OFF,C.ON,b.lt); b.dot.Color=lerpC(C.OFFDOT,C.ONDOT,b.lt)
                        local sc=tabScroll[curTab] or 0; local ry=b.cRY or b.ry
                        local dox=b.rx+b.cw-L.TW-8; local ay=uiY+ry-sc
                        b.tog.Position=Vector2.new(uiX+dox,ay+b.ch/2-L.TH/2)
                        b.dot.Position=Vector2.new(uiX+dox+2+(L.TW-L.TH)*b.lt,ay+b.ch/2-L.TH/2+2)
                    end
                end
                -- Glow + title shimmer
                local t=tick()
                for i,s in ipairs(glowL) do
                    local p=t+glowPh[i]; s.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
                    s.Transparency=(i==1 and 0.6 or 0.75)+0.25*math.abs(math.sin(p*0.5))
                end
                local tf=(math.sin(t*2)+1)/2
                dTitleW.Color=lerpC(C.WHITE,C.ACCENT,tf); dTitleA.Color=lerpC(C.ACCENT,C.WHITE,tf)
                if dMiniTW then dMiniTW.Color=lerpC(C.WHITE,C.ACCENT,tf); dMiniTA.Color=lerpC(C.ACCENT,C.WHITE,tf) end
                -- Hover glow
                for _,b in ipairs(btns) do
                    if b.tab==curTab and shown[b.bg] and not b.isDiv and not b.isLog then
                        local sc=tabScroll[curTab] or 0; local iy=uiY+(b.cRY or b.ry)-sc
                        if inBox(uiX+b.rx,iy,b.cw,b.ch) then b.bg.Color=lerpC(C.ROWBG,C.WHITE,0.06); b.tHA=1
                        else b.tHA=0; if not b.isAct or not b.customCol then b.bg.Color=C.ROWBG end end
                        if b.outGlow then
                            local diff=(b.tHA or 0)-(b.hA or 0)
                            if math.abs(diff)>0.05 then b.hA=(b.hA or 0)+diff*0.15; b.outGlow.Transparency=b.hA*(dMain and dMain.Transparency or 1)
                            elseif b.tHA==0 then b.hA=0; b.outGlow.Transparency=0 end
                            b.outGlow.Visible=(b.hA or 0)>0.02
                        end
                    end
                end
                -- Footer labels
                if dWelcome and dNameTxt then
                    local fy=uiY+uiH-L.FOT+9
                    dWelcome.Position=Vector2.new(uiX+42,fy); dNameTxt.Position=Vector2.new(uiX+42+64,fy)
                    dWelcome.Visible=menuOpen; dNameTxt.Visible=menuOpen
                end
                if dCharLbl and charFn then
                    local nt=charFn(); if dCharLbl.Text~=" | "..nt then dCharLbl.Text=" | "..nt end
                end
                -- Scroll wheel
                if curTab and _scrollDelta~=0 and inBox(uiX+L.SB,uiY+L.TOP,L.CW,cH()) then
                    scrollTab(curTab,-_scrollDelta*28)
                end
                _scrollDelta=0
                -- Scrollbar thumb drag
                if curTab then
                    local total=tabRowY[curTab] or 0
                    local maxSc=math.max(0,total-cH()+8)
                    updateScrollbar()
                    if maxSc>0 then
                        local sbgY=uiY+L.TOP+2; local sbgH=uiH-L.TOP-L.FOT-4
                        local thumbH=math.max(20,math.min(sbgH,(cH()/(total+0.001))*sbgH))
                        if clicking and not wasClick and inBox(uiX+L.W-10,sbgY,12,sbgH) then
                            local sc=tabScroll[curTab] or 0
                            local thumbY=sbgY+clamp(sc/maxSc,0,1)*(sbgH-thumbH)
                            if inBox(uiX+L.W-10,thumbY,12,thumbH) then
                                scrDrag=true; scrDOY=mouse.Y-thumbY
                            else
                                -- click on track, jump to position
                                local rf=clamp((mouse.Y-sbgY-thumbH/2)/(sbgH-thumbH),0,1)
                                local newSc=rf*maxSc; local delta=newSc-(tabScroll[curTab] or 0)
                                scrollTab(curTab,delta); scrDrag=true; scrDOY=thumbH/2
                            end
                        end
                        if scrDrag and clicking then
                            local sc=tabScroll[curTab] or 0
                            local thumbY=sbgY+clamp(sc/maxSc,0,1)*(sbgH-thumbH)
                            local rf=clamp((mouse.Y-sbgY-scrDOY)/(sbgH-thumbH),0,1)
                            local newSc=rf*maxSc; local delta=newSc-sc
                            scrollTab(curTab,delta)
                        end
                    end
                end
                if not clicking then scrDrag=false end
                -- DD option alpha fade
                for _,b in ipairs(btns) do
                    if b.isDD then
                        local mfn=1-(toggledAt-(tick()-FADE))/FADE
                        local mOp=menuOpen and clamp(mfn,0,1) or clamp(1-mfn,0,1)
                        for _,o in ipairs(b.opts) do
                            local diff=o.targetA-o.alpha
                            if math.abs(diff)>0.01 then
                                o.alpha=o.alpha+diff*0.25; local v2=o.alpha>0.02
                                o.bg.Visible=v2; o.ln.Visible=v2; o.lb.Visible=v2
                                if v2 then o.bg.Transparency=o.alpha*mOp; o.ln.Transparency=o.alpha*mOp; o.lb.Transparency=o.alpha*mOp end
                            end
                        end
                    end
                end
            end

            applyFade()

            -- Height animation
            local dt=tick()-lastTick; lastTick=tick()
            if math.abs(uiH-uiHtgt)>1 then
                uiH=uiH+(uiHtgt-uiH)*clamp(dt*12,0,1); updatePos(); updateScrollbar()
                if curTab then for _,b in ipairs(btns) do if b.tab==curTab then bPos(b); bShow(b,not(b.section and _sections[b.section])) end end end
            elseif uiH~=uiHtgt then uiH=uiHtgt; updatePos(); updateScrollbar() end

            -- Tab fade cleanup
            if prevTab then
                if clamp((tick()-tabAt)/TFADE,0,1)>=1 then
                    for _,b in ipairs(btns) do if b.tab==prevTab then bShow(b,false) end end
                    for _,d in ipairs(allD) do if tabFade[d]=="prev" then tabFade[d]=nil end end
                    prevTab=nil
                end
            end

            -- CLICK HANDLING
            local mfn=1-(toggledAt-(tick()-FADE))/FADE
            local mOp=math.abs((menuOpen and 0 or 1)-clamp(mfn,0,1))
            local handleDrag=false

            if clicking and not wasClick and mOp>0.5 and not isLoading then
                if inBox(uiX,uiY,L.W,uiH) then handleDrag=true end

                -- Minimize/close dots
                if inBox(uiX+L.W-59,uiY+11,12,12) then
                    handleDrag=false; uiHtgt=L.MINI_H
                    task.spawn(function()
                        while math.abs(uiH-L.MINI_H)>2 and menuOpen do task.wait() end
                        if not menuOpen then return end
                        minimized=true; miniClosed=false; menuOpen=false
                        pcall(function() setrobloxinput(true) end)
                        for _,d in ipairs(allD) do d.Visible=false end
                        dScrBg.Visible=false; dScrThumb.Visible=false
                        refreshMini(); showMini(true); updateMiniPos()
                    end)
                elseif inBox(uiX+L.W-46,uiY+11,12,12) then
                    handleDrag=false; menuOpen=false; toggledAt=tick()
                elseif not inBox(uiX+L.W-10,uiY+L.TOP+2,12,uiH-L.TOP-L.FOT-4) then
                    -- DD option clicks
                    local optHit=false
                    if openDD then
                        local sc=tabScroll[openDD.tab] or 0
                        for i,o in ipairs(openDD.opts) do
                            if inBox(uiX+openDD.rx,uiY+o.ry-sc,openDD.cw,openDD.ch) then
                                optHit=true; handleDrag=false
                                openDD.selected=i; openDD.valLbl.Text=openDD.options[i]
                                for j,o2 in ipairs(openDD.opts) do o2.lb.Color=j==i and C.ACCENT or C.WHITE; o2.targetA=0 end
                                openDD.open=false; openDD.arrow.Text="v"
                                local prev=openDD; openDD=nil
                                uiHtgt=L.H; recalcLayout(curTab)
                                if prev.cb then pcall(prev.cb,prev.options[i],i) end; break
                            end
                        end
                    end
                    if not optHit then
                        -- Tab buttons
                        for _,t in ipairs(tabObjs) do
                            if inBox(uiX+7,uiY+t.tY,L.SB-14,26) then handleDrag=false; switchTab(t.name) end
                        end
                        -- Element clicks
                        for idx,b in ipairs(btns) do
                            if b.tab==curTab and not b.isSlider and shown[b.bg] then
                                local sc=tabScroll[curTab] or 0; local iy=uiY+(b.cRY or b.ry)-sc
                                if inBox(uiX+b.rx,iy,b.cw,b.ch) then
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
                                            uiHtgt=L.H; openDD=nil; recalcLayout(curTab)
                                        end
                                        b.open=not b.open; b.arrow.Text=b.open and "^" or "v"
                                        openDD=b.open and b or nil
                                        uiHtgt=b.open and (L.H+#b.opts*b.ch) or L.H
                                        if b.open then
                                            local sc2=tabScroll[curTab] or 0; local dax=uiX+b.rx; local day=uiY+b.ry-sc2
                                            for oi,o in ipairs(b.opts) do
                                                local oy2=day+b.ch+((oi-1)*b.ch)
                                                o.bg.Position=Vector2.new(dax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                                                o.ln.From=Vector2.new(dax,oy2+b.ch); o.ln.To=Vector2.new(dax+b.cw,oy2+b.ch)
                                                o.lb.Position=Vector2.new(dax+14,oy2+b.ch/2-6)
                                                o.ry=b.ry+b.ch+((oi-1)*b.ch); o.alpha=0; o.targetA=1
                                                setVis(o.bg,true); setVis(o.ln,true); setVis(o.lb,true)
                                            end
                                        end
                                        recalcLayout(curTab)
                                    elseif b.isColorPicker then
                                        local sc2=tabScroll[curTab] or 0; local iy2=uiY+(b.cRY or b.ry)-sc2
                                        local tw=(#b.swatches*19)-5; local sx0=uiX+b.rx+b.cw-tw-10
                                        for j,sw in ipairs(b.swatches) do
                                            local sx=sx0+(j-1)*19; local sy=iy2+b.ch/2-7
                                            if inBox(sx,sy,14,14) then
                                                b.selected=j; b.value=sw.col
                                                for k,sw2 in ipairs(b.swatches) do sw2.bor.Color=k==j and C.WHITE or C.DIMGRAY end
                                                if b.cb then pcall(b.cb,sw.col) end; break
                                            end
                                        end
                                    elseif b.isDiv and b.collapsible and b.section then
                                        if openDD then
                                            openDD.open=false; if openDD.arrow then openDD.arrow.Text="v" end
                                            for _,o in ipairs(openDD.opts) do o.targetA=0 end
                                            uiHtgt=L.H; openDD=nil
                                        end
                                        local sec=b.section; _sections[sec]=not _sections[sec]
                                        b.arrow.Text=_sections[sec] and ">" or "v"
                                        recalcLayout(curTab); break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- SLIDER DRAG
            for _,b in ipairs(btns) do
                if b.isSlider and b.tab==curTab and menuOpen and shown[b.bg] then
                    local sc=tabScroll[curTab] or 0; local ax=uiX+b.rx+8
                    local iy=uiY+(b.cRY or b.ry)-sc
                    local ay=iy+b.ch-11
                    if clicking and not wasClick and inBox(uiX+b.rx,iy,b.cw,b.ch) then
                        handleDrag=false; b.dragging=true
                    end
                    if not clicking and wasClick and b.dragging then
                        pcall(function() notify(b.baseLbl..": "..(b.isFloat and string.format("%.1f",b.value) or math.floor(b.value)),nil,2) end)
                    end
                    if not clicking then b.dragging=false end
                    if b.dragging and clicking then
                        local frac=clamp((mouse.X-ax)/b.trkW,0,1)
                        b.value=b.minV+frac*(b.maxV-b.minV)
                        local fx=ax+frac*b.trkW
                        b.fill.To=Vector2.new(fx,ay); b.handle.Position=Vector2.new(fx-4,ay-4)
                        b.lbl.Text=b.baseLbl..": "..(b.isFloat and string.format("%.1f",b.value) or math.floor(b.value))
                        if b.cb then pcall(b.cb,b.value) end
                    end
                end
            end

            -- WINDOW DRAG (topbar only, not on content/scrollbar/buttons)
            if clicking and not wasClick and handleDrag and menuOpen then
                if inBox(uiX,uiY,L.W,L.TOP) then
                    dragging=true; dragOX=mouse.X-uiX; dragOY=mouse.Y-uiY
                end
            end
            if not clicking then dragging=false end
            if dragging and clicking then
                local vpW,vpH=getVP()
                uiX=clamp(mouse.X-dragOX,0,vpW-L.W); uiY=clamp(mouse.Y-dragOY,0,vpH-uiH)
                updatePos(); updateScrollbar()
                if curTab then for _,b in ipairs(btns) do if b.tab==curTab then bPos(b) end end end
            end

            -- KEYBIND LISTEN
            if listenKey then
                for k=0x08,0xDD do
                    if iskeypressed(k) and k~=0x01 and k~=0x02 then
                        menuKey=k; local n=kname(k)
                        if iKeyInfo then btns[iKeyInfo].lbl.Text="Menu Key: "..n end
                        if iKeyBind then btns[iKeyBind].lbl.Text="Click to Rebind" end
                        dKeyLbl.Text=n; dMiniKey.Text=n; listenKey=false; break
                    end
                end
            end

            wasClick=clicking
            end end)
    end -- Init

    win._tabOrder=tabOrder
    function win:Tab(name) table.insert(tabOrder,name); return getTabAPI(name) end
    function win:SettingsTab(destroyCb)
        local s=self:Tab("Settings")
        s:Div("UI"); s:Dropdown("Theme",{"Check it","Dark","Moon","Grass","Light"},1,function(v) applyTheme(v) end)
        s:Div("KEYBIND"); iKeyInfo=s:Button("Menu Key: F1",C.ROWBG); iKeyBind=s:Button("Click to Rebind",Color3.fromRGB(14,20,40))
        s:Div("DANGER"); s:Button("Destroy Menu",Color3.fromRGB(28,7,7),destroyCb,Color3.fromRGB(210,55,55))
        return s
    end
    function win:ApplyTheme(name) applyTheme(name) end
    UILib.applyTheme=function(name) applyTheme(name) end
    function win:Destroy()
        destroyed=true
        pcall(function() _G.notify("UI destroyed.",titleA.." "..titleB,3) end)
        for _,d in ipairs(allD) do pcall(function() d:Remove() end) end
        for _,d in ipairs(miniD) do pcall(function() d:Remove() end) end
        for _,l in ipairs(miniLbls) do pcall(function() l:Remove() end) end
        for _,d in ipairs({dScrBg,dScrThumb,tipBg,tipBor,tipLbl,tipDesc}) do if d then pcall(function() d:Remove() end) end end
        for _,b in ipairs(btns) do if b.isLog then for _,l in ipairs(b.lbls) do pcall(function() l:Remove() end) end end end
    end
    return win
end

_G.UILib=UILib
print("[UILib] v2.1 loaded")
return UILib
