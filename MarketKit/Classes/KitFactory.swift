import HsToolKit
import GRDB

extension Kit {
    private static let dataDirectoryName = "market-kit"
    private static let databaseFileName = "market-kit"

    public static func instance(hsApiBaseUrl: String, hsOldApiBaseUrl: String, cryptoCompareApiKey: String? = nil, defiYieldApiKey: String? = nil, minLogLevel: Logger.Level = .error) throws -> Kit {
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
        let hsOldProvider = HsOldProvider(baseUrl: hsOldApiBaseUrl, networkManager: networkManager)
        let defiYieldProvider = DefiYieldProvider(networkManager: networkManager, apiKey: defiYieldApiKey)

        let coinManager = CoinManager(storage: coinStorage, hsProvider: hsProvider, hsOldProvider: hsOldProvider, coinGeckoProvider: coinGeckoProvider, defiYieldProvider: defiYieldProvider, categoryManager: coinCategoryManager, exchangeManager: exchangeManager)

        let coinSyncer = CoinSyncer(coinManager: coinManager, hsProvider: hsProvider)
        let coinCategorySyncer = CoinCategorySyncer(hsProvider: hsProvider, coinCategoryManager: coinCategoryManager)

        let coinPriceStorage = try CoinPriceStorage(dbPool: dbPool)
        let coinPriceManager = CoinPriceManager(storage: coinPriceStorage)
        let coinPriceSchedulerFactory = CoinPriceSchedulerFactory(manager: coinPriceManager, hsProvider: hsProvider, reachabilityManager: reachabilityManager, logger: logger)
        let coinPriceSyncManager = CoinPriceSyncManager(schedulerFactory: coinPriceSchedulerFactory)
        coinPriceManager.delegate = coinPriceSyncManager

        let coinHistoricalPriceStorage = try CoinHistoricalPriceStorage(dbPool: dbPool)
        let coinHistoricalPriceManager = CoinHistoricalPriceManager(storage: coinHistoricalPriceStorage, coinManager: coinManager, coinGeckoProvider: coinGeckoProvider)

        let chartStorage = try ChartStorage(dbPool: dbPool)
        let chartManager = ChartManager(coinManager: coinManager, storage: chartStorage, coinPriceManager: coinPriceManager)

        let chartSchedulerFactory = ChartSchedulerFactory(manager: chartManager, provider: coinGeckoProvider, reachabilityManager: reachabilityManager, retryInterval: 30, logger: logger)
        let chartSyncManager = ChartSyncManager(coinManager: coinManager, schedulerFactory: chartSchedulerFactory, chartInfoManager: chartManager, coinPriceSyncManager: coinPriceSyncManager)

        chartManager.delegate = chartSyncManager

        let postManager = PostManager(provider: cryptoCompareProvider)

        let globalMarketInfoStorage = try GlobalMarketInfoStorage(dbPool: dbPool)
        let globalMarketInfoManager = GlobalMarketInfoManager(provider: hsOldProvider, storage: globalMarketInfoStorage)

        return Kit(
                coinManager: coinManager,
                coinCategoryManager: coinCategoryManager,
                coinSyncer: coinSyncer,
                coinCategorySyncer: coinCategorySyncer,
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
