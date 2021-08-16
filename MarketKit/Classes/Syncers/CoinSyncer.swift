import RxSwift

class CoinSyncer {
    private let hsProvider: HsProvider
    private let coinManager: CoinManager
    private let disposeBag = DisposeBag()

    init(hsProvider: HsProvider, coinManager: CoinManager) {
        self.hsProvider = hsProvider
        self.coinManager = coinManager
    }

    private func handleFetch(error: Error) {
        print("Fetch error: \(error)")
    }

}

extension CoinSyncer {

    func sync() {
        hsProvider.coinsSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] coins in
                    self?.coinManager.handleFetched(coins: coins)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
