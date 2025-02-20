ESX = exports["es_extended"]:getSharedObject()

local previousPrices = {} -- Store last known prices

-- Command to open stock exchange UI
RegisterCommand("stocks", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" }) -- Open NUI
    TriggerServerEvent("stock_exchange:getStockData") -- Request stock data
end, false)

-- Close UI when "Escape" key is pressed
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" }) -- Close UI
    cb("ok")
end)

-- Handle buying stocks
RegisterNUICallback("buyStock", function(data, cb)
    TriggerServerEvent("stock_exchange:buyStock", data.symbol, data.amount)
    cb("ok")
end)

-- Handle selling stocks
RegisterNUICallback("sellStock", function(data, cb)
    TriggerServerEvent("stock_exchange:sellStock", data.symbol, data.amount)
    cb("ok")
end)

-- Update stock prices and calculate price difference
local previousPrices = {}

RegisterNetEvent("stock_exchange:updatePrices")
AddEventHandler("stock_exchange:updatePrices", function(prices)
    local priceChanges = {}
    local oxItems = exports.ox_inventory:Items() -- Fetch all item labels from Ox

    for symbol, stockData in pairs(prices) do
        if type(stockData) == "table" then -- Ensure it's a valid stock object
            local itemLabel = oxItems[symbol] and oxItems[symbol].label or symbol -- Get Ox Inventory item label
            local oldPrice = previousPrices[symbol] and previousPrices[symbol].price or stockData.price
            local difference = stockData.price - oldPrice
            local color = "#FFFFFF" -- Default white

            if difference > 0 then
                color = "#00FF00" -- Green for profit
            elseif difference < 0 then
                color = "#FF0000" -- Red for loss
            end

            priceChanges[symbol] = {
                marketName = stockData.marketName, -- Custom market name
                itemLabel = itemLabel, -- Ox Inventory item label
                price = stockData.price,
                diff = difference,
                color = color
            }
        end
    end

    previousPrices = prices -- Store prices for next update
    SendNUIMessage({ action = "update", stocks = priceChanges })
end)


-- Close UI when ESC key is pressed
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 200) then -- 200 = ESC key
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "close" }) -- Close UI properly
        end
    end
end)
