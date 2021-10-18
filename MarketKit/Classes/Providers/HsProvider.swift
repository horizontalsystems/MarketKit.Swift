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

    func marketInfosSingle(top: Int) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "limit": top,
            "fields": "price,price_change_24h,market_cap,total_volume"
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
    }

    func advancedMarketInfosSingle(top: Int) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "limit": top,
            "fields": "price,market_cap,total_volume,price_change_24h,price_change_7d,price_change_14d,price_change_30d,price_change_200d,price_change_1y,ath_percentage,atl_percentage"
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
    }

    func marketInfosSingle(coinUids: [String]) -> Single<[MarketInfoRaw]> {
        let parameters: Parameters = [
            "uids": coinUids.joined(separator: ","),
            "fields": "price,price_change_24h,market_cap,total_volume"
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters)
    }

    func marketInfosSingle(categoryUid: String) -> Single<[MarketInfoRaw]> {
        networkManager.single(url: "\(baseUrl)/v1/categories/\(categoryUid)/coins", method: .get)
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String, languageCode: String) -> Single<MarketInfoOverviewRaw> {
        networkManager.single(url: "\(baseUrl)/v1/coins/\(coinUid)?currency=\(currencyCode)&language=\(languageCode)", method: .get)
    }

    func marketInfoDetailsSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoDetails> {
        networkManager.single(url: "\(baseUrl)/v1/coins/\(coinUid)/details?currency=\(currencyCode)", method: .get)
                .map { (response: MarketInfoDetailsResponse) -> MarketInfoDetails in
                    response.marketInfoDetails()
                }
    }

    func coinCategoriesSingle() -> Single<[CoinCategory]> {
        networkManager.single(url: "\(baseUrl)/v1/categories", method: .get)
    }

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

}
