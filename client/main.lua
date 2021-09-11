-- LICENSE
-- MIT License

-- Copyright (c) 2021 thibaultDup

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- END LICENSE


ESX = nil
localVehicles = {}
localGarages = {}
isInDelivery = false --{5}
playerId = nil



--TEST - gameEvents --------------------------------

-- RegisterNetEvent('onResourceStart')
-- AddEventHandler('onResourceStart', function(resource)
	-- print("RESOURCE STARTED !!!!!")
-- end)

--Fin TEST


--Events -------------------------------------------------------------------------------------------------

--Event to get the return of the Event server [ esx_bringIt:GetPersonalCar ]
RegisterNetEvent("esx_bringIt:GetPersonalCar:return")
AddEventHandler("esx_bringIt:GetPersonalCar:return", function(vehicles)

	localVehicles = vehicles
	
end)

--Event to get the return of the Event server [ esx_bringIt:GetPersonalCarInGarage ]
RegisterNetEvent("esx_bringIt:GetPersonalCarInGarage:return")
AddEventHandler("esx_bringIt:GetPersonalCarInGarage:return", function(vehicles)

	localVehicles = vehicles
	
end)

--Event to get the return of the Event server [ esx_bringIt:GetPersonalGarage ]
RegisterNetEvent("esx_bringIt:GetPersonalGarage:return")
AddEventHandler("esx_bringIt:GetPersonalGarage:return", function(garages)

	localGarages = garages

end)

--Event called by our server script when a player emmits a call (via gcphone) to 505505 or 505-505 numbers wich will start the script core by calling our [ main() ] function {7}
RegisterNetEvent("esx_bringIt:MechanoCalled")
AddEventHandler("esx_bringIt:MechanoCalled", function()
	
	-- --Sends an NUIMessage to our [ closephone.js ] wich in turn will trigger an NUIcallback from gcphone to close the phone
	-- SendNUIMessage({action = 'close'})
	--Set the focus to the NUI menu of our script, focus wich is normaly on the gcphone NUI script. To allow player to interact with our mechano menu while the phone is still out.
	--SetNuiFocus(true, true)
	playerId = PlayerPedId()
	Citizen.Wait(2000)
	
	main()
	
	Citizen.Wait(1000)
	
	-- Trigger the Event we add to the [ gcphone/client/client.lua ] wich close the phone after our Menu is displayed
	TriggerEvent("gcPhone:closeThePhone")

end)


--Fin Events -------------------------------------------------------------------------------------------------


--Thread[0] Wait to GET the ESX Object -------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()

    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
	
end)
--Fin Thread[0] -------------------------------------------------------------------------------------------------


--Thread[1] Main Thread -------------------------------------------------------------------------------------------------
-- Citizen.CreateThread(function()
	
	-- Citizen.Wait(100)
	
	-- displayMenu()
	
	-- --TEST
	
	-- --playerCoordsTest = GetEntityCoords(PlayerPedId())
	
	-- --print(LookForCoordsNearPlayer(playerCoordsTest))
	-- --Fin TEST
	

-- end)
--Fin Thread[1] -------------------------------------------------------------------------------------------------




--Functions -------------------------------------------------------------------------------------------------

--Our main function wich is called by our event [ MechanoCalled ]. This function will launch the script by displaying the menu {7}
function main()

	Citizen.Wait(100)
	
	displayMenu()


end



