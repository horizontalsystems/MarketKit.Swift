import Foundation
import ObjectMapper

class CoinPriceStart: ImmutableMappable {
    let timestamp: TimeInterval

    init(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }

    required init(map: Map) throws {
        let timestampInt: Int = try map.value("timestamp")
        timestamp = TimeInterval(timestampInt)
    }

}
