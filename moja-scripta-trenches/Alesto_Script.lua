--[[
    Alesto Script - Modern Version
    Made with ❤️ for better gaming experience
]]

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Variables
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Menu variables
local ScreenGui = nil
local MainFrame = nil
local isMenuOpen = false
local isMinimized = false
local isDragging = false
local dragStart = nil
local startPos = nil

-- Modern Configuration
local Config = {
    MenuKey = Enum.KeyCode.RightShift,
    MinimizeKey = Enum.KeyCode.M,
    DragKey = Enum.KeyCode.RightControl,
    MenuSize = UDim2.new(0, 350, 0, 450),
    MinimizedSize = UDim2.new(0, 60, 0, 35),
    MenuPosition = UDim2.new(0.5, -175, 0.5, -225),
    MinimizedPosition = UDim2.new(1, -70, 0, 10),
    Colors = {
        Primary = Color3.fromRGB(45, 45, 45),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 150, 255),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 150, 0),
        Error = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200)
    }
}

-- Feature states
local Features = {
    Aimbot = false,
    ESP = false,
    Speed = false,
    Jump = false,
    Fly = false,
    NoClip = false,
    InfiniteJump = false,
    AntiAim = false
}

-- Modern Color Palette
local AccentOn = Color3.fromRGB(255, 79, 203) -- Roza za uključeno
local AccentOff = Color3.fromRGB(60, 60, 60)  -- Siva za isključeno
local SectionBG = Color3.fromRGB(30, 30, 30)
local PanelBG = Color3.fromRGB(18, 18, 18)
local TextColor = Color3.fromRGB(240, 240, 240)

-- Destroy old GUI if exists
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlestoScript"
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = game:GetService("CoreGui")

MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 520)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
MainFrame.BackgroundColor3 = PanelBG
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 18)

-- Tabovi
local Tabs = {"Combat", "ESP", "Info"}
local TabFrames = {}
local SelectedTab = "Combat"
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -32, 0, 48)
TabBar.Position = UDim2.new(0, 16, 0, 16)
TabBar.BackgroundTransparency = 1
TabBar.BorderSizePixel = 0

for i, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size = UDim2.new(0, 110, 0, 38)
    TabBtn.Position = UDim2.new(0, (i-1)*120, 0, 0)
    TabBtn.BackgroundColor3 = (SelectedTab == tabName) and AccentOn or AccentOff
    TabBtn.Text = tabName
    TabBtn.TextColor3 = TextColor
    TabBtn.TextScaled = true
    TabBtn.Font = Enum.Font.GothamBold
    local TabCorner = Instance.new("UICorner", TabBtn)
    TabCorner.CornerRadius = UDim.new(0, 12)
    TabBtn.MouseButton1Click:Connect(function()
        SelectedTab = tabName
        for _, btn in pairs(TabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Text == SelectedTab) and AccentOn or AccentOff
            end
        end
        for name, frame in pairs(TabFrames) do
            frame.Visible = (name == SelectedTab)
        end
    end)
end

-- Sekcija: Combat (prva faza, Hitbox)
local CombatFrame = Instance.new("Frame", MainFrame)
CombatFrame.Size = UDim2.new(1, -32, 1, -80)
CombatFrame.Position = UDim2.new(0, 16, 0, 72)
CombatFrame.BackgroundColor3 = SectionBG
CombatFrame.BorderSizePixel = 0
local CombatCorner = Instance.new("UICorner", CombatFrame)
CombatCorner.CornerRadius = UDim.new(0, 14)
TabFrames["Combat"] = CombatFrame

-- Hitbox sekcija
local HitboxLabel = Instance.new("TextLabel", CombatFrame)
HitboxLabel.Size = UDim2.new(0, 120, 0, 32)
HitboxLabel.Position = UDim2.new(0, 16, 0, 18)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "Hitbox"
HitboxLabel.TextColor3 = TextColor
HitboxLabel.TextScaled = true
HitboxLabel.Font = Enum.Font.GothamBold

-- Moderni toggle
local HitboxToggle = Instance.new("TextButton", CombatFrame)
HitboxToggle.Size = UDim2.new(0, 60, 0, 32)
HitboxToggle.Position = UDim2.new(0, 150, 0, 18)
HitboxToggle.BackgroundColor3 = AccentOff
HitboxToggle.Text = "OFF"
HitboxToggle.TextColor3 = TextColor
HitboxToggle.TextScaled = true
HitboxToggle.Font = Enum.Font.GothamBold
local ToggleCorner = Instance.new("UICorner", HitboxToggle)
ToggleCorner.CornerRadius = UDim.new(0, 10)

