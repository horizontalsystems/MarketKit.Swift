import Foundation

class CoinManager {
    private let storage: CoinStorage
    private let hsProvider: HsProvider
    private let coinGeckoProvider: CoinGeckoProvider
    private let exchangeManager: ExchangeManager

    init(storage: CoinStorage, hsProvider: HsProvider, coinGeckoProvider: CoinGeckoProvider, exchangeManager: ExchangeManager) {
        self.storage = storage
        self.hsProvider = hsProvider
        self.coinGeckoProvider = coinGeckoProvider
        self.exchangeManager = exchangeManager
    }

    private func marketInfos(rawMarketInfos: [MarketInfoRaw]) -> [MarketInfo] {
        do {
            let fullCoins = try fullCoins(coinUids: rawMarketInfos.map { $0.uid })
            let dictionary = fullCoins.reduce(into: [String: FullCoin]()) { $0[$1.coin.uid] = $1 }

            return rawMarketInfos.compactMap { rawMarketInfo in
                guard let fullCoin = dictionary[rawMarketInfo.uid] else {
                    return nil
                }

                return rawMarketInfo.marketInfo(fullCoin: fullCoin)
            }
        } catch {
            return []
        }
    }

    private func defiCoins(rawDefiCoins: [DefiCoinRaw]) -> [DefiCoin] {
        do {
            let fullCoins = try fullCoins(coinUids: rawDefiCoins.compactMap { $0.uid })
            let dictionary = fullCoins.reduce(into: [String: FullCoin]()) { $0[$1.coin.uid] = $1 }

            return rawDefiCoins.map { rawDefiCoin in
                rawDefiCoin.defiCoin(fullCoin: rawDefiCoin.uid.flatMap { dictionary[$0] })
            }
        } catch {
            return []
        }
    }

}

extension CoinManager {

    // Coins

    func coinsCount() throws -> Int {
        try storage.coinsCount()
    }

    func coin(uid: String) throws -> Coin? {
        try storage.coin(uid: uid)
    }

    func fullCoins(filter: String, limit: Int) throws -> [FullCoin] {
        try storage.coinTokenRecords(filter: filter, limit: limit)
                .map { $0.fullCoin }
    }

    func fullCoin(uid: String) throws -> FullCoin? {
        try storage.coinTokenRecord(uid: uid)?.fullCoin
    }

    func fullCoins(coinUids: [String]) throws -> [FullCoin] {
        try storage.coinTokenRecords(coinUids: coinUids)
                .map { $0.fullCoin }
    }

    func allCoins() throws -> [Coin] {
        try storage.allCoins()
    }

    func token(query: TokenQuery) throws -> Token? {
        try storage.tokenInfoRecord(query: query)
                .map { $0.token }
    }

    func tokens(queries: [TokenQuery]) throws -> [Token] {
        try storage.tokenInfoRecords(queries: queries)
                .map { $0.token }
    }

    func tokens(reference: String) throws -> [Token] {
        try storage.tokenInfoRecords(reference: reference)
                .map { $0.token }
    }

    func tokens(blockchainType: BlockchainType, filter: String, limit: Int) throws -> [Token] {
        try storage.tokenInfoRecords(blockchainType: blockchainType, filter: filter, limit: limit)
                .map { $0.token }
    }

    func allBlockchains() throws -> [Blockchain] {
        try storage.allBlockchainRecords()
                .map { $0.blockchain }
    }

    func blockchain(uid: String) throws -> Blockchain? {
        try storage.blockchain(uid: uid)
                .map { $0.blockchain }
    }

    func blockchains(uids: [String]) throws -> [Blockchain] {
        try storage.blockchains(uids: uids)
                .map { $0.blockchain }
    }

    // Market Info

    func marketInfos(top: Int, currencyCode: String, defi: Bool) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.marketInfos(top: top, currencyCode: currencyCode, defi: defi)
        return marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func advancedMarketInfos(top: Int, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.advancedMarketInfos(top: top, currencyCode: currencyCode)
        return marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func marketInfos(coinUids: [String], currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.marketInfos(coinUids: coinUids, currencyCode: currencyCode)
        return marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func marketInfos(categoryUid: String, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.marketInfos(categoryUid: categoryUid, currencyCode: currencyCode)
        return marketInfos(rawMarketInfos: rawMarketInfos)
    }

    func marketInfoOverview(coinUid: String, currencyCode: String, languageCode: String) async throws -> MarketInfoOverview {
        let response = try await hsProvider.marketInfoOverview(coinUid: coinUid, currencyCode: currencyCode, languageCode: languageCode)

        guard let fullCoin = try? fullCoin(uid: coinUid) else {
            throw Kit.KitError.noFullCoin
        }

        return response.marketInfoOverview(fullCoin: fullCoin)
    }

    func marketTicker(coinUid: String) async throws -> [MarketTicker] {
        guard let coin = try? storage.coin(uid: coinUid), let coinGeckoId = coin.coinGeckoId else {
            return []
        }

        let response = try await coinGeckoProvider.marketTickers(coinId: coinGeckoId)

        let coinUids = (response.tickers.map { [$0.coinId, $0.targetCoinId] }).flatMap({ $0 }).compactMap { $0 }
        let coins = (try? storage.coins(uids: coinUids)) ?? []

        return response.marketTickers(imageUrls: exchangeManager.imageUrlsMap(ids: response.exchangeIds), coins: coins)
    }

    func defiCoins(currencyCode: String) async throws -> [DefiCoin] {
        let rawDefiCoins = try await hsProvider.defiCoins(currencyCode: currencyCode)
        return defiCoins(rawDefiCoins: rawDefiCoins)
    }

    //Top Platforms

    func topPlatforms(currencyCode: String) async throws -> [TopPlatform] {
        let responses = try await hsProvider.topPlatforms(currencyCode: currencyCode)
        return responses.map { $0.topPlatform }
    }

    func topPlatformsCoinsList(blockchain: String, currencyCode: String) async throws -> [MarketInfo] {
        let rawMarketInfos = try await hsProvider.topPlatformCoinsList(blockchain: blockchain, currencyCode: currencyCode)
        return marketInfos(rawMarketInfos: rawMarketInfos)
    }

    // Top Movers

    func topMovers(currencyCode: String) async throws -> TopMovers {
        let raw = try await hsProvider.topMoversRaw(currencyCode: currencyCode)
        return TopMovers(
                gainers100: marketInfos(rawMarketInfos: raw.gainers100),
                gainers200: marketInfos(rawMarketInfos: raw.gainers200),
                gainers300: marketInfos(rawMarketInfos: raw.gainers300),
                losers100: marketInfos(rawMarketInfos: raw.losers100),
                losers200: marketInfos(rawMarketInfos: raw.losers200),
                losers300: marketInfos(rawMarketInfos: raw.losers300)
        )
    }

}
