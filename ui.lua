local UI={}
local Players=game:GetService("Players"); local UIS=game:GetService("UserInputService")
local p=Players.LocalPlayer; local pg=p:WaitForChild("PlayerGui")
local gui,window,content; local pages={}; local tabs={}; local cons={}
local C={bg=Color3.fromRGB(16,18,22),panel=Color3.fromRGB(22,25,30),panel2=Color3.fromRGB(28,33,40),group=Color3.fromRGB(20,23,28),border=Color3.fromRGB(52,59,70),text=Color3.fromRGB(240,240,244),muted=Color3.fromRGB(150,157,168),blue=Color3.fromRGB(73,143,215)}
local function con(s,f)local c=s:Connect(f);table.insert(cons,c);return c end
local function group(parent,n,x,y,w,h)local f=Instance.new("Frame");f.Name=n;f.Size=UDim2.fromOffset(w,h);f.Position=UDim2.fromOffset(x,y);f.BackgroundColor3=C.group;f.BorderSizePixel=1;f.BorderColor3=C.border;f.Parent=parent;return f end
local function tog(parent,text,x,y,get,set)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(220,25);b.Position=UDim2.fromOffset(x,y);b.BackgroundColor3=C.panel2;b.BorderSizePixel=1;b.BorderColor3=C.border;b.TextColor3=C.text;b.TextSize=9;b.Font=Enum.Font.Code;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=parent;local function u()b.Text=("%s  [%s]"):format(text,get() and "ON" or "OFF")end;con(b.Activated,function()set(not get());u()end);u();return b end
function UI.Build(Config,Automation,Stats,Spy)
 local old=pg:FindFirstChild("sB_Hub_v1");if old then old:Destroy()end
 gui=Instance.new("ScreenGui");gui.Name="sB_Hub_v1";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=100000;gui.Parent=pg
 window=Instance.new("Frame");window.Size=UDim2.fromOffset(500,600);window.Position=UDim2.new(.5,-250,.5,-300);window.BackgroundColor3=C.bg;window.BorderSizePixel=1;window.BorderColor3=C.border;window.Parent=gui
 local bar=Instance.new("Frame");bar.Size=UDim2.new(1,0,0,34);bar.BackgroundColor3=C.panel;bar.Parent=window
 local title=Instance.new("TextLabel");title.Size=UDim2.fromOffset(250,34);title.Position=UDim2.fromOffset(10,0);title.BackgroundTransparency=1;title.Text="sB Hub v1";title.TextColor3=C.text;title.TextSize=16;title.Font=Enum.Font.Code;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=bar
 local tb=Instance.new("Frame");tb.Size=UDim2.new(1,-10,0,28);tb.Position=UDim2.fromOffset(5,39);tb.BackgroundColor3=C.panel;tb.BorderSizePixel=1;tb.BorderColor3=C.border;tb.Parent=window
 content=Instance.new("Frame");content.Size=UDim2.new(1,-10,1,-76);content.Position=UDim2.fromOffset(5,71);content.BackgroundColor3=C.bg;content.Parent=window
 for i,n in ipairs({"main","automation","stats","esp","notify","spy","settings"}) do
  local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(70,28);b.Position=UDim2.fromOffset((i-1)*70,0);b.BackgroundColor3=C.panel;b.Text=n;b.TextColor3=C.muted;b.TextSize=10;b.Font=Enum.Font.Code;b.Parent=tb;tabs[n]=b
  local page=Instance.new("ScrollingFrame");page.Size=UDim2.fromScale(1,1);page.BackgroundTransparency=1;page.BorderSizePixel=0;page.AutomaticCanvasSize=Enum.AutomaticSize.Y;page.ScrollBarThickness=4;page.Visible=false;page.Parent=content;pages[n]=page
  con(b.Activated,function()for k,v in pairs(pages)do v.Visible=k==n end;title.Text="sB Hub v1  •  "..n;for k,v in pairs(tabs)do v.TextColor3=k==n and C.text or C.muted;v.BackgroundColor3=k==n and C.panel2 or C.panel end end)
 end
 local a=group(pages.automation,"automation",10,10,470,300)
 local keys={"autoTrain","autoRebirth","autoJungleRock","autoEgg","autoUltimates","autoSize","autoSpeed"}
 for i,k in ipairs(keys)do tog(a,k,10,20+(i-1)*35,function()return Config.state[k]end,function(v)Config.state[k]=v;Config.Save()end)end
 local s=group(pages.stats,"session",10,10,470,250)
 local l=Instance.new("TextLabel");l.Size=UDim2.fromOffset(450,220);l.Position=UDim2.fromOffset(10,20);l.BackgroundTransparency=1;l.TextColor3=C.text;l.TextSize=11;l.Font=Enum.Font.Code;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=s
 task.spawn(function()while gui and gui.Parent do task.wait(.5);local x=Stats.Refresh();l.Text=("Strength: %s\nGain: +%s\nStrength/hr: %s\nRebirths: %s\nGain: +%s\nRebirths/hr: %.2f"):format(Stats.Format(x.strength),Stats.Format(x.strengthGain),Stats.Format(x.strengthPerHour),Stats.Format(x.rebirths),Stats.Format(x.rebirthGain),x.rebirthsPerHour)end end)
 pages.main.Visible=true;tabs.main.TextColor3=C.text;tabs.main.BackgroundColor3=C.panel2
 local dragging=false;local ds,sp
con(UIS.InputBegan,function(i,gp)
 if gp then return end
 if i.KeyCode==Enum.KeyCode.RightShift then
  gui.Enabled=not gui.Enabled
 end
end)
 con(bar.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;ds=i.Position;sp=window.Position end end)
 con(UIS.InputChanged,function(i)if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds;window.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
 con(UIS.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
 return gui
end
function UI.Destroy()for _,c in ipairs(cons)do pcall(function()c:Disconnect()end)end;table.clear(cons);if gui then gui:Destroy()end end
return UI
