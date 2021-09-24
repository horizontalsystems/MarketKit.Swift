import ObjectMapper

class CoinResponse: ImmutableMappable {
    let uid: String
    let name: String
    let code: String
    let marketCapRank: Int?
    let coinGeckoId: String

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        code = try map.value("code")
        marketCapRank = try? map.value("market_cap_rank")
        coinGeckoId = try map.value("coingecko_id")
    }

}
