local QBCore = exports['qb-core']:GetCoreObject()

local bmxID = 1131912276



local models = {
    `cruiser`,
   `scorcher`,
   `fixter`,
   `tribike`,
   `tribike2`,
   `tribike3`,
}

local bmxmo = {
    `bmx`,
}

exports['qb-target']:AddTargetModel(models, {
    options = {
        {
            type = "event",
            event = "pickup:bike",
            icon = "fas fa-bicycle",
            label = "Pickup Bike",
        },
	},
	distance = 2.0,
})

exports['qb-target']:AddTargetModel(bmxmo, {
    options = {
		{
		    type = 'event',
			event = 'fetchBMX',
			icon = "fa fa-bicycle",
			label = "Pickup Bike",
		},
	},
	distance = 2.0,
})

RegisterNetEvent('pickup:bike')
AddEventHandler('pickup:bike', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)
    local bone = GetPedBoneIndex(PlayerPed)
    local bike = false

    if GetEntityModel(vehicle) == [[GetHashKey("bmx")]] or GetEntityModel(vehicle) == GetHashKey("scorcher") or GetEntityModel(vehicle) == GetHashKey("cruiser") or GetEntityModel(vehicle) == GetHashKey("fixter") or GetEntityModel(vehicle) == GetHashKey("tribike") or GetEntityModel(vehicle) == GetHashKey("tribike2") or GetEntityModel(vehicle) == GetHashKey("tribike3") then

    AttachEntityToEntity(vehicle, playerPed, bone,0.0, 0.24, 0.10, 340.0, 330.0, 330.0, true, true, false, true, 1, true)
   

    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do Citizen.Wait(0) end
    TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 2.0, 2.0, 50000000, 51, 0, false, false, false)
    bike = true 
	
    RegisterCommand('dropbike', function()
        if IsEntityAttached(vehicle) then
        DetachEntity(vehicle, nil, nil)
        SetVehicleOnGroundProperly(vehicle)
        ClearPedTasksImmediately(playerPed)
        bike = false
        end
    end, false)

        RegisterKeyMapping('dropbike', 'Drop Bike', 'keyboard', 'e')

                Citizen.CreateThread(function()
                while true do
                Citizen.Wait(0)
                if bike and IsEntityPlayingAnim(playerPed, "anim@heists@box_carry@", "idle", 3) ~= 1 then
                    RequestAnimDict("anim@heists@box_carry@")
                    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do Citizen.Wait(0) end
                    TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 2.0, 2.0, 50000000, 51, 0, false, false, false)
                    if not IsEntityAttachedToEntity(playerPed, vehicle) then
                        bike = false
                        ClearPedTasksImmediately(playerPed)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('pickup:bmx', function(bmxitem, prim, sec, perl, plate)
    local src = source
    [[local Player = QBCore.Functions.GetPlayer(src)]]
    local bmx = {}
    if bmxitem == "bmx" then
        bmx.prim = prim
        bmx.sec = sec
        bmx.perl = perl
        bmx.plate = plate
    end
end)

RegisterNetEvent('placeBike', function(prim,sec,perl,plate)
    local playerPed = PlayerPedId()
    local forward = GetEntityForwardVector(playerPed)
    local coords = GetEntityCoords(playerPed) + forward * 1
    RequestAnimDict('anim@mp_snowball')
    TaskPlayAnim(playerPed, 'anim@mp_snowball', 'pickup_snowball', 8.0, 8.0, -1, 48, 1, false, false, false)
    Wait(1000)
    while not HasModelLoaded(bmxID) do
        RequestModel(bmxID)
        Citizen.Wait(10)
    end

    if HasModelLoaded(bmxID) then
        local createdbmx = CreateVehicle(bmxID, coords, 1.0, true, true)
        if createdbmx ~= 0 then
            SetVehicleColours(createdbmx, prim, sec)
            SetVehicleExtraColours(createdbmx, perl, 0)
            SetEntityHeading(createdbmx, GetEntityHeading(playerPed))
            OnBack = true
            lastbike = nil
        end
    end
end)

RegisterNetEvent('fetchBMX', function()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local bmxEntity, closestDistance = QBCore.Functions.GetClosestVehicle(playerCoords)
    
        if bmxEntity ~= nil then
            local bmxModel = GetEntityModel(bmxEntity)
            local hasItem = QBCore.Functions.HasItem('bmx')
            if not hasItem then
                if bmxModel == bmxID then 
                    local colorPrimary, colorSecondary = GetVehicleColours(bmxEntity)
                    local perl, wheel = GetVehicleExtraColours(bmxEntity)
                    local plate = GetVehicleNumberPlateText(bmxEntity)
                    NetworkRequestControlOfEntity(bmxEntity)
                    RequestAnimDict('anim@mp_snowball')
                    TaskPlayAnim(playerPed, 'anim@mp_snowball', 'pickup_snowball', 8.0, 8.0, -1, 48, 1, false, false, false)
                    Wait(1000)
                    --DeleteEntity(bmxEntity)
                    AttachEntityToEntity(bmxEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24818), 0.08, -0.25, 0.0, 10.0, 10.0, 90.0, false, false, false, false, 2, true)
                    TriggerServerEvent('QBCore:Server:AddItem', "bmx", 1)
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["bmx"], "add")
                    OnBack = true
                    while OnBack do
                        Wait(10)
                        local hasItem = QBCore.Functions.HasItem('bmx')
                        if not hasItem then
                            OnBack = false
                        end
                    end
                    lastbike = bmxEntity
                    DeleteEntity(bmxEntity)
                end
            else
                QBCore.Functions.Notify('You already have a bike on you.', 'error', 5000)
            end
        end
    end)
