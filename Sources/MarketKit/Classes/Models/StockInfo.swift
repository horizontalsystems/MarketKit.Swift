import Foundation
import ObjectMapper

public struct StockInfo: ImmutableMappable {
    public let uid: String
    public let name: String
    public let symbol: String?
    public let price: Decimal?
    public let priceChange1d: Decimal?
    public let priceChange7d: Decimal?
    public let priceChange14d: Decimal?
    public let priceChange30d: Decimal?
    public let priceChange90d: Decimal?
    public let priceChange200d: Decimal?
    public let priceChange1y: Decimal?
    public let priceChange2y: Decimal?
    public let priceChange3y: Decimal?
    public let priceChange4y: Decimal?
    public let priceChange5y: Decimal?

    public init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        symbol = try? map.value("symbol")
        price = try? map.value("market_price", using: Transform.stringToDecimalTransform)

        priceChange1d = try? map.value("price_change.1d", using: Transform.stringToDecimalTransform)
        priceChange7d = try? map.value("price_change.7d", using: Transform.stringToDecimalTransform)
        priceChange14d = try? map.value("price_change.14d", using: Transform.stringToDecimalTransform)
        priceChange30d = try? map.value("price_change.30d", using: Transform.stringToDecimalTransform)
        priceChange90d = try? map.value("price_change.90d", using: Transform.stringToDecimalTransform)
        priceChange200d = try? map.value("price_change.200d", using: Transform.stringToDecimalTransform)
        priceChange1y = try? map.value("price_change.1y", using: Transform.stringToDecimalTransform)
        priceChange2y = try? map.value("price_change.2y", using: Transform.stringToDecimalTransform)
        priceChange3y = try? map.value("price_change.3y", using: Transform.stringToDecimalTransform)
        priceChange4y = try? map.value("price_change.4y", using: Transform.stringToDecimalTransform)
        priceChange5y = try? map.value("price_change.5y", using: Transform.stringToDecimalTransform)
    }
}
