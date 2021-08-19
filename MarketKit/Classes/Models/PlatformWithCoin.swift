import GRDB

public struct PlatformWithCoin: FetchableRecord, Decodable {
    public let platform: Platform
    public let coin: Coin
}
