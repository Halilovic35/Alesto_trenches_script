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
    Accent = Color3.fromRGB(255, 20, 147), -- pink umesto plava
    Text = Color3.fromRGB(255, 255, 255),
    Minimized = Color3.fromRGB(40, 40, 50),
    Section = Color3.fromRGB(36, 36, 48),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    Slider = Color3.fromRGB(60, 60, 80),
    SliderBar = Color3.fromRGB(80, 80, 100)
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
Title.Text = "Alesto Hub | Combat & ESP"
Title.TextColor3 = Config.Colors.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 38, 0, 38)
MinimizeBtn.Position = UDim2.new(1, -44, 0, 5)
MinimizeBtn.BackgroundColor3 = Config.Colors.Accent
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Config.Colors.Text
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
local MinBtnCorner = Instance.new("UICorner", MinimizeBtn)
MinBtnCorner.CornerRadius = UDim.new(0, 12)

-- MODERNI TABOVI
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
CombatTab.TextScaled = true
CombatTab.Font = Enum.Font.GothamBold
local CombatTabCorner = Instance.new("UICorner", CombatTab)
CombatTabCorner.CornerRadius = UDim.new(0, 12)

local ESPTab = Instance.new("TextButton", TabsFrame)
ESPTab.Size = UDim2.new(0.5, -2, 1, 0)
ESPTab.Position = UDim2.new(0.5, 2, 0, 0)
ESPTab.BackgroundColor3 = Config.Colors.Secondary
ESPTab.Text = "ESP"
ESPTab.TextColor3 = Config.Colors.Text
ESPTab.TextScaled = true
ESPTab.Font = Enum.Font.GothamBold
local ESPTabCorner = Instance.new("UICorner", ESPTab)
ESPTabCorner.CornerRadius = UDim.new(0, 12)

-- SVE SEKCIJE (Combat/ESP) SU U POSEBNIM FRAME-ovima, SAKRIVAJU SE OVISNO O TABU
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

CombatTab.MouseButton1Click:Connect(function()
    CombatTab.BackgroundColor3 = Config.Colors.Accent
    ESPTab.BackgroundColor3 = Config.Colors.Secondary
    CombatSection.Visible = true
    ESPSection.Visible = false
end)
ESPTab.MouseButton1Click:Connect(function()
    CombatTab.BackgroundColor3 = Config.Colors.Secondary
    ESPTab.BackgroundColor3 = Config.Colors.Accent
    CombatSection.Visible = false
    ESPSection.Visible = true
end)

-- Section: Vizija (ESP)
local VizijaSection = Instance.new("Frame", ESPSection)
VizijaSection.Size = UDim2.new(1, -32, 0, 80)
VizijaSection.Position = UDim2.new(0, 16, 0, 16)
VizijaSection.BackgroundColor3 = Config.Colors.Section
VizijaSection.BorderSizePixel = 0
local VizijaCorner = Instance.new("UICorner", VizijaSection)
VizijaCorner.CornerRadius = UDim.new(0, 12)

local VizijaLabel = Instance.new("TextLabel", VizijaSection)
VizijaLabel.Size = UDim2.new(0, 120, 0, 32)
VizijaLabel.Position = UDim2.new(0, 10, 0, 8)
VizijaLabel.BackgroundTransparency = 1
VizijaLabel.Text = "Vizija (kutije)"
VizijaLabel.TextColor3 = Config.Colors.Text
VizijaLabel.TextScaled = true
VizijaLabel.Font = Enum.Font.GothamBold

local VizijaToggle = Instance.new("TextButton", VizijaSection)
VizijaToggle.Size = UDim2.new(0, 100, 0, 32)
VizijaToggle.Position = UDim2.new(0, 140, 0, 8)
VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
VizijaToggle.TextColor3 = Config.Colors.Text
VizijaToggle.TextScaled = true
VizijaToggle.Font = Enum.Font.GothamBold
local VizijaToggleCorner = Instance.new("UICorner", VizijaToggle)
VizijaToggleCorner.CornerRadius = UDim.new(0, 8)

local OnlyEnemiesBtn = Instance.new("TextButton", VizijaSection)
OnlyEnemiesBtn.Size = UDim2.new(0, 120, 0, 28)
OnlyEnemiesBtn.Position = UDim2.new(0, 10, 0, 48)
OnlyEnemiesBtn.BackgroundColor3 = Config.Colors.ToggleOff
OnlyEnemiesBtn.Text = VIZIJA_ENEMY_ONLY and "Samo protivnici" or "Svi igrači"
OnlyEnemiesBtn.TextColor3 = Config.Colors.Text
OnlyEnemiesBtn.TextScaled = true
OnlyEnemiesBtn.Font = Enum.Font.Gotham
local OnlyEnemiesCorner = Instance.new("UICorner", OnlyEnemiesBtn)
OnlyEnemiesCorner.CornerRadius = UDim.new(0, 8)

OnlyEnemiesBtn.MouseButton1Click:Connect(function()
    VIZIJA_ENEMY_ONLY = not VIZIJA_ENEMY_ONLY
    OnlyEnemiesBtn.Text = VIZIJA_ENEMY_ONLY and "Samo protivnici" or "Svi igrači"
    OnlyEnemiesBtn.BackgroundColor3 = VIZIJA_ENEMY_ONLY and Config.Colors.Accent or Config.Colors.ToggleOff
end)

