import Foundation

public enum HsPeriodType: Hashable {
    static let keyAll = "all"

    case byPeriod(HsTimePeriod)
    case byCustomPoints(HsTimePeriod, Int)
    case byStartTime(TimeInterval)

    public init?(rawValue: String) {
        if let period = HsTimePeriod(rawValue: rawValue) {
            self = .byPeriod(period)
            return
        }
        let chunks = rawValue.split(separator: "_")
        if chunks.count == 2 {
            if chunks[0] == Self.keyAll,
               let timestamp = Int(chunks[1])
            {
                self = .byStartTime(TimeInterval(timestamp))
                return
            } else if let period = HsTimePeriod(rawValue: String(chunks[0])),
                      let pointCount = Int(chunks[1])
            {
                self = .byCustomPoints(period, pointCount)
                return
            }
        }
        self = .byPeriod(.day1)
    }

    public var rawValue: String {
        switch self {
        case let .byPeriod(interval): return interval.rawValue
        case let .byStartTime(timeStart): return [Self.keyAll, Int(timeStart).description].joined(separator: "_")
        case let .byCustomPoints(interval, pointCount): return [interval.rawValue, pointCount.description].joined(separator: "_")
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .byPeriod(interval): hasher.combine(interval)
        case let .byStartTime(startTime): hasher.combine(startTime)
        case let .byCustomPoints(interval, pointCount):
            hasher.combine(interval)
            hasher.combine(pointCount)
        }
    }

    public static func == (lhs: HsPeriodType, rhs: HsPeriodType) -> Bool {
        switch (lhs, rhs) {
        case let (.byPeriod(lhsPeriod), .byPeriod(rhsPeriod)): return lhsPeriod == rhsPeriod
        case let (.byStartTime(lhsStartTime), .byStartTime(rhsStartTime)): return lhsStartTime == rhsStartTime
        case let (.byCustomPoints(lhsI, lhsC), .byCustomPoints(rhsI, rhsC)): return lhsI == rhsI && lhsC == rhsC
        default: return false
        }
    }
}
