import GRDB

class CoinStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create Coins, Blockchains and Tokens") { db in
            if try db.tableExists("coin") {
                try db.drop(table: "coin")
            }
            if try db.tableExists("platform") {
                try db.drop(table: "platform")
            }

            try db.create(table: Coin.databaseTableName) { t in
                t.column(Coin.Columns.uid.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(Coin.Columns.name.name, .text).notNull()
                t.column(Coin.Columns.code.name, .text).notNull()
                t.column(Coin.Columns.marketCapRank.name, .integer)
                t.column(Coin.Columns.coinGeckoId.name, .text)
            }

            try db.create(table: BlockchainRecord.databaseTableName) { t in
                t.column(BlockchainRecord.Columns.uid.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(BlockchainRecord.Columns.name.name, .text).notNull()
            }

            try db.create(table: TokenRecord.databaseTableName) { t in
                t.column(TokenRecord.Columns.coinUid.name, .text).notNull().indexed().references(Coin.databaseTableName, onDelete: .cascade)
                t.column(TokenRecord.Columns.blockchainUid.name, .text).notNull().indexed().references(BlockchainRecord.databaseTableName, onDelete: .cascade)
                t.column(TokenRecord.Columns.type.name, .text).notNull()
                t.column(TokenRecord.Columns.decimals.name, .integer)
                t.column(TokenRecord.Columns.reference.name, .text)

                t.primaryKey([TokenRecord.Columns.coinUid.name, TokenRecord.Columns.blockchainUid.name, TokenRecord.Columns.type.name], onConflict: .replace)
            }
        }

        migrator.registerMigration("Add 'explorerUrl' column to Blockchains") { db in
            try db.alter(table: BlockchainRecord.databaseTableName) { t in
                t.add(column: "explorerUrl", .text)
            }
        }

        migrator.registerMigration("Rename 'explorerUrl' column to 'eip3091url' in Blockchains") { db in
            try db.alter(table: BlockchainRecord.databaseTableName) { t in
                t.rename(column: "explorerUrl", to: BlockchainRecord.Columns.eip3091url.name)
            }

            try BlockchainRecord.updateAll(db, BlockchainRecord.Columns.eip3091url.set(to: nil))
        }

        return migrator
    }

    private func searchOrder(filter: String) -> SQL {
        SQL(sql: """
                 CASE WHEN \(Coin.databaseTableName).\(Coin.Columns.code) LIKE ? THEN 1 
                 WHEN \(Coin.databaseTableName).\(Coin.Columns.code) LIKE ? THEN 2 
                 WHEN \(Coin.databaseTableName).\(Coin.Columns.name) LIKE ? THEN 3
                 ELSE 4 END,
                 CASE WHEN \(Coin.databaseTableName).\(Coin.Columns.marketCapRank) IS NULL THEN 1 ELSE 0 END,
                 \(Coin.databaseTableName).\(Coin.Columns.marketCapRank) ASC, 
                 \(Coin.databaseTableName).\(Coin.Columns.name) ASC
                 """,
                arguments: [filter, "\(filter)%", "\(filter)%"]
        )
    }

    private func filter(tokenQuery: TokenQuery) -> SQLSpecificExpressible {
        let (type, reference) = tokenQuery.tokenType.values

        var conditions: [SQLSpecificExpressible] = [
            TokenRecord.Columns.blockchainUid == tokenQuery.blockchainType.uid,
            TokenRecord.Columns.type == type
        ]

        if let reference = reference {
            conditions.append(TokenRecord.Columns.reference.like(reference))
        }

        return conditions.joined(operator: .and)
    }

}

extension CoinStorage {

    func coinsCount() throws -> Int {
        try dbPool.read { db in
            try Coin.fetchCount(db)
        }
    }

    func coin(uid: String) throws -> Coin? {
        try dbPool.read { db in
            try Coin.filter(Coin.Columns.uid == uid).fetchOne(db)
        }
    }

    func coins(uids: [String]) throws -> [Coin] {
        try dbPool.read { db in
            try Coin.filter(uids.contains(Coin.Columns.uid)).fetchAll(db)
        }
    }

