-- NovaLib v1.1 - Modern draggable mod menu library (by srfcheats)
-- Password default: "NovaModsReborn"
-- Place in a LocalScript (player environment) or host and loadstring it.

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NovaLib = {}
local _CONFIGS = {}

-- ===== Utility / Save helpers =====
local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

local function canWrite()
    return pcall(function() return writefile ~= nil end)
end

local function saveConfigFile(name, tbl)
    if not canWrite() then return false end
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, tbl)
    if not ok then return false end
    pcall(writefile, name, enc)
    return true
end

local function loadConfigFile(name)
    if not canWrite() then return nil end
    if not pcall(readfile, name) then return nil end
    local txt = readfile(name)
    local ok, dec = pcall(HttpService.JSONDecode, HttpService, txt)
    if ok then return dec end
    return nil
end

-- ===== Style & helpers =====
local COLORS = {
    blue = Color3.fromRGB(0,102,255),
    blueLight = Color3.fromRGB(120,180,255),
    uiBg = Color3.fromRGB(255,255,255),
    uiText = Color3.fromRGB(0,102,255),
    dark = Color3.fromRGB(30,30,30),
    light = Color3.fromRGB(240,240,240)
}

local function mk(parent, class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    obj.Parent = parent
    return obj
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end
local function makeStroke(parent, thickness, color)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or COLORS.blueLight
    s.Parent = parent
    return s
end

local function tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

-- ===== Floating Circle Launcher (shared) =====
local circleGui = mk(playerGui, "ScreenGui", {Name = "NovaLibCircleGui", ResetOnSpawn = false, IgnoreGuiInset = true})
local circleBtn = mk(circleGui, "TextButton", {
    Name = "NovaLauncher",
    Size = UDim2.new(0,64,0,64),
    Position = UDim2.new(0.05,0,0.35,0),
    BackgroundColor3 = COLORS.blue,
    Text = "Nova",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.new(1,1,1),
    BorderSizePixel = 0,
})
makeCorner(circleBtn,999)
makeStroke(circleBtn, 2, COLORS.blueLight)

-- Circle drag (mobile-friendly)
do
    local dragging, dragStart, startPos, dragInput
    circleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = circleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    circleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragInput and input == dragInput and dragging then
            local delta = input.Position - dragStart
            circleBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ===== Password Modal (shared) =====
local function createPasswordModal()
    local g = mk(playerGui, "ScreenGui", {Name = "NovaLibPassword", ResetOnSpawn = false, IgnoreGuiInset = true})
    g.Enabled = false

    local overlay = mk(g, "Frame", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, BorderSizePixel = 0})
    local box = mk(g, "Frame", {Size = UDim2.new(0,360,0,140), Position = UDim2.new(0.5,-180,0.45,-70), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = COLORS.dark})
    makeCorner(box, 10)

    local title = mk(box, "TextLabel", {Size = UDim2.new(1,-24,0,28), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 18, Text = "Enter Password", TextColor3 = Color3.new(1,1,1)})
    local input = mk(box, "TextBox", {Size = UDim2.new(1,-24,0,40), Position = UDim2.new(0,12,0,48), BackgroundColor3 = Color3.fromRGB(245,245,245), PlaceholderText = "Password", Font = Enum.Font.Gotham})
    local feedback = mk(box, "TextLabel", {Size = UDim2.new(1,-24,0,18), Position = UDim2.new(0,12,1,-28), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(255,100,100)})
    local submit = mk(box, "TextButton", {Size = UDim2.new(0,120,0,34), Position = UDim2.new(1,-136,1,-52), BackgroundColor3 = COLORS.blue, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1,1,1), Text = "Unlock"})
    makeCorner(submit, 6)
    local cancel = mk(box, "TextButton", {Size = UDim2.new(0,100,0,34), Position = UDim2.new(0,12,1,-52), BackgroundColor3 = Color3.fromRGB(130,130,130), Font = Enum.Font.Gotham, TextColor3 = Color3.new(1,1,1), Text = "Exit"})
    makeCorner(cancel, 6)

    local function open()
        if g.Enabled then return end
        g.Enabled = true
        overlay.BackgroundTransparency = 1
        box.Size = UDim2.new(0,0,0,0)
        box.Visible = true
        tween(overlay, {BackgroundTransparency = 0.5}, 0.25)
        tween(box, {Size = UDim2.new(0,360,0,140)}, 0.28, Enum.EasingStyle.Back)
        input.Text = ""; feedback.Text = ""; input:CaptureFocus()
    end
    local function close()
        if not g.Enabled then return end
        tween(overlay, {BackgroundTransparency = 1}, 0.18)
        tween(box, {Size = UDim2.new(0,0,0,0)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.2, function() box.Visible = false; g.Enabled = false end)
    end

    return {Gui = g, Open = open, Close = close, Input = input, Submit = submit, Cancel = cancel, Feedback = feedback}
end

local passwordModal = createPasswordModal()
local MASTER_PASSWORD = "NovaModsReborn"

-- ===== Window Factory =====
function NovaLib:MakeWindow(opts)
    opts = opts or {}
    local name = opts.Name or "Nova Window"
    local saveConfig = opts.SaveConfig == true
    local configName = opts.ConfigName or (name:gsub("%s+","_") .. ".json")

    -- create screen gui container
    local gui = mk(playerGui, "ScreenGui", {Name = "NovaWindow_" .. name, ResetOnSpawn = false, IgnoreGuiInset = true})
    local window = mk(gui, "Frame", {Size = UDim2.new(0,340,0,260), Position = UDim2.new(0.5,-170,0.5,-130), BackgroundColor3 = COLORS.uiBg, Visible = false})
    makeCorner(window, 12)

    -- logo strip (small)
    local logoStrip = mk(window, "Frame", {Size = UDim2.new(0,80,0,28), Position = UDim2.new(0,12,0,12), BackgroundColor3 = COLORS.blue})
    makeCorner(logoStrip, 6)

    -- tabs bar
    local tabsBar = mk(window, "Frame", {Size = UDim2.new(1,-24,0,34), Position = UDim2.new(0,12,0,56), BackgroundTransparency = 1})

    -- close/hide
    local closeBtn = mk(window, "TextButton", {Size = UDim2.new(0,80,0,28), Position = UDim2.new(1,-96,0,12), BackgroundColor3 = COLORS.light, Text = "Close", Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
    makeCorner(closeBtn, 6)
    local hideBtn = mk(window, "TextButton", {Size = UDim2.new(0,60,0,28), Position = UDim2.new(1,-36,0,12), BackgroundColor3 = Color3.fromRGB(230,230,230), Text = "Hide", Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
    makeCorner(hideBtn, 6)

    local content = mk(window, "Frame", {Position = UDim2.new(0,12,0,96), Size = UDim2.new(1,-24,1,-120), BackgroundTransparency = 1})

    local footer = mk(window, "TextLabel", {Size = UDim2.new(1,0,0,22), Position = UDim2.new(0,0,1,-26), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14, Text = "coded by srfcheats", TextColor3 = COLORS.uiText})

    -- draggable window
    do
        local dragging, dragStart, startPos, dragInput
        window.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = inp.Position
                startPos = window.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        window.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
        end)
        UIS.InputChanged:Connect(function(inp)
            if dragInput and inp == dragInput and dragging then
                local delta = inp.Position - dragStart
                window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- config load
    _CONFIGS[configName] = _CONFIGS[configName] or {}
    if saveConfig and canWrite() then
        local loaded = loadConfigFile(configName)
        if loaded then _CONFIGS[configName] = loaded end
    end

    -- tab maker
    function window:MakeTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or "Tab"
        -- create tab button
        local index = #tabsBar:GetChildren() + 1
        local btn = mk(tabsBar, "TextButton", {Size = UDim2.new(0,120,0,30), Position = UDim2.new(0, (index-1)*128, 0, 0), BackgroundColor3 = COLORS.light, Text = tabName, Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
        makeCorner(btn, 6)

        -- create frame
        local tabFrame = mk(content, "Frame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})

        -- show logic
        btn.MouseButton1Click:Connect(function()
            for _, c in pairs(content:GetChildren()) do
                if c:IsA("Frame") then c.Visible = false end
            end
            tabFrame.Visible = true
        end)

        -- auto open first tab
        if #content:GetChildren() == 0 then
            btn:Activate()
            tabFrame.Visible = true
        end

        -- Tab API
        local TabAPI = {}

        function TabAPI:AddParagraph(opts)
            opts = opts or {}
            local title = mk(tabFrame, "TextLabel", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = COLORS.uiText, Text = tostring(opts.Title or "")})
            local body = mk(tabFrame, "TextLabel", {Size = UDim2.new(1,0,0,36), Position = UDim2.new(0,0,0,22), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(80,80,80), Text = tostring(opts.Text or "")})
            return title, body
        end

        function TabAPI:AddLabel(opts)
            opts = opts or {}
            local label = mk(tabFrame, "TextLabel", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = COLORS.uiText, Text = tostring(opts.Text or "")})
            return label
        end

        function TabAPI:AddButton(opts)
            opts = opts or {}
            local btn = mk(tabFrame, "TextButton", {Size = UDim2.new(0,260,0,36), Position = UDim2.new(0,0,0, (#tabFrame:GetChildren()-1)*42 ), BackgroundColor3 = COLORS.light, Text = tostring(opts.Name or "Button"), Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
            makeCorner(btn, 8)
            btn.MouseButton1Click:Connect(function() if type(opts.Callback) == "function" then pcall(opts.Callback) end end)
            return btn
        end

        function TabAPI:AddToggle(opts)
            opts = opts or {}
            local name = tostring(opts.Name or "Toggle")
            local default = opts.Default == true
            local flag = opts.Flag or name:gsub("%s","_")
            _CONFIGS[configName] = _CONFIGS[configName] or {}
            if _CONFIGS[configName][flag] == nil then _CONFIGS[configName][flag] = default end

            local btn = mk(tabFrame, "TextButton", {Size = UDim2.new(0,260,0,36), Position = UDim2.new(0,0,0, (#tabFrame:GetChildren()-1)*42 ), BackgroundColor3 = COLORS.light, Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
            makeCorner(btn, 8)
            btn.Text = name .. " : " .. (_CONFIGS[configName][flag] and "ON" or "OFF")
            btn.MouseButton1Click:Connect(function()
                _CONFIGS[configName][flag] = not _CONFIGS[configName][flag]
                btn.Text = name .. " : " .. (_CONFIGS[configName][flag] and "ON" or "OFF")
                if type(opts.Callback) == "function" then pcall(opts.Callback, _CONFIGS[configName][flag]) end
                if saveConfig then saveConfigFile(configName, _CONFIGS[configName]) end
            end)
            return btn
        end

        function TabAPI:AddSlider(opts)
            opts = opts or {}
            local min = tonumber(opts.Min) or 0
            local max = tonumber(opts.Max) or 1
            local default = tonumber(opts.Default) or min
            local step = tonumber(opts.Step) or 0.01
            local flag = opts.Flag or (opts.Name or "Slider"):gsub("%s","_")
            _CONFIGS[configName] = _CONFIGS[configName] or {}
            if _CONFIGS[configName][flag] == nil then _CONFIGS[configName][flag] = default end

            local label = mk(tabFrame, "TextLabel", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = COLORS.uiText})
            label.Text = tostring(opts.Name or "Slider") .. ": " .. tostring(_CONFIGS[configName][flag])

            local bar = mk(tabFrame, "Frame", {Size = UDim2.new(0,260,0,12), Position = UDim2.new(0,0,0, (#tabFrame:GetChildren()-1)*42 + 24), BackgroundColor3 = Color3.fromRGB(230,230,230)})
            makeCorner(bar, 6)
            local rel = (_CONFIGS[configName][flag] - min) / (max - min)
            local fill = mk(bar, "Frame", {Size = UDim2.new(rel,0,1,0), BackgroundColor3 = COLORS.blue})
            makeCorner(fill,6)
            local knob = mk(bar, "TextButton", {Size = UDim2.new(0,16,0,16), Position = UDim2.new(rel,0,0.5,-8), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0})
            makeCorner(knob, 999)

            -- dragging logic
            local dragging = false
            knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            knob.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UIS.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = i.Position.X; local abs = bar.AbsolutePosition.X; local w = bar.AbsoluteSize.X
                    if w > 0 then
                        local r = math.clamp((x-abs)/w, 0, 1)
                        local val = min + r*(max-min)
                        val = math.floor(val/step+0.5)*step
                        _CONFIGS[configName][flag] = tonumber(string.format("%.2f", val))
                        fill.Size = UDim2.new(r,0,1,0)
                        knob.Position = UDim2.new(r,0,0.5,-8)
                        label.Text = tostring(opts.Name or "Slider") .. ": " .. tostring(_CONFIGS[configName][flag])
                        if type(opts.Callback) == "function" then pcall(opts.Callback, _CONFIGS[configName][flag]) end
                        if saveConfig then saveConfigFile(configName, _CONFIGS[configName]) end
                    end
                end
            end)

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local x = i.Position.X; local abs = bar.AbsolutePosition.X; local w = bar.AbsoluteSize.X
                    if w > 0 then
                        local r = math.clamp((x-abs)/w, 0, 1)
                        local val = min + r*(max-min)
                        val = math.floor(val/step+0.5)*step
                        _CONFIGS[configName][flag] = tonumber(string.format("%.2f", val))
                        fill.Size = UDim2.new(r,0,1,0)
                        knob.Position = UDim2.new(r,0,0.5,-8)
                        label.Text = tostring(opts.Name or "Slider") .. ": " .. tostring(_CONFIGS[configName][flag])
                        if type(opts.Callback) == "function" then pcall(opts.Callback, _CONFIGS[configName][flag]) end
                        if saveConfig then saveConfigFile(configName, _CONFIGS[configName]) end
                    end
                end
            end)

            return {Label = label, Bar = bar, Fill = fill, Knob = knob}
        end

        function TabAPI:AddTextbox(opts)
            opts = opts or {}
            local box = mk(tabFrame, "TextBox", {Size = UDim2.new(0,260,0,36), Position = UDim2.new(0,0,0, (#tabFrame:GetChildren()-1)*42 ), BackgroundColor3 = Color3.fromRGB(245,245,245), Font = Enum.Font.Gotham, TextSize = 16, PlaceholderText = tostring(opts.Placeholder or "")})
            makeCorner(box,8)
            box.FocusLost:Connect(function(enter) if enter and type(opts.Callback) == "function" then pcall(opts.Callback, box.Text) end end)
            return box
        end

        function TabAPI:AddDropdown(opts)
            opts = opts or {}
            local name = tostring(opts.Name or "Dropdown")
            local items = opts.Options or {}
            local flag = opts.Flag or name:gsub("%s","_")
            _CONFIGS[configName] = _CONFIGS[configName] or {}
            if _CONFIGS[configName][flag] == nil and #items>0 then _CONFIGS[configName][flag] = items[1] end

            local container = mk(tabFrame, "Frame", {Size = UDim2.new(0,260,0,36), Position = UDim2.new(0,0,0, (#tabFrame:GetChildren()-1)*42 )})
            local label = mk(container, "TextLabel", {Size = UDim2.new(1,-30,1,0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = COLORS.uiText, Text = name})
            local arrow = mk(container, "TextButton", {Size = UDim2.new(0,30,1,0), Position = UDim2.new(1,-30,0,0), BackgroundColor3 = COLORS.light, Text = "v", Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
            makeCorner(container, 8); makeCorner(arrow,6)

            -- dropdown list popup
            local listGui = mk(playerGui, "ScreenGui", {Name = "NovaDropdownTemp", ResetOnSpawn = false})
            listGui.Enabled = false
            local listFrame = mk(listGui, "Frame", {Size = UDim2.new(0,200,0,20 + #items*28), Position = UDim2.new(0.5,0,0.5,0), BackgroundColor3 = COLORS.uiBg})
            makeCorner(listFrame,8)
            listFrame.Visible = false

            local function showList()
                listGui.Enabled = true
                listFrame.Visible = true
                -- position under container
                local abs = container.AbsolutePosition
                listFrame.Position = UDim2.new(0, abs.X, 0, abs.Y + container.AbsoluteSize.Y + 6)
                -- clear existing children except template index 0
                for _,c in pairs(listFrame:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
                for i,v in ipairs(items) do
                    local it = mk(listFrame, "TextButton", {Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,0,(i-1)*28), BackgroundColor3 = COLORS.light, Text = v, Font = Enum.Font.Gotham, TextColor3 = COLORS.uiText})
                    makeCorner(it,6)
                    it.MouseButton1Click:Connect(function()
                        _CONFIGS[configName][flag] = v
                        if type(opts.Callback) == "function" then pcall(opts.Callback, v) end
                        listFrame.Visible = false
                        listGui.Enabled = false
                    end)
                end
            end
            arrow.MouseButton1Click:Connect(function()
                if listFrame.Visible then listFrame.Visible = false; listGui.Enabled = false else showList() end
            end)

            -- show current selection initially
            label.Text = name .. " : " .. tostring(_CONFIGS[configName][flag] or "")

            return {
                Container = container,
                Label = label,
                Open = showList,
                Get = function() return _CONFIGS[configName][flag] end
            }
        end

        function TabAPI:AddKeybind(opts)
            opts = opts or {}
            local name = tostring(opts.Name or "Keybind")
            local flag = opts.Flag or name:gsub("%s","_")
            _CONFIGS[configName] = _CONFIGS[configName] or {}
            if _CONFIGS[configName][flag] == nil then _CONFIGS[configName][flag] = "None" end

            local btn = mk(tabFrame, "TextButton", {Size = UDim2.new(0,260,0,36), Position = UDim2.new(0,0,0,(#tabFrame:GetChildren()-1)*42), BackgroundColor3 = COLORS.light, Font = Enum.Font.GothamBold, TextColor3 = COLORS.uiText})
            makeCorner(btn,8)
            btn.Text = name .. " : " .. tostring(_CONFIGS[configName][flag])

            local capturing = false
            btn.MouseButton1Click:Connect(function()
                capturing = true
                btn.Text = name .. " : [Press a key]"
                -- capture next key
                local conn
                conn = UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.KeyCode then
                        _CONFIGS[configName][flag] = tostring(input.KeyCode)
                        btn.Text = name .. " : " .. tostring(_CONFIGS[configName][flag])
                        if type(opts.Callback) == "function" then pcall(opts.Callback, _CONFIGS[configName][flag]) end
                        if saveConfig then saveConfigFile(configName, _CONFIGS[configName]) end
                        capturing = false
                        conn:Disconnect()
                    end
                end)
            end)

            return btn
        end

        function TabAPI:AddColorPicker(opts)
            opts = opts or {}
            local name = tostring(opts.Name or "Color")
            local flag = opts.Flag or name:gsub("%s","_")
            _CONFIGS[configName] = _CONFIGS[configName] or {}
            if _CONFIGS[configName][flag] == nil then _CONFIGS[configName][flag] = {r=0,g=102,b=255} end

            local container = mk(tabFrame, "Frame", {Size = UDim2.new(0,260,0,36), Position = UDim2.new(0,0,0,(#tabFrame:GetChildren()-1)*42 )})
            local label = mk(container, "TextLabel", {Size = UDim2.new(0,200,1,0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = COLORS.uiText, Text = name})
            local swatch = mk(container, "Frame", {Size = UDim2.new(0,36,0,24), Position = UDim2.new(1,-40,0.5,-12), BackgroundColor3 = Color3.fromRGB(_CONFIGS[configName][flag].r,_CONFIGS[configName][flag].g,_CONFIGS[configName][flag].b)})
            makeCorner(swatch,6)

            -- open a simple color picker modal
            local pickerGui = mk(playerGui, "ScreenGui", {Name = "NovaColorPickerTemp", ResetOnSpawn = false})
            pickerGui.Enabled = false
            local pickerFrame = mk(pickerGui, "Frame", {Size = UDim2.new(0,300,0,200), Position = UDim2.new(0.5,-150,0.5,-100), BackgroundColor3 = COLORS.uiBg})
            makeCorner(pickerFrame,10)

            local hue = mk(pickerFrame, "Frame", {Size = UDim2.new(0,260,0,24), Position = UDim2.new(0,20,0,20), BackgroundColor3 = COLORS.light})
            makeCorner(hue,6)
            local hueFill = mk(hue, "Frame", {Size = UDim2.new(0.5,0,1,0), BackgroundColor3 = COLORS.blue})
            makeCorner(hueFill,6)

            local doneBtn = mk(pickerFrame, "TextButton", {Size = UDim2.new(0,100,0,32), Position = UDim2.new(0.5,-50,1,-48), BackgroundColor3 = COLORS.blue, Text = "Select", Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1,1,1)})
            makeCorner(doneBtn,6)

            local function openPicker()
                pickerGui.Enabled = true
                pickerFrame.Visible = true
            end

            local function closePicker()
                pickerGui.Enabled = false
                pickerFrame.Visible = false
            end

            swatch.MouseButton1Click:Connect(function() openPicker() end)
            doneBtn.MouseButton1Click:Connect(function()
                -- simplistic: pick a color proportional to hueFill size (demo)
                local r,g,b = 0,102,255
                _CONFIGS[configName][flag] = {r=r,g=g,b=b}
                swatch.BackgroundColor3 = Color3.fromRGB(r,g,b)
                if type(opts.Callback) == "function" then pcall(opts.Callback, _CONFIGS[configName][flag]) end
                closePicker()
                if saveConfig then saveConfigFile(configName, _CONFIGS[configName]) end
            end)

            return {
                Container = container,
                Label = label,
                Swatch = swatch,
                GetColor = function() return _CONFIGS[configName][flag] end
            }
        end

        return TabAPI
    end

    -- window public API
    local API = {}
    API.Gui = gui
    API.Frame = window
    function API:Show()
        window.Visible = true
        circleBtn.Visible = false
    end
    function API:Hide()
        window.Visible = false
        circleBtn.Visible = true
    end
    function API:Save()
        if canWrite() then saveConfigFile(configName, _CONFIGS[configName] or {}) end
    end

    -- close/hide button handlers
    closeBtn.MouseButton1Click:Connect(function() window.Visible = false; circleBtn.Visible = true end)
    hideBtn.MouseButton1Click:Connect(function() window.Visible = false; circleBtn.Visible = false end)

    -- bind to close saving
    game:BindToClose(function() if canWrite() then saveConfigFile(configName, _CONFIGS[configName] or {}) end end)

    return API
end

-- ===== Circle behavior: when clicked, open password modal then first window created =====
local createdWindows = {} -- store created windows guis to show after password

-- intercept MakeWindow to track created windows
local oldMakeWindow = NovaLib.MakeWindow
NovaLib.MakeWindow = function(self, opts)
    local win = oldMakeWindow(self, opts)
    table.insert(createdWindows, win)
    return win
end

circleBtn.MouseButton1Click:Connect(function()
    if #createdWindows == 0 then
        -- nothing made yet, open password modal to unlock library features
        passwordModal.Open()
        return
    end
    -- if not unlocked -> show password modal
    if not (script and script._NovaUnlocked) and not passwordModal.Gui.Enabled and not (script and script._NovaUnlocked) then
        passwordModal.Open()
        return
    end
    -- toggle first window
    for _, w in ipairs(createdWindows) do
        if w and w.Frame then
            w:Show()
            break
        end
    end
end)

-- password handling
passwordModal.Submit.MouseButton1Click:Connect(function()
    local txt = tostring(passwordModal.Input.Text or "")
    if txt == MASTER_PASSWORD then
        passwordModal.Feedback.TextColor3 = Color3.fromRGB(100,255,100)
        passwordModal.Feedback.Text = "Password correct. Unlocking..."
        task.wait(0.3)
        passwordModal.Close()
        -- mark unlocked in script
        if script then script._NovaUnlocked = true end
        -- open first created window or keep circle if none
        for _, w in ipairs(createdWindows) do
            if w and w.Frame then
                w:Show()
                -- center near current circle position
                local frame = w.Frame
                local cPos = circleBtn.AbsolutePosition; local cSize = circleBtn.AbsoluteSize
                local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
                local menuW, menuH = frame.AbsoluteSize.X, frame.AbsoluteSize.Y
                local menuX = (cPos.X + cSize.X/2) - (menuW/2)
                local menuY = (cPos.Y + cSize.Y/2) - (menuH/2)
                frame.Position = UDim2.new(0, math.clamp(menuX, 10, screenSize.X - menuW - 10), 0, math.clamp(menuY, 10, screenSize.Y - menuH - 10))
                circleBtn.Visible = false
                break
            end
        end
    else
        passwordModal.Feedback.TextColor3 = Color3.fromRGB(255,100,100)
        passwordModal.Feedback.Text = "Incorrect password."
        passwordModal.Input.Text = ""
    end
end)

passwordModal.Cancel.MouseButton1Click:Connect(function()
    passwordModal.Feedback.Text = "Cancelled."
    task.wait(0.2); passwordModal.Close()
end)

-- finalize
return NovaLib

-- ===========================
-- Example usage (paste into a separate LocalScript after hosting NovaLib)
--[[
local Nova = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
local Win = Nova:MakeWindow({Name="Nova Mods", SaveConfig=true, ConfigName="novaconfig.json"})
local Tab = Win:MakeTab({Name="Features"})
Tab:AddLabel({Text="Welcome to Nova"})
Tab:AddParagraph({Title="Info", Text="Use these features carefully."})
Tab:AddToggle({Name="AutoMine", Default=false, Flag="AutoMineFlag", Callback=function(v)
    print("AutoMine:", v)
end})
Tab:AddButton({Name="Battery Saver", Callback=function()
    print("Battery Saver Clicked")
end})
Tab:AddSlider({Name="Mine Delay", Min=0.01, Max=1, Default=0.05, Step=0.01, Flag="MineDelay", Callback=function(v) print("Delay",v) end})
local dd = Tab:AddDropdown({Name="Example Dropdown", Options={"One","Two","Three"}, Flag="DD"})
local k = Tab:AddKeybind({Name="Toggle Key", Flag="Key1", Callback=function(kc) print("Bound to",kc) end})
local col = Tab:AddColorPicker({Name="Accent Color", Flag="Accent", Callback=function(col) print(col) end})
]]
-- ===========================
