import GRDB

public struct MarketCoin {
    public let coin: Coin
    public let price: Decimal
    public let priceChange: Double?
    public let marketCap: Int
    public let totalVolume: Int

    init(marketCoinResponse: MarketCoinResponse) {
        coin = Coin(coinResponse: marketCoinResponse)
        price = marketCoinResponse.price
        priceChange = marketCoinResponse.priceChange
        marketCap = marketCoinResponse.marketCap
        totalVolume = marketCoinResponse.totalVolume
    }

}
