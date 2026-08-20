-- sB Hub v1 - stable modular loader
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

sBHubAlive = false
running = false

local function disconnectExisting()
    pcall(function()
        if type(connections) == "table" then
            for _, c in ipairs(connections) do
                pcall(function() c:Disconnect() end)
            end
            table.clear(connections)
        end
    end)
end

disconnectExisting()

for _, name in ipairs({"sB_Hub_v1", "sB_Overlays"}) do
    local old = playerGui:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

sBHubAlive = true
running = true

local function downloadSource(fileName)
    local url = BASE .. fileName .. "?v=" .. tostring(math.floor(os.clock() * 1000000))
    local lastError

    for attempt = 1, 4 do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)

        if ok and type(result) == "string" and #result > 0 then
            return result
        end

        lastError = result
        if attempt < 4 then
            task.wait(0.5 * attempt)
        end
    end

    error("[sB Hub] Download failed: " .. fileName .. "\n" .. tostring(lastError))
end

local function loadModule(fileName)
    print("[sB Hub] Downloading:", fileName)

    local source = downloadSource(fileName)

    source = source:gsub("while running do", function()
        return "while running and sBHubAlive do"
    end)

    print("[sB Hub] Downloaded:", fileName, #source, "bytes")

    local chunk, compileError = loadstring(source, "@" .. fileName)
    if not chunk then
        error("[sB Hub] Compile failed: " .. fileName .. "\n" .. tostring(compileError))
    end

    local ok, result = pcall(chunk)
    if not ok then
        error("[sB Hub] Runtime error: " .. fileName .. "\n" .. tostring(result))
    end

    return result
end

for _, moduleName in ipairs({
    "config.lua",
    "ui_click.lua",
    "stats.lua",
    "overlays.lua",
    "notifications.lua",
    "spy.lua",
    "esp.lua",
    "automation.lua",
    "runtime.lua",
}) do
    loadModule(moduleName)
end

local screen = playerGui:FindFirstChild("sB_Hub_v1")
if not screen then
    error("[sB Hub] sB_Hub_v1 was not created by ui_click.lua")
end

gui = screen
gui.Parent = playerGui
gui.Enabled = true
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

window = window or gui:FindFirstChildWhichIsA("Frame")
if not window then
    error("[sB Hub] sB_Hub_v1 exists but contains no Frame window")
end

window.Parent = gui
window.Visible = true
window.Active = true
window.Draggable = true
window.ZIndex = 1000

if tabBar then
    tabBar.Visible = true
    tabBar.ZIndex = 1001
end

if content then
    content.Visible = true
    content.ZIndex = 1000
end

if type(showTab) == "function" then
    pcall(function()
        showTab("main")
    end)
end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("GuiButton") then
        object.Active = true
        object.Selectable = true
        pcall(function() object.Interactable = true end)
    end
end

local function moveInputPair(parent, box, labelText, y)
    if not parent or not box then
        return
    end

    box.Position = UDim2.fromOffset(8, y + 16)

    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("TextLabel") and child.Text == labelText then
            child.Position = UDim2.fromOffset(8, y)
            break
        end
    end
end

if sizeSpeedGroup then
    sizeSpeedGroup.Size = UDim2.fromOffset(230, 260)
    sizeSpeedGroup.ClipsDescendants = false
end

if sizeModeLabel and sizeMode then
    sizeModeLabel.Position = UDim2.fromOffset(8, 30)
    sizeMode.Position = UDim2.fromOffset(98, 28)
end

moveInputPair(sizeSpeedGroup, sizeCustom, "custom size", 65)

if speedModeLabel and speedMode then
    speedModeLabel.Position = UDim2.fromOffset(8, 114)
    speedMode.Position = UDim2.fromOffset(98, 112)
end

moveInputPair(sizeSpeedGroup, speedCustom, "custom speed", 149)

if recoveryText then
    recoveryText.Position = UDim2.fromOffset(8, 205)
    recoveryText.Size = UDim2.fromOffset(210, 40)
end

if overlayGroup then
    overlayGroup.Size = UDim2.fromOffset(230, 180)
end

if goalGroup then
    goalGroup.Size = UDim2.fromOffset(230, 180)
end

if hotkeyGroup and hotkeyScroll then
    hotkeyGroup.Size = UDim2.fromOffset(470, 340)
    hotkeyScroll.Size = UDim2.fromOffset(450, 300)
end

-- Direct mouse-input bridge for module controls. The executor is accepting
-- mouse input (Kill Hub works), but MouseButton1Click on the generated module
-- buttons is not firing consistently. Handle the same controls through the
-- proven InputBegan path.
local directClickConnections = {}
local directClickSeen = setmetatable({}, {__mode = "k"})

local function directClick(button, fn)
    if not button or not button:IsA("GuiButton") or directClickSeen[button] then
        return
    end

    directClickSeen[button] = true
    local c = button.InputBegan:Connect(function(input)
        if not sBHubAlive then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ok, err = pcall(fn)
            if not ok then
                warn("[sB Hub] UI click error:", button.Name, tostring(err))
            end
        end
    end)
    table.insert(directClickConnections, c)
end

-- Tabs.
for tabName, button in pairs(tabs or {}) do
    directClick(button, function()
        showTab(tabName)
    end)
end

-- Toggle rows generated by makeToggle(). Their direct child label contains
-- the display text; map each row back to the corresponding state field.
local toggleMap = {
    ["auto train"] = "autoTrain",
    ["auto rebirth"] = "autoRebirth",
    ["rebirth limit"] = "rebirthLimit",
    ["skip rebirth animation"] = "skipRebirthAnimation",
    ["auto jungle rock"] = "autoJungleRock",
    ["auto egg"] = "autoEgg",
    ["auto ultimates"] = "autoUltimates",
    ["auto size"] = "autoSize",
    ["auto speed"] = "autoSpeed",
    ["notifications"] = "notifications",
    ["pet notifications"] = "petNotifications",
    ["aura notifications"] = "auraNotifications",
    ["rarity alerts"] = "rarityNotifications",
    ["basic"] = "rareBasic",
    ["rare"] = "rareRare",
    ["epic"] = "rareEpic",
    ["unique"] = "rareUnique",
    ["advanced"] = "rareAdvanced",
    ["esp"] = "esp",
    ["boxes"] = "espBoxes",
    ["names"] = "espNames",
    ["distance"] = "espDistance",
    ["health"] = "espHealth",
    ["tracers"] = "espTracers",
    ["team check"] = "espTeamCheck",
    ["coordinates"] = "coords",
    ["compass"] = "coordsCompass",
    ["heading"] = "coordsHeading",
    ["pitch"] = "coordsPitch",
    ["auto refresh"] = "serverSpyAutoRefresh",
    ["automation status"] = "automationOverlay",
    ["performance monitor"] = "performanceOverlay",
    ["anti afk"] = "antiAFK",
    ["mute strength"] = "muteStrength",
    ["mute rebirth"] = "muteRebirth",
    ["goal enabled"] = "goal.enabled",
}

local function renderToggleRow(row)
    local stateKey = toggleMap[string.lower(row.Text or "")]
    if stateKey == "goal.enabled" then
        local box = row:FindFirstChildWhichIsA("Frame")
        if box then
            box.BackgroundColor3 = goal.enabled and GUI_COLORS.blue or GUI_COLORS.off
            box.BorderColor3 = goal.enabled and GUI_COLORS.blue or GUI_COLORS.border
        end
        return
    end
    if not stateKey then
        return
    end
    local box = row:FindFirstChildWhichIsA("Frame")
    if box then
        local enabled = state[stateKey] == true
        box.BackgroundColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.off
        box.BorderColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.border
    end
end

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("TextButton") then
        local label = object:FindFirstChildWhichIsA("TextLabel")
        local hasBox = object:FindFirstChildWhichIsA("Frame") ~= nil
        if label and hasBox then
            local text = string.lower(label.Text or "")
            local key = toggleMap[text]
            if key then
                directClick(object, function()
                    if key == "goal.enabled" then
                        goal.enabled = not goal.enabled
                    else
                        state[key] = not state[key]
                    end
                    renderToggleRow(object)
                    pcall(saveConfig)
                end)
                renderToggleRow(object)
            end
        end
    end
end

-- Size/speed mode buttons.
if sizeMode then
    directClick(sizeMode, function()
        state.sizeMode = state.sizeMode == "Max" and "Custom" or "Max"
        sizeMode.Text = state.sizeMode == "Max" and "MAX" or "CUSTOM"
        pcall(saveConfig)
    end)
end

if speedMode then
    directClick(speedMode, function()
        state.speedMode = state.speedMode == "Max" and "Custom" or "Max"
        speedMode.Text = state.speedMode == "Max" and "MAX" or "CUSTOM"
        pcall(saveConfig)
    end)
end

-- Goal type.
if goalType then
    directClick(goalType, function()
        local types = {"Strength", "Durability", "Rebirths"}
        local i = table.find(types, goal.type) or 1
        goal.type = types[(i % #types) + 1]
        goalType.Text = goal.type
        pcall(saveConfig)
    end)
end

-- Remaining simple buttons.
if refreshPetListButton then
    directClick(refreshPetListButton, function()
        if type(scanPetPool) == "function" then
            local pets = scanPetPool()
            if #pets > 0 then
                selectedPets = {pets[1]}
                if type(updatePetSelectionText) == "function" then updatePetSelectionText() end
                if type(saveConfig) == "function" then saveConfig() end
                if type(notify) == "function" then notify("PET LIST", "Loaded " .. tostring(#pets) .. " pets.", GUI_COLORS.blue) end
            end
        end
    end)
end

if spyPlayerText then
    directClick(spyPlayerText, function()
        if type(rebuildSpyList) == "function" then rebuildSpyList() end
        spyList.Visible = not spyList.Visible
    end)
end

if refreshSpy then
    directClick(refreshSpy, function()
        if type(rebuildSpyList) == "function" then rebuildSpyList() end
        if type(refreshSpyText) == "function" then refreshSpyText() end
    end)
end

print("[sB Hub] Direct UI input bridge installed")

if titleBar then
    local oldKill = titleBar:FindFirstChild("sB_KillHub")
    if oldKill then
        oldKill:Destroy()
    end

    local killFrame = Instance.new("Frame")
    killFrame.Name = "sB_KillHub"
    killFrame.Size = UDim2.fromOffset(84, 24)
    killFrame.Position = UDim2.fromOffset(276, 5)
    killFrame.BackgroundColor3 = GUI_COLORS.danger
    killFrame.BorderSizePixel = 1
    killFrame.BorderColor3 = GUI_COLORS.border
    killFrame.Active = true
    killFrame.Visible = true
    killFrame.ZIndex = 2000
    killFrame.Parent = titleBar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "KILL HUB"
    label.TextColor3 = GUI_COLORS.text
    label.TextSize = 10
    label.Font = FONT
    label.ZIndex = 2001
    label.Parent = killFrame

    local killed = false

    local function killHub()
        if killed then
            return
        end

        killed = true
        sBHubAlive = false
        running = false

        for _, c in ipairs(directClickConnections) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(directClickConnections)

        if type(connections) == "table" then
            for _, c in ipairs(connections) do
                pcall(function() c:Disconnect() end)
            end
            table.clear(connections)
        end

        pcall(function() destroyAllESP() end)
        pcall(function()
            if jungleBillboard then
                jungleBillboard:Destroy()
                jungleBillboard = nil
            end
        end)
        pcall(function()
            if gui and gui.Parent then
                gui:Destroy()
            end
        end)
        pcall(function()
            if overlayGui and overlayGui.Parent then
                overlayGui:Destroy()
            end
        end)

        print("[sB Hub] Killed - lifecycle stopped")
    end

    killFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            killHub()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or killed then
            return
        end

        if input.KeyCode == Enum.KeyCode.End then
            killHub()
        end
    end)
end

print("[sB Hub] KILL HUB installed")
print("[sB Hub] Drag mode: built-in")
print("[sB Hub] Faithful modular build loaded")