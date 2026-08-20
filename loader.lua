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

    -- Keep every background loop tied to the shared lifecycle flag.
    source = source:gsub("while running do", function()
        return "while running and sBHubAlive do"
    end)

    -- The executor accepts GuiObject/InputBegan reliably, while some
    -- MouseButton1Click connections are not being delivered consistently.
    -- Convert modular UI button handlers before compilation.
    if fileName == "ui_click.lua" then
        source = source:gsub(
            "connect%(([%a_][%w_]*)%.MouseButton1Click,%s*function%(",
            function(objectName)
                return "connect(" .. objectName .. ".InputBegan, function(input)\n    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end\n"
            end
        )
    end

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
