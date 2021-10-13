import Foundation
import ObjectMapper

public class GlobalMarketPoint: ImmutableMappable {
    public let timestamp: TimeInterval
    public let marketCap: Decimal
    public let volume24h: Decimal
    public let marketCapDefi: Decimal
    public let tvl: Decimal
    public let dominanceBtc: Decimal

    required public init(map: Map) throws {
        timestamp = try map.value("timestamp")
        marketCap = try map.value("market_cap", using: Transform.doubleToDecimalTransform)
        volume24h = try map.value("volume24h", using: Transform.doubleToDecimalTransform)
        marketCapDefi = try map.value("market_cap_defi", using: Transform.doubleToDecimalTransform)
        tvl = try map.value("tvl", using: Transform.doubleToDecimalTransform)
        dominanceBtc = try map.value("dominance_btc", using: Transform.doubleToDecimalTransform)
    }

    public func mapping(map: Map) {
        timestamp >>> map["timestamp"]
        marketCap >>> (map["market_cap"], Transform.doubleToDecimalTransform)
        volume24h >>> (map["volume24h"], Transform.doubleToDecimalTransform)
        marketCapDefi >>> (map["market_cap_defi"], Transform.doubleToDecimalTransform)
        tvl >>> (map["tvl"], Transform.doubleToDecimalTransform)
        dominanceBtc >>> (map["dominance_btc"], Transform.doubleToDecimalTransform)
    }

}

extension GlobalMarketPoint: CustomStringConvertible {

    public var description: String {
        "GlobalMarketInfo [timestamp: \(timestamp); marketCap: \(marketCap); volume24h: \(volume24h); marketCapDefi: \(marketCapDefi); tvl: \(tvl); dominanceBtc: \(dominanceBtc)]"
    }

}
