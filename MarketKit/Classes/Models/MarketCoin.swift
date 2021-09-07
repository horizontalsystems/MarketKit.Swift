import GRDB

public struct MarketCoin: FetchableRecord, Decodable {
    public let coin: Coin
    public let platforms: [Platform]

    public init(coin: Coin, platforms: [Platform]) {
        self.coin = coin
        self.platforms = platforms
    }

    init(coinResponse: CoinResponse) {
        coin = Coin(coinResponse: coinResponse)
        platforms = coinResponse.platforms.flatMap { Platform(platformResponse: $0, coinUid: coinResponse.uid) }
    }

}
