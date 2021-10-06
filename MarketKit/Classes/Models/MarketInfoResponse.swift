import ObjectMapper

class MarketInfoResponse: CoinResponse {
    let price: Decimal
    let priceChange: Decimal?
    let marketCap: Decimal
    let totalVolume: Decimal

    required init(map: Map) throws {
        price = try map.value("price", using: Transform.stringToDecimalTransform)
        priceChange = try? map.value("price_change_24h", using: Transform.stringToDecimalTransform)
        marketCap = try map.value("market_cap", using: Transform.stringToDecimalTransform)
        totalVolume = try map.value("total_volume", using: Transform.stringToDecimalTransform)

        try super.init(map: map)
    }

    func marketInfo() -> MarketInfo {
        MarketInfo(
            coin: coin(),
            price: price,
            priceChange: priceChange,
            marketCap: marketCap,
            totalVolume: totalVolume
        )
    }

}
