import RxSwift

class CoinSyncer {
    private let coinManager: CoinManager
    private let disposeBag = DisposeBag()

    init(coinManager: CoinManager) {
        self.coinManager = coinManager
    }

    private func handleFetch(error: Error) {
        print("MarketCoins fetch error: \(error)")
    }

}

extension CoinSyncer {

    func sync() {
        coinManager.fullCoinsSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] fullCoins in
                    self?.coinManager.handleFetched(fullCoins: fullCoins)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
