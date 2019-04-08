resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'ESX Inventory HUD'

version '1.0'

ui_page 'html/ui.html'

client_scripts {
  '@es_extended/locale.lua',
  'client/main.lua',
  'locales/cs.lua',
  'locales/en.lua',
  'config.lua'	
}

files {
    'html/ui.html',
    'html/css/contextMenu.min.css',
    'html/css/jquery.dialog.min.css',
    'html/css/ui.min.css',
    'html/js/config.js',
    'html/js/contextMenu.min.js',
    'html/js/jquery.dialog.min.js',
    'html/locales/cs.js',
    'html/locales/en.js',
    'locales/cs.lua',
    'locales/en.lua',
    'html/fonts/osifont.ttf',
    'html/img/items/beer.png',
    'html/img/items/binoculars.png',
    'html/img/items/bread.png',
    'html/img/items/cannabis.png',
    'html/img/items/cigarette.png',
    'html/img/items/clip.png',
    'html/img/items/cocacola.png',
    'html/img/items/coffee.png',
    'html/img/items/coke.png',
    'html/img/items/gold.png',
    'html/img/items/hamburger.png',
    'html/img/items/cash.png',
    'html/img/items/chocolate.png',
    'html/img/items/iron.png',
    'html/img/items/jewels.png',
    'html/img/items/medikit.png',
    'html/img/items/tequila.png',
    'html/img/items/whisky.png',
    'html/img/items/WEAPON_PISTOL.png',
    'html/img/items/WEAPON_KNIFE.png',
    'html/img/items/WEAPON_HAMMER.png',
    'html/img/items/limonade.png'
}