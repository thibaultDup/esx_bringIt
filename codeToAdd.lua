
--Add the following code to [ gcphone/client/client.lua ] (around line 359) , to link the script to the phone




--Add closing phone event for my [ esx_bringIt ] scipt, to be able to control the closing of the phone -----------------------------------------

RegisterNetEvent("gcPhone:closeThePhone")
AddEventHandler("gcPhone:closeThePhone", function()

  print("Triggered")
  menuIsOpen = false
  TriggerEvent('gcPhone:setMenuStatus', false)
  SendNUIMessage({show = false})
  PhonePlayOut()

end)

--