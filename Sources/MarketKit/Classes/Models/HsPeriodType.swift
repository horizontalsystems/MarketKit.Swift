import Foundation

public enum HsPeriodType: Hashable {
    static let keyAll = "all"
    public static let day1 = Self.byPeriod(.day1)

    case byPeriod(HsTimePeriod)
    case byStartTime(TimeInterval)

    public init?(rawValue: String) {
        if let period = HsTimePeriod(rawValue: rawValue) {
            self = .byPeriod(period)
            return
        }
        let chunks = rawValue.split(separator: "_")
        if chunks.count == 2,
           chunks[0] == Self.keyAll,
           let timestamp = Int(chunks[1]) {

            self = .byStartTime(TimeInterval(timestamp))
            return
        }

        self = .byPeriod(.day1)
    }

    public var rawValue: String {
        switch self {
        case .byPeriod(let interval): return interval.rawValue
        case .byStartTime(let timeStart): return [Self.keyAll, Int(timeStart).description].joined(separator: "_")
        }
    }

    public var expiration: TimeInterval {
        switch self {
        case .byPeriod(let period): return period.expiration
        case .byStartTime: return .days(7)  //todo: expiration == timeinterval from request
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .byPeriod(let period): hasher.combine(period)
        case .byStartTime(let startTime): hasher.combine(startTime)
        }
    }

    public static func ==(lhs: HsPeriodType, rhs: HsPeriodType) -> Bool {
        switch (lhs, rhs) {
        case (.byPeriod(let lhsPeriod), .byPeriod(let rhsPeriod)): return lhsPeriod == rhsPeriod
        case (.byStartTime(let lhsStartTime), .byStartTime(let rhsStartTime)): return lhsStartTime == rhsStartTime
        default: return false
        }
    }

}
