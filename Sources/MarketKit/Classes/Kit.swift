import Foundation
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
    private let postManager: PostManager
    private let globalMarketInfoManager: GlobalMarketInfoManager
    private let hsProvider: HsProvider

    init(coinManager: CoinManager, nftManager: NftManager, marketOverviewManager: MarketOverviewManager, hsDataSyncer: HsDataSyncer, coinSyncer: CoinSyncer, exchangeSyncer: ExchangeSyncer, coinPriceManager: CoinPriceManager, coinPriceSyncManager: CoinPriceSyncManager, coinHistoricalPriceManager: CoinHistoricalPriceManager, postManager: PostManager, globalMarketInfoManager: GlobalMarketInfoManager, hsProvider: HsProvider) {
        self.coinManager = coinManager
        self.nftManager = nftManager
        self.marketOverviewManager = marketOverviewManager
        self.hsDataSyncer = hsDataSyncer
        self.coinSyncer = coinSyncer
        self.exchangeSyncer = exchangeSyncer
        self.coinPriceManager = coinPriceManager
        self.coinPriceSyncManager = coinPriceSyncManager
        self.coinHistoricalPriceManager = coinHistoricalPriceManager
        self.postManager = postManager
        self.globalMarketInfoManager = globalMarketInfoManager
        self.hsProvider = hsProvider

        coinSyncer.initialSync()
    }

}

extension Kit {

    public func sync() {
        hsDataSyncer.sync()
        exchangeSyncer.sync()
    }

    // Coins

    public var fullCoinsUpdatedObservable: Observable<Void> {
        coinSyncer.fullCoinsUpdatedObservable
    }

    public func fullCoins(filter: String, limit: Int = 20) throws -> [FullCoin] {
        try coinManager.fullCoins(filter: filter, limit: limit)
    }

