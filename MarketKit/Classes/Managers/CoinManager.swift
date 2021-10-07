import RxSwift
import RxRelay

class CoinManager {
    private let storage: CoinStorage
    private let hsProvider: HsProvider
    private let coinGeckoProvider: CoinGeckoProvider
    private let categoryManager: CoinCategoryManager
    private let exchangeManager: ExchangeManager

    private let fullCoinsUpdatedRelay = PublishRelay<Void>()

    init(storage: CoinStorage, hsProvider: HsProvider, coinGeckoProvider: CoinGeckoProvider, categoryManager: CoinCategoryManager, exchangeManager: ExchangeManager) {
        self.storage = storage
        self.hsProvider = hsProvider
        self.coinGeckoProvider = coinGeckoProvider
        self.categoryManager = categoryManager
        self.exchangeManager = exchangeManager
    }

    func marketInfos(rawMarketInfos: [MarketInfoRaw]) -> [MarketInfo] {
        do {
            let fullCoins = try storage.fullCoins(coinUids: rawMarketInfos.map { $0.uid })
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
}

extension CoinManager {

    var fullCoinsUpdatedObservable: Observable<Void> {
        fullCoinsUpdatedRelay.asObservable()
    }

    func fullCoins(filter: String, limit: Int) throws -> [FullCoin] {
        try storage.fullCoins(filter: filter, limit: limit)
    }

    func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try storage.fullCoins(coinUids: coinUids)
    }

    func fullCoins(coinTypes: [CoinType]) throws -> [FullCoin] {
        try storage.fullCoins(coinTypes: coinTypes)
    }

    func marketInfosSingle(top: Int, limit: Int?, order: MarketInfo.Order?) -> Single<[MarketInfo]> {
        hsProvider.marketInfosSingle(top: top, limit: limit, order: order)
                .map { [weak self] rawMarketInfos -> [MarketInfo] in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    func marketInfosSingle(coinUids: [String], order: MarketInfo.Order?) -> Single<[MarketInfo]> {
        hsProvider.marketInfosSingle(coinUids: coinUids, order: order)
                .map { [weak self] rawMarketInfos -> [MarketInfo] in
                    self?.marketInfos(rawMarketInfos: rawMarketInfos) ?? []
                }
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverview> {
        hsProvider.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
                .map { [weak self] (rawMarketInfoOverview: MarketInfoOverviewRaw) -> MarketInfoOverview in
                    rawMarketInfoOverview.marketInfoOverview(categories: self?.categoryManager.coinCategories(uids: rawMarketInfoOverview.categoryIds) ?? [])
                }
    }

    func marketTickerSingle(coinUid: String) -> Single<[MarketTicker]> {
        guard let coin = try? storage.coin(uid: coinUid),
              let coinGeckoId = coin.coinGeckoId else {
            return Single.just([])
        }

        return coinGeckoProvider.marketTickersSingle(coinId: coinGeckoId)
                .map { [weak self] response in
                    response.marketTickers(imageUrls: self?.exchangeManager.imageUrlsMap(ids: response.exchangeIds) ?? [:])
                }
    }

    func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try storage.platformCoin(coinType: coinType)
    }

    func platformCoins() throws -> [PlatformCoin] {
        try storage.platformCoins()
    }

    func platformCoins(coinTypes: [CoinType]) throws -> [PlatformCoin] {
        try storage.platformCoins(coinTypeIds: coinTypes.map { $0.id} )
    }

    func platformCoins(coinTypeIds: [String]) throws -> [PlatformCoin] {
        try storage.platformCoins(coinTypeIds: coinTypeIds)
    }

    func coins(filter: String, limit: Int) throws -> [Coin] {
        try storage.coins(filter: filter, limit: limit)
    }

    func handleFetched(fullCoins: [FullCoin]) {
        do {
            try storage.save(fullCoins: fullCoins)
            fullCoinsUpdatedRelay.accept(())
        } catch {
            // todo
        }
    }

}
