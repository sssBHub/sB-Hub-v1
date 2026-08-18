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

state = {}
state.autoTrain = false
state.autoRebirth = false
state.rebirthLimit = false
state.rebirthTarget = 1000
state.autoJungleRock = false
state.autoEgg = false
state.autoUltimates = false
state.autoSize = false
state.autoSpeed = false
state.sizeMode = "Max"
state.speedMode = "Max"
state.sizeCustom = 2
state.speedCustom = 93
state.skipRebirthAnimation = false
state.antiAFK = false
state.esp = false
state.espBoxes = true
state.espNames = true
state.espDistance = true
state.espHealth = true
state.espTracers = false
state.espTeamCheck = false
state.espMaxDistance = 1500
state.coords = false
state.coordsCompass = true
state.coordsHeading = true
state.coordsPitch = true
state.automationOverlay = true
state.performanceOverlay = true
state.notifications = true
state.petNotifications = true
state.auraNotifications = true
state.rarityNotifications = true
state.rareBasic = false
state.rareRare = false
state.rareEpic = true
state.rareUnique = true
state.rareAdvanced = true
state.serverSpyAutoRefresh = true
state.muteStrength = false
state.muteRebirth = false

goal = {}
goal.type = "Strength"
goal.target = 100000000
goal.enabled = false

hotkeys = {}
hotkeys.autoTrain = nil
hotkeys.autoRebirth = nil
hotkeys.rebirthLimit = nil
hotkeys.autoJungleRock = nil
hotkeys.autoEgg = nil
hotkeys.autoUltimates = nil
hotkeys.autoSize = nil
hotkeys.autoSpeed = nil
hotkeys.skipRebirthAnimation = nil
hotkeys.antiAFK = nil
hotkeys.esp = nil
hotkeys.coords = nil
hotkeys.automationOverlay = nil
hotkeys.performanceOverlay = nil
hotkeys.notifications = nil
hotkeys.autoPetNotifications = nil
hotkeys.autoAuraNotifications = nil

selectedPets = {}
selectedAuras = {}
sessionStart = os.clock()
startingStrength = tonumber(strength.Value) or 0
startingRebirths = tonumber(rebirths.Value) or 0
gems = player:FindFirstChild("Gems")
durability = player:FindFirstChild("Durability")
startingDurability = 0
if durability then
    startingDurability = tonumber(durability.Value) or 0
end

character = nil
humanoid = nil
root = nil
gameGui = nil
rebirthButton = nil
currentExercise = "None"
currentRock = "OFF"
currentUltimate = "Idle"
junglePositioned = false
jungleBillboard = nil
connections = {}
espEntries = {}
notifications = {}
notificationFeed = {}
crystalStats = {}
crystalStats.opened = 0
crystalStats.selectedPetHits = 0
crystalStats.selectedAuraHits = 0
crystalStats.rarityHits = 0
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
GlobalFunctions = nil

pcall(function()
    GlobalFunctions = require(
        ReplicatedStorage:WaitForChild("shared")
            :WaitForChild("modules")
            :WaitForChild("GlobalFunctions")
    )
end)

GUI_COLORS = {}
GUI_COLORS.bg = Color3.fromRGB(18, 18, 21)
GUI_COLORS.panel = Color3.fromRGB(24, 24, 28)
GUI_COLORS.panel2 = Color3.fromRGB(30, 30, 35)
GUI_COLORS.group = Color3.fromRGB(22, 22, 26)
GUI_COLORS.border = Color3.fromRGB(57, 57, 65)
GUI_COLORS.text = Color3.fromRGB(225, 225, 230)
GUI_COLORS.muted = Color3.fromRGB(150, 150, 158)
GUI_COLORS.blue = Color3.fromRGB(73, 143, 215)
GUI_COLORS.green = Color3.fromRGB(90, 220, 120)
GUI_COLORS.red = Color3.fromRGB(230, 90, 90)
GUI_COLORS.yellow = Color3.fromRGB(235, 200, 90)
GUI_COLORS.off = Color3.fromRGB(43, 43, 49)
GUI_COLORS.danger = Color3.fromRGB(95, 40, 44)

ESP_COLORS = {}
ESP_COLORS.box = Color3.fromRGB(73, 143, 215)
ESP_COLORS.text = Color3.fromRGB(240, 240, 244)
ESP_COLORS.tracer = Color3.fromRGB(73, 143, 215)
ESP_COLORS.health = Color3.fromRGB(90, 220, 120)
FONT = Enum.Font.Code
saveName = "sBHub_v1_Settings.json"

function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

function safe(fn, ...)
    if type(fn) ~= "function" then
        return false
    end
    return pcall(fn, ...)
end

function fire(signal)
    if type(firesignal) ~= "function" then
        return false
    end
    return pcall(firesignal, signal)
end

function fmt(value)
    value = tonumber(value) or 0
    local a = math.abs(value)
    if a >= 1000000000000 then
        return string.format("%.2fT", value / 1000000000000)
    elseif a >= 1000000000 then
        return string.format("%.2fB", value / 1000000000)
    elseif a >= 1000000 then
        return string.format("%.2fM", value / 1000000)
    elseif a >= 1000 then
        return string.format("%.2fK", value / 1000)
    end
    return string.format("%.0f", value)
end

function formatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor(seconds / 60) % 60
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

function rankToText(rank)
    return tostring(rank or "Unknown")
end

function saveConfig()
    local data = {}
    data.state = state
    data.goal = goal
    data.hotkeys = hotkeys
    data.selectedPets = selectedPets
    data.selectedAuras = selectedAuras
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then
        return
    end
    if type(writefile) == "function" then
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
    local data = nil
    local env = getgenv and getgenv()
    if env and env.sBHubSavedConfig then
        data = env.sBHubSavedConfig
    end
    if not data and type(isfile) == "function" and type(readfile) == "function" then
        if isfile(saveName) then
            local ok, raw = pcall(readfile, saveName)
            if ok and raw then
                local good, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
                if good then
                    data = decoded
                end
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
