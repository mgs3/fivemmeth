local JourneyModel = GetHashKey("journey")
local MethStart = false
local HasMask = nil
local StartBlocked = false
local FirstSpawn = true

local function IsPlayerInZoneAndInJourney()
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) or not IsPedInAnyVehicle(playerPed, false) then return false end
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= JourneyModel then return false end
    if MethStart and GetPlayerSeatId(vehicle) ~= 1 then return false end
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
    MethStart = false
    StopParticule("smoke")
    StopParticule("smoke2")
end

local function CreateOneMeth()
    if not MethStart then return end
    if IsPlayerInZoneAndInJourney() then
        DrawTextAndProgressBar("Création de Méthamphétamine", 2500, 0.4, 0.87, 255, 255, 255, true)
        Wait(2500)
        TriggerServerEvent("fivem:createOneMeth")
    else
        StopMeth()
        TriggerServerEvent("fivem:stopMeth")
    end
end

local function GetClosestMethCoord()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestCoord = nil
    local minDist = math.huge
    for i = 1, #MethCoords do
        local coords = MethCoords[i]
        local dist = #(playerCoords - coords)
        if dist < minDist then
            minDist = dist
            closestCoord = coords
        end
    end
    return closestCoord
end

local function AddGpsPoint(vehicle, seatId)
    
    return true
end

local function OnEnterVehicule(vehicle)
    if StartBlocked or MethStart then return end
    local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= JourneyModel then return false end
    local seatId = GetPlayerSeatId(vehicle)
    if seatId ~= -1 then return false end

    SetDestination(GetClosestMethCoord())
    local playerPed = PlayerPedId()
    while IsPedInAnyVehicle(playerPed, false) and not IsPlayerInZoneAndInJourney() do
        Wait(1000)
    end

    local stopHot = false
    while IsPedInAnyVehicle(playerPed, false) and not stopHot and IsPlayerInZoneAndInJourney() do
        Wait(1)
        if MethStart then
            ShowHelpText("Appuyez sur ~INPUT_ENTER~ pour stopper la création.", 1000, 0)
            if IsControlJustPressed(0, ActionKeyF) then
                ShowHelpText("", 100, 1)
                TriggerServerEvent("fivem:stopMeth")
                return
            end
        elseif seatId == 1 then
            ShowHelpText("Appuyez sur ~INPUT_CONTEXT~ pour créer de la Méthamphétamine.", 1000, 0)
            if IsControlJustPressed(0, ActionKeyE) then
                TriggerServerEvent("fivem:checkStartMeth")
            end
        elseif IsVehicleSeatFree(vehicle, 1) then
            ShowHelpText("Appuyez sur ~INPUT_CONTEXT~ pour vous déplacer vers l'arrière du véhicule.", 1000, 0)
            if IsControlJustPressed(0, ActionKeyE) then
                SetVehicleEngineOn(vehicle, false, false, true)
                TaskWarpPedIntoVehicle(playerPed, vehicle, 1)
                seatId = 1
            end
        end
    end
    ShowHelpText("", 100, 1)
    if MethStart then
        TriggerServerEvent("fivem:stopMeth")
        StopMeth()
    end
    if IsPedInAnyVehicle(playerPed, false) then
        OnEnterVehicule(vehicle)
    end
end

local function Notify(text)
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

local function Respawn()
    local playerPed = PlayerPedId()
    local spawnCoords = vector3(1970.8584, 3896.0298, 33.1999)
    local spawnHeading = 160.0
    local model = GetHashKey("a_m_y_business_01")
    local time = GetGameTimer()

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(500)
    end
    FreezePlayer(PlayerId(), true)

    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    RequestCollisionAtCoord(spawnCoords.x + 4.0, spawnCoords.y, spawnCoords.z)
    SetEntityCoordsNoOffset(playerPed, spawnCoords.x + 4.0, spawnCoords.y, spawnCoords.z, false, false, false)
    NetworkResurrectLocalPlayer(spawnCoords.x + 4.0, spawnCoords.y, spawnCoords.z, spawnHeading, 1, true)
    ClearPedTasksImmediately(playerPed)
    SetEntityHeading(playerPed, spawnHeading)
    ClearPlayerWantedLevel(PlayerId())
    SetWaypointOff()
    SetGpsMultiRouteRender(false)
    
    RequestModel(JourneyModel)
    while not HasModelLoaded(JourneyModel) do
        Wait(10)
    end
    local vehicle = CreateVehicle(JourneyModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, false)
    SetVehicleOnGroundProperly(vehicle)

    while (not HasCollisionLoadedAroundEntity(playerPed) and (GetGameTimer() - time) < 1000) do
        Wait(10)
    end
    ShutdownLoadingScreen()
    if IsScreenFadedOut() then
        DoScreenFadeIn(500)
        while not IsScreenFadedIn() do
            Wait(500)
        end
    end
    FreezePlayer(PlayerId(), false)
