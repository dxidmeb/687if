local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local farming = false
local totalCollected = 0
local totalRuntime = 0
local sessionStart = 0

local function formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d", m, s)
end

local function getTotalRuntime()
    if farming then
        return totalRuntime + (os.clock() - sessionStart)
    end
    return totalRuntime
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "SimpleFarmGui"
Gui.ResetOnSpawn = false

local guiParent = PlayerGui
if gethui then
    local ok, result = pcall(gethui)
    if ok and result then
        guiParent = result
    end
end
Gui.Parent = guiParent

local Frame = Instance.new("Frame")
Frame.Parent = Gui
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.Position = UDim2.new(0.5, -130, 0.5, -110)
Frame.Size = UDim2.new(0, 260, 0, 220)
Frame.Active = true
Frame.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "MM2 Coin Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Frame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0, 42)
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.Text = "Status: Stopped"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 15

local TotalCollectedLabel = Instance.new("TextLabel")
TotalCollectedLabel.Parent = Frame
TotalCollectedLabel.BackgroundTransparency = 1
TotalCollectedLabel.Position = UDim2.new(0, 0, 0, 68)
TotalCollectedLabel.Size = UDim2.new(1, 0, 0, 25)
TotalCollectedLabel.Font = Enum.Font.SourceSansBold
TotalCollectedLabel.Text = "Total Collected: 0"
TotalCollectedLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
TotalCollectedLabel.TextSize = 16

local TotalRuntimeLabel = Instance.new("TextLabel")
TotalRuntimeLabel.Parent = Frame
TotalRuntimeLabel.BackgroundTransparency = 1
TotalRuntimeLabel.Position = UDim2.new(0, 0, 0, 94)
TotalRuntimeLabel.Size = UDim2.new(1, 0, 0, 25)
TotalRuntimeLabel.Font = Enum.Font.SourceSansBold
TotalRuntimeLabel.Text = "Total Runtime: 00:00"
TotalRuntimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TotalRuntimeLabel.TextSize = 16

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleButton.Position = UDim2.new(0.15, 0, 0, 130)
ToggleButton.Size = UDim2.new(0.7, 0, 0, 40)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Start"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = ToggleButton

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Frame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Position = UDim2.new(1, -30, 0, 8)
CloseButton.Size = UDim2.new(0, 22, 0, 22)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    farming = false
    Gui:Destroy()
end)

ToggleButton.MouseButton1Click:Connect(function()
    farming = not farming
    if farming then
        sessionStart = os.clock()
        ToggleButton.Text = "Stop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        StatusLabel.Text = "Status: Farming..."
    else
        totalRuntime = totalRuntime + (os.clock() - sessionStart)
        ToggleButton.Text = "Start"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        StatusLabel.Text = "Status: Stopped"
    end
end)

task.spawn(function()
    while Gui.Parent do
        task.wait(0.5)
        TotalRuntimeLabel.Text = "Total Runtime: " .. formatTime(getTotalRuntime())
    end
end)

local function getClosestCoin(root)
    local container = workspace:FindFirstChild("CoinContainer", true)
    local closestCoin = nil
    local closestDist = math.huge

    local function checkCoin(coin)
        if coin.Name ~= "Coin_Server" then return end
        if not coin:IsA("BasePart") then return end
        local visual = coin:FindFirstChild("CoinVisual")
        if visual and visual.Transparency >= 1 then return end
        local dist = (root.Position - coin.Position).Magnitude
        if dist < closestDist then
            closestCoin = coin
            closestDist = dist
        end
    end

    if container then
        for _, coin in pairs(container:GetChildren()) do
            checkCoin(coin)
        end
    end

    if not closestCoin then
        for _, coin in pairs(workspace:GetDescendants()) do
            checkCoin(coin)
        end
    end

    return closestCoin, closestDist
end

task.spawn(function()
    while Gui.Parent do
        task.wait(0.2)
        if not farming then continue end

        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then
            StatusLabel.Text = "Status: Waiting for character..."
            continue
        end

        local closestCoin, closestDist = getClosestCoin(root)

        if not closestCoin then
            StatusLabel.Text = "Status: No coins - waiting for round..."
            task.wait(2)
            continue
        end

        StatusLabel.Text = "Status: Farming..."

        local tweenTime = math.clamp(closestDist * 0.05, 0.3, 2)
        local tween = TweenService:Create(root,
            TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
            {CFrame = closestCoin.CFrame}
        )
        tween:Play()
        task.wait(tweenTime + 0.1)

        if closestCoin.Parent and (root.Position - closestCoin.Position).Magnitude < 8 then
            totalCollected = totalCollected + 1
            TotalCollectedLabel.Text = "Total Collected: " .. totalCollected
        end
    end
end)
