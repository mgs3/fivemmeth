local JourneyModel = GetHashKey("journey")
local MethStart = false
local Roll = 0
local Phenyl1Propanone2 = 100;
local Chlorhydrate = 100;
local Methamphetamine = 0
local Life = 150
local HasMask = false

local function checkPlayer()
    local playerPed = GetPlayerPed(source)
    if not playerPed then
        return false
    end
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    if not currentVehicle then
        return false
    end
    local currentModel = GetEntityModel(currentVehicle)
    if currentModel ~= JourneyModel then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    for i = 1, #MethCoords do
        local coords = MethCoords[i]
        local distance = #(playerCoords - coords)
        if distance <= MethRadius then
            return true
        end
    end
    return false
end

RegisterNetEvent("fivem:checkStartMeth")
AddEventHandler("fivem:checkStartMeth", function()
    if MethStart or not Life then
        return false
    end
    if Phenyl1Propanone2 < 2 or Chlorhydrate < 2 then
        TriggerClientEvent("fivem:insufficientIngredients", source)
        return false
    end
    if checkPlayer() then
        Roll = math.random(1, 100);
        TriggerClientEvent("fivem:methStartOk", source, Roll)
        MethStart = true
    end
end)

RegisterNetEvent("fivem:stopMeth")
AddEventHandler("fivem:stopMeth", function()
    MethStart = false
end)

RegisterNetEvent("fivem:createOneMeth")
AddEventHandler("fivem:createOneMeth", function()
    if not MethStart or not checkPlayer() or not Life then
        TriggerClientEvent("fivem:stopMeth", source)
        MethStart = false
        return
    end

    if Roll == 1 then
        MethStart = false
        TriggerClientEvent("fivem:badRollExplose", source)
        return
    end
    Roll = math.random(1, 100);

    if not HasMask then
        Life = Life - 1
        TriggerClientEvent("fivem:applySteamDamage", source, Life)
    end

    Phenyl1Propanone2 = Phenyl1Propanone2 - 2
    Chlorhydrate = Chlorhydrate - 2
    Methamphetamine = Methamphetamine + 1
    if Phenyl1Propanone2 < 2 or Chlorhydrate < 2 then
        MethStart = false
        TriggerClientEvent("fivem:endCreateMeth", source, Methamphetamine)
        return
    end
    TriggerClientEvent("fivem:createOneMethSuccess", source, Methamphetamine, Roll)
end)

RegisterNetEvent("fivem:setOnMask")
AddEventHandler("fivem:setOnMask", function()
    HasMask = true
end)

RegisterNetEvent("fivem:setOffMask")
AddEventHandler("fivem:setOffMask", function()
    HasMask = false
end)