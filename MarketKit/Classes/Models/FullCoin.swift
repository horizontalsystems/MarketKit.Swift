import GRDB

public struct FullCoin: FetchableRecord, Decodable {
    public let coin: Coin
    public let platforms: [Platform]

    public init(coin: Coin, platforms: [Platform]) {
        self.coin = coin
        self.platforms = platforms
    }

}
