import ObjectMapper

class FullCoinResponse: CoinResponse {
    let platforms: [PlatformResponse]

    required init(map: Map) throws {
        platforms = try map.value("platforms")

        try super.init(map: map)
    }

    func fullCoin() -> FullCoin {
        FullCoin(coin: coin(), platforms: platforms.compactMap { $0.platform(coinUid: uid) })
    }
}
