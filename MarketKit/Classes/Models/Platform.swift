import GRDB

public class Platform: Record, Decodable {
    static let coin = belongsTo(Coin.self)

    public let coinType: CoinType
    public let decimal: Int
    let coinUid: String

    enum Columns: String, ColumnExpression {
        case coinType, decimal, coinUid
    }

    public init(coinType: CoinType, decimal: Int, coinUid: String) {
        self.coinType = coinType
        self.decimal = decimal
        self.coinUid = coinUid

        super.init()
    }

    init?(platformResponse: PlatformResponse, coinUid: String) {
        guard let coinType = CoinType(type: platformResponse.type, reference: platformResponse.reference) else {
            return nil
        }

        self.coinType = coinType
        decimal = platformResponse.decimal
        self.coinUid = coinUid

        super.init()
    }

    required init(row: Row) {
        coinType = CoinType(id: row[Columns.coinType])
        decimal = row[Columns.decimal]
        coinUid = row[Columns.coinUid]

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "platform"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.coinType] = coinType.id
        container[Columns.decimal] = decimal
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
        lhs.coinType == rhs.coinType && lhs.decimal == rhs.decimal && lhs.coinUid == rhs.coinUid
    }

}

extension Platform: CustomStringConvertible {

    public var description: String {
        "Platform [coinType: \(coinType); decimal: \(decimal); coinUid: \(coinUid)]"
    }

}
