--[[
    script by Alesto
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

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
local parentGui
if math.random() > 0.5 and Players.LocalPlayer:FindFirstChild("PlayerGui") then
    parentGui = Players.LocalPlayer.PlayerGui
else
    parentGui = game:GetService("CoreGui")
end

-- Config
local Config = {
    MenuSize = UDim2.new(0, 370, 0, 470),
    MenuPosition = UDim2.new(0.5, -185, 0.5, -235),
    MinimizedSize = UDim2.new(0, 50, 0, 50),
    MinimizedPosition = UDim2.new(0, 100, 0, 100),
    MenuKey = Enum.KeyCode.RightShift,
    Colors = {
        Primary = Color3.fromRGB(35, 40, 55),
        Secondary = Color3.fromRGB(25, 30, 40),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Minimized = Color3.fromRGB(0, 150, 255),
        Section = Color3.fromRGB(50, 60, 80)
    }
}

local isMenuOpen = true
local isMinimized = false

-- State for features
local VIZIJA_ENABLED = false
local VIZIJA_COLOR = Color3.fromRGB(0, 150, 255)
local VIZIJA_ENEMY_ONLY = true
local FORCE_RENDER = true -- Uvijek renderuj igrače
local vizijaBoxes = {}
local META_HEAD = true
local META_TORSO = false
local META_FOV = 3

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

local MainFrame = Instance.new("Frame")
MainFrame.Name = frameName
MainFrame.Size = UDim2.new(0, 370, 0, 600)
MainFrame.Position = Config.MenuPosition
MainFrame.BackgroundColor3 = Config.Colors.Primary
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
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
Title.Text = "Alesto Panel"
Title.TextColor3 = Color3.fromRGB(200, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = Color3.fromRGB(0, 200, 255)
local titleGradient = Instance.new("UIGradient", Title)
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 200))
}
titleGradient.Rotation = 0

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

-- Section: Vizija (ESP)
local VizijaSection = Instance.new("Frame", MainFrame)
VizijaSection.Size = UDim2.new(1, -32, 0, 90)
VizijaSection.Position = UDim2.new(0, 16, 0, 60)
VizijaSection.BackgroundColor3 = Config.Colors.Section
VizijaSection.BorderSizePixel = 0
local VizijaCorner = Instance.new("UICorner", VizijaSection)
VizijaCorner.CornerRadius = UDim.new(0, 12)

-- Vraćam labele, inpute i vrijednosti u sekcije
-- VIZIJA SEKCIJA
local VizijaLabel = Instance.new("TextLabel", VizijaSection)
VizijaLabel.Size = UDim2.new(0, 140, 0, 28)
VizijaLabel.BackgroundTransparency = 1
VizijaLabel.Text = "Vizija (kutije)"
VizijaLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
VizijaLabel.Font = Enum.Font.GothamBold
VizijaLabel.TextScaled = true
VizijaLabel.TextXAlignment = Enum.TextXAlignment.Left
VizijaLabel.Position = UDim2.new(0, 8, 0, 8)

local VizijaToggle = Instance.new("TextButton", VizijaSection)
VizijaToggle.Size = UDim2.new(0, 100, 0, 32)
VizijaToggle.Position = UDim2.new(0, 140, 0, 8)
VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
VizijaToggle.TextColor3 = Config.Colors.Text
VizijaToggle.TextScaled = true
VizijaToggle.Font = Enum.Font.GothamBold
local VizijaToggleCorner = Instance.new("UICorner", VizijaToggle)
VizijaToggleCorner.CornerRadius = UDim.new(0, 8)

local OnlyEnemiesBtn = Instance.new("TextButton", VizijaSection)
OnlyEnemiesBtn.Size = UDim2.new(0, 120, 0, 28)
OnlyEnemiesBtn.Position = UDim2.new(0, 10, 0, 48)
OnlyEnemiesBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
OnlyEnemiesBtn.Text = VIZIJA_ENEMY_ONLY and "Samo protivnici" or "Svi igrači"
OnlyEnemiesBtn.TextColor3 = Config.Colors.Text
OnlyEnemiesBtn.TextScaled = true
OnlyEnemiesBtn.Font = Enum.Font.Gotham
local OnlyEnemiesCorner = Instance.new("UICorner", OnlyEnemiesBtn)
OnlyEnemiesCorner.CornerRadius = UDim.new(0, 8)

OnlyEnemiesBtn.MouseButton1Click:Connect(function()
    VIZIJA_ENEMY_ONLY = not VIZIJA_ENEMY_ONLY
    OnlyEnemiesBtn.Text = VIZIJA_ENEMY_ONLY and "Samo protivnici" or "Svi igrači"
end)

VizijaToggle.MouseButton1Click:Connect(function()
    VIZIJA_ENABLED = not VIZIJA_ENABLED
    VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
    VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
    if not VIZIJA_ENABLED then
        for _,v in pairs(vizijaBoxes) do v:Remove() end
        vizijaBoxes = {}
    end
end)

-- Section: Boja kutije (Color Wheel)
local ColorSection = Instance.new("Frame", MainFrame)
ColorSection.Size = UDim2.new(1, -32, 0, 110)
ColorSection.Position = UDim2.new(0, 16, 0, 160)
ColorSection.BackgroundColor3 = Config.Colors.Section
ColorSection.BorderSizePixel = 0
local ColorCorner = Instance.new("UICorner", ColorSection)
ColorCorner.CornerRadius = UDim.new(0, 12)

-- BOJA KUTIJE SEKCIJA
local ColorLabel = Instance.new("TextLabel", ColorSection)
ColorLabel.Size = UDim2.new(0, 140, 0, 28)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Boja kutije"
ColorLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
ColorLabel.Font = Enum.Font.GothamBold
ColorLabel.TextScaled = true
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Position = UDim2.new(0, 8, 0, 8)

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

-- Section: Meta (Hitbox)
local MetaSection = Instance.new("Frame", MainFrame)
MetaSection.Size = UDim2.new(1, -32, 0, 220)
MetaSection.Position = UDim2.new(0, 16, 0, 280)
MetaSection.BackgroundColor3 = Config.Colors.Section
MetaSection.BorderSizePixel = 0
local MetaCorner = Instance.new("UICorner", MetaSection)
MetaCorner.CornerRadius = UDim.new(0, 12)