--Function that will display a menu wich includes all the player's car
function displayMenu()

	Citizen.Wait(100)
	
	-- --Trigger the server Event that fetch all the parked car of the player in is garages
	-- TriggerServerEvent("esx_bringIt:GetPersonalCar")
	
	--TABLE that will contain our menu items
	local menuItems = {}
	--Temp var to add garages to the list
	local garage = ""
	
	--For all the garages in [ esx_garage/config.lua ]
	for k,v in pairs(Config.Garages) do
	
		--IsClosed mean Open weirdly
		if (v.IsClosed) then
			
			table.insert(menuItems, { ["label"] = k, ["value"] = k })
	
		end
		
	end
	
	--[TO MOVE] Get the coords of the player to later spawn the car beside him
	--playerCoords = GetEntityCoords(PlayerPedId())
	playerCoords = GetEntityCoords(playerId)
	print(playerCoords)
	--Call the function that search for a road behind the player to spawn the vehicle and return the coords of the spwan point
	spawnVehicleCoords = LookForCoordsNearPlayer(playerCoords)
	
	--TEST
	--print(spawnVehicleCoords)
	
	--If the [ LookForCoordsNearPlayer() ] doesn't found any coords on road near the player
	if( spawnVehicleCoords == nil ) then
	
		ESX.ShowAdvancedNotification("Mechano", "~b~BringIt" ,"~r~I can't get to you know, try a little later !", "CHAR_MECHANIC")
		return 
		
	end
	
	-- If variable [ isInDelivery ] is true, that means that the mechano is already in delivery so he isn't reachable {5}
	if( isInDelivery == true ) then
	
		ESX.ShowAdvancedNotification("Mechano", "~b~BringIt" ,"~r~I'm already driving a car to you, I cannot duplicate myself !!!", "CHAR_MECHANIC")
		return 
		
	end
	
	--Close all eventual menu
	ESX.UI.Menu.CloseAll()
	
	--Open the Menu [ bringItGarages ]
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItGarages',
			{
				title    = "Your garages",
				align    = 'top-left',
				elements = menuItems
			},
			
	function(data, menu)
		
		local action = data.current.value
		
		if (action == "MiltonDrive") then
			
			print("PRESSED")
			subMenuItems = {}
			
			--Used to load the global variable [ localVehicle ] with the cars that are in the garage passed in arg1
			getCarInGarage("MiltonDrive")
			
			--TEST
			--If the garage is empty no need to add ITEMS and Open the [ bringItCars ] so we close the parent menu and return
			if( localVehicles[1] == nil ) then
			
				--print("EMPTY !!")
				--ShowNotification : No cars parked in this garage
				ESX.ShowNotification("~r~No cars in this garage", true, false, 140)
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
				--TEST -----------
				--return
				
			else
				--Add entries to the UI Sub Menu [ bringItCars ]
				--For each vehicle in the player's garage
				for i, field in ipairs(localVehicles) do
				
						
						for k, vehicleData in pairs(field.vehicle) do

							if (k == "model") then
								--Add the car to the subMenuCar for this Garage
								table.insert(subMenuItems, { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData)), ["value"] = i })
								--elements[i] = { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData.model)), ["value"] = field.id }
								
							end
							
						end
						
				
				end
			end
			--Fin TEST
			
			--Close the parent Menu if open
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
			
			--Open the sub menu
			print("OPEN SUBMENU HERE")
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItCars',
			{
				title    = "Your cars in MiltonDrive",
				align    = 'top-left',
				elements = subMenuItems
			},
			
			function(data, menu)
			
				vehicleIndex = data.current.value
				
				--Close the child menu
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
		
				Citizen.Wait(500)
		
				--Call the function to spawn the vehicle et delete him from the garage
				spawnVehicle(vehicleIndex)
				
			end, function(data, menu)
				 menu.close()
			end)



			
		elseif (action == "IntegrityWay") then
			
			print("PRESSED")
			subMenuItems = {}
			
			--Used to load the global variable [ localVehicle ] with the cars that are in the garage passed in arg1
			getCarInGarage("IntegrityWay")
			
			--TEST
			--If the garage is empty no need to add ITEMS and Open the [ bringItCars ] so we close the parent menu and return
			if( localVehicles[1] == nil ) then
			
				--print("EMPTY !!")
				--ShowNotification : No cars parked in this garage
				ESX.ShowNotification("~r~No cars in this garage", true, false, 140)
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
				return
				
			else
				--Add entries to the UI Sub Menu [ bringItCars ]
				--For each vehicle in the player's garage
				for i, field in ipairs(localVehicles) do
				
						
						for k, vehicleData in pairs(field.vehicle) do

							if (k == "model") then
								--Add the car to the subMenuCar for this Garage
								table.insert(subMenuItems, { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData)), ["value"] = i })
								--elements[i] = { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData.model)), ["value"] = field.id }
								
							end
							
						end
						
				
				end
			end
			--Fin TEST
			
			--Close the parent Menu if open
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
			
			--Open the sub menu
			print("OPEN SUBMENU HERE")
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItCars',
			{
				title    = "Your cars in IntegrityWay",
				align    = 'top-left',
				elements = subMenuItems
			},
			
			function(data, menu)
			
				vehicleIndex = data.current.value
				
				--Close the child menu
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
		
				Citizen.Wait(500)
		
				--Call the function to spawn the vehicle et delete him from the garage
				spawnVehicle(vehicleIndex)
				
			end, function(data, menu)
				 menu.close()
			end)



			
		elseif (action == "DidionWay") then
		
	
			
			print("PRESSED")
			subMenuItems = {}
			
			--Used to load the global variable [ localVehicle ] with the cars that are in the garage passed in arg1
			getCarInGarage("DidionWay")
			
			--TEST
			--If the garage is empty no need to add ITEMS and Open the [ bringItCars ] so we close the parent menu and return
			if( localVehicles[1] == nil ) then
			
				--print("EMPTY !!")
				--ShowNotification : No cars parked in this garage
				ESX.ShowNotification("~r~No cars in this garage", true, false, 140)
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
				return
				
			else
				--Add entries to the UI Sub Menu [ bringItCars ]
				--For each vehicle in the player's garage
				for i, field in ipairs(localVehicles) do
				
						
						for k, vehicleData in pairs(field.vehicle) do

							if (k == "model") then
								--Add the car to the subMenuCar for this Garage
								table.insert(subMenuItems, { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData)), ["value"] = i })
								--elements[i] = { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData.model)), ["value"] = field.id }
								
							end
							
						end
						
				
				end
				
			end
			--Fin TEST
			
			--Close the parent Menu if open
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
			
			--Open the sub menu
			print("OPEN SUBMENU HERE")
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItCars',
			{
				title    = "Your cars in DidionWay",
				align    = 'top-left',
				elements = subMenuItems
			},
			
			function(data, menu)
			
				vehicleIndex = data.current.value
				
				--Close the child menu
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
		
				Citizen.Wait(500)
		
				--Call the function to spawn the vehicle et delete him from the garage
				spawnVehicle(vehicleIndex)
				
			end, function(data, menu)
				 menu.close()
			end)
			
			
			
			
		elseif (action == "VinewoodEstate2650") then
		
			
			--print("PRESSED")
			subMenuItems = {}
			
			--Used to load the global variable [ localVehicle ] with the cars that are in the garage passed in arg1
			getCarInGarage("VinewoodEstate2650")
			
			--TEST
			--If the garage is empty no need to add ITEMS and Open the [ bringItCars ] so we close the parent menu and return
			if( localVehicles[1] == nil ) then
			
				--print("EMPTY !!")
				--ShowNotification : No cars parked in this garage
				ESX.ShowNotification("~r~No cars in this garage", true, false, 140)
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
				return
				
			else
				--Add entries to the UI Sub Menu [ bringItCars ]
				--For each vehicle in the player's garage
				for i, field in ipairs(localVehicles) do
				
						
						for k, vehicleData in pairs(field.vehicle) do

							if (k == "model") then
								--Add the car to the subMenuCar for this Garage
								table.insert(subMenuItems, { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData)), ["value"] = i })
								--elements[i] = { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData.model)), ["value"] = field.id }
								
							end
							
						end
						
				
				end
			end
			--Fin TEST
			
			--Close the parent Menu if open
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
			
			--Open the sub menu
			print("OPEN SUBMENU HERE")
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItCars',
			{
				title    = "Your cars in VinewoodEstate2650",
				align    = 'top-left',
				elements = subMenuItems
			},
			
			function(data, menu)
			
				vehicleIndex = data.current.value
				
				--Close the child menu
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
		
				Citizen.Wait(500)
		
				--Call the function to spawn the vehicle et delete him from the garage
				spawnVehicle(vehicleIndex)
				
			end, function(data, menu)
				 menu.close()
			end)
			
			
			
		elseif (action == "ImaginationCt265") then
			
			print("PRESSED")
			subMenuItems = {}
			
			--Used to load the global variable [ localVehicle ] with the cars that are in the garage passed in arg1
			getCarInGarage("ImaginationCt265")
			
			--TEST
			--If the garage is empty no need to add ITEMS and Open the [ bringItCars ] so we close the parent menu and return
			if( localVehicles[1] == nil ) then
			
				--print("EMPTY !!")
				--ShowNotification : No cars parked in this garage
				ESX.ShowNotification("~r~No cars in this garage", true, false, 140)
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
				return
				
			else
				--Add entries to the UI Sub Menu [ bringItCars ]
				--For each vehicle in the player's garage
				for i, field in ipairs(localVehicles) do
				
						
						for k, vehicleData in pairs(field.vehicle) do

							if (k == "model") then
								--Add the car to the subMenuCar for this Garage
								table.insert(subMenuItems, { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData)), ["value"] = i })
								--elements[i] = { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData.model)), ["value"] = field.id }
								
							end
							
						end
						
				
				end
			end
			--Fin TEST
			
			--Close the parent Menu if open
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
			
			--Open the sub menu
			print("OPEN SUBMENU HERE")
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItCars',
			{
				title    = "Your cars in ImaginationCt265",
				align    = 'top-left',
				elements = subMenuItems
			},
			
			function(data, menu)
			
				vehicleIndex = data.current.value
			
				--Close the child menu
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
				
				Citizen.Wait(500)
				
				--Call the function to spawn the vehicle et delete him from the garage
				spawnVehicle(vehicleIndex)
				
			end, function(data, menu)
				 menu.close()
			end)
			
			
			
		elseif (action == "SteeleWay1150") then
		
		
			
			print("PRESSED")
			subMenuItems = {}
			
			--Used to load the global variable [ localVehicle ] with the cars that are in the garage passed in arg1
			getCarInGarage("SteeleWay1150")
			
			--TEST
			--If the garage is empty no need to add ITEMS and Open the [ bringItCars ] so we close the parent menu and return
			if( localVehicles[1] == nil ) then
			
				--print("EMPTY !!")
				--ShowNotification : No cars parked in this garage
				ESX.ShowNotification("~r~No cars in this garage", true, false, 140)
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
				return
				
			else
				--Add entries to the UI Sub Menu [ bringItCars ]
				--For each vehicle in the player's garage
				for i, field in ipairs(localVehicles) do
				
						
						for k, vehicleData in pairs(field.vehicle) do

							if (k == "model") then
								--Add the car to the subMenuCar for this Garage
								table.insert(subMenuItems, { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData)), ["value"] = i })
								--elements[i] = { ["label"] = string.lower(GetDisplayNameFromVehicleModel(vehicleData.model)), ["value"] = field.id }
								
							end
							
						end
						
				
				end
			end
			--Fin TEST
			
			--Close the parent Menu if open
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItGarages')
			
			--Open the sub menu
			print("OPEN SUBMENU HERE")
			
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bringItCars',
			{
				title    = "Your cars in SteeleWay1150",
				align    = 'top-left',
				elements = subMenuItems
			},
			
			function(data, menu)
			
				vehicleIndex = data.current.value
				
				--Call the function to spawn the vehicle et delete him from the garage
				spawnVehicle(vehicleIndex)
			
				--Close the child menu
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
				
			end, function(data, menu)
				 menu.close()
			end)
			
			
			
			
		end
			
	end, function(data, menu)
		menu.close()
	end)
	
	
