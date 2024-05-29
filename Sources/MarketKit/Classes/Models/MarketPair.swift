import Foundation
import ObjectMapper

public struct MarketPair {
    public let base: String
    public let baseCoinUid: String?
    public let target: String
    public let targetCoinUid: String?
    public let marketName: String
    public let marketImageUrl: String?
    public let rank: Int
    public let volume: Decimal?
    public let price: Decimal?
    public let tradeUrl: String?
    public let baseCoin: Coin?
    public let targetCoin: Coin?

    public var uid: String {
        "\(base) \(target) \(marketName)"
    }
}
