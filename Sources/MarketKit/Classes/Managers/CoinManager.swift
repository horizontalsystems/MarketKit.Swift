import Foundation
import RxSwift
import RxRelay

class CoinManager {
    private let storage: CoinStorage
    private let hsProvider: HsProvider
    private let coinGeckoProvider: CoinGeckoProvider
    private let defiYieldProvider: DefiYieldProvider
    private let exchangeManager: ExchangeManager

    init(storage: CoinStorage, hsProvider: HsProvider, coinGeckoProvider: CoinGeckoProvider, defiYieldProvider: DefiYieldProvider, exchangeManager: ExchangeManager) {
        self.storage = storage
        self.hsProvider = hsProvider
        self.coinGeckoProvider = coinGeckoProvider
        self.defiYieldProvider = defiYieldProvider
        self.exchangeManager = exchangeManager
    }

    private func marketInfos(rawMarketInfos: [MarketInfoRaw]) -> [MarketInfo] {
        do {
            let fullCoins = try fullCoins(coinUids: rawMarketInfos.map { $0.uid })
            let dictionary = fullCoins.reduce(into: [String: FullCoin]()) { $0[$1.coin.uid] = $1 }

            return rawMarketInfos.compactMap { rawMarketInfo in
                guard let fullCoin = dictionary[rawMarketInfo.uid] else {
                    return nil
                }

                return rawMarketInfo.marketInfo(fullCoin: fullCoin)
            }
        } catch {
            return []
        }
    }

    private func defiCoins(rawDefiCoins: [DefiCoinRaw]) -> [DefiCoin] {
        do {
            let fullCoins = try fullCoins(coinUids: rawDefiCoins.compactMap { $0.uid })
            let dictionary = fullCoins.reduce(into: [String: FullCoin]()) { $0[$1.coin.uid] = $1 }

            return rawDefiCoins.map { rawDefiCoin in
                rawDefiCoin.defiCoin(fullCoin: rawDefiCoin.uid.flatMap { dictionary[$0] })
            }
        } catch {
            return []
        }
    }

}

extension CoinManager {

    // Coins

    func coinsCount() throws -> Int {
        try storage.coinsCount()
    }

    func coin(uid: String) throws -> Coin? {
        try storage.coin(uid: uid)
    }

    func fullCoins(filter: String, limit: Int) throws -> [FullCoin] {
        try storage.coinTokenRecords(filter: filter, limit: limit)
                .map { $0.fullCoin }
    }

    func fullCoin(uid: String) throws -> FullCoin? {
        try storage.coinTokenRecord(uid: uid)?.fullCoin
    }

