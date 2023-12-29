public struct MarketOverview {
    public let globalMarketPoints: [GlobalMarketPoint]
    public let coinCategories: [CoinCategory]
    public let topPairs: [MarketPair]
    public let topPlatforms: [TopPlatform]
    public let collections: [HsTimePeriod: [NftTopCollection]]
}
