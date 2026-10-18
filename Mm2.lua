-- M2 Auto Farm v5 (Candy Collector)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

-- CONFIGURAÇÕES
local CONFIG = {
    ClickSpeed = 0.15, -- Aumente para 0.2 se estiver lento
    Jitter = 0.05,
    -- Nomes que o script deve procurar nos objetos
    TargetKeywords = {"candy", "resource", "node", "farm", "ore", "crystal", "gold", "silver", "copper", "iron", "coal"},
    -- Distância máxima para farmar
    MaxDistance = 50,
    -- Posição de farme (opcional)
    FarmPosition = nil, -- Ex: Vector3.new(100, 50, 200)
}

local State = {
    IsFarming = true,
    CurrentRemote = nil,
}

-- UI
local function CreateUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M2FarmUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 300, 0, 180)
    Main.Position = UDim2.new(1, -320, 0, 50)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "M2 Candy Farm"
    Title.TextColor3 = Color3.fromRGB(0, 255, 128)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -20, 0, 20)
    Status.Position = UDim2.new(0.05, 0, 0.25, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Status: Procurando alvo..."
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextScaled = true
    Status.Font = Enum.Font.Gotham
    Status.Parent = Main

    local BtnToggle = Instance.new("TextButton")
    BtnToggle.Name = "BtnToggle"
    BtnToggle.Size = UDim2.new(0.45, 0, 0, 40)
    BtnToggle.Position = UDim2.new(0.05, 0, 0.5, 0)
    BtnToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    BtnToggle.Text = "Pausar Farm"
    BtnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnToggle.TextScaled = true
    BtnToggle.Font = Enum.Font.GothamMedium
    BtnToggle.Parent = Main

    local BtnToggleCorner = Instance.new("UICorner")
    BtnToggleCorner.CornerRadius = UDim.new(0, 8)
    BtnToggleCorner.Parent = BtnToggle

    local BtnTele = Instance.new("TextButton")
    BtnTele.Name = "BtnTele"
    BtnTele.Size = UDim2.new(0.45, 0, 0, 40)
    BtnTele.Position = UDim2.new(0.5, 5, 0.5, 0)
    BtnTele.BackgroundColor3 = Color3.fromRGB(60, 90, 150)
    BtnTele.Text = "Ir pro Farme"
    BtnTele.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnTele.TextScaled = true
    BtnTele.Font = Enum.Font.GothamMedium
    BtnTele.Parent = Main

    local BtnTeleCorner = Instance.new("UICorner")
    BtnTeleCorner.CornerRadius = UDim.new(0, 8)
    BtnTeleCorner.Parent = BtnTele

    local BtnExit = Instance.new("TextButton")
    BtnExit.Name = "BtnExit"
    BtnExit.Size = UDim2.new(1, -20, 0, 30)
    BtnExit.Position = UDim2.new(0.05, 0, 0.85, 0)
    BtnExit.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    BtnExit.Text = "Sair do Script"
    BtnExit.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnExit.TextScaled = true
    BtnExit.Font = Enum.Font.GothamMedium
    BtnExit.Parent = Main

    local BtnExitCorner = Instance.new("UICorner")
    BtnExitCorner.CornerRadius = UDim.new(0, 8)
    BtnExitCorner.Parent = BtnExit

    -- Eventos dos Botões
    BtnToggle.MouseButton1Click:Connect(function()
        State.IsFarming = not State.IsFarming
        if State.IsFarming then
            BtnToggle.Text = "Pausar Farm"
            BtnToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
            Status.Text = "Status: Ativo"
        else
            BtnToggle.Text = "Iniciar Farm"
            BtnToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            Status.Text = "Status: Pausado"
        end
    end)

    BtnTele.MouseButton1Click:Connect(function()
        if CONFIG.FarmPosition then
            RootPart.CFrame = CFrame.new(CONFIG.FarmPosition)
            Status.Text = "Status: Teleportado"
        else
            Status.Text = "Status: Defina FarmPosition"
        end
    end)

    BtnExit.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        State.IsFarming = false
        print("[M2 Farm] Script desligado.")
    end)
