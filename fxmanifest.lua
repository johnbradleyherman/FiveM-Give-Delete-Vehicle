fx_version 'adamant'
games { 'gta5' }
ui_page 'html/index.html'

author 'aintjb'
description 'JB Scripts | Discord link: https://discord.gg/ZyNuMCBeMh'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'config.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/main.lua',
	'config.lua'
}
