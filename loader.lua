-- Execute this file with the other Lua modules in the same folder.
local function loadModule(name)
 local raw
 if typeof(readfile)=="function" then
  local ok,data=pcall(readfile,name)
  if ok then raw=data end
 end
 if raw and typeof(loadstring)=="function" then
  local f,err=loadstring(raw,"@"..name)
  assert(f,err)
  return f()
 end
 if typeof(loadfile)=="function" then
  local f,err=loadfile(name)
  assert(f,err)
  return f()
 end
 error("Cannot load "..name..": executor needs readfile/loadstring or loadfile")
end
local Config=loadModule("config.lua")
local Notifications=loadModule("notifications.lua")
local Stats=loadModule("stats.lua")
local Spy=loadModule("spy.lua")
local ESP=loadModule("esp.lua")
local Overlays=loadModule("overlays.lua")
local Automation=loadModule("automation.lua")
local UI=loadModule("ui.lua")
Automation.Start(Config.state)
UI.Build(Config,Automation,Stats,Spy)
local Hub={Config=Config,Notifications=Notifications,Stats=Stats,Spy=Spy,ESP=ESP,Overlays=Overlays,Automation=Automation,UI=UI}
if getgenv then getgenv().sBHub=Hub end
print("[sB Hub] Modular build loaded.")
return Hub
