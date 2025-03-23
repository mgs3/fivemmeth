local zoneCoords = vector3(1394.7477, 3627.9487, 34.3793)
local zoneRadius = 2.0
local actionKeyE = 38
local actionKeyF = 23
local journeyModel = GetHashKey("journey")
local methStart = false
local fxId = {}
local textData = {}
local seatId = -1
local mask = nil
local startBlocked = false

local function DrawTextForDuration(text, duration, x, y, r, g, b)
    local id = math.random()
    textData[id] = {
        text = text,
        timer = GetGameTimer() + duration,
        id = id,
        x = x,
        y = y,
        r = r,
        g = g,
        b = b
    }
end

function DrawProgressBar(time)
    local endTime = GetGameTimer() + time
    while GetGameTimer() < endTime do
        Citizen.Wait(0)
        DrawRect(0.5, 0.9, 0.2, 0.01, 0, 0, 0, 150)
        local progress = (time - (endTime - GetGameTimer())) / time
        DrawRect(0.4 + (progress * 0.1), 0.9, progress * 0.2, 0.01, 255, 0, 0, 200)
    end
end

local function GetPlayerSeatId(vehicle)
    local playerPed = PlayerPedId()
    local seatId = -1

    for seatIndex = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 1 do
        if GetPedInVehicleSeat(vehicle, seatIndex) == playerPed then
            seatId = seatIndex
            break
        end
    end

    return seatId
end

local function IsPlayerInZoneAndInJourney()
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) or not IsPedInAnyVehicle(playerPed, false) then
        return false
    end
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehiculeModel = GetEntityModel(vehicle)
    if methStart then
        seatId = GetPlayerSeatId(vehicle)
        return vehiculeModel == journeyModel and seatId == 1 and Vdist(playerCoords.x, playerCoords.y, playerCoords.z, zoneCoords.x, zoneCoords.y, zoneCoords.z) < zoneRadius
    end
    return vehiculeModel == journeyModel and Vdist(playerCoords.x, playerCoords.y, playerCoords.z, zoneCoords.x, zoneCoords.y, zoneCoords.z) < zoneRadius
end

local function StopMeth()
    methStart = false
    StopParticleFxLooped(fxId["smoke"], false)
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

local function PlayParticule(id, name, entity, x, y, z, rx, ry, rz, s)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while (not HasNamedPtfxAssetLoaded("core")) do
            Wait(100)
        end
    end
    UseParticleFxAssetNextCall("core")
    fxId[id] = StartParticleFxLoopedOnEntity(name, entity, x, y, z, rx, ry, rz, s, false, false, false)
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
    Citizen.Wait(5000)
    StopParticleFxLooped(fxId["fire1"], false)
    PlayParticule("fire1", "ent_amb_fbi_fire_dub_door", vehicle,  -0.9, -2.0, 1.0, 90.0, 90.0, 180.0, 3.5)
    Citizen.Wait(2500)
    PlaySoundFromEntity(soundId2, "SPRAY", vehicle, "CARWASH_SOUNDS", true, 0)
    PlayParticule("fire2", "ent_amb_fbi_fire_dub_door", vehicle, 0.0, 2.0, 0.0, 0.0, 45.0, 90.0, 2.5)
    Citizen.Wait(3500)
    local vehicleCoords = GetEntityCoords(vehicle)
    AddExplosion(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 2, 100.0, true, false, 1.0)
    StopParticleFxLooped(fxId["fire1"], false)
    StopParticleFxLooped(fxId["fire2"], false)
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

local function showHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, false, false, -1)
end

local function SetDestination(coords)
    SetNewWaypoint(coords.x, coords.y)
    StartGpsMultiRoute(5, false, true)
    AddPointToGpsMultiRoute(coords.x, coords.y, coords.z)
    SetGpsMultiRouteRender(true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if not startBlocked then
            if not methStart then
                seatId = GetPlayerSeatId(vehicle)
                if IsPlayerInZoneAndInJourney() then
                    if seatId == 1 then
                        showHelpText("Appuyez sur ~INPUT_CONTEXT~ pour créer de la Méthamphétamine.")
                        if IsControlJustPressed(0, actionKeyE) then
                            TriggerServerEvent("fivem:checkStartMeth")
                        end
                    else
                        if IsVehicleSeatFree(vehicle, 1) then
                            showHelpText("Appuyez sur ~INPUT_CONTEXT~ pour vous déplacer vers l'arrière du véhicule.")
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
                showHelpText("Appuyez sur ~INPUT_ENTER~ pour stopper la création.")
                if IsControlJustPressed(0, actionKeyF) then
                    TriggerServerEvent("fivem:stopMeth")
                    StopMeth()
                end
            end
        end

        for _, data in pairs(textData) do
            local currentTime = GetGameTimer()

            if currentTime > data.timer then
                textData[data.id] = nil
            else
                SetTextScale(0.35, 0.35)
                SetTextFont(4)
                SetTextProportional(true)
                SetTextColour(data.r, data.g, data.b, 255)
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextDropShadow()
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(data.text)
                DrawText(data.x, data.y)
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