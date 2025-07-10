--[[
    Neutral Panel Script (Stealth Version)
    by Halilovic35 & AI
    Sva imena su randomizirana, GUI i funkcije su neutralne
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
    MenuSize = UDim2.new(0, 350, 0, 420),
    MenuPosition = UDim2.new(0.5, -175, 0.5, -210),
    MinimizedSize = UDim2.new(0, 50, 0, 50),
    MinimizedPosition = UDim2.new(0, 100, 0, 100),
    MenuKey = Enum.KeyCode.RightShift,
    Colors = {
        Primary = Color3.fromRGB(45, 45, 45),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Minimized = Color3.fromRGB(0, 150, 255)
    }
}

local isMenuOpen = true
local isMinimized = false

-- State for features
local FEATURE1_ENABLED = false
local FEATURE1_COLOR = Color3.fromRGB(0, 150, 255)
local FEATURE1_ENEMY_ONLY = true
local feature1Boxes = {}
local FEATURE2_HEAD = true
local FEATURE2_TORSO = false
local FEATURE2_FOV = 3

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
Corner.CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Name = "Bar_"..randStr(3)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Config.Colors.Secondary
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Panel"
Title.TextColor3 = Config.Colors.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 2)
MinimizeBtn.BackgroundColor3 = Config.Colors.Accent
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Config.Colors.Text
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
local MinBtnCorner = Instance.new("UICorner", MinimizeBtn)
MinBtnCorner.CornerRadius = UDim.new(0, 8)

-- Opcija 1 (bivši ESP)
local Feature1Toggle = Instance.new("TextButton", MainFrame)
Feature1Toggle.Size = UDim2.new(0, 140, 0, 40)
Feature1Toggle.Position = UDim2.new(0, 20, 0, 60)
Feature1Toggle.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
Feature1Toggle.Text = "Opcija 1: OFF"
Feature1Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Feature1Toggle.TextScaled = true
Feature1Toggle.Font = Enum.Font.GothamBold
local F1Corner = Instance.new("UICorner", Feature1Toggle)
F1Corner.CornerRadius = UDim.new(0, 8)

-- Boja (RGB slideri)
local ColorLabel = Instance.new("TextLabel", MainFrame)
ColorLabel.Size = UDim2.new(0, 120, 0, 30)
ColorLabel.Position = UDim2.new(0, 20, 0, 110)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Boja"
ColorLabel.TextColor3 = Config.Colors.Text
ColorLabel.TextScaled = true
ColorLabel.Font = Enum.Font.Gotham

local function makeSlider(name, y, default, callback, min, max)
    local label = Instance.new("TextLabel", MainFrame)
    label.Size = UDim2.new(0, 30, 0, 30)
    label.Position = UDim2.new(0, 20, 0, y)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Config.Colors.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham

    local slider = Instance.new("TextButton", MainFrame)
    slider.Size = UDim2.new(0, 180, 0, 30)
    slider.Position = UDim2.new(0, 60, 0, y)
    slider.BackgroundColor3 = Color3.fromRGB(default, default, default)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.fromRGB(0,0,0)
    slider.TextScaled = true
    slider.Font = Enum.Font.Gotham
    local dragging = false
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor(rel * ((max or 255)-(min or 0)) + (min or 0))
            slider.Text = tostring(value)
            if name == "FOV" then
                callback(value)
                slider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            else
                slider.BackgroundColor3 = Color3.fromRGB(
                    name=="R" and value or FEATURE1_COLOR.R*255,
                    name=="G" and value or FEATURE1_COLOR.G*255,
                    name=="B" and value or FEATURE1_COLOR.B*255
                )
                callback(value)
            end
        end
    end)
    return slider
end

local function updateF1Color()
    Feature1Toggle.BackgroundColor3 = FEATURE1_COLOR
end

local rSlider = makeSlider("R", 150, FEATURE1_COLOR.R*255, function(v)
    FEATURE1_COLOR = Color3.fromRGB(v, FEATURE1_COLOR.G*255, FEATURE1_COLOR.B*255)
    updateF1Color()
end)
local gSlider = makeSlider("G", 190, FEATURE1_COLOR.G*255, function(v)
    FEATURE1_COLOR = Color3.fromRGB(FEATURE1_COLOR.R*255, v, FEATURE1_COLOR.B*255)
    updateF1Color()
end)
local bSlider = makeSlider("B", 230, FEATURE1_COLOR.B*255, function(v)
    FEATURE1_COLOR = Color3.fromRGB(FEATURE1_COLOR.R*255, FEATURE1_COLOR.G*255, v)
    updateF1Color()
end)

-- Opcija 1: Samo protivnici
local OnlyEnemiesBtn = Instance.new("TextButton", MainFrame)
OnlyEnemiesBtn.Size = UDim2.new(0, 180, 0, 35)
OnlyEnemiesBtn.Position = UDim2.new(0, 20, 0, 270)
OnlyEnemiesBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
OnlyEnemiesBtn.Text = "Opcija 1: Samo protivnici"
OnlyEnemiesBtn.TextColor3 = Color3.fromRGB(255,255,255)
OnlyEnemiesBtn.TextScaled = true
OnlyEnemiesBtn.Font = Enum.Font.Gotham
local OnlyEnemiesCorner = Instance.new("UICorner", OnlyEnemiesBtn)
OnlyEnemiesCorner.CornerRadius = UDim.new(0, 8)

