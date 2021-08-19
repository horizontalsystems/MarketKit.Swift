import GRDB

public class Platform: Record, Decodable {
    static let coin = belongsTo(Coin.self)

    public let type: String
    public let value: String
    let coinUid: String

    enum Columns: String, ColumnExpression {
        case type, value, coinUid
    }

    public init(type: String, value: String, coinUid: String) {
        self.type = type
        self.value = value
        self.coinUid = coinUid

        super.init()
    }

    init(platformResponse: PlatformResponse, coinUid: String) {
        type = platformResponse.type
        value = platformResponse.value
        self.coinUid = coinUid

        super.init()
    }

    required init(row: Row) {
        type = row[Columns.type]
        value = row[Columns.value]
        coinUid = row[Columns.coinUid]

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "platform"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.type] = type
        container[Columns.value] = value
        container[Columns.coinUid] = coinUid
    }

}

extension Platform: CustomStringConvertible {

    public var description: String {
        "Platform [type: \(type); value: \(value); coinUid: \(coinUid)]"
    }

}
