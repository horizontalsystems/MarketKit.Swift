import Foundation
import ObjectMapper

class MarketInfoTvlRaw: ImmutableMappable {

    let timestamp: TimeInterval
    let tvl: Decimal

    required init(map: Map) throws {
        let timestampInt: Int = try map.value("date")
        timestamp = TimeInterval(timestampInt)
        tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
    }

    var marketInfoTvl: ChartPoint {
        ChartPoint(timestamp: timestamp, value: tvl)
    }

}
