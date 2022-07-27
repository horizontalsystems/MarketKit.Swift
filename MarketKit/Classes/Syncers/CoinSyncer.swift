import RxSwift
import RxRelay

class CoinSyncer {
    private let keyCoinsLastSyncTimestamp = "coin-syncer-coins-last-sync-timestamp"
    private let keyBlockchainsLastSyncTimestamp = "coin-syncer-blockchains-last-sync-timestamp"
    private let keyTokensLastSyncTimestamp = "coin-syncer-tokens-last-sync-timestamp"
    private let keyInitialSyncVersion = "coin-syncer-initial-sync-version"
    private let limit = 1000
    private let currentVersion = 2

    private let storage: CoinStorage
    private let hsProvider: HsProvider
    private let syncerStateStorage: SyncerStateStorage
    private let disposeBag = DisposeBag()

    private let fullCoinsUpdatedRelay = PublishRelay<Void>()

    init(storage: CoinStorage, hsProvider: HsProvider, syncerStateStorage: SyncerStateStorage) {
        self.storage = storage
        self.hsProvider = hsProvider
        self.syncerStateStorage = syncerStateStorage
    }

    private func saveLastSyncTimestamps(coins: Int, blockchains: Int, tokens: Int) {
        try? syncerStateStorage.save(value: String(coins), key: keyCoinsLastSyncTimestamp)
        try? syncerStateStorage.save(value: String(blockchains), key: keyBlockchainsLastSyncTimestamp)
        try? syncerStateStorage.save(value: String(tokens), key: keyTokensLastSyncTimestamp)
    }

    func handleFetched(coins: [Coin], blockchainRecords: [BlockchainRecord], tokenRecords: [TokenRecord]) {
        do {
            try storage.update(coins: coins, blockchainRecords: blockchainRecords, tokenRecords: tokenRecords)
            fullCoinsUpdatedRelay.accept(())
        } catch {
            print("Fetched data error: \(error)")
        }
    }

}

extension CoinSyncer {

    var fullCoinsUpdatedObservable: Observable<Void> {
        fullCoinsUpdatedRelay.asObservable()
    }

    func initialSync() {
        do {
            if let versionString = try syncerStateStorage.value(key: keyInitialSyncVersion), let version = Int(versionString), currentVersion == version {
                return
            }

            guard let coinsPath = Kit.bundle?.path(forResource: "coins", ofType: "json") else {
                return
            }
            guard let blockchainsPath = Kit.bundle?.path(forResource: "blockchains", ofType: "json") else {
                return
            }
            guard let tokensPath = Kit.bundle?.path(forResource: "tokens", ofType: "json") else {
                return
            }

            guard let coins = [Coin](JSONString: try String(contentsOfFile: coinsPath, encoding: .utf8)) else {
                return
            }
            guard let blockchainRecords = [BlockchainRecord](JSONString: try String(contentsOfFile: blockchainsPath, encoding: .utf8)) else {
                return
            }
            guard let tokenRecords = [TokenRecord](JSONString: try String(contentsOfFile: tokensPath, encoding: .utf8)) else {
                return
            }

            try storage.update(coins: coins, blockchainRecords: blockchainRecords, tokenRecords: tokenRecords)

            try syncerStateStorage.save(value: "\(currentVersion)", key: keyInitialSyncVersion)
            try syncerStateStorage.delete(key: keyCoinsLastSyncTimestamp)
            try syncerStateStorage.delete(key: keyBlockchainsLastSyncTimestamp)
            try syncerStateStorage.delete(key: keyTokensLastSyncTimestamp)
        } catch {
            print("CoinSyncer: initial sync error: \(error)")
        }
    }

    func coinsDump() throws -> String? {
        let coins = try storage.allCoins()
        return coins.toJSONString()
    }

    func blockchainsDump() throws -> String? {
        let blockchainRecords = try storage.allBlockchainRecords()
        return blockchainRecords.toJSONString()
    }

    func tokenRecordsDump() throws -> String? {
        let tokenRecords = try storage.allTokenRecords()
        return tokenRecords.toJSONString()
    }

    func sync(coinsTimestamp: Int, blockchainsTimestamp: Int, tokensTimestamp: Int) {
        var coinsOutdated = true
        var blockchainsOutdated = true
        var tokensOutdated = true

        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyCoinsLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), coinsTimestamp == lastSyncTimestamp {
            coinsOutdated = false
        }
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyBlockchainsLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), blockchainsTimestamp == lastSyncTimestamp {
            blockchainsOutdated = false
        }
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyTokensLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), tokensTimestamp == lastSyncTimestamp {
            tokensOutdated = false
        }

        guard coinsOutdated || blockchainsOutdated || tokensOutdated else {
            return
        }

        Single.zip(hsProvider.allCoinsSingle(), hsProvider.allBlockchainRecordsSingle(), hsProvider.allTokenRecordsSingle())
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] coins, blockchainRecords, tokenRecords in
                    self?.handleFetched(coins: coins, blockchainRecords: blockchainRecords, tokenRecords: tokenRecords)
                    self?.saveLastSyncTimestamps(coins: coinsTimestamp, blockchains: blockchainsTimestamp, tokens: tokensTimestamp)
                }, onError: { error in
                    print("Market data fetch error: \(error)")
                })
                .disposed(by: disposeBag)
    }

}
