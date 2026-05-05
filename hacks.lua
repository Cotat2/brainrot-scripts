local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local p = game.Players.LocalPlayer

-- Variables de estado
local flyActivo = false
local flingActivo = false
local objetoFlingActivo = false
local conexionFly
local conexionFling
local conexionObjetos

-- === FUNCIÓN DROPKICK (Q) ===
local function ejecutarDropkick()
    local char = p.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    
    local hum = char.Humanoid
    local pie = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
    if not pie then return end

    -- 1. Reproducir Animación
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://2406323247"
    local loadAnim = hum:LoadAnimation(anim)
    loadAnim:Play()

    -- 2. Crear Hitbox Invisible
    local hitbox = Instance.new("Part")
    hitbox.Name = "DropkickHitbox"
    hitbox.Size = Vector3.new(6, 6, 6)
    hitbox.Transparency = 1
    hitbox.CanCollide = true
    hitbox.Massless = false
    -- Densidad máxima para impacto total
    hitbox.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
    hitbox.Parent = char

    local weld = Instance.new("Weld")
    weld.Part0 = pie
    weld.Part1 = hitbox
    weld.C0 = CFrame.new(0, -1, 0)
    weld.Parent = hitbox

    -- 3. Lógica de Impacto (.Touched)
    local haGolpeado = false
    hitbox.Touched:Connect(function(hit)
        if haGolpeado or hit:IsDescendantOf(char) then return end
        
        local rootHit = hit.Parent:FindFirstChild("HumanoidRootPart") or hit
        if rootHit then
            haGolpeado = true
            local direccion = workspace.CurrentCamera.CFrame.LookVector
            
            -- Aplicar fuerza masiva basada en la cámara
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = (direccion * 200) + Vector3.new(0, 50, 0) -- Empuje frontal y hacia arriba
            bv.Parent = rootHit
            
            game:GetService("Debris"):AddItem(bv, 0.5) -- La fuerza dura medio segundo
        end
    end)

    -- Limpieza de la hitbox tras la patada
    game:GetService("Debris"):AddItem(hitbox, 0.8)
end

-- === FUNCIONES ANTERIORES (F, L, T, Y) ===

local function cargarInfiniteYield()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
end

local function activarObjetoFling()
    if conexionObjetos then conexionObjetos:Disconnect() end
    conexionObjetos = RunService.Heartbeat:Connect(function()
        if not objetoFlingActivo then return end
        local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local partes = workspace:GetPartBoundsInRadius(root.Position, 500)
        for _, obj in pairs(partes) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") and not obj.Anchored then
                obj.AngularVelocity = Vector3.new(0, 99999, 0)
                obj.Velocity = obj.Velocity + Vector3.new(0, 5, 0)
            end
        end
    end)
end

local function activarFling()
    local c = p.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local root = c.HumanoidRootPart
    
    local reach = Instance.new("Part", c)
    reach.Name = "FlingReach"; reach.Size = Vector3.new(45, 2, 45); reach.Transparency = 1
    reach.CanCollide = true; reach.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
    
    local weld = Instance.new("Weld", reach)
    weld.Part0 = root; weld.Part1 = reach

    local bgv = Instance.new("BodyAngularVelocity", root)
    bgv.Name = "FlingForce"; bgv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bgv.AngularVelocity = Vector3.new(0, 999999, 0) 

    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "FlingAnchor"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0, 0, 0)

    conexionFling = RunService.Stepped:Connect(function()
        c.Humanoid.PlatformStand = true
        for _, part in pairs(c:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "FlingReach" then part.CanCollide = false end
        end
    end)
end

local function limpiarFling()
    if p.Character then
        for _, v in pairs(p.Character:GetDescendants()) do
            if v.Name == "FlingForce" or v.Name == "FlingAnchor" or v.Name == "FlingReach" then v:Destroy() end
        end
    end
    if conexionFling then conexionFling:Disconnect() end
end

local function activarFly()
    local c = p.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local root = c.HumanoidRootPart
    local bvFly = Instance.new("BodyVelocity", root); bvFly.Name = "AdminFly"; bvFly.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    local bgFly = Instance.new("BodyGyro", root); bgFly.Name = "AdminGyro"; bgFly.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    conexionFly = RunService.RenderStepped:Connect(function()
        if not flyActivo then return end
        local cam = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
        bvFly.Velocity = moveDir * 50; bgFly.CFrame = cam
    end)
end

-- === DETECTOR DE TECLAS ===
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then -- DROPKICK
        ejecutarDropkick()
    elseif input.KeyCode == Enum.KeyCode.F then -- FLY
        flyActivo = not flyActivo
        if flyActivo then activarFly() else 
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if p.Character.HumanoidRootPart:FindFirstChild("AdminFly") then p.Character.HumanoidRootPart.AdminFly:Destroy() end
                if p.Character.HumanoidRootPart:FindFirstChild("AdminGyro") then p.Character.HumanoidRootPart.AdminGyro:Destroy() end
            end
            if conexionFly then conexionFly:Disconnect() end
        end
    elseif input.KeyCode == Enum.KeyCode.L then -- FLING
        flingActivo = not flingActivo
        if flingActivo then activarFling() else limpiarFling() end
    elseif input.KeyCode == Enum.KeyCode.T then -- OBJ FLING
        objetoFlingActivo = not objetoFlingActivo
        if objetoFlingActivo then activarObjetoFling() end
    elseif input.KeyCode == Enum.KeyCode.Y then -- ADMIN
        cargarInfiniteYield()
    end
end)