local hitboxOn = false
HitboxToggle.MouseButton1Click:Connect(function()
    hitboxOn = not hitboxOn
    HitboxToggle.BackgroundColor3 = hitboxOn and AccentOn or AccentOff
    HitboxToggle.Text = hitboxOn and "ON" or "OFF"
end)

-- Moderni slider
local SliderFrame = Instance.new("Frame", CombatFrame)
SliderFrame.Size = UDim2.new(0, 260, 0, 38)
SliderFrame.Position = UDim2.new(0, 16, 0, 70)
SliderFrame.BackgroundTransparency = 1
local SliderBar = Instance.new("Frame", SliderFrame)
SliderBar.Size = UDim2.new(0, 200, 0, 8)
SliderBar.Position = UDim2.new(0, 0, 0.5, -4)
SliderBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
SliderBar.BorderSizePixel = 0
local SliderBarCorner = Instance.new("UICorner", SliderBar)
SliderBarCorner.CornerRadius = UDim.new(0, 4)
SliderBar.Parent = SliderFrame
local SliderKnob = Instance.new("Frame", SliderFrame)
SliderKnob.Size = UDim2.new(0, 18, 0, 18)
SliderKnob.Position = UDim2.new(0, 0, 0.5, -9)
SliderKnob.BackgroundColor3 = AccentOn
SliderKnob.BorderSizePixel = 0
local KnobCorner = Instance.new("UICorner", SliderKnob)
KnobCorner.CornerRadius = UDim.new(1, 0)
local dragging = false
local minValue, maxValue = 0.1, 6
local hitboxValue = 1
local ValueLabel = Instance.new("TextLabel", SliderFrame)
ValueLabel.Size = UDim2.new(0, 40, 0, 24)
ValueLabel.Position = UDim2.new(0, 210, 0, -8)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = tostring(hitboxValue)
ValueLabel.TextColor3 = AccentOn
ValueLabel.TextScaled = true
ValueLabel.Font = Enum.Font.GothamBold
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
SliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        hitboxValue = minValue + (maxValue - minValue) * rel
        SliderKnob.Position = UDim2.new(rel, 0, 0.5, -9)
        ValueLabel.Text = string.format("%.1f", hitboxValue)
    end
end)

-- Moderni color picker (kvadrat + RGB/HEX input)
local ColorPickerFrame = Instance.new("Frame", CombatFrame)
ColorPickerFrame.Size = UDim2.new(0, 180, 0, 90)
ColorPickerFrame.Position = UDim2.new(0, 16, 0, 130)
ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
ColorPickerFrame.BorderSizePixel = 0
local PickerCorner = Instance.new("UICorner", ColorPickerFrame)
PickerCorner.CornerRadius = UDim.new(0, 10)
-- (Ovde ide custom kvadrat za biranje boje, RGB i HEX input, placeholder za sad)
local PickerLabel = Instance.new("TextLabel", ColorPickerFrame)
PickerLabel.Size = UDim2.new(1, 0, 0, 20)
PickerLabel.Position = UDim2.new(0, 0, 0, 0)
PickerLabel.BackgroundTransparency = 1
PickerLabel.Text = "Hitbox color (modern picker soon)"
PickerLabel.TextColor3 = TextColor
PickerLabel.TextScaled = true
PickerLabel.Font = Enum.Font.Gotham

-- ESP sekcija
local ESPFrame = Instance.new("Frame", MainFrame)
ESPFrame.Size = UDim2.new(1, -32, 1, -80)
ESPFrame.Position = UDim2.new(0, 16, 0, 72)
ESPFrame.BackgroundColor3 = SectionBG
ESPFrame.BorderSizePixel = 0
ESPFrame.Visible = false
local ESPCorner = Instance.new("UICorner", ESPFrame)
ESPCorner.CornerRadius = UDim.new(0, 14)
TabFrames["ESP"] = ESPFrame

-- ESP Toggle
local ESPLabel = Instance.new("TextLabel", ESPFrame)
ESPLabel.Size = UDim2.new(0, 120, 0, 32)
ESPLabel.Position = UDim2.new(0, 16, 0, 18)
ESPLabel.BackgroundTransparency = 1
ESPLabel.Text = "ESP"
ESPLabel.TextColor3 = TextColor
ESPLabel.TextScaled = true
ESPLabel.Font = Enum.Font.GothamBold

