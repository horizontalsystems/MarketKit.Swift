import Foundation

public struct MarketInfo {
    public let fullCoin: FullCoin
    public let price: Decimal?
    public let priceChange: Decimal?
    public let marketCap: Decimal?
    public let totalVolume: Decimal?
}

extension MarketInfo {

    public enum OrderField: String {
        case priceChange = "price_change"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
    }

    public enum OrderDirection: String {
        case ascending = "ASC"
        case descending = "DESC"
    }

    public struct Order {
        let field: OrderField
        let direction: OrderDirection

        public init(field: OrderField, direction: OrderDirection) {
            self.field = field
            self.direction = direction
        }
    }

}
