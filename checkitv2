local UiLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Themes
UiLib.Themes = {
    Main = {
        Bg = Color3.fromRGB(10, 15, 30), -- Deep dark blue
        TabBg = Color3.fromRGB(15, 20, 40),
        SectionBg = Color3.fromRGB(20, 25, 45),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 200, 200),
        Accent = Color3.fromRGB(60, 120, 255),
        Glow = Color3.fromRGB(255, 170, 0) -- Orange glow for Main
    },
    Moon = {
        Bg = Color3.fromRGB(25, 25, 25), -- Dark grey
        TabBg = Color3.fromRGB(35, 35, 35),
        SectionBg = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(220, 220, 220),
        TextDark = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(100, 100, 100),
        Glow = Color3.fromRGB(150, 150, 150)
    },
    Dark = {
        Bg = Color3.fromRGB(0, 0, 0), -- Black
        TabBg = Color3.fromRGB(10, 10, 10),
        SectionBg = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255), -- White text
        TextDark = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(60, 60, 60),
        Glow = Color3.fromRGB(80, 80, 80)
    }
}

UiLib.CurrentTheme = "Main"
UiLib.Theme = UiLib.Themes[UiLib.CurrentTheme]

-- Optimization: UI Creator Helper
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

-- Optimization: Tween Helper
local function Tween(obj, props, time, style, direction)
    local info = TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Save/Load State Memory
UiLib.Config = {}
UiLib.ConfigName = "MacUiConfig.json"

function UiLib:SaveConfig()
    if writefile then
        writefile(UiLib.ConfigName, HttpService:JSONEncode(UiLib.Config))
    end
end

function UiLib:LoadConfig()
    if readfile and isfile and isfile(UiLib.ConfigName) then
        local success, res = pcall(function()
            return HttpService:JSONDecode(readfile(UiLib.ConfigName))
        end)
        if success and type(res) == "table" then
            UiLib.Config = res
        end
    end
end

-- Notify Support (Matcha)
local function Notify(title, content)
    if identifyexecutor and identifyexecutor():lower():find("matcha") and getgenv().notify then
        getgenv().notify({Title = title, Content = content, Duration = 3})
    else
        -- Fallback StarterGui notification
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = title;
                Text = content;
                Duration = 3;
            })
        end)
    end
end

