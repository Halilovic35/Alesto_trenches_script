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
    Accent = Color3.fromRGB(0, 120, 255), -- Blue accent color
    Text = Color3.fromRGB(255, 255, 255),
    Minimized = Color3.fromRGB(40, 40, 50),
    Section = Color3.fromRGB(36, 36, 48),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    Slider = Color3.fromRGB(60, 60, 80),
    SliderBar = Color3.fromRGB(0, 120, 255)
}

-- Add missing config variables
Config.MenuPosition = UDim2.new(0.5, -185, 0.5, -300)
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
local META_HEAD = true
local META_TORSO = false
local META_FOV = 6 -- promeni default na 6

-- Opcije boje glave za hitbox
local HITBOX_HEAD_COLOR = Color3.fromRGB(255, 0, 0) -- default crvena

-- Nametag opcije
local NAMETAG_ENABLED = false
local NAMETAG_SCALE = 1.5

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
MainFrame.Size = UDim2.new(0, 370, 0, 600)
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
Title.Text = "Tbao Hub | Murderers vs sheriffs duels"
Title.TextColor3 = Config.Colors.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- Window Controls
local SearchBtn = Instance.new("TextButton", TitleBar)
SearchBtn.Size = UDim2.new(0, 24, 0, 24)
SearchBtn.Position = UDim2.new(1, -120, 0.5, -12)
SearchBtn.BackgroundTransparency = 1
SearchBtn.Text = "🔍"
SearchBtn.TextColor3 = Config.Colors.Text
SearchBtn.TextScaled = true
SearchBtn.Font = Enum.Font.Gotham

local PinBtn = Instance.new("TextButton", TitleBar)
PinBtn.Size = UDim2.new(0, 24, 0, 24)
PinBtn.Position = UDim2.new(1, -90, 0.5, -12)
PinBtn.BackgroundTransparency = 1
PinBtn.Text = "📌"
PinBtn.TextColor3 = Config.Colors.Text
PinBtn.TextScaled = true
PinBtn.Font = Enum.Font.Gotham

local FolderBtn = Instance.new("TextButton", TitleBar)
FolderBtn.Size = UDim2.new(0, 24, 0, 24)
FolderBtn.Position = UDim2.new(1, -60, 0.5, -12)
FolderBtn.BackgroundTransparency = 1
FolderBtn.Text = "📁"
FolderBtn.TextColor3 = Config.Colors.Text
FolderBtn.TextScaled = true
FolderBtn.Font = Enum.Font.Gotham

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -30, 0.5, -12)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "🗗"
MinimizeBtn.TextColor3 = Config.Colors.Text
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.Gotham

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.Colors.Text
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold

-- Tabs
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(1, 0, 0, 48)
TabsFrame.Position = UDim2.new(0, 0, 0, 48)
TabsFrame.BackgroundColor3 = Config.Colors.Secondary
TabsFrame.BorderSizePixel = 0
local TabsCorner = Instance.new("UICorner", TabsFrame)
TabsCorner.CornerRadius = UDim.new(0, 16)

local InfoTab = Instance.new("TextButton", TabsFrame)
InfoTab.Size = UDim2.new(0.33, -2, 1, 0)
InfoTab.Position = UDim2.new(0, 0, 0, 0)
InfoTab.BackgroundColor3 = Config.Colors.Secondary
InfoTab.Text = "Info"
InfoTab.TextColor3 = Config.Colors.Text
InfoTab.TextScaled = true
InfoTab.Font = Enum.Font.GothamBold
local InfoTabCorner = Instance.new("UICorner", InfoTab)
InfoTabCorner.CornerRadius = UDim.new(0, 12)

local CombatTab = Instance.new("TextButton", TabsFrame)
CombatTab.Size = UDim2.new(0.33, -2, 1, 0)
CombatTab.Position = UDim2.new(0.33, 2, 0, 0)
CombatTab.BackgroundColor3 = Config.Colors.Accent
CombatTab.Text = "Combat"
CombatTab.TextColor3 = Config.Colors.Text
CombatTab.TextScaled = true
CombatTab.Font = Enum.Font.GothamBold
local CombatTabCorner = Instance.new("UICorner", CombatTab)
CombatTabCorner.CornerRadius = UDim.new(0, 12)

