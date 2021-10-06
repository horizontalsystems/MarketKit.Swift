import RxSwift

protocol ICoinPriceCoinUidDataSource: AnyObject {
    func coinUids(currencyCode: String) -> [String]
}

class CoinPriceSchedulerProvider {
    private let currencyCode: String
    private let manager: CoinPriceManager
    private let hsProvider: HsProvider

    weak var dataSource: ICoinPriceCoinUidDataSource?

    init(manager: CoinPriceManager, hsProvider: HsProvider, currencyCode: String) {
        self.manager = manager
        self.hsProvider = hsProvider
        self.currencyCode = currencyCode
    }

    private var coinUids: [String] {
        dataSource?.coinUids(currencyCode: currencyCode) ?? []
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
        manager.lastSyncTimestamp(coinUids: coinUids, currencyCode: currencyCode)
    }

    var expirationInterval: TimeInterval {
        CoinPrice.expirationInterval
    }

    var syncSingle: Single<Void> {
        hsProvider.coinPricesSingle(coinUids: coinUids, currencyCode: currencyCode)
                .do(onSuccess: { [weak self] coinPrices in
                    self?.handle(updatedCoinPrices: coinPrices)
                })
                .map { _ in () }
    }

    func notifyExpired() {
        manager.notifyExpired(coinUids: coinUids, currencyCode: currencyCode)
    }

}
