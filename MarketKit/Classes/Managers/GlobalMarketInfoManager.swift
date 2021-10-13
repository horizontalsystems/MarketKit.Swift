import RxSwift

class GlobalMarketInfoManager {
    private let expirationInterval: TimeInterval = 600 // 6 mins

    private let provider: HsOldProvider
    private let storage: GlobalMarketInfoStorage

    init(provider: HsOldProvider, storage: GlobalMarketInfoStorage) {
        self.provider = provider
        self.storage = storage
    }

}

extension GlobalMarketInfoManager {

    func globalMarketInfoSingle(currencyCode: String, timePeriod: TimePeriod) -> Single<GlobalMarketInfo> {
        let currentTimestamp = Date().timeIntervalSince1970

        if let storedInfo = try? storage.globalMarketInfo(currencyCode: currencyCode, timePeriod: timePeriod), currentTimestamp - storedInfo.timestamp < expirationInterval {
            return Single.just(storedInfo)
        }

        return provider.globalMarketPointsSingle(currencyCode: currencyCode, timePeriod: timePeriod)
                .map { points in
                    GlobalMarketInfo(currencyCode: currencyCode, timePeriod: timePeriod, points: points)
                }
                .do(onNext: { [weak self] info in
                    try? self?.storage.save(globalMarketInfo: info)
                })
    }

}
