import Foundation

public struct TopPlatform {
    public let blockchain: Blockchain
    public let rank: Int?
    public let protocolsCount: Int?
    public let marketCap: Decimal?

    public let ranks: [HsTimePeriod: Int]
    public let changes: [HsTimePeriod: Decimal]
}
