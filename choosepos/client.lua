local COOLDOWN_TIR_SECONDES = 60

local UI_OPEN   = false
local TirBloque = false

local ProtectedZones = {
    { label = "Lobby",   coords = vector3(-429.0129, 1110.8551, 327.6910), radius = 500.0 },
}

local function isInProtectedZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(ProtectedZones) do
        if #(playerCoords - zone.coords) <= zone.radius then
            return true, zone.label
        end
    end
    return false, nil
end

local Tenues = {
    {
        label = "Madrazo",
        tenue = {
            homme = { tshirt = {15, 0}, torso = {93,  0},  arms = {30, 0}, pants = {47,  1}, shoes = {29,  0} },
            femme = { tshirt = {14, 0}, torso = {85,  0},  arms = {14, 0}, pants = {45,  0}, shoes = {31,  0} },
        }
    },
    {
        label = "Duggan",
        tenue = {
            homme = { tshirt = {15, 0}, torso = {138, 0},  arms = {30, 0}, pants = {10,  0}, shoes = {10,  0} },
            femme = { tshirt = {14, 0}, torso = {135, 0},  arms = {36, 0}, pants = {1,   0}, shoes = {180, 0} },
        }
    },
    {
        label = "Vagos",
        tenue = {
            homme = { tshirt = {15, 0}, torso = {14,  1},  arms = {1,  0}, pants = {42,  0}, shoes = {7,   0} },
            femme = { tshirt = {14, 0}, torso = {121, 10}, arms = {3,  0}, pants = {1,   0}, shoes = {180, 0} },
        }
    },
    {
        label = "Ballas",
        tenue = {
            homme = { tshirt = {1,  0}, torso = {7,   9},  arms = {30, 0}, pants = {1,   8}, shoes = {7,   0} },
            femme = { tshirt = {14, 0}, torso = {368, 0},  arms = {0,  0}, pants = {1,   0}, shoes = {180, 0} },
        }
    },
    {
        label = "Marabunta",
        tenue = {
            homme = { tshirt = {15, 0}, torso = {14,  0},  arms = {30, 0}, pants = {42,  0}, shoes = {7,   0} },
            femme = { tshirt = {14, 0}, torso = {121, 6},  arms = {3,  0}, pants = {1,   0}, shoes = {180, 0} },
        }
    },
    {
        label = "BMF",
        tenue = {
            homme = { tshirt = {15, 0}, torso = {111, 3},  arms = {1,  0}, pants = {10,  0}, shoes = {12,  6} },
            femme = { tshirt = {14, 0}, torso = {103, 3},  arms = {36, 0}, pants = {3,   0}, shoes = {180, 0} },
        }
    },
    {
        label = "Famillies",
        tenue = {
            homme = { tshirt = {15, 0}, torso = {467, 0},  arms = {1,  0}, pants = {5,   6}, shoes = {7,   0} },
            femme = { tshirt = {14, 0}, torso = {501, 0},  arms = {3,  0}, pants = {220, 0}, shoes = {180, 0} },
        }
    },
}

local function ApplyTenue(tenue)
    local ped     = PlayerPedId()
    local isFemme = GetEntityModel(ped) == GetHashKey("mp_f_freemode_01")
    local t       = isFemme and tenue.femme or tenue.homme

    SetPedComponentVariation(ped, 8,  t.tshirt[1], t.tshirt[2], 2)
    SetPedComponentVariation(ped, 11, t.torso[1],  t.torso[2],  2)
    SetPedComponentVariation(ped, 9,  t.arms[1],   t.arms[2],   2)
    SetPedComponentVariation(ped, 4,  t.pants[1],  t.pants[2],  2)
    SetPedComponentVariation(ped, 6,  t.shoes[1],  t.shoes[2],  2)
end

