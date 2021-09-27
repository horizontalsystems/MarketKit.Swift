import GRDB

public struct MarketInfo {
    public let coin: Coin
    public let price: Decimal
    public let priceChange: Double?
    public let marketCap: Int
    public let totalVolume: Int

    init(marketInfoResponse: MarketInfoResponse) {
        coin = Coin(coinResponse: marketInfoResponse)
        price = marketInfoResponse.price
        priceChange = marketInfoResponse.priceChange
        marketCap = marketInfoResponse.marketCap
        totalVolume = marketInfoResponse.totalVolume
    }

}
