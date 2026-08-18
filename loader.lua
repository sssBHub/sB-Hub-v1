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

local plr = game:GetService("Players").LocalPlayer
local pg = plr and plr:FindFirstChild("PlayerGui")
if pg then
    local old = pg:FindFirstChild("sB_Hub_v1")
    if old then old:Destroy() end
    local oldOverlay = pg:FindFirstChild("sB_Overlays")
    if oldOverlay then oldOverlay:Destroy() end
end

sBHubAlive = true
running = true

local function downloadSource(fileName)
    local url = BASE .. fileName .. "?v=" .. tostring(os.clock()):gsub("%.", "")
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
            warn("[sB Hub] Download retry:", fileName, attempt + 1, "/ 4")
            task.wait(0.75 * attempt)
        end
    end
    error("[sB Hub] Download failed: " .. fileName .. "\n" .. tostring(lastError))
end

local function loadModule(fileName)
    print("[sB Hub] Downloading:", fileName)
    local source = downloadSource(fileName)
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

-- Do not hide errors from the final GUI setup.
local function ensureVisibleGui()
    local currentPlayerGui = plr:FindFirstChild("PlayerGui")
    if not currentPlayerGui then
        error("[sB Hub] PlayerGui missing after module load")
    end

    local screen = currentPlayerGui:FindFirstChild("sB_Hub_v1")
    print("[sB Hub] Post-load GUI lookup:", screen and "FOUND" or "MISSING")

    if not screen then
        error("[sB Hub] sB_Hub_v1 was not created by ui.lua")
    end

    gui = screen
    gui.Parent = currentPlayerGui
    gui.Enabled = true
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100000

    window = window or gui:FindFirstChildWhichIsA("Frame")
    if not window then
        error("[sB Hub] sB_Hub_v1 exists but contains no Frame window")
    end

    window.Parent = gui
    window.Visible = true
    window.ZIndex = math.max(window.ZIndex, 1000)

    for _, object in ipairs(gui:GetDescendants()) do
        if object:IsA("GuiButton") then
            object.Active = true
            pcall(function() object.Interactable = true end)
            object.Selectable = true
        end
    end

    print(
        "[sB Hub] GUI state:",
        "enabled=", tostring(gui.Enabled),
        "parent=", tostring(gui.Parent and gui.Parent.Name),
        "windowVisible=", tostring(window.Visible),
        "windowPosition=", tostring(window.Position)
    )
end

local setupOk, setupErr = pcall(ensureVisibleGui)
if not setupOk then
    warn(tostring(setupErr))

    -- Guaranteed fallback so the executor cannot silently produce nothing.
    local currentPlayerGui = plr:FindFirstChild("PlayerGui")
    if currentPlayerGui then
        local fallback = Instance.new("ScreenGui")
        fallback.Name = "sB_Hub_Diagnostic"
        fallback.ResetOnSpawn = false
        fallback.IgnoreGuiInset = true
        fallback.DisplayOrder = 100001
        fallback.Parent = currentPlayerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(420, 100)
        frame.Position = UDim2.new(0.5, -210, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(220, 80, 80)
        frame.Parent = fallback

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, -20)
        label.Position = UDim2.fromOffset(10, 10)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 14
        label.Font = Enum.Font.Code
        label.TextWrapped = true
        label.Text = "sB Hub UI setup failed.\nCheck console for the exact error."
        label.Parent = frame
    end
else
    print("[sB Hub] GUI visibility setup complete")
end

pcall(function()
    if not gui or not titleBar then
        error("[sB Hub] UI objects were not created")
    end

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