    public func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try coinManager.fullCoins(coinUids: coinUids)
    }

    public func allCoins() throws -> [Coin] {
        try coinManager.allCoins()
    }

    public func coinsDump() throws -> String? {
        try coinSyncer.coinsDump()
    }

    public func blockchainsDump() throws -> String? {
        try coinSyncer.blockchainsDump()
    }

    public func tokenRecordsDump() throws -> String? {
        try coinSyncer.tokenRecordsDump()
    }

    public func token(query: TokenQuery) throws -> Token? {
        try coinManager.token(query: query)
    }

    public func tokens(queries: [TokenQuery]) throws -> [Token] {
        try coinManager.tokens(queries: queries)
    }

    public func tokens(reference: String) throws -> [Token] {
        try coinManager.tokens(reference: reference)
    }

    public func tokens(blockchainType: BlockchainType, filter: String, limit: Int = 20) throws -> [Token] {
        try coinManager.tokens(blockchainType: blockchainType, filter: filter, limit: limit)
    }

    public func blockchains(uids: [String]) throws -> [Blockchain] {
        try coinManager.blockchains(uids: uids)
    }

    public func blockchain(uid: String) throws -> Blockchain? {
        try coinManager.blockchain(uid: uid)
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
        coinManager.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
    }

    public func marketInfoDetailsSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoDetails> {
        coinManager.marketInfoDetailsSingle(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func marketTickersSingle(coinUid: String) -> Single<[MarketTicker]> {
        coinManager.marketTickerSingle(coinUid: coinUid)
    }

    public func tokenHoldersSingle(coinUid: String, blockchainUid: String) -> Single<TokenHolders> {
        hsProvider.tokenHoldersSingle(coinUid: coinUid, blockchainUid: blockchainUid)
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

    public func coinHistoricalPriceValue(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Decimal? {
        coinHistoricalPriceManager.coinHistoricalPriceValue(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)
    }

    public func coinHistoricalPriceValueSingle(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Single<Decimal> {
        coinHistoricalPriceManager.coinHistoricalPriceValueSingle(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)
    }

    // Chart Info

    public func chartPriceStart(coinUid: String) -> Single<TimeInterval> {
        hsProvider.coinPriceChartStart(coinUid: coinUid).map { $0.timestamp }
    }

    public func chartPointsSingle(coinUid: String, currencyCode: String, periodType: HsPeriodType) -> Single<[ChartPoint]> {
        hsProvider.coinPriceChartSingle(coinUid: coinUid, currencyCode: currencyCode, periodType: periodType)
                .map { $0.map { $0.chartPoint } }
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

    public func topPlatformMarketInfosSingle(blockchain: String, currencyCode: String) -> Single<[MarketInfo]> {
        coinManager.topPlatformsCoinsListSingle(blockchain: blockchain, currencyCode: currencyCode)
    }

    public func topPlatformMarketCapChartSingle(platform: String, currencyCode: String?, timePeriod: HsTimePeriod) -> Single<[CategoryMarketPoint]> {
        hsProvider.topPlatformMarketCapChartSingle(platform: platform, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    // Pro Data

    public func analyticsSingle(coinUid: String, currencyCode: String) -> Single<Analytics> {
        hsProvider.analyticsSingle(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func analyticsPreviewSingle(coinUid: String) -> Single<AnalyticsPreview> {
        hsProvider.analyticsPreviewSingle(coinUid: coinUid)
    }

    public func cexVolumesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<AggregatedChartPoints> {
        hsProvider.coinPriceChartSingle(coinUid: coinUid, currencyCode: currencyCode, periodType: .byPeriod(timePeriod))
                .map { responses in
                    let points = responses.compactMap { $0.volumeChartPoint }

                    return AggregatedChartPoints(
                            points: points,
                            aggregatedValue: points.map { $0.value }.reduce(0, +)
                    )
                }
    }

    public func cexVolumeRanksSingle(currencyCode: String) -> Single<[RankMultiValue]> {
        hsProvider.cexVolumeRanksSingle(currencyCode: currencyCode)
    }

    public func dexVolumeRanksSingle(currencyCode: String) -> Single<[RankMultiValue]> {
        hsProvider.dexVolumeRanksSingle(currencyCode: currencyCode)
    }

    public func dexLiquidityRanksSingle() -> Single<[RankValue]> {
        hsProvider.dexLiquidityRanksSingle()
    }

    public func activeAddressRanksSingle() -> Single<[RankMultiValue]> {
        hsProvider.activeAddressRanksSingle()
    }

    public func transactionCountRanksSingle() -> Single<[RankMultiValue]> {
        hsProvider.transactionCountRanksSingle()
    }

    public func revenueRanksSingle(currencyCode: String) -> Single<[RankMultiValue]> {
        hsProvider.revenueRanksSingle(currencyCode: currencyCode)
    }

    public func dexVolumesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<AggregatedChartPoints> {
        hsProvider.dexVolumesSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
                .map {
                    AggregatedChartPoints(
                            points: $0.points.map { $0.chartPoint },
                            aggregatedValue: $0.points.map { $0.volume }.reduce(0, +)
                    )
                }
    }

    public func dexLiquiditySingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<[ChartPoint]> {
        hsProvider.dexLiquiditySingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
                .map { $0.points.map { $0.chartPoint } }
    }

    public func activeAddressesSingle(coinUid: String, timePeriod: HsTimePeriod) -> Single<AggregatedChartPoints> {
        hsProvider.activeAddressesSingle(coinUid: coinUid, timePeriod: timePeriod)
                .map {
                    AggregatedChartPoints(
                            points: $0.points.map { $0.chartPoint },
                            aggregatedValue: nil
                    )
                }
    }

    public func transactionsSingle(coinUid: String, timePeriod: HsTimePeriod) -> Single<AggregatedChartPoints> {
        hsProvider.transactionsSingle(coinUid: coinUid, timePeriod: timePeriod)
                .map {
                    AggregatedChartPoints(
                            points: $0.points.map { $0.chartPoint },
                            aggregatedValue: $0.points.map { Decimal($0.count) }.reduce(0, +)
                    )
                }
    }

    public func marketInfoTvlSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<[ChartPoint]> {
        hsProvider.marketInfoTvlSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    // Overview

    public func marketOverviewSingle(currencyCode: String) -> Single<MarketOverview> {
        marketOverviewManager.marketOverviewSingle(currencyCode: currencyCode)
    }

    public func topMoversSingle(currencyCode: String) -> Single<TopMovers> {
        coinManager.topMoversSingle(currencyCode: currencyCode)
    }

    // NFT

    public func nftTopCollectionsSingle() -> Single<[NftTopCollection]> {
        nftManager.topCollectionsSingle()
    }

    // Misc

    public func syncInfo() -> SyncInfo {
        coinSyncer.syncInfo()
    }

}

extension Kit {

    public struct SyncInfo {
        public let coinsTimestamp: String?
        public let blockchainsTimestamp: String?
        public let tokensTimestamp: String?
    }

    public enum KitError: Error {
        case noChartData
        case noFullCoin
        case weakReference
    }

}