-- POVECANJE GLAVUDJE SEKCIJA
local MetaLabel = Instance.new("TextLabel", MetaSection)
MetaLabel.Size = UDim2.new(0, 140, 0, 28)
MetaLabel.BackgroundTransparency = 1
MetaLabel.Text = "Povecaj glavudju"
MetaLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
MetaLabel.Font = Enum.Font.GothamBold
MetaLabel.TextScaled = true
MetaLabel.TextXAlignment = Enum.TextXAlignment.Left
MetaLabel.Position = UDim2.new(0, 8, 0, 8)

-- MODERNI INPUT BOX ZA FOV (hitbox)
local FOVInput = Instance.new("TextBox", MetaSection)
FOVInput.Size = UDim2.new(0, 60, 0, 28)
FOVInput.Position = UDim2.new(0, 70, 0, 48)
FOVInput.BackgroundColor3 = Color3.fromRGB(30,40,60)
FOVInput.TextColor3 = Config.Colors.Text
FOVInput.Text = tostring(META_FOV)
FOVInput.TextScaled = true
FOVInput.Font = Enum.Font.GothamBold
FOVInput.PlaceholderText = "FOV"
FOVInput.ClearTextOnFocus = false
FOVInput.TextStrokeTransparency = 0.7
FOVInput.TextStrokeColor3 = Color3.fromRGB(0,0,0)
local FOVInputCorner = Instance.new("UICorner", FOVInput)
FOVInputCorner.CornerRadius = UDim.new(0, 8)
FOVInput.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(FOVInput.Text)
        if val and val >= 1 and val <= MAX_HITBOX_FOV then
            META_FOV = val
            FOVInput.Text = tostring(val)
        else
            FOVInput.Text = tostring(META_FOV)
        end
    end
end)

-- MODERNI INPUT BOX ZA SCALE (veličina imena)
local ImenaScaleInput = Instance.new("TextBox", ImenaSection)
ImenaScaleInput.Size = UDim2.new(0, 60, 0, 28)
ImenaScaleInput.Position = UDim2.new(0, 200, 0, 8)
ImenaScaleInput.BackgroundColor3 = Color3.fromRGB(30,40,60)
ImenaScaleInput.TextColor3 = Config.Colors.Text
ImenaScaleInput.Text = tostring(NAMETAG_SCALE)
ImenaScaleInput.TextScaled = true
ImenaScaleInput.Font = Enum.Font.GothamBold
ImenaScaleInput.PlaceholderText = "Veličina"
ImenaScaleInput.ClearTextOnFocus = false
ImenaScaleInput.TextStrokeTransparency = 0.7
ImenaScaleInput.TextStrokeColor3 = Color3.fromRGB(0,0,0)
local ImenaScaleInputCorner = Instance.new("UICorner", ImenaScaleInput)
ImenaScaleInputCorner.CornerRadius = UDim.new(0, 8)
ImenaScaleInput.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(ImenaScaleInput.Text)
        if val and val >= 0.1 and val <= 5.0 then
            NAMETAG_SCALE = val
            ImenaScaleInput.Text = tostring(val)
        else
            ImenaScaleInput.Text = tostring(NAMETAG_SCALE)
        end
    end
end)

-- Ukloni stare slidere za FOV i scale ako postoje
if FOVSlider then FOVSlider:Destroy() end
if ImenaScaleSlider then ImenaScaleSlider:Destroy() end

local HeadBtn = Instance.new("TextButton", MetaSection)
HeadBtn.Size = UDim2.new(0, 70, 0, 28)
HeadBtn.Position = UDim2.new(0, 10, 0, 80)
HeadBtn.BackgroundColor3 = META_HEAD and Config.Colors.Accent or Color3.fromRGB(60,60,60)
HeadBtn.Text = "Glava"
HeadBtn.TextColor3 = Config.Colors.Text
HeadBtn.TextScaled = true
HeadBtn.Font = Enum.Font.GothamBold
local HeadCorner = Instance.new("UICorner", HeadBtn)
HeadCorner.CornerRadius = UDim.new(0, 8)

local TorsoBtn = Instance.new("TextButton", MetaSection)
TorsoBtn.Size = UDim2.new(0, 70, 0, 28)
TorsoBtn.Position = UDim2.new(0, 90, 0, 80)
TorsoBtn.BackgroundColor3 = META_TORSO and Config.Colors.Accent or Color3.fromRGB(60,60,60)
TorsoBtn.Text = "Tijelo"
TorsoBtn.TextColor3 = Config.Colors.Text
TorsoBtn.TextScaled = true
TorsoBtn.Font = Enum.Font.GothamBold
local TorsoCorner = Instance.new("UICorner", TorsoBtn)
TorsoCorner.CornerRadius = UDim.new(0, 8)

HeadBtn.MouseButton1Click:Connect(function()
    META_HEAD = not META_HEAD
    HeadBtn.BackgroundColor3 = META_HEAD and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)
TorsoBtn.MouseButton1Click:Connect(function()
    META_TORSO = not META_TORSO
    TorsoBtn.BackgroundColor3 = META_TORSO and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)

-- GUI: Dugmad za biranje boje glave
local HeadColorLabel = Instance.new("TextLabel", MetaSection)
HeadColorLabel.Size = UDim2.new(0, 80, 0, 28)
HeadColorLabel.Position = UDim2.new(0, 170, 0, 80)
HeadColorLabel.BackgroundTransparency = 1
HeadColorLabel.Text = "Boja glave"
HeadColorLabel.TextColor3 = Config.Colors.Text
HeadColorLabel.TextScaled = true
HeadColorLabel.Font = Enum.Font.Gotham

local RedBtn = Instance.new("TextButton", MetaSection)
RedBtn.Size = UDim2.new(0, 28, 0, 28)
RedBtn.Position = UDim2.new(0, 260, 0, 80)
RedBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedBtn.Text = ""
local RedBtnCorner = Instance.new("UICorner", RedBtn)
RedBtnCorner.CornerRadius = UDim.new(1, 0)

