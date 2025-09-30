-- Script con menú estilo Hub para Delta (Versión Final 2.9.2 - Inicialización Mejorada)

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local menuCreated = false -- Nueva variable para controlar la creación del menú

-- Estado de las funciones
local multipleJumpEnabled = false
local wallhackEnabled = false
local fakeInvisibilityEnabled = false
local speedHackEnabled = false 
local advancedNoclipEnabled = false
local teleportToBaseEnabled = false
local noclipLoop = nil
local baseLocation = nil

-- Variables para el Speed Hack
local currentWalkSpeed = 16 
local speedHackSlider = nil
local speedLabel = nil

-- Variables para la Invisibilidad Falsa
local ghostClone = nil

-- [MANTENEMOS LAS FUNCIONES toggleMultipleJump, toggleWallhack, toggleFakeInvisibility, setSpeedHackSpeed, toggleSpeedHack, toggleAdvancedNoclip, toggleTeleportToBase SIN CAMBIOS]
-- Para no duplicar el código, las funciones de las características (salto, speed, noclip, etc.) se mantienen como en la versión 2.9.1.
-- Solo se modifica la lógica de inicialización y el creador del menú.

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

-- Función para la Invisibilidad Falsa
local function toggleFakeInvisibility(state)
    fakeInvisibilityEnabled = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    if state then
        -- Creamos un clon visual del avatar
        ghostClone = character:Clone()
        ghostClone.Name = "GhostClone"
        ghostClone.Parent = workspace
        
        -- Hacemos el clon inamovible
        for _, part in pairs(ghostClone:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = true
                part.CanCollide = false
            end
        end
        
        -- Hacemos que el avatar real sea invisible localmente
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
            end
        end
    else
        -- Eliminamos el clon y restauramos la visibilidad del avatar real
        if ghostClone then
            ghostClone:Destroy()
            ghostClone = nil
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

-- Función para establecer la velocidad de caminata
local function setSpeedHackSpeed(speed)
    currentWalkSpeed = speed
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.WalkSpeed = currentWalkSpeed
    
    -- Actualizar el texto del slider
    if speedLabel then
        speedLabel.Text = "Velocidad: " .. math.floor(currentWalkSpeed)
    end
end

-- Función para activar o desactivar el Speed Hack (para el botón de reset)
local function toggleSpeedHack(state)
    speedHackEnabled = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if not state then
        -- Resetear a velocidad por defecto (16)
        setSpeedHackSpeed(16)
        if speedHackSlider then
            -- Mover el slider al valor por defecto para reflejar el estado
            speedHackSlider.Value = 16
        end
    else
        -- Si se activa, usar la velocidad actual del slider
        setSpeedHackSpeed(speedHackSlider.Value)
    end
end

-- FUNCIÓN DE NOCLIP AVANZADO
local function toggleAdvancedNoclip(state)
    advancedNoclipEnabled = state

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera
    local speed = 1.5 

    if state then
        -- Desactiva la colisión localmente
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        humanoid.WalkSpeed = 0 

        noclipLoop = RunService.Heartbeat:Connect(function()
            if advancedNoclipEnabled then
                local moveVector = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end

                if moveVector.Magnitude > 0 then
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveVector.Unit * speed
                end
            end
        end)
    else
        -- Restaura la colisión, la velocidad y desconecta el loop
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        humanoid.WalkSpeed = currentWalkSpeed -- Usar la velocidad personalizada actual
        if noclipLoop then
            noclipLoop:Disconnect()
            noclipLoop = nil
        end
    end
end

-- FUNCIÓN NUEVA: Teleport a Base
local function toggleTeleportToBase(state)
    teleportToBaseEnabled = state

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if state then
        -- Guardar la posición actual
        baseLocation = humanoidRootPart.CFrame
        return "Base guardada."
    else
        -- Teletransportar a la posición guardada
        if baseLocation then
            humanoidRootPart.CFrame = baseLocation
            return "Teletransporte a base realizado."
        else
            return "No hay una base guardada."
        end
    end
end


-- Función que se encarga de crear el menú y su lógica
local function createMenu()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Limpiar versiones anteriores
    if playerGui:FindFirstChild("HubMenu") then
        playerGui:FindFirstChild("HubMenu"):Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HubMenu"
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

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

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -150, 1, -40)
    contentFrame.Position = UDim2.new(0, 150, 0, 40)
    contentFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    contentFrame.Parent = mainFrame

    local currentTab
    local function changeTab(tabFrame)
        if currentTab then
            currentTab.Visible = false
        end
        currentTab = tabFrame
        currentTab.Visible = true
    end

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

    local stealerTab = Instance.new("Frame")
    stealerTab.Size = UDim2.new(1, 0, 1, 0)
    stealerTab.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    stealerTab.Parent = contentFrame
    stealerTab.Visible = false

    mainButton.MouseButton1Click:Connect(function() changeTab(mainTab) end)
    playerButton.MouseButton1Click:Connect(function() changeTab(playerTab) end)
    stealerButton.MouseButton1Click:Connect(function() changeTab(stealerTab) end)

    changeTab(mainTab)

    -- Player Tab (Contiene Salto, Wallhack, Invisibilidad, Speed, Noclip y TP)
    local yPosition = 20

    local multipleJumpButton = Instance.new("TextButton")
    multipleJumpButton.Size = UDim2.new(0, 180, 0, 40)
    multipleJumpButton.Position = UDim2.new(0, 20, 0, yPosition)
    multipleJumpButton.Text = "Salto Múltiple: OFF"
    multipleJumpButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    multipleJumpButton.Parent = playerTab
    multipleJumpButton.MouseButton1Click:Connect(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        toggleMultipleJump(not multipleJumpEnabled, humanoid)
        multipleJumpButton.Text = "Salto Múltiple: " .. (multipleJumpEnabled and "ON" or "OFF")
    end)
    yPosition = yPosition + 60

    local wallhackButton = Instance.new("TextButton")
    wallhackButton.Size = UDim2.new(0, 180, 0, 40)
    wallhackButton.Position = UDim2.new(0, 20, 0, yPosition)
    wallhackButton.Text = "Wallhack (ESP): OFF"
    wallhackButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    wallhackButton.Parent = playerTab
    wallhackButton.MouseButton1Click:Connect(function()
        toggleWallhack(not wallhackEnabled)
        wallhackButton.Text = "Wallhack (ESP): " .. (wallhackEnabled and "ON" or "OFF")
    end)
    yPosition = yPosition + 60

    local ghostModeButton = Instance.new("TextButton")
    ghostModeButton.Size = UDim2.new(0, 180, 0, 40)
    ghostModeButton.Position = UDim2.new(0, 20, 0, yPosition)
    ghostModeButton.Text = "Invisibilidad Falsa: OFF"
    ghostModeButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    ghostModeButton.Parent = playerTab
    ghostModeButton.MouseButton1Click:Connect(function()
        toggleFakeInvisibility(not fakeInvisibilityEnabled)
        ghostModeButton.Text = "Invisibilidad Falsa: " .. (fakeInvisibilityEnabled and "ON" or "OFF")
    end)
    yPosition = yPosition + 60
    
    -- Speed Hack Slider
    speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 180, 0, 20)
    speedLabel.Position = UDim2.new(0, 20, 0, yPosition)
    speedLabel.Text = "Velocidad: 16"
    speedLabel.Font = Enum.Font.SourceSansBold
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Parent = playerTab
    yPosition = yPosition + 25

    speedHackSlider = Instance.new("Slider")
    speedHackSlider.Size = UDim2.new(0, 180, 0, 20)
    speedHackSlider.Position = UDim2.new(0, 20, 0, yPosition)
    speedHackSlider.Parent = playerTab
    
    speedHackSlider.Minimum = 1 
    speedHackSlider.Maximum = 1000
    speedHackSlider.Value = currentWalkSpeed -- Usar el valor actual

    -- LÓGICA CORREGIDA DEL SLIDER
    speedHackSlider:GetPropertyChangedSignal("Value"):Connect(function()
        local newSpeed = math.floor(speedHackSlider.Value)
        setSpeedHackSpeed(newSpeed)
    end)
    yPosition = yPosition + 25

    local speedResetButton = Instance.new("TextButton")
    speedResetButton.Size = UDim2.new(0, 180, 0, 20)
    speedResetButton.Position = UDim2.new(0, 20, 0, yPosition)
    speedResetButton.Text = "Resetear Velocidad (16)"
    speedResetButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    speedResetButton.Parent = playerTab
    speedResetButton.MouseButton1Click:Connect(function()
        toggleSpeedHack(false) 
    end)
    yPosition = yPosition + 40
    
    -- Noclip
    local advancedNoclipButton = Instance.new("TextButton")
    advancedNoclipButton.Size = UDim2.new(0, 180, 0, 40)
    advancedNoclipButton.Position = UDim2.new(0, 20, 0, yPosition)
    advancedNoclipButton.Text = "Noclip Avanzado: OFF"
    advancedNoclipButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    advancedNoclipButton.Parent = playerTab
    advancedNoclipButton.MouseButton1Click:Connect(function()
        toggleAdvancedNoclip(not advancedNoclipEnabled)
        advancedNoclipButton.Text = "Noclip Avanzado: " .. (advancedNoclipEnabled and "ON" or "OFF")
    end)
    yPosition = yPosition + 60

    -- Teleport a Base
    local teleportToBaseButton = Instance.new("TextButton")
    teleportToBaseButton.Size = UDim2.new(0, 180, 0, 40)
    teleportToBaseButton.Position = UDim2.new(0, 20, 0, yPosition)
    teleportToBaseButton.Text = "Guardar Base"
    teleportToBaseButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    teleportToBaseButton.Parent = playerTab
    teleportToBaseButton.MouseButton1Click:Connect(function()
        if baseLocation == nil then
            toggleTeleportToBase(true)
            teleportToBaseButton.Text = "Teleport a Base"
            teleportToBaseButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        else
            toggleTeleportToBase(false)
            teleportToBaseButton.Text = "Guardar Base"
            teleportToBaseButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        end
    end)
    
    -- Control de Minimizar/Mostrar
    local hideButton = Instance.new("TextButton")
    hideButton.Size = UDim2.new(0, 20, 0, 20)
    hideButton.Position = UDim2.new(1, -25, 0, 5)
    hideButton.Text = "-"
    hideButton.Font = Enum.Font.SourceSansBold
    hideButton.TextSize = 20
    hideButton.TextColor3 = Color3.new(1, 1, 1)
    hideButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    hideButton.Parent = mainFrame

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

    hideButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        showButton.Visible = true
    end)

    showButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        showButton.Visible = false
    end)

    local mouse = LocalPlayer:GetMouse()
    mouse.Icon = ""
end

-- *** LÓGICA DE INICIALIZACIÓN REVISADA Y SIMPLIFICADA ***
-- Creamos un solo hilo para esperar todo y crear el menú una vez.
if not menuCreated then
    -- 1. Esperar al PlayerGui (donde se cargan las interfaces)
    LocalPlayer:WaitForChild("PlayerGui")

    -- 2. Esperar al personaje inicial para configurar la velocidad y otros aspectos.
    -- Esto garantiza que el Humanoid existe cuando se usa setSpeedHackSpeed.
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end

    -- 3. Crear el menú
    createMenu()
    menuCreated = true
end
