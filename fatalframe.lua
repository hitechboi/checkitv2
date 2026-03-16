

local UILib = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local FATAL_ACCENT = Color3.fromHex and Color3.fromHex("#7a1e2c") or Color3.fromRGB(122, 30, 44)

local function createScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "CheckItV2"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.Parent = localPlayer:WaitForChild("PlayerGui")
    return sg
end

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            update(input)
        end
    end)
end

local function createText(parent, text, size, color, bold, align)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextSize = size or 14
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextXAlignment = align or Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createToggle(parent)
    local holder = Instance.new("TextButton")
    holder.AutoButtonColor = false
    holder.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, -8, 0, 28)
    holder.Text = ""

    local label = createText(holder, "Toggle", 14, Color3.fromRGB(235, 235, 245), false, Enum.TextXAlignment.Left)
    label.Position = UDim2.fromOffset(10, 6)
    label.Size = UDim2.new(1, -60, 1, -6)

    local knobBg = Instance.new("Frame")
    knobBg.AnchorPoint = Vector2.new(1, 0.5)
    knobBg.Position = UDim2.new(1, -10, 0.5, 0)
    knobBg.Size = UDim2.fromOffset(34, 16)
    knobBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    knobBg.BorderSizePixel = 0
    knobBg.Parent = holder

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 8)
    uic.Parent = knobBg

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = Color3.fromRGB(140, 60, 85)
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = UDim2.fromOffset(1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = knobBg

    local uic2 = Instance.new("UICorner")
    uic2.CornerRadius = UDim.new(1, 0)
    uic2.Parent = knob

    local state = false
    local callback = nil

    local function setVisual(on)
        state = on
        if on then
            knobBg.BackgroundColor3 = Color3.fromRGB(220, 90, 120)
            knob.Position = UDim2.fromOffset(19, 1)
        else
            knobBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
            knob.Position = UDim2.fromOffset(1, 1)
        end
    end

    holder.MouseButton1Click:Connect(function()
        setVisual(not state)
        if callback then
            task.spawn(callback, state)
        end
    end)

    local api = {}
    function api:SetText(t)
        label.Text = t or ""
    end
    function api:SetState(v)
        setVisual(v and true or false)
        if callback then
            task.spawn(callback, state)
        end
    end
    function api:SetCallback(cb)
        callback = cb
    end

    return holder, api
end

local function createSlider(parent)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, -8, 0, 38)

    local label = createText(holder, "Slider", 14, Color3.fromRGB(235, 235, 245), false, Enum.TextXAlignment.Left)
    label.Position = UDim2.fromOffset(2, 0)
    label.Size = UDim2.new(1, -4, 0, 18)

    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
    barBg.BorderSizePixel = 0
    barBg.Position = UDim2.fromOffset(2, 22)
    barBg.Size = UDim2.new(1, -4, 0, 6)
    barBg.Parent = holder

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 3)
    uic.Parent = barBg

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(235, 90, 120)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.fromScale(0, 1)
    fill.Parent = barBg

    local uic2 = Instance.new("UICorner")
    uic2.CornerRadius = UDim.new(0, 3)
    uic2.Parent = fill

    local handle = Instance.new("Frame")
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Size = UDim2.fromOffset(10, 10)
    handle.Position = UDim2.fromOffset(0, 3)
    handle.BackgroundColor3 = Color3.fromRGB(255, 220, 230)
    handle.BorderSizePixel = 0
    handle.Parent = barBg

    local uic3 = Instance.new("UICorner")
    uic3.CornerRadius = UDim.new(1, 0)
    uic3.Parent = handle

    local valueLbl = createText(holder, "0", 12, Color3.fromRGB(210, 210, 220), false, Enum.TextXAlignment.Right)
    valueLbl.Position = UDim2.new(0, 0, 0, 0)
    valueLbl.Size = UDim2.new(1, -4, 0, 18)

    local dragging = false
    local minV, maxV, curV, isFloat = 0, 1, 0, false
    local callback = nil

    local function setVisual(v)
        curV = math.clamp(v, minV, maxV)
        local alpha = (curV - minV) / (maxV - minV)
        fill.Size = UDim2.fromScale(alpha, 1)
        handle.Position = UDim2.new(alpha, 0, 0.5, 0)
        local disp
        if isFloat then
            disp = string.format("%.2f", curV)
        else
            disp = tostring(math.floor(curV + 0.5))
        end
        valueLbl.Text = disp
        if callback then
            task.spawn(callback, curV)
        end
    end

    local function onInput(input)
        if not dragging then return end
        local rel = input.Position.X - barBg.AbsolutePosition.X
        local alpha = math.clamp(rel / barBg.AbsoluteSize.X, 0, 1)
        local v = minV + (maxV - minV) * alpha
        setVisual(v)
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            onInput(input)
        end
    end)

    barBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            onInput(input)
        end
    end)

    local api = {}
    function api:Configure(text, _min, _max, default, _isFloat, cb)
        label.Text = text or "Slider"
        minV = _min or 0
        maxV = _max or 1
        isFloat = _isFloat and true or false
        callback = cb
        setVisual(default or minV)
    end

    return holder, api
