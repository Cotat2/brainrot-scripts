-- Script con menú para Delta

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Estado de las funciones
local infiniteJumpEnabled = false
local wallhackEnabled = false
local noClipEnabled = false

-- Función para activar o desactivar el Salto Infinito
local function toggleInfiniteJump(state)
    infiniteJumpEnabled = state
    if state then
        Humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Freefall then
                if infiniteJumpEnabled then
                    wait()
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- Función para activar o desactivar el Wallhack (ESP)
local function toggleWallhack(state)
    wallhackEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Humanoid then
                -- Crea una etiqueta sobre la cabeza del jugador
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
                    textLabel.TextColor3 = Color3.new(1, 0, 0) -- Color rojo
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

-- Función para activar o desactivar el Atraviesa-Muros (NoClip)
local function toggleNoClip(state)
    noClipEnabled = state
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("BasePart") then
            child.CanCollide = not state
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

local infiniteJumpButton = Instance.new("TextButton")
infiniteJumpButton.Size = UDim2.new(1, -20, 0, 40)
infiniteJumpButton.Position = UDim2.new(0, 10, 0, 40)
infiniteJumpButton.Text = "Salto Infinito: OFF"
infiniteJumpButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
infiniteJumpButton.Parent = frame

infiniteJumpButton.MouseButton1Click:Connect(function()
    toggleInfiniteJump(not infiniteJumpEnabled)
    infiniteJumpButton.Text = "Salto Infinito: " .. (infiniteJumpEnabled and "ON" or "OFF")
end)

local wallhackButton = Instance.new("TextButton")
wallhackButton.Size = UDim2.new(1, -20, 0, 40)
wallhackButton.Position = UDim2.new(0, 10, 0, 90)
wallhackButton.Text = "Wallhack (ESP): OFF"
wallhackButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
wallhackButton.Parent = frame

wallhackButton.MouseButton1Click:Connect(function()
    toggleWallhack(not wallhackEnabled)
    wallhackButton.Text = "Wallhack (ESP): " .. (wallhackEnabled and "ON" or "OFF")
end)

local noClipButton = Instance.new("TextButton")
noClipButton.Size = UDim2.new(1, -20, 0, 40)
noClipButton.Position = UDim2.new(0, 10, 0, 140)
noClipButton.Text = "Atraviesa Muros: OFF"
noClipButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
noClipButton.Parent = frame

noClipButton.MouseButton1Click:Connect(function()
    toggleNoClip(not noClipEnabled)
    noClipButton.Text = "Atraviesa Muros: " .. (noClipEnabled and "ON" or "OFF")
end)
