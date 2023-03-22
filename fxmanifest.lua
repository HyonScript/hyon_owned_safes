fx_version 'cerulean'
game 'gta5'
name 'hyon_owned_safes'
version      '1.0.0'
description 'Player Owned Safes'

dependencies {
	'es_extended',
	'ox_lib',
}

shared_script {
	'@ox_lib/init.lua',
	'config.lua'
}

client_scripts {
	'@es_extended/imports.lua',
    'client/main.lua'
}

server_scripts {
	'@es_extended/imports.lua',
	'@mysql-async/lib/MySQL.lua',
	'@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'

