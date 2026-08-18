-- Faithful split from the uploaded original sB Hub source.
Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
VirtualInputManager = game:GetService("VirtualInputManager")
VirtualUser = game:GetService("VirtualUser")
ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")
Stats = game:GetService("Stats")

player = Players.LocalPlayer
playerGui = player:WaitForChild("PlayerGui")
backpack = player:WaitForChild("Backpack")
leaderstats = player:WaitForChild("leaderstats")

strength = leaderstats:WaitForChild("Strength")
rebirths = leaderstats:WaitForChild("Rebirths")

running = true
guiOpen = true

state = {
    autoTrain = false,
    autoRebirth = false,
    rebirthLimit = false,
    rebirthTarget = 1000,

    autoJungleRock = false,
    autoEgg = false,
    autoUltimates = false,

    autoSize = false,
    autoSpeed = false,
    sizeMode = "Max",
    speedMode = "Max",
    sizeCustom = 2,
    speedCustom = 93,

    skipRebirthAnimation = false,
    antiAFK = false,

    esp = false,
    espBoxes = true,
    espNames = true,
    espDistance = true,
    espHealth = true,
    espTracers = false,
    espTeamCheck = false,
    espMaxDistance = 1500,

    coords = false,
    coordsCompass = true,
    coordsHeading = true,
    coordsPitch = true,

    automationOverlay = true,
    performanceOverlay = true,

    notifications = true,
    petNotifications = true,
    auraNotifications = true,
    rarityNotifications = true,

    rareBasic = false,
    rareRare = false,
    rareEpic = true,
    rareUnique = true,
    rareAdvanced = true,

    serverSpyAutoRefresh = true,

    muteStrength = false,
    muteRebirth = false,
}

goal = {
    type = "Strength",
    target = 100000000,
    enabled = false,
}

hotkeys = {
    autoTrain = nil,
    autoRebirth = nil,
    rebirthLimit = nil,
    autoJungleRock = nil,
    autoEgg = nil,
    autoUltimates = nil,
    autoSize = nil,
    autoSpeed = nil,
    skipRebirthAnimation = nil,
    antiAFK = nil,
    esp = nil,
    coords = nil,
    automationOverlay = nil,
    performanceOverlay = nil,
    notifications = nil,
    autoPetNotifications = nil,
    autoAuraNotifications = nil,
}

selectedPets = {}
selectedAuras = {}

sessionStart = os.clock()
startingStrength = tonumber(strength.Value) or 0
startingRebirths = tonumber(rebirths.Value) or 0

gems = player:FindFirstChild("Gems")
durability = player:FindFirstChild("Durability")
startingDurability = durability and tonumber(durability.Value) or 0

character
humanoid
root
gameGui
rebirthButton

currentExercise = "None"
currentRock = "OFF"
currentUltimate = "Idle"

junglePositioned = false
jungleBillboard

connections = {}
espEntries = {}
notifications = {}
notificationFeed = {}

crystalStats = {
    opened = 0,
    selectedPetHits = 0,
    selectedAuraHits = 0,
    rarityHits = 0,
}

lastStrength = startingStrength
lastRebirths = startingRebirths
lastDurability = startingDurability

petReferenceSnapshot = {}
auraReferenceSnapshot = {}
pendingCrystalWindow = 0

currentServerPlayer = nil
hotkeyCapture = nil

fps = 0
frameCounter = 0
lastFpsTime = os.clock()

GlobalFunctions

pcall(function()
    GlobalFunctions = require(
        ReplicatedStorage
            :WaitForChild("shared")
            :WaitForChild("modules")
            :WaitForChild("GlobalFunctions")
    )
end)

GUI_COLORS = {
    bg = Color3.fromRGB(18, 18, 21),
    panel = Color3.fromRGB(24, 24, 28),
    panel2 = Color3.fromRGB(30, 30, 35),
    group = Color3.fromRGB(22, 22, 26),
    border = Color3.fromRGB(57, 57, 65),
    text = Color3.fromRGB(225, 225, 230),
    muted = Color3.fromRGB(150, 150, 158),
    blue = Color3.fromRGB(73, 143, 215),
    green = Color3.fromRGB(90, 220, 120),
    red = Color3.fromRGB(230, 90, 90),
    yellow = Color3.fromRGB(235, 200, 90),
    off = Color3.fromRGB(43, 43, 49),
    danger = Color3.fromRGB(95, 40, 44),
}

ESP_COLORS = {
    box = Color3.fromRGB(73, 143, 215),
    text = Color3.fromRGB(240, 240, 244),
    tracer = Color3.fromRGB(73, 143, 215),
    health = Color3.fromRGB(90, 220, 120),
}

FONT = Enum.Font.Code

saveName = "sBHub_v1_Settings.json"

function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

function safe(fn, ...)
    if typeof(fn) ~= "function" then
        return false
    end
    return pcall(fn, ...)
end

function fire(signal)
    if typeof(firesignal) ~= "function" then
        return false
    end
    return pcall(firesignal, signal)
end

function fmt(value)
    value = tonumber(value) or 0
    local a = math.abs(value)

    if a >= 1e12 then
        return string.format("%.2fT", value / 1e12)
    elseif a >= 1e9 then
        return string.format("%.2fB", value / 1e9)
    elseif a >= 1e6 then
        return string.format("%.2fM", value / 1e6)
    elseif a >= 1e3 then
        return string.format("%.2fK", value / 1e3)
    end

    return string.format("%.0f", value)
end

function formatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return string.format(
        "%02d:%02d:%02d",
        math.floor(seconds / 3600),
        math.floor(seconds / 60) % 60,
        seconds % 60
    )
end

function rankToText(rank)
    return tostring(rank or "Unknown")
end

function saveConfig()
    local data = {
        state = state,
        goal = goal,
        hotkeys = hotkeys,
        selectedPets = selectedPets,
        selectedAuras = selectedAuras,
    }

    local ok, encoded = pcall(
        HttpService.JSONEncode,
        HttpService,
        data
    )

    if not ok then
        return
    end

    if typeof(writefile) == "function" then
        pcall(function()
            writefile(saveName, encoded)
        end)
    end

    local env = getgenv and getgenv()

    if env then
        env.sBHubSavedConfig = data
    end
end

function loadConfig()
    local data

    local env = getgenv and getgenv()

    if env and env.sBHubSavedConfig then
        data = env.sBHubSavedConfig
    end

    if not data and typeof(isfile) == "function"
        and typeof(readfile) == "function"
        and isfile(saveName) then

        local ok, raw = pcall(readfile, saveName)

        if ok and raw then
            local decodedOk, decoded =
                pcall(
                    HttpService.JSONDecode,
                    HttpService,
                    raw
                )

            if decodedOk then
                data = decoded
            end
        end
    end

    if type(data) ~= "table" then
        return
    end

    if type(data.state) == "table" then
        for key, value in pairs(data.state) do
            if state[key] ~= nil then
                state[key] = value
            end
        end
    end

    if type(data.goal) == "table" then
        for key, value in pairs(data.goal) do
            if goal[key] ~= nil then
                goal[key] = value
            end
        end
    end

    if type(data.hotkeys) == "table" then
        for key, value in pairs(data.hotkeys) do
            if hotkeys[key] ~= nil then
                hotkeys[key] = value
            end
        end
    end

    if type(data.selectedPets) == "table" then
        selectedPets = data.selectedPets
    end

    if type(data.selectedAuras) == "table" then
        selectedAuras = data.selectedAuras
    end
end

loadConfig()

-- module end
