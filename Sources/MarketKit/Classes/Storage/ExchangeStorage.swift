import GRDB

class ExchangeStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create Exchange") { db in
            try db.create(table: Exchange.databaseTableName) { t in
                t.column(Exchange.Columns.id.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(Exchange.Columns.name.name, .text).notNull()
                t.column(Exchange.Columns.imageUrl.name, .integer)
            }
        }

        migrator.registerMigration("Create Verified Exchange") { db in
            try db.create(table: VerifiedExchange.databaseTableName) { t in
                t.column(VerifiedExchange.Columns.uid.name, .text).notNull().primaryKey(onConflict: .replace)
            }
        }

        return migrator
    }
}

extension ExchangeStorage {
    func exchanges(ids: [String]) throws -> [Exchange] {
        try dbPool.read { db in
            try Exchange.filter(ids.contains(Exchange.Columns.id)).fetchAll(db)
        }
    }

    func update(exchanges: [Exchange]) throws {
        _ = try dbPool.write { db in
            try Exchange.deleteAll(db)

            for exchange in exchanges {
                try exchange.insert(db)
            }
        }
    }

    func verifiedExchanges() throws -> [VerifiedExchange] {
        try dbPool.read { db in
            try VerifiedExchange.fetchAll(db)
        }
    }

    func update(verifiedExchanges: [VerifiedExchange]) throws {
        _ = try dbPool.write { db in
            try VerifiedExchange.deleteAll(db)

            for verifiedExchange in verifiedExchanges {
                try verifiedExchange.insert(db)
            }
        }
    }
}
