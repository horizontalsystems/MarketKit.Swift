import GRDB

public class Coin: Record, Decodable {
    static let platforms = hasMany(Platform.self)

    public let uid: String
    public let name: String
    public let code: String
    public let decimal: Int

    enum Columns: String, ColumnExpression {
        case uid, name, code, decimal
    }

    public init(uid: String, name: String, code: String, decimal: Int) {
        self.uid = uid
        self.name = name
        self.code = code
        self.decimal = decimal

        super.init()
    }

    init(coinResponse: CoinResponse) {
        uid = coinResponse.uid
        name = coinResponse.name
        code = coinResponse.code
        decimal = coinResponse.decimal

        super.init()
    }

    required public init(row: Row) {
        uid = row[Columns.uid]
        name = row[Columns.name]
        code = row[Columns.code]
        decimal = row[Columns.decimal]

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
    }

}

extension Coin: CustomStringConvertible {

    public var description: String {
        "Coin [uid: \(uid); name: \(name); code: \(code); decimal: \(decimal)]"
    }

}

extension Coin: Equatable {

    public static func ==(lhs: Coin, rhs: Coin) -> Bool {
        lhs.uid == rhs.uid
    }

}