end


--Function that get all the cars in the garage in arg1
function getCarInGarage(garage)

	
	TriggerServerEvent("esx_bringIt:GetPersonalCarInGarage", garage)
	
	Citizen.Wait(2000)
	
	vehicleProps = {}
	
	--Go through each field stored in the [ localVehicles ] wich are the same as the fields in table [ user_parkings ] but only the one we fetch in the server script {1}
	for i, field in ipairs(localVehicles) do
	
		--field.id = the unique id of the DB table entry
		--field.garage = garage name
		--field.vehicle = table containing all the caracteristics of the vehicle and their value (model,turbo,engine ...)
		
		--The idea here is to parse the [ vehicle ] index of localVehicules into a lua TABLE
		for k, vehicleData in pairs(field.vehicle) do
		
			--print(k)
			--print(vehicleData)
			--table.insert(vehicleProps, {k  = vehicleData})
			vehicleProps[k] = vehicleData
			
		end
		
		--replace the [ localVehicles.vehicle ] of the local TABLE [ localVehicles ] with a TABLE more suited for LUA
		field.vehicle = vehicleProps
		vehicleProps = {}
		
	end


end

--Function that spawn the desired vehicle and remove it from the garage he is in
function spawnVehicle(vehicleIndex)
	local driverNpc = nil
	local _vehicle = nil
	local loopSwitch = true
	
	--Spawn a vehicule model of the user and set all its caracteristics as the player's car
	ESX.Game.SpawnVehicle(localVehicles[vehicleIndex].vehicle.model, spawnVehicleCoords, 100.0,function(vehicle)
	
		--Add the same modifications as the original player car
		ESX.Game.SetVehicleProperties(vehicle, localVehicles[vehicleIndex].vehicle)
		_vehicle = vehicle
		
	end)
			
	--Wait for the [ SpawnVehicle ] function to finish (cause Async)		
	while _vehicle == nil do
		Citizen.Wait(5000)
	end
	
	--print(_vehicle)
	
	--Allow us to know that the mechano is alreay in delivery
	isInDelivery = true
	
	--Create a NPC inside the vehicle, to drive it
	RequestModel(-907676309) --Request NPC model
	Citizen.Wait(1000) --Wait for the model to load
	driverNpc = CreatePedInsideVehicle(_vehicle, 4, -907676309, -1, true, false)	
	print("DriverNpc :")
	print(driverNpc)		
	
	
	
	Citizen.Wait(2500)
	
	--Add Blip to the NPC so the player can see is position on the map
	npcBlip = AddBlipForEntity(driverNpc) 
	SetBlipSprite(npcBlip, 225)
	SetBlipColour(npcBlip, 17)
	SetBlipAlpha(npcBlip, 200)
	SetBlipFlashes(npcBlip, true)
	
	--Make the NPC drive the car to the player location
	--TaskVehicleDriveToCoord(driverNpc, _vehicle, playerCoords.x, playerCoords.y, playerCoords.z, 30.0, 1, _vehicle, 1074528293, 1.0, true) --786603
	TaskVehicleDriveToCoordLongrange(driverNpc, _vehicle, playerCoords.x, playerCoords.y, playerCoords.z, 18.0, 1074528293, 5.0)
	
	--ShowNotification saying that vehicle is on is way
	ESX.ShowNotification("~b~Your Vehicle is on is way ! (check your map)", true, false, 140)
	ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bringItCars')
	
	--Citizen.Wait(100000)

	--Check if the NPC is arrived to the player coords
	driverCoords = GetEntityCoords(_vehicle)
	while( loopSwitch ) do
		--check every 1 sec
		Citizen.Wait(1000)
		--checking the new driver coords
		driverCoords = GetEntityCoords(_vehicle)
		
		--TEST
		--print(playerCoords)
		--print(driverCoords)
		
		--TEST
		--If the vehicle is at 6 units of the player coords on the X or Y unit then quit the loop
		if( (playerCoords.x - driverCoords.x >= -20 and playerCoords.x - driverCoords.x <= 20) and (playerCoords.y - driverCoords.y >= -20 and playerCoords.y - driverCoords.y <= 20 ) ) then
			loopSwitch = false
			
			
			--Make the NPC stop progressively when he reaches the player position, so he doesn't drift like crazy
			TaskVehicleTempAction(driverNpc, _vehicle, 1, 1000)
			
			
			--Make the NPC exit the vehicle and flag him as not needed anymore
			TaskLeaveAnyVehicle(driverNpc, 0, 256)
			
			--TEST -----------------------
			--NPC honk at the player
			for i = 1, 60000 do
				SoundVehicleHornThisFrame(_vehicle)
			end
			
		end
		print("On is way")
		print(loopSwitch)
	end
	
	
	ESX.ShowAdvancedNotification("Mechano", "~r~BringIt" ,"~b~Your car as arrived, check aroud you", "CHAR_MECHANIC")
	
	--Mechano is not in delivery anymore
	isInDelivery = false
	
	Citizen.Wait(2000)
	--Make the NPC walk so he doesn't enter back in the car when we let him go with [ RemovePedElegantly() ]
	TaskWanderStandard(driverNpc, 10, 10)
	Citizen.Wait(2000) 
	
	--Flag the NPC as NoLongerNeeded so the game will delete it when he will see fit
	--SetPedAsNoLongerNeeded(driverNpc)
	RemovePedElegantly(driverNpc)
	RemoveBlip(npcBlip)	
	
	--Delete the vehicle from the parking table (because the player is summoning it so it is no longer in is garage)
	--TriggerServerEvent("esx_bringIt:RemoveCarFromGarage", localVehicles[vehicleIndex].garage, localVehicles[vehicleIndex].id) 
			
	print("should be arrived")

