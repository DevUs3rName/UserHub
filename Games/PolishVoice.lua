local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local VoiceChatInternal = game:GetService("VoiceChatInternal")
local VoiceChatService = game:GetService("VoiceChatService")
local UserInputService = game:GetService("UserInputService")

local targetPosition = Vector3.new(-95.81661987304688, 47.329925537109375, -981.8408203125)
local teleportInterval = 600

local isActive = false
local teleportTimer = 0
local originalPosition = nil
local isTeleporting = false

-- Voice Chat Variables
local voiceSettings = {
    ClickToSelect = false,
    HearAnywhere = false,
    Spy = false,
    HighlightVC = false,
    HighlightSelf = false,
    SpeakNotifications = false,
    DarkMode = false,
    SelectedPlayer = nil
}

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

-- ============ VOICE CHAT FUNCTIONS ============

local function GetVoiceParticipants()
    local participants = {}
    for _, userId in pairs(VoiceChatInternal:GetParticipants()) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            table.insert(participants, player)
        end
    end
    return participants
end

local function AddHighlight(character)
    if not character:FindFirstChild("Highlight") and voiceSettings.HighlightVC then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    end
end

local function RemoveHighlight(character)
    local highlight = character:FindFirstChild("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

local function UpdateHighlight(player)
    if not player or not player.Character then return end
    local char = player.Character
    
    if voiceSettings.HighlightVC then
        AddHighlight(char)
    else
        RemoveHighlight(char)
    end
end

local function CheckVoiceEnabled()
    return VoiceChatService:IsVoiceEnabledForUserIdAsync(Player.UserId)
end

local function SelectPlayer(player)
    voiceSettings.SelectedPlayer = player
    if player then
        Rayfield:Notify({
            Title = "Voice Chat",
            Content = "Wybrano: " .. player.Name,
            Duration = 3
        })
    end
end

-- ============ DARK MODE FUNCTIONS ============

local function ApplyDarkMode(enabled)
    if enabled then
        if game.Lighting:FindFirstChild("NiggaDArk") then
            game.Lighting.NiggaDArk:Destroy()
        end
        local darkPart = Instance.new("Part", game.Lighting)
        darkPart.Name = "NiggaDArk"
        
        if Player.PlayerGui:FindFirstChild("BubbleChat") then
            Player.PlayerGui:FindFirstChild("BubbleChat"):Destroy()
        end
        game.Chat.BubbleChatEnabled = true
        
        local settings = {
            BubbleDuration = 15,
            MaxBubbles = 3,
            BackgroundColor3 = Color3.fromRGB(1, 1, 1),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            Transparency = 0.1,
            CornerRadius = UDim.new(0, 12),
            TailVisible = true,
            Padding = 8,
            MaxWidth = 300,
            VerticalStudsOffset = 0,
            BubblesSpacing = 6,
            MinimizeDistance = 40,
            MaxDistance = 100
        }
        pcall(function()
            game:GetService("Chat"):SetBubbleChatSettings(settings)
        end)
        
        -- Dark mode loop
        task.spawn(function()
            while voiceSettings.DarkMode do
                task.wait()
                for _, bubble in pairs(game:GetService("CoreGui").ExperienceChat.bubbleChat:GetChildren()) do
                    if bubble:IsA("BillboardGui") and bubble:FindFirstChild("PlayerButtons") then
                        bubble.PlayerButtons.BackgroundColor3 = Color3.fromRGB(1, 1, 1)
                        bubble.PlayerButtons.Carat.ImageColor3 = Color3.fromRGB(1, 1, 1)
                    end
                end
            end
        end)
    else
        if game.Lighting:FindFirstChild("NiggaDArk") then
            game.Lighting.NiggaDArk:Destroy()
        end
        game.Chat.BubbleChatEnabled = true
        
        local settings = {
            BubbleDuration = 15,
            MaxBubbles = 3,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            TextColor3 = Color3.fromRGB(1, 1, 1),
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            Transparency = 0.1,
            CornerRadius = UDim.new(0, 12),
            TailVisible = true,
            Padding = 8,
            MaxWidth = 300,
            VerticalStudsOffset = 0,
            BubblesSpacing = 6,
            MinimizeDistance = 40,
            MaxDistance = 100
        }
        pcall(function()
            game:GetService("Chat"):SetBubbleChatSettings(settings)
        end)
        
        -- Reset bubble colors
        for _, bubble in pairs(game:GetService("CoreGui").ExperienceChat.bubbleChat:GetChildren()) do
            if bubble:IsA("BillboardGui") and bubble:FindFirstChild("PlayerButtons") then
                bubble.PlayerButtons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                bubble.PlayerButtons.Carat.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end

-- ============ VOICE EVENTS ============

-- Handle voice participant highlighting
VoiceChatInternal.ParticipantsStateChanged:Connect(function(ac, ad, ae)
    for _, data in pairs(ae) do
        local userId = data.userId
        local isActive = data.isSignalActive
        local player = Players:GetPlayerByUserId(userId)
        
        if player and player.Character and voiceSettings.HighlightVC then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if highlight then
                if isActive then
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                else
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end)

-- Handle self highlight
VoiceChatInternal.PlayerMicActivitySignalChange:Connect(function(data)
    local isActive = data.isActive
    
    if voiceSettings.HighlightSelf and Player.Character then
        local highlight = Player.Character:FindFirstChildOfClass("Highlight")
        if highlight then
            if isActive then
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end)

-- Click to select player
UserInputService.InputBegan:connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and 
       UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 
       voiceSettings.ClickToSelect then
        
        local mouse = Player:GetMouse()
        local target = mouse.Target
        
        if target and target.Parent then
            local selectedPlayer = Players:GetPlayerFromCharacter(target.Parent)
            if selectedPlayer and selectedPlayer ~= Player then
                SelectPlayer(selectedPlayer)
            end
        end
    end
end)

