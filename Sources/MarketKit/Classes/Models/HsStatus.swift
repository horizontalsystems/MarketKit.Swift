import ObjectMapper

struct HsStatus: ImmutableMappable {
    let coins: Int
    let blockchains: Int
    let tokens: Int
    let exchanges: Int

    init(map: Map) throws {
        coins = try map.value("coins")
        blockchains = try map.value("blockchains")
        tokens = try map.value("tokens")
        exchanges = try map.value("exchanges")
    }
}
