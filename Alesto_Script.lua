pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Alesto Script",
        Text = "Skripta je uspješno pokrenuta!",
        Duration = 5
    })
end)
--[[
    script by Alesto
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local FOV_MIN = 20
local FOV_MAX = 120
local FOV_DEFAULT = 70
local currentFOV = FOV_DEFAULT

-- Hitbox FOV range
local HITBOX_FOV_MIN = 1
local HITBOX_FOV_MAX = 200

-- Random string generator
local function randStr(len)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local s = ''
    for i = 1, len do
        local r = math.random(1, #chars)
        s = s .. chars:sub(r, r)
    end
    return s
end

math.randomseed(tick()*1000)

-- Random parent: CoreGui ili PlayerGui
local parentGui = game:GetService("CoreGui")

-- Config
local Config = {}
Config.Colors = {
    Primary = Color3.fromRGB(24, 24, 32),
    Secondary = Color3.fromRGB(32, 32, 44),
    Accent = Color3.fromRGB(255, 20, 147), -- Pink accent color
    Text = Color3.fromRGB(255, 255, 255),
    Minimized = Color3.fromRGB(40, 40, 50),
    Section = Color3.fromRGB(36, 36, 48),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    Slider = Color3.fromRGB(60, 60, 80),
    SliderBar = Color3.fromRGB(255, 20, 147)
}

-- Add missing config variables
Config.MenuPosition = UDim2.new(0.5, -275, 0.5, -400)
Config.MenuKey = Enum.KeyCode.RightShift
Config.MinimizedSize = UDim2.new(0, 50, 0, 50)
Config.MinimizedPosition = UDim2.new(0, 10, 0, 10)

local isMenuOpen = true
local isMinimized = false

-- State for features
local VIZIJA_ENABLED = false
local VIZIJA_COLOR = Color3.fromRGB(255, 20, 147)
local VIZIJA_ENEMY_ONLY = true
local FORCE_RENDER = true -- Uvijek renderuj igrače
local vizijaBoxes = {}

-- Hitbox opcije
local META_HEAD = false
local META_TORSO = false
local META_HEAD_FOV = 6
local META_TORSO_FOV = 6
local HITBOX_HEAD_COLOR = Color3.fromRGB(255, 0, 0)
local HITBOX_TORSO_COLOR = Color3.fromRGB(0, 255, 0)

-- Nametag opcije
local NAMETAG_ENABLED = false
local NAMETAG_SCALE = 1.5

-- Crosshair opcije
local CROSSHAIR_ENABLED = false
local CROSSHAIR_COLOR = Color3.fromRGB(255, 255, 255)

-- Random names
local guiName = "UI_"..randStr(4)
local frameName = "Panel_"..randStr(4)
local miniName = "Mini_"..randStr(4)

-- GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = parentGui
print("GUI parentan")

local MainFrame = Instance.new("Frame")
MainFrame.Name = frameName
-- MainFrame size - smanjeno da stane na ekran
MainFrame.Size = UDim2.new(0, 600, 0, 750)
Config.MenuPosition = UDim2.new(0.5, -300, 0.5, -375)
MainFrame.Position = Config.MenuPosition
MainFrame.BackgroundColor3 = Config.Colors.Primary
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 16)

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Name = "Bar_"..randStr(3)
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Config.Colors.Secondary
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Alesto Panel"
Title.TextColor3 = Config.Colors.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- Window Controls
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -30, 0.5, -12)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Config.Colors.Text
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Config.Colors.Text
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold

-- Minimize/Maximize functionality
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Minimize
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = Config.MinimizedSize,
            Position = Config.MinimizedPosition
        }):Play()
        MinimizeBtn.Text = "+"
    else
        -- Maximize
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 600, 0, 750),
            Position = Config.MenuPosition
        }):Play()
        MinimizeBtn.Text = "-"
    end
end)

-- Close functionality
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tabs
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(1, 0, 0, 48)
TabsFrame.Position = UDim2.new(0, 0, 0, 48)
TabsFrame.BackgroundColor3 = Config.Colors.Secondary
TabsFrame.BorderSizePixel = 0
local TabsCorner = Instance.new("UICorner", TabsFrame)
TabsCorner.CornerRadius = UDim.new(0, 16)

local CombatTab = Instance.new("TextButton", TabsFrame)
CombatTab.Size = UDim2.new(0.5, -2, 1, 0)
CombatTab.Position = UDim2.new(0, 0, 0, 0)
CombatTab.BackgroundColor3 = Config.Colors.Accent
CombatTab.Text = "Combat"
CombatTab.TextColor3 = Config.Colors.Text
CombatTab.TextSize = 14
CombatTab.Font = Enum.Font.GothamBold
local CombatTabCorner = Instance.new("UICorner", CombatTab)
CombatTabCorner.CornerRadius = UDim.new(0, 12)

local VizijaTab = Instance.new("TextButton", TabsFrame)
VizijaTab.Size = UDim2.new(0.5, -2, 1, 0)
VizijaTab.Position = UDim2.new(0.5, 2, 0, 0)
VizijaTab.BackgroundColor3 = Config.Colors.Secondary
VizijaTab.Text = "Vizija"
VizijaTab.TextColor3 = Config.Colors.Text
VizijaTab.TextSize = 14
VizijaTab.Font = Enum.Font.GothamBold
local VizijaTabCorner = Instance.new("UICorner", VizijaTab)
VizijaTabCorner.CornerRadius = UDim.new(0, 12)

-- Content Sections

local CombatSection = Instance.new("Frame", MainFrame)
CombatSection.Name = "CombatSection"
-- CombatSection i VizijaSection size
CombatSection.Size = UDim2.new(1, -40, 1, -140)
CombatSection.Position = UDim2.new(0, 20, 0, 100)
CombatSection.BackgroundColor3 = Config.Colors.Section
CombatSection.BorderSizePixel = 0
local CombatSectionCorner = Instance.new("UICorner", CombatSection)
CombatSectionCorner.CornerRadius = UDim.new(0, 16)

local VizijaSection = Instance.new("Frame", MainFrame)
VizijaSection.Name = "VizijaSection"
-- CombatSection i VizijaSection size
VizijaSection.Size = UDim2.new(1, -40, 1, -140)
VizijaSection.Position = UDim2.new(0, 20, 0, 100)
VizijaSection.BackgroundColor3 = Config.Colors.Section
VizijaSection.BorderSizePixel = 0
local VizijaSectionCorner = Instance.new("UICorner", VizijaSection)
VizijaSectionCorner.CornerRadius = UDim.new(0, 16)
VizijaSection.Visible = false

-- Tab switching with animations and hover effects
local function addTabHoverEffects(tab)
    tab.MouseEnter:Connect(function()
        if tab.BackgroundColor3 ~= Config.Colors.Accent then
            TweenService:Create(tab, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            }):Play()
        end
    end)
    
    tab.MouseLeave:Connect(function()
        if tab.BackgroundColor3 ~= Config.Colors.Accent then
            TweenService:Create(tab, TweenInfo.new(0.2), {
                BackgroundColor3 = Config.Colors.Secondary
            }):Play()
        end
    end)
end

addTabHoverEffects(CombatTab)
addTabHoverEffects(VizijaTab)

