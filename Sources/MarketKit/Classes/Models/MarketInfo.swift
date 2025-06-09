import Foundation

public struct MarketInfo {
    public let fullCoin: FullCoin
    public let price: Decimal?
    public let priceChange24h: Decimal?
    public let priceChange1d: Decimal?
    public let priceChange7d: Decimal?
    public let priceChange14d: Decimal?
    public let priceChange30d: Decimal?
    public let priceChange90d: Decimal?
    public let priceChange200d: Decimal?
    public let priceChange1y: Decimal?
    public let priceChange2y: Decimal?
    public let priceChange3y: Decimal?
    public let priceChange4y: Decimal?
    public let priceChange5y: Decimal?
    public let marketCap: Decimal?
    public let marketCapRank: Int?
    public let totalVolume: Decimal?
    public let athPercentage: Decimal?
    public let atlPercentage: Decimal?
    public let listedOnTopExchanges: Bool?
    public let solidCex: Bool?
    public let solidDex: Bool?
    public let goodDistribution: Bool?
    public let indicatorsResult: TechnicalAdvice.Advice?
    public let categoryIds: [Int]
}