VizijaToggle.MouseButton1Click:Connect(function()
    VIZIJA_ENABLED = not VIZIJA_ENABLED
    VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
    VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
    if not VIZIJA_ENABLED then
        for _,v in pairs(vizijaBoxes) do v:Remove() end
        vizijaBoxes = {}
    end
end)

-- Section: Boja kutije (Color Wheel)
local ColorSection = Instance.new("Frame", ESPSection)
ColorSection.Size = UDim2.new(1, -32, 0, 100)
ColorSection.Position = UDim2.new(0, 16, 0, 110)
ColorSection.BackgroundColor3 = Config.Colors.Section
ColorSection.BorderSizePixel = 0
local ColorCorner = Instance.new("UICorner", ColorSection)
ColorCorner.CornerRadius = UDim.new(0, 12)

local ColorLabel = Instance.new("TextLabel", ColorSection)
ColorLabel.Size = UDim2.new(0, 120, 0, 32)
ColorLabel.Position = UDim2.new(0, 10, 0, 8)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Boja kutije"
ColorLabel.TextColor3 = Config.Colors.Text
ColorLabel.TextScaled = true
ColorLabel.Font = Enum.Font.GothamBold

-- Color wheel (simple implementation)
local ColorWheel = Instance.new("ImageButton", ColorSection)
ColorWheel.Size = UDim2.new(0, 70, 0, 70)
ColorWheel.Position = UDim2.new(0, 140, 0, 8)
ColorWheel.BackgroundTransparency = 1
ColorWheel.Image = "rbxassetid://6020299385" -- Roblox color wheel asset

local ColorPreview = Instance.new("Frame", ColorSection)
ColorPreview.Size = UDim2.new(0, 32, 0, 32)
ColorPreview.Position = UDim2.new(0, 220, 0, 24)
ColorPreview.BackgroundColor3 = VIZIJA_COLOR
ColorPreview.BorderSizePixel = 0
local ColorPreviewCorner = Instance.new("UICorner", ColorPreview)
ColorPreviewCorner.CornerRadius = UDim.new(1, 0)

ColorWheel.MouseButton1Down:Connect(function(input)
    local abs = ColorWheel.AbsolutePosition
    local rel = Vector2.new(input.X - abs.X, input.Y - abs.Y)
    local r = ColorWheel.AbsoluteSize.X/2
    local center = Vector2.new(r, r)
    local dist = (rel - center).Magnitude
    if dist <= r then
        local angle = math.atan2(rel.Y - r, rel.X - r)
        local hue = (angle/(2*math.pi))%1
        VIZIJA_COLOR = Color3.fromHSV(hue, 1, 1)
        ColorPreview.BackgroundColor3 = VIZIJA_COLOR
    end
end)

-- Dodaj i mouse movement za smooth color picking
local draggingColor = false
ColorWheel.MouseButton1Down:Connect(function()
    draggingColor = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingColor = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingColor and input.UserInputType == Enum.UserInputType.MouseMovement then
        local abs = ColorWheel.AbsolutePosition
        local rel = Vector2.new(input.Position.X - abs.X, input.Position.Y - abs.Y)
        local r = ColorWheel.AbsoluteSize.X/2
        local center = Vector2.new(r, r)
        local dist = (rel - center).Magnitude
        if dist <= r then
            local angle = math.atan2(rel.Y - r, rel.X - r)
            local hue = (angle/(2*math.pi))%1
            VIZIJA_COLOR = Color3.fromHSV(hue, 1, 1)
            ColorPreview.BackgroundColor3 = VIZIJA_COLOR
        end
    end
end)

-- Nova sekcija: Imena + Krozzid
local ImenaSection = Instance.new("Frame", ESPSection)
ImenaSection.Size = UDim2.new(1, -32, 0, 70)
ImenaSection.Position = UDim2.new(0, 16, 0, 230)
ImenaSection.BackgroundColor3 = Config.Colors.Section
ImenaSection.BorderSizePixel = 0
local ImenaSectionCorner = Instance.new("UICorner", ImenaSection)
ImenaSectionCorner.CornerRadius = UDim.new(0, 12)

local ImenaLabel = Instance.new("TextLabel", ImenaSection)
ImenaLabel.Size = UDim2.new(0, 80, 0, 28)
ImenaLabel.Position = UDim2.new(0, 10, 0, 8)
ImenaLabel.BackgroundTransparency = 1
ImenaLabel.Text = "Imena"
ImenaLabel.TextColor3 = Config.Colors.Text
ImenaLabel.TextScaled = true
ImenaLabel.Font = Enum.Font.GothamBold

local ImenaToggle = Instance.new("TextButton", ImenaSection)
ImenaToggle.Size = UDim2.new(0, 90, 0, 28)
ImenaToggle.Position = UDim2.new(0, 100, 0, 8)
ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
ImenaToggle.TextColor3 = Config.Colors.Text
ImenaToggle.TextScaled = true
ImenaToggle.Font = Enum.Font.GothamBold
local ImenaToggleCorner = Instance.new("UICorner", ImenaToggle)
ImenaToggleCorner.CornerRadius = UDim.new(0, 8)
ImenaToggle.MouseButton1Click:Connect(function()
    NAMETAG_ENABLED = not NAMETAG_ENABLED
    ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
    ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
end)