CombatTab.MouseButton1Click:Connect(function()
    -- Animate tab colors with bounce effect
    TweenService:Create(CombatTab, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = Config.Colors.Accent}):Play()
    TweenService:Create(VizijaTab, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = Config.Colors.Secondary}):Play()
    
    CombatSection.Visible = true
    VizijaSection.Visible = false
end)

VizijaTab.MouseButton1Click:Connect(function()
    -- Animate tab colors with bounce effect
    TweenService:Create(CombatTab, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = Config.Colors.Secondary}):Play()
    TweenService:Create(VizijaTab, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = Config.Colors.Accent}):Play()
    
    CombatSection.Visible = false
    VizijaSection.Visible = true
end)



-- Combat Section Content
-- Povećaj Glavudju Section
local HeadHitboxSection = Instance.new("Frame", CombatSection)
HeadHitboxSection.Size = UDim2.new(1, -40, 0, 160)
HeadHitboxSection.Position = UDim2.new(0, 20, 0, 20)
HeadHitboxSection.BackgroundColor3 = Config.Colors.Primary
HeadHitboxSection.BorderSizePixel = 0
local HeadHitboxSectionCorner = Instance.new("UICorner", HeadHitboxSection)
HeadHitboxSectionCorner.CornerRadius = UDim.new(0, 12)

local HeadHitboxLabel = Instance.new("TextLabel", HeadHitboxSection)
HeadHitboxLabel.Size = UDim2.new(1, 0, 0, 30)
HeadHitboxLabel.Position = UDim2.new(0, 16, 0, 8)
HeadHitboxLabel.BackgroundTransparency = 1
HeadHitboxLabel.Text = "Povećaj Glavudju"
HeadHitboxLabel.TextColor3 = Config.Colors.Text
HeadHitboxLabel.TextScaled = true
HeadHitboxLabel.Font = Enum.Font.GothamBold
HeadHitboxLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Head Hitbox Toggle
local HeadHitboxToggle = Instance.new("TextButton", HeadHitboxSection)
HeadHitboxToggle.Size = UDim2.new(0, 50, 0, 25)
HeadHitboxToggle.Position = UDim2.new(1, -66, 0, 8)
HeadHitboxToggle.BackgroundColor3 = Config.Colors.ToggleOff
HeadHitboxToggle.Text = ""
local HeadHitboxToggleCorner = Instance.new("UICorner", HeadHitboxToggle)
HeadHitboxToggleCorner.CornerRadius = UDim.new(0, 12)

local HeadHitboxToggleKnob = Instance.new("Frame", HeadHitboxToggle)
HeadHitboxToggleKnob.Size = UDim2.new(0, 21, 0, 21)
HeadHitboxToggleKnob.Position = UDim2.new(0, 2, 0, 2)
HeadHitboxToggleKnob.BackgroundColor3 = Config.Colors.Text
local HeadHitboxToggleKnobCorner = Instance.new("UICorner", HeadHitboxToggleKnob)
HeadHitboxToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Head FOV Slider
local HeadFOVLabel = Instance.new("TextLabel", HeadHitboxSection)
HeadFOVLabel.Size = UDim2.new(1, 0, 0, 20)
HeadFOVLabel.Position = UDim2.new(0, 16, 0, 45)
HeadFOVLabel.BackgroundTransparency = 1
HeadFOVLabel.Text = "FOV Glavudje"
HeadFOVLabel.TextColor3 = Config.Colors.Text
HeadFOVLabel.TextScaled = true
HeadFOVLabel.Font = Enum.Font.Gotham
HeadFOVLabel.TextXAlignment = Enum.TextXAlignment.Left

local HeadFOVSlider = Instance.new("Frame", HeadHitboxSection)
HeadFOVSlider.Size = UDim2.new(0, 120, 0, 6)
HeadFOVSlider.Position = UDim2.new(1, -140, 0, 50)
HeadFOVSlider.BackgroundColor3 = Config.Colors.Slider
local HeadFOVSliderCorner = Instance.new("UICorner", HeadFOVSlider)
HeadFOVSliderCorner.CornerRadius = UDim.new(0, 3)

local HeadFOVSliderBar = Instance.new("Frame", HeadFOVSlider)
HeadFOVSliderBar.Size = UDim2.new(0.5, 0, 1, 0)
HeadFOVSliderBar.Position = UDim2.new(0, 0, 0, 0)
HeadFOVSliderBar.BackgroundColor3 = Config.Colors.SliderBar
local HeadFOVSliderBarCorner = Instance.new("UICorner", HeadFOVSliderBar)
HeadFOVSliderBarCorner.CornerRadius = UDim.new(0, 3)

local HeadFOVValue = Instance.new("TextLabel", HeadHitboxSection)
HeadFOVValue.Size = UDim2.new(0, 40, 0, 20)
HeadFOVValue.Position = UDim2.new(1, -50, 0, 45)
HeadFOVValue.BackgroundTransparency = 1
HeadFOVValue.Text = tostring(META_HEAD_FOV)
HeadFOVValue.TextColor3 = Config.Colors.Text
HeadFOVValue.TextScaled = true
HeadFOVValue.Font = Enum.Font.Gotham
HeadFOVValue.TextXAlignment = Enum.TextXAlignment.Center

-- Head Color Section
local HeadColorLabel = Instance.new("TextLabel", HeadHitboxSection)
HeadColorLabel.Size = UDim2.new(1, 0, 0, 20)
HeadColorLabel.Position = UDim2.new(0, 16, 0, 80)
HeadColorLabel.BackgroundTransparency = 1
HeadColorLabel.Text = "Boja Glavudje"
HeadColorLabel.TextColor3 = Config.Colors.Text
HeadColorLabel.TextScaled = true
HeadColorLabel.Font = Enum.Font.Gotham
HeadColorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Head RGB Inputs
local HeadRInput = Instance.new("TextBox", HeadHitboxSection)
HeadRInput.Size = UDim2.new(0, 40, 0, 20)
HeadRInput.Position = UDim2.new(1, -140, 0, 80)
HeadRInput.BackgroundColor3 = Config.Colors.Secondary
HeadRInput.Text = "255"
HeadRInput.TextColor3 = Config.Colors.Text
HeadRInput.TextScaled = true
HeadRInput.Font = Enum.Font.Gotham
local HeadRInputCorner = Instance.new("UICorner", HeadRInput)
HeadRInputCorner.CornerRadius = UDim.new(0, 6)

local HeadGInput = Instance.new("TextBox", HeadHitboxSection)
HeadGInput.Size = UDim2.new(0, 40, 0, 20)
HeadGInput.Position = UDim2.new(1, -95, 0, 80)
HeadGInput.BackgroundColor3 = Config.Colors.Secondary
HeadGInput.Text = "0"
HeadGInput.TextColor3 = Config.Colors.Text
HeadGInput.TextScaled = true
HeadGInput.Font = Enum.Font.Gotham
local HeadGInputCorner = Instance.new("UICorner", HeadGInput)
HeadGInputCorner.CornerRadius = UDim.new(0, 6)

local HeadBInput = Instance.new("TextBox", HeadHitboxSection)
HeadBInput.Size = UDim2.new(0, 40, 0, 20)
HeadBInput.Position = UDim2.new(1, -50, 0, 80)
HeadBInput.BackgroundColor3 = Config.Colors.Secondary
HeadBInput.Text = "0"
HeadBInput.TextColor3 = Config.Colors.Text
HeadBInput.TextScaled = true
HeadBInput.Font = Enum.Font.Gotham
local HeadBInputCorner = Instance.new("UICorner", HeadBInput)
HeadBInputCorner.CornerRadius = UDim.new(0, 6)

