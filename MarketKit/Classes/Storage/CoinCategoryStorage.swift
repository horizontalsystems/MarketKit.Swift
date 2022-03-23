import GRDB

class CoinCategoryStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create CoinCategories") { db in
            try db.create(table: CoinCategory.databaseTableName) { t in
                t.column(CoinCategory.Columns.uid.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(CoinCategory.Columns.name.name, .text).notNull()
                t.column(CoinCategory.Columns.descriptions.name, .blob)
            }
        }

        migrator.registerMigration("Add 'order' field") { db in
            try db.alter(table: CoinCategory.databaseTableName) { t in
                t.add(column: CoinCategory.Columns.order.name, .integer).notNull().defaults(to: 0)
            }
        }

        migrator.registerMigration("Add stats fields") { db in
            try db.alter(table: CoinCategory.databaseTableName) { t in
                t.add(column: CoinCategory.Columns.marketCap.name, .text)
                t.add(column: CoinCategory.Columns.change24H.name, .text)
                t.add(column: CoinCategory.Columns.change1W.name, .text)
                t.add(column: CoinCategory.Columns.change1M.name, .text)
            }
        }

        return migrator
    }

}

extension CoinCategoryStorage {

    func coinCategories() throws -> [CoinCategory] {
        try dbPool.read { db in
            try CoinCategory.order(CoinCategory.Columns.order.asc).fetchAll(db)
        }
    }

    func coinCategories(uids: [String]) throws -> [CoinCategory] {
        try dbPool.read { db in
            try CoinCategory.filter(uids.contains(CoinCategory.Columns.uid)).fetchAll(db)
        }
    }

    func coinCategory(uid: String) throws -> CoinCategory? {
        try dbPool.read { db in
            try CoinCategory.filter(CoinCategory.Columns.uid == uid).fetchOne(db)
        }
    }

    func update(coinCategories: [CoinCategory]) throws {
        _ = try dbPool.write { db in
            try CoinCategory.deleteAll(db)

            for coinCategory in coinCategories {
                try coinCategory.insert(db)
            }
        }
    }

}
