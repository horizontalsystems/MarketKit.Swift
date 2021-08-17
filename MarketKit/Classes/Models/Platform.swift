import GRDB

public class Platform: Record, Decodable {
    static let coin = belongsTo(Coin.self)

    public let uid: String
    public let value: String
    let coinUid: String

    enum Columns: String, ColumnExpression {
        case uid, value, coinUid
    }

    init(platformResponse: PlatformResponse, coinUid: String) {
        uid = platformResponse.uid
        value = platformResponse.value
        self.coinUid = coinUid

        super.init()
    }

    required init(row: Row) {
        uid = row[Columns.uid]
        value = row[Columns.value]
        coinUid = row[Columns.coinUid]

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "platform"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.value] = value
        container[Columns.coinUid] = coinUid
    }

}

extension Platform: CustomStringConvertible {

    public var description: String {
        "Platform [uid: \(uid); value: \(value); coinUid: \(coinUid)]"
    }

}
