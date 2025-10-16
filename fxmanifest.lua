fx_version 'cerulean'
game 'gta5'

name 'Mythic-RadioList'
author 'Mythic Framework'
description 'Mythic Radio List : List of players in each radio for mythic radio system'

shared_scripts {
	'Config.lua',
}

ui_page "ui/index.html"

files {
	"ui/index.html"
}

server_script {
	"Server/*.lua"
}

client_script {
	"Client/*.lua"
}


