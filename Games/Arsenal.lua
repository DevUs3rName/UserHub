--[[
    Arsenal Script - Rayfield UI
    Aimbot + Silent Aim + ESP + Detection
]]

-- Sprawdzenie czy to Arsenal
if game.PlaceId ~= 286090429 then 
    return
end

if _G.AimBotScript then
    _G.AimBotScript:Destroy() 
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Ustawienia
local Enabled = true
local FOV = 100
local Smoothing = 0.1

local SilentAimEnabled = false
local HitboxSize = 13
local HitboxTransparency = 10

local ShowFOVCircle = true
local ShowESP = true
local ESPColor = Color3.new(0, 1, 0)

local ShowScriptUsers = true
local ScriptIdentifier = "ArsenalScript_" .. math.random(10000, 99999)
local DetectedUsers = {}
local UserListText = nil

-- Rysowanie
if not Drawing then
    return
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ShowFOVCircle
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local ESPDrawings = {}

-- Funkcje wykrywania skryptu
local function BroadcastPresence()
    if not _G.ArsenalScriptUsers then
        _G.ArsenalScriptUsers = {}
    end
    _G.ArsenalScriptUsers[LocalPlayer.Name] = {
        identifier = ScriptIdentifier,
        timestamp = tick(),
        player = LocalPlayer
    }
end

local function UpdateDetectedUsers()
    if not _G.ArsenalScriptUsers then return end
    
    DetectedUsers = {}
    local currentTime = tick()
    
    for playerName, data in pairs(_G.ArsenalScriptUsers) do
        if currentTime - data.timestamp > 10 then
            _G.ArsenalScriptUsers[playerName] = nil
        else
            table.insert(DetectedUsers, playerName)
        end
    end
end

-- ESP
local function CreateESP(player)
    if ESPDrawings[player] then return end

    local drawings = {}
    drawings.Spine = Drawing.new("Line")
    drawings.LeftUpperArm = Drawing.new("Line")
    drawings.LeftLowerArm = Drawing.new("Line")
    drawings.RightUpperArm = Drawing.new("Line")
    drawings.RightLowerArm = Drawing.new("Line")
    drawings.LeftUpperLeg = Drawing.new("Line")
    drawings.LeftLowerLeg = Drawing.new("Line")
    drawings.RightUpperLeg = Drawing.new("Line")
    drawings.RightLowerLeg = Drawing.new("Line")
    
    drawings.DistanceText = Drawing.new("Text")
    drawings.DistanceText.Text = "0m"
    drawings.DistanceText.Size = 16
    drawings.DistanceText.Color = Color3.new(1, 1, 1)
    drawings.DistanceText.Center = true
    drawings.DistanceText.Outline = true
    drawings.DistanceText.OutlineColor = Color3.new(0, 0, 0)
    drawings.DistanceText.Visible = false
    
    for name, line in pairs(drawings) do
        if name:find("Arm") or name:find("Leg") or name == "Spine" then
            line.Visible = false
            line.Color = ESPColor
            line.Thickness = 2
        end
    end

    ESPDrawings[player] = drawings
end

local function RemoveESP(player)
    if not ESPDrawings[player] then return end

    for _, drawing in pairs(ESPDrawings[player]) do
        drawing:Remove()
    end
    ESPDrawings[player] = nil
end

