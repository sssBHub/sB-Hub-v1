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
controlGui.IgnoreGuiInset = true
controlGui.DisplayOrder = 200000
controlGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
controlGui.Parent = playerGui

local killButton = Instance.new("TextButton")
killButton.Name = "sB_UI_Test_Kill"
killButton.Size = UDim2.fromOffset(120, 32)
killButton.Position = UDim2.new(1, -135, 0, 15)
killButton.BackgroundColor3 = GUI_COLORS.danger
killButton.BorderSizePixel = 1
killButton.BorderColor3 = GUI_COLORS.border
killButton.Text = "KILL HUB"
killButton.TextColor3 = GUI_COLORS.text
killButton.TextSize = 11
killButton.Font = FONT
killButton.AutoButtonColor = true
killButton.Active = true
killButton.Selectable = true
killButton.ZIndex = 200001
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

    if type(connections) == "table" then
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(connections)
    end

    pcall(function()
        if controlGui and controlGui.Parent then
            controlGui:Destroy()
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

    print("[sB Hub UI TEST] Killed")
end

shellConnect(killButton.MouseButton1Click, killHub)

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
print("[sB Hub UI TEST] Kill button=", killButton.Visible, "parent=", killButton.Parent.Name, "main=", pages.main.Visible)
