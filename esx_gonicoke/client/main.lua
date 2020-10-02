ESX = nil
local PlayerData = {}
local randomJobZone = 0
local cokeCar = nil
local gangPed = {}
gangPed.peds = {}
local cokeCarBlip = {}
local cokeDeliverBlip = {}
local working = false
local spawnAll = false
local delivering = false
local collecting = false
local can = false
local cokeRecolected = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	PlayerData = ESX.GetPlayerData()

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

RegisterNetEvent('esx_gonicoke:startVan')
AddEventHandler('esx_gonicoke:startVan', function()
	if working == true then
		RemoveBlip(cokeCarBlip)
		working = false
	end
	if delivering == true then
		RemoveBlip(cokeDeliverBlip)
		delivering = false
	end
	randomJobZone = math.random(0, 2)
	createMissionBlip()
	ESX.ShowHelpNotification('~b~Ve a buscar el furgon con la coca~b~')
	working = true
	spawnAll = true
	triggerServer = false
	collecting = false
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if GetEntityHealth(PlayerPedId(-1)) <= 0 then
			if working == true then
				RemoveBlip(cokeCarBlip)
			end
			if delivering == true then
				RemoveBlip(cokeDeliverBlip)
			end
			working = false
			delivering = false
			spawnAll = false
			collecting = false
		end
		if delivering == true then
			DrawMarker(1, Config.DeliverZone.x, Config.DeliverZone.y, Config.DeliverZone.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 255, 255, 0, 80, false, true, 2, nil, nil, false)
		end
		if collecting == true then
			DrawMarker(1, GetEntityCoords(cokeCar).x, GetEntityCoords(cokeCar).y+2, GetEntityCoords(cokeCar).z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 255, 0, 80, false, true, 2, nil, nil, false)
		end
		if cokeRecolected <= 0 and can then
			collecting = false
			working = false
			delivering = false
			spawnAll = false
			ESX.ShowHelpNotification("~b~Has recogido toda la coca~b~")
			can = false
		end
		spawnCarNPCs()
		insideCokeCar()
		if collecting == true and GetDistanceBetweenCoords(GetEntityCoords(cokeCar).x, GetEntityCoords(cokeCar).y+2, GetEntityCoords(cokeCar).z, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, false) < 3 and cokeRecolected > 0 then
			ESX.ShowHelpNotification("~b~Presiona ~INPUT_CONTEXT~ para recoger la coca~b~")
			if IsControlJustPressed(0, 54) then
				cokeRecolected = cokeRecolected-1
				FreezeEntityPosition(PlayerPedId(-1), true)
				TaskStartScenarioInPlace(PlayerPedId(-1), "PROP_HUMAN_BUM_BIN", 0, true)
				Citizen.Wait(3000)
				TaskStartScenarioInPlace(PlayerPedId(-1), "PROP_HUMAN_BUM_BIN", 0, false)
				Citizen.Wait(3000)
				FreezeEntityPosition(PlayerPedId(-1), false)
				ClearPedTasksImmediately(PlayerPedId(-1))
				TriggerServerEvent('esx_gonicoke:receiveCoke')
				can = true
			end
		end
	end
end)

function insideCokeCar()
	if GetDistanceBetweenCoords(Config.DeliverZone.x, Config.DeliverZone.y, Config.DeliverZone.z, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, false) < 3 and working == true and delivering == true then
		RemoveBlip(cokeDeliverBlip)
		SetVehicleDoorOpen(cokeCar, 2, false, true)
		SetVehicleDoorOpen(cokeCar, 3, false, true)
		SetVehicleEngineOn(cokeCar, false, true, true)
		SetEntityHeading(cokeCar, 180.0)
		SetVehicleForwardSpeed(cokeCar, 0)
		createCokeBlocks()
		cokeRecolected = math.random(Config.CokeColletion.from, Config.CokeColletion.to)
		
		working = false
		delivering = false
		spawnAll = false
		collecting = true
	end
	if working == true and IsPedInVehicle(PlayerPedId(-1), cokeCar, true) and delivering == false then
		RemoveBlip(cokeCarBlip)
		createDeliverBlip()
		delivering = true
	end
end