local ImenaScaleLabel = Instance.new("TextLabel", ImenaSection)
ImenaScaleLabel.Size = UDim2.new(0, 60, 0, 28)
ImenaScaleLabel.Position = UDim2.new(0, 200, 0, 8)
ImenaScaleLabel.BackgroundTransparency = 1
ImenaScaleLabel.Text = "Veličina"
ImenaScaleLabel.TextColor3 = Config.Colors.Text
ImenaScaleLabel.TextScaled = true
ImenaScaleLabel.Font = Enum.Font.Gotham

local ImenaScaleSlider = Instance.new("TextButton", ImenaSection)
ImenaScaleSlider.Size = UDim2.new(0, 60, 0, 28)
ImenaScaleSlider.Position = UDim2.new(0, 270, 0, 8)
ImenaScaleSlider.BackgroundColor3 = Config.Colors.Accent
ImenaScaleSlider.Text = tostring(NAMETAG_SCALE)
ImenaScaleSlider.TextColor3 = Config.Colors.Text
ImenaScaleSlider.TextScaled = true
ImenaScaleSlider.Font = Enum.Font.GothamBold
local draggingImenaScale = false
ImenaScaleSlider.MouseButton1Down:Connect(function()
    draggingImenaScale = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingImenaScale = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingImenaScale and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - ImenaScaleSlider.AbsolutePosition.X) / ImenaScaleSlider.AbsoluteSize.X, 0, 1)
        local value = math.floor(rel * 49 + 1) / 10 -- 0.1 do 5.0
        NAMETAG_SCALE = value
        ImenaScaleSlider.Text = tostring(value)
    end
end)
NAMETAG_SCALE = 0.1
ImenaScaleSlider.Text = tostring(NAMETAG_SCALE)

-- Krozzid toggle u Imena sekciji
local KrozzidToggle = Instance.new("TextButton", ImenaSection)
KrozzidToggle.Size = UDim2.new(0, 120, 0, 28)
KrozzidToggle.Position = UDim2.new(0, 10, 0, 40)
KrozzidToggle.BackgroundColor3 = KROZZID_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
KrozzidToggle.Text = KROZZID_ENABLED and "Krozzid: Uključeno" or "Krozzid: Isključeno"
KrozzidToggle.TextColor3 = Config.Colors.Text
KrozzidToggle.TextScaled = true
KrozzidToggle.Font = Enum.Font.GothamBold
local KrozzidToggleCorner = Instance.new("UICorner", KrozzidToggle)
KrozzidToggleCorner.CornerRadius = UDim.new(0, 8)
local KROZZID_ENABLED = false
KrozzidToggle.MouseButton1Click:Connect(function()
    KROZZID_ENABLED = not KROZZID_ENABLED
    KrozzidToggle.Text = KROZZID_ENABLED and "Krozzid: Uključeno" or "Krozzid: Isključeno"
    KrozzidToggle.BackgroundColor3 = KROZZID_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
end)

-- Section: Meta (Hitbox) - PREMESTI U COMBAT SECTION
local MetaSection = Instance.new("Frame", CombatSection)
MetaSection.Size = UDim2.new(1, -32, 0, 150)
MetaSection.Position = UDim2.new(0, 16, 0, 16)
MetaSection.BackgroundColor3 = Config.Colors.Section
MetaSection.BorderSizePixel = 0
local MetaCorner = Instance.new("UICorner", MetaSection)
MetaCorner.CornerRadius = UDim.new(0, 12)

local MetaLabel = Instance.new("TextLabel", MetaSection)
MetaLabel.Size = UDim2.new(0, 120, 0, 32)
MetaLabel.Position = UDim2.new(0, 10, 0, 8)
MetaLabel.BackgroundTransparency = 1
MetaLabel.Text = "Povecaj glavudju"
MetaLabel.TextColor3 = Config.Colors.Text
MetaLabel.TextScaled = true
MetaLabel.Font = Enum.Font.GothamBold

local FOVLabel = Instance.new("TextLabel", MetaSection)
FOVLabel.Size = UDim2.new(0, 60, 0, 28)
FOVLabel.Position = UDim2.new(0, 10, 0, 48)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV"
FOVLabel.TextColor3 = Config.Colors.Text
FOVLabel.TextScaled = true
FOVLabel.Font = Enum.Font.Gotham

local FOVSlider = Instance.new("TextButton", MetaSection)
FOVSlider.Size = UDim2.new(0, 180, 0, 28)
FOVSlider.Position = UDim2.new(0, 70, 0, 48)
FOVSlider.BackgroundColor3 = Config.Colors.Accent
FOVSlider.Text = tostring(META_FOV)
FOVSlider.TextColor3 = Config.Colors.Text
FOVSlider.TextScaled = true
FOVSlider.Font = Enum.Font.GothamBold
local draggingFOV = false
FOVSlider.MouseButton1Down:Connect(function()
    draggingFOV = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - FOVSlider.AbsolutePosition.X) / FOVSlider.AbsoluteSize.X, 0, 1)
        local value = math.floor(rel * (HITBOX_FOV_MAX-HITBOX_FOV_MIN) + HITBOX_FOV_MIN) -- 1 do 200
        META_FOV = value
        FOVSlider.Text = tostring(value)
    end
end)

