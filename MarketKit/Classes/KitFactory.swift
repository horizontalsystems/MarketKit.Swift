import HsToolKit
import GRDB

extension Kit {
    private static let dataDirectoryName = "market-kit"
    private static let databaseFileName = "market-kit"

    public static func instance(hsApiBaseUrl: String, cryptoCompareApiKey: String? = nil, minLogLevel: Logger.Level = .error) throws -> Kit {
        let logger = Logger(minLogLevel: minLogLevel)
        let reachabilityManager = ReachabilityManager()

        let databaseURL = try dataDirectoryUrl().appendingPathComponent("\(databaseFileName).sqlite")
        let dbPool = try DatabasePool(path: databaseURL.path)
        let coinStorage = try CoinStorage(dbPool: dbPool)
        let coinCategoryStorage = try CoinCategoryStorage(dbPool: dbPool)
        let coinCategoryManager = CoinCategoryManager(storage: coinCategoryStorage)

        let networkManager = NetworkManager(logger: logger)

        let cryptoCompareProvider = CryptoCompareProvider(networkManager: networkManager, apiKey: cryptoCompareApiKey)
        let hsProvider = HsProvider(baseUrl: hsApiBaseUrl, networkManager: networkManager)
        
        let coinManager = CoinManager(storage: coinStorage, hsProvider: hsProvider, categoryManager: coinCategoryManager)

        let coinSyncer = CoinSyncer(coinManager: coinManager)
        let coinCategorySyncer = CoinCategorySyncer(hsProvider: hsProvider, coinCategoryManager: coinCategoryManager)

        let coinPriceStorage = try CoinPriceStorage(dbPool: dbPool)
        let coinPriceManager = CoinPriceManager(storage: coinPriceStorage)
        let coinPriceSchedulerFactory = CoinPriceSchedulerFactory(manager: coinPriceManager, coinManager: coinManager, provider: hsProvider, reachabilityManager: reachabilityManager, logger: logger)
        let coinPriceSyncManager = CoinPriceSyncManager(schedulerFactory: coinPriceSchedulerFactory)
        coinPriceManager.delegate = coinPriceSyncManager

        let postManager = PostManager(provider: cryptoCompareProvider)

        return Kit(
                coinManager: coinManager,
                coinCategoryManager: coinCategoryManager,
                coinSyncer: coinSyncer,
                coinCategorySyncer: coinCategorySyncer,
                coinPriceManager: coinPriceManager,
                coinPriceSyncManager: coinPriceSyncManager,
                postManager: postManager
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
