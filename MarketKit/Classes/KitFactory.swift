import HsToolKit
import GRDB

extension Kit {
    private static let dataDirectoryName = "market-kit"
    private static let databaseFileName = "market-kit"

    public static func instance(hsApiBaseUrl: String, cryptoCompareApiKey: String? = nil, minLogLevel: Logger.Level = .error) throws -> Kit {
        let logger = Logger(minLogLevel: minLogLevel)
        let reachabilityManager = ReachabilityManager()
        let networkManager = NetworkManager(logger: logger)

        let databaseURL = try dataDirectoryUrl().appendingPathComponent("\(databaseFileName).sqlite")
        let dbPool = try DatabasePool(path: databaseURL.path)
        let coinStorage = try CoinStorage(dbPool: dbPool)
        let coinCategoryStorage = try CoinCategoryStorage(dbPool: dbPool)
        let coinCategoryManager = CoinCategoryManager(storage: coinCategoryStorage)

        let coinGeckoProvider = CoinGeckoProvider(baseUrl: "https://api.coingecko.com/api/v3", networkManager: networkManager)
        let exchangeStorage = try ExchangeStorage(dbPool: dbPool)
        let exchangeManager = ExchangeManager(storage: exchangeStorage)
        let exchangeSyncer = ExchangeSyncer(exchangeManager: exchangeManager, coinGeckoProvider: coinGeckoProvider)

        let cryptoCompareProvider = CryptoCompareProvider(networkManager: networkManager, apiKey: cryptoCompareApiKey)
        let hsProvider = HsProvider(baseUrl: hsApiBaseUrl, networkManager: networkManager)
        
        let coinManager = CoinManager(storage: coinStorage, hsProvider: hsProvider, coinGeckoProvider: coinGeckoProvider, categoryManager: coinCategoryManager, exchangeManager: exchangeManager)

        let coinSyncer = CoinSyncer(coinManager: coinManager, hsProvider: hsProvider)
        let coinCategorySyncer = CoinCategorySyncer(hsProvider: hsProvider, coinCategoryManager: coinCategoryManager)

        let coinPriceStorage = try CoinPriceStorage(dbPool: dbPool)
        let coinPriceManager = CoinPriceManager(storage: coinPriceStorage)
        let coinPriceSchedulerFactory = CoinPriceSchedulerFactory(manager: coinPriceManager, hsProvider: hsProvider, reachabilityManager: reachabilityManager, logger: logger)
        let coinPriceSyncManager = CoinPriceSyncManager(schedulerFactory: coinPriceSchedulerFactory)
        coinPriceManager.delegate = coinPriceSyncManager

        let chartStorage = try ChartStorage(dbPool: dbPool)
        let chartManager = ChartManager(coinManager: coinManager, storage: chartStorage, coinPriceManager: coinPriceManager)

        let chartSchedulerFactory = ChartSchedulerFactory(manager: chartManager, provider: coinGeckoProvider, reachabilityManager: reachabilityManager, retryInterval: 30, logger: logger)
        let chartSyncManager = ChartSyncManager(coinManager: coinManager, schedulerFactory: chartSchedulerFactory, chartInfoManager: chartManager, coinPriceSyncManager: coinPriceSyncManager)

        let postManager = PostManager(provider: cryptoCompareProvider)

        return Kit(
                coinManager: coinManager,
                coinCategoryManager: coinCategoryManager,
                coinSyncer: coinSyncer,
                coinCategorySyncer: coinCategorySyncer,
                exchangeSyncer: exchangeSyncer,
                coinPriceManager: coinPriceManager,
                coinPriceSyncManager: coinPriceSyncManager,
                chartManager: chartManager,
                chartSyncManager: chartSyncManager,
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