local function UpdateESP()
    for player, drawings in pairs(ESPDrawings) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if player.Team ~= LocalPlayer.Team then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                
                local leftUpperArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
                local leftLowerArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftLowerArm")
                local rightUpperArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
                local rightLowerArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightLowerArm")
                local leftUpperLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
                local leftLowerLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
                local rightUpperLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
                local rightLowerLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")

                if head and torso then
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                    
                    if headOnScreen and torsoOnScreen then
                        drawings.Spine.From = Vector2.new(headPos.X, headPos.Y)
                        drawings.Spine.To = Vector2.new(torsoPos.X, torsoPos.Y)
                        drawings.Spine.Visible = ShowESP
                        
                        if leftUpperArm then
                            local leftUpperArmPos, leftUpperArmOnScreen = Camera:WorldToViewportPoint(leftUpperArm.Position)
                            if leftUpperArmOnScreen then
                                drawings.LeftUpperArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                                drawings.LeftUpperArm.To = Vector2.new(leftUpperArmPos.X, leftUpperArmPos.Y)
                                drawings.LeftUpperArm.Visible = ShowESP
                                
                                if leftLowerArm and leftLowerArm ~= leftUpperArm then
                                    local leftLowerArmPos, leftLowerArmOnScreen = Camera:WorldToViewportPoint(leftLowerArm.Position)
                                    if leftLowerArmOnScreen then
                                        drawings.LeftLowerArm.From = Vector2.new(leftUpperArmPos.X, leftUpperArmPos.Y)
                                        drawings.LeftLowerArm.To = Vector2.new(leftLowerArmPos.X, leftLowerArmPos.Y)
                                        drawings.LeftLowerArm.Visible = ShowESP
                                    else
                                        drawings.LeftLowerArm.Visible = false
                                    end
                                else
                                    drawings.LeftLowerArm.Visible = false
                                end
                            else
                                drawings.LeftUpperArm.Visible = false
                                drawings.LeftLowerArm.Visible = false
                            end
                        else
                            drawings.LeftUpperArm.Visible = false
                            drawings.LeftLowerArm.Visible = false
                        end
                        
                        if rightUpperArm then
                            local rightUpperArmPos, rightUpperArmOnScreen = Camera:WorldToViewportPoint(rightUpperArm.Position)
                            if rightUpperArmOnScreen then
                                drawings.RightUpperArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                                drawings.RightUpperArm.To = Vector2.new(rightUpperArmPos.X, rightUpperArmPos.Y)
                                drawings.RightUpperArm.Visible = ShowESP
                                
                                if rightLowerArm and rightLowerArm ~= rightUpperArm then
                                    local rightLowerArmPos, rightLowerArmOnScreen = Camera:WorldToViewportPoint(rightLowerArm.Position)
                                    if rightLowerArmOnScreen then
                                        drawings.RightLowerArm.From = Vector2.new(rightUpperArmPos.X, rightUpperArmPos.Y)
                                        drawings.RightLowerArm.To = Vector2.new(rightLowerArmPos.X, rightLowerArmPos.Y)
                                        drawings.RightLowerArm.Visible = ShowESP
                                    else
                                        drawings.RightLowerArm.Visible = false
                                    end
                                else
                                    drawings.RightLowerArm.Visible = false
                                end
                            else
                                drawings.RightUpperArm.Visible = false
                                drawings.RightLowerArm.Visible = false
                            end
                        else
                            drawings.RightUpperArm.Visible = false
                            drawings.RightLowerArm.Visible = false
                        end
                        
                        if leftUpperLeg then
                            local leftUpperLegPos, leftUpperLegOnScreen = Camera:WorldToViewportPoint(leftUpperLeg.Position)
                            if leftUpperLegOnScreen then
                                drawings.LeftUpperLeg.From = Vector2.new(torsoPos.X, torsoPos.Y)
                                drawings.LeftUpperLeg.To = Vector2.new(leftUpperLegPos.X, leftUpperLegPos.Y)
                                drawings.LeftUpperLeg.Visible = ShowESP
                                
                                if leftLowerLeg and leftLowerLeg ~= leftUpperLeg then
                                    local leftLowerLegPos, leftLowerLegOnScreen = Camera:WorldToViewportPoint(leftLowerLeg.Position)
                                    if leftLowerLegOnScreen then
                                        drawings.LeftLowerLeg.From = Vector2.new(leftUpperLegPos.X, leftUpperLegPos.Y)
                                        drawings.LeftLowerLeg.To = Vector2.new(leftLowerLegPos.X, leftLowerLegPos.Y)
                                        drawings.LeftLowerLeg.Visible = ShowESP
                                    else
                                        drawings.LeftLowerLeg.Visible = false
                                    end
                                else
                                    drawings.LeftLowerLeg.Visible = false
                                end
                            else
                                drawings.LeftUpperLeg.Visible = false
                                drawings.LeftLowerLeg.Visible = false
                            end
                        else
                            drawings.LeftUpperLeg.Visible = false
                            drawings.LeftLowerLeg.Visible = false
                        end
                        
                        if rightUpperLeg then
                            local rightUpperLegPos, rightUpperLegOnScreen = Camera:WorldToViewportPoint(rightUpperLeg.Position)
                            if rightUpperLegOnScreen then
                                drawings.RightUpperLeg.From = Vector2.new(torsoPos.X, torsoPos.Y)
                                drawings.RightUpperLeg.To = Vector2.new(rightUpperLegPos.X, rightUpperLegPos.Y)
                                drawings.RightUpperLeg.Visible = ShowESP
                                
                                if rightLowerLeg and rightLowerLeg ~= rightUpperLeg then
                                    local rightLowerLegPos, rightLowerLegOnScreen = Camera:WorldToViewportPoint(rightLowerLeg.Position)
                                    if rightLowerLegOnScreen then
                                        drawings.RightLowerLeg.From = Vector2.new(rightUpperLegPos.X, rightUpperLegPos.Y)
                                        drawings.RightLowerLeg.To = Vector2.new(rightLowerLegPos.X, rightLowerLegPos.Y)
                                        drawings.RightLowerLeg.Visible = ShowESP
                                    else
                                        drawings.RightLowerLeg.Visible = false
                                    end
                                else
                                    drawings.RightLowerLeg.Visible = false
                                end
                            else
                                drawings.RightUpperLeg.Visible = false
                                drawings.RightLowerLeg.Visible = false
                            end
                        else
                            drawings.RightUpperLeg.Visible = false
                            drawings.RightLowerLeg.Visible = false
                        end
                        
                        local distance = math.floor((head.Position - Camera.CFrame.Position).Magnitude)
                        drawings.DistanceText.Text = distance .. "m"
                        drawings.DistanceText.Position = Vector2.new(headPos.X, headPos.Y - 25)
                        drawings.DistanceText.Visible = ShowESP
                    else
                        for _, element in pairs(drawings) do
                            element.Visible = false
                        end
                    end
                else
                    for _, element in pairs(drawings) do
                        element.Visible = false
                    end
                end
            else
                for _, element in pairs(drawings) do
                    element.Visible = false
                end
            end
        else
            for _, element in pairs(drawings) do
                element.Visible = false
            end
        end
    end