local ESPTab = Instance.new("TextButton", TabsFrame)
ESPTab.Size = UDim2.new(0.33, -2, 1, 0)
ESPTab.Position = UDim2.new(0.66, 4, 0, 0)
ESPTab.BackgroundColor3 = Config.Colors.Secondary
ESPTab.Text = "Esp"
ESPTab.TextColor3 = Config.Colors.Text
ESPTab.TextScaled = true
ESPTab.Font = Enum.Font.GothamBold
local ESPTabCorner = Instance.new("UICorner", ESPTab)
ESPTabCorner.CornerRadius = UDim.new(0, 12)

-- Content Sections
local InfoSection = Instance.new("Frame", MainFrame)
InfoSection.Name = "InfoSection"
InfoSection.Size = UDim2.new(1, -32, 1, -120)
InfoSection.Position = UDim2.new(0, 16, 0, 100)
InfoSection.BackgroundColor3 = Config.Colors.Section
InfoSection.BorderSizePixel = 0
local InfoSectionCorner = Instance.new("UICorner", InfoSection)
InfoSectionCorner.CornerRadius = UDim.new(0, 16)
InfoSection.Visible = false

local CombatSection = Instance.new("Frame", MainFrame)
CombatSection.Name = "CombatSection"
CombatSection.Size = UDim2.new(1, -32, 1, -120)
CombatSection.Position = UDim2.new(0, 16, 0, 100)
CombatSection.BackgroundColor3 = Config.Colors.Section
CombatSection.BorderSizePixel = 0
local CombatSectionCorner = Instance.new("UICorner", CombatSection)
CombatSectionCorner.CornerRadius = UDim.new(0, 16)

local ESPSection = Instance.new("Frame", MainFrame)
ESPSection.Name = "ESPSection"
ESPSection.Size = UDim2.new(1, -32, 1, -120)
ESPSection.Position = UDim2.new(0, 16, 0, 100)
ESPSection.BackgroundColor3 = Config.Colors.Section
ESPSection.BorderSizePixel = 0
local ESPSectionCorner = Instance.new("UICorner", ESPSection)
ESPSectionCorner.CornerRadius = UDim.new(0, 16)
ESPSection.Visible = false

-- Tab switching
InfoTab.MouseButton1Click:Connect(function()
    InfoTab.BackgroundColor3 = Config.Colors.Accent
    CombatTab.BackgroundColor3 = Config.Colors.Secondary
    ESPTab.BackgroundColor3 = Config.Colors.Secondary
    InfoSection.Visible = true
    CombatSection.Visible = false
    ESPSection.Visible = false
end)

CombatTab.MouseButton1Click:Connect(function()
    InfoTab.BackgroundColor3 = Config.Colors.Secondary
    CombatTab.BackgroundColor3 = Config.Colors.Accent
    ESPTab.BackgroundColor3 = Config.Colors.Secondary
    InfoSection.Visible = false
    CombatSection.Visible = true
    ESPSection.Visible = false
end)

ESPTab.MouseButton1Click:Connect(function()
    InfoTab.BackgroundColor3 = Config.Colors.Secondary
    CombatTab.BackgroundColor3 = Config.Colors.Secondary
    ESPTab.BackgroundColor3 = Config.Colors.Accent
    InfoSection.Visible = false
    CombatSection.Visible = false
    ESPSection.Visible = true
end)

-- Info Section Content
local InfoTitle = Instance.new("TextLabel", InfoSection)
InfoTitle.Size = UDim2.new(1, 0, 0, 40)
InfoTitle.Position = UDim2.new(0, 16, 0, 16)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Script Information"
InfoTitle.TextColor3 = Config.Colors.Text
InfoTitle.TextScaled = true
InfoTitle.Font = Enum.Font.GothamBold

