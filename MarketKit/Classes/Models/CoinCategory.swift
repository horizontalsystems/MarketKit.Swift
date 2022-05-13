import GRDB
import ObjectMapper

public class CoinCategory: Record, ImmutableMappable {
    public let uid: String
    public let name: String
    public let descriptions: [String: String]
    public let order: Int
    public let marketCap: Decimal?
    public let diff24H: Decimal?
    public let diff1W: Decimal?
    public let diff1M: Decimal?


    enum Columns: String, ColumnExpression {
        case uid, name, descriptions, order
    }

    public required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        descriptions = try map.value("description")
        order = try map.value("order")

        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        diff24H = try? map.value("change_24h", using: Transform.stringToDecimalTransform)
        diff1W = try? map.value("change_1w", using: Transform.stringToDecimalTransform)
        diff1M = try? map.value("change_1m", using: Transform.stringToDecimalTransform)

        super.init()
    }

    required public init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]
        descriptions = (try? JSONSerialization.jsonObject(with: row[Columns.descriptions]) as? [String: String]) ?? [:]
        order = row[Columns.order]

        marketCap = nil
        diff24H = nil
        diff1W = nil
        diff1M = nil

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "coinCategory"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.descriptions] = try? JSONSerialization.data(withJSONObject: descriptions)
        container[Columns.order] = order
    }

}

extension CoinCategory: CustomStringConvertible {

    public func diff(timePeriod: HsTimePeriod) -> Decimal? {
        switch timePeriod {
        case .day1: return diff24H
        case .week1: return diff1W
        case .month1: return diff1M

        default: return diff24H
        }
    }

    public var description: String {
        "CoinCategory [uid: \(uid); name: \(name); descriptionCount: \(descriptions.count); order: \(order)]"
    }

}
