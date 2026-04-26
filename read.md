# 💎 Emerald UI | Definitive Developer Manual

Emerald UI is a professional-grade Roblox UI library featuring high-performance animations, a sleek dark-mode aesthetic, and a powerful **Flag & State Management** system.

---

## 🚀 1. Initialization

Load the library and create your main window.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/networph/Emerald-UI/main/library.lua"))()

-- Usage: Library:Window(Title, Subtitle, Icon, Size)
local Window = Library:Window(
    "Neptune", 
    "discord.gg/neptune-hub", 
    "rbxassetid://81603686073386", 
    UDim2.fromOffset(790, 600)
)
```

---

## 📂 2. Layout Architecture

The library follows a strict hierarchy for organization:
**Window → Tab → [SubTab] → Groupbox → Elements**

### Tabs & SubTabs
- **Tabs**: Main categories on the left sidebar.
- **SubTabs**: Secondary categories at the top. 
- **Icons**: Optional for Tabs. If not provided, a default diamond icon is used.

> [!IMPORTANT]
> If a Tab contains SubTabs, you **must** add Groupboxes to the SubTab, not the main Tab.

```lua
local MainTab = Window:AddTab("Main", "rbxassetid://6034509993")
local CombatSub = MainTab:AddSubTab("Combat")

-- Adding a groupbox
local AimBox = CombatSub:AddLeftGroupbox("Aimbot")
local VisualBox = CombatSub:AddRightGroupbox("Visuals")
```

### Home Page Dashboard
You can apply a beautiful dashboard to any tab using `:ApplyHomePage()`. This is ideal for your "General" or "Home" tab.

```lua
local HomeTab = Window:AddTab("Home")
HomeTab:ApplyHomePage({
    Subtitle = "Premium Script Hub",
    StatusText = "Active",
    Version = "v1.2.4",
    Credits = {
        "Lead Developer: @networph",
        "UI Design: @grclntt",
        "Contributor: @Antigravity"
    },
    KeyInfo = {
        "License: Lifetime",
        "Expires: Never",
        "HWID: Locked"
    }
})
```
*Note: `ApplyHomePage` must be called on a tab without subtabs and before adding any groupboxes.*

---

## 🚩 3. The Flag & Options System

This system allows you to manage states globally without tracking local variables.

### Registration
When you provide a `Flag` string to an element, it is registered in:
- **`Library.Toggles`**: For standard toggles.
- **`Library.Options`**: For Sliders, Dropdowns, Inputs, Keybinds, and Colorpickers.

### Accessing Values
```lua
-- Access current value
local isEnabled = Library.Toggles["MyToggle"].Value
local fovRadius = Library.Options["AimbotFOV"].Value

-- Note: RangeSliders return a table { Min = x, Max = y }
local range = Library.Options["RenderDist"].Value
print(range.Min, range.Max)
```

### Global Methods
- **`:SetValue(val)`**: Updates the state and triggers UI updates/callbacks.
- **`:OnChanged(callback)`**: Registers a listener that fires whenever the value changes.
- **`:Get()`**: Returns the current value.

```lua
Library.Toggles["TriggerEnabled"]:OnChanged(function(state)
    print("Toggle is now:", state)
end)

-- Remote update
Library.Options["AimbotFOV"]:SetValue(120)
```

---

## 🎨 4. UI Elements Reference

### Toggles
```lua
local MyToggle = AimBox:AddToggle("AimbotEnabled", true, function(state) 
    print("Aimbot is:", state)
end)

-- Nested Widgets (Appears next to the toggle text)
MyToggle:AddColorpicker(Color3.new(1,0,0), function(color) end)
MyToggle:AddKeybind(Enum.KeyCode.E, "Hold", function(active) end)
```

### Sliders
```lua
local Slider = AimBox:AddSlider("AimbotSmoothness", 1, 100, 35, function(v) end, "%")

Slider:Set(50) -- Update value via code
```

### Range Sliders
Selects a range between two points.
```lua
local Range = AimBox:AddRangeSlider("VelocityRange", 0, 100, 20, 80, function(low, high) end, " studs")

