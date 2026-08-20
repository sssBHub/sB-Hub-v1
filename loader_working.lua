-- sB Hub v1 - working-copy automation loader
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
    local lastError
    for attempt = 1, 4 do
        local ok, result = pcall(function() return game:HttpGet(url) end)
        if ok and type(result) == "string" and #result > 0 then
            return result
        end
        lastError = result
        if attempt < 4 then task.wait(0.5 * attempt) end
    end
    error("[sB Hub] Download failed: " .. name .. "\n" .. tostring(lastError))
end

local ORIGINAL_AUTOTRAIN = [[
task.spawn(function()
    while running do
        task.wait()

        if not state.autoTrain then
            continue
        end

        if not character
            or not character.Parent
            or not humanoid
            or not humanoid.Parent then

            refreshCharacter()
            continue
        end

        local selected =
            findExercise()

        if not selected then
            currentExercise =
                "None"

            continue
        end

        currentExercise =
            tostring(
                selected.tool.Name
            )

        local tool =
            selected.tool

        if tool.Parent ~= character then
            pcall(function()
                humanoid:EquipTool(tool)
            end)

            task.wait()
            continue
        end

        pcall(function()
            tool:Activate()
        end)
    end
end)
]]

local function loadModule(name)
    print("[sB Hub] Downloading:", name)
    local source = download(name)

    source = source:gsub("while running do", function()
        return "while running and sBHubAlive do"
    end)

    if name == "automation.lua" then
        local startMark = "pcall(refreshCharacter)"
        local endMark = "task.spawn(function()\n    while running and sBHubAlive do\n        task.wait(0.1)"
        local a = source:find(startMark, 1, true)
        local b = source:find(endMark, 1, true)

        if a and b and b > a then
            local prefix = source:sub(1, a - 1)
            local suffix = source:sub(b)
            local rebirthMarker = suffix:find("task.spawn(function()\n    while running and sBHubAlive do\n        task.wait(0.1)", 1, true)
            if rebirthMarker then
                source = prefix .. "pcall(refreshCharacter)\n\n" .. ORIGINAL_AUTOTRAIN .. "\n" .. suffix:sub(rebirthMarker)
                print("[sB Hub] Using ORIGINAL Auto Train implementation")
            end
        end
    end

    local chunk, err = loadstring(source, "@" .. name)
    if not chunk then error("[sB Hub] Compile failed: " .. name .. "\n" .. tostring(err)) end
    local ok, result = pcall(chunk)
    if not ok then error("[sB Hub] Runtime error: " .. name .. "\n" .. tostring(result)) end
    print("[sB Hub] Downloaded:", name, #source, "bytes")
    return result
end

for _, name in ipairs({
    "config.lua", "ui_click.lua", "stats.lua", "overlays.lua",
    "notifications.lua", "spy.lua", "esp.lua", "automation.lua", "runtime.lua"
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

-- Keep the proven working UI/input layer from loader_controls.lua.
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
    local c = surface.InputBegan:Connect(function(input)
        if not sBHubAlive then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local ok, err = pcall(callback)
        if not ok then warn("[sB Hub] Click error:", tostring(name), tostring(err)) end
    end)
    table.insert(clickConnections, c)
end

for tabName, button in pairs(tabs or {}) do
    addSurface(button, function() showTab(tabName) end, "Tab_" .. tabName)
end

local toggleMap = {
    ["auto train"] = "autoTrain", ["auto rebirth"] = "autoRebirth", ["rebirth limit"] = "rebirthLimit",
    ["skip rebirth animation"] = "skipRebirthAnimation", ["auto jungle rock"] = "autoJungleRock",
    ["auto egg"] = "autoEgg", ["auto ultimates"] = "autoUltimates", ["auto size"] = "autoSize",
    ["auto speed"] = "autoSpeed", ["notifications"] = "notifications", ["pet notifications"] = "petNotifications",
    ["aura notifications"] = "auraNotifications", ["rarity alerts"] = "rarityNotifications",
    ["basic"] = "rareBasic", ["rare"] = "rareRare", ["epic"] = "rareEpic", ["unique"] = "rareUnique",
    ["advanced"] = "rareAdvanced", ["esp"] = "esp", ["boxes"] = "espBoxes", ["names"] = "espNames",
    ["distance"] = "espDistance", ["health"] = "espHealth", ["tracers"] = "espTracers",
    ["team check"] = "espTeamCheck", ["coordinates"] = "coords", ["compass"] = "coordsCompass",
    ["heading"] = "coordsHeading", ["pitch"] = "coordsPitch", ["auto refresh"] = "serverSpyAutoRefresh",
    ["automation status"] = "automationOverlay", ["performance monitor"] = "performanceOverlay",
    ["anti afk"] = "antiAFK", ["mute strength"] = "muteStrength", ["mute rebirth"] = "muteRebirth"
}

local function renderToggle(button, key)
    local box = button:FindFirstChildWhichIsA("Frame")
    if not box then return end
    local on = state[key] == true
    box.BackgroundColor3 = on and GUI_COLORS.blue or GUI_COLORS.off
    box.BorderColor3 = on and GUI_COLORS.blue or GUI_COLORS.border
end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("TextButton") then
        local label = object:FindFirstChildWhichIsA("TextLabel")
        local box = object:FindFirstChildWhichIsA("Frame")
        if label and box then
            local key = toggleMap[string.lower(label.Text or "")]
            if key then
                addSurface(object, function()
                    state[key] = not state[key]
                    renderToggle(object, key)
                    pcall(saveConfig)
                end, "Toggle_" .. key)
                renderToggle(object, key)
            end
        end
    end
end

if sizeMode then
    addSurface(sizeMode, function()
        state.sizeMode = state.sizeMode == "Max" and "Custom" or "Max"
        sizeMode.Text = state.sizeMode == "Max" and "MAX" or "CUSTOM"
        pcall(saveConfig)
    end, "SizeMode")
end

if speedMode then
    addSurface(speedMode, function()
        state.speedMode = state.speedMode == "Max" and "Custom" or "Max"
        speedMode.Text = state.speedMode == "Max" and "MAX" or "CUSTOM"
        pcall(saveConfig)
    end, "SpeedMode")
end

if titleBar then
    local oldKill = titleBar:FindFirstChild("sB_KillHub")
    if oldKill then oldKill:Destroy() end

    local kill = Instance.new("Frame")
    kill.Name = "sB_KillHub"
    kill.Size = UDim2.fromOffset(84, 24)
    kill.Position = UDim2.fromOffset(276, 5)
    kill.BackgroundColor3 = GUI_COLORS.danger
    kill.BorderSizePixel = 1
    kill.BorderColor3 = GUI_COLORS.border
    kill.Active = true
    kill.Visible = true
    kill.ZIndex = 2000
    kill.Parent = titleBar

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = "KILL HUB"
    text.TextColor3 = GUI_COLORS.text
    text.TextSize = 10
    text.Font = FONT
    text.ZIndex = 2001
    text.Parent = kill

    local killed = false
    local function killHub()
        if killed then return end
        killed = true
        sBHubAlive = false
        running = false
        for _, c in ipairs(clickConnections) do pcall(function() c:Disconnect() end) end
        table.clear(clickConnections)
        if type(connections) == "table" then
            for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
            table.clear(connections)
        end
        pcall(function() destroyAllESP() end)
        pcall(function() if jungleBillboard then jungleBillboard:Destroy() end end)
        pcall(function() if gui and gui.Parent then gui:Destroy() end end)
        pcall(function() if overlayGui and overlayGui.Parent then overlayGui:Destroy() end end)
        print("[sB Hub] Killed - lifecycle stopped")
    end
    kill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then killHub() end
    end)
end

print("[sB Hub] WORKING COPY Auto Train build loaded")
print("[sB Hub] Drag mode: built-in")
print("[sB Hub] KILL HUB installed")
print("[sB Hub] Faithful modular build loaded")
