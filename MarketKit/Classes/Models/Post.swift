import ObjectMapper

public struct Post: ImmutableMappable {
    public let source: String
    public let title: String
    public let body: String
    public let timestamp: TimeInterval
    public let url: String

    public init(map: Map) throws {
        source = try map.value("source_info.name")
        title = try map.value("title")
        body = try map.value("body")
        timestamp = try map.value("published_on")
        url = try map.value("url")
    }

}
