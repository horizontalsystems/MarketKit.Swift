import Foundation

struct ChartInfoKey {
    let coin: Coin
    let currencyCode: String
    let periodType: HsPeriodType
}

extension ChartInfoKey: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coin.uid)
        hasher.combine(currencyCode)
        hasher.combine(periodType)
    }

    public static func ==(lhs: ChartInfoKey, rhs: ChartInfoKey) -> Bool {
        lhs.coin.uid == rhs.coin.uid && lhs.currencyCode == rhs.currencyCode && lhs.periodType == rhs.periodType
    }

}

extension ChartInfoKey: CustomStringConvertible {

    public var description: String {
        "[\(coin.uid); \(currencyCode); \(periodType)]"
    }

}
