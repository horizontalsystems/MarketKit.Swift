import Foundation

public struct HsChartHelper {

    static func pointInterval(_ interval: HsTimePeriod) -> HsPointTimePeriod {
        switch interval {
        case .day1: return .minute30
        case .week1: return  .hour4
        case .week2: return  .hour8
        case .year2: return .week1
        default: return .day1
        }
    }

    static func fromTimestamp(_ timestamp: TimeInterval, interval: HsTimePeriod, indicatorPoints: Int) -> TimeInterval {
        // time needed for build indicators
        let pointInterval = Self.pointInterval(interval)
        let additionalTime = TimeInterval(indicatorPoints) * pointInterval.interval

        return timestamp - interval.range - additionalTime
    }

    public static func validIntervals(startTime: TimeInterval?) -> [HsTimePeriod] {
        guard let startTime else { return HsTimePeriod.allCases }
        let genesisDate = Date(timeIntervalSince1970: startTime)
        let dayCount = Calendar.current.dateComponents([.day], from: genesisDate, to: Date()).day
        let monthCount = Calendar.current.dateComponents([.month], from: genesisDate, to: Date()).month
        let yearCount = Calendar.current.dateComponents([.year], from: genesisDate, to: Date()).year

        var intervals = [HsTimePeriod.day1]
        if let dayCount {
            if dayCount >= 7 {
                intervals.append(.week1)
            }
            if dayCount >= 14 {
                intervals.append(.week2)
            }
        }
        if let monthCount {
            if monthCount >= 1 {
                intervals.append(.month1)
            }
            if monthCount >= 3 {
                intervals.append(.month3)
            }
            if monthCount >= 6 {
                intervals.append(.month6)
            }
        }
        if let yearCount {
            if yearCount >= 1 {
                intervals.append(.year1)
            }
            if yearCount >= 2 {
                intervals.append(.year2)
            }
        }

        return intervals
    }

    static func intervalForAll(genesisTime: TimeInterval) -> HsPointTimePeriod {
        let seconds = Date().timeIntervalSince1970 - genesisTime
        if seconds <= .days(1) {
            return .minute30
        }
        if seconds <= .days(7) {
            return .hour4
        }
        if seconds <= .days(14) {
            return .hour8
        }
        if seconds <= .days(2 * 365) {
            return .day1
        }
        return .week1
    }

}
