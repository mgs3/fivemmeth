local volStart = false
local roll
local object = 0

local function checkPlayer()
    local playerPed = GetPlayerPed(source)
    if not playerPed then
        return false
    end
    if GetVehiclePedIsIn(playerPed, false) > 0 then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    for _, coords in pairs(VolCoords) do
        local distance = #(playerCoords - coords)
        if distance <= VolRadius then
            return true
        end
    end
    return false
end

RegisterNetEvent("fivem:stopVol")
AddEventHandler("fivem:stopVol", function()
    volStart = false
end)

RegisterNetEvent("fivem:createOneVol")
AddEventHandler("fivem:createOneVol", function()
    if not volStart or not checkPlayer() then
        volStart = false
        TriggerClientEvent("fivem:stopVol", source, roll)
        return
    end

    if roll == 1 then
        volStart = false
        --TriggerClientEvent("fivem:badRollExplose", source)
        return
    end
    roll = math.random(1, 100);

    object = object + 1
    TriggerClientEvent("fivem:createOneVolSuccess", source, object, roll)
end)

RegisterNetEvent("fivem:checkStartVol")
AddEventHandler("fivem:checkStartVol", function()
    if volStart then
        return false
    end
    if checkPlayer() then
        roll = math.random(1, 100);
        TriggerClientEvent("fivem:volStartOk", source, roll)
        volStart = true
    end
end)