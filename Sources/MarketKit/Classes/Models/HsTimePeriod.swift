import Foundation

public enum HsTimePeriod: String, CaseIterable {
    case day1 = "1d"
    case week1 = "1w"
    case week2 = "2w"
    case month1 = "1m"
    case month3 = "3m"
    case month6 = "6m"
    case year1 = "1y"
    case year2 = "2y"
    case year5 = "5y"

    var range: TimeInterval {
        switch self {
        case .day1: return .days(1)
        case .week1: return .days(7)
        case .week2: return .days(14)
        case .month1: return .days(30)
        case .month3: return .days(90)
        case .month6: return .days(180)
        case .year1: return .days(365)
        case .year2: return 2 * .days(365)
        case .year5: return 5 * .days(365)
        }
    }
}

extension HsTimePeriod: Comparable {
    public static func < (lhs: HsTimePeriod, rhs: HsTimePeriod) -> Bool {
        lhs.range < rhs.range
    }

    public static func == (lhs: HsTimePeriod, rhs: HsTimePeriod) -> Bool {
        lhs.range == rhs.range
    }
}
