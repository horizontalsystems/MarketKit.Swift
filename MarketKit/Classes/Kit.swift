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

    public func sync() {
        coinSyncer.sync()
    }

}
