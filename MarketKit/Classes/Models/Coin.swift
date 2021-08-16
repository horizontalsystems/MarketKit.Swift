import GRDB
import ObjectMapper

public class Coin: Record, ImmutableMappable {
    public let uid: String
    public let name: String
    public let code: String

    enum Columns: String, ColumnExpression {
        case uid, name, code
    }

    init(uid: String, name: String, code: String) {
        self.uid = uid
        self.name = name
        self.code = code

        super.init()
    }

    required public init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]
        code = row[Columns.code]

        super.init(row: row)
    }

    required public init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        code = try map.value("code")

        super.init()
    }

    override open class var databaseTableName: String {
        "coins"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.code] = code
    }

}

extension Coin: CustomStringConvertible {

    public var description: String {
        "Coin [uid: \(uid); name: \(name); code: \(code)]"
    }

}

extension Coin: Equatable {

    public static func ==(lhs: Coin, rhs: Coin) -> Bool {
        lhs.uid == rhs.uid
    }

}
