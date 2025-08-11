-- Script con menú estilo Hub para Delta (Versión Final 2.8 - Teleport a Base)

-- Variables principales
Jugadores locales = juego:GetService("Jugadores")
local LocalPlayer = Jugadores.LocalPlayer
ServicioDeEntradaDeUsuario local = juego:ObtenerServicio("ServicioDeEntradaDeUsuario")
RunService local = juego:GetService("RunService")
últimaInstanciaDeMenú local = nula

-- Estado de las funciones
local multipleJumpEnabled = falso
wallhackEnabled local = falso
fakeInvisibilityEnabled local = falso
local speedHackEnabled = falso
local advancedNoclipEnabled = falso
teleportToBaseEnabled local = falso
noclipLoop local = nulo
ubicación base local = nula

-- Variables para la Invisibilidad Falsa
fantasma localClone = nulo

-- Función para manejar el Salto Múltiple
función local handleJump(humanoid)
    Si multipleJumpEnabled entonces
        Si humanoide y humanoide.Salud > 0 entonces
            humanoide:ChangeState(Enum.HumanoidStateType.Jumping)
        fin
    fin
fin

-- Función para activar o desactivar el Salto Múltiple
función local toggleMultipleJump(estado, humanoide)
    multipleJumpEnabled = estado
    Si el estado entonces
        UserInputService.InputBegan:Connect(función(entrada, evento procesado por el juego)
            si input.KeyCode == Enum.KeyCode.Space y no gameProcessedEvent entonces
                handleJump(humanoide)
            fin
        fin)
    fin
fin

-- Función para activar o desactivar el Wallhack (ESP)
función local toggleWallhack(estado)
    wallhackEnabled = estado
    Si el estado entonces
        para _, jugador en ipairs(Players:GetPlayers()) hacer
            si jugador ~= LocalPlayer y jugador.Character y jugador.Character:FindFirstChild("Humanoid") entonces
                cabeza local = jugador.Personaje:BuscarPrimerHijo("Cabeza")
                si cabeza y cabeza:FindFirstChild("PlayerESP") == nil entonces
                    cartelera localGui = Instancia.new("BillboardGui")
                    billboardGui.Name = "PlayerESP"
                    carteleraGui.Tamaño = UDim2.nuevo(0, 100, 0, 50)
                    carteleraGui.StudsOffset = Vector3.new(0, 3, 0)
                    billboardGui.AlwaysOnTop = verdadero

                    etiqueta de texto local = Instancia.new("Etiqueta de texto")
                    textLabel.Text = jugador.Nombre
                    etiquetaDeTexto.Tamaño = UDim2.nuevo(1, 0, 1, 0)
                    etiquetaDeTexto.Fuente = Enumeración.Fuente.FuenteSans
                    Etiqueta de texto.Tamaño del texto = 14
                    EtiquetaDeTexto.ColorDeTexto3 = Color3.nuevo(1, 0, 0)
                    Etiqueta de texto.Transparencia de fondo = 1
                    EtiquetaDeTexto.Padre = billboardGui

                    billboardGui.Parent = cabeza
                fin
            fin
        fin
    demás
        para _, jugador en ipairs(Players:GetPlayers()) hacer
            si jugador.Carácter y jugador.Carácter:BuscarPrimerHijo("Cabeza") entonces
                esp local = jugador.Personaje.Cabeza:BuscarPrimerHijo("JugadorESP")
                si esp entonces
                    esp:Destruir()
                fin
            fin
        fin
    fin
fin

-- Función para la Invisibilidad Falsa
función local toggleFakeInvisibility(estado)
    fakeInvisibilityEnabled = estado
    personaje local = LocalPlayer.Character o LocalPlayer.CharacterAdded:Wait()
    
    Si el estado entonces
        -- Creamos un clon visual del avatar
        ghostClone = personaje:Clone()
        ghostClone.Name = "GhostClone"
        ghostClone.Parent = espacio de trabajo
        
        --Hacemos el clon inamovible
        para _, parte en pares(ghostClone:GetChildren()) hacer
            si parte:IsA("BasePart") entonces
                parte.Anclado = verdadero
                parte.CanCollide = falso
            fin
        fin
        
        -- Hacemos que el avatar real sea invisible localmente
        para _, parte en pares(carácter:GetChildren()) hacer
            si parte:IsA("BasePart") entonces
                parte.ModificadorDeTransparenciaLocal = 1
            fin
        fin
    demás
        -- Eliminamos el clon y restauramos la visibilidad del avatar real.
        Si ghostClone entonces
            ghostClone:Destruir()
            ghostClone = nulo
        fin
        para _, parte en pares(carácter:GetChildren()) hacer
            si parte:IsA("BasePart") entonces
                parte.Modificador de Transparencia Local = 0
            fin
        fin
    fin
