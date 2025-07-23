import Foundation
import ObjectMapper

public struct Vault: ImmutableMappable, Hashable {
    public let address: String
    public let rank: Int?
    public let name: String
    public let apy: [HsTimePeriod: Decimal]
    public let tvl: Decimal
    public let chain: String
    public let assetSymbol: String
    public let protocolName: String
    public let protocolLogo: String
    public let holders: Int?
    public let url: String?
    public let apyChart: [ChartPoint]?

    public init(map: Map) throws {
        address = try map.value("address")
        rank = try? map.value("rank")
        name = try map.value("name")
        apy = try [
            .day1: map.value("apy.1d", using: Transform.stringToDecimalTransform),
            .week1: map.value("apy.7d", using: Transform.stringToDecimalTransform),
            .month1: map.value("apy.30d", using: Transform.stringToDecimalTransform),
        ]
        tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
        chain = try map.value("chain")
        assetSymbol = try map.value("asset_symbol")
        protocolName = try map.value("protocol_name")
        protocolLogo = try map.value("protocol_logo")
        holders = try? map.value("holders")
        url = try? map.value("url")
        apyChart = try? map.value("apy_chart")
    }

    public struct ChartPoint: ImmutableMappable, Hashable {
        public let timestamp: TimeInterval
        public let apy: Decimal

        public init(map: Map) throws {
            timestamp = try map.value("timestamp")
            apy = try map.value("apy", using: Transform.stringToDecimalTransform)
        }
    }
}
