ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_gonicoke:receiveCoke')
AddEventHandler('esx_gonicoke:receiveCoke', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem("coca", 1)
end)