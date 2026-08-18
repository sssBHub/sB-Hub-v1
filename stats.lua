local Stats={}
local Players=game:GetService("Players")
local p=Players.LocalPlayer
local ls=p:WaitForChild("leaderstats",15)
assert(ls,"sB Hub: leaderstats was not found")
local strength=ls:WaitForChild("Strength",15)
local rebirths=ls:WaitForChild("Rebirths",15)
assert(strength and rebirths,"sB Hub: Strength/Rebirths were not found")
local start=os.clock()
local s0=tonumber(strength.Value) or 0
local r0=tonumber(rebirths.Value) or 0
local d0=0
local d=p:FindFirstChild("Durability"); if d then d0=tonumber(d.Value) or 0 end
function Stats.Refresh()
 d=p:FindFirstChild("Durability")
 local e=math.max(1,os.clock()-start)
 local s=tonumber(strength.Value) or 0
 local r=tonumber(rebirths.Value) or 0
 local dv=d and tonumber(d.Value) or 0
 return {elapsed=e,strength=s,strengthGain=math.max(0,s-s0),strengthPerHour=math.max(0,s-s0)/e*3600,
 rebirths=r,rebirthGain=math.max(0,r-r0),rebirthsPerHour=math.max(0,r-r0)/e*3600,
 durability=dv,durabilityGain=math.max(0,dv-d0),durabilityPerHour=math.max(0,dv-d0)/e*3600}
end
function Stats.Format(v)
 v=tonumber(v) or 0; local a=math.abs(v)
 if a>=1e12 then return ("%.2fT"):format(v/1e12) elseif a>=1e9 then return ("%.2fB"):format(v/1e9)
 elseif a>=1e6 then return ("%.2fM"):format(v/1e6) elseif a>=1e3 then return ("%.2fK"):format(v/1e3) end
 return ("%.0f"):format(v)
end
return Stats
