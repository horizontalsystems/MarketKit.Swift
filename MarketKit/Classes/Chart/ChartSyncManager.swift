import RxSwift

class ChartSyncManager {
    private let coinManager: CoinManager
    private let schedulerFactory: ChartSchedulerFactory
    private let chartInfoManager: ChartManager
    private let coinPriceSyncManager: CoinPriceSyncManager

    private var subjects = [ChartInfoKey: PublishSubject<ChartInfo>]()
    private var schedulers = [ChartInfoKey: Scheduler]()

    private var failedKeys = [ChartInfoKey]()

    private let queue = DispatchQueue(label: "io.horizontalsystems.x_rates_kit.chart_info_sync_manager", qos: .userInitiated)

    init(coinManager: CoinManager, schedulerFactory: ChartSchedulerFactory, chartInfoManager: ChartManager, coinPriceSyncManager: CoinPriceSyncManager) {
        self.coinManager = coinManager
        self.schedulerFactory = schedulerFactory
        self.chartInfoManager = chartInfoManager
        self.coinPriceSyncManager = coinPriceSyncManager
    }

    private func subject(key: ChartInfoKey) -> PublishSubject<ChartInfo> {
        if let subject = subjects[key] {
            return subject
        }

        let subject = PublishSubject<ChartInfo>()
        subjects[key] = subject
        return subject
    }

    private func scheduler(key: ChartInfoKey) -> Scheduler {
        if let scheduler = schedulers[key] {
            return scheduler
        }

        let scheduler = schedulerFactory.scheduler(key: key)
        schedulers[key] = scheduler

        return scheduler
    }

    private func cleanUp(key: ChartInfoKey) {
        if let subject = subjects[key], subject.hasObservers {
            return
        }

        subjects[key] = nil
        schedulers[key] = nil
    }

    private func onSubscribed(key: ChartInfoKey) {
        queue.async {
            self.scheduler(key: key).schedule()
        }
    }

    private func onDisposed(key: ChartInfoKey) {
        queue.async {
            self.cleanUp(key: key)
        }
    }

}

extension ChartSyncManager {

    func chartInfoObservable(coinUid: String, currencyCode: String, chartType: ChartType) -> Observable<ChartInfo> {
        queue.sync {
            guard let fullCoin = try? coinManager.fullCoins(coinUids: [coinUid]).first else {
                return Observable.error(Kit.KitError.noChartData)
            }
            let key = ChartInfoKey(coin: fullCoin.coin, currencyCode: currencyCode, chartType: chartType)

            guard !failedKeys.contains(key) else {
                return Observable.error(Kit.KitError.noChartData)
            }

            return subject(key: key)
                    .do(onSubscribed: { [weak self] in
                        self?.onSubscribed(key: key)
                    }, onDispose: { [weak self] in
                        self?.onDisposed(key: key)
                    })
        }
    }

}

extension ChartSyncManager: IChartInfoManagerDelegate {

    func didUpdate(chartInfo: ChartInfo, key: ChartInfoKey) {
        queue.async {
            self.subjects[key]?.onNext(chartInfo)
        }
    }

    func didFoundNoChartInfo(key: ChartInfoKey) {
        queue.async {
            self.failedKeys.append(key)
            self.subjects[key]?.onError(Kit.KitError.noChartData)
        }
    }

}
