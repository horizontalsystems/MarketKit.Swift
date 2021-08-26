import RxSwift
import RxRelay

class CoinManager {
    private let storage: CoinStorage

    private let marketCoinsRelay = PublishRelay<[MarketCoin]>()

    init(storage: CoinStorage) {
        self.storage = storage
    }

}

extension CoinManager {

    var marketCoinsObservable: Observable<[MarketCoin]> {
        marketCoinsRelay.asObservable()
    }

    func marketCoins(filter: String, limit: Int) throws -> [MarketCoin] {
        try storage.marketCoins(filter: filter, limit: limit)
    }

    func platformWithCoin(reference: String) throws -> PlatformWithCoin? {
        try storage.platformWithCoin(reference: reference)
    }

    func save(coin: Coin, platform: Platform) throws {
        try storage.save(coin: coin, platform: platform)
    }

    func handleFetched(marketCoins: [MarketCoin]) {
        do {
            try storage.save(marketCoins: marketCoins)
            marketCoinsRelay.accept(marketCoins)
        } catch {
            // todo
        }
    }

}