local HeadBtn = Instance.new("TextButton", MetaSection)
HeadBtn.Size = UDim2.new(0, 70, 0, 28)
HeadBtn.Position = UDim2.new(0, 10, 0, 60)
HeadBtn.BackgroundColor3 = META_HEAD and Config.Colors.Accent or Config.Colors.ToggleOff
HeadBtn.Text = "Glava"
HeadBtn.TextColor3 = Config.Colors.Text
HeadBtn.TextScaled = true
HeadBtn.Font = Enum.Font.GothamBold
local HeadCorner = Instance.new("UICorner", HeadBtn)
HeadCorner.CornerRadius = UDim.new(0, 8)

local TorsoBtn = Instance.new("TextButton", MetaSection)
TorsoBtn.Size = UDim2.new(0, 70, 0, 28)
TorsoBtn.Position = UDim2.new(0, 90, 0, 60)
TorsoBtn.BackgroundColor3 = META_TORSO and Config.Colors.Accent or Config.Colors.ToggleOff
TorsoBtn.Text = "Tijelo"
TorsoBtn.TextColor3 = Config.Colors.Text
TorsoBtn.TextScaled = true
TorsoBtn.Font = Enum.Font.GothamBold
local TorsoCorner = Instance.new("UICorner", TorsoBtn)
TorsoCorner.CornerRadius = UDim.new(0, 8)

HeadBtn.MouseButton1Click:Connect(function()
    META_HEAD = not META_HEAD
    HeadBtn.BackgroundColor3 = META_HEAD and Config.Colors.Accent or Config.Colors.ToggleOff
end)
TorsoBtn.MouseButton1Click:Connect(function()
    META_TORSO = not META_TORSO
    TorsoBtn.BackgroundColor3 = META_TORSO and Config.Colors.Accent or Config.Colors.ToggleOff
end)

-- GUI: Dugmad za biranje boje glave
local HeadColorLabel = Instance.new("TextLabel", MetaSection)
HeadColorLabel.Size = UDim2.new(0, 80, 0, 28)
HeadColorLabel.Position = UDim2.new(0, 170, 0, 60)
HeadColorLabel.BackgroundTransparency = 1
HeadColorLabel.Text = "Boja glave"
HeadColorLabel.TextColor3 = Config.Colors.Text
HeadColorLabel.TextScaled = true
HeadColorLabel.Font = Enum.Font.Gotham

local RedBtn = Instance.new("TextButton", MetaSection)
RedBtn.Size = UDim2.new(0, 28, 0, 28)
RedBtn.Position = UDim2.new(0, 260, 0, 60)
RedBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedBtn.Text = ""
local RedBtnCorner = Instance.new("UICorner", RedBtn)
RedBtnCorner.CornerRadius = UDim.new(1, 0)

local BlueBtn = Instance.new("TextButton", MetaSection)
BlueBtn.Size = UDim2.new(0, 28, 0, 28)
BlueBtn.Position = UDim2.new(0, 295, 0, 60)
BlueBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
BlueBtn.Text = ""
local BlueBtnCorner = Instance.new("UICorner", BlueBtn)
BlueBtnCorner.CornerRadius = UDim.new(1, 0)

local GreenBtn = Instance.new("TextButton", MetaSection)
GreenBtn.Size = UDim2.new(0, 28, 0, 28)
GreenBtn.Position = UDim2.new(0, 330, 0, 60)
GreenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
GreenBtn.Text = ""
local GreenBtnCorner = Instance.new("UICorner", GreenBtn)
GreenBtnCorner.CornerRadius = UDim.new(1, 0)

RedBtn.MouseButton1Click:Connect(function()
    HITBOX_HEAD_COLOR = Color3.fromRGB(255, 0, 0)
end)
BlueBtn.MouseButton1Click:Connect(function()
    HITBOX_HEAD_COLOR = Color3.fromRGB(0, 0, 255)
end)
GreenBtn.MouseButton1Click:Connect(function()
    HITBOX_HEAD_COLOR = Color3.fromRGB(0, 255, 0)
end)

-- FOV ZOOM TOGGLE I SLIDER - DODAJ U COMBAT SECTION
local FOV_ENABLED = false
local FOVToggle = Instance.new("TextButton", CombatSection)
FOVToggle.Size = UDim2.new(0, 90, 0, 28)
FOVToggle.Position = UDim2.new(0, 16, 0, 180)
FOVToggle.BackgroundColor3 = FOV_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
FOVToggle.Text = FOV_ENABLED and "FOV ON" or "FOV OFF"
FOVToggle.TextColor3 = Config.Colors.Text
FOVToggle.TextScaled = true
FOVToggle.Font = Enum.Font.GothamBold
local FOVToggleCorner = Instance.new("UICorner", FOVToggle)
FOVToggleCorner.CornerRadius = UDim.new(0, 8)
FOVToggle.MouseButton1Click:Connect(function()
    FOV_ENABLED = not FOV_ENABLED
    FOVToggle.Text = FOV_ENABLED and "FOV ON" or "FOV OFF"
    FOVToggle.BackgroundColor3 = FOV_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
    if FOV_ENABLED then
        Camera.FieldOfView = currentFOV
    else
        Camera.FieldOfView = FOV_DEFAULT
    end
end)

local FOVGuiLabel = Instance.new("TextLabel", CombatSection)
FOVGuiLabel.Size = UDim2.new(0, 100, 0, 28)
FOVGuiLabel.Position = UDim2.new(0, 120, 0, 180)
FOVGuiLabel.BackgroundTransparency = 1
FOVGuiLabel.Text = "FOV (zoom)"
FOVGuiLabel.TextColor3 = Config.Colors.Text
FOVGuiLabel.TextScaled = true
FOVGuiLabel.Font = Enum.Font.GothamBold

