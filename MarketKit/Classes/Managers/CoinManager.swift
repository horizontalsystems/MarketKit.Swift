import RxSwift
import RxRelay

class CoinManager {
    private let storage: CoinStorage
    private let hsProvider: HsProvider

    private let fullCoinsUpdatedRelay = PublishRelay<Void>()

    init(storage: CoinStorage, hsProvider: HsProvider) {
        self.storage = storage
        self.hsProvider = hsProvider
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
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoOverview> {
        hsProvider.marketInfoOverviewSingle(coinUid: coinUid, currencyCode: currencyCode)
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
