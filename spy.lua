-- Faithful split from the uploaded original sB Hub source.
function getGoalCurrent()
    if goal.type == "Strength" then
        return tonumber(strength.Value) or 0
    elseif goal.type == "Durability" then
        durability =
            player:FindFirstChild("Durability")

        return durability
            and
            tonumber(durability.Value)
            or
            0
    elseif goal.type == "Rebirths" then
        return tonumber(rebirths.Value) or 0
    end

    return 0
end

function getPlayerStat(plr, name)
    local ls =
        plr:FindFirstChild(
            "leaderstats"
        )

    local value =
        ls
        and
        ls:FindFirstChild(name)

    if value and value:IsA("ValueBase") then
        return tonumber(value.Value) or value.Value
    end

    value =
        plr:FindFirstChild(name)

    if value and value:IsA("ValueBase") then
        return tonumber(value.Value) or value.Value
    end

    return "N/A"
end

function refreshSpyText()
    if not currentServerPlayer then
        spyText.Text =
            "Select a player."
        return
    end

    local plr =
        currentServerPlayer

    if not plr.Parent then
        currentServerPlayer = nil
        spyPlayerText.Text =
            "select player"
        spyText.Text =
            "Player left."
        return
    end

    local statNames = {
        "Strength",
        "Rebirths",
        "Kills",
        "Brawls",
        "Durability",
        "Wins",
    }

    local lines = {
        "Player: " .. plr.Name,
        "Display: " .. plr.DisplayName,
        "",
    }

    for _, name in ipairs(statNames) do
        table.insert(
            lines,
            name .. ": " ..
            tostring(
                getPlayerStat(
                    plr,
                    name
                )
            )
        )
    end

    spyText.Text =
        table.concat(
            lines,
            "\n"
        )
end

function rebuildSpyList()
    for _, child in ipairs(
        spyList:GetChildren()
    ) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local y = 0

    for _, plr in ipairs(
        Players:GetPlayers()
    ) do
        if plr ~= player then
            local button =
                Instance.new("TextButton")

            button.Size =
                UDim2.fromOffset(
                    205,
                    25
                )

            button.Position =
                UDim2.fromOffset(
                    5,
                    y
                )

            button.BackgroundColor3 =
                GUI_COLORS.panel2

            button.BorderSizePixel =
                1

            button.BorderColor3 =
                GUI_COLORS.border

            button.Text =
                plr.DisplayName

                .. " ("
                .. plr.Name
                .. ")"

            button.TextColor3 =
                GUI_COLORS.text

            button.TextSize =
                9

            button.Font =
                FONT

            button.AutoButtonColor =
                false

            button.Parent =
                spyList

            connect(
                button.Activated,
                function()
                    currentServerPlayer =
                        plr

                    spyPlayerText.Text =
                        plr.DisplayName

                    spyList.Visible =
                        false

                    refreshSpyText()
                end
            )

            y += 28
        end
    end
end

connect(
    spyPlayerText.Activated,
    function()
        rebuildSpyList()
        spyList.Visible =
            not spyList.Visible
    end
)

connect(
    refreshSpy.Activated,
    function()
        rebuildSpyList()
        refreshSpyText()
    end
)

connect(
    Players.PlayerAdded,
    function()
        rebuildSpyList()
    end
)

connect(
    Players.PlayerRemoving,
    function(plr)
        if currentServerPlayer == plr then
            currentServerPlayer = nil
            spyPlayerText.Text =
                "select player"
        end

        rebuildSpyList()
    end
)

connect(
    player.Idled,
    function()
        if state.antiAFK and running then
            safe(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(
                    Vector2.new(0, 0)
                )
            end)
        end
    end
)

-- module end
