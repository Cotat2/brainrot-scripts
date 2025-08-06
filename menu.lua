-- Script con menú estilo Hub para Delta

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")

-- Estado de las funciones
local multipleJumpEnabled = false
local wallhackEnabled = false

-- Estado del menú
local menuHidden = false

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
        UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if input.KeyCode == Enum.KeyCode.Space then
                handleJump()
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

-- Creamos el ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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

local mainButton = createTabButton("  Main", 40)
local stealerButton = createTabButton("  Stealer", 80)
local helperButton = createTabButton("  Helper", 120)
local playerButton = createTabButton("  Player", 160)
local finderButton = createTabButton("  Finder", 200)
local serverButton = createTabButton("  Server", 240)
local discordButton = createTabButton("  Discord!", 280)

-- Creamos el área de contenido
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -150, 1, -40)
contentFrame.Position = UDim2.new(0, 150, 0, 40)
contentFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
contentFrame.Parent = mainFrame

-- Función para cambiar de pestaña
local currentTab
local function changeTab(tabFrame)
    if currentTab then
        currentTab.Visible = false
    end
    currentTab = tabFrame
    currentTab.Visible = true
end

-- Creamos las pestañas (frames de contenido)
local mainTab = Instance.new("Frame")
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
mainTab.Parent = contentFrame
mainTab.Visible = false

local playerTab = Instance.new("Frame")
playerTab.Size = UDim2.new(1, 0, 1, 0)
playerTab.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
playerTab.Parent = contentFrame
playerTab.Visible = false

-- Aquí puedes crear más pestañas
local stealerTab = Instance.new("Frame")
stealerTab.Size = UDim2.new(1, 0, 1, 0)
stealerTab.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
stealerTab.Parent = contentFrame
stealerTab.Visible = false

-- Conectamos los botones a las pestañas
mainButton.MouseButton1Click:Connect(function() changeTab(mainTab) end)
playerButton.MouseButton1Click:Connect(function() changeTab(playerTab) end)
stealerButton.MouseButton1Click:Connect(function() changeTab(stealerTab) end)

-- Inicialmente mostramos la pestaña principal
changeTab(mainTab)

-- Creamos los botones de las funciones en la pestaña "Player"
local multipleJumpButton = Instance.new("TextButton")
multipleJumpButton.Size = UDim2.new(0, 180, 0, 40)
multipleJumpButton.Position = UDim2.new(0, 20, 0, 20)
multipleJumpButton.Text = "Salto Múltiple: OFF"
multipleJumpButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
multipleJumpButton.Parent = playerTab
multipleJumpButton.MouseButton1Click:Connect(function()
    toggleMultipleJump(not multipleJumpEnabled)
    multipleJumpButton.Text = "Salto Múltiple: " .. (multipleJumpEnabled and "ON" or "OFF")
end)

local wallhackButton = Instance.new("TextButton")
wallhackButton.Size = UDim2.new(0, 180, 0, 40)
wallhackButton.Position = UDim2.new(0, 20, 0, 80)
wallhackButton.Text = "Wallhack (ESP): OFF"
wallhackButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
wallhackButton.Parent = playerTab
wallhackButton.MouseButton1Click:Connect(function()
    toggleWallhack(not wallhackEnabled)
    wallhackButton.Text = "Wallhack (ESP): " .. (wallhackEnabled and "ON" or "OFF")
end)

-- Botón para ocultar el menú
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 20, 0, 20)
hideButton.Position = UDim2.new(1, -25, 0, 5)
hideButton.Text = "-"
hideButton.Font = Enum.Font.SourceSansBold
hideButton.TextSize = 20
hideButton.TextColor3 = Color3.new(1, 1, 1)
hideButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
hideButton.Parent = mainFrame

-- Botón para mostrar el menú (el "logo" discreto)
local showButton = Instance.new("TextButton")
showButton.Size = UDim2.new(0, 50, 0, 50)
showButton.Position = UDim2.new(0.5, -25, 0.5, -25)
showButton.Text = "CH"
showButton.Font = Enum.Font.SourceSansBold
showButton.TextSize = 20
showButton.TextColor3 = Color3.new(1, 1, 1)
showButton.BackgroundColor3 = Color3.new(0.5, 0.2, 0.2)
showButton.Visible = false
showButton.Parent = screenGui

-- Conexión de los botones para ocultar/mostrar
hideButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    showButton.Visible = true
end)

showButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    showButton.Visible = false
end)
