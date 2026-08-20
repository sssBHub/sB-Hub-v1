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

local shellConnections = {}
local function shellConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(shellConnections, connection)
    return connection
end

local UserInputService = game:GetService("UserInputService")
local killed = false

-- Kill control is a plain Frame so it uses the same InputBegan path as dragging.
local oldKill = window:FindFirstChild("sB_UITestKill")
if oldKill then
    oldKill:Destroy()
end

local killButton = Instance.new("Frame")
killButton.Name = "sB_UITestKill"
killButton.Size = UDim2.fromOffset(120, 32)
killButton.Position = UDim2.new(1, -132, 1, -44)
killButton.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
killButton.BorderSizePixel = 1
killButton.BorderColor3 = Color3.fromRGB(220, 220, 220)
killButton.Active = true
killButton.Visible = true
killButton.ZIndex = 5000
killButton.Parent = window

local killLabel = Instance.new("TextLabel")
killLabel.Name = "Label"
killLabel.Size = UDim2.fromScale(1, 1)
killLabel.BackgroundTransparency = 1
killLabel.Text = "KILL HUB"
killLabel.TextColor3 = Color3.new(1, 1, 1)
killLabel.TextSize = 11
killLabel.Font = Enum.Font.Code
killLabel.TextXAlignment = Enum.TextXAlignment.Center
killLabel.TextYAlignment = Enum.TextYAlignment.Center
killLabel.Active = false
killLabel.ZIndex = 5001
killLabel.Parent = killButton

local function killHub()
    if killed then return end
    killed = true

    for _, connection in ipairs(shellConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(shellConnections)

    if type(connections) == "table" then
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(connections)
    end

    pcall(function()
        if gui and gui.Parent then gui:Destroy() end
    end)

    pcall(function()
        if overlayGui and overlayGui.Parent then overlayGui:Destroy() end
    end)

    print("[sB Hub UI TEST] Killed")
end

shellConnect(killButton.InputBegan, function(input)
    if killed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        killHub()
    end
end)

shellConnect(UserInputService.InputBegan, function(input, processed)
    if processed or killed then return end
    if input.KeyCode == Enum.KeyCode.End then
        killHub()
    end
end)

-- Dedicated drag handler.
local dragging = false
local dragStart = nil
local startPosition = nil

titleBar.Active = true
shellConnect(titleBar.InputBegan, function(input)
    if killed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

    dragging = true
    dragStart = input.Position
    startPosition = window.Position
end)

shellConnect(UserInputService.InputChanged, function(input)
    if not dragging or killed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if not window or not window.Parent then return end

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
print(
    "[sB Hub UI TEST] Kill button=", killButton.Visible,
    "parent=", killButton.Parent.Name,
    "absPos=", killButton.AbsolutePosition,
    "absSize=", killButton.AbsoluteSize,
    "main=", pages.main.Visible
)
