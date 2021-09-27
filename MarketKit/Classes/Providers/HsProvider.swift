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
        networkManager.single(url: "\(baseUrl)/v1/coins/all", method: .get).map { (fullCoinResponses: [FullCoinResponse]) -> [FullCoin] in
            fullCoinResponses.map { FullCoin(fullCoinResponse: $0) }
        }
    }

    func marketInfosSingle() -> Single<[MarketInfo]> {
        networkManager.single(url: "\(baseUrl)/v1/coins", method: .get).map { (marketInfoResponses: [MarketInfoResponse]) -> [MarketInfo] in
            marketInfoResponses.map { MarketInfo(marketInfoResponse: $0) }
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
