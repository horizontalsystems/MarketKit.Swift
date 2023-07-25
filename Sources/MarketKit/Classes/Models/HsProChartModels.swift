import Foundation
import ObjectMapper

public struct Analytics: ImmutableMappable {
    public let cexVolume: ExVolume?
    public let dexVolume: ExVolume?
    public let dexLiquidity: DexLiquidity?
    public let addresses: Addresses?
    public let transactions: Transactions?
    public let holders: [HolderBlockchain]?
    public let holdersRank: Int?
    public let holdersRating: String?
    public let tvl: Tvl?
    public let fee: ValueRank?
    public let revenue: ValueRank?
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
        holdersRank = try? map.value("holders_rank")
        holdersRating = try? map.value("holders_rating")
        tvl = try? map.value("tvl")
        fee = try? map.value("fee")
        revenue = try? map.value("revenue")
        reports = try? map.value("reports")
        fundsInvested = try? map.value("funds_invested", using: Transform.stringToDecimalTransform)
        treasuries = try? map.value("treasuries", using: Transform.stringToDecimalTransform)
    }

    public struct ExVolume: ImmutableMappable {
        public let points: [VolumePoint]
        public let rank30d: Int?
        public let rating: String?

        public init(map: Map) throws {
            points = try map.value("points")
            rank30d = try? map.value("rank_30d")
            rating = try? map.value("rating")
        }

        public var aggregatedChartPoints: AggregatedChartPoints {
            AggregatedChartPoints(
                    points: points.map { $0.chartPoint },
                    aggregatedValue: points.map { $0.volume }.reduce(0, +)
            )
        }
    }

    public struct DexLiquidity: ImmutableMappable {
        public let points: [VolumePoint]
        public let rank: Int?
        public let rating: String?

        public init(map: Map) throws {
            points = try map.value("points")
            rank = try? map.value("rank")
            rating = try? map.value("rating")
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct Addresses: ImmutableMappable {
        public let points: [CountPoint]
        public let rank30d: Int?
        public let count30d: Int?
        public let rating: String?

        public init(map: Map) throws {
            points = try map.value("points")
            rank30d = try? map.value("rank_30d")
            count30d = try? map.value("count_30d")
            rating = try? map.value("rating")
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct Transactions: ImmutableMappable {
        public let points: [CountPoint]
        public let rank30d: Int?
        public let volume30d: Decimal?
        public let rating: String?

        public init(map: Map) throws {
            points = try map.value("points")
            rank30d = try? map.value("rank_30d")
            volume30d = try? map.value("volume_30d", using: Transform.stringToDecimalTransform)
            rating = try? map.value("rating")
        }

        public var aggregatedChartPoints: AggregatedChartPoints {
            AggregatedChartPoints(
                    points: points.map { $0.chartPoint },
                    aggregatedValue: points.map { $0.count }.reduce(0, +)
            )
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
        public let rating: String?

        public init(map: Map) throws {
            points = try map.value("points")
            rank = try? map.value("rank")
            ratio = try? map.value("ratio", using: Transform.stringToDecimalTransform)
            rating = try? map.value("rating")
        }

        public var chartPoints: [ChartPoint] {
            points.map { $0.chartPoint }
        }
    }

    public struct ValueRank: ImmutableMappable {
        public let value30d: Decimal?
        public let rank30d: Int?
        public let description: String?

        public init(map: Map) throws {
            value30d = try? map.value("value_30d", using: Transform.stringToDecimalTransform)
            rank30d = try? map.value("rank_30d")
            description = try? map.value("description")
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
    public let cexVolumeRating: Bool
    public let dexVolume: Bool
    public let dexVolumeRank30d: Bool
    public let dexVolumeRating: Bool
    public let dexLiquidity: Bool
    public let dexLiquidityRank: Bool
    public let dexLiquidityRating: Bool
    public let addresses: Bool
    public let addressesCount30d: Bool
    public let addressesRank30d: Bool
    public let addressesRating: Bool
    public let transactions: Bool
    public let transactionsVolume30d: Bool
    public let transactionsRank30d: Bool
    public let transactionsRating: Bool
    public let holders: Bool
    public let holdersRank: Bool
    public let holdersRating: Bool
    public let tvl: Bool
    public let tvlRank: Bool
    public let tvlRatio: Bool
    public let tvlRating: Bool
    public let fee: Bool
    public let feeRank30d: Bool
    public let revenue: Bool
    public let revenueRank30d: Bool
    public let reports: Bool
    public let fundsInvested: Bool
    public let treasuries: Bool

    public init(map: Map) throws {
        cexVolume = (try? map.value("cex_volume.points")) ?? false
        cexVolumeRank30d = (try? map.value("cex_volume.rank_30d")) ?? false
        cexVolumeRating = (try? map.value("cex_volume.rating")) ?? false
        dexVolume = (try? map.value("dex_volume.points")) ?? false
        dexVolumeRank30d = (try? map.value("dex_volume.rank_30d")) ?? false
        dexVolumeRating = (try? map.value("dex_volume.rating")) ?? false
        dexLiquidity = (try? map.value("dex_liquidity.points")) ?? false
        dexLiquidityRank = (try? map.value("dex_liquidity.rank")) ?? false
        dexLiquidityRating = (try? map.value("dex_liquidity.rating")) ?? false
        addresses = (try? map.value("addresses.points")) ?? false
        addressesRank30d = (try? map.value("addresses.rank_30d")) ?? false
        addressesCount30d = (try? map.value("addresses.count_30d")) ?? false
        addressesRating = (try? map.value("addresses.rating")) ?? false
        transactions = (try? map.value("transactions.points")) ?? false
        transactionsVolume30d = (try? map.value("transactions.volume_30d")) ?? false
        transactionsRank30d = (try? map.value("transactions.rank_30d")) ?? false
        transactionsRating = (try? map.value("transactions.rating")) ?? false
        holders = (try? map.value("holders")) ?? false
        holdersRank = (try? map.value("holders_rank")) ?? false
        holdersRating = (try? map.value("holders_rating")) ?? false
        tvl = (try? map.value("tvl.points")) ?? false
        tvlRank = (try? map.value("tvl.rank")) ?? false
        tvlRatio = (try? map.value("tvl.ratio")) ?? false
        tvlRating = (try? map.value("tvl.rating")) ?? false
        fee = (try? map.value("fee.value_30d")) ?? false
        feeRank30d = (try? map.value("fee.rank_30d")) ?? false
        revenue = (try? map.value("revenue.value_30d")) ?? false
        revenueRank30d = (try? map.value("revenue.rank_30d")) ?? false
        reports = (try? map.value("reports")) ?? false
        fundsInvested = (try? map.value("funds_invested")) ?? false
        treasuries = (try? map.value("treasuries")) ?? false
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

public struct CountVolumePoint: ImmutableMappable {
    public let timestamp: TimeInterval
    public let count: Decimal
    public let volume: Decimal

    public init(map: Map) throws {
        timestamp = try map.value("timestamp")
        count = try map.value("count", using: Transform.stringToDecimalTransform)
        volume = try map.value("volume", using: Transform.stringToDecimalTransform)
    }

    public var chartPoint: ChartPoint {
        ChartPoint(timestamp: timestamp, value: count, volume: volume)
    }
}

public struct RankMultiValue: ImmutableMappable {
    public let uid: String
    public let value1d: Decimal?
    public let value7d: Decimal?
    public let value30d: Decimal?

    public init(map: Map) throws {
        uid = try map.value("uid")
        value1d = try? map.value("value_1d", using: Transform.stringToDecimalTransform)
        value7d = try? map.value("value_7d", using: Transform.stringToDecimalTransform)
        value30d = try? map.value("value_30d", using: Transform.stringToDecimalTransform)
    }

}

public struct RankValue: ImmutableMappable {
    public let uid: String
    public let value: Decimal?

    public init(map: Map) throws {
        uid = try map.value("uid")
        value = try? map.value("value", using: Transform.stringToDecimalTransform)
    }

}

public struct ProSubscription: ImmutableMappable {
    public let address: String
    public let deadline: TimeInterval

    public init(map: Map) throws {
        address = try map.value("address")
        deadline = try map.value("deadline")
    }
}
