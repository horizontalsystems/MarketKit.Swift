import ObjectMapper

struct HsStatus: ImmutableMappable {
    let coins: Int
    let blockchains: Int
    let tokens: Int

    init(coins: Int, blockchains: Int, tokens: Int) {
        self.coins = coins
        self.blockchains = blockchains
        self.tokens = tokens
    }

    init(map: Map) throws {
        coins = try map.value("coins")
        blockchains = try map.value("blockchains")
        tokens = try map.value("tokens")
    }

}
