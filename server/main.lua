ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_gonicoke:receiveCoke')
AddEventHandler('esx_gonicoke:receiveCoke', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem("coca", 1)
end)

ESX.RegisterUsableItem('usb', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('usb', 1)
	TriggerClientEvent('esx_gonicoke:startVan', source)
	TriggerClientEvent("esx_gonicoke:entornoPoli", source)
end)

ESX.RegisterUsableItem('coca', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem('bolsa').count >= 20 then
		xPlayer.removeInventoryItem('coca', 1)
		xPlayer.addInventoryItem('bolsacoca', 20)
		xPlayer.removeInventoryItem('bolsa', 20)
		xPlayer.showNotification('~b~Has creado 20~b~ ~w~Bolsas de Coca (10g)~w~')
	else
		xPlayer.showNotification('~b~Necesitas 20~b~ ~w~Bolsas de Plastico~w~ ~b~para poder desempaquetar los fardos~b~')
	end
end)

RegisterServerEvent('esx_gonicoke:entornoPoliPls')
AddEventHandler('esx_gonicoke:entornoPoliPls', function(location, msg, x, y, z, type)
	local _source = source
	--print("Aviso tipo: "..type.." Mandado por: ".._source)
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			POL = xPlayer.source
			local playername = GetPlayerName(_source)
			local ped = GetPlayerPed(_source)
			local mensaje = '^*^4Entorno | Steam Name: ^r' .. playername .. '^*^4 | Reporte: ^rUn camión con droga ha sido localizado'
			local mensajeNotification = '~r~[Entorno] ~w~Reporte: Un camión con droga ha sido localizado'
			
			TriggerClientEvent('esx_gonicoke:setBlip', POL, x, y, z)
			TriggerClientEvent('chatMessage', POL, mensaje)
			TriggerClientEvent('esx:showNotification', POL, mensajeNotification)
		end
	end	
end)