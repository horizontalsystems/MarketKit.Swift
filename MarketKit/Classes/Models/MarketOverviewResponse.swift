import ObjectMapper

struct MarketOverviewResponse: ImmutableMappable {
    let globalMarketPoints: [GlobalMarketPoint]
    let coinCategories: [CoinCategory]
    let topPlatforms: [TopPlatformResponse]
    let collections1d: [NftTopCollectionResponse]
    let collections1w: [NftTopCollectionResponse]
    let collections1m: [NftTopCollectionResponse]

    init(map: Map) throws {
        globalMarketPoints = try map.value("global")
        coinCategories = try map.value("sectors")
        topPlatforms = try map.value("platforms")
        collections1d = try map.value("nft.one_day")
        collections1w = try map.value("nft.seven_day")
        collections1m = try map.value("nft.thirty_day")
    }
}
