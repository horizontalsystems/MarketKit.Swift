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

        migrator.registerMigration("createCoins") { db in
            try db.create(table: Coin.databaseTableName) { t in
                t.column(Coin.Columns.uid.name, .text).notNull()
                t.column(Coin.Columns.name.name, .text).notNull()
                t.column(Coin.Columns.code.name, .text).notNull()

                t.primaryKey([Coin.Columns.uid.name], onConflict: .replace)
            }
        }

        return migrator
    }

}

extension Storage {

    func coins(filter: String) throws -> [Coin] {
        try dbPool.read { db in
            try Coin
                    .filter(Coin.Columns.name.like("%\(filter)%") || Coin.Columns.code.like("%\(filter)%"))
                    .fetchAll(db)
        }
    }

    func save(coins: [Coin]) throws {
        _ = try dbPool.write { db in
            for coin in coins {
                try coin.insert(db)
            }
        }
    }

}
