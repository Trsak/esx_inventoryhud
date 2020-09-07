local lastStorage = nil

RegisterNetEvent("esx_inventoryhud:openStorageInventory")
AddEventHandler(
    "esx_inventoryhud:openStorageInventory",
    function(storage)
        lastStorage = storage

        ESX.TriggerServerCallback(
            "esx_inventoryhud:getStorageInventory",
            function(storageData)
                setStorageInventoryData(storageData)
                openStorageInventory()
            end,
            storage
        )
    end
)

function refreshStorageInventory()
    ESX.TriggerServerCallback(
        "esx_inventoryhud:getStorageInventory",
        function(storageData)
            setStorageInventoryData(storageData)
        end,
        lastStorage
    )
end

function setStorageInventoryData(data)
    items = {}

    local blackMoney = data.blackMoney
    local storageItems = data.inventory
    local storageWeapons = data.weapons

    if blackMoney > 0 then
        accountData = {
            label = _U("black_money"),
            count = blackMoney,
            type = "item_account",
            name = "black_money",
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, accountData)
    end

    for i = 1, #storageItems, 1 do
        local item = storageItems[i]

        if item.count > 0 then
            item.type = "item_standard"
            item.usable = false
            item.rare = false
            item.limit = -1
            item.canRemove = false

            table.insert(items, item)
        end
    end

    for i = 1, #storageWeapons, 1 do
        local weapon = storageWeapons[i]

        if storageWeapons[i].name ~= "WEAPON_UNARMED" then
            table.insert(
                items,
                {
                    label = ESX.GetWeaponLabel(weapon.name),
                    count = weapon.ammo,
                    limit = -1,
                    type = "item_weapon",
                    name = weapon.name,
                    usable = false,
                    rare = false,
                    canRemove = false
                }
            )
        end
    end

    SendNUIMessage(
        {
            action = "setSecondInventoryItems",
            itemList = items
        }
    )
end

function openStorageInventory()
    loadPlayerInventory()
    isInInventory = true

    SendNUIMessage(
        {
            action = "display",
            type = "storage"
        }
    )

    SetNuiFocus(true, true)
end

RegisterNUICallback(
    "PutIntoStorage",
    function(data, cb)
        if IsPedSittingInAnyVehicle(playerPed) then
            return
        end

        if type(data.number) == "number" and math.floor(data.number) == data.number then
            local count = tonumber(data.number)

            if data.item.type == "item_weapon" then
                count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
            end

            TriggerServerEvent("esx_inventoryhud:putStorageItem", lastStorage, data.item.type, data.item.name, count)
        end

        Wait(150)
        refreshStorageInventory()
        Wait(150)
        loadPlayerInventory()

        cb("ok")
    end
)

RegisterNUICallback(
    "TakeFromStorage",
    function(data, cb)
        if IsPedSittingInAnyVehicle(playerPed) then
            return
        end

        if type(data.number) == "number" and math.floor(data.number) == data.number then
            TriggerServerEvent("esx_inventoryhud:getStorageItem", lastStorage, data.item.type, data.item.name, tonumber(data.number))
        end

        Wait(150)
        refreshStorageInventory()
        Wait(150)
        loadPlayerInventory()

        cb("ok")
    end
)
