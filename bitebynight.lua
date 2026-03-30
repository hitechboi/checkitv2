local _l;do local _o,_r=pcall(function()return loadstring(game:HttpGet("https://raw.githubusercontent.com/hitechboi/checkitv2/refs/heads/main/imjussayin.lua".."?cache="..tostring(os.time())))()end);if _o and _r then _l=_r elseif _G.lib then _l=_G.lib else pcall(function()notify("Bite By Night","Failed to load UI library",5)end)return end end
local _p=game.Players.LocalPlayer
local _w=_l:Window("Bite","By Night")
pcall(function()if _w.SetGameName then _w:SetGameName(type(getgamename)=="function"and getgamename()or"Bite By Night")end end)
pcall(function()if _w.AddMainScriptLog then _w:AddMainScriptLog("v1.1",os.date("%Y-%m-%d"),{"health bar color opaque green","Added Recticles"})end end)
local _cv=nil
pcall(function()local s=game:HttpGet("https://raw.githubusercontent.com/hitechboi/checkitv2/refs/heads/main/ChildVm.lua?t="..tostring(os.time()));if s and #s>100 then loadstring(s)()end end)
local _vm=nil
if _G.ChildVm then _cv=_G.ChildVm;_vm=_cv.new({PollRate=0.2})end
local _rs={}
do
local _b,_a,_lt,_sc,_sn,_em,_ec={},true,os.clock(),{},0,10,0
local function _sig()
local s={c={}}
function s:Connect(f)local cn={f=f,o=true};table.insert(s.c,cn);return{Disconnect=function()cn.o=false;cn.f=nil end}end
function s:Fire(...)local i=1;while i<=#s.c do local cn=s.c[i];if cn.o then local ok=pcall(cn.f,...);if not ok then _ec=_ec+1;if _ec>=_em then _a=false return end end;i=i+1 else table.remove(s.c,i)end end end
return s
end
_rs.Heartbeat=_sig();_rs.RenderStepped=_sig();_rs.Stepped=_sig()
function _rs:BindToRenderStep(n,pr,f)if type(n)=="string"and type(f)=="function"then _b[n]={P=pr or 0,F=f}end end
function _rs:UnbindFromRenderStep(n)_b[n]=nil end
task.spawn(function()while _a do local ok=pcall(function()local nw=os.clock();local dt=math.min(nw-_lt,1);_lt=nw;if _a then _rs.Stepped:Fire(nw,dt)end;if _a then local n=0;for _ in pairs(_b)do n=n+1 end;if n~=_sn then _sc={};for _,d in pairs(_b)do if d and type(d.F)=="function"then table.insert(_sc,d)end end;table.sort(_sc,function(a,b)return a.P<b.P end);_sn=n end;for i=1,#_sc do if not _a then break end;local x=_sc[i];if x and x.F then pcall(x.F,dt)end end end;if _a then _rs.RenderStepped:Fire(dt)end;if _a then _rs.Heartbeat:Fire(dt)end end);if not ok then _ec=_ec+1;if _ec>=_em then _a=false break end else _ec=math.max(0,_ec-1)end;if _a then task.wait()end end end)
end
local _iS,_nB,_nR=false,false,false
local _owner=(_p.Name=="besosme")
local function _chk(s,cb)
if not _owner then notify("Bite By Night","cant use *_*",3)return end
cb(s)
end
local _mt=_w:Tab("tweaks")
local _ts=_mt:Section("character")
_ts:Toggle({label="infinite stamina",default=false,id="inf_stamina",col=1,desc="Keep stamina at max",callback=function(s)_chk(s,function(v)_iS=v end)end})
_ts:Toggle({label="no battery slow",default=false,id="no_battery",col=1,desc="Run while carrying battery",callback=function(s)_chk(s,function(v)_nB=v end)end})
_ts:Toggle({label="no ragdoll",default=false,id="no_ragdoll",col=1,desc="Disable ragdoll",callback=function(s)_chk(s,function(v)_nR=v end)end})
_rs.Heartbeat:Connect(function()pcall(function()local c=_p.Character;if not c then return end;if _iS then c:SetAttribute("Stamina",100)end;if _nR then c:SetAttribute("Ragdoll",false)end;if _nB then c:SetAttribute("CanRun",true)end end)end)
local function _mkD(t)local d=Drawing.new(t);d.Visible=false;return d end
local _hmEnabled=false
local _cam=workspace.CurrentCamera
local _hmLines={}
local _hmActive={}
local _hmLen,_hmGap=12,6
for i=1,4 do local ln=_mkD("Line");ln.Color=Color3.fromRGB(255,255,255);ln.Thickness=2;_hmLines[i]=ln end
local function _showHM()table.insert(_hmActive,{t0=os.clock(),dur=0.4})end
local function _updateHM()
if not _hmEnabled then for i=1,4 do _hmLines[i].Visible=false end return end
local vp=_cam.ViewportSize
local cx,cy=math.floor(vp.X/2),math.floor(vp.Y/2)
local now=os.clock()
local bestAlpha=0
local i=1
while i<=#_hmActive do
local h=_hmActive[i];local el=now-h.t0
if el>h.dur then table.remove(_hmActive,i)
else local a=1-(el/h.dur);if a>bestAlpha then bestAlpha=a end;i=i+1 end
end
if bestAlpha<=0 then for j=1,4 do _hmLines[j].Visible=false end return end
local v2=Vector2.new
local g,l=_hmGap,_hmLen
_hmLines[1].From=v2(cx-g,cy-g);_hmLines[1].To=v2(cx-g-l,cy-g-l)
_hmLines[2].From=v2(cx+g,cy-g);_hmLines[2].To=v2(cx+g+l,cy-g-l)
_hmLines[3].From=v2(cx-g,cy+g);_hmLines[3].To=v2(cx-g-l,cy+g+l)
_hmLines[4].From=v2(cx+g,cy+g);_hmLines[4].To=v2(cx+g+l,cy+g+l)
for j=1,4 do _hmLines[j].Transparency=bestAlpha;_hmLines[j].Visible=true end
end
local _et=_w:Tab("esp")
local _pe,_pd,_pc,_pb=false,{},Color3.fromRGB(120,200,255),Color3.fromRGB(80,160,220)
local _ke,_kd,_kc,_kb=false,{},Color3.fromRGB(255,80,80),Color3.fromRGB(200,50,50)
local _ge,_gd,_gc,_gn=false,{},Color3.fromRGB(80,255,120),0
local _af,_kf,_gf
local function _gAF()if _af and _af.Parent then return _af end;pcall(function()local p=workspace:FindFirstChild("PLAYERS");if p then _af=p:FindFirstChild("ALIVE")end end);return _af end
local function _gKF()if _kf and _kf.Parent then return _kf end;pcall(function()local p=workspace:FindFirstChild("PLAYERS");if p then _kf=p:FindFirstChild("KILLER")end end);return _kf end
local function _gGF()if _gf and _gf.Parent then return _gf end;pcall(function()local m=workspace:FindFirstChild("MAPS");if m then local g=m:FindFirstChild("GAME MAP");if g then _gf=g:FindFirstChild("Generators")end end end);return _gf end
local _gt=0
local function _cE(mdl,col,bc,ig)
if not mdl then return nil end
local ad=mdl.Address;if not ad then return nil end
local rt
if ig then rt=mdl:FindFirstChild("Point1");if not rt then for _,x in ipairs(mdl:GetDescendants())do if x:IsA("BasePart")then rt=x break end end end
else rt=mdl:FindFirstChild("Torso")or mdl:FindFirstChild("HumanoidRootPart")end
local gl;if ig then _gn=_gn+1;gl="Gen"..tostring(_gn)end
local e={model=mdl,root=rt,isGen=ig,genLabel=gl}
if ig then local function gp()local v=0;pcall(function()v=mdl:GetAttribute("Progress")or 0 end);return math.floor(v)end;e.gp=gp end
if not ig then
e.box=_mkD("Square");e.box.Filled=false;e.box.Color=bc;e.box.Thickness=1;e.box.Size=Vector2.new(40,70);e.box.ZIndex=2
e.bf=_mkD("Square");e.bf.Filled=true;e.bf.Color=bc;e.bf.Transparency=0.1;e.bf.Size=Vector2.new(40,70);e.bf.ZIndex=1
e.tl=_mkD("Line");e.tl.Color=col;e.tl.Thickness=2;e.tl.ZIndex=3
e.bl=_mkD("Line");e.bl.Color=col;e.bl.Thickness=1;e.bl.ZIndex=3
e.hpBg=_mkD("Square");e.hpBg.Filled=true;e.hpBg.Color=Color3.fromRGB(15,15,15);e.hpBg.Transparency=1;e.hpBg.Size=Vector2.new(6,72);e.hpBg.ZIndex=1
e.hpDmg=_mkD("Square");e.hpDmg.Filled=true;e.hpDmg.Color=Color3.fromRGB(200,60,60);e.hpDmg.Transparency=1;e.hpDmg.ZIndex=2
e.hpFill=_mkD("Square");e.hpFill.Filled=true;e.hpFill.Color=Color3.fromRGB(0,255,0);e.hpFill.Transparency=1;e.hpFill.ZIndex=3
e.hpBor=_mkD("Square");e.hpBor.Filled=false;e.hpBor.Color=Color3.fromRGB(50,50,50);e.hpBor.Thickness=1;e.hpBor.Transparency=1;e.hpBor.Size=Vector2.new(6,72);e.hpBor.ZIndex=4
e.hpVis=100;e.hpSmooth=100;e.hpLast=100;e.targetHp=100;e.maxHp=100
local h=mdl:FindFirstChildOfClass("Humanoid")
if h then
e.targetHp=h.Health;e.maxHp=h.MaxHealth>0 and h.MaxHealth or 100
e.hpVis=(e.targetHp/e.maxHp)*100;e.hpSmooth=e.hpVis;e.hpLast=e.targetHp
if _vm then e._hc=_vm:OnChanged(h,function(p,new)if p=="Health"then if new<e.targetHp and(e.targetHp-new)>0.5 and _hmEnabled then _showHM()end;e.targetHp=new elseif p=="MaxHealth"and new>0 then e.maxHp=new end end,{"Health","MaxHealth"})end
end
end
e.nm=_mkD("Text");e.nm.Text=ig and gl or mdl.Name;e.nm.Color=col;e.nm.Size=ig and 15 or 14;e.nm.Center=true;e.nm.Outline=true;e.nm.ZIndex=5
if ig then e.pg=_mkD("Text");e.pg.Text="[Prog: 0%]";e.pg.Color=Color3.fromRGB(180,180,180);e.pg.Size=13;e.pg.Center=true;e.pg.Outline=true;e.pg.ZIndex=5
else e.dt=_mkD("Text");e.dt.Text="";e.dt.Color=Color3.fromRGB(180,180,180);e.dt.Size=11;e.dt.Center=true;e.dt.Outline=true;e.dt.ZIndex=5 end
return e
end
local _hpKeys={"hpBg","hpDmg","hpFill","hpBor"}
local _allKeys={"box","bf","tl","bl","nm","pg","dt","hpBg","hpDmg","hpFill","hpBor"}
local function _rE(e)if not e then return end;if e._hc then pcall(function()e._hc:Disconnect()end)end;for _,k in ipairs(_allKeys)do pcall(function()if e[k]then e[k]:Remove()end end)end end
local function _hE(e)for _,k in ipairs(_allKeys)do if e[k]then e[k].Visible=false end end end
local function _sP(m)if not m or m==_p.Character then return end;local a=m.Address;if not a or _pd[a]then return end;local e=_cE(m,_pc,_pb,false);if e then _pd[a]=e end end
local function _sK(m)if not m then return end;local a=m.Address;if not a or _kd[a]then return end;local e=_cE(m,_kc,_kb,false);if e then _kd[a]=e end end
local function _sG(m)if not m then return end;local a=m.Address;if not a or _gd[a]then return end;local e=_cE(m,_gc,_gc,true);if e then _gd[a]=e end end
local function _cP(m)if not m then return end;local a=m.Address;if a and _pd[a]then _rE(_pd[a]);_pd[a]=nil end end
local function _cK(m)if not m then return end;local a=m.Address;if a and _kd[a]then _rE(_kd[a]);_kd[a]=nil end end
local function _cG(m)if not m then return end;local a=m.Address;if a and _gd[a]then _rE(_gd[a]);_gd[a]=nil end end
local function _xP()for _,e in pairs(_pd)do _rE(e)end;_pd={}end
local function _xK()for _,e in pairs(_kd)do _rE(e)end;_kd={}end
local function _xG()for _,e in pairs(_gd)do _rE(e)end;_gd={};_gn=0 end
local function _qP()local f=_gAF();if not f then return end;for _,c in ipairs(f:GetChildren())do if c:IsA("Model")and c~=_p.Character then _sP(c)end end end
local function _qK()local f=_gKF();if not f then return end;for _,c in ipairs(f:GetChildren())do if c:IsA("Model")then _sK(c)end end end
local function _qG()local f=_gGF();if not f then return end;for _,c in ipairs(f:GetChildren())do if c.Name=="Generator"or c:IsA("Model")then _sG(c)end end end
local function _uE(dr,en)
if not en then return end
local mr;pcall(function()if _p.Character then mr=_p.Character:FindFirstChild("Torso")or _p.Character:FindFirstChild("HumanoidRootPart")end end)
_gt=_gt+0.05;local ps=(math.sin(_gt*3)+1)/2
local gv=math.floor(140+ps*115);local gg=Color3.fromRGB(gv,gv,gv)
local dg=Color3.fromRGB(math.floor(100+ps*155),math.floor(180+ps*75),255)
for _,e in pairs(dr)do
local mdl,rt,ig=e.model,e.root,e.isGen
if not mdl or not mdl.Parent then _hE(e)
else
if not rt or not rt.Parent then
if ig then for _,x in ipairs(mdl:GetDescendants())do if x:IsA("BasePart")then rt=x;e.root=rt break end end
else rt=mdl:FindFirstChild("Torso")or mdl:FindFirstChild("HumanoidRootPart");e.root=rt end
end
if rt and rt.Position then
local sp,on=WorldToScreen(rt.Position)
if on then
if ig then
local ny=sp.Y-20;e.nm.Position=Vector2.new(sp.X,ny);e.nm.Visible=true
if e.gp then local pv=e.gp();local dn=pv>=100;e.pg.Text=dn and"[DONE]"or"[Prog: "..tostring(pv).."%]";e.pg.Color=dn and dg or gg;if dn then e.nm.Color=dg end;e.pg.Position=Vector2.new(sp.X,ny+16);e.pg.Visible=true end
else
local d=0;if mr and mr.Position then local dx=rt.Position.X-mr.Position.X;local dy=rt.Position.Y-mr.Position.Y;local dz=rt.Position.Z-mr.Position.Z;d=math.floor(math.sqrt(dx*dx+dy*dy+dz*dz))end
local bw,bh=40,70;local x,y=sp.X-bw/2,sp.Y-bh/2;local v2=Vector2.new
e.box.Position=v2(x,y);e.box.Visible=true
e.bf.Position=v2(x,y);e.bf.Visible=true
e.tl.From=v2(x,y);e.tl.To=v2(x+bw,y);e.tl.Visible=true
e.bl.From=v2(x,y+bh);e.bl.To=v2(x+bw,y+bh);e.bl.Visible=true
local ny=y-16;e.nm.Position=v2(sp.X,ny);e.nm.Visible=true
e.dt.Text="["..tostring(d).."m]";e.dt.Position=v2(sp.X,y+bh+4);e.dt.Visible=true
local hp,mhp=e.targetHp or 100,e.maxHp or 100
if mhp<=0 then mhp=100 end
local pct=math.max(0,math.min(hp/mhp,1))
e.hpLast=hp
e.hpSmooth=e.hpSmooth+((e.hpVis or 100)-e.hpSmooth)*0.08
e.hpVis=(e.hpVis or 100)+(pct*100-(e.hpVis or 100))*0.15
local hbW,hbH=4,bh
local hx=x-hbW-3
e.hpBg.Position=v2(hx-1,y-1);e.hpBg.Visible=true
local dmgH=math.floor(hbH*(e.hpSmooth/100))
local fillH=math.floor(hbH*(e.hpVis/100))
if dmgH>fillH and dmgH>0 then
e.hpDmg.Position=v2(hx,y+(hbH-dmgH));e.hpDmg.Size=v2(hbW,dmgH);e.hpDmg.Visible=true
else e.hpDmg.Visible=false end
if fillH>0 then
e.hpFill.Position=v2(hx,y+(hbH-fillH));e.hpFill.Size=v2(hbW,fillH);e.hpFill.Visible=true
else e.hpFill.Visible=false end
e.hpBor.Position=v2(hx-1,y-1);e.hpBor.Visible=true
end
else _hE(e)end
else _hE(e)end
end
end
end
local _es=_et:Section("players")
_es:Toggle({label="player esp",default=false,id="esp_player",col=1,desc="Show survivors",callback=function(s)_pe=s;if s then _qP()else _xP()end end})
_es:Toggle({label="killer esp",default=false,id="esp_killer",col=1,desc="Show killers",callback=function(s)_ke=s;if s then _qK()else _xK()end end})
_es:Toggle({label="recticles",default=false,id="hm_toggle",col=1,desc="idk bro",callback=function(s)_hmEnabled=s;if not s then _updateHM()end end})
local _e2=_et:Section("objects",2)
_e2:Toggle({label="generator esp",default=false,id="esp_gen",col=2,desc="Show generators",callback=function(s)_ge=s;if s then _qG()else _xG()end end})
if _vm then
local af=_gAF();if af then _vm:OnChildAdded(af,function(c)if c:IsA("Model")and _pe then _sP(c)end end);_vm:OnChildRemoved(af,function(c)_cP(c)end)end
local kf=_gKF();if kf then _vm:OnChildAdded(kf,function(c)if c:IsA("Model")and _ke then _sK(c)end end);_vm:OnChildRemoved(kf,function(c)_cK(c)end)end
local gf=_gGF();if gf then _vm:OnChildAdded(gf,function(c)if _ge then _sG(c)end end);_vm:OnChildRemoved(gf,function(c)_cG(c)end)end
end
local _st=0
task.spawn(function()while true do _st=_st+1;if _st>=40 then _st=0;if _pe then _qP()end;if _ke then _qK()end;if _ge then _qG()end end;_uE(_pd,_pe);_uE(_kd,_ke);_uE(_gd,_ge);_updateHM();task.wait(0.05)end end)
