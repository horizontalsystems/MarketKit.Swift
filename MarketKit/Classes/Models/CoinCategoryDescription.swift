import ObjectMapper

public class CoinCategoryDescription: ImmutableMappable {
    public let language: String
    public let content: String

    public required init(map: Map) throws {
        language = try map.value("language")
        content = try map.value("content")
    }

    public func mapping(map: Map) {
        language >>> map["language"]
        content >>> map["content"]
    }

}

extension CoinCategoryDescription: CustomStringConvertible {

    public var description: String {
        "CoinCategoryDescription [language: \(language); contentCount: \(content.count)]"
    }

}
