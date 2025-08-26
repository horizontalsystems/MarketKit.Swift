public struct FullCoin {
    public let coin: Coin
    public let tokens: [Token]

    public init(coin: Coin, tokens: [Token]) {
        self.coin = coin
        self.tokens = tokens
    }
}

extension FullCoin: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.coin == rhs.coin && lhs.tokens == rhs.tokens
    }
}

extension FullCoin: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(coin.uid)
    }
}

extension FullCoin: Identifiable {
    public var id: String {
        coin.uid
    }
}
