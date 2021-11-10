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
    let categoryUids: [String]
    let description: String
    let platforms: [PlatformResponse]
    let links: [String: String?]

    required init(map: Map) throws {
        marketCap = try? map.value("market_data.market_cap", using: Transform.stringToDecimalTransform)
        marketCapRank = try? map.value("market_data.market_cap_rank")
        totalSupply = try? map.value("market_data.total_supply", using: Transform.stringToDecimalTransform)
        circulatingSupply = try? map.value("market_data.circulating_supply", using: Transform.stringToDecimalTransform)
        volume24h = try? map.value("market_data.total_volume", using: Transform.stringToDecimalTransform)
        dilutedMarketCap = try? map.value("market_data.fully_diluted_valuation", using: Transform.stringToDecimalTransform)
        tvl = try? map.value("market_data.total_value_locked", using: Transform.stringToDecimalTransform)
        performance = try map.value("performance")
        genesisDate = try? map.value("genesis_date", using: Transform.stringToDateTransform)
        categoryUids = try map.value("category_uids")
        description = (try? map.value("description")) ?? ""
        platforms = try map.value("platforms")
        links = try map.value("links")
    }

    func marketInfoOverview(categories: [CoinCategory]) -> MarketInfoOverview {
        var convertedLinks = [LinkType: String]()

        for (type, link) in links {
            if let linkType = LinkType(rawValue: type), let link = link {
                convertedLinks[linkType] = link
            }
        }

        let convertedPerformance: [PerformanceRow] = performance.compactMap { (base, changes) -> PerformanceRow? in
            guard let performanceBase = PerformanceBase(rawValue: base) else {
                return nil
            }

            var performanceChanges = [TimePeriod: Decimal]()
            for (timePeriodStr, change) in changes {
                if let changeStr = change,
                   let changeDecimal = Decimal(string: changeStr),
                   let timePeriod = TimePeriod(rawValue: timePeriodStr) {
                    performanceChanges[timePeriod] = changeDecimal
                }
            }

            guard !performanceChanges.isEmpty else {
                return nil
            }

            return PerformanceRow(base: performanceBase, changes: performanceChanges)
        }.sorted { $0.base < $1.base }

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
                coinTypes: platforms.compactMap { $0.coinType },
                links: convertedLinks
        )
    }

}
