import Foundation
import ObjectMapper

public struct MarketPair: ImmutableMappable {
    public let base: String
    public let target: String
    public let marketName: String
    public let marketImageUrl: String?
    public let rank: Int
    public let volume: Decimal?
    public let price: Decimal?
    public let tradeUrl: String?

    public init(map: Map) throws {
        base = try map.value("base")
        target = try map.value("target")
        marketName = try map.value("market_name")
        marketImageUrl = try? map.value("market_logo")
        rank = try map.value("rank")
        volume = try? map.value("volume", using: Transform.stringToDecimalTransform)
        price = try? map.value("price", using: Transform.stringToDecimalTransform)
        tradeUrl = try? map.value("trade_url")
    }

    public var uid: String {
        "\(base) \(target) \(marketName)"
    }
}
