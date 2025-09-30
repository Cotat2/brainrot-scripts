-- Script con menú estilo Hub para Delta (Versión Final 2.8 - Teleport a Base)
-- AÑADIDA: Funcionalidad de Jump Boost ajustable.

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lastMenuInstance = nil

-- Estado de las funciones
local multipleJumpEnabled = false
local wallhackEnabled = false
local fakeInvisibilityEnabled = false
local speedHackEnabled = false
local advancedNoclipEnabled = false
local teleportToBaseEnabled = false
local noclipLoop = nil
local baseLocation = nil

-- Variables para la Invisibilidad Falsa
local ghostClone = nil

-- NUEVAS VARIABLES PARA JUMP BOOST
local jumpBoostEnabled = false
local jumpHeight = 50 -- Altura de salto inicial

-- NUEVA: Función para manejar el Jump Boost
local function activateJumpBoost(newJumpHeight)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = newJumpHeight
    end
end

local function deactivateJumpBoost()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = 50 -- Valor por defecto
    end
end

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

-- Función para activar o desactivar el Speed Hack
local function toggleSpeedHack(state)
    speedHackEnabled = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if state then
        humanoid.WalkSpeed = 50
    else
        humanoid.WalkSpeed = 16
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
        humanoid.WalkSpeed = 16
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

    -- Player Tab
    local multipleJumpButton = Instance.new("TextButton")
    multipleJumpButton.Size = UDim2.new(0, 180, 0, 40)
    multipleJumpButton.Position = UDim2.new(0, 20, 0, 20)
    multipleJumpButton.Text = "Salto Múltiple: OFF"
    multipleJumpButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
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
    wallhackButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    wallhackButton.Parent = playerTab
    wallhackButton.MouseButton1Click:Connect(function()
        toggleWallhack(not wallhackEnabled)
        wallhackButton.Text = "Wallhack (ESP): " .. (wallhackEnabled and "ON" or "OFF")
    end)

    local ghostModeButton = Instance.new("TextButton")
    ghostModeButton.Size = UDim2.new(0, 180, 0, 40)
    ghostModeButton.Position = UDim2.new(0, 20, 0, 140)
    ghostModeButton.Text = "Invisibilidad Falsa: OFF"
    ghostModeButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    ghostModeButton.Parent = playerTab
    ghostModeButton.MouseButton1Click:Connect(function()
        toggleFakeInvisibility(not fakeInvisibilityEnabled)
        ghostModeButton.Text = "Invisibilidad Falsa: " .. (fakeInvisibilityEnabled and "ON" or "OFF")
    end)
    
    local speedHackButton = Instance.new("TextButton")
    speedHackButton.Size = UDim2.new(0, 180, 0, 40)
    speedHackButton.Position = UDim2.new(0, 20, 0, 200)
    speedHackButton.Text = "Speed Hack: OFF"
    speedHackButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    speedHackButton.Parent = playerTab
    speedHackButton.MouseButton1Click:Connect(function()
        toggleSpeedHack(not speedHackEnabled)
        speedHackButton.Text = "Speed Hack: " .. (speedHackEnabled and "ON" or "OFF")
    end)

    -- AÑADIDA: Jump Boost con Slider
    local jumpBoostButton = Instance.new("TextButton")
    jumpBoostButton.Size = UDim2.new(0, 180, 0, 40)
    jumpBoostButton.Position = UDim2.new(0, 20, 0, 260)
    jumpBoostButton.Text = "Jump Boost: OFF"
    jumpBoostButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    jumpBoostButton.Parent = playerTab
    jumpBoostButton.MouseButton1Click:Connect(function()
        jumpBoostEnabled = not jumpBoostEnabled
        jumpBoostButton.Text = "Jump Boost: " .. (jumpBoostEnabled and "ON" or "OFF")
        if jumpBoostEnabled then
            activateJumpBoost(jumpHeight)
        else
            deactivateJumpBoost()
        end
    end)

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 180, 0, 20)
    sliderFrame.Position = UDim2.new(0, 20, 0, 310)
    sliderFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    sliderFrame.Parent = playerTab

    local sliderButton = Instance.new("Frame")
    sliderButton.Size = UDim2.new(0, 20, 1, 0)
    sliderButton.Position = UDim2.new(0, 0, 0, 0)
    sliderButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    sliderButton.Parent = sliderFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 1, 0)
    sliderLabel.Text = "Altura: " .. jumpHeight
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.TextSize = 14
    sliderLabel.TextColor3 = Color3.new(1, 1, 1)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Parent = sliderFrame

    local dragging = false
    local function updateSlider(input)
        local x = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
        local newPosition = x / sliderFrame.AbsoluteSize.X
        sliderButton.Position = UDim2.new(newPosition, 0, 0, 0)
        
        jumpHeight = math.floor(50 + newPosition * 250) -- Rango de 50 a 300
        sliderLabel.Text = "Altura: " .. jumpHeight
        
        if jumpBoostEnabled then
            activateJumpBoost(jumpHeight)
        end
    end
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateSlider(input)
        end
    end)


    -- Stealer Tab
    local advancedNoclipButton = Instance.new("TextButton")
    advancedNoclipButton.Size = UDim2.new(0, 180, 0, 40)
    advancedNoclipButton.Position = UDim2.new(0, 20, 0, 20)
    advancedNoclipButton.Text = "Noclip Avanzado: OFF"
    advancedNoclipButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    advancedNoclipButton.Parent = stealerTab
    advancedNoclipButton.MouseButton1Click:Connect(function()
        toggleAdvancedNoclip(not advancedNoclipEnabled)
        advancedNoclipButton.Text = "Noclip Avanzado: " .. (advancedNoclipEnabled and "ON" or "OFF")
    end)

    local teleportToBaseButton = Instance.new("TextButton")
    teleportToBaseButton.Size = UDim2.new(0, 180, 0, 40)
    teleportToBaseButton.Position = UDim2.new(0, 20, 0, 80)
    teleportToBaseButton.Text = "Guardar Base"
    teleportToBaseButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    teleportToBaseButton.Parent = stealerTab
    teleportToBaseButton.MouseButton1Click:Connect(function()
        if baseLocation == nil then
            toggleTeleportToBase(true)
            teleportToBaseButton.Text = "Teleport a Base"
            teleportToBaseButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        else
            toggleTeleportToBase(false)
        end
    end)

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
    -- Restaurar el estado del jump boost si estaba activado
    if jumpBoostEnabled then
        activateJumpBoost(jumpHeight)
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
