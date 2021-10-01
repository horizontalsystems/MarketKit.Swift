import RxSwift
import RxRelay

class CoinCategoryManager {
    private let storage: CoinCategoryStorage

    private let coinCategoriesRelay = PublishRelay<[CoinCategory]>()

    init(storage: CoinCategoryStorage) {
        self.storage = storage
    }

}

extension CoinCategoryManager {

    var coinCategoriesObservable: Observable<[CoinCategory]> {
        coinCategoriesRelay.asObservable()
    }

    func coinCategories() throws -> [CoinCategory] {
        try storage.coinCategories()
    }

    func handleFetched(coinCategories: [CoinCategory]) {
        do {
            try storage.save(coinCategories: coinCategories)
            coinCategoriesRelay.accept(coinCategories)
        } catch {
            // todo
        }
    }

    func categories(uids: [String]) throws -> [CoinCategory] {
        try storage.categories(uids: uids)
    }

}
