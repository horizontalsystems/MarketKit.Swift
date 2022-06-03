import RxSwift

class CoinSyncer {
    private let keyPlatformsLastSyncTimestamp = "coin-syncer-coins-last-sync-timestamp"
    private let keyCoinsLastSyncTimestamp = "coin-syncer-platforms-last-sync-timestamp"
    private let keyFullCoinsLastSyncTimestamp = "coin-syncer-full-coins-last-sync-timestamp"
    private let keyInitialSyncVersion = "coin-syncer-initial-sync-version"
    private let limit = 1000
    private let currentVersion = 1

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
                    let loadedFullCoins = loadedFullCoins + fullCoins

                    if fullCoins.count < limit {
                        return Single.just(loadedFullCoins)
                    }

                    return recursiveSyncSingle(page: page + 1, loadedFullCoins: loadedFullCoins)
                }
    }

    private func handleFetch(error: Error) {
        print("MarketCoins fetch error: \(error)")
    }

    private func saveCoins(lastSyncTimestamp: Int) {
        try? syncerStateStorage.save(value: String(lastSyncTimestamp), key: keyCoinsLastSyncTimestamp)
    }

    private func savePlatforms(lastSyncTimestamp: Int) {
        try? syncerStateStorage.save(value: String(lastSyncTimestamp), key: keyPlatformsLastSyncTimestamp)
    }

}

extension CoinSyncer {

    func initialSync() {
        do {
            if let versionString = try syncerStateStorage.value(key: keyInitialSyncVersion), let version = Int(versionString), currentVersion == version {
                return
            }

            guard let path = Kit.bundle?.path(forResource: "full_coins", ofType: "json") else {
                return
            }

            let jsonString = try String(contentsOfFile: path, encoding: .utf8)
            guard let responses = [FullCoinResponse](JSONString: jsonString) else {
                return
            }

            coinManager.handleFetched(fullCoins: responses.map { $0.fullCoin() })
            try syncerStateStorage.save(value: "\(currentVersion)", key: keyInitialSyncVersion)
            try syncerStateStorage.delete(key: keyCoinsLastSyncTimestamp)
            try syncerStateStorage.delete(key: keyPlatformsLastSyncTimestamp)
        } catch {
            print("CoinSyncer: initial sync error: \(error)")
        }
    }

    func coinsDump() throws -> String? {
        let fullCoins =  try coinManager.fullCoins(filter: "", limit: 1_000_000)

        let fullCoinResponses: [FullCoinResponse] = fullCoins.map { fullCoin in
            FullCoinResponse(
                    uid: fullCoin.coin.uid,
                    name: fullCoin.coin.name,
                    code: fullCoin.coin.code,
                    marketCapRank: fullCoin.coin.marketCapRank,
                    coinGeckoId: fullCoin.coin.coinGeckoId,
                    platforms: fullCoin.platforms.map { platform in
                        let coinTypeAttributes = platform.coinType.coinTypeAttributes
                        return PlatformResponse(
                                type: coinTypeAttributes.type,
                                decimals: platform.decimals,
                                address: coinTypeAttributes.address,
                                symbol: coinTypeAttributes.symbol
                        )
                    }
            )
        }

        return fullCoinResponses.toJSONString()
    }

    func sync(coinsTimestamp: Int, platformsTimestamp: Int) {
        var coinsOutdated = true
        var platformsOutdated = true
        var forceUpdateOutdated = true

        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyCoinsLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), coinsTimestamp == lastSyncTimestamp {
            coinsOutdated = false
        }
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyPlatformsLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), platformsTimestamp == lastSyncTimestamp {
            platformsOutdated = false
        }
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyFullCoinsLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), Date().timeIntervalSince1970 - Double(lastSyncTimestamp) < 60 * 60 * 24 {
            forceUpdateOutdated = false
        }

        guard coinsOutdated || platformsOutdated || forceUpdateOutdated else {
            return
        }

        recursiveSyncSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] fullCoins in
                    self?.coinManager.handleFetched(fullCoins: fullCoins)
                    self?.saveCoins(lastSyncTimestamp: coinsTimestamp)
                    self?.savePlatforms(lastSyncTimestamp: platformsTimestamp)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
