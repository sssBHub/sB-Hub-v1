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

-- Dedicated UI-shell controls. Runtime/automation modules are intentionally
-- not loaded in this test.
local shellConnections = {}

local function shellConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(shellConnections, connection)
    return connection
end

-- Kill Hub button.
local oldKill = titleBar:FindFirstChild("sB_KillHub")
if oldKill then
    oldKill:Destroy()
end

local killButton = Instance.new("TextButton")
killButton.Name = "sB_KillHub"
killButton.Size = UDim2.fromOffset(82, 24)
killButton.Position = UDim2.new(1, -88, 0, 5)
killButton.BackgroundColor3 = GUI_COLORS.danger
killButton.BorderSizePixel = 1
killButton.BorderColor3 = GUI_COLORS.border
killButton.Text = "KILL HUB"
killButton.TextColor3 = GUI_COLORS.text
killButton.TextSize = 9
killButton.Font = FONT
killButton.AutoButtonColor = true
killButton.Active = true
killButton.Selectable = true
killButton.ZIndex = 2000
killButton.Parent = titleBar

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

    if gui and gui.Parent then
        gui:Destroy()
    end

    if overlayGui and overlayGui.Parent then
        overlayGui:Destroy()
    end

    print("[sB Hub UI TEST] Killed")
end

shellConnect(killButton.MouseButton1Click, killHub)

-- Single dedicated drag handler for this shell test.
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

    if input.Position.X >= killButton.AbsolutePosition.X
        and input.Position.X <= killButton.AbsolutePosition.X + killButton.AbsoluteSize.X
        and input.Position.Y >= killButton.AbsolutePosition.Y
        and input.Position.Y <= killButton.AbsolutePosition.Y + killButton.AbsoluteSize.Y then
        return
    end

    dragging = true
    dragStart = input.Position
    startPosition = window.Position
end)

local UserInputService = game:GetService("UserInputService")

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
print("[sB Hub UI TEST] Kill button=", killButton.Visible, "titleBar=", titleBar.Visible, "main=", pages.main.Visible)
