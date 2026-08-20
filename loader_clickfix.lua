local BASE = "https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/"

local function run(url)
    local source = game:HttpGet(url .. "?v=" .. tostring(math.floor(os.clock() * 1000000)))
    local chunk, err = loadstring(source, "@clickfix")
    assert(chunk, err)
    return chunk()
end

-- The stable loader now owns the real UI input handlers. Do not place a
-- second transparent layer over the controls; that causes duplicate toggles.
run(BASE .. "loader.lua")

print("[sB ClickFix] No overlay installed; using native stable hub handlers")
print("[sB ClickFix] Loaded stable hub")
