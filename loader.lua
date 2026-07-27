local HttpService = game:GetService("HttpService")

local GITHUB_RAW_URL = "https://raw.githubusercontent.com/DevUs3rName/UserHub/main/"
local GAMES_JSON_URL = GITHUB_RAW_URL .. "games.json"

local VALID_KEYS = {
    "420Userhubthebest69"
}

local function isValidKey(inputKey)
    for _, key in ipairs(VALID_KEYS) do
        if key == inputKey then
            return true
        end
    end
    return false
end

local function showKeyGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystem"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 180)
    frame.Position = UDim2.new(0.5, -175, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.95
    frame.Parent = screenGui
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "UserHub - Wpisz klucz"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 40)
    textBox.Position = UDim2.new(0.1, 0, 0, 60)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = "Wpisz swój klucz..."
    textBox.Text = ""
    textBox.Parent = frame
    
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.4, 0, 0, 35)
    confirmBtn.Position = UDim2.new(0.3, 0, 0, 115)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.TextSize = 16
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.Text = "Potwierdź"
    confirmBtn.Parent = frame
    
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, 0, 0, 25)
    errorLabel.Position = UDim2.new(0, 0, 0, 155)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorLabel.TextSize = 14
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.Parent = frame
    
    confirmBtn.MouseButton1Click:Connect(function()
        local key = textBox.Text
        if key ~= "" then
            if isValidKey(key) then
                screenGui:Destroy()
                loadMainScript()
            else
                errorLabel.Text = "❌ Nieprawidłowy klucz!"
                wait(2)
                errorLabel.Text = ""
            end
        else
            errorLabel.Text = "❌ Wpisz klucz!"
            wait(2)
            errorLabel.Text = ""
        end
    end)
end

local function loadMainScript()
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

showKeyGUI()
