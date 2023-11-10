import Alamofire
import Foundation
import HsToolKit
import ObjectMapper

class HsProvider {
    private let baseUrl: String
    private let networkManager: NetworkManager
    private let headers: HTTPHeaders

    var proAuthToken: String?

    init(baseUrl: String, networkManager: NetworkManager, appVersion: String, appId: String?, apiKey: String?) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager

        var headers = HTTPHeaders()
        headers.add(name: "app_platform", value: "ios")
        headers.add(name: "app_version", value: appVersion)

        if let appId {
            headers.add(name: "app_id", value: appId)
        }

        if let apiKey {
            headers.add(name: "apikey", value: apiKey)
        }

        self.headers = headers
    }

    private var proHeaders: HTTPHeaders? {
        guard let proAuthToken else {
            return headers
        }

        var proHeaders = headers
        proHeaders.add(.authorization(proAuthToken))
        return proHeaders
    }
}

extension HsProvider {
    func marketOverview(currencyCode: String) async throws -> MarketOverviewResponse {
        let parameters: Parameters = [
            "simplified": true,
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/markets/overview", method: .get, parameters: parameters, headers: headers)
    }

    func topMoversRaw(currencyCode: String) async throws -> TopMoversRaw {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins/top-movers", method: .get, parameters: parameters, headers: headers)
    }
}

extension HsProvider {
    // Status

    func status() async throws -> HsStatus {
        try await networkManager.fetch(url: "\(baseUrl)/v1/status/updates", method: .get, headers: headers)
    }

    // Coins

    func allCoins() async throws -> [Coin] {
        try await networkManager.fetch(url: "\(baseUrl)/v1/coins/list", method: .get, headers: headers)
    }

    func allBlockchainRecords() async throws -> [BlockchainRecord] {
        try await networkManager.fetch(url: "\(baseUrl)/v1/blockchains/list", method: .get, headers: headers)
    }

    func allTokenRecords() async throws -> [TokenRecord] {
        try await networkManager.fetch(url: "\(baseUrl)/v1/tokens/list", method: .get, headers: headers)
    }

    // Market Infos

    func marketInfos(top: Int, currencyCode: String, defi: Bool) async throws -> [MarketInfoRaw] {
        var parameters: Parameters = [
            "limit": top,
            "fields": "price,price_change_24h,market_cap,market_cap_rank,total_volume",
            "currency": currencyCode.lowercased(),
            "order_by_rank": "true",
        ]

        if defi {
            parameters["defi"] = "true"
        }

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters, headers: headers)
    }

    func advancedMarketInfos(top: Int, currencyCode: String) async throws -> [MarketInfoRaw] {
        let parameters: Parameters = [
            "limit": top,
            "fields": "price,market_cap,market_cap_rank,total_volume,price_change_24h,price_change_7d,price_change_14d,price_change_30d,price_change_200d,price_change_1y,ath_percentage,atl_percentage",
            "currency": currencyCode.lowercased(),
            "order_by_rank": "true",
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters, headers: headers)
    }

    func marketInfos(coinUids: [String], currencyCode: String) async throws -> [MarketInfoRaw] {
        let parameters: Parameters = [
            "uids": coinUids.joined(separator: ","),
            "fields": "price,price_change_24h,market_cap,market_cap_rank,total_volume",
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters, headers: headers)
    }

    func marketInfos(categoryUid: String, currencyCode: String) async throws -> [MarketInfoRaw] {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/categories/\(categoryUid)/coins", method: .get, parameters: parameters, headers: headers)
    }

    func marketInfoOverview(coinUid: String, currencyCode: String, languageCode: String) async throws -> MarketInfoOverviewResponse {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "language": languageCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins/\(coinUid)", method: .get, parameters: parameters, headers: headers)
    }

    func marketInfoDetails(coinUid: String, currencyCode: String) async throws -> MarketInfoDetails {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        let response: MarketInfoDetailsResponse = try await networkManager.fetch(url: "\(baseUrl)/v1/coins/\(coinUid)/details", method: .get, parameters: parameters, headers: headers)
        return response.marketInfoDetails()
    }

