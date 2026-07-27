local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

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
        warn("Nie znaleziono skryptu: " .. scriptName)
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
    local placeId = game.PlaceId
    return tostring(placeId)
end

local function executeScript(scriptName)
    local scriptContent = getScriptContent(scriptName)
    if scriptContent then
        loadstring(scriptContent)()
        return true
    end
    return false
end

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UserHubLoader"
    screenGui.Parent = Player.PlayerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 350, 0, 200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 16)
    
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Parent = mainFrame
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(-0.03, 0, -0.05, 0)
    glow.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.Parent = glow
    glowCorner.CornerRadius = UDim.new(0, 20)
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = mainFrame
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "UserHub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = mainFrame
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Szukanie skryptu dla tej gry..."
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local loadingBar = Instance.new("Frame")
    loadingBar.Name = "LoadingBar"
    loadingBar.Parent = mainFrame
    loadingBar.Size = UDim2.new(0.8, 0, 0, 4)
    loadingBar.Position = UDim2.new(0.1, 0, 0, 105)
    loadingBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    loadingBar.BorderSizePixel = 0
    
    local loadingBarCorner = Instance.new("UICorner")
    loadingBarCorner.Parent = loadingBar
    loadingBarCorner.CornerRadius = UDim.new(1, 0)
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Parent = loadingBar
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    progressBar.BorderSizePixel = 0
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.Parent = progressBar
    progressCorner.CornerRadius = UDim.new(1, 0)
    
    local gameNameLabel = Instance.new("TextLabel")
    gameNameLabel.Name = "GameNameLabel"
    gameNameLabel.Parent = mainFrame
    gameNameLabel.Size = UDim2.new(1, -40, 0, 25)
    gameNameLabel.Position = UDim2.new(0, 20, 0, 120)
    gameNameLabel.BackgroundTransparency = 1
    gameNameLabel.Text = ""
    gameNameLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    gameNameLabel.TextSize = 12
    gameNameLabel.Font = Enum.Font.Gotham
    gameNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = mainFrame
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(150, 150, 170)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.Gotham
    closeButton.BorderSizePixel = 0
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui, statusLabel, progressBar, gameNameLabel
end

local gui, statusLabel, progressBar, gameNameLabel = createGUI()

local games = loadGamesList()
local currentPlaceId = getCurrentGameId()
local foundGame = nil
local foundScript = nil

for _, gameData in ipairs(games) do
    if tostring(gameData.gameId) == currentPlaceId then
        foundGame = gameData
        break
    end
end

if foundGame then
    statusLabel.Text = "Znaleziono skrypt!"
    gameNameLabel.Text = foundGame.name
    
    for i = 1, 100 do
        progressBar.Size = UDim2.new(i / 100, 0, 1, 0)
        task.wait(0.005)
    end
    
    task.wait(0.2)
    
    statusLabel.Text = "Ladowanie..."
    task.wait(0.3)
    
    local success = executeScript(foundGame.id)
    
    if success then
        statusLabel.Text = "Zaladowano!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        task.wait(0.5)
        gui:Destroy()
    else
        statusLabel.Text = "Blad ladowania!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        progressBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
else
    statusLabel.Text = "Brak skryptu dla tej gry"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    gameNameLabel.Text = "Gra nie jest wspierana"
end
