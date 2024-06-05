import Foundation

extension Decimal {
    init?(convertibleValue: Any?) {
        guard let convertibleValue = convertibleValue as? CustomStringConvertible,
              let value = Decimal(string: convertibleValue.description)
        else {
            return nil
        }

        self = value
    }
}

public extension TimeInterval {
    static func minutes(_ count: Self) -> Self {
        count * 60
    }

    static func hours(_ count: Self) -> Self {
        count * minutes(60)
    }

    static func days(_ count: Self) -> Self {
        count * hours(24)
    }

    static func midnightUTC() -> Self {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)

        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: now)

        components.hour = 0
        components.minute = 0
        components.second = 0

        guard let todayMidnightUTC = calendar.date(from: components) else {
            return 0
        }

        return todayMidnightUTC.timeIntervalSince1970
    }
}
