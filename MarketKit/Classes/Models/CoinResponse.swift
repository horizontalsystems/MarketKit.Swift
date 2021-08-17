import ObjectMapper

class CoinResponse: ImmutableMappable {
    let uid: String
    let name: String
    let code: String
    let decimal: Int
    let platforms: [PlatformResponse]

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        code = try map.value("code")
        decimal = try map.value("decimal")
        platforms = try map.value("platforms")
    }

}
