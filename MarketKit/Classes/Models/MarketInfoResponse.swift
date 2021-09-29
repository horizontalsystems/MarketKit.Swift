import ObjectMapper

class MarketInfoResponse: CoinResponse {
    let price: Decimal
    let priceChange: Decimal?
    let marketCap: Decimal
    let totalVolume: Decimal

    required init(map: Map) throws {
        price = try map.value("price", using: Self.stringToDecimalTransform)
        priceChange = try? map.value("price_change_24h", using: Self.stringToDecimalTransform)
        marketCap = try map.value("market_cap", using: Self.stringToDecimalTransform)
        totalVolume = try map.value("total_volume", using: Self.stringToDecimalTransform)

        try super.init(map: map)
    }

    private static let stringToDecimalTransform: TransformOf<Decimal, String> = TransformOf(fromJSON: { string -> Decimal? in
        guard let string = string else { return nil }
        return Decimal(string: string)
    }, toJSON: { _ in nil })

}
