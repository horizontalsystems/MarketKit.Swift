import GRDB
import ObjectMapper

class BlockchainRecord: Record, Decodable, ImmutableMappable {
    static let tokens = hasMany(TokenRecord.self)

    let uid: String
    let name: String
    let explorerUrl: String?

    override class var databaseTableName: String {
        "blockchain"
    }

    enum Columns: String, ColumnExpression {
        case uid, name, explorerUrl
    }

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        explorerUrl = try? map.value("url")

        super.init()
    }

    func mapping(map: Map) {
        uid >>> map["uid"]
        name >>> map["name"]
        explorerUrl >>> map["url"]
    }

    required init(row: Row) throws {
        uid = row[Columns.uid]
        name = row[Columns.name]
        explorerUrl = row[Columns.explorerUrl]

        try super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) throws {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.explorerUrl] = explorerUrl
    }

    var blockchain: Blockchain {
        Blockchain(
                type: BlockchainType(uid: uid),
                name: name,
                explorerUrl: explorerUrl
        )
    }

}
