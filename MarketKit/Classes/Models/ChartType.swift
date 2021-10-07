public enum ChartType: Int, CaseIterable {
    case today
    case day
    case week
    case week2
    case month
    case month3
    case halfYear
    case year
    case year2

    var expirationInterval: TimeInterval {
        let multiplier: TimeInterval

        switch resource {
        case "histominute": multiplier = 60
        case "histohour": multiplier = 60 * 60
        case "histoday": multiplier = 24 * 60 * 60
        default: multiplier = 60
        }

        return TimeInterval(interval) * multiplier
    }

    var rangeInterval: TimeInterval {
        expirationInterval * TimeInterval(pointCount)
    }

    var interval: Int {
        switch self {
        case .today: return 30
        case .day: return 30
        case .week: return 4
        case .week2: return 8
        case .month: return 12
        case .month3: return 2
        case .halfYear: return 3
        case .year: return 7
        case .year2: return 14
        }
    }

    var resource: String {
        switch self {
        case .today: return "histominute"
        case .day: return "histominute"
        case .week: return "histohour"
        case .week2: return "histohour"
        case .month: return "histohour"
        case .month3: return "histoday"
        case .halfYear: return "histoday"
        case .year: return "histoday"
        case .year2: return "histoday"
        }
    }

    var pointCount: Int {
        switch self {
        case .today: return 48
        case .day: return 48
        case .week: return 48
        case .week2: return 45
        case .month: return 60
        case .month3: return 45
        case .halfYear: return 60
        case .year: return 52
        case .year2: return 52
        }
    }

    var coinGeckoPointCount: Int {
        switch self {
        case .today, .day: return pointCount
        default: return pointCount * 2
        }
    }

    var coinGeckoDaysParameter: Int {
        switch self {
        case .today: return 1
        case .day: return 1
        case .week: return 7 * 2
        case .week2: return 14 * 2
        case .month: return 30 * 2
        case .month3: return 90 * 2
        case .halfYear: return 180 * 2
        case .year: return 360 * 2
        case .year2: return 720 * 2
        }
    }

    var intervalInSeconds: TimeInterval {
        switch self {
        case .today: return TimeInterval(interval * 60)              // 30 minutes
        case .day: return TimeInterval(interval * 60)                // 30 minutes
        case .week: return TimeInterval(interval * 60 * 60)          // 4 hours
        case .week2: return TimeInterval(interval * 60 * 60)         // 8 hours
        case .month: return TimeInterval(interval * 60 * 60)         // 12 hours
        case .month3: return TimeInterval(interval * 24 * 60 * 60)   // 2 days
        case .halfYear: return TimeInterval(interval * 24 * 60 * 60) // 3 days
        case .year: return TimeInterval(interval * 24 * 60 * 60)     // 7 days
        case .year2: return TimeInterval(interval * 24 * 60 * 60)    // 14 days
        }
    }

}
