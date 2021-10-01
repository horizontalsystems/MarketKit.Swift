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

        return migrator
    }

}

extension CoinCategoryStorage {

    func coinCategories() throws -> [CoinCategory] {
        try dbPool.read { db in
            try CoinCategory.fetchAll(db)
        }
    }

    func save(coinCategories: [CoinCategory]) throws {
        _ = try dbPool.write { db in
            for coinCategory in coinCategories {
                try coinCategory.insert(db)
            }
        }
    }

    func categories(uids: [String]) throws -> [CoinCategory] {
        try dbPool.read { db in
            try CoinCategory.filter(uids.contains(CoinCategory.Columns.uid)).fetchAll(db)
        }
    }

}
