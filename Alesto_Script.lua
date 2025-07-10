--[[
    Vizija & Meta Panel (Modern Version)
    by Halilovic35 & AI
    Moderan GUI, color wheel, precizne kutije, jasne sekcije
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

-- Hotkey config
local ESP_HOTKEY = Enum.KeyCode.E
local HITBOX_HOTKEY = Enum.KeyCode.H

-- State
local VIZIJA_ENABLED = false
local HITBOX_ENABLED = false
local VIZIJA_ENEMY_ONLY = true
local FORCE_RENDER = true -- Uvijek renderuj igrače
local vizijaBoxes = {}
local META_HEAD = true
local META_TORSO = false
local META_FOV = 3

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

-- Modern toggle (slide) helper
local function createToggle(parent, label, state, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0, 120, 0, 32)
    Frame.BackgroundTransparency = 1
    
    local Text = Instance.new("TextLabel", Frame)
    Text.Size = UDim2.new(0.6, 0, 1, 0)
    Text.Position = UDim2.new(0, 0, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = label
    Text.TextColor3 = Config.Colors.Text
    Text.TextScaled = true
    Text.Font = Enum.Font.GothamBold
    
    local Toggle = Instance.new("TextButton", Frame)
    Toggle.Size = UDim2.new(0, 48, 0, 24)
    Toggle.Position = UDim2.new(0.65, 0, 0.15, 0)
    Toggle.BackgroundColor3 = state and Config.Colors.Accent or Color3.fromRGB(60,60,60)
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    local Corner = Instance.new("UICorner", Toggle)
    Corner.CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Toggle)
    Circle.Size = UDim2.new(0, 20, 0, 20)
    Circle.Position = state and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    Circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Circle.BorderSizePixel = 0
    local CircleCorner = Instance.new("UICorner", Circle)
    CircleCorner.CornerRadius = UDim.new(1, 0)
    
    local function updateToggle(val)
        Toggle.BackgroundColor3 = val and Config.Colors.Accent or Color3.fromRGB(60,60,60)
        Circle:TweenPosition(val and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.15, true)
    end
    
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle(state)
        if callback then callback(state) end
    end)
    
    updateToggle(state)
    return Frame, function(val)
        state = val
        updateToggle(state)
    end
end

-- ESP Toggle
local VizijaToggleFrame, setVizijaToggle = createToggle(MainFrame, "Vizija (kutije)", VIZIJA_ENABLED, function(val)
    VIZIJA_ENABLED = val
end)
VizijaToggleFrame.Position = UDim2.new(0, 16, 0, 60)

-- Hitbox Toggle
local HitboxToggleFrame, setHitboxToggle = createToggle(MainFrame, "Meta (hitbox)", HITBOX_ENABLED, function(val)
    HITBOX_ENABLED = val
end)
HitboxToggleFrame.Position = UDim2.new(0, 16, 0, 110)

-- Hotkey GUI
local HotkeyFrame = Instance.new("Frame", MainFrame)
HotkeyFrame.Size = UDim2.new(1, -32, 0, 40)
HotkeyFrame.Position = UDim2.new(0, 16, 0, 160)
HotkeyFrame.BackgroundTransparency = 1
local HotkeyLabel = Instance.new("TextLabel", HotkeyFrame)
HotkeyLabel.Size = UDim2.new(0.5, 0, 1, 0)
HotkeyLabel.Position = UDim2.new(0, 0, 0, 0)
HotkeyLabel.BackgroundTransparency = 1
HotkeyLabel.Text = "ESP tipka: "..ESP_HOTKEY.Name.." | Hitbox tipka: "..HITBOX_HOTKEY.Name
HotkeyLabel.TextColor3 = Config.Colors.Text
HotkeyLabel.TextScaled = true
HotkeyLabel.Font = Enum.Font.Gotham

-- Hotkey change logic (klikni na labelu, pa pritisni tipku)
HotkeyLabel.MouseButton1Click:Connect(function()
    HotkeyLabel.Text = "Pritisni tipku za ESP..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        ESP_HOTKEY = input.KeyCode
        HotkeyLabel.Text = "ESP tipka: "..ESP_HOTKEY.Name.." | Hitbox tipka: "..HITBOX_HOTKEY.Name
        conn:Disconnect()
    end)
end)

