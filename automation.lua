-- Faithful split from the uploaded original sB Hub source.
function refreshCharacter()
    backpack = player:WaitForChild("Backpack")

    character =
        player.Character or
        player.CharacterAdded:Wait()

    humanoid =
        character:WaitForChild("Humanoid", 10)

    root =
        character:WaitForChild("HumanoidRootPart", 10)

    gems = player:FindFirstChild("Gems")
    durability = player:FindFirstChild("Durability")

    gameGui = playerGui:FindFirstChild("gameGui")
    rebirthButton = nil

    if gameGui then
        local menu = gameGui:FindFirstChild("rebirthMenu")

        if menu then
            rebirthButton =
                menu:FindFirstChild("confirmButton")
        end
    end

    return character and humanoid and root
end

function getJungleRock()
    local folder =
        workspace:FindFirstChild("machinesFolder")

    if not folder then
        return nil, nil
    end

    local machine =
        folder:FindFirstChild("Ancient Jungle Rock")

    if not machine then
        return nil, nil
    end

    local rock =
        machine:FindFirstChild("Rock", true)

    if not rock or not rock:IsA("BasePart") then
        return nil, nil
    end

    return machine, rock
end

function jungleTarget()
    if not character or not character.Parent then
        return nil
    end

    local machine, rock = getJungleRock()

    if not machine or not rock then
        return nil
    end

    local desired =
        rock.Position +
        Vector3.new(0, 0, 100)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        character,
        machine,
    }

    local result =
        workspace:Raycast(
            Vector3.new(desired.X, 300, desired.Z),
            Vector3.new(0, -600, 0),
            params
        )

    if not result then
        return nil
    end

    local p =
        result.Position +
        Vector3.new(0, 3, 0)

    return CFrame.lookAt(
        p,
        Vector3.new(
            rock.Position.X,
            p.Y,
            rock.Position.Z
        )
    )
end

function createJungleBillboard()
    if jungleBillboard then
        return
    end

    local _, rock = getJungleRock()

    if not rock then
        return
    end

    jungleBillboard =
        Instance.new("BillboardGui")

    jungleBillboard.Name =
        "sB_AutoRockStatus"

    jungleBillboard.Size =
        UDim2.fromOffset(190, 52)

    jungleBillboard.StudsOffset =
        Vector3.new(
            0,
            rock.Size.Y / 2 + 4,
            0
        )

    jungleBillboard.AlwaysOnTop = true
    jungleBillboard.Enabled = false
    jungleBillboard.Parent = rock

    local frame = Instance.new("Frame")
    frame.Name = "Background"
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = GUI_COLORS.panel
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 1
    frame.BorderColor3 = GUI_COLORS.border
    frame.Parent = jungleBillboard

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = GUI_COLORS.text
    label.TextSize = 12
    label.Font = FONT
    label.TextWrapped = true
    label.Parent = frame
end

function updateJungleBillboard(text, active)
    createJungleBillboard()

    if not jungleBillboard then
        return
    end

    jungleBillboard.Enabled = active

    local background =
        jungleBillboard:FindFirstChild("Background")

    local label =
        background and
        background:FindFirstChild("Text")

    if label then
        label.Text = tostring(text or "")
        label.TextColor3 =
            active
            and GUI_COLORS.blue
            or GUI_COLORS.muted
    end
end

function getPunch()
    if not character or not character.Parent then
        return nil
    end

    local punch =
        character:FindFirstChild("Punch")

    if punch and punch:IsA("Tool") then
        return punch
    end

    punch =
        backpack:FindFirstChild("Punch")

    if punch and punch:IsA("Tool") then
        return punch
    end

    return nil
end

