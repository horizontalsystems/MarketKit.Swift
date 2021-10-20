import Foundation
import RxSwift

class CoinHistoricalPriceManager {
    private let storage: CoinHistoricalPriceStorage
    private let coinManager: CoinManager
    private let coinGeckoProvider: CoinGeckoProvider

    init(storage: CoinHistoricalPriceStorage, coinManager: CoinManager, coinGeckoProvider: CoinGeckoProvider) {
        self.storage = storage
        self.coinManager = coinManager
        self.coinGeckoProvider = coinGeckoProvider
    }

}

extension CoinHistoricalPriceManager {

    func coinHistoricalPriceValueSingle(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Single<Decimal> {
        if let storedPrice = try? storage.coinHistoricalPrice(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp) {
            return Single.just(storedPrice.value)
        }

        guard let coinGeckoId = try? coinManager.coin(uid: coinUid)?.coinGeckoId else {
            return Single.error(CoinError.coinNotFound)
        }

        return coinGeckoProvider.historicalPriceValueSingle(id: coinGeckoId, currencyCode: currencyCode, timestamp: timestamp)
                .do(onSuccess: { [weak self] value in
                    let coinHistoricalPrice = CoinHistoricalPrice(coinUid: coinUid, currencyCode: currencyCode, value: value, timestamp: timestamp)
                    try? self?.storage.save(coinHistoricalPrice: coinHistoricalPrice)
                })
    }

}

extension CoinHistoricalPriceManager {

    enum CoinError: Error {
        case coinNotFound
    }

}
