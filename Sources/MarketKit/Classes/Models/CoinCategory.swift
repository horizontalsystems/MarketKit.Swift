import Foundation
import ObjectMapper

public class CoinCategory: ImmutableMappable {
    public let uid: String
    public let name: String
    public let descriptions: [String: String]
    public let marketCap: Decimal?
    public let diff24H: Decimal?
    public let diff1W: Decimal?
    public let diff1M: Decimal?

    public required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        descriptions = try map.value("description")

        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        diff24H = try? map.value("change_24h", using: Transform.stringToDecimalTransform)
        diff1W = try? map.value("change_1w", using: Transform.stringToDecimalTransform)
        diff1M = try? map.value("change_1m", using: Transform.stringToDecimalTransform)
    }
}

public extension CoinCategory {
    func diff(timePeriod: HsTimePeriod) -> Decimal? {
        switch timePeriod {
        case .day1: return diff24H
        case .week1: return diff1W
        case .month1: return diff1M

        default: return diff24H
        }
    }
}

extension CoinCategory: CustomStringConvertible {
    public var description: String {
        "CoinCategory [uid: \(uid); name: \(name); descriptionCount: \(descriptions.count)]"
    }
}
