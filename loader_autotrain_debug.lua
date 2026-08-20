-- sB Hub v1 - Auto Train diagnostic build
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

sBHubAlive = false
running = false
pcall(function()
    if type(connections) == "table" then
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        table.clear(connections)
    end
end)
for _, name in ipairs({"sB_Hub_v1", "sB_Overlays"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end
sBHubAlive = true
running = true

local function download(name)
    local url = BASE .. name .. "?v=" .. tostring(math.floor(os.clock() * 1000000))
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if not ok then error("[sB Debug] download failed: " .. name .. "\n" .. tostring(result)) end
    return result
end

local function loadModule(name)
    local source = download(name)
    source = source:gsub("while running do", function() return "while running and sBHubAlive do" end)
    local chunk, err = loadstring(source, "@" .. name)
    if not chunk then error("[sB Debug] compile failed: " .. name .. "\n" .. tostring(err)) end
    local ok, result = pcall(chunk)
    if not ok then error("[sB Debug] runtime failed: " .. name .. "\n" .. tostring(result)) end
end

-- runtime.lua must load before automation.lua because it defines the shared
-- refreshCharacter/findExercise runtime used by Auto Train.
for _, name in ipairs({"config.lua", "ui_click.lua", "stats.lua", "overlays.lua", "notifications.lua", "spy.lua", "esp.lua", "runtime.lua", "automation.lua"}) do
    loadModule(name)
end

local gui = playerGui:FindFirstChild("sB_Hub_v1")
if not gui then error("[sB Debug] GUI missing") end
window = window or gui:FindFirstChildWhichIsA("Frame")
if not window then error("[sB Debug] window missing") end
window.Visible = true
window.Active = true
window.Draggable = true
window.ZIndex = 1000
if tabBar then tabBar.Visible = true end
if content then content.Visible = true end
if type(showTab) == "function" then pcall(function() showTab("main") end) end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("GuiButton") then
        object.Active = false
        pcall(function() object.Interactable = false end)
    end
end
local clickConnections = {}
local function surface(target, callback, name)
    if not target or not target.Parent then return end
    local f = Instance.new("Frame")
    f.Name = "sB_DebugClick_" .. tostring(name or target.Name)
    f.Size = target.Size
    f.Position = target.Position
    f.AnchorPoint = target.AnchorPoint
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Active = true
    f.ZIndex = (target.ZIndex or 1) + 10
    f.Parent = target.Parent
    table.insert(clickConnections, f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then pcall(callback) end
    end))
end
for tabName, button in pairs(tabs or {}) do surface(button, function() showTab(tabName) end, "Tab_" .. tabName) end
local toggleMap = {
 ["auto train"]="autoTrain", ["auto rebirth"]="autoRebirth", ["rebirth limit"]="rebirthLimit", ["skip rebirth animation"]="skipRebirthAnimation",
 ["auto jungle rock"]="autoJungleRock", ["auto egg"]="autoEgg", ["auto ultimates"]="autoUltimates", ["auto size"]="autoSize", ["auto speed"]="autoSpeed",
 ["notifications"]="notifications", ["pet notifications"]="petNotifications", ["aura notifications"]="auraNotifications", ["rarity alerts"]="rarityNotifications",
 ["basic"]="rareBasic", ["rare"]="rareRare", ["epic"]="rareEpic", ["unique"]="rareUnique", ["advanced"]="rareAdvanced",
 ["esp"]="esp", ["boxes"]="espBoxes", ["names"]="espNames", ["distance"]="espDistance", ["health"]="espHealth", ["tracers"]="espTracers", ["team check"]="espTeamCheck",
 ["coordinates"]="coords", ["compass"]="coordsCompass", ["heading"]="coordsHeading", ["pitch"]="coordsPitch", ["auto refresh"]="serverSpyAutoRefresh",
 ["automation status"]="automationOverlay", ["performance monitor"]="performanceOverlay", ["anti afk"]="antiAFK", ["mute strength"]="muteStrength", ["mute rebirth"]="muteRebirth"
}
for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("TextButton") then
        local label = object:FindFirstChildWhichIsA("TextLabel")
        local box = object:FindFirstChildWhichIsA("Frame")
        local key = label and toggleMap[string.lower(label.Text or "")]
        if key and box then
            surface(object, function()
                state[key] = not state[key]
                box.BackgroundColor3 = state[key] and GUI_COLORS.blue or GUI_COLORS.off
                box.BorderColor3 = state[key] and GUI_COLORS.blue or GUI_COLORS.border
                pcall(saveConfig)
            end, "Toggle_" .. key)
        end
    end
end

local debug = Instance.new("TextLabel")
debug.Name = "sB_AutoTrainDebug"
debug.Size = UDim2.fromOffset(360, 105)
debug.AnchorPoint = Vector2.new(0, 1)
debug.Position = UDim2.new(0, 8, 1, -8)
debug.BackgroundColor3 = GUI_COLORS.panel
debug.BackgroundTransparency = 0.08
debug.BorderSizePixel = 1
debug.BorderColor3 = GUI_COLORS.border
debug.TextColor3 = GUI_COLORS.text
debug.TextSize = 10
debug.Font = Enum.Font.Code
debug.TextXAlignment = Enum.TextXAlignment.Left
debug.TextYAlignment = Enum.TextYAlignment.Top
debug.ZIndex = 5000
-- Parent to the actual main window so it is the bottom-left of the hub.
debug.Parent = window

local function val(obj)
    return obj and tostring(obj.Value) or "nil"
end

task.spawn(function()
    while running and sBHubAlive do
        task.wait(0.25)
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp = player:FindFirstChildOfClass("Backpack")
        local toolNames = {}
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") then table.insert(toolNames, t.Name) end
            end
        end
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then table.insert(toolNames, "[EQUIPPED] " .. t.Name) end
            end
        end
        debug.Text =
            "AUTO TRAIN DEBUG\n" ..
            "state.autoTrain: " .. tostring(state.autoTrain) .. "\n" ..
            "running: " .. tostring(running) .. " / alive: " .. tostring(sBHubAlive) .. "\n" ..
            "character: " .. tostring(char and char.Name or "nil") .. "\n" ..
            "humanoid: " .. tostring(hum ~= nil) .. "\n" ..
            "currentExercise: " .. tostring(currentExercise) .. "\n" ..
            "strength: " .. val(strength) .. "\n" ..
            "tools: " .. (#toolNames > 0 and table.concat(toolNames, ", ") or "NONE")
    end
end)

if titleBar then
    local kill = Instance.new("Frame")
    kill.Size = UDim2.fromOffset(84, 24)
    kill.Position = UDim2.fromOffset(276, 5)
    kill.BackgroundColor3 = GUI_COLORS.danger
    kill.BorderSizePixel = 1
    kill.Active = true
    kill.ZIndex = 5001
    kill.Parent = titleBar
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1,1)
    t.BackgroundTransparency = 1
    t.Text = "KILL HUB"
    t.TextColor3 = GUI_COLORS.text
    t.TextSize = 10
    t.Font = Enum.Font.Code
    t.Parent = kill
    kill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sBHubAlive = false
            running = false
            for _, c in ipairs(clickConnections) do pcall(function() c:Disconnect() end) end
            if gui and gui.Parent then gui:Destroy() end
            print("[sB Debug] killed")
        end
    end)
end

pcall(refreshCharacter)
print("[sB Debug] Runtime-before-automation diagnostic loaded")