end

-- Aimbot funkcje
local function IsPlayerVisible(player)
    if not player.Character then return false end
    local target = player.Character:FindFirstChild("Head")
    if not target then return false end

    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit
    local ray = Ray.new(origin, direction * 1000)

    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})

    if hit and hit:IsDescendantOf(player.Character) then
        return true
    end
    return false
end

local function IsInFOVCircle(player)
    if not player.Character then return false end
    local target = player.Character:FindFirstChild("Head")
    if not target then return false end

    local screenPoint, onScreen = Camera:WorldToViewportPoint(target.Position)
    if not onScreen then return false end

    local circleCenter = FOVCircle.Position
    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - circleCenter).Magnitude

    return distance <= FOVCircle.Radius
end

local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if player.Team ~= LocalPlayer.Team then
                if IsPlayerVisible(player) and IsInFOVCircle(player) then
                    local screenPoint = Camera:WorldToViewportPoint(player.Character.Head.Position)
                    local circleCenter = FOVCircle.Position
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - circleCenter).Magnitude

                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function AimBot()
    if not Enabled then return end 
    local closestPlayer = GetClosestPlayerInFOV()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local target = closestPlayer.Character.Head
        
        local currentLook = Camera.CFrame.LookVector
        local targetLook = (target.Position - Camera.CFrame.Position).Unit
        local adjustedLook = (currentLook + (targetLook - currentLook) * Smoothing).Unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + adjustedLook)
    end
