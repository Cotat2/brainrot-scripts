-- Script con menú estilo Hub para Delta (Corregido y Persistente)

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Estado de las funciones
local multipleJumpEnabled = false
local wallhackEnabled = false

-- Función para manejar el Salto Múltiple
local function handleJump(humanoid)
    if multipleJumpEnabled then
        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Función para activar o desactivar el Salto Múltiple
local function toggleMultipleJump(state, humanoid)
    multipleJumpEnabled = state
    if state then
        UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if input.KeyCode == Enum.KeyCode.Space then
                handleJump(humanoid)
            end
        end)
    end
end

-- Función para activar o desactivar el Wallhack (ESP)
local function toggleWallhack(state)
    wallhackEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local head = player.Character:FindFirstChild("Head")
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

-- Creamos el ScreenGui que se usará para el menú y el botón de mostrar
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubMenu"

-- Creamos el Frame principal del menú
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Creamos la barra de navegación lateral
local navFrame = Instance.new("Frame")
navFrame.Size = UDim2.new(0, 150, 1, 0)
navFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
navFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "Chilli Hub"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
titleLabel.Parent = navFrame

-- Creamos los botones de las pestañas
local function createTabButton(text, yOffset)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, yOffset)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    button.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextScaled = true
    button.Parent = navFrame
    return button
end

local mainButton = createTab
