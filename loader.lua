-- sB Hub v1 - GitHub loader (faithful split)
-- The loader owns cross-module compatibility fixes so the original UI/code
-- can remain close to the uploaded source.
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/12a7841f8723825886f546b282c197c38ce1845d/"

-- Stop/destroy a previous instance before creating another one.
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
        -- Some executor environments do not reliably dispatch Activated.
        -- The original UI uses GuiButton descendants, so direct mouse clicks
        -- are the safest compatibility event for TextButton/ImageButton.
        source = source:gsub("%.Activated", ".MouseButton1Click")
    elseif fileName == "runtime.lua" then
        -- Normalize bare variable statements produced by the split.
        source = source:gsub("[\r\n]+dragStart[ \t]*[\r\n]+startPosition", "\ndragStart = nil\nstartPosition = nil", 1)
        -- Runtime no longer owns title-bar dragging; UI owns it.
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

-- Always-visible emergency unload button.
pcall(function()
    if not gui or not titleBar then return end
    if titleBar:FindFirstChild("sB_KillHub") then return end

    local kill = Instance.new("TextButton")
    kill.Name = "sB_KillHub"
    kill.Size = UDim2.fromOffset(82, 24)
    kill.Position = UDim2.new(1, -90, 0, 5)
    kill.BackgroundColor3 = GUI_COLORS.danger
    kill.BorderSizePixel = 1
    kill.BorderColor3 = GUI_COLORS.border
    kill.Text = "KILL HUB"
    kill.TextColor3 = GUI_COLORS.text
    kill.TextSize = 9
    kill.Font = FONT
    kill.AutoButtonColor = true
    kill.ZIndex = 1005
    kill.Parent = titleBar

    kill.MouseButton1Click:Connect(function()
        running = false

        pcall(function()
            for _, c in ipairs(connections) do
                c:Disconnect()
            end
            table.clear(connections)
        end)

        pcall(function()
            destroyAllESP()
        end)

        pcall(function()
            if jungleBillboard then
                jungleBillboard:Destroy()
            end
        end)

        pcall(function()
            if gui and gui.Parent then gui:Destroy() end
        end)

        pcall(function()
            if overlayGui and overlayGui.Parent then overlayGui:Destroy() end
        end)

        print("[sB Hub] Killed")
    end)
end)

print("[sB Hub] Faithful modular build loaded")
