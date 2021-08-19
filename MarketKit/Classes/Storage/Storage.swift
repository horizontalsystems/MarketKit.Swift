import GRDB

class Storage {
    private let dbPool: DatabasePool

    init(dataDirectoryUrl: URL, databaseFileName: String) throws {
        let databaseURL = dataDirectoryUrl.appendingPathComponent("\(databaseFileName).sqlite")
        dbPool = try DatabasePool(path: databaseURL.path)
        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create Coins and Platforms") { db in
            try db.create(table: Coin.databaseTableName) { t in
                t.column(Coin.Columns.uid.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(Coin.Columns.name.name, .text).notNull()
                t.column(Coin.Columns.code.name, .text).notNull()
                t.column(Coin.Columns.decimal.name, .integer).notNull()
            }

            try db.create(table: Platform.databaseTableName) { t in
                t.column(Platform.Columns.type.name, .text).notNull()
                t.column(Platform.Columns.value.name, .text).notNull()
                t.column(Platform.Columns.coinUid.name, .text).notNull().indexed().references(Coin.databaseTableName, onDelete: .cascade)

                t.primaryKey([Platform.Columns.type.name, Platform.Columns.value.name, Platform.Columns.coinUid.name], onConflict: .replace)
            }
        }

        return migrator
    }

}

extension Storage {

    func marketCoins(filter: String, limit: Int) throws -> [MarketCoin] {
        try dbPool.read { db in
            let request = Coin
                    .including(all: Coin.platforms)
                    .filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%"))
                    .limit(limit)

            return try MarketCoin.fetchAll(db, request)
        }
    }

    func platformWithCoin(reference: String) throws -> PlatformWithCoin? {
        try dbPool.read { db in
            let request = Platform
                    .including(required: Platform.coin)
                    .filter(Platform.Columns.value.like(reference))

            return try PlatformWithCoin.fetchOne(db, request)
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

}
