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
