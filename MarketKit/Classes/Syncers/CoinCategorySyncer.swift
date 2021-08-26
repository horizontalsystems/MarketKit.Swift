import RxSwift

class CoinCategorySyncer {
    private let hsProvider: HsProvider
    private let coinCategoryManager: CoinCategoryManager
    private let disposeBag = DisposeBag()

    init(hsProvider: HsProvider, coinCategoryManager: CoinCategoryManager) {
        self.hsProvider = hsProvider
        self.coinCategoryManager = coinCategoryManager
    }

    private func handleFetch(error: Error) {
        print("CoinCategories fetch error: \(error)")
    }

}

extension CoinCategorySyncer {

    func sync() {
        hsProvider.coinCategoriesSingle()
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .subscribe(onSuccess: { [weak self] coinCategories in
                    self?.coinCategoryManager.handleFetched(coinCategories: coinCategories)
                }, onError: { [weak self] error in
                    self?.handleFetch(error: error)
                })
                .disposed(by: disposeBag)
    }

}