    func marketInfoTvl(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [ChartPoint] {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "interval": timePeriod.rawValue,
        ]

        let response: [MarketInfoTvlRaw] = try await networkManager.fetch(url: "\(baseUrl)/v1/defi-protocols/\(coinUid)/tvls", method: .get, parameters: parameters, headers: headers)
        return response.compactMap { $0.marketInfoTvl }
    }

    func marketInfoGlobalTvl(platform: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [ChartPoint] {
        var parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "interval": timePeriod.rawValue,
        ]

        if !platform.isEmpty {
            parameters["chain"] = platform
        }

        let response: [MarketInfoTvlRaw] = try await networkManager.fetch(url: "\(baseUrl)/v1/global-markets/tvls", method: .get, parameters: parameters, headers: headers)
        return response.compactMap { $0.marketInfoTvl }
    }

    func defiCoins(currencyCode: String) async throws -> [DefiCoinRaw] {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/defi-protocols", method: .get, parameters: parameters, headers: headers)
    }

    // Coin Categories

    func coinCategories(currencyCode: String? = nil) async throws -> [CoinCategory] {
        var parameters: Parameters = [:]
        if let currencyCode = currencyCode {
            parameters["currency"] = currencyCode.lowercased()
        }
        return try await networkManager.fetch(url: "\(baseUrl)/v1/categories", method: .get, parameters: parameters, headers: headers)
    }

    func coinCategoryMarketCapChart(category: String, currencyCode: String?, timePeriod: HsTimePeriod) async throws -> [CategoryMarketPoint] {
        var parameters: Parameters = [:]
        if let currencyCode = currencyCode {
            parameters["currency"] = currencyCode.lowercased()
        }
        parameters["interval"] = timePeriod.rawValue

        return try await networkManager.fetch(url: "\(baseUrl)/v1/categories/\(category)/market_cap", method: .get, parameters: parameters, headers: headers)
    }

    // Coin Prices

    func coinPrices(coinUids: [String], walletCoinUids: [String], currencyCode: String) async throws -> [CoinPrice] {
        var parameters: Parameters = [
            "uids": coinUids.joined(separator: ","),
            "currency": currencyCode.lowercased(),
            "fields": "price,price_change_24h,last_updated",
        ]

        if !walletCoinUids.isEmpty {
            parameters["enabled_uids"] = walletCoinUids.joined(separator: ",")
        }

        let responses: [CoinPriceResponse] = try await networkManager.fetch(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters, headers: headers)
        return responses.map { $0.coinPrice(currencyCode: currencyCode) }
    }

    func historicalCoinPrice(coinUid: String, currencyCode: String, timestamp: TimeInterval) async throws -> HistoricalCoinPriceResponse {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "timestamp": Int(timestamp),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins/\(coinUid)/price_history", method: .get, parameters: parameters, headers: headers)
    }

    func coinPriceChartStart(coinUid: String) async throws -> CoinPriceStart {
        try await networkManager.fetch(url: "\(baseUrl)/v1/coins/\(coinUid)/price_chart_start", method: .get, headers: headers)
    }

    func coinPriceChart(coinUid: String, currencyCode: String, interval: HsPointTimePeriod, fromTimestamp: TimeInterval? = nil) async throws -> [ChartCoinPriceResponse] {
        var parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "interval": interval.rawValue,
        ]

        if let fromTimestamp {
            parameters["from_timestamp"] = Int(fromTimestamp)
        }

