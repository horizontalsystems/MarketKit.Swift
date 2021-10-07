import Foundation
import HsToolKit

class ChartSchedulerFactory {
    private let manager: ChartManager
    private let provider: CoinGeckoProvider
    private let reachabilityManager: IReachabilityManager
    private let retryInterval: TimeInterval
    private var logger: Logger?

    init(manager: ChartManager, provider: CoinGeckoProvider, reachabilityManager: IReachabilityManager, retryInterval: TimeInterval, logger: Logger? = nil) {
        self.manager = manager
        self.provider = provider
        self.reachabilityManager = reachabilityManager
        self.retryInterval = retryInterval
        self.logger = logger
    }

    func scheduler(key: ChartInfoKey) -> Scheduler {
        let schedulerProvider = ChartSchedulerProvider(key: key, manager: manager, provider: provider, retryInterval: retryInterval)
        return Scheduler(provider: schedulerProvider, reachabilityManager: reachabilityManager, logger: logger)
    }

}
