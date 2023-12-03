import Foundation
import GRDB

class CoinHistoricalPriceStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create CoinHistoricalPrices") { db in
            try db.create(table: CoinHistoricalPrice.databaseTableName) { t in
                t.column(CoinHistoricalPrice.Columns.coinUid.name, .text).notNull()
                t.column(CoinHistoricalPrice.Columns.currencyCode.name, .text).notNull()
                t.column(CoinHistoricalPrice.Columns.timestamp.name, .double).notNull()
                t.column(CoinHistoricalPrice.Columns.value.name, .text)

                t.primaryKey([CoinHistoricalPrice.Columns.coinUid.name, CoinHistoricalPrice.Columns.currencyCode.name, CoinHistoricalPrice.Columns.timestamp.name], onConflict: .replace)
            }
        }

        return migrator
    }
}

extension CoinHistoricalPriceStorage {
    func coinHistoricalPrice(coinUid: String, currencyCode: String, timestamp: TimeInterval) throws -> CoinHistoricalPrice? {
        try dbPool.read { db in
            try CoinHistoricalPrice
                .filter(CoinHistoricalPrice.Columns.coinUid == coinUid && CoinHistoricalPrice.Columns.currencyCode == currencyCode && CoinHistoricalPrice.Columns.timestamp == timestamp)
                .fetchOne(db)
        }
    }

    func save(coinHistoricalPrice: CoinHistoricalPrice) throws {
        _ = try dbPool.write { db in
            try coinHistoricalPrice.insert(db)
        }
    }
}
