-- sB Hub v1 - GitHub loader (faithful split)
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/12a7841f8723825886f546b282c197c38ce1845d/"

-- Stop the previous run before creating another one.
pcall(function()
    if type(running) == "boolean" then
        running = false
    end
    if type(connections) == "table" then
        for _, c in ipairs(connections) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(connections)
    end
end)

pcall(function()
    local p = game:GetService("Players").LocalPlayer
    local pg = p and p:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("sB_Hub_v1")
        if old then old:Destroy() end
        local oldOverlay = pg:FindFirstChild("sB_Overlays")
        if oldOverlay then oldOverlay:Destroy() end
    end
end)

local function loadModule(fileName)
    local url = BASE .. fileName
    print("[sB Hub] Downloading:", fileName)

    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error("[sB Hub] Download failed: " .. fileName .. "\n" .. tostring(source))
    end

    if fileName == "ui.lua" then
        source = source:gsub("%.Activated", ".MouseButton1Click")
    elseif fileName == "runtime.lua" then
        source = source:gsub("[\r\n]+dragStart[ \t]*[\r\n]+startPosition", "\ndragStart = nil\nstartPosition = nil", 1)
        source = source:gsub("connect%(%s*titleBar%.InputBegan.-%end%)%s*%)", "", 1)
        source = source:gsub("connect%(%s*UserInputService%.InputChanged.-%end%)%s*%)", "", 1)
        source = source:gsub("connect%(%s*UserInputService%.InputEnded.-%end%)%s*%)", "", 1)
    end

    print("[sB Hub] Downloaded:", fileName, #source, "bytes")
    local chunk, compileError = loadstring(source, "@" .. fileName)
    if not chunk then
        error("[sB Hub] Compile failed: " .. fileName .. "\n" .. tostring(compileError))
    end
    local success, result = pcall(chunk)
    if not success then
        error("[sB Hub] Runtime error: " .. fileName .. "\n" .. tostring(result))
    end
    return result
end

loadModule("config.lua")
loadModule("ui.lua")
loadModule("automation.lua")
loadModule("notifications.lua")
loadModule("spy.lua")
loadModule("esp.lua")
loadModule("stats.lua")
loadModule("overlays.lua")
loadModule("runtime.lua")

-- Make every control explicitly interactive.
pcall(function()
    if gui then
        for _, object in ipairs(gui:GetDescendants()) do
            if object:IsA("GuiButton") then
                object.Active = true
                object.Selectable = true
            end
        end
    end
end)

-- Add a dedicated, always-visible emergency button.
pcall(function()
    if not gui or not titleBar then
        error("UI objects were not created")
    end

    local existing = titleBar:FindFirstChild("sB_KillHub")
    if existing then existing:Destroy() end

    local kill = Instance.new("TextButton")
    kill.Name = "sB_KillHub"
    kill.Size = UDim2.fromOffset(82, 24)
    kill.Position = UDim2.new(1, -88, 0, 5)
    kill.BackgroundColor3 = GUI_COLORS.danger
    kill.BorderSizePixel = 1
    kill.BorderColor3 = GUI_COLORS.border
    kill.Text = "KILL HUB"
    kill.TextColor3 = GUI_COLORS.text
    kill.TextSize = 9
    kill.Font = FONT
    kill.AutoButtonColor = true
    kill.Active = true
    kill.Selectable = true
    kill.ZIndex = 10010
    kill.Parent = titleBar

    kill.MouseButton1Click:Connect(function()
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
        print("[sB Hub] Killed")
    end)

    print("[sB Hub] KILL HUB installed")
end)

-- Own window dragging here so there is exactly one drag controller.
pcall(function()
    if not gui or not window or not titleBar then
        return
    end

    local UIS = game:GetService("UserInputService")
    titleBar.Active = true

    local dragging = false
    local dragStart = nil
    local startPosition = nil

    local function onBegin(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = window.Position
        end
    end

    local function onChanged(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if not window or not window.Parent then return end
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    local function onEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end

    table.insert(connections, titleBar.InputBegan:Connect(onBegin))
    table.insert(connections, UIS.InputChanged:Connect(onChanged))
    table.insert(connections, UIS.InputEnded:Connect(onEnded))
end)

print("[sB Hub] Faithful modular build loaded")
