import Foundation
import HsToolKit

class CoinPriceSchedulerFactory {
    private let manager: CoinPriceManager
    private let hsProvider: HsProvider
    private let reachabilityManager: IReachabilityManager
    private var logger: Logger?

    init(manager: CoinPriceManager, hsProvider: HsProvider, reachabilityManager: IReachabilityManager, logger: Logger? = nil) {
        self.manager = manager
        self.hsProvider = hsProvider
        self.reachabilityManager = reachabilityManager
        self.logger = logger
    }

    func scheduler(currencyCode: String, coinUidDataSource: ICoinPriceCoinUidDataSource) -> Scheduler {
        let schedulerProvider = CoinPriceSchedulerProvider(
                manager: manager,
                hsProvider: hsProvider,
                currencyCode: currencyCode
        )

        schedulerProvider.dataSource = coinUidDataSource

        return Scheduler(provider: schedulerProvider, reachabilityManager: reachabilityManager, logger: logger)
    }

}
