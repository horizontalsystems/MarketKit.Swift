import RxSwift

public class Kit {
    private let coinManager: CoinManager
    private let coinCategoryManager: CoinCategoryManager
    private let coinSyncer: CoinSyncer
    private let coinCategorySyncer: CoinCategorySyncer
    private let exchangeSyncer: ExchangeSyncer
    private let coinPriceManager: CoinPriceManager
    private let coinPriceSyncManager: CoinPriceSyncManager
    private let chartManager: ChartManager
    private let chartSyncManager: ChartSyncManager
    private let postManager: PostManager

    init(coinManager: CoinManager, coinCategoryManager: CoinCategoryManager, coinSyncer: CoinSyncer, coinCategorySyncer: CoinCategorySyncer, exchangeSyncer: ExchangeSyncer, coinPriceManager: CoinPriceManager, coinPriceSyncManager: CoinPriceSyncManager, chartManager: ChartManager, chartSyncManager: ChartSyncManager, postManager: PostManager) {
        self.coinManager = coinManager
        self.coinCategoryManager = coinCategoryManager
        self.coinSyncer = coinSyncer
        self.coinCategorySyncer = coinCategorySyncer
        self.exchangeSyncer = exchangeSyncer
        self.coinPriceManager = coinPriceManager
        self.coinPriceSyncManager = coinPriceSyncManager
        self.chartManager = chartManager
        self.chartSyncManager = chartSyncManager
        self.postManager = postManager
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

    public func marketInfosSingle(top: Int = 250, limit: Int? = nil, order: MarketInfo.Order? = nil) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(top: top, limit: limit, order: order)
    }

    public func marketInfosSingle(coinUids: [String], order: MarketInfo.Order? = nil) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(coinUids: coinUids, order: order)
    }

    public func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverview> {
        coinManager.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
    }

    public func marketTickersSingle(coinUid: String) -> Single<[MarketTicker]> {
        coinManager.marketTickerSingle(coinUid: coinUid)
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

}

extension Kit {

    public enum KitError: Error {
        case noChartData
    }

}