HotkeyLabel.MouseButton2Click:Connect(function()
    HotkeyLabel.Text = "Pritisni tipku za Hitbox..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        HITBOX_HOTKEY = input.KeyCode
        HotkeyLabel.Text = "ESP tipka: "..ESP_HOTKEY.Name.." | Hitbox tipka: "..HITBOX_HOTKEY.Name
        conn:Disconnect()
    end)
end)

-- Hotkey logic
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == ESP_HOTKEY then
        VIZIJA_ENABLED = not VIZIJA_ENABLED
        setVizijaToggle(VIZIJA_ENABLED)
    elseif input.KeyCode == HITBOX_HOTKEY then
        HITBOX_ENABLED = not HITBOX_ENABLED
        setHitboxToggle(HITBOX_ENABLED)
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
MetaLabel.Text = "Meta (hitbox)"
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
        local value = math.floor(rel * 19 + 1)
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

-- Meta (hitbox) loop
RunService.RenderStepped:Connect(function()
    if not HITBOX_ENABLED then return end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and isEnemy(plr) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            if META_HEAD then
                local head = char:FindFirstChild("Head")
                if head then
                    pcall(function()
                        head.Size = Vector3.new(META_FOV, META_FOV, META_FOV)
                        head.CanCollide = false
                        head.Transparency = 0.5
                    end)
                end
            end
            if META_TORSO then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then
                    pcall(function()
                        torso.Size = Vector3.new(META_FOV*2, META_FOV*2, META_FOV*1.5)
                        torso.CanCollide = false
                        torso.Transparency = 0.5
                    end)
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
            if (not VIZIJA_ENEMY_ONLY) or (isEnemy(plr)) then
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

-- Accordion sekcije
local accordionState = {Hitbox = false, ESP = false}
local function closeAllDropdowns()
    accordionState.Hitbox = false
    accordionState.ESP = false
    HitboxDropdown:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true)
    ESPDropdown:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true)
end

-- Hitbox sekcija
local HitboxSection = Instance.new("Frame", MainFrame)
HitboxSection.Size = UDim2.new(1, -32, 0, 40)
HitboxSection.Position = UDim2.new(0, 16, 0, 60)
HitboxSection.BackgroundColor3 = Config.Colors.Section
HitboxSection.BorderSizePixel = 0
local HitboxCorner = Instance.new("UICorner", HitboxSection)
HitboxCorner.CornerRadius = UDim.new(0, 10)

local HitboxLabel = Instance.new("TextLabel", HitboxSection)
HitboxLabel.Size = UDim2.new(1, -40, 1, 0)
HitboxLabel.Position = UDim2.new(0, 10, 0, 0)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "Hitbox"
HitboxLabel.TextColor3 = Config.Colors.Text
HitboxLabel.TextScaled = true
HitboxLabel.Font = Enum.Font.GothamBold

local HitboxToggle = Instance.new("TextButton", HitboxSection)
HitboxToggle.Size = UDim2.new(0, 32, 0, 32)
HitboxToggle.Position = UDim2.new(1, -38, 0, 4)
HitboxToggle.BackgroundColor3 = HITBOX_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
HitboxToggle.Text = ""
local HitboxToggleCorner = Instance.new("UICorner", HitboxToggle)
HitboxToggleCorner.CornerRadius = UDim.new(1, 0)

-- Dropdown za Hitbox
HitboxDropdown = Instance.new("Frame", MainFrame)
HitboxDropdown.Size = UDim2.new(1, -32, 0, 0)
HitboxDropdown.Position = UDim2.new(0, 16, 0, 100)
HitboxDropdown.BackgroundColor3 = Config.Colors.Section
HitboxDropdown.BorderSizePixel = 0
HitboxDropdown.ClipsDescendants = true
local HitboxDropdownCorner = Instance.new("UICorner", HitboxDropdown)
HitboxDropdownCorner.CornerRadius = UDim.new(0, 10)