local function ActiverCooldownTir()
    TirBloque = true
    local remaining = COOLDOWN_TIR_SECONDES

    SendNUIMessage({
        action = "showCooldown",
        time   = remaining
    })

    Citizen.CreateThread(function()
        while remaining > 0 and TirBloque do
            local protected, label = isInProtectedZone()
            if protected then
                TirBloque = false
                TriggerEvent('esx:showNotification', ("~g~Cooldown annulé~s~ — Zone protégée (%s)"):format(label))
                SendNUIMessage({ action = "hideCooldown" })
                return
            end
            Citizen.Wait(1000)
            remaining = remaining - 1
            SendNUIMessage({
                action = "updateCooldown",
                time   = remaining
            })
        end

        TirBloque = false
        TriggerEvent('esx:showNotification', "~g~Vous pouvez maintenant tirer !")
        SendNUIMessage({ action = "hideCooldown" })
    end)

    Citizen.CreateThread(function()
        while TirBloque do
            DisableControlAction(0, 24,  true)
            DisableControlAction(0, 25,  true)
            DisableControlAction(0, 42,  true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            Citizen.Wait(0)
        end
    end)
end

local function TeleportSequence(coords, callback)
    local ped = PlayerPedId()
    if not coords then return end

    DoScreenFadeOut(800)
    Citizen.Wait(900)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)

    if coords.w then
        SetEntityHeading(ped, coords.w)
    end

    FreezeEntityPosition(ped, true)
    Citizen.Wait(1500)
    FreezeEntityPosition(ped, false)

    DoScreenFadeIn(800)

    if callback then callback() end
end

RegisterNetEvent('choosepos:openTenuePicker')
AddEventHandler('choosepos:openTenuePicker', function()
    local options = {}
    for i, entry in ipairs(Tenues) do
        options[i] = { label = entry.label, value = i }
    end

    local intChoix = lib.inputDialog("🏠 Tenue Intérieur", {
        { type = "select", label = "Choisir la tenue", options = options, required = true }
    })

    if not intChoix or not intChoix[1] then
        TriggerEvent('esx:showNotification', "~r~Sélection annulée.")
        return
    end

    local tenueIntIndex = intChoix[1]
    local tenueInt      = Tenues[tenueIntIndex]

    local optionsExt = {}
    for i, entry in ipairs(Tenues) do
        if i ~= tenueIntIndex then
            optionsExt[#optionsExt + 1] = { label = entry.label, value = i }
        end
    end

    local extChoix = lib.inputDialog("🌿 Tenue Extérieur", {
        { type = "select", label = "Choisir la tenue", options = optionsExt, required = true }
    })

    if not extChoix or not extChoix[1] then
        TriggerEvent('esx:showNotification', "~r~Sélection annulée.")
        return
    end

    local tenueExt = Tenues[extChoix[1]]

    TriggerServerEvent('choosepos:confirmTenues', tenueInt.label, tenueExt.label)

    TriggerEvent('esx:showNotification',
        "~g~Tenues confirmées : ~w~" .. tenueInt.label .. " ~g~(Int) ~w~/ ~r~" .. tenueExt.label .. " ~r~(Ext)")
end)

RegisterNetEvent('choosepos:applyTenue')
AddEventHandler('choosepos:applyTenue', function(tenueLabel)
    for _, entry in ipairs(Tenues) do
        if entry.label == tenueLabel then
            ApplyTenue(entry.tenue)
            return
        end
    end
end)

RegisterNetEvent('choosepos:startVote')
AddEventHandler('choosepos:startVote', function(time, initialVotes)
    if UI_OPEN then return end

    UI_OPEN = true
    TriggerScreenblurFadeIn(500)
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "openUI",
        time   = time,
        votes  = initialVotes
    })
end)

RegisterNetEvent('choosepos:updateVotes')
AddEventHandler('choosepos:updateVotes', function(votes)
    if not UI_OPEN then return end

    SendNUIMessage({
        action = "updateVotes",
        votes  = votes
    })
end)

RegisterNetEvent('choosepos:endVote')
AddEventHandler('choosepos:endVote', function(winningChoice, coords, slot)
    TriggerScreenblurFadeOut(500)
    SendNUIMessage({ action = "closeUI" })
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    UI_OPEN = false

    if coords then
        local slotLabel = (slot == "interieur") and "~b~INTÉRIEUR" or "~r~EXTÉRIEUR"
        TriggerEvent('esx:showNotification', slotLabel .. " ~w~— Téléportation en cours...")

        TeleportSequence(coords, function()
            ActiverCooldownTir()
        end)
    end
end)

