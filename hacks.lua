-- SCRIPT REPARADO Y SIMPLIFICADO (100% FE)
print("Iniciando carga del script...")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")

-- Variables de estado
local auraActiva = false
local lanzadorObjetos = false
local fuerza = 8000 -- Aumentado para que se note el impacto

-- 1. CREACIÓN DEL AURA FÍSICA (Tecla L)
local Aura = Instance.new("Part")
Aura.Name = "AuraPesada"
Aura.Parent = Character
Aura.Size = Vector3.new(12, 12, 12)
Aura.Transparency = 0.8 -- Un poco visible para que sepas que está ahí (puedes poner 1 luego)
Aura.Color = Color3.fromRGB(255, 255, 0)
Aura.CanCollide = false
Aura.CanTouch = true

local Weld = Instance.new("Weld", Aura)
Weld.Part0 = Character:WaitForChild("HumanoidRootPart")
Weld.Part1 = Aura

-- Propiedad física extrema para mover cosas
local PropiedadFisica = PhysicalProperties.new(100, 0.3, 0.5, 100, 100)

-- 2. DETECCIÓN DE TECLAS (REPARADA)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- No se activa si escribes en el chat

    -- TECLA L: Activar/Desactivar Aura
    if input.KeyCode == Enum.KeyCode.L then
        auraActiva = not auraActiva
        Aura.CanCollide = auraActiva
        if auraActiva then
            Aura.CustomPhysicalProperties = PropiedadFisica
            print("AURA: ACTIVADA (Modo bola de demolición)")
        else
            print("AURA: DESACTIVADA")
        end
    end

    -- TECLA T: Lanzar objetos cercanos
    if input.KeyCode == Enum.KeyCode.T then
        lanzadorObjetos = not lanzadorObjetos
        print("LANZADOR: " .. (lanzadorObjetos and "ACTIVADO" or "DESACTIVADO"))
        
        task.spawn(function()
            while lanzadorObjetos do
                for _, pieza in pairs(workspace:GetDescendants()) do
                    if pieza:IsA("BasePart") and not pieza:IsDescendantOf(Character) then
                        -- Solo piezas sueltas y cerca tuyo
                        if pieza.Anchored == false and (pieza.Position - Character.HumanoidRootPart.Position).Magnitude < 80 then
                            -- Empujón violento
                            pieza.Velocity = Vector3.new(0, 50, 0) + (pieza.Position - Character.HumanoidRootPart.Position).Unit * fuerza
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end)

print("¡SCRIPT CARGADO EXITOSAMENTE!")
print("Usa L para el escudo físico y T para lanzar escombros.")