-- Head Color Picker (Modern)
local HeadColorPicker = Instance.new("Frame", HeadHitboxSection)
HeadColorPicker.Size = UDim2.new(0, 60, 0, 60)
HeadColorPicker.Position = UDim2.new(1, -80, 0, 100)
HeadColorPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
local HeadColorPickerCorner = Instance.new("UICorner", HeadColorPicker)
HeadColorPickerCorner.CornerRadius = UDim.new(0, 8)

-- Head Color Picker Gradient (Full spectrum)
local HeadColorGradient = Instance.new("UIGradient", HeadColorPicker)
HeadColorGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
HeadColorGradient.Rotation = 0

-- Head Color Picker Cursor
local HeadColorCursor = Instance.new("Frame", HeadColorPicker)
HeadColorCursor.Size = UDim2.new(0, 8, 0, 8)
HeadColorCursor.Position = UDim2.new(0.8, -4, 0.2, -4)
HeadColorCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local HeadColorCursorCorner = Instance.new("UICorner", HeadColorCursor)
HeadColorCursorCorner.CornerRadius = UDim.new(0, 4)

-- Povećaj Tijelo Section
local BodyHitboxSection = Instance.new("Frame", CombatSection)
BodyHitboxSection.Size = UDim2.new(1, -40, 0, 160)
BodyHitboxSection.Position = UDim2.new(0, 20, 0, 200)
BodyHitboxSection.BackgroundColor3 = Config.Colors.Primary
BodyHitboxSection.BorderSizePixel = 0
local BodyHitboxSectionCorner = Instance.new("UICorner", BodyHitboxSection)
BodyHitboxSectionCorner.CornerRadius = UDim.new(0, 12)

local BodyHitboxLabel = Instance.new("TextLabel", BodyHitboxSection)
BodyHitboxLabel.Size = UDim2.new(1, 0, 0, 30)
BodyHitboxLabel.Position = UDim2.new(0, 16, 0, 8)
BodyHitboxLabel.BackgroundTransparency = 1
BodyHitboxLabel.Text = "Povećaj Tijelo"
BodyHitboxLabel.TextColor3 = Config.Colors.Text
BodyHitboxLabel.TextScaled = true
BodyHitboxLabel.Font = Enum.Font.GothamBold
BodyHitboxLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Body Hitbox Toggle
local BodyHitboxToggle = Instance.new("TextButton", BodyHitboxSection)
BodyHitboxToggle.Size = UDim2.new(0, 50, 0, 25)
BodyHitboxToggle.Position = UDim2.new(1, -66, 0, 8)
BodyHitboxToggle.BackgroundColor3 = Config.Colors.ToggleOff
BodyHitboxToggle.Text = ""
local BodyHitboxToggleCorner = Instance.new("UICorner", BodyHitboxToggle)
BodyHitboxToggleCorner.CornerRadius = UDim.new(0, 12)

local BodyHitboxToggleKnob = Instance.new("Frame", BodyHitboxToggle)
BodyHitboxToggleKnob.Size = UDim2.new(0, 21, 0, 21)
BodyHitboxToggleKnob.Position = UDim2.new(0, 2, 0, 2)
BodyHitboxToggleKnob.BackgroundColor3 = Config.Colors.Text
local BodyHitboxToggleKnobCorner = Instance.new("UICorner", BodyHitboxToggleKnob)
BodyHitboxToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Body FOV Slider
local BodyFOVLabel = Instance.new("TextLabel", BodyHitboxSection)
BodyFOVLabel.Size = UDim2.new(1, 0, 0, 20)
BodyFOVLabel.Position = UDim2.new(0, 16, 0, 40)
BodyFOVLabel.BackgroundTransparency = 1
BodyFOVLabel.Text = "FOV Tijela"
BodyFOVLabel.TextColor3 = Config.Colors.Text
BodyFOVLabel.TextScaled = true
BodyFOVLabel.Font = Enum.Font.Gotham
BodyFOVLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Body FOV Slider Background
local BodyFOVSlider = Instance.new("Frame", BodyHitboxSection)
BodyFOVSlider.Size = UDim2.new(0, 120, 0, 6)
BodyFOVSlider.Position = UDim2.new(1, -140, 0, 45)
BodyFOVSlider.BackgroundColor3 = Config.Colors.Slider
local BodyFOVSliderCorner = Instance.new("UICorner", BodyFOVSlider)
BodyFOVSliderCorner.CornerRadius = UDim.new(0, 3)

-- Body FOV Slider Fill
local BodyFOVSliderBar = Instance.new("Frame", BodyFOVSlider)
BodyFOVSliderBar.Size = UDim2.new((META_TORSO_FOV - HITBOX_FOV_MIN) / (HITBOX_FOV_MAX - HITBOX_FOV_MIN), 0, 1, 0)
BodyFOVSliderBar.Position = UDim2.new(0, 0, 0, 0)
BodyFOVSliderBar.BackgroundColor3 = Config.Colors.SliderBar
local BodyFOVSliderBarCorner = Instance.new("UICorner", BodyFOVSliderBar)
BodyFOVSliderBarCorner.CornerRadius = UDim.new(0, 3)

-- Body FOV Value Display
local BodyFOVValue = Instance.new("TextLabel", BodyHitboxSection)
BodyFOVValue.Size = UDim2.new(0, 40, 0, 20)
BodyFOVValue.Position = UDim2.new(1, -50, 0, 40)
BodyFOVValue.BackgroundTransparency = 1
BodyFOVValue.Text = tostring(META_TORSO_FOV)
BodyFOVValue.TextColor3 = Config.Colors.Text
BodyFOVValue.TextScaled = true
BodyFOVValue.Font = Enum.Font.GothamBold

-- Body Color Section
local BodyColorLabel = Instance.new("TextLabel", BodyHitboxSection)
BodyColorLabel.Size = UDim2.new(1, 0, 0, 20)
BodyColorLabel.Position = UDim2.new(0, 16, 0, 70)
BodyColorLabel.BackgroundTransparency = 1
BodyColorLabel.Text = "Boja Tijela"
BodyColorLabel.TextColor3 = Config.Colors.Text
BodyColorLabel.TextScaled = true
BodyColorLabel.Font = Enum.Font.Gotham
BodyColorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Body RGB Inputs
local BodyRInput = Instance.new("TextBox", BodyHitboxSection)
BodyRInput.Size = UDim2.new(0, 40, 0, 20)
BodyRInput.Position = UDim2.new(1, -140, 0, 70)
BodyRInput.BackgroundColor3 = Config.Colors.Secondary
BodyRInput.Text = "0"
BodyRInput.TextColor3 = Config.Colors.Text
BodyRInput.TextScaled = true
BodyRInput.Font = Enum.Font.Gotham
local BodyRInputCorner = Instance.new("UICorner", BodyRInput)
BodyRInputCorner.CornerRadius = UDim.new(0, 6)

