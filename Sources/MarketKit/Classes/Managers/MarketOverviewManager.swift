import Foundation

class MarketOverviewManager {
    private let nftManager: NftManager
    private let hsProvider: HsProvider

    init(nftManager: NftManager, hsProvider: HsProvider) {
        self.nftManager = nftManager
        self.hsProvider = hsProvider
    }
}

extension MarketOverviewManager {
    func marketOverview(currencyCode: String) async throws -> MarketOverview {
        let response = try await hsProvider.marketOverview(currencyCode: currencyCode)

        return MarketOverview(
            globalMarketPoints: response.globalMarketPoints,
            coinCategories: response.coinCategories,
            topPairs: response.topPairs,
            topPlatforms: response.topPlatforms.map(\.topPlatform),
            collections: [
                .day1: nftManager.topCollections(responses: response.collections1d),
                .week1: nftManager.topCollections(responses: response.collections1w),
                .month1: nftManager.topCollections(responses: response.collections1m),
            ]
        )
    }
}
