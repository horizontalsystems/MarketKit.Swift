class CoinCategoryManager {
    private let storage: CoinCategoryStorage

    init(storage: CoinCategoryStorage) {
        self.storage = storage
    }

}

extension CoinCategoryManager {

    func coinCategories() throws -> [CoinCategory] {
        try storage.coinCategories()
    }

    func handleFetched(coinCategories: [CoinCategory]) {
        do {
            try storage.save(coinCategories: coinCategories)
        } catch {
            // todo
        }
    }

}
