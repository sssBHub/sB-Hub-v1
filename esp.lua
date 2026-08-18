-- Faithful split from the uploaded original sB Hub source.
function projectBox(characterModel)
    local camera =
        workspace.CurrentCamera

    if not camera then
        return nil
    end

    local cf, size =
        characterModel:GetBoundingBox()

    local half =
        size / 2

    local corners = {
        Vector3.new(-half.X, -half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y, half.Z),
        Vector3.new(-half.X, half.Y, -half.Z),
        Vector3.new(-half.X, half.Y, half.Z),
        Vector3.new(half.X, -half.Y, -half.Z),
        Vector3.new(half.X, -half.Y, half.Z),
        Vector3.new(half.X, half.Y, -half.Z),
        Vector3.new(half.X, half.Y, half.Z),
    }

    local minX = math.huge
    local minY = math.huge
    local maxX = -math.huge
    local maxY = -math.huge
    local any = false

    for _, corner in ipairs(corners) do
        local screen, visible =
            camera:WorldToViewportPoint(
                cf:PointToWorldSpace(corner)
            )

        if visible then
            any = true
        end

        minX = math.min(minX, screen.X)
        minY = math.min(minY, screen.Y)
        maxX = math.max(maxX, screen.X)
        maxY = math.max(maxY, screen.Y)
    end

    if not any then
        return nil
    end

    return {
        position = Vector2.new(minX, minY),
        size = Vector2.new(
            maxX - minX,
            maxY - minY
        ),
    }
end

function clearESP(plr)
    local entry =
        espEntries[plr]

    if not entry then
        return
    end

    for _, obj in pairs(entry) do
        if typeof(obj) == "table" then
            pcall(function()
                obj:Remove()
            end)
        end
    end

    espEntries[plr] = nil
end

function ensureESP(plr)
    if plr == player then
        return
    end

    if typeof(Drawing) ~= "table"
        and typeof(Drawing) ~= "userdata" then
        return
    end

    local entry =
        espEntries[plr]

    if entry then
        return entry
    end

    entry = {}

    if state.espBoxes then
        entry.box =
            Drawing.new("Square")

        entry.box.Thickness = 1
        entry.box.Filled = false
        entry.box.Color = ESP_COLORS.box
        entry.box.Visible = false
    end

    if state.espNames then
        entry.name =
            Drawing.new("Text")

        entry.name.Size = 13
        entry.name.Center = true
        entry.name.Outline = true
        entry.name.Color = ESP_COLORS.text
        entry.name.Visible = false
    end

    if state.espDistance then
        entry.distance =
            Drawing.new("Text")

        entry.distance.Size = 11
        entry.distance.Center = true
        entry.distance.Outline = true
        entry.distance.Color = ESP_COLORS.text
        entry.distance.Visible = false
    end

    if state.espHealth then
        entry.health =
            Drawing.new("Text")

        entry.health.Size = 11
        entry.health.Center = true
        entry.health.Outline = true
        entry.health.Color = ESP_COLORS.health
        entry.health.Visible = false
    end

    if state.espTracers then
        entry.tracer =
            Drawing.new("Line")

        entry.tracer.Thickness = 1
        entry.tracer.Color = ESP_COLORS.tracer
        entry.tracer.Visible = false
    end

    espEntries[plr] = entry

    return entry
end

function destroyAllESP()
    for plr in pairs(espEntries) do
        clearESP(plr)
    end
end

function updateESP()
    if not state.esp then
        destroyAllESP()
        return
    end

    for _, plr in ipairs(
        Players:GetPlayers()
    ) do

        if plr == player then
            continue
        end

        if state.espTeamCheck
            and plr.Team
            and player.Team
            and plr.Team == player.Team then

            clearESP(plr)
            continue
        end

        local model =
            plr.Character

        local targetRoot =
            model
            and
            model:FindFirstChild(
                "HumanoidRootPart"
            )

        if not model
            or not targetRoot then

            clearESP(plr)
            continue
        end

        local distance =
            root
            and root.Parent
            and
            (
                root.Position -
                targetRoot.Position
            ).Magnitude
            or
            math.huge

        if distance >
            state.espMaxDistance then

            clearESP(plr)
            continue
        end

        local box =
            projectBox(
                model
            )

        if not box then
            continue
        end

        local entry =
            ensureESP(plr)

        if not entry then
            continue
        end

        local center =
            box.position +
            box.size / 2

        if entry.box then
            entry.box.Position =
                box.position

            entry.box.Size =
                box.size

            entry.box.Visible =
                state.espBoxes
        end

        if entry.name then
            entry.name.Text =
                tostring(
                    plr.DisplayName
                )

            entry.name.Position =
                Vector2.new(
                    center.X,
                    box.position.Y - 16
                )

            entry.name.Visible =
                state.espNames
        end

        if entry.distance then
            entry.distance.Text =
                string.format(
                    "%.0f studs",
                    distance
                )

            entry.distance.Position =
                Vector2.new(
                    center.X,
                    box.position.Y +
                    box.size.Y +
                    2
                )

            entry.distance.Visible =
                state.espDistance
        end

        if entry.health then
            local targetHumanoid =
                model:FindFirstChildOfClass(
                    "Humanoid"
                )

            if targetHumanoid then
                local hp =
                    tonumber(
                        targetHumanoid.Health
                    ) or 0

                local maxHp =
                    math.max(
                        1,
                        tonumber(
                            targetHumanoid.MaxHealth
                        ) or 1
                    )

                local ratio =
                    math.clamp(
                        hp / maxHp,
                        0,
                        1
                    )

                entry.health.Text =
                    string.format(
                        "HP %.0f / %.0f",
                        hp,
                        maxHp
                    )

                entry.health.Color =
                    Color3.fromRGB(
                        255 * (1 - ratio),
                        100 + (155 * ratio),
                        100
                    )

                entry.health.Position =
                    Vector2.new(
                        center.X,
                        box.position.Y +
                        box.size.Y +
                        16
                    )

                entry.health.Visible =
                    state.espHealth
            else
                entry.health.Visible = false
            end
        end

        if entry.tracer then
            local camera =
                workspace.CurrentCamera

            if camera then
                local screen =
                    camera:WorldToViewportPoint(
                        targetRoot.Position
                    )

                entry.tracer.From =
                    Vector2.new(
                        camera.ViewportSize.X / 2,
                        camera.ViewportSize.Y
                    )

                entry.tracer.To =
                    Vector2.new(
                        screen.X,
                        screen.Y
                    )

                entry.tracer.Visible =
                    state.espTracers
            end
        end
    end
end

-- module end
