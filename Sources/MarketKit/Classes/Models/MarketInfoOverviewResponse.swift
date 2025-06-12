import Foundation
import ObjectMapper

class MarketInfoOverviewResponse: ImmutableMappable {
    let marketCap: Decimal?
    let marketCapRank: Int?
    let totalSupply: Decimal?
    let circulatingSupply: Decimal?
    let volume24h: Decimal?
    let dilutedMarketCap: Decimal?
    let performance: [String: [String: String?]]
    let genesisDate: Date?
    let categories: [CoinCategory]
    let description: String
    let links: [String: String?]

    required init(map: Map) throws {
        marketCap = try? map.value("market_data.market_cap", using: Transform.stringToDecimalTransform)
        marketCapRank = try? map.value("market_data.market_cap_rank")
        totalSupply = try? map.value("market_data.total_supply", using: Transform.stringToDecimalTransform)
        circulatingSupply = try? map.value("market_data.circulating_supply", using: Transform.stringToDecimalTransform)
        volume24h = try? map.value("market_data.total_volume", using: Transform.stringToDecimalTransform)
        dilutedMarketCap = try? map.value("market_data.fully_diluted_valuation", using: Transform.stringToDecimalTransform)
        performance = try map.value("performance")
        genesisDate = try? map.value("genesis_date", using: Transform.stringToDateTransform)
        categories = try map.value("categories")
        description = (try? map.value("description")) ?? ""
        links = (try? map.value("links")) ?? [:]
    }

    func marketInfoOverview(fullCoin: FullCoin) -> MarketInfoOverview {
        var convertedLinks = [LinkType: String]()

        for (type, link) in links {
            if let linkType = LinkType(rawValue: type), let link {
                convertedLinks[linkType] = link
            }
        }

        let convertedPerformance: [PerformanceRow] = performance.compactMap { baseUid, changes -> PerformanceRow? in
            var performanceChanges = [HsTimePeriod: Decimal]()
            for (timePeriodStr, change) in changes {
                if let changeStr = change,
                   let changeDecimal = Decimal(string: changeStr),
                   let timePeriod = Self.timePeriod(timePeriodStr)
                {
                    performanceChanges[timePeriod] = changeDecimal
                }
            }

            guard !performanceChanges.isEmpty else {
                return nil
            }

            return PerformanceRow(baseUid: baseUid, changes: performanceChanges)
        }

        return MarketInfoOverview(
            fullCoin: fullCoin,
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            totalSupply: totalSupply,
            circulatingSupply: circulatingSupply,
            volume24h: volume24h,
            dilutedMarketCap: dilutedMarketCap,
            performance: convertedPerformance,
            genesisDate: genesisDate,
            categories: categories,
            description: description,
            links: convertedLinks
        )
    }

    static func timePeriod(_ timePeriod: String) -> HsTimePeriod? {
        switch timePeriod {
        case "24h": return .day1
        case "7d": return .week1
        case "14d": return .week2
        case "30d": return .month1
        case "90d": return .month3
        case "200d": return .month6
        case "1y": return .year1
        case "2y": return .year2
        case "3y": return .year3
        case "4y": return .year4
        case "5y": return .year5
        default: return nil
        }
    }

    static func hsTimePeriodStr(_ timePeriod: HsTimePeriod) -> String {
        switch timePeriod {
        case .day1: return "24h"
        case .week1: return "7d"
        case .week2: return "14d"
        case .month1: return "30d"
        case .month3: return "90d"
        case .month6: return "200d"
        case .year1: return "1y"
        case .year2: return "2y"
        case .year3: return "3y"
        case .year4: return "4y"
        case .year5: return "5y"
        default: return "24h"
        }
    }
}
