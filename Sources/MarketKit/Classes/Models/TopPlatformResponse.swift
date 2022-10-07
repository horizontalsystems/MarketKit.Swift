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
        ranks[.day1] = stats.oneDayRank
        ranks[.week1] = stats.sevenDaysRank
        ranks[.month1] = stats.thirtyDaysRank

        var changes = [HsTimePeriod: Decimal]()
        changes[.day1] = stats.oneDayChange
        changes[.week1] = stats.sevenDaysChange
        changes[.month1] = stats.thirtyDaysChange

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
        let oneDayRank: Int?
        let sevenDaysRank: Int?
        let thirtyDaysRank: Int?
        let oneDayChange: Decimal?
        let sevenDaysChange: Decimal?
        let thirtyDaysChange: Decimal?

        init(map: Map) throws {
            oneDayRank = try? map.value("rank_1d", using: Transform.stringToIntTransform)
            sevenDaysRank = try? map.value("rank_1w", using: Transform.stringToIntTransform)
            thirtyDaysRank = try? map.value("rank_1m", using: Transform.stringToIntTransform)

            oneDayChange = try? map.value("change_1d", using: Transform.stringToDecimalTransform)
            sevenDaysChange = try? map.value("change_1w", using: Transform.stringToDecimalTransform)
            thirtyDaysChange = try? map.value("change_1m", using: Transform.stringToDecimalTransform)

        }
    }

}
