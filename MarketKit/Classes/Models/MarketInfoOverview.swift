import Foundation

public struct MarketInfoOverview {
    public let marketCap: Decimal?
    public let marketCapRank: Int?
    public let totalSupply: Decimal?
    public let circulatingSupply: Decimal?
    public let volume24h: Decimal?
    public let dilutedMarketCap: Decimal?
    public let tvl: Decimal?
    public let performance: [String: [TimePeriod: Decimal]]
    public let genesisDate: Date?
    public let categories: [CoinCategory]
    public let description: String
    public let links: [LinkType: String]

    init(response: MarketInfoOverviewResponse, categories: [CoinCategory]) {
        marketCap = response.marketCap
        marketCapRank = response.marketCapRank
        totalSupply = response.totalSupply
        circulatingSupply = response.circulatingSupply
        volume24h = response.volume24h
        dilutedMarketCap = response.dilutedMarketCap
        tvl = response.tvl
        genesisDate = response.genesisDate
        description = response.description
        self.categories = categories

        var links = [LinkType: String]()
        var performance = [String: [TimePeriod: Decimal]]()

        for (type, link) in response.links {
            if let linkType = LinkType(rawValue: type), let link = link {
                links[linkType] = link
            }
        }

        for (currency, changes) in response.performance {
            performance[currency] = [TimePeriod: Decimal]()
            for (timePeriodStr, change) in changes {
                if let timePeriod = TimePeriod(rawValue: timePeriodStr),
                   let changeStr = change,
                   let changeDecimal = Decimal(string: changeStr) {
                    performance[currency]?[timePeriod] = changeDecimal
                }
            }
        }

        self.performance = performance
        self.links = links
    }

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