    func coinTokenRecords(filter: String, limit: Int) throws -> [CoinTokensRecord] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.tokens.including(required: TokenRecord.blockchain))
                    .filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%"))
                    .order(literal: searchOrder(filter: filter))
                    .limit(limit)

            return try CoinTokensRecord.fetchAll(db, request)
        }
    }

    func coinTokenRecord(uid: String) throws -> CoinTokensRecord? {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.tokens.including(required: TokenRecord.blockchain))
                    .filter(Coin.Columns.uid == uid)

            return try CoinTokensRecord.fetchOne(db, request)
        }
    }

    func coinTokenRecords(coinUids: [String]) throws -> [CoinTokensRecord] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.tokens.including(required: TokenRecord.blockchain))
                    .filter(coinUids.contains(Coin.Columns.uid))

            return try CoinTokensRecord.fetchAll(db, request)
        }
    }

    func tokenInfoRecord(query: TokenQuery) throws -> TokenInfoRecord? {
        try dbPool.read { db in
            let request = TokenRecord
                    .including(required: TokenRecord.coin)
                    .including(required: TokenRecord.blockchain)
                    .filter(filter(tokenQuery: query))

            return try TokenInfoRecord.fetchOne(db, request)
        }
    }

    func tokenInfoRecords(queries: [TokenQuery]) throws -> [TokenInfoRecord] {
        try dbPool.read { db in
            let request = TokenRecord
                    .including(required: TokenRecord.coin)
                    .including(required: TokenRecord.blockchain)
                    .filter(queries.map { filter(tokenQuery: $0) }.joined(operator: .or))

            return try TokenInfoRecord.fetchAll(db, request)
        }
    }

    func tokenInfoRecords(reference: String) throws -> [TokenInfoRecord] {
        try dbPool.read { db in
            let request = TokenRecord
                    .including(required: TokenRecord.coin)
                    .including(required: TokenRecord.blockchain)
                    .filter(TokenRecord.Columns.reference.like(reference))

            return try TokenInfoRecord.fetchAll(db, request)
        }
    }

    func tokenInfoRecords(blockchainType: BlockchainType, filter: String, limit: Int) throws -> [TokenInfoRecord] {
        try dbPool.read { db in
            let request = TokenRecord
                    .including(required: TokenRecord.coin.filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%")))
                    .including(required: TokenRecord.blockchain.filter(BlockchainRecord.Columns.uid == blockchainType.uid))
                    .order(literal: searchOrder(filter: filter))
                    .limit(limit)

            return try TokenInfoRecord.fetchAll(db, request)
        }
    }

    func blockchain(uid: String) throws -> BlockchainRecord? {
        try dbPool.read { db in
            try BlockchainRecord.filter(BlockchainRecord.Columns.uid == uid).fetchOne(db)
        }
    }

    func blockchains(uids: [String]) throws -> [BlockchainRecord] {
        try dbPool.read { db in
            try BlockchainRecord.filter(uids.contains(BlockchainRecord.Columns.uid)).fetchAll(db)
        }
    }

    func allCoins() throws -> [Coin] {
        try dbPool.read { db in
            try Coin.fetchAll(db)
        }
    }

    func allBlockchainRecords() throws -> [BlockchainRecord] {
        try dbPool.read { db in
            try BlockchainRecord.fetchAll(db)
        }
    }

    func allTokenRecords() throws -> [TokenRecord] {
        try dbPool.read { db in
            try TokenRecord.fetchAll(db)
        }
    }

    func update(coins: [Coin], blockchainRecords: [BlockchainRecord], tokenRecords: [TokenRecord]) throws {
        _ = try dbPool.write { db in
            try Coin.deleteAll(db)
            try BlockchainRecord.deleteAll(db)
            try TokenRecord.deleteAll(db)

            for coin in coins {
                try coin.insert(db)
            }
            for blockchainRecord in blockchainRecords {
                try blockchainRecord.insert(db)
            }
            for tokenRecord in tokenRecords {
                try? tokenRecord.insert(db)
            }
        }
    }

}

struct CoinTokensRecord: FetchableRecord, Decodable {
    let coin: Coin
    let tokens: [TokenBlockchainRecord]

    var fullCoin: FullCoin {
        FullCoin(
                coin: coin,
                tokens: tokens.map { record in
                    let tokenType: TokenType

                    if record.token.decimals != nil {
                        tokenType = TokenType(type: record.token.type, reference: record.token.reference)
                    } else {
                        tokenType = .unsupported(type: record.token.type, reference: record.token.reference)
                    }

                    return Token(
                            coin: coin,
                            blockchain: record.blockchain.blockchain,
                            type: tokenType,
                            decimals: record.token.decimals ?? 0
                    )
                }
        )
    }

}

struct TokenBlockchainRecord: FetchableRecord, Decodable {
    let token: TokenRecord
    let blockchain: BlockchainRecord
}

struct TokenInfoRecord: FetchableRecord, Decodable {
    let tokenRecord: TokenRecord
    let coin: Coin
    let blockchain: BlockchainRecord

    var token: Token {
        let tokenType: TokenType

        if tokenRecord.decimals != nil {
            tokenType = TokenType(type: tokenRecord.type, reference: tokenRecord.reference)
        } else {
            tokenType = .unsupported(type: tokenRecord.type, reference: tokenRecord.reference)
        }

        return Token(
                coin: coin,
                blockchain: blockchain.blockchain,
                type: tokenType,
                decimals: tokenRecord.decimals ?? 0
        )
    }

}
