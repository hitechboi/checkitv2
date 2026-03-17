local UILib = {}
local tick = tick or os.clock
local warn = warn or function() end
task = task or _G.task
ismouse1pressed = ismouse1pressed or _G.ismouse1pressed or function() return false end
iskeypressed = iskeypressed or _G.iskeypressed or function() return false end
setrobloxinput = setrobloxinput or _G.setrobloxinput or function() end
notify = notify or _G.notify or function() end
if not task then
    task = {
        spawn = function(fn) coroutine.wrap(fn)() end,
        wait = function(t) local s=tick(); while tick()-s<(t or 0) do end end,
        delay = function(t,fn) task.spawn(function() task.wait(t); fn() end) end
    }
end

local THEMES = {
    ["Fatal Frame"] = {
        ACCENT=Color3.fromRGB(122,30,44), BG=Color3.fromRGB(12,10,10),
        SIDEBAR=Color3.fromRGB(16,12,12), CONTENT=Color3.fromRGB(14,11,11),
        ROWBG=Color3.fromRGB(20,16,16), TOPBAR=Color3.fromRGB(16,12,12),
        TABBAR=Color3.fromRGB(14,11,11), TABSEL=Color3.fromRGB(24,18,18),
        BORDER=Color3.fromRGB(30,22,22), DIV=Color3.fromRGB(28,20,20),
        DIMGRAY=Color3.fromRGB(50,38,38), GRAY=Color3.fromRGB(100,80,80),
        WHITE=Color3.fromRGB(200,180,180), BLACK=Color3.fromRGB(0,0,0),
        ON=Color3.fromRGB(122,30,44), OFF=Color3.fromRGB(40,30,30),
        ONDOT=Color3.fromRGB(200,180,180), OFFDOT=Color3.fromRGB(80,60,60),
        MINIBAR=Color3.fromRGB(14,11,11), SHADOW=Color3.fromRGB(0,0,0),
    }
}

local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function lerpC(a,b,t) return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t) end
local function getViewport()
    local ok,vp=pcall(function() return game.Workspace.CurrentCamera.ViewportSize end)
    if ok and vp then return vp.X, vp.Y end
    return 1920,1080
end

