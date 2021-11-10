import Foundation

public struct MarketInfoOverview {
    public let marketCap: Decimal?
    public let marketCapRank: Int?
    public let totalSupply: Decimal?
    public let circulatingSupply: Decimal?
    public let volume24h: Decimal?
    public let dilutedMarketCap: Decimal?
    public let tvl: Decimal?
    public let performance: [PerformanceRow]
    public let genesisDate: Date?
    public let categories: [CoinCategory]
    public let description: String
    public let coinTypes: [CoinType]
    public let links: [LinkType: String]
}

public enum LinkType: String {
    case guide
    case website
    case whitepaper
    case twitter
    case telegram
    case reddit
    case github
}
