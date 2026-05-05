-- REESCRITURA TOTAL: hacks.lua (100% FE COMPATIBLE)
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN DE PODER
local flingPower = 10000 -- Fuerza para mandar todo a volar
local activeAura = false
local activeT = false

-- 1. CREAR EL OBJETO FÍSICO (AURA L)
-- Creamos una pieza invisible unida a ti con densidad extrema
local AuraPart = Instance.new("Part")
AuraPart.Name = "AuraFisica"
AuraPart.Parent = Character
AuraPart.Size = Vector3.new(12, 12, 12)
AuraPart.Transparency = 1 -- Totalmente invisible
AuraPart.CanCollide = false
AuraPart.Massless = false

local Weld = Instance.new("Weld", AuraPart)
Weld.Part0 = Character:WaitForChild("HumanoidRootPart")
Weld.Part1 = AuraPart

-- 2. FUNCIÓN DE LA TECLA T (LANZAR MAPA ROTO)
-- Buscamos partes sueltas y les aplicamos un impulso masivo
local function launchObjects()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(Character) then
            if part.Anchored == false then
                local dist = (part.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < 70 then -- Radio de acción
                    part.Velocity = (part.Position - Character.HumanoidRootPart.Position).Unit * 150 + Vector3.new(0, 50, 0)
                    local force = Instance.new("BodyForce", part)
                    force.Force = Vector3.new(0, part:GetMass() * 196.2, 0) + (part.Position - Character.HumanoidRootPart.Position).Unit * flingPower
                    game:GetService("Debris"):AddItem(force, 0.2)
                end
            end
        end
    end
end

-- 3. DETECTAR TECLAS
UIS.InputBegan:Connect(function(input, chat)
    if chat then return end
    
    -- Tecla L: Aura de Choque
    if input.KeyCode == Enum.KeyCode.L then
        activeAura = not activeAura
        AuraPart.CanCollide = activeAura
        AuraPart.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 100, 100)
        print("Aura: " .. (activeAura and "ON" or "OFF"))
    end
    
    -- Tecla T: Lanzar Escombros
    if input.KeyCode == Enum.KeyCode.T then
        activeT = not activeT
        print("Modo Lanzar: " .. (activeT and "ON" or "OFF"))
    end
end)

-- Bucle de ejecución constante
RunService.Heartbeat:Connect(function()
    if activeT then
        launchObjects()
    end
    -- Anti-caída para el personaje cuando el aura está activa
    if activeAura then
        Character.Humanoid:ChangeState(11)
    end
end)

print("--- SCRIPT REPARADO CARGADO ---")