local FOVGuiSlider = Instance.new("TextButton", CombatSection)
FOVGuiSlider.Size = UDim2.new(0, 180, 0, 28)
FOVGuiSlider.Position = UDim2.new(0, 230, 0, 180)
FOVGuiSlider.BackgroundColor3 = Config.Colors.Accent
FOVGuiSlider.Text = tostring(currentFOV)
FOVGuiSlider.TextColor3 = Config.Colors.Text
FOVGuiSlider.TextScaled = true
FOVGuiSlider.Font = Enum.Font.GothamBold
local draggingFOVGui = false
FOVGuiSlider.MouseButton1Down:Connect(function()
    draggingFOVGui = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOVGui = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFOVGui and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - FOVGuiSlider.AbsolutePosition.X) / FOVGuiSlider.AbsoluteSize.X, 0, 1)
        local value = math.floor(rel * (FOV_MAX-FOV_MIN) + FOV_MIN) -- 20 do 120 za zoom
        currentFOV = value
        FOVGuiSlider.Text = tostring(value)
        if FOV_ENABLED then
            Camera.FieldOfView = value
        end
    end
end)

-- Dodaj Infinite Jump sekciju
local InfiniteJumpSection = Instance.new("Frame", CombatSection)
InfiniteJumpSection.Size = UDim2.new(1, -32, 0, 70)
InfiniteJumpSection.Position = UDim2.new(0, 16, 0, 230)
InfiniteJumpSection.BackgroundColor3 = Config.Colors.Section
InfiniteJumpSection.BorderSizePixel = 0
local InfiniteJumpCorner = Instance.new("UICorner", InfiniteJumpSection)
InfiniteJumpCorner.CornerRadius = UDim.new(0, 12)

local InfiniteJumpLabel = Instance.new("TextLabel", InfiniteJumpSection)
InfiniteJumpLabel.Size = UDim2.new(0, 120, 0, 28)
InfiniteJumpLabel.Position = UDim2.new(0, 10, 0, 8)
InfiniteJumpLabel.BackgroundTransparency = 1
InfiniteJumpLabel.Text = "Infinite Jump"
InfiniteJumpLabel.TextColor3 = Config.Colors.Text
InfiniteJumpLabel.TextScaled = true
InfiniteJumpLabel.Font = Enum.Font.GothamBold

local INFINITE_JUMP_ENABLED = false
local InfiniteJumpToggle = Instance.new("TextButton", InfiniteJumpSection)
InfiniteJumpToggle.Size = UDim2.new(0, 90, 0, 28)
InfiniteJumpToggle.Position = UDim2.new(0, 140, 0, 8)
InfiniteJumpToggle.BackgroundColor3 = INFINITE_JUMP_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
InfiniteJumpToggle.Text = INFINITE_JUMP_ENABLED and "Uključeno" or "Isključeno"
InfiniteJumpToggle.TextColor3 = Config.Colors.Text
InfiniteJumpToggle.TextScaled = true
InfiniteJumpToggle.Font = Enum.Font.GothamBold
local InfiniteJumpToggleCorner = Instance.new("UICorner", InfiniteJumpToggle)
InfiniteJumpToggleCorner.CornerRadius = UDim.new(0, 8)
InfiniteJumpToggle.MouseButton1Click:Connect(function()
    INFINITE_JUMP_ENABLED = not INFINITE_JUMP_ENABLED
    InfiniteJumpToggle.Text = INFINITE_JUMP_ENABLED and "Uključeno" or "Isključeno"
    InfiniteJumpToggle.BackgroundColor3 = INFINITE_JUMP_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
end)

-- Bindovi
local ESP_BIND = nil
local HITBOX_BIND = nil
local NAMETAG_BIND = nil
local KROZZID_BIND = nil
local INFINITE_JUMP_BIND = nil
local waitingForBind = nil -- "ESP", "HITBOX", "NAMETAG", "KROZZID", "INFINITE_JUMP"

-- Nova sekcija: Bindovi - PREMESTI NA DNO MAIN FRAME
local BindoviSection = Instance.new("Frame", MainFrame)
BindoviSection.Size = UDim2.new(1, -32, 0, 80)
BindoviSection.Position = UDim2.new(0, 16, 1, -100)
BindoviSection.BackgroundColor3 = Config.Colors.Section
BindoviSection.BorderSizePixel = 0
local BindoviSectionCorner = Instance.new("UICorner", BindoviSection)
BindoviSectionCorner.CornerRadius = UDim.new(0, 12)

local BindoviLabel = Instance.new("TextLabel", BindoviSection)
BindoviLabel.Size = UDim2.new(0, 120, 0, 28)
BindoviLabel.Position = UDim2.new(0, 10, 0, 8)
BindoviLabel.BackgroundTransparency = 1
BindoviLabel.Text = "Bindovi (tipke)"
BindoviLabel.TextColor3 = Config.Colors.Text
BindoviLabel.TextScaled = true
BindoviLabel.Font = Enum.Font.GothamBold