local BlueBtn = Instance.new("TextButton", MetaSection)
BlueBtn.Size = UDim2.new(0, 28, 0, 28)
BlueBtn.Position = UDim2.new(0, 295, 0, 80)
BlueBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
BlueBtn.Text = ""
local BlueBtnCorner = Instance.new("UICorner", BlueBtn)
BlueBtnCorner.CornerRadius = UDim.new(1, 0)

local GreenBtn = Instance.new("TextButton", MetaSection)
GreenBtn.Size = UDim2.new(0, 28, 0, 28)
GreenBtn.Position = UDim2.new(0, 330, 0, 80)
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

-- Bindovi
local ESP_BIND = Enum.KeyCode.E
local HITBOX_BIND = Enum.KeyCode.H
local NAMETAG_BIND = Enum.KeyCode.N
local KROZZID_BIND = Enum.KeyCode.K
local waitingForBind = nil -- "ESP", "HITBOX", "NAMETAG", "KROZZID"

-- Nova sekcija: Imena + Krozzid
local ImenaSection = Instance.new("Frame", MainFrame)
ImenaSection.Size = UDim2.new(1, -32, 0, 70)
ImenaSection.Position = UDim2.new(0, 16, 0, 500)
ImenaSection.BackgroundColor3 = Config.Colors.Section
ImenaSection.BorderSizePixel = 0
local ImenaSectionCorner = Instance.new("UICorner", ImenaSection)
ImenaSectionCorner.CornerRadius = UDim.new(0, 12)

-- IMENA SEKCIJA
local ImenaLabel = Instance.new("TextLabel", ImenaSection)
ImenaLabel.Size = UDim2.new(0, 140, 0, 28)
ImenaLabel.BackgroundTransparency = 1
ImenaLabel.Text = "Imena"
ImenaLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
ImenaLabel.Font = Enum.Font.GothamBold
ImenaLabel.TextScaled = true
ImenaLabel.TextXAlignment = Enum.TextXAlignment.Left
ImenaLabel.Position = UDim2.new(0, 8, 0, 8)

local ImenaToggle = Instance.new("TextButton", ImenaSection)
ImenaToggle.Size = UDim2.new(0, 90, 0, 28)
ImenaToggle.Position = UDim2.new(0, 100, 0, 8)
ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
ImenaToggle.TextColor3 = Config.Colors.Text
ImenaToggle.TextScaled = true
ImenaToggle.Font = Enum.Font.GothamBold
local ImenaToggleCorner = Instance.new("UICorner", ImenaToggle)
ImenaToggleCorner.CornerRadius = UDim.new(0, 8)
ImenaToggle.MouseButton1Click:Connect(function()
    NAMETAG_ENABLED = not NAMETAG_ENABLED
    ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
    ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)

-- IMENA SEKCIJA
local ImenaScaleLabel = Instance.new("TextLabel", ImenaSection)
ImenaScaleLabel.Size = UDim2.new(0, 60, 0, 24)
ImenaScaleLabel.BackgroundTransparency = 1
ImenaScaleLabel.Text = "Veličina"
ImenaScaleLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
ImenaScaleLabel.Font = Enum.Font.Gotham
ImenaScaleLabel.TextScaled = true
ImenaScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ImenaScaleLabel.Position = UDim2.new(0, 8, 0, 36)

-- Krozzid toggle u Imena sekciji
local KrozzidToggle = Instance.new("TextButton", ImenaSection)
KrozzidToggle.Size = UDim2.new(0, 120, 0, 28)
KrozzidToggle.Position = UDim2.new(0, 10, 0, 40)
KrozzidToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
KrozzidToggle.Text = "Krozzid: Isključeno"
KrozzidToggle.TextColor3 = Config.Colors.Text
KrozzidToggle.TextScaled = true
KrozzidToggle.Font = Enum.Font.GothamBold
local KrozzidToggleCorner = Instance.new("UICorner", KrozzidToggle)
KrozzidToggleCorner.CornerRadius = UDim.new(0, 8)
local KROZZID_ENABLED = false
KrozzidToggle.MouseButton1Click:Connect(function()
    KROZZID_ENABLED = not KROZZID_ENABLED
    KrozzidToggle.Text = KROZZID_ENABLED and "Krozzid: Uključeno" or "Krozzid: Isključeno"
    KrozzidToggle.BackgroundColor3 = KROZZID_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)

-- Nova sekcija: Bindovi
local BindoviSection = Instance.new("Frame", MainFrame)
BindoviSection.Size = UDim2.new(1, -32, 0, 60)
BindoviSection.Position = UDim2.new(0, 16, 0, 580)
BindoviSection.BackgroundColor3 = Config.Colors.Section
BindoviSection.BorderSizePixel = 0
local BindoviSectionCorner = Instance.new("UICorner", BindoviSection)
BindoviSectionCorner.CornerRadius = UDim.new(0, 12)

-- BINDOVI SEKCIJA
local BindoviLabel = Instance.new("TextLabel", BindoviSection)
BindoviLabel.Size = UDim2.new(0, 140, 0, 28)
BindoviLabel.BackgroundTransparency = 1
BindoviLabel.Text = "Bindovi (tipke)"
BindoviLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
BindoviLabel.Font = Enum.Font.GothamBold
BindoviLabel.TextScaled = true
BindoviLabel.TextXAlignment = Enum.TextXAlignment.Left
BindoviLabel.Position = UDim2.new(0, 8, 0, 8)

local ESPBindBtn = Instance.new("TextButton", BindoviSection)
ESPBindBtn.Size = UDim2.new(0, 80, 0, 28)
ESPBindBtn.Position = UDim2.new(0, 140, 0, 8)
ESPBindBtn.BackgroundColor3 = Config.Colors.Accent
ESPBindBtn.Text = "ESP: "..tostring(ESP_BIND.Name)
ESPBindBtn.TextColor3 = Config.Colors.Text
ESPBindBtn.TextScaled = true
ESPBindBtn.Font = Enum.Font.GothamBold
local ESPBindCorner = Instance.new("UICorner", ESPBindBtn)
ESPBindCorner.CornerRadius = UDim.new(0, 8)

