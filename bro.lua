-- ===========================
-- NovaLib v1.2 - Fixed Version
-- Author: srfcheats (modified/fixed)
-- Password default: "NovaModsReborn"
-- Place in a LocalScript
-- ===========================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NovaLib = {}
local _CONFIGS = {}

-- ===== Utility =====
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

-- ===== Styles =====
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

-- ===== Floating Circle Launcher =====
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
makeCorner(circleBtn, 999)
makeStroke(circleBtn, 2, COLORS.blueLight)

-- Draggable circle
do
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        circleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    circleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = circleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    circleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ===== Password Modal =====
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

    local gui = mk(playerGui, "ScreenGui", {Name = "NovaWindow_"..name, ResetOnSpawn = false, IgnoreGuiInset = true})
    local window = mk(gui, "Frame", {Size=UDim2.new(0,340,0,260), Position=UDim2.new(0.5,-170,0.5,-130), BackgroundColor3=COLORS.uiBg, Visible=false})
    makeCorner(window,12)

    local tabsBar = mk(window, "Frame", {Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,56), BackgroundTransparency=1})
    local content = mk(window, "Frame", {Position=UDim2.new(0,12,0,96), Size=UDim2.new(1,-24,1,-120), BackgroundTransparency=1})
    local closeBtn = mk(window,"TextButton",{Size=UDim2.new(0,80,0,28), Position=UDim2.new(1,-96,0,12), BackgroundColor3=COLORS.light, Text="Close", Font=Enum.Font.GothamBold, TextColor3=COLORS.uiText})
    makeCorner(closeBtn,6)
    local hideBtn = mk(window,"TextButton",{Size=UDim2.new(0,60,0,28), Position=UDim2.new(1,-36,0,12), BackgroundColor3=Color3.fromRGB(230,230,230), Text="Hide", Font=Enum.Font.GothamBold, TextColor3=COLORS.uiText})
    makeCorner(hideBtn,6)
    local footer = mk(window,"TextLabel",{Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,1,-26), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=14, Text="coded by srfcheats", TextColor3=COLORS.uiText})

    -- Draggable window
    do
        local dragging = false
        local dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        window.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                dragStart=input.Position
                startPos=window.Position
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        window.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
        end)
        UIS.InputChanged:Connect(function(input)
            if input==dragInput and dragging then update(input) end
        end)
    end

    -- Config load
    _CONFIGS[configName] = _CONFIGS[configName] or {}
    if saveConfig and canWrite() then
        local loaded = loadConfigFile(configName)
        if loaded then _CONFIGS[configName] = loaded end
    end

    -- Tab maker
    function window:MakeTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or "Tab"
        local index = #tabsBar:GetChildren() + 1
        local btn = mk(tabsBar,"TextButton",{Size=UDim2.new(0,120,0,30), Position=UDim2.new(0,(index-1)*128,0,0), BackgroundColor3=COLORS.light, Text=tabName, Font=Enum.Font.GothamBold, TextColor3=COLORS.uiText})
        makeCorner(btn,6)
        local tabFrame = mk(content,"Frame",{Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false})

        btn.MouseButton1Click:Connect(function()
            for _,c in pairs(content:GetChildren()) do
                if c:IsA("Frame") then c.Visible=false end
            end
            tabFrame.Visible=true
        end)

        if #content:GetChildren()==0 then
            tabFrame.Visible=true
        end

        local TabAPI = {}
        return TabAPI
    end

    local API = {}
    API.Gui = gui
    API.Frame = window
    function API:Show() window.Visible=true; circleBtn.Visible=false end
    function API:Hide() window.Visible=false; circleBtn.Visible=true end
    function API:Save() if canWrite() then saveConfigFile(configName,_CONFIGS[configName] or {}) end end

    closeBtn.MouseButton1Click:Connect(function() API:Hide() end)
    hideBtn.MouseButton1Click:Connect(function() window.Visible=false; circleBtn.Visible=false end)

    return API
end

-- MainWindow tracking
local createdWindows = {}
local oldMakeWindow = NovaLib.MakeWindow
NovaLib.MakeWindow = function(self, opts)
    local win = oldMakeWindow(self, opts)
    table.insert(createdWindows, win)
    if not NovaLib.MainWindow then NovaLib.MainWindow = win end
    return win
end

-- Circle click and password logic
script._NovaUnlocked = false

circleBtn.MouseButton1Click:Connect(function()
    if script._NovaUnlocked then
        if NovaLib.MainWindow then NovaLib.MainWindow:Show() end
    else
        passwordModal.Open()
    end
end)

passwordModal.Submit.MouseButton1Click:Connect(function()
    if passwordModal.Input.Text==MASTER_PASSWORD then
        script._NovaUnlocked=true
        passwordModal.Close()
        if NovaLib.MainWindow then NovaLib.MainWindow:Show() end
    else
        passwordModal.Feedback.Text="Incorrect password!"
    end
end)

passwordModal.Cancel.MouseButton1Click:Connect(function() passwordModal.Close() end)

return NovaLib