function findExercise()
    if not character or not character.Parent then
        return nil
    end

    local choices = {}

    local function scan(container)
        for _, tool in ipairs(container:GetChildren()) do
            if not tool:IsA("Tool") then
                continue
            end

            local gain =
                tool:FindFirstChild("strengthGain")

            local repTime =
                tool:FindFirstChild("repTime")

            if not gain
                or not repTime
                or not gain:IsA("ValueBase")
                or not repTime:IsA("ValueBase") then
                continue
            end

            local requirement =
                tool:FindFirstChild("requiredAmount")

            local req = 0

            if requirement and requirement:IsA("ValueBase") then
                req = tonumber(requirement.Value) or 0
            end

            if strength.Value >= req then
                table.insert(
                    choices,
                    {
                        tool = tool,
                        gain = tonumber(gain.Value) or 0,
                        requirement = req,
                        repTime =
                            math.max(
                                tonumber(repTime.Value) or 0.35,
                                0.01
                            ),
                    }
                )
            end
        end
    end

    scan(backpack)
    scan(character)

    table.sort(
        choices,
        function(a, b)
            if a.requirement ~= b.requirement then
                return a.requirement > b.requirement
            end

            return a.gain > b.gain
        end
    )

    return choices[1]
end

function getRebirthRequirement()
    if not GlobalFunctions then
        return nil
    end

    local fn =
        GlobalFunctions.calculateRequiredRebirthStrength

    if typeof(fn) ~= "function" then
        return nil
    end

    local ok, result =
        pcall(
            fn,
            rebirths.Value,
            player
        )

    if ok and type(result) == "number" then
        return result
    end

    return nil
end

function getNextRebirthGems()
    if not GlobalFunctions then
        return nil
    end

    local fn =
        GlobalFunctions.calculateNextRebirthGems

    if typeof(fn) ~= "function" then
        return nil
    end

    local ok, result =
        pcall(
            fn,
            rebirths.Value
        )

    if ok and type(result) == "number" then
        return result
    end

    return nil
end

function stopRebirthSequence()
    local controller =
        ReplicatedStorage
            :FindFirstChild("client")
            and
            ReplicatedStorage.client:FindFirstChild(
                "controllers"
            )
            and
            ReplicatedStorage.client.controllers:FindFirstChild(
                "RebirthController"
            )

    if not controller
        or not controller:IsA("ModuleScript") then
        return
    end

    local ok, module =
        pcall(require, controller)

    if not ok or type(module) ~= "table" then
        return
    end

    if type(module.StopCameraSequence) == "function" then
        pcall(function()
            module.StopCameraSequence(module)
        end)

        pcall(function()
            module.StopCameraSequence()
        end)
    end
end

function setSettingValue(name, value)
    local menu =
        gameGui
        and
        gameGui:FindFirstChild("settingsMenu")

    local frame =
        menu
        and
        menu:FindFirstChild(
            "settingsFrame",
            true
        )

    if not frame then
        return
    end

    local target =
        frame:FindFirstChild(
            name,
            true
        )

    if not target then
        return
    end

    local amount =
        target:FindFirstChild(
            "amountBox",
            true
        )

    if amount and amount:IsA("TextBox") then
        amount.Text = tostring(value)
    end
end

function applySize()
    local menu =
        gameGui
        and
        gameGui:FindFirstChild("settingsMenu")

    if not menu then
        return
    end

    if state.sizeMode == "Max" then
        local button =
            menu:FindFirstChild(
                "maxSizeButton",
                true
            )

        if button and button:IsA("GuiButton") then
            fire(button.Activated)
        end
    else
        setSettingValue(
            "sizeSetting",
            state.sizeCustom
        )
    end
end

function applySpeed()
    local menu =
        gameGui
        and
        gameGui:FindFirstChild("settingsMenu")

    if not menu then
        return
    end

    if state.speedMode == "Max" then
        local button =
            menu:FindFirstChild(
                "maxSpeedButton",
                true
            )

        if button and button:IsA("GuiButton") then
            fire(button.Activated)
        end
    else
        setSettingValue(
            "speedSetting",
            state.speedCustom
        )
    end
end


task.spawn(function()
    while running do
        task.wait()

        if not state.autoTrain then
            continue
        end

        if not character
            or not character.Parent
            or not humanoid
            or not humanoid.Parent then

            refreshCharacter()
            continue
        end

        local selected =
            findExercise()

        if not selected then
            currentExercise =
                "None"

            continue
        end

        currentExercise =
            tostring(
                selected.tool.Name
            )

        local tool =
            selected.tool

        if tool.Parent ~= character then
            pcall(function()
                humanoid:EquipTool(tool)
            end)

            task.wait()
            continue
        end

        pcall(function()
            tool:Activate()
        end)
    end
end)

