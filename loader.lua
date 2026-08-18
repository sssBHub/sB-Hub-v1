-- sB Hub v1 - GitHub loader (faithful split)
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"

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

sBHubAlive = true
running = true

local function loadModule(fileName)
    local url = BASE .. fileName .. "?v=" .. tostring(os.clock()):gsub("%.", "")
    print("[sB Hub] Downloading:", fileName)

    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error("[sB Hub] Download failed: " .. fileName .. "\n" .. tostring(source))
    end

    source = source:gsub("while running do", "while running and sBHubAlive do")

    if fileName == "runtime.lua" then
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

pcall(function()
    if gui then
        for _, object in ipairs(gui:GetDescendants()) do
            if object:IsA("GuiButton") then
                object.Active = true
                pcall(function() object.Interactable = true end)
                object.Selectable = true
            end
        end
    end
end)

pcall(function()
    if not gui or not titleBar then error("UI objects were not created") end

    local oldKill = titleBar:FindFirstChild("sB_KillHub")
    if oldKill then oldKill:Destroy() end

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
    pcall(function() kill.Interactable = true end)
    kill.Selectable = true
    kill.ZIndex = 10010
    kill.Parent = titleBar

    local function killHub()
        sBHubAlive = false
        running = false
        task.wait()
        if type(connections) == "table" then
            for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
            table.clear(connections)
        end
        pcall(function() destroyAllESP() end)
        pcall(function() if jungleBillboard then jungleBillboard:Destroy() end end)
        pcall(function() if gui and gui.Parent then gui:Destroy() end end)
        pcall(function() if overlayGui and overlayGui.Parent then overlayGui:Destroy() end end)
        print("[sB Hub] Killed - lifecycle stopped")
    end

    kill.MouseButton1Click:Connect(killHub)
    kill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then killHub() end
    end)
    print("[sB Hub] KILL HUB installed")
end)

pcall(function()
    if not gui or not window or not titleBar then return end
    local UIS = game:GetService("UserInputService")
    titleBar.Active = true
    pcall(function() titleBar.Interactable = true end)
    local dragging = false
    local dragStart = nil
    local startPosition = nil

    table.insert(connections, titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = window.Position
        end
    end))
    table.insert(connections, UIS.InputChanged:Connect(function(input)
        if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if not window or not window.Parent then return end
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end))
    table.insert(connections, UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
end)

print("[sB Hub] Faithful modular build loaded")
