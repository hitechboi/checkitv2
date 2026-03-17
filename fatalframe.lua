local _f={}
local _tk=tick or os.clock
local _c={
    bg=Color3.fromRGB(10,7,8),tb=Color3.fromRGB(8,5,6),
    ct=Color3.fromRGB(14,10,11),rw=Color3.fromRGB(14,8,8),
    rh=Color3.fromRGB(18,10,10),sb=Color3.fromRGB(18,10,12),
    bd=Color3.fromRGB(42,16,21),ac=Color3.fromRGB(122,30,44),
    ab=Color3.fromRGB(200,72,90),tx=Color3.fromRGB(200,184,184),
    dm=Color3.fromRGB(74,48,48),mt=Color3.fromRGB(48,28,28),
    to=Color3.fromRGB(90,21,32),tf=Color3.fromRGB(26,13,13),
    do_=Color3.fromRGB(200,72,90),df=Color3.fromRGB(58,31,31),
    ft=Color3.fromRGB(8,5,6),ta=Color3.fromRGB(200,184,184),
    ti=Color3.fromRGB(74,48,48),db=Color3.fromRGB(12,8,9),
    dp=Color3.fromRGB(16,10,11),ds=Color3.fromRGB(200,72,90),
    lh=Color3.fromRGB(122,30,44),ld=Color3.fromRGB(58,38,38),
}
local _l={w=580,th=34,bh=28,fh=30,rh=36,sh=24,slh=36,pd=14,ch=360,tw=30,toh=14,dr=5}
_l.h=_l.th+_l.bh+_l.ch+_l.fh
local _fn=Drawing.Fonts.Monospace
local _fs=12
local _fsm=10
local function _cl(v,a,b) return math.max(a,math.min(b,v)) end
local function _ln(a,b,t) return a+(b-a)*t end
local function _lc(a,b,t)
    return Color3.fromRGB(
        math.floor(a.R*255+(b.R*255-a.R*255)*t),
        math.floor(a.G*255+(b.G*255-a.G*255)*t),
        math.floor(a.B*255+(b.B*255-a.B*255)*t))
end
local function _vp()
    local ok,v=pcall(function() return workspace.CurrentCamera.ViewportSize end)
    if ok and v then return v.X,v.Y end
    return 1920,1080
end
local function _tw(s,a,b,d,e)
    e=e or function(t) return t end
    task.spawn(function()
        local t0=_tk()
        while true do
            local t=_cl((_tk()-t0)/d,0,1)
            s(_ln(a,b,e(t)))
            if t>=1 then break end
            task.wait(0.016)
        end
        s(b)
    end)
end
local function _twc(s,a,b,d)
    task.spawn(function()
        local t0=_tk()
        while true do
            local t=_cl((_tk()-t0)/d,0,1)
            s(_lc(a,b,t))
            if t>=1 then break end
            task.wait(0.016)
        end
        s(b)
    end)
end
local function _eo(t) return 1-(1-t)^3 end
local function _sq(x,y,w,h,col,fi,zi,tr)
    local s=Drawing.new("Square")
    s.Position=Vector2.new(x,y);s.Size=Vector2.new(w,h)
    s.Color=col;s.Filled=fi~=false;s.Transparency=tr or 1
    s.ZIndex=zi or 1;s.Visible=true;return s
end
local function _ln2(x1,y1,x2,y2,col,zi,th,tr)
    local l=Drawing.new("Line")
    l.From=Vector2.new(x1,y1);l.To=Vector2.new(x2,y2)
    l.Color=col;l.Thickness=th or 1;l.Transparency=tr or 1
    l.ZIndex=zi or 2;l.Visible=true;return l
end
local function _tx2(t,x,y,sz,col,zi,ce,bo,tr)
    local d=Drawing.new("Text")
    d.Text=t;d.Position=Vector2.new(x,y);d.Size=sz or _fs
    d.Color=col or _c.tx;d.Font=bo and Drawing.Fonts.SystemBold or _fn
    d.Center=ce or false;d.Outline=false;d.Transparency=tr or 1
    d.ZIndex=zi or 3;d.Visible=true;return d
end
local function _ci(x,y,r,col,fi,zi,tr)
    local c=Drawing.new("Circle")
    c.Position=Vector2.new(x,y);c.Radius=r;c.Color=col
    c.Filled=fi~=false;c.NumSides=32;c.Thickness=1
    c.Transparency=tr or 1;c.ZIndex=zi or 2;c.Visible=true;return c
