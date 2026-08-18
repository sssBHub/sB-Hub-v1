local Spy={}
local Players=game:GetService("Players")
local me=Players.LocalPlayer
local current
local function stat(plr,name)
 local ls=plr:FindFirstChild("leaderstats"); local v=ls and ls:FindFirstChild(name) or plr:FindFirstChild(name)
 if v and v:IsA("ValueBase") then return tonumber(v.Value) or v.Value end
 return "N/A"
end
function Spy.Players()
 local r={}; for _,p in ipairs(Players:GetPlayers()) do if p~=me then table.insert(r,p) end end; return r
end
function Spy.Select(p) if p and p~=me then current=p else current=nil end end
function Spy.GetSelected() return current end
function Spy.Refresh()
 if not current or not current.Parent then return nil end
 local r={Player=current.Name,Display=current.DisplayName}
 for _,n in ipairs({"Strength","Rebirths","Kills","Brawls","Durability","Wins"}) do r[n]=stat(current,n) end
 return r
end
return Spy
