import RxSwift

class HsDataSyncer {
    private let coinSyncer: CoinSyncer
    private let coinCategorySyncer: CoinCategorySyncer
    private let hsProvider: HsProvider
    private let disposeBag = DisposeBag()

    init(coinSyncer: CoinSyncer, coinCategorySyncer: CoinCategorySyncer, hsProvider: HsProvider) {
        self.coinSyncer = coinSyncer
        self.coinCategorySyncer = coinCategorySyncer
        self.hsProvider = hsProvider
    }

}

extension HsDataSyncer {

    func sync() {
        hsProvider.statusSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] status in
                    self?.coinSyncer.sync(coinsTimestamp: status.coins, platformsTimestamp: status.platforms)
                    self?.coinCategorySyncer.sync(timestamp: status.categories)
                }, onError: { error in
                    print("Hs Status sync error: \(error)")
                })
                .disposed(by: disposeBag)
    }

}
