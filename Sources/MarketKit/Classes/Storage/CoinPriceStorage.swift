import GRDB

class CoinPriceStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create CoinPrices") { db in
            try db.create(table: CoinPrice.databaseTableName) { t in
                t.column(CoinPrice.Columns.coinUid.name, .text).notNull()
                t.column(CoinPrice.Columns.currencyCode.name, .text).notNull()
                t.column(CoinPrice.Columns.value.name, .text)
                t.column(CoinPrice.Columns.diff.name, .double)
                t.column(CoinPrice.Columns.timestamp.name, .double)

                t.primaryKey([CoinPrice.Columns.coinUid.name, CoinPrice.Columns.currencyCode.name], onConflict: .replace)
            }
        }

        return migrator
    }

}

extension CoinPriceStorage {

    func coinPrice(coinUid: String, currencyCode: String) throws -> CoinPrice? {
        try dbPool.read { db in
            try CoinPrice.filter(CoinPrice.Columns.coinUid == coinUid && CoinPrice.Columns.currencyCode == currencyCode).fetchOne(db)
        }
    }

    func coinPrices(coinUids: [String], currencyCode: String) throws -> [CoinPrice] {
        try dbPool.read { db in
            try CoinPrice.filter(coinUids.contains(CoinPrice.Columns.coinUid) && CoinPrice.Columns.currencyCode == currencyCode).fetchAll(db)
        }
    }

    func coinPricesSortedByTimestamp(coinUids: [String], currencyCode: String) throws -> [CoinPrice] {
        try dbPool.read { db in
            try CoinPrice
                    .filter(coinUids.contains(CoinPrice.Columns.coinUid) && CoinPrice.Columns.currencyCode == currencyCode)
                    .order(CoinPrice.Columns.timestamp)
                    .fetchAll(db)
        }
    }

    func save(coinPrices: [CoinPrice]) throws {
        _ = try dbPool.write { db in
            for coinPrice in coinPrices {
                try coinPrice.insert(db)
            }
        }
    }

}
