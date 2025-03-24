VolCoords = {
    vector3(380.0917, 326.6262, 103.5664),
    vector3(1154.5106, -322.1716, 69.2051),
    vector3(1138.0847, -984.4512, 46.4158),
    vector3(31.7155, -1345.2067, 29.4970),
    vector3(-52.8946, -1749.7804, 29.4210),
    vector3(-716.0392, -911.2817, 19.2156),
    vector3(-1221.7832, -904.2063, 12.3263),
    vector3(-1490.2101, -378.4136, 40.1634),
    vector3(-1428.5740, -260.1311, 48.5775), -- Superette uniquement sur RR (morningwood)
    vector3(-1829.0353, 789.2854, 138.2874),
    vector3(-3243.7175, 1007.3864, 12.8307),
    vector3(-3043.1433, 590.8055, 7.9089),
    vector3(-2969.3970, 393.5261, 15.0433),
    vector3(2555.7341, 388.1012, 108.6229),
    vector3(2679.9424, 3286.6494, 55.2411),
    vector3(1163.4899, 2707.4622, 38.1577),
    vector3(542.1309, 2668.4438, 42.1565),
    vector3(-2538.4895, 2309.6846, 35.5238), -- Superette uniquement sur RR (Route 68)
    vector3(1965.5151, 3745.1228, 32.3437),
    vector3(1705.6570, 4929.7974, 42.0637),
    vector3(1735.2678, 6413.8423, 35.0372)
}
VolRadius = 0.5
MethCoords = {
    vector3(1394.7477, 3627.9487, 34.3793)
}
MethRadius = 2

local textData = {}
local fxId = {}

function GetPlayerSeatId(vehicle)
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

function PlayParticule(id, name, entity, x, y, z, rx, ry, rz, s)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while (not HasNamedPtfxAssetLoaded("core")) do
            Wait(100)
        end
    end
    UseParticleFxAssetNextCall("core")
    fxId[id] = StartParticleFxLoopedOnEntity(name, entity, x, y, z, rx, ry, rz, s, false, false, false)
end

function StopParticule(id)
    StopParticleFxLooped(fxId[id], false)
end

function ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, false, false, -1)
end

function DrawProgressBar(time)
    local endTime = GetGameTimer() + time
    while GetGameTimer() < endTime do
        Wait(0)
        DrawRect(0.5, 0.9, 0.2, 0.01, 0, 0, 0, 150)
        local progress = (time - (endTime - GetGameTimer())) / time
        DrawRect(0.4 + (progress * 0.1), 0.9, progress * 0.2, 0.01, 255, 0, 0, 200)
    end
end

function DrawTextForDuration(text, duration, x, y, r, g, b)
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

Citizen.CreateThread(function()
    while true do
        Wait(0)
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