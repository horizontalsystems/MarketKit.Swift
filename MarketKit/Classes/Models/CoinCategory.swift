import Foundation
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
        case uid, name, descriptions, order, marketCap, change24H, change1W, change1M
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
        marketCap = row[Columns.marketCap]
        diff24H = row[Columns.change24H]
        diff1W = row[Columns.change1W]
        diff1M = row[Columns.change1M]

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
        container[Columns.marketCap] = marketCap
        container[Columns.change24H] = diff24H
        container[Columns.change1W] = diff1W
        container[Columns.change1M] = diff1M
    }

}

extension CoinCategory: CustomStringConvertible {

    public var description: String {
        "CoinCategory [uid: \(uid); name: \(name); descriptionCount: \(descriptions.count); order: \(order); marketCap: \(marketCap); change24H: \(diff24H); change1W: \(diff1W); change1M: \(diff1M)]"
    }

}
