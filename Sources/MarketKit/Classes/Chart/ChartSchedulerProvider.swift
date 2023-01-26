import Foundation
import RxSwift

class ChartSchedulerProvider {
    private let key: ChartInfoKey
    private let manager: ChartManager
    private let hsProvider: HsProvider

    private let indicatorPoints: Int
    private let retryInterval: TimeInterval

    init(key: ChartInfoKey, manager: ChartManager, hsProvider: HsProvider, retryInterval: TimeInterval, indicatorPoints: Int) {
        self.key = key
        self.manager = manager
        self.hsProvider = hsProvider
        self.retryInterval = retryInterval
        self.indicatorPoints = indicatorPoints
    }

    private func handleUpdated(chartCoinPriceResponse: [HsProvider.ChartCoinPriceResponse]) {
        let points = chartCoinPriceResponse.map {
            $0.chartPoint
        }

        manager.handleUpdated(chartPoints: points, key: key)
    }

    private func handleNoChartPoints() {
        manager.handleNoChartPoints(key: key)
    }

}

extension ChartSchedulerProvider: ISchedulerProvider {

    var id: String {
        "\(key)"
    }

    var lastSyncTimestamp: TimeInterval? {
        manager.lastSyncTimestamp(key: key)
    }

    var expirationInterval: TimeInterval {
        key.periodType.expiration
    }

    var syncSingle: Single<Void> {
        hsProvider.coinPriceChartSingle(coinUid: key.coin.uid, currencyCode: key.currencyCode, periodType: key.periodType, indicatorPoints: indicatorPoints)
                .do(onSuccess: { [weak self] response in
                    self?.handleUpdated(chartCoinPriceResponse: response)
                }, onError: { [weak self] error in
                    self?.handleNoChartPoints()
                })
                .map { _ in
                    ()
                }
    }

    func notifyExpired() {
        //todo: update if needed
    }

}