local HitboxBindBtn = Instance.new("TextButton", BindoviSection)
HitboxBindBtn.Size = UDim2.new(0, 90, 0, 28)
HitboxBindBtn.Position = UDim2.new(0, 230, 0, 8)
HitboxBindBtn.BackgroundColor3 = Config.Colors.Accent
HitboxBindBtn.Text = "Glavudja: "..tostring(HITBOX_BIND.Name)
HitboxBindBtn.TextColor3 = Config.Colors.Text
HitboxBindBtn.TextScaled = true
HitboxBindBtn.Font = Enum.Font.GothamBold
local HitboxBindCorner = Instance.new("UICorner", HitboxBindBtn)
HitboxBindCorner.CornerRadius = UDim.new(0, 8)

local ImenaBindBtn = Instance.new("TextButton", BindoviSection)
ImenaBindBtn.Size = UDim2.new(0, 90, 0, 28)
ImenaBindBtn.Position = UDim2.new(0, 330, 0, 8)
ImenaBindBtn.BackgroundColor3 = Config.Colors.Accent
ImenaBindBtn.Text = "Imena: "..tostring(NAMETAG_BIND.Name)
ImenaBindBtn.TextColor3 = Config.Colors.Text
ImenaBindBtn.TextScaled = true
ImenaBindBtn.Font = Enum.Font.GothamBold
local ImenaBindCorner = Instance.new("UICorner", ImenaBindBtn)
ImenaBindCorner.CornerRadius = UDim.new(0, 8)

local KrozzidBindBtn = Instance.new("TextButton", BindoviSection)
KrozzidBindBtn.Size = UDim2.new(0, 90, 0, 28)
KrozzidBindBtn.Position = UDim2.new(0, 430, 0, 8)
KrozzidBindBtn.BackgroundColor3 = Config.Colors.Accent
KrozzidBindBtn.Text = "Krozzid: "..tostring(KROZZID_BIND.Name)
KrozzidBindBtn.TextColor3 = Config.Colors.Text
KrozzidBindBtn.TextScaled = true
KrozzidBindBtn.Font = Enum.Font.GothamBold
local KrozzidBindCorner = Instance.new("UICorner", KrozzidBindBtn)
KrozzidBindCorner.CornerRadius = UDim.new(0, 8)

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

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if waitingForBind == "ESP" then
        ESP_BIND = input.KeyCode
        ESPBindBtn.Text = "ESP: "..tostring(ESP_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "HITBOX" then
        HITBOX_BIND = input.KeyCode
        HitboxBindBtn.Text = "Hitbox: "..tostring(HITBOX_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "NAMETAG" then
        NAMETAG_BIND = input.KeyCode
        NametagBindBtn.Text = "Nametag: "..tostring(NAMETAG_BIND.Name)
        waitingForBind = nil
        return
    elseif waitingForBind == "KROZZID" then
        KROZZID_BIND = input.KeyCode
        KrozzidBindBtn.Text = "Krozzid: "..tostring(KROZZID_BIND.Name)
        waitingForBind = nil
        return
    end
    -- Bind funkcionalnost
    if input.KeyCode == ESP_BIND then
        VIZIJA_ENABLED = not VIZIJA_ENABLED
        VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
        VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
        if not VIZIJA_ENABLED then
            for _,v in pairs(vizijaBoxes) do v:Remove() end
            vizijaBoxes = {}
        end
    elseif input.KeyCode == HITBOX_BIND then
        if META_HEAD or META_TORSO then
            META_HEAD = false
            META_TORSO = false
            HeadBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            TorsoBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        else
            META_HEAD = true
            HeadBtn.BackgroundColor3 = Config.Colors.Accent
        end
    elseif input.KeyCode == NAMETAG_BIND then
        NAMETAG_ENABLED = not NAMETAG_ENABLED
        NametagToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
        NametagToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
    elseif input.KeyCode == KROZZID_BIND then
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

-- U GUI slideru za FOV (hitbox):
-- FOVSlider.MouseButton1Down:Connect(function()
--     draggingFOV = true
-- end)
-- UserInputService.InputEnded:Connect(function(input)
--     if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = false end
-- end)
-- UserInputService.InputChanged:Connect(function(input)
--     if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
--         local rel = math.clamp((input.Position.X - FOVSlider.AbsolutePosition.X) / FOVSlider.AbsoluteSize.X, 0, 1)
--         local value = math.floor(rel * (MAX_HITBOX_FOV-1) + 1)
--         META_FOV = value
--         FOVSlider.Text = tostring(value)
--     end
-- end)

-- Ukloni stari slider za HB veličinu do 200 (ako postoji)
if HitboxFOVLabel then HitboxFOVLabel:Destroy() end
if HitboxFOVSlider then HitboxFOVSlider:Destroy() end

-- MODERNI SLIDE SWITCH (custom)
local function createSwitch(parent, state, onToggle, colorOn, colorOff)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, 48, 0, 28)
    frame.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundColor3 = state and colorOn or colorOff
    bg.BorderSizePixel = 0
    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", bg)
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = state and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)
    local dragging = false
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    bg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            state = not state
            onToggle(state)
            bg.BackgroundColor3 = state and colorOn or colorOff
            knob:TweenPosition(state and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.18, true)
        end
    end)
    return frame, function(val)
        state = val
        bg.BackgroundColor3 = state and colorOn or colorOff
        knob.Position = state and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
    end
end

-- MODERNE PASTEL BOJE
local pastelRed = Color3.fromRGB(255, 120, 120)
local pastelBlue = Color3.fromRGB(120, 180, 255)
local pastelGreen = Color3.fromRGB(120, 255, 180)

-- PRIMJENA SLIDE SWITCHA ZA SVE TOGGLE-OVE
-- ESP
local espSwitch, setESPSwitch = createSwitch(VizijaSection, VIZIJA_ENABLED, function(val)
    VIZIJA_ENABLED = val
    VizijaToggle.Text = val and "Uključeno" or "Isključeno"
    VizijaToggle.BackgroundColor3 = val and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end, Config.Colors.Accent, Color3.fromRGB(60,60,60))
