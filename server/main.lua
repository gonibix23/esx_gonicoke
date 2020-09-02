ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_gonicoke:receiveCoke')
AddEventHandler('esx_gonicoke:receiveCoke', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem("coca", 1)
end)

ESX.RegisterUsableItem('usb', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_gonicoke:startVan', source)
	xPlayer.removeInventoryItem('usb', 1)
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