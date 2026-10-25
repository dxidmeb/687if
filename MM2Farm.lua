local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1564040432877310102/aOY4GiLEOiiqJOkEBnFY4uNepGetsE8Mv0B7xco5UsWokX4N8i1fS1MfWpg64MIq1xtv"

local farming = false
local totalCollected = 0
local totalRuntime = 0
local sessionStart = 0
local lastWebhook = 0

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

local function sendWebhook(title, statusText)
    if WEBHOOK_URL == "" then return end
    local req = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
    if not req then return end
    local data = {
        username = "MM2 Farm",
        embeds = {{
            title = title,
            color = 1118481,
            fields = {
                {name = "Status", value = statusText, inline = true},
                {name = "Runtime", value = formatTime(getTotalRuntime()), inline = true},
                {name = "Collected", value = tostring(totalCollected), inline = true},
                {name = "Player", value = LocalPlayer.Name, inline = true}
            },
            footer = {text = "Made by Fuzzy"}
        }}
    }
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MM2FarmGui"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0, 0.5)
Frame.Position = UDim2.new(0, 16, 0.5, 0)
Frame.Size = UDim2.new(0, 240, 0, 232)
Frame.Active = true
Frame.Draggable = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1
FrameStroke.Color = Color3.fromRGB(38, 38, 38)
FrameStroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 16, 0, 14)
Title.Size = UDim2.new(0, 160, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "MM2 FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Frame
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -32, 0, 10)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.Gotham
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(140, 140, 140)
CloseButton.TextSize = 16

local Divider = Instance.new("Frame")
Divider.Parent = Frame
Divider.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0, 16, 0, 42)
Divider.Size = UDim2.new(1, -32, 0, 1)

local function makeRow(y, labelText)
    local label = Instance.new("TextLabel")
    label.Parent = Frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, y)
    label.Size = UDim2.new(0, 100, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(140, 140, 140)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    local value = Instance.new("TextLabel")
    value.Parent = Frame
    value.BackgroundTransparency = 1
    value.Position = UDim2.new(1, -116, 0, y)
    value.Size = UDim2.new(0, 100, 0, 20)
    value.Font = Enum.Font.GothamBold
    value.TextColor3 = Color3.fromRGB(255, 255, 255)
    value.TextSize = 12
    value.TextXAlignment = Enum.TextXAlignment.Right
    return value
end

local StatusValue = makeRow(58, "Status")
StatusValue.Text = "Stopped"
local CollectedValue = makeRow(84, "Total Collected")
CollectedValue.Text = "0"
local RuntimeValue = makeRow(110, "Total Runtime")
RuntimeValue.Text = "00:00"

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Position = UDim2.new(0, 16, 0, 146)
ToggleButton.Size = UDim2.new(1, -32, 0, 36)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "START"
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextSize = 13

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleButton

local Footer = Instance.new("TextLabel")
Footer.Parent = Frame
Footer.BackgroundTransparency = 1
Footer.Position = UDim2.new(0, 0, 1, -26)
Footer.Size = UDim2.new(1, 0, 0, 16)
Footer.Font = Enum.Font.Gotham
Footer.Text = "Made by Fuzzy"
Footer.TextColor3 = Color3.fromRGB(110, 110, 110)
Footer.TextSize = 11

CloseButton.MouseButton1Click:Connect(function()
    if farming then
        totalRuntime = totalRuntime + (os.clock() - sessionStart)
        farming = false
        sendWebhook("Bot Stopped", "Stopped")
    end
    Gui:Destroy()
end)

ToggleButton.MouseButton1Click:Connect(function()
    farming = not farming
    if farming then
        sessionStart = os.clock()
        lastWebhook = os.clock()
        ToggleButton.Text = "STOP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusValue.Text = "Farming"
        sendWebhook("Bot Started", "Farming")
    else
        totalRuntime = totalRuntime + (os.clock() - sessionStart)
        ToggleButton.Text = "START"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        StatusValue.Text = "Stopped"
        sendWebhook("Bot Stopped", "Stopped")
    end
end)

task.spawn(function()
    while Gui.Parent do
        task.wait(0.5)
        RuntimeValue.Text = formatTime(getTotalRuntime())
        if farming and os.clock() - lastWebhook >= 300 then
            lastWebhook = os.clock()
            sendWebhook("Bot Running", "Farming")
        end
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
            StatusValue.Text = "Waiting for character"
            continue
        end
        local closestCoin, closestDist = getClosestCoin(root)
        if not closestCoin then
            StatusValue.Text = "No coins"
            task.wait(2)
            continue
        end
        StatusValue.Text = "Farming"
        local tweenTime = math.clamp(closestDist * 0.05, 0.3, 2)
        local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = closestCoin.CFrame})
        tween:Play()
        task.wait(tweenTime + 0.1)
        if closestCoin.Parent and (root.Position - closestCoin.Position).Magnitude < 8 then
            totalCollected = totalCollected + 1
            CollectedValue.Text = tostring(totalCollected)
        end
    end
end)
