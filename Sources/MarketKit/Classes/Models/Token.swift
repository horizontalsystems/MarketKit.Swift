public struct Token {
    public let coin: Coin
    public let blockchain: Blockchain
    public let type: TokenType
    public let decimals: Int

    public init(coin: Coin, blockchain: Blockchain, type: TokenType, decimals: Int) {
        self.coin = coin
        self.blockchain = blockchain
        self.type = type
        self.decimals = decimals
    }

    public var blockchainType: BlockchainType {
        blockchain.type
    }

    public var tokenQuery: TokenQuery {
        TokenQuery(blockchainType: blockchainType, tokenType: type)
    }

    public var fullCoin: FullCoin {
        FullCoin(coin: coin, tokens: [self])
    }

}

extension Token: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coin)
        hasher.combine(blockchain)
        hasher.combine(type)
        hasher.combine(decimals)
    }

}

extension Token: Equatable {

    public static func ==(lhs: Token, rhs: Token) -> Bool {
        lhs.coin == rhs.coin
                && lhs.blockchain == rhs.blockchain
                && lhs.type == rhs.type
                && lhs.decimals == rhs.decimals
    }

}

extension Token: CustomStringConvertible {

    public var description: String {
        "Token [coin: \(coin); blockchain: \(blockchain); type: \(type); decimals: \(decimals)]"
    }

}
