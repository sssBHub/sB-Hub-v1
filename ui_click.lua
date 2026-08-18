gui = Instance.new("ScreenGui")
gui.Name = "sB_Hub_v1"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = playerGui

overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "sB_Overlays"
overlayGui.ResetOnSpawn = false
overlayGui.IgnoreGuiInset = true
overlayGui.DisplayOrder = 99999
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
overlayGui.Parent = playerGui

window = Instance.new("Frame")
window.Size = UDim2.fromOffset(500, 600)
window.Position = UDim2.new(0.5, -250, 0.5, -300)
window.BackgroundColor3 = GUI_COLORS.bg
window.BorderSizePixel = 1
window.BorderColor3 = GUI_COLORS.border
window.ZIndex = 1000
window.Parent = gui

titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = GUI_COLORS.panel
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 1001
titleBar.Parent = window

title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(200, 34)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "sB Hub v1"
title.TextColor3 = GUI_COLORS.text
title.TextSize = 16
title.Font = FONT
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 1002
title.Parent = titleBar

onlineLabel = Instance.new("TextLabel")
onlineLabel.Size = UDim2.fromOffset(120, 34)
onlineLabel.Position = UDim2.new(1, -130, 0, 0)
onlineLabel.BackgroundTransparency = 1
onlineLabel.Text = "● online"
onlineLabel.TextColor3 = GUI_COLORS.green
onlineLabel.TextSize = 11
onlineLabel.Font = FONT
onlineLabel.TextXAlignment = Enum.TextXAlignment.Right
onlineLabel.ZIndex = 1002
onlineLabel.Parent = titleBar

tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -10, 0, 28)
tabBar.Position = UDim2.fromOffset(5, 39)
tabBar.BackgroundColor3 = GUI_COLORS.panel
tabBar.BorderSizePixel = 1
tabBar.BorderColor3 = GUI_COLORS.border
tabBar.ZIndex = 1001
tabBar.Parent = window

content = Instance.new("Frame")
content.Size = UDim2.new(1, -10, 1, -76)
content.Position = UDim2.fromOffset(5, 71)
content.BackgroundColor3 = GUI_COLORS.bg
content.BorderSizePixel = 1
content.BorderColor3 = GUI_COLORS.border
content.ZIndex = 1000
content.Parent = window

tabNames = {"main", "automation", "stats", "esp", "notify", "spy", "settings"}
tabs = {}
pages = {}
tabWidth = 70

for index, name in ipairs(tabNames) do
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.fromOffset(tabWidth, 28)
    button.Position = UDim2.fromOffset((index - 1) * tabWidth, 0)
    button.BackgroundColor3 = GUI_COLORS.panel
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = GUI_COLORS.muted
    button.TextSize = 10
    button.Font = FONT
    button.AutoButtonColor = false
    button.Active = true
    button.Selectable = true
    button.ZIndex = 1002
    button.Parent = tabBar

    local topLine = Instance.new("Frame")
    topLine.Name = "TopLine"
    topLine.Size = UDim2.new(1, 0, 0, 2)
    topLine.BackgroundColor3 = GUI_COLORS.blue
    topLine.BorderSizePixel = 0
    topLine.Visible = false
    topLine.ZIndex = 1003
    topLine.Parent = button

    local shadow = Instance.new("UIStroke")
    shadow.Name = "Shadow"
    shadow.Color = GUI_COLORS.blue
    shadow.Thickness = 1
    shadow.Transparency = 0.65
    shadow.Enabled = false
    shadow.Parent = button

    tabs[name] = button

    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = GUI_COLORS.border
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 1001
    page.Parent = content

    pages[name] = page
end

