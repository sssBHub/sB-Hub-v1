-- Faithful split from the uploaded original sB Hub source.
function scanPetPool()
    local names = {}

    local runtime =
        ReplicatedStorage
            :FindFirstChild("shared")
            and
            ReplicatedStorage.shared:FindFirstChild(
                "runtime"
            )

    local petFolder =
        runtime
        and
        runtime:FindFirstChild(
            "cPetShopFolder"
        )

    if petFolder then
        for _, obj in ipairs(
            petFolder:GetChildren()
        ) do
            if obj.Name ~= "" then
                names[obj.Name] = true
            end
        end
    end

    local pets =
        player:FindFirstChild(
            "petsFolder"
        )

    if pets then
        for _, rarity in ipairs(
            pets:GetChildren()
        ) do
            for _, pet in ipairs(
                rarity:GetChildren()
            ) do
                names[pet.Name] = true
            end
        end
    end

    local list = {}

    for name in pairs(names) do
        table.insert(list, name)
    end

    table.sort(list)

    return list
end

function scanAuraPool()
    local names = {}

    local pets =
        player:FindFirstChild(
            "powerUpsFolder"
        )

    if pets then
        for _, rarity in ipairs(
            pets:GetChildren()
        ) do
            for _, aura in ipairs(
                rarity:GetChildren()
            ) do
                names[aura.Name] = true
            end
        end
    end

    if gameGui then
        local boosts =
            gameGui:FindFirstChild(
                "itemsMenu"
            )

        boosts =
            boosts
            and
            boosts:FindFirstChild(
                "boostsFrames"
            )

        if boosts then
            for _, obj in ipairs(
                boosts:GetDescendants()
            ) do

                local label =
                    obj:FindFirstChild(
                        "nameLabel"
                    )

                if label
                    and label:IsA("TextLabel")
                    and label.Text ~= "" then

                    names[label.Text] = true
                end
            end
        end
    end

    local list = {}

    for name in pairs(names) do
        table.insert(list, name)
    end

    table.sort(list)

    return list
end

function selectedContains(list, name)
    for _, item in ipairs(list) do
        if item == name then
            return true
        end
    end

    return false
end

function rarityEnabled(rarity)
    rarity = string.lower(tostring(rarity or ""))

    if rarity == "basic" then
        return state.rareBasic
    elseif rarity == "rare" then
        return state.rareRare
    elseif rarity == "epic" then
        return state.rareEpic
    elseif rarity == "unique" then
        return state.rareUnique
    elseif rarity == "advanced" then
        return state.rareAdvanced
    end

    return false
end

function announcePet(pet)
    if not pet then
        return
    end

    local name =
        tostring(pet.Name)

    local rarity =
        pet.Parent
        and
        tostring(pet.Parent.Name)
        or
        "Unknown"

    local selected =
        selectedContains(
            selectedPets,
            name
        )

    local rare =
        state.rarityNotifications
        and
        rarityEnabled(rarity)

    if not selected and not rare then
        return
    end

    if selected then
        crystalStats.selectedPetHits += 1
    end

    if rare then
        crystalStats.rarityHits += 1
    end

    local color =
        rare
        and GUI_COLORS.yellow
        or GUI_COLORS.blue

    notify(
        "NEW PET",
        name .. " • " .. rarity,
        color
    )
end

function announceAura(name, rarity)
    name = tostring(name or "")
    rarity = tostring(rarity or "Unknown")

    local selected =
        selectedContains(
            selectedAuras,
            name
        )

    local rare =
        state.rarityNotifications
        and
        rarityEnabled(rarity)

    if not selected and not rare then
        return
    end

    if selected then
        crystalStats.selectedAuraHits += 1
    end

    if rare then
        crystalStats.rarityHits += 1
    end

    notify(
        "NEW AURA",
        name .. " • " .. rarity,
        rare and GUI_COLORS.yellow or GUI_COLORS.blue
    )
end

