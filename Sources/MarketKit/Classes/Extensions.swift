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
}
