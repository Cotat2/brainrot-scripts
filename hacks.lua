-- Script con menú estilo Hub para Delta (Versión Final 2.9 - Vacío)

-- Variables principales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lastMenuInstance = nil

-- Estado de las funciones
-- (Todas las funciones están deshabilitadas)
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

-- Funciones completamente vacías
local function handleJump(humanoid) end
local function toggleMultipleJump(state, humanoid) end
local function toggleWallhack(state) end
local function toggleFakeInvisibility(state) end
local function toggleSpeedHack(state) end
local function toggleAdvancedNoclip(state) end
local function toggleTeleportToBase(state) end

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

    -- Player Tab (Vacío)
    -- Stealer Tab (Vacío)

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