local ESPBindBtn = Instance.new("TextButton", BindoviSection)
ESPBindBtn.Size = UDim2.new(0, 70, 0, 28)
ESPBindBtn.Position = UDim2.new(0, 140, 0, 8)
ESPBindBtn.BackgroundColor3 = Config.Colors.Accent
ESPBindBtn.Text = "ESP: "..tostring(ESP_BIND and ESP_BIND.Name or "Nema binda")
ESPBindBtn.TextColor3 = Config.Colors.Text
ESPBindBtn.TextScaled = true
ESPBindBtn.Font = Enum.Font.GothamBold
local ESPBindCorner = Instance.new("UICorner", ESPBindBtn)
ESPBindCorner.CornerRadius = UDim.new(0, 8)

local HitboxBindBtn = Instance.new("TextButton", BindoviSection)
HitboxBindBtn.Size = UDim2.new(0, 80, 0, 28)
HitboxBindBtn.Position = UDim2.new(0, 220, 0, 8)
HitboxBindBtn.BackgroundColor3 = Config.Colors.Accent
HitboxBindBtn.Text = "Glavudja: "..tostring(HITBOX_BIND and HITBOX_BIND.Name or "Nema binda")
HitboxBindBtn.TextColor3 = Config.Colors.Text
HitboxBindBtn.TextScaled = true
HitboxBindBtn.Font = Enum.Font.GothamBold
local HitboxBindCorner = Instance.new("UICorner", HitboxBindBtn)
HitboxBindCorner.CornerRadius = UDim.new(0, 8)

local ImenaBindBtn = Instance.new("TextButton", BindoviSection)
ImenaBindBtn.Size = UDim2.new(0, 70, 0, 28)
ImenaBindBtn.Position = UDim2.new(0, 310, 0, 8)
ImenaBindBtn.BackgroundColor3 = Config.Colors.Accent
ImenaBindBtn.Text = "Imena: "..tostring(NAMETAG_BIND and NAMETAG_BIND.Name or "Nema binda")
ImenaBindBtn.TextColor3 = Config.Colors.Text
ImenaBindBtn.TextScaled = true
ImenaBindBtn.Font = Enum.Font.GothamBold
local ImenaBindCorner = Instance.new("UICorner", ImenaBindBtn)
ImenaBindCorner.CornerRadius = UDim.new(0, 8)

local KrozzidBindBtn = Instance.new("TextButton", BindoviSection)
KrozzidBindBtn.Size = UDim2.new(0, 80, 0, 28)
KrozzidBindBtn.Position = UDim2.new(0, 390, 0, 8)
KrozzidBindBtn.BackgroundColor3 = Config.Colors.Accent
KrozzidBindBtn.Text = "Krozzid: "..tostring(KROZZID_BIND and KROZZID_BIND.Name or "Nema binda")
KrozzidBindBtn.TextColor3 = Config.Colors.Text
KrozzidBindBtn.TextScaled = true
KrozzidBindBtn.Font = Enum.Font.GothamBold
local KrozzidBindCorner = Instance.new("UICorner", KrozzidBindBtn)
KrozzidBindCorner.CornerRadius = UDim.new(0, 8)

local InfiniteJumpBindBtn = Instance.new("TextButton", BindoviSection)
InfiniteJumpBindBtn.Size = UDim2.new(0, 90, 0, 28)
InfiniteJumpBindBtn.Position = UDim2.new(0, 140, 0, 40)
InfiniteJumpBindBtn.BackgroundColor3 = Config.Colors.Accent
InfiniteJumpBindBtn.Text = "Infinite Jump: "..tostring(INFINITE_JUMP_BIND and INFINITE_JUMP_BIND.Name or "Nema binda")
InfiniteJumpBindBtn.TextColor3 = Config.Colors.Text
InfiniteJumpBindBtn.TextScaled = true
InfiniteJumpBindBtn.Font = Enum.Font.GothamBold
local InfiniteJumpBindCorner = Instance.new("UICorner", InfiniteJumpBindBtn)
InfiniteJumpBindCorner.CornerRadius = UDim.new(0, 8)

