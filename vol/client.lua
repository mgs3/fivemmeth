local actionKeyE = 38
local volStart = false

local function IsPlayerInZone()
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) or IsPedInAnyVehicle(playerPed, false) then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    for _, coords in pairs(VolCoords) do
        if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) < VolRadius then
            return true
        end
    end
    return false
end

local function PlayAnimationVol()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, "anim@heists@ornate_bank@grab_cash", "grab", 8.0, -8.0, 3000, 49, 0, false, false, false)
end

local function CreateOneVol()
    if not volStart then
        return
    end
    if IsPlayerInZone() then
        PlayAnimationVol()
        DrawTextForDuration("Vol en cours...", 2500, 0.4, 0.87, 255, 255, 255)
        DrawProgressBar(3000)
        TriggerServerEvent("fivem:createOneVol")
    else
        volStart = false
        TriggerServerEvent("fivem:stopVol")
    end
end

RegisterNetEvent("fivem:volStartOk")
AddEventHandler("fivem:volStartOk", function(roll)
    DrawTextForDuration("Lancé de dé : "..roll, 2500, 0.4, 0.91, 255, 255, 255)
    volStart = true
    --local playerPed = PlayerPedId()
    --local vehicle = GetVehiclePedIsIn(playerPed, false)
    --PlayParticule("smoke" , "exp_grd_bzgas_smoke", vehicle, -0.6, -2.0, 0.8, 0.0, 0.0, 0.0, 1.5)
    CreateOneVol()
end)

RegisterNetEvent("fivem:createOneVolSuccess")
AddEventHandler("fivem:createOneVolSuccess", function(object, roll)
    DrawTextForDuration("+1 Object ("..object..") Nouveau dé : " .. roll, 1000, 0.4, 0.91, 0, 255, 0)
    CreateOneVol()
end)

RegisterNetEvent("fivem:stopVol")
AddEventHandler("fivem:stopVol", function(methamphetamine)
    volStart = false
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPlayerInZone() then
            if not volStart then
                ShowHelpText("Appuyez sur ~INPUT_CONTEXT~ pour commencer le vol.")
                if IsControlJustPressed(0, actionKeyE) then
                    TriggerServerEvent("fivem:checkStartVol")
                end
            end
        else 
            if volStart then
                ClearPedTasks(PlayerPedId())
            end
        end
    end
end)