RegisterNetEvent('choosepos:inverseEquipes')
AddEventHandler('choosepos:inverseEquipes', function(coords, slot, tenueLabel)
    local slotLabel = (slot == "interieur") and "~b~INTÉRIEUR" or "~r~EXTÉRIEUR"
    TriggerEvent('esx:showNotification', "~y~[INVERSE]~w~ Vous passez " .. slotLabel .. " — Téléportation...")

    for _, entry in ipairs(Tenues) do
        if entry.label == tenueLabel then
            ApplyTenue(entry.tenue)
            break
        end
    end

    TeleportSequence(coords, function()
        ActiverCooldownTir()
    end)
end)

RegisterNetEvent('choosepos:forceClose')
AddEventHandler('choosepos:forceClose', function()
    if not UI_OPEN then return end

    TriggerScreenblurFadeOut(500)
    SendNUIMessage({ action = "closeUI" })
    SetNuiFocus(false, false)
    UI_OPEN = false
end)

RegisterNUICallback('sendVote', function(data, cb)
    if data and data.choice then
        TriggerServerEvent('choosepos:receiveVote', data.choice)
    end
    cb('ok')
end)

RegisterNUICallback('refuseVote', function(data, cb)
    UI_OPEN = false
    TriggerScreenblurFadeOut(500)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "closeUI" })
    TriggerServerEvent('choosepos:refuseVote')
    cb('ok')
end)

Citizen.CreateThread(function()
    local estMort = false
    while true do
        Citizen.Wait(500)
        local ped  = PlayerPedId()
        local mort = IsEntityDead(ped) or IsPedDeadOrDying(ped, true)

        if mort and not estMort then
            estMort = true
            TriggerServerEvent('choosepos:joueurMort')
        elseif not mort then
            estMort = false
        end
    end
end)

local EquipeData = { interieur = {}, exterieur = {} }

RegisterNetEvent('choosepos:updateEquipeData')
AddEventHandler('choosepos:updateEquipeData', function(data)
    EquipeData = data
end)

RegisterCommand('equipesmenu', function()
    TriggerServerEvent('choosepos:requestEquipeData')
end, false)

