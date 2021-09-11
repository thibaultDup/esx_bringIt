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

print("[ esx_bringIt ] RESOURCE STARTED")
print("You can find this resource in my github : https://github.com/thibaultDup") 

ESX = nil

--Wait to get the ESX Object
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--TEST - esx_PHONE --------------------------------

--Duplicate the Event [ 'gcPhone:startCall' ] of gcPhone, to capture call and trigger the opening of our script's menu {7}
--If a player call 505505 or 505-505 it will start our script core
RegisterNetEvent("gcPhone:startCall")
AddEventHandler('gcPhone:startCall', function(phone_number, rtcOffer, extraData)

	--REMOVE in the futur
	local _source = source
	
	--TEST
	-- print(rtcOffer)
	-- print(extraData)
	
	if( phone_number == "505505" or phone_number == "505-505" ) then
	
		print("Calling Mechano")
		
		TriggerClientEvent("esx_bringIt:MechanoCalled", _source)
	
	end 
	
	
end)

--Fin TEST

RegisterNetEvent("esx_bringIt:GetPersonalCar")
AddEventHandler("esx_bringIt:GetPersonalCar", function()

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	--print(xPlayer.identifier)
	
	--Fetch all the entries for the player in [ user_parkings ] based on his identifier.
	MySQL.Async.fetchAll('SELECT * FROM `user_parkings` WHERE `identifier` = @identifier',
	{
		['@identifier'] = xPlayer.identifier,
		['@garage']     = garage
	}, function(result)
	
		--DeclaringTABLE that contain all the entries fetched by the SQL request {2}
		local vehicles = {}
		
		--Inserting into the results of the SQL request (only the fields that interest us) ( fields : [ garage ], [ vehicle ] ) {2}
		for i=1, #result, 1 do
			table.insert(vehicles, {
				
				--[ id ] is the id of the entry in the database
				id = result[i].id,
				
				--[ garage ] is a STRING containing the name of the garage where the wehicle is stored
				garage = result[i].garage,
				
				--[ vehicle ] is a TABLE containing all the specificities of the car
				vehicle = json.decode(result[i].vehicle)
				
			})
		end
		
		
		--Return the vehicles TABLE {2}
		TriggerClientEvent("esx_bringIt:GetPersonalCar:return", -1, vehicles)
		
	end)
	

end)

RegisterNetEvent("esx_bringIt:GetPersonalCarInGarage")
AddEventHandler("esx_bringIt:GetPersonalCarInGarage", function(garage)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	--print(xPlayer.identifier)
	
	--Fetch all the entries for the player in [ user_parkings ] based on his identifier.
	MySQL.Async.fetchAll('SELECT * FROM `user_parkings` WHERE `identifier` = @identifier AND `garage` = @garage',
	{
		['@identifier'] = xPlayer.identifier,
		['@garage']     = garage
	}, function(result)
	
		--DeclaringTABLE that contain all the entries fetched by the SQL request {2}
		local vehicles = {}
		
		--Inserting into the results of the SQL request (only the fields that interest us) ( fields : [ garage ], [ vehicle ] ) {2}
		for i=1, #result, 1 do
			table.insert(vehicles, {
				
				--[ id ] is the id of the entry in the database
				id = result[i].id,
				
				--[ garage ] is a STRING containing the name of the garage where the wehicle is stored
				garage = result[i].garage,
				
				--[ vehicle ] is a TABLE containing all the specificities of the car
				vehicle = json.decode(result[i].vehicle)
				
			})
		end
		
		
		--Return the vehicles TABLE {2}
		TriggerClientEvent("esx_bringIt:GetPersonalCarInGarage:return", -1, vehicles)
		
	end)
end)


RegisterNetEvent("esx_bringIt:GetPersonalGarage")
AddEventHandler("esx_bringIt:GetPersonalGarage", function()

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	
	--Fetch all the entries for the player in [ user_parkings ] based on his identifier.
	MySQL.Async.fetchAll('SELECT `garage` FROM `user_parkings` WHERE `identifier` = @identifier',
	{
		['@identifier'] = xPlayer.identifier
	}, function(result)
	
		--DeclaringTABLE that contain all the entries fetched by the SQL request {2}
		local garages = {}
		
		--Inserting into the results of the SQL request (only the fields that interest us) ( fields : [ garage ], [ vehicle ] ) {2}
		for i=1, #result, 1 do
			table.insert(garages, {result[i].garage})
		end
		
		--Return the vehicles TABLE {2}
		TriggerClientEvent("esx_bringIt:GetPersonalGarage:return", -1, garages)
		
	end)
	

end)


RegisterNetEvent("esx_bringIt:RemoveCarFromGarage")
AddEventHandler("esx_bringIt:RemoveCarFromGarage", function(garage, id)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('DELETE FROM `user_parkings` WHERE `identifier` = @identifier AND `garage` = @garage AND `id` = @id ',
			{
				['@id'] = id,
				['@identifier'] = xPlayer.identifier,
				['@garage']     = garage;
			}, function(rowsChanged)
				--xPlayer.showNotification(_U('veh_released'))
			end)


end)