end

-- Silent Aim
local silentAimConnections = {}

local function StartSilentAim()
    if silentAimConnections.transparency then
        silentAimConnections.transparency:Disconnect()
    end
    if silentAimConnections.hitbox then
        silentAimConnections.hitbox:Disconnect()
    end
    
    silentAimConnections.transparency = coroutine.wrap(function()
        while SilentAimEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, partName in pairs({"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}) do
                        local part = player.Character:FindFirstChild(partName)
                        if part then
                            part.Transparency = HitboxTransparency
                        end
                    end
                end
            end
            wait(1)
        end
    end)()
    
    silentAimConnections.hitbox = coroutine.wrap(function()
        while SilentAimEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, partName in pairs({"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}) do
                        local part = player.Character:FindFirstChild(partName)
                        if part then
                            part.CanCollide = false
                            part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        end
                    end
                end
            end
            wait(1)
        end
    end)()
end

local function StopSilentAim()
    if silentAimConnections.transparency then
        silentAimConnections.transparency:Disconnect()
        silentAimConnections.transparency = nil
    end
    if silentAimConnections.hitbox then
        silentAimConnections.hitbox:Disconnect()
        silentAimConnections.hitbox = nil
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, partName in pairs({"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}) do
                local part = player.Character:FindFirstChild(partName)
                if part then
                    part.Transparency = 0
                    part.CanCollide = true
                
                    if partName == "HumanoidRootPart" then
                        part.Size = Vector3.new(2, 2, 1)
                    elseif partName:find("Leg") then
                        part.Size = Vector3.new(1, 2, 1)
                    elseif partName == "HeadHB" then
                        part.Size = Vector3.new(2, 1, 1)
                    end
                end
            end
        end
    end
end

-- GUI
local Window = Rayfield:CreateWindow({
    Name = "Arsenal Script",
    Icon = 0,
    LoadingTitle = "Arsenal Script",
    LoadingSubtitle = "by UserHub",
    Theme = "Dark",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArsenalScript",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("Aimbot", 0)
local VisualsTab = Window:CreateTab("Visuals", 1)
local DetectionTab = Window:CreateTab("Detection", 2)
local SettingsTab = Window:CreateTab("Settings", 3)

-- Aimbot Tab
local AimbotSection = MainTab:CreateSection("Aimbot")

MainTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = Enabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Enabled = Value
    end
})

MainTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = FOV,
    Flag = "FOVSlider",
    Callback = function(Value)
        FOV = Value
        FOVCircle.Radius = Value
    end
})

MainTab:CreateSlider({
    Name = "Smoothing",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = Smoothing * 100,
    Flag = "SmoothingSlider",
    Callback = function(Value)
        Smoothing = Value / 100
    end
})

local SilentAimSection = MainTab:CreateSection("Silent Aim")

MainTab:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = SilentAimEnabled,
    Flag = "SilentAimToggle",
    Callback = function(Value)
        SilentAimEnabled = Value
        if Value then
            StartSilentAim()
        else
            StopSilentAim()
        end
    end
})

MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = HitboxSize,
    Flag = "HitboxSizeSlider",
    Callback = function(Value)
        HitboxSize = Value
    end
})

MainTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = HitboxTransparency,
    Flag = "HitboxTransparencySlider",
    Callback = function(Value)
        HitboxTransparency = Value
    end
})

-- Visuals Tab
local VisualsSection = VisualsTab:CreateSection("Visuals")

VisualsTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = ShowFOVCircle,
    Flag = "FOVCircleToggle",
    Callback = function(Value)
        ShowFOVCircle = Value
        FOVCircle.Visible = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Show ESP Skeleton",
    CurrentValue = ShowESP,
    Flag = "ESPToggle",
    Callback = function(Value)
        ShowESP = Value
    end
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = ESPColor,
    Flag = "ESPColor",
    Callback = function(Value)
        ESPColor = Value
        for _, drawings in pairs(ESPDrawings) do
            if drawings.Spine then drawings.Spine.Color = Value end
            if drawings.LeftUpperArm then drawings.LeftUpperArm.Color = Value end
            if drawings.LeftLowerArm then drawings.LeftLowerArm.Color = Value end
            if drawings.RightUpperArm then drawings.RightUpperArm.Color = Value end
            if drawings.RightLowerArm then drawings.RightLowerArm.Color = Value end
            if drawings.LeftUpperLeg then drawings.LeftUpperLeg.Color = Value end
            if drawings.LeftLowerLeg then drawings.LeftLowerLeg.Color = Value end
            if drawings.RightUpperLeg then drawings.RightUpperLeg.Color = Value end
            if drawings.RightLowerLeg then drawings.RightLowerLeg.Color = Value end
        end
    end
})

-- Detection Tab
local DetectionSection = DetectionTab:CreateSection("Script Detection")

DetectionTab:CreateToggle({
    Name = "Show Script Users",
    CurrentValue = ShowScriptUsers,
    Flag = "ShowUsersToggle",
    Callback = function(Value)
        ShowScriptUsers = Value
    end
})

DetectionTab:CreateButton({
    Name = "Refresh User List",
    Callback = function()
        UpdateDetectedUsers()
        print("User list refreshed - Found " .. #DetectedUsers .. " script users")
    end
})

local userListLabel = DetectionTab:CreateLabel("Detected Users: None")

-- Aktualizacja listy użytkowników
spawn(function()
    while _G.AimBotScript do
        BroadcastPresence()
        UpdateDetectedUsers()
        if #DetectedUsers > 0 then
            userListLabel:Set("Detected Users (" .. #DetectedUsers .. "):\n" .. table.concat(DetectedUsers, "\n"))
        else
            userListLabel:Set("Detected Users: None")
        end
        wait(2)
    end
end)

-- Settings Tab
local SettingsSection = SettingsTab:CreateSection("Settings")

SettingsTab:CreateButton({
    Name = "Reset Settings",
    Callback = function()
        Enabled = true
        SilentAimEnabled = false
        FOV = 100
        Smoothing = 0.1
        ShowFOVCircle = true
        ShowESP = true
        ESPColor = Color3.new(0, 1, 0)
        HitboxSize = 13
        HitboxTransparency = 10
        FOVCircle.Radius = FOV
        FOVCircle.Visible = ShowFOVCircle
        StopSilentAim()
        for _, drawings in pairs(ESPDrawings) do
            for _, line in pairs(drawings) do
                line.Color = ESPColor
            end
        end
        print("Settings reset to default")
    end
})

-- Inicjalizacja
BroadcastPresence()

-- ESP dla graczy
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Główne pętle
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    UpdateESP()
end)

RunService.RenderStepped:Connect(AimBot)

-- Destroy function
_G.AimBotScript = {
    Destroy = function()
        StopSilentAim()

        if FOVCircle then
            FOVCircle:Remove()
        end

        if _G.ArsenalScriptUsers and _G.ArsenalScriptUsers[LocalPlayer.Name] then
            _G.ArsenalScriptUsers[LocalPlayer.Name] = nil
        end

        for player, drawings in pairs(ESPDrawings) do
            RemoveESP(player)
        end

        for _, connection in pairs(getconnections(RunService.RenderStepped)) do
            connection:Disconnect()
        end

        if Window then
            Window:Destroy()
        end
        
        _G.AimBotScript = nil

        print("Arsenal Script destroyed")
    end
}