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

local oldKill = titleBar:FindFirstChild("sB_TestKill")
if oldKill then
    oldKill:Destroy()
end

local oldDrag = titleBar:FindFirstChild("sB_TestDragSurface")
if oldDrag then
    oldDrag:Destroy()
end

local killFrame = Instance.new("Frame")
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

local dragSurface = Instance.new("Frame")
dragSurface.Name = "sB_TestDragSurface"
dragSurface.Size = UDim2.new(1, -190, 1, 0)
dragSurface.Position = UDim2.fromOffset(0, 0)
dragSurface.BackgroundTransparency = 1
dragSurface.BorderSizePixel = 0
dragSurface.Active = true
dragSurface.Visible = true
dragSurface.ZIndex = 1999
dragSurface.Parent = titleBar

local killed = false
local dragging = false
local dragStart = nil
local startPosition = nil

local function disconnectAll()
    if type(connections) == "table" then
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(connections)
    end
end

local function killHub()
    if killed then
        return
    end

    killed = true
    disconnectAll()

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

dragSurface.InputBegan:Connect(function(input)
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

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or killed then
        return
    end

    if input.KeyCode == Enum.KeyCode.End then
        killHub()
    end
end)

print("[sB Hub UI TEST] UI shell loaded")
print("[sB Hub UI TEST] Kill frame visible=", killFrame.Visible, "drag surface=", dragSurface.Visible)
