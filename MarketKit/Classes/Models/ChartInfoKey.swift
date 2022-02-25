struct ChartInfoKey {
    let coin: Coin
    let currencyCode: String
    let interval: HsTimePeriod
}

extension ChartInfoKey: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coin.uid)
        hasher.combine(currencyCode)
        hasher.combine(interval.rawValue)
    }

    public static func ==(lhs: ChartInfoKey, rhs: ChartInfoKey) -> Bool {
        lhs.coin.uid == rhs.coin.uid && lhs.currencyCode == rhs.currencyCode && lhs.interval == rhs.interval
    }

}

extension ChartInfoKey: CustomStringConvertible {

    public var description: String {
        "[\(coin.uid); \(currencyCode); \(interval.rawValue)]"
    }

}
