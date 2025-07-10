--[[
    Alesto Script - Modern Clean Version (Base GUI)
    by Halilovic35 & AI
    Prva verzija: samo GUI sa drag & minimize/maximize
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- GUI Config
local Config = {
    MenuSize = UDim2.new(0, 350, 0, 300),
    MenuPosition = UDim2.new(0.5, -175, 0.5, -150),
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

-- State
local isMenuOpen = true
local isMinimized = false
local dragStart, startPos

-- GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlestoScriptGUI"
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
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
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Config.Colors.Secondary
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Alesto Script"
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

-- Minimized (kockica) GUI
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
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
    game:GetService("UserInputService").InputChanged:Connect(function(input)
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

-- Success notification
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Alesto Script",
        Text = "GUI loaded! (RightShift za toggle, - za minimizaciju)",
        Duration = 5
    })
end)

-- Dalje funkcije (ESP, Hitbox) će biti dodate u sledećim koracima! 