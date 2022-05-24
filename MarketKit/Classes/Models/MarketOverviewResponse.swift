import ObjectMapper

struct MarketOverviewResponse: ImmutableMappable {
    let globalMarketPoints: [GlobalMarketPoint]
    let coinCategories: [CoinCategory]
    let topPlatforms: [TopPlatformResponse]
    let collections1d: [NftCollectionResponse]
    let collections1w: [NftCollectionResponse]
    let collections1m: [NftCollectionResponse]

    init(map: Map) throws {
        globalMarketPoints = try map.value("global")
        coinCategories = try map.value("sectors")
        topPlatforms = try map.value("platforms")
        collections1d = try map.value("nft.one_day")
        collections1w = try map.value("nft.seven_day")
        collections1m = try map.value("nft.thirty_day")
    }
}
