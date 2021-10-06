import ObjectMapper
import Foundation

class MarketInfoOverviewRaw: ImmutableMappable {
    let marketCap: Decimal?
    let marketCapRank: Int?
    let totalSupply: Decimal?
    let circulatingSupply: Decimal?
    let volume24h: Decimal?
    let dilutedMarketCap: Decimal?
    let tvl: Decimal?
    let performance: [String: [String: String?]]
    let genesisDate: Date?
    let categoryIds: [String]
    let description: String
    let links: [String: String?]

    required init(map: Map) throws {
        marketCap = try? map.value("market_data.market_cap", using: Transform.stringToDecimalTransform)
        marketCapRank = try? map.value("market_data.market_cap_rank")
        totalSupply = try? map.value("market_data.total_supply", using: Transform.stringToDecimalTransform)
        circulatingSupply = try? map.value("market_data.circulating_supply", using: Transform.stringToDecimalTransform)
        volume24h = try? map.value("market_data.total_volume", using: Transform.stringToDecimalTransform)
        dilutedMarketCap = try? map.value("market_data.fully_diluted_valuation", using: Transform.stringToDecimalTransform)
        tvl = nil
        performance = try map.value("performance")
        genesisDate = try? map.value("genesis_date", using: DateTransform())
        categoryIds = try map.value("category_ids")
        description = (try? map.value("description")) ?? ""
        links = try map.value("links")
    }

    func marketInfoOverview(categories: [CoinCategory]) -> MarketInfoOverview {
        var convertedLinks = [LinkType: String]()
        var convertedPerformance = [String: [TimePeriod: Decimal]]()

        for (type, link) in links {
            if let linkType = LinkType(rawValue: type), let link = link {
                convertedLinks[linkType] = link
            }
        }

        for (currency, changes) in performance {
            convertedPerformance[currency] = [TimePeriod: Decimal]()
            for (timePeriodStr, change) in changes {
                if let timePeriod = TimePeriod(rawValue: timePeriodStr),
                   let changeStr = change,
                   let changeDecimal = Decimal(string: changeStr) {
                    convertedPerformance[currency]?[timePeriod] = changeDecimal
                }
            }
        }

        return MarketInfoOverview(
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            totalSupply: totalSupply,
            circulatingSupply: circulatingSupply,
            volume24h: volume24h,
            dilutedMarketCap: dilutedMarketCap,
            tvl: tvl,
            performance: convertedPerformance,
            genesisDate: genesisDate,
            categories: categories,
            description: description,
            links: convertedLinks
        )
    }

}
