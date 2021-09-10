import RxSwift
import RxRelay

class CoinManager {
    private let storage: CoinStorage

    private let marketCoinsUpdatedRelay = PublishRelay<Void>()

    init(storage: CoinStorage) {
        self.storage = storage
    }

}

extension CoinManager {

    var marketCoinsUpdatedObservable: Observable<Void> {
        marketCoinsUpdatedRelay.asObservable()
    }

    func marketCoins(filter: String, limit: Int) throws -> [MarketCoin] {
        try storage.marketCoins(filter: filter, limit: limit)
    }

    func marketCoins(coinUids: [String]) throws -> [MarketCoin] {
        try storage.marketCoins(coinUids: coinUids)
    }

    func marketCoins(coinTypes: [CoinType]) throws -> [MarketCoin] {
        try storage.marketCoins(coinTypes: coinTypes)
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

    func save(coin: Coin, platform: Platform) throws {
        try storage.save(coin: coin, platform: platform)
        marketCoinsUpdatedRelay.accept(())
    }

    func coins(filter: String, limit: Int) throws -> [Coin] {
        try storage.coins(filter: filter, limit: limit)
    }

    func handleFetched(marketCoins: [MarketCoin]) {
        do {
            try storage.save(marketCoins: marketCoins)
            marketCoinsUpdatedRelay.accept(())
        } catch {
            // todo
        }
    }

}
