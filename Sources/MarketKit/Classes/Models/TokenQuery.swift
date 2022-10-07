public struct TokenQuery {
    public let blockchainType: BlockchainType
    public let tokenType: TokenType

    public init(blockchainType: BlockchainType, tokenType: TokenType) {
        self.blockchainType = blockchainType
        self.tokenType = tokenType
    }

    public init?(id: String) {
        let chunks = id.split(separator: "|").map { String($0) }

        guard chunks.count == 2, let tokenType = TokenType(id: chunks[1]) else {
            return nil
        }

        self.init(
                blockchainType: BlockchainType(uid: chunks[0]),
                tokenType: tokenType
        )
    }

    public var id: String {
        [blockchainType.uid, tokenType.id].joined(separator: "|")
    }

}

extension TokenQuery: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(blockchainType)
        hasher.combine(tokenType)
    }

}

extension TokenQuery: Equatable {

    public static func ==(lhs: TokenQuery, rhs: TokenQuery) -> Bool {
        lhs.blockchainType == rhs.blockchainType && lhs.tokenType == rhs.tokenType
    }

}
