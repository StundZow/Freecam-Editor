fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Freecam Editor'
description 'Freecam sans HUD pour tourner des B-rolls'
version '1.2.0'

shared_script 'config.lua'

client_scripts {
    'settings.lua',
    'sky.lua',
    'distance.lua',
    'menu.lua',
    'client.lua',
}

server_script 'server.lua'
