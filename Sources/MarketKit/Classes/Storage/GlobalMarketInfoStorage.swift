import GRDB

class GlobalMarketInfoStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create GlobalMarketInfo") { db in
            try db.create(table: GlobalMarketInfo.databaseTableName) { t in
                t.column(GlobalMarketInfo.Columns.currencyCode.name, .text).notNull()
                t.column(GlobalMarketInfo.Columns.timePeriod.name, .text).notNull()
                t.column(GlobalMarketInfo.Columns.points.name, .text).notNull()
                t.column(GlobalMarketInfo.Columns.timestamp.name, .double)

                t.primaryKey([GlobalMarketInfo.Columns.currencyCode.name, GlobalMarketInfo.Columns.timePeriod.name], onConflict: .replace)
            }
        }

        return migrator
    }
}

extension GlobalMarketInfoStorage {
    func globalMarketInfo(currencyCode: String, timePeriod: HsTimePeriod) throws -> GlobalMarketInfo? {
        try dbPool.read { db in
            try GlobalMarketInfo
                .filter(GlobalMarketInfo.Columns.currencyCode == currencyCode && GlobalMarketInfo.Columns.timePeriod == timePeriod.rawValue)
                .fetchOne(db)
        }
    }

    func save(globalMarketInfo: GlobalMarketInfo) throws {
        _ = try dbPool.write { db in
            try globalMarketInfo.insert(db)
        }
    }
}
