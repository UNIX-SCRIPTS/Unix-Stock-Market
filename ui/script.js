window.addEventListener("message", function(event) {
    if (event.data.action === "open") {
        document.getElementById("stock-ui").style.display = "block";
    } else if (event.data.action === "close") {
        document.getElementById("stock-ui").style.display = "none";
    } else if (event.data.action === "update") {
        updateStocks(event.data.stocks);
    }
});

// Function to update stock list
function updateStocks(stocks) {
    let stockList = document.getElementById("stock-list");
    stockList.innerHTML = ""; // Clear previous stocks

    Object.keys(stocks).forEach(symbol => {
        let stock = stocks[symbol];
        if (!stock) return; // Prevent errors if stock is missing

        let price = stock.price || 0;
        let priceChange = stock.diff || 0;
        let color = stock.color || "#FFFFFF"; // Default white if missing
        let arrow = priceChange > 0 ? "🔺" : priceChange < 0 ? "🔻" : ""; // Green up or red down arrow

        let div = document.createElement("div");
        div.className = "stock-box";
        div.innerHTML = `
            <div class="stock-info">
                <h3 class="stock-name">${stock.marketName}</h3> <!-- Show Ox Label + Market Name -->
                <p class="stock-price">
                    <span class="cost-clas">COST</span> $${price.toFixed(2)} 
                    <span class="price-change" style="color: ${color}; margin-left: 1px;">
                        ${arrow} $${Math.abs(priceChange).toFixed(2)}
                    </span>
                </p>
            </div>
            <div class="stock-actions">
                <input type="number" id="buy-${symbol}" value="1" min="1" oninput="validateStockInput('${symbol}')">
                <button class="buy-btn" onclick="buyStock('${symbol}')">BUY</button>
                <button class="sell-btn" onclick="sellStock('${symbol}')">SELL</button>
            </div>
        `;
        stockList.appendChild(div);
    });
}


// Close UI when ESC key is pressed
document.addEventListener("keydown", function(event) {
    if (event.key === "Escape") {
        closeUI();
    }
});

function closeUI() {
    document.getElementById("stock-ui").style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

// Buy stock function
function buyStock(symbol) {
    let amount = parseInt(document.getElementById(`buy-${symbol}`).value);
    fetch(`https://${GetParentResourceName()}/buyStock`, {
        method: "POST",
        body: JSON.stringify({ symbol: symbol, amount: amount }),
        headers: { "Content-Type": "application/json" }
    });
}

// Sell stock function
function sellStock(symbol) {
    let amount = parseInt(document.getElementById(`buy-${symbol}`).value);
    fetch(`https://${GetParentResourceName()}/sellStock`, {
        method: "POST",
        body: JSON.stringify({ symbol: symbol, amount: amount }),
        headers: { "Content-Type": "application/json" }
    });
}
