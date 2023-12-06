import Foundation
import ObjectMapper

struct TopPlatformResponse: ImmutableMappable {
    let uid: String
    let name: String
    let rank: Int?
    let protocolsCount: Int?
    let marketCap: Decimal?
    let stats: StatsResponse

    init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        rank = try? map.value("rank")
        protocolsCount = try? map.value("protocols")
        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        stats = try map.value("stats")
    }

    var topPlatform: TopPlatform {
        var ranks = [HsTimePeriod: Int]()
        ranks[.week1] = stats.rank1w
        ranks[.month1] = stats.rank1m
        ranks[.month3] = stats.rank3m

        var changes = [HsTimePeriod: Decimal]()
        changes[.week1] = stats.change1w
        changes[.month1] = stats.change1m
        changes[.month3] = stats.change3m

        return TopPlatform(
            blockchain: Blockchain(type: BlockchainType(uid: uid), name: name, explorerUrl: nil),
            rank: rank,
            protocolsCount: protocolsCount,
            marketCap: marketCap,
            ranks: ranks,
            changes: changes
        )
    }
}

extension TopPlatformResponse {
    struct StatsResponse: ImmutableMappable {
        let rank1w: Int?
        let rank1m: Int?
        let rank3m: Int?
        let change1w: Decimal?
        let change1m: Decimal?
        let change3m: Decimal?

        init(map: Map) throws {
            rank1w = try? map.value("rank_1w", using: Transform.stringToIntTransform)
            rank1m = try? map.value("rank_1m", using: Transform.stringToIntTransform)
            rank3m = try? map.value("rank_3m", using: Transform.stringToIntTransform)

            change1w = try? map.value("change_1w", using: Transform.stringToDecimalTransform)
            change1m = try? map.value("change_1m", using: Transform.stringToDecimalTransform)
            change3m = try? map.value("change_3m", using: Transform.stringToDecimalTransform)
        }
    }
}
