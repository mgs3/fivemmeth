local VolStart = false

local function IsPlayerInZone()
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) or IsPedInAnyVehicle(playerPed, false) then
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

local function PlayAnimationVol()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") do
        Wait(10)
    end
    TaskPlayAnim(playerPed, "anim@heists@ornate_bank@grab_cash", "grab", 8.0, -8.0, 3000, 49, 0, false, false, false)
end

local function CreateOneVol()
    if not VolStart then
        return
    end
    if IsPlayerInZone() then
        PlayAnimationVol()
        DrawTextForDuration("Vol en cours...", 2500, 0.4, 0.87, 255, 255, 255)
        DrawProgressBar(3000)
        TriggerServerEvent("fivem:createOneVol")
    else
        VolStart = false
        TriggerServerEvent("fivem:stopVol")
    end
end

RegisterNetEvent("fivem:volStartOk")
AddEventHandler("fivem:volStartOk", function(roll)
    DrawTextForDuration("Lancé de dé : "..roll, 2500, 0.4, 0.91, 255, 255, 255)
    VolStart = true
    CreateOneVol()
end)

RegisterNetEvent("fivem:createOneVolSuccess")
AddEventHandler("fivem:createOneVolSuccess", function(object, roll)
    DrawTextForDuration("+1 Object ("..object..") Nouveau dé : " .. roll, 1000, 0.4, 0.91, 0, 255, 0)
    CreateOneVol()
end)

RegisterNetEvent("fivem:stopVol")
AddEventHandler("fivem:stopVol", function(methamphetamine)
    VolStart = false
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsPlayerInZone() then
            if not VolStart then
                ShowHelpText("Appuyez sur ~INPUT_CONTEXT~ pour commencer le vol.", 100, 0)
                if IsControlJustPressed(0, ActionKeyE) then
                    TriggerServerEvent("fivem:checkStartVol")
                end
            end
        else 
            if VolStart then
                ClearPedTasks(PlayerPedId())
            end
        end
    end
end)