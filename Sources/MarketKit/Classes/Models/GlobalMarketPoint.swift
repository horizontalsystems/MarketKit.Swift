import Foundation
import ObjectMapper

public class GlobalMarketPoint: ImmutableMappable {
    public let timestamp: TimeInterval
    public let marketCap: Decimal
    public let volume24h: Decimal
    public let defiMarketCap: Decimal
    public let tvl: Decimal
    public let btcDominance: Decimal

    public required init(map: Map) throws {
        timestamp = try map.value("date")
        marketCap = try map.value("market_cap", using: Transform.stringToDecimalTransform)
        volume24h = try map.value("volume", using: Transform.stringToDecimalTransform)
        defiMarketCap = try map.value("defi_market_cap", using: Transform.stringToDecimalTransform)
        tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
        btcDominance = try map.value("btc_dominance", using: Transform.stringToDecimalTransform)
    }

    public func mapping(map: Map) {
        timestamp >>> map["date"]
        marketCap >>> (map["market_cap"], Transform.stringToDecimalTransform)
        volume24h >>> (map["volume"], Transform.stringToDecimalTransform)
        defiMarketCap >>> (map["defi_market_cap"], Transform.stringToDecimalTransform)
        tvl >>> (map["tvl"], Transform.stringToDecimalTransform)
        btcDominance >>> (map["btc_dominance"], Transform.stringToDecimalTransform)
    }
}

extension GlobalMarketPoint: CustomStringConvertible {
    public var description: String {
        "GlobalMarketInfo [timestamp: \(timestamp); marketCap: \(marketCap); volume24h: \(volume24h); defiMarketCap: \(defiMarketCap); tvl: \(tvl); btcDominance: \(btcDominance)]"
    }
}
