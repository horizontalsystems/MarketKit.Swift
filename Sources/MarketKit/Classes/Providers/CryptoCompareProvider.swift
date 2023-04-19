import Alamofire
import HsToolKit

class CryptoCompareProvider {
    private let baseUrl = "https://min-api.cryptocompare.com"

    private let networkManager: NetworkManager
    private let apiKey: String?

    init(networkManager: NetworkManager, apiKey: String?) {
        self.networkManager = networkManager
        self.apiKey = apiKey
    }

}

extension CryptoCompareProvider {

    func posts() async throws -> [Post] {
        var parameters: Parameters = [
            "excludeCategories": "Sponsored",
            "feeds": "cointelegraph,theblock,decrypt",
            "extraParams": "Blocksdecoded"
        ]

        parameters["api_key"] = apiKey

        let postsResponse: PostsResponse = try await networkManager.fetch(url: "\(baseUrl)/data/v2/news/", method: .get, parameters: parameters, interceptor: RateLimitRetrier(), responseCacherBehavior: .doNotCache)
        return postsResponse.posts
    }

}

extension CryptoCompareProvider {

    class RateLimitRetrier: RequestInterceptor {
        private var attempt = 0

        func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> ()) {
            let error = NetworkManager.unwrap(error: error)

            if case RequestError.rateLimitExceeded = error {
                completion(resolveResult())
            } else {
                completion(.doNotRetry)
            }
        }

        private func resolveResult() -> RetryResult {
            attempt += 1

            if attempt == 1 { return .retryWithDelay(3) }
            if attempt == 2 { return .retryWithDelay(6) }

            return .doNotRetry
        }

    }

}

extension CryptoCompareProvider {

    enum RequestError: Error {
        case rateLimitExceeded
    }

}
