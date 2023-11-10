import Foundation
import HsExtensions

class VerifiedExchangeSyncer {
    private let keyLastSyncTimestamp = "verified-exchange-syncer-last-sync-timestamp"

    private let exchangeManager: ExchangeManager
    private let hsProvider: HsProvider
    private let syncerStateStorage: SyncerStateStorage
    private var tasks = Set<AnyTask>()

    init(exchangeManager: ExchangeManager, hsProvider: HsProvider, syncerStateStorage: SyncerStateStorage) {
        self.exchangeManager = exchangeManager
        self.hsProvider = hsProvider
        self.syncerStateStorage = syncerStateStorage
    }

    private func handleFetch(error: Error) {
        print("Verified Exchanges fetch error: \(error)")
    }

    private func save(lastSyncTimestamp: Int) {
        try? syncerStateStorage.save(value: String(lastSyncTimestamp), key: keyLastSyncTimestamp)
    }
}

extension VerifiedExchangeSyncer {
    func sync(timestamp: Int) {
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyLastSyncTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), timestamp == lastSyncTimestamp {
            return
        }

        Task { [weak self, hsProvider] in
            do {
                let uids = try await hsProvider.verifiedExchangeUids()
                let verifiedExchanges = uids.map { VerifiedExchange(uid: $0) }

                self?.exchangeManager.handleFetched(verifiedExchanges: verifiedExchanges)
                self?.save(lastSyncTimestamp: timestamp)
            } catch {
                self?.handleFetch(error: error)
            }
        }.store(in: &tasks)
    }
}