function spawnCarNPCs()
	if GetDistanceBetweenCoords(Config.CarSpawnZones[randomJobZone].x, Config.CarSpawnZones[randomJobZone].y, Config.CarSpawnZones[randomJobZone].z, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, false) < 300 and working == true and spawnAll == true then
		local cokeCarHash = GetHashKey('Burrito4')
		RequestModel(cokeCarHash)
		while not HasModelLoaded(cokeCarHash) do
			RequestModel(cokeCarHash)
			Citizen.Wait(0)
		end
		cokeCar = CreateVehicle(cokeCarHash, Config.CarSpawnZones[randomJobZone].x, Config.CarSpawnZones[randomJobZone].y, Config.CarSpawnZones[randomJobZone].z, Config.CarSpawnZones[randomJobZone].heading, true, false)
		SetEntityAsMissionEntity(cokeCar, true, true)

		RequestModel(GetHashKey( "g_m_y_lost_01"))
		while not HasModelLoaded(GetHashKey("g_m_y_lost_01")) do
			Citizen.Wait(1)
		end

		AddRelationshipGroup("gangGroup")
		Citizen.Wait(0)
		for i, v in pairs(Config.SpawnZones[randomJobZone]) do
			gangPed.peds[i] = CreatePed(4, 'g_m_y_lost_01', v.x, v.y, v.z, v.heading, true, false)
			GiveDelayedWeaponToPed(gangPed.peds[i], 'WEAPON_ASSAULTRIFLE', 1000, false)
			SetPedArmour(gangPed.peds[i], 100)
			SetPedCombatRange(gangPed.peds[i], 2)
			SetPedCombatMovement(gangPed.peds[i], 0)
			SetPedShootRate(gangPed.peds[i], 500)
			SetPedCombatAbility(gangPed.peds[i], 2)
			SetPedCombatAttributes(gangPed.peds[i], 46, true)
			SetPedCombatAttributes(gangPed.peds[i], 0, true)
			SetPedAccuracy(gangPed.peds[i], 100)
			TaskCombatPed(gangPed.peds[i], PlayerPedId(-1), 0, 16)
			SetModelAsNoLongerNeeded(gangPed.peds[i])
			SetPedDropsWeaponsWhenDead(gangPed.peds[i], false)
			SetPedRelationshipGroupHash(gangPed.peds[i], GetHashKey("gangGroup"))
		end
		spawnAll = false
	end
end

function createMissionBlip()
	cokeCarBlip = AddBlipForCoord(Config.CarSpawnZones[randomJobZone].x, Config.CarSpawnZones[randomJobZone].y, Config.CarSpawnZones[randomJobZone].z)
	SetBlipSprite(cokeCarBlip, 1)
    SetBlipDisplay(cokeCarBlip, 10)
	SetBlipScale(cokeCarBlip, 1.0)
	SetBlipRoute(cokeCarBlip, true)
	SetBlipColour(cokeCarBlip, 5)
end

function createDeliverBlip()
	cokeDeliverBlip = AddBlipForCoord(Config.DeliverZone.x, Config.DeliverZone.y, Config.DeliverZone.z)
	SetBlipSprite(cokeDeliverBlip, 1)
    SetBlipDisplay(cokeDeliverBlip, 10)
	SetBlipScale(cokeDeliverBlip, 1.0)
	SetBlipRoute(cokeDeliverBlip, true)
	SetBlipColour(cokeDeliverBlip, 5)
end

function createCokeBlocks()
	local model = GetHashKey("prop_coke_block_01")
	RequestModel(model)
	while (not HasModelLoaded(model)) do
		Wait(1)
	end
	for i=1,5 do
		for j=1, 5 do
			for k=1, 5 do
				local obj = CreateObject(model, GetEntityCoords(cokeCar).x-1+(j/5), GetEntityCoords(cokeCar).y+3.5+(i/5), GetEntityCoords(cokeCar).z-0.9+(k/8), true, false, true)
    			SetModelAsNoLongerNeeded(model)
				SetEntityAsMissionEntity(obj)
			end
		end
	end
	
end

RegisterNetEvent("esx_gonicoke:entornoPoli")
AddEventHandler("esx_gonicoke:entornoPoli", function(source, args) 
	local name = GetPlayerName(PlayerId())
    local ped = GetPlayerPed(PlayerId())
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local street = GetStreetNameAtCoord(x, y, z)
    local location = GetStreetNameFromHashKey(street)
	TriggerEvent('chatMessage', '', {255,255,255}, '^8 La policía también ha recibido un chivatazo date prisa!')
	TriggerServerEvent('esx_gonicoke:entornoPoliPls', location, msg, x, y, z, tipo)
end)

RegisterNetEvent('esx_gonicoke:setBlip')
AddEventHandler('esx_gonicoke:setBlip', function(x, y, z)
	loadESX()
	local blip = AddBlipForCoord(Config.CarSpawnZones[randomJobZone].x, Config.CarSpawnZones[randomJobZone].y, Config.CarSpawnZones[randomJobZone].z)
	SetBlipSprite(blip, 4)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 1)
	SetBlipDisplay(blip, 10)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Aviso')
	EndTextCommandSetBlipName(blip)
	Wait(displayTime * 1000)
	RemoveBlip(blip)
end)

function loadESX()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(0)
	end
end