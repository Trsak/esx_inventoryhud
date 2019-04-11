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

local anotherPlayerInventory = false
local anotherPlayer = 0
local isInInventory = false
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
        if IsControlJustReleased(0, Config.OpenControl) and IsInputDisabled(0) then
            anotherPlayerInventory = false
            openInventory()
        end
    end
end)

function openInventory()
    loadPlayerInventory()
    isInInventory = true
    SendNUIMessage({
        action = "display"
    })
    SetNuiFocus(true, true)
end

RegisterNUICallback('NUIFocusOff', function()
    isInInventory = false
    SendNUIMessage({
        action = "hide"
    })
	SetNuiFocus(false, false)
end)

RegisterNUICallback('GetNearPlayers', function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayers = false
    local elements     = {}

    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            foundPlayers = true

            table.insert(elements, {
                label = GetPlayerName(players[i]),
                player = GetPlayerServerId(players[i])
            })
        end
    end
    
    if not foundPlayers then
        ESX.ShowNotification(_U('players_nearby'))
    else
        SendNUIMessage({
            action = "nearPlayers",
            foundAny = foundPlayers,
            players = elements,
            item = data.item,
            count = data.count,
            type = data.type,
            what = data.what
        })
    end
    
	cb("ok")
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

RegisterNUICallback('GiveItem', function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayer = false
    for i=1, #players, 1 do
        if players[i] ~= PlayerId() then
            if GetPlayerServerId(players[i]) == data.player then
                foundPlayer = true
            end
        end
    end
    
    if foundPlayer then
        TriggerServerEvent('esx:giveInventoryItem', data.player, data.data.type, data.data.item, tonumber(data.data.count))
        Wait(500)
        loadPlayerInventory()
    else
        ESX.ShowNotification(_U('player_nearby'))
    end
	cb("ok")
end)

function shouldSkipAccount (accountName)
    for index, value in ipairs(Config.ExcludeAccountsList) do
        if value == accountName then
            return true
        end
    end

    return false
end

function loadPlayerInventory()
    local PlayerData
    if anotherPlayerInventory then
        PlayerData = anotherPlayer
    else
        PlayerData = ESX.GetPlayerData()
    end

    local playerPed = PlayerPedId()
    local inventory = PlayerData["inventory"]
    local money = PlayerData["money"]
    local accounts = PlayerData["accounts"]
    local items  = {}

    if Config.IncludeCash and money ~= nil then
        if money > 0 then
            local formattedMoney = ESX.Math.GroupDigits(money)

            table.insert(items, {
                label     = _U('cash'),
                count     = formattedMoney,
                type      = 'item_money',
                name     = 'cash',
                usable    = false,
                rare      = false,
                limit = -1,
                canRemove = true
            })
        end
    end

    if Config.IncludeAccounts and accounts ~= nil then
        for i=1, #accounts, 1 do
            if not shouldSkipAccount(accounts[i].name) then
                if accounts[i].money > 0 then
                    local canDrop = accounts[i].name ~= 'bank'

                    table.insert(items, {
                        label     = accounts[i].label,
                        count     = accounts[i].money,
                        type      = 'item_account',
                        name     = accounts[i].name,
                        usable    = false,
                        rare      = false,
                        limit = -1,
                        canRemove = canDrop
                    })
                end
            end
        end
    end
    
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

    if Config.IncludeWeapons then
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
    end
    
    
    SendNUIMessage({
        action = "setItems",
        itemList = items
    })
end

RegisterNetEvent("esx_inventoryhud:openPlayerInventory")
AddEventHandler("esx_inventoryhud:openPlayerInventory", function(player)
    anotherPlayerInventory = true
    anotherPlayer = player
    openInventory()
end)

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/openinventory',  _U('openinventory_help'),  { { name = _U('generic_argument_name'), help = _U('generic_argument_help') } } )
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/openinventory')
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if isInInventory then
            local playerPed = PlayerPedId()
			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, Keys['W'], true) -- W
			DisableControlAction(0, Keys['A'], true) -- A
			DisableControlAction(0, 31, true) -- S (fault in Keys table!)
			DisableControlAction(0, 30, true) -- D (fault in Keys table!)

			DisableControlAction(0, Keys['R'], true) -- Reload
			DisableControlAction(0, Keys['SPACE'], true) -- Jump
			DisableControlAction(0, Keys['Q'], true) -- Cover
			DisableControlAction(0, Keys['TAB'], true) -- Select Weapon
			DisableControlAction(0, Keys['F'], true) -- Also 'enter'?

			DisableControlAction(0, Keys['F1'], true) -- Disable phone
			DisableControlAction(0, Keys['F2'], true) -- Inventory
			DisableControlAction(0, Keys['F3'], true) -- Animations
			DisableControlAction(0, Keys['F6'], true) -- Job

			DisableControlAction(0, Keys['V'], true) -- Disable changing view
			DisableControlAction(0, Keys['C'], true) -- Disable looking behind
			DisableControlAction(0, Keys['X'], true) -- Disable clearing animation
			DisableControlAction(2, Keys['P'], true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, Keys['LEFTCTRL'], true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
	end
end)