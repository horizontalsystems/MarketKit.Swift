import ObjectMapper
import Foundation

class MarketInfoDetailsResponse: ImmutableMappable {

    // Token Liquidity
    let volume: Decimal?
    let volumeRank: Decimal?
    let volumeChange: Float?
    let hasHolders: Bool

    // TVL
    let marketCap: Decimal?
    let tvl: Decimal?
    let tvlRank: Int?

    // Investor Data
    let totalTreasuries: Decimal?
    let totalFundsInvested: Decimal?
    let hasReports: Bool

    // Security Parameters
    let privacy: String?
    let decentralizedIssuance: Bool?
    let confiscationResistant: Bool?
    let censorshipResistant: Bool?
    let hasAudits: Bool

    required init(map: Map) throws {
        volume = try? map.value("volume", using: Transform.stringToDecimalTransform)
        volumeRank = try? map.value("volumeRank")
        volumeChange = try? map.value("volumeChange")
        hasHolders = try map.value("hasHolders")
        marketCap = try? map.value("marketCap", using: Transform.stringToDecimalTransform)
        tvl = try? map.value("tvl", using: Transform.stringToDecimalTransform)
        tvlRank = try? map.value("tvlRank")
        totalTreasuries = try? map.value("totalTreasuries", using: Transform.stringToDecimalTransform)
        totalFundsInvested = try? map.value("totalFundsInvested", using: Transform.stringToDecimalTransform)
        hasReports = try map.value("hasReports")
        privacy = try? map.value("privacy")
        decentralizedIssuance = try? map.value("decentralizedIssuance")
        confiscationResistant = try? map.value("confiscationResistant")
        censorshipResistant = try? map.value("censorshipResistant")
        hasAudits = try map.value("hasAudits")
    }

    func marketInfoDetails() -> MarketInfoDetails {
        MarketInfoDetails(
                volume: volume,
                volumeRank: volumeRank,
                volumeChange: volumeChange,
                hasHolders: hasHolders,
                marketCap: marketCap,
                tvl: tvl,
                tvlRank: tvlRank,
                totalTreasuries: totalTreasuries,
                totalFundsInvested: totalFundsInvested,
                hasReports: hasReports,
                privacy: privacy.flatMap { MarketInfoDetails.SecurityLevel(rawValue: $0) },
                decentralizedIssuance: decentralizedIssuance,
                confiscationResistant: confiscationResistant,
                censorshipResistant: censorshipResistant,
                hasAudits: hasAudits
        )
    }

}
