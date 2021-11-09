import ObjectMapper
import Foundation

class MarketInfoDetailsResponse: ImmutableMappable {

    // TVL
    let tvl: Decimal?
    let tvlRank: Int?
    let tvlRatio: Decimal?

    // Investor Data
    let totalTreasuries: Decimal?
    let totalFundsInvested: Decimal?
    let reportsCount: Int

    // Security Parameters
    let privacy: String?
    let decentralizedIssuance: Bool?
    let confiscationResistant: Bool?
    let censorshipResistant: Bool?

    required init(map: Map) throws {
        tvl = try? map.value("tvl", using: Transform.stringToDecimalTransform)
        tvlRank = try? map.value("tvl_rank")
        tvlRatio = try? map.value("tvl_ratio", using: Transform.stringToDecimalTransform)

        totalTreasuries = try? map.value("investor_data.treasuries", using: Transform.stringToDecimalTransform)
        totalFundsInvested = try? map.value("investor_data.funds_invested", using: Transform.stringToDecimalTransform)
        reportsCount = try map.value("reports_count")

        privacy = try? map.value("security.privacy")
        decentralizedIssuance = try? map.value("security.decentralized")
        confiscationResistant = try? map.value("security.confiscation_resistance")
        censorshipResistant = try? map.value("security.censorship_resistance")
    }

    func marketInfoDetails() -> MarketInfoDetails {
        MarketInfoDetails(
                tvl: tvl,
                tvlRank: tvlRank,
                tvlRatio: tvlRatio,
                totalTreasuries: totalTreasuries,
                totalFundsInvested: totalFundsInvested,
                reportsCount: reportsCount,
                privacy: privacy.flatMap { MarketInfoDetails.SecurityLevel(rawValue: $0) },
                decentralizedIssuance: decentralizedIssuance,
                confiscationResistant: confiscationResistant,
                censorshipResistant: censorshipResistant
        )
    }

}
