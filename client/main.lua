ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx_giveownedcar:spawnVehicle')
AddEventHandler('esx_giveownedcar:spawnVehicle', function(playerID, model, playerName, type, vehicleType)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local carExist  = false

	ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) --get vehicle info
		if DoesEntityExist(vehicle) then
			carExist = true
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local newPlate     = exports.esx_vehicleshop:GeneratePlate()
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = newPlate
			TriggerServerEvent('esx_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
			ESX.Game.DeleteVehicle(vehicle)	
			if type ~= 'console' then
				lib.notify({
					title = 'Vehicle '..model..' with plate number '..newPlate..' has been park into ' ..playerName.. ' garage',
					type = 'success',
					duration = 15000,
					position = 'center-right',
					style = {
						backgroundColor = '#1C1C1C',
						color = '#C1C2C5',
						borderRadius = '8px',
						['.description'] = {
							fontSize = '16px',
							color = '#B0B3B8'
						},
					},
				})
			end				
		end		
	end)
	
	Wait(2000)
	if not carExist then
		if type ~= 'console' then
			lib.notify({
				title = 'This vehicle '..model..' is not exist',
				type = 'error',
				duration = 5000,
				position = 'center-right',
				style = {
					backgroundColor = '#1C1C1C',
					color = '#C1C2C5',
					borderRadius = '8px',
					['.description'] = {
						fontSize = '16px',
						color = '#B0B3B8'
					},
				},
			})
		end
	end
end)

RegisterNetEvent('esx_giveownedcar:spawnVehiclePlate')
AddEventHandler('esx_giveownedcar:spawnVehiclePlate', function(playerID, model, plate, playerName, type, vehicleType)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local generatedPlate = string.upper(plate)
	local carExist  = false

	ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function (isPlateTaken)
		if not isPlateTaken then
			ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) --get vehicle info	
				if DoesEntityExist(vehicle) then
					carExist = true
					SetEntityVisible(vehicle, false, false)
					SetEntityCollision(vehicle, false)	
					
					local newPlate     = string.upper(plate)
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					vehicleProps.plate = newPlate
					TriggerServerEvent('esx_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
					ESX.Game.DeleteVehicle(vehicle)
					if type ~= 'console' then
						ESX.ShowNotification(_U('gived_car',  model, newPlate, playerName))
					end				
				end
			end)
		else
			carExist = true
			if type ~= 'console' then
				lib.notify({
					title = 'This plate is already been used on another vehicle',
					type = 'error',
					duration = 5000,
					position = 'center-right',
					style = {
						backgroundColor = '#1C1C1C',
						color = '#C1C2C5',
						borderRadius = '8px',
						['.description'] = {
							fontSize = '16px',
							color = '#B0B3B8'
						},
					},
				})
			end					
		end
	end, generatedPlate)
	
	Wait(2000)
	if not carExist then
		if type ~= 'console' then
			lib.notify({
				title = 'This vehicle '..model..' is not exist',
				type = 'error',
				duration = 5000,
				position = 'center-right',
				style = {
					backgroundColor = '#1C1C1C',
					color = '#C1C2C5',
					borderRadius = '8px',
					['.description'] = {
						fontSize = '16px',
						color = '#B0B3B8'
					},
				},
			})
		end		
	end	
end)