RegisterNetEvent('choosepos:receiveEquipeDataAndOpenMenu')
AddEventHandler('choosepos:receiveEquipeDataAndOpenMenu', function(data)
    EquipeData = data

    local int = EquipeData.interieur
    local ext = EquipeData.exterieur

    local intLabel = "🏠 Équipe INTÉRIEUR — " .. #int .. " joueur(s)"
    local extLabel = "🌿 Équipe EXTÉRIEUR — " .. #ext .. " joueur(s)"

    local intPlayers = ""
    for _, name in ipairs(int) do
        intPlayers = intPlayers .. "• " .. name .. "\n"
    end
    if intPlayers == "" then intPlayers = "Aucun joueur" end

    local extPlayers = ""
    for _, name in ipairs(ext) do
        extPlayers = extPlayers .. "• " .. name .. "\n"
    end
    if extPlayers == "" then extPlayers = "Aucun joueur" end

    lib.registerContext({
        id    = 'choosepos_equipes_menu',
        title = '👥 Équipes en cours',
        options = {
            {
                title    = intLabel,
                disabled = true,
                icon     = 'house',
            },
            {
                title    = intPlayers,
                disabled = true,
                icon     = 'user-group',
            },
            {
                title    = '──────────────────',
                disabled = true,
            },
            {
                title    = extLabel,
                disabled = true,
                icon     = 'tree',
            },
            {
                title    = extPlayers,
                disabled = true,
                icon     = 'user-group',
            },
            {
                title    = '──────────────────',
                disabled = true,
            },
            {
                title       = '📢 Envoyer une annonce globale',
                description = 'Affiche un grand message à tous les joueurs',
                icon        = 'bullhorn',
                onSelect    = function()
                    local input = lib.inputDialog('📢 Annonce Globale', {
                        {
                            type        = 'input',
                            label       = 'Message à diffuser',
                            placeholder = 'Ex: La partie commence dans 30 secondes !',
                            required    = true,
                            min         = 3,
                            max         = 200,
                        }
                    })

                    if not input or not input[1] or input[1] == '' then
                        lib.notify({ title = 'Annonce annulée', type = 'error' })
                        return
                    end

                    TriggerServerEvent('AdminMenu:annonceGTA', input[1])
                    lib.notify({ title = '✅ Annonce envoyée', description = input[1], type = 'success' })
                end
            },
        }
    })

    lib.showContext('choosepos_equipes_menu')
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  PANEL ADMIN — Configuration des positions et tenues en jeu
-- ══════════════════════════════════════════════════════════════════════════════

local AdminData = nil  -- données reçues du serveur

-- Tenues disponibles (miroir du tableau Tenues pour les labels)
local TenueLabels = {}
for _, entry in ipairs(Tenues) do
    table.insert(TenueLabels, entry.label)
end

-- ─── Réception des données serveur ─────────────────────────────────────────
RegisterNetEvent('choosepos:adminReceiveData')
AddEventHandler('choosepos:adminReceiveData', function(data)
    AdminData = data
    OpenAdminPanelMain()
end)

-- ─── Menu principal du panel ────────────────────────────────────────────────
function OpenAdminPanelMain()
    if not AdminData then return end

    local mapLabel   = AdminData.currentMap and (AdminData.labels[AdminData.currentMap] or AdminData.currentMap) or "Aucune"
    local tenueInt   = AdminData.tenueInterieur or "Non définie"
    local tenueExt   = AdminData.tenueExterieur or "Non définie"
    local voteStatus = AdminData.voteActive and "~r~Actif" or "~g~Inactif"

    lib.registerContext({
        id    = 'choosepos_admin_main',
        title = '⚙️ ChoosePos — Panel Admin',
        options = {
            {
                title       = '📊 État actuel',
                description = 'Map: ' .. mapLabel .. ' | Vote: ' .. voteStatus .. '\nInt: ' .. tenueInt .. ' | Ext: ' .. tenueExt,
                disabled    = true,
                icon        = 'circle-info',
            },
            {
                title       = '📍 Configurer les positions',
                description = 'Modifier les spawns intérieur / extérieur de chaque map',
                icon        = 'map-marker-alt',
                onSelect    = OpenAdminPositionsMenu,
            },
            {
                title       = '👕 Configurer les tenues',
                description = 'Changer la tenue intérieur ou extérieur en cours',
                icon        = 'shirt',
                onSelect    = OpenAdminTenuesMenu,
            },
            {
                title       = '🔄 Reset compteur de morts',
                description = 'Réinitialise les morts des deux équipes (en cas de bug)',
                icon        = 'rotate',
                onSelect    = function()
                    TriggerServerEvent('choosepos:adminResetMorts')
                end,
            },
        }
    })

    lib.showContext('choosepos_admin_main')
end

-- ─── Menu sélection de la map pour les positions ────────────────────────────
function OpenAdminPositionsMenu()
    if not AdminData then return end

    local options = {
        {
            title    = '← Retour',
            icon     = 'arrow-left',
            onSelect = OpenAdminPanelMain,
        }
    }

    -- Trie les maps par label
    local sortedMaps = {}
    for k, label in pairs(AdminData.labels) do
        table.insert(sortedMaps, { key = k, label = label })
    end
    table.sort(sortedMaps, function(a, b) return a.label < b.label end)

    for _, entry in ipairs(sortedMaps) do
        local k     = entry.key
        local label = entry.label
        local dest  = AdminData.destinations[k]
        local intC  = dest and dest.interieur
        local extC  = dest and dest.exterieur

        local descInt = intC and ("X:%.1f Y:%.1f Z:%.1f"):format(intC.x, intC.y, intC.z) or "?"
        local descExt = extC and ("X:%.1f Y:%.1f Z:%.1f"):format(extC.x, extC.y, extC.z) or "?"

        table.insert(options, {
            title       = '📍 ' .. label,
            description = '🏠 Int: ' .. descInt .. '\n🌿 Ext: ' .. descExt,
            icon        = 'location-dot',
            onSelect    = function()
                OpenAdminMapSlotMenu(k, label)
            end,
        })
    end

    lib.registerContext({
        id      = 'choosepos_admin_positions',
        title   = '📍 Positions des maps',
        options = options,
    })
    lib.showContext('choosepos_admin_positions')
end

-- ─── Menu choix du slot (int/ext) pour une map ──────────────────────────────
function OpenAdminMapSlotMenu(mapKey, mapLabel)
    if not AdminData then return end

    local dest = AdminData.destinations[mapKey]
    local intC = dest and dest.interieur
    local extC = dest and dest.exterieur

    lib.registerContext({
        id    = 'choosepos_admin_mapslot',
        title = '📍 ' .. mapLabel,
        options = {
            {
                title    = '← Retour',
                icon     = 'arrow-left',
                onSelect = OpenAdminPositionsMenu,
            },
            {
                title       = '🏠 Modifier INTÉRIEUR',
                description = intC and ("Actuel: X:%.1f Y:%.1f Z:%.1f"):format(intC.x, intC.y, intC.z) or "Non défini",
                icon        = 'house',
                onSelect    = function()
                    CapturePositionAndSend(mapKey, mapLabel, "interieur")
                end,
            },
            {
                title       = '🌿 Modifier EXTÉRIEUR',
                description = extC and ("Actuel: X:%.1f Y:%.1f Z:%.1f"):format(extC.x, extC.y, extC.z) or "Non défini",
                icon        = 'tree',
                onSelect    = function()
                    CapturePositionAndSend(mapKey, mapLabel, "exterieur")
                end,
            },
            {
                title       = '🚀 Se téléporter — INTÉRIEUR',
                description = 'Aller sur le spawn intérieur actuel',
                icon        = 'person-running',
                onSelect    = function()
                    if intC then
                        local ped = PlayerPedId()
                        DoScreenFadeOut(500)
                        Citizen.Wait(600)
                        SetEntityCoordsNoOffset(ped, intC.x, intC.y, intC.z, false, false, false)
                        if intC.w then SetEntityHeading(ped, intC.w) end
                        DoScreenFadeIn(500)
                    else
                        lib.notify({ title = 'Coords introuvables', type = 'error' })
                    end
                end,
            },
            {
                title       = '🚀 Se téléporter — EXTÉRIEUR',
                description = 'Aller sur le spawn extérieur actuel',
                icon        = 'person-running',
                onSelect    = function()
                    if extC then
                        local ped = PlayerPedId()
                        DoScreenFadeOut(500)
                        Citizen.Wait(600)
                        SetEntityCoordsNoOffset(ped, extC.x, extC.y, extC.z, false, false, false)
                        if extC.w then SetEntityHeading(ped, extC.w) end
                        DoScreenFadeIn(500)
                    else
                        lib.notify({ title = 'Coords introuvables', type = 'error' })
                    end
                end,
            },
        }
    })
    lib.showContext('choosepos_admin_mapslot')
end

-- ─── Capture la position du joueur et envoie au serveur ─────────────────────
function CapturePositionAndSend(mapKey, mapLabel, slot)
    local confirm = lib.alertDialog({
        header  = '📍 Capturer la position',
        content = 'La position actuelle de ton personnage sera utilisée comme spawn **' .. slot .. '** pour **' .. mapLabel .. '**.\n\nTu veux continuer ?',
        centered = true,
        cancel   = true,
    })

    if confirm ~= 'confirm' then
        OpenAdminMapSlotMenu(mapKey, mapLabel)
        return
    end

    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TriggerServerEvent('choosepos:adminSetPosition', mapKey, slot, {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = heading,
    })

    -- Met à jour le cache local
    if AdminData and AdminData.destinations[mapKey] then
        AdminData.destinations[mapKey][slot] = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = heading,
        }
    end

    lib.notify({
        title       = '✅ Position sauvegardée',
        description = slot .. ' → ' .. mapLabel,
        type        = 'success',
    })

    OpenAdminMapSlotMenu(mapKey, mapLabel)