end

local function createButton(parent)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.Text = ""

    local lbl = createText(btn, "Button", 14, Color3.fromRGB(235, 235, 245), false, Enum.TextXAlignment.Center)
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Position = UDim2.fromScale(0.5, 0.5)
    lbl.Size = UDim2.new(1, -12, 1, -4)

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 4)
    uic.Parent = btn

    local callback = nil

    btn.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end)

    local api = {}
    function api:SetText(t)
        lbl.Text = t or "Button"
    end
    function api:SetCallback(cb)
        callback = cb
    end

    return btn, api
end

local function createDropdown(parent)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, -8, 0, 30)

    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Text = ""
    button.Parent = holder

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 4)
    uic.Parent = button

    local label = createText(button, "Dropdown", 14, Color3.fromRGB(235, 235, 245), false, Enum.TextXAlignment.Left)
    label.Position = UDim2.fromOffset(10, 6)
    label.Size = UDim2.new(1, -40, 1, -6)

    local valueLbl = createText(button, "", 13, Color3.fromRGB(210, 210, 230), false, Enum.TextXAlignment.Right)
    valueLbl.Position = UDim2.fromOffset(0, 6)
    valueLbl.Size = UDim2.new(1, -22, 1, -6)

    local arrow = createText(button, "v", 13, Color3.fromRGB(210, 210, 230), false, Enum.TextXAlignment.Right)
    arrow.Size = UDim2.fromOffset(16, 18)
    arrow.Position = UDim2.new(1, -18, 0, 6)

    local listFrame = Instance.new("Frame")
    listFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    listFrame.BorderSizePixel = 0
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 2)
    listFrame.Visible = false
    listFrame.Parent = holder

    local uicList = Instance.new("UICorner")
    uicList.CornerRadius = UDim.new(0, 4)
    uicList.Parent = listFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = listFrame

    local options = {}
    local selectedIdx = 1
    local callback = nil

    local function refreshSize()
        local count = #options
        listFrame.Size = UDim2.new(1, 0, 0, count > 0 and (count * 22 + 4) or 0)
    end

    local function setSelected(idx, fireCb)
        selectedIdx = idx
        local val = options[idx] or ""
        valueLbl.Text = val
        if fireCb and callback then
            task.spawn(callback, val, idx)
        end
    end

    local function rebuild()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.AutoButtonColor = false
            optBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            optBtn.BorderSizePixel = 0
            optBtn.Size = UDim2.new(1, -4, 0, 20)
            optBtn.Text = ""
            optBtn.Parent = listFrame

            local lbl = createText(optBtn, opt, 13, Color3.fromRGB(230, 230, 240), false, Enum.TextXAlignment.Left)
            lbl.Position = UDim2.fromOffset(8, 2)
            lbl.Size = UDim2.new(1, -10, 1, -4)

            optBtn.MouseButton1Click:Connect(function()
                listFrame.Visible = false
                arrow.Text = "v"
                setSelected(i, true)
            end)
        end
        refreshSize()
        if #options > 0 and (not options[selectedIdx]) then
            setSelected(1, false)
        end
    end

    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        arrow.Text = listFrame.Visible and "^" or "v"
    end)

    local api = {}
    function api:Configure(text, opts, defaultIdx, cb)
        label.Text = text or "Dropdown"
        options = table.clone(opts or {})
        callback = cb
        selectedIdx = defaultIdx or 1
        rebuild()
        setSelected(selectedIdx, false)
    end

    function api:SetOptions(opts)
        options = table.clone(opts or {})
        rebuild()
        setSelected(1, false)
    end

    return holder, api
end

-----------------------------------------------------------------------
-- Window / Tab API
-----------------------------------------------------------------------

