import Foundation
import Alamofire
import ObjectMapper

enum HsProChartResource: String {
    case dexVolume = "transactions/dex-volumes"
    case dexLiquidity = "transactions/dex-liquidity"
    case txCountVolume = "transactions"
    case activeAddresses = "addresses"
}

protocol IHsProChartResource {
    static var source: String { get }
}

public class ProChartPointDataResponse: ImmutableMappable {
    let timestamp: TimeInterval
    let count: Int?
    let volume: Decimal?

    required public init(map: Map) throws {
        timestamp = try map.value("timestamp")
        count = try? map.value("count")
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
            item.count.map { ChartPoint(timestamp: item.timestamp, value: Decimal($0)) }
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

public class ActiveAddressesResponse: ProDataResponse, ImmutableMappable, IHsProChartResource {
    static let source = HsProChartResource.activeAddresses.rawValue
    static public var empty = ActiveAddressesResponse(platforms: [], data: [])

    override class func dataField() -> String { "addresses" }
}

public class TransactionDataResponse: ProDataResponse, ImmutableMappable, IHsProChartResource {
    static let source = HsProChartResource.txCountVolume.rawValue
    static public var empty = TransactionDataResponse(platforms: [], data: [])

    override class func dataField() -> String { "transactions" }
}

public struct Analytics: ImmutableMappable {
    public let cexVolume: ExVolume?
    public let dexVolume: ExVolume?
    public let dexLiquidity: DexLiquidity?
    public let addresses: Addresses?
    public let transactions: Transactions?
    public let holders: [HolderBlockchain]?
    public let tvl: Tvl?
    public let revenue: Revenue?
    public let reports: Int?
    public let fundsInvested: Decimal?
    public let treasuries: Decimal?

    public init(map: Map) throws {
        cexVolume = try? map.value("cex_volume")
        dexVolume = try? map.value("dex_volume")
        dexLiquidity = try? map.value("dex_liquidity")
        addresses = try? map.value("addresses")
        transactions = try? map.value("transactions")
        holders = try? map.value("holders")
        tvl = try? map.value("tvl")
        revenue = try? map.value("revenue")
        reports = try? map.value("reports")
        fundsInvested = try? map.value("funds_invested", using: Transform.stringToDecimalTransform)
        treasuries = try? map.value("treasuries", using: Transform.stringToDecimalTransform)
    }

    public struct ExVolume: ImmutableMappable {
        public let points: [VolumePoint]
        public let rank30d: Int?

        public init(map: Map) throws {
            points = try map.value("points")
            rank30d = try? map.value("rank_30d")
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct DexLiquidity: ImmutableMappable {
        public let points: [VolumePoint]
        public let rank: Int?

        public init(map: Map) throws {
            points = try map.value("points")
            rank = try? map.value("rank")
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct Addresses: ImmutableMappable {
        public let points: [CountPoint]
        public let rank30d: Int?
        public let count30d: Int?

        public init(map: Map) throws {
            points = try map.value("points")
            rank30d = try? map.value("rank_30d")
            count30d = try? map.value("count_30d")
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct Transactions: ImmutableMappable {
        public let points: [CountPoint]
        public let rank30d: Int?
        public let volume30d: Decimal?

        public init(map: Map) throws {
            points = try map.value("points")
            rank30d = try? map.value("rank_30d")
            volume30d = try? map.value("volume_30d", using: Transform.stringToDecimalTransform)
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct HolderBlockchain: ImmutableMappable {
        public let uid: String
        public let holdersCount: Decimal

        public init(map: Map) throws {
            uid = try map.value("blockchain_uid")
            holdersCount = try map.value("holders_count", using: Transform.stringToDecimalTransform)
        }
    }

    public struct Tvl: ImmutableMappable {
        public let points: [TvlPoint]
        public let rank: Int?
        public let ratio: Decimal?

        public init(map: Map) throws {
            points = try map.value("points")
            rank = try? map.value("rank")
            ratio = try? map.value("ratio", using: Transform.stringToDecimalTransform)
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct Revenue: ImmutableMappable {
        public let value30d: Decimal?
        public let rank30d: Int?

        public init(map: Map) throws {
            value30d = try? map.value("value_30d", using: Transform.stringToDecimalTransform)
            rank30d = try? map.value("rank_30d")
        }
    }

    public struct VolumePoint: ImmutableMappable {
        public let timestamp: TimeInterval
        public let volume: Decimal

        public init(map: Map) throws {
            timestamp = try map.value("timestamp")
            volume = try map.value("volume", using: Transform.stringToDecimalTransform)
        }

        public var chartPoint: ChartPoint {
            ChartPoint(timestamp: timestamp, value: volume)
        }
    }

    public struct CountPoint: ImmutableMappable {
        public let timestamp: TimeInterval
        public let count: Decimal

        public init(map: Map) throws {
            timestamp = try map.value("timestamp")
            count = try map.value("count", using: Transform.stringToDecimalTransform)
        }

        public var chartPoint: ChartPoint {
            ChartPoint(timestamp: timestamp, value: count)
        }
    }

    public struct TvlPoint: ImmutableMappable {
        public let timestamp: TimeInterval
        public let tvl: Decimal

        public init(map: Map) throws {
            timestamp = try map.value("timestamp")
            tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
        }

        public var chartPoint: ChartPoint {
            ChartPoint(timestamp: timestamp, value: tvl)
        }
    }

}

public struct AnalyticsPreview: ImmutableMappable {
    public let cexVolume: Bool
    public let cexVolumeRank30d: Bool
    public let dexVolume: Bool
    public let dexVolumeRank30d: Bool
    public let dexLiquidity: Bool
    public let dexLiquidityRank: Bool
    public let addresses: Bool
    public let addressesRank30d: Bool
    public let transactions: Bool
    public let transactionsVolume30d: Bool
    public let transactionsRank30d: Bool
    public let holders: Bool
    public let tvl: Bool
    public let tvlRank: Bool
    public let tvlRatio: Bool
    public let revenue: Bool
    public let revenueRank30d: Bool
    public let reports: Bool
    public let fundsInvested: Bool
    public let treasuries: Bool

    public init(map: Map) throws {
        cexVolume = (try? map.value("cex_volume.points")) ?? false
        cexVolumeRank30d = (try? map.value("cex_volume.rank_30d")) ?? false
        dexVolume = (try? map.value("dex_volume.points")) ?? false
        dexVolumeRank30d = (try? map.value("dex_volume.rank_30d")) ?? false
        dexLiquidity = (try? map.value("dex_liquidity.points")) ?? false
        dexLiquidityRank = (try? map.value("dex_liquidity.rank")) ?? false
        addresses = (try? map.value("addresses.points")) ?? false
        addressesRank30d = (try? map.value("addresses.rank_30d")) ?? false
        transactions = (try? map.value("transactions.points")) ?? false
        transactionsVolume30d = (try? map.value("transactions.volume_30d")) ?? false
        transactionsRank30d = (try? map.value("transactions.rank_30d")) ?? false
        holders = (try? map.value("holders")) ?? false
        tvl = (try? map.value("tvl.points")) ?? false
        tvlRank = (try? map.value("tvl.rank")) ?? false
        tvlRatio = (try? map.value("tvl.ratio")) ?? false
        revenue = (try? map.value("revenue.value_30d")) ?? false
        revenueRank30d = (try? map.value("revenue.rank_30d")) ?? false
        reports = (try? map.value("reports")) ?? false
        fundsInvested = (try? map.value("funds_invested")) ?? false
        treasuries = (try? map.value("treasuries")) ?? false
    }

}
