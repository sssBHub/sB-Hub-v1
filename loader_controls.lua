-- sB Hub v1 - clean control-input loader
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
    local url = BASE .. name .. "?v=" .. tostring(math.floor(os.clock() * 1000000))
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

    source = source:gsub("while running do", function()
        return "while running and sBHubAlive do"
    end)

    local chunk, err = loadstring(source, "@" .. name)
    if not chunk then error("[sB Hub] Compile failed: " .. name .. "\n" .. tostring(err)) end
    local ok, result = pcall(chunk)
    if not ok then error("[sB Hub] Runtime error: " .. name .. "\n" .. tostring(result)) end
    print("[sB Hub] Downloaded:", name, #source, "bytes")
    return result
end

-- runtime.lua provides refreshCharacter(), findExercise(), and the other
-- shared runtime functions consumed by automation.lua. Load it first.
for _, name in ipairs({
    "config.lua", "ui_click.lua", "stats.lua", "overlays.lua",
    "notifications.lua", "spy.lua", "esp.lua", "runtime.lua", "automation.lua"
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

if sizeSpeedGroup then sizeSpeedGroup.Size = UDim2.fromOffset(230, 260); sizeSpeedGroup.ClipsDescendants = false end
if sizeModeLabel and sizeMode then sizeModeLabel.Position = UDim2.fromOffset(8, 30); sizeMode.Position = UDim2.fromOffset(98, 28) end
if sizeCustom then sizeCustom.Position = UDim2.fromOffset(8, 81) end
if speedModeLabel and speedMode then speedModeLabel.Position = UDim2.fromOffset(8, 114); speedMode.Position = UDim2.fromOffset(98, 112) end
if speedCustom then speedCustom.Position = UDim2.fromOffset(8, 165) end
if recoveryText then recoveryText.Position = UDim2.fromOffset(8, 214); recoveryText.Size = UDim2.fromOffset(210, 38) end
if overlayGroup then overlayGroup.Size = UDim2.fromOffset(230, 180) end
if goalGroup then goalGroup.Size = UDim2.fromOffset(230, 180) end
if hotkeyGroup and hotkeyScroll then hotkeyGroup.Size = UDim2.fromOffset(470, 340); hotkeyScroll.Size = UDim2.fromOffset(450, 300) end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("GuiButton") then
        object.Active = false
        pcall(function() object.Interactable = false end)
    end
end

local clickConnections = {}
local function addSurface(target, callback, name)
    if not target or not target.Parent then return end
    local parent = target.Parent
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
    surface.Parent = parent
    local c = surface.InputBegan:Connect(function(input)
        if not sBHubAlive then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local ok, err = pcall(callback)
        if not ok then warn("[sB Hub] Click error:", tostring(name), tostring(err)) end
    end)
    table.insert(clickConnections, c)
    return surface
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

if goalType then
    addSurface(goalType, function()
        local types = {"Strength", "Durability", "Rebirths"}
        local i = table.find(types, goal.type) or 1
        goal.type = types[(i % #types) + 1]
        goalType.Text = goal.type
        pcall(saveConfig)
    end, "GoalType")
end

if refreshPetListButton then
    addSurface(refreshPetListButton, function()
        if type(scanPetPool) == "function" then
            local pets = scanPetPool()
            if #pets > 0 then
                selectedPets = {pets[1]}
                if type(updatePetSelectionText) == "function" then updatePetSelectionText() end
                pcall(saveConfig)
                if type(notify) == "function" then notify("PET LIST", "Loaded " .. tostring(#pets) .. " pets.", GUI_COLORS.blue) end
            end
        end
    end, "PetList")
end

if spyPlayerText then
    addSurface(spyPlayerText, function()
        if type(rebuildSpyList) == "function" then rebuildSpyList() end
        spyList.Visible = not spyList.Visible
    end, "SpyPlayer")
end
if refreshSpy then
    addSurface(refreshSpy, function()
        if type(rebuildSpyList) == "function" then rebuildSpyList() end
        if type(refreshSpyText) == "function" then refreshSpyText() end
    end, "SpyRefresh")
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
    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.End then killHub() end
    end)
end

print("[sB Hub] Runtime-before-automation build loaded")
print("[sB Hub] Drag mode: built-in")
print("[sB Hub] KILL HUB installed")
print("[sB Hub] Faithful modular build loaded")
