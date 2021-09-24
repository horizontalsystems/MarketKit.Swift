import ObjectMapper

class FullCoinResponse: CoinResponse {
    let platforms: [PlatformResponse]

    required init(map: Map) throws {
        platforms = try map.value("platforms")

        try super.init(map: map)
    }

}
