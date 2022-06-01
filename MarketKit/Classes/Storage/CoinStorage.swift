import GRDB

class CoinStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create Coins and Platforms") { db in
            try db.create(table: Coin.databaseTableName) { t in
                t.column(Coin.Columns.uid.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(Coin.Columns.name.name, .text).notNull()
                t.column(Coin.Columns.code.name, .text).notNull()
                t.column(Coin.Columns.marketCapRank.name, .integer)
                t.column(Coin.Columns.coinGeckoId.name, .text)
            }

            try db.create(table: Platform.databaseTableName) { t in
                t.column(Platform.Columns.coinType.name, .text).notNull()
                t.column(Platform.Columns.decimals.name, .integer).notNull()
                t.column(Platform.Columns.coinUid.name, .text).notNull().indexed().references(Coin.databaseTableName, onDelete: .cascade)

                t.primaryKey([Platform.Columns.coinType.name, Platform.Columns.coinUid.name], onConflict: .replace)
            }
        }

        return migrator
    }

    private func searchOrder(filter: String) -> SQL {
        SQL(sql: """
                 CASE WHEN \(Coin.Columns.code) LIKE ? THEN 1 
                 WHEN \(Coin.Columns.code) LIKE ? THEN 2 
                 WHEN \(Coin.Columns.name) LIKE ? THEN 3
                 ELSE 4 END,
                 CASE WHEN \(Coin.Columns.marketCapRank) IS NULL THEN 1 ELSE 0 END,
                 \(Coin.Columns.marketCapRank) ASC, 
                 \(Coin.Columns.name) ASC
                 """,
                arguments: [filter, "\(filter)%", "\(filter)%"]
        )
    }

}

extension CoinStorage {

    func coinsCount() throws -> Int {
        try dbPool.read { db in
            try Coin.fetchCount(db)
        }
    }

    func fullCoins(filter: String, limit: Int) throws -> [FullCoin] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.platforms)
                    .filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%"))
                    .order(literal: searchOrder(filter: filter))
                    .limit(limit)

            return try FullCoin.fetchAll(db, request)
        }
    }

    func coins(coinUids: [String]) throws -> [Coin] {
        try dbPool.read { db in
            try Coin
                    .filter(coinUids.contains(Coin.Columns.uid))
                    .fetchAll(db)
        }
    }

    func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.platforms)
                    .filter(coinUids.contains(Coin.Columns.uid))

            return try FullCoin.fetchAll(db, request)
        }
    }

    func fullCoins(coinTypes: [CoinType]) throws -> [FullCoin] {
        try dbPool.read { db in
            let coinTypeIds = coinTypes.map { $0.id }

            let platformRequest = Platform
                    .including(required: Platform.coin)
                    .filter(coinTypeIds.contains(Platform.Columns.coinType))

            let platformCoins = try PlatformCoin.fetchAll(db, platformRequest)
            let coinUids = platformCoins.map { $0.coin.uid }

            let request = Coin
                    .including(all: Coin.platforms)
                    .filter(coinUids.contains(Coin.Columns.uid))

            return try FullCoin.fetchAll(db, request)
        }
    }

    func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try dbPool.read { db in
            let request = Platform
                    .including(required: Platform.coin)
                    .filter(Platform.Columns.coinType.lowercased == coinType.id.lowercased())

            return try PlatformCoin.fetchOne(db, request)
        }
    }

    func platformCoins(platformType: PlatformType, filter: String, limit: Int) throws -> [PlatformCoin] {
        try dbPool.read { db in
            let request = Platform
                    .including(required: Platform.coin.filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%")))
                    .filter(Platform.Columns.coinType == platformType.baseCoinType.id || Platform.Columns.coinType.like("\(platformType.evmCoinTypeIdPrefix)%"))
                    .order(literal: searchOrder(filter: filter))
                    .limit(limit)

            return try PlatformCoin.fetchAll(db, request)
        }
    }

    func platformCoins(coinTypeIds: [String]) throws -> [PlatformCoin] {
        try dbPool.read { db in
            let request = Platform
                    .including(required: Platform.coin)
                    .filter(coinTypeIds.contains(Platform.Columns.coinType))

            return try PlatformCoin.fetchAll(db, request)
        }
    }

    func update(fullCoins: [FullCoin]) throws {
        _ = try dbPool.write { db in
            try Coin.deleteAll(db)
            try Platform.deleteAll(db)

            for fullCoin in fullCoins {
                try fullCoin.coin.insert(db)

                for platform in fullCoin.platforms {
                    try platform.insert(db)
                }
            }
        }
    }

    func coin(uid: String) throws -> Coin? {
        try dbPool.read { db in
            try Coin
                    .filter(Coin.Columns.uid == uid)
                    .fetchOne(db)
        }
    }

}
