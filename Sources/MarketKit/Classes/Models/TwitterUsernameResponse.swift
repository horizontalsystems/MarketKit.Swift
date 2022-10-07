import Foundation
import ObjectMapper

public class TwitterUsernameResponse: ImmutableMappable {
    public let username: String?

    required public init(map: Map) throws {
        username = try map.value("twitter")
    }

}
