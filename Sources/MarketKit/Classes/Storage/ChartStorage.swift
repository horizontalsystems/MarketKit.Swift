import GRDB

class ChartStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try migrator.migrate(dbPool)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("Create Charts") { db in
            try db.create(table: ChartPointRecord.databaseTableName) { t in
                t.column(ChartPointRecord.Columns.coinUid.name, .text).notNull()
                t.column(ChartPointRecord.Columns.currencyCode.name, .text).notNull()
                t.column(ChartPointRecord.Columns.chartType.name, .integer).notNull()
                t.column(ChartPointRecord.Columns.timestamp.name, .double).notNull()
                t.column(ChartPointRecord.Columns.value.name, .text).notNull()
                t.column(ChartPointRecord.Columns.volume.name)

                t.primaryKey([ChartPointRecord.Columns.coinUid.name,
                              ChartPointRecord.Columns.currencyCode.name,
                              ChartPointRecord.Columns.chartType.name,
                              ChartPointRecord.Columns.timestamp.name,
                ], onConflict: .replace)
            }
        }

        return migrator
    }

}

extension ChartStorage {

    func chartPoints(key: ChartInfoKey) throws -> [ChartPoint] {
        try dbPool.read { db in
            try ChartPointRecord
                    .filter(ChartPointRecord.Columns.coinUid == key.coinUid && ChartPointRecord.Columns.currencyCode == key.currencyCode && ChartPointRecord.Columns.chartType == (key.periodType.rawValue))
                    .order(ChartPointRecord.Columns.timestamp).fetchAll(db)
                    .map { ChartPoint(timestamp: $0.timestamp, value: $0.value)
                            .added(field: ChartPoint.volume, value: $0.volume)
                    }
        }
    }

    func save(chartPoints: [ChartPointRecord]) throws {
        _ = try dbPool.write { db in
            for point in chartPoints {
                try point.insert(db)
            }
        }
    }

    func deleteChartPoints(key: ChartInfoKey) throws {
        _ = try dbPool.write { db in
            try ChartPointRecord
                    .filter(ChartPointRecord.Columns.coinUid == key.coinUid && ChartPointRecord.Columns.currencyCode == key.currencyCode && ChartPointRecord.Columns.chartType == (key.periodType.rawValue))
                    .deleteAll(db)
        }
    }

}
