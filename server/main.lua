ESX = exports["es_extended"]:getSharedObject()

function SendToDiscord(name, message)
    local DiscordWebhook = Config.GiveCarLogs
    local embeds = {
        {
            ["title"] = name,
            ["description"] = message,
            ["type"] = "rich",
            ["color"] = 255,
            ["footer"] = {
                ["text"] = os.date("JB Scripts - %Y-%m-%d | %H:%M:%S")  
            }
        }
    }
    PerformHttpRequest(DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "JB Scripts", embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand('givecar', function(source, args)
	givevehicle(source, args, 'car')
end)

RegisterCommand('giveplane', function(source, args)
	givevehicle(source, args, 'airplane')
end)

RegisterCommand('giveboat', function(source, args)
	givevehicle(source, args, 'boat')
end)

RegisterCommand('giveheli', function(source, args)
	givevehicle(source, args, 'helicopter')
end)

function givevehicle(_source, _args, vehicleType)
	if havePermission(_source) then
		if _args[1] == nil or _args[2] == nil then
			TriggerClientEvent('ox_lib:notify', _source, { 
				type = 'info', 
				title = '/givevehicle playerID carModel [plate]',
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
		elseif _args[3] ~= nil then
			local playerName = GetPlayerName(_args[1])
			local plate = _args[3]
			if #_args > 3 then
				for i=4, #_args do
					plate = plate.." ".._args[i]
				end
			end	
			plate = string.upper(plate)
			TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', _source, _args[1], _args[2], plate, playerName, 'player', vehicleType)
		else
			local playerName = GetPlayerName(_args[1])
			TriggerClientEvent('esx_giveownedcar:spawnVehicle', _source, _args[1], _args[2], playerName, 'player', vehicleType)
		end
	else
		TriggerClientEvent('ox_lib:notify', _source, { 
			type = 'error', 
			title = 'You don\'t have permission to do this command!',
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

RegisterCommand('delcarplate', function(source, args)
local xPlayer = ESX.GetPlayerFromId(source)
	if havePermission(source) then
		if args[1] == nil then
			TriggerClientEvent('ox_lib:notify', source, { 
				type = 'info', 
				title = '/delcarplate <plate>',
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
		else
			local plate = args[1]
			if #args > 1 then
				for i=2, #args do
					plate = plate.." "..args[i]
				end		
			end
			plate = string.upper(plate)
			
			local result = MySQL.Sync.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
				['@plate'] = plate
			})
			if result == 1 then
				TriggerClientEvent('ox_lib:notify', source, { 
					type = 'success', 
					title = 'Vehicle with plate number '..plate..' has been deleted',
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
				SendToDiscord("VEHICLE DELETED", "**Plate Number:** "..plate.."\n **Deleted by:** " ..xPlayer.name)
			elseif result == 0 then
				TriggerClientEvent('ox_lib:notify', source, { 
					type = 'error', 
					title = 'Vehicle with plate number '..plate..' is not exist',
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
	else
		TriggerClientEvent('ox_lib:notify', source, { 
			type = 'error', 
			title = 'You don\'t have permission to do this command!',
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
end)

RegisterServerEvent('esx_giveownedcar:setVehicle')
AddEventHandler('esx_giveownedcar:setVehicle', function (vehicleProps, playerID, vehicleType)
	local _source = playerID
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps),
		['@stored']  = 1,
		['type'] = vehicleType
	}, function ()
			TriggerClientEvent('ox_lib:notify', _source, { 
				type = 'success', 
				title = 'You received a vehicle with plate number ' ..vehicleProps.plate.. ' check it now in your garage',
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
			SendToDiscord("VEHICLE RECEIVED", "**Plate Number:** "..vehicleProps.plate.."\n **Player Name:** " ..xPlayer.name)
	end)
end)

function havePermission(_source)
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerGroup = xPlayer.getGroup()
	local isAdmin = false
	for k,v in pairs(Config.AuthorizedRanks) do
		if v == playerGroup then
			isAdmin = true
			break
		end
	end
	
	if IsPlayerAceAllowed(_source, "giveownedcar.command") then isAdmin = true end
	
	return isAdmin
end
