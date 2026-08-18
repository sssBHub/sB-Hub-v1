local Automation={}
local Players=game:GetService("Players")
local VIM=game:GetService("VirtualInputManager")
local VU=game:GetService("VirtualUser")
local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui")
local backpack=player:WaitForChild("Backpack")
local running=false
local connections={}
local exercise="None"
local rock="OFF"
local ultimate="None"
local function con(s,f) local c=s:Connect(f); table.insert(connections,c); return c end
local function character() local c=player.Character; if not c then return end return c,c:FindFirstChildOfClass("Humanoid"),c:FindFirstChild("HumanoidRootPart") end
local function punch(c) local x=c and c:FindFirstChild("Punch") or backpack:FindFirstChild("Punch"); return x and x:IsA("Tool") and x end
function Automation.Start(state)
 running=true
 con(player.Idled,function() if state.antiAFK and running then pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new(0,0)) end) end end)
 task.spawn(function()
  while running do
   task.wait()
   local c,h=character()
   if state.autoTrain and c and h then
    for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name~="Punch" then exercise=t.Name; pcall(function() t:Activate() end); break end end
   end
  end
 end)
 task.spawn(function()
  while running do
   task.wait(0.08)
   if state.autoEgg then pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.E,false,game); VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game) end) end
  end
 end)
 task.spawn(function()
  while running do
   task.wait()
   local c,h=character()
   if state.autoJungleRock and c and h then local t=punch(c); if t then if t.Parent~=c then pcall(function() h:EquipTool(t) end); task.wait() end; if t.Parent==c then pcall(function() t:Activate() end) end end end
  end
 end)
 task.spawn(function()
  while running do
   task.wait(0.5)
   if state.autoUltimates then
    local g=gui:FindFirstChild("ultimatesGui")
    if g then for _,o in ipairs(g:GetDescendants()) do if o:IsA("GuiButton") then local l=o:FindFirstChild("titleLabel",true); if l and l.Text~="" then ultimate=tostring(l.Text); if typeof(firesignal)=="function" then
  pcall(firesignal,o.Activated)
 elseif o:IsA("GuiButton") then
  pcall(function() o:Activate() end)
 end
 break end end end end
   end
  end
 end)
end
function Automation.Stop() running=false; for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end; table.clear(connections) end
function Automation.Status() return {exercise=exercise,rock=rock,ultimate=ultimate} end
return Automation
