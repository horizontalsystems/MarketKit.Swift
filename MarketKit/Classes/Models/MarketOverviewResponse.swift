import ObjectMapper

struct MarketOverviewResponse: ImmutableMappable {
    let globalMarketPoints: [GlobalMarketPoint]
    let coinCategories: [CoinCategory]
    let topPlatforms: [TopPlatformResponse]

    init(map: Map) throws {
        globalMarketPoints = try map.value("global")
        coinCategories = try map.value("sectors")
        topPlatforms = try map.value("platforms")
    }

    var marketOverview: MarketOverview {
        MarketOverview(
                globalMarketPoints: globalMarketPoints,
                coinCategories: coinCategories,
                topPlatforms: topPlatforms.map { $0.topPlatform }
        )
    }
}