local InfoText = Instance.new("TextLabel", InfoSection)
InfoText.Size = UDim2.new(1, -32, 1, -80)
InfoText.Position = UDim2.new(0, 16, 0, 60)
InfoText.BackgroundTransparency = 1
InfoText.Text = "Tbao Hub Script\n\nFeatures:\n• Combat enhancements\n• ESP functionality\n• Modern UI\n\nPress Right Shift to toggle"
InfoText.TextColor3 = Config.Colors.Text
InfoText.TextScaled = true
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top

-- Combat Section Content
local HitboxSection = Instance.new("Frame", CombatSection)
HitboxSection.Size = UDim2.new(1, -32, 0, 120)
HitboxSection.Position = UDim2.new(0, 16, 0, 16)
HitboxSection.BackgroundColor3 = Config.Colors.Primary
HitboxSection.BorderSizePixel = 0
local HitboxSectionCorner = Instance.new("UICorner", HitboxSection)
HitboxSectionCorner.CornerRadius = UDim.new(0, 12)

local HitboxLabel = Instance.new("TextLabel", HitboxSection)
HitboxLabel.Size = UDim2.new(1, 0, 0, 30)
HitboxLabel.Position = UDim2.new(0, 16, 0, 8)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "Hitbox"
HitboxLabel.TextColor3 = Config.Colors.Text
HitboxLabel.TextScaled = true
HitboxLabel.Font = Enum.Font.GothamBold
HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Hitbox Toggle
local HitboxToggle = Instance.new("TextButton", HitboxSection)
HitboxToggle.Size = UDim2.new(0, 50, 0, 25)
HitboxToggle.Position = UDim2.new(1, -66, 0, 8)
HitboxToggle.BackgroundColor3 = Config.Colors.ToggleOff
HitboxToggle.Text = ""
local HitboxToggleCorner = Instance.new("UICorner", HitboxToggle)
HitboxToggleCorner.CornerRadius = UDim.new(0, 12)

local HitboxToggleKnob = Instance.new("Frame", HitboxToggle)
HitboxToggleKnob.Size = UDim2.new(0, 21, 0, 21)
HitboxToggleKnob.Position = UDim2.new(0, 2, 0, 2)
HitboxToggleKnob.BackgroundColor3 = Config.Colors.Text
local HitboxToggleKnobCorner = Instance.new("UICorner", HitboxToggleKnob)
HitboxToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Hitbox Value Slider
local HitboxValueLabel = Instance.new("TextLabel", HitboxSection)
HitboxValueLabel.Size = UDim2.new(1, 0, 0, 20)
HitboxValueLabel.Position = UDim2.new(0, 16, 0, 40)
HitboxValueLabel.BackgroundTransparency = 1
HitboxValueLabel.Text = "Hitbox value"
HitboxValueLabel.TextColor3 = Config.Colors.Text
HitboxValueLabel.TextScaled = true
HitboxValueLabel.Font = Enum.Font.Gotham
HitboxValueLabel.TextXAlignment = Enum.TextXAlignment.Left

local HitboxValueBox = Instance.new("TextBox", HitboxSection)
HitboxValueBox.Size = UDim2.new(0, 60, 0, 25)
HitboxValueBox.Position = UDim2.new(1, -76, 0, 40)
HitboxValueBox.BackgroundColor3 = Config.Colors.Secondary
HitboxValueBox.Text = tostring(META_FOV)
HitboxValueBox.TextColor3 = Config.Colors.Text
HitboxValueBox.TextScaled = true
HitboxValueBox.Font = Enum.Font.Gotham
HitboxValueBox.PlaceholderText = "0"
local HitboxValueBoxCorner = Instance.new("UICorner", HitboxValueBox)
HitboxValueBoxCorner.CornerRadius = UDim.new(0, 8)

