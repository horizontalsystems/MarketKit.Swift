import Foundation
import GRDB

public class ChartPoint: Record {
    public let coinUid: String
    public let currencyCode: String
    public let chartType: ChartType
    public let timestamp: TimeInterval
    public let value: Decimal
    public let volume: Decimal?

    public init(coinUid: String, currencyCode: String, chartType: ChartType, timestamp: TimeInterval, value: Decimal, volume: Decimal?) {
        self.coinUid = coinUid
        self.currencyCode = currencyCode
        self.chartType = chartType
        self.timestamp = timestamp
        self.value = value
        self.volume = volume

        super.init()
    }

    override open class var databaseTableName: String {
        "chart_points"
    }

    enum Columns: String, ColumnExpression {
        case coinUid, currencyCode, chartType, timestamp, value, volume
    }

    required init(row: Row) {
        coinUid = row[Columns.coinUid]
        currencyCode = row[Columns.currencyCode]
        chartType = ChartType(rawValue: row[Columns.chartType]) ?? .day
        timestamp = row[Columns.timestamp]
        value = row[Columns.value]
        volume = row[Columns.volume]

        super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.coinUid] = coinUid
        container[Columns.currencyCode] = currencyCode
        container[Columns.chartType] = chartType.rawValue
        container[Columns.timestamp] = timestamp
        container[Columns.value] = value
        container[Columns.volume] = volume
    }

}

extension ChartPoint: Equatable {

    public static func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        lhs.timestamp == rhs.timestamp && lhs.value == rhs.value
    }

}
