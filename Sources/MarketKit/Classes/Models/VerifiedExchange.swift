import GRDB
import ObjectMapper

class VerifiedExchange: Record, ImmutableMappable {
    let uid: String

    init(uid: String) {
        self.uid = uid
        super.init()
    }

    override open class var databaseTableName: String {
        "VerifiedExchange"
    }

    enum Columns: String, ColumnExpression {
        case uid
    }

    required init(map: Map) throws {
        uid = try map.value("uid")

        super.init()
    }

    required init(row: Row) throws {
        uid = row[Columns.uid]

        try super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) throws {
        container[Columns.uid] = uid
    }
}
