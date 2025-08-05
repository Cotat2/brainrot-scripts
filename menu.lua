--- GUI Personalizada para "Roba un Brainrot"
-- Incluye: Boost Velocidad y Regulador de Altura de Salto

-- Crear UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local SpeedButton = Instance.new("TextButton")
local JumpSliderFrame = Instance.new("Frame")
local SliderBar = Instance.new("Frame")
local SliderKnob = Instance.new("TextButton")
local JumpLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuración UI
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "BrainrotScriptUI"

Frame.Size = UDim2.new(0, 220, 0, 200)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Frame.Parent = ScreenGui

SpeedButton.Size = UDim2.new(1, -20, 0, 40)
SpeedButton.Position = UDim2.new(0, 10, 0, 10)
SpeedButton.Text = "Activar Boost Velocidad"
SpeedButton.BackgroundColor3 = Color3.new(0.1, 0.6, 0.2)
SpeedButton.TextColor3 = Color3.new(1, 1, 1)
SpeedButton.Parent = Frame

JumpSliderFrame.Size = UDim2.new(1, -20, 0, 60)
JumpSliderFrame.Position = UDim2.new(0, 10, 0, 60)
JumpSliderFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
JumpSliderFrame.Parent = Frame

JumpLabel.Size = UDim2.new(1, 0, 0, 20)
JumpLabel.Position = UDim2.new(0, 0, 0, 0)
JumpLabel.Text = "Altura de salto: 100"
JumpLabel.TextColor3 = Color3.new(1, 1, 1)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Parent = JumpSliderFrame

SliderBar.Size = UDim2.new(1, -20, 0, 10)
SliderBar.Position = UDim2.new(0, 10, 0, 30)
SliderBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SliderBar.Parent = JumpSliderFrame

SliderKnob.Size = UDim2.new(0, 10, 0, 20)
SliderKnob.Position = UDim2.new(0.45, 0, 0, 25)
SliderKnob.BackgroundColor3 = Color3.new(0.9, 0.4, 0.1)
SliderKnob.Text = ""
SliderKnob.Parent = JumpSliderFrame

CloseButton.Size = UDim2.new(1, -20, 0, 30)
CloseButton.Position = UDim2.new(0, 10, 1, -40)
CloseButton.Text = "Cerrar Menú"
CloseButton.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = Frame

-- Función Boost Velocidad
SpeedButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed * 2
    end
end)

-- Función para actualizar altura de salto
local function updateJumpPower(percent)
    local jumpPower = math.floor(50 + (percent * 150)) -- Rango de 50 a 200
    JumpLabel.Text = "Altura de salto: " .. jumpPower

    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = jumpPower
        end
    end
end

-- Control del slider
local dragging = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

SliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local absPos = SliderBar.AbsolutePosition.X
        local absSize = SliderBar.AbsoluteSize.X
        local percent = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
        SliderKnob.Position = UDim2.new(percent, -5, 0, 25)
        updateJumpPower(percent)
    end
end)

-- Inicializar con 100
updateJumpPower(0.33)

-- Cerrar menú
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
