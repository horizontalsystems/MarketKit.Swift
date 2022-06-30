import Foundation
import RxSwift

class CoinHistoricalPriceManager {
    private let storage: CoinHistoricalPriceStorage
    private let hsProvider: HsProvider

    init(storage: CoinHistoricalPriceStorage, hsProvider: HsProvider) {
        self.storage = storage
        self.hsProvider = hsProvider
    }

}

extension CoinHistoricalPriceManager {

    func coinHistoricalPriceValue(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Decimal? {
        try? storage.coinHistoricalPrice(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)?.value
    }

    func coinHistoricalPriceValueSingle(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Single<Decimal> {
        hsProvider.historicalCoinPriceSingle(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)
                .flatMap { [weak self] response in
                    if abs(Int(timestamp) - response.timestamp) < 24 * 60 * 60 { // 1 day
                        try? self?.storage.save(coinHistoricalPrice: CoinHistoricalPrice(coinUid: coinUid, currencyCode: currencyCode, value: response.price, timestamp: timestamp))

                        return Single.just(response.price)
                    } else {
                        return Single.error(ResponseError.returnedTimestampIsTooInaccurate)
                    }
                }
    }

}

extension CoinHistoricalPriceManager {

    enum ResponseError: Error {
        case returnedTimestampIsTooInaccurate
    }

}