-- Auto-highlight new players
Players.PlayerAdded:Connect(function(player)
    if voiceSettings.HighlightVC then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            UpdateHighlight(player)
        end)
    end
end)

-- ============ GAME NAME ============
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Roblox"

-- ============ RAYFIELD WINDOW ============
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

-- ============ MAIN TAB (AutoFarm) ============
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

-- ============ TELEPORTS TAB ============
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

-- ============ VOICE CHAT TAB ============
local VoiceTab = Window:CreateTab("Voice Chat", 2)

-- Voice Section
local VoiceSection = VoiceTab:CreateSection("Voice Chat Controls")

-- Get participants for dropdown
local function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

VoiceTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    CurrentOption = "",
    Callback = function(option)
        local selected = Players:FindFirstChild(option)
        if selected then
            SelectPlayer(selected)
        end
    end
})

VoiceTab:CreateToggle({
    Name = "Click to Select (CTRL + Click)",
    CurrentValue = false,
    Flag = "ClickToSelect",
    Callback = function(Value)
        voiceSettings.ClickToSelect = Value
        if Value then
            Rayfield:Notify({
                Title = "Voice Chat",
                Content = "Kliknij gracza z CTRL aby wybrać",
                Duration = 3
            })
        end
    end
})

VoiceTab:CreateToggle({
    Name = "Hear Anywhere",
    CurrentValue = false,
    Flag = "HearAnywhere",
    Callback = function(Value)
        voiceSettings.HearAnywhere = Value
        if Value then
            local soundPart = Instance.new("Part", workspace)
            soundPart.Name = "SoundInf"
            soundPart.Size = Vector3.new(10e10, 10e10, 10e10)
            soundPart.Anchored = true
            soundPart.CanCollide = false
            soundPart.Transparency = 1
            soundPart.CFrame = HumanoidRootPart.CFrame
            
            game:GetService("SoundService"):SetListener(Enum.ListenerType.ObjectPosition, soundPart)
        else
            if workspace:FindFirstChild("SoundInf") then
                workspace.SoundInf:Destroy()
            end
            game:GetService("SoundService"):SetListener(Enum.ListenerType.Camera)
        end
    end
})

VoiceTab:CreateToggle({
    Name = "Spy",
    CurrentValue = false,
    Flag = "Spy",
    Callback = function(Value)
        voiceSettings.Spy = Value
        if Value and voiceSettings.SelectedPlayer then
            local target = voiceSettings.SelectedPlayer
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                game:GetService("SoundService"):SetListener(Enum.ListenerType.ObjectPosition, target.Character.HumanoidRootPart)
                Rayfield:Notify({
                    Title = "Voice Chat",
                    Content = "Szpiegujesz: " .. target.Name,
                    Duration = 3
                })
            end
        else
            if not voiceSettings.HearAnywhere then
                game:GetService("SoundService"):SetListener(Enum.ListenerType.Camera)
            end
        end
    end
})

VoiceTab:CreateToggle({
    Name = "Highlight VC Players",
    CurrentValue = false,
    Flag = "HighlightVC",
    Callback = function(Value)
        voiceSettings.HighlightVC = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    AddHighlight(player.Character)
                end
                player.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if voiceSettings.HighlightVC then
                        AddHighlight(char)
                    end
                end)
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    RemoveHighlight(player.Character)
                end
            end
        end
    end
})

VoiceTab:CreateToggle({
    Name = "Highlight Self",
    CurrentValue = false,
    Flag = "HighlightSelf",
    Callback = function(Value)
        voiceSettings.HighlightSelf = Value
        if Value and Player.Character then
            AddHighlight(Player.Character)
        elseif not Value and Player.Character then
            RemoveHighlight(Player.Character)
        end
    end
})

VoiceTab:CreateToggle({
    Name = "Speaking Notifications",
    CurrentValue = false,
    Flag = "SpeakNotifications",
    Callback = function(Value)
        voiceSettings.SpeakNotifications = Value
    end
})

VoiceTab:CreateToggle({
    Name = "Dark Mode",
    CurrentValue = false,
    Flag = "DarkMode",
    Callback = function(Value)
        voiceSettings.DarkMode = Value
        ApplyDarkMode(Value)
    end
})

VoiceTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        local options = GetPlayerList()
        -- Refresh dropdown (implementation depends on Rayfield version)
        Rayfield:Notify({
            Title = "Voice Chat",
            Content = "Lista odświeżona!",
            Duration = 2
        })
    end
})

-- ============ HEARTBEAT LOOP ============
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
