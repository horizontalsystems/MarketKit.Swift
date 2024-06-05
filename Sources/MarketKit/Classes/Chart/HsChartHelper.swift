import Foundation

public enum HsChartHelper {
    static func pointInterval(_ interval: HsTimePeriod) -> HsPointTimePeriod {
        switch interval {
        case .day1, .hour24: return .minute30
        case .week1: return .hour4
        case .week2: return .hour8
        case .month1, .month3, .month6: return .day1
        case .year1, .year2: return .week1
        case .year5: return .month1
        }
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
            if yearCount >= 5 {
                intervals.append(.year5)
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
        if seconds <= .days(365) {
            return .day1
        }
        if seconds <= .days(5 * 365) {
            return .week1
        }
        return .month1
    }
}
