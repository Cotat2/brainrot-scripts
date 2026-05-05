-- FE Ultra Fling & Object Mover (Versión Corregida)
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

-- Configuración de Poder
local FlingPower = 5000 -- Poder para lanzar objetos
local AuraActive = false
local ObjectFlingActive = false

-- 1. SOLUCIÓN TECLA T (Object Fling Mejorado)
-- En lugar de rotar, aplica fuerza de empuje directa
Mouse.KeyDown:connect(function(key)
    if key:lower() == "t" then
        ObjectFlingActive = not ObjectFlingActive
        if ObjectFlingActive then
            print("Object Fling: ACTIVADO (Buscando piezas sueltas...)")
            -- Bucle de fuerza
            while ObjectFlingActive do
                for _, part in pairs(game.Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part:IsDescendantOf(Character) then
                        -- Solo afecta a partes que NO estén ancladas y estén cerca (100 studs)
                        if part.Anchored == false and (part.Position - Character.HumanoidRootPart.Position).Magnitude < 100 then
                            part.Velocity = Vector3.new(0, FlingPower/10, 0) -- Un pequeño salto
                            local thrust = Instance.new("BodyThrust", part)
                            thrust.Force = Vector3.new(FlingPower, FlingPower, FlingPower)
                            thrust.Location = part.Position
                            game:GetService("Debris"):AddItem(thrust, 0.1) -- Desaparece rápido para no laggear
                        end
                    end
                end
                task.wait(0.1)
            end
        else
            print("Object Fling: DESACTIVADO")
        end
    end
end)

-- 2. SOLUCIÓN TECLA L (Aura de Colisión FE)
-- Creamos una pieza invisible con densidad máxima
local FlingPart = Instance.new("Part", Character)
FlingPart.Name = "FE_Aura"
FlingPart.Transparency = 1
FlingPart.CanCollide = false -- La activamos por código
FlingPart.Size = Vector3.new(15, 15, 15)
local Weld = Instance.new("Weld", FlingPart)
Weld.Part0 = Character.HumanoidRootPart
Weld.Part1 = FlingPart

local CustomPhys = PhysicalProperties.new(100, 0.3, 0.5, 100, 100) -- DENSIDAD AL MÁXIMO

Mouse.KeyDown:connect(function(key)
    if key:lower() == "l" then
        AuraActive = not AuraActive
        if AuraActive then
            FlingPart.CanCollide = true
            FlingPart.CustomPhysicalProperties = CustomPhys
            print("Aura Física: ACTIVADA")
        else
            FlingPart.CanCollide = false
            print("Aura Física: DESACTIVADA")
        end
    end
end)

-- 3. Vuelo (Tecla F) y Dropkick (Tecla Q) se mantienen por ser 100% FE
-- [Aquí iría el resto de tu código base de vuelo y animación]

print("Script Cargado: T para Objetos (FE), L para Aura Pesada.")
