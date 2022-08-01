import Foundation
import ObjectMapper

public class CategoryMarketPoint: ImmutableMappable {
    public let timestamp: TimeInterval
    public let marketCap: Decimal

    required public init(map: Map) throws {
        timestamp = try ((try? map.value("timestamp")) ?? (try map.value("date"))) //todo remove date afte API update
        marketCap = try map.value("market_cap", using: Transform.stringToDecimalTransform)
    }

}

extension CategoryMarketPoint: CustomStringConvertible {

    public var description: String {
        "CategoryMarketPoint [timestamp: \(timestamp); marketCap: \(marketCap)]"
    }

}
