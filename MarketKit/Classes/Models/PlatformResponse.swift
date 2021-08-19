import ObjectMapper

class PlatformResponse: ImmutableMappable {
    let type: String
    let value: String

    required init(map: Map) throws {
        type = try map.value("type")
        value = try map.value("value")
    }

}
