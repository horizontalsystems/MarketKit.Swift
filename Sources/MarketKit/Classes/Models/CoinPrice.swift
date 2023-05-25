import Foundation
import GRDB

public class CoinPrice: Record {
    static let expirationInterval: TimeInterval = 240

    public let coinUid: String
    public let currencyCode: String
    public let value: Decimal
    public let diff: Decimal?
    public let timestamp: TimeInterval

    enum Columns: String, ColumnExpression, CaseIterable {
        case coinUid, currencyCode, value, diff, timestamp
    }

    init(coinUid: String, currencyCode: String, value: Decimal, diff: Decimal?, timestamp: TimeInterval) {
        self.coinUid = coinUid
        self.currencyCode = currencyCode
        self.value = value
        self.diff = diff
        self.timestamp = timestamp

        super.init()
    }

    override open class var databaseTableName: String {
        "coinPrice"
    }

    required init(row: Row) throws {
        coinUid = row[Columns.coinUid]
        currencyCode = row[Columns.currencyCode]
        value = row[Columns.value]
        diff = row[Columns.diff]
        timestamp = row[Columns.timestamp]

        try super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) throws {
        container[Columns.coinUid] = coinUid
        container[Columns.currencyCode] = currencyCode
        container[Columns.value] = value
        container[Columns.diff] = diff
        container[Columns.timestamp] = timestamp
    }

    public var expired: Bool {
        Date().timeIntervalSince1970 - timestamp > Self.expirationInterval
    }

}

extension CoinPrice: CustomStringConvertible {

    public var description: String {
        "CoinPrice [coinUid: \(coinUid); currencyCode: \(currencyCode); value: \(value); diff: \(diff.map { "\($0)" } ?? "nil"); timestamp: \(timestamp)]"
    }

}
