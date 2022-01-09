local QBCore = exports['qb-core']:GetCoreObject()

local searched = {3423423424}
local dumpsters = {-1096777189, 666561306, 1437508529, -1426008804, -228596739, 161465839, 651101403, -58485588, 1614656839, -58485588, 218085040}
local canSearch = true

RegisterNetEvent('qb-trashsearch:client:searchtrash', function()
    if canSearch then
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)
        local dumpsterFound = false

        for i = 1, #dumpsters do
            local dumpster = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, dumpsters[i], false, false, false)
            local dumpPos = GetEntityCoords(dumpster)
            local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, dumpPos.x, dumpPos.y, dumpPos.z, true)

            if dist < 1.8 then
            for i = 1, #searched do
                if searched[i] == dumpster then
                    dumpsterFound = true
                end
                if i == #searched and dumpsterFound then
                    QBCore.Functions.Notify('This dumpster has already been searched', 'error')
                elseif i == #searched and not dumpsterFound then

                local itemType = math.random(#Config.RewardTypes)
                TriggerEvent('qb-trashsearch:client:progressbar',itemType)
                TriggerServerEvent('qb-trashsearch:server:startDumpsterTimer', dumpster)
                table.insert(searched, dumpster)
                end
            end
        end
    end
end
end)

RegisterNetEvent('qb-trashsearch:server:removeDumpster')
AddEventHandler('qb-trashsearch:server:removeDumpster', function(object)
    for i = 1, #searched do
        if searched[i] == object then
            table.remove(searched, i)
        end
    end
end)

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

RegisterNetEvent('qb-trashsearch:client:progressbar', function(itemType)
	local src = source
    local ply = QBCore.Functions.GetPlayerData()
    QBCore.Functions.Progressbar("trash_find", "Dumpster Diving", math.random (1, 1), false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "amb@prop_human_bum_bin@idle_b",
        anim = "idle_d",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 1.0)
        if Config.RewardTypes[itemType].type == "item" then
            QBCore.Functions.Notify("Looks like you found something", "success")
            QBCore.Functions.Notify("You smell like shit")
            TriggerServerEvent('qb-trashsearch:server:recieveItem')
        elseif Config.RewardTypes[itemType].type == "money" then
            QBCore.Functions.Notify("You found some cash", "success")
            QBCore.Functions.Notify("You smell like shit")
            TriggerServerEvent('qb-trashsearch:server:givemoney', math.random (21, 39))
        elseif Config.RewardTypes[itemType].type == "nothing" then
            QBCore.Functions.Notify("You found nothing", "error")
            QBCore.Functions.Notify("You smell like shit")
        end
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 1.0)
        QBCore.Functions.Notify("Stopped Searching", "error")
    end)
end)
