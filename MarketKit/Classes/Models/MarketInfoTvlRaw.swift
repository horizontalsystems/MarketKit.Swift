import Foundation
import ObjectMapper

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    return dateFormatter
}()

class MarketInfoTvlRaw: ImmutableMappable {

    let timestamp: TimeInterval
    let tvl: Decimal

    required init(map: Map) throws {
        let date: String = try map.value("date")
        timestamp = dateFormatter.date(from: date)?.timeIntervalSince1970 ?? 0

//        let timestampInt: Int = try map.value("timestamp")
//        timestamp = TimeInterval(timestampInt)
        tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
    }

    var marketInfoTvl: ChartPoint {
        ChartPoint(timestamp: timestamp, value: tvl)
    }

}
