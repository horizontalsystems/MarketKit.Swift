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
