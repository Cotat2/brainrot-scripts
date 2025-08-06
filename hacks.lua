-- Versión 4.0
-- Script con menú estilo Hub para Delta (Versión Final con Colores Corregidos)

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local lastMenuInstance = nil

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
            if input.KeyCode == Enum.KeyCode.Space and not gameProcessedEvent then
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

-- Función que se encarga de crear el menú y su lógica
local function createMenu()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("HubMenu") then
        playerGui:FindFirstChild("HubMenu"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HubMenu"
    screenGui.Parent = playerGui
    
    -- Creamos el Frame principal del menú con color y transparencia
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(1, 0.95, 0.4) -- Amarillo más brillante
    mainFrame.BackgroundTransparency = 0.5 -- 50% de transparencia
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    -- Creamos la barra de navegación lateral
    local navFrame = Instance.new("Frame")
    navFrame.Size = UDim2.new(0, 150, 1, 0)
    navFrame.BackgroundColor3 = Color3.new(0.8, 0.76, 0.3) -- Amarillo más oscuro
    navFrame.BackgroundTransparency = 0.5 -- 50% de transparencia
    navFrame.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Text = "Chilli Hub"
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.new(0, 0, 0) -- Texto negro
    titleLabel.BackgroundColor3 = Color3.new(0.6, 0.57, 0.2) -- Amarillo aún más oscuro
    titleLabel.Parent = navFrame

    -- Creamos los botones de las pestañas
    local function createTabButton(text, yOffset)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 40)
        button.Position = UDim2.new(0, 0, 0, yOffset)
        button.Text = text
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 16
        button.TextColor3 = Color3.new(0.2, 0.2, 0.2)
        button.BackgroundColor3 = Color3.new(0.8, 0.76, 0.3)
        button.BackgroundTransparency = 0.5 -- 50% de transparencia
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
    contentFrame.BackgroundColor3 = Color3.new(1, 0.95, 0.4)
    contentFrame.BackgroundTransparency = 0.5
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
    mainTab.BackgroundColor3 = Color3.new(1, 0.95, 0.4)
    mainTab.BackgroundTransparency = 0.5
    mainTab.Parent = contentFrame
    mainTab.Visible = false

    local playerTab = Instance.new("Frame")
    playerTab.Size = UDim2.new(1, 0, 1, 0)
    playerTab.BackgroundColor3 = Color3.new(1, 0.95, 0.4)
    playerTab.BackgroundTransparency = 0.5
    playerTab.Parent = contentFrame
    playerTab.Visible = false

    local stealerTab = Instance.new("Frame")
    stealerTab.Size = UDim2.new(1, 0, 1, 0)
    stealerTab.BackgroundColor3 = Color3.new(1, 0.95, 0.4)
    stealerTab.BackgroundTransparency = 0.5
    stealerTab.Parent = contentFrame
    stealerTab.Visible = false

    -- Conectamos los botones a las pestañas
    mainButton.MouseButton1Click:Connect(function() changeTab(mainTab) end)
    playerButton.MouseButton1Click:Connect(function() changeTab(playerTab) end)
    stealerButton.MouseButton1Click:Connect(function() changeTab(stealerTab) end)

    changeTab(mainTab)

    -- Creamos los botones de las funciones en la pestaña "Player"
    local multipleJumpButton = Instance.new("TextButton")
    multipleJumpButton.Size = UDim2.new(0, 180, 0, 40)
    multipleJumpButton.Position = UDim2.new(0, 20, 0, 20)
    multipleJumpButton.Text = "Salto Múltiple: OFF"
    multipleJumpButton.BackgroundColor3 = Color3.new(0.6, 0.57, 0.2)
    multipleJumpButton.Parent = playerTab
    multipleJumpButton.MouseButton1Click:Connect(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        toggleMultipleJump(not multipleJumpEnabled, humanoid)
        multipleJumpButton.Text = "Salto Múltiple: " .. (multipleJumpEnabled and "ON" or "OFF")
    end)

    local wallhackButton = Instance.new("TextButton")
    wallhackButton.Size = UDim2.new(0, 180, 0, 40)
    wallhackButton.Position = UDim2.new(0, 20, 0, 80)
    wallhackButton.Text = "Wallhack (ESP): OFF"
    wallhackButton.BackgroundColor3 = Color3.new(0.6, 0.57, 0.2)
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
    hideButton.TextColor3 = Color3.new(0, 0, 0)
    hideButton.BackgroundColor3 = Color3.new(0.7, 0.6, 0)
    hideButton.Parent = mainFrame

    -- Botón para mostrar el menú (el "logo" discreto)
    local showButton = Instance.new("TextButton")
    showButton.Size = UDim2.new(0, 50, 0, 50)
    showButton.Position = UDim2.new(0.5, -25, 0.5, -25)
    showButton.Text = "CH"
    showButton.Font = Enum.Font.SourceSansBold
    showButton.TextSize = 20
    showButton.TextColor3 = Color3.new(0, 0, 0)
    showButton.BackgroundColor3 = Color3.new(0.7, 0.6, 0)
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

    return screenGui
end

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    if lastMenuInstance then
        lastMenuInstance.Parent = LocalPlayer.PlayerGui
    else
        lastMenuInstance = createMenu()
        lastMenuInstance.Parent = LocalPlayer.PlayerGui
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Ejecutamos la función si el personaje ya existe
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
