import Foundation
import ObjectMapper

public class DefiCoin: ImmutableMappable {
    public let uid: String?
    public let name: String
    public let logo: String
    public let tvl: Decimal
    public let tvlRank: Int
    public let tvlChange1d: Decimal?
    public let tvlChange7d: Decimal?
    public let tvlChange30d: Decimal?
    public let chains: [String]

    required public init(map: Map) throws {
        uid = try? map.value("uid")
        name = try map.value("name")
        logo = try map.value("logo")
        tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
        tvlRank = try map.value("tvl_rank")
        tvlChange1d = try? map.value("tvl_change_1d", using: Transform.stringToDecimalTransform)
        tvlChange7d = try? map.value("tvl_change_7d", using: Transform.stringToDecimalTransform)
        tvlChange30d = try? map.value("tvl_change_30d", using: Transform.stringToDecimalTransform)
        chains = try map.value("chains")
    }

}
