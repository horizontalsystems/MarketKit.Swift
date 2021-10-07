public enum TimePeriod {
    case all
    case hour1
    case dayStart
    case hour24
    case day7
    case day14
    case day30
    case day200
    case year1

    public init(rawValue: String) {
        switch rawValue {
        case "All": self = .all
        case "1h": self =  .hour1
        case "DayStart": self =  .dayStart
        case "24h": self =  .hour24
        case "7d": self =  .day7
        case "14d": self =  .day14
        case "30d": self =  .day30
        case "200d": self =  .day200
        case "1y": self =  .year1
        default: self = .hour24
        }
    }

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
