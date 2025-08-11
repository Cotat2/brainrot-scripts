-- Script con menú estilo Hub para Delta (Versión Final 3.0 - El Control Absoluto)

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
local superJumpEnabled = false
local noclipLoop = nil
local baseLocation = nil

-- Variables para la Invisibilidad Falsa
local ghostClone = nil

-- Valores por defecto
local defaultWalkSpeed = 16
local defaultJumpPower = 50

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
        humanoid.WalkSpeed = defaultWalkSpeed
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
        humanoid.WalkSpeed = defaultWalkSpeed
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

-- ** NUEVOS PODERES DE NUESTRA CONVERSACIÓN **

-- Súper Salto
local function toggleSuperJump(state)
    superJumpEnabled = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if state then
        humanoid.JumpPower = 150
    else
        humanoid.JumpPower = defaultJumpPower
    end
end

-- Congelar Jugador
local function freezePlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        targetPlayer.Character.Humanoid.WalkSpeed = 0
        targetPlayer.Character.Humanoid.JumpPower = 0
    end
end

-- Descongelar Jugador
local function unfreezePlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        targetPlayer.Character.Humanoid.WalkSpeed = defaultWalkSpeed
        targetPlayer.Character.Humanoid.JumpPower = defaultJumpPower
    end
end

-- Teleport a Coordenadas
local function teleportToCoords(x, y, z)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(x, y, z)
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

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = navFrame
    
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

    local function createTabButton(text)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 40)
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

    local adminTab = Instance.new("Frame")
    adminTab.Size = UDim2.new(1, 0, 1, 0)
    adminTab.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    adminTab.Parent = contentFrame
    adminTab.Visible = false

    local mainButton = createTabButton("  Main")
    local stealerButton = createTabButton("  Stealer")
    local helperButton = createTabButton("  Helper")
    local playerButton = createTabButton("  Player")
    local adminButton = createTabButton("  Admin")
    
    mainButton.MouseButton1Click:Connect(function() changeTab(mainTab) end)
    playerButton.MouseButton1Click:Connect(function() changeTab(playerTab) end)
    stealerButton.MouseButton1Click:Connect(function() changeTab(stealerTab) end)
    adminButton.MouseButton1Click:Connect(function() changeTab(adminTab) end)

    changeTab(mainTab)

    local function createSectionTitle(title, parent)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = title
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        label.Parent = parent
    end

    local function createToggleButton(text, parent, toggleFunc)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 40)
        button.Position = UDim2.new(0, 10, 0, 0)
        button.Text = text .. ": OFF"
        button.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        button.Parent = parent
        button.MouseButton1Click:Connect(function()
            local state = button.Text:find("OFF")
            if state then
                toggleFunc(true)
                button.Text = text .. ": ON"
            else
                toggleFunc(false)
                button.Text = text .. ": OFF"
            end
        end)
        return button
    end

    -- Player Tab
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.Padding = UDim.new(0, 5)
    playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayout.Parent = playerTab

    createToggleButton("Salto Múltiple", playerTab, toggleMultipleJump)
    createToggleButton("Wallhack (ESP)", playerTab, toggleWallhack)
    createToggleButton("Invisibilidad Falsa", playerTab, toggleFakeInvisibility)
    createToggleButton("Speed Hack", playerTab, toggleSpeedHack)
    createToggleButton("Super Salto", playerTab, toggleSuperJump)
    
    -- Stealer Tab
    local stealerLayout = Instance.new("UIListLayout")
    stealerLayout.Padding = UDim.new(0, 5)
    stealerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    stealerLayout.Parent = stealerTab

    createToggleButton("Noclip Avanzado", stealerTab, toggleAdvancedNoclip)

    local teleportToBaseButton = Instance.new("TextButton")
    teleportToBaseButton.Size = UDim2.new(1, -20, 0, 40)
    teleportToBaseButton.Position = UDim2.new(0, 10, 0, 0)
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
            teleportToBaseButton.Text = "Guardar Base"
            teleportToBaseButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        end
    end)
    
    local coordsInputTitle = createSectionTitle("Teleport a Coordenadas", stealerTab)
    local xInput = Instance.new("TextBox")
    xInput.PlaceholderText = "X"
    xInput.Size = UDim2.new(0.33, -10, 0, 30)
    xInput.Parent = stealerTab
    local yInput = Instance.new("TextBox")
    yInput.PlaceholderText = "Y"
    yInput.Size = UDim2.new(0.33, -10, 0, 30)
    yInput.Position = UDim2.new(0.33, 0, 0, 0)
    yInput.Parent = stealerTab
    local zInput = Instance.new("TextBox")
    zInput.PlaceholderText = "Z"
    zInput.Size = UDim2.new(0.33, -10, 0, 30)
    zInput.Position = UDim2.new(0.66, 0, 0, 0)
    zInput.Parent = stealerTab
    local teleportButton = createToggleButton("Teleportar", stealerTab, function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        if x and y and z then
            teleportToCoords(x, y, z)
        end
    end)
    
    -- Admin Tab
    local adminLayout = Instance.new("UIListLayout")
    adminLayout.Padding = UDim.new(0, 5)
    adminLayout.SortOrder = Enum.SortOrder.LayoutOrder
    adminLayout.Parent = adminTab
    
    local playerInputTitle = createSectionTitle("Control de Jugadores", adminTab)
    local targetInput = Instance.new("TextBox")
    targetInput.PlaceholderText = "Nombre del Jugador"
    targetInput.Size = UDim2.new(1, -20, 0, 30)
    targetInput.Position = UDim2.new(0, 10, 0, 0)
    targetInput.Parent = adminTab

    local freezeButton = Instance.new("TextButton")
    freezeButton.Size = UDim2.new(0.5, -15, 0, 40)
    freezeButton.Position = UDim2.new(0, 10, 0, 0)
    freezeButton.Text = "Congelar"
    freezeButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    freezeButton.Parent = adminTab
    freezeButton.MouseButton1Click:Connect(function()
        local targetName = targetInput.Text
        local targetPlayer = Players:FindFirstChild(targetName)
        freezePlayer(targetPlayer)
    end)
    
    local unfreezeButton = Instance.new("TextButton")
    unfreezeButton.Size = UDim2.new(0.5, -15, 0, 40)
    unfreezeButton.Position = UDim2.new(0.5, 5, 0, 0)
    unfreezeButton.Text = "Descongelar"
    unfreezeButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    unfreezeButton.Parent = adminTab
    unfreezeButton.MouseButton1Click:Connect(function()
        local targetName = targetInput.Text
        local targetPlayer = Players:FindFirstChild(targetName)
        unfreezePlayer(targetPlayer)
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

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
