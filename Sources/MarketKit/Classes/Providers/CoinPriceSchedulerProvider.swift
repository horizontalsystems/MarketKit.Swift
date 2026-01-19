import Foundation

protocol ICoinPriceCoinUidDataSource: AnyObject {
    func allCoinUids(currencyCode: String) -> [String]
}

class CoinPriceSchedulerProvider {
    private let currencyCode: String
    private let manager: CoinPriceManager
    private let provider: HsProvider

    weak var dataSource: ICoinPriceCoinUidDataSource?

    init(manager: CoinPriceManager, provider: HsProvider, currencyCode: String) {
        self.manager = manager
        self.provider = provider
        self.currencyCode = currencyCode
    }

    private var allCoinUids: [String] {
        dataSource?.allCoinUids(currencyCode: currencyCode) ?? []
    }

    private func handle(updatedCoinPrices: [CoinPrice]) {
        manager.handleUpdated(coinPrices: updatedCoinPrices, currencyCode: currencyCode)
    }
}

extension CoinPriceSchedulerProvider: ISchedulerProvider {
    var id: String {
        "CoinPriceProvider"
    }

    var lastSyncTimestamp: TimeInterval? {
        manager.lastSyncTimestamp(coinUids: allCoinUids, currencyCode: currencyCode)
    }

    var expirationInterval: TimeInterval {
        CoinPrice.expirationInterval
    }

    func sync() async throws {
        guard let coinUids = dataSource?.allCoinUids(currencyCode: currencyCode), !coinUids.isEmpty else {
            return
        }

        let coinPrices = try await provider.coinPrices(coinUids: coinUids, currencyCode: currencyCode)
        handle(updatedCoinPrices: coinPrices)
    }

    func notifyExpired() {
        manager.notifyExpired(coinUids: allCoinUids, currencyCode: currencyCode)
    }
}
