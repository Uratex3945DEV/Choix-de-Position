ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Webhooks = {
    commande = "https://discord.com/api/webhooks/1497950831478181958/E0ZxL3QiV7wVcuFrHZCOfLo6o08dTI7rjbzaqQ2rRZttsLt3u8McAIW-GEJuWYaoBgWe",
    securite = "https://discord.com/api/webhooks/1497951098722455635/rZzZvfc1H3JBBeNENR7lIGgaouNz4RABpABUXWASdrVKFRWg0I-vo50FQAJlUfG-Ub8C",
    vote     = "https://discord.com/api/webhooks/1497951213264703498/UiMjQTe27T18xVFxDpt0rxtthk7AHlsixJbMoBCP8DtlemfyqLj_sL3tPchIMhxP6wv2",
    equipes  = "https://discord.com/api/webhooks/1497951266519650466/PDVUt_z5l2pm7B5FaDOaW_Zn1OjdM-8qd76XIK1oAoUNcuzqJpUk0dQpdoRIcJAxMHkQ",
}

local function SendLog(webhook, title, message, color)
    local url = Webhooks[webhook]
    if not url or url == "" then return end

    local embed = {
        {
            ["title"]       = title,
            ["description"] = message,
            ["color"]       = color or 16711680,
            ["footer"]      = { ["text"] = "choosepos • " .. webhook },
            ["timestamp"]   = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(url, function() end, "POST",
        json.encode({
            username = "ChoosePos — " .. webhook:sub(1,1):upper() .. webhook:sub(2),
            embeds   = embed
        }),
        { ["Content-Type"] = "application/json" }
    )
end

local Destinations = {
    camp     = { interieur = { x = -1125.9082, y = 4925.9131, z = 219.0878, w = 263.1524 }, exterieur = { x = -1008.6759, y = 4961.0483, z = 195.3463, w = 146.2953 } },
    merry    = { interieur = { x = 485.1867,   y = -3149.6331, z = 6.0701,  w = 276.6308 }, exterieur = { x = 492.3228,   y = -3023.4595, z = 6.0598,  w = 177.2637 } },
    palmer   = { interieur = { x = 2725.0654,  y = 1386.0181,  z = 24.5065, w = 358.8296 }, exterieur = { x = 2704.7476,  y = 1569.9208,  z = 24.5211, w = 268.8914 } },
    avion    = { interieur = { x = 2404.3738,  y = 3107.0449,  z = 48.1792, w = 162.7370 }, exterieur = { x = 2371.4517,  y = 3119.8765,  z = 48.1630, w = 242.4251 } },
    roxwood  = { interieur = { x = -343.6741,  y = 7750.6226,  z = 6.3982,  w = 359.6245 }, exterieur = { x = -353.6663,  y = 7708.2202,  z = 6.3983,  w = 350.2935 } },
    labs     = { interieur = { x = 3617.8027,  y = 3732.2715,  z = 28.6901, w = 145.2069 }, exterieur = { x = 3631.9302,  y = 3762.3591,  z = 29.5157, w = 155.2362 } },
    biker    = { interieur = { x = 54.8628,    y = 3713.2502,  z = 39.7549, w = 182.3826 }, exterieur = { x = 60.0516,    y = 3591.4189,  z = 39.7955, w = 350.0816 } },
    kortz    = { interieur = { x = -2209.0872, y = 263.8361,   z = 197.1040, w = 279.3542 }, exterieur = { x = -2306.6697, y = 441.1794,  z = 174.4666, w = 172.5930 } },
    naval    = { interieur = { x = 36.3382,    y = -2663.0840, z = 12.0448, w = 355.2131 }, exterieur = { x = 33.4976,    y = -2645.5339, z = 6.0133,  w = 198.5529 } },
    manoir   = { interieur = { x = 3904.2595,  y = 4875.1426,  z = 13.6040, w = 198.5529 }, exterieur = { x = 3939.4956,  y = 4883.5132,  z = 14.9277, w = 106.3242 } },
    neil     = { interieur = { x = 2448.1350,  y = 4983.3281,  z = 46.8469, w = 310.7483 }, exterieur = { x = 2468.1970,  y = 4955.3701,  z = 45.1171, w = 272.5053 } },
    scarface = { interieur = { x = -3316.3145, y = 551.3894,  z = 14.1075, w = 298.3670 }, exterieur = { x = -3279.8250, y = 523.3915,   z = 12.2657, w = 67.7082  } },
    casse    = { interieur = { x = -515.9210,  y = -1712.9590, z = 19.3194, w = 226.6822 }, exterieur = { x = -403.6815,  y = -1717.6913, z = 19.0596, w = 68.1634  } },
    yacht    = { interieur = { x = -2038.7087, y = -1033.1168, z = 2.5845,  w = 72.5051  }, exterieur = { x = -2043.7803, y = -1031.7238, z = 11.9807, w = 69.2897  } },
    usine    = { interieur = { x = -1723.3563, y = 6427.8105,  z = 16.7391, w = 88.5420  }, exterieur = { x = -1595.8739, y = 6557.9233,  z = 16.7453, w = 182.1086 } },
    scirie   = { interieur = { x = -554.2745,  y = 5322.5859,  z = 73.5997, w = 326.0592 }, exterieur = { x = -588.3157,  y = 5303.8394,  z = 70.2143, w = 263.8417 } },
    sous     = { interieur = { x = 150.8027,   y = -598.6061,  z = 17.7537, w = 266.0916 }, exterieur = { x = 268.1720,   y = -462.4863,  z = 23.5189, w = 115.9303 } },
    bell     = { interieur = { x = -79.0393,   y = 6286.4014,  z = 31.3407, w = 196.2848 }, exterieur = { x = -77.1237,   y = 6221.6768,  z = 31.0898, w = 38.5729  } },
}

local Labels = {
    camp     = "Camp Nudiste",
    merry    = "MerryWeather",
    palmer   = "Palmer Station",
    avion    = "Casse Avion",
    roxwood  = "Parc Aquatique",
    labs     = "Human Labs",
    biker    = "Camp Biker",
    kortz    = "Kortz Center",
    naval    = "Chantier Naval",
    manoir   = "Manoir",
    neil     = "Maison O'Neil",
    casse    = "Casse SUD",
    yacht    = "Yacht",
    usine    = "Usine Roxwood",
    scirie   = "Scirie NORD",
    sous     = "Sous Terrain LS",
    bell     = "Cluckin' Bell",
    scarface = "Villa Scarface",
}

local AllowedGroups = {
    ["helper"]       = true,
    ["mod"]          = true,
    ["admin"]        = true,
    ["superadmin"]   = true,
    ["assistnaruto"] = true,
    ["assistadam"]   = true,
    ["assistrubs"]   = true,
    ["assisturatex"] = true,
    ["skysecu"]      = true,
    ["gerantstaff"]  = true,
    ["responsable"]  = true,
    ["mainteam"]     = true,
    ["cofondateur"]  = true,
    ["fondateur"]    = true,
}

local GroupLabels = {
    ["helper"]       = "Helper",
    ["mod"]          = "Modérateur",
    ["admin"]        = "Administrateur",
    ["superadmin"]   = "Super-Administrateur",
    ["assistnaruto"] = "Assistant Naruto",
    ["assistadam"]   = "Assistant Adam",
    ["assistrubs"]   = "Assistant Rubs",
    ["assisturatex"] = "Assistant Uratex",
    ["skysecu"]      = "Sky Sécurité",
    ["gerantstaff"]  = "Gérant Staff / CM",
    ["responsable"]  = "Responsable",
    ["mainteam"]     = "Main-Team",
    ["cofondateur"]  = "Co-Fondateur",
    ["fondateur"]    = "Fondateur",
}

local function GetGroupLabel(group)
    return GroupLabels[group] or group
end

local VoteActive   = false
local VoteDuration = 15
local CurrentVotes = {}
local HasVoted     = {}
local RefusedPlayers = {}

local LastChoosePos = 0
local CooldownTime  = 150

local TenueInterieur = nil
local TenueExterieur = nil

local CurrentMap      = nil   -- clé de la map ex: "camp"
local TeamAssignments = {}    -- src → "interieur" | "exterieur"

local MortsEquipe = { interieur = {}, exterieur = {} }


-- ──────────────────────────────────────────────────────────────
--  MYSQL — Chargement des positions personnalisées au démarrage
-- ──────────────────────────────────────────────────────────────
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    MySQL.Async.fetchAll([[
        CREATE TABLE IF NOT EXISTS `choosepos_positions` (
            `map_key`  VARCHAR(64)  NOT NULL,
            `slot`     VARCHAR(16)  NOT NULL,
            `x`        FLOAT        NOT NULL,
            `y`        FLOAT        NOT NULL,
            `z`        FLOAT        NOT NULL,
            `w`        FLOAT        NOT NULL DEFAULT 0.0,
            `updated_at` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`map_key`, `slot`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function() end)

    MySQL.Async.fetchAll('SELECT map_key, slot, x, y, z, w FROM choosepos_positions', {}, function(rows)
        if not rows then return end
        local count = 0
        for _, row in ipairs(rows) do
            local k = row.map_key
            local s = row.slot
            if Destinations[k] and (s == 'interieur' or s == 'exterieur') then
                Destinations[k][s] = { x = row.x, y = row.y, z = row.z, w = row.w }
                count = count + 1
            end
        end
        if count > 0 then
            print(('[choosepos] %d position(s) chargée(s) depuis MySQL.'):format(count))
        end
    end)
end)

local function ShufflePlayers(players)
    math.randomseed(os.time() + math.random(1, 99999))
    for i = #players, 2, -1 do
        local j = math.random(1, i)
        players[i], players[j] = players[j], players[i]
    end
    return players
end

local function AssignTeams()
    TeamAssignments = {}
    MortsEquipe     = { interieur = {}, exterieur = {} }

    local allPlayers = GetPlayers()
    local playersToAssign = {}

    for _, pid in ipairs(allPlayers) do
        local src = tonumber(pid)
        if not RefusedPlayers[src] then
            table.insert(playersToAssign, pid)
        end
    end

    local players = ShufflePlayers(playersToAssign)
    local slot    = "interieur"

    for _, pid in ipairs(players) do
        local src = tonumber(pid)
        TeamAssignments[src] = slot
        slot = (slot == "interieur") and "exterieur" or "interieur"
    end

    local teamLog = ""
    for src, t in pairs(TeamAssignments) do
        teamLog = teamLog .. "ID " .. src .. " → " .. t .. "\n"
    end

    SendLog("equipes", "👥 Assignation des équipes (aléatoire)",
        "**Joueurs connectés:** " .. #players .. "\n\n" .. teamLog,
        7419530
    )
end


local function BroadcastHudUpdate()
    if not CurrentMap then return end

    local data = { interieur = {}, exterieur = {} }
    for pid, slot in pairs(TeamAssignments) do
        local px   = ESX.GetPlayerFromId(pid)
        local name = px and px.getName() or ("ID " .. pid)
        table.insert(data[slot], { id = pid, name = name })
    end

    TriggerClientEvent('choosepos:hudUpdate', -1, {
        map      = CurrentMap and Labels[CurrentMap] or nil,
        tenueInt = TenueInterieur,
        tenueExt = TenueExterieur,
        players  = data,
    })
end

RegisterCommand('choosepos', function(source)

    if source == 0 then
        SendLog("commande", "⚙️ /choosepos console", "Commande lancée depuis la **console serveur** (ignorée).", 8421504)
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        SendLog("commande", "❌ Joueur introuvable", "**ID:** " .. source .. " — ESX.GetPlayerFromId a retourné nil.", 15158332)
        return
    end

    local pGroup = xPlayer.getGroup()
    local pName  = xPlayer.getName()
    local now    = os.time()

    SendLog("commande", "🎮 /choosepos utilisé",
        "**ID:** " .. source ..
        "\n**Nom:** " .. pName ..
        "\n**Groupe:** " .. GetGroupLabel(pGroup) .. " (" .. pGroup .. ")" ..
        "\n**Heure:** " .. os.date("%H:%M:%S"),
        3447003
    )

    if pGroup ~= "fondateur" then
        local elapsed = now - LastChoosePos
        if elapsed < CooldownTime then
            local remaining = CooldownTime - elapsed
            SendLog("securite", "⏳ Cooldown bloqué",
                "**ID:** " .. source ..
                "\n**Nom:** " .. pName ..
                "\n**Groupe:** " .. GetGroupLabel(pGroup) ..
                "\n**Temps restant:** " .. remaining .. "s (" .. math.ceil(remaining / 60) .. " min)",
                16776960
            )
            TriggerClientEvent('esx:showNotification', source,
                "~r~Vous pouvez refaire la commande dans ~y~" .. math.ceil(remaining / 60) .. " minute(s).")
            return
        end
    end

    if not AllowedGroups[pGroup] then
        SendLog("securite", "⛔ Permission refusée",
            "**ID:** " .. source ..
            "\n**Nom:** " .. pName ..
            "\n**Groupe:** " .. pGroup .. " (non autorisé)",
            15158332
        )
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas la permission.")
        return
    end

    if VoteActive then
        SendLog("securite", "⚠️ Vote déjà actif",
            "**ID:** " .. source ..
            "\n**Nom:** " .. pName ..
            "\n**Groupe:** " .. GetGroupLabel(pGroup) ..
            "\n→ Tentative de lancer un second vote bloquée.",
            15105570
        )
        TriggerClientEvent('esx:showNotification', source, "~r~Un vote est déjà en cours.")
        return
    end

    TriggerClientEvent('choosepos:openTenuePicker', source)

end, false)

RegisterCommand('chooseposinverse', function(source)

    if source == 0 then
        print("[choosepos] /chooseposinverse ignorée depuis la console.")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local pGroup = xPlayer.getGroup()
    local pName  = xPlayer.getName()

    if not AllowedGroups[pGroup] then
        SendLog("securite", "⛔ /chooseposinverse refusé",
            "**ID:** " .. source ..
            "\n**Nom:** " .. pName ..
            "\n**Groupe:** " .. pGroup .. " (non autorisé)",
            15158332
        )
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas la permission.")
        return
    end

    if not CurrentMap or not next(TeamAssignments) then
        TriggerClientEvent('esx:showNotification', source,
            "~r~Aucune partie en cours. Lancez d'abord un /choosepos.")
        return
    end

    if VoteActive then
        TriggerClientEvent('esx:showNotification', source,
            "~r~Impossible pendant un vote en cours.")
        return
    end

    local dest = Destinations[CurrentMap]
    if not dest then
        TriggerClientEvent('esx:showNotification', source, "~r~Map introuvable dans les destinations.")
        return
    end

    for src, slot in pairs(TeamAssignments) do
        TeamAssignments[src] = (slot == "interieur") and "exterieur" or "interieur"
    end

    MortsEquipe = { interieur = {}, exterieur = {} }
    TriggerClientEvent('choosepos:hudResetDead', -1)

    local intList = ""
    local extList = ""
    local players = GetPlayers()

    for _, pid in ipairs(players) do
        local src  = tonumber(pid)
        if not RefusedPlayers[src] then
            local slot = TeamAssignments[src]

            if not slot then
                slot = "interieur"
                TeamAssignments[src] = slot
            end

            local coords     = dest[slot]
            local tenueLabel = (slot == "interieur") and TenueInterieur or TenueExterieur
            local px         = ESX.GetPlayerFromId(src)
            local pnick      = px and px.getName() or ("ID " .. src)

            if slot == "interieur" then
                intList = intList .. pnick .. " (ID:" .. src .. ")\n"
            else
                extList = extList .. pnick .. " (ID:" .. src .. ")\n"
            end

            TriggerClientEvent('choosepos:inverseEquipes', src, coords, slot, tenueLabel)
        end
    end

    BroadcastHudUpdate()
    TriggerClientEvent('esx:showNotification', -1, "~y~[INVERSE]~w~ Les équipes ont été inversées !")

    SendLog("equipes", "🔄 /chooseposinverse — Équipes inversées",
        "**Lancé par:** " .. pName .. " (ID: " .. source .. ")" ..
        "\n**Groupe:** " .. GetGroupLabel(pGroup) ..
        "\n**Map actuelle:** " .. Labels[CurrentMap] ..
        "\n**Tenue Intérieur:** " .. (TenueInterieur or "?") ..
        "\n**Tenue Extérieur:** " .. (TenueExterieur or "?") ..
        "\n\n🏠 **Intérieur (après inversion):**\n" .. (intList ~= "" and intList or "_aucun_") ..
        "\n🌿 **Extérieur (après inversion):**\n" .. (extList ~= "" and extList or "_aucun_"),
        16744272
    )

end, false)

RegisterNetEvent('choosepos:confirmTenues')
AddEventHandler('choosepos:confirmTenues', function(labelInt, labelExt)
    local source = source

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local pName  = xPlayer.getName()
    local pGroup = xPlayer.getGroup()
    local now    = os.time()

    TenueInterieur  = labelInt
    TenueExterieur  = labelExt
    VoteActive      = true
    LastChoosePos   = now
    HasVoted        = {}
    RefusedPlayers  = {}
    CurrentVotes    = {}
    CurrentMap      = nil
    TeamAssignments = {}

    for k, _ in pairs(Labels) do
        CurrentVotes[k] = 0
    end

    local playerCount = #GetPlayers()

    SendLog("vote", "🚀 Vote lancé",
        "**Par:** " .. pName .. " (ID: " .. source .. ")" ..
        "\n**Groupe:** " .. GetGroupLabel(pGroup) ..
        "\n**Durée:** " .. VoteDuration .. "s" ..
        "\n**Joueurs connectés:** " .. playerCount ..
        "\n**Tenue Intérieur:** " .. labelInt ..
        "\n**Tenue Extérieur:** " .. labelExt ..
        "\n**Maps disponibles:** " .. (function()
            local list = ""
            for k, _ in pairs(Labels) do list = list .. k .. ", " end
            return list:sub(1, -3)
        end)(),
        3066993
    )

    TriggerClientEvent('esx:showNotification', -1, "~g~Un vote de position a été lancé !")
    TriggerClientEvent('choosepos:startVote', -1, VoteDuration, CurrentVotes)

    Citizen.CreateThread(function()
        Citizen.Wait(VoteDuration * 1000)

        VoteActive = false
        AssignTeams()
        BroadcastHudUpdate()

        local winner         = "camp"
        local maxVotes       = 0
        local totalVotesCast = 0
        local resultText     = ""

        for k, v in pairs(CurrentVotes) do
            totalVotesCast = totalVotesCast + v
            resultText     = resultText .. Labels[k] .. " (" .. k .. "): **" .. v .. "** vote(s)\n"
            if v > maxVotes then
                winner   = k
                maxVotes = v
            end
        end

        CurrentMap = winner

        local dest = Destinations[winner]

        SendLog("vote", "🏆 Vote terminé — résultat",
            "**Gagnant:** " .. Labels[winner] .. " (" .. winner .. ")" ..
            "\n**Votes gagnants:** " .. maxVotes ..
            "\n**Total votes exprimés:** " .. totalVotesCast ..
            "\n**Abstentions:** " .. (#GetPlayers() - totalVotesCast) ..
            "\n\n**Spawn Intérieur:** X: " .. dest.interieur.x .. " | Y: " .. dest.interieur.y .. " | Z: " .. dest.interieur.z ..
            "\n**Spawn Extérieur:** X: " .. dest.exterieur.x .. " | Y: " .. dest.exterieur.y .. " | Z: " .. dest.exterieur.z ..
            "\n\n📊 **Résultats complets:**\n" .. resultText,
            5763719
        )

        TriggerClientEvent('esx:showNotification', -1,
            "~r~Fin du vote ~w~→ ~y~" .. Labels[winner] .. " ~w~(" .. maxVotes .. " voix)")

        local players = GetPlayers()
        local intList = ""
        local extList = ""

        for _, pid in ipairs(players) do
            local src        = tonumber(pid)
            if not RefusedPlayers[src] then
                local slot       = TeamAssignments[src] or "interieur"
                local coords     = dest[slot]
                local px         = ESX.GetPlayerFromId(src)
                local pnick      = px and px.getName() or ("ID " .. src)
                local tenueLabel = (slot == "interieur") and TenueInterieur or TenueExterieur

                TriggerClientEvent('choosepos:applyTenue', src, tenueLabel)

                if slot == "interieur" then
                    intList = intList .. pnick .. " (ID:" .. src .. ")\n"
                else
                    extList = extList .. pnick .. " (ID:" .. src .. ")\n"
                end

                TriggerClientEvent('choosepos:endVote', src, winner, coords, slot)
            else
                TriggerClientEvent('choosepos:forceClose', src)
            end
        end

        SendLog("equipes", "🚁 Téléportation effectuée",
            "**Map:** " .. Labels[winner] ..
            "\n**Tenue Intérieur:** " .. TenueInterieur ..
            "\n**Tenue Extérieur:** " .. TenueExterieur ..
            "\n\n🏠 **Intérieur:**\n" .. (intList ~= "" and intList or "_aucun_") ..
            "\n🌿 **Extérieur:**\n" .. (extList ~= "" and extList or "_aucun_"),
            1752220
        )
    end)
end)

RegisterNetEvent('choosepos:receiveVote')
AddEventHandler('choosepos:receiveVote', function(choice)
    local src = source

    if not VoteActive then
        SendLog("securite", "🚫 Vote rejeté — vote inactif",
            "**ID:** " .. src ..
            "\n**Choix envoyé:** " .. tostring(choice) ..
            "\n→ Aucun vote en cours au moment de la réception.",
            8421504
        )
        return
    end

    if HasVoted[src] then
        SendLog("securite", "🔁 Double vote bloqué",
            "**ID:** " .. src ..
            "\n**Choix tenté:** " .. tostring(choice) ..
            "\n→ Ce joueur a déjà voté.",
            16776960
        )
        return
    end

    if not CurrentVotes[choice] then
        SendLog("securite", "❓ Choix invalide",
            "**ID:** " .. src ..
            "\n**Choix reçu:** " .. tostring(choice) ..
            "\n→ Cette map n'existe pas dans la liste.",
            15158332
        )
        return
    end

    HasVoted[src]        = true
    CurrentVotes[choice] = CurrentVotes[choice] + 1

    local xPlayer  = ESX.GetPlayerFromId(src)
    local pName    = xPlayer and xPlayer.getName() or ("ID " .. src)
    local totalSoFar = 0

    for _, v in pairs(CurrentVotes) do totalSoFar = totalSoFar + v end

    SendLog("vote", "🗳️ Vote reçu",
        "**ID:** " .. src ..
        "\n**Nom:** " .. pName ..
        "\n**Choix:** " .. Labels[choice] .. " (" .. choice .. ")" ..
        "\n**Votes pour cette map:** " .. CurrentVotes[choice] ..
        "\n**Total votes exprimés:** " .. totalSoFar,
        10181046
    )

    TriggerClientEvent('choosepos:updateVotes', -1, CurrentVotes)
end)

RegisterNetEvent('choosepos:refuseVote')
AddEventHandler('choosepos:refuseVote', function()
    local src = source

    if not VoteActive then
        return
    end

    RefusedPlayers[src] = true

    local xPlayer = ESX.GetPlayerFromId(src)
    local pName   = xPlayer and xPlayer.getName() or ("ID " .. src)

    SendLog("vote", "❌ Vote Refusé",
        "**ID:** " .. src ..
        "\n**Nom:** " .. pName ..
        "\n→ Ce joueur a refusé de participer au POSPOS.",
        15158332
    )
end)

RegisterNetEvent('choosepos:requestEquipeData')
AddEventHandler('choosepos:requestEquipeData', function()
    local src  = source
    local data = { interieur = {}, exterieur = {} }

    for pid, slot in pairs(TeamAssignments) do
        local px   = ESX.GetPlayerFromId(pid)
        local name = px and px.getName() or ("ID " .. pid)
        table.insert(data[slot], name)
    end

    TriggerClientEvent('choosepos:receiveEquipeDataAndOpenMenu', src, data)
    TriggerClientEvent('choosepos:updateEquipeData', src, data)
end)

RegisterNetEvent('choosepos:joueurMort')
AddEventHandler('choosepos:joueurMort', function()
    local src  = source
    local slot = TeamAssignments[src]

    if not slot then return end
    if not CurrentMap then return end

    if MortsEquipe[slot][src] then return end

    MortsEquipe[slot][src] = true

    -- Notifie tous les clients pour mettre à jour le point mort du HUD
    TriggerClientEvent('choosepos:hudPlayerDead', -1, src)


    local totalEquipe = 0
    local mortsCount  = 0

    for pid, s in pairs(TeamAssignments) do
        if s == slot then
            totalEquipe = totalEquipe + 1
            if MortsEquipe[slot][pid] then
                mortsCount = mortsCount + 1
            end
        end
    end

    if totalEquipe > 0 and mortsCount >= totalEquipe then
        local equipeGagnante = (slot == "interieur") and "exterieur" or "interieur"
        local labelGagnant   = (equipeGagnante == "interieur") and "🏠 INTÉRIEUR" or "🌿 EXTÉRIEUR"
        local tenueGagnante  = (equipeGagnante == "interieur") and TenueInterieur or TenueExterieur
        local mapLabel       = CurrentMap and Labels[CurrentMap] or "?"

        TriggerClientEvent('esx:showNotification', -1,
            "~y~🏆 VICTOIRE ~w~— Équipe " .. labelGagnant ..
            " ~g~(" .. (tenueGagnante or "?") .. ")~w~ remporte la manche sur ~y~" .. mapLabel .. "~w~ !")

        SendLog("equipes", "🏆 Victoire détectée — Inversion automatique",
            "**Équipe gagnante:** " .. labelGagnant ..
            "\n**Tenue:** " .. (tenueGagnante or "?") ..
            "\n**Map:** " .. mapLabel ..
            "\n**Équipe éliminée (" .. slot .. "):** " .. mortsCount .. "/" .. totalEquipe .. " morts" ..
            "\n→ Lancement automatique du **chooseposinverse**",
            5763719
        )

        MortsEquipe = { interieur = {}, exterieur = {} }
        TriggerClientEvent('choosepos:hudResetDead', -1)

        -- ══════════════════════════════════════════════════
        --  INVERSION AUTOMATIQUE
        -- ══════════════════════════════════════════════════
        if VoteActive then return end

        local dest = Destinations[CurrentMap]
        if not dest then return end

        -- Inverser les équipes
        for pid, s in pairs(TeamAssignments) do
            TeamAssignments[pid] = (s == "interieur") and "exterieur" or "interieur"
        end

        local intList = ""
        local extList = ""

        for _, pid in ipairs(GetPlayers()) do
            local s = tonumber(pid)
            if not RefusedPlayers[s] then
                local newSlot    = TeamAssignments[s]
                if not newSlot then
                    newSlot = "interieur"
                    TeamAssignments[s] = newSlot
                end

                local coords     = dest[newSlot]
                local tenueLabel = (newSlot == "interieur") and TenueInterieur or TenueExterieur
                local px         = ESX.GetPlayerFromId(s)
                local pnick      = px and px.getName() or ("ID " .. s)

                if newSlot == "interieur" then
                    intList = intList .. pnick .. " (ID:" .. s .. ")\n"
                else
                    extList = extList .. pnick .. " (ID:" .. s .. ")\n"
                end

                TriggerClientEvent('choosepos:inverseEquipes', s, coords, newSlot, tenueLabel)
            end
        end

        BroadcastHudUpdate()
        TriggerClientEvent('esx:showNotification', -1, "~y~[AUTO-INVERSE]~w~ Les équipes ont été inversées automatiquement !")

        SendLog("equipes", "🔄 Auto-Inverse — Équipes inversées automatiquement",
            "**Map:** " .. mapLabel ..
            "\n**Tenue Intérieur:** " .. (TenueInterieur or "?") ..
            "\n**Tenue Extérieur:** " .. (TenueExterieur or "?") ..
            "\n\n🏠 **Intérieur (après inversion):**\n" .. (intList ~= "" and intList or "_aucun_") ..
            "\n🌿 **Extérieur (après inversion):**\n" .. (extList ~= "" and extList or "_aucun_"),
            16744272
        )
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  PANEL ADMIN — Gestion des positions et tenues en jeu
-- ══════════════════════════════════════════════════════════════════════════════

-- Retourne toutes les données nécessaires au panel admin
RegisterNetEvent('choosepos:adminOpenPanel')
AddEventHandler('choosepos:adminOpenPanel', function()
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not AllowedGroups[xPlayer.getGroup()] then
        TriggerClientEvent('esx:showNotification', src, "~r~Permission refusée.")
        return
    end

    -- Construit les listes simplifiées à envoyer au client
    local destData   = {}
    for k, v in pairs(Destinations) do
        destData[k] = {
            interieur = { x = v.interieur.x, y = v.interieur.y, z = v.interieur.z, w = v.interieur.w },
            exterieur = { x = v.exterieur.x, y = v.exterieur.y, z = v.exterieur.z, w = v.exterieur.w },
        }
    end

    TriggerClientEvent('choosepos:adminReceiveData', src, {
        destinations   = destData,
        labels         = Labels,
        tenueInterieur = TenueInterieur,
        tenueExterieur = TenueExterieur,
        currentMap     = CurrentMap,
        voteActive     = VoteActive,
    })
end)

-- Met à jour une position (intérieur ou extérieur) pour une map donnée
RegisterNetEvent('choosepos:adminSetPosition')
AddEventHandler('choosepos:adminSetPosition', function(mapKey, slot, coords)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not AllowedGroups[xPlayer.getGroup()] then
        TriggerClientEvent('esx:showNotification', src, "~r~Permission refusée.")
        return
    end

    if not Destinations[mapKey] then
        TriggerClientEvent('esx:showNotification', src, "~r~Map introuvable : " .. tostring(mapKey))
        return
    end

    if slot ~= "interieur" and slot ~= "exterieur" then
        TriggerClientEvent('esx:showNotification', src, "~r~Slot invalide.")
        return
    end

    Destinations[mapKey][slot] = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = coords.w or Destinations[mapKey][slot].w,
    }

    local pName = xPlayer.getName()
    SendLog("commande", "📍 Position modifiée (admin panel)",
        "**Par:** " .. pName .. " (ID: " .. src .. ")" ..
        "\n**Map:** " .. (Labels[mapKey] or mapKey) ..
        "\n**Slot:** " .. slot ..
        "\n**Nouvelles coords:** X=" .. coords.x .. " Y=" .. coords.y .. " Z=" .. coords.z .. " W=" .. (coords.w or "?"),
        3447003
    )

    -- Persistance MySQL
    MySQL.Async.execute([[
        INSERT INTO `choosepos_positions` (map_key, slot, x, y, z, w)
        VALUES (@map_key, @slot, @x, @y, @z, @w)
        ON DUPLICATE KEY UPDATE x = @x, y = @y, z = @z, w = @w
    ]], {
        ['@map_key'] = mapKey,
        ['@slot']    = slot,
        ['@x']       = coords.x,
        ['@y']       = coords.y,
        ['@z']       = coords.z,
        ['@w']       = coords.w or 0.0,
    }, function() end)

    TriggerClientEvent('esx:showNotification', src,
        "~g~Position ~y~" .. slot .. " ~g~mise à jour pour ~w~" .. (Labels[mapKey] or mapKey))
end)

-- Met à jour la tenue intérieur ou extérieur en live
RegisterNetEvent('choosepos:adminSetTenue')
AddEventHandler('choosepos:adminSetTenue', function(slot, tenueLabel)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not AllowedGroups[xPlayer.getGroup()] then
        TriggerClientEvent('esx:showNotification', src, "~r~Permission refusée.")
        return
    end

    if slot == "interieur" then
        TenueInterieur = tenueLabel
    elseif slot == "exterieur" then
        TenueExterieur = tenueLabel
    else
        TriggerClientEvent('esx:showNotification', src, "~r~Slot invalide.")
        return
    end

    local pName = xPlayer.getName()
    SendLog("commande", "👕 Tenue modifiée (admin panel)",
        "**Par:** " .. pName .. " (ID: " .. src .. ")" ..
        "\n**Slot:** " .. slot ..
        "\n**Nouvelle tenue:** " .. tenueLabel,
        10181046
    )

    TriggerClientEvent('esx:showNotification', src,
        "~g~Tenue ~y~" .. slot .. " ~g~→ ~w~" .. tenueLabel)
end)

-- Réinitialise manuellement les morts d'une équipe (util si bug)
RegisterNetEvent('choosepos:adminResetMorts')
AddEventHandler('choosepos:adminResetMorts', function()
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not AllowedGroups[xPlayer.getGroup()] then return end

    MortsEquipe = { interieur = {}, exterieur = {} }
    TriggerClientEvent('esx:showNotification', src, "~g~Compteur de morts réinitialisé.")
end)
