import Foundation
import Alamofire
import ObjectMapper
import HsToolKit

class CoinGeckoProvider {
    private let baseUrl = "https://api.coingecko.com/api/v3"

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

}

extension CoinGeckoProvider {

    func exchanges(limit: Int, page: Int) async throws -> [Exchange] {
        let parameters: Parameters = [
            "per_page": limit,
            "page": page
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/exchanges", method: .get, parameters: parameters)
    }

    func marketTickers(coinId: String) async throws -> CoinGeckoCoinResponse {
        let parameters: Parameters = [
            "tickers": "true",
            "localization": "false",
            "market_data": "false",
            "community_data": "false",
            "developer_data": "false",
            "sparkline": "false"
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/coins/\(coinId)", method: .get, parameters: parameters)
    }

}
