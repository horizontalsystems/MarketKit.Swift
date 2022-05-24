import RxSwift

public class Kit {
    private let coinManager: CoinManager
    private let nftManager: NftManager
    private let marketOverviewManager: MarketOverviewManager
    private let hsDataSyncer: HsDataSyncer
    private let coinSyncer: CoinSyncer
    private let exchangeSyncer: ExchangeSyncer
    private let coinPriceManager: CoinPriceManager
    private let coinPriceSyncManager: CoinPriceSyncManager
    private let coinHistoricalPriceManager: CoinHistoricalPriceManager
    private let chartManager: ChartManager
    private let chartSyncManager: ChartSyncManager
    private let postManager: PostManager
    private let globalMarketInfoManager: GlobalMarketInfoManager
    private let hsProvider: HsProvider

    init(coinManager: CoinManager, nftManager: NftManager, marketOverviewManager: MarketOverviewManager, hsDataSyncer: HsDataSyncer, coinSyncer: CoinSyncer, exchangeSyncer: ExchangeSyncer, coinPriceManager: CoinPriceManager, coinPriceSyncManager: CoinPriceSyncManager, coinHistoricalPriceManager: CoinHistoricalPriceManager, chartManager: ChartManager, chartSyncManager: ChartSyncManager, postManager: PostManager, globalMarketInfoManager: GlobalMarketInfoManager, hsProvider: HsProvider) {
        self.coinManager = coinManager
        self.nftManager = nftManager
        self.marketOverviewManager = marketOverviewManager
        self.hsDataSyncer = hsDataSyncer
        self.coinSyncer = coinSyncer
        self.exchangeSyncer = exchangeSyncer
        self.coinPriceManager = coinPriceManager
        self.coinPriceSyncManager = coinPriceSyncManager
        self.coinHistoricalPriceManager = coinHistoricalPriceManager
        self.chartManager = chartManager
        self.chartSyncManager = chartSyncManager
        self.postManager = postManager
        self.globalMarketInfoManager = globalMarketInfoManager
        self.hsProvider = hsProvider

        coinSyncer.initialSync()
    }

}

extension Kit {

    static var bundle: Bundle? {
        Bundle(for: Kit.self).url(forResource: "MarketKit", withExtension: "bundle").flatMap { Bundle(url: $0) }
    }

}

extension Kit {

    public func sync() {
        hsDataSyncer.sync()
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

    public func coinsDump() throws -> String? {
        try coinSyncer.coinsDump()
    }

    public func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try coinManager.platformCoin(coinType: coinType)
    }

    public func platformCoins(platformType: PlatformType, filter: String, limit: Int = 20) throws -> [PlatformCoin] {
        try coinManager.platformCoins(platformType: platformType, filter: filter, limit: limit)
    }

    public func platformCoins(coinTypes: [CoinType]) throws -> [PlatformCoin] {
        try coinManager.platformCoins(coinTypes: coinTypes)
    }

    public func platformCoins(coinTypeIds: [String]) throws -> [PlatformCoin] {
        try coinManager.platformCoins(coinTypeIds: coinTypeIds)
    }

    // Market Info

