import RxSwift

class ChartSchedulerProvider {
    private let key: ChartInfoKey
    private let manager: ChartManager
    private let provider: CoinGeckoProvider

    let retryInterval: TimeInterval

    init(key: ChartInfoKey, manager: ChartManager, provider: CoinGeckoProvider, retryInterval: TimeInterval) {
        self.key = key
        self.manager = manager
        self.provider = provider
        self.retryInterval = retryInterval
    }

    private func handleUpdated(chartPoints: [ChartPoint]) {
        manager.handleUpdated(chartPoints: chartPoints, key: key)
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
        key.chartType.expirationInterval
    }

    var syncSingle: Single<Void> {
        provider.chartPointsSingle(key: key)
                .do(onSuccess: { [weak self] chartPoints in
                    self?.handleUpdated(chartPoints: chartPoints)
                }, onError: { [weak self] error in
                    if case CoinGeckoProvider.CoinGeckoError.noCoinGeckoId = error {
                        self?.handleNoChartPoints()
                    }
                })
                .map { _ in () }
    }

    func notifyExpired() {
        //todo: update if needed
    }

}
