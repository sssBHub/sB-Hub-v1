-- Faithful split from the uploaded original sB Hub source.
function scanPetAnalyzer()
    local result = {
        pets = 0,
        strength = 0,
        durability = 0,
        agility = 0,
        bestStrength = nil,
        bestDurability = nil,
    }

    local folder =
        player:FindFirstChild(
            "petsFolder"
        )

    if not folder then
        return result
    end

    for _, rarity in ipairs(
        folder:GetChildren()
    ) do

        for _, pet in ipairs(
            rarity:GetChildren()
        ) do

            local perks =
                pet:FindFirstChild(
                    "perksFolder"
                )

            if not perks then
                continue
            end

            result.pets += 1

            local s =
                perks:FindFirstChild(
                    "strength"
                )

            local d =
                perks:FindFirstChild(
                    "durability"
                )

            local a =
                perks:FindFirstChild(
                    "agility"
                )

            local strengthValue =
                s and
                tonumber(s.Value)
                or 0

            local durabilityValue =
                d and
                tonumber(d.Value)
                or 0

            local agilityValue =
                a and
                tonumber(a.Value)
                or 0

            result.strength +=
                strengthValue

            result.durability +=
                durabilityValue

            result.agility +=
                agilityValue

            if not result.bestStrength
                or
                strengthValue >
                result.bestStrength.value then

                result.bestStrength = {
                    name = pet.Name,
                    value = strengthValue,
                }
            end

            if not result.bestDurability
                or
                durabilityValue >
                result.bestDurability.value then

                result.bestDurability = {
                    name = pet.Name,
                    value = durabilityValue,
                }
            end
        end
    end

    return result
end

function updatePetAnalyzer()
    local data =
        scanPetAnalyzer()

    local bestStrength =
        data.bestStrength
        and
        (
            data.bestStrength.name
            ..
            " +"
            ..
            fmt(
                data.bestStrength.value
            )
        )
        or
        "N/A"

    local bestDurability =
        data.bestDurability
        and
        (
            data.bestDurability.name
            ..
            " +"
            ..
            fmt(
                data.bestDurability.value
            )
        )
        or
        "N/A"

    petStatsText.Text =
        "Pets found: "
        ..
        tostring(data.pets)
        ..
        "\nStrength perks: "
        ..
        fmt(data.strength)
        ..
        "\nDurability perks: "
        ..
        fmt(data.durability)
        ..
        "\nAgility perks: "
        ..
        fmt(data.agility)
        ..
        "\nBest Strength: "
        ..
        bestStrength
        ..
        "\nBest Durability: "
        ..
        bestDurability
        ..
        "\n\nRead-only."
end

-- module end
