import Foundation

public struct PerformanceRow {
    public let base: PerformanceBase
    public let changes: [HsTimePeriod: Decimal]
}

public enum PerformanceBase: String, CaseIterable {
    case usd
    case btc
    case eth

    private var index: Int {
        switch self {
        case .usd: return 0
        case .btc: return 1
        case .eth: return 2
        }
    }
}

extension PerformanceBase: Comparable {
    public static func < (lhs: PerformanceBase, rhs: PerformanceBase) -> Bool {
        lhs.index < rhs.index
    }

    public static func == (lhs: PerformanceBase, rhs: PerformanceBase) -> Bool {
        lhs.index == rhs.index
    }
}