local BodyGInput = Instance.new("TextBox", BodyHitboxSection)
BodyGInput.Size = UDim2.new(0, 40, 0, 20)
BodyGInput.Position = UDim2.new(1, -95, 0, 70)
BodyGInput.BackgroundColor3 = Config.Colors.Secondary
BodyGInput.Text = "255"
BodyGInput.TextColor3 = Config.Colors.Text
BodyGInput.TextScaled = true
BodyGInput.Font = Enum.Font.Gotham
local BodyGInputCorner = Instance.new("UICorner", BodyGInput)
BodyGInputCorner.CornerRadius = UDim.new(0, 6)

local BodyBInput = Instance.new("TextBox", BodyHitboxSection)
BodyBInput.Size = UDim2.new(0, 40, 0, 20)
BodyBInput.Position = UDim2.new(1, -50, 0, 70)
BodyBInput.BackgroundColor3 = Config.Colors.Secondary
BodyBInput.Text = "0"
BodyBInput.TextColor3 = Config.Colors.Text
BodyBInput.TextScaled = true
BodyBInput.Font = Enum.Font.Gotham
local BodyBInputCorner = Instance.new("UICorner", BodyBInput)
BodyBInputCorner.CornerRadius = UDim.new(0, 6)

-- Body Color Picker (Modern)
local BodyColorPicker = Instance.new("Frame", BodyHitboxSection)
BodyColorPicker.Size = UDim2.new(0, 60, 0, 60)
BodyColorPicker.Position = UDim2.new(1, -80, 0, 100)
BodyColorPicker.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
local BodyColorPickerCorner = Instance.new("UICorner", BodyColorPicker)
BodyColorPickerCorner.CornerRadius = UDim.new(0, 8)

-- Body Color Picker Gradient (Full spectrum)
local BodyColorGradient = Instance.new("UIGradient", BodyColorPicker)
BodyColorGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
BodyColorGradient.Rotation = 0

-- Body Color Picker Cursor
local BodyColorCursor = Instance.new("Frame", BodyColorPicker)
BodyColorCursor.Size = UDim2.new(0, 8, 0, 8)
BodyColorCursor.Position = UDim2.new(0.2, -4, 0.8, -4)
BodyColorCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local BodyColorCursorCorner = Instance.new("UICorner", BodyColorCursor)
BodyColorCursorCorner.CornerRadius = UDim.new(0, 4)

-- Local Section
local LocalSection = Instance.new("Frame", CombatSection)
LocalSection.Size = UDim2.new(1, -32, 0, 140)
LocalSection.Position = UDim2.new(0, 16, 0, 380)
LocalSection.BackgroundColor3 = Config.Colors.Primary
LocalSection.BorderSizePixel = 0
local LocalSectionCorner = Instance.new("UICorner", LocalSection)
LocalSectionCorner.CornerRadius = UDim.new(0, 12)

local LocalLabel = Instance.new("TextLabel", LocalSection)
LocalLabel.Size = UDim2.new(1, 0, 0, 30)
LocalLabel.Position = UDim2.new(0, 16, 0, 8)
LocalLabel.BackgroundTransparency = 1
LocalLabel.Text = "Local"
LocalLabel.TextColor3 = Config.Colors.Text
LocalLabel.TextScaled = true
LocalLabel.Font = Enum.Font.GothamBold
LocalLabel.TextXAlignment = Enum.TextXAlignment.Left



-- Inf Jump Toggle
local InfJumpLabel = Instance.new("TextLabel", LocalSection)
InfJumpLabel.Size = UDim2.new(1, -100, 0, 20)
InfJumpLabel.Position = UDim2.new(0, 16, 0, 40)
InfJumpLabel.BackgroundTransparency = 1
InfJumpLabel.Text = "Inf jump"
InfJumpLabel.TextColor3 = Config.Colors.Text
InfJumpLabel.TextScaled = true
InfJumpLabel.Font = Enum.Font.Gotham
InfJumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local InfJumpToggle = Instance.new("TextButton", LocalSection)
InfJumpToggle.Size = UDim2.new(0, 50, 0, 25)
InfJumpToggle.Position = UDim2.new(1, -66, 0, 40)
InfJumpToggle.BackgroundColor3 = Config.Colors.ToggleOff
InfJumpToggle.Text = ""
local InfJumpToggleCorner = Instance.new("UICorner", InfJumpToggle)
InfJumpToggleCorner.CornerRadius = UDim.new(0, 12)

local InfJumpToggleKnob = Instance.new("Frame", InfJumpToggle)
InfJumpToggleKnob.Size = UDim2.new(0, 21, 0, 21)
InfJumpToggleKnob.Position = UDim2.new(0, 2, 0, 2)
InfJumpToggleKnob.BackgroundColor3 = Config.Colors.Text
local InfJumpToggleKnobCorner = Instance.new("UICorner", InfJumpToggleKnob)
InfJumpToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Krozzid Toggle
local KrozzidLabel = Instance.new("TextLabel", LocalSection)
KrozzidLabel.Size = UDim2.new(1, -100, 0, 20)
KrozzidLabel.Position = UDim2.new(0, 16, 0, 70)
KrozzidLabel.BackgroundTransparency = 1
KrozzidLabel.Text = "Krozzid"
KrozzidLabel.TextColor3 = Config.Colors.Text
KrozzidLabel.TextScaled = true
KrozzidLabel.Font = Enum.Font.Gotham
KrozzidLabel.TextXAlignment = Enum.TextXAlignment.Left

local KrozzidToggle = Instance.new("TextButton", LocalSection)
KrozzidToggle.Size = UDim2.new(0, 50, 0, 25)
KrozzidToggle.Position = UDim2.new(1, -66, 0, 70)
KrozzidToggle.BackgroundColor3 = Config.Colors.ToggleOff
KrozzidToggle.Text = ""
local KrozzidToggleCorner = Instance.new("UICorner", KrozzidToggle)
KrozzidToggleCorner.CornerRadius = UDim.new(0, 12)

local KrozzidToggleKnob = Instance.new("Frame", KrozzidToggle)
KrozzidToggleKnob.Size = UDim2.new(0, 21, 0, 21)
KrozzidToggleKnob.Position = UDim2.new(0, 2, 0, 2)
KrozzidToggleKnob.BackgroundColor3 = Config.Colors.Text
local KrozzidToggleKnobCorner = Instance.new("UICorner", KrozzidToggleKnob)
KrozzidToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Imena Toggle (moved to VizijaSection)
local ImenaLabel = Instance.new("TextLabel", VizijaSection)
ImenaLabel.Size = UDim2.new(1, -100, 0, 20)
ImenaLabel.Position = UDim2.new(0, 16, 0, 200)
ImenaLabel.BackgroundTransparency = 1
ImenaLabel.Text = "Imena"
ImenaLabel.TextColor3 = Config.Colors.Text
ImenaLabel.TextScaled = true
ImenaLabel.Font = Enum.Font.Gotham
ImenaLabel.TextXAlignment = Enum.TextXAlignment.Left

local ImenaToggle = Instance.new("TextButton", VizijaSection)
ImenaToggle.Size = UDim2.new(0, 50, 0, 25)
ImenaToggle.Position = UDim2.new(1, -66, 0, 200)
ImenaToggle.BackgroundColor3 = Config.Colors.ToggleOff
ImenaToggle.Text = ""
local ImenaToggleCorner = Instance.new("UICorner", ImenaToggle)
ImenaToggleCorner.CornerRadius = UDim.new(0, 12)

