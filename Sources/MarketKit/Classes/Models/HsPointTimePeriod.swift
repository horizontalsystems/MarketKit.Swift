import Foundation

enum HsPointTimePeriod: String {
    case minute30 = "30m"
    case hour1 = "1h"
    case hour4 = "4h"
    case hour8 = "8h"
    case day1 = "1d"
    case week1 = "1w"

    var interval: TimeInterval {
        switch self {
        case .minute30: return .minutes(30)
        case .hour1: return .hours(1)
        case .hour4: return .hours(4)
        case .hour8: return .hours(8)
        case .day1: return .days(1)
        case .week1: return .days(7)
        }
    }

}
