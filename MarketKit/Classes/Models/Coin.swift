import GRDB

public class Coin: Record, Decodable {
    static let platforms = hasMany(Platform.self)

    public let uid: String
    public let name: String
    public let code: String
    public let decimal: Int
    public let marketCapRank: Int?
    public let coinGeckoId: String?

    enum Columns: String, ColumnExpression {
        case uid, name, code, decimal, marketCapRank, coinGeckoId
    }

    public init(uid: String, name: String, code: String, decimal: Int, marketCapRank: Int?, coinGeckoId: String?) {
        self.uid = uid
        self.name = name
        self.code = code
        self.decimal = decimal
        self.marketCapRank = marketCapRank
        self.coinGeckoId = coinGeckoId

        super.init()
    }

    init(coinResponse: CoinResponse) {
        uid = coinResponse.uid
        name = coinResponse.name
        code = coinResponse.code
        decimal = coinResponse.decimal
        marketCapRank = coinResponse.marketCapRank
        coinGeckoId = coinResponse.coinGeckoId

        super.init()
    }

    required public init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]
        code = row[Columns.code]
        decimal = row[Columns.decimal]
        marketCapRank = row[Columns.marketCapRank]
        coinGeckoId = row[Columns.coinGeckoId]

        super.init(row: row)
    }

    override open class var databaseTableName: String {
        "coin"
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.name] = name
        container[Columns.code] = code
        container[Columns.decimal] = decimal
        container[Columns.marketCapRank] = marketCapRank
        container[Columns.coinGeckoId] = coinGeckoId
    }

}

extension Coin: CustomStringConvertible {

    public var description: String {
        "Coin [uid: \(uid); name: \(name); code: \(code); decimal: \(decimal); marketCapRank: \(marketCapRank.map { "\($0)" } ?? "nil"); coinGeckoId: \(coinGeckoId.map { "\($0)" } ?? "nil")]"
    }

}

extension Coin: Equatable {

    public static func ==(lhs: Coin, rhs: Coin) -> Bool {
        lhs.uid == rhs.uid
    }

}
