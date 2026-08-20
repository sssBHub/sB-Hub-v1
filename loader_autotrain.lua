-- sB Hub v1 - isolated Auto Train loader
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
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

local function loadModule(name)
    print("[sB Hub] Downloading:", name)
    local url = BASE .. name .. "?v=" .. tostring(os.time())
    local source
    local lastError
    for attempt = 1, 4 do
        local ok, result = pcall(function() return game:HttpGet(url) end)
        if ok and type(result) == "string" and #result > 0 then
            source = result
            break
        end
        lastError = result
        if attempt < 4 then task.wait(0.5 * attempt) end
    end
    if not source then error("[sB Hub] Download failed: " .. name .. "\n" .. tostring(lastError)) end
    source = source:gsub("while running do", function() return "while running and sBHubAlive do" end)
    local chunk, err = loadstring(source, "@" .. name)
    if not chunk then error("[sB Hub] Compile failed: " .. name .. "\n" .. tostring(err)) end
    local ok, result = pcall(chunk)
    if not ok then error("[sB Hub] Runtime error: " .. name .. "\n" .. tostring(result)) end
    print("[sB Hub] Downloaded:", name, #source, "bytes")
    return result
end

-- Deliberately omit runtime.lua for this Auto Train test.
for _, name in ipairs({
    "config.lua", "ui_click.lua", "stats.lua", "overlays.lua",
    "notifications.lua", "spy.lua", "esp.lua", "automation.lua"
}) do
    loadModule(name)
end

local gui = playerGui:FindFirstChild("sB_Hub_v1")
assert(gui, "[sB Hub] GUI missing")
gui.Enabled = true
gui.DisplayOrder = 100000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
window = window or gui:FindFirstChildWhichIsA("Frame")
assert(window, "[sB Hub] Main window missing")
window.Visible = true
window.Active = true
window.Draggable = true
window.ZIndex = 1000
if tabBar then tabBar.Visible = true; tabBar.ZIndex = 1001 end
if content then content.Visible = true; content.ZIndex = 1000 end
if type(showTab) == "function" then pcall(function() showTab("main") end) end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("GuiButton") then
        object.Active = false
        pcall(function() object.Interactable = false end)
    end
end

local clickConnections = {}
local function addSurface(target, callback, name)
    if not target or not target.Parent then return end
    local surface = Instance.new("Frame")
    surface.Name = "sB_Click_" .. tostring(name or target.Name)
    surface.Size = target.Size
    surface.Position = target.Position
    surface.AnchorPoint = target.AnchorPoint
    surface.BackgroundTransparency = 1
    surface.BorderSizePixel = 0
    surface.Active = true
    surface.Visible = true
    surface.ZIndex = math.max(1000, (target.ZIndex or 1) + 10)
    surface.Parent = target.Parent
    table.insert(clickConnections, surface.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and sBHubAlive then
            local ok, err = pcall(callback)
            if not ok then warn("[sB Hub] Click error:", tostring(name), tostring(err)) end
        end
    end))
end

for tabName, button in pairs(tabs or {}) do
    addSurface(button, function() showTab(tabName) end, "Tab_" .. tabName)
end

local toggleMap = {
    ["auto train"]="autoTrain", ["auto rebirth"]="autoRebirth", ["rebirth limit"]="rebirthLimit",
    ["skip rebirth animation"]="skipRebirthAnimation", ["auto jungle rock"]="autoJungleRock",
    ["auto egg"]="autoEgg", ["auto ultimates"]="autoUltimates", ["auto size"]="autoSize", ["auto speed"]="autoSpeed",
    ["notifications"]="notifications", ["pet notifications"]="petNotifications", ["aura notifications"]="auraNotifications",
    ["rarity alerts"]="rarityNotifications", ["basic"]="rareBasic", ["rare"]="rareRare", ["epic"]="rareEpic",
    ["unique"]="rareUnique", ["advanced"]="rareAdvanced", ["esp"]="esp", ["boxes"]="espBoxes", ["names"]="espNames",
    ["distance"]="espDistance", ["health"]="espHealth", ["tracers"]="espTracers", ["team check"]="espTeamCheck",
    ["coordinates"]="coords", ["compass"]="coordsCompass", ["heading"]="coordsHeading", ["pitch"]="coordsPitch",
    ["auto refresh"]="serverSpyAutoRefresh", ["automation status"]="automationOverlay", ["performance monitor"]="performanceOverlay",
    ["anti afk"]="antiAFK", ["mute strength"]="muteStrength", ["mute rebirth"]="muteRebirth"
}

