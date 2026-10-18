-- M2 Auto Farm v4 (Corrigido)
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
    ClickSpeed = 0.1, -- Segundos entre cliques
    Jitter = 0.05, -- Variabilidade para parecer humano
    -- Posição de farme: Deixe nil para usar a posição atual do personagem
    FarmPosition = nil, 
    -- Se quiser forçar uma posição, descomente a linha abaixo e ajuste:
    -- FarmPosition = Vector3.new(0, 50, 0),
}

local State = {
    IsFarming = true,
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
    Main.Size = UDim2.new(0, 280, 0, 150)
    Main.Position = UDim2.new(1, -300, 0, 50)
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
    Title.Text = "M2 Auto Farm"
    Title.TextColor3 = Color3.fromRGB(0, 255, 128)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -20, 0, 20)
    Status.Position = UDim2.new(0.05, 0, 0.25, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "Status: Ativo"
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
            Status.Text = "Status: Use FarmPosition"
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

            -- Mira no Objeto Mais Próximo (ou no próprio personagem como fallback)
            local targetPos = RootPart.Position + Vector3.new(0, 2, 0)
            
            -- Se tiver uma posição de farme configurada, usa ela
            if CONFIG.FarmPosition then
                targetPos = CONFIG.FarmPosition
            end

            local viewportPoint = Camera:WorldToViewportPoint(targetPos)
            
            -- Se o ponto estiver na frente da câmera, clica
            if viewportPoint.Z > 0 then
                ClickAtScreen(Vector2.new(viewportPoint.X, viewportPoint.Y))
            else
                -- Fallback: Clique no centro da tela
                ClickAtScreen(Vector2.new(960, 540))
            end

            local jitter = (math.random() - 0.5) * CONFIG.Jitter
            task.wait(CONFIG.ClickSpeed + jitter)
        end
    end)
end

StartFarm()