local ImenaToggleKnob = Instance.new("Frame", ImenaToggle)
ImenaToggleKnob.Size = UDim2.new(0, 21, 0, 21)
ImenaToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ImenaToggleKnob.BackgroundColor3 = Config.Colors.Text
local ImenaToggleKnobCorner = Instance.new("UICorner", ImenaToggleKnob)
ImenaToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Imena FOV Slider
local ImenaFOVLabel = Instance.new("TextLabel", VizijaSection)
ImenaFOVLabel.Size = UDim2.new(1, 0, 0, 20)
ImenaFOVLabel.Position = UDim2.new(0, 16, 0, 235)
ImenaFOVLabel.BackgroundTransparency = 1
ImenaFOVLabel.Text = "FOV Imena"
ImenaFOVLabel.TextColor3 = Config.Colors.Text
ImenaFOVLabel.TextScaled = true
ImenaFOVLabel.Font = Enum.Font.Gotham
ImenaFOVLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Imena FOV Slider Background
local ImenaFOVSlider = Instance.new("Frame", VizijaSection)
ImenaFOVSlider.Size = UDim2.new(0, 120, 0, 6)
ImenaFOVSlider.Position = UDim2.new(1, -140, 0, 240)
ImenaFOVSlider.BackgroundColor3 = Config.Colors.Slider
local ImenaFOVSliderCorner = Instance.new("UICorner", ImenaFOVSlider)
ImenaFOVSliderCorner.CornerRadius = UDim.new(0, 3)

-- Imena FOV Slider Fill
local ImenaFOVSliderBar = Instance.new("Frame", ImenaFOVSlider)
ImenaFOVSliderBar.Size = UDim2.new(0.5, 0, 1, 0)
ImenaFOVSliderBar.Position = UDim2.new(0, 0, 0, 0)
ImenaFOVSliderBar.BackgroundColor3 = Config.Colors.SliderBar
local ImenaFOVSliderBarCorner = Instance.new("UICorner", ImenaFOVSliderBar)
ImenaFOVSliderBarCorner.CornerRadius = UDim.new(0, 3)

-- Imena FOV Value Display
local ImenaFOVValue = Instance.new("TextLabel", VizijaSection)
ImenaFOVValue.Size = UDim2.new(0, 40, 0, 20)
ImenaFOVValue.Position = UDim2.new(1, -50, 0, 235)
ImenaFOVValue.BackgroundTransparency = 1
ImenaFOVValue.Text = "1.0"
ImenaFOVValue.TextColor3 = Config.Colors.Text
ImenaFOVValue.TextScaled = true
ImenaFOVValue.Font = Enum.Font.GothamBold

-- Vizija Section Content
local VizijaEnabledLabel = Instance.new("TextLabel", VizijaSection)
VizijaEnabledLabel.Size = UDim2.new(1, -100, 0, 30)
VizijaEnabledLabel.Position = UDim2.new(0, 16, 0, 16)
VizijaEnabledLabel.BackgroundTransparency = 1
VizijaEnabledLabel.Text = "Vizija"
VizijaEnabledLabel.TextColor3 = Config.Colors.Text
VizijaEnabledLabel.TextScaled = true
VizijaEnabledLabel.Font = Enum.Font.Gotham
VizijaEnabledLabel.TextXAlignment = Enum.TextXAlignment.Left

local VizijaEnabledToggle = Instance.new("TextButton", VizijaSection)
VizijaEnabledToggle.Size = UDim2.new(0, 50, 0, 25)
VizijaEnabledToggle.Position = UDim2.new(1, -66, 0, 16)
VizijaEnabledToggle.BackgroundColor3 = Config.Colors.ToggleOff
VizijaEnabledToggle.Text = ""
local VizijaEnabledToggleCorner = Instance.new("UICorner", VizijaEnabledToggle)
VizijaEnabledToggleCorner.CornerRadius = UDim.new(0, 12)

local VizijaEnabledToggleKnob = Instance.new("Frame", VizijaEnabledToggle)
VizijaEnabledToggleKnob.Size = UDim2.new(0, 21, 0, 21)
VizijaEnabledToggleKnob.Position = UDim2.new(0, 2, 0, 2)
VizijaEnabledToggleKnob.BackgroundColor3 = Config.Colors.Text
local VizijaEnabledToggleKnobCorner = Instance.new("UICorner", VizijaEnabledToggleKnob)
VizijaEnabledToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- ESP Color Section
local ESPColorLabel = Instance.new("TextLabel", VizijaSection)
ESPColorLabel.Size = UDim2.new(1, 0, 0, 20)
ESPColorLabel.Position = UDim2.new(0, 16, 0, 50)
ESPColorLabel.BackgroundTransparency = 1
ESPColorLabel.Text = "Boja ESP"
ESPColorLabel.TextColor3 = Config.Colors.Text
ESPColorLabel.TextScaled = true
ESPColorLabel.Font = Enum.Font.Gotham
ESPColorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ESP RGB Inputs
local ESPRInput = Instance.new("TextBox", VizijaSection)
ESPRInput.Size = UDim2.new(0, 40, 0, 20)
ESPRInput.Position = UDim2.new(1, -140, 0, 50)
ESPRInput.BackgroundColor3 = Config.Colors.Secondary
ESPRInput.Text = "255"
ESPRInput.TextColor3 = Config.Colors.Text
ESPRInput.TextScaled = true
ESPRInput.Font = Enum.Font.Gotham
local ESPRInputCorner = Instance.new("UICorner", ESPRInput)
ESPRInputCorner.CornerRadius = UDim.new(0, 6)

local ESPGInput = Instance.new("TextBox", VizijaSection)
ESPGInput.Size = UDim2.new(0, 40, 0, 20)
ESPGInput.Position = UDim2.new(1, -95, 0, 50)
ESPGInput.BackgroundColor3 = Config.Colors.Secondary
ESPGInput.Text = "20"
ESPGInput.TextColor3 = Config.Colors.Text
ESPGInput.TextScaled = true
ESPGInput.Font = Enum.Font.Gotham
local ESPGInputCorner = Instance.new("UICorner", ESPGInput)
ESPGInputCorner.CornerRadius = UDim.new(0, 6)

local ESPBInput = Instance.new("TextBox", VizijaSection)
ESPBInput.Size = UDim2.new(0, 40, 0, 20)
ESPBInput.Position = UDim2.new(1, -50, 0, 50)
ESPBInput.BackgroundColor3 = Config.Colors.Secondary
ESPBInput.Text = "147"
ESPBInput.TextColor3 = Config.Colors.Text
ESPBInput.TextScaled = true
ESPBInput.Font = Enum.Font.Gotham
local ESPBInputCorner = Instance.new("UICorner", ESPBInput)
ESPBInputCorner.CornerRadius = UDim.new(0, 6)

-- ESP Color Picker (Modern)
local ESPColorPicker = Instance.new("Frame", VizijaSection)
ESPColorPicker.Size = UDim2.new(0, 60, 0, 60)
ESPColorPicker.Position = UDim2.new(1, -80, 0, 100)
ESPColorPicker.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
local ESPColorPickerCorner = Instance.new("UICorner", ESPColorPicker)
ESPColorPickerCorner.CornerRadius = UDim.new(0, 8)

-- ESP Color Picker Gradient (Full spectrum)
local ESPColorGradient = Instance.new("UIGradient", ESPColorPicker)
ESPColorGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
ESPColorGradient.Rotation = 0

