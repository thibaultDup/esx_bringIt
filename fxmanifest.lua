fx_version 'adamant'
game 'gta5'
name 'esx_bringIt'
description 'The equivalent of GTA Online mechano, wich bring your personnal vehhicle on demand' 
author 'thibaultDup'
--ui_page 'html/ui.html'

-- files {
	-- 'html/ui.html',
    -- 'html/closephone.js'
-- }

shared_scripts{
	'@es_extended/imports.lua',
}

client_scripts{
	'client/main.lua',
	'@esx_garage/config.lua'
}

server_scripts{
	'server/main.lua',
	'@mysql-async/lib/MySQL.lua'
}