import Foundation
import GRDB

extension Decimal: DatabaseValueConvertible {

    public var databaseValue: DatabaseValue {
        NSDecimalNumber(decimal: self).stringValue.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Decimal? {
        guard case .string(let rawValue) = dbValue.storage else {
            return nil
        }
        return Decimal(string: rawValue)
    }

    init?(convertibleValue: Any?) {
        guard let convertibleValue = convertibleValue as? CustomStringConvertible,
              let value = Decimal.init(string: convertibleValue.description) else {
            return nil
        }

        self = value
    }

}

extension TimeInterval {

    public static func minutes(_ count: Self) -> Self {
        count * 60
    }

    public static func hours(_ count: Self) -> Self {
        count * minutes(60)
    }

    public static func days(_ count: Self) -> Self {
        count * hours(24)
    }

}