-- ESP Color Picker Cursor
local ESPColorCursor = Instance.new("Frame", ESPColorPicker)
ESPColorCursor.Size = UDim2.new(0, 8, 0, 8)
ESPColorCursor.Position = UDim2.new(0.9, -4, 0.1, -4)
ESPColorCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local ESPColorCursorCorner = Instance.new("UICorner", ESPColorCursor)
ESPColorCursorCorner.CornerRadius = UDim.new(0, 4)

-- Toggle functionality with animations and hover effects
local function createToggle(toggle, knob, callback)
    local isOn = false
    local originalColor = toggle.BackgroundColor3
    
    -- Hover animations
    toggle.MouseEnter:Connect(function()
        if not isOn then
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            }):Play()
        end
    end)
    
    toggle.MouseLeave:Connect(function()
        if not isOn then
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = originalColor
            }):Play()
        end
    end)
    
    -- Toggle function
    local function toggleState()
        isOn = not isOn
        
        local targetColor = isOn and Config.Colors.Accent or Config.Colors.ToggleOff
        local targetPosition = isOn and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
        
        -- Animate toggle background with bounce effect
        local colorTween = TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        })
        colorTween:Play()
        
        -- Animate knob position with bounce effect
        local positionTween = TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = targetPosition
        })
        positionTween:Play()
        
        -- Scale animation for feedback
        local scaleTween = TweenService:Create(toggle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 52, 0, 27)
        })
        scaleTween:Play()
        
        scaleTween.Completed:Connect(function()
            TweenService:Create(toggle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 25)
            }):Play()
        end)
        
        if callback then
            callback(isOn)
        end
    end
    
    -- Right Shift functionality for this specific toggle
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleState()
        end
    end)
    
    return function() return isOn end
end

-- Toggle functionality is now handled globally with Right Shift

-- Add hover effects to input boxes
local function addInputHoverEffects(input)
    local originalColor = input.BackgroundColor3
    
    input.MouseEnter:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        }):Play()
    end)
    
    input.MouseLeave:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
    
    input.Focused:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Colors.Accent
        }):Play()
    end)
    
    input.FocusLost:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

-- Head FOV input handling
HeadFOVBox.FocusLost:Connect(function()
    local value = tonumber(HeadFOVBox.Text)
    if value and value >= HITBOX_FOV_MIN and value <= HITBOX_FOV_MAX then
        META_HEAD_FOV = value
    else
        HeadFOVBox.Text = tostring(META_HEAD_FOV)
    end
end)

-- Add hover effects to all input boxes
addInputHoverEffects(HeadFOVBox)
addInputHoverEffects(BodyFOVBox)
addInputHoverEffects(HeadRInput)
addInputHoverEffects(HeadGInput)
addInputHoverEffects(HeadBInput)
addInputHoverEffects(BodyRInput)
addInputHoverEffects(BodyGInput)
addInputHoverEffects(BodyBInput)
addInputHoverEffects(ESPRInput)
addInputHoverEffects(ESPGInput)
addInputHoverEffects(ESPBInput)

-- Body FOV input handling
BodyFOVBox.FocusLost:Connect(function()
    local value = tonumber(BodyFOVBox.Text)
    if value and value >= HITBOX_FOV_MIN and value <= HITBOX_FOV_MAX then
        META_TORSO_FOV = value
    else
        BodyFOVBox.Text = tostring(META_TORSO_FOV)
    end
end)

-- Head color picker functionality
local function updateHeadColor()
    local r = tonumber(HeadRInput.Text) or 255
    local g = tonumber(HeadGInput.Text) or 0
    local b = tonumber(HeadBInput.Text) or 0
    
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    local color = Color3.fromRGB(r, g, b)
    HITBOX_HEAD_COLOR = color
    HeadColorPicker.BackgroundColor3 = color
end

HeadRInput.FocusLost:Connect(updateHeadColor)
HeadGInput.FocusLost:Connect(updateHeadColor)
HeadBInput.FocusLost:Connect(updateHeadColor)

-- Body color picker functionality
local function updateBodyColor()
    local r = tonumber(BodyRInput.Text) or 0
    local g = tonumber(BodyGInput.Text) or 255
    local b = tonumber(BodyBInput.Text) or 0
    
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    local color = Color3.fromRGB(r, g, b)
    HITBOX_TORSO_COLOR = color
    BodyColorPicker.BackgroundColor3 = color
end

BodyRInput.FocusLost:Connect(updateBodyColor)
BodyGInput.FocusLost:Connect(updateBodyColor)
BodyBInput.FocusLost:Connect(updateBodyColor)

-- ESP color picker functionality
local function updateESPColor()
    local r = tonumber(ESPRInput.Text) or 255
    local g = tonumber(ESPGInput.Text) or 20
    local b = tonumber(ESPBInput.Text) or 147
    
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    local color = Color3.fromRGB(r, g, b)
    VIZIJA_COLOR = color
    ESPColorPicker.BackgroundColor3 = color
end

ESPRInput.FocusLost:Connect(updateESPColor)
ESPGInput.FocusLost:Connect(updateESPColor)
ESPBInput.FocusLost:Connect(updateESPColor)

-- Minimize functionality with animations
MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        -- Animate back to full size
        local sizeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 450, 0, 700)
        })
        local positionTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = Config.MenuPosition
        })
        sizeTween:Play()
        positionTween:Play()
        isMinimized = false
    else
        -- Animate to minimized
        local sizeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Config.MinimizedSize
        })
        local positionTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = Config.MinimizedPosition
        })
        sizeTween:Play()
        positionTween:Play()
        isMinimized = true
    end
end)

-- Close functionality
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Menu toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Config.MenuKey then
        isMenuOpen = not isMenuOpen
        MainFrame.Visible = isMenuOpen
    end
end)

-- Helper functions
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    
    return closestPlayer
end

local function isEnemy(player)
    if not VIZIJA_ENEMY_ONLY then return true end
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return false end
    
    -- Check if player is on different team (basic team check)
    local localTeam = localPlayer.Team
    local playerTeam = player.Team
    
    if localTeam and playerTeam then
        return localTeam ~= playerTeam
    end
    
    return true -- Default to enemy if no team info
end

-- ESP Box creation and management
local function createESPBox(player)
    if vizijaBoxes[player] then return end
    
    local espBox = Instance.new("BillboardGui")
    espBox.Name = "ESPBox_" .. player.Name
    espBox.Size = UDim2.new(0, 100, 0, 150)
    espBox.StudsOffset = Vector3.new(0, 2, 0)
    espBox.AlwaysOnTop = true
    espBox.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = VIZIJA_COLOR
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 2
    frame.BorderColor3 = VIZIJA_COLOR
    frame.Parent = espBox
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    -- Name tag
    local nameTag = Instance.new("TextLabel")
    nameTag.Size = UDim2.new(1, 0, 0, 20)
    nameTag.Position = UDim2.new(0, 0, 0, -25)
    nameTag.BackgroundTransparency = 1
    nameTag.Text = player.Name
    nameTag.TextColor3 = VIZIJA_COLOR
    nameTag.TextScaled = true
    nameTag.Font = Enum.Font.GothamBold
    nameTag.Parent = espBox
    
    espBox.Parent = Camera
    vizijaBoxes[player] = espBox
end

local function removeESPBox(player)
    if vizijaBoxes[player] then
        vizijaBoxes[player]:Destroy()
        vizijaBoxes[player] = nil
    end
