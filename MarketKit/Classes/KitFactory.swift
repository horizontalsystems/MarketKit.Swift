import HsToolKit
import GRDB

extension Kit {
    private static let dataDirectoryName = "market-kit"
    private static let databaseFileName = "market-kit"
    private static let hsApiBaseUrl = "http://10.0.1.40:3000/v1"

    public static func instance(minLogLevel: Logger.Level = .error) throws -> Kit {
        let logger = Logger(minLogLevel: minLogLevel)
        let reachabilityManager = ReachabilityManager()

        let databaseURL = try dataDirectoryUrl().appendingPathComponent("\(databaseFileName).sqlite")
        let dbPool = try DatabasePool(path: databaseURL.path)
        let coinStorage = try CoinStorage(dbPool: dbPool)
        let coinCategoryStorage = try CoinCategoryStorage(dbPool: dbPool)

        let networkManager = NetworkManager(logger: logger)

        let coinManager = CoinManager(storage: coinStorage)
        let coinCategoryManager = CoinCategoryManager(storage: coinCategoryStorage)

        let hsProvider = HsProvider(baseUrl: hsApiBaseUrl, networkManager: networkManager)

        let coinSyncer = CoinSyncer(hsProvider: hsProvider, coinManager: coinManager)
        let coinCategorySyncer = CoinCategorySyncer(hsProvider: hsProvider, coinCategoryManager: coinCategoryManager)

        return Kit(
                coinManager: coinManager,
                coinCategoryManager: coinCategoryManager,
                coinSyncer: coinSyncer,
                coinCategorySyncer: coinCategorySyncer
        )
    }

    private static func dataDirectoryUrl() throws -> URL {
        let fileManager = FileManager.default

        let url = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(dataDirectoryName, isDirectory: true)

        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        return url
    }

}
