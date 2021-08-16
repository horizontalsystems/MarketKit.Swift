class CoinManager {
    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

}

extension CoinManager {

    func coins(filter: String) throws -> [Coin] {
        try storage.coins(filter: filter)
    }

    func handleFetched(coins: [Coin]) {
        do {
            try storage.save(coins: coins)
        } catch {
            // todo
        }
    }

}