espSwitch.Position = UDim2.new(0, 250, 0, 8)
VizijaToggle.Visible = false

-- OnlyEnemies
local enemySwitch, setEnemySwitch = createSwitch(VizijaSection, VIZIJA_ENEMY_ONLY, function(val)
    VIZIJA_ENEMY_ONLY = val
    OnlyEnemiesBtn.Text = val and "Samo protivnici" or "Svi igrači"
end, pastelBlue, Color3.fromRGB(60,60,60))
enemySwitch.Position = UDim2.new(0, 250, 0, 48)
OnlyEnemiesBtn.Visible = false

-- Nametag
local imenaSwitch, setImenaSwitch = createSwitch(ImenaSection, NAMETAG_ENABLED, function(val)
    NAMETAG_ENABLED = val
    ImenaToggle.Text = val and "Uključeno" or "Isključeno"
    ImenaToggle.BackgroundColor3 = val and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end, pastelGreen, Color3.fromRGB(60,60,60))
imenaSwitch.Position = UDim2.new(0, 200, 0, 8)
ImenaToggle.Visible = false

-- Krozzid
local krozzidSwitch, setKrozzidSwitch = createSwitch(ImenaSection, KROZZID_ENABLED, function(val)
    KROZZID_ENABLED = val
    KrozzidToggle.Text = val and "Krozzid: Uključeno" or "Krozzid: Isključeno"
    KrozzidToggle.BackgroundColor3 = val and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end, pastelRed, Color3.fromRGB(60,60,60))
krozzidSwitch.Position = UDim2.new(0, 340, 0, 8)
KrozzidToggle.Visible = false

-- Glava/Tijelo
local headSwitch, setHeadSwitch = createSwitch(MetaSection, META_HEAD, function(val)
    META_HEAD = val
    HeadBtn.BackgroundColor3 = val and pastelRed or Color3.fromRGB(60,60,60)
end, pastelRed, Color3.fromRGB(60,60,60))
headSwitch.Position = UDim2.new(0, 10, 0, 80)
HeadBtn.Visible = false
local torsoSwitch, setTorsoSwitch = createSwitch(MetaSection, META_TORSO, function(val)
    META_TORSO = val
    TorsoBtn.BackgroundColor3 = val and pastelBlue or Color3.fromRGB(60,60,60)
end, pastelBlue, Color3.fromRGB(60,60,60))
torsoSwitch.Position = UDim2.new(0, 70, 0, 80)
TorsoBtn.Visible = false

-- BOJE ZA GLAVU (PASTEL)
RedBtn.BackgroundColor3 = pastelRed
BlueBtn.BackgroundColor3 = pastelBlue
GreenBtn.BackgroundColor3 = pastelGreen

-- GRID/FLEX LAYOUT ZA SVE SEKCIJE
for _,frame in ipairs({VizijaSection, ColorSection, MetaSection, ImenaSection, BindoviSection}) do
    local layout = Instance.new("UIListLayout", frame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
end

-- PANEL I SEKCIJE: SHADOW, BORDER, PADDING
for _,frame in ipairs({MainFrame, VizijaSection, ColorSection, MetaSection, ImenaSection, BindoviSection}) do
    local border = Instance.new("UIStroke", frame)
    border.Color = Color3.fromRGB(60, 70, 90)
    border.Thickness = 2
    border.Transparency = 0.7
    local shadow = Instance.new("ImageLabel", frame)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.85
    shadow.ZIndex = 0
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
end

-- 1. Vizija (ESP) sekcija ostaje kao prije
-- 2. Boja kutije sekcija ostaje kao prije
-- 3. Hitbox sekcija preimenuj u "Povecaj glavudju"
MetaLabel.Text = "Povecaj glavudju"

-- 4. Nametag sekcija preimenuj u "Imena" i spoji u MetaSection
local ImenaLabel = Instance.new("TextLabel", MetaSection)
ImenaLabel.Size = UDim2.new(0, 120, 0, 28)
ImenaLabel.Position = UDim2.new(0, 10, 0, 8+32+48+28+8) -- ispod ostalih
ImenaLabel.BackgroundTransparency = 1
ImenaLabel.Text = "Imena"
ImenaLabel.TextColor3 = Config.Colors.Text
ImenaLabel.TextScaled = true
ImenaLabel.Font = Enum.Font.GothamBold

local ImenaToggle = Instance.new("TextButton", MetaSection)
ImenaToggle.Size = UDim2.new(0, 100, 0, 28)
ImenaToggle.Position = UDim2.new(0, 140, 0, 8+32+48+28+8)
ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
ImenaToggle.TextColor3 = Config.Colors.Text
ImenaToggle.TextScaled = true
ImenaToggle.Font = Enum.Font.GothamBold
local ImenaToggleCorner = Instance.new("UICorner", ImenaToggle)
ImenaToggleCorner.CornerRadius = UDim.new(0, 8)
ImenaToggle.MouseButton1Click:Connect(function()
    NAMETAG_ENABLED = not NAMETAG_ENABLED
    ImenaToggle.Text = NAMETAG_ENABLED and "Uključeno" or "Isključeno"
    ImenaToggle.BackgroundColor3 = NAMETAG_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)

local ImenaScaleLabel = Instance.new("TextLabel", MetaSection)
ImenaScaleLabel.Size = UDim2.new(0, 60, 0, 28)
ImenaScaleLabel.Position = UDim2.new(0, 250, 0, 8+32+48+28+8)
ImenaScaleLabel.BackgroundTransparency = 1
ImenaScaleLabel.Text = "Veličina"
ImenaScaleLabel.TextColor3 = Config.Colors.Text
ImenaScaleLabel.TextScaled = true
ImenaScaleLabel.Font = Enum.Font.Gotham

-- MODERNI INPUT BOX ZA SCALE (veličina imena)
local ImenaScaleInput = Instance.new("TextBox", MetaSection)
ImenaScaleInput.Size = UDim2.new(0, 100, 0, 28)
ImenaScaleInput.Position = UDim2.new(0, 320, 0, 8+32+48+28+8)
ImenaScaleInput.BackgroundColor3 = Config.Colors.Accent
ImenaScaleInput.TextColor3 = Config.Colors.Text
ImenaScaleInput.Text = tostring(NAMETAG_SCALE)
ImenaScaleInput.TextScaled = true
ImenaScaleInput.Font = Enum.Font.GothamBold
ImenaScaleInput.PlaceholderText = "Veličina"
ImenaScaleInput.ClearTextOnFocus = false
ImenaScaleInput.TextStrokeTransparency = 0.7
ImenaScaleInput.TextStrokeColor3 = Color3.fromRGB(0,0,0)
local ImenaScaleInputCorner = Instance.new("UICorner", ImenaScaleInput)
ImenaScaleInputCorner.CornerRadius = UDim.new(0, 8)
ImenaScaleInput.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(ImenaScaleInput.Text)
        if val and val >= 0.1 and val <= 5.0 then
            NAMETAG_SCALE = val
            ImenaScaleInput.Text = tostring(val)
        else
            ImenaScaleInput.Text = tostring(NAMETAG_SCALE)
        end
    end
end)

