import HsToolKit
import GRDB

extension Kit {
    private static let dataDirectoryName = "market-kit"
    private static let databaseFileName = "market-kit"

    public static func instance(hsApiBaseUrl: String, cryptoCompareApiKey: String? = nil, defiYieldApiKey: String? = nil, hsProviderApiKey: String? = nil, indicatorPoints: Int = 50, minLogLevel: Logger.Level = .error) throws -> Kit {
        let logger = Logger(minLogLevel: minLogLevel)
        let reachabilityManager = ReachabilityManager()
        let networkManager = NetworkManager(logger: logger)

        let databaseURL = try dataDirectoryUrl().appendingPathComponent("\(databaseFileName).sqlite")
        let dbPool = try DatabasePool(path: databaseURL.path)
        let coinStorage = try CoinStorage(dbPool: dbPool)
        let coinCategoryStorage = try CoinCategoryStorage(dbPool: dbPool)
        let coinCategoryManager = CoinCategoryManager(storage: coinCategoryStorage)

        let syncerStateStorage = try SyncerStateStorage(dbPool: dbPool)

        let coinGeckoProvider = CoinGeckoProvider(baseUrl: "https://api.coingecko.com/api/v3", networkManager: networkManager)
        let exchangeStorage = try ExchangeStorage(dbPool: dbPool)
        let exchangeManager = ExchangeManager(storage: exchangeStorage)
        let exchangeSyncer = ExchangeSyncer(exchangeManager: exchangeManager, coinGeckoProvider: coinGeckoProvider, syncerStateStorage: syncerStateStorage)

        let cryptoCompareProvider = CryptoCompareProvider(networkManager: networkManager, apiKey: cryptoCompareApiKey)
        let hsProvider = HsProvider(baseUrl: hsApiBaseUrl, networkManager: networkManager, apiKey: hsProviderApiKey)
        let defiYieldProvider = DefiYieldProvider(networkManager: networkManager, apiKey: defiYieldApiKey)

        let coinManager = CoinManager(storage: coinStorage, hsProvider: hsProvider, coinGeckoProvider: coinGeckoProvider, defiYieldProvider: defiYieldProvider, categoryManager: coinCategoryManager, exchangeManager: exchangeManager)

        let coinSyncer = CoinSyncer(coinManager: coinManager, hsProvider: hsProvider, syncerStateStorage: syncerStateStorage)
        let coinCategorySyncer = CoinCategorySyncer(coinCategoryManager: coinCategoryManager, hsProvider: hsProvider, syncerStateStorage: syncerStateStorage)

        let hsDataSyncer = HsDataSyncer(coinSyncer: coinSyncer, coinCategorySyncer: coinCategorySyncer, hsProvider: hsProvider)

        let coinPriceStorage = try CoinPriceStorage(dbPool: dbPool)
        let coinPriceManager = CoinPriceManager(storage: coinPriceStorage)
        let coinPriceSchedulerFactory = CoinPriceSchedulerFactory(manager: coinPriceManager, hsProvider: hsProvider, reachabilityManager: reachabilityManager, logger: logger)
        let coinPriceSyncManager = CoinPriceSyncManager(schedulerFactory: coinPriceSchedulerFactory)
        coinPriceManager.delegate = coinPriceSyncManager

        let coinHistoricalPriceStorage = try CoinHistoricalPriceStorage(dbPool: dbPool)
        let coinHistoricalPriceManager = CoinHistoricalPriceManager(storage: coinHistoricalPriceStorage, hsProvider: hsProvider)

        let chartStorage = try ChartStorage(dbPool: dbPool)
        let chartManager = ChartManager(coinManager: coinManager, storage: chartStorage, hsProvider: hsProvider, indicatorPoints: indicatorPoints)

        let chartSchedulerFactory = ChartSchedulerFactory(manager: chartManager, hsProvider: hsProvider, reachabilityManager: reachabilityManager, retryInterval: 30, indicatorPoints: indicatorPoints, logger: logger)
        let chartSyncManager = ChartSyncManager(coinManager: coinManager, schedulerFactory: chartSchedulerFactory, coinPriceSyncManager: coinPriceSyncManager)

        chartManager.delegate = chartSyncManager

        let postManager = PostManager(provider: cryptoCompareProvider)

        let globalMarketInfoStorage = try GlobalMarketInfoStorage(dbPool: dbPool)
        let globalMarketInfoManager = GlobalMarketInfoManager(provider: hsProvider, storage: globalMarketInfoStorage)

        return Kit(
                coinManager: coinManager,
                coinCategoryManager: coinCategoryManager,
                hsDataSyncer: hsDataSyncer,
                coinSyncer: coinSyncer,
                exchangeSyncer: exchangeSyncer,
                coinPriceManager: coinPriceManager,
                coinPriceSyncManager: coinPriceSyncManager,
                coinHistoricalPriceManager: coinHistoricalPriceManager,
                chartManager: chartManager,
                chartSyncManager: chartSyncManager,
                postManager: postManager,
                globalMarketInfoManager: globalMarketInfoManager
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
