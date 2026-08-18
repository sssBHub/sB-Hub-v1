-- sB Hub v1 - config.lua
local Config = {}
Config.state = {
 autoTrain=false, autoRebirth=false, rebirthLimit=false, rebirthTarget=1000,
 autoJungleRock=false, autoEgg=false, autoUltimates=false,
 autoSize=false, autoSpeed=false, sizeMode="Max", speedMode="Max",
 sizeCustom=2, speedCustom=93, skipRebirthAnimation=false, antiAFK=false,
 esp=false, espBoxes=true, espNames=true, espDistance=true, espHealth=true,
 espTracers=false, espTeamCheck=false, espMaxDistance=1500,
 coords=false, coordsCompass=true, coordsHeading=true, coordsPitch=true,
 automationOverlay=true, performanceOverlay=true,
 notifications=true, petNotifications=true, auraNotifications=true,
 rarityNotifications=true, rareBasic=false, rareRare=false, rareEpic=true,
 rareUnique=true, rareAdvanced=true, serverSpyAutoRefresh=true,
 muteStrength=false, muteRebirth=false
}
Config.goal={type="Strength",target=100000000,enabled=false}
Config.hotkeys={autoTrain=nil,autoRebirth=nil,rebirthLimit=nil,autoJungleRock=nil,
 autoEgg=nil,autoUltimates=nil,autoSize=nil,autoSpeed=nil,skipRebirthAnimation=nil,
 antiAFK=nil,esp=nil,coords=nil,automationOverlay=nil,performanceOverlay=nil,
 notifications=nil,autoPetNotifications=nil,autoAuraNotifications=nil}
Config.selectedPets={}
Config.selectedAuras={}
Config.saveName="sBHub_v1_Settings.json"
local HttpService=game:GetService("HttpService")
local function merge(dst,src) if type(src)=="table" then for k,v in pairs(src) do if dst[k]~=nil then dst[k]=v end end end end
function Config.Load()
 local data
 local env=getgenv and getgenv()
 if env and env.sBHubSavedConfig then data=env.sBHubSavedConfig end
 if not data and typeof(isfile)=="function" and typeof(readfile)=="function" and isfile(Config.saveName) then
  local ok,raw=pcall(readfile,Config.saveName)
  if ok and raw then local good,value=pcall(HttpService.JSONDecode,HttpService,raw); if good then data=value end end
 end
 if type(data)~="table" then return end
 merge(Config.state,data.state); merge(Config.goal,data.goal); merge(Config.hotkeys,data.hotkeys)
 if type(data.selectedPets)=="table" then Config.selectedPets=data.selectedPets end
 if type(data.selectedAuras)=="table" then Config.selectedAuras=data.selectedAuras end
end
function Config.Save()
 local data={state=Config.state,goal=Config.goal,hotkeys=Config.hotkeys,selectedPets=Config.selectedPets,selectedAuras=Config.selectedAuras}
 local ok,encoded=pcall(HttpService.JSONEncode,HttpService,data)
 if not ok then return end
 if typeof(writefile)=="function" then pcall(function() writefile(Config.saveName,encoded) end) end
 local env=getgenv and getgenv(); if env then env.sBHubSavedConfig=data end
end
Config.Load()
return Config
