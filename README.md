# NovaMod Library
-- This documentation is for the stable release of NovaMod, a Roblox mod menu UI library
-- with a draggable floating button, password protection, and configurable tabs.

## Booting the Library
local NovaMod = loadstring(game:HttpGet('https://raw.githubusercontent.com/srfcheats/NovaMod/main/Library.lua'))()

## Creating a Window
local Window = NovaMod:MakeWindow({
    Name = "NovaMod Menu",
    SaveConfig = true,
    ConfigFolder = "NovaModConfig",
    Password = "NovaModsReborn"
})
--[[
Name <string> – Window title
SaveConfig <bool> – Saves UI settings
ConfigFolder <string> – Folder where config files are saved
Password <string> – Password required to open menu
]]

## Creating a Tab
local Tab = Window:MakeTab({
    Name = "Features",
    Icon = "" -- Optional, leave blank if no icon
})
--[[
Name <string> – Tab title
Icon <string> – Optional tab icon
]]

## Creating a Toggle
Tab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})
--[[
Name <string> – Label of toggle
Default <bool> – true/false
Callback <function> – Function triggered on change
]]

## Creating a Button
Tab:AddButton({
    Name = "Activate Feature",
    Callback = function()
        print("Button pressed")
    end
})
--[[
Name <string> – Label of button
Callback <function> – Function triggered on click
]]

## Creating a Slider
Tab:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    ValueName = "units",
    Callback = function(Value)
        print(Value)
    end
})
--[[
Name <string> – Slider label
Min / Max <number> – Range
Default <number> – Default value
Increment <number> – Step per drag
ValueName <string> – Text next to value
Callback <function> – Function triggered on change
]]

## Creating a Dropdown
Tab:AddDropdown({
    Name = "Select Tool",
    Default = "Pickaxe",
    Options = {"Pickaxe", "Shovel", "Drill"},
    Callback = function(Value)
        print(Value)
    end
})
--[[
Name <string> – Dropdown label
Default <string> – Default option
Options <table> – Table of options
Callback <function> – Function triggered on selection
]]

## Creating a Keybind
Tab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Callback = function()
        print("Key pressed")
    end
})
--[[
Name <string> – Label of keybind
Default <Enum.KeyCode> – Default key
Hold <bool> – If true, runs while holding key
Callback <function> – Function triggered on press
]]

## Creating a Colorpicker
Tab:AddColorpicker({
    Name = "UI Accent",
    Default = Color3.fromRGB(0,122,255),
    Callback = function(Value)
        print(Value)
    end
})
--[[
Name <string> – Label of colorpicker
Default <Color3> – Default color
Callback <function> – Function triggered on change
]]

## Creating a Textbox
Tab:AddTextbox({
    Name = "Custom Message",
    Default = "Hello!",
    TextDisappear = true,
    Callback = function(Value)
        print(Value)
    end
})
--[[
Name <string> – Label of textbox
Default <string> – Default text
TextDisappear <bool> – Text disappears after input
Callback <function> – Function triggered on input
]]

## Creating a Label
Tab:AddLabel("Current Version: 1.0.0")
--[[
Text <string> – Label text
]]

## Creating a Paragraph
Tab:AddParagraph("NovaMod Menu", "Coded by srfcheats | Blue UI, draggable, with password")
--[[
Title <string> – Paragraph title
Content <string> – Paragraph content
]]

## Initializing the UI
NovaMod:Init()
