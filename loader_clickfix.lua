local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"

local function run(url)
    local source = game:HttpGet(url .. "?v=" .. tostring(math.floor(os.clock() * 1000000)))
    local chunk, err = loadstring(source, "@clickfix")
    assert(chunk, err)
    return chunk()
end

-- Load the current stable hub first.
run(BASE .. "loader.lua")

task.wait(0.25)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screen = playerGui:FindFirstChild("sB_Hub_v1")
assert(screen, "sB Hub GUI not found")

local overlays = playerGui:FindFirstChild("sB_ClickFix")
if overlays then
    overlays:Destroy()
end

overlays = Instance.new("ScreenGui")
overlays.Name = "sB_ClickFix"
overlays.ResetOnSpawn = false
overlays.IgnoreGuiInset = true
overlays.DisplayOrder = 100001
overlays.ZIndexBehavior = Enum.ZIndexBehavior.Global
overlays.Parent = playerGui

local overlayRoot = Instance.new("Frame")
overlayRoot.Size = UDim2.fromScale(1, 1)
overlayRoot.BackgroundTransparency = 1
overlayRoot.BorderSizePixel = 0
overlayRoot.Active = false
overlayRoot.Parent = overlays

local alive = true

local function isInside(obj)
    return obj and obj.Parent and obj:IsDescendantOf(screen)
end

local function addSurface(target, callback, name)
    if not isInside(target) then
        return
    end

    local surface = Instance.new("Frame")
    surface.Name = "ClickFix_" .. tostring(name or target.Name)
    surface.BackgroundTransparency = 1
    surface.BorderSizePixel = 0
    surface.Active = true
    surface.Visible = true
    surface.ZIndex = 60000
    surface.Size = target.Size
    surface.Position = target.Position
    surface.Parent = target.Parent

    surface.InputBegan:Connect(function(input)
        if not alive then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        local ok, err = pcall(callback)
        if not ok then
            warn("[sB ClickFix]", tostring(name), tostring(err))
        end
    end)

    return surface
end

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
}

local function renderToggle(button, key)
    local box = button:FindFirstChildWhichIsA("Frame")
    if not box then
        return
    end
    local enabled = state[key] == true
    box.BackgroundColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.off
    box.BorderColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.border
end

local count = 0

-- Tabs.
for tabName, tabButton in pairs(tabs or {}) do
    addSurface(tabButton, function()
        if type(showTab) == "function" then
            showTab(tabName)
        end
    end, "tab_" .. tabName)
    count += 1
end

-- Toggles.
for _, obj in ipairs(screen:GetDescendants()) do
    if obj:IsA("TextButton") then
        local label = obj:FindFirstChildWhichIsA("TextLabel")
        local box = obj:FindFirstChildWhichIsA("Frame")
        if label and box then
            local text = string.lower(label.Text or "")
            local key = toggleMap[text]
            if key then
                addSurface(obj, function()
                    state[key] = not state[key]
                    renderToggle(obj, key)
                    if type(saveConfig) == "function" then
                        pcall(saveConfig)
                    end
                end, "toggle_" .. key)
                renderToggle(obj, key)
                count += 1
            end
        end
    end
end

-- Size/speed mode controls.
if sizeMode then
    addSurface(sizeMode, function()
        state.sizeMode = state.sizeMode == "Max" and "Custom" or "Max"
        sizeMode.Text = state.sizeMode == "Max" and "MAX" or "CUSTOM"
        if type(saveConfig) == "function" then pcall(saveConfig) end
    end, "size_mode")
    count += 1
end

if speedMode then
    addSurface(speedMode, function()
        state.speedMode = state.speedMode == "Max" and "Custom" or "Max"
        speedMode.Text = state.speedMode == "Max" and "MAX" or "CUSTOM"
        if type(saveConfig) == "function" then pcall(saveConfig) end
    end, "speed_mode")
    count += 1
end

if goalType then
    addSurface(goalType, function()
        local types = {"Strength", "Durability", "Rebirths"}
        local i = table.find(types, goal.type) or 1
        goal.type = types[(i % #types) + 1]
        goalType.Text = goal.type
        if type(saveConfig) == "function" then pcall(saveConfig) end
    end, "goal_type")
    count += 1
end

print("[sB ClickFix] Installed surfaces:", count)
print("[sB ClickFix] Plain Frame input layer active")

-- Kill this click-fix layer automatically with the hub's lifecycle.
task.spawn(function()
    while alive and sBHubAlive do
        task.wait(0.5)
    end
    alive = false
    pcall(function() overlays:Destroy() end)
end)
