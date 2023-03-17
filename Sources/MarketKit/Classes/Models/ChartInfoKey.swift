import Foundation

struct ChartInfoKey {
    let coinUid: String
    let currencyCode: String
    let periodType: HsPeriodType
}

extension ChartInfoKey: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coinUid)
        hasher.combine(currencyCode)
        hasher.combine(periodType)
    }

    public static func ==(lhs: ChartInfoKey, rhs: ChartInfoKey) -> Bool {
        lhs.coinUid == rhs.coinUid && lhs.currencyCode == rhs.currencyCode && lhs.periodType == rhs.periodType
    }

}

extension ChartInfoKey: CustomStringConvertible {

    public var description: String {
        "[\(coinUid); \(currencyCode); \(periodType)]"
    }

}
