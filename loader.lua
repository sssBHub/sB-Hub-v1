-- sB Hub v1 - GitHub loader (faithful split)
-- Stop an older execution before starting a new one.
if getgenv then
    local env = getgenv()
    env.sBHubRunning = false
end

local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/12a7841f8723825886f546b282c197c38ce1845d/"

local function loadModule(fileName)
    local url = BASE .. fileName
    print("[sB Hub] Downloading:", fileName)

    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error("[sB Hub] Download failed: " .. fileName .. "\n" .. tostring(source))
    end

    if fileName == "runtime.lua" then
        source = source:gsub("[\r\n]+dragStart[ \t]*[\r\n]+startPosition", "\ndragStart = nil\nstartPosition = nil", 1)
        source = source:gsub("dragging = false[ \t]*[\r\n]+dragStart[ \t]*[\r\n]+startPosition", "dragging = false\ndragStart = nil\nstartPosition = nil", 1)
    elseif fileName == "ui.lua" then
        -- TextButton.MouseButton1Click is more consistently delivered by executor environments.
        source = source:gsub("connect%(%s*button%.Activated%s*,", "connect(button.MouseButton1Click,", 1)
        source = source:gsub("connect%(%s*button%.Activated%s*,", "connect(button.MouseButton1Click,", 1)
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

if getgenv then
    getgenv().sBHubRunning = true
end

loadModule("runtime.lua")

print("[sB Hub] Faithful modular build loaded")