OnlyEnemiesBtn.MouseButton1Click:Connect(function()
    FEATURE1_ENEMY_ONLY = not FEATURE1_ENEMY_ONLY
    OnlyEnemiesBtn.Text = FEATURE1_ENEMY_ONLY and "Opcija 1: Samo protivnici" or "Opcija 1: Svi igraci"
end)

-- Opcija 2 (bivši hitbox)
local HitboxLabel = Instance.new("TextLabel", MainFrame)
HitboxLabel.Size = UDim2.new(0, 120, 0, 30)
HitboxLabel.Position = UDim2.new(0, 20, 0, 320)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "FOV"
HitboxLabel.TextColor3 = Config.Colors.Text
HitboxLabel.TextScaled = true
HitboxLabel.Font = Enum.Font.GothamBold

local FOVSlider = makeSlider("FOV", 360, FEATURE2_FOV, function(v)
    FEATURE2_FOV = v
end, 1, 20)

local GlavaBtn = Instance.new("TextButton", MainFrame)
GlavaBtn.Size = UDim2.new(0, 70, 0, 30)
GlavaBtn.Position = UDim2.new(0, 200, 0, 320)
GlavaBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
GlavaBtn.Text = "Opcija 2: 1"
GlavaBtn.TextColor3 = FEATURE2_HEAD and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
GlavaBtn.TextScaled = true
GlavaBtn.Font = Enum.Font.GothamBold
local GlavaCorner = Instance.new("UICorner", GlavaBtn)
GlavaCorner.CornerRadius = UDim.new(0, 8)

local TijeloBtn = Instance.new("TextButton", MainFrame)
TijeloBtn.Size = UDim2.new(0, 70, 0, 30)
TijeloBtn.Position = UDim2.new(0, 280, 0, 320)
TijeloBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
TijeloBtn.Text = "Opcija 2: 2"
TijeloBtn.TextColor3 = FEATURE2_TORSO and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
TijeloBtn.TextScaled = true
TijeloBtn.Font = Enum.Font.GothamBold
local TijeloCorner = Instance.new("UICorner", TijeloBtn)
TijeloCorner.CornerRadius = UDim.new(0, 8)

GlavaBtn.MouseButton1Click:Connect(function()
    FEATURE2_HEAD = not FEATURE2_HEAD
    GlavaBtn.TextColor3 = FEATURE2_HEAD and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
end)
TijeloBtn.MouseButton1Click:Connect(function()
    FEATURE2_TORSO = not FEATURE2_TORSO
    TijeloBtn.TextColor3 = FEATURE2_TORSO and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
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

-- Keyboard toggle
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

-- Opcija 1 toggle
Feature1Toggle.MouseButton1Click:Connect(function()
    FEATURE1_ENABLED = not FEATURE1_ENABLED
    Feature1Toggle.Text = FEATURE1_ENABLED and "Opcija 1: ON" or "Opcija 1: OFF"
    Feature1Toggle.BackgroundColor3 = FEATURE1_ENABLED and FEATURE1_COLOR or Color3.fromRGB(30,120,200)
    if not FEATURE1_ENABLED then
        for _,v in pairs(feature1Boxes) do v:Remove() end
        feature1Boxes = {}
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
    return getTeam(player) ~= getTeam(lp)
end

local function getChar(plr)
    return plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character
end

local function get2DBox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local minY, maxY = hrp.Position.Y, hrp.Position.Y
    if FEATURE2_HEAD and head then
        minY = math.min(minY, head.Position.Y)
        maxY = math.max(maxY, head.Position.Y)
    end
    if FEATURE2_TORSO and torso then
        minY = math.min(minY, torso.Position.Y)
        maxY = math.max(maxY, torso.Position.Y)
    end
    local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onscreen then return end
    local fov = FEATURE2_FOV or 3
    local w = 3.5 * fov * (FEATURE2_TORSO and 1.2 or 1)
    local h = (maxY - minY + 2.5) * 10 * fov
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

-- Opcija 2 (hitbox) loop
RunService.RenderStepped:Connect(function()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and isEnemy(plr) and getChar(plr) then
            local char = getChar(plr)
            if FEATURE2_HEAD then
                local head = char:FindFirstChild("Head")
                if head then
                    pcall(function()
                        head.Size = Vector3.new(FEATURE2_FOV, FEATURE2_FOV, FEATURE2_FOV)
                        head.CanCollide = false
                        head.Transparency = 0.5
                    end)
                end
            end
            if FEATURE2_TORSO then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then
                    pcall(function()
                        torso.Size = Vector3.new(FEATURE2_FOV*2, FEATURE2_FOV*2, FEATURE2_FOV*1.5)
                        torso.CanCollide = false
                        torso.Transparency = 0.5
                    end)
                end
            end
        end
    end
end)

-- Opcija 1 (ESP) loop
RunService.RenderStepped:Connect(function()
    if not FEATURE1_ENABLED then return end
    for _,v in pairs(feature1Boxes) do v.Visible = false end
    local i = 1
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and getChar(plr) then
            if (FEATURE1_ENEMY_ONLY and isEnemy(plr)) or (not FEATURE1_ENEMY_ONLY) then
                local char = getChar(plr)
                local x, y, w, h = get2DBox(char)
                if x and y and w and h then
                    if not feature1Boxes[i] then feature1Boxes[i] = createBox() end
                    local box = feature1Boxes[i]
                    box.Visible = true
                    box.Color = FEATURE1_COLOR
                    box.Position = Vector2.new(x, y)
                    box.Size = Vector2.new(w, h)
                    i = i + 1
                end
            end
        end
    end
    for j = i, #feature1Boxes do
        if feature1Boxes[j] then feature1Boxes[j].Visible = false end
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