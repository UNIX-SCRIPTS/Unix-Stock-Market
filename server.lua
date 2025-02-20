ESX = exports["es_extended"]:getSharedObject()
local stockPrices = {}
local previousPrices = {} -- Store previous prices for comparison

-- Function to generate stock prices
function GenerateStockPrices()
    local oxItems = exports.ox_inventory:Items() -- Fetch all item labels
    local newPrices = {}

    for _, stock in ipairs(Config.Stocks) do
        local symbol = stock.symbol
        local oldPrice = stockPrices[symbol] and stockPrices[symbol].price or math.random(Config.MinStockPrice, Config.MaxStockPrice)
        local newPrice = oldPrice + math.random(-50, 50) -- Random fluctuation
        newPrice = math.max(Config.MinStockPrice, newPrice) -- Prevent negative prices

        local itemLabel = oxItems[symbol] and oxItems[symbol].label or symbol -- Get item name from Ox Inventory

        newPrices[symbol] = {
            marketName = stock.marketName, -- Custom name in UI
            itemLabel = itemLabel, -- Ox Inventory item label
            price = newPrice,
            diff = newPrice - oldPrice, -- Correctly calculate difference
            color = newPrice > oldPrice and "#00FF00" or (newPrice < oldPrice and "#FF0000" or "#FFFFFF")
        }
    end

    previousPrices = stockPrices -- Store previous prices for the next update
    stockPrices = newPrices -- Update stock prices
    TriggerClientEvent("stock_exchange:updatePrices", -1, stockPrices) -- Send update to all players
end

-- Auto-update prices every hour
CreateThread(function()
    GenerateStockPrices()
    while true do
        Wait(3600000) --3600000 Update every hour
        GenerateStockPrices()
    end
end)

-- Buy Stock
RegisterServerEvent("stock_exchange:buyStock")
AddEventHandler("stock_exchange:buyStock", function(symbol, quantity)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local stock = stockPrices[symbol]
    if not stock then return end -- Prevent error if stock is missing

    local price = stock.price * quantity
    if xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        exports.ox_inventory:AddItem(src, symbol, quantity)
        TriggerClientEvent("stock_exchange:notify", src, "success", "You bought " .. quantity .. " shares of " .. stock.itemLabel)
    else
        TriggerClientEvent("stock_exchange:notify", src, "error", "Not enough money!")
    end
end)

-- Sell Stock
RegisterServerEvent("stock_exchange:sellStock")
AddEventHandler("stock_exchange:sellStock", function(symbol, quantity)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local stock = stockPrices[symbol]
    if not stock then return end -- Prevent error if stock is missing

    local price = stock.price * quantity
    if exports.ox_inventory:RemoveItem(src, symbol, quantity) then
        xPlayer.addAccountMoney("bank", price)
        TriggerClientEvent("stock_exchange:notify", src, "success", "You sold " .. quantity .. " shares of " .. stock.itemLabel .. " for $" .. price)
    else
        TriggerClientEvent("stock_exchange:notify", src, "error", "You don't have enough stock to sell!")
    end
end)

-- Send stock prices to client
RegisterServerEvent("stock_exchange:getStockData")
AddEventHandler("stock_exchange:getStockData", function()
    local src = source
    TriggerClientEvent("stock_exchange:updatePrices", src, stockPrices)
end)
