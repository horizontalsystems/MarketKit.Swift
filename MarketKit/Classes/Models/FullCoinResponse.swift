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

    init(uid: String, name: String, code: String, marketCapRank: Int?, coinGeckoId: String?, platforms: [PlatformResponse]) {
        self.uid = uid
        self.name = name
        self.code = code
        self.marketCapRank = marketCapRank
        self.coinGeckoId = coinGeckoId
        self.platforms = platforms
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

    func mapping(map: Map) {
        uid           >>> map["uid"]
        name          >>> map["name"]
        code          >>> map["code"]
        marketCapRank >>> map["marketCapRank"]
        coinGeckoId   >>> map["coinGeckoId"]
        platforms     >>> map["platforms"]
    }

}
