import Foundation

class CoinHistoricalPriceManager {
    private let storage: CoinHistoricalPriceStorage
    private let hsProvider: HsProvider

    init(storage: CoinHistoricalPriceStorage, hsProvider: HsProvider) {
        self.storage = storage
        self.hsProvider = hsProvider
    }
}

extension CoinHistoricalPriceManager {
    func cachedCoinHistoricalPriceValue(coinUid: String, currencyCode: String, timestamp: TimeInterval) -> Decimal? {
        try? storage.coinHistoricalPrice(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)?.value
    }

    func coinHistoricalPriceValue(coinUid: String, currencyCode: String, timestamp: TimeInterval) async throws -> Decimal {
        let response = try await hsProvider.historicalCoinPrice(coinUid: coinUid, currencyCode: currencyCode, timestamp: timestamp)

        guard abs(Int(timestamp) - response.timestamp) < 24 * 60 * 60 else { // 1 day
            throw ResponseError.returnedTimestampIsTooInaccurate
        }

        try? storage.save(coinHistoricalPrice: CoinHistoricalPrice(coinUid: coinUid, currencyCode: currencyCode, value: response.price, timestamp: timestamp))

        return response.price
    }
}

extension CoinHistoricalPriceManager {
    enum ResponseError: Error {
        case returnedTimestampIsTooInaccurate
    }
}
