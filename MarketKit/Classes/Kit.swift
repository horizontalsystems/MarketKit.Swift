public class Kit {
    private let coinManager: CoinManager
    private let coinSyncer: CoinSyncer

    init(coinManager: CoinManager, coinSyncer: CoinSyncer) {
        self.coinManager = coinManager
        self.coinSyncer = coinSyncer
    }

}

extension Kit {

    public func marketCoins(filter: String, limit: Int = 20) throws -> [MarketCoin] {
        try coinManager.marketCoins(filter: filter, limit: limit)
    }

    public func platformWithCoin(reference: String) throws -> PlatformWithCoin? {
        try coinManager.platformWithCoin(reference: reference)
    }

    public func save(coin: Coin, platform: Platform) throws {
        try coinManager.save(coin: coin, platform: platform)
    }

    public func sync() {
        coinSyncer.sync()
    }

}
