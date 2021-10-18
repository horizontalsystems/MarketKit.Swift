import Foundation

public struct MarketInfoDetails {

    public let volume: Decimal?
    public let volumeRank: Decimal?
    public let volumeChange: Float?
    public let hasHolders: Bool
    public let marketCap: Decimal?
    public let tvl: Decimal?
    public let tvlRank: Int?
    public let totalTreasuries: Decimal?
    public let totalFundsInvested: Decimal?
    public let hasReports: Bool
    public let privacy: SecurityLevel?
    public let decentralizedIssuance: Bool?
    public let confiscationResistant: Bool?
    public let censorshipResistant: Bool?
    public let hasAudits: Bool

}

extension MarketInfoDetails {

    public enum SecurityLevel: String {
        case low
        case medium
        case high
    }

}
