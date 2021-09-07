import RxSwift

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

    public var marketCoinsUpdatedObservable: Observable<Void> {
        coinManager.marketCoinsUpdatedObservable
    }

    public func marketCoins(filter: String, limit: Int = 20) throws -> [MarketCoin] {
        try coinManager.marketCoins(filter: filter, limit: limit)
    }

    public func marketCoins(coinUids: [String]) throws -> [MarketCoin] {
        try coinManager.marketCoins(coinUids: coinUids)
    }

    public func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try coinManager.platformCoin(coinType: coinType)
    }

    public func platformCoins() throws -> [PlatformCoin] {
        try coinManager.platformCoins()
    }

    public func save(coin: Coin, platform: Platform) throws {
        try coinManager.save(coin: coin, platform: platform)
    }

    // Categories

    public var coinCategoriesObservable: Observable<[CoinCategory]> {
        coinCategoryManager.coinCategoriesObservable
    }

    public func coinCategories() throws -> [CoinCategory] {
        try coinCategoryManager.coinCategories()
    }

    public func sync() {
        coinSyncer.sync()
        coinCategorySyncer.sync()
    }

}
