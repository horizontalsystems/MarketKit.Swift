import Foundation

public struct DefiCoin {
    public let type: DefiCoinType
    public let tvl: Decimal
    public let tvlRank: Int
    public let tvlChange1d: Decimal?
    public let tvlChange1w: Decimal?
    public let tvlChange2w: Decimal?
    public let tvlChange1m: Decimal?
    public let tvlChange3m: Decimal?
    public let tvlChange6m: Decimal?
    public let tvlChange1y: Decimal?
    public let chains: [String]
    public let chainTvls: [String: Decimal]

    public enum DefiCoinType {
        case fullCoin(fullCoin: FullCoin)
        case defiCoin(name: String, logo: String)
    }
}
