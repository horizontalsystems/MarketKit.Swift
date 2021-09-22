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

}
