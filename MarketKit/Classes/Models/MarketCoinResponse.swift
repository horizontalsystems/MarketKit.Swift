import ObjectMapper

class MarketCoinResponse: CoinResponse {
    let price: Decimal
    let priceChange: Double?
    let marketCap: Int
    let totalVolume: Int

    required init(map: Map) throws {
        price = try map.value("price", using: Self.stringToDecimalTransform)
        priceChange = try? map.value("price_change_24h")
        marketCap = try map.value("market_cap")
        totalVolume = try map.value("total_volume")

        try super.init(map: map)
    }

    private static let stringToDecimalTransform: TransformOf<Decimal, String> = TransformOf(fromJSON: { string -> Decimal? in
        guard let string = string else { return nil }
        return Decimal(string: string)
    }, toJSON: { _ in nil })

}