Range:Set(10, 90) -- Update range via code
```

### Dropdowns
```lua
local Dropdown = AimBox:AddDropdown("TargetPart", {"Head", "Torso", "Random"}, "Head", function(v) end, false)

Dropdown:SetValues({"New", "Options"}) -- Dynamically update options
Dropdown:Set("Torso") -- Select value
```

### Colorpickers (Standalone)
Supports both Color3 and Transparency (0-1).
```lua
local CP = AimBox:AddColorpicker("EspColor", Color3.fromRGB(255, 255, 255), function(color, transparency) end)

CP:SetValue(Color3.new(0, 1, 0), 0.5)
```

### Keybinds (Standalone)
Modes: `"Hold"`, `"Toggle"`, `"Always"`.
```lua
local KB = AimBox:AddKeybind("MenuKey", Enum.KeyCode.RightControl, "Toggle", function(active) end)

KB:SetValue(Enum.KeyCode.F, "Hold")
```

### Inputs & Labels
```lua
local Input = AimBox:AddInput("SearchUser", "", "Enter name...", function(val) end)

Input:Set("New Text")

local Label = AimBox:AddLabel("Status: Waiting...")
Label:Set("Status: Running")
```

### Buttons & Button Rows
Add multiple buttons to the same horizontal row.
```lua
local Row = AimBox:AddButton("Save Config", function() end)
Row:AddButton("Load Config", function() end)
Row:AddButton("Reset", function() end)
```

---

## 🔔 5. Notifications & Overlays

### Notifications
Send high-quality toast notifications to the user.
```lua
Library:Notify({
    Title = "Success",
    Description = "Configuration loaded successfully!",
    Duration = 5,
    Type = "success" -- "info", "success", "warning", "error"
})
```

### Keybind List
A floating window that displays active keybinds.
```lua
Library.KeybindList:SetVisible(true)
```
Elements with flags automatically register themselves to this list when they are active or set to "Always" mode.

---

## ⚙️ 6. Configuration System

Emerald UI automatically creates a folder named `Erm` in your exploit's workspace.
- **Fonts**: `Erm/Fonts`
- **Configs**: `Erm/Configs`

To enable the config management UI:
```lua
local ConfigTab = Window:AddTab("Settings")
ConfigTab:ApplySettings()
```
This adds a comprehensive interface to:
- **Save/Overwrite**: Create new configs or update existing ones.
- **Load**: Apply config settings instantly.
- **Delete**: Remove unwanted configs.
- **Autoload**: Choose a config to load automatically on next execution.

---

## 🛠️ 7. Lifecycle & Utilities

### Unloading
Properly cleans up all connections, UI instances, and flag tables.
```lua
Library:Unload()
```

### Anonymous Mode
Hides the player's name and avatar in the Home Page dashboard.
```lua
Library.AnonymousMode = true
```

### Customizing
- **`Library:RegisterFont(Name, Url)`**: Download and use custom .ttf fonts.
- **Draggable & Resizable**: Enabled by default on the main window.
- **Smooth Scrolling**: Built-in Heartbeat-based smooth scrolling for all pages.

---

## 📋 Full Integration Example

```lua
local Library = loadstring(game:HttpGet("..."))()
local Window = Library:Window("Networph Hub", "v1.0")

local Home = Window:AddTab("Home")
Home:ApplyHomePage({ Subtitle = "Best Script" })

local Combat = Window:AddTab("Combat")
local Sec = Combat:AddLeftGroupbox("Aimbot")

Sec:AddToggle("Enable", false, function(v) end):AddKeybind(Enum.KeyCode.E)
Sec:AddSlider("FOV", 0, 500, 150, function(v) end)

local Settings = Window:AddTab("Settings")
Settings:ApplySettings()

Library:Notify({ Title = "Loaded", Description = "Welcome back!", Type = "info" })
```

---
*Made with ❤️ by Networph | Documentation by Antigravity*
