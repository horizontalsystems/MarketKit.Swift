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
            try db.create(table: CoinPrice.databaseTableName) { t in
                t.column(ChartPoint.Columns.coinUid.name, .text).notNull()
                t.column(ChartPoint.Columns.currencyCode.name, .text).notNull()
                t.column(ChartPoint.Columns.chartType.name, .integer).notNull()
                t.column(ChartPoint.Columns.timestamp.name, .double).notNull()
                t.column(ChartPoint.Columns.value.name, .text).notNull()
                t.column(ChartPoint.Columns.volume.name)

                t.primaryKey([CoinPrice.Columns.coinUid.name, CoinPrice.Columns.currencyCode.name], onConflict: .replace)
            }
        }

        return migrator
    }

}

extension ChartStorage {

    func chartPoints(key: ChartInfoKey) -> [ChartPoint] {
        try! dbPool.read { db in
            try ChartPoint
                    .filter(ChartPoint.Columns.coinUid == key.coin.uid && ChartPoint.Columns.currencyCode == key.currencyCode && ChartPoint.Columns.chartType == key.chartType.rawValue)
                    .order(ChartPoint.Columns.timestamp).fetchAll(db)
        }
    }

    func save(chartPoints: [ChartPoint]) {
        _ = try! dbPool.write { db in
            for point in chartPoints {
                try point.insert(db)
            }
        }
    }

    func deleteChartPoints(key: ChartInfoKey) {
        _ = try! dbPool.write { db in
            try ChartPoint
                    .filter(ChartPoint.Columns.coinUid == key.coin.uid && ChartPoint.Columns.currencyCode == key.currencyCode && ChartPoint.Columns.chartType == key.chartType.rawValue)
                    .deleteAll(db)
        }
    }

}
