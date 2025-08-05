-- GUI Personalizada para "Roba un Brainrot"
-- Incluye: Boost Velocidad, Saltos Infinitos

-- Crear UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local SpeedButton = Instance.new("TextButton")
local JumpButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

-- Propiedades UI
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "BrainrotScriptUI"

Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Frame.Parent = ScreenGui

SpeedButton.Size = UDim2.new(1, -20, 0, 40)
SpeedButton.Position = UDim2.new(0, 10, 0, 10)
SpeedButton.Text = "Activar Boost Velocidad"
SpeedButton.BackgroundColor3 = Color3.new(0.1, 0.6, 0.2)
SpeedButton.TextColor3 = Color3.new(1, 1, 1)
SpeedButton.Parent = Frame

JumpButton.Size = UDim2.new(1, -20, 0, 40)
JumpButton.Position = UDim2.new(0, 10, 0, 60)
JumpButton.Text = "Activar Saltos Infinitos"
JumpButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
JumpButton.TextColor3 = Color3.new(1, 1, 1)
JumpButton.Parent = Frame

CloseButton.Size = UDim2.new(1, -20, 0, 30)
CloseButton.Position = UDim2.new(0, 10, 1, -40)
CloseButton.Text = "Cerrar Menú"
CloseButton.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = Frame

-- Función Boost Velocidad
SpeedButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed * 2
    end
end)

-- Función Saltos Infinitos
JumpButton.MouseButton1Click:Connect(function()
    local UIS = game:GetService("UserInputService")
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    UIS.JumpRequest:Connect(function()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- Función Cerrar Menú
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
