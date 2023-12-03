public struct FullCoin {
    public let coin: Coin
    public let tokens: [Token]

    public init(coin: Coin, tokens: [Token]) {
        self.coin = coin
        self.tokens = tokens
    }
}