        return try await networkManager.fetch(url: "\(baseUrl)/v1/coins/\(coinUid)/price_chart", method: .get, parameters: parameters, headers: headers)
    }

    // Holders

    func tokenHolders(coinUid: String, blockchainUid: String) async throws -> TokenHolders {
        let parameters: Parameters = [
            "blockchain_uid": blockchainUid,
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/\(coinUid)/holders", method: .get, parameters: parameters, headers: proHeaders)
    }

    // Funds

    func coinInvestments(coinUid: String) async throws -> [CoinInvestment] {
        let parameters: Parameters = [
            "coin_uid": coinUid,
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/funds/investments", method: .get, parameters: parameters, headers: headers)
    }

    func coinTreasuries(coinUid: String, currencyCode: String) async throws -> [CoinTreasury] {
        let parameters: Parameters = [
            "coin_uid": coinUid,
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/funds/treasuries", method: .get, parameters: parameters, headers: headers)
    }

    func coinReports(coinUid: String) async throws -> [CoinReport] {
        let parameters: Parameters = [
            "coin_uid": coinUid,
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/reports", method: .get, parameters: parameters, headers: headers)
    }

    func twitterUsername(coinUid: String) async throws -> String? {
        let response: TwitterUsernameResponse = try await networkManager.fetch(url: "\(baseUrl)/v1/coins/\(coinUid)/twitter", method: .get, headers: headers)
        return response.username
    }

    func globalMarketPoints(currencyCode: String, timePeriod: HsTimePeriod) async throws -> [GlobalMarketPoint] {
        let parameters: Parameters = [
            "interval": timePeriod.rawValue,
            "currency": currencyCode,
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/global-markets", method: .get, parameters: parameters, headers: headers)
    }

    // Top Platforms

    func topPlatforms(currencyCode: String) async throws -> [TopPlatformResponse] {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/top-platforms", method: .get, parameters: parameters)
    }

    func topPlatformCoinsList(blockchain: String, currencyCode: String) async throws -> [MarketInfoRaw] {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/top-platforms/\(blockchain)/list", method: .get, parameters: parameters)
    }

    func topPlatformMarketCapChart(platform: String, currencyCode: String?, timePeriod: HsTimePeriod) async throws -> [CategoryMarketPoint] {
        var parameters: Parameters = [:]
        if let currencyCode = currencyCode {
            parameters["currency"] = currencyCode.lowercased()
        }
        parameters["interval"] = timePeriod.rawValue

        return try await networkManager.fetch(url: "\(baseUrl)/v1/top-platforms/\(platform)/chart", method: .get, parameters: parameters, headers: headers)
    }

    // Pro Charts

    private func proData<T: ImmutableMappable>(path: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [T] {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "interval": timePeriod.rawValue,
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/\(path)", method: .get, parameters: parameters, headers: proHeaders)
    }

    private func proData<T: ImmutableMappable>(path: String, timePeriod: HsTimePeriod) async throws -> [T] {
        let parameters: Parameters = [
            "interval": timePeriod.rawValue,
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/\(path)", method: .get, parameters: parameters, headers: proHeaders)
    }

    private func rankData<T: ImmutableMappable>(type: String, currencyCode: String? = nil) async throws -> [T] {
        var parameters: Parameters = [
            "type": type,
        ]

        if let currencyCode {
            parameters["currency"] = currencyCode.lowercased()
        }

        return try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/ranks", method: .get, parameters: parameters, headers: proHeaders)
    }

    func analytics(coinUid: String, currencyCode: String) async throws -> Analytics {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/\(coinUid)", method: .get, parameters: parameters, headers: proHeaders)
    }

    func analyticsPreview(coinUid: String) async throws -> AnalyticsPreview {
        try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/\(coinUid)/preview", method: .get, headers: headers)
    }

    func dexVolumes(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [VolumePoint] {
        try await proData(path: "\(coinUid)/dex-volumes", currencyCode: currencyCode, timePeriod: timePeriod)
    }

    func dexLiquidity(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) async throws -> [VolumePoint] {
        try await proData(path: "\(coinUid)/dex-liquidity", currencyCode: currencyCode, timePeriod: timePeriod)
    }

    func activeAddresses(coinUid: String, timePeriod: HsTimePeriod) async throws -> [CountPoint] {
        try await proData(path: "\(coinUid)/addresses", timePeriod: timePeriod)
    }

    func transactions(coinUid: String, timePeriod: HsTimePeriod) async throws -> [CountVolumePoint] {
        try await proData(path: "\(coinUid)/transactions", timePeriod: timePeriod)
    }

    func cexVolumeRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await rankData(type: "cex_volume", currencyCode: currencyCode)
    }

    func dexVolumeRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await rankData(type: "dex_volume", currencyCode: currencyCode)
    }

    func dexLiquidityRanks() async throws -> [RankValue] {
        try await rankData(type: "dex_liquidity")
    }

    func activeAddressRanks() async throws -> [RankMultiValue] {
        try await rankData(type: "address")
    }

    func transactionCountRanks() async throws -> [RankMultiValue] {
        try await rankData(type: "tx_count")
    }

    func holdersRanks() async throws -> [RankValue] {
        try await rankData(type: "holders")
    }

    func feeRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await rankData(type: "fee", currencyCode: currencyCode)
    }

    func revenueRanks(currencyCode: String) async throws -> [RankMultiValue] {
        try await rankData(type: "revenue", currencyCode: currencyCode)
    }

    // Authentication

    func subscriptions(addresses: [String]) async throws -> [ProSubscription] {
        let parameters: Parameters = [
            "address": addresses.joined(separator: ","),
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/analytics/subscriptions", method: .get, parameters: parameters, headers: headers)
    }

    func authKey(address: String) async throws -> String {
        let parameters: Parameters = [
            "address": address,
        ]

        let response: SignMessageResponse = try await networkManager.fetch(url: "\(baseUrl)/v1/auth/get-sign-message", method: .get, parameters: parameters, headers: headers)

        return response.message
    }

    func authenticate(signature: String, address: String) async throws -> String {
        let parameters: Parameters = [
            "signature": signature,
            "address": address,
        ]

        let response: AuthenticateResponse = try await networkManager.fetch(url: "\(baseUrl)/v1/auth/authenticate", method: .post, parameters: parameters, headers: headers)

        return response.token
    }

    // Personal Support

    func requestPersonalSupport(telegramUsername: String) async throws {
        let parameters: Parameters = [
            "username": telegramUsername,
        ]

        _ = try await networkManager.fetchJson(url: "\(baseUrl)/v1/support/start-chat", method: .post, parameters: parameters, headers: proHeaders)
    }

    // Verified Exchanges

    func verifiedExchangeUids() async throws -> [String] {
        let json = try await networkManager.fetchJson(url: "\(baseUrl)/v1/exchanges/whitelist", headers: headers)

        guard let uids = json as? [String] else {
            throw NetworkManager.TaskError()
        }

        return uids
    }
}

extension HsProvider {
    struct HistoricalCoinPriceResponse: ImmutableMappable {
        let timestamp: Int
        let price: Decimal

        init(map: Map) throws {
            timestamp = try map.value("timestamp")
            price = try map.value("price", using: Transform.stringToDecimalTransform)
        }
    }

    struct ChartCoinPriceResponse: ImmutableMappable {
        let timestamp: Int
        let price: Decimal
        let totalVolume: Decimal?

        init(map: Map) throws {
            timestamp = try map.value("timestamp")
            price = try map.value("price", using: Transform.stringToDecimalTransform)
            totalVolume = try? map.value("volume", using: Transform.stringToDecimalTransform)
        }

        var chartPoint: ChartPoint {
            ChartPoint(
                timestamp: TimeInterval(timestamp),
                value: price,
                volume: totalVolume
            )
        }

        var volumeChartPoint: ChartPoint? {
            guard let totalVolume else {
                return nil
            }

            return ChartPoint(timestamp: TimeInterval(timestamp), value: totalVolume)
        }
    }

    struct SignMessageResponse: ImmutableMappable {
        let message: String

        init(map: Map) throws {
            message = try map.value("message")
        }
    }

    struct AuthenticateResponse: ImmutableMappable {
        let token: String

        init(map: Map) throws {
            token = try map.value("token")
        }
    }
}
