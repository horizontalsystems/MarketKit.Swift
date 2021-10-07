struct ChartInfoKey {
    let coin: Coin
    let currencyCode: String
    let chartType: ChartType
}

extension ChartInfoKey: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coin.uid)
        hasher.combine(currencyCode)
        hasher.combine(chartType)
    }

    public static func ==(lhs: ChartInfoKey, rhs: ChartInfoKey) -> Bool {
        lhs.coin.uid == rhs.coin.uid && lhs.currencyCode == rhs.currencyCode && lhs.chartType == rhs.chartType
    }

}

extension ChartInfoKey: CustomStringConvertible {

    public var description: String {
        "[\(coin.uid); \(currencyCode); \(chartType)]"
    }

}
