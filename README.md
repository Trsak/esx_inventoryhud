# esx_inventoryhud 2.1
Inventory HUD for ESX. You can open and close inventory using F2. Part of code was taken from [es_extended](https://github.com/ESX-Org/es_extended).

## Requirements
* [es_extended](https://github.com/ESX-Org/es_extended)
* [pNotify](https://forum.fivem.net/t/release-pnotify-in-game-js-notifications-using-noty/20659)

## Features
- Drag and drop
- Using items
- Dropping items
- Giving items
- Cash included
- Accounts support (bank, black money, ...)
- Weapons support
- Fully configurable (check config.lua and html/js/config.js)
- Locale files included (check locales/ and html/locales/ directories)

## Addons
* [Vehicle trunk inventory](https://github.com/Trsak/esx_inventoryhud_trunk/tree/master)

## Screens
* [https://i.imgur.com/eHD01Tl.png](https://i.imgur.com/eHD01Tl.png)

## Download & Installation

### Using Git
```
cd resources
git clone https://github.com/Trsak/esx_inventoryhud [esx]/esx_inventoryhud
```

### Manually
- Download https://github.com/Trsak/esx_inventoryhud/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Open `es_extended`, then find and remove this code in `client/main.lua`:
```
-- Menu interactions
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if IsControlJustReleased(0, Keys['F2']) and IsInputDisabled(0) and not isDead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end

	end
end)
```
- Add this to your `server.cfg`:

```
start esx_inventoryhud
```

## Config files
* config.lua
* html/js/config.js