-- Hitbox Color Section
local HitboxColorLabel = Instance.new("TextLabel", HitboxSection)
HitboxColorLabel.Size = UDim2.new(1, 0, 0, 20)
HitboxColorLabel.Position = UDim2.new(0, 16, 0, 70)
HitboxColorLabel.BackgroundTransparency = 1
HitboxColorLabel.Text = "Hitbox color"
HitboxColorLabel.TextColor3 = Config.Colors.Text
HitboxColorLabel.TextScaled = true
HitboxColorLabel.Font = Enum.Font.Gotham
HitboxColorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- RGB Inputs
local RInput = Instance.new("TextBox", HitboxSection)
RInput.Size = UDim2.new(0, 40, 0, 20)
RInput.Position = UDim2.new(1, -140, 0, 70)
RInput.BackgroundColor3 = Config.Colors.Secondary
RInput.Text = "255"
RInput.TextColor3 = Config.Colors.Text
RInput.TextScaled = true
RInput.Font = Enum.Font.Gotham
local RInputCorner = Instance.new("UICorner", RInput)
RInputCorner.CornerRadius = UDim.new(0, 6)

local GInput = Instance.new("TextBox", HitboxSection)
GInput.Size = UDim2.new(0, 40, 0, 20)
GInput.Position = UDim2.new(1, -95, 0, 70)
GInput.BackgroundColor3 = Config.Colors.Secondary
GInput.Text = "0"
GInput.TextColor3 = Config.Colors.Text
GInput.TextScaled = true
GInput.Font = Enum.Font.Gotham
local GInputCorner = Instance.new("UICorner", GInput)
GInputCorner.CornerRadius = UDim.new(0, 6)

local BInput = Instance.new("TextBox", HitboxSection)
BInput.Size = UDim2.new(0, 40, 0, 20)
BInput.Position = UDim2.new(1, -50, 0, 70)
BInput.BackgroundColor3 = Config.Colors.Secondary
BInput.Text = "0"
BInput.TextColor3 = Config.Colors.Text
BInput.TextScaled = true
BInput.Font = Enum.Font.Gotham
local BInputCorner = Instance.new("UICorner", BInput)
BInputCorner.CornerRadius = UDim.new(0, 6)

-- Hex Input
local HexInput = Instance.new("TextBox", HitboxSection)
HexInput.Size = UDim2.new(0, 60, 0, 20)
HexInput.Position = UDim2.new(1, -76, 0, 95)
HexInput.BackgroundColor3 = Config.Colors.Secondary
HexInput.Text = "#FF0000"
HexInput.TextColor3 = Config.Colors.Text
HexInput.TextScaled = true
HexInput.Font = Enum.Font.Gotham
local HexInputCorner = Instance.new("UICorner", HexInput)
HexInputCorner.CornerRadius = UDim.new(0, 6)

-- Color Picker
local ColorPicker = Instance.new("Frame", HitboxSection)
ColorPicker.Size = UDim2.new(0, 60, 0, 60)
ColorPicker.Position = UDim2.new(1, -76, 0, 120)
ColorPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
local ColorPickerCorner = Instance.new("UICorner", ColorPicker)
ColorPickerCorner.CornerRadius = UDim.new(0, 8)

-- Local Section
local LocalSection = Instance.new("Frame", CombatSection)
LocalSection.Size = UDim2.new(1, -32, 0, 80)
LocalSection.Position = UDim2.new(0, 16, 0, 150)
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

-- No Clip Toggle
local NoClipLabel = Instance.new("TextLabel", LocalSection)
NoClipLabel.Size = UDim2.new(1, -100, 0, 20)
NoClipLabel.Position = UDim2.new(0, 16, 0, 40)
NoClipLabel.BackgroundTransparency = 1
NoClipLabel.Text = "No clip"
NoClipLabel.TextColor3 = Config.Colors.Text
NoClipLabel.TextScaled = true
NoClipLabel.Font = Enum.Font.Gotham
NoClipLabel.TextXAlignment = Enum.TextXAlignment.Left

