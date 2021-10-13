import Foundation
import GRDB
import ObjectMapper

public class GlobalMarketInfo: Record {
    let currencyCode: String
    let timePeriod: TimePeriod
    public let points: [GlobalMarketPoint]
    let timestamp: TimeInterval

    enum Columns: String, ColumnExpression {
        case currencyCode, timePeriod, points, timestamp
    }

    override open class var databaseTableName: String {
        "globalMarketInfo"
    }

    init(currencyCode: String, timePeriod: TimePeriod, points: [GlobalMarketPoint]) {
        self.currencyCode = currencyCode
        self.timePeriod = timePeriod
        self.points = points
        timestamp = Date().timeIntervalSince1970

        super.init()
    }

    required init(row: Row) {
        currencyCode = row[Columns.currencyCode]
        timePeriod = TimePeriod(rawValue: row[Columns.timePeriod]) ?? .hour24
        points = [GlobalMarketPoint](JSONString: row[Columns.points]) ?? []
        timestamp = row[Columns.timestamp]

        super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.currencyCode] = currencyCode
        container[Columns.timePeriod] = timePeriod.rawValue
        container[Columns.points] = points.toJSONString()
        container[Columns.timestamp] = timestamp
    }

}
