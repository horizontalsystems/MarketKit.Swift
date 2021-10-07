import ObjectMapper

class MarketInfoRaw: ImmutableMappable {
    let uid: String
    let price: Decimal
    let priceChange: Decimal?
    let marketCap: Decimal
    let totalVolume: Decimal?

    required init(map: Map) throws {
        uid = try map.value("uid")
        price = try map.value("price", using: Transform.stringToDecimalTransform)
        priceChange = try? map.value("price_change_24h", using: Transform.stringToDecimalTransform)
        marketCap = try map.value("market_cap", using: Transform.stringToDecimalTransform)
        totalVolume = try? map.value("total_volume", using: Transform.stringToDecimalTransform)
    }

    func marketInfo(fullCoin: FullCoin) -> MarketInfo {
        MarketInfo(
            fullCoin: fullCoin,
            price: price,
            priceChange: priceChange,
            marketCap: marketCap,
            totalVolume: totalVolume
        )
    }

}
