import ObjectMapper

struct TopPlatformResponse: ImmutableMappable {
    let name: String
    let marketCap: Decimal?
    let rank: Int?
    let stats: TopPlatformStatsResponse

    init(map: Map) throws {
        name = try map.value("name")
        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        rank = try? map.value("rank")
        stats = try map.value("stats")
    }

}

extension TopPlatformResponse {

    struct TopPlatformStatsResponse: ImmutableMappable {
        let oneDayRank: Int?
        let sevenDaysRank: Int?
        let thirtyDaysRank: Int?
        let oneDayChange: Decimal?
        let sevenDayChange: Decimal?
        let thirtyDayChange: Decimal?
        let protocolsCount: Int?

        init(map: Map) throws {
            oneDayRank = try? map.value("rank_1d", using: Transform.stringToIntTransform)
            sevenDaysRank = try? map.value("rank_1w", using: Transform.stringToIntTransform)
            thirtyDaysRank = try? map.value("rank_1m", using: Transform.stringToIntTransform)

            oneDayChange = try? map.value("change_1d", using: Transform.stringToDecimalTransform)
            sevenDayChange = try? map.value("change_1w", using: Transform.stringToDecimalTransform)
            thirtyDayChange = try? map.value("change_1m", using: Transform.stringToDecimalTransform)

            protocolsCount = try? map.value("protocols", using: Transform.stringToIntTransform)
        }
    }

}