-- ESP sekcija
local ESPSection = Instance.new("Frame", MainFrame)
ESPSection.Size = UDim2.new(1, -32, 0, 40)
ESPSection.Position = UDim2.new(0, 16, 0, 150)
ESPSection.BackgroundColor3 = Config.Colors.Section
ESPSection.BorderSizePixel = 0
local ESPCorner = Instance.new("UICorner", ESPSection)
ESPCorner.CornerRadius = UDim.new(0, 10)

local ESPLabel = Instance.new("TextLabel", ESPSection)
ESPLabel.Size = UDim2.new(1, -40, 1, 0)
ESPLabel.Position = UDim2.new(0, 10, 0, 0)
ESPLabel.BackgroundTransparency = 1
ESPLabel.Text = "ESP"
ESPLabel.TextColor3 = Config.Colors.Text
ESPLabel.TextScaled = true
ESPLabel.Font = Enum.Font.GothamBold

local ESPToggle = Instance.new("TextButton", ESPSection)
ESPToggle.Size = UDim2.new(0, 32, 0, 32)
ESPToggle.Position = UDim2.new(1, -38, 0, 4)
ESPToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
ESPToggle.Text = ""
local ESPToggleCorner = Instance.new("UICorner", ESPToggle)
ESPToggleCorner.CornerRadius = UDim.new(1, 0)

-- Dropdown za ESP
ESPDrodown = Instance.new("Frame", MainFrame)
ESPDrodown.Size = UDim2.new(1, -32, 0, 0)
ESPDrodown.Position = UDim2.new(0, 16, 0, 190)
ESPDrodown.BackgroundColor3 = Config.Colors.Section
ESPDrodown.BorderSizePixel = 0
ESPDrodown.ClipsDescendants = true
local ESPDropdownCorner = Instance.new("UICorner", ESPDrodown)
ESPDropdownCorner.CornerRadius = UDim.new(0, 10)

-- Toggle logika
HitboxToggle.MouseButton1Click:Connect(function()
    HITBOX_ENABLED = not HITBOX_ENABLED
    HitboxToggle.BackgroundColor3 = HITBOX_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)
HitboxSection.MouseButton2Click:Connect(function()
    closeAllDropdowns()
    accordionState.Hitbox = not accordionState.Hitbox
    if accordionState.Hitbox then
        HitboxDropdown:TweenSize(UDim2.new(1,0,0,120), "Out", "Quad", 0.2, true)
    else
        HitboxDropdown:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true)
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    VIZIJA_ENABLED = not VIZIJA_ENABLED
    ESPToggle.BackgroundColor3 = VIZIJA_ENABLED and Config.Colors.Accent or Color3.fromRGB(60,60,60)
end)
ESPSection.MouseButton2Click:Connect(function()
    closeAllDropdowns()
    accordionState.ESP = not accordionState.ESP
    if accordionState.ESP then
        ESPDrodown:TweenSize(UDim2.new(1,0,0,120), "Out", "Quad", 0.2, true)
    else
        ESPDrodown:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true)
    end
end)

-- Virtualni hitbox indikator (krug)
local Drawing = Drawing or getgenv().Drawing
local hitboxCircles = {}
RunService.RenderStepped:Connect(function()
    for _,circle in pairs(hitboxCircles) do circle.Visible = false end
    if HITBOX_ENABLED then
        local i = 1
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and isEnemy(plr) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
                if onscreen then
                    if not hitboxCircles[i] then
                        hitboxCircles[i] = Drawing.new("Circle")
                        hitboxCircles[i].Thickness = 2
                        hitboxCircles[i].Transparency = 1
                        hitboxCircles[i].ZIndex = 2
                        hitboxCircles[i].Filled = false
                        hitboxCircles[i].Color = Color3.fromRGB(255,0,0)
                    end
                    local circle = hitboxCircles[i]
                    circle.Visible = true
                    circle.Position = Vector2.new(pos.X, pos.Y)
                    circle.Radius = META_FOV * 10
                    i = i + 1
                end
            end
        end
        for j = i, #hitboxCircles do
            if hitboxCircles[j] then hitboxCircles[j].Visible = false end
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