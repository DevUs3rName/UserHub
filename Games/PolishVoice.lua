local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")

local targetPosition = Vector3.new(-95.81661987304688, 47.329925537109375, -981.8408203125)
local teleportInterval = 600

local isActive = false
local teleportTimer = 0
local originalPosition = nil
local isTeleporting = false

local function teleportToPosition(pos)
    if not Character or not Character.Parent then
        Character = Player.Character
        if not Character then return end
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    
    if not HumanoidRootPart then return end
    
    HumanoidRootPart.CFrame = CFrame.new(pos)
end

local function teleportToTarget()
    if not Character or not Character.Parent then
        Character = Player.Character
        if not Character then return end
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    
    if not HumanoidRootPart then return end
    
    originalPosition = HumanoidRootPart.Position
    isTeleporting = true
    
    HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    
    task.wait(0.1)
    
    if originalPosition then
        HumanoidRootPart.CFrame = CFrame.new(originalPosition)
        originalPosition = nil
    end
    
    isTeleporting = false
end

local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Roblox"

local Window = Rayfield:CreateWindow({
    Name = "UserHub | " .. gameName,
    Icon = 0,
    LoadingTitle = "UserHub",
    LoadingSubtitle = gameName,
    Theme = "Dark",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UserHub",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("AutoFarm", 0)

local Toggle = MainTab:CreateToggle({
    Name = "AutoFarm Coins",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        isActive = Value
        if isActive then
            teleportTimer = 0
        else
            teleportTimer = 0
        end
    end
})

local timeDisplay = MainTab:CreateLabel("Nastepny teleport: --:--")

local function updateTimer()
    if isActive then
        local remaining = math.max(0, teleportInterval - teleportTimer)
        local minutes = math.floor(remaining / 60)
        local seconds = math.floor(remaining % 60)
        timeDisplay:Set(string.format("Nastepny teleport: %02d:%02d", minutes, seconds))
    else
        timeDisplay:Set("Nastepny teleport: --:--")
    end
end

local TeleportsTab = Window:CreateTab("Teleports", 1)

local TeleportsSection = TeleportsTab:CreateSection("Lokacje")

TeleportsTab:CreateButton({
    Name = "Elite",
    Callback = function()
        local elitePos = Vector3.new(-858.5923461914062, 87.2798843383789, -32422.427734375)
        teleportToPosition(elitePos)
    end
})

TeleportsTab:CreateButton({
    Name = "News",
    Callback = function()
        local newsPos = Vector3.new(1734.02001953125, 28.369802474975586, -1202.1199951171875)
        teleportToPosition(newsPos)
    end
})

TeleportsTab:CreateButton({
    Name = "Beach",
    Callback = function()
        local beachPos = Vector3.new(-929.1425170898438, 14.865099906921387, -733.673583984375)
        teleportToPosition(beachPos)
    end
})

TeleportsTab:CreateButton({
    Name = "Go-Kart",
    Callback = function()
        local gokartPos = Vector3.new(-920.2070922851562, 25.77408790588379, -1229.408203125)
        teleportToPosition(gokartPos)
    end
})

TeleportsTab:CreateButton({
    Name = "Shop",
    Callback = function()
        local shopPos = Vector3.new(-858.1865234375, 26.63401222229004, -834.172607421875)
        teleportToPosition(shopPos)
    end
})

TeleportsTab:CreateButton({
    Name = "Stage",
    Callback = function()
        local stagePos = Vector3.new(-730.2810668945312, 26.386600494384766, -1107.3328857421875)
        teleportToPosition(stagePos)
    end
})

TeleportsTab:CreateButton({
    Name = "Soccer",
    Callback = function()
        local soccerPos = Vector3.new(-1047.52, 25.11, -1054.85)
        teleportToPosition(soccerPos)
    end
})

game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    if isActive and not isTeleporting then
        teleportTimer = teleportTimer + deltaTime
        
        if teleportTimer >= teleportInterval then
            teleportTimer = 0
            teleportToTarget()
        end
        
        updateTimer()
    end
end)

updateTimer()
