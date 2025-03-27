local VolStart = false
local Roll
local Object = 0

local function CheckPlayer()
    local playerPed = GetPlayerPed(source)
    if not playerPed then
        return false
    end
    if GetVehiclePedIsIn(playerPed, false) > 0 then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    for i = 1, #VolCoords do
        local coords = VolCoords[i]
        local distance = #(playerCoords - coords)
        if distance <= VolRadius then
            return true
        end
    end
    return false
end

RegisterNetEvent("fivem:stopVol")
AddEventHandler("fivem:stopVol", function()
    VolStart = false
end)

RegisterNetEvent("fivem:createOneVol")
AddEventHandler("fivem:createOneVol", function()
    if not VolStart or not CheckPlayer() then
        VolStart = false
        TriggerClientEvent("fivem:stopVol", source, Roll)
        return
    end

    if Roll == 1 then
        VolStart = false
        --TriggerClientEvent("fivem:badRollExplose", source)
        return
    end
    Roll = math.random(1, 100);

    Object = Object + 1
    TriggerClientEvent("fivem:createOneVolSuccess", source, Object, Roll)
end)

RegisterNetEvent("fivem:checkStartVol")
AddEventHandler("fivem:checkStartVol", function()
    if VolStart then
        return false
    end
    if CheckPlayer() then
        Roll = math.random(1, 100);
        TriggerClientEvent("fivem:volStartOk", source, Roll)
        VolStart = true
    end
end)