end

-- Player management
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if VIZIJA_ENABLED and isEnemy(player) then
            createESPBox(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESPBox(player)
end)

-- ESP Loop
RunService.Heartbeat:Connect(function()
    if not VIZIJA_ENABLED then
        -- Remove all ESP boxes when disabled
        for player, espBox in pairs(vizijaBoxes) do
            espBox:Destroy()
        end
        vizijaBoxes = {}
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
            if isEnemy(player) then
                if not vizijaBoxes[player] then
                    createESPBox(player)
                end
                
                -- Update ESP box position and visibility
                local espBox = vizijaBoxes[player]
                if espBox and espBox.Adornee then
                    local rootPart = player.Character.HumanoidRootPart
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    
                    if distance < 1000 then -- Only show ESP within 1000 studs
                        espBox.Enabled = true
                        espBox.Adornee = rootPart
                        
                        -- Update color
                        local frame = espBox:FindFirstChild("Frame")
                        local nameTag = espBox:FindFirstChild("TextLabel")
                        if frame then
                            frame.BackgroundColor3 = VIZIJA_COLOR
                            frame.BorderColor3 = VIZIJA_COLOR
                        end
                        if nameTag then
                            nameTag.TextColor3 = VIZIJA_COLOR
                        end
                    else
                        espBox.Enabled = false
                    end
                end
            else
                removeESPBox(player)
            end
        else
            removeESPBox(player)
        end
    end
end)

-- Hitbox functionality
RunService.Heartbeat:Connect(function()
    local closestPlayer = getClosestPlayer()
    if not closestPlayer or not closestPlayer.Character then return end
    
    -- Head hitbox
    if META_HEAD then
        local head = closestPlayer.Character:FindFirstChild("Head")
        if head then
            -- Expand head hitbox
            head.Size = Vector3.new(META_HEAD_FOV, META_HEAD_FOV, META_HEAD_FOV)
            
            -- Visual indicator
            if head:FindFirstChild("HeadHitboxIndicator") then
                head.HeadHitboxIndicator:Destroy()
            end
            
            local indicator = Instance.new("Part")
            indicator.Name = "HeadHitboxIndicator"
            indicator.Size = Vector3.new(META_HEAD_FOV, META_HEAD_FOV, META_HEAD_FOV)
            indicator.Position = head.Position
            indicator.Anchored = true
            indicator.CanCollide = false
            indicator.Transparency = 0.8
            indicator.Color = HITBOX_HEAD_COLOR
            indicator.Material = Enum.Material.Neon
            indicator.Parent = head
            
            game:GetService("Debris"):AddItem(indicator, 0.1)
        end
    end
    
    -- Body hitbox
    if META_TORSO then
        local torso = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if torso then
            -- Expand torso hitbox
            torso.Size = Vector3.new(META_TORSO_FOV, META_TORSO_FOV, META_TORSO_FOV)
            
            -- Visual indicator
            if torso:FindFirstChild("BodyHitboxIndicator") then
                torso.BodyHitboxIndicator:Destroy()
            end
            
            local indicator = Instance.new("Part")
            indicator.Name = "BodyHitboxIndicator"
            indicator.Size = Vector3.new(META_TORSO_FOV, META_TORSO_FOV, META_TORSO_FOV)
            indicator.Position = torso.Position
            indicator.Anchored = true
            indicator.CanCollide = false
            indicator.Transparency = 0.8
            indicator.Color = HITBOX_TORSO_COLOR
            indicator.Material = Enum.Material.Neon
            indicator.Parent = torso
            
            game:GetService("Debris"):AddItem(indicator, 0.1)
        end
    end
end)

-- No clip functionality
RunService.Heartbeat:Connect(function()
    local player = Players.LocalPlayer
    if not player or not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- No clip implementation
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= rootPart then
            part.CanCollide = false
        end
    end
end)

-- Infinite jump functionality
UserInputService.JumpRequest:Connect(function()
    local player = Players.LocalPlayer
    if not player or not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Infinite jump implementation
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

-- Crosshair functionality
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "CrosshairGui"
CrosshairGui.Parent = parentGui

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Size = UDim2.new(0, 20, 0, 20)
CrosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Parent = CrosshairGui

local CrosshairLine1 = Instance.new("Frame")
CrosshairLine1.Size = UDim2.new(0, 2, 0, 20)
CrosshairLine1.Position = UDim2.new(0.5, -1, 0, 0)
CrosshairLine1.BackgroundColor3 = CROSSHAIR_COLOR
CrosshairLine1.Parent = CrosshairFrame

local CrosshairLine2 = Instance.new("Frame")
CrosshairLine2.Size = UDim2.new(0, 20, 0, 2)
CrosshairLine2.Position = UDim2.new(0, 0, 0.5, -1)
CrosshairLine2.BackgroundColor3 = CROSSHAIR_COLOR
CrosshairLine2.Parent = CrosshairFrame

CrosshairGui.Enabled = CROSSHAIR_ENABLED

-- Update crosshair visibility when toggle changes
local function updateCrosshairVisibility()
    CrosshairGui.Enabled = CROSSHAIR_ENABLED
end

-- Crosshair visibility is now handled globally

-- FOV circle (optional)
local FOVCircle = Instance.new("Part")
FOVCircle.Name = "FOVCircle"
FOVCircle.Shape = Enum.PartType.Cylinder
FOVCircle.Size = Vector3.new(0.1, currentFOV * 2, currentFOV * 2)
FOVCircle.Position = Camera.CFrame.Position
FOVCircle.Anchored = true
FOVCircle.CanCollide = false
FOVCircle.Transparency = 0.8
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Material = Enum.Material.Neon
FOVCircle.Parent = workspace

-- Update FOV circle
RunService.Heartbeat:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Camera.CFrame.Position
        FOVCircle.Size = Vector3.new(0.1, currentFOV * 2, currentFOV * 2)
    end
end)

-- Slider functionality
local function createSlider(slider, sliderBar, valueLabel, minValue, maxValue, currentValue, callback)
    local isDragging = false
    
    -- Mouse down on slider
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    -- Mouse up anywhere
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Mouse movement
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local sliderSize = slider.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            
            -- Update slider bar
            sliderBar.Size = UDim2.new(relativeX, 0, 1, 0)
            
            -- Update value label
            if maxValue <= 10 then
                valueLabel.Text = string.format("%.1f", newValue)
            else
                valueLabel.Text = tostring(math.floor(newValue))
            end
            
            -- Call callback
            if callback then
                callback(newValue)
            end
        end
    end)
    
    -- Initialize slider position
    local initialRelative = (currentValue - minValue) / (maxValue - minValue)
    sliderBar.Size = UDim2.new(initialRelative, 0, 1, 0)
    if maxValue <= 10 then
        valueLabel.Text = string.format("%.1f", currentValue)
    else
        valueLabel.Text = tostring(math.floor(currentValue))
    end
    
    -- Add click functionality to slider
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local sliderSize = slider.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            
            -- Update slider bar
            sliderBar.Size = UDim2.new(relativeX, 0, 1, 0)
            
            -- Update value label
            if maxValue <= 10 then
                valueLabel.Text = string.format("%.1f", newValue)
            else
                valueLabel.Text = tostring(math.floor(newValue))
            end
            
            -- Call callback
            if callback then
                callback(newValue)
            end
        end
    end)
end

