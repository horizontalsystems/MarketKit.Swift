import RxSwift

class PostManager {
    private let provider: CryptoCompareProvider

    init(provider: CryptoCompareProvider) {
        self.provider = provider
    }

}

extension PostManager {

    func postsSingle() -> Single<[Post]> {
        provider.postsSingle()
    }

}