local NoClipToggle = Instance.new("TextButton", LocalSection)
NoClipToggle.Size = UDim2.new(0, 50, 0, 25)
NoClipToggle.Position = UDim2.new(1, -66, 0, 40)
NoClipToggle.BackgroundColor3 = Config.Colors.ToggleOff
NoClipToggle.Text = ""
local NoClipToggleCorner = Instance.new("UICorner", NoClipToggle)
NoClipToggleCorner.CornerRadius = UDim.new(0, 12)

local NoClipToggleKnob = Instance.new("Frame", NoClipToggle)
NoClipToggleKnob.Size = UDim2.new(0, 21, 0, 21)
NoClipToggleKnob.Position = UDim2.new(0, 2, 0, 2)
NoClipToggleKnob.BackgroundColor3 = Config.Colors.Text
local NoClipToggleKnobCorner = Instance.new("UICorner", NoClipToggleKnob)
NoClipToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Inf Jump Toggle
local InfJumpLabel = Instance.new("TextLabel", LocalSection)
InfJumpLabel.Size = UDim2.new(1, -100, 0, 20)
InfJumpLabel.Position = UDim2.new(0, 16, 0, 65)
InfJumpLabel.BackgroundTransparency = 1
InfJumpLabel.Text = "Inf jump"
InfJumpLabel.TextColor3 = Config.Colors.Text
InfJumpLabel.TextScaled = true
InfJumpLabel.Font = Enum.Font.Gotham
InfJumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local InfJumpToggle = Instance.new("TextButton", LocalSection)
InfJumpToggle.Size = UDim2.new(0, 50, 0, 25)
InfJumpToggle.Position = UDim2.new(1, -66, 0, 65)
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

-- ESP Section Content
local ESPEnabledLabel = Instance.new("TextLabel", ESPSection)
ESPEnabledLabel.Size = UDim2.new(1, -100, 0, 30)
ESPEnabledLabel.Position = UDim2.new(0, 16, 0, 16)
ESPEnabledLabel.BackgroundTransparency = 1
ESPEnabledLabel.Text = "Esp enabled"
ESPEnabledLabel.TextColor3 = Config.Colors.Text
ESPEnabledLabel.TextScaled = true
ESPEnabledLabel.Font = Enum.Font.Gotham
ESPEnabledLabel.TextXAlignment = Enum.TextXAlignment.Left

local ESPEnabledToggle = Instance.new("TextButton", ESPSection)
ESPEnabledToggle.Size = UDim2.new(0, 50, 0, 25)
ESPEnabledToggle.Position = UDim2.new(1, -66, 0, 16)
ESPEnabledToggle.BackgroundColor3 = Config.Colors.ToggleOff
ESPEnabledToggle.Text = ""
local ESPEnabledToggleCorner = Instance.new("UICorner", ESPEnabledToggle)
ESPEnabledToggleCorner.CornerRadius = UDim.new(0, 12)

local ESPEnabledToggleKnob = Instance.new("Frame", ESPEnabledToggle)
ESPEnabledToggleKnob.Size = UDim2.new(0, 21, 0, 21)
ESPEnabledToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ESPEnabledToggleKnob.BackgroundColor3 = Config.Colors.Text
local ESPEnabledToggleKnobCorner = Instance.new("UICorner", ESPEnabledToggleKnob)
ESPEnabledToggleKnobCorner.CornerRadius = UDim.new(0, 10)

local ESPNameLabel = Instance.new("TextLabel", ESPSection)
ESPNameLabel.Size = UDim2.new(1, -100, 0, 30)
ESPNameLabel.Position = UDim2.new(0, 16, 0, 50)
ESPNameLabel.BackgroundTransparency = 1
ESPNameLabel.Text = "Esp name"
ESPNameLabel.TextColor3 = Config.Colors.Text
ESPNameLabel.TextScaled = true
ESPNameLabel.Font = Enum.Font.Gotham
ESPNameLabel.TextXAlignment = Enum.TextXAlignment.Left