-- 5. Dodaj Krozzid toggle u isti panel
local KrozzidToggle = Instance.new("TextButton", MetaSection)
KrozzidToggle.Size = UDim2.new(0, 120, 0, 28)
KrozzidToggle.Position = UDim2.new(0, 10, 0, 8+32+48+28+8+32)
KrozzidToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
KrozzidToggle.Text = "Krozzid"
KrozzidToggle.TextColor3 = Config.Colors.Text
KrozzidToggle.TextScaled = true
KrozzidToggle.Font = Enum.Font.GothamBold
local KrozzidToggleCorner = Instance.new("UICorner", KrozzidToggle)
KrozzidToggleCorner.CornerRadius = UDim.new(0, 8)
KrozzidToggle.MouseButton1Click:Connect(function()
    -- Pozovi wallshot funkciju
    local origin = Camera.CFrame.Position
    local direction = Camera.CFrame.LookVector * 1000
    local ignoreList = {Players.LocalPlayer.Character}
    local target = krozZid(origin, direction, ignoreList)
    if target and target:FindFirstChild("Head") then
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
end)

-- Krozzid toggle (uključi/isključi wallshot)
local KROZZID_ENABLED = false
KrozzidToggle.Text = "Krozzid: Isključeno"
KrozzidToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
KrozzidToggle.MouseButton1Click:Connect(function()
    KROZZID_ENABLED = not KROZZID_ENABLED
    KrozzidToggle.Text = KROZZID_ENABLED and "Krozzid: Uključeno" or "Krozzid: Isključeno"
    KrozzidToggle.BackgroundColor3 = KROZZID_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)

-- Nametag loop (BillboardGui iznad glave protivnika, updateuje tekst i veličinu, briše na smrt)
RunService.RenderStepped:Connect(function()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local show = NAMETAG_ENABLED and hum and hum.Health > 0 and ((VIZIJA_ENEMY_ONLY and isEnemy(plr)) or (not VIZIJA_ENEMY_ONLY))
            local head = plr.Character.Head
            local tag = head:FindFirstChild("AlestoNametag")
            if show then
                if not tag then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "AlestoNametag"
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 200 * NAMETAG_SCALE, 0, 50 * NAMETAG_SCALE)
                    bb.StudsOffset = Vector3.new(0, 2, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = head
                    local txt = Instance.new("TextLabel", bb)
                    txt.Name = "AlestoNametagText"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = plr.DisplayName or plr.Name
                    txt.TextColor3 = Color3.fromRGB(255,255,255)
                    txt.TextStrokeTransparency = 0.5
                    txt.TextScaled = true
                    txt.Font = Enum.Font.GothamBold
                else
                    -- Update tekst i veličinu
                    tag.Size = UDim2.new(0, 200 * NAMETAG_SCALE, 0, 50 * NAMETAG_SCALE)
                    local txt = tag:FindFirstChild("AlestoNametagText")
                    if txt then txt.Text = plr.DisplayName or plr.Name end
                end
            else
                if tag then tag:Destroy() end
            end
        end
    end
end)

-- Meta (hitbox) loop: fizički povećava glavu/tijelo, resetuje na smrt
RunService.RenderStepped:Connect(function()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and isEnemy(plr) and getChar(plr) then
            local char = getChar(plr)
            local hum = char:FindFirstChild("Humanoid")
            if META_HEAD then
                local head = char:FindFirstChild("Head")
                if head and hum and hum.Health > 0 then
                    pcall(function()
                        head.Size = Vector3.new(META_FOV, META_FOV, META_FOV)
                        head.CanCollide = false
                        head.Transparency = 0.5
                        head.Color = HITBOX_HEAD_COLOR
                    end)
                elseif head and hum and hum.Health <= 0 then
                    head.Size = Vector3.new(2, 1, 1) -- default size
                    head.Color = Color3.fromRGB(163, 162, 165)
                end
            end
            if META_TORSO then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso and hum and hum.Health > 0 then
                    pcall(function()
                        torso.Size = Vector3.new(META_FOV*2, META_FOV*2, META_FOV*1.5)
                        torso.CanCollide = false
                        torso.Transparency = 0.5
                    end)
                elseif torso and hum and hum.Health <= 0 then
                    torso.Size = Vector3.new(2, 2, 1) -- default size
                end
            end
        end
    end
end)

-- Vizija (ESP) loop
RunService.RenderStepped:Connect(function()
    if not VIZIJA_ENABLED then return end
    for _,v in pairs(vizijaBoxes) do v.Visible = false end
    local i = 1
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if (VIZIJA_ENEMY_ONLY and isEnemy(plr)) or (not VIZIJA_ENEMY_ONLY) then
                local char = plr.Character
                local x, y, w, h = get2DBox(char)
                if x and y and w and h then
                    if not vizijaBoxes[i] then vizijaBoxes[i] = createBox() end
                    local box = vizijaBoxes[i]
                    box.Visible = true
                    box.Color = VIZIJA_COLOR
                    box.Position = Vector2.new(x, y)
                    box.Size = Vector2.new(w, h)
                    i = i + 1
                end
            end
        end
    end
    for j = i, #vizijaBoxes do
        if vizijaBoxes[j] then vizijaBoxes[j].Visible = false end
    end
end)

