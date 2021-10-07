import RxSwift
import HsToolKit
import Alamofire

class CryptoCompareProvider {
    private let baseUrl = "https://min-api.cryptocompare.com"

    private let networkManager: NetworkManager
    private let apiKey: String?

    init(networkManager: NetworkManager, apiKey: String?) {
        self.networkManager = networkManager
        self.apiKey = apiKey
    }

    private func request(path: String, parameters: Parameters = [:]) -> DataRequest {
        var parameters = parameters
        parameters["api_key"] = apiKey

        return networkManager.session
                .request(baseUrl + path, method: .get, parameters: parameters, interceptor: RateLimitRetrier())
                .cacheResponse(using: ResponseCacher(behavior: .doNotCache))
    }

}

extension CryptoCompareProvider {

    func postsSingle() -> Single<[Post]> {
        var parameters: Parameters = [
            "excludeCategories": "Sponsored",
            "feeds": "cointelegraph,theblock,decrypt",
            "extraParams": "Blocksdecoded"
        ]

        return networkManager.single(request: request(path: "/data/v2/news/", parameters: parameters)).map { (postsResponse: PostsResponse) in
            postsResponse.posts
        }
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
