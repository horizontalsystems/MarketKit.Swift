import Foundation
import HsExtensions

class ExchangeSyncer {
    private let keyLastSyncTimestamp = "exchange-syncer-last-sync-timestamp"
    private let syncPeriod: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    private let exchangeManager: ExchangeManager
    private let coinGeckoProvider: CoinGeckoProvider
    private let syncerStateStorage: SyncerStateStorage
    private var tasks = Set<AnyTask>()

    init(exchangeManager: ExchangeManager, coinGeckoProvider: CoinGeckoProvider, syncerStateStorage: SyncerStateStorage) {
        self.exchangeManager = exchangeManager
        self.coinGeckoProvider = coinGeckoProvider
        self.syncerStateStorage = syncerStateStorage
    }

    private func handleFetch(error: Error) {
        print("MarketCoins fetch error: \(error)")
    }

    private func fetch(limit: Int, page: Int) async throws -> [Exchange] {
        let exchanges = try await coinGeckoProvider.exchanges(limit: limit, page: page)

        guard exchanges.count == limit else {
            return exchanges
        }

        let more = try await fetch(limit: limit, page: page + 1)
        return exchanges + more
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

        Task { [weak self] in
            do {
                let exchanges = try await self?.fetch(limit: 250, page: 0)

                self?.exchangeManager.handleFetched(exchanges: exchanges ?? [])
                self?.save(lastSyncTimestamp: currentTimestamp)
            } catch {
                self?.handleFetch(error: error)
            }
        }.store(in: &tasks)
    }
}
