import Alamofire
import ObjectMapper

enum HsProChartResource: String {
    case dexVolume = "transactions/dex-volumes"
    case dexLiquidity = "transactions/dex-liquidity"
    case txCountVolume = "transactions"
}

protocol IHsProChartResource {
    static var source: String { get }
}

public class ProChartPointDataResponse: ImmutableMappable {
    let timestamp: TimeInterval
    let count: Decimal?
    let volume: Decimal?

    required public init(map: Map) throws {
//      todo: wait backend and change
//      timestamp = try map.value("timestamp")
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)

        let dateString: String? = try map.value("date")
        let date = dateString.flatMap { formatter.date(from: $0) }

        timestamp = date?.timeIntervalSince1970 ?? -1
        count = try? map.value("count", using: Transform.stringToDecimalTransform)
        volume = try? map.value("volume", using: Transform.stringToDecimalTransform)
    }
}

extension Collection where Element: ProChartPointDataResponse {

    public var volumePoints: [ChartPoint] {
        self.compactMap { item in
            item.volume.map { ChartPoint(timestamp: item.timestamp, value: $0) }
        }
    }

    public var countPoints: [ChartPoint] {
        self.compactMap { item in
            item.count.map { ChartPoint(timestamp: item.timestamp, value: $0) }
        }
    }

}

public class ProDataResponse {
    class func dataField() -> String { "" }

    let platforms: [String]
    let data: [ProChartPointDataResponse]

    required public init(map: Map) throws {
        platforms = try map.value("platforms")
        data = try map.value(Self.dataField())
    }

    init(platforms: [String], data: [ProChartPointDataResponse]) {
        self.platforms = platforms
        self.data = data
    }

    public var volumePoints: [ChartPoint] {
        data.volumePoints
    }

    public var countPoints: [ChartPoint] {
        data.countPoints
    }

}

public class DexLiquidityResponse: ProDataResponse, ImmutableMappable, IHsProChartResource {
    static let source = HsProChartResource.dexLiquidity.rawValue
    static public var empty = DexLiquidityResponse(platforms: [], data: [])

    override class func dataField() -> String { "liquidity" }
}

public class DexVolumeResponse: ProDataResponse, ImmutableMappable, IHsProChartResource {
    static let source = HsProChartResource.dexVolume.rawValue
    static public var empty = DexVolumeResponse(platforms: [], data: [])

    override class func dataField() -> String { "volumes" }
}

public class TransactionDataResponse: ProDataResponse, ImmutableMappable, IHsProChartResource {
    static let source = HsProChartResource.txCountVolume.rawValue
    static public var empty = TransactionDataResponse(platforms: [], data: [])

    override class func dataField() -> String { "transactions" }
}
