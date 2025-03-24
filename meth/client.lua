local actionKeyE = 38
local actionKeyF = 23
local journeyModel = GetHashKey("journey")
local methStart = false
local seatId = -1
local mask = nil
local startBlocked = false

local function IsPlayerInZoneAndInJourney()
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) or not IsPedInAnyVehicle(playerPed, false) then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= journeyModel then
        return false
    end
    if methStart then
        local seatId = GetPlayerSeatId(vehicle)
        if seatId ~= 1 then
            return false
        end
    end
    for i = 1, #MethCoords do
        local coords = MethCoords[i]
        local distance = #(playerCoords - coords)
        if distance <= MethRadius then
            return true
        end
    end
    return false
end


local function StopMeth()
    methStart = false
    StopParticule("smoke")
end

local function CreateOneMeth()
    if not methStart then
        return
    end
    if IsPlayerInZoneAndInJourney() then
        DrawTextForDuration("Création de Méthamphétamine", 2500, 0.4, 0.87, 255, 255, 255)
        DrawProgressBar(2500)
        TriggerServerEvent("fivem:createOneMeth")
    else
        StopMeth()
        TriggerServerEvent("fivem:stopMeth")
    end
end

RegisterNetEvent("fivem:badRollExplose")
AddEventHandler("fivem:badRollExplose", function()
    startBlocked = true
    StopMeth()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local soundId = GetSoundId()
    local soundId2 = GetSoundId()
    PlaySoundFromEntity(soundId, "Flare", vehicle, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", true, 0)
    PlayParticule("fire1", "ent_amb_fbi_fire_dub_door", vehicle, -0.9, -2.0, 1.0, 90.0, 90.0, 180.0, 1.5)
    Wait(5000)
    StopParticule("fire1")
    PlayParticule("fire1", "ent_amb_fbi_fire_dub_door", vehicle,  -0.9, -2.0, 1.0, 90.0, 90.0, 180.0, 3.5)
    Wait(2500)
    PlaySoundFromEntity(soundId2, "SPRAY", vehicle, "CARWASH_SOUNDS", true, 0)
    PlayParticule("fire2", "ent_amb_fbi_fire_dub_door", vehicle, 0.0, 2.0, 0.0, 0.0, 45.0, 90.0, 2.5)
    Wait(3500)
    local vehicleCoords = GetEntityCoords(vehicle)
    AddExplosion(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 2, 100.0, true, false, 1.0)
    StopParticule("fire1")
    StopParticule("fire2")
    StopSound(soundId)
    ReleaseSoundId(soundId)
    StopSound(soundId2)
    ReleaseSoundId(soundId2)
    startBlocked = false
end)

RegisterNetEvent("fivem:createOneMethSuccess")
AddEventHandler("fivem:createOneMethSuccess", function(methamphetamine, roll)
    DrawTextForDuration("+1 Méthamphétamine ("..methamphetamine..") Nouveau dé : " .. roll, 1000, 0.4, 0.91, 0, 255, 0)
    CreateOneMeth()
end)

RegisterNetEvent("fivem:insufficientIngredients")
AddEventHandler("fivem:insufficientIngredients", function(methamphetamine)
    DrawTextForDuration("Pas assez d'ingrédients", 1000, 0.4, 0.91, 255, 0, 0)
    StopMeth()
end)

RegisterNetEvent("fivem:endCreateMeth")
AddEventHandler("fivem:endCreateMeth", function(methamphetamine)
    DrawTextForDuration("Fin de création (Methamphetamine : "..methamphetamine..")", 2000, 0.4, 0.91, 255, 255, 255)
    StopMeth()
end)

RegisterNetEvent("fivem:stopMeth")
AddEventHandler("fivem:stopMeth", function()
    StopMeth()
end)

RegisterNetEvent("fivem:methStartOk")
AddEventHandler("fivem:methStartOk", function(roll)
    DrawTextForDuration("Lancé de dé : "..roll, 2500, 0.4, 0.91, 255, 255, 255)
    methStart = true
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    PlayParticule("smoke" , "exp_grd_bzgas_smoke", vehicle, -0.6, -2.0, 0.8, 0.0, 0.0, 0.0, 1.5)
    CreateOneMeth()
end)

RegisterNetEvent("fivem:applySteamDamage")
AddEventHandler("fivem:applySteamDamage", function(life)
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, life)
end)

local function SetDestination(coords)
    SetNewWaypoint(coords.x, coords.y)
    StartGpsMultiRoute(5, false, true)
    AddPointToGpsMultiRoute(coords.x, coords.y, coords.z)
    SetGpsMultiRouteRender(true)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if not startBlocked then
            if not methStart then
                seatId = GetPlayerSeatId(vehicle)
                if IsPlayerInZoneAndInJourney() then
                    if seatId == 1 then
                        ShowHelpText("Appuyez sur ~INPUT_CONTEXT~ pour créer de la Méthamphétamine.")
                        if IsControlJustPressed(0, actionKeyE) then
                            TriggerServerEvent("fivem:checkStartMeth")
                        end
                    else
                        if IsVehicleSeatFree(vehicle, 1) then
                            ShowHelpText("Appuyez sur ~INPUT_CONTEXT~ pour vous déplacer vers l'arrière du véhicule.")
                            if IsControlJustPressed(0, actionKeyE) then
                                SetVehicleEngineOn(vehicle, false, false, true)
                                TaskWarpPedIntoVehicle(playerPed, vehicle, 1)
                            end
                        end
                    end
                else
                    if IsPedInAnyVehicle(playerPed, false) then
                        local vehiculeModel = GetEntityModel(vehicle)
                        if vehiculeModel == journeyModel then
                            local newDestination = vector3(1394.7477, 3627.9487, 34.3793)
                            SetDestination(newDestination)
                        end
                    end
                end
            else
                ShowHelpText("Appuyez sur ~INPUT_ENTER~ pour stopper la création.")
                if IsControlJustPressed(0, actionKeyF) then
                    TriggerServerEvent("fivem:stopMeth")
                    StopMeth()
                end
            end
        end
    end
end)

local function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local function PlayEmote()
    local playerped = GetPlayerPed(-1)
    RequestAnimDict('mp_masks@standard_car@ds@')
    TaskPlayAnim(playerped, 'mp_masks@standard_car@ds@', 'put_on_mask', 8.0, 8.0, 800, 16, 0, false, false, false)
    Wait(800)
end

RegisterCommand("mask", function()
    local playerPed = PlayerPedId()

    if mask then
        PlayEmote()
        DeleteEntity(mask)
        mask = nil
        SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
        SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1) -- Ne marche pas mais je pense que c'est lié au autre script de CFX
        TriggerServerEvent("fivem:setOffMask")
        notify("Gasmask ~r~off")
        return
    end

    local model = GetHashKey("p_d_scuba_mask_s")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    PlayEmote()
    mask = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(mask, playerPed, GetPedBoneIndex(playerPed, 12844), 0, 0.0, 0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
    SetEntityProofs(playerPed, false, false, false, false, false, false, true, true)
    SetPedComponentVariation(PlayerPedId(), 1, 46, 0, 1) -- Ne marche pas mais je pense que c'est lié au autre script de CFX
    TriggerServerEvent("fivem:setOnMask")
    notify("Gasmask ~g~on")
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if mask then
            DeleteEntity(mask)
        end
    end
end)