import Foundation
import HsToolKit

class ChartSchedulerFactory {
    private let manager: ChartManager
    private let hsProvider: HsProvider
    private let reachabilityManager: IReachabilityManager
    private let retryInterval: TimeInterval
    private let indicatorPoints: Int
    private var logger: Logger?

    init(manager: ChartManager, hsProvider: HsProvider, reachabilityManager: IReachabilityManager, retryInterval: TimeInterval, indicatorPoints: Int, logger: Logger? = nil) {
        self.manager = manager
        self.hsProvider = hsProvider
        self.reachabilityManager = reachabilityManager
        self.retryInterval = retryInterval
        self.indicatorPoints = indicatorPoints
        self.logger = logger
    }

    func scheduler(key: ChartInfoKey) -> Scheduler {
        let schedulerProvider = ChartSchedulerProvider(key: key, manager: manager, hsProvider: hsProvider, retryInterval: retryInterval, indicatorPoints: indicatorPoints)
        return Scheduler(provider: schedulerProvider, reachabilityManager: reachabilityManager, logger: logger)
    }

}