end

RegisterNetEvent("fivem:badRollExplose")
AddEventHandler("fivem:badRollExplose", function()
    StartBlocked = true
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
    StartBlocked = false
end)

RegisterNetEvent("fivem:createOneMethSuccess")
AddEventHandler("fivem:createOneMethSuccess", function(methamphetamine, roll)
    DrawTextAndProgressBar("+1 Méthamphétamine ("..methamphetamine..") Nouveau dé : " .. roll, 1000, 0.4, 0.91, 0, 255, false)
    CreateOneMeth()
end)

RegisterNetEvent("fivem:insufficientIngredients")
AddEventHandler("fivem:insufficientIngredients", function(methamphetamine)
    DrawTextAndProgressBar("Pas assez d'ingrédients", 1000, 0.4, 0.91, 255, 0, 0, false)
    StopMeth()
end)

RegisterNetEvent("fivem:endCreateMeth")
AddEventHandler("fivem:endCreateMeth", function(methamphetamine)
    DrawTextAndProgressBar("Fin de création (Methamphetamine : "..methamphetamine..")", 2000, 0.4, 0.91, 255, 255, 255, false)
    StopMeth()
end)

RegisterNetEvent("fivem:stopMeth")
AddEventHandler("fivem:stopMeth", function()
    StopMeth()
end)

RegisterNetEvent("fivem:methStartOk")
AddEventHandler("fivem:methStartOk", function(roll)
    DrawTextAndProgressBar("Lancé de dé : "..roll, 2500, 0.4, 0.91, 255, 255, 255, false)
    MethStart = true
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    PlayParticule("smoke" , "ent_amb_smoke_general", vehicle, -0.6, -2.0, 0.8, 0.0, 0.0, 0.0, 0.4)
    PlayParticule("smoke2" , "exp_grd_bzgas_smoke", vehicle, -0.6, -2.0, 0.8, 0.0, 0.0, 0.0, 0.8)
    CreateOneMeth()
end)

RegisterNetEvent("fivem:applySteamDamage")
AddEventHandler("fivem:applySteamDamage", function(life)
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, life)
end)

RegisterCommand("mask", function()
    local playerPed = PlayerPedId()

    if HasMask then
        PlayEmote()
        DeleteEntity(HasMask)
        HasMask = nil
        SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
        SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1) -- Ne marche pas mais je pense que c'est lié au autre script de CFX
        TriggerServerEvent("fivem:setOffMask")
        Notify("Gasmask ~r~off")
        return
    end

    local model = GetHashKey("p_d_scuba_mask_s")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    PlayEmote()
    HasMask = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(HasMask, playerPed, GetPedBoneIndex(playerPed, 12844), 0, 0.0, 0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
    SetEntityProofs(playerPed, false, false, false, false, false, false, true, true)
    SetPedComponentVariation(PlayerPedId(), 1, 46, 0, 1) -- Ne marche pas mais je pense que c'est lié au autre script de CFX
    TriggerServerEvent("fivem:setOnMask")
    Notify("Gasmask ~g~on")
end, false)

RegisterCommand("respawn", function()
    Respawn()
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and HasMask then
        DeleteEntity(HasMask)
    end
end)

AddEventHandler('gameEventTriggered', function(eventName, data)
    local playerId = data[1]
    if eventName == "CEventNetworkPlayerEnteredVehicle" and playerId == PlayerId() then
        OnEnterVehicule(data[2])
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, true) then return end
    OnEnterVehicule(GetVehiclePedIsIn(playerPed, false))
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not FirstSpawn then return end
    local playerPed = PlayerPedId()
    if not IsEntityDead(playerPed) then return end
    FirstSpawn = true
    Wait(1000)
    Respawn()
end)