local ESPNameToggle = Instance.new("TextButton", ESPSection)
ESPNameToggle.Size = UDim2.new(0, 50, 0, 25)
ESPNameToggle.Position = UDim2.new(1, -66, 0, 50)
ESPNameToggle.BackgroundColor3 = Config.Colors.ToggleOff
ESPNameToggle.Text = ""
local ESPNameToggleCorner = Instance.new("UICorner", ESPNameToggle)
ESPNameToggleCorner.CornerRadius = UDim.new(0, 12)

local ESPNameToggleKnob = Instance.new("Frame", ESPNameToggle)
ESPNameToggleKnob.Size = UDim2.new(0, 21, 0, 21)
ESPNameToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ESPNameToggleKnob.BackgroundColor3 = Config.Colors.Text
local ESPNameToggleKnobCorner = Instance.new("UICorner", ESPNameToggleKnob)
ESPNameToggleKnobCorner.CornerRadius = UDim.new(0, 10)

local ESPBoxLabel = Instance.new("TextLabel", ESPSection)
ESPBoxLabel.Size = UDim2.new(1, -100, 0, 30)
ESPBoxLabel.Position = UDim2.new(0, 16, 0, 84)
ESPBoxLabel.BackgroundTransparency = 1
ESPBoxLabel.Text = "Esp box"
ESPBoxLabel.TextColor3 = Config.Colors.Text
ESPBoxLabel.TextScaled = true
ESPBoxLabel.Font = Enum.Font.Gotham
ESPBoxLabel.TextXAlignment = Enum.TextXAlignment.Left

local ESPBoxToggle = Instance.new("TextButton", ESPSection)
ESPBoxToggle.Size = UDim2.new(0, 50, 0, 25)
ESPBoxToggle.Position = UDim2.new(1, -66, 0, 84)
ESPBoxToggle.BackgroundColor3 = Config.Colors.ToggleOff
ESPBoxToggle.Text = ""
local ESPBoxToggleCorner = Instance.new("UICorner", ESPBoxToggle)
ESPBoxToggleCorner.CornerRadius = UDim.new(0, 12)

local ESPBoxToggleKnob = Instance.new("Frame", ESPBoxToggle)
ESPBoxToggleKnob.Size = UDim2.new(0, 21, 0, 21)
ESPBoxToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ESPBoxToggleKnob.BackgroundColor3 = Config.Colors.Text
local ESPBoxToggleKnobCorner = Instance.new("UICorner", ESPBoxToggleKnob)
ESPBoxToggleKnobCorner.CornerRadius = UDim.new(0, 10)

local ESPTracerLabel = Instance.new("TextLabel", ESPSection)
ESPTracerLabel.Size = UDim2.new(1, -100, 0, 30)
ESPTracerLabel.Position = UDim2.new(0, 16, 0, 118)
ESPTracerLabel.BackgroundTransparency = 1
ESPTracerLabel.Text = "Esp tracer"
ESPTracerLabel.TextColor3 = Config.Colors.Text
ESPTracerLabel.TextScaled = true
ESPTracerLabel.Font = Enum.Font.Gotham
ESPTracerLabel.TextXAlignment = Enum.TextXAlignment.Left

local ESPTracerToggle = Instance.new("TextButton", ESPSection)
ESPTracerToggle.Size = UDim2.new(0, 50, 0, 25)
ESPTracerToggle.Position = UDim2.new(1, -66, 0, 118)
ESPTracerToggle.BackgroundColor3 = Config.Colors.ToggleOff
ESPTracerToggle.Text = ""
local ESPTracerToggleCorner = Instance.new("UICorner", ESPTracerToggle)
ESPTracerToggleCorner.CornerRadius = UDim.new(0, 12)

local ESPTracerToggleKnob = Instance.new("Frame", ESPTracerToggle)
ESPTracerToggleKnob.Size = UDim2.new(0, 21, 0, 21)
ESPTracerToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ESPTracerToggleKnob.BackgroundColor3 = Config.Colors.Text
local ESPTracerToggleKnobCorner = Instance.new("UICorner", ESPTracerToggleKnob)
ESPTracerToggleKnobCorner.CornerRadius = UDim.new(0, 10)

