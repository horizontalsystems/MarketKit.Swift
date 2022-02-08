public enum HsTimePeriod: String {
    case day1 = "1d"
    case week1 = "1w"
    case week2 = "2w"
    case month1 = "1m"
    case month3 = "3m"
    case month6 = "6m"
    case year1 = "1y"

    public init(chartType: ChartType) {
        switch chartType {
        case .week: self = .week1
        case .week2: self = .week2
        case .month, .monthByDay: self = .month1
        case .month3: self = .month3
        case .halfYear: self = .month6
        case .year: self = .year1
        default: self = .day1
        }
    }
}
