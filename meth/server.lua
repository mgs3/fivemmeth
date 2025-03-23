local journeyModel = GetHashKey("journey")
local methStart = false
local roll = 0
local phenyl1propanone2 = 100;
local chlorhydrate = 100;
local methamphetamine = 0
local life = 150
local hasmask = false

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
    if currentModel ~= journeyModel then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    for _, coords in pairs(MethCoords) do
        local distance = #(playerCoords - coords)
        if distance <= MethRadius then
            return true
        end
    end
    return false
end

RegisterNetEvent("fivem:checkStartMeth")
AddEventHandler("fivem:checkStartMeth", function()
    if methStart or not life then
        return false
    end
    if phenyl1propanone2 < 2 or chlorhydrate < 2 then
        TriggerClientEvent("fivem:insufficientIngredients", source)
        return false
    end
    if checkPlayer() then
        roll = math.random(1, 100);
        TriggerClientEvent("fivem:methStartOk", source, roll)
        methStart = true
    end
end)

RegisterNetEvent("fivem:stopMeth")
AddEventHandler("fivem:stopMeth", function()
    methStart = false
end)

RegisterNetEvent("fivem:createOneMeth")
AddEventHandler("fivem:createOneMeth", function()
    if not methStart or not checkPlayer() or not life then
        TriggerClientEvent("fivem:stopMeth", source)
        methStart = false
        return
    end

    if roll == 1 then
        methStart = false
        TriggerClientEvent("fivem:badRollExplose", source)
        return
    end
    roll = math.random(1, 100);

    if not hasmask then
        life = life - 1
        TriggerClientEvent("fivem:applySteamDamage", source, life)
    end

    phenyl1propanone2 = phenyl1propanone2 - 2
    chlorhydrate = chlorhydrate - 2
    methamphetamine = methamphetamine + 1
    if phenyl1propanone2 < 2 or chlorhydrate < 2 then
        methStart = false
        TriggerClientEvent("fivem:endCreateMeth", source, methamphetamine)
        return
    end
    TriggerClientEvent("fivem:createOneMethSuccess", source, methamphetamine, roll)
end)

RegisterNetEvent("fivem:setOnMask")
AddEventHandler("fivem:setOnMask", function()
    hasmask = true
end)

RegisterNetEvent("fivem:setOffMask")
AddEventHandler("fivem:setOffMask", function()
    hasmask = false
end)