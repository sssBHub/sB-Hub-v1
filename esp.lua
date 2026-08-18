local ESP={}
local entries={}
function ESP.Enable(state)
 ESP.state=state and true or false
 ESP.active=false -- Rendering is intentionally disabled until source-specific ESP logic is available.
end
function ESP.Disable() for p,e in pairs(entries) do for _,o in pairs(e) do pcall(function() o:Remove() end) end entries[p]=nil end end
function ESP.Update() end
function ESP.Destroy() ESP.Disable() end
return ESP
