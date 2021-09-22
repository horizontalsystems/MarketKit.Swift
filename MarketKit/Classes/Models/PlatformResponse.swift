import ObjectMapper

class PlatformResponse: ImmutableMappable {
    let type: String
    let decimals: Int?
    let address: String?
    let symbol: String?

    required init(map: Map) throws {
        type = try map.value("type")
        decimals = try? map.value("decimals")
        address = try? map.value("address")
        symbol = try? map.value("symbol")
    }

}
