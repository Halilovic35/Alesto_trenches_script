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
MainFrame.Size = Config.MenuSize
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

-- Section: Vizija (ESP)
local VizijaSection = Instance.new("Frame", MainFrame)
VizijaSection.Size = UDim2.new(1, -32, 0, 90)
VizijaSection.Position = UDim2.new(0, 16, 0, 60)
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

-- Section: Meta (Hitbox)
local MetaSection = Instance.new("Frame", MainFrame)
MetaSection.Size = UDim2.new(1, -32, 0, 110)
MetaSection.Position = UDim2.new(0, 16, 0, 280)
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
        local value = math.floor(rel * (MAX_HITBOX_FOV-1) + 1)
        META_FOV = value
        FOVSlider.Text = tostring(value)
    end
end)

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

-- GUI: Bind sekcija (sve u jednom redu)
local BindSection = Instance.new("Frame", MainFrame)
BindSection.Size = UDim2.new(1, -32, 0, 40)
BindSection.Position = UDim2.new(0, 16, 0, 570)
BindSection.BackgroundColor3 = Config.Colors.Section
BindSection.BorderSizePixel = 0
local BindCorner = Instance.new("UICorner", BindSection)
BindCorner.CornerRadius = UDim.new(0, 12)

local ESPBindBtn = Instance.new("TextButton", BindSection)
ESPBindBtn.Size = UDim2.new(0, 90, 0, 28)
ESPBindBtn.Position = UDim2.new(0, 10, 0, 6)
ESPBindBtn.BackgroundColor3 = Config.Colors.Accent
ESPBindBtn.Text = "ESP: "..tostring(ESP_BIND.Name)
ESPBindBtn.TextColor3 = Config.Colors.Text
ESPBindBtn.TextScaled = true
ESPBindBtn.Font = Enum.Font.GothamBold
local ESPBindCorner = Instance.new("UICorner", ESPBindBtn)
ESPBindCorner.CornerRadius = UDim.new(0, 8)

local HitboxBindBtn = Instance.new("TextButton", BindSection)
HitboxBindBtn.Size = UDim2.new(0, 90, 0, 28)
HitboxBindBtn.Position = UDim2.new(0, 110, 0, 6)
HitboxBindBtn.BackgroundColor3 = Config.Colors.Accent
HitboxBindBtn.Text = "Hitbox: "..tostring(HITBOX_BIND.Name)
HitboxBindBtn.TextColor3 = Config.Colors.Text
HitboxBindBtn.TextScaled = true
HitboxBindBtn.Font = Enum.Font.GothamBold
local HitboxBindCorner = Instance.new("UICorner", HitboxBindBtn)
HitboxBindCorner.CornerRadius = UDim.new(0, 8)

local NametagBindBtn = Instance.new("TextButton", BindSection)
NametagBindBtn.Size = UDim2.new(0, 110, 0, 28)
NametagBindBtn.Position = UDim2.new(0, 210, 0, 6)
NametagBindBtn.BackgroundColor3 = Config.Colors.Accent
NametagBindBtn.Text = "Nametag: "..tostring(NAMETAG_BIND.Name)
NametagBindBtn.TextColor3 = Config.Colors.Text
NametagBindBtn.TextScaled = true
NametagBindBtn.Font = Enum.Font.GothamBold
local NametagBindCorner = Instance.new("UICorner", NametagBindBtn)
NametagBindCorner.CornerRadius = UDim.new(0, 8)

local KrozzidBindBtn = Instance.new("TextButton", BindSection)
KrozzidBindBtn.Size = UDim2.new(0, 110, 0, 28)
KrozzidBindBtn.Position = UDim2.new(0, 330, 0, 6)
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
NametagBindBtn.MouseButton1Click:Connect(function()
    NametagBindBtn.Text = "Pritisni tipku..."
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
FOVSlider.MouseButton1Down:Connect(function()
    draggingFOV = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - FOVSlider.AbsolutePosition.X) / FOVSlider.AbsoluteSize.X, 0, 1)
        local value = math.floor(rel * (MAX_HITBOX_FOV-1) + 1)
        META_FOV = value
        FOVSlider.Text = tostring(value)
    end
end)

-- Ukloni stari slider za HB veličinu do 200 (ako postoji)
if HitboxFOVLabel then HitboxFOVLabel:Destroy() end
if HitboxFOVSlider then HitboxFOVSlider:Destroy() end

-- NOVI PANEL: Sve u jednom (Vizija, Boja kutije, Povecaj glavudju, Imena, Krozzid)
-- (Zadržavamo postojeće sekcije, ali ih rearanžiramo i preimenujemo)

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

local ImenaScaleSlider = Instance.new("TextButton", MetaSection)
ImenaScaleSlider.Size = UDim2.new(0, 100, 0, 28)
ImenaScaleSlider.Position = UDim2.new(0, 320, 0, 8+32+48+28+8)
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