end


--Function that search a road near the player actual location
function LookForCoordsNearPlayer(playerCoords)

	local noRoadsCounter = 0
	local headingBackOfPlayer = 0
	
	--The value of [ spawnpoint ] starts at player coords then will change until we find a point on the road behind the player
	local spawnpoint = playerCoords
	local headingPlayer = GetEntityHeading(PlayerPedId())
	
	if( headingPlayer < 180) then
		headingBackOfPlayer = headingPlayer + 180
	else
		headingBackOfPlayer = headingPlayer - 180
	end
		
	--TEST --------------------------------
	
	--Move the spawnpoint further from the player, so the car will spawn in another street or around another building block
	if( headingBackOfPlayer > 0 and  headingBackOfPlayer < 90 ) then
		
		spawnpoint = vector3(playerCoords.x - 100, playerCoords.y + 100, playerCoords.z)
		
	elseif( headingBackOfPlayer >= 90 and  headingBackOfPlayer < 180 ) then

		spawnpoint = vector3(playerCoords.x - 100, playerCoords.y - 100, playerCoords.z)		
		
	elseif( headingBackOfPlayer >= 180 and  headingBackOfPlayer < 270 ) then
		
		spawnpoint = vector3(playerCoords.x + 100, playerCoords.y + 100, playerCoords.z) 	
		
	elseif( headingBackOfPlayer >= 270 and  headingBackOfPlayer <= 360 ) then
		
		spawnpoint = vector3(playerCoords.x + 100, playerCoords.y + 100, playerCoords.z) 	
		
	else
		--NOTHING
	end
	
	
	
	--Fin TEST -------------------------------
	
	
	--pointOnRoad = 1 if player on road else pointOnRoad = false
	local pointOnRoad = false
	--Changed to true if no point on road are found at 600 units of the player {4}
	local notFound = false
	
	--TEST
	--print(spawnpoint)
	checkCoords = spawnpoint
	
	--Checking different coodrs behind the player to find a road where to spawn the vehicle
	while pointOnRoad == false do
	
		--checkCoords = spawnpoint
		
		if( headingBackOfPlayer > 0 and  headingBackOfPlayer < 90 ) then
		
			checkCoords = vector3(checkCoords.x - 30,checkCoords.y + 30,checkCoords.z) 
		
		elseif( headingBackOfPlayer >= 90 and  headingBackOfPlayer < 180 ) then

			checkCoords = vector3(checkCoords.x - 30,checkCoords.y - 30,checkCoords.z) 		
		
		elseif( headingBackOfPlayer >= 180 and  headingBackOfPlayer < 270 ) then
		
			checkCoords = vector3(checkCoords.x + 30,checkCoords.y - 30,checkCoords.z) 	
		
		elseif( headingBackOfPlayer >= 270 and  headingBackOfPlayer <= 360 ) then
		
			checkCoords = vector3(checkCoords.x + 30,checkCoords.y + 30,checkCoords.z) 	
		
		else
			--NOTHING
		end
	
		--Check to see if our actual [ checkCoords ] is on a road
		pointOnRoad = IsPointOnRoad(checkCoords.x,checkCoords.y,checkCoords.z)
		
		--TEST
		--print(checkCoords)
		
		--If their is no points on road at 600 units of the player, drop the search {4}
		noRoadsCounter = noRoadsCounter + 1
		if( noRoadsCounter == 300 ) then 
			--pointOnRoad = "NOT FOUND !"
			notFound = true
			pointOnRoad = true
		end
		
	end
	
	spawnpoint = checkCoords
	
	--If no point on road are found at 600 units of the player {4}
	if( notFound ) then 
	
		spawnpoint = nil
		
	end
	
	
	return spawnpoint
	

