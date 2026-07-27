local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Ustawienia GitHub
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/TwojeRepo/UserHub/main/"
local GAMES_JSON_URL = GITHUB_RAW_URL .. "games.json"

-- Funkcja do pobierania zawartości skryptu z GitHub
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

-- Funkcja do pobierania listy gier z GitHub
local function loadGamesList()
    local success, result = pcall(function()
        return game:HttpGet(GAMES_JSON_URL)
    end)
    
    if success and result then
        local data = HttpService:JSONDecode(result)
        return data.games or {}
    else
        warn("Nie można pobrać listy gier, używam domyślnej")
    end
end

-- Funkcja do wykonania skryptu
local function executeScript(scriptName)
    local scriptContent = getScriptContent(scriptName)
    if scriptContent then
        loadstring(scriptContent)()
        return true
    else
        warn("Nie znaleziono skryptu: " .. scriptName)
        return false
    end
end

-- Tworzenie GUI
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
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = titleBar
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = titleBar
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "UserHub Loader"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Parent = titleBar
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 1, -20)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Wybierz gre do zaladowania"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 170)
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Name = "LoadingLabel"
    loadingLabel.Parent = mainFrame
    loadingLabel.Size = UDim2.new(1, 0, 0, 30)
    loadingLabel.Position = UDim2.new(0, 0, 0, 55)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "Ladowanie listy gier..."
    loadingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingLabel.TextSize = 14
    loadingLabel.Font = Enum.Font.Gotham
    
    local gamesList = Instance.new("ScrollingFrame")
    gamesList.Name = "GamesList"
    gamesList.Parent = mainFrame
    gamesList.Size = UDim2.new(1, -20, 1, -110)
    gamesList.Position = UDim2.new(0, 10, 0, 90)
    gamesList.BackgroundTransparency = 1
    gamesList.BorderSizePixel = 0
    gamesList.ScrollBarThickness = 4
    gamesList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    gamesList.Visible = false
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = gamesList
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Przycisk zamknięcia
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = mainFrame
    closeButton.Size = UDim2.new(0, 80, 0, 35)
    closeButton.Position = UDim2.new(1, -95, 1, -48)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Zamknij"
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.Gotham
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Wczytaj gry
    local games = loadGamesList()
    
    loadingLabel.Visible = false
    gamesList.Visible = true
    
    for _, gameData in ipairs(games) do
        local gameButton = Instance.new("Frame")
        gameButton.Name = "GameButton_" .. gameData.id
        gameButton.Parent = gamesList
        gameButton.Size = UDim2.new(1, 0, 0, 80)
        gameButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        gameButton.BackgroundTransparency = 0.3
        gameButton.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = gameButton
        btnCorner.CornerRadius = UDim.new(0, 8)
        
        local gameName = Instance.new("TextLabel")
        gameName.Name = "GameName"
        gameName.Parent = gameButton
        gameName.Size = UDim2.new(1, -20, 0, 25)
        gameName.Position = UDim2.new(0, 10, 0, 8)
        gameName.BackgroundTransparency = 1
        gameName.Text = gameData.name
        gameName.TextColor3 = Color3.fromRGB(255, 255, 255)
        gameName.TextSize = 18
        gameName.Font = Enum.Font.GothamBold
        gameName.TextXAlignment = Enum.TextXAlignment.Left
        
        local gameDesc = Instance.new("TextLabel")
        gameDesc.Name = "GameDesc"
        gameDesc.Parent = gameButton
        gameDesc.Size = UDim2.new(1, -20, 0, 20)
        gameDesc.Position = UDim2.new(0, 10, 0, 35)
        gameDesc.BackgroundTransparency = 1
        gameDesc.Text = gameData.description or "Brak opisu"
        gameDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
        gameDesc.TextSize = 13
        gameDesc.Font = Enum.Font.Gotham
        gameDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local loadButton = Instance.new("TextButton")
        loadButton.Name = "LoadButton"
        loadButton.Parent = gameButton
        loadButton.Size = UDim2.new(0, 100, 0, 30)
        loadButton.Position = UDim2.new(1, -110, 1, -38)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
        loadButton.BorderSizePixel = 0
        loadButton.Text = "Zaladuj"
        loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadButton.TextSize = 14
        loadButton.Font = Enum.Font.GothamBold
        
        local loadCorner = Instance.new("UICorner")
        loadCorner.Parent = loadButton
        loadCorner.CornerRadius = UDim.new(0, 6)
        
        loadButton.MouseButton1Click:Connect(function()
            loadButton.Text = "Ladowanie..."
            loadButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            loadButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            
            local success = executeScript(gameData.id)
            if success then
                screenGui:Destroy()
            else
                loadButton.Text = "Blad"
                loadButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                task.wait(1)
                loadButton.Text = "Zaladuj"
                loadButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
                loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end
    
    return screenGui
end

createGUI()