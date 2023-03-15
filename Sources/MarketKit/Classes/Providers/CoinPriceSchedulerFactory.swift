import Foundation
import HsToolKit

class CoinPriceSchedulerFactory {
    private let manager: CoinPriceManager
    private let provider: CoinGeckoProvider
    private let reachabilityManager: IReachabilityManager
    private var logger: Logger?

    init(manager: CoinPriceManager, provider: CoinGeckoProvider, reachabilityManager: IReachabilityManager, logger: Logger? = nil) {
        self.manager = manager
        self.provider = provider
        self.reachabilityManager = reachabilityManager
        self.logger = logger
    }

    func scheduler(currencyCode: String, coinUidDataSource: ICoinPriceCoinUidDataSource) -> Scheduler {
        let schedulerProvider = CoinPriceSchedulerProvider(
                manager: manager,
                provider: provider,
                currencyCode: currencyCode
        )

        schedulerProvider.dataSource = coinUidDataSource

        return Scheduler(provider: schedulerProvider, reachabilityManager: reachabilityManager, logger: logger)
    }

}
