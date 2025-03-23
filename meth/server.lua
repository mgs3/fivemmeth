local zoneCoords = vector3(1394.7477, 3627.9487, 34.3793)
local zoneRadius = 2
local journeyModel = GetHashKey("journey")
local methStart = false
local roll = 0
local phenyl1propanone2 = 100;
local chlorhydrate = 100;
local methamphetamine = 0
local life = 150
local hasmask = false

local function getDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function checkPlayer()
    local playerPed = GetPlayerPed(source)
    if playerPed == 0 or playerPed == nil then
        return false
    end
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    if currentVehicle == 0 or currentVehicle == nil then
        return false
    end
    local currentModel = GetEntityModel(currentVehicle)
    if currentModel ~= journeyModel then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    local distance = getDistance(playerCoords.x, playerCoords.y, playerCoords.z, zoneCoords.x, zoneCoords.y, zoneCoords.z)
    if distance > zoneRadius then
        return false
    end
    return true;
end

RegisterNetEvent("fivem:checkStartMeth")
AddEventHandler("fivem:checkStartMeth", function()
    if (methStart or life == 0) then
        return false
    end
    if (phenyl1propanone2 < 2 or chlorhydrate < 2) then
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
    if methStart == false or checkPlayer() == false or life == 0 then
        return
    end

    if (roll == 1) then
        methStart = false
        TriggerClientEvent("fivem:badRollExplose", source)
        return
    end
    roll = math.random(1, 100);

    if (hasmask == false) then
        life = life - 1
        TriggerClientEvent("fivem:applySteamDamage", source, life)
    end

    phenyl1propanone2 = phenyl1propanone2 - 2
    chlorhydrate = chlorhydrate - 2
    methamphetamine = methamphetamine + 1
    if (phenyl1propanone2 < 2 or chlorhydrate < 2) then
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