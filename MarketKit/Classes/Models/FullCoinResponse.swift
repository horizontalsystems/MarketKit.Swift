import ObjectMapper

class FullCoinResponse: ImmutableMappable {
    let uid: String
    let name: String
    let code: String
    let platforms: [PlatformResponse]
    let marketCapRank: Int?
    let coinGeckoId: String

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        code = try map.value("code")
        platforms = try map.value("platforms")
        marketCapRank = try? map.value("market_cap_rank")
        coinGeckoId = try map.value("coingecko_id")
    }

}
