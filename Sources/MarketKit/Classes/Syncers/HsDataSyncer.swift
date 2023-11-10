import HsExtensions

class HsDataSyncer {
    private let coinSyncer: CoinSyncer
    private let verifiedExchangeSyncer: VerifiedExchangeSyncer
    private let hsProvider: HsProvider
    private var tasks = Set<AnyTask>()

    init(coinSyncer: CoinSyncer, verifiedExchangeSyncer: VerifiedExchangeSyncer, hsProvider: HsProvider) {
        self.coinSyncer = coinSyncer
        self.verifiedExchangeSyncer = verifiedExchangeSyncer
        self.hsProvider = hsProvider
    }
}

extension HsDataSyncer {
    func sync() {
        Task { [hsProvider, coinSyncer, verifiedExchangeSyncer] in
            do {
                let status = try await hsProvider.status()
                coinSyncer.sync(coinsTimestamp: status.coins, blockchainsTimestamp: status.blockchains, tokensTimestamp: status.tokens)
                verifiedExchangeSyncer.sync(timestamp: status.exchanges)
            } catch {
                print("Hs Status sync error: \(error)")
            }
        }.store(in: &tasks)
    }
}
