import Foundation
import RxSwift
import HsToolKit
import Alamofire
import ObjectMapper

class HsProvider {
    private let baseUrl: String
    private let networkManager: NetworkManager

    init(baseUrl: String, networkManager: NetworkManager) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager
    }

}

extension HsProvider {

    // Full Coins

    func fullCoinsSingle() -> Single<[FullCoin]> {
        let parameters: Parameters = [
            "fields": "name,code,market_cap_rank,coingecko_id,platforms"
        ]

        return networkManager
                .single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
                .map { (fullCoinResponses: [FullCoinResponse]) -> [FullCoin] in
                    fullCoinResponses.map { $0.fullCoin() }
                }
    }

    // Market Infos

    func marketInfosSingle(top: Int, currencyCode: String) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "limit": top,
            "fields": "price,price_change_24h,market_cap,total_volume",
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
    }

    func advancedMarketInfosSingle(top: Int, currencyCode: String) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "limit": top,
            "fields": "price,market_cap,total_volume,price_change_24h,price_change_7d,price_change_14d,price_change_30d,price_change_200d,price_change_1y,ath_percentage,atl_percentage",
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
    }

    func marketInfosSingle(coinUids: [String], currencyCode: String) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "uids": coinUids.joined(separator: ","),
            "fields": "price,price_change_24h,market_cap,total_volume",
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
    }

    func marketInfosSingle(categoryUid: String, currencyCode: String) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/categories/\(categoryUid)/coins", method: .get, parameters: parameters)
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverviewRaw> {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "language": languageCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins/\(coinUid)", method: .get, parameters: parameters)
    }

    func marketInfoDetailsSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoDetails> {
        let parameters: Parameters = [
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins/\(coinUid)/details", method: .get, parameters: parameters)
                .map { (response: MarketInfoDetailsResponse) -> MarketInfoDetails in
                    response.marketInfoDetails()
                }
    }

    func marketInfoTvlSingle(coinUid: String, currencyCode: String, timePeriod: TimePeriod) -> Single<[ChartPoint]> {
        let interval: String

        switch timePeriod {
        case .day7: interval = "7d"
        case .day30: interval = "30d"
        default: interval = "1d"
        }

        let parameters: Parameters = [
            "currency": currencyCode.lowercased(),
            "interval": interval
        ]

        return networkManager.single(url: "\(baseUrl)/v1/defi-coins/\(coinUid)/tvls", method: .get, parameters: parameters)
                .map { (response: [MarketInfoTvlRaw]) -> [ChartPoint] in
                    response.map { $0.marketInfoTvl }
                }
    }

    // Coin Categories

    func coinCategoriesSingle() -> Single<[CoinCategory]> {
        networkManager.single(url: "\(baseUrl)/v1/categories", method: .get)
    }

    // Coin Prices

    func coinPricesSingle(coinUids: [String], currencyCode: String) -> Single<[CoinPrice]> {
        let parameters: Parameters = [
            "uids": coinUids.joined(separator: ","),
            "currency": currencyCode.lowercased(),
            "fields": "price,price_change_24h,last_updated"
        ]

        return networkManager
                .single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
                .map { (coinPriceResponses: [CoinPriceResponse]) -> [CoinPrice] in
                    coinPriceResponses.map { coinPriceResponse in
                        coinPriceResponse.coinPrice(currencyCode: currencyCode)
                    }
                }
    }

    // Holders

    func topHoldersSingle(coinUid: String) -> Single<[TokenHolder]> {
        let parameters: Parameters = [
            "coin_uid": coinUid
        ]

        return networkManager.single(url: "\(baseUrl)/v1/addresses/holders", method: .get, parameters: parameters)
    }

    // Funds

    func coinInvestmentsSingle(coinUid: String, currencyCode: String) -> Single<[CoinInvestment]> {
        let parameters: Parameters = [
            "coin_uid": coinUid,
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/funds/investments", method: .get, parameters: parameters)
    }

    func coinTreasuriesSingle(coinUid: String, currencyCode: String) -> Single<[CoinTreasury]> {
        let parameters: Parameters = [
            "coin_uid": coinUid,
            "currency": currencyCode.lowercased()
        ]

        return networkManager.single(url: "\(baseUrl)/v1/funds/treasuries", method: .get, parameters: parameters)
    }

}
