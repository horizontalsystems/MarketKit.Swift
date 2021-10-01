import Foundation
import RxSwift
import HsToolKit
import Alamofire
import ObjectMapper

class HsProvider {
    private let baseUrl: String
    private let networkManager: NetworkManager
    private let categoryManager: CoinCategoryManager

    init(baseUrl: String, networkManager: NetworkManager, categoryManager: CoinCategoryManager) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager
        self.categoryManager = categoryManager
    }

}

extension HsProvider {

    func fullCoinsSingle() -> Single<[FullCoin]> {
        networkManager.single(url: "\(baseUrl)/v1/coins/all", method: .get).map { (fullCoinResponses: [FullCoinResponse]) -> [FullCoin] in
            fullCoinResponses.map { FullCoin(fullCoinResponse: $0) }
        }
    }

    func marketInfosSingle(top: Int, limit: Int?, order: MarketInfo.Order?) -> Single<[MarketInfo]> {
        var parameters: Parameters = [
            "top": top
        ]

        if let limit = limit {
            parameters["limit"] = limit
        }

        if let order = order {
            parameters["orderField"] = order.field.rawValue
            parameters["orderDirection"] = order.direction.rawValue
        }

        return networkManager.single(url: "\(baseUrl)/v1/coins", method: .get, parameters: parameters).map { (marketInfoResponses: [MarketInfoResponse]) -> [MarketInfo] in
            marketInfoResponses.map { MarketInfo(marketInfoResponse: $0) }
        }
    }

    func marketInfoOverviewSingle(coinUid: String, currencyCode: String) -> Single<MarketInfoOverview> {
        networkManager.single(url: "\(baseUrl)/v1/coins/\(coinUid)?currencyCode=\(currencyCode)", method: .get).map { [weak self] (response: MarketInfoOverviewResponse) -> MarketInfoOverview in
            let categories = response.categoryIds.compactMap { self?.categoryManager.categoryName(uid: $0) }

            return MarketInfoOverview(response: response, categories: categories)
        }
    }

    func coinCategoriesSingle() -> Single<[CoinCategory]> {
        networkManager.single(url: "\(baseUrl)/v1/categories", method: .get)
    }

    func coinPricesSingle(coinUids: [String], currencyCode: String) -> Single<[CoinPrice]> {
        let parameters: Parameters = [
            "ids": coinUids.joined(separator: ","),
            "currency": currencyCode
        ]

        return networkManager.single(url: "\(baseUrl)/v1/coins/prices", method: .get, parameters: parameters).map { (coinPriceResponsesMap: [String: CoinPriceResponse]) -> [CoinPrice] in
            coinPriceResponsesMap.map { coinUid, coinPriceResponse in
                CoinPrice(
                        coinUid: coinUid,
                        currencyCode: currencyCode,
                        value: coinPriceResponse.price,
                        diff: coinPriceResponse.priceChange,
                        timestamp: coinPriceResponse.lastUpdated
                )
            }
        }
    }

}