fin

-- Función para activar o desactivar el Speed Hack
función local toggleSpeedHack(estado)
    speedHackEnabled = estado
    personaje local = LocalPlayer.Character o LocalPlayer.CharacterAdded:Wait()
    humanoide local = personaje:WaitForChild("Humanoide")
    
    Si el estado entonces
        humanoide.WalkSpeed = 50
    demás
        humanoide.WalkSpeed = 16
    fin
fin

-- FUNCIÓN DE NOCLIP AVANZADO
función local toggleAdvancedNoclip(estado)
    advancedNoclipEnabled = estado

    personaje local = LocalPlayer.Character o LocalPlayer.CharacterAdded:Wait()
    ParteRaízHumanoide local = personaje:EsperaAlHijo("ParteRaízHumanoide")
    humanoide local = personaje:WaitForChild("Humanoide")
    cámara local = espacio de trabajo.CurrentCamera
    velocidad local = 1,5

    Si el estado entonces
        -- Desactiva la colisión localmente
        para _, parte en pares(carácter:GetChildren()) hacer
            si parte:IsA("BasePart") entonces
                parte.CanCollide = falso
            fin
        fin
        humanoide.WalkSpeed = 0

        noclipLoop = RunService.Heartbeat:Conectar(función()
            Si advancedNoclipEnabled entonces
                movimiento localVector = Vector3.new(0, 0, 0)
                si UserInputService:IsKeyDown(Enum.KeyCode.W) entonces
                    moverVector = moverVector + cámara.CFrame.LookVector
                fin
                si UserInputService:IsKeyDown(Enum.KeyCode.S) entonces
                    moveVector = moveVector - cámara.CFrame.LookVector
                fin
                si UserInputService:IsKeyDown(Enum.KeyCode.D) entonces
                    moverVector = moverVector + cámara.CFrame.RightVector
                fin
                si UserInputService:IsKeyDown(Enum.KeyCode.A) entonces
                    moveVector = moveVector - cámara.CFrame.RightVector
                fin

                si moveVector.Magnitude > 0 entonces
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveVector.Unit * velocidad
                fin
            fin
        fin)
    demás
        -- Restaura la colisión, la velocidad y desconecta el loop
        para _, parte en pares(carácter:GetChildren()) hacer
            si parte:IsA("BasePart") entonces
                parte.CanCollide = verdadero
            fin
        fin
        humanoide.WalkSpeed = 16
        Si noclipLoop entonces
            noclipLoop:Desconectar()
            noclipLoop = nulo
        fin
    fin
fin

-- FUNCIÓN NUEVA: Teletransportar una Base
función local toggleTeleportToBase(estado)
    teleportToBaseEnabled = estado

    personaje local = LocalPlayer.Character o LocalPlayer.CharacterAdded:Wait()
    ParteRaízHumanoide local = personaje:EsperaAlHijo("ParteRaízHumanoide")

    Si el estado entonces
        -- Guardar la posición actual
        baseLocation = humanoidRootPart.CFrame
        devolver "Base guardada."
    demás
        -- Teletransportar a la posición guardada
        Si baseLocation entonces
            humanoidRootPart.CFrame = ubicaciónBase
            return "Teletransporte a base realizado."
        demás
            return "No hay una base guardada."
        fin
    fin
fin


-- Función que se encarga de crear el menú y su lógica
función local createMenu()
    Interfaz gráfica del jugador local = Jugador local:EsperarAlHijo("Interfaz gráfica del jugador")
    si playerGui:FindFirstChild("HubMenu") entonces
        playerGui:FindFirstChild("Menú del concentrador"):Destroy()
    fin

    screenGui local = Instancia.new("ScreenGui")
    screenGui.Name = "Menú del concentrador"
    screenGui.Parent = playerGui
    
    marco principal local = Instancia.new("Marco")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    Marco principal.BorderSizePixel = 0
    mainFrame.Active = verdadero
    mainFrame.Draggable = verdadero
    Marco principal.Padre = screenGui

    navFrame local = Instancia.new("Marco")
    navFrame.Tamaño = UDim2.nuevo(0, 1
