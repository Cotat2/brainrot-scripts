-- Script con menú para Delta (Versión final)
-- Incluye Salto Múltiple, Salto Potenciado (ajustable) y Wallhack (ESP)

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Estado de las funciones
local multipleJumpEnabled = false
local wallhackEnabled = false
local jumpBoostEnabled = false

-- Valor del salto potenciado
local originalJumpPower = Humanoid.JumpPower
local jumpBoostValue = 50 -- Valor por defecto

-- Función para manejar el Salto Múltiple
local function handleJump()
    if multipleJumpEnabled then
        if Humanoid.Health > 0 then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Función para activar o desactivar el Salto Múltiple
local function toggleMultipleJump(state)
    multipleJumpEnabled = state
    if state then
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
            if input.KeyCode == Enum.KeyCode.Space then
                handleJump()
            end
        end)
    end
end

-- Función para activar o desactivar el Salto Potenciado
local function toggleJumpBoost(state)
    jumpBoostEnabled = state
    if state then
        Humanoid.JumpPower = originalJumpPower + jumpBoostValue
    else
        Humanoid.JumpPower = originalJumpPower
    end
end

-- Función para actualizar el valor del Salto Potenciado desde el TextBox
local function updateJumpBoostValue(text)
    local num = tonumber(text)
    if num then
        jumpBoostValue = num
    end
end

-- Función para activar o desactivar el Wallhack (ESP)
local function toggleWallhack(state)
    wallhackEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Humanoid then
                local head = player.Character:WaitForChild("Head")
                if head and head:FindFirstChild("PlayerESP") == nil then
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Name = "PlayerESP"
                    billboardGui.Size = UDim2.new(0, 100, 0, 50)
                    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
                    billboardGui.AlwaysOnTop = true

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Text = player.Name
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.Font = Enum.Font.SourceSans
                    textLabel.TextSize = 14
                    textLabel.TextColor3 = Color3.new(1, 0, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Parent = billboardGui

                    billboardGui.Parent = head
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("PlayerESP")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end
end

-- Creamos el menú
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0.5, -100, 0.5, -125)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Mod Menu"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
title.Parent = frame

local multipleJumpButton = Instance.new("TextButton")
multipleJumpButton.Size = UDim2.new(1, -20, 0, 40)
multipleJumpButton.Position = UDim2.new(0, 10, 0, 40)
multipleJumpButton.Text = "Salto Múltiple: OFF"
multipleJumpButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
multipleJumpButton.Parent = frame

multipleJumpButton.MouseButton1Click:Connect(function()
    toggleMultipleJump(not multipleJumpEnabled)
    multipleJumpButton.Text = "Salto Múltiple: " .. (multipleJumpEnabled and "ON" or "OFF")
end)

local jumpBoostLabel = Instance.new("TextLabel")
jumpBoostLabel.Size = UDim2.new(0, 100, 0, 20)
jumpBoostLabel.Position = UDim2.new(0, 10, 0, 90)
jumpBoostLabel.Text = "Salto Potenciado:"
jumpBoostLabel.Font = Enum.Font.SourceSans
jumpBoostLabel.TextSize = 14
jumpBoostLabel.TextColor3 = Color3.new(1, 1, 1)
jumpBoostLabel.BackgroundTransparency = 1
jumpBoostLabel.Parent = frame

local jumpBoostTextBox = Instance.new("TextBox")
jumpBoostTextBox.Size = UDim2.new(0, 60, 0, 20)
jumpBoostTextBox.Position = UDim2.new(0, 120, 0, 90)
jumpBoostTextBox.PlaceholderText = tostring(jumpBoostValue)
jumpBoostTextBox.Text = tostring(jumpBoostValue)
jumpBoostTextBox.Font = Enum.Font.SourceSans
jumpBoostTextBox.TextSize = 14
jumpBoostTextBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
jumpBoostTextBox.Parent = frame

jumpBoostTextBox.FocusLost:Connect(function()
    updateJumpBoostValue(jumpBoostTextBox.Text)
    if jumpBoostEnabled then
        toggleJumpBoost(false)
        toggleJumpBoost(true)
    end
end)

local wallhackButton = Instance.new("TextButton")
wallhackButton.Size = UDim2.new(1, -20, 0, 40)
wallhackButton.Position = UDim2.new(0, 10, 0, 140)
wallhackButton.Text = "Wallhack (ESP): OFF"
wallhackButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
wallhackButton.Parent = frame

wallhackButton.MouseButton1Click:Connect(function()
    toggleWallhack(not wallhackEnabled)
    wallhackButton.Text = "Wallhack (ESP): " .. (wallhackEnabled and "ON" or "OFF")
end)

local jumpBoostToggleButton = Instance.new("TextButton")
jumpBoostToggleButton.Size = UDim2.new(1, -20, 0, 40)
jumpBoostToggleButton.Position = UDim2.new(0, 10, 0, 190)
jumpBoostToggleButton.Text = "Activar Salto Potenciado: OFF"
jumpBoostToggleButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
jumpBoostToggleButton.Parent = frame

jumpBoostToggleButton.MouseButton1Click:Connect(function()
    toggleJumpBoost(not jumpBoostEnabled)
    jumpBoostToggleButton.Text = "Activar Salto Potenciado: " .. (jumpBoostEnabled and "ON" or "OFF")
end)