-- U wallshot funkciji koristi KROZZID_ENABLED za prikaz/skrivanje highlighta
RunService.RenderStepped:Connect(function()
    if KROZZID_ENABLED then
        local origin = Camera.CFrame.Position
        local direction = Camera.CFrame.LookVector * 1000
        local ignoreList = {Players.LocalPlayer.Character}
        local target = krozZid(origin, direction, ignoreList)
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local sb = head:FindFirstChild("KrozzidHighlight")
                if sb then sb:Destroy() end
            end
        end
        if target and target:FindFirstChild("Head") then
            local head = target.Head
            if not head:FindFirstChild("KrozzidHighlight") then
                local sb = Instance.new("SelectionBox")
                sb.Name = "KrozzidHighlight"
                sb.Adornee = head
                sb.Color3 = Color3.fromRGB(255,0,0)
                sb.LineThickness = 0.1
                sb.Parent = head
            end
        end
    else
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local sb = head:FindFirstChild("KrozzidHighlight")
                if sb then sb:Destroy() end
            end
        end
    end
end)

-- Neutralna notifikacija
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Panel",
        Text = "Panel učitan! (RightShift za toggle, - za minimizaciju)",
        Duration = 5
    })
end) 

-- Funkcija za wallshot (kroz zid)
local function krozZid(origin, direction, ignoreList)
    local maxDistance = 1000
    local currentOrigin = origin
    local remainingDistance = maxDistance
    local foundTarget = nil
    local tried = 0
    while remainingDistance > 0 and tried < 50 do
        local ray = Ray.new(currentOrigin, direction.Unit * remainingDistance)
        local part, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
        if part then
            -- Provjeri je li dio protivnika
            local character = part:FindFirstAncestorOfClass("Model")
            if character and Players:GetPlayerFromCharacter(character) and isEnemy(Players:GetPlayerFromCharacter(character)) then
                foundTarget = character
                break
            else
                -- Nije protivnik, nastavi raycast od te tačke dalje
                table.insert(ignoreList, part)
                currentOrigin = position + direction.Unit * 0.1 -- malo pomjeri dalje
                remainingDistance = remainingDistance - (position - currentOrigin).Magnitude
            end
        else
            break -- ništa više nije pogođeno
        end
        tried = tried + 1
    end
    return foundTarget
end 

-- MODERNI UI REDIZAJN
-- 1. Gradient pozadina glavnog panela
local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 25, 35))
}
MainGradient.Rotation = 45

-- 2. Blur/shadow efekt iza panela
local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Parent = game:GetService("Lighting")

local shadow = Instance.new("ImageLabel", MainFrame)
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217" -- soft shadow
shadow.ImageTransparency = 0.7
shadow.ZIndex = 0

-- 3. Animacije na hover/click za gumbe i slidere
local function addButtonAnim(btn)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Config.Colors.Accent:lerp(Color3.fromRGB(0,200,255), 0.3)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Config.Colors.Accent
    end)
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end)
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = Config.Colors.Accent
    end)
end
for _,section in ipairs({ESPBindBtn, HitboxBindBtn, ImenaBindBtn, KrozzidBindBtn, ImenaToggle, ImenaScaleInput, KrozzidToggle, FOVInput, HeadBtn, TorsoBtn, RedBtn, BlueBtn, GreenBtn, VizijaToggle, OnlyEnemiesBtn, ColorWheel}) do
    if section then pcall(function() addButtonAnim(section) end) end
end

-- 4. Zaobljeni kutovi i suptilni border na svim sekcijama
for _,frame in ipairs({MainFrame, VizijaSection, ColorSection, MetaSection, ImenaSection, BindoviSection}) do
    if frame then
        local border = Instance.new("UIStroke", frame)
        border.Color = Color3.fromRGB(60, 70, 90)
        border.Thickness = 2
        border.Transparency = 0.7
    end
end

-- 5. Moderni font
for _,label in ipairs(MainFrame:GetDescendants()) do
    if label:IsA("TextLabel") or label:IsA("TextButton") then
        label.Font = Enum.Font.GothamSemibold
    end
end

-- 6. Ikonice uz naslove sekcija
local function addIcon(label, assetId)
    local icon = Instance.new("ImageLabel", label.Parent)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, -32, 0, 2)
    icon.BackgroundTransparency = 1
    icon.Image = assetId
    icon.ZIndex = label.ZIndex or 2
end
addIcon(Title, "rbxassetid://6031094678") -- panel
addIcon(VizijaLabel, "rbxassetid://6031071050") -- vizija
addIcon(ColorLabel, "rbxassetid://6023426926") -- boja
addIcon(MetaLabel, "rbxassetid://6031068425") -- glavudja
addIcon(ImenaLabel, "rbxassetid://6031071053") -- imena
addIcon(BindoviLabel, "rbxassetid://6031068433") -- bindovi

-- 7. Poboljšani color picker (dodaj outline i value bubble)
ColorWheel.ImageTransparency = 0.1
local colorOutline = Instance.new("UIStroke", ColorWheel)
colorOutline.Color = Color3.fromRGB(0, 150, 255)
colorOutline.Thickness = 2
local colorBubble = Instance.new("TextLabel", ColorSection)
colorBubble.Size = UDim2.new(0, 40, 0, 24)
colorBubble.Position = UDim2.new(0, 220, 0, 8)
colorBubble.BackgroundTransparency = 0.2
colorBubble.BackgroundColor3 = Color3.fromRGB(30,40,60)
colorBubble.TextColor3 = Config.Colors.Text
colorBubble.TextScaled = true
colorBubble.Font = Enum.Font.GothamBold
colorBubble.Text = "RGB: "..math.floor(VIZIJA_COLOR.r*255)..","..math.floor(VIZIJA_COLOR.g*255)..","..math.floor(VIZIJA_COLOR.b*255)

