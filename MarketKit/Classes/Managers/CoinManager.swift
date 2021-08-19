class CoinManager {
    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

}

extension CoinManager {

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
        } catch {
            // todo
        }
    }

}
