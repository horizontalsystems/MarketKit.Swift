import Foundation

class CoinManager {
    private let storage: CoinStorage
    private let hsProvider: HsProvider

    init(storage: CoinStorage, hsProvider: HsProvider) {
        self.storage = storage
        self.hsProvider = hsProvider
    }
}

extension CoinManager {
    func coinsCount() throws -> Int {
        try storage.coinsCount()
    }

    func coin(uid: String) throws -> Coin? {
        try storage.coin(uid: uid)
    }

    func coins(uids: [String]) throws -> [Coin] {
        try storage.coins(uids: uids)
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

    func marketInfos(rawMarketInfos: [MarketInfoRaw]) -> [MarketInfo] {
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

    func defiCoins(rawDefiCoins: [DefiCoinRaw]) -> [DefiCoin] {
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
