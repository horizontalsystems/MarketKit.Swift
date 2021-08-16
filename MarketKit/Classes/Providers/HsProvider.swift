import RxSwift
import HsToolKit

class HsProvider {
    private let baseUrl: String
    private let networkManager: NetworkManager

    init(baseUrl: String, networkManager: NetworkManager) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager
    }

}

extension HsProvider {

    func coinsSingle() -> Single<[Coin]> {
        networkManager.single(url: "\(baseUrl)/coins", method: .get)
    }

}
