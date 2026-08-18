-- sB Hub v1 - GitHub loader (faithful split)
-- Pin the module base to the commit containing the syntax-fixed config.lua.
local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/20fe985aeb7a2a37c908957514205419f147ca0c/"

local function loadModule(fileName)
    local url = BASE .. fileName
    print("[sB Hub] Downloading:", fileName)
    local ok, source = pcall(function() return game:HttpGet(url) end)
    if not ok then error("[sB Hub] Download failed: " .. fileName .. "\n" .. tostring(source)) end
    print("[sB Hub] Downloaded:", fileName, #source, "bytes")
    local chunk, compileError = loadstring(source, "@" .. fileName)
    if not chunk then error("[sB Hub] Compile failed: " .. fileName .. "\n" .. tostring(compileError)) end
    local success, result = pcall(chunk)
    if not success then error("[sB Hub] Runtime error: " .. fileName .. "\n" .. tostring(result)) end
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

print("[sB Hub] Faithful modular build loaded")
