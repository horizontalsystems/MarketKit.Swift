import RxSwift
import RxRelay

class CoinManager {
    private let storage: CoinStorage
    private let hsProvider: HsProvider
    private let categoryManager: CoinCategoryManager

    private let fullCoinsUpdatedRelay = PublishRelay<Void>()

    init(storage: CoinStorage, hsProvider: HsProvider, categoryManager: CoinCategoryManager) {
        self.storage = storage
        self.hsProvider = hsProvider
        self.categoryManager = categoryManager
    }

    func convertToMarketInfoArray(rawMarketInfoArray: [MarketInfoRaw]) -> [MarketInfo] {
        let fullCoins = (try? storage.fullCoins(coinUids: rawMarketInfoArray.map { $0.uid })) ?? []

        return fullCoins.compactMap { fullCoin in
            rawMarketInfoArray
                    .first { $0.uid == fullCoin.coin.uid }
                    .flatMap { $0.marketInfo(fullCoin: fullCoin) }
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
                .map { [weak self] (rawMarketInfoArray: [MarketInfoRaw]) -> [MarketInfo] in
                    self?.convertToMarketInfoArray(rawMarketInfoArray: rawMarketInfoArray) ?? []
                }
    }

    func marketInfosSingle(coinUids: [String], order: MarketInfo.Order?) -> Single<[MarketInfo]> {
        hsProvider.marketInfosSingle(coinUids: coinUids, order: order)
                .map { [weak self] (rawMarketInfoArray: [MarketInfoRaw]) -> [MarketInfo] in
                    self?.convertToMarketInfoArray(rawMarketInfoArray: rawMarketInfoArray) ?? []
                }
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverview> {
        hsProvider.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)
                .map { [weak self] (rawMarketInfoOverview: MarketInfoOverviewRaw) -> MarketInfoOverview in
                    let categories = (try? self?.categoryManager.categories(uids: rawMarketInfoOverview.categoryIds)) ?? []

                    return rawMarketInfoOverview.marketInfoOverview(categories: categories)
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
