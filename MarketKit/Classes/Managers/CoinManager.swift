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

    func platformWithCoin(reference: String) throws -> PlatformWithCoin? {
        try storage.platformWithCoin(reference: reference)
    }

    func save(coin: Coin, platform: Platform) throws {
        try storage.save(coin: coin, platform: platform)
        marketCoinsUpdatedRelay.accept(())
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
