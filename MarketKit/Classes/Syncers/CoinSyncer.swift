import RxSwift

class CoinSyncer {
    private let keyLastSyncTimestamp = "coin-syncer-last-sync-timestamp"
    private let syncPeriod: TimeInterval = 24 * 60 * 60 // 1 day
    private let limit = 1000

    private let coinManager: CoinManager
    private let hsProvider: HsProvider
    private let syncerStateStorage: SyncerStateStorage
    private let disposeBag = DisposeBag()

    init(coinManager: CoinManager, hsProvider: HsProvider, syncerStateStorage: SyncerStateStorage) {
        self.coinManager = coinManager
        self.hsProvider = hsProvider
        self.syncerStateStorage = syncerStateStorage
    }

    private func recursiveSyncSingle(page: Int = 1, loadedFullCoins: [FullCoin] = []) -> Single<[FullCoin]> {
        hsProvider.fullCoinsSingle(page: page, limit: limit)
                .flatMap { [unowned self] fullCoins in
                    if fullCoins.count < limit {
                        return Single.just(loadedFullCoins)
                    }

                    return recursiveSyncSingle(page: page + 1, loadedFullCoins: loadedFullCoins + fullCoins)
                }
    }

    private func handleFetch(error: Error) {
        print("MarketCoins fetch error: \(error)")
    }

    private func save(lastSyncTimestamp: TimeInterval) {
        try? syncerStateStorage.save(value: String(lastSyncTimestamp), key: keyLastSyncTimestamp)
    }

}

extension CoinSyncer {

    func initialSync() {
        do {
            guard try coinManager.coinsCount() == 0 else {
                return
            }

            guard let path = Kit.bundle?.path(forResource: "full_coins", ofType: "json") else {
                return
            }

            let jsonString = try String(contentsOfFile: path, encoding: .utf8)
            guard let responses = try [FullCoinResponse](JSONString: jsonString) else {
                return
            }

            coinManager.handleFetched(fullCoins: responses.map { $0.fullCoin() })
        } catch {
            print("CoinSyncer: initial sync error: \(error)")
        }
    }

    func sync() {
        let currentTimestamp = Date().timeIntervalSince1970

        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyLastSyncTimestamp), let lastSyncTimestamp = Double(rawLastSyncTimestamp), currentTimestamp - lastSyncTimestamp < syncPeriod {
            return
        }

        recursiveSyncSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] fullCoins in
                    self?.coinManager.handleFetched(fullCoins: fullCoins)
                    self?.save(lastSyncTimestamp: currentTimestamp)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
