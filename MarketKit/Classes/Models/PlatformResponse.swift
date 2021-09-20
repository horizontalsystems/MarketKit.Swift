import ObjectMapper

class PlatformResponse: ImmutableMappable {
    let type: String
    let decimal: Int?
    let address: String?
    let symbol: String?

    required init(map: Map) throws {
        type = try map.value("type")
        decimal = try? map.value("decimal")
        address = try? map.value("address")
        symbol = try? map.value("symbol")
    }

}
