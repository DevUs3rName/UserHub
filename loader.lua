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
