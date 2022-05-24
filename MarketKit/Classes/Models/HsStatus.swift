import ObjectMapper

class HsStatus: ImmutableMappable {
    let platforms: Int
    let coins: Int

    required init(map: Map) throws {
        platforms = try map.value("platforms")
        coins = try map.value("coins")
    }

}
