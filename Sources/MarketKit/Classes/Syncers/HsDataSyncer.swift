import HsExtensions

class HsDataSyncer {
    private let coinSyncer: CoinSyncer
    private let hsProvider: HsProvider
    private var tasks = Set<AnyTask>()

    init(coinSyncer: CoinSyncer, hsProvider: HsProvider) {
        self.coinSyncer = coinSyncer
        self.hsProvider = hsProvider
    }
}

extension HsDataSyncer {
    func sync() {
        Task { [hsProvider, coinSyncer] in
            do {
                let status = try await hsProvider.status()
                coinSyncer.sync(coinsTimestamp: status.coins, blockchainsTimestamp: status.blockchains, tokensTimestamp: status.tokens)
            } catch {
                print("Hs Status sync error: \(error)")
            }
        }.store(in: &tasks)
    }
}
