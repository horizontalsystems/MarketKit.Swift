import GRDB
import ObjectMapper

public class CoinCategory: Record, ImmutableMappable {
    public let uid: String
    public let name: String
    public let descriptions: [String: String]

    enum Columns: String, ColumnExpression {
        case uid, name, descriptions
    }

    public required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        descriptions = try map.value("description")

        super.init()
    }

    required public init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]
        descriptions = (try? JSONSerialization.jsonObject(with: row[Columns.descriptions]) as? [String: String]) ?? [:]

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "coinCategory"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.descriptions] = try? JSONSerialization.data(withJSONObject: descriptions)
    }

}

extension CoinCategory: CustomStringConvertible {

    public var description: String {
        "CoinCategory [uid: \(uid); name: \(name); descriptionCount: \(descriptions.count)]"
    }

}