function UILib.Window(titleA, titleB, gameName, notifFn)
    local win = {}
    local mouse
    pcall(function() mouse = game.Players.LocalPlayer:GetMouse() end)
    local uname = ""
    pcall(function() uname = game.Players.LocalPlayer.Name end)

    local C = {}
    for k,v in pairs(THEMES["Fatal Frame"]) do C[k]=v end

    local L = {
        W=580, TOPBAR=32, TABBAR=24, CONTENT_TOP=56, FOOTER=28,
        ROW_H=28, ROW_PAD=8, COL_W=275, COL_GAP=14,
        TOG_W=28, TOG_H=12, HDL=8, MINI_H=64,
    }
    local uiCurrentH = 480
    local uiX, uiY = 100, 80
    local menuOpen = true
    local menuToggledAt = 0
    local FADE_DUR = 0.25
    local menuKey = 0x70
    local wasMenuKey = false
    local minimized = false
    local miniClosed = false
    local destroyed = false
    local wasClicking = false
    local dragging, dragOffX, dragOffY = false, 0, 0
    local miniDragging, miniDragOffX, miniDragOffY = false, 0, 0
    local currentTab = nil
    local openDropdown = nil
    local listenKey = false
    local _scrollDelta = 0
    local _collapseSections = {}
    local charLabelFn = nil

    local allDrawings = {}
    local showSet = {}
    local tabSet = {}
    local btns = {}
    local tabObjs = {}
    local tabScroll = {}
    local tabRowY = {}
    local baseUI = {}
    local miniDrawings = {}
    local miniActiveLbls = {}
    local miniActivePulse = {}
    local glowLines = {}
    local glowPhase = {}
    local iKeyBind, iKeyInfo
    local DROPDOWN_MAX_VISIBLE = 6

    local notif = notifFn or function(msg,title,dur)
        pcall(function() notify(msg, title or titleA.." "..titleB, dur or 3) end)
    end

    local function kname(k)
        local m={[0x70]="f1",[0x71]="f2",[0x72]="f3",[0x73]="f4",[0x74]="f5",[0x75]="f6",
                  [0x76]="f7",[0x77]="f8",[0x78]="f9",[0x79]="f10",[0x7A]="f11",[0x7B]="f12",
                  [0x24]="home",[0x23]="end",[0x2D]="ins",[0x2E]="del"}
        return m[k] or string.format("0x%02X",k)
    end

    -- Drawing primitives
    local function mkSq(x,y,w,h,col,fill,trans,zidx)
        local d=Drawing.new("Square")
        d.Position=Vector2.new(x,y); d.Size=Vector2.new(w,h)
        d.Color=col or C.BG; d.Filled=fill~=false; d.Transparency=1-(trans or 0)
        d.ZIndex=zidx or 1; d.Visible=false
        return d
    end
    local function mkLn(x1,y1,x2,y2,col,zidx,thick)
        local d=Drawing.new("Line")
        d.From=Vector2.new(x1,y1); d.To=Vector2.new(x2,y2)
        d.Color=col or C.BORDER; d.Thickness=thick or 1
        d.Transparency=1; d.ZIndex=zidx or 1; d.Visible=false
        return d
    end
    local function mkTx(txt,x,y,sz,col,center,zidx,bold)
        local d=Drawing.new("Text")
        d.Text=tostring(txt); d.Position=Vector2.new(x,y); d.Size=sz or 13
        d.Color=col or C.WHITE; d.Center=center==true; d.ZIndex=zidx or 1
        d.Visible=false; d.Outline=true
        pcall(function() d.Font=bold and Drawing.Fonts.SystemBold or Drawing.Fonts.System end)
        return d
    end
    local function mkD(d) table.insert(allDrawings,d); return d end

    -- Visibility
    local function setShow(d,yes)
        if not d then return end
        if yes then showSet[d]=true else showSet[d]=nil end
        local grp=tabSet[d]
        d.Visible=(yes==true) and (not grp or grp==currentTab)
    end

    local function inBox(x,y,w,h)
        if not mouse then return false end
        return mouse.X>=x and mouse.X<=x+w and mouse.Y>=y and mouse.Y<=y+h
    end

    local function CONTENT_H() return uiCurrentH-L.CONTENT_TOP-L.FOOTER end

    -- Scroll event (try multiple approaches for Matcha compat)
    pcall(function() mouse.WheelForward:Connect(function() _scrollDelta=_scrollDelta-1 end) end)
    pcall(function() mouse.WheelBackward:Connect(function() _scrollDelta=_scrollDelta+1 end) end)
    pcall(function()
        local UIS = game:GetService("UserInputService")
        UIS.InputBegan:Connect(function(input)
            pcall(function()
                if input.UserInputType == Enum.UserInputType.MouseWheel then
                    if input.Position.Z > 0 then _scrollDelta=_scrollDelta-1
                    elseif input.Position.Z < 0 then _scrollDelta=_scrollDelta+1 end
                end
            end)
        end)
    end)

    ----------------------------------------------------------------
    -- bShow / bPos
    ----------------------------------------------------------------
    local function bShow(b,yes)
        setShow(b.bg,yes)
        if b.lbl then setShow(b.lbl,yes) end
        if b.ln then setShow(b.ln,yes) end
        if b.outGlow then setShow(b.outGlow,yes) end
        if b.tog then setShow(b.tog,yes); setShow(b.dot,yes) end
        if b.oLbl then setShow(b.oLbl,yes) end
        if b.valLbl then setShow(b.valLbl,yes) end
        if b.track then setShow(b.track,yes); setShow(b.fill,yes); setShow(b.handle,yes) end
        if b.dlb then setShow(b.dlb,yes) end
        if b.out then setShow(b.out,yes) end
        if b.arrow then setShow(b.arrow,yes) end
        if b.isDropdown then
            for _,o in ipairs(b.optBgs or {}) do
                setShow(o.bg,yes and b.open); setShow(o.ln,yes and b.open); setShow(o.lb,yes and b.open)
            end
            if b.panelBg then setShow(b.panelBg,yes and b.open) end
            if b.panelBorder then setShow(b.panelBorder,yes and b.open) end
        end
        if b.isTextInput then
            if b.inputBg then setShow(b.inputBg,yes) end
            if b.inputTx then setShow(b.inputTx,yes) end
        end
        if b.isColorPicker then
            for _,sw in ipairs(b.swatches or {}) do setShow(sw.sq,yes); setShow(sw.border,yes) end
        end
        if b.qbg then setShow(b.qbg,yes) end
        if b.qlb then setShow(b.qlb,yes) end
    end

    local function bPos(b)
        local animY=b.currentRY or b.ry
        local sc=tabScroll[b.tab.."_"..b.col] or 0
        local colOff=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
        local ax,ay=uiX+colOff,uiY+animY-sc
        b.bg.Position=Vector2.new(ax,ay)
        if b.outGlow then b.outGlow.Position=Vector2.new(ax-1,ay-1) end
        if b.isDiv then
            b.lbl.Position=Vector2.new(ax+6,ay)
            if b.ln then b.ln.From=Vector2.new(ax,ay+13); b.ln.To=Vector2.new(ax+b.cw,ay+13) end
            if b.arrow then b.arrow.Position=Vector2.new(ax+b.cw-6,ay); b.arrow.Text=_collapseSections[b.sectionName] and ">" or "v" end
        elseif b.isAct then
            if b.out then b.out.Position=Vector2.new(ax,ay) end
            b.bg.Position=Vector2.new(ax+1,ay+1)
            b.lbl.Position=Vector2.new(ax+b.cw/2,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
        elseif b.isSlider then
            b.lbl.Position=Vector2.new(ax+8,ay+5)
            if b.valLbl then
                local disp=b.isFloat and string.format("%.2f",b.value) or tostring(math.floor(b.value))
                b.valLbl.Text=disp; b.valLbl.Position=Vector2.new(ax+b.cw-8-(#disp*6),ay+5)
            end
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
            local maxVis=math.min(DROPDOWN_MAX_VISIBLE,#(b.options or {}))
            if b.panelBg then setShow(b.panelBg,b.open) end
            if b.panelBorder then setShow(b.panelBorder,b.open) end
            if b.open and b.panelBg then
                local py=ay+b.ch; local ph=maxVis*b.ch
                b.panelBg.Position=Vector2.new(ax,py); b.panelBg.Size=Vector2.new(b.cw,ph)
                b.panelBorder.Position=Vector2.new(ax,py); b.panelBorder.Size=Vector2.new(b.cw,ph)
            end
            for i,o in ipairs(b.optBgs or {}) do
                local vi=i-scrollOff; local visible=vi>=1 and vi<=maxVis
                if visible then
                    local oy2=ay+b.ch+((vi-1)*b.ch)
                    o.bg.Position=Vector2.new(ax,oy2); o.bg.Size=Vector2.new(b.cw,b.ch)
                    o.ln.From=Vector2.new(ax,oy2+b.ch); o.ln.To=Vector2.new(ax+b.cw,oy2+b.ch)
                    o.lb.Position=Vector2.new(ax+12,oy2+b.ch/2-6)
                    o.bg.Color=lerpC(C.ROWBG,C.WHITE,(o.hoverAlpha or 0)*0.12)
                end
                setShow(o.bg,b.open and visible); setShow(o.ln,b.open and visible); setShow(o.lb,b.open and visible)
            end
        elseif b.isTextInput then
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            b.inputBg.Position=Vector2.new(ax+b.cw-b.inputW-8,ay+b.ch/2-9)
            b.inputTx.Position=Vector2.new(ax+b.cw-b.inputW-2,ay+b.ch/2-6)
        elseif b.isColorPicker then
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch)
            local totalW=(#b.swatches*19)-5; local startX=ax+b.cw-totalW-10
            for i,sw in ipairs(b.swatches) do
                local sx=startX+(i-1)*19; local sy=ay+b.ch/2-7
                sw.sq.Position=Vector2.new(sx,sy); sw.border.Position=Vector2.new(sx-1,sy-1)
            end
        else
            b.lbl.Position=Vector2.new(ax+10,ay+b.ch/2-6)
            if b.ln then b.ln.From=Vector2.new(ax,ay+b.ch); b.ln.To=Vector2.new(ax+b.cw,ay+b.ch) end
            if b.tog then
                local dox=b.cw-L.TOG_W-8
                b.tog.Position=Vector2.new(ax+dox,ay+b.ch/2-L.TOG_H/2)
                b.dot.Position=Vector2.new(ax+dox+2+(L.TOG_W-L.TOG_H)*b.lt,ay+b.ch/2-L.TOG_H/2+2)
                if b.oLbl then b.oLbl.Position=Vector2.new(ax+dox-12,ay+b.ch/2-5) end
            end
        end
    end

    local function tagBtnFade(b,group)
        tabSet[b.bg]=group
        if b.lbl then tabSet[b.lbl]=group end
        if b.outGlow then tabSet[b.outGlow]=group end
        if b.ln then tabSet[b.ln]=group end
        if b.tog then tabSet[b.tog]=group; tabSet[b.dot]=group end
        if b.oLbl then tabSet[b.oLbl]=group end
        if b.valLbl then tabSet[b.valLbl]=group end
        if b.track then tabSet[b.track]=group; tabSet[b.fill]=group; tabSet[b.handle]=group end
        if b.dlb then tabSet[b.dlb]=group end
        if b.out then tabSet[b.out]=group end
        if b.arrow then tabSet[b.arrow]=group end
        if b.isDropdown then
            for _,o in ipairs(b.optBgs or {}) do tabSet[o.bg]=group; tabSet[o.ln]=group; tabSet[o.lb]=group end
            if b.panelBg then tabSet[b.panelBg]=group end
            if b.panelBorder then tabSet[b.panelBorder]=group end
        end
        if b.isTextInput then
            if b.inputBg then tabSet[b.inputBg]=group end
            if b.inputTx then tabSet[b.inputTx]=group end
        end
        if b.isColorPicker then
            for _,sw in ipairs(b.swatches or {}) do tabSet[sw.sq]=group; tabSet[sw.border]=group end
        end
    end

    ----------------------------------------------------------------
    -- Tab system
    ----------------------------------------------------------------
    local function recalculateLayout(tab, col)
        local y = L.CONTENT_TOP + 6
        local key = tab.."_"..col
        for _,b in ipairs(btns) do
            if b.tab==tab and b.col==col then
                local isCollapsed = b.section and _collapseSections[b.section]
                if isCollapsed and not b.isDiv then
                    b.ry=y; b.baseRY=y; b._collapseTarget=y; b._collapsing=true
                    if b.currentRY then b._collapseTarget=y end
                else
                    b.ry=y; b.baseRY=y; b.currentRY=y; b._collapsing=false
                    local extra=0
                    if b.isDropdown and b.open then
                        extra=math.min(DROPDOWN_MAX_VISIBLE,#(b.options or {}))*b.ch
                    end
                    y=y+b.ch+2+extra
                end
            end
        end
        tabRowY[key]=y
    end

    local function switchTab(name)
        if openDropdown then
            openDropdown.open=false
            if openDropdown.arrow then openDropdown.arrow.Text="v" end
            for _,o in ipairs(openDropdown.optBgs or {}) do o.targetAlpha=0 end
            openDropdown=nil
        end
        for _,t in ipairs(tabObjs) do
            t.sel=(t.name==name)
            if t.lbl then t.lbl.Visible=t.sel and menuOpen end
            if t.lblG then t.lblG.Visible=(not t.sel) and menuOpen end
            if t.underline then t.underline.Visible=t.sel and menuOpen end
        end
        currentTab=name
        for _,b in ipairs(btns) do
            if b.tab==name then bShow(b,true); bPos(b) else bShow(b,false) end
        end
        recalculateLayout(name,"left"); recalculateLayout(name,"right")
        for _,b in ipairs(btns) do if showSet[b.bg] then bPos(b) end end
    end

    local function showTab(name)
        for _,b in ipairs(btns) do
            if b.tab==name then bShow(b,true); bPos(b) else bShow(b,false) end
        end
        for _,b in ipairs(btns) do if showSet[b.bg] then bPos(b) end end
    end

    local function resizeForDropdown(b, opening)
        recalculateLayout(b.tab, b.col)
    end

    ----------------------------------------------------------------
    -- Element creators
    ----------------------------------------------------------------
    local currentSection = {}

    local function addDiv(tab,col,lbl,relY,collapsible)
        local cw=L.COL_W; local ry=relY
        local bg=mkD(mkSq(0,0,cw,16,C.ROWBG,true,1,2))
        bg.Transparency=0; bg.Filled=false
        local lb=mkD(mkTx(lbl,0,0,10,C.ACCENT,false,8))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local arrow=collapsible and mkD(mkTx("v",0,0,10,C.GRAY,false,8)) or nil
        local sectionName=tab.."_"..col.."_"..lbl
        if collapsible then _collapseSections[sectionName]=false end
        currentSection[tab.."_"..col]=sectionName
        local b={tab=tab,col=col,isDiv=true,bg=bg,lbl=lb,ln=dl,arrow=arrow,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=16,
                 collapsible=collapsible,sectionName=sectionName,
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    local function addToggle(tab,col,lbl,relY,init,cb,desc)
        local cw=L.COL_W; local ch=L.ROW_H; local ry=relY
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local tog=mkD(mkSq(0,0,L.TOG_W,L.TOG_H,init and C.ON or C.OFF,true,1,6))
        local dot=mkD(mkSq(0,0,L.TOG_H-4,L.TOG_H-4,init and C.ONDOT or C.OFFDOT,true,1,7))
        local oLbl=mkD(mkTx("o",0,0,9,init and C.ONDOT or C.OFFDOT,false,6))
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5))
        local secKey=tab.."_"..col
        local b={tab=tab,col=col,isTog=true,bg=bg,lbl=lb,ln=dl,tog=tog,dot=dot,oLbl=oLbl,
                 outGlow=outGlow,toggleName=lbl,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,
                 state=init or false,lt=init and 1 or 0,cb=cb,
                 section=currentSection[secKey],
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    local function addSlider(tab,col,lbl,relY,minV,maxV,initV,cb,isFloat,desc)
        local cw=L.COL_W; local ch=L.ROW_H+4; local ry=relY
        local trackW=cw-16
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local dlb=desc and mkD(mkTx(desc,0,0,9,C.GRAY,false,8)) or nil
        local trk=mkD(mkLn(0,0,0,0,C.DIMGRAY,5,3))
        local fil=mkD(mkLn(0,0,0,0,C.ACCENT,6,3))
        local hdl=mkD(mkSq(0,0,L.HDL,L.HDL,C.ACCENT,true,1,7))
        local initDisp=isFloat and string.format("%.2f",initV) or tostring(math.floor(initV))
        local sValLbl=mkD(mkTx(initDisp,0,0,11,C.ACCENT,false,8))
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5))
        local secKey=tab.."_"..col
        local b={tab=tab,col=col,isSlider=true,bg=bg,lbl=lb,ln=dl,track=trk,fill=fil,handle=hdl,
                 outGlow=outGlow,valLbl=sValLbl,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,trackW=trackW,
                 minV=minV,maxV=maxV,value=initV,baseLbl=lbl,dragging=false,cb=cb,
                 isFloat=isFloat or false,dlb=dlb,
                 section=currentSection[secKey],
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    local function addAct(tab,col,lbl,relY,bgCol,cb,lblCol)
        local cw=L.COL_W; local ch=L.ROW_H-2; local ry=relY
        local outBg=bgCol or C.ROWBG
        local out=mkD(mkSq(0,0,cw,ch,outBg,true,1,3))
        local bg=mkD(mkSq(0,0,cw-2,ch-2,bgCol or C.ROWBG,true,1,4))
        local lb=mkD(mkTx(lbl,0,0,11,lblCol or C.WHITE,true,8))
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5))
        local secKey=tab.."_"..col
        local b={tab=tab,col=col,isAct=true,customCol=bgCol~=nil,out=out,bg=bg,lbl=lb,outGlow=outGlow,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,cb=cb,
                 section=currentSection[secKey],
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    local function addDropdown(tab,col,lbl,relY,options,initIdx,cb)
        local cw=L.COL_W; local ch=L.ROW_H; local ry=relY
        local out=mkD(mkSq(0,0,cw,ch,C.BORDER,true,1,3))
        local bg=mkD(mkSq(0,0,cw-2,ch-2,C.ROWBG,true,1,4))
        local lb=mkD(mkTx(lbl,0,0,11,C.GRAY,false,8))
        local vl=mkD(mkTx(options[initIdx] or "",0,0,11,C.WHITE,false,8))
        local ar=mkD(mkTx("v",0,0,11,C.GRAY,false,8))
        local panelBg=mkD(mkSq(0,0,cw,ch*DROPDOWN_MAX_VISIBLE,C.ROWBG,true,1,9))
        local panelBorder=mkD(mkSq(0,0,cw,ch*DROPDOWN_MAX_VISIBLE,C.BORDER,false,1,10))
        local optBgs={}
        for i,opt in ipairs(options) do
            local obg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,10))
            local oln=mkD(mkLn(0,0,0,0,C.DIV,10,1))
            local olb=mkD(mkTx(opt,0,0,11,i==initIdx and C.ACCENT or C.WHITE,false,11))
            table.insert(optBgs,{bg=obg,ln=oln,lb=olb,hoverAlpha=0,targetAlpha=0,alpha=0})
        end
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5))
        local secKey=tab.."_"..col
        local b={tab=tab,col=col,isDropdown=true,out=out,bg=bg,lbl=lb,valLbl=vl,arrow=ar,
                 outGlow=outGlow,panelBg=panelBg,panelBorder=panelBorder,optBgs=optBgs,
                 options=options,selected=initIdx,scrollOffset=0,highlightIdx=initIdx,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,cb=cb,open=false,
                 section=currentSection[secKey],
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    local function addTextInput(tab,col,lbl,relY,default,inputW,cb)
        local cw=L.COL_W; local ch=L.ROW_H; local ry=relY
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local ibg=mkD(mkSq(0,0,inputW,18,C.CONTENT,true,1,5))
        local itx=mkD(mkTx(default or "",0,0,11,C.ACCENT,false,6))
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5))
        local secKey=tab.."_"..col
        local b={tab=tab,col=col,isTextInput=true,bg=bg,lbl=lb,ln=dl,
                 inputBg=ibg,inputTx=itx,inputW=inputW,outGlow=outGlow,
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,
                 value=default or "",cb=cb,
                 section=currentSection[secKey],
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    local function addColorPicker(tab,col,lbl,relY,initCol,cb)
        local cw=L.COL_W; local ch=L.ROW_H; local ry=relY
        local bg=mkD(mkSq(0,0,cw,ch,C.ROWBG,true,1,3))
        local lb=mkD(mkTx(lbl,0,0,11,C.WHITE,false,8))
        local dl=mkD(mkLn(0,0,0,0,C.DIV,4,1))
        local presets={
            Color3.fromRGB(255,0,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,100,255),
            Color3.fromRGB(255,255,0),Color3.fromRGB(255,0,255),Color3.fromRGB(255,255,255),
            Color3.fromRGB(122,30,44),Color3.fromRGB(0,0,0)
        }
        local swatches={}
        for i,c in ipairs(presets) do
            local sq=mkD(mkSq(0,0,14,14,c,true,1,6))
            local bd=mkD(mkSq(0,0,16,16,i==1 and C.WHITE or C.BORDER,false,1,5))
            table.insert(swatches,{sq=sq,border=bd,col=c})
        end
        local outGlow=mkD(mkSq(0,0,cw+2,ch+2,C.ACCENT,false,0,5))
        local secKey=tab.."_"..col
        local b={tab=tab,col=col,isColorPicker=true,bg=bg,lbl=lb,ln=dl,swatches=swatches,
                 outGlow=outGlow,selected=1,value=presets[1],
                 rx=0,ry=ry,baseRY=ry,currentRY=ry,cw=cw,ch=ch,cb=cb,
                 section=currentSection[secKey],
                 hoverAlpha=0,targetHoverAlpha=0}
        tagBtnFade(b,tab)
        table.insert(btns,b); return #btns
    end

    ----------------------------------------------------------------
    -- Tab API
    ----------------------------------------------------------------
    local function getTabAPI(tabName, col)
        local nextYVal = L.CONTENT_TOP + 6
        local function nextY(h)
            local y=nextYVal; nextYVal=nextYVal+h+2; return y
        end
        local api = {}
        function api:Div(lbl, collapsible)
            if collapsible==nil then collapsible=true end
            addDiv(tabName,col,lbl,nextY(20),collapsible)
        end
        function api:Toggle(lbl, init, cb, desc)
            addToggle(tabName,col,lbl,nextY(L.ROW_H+2),init,cb,desc)
        end
        function api:Slider(lbl, minV, maxV, initV, cb, isFloat, desc)
            addSlider(tabName,col,lbl,nextY(L.ROW_H+6),minV,maxV,initV,cb,isFloat,desc)
        end
        function api:Button(lbl, bgCol, cb, lblCol)
            return addAct(tabName,col,lbl,nextY(L.ROW_H),bgCol,cb,lblCol)
        end
        function api:Dropdown(lbl, options, initIdx, cb)
            addDropdown(tabName,col,lbl,nextY(L.ROW_H+2),options,initIdx,cb)
        end
        function api:TextInput(lbl, default, inputW, cb)
            addTextInput(tabName,col,lbl,nextY(L.ROW_H+2),default,inputW,cb)
        end
        function api:ColorPicker(lbl, initCol, cb)
            addColorPicker(tabName,col,lbl,nextY(L.ROW_H+2),initCol,cb)
        end
        return api
    end

    ----------------------------------------------------------------
    -- Tab registration
    ----------------------------------------------------------------
    win._tabOrder = {}
    function win:Tab(name)
        table.insert(win._tabOrder, name)
        local left = getTabAPI(name, "left")
        local right = getTabAPI(name, "right")
        return {Left=left, Right=right, left=left, right=right,
                Name=name, name=name}
    end

    function win:SettingsTab(destroyCb)
        local st = win:Tab("settings")
        local themeNames = {}
        for k in pairs(THEMES) do table.insert(themeNames,k) end
        st.Left:Div("appearance")
        st.Left:Dropdown("theme", themeNames, 1, function(val)
            pcall(function()
                for k,v in pairs(THEMES[val]) do C[k]=v end
                for _,d in ipairs(allDrawings) do
                    pcall(function()
                        if d.Color then
                            -- recolor handled in loop
                        end
                    end)
                end
            end)
        end)
        st.Left:Div("controls")
        iKeyInfo = st.Left:Button("Menu Key: "..kname(menuKey), nil, nil)
        iKeyBind = st.Left:Button("Click to Rebind", nil, function()
            listenKey = true
            btns[iKeyBind].lbl.Text = "Press any key..."
        end)
        st.Right:Div("actions")
        st.Right:Button("Destroy UI", Color3.fromRGB(122,30,44), function()
            if destroyCb then destroyCb() end
        end, C.WHITE)
        recalculateLayout("settings","left"); recalculateLayout("settings","right")
    end

    ----------------------------------------------------------------
    -- Base drawing variables
    ----------------------------------------------------------------
    local dShadow,dMainBg,dGlow1,dGlow2,dBorder
    local dTopBar,dTopLine,dTabBar,dTabLine
    local dTitleW,dTitleA,dTitleG,dKeyLbl,dBtnMinimize,dBtnClose
    local dContent,dFooter,dFotLine,dFooterRight
    local dWelcomeTxt,dNameTxt

    local dMiniShadow,dMiniBg,dMiniGlow1,dMiniGlow2,dMiniBorder
    local dMiniTopBar,dMiniTitleW,dMiniTitleA,dMiniKeyLbl,dMiniDivLn,dMiniActiveBg

    ----------------------------------------------------------------
    -- updatePos
    ----------------------------------------------------------------
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
        local tabStartX=uiX+12
        for _,t in ipairs(tabObjs) do
            t.tabX=tabStartX
            t.lbl.Position=Vector2.new(tabStartX,uiY+L.TOPBAR+7)
            t.lblG.Position=Vector2.new(tabStartX,uiY+L.TOPBAR+7)
            t.underline.From=Vector2.new(tabStartX,uiY+L.CONTENT_TOP-1)
            t.underline.To=Vector2.new(tabStartX+t.tw,uiY+L.CONTENT_TOP-1)
            tabStartX=tabStartX+t.tw+16
        end
        for _,b in ipairs(btns) do if showSet[b.bg] then bPos(b) end end
    end

    local function updateMiniPos()
        dMiniShadow.Position=Vector2.new(uiX-2,uiY-2); dMiniShadow.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniBg.Position=Vector2.new(uiX,uiY); dMiniBg.Size=Vector2.new(L.W,L.MINI_H)
        dMiniBorder.Position=Vector2.new(uiX,uiY); dMiniBorder.Size=Vector2.new(L.W,L.MINI_H)
        dMiniGlow1.Position=Vector2.new(uiX-1,uiY-1); dMiniGlow1.Size=Vector2.new(L.W+2,L.MINI_H+2)
        dMiniGlow2.Position=Vector2.new(uiX-2,uiY-2); dMiniGlow2.Size=Vector2.new(L.W+4,L.MINI_H+4)
        dMiniTopBar.Position=Vector2.new(uiX+1,uiY+1); dMiniTopBar.Size=Vector2.new(L.W-2,L.TOPBAR)
        dMiniTitleW.Position=Vector2.new(uiX+14,uiY+8)
        dMiniTitleA.Position=Vector2.new(uiX+60,uiY+8)
        dMiniKeyLbl.Position=Vector2.new(uiX+L.W-16,uiY+10)
        dMiniDivLn.From=Vector2.new(uiX+1,uiY+L.TOPBAR); dMiniDivLn.To=Vector2.new(uiX+L.W-1,uiY+L.TOPBAR)
        dMiniActiveBg.Position=Vector2.new(uiX+1,uiY+L.TOPBAR); dMiniActiveBg.Size=Vector2.new(L.W-2,L.MINI_H-L.TOPBAR-1)
    end

    local function refreshMiniLabels()
        for i,lb in ipairs(miniActiveLbls) do lb.Text="" end
        local idx=1
        for _,b in ipairs(btns) do
            if b.isTog and b.state and idx<=#miniActiveLbls then
                miniActiveLbls[idx].Text=b.toggleName or ""; idx=idx+1
            end
        end
    end

    local function showMiniUI(yes)
        for _,d in ipairs(miniDrawings) do d.Visible=yes end
        minimized=yes
        if yes then
            for _,d in ipairs(allDrawings) do d.Visible=false end
        end
    end

    local function applyFade()
        local elapsed=tick()-menuToggledAt
        local frac=clamp(elapsed/FADE_DUR,0,1)
        local alpha=menuOpen and frac or (1-frac)
        for _,d in ipairs(allDrawings) do
            if showSet[d] then
                local grp=tabSet[d]
                local vis=(not grp or grp==currentTab)
                d.Transparency=alpha
                d.Visible=vis and alpha>0.01
            end
        end
        dShadow.Transparency=alpha*0.5
        dGlow1.Transparency=alpha*0.15
        dGlow2.Transparency=alpha*0.08
    end

    ----------------------------------------------------------------
    -- Init
    ----------------------------------------------------------------
    function win:Init(defaultTab, _charLabelFn)
        charLabelFn = _charLabelFn
        -- Create base drawings
        dShadow=mkD(mkSq(0,0,L.W+4,uiCurrentH+4,C.SHADOW,true,0.5,1))
        dMainBg=mkD(mkSq(0,0,L.W,uiCurrentH,C.BG,true,1,2))
        dGlow1=mkD(mkSq(0,0,L.W+2,uiCurrentH+2,C.ACCENT,false,0.15,1))
        dGlow2=mkD(mkSq(0,0,L.W+4,uiCurrentH+4,C.ACCENT,false,0.08,1))
        dBorder=mkD(mkSq(0,0,L.W,uiCurrentH,C.BORDER,false,1,3))
        dTopBar=mkD(mkSq(0,0,L.W-2,L.TOPBAR,C.TOPBAR,true,1,4))
        dTopLine=mkD(mkLn(0,0,0,0,C.BORDER,4,1))
        dTabBar=mkD(mkSq(0,0,L.W-2,L.TABBAR,C.TABBAR,true,1,4))
        dTabLine=mkD(mkLn(0,0,0,0,C.BORDER,4,1))
        dTitleW=mkD(mkTx(titleA,0,0,14,C.WHITE,false,9,true))
        dTitleA=mkD(mkTx(titleB,0,0,14,C.ACCENT,false,9,true))
        local gn=gameName or ""
        pcall(function()
            if gn=="" then
                local ok2,n=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
                if ok2 and n then gn=n end
            end
        end)
        dTitleG=mkD(mkTx(gn,0,0,11,C.GRAY,false,7))
        dKeyLbl=mkD(mkTx(kname(menuKey),0,0,10,C.GRAY,false,9))
        dBtnMinimize=mkD(mkTx("-",0,0,14,C.GRAY,false,9))
        dBtnClose=mkD(mkTx("x",0,0,14,C.GRAY,false,9))
        dContent=mkD(mkSq(0,0,L.W-2,uiCurrentH-L.CONTENT_TOP-L.FOOTER-1,C.CONTENT,true,1,2))
        dFooter=mkD(mkSq(0,0,L.W-2,L.FOOTER-1,C.TOPBAR,true,1,3))
        dFotLine=mkD(mkLn(0,0,0,0,C.BORDER,4,1))
        dWelcomeTxt=mkD(mkTx("welcome, ",0,0,11,C.GRAY,false,5,false))
        dNameTxt=mkD(mkTx(uname,0,0,11,C.WHITE,false,5,true))
        dFooterRight=mkD(mkTx("",0,0,11,C.GRAY,false,5,false))

        baseUI={dShadow,dMainBg,dGlow2,dGlow1,dBorder,dTopBar,dTopLine,dTabBar,dTabLine,
                dTitleW,dTitleA,dTitleG,dKeyLbl,dBtnMinimize,dBtnClose,
                dContent,dFooter,dFotLine,dWelcomeTxt,dNameTxt,dFooterRight}

        -- Create tab labels
        for _,name in ipairs(win._tabOrder) do
            local tw=#name*7+4
            local lb=mkTx(name,0,0,11,C.WHITE,false,8,true)
            local lbG=mkTx(name,0,0,11,C.GRAY,false,8)
            local ul=mkLn(0,0,0,0,C.ACCENT,8,2)
            local sel=(name==defaultTab)
            local t={name=name,lbl=lb,lblG=lbG,underline=ul,tw=tw,sel=sel,tabX=0}
            table.insert(tabObjs,t)
            table.insert(allDrawings,lb); table.insert(allDrawings,lbG); table.insert(allDrawings,ul)
        end

        -- Glow lines
        for i=1,2 do
            local g=mkD(mkSq(0,0,L.W,2,C.ACCENT,true,0.6,1))
            table.insert(glowLines,g); glowPhase[i]=math.random()*6.28
        end

        -- Mini bar drawings
        dMiniShadow=mkSq(0,0,L.W+4,L.MINI_H+4,C.SHADOW,true,0.5,1)
        dMiniBg=mkSq(0,0,L.W,L.MINI_H,C.BG,true,1,2)
        dMiniGlow1=mkSq(0,0,L.W+2,L.MINI_H+2,C.ACCENT,false,0.15,1)
        dMiniGlow2=mkSq(0,0,L.W+4,L.MINI_H+4,C.ACCENT,false,0.08,1)
        dMiniBorder=mkSq(0,0,L.W,L.MINI_H,C.BORDER,false,1,3)
        dMiniTopBar=mkSq(0,0,L.W-2,L.TOPBAR,C.TOPBAR,true,1,4)
        dMiniTitleW=mkTx(titleA,0,0,14,C.WHITE,false,9,true)
        dMiniTitleA=mkTx(titleB,0,0,14,C.ACCENT,false,9,true)
        dMiniKeyLbl=mkTx(kname(menuKey),0,0,10,C.GRAY,false,9)
        dMiniDivLn=mkLn(0,0,0,0,C.BORDER,4,1)
        dMiniActiveBg=mkSq(0,0,L.W-2,L.MINI_H-L.TOPBAR-1,C.MINIBAR,true,1,2)
        miniDrawings={dMiniShadow,dMiniBg,dMiniGlow2,dMiniGlow1,dMiniBorder,dMiniTopBar,dMiniTitleW,dMiniTitleA,dMiniKeyLbl,dMiniDivLn,dMiniActiveBg}
        for _,d in ipairs(miniDrawings) do d.Visible=false end

        -- Mini active labels
        for i=1,5 do
            local lb=mkTx("",uiX+14,uiY+L.TOPBAR+4+(i-1)*10,9,C.ACCENT,false,5)
            table.insert(miniActiveLbls,lb); miniActivePulse[i]=math.random()*6.28
        end

        -- Init state
        currentTab=defaultTab
        notif("Loaded on "..(gn or ""),"check it v2",4)
        for _,d in ipairs(baseUI) do setShow(d,true) end
        for _,t in ipairs(tabObjs) do
            setShow(t.lbl,t.sel); setShow(t.lblG,not t.sel); setShow(t.underline,t.sel)
        end
        showTab(currentTab)
        recalculateLayout(currentTab,"left"); recalculateLayout(currentTab,"right")
        updatePos()

        ----------------------------------------------------------------
        -- RENDER LOOP (modeled after v1's proven approach)
        ----------------------------------------------------------------
        task.spawn(function()
        while not destroyed do
            task.wait(0.016)
            local clicking = false
            pcall(function() clicking = ismouse1pressed() end)
            local keyDown = false
            pcall(function() keyDown = iskeypressed(menuKey) end)

            -- Menu key toggle
            if keyDown and not wasMenuKey then
                if miniClosed then
                    miniClosed=false; refreshMiniLabels(); showMiniUI(true); updateMiniPos()
                    for _,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible=true end end
                elseif minimized then
                    showMiniUI(false); miniClosed=true
                    for _,d in ipairs(allDrawings) do d.Visible=false end
                else
                    menuOpen=not menuOpen; menuToggledAt=tick()
                    pcall(function() setrobloxinput(not menuOpen) end)
                end
            end
            wasMenuKey=keyDown

            -- Minibar mode
            if minimized and not miniClosed then
                local t=tick()*1.0
                for i,sq in ipairs(glowLines) do
                    sq.Visible=false
                end
                local pt=tick()*0.8
                for i,lb in ipairs(miniActiveLbls) do
                    if lb.Text~="" then
                        lb.Visible=true
                        local f=(math.sin(pt+miniActivePulse[i])+1)/2
                        lb.Color=lerpC(C.ACCENT,C.WHITE,f)
                    else lb.Visible=false end
                end
                if clicking and not wasClicking then
                    if inBox(uiX+L.W-42,uiY+11,12,12) then
                        miniClosed=true
                        for _,d in ipairs(miniDrawings) do d.Visible=false end
                        for _,l in ipairs(miniActiveLbls) do l.Visible=false end
                        for _,d in ipairs(allDrawings) do d.Visible=false end
                    elseif inBox(uiX+L.W-28,uiY+11,12,12) then
                        showMiniUI(false); minimized=false
                        menuOpen=true; menuToggledAt=tick()
                        for _,d in ipairs(baseUI) do setShow(d,true) end
                        for _,t2 in ipairs(tabObjs) do
                            setShow(t2.lbl,t2.sel); setShow(t2.lblG,not t2.sel); setShow(t2.underline,t2.sel)
                        end
                        showTab(currentTab); updatePos()
                    elseif inBox(uiX,uiY,L.W,L.MINI_H) then
                        miniDragging=true; miniDragOffX=mouse.X-uiX; miniDragOffY=mouse.Y-uiY
                    end
                end
                if not clicking then miniDragging=false end
                if miniDragging and clicking then
                    local vpW,vpH=getViewport()
                    uiX=clamp(mouse.X-miniDragOffX,0,vpW-L.W)
                    uiY=clamp(mouse.Y-miniDragOffY,0,vpH-L.MINI_H)
                    updateMiniPos()
                end
                wasClicking=clicking
            end

            -- Full UI mode
            if not minimized then
                for _,lb in ipairs(miniActiveLbls) do lb.Visible=false end

                -- Glow animation
                local t=tick()*1.0
                for i,sq in ipairs(glowLines) do
                    local p=t+glowPhase[i]
                    sq.Color=lerpC(C.ACCENT,C.WHITE,math.abs(math.sin(p))*0.3)
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
                        if b.oLbl then b.oLbl.Color=lerpC(C.OFFDOT,C.ONDOT,b.lt) end
                        if showSet[b.bg] then bPos(b) end
                    end
                end

                -- Hover effects
                for _,b in ipairs(btns) do
                    if menuOpen and b.tab==currentTab and showSet[b.bg] and not b.isDiv then
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

                -- Fade
                applyFade()

                -- Footer position
                if dWelcomeTxt and dNameTxt then
                    local wX=uiX+14; local tY=uiY+uiCurrentH-L.FOOTER+7
                    dWelcomeTxt.Position=Vector2.new(wX,tY); dWelcomeTxt.Visible=menuOpen
                    dNameTxt.Position=Vector2.new(wX+60,tY); dNameTxt.Visible=menuOpen
                end

                -- Smooth layout
                for _,b in ipairs(btns) do
                    if b.currentRY and b.tab==currentTab then
                        if b._collapsing and b._collapseTarget then
                            local diff2=b._collapseTarget-b.currentRY
                            if math.abs(diff2)>0.5 then b.currentRY=b.currentRY+diff2*0.2
                            else b.currentRY=b._collapseTarget; b._collapsing=false end
                        else
                            local diff2=b.ry-b.currentRY
                            if math.abs(diff2)>0.5 then b.currentRY=b.currentRY+diff2*0.2
                            else b.currentRY=b.ry end
                        end
                        if showSet[b.bg] then bPos(b) end
                    end
                end

                -- Content clipping
                local clipTop=uiY+L.CONTENT_TOP
                local clipBot=uiY+uiCurrentH-L.FOOTER
                for _,b in ipairs(btns) do
                    if b.tab==currentTab and showSet[b.bg] then
                        local sc=tabScroll[b.tab.."_"..b.col] or 0
                        local itemY=uiY+(b.currentRY or b.ry)-sc
                        local isCollapsed=b.section and _collapseSections[b.section]
                        if itemY+b.ch<clipTop or itemY>clipBot or (isCollapsed and not b.isDiv) then
                            b.bg.Visible=false; if b.lbl then b.lbl.Visible=false end
                            if b.ln then b.ln.Visible=false end
                            if b.tog then b.tog.Visible=false; b.dot.Visible=false end
                            if b.oLbl then b.oLbl.Visible=false end
                            if b.valLbl then b.valLbl.Visible=false end
                            if b.track then b.track.Visible=false; b.fill.Visible=false; b.handle.Visible=false end
                            if b.out then b.out.Visible=false end
                            if b.dlb then b.dlb.Visible=false end
                            if b.arrow then b.arrow.Visible=false end
                            if b.isTextInput then
                                if b.inputBg then b.inputBg.Visible=false end
                                if b.inputTx then b.inputTx.Visible=false end
                            end
                        end
                    end
                end

                -- Handle click (single frame: clicking and not wasClicking)
                local handleDrag=true
                local mfn=1-((menuToggledAt+FADE_DUR-tick())/FADE_DUR)
                local mOp=menuOpen and clamp(mfn,0,1) or (1-clamp(mfn,0,1))

                if clicking and not wasClicking and mOp>0.5 then
                    -- Minimize/close buttons
                    if inBox(uiX+L.W-42,uiY+8,14,20) then
                        handleDrag=false
                        minimized=true; showMiniUI(true)
                        refreshMiniLabels(); updateMiniPos()
                        for _,lb in ipairs(miniActiveLbls) do if lb.Text~="" then lb.Visible=true end end
                    elseif inBox(uiX+L.W-28,uiY+8,14,20) then
                        handleDrag=false; win:Destroy()
                    end

                    -- Tab clicks
                    for _,t2 in ipairs(tabObjs) do
                        if inBox(t2.tabX,uiY+L.TOPBAR,t2.tw,L.TABBAR) then
                            handleDrag=false; switchTab(t2.name)
                        end
                    end

                    -- Dropdown option clicks
                    if openDropdown and openDropdown.open then
                        local bd=openDropdown
                        local sc=tabScroll[bd.tab.."_"..bd.col] or 0
                        local colOff=bd.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                        local bdy=uiY+(bd.currentRY or bd.ry)-sc
                        local scrollOff=bd.scrollOffset or 0
                        local maxVis=math.min(DROPDOWN_MAX_VISIBLE,#(bd.options or {}))
                        for i=1,maxVis do
                            local oi=i+scrollOff
                            if oi>0 and oi<=#bd.options then
                                local oy=bdy+bd.ch+((i-1)*bd.ch)
                                if inBox(uiX+colOff,oy,bd.cw,bd.ch) then
                                    handleDrag=false
                                    bd.selected=oi; bd.valLbl.Text=bd.options[oi]
                                    for j,o in ipairs(bd.optBgs) do o.lb.Color=j==oi and C.ACCENT or C.WHITE end
                                    bd.open=false; bd.arrow.Text="v"; openDropdown=nil
                                    resizeForDropdown(bd,false)
                                    if bd.cb then bd.cb(bd.options[oi],oi) end
                                    break
                                end
                            end
                        end
                    end

                    -- Element clicks
                    for _,b in ipairs(btns) do
                        if b.tab==currentTab and not b.isSlider and showSet[b.bg] then
                            local sc=tabScroll[b.tab.."_"..b.col] or 0
                            local colOff=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                            local itemY=uiY+(b.currentRY or b.ry)-sc
                            if inBox(uiX+colOff,itemY,b.cw,b.ch) then
                                handleDrag=false
                                if b.isTog then
                                    b.state=not b.state
                                    if b.cb then b.cb(b.state) end
                                    notif(b.toggleName.." "..(b.state and "enabled" or "disabled"),nil,2)
                                    refreshMiniLabels()
                                elseif b.isAct then
                                    if iKeyBind and b==btns[iKeyBind] and not listenKey then
                                        listenKey=true; btns[iKeyBind].lbl.Text="Press any key..."
                                    elseif b.cb then b.cb() end
                                elseif b.isDropdown then
                                    if openDropdown and openDropdown~=b then
                                        openDropdown.open=false; if openDropdown.arrow then openDropdown.arrow.Text="v" end
                                        resizeForDropdown(openDropdown,false); openDropdown=nil
                                    end
                                    b.open=not b.open
                                    if b.arrow then b.arrow.Text=b.open and "^" or "v" end
                                    if b.open then b.scrollOffset=0; openDropdown=b
                                        for _,o in ipairs(b.optBgs) do o.targetAlpha=1; setShow(o.bg,true); setShow(o.ln,true); setShow(o.lb,true) end
                                    else openDropdown=nil end
                                    resizeForDropdown(b,b.open)
                                elseif b.isColorPicker then
                                    local colOff2=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                                    local ax2=uiX+colOff2
                                    local totalW2=(#b.swatches*19)-5; local startX2=ax2+b.cw-totalW2-10
                                    for j,sw in ipairs(b.swatches) do
                                        local sx=startX2+(j-1)*19; local sy=itemY+b.ch/2-7
                                        if inBox(sx,sy,14,14) then
                                            b.selected=j; b.value=sw.col
                                            for k2,sw2 in ipairs(b.swatches) do sw2.border.Color=k2==j and C.WHITE or C.BORDER end
                                            if b.cb then b.cb(sw.col) end; break
                                        end
                                    end
                                elseif b.isDiv and b.collapsible and b.sectionName then
                                    _collapseSections[b.sectionName]=not _collapseSections[b.sectionName]
                                    if b.arrow then b.arrow.Text=_collapseSections[b.sectionName] and ">" or "v" end
                                    recalculateLayout(currentTab,"left"); recalculateLayout(currentTab,"right")
                                end
                            end
                        end
                    end
                end

                -- Slider dragging
                for _,b in ipairs(btns) do
                    if b.isSlider and b.tab==currentTab and menuOpen then
                        local sc=tabScroll[b.tab.."_"..b.col] or 0
                        local colOff=b.col=="right" and (L.ROW_PAD+L.COL_W+L.COL_GAP) or L.ROW_PAD
                        local ax=uiX+colOff+8; local itemY=uiY+(b.currentRY or b.ry)-sc
                        if clicking and not wasClicking and inBox(uiX+colOff,itemY,b.cw,b.ch) and b.bg.Visible then
                            handleDrag=false; b.dragging=true
                        end
                        if not clicking and b.dragging then
                            local disp=b.isFloat and string.format("%.2f",b.value) or math.floor(b.value)
                            notif(b.baseLbl..": "..disp,nil,2)
                        end
                        if not clicking then b.dragging=false end
                        if b.dragging and clicking then
                            local frac=clamp((mouse.X-ax)/b.trackW,0,1)
                            b.value=b.minV+frac*(b.maxV-b.minV)
                            local disp=b.isFloat and string.format("%.2f",b.value) or tostring(math.floor(b.value))
                            b.lbl.Text=b.baseLbl
                            if b.valLbl then b.valLbl.Text=disp end
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
                    if inBox(uiX,uiY,L.W,uiCurrentH) then
                        dragging=true; dragOffX=mouse.X-uiX; dragOffY=mouse.Y-uiY
                    end
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
                if charLabelFn and dFooterRight then
                    local nt=charLabelFn()
                    if nt and nt~="" then
                        dFooterRight.Text=nt
                        local rX=uiX+L.W-14-(#nt*6); local tY=uiY+uiCurrentH-L.FOOTER+7
                        dFooterRight.Position=Vector2.new(rX,tY); dFooterRight.Visible=menuOpen
                    end
                end
            end
        end
        end)
    end

    ----------------------------------------------------------------
    -- Destroy
    ----------------------------------------------------------------
    function win:Destroy()
        destroyed=true
        pcall(function() setrobloxinput(true) end)
        for _,d in ipairs(allDrawings) do pcall(function() d:Remove() end) end
        for _,d in ipairs(miniDrawings) do pcall(function() d:Remove() end) end
        for _,l in ipairs(miniActiveLbls) do pcall(function() l:Remove() end) end
    end

    function win:ApplyTheme(name)
        if THEMES[name] then
            for k,v in pairs(THEMES[name]) do C[k]=v end
        end
    end
    UILib.applyTheme = function(name)
        if THEMES[name] then
            for k,v in pairs(THEMES[name]) do C[k]=v end
        end
    end

    return win
end

print("[UILib] v2.0.0 loaded")
_G.UILib = UILib
return UILib
