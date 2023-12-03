class PostManager {
    private let provider: CryptoCompareProvider

    init(provider: CryptoCompareProvider) {
        self.provider = provider
    }
}

extension PostManager {
    func posts() async throws -> [Post] {
        try await provider.posts()
    }
}
