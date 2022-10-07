import Foundation

struct HsChartRequestHelper {

    static func pointInterval(_ interval: HsTimePeriod) -> HsPointTimePeriod {
        switch interval {
        case .day1: return .minute30
        case .week1: return  .hour4
        case .week2: return  .hour8
        default: return .day1
        }
    }

    static func fromTimestamp(_ timestamp: TimeInterval, interval: HsTimePeriod, indicatorPoints: Int) -> TimeInterval {
        // time needed for build indicators
        let pointInterval = Self.pointInterval(interval)
        let additionalTime = TimeInterval(indicatorPoints) * pointInterval.interval

        return timestamp - interval.range - additionalTime
    }

}
