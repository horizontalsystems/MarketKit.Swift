import GRDB

public class Platform: Record, Decodable {
    static let coin = belongsTo(Coin.self)

    public let coinType: CoinType
    public let decimals: Int
    let coinUid: String

    enum Columns: String, ColumnExpression {
        case coinType, decimals, coinUid
    }

    public init(coinType: CoinType, decimals: Int, coinUid: String) {
        self.coinType = coinType
        self.decimals = decimals
        self.coinUid = coinUid

        super.init()
    }

    required init(row: Row) {
        coinType = CoinType(id: row[Columns.coinType])
        decimals = row[Columns.decimals]
        coinUid = row[Columns.coinUid]

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "platform"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.coinType] = coinType.id
        container[Columns.decimals] = decimals
        container[Columns.coinUid] = coinUid
    }

}

extension Platform: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coinType)
        hasher.combine(coinUid)
    }

}

extension Platform: Equatable {

    public static func ==(lhs: Platform, rhs: Platform) -> Bool {
        lhs.coinType == rhs.coinType && lhs.decimals == rhs.decimals && lhs.coinUid == rhs.coinUid
    }

}

extension Platform: CustomStringConvertible {

    public var description: String {
        "Platform [coinType: \(coinType); decimals: \(decimals); coinUid: \(coinUid)]"
    }

}
