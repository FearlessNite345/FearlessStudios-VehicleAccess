function GetDistanceFromVehicleBone(vehicle, boneName, targetPosition)
    -- Ensure the vehicle and bone index are valid
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
        return nil, nil
    end

    -- Get the position of the specified bone relative to the vehicle's position
    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    local bonePosition = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    -- Calculate distance between the bone position and the target position
    if bonePosition then
        return #(bonePosition - targetPosition), bonePosition
    else
        return nil, nil
    end
end

function GetVehiclesWithinDistance(playerPed, maxDistance)
    local playerPosition = GetEntityCoords(playerPed, false)

    -- Get the vehicle pool
    local vehiclePool = GetGamePool('CVehicle')

    local closestVehicle = nil
    local closestDistance = 9999

    -- Iterate through the vehicle pool
    for _, vehicleHandle in ipairs(vehiclePool) do
        -- Check if the vehicle handle is valid
        if DoesEntityExist(vehicleHandle) then
            local vehiclePosition = GetEntityCoords(vehicleHandle, false)
            local distance = #(playerPosition - vehiclePosition)

            -- Add the vehicle to the table if it's within the specified distance
            if distance <= maxDistance then
                if distance < closestDistance then
                    closestDistance = distance
                    closestVehicle = vehicleHandle
                end
            end
        end
    end

    return closestVehicle, closestDistance
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()

        if not IsPedInAnyVehicle(playerPed, true) then
            local plrCoords = GetEntityCoords(playerPed, false)
            local maxDistance = 4.0

            --local closestVehicle, closestDistance = GetVehiclesWithinDistance(playerPed, maxDistance)
            local posped = GetEntityCoords(playerPed, false)
            local entityWorld = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, -5.0)
            local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(posped.x, posped.y, posped.z, entityWorld.x,
                entityWorld.y, entityWorld.z, 10, playerPed, 0)
            local a, b, c, d, closestVehicle = GetShapeTestResult(rayHandle)
            local Distance = #(c - posped)

            if Distance > maxDistance then
                Citizen.Wait(500)
            end

            if closestVehicle ~= 0 then
                local bonnetDist, bonnetCoords = GetDistanceFromVehicleBone(closestVehicle, 'bonnet', plrCoords)
                local bootDist, bootCoords = GetDistanceFromVehicleBone(closestVehicle, 'boot', plrCoords)
                local distWhenClosed = 1.4
                local distWhenOpen = 1.65
                
                if (bonnetDist < bootDist or bootCoords == nil) and bonnetDist < 2 and bonnetCoords ~= nil then
                    local doorState = "Open"
                    local doorIndex = 4

                    if GetVehicleDoorAngleRatio(closestVehicle, doorIndex) > 0.1 then
                        doorState = "Close"
                    else
                        doorState = "Open"
                    end

                    DrawText3D(bonnetCoords.x, bonnetCoords.y, bonnetCoords.z, 0.45,
                        "~w~[~g~" .. GetKeyStringFromKeyID(Config.openKey) .. "~w~] " .. doorState .. " Hood")

                    if IsControlJustReleased(0, Config.openKey) then
                        if doorState == "Close" then
                            SetVehicleDoorShut(closestVehicle, doorIndex, false)
                        else
                            SetVehicleDoorOpen(closestVehicle, doorIndex, false, false)
                        end
                    end
                elseif bootDist < bonnetDist and bootDist < distWhenClosed and bootCoords ~= nil then
                    local doorState = "Open"
                    local doorIndex = 5
                    local dist = distWhenClosed

                    if GetVehicleDoorAngleRatio(closestVehicle, doorIndex) > 0.1 then
                        doorState = "Close"
                        dist = distWhenOpen
                    else
                        doorState = "Open"
                        dist = distWhenClosed
                    end

                    DrawText3D(bootCoords.x, bootCoords.y, bootCoords.z, 0.45,
                        "~w~[~g~" .. GetKeyStringFromKeyID(Config.openKey) .. "~w~] " .. doorState .. " Trunk")

                    if IsControlJustReleased(0, Config.openKey) then
                        if doorState == "Close" then
                            SetVehicleDoorShut(closestVehicle, doorIndex, false)
                        else
                            SetVehicleDoorOpen(closestVehicle, doorIndex, false, false)
                        end
                    end
                end
            end
        end
    end
end)

RegisterCommand("FSVA-OHD", function()
    local playerPed = PlayerPedId()
    local doorIndex = 4

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)

        if GetPedInVehicleSeat(veh, -1) == playerPed then
            if GetVehicleDoorAngleRatio(veh, doorIndex) > 0.1 then
                SetVehicleDoorShut(veh, doorIndex, false)
            else
                SetVehicleDoorOpen(veh, doorIndex, false, false)
            end
        end
    end
end, false)

RegisterCommand("FSVA-TPOP", function()
    local playerPed = PlayerPedId()
    local doorIndex = 5

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)

        if GetPedInVehicleSeat(veh, -1) == playerPed then
            if GetVehicleDoorAngleRatio(veh, doorIndex) > 0.1 then
                SetVehicleDoorShut(veh, doorIndex, false)
            else
                SetVehicleDoorOpen(veh, doorIndex, false, false)
            end
        end
    end
end, false)

RegisterCommand("FSVA-LFRT", function()
    local playerPed = PlayerPedId()
    local doorIndex = 0

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)

        if GetPedInVehicleSeat(veh, -1) == playerPed then
            if GetVehicleDoorAngleRatio(veh, doorIndex) > 0.1 then
                SetVehicleDoorShut(veh, doorIndex, false)
            else
                SetVehicleDoorOpen(veh, doorIndex, false, false)
            end
        end
    end
end, false)

RegisterCommand("FSVA-RFRT", function()
    local playerPed = PlayerPedId()
    local doorIndex = 1

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)

        if GetPedInVehicleSeat(veh, -1) == playerPed then
            if GetVehicleDoorAngleRatio(veh, doorIndex) > 0.1 then
                SetVehicleDoorShut(veh, doorIndex, false)
            else
                SetVehicleDoorOpen(veh, doorIndex, false, false)
            end
        end
    end
end, false)

RegisterCommand("FSVA-LBCK", function()
    local playerPed = PlayerPedId()
    local doorIndex = 2

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)

        if GetPedInVehicleSeat(veh, -1) == playerPed then
            if GetVehicleDoorAngleRatio(veh, doorIndex) > 0.1 then
                SetVehicleDoorShut(veh, doorIndex, false)
            else
                SetVehicleDoorOpen(veh, doorIndex, false, false)
            end
        end
    end
end, false)

RegisterCommand("FSVA-RBCK", function()
    local playerPed = PlayerPedId()
    local doorIndex = 3

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)

        if GetPedInVehicleSeat(veh, -1) == playerPed then
            if GetVehicleDoorAngleRatio(veh, doorIndex) > 0.1 then
                SetVehicleDoorShut(veh, doorIndex, false)
            else
                SetVehicleDoorOpen(veh, doorIndex, false, false)
            end
        end
    end
end, false)