local function renderToggle(button, key)
    local box = button:FindFirstChildWhichIsA("Frame")
    if box then
        local on = state[key] == true
        box.BackgroundColor3 = on and GUI_COLORS.blue or GUI_COLORS.off
        box.BorderColor3 = on and GUI_COLORS.blue or GUI_COLORS.border
    end
end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("TextButton") then
        local label = object:FindFirstChildWhichIsA("TextLabel")
        local box = object:FindFirstChildWhichIsA("Frame")
        local key = label and toggleMap[string.lower(label.Text or "")]
        if key and box then
            addSurface(object, function()
                state[key] = not state[key]
                renderToggle(object, key)
                pcall(saveConfig)
                print("[sB Hub] Toggle:", key, state[key])
            end, "Toggle_" .. key)
            renderToggle(object, key)
        end
    end
end

if titleBar then
    local kill = Instance.new("Frame")
    kill.Name = "sB_KillHub"
    kill.Size = UDim2.fromOffset(84, 24)
    kill.Position = UDim2.fromOffset(276, 5)
    kill.BackgroundColor3 = GUI_COLORS.danger
    kill.BorderSizePixel = 1
    kill.BorderColor3 = GUI_COLORS.border
    kill.Active = true
    kill.ZIndex = 2000
    kill.Parent = titleBar
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = "KILL HUB"
    label.TextColor3 = GUI_COLORS.text
    label.TextSize = 10
    label.Font = FONT
    label.ZIndex = 2001
    label.Parent = kill
    kill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sBHubAlive = false
            running = false
            for _, c in ipairs(clickConnections) do pcall(function() c:Disconnect() end) end
            table.clear(clickConnections)
            if type(connections) == "table" then
                for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
                table.clear(connections)
            end
            if gui and gui.Parent then gui:Destroy() end
            print("[sB Hub] Killed")
        end
    end)
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
debug.Font = FONT
debug.TextXAlignment = Enum.TextXAlignment.Left
debug.TextYAlignment = Enum.TextYAlignment.Top
debug.ZIndex = 2005
debug.Parent = window

task.spawn(function()
    while running and sBHubAlive do
        task.wait(0.25)
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp = player:FindFirstChildOfClass("Backpack")
        local names = {}
        if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(names, t.Name) end end end
        if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(names, "[EQUIPPED] " .. t.Name) end end end
        debug.Text = "AUTO TRAIN DEBUG\n" ..
            "state.autoTrain: " .. tostring(state.autoTrain) .. "\n" ..
            "running/alive: " .. tostring(running) .. " / " .. tostring(sBHubAlive) .. "\n" ..
            "character: " .. tostring(char and char.Name or "nil") .. "\n" ..
            "humanoid: " .. tostring(hum ~= nil) .. "\n" ..
            "currentExercise: " .. tostring(currentExercise) .. "\n" ..
            "strength: " .. tostring(strength and strength.Value or "nil") .. "\n" ..
            "tools: " .. (#names > 0 and table.concat(names, ", ") or "NONE")
    end
end)

print("[sB Hub] AUTO TRAIN isolated build loaded")
print("[sB Hub] runtime.lua intentionally skipped")
print("[sB Hub] Drag mode: built-in")
print("[sB Hub] KILL HUB installed")