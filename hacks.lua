-- Script con menú estilo Hub para Delta (Versión Corregida 2.3 - No Daño de Caída)

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
local noclipEnabled = false
local noFallDamageEnabled = false
local noFallDamageConnection = nil

-- Variables para la Invisibilidad Falsa
local ghostClone = nil

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

-- Función para activar o desactivar el Noclip
local function toggleNoclip(state)
    noclipEnabled = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    if state then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- FUNCIÓN CORREGIDA PARA EL DAÑO DE CAÍDA
local function toggleNoFallDamage(state)
    noFallDamageEnabled = state
    
    if noFallDamageConnection then
        noFallDamageConnection:Disconnect()
        noFallDamageConnection = nil
    end

    if state then
        local function onCharacterAdded(character)
            local humanoid = character:WaitForChild("Humanoid")
            noFallDamageConnection = humanoid.Landed:Connect(function()
                humanoid:TakeDamage(0)
            end)
        end
        
        LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
        if LocalPlayer.Character then
            onCharacterAdded(LocalPlayer.Character)
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
    
    -- Stealer Tab
    local noclipButton = Instance.new("TextButton")
    noclipButton.Size = UDim2.new(0, 180, 0, 40)
    noclipButton.Position = UDim2.new(0, 20, 0, 20)
    noclipButton.Text = "Noclip: OFF"
    noclipButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    noclipButton.Parent = stealerTab
    noclipButton.MouseButton1Click:Connect(function()
        toggleNoclip(not noclipEnabled)
        noclipButton.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
    end)

    local noFallDamageButton = Instance.new("TextButton")
    noFallDamageButton.Size = UDim2.new(0, 180, 0, 40)
    noFallDamageButton.Position = UDim2.new(0, 20, 0, 80)
    noFallDamageButton.Text = "No Daño de Caída: OFF"
    noFallDamageButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    noFallDamageButton.Parent = stealerTab
    noFallDamageButton.MouseButton1Click:Connect(function()
        toggleNoFallDamage(not noFallDamageEnabled)
        noFallDamageButton.Text = "No Daño de Caída: " .. (noFallDamageEnabled and "ON" or "OFF")
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
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
