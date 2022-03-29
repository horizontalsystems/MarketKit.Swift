import RxSwift

class CoinCategorySyncer {
    private let keyLastSyncTimestamp = "coin-category-syncer-last-sync-timestamp"

    private let coinCategoryManager: CoinCategoryManager
    private let hsProvider: HsProvider
    private let syncerStateStorage: SyncerStateStorage
    private let disposeBag = DisposeBag()

    init(coinCategoryManager: CoinCategoryManager, hsProvider: HsProvider, syncerStateStorage: SyncerStateStorage) {
        self.coinCategoryManager = coinCategoryManager
        self.hsProvider = hsProvider
        self.syncerStateStorage = syncerStateStorage
    }

    private func handleFetch(error: Error) {
        print("CoinCategories fetch error: \(error)")
    }

    private func save(lastSyncTimestamp: Int) {
        try? syncerStateStorage.save(value: String(lastSyncTimestamp), key: keyLastSyncTimestamp)
    }

}

extension CoinCategorySyncer {

    func sync(timestamp: Int) {
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), timestamp == lastSyncTimestamp {
            return
        }

        hsProvider.coinCategoriesSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] coinCategories in
                    self?.coinCategoryManager.handleFetched(coinCategories: coinCategories)
                    self?.save(lastSyncTimestamp: timestamp)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

    func categoryMarketDataSingle(currencyCode: String) -> Single<[CoinCategoryMarketData]> {
        hsProvider.coinCategoriesMarketDataSingle(currencyCode: currencyCode)
    }

}