end

--Fin Functions -------------------------------------------------------------------------------------------------





-- [ TODO ] -------------------------------------------------------------------------------------------------

	--[GOOD]Implement the SubMenu for the "VinewoodEstate2650" garage and test it   (ESX.UI.Menu.Open())
	--[GOOD]Make the NPC drive the car to the player location with the function [ TaskVehicleDriveToCoordLongrange ]
	--[GOOD] + then make the NPC exit the car, walk away and then deleteHim
	--[GOOD]Add the "Vehicle incoming" Notification
	--[GOOD]Add the if statement to change the condition of the loop
	--[+/- GOOD] Make the NPC horn at the player at arrival
	--[GOOD]Send a notif to the player when the [ LookForCoordsNearPlayer() ] function isn't able to find a spwanPoint aroundHim
	--[GOOD]Regler le problème du multi spawn de voiture lors du spam ENTER (move the ExitMenu the higher up)
	--Faire un system qui annule la livraison si la voiture met trop de temps à arriver
	--[GOOD]Delete the car from DB only at the end (move the TriggerEvent to the end of spawn car)
	--[GOOD]Implement a system to check if the mechano is already in delivery for this player, if so disable his services (so the player cannot recall for the same car){5}
	--[GOOD] Fix the problem of the NPC not spawning inside the vehicule at random times (maybe increase timer)
	--[GOOD]Stop the task of the NPC when he arrives to destination before making him exit vehicle, so he doesn't drift and make a mess 
	--Deal with the fact that the vehicle isn't in the database anymore
	--Faire un retour arrière du sub menu au menu si la garage est vide, au cas ou le joueur se trompe ou autre