function getPetCardSnapshot()
    local result = {}

    if not gameGui then
        return result
    end

    local items =
        gameGui:FindFirstChild(
            "itemsMenu"
        )

    local frames =
        items
        and
        items:FindFirstChild(
            "petsFrames"
        )

    if not frames then
        return result
    end

    for _, obj in ipairs(
        frames:GetDescendants()
    ) do
        if obj:IsA("ObjectValue")
            and obj.Name == "petReference" then

            local value = obj.Value

            if value then
                result[
                    value:GetFullName()
                ] = value
            end
        end
    end

    return result
end

function getAuraSnapshot()
    local result = {}

    if not gameGui then
        return result
    end

    local items =
        gameGui:FindFirstChild(
            "itemsMenu"
        )

    local frames =
        items
        and
        items:FindFirstChild(
            "boostsFrames"
        )

    if not frames then
        return result
    end

    for _, button in ipairs(
        frames:GetDescendants()
    ) do
        if button:IsA("TextButton")
            or button:IsA("ImageButton") then

            local ref =
                button:FindFirstChild(
                    "boostReference",
                    true
                )
                or
                button:FindFirstChild(
                    "itemReference",
                    true
                )
                or
                button:FindFirstChild(
                    "auraReference",
                    true
                )

            if ref
                and ref:IsA("ObjectValue")
                and ref.Value then

                result[
                    ref.Value:GetFullName()
                ] =
                    ref.Value
            end
        end
    end

    return result
end

function refreshNotificationSources()
    local newPets =
        getPetCardSnapshot()

    if next(petReferenceSnapshot) ~= nil then
        for path, pet in pairs(newPets) do
            if not petReferenceSnapshot[path] then
                if pendingCrystalWindow > 0 then
                    announcePet(pet)
                end
            end
        end
    end

    petReferenceSnapshot = newPets

    local newAuras =
        getAuraSnapshot()

    if next(auraReferenceSnapshot) ~= nil then
        for path, aura in pairs(newAuras) do
            if not auraReferenceSnapshot[path] then
                if pendingCrystalWindow > 0 then
                    local rarity =
                        aura.Parent
                        and aura.Parent.Name
                        or "Unknown"

                    announceAura(
                        aura.Name,
                        rarity
                    )
                end
            end
        end
    end

    auraReferenceSnapshot = newAuras
end

function updateHistory()
    local lines = {}

    for i = 1, math.min(#notificationFeed, 18) do
        local event = notificationFeed[i]
        table.insert(
            lines,
            "["
            .. event.time
            .. "] "
            .. event.text
        )
    end

    historyText.Text =
        #lines > 0
        and table.concat(lines, "\n")
        or
        "No notifications yet."
end

function updatePetSelectionText()
    local list = {}

    for i = 1, math.min(#selectedPets, 5) do
        table.insert(list, selectedPets[i])
    end

    if #selectedPets > 5 then
        table.insert(
            list,
            "+" .. tostring(#selectedPets - 5) .. " more"
        )
    end

    petSelectionText.Text =
        "Selected pets:\n"
        ..
        (
            #list > 0
            and table.concat(list, "\n")
            or "None"
        )
end

connect(
    refreshPetListButton.Activated,
    function()
        local pets = scanPetPool()

        if #pets == 0 then
            notify(
                "PET LIST",
                "No pet definitions found.",
                GUI_COLORS.red
            )
            return
        end

        selectedPets = {
            pets[1]
        }

        saveConfig()
        updatePetSelectionText()

        notify(
            "PET LIST",
            "Loaded " .. tostring(#pets) .. " pets.",
            GUI_COLORS.blue
        )
    end
)

goalTypes = {
    "Strength",
    "Durability",
    "Rebirths",
}

connect(
    goalType.Activated,
    function()
        local current =
            table.find(
                goalTypes,
                goal.type
            )
            or 1

        current =
            current % #goalTypes + 1

        goal.type =
            goalTypes[current]

        goalType.Text =
            goal.type

        saveConfig()
    end
)


task.spawn(function()
    while running do
        task.wait(0.25)

        if pendingCrystalWindow > 0
            and os.clock() > pendingCrystalWindow then

            pendingCrystalWindow = 0
        end

        refreshNotificationSources()
        updateHistory()
    end
end)

-- module end
