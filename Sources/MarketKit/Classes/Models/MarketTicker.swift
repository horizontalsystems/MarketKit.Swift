import Foundation

public struct MarketTicker {
    public let base: String
    public let target: String
    public let marketName: String
    public let marketImageUrl: String?
    public let rate: Decimal
    public let volume: Decimal
    public let tradeUrl: String?
}
