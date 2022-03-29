import Foundation
import GRDB
import ObjectMapper

public class CoinCategoryMarketData: ImmutableMappable {
    public let uid: String
    public let marketCap: Decimal?
    public let diff24H: Decimal?
    public let diff1W: Decimal?
    public let diff1M: Decimal?

    public required init(map: Map) throws {
        uid = try map.value("uid")
        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        diff24H = try? map.value("change_24h", using: Transform.stringToDecimalTransform)
        diff1W = try? map.value("change_1w", using: Transform.stringToDecimalTransform)
        diff1M = try? map.value("change_1m", using: Transform.stringToDecimalTransform)
    }

}

extension CoinCategoryMarketData: CustomStringConvertible {

    public var description: String {
        "CoinCategoryMarketData [uid: \(uid); marketCap: \(marketCap); change24H: \(diff24H); change1W: \(diff1W); change1M: \(diff1M)]"
    }

}
