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

}
