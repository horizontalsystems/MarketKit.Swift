import Combine
import Foundation

public class Kit {
    private let coinManager: CoinManager
    private let nftManager: NftManager
    private let marketOverviewManager: MarketOverviewManager
    private let hsDataSyncer: HsDataSyncer
    private let coinSyncer: CoinSyncer
    private let coinPriceManager: CoinPriceManager
    private let coinPriceSyncManager: CoinPriceSyncManager
    private let coinHistoricalPriceManager: CoinHistoricalPriceManager
    private let postManager: PostManager
    private let globalMarketInfoManager: GlobalMarketInfoManager
    private let hsProvider: HsProvider

    init(coinManager: CoinManager, nftManager: NftManager, marketOverviewManager: MarketOverviewManager, hsDataSyncer: HsDataSyncer, coinSyncer: CoinSyncer, coinPriceManager: CoinPriceManager, coinPriceSyncManager: CoinPriceSyncManager, coinHistoricalPriceManager: CoinHistoricalPriceManager, postManager: PostManager, globalMarketInfoManager: GlobalMarketInfoManager, hsProvider: HsProvider) {
        self.coinManager = coinManager
        self.nftManager = nftManager
        self.marketOverviewManager = marketOverviewManager
        self.hsDataSyncer = hsDataSyncer
        self.coinSyncer = coinSyncer
        self.coinPriceManager = coinPriceManager
        self.coinPriceSyncManager = coinPriceSyncManager
        self.coinHistoricalPriceManager = coinHistoricalPriceManager
        self.postManager = postManager
        self.globalMarketInfoManager = globalMarketInfoManager
        self.hsProvider = hsProvider

        coinSyncer.initialSync()
    }
}

public extension Kit {
    func sync() {
        hsDataSyncer.sync()
    }

    func set(proAuthToken: String?) {
        hsProvider.proAuthToken = proAuthToken
    }

    // Coins

    var fullCoinsUpdatedPublisher: AnyPublisher<Void, Never> {
        coinSyncer.fullCoinsUpdatedPublisher
    }

    func topFullCoins(limit: Int = 20) throws -> [FullCoin] {
        try coinManager.topFullCoins(limit: limit)
    }

    func fullCoins(filter: String, limit: Int = 20) throws -> [FullCoin] {
        try coinManager.fullCoins(filter: filter, limit: limit)
    }

