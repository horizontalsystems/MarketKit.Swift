import GRDB
import ObjectMapper

public class Exchange: Record, ImmutableMappable {
    public let id: String
    public let name: String
    public let imageUrl: String

    override open class var databaseTableName: String {
        "exchanges"
    }

    enum Columns: String, ColumnExpression {
        case id, name, imageUrl
    }

    public required init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
        imageUrl = try map.value("image")

        super.init()
    }

    required init(row: Row) {
        id = row[Columns.id]
        name = row[Columns.name]
        imageUrl = row[Columns.imageUrl]

        super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.imageUrl] = imageUrl
    }
}

extension Exchange: CustomStringConvertible {

    public var description: String {
        "Exchange [id: \(id); name: \(name); imageUrl: \(imageUrl)]"
    }

}