    public func marketInfosSingle(top: Int = 250, currencyCode: String, defi: Bool = false) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(top: top, currencyCode: currencyCode, defi: defi)
    }

    public func advancedMarketInfosSingle(top: Int = 250, currencyCode: String) -> Single<[MarketInfo]> {
        coinManager.advancedMarketInfosSingle(top: top, currencyCode: currencyCode)
    }

    public func marketInfosSingle(coinUids: [String], currencyCode: String) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(coinUids: coinUids, currencyCode: currencyCode)
    }

    public func marketInfosSingle(categoryUid: String, currencyCode: String) -> Single<[MarketInfo]> {
        coinManager.marketInfosSingle(categoryUid: categoryUid, currencyCode: currencyCode)
    }

    public func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverview> {
        hsProvider.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
    }

    public func marketInfoDetailsSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoDetails> {
        coinManager.marketInfoDetailsSingle(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func marketTickersSingle(coinUid: String) -> Single<[MarketTicker]> {
        coinManager.marketTickerSingle(coinUid: coinUid)
    }

    public func topHoldersSingle(coinUid: String) -> Single<[TokenHolder]> {
        coinManager.topHoldersSingle(coinUid: coinUid)
    }

    public func auditReportsSingle(addresses: [String]) -> Single<[Auditor]> {
        coinManager.auditReportsSingle(addresses: addresses)
    }

    public func investmentsSingle(coinUid: String) -> Single<[CoinInvestment]> {
        coinManager.investmentsSingle(coinUid: coinUid)
    }

    public func treasuriesSingle(coinUid: String, currencyCode: String) -> Single<[CoinTreasury]> {
        coinManager.treasuriesSingle(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func coinReportsSingle(coinUid: String) -> Single<[CoinReport]> {
        coinManager.coinReportsSingle(coinUid: coinUid)
    }

    public func marketInfoTvlSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<[ChartPoint]> {
        coinManager.marketInfoTvlSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    public func marketInfoGlobalTvlSingle(platform: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<[ChartPoint]> {
        coinManager.marketInfoGlobalTvlSingle(platform: platform, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    public func defiCoinsSingle(currencyCode: String) -> Single<[DefiCoin]> {
        coinManager.defiCoinsSingle(currencyCode: currencyCode)
    }

    public func twitterUsername(coinUid: String) -> Single<String?> {
        coinManager.twitterUsername(coinUid: coinUid)
    }


    // Categories

    public func coinCategoriesSingle(currencyCode: String) -> Single<[CoinCategory]> {
        hsProvider.coinCategoriesSingle(currencyCode: currencyCode)
    }

    public func coinCategoryMarketCapChartSingle(category: String, currencyCode: String?, timePeriod: HsTimePeriod) -> Single<[CategoryMarketPoint]> {
        hsProvider.coinCategoryMarketCapChartSingle(category: category, currencyCode: currencyCode, timePeriod: timePeriod)
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

    public func chartInfo(coinUid: String, currencyCode: String, interval: HsTimePeriod) -> ChartInfo? {
        chartManager.chartInfo(coinUid: coinUid, currencyCode: currencyCode, interval: interval)
    }

    public func chartInfoSingle(coinUid: String, currencyCode: String, interval: HsTimePeriod) -> Single<ChartInfo> {
        chartManager.chartInfoSingle(coinUid: coinUid, currencyCode: currencyCode, interval: interval)
    }

    public func chartInfoObservable(coinUid: String, currencyCode: String, interval: HsTimePeriod) -> Observable<ChartInfo> {
        chartSyncManager.chartInfoObservable(coinUid: coinUid, currencyCode: currencyCode, interval: interval)
    }

    // Posts

    public func postsSingle() -> Single<[Post]> {
        postManager.postsSingle()
    }

    // Global Market Info

    public func globalMarketPointsSingle(currencyCode: String, timePeriod: HsTimePeriod) -> Single<[GlobalMarketPoint]> {
        globalMarketInfoManager.globalMarketPointsSingle(currencyCode: currencyCode, timePeriod: timePeriod)
    }

    // Platforms

    public func topPlatformsSingle(currencyCode: String) -> Single<[TopPlatform]> {
        coinManager.topPlatformsSingle(currencyCode: currencyCode)
    }

    // Pro Charts

    public func dexLiquiditySingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, sessionKey: String?) -> Single<DexLiquidityResponse> {
        coinManager.dexLiquiditySingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, sessionKey: sessionKey)
    }

    public func dexVolumesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, sessionKey: String?) -> Single<DexVolumeResponse> {
        coinManager.dexVolumesSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, sessionKey: sessionKey)
    }

    public func transactionDataSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, platform: String?, sessionKey: String?) -> Single<TransactionDataResponse> {
        coinManager.transactionDataSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, platform: platform, sessionKey: sessionKey)
    }


    public func activeAddressesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, sessionKey: String?) -> Single<[ProChartPointDataResponse]> {
        coinManager.activeAddressesSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, sessionKey: sessionKey)
    }

    // Overview

    public func marketOverviewSingle(currencyCode: String) -> Single<MarketOverview> {
        marketOverviewManager.marketOverviewSingle(currencyCode: currencyCode)
    }

    public func topMoversSingle(currencyCode: String) -> Single<TopMovers> {
        coinManager.topMoversSingle(currencyCode: currencyCode)
    }

    // NFT

    public func nftAssetCollectionSingle(address: String) -> Single<NftAssetCollection> {
        nftManager.assetCollectionSingle(address: address)
    }

    public func nftCollectionSingle(uid: String) -> Single<NftCollection> {
        nftManager.collectionSingle(uid: uid)
    }

    public func nftCollectionsSingle() -> Single<[NftCollection]> {
        nftManager.collectionsSingle()
    }

    public func nftAssetSingle(contractAddress: String, tokenId: String) -> Single<NftAsset> {
        nftManager.assetSingle(contractAddress: contractAddress, tokenId: tokenId)
    }

    public func nftAssetsSingle(collectionUid: String, cursor: String? = nil) -> Single<PagedNftAssets> {
        nftManager.assetsSingle(collectionUid: collectionUid, cursor: cursor)
    }

    public func nftEventsSingle(collectionUid: String, eventType: NftEvent.EventType?, cursor: String? = nil) -> Single<PagedNftEvents> {
        nftManager.eventsSingle(collectionUid: collectionUid, eventType: eventType, cursor: cursor)
    }

}

extension Kit {

    public enum KitError: Error {
        case noChartData
    }

}
