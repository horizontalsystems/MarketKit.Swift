import ObjectMapper

class FullCoinResponse: ImmutableMappable {
    let uid: String
    let name: String
    let code: String
    let marketCapRank: Int?
    let coinGeckoId: String?
    let platforms: [PlatformResponse]

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        code = try map.value("code")
        marketCapRank = try? map.value("market_cap_rank")
        coinGeckoId = try? map.value("coingecko_id")
        platforms = try map.value("platforms")
    }

    func fullCoin() -> FullCoin {
        let coin = Coin(
                uid: uid,
                name: name,
                code: code.uppercased(),
                marketCapRank: marketCapRank,
                coinGeckoId: coinGeckoId
        )

        return FullCoin(coin: coin, platforms: platforms.compactMap { $0.platform(coinUid: uid) })
    }

}
