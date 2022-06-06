import GRDB
import ObjectMapper

class TokenRecord: Record, Decodable, ImmutableMappable {
    static let coin = belongsTo(Coin.self)
    static let blockchain = belongsTo(BlockchainRecord.self)

    let coinUid: String
    let blockchainUid: String
    let type: String
    let decimals: Int?
    let reference: String?

    override class var databaseTableName: String {
        "token"
    }

    enum Columns: String, ColumnExpression {
        case coinUid, blockchainUid, type, decimals, reference
    }

    init(coinUid: String, blockchainUid: String, type: String, decimals: Int? = nil, reference: String? = nil) {
        self.coinUid = coinUid
        self.blockchainUid = blockchainUid
        self.type = type
        self.decimals = decimals
        self.reference = reference

        super.init()
    }

    required init(map: Map) throws {
        let type: String = try map.value("type")

        coinUid = try map.value("coin_uid")
        blockchainUid = try map.value("blockchain_uid")
        self.type = type
        decimals = try? map.value("decimals")

        switch type {
        case "eip20": reference = try? map.value("address")
        case "bep2": reference = try? map.value("symbol")
        default: reference = try? map.value("address")
        }

        super.init()
    }

    func mapping(map: Map) {
        coinUid >>> map["coin_uid"]
        blockchainUid >>> map["blockchain_uid"]
        type >>> map["type"]
        decimals >>> map["decimals"]

        switch type {
        case "eip20": reference >>> map["address"]
        case "bep2": reference >>> map["symbol"]
        case "unsupported":
            if let reference = reference {
                reference >>> map["address"]
            }
        default: ()
        }
    }

    required init(row: Row) {
        coinUid = row[Columns.coinUid]
        blockchainUid = row[Columns.blockchainUid]
        type = row[Columns.type]
        decimals = row[Columns.decimals]
        reference = row[Columns.reference]

        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Columns.coinUid] = coinUid
        container[Columns.blockchainUid] = blockchainUid
        container[Columns.type] = type
        container[Columns.decimals] = decimals
        container[Columns.reference] = reference
    }

}
