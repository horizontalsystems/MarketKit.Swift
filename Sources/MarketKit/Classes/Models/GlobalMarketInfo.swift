import Foundation
import GRDB
import ObjectMapper

public class GlobalMarketInfo: Record {
    let currencyCode: String
    let timePeriod: HsTimePeriod
    public let points: [GlobalMarketPoint]
    let timestamp: TimeInterval

    enum Columns: String, ColumnExpression {
        case currencyCode, timePeriod, points, timestamp
    }

    override open class var databaseTableName: String {
        "globalMarketInfo"
    }

    init(currencyCode: String, timePeriod: HsTimePeriod, points: [GlobalMarketPoint]) {
        self.currencyCode = currencyCode
        self.timePeriod = timePeriod
        self.points = points
        timestamp = Date().timeIntervalSince1970

        super.init()
    }

    required init(row: Row) throws {
        currencyCode = row[Columns.currencyCode]
        timePeriod = HsTimePeriod(rawValue: row[Columns.timePeriod]) ?? .day1
        points = [GlobalMarketPoint](JSONString: row[Columns.points]) ?? []
        timestamp = row[Columns.timestamp]

        try super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) throws {
        container[Columns.currencyCode] = currencyCode
        container[Columns.timePeriod] = timePeriod.rawValue
        container[Columns.points] = points.toJSONString()
        container[Columns.timestamp] = timestamp
    }
}
