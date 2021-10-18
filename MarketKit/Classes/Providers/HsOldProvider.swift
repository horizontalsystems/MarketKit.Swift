import Foundation
import RxSwift
import HsToolKit
import Alamofire
import ObjectMapper

class HsOldProvider {
    private let baseUrl: String
    private let networkManager: NetworkManager

    init(baseUrl: String, networkManager: NetworkManager) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager
    }

}

extension HsOldProvider {

    func globalMarketPointsSingle(currencyCode: String, timePeriod: TimePeriod) -> Single<[GlobalMarketPoint]> {
        let parameters: Parameters = [
            "currency_code": currencyCode
        ]

        return networkManager.single(url: "\(baseUrl)/api/v1/markets/global/\(timePeriod.rawValue)", method: .get, parameters: parameters)
    }

    func topTokenHoldersSingle(fullCoin: FullCoin, itemsCount: Int) -> Single<[TokenHolder]> {
        var resolvedAddress: String? = nil

        for platform in fullCoin.platforms {
            if case .erc20(let address) = platform.coinType {
                resolvedAddress = address
            }
        }

        guard let address = resolvedAddress else {
            return Single.error(TopTokenHoldersError.unsupportedCoinType)
        }

        let parameters: Parameters = ["limit": itemsCount]

        return networkManager.single(url: "\(baseUrl)tokens/holders/\(address)", method: .get, parameters: parameters)
    }

}

extension HsOldProvider {

    enum TopTokenHoldersError: Error {
        case unsupportedCoinType
    }

}
