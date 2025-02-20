fx_version 'cerulean'
game 'gta5'

author 'UNIX SCRIPT'
description 'STOCK SYSTEM'
version '1.0.0'

ui_page 'ui/index.html'

-- Shared files
shared_scripts {
    'config.lua'
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua', -- If using MySQL for saving stock transactions
    'server.lua'
}

-- Client scripts
client_scripts {
    'client.lua'
}

-- NUI Files
files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

-- Required for NUI to work
lua54 'yes'