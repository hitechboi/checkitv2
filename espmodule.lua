local ESP={}
ESP.__index=ESP
ESP.Settings={Enabled=true,Box=true,Skeleton=true,Health=true,Distance=true,Name=true,Tracers=false,TextSize=14}
ESP.Objects={}

local camera=workspace.CurrentCamera
local rs=game:GetService("RunService")
local floor=math.floor
local function md(c)return Drawing.new(c)end

local ESPObj={}
ESPObj.__index=ESPObj

function ESPObj.new(m,o)
    local s=setmetatable({},ESPObj)
    s.Model=m
    s.Options=o or {}
    s.Root=m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildOfClass("Part")
    s.Color=s.Options.Color or Color3.fromRGB(255,255,255)
    s.Drawings={}
    s:CreateDrawings()
    return s
end

function ESPObj:CreateDrawings()
    local d=self.Drawings
    d.Box=md("Square")d.Box.Filled=false;d.Box.Thickness=1;d.Box.ZIndex=2
    d.HpBg=md("Square")d.HpBg.Filled=true;d.HpBg.Color=Color3.fromRGB(15,15,15);d.HpBg.ZIndex=1
    d.HpFill=md("Square")d.HpFill.Filled=true;d.HpFill.Color=Color3.fromRGB(150,255,150);d.HpFill.ZIndex=3
    d.Name=md("Text")d.Name.Size=ESP.Settings.TextSize;d.Name.Center=true;d.Name.Outline=true;d.Name.ZIndex=5
    d.Dist=md("Text")d.Dist.Size=ESP.Settings.TextSize-3;d.Dist.Color=Color3.fromRGB(180,180,180);d.Dist.Center=true;d.Dist.Outline=true;d.Dist.ZIndex=5
    local sk={}
    for i=1,5 do local l=md("Line")l.Thickness=2;l.ZIndex=4;sk[i]=l end
    d.Skeleton=sk
    d.Tracer=md("Line")d.Tracer.Thickness=1;d.Tracer.ZIndex=1
end

function ESPObj:SetVis(s)
    local d=self.Drawings
    d.Box.Visible=s and ESP.Settings.Box
    d.Name.Visible=s and ESP.Settings.Name
    d.Dist.Visible=s and ESP.Settings.Distance
    d.HpBg.Visible=s and ESP.Settings.Health
    d.HpFill.Visible=s and ESP.Settings.Health
    d.Tracer.Visible=s and ESP.Settings.Tracers
    for _,l in ipairs(d.Skeleton) do l.Visible=false end
end

function ESPObj:Remove()
    local d=self.Drawings
    for _,l in ipairs(d.Skeleton)do l:Remove()end
    d.Box:Remove()d.Name:Remove()d.Dist:Remove()d.HpBg:Remove()d.HpFill:Remove()d.Tracer:Remove()
end

local function wtsp(p)
    local v,o=camera:WorldToScreenPoint(p)
    return Vector2.new(v.X,v.Y),o,v.Z
end

function ESPObj:UpdateSkeleton()
    local d=self.Drawings.Skeleton
    for _,l in ipairs(d)do l.Visible=false end
    if not ESP.Settings.Skeleton then return end
    local m=self.Model
    local idx=1
    local function connectup(p1,p2)
        if not p1 or not p2 then return end
        local pos1,o1=wtsp(p1.Position)
        local pos2,o2=wtsp(p2.Position)
        if o1 and o2 then
            local l=d[idx]
            if l then l.Visible=true;l.From=pos1;l.To=pos2;l.Color=self.Color;idx=idx+1 end
        end
    end
    local hd,t=m:FindFirstChild("Head"),m:FindFirstChild("Torso")
    local la,ra=m:FindFirstChild("Left Arm"),m:FindFirstChild("Right Arm")
    local ll,rl=m:FindFirstChild("Left Leg"),m:FindFirstChild("Right Leg")
    connectup(hd,t)connectup(t,la)connectup(t,ra)connectup(t,ll)connectup(t,rl)
end

function ESPObj:UpdateHBar(pos,s,pct)
    local d=self.Drawings
    local h=s.Y
    d.HpBg.Size=Vector2.new(4,h);d.HpBg.Position=Vector2.new(pos.X-s.X/2-6,pos.Y-s.Y/2)
    d.HpFill.Size=Vector2.new(2,h*pct);d.HpFill.Position=Vector2.new(pos.X-s.X/2-5,pos.Y+s.Y/2-(h*pct))
end

function ESPObj:Update()
    if not self.Model or not self.Model.Parent or not self.Root then self:SetVis(false)return false end
    local pos,on=wtsp(self.Root.Position)
    if not on or not ESP.Settings.Enabled then self:SetVis(false)return true end
    local dist=(camera.CFrame.Position-self.Root.Position).Magnitude
    local scale=1000/dist
    local bs=Vector2.new(self.Options.SizeX and self.Options.SizeX*scale or 40*scale,self.Options.SizeY and self.Options.SizeY*scale or 70*scale)
    self:SetVis(true)
    local d=self.Drawings
    if ESP.Settings.Box then
        d.Box.Size=bs;d.Box.Position=Vector2.new(pos.X-bs.X/2,pos.Y-bs.Y/2);d.Box.Color=self.Color
    end
    if ESP.Settings.Name then
        d.Name.Text=self.Options.Name or self.Model.Name
        d.Name.Position=Vector2.new(pos.X,pos.Y-bs.Y/2-16);d.Name.Color=self.Color
    end
    if ESP.Settings.Distance then
        d.Dist.Text="["..floor(dist).." st]";d.Dist.Position=Vector2.new(pos.X,pos.Y+bs.Y/2+2)
    end
    if ESP.Settings.Health then
        local hum=self.Model:FindFirstChildOfClass("Humanoid")
        if hum then self:UpdateHBar(pos,bs,hum.Health/(hum.MaxHealth>0 and hum.MaxHealth or 100))
        else d.HpBg.Visible=false;d.HpFill.Visible=false end
    end
    if ESP.Settings.Tracers then
        d.Tracer.From=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y);d.Tracer.To=Vector2.new(pos.X,pos.Y+bs.Y/2);d.Tracer.Color=self.Color
    end
    if ESP.Settings.Skeleton then self:UpdateSkeleton()end
    return true
end

function ESP:Add(m,o)if m and not ESP.Objects[m]then ESP.Objects[m]=ESPObj.new(m,o)end end
function ESP:Remove(m)if ESP.Objects[m]then ESP.Objects[m]:Remove();ESP.Objects[m]=nil end end

rs.RenderStepped:Connect(function()
    if not ESP.Settings.Enabled then return end
    for m,o in pairs(ESP.Objects)do if not o:Update()then ESP:Remove(m)end end
end)
_G.BiteByNightESP=ESP
return ESP
