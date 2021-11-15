import GRDB

class SyncerStateStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create Syncer States") { db in
            try db.create(table: SyncerState.databaseTableName) { t in
                t.column(SyncerState.Columns.key.name, .text).notNull().primaryKey(onConflict: .replace)
                t.column(SyncerState.Columns.value.name, .text).notNull()
            }
        }

        return migrator
    }

}

extension SyncerStateStorage {

    func value(key: String) throws -> String? {
        try dbPool.read { db in
            try SyncerState.filter(SyncerState.Columns.key == key).fetchOne(db)?.value
        }
    }

    func save(value: String, key: String) throws {
        _ = try dbPool.write { db in
            let syncerState = SyncerState(key: key, value: value)
            try syncerState.insert(db)
        }
    }

}
