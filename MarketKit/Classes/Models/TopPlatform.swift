import Foundation

public struct TopPlatform {
    public let uid: String
    public let name: String
    public let rank: Int?
    public let protocolsCount: Int?
    public let marketCap: Decimal?

    public let oneDayRank: Int?
    public let sevenDaysRank: Int?
    public let thirtyDaysRank: Int?

    public let oneDayChange: Decimal?
    public let sevenDayChange: Decimal?
    public let thirtyDayChange: Decimal?

}