end

-- ─── Menu configuration des tenues ──────────────────────────────────────────
function OpenAdminTenuesMenu()
    if not AdminData then return end

    local tenueInt = AdminData.tenueInterieur or "Non définie"
    local tenueExt = AdminData.tenueExterieur or "Non définie"

    -- Options de tenue pour le select
    local tenueOptions = {}
    for _, label in ipairs(TenueLabels) do
        table.insert(tenueOptions, { label = label, value = label })
    end

    lib.registerContext({
        id    = 'choosepos_admin_tenues',
        title = '👕 Configuration des tenues',
        options = {
            {
                title    = '← Retour',
                icon     = 'arrow-left',
                onSelect = OpenAdminPanelMain,
            },
            {
                title       = '🏠 Tenue INTÉRIEUR',
                description = 'Actuelle : ' .. tenueInt,
                icon        = 'house',
                onSelect    = function()
                    SelectTenueSlot("interieur", tenueOptions)
                end,
            },
            {
                title       = '🌿 Tenue EXTÉRIEUR',
                description = 'Actuelle : ' .. tenueExt,
                icon        = 'tree',
                onSelect    = function()
                    SelectTenueSlot("exterieur", tenueOptions)
                end,
            },
        }
    })
    lib.showContext('choosepos_admin_tenues')