function UILib.Window(titleA, titleB, gameName)
    titleA = titleA or "check it"
    titleB = titleB or "prison life"
    gameName = gameName or ""

    local sg = createScreenGui()

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.Size = UDim2.fromOffset(560, 360)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BorderSizePixel = 0
    main.Parent = sg

    local uicMain = Instance.new("UICorner")
    uicMain.CornerRadius = UDim.new(0, 6)
    uicMain.Parent = main

    local topBar = Instance.new("Frame")
    topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.Parent = main

    local titleLbl = createText(topBar, string.lower(titleA) .. "  " .. string.lower(titleB), 14, FATAL_ACCENT, true, Enum.TextXAlignment.Left)
    titleLbl.Position = UDim2.fromOffset(10, 6)
    titleLbl.Size = UDim2.new(0.5, -10, 1, -6)

    local gameLbl = createText(topBar, string.lower(gameName or ""), 13, Color3.fromRGB(180, 180, 195), false, Enum.TextXAlignment.Left)
    gameLbl.Position = UDim2.fromOffset(10, 16)
    gameLbl.Size = UDim2.new(0.5, -10, 1, -16)

    local tabsBar = Instance.new("Frame")
    tabsBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tabsBar.BorderSizePixel = 0
    tabsBar.Position = UDim2.fromOffset(0, 30)
    tabsBar.Size = UDim2.new(1, 0, 0, 28)
    tabsBar.Parent = main

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabsLayout.Parent = tabsBar

    local tabsPadding = Instance.new("UIPadding")
    tabsPadding.PaddingLeft = UDim.new(0, 10)
    tabsPadding.Parent = tabsBar

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    content.BorderSizePixel = 0
    content.Position = UDim2.fromOffset(0, 58)
    content.Size = UDim2.new(1, 0, 1, -58)
    content.Parent = main

    local tabs = {}
    local currentTab = nil

        local function selectTab(tab)
        if currentTab == tab then return end
        currentTab = tab
        for _, t in ipairs(tabs) do
            t.btn.TextColor3 = t == tab and FATAL_ACCENT or Color3.fromRGB(200, 200, 205)
            t.btn.BackgroundTransparency = t == tab and 0 or 1
            t.page.Visible = (t == tab)
        end
    end

    makeDraggable(main, topBar)

    local win = {}
    win._tabOrder = {}

    function win:Tab(name)
        table.insert(self._tabOrder, name)

        local tabBtn = Instance.new("TextButton")
        tabBtn.AutoButtonColor = false
        tabBtn.BackgroundTransparency = 1
        tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        tabBtn.BorderSizePixel = 0
        tabBtn.Size = UDim2.fromOffset(80, 24)
        tabBtn.Text = name
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 13
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 205)
        tabBtn.Parent = tabsBar

        local page = Instance.new("Frame")
        page.BackgroundTransparency = 1
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Visible = false
        page.Parent = content

        local left = Instance.new("Frame")
        left.BackgroundTransparency = 1
        left.Size = UDim2.new(0.5, -20, 1, -20)
        left.Position = UDim2.fromOffset(10, 10)
        left.Parent = page

        local right = Instance.new("Frame")
        right.BackgroundTransparency = 1
        right.Size = UDim2.new(0.5, -20, 1, -20)
        right.Position = UDim2.new(0.5, 10, 0, 10)
        right.Parent = page

        local function setupList(frame)
            local layout = Instance.new("UIListLayout")
            layout.FillDirection = Enum.FillDirection.Vertical
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 6)
            layout.Parent = frame
        end

        setupList(left)
        setupList(right)

        local tabObj = {btn = tabBtn, page = page, left = left, right = right}
        table.insert(tabs, tabObj)

        tabBtn.MouseButton1Click:Connect(function()
            selectTab(tabObj)
        end)

        if not currentTab then
            selectTab(tabObj)
        end

        local columnToggle = true

        local api = {}

        function api:Div(title, _)
            local targetCol = columnToggle and left or right
            columnToggle = not columnToggle

            local div = Instance.new("Frame")
            div.BackgroundTransparency = 1
            div.Size = UDim2.new(1, -4, 0, 22)
            div.Parent = targetCol

            local lbl = createText(div, string.upper(title or ""), 13, Color3.fromRGB(200, 90, 120), true, Enum.TextXAlignment.Left)
            lbl.Position = UDim2.fromOffset(2, 2)
            lbl.Size = UDim2.new(1, -4, 1, -4)
        end

        function api:Toggle(text, default, cb, _tip)
            local targetCol = left
            local element, toApi = createToggle(targetCol)
            element.Parent = targetCol
            toApi:SetText(text or "Toggle")
            toApi:SetCallback(cb)
            if default then
                toApi:SetState(true)
            end
            return toApi
        end

        function api:Slider(text, minV, maxV, default, cb, isFloat, _tip)
            local targetCol = left
            local element, slApi = createSlider(targetCol)
            element.Parent = targetCol
            slApi:Configure(text, minV, maxV, default, isFloat, cb)
            return slApi
        end

        function api:Dropdown(text, opts, defaultIdx, cb, _tip)
            local targetCol = right
            local element, ddApi = createDropdown(targetCol)
            element.Parent = targetCol
            ddApi:Configure(text, opts, defaultIdx, cb)
            return ddApi
        end

        function api:Button(text, _color, cb)
            local targetCol = right
            local element, btApi = createButton(targetCol)
            element.Parent = targetCol
            btApi:SetText(text or "Button")
            btApi:SetCallback(cb)
            return btApi
        end

        return api
    end

    function win:SettingsTab()
        return self:Tab("Settings")
    end

    function win:Destroy()
        if sg then
            sg:Destroy()
        end
    end

    function win:ApplyTheme(_name)
        -- Single main theme: "Fatal Frame"
        -- Primary: black, Secondary/accent: FATAL_ACCENT
        topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tabsBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        titleLbl.TextColor3 = FATAL_ACCENT
    end

    return win
end

return UILib
