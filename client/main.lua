local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
    
	ESX.PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, Keys["F2"]) then
            loadPlayerInventory()
            SendNUIMessage({
                action = "display"
            })
            SetNuiFocus(true, true)
        end
    end
end)

RegisterNUICallback('NUIFocusOff', function()
    SendNUIMessage({
        action = "hide"
    })
	SetNuiFocus(false, false)
end)

RegisterNUICallback('UseItem', function(data, cb)
    TriggerServerEvent('esx:useItem', data.item)
    Citizen.Wait(500)
    loadPlayerInventory()
	cb("ok")
end)

RegisterNUICallback('DropItem', function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if data.type == 'item_weapon' then
        TriggerServerEvent('esx:removeInventoryItem', data.type, data.item)
        Wait(500)
        loadPlayerInventory()
    else -- type: item_standard
        TriggerServerEvent('esx:removeInventoryItem', data.type, data.item, data.number)
        Wait(500)
        loadPlayerInventory()
    end

	cb("ok")
end)

function loadPlayerInventory()
    PlayerData = ESX.GetPlayerData()
    local playerPed = PlayerPedId()
    local inventory = PlayerData["inventory"]
    local items  = {}
    
    for i=1, #inventory, 1 do
		if inventory[i].count > 0 then
			table.insert(items, {
				label     = inventory[i].label,
				type      = 'item_standard',
				count     = inventory[i].count,
				name     = inventory[i].name,
				usable    = inventory[i].usable,
				rare      = inventory[i].rare,
				limit      = inventory[i].limit,
				canRemove = inventory[i].canRemove
			})
		end
    end

    local weaponsList = ESX.GetWeaponList()
	for i=1, #weaponsList, 1 do
		local weaponHash = GetHashKey(weaponsList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponsList[i].name ~= 'WEAPON_UNARMED' then
			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
			table.insert(items, {
				label     = weaponsList[i].label,
                count     = ammo,
                limit     = -1,
				type      = 'item_weapon',
				name     = weaponsList[i].name,
				usable    = false,
				rare      = false,
				canRemove = true
			})
		end
	end
    
    
    SendNUIMessage({
        action = "setItems",
        itemList = items
    })
end