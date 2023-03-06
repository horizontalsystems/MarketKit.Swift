import GRDB
import ObjectMapper

class BlockchainRecord: Record, Decodable, ImmutableMappable {
    static let tokens = hasMany(TokenRecord.self)

    let uid: String
    let name: String
    let eip3091url: String?

    override class var databaseTableName: String {
        "blockchain"
    }

    enum Columns: String, ColumnExpression {
        case uid, name, eip3091url
    }

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        eip3091url = try? map.value("eip3091_url")

        super.init()
    }

    func mapping(map: Map) {
        uid >>> map["uid"]
        name >>> map["name"]
        eip3091url >>> map["eip3091_url"]
    }

    required init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]
        eip3091url = row[Columns.eip3091url]

        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.eip3091url] = eip3091url
    }

    var blockchain: Blockchain {
        Blockchain(
                type: BlockchainType(uid: uid),
                name: name,
                eip3091url: eip3091url
        )
    }

}
