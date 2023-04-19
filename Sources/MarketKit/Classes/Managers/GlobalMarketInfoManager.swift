import Foundation

class GlobalMarketInfoManager {
    private let expirationInterval: TimeInterval = 600 // 6 mins

    private let provider: HsProvider
    private let storage: GlobalMarketInfoStorage

    init(provider: HsProvider, storage: GlobalMarketInfoStorage) {
        self.provider = provider
        self.storage = storage
    }

}

extension GlobalMarketInfoManager {

    func globalMarketPoints(currencyCode: String, timePeriod: HsTimePeriod) async throws -> [GlobalMarketPoint] {
        let currentTimestamp = Date().timeIntervalSince1970

        if let storedInfo = try? storage.globalMarketInfo(currencyCode: currencyCode, timePeriod: timePeriod), currentTimestamp - storedInfo.timestamp < expirationInterval {
            return storedInfo.points
        }

        let points = try await provider.globalMarketPoints(currencyCode: currencyCode, timePeriod: timePeriod)

        let info = GlobalMarketInfo(currencyCode: currencyCode, timePeriod: timePeriod, points: points)
        try? storage.save(globalMarketInfo: info)

        return points
    }

}
