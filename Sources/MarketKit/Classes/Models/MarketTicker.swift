import Foundation
import ObjectMapper

public struct MarketTicker: ImmutableMappable {
    public let base: String
    public let target: String
    public let marketName: String
    public let marketImageUrl: String?
    public let rate: Decimal
    public let volume: Decimal
    public let tradeUrl: String?
    public let verified: Bool

    public init(map: Map) throws {
        base = try map.value("base")
        target = try map.value("target")
        marketName = try map.value("market_name")
        marketImageUrl = try? map.value("market_logo")
        rate = try map.value("price", using: Transform.stringToDecimalTransform)
        volume = try map.value("volume", using: Transform.stringToDecimalTransform)
        tradeUrl = try? map.value("trade_url")
        verified = try map.value("whitelisted")
    }
}
