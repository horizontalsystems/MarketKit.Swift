import GRDB
import ObjectMapper

class BlockchainRecord: Record, Decodable, ImmutableMappable {
    static let tokens = hasMany(TokenRecord.self)

    let uid: String
    let name: String

    override class var databaseTableName: String {
        "blockchain"
    }

    enum Columns: String, ColumnExpression {
        case uid, name
    }

    init(uid: String, name: String) {
        self.uid = uid
        self.name = name

        super.init()
    }

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")

        super.init()
    }

    func mapping(map: Map) {
        uid >>> map["uid"]
        name >>> map["name"]
    }

    required init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]

        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
    }

    var blockchain: Blockchain {
        Blockchain(
                type: BlockchainType(uid: uid),
                name: name
        )
    }

}
