import Foundation

public struct MarketInfoDetails {
    public let tvl: Decimal?
    public let tvlRank: Int?
    public let tvlRatio: Decimal?
    public let totalTreasuries: Decimal?
    public let totalFundsInvested: Decimal?
    public let privacy: SecurityLevel?
    public let decentralizedIssuance: Bool?
    public let confiscationResistant: Bool?
    public let censorshipResistant: Bool?

}

extension MarketInfoDetails {

    public enum SecurityLevel: String {
        case low
        case medium
        case high
    }

}
