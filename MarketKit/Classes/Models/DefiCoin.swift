import Foundation

public struct DefiCoin {
    public let type: DefiCoinType
    public let tvl: Decimal
    public let tvlRank: Int
    public let tvlChange1d: Decimal?
    public let tvlChange7d: Decimal?
    public let tvlChange30d: Decimal?
    public let chains: [String]

    public enum DefiCoinType {
        case fullCoin(fullCoin: FullCoin)
        case defiCoin(name: String, logo: String)
    }

}
