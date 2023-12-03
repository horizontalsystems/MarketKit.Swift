import Foundation
import ObjectMapper

public struct TokenHolders: ImmutableMappable {
    public let count: Decimal
    public let holdersUrl: String?
    public let topHolders: [Holder]

    public init(map: Map) throws {
        count = try map.value("count", using: Transform.stringToDecimalTransform)
        holdersUrl = try? map.value("holders_url")
        topHolders = try map.value("top_holders")
    }

    public struct Holder: ImmutableMappable {
        public let address: String
        public let percentage: Decimal
        public let balance: Decimal

        public init(map: Map) throws {
            address = try map.value("address")
            percentage = try map.value("percentage", using: Transform.stringToDecimalTransform)
            balance = try map.value("balance", using: Transform.stringToDecimalTransform)
        }
    }
}
