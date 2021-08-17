import GRDB

public struct MarketCoin: FetchableRecord, Decodable {
    public let coin: Coin
    public let platforms: [Platform]

    init(coinResponse: CoinResponse) {
        coin = Coin(coinResponse: coinResponse)
        platforms = coinResponse.platforms.map { Platform(platformResponse: $0, coinUid: coinResponse.uid) }
    }

}