-- 8. Responsive padding i razmaci
for _,frame in ipairs({VizijaSection, ColorSection, MetaSection, ImenaSection, BindoviSection}) do
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
end

-- 9. Animacija otvaranja/zatvaranja panela
MainFrame.Visible = false
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Config.MenuPosition, Size = MainFrame.Size, Visible = true}):Play()

-- 10. Custom switch/toggle dizajn
local function styleToggle(btn)
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = btn.BackgroundColor3
    btn.TextColor3 = btn.TextColor3
    btn.TextStrokeTransparency = 0.7
    btn.TextStrokeColor3 = Color3.fromRGB(0,0,0)
end
for _,btn in ipairs({VizijaToggle, OnlyEnemiesBtn, ImenaToggle, KrozzidToggle, HeadBtn, TorsoBtn}) do
    if btn then pcall(function() styleToggle(btn) end) end
end

-- 11. Slider s value bubble
-- local function addSliderBubble(slider, getValue)
--     local bubble = Instance.new("TextLabel", slider)
--     bubble.Size = UDim2.new(0, 40, 0, 20)
--     bubble.Position = UDim2.new(1, 8, 0, 0)
--     bubble.BackgroundTransparency = 0.3
--     bubble.BackgroundColor3 = Color3.fromRGB(30,40,60)
--     bubble.TextColor3 = Config.Colors.Text
--     bubble.TextScaled = true
--     bubble.Font = Enum.Font.GothamBold
--     bubble.Text = getValue()
--     slider.MouseMoved:Connect(function()
--         bubble.Text = getValue()
--     end)
-- end
-- addSliderBubble(FOVSlider, function() return tostring(META_FOV) end)
-- addSliderBubble(ImenaScaleSlider, function() return tostring(NAMETAG_SCALE) end)

-- 12. Sekcije s blagim shadowom i headerom
for _,frame in ipairs({VizijaSection, ColorSection, MetaSection, ImenaSection, BindoviSection}) do
    local shadow = Instance.new("ImageLabel", frame)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.85
    shadow.ZIndex = 0
end

-- 13. Notifikacije u istom stilu kao panel
local function notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
            Icon = "rbxassetid://6031094678"
        })
    end)
end
notify("Panel", "Panel učitan! (RightShift za toggle, - za minimizaciju)") 

-- Ukloni sve MouseEnter/MouseLeave evente sa switch/toggle dugmića
-- Očisti duple/sakrivene elemente i ostavi samo jedan set kontrola po sekciji
-- Svaka sekcija ima svoj UIListLayout za uredan prikaz
for _,frame in ipairs({VizijaSection, ColorSection, MetaSection, ImenaSection, BindoviSection}) do
    for _,child in ipairs(frame:GetChildren()) do
        if child:IsA("UIListLayout") then child:Destroy() end
    end
    local layout = Instance.new("UIListLayout", frame)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 6)
end

-- ESP sekcija
VizijaLabel.Text = "Vizija (kutije)"
VizijaToggle.Visible = true
VizijaToggle.Position = UDim2.new(0, 8, 0, 36)
VizijaToggle.Size = UDim2.new(0, 120, 0, 32)
VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
VizijaToggle.MouseButton1Click:Connect(function()
    VIZIJA_ENABLED = not VIZIJA_ENABLED
    VizijaToggle.Text = VIZIJA_ENABLED and "Uključeno" or "Isključeno"
    VizijaToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)
OnlyEnemiesBtn.Visible = true
OnlyEnemiesBtn.Position = UDim2.new(0, 8, 0, 74)
OnlyEnemiesBtn.Size = UDim2.new(0, 120, 0, 28)
OnlyEnemiesBtn.Text = VIZIJA_ENEMY_ONLY and "Samo protivnici" or "Svi igrači"
OnlyEnemiesBtn.MouseButton1Click:Connect(function()
    VIZIJA_ENEMY_ONLY = not VIZIJA_ENEMY_ONLY
    OnlyEnemiesBtn.Text = VIZIJA_ENEMY_ONLY and "Samo protivnici" or "Svi igrači"
end)

-- Boja sekcija
ColorLabel.Text = "Boja kutije"
ColorWheel.Position = UDim2.new(0, 8, 0, 36)
ColorPreview.Position = UDim2.new(0, 90, 0, 36)

-- Glavudja sekcija
MetaLabel.Text = "Povecaj glavudju"
HeadBtn.Visible = true
HeadBtn.Position = UDim2.new(0, 8, 0, 36)
TorsoBtn.Visible = true
TorsoBtn.Position = UDim2.new(0, 90, 0, 36)
FOVInput.Position = UDim2.new(0, 8, 0, 74)
FOVInput.Size = UDim2.new(0, 60, 0, 28)
RedBtn.Position = UDim2.new(0, 8, 0, 112)
BlueBtn.Position = UDim2.new(0, 46, 0, 112)
GreenBtn.Position = UDim2.new(0, 84, 0, 112)

-- Imena sekcija
ImenaLabel.Text = "Imena"
ImenaToggle.Visible = true
ImenaToggle.Position = UDim2.new(0, 8, 0, 36)
ImenaToggle.Size = UDim2.new(0, 100, 0, 28)
ImenaScaleLabel.Position = UDim2.new(0, 8, 0, 74)
ImenaScaleInput.Position = UDim2.new(0, 70, 0, 74)
ImenaScaleInput.Size = UDim2.new(0, 60, 0, 28)
KrozzidToggle.Visible = true
KrozzidToggle.Position = UDim2.new(0, 8, 0, 112)
KrozzidToggle.Size = UDim2.new(0, 120, 0, 28)

-- Bindovi sekcija
BindoviLabel.Text = "Bindovi (tipke)"
ESPBindBtn.Position = UDim2.new(0, 8, 0, 36)
HitboxBindBtn.Position = UDim2.new(0, 100, 0, 36)
ImenaBindBtn.Position = UDim2.new(0, 192, 0, 36)
KrozzidBindBtn.Position = UDim2.new(0, 284, 0, 36)

-- Ukloni sve MouseEnter/MouseLeave evente sa svih dugmića
-- (Ovo je implicitno jer više ne dodajemo te evente)