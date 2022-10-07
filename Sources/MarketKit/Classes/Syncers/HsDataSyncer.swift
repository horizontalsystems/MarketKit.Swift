import RxSwift

class HsDataSyncer {
    private let coinSyncer: CoinSyncer
    private let hsProvider: HsProvider
    private let disposeBag = DisposeBag()

    init(coinSyncer: CoinSyncer, hsProvider: HsProvider) {
        self.coinSyncer = coinSyncer
        self.hsProvider = hsProvider
    }

}

extension HsDataSyncer {

    func sync() {
        hsProvider.statusSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] status in
                    self?.coinSyncer.sync(coinsTimestamp: status.coins, blockchainsTimestamp: status.blockchains, tokensTimestamp: status.tokens)
                }, onError: { error in
                    print("Hs Status sync error: \(error)")
                })
                .disposed(by: disposeBag)
    }

}
