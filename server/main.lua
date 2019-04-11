ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

TriggerEvent('es:addGroupCommand', 'openinventory', "admin", function(source, args, user)
	if args[1] then
		local xPlayer = ESX.GetPlayerFromId(args[1])

		if xPlayer then
			TriggerClientEvent("esx_inventoryhud:openPlayerInventory", source, xPlayer)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, _U('player_not_online'))
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, _U('id_not_number'))
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, _U('no_permission'))
end)