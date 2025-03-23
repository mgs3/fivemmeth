local vehicleModel = "journey"
local spawnCoords = vector3(1970.8584, 3896.0298, 33.1999)
local spawnHeading = 160.0
local playerPed = PlayerPedId()
local tpCoords = vector3(spawnCoords.x + 4.0, spawnCoords.y, spawnCoords.z)

SetEntityCoords(playerPed, tpCoords.x, tpCoords.y, tpCoords.z, false, false, false, false)
SetEntityHeading(playerPed, spawnHeading)
SetWaypointOff()
SetGpsMultiRouteRender(false)

RequestModel(vehicleModel)
while not HasModelLoaded(vehicleModel) do
    Wait(100)
end

local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, false)
SetVehicleOnGroundProperly(vehicle)