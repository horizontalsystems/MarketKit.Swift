public class Kit {
    private let coinManager: CoinManager
    private let coinCategoryManager: CoinCategoryManager
    private let coinSyncer: CoinSyncer
    private let coinCategorySyncer: CoinCategorySyncer

    init(coinManager: CoinManager, coinCategoryManager: CoinCategoryManager, coinSyncer: CoinSyncer, coinCategorySyncer: CoinCategorySyncer) {
        self.coinManager = coinManager
        self.coinCategoryManager = coinCategoryManager
        self.coinSyncer = coinSyncer
        self.coinCategorySyncer = coinCategorySyncer
    }

}

extension Kit {

    // Coins

    public func marketCoins(filter: String, limit: Int = 20) throws -> [MarketCoin] {
        try coinManager.marketCoins(filter: filter, limit: limit)
    }

    public func platformWithCoin(reference: String) throws -> PlatformWithCoin? {
        try coinManager.platformWithCoin(reference: reference)
    }

    public func save(coin: Coin, platform: Platform) throws {
        try coinManager.save(coin: coin, platform: platform)
    }

    // Categories

    public func coinCategories() throws -> [CoinCategory] {
        try coinCategoryManager.coinCategories()
    }

    public func sync() {
        coinSyncer.sync()
        coinCategorySyncer.sync()
    }

}
