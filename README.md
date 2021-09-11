
# esx_bringIt

:octocat: :octocat: :octocat: 

---

Project's Author : thibaultDup

## Introduction :

[ **esx_bringIt** ] is my first Cfx script from scratch, their might be some bugs don't hesitate to contact me regarding those.

This script's purpose is to bring the GTA Online feature, wich allows you to call the mechanic for him to bring one of your personal car, to FiveM servers.

- You call a number with your phone.
- A menu pop's up with a list of all the garages aviable on the server.
- You choose from wich garage you want a vehicle from.
- A sub menu containing the vehicules parked in the garage pop's up.
- You choose the vehicule you want him to bring you
- You wait a few minutes (watch the map to see the mechanic's live position)
- Here is your vehicule delivered just for you



## Requirements:

I developped this resource to work inside the ESX ecosystem (ESX 1.2 and up)

- es_extended
- esx_garage
- gcpone Re-Ignited

Infos : For the time being, the resource only works with gcphone. But i'm actually working on making it compatible with other phones resources (ex_phone etc..)


## Installation: 


1. Download the ZIP, extract it, rename it esx_bringIt (if necessary)
2. Put the folder in the resources folder
3. *Add the following code* to the [ **gcphone/client/client.lua** ] file (around the line 359) : 
![Code to add the cgphone](https://i.imgur.com/HnuDZK5.png)
- I know that modifing other scripts this way in order to make my script working isn't the best way, i'm looking for another way to link the phone ot my script, but for now you need to do that in order to call the Mechano from the phone.
- You can find this code in the [ **codeToAdd.lua** ] file
4. Add this following line to the server.cfg (at the bottom of all the esx_addon startup) : ensure esx_bringIt

In the game : 

1. Bring the phone out.
2. Add a new contact named "Mechanic" (or whatever you want) with 505505 or 505-505 as his number. (You can change the number in the config.lua file)
3. Just call this contact for the Mechano to bring your car


## TODO LIST:

- Add a config file
- Add multiple languages for the scipt's text

## Other: 

If you encounter any issues, don't hesitate to report them :smiley_cat:

---