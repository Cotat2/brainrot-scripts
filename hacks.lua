-- Script con menú estilo Hub para Delta (Versión Final 2.8 - Teleport a Base)

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
    navFrame.Size = UDim2.new(0, 1
