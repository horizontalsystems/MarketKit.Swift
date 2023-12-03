import Foundation
import ObjectMapper

public class TwitterUsernameResponse: ImmutableMappable {
    public let username: String?

    public required init(map: Map) throws {
        username = try map.value("twitter")
    }
}
