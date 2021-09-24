import GRDB

public struct FullCoin: FetchableRecord, Decodable {
    public let coin: Coin
    public let platforms: [Platform]

    public init(coin: Coin, platforms: [Platform]) {
        self.coin = coin
        self.platforms = platforms
    }

    init(fullCoinResponse: FullCoinResponse) {
        coin = Coin(fullCoinResponse: fullCoinResponse)
        platforms = fullCoinResponse.platforms.flatMap { Platform(platformResponse: $0, coinUid: fullCoinResponse.uid) }
    }

}
