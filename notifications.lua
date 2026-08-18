local Notifications={}
local feed={}
function Notifications.AddEvent(text)
 table.insert(feed,1,{time=os.date("%H:%M:%S"),text=tostring(text)})
 while #feed>30 do table.remove(feed) end
end
function Notifications.GetFeed() return feed end
function Notifications.Notify(title,body,color)
 Notifications.AddEvent(("%s: %s"):format(tostring(title),tostring(body)))
end
return Notifications
