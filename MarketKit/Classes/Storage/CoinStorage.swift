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

}

extension CoinStorage {

    func marketCoins(filter: String, limit: Int) throws -> [MarketCoin] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.platforms)
                    .filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%"))
                    .order(Coin.Columns.marketCapRank.asc)
                    .limit(limit)

            return try MarketCoin.fetchAll(db, request)
        }
    }

    func marketCoins(coinUids: [String]) throws -> [MarketCoin] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.platforms)
                    .filter(coinUids.contains(Coin.Columns.uid))

            return try MarketCoin.fetchAll(db, request)
        }
    }

    func marketCoins(coinTypes: [CoinType]) throws -> [MarketCoin] {
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

            return try MarketCoin.fetchAll(db, request)
        }
    }

    func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try dbPool.read { db in
            let request = Platform
                    .including(required: Platform.coin)
                    .filter(Platform.Columns.coinType == coinType.id)

            return try PlatformCoin.fetchOne(db, request)
        }
    }

    func platformCoins() throws -> [PlatformCoin] {
        try dbPool.read { db in
            let request = Platform.including(required: Platform.coin)
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

    func save(marketCoins: [MarketCoin]) throws {
        _ = try dbPool.write { db in
            for marketCoin in marketCoins {
                try marketCoin.coin.insert(db)

                for platform in marketCoin.platforms {
                    try platform.insert(db)
                }
            }
        }
    }

    func save(coin: Coin, platform: Platform) throws {
        _ = try dbPool.write { db in
            try coin.insert(db)
            try platform.insert(db)
        }
    }

    func coins(filter: String, limit: Int) throws -> [Coin] {
        try dbPool.read { db in
            try Coin
                    .filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%"))
                    .order(Coin.Columns.marketCapRank.asc)
                    .limit(limit)
                    .fetchAll(db)
        }
    }

}
