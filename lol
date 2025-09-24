local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

--// Teleport simples
local function tpTo(pos)
    if HRP and HRP.Parent then
        HRP.CFrame = CFrame.new(pos)
    end
end

--// Função pra encontrar a base do jogador
local function getPlayerBase()
    for _, base in pairs(workspace.Bases:GetChildren()) do
        local owner = base:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer then
            return base
        end
    end
    return nil
end

--// Função de loop de touch (abre o Lock)
local function startTouchLoop(base)
    local lock = base:FindFirstChild("Lock")
    if not lock then return end

    local touch = lock:FindFirstChild("TouchInterest")
    if not touch then return end

    while task.wait(0.1) do
        if not HRP or not HRP.Parent then
            HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        end
        if HRP and HRP.Parent then
            firetouchinterest(HRP, lock, 0)
            firetouchinterest(HRP, lock, 1)
        end
    end
end

--// GUI com imagem e texto (arrastável)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local button = Instance.new("ImageButton")
button.Size = UDim2.new(0, 48, 0, 48)
button.Position = UDim2.new(1, -200, 1, -60)
button.AnchorPoint = Vector2.new(0, 0)
button.BackgroundTransparency = 0.2
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
button.Image = "rbxassetid://91045108512308" -- ✅ rbxassetid aplicado
button.ImageColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 2
button.BorderColor3 = Color3.fromRGB(0, 255, 0)
button.ZIndex = 1000
button.Parent = gui

-- Texto ao lado
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 150, 0, 48)
textLabel.Position = UDim2.new(0, 55, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextSize = 20
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Text = "MitHub Farm"
textLabel.ZIndex = 1000
textLabel.Parent = button

-- Sistema de arrastar
local dragging, dragInput, dragStart, startPos = false

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// Ação do botão: Teleportar pro TouchingPart da sua base
button.MouseButton1Click:Connect(function()
    local base = getPlayerBase()
    if base then
        local touchingPart = base:FindFirstChild("TouchingPart")
        if touchingPart and touchingPart:IsA("BasePart") then
            tpTo(touchingPart.Position + Vector3.new(0, 3, 0))
            warn("✅ Teleportado para o TouchingPart da sua base:", base.Name)
        else
            warn("❌ Sua base não tem TouchingPart!")
        end
    else
        warn("❌ Nenhuma base encontrada para você.")
    end
end)

--// Inicia o loop automático de touch
task.spawn(function()
    local myBase = nil
    repeat
        myBase = getPlayerBase()
        task.wait(1)
    until myBase

    startTouchLoop(myBase)
end)