-- Toggle functionality
local function createToggle(toggle, knob, callback)
    local isOn = false
    
    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            toggle.BackgroundColor3 = Config.Colors.Accent
            knob.Position = UDim2.new(1, -23, 0, 2)
        else
            toggle.BackgroundColor3 = Config.Colors.ToggleOff
            knob.Position = UDim2.new(0, 2, 0, 2)
        end
        if callback then
            callback(isOn)
        end
    end)
    
    return function() return isOn end
end

-- Create toggles
local hitboxEnabled = createToggle(HitboxToggle, HitboxToggleKnob, function(enabled)
    META_HEAD = enabled
end)

local noClipEnabled = createToggle(NoClipToggle, NoClipToggleKnob, function(enabled)
    -- No clip functionality
end)

local infJumpEnabled = createToggle(InfJumpToggle, InfJumpToggleKnob, function(enabled)
    -- Inf jump functionality
end)

local espEnabled = createToggle(ESPEnabledToggle, ESPEnabledToggleKnob, function(enabled)
    VIZIJA_ENABLED = enabled
end)

local espNameEnabled = createToggle(ESPNameToggle, ESPNameToggleKnob, function(enabled)
    NAMETAG_ENABLED = enabled
end)

local espBoxEnabled = createToggle(ESPBoxToggle, ESPBoxToggleKnob, function(enabled)
    -- ESP box functionality
end)

local espTracerEnabled = createToggle(ESPTracerToggle, ESPTracerToggleKnob, function(enabled)
    -- ESP tracer functionality
end)

-- Hitbox value input handling
HitboxValueBox.FocusLost:Connect(function()
    local value = tonumber(HitboxValueBox.Text)
    if value and value >= HITBOX_FOV_MIN and value <= HITBOX_FOV_MAX then
        META_FOV = value
    else
        HitboxValueBox.Text = tostring(META_FOV)
    end
end)

-- Color picker functionality
local function updateColor()
    local r = tonumber(RInput.Text) or 255
    local g = tonumber(GInput.Text) or 0
    local b = tonumber(BInput.Text) or 0
    
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    local color = Color3.fromRGB(r, g, b)
    HITBOX_HEAD_COLOR = color
    ColorPicker.BackgroundColor3 = color
    HexInput.Text = string.format("#%02X%02X%02X", r, g, b)
end

RInput.FocusLost:Connect(updateColor)
GInput.FocusLost:Connect(updateColor)
BInput.FocusLost:Connect(updateColor)

-- Minimize functionality
MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 370, 0, 600)
        MainFrame.Position = Config.MenuPosition
        isMinimized = false
    else
        MainFrame.Size = Config.MinimizedSize
        MainFrame.Position = Config.MinimizedPosition
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
    if not META_HEAD then return end
    
    local closestPlayer = getClosestPlayer()
    if not closestPlayer or not closestPlayer.Character then return end
    
    local head = closestPlayer.Character:FindFirstChild("Head")
    if not head then return end
    
    -- Expand head hitbox
    local originalSize = head.Size
    head.Size = Vector3.new(META_FOV, META_FOV, META_FOV)
    
    -- Visual indicator (optional)
    if head:FindFirstChild("HitboxIndicator") then
        head.HitboxIndicator:Destroy()
    end
    
    local indicator = Instance.new("Part")
    indicator.Name = "HitboxIndicator"
    indicator.Size = Vector3.new(META_FOV, META_FOV, META_FOV)
    indicator.Position = head.Position
    indicator.Anchored = true
    indicator.CanCollide = false
    indicator.Transparency = 0.8
    indicator.Color = HITBOX_HEAD_COLOR
    indicator.Material = Enum.Material.Neon
    indicator.Parent = head
    
    -- Clean up after a short time
    game:GetService("Debris"):AddItem(indicator, 0.1)
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

-- Cleanup on script end
game:BindToClose(function()
    for _, espBox in pairs(vizijaBoxes) do
        espBox:Destroy()
    end
    if FOVCircle then
        FOVCircle:Destroy()
    end
end)

print("Alesto Script loaded successfully!") 