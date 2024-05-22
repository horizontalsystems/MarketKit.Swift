import Foundation
import ObjectMapper

public struct Etf: ImmutableMappable {
    public let ticker: String
    public let name: String
    public let date: Date?
    public let totalAssets: Decimal?
    public let totalInflow: Decimal?
    public let inflows: [HsTimePeriod: Decimal]

    public init(map: Map) throws {
        ticker = try map.value("ticker")
        name = try map.value("name")
        date = try? map.value("date", using: Self.dateTransform)
        totalAssets = try? map.value("total_assets", using: Transform.stringToDecimalTransform)
        totalInflow = try? map.value("total_inflow", using: Transform.stringToDecimalTransform)

        var inflows = [HsTimePeriod: Decimal]()

        inflows[.day1] = try? map.value("inflow_1d", using: Transform.stringToDecimalTransform)
        inflows[.week1] = try? map.value("inflow_1w", using: Transform.stringToDecimalTransform)
        inflows[.month1] = try? map.value("inflow_1m", using: Transform.stringToDecimalTransform)
        inflows[.month3] = try? map.value("inflow_3m", using: Transform.stringToDecimalTransform)

        self.inflows = inflows
    }
}

extension Etf {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    static let dateTransform: TransformOf<Date, String> = TransformOf(
        fromJSON: { string -> Date? in
            guard let string else { return nil }
            return dateFormatter.date(from: string)
        },
        toJSON: { (value: Date?) in
            guard let value else { return nil }
            return dateFormatter.string(from: value)
        }
    )
}