local ESPToggle = Instance.new("TextButton", ESPFrame)
ESPToggle.Size = UDim2.new(0, 60, 0, 32)
ESPToggle.Position = UDim2.new(0, 150, 0, 18)
ESPToggle.BackgroundColor3 = AccentOff
ESPToggle.Text = "OFF"
ESPToggle.TextColor3 = TextColor
ESPToggle.TextScaled = true
ESPToggle.Font = Enum.Font.GothamBold
local ESPToggleCorner = Instance.new("UICorner", ESPToggle)
ESPToggleCorner.CornerRadius = UDim.new(0, 10)

local espOn = false
ESPToggle.MouseButton1Click:Connect(function()
    espOn = not espOn
    ESPToggle.BackgroundColor3 = espOn and AccentOn or AccentOff
    ESPToggle.Text = espOn and "ON" or "OFF"
end)

-- ESP scale slider
local ESPScaleFrame = Instance.new("Frame", ESPFrame)
ESPScaleFrame.Size = UDim2.new(0, 260, 0, 38)
ESPScaleFrame.Position = UDim2.new(0, 16, 0, 70)
ESPScaleFrame.BackgroundTransparency = 1
local ESPScaleBar = Instance.new("Frame", ESPScaleFrame)
ESPScaleBar.Size = UDim2.new(0, 200, 0, 8)
ESPScaleBar.Position = UDim2.new(0, 0, 0.5, -4)
ESPScaleBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
ESPScaleBar.BorderSizePixel = 0
local ESPScaleBarCorner = Instance.new("UICorner", ESPScaleBar)
ESPScaleBarCorner.CornerRadius = UDim.new(0, 4)
ESPScaleBar.Parent = ESPScaleFrame
local ESPScaleKnob = Instance.new("Frame", ESPScaleFrame)
ESPScaleKnob.Size = UDim2.new(0, 18, 0, 18)
ESPScaleKnob.Position = UDim2.new(0, 0, 0.5, -9)
ESPScaleKnob.BackgroundColor3 = AccentOn
ESPScaleKnob.BorderSizePixel = 0
local ESPKnobCorner = Instance.new("UICorner", ESPScaleKnob)
ESPKnobCorner.CornerRadius = UDim.new(1, 0)
local espDragging = false
local espMin, espMax = 0.1, 3
local espScale = 1
local ESPValueLabel = Instance.new("TextLabel", ESPScaleFrame)
ESPValueLabel.Size = UDim2.new(0, 40, 0, 24)
ESPValueLabel.Position = UDim2.new(0, 210, 0, -8)
ESPValueLabel.BackgroundTransparency = 1
ESPValueLabel.Text = tostring(espScale)
ESPValueLabel.TextColor3 = AccentOn
ESPValueLabel.TextScaled = true
ESPValueLabel.Font = Enum.Font.GothamBold
ESPScaleKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then espDragging = true end
end)
ESPScaleKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then espDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if espDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - ESPScaleBar.AbsolutePosition.X) / ESPScaleBar.AbsoluteSize.X, 0, 1)
        espScale = math.floor((espMin + (espMax-espMin)*rel)*10)/10
        ESPScaleKnob.Position = UDim2.new(0, rel*200-9, 0.5, -9)
        ESPValueLabel.Text = tostring(espScale)
    end
end)

-- Bindovi sekcija (ispod u Combat tabu)
local BindsFrame = Instance.new("Frame", CombatFrame)
BindsFrame.Size = UDim2.new(0, 180, 0, 110)
BindsFrame.Position = UDim2.new(0, 220, 0, 18)
BindsFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
BindsFrame.BorderSizePixel = 0
local BindsCorner = Instance.new("UICorner", BindsFrame)
BindsCorner.CornerRadius = UDim.new(0, 10)
local BindsLabel = Instance.new("TextLabel", BindsFrame)
BindsLabel.Size = UDim2.new(1, 0, 0, 20)
BindsLabel.Position = UDim2.new(0, 0, 0, 0)
BindsLabel.BackgroundTransparency = 1
BindsLabel.Text = "Bindovi"
BindsLabel.TextColor3 = TextColor
BindsLabel.TextScaled = true
BindsLabel.Font = Enum.Font.GothamBold

