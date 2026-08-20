-- sB Hub v1 - native-input modular loader
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

sBHubAlive = false
running = false

pcall(function()
    if type(connections) == "table" then
        for _, c in ipairs(connections) do
            pcall(function() c:Disconnect() end)
        end
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

local function normalizeUI(source)
    -- Replace every native MouseButton1Click callback with InputBegan.
    -- Function replacements avoid Lua's '%' replacement-string rules.
    source = source:gsub(
        "connect%(([%a_][%w_]*)%.MouseButton1Click,%s*function%(%)([\r\n]*)",
        function(buttonName, newline)
            return "connect(" .. buttonName .. ".InputBegan, function(input)" .. newline ..
                "        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end" .. newline
        end
    )
    return source
end

local function loadModule(name)
    print("[sB Hub] Downloading:", name)
    local source = download(name)

    source = source:gsub("while running do", function()
        return "while running and sBHubAlive do"
    end)

    if name == "ui_click.lua" then
        source = normalizeUI(source)
    end

    local chunk, compileError = loadstring(source, "@" .. name)
    if not chunk then
        error("[sB Hub] Compile failed: " .. name .. "\n" .. tostring(compileError))
    end

    local ok, result = pcall(chunk)
    if not ok then
        error("[sB Hub] Runtime error: " .. name .. "\n" .. tostring(result))
    end

    print("[sB Hub] Downloaded:", name, #source, "bytes")
    return result
end

for _, name in ipairs({
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
    loadModule(name)
end

local screen = playerGui:FindFirstChild("sB_Hub_v1")
if not screen then error("[sB Hub] sB_Hub_v1 was not created") end

gui = screen
gui.Enabled = true
gui.Parent = playerGui
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

for _, object in ipairs(gui:GetDescendants()) do
    if object:IsA("GuiButton") then
        object.Active = true
        object.Selectable = true
        pcall(function() object.Interactable = true end)
    end
end

-- Keep the known-good visual cleanup.
if sizeSpeedGroup then
    sizeSpeedGroup.Size = UDim2.fromOffset(230, 260)
    sizeSpeedGroup.ClipsDescendants = false
end
if sizeModeLabel and sizeMode then
    sizeModeLabel.Position = UDim2.fromOffset(8, 30)
    sizeMode.Position = UDim2.fromOffset(98, 28)
end
if sizeCustom then
    sizeCustom.Position = UDim2.fromOffset(8, 81)
end
if speedModeLabel and speedMode then
    speedModeLabel.Position = UDim2.fromOffset(8, 114)
    speedMode.Position = UDim2.fromOffset(98, 112)
end
if speedCustom then
    speedCustom.Position = UDim2.fromOffset(8, 165)
end
if recoveryText then
    recoveryText.Position = UDim2.fromOffset(8, 214)
    recoveryText.Size = UDim2.fromOffset(210, 38)
end
if overlayGroup then overlayGroup.Size = UDim2.fromOffset(230, 180) end
if goalGroup then goalGroup.Size = UDim2.fromOffset(230, 180) end
if hotkeyGroup and hotkeyScroll then
    hotkeyGroup.Size = UDim2.fromOffset(470, 340)
    hotkeyScroll.Size = UDim2.fromOffset(450, 300)
end

-- Kill Hub stays inside the main GUI title bar.
if titleBar then
    local oldKill = titleBar:FindFirstChild("sB_KillHub")
    if oldKill then oldKill:Destroy() end

    local kill = Instance.new("TextButton")
    kill.Name = "sB_KillHub"
    kill.Size = UDim2.fromOffset(84, 24)
    kill.Position = UDim2.fromOffset(276, 5)
    kill.BackgroundColor3 = GUI_COLORS.danger
    kill.BorderSizePixel = 1
    kill.BorderColor3 = GUI_COLORS.border
    kill.Text = "KILL HUB"
    kill.TextColor3 = GUI_COLORS.text
    kill.TextSize = 10
    kill.Font = FONT
    kill.Active = true
    kill.Selectable = true
    pcall(function() kill.Interactable = true end)
    kill.ZIndex = 2000
    kill.Parent = titleBar

    local killed = false
    local function killHub()
        if killed then return end
        killed = true
        sBHubAlive = false
        running = false

        if type(connections) == "table" then
            for _, c in ipairs(connections) do
                pcall(function() c:Disconnect() end)
            end
            table.clear(connections)
        end

        pcall(function() destroyAllESP() end)
        pcall(function() if jungleBillboard then jungleBillboard:Destroy() end end)
        pcall(function() if gui and gui.Parent then gui:Destroy() end end)
        pcall(function() if overlayGui and overlayGui.Parent then overlayGui:Destroy() end end)
        print("[sB Hub] Killed - lifecycle stopped")
    end

    kill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            killHub()
        end
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if processed or killed then return end
        if input.KeyCode == Enum.KeyCode.End then killHub() end
    end)
end

print("[sB Hub] Native UI input build loaded")
print("[sB Hub] Drag mode: built-in")
print("[sB Hub] KILL HUB installed")
print("[sB Hub] Faithful modular build loaded")
