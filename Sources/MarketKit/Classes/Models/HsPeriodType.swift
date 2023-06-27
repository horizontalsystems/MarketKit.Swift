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
               let timestamp = Int(chunks[1]) {

                self = .byStartTime(TimeInterval(timestamp))
                return
            } else if let period = HsTimePeriod(rawValue: String(chunks[0])),
                      let pointCount = Int(chunks[1]) {

                self = .byCustomPoints(period, pointCount)
                return
            }
        }
        self = .byPeriod(.day1)
    }

    public var rawValue: String {
        switch self {
        case .byPeriod(let interval): return interval.rawValue
        case .byStartTime(let timeStart): return [Self.keyAll, Int(timeStart).description].joined(separator: "_")
        case .byCustomPoints(let interval, let pointCount): return [interval.rawValue, pointCount.description].joined(separator: "_")
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .byPeriod(let interval): hasher.combine(interval)
        case .byStartTime(let startTime): hasher.combine(startTime)
        case .byCustomPoints(let interval, let pointCount):
            hasher.combine(interval)
            hasher.combine(pointCount)
        }
    }

    public static func ==(lhs: HsPeriodType, rhs: HsPeriodType) -> Bool {
        switch (lhs, rhs) {
        case (.byPeriod(let lhsPeriod), .byPeriod(let rhsPeriod)): return lhsPeriod == rhsPeriod
        case (.byStartTime(let lhsStartTime), .byStartTime(let rhsStartTime)): return lhsStartTime == rhsStartTime
        case (.byCustomPoints(let lhsI, let lhsC), .byCustomPoints(let rhsI, let rhsC)): return lhsI == rhsI && lhsC == rhsC
        default: return false
        }
    }

}
