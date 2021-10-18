import Foundation

public struct MarketInfo {
    public let fullCoin: FullCoin
    public let price: Decimal?
    public let priceChange24h: Decimal?
    public let priceChange7d: Decimal?
    public let priceChange14d: Decimal?
    public let priceChange30d: Decimal?
    public let priceChange200d: Decimal?
    public let priceChange1y: Decimal?
    public let marketCap: Decimal?
    public let totalVolume: Decimal?
    public let ath: Decimal?
    public let atl: Decimal?
}