-- Color picker functionality
local function createColorPicker(colorPicker, cursor, rInput, gInput, bInput, callback)
    local isDragging = false
    
    -- Mouse down on color picker
    colorPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    -- Mouse up anywhere
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Mouse movement
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local pickerPos = colorPicker.AbsolutePosition
            local pickerSize = colorPicker.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - pickerPos.X) / pickerSize.X, 0, 1)
            local relativeY = math.clamp((mousePos.Y - pickerPos.Y) / pickerSize.Y, 0, 1)
            
            -- Update cursor position
            cursor.Position = UDim2.new(relativeX, -4, relativeY, -4)
            
            -- Calculate color based on position (full spectrum)
            local hue = relativeX * 360
            local saturation = 1
            local value = 1 - relativeY
            
            local color = Color3.fromHSV(hue, saturation, value)
            
            -- Update RGB inputs
            rInput.Text = tostring(math.floor(color.R * 255))
            gInput.Text = tostring(math.floor(color.G * 255))
            bInput.Text = tostring(math.floor(color.B * 255))
            
            -- Update color picker background
            colorPicker.BackgroundColor3 = color
            
            -- Call callback
            if callback then
                callback(color)
            end
        end
    end)
    
    -- Add click functionality to color picker
    colorPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local pickerPos = colorPicker.AbsolutePosition
            local pickerSize = colorPicker.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - pickerPos.X) / pickerSize.X, 0, 1)
            local relativeY = math.clamp((mousePos.Y - pickerPos.Y) / pickerSize.Y, 0, 1)
            
            -- Update cursor position
            cursor.Position = UDim2.new(relativeX, -4, relativeY, -4)
            
            -- Calculate color based on position (full spectrum)
            local hue = relativeX * 360
            local saturation = 1
            local value = 1 - relativeY
            
            local color = Color3.fromHSV(hue, saturation, value)
            
            -- Update RGB inputs
            rInput.Text = tostring(math.floor(color.R * 255))
            gInput.Text = tostring(math.floor(color.G * 255))
            bInput.Text = tostring(math.floor(color.B * 255))
            
            -- Update color picker background
            colorPicker.BackgroundColor3 = color
            
            -- Call callback
            if callback then
                callback(color)
            end
        end
    end)
    
    -- Initialize cursor position based on current color
    local currentR = tonumber(rInput.Text) or 255
    local currentG = tonumber(gInput.Text) or 0
    local currentB = tonumber(bInput.Text) or 0
    
    local currentColor = Color3.fromRGB(currentR, currentG, currentB)
    local h, s, v = currentColor:ToHSV()
    
    local relativeX = h / 360
    local relativeY = 1 - v
    
    cursor.Position = UDim2.new(relativeX, -4, relativeY, -4)
end

-- Toggle functionality
local toggleStates = {}

local function toggleSwitch(toggle, knob, callback)
    local data = toggleStates[toggle]
    if not data then return end
    
    local isOn = not data.isOn
    toggleStates[toggle].isOn = isOn
    
    local targetColor = isOn and Config.Colors.Accent or Config.Colors.ToggleOff
    local targetPosition = isOn and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
    
    -- Animate toggle background
    TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor
    }):Play()
    
    -- Animate knob position
    TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = targetPosition
    }):Play()
    
    -- Call callback
    if callback then
        callback(isOn)
    end
end

-- Register all toggles with individual click functionality
toggleStates[HeadHitboxToggle] = {knob = HeadHitboxToggleKnob, isOn = false, callback = function(enabled) META_HEAD = enabled end}
toggleStates[BodyHitboxToggle] = {knob = BodyHitboxToggleKnob, isOn = false, callback = function(enabled) META_TORSO = enabled end}
toggleStates[InfJumpToggle] = {knob = InfJumpToggleKnob, isOn = false, callback = function(enabled) end}
toggleStates[ImenaToggle] = {knob = ImenaToggleKnob, isOn = false, callback = function(enabled) NAMETAG_ENABLED = enabled end}
toggleStates[KrozzidToggle] = {knob = KrozzidToggleKnob, isOn = false, callback = function(enabled) 
    CROSSHAIR_ENABLED = enabled 
    updateCrosshairVisibility()
end}
toggleStates[VizijaEnabledToggle] = {knob = VizijaEnabledToggleKnob, isOn = false, callback = function(enabled) VIZIJA_ENABLED = enabled end}

-- Individual toggle clicks
HeadHitboxToggle.MouseButton1Click:Connect(function()
    toggleSwitch(HeadHitboxToggle, HeadHitboxToggleKnob, function(enabled) META_HEAD = enabled end)
end)

BodyHitboxToggle.MouseButton1Click:Connect(function()
    toggleSwitch(BodyHitboxToggle, BodyHitboxToggleKnob, function(enabled) META_TORSO = enabled end)
end)

InfJumpToggle.MouseButton1Click:Connect(function()
    toggleSwitch(InfJumpToggle, InfJumpToggleKnob, function(enabled) end)
end)

ImenaToggle.MouseButton1Click:Connect(function()
    toggleSwitch(ImenaToggle, ImenaToggleKnob, function(enabled) NAMETAG_ENABLED = enabled end)
end)

KrozzidToggle.MouseButton1Click:Connect(function()
    toggleSwitch(KrozzidToggle, KrozzidToggleKnob, function(enabled) 
        CROSSHAIR_ENABLED = enabled 
        updateCrosshairVisibility()
    end)
end)

VizijaEnabledToggle.MouseButton1Click:Connect(function()
    toggleSwitch(VizijaEnabledToggle, VizijaEnabledToggleKnob, function(enabled) VIZIJA_ENABLED = enabled end)
end)

-- Right Shift to toggle GUI visibility
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        isMenuOpen = not isMenuOpen
        MainFrame.Visible = isMenuOpen
    end
end)

-- Initialize sliders and color pickers
createSlider(HeadFOVSlider, HeadFOVSliderBar, HeadFOVValue, HITBOX_FOV_MIN, HITBOX_FOV_MAX, META_HEAD_FOV, function(value)
    META_HEAD_FOV = value
end)

createSlider(BodyFOVSlider, BodyFOVSliderBar, BodyFOVValue, HITBOX_FOV_MIN, HITBOX_FOV_MAX, META_TORSO_FOV, function(value)
    META_TORSO_FOV = value
end)

createSlider(ImenaFOVSlider, ImenaFOVSliderBar, ImenaFOVValue, 0.1, 5, 1.0, function(value)
    NAMETAG_SCALE = value
end)

createColorPicker(HeadColorPicker, HeadColorCursor, HeadRInput, HeadGInput, HeadBInput, function(color)
    HITBOX_HEAD_COLOR = color
end)

createColorPicker(BodyColorPicker, BodyColorCursor, BodyRInput, BodyGInput, BodyBInput, function(color)
    HITBOX_TORSO_COLOR = color
end)

createColorPicker(ESPColorPicker, ESPColorCursor, ESPRInput, ESPGInput, ESPBInput, function(color)
    VIZIJA_COLOR = color
end)

-- Cleanup on script end
game:BindToClose(function()
    for _, espBox in pairs(vizijaBoxes) do
        espBox:Destroy()
    end
    if FOVCircle then
        FOVCircle:Destroy()
    end
    if CrosshairGui then
        CrosshairGui:Destroy()
    end
end)

print("Alesto Panel loaded successfully!") 