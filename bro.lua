-- ===========================
-- NovaLib Rewritten Full
-- ===========================
local NovaLib = {}
NovaLib.__index = NovaLib

-- Helper functions
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- ===========================
-- Create Window
-- ===========================
function NovaLib:CreateWindow(title, opts)
    local self = setmetatable({}, NovaLib)
    self.Tabs = {}
    self._YPos = 10

    -- Main GUI
    local ScreenGui = Create("ScreenGui",{Name = "NovaLibGUI", ResetOnSpawn = false, Parent = game:GetService("CoreGui")})
    local Frame = Create("Frame",{Size = UDim2.new(0,450,0,500), BackgroundColor3 = Color3.fromRGB(30,30,30), Parent = ScreenGui})
    local UICorner = Create("UICorner",{CornerRadius=UDim.new(0,10), Parent=Frame})
    self.Gui = ScreenGui
    self.Frame = Frame

    -- Title
    local titleLabel = Create("TextLabel",{Text=title, TextColor3=Color3.fromRGB(255,255,255), Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=Frame})

    return self
end

-- ===========================
-- Create Tab
-- ===========================
function NovaLib:CreateTab(name)
    local Tab = {}
    Tab.Elements = {}
    Tab._YPos = 10

    local Frame = Create("Frame",{Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=self.Frame})
    Tab.Frame = Frame
    Tab.Name = name

    function Tab:AddToggle(opts)
        local btn = Create("TextButton",{
            Size=UDim2.new(0,200,0,30),
            Position=UDim2.new(0,10,0,self._YPos),
            Text=opts.Name,
            BackgroundColor3=opts.Default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0),
            TextColor3=Color3.fromRGB(255,255,255),
            Parent=self.Frame
        })
        local state = opts.Default or false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
            if opts.Callback then opts.Callback(state) end
        end)
        self._YPos = self._YPos + 40
    end

    function Tab:AddButton(opts)
        local btn = Create("TextButton",{
            Size=UDim2.new(0,200,0,30),
            Position=UDim2.new(0,10,0,self._YPos),
            Text=opts.Name,
            BackgroundColor3=Color3.fromRGB(0,102,204),
            TextColor3=Color3.fromRGB(255,255,255),
            Parent=self.Frame
        })
        btn.MouseButton1Click:Connect(function()
            if opts.Callback then opts.Callback() end
        end)
        self._YPos = self._YPos + 40
    end

    function Tab:AddSlider(opts)
        local lbl = Create("TextLabel",{
            Size=UDim2.new(0,200,0,30),
            Position=UDim2.new(0,10,0,self._YPos),
            Text=opts.Name..": "..opts.Default,
            TextColor3=Color3.fromRGB(255,255,255),
            BackgroundColor3=Color3.fromRGB(50,50,50),
            Parent=self.Frame
        })
        local value = opts.Default
        lbl.MouseButton1Click:Connect(function()
            value = value + opts.Step
            if value > opts.Max then value = opts.Min end
            lbl.Text = opts.Name..": "..value
            if opts.Callback then opts.Callback(value) end
        end)
        self._YPos = self._YPos + 40
    end

    function Tab:AddTextbox(opts)
        local tb = Create("TextBox",{
            Size=UDim2.new(0,200,0,30),
            Position=UDim2.new(0,10,0,self._YPos),
            PlaceholderText=opts.Placeholder or "",
            TextColor3=Color3.fromRGB(255,255,255),
            BackgroundColor3=Color3.fromRGB(50,50,50),
            Parent=self.Frame
        })
        tb.FocusLost:Connect(function(enter)
            if enter and opts.Callback then opts.Callback(tb.Text) end
        end)
        self._YPos = self._YPos + 40
    end

    function Tab:AddColorPicker(opts)
        local btn = Create("TextButton",{
            Size=UDim2.new(0,200,0,30),
            Position=UDim2.new(0,10,0,self._YPos),
            Text=opts.Name,
            BackgroundColor3=opts.Default or Color3.fromRGB(255,255,255),
            TextColor3=Color3.fromRGB(0,0,0),
            Parent=self.Frame
        })
        btn.MouseButton1Click:Connect(function()
            local color = Color3.new(math.random(),math.random(),math.random())
            btn.BackgroundColor3 = color
            if opts.Callback then opts.Callback(color) end
        end)
        self._YPos = self._YPos + 40
    end

    function Tab:AddKeybind(opts)
        local btn = Create("TextButton",{
            Size=UDim2.new(0,200,0,30),
            Position=UDim2.new(0,10,0,self._YPos),
            Text=opts.Name..": "..(opts.Default and opts.Default.Name or "None"),
            BackgroundColor3=Color3.fromRGB(50,50,50),
            TextColor3=Color3.fromRGB(255,255,255),
            Parent=self.Frame
        })
        btn.MouseButton1Click:Connect(function()
            btn.Text = opts.Name..": ..."
            local conn
            conn = game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    btn.Text = opts.Name..": "..input.KeyCode.Name
                    if opts.Callback then opts.Callback(input.KeyCode) end
                    conn:Disconnect()
                end
            end)
        end)
        self._YPos = self._YPos + 40
    end

    function Tab:AddParagraph(text)
        local lbl = Create("TextLabel",{
            Size=UDim2.new(0,400,0,40),
            Position=UDim2.new(0,10,0,self._YPos),
            Text=text,
            TextWrapped=true,
            TextColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency=1,
            Parent=self.Frame
        })
        self._YPos = self._YPos + 50
    end

    function Tab:AddTable(opts)
        local frame = Create("Frame",{Size=UDim2.new(0,400,0,30 + #opts.Data*20), Position=UDim2.new(0,10,0,self._YPos), BackgroundColor3=Color3.fromRGB(30,30,30), Parent=self.Frame})
        local title = Create("TextLabel",{Size=UDim2.new(1,0,0,30), Text=opts.Name, TextColor3=Color3.fromRGB(255,255,255), BackgroundColor3=Color3.fromRGB(50,50,50), Parent=frame})
        for i,v in pairs(opts.Data) do
            local row = Create("TextLabel",{Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,30+(i-1)*20), Text=v, TextColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=1, Parent=frame})
        end
        self._YPos = self._YPos + frame.Size.Y.Offset + 10
    end

    table.insert(self.Tabs,Tab)
    return Tab
end

return NovaLib
