local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function loadFile(name)
    local source = game:HttpGet(BASE .. name .. "?v=" .. tostring(os.clock()))
    local chunk, err = loadstring(source, "@" .. name)
    assert(chunk, err)
    return chunk()
end

local oldControls = playerGui:FindFirstChild("sB_UI_Test_Controls")
if oldControls then
    oldControls:Destroy()
end

loadFile("config.lua")
loadFile("ui_click.lua")

if type(showTab) == "function" then
    showTab("main")
end

if gui then
    gui.Enabled = true
    gui.Parent = playerGui
    gui.DisplayOrder = 100000
end

if window then
    window.Visible = true
end

if tabBar then
    tabBar.Visible = true
end

if content then
    content.Visible = true
end

-- KILL HUB is part of the main GUI title bar.
local killFrame = titleBar:FindFirstChild("sB_TestKill")
if killFrame then
    killFrame:Destroy()
end

killFrame = Instance.new("Frame")
killFrame.Name = "sB_TestKill"
killFrame.Size = UDim2.fromOffset(84, 24)
killFrame.Position = UDim2.fromOffset(276, 5)
killFrame.BackgroundColor3 = Color3.fromRGB(190, 55, 55)
killFrame.BorderSizePixel = 1
killFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
killFrame.Active = true
killFrame.Visible = true
killFrame.ZIndex = 2000
killFrame.Parent = titleBar

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.fromScale(1, 1)
killLabel.BackgroundTransparency = 1
killLabel.Text = "KILL HUB"
killLabel.TextColor3 = Color3.new(1, 1, 1)
killLabel.TextSize = 10
killLabel.Font = Enum.Font.Code
killLabel.ZIndex = 2001
killLabel.Parent = killFrame

local killed = false

local function killHub()
    if killed then
        return
    end

    killed = true

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

killFrame.InputBegan:Connect(function(input)
    if killed then
        return
    end

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

-- Dedicated drag handler. It belongs to this shell only and leaves KILL HUB out of drag hit-testing.
titleBar.Active = true

local dragging = false
local dragStart = nil
local startPosition = nil

local function pointInside(guiObject, point)
    local p = guiObject.AbsolutePosition
    local s = guiObject.AbsoluteSize
    return point.X >= p.X
        and point.X <= p.X + s.X
        and point.Y >= p.Y
        and point.Y <= p.Y + s.Y
end

titleBar.InputBegan:Connect(function(input)
    if killed then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    if pointInside(killFrame, input.Position) then
        return
    end

    dragging = true
    dragStart = input.Position
    startPosition = window.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if killed or not dragging then
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

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[sB Hub UI TEST] UI shell loaded")
print("[sB Hub UI TEST] Kill frame visible=", killFrame.Visible, "parent=", killFrame.Parent.Name, "absPos=", killFrame.AbsolutePosition, "absSize=", killFrame.AbsoluteSize, "drag=", true)
