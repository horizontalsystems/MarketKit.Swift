import RxSwift

public class Kit {
    private let coinManager: CoinManager
    private let coinCategoryManager: CoinCategoryManager
    private let coinSyncer: CoinSyncer
    private let coinCategorySyncer: CoinCategorySyncer
    private let exchangeSyncer: ExchangeSyncer
    private let coinPriceManager: CoinPriceManager
    private let coinPriceSyncManager: CoinPriceSyncManager
    private let coinHistoricalPriceManager: CoinHistoricalPriceManager
    private let chartManager: ChartManager
    private let chartSyncManager: ChartSyncManager
    private let postManager: PostManager
    private let globalMarketInfoManager: GlobalMarketInfoManager

    init(coinManager: CoinManager, coinCategoryManager: CoinCategoryManager, coinSyncer: CoinSyncer, coinCategorySyncer: CoinCategorySyncer, exchangeSyncer: ExchangeSyncer, coinPriceManager: CoinPriceManager, coinPriceSyncManager: CoinPriceSyncManager, coinHistoricalPriceManager: CoinHistoricalPriceManager, chartManager: ChartManager, chartSyncManager: ChartSyncManager, postManager: PostManager, globalMarketInfoManager: GlobalMarketInfoManager) {
        self.coinManager = coinManager
        self.coinCategoryManager = coinCategoryManager
        self.coinSyncer = coinSyncer
        self.coinCategorySyncer = coinCategorySyncer
        self.exchangeSyncer = exchangeSyncer
        self.coinPriceManager = coinPriceManager
        self.coinPriceSyncManager = coinPriceSyncManager
        self.coinHistoricalPriceManager = coinHistoricalPriceManager
        self.chartManager = chartManager
        self.chartSyncManager = chartSyncManager
        self.postManager = postManager
        self.globalMarketInfoManager = globalMarketInfoManager
    }

}

extension Kit {

    public func sync() {
        coinSyncer.sync()
        coinCategorySyncer.sync()
        exchangeSyncer.sync()
    }

    // Coins

    public var fullCoinsUpdatedObservable: Observable<Void> {
        coinManager.fullCoinsUpdatedObservable
    }

    public func fullCoins(filter: String, limit: Int = 20) throws -> [FullCoin] {
        try coinManager.fullCoins(filter: filter, limit: limit)
    }

    public func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try coinManager.fullCoins(coinUids: coinUids)
    }

    public func fullCoins(coinTypes: [CoinType]) throws -> [FullCoin] {
        try coinManager.fullCoins(coinTypes: coinTypes)
    }

    public func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try coinManager.platformCoin(coinType: coinType)
    }

    public func platformCoins() throws -> [PlatformCoin] {
        try coinManager.platformCoins()
    }

    public func platformCoins(coinTypes: [CoinType]) throws -> [PlatformCoin] {
        try coinManager.platformCoins(coinTypes: coinTypes)
    }

    public func platformCoins(coinTypeIds: [String]) throws -> [PlatformCoin] {
        try coinManager.platformCoins(coinTypeIds: coinTypeIds)
    }

    public func coins(filter: String, limit: Int = 20) throws -> [Coin] {
        try coinManager.coins(filter: filter, limit: limit)
    }

    // Market Info

    public func marketInfosSingle(top: Int = 250) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(top: top)
    }

    public func advancedMarketInfosSingle(top: Int = 250) -> Single<[MarketInfo]> {
        coinManager.advancedMarketInfosSingle(top: top)
    }

    public func marketInfosSingle(coinUids: [String]) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(coinUids: coinUids)
    }

    public func marketInfosSingle(categoryUid: String) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(categoryUid: categoryUid)
    }

    public func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverview> {
        coinManager.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
    }

    public func marketTickersSingle(coinUid: String) -> Single<[MarketTicker]> {
        coinManager.marketTickerSingle(coinUid: coinUid)
    }

    public func topTokenHoldersSingle(coinUid: String, itemsCount: Int = 20) -> Single<[TokenHolder]> {
        coinManager.topTokenHoldersSingle(coinUid: coinUid, itemsCount: itemsCount)
    }

    public func auditReportsSingle(coinUid: String) -> Single<[Auditor]> {
        coinManager.auditReportsSingle(coinUid: coinUid)
    }

    // Categories

    public var coinCategoriesObservable: Observable<[CoinCategory]> {
        coinCategoryManager.coinCategoriesObservable
    }

    public func coinCategories() throws -> [CoinCategory] {
        try coinCategoryManager.coinCategories()
    }

    public func coinCategory(uid: String) throws -> CoinCategory? {
        try coinCategoryManager.coinCategory(uid: uid)
    }

    // Coin Prices

    public func refreshCoinPrices(currencyCode: String) {
        coinPriceSyncManager.refresh(currencyCode: currencyCode)
    }

    public func coinPrice(coinUid: String, currencyCode: String) -> CoinPrice? {
        coinPriceManager.coinPrice(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func coinPriceMap(coinUids: [String], currencyCode: String) -> [String: CoinPrice] {
        coinPriceManager.coinPriceMap(coinUids: coinUids, currencyCode: currencyCode)
    }

    public func coinPriceObservable(coinUid: String, currencyCode: String) -> Observable<CoinPrice> {
        coinPriceSyncManager.coinPriceObservable(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func coinPriceMapObservable(coinUids: [String], currencyCode: String) -> Observable<[String: CoinPrice]> {
        coinPriceSyncManager.coinPriceMapObservable(coinUids: coinUids, currencyCode: currencyCode)
    }

    // Coin Historical Prices

    public func coinHistoricalPriceValueSingle(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Single<Decimal> {
        coinHistoricalPriceManager.coinHistoricalPriceValueSingle(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)
    }

    // Chart Info

    public func chartInfo(coinUid: String, currencyCode: String, chartType: ChartType) -> ChartInfo? {
        chartManager.chartInfo(coinUid: coinUid, currencyCode: currencyCode, chartType: chartType)
    }

    public func chartInfoObservable(coinUid: String, currencyCode: String, chartType: ChartType) -> Observable<ChartInfo> {
        chartSyncManager.chartInfoObservable(coinUid: coinUid, currencyCode: currencyCode, chartType: chartType)
    }

    // Posts

    public func postsSingle() -> Single<[Post]> {
        postManager.postsSingle()
    }

    // Global Market Info

    public func globalMarketPointsSingle(currencyCode: String, timePeriod: TimePeriod) -> Single<[GlobalMarketPoint]> {
        globalMarketInfoManager.globalMarketPointsSingle(currencyCode: currencyCode, timePeriod: timePeriod)
    }

}

extension Kit {

    public enum KitError: Error {
        case noChartData
    }

}
