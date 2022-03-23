import ObjectMapper

class HsStatus: ImmutableMappable {
    let platforms: Int
    let coins: Int
    let categories: Int

    required init(map: Map) throws {
        platforms = try map.value("platforms")
        coins = try map.value("coins")
        categories = try map.value("categories")
    }

}
