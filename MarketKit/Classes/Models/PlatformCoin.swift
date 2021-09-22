import GRDB

public struct PlatformCoin: FetchableRecord, Decodable {
    public let platform: Platform
    public let coin: Coin

    public init(coin: Coin, platform: Platform) {
        self.coin = coin
        self.platform = platform
    }

    public var marketCoin: MarketCoin {
        MarketCoin(coin: coin, platforms: [platform])
    }

    public var name: String {
        coin.name
    }

    public var code: String {
        coin.code
    }

    public var coinType: CoinType {
        platform.coinType
    }

    public var decimals: Int {
        platform.decimals
    }

}

extension PlatformCoin: Equatable {

    public static func ==(lhs: PlatformCoin, rhs: PlatformCoin) -> Bool {
        lhs.platform == rhs.platform && lhs.coin == rhs.coin
    }

}

extension PlatformCoin: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(platform)
        hasher.combine(coin)
    }

}
