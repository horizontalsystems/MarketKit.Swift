public enum TimePeriod: String {
    case all = "All"
    case hour1 = "1h"
    case dayStart = "DayStart"
    case hour24 = "24h"
    case day7 = "7d"
    case day14 = "14d"
    case day30 = "30d"
    case day200 = "200d"
    case year1 = "1y"

    public init(chartType: ChartType) {
        switch chartType {
        case .today: self = .dayStart
        case .day: self = .hour24
        case .week: self = .day7
        case .week2: self = .day14
        case .month: self = .day30
        case .halfYear: self = .day200
        case .year: self = .year1
        default: self = .hour24
        }
    }

}