task.spawn(function()
    while running do
        task.wait(0.1)

        if not state.autoRebirth then
            continue
        end

        if state.rebirthLimit
            and rebirths.Value >=
            state.rebirthTarget then

            continue
        end

        if rebirthButton
            and rebirthButton.Parent
            and rebirthButton.Visible
            and rebirthButton.Active then

            fire(
                rebirthButton.Activated
            )
        end
    end
end)

task.spawn(function()
    while running do
        task.wait(0.04)

        if state.skipRebirthAnimation then
            stopRebirthSequence()

            if humanoid and humanoid.Parent then
                for _, track in ipairs(
                    humanoid:GetPlayingAnimationTracks()
                ) do
                    local name =
                        string.lower(
                            tostring(
                                track.Name
                            )
                        )

                    if name:find(
                        "rebirth",
                        1,
                        true
                    )
                    or name:find(
                        "celebrat",
                        1,
                        true
                    ) then

                        pcall(function()
                            track:Stop(0)
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while running do
        task.wait(0.08)

        if not state.autoEgg then
            continue
        end

        pcall(function()
            VirtualInputManager:SendKeyEvent(
                true,
                Enum.KeyCode.E,
                false,
                game
            )

            VirtualInputManager:SendKeyEvent(
                false,
                Enum.KeyCode.E,
                false,
                game
            )

            pendingCrystalWindow =
                os.clock() + 2

            crystalStats.opened += 1
        end)
    end
end)

task.spawn(function()
    while running do
        task.wait(0.05)

        if not state.autoJungleRock then
            junglePositioned = false
            currentRock = "OFF"

            if jungleBillboard then
                jungleBillboard.Enabled = false
            end

            continue
        end

        if not character
            or not character.Parent
            or not root
            or not root.Parent then

            currentRock = "Recovering"
            continue
        end

        local target =
            jungleTarget()

        if not target then
            currentRock =
                "Unavailable"
            continue
        end

        currentRock =
            "Ancient Jungle Rock"

        if not junglePositioned then
            pcall(function()
                character:PivotTo(target)
            end)

            junglePositioned = true
        elseif
            (root.Position - target.Position).Magnitude > 4 then

            pcall(function()
                character:PivotTo(target)
            end)
        end

        updateJungleBillboard(
            "● AUTO ROCK ACTIVE\nAncient Jungle Rock",
            true
        )
    end
end)

task.spawn(function()
    while running do
        task.wait()

        if not state.autoJungleRock then
            continue
        end

        if not character
            or not humanoid
            or not humanoid.Parent then
            continue
        end

        local punch =
            getPunch()

        if not punch then
            continue
        end

        if punch.Parent ~= character then
            pcall(function()
                humanoid:EquipTool(punch)
            end)

            task.wait()
        end

        if punch.Parent == character then
            pcall(function()
                punch:Activate()
            end)
        end
    end
end)

task.spawn(function()
    while running do
        task.wait(1)

        if state.autoSize then
            applySize()
        end

        if state.autoSpeed then
            applySpeed()
        end
    end
end)

task.spawn(function()
    while running do
        task.wait(0.5)

        if not state.autoUltimates then
            continue
        end

        local ultimateGui =
            playerGui:FindFirstChild(
                "ultimatesGui"
            )

        if not ultimateGui then
            continue
        end

        for _, object in ipairs(
            ultimateGui:GetDescendants()
        ) do
            if object:IsA("GuiButton") then
                local label =
                    object:FindFirstChild(
                        "titleLabel",
                        true
                    )

                if label and label.Text ~= "" then
                    currentUltimate =
                        tostring(
                            label.Text
                        )

                    fire(
                        object.Activated
                    )

                    task.wait(0.15)
                    break
                end
            end
        end
    end
end)

-- module end
