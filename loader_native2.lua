-- sB Hub v1 - native frame-input modular loader
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

local function download(name)
    local url = BASE .. name .. "?v=" .. tostring(math.floor(os.clock() * 1000000))
    local lastError
    for attempt = 1, 4 do
        local ok, result = pcall(function() return game:HttpGet(url) end)
        if ok and type(result) == "string" and #result > 0 then return result end
        lastError = result
        if attempt < 4 then task.wait(0.5 * attempt) end
    end
    error("[sB Hub] Download failed: " .. name .. "\n" .. tostring(lastError))
end

local function loadModule(name)
    print("[sB Hub] Downloading:", name)
    local source = download(name)
    source = source:gsub("while running do", function() return "while running and sBHubAlive do" end)
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

local screen = playerGui:FindFirstChild("sB_Hub_v1")
if not screen then error("[sB Hub] sB_Hub_v1 was not created") end

gui = screen
gui.Parent = playerGui
gui.Enabled = true
gui.DisplayOrder = 100000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

window = window or gui:FindFirstChildWhichIsA("Frame")
if not window then error("[sB Hub] Main window missing") end
window.Parent = gui
window.Visible = true
window.Active = true
window.Draggable = true
window.ZIndex = 1000

if type(showTab) == "function" then pcall(function() showTab("main") end) end
if tabBar then tabBar.Visible = true end
if content then content.Visible = true end

-- Prevent native TextButton callbacks from competing with the Frame input layer.
for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("TextButton") then
        object.Active = false
        pcall(function() object.Interactable = false end)
    end
end

local function addClickFrame(target, callback, name)
    if not target or not target.Parent then return nil end
    local frame = Instance.new("Frame")
    frame.Name = "sB_Input_" .. tostring(name or target.Name)
    frame.Size = UDim2.fromScale(1, 1)
    frame.Position = UDim2.fromOffset(0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Visible = true
    frame.ZIndex = (target.ZIndex or 1) + 50
    frame.Parent = target

    frame.InputBegan:Connect(function(input)
        if not sBHubAlive then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        pcall(callback)
    end)
    return frame
end

-- Tabs: overlay each tab button with a Frame that owns the click.
for tabName, button in pairs(tabs or {}) do
    addClickFrame(button, function()
        if type(showTab) == "function" then showTab(tabName) end
    end, "Tab_" .. tabName)
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
    local enabled = state[key] == true
    box.BackgroundColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.off
    box.BorderColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.border
end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("TextButton") then
        local label = object:FindFirstChildWhichIsA("TextLabel")
        local box = object:FindFirstChildWhichIsA("Frame")
        if label and box then
            local key = toggleMap[string.lower(label.Text or "")]
            if key then
                addClickFrame(object, function()
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
    addClickFrame(sizeMode, function()
        state.sizeMode = state.sizeMode == "Max" and "Custom" or "Max"
        sizeMode.Text = state.sizeMode == "Max" and "MAX" or "CUSTOM"
        pcall(saveConfig)
    end, "SizeMode")
end

if speedMode then
    addClickFrame(speedMode, function()
        state.speedMode = state.speedMode == "Max" and "Custom" or "Max"
        speedMode.Text = state.speedMode == "Max" and "MAX" or "CUSTOM"
        pcall(saveConfig)
    end, "SpeedMode")
end

-- Stable visual cleanup.
if sizeSpeedGroup then sizeSpeedGroup.Size = UDim2.fromOffset(230, 260); sizeSpeedGroup.ClipsDescendants = false end
if sizeModeLabel and sizeMode then sizeModeLabel.Position = UDim2.fromOffset(8, 30); sizeMode.Position = UDim2.fromOffset(98, 28) end
if sizeCustom then sizeCustom.Position = UDim2.fromOffset(8, 81) end
if speedModeLabel and speedMode then speedModeLabel.Position = UDim2.fromOffset(8, 114); speedMode.Position = UDim2.fromOffset(98, 112) end
if speedCustom then speedCustom.Position = UDim2.fromOffset(8, 165) end
if recoveryText then recoveryText.Position = UDim2.fromOffset(8, 214); recoveryText.Size = UDim2.fromOffset(210, 38) end
if overlayGroup then overlayGroup.Size = UDim2.fromOffset(230, 180) end
if goalGroup then goalGroup.Size = UDim2.fromOffset(230, 180) end
if hotkeyGroup and hotkeyScroll then hotkeyGroup.Size = UDim2.fromOffset(470, 340); hotkeyScroll.Size = UDim2.fromOffset(450, 300) end

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

print("[sB Hub] Native Frame input build loaded")
print("[sB Hub] Drag mode: built-in")
print("[sB Hub] KILL HUB installed")
print("[sB Hub] Faithful modular build loaded")
