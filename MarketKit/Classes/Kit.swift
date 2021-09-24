import RxSwift

public class Kit {
    private let coinManager: CoinManager
    private let coinCategoryManager: CoinCategoryManager
    private let coinSyncer: CoinSyncer
    private let coinCategorySyncer: CoinCategorySyncer
    private let coinPriceManager: CoinPriceManager
    private let coinPriceSyncManager: CoinPriceSyncManager

    init(coinManager: CoinManager, coinCategoryManager: CoinCategoryManager, coinSyncer: CoinSyncer, coinCategorySyncer: CoinCategorySyncer, coinPriceManager: CoinPriceManager, coinPriceSyncManager: CoinPriceSyncManager) {
        self.coinManager = coinManager
        self.coinCategoryManager = coinCategoryManager
        self.coinSyncer = coinSyncer
        self.coinCategorySyncer = coinCategorySyncer
        self.coinPriceManager = coinPriceManager
        self.coinPriceSyncManager = coinPriceSyncManager
    }

}

extension Kit {

    // Coins

    public var fullCoinsUpdatedObservable: Observable<Void> {
        coinManager.fullCoinsUpdatedObservable
    }

    public func fullCoins(filter: String, limit: Int = 20) throws -> [FullCoin] {
        try coinManager.fullCoins(filter: filter, limit: limit)
    }

    public func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try coinManager.fullCoins(coinUids: coinUids)
    }

    public func fullCoins(coinTypes: [CoinType]) throws -> [FullCoin] {
        try coinManager.fullCoins(coinTypes: coinTypes)
    }

    public func platformCoin(coinType: CoinType) throws -> PlatformCoin? {
        try coinManager.platformCoin(coinType: coinType)
    }

    public func platformCoins() throws -> [PlatformCoin] {
        try coinManager.platformCoins()
    }

    public func platformCoins(coinTypes: [CoinType]) throws -> [PlatformCoin] {
        try coinManager.platformCoins(coinTypes: coinTypes)
    }

    public func platformCoins(coinTypeIds: [String]) throws -> [PlatformCoin] {
        try coinManager.platformCoins(coinTypeIds: coinTypeIds)
    }

    public func coins(filter: String, limit: Int = 20) throws -> [Coin] {
        try coinManager.coins(filter: filter, limit: limit)
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

    // Coin Prices

    public func refreshCoinPrices(currencyCode: String) {
        coinPriceSyncManager.refresh(currencyCode: currencyCode)
    }

    public func coinPrice(coinUid: String, currencyCode: String) -> CoinPrice? {
        coinPriceManager.coinPrice(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func coinPriceMap(coinUids: [String], currencyCode: String) -> [String: CoinPrice] {
        coinPriceManager.coinPriceMap(coinUids: coinUids, currencyCode: currencyCode)
    }

    public func coinPriceObservable(coinUid: String, currencyCode: String) -> Observable<CoinPrice> {
        coinPriceSyncManager.coinPriceObservable(coinUid: coinUid, currencyCode: currencyCode)
    }

    public func coinPriceMapObservable(coinUids: [String], currencyCode: String) -> Observable<[String: CoinPrice]> {
        coinPriceSyncManager.coinPriceMapObservable(coinUids: coinUids, currencyCode: currencyCode)
    }

}