    func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try storage.coinTokenRecords(coinUids: coinUids)
                .map { $0.fullCoin }
    }

    func token(query: TokenQuery) throws -> Token? {
        try storage.tokenInfoRecord(query: query)
                .map { $0.token }
    }

    func tokens(queries: [TokenQuery]) throws -> [Token] {
        try storage.tokenInfoRecords(queries: queries)
                .map { $0.token }
    }

    func tokens(reference: String) throws -> [Token] {
        try storage.tokenInfoRecords(reference: reference)
                .map { $0.token }
    }

    func tokens(blockchainType: BlockchainType, filter: String, limit: Int) throws -> [Token] {
        try storage.tokenInfoRecords(blockchainType: blockchainType, filter: filter, limit: limit)
                .map { $0.token }
    }

    func blockchain(uid: String) throws -> Blockchain? {
        try storage.blockchain(uid: uid)
                .map { $0.blockchain }
    }

    func blockchains(uids: [String]) throws -> [Blockchain] {
        try storage.blockchains(uids: uids)
                .map { $0.blockchain }
    }

    // Market Info

    func marketInfosSingle(top: Int, currencyCode: String, defi: Bool) -> Single<[MarketInfo]> {
        hsProvider.marketInfosSingle(top: top, currencyCode: currencyCode, defi: defi)
                .map { [weak self] rawMarketInfos -> [MarketInfo] in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    func advancedMarketInfosSingle(top: Int, currencyCode: String) -> Single<[MarketInfo]> {
        hsProvider.advancedMarketInfosSingle(top: top, currencyCode: currencyCode)
                .map { [weak self] rawMarketInfos -> [MarketInfo] in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    func marketInfosSingle(coinUids: [String], currencyCode: String) -> Single<[MarketInfo]> {
        hsProvider.marketInfosSingle(coinUids: coinUids, currencyCode: currencyCode)
                .map { [weak self] rawMarketInfos -> [MarketInfo] in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    func marketInfosSingle(categoryUid: String, currencyCode: String) -> Single<[MarketInfo]> {
        hsProvider.marketInfosSingle(categoryUid: categoryUid, currencyCode: currencyCode)
                .map { [weak self] rawMarketInfos -> [MarketInfo] in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverview> {
        hsProvider.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
                .flatMap { [weak self] response in
                    if let fullCoin = try? self?.fullCoin(uid: coinUid) {
                        return Single.just(response.marketInfoOverview(fullCoin: fullCoin))
                    } else {
                        return Single.error(Kit.KitError.noFullCoin)
                    }
                }
    }

    func marketTickerSingle(coinUid: String) -> Single<[MarketTicker]> {
        guard let coin = try? storage.coin(uid: coinUid), let coinGeckoId = coin.coinGeckoId else {
            return Single.just([])
        }

        return coinGeckoProvider.marketTickersSingle(coinId: coinGeckoId)
                .map { [weak self] response in
                    let coinUids = (response.tickers.map { [$0.coinId, $0.targetCoinId] }).flatMap({ $0 }).compactMap { $0 }
                    let coins = (try? self?.storage.coins(uids: coinUids)) ?? []

                    return response.marketTickers(imageUrls: self?.exchangeManager.imageUrlsMap(ids: response.exchangeIds) ?? [:], coins: coins)
                }
    }

    func marketInfoDetailsSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoDetails> {
        hsProvider.marketInfoDetailsSingle(coinUid: coinUid, currencyCode: currencyCode)
    }

    func topHoldersSingle(coinUid: String) -> Single<[TokenHolder]> {
        hsProvider.topHoldersSingle(coinUid: coinUid)
    }

    func auditReportsSingle(addresses: [String]) -> Single<[Auditor]> {
        defiYieldProvider.auditReportsSingle(addresses: addresses)
    }

    func investmentsSingle(coinUid: String) -> Single<[CoinInvestment]> {
        hsProvider.coinInvestmentsSingle(coinUid: coinUid)
    }

    func treasuriesSingle(coinUid: String, currencyCode: String) -> Single<[CoinTreasury]> {
        hsProvider.coinTreasuriesSingle(coinUid: coinUid, currencyCode: currencyCode)
    }

    func coinReportsSingle(coinUid: String) -> Single<[CoinReport]> {
        hsProvider.coinReportsSingle(coinUid: coinUid)
    }

    func marketInfoTvlSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<[ChartPoint]> {
        hsProvider.marketInfoTvlSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    func marketInfoGlobalTvlSingle(platform: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<[ChartPoint]> {
        hsProvider.marketInfoGlobalTvlSingle(platform: platform, currencyCode: currencyCode, timePeriod: timePeriod)
    }

    func defiCoinsSingle(currencyCode: String) -> Single<[DefiCoin]> {
        hsProvider.defiCoinsSingle(currencyCode: currencyCode).map { [weak self] rawDefiCoins in
            self?.defiCoins(rawDefiCoins: rawDefiCoins) ?? []
        }
    }

    func twitterUsername(coinUid: String) -> Single<String?> {
        hsProvider.twitterUsername(coinUid: coinUid)
    }


    //Top Platforms

    func topPlatformsSingle(currencyCode: String) -> Single<[TopPlatform]> {
        hsProvider.topPlatformsSingle(currencyCode: currencyCode).map { responses in
            responses.map { $0.topPlatform }
        }
    }

    func topPlatformsCoinsListSingle(blockchain: String, currencyCode: String) -> Single<[MarketInfo]> {
        hsProvider.topPlatformCoinsListSingle(blockchain: blockchain, currencyCode: currencyCode)
                .map { [weak self] rawMarketInfos in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    //Pro charts

    func dexLiquiditySingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, sessionKey: String?) -> Single<DexLiquidityResponse> {
        hsProvider.dexLiquiditySingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, sessionKey: sessionKey)
    }

    func dexVolumesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, sessionKey: String?) -> Single<DexVolumeResponse> {
        hsProvider.dexVolumesSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, sessionKey: sessionKey)
    }

    func transactionDataSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, platform: String?, sessionKey: String?) -> Single<TransactionDataResponse> {
        hsProvider.transactionDataSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, platform: platform, sessionKey: sessionKey)
    }

    func activeAddressesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod, sessionKey: String?) -> Single<[ProChartPointDataResponse]> {
        hsProvider.activeAddressesSingle(coinUid: coinUid, currencyCode: currencyCode, timePeriod: timePeriod, sessionKey: sessionKey)
    }

    // Top Movers

    func topMoversSingle(currencyCode: String) -> Single<TopMovers> {
        hsProvider.topMoversRawSingle(currencyCode: currencyCode)
                .map { [weak self] raw in
                    TopMovers(
                            gainers100: self?.marketInfos(rawMarketInfos: raw.gainers100) ?? [],
                            gainers200: self?.marketInfos(rawMarketInfos: raw.gainers200) ?? [],
                            gainers300: self?.marketInfos(rawMarketInfos: raw.gainers300) ?? [],
                            losers100: self?.marketInfos(rawMarketInfos: raw.losers100) ?? [],
                            losers200: self?.marketInfos(rawMarketInfos: raw.losers200) ?? [],
                            losers300: self?.marketInfos(rawMarketInfos: raw.losers300) ?? []
                    )
                }
    }

}
