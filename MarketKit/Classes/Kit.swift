public class Kit {
    private let coinManager: CoinManager
    private let coinSyncer: CoinSyncer

    init(coinManager: CoinManager, coinSyncer: CoinSyncer) {
        self.coinManager = coinManager
        self.coinSyncer = coinSyncer
    }

}

extension Kit {

    public func coins(filter: String) throws -> [Coin] {
        try coinManager.coins(filter: filter)
    }

    public func sync() {
        coinSyncer.sync()
    }

}