end
local _kn={}
for i=0x41,0x5A do _kn[i]=string.char(i) end
for i=0x30,0x39 do _kn[i]=tostring(i-0x30) end
_kn[0x70]="F1";_kn[0x71]="F2";_kn[0x72]="F3";_kn[0x73]="F4"
_kn[0x74]="F5";_kn[0x75]="F6";_kn[0x76]="F7";_kn[0x77]="F8"
_kn[0x78]="F9";_kn[0x79]="F10";_kn[0x7A]="F11";_kn[0x7B]="F12"
_kn[0x20]="Space";_kn[0x1B]="Esc";_kn[0x0D]="Enter"
_kn[0x08]="Back";_kn[0x09]="Tab"
local function _kname(k) return _kn[k] or ("key"..k) end
function _f.Window(ta,tb,gn)
    local win={}
    local mouse=game.Players.LocalPlayer:GetMouse()
    local vpw,vph=_vp()
    local ux=math.floor((vpw-_l.w)/2)
    local uy=math.floor((vph-_l.h)/2)
    local drag=false;local dox=0;local doy=0
    local wc2=false;local mopen=true;local mkey=0x70
    local lkey=false;local dest=false;local ctab=nil
    local alld={};local tobjs={};local btns={}
    local trows={};local tscroll={};local opdd=nil
    local _sd=0;local clfn=nil;local iklbl=nil;local tabmap={}
    pcall(function()
        mouse.WheelForward:Connect(function() _sd=_sd-1 end)
        mouse.WheelBackward:Connect(function() _sd=_sd+1 end)
    end)
    local function mkd(d) table.insert(alld,d);return d end
    local function ch() return _l.ch end
    local function fh() return _l.th+_l.bh+ch()+_l.fh end
    local dbg=mkd(_sq(ux,uy,_l.w,fh(),_c.bg,true,1))
    local dbrd=mkd(_sq(ux,uy,_l.w,fh(),_c.bd,false,2))
    local dtb=mkd(_sq(ux,uy,_l.w,_l.th,_c.tb,true,2))
    local dtbl=mkd(_ln2(ux,uy+_l.th,ux+_l.w,uy+_l.th,_c.bd,3,1))
    local dta=mkd(_tx2(ta,ux+_l.pd,uy+_l.th/2-6,13,_c.tx,4))
    local dtb2=mkd(_tx2(tb and (" "..tb) or "",ux+_l.pd+#ta*7+4,uy+_l.th/2-6,_fsm,_c.dm,4))
    local dgn=mkd(_tx2(gn or "",ux+_l.pd+#ta*7+4+(tb and (#tb*6+8) or 0),uy+_l.th/2-6,_fsm,_c.ac,4))
    local dodt=mkd(_ci(ux+_l.w-28,uy+_l.th/2,3,_c.ac,true,4))
    local dotx=mkd(_tx2("online",ux+_l.w-22,uy+_l.th/2-5,_fsm,_c.mt,4))
    local dkl=mkd(_tx2("f1",ux+_l.w-56,uy+_l.th/2-5,_fsm,_c.mt,4))
    local dbb=mkd(_sq(ux,uy+_l.th,_l.w,_l.bh,_c.tb,true,2))
    local dbbl=mkd(_ln2(ux,uy+_l.th+_l.bh,ux+_l.w,uy+_l.th+_l.bh,_c.bd,3,1))
    local dct=mkd(_sq(ux,uy+_l.th+_l.bh,_l.w,ch(),_c.bg,true,1))
    local dft=mkd(_sq(ux,uy+fh()-_l.fh,_l.w,_l.fh,_c.tb,true,2))
    local dftl=mkd(_ln2(ux,uy+fh()-_l.fh,ux+_l.w,uy+fh()-_l.fh,_c.bd,3,1))
    local dwl=mkd(_tx2("welcome,",ux+_l.pd,uy+fh()-_l.fh+9,_fsm,_c.dm,4))
    local dun=mkd(_tx2("",ux+_l.pd+54,uy+fh()-_l.fh+9,_fsm,_c.ac,4))
    local dcl=mkd(_tx2("",ux+_l.w-_l.pd-160,uy+fh()-_l.fh+9,_fsm,_c.mt,4))
    pcall(function() dun.Text=game.Players.LocalPlayer.Name end)
    local dscb=mkd(_sq(ux+_l.w-5,uy+_l.th+_l.bh+2,3,ch()-4,_c.bd,true,5))
    local dsct=mkd(_sq(ux+_l.w-5,uy+_l.th+_l.bh+2,3,20,_c.ac,true,6))
    dscb.Visible=false;dsct.Visible=false
    local tabx=ux+_l.pd
    local function updpos()
        dbg.Position=Vector2.new(ux,uy);dbg.Size=Vector2.new(_l.w,fh())
        dbrd.Position=Vector2.new(ux,uy);dbrd.Size=Vector2.new(_l.w,fh())
        dtb.Position=Vector2.new(ux,uy)
        dtbl.From=Vector2.new(ux,uy+_l.th);dtbl.To=Vector2.new(ux+_l.w,uy+_l.th)
        dta.Position=Vector2.new(ux+_l.pd,uy+_l.th/2-6)
        dtb2.Position=Vector2.new(ux+_l.pd+#ta*7+4,uy+_l.th/2-6)
        dgn.Position=Vector2.new(ux+_l.pd+#ta*7+4+(tb and (#tb*6+8) or 0),uy+_l.th/2-6)
        dodt.Position=Vector2.new(ux+_l.w-28,uy+_l.th/2)
        dotx.Position=Vector2.new(ux+_l.w-22,uy+_l.th/2-5)
        dkl.Position=Vector2.new(ux+_l.w-56,uy+_l.th/2-5)
        dbb.Position=Vector2.new(ux,uy+_l.th)
        dbbl.From=Vector2.new(ux,uy+_l.th+_l.bh);dbbl.To=Vector2.new(ux+_l.w,uy+_l.th+_l.bh)
        dct.Position=Vector2.new(ux,uy+_l.th+_l.bh);dct.Size=Vector2.new(_l.w,ch())
        dft.Position=Vector2.new(ux,uy+fh()-_l.fh)
        dftl.From=Vector2.new(ux,uy+fh()-_l.fh);dftl.To=Vector2.new(ux+_l.w,uy+fh()-_l.fh)
        dwl.Position=Vector2.new(ux+_l.pd,uy+fh()-_l.fh+9)
        dun.Position=Vector2.new(ux+_l.pd+54,uy+fh()-_l.fh+9)
        dcl.Position=Vector2.new(ux+_l.w-_l.pd-160,uy+fh()-_l.fh+9)
        dscb.Position=Vector2.new(ux+_l.w-5,uy+_l.th+_l.bh+2)
        dscb.Size=Vector2.new(3,ch()-4)
        for _,t in ipairs(tobjs) do if t.repos then t:repos() end end
        for _,b in ipairs(btns) do if b.tab==ctab and b.reposition then b:reposition() end end
    end
    local function switchtab(name)
        if name==ctab then return end
        ctab=name;tscroll[name]=tscroll[name] or 0
        for _,t in ipairs(tobjs) do
            t.active=t.name==name
            if t.recolor then t:recolor() end
        end
        for _,b in ipairs(btns) do
            local show=b.tab==name;b.visible=show
            if b.setOpacity then b:setOpacity(show and 1 or 0) end
            if show and b.reposition then b:reposition() end
        end
    end
    local function gettab(name)
        if tabmap[name] then return tabmap[name] end
        local tw2=60
        local tl=mkd(_ln2(tabx,uy+_l.th+_l.bh-1,tabx+tw2,uy+_l.th+_l.bh-1,_c.ac,4,2))
        local tlbl=mkd(_tx2(string.lower(name),tabx+tw2/2,uy+_l.th+_l.bh/2-5,_fsm,_c.ti,5,true))
        tl.Visible=false
        local tobj={name=name,active=false,lbl=tlbl,line=tl,w=tw2,x=tabx}
        function tobj:recolor()
            self.lbl.Color=self.active and _c.ta or _c.ti
            self.line.Visible=self.active
        end
        function tobj:repos() end
        tabx=tabx+tw2+2
        table.insert(tobjs,tobj)
        tscroll[name]=0;trows[name]=0
        local cly={uy+_l.th+_l.bh};local cry={uy+_l.th+_l.bh}
        local two=false;local csp=math.floor(_l.w/2)
        local api={}
        local function ny(col) return two and col=="R" and cry[1] or cly[1] end
        local function ay(col,h)
            if two then if col=="R" then cry[1]=cry[1]+h else cly[1]=cly[1]+h end
            else cly[1]=cly[1]+h end
            trows[name]=(trows[name] or 0)+h
        end
        local function rx(col) return two and col=="R" and ux+csp or ux end
        local function rw(col) return two and csp or _l.w end
        function api:TwoColumn()
            two=true
            local dl=mkd(_ln2(ux+csp,uy+_l.th+_l.bh,ux+csp,uy+_l.th+_l.bh+ch(),_c.bd,3,1))
            dl.Visible=name==ctab
            local b={tab=name,visible=name==ctab}
            b.setOpacity=function(self,op) dl.Visible=op>0.5 and self.visible end
            b.reposition=function(self)
                dl.From=Vector2.new(ux+csp,uy+_l.th+_l.bh)
                dl.To=Vector2.new(ux+csp,uy+_l.th+_l.bh+ch())
            end
            table.insert(btns,b)
        end
        function api:Div(label,col)
            col=col or "L";local ry=ny(col);local rw2=rw(col);local rx2=rx(col)
            local bg=mkd(_sq(rx2,ry,rw2,_l.sh,_c.sb,true,3))
            local lb=mkd(_tx2(string.lower(label or ""),rx2+_l.pd,ry+_l.sh/2-5,_fsm,_c.ac,5))
            local bl=mkd(_ln2(rx2,ry+_l.sh,rx2+rw2,ry+_l.sh,_c.bd,4,1))
            ay(col,_l.sh)
            local b={tab=name,visible=name==ctab,_d={bg,lb,bl}}
            b.setOpacity=function(self,op)
                for _,d in ipairs(self._d) do d.Visible=op>0.5 and self.visible end
            end
            b.reposition=function(self)
                local sc=tscroll[name] or 0;local a=ry-sc
                bg.Position=Vector2.new(rx2,a);lb.Position=Vector2.new(rx2+_l.pd,a+_l.sh/2-5)
                bl.From=Vector2.new(rx2,a+_l.sh);bl.To=Vector2.new(rx2+rw2,a+_l.sh)
                local iv=a>=uy+_l.th+_l.bh-2 and a<uy+_l.th+_l.bh+ch()
                for _,d in ipairs(self._d) do d.Visible=self.visible and iv end
            end
            b:setOpacity(b.visible and 1 or 0);table.insert(btns,b)
        end
        function api:Toggle(label,default,callback,tip,col)
            col=col or "L";local ry=ny(col);local rw2=rw(col);local rx2=rx(col)
            local state=default or false
            local bg=mkd(_sq(rx2,ry,rw2,_l.rh,_c.rw,true,3))
            local lb=mkd(_tx2(string.lower(label),rx2+_l.pd,ry+_l.rh/2-6,_fs,_c.tx,5))
            local bl=mkd(_ln2(rx2,ry+_l.rh,rx2+rw2,ry+_l.rh,_c.bd,4,1))
            local tox=rx2+rw2-_l.pd-_l.tw;local toy=ry+_l.rh/2-_l.toh/2
            local tobg=mkd(_sq(tox,toy,_l.tw,_l.toh,state and _c.to or _c.tf,true,5))
            local dx=state and tox+_l.tw-_l.toh/2-1 or tox+_l.toh/2+1
            local dot=mkd(_ci(dx,toy+_l.toh/2,_l.dr,state and _c.do_ or _c.df,true,6))
            ay(col,_l.rh)
            local b={tab=name,visible=name==ctab,state=state,_d={bg,lb,bl,tobg,dot}}
            function b:setState(s)
                self.state=s;tobg.Color=s and _c.to or _c.tf
                local tx3=s and tox+_l.tw-_l.toh/2-1 or tox+_l.toh/2+1
                _tw(function(v) dot.Position=Vector2.new(v,dot.Position.Y) end,dot.Position.X,tx3,0.12,_eo)
                _twc(function(c) dot.Color=c end,dot.Color,s and _c.do_ or _c.df,0.12)
                if callback then pcall(callback,s) end
            end
            b.setOpacity=function(self,op)
                for _,d in ipairs(self._d) do d.Visible=op>0.5 and self.visible end
            end
            b.reposition=function(self)
                local sc=tscroll[name] or 0;local a=ry-sc
                local ty2=a+_l.rh/2-_l.toh/2;local tx4=rx2+rw2-_l.pd-_l.tw
                bg.Position=Vector2.new(rx2,a);lb.Position=Vector2.new(rx2+_l.pd,a+_l.rh/2-6)
                bl.From=Vector2.new(rx2,a+_l.rh);bl.To=Vector2.new(rx2+rw2,a+_l.rh)
                tobg.Position=Vector2.new(tx4,ty2)
                dot.Position=Vector2.new(self.state and tx4+_l.tw-_l.toh/2-1 or tx4+_l.toh/2+1,ty2+_l.toh/2)
                local iv=a>=uy+_l.th+_l.bh-2 and a<uy+_l.th+_l.bh+ch()
                for _,d in ipairs(self._d) do d.Visible=self.visible and iv end
            end
            b._click=function(mx,my)
                local sc=tscroll[name] or 0;local a=ry-sc
                if mx>=rx2 and mx<=rx2+rw2 and my>=a and my<=a+_l.rh then
                    if mx>=rx2+rw2-_l.pd-_l.tw-8 then b:setState(not b.state) end
                end
            end
            b._hover=function(mx,my)
                local sc=tscroll[name] or 0;local a=ry-sc
                bg.Color=(mx>=rx2 and mx<=rx2+rw2 and my>=a and my<=a+_l.rh) and _c.rh or _c.rw
            end
            b:setOpacity(b.visible and 1 or 0);table.insert(btns,b);return b
        end
        function api:Slider(label,minv,maxv,default,callback,isf,hint,col)
            col=col or "L";local ry=ny(col);local rw2=rw(col);local rx2=rx(col)
            local value=default or minv
            local trw=rw2-_l.pd*2;local trx=rx2+_l.pd;local try=ry+_l.slh-10
            local bg=mkd(_sq(rx2,ry,rw2,_l.slh,_c.rw,true,3))
            local fr=(value-minv)/(maxv-minv)
            local lb=mkd(_tx2(string.lower(label)..": "..(isf and string.format("%.2f",value) or tostring(math.floor(value))),rx2+_l.pd,ry+8,_fs,_c.tx,5))
            local bl=mkd(_ln2(rx2,ry+_l.slh,rx2+rw2,ry+_l.slh,_c.bd,4,1))
            local tr=mkd(_ln2(trx,try,trx+trw,try,_c.ac,5,1))
            local hdl=mkd(_ci(trx+fr*trw,try,4,_c.ac,true,6))
            ay(col,_l.slh)
            local b={tab=name,visible=name==ctab,value=value,dragging=false,_d={bg,lb,bl,tr,hdl}}
            b.setOpacity=function(self,op)
                for _,d in ipairs(self._d) do d.Visible=op>0.5 and self.visible end
            end
            b.reposition=function(self)
                local sc=tscroll[name] or 0;local a=ry-sc
                local ty2=a+_l.slh-10;local tx2=rx2+_l.pd
                bg.Position=Vector2.new(rx2,a);lb.Position=Vector2.new(rx2+_l.pd,a+8)
                bl.From=Vector2.new(rx2,a+_l.slh);bl.To=Vector2.new(rx2+rw2,a+_l.slh)
                tr.From=Vector2.new(tx2,ty2);tr.To=Vector2.new(tx2+trw,ty2)
                local f=(self.value-minv)/(maxv-minv)
                hdl.Position=Vector2.new(tx2+f*trw,ty2)
                local iv=a>=uy+_l.th+_l.bh-2 and a<uy+_l.th+_l.bh+ch()
                for _,d in ipairs(self._d) do d.Visible=self.visible and iv end
            end
            b._drag=function(mx,my,clk)
                local sc=tscroll[name] or 0;local a=ry-sc
                local ty2=a+_l.slh-10;local tx2=rx2+_l.pd
                if not clk then b.dragging=false;return end
                if not b.dragging then
                    if mx>=tx2-8 and mx<=tx2+trw+8 and my>=ty2-8 and my<=ty2+8 then b.dragging=true end
                end
                if b.dragging then
                    local f=_cl((mx-tx2)/trw,0,1)
                    local raw=minv+f*(maxv-minv)
                    b.value=isf and math.floor(raw*100+0.5)/100 or math.floor(raw+0.5)
                    hdl.Position=Vector2.new(tx2+f*trw,ty2)
                    lb.Text=string.lower(label)..": "..(isf and string.format("%.2f",b.value) or tostring(math.floor(b.value)))
                    if callback then pcall(callback,b.value) end
                end
            end
            b:setOpacity(b.visible and 1 or 0);table.insert(btns,b);return b
        end
        function api:Button(label,bgcol,callback,txcol,col)
            col=col or "L";local ry=ny(col);local rw2=rw(col);local rx2=rx(col)
            local bg=mkd(_sq(rx2,ry,rw2,_l.rh,bgcol or _c.rw,true,3))
            local lb=mkd(_tx2(string.lower(label),rx2+rw2/2,ry+_l.rh/2-6,_fs,txcol or _c.tx,5,true))
            local bl=mkd(_ln2(rx2,ry+_l.rh,rx2+rw2,ry+_l.rh,_c.bd,4,1))
            ay(col,_l.rh)
            local b={tab=name,visible=name==ctab,_bc=bgcol or _c.rw,_d={bg,lb,bl}}
            b.setOpacity=function(self,op)
                for _,d in ipairs(self._d) do d.Visible=op>0.5 and self.visible end
            end
            b.reposition=function(self)
                local sc=tscroll[name] or 0;local a=ry-sc
                bg.Position=Vector2.new(rx2,a);lb.Position=Vector2.new(rx2+rw2/2,a+_l.rh/2-6)
                bl.From=Vector2.new(rx2,a+_l.rh);bl.To=Vector2.new(rx2+rw2,a+_l.rh)
                local iv=a>=uy+_l.th+_l.bh-2 and a<uy+_l.th+_l.bh+ch()
                for _,d in ipairs(self._d) do d.Visible=self.visible and iv end
            end
            b._click=function(mx,my)
                local sc=tscroll[name] or 0;local a=ry-sc
                if mx>=rx2 and mx<=rx2+rw2 and my>=a and my<=a+_l.rh then
                    if callback then pcall(callback) end
                end
            end
            b._hover=function(mx,my)
                local sc=tscroll[name] or 0;local a=ry-sc
                bg.Color=(mx>=rx2 and mx<=rx2+rw2 and my>=a and my<=a+_l.rh) and _c.rh or b._bc
            end
            b:setOpacity(b.visible and 1 or 0);table.insert(btns,b);return b
        end
        function api:Dropdown(label,opts,defidx,callback,col)
            col=col or "L";local ry=ny(col);local rw2=rw(col);local rx2=rx(col)
            local sidx=defidx or 1;local sval=opts[sidx] or "";local open=false;local oph=_l.rh
            local bg=mkd(_sq(rx2,ry,rw2,_l.rh,_c.rw,true,3))
            local lb=mkd(_tx2(string.lower(label),rx2+_l.pd,ry+_l.rh/2-6,_fs,_c.tx,5))
            local vl=mkd(_tx2(string.lower(sval),rx2+rw2-_l.pd-#sval*6,ry+_l.rh/2-6,_fs,_c.ac,5))
            local al=mkd(_tx2("v",rx2+rw2-_l.pd,ry+_l.rh/2-6,_fsm,_c.dm,5))
            local bl=mkd(_ln2(rx2,ry+_l.rh,rx2+rw2,ry+_l.rh,_c.bd,4,1))
            ay(col,_l.rh)
            local oo={}
            for i,opt in ipairs(opts) do
                local oy=ry+_l.rh+(i-1)*oph
                local obg=mkd(_sq(rx2,oy,rw2,oph,i==sidx and _c.rh or _c.dp,true,6))
                local olb=mkd(_tx2(string.lower(opt),rx2+_l.pd+8,oy+oph/2-6,_fs,i==sidx and _c.ds or _c.dm,7))
                local oln=mkd(_ln2(rx2,oy+oph,rx2+rw2,oy+oph,_c.bd,7,1))
                obg.Visible=false;olb.Visible=false;oln.Visible=false
                table.insert(oo,{bg=obg,lbl=olb,line=oln,val=opt,idx=i})
            end
            local ph=#opts*oph
            local pbg=mkd(_sq(rx2,ry+_l.rh,rw2,ph,_c.db,true,5))
            local pbd=mkd(_sq(rx2,ry+_l.rh,rw2,ph,_c.bd,false,6))
            pbg.Visible=false;pbd.Visible=false
            local function showoo(s)
                open=s;al.Text=s and "^" or "v"
                pbg.Visible=s and name==ctab;pbd.Visible=s and name==ctab
                for _,o in ipairs(oo) do
                    o.bg.Visible=s and name==ctab
                    o.lbl.Visible=s and name==ctab
                    o.line.Visible=s and name==ctab
                end
            end
            local b={tab=name,visible=name==ctab,_d={bg,lb,vl,al,bl,pbg,pbd},_oo=oo}
            function b:SetOptions(newopts)
                opts=newopts
                for _,o in ipairs(oo) do o.bg.Visible=false;o.lbl.Visible=false;o.line.Visible=false end
                oo={}
                for i,opt in ipairs(newopts) do
                    local oy=ry+_l.rh+(i-1)*oph
                    local obg=mkd(_sq(rx2,oy,rw2,oph,_c.dp,true,6))
                    local olb=mkd(_tx2(string.lower(opt),rx2+_l.pd+8,oy+oph/2-6,_fs,i==sidx and _c.ds or _c.dm,7))
                    local oln=mkd(_ln2(rx2,oy+oph,rx2+rw2,oy+oph,_c.bd,7,1))
                    obg.Visible=false;olb.Visible=false;oln.Visible=false
                    table.insert(oo,{bg=obg,lbl=olb,line=oln,val=opt,idx=i})
                end
                b._oo=oo;pbg.Size=Vector2.new(rw2,#newopts*oph);pbd.Size=Vector2.new(rw2,#newopts*oph)
                if open then showoo(false) end
            end
            b.setOpacity=function(self,op)
                local s=op>0.5 and self.visible
                for _,d in ipairs(self._d) do d.Visible=s end
                if not s then showoo(false) end
            end
            b.reposition=function(self)
                local sc=tscroll[name] or 0;local a=ry-sc
                bg.Position=Vector2.new(rx2,a);lb.Position=Vector2.new(rx2+_l.pd,a+_l.rh/2-6)
                vl.Position=Vector2.new(rx2+rw2-_l.pd-#string.lower(sval)*6,a+_l.rh/2-6)
                al.Position=Vector2.new(rx2+rw2-_l.pd,a+_l.rh/2-6)
                bl.From=Vector2.new(rx2,a+_l.rh);bl.To=Vector2.new(rx2+rw2,a+_l.rh)
                pbg.Position=Vector2.new(rx2,a+_l.rh);pbd.Position=Vector2.new(rx2,a+_l.rh)
                for i,o in ipairs(oo) do
                    local oy=a+_l.rh+(i-1)*oph
                    o.bg.Position=Vector2.new(rx2,oy);o.lbl.Position=Vector2.new(rx2+_l.pd+8,oy+oph/2-6)
                    o.line.From=Vector2.new(rx2,oy+oph);o.line.To=Vector2.new(rx2+rw2,oy+oph)
                end
                local iv=a>=uy+_l.th+_l.bh-2 and a<uy+_l.th+_l.bh+ch()
                for _,d in ipairs(self._d) do d.Visible=self.visible and iv end
                if open then
                    pbg.Visible=self.visible;pbd.Visible=self.visible
                    for _,o in ipairs(oo) do
                        o.bg.Visible=self.visible;o.lbl.Visible=self.visible;o.line.Visible=self.visible
                    end
                end
            end
            b._click=function(mx,my)
                if not b.visible then return end
                local sc=tscroll[name] or 0;local a=ry-sc
                if mx>=rx2 and mx<=rx2+rw2 and my>=a and my<=a+_l.rh then
                    if open then showoo(false)
                    else
                        if opdd and opdd~=b then pcall(function() opdd:_closeDD() end) end
                        showoo(true);opdd=b
                    end
                    return
                end
                if open then
                    for _,o in ipairs(oo) do
                        local oy=a+_l.rh+(o.idx-1)*oph
                        if mx>=rx2 and mx<=rx2+rw2 and my>=oy and my<=oy+oph then
                            sidx=o.idx;sval=o.val;vl.Text=string.lower(sval)
                            for _,o2 in ipairs(oo) do
                                o2.lbl.Color=o2.idx==sidx and _c.ds or _c.dm
                                o2.bg.Color=o2.idx==sidx and _c.rh or _c.dp
                            end
                            showoo(false);opdd=nil
                            if callback then pcall(callback,sval,sidx) end
                            return
                        end
                    end
                    showoo(false);opdd=nil
                end
            end
            b._closeDD=function(self) showoo(false);opdd=nil end
            b:setOpacity(b.visible and 1 or 0);table.insert(btns,b);return b
        end
        function api:Log(entries,col)
            col=col or "L"
            for _,entry in ipairs(entries) do
                local ry2=ny(col);local rw2=rw(col);local rx2=rx(col)
                local hl=entry:sub(1,1)==">"
                local bg=mkd(_sq(rx2,ry2,rw2,_l.rh,_c.rw,true,3))
                local lb=mkd(_tx2(string.lower(entry),rx2+_l.pd,ry2+_l.rh/2-6,_fsm,hl and _c.lh or _c.ld,5))
                local bl=mkd(_ln2(rx2,ry2+_l.rh,rx2+rw2,ry2+_l.rh,_c.bd,4,1))
                ay(col,_l.rh)
                local b={tab=name,visible=name==ctab,_d={bg,lb,bl}}
                b.setOpacity=function(self,op)
                    for _,d in ipairs(self._d) do d.Visible=op>0.5 and self.visible end
                end
                b.reposition=function(self)
                    local sc=tscroll[name] or 0;local a=ry2-sc
                    bg.Position=Vector2.new(rx2,a);lb.Position=Vector2.new(rx2+_l.pd,a+_l.rh/2-6)
                    bl.From=Vector2.new(rx2,a+_l.rh);bl.To=Vector2.new(rx2+rw2,a+_l.rh)
                    local iv=a>=uy+_l.th+_l.bh-2 and a<uy+_l.th+_l.bh+ch()
                    for _,d in ipairs(self._d) do d.Visible=self.visible and iv end
                end
                b:setOpacity(b.visible and 1 or 0);table.insert(btns,b)
            end
        end
        tabmap[name]=api;return api
    end
    function win:Tab(name) return gettab(name) end
    function win:SettingsTab(dcb)
        local s=self:Tab("settings")
        s:Div("ui")
        s:Dropdown("theme",{"fatal frame","check it","moon","grass","light","dark"},1,function() end)
        s:Div("keybind")
        iklbl=s:Button("menu key: f1",_c.rw,nil,_c.dm)
        s:Button("click to rebind",_c.rw,function() lkey=true end,_c.dm)
        s:Div("danger")
        s:Button("destroy menu",_c.rw,function() if dcb then pcall(dcb) end end,_c.ac)
        return s
    end
    function win:Init(dtab,cfn)
        clfn=cfn
        if dtab and tabmap[dtab] then switchtab(dtab)
        elseif #tobjs>0 then switchtab(tobjs[1].name) end
        updpos()
    end
    function win:SetActiveCount(n) dotx.Text="online: "..tostring(n) end
    function win:Destroy()
        dest=true
        for _,d in ipairs(alld) do pcall(function() d:Remove() end) end
    end
    task.spawn(function()
        while not dest do
            task.wait(0.016)
            if not mopen then
                for _,d in ipairs(alld) do d.Visible=false end
                goto cont
            end
            local mx=mouse.X;local my=mouse.Y
            local clk=false
            pcall(function() clk=ismouse1pressed() end)
            local jclk=clk and not wc2
            if clfn then pcall(function() dcl.Text=clfn() end) end
            if lkey then
                for k=0x08,0xDD do
                    local p=false
                    pcall(function() p=iskeypressed(k) end)
                    if p and k~=0x01 and k~=0x02 then
                        mkey=k;dkl.Text=string.lower(_kname(k))
                        if iklbl then iklbl._d[2].Text="menu key: "..string.lower(_kname(k)) end
                        lkey=false;break
                    end
                end
            end
            local mkp=false
            pcall(function() mkp=iskeypressed(mkey) end)
            if mkp and not lkey then
                mopen=not mopen;task.wait(0.15)
                if not mopen then
                    for _,d in ipairs(alld) do d.Visible=false end
                else
                    updpos()
                    for _,b in ipairs(btns) do
                        if b.tab==ctab and b.reposition then b:reposition() end
                    end
                end
                goto cont
            end
            if jclk then
                local itb=mx>=ux and mx<=ux+_l.w and my>=uy+_l.th and my<=uy+_l.th+_l.bh
                if itb then
                    local ht=false
                    for _,t in ipairs(tobjs) do
                        if mx>=t.x and mx<=t.x+t.w and my>=uy+_l.th and my<=uy+_l.th+_l.bh then
                            switchtab(t.name);ht=true;break
                        end
                    end
                    if not ht then drag=true;dox=mx-ux;doy=my-uy end
                elseif my>=uy and my<=uy+_l.th then
                    drag=true;dox=mx-ux;doy=my-uy
                end
                if my>=uy+_l.th+_l.bh and my<uy+fh()-_l.fh then
                    for _,b in ipairs(btns) do
                        if b.tab==ctab and b._click then pcall(b._click,b,mx,my) end
                    end
                end
            end
            if not clk then drag=false end
            if drag and clk then
                local vw2,vh2=_vp()
                ux=_cl(mx-dox,0,vw2-_l.w);uy=_cl(my-doy,0,vh2-fh());updpos()
            end
            for _,b in ipairs(btns) do
                if b.tab==ctab then
                    if b._hover then pcall(b._hover,b,mx,my) end
                    if b._drag and clk then pcall(b._drag,b,mx,my,clk) end
                end
            end
            if _sd~=0 and my>=uy+_l.th+_l.bh and my<uy+fh()-_l.fh then
                local msc=math.max(0,(trows[ctab] or 0)-ch()+8)
                tscroll[ctab]=_cl((tscroll[ctab] or 0)+_sd*18,0,msc);_sd=0
                for _,b in ipairs(btns) do
                    if b.tab==ctab and b.reposition then b:reposition() end
                end
                local msc2=math.max(0,(trows[ctab] or 0)-ch()+8)
                if msc2>0 then
                    dscb.Visible=true;dsct.Visible=true
                    local sbh=ch()-4;local fr=(tscroll[ctab] or 0)/msc2
                    local th2=math.max(20,(ch()/(trows[ctab] or ch()))*sbh)
                    dsct.Size=Vector2.new(3,th2)
                    dsct.Position=Vector2.new(ux+_l.w-5,uy+_l.th+_l.bh+2+fr*(sbh-th2))
                else dscb.Visible=false;dsct.Visible=false end
            end
            wc2=clk
            ::cont::
        end
    end)
    return win
end
_f.Colors={
    ACCENT=Color3.fromRGB(122,30,44),ACCENT_BR=Color3.fromRGB(200,72,90),
    TEXT=Color3.fromRGB(200,184,184),DIM=Color3.fromRGB(74,48,48),
    ROW=Color3.fromRGB(14,8,8),ROWBG=Color3.fromRGB(14,8,8),
    WHITE=Color3.fromRGB(200,184,184),GRAY=Color3.fromRGB(74,48,48),
    BG=Color3.fromRGB(10,7,8),BORDER=Color3.fromRGB(42,16,21),
}
_G.FatalUI=_f
return _f