end

-- Função de Clique
local function ClickAtScreen(pos2D)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos2D.X, pos2D.Y, 0, true)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(pos2D.X, pos2D.Y, 0, false)
    end)
end

-- Função de Aimbot
local function AimAtPart(part)
    local targetPos = part.Position
    local cameraPos = Camera.CFrame.Position
    local lookAt = CFrame.lookAt(cameraPos, targetPos)
    Camera.CFrame = CFrame.new(cameraPos) * lookAt
end

-- Função de Encontrar Alvo
local function FindTarget()
    local closestPart = nil
    local closestDist = math.huge

    for _, part in Workspace:GetDescendants() do
        if part:IsA("BasePart") and part ~= RootPart then
            local lowerName = part.Name:lower()
            local match = false
            for _, keyword in CONFIG.TargetKeywords do
                if lowerName:find(keyword) then
                    match = true
                    break
                end
            end

            if match then
                local dist = (RootPart.Position - part.Position).Magnitude
                if dist < closestDist and dist < CONFIG.MaxDistance then
                    closestDist = dist
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end

-- Função de Disparar Remote
local function FireRemote(part)
    if not State.CurrentRemote then
        -- Procura por remotes comuns
        for _, obj in Workspace:GetDescendants() do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local lowerName = obj.Name:lower()
                if lowerName:find("collect") or lowerName:find("farm") or lowerName:find("interact") or lowerName:find("mine") then
                    State.CurrentRemote = obj
                    print("[M2 Farm] Remote encontrado: " .. obj.Name)
                    break
                end
            end
        end
    end

    if State.CurrentRemote then
        pcall(function()
            if State.CurrentRemote:IsA("RemoteEvent") then
                State.CurrentRemote:FireServer(part, part.Name)
            elseif State.CurrentRemote:IsA("RemoteFunction") then
                State.CurrentRemote:InvokeServer(part, part.Name)
            end
        end)
    end
end

-- Loop Principal
local function StartFarm()
    CreateUI()
    print("[M2 Farm] Iniciado.")

    task.spawn(function()
        while true do
            if not State.IsFarming then
                task.wait(0.5)
                continue
            end

            -- Verifica Personagem
            if not LocalPlayer.Character or not RootPart then
                Character = LocalPlayer.Character
                RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                if not RootPart then
                    task.wait(1)
                    continue
                end
            end

            -- Teleporte (se configurado)
            if CONFIG.FarmPosition and (RootPart.Position - CONFIG.FarmPosition).Magnitude > 50 then
                RootPart.CFrame = CFrame.new(CONFIG.FarmPosition)
                task.wait(0.5)
            end

            -- Encontra o alvo
            local target = FindTarget()

            if target then
                -- Mira no alvo
                AimAtPart(target)
                
                -- Dispara Remote (se existir)
                FireRemote(target)

                -- Clica na posição exata do alvo na tela
                local viewportPoint = Camera:WorldToViewportPoint(target.Position)
                if viewportPoint.Z > 0 then
                    ClickAtScreen(Vector2.new(viewportPoint.X, viewportPoint.Y))
                else
                    -- Fallback: Clique no centro da tela
                    ClickAtScreen(Vector2.new(960, 540))
                end
                
                -- Atualiza status
                local statusLabel = ScreenGui:FindFirstChild("MainFrame"):FindFirstChild("Status")
                if statusLabel then
                    statusLabel.Text = "Farmando: " .. target.Name
                end
            else
                -- Se não achar alvo, clica no centro da tela
                ClickAtScreen(Vector2.new(960, 540))
                local statusLabel = ScreenGui:FindFirstChild("MainFrame"):FindFirstChild("Status")
                if statusLabel then
                    statusLabel.Text = "Status: Sem alvo próximo"
                end
            end

            local jitter = (math.random() - 0.5) * CONFIG.Jitter
            task.wait(CONFIG.ClickSpeed + jitter)
        end
    end)
end

StartFarm()