-- Table[ user_parkings ] champ [ vehicle ] content : 

-- test = {"modEngine"=-1,
-- "modTurbo"=false,
-- "modSeats"=-1,
-- "neonColor"=[255,0,255],
-- "modTrimA"=-1,
-- "modSuspension"=-1,
-- "model"=-1216765807,
-- "pearlescentColor"=7,
-- "modDoorSpeaker"=-1,
-- "modBackWheels"=-1,
-- "bodyHealth"=1000.0,
-- "engineHealth"=1000.0,
-- "modRoof"=-1,
-- "modRearBumper"=-1,
-- "modOrnaments"=-1,
-- "xenonColor"=255,
-- "modLivery"=-1,
-- "modAirFilter"=-1,
-- "modDashboard"=-1,
-- "modDial"=-1,
-- "color1"=1,
-- "modFrame"=-1,
-- "modShifterLeavers"=-1,
-- "modAerials"=-1,
-- "color2"=0,
-- "tyreSmokeColor"=[255,255,255],
-- "modVanityPlate"=-1,
-- "fuelLevel"=65.0,
-- "tankHealth"=1000.0,
-- "wheelColor"=156,
-- "modSideSkirt"=-1,
-- "modXenon"=false,
-- "modRightFender"=-1,
-- "modWindows"=-1,
-- "modGrille"=-1,
-- "modArchCover"=-1,
-- "modSteeringWheel"=-1,
-- "windowTint"=-1,
-- "modTransmission"=-1,
-- "modFender"=-1,
-- "extras"={"1"=true,"12"=true,"10"=false},
-- "modExhaust"=-1,
-- "modSmokeEnabled"=false,
-- "plate"="06KMN732",
-- "neonEnabled"=[false,false,false,false],
-- "modHorns"=-1,
-- "modBrakes"=-1,
-- "dirtLevel"=1.2,
-- "modFrontWheels"=-1,
-- "modTrimB"=-1,
-- "modSpeakers"=-1,
-- "modArmor"=-1,
-- "modFrontBumper"=-1,
-- "modAPlate"=-1,
-- "modTank"=-1,
-- "modStruts"=-1,
-- "modEngineBlock"=-1,
-- "modTrunk"=-1,
-- "modPlateHolder"=-1,
-- "modHydrolic"=-1,
-- "plateIndex"=0,
-- "wheels"=7,
-- "modHood"=-1,
-- "modSpoilers"=-1
-- }