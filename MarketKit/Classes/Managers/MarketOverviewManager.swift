import Foundation
import RxSwift

class MarketOverviewManager {
    private let nftManager: NftManager
    private let hsProvider: HsProvider

    init(nftManager: NftManager, hsProvider: HsProvider) {
        self.nftManager = nftManager
        self.hsProvider = hsProvider
    }

    private func marketOverview(response: MarketOverviewResponse) -> MarketOverview {
        MarketOverview(
                globalMarketPoints: response.globalMarketPoints,
                coinCategories: response.coinCategories,
                topPlatforms: response.topPlatforms.map { $0.topPlatform },
                collections: [
                    .day1: nftManager.collections(responses: response.collections1d),
                    .week1: nftManager.collections(responses: response.collections1w),
                    .month1: nftManager.collections(responses: response.collections1m)
                ]
        )
    }

}

extension MarketOverviewManager {

    func marketOverviewSingle(currencyCode: String) -> Single<MarketOverview> {
        hsProvider.marketOverviewSingle(currencyCode: currencyCode)
                .map { [unowned self] in marketOverview(response: $0) }
    }

}
