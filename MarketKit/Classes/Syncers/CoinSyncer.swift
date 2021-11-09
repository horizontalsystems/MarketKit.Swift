import RxSwift

class CoinSyncer {
    private let coinManager: CoinManager
    private let hsProvider: HsProvider
    private let disposeBag = DisposeBag()

    init(coinManager: CoinManager, hsProvider: HsProvider) {
        self.coinManager = coinManager
        self.hsProvider = hsProvider
    }

    private func handleFetch(error: Error) {
        print("MarketCoins fetch error: \(error)")
    }

}

extension CoinSyncer {

    func initialSync() {
        do {
            guard try coinManager.coinsCount() == 0 else {
                return
            }

            guard let path = Kit.bundle?.path(forResource: "full_coins", ofType: "json") else {
                return
            }

            let jsonString = try String(contentsOfFile: path, encoding: .utf8)
            guard let responses = try [FullCoinResponse](JSONString: jsonString) else {
                return
            }

            coinManager.handleFetched(fullCoins: responses.map { $0.fullCoin() })
        } catch {
            print("CoinSyncer: initial sync error: \(error)")
        }
    }

    func sync() {
        hsProvider.fullCoinsSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] fullCoins in
                    self?.coinManager.handleFetched(fullCoins: fullCoins)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