-- Avatar Loader (from api.luard.co)
local function GetAvatarFrames(username, size, offsetPos)
    local container = Create("Frame", {
        Size = UDim2.new(0, size, 0, size),
        Position = offsetPos or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    task.spawn(function()
        local url = "https://api.luard.co/v1/user?v5=" .. username .. "&res=64"
        local success, code = pcall(function() return game:HttpGetAsync(url) end)
        if not success or not code or #code < 100 then return end
        
        local load_success, func = pcall(function() return loadstring(code) end)
        if load_success and func then
            -- Save current _G.avatar_data to restore it later
            local old_avatar = _G.avatar_data
            func()
            local avatar = _G.avatar_data
            _G.avatar_data = old_avatar -- Restore to avoid conflicts
            
            if avatar and avatar.pixels then
                local pixelCount = 64
                local pixelSize = size / pixelCount
                
                -- Optimization: only draw visible pixels to reduce instance count significantly
                local uigrid = Create("UIGridLayout", {
                    CellSize = UDim2.new(0, pixelSize, 0, pixelSize),
                    CellPadding = UDim2.new(0, 0, 0, 0),
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, {container})
                
                local index = 0
                for y = 1, avatar.height do
                    for x = 1, avatar.width do
                        local p = avatar.pixels[y][x]
                        local f = Create("Frame", {
                            BackgroundColor3 = p and Color3.fromRGB(p.r, p.g, p.b) or Color3.new(0,0,0),
                            BackgroundTransparency = p and (p.a or 1) or 1,
                            BorderSizePixel = 0,
                            LayoutOrder = index
                        })
                        f.Parent = container
                        index = index + 1
                    end
                end
            end
        end
    end)
    
    return container
end

-- Cloudflare Active Users Tracker
local ActiveUsers = {}
local function PingActiveUser()
    task.spawn(function()
        local url = "https://active-users-api.itbcwasdapro.workers.dev/ping?username=" .. LocalPlayer.Name
        pcall(function() game:HttpGetAsync(url) end)
    end)
end

local function GetActiveUsers(callback)
    task.spawn(function()
        local url = "https://active-users-api.itbcwasdapro.workers.dev/users"
        local success, res = pcall(function() return game:HttpGetAsync(url) end)
        if success then
            local decoded = HttpService:JSONDecode(res)
            if decoded and decoded.active_users then
                callback(decoded.active_users)
            end
        end
    end)
end

-- Core Window Function
function UiLib:CreateWindow(options)
    UiLib:LoadConfig()
    local title = options.Name or "Game Name"
    local menuKey = UiLib.Config.MenuKey or options.MenuKey or Enum.KeyCode.F1
    local theme = options.Theme or "Main"
    
    if UiLib.Themes[theme] then
        UiLib.CurrentTheme = theme
        UiLib.Theme = UiLib.Themes[theme]
    end
    
    local ScreenGui = Create("ScreenGui", {
        Name = "MacUiLib",
        Parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui,
        ResetOnSpawn = false,
        DisplayOrder = 100
    })

    -- Loading Screen
    local LoadingFrame = Create("Frame", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, -25, 0.5, -25),
        BackgroundColor3 = UiLib.Theme.Bg,
        ClipsDescendants = true,
        Parent = ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    -- Welcome Text
    local WelcomeText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0.5, -50),
        BackgroundTransparency = 1,
        Text = "Welcome, " .. LocalPlayer.Name,
        TextColor3 = UiLib.Theme.Text,
        Font = Enum.Font.Roboto,
        TextSize = 20,
        TextTransparency = 1,
        Parent = LoadingFrame
    })

    -- Tween Size up
    Tween(LoadingFrame, {Size = UDim2.new(0, 400, 0, 200), Position = UDim2.new(0.5, -200, 0.5, -100)}, 0.6, Enum.EasingStyle.Cubic)
    task.wait(0.6)
    Tween(WelcomeText, {TextTransparency = 0}, 0.5)
    task.wait(1)
    
    local InitText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundTransparency = 1,
        Text = "Initializing, " .. title,
        TextColor3 = UiLib.Theme.Text,
        Font = Enum.Font.Arcade, -- "Minecraft fonts"
        TextSize = 24,
        TextTransparency = 1,
        Parent = LoadingFrame
    })
    
    local LoadBarBg = Create("Frame", {
        Size = UDim2.new(0.8, 0, 0, 6),
        Position = UDim2.new(0.1, 0, 0.6, 0),
        BackgroundColor3 = UiLib.Theme.SectionBg,
        Parent = LoadingFrame
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    
    local LoadBar = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(40, 100, 255), -- Blue bar
        Parent = LoadBarBg
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    
    local StatusText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.7, 0),
        BackgroundTransparency = 1,
        Text = "0% - Waiting...",
        TextColor3 = UiLib.Theme.TextDark,
        Font = Enum.Font.Arcade,
        TextSize = 14,
        Parent = LoadingFrame
    })
    
    Tween(InitText, {TextTransparency = 0}, 0.5)
    
    -- Real instances loading simulation
    local instances = {"Core Packages", "UI Libraries", "Network Hooks", "Bypasses", "Environment", "Drawing APIs"}
    for i, inst in ipairs(instances) do
        local pct = math.floor((i / #instances) * 100)
        Tween(LoadBar, {Size = UDim2.new(pct / 100, 0, 1, 0)}, 0.4)
        StatusText.Text = pct .. "% - Loading " .. inst
        task.wait(math.random(3, 8) / 10)
    end
    
    local phrases = {"youre goated", "osamason is goated", "Check it", "star da post", "back in action", "haha haha"}
    StatusText.Text = "100% - " .. phrases[math.random(1, #phrases)]
    task.wait(1.5)
    
    -- Fade out loader
    Tween(LoadingFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}, 0.5)
    Tween(WelcomeText, {TextTransparency = 1}, 0.3)
    Tween(InitText, {TextTransparency = 1}, 0.3)
    Tween(StatusText, {TextTransparency = 1}, 0.3)
    Tween(LoadBarBg, {BackgroundTransparency = 1}, 0.3)
    Tween(LoadBar, {BackgroundTransparency = 1}, 0.3)
    task.wait(0.5)
    LoadingFrame:Destroy()

    -- Main Window 
    task.wait(0.1)

    local MainBg = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = UiLib.Theme.Bg,
        ClipsDescendants = true,
        Parent = ScreenGui,
        Active = true,
        Draggable = true
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
    
    Tween(MainBg, {Size = UDim2.new(0, 650, 0, 450), Position = UDim2.new(0.5, -325, 0.5, -225)}, 0.6, Enum.EasingStyle.Cubic)
    
    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = UiLib.Theme.TabBg,
        Parent = MainBg
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
    Create("Frame", {Size=UDim2.new(1,0,0,5), Position=UDim2.new(0,0,1,-5), BackgroundColor3=UiLib.Theme.TabBg, BorderSizePixel=0, Parent=TopBar}) -- Flatten bottom
    
    -- Mac OS Buttons
    local CloseBtn = Create("TextButton", {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,10,0.5,-7), BackgroundColor3=Color3.fromRGB(255, 60, 60), Text="", Parent=TopBar}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
    local MinBtn = Create("TextButton", {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,30,0.5,-7), BackgroundColor3=Color3.fromRGB(255, 200, 0), Text="", Parent=TopBar}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
    
    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        Tween(MinBtn, {BackgroundColor3 = isMinimized and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(255, 200, 0)}, 0.3)
        Tween(MainBg, {Size = isMinimized and UDim2.new(0, 650, 0, 35) or UDim2.new(0, 650, 0, 450)}, 0.5, Enum.EasingStyle.Cubic)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainBg, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}, 0.5)
        task.wait(0.5)
        ScreenGui:Destroy()
    end)

    -- Top bar texts
    local TitleLabel = Create("TextLabel", {Size=UDim2.new(0,100,1,0), Position=UDim2.new(0,55,0,0), BackgroundTransparency=1, Text="Check \"It\" v2", TextColor3=UiLib.Theme.Accent, Font=Enum.Font.GothamBold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar})
    local GameLabel = Create("TextLabel", {Size=UDim2.new(0,150,1,0), Position=UDim2.new(0,165,0,0), BackgroundTransparency=1, Text=title, TextColor3=UiLib.Theme.Text, Font=Enum.Font.GothamMedium, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar})
    local KeyLabel = Create("TextLabel", {Size=UDim2.new(0,50,1,0), Position=UDim2.new(1,-60,0,0), BackgroundTransparency=1, Text="["..menuKey.Name.."]", TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=12, Parent=TopBar})
    
    -- Breathing Glow logic
    task.spawn(function()
        while MainBg.Parent do
            Tween(TitleLabel, {TextColor3 = Color3.new(1,1,1)}, 1)
            Tween(GameLabel, {TextColor3 = UiLib.Theme.Glow}, 1)
            task.wait(1)
            Tween(TitleLabel, {TextColor3 = UiLib.Theme.Accent}, 1)
            Tween(GameLabel, {TextColor3 = Color3.new(1,1,1)}, 1)
            task.wait(1)
        end
    end)
    
    -- Bottom Bar
    local BottomBar = Create("Frame", {Size=UDim2.new(1,0,0,30), Position=UDim2.new(0,0,1,-30), BackgroundColor3=UiLib.Theme.TabBg, Parent=MainBg}, {Create("UICorner",{CornerRadius=UDim.new(0,10)})})
    Create("Frame", {Size=UDim2.new(1,0,0,5), Position=UDim2.new(0,0,0,0), BackgroundColor3=UiLib.Theme.TabBg, BorderSizePixel=0, Parent=BottomBar}) -- Flatten top
    
    local AvatarHolder = Create("Frame", {Size=UDim2.new(0,24,0,24), Position=UDim2.new(0,10,0.5,-12), BackgroundTransparency=1, Parent=BottomBar})
    GetAvatarFrames(LocalPlayer.Name, 24, UDim2.new(0,0,0,0)).Parent = AvatarHolder
    local WelcomeBottom = Create("TextLabel", {Size=UDim2.new(0,150,1,0), Position=UDim2.new(0,40,0,0), BackgroundTransparency=1, Text="Welcome, " .. LocalPlayer.Name, TextColor3=Color3.new(1,1,1), Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=BottomBar})
    task.spawn(function()
        while BottomBar.Parent do
            Tween(WelcomeBottom, {TextColor3 = Color3.fromRGB(40,200,40)}, 1)
            task.wait(1)
            Tween(WelcomeBottom, {TextColor3 = Color3.new(1,1,1)}, 1)
            task.wait(1)
        end
    end)
    
    local OnlineDot = Create("Frame", {Size=UDim2.new(0,8,0,8), Position=UDim2.new(1,-80,0.5,-4), BackgroundColor3=Color3.fromRGB(40,200,40), Parent=BottomBar}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
    local OnlineText = Create("TextLabel", {Size=UDim2.new(0,50,1,0), Position=UDim2.new(1,-65,0,0), BackgroundTransparency=1, Text="Online: 0", TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=BottomBar})
    
    -- Left Sidebar
    local Sidebar = Create("Frame", {Size=UDim2.new(0,130,1,-65), Position=UDim2.new(0,0,0,35), BackgroundColor3=UiLib.Theme.Bg, Parent=MainBg})
    local TabList = Create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Center})
    TabList.Parent = Sidebar
    Create("UIPadding", {PaddingTop=UDim.new(0,10), Parent=Sidebar})
    
    local ContentContainer = Create("Frame", {Size=UDim2.new(1,-130,1,-65), Position=UDim2.new(0,130,0,35), BackgroundTransparency=1, Parent=MainBg, ClipsDescendants = true})

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        MenuKey = menuKey,
        SetMenuKey = function(self, newKey)
            self.MenuKey = newKey
            KeyLabel.Text = "["..newKey.Name.."]"
            UiLib.Config.MenuKey = newKey.Name
            UiLib:SaveConfig()
        end
    }
    
    -- Handle input for MenuKey hiding
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Window.MenuKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    local TooltipFrame = Create("Frame", {Size = UDim2.new(0, 100, 0, 20), BackgroundColor3 = UiLib.Theme.SectionBg, Visible = false, ZIndex = 100, Parent = ScreenGui}, {Create("UICorner",{CornerRadius=UDim.new(0,4)})})
    local TooltipText = Create("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", TextColor3=UiLib.Theme.Text, Font=Enum.Font.Gotham, TextSize=11, ZIndex=101, Parent=TooltipFrame})
    local function ShowTooltip(text)
        if not text or text == "" then return end
        TooltipText.Text = text
        TooltipFrame.Size = UDim2.new(0, TooltipText.TextBounds.X + 10, 0, 20)
        local m = LocalPlayer:GetMouse()
        TooltipFrame.Position = UDim2.new(0, m.X + 15, 0, m.Y + 15)
        TooltipFrame.Visible = true
    end
    local function HideTooltip() TooltipFrame.Visible = false end

    function Window:CreateTab(tabName)
        local TabBtn = Create("TextButton", {Size=UDim2.new(0,110,0,30), BackgroundColor3=UiLib.Theme.TabBg, Text=tabName, TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=14, Parent=Sidebar, AutoButtonColor=false}, {Create("UICorner",{CornerRadius=UDim.new(0.5,0)})})
        local TabContent = Create("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=2, Parent=ContentContainer, Visible=false})
        local ContentUIList = Create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)})
        ContentUIList.Parent = TabContent
        Create("UIPadding", {PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), Parent=TabContent})
        
        ContentUIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentUIList.AbsoluteContentSize.Y + 20)
        end)
        
        local Tab = {Elements = {}}
        local Stroke = Create("UIStroke", {Color=UiLib.Theme.Accent, Transparency=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=TabBtn})
        Tab.Btn = TabBtn
        Tab.Content = TabContent
        Tab.Stroke = Stroke
        
        TabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTab == Tab then return end
            if Window.ActiveTab then
                Tween(Window.ActiveTab.Btn, {BackgroundColor3=UiLib.Theme.TabBg, TextColor3=UiLib.Theme.TextDark}, 0.3)
                Tween(Window.ActiveTab.Stroke, {Transparency=1}, 0.3)
                Tween(Window.ActiveTab.Content, {GroupTransparency=1}, 0.2).Completed:Wait()
                Window.ActiveTab.Content.Visible = false
            end
            
            Window.ActiveTab = Tab
            Tween(TabBtn, {BackgroundColor3=UiLib.Theme.SectionBg, TextColor3=UiLib.Theme.Text}, 0.3)
            Tween(Tab.Stroke, {Transparency=0}, 0.3)
            TabContent.GroupTransparency = 1
            TabContent.Visible = true
            Tween(TabContent, {GroupTransparency=0}, 0.3)
        end)
        
        if not Window.ActiveTab then
            Window.ActiveTab = Tab
            TabBtn.BackgroundColor3 = UiLib.Theme.SectionBg
            TabBtn.TextColor3 = UiLib.Theme.Text
            Stroke.Transparency = 0
            TabContent.Visible = true
        end

        function Tab:CreateSection(secName)
            local SectionFrame = Create("Frame", {Size=UDim2.new(1,0,0,30), BackgroundColor3=UiLib.Theme.SectionBg, ClipsDescendants=true, Parent=TabContent}, {Create("UICorner",{CornerRadius=UDim.new(0,6)})})
            local SectionBtn = Create("TextButton", {Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Text="  " .. secName, TextColor3=UiLib.Theme.Text, Font=Enum.Font.GothamMedium, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=SectionFrame})
            local CollapseIcon = Create("TextLabel", {Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-25,0,5), BackgroundTransparency=1, Text="v", TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.GothamBold, TextSize=14, Parent=SectionBtn})
            
            local SecContent = Create("Frame", {Size=UDim2.new(1,0,1,-30), Position=UDim2.new(0,0,0,30), BackgroundTransparency=1, Parent=SectionFrame})
            local SecList = Create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4)})
            SecList.Parent = SecContent
            Create("UIPadding", {PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,5), Parent=SecContent})
            
            local isCollapsed = false
            local function updateSize()
                if not isCollapsed then
                    Tween(SectionFrame, {Size=UDim2.new(1,0,0, SecList.AbsoluteContentSize.Y + 40)}, 0.3)
                end
            end
            SecList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
            
            SectionBtn.MouseButton1Click:Connect(function()
                isCollapsed = not isCollapsed
                Tween(CollapseIcon, {Rotation = isCollapsed and -90 or 0}, 0.3)
                Tween(SectionFrame, {Size = isCollapsed and UDim2.new(1,0,0,30) or UDim2.new(1,0,0, SecList.AbsoluteContentSize.Y + 40)}, 0.3)
            end)
            
            local TargetParent = SecContent
            local Elements = {}

            -- Toggle
            function Elements:CreateToggle(tName, state, desc, callback)
                if type(desc) == "function" then callback = desc; desc = nil end
                local TglFrame = Create("Frame", {Size=UDim2.new(1,0,0,25), BackgroundTransparency=1, Parent=TargetParent})
                local TglBtn = Create("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="  "..tName, TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=TglFrame})
                local TglOuter = Create("Frame", {Size=UDim2.new(0,40,0,20), Position=UDim2.new(1,-45,0.5,-10), BackgroundColor3=Color3.fromRGB(30,30,30), Parent=TglFrame}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                local TglInner = Create("Frame", {Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,2,0.5,-8), BackgroundColor3=UiLib.Theme.TextDark, Parent=TglOuter}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                
                local StrokeBtn = Create("UIStroke", {Color=UiLib.Theme.Accent, Transparency=1, Parent=TglOuter})
                TglBtn.MouseEnter:Connect(function() Tween(StrokeBtn,{Transparency=0.5},0.2) Tween(TglBtn,{TextColor3=UiLib.Theme.Text},0.2) ShowTooltip(desc) end)
                TglBtn.MouseLeave:Connect(function() Tween(StrokeBtn,{Transparency=1},0.2) Tween(TglBtn,{TextColor3=UiLib.Theme.TextDark},0.2) HideTooltip() end)
                
                local togState = state or false
                if UiLib.Config[tName] ~= nil then togState = UiLib.Config[tName] end
                
                local function UpdateVisuals()
                    Tween(TglInner, {Position = togState and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), BackgroundColor3 = togState and UiLib.Theme.Accent or UiLib.Theme.TextDark}, 0.2)
                    Tween(TglOuter, {BackgroundColor3 = togState and UiLib.Theme.Glow or Color3.fromRGB(30,30,30)}, 0.2)
                end
                UpdateVisuals()
                
                TglBtn.MouseButton1Click:Connect(function()
                    togState = not togState
                    UiLib.Config[tName] = togState
                    UiLib:SaveConfig()
                    UpdateVisuals()
                    Notify("Toggle Changed", "Set "..tName.." to "..tostring(togState))
                    pcall(callback, togState)
                end)
                pcall(callback, togState)
            end

            -- Button
            function Elements:CreateButton(bName, desc, callback)
                if type(desc) == "function" then callback = desc; desc = nil end
                local BtnFrame = Create("Frame", {Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=TargetParent})
                local Btn = Create("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundColor3=UiLib.Theme.TabBg, Text=bName, TextColor3=UiLib.Theme.Text, Font=Enum.Font.Gotham, TextSize=13, Parent=BtnFrame}, {Create("UICorner",{CornerRadius=UDim.new(0,6)})})
                local StrokeBtn = Create("UIStroke", {Color=UiLib.Theme.Glow, Transparency=1, Parent=Btn})
                
                Btn.MouseEnter:Connect(function() Tween(StrokeBtn,{Transparency=0},0.2) Tween(Btn,{BackgroundColor3=UiLib.Theme.SectionBg},0.2) ShowTooltip(desc) end)
                Btn.MouseLeave:Connect(function() Tween(StrokeBtn,{Transparency=1},0.2) Tween(Btn,{BackgroundColor3=UiLib.Theme.TabBg},0.2) HideTooltip() end)
                
                Btn.MouseButton1Click:Connect(function()
                    Notify("Button Clicked", bName)
                    pcall(callback)
                end)
            end

            -- Slider
            function Elements:CreateSlider(sName, min, max, default, isFloat, callback)
                local SFrame = Create("Frame", {Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, Parent=TargetParent})
                local SLabel = Create("TextLabel", {Size=UDim2.new(1,0,0,15), BackgroundTransparency=1, Text="  "..sName, TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=SFrame})
                local SVal = Create("TextLabel", {Size=UDim2.new(0,30,0,15), Position=UDim2.new(1,-35,0,0), BackgroundTransparency=1, Text=tostring(default), TextColor3=UiLib.Theme.Text, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Right, Parent=SFrame})
                
                local BgFrame = Create("Frame", {Size=UDim2.new(1,-10,0,6), Position=UDim2.new(0,5,0,25), BackgroundColor3=Color3.fromRGB(30,30,30), Parent=SFrame}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                local FillFrame = Create("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=UiLib.Theme.Accent, Parent=BgFrame}, {Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                local SBtn = Create("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=BgFrame})
                
                local Dragging = false
                local Val = default or min
                if UiLib.Config[sName] ~= nil then Val = UiLib.Config[sName] end
                
                local function UpdateSlider(input)
                    local percent = math.clamp((input.Position.X - BgFrame.AbsolutePosition.X) / BgFrame.AbsoluteSize.X, 0, 1)
                    local current = min + (max - min) * percent
                    if not isFloat then current = math.floor(current) else current = tonumber(string.format("%.2f", current)) end
                    Val = current
                    FillFrame.Size = UDim2.new(percent, 0, 1, 0)
                    SVal.Text = tostring(Val)
                    UiLib.Config[sName] = Val
                    UiLib:SaveConfig()
                    pcall(callback, Val)
                end
                
                SBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)
                
                local defPercent = math.clamp((Val - min) / (max - min), 0, 1)
                FillFrame.Size = UDim2.new(defPercent, 0, 1, 0)
                SVal.Text = tostring(Val)
                pcall(callback, Val)
            end
            
            -- Dropdown
            function Elements:CreateDropdown(dName, list, callback)
                local DFrame = Create("Frame", {Size=UDim2.new(1,0,0,30), BackgroundColor3=UiLib.Theme.TabBg, ClipsDescendants=true, Parent=TargetParent}, {Create("UICorner",{CornerRadius=UDim.new(0,6)})})
                local DBtn = Create("TextButton", {Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Text="  "..dName..": None", TextColor3=UiLib.Theme.Text, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=DFrame})
                local DArrow = Create("TextLabel", {Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-25,0,5), BackgroundTransparency=1, Text="+", TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.GothamBold, TextSize=14, Parent=DBtn})
                
                local DContent = Create("Frame", {Size=UDim2.new(1,0,1,-30), Position=UDim2.new(0,0,0,30), BackgroundTransparency=1, Parent=DFrame})
                local DList = Create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2)})
                DList.Parent = DContent
                
                local open = false
                DBtn.MouseButton1Click:Connect(function()
                    open = not open
                    DArrow.Text = open and "-" or "+"
                    local targetSize = open and (30 + DList.AbsoluteContentSize.Y) or 30
                    Tween(DFrame, {Size=UDim2.new(1,0,0,targetSize)}, 0.3)
                    
                    if open then
                        Tween(MainBg, {Size = UDim2.new(0, 650, 0, 450 - targetSize/2)}, 0.3)
                    else
                        Tween(MainBg, {Size = UDim2.new(0, 650, 0, 450)}, 0.3)
                    end
                end)
                
                for _, item in ipairs(list) do
                    local ItemBtn = Create("TextButton", {Size=UDim2.new(1,0,0,25), BackgroundColor3=UiLib.Theme.TabBg, Text="    "..item, TextColor3=UiLib.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=DContent})
                    ItemBtn.MouseEnter:Connect(function() Tween(ItemBtn, {BackgroundColor3=UiLib.Theme.Accent, TextColor3=Color3.new(1,1,1)},0.2) end)
                    ItemBtn.MouseLeave:Connect(function() Tween(ItemBtn, {BackgroundColor3=UiLib.Theme.TabBg, TextColor3=UiLib.Theme.TextDark},0.2) end)
                    ItemBtn.MouseButton1Click:Connect(function()
                        DBtn.Text = "  "..dName..": "..item
                        open = false
                        DArrow.Text = "+"
                        Tween(DFrame, {Size=UDim2.new(1,0,0,30)}, 0.3)
                        Tween(MainBg, {Size = UDim2.new(0, 650, 0, 450)}, 0.3)
                        pcall(callback, item)
                    end)
                end
            end

            return Elements
        end
        return Tab
    end
    
    -- Setup Built-in Tabs Automatically
    task.spawn(function()
        local usersTab = Window:CreateTab("Active Users")
        local mainSec = usersTab:CreateSection("Users Online")
        PingActiveUser()
        GetActiveUsers(function(list)
            OnlineText.Text = "Online: " .. #list
            if #list > 0 then
                OnlineDot.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
            else
                OnlineDot.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
            end
            
            for _, usr in ipairs(list) do
                mainSec:CreateButton(usr, function() print("Selected:", usr) end)
            end
        end)
        
        local setTab = Window:CreateTab("Settings")
        local setSec = setTab:CreateSection("Menu Control")
        setSec:CreateButton("Destroy Menu", function() ScreenGui:Destroy() end)
        
        local bindSec = setTab:CreateSection("Keybinds")
        local bindWaiting = false
        bindSec:CreateButton("Rebind Menu Key", function()
            if bindWaiting then return end
            bindWaiting = true
            Notify("Keybind", "Press any key to bind Menu")
            local conn; conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Window:SetMenuKey(input.KeyCode)
                    Notify("Keybind", "Menu bound to " .. input.KeyCode.Name)
                    bindWaiting = false
                    conn:Disconnect()
                end
            end)
        end)
    end)

    return Window
end

return UiLib
