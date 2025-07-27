-- SHADOW HUB PRO - v2.0
-- Aimbot Universal | ESP Profissional | Auto Coletor
-- Feito com interface leve e visual limpo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG
local Settings = {
    AimbotEnabled = true,
    ESPEnabled = true,
    FOV = 150,
    FOVCircle = true,
    AutoCollectEnabled = true,
    FOVColor = Color3.fromRGB(255,255,255),
    AllyColor = Color3.fromRGB(0, 170, 255),
    EnemyColor = Color3.fromRGB(255, 0, 0),
}

-- GUI BASE
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

-- FOV CIRCLE
local circle = Drawing.new("Circle")
circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
circle.Radius = Settings.FOV
circle.Color = Settings.FOVColor
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.4
circle.Visible = Settings.FOVCircle

-- FUNÇÃO: Checa se jogador é inimigo (mesmo sem times)
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team ~= nil and LocalPlayer.Team ~= nil then
        return player.Team ~= LocalPlayer.Team
    end
    -- Se não há time, considera todos como inimigos
    return true
end

-- FUNÇÃO: Encontra o alvo mais próximo dentro do FOV
local function GetClosestPlayer()
    local closest = nil
    local shortest = Settings.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") and IsEnemy(player) then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end

    return closest
end

-- FUNÇÃO: Aimbot
RunService.RenderStepped:Connect(function()
    circle.Radius = Settings.FOV
    circle.Visible = Settings.FOVCircle

    if Settings.AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head.Position
            local screenPos = Camera:WorldToScreenPoint(head)
            mousemoverel((screenPos.X - Camera.ViewportSize.X/2) * 0.1, (screenPos.Y - Camera.ViewportSize.Y/2) * 0.1)
        end
    end
end)

-- FUNÇÃO: ESP simples com bolinha dentro do jogador
local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "ESP_Objects"

RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled then
        for _, item in pairs(ESPFolder:GetChildren()) do item:Destroy() end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local existing = ESPFolder:FindFirstChild(player.Name)
            if not existing then
                local adorn = Instance.new("BillboardGui", ESPFolder)
                adorn.Name = player.Name
                adorn.Adornee = player.Character.HumanoidRootPart
                adorn.Size = UDim2.new(0, 6, 0, 6)
                adorn.AlwaysOnTop = true

                local frame = Instance.new("Frame", adorn)
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = IsEnemy(player) and Settings.EnemyColor or Settings.AllyColor
                frame.BorderSizePixel = 0
            end
        end
    end
end)

-- FUNÇÃO: Auto Coletor
RunService.Heartbeat:Connect(function()
    if not Settings.AutoCollectEnabled then return end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.MaxActivationDistance >= 8 then
            if (v.Parent.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < v.MaxActivationDistance then
                fireproximityprompt(v)
            end
        end
    end
end)
