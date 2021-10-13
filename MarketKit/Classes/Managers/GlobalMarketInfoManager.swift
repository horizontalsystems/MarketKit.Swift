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

    func globalMarketPointsSingle(currencyCode: String, timePeriod: TimePeriod) -> Single<[GlobalMarketPoint]> {
        let currentTimestamp = Date().timeIntervalSince1970

        if let storedInfo = try? storage.globalMarketInfo(currencyCode: currencyCode, timePeriod: timePeriod), currentTimestamp - storedInfo.timestamp < expirationInterval {
            return Single.just(storedInfo.points)
        }

        return provider.globalMarketPointsSingle(currencyCode: currencyCode, timePeriod: timePeriod)
                .do(onNext: { [weak self] points in
                    let info = GlobalMarketInfo(currencyCode: currencyCode, timePeriod: timePeriod, points: points)
                    try? self?.storage.save(globalMarketInfo: info)
                })
    }

}