-- ESP bind
table.insert(_G or getgenv and getgenv() or {}, {ESPBind = Enum.KeyCode.F})
local ESPBindBtn = Instance.new("TextButton", BindsFrame)
ESPBindBtn.Size = UDim2.new(0, 120, 0, 28)
ESPBindBtn.Position = UDim2.new(0, 20, 0, 30)
ESPBindBtn.BackgroundColor3 = AccentOff
ESPBindBtn.Text = "ESP: F"
ESPBindBtn.TextColor3 = TextColor
ESPBindBtn.TextScaled = true
ESPBindBtn.Font = Enum.Font.Gotham
local ESPBindCorner = Instance.new("UICorner", ESPBindBtn)
ESPBindCorner.CornerRadius = UDim.new(0, 8)
ESPBindBtn.MouseButton1Click:Connect(function()
    ESPBindBtn.Text = "ESP: ..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            ESPBindBtn.Text = "ESP: "..input.KeyCode.Name
            _G.ESPBind = input.KeyCode
            conn:Disconnect()
        end
    end)
end)

-- Hitbox bind
table.insert(_G or getgenv and getgenv() or {}, {HitboxBind = Enum.KeyCode.H})
local HitboxBindBtn = Instance.new("TextButton", BindsFrame)
HitboxBindBtn.Size = UDim2.new(0, 120, 0, 28)
HitboxBindBtn.Position = UDim2.new(0, 20, 0, 68)
HitboxBindBtn.BackgroundColor3 = AccentOff
HitboxBindBtn.Text = "Hitbox: H"
HitboxBindBtn.TextColor3 = TextColor
HitboxBindBtn.TextScaled = true
HitboxBindBtn.Font = Enum.Font.Gotham
local HitboxBindCorner = Instance.new("UICorner", HitboxBindBtn)
HitboxBindCorner.CornerRadius = UDim.new(0, 8)
HitboxBindBtn.MouseButton1Click:Connect(function()
    HitboxBindBtn.Text = "Hitbox: ..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            HitboxBindBtn.Text = "Hitbox: "..input.KeyCode.Name
            _G.HitboxBind = input.KeyCode
            conn:Disconnect()
        end
    end)
end)

-- Nametag (Imena) bind
table.insert(_G or getgenv and getgenv() or {}, {NametagBind = Enum.KeyCode.N})
local NametagBindBtn = Instance.new("TextButton", BindsFrame)
NametagBindBtn.Size = UDim2.new(0, 120, 0, 28)
NametagBindBtn.Position = UDim2.new(0, 20, 0, 106)
NametagBindBtn.BackgroundColor3 = AccentOff
NametagBindBtn.Text = "Imena: N"
NametagBindBtn.TextColor3 = TextColor
NametagBindBtn.TextScaled = true
NametagBindBtn.Font = Enum.Font.Gotham
local NametagBindCorner = Instance.new("UICorner", NametagBindBtn)
NametagBindCorner.CornerRadius = UDim.new(0, 8)
NametagBindBtn.MouseButton1Click:Connect(function()
    NametagBindBtn.Text = "Imena: ..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            NametagBindBtn.Text = "Imena: "..input.KeyCode.Name
            _G.NametagBind = input.KeyCode
            conn:Disconnect()
        end
    end)
end)

-- Wallshot (Krozzid) bind
table.insert(_G or getgenv and getgenv() or {}, {WallshotBind = Enum.KeyCode.Z})
local WallshotBindBtn = Instance.new("TextButton", BindsFrame)
WallshotBindBtn.Size = UDim2.new(0, 120, 0, 28)
WallshotBindBtn.Position = UDim2.new(0, 20, 0, 144)
WallshotBindBtn.BackgroundColor3 = AccentOff
WallshotBindBtn.Text = "Krozzid: Z"
WallshotBindBtn.TextColor3 = TextColor
WallshotBindBtn.TextScaled = true
WallshotBindBtn.Font = Enum.Font.Gotham
local WallshotBindCorner = Instance.new("UICorner", WallshotBindBtn)
WallshotBindCorner.CornerRadius = UDim.new(0, 8)
WallshotBindBtn.MouseButton1Click:Connect(function()
    WallshotBindBtn.Text = "Krozzid: ..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            WallshotBindBtn.Text = "Krozzid: "..input.KeyCode.Name
            _G.WallshotBind = input.KeyCode
            conn:Disconnect()
        end
    end)
end)

-- Prikaz samo aktivnog taba
for name, frame in pairs(TabFrames) do
    frame.Visible = (name == SelectedTab)
end

