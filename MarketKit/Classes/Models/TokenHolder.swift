import ObjectMapper
import Foundation

public struct TokenHolder: ImmutableMappable {
    public let address: String
    public let share: Decimal

    public init(map: Map) throws {
        address = try map.value("address")
        share = try map.value("share", using: Transform.stringToDecimalTransform)
    }

}
