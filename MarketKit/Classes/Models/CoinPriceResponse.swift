import Foundation
import ObjectMapper

struct CoinPriceResponse: ImmutableMappable {
    let price: Decimal
    let priceChange: Double
    let lastUpdated: TimeInterval

    init(map: Map) throws {
        price = try map.value("price", using: Self.stringToDecimalTransform)
        priceChange = try map.value("price_change")
        lastUpdated = try map.value("last_updated")
    }

    private static let stringToDecimalTransform: TransformOf<Decimal, String> = TransformOf(fromJSON: { string -> Decimal? in
        guard let string = string else { return nil }
        return Decimal(string: string)
    }, toJSON: { _ in nil })

}