ESPBindBtn.MouseButton1Click:Connect(function()
    ESPBindBtn.Text = "Pritisni tipku..."
    waitingForBind = "ESP"
end)
HitboxBindBtn.MouseButton1Click:Connect(function()
    HitboxBindBtn.Text = "Pritisni tipku..."
    waitingForBind = "HITBOX"
end)
ImenaBindBtn.MouseButton1Click:Connect(function()
    ImenaBindBtn.Text = "Pritisni tipku..."
    waitingForBind = "NAMETAG"
end)
KrozzidBindBtn.MouseButton1Click:Connect(function()
    KrozzidBindBtn.Text = "Pritisni tipku..."
    waitingForBind = "KROZZID"
end)
InfiniteJumpBindBtn.MouseButton1Click:Connect(function()
    InfiniteJumpBindBtn.Text = "Pritisni tipku..."
    waitingForBind = "INFINITE_JUMP"
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if waitingForBind == "ESP" then
        ESP_BIND = input.KeyCode
        ESPBindBtn.Text = "ESP: "..tostring(ESP_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "HITBOX" then
        HITBOX_BIND = input.KeyCode
        HitboxBindBtn.Text = "Glavudja: "..tostring(HITBOX_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "NAMETAG" then
        NAMETAG_BIND = input.KeyCode
        ImenaBindBtn.Text = "Imena: "..tostring(NAMETAG_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "KROZZID" then
        KROZZID_BIND = input.KeyCode
        KrozzidBindBtn.Text = "Krozzid: "..tostring(KROZZID_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "INFINITE_JUMP" then
        INFINITE_JUMP_BIND = input.KeyCode
        InfiniteJumpBindBtn.Text = "Infinite Jump: "..tostring(INFINITE_JUMP_BIND.Name)
        waitingForBind = nil
        return
    end
    -- Bind funkcionalnost - samo ako bind postoji
    if ESP_BIND and input.KeyCode == ESP_BIND then
        VIZIJA_ENABLED = not VIZIJA_ENABLED
        VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
        VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
        if not VIZIJA_ENABLED then
            for _,v in pairs(vizijaBoxes) do v:Remove() end
            vizijaBoxes = {}
        end
    elseif HITBOX_BIND and input.KeyCode == HITBOX_BIND then
        if META_HEAD or META_TORSO then
            META_HEAD = false
            META_TORSO = false
            HeadBtn.BackgroundColor3 = Config.Colors.ToggleOff
            TorsoBtn.BackgroundColor3 = Config.Colors.ToggleOff
        else
            META_HEAD = true
            HeadBtn.BackgroundColor3 = Config.Colors.Accent
        end
    elseif NAMETAG_BIND and input.KeyCode == NAMETAG_BIND then
        NAMETAG_ENABLED = not NAMETAG_ENABLED
        ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
        ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
    elseif KROZZID_BIND and input.KeyCode == KROZZID_BIND then
        -- Krozzid: pronađi i highlightaj prvog protivnika kroz zid
        local origin = Camera.CFrame.Position
        local direction = Camera.CFrame.LookVector * 1000
        local ignoreList = {Players.LocalPlayer.Character}
        local target = krozZid(origin, direction, ignoreList)
        if target and target:FindFirstChild("Head") then
            -- Highlight protivnika (npr. crveni SelectionBox na glavi)
            local head = target.Head
            if not head:FindFirstChild("KrozzidHighlight") then
                local sb = Instance.new("SelectionBox")
                sb.Name = "KrozzidHighlight"
                sb.Adornee = head
                sb.Color3 = Color3.fromRGB(255,0,0)
                sb.LineThickness = 0.1
                sb.Parent = head
                game.Debris:AddItem(sb, 1.5)
            end
        end
    elseif INFINITE_JUMP_BIND and input.KeyCode == INFINITE_JUMP_BIND then
        INFINITE_JUMP_ENABLED = not INFINITE_JUMP_ENABLED
        InfiniteJumpToggle.Text = INFINITE_JUMP_ENABLED and "Uključeno" or "Isključeno"
        InfiniteJumpToggle.BackgroundColor3 = INFINITE_JUMP_ENABLED and Config.Colors.Accent or Config.Colors.ToggleOff
    end
end)

-- Infinite Jump Input Handler
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if INFINITE_JUMP_ENABLED and INFINITE_JUMP_BIND and input.KeyCode == INFINITE_JUMP_BIND then
        local player = Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            humanoid.Jump = true
        end
    end
end)

-- Minimized (kockica) GUI
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = miniName
MiniFrame.Size = Config.MinimizedSize
MiniFrame.Position = Config.MinimizedPosition
MiniFrame.BackgroundColor3 = Config.Colors.Minimized
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.Parent = ScreenGui
local MiniCorner = Instance.new("UICorner", MiniFrame)
MiniCorner.CornerRadius = UDim.new(1, 0)

local MiniBtn = Instance.new("TextButton", MiniFrame)
MiniBtn.Size = UDim2.new(1, 0, 1, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Text = ">"
MiniBtn.TextColor3 = Config.Colors.Text
MiniBtn.TextScaled = true
MiniBtn.Font = Enum.Font.GothamBold

-- Dragging logic
local function enableDrag(frame)
    local dragging = false
    local dragInput, mousePos, framePos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

enableDrag(MainFrame)
enableDrag(MiniFrame)

-- Minimize/maximize logic
local function minimizeGUI()
    MainFrame.Visible = false
    MiniFrame.Visible = true
    isMinimized = true
end

local function maximizeGUI()
    MainFrame.Visible = true
    MiniFrame.Visible = false
    isMinimized = false
end

MinimizeBtn.MouseButton1Click:Connect(minimizeGUI)
MiniBtn.MouseButton1Click:Connect(maximizeGUI)

-- Keyboard toggle (RightShift za cijeli panel)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.MenuKey then
        if isMenuOpen then
            MainFrame.Visible = false
            MiniFrame.Visible = false
            isMenuOpen = false
        else
            if isMinimized then
                MiniFrame.Visible = true
            else
                MainFrame.Visible = true
            end
            isMenuOpen = true
        end
    end
end)

-- Helperi
local function getTeam(player)
    local team = nil
    pcall(function()
        if player.Team then team = player.Team.Name end
    end)
    return team
end

local function isEnemy(player)
    local lp = Players.LocalPlayer
    local playerTeam = getTeam(player)
    local localTeam = getTeam(lp)
    
    -- Ako oba igrača imaju tim, provjeri jesu li različiti
    if playerTeam and localTeam then
        return playerTeam ~= localTeam
    end
    
    -- Ako jedan ima tim a drugi nema, smatraju se neprijateljima
    if (playerTeam and not localTeam) or (not playerTeam and localTeam) then
        return true
    end
    
    -- Ako oba nemaju tim, smatraju se neprijateljima (FFA)
    return true
end

local function getChar(plr)
    return plr.Character
end

-- Dodaj krozZid funkciju
local function krozZid(origin, direction, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        local hitPart = result.Instance
        local hitPlayer = Players:GetPlayerFromCharacter(hitPart.Parent)
        if hitPlayer and hitPlayer ~= Players.LocalPlayer then
            return hitPlayer.Character
        end
    end
    return nil
end

local function get2DBox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local minY, maxY = hrp.Position.Y, hrp.Position.Y
    if head then
        minY = math.min(minY, head.Position.Y)
        maxY = math.max(maxY, head.Position.Y)
    end
    if torso then
        minY = math.min(minY, torso.Position.Y)
        maxY = math.max(maxY, torso.Position.Y)
    end
    local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onscreen then return end
    local w = 3.5 * 2
    local h = (maxY - minY + 2.5) * 10
    return pos.X - w/2, pos.Y - h/2, w, h
end

local function createBox()
    local boxName = "Box_"..randStr(4)
    local box = Drawing and Drawing.new and Drawing.new("Square")
    if box then
        box.Thickness = 2
        box.Filled = false
        box.Visible = false
        box.Transparency = 1
        box.ZIndex = 2
        box.Name = boxName
    end
    return box
end

-- Force render loop (uvijek renderuj igrače)
RunService.RenderStepped:Connect(function()
    if FORCE_RENDER then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and getChar(plr) then
                local char = getChar(plr)
                -- Forsiraj renderovanje karaktera
                pcall(function()
                    char.Parent = workspace
                    for _,part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.CanCollide = false
                        end
                    end
                end)
            end
        end
    end
end)

-- U virtualnom hitboxu koristi maksimalnu vrijednost
local function isInVirtualHitbox(targetPart, fov)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return false end
    local mousePos = UserInputService:GetMouseLocation()
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
    return dist <= fov
end

-- Ograniči maksimalni FOV za fizički hitbox
local MAX_HITBOX_FOV = 200

-- FOV efekt loop
-- (ukloni RunService.RenderStepped loop za FOV)

-- ESP, Hitbox, Nametag gameplay loop
RunService.RenderStepped:Connect(function()
    -- ESP kutije
    if VIZIJA_ENABLED then
        for _,v in pairs(vizijaBoxes) do v.Visible = false end
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and getChar(plr) then
                if not VIZIJA_ENEMY_ONLY or isEnemy(plr) then
                    local char = getChar(plr)
                    local box = vizijaBoxes[plr] or createBox()
                    vizijaBoxes[plr] = box
                    local x, y, w, h = get2DBox(char)
                    if x and y and w and h then
                        box.Position = Vector2.new(x, y)
                        box.Size = Vector2.new(w, h)
                        box.Color = VIZIJA_COLOR
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                end
            end
        end
    else
        for _,v in pairs(vizijaBoxes) do v.Visible = false end
    end
    
    -- Nametag
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and getChar(plr) then
            local char = getChar(plr)
            local head = char:FindFirstChild("Head")
            if head then
                if NAMETAG_ENABLED then
                    if not head:FindFirstChild("AlestoNametag") then
                        local tag = Instance.new("BillboardGui")
                        tag.Name = "AlestoNametag"
                        tag.Adornee = head
                        tag.Size = UDim2.new(0,100,0,40)
                        tag.StudsOffset = Vector3.new(0,1.5,0)
                        tag.AlwaysOnTop = true
                        local label = Instance.new("TextLabel", tag)
                        label.Size = UDim2.new(1,0,1,0)
                        label.BackgroundTransparency = 1
                        label.Text = plr.Name
                        label.TextColor3 = Config.Colors.Accent
                        label.TextScaled = true
                        label.Font = Enum.Font.GothamBold
                        tag.Parent = head
                    else
                        local tag = head:FindFirstChild("AlestoNametag")
                        tag.Size = UDim2.new(0,100*NAMETAG_SCALE,0,40*NAMETAG_SCALE)
                        tag.Enabled = true
                    end
                else
                    if head:FindFirstChild("AlestoNametag") then
                        head.AlestoNametag.Enabled = false
                    end
                end
            end
        end
    end
    
    -- Hitbox - samo kad su uključeni
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and getChar(plr) then
            local char = getChar(plr)
            
            -- Hitbox za glavu
            if char:FindFirstChild("Head") then
                if META_HEAD then
                    char.Head.Size = Vector3.new(META_FOV/10, META_FOV/10, META_FOV/10)
                    char.Head.Color = HITBOX_HEAD_COLOR
                    char.Head.Material = Enum.Material.Neon
                else
                    char.Head.Size = Vector3.new(2,1,1)
                    char.Head.Color = Color3.fromRGB(255,255,255)
                    char.Head.Material = Enum.Material.Plastic
                end
            end
            
            -- Hitbox za tijelo
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if torso then
                if META_TORSO then
                    torso.Size = Vector3.new(META_FOV/10, META_FOV/10, META_FOV/10)
                    torso.Color = HITBOX_HEAD_COLOR
                    torso.Material = Enum.Material.Neon
                else
                    torso.Size = Vector3.new(2,2,1)
                    torso.Color = Color3.fromRGB(255,255,255)
                    torso.Material = Enum.Material.Plastic
                end
            end
        end
    end
    
    -- Infinite Jump
    if INFINITE_JUMP_ENABLED then
        local player = Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            -- Omogući infinite jump
            humanoid.JumpPower = 50
        end
    end
end) 