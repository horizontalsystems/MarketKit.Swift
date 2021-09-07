import ObjectMapper

class PlatformResponse: ImmutableMappable {
    let type: String
    let decimal: Int
    let reference: String?

    required init(map: Map) throws {
        type = try map.value("type")
        decimal = try map.value("decimal")
        reference = try? map.value("reference")
    }

}
