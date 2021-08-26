import GRDB
import ObjectMapper

public class CoinCategory: Record, ImmutableMappable {
    public let uid: String
    public let name: String
    public let descriptions: [CoinCategoryDescription]

    enum Columns: String, ColumnExpression {
        case uid, name, descriptions
    }

    public required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        descriptions = try map.value("descriptions")

        super.init()
    }

    required public init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]

        if let jsonString: String = row[Columns.descriptions], let descriptions = [CoinCategoryDescription](JSONString: jsonString) {
            self.descriptions = descriptions
        } else {
            descriptions = []
        }

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "coinCategory"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.descriptions] = descriptions.toJSONString()
    }

}

extension CoinCategory: CustomStringConvertible {

    public var description: String {
        "CoinCategory [uid: \(uid); name: \(name); descriptionCount: \(descriptions.count)]"
    }

}
