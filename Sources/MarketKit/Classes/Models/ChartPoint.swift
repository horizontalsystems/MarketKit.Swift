import Foundation
import GRDB

public class ChartPoint {
    public let timestamp: TimeInterval
    public let value: Decimal
    public var volume: Decimal?

    public init(timestamp: TimeInterval, value: Decimal, volume: Decimal? = nil) {
        self.timestamp = timestamp
        self.value = value
        self.volume = volume
    }
}

extension ChartPoint: Equatable {
    public static func == (lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        lhs.timestamp == rhs.timestamp && lhs.value == rhs.value && lhs.volume == rhs.volume
    }
}

public struct AggregatedChartPoints {
    public let points: [ChartPoint]
    public let aggregatedValue: Decimal?

    public init(points: [ChartPoint], aggregatedValue: Decimal?) {
        self.points = points
        self.aggregatedValue = aggregatedValue
    }
}
