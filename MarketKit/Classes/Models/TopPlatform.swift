import Foundation

public struct TopPlatform {
    public let fullCoin: FullCoin
    public let marketCap: Decimal?
    public let rank: Int?

    public let oneDayRank: Int?
    public let sevenDaysRank: Int?
    public let thirtyDaysRank: Int?

    public let oneDayChange: Decimal?
    public let sevenDayChange: Decimal?
    public let thirtyDayChange: Decimal?

    public let protocolsCount: Int?
}