    func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try coinManager.fullCoins(coinUids: coinUids)
    }

    func allCoins() throws -> [Coin] {
        try coinManager.allCoins()
    }

    func coinsDump() throws -> String? {
        try coinSyncer.coinsDump()
    }

    func blockchainsDump() throws -> String? {
        try coinSyncer.blockchainsDump()
    }

    func tokenRecordsDump() throws -> String? {
        try coinSyncer.tokenRecordsDump()
    }

    func token(query: TokenQuery) throws -> Token? {
        try coinManager.token(query: query)
    }

    func tokens(queries: [TokenQuery]) throws -> [Token] {
        try coinManager.tokens(queries: queries)
    }

    func tokens(reference: String) throws -> [Token] {
        try coinManager.tokens(reference: reference)
    }

    func tokens(blockchainType: BlockchainType, filter: String, limit: Int = 20) throws -> [Token] {
        try coinManager.tokens(blockchainType: blockchainType, filter: filter, limit: limit)
    }

    func allBlockchains() throws -> [Blockchain] {
        try coinManager.allBlockchains()
    }

    func blockchains(uids: [String]) throws -> [Blockchain] {
        try coinManager.blockchains(uids: uids)
    }

    func blockchain(uid: String) throws -> Blockchain? {
        try coinManager.blockchain(uid: uid)
    }

    // Market Info

    func marketInfos(top: Int = 250, currencyCode: String, defi: Bool = false) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.marketInfos(top: top, currencyCode: currencyCode, defi: defi)
        return coinManager.marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func topCoinsMarketInfos(top: Int, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.topCoinsMarketInfos(top: top, currencyCode: currencyCode)
        return coinManager.marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func advancedMarketInfos(top: Int = 250, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.advancedMarketInfos(top: top, currencyCode: currencyCode)
        return coinManager.marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func marketInfos(coinUids: [String], currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.marketInfos(coinUids: coinUids, currencyCode: currencyCode)
        return coinManager.marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func marketInfos(categoryUid: String, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.marketInfos(categoryUid: categoryUid, currencyCode: currencyCode)
        return coinManager.marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func marketInfoOverview(coinUid: String, currencyCode: String, languageCode: String) async throws -> MarketInfoOverview {
        let response = try await hsProvider.marketInfoOverview(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)

        guard let fullCoin = try? coinManager.fullCoin(uid: coinUid) else {
            throw Kit.KitError.noFullCoin
        }

        return response.marketInfoOverview(fullCoin: fullCoin)
    }

    func marketTickers(coinUid: String, currencyCode: String) async throws -> [MarketTicker] {
        try await hsProvider.marketTickers(coinUid: coinUid, currencyCode: currencyCode)
    }

    func tokenHolders(coinUid: String, blockchainUid: String) async throws -> TokenHolders {
        try await hsProvider.tokenHolders(coinUid: coinUid, blockchainUid: blockchainUid)
    }

    func investments(coinUid: String) async throws -> [CoinInvestment] {
        try await hsProvider.coinInvestments(coinUid: coinUid)
    }

    func treasuries(coinUid: String, currencyCode: String) async throws -> [CoinTreasury] {
        try await hsProvider.coinTreasuries(coinUid: coinUid, currencyCode: currencyCode)
    }

    func coinReports(coinUid: String) async throws -> [CoinReport] {
        try await hsProvider.coinReports(coinUid: coinUid)
    }

    func marketInfoGlobalTvl(platform: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [ChartPoint] {
        try await hsProvider.marketInfoGlobalTvl(platform: platform, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    func defiCoins(currencyCode: String) async throws -> [DefiCoin] {
        let rawDefiCoins = try await hsProvider.defiCoins(currencyCode: currencyCode)
        return coinManager.defiCoins(rawDefiCoins: rawDefiCoins)
    }

    func twitterUsername(coinUid: String) async throws -> String? {
        try await hsProvider.twitterUsername(coinUid: coinUid)
    }

    // Categories

    func coinCategories(currencyCode: String) async throws -> [CoinCategory] {
        try await hsProvider.coinCategories(currencyCode: currencyCode)
    }

    func coinCategoryMarketCapChart(category: String, currencyCode: String?, timePeriod: HsTimePeriod) async throws -> [CategoryMarketPoint] {
        try await hsProvider.coinCategoryMarketCapChart(category: category, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    // Coin Prices

    func refreshCoinPrices(currencyCode: String) {
        coinPriceSyncManager.refresh(currencyCode: currencyCode)
    }

    func coinPrice(coinUid: String, currencyCode: String) -> CoinPrice? {
        coinPriceManager.coinPrice(coinUid: coinUid, currencyCode: currencyCode)
    }

    func coinPriceMap(coinUids: [String], currencyCode: String) -> [String: CoinPrice] {
        coinPriceManager.coinPriceMap(coinUids: coinUids, currencyCode: currencyCode)
    }

    func coinPricePublisher(coinUid: String, currencyCode: String) -> AnyPublisher<CoinPrice, Never> {
        coinPriceSyncManager.coinPricePublisher(coinUid: coinUid, currencyCode: currencyCode)
    }

    func coinPriceMapPublisher(coinUids: [String], currencyCode: String) -> AnyPublisher<[String: CoinPrice], Never> {
        coinPriceSyncManager.coinPriceMapPublisher(coinUids: coinUids, currencyCode: currencyCode)
    }

    // Coin Historical Prices

    func cachedCoinHistoricalPriceValue(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Decimal? {
        coinHistoricalPriceManager.cachedCoinHistoricalPriceValue(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)
    }

    func coinHistoricalPriceValue(coinUid: String, currencyCode: String, timestamp: TimeInterval) async throws -> Decimal {
        try await coinHistoricalPriceManager.coinHistoricalPriceValue(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)
    }

    // Chart Info

    func chartPriceStart(coinUid: String) async throws -> TimeInterval {
        try await hsProvider.coinPriceChartStart(coinUid: coinUid).timestamp
    }

    func chartPoints(coinUid: String, currencyCode: String, interval: HsPointTimePeriod, pointCount: Int) async throws -> [ChartPoint] {
        let fromTimestamp = Date().timeIntervalSince1970 - interval.interval * TimeInterval(pointCount)

        let points = try await hsProvider.coinPriceChart(coinUid: coinUid, currencyCode: currencyCode, interval: interval, fromTimestamp: fromTimestamp)
            .map(\.chartPoint)

        return points
    }

    private func intervalData(periodType: HsPeriodType) -> (interval: HsPointTimePeriod, timestamp: TimeInterval?, visible: TimeInterval) {
        let interval: HsPointTimePeriod

        var fromTimestamp: TimeInterval?
        var visibleTimestamp: TimeInterval = 0 // start timestamp for visible part of chart. Will change only for .byCustomPoints

        switch periodType {
        case let .byPeriod(timePeriod):
            interval = HsChartHelper.pointInterval(timePeriod)
            visibleTimestamp = Date().timeIntervalSince1970 - timePeriod.range
            fromTimestamp = visibleTimestamp
        case let .byCustomPoints(timePeriod, pointCount): // custom points needed to build chart indicators
            interval = HsChartHelper.pointInterval(timePeriod)
            let customPointInterval = interval.interval * TimeInterval(pointCount)
            visibleTimestamp = Date().timeIntervalSince1970 - timePeriod.range
            fromTimestamp = visibleTimestamp - customPointInterval
        case let .byStartTime(startTime):
            interval = HsChartHelper.intervalForAll(genesisTime: startTime)
            visibleTimestamp = startTime
        }

        return (interval: interval, timestamp: fromTimestamp, visible: visibleTimestamp)
    }

    func chartPoints(coinUid: String, currencyCode: String, periodType: HsPeriodType) async throws -> (TimeInterval, [ChartPoint]) {
        let data = intervalData(periodType: periodType)

        let points = try await hsProvider.coinPriceChart(
            coinUid: coinUid,
            currencyCode: currencyCode,
            interval: data.interval,
            fromTimestamp: data.timestamp
        )
        .map(\.chartPoint)

        return (data.visible, points)
    }

    // Posts

    func posts() async throws -> [Post] {
        try await postManager.posts()
    }

    // Global Market Info

    func globalMarketPoints(currencyCode: String, timePeriod: HsTimePeriod) async throws -> [GlobalMarketPoint] {
        try await globalMarketInfoManager.globalMarketPoints(currencyCode: currencyCode, timePeriod: timePeriod)
    }

    // Pairs

    func topPairs(currencyCode: String) async throws -> [MarketPair] {
        try await hsProvider.topPairs(currencyCode: currencyCode)
    }

    // Platforms

    func topPlatforms(currencyCode: String) async throws -> [TopPlatform] {
        let responses = try await hsProvider.topPlatforms(currencyCode: currencyCode)
        return responses.map(\.topPlatform)
    }

    func topPlatformMarketInfos(blockchain: String, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.topPlatformCoinsList(blockchain: blockchain, currencyCode: currencyCode)
        return coinManager.marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func topPlatformMarketCapStart(platform: String) async throws -> TimeInterval {
        try await hsProvider.topPlatformMarketCapStart(platform: platform).timestamp
    }

    func topPlatformMarketCapChart(platform: String, currencyCode: String?, periodType: HsPeriodType) async throws -> [CategoryMarketPoint] {
        let data = intervalData(periodType: periodType)

        return try await hsProvider.topPlatformMarketCapChart(
            platform: platform,
            currencyCode: currencyCode,
            interval: data.interval,
            fromTimestamp: data.timestamp
        )
    }

    // Pro Data

    func analytics(coinUid: String, currencyCode: String) async throws -> Analytics {
        try await hsProvider.analytics(coinUid: coinUid, currencyCode: currencyCode)
    }

    func analyticsPreview(coinUid: String) async throws -> AnalyticsPreview {
        try await hsProvider.analyticsPreview(coinUid: coinUid)
    }

    func cexVolumes(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> AggregatedChartPoints {
        let responses = try await hsProvider.coinPriceChart(
            coinUid: coinUid,
            currencyCode: currencyCode,
            interval: .day1,
            fromTimestamp: Date().timeIntervalSince1970 - timePeriod.range
        )

        let points = responses.compactMap(\.volumeChartPoint)

        return AggregatedChartPoints(
            points: points,
            aggregatedValue: points.map(\.value).reduce(0, +)
        )
    }

    func cexVolumeRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await hsProvider.cexVolumeRanks(currencyCode: currencyCode)
    }

    func dexVolumeRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await hsProvider.dexVolumeRanks(currencyCode: currencyCode)
    }

    func dexLiquidityRanks() async throws -> [RankValue] {
        try await hsProvider.dexLiquidityRanks()
    }

    func activeAddressRanks() async throws -> [RankMultiValue] {
        try await hsProvider.activeAddressRanks()
    }

    func transactionCountRanks() async throws -> [RankMultiValue] {
        try await hsProvider.transactionCountRanks()
    }

    func holdersRanks() async throws -> [RankValue] {
        try await hsProvider.holdersRanks()
    }

    func feeRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await hsProvider.feeRanks(currencyCode: currencyCode)
    }

    func revenueRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await hsProvider.revenueRanks(currencyCode: currencyCode)
    }

    func dexVolumes(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> AggregatedChartPoints {
        let points = try await hsProvider.dexVolumes(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
        return AggregatedChartPoints(
            points: points.map(\.chartPoint),
            aggregatedValue: points.map(\.volume).reduce(0, +)
        )
    }

    func dexLiquidity(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [ChartPoint] {
        try await hsProvider.dexLiquidity(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
            .map(\.chartPoint)
    }

    func activeAddresses(coinUid: String, timePeriod: HsTimePeriod) async throws -> [ChartPoint] {
        try await hsProvider.activeAddresses(coinUid: coinUid, timePeriod: timePeriod)
            .map(\.chartPoint)
    }

    func transactions(coinUid: String, timePeriod: HsTimePeriod) async throws -> AggregatedChartPoints {
        let points = try await hsProvider.transactions(coinUid: coinUid, timePeriod: timePeriod)
        return AggregatedChartPoints(
            points: points.map(\.chartPoint),
            aggregatedValue: points.map(\.count).reduce(0, +)
        )
    }

    func marketInfoTvl(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [ChartPoint] {
        try await hsProvider.marketInfoTvl(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    // Overview

    func marketOverview(currencyCode: String) async throws -> MarketOverview {
        try await marketOverviewManager.marketOverview(currencyCode: currencyCode)
    }

    func topMovers(currencyCode: String) async throws -> TopMovers {
        let raw = try await hsProvider.topMoversRaw(currencyCode: currencyCode)
        return TopMovers(
            gainers100: coinManager.marketInfos(rawMarketInfos: raw.gainers100),
            gainers200: coinManager.marketInfos(rawMarketInfos: raw.gainers200),
            gainers300: coinManager.marketInfos(rawMarketInfos: raw.gainers300),
            losers100: coinManager.marketInfos(rawMarketInfos: raw.losers100),
            losers200: coinManager.marketInfos(rawMarketInfos: raw.losers200),
            losers300: coinManager.marketInfos(rawMarketInfos: raw.losers300)
        )
    }

    // NFT

    func nftTopCollections() async throws -> [NftTopCollection] {
        try await nftManager.topCollections()
    }

    // Auth

    func subscriptions(addresses: [String]) async throws -> [ProSubscription] {
        try await hsProvider.subscriptions(addresses: addresses)
    }

    func authKey(address: String) async throws -> String {
        try await hsProvider.authKey(address: address)
    }

    func authenticate(signature: String, address: String) async throws -> String {
        try await hsProvider.authenticate(signature: signature, address: address)
    }

    func requestPersonalSupport(telegramUsername: String) async throws {
        try await hsProvider.requestPersonalSupport(telegramUsername: telegramUsername)
    }

    // Misc

    func syncInfo() -> SyncInfo {
        coinSyncer.syncInfo()
    }

    // Stats

    func send(stats: Any, appVersion: String, appId: String?) async throws {
        try await hsProvider.send(stats: stats, appVersion: appVersion, appId: appId)
    }
}

public extension Kit {
    struct SyncInfo {
        public let coinsTimestamp: String?
        public let blockchainsTimestamp: String?
        public let tokensTimestamp: String?
    }

    enum KitError: Error {
        case noChartData
        case noFullCoin
        case weakReference
    }
}
