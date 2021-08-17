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

    func handleFetched(marketCoins: [MarketCoin]) {
        do {
            try storage.save(marketCoins: marketCoins)
        } catch {
            // todo
        }
    }

}
