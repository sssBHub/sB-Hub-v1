local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"

local function loadFile(name)
    local source = game:HttpGet(BASE .. name .. "?v=" .. os.clock())
    local chunk, err = loadstring(source, "@" .. name)
    assert(chunk, err)
    return chunk()
end

loadFile("config.lua")
loadFile("ui_click.lua")

if type(showTab) == "function" then
    showTab("main")
end

gui.Enabled = true
gui.Parent = playerGui
gui.DisplayOrder = 100000
window.Visible = true
window.ZIndex = 1

tabBar.Visible = true
tabBar.ZIndex = 10
content.Visible = true
content.ZIndex = 5

for _, page in pairs(pages) do
    page.ZIndex = 6
end

for _, button in pairs(tabs) do
    button.Visible = true
    button.ZIndex = 11
end

-- Completely independent shell controls. Runtime/automation modules are not loaded.
local shellConnections = {}
local function shellConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(shellConnections, connection)
    return connection
end

local UserInputService = game:GetService("UserInputService")

local oldControlGui = playerGui:FindFirstChild("sB_UI_Test_Controls")
if oldControlGui then
    oldControlGui:Destroy()
end

local controlGui = Instance.new("ScreenGui")
controlGui.Name = "sB_UI_Test_Controls"
controlGui.ResetOnSpawn = false
controlGui.IgnoreGuiInset = false
controlGui.DisplayOrder = 2147483646
controlGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
controlGui.Enabled = true
controlGui.Parent = playerGui

local killButton = Instance.new("TextButton")
killButton.Name = "sB_UI_Test_Kill"
killButton.Size = UDim2.fromOffset(150, 42)
killButton.Position = UDim2.fromOffset(15, 15)
killButton.BackgroundColor3 = GUI_COLORS.danger
killButton.BorderSizePixel = 1
killButton.BorderColor3 = GUI_COLORS.border
killButton.Text = "KILL HUB"
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.TextSize = 13
killButton.Font = Enum.Font.Code
killButton.AutoButtonColor = true
killButton.Active = true
killButton.Selectable = true
killButton.Visible = true
killButton.ZIndex = 2147483647
killButton.Parent = controlGui

local killed = false

local function killHub()
    if killed then
        return
    end

    killed = true

    for _, connection in ipairs(shellConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(shellConnections)

    pcall(function()
        if controlGui and controlGui.Parent then
            controlGui:Destroy()
        end
    end)

    if type(connections) == "table" then
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(connections)
    end

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

    print("[sB Hub UI TEST] Killed")
end

shellConnect(killButton.MouseButton1Click, killHub)

-- Emergency keyboard fallback.
shellConnect(UserInputService.InputBegan, function(input, processed)
    if processed or killed then
        return
    end

    if input.KeyCode == Enum.KeyCode.End then
        killHub()
    end
end)

-- Dedicated drag handler owned only by this shell test.
titleBar.Active = true
titleBar.Selectable = true

local dragging = false
local dragStart = nil
local startPosition = nil

shellConnect(titleBar.InputBegan, function(input)
    if killed then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    dragging = true
    dragStart = input.Position
    startPosition = window.Position
end)

shellConnect(UserInputService.InputChanged, function(input)
    if not dragging or killed then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    if not window or not window.Parent then
        return
    end

    local delta = input.Position - dragStart

    window.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

shellConnect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[sB Hub UI TEST] UI shell loaded")
print("[sB Hub UI TEST] Kill button=", killButton.Visible, "enabled=", controlGui.Enabled, "parent=", killButton.Parent.Name, "pos=", killButton.AbsolutePosition, "size=", killButton.AbsoluteSize, "main=", pages.main.Visible)
