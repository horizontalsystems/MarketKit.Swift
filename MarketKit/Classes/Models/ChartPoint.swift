import Foundation
import GRDB

public class ChartPoint {
    public let timestamp: TimeInterval
    public let value: Decimal
    public var extra: [String: Decimal]

    public init(timestamp: TimeInterval, value: Decimal, extra: [String: Decimal] = [:]) {
        self.timestamp = timestamp
        self.value = value
        self.extra = extra
    }

    @discardableResult public func added(field: String, value: Decimal?) -> Self {
        if let value = value {
            extra[field] = value
        } else {
            extra.removeValue(forKey: field)
        }
        return self
    }

}

extension ChartPoint {
    public static let volume = "volume"
}

extension ChartPoint: Equatable {

    public static func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        lhs.timestamp == rhs.timestamp && lhs.value == rhs.value
    }

}
