-- m2_farm.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configurações
local CONFIG = {
    FarmPosition = Vector3.new(0, 50, 0),
    ClickSpeed = 0.1,
    AutoTeleport = true
}

-- UI Simples
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "M2FarmUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(1, -220, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "M2 Auto Farm"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextScaled = true
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ativo"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true
StatusLabel.Parent = Frame

-- Função de Farme
local function startFarming()
    task.spawn(function()
        while true do
            if CONFIG.AutoTeleport then
                RootPart.CFrame = CFrame.new(CONFIG.FarmPosition)
            end
            
            -- Simula clique no centro da tela
            UserInputService:MouseButtons1Down(Vector2.new(960, 540))
            task.wait(0.05)
            UserInputService:MouseButtons1Up(Vector2.new(960, 540))
            
            task.wait(CONFIG.ClickSpeed)
        end
    end)
end

startFarming()
print("[M2 Farm] Script carregado!")