function makeGroup(parent, name, x, y, width, height)
    local group = Instance.new("Frame")
    group.Size = UDim2.fromOffset(width, height)
    group.Position = UDim2.fromOffset(x, y)
    group.BackgroundColor3 = GUI_COLORS.group
    group.BorderSizePixel = 1
    group.BorderColor3 = GUI_COLORS.border
    group.ZIndex = 1002
    group.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 22)
    label.Position = UDim2.fromOffset(6, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = GUI_COLORS.muted
    label.TextSize = 11
    label.Font = FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1003
    label.Parent = group

    return group
end

function makeToggle(parent, text, x, y, getter, setter, width)
    width = width or 220
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(width, 27)
    button.Position = UDim2.fromOffset(x, y)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Active = true
    button.Selectable = true
    button.ZIndex = 1003
    button.Parent = parent

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(12, 12)
    box.Position = UDim2.fromOffset(5, 7)
    box.BackgroundColor3 = GUI_COLORS.off
    box.BorderSizePixel = 1
    box.BorderColor3 = GUI_COLORS.border
    box.ZIndex = 1004
    box.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -25, 1, 0)
    label.Position = UDim2.fromOffset(23, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = GUI_COLORS.text
    label.TextSize = 11
    label.Font = FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1004
    label.Parent = button

    local function render()
        local enabled = getter()
        box.BackgroundColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.off
        box.BorderColor3 = enabled and GUI_COLORS.blue or GUI_COLORS.border
    end

    connect(button.MouseButton1Click, function()
        setter(not getter())
        render()
        saveConfig()
    end)

    render()
    return button
end

function makeInput(parent, labelText, x, y, width, value, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(width, 17)
    label.Position = UDim2.fromOffset(x, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = GUI_COLORS.muted
    label.TextSize = 9
    label.Font = FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1004
    label.Parent = parent

    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(width, 23)
    box.Position = UDim2.fromOffset(x, y + 16)
    box.BackgroundColor3 = GUI_COLORS.panel2
    box.BorderSizePixel = 1
    box.BorderColor3 = GUI_COLORS.border
    box.Text = tostring(value)
    box.TextColor3 = GUI_COLORS.text
    box.TextSize = 10
    box.Font = FONT
    box.ClearTextOnFocus = false
    box.Active = true
    box.ZIndex = 1004
    box.Parent = parent

    connect(box.FocusLost, function()
        callback(box.Text)
        saveConfig()
    end)

    return box
end

function makeStat(parent, text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(210, 23)
    label.Position = UDim2.fromOffset(10, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = GUI_COLORS.muted
    label.TextSize = 10
    label.Font = FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1004
    label.Parent = parent

    local value = Instance.new("TextLabel")
    value.Size = UDim2.fromOffset(220, 23)
    value.Position = UDim2.fromOffset(245, y)
    value.BackgroundTransparency = 1
    value.Text = "..."
    value.TextColor3 = GUI_COLORS.text
    value.TextSize = 10
    value.Font = FONT
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.ZIndex = 1004
    value.Parent = parent

    return value
end

function makeModeButton(parent, x, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(80, 23)
    button.Position = UDim2.fromOffset(x, y)
    button.BackgroundColor3 = GUI_COLORS.panel2
    button.BorderSizePixel = 1
    button.BorderColor3 = GUI_COLORS.border
    button.TextColor3 = GUI_COLORS.text
    button.TextSize = 9
    button.Font = FONT
    button.AutoButtonColor = false
    button.Active = true
    button.Selectable = true
    button.ZIndex = 1004
    button.Parent = parent
    return button
end

function showTab(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(tabs) do
        local selected = tabName == name
        button.BackgroundColor3 = selected and GUI_COLORS.panel2 or GUI_COLORS.panel
        button.TextColor3 = selected and GUI_COLORS.text or GUI_COLORS.muted
        local line = button:FindFirstChild("TopLine")
        if line then line.Visible = selected end
        local shadow = button:FindFirstChild("Shadow")
        if shadow and shadow:IsA("UIStroke") then shadow.Enabled = selected end
    end
end

function addEvent(text)
    table.insert(notificationFeed, 1, {time = os.date("%H:%M:%S"), text = tostring(text)})
    while #notificationFeed > 30 do table.remove(notificationFeed) end
end

function notify(titleText, bodyText, color)
    if not state.notifications then return end
    local toast = Instance.new("Frame")
    toast.Size = UDim2.fromOffset(260, 66)
    toast.Position = UDim2.new(1, -280, 0, 20 + (#notifications * 75))
    toast.BackgroundColor3 = GUI_COLORS.panel
    toast.BorderSizePixel = 1
    toast.BorderColor3 = color or GUI_COLORS.blue
    toast.ZIndex = 10000
    toast.Parent = overlayGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -12, 0, 21)
    titleLabel.Position = UDim2.fromOffset(6, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = tostring(titleText)
    titleLabel.TextColor3 = color or GUI_COLORS.blue
    titleLabel.TextSize = 12
    titleLabel.Font = FONT
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 10001
    titleLabel.Parent = toast

    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Size = UDim2.new(1, -12, 1, -27)
    bodyLabel.Position = UDim2.fromOffset(6, 25)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Text = tostring(bodyText)
    bodyLabel.TextColor3 = GUI_COLORS.text
    bodyLabel.TextSize = 10
    bodyLabel.Font = FONT
    bodyLabel.TextWrapped = true
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.ZIndex = 10001
    bodyLabel.Parent = toast

    table.insert(notifications, toast)
    addEvent(tostring(titleText) .. " - " .. tostring(bodyText))

    task.delay(4, function()
        pcall(function() toast:Destroy() end)
        for i, item in ipairs(notifications) do
            if item == toast then table.remove(notifications, i) break end
        end
        for i, item in ipairs(notifications) do
            if item and item.Parent then
                item.Position = UDim2.new(1, -280, 0, 20 + ((i - 1) * 75))
            end
        end
    end)
end

for name, button in pairs(tabs) do
    connect(button.MouseButton1Click, function()
        showTab(name)
    end)
end

mainPage = pages.main
progressGroup = makeGroup(mainPage, "rebirth progress", 10, 10, 470, 90)
progressText = Instance.new("TextLabel")
progressText.Size = UDim2.fromOffset(450, 20)
progressText.Position = UDim2.fromOffset(10, 23)
progressText.BackgroundTransparency = 1
progressText.Text = "Waiting for rebirth data..."
progressText.TextColor3 = GUI_COLORS.text
progressText.TextSize = 11
progressText.Font = FONT
progressText.TextXAlignment = Enum.TextXAlignment.Left
progressText.Parent = progressGroup
progressBar = Instance.new("Frame")
progressBar.Size = UDim2.fromOffset(280, 12)
progressBar.Position = UDim2.fromOffset(10, 50)
progressBar.BackgroundColor3 = GUI_COLORS.off
progressBar.BorderSizePixel = 0
progressBar.Parent = progressGroup
progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = GUI_COLORS.blue
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar
progressPercent = Instance.new("TextLabel")
progressPercent.Size = UDim2.fromOffset(90, 18)
progressPercent.Position = UDim2.fromOffset(300, 47)
progressPercent.BackgroundTransparency = 1
progressPercent.Text = "0.0%"
progressPercent.TextColor3 = GUI_COLORS.muted
progressPercent.TextSize = 10
progressPercent.Font = FONT
progressPercent.Parent = progressGroup

mainLeft = makeGroup(mainPage, "automation", 10, 110, 230, 255)
makeToggle(mainLeft, "auto train", 8, 28, function() return state.autoTrain end, function(v) state.autoTrain = v end)
makeToggle(mainLeft, "auto rebirth", 8, 55, function() return state.autoRebirth end, function(v) state.autoRebirth = v end)
makeToggle(mainLeft, "rebirth limit", 8, 82, function() return state.rebirthLimit end, function(v) state.rebirthLimit = v end)
makeToggle(mainLeft, "skip rebirth animation", 8, 109, function() return state.skipRebirthAnimation end, function(v) state.skipRebirthAnimation = v end)
makeInput(mainLeft, "target rebirth", 8, 145, 105, state.rebirthTarget, function(value) local n=tonumber(value); if n then state.rebirthTarget=math.max(0, math.floor(n)) end end)
activityText = Instance.new("TextLabel")
activityText.Size = UDim2.fromOffset(205, 75)
activityText.Position = UDim2.fromOffset(8, 194)
activityText.BackgroundTransparency = 1
activityText.Text = "Loading..."
activityText.TextColor3 = GUI_COLORS.muted
activityText.TextSize = 9
activityText.Font = FONT
activityText.TextXAlignment = Enum.TextXAlignment.Left
activityText.TextYAlignment = Enum.TextYAlignment.Top
activityText.Parent = mainLeft

mainRight = makeGroup(mainPage, "what am i doing?", 250, 110, 230, 255)
currentActivity = Instance.new("TextLabel")
currentActivity.Size = UDim2.fromOffset(210, 205)
currentActivity.Position = UDim2.fromOffset(8, 28)
currentActivity.BackgroundTransparency = 1
currentActivity.Text = "Loading..."
currentActivity.TextColor3 = GUI_COLORS.muted
currentActivity.TextSize = 10
currentActivity.Font = FONT
currentActivity.TextXAlignment = Enum.TextXAlignment.Left
currentActivity.TextYAlignment = Enum.TextYAlignment.Top
currentActivity.TextWrapped = true
currentActivity.Parent = mainRight

automationPage = pages.automation
automationGroup = makeGroup(automationPage, "automation", 10, 10, 230, 190)
makeToggle(automationGroup, "auto jungle rock", 8, 28, function() return state.autoJungleRock end, function(v) state.autoJungleRock = v end)
makeToggle(automationGroup, "auto egg", 8, 55, function() return state.autoEgg end, function(v) state.autoEgg = v end)
makeToggle(automationGroup, "auto ultimates", 8, 82, function() return state.autoUltimates end, function(v) state.autoUltimates = v end)
makeToggle(automationGroup, "auto size", 8, 109, function() return state.autoSize end, function(v) state.autoSize = v end)
makeToggle(automationGroup, "auto speed", 8, 136, function() return state.autoSpeed end, function(v) state.autoSpeed = v end)

sizeSpeedGroup = makeGroup(automationPage, "size / speed", 250, 10, 230, 245)
sizeMode = makeModeButton(sizeSpeedGroup, 90, 28)
sizeMode.Text = state.sizeMode == "Max" and "MAX" or "CUSTOM"
sizeModeLabel = Instance.new("TextLabel")
sizeModeLabel.Size = UDim2.fromOffset(78, 22)
sizeModeLabel.Position = UDim2.fromOffset(8, 29)
sizeModeLabel.BackgroundTransparency = 1
sizeModeLabel.Text = "size mode"
sizeModeLabel.TextColor3 = GUI_COLORS.muted
sizeModeLabel.TextSize = 9
sizeModeLabel.Font = FONT
sizeModeLabel.Parent = sizeSpeedGroup
sizeCustom = makeInput(sizeSpeedGroup, "custom size", 8, 65, 110, state.sizeCustom, function(value) local n=tonumber(value); if n then state.sizeCustom=n end end)
speedMode = makeModeButton(sizeSpeedGroup, 90, 114)
speedMode.Text = state.speedMode == "Max" and "MAX" or "CUSTOM"
speedModeLabel = Instance.new("TextLabel")
speedModeLabel.Size = UDim2.fromOffset(78, 22)
speedModeLabel.Position = UDim2.fromOffset(8, 115)
speedModeLabel.BackgroundTransparency = 1
speedModeLabel.Text = "speed mode"
speedModeLabel.TextColor3 = GUI_COLORS.muted
speedModeLabel.TextSize = 9
speedModeLabel.Font = FONT
speedModeLabel.Parent = sizeSpeedGroup
speedCustom = makeInput(sizeSpeedGroup, "custom speed", 8, 151, 110, state.speedCustom, function(value) local n=tonumber(value); if n then state.speedCustom=n end end)
recoveryText = Instance.new("TextLabel")
recoveryText.Size = UDim2.fromOffset(210, 58)
recoveryText.Position = UDim2.fromOffset(8, 200)
recoveryText.BackgroundTransparency = 1
recoveryText.Text = "Respawn recovery: ON\nRock recovery: ON\nTool reacquire: ON"
recoveryText.TextColor3 = GUI_COLORS.muted
recoveryText.TextSize = 9
recoveryText.Font = FONT
recoveryText.Parent = sizeSpeedGroup
connect(sizeMode.MouseButton1Click, function()
    state.sizeMode = state.sizeMode == "Max" and "Custom" or "Max"
    sizeMode.Text = state.sizeMode == "Max" and "MAX" or "CUSTOM"
    saveConfig()
end)
connect(speedMode.MouseButton1Click, function()
    state.speedMode = state.speedMode == "Max" and "Custom" or "Max"
    speedMode.Text = state.speedMode == "Max" and "MAX" or "CUSTOM"
    saveConfig()
end)

statsPage = pages.stats
statsGroup = makeGroup(statsPage, "session", 10, 10, 470, 405)
sessionValue = makeStat(statsGroup, "session", 28)
strengthStartValue = makeStat(statsGroup, "strength start", 52)
strengthCurrentValue = makeStat(statsGroup, "strength", 76)
strengthGainValue = makeStat(statsGroup, "strength gained", 100)
strengthHourValue = makeStat(statsGroup, "strength / hour", 124)
rebirthStartValue = makeStat(statsGroup, "rebirth start", 148)
rebirthCurrentValue = makeStat(statsGroup, "rebirths", 172)
rebirthGainValue = makeStat(statsGroup, "rebirths gained", 196)
rebirthHourValue = makeStat(statsGroup, "rebirths / hour", 220)
gemsValue = makeStat(statsGroup, "gems", 244)
durabilityValue = makeStat(statsGroup, "durability", 268)
durabilityHourValue = makeStat(statsGroup, "durability / hour", 292)
exerciseValue = makeStat(statsGroup, "exercise", 316)
rockValue = makeStat(statsGroup, "jungle rock", 340)
fpsValue = makeStat(statsGroup, "fps", 364)
petGroup = makeGroup(statsPage, "pet loadout analyzer", 10, 425, 470, 180)
petStatsText = Instance.new("TextLabel")
petStatsText.Size = UDim2.fromOffset(450, 150)
petStatsText.Position = UDim2.fromOffset(10, 25)
petStatsText.BackgroundTransparency = 1
petStatsText.TextColor3 = GUI_COLORS.muted
petStatsText.TextSize = 9
petStatsText.Font = FONT
petStatsText.TextXAlignment = Enum.TextXAlignment.Left
petStatsText.TextYAlignment = Enum.TextYAlignment.Top
petStatsText.Parent = petGroup

notifyPage = pages.notify
notifyGroup = makeGroup(notifyPage, "notifications", 10, 10, 230, 250)
makeToggle(notifyGroup, "notifications", 8, 28, function() return state.notifications end, function(v) state.notifications = v end)
makeToggle(notifyGroup, "pet notifications", 8, 55, function() return state.petNotifications end, function(v) state.petNotifications = v end)
makeToggle(notifyGroup, "aura notifications", 8, 82, function() return state.auraNotifications end, function(v) state.auraNotifications = v end)
makeToggle(notifyGroup, "rarity alerts", 8, 109, function() return state.rarityNotifications end, function(v) state.rarityNotifications = v end)
makeToggle(notifyGroup, "basic", 8, 136, function() return state.rareBasic end, function(v) state.rareBasic = v end)
makeToggle(notifyGroup, "rare", 8, 163, function() return state.rareRare end, function(v) state.rareRare = v end)
makeToggle(notifyGroup, "epic", 8, 190, function() return state.rareEpic end, function(v) state.rareEpic = v end)
notifyGroup2 = makeGroup(notifyPage, "rare filters", 250, 10, 230, 250)
makeToggle(notifyGroup2, "unique", 8, 28, function() return state.rareUnique end, function(v) state.rareUnique = v end)
makeToggle(notifyGroup2, "advanced", 8, 55, function() return state.rareAdvanced end, function(v) state.rareAdvanced = v end)
petSelectionText = Instance.new("TextLabel")
petSelectionText.Size = UDim2.fromOffset(210, 100)
petSelectionText.Position = UDim2.fromOffset(8, 88)
petSelectionText.BackgroundTransparency = 1
petSelectionText.Text = "Selected pets:\nNone"
petSelectionText.TextColor3 = GUI_COLORS.muted
petSelectionText.TextSize = 9
petSelectionText.Font = FONT
petSelectionText.TextXAlignment = Enum.TextXAlignment.Left
petSelectionText.TextYAlignment = Enum.TextYAlignment.Top
petSelectionText.TextWrapped = true
petSelectionText.Parent = notifyGroup2
refreshPetListButton = Instance.new("TextButton")
refreshPetListButton.Size = UDim2.fromOffset(105, 24)
refreshPetListButton.Position = UDim2.fromOffset(115, 197)
refreshPetListButton.BackgroundColor3 = GUI_COLORS.panel2
refreshPetListButton.BorderSizePixel = 1
refreshPetListButton.BorderColor3 = GUI_COLORS.border
refreshPetListButton.Text = "PET LIST"
refreshPetListButton.TextColor3 = GUI_COLORS.text
refreshPetListButton.TextSize = 9
refreshPetListButton.Font = FONT
refreshPetListButton.AutoButtonColor = false
refreshPetListButton.Active = true
refreshPetListButton.Parent = notifyGroup2

historyGroup = makeGroup(notifyPage, "notification history", 10, 270, 470, 285)
historyText = Instance.new("TextLabel")
historyText.Size = UDim2.fromOffset(450, 245)
historyText.Position = UDim2.fromOffset(10, 28)
historyText.BackgroundTransparency = 1
historyText.TextColor3 = GUI_COLORS.muted
historyText.TextSize = 9
historyText.Font = FONT
historyText.TextXAlignment = Enum.TextXAlignment.Left
historyText.TextYAlignment = Enum.TextYAlignment.Top
historyText.TextWrapped = true
historyText.Parent = historyGroup
crystalGroup = makeGroup(notifyPage, "crystal statistics", 10, 565, 470, 110)
crystalText = Instance.new("TextLabel")
crystalText.Size = UDim2.fromOffset(450, 80)
crystalText.Position = UDim2.fromOffset(10, 25)
crystalText.BackgroundTransparency = 1
crystalText.TextColor3 = GUI_COLORS.muted
crystalText.TextSize = 9
crystalText.Font = FONT
crystalText.TextXAlignment = Enum.TextXAlignment.Left
crystalText.Parent = crystalGroup

espPage = pages.esp
espGroup = makeGroup(espPage, "player esp", 10, 10, 230, 285)
makeToggle(espGroup, "esp", 8, 28, function() return state.esp end, function(v) state.esp = v end)
makeToggle(espGroup, "boxes", 8, 55, function() return state.espBoxes end, function(v) state.espBoxes = v end)
makeToggle(espGroup, "names", 8, 82, function() return state.espNames end, function(v) state.espNames = v end)
makeToggle(espGroup, "distance", 8, 109, function() return state.espDistance end, function(v) state.espDistance = v end)
makeToggle(espGroup, "health", 8, 136, function() return state.espHealth end, function(v) state.espHealth = v end)
makeToggle(espGroup, "tracers", 8, 163, function() return state.espTracers end, function(v) state.espTracers = v end)
makeToggle(espGroup, "team check", 8, 190, function() return state.espTeamCheck end, function(v) state.espTeamCheck = v end)
makeInput(espGroup, "max distance", 8, 222, 105, state.espMaxDistance, function(value) local n=tonumber(value); if n then state.espMaxDistance=math.max(50,n) end end)
coordsGroup = makeGroup(espPage, "coordinates", 250, 10, 230, 285)
makeToggle(coordsGroup, "coordinates", 8, 28, function() return state.coords end, function(v) state.coords = v end)
makeToggle(coordsGroup, "compass", 8, 55, function() return state.coordsCompass end, function(v) state.coordsCompass = v end)
makeToggle(coordsGroup, "heading", 8, 82, function() return state.coordsHeading end, function(v) state.coordsHeading = v end)
makeToggle(coordsGroup, "pitch", 8, 109, function() return state.coordsPitch end, function(v) state.coordsPitch = v end)

spyPage = pages.spy
spyGroup = makeGroup(spyPage, "server spy", 10, 10, 470, 230)
spyPlayerText = Instance.new("TextButton")
spyPlayerText.Size = UDim2.fromOffset(220, 27)
spyPlayerText.Position = UDim2.fromOffset(10, 28)
spyPlayerText.BackgroundColor3 = GUI_COLORS.panel2
spyPlayerText.BorderSizePixel = 1
spyPlayerText.BorderColor3 = GUI_COLORS.border
spyPlayerText.Text = "select player"
spyPlayerText.TextColor3 = GUI_COLORS.text
spyPlayerText.TextSize = 9
spyPlayerText.Font = FONT
spyPlayerText.AutoButtonColor = false
spyPlayerText.Active = true
spyPlayerText.Parent = spyGroup
refreshSpy = Instance.new("TextButton")
refreshSpy.Size = UDim2.fromOffset(100, 27)
refreshSpy.Position = UDim2.fromOffset(245, 28)
refreshSpy.BackgroundColor3 = GUI_COLORS.panel2
refreshSpy.BorderSizePixel = 1
refreshSpy.BorderColor3 = GUI_COLORS.border
refreshSpy.Text = "REFRESH"
refreshSpy.TextColor3 = GUI_COLORS.text
refreshSpy.TextSize = 9
refreshSpy.Font = FONT
refreshSpy.AutoButtonColor = false
refreshSpy.Active = true
refreshSpy.Parent = spyGroup
makeToggle(spyGroup, "auto refresh", 350, 28, function() return state.serverSpyAutoRefresh end, function(v) state.serverSpyAutoRefresh = v end, 110)
spyText = Instance.new("TextLabel")
spyText.Size = UDim2.fromOffset(450, 155)
spyText.Position = UDim2.fromOffset(10, 65)
spyText.BackgroundTransparency = 1
spyText.Text = "Select a player."
spyText.TextColor3 = GUI_COLORS.muted
spyText.TextSize = 9
spyText.Font = FONT
spyText.TextXAlignment = Enum.TextXAlignment.Left
spyText.TextYAlignment = Enum.TextYAlignment.Top
spyText.Parent = spyGroup
spyList = Instance.new("ScrollingFrame")
spyList.Size = UDim2.fromOffset(220, 160)
spyList.Position = UDim2.fromOffset(10, 60)
spyList.BackgroundColor3 = GUI_COLORS.panel
spyList.BorderSizePixel = 1
spyList.BorderColor3 = GUI_COLORS.border
spyList.Visible = false
spyList.AutomaticCanvasSize = Enum.AutomaticSize.Y
spyList.ScrollBarThickness = 3
spyList.Parent = spyGroup

settingsPage = pages.settings
overlayGroup = makeGroup(settingsPage, "overlays", 10, 10, 230, 175)
makeToggle(overlayGroup, "automation status", 8, 28, function() return state.automationOverlay end, function(v) state.automationOverlay = v end)
makeToggle(overlayGroup, "performance monitor", 8, 55, function() return state.performanceOverlay end, function(v) state.performanceOverlay = v end)
makeToggle(overlayGroup, "anti afk", 8, 82, function() return state.antiAFK end, function(v) state.antiAFK = v end)
makeToggle(overlayGroup, "mute strength", 8, 109, function() return state.muteStrength end, function(v) state.muteStrength = v end)
makeToggle(overlayGroup, "mute rebirth", 8, 136, function() return state.muteRebirth end, function(v) state.muteRebirth = v end)
goalGroup = makeGroup(settingsPage, "goal", 250, 10, 230, 175)
goalType = Instance.new("TextButton")
goalType.Size = UDim2.fromOffset(100, 24)
goalType.Position = UDim2.fromOffset(8, 30)
goalType.BackgroundColor3 = GUI_COLORS.panel2
goalType.BorderSizePixel = 1
goalType.BorderColor3 = GUI_COLORS.border
goalType.Text = goal.type
goalType.TextColor3 = GUI_COLORS.text
goalType.TextSize = 9
goalType.Font = FONT
goalType.AutoButtonColor = false
goalType.Active = true
goalType.Parent = goalGroup
goalInput = makeInput(goalGroup, "target", 120, 30, 95, goal.target, function(value) local n=tonumber(value); if n then goal.target=n end end)
makeToggle(goalGroup, "goal enabled", 8, 85, function() return goal.enabled end, function(v) goal.enabled = v end)
goalProgress = Instance.new("TextLabel")
goalProgress.Size = UDim2.fromOffset(207, 50)
goalProgress.Position = UDim2.fromOffset(8, 115)
goalProgress.BackgroundTransparency = 1
goalProgress.TextColor3 = GUI_COLORS.muted
goalProgress.TextSize = 9
goalProgress.Font = FONT
goalProgress.TextYAlignment = Enum.TextYAlignment.Top
goalProgress.Parent = goalGroup

hotkeyGroup = makeGroup(settingsPage, "hotkeys", 10, 195, 470, 330)
hotkeyScroll = Instance.new("ScrollingFrame")
hotkeyScroll.Size = UDim2.fromOffset(450, 290)
hotkeyScroll.Position = UDim2.fromOffset(10, 28)
hotkeyScroll.BackgroundTransparency = 1
hotkeyScroll.BorderSizePixel = 0
hotkeyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
hotkeyScroll.ScrollBarThickness = 3
hotkeyScroll.Parent = hotkeyGroup
hotkeyRows = {}
hotkeyNames = {{"autoTrain", "Auto Train"},{"autoRebirth", "Auto Rebirth"},{"rebirthLimit", "Rebirth Limit"},{"autoJungleRock", "Auto Jungle Rock"},{"autoEgg", "Auto Egg"},{"autoUltimates", "Auto Ultimates"},{"autoSize", "Auto Size"},{"autoSpeed", "Auto Speed"},{"skipRebirthAnimation", "Skip Rebirth"},{"antiAFK", "Anti AFK"},{"esp", "ESP"},{"coords", "Coordinates"},{"automationOverlay", "Automation Overlay"},{"performanceOverlay", "Performance Monitor"},{"notifications", "Notifications"}}
function keyToText(key) return key and key.Name or "-" end
for i, entry in ipairs(hotkeyNames) do
    local keyName = entry[1]
    local displayName = entry[2]
    local row = Instance.new("Frame")
    row.Size = UDim2.fromOffset(430, 27)
    row.Position = UDim2.fromOffset(0, (i - 1) * 29)
    row.BackgroundTransparency = 1
    row.Parent = hotkeyScroll
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(280, 27)
    label.BackgroundTransparency = 1
    label.Text = displayName
    label.TextColor3 = GUI_COLORS.text
    label.TextSize = 9
    label.Font = FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.fromOffset(100, 23)
    keyButton.Position = UDim2.fromOffset(290, 2)
    keyButton.BackgroundColor3 = GUI_COLORS.panel2
    keyButton.BorderSizePixel = 1
    keyButton.BorderColor3 = GUI_COLORS.border
    keyButton.Text = keyToText(hotkeys[keyName])
    keyButton.TextColor3 = GUI_COLORS.text
    keyButton.TextSize = 9
    keyButton.Font = FONT
    keyButton.AutoButtonColor = false
    keyButton.Active = true
    keyButton.Parent = row
    hotkeyRows[keyName] = keyButton
    connect(keyButton.MouseButton1Click, function()
        hotkeyCapture = keyName
        keyButton.Text = "PRESS KEY"
    end)
end

unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.fromOffset(110, 30)
unloadButton.Position = UDim2.fromOffset(10, 535)
unloadButton.BackgroundColor3 = GUI_COLORS.danger
unloadButton.BorderSizePixel = 1
unloadButton.BorderColor3 = GUI_COLORS.border
unloadButton.Text = "UNLOAD"
unloadButton.TextColor3 = GUI_COLORS.text
unloadButton.TextSize = 9
unloadButton.Font = FONT
unloadButton.AutoButtonColor = false
unloadButton.Active = true
unloadButton.Selectable = true
unloadButton.Parent = settingsPage

coordsOverlay = Instance.new("Frame")
coordsOverlay.Size = UDim2.fromOffset(250, 120)
coordsOverlay.Position = UDim2.fromOffset(12, 12)
coordsOverlay.BackgroundColor3 = GUI_COLORS.panel
coordsOverlay.BackgroundTransparency = 0.12
coordsOverlay.BorderSizePixel = 1
coordsOverlay.BorderColor3 = GUI_COLORS.border
coordsOverlay.Visible = false
coordsOverlay.Parent = overlayGui
coordsText = Instance.new("TextLabel")
coordsText.Size = UDim2.fromScale(1, 1)
coordsText.Position = UDim2.fromOffset(8, 6)
coordsText.BackgroundTransparency = 1
coordsText.TextColor3 = GUI_COLORS.text
coordsText.TextSize = 10
coordsText.Font = FONT
coordsText.TextXAlignment = Enum.TextXAlignment.Left
coordsText.TextYAlignment = Enum.TextYAlignment.Top
coordsText.Parent = coordsOverlay
performanceOverlay = Instance.new("Frame")
performanceOverlay.Size = UDim2.fromOffset(180, 72)
performanceOverlay.Position = UDim2.new(1, -192, 1, -84)
performanceOverlay.BackgroundColor3 = GUI_COLORS.panel
performanceOverlay.BackgroundTransparency = 0.12
performanceOverlay.BorderSizePixel = 1
performanceOverlay.BorderColor3 = GUI_COLORS.border
performanceOverlay.Visible = false
performanceOverlay.Parent = overlayGui
performanceText = Instance.new("TextLabel")
performanceText.Size = UDim2.fromScale(1, 1)
performanceText.Position = UDim2.fromOffset(8, 5)
performanceText.BackgroundTransparency = 1
performanceText.TextColor3 = GUI_COLORS.text
performanceText.TextSize = 9
performanceText.Font = FONT
performanceText.TextXAlignment = Enum.TextXAlignment.Left
performanceText.TextYAlignment = Enum.TextYAlignment.Top
performanceText.Parent = performanceOverlay
automationOverlay = Instance.new("Frame")
automationOverlay.Size = UDim2.fromOffset(200, 165)
automationOverlay.Position = UDim2.new(0, 12, 0.5, -80)
automationOverlay.BackgroundColor3 = GUI_COLORS.panel
automationOverlay.BackgroundTransparency = 0.12
automationOverlay.BorderSizePixel = 1
automationOverlay.BorderColor3 = GUI_COLORS.border
automationOverlay.Visible = false
automationOverlay.Parent = overlayGui
automationOverlayText = Instance.new("TextLabel")
automationOverlayText.Size = UDim2.fromScale(1, 1)
automationOverlayText.Position = UDim2.fromOffset(8, 5)
automationOverlayText.BackgroundTransparency = 1
automationOverlayText.TextColor3 = GUI_COLORS.text
automationOverlayText.TextSize = 9
automationOverlayText.Font = FONT
automationOverlayText.TextXAlignment = Enum.TextXAlignment.Left
automationOverlayText.TextYAlignment = Enum.TextYAlignment.Top
automationOverlayText.Parent = automationOverlay
