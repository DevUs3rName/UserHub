local HttpService = game:GetService("HttpService")

local GITHUB_RAW_URL = "https://raw.githubusercontent.com/DevUs3rName/UserHub/main/"
local GAMES_JSON_URL = GITHUB_RAW_URL .. "games.json"

local function getScriptContent(scriptName)
    local url = GITHUB_RAW_URL .. "Games/" .. scriptName .. ".lua"
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result then
        return result
    else
        return nil
    end
end

local function loadGamesList()
    local success, result = pcall(function()
        return game:HttpGet(GAMES_JSON_URL)
    end)
    
    if success and result then
        local data = HttpService:JSONDecode(result)
        return data.games or {}
    else
        return {}
    end
end

local function getCurrentGameId()
    return tostring(game.PlaceId)
end

local function executeScript(scriptName)
    local scriptContent = getScriptContent(scriptName)
    if scriptContent then
        loadstring(scriptContent)()
        return true
    end
    return false
end

local function loadScript()
    local games = loadGamesList()
    local currentPlaceId = getCurrentGameId()
    local foundGame = nil

    for _, gameData in ipairs(games) do
        if tostring(gameData.gameId) == currentPlaceId then
            foundGame = gameData
            break
        end
    end

    if foundGame then
        print("[UserHub] Found script for: " .. foundGame.name)
        local success = executeScript(foundGame.id)
        if success then
            print("[UserHub] Loaded: " .. foundGame.name)
        else
            warn("[UserHub] Failed to load script: " .. foundGame.id)
        end
    else
        print("[UserHub] No script found for this game (PlaceId: " .. currentPlaceId .. ")")
    end
end

local function createKeyGUI()
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UserHubKeySystem"
    screenGui.Parent = Player.PlayerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 350, 0, 220)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = mainFrame
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "UserHub Key System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Parent = mainFrame
    subtitle.Size = UDim2.new(1, -40, 0, 25)
    subtitle.Position = UDim2.new(0, 20, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter your key to continue"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 170)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    
    local keyBox = Instance.new("TextBox")
    keyBox.Name = "KeyBox"
    keyBox.Parent = mainFrame
    keyBox.Size = UDim2.new(0.8, 0, 0, 40)
    keyBox.Position = UDim2.new(0.1, 0, 0, 105)
    keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    keyBox.BackgroundTransparency = 0.3
    keyBox.BorderSizePixel = 0
    keyBox.Text = ""
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.TextSize = 16
    keyBox.Font = Enum.Font.Gotham
    keyBox.PlaceholderText = "Enter key here..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    keyBox.ClearTextOnFocus = false
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.Parent = keyBox
    keyCorner.CornerRadius = UDim.new(0, 8)
    
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Parent = mainFrame
    submitButton.Size = UDim2.new(0.5, 0, 0, 40)
    submitButton.Position = UDim2.new(0.25, 0, 0, 160)
    submitButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Submit"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.GothamBold
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.Parent = submitButton
    submitCorner.CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = mainFrame
    statusLabel.Size = UDim2.new(1, -40, 0, 25)
    statusLabel.Position = UDim2.new(0, 20, 0, 195)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local function verifyKey(inputKey)
        return inputKey == "420Userhubthebest69"
    end
    
    submitButton.MouseButton1Click:Connect(function()
        local inputKey = keyBox.Text
        if verifyKey(inputKey) then
            statusLabel.Text = "Key accepted! Loading..."
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            task.wait(0.5)
            screenGui:Destroy()
            loadScript()
        else
            statusLabel.Text = "Invalid key! Please try again."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            keyBox.Text = ""
        end
    end)
    
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submitButton.MouseButton1Click:Fire()
        end
    end)
end

createKeyGUI()
