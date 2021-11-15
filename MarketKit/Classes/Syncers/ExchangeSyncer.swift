import RxSwift

class ExchangeSyncer {
    private let keyLastSyncTimestamp = "exchange-syncer-last-sync-timestamp"
    private let syncPeriod: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    private let exchangeManager: ExchangeManager
    private let coinGeckoProvider: CoinGeckoProvider
    private let syncerStateStorage: SyncerStateStorage
    private let disposeBag = DisposeBag()

    init(exchangeManager: ExchangeManager, coinGeckoProvider: CoinGeckoProvider, syncerStateStorage: SyncerStateStorage) {
        self.exchangeManager = exchangeManager
        self.coinGeckoProvider = coinGeckoProvider
        self.syncerStateStorage = syncerStateStorage
    }

    private func handleFetch(error: Error) {
        print("MarketCoins fetch error: \(error)")
    }

    private func fetch(limit: Int, page: Int) -> Single<[Exchange]> {
        coinGeckoProvider.exchangesSingle(limit: limit, page: page)
                .flatMap { [weak self] exchanges -> Single<[Exchange]> in
                    guard let syncer = self else {
                        return Single.just([])
                    }

                    guard exchanges.count == limit else {
                        return Single.just(exchanges)
                    }

                    return syncer.fetch(limit: limit, page: page + 1).map { exchanges + $0 }
                }
    }

    private func save(lastSyncTimestamp: TimeInterval) {
        try? syncerStateStorage.save(value: String(lastSyncTimestamp), key: keyLastSyncTimestamp)
    }

}

extension ExchangeSyncer {

    func sync() {
        let currentTimestamp = Date().timeIntervalSince1970

        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyLastSyncTimestamp), let lastSyncTimestamp = Double(rawLastSyncTimestamp), currentTimestamp - lastSyncTimestamp < syncPeriod {
            return
        }

        fetch(limit: 250, page: 0)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] exchanges in
                    self?.exchangeManager.handleFetched(exchanges: exchanges)
                    self?.save(lastSyncTimestamp: currentTimestamp)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
