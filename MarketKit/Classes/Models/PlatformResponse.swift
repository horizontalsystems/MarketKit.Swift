import ObjectMapper

class PlatformResponse: ImmutableMappable {
    let uid: String
    let value: String

    required init(map: Map) throws {
        uid = try map.value("uid")
        value = try map.value("value")
    }

}