-- Create modern UI components
local function createModernButton(parent, text, position, size, callback)
    local Button = Instance.new("TextButton")
    Button.Name = text .. "Button"
    Button.Size = size or UDim2.new(1, -20, 0, 45)
    Button.Position = position
    Button.BackgroundColor3 = Config.Colors.Primary
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Config.Colors.Text
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    Button.Parent = parent
    
    -- Modern corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    -- Gradient effect
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Colors.Primary),
        ColorSequenceKeypoint.new(1, Config.Colors.Secondary)
    })
    Gradient.Parent = Button
    
    -- Click effect
    Button.MouseButton1Click:Connect(function()
        -- Click animation
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = size and (size + UDim2.new(0, -5, 0, -5)) or UDim2.new(1, -25, 0, 40)
        }):Play()
        
        wait(0.1)
        
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = size or UDim2.new(1, -20, 0, 45)
        }):Play()
        
        if callback then
            callback()
        end
    end)
    
    -- Hover effects
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Colors.Accent
        }):Play()
        TweenService:Create(Gradient, TweenInfo.new(0.2), {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Config.Colors.Accent),
                ColorSequenceKeypoint.new(1, Config.Colors.Secondary)
            })
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Colors.Primary
        }):Play()
        TweenService:Create(Gradient, TweenInfo.new(0.2), {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Config.Colors.Primary),
                ColorSequenceKeypoint.new(1, Config.Colors.Secondary)
            })
        }):Play()
    end)
    
    return Button
end

-- Create the main menu
local function createMenu()
    if ScreenGui then ScreenGui:Destroy() end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AlestoScript"
    ScreenGui.DisplayOrder = 1000
    ScreenGui.Parent = game:GetService("CoreGui")
    
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Config.MenuSize
    MainFrame.Position = Config.MenuPosition
    MainFrame.BackgroundColor3 = Config.Colors.Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Modern corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Title bar with gradient
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Config.Colors.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Title gradient
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Colors.Accent),
        ColorSequenceKeypoint.new(1, Config.Colors.Secondary)
    })
    TitleGradient.Parent = TitleBar
    
    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "Alesto Script"
    TitleText.TextColor3 = Config.Colors.Text
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Parent = TitleBar
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Config.Colors.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Config.Colors.Text
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        if ScreenGui then ScreenGui:Destroy() end
        isMenuOpen = false
    end)
    
    -- Content frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Scroll frame for buttons
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    ScrollFrame.Parent = ContentFrame
    
    -- Create feature buttons
    local buttonY = 10
    local buttonSpacing = 55
    
    -- Aimbot Button
    createModernButton(ScrollFrame, "Aimbot", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.Aimbot = not Features.Aimbot
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "Aimbot: " .. (Features.Aimbot and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- ESP Button
    createModernButton(ScrollFrame, "ESP", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.ESP = not Features.ESP
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "ESP: " .. (Features.ESP and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- Speed Button
    createModernButton(ScrollFrame, "Speed", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.Speed = not Features.Speed
        if Features.Speed then
            Humanoid.WalkSpeed = 50
        else
            Humanoid.WalkSpeed = 16
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "Speed: " .. (Features.Speed and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- Jump Button
    createModernButton(ScrollFrame, "Jump", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.Jump = not Features.Jump
        if Features.Jump then
            Humanoid.JumpPower = 100
        else
            Humanoid.JumpPower = 50
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "Jump: " .. (Features.Jump and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- Fly Button
    createModernButton(ScrollFrame, "Fly", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.Fly = not Features.Fly
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "Fly: " .. (Features.Fly and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- NoClip Button
    createModernButton(ScrollFrame, "NoClip", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.NoClip = not Features.NoClip
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "NoClip: " .. (Features.NoClip and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- Infinite Jump Button
    createModernButton(ScrollFrame, "Infinite Jump", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.InfiniteJump = not Features.InfiniteJump
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "Infinite Jump: " .. (Features.InfiniteJump and "ON" or "OFF"),
            Duration = 2
        })
    end)
    buttonY = buttonY + buttonSpacing
    
    -- Anti Aim Button
    createModernButton(ScrollFrame, "Anti Aim", UDim2.new(0, 0, 0, buttonY), nil, function()
        Features.AntiAim = not Features.AntiAim
        game.StarterGui:SetCore("SendNotification", {
            Title = "Alesto",
            Text = "Anti Aim: " .. (Features.AntiAim and "ON" or "OFF"),
            Duration = 2
        })
    end)
    
    -- Dragging functionality
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local connection
            connection = input.Changed:Connect(function()
                if not isDragging then
                    connection:Disconnect()
                else
                    updateDrag(input)
                end
            end)
        end
    end)
end

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.MenuKey then
        if not isMenuOpen then
            MainFrame.Visible = true
            isMenuOpen = true
        else
            MainFrame.Visible = false
            isMenuOpen = false
        end
    end
end)

-- Initialize
createMenu()
isMenuOpen = true

-- Success notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Alesto Script",
    Text = "Loaded successfully! Press RightShift to toggle menu",
    Duration = 5
}) 