end

-- ─── Sélection de la tenue via inputDialog ───────────────────────────────────
function SelectTenueSlot(slot, tenueOptions)
    local input = lib.inputDialog('👕 Tenue ' .. slot:upper(), {
        {
            type     = 'select',
            label    = 'Choisir la tenue',
            options  = tenueOptions,
            required = true,
        }
    })

    if not input or not input[1] then
        OpenAdminTenuesMenu()
        return
    end

    local tenueLabel = input[1]

    TriggerServerEvent('choosepos:adminSetTenue', slot, tenueLabel)

    -- Met à jour le cache local
    if AdminData then
        if slot == "interieur" then
            AdminData.tenueInterieur = tenueLabel
        else
            AdminData.tenueExterieur = tenueLabel
        end
    end

    lib.notify({
        title       = '✅ Tenue mise à jour',
        description = slot .. ' → ' .. tenueLabel,
        type        = 'success',
    })

    OpenAdminTenuesMenu()
end

-- ─── Commande d'ouverture du panel ──────────────────────────────────────────
RegisterCommand('adminpos', function()
    TriggerServerEvent('choosepos:adminOpenPanel')
end, false)



-- ══════════════════════════════════════════════════════════════════════════════
--  HUD ÉQUIPES — Réception des events serveur
-- ══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('choosepos:hudUpdate')
AddEventHandler('choosepos:hudUpdate', function(data)
    SendNUIMessage({
        action   = "showHud",
        map      = data.map,
        players  = data.players,
    })
end)

RegisterNetEvent('choosepos:hudPlayerDead')
AddEventHandler('choosepos:hudPlayerDead', function(playerId, slot)
    SendNUIMessage({
        action = "hudPlayerDead",
        slot   = slot,
    })
end)

RegisterNetEvent('choosepos:hudResetDead')
AddEventHandler('choosepos:hudResetDead', function(data)
    SendNUIMessage({
        action  = "hudResetDead",
        map     = data and data.map or nil,
        players = data and data.players or nil,
    })
end)

-- /huddebug — staff only (vérification côté serveur)
RegisterNetEvent('choosepos:hudDebugOpen')
AddEventHandler('choosepos:hudDebugOpen', function(data)
    SendNUIMessage({
        action  = "showHud",
        map     = data.map,
        players = data.players,
    })
end)

RegisterCommand('huddebug', function()
    TriggerServerEvent('choosepos:requestHudDebug')
end, false)

RegisterCommand('hudclose', function()
    SendNUIMessage({ action = "hideHud" })
end, false)
