-- Faithful split from the uploaded original sB Hub source.
RunService.RenderStepped:Connect(function()
    frameCounter += 1

    if os.clock() - lastFpsTime >= 1 then
        fps = frameCounter /
            (os.clock() - lastFpsTime)

        frameCounter = 0
        lastFpsTime = os.clock()
    end

    if state.esp then
        updateESP()
    end

    if state.coords
        and root
        and root.Parent then

        local look =
            root.CFrame.LookVector

        local heading =
            (
                math.deg(
                    math.atan2(
                        look.X,
                        -look.Z
                    )
                )
                + 360
            )
            % 360

        local pitch =
            math.deg(
                math.asin(
                    math.clamp(
                        look.Y,
                        -1,
                        1
                    )
                )
            )

        local directions = {
            "N",
            "NE",
            "E",
            "SE",
            "S",
            "SW",
            "W",
            "NW",
        }

        local index =
            math.floor(
                (heading + 22.5) /
                45
            ) % 8 + 1

        local direction =
            directions[index]

        local lines = {
            string.format(
                "X: %.2f",
                root.Position.X
            ),
            string.format(
                "Y: %.2f",
                root.Position.Y
            ),
            string.format(
                "Z: %.2f",
                root.Position.Z
            ),
        }

        if state.coordsCompass then
            table.insert(
                lines,
                "Facing: "
                ..
                direction
            )
        end

        if state.coordsHeading then
            table.insert(
                lines,
                string.format(
                    "Heading: %.1f°",
                    heading
                )
            )
        end

        if state.coordsPitch then
            table.insert(
                lines,
                string.format(
                    "Pitch: %.1f°",
                    pitch
                )
            )
        end

        coordsText.Text =
            table.concat(
                lines,
                "\n"
            )

        coordsOverlay.Visible =
            true
    else
        coordsOverlay.Visible =
            false
    end
end)

-- module end
