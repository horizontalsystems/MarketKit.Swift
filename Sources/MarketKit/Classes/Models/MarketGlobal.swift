import Foundation
import ObjectMapper

public struct MarketGlobal: ImmutableMappable {
    public let marketCap: Decimal?
    public let marketCapChange: Decimal?
    public let defiMarketCap: Decimal?
    public let defiMarketCapChange: Decimal?
    public let volume: Decimal?
    public let volumeChange: Decimal?
    public let btcDominance: Decimal?
    public let btcDominanceChange: Decimal?
    public let tvl: Decimal?
    public let tvlChange: Decimal?
    public let etfTotalInflow: Decimal?
    public let etfDailyInflow: Decimal?

    public init(map: Map) throws {
        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        marketCapChange = try? map.value("market_cap_change", using: Transform.stringToDecimalTransform)
        defiMarketCap = try? map.value("defi_market_cap", using: Transform.stringToDecimalTransform)
        defiMarketCapChange = try? map.value("defi_market_cap_change", using: Transform.stringToDecimalTransform)
        volume = try? map.value("volume", using: Transform.stringToDecimalTransform)
        volumeChange = try? map.value("volume_change", using: Transform.stringToDecimalTransform)
        btcDominance = try? map.value("btc_dominance", using: Transform.stringToDecimalTransform)
        btcDominanceChange = try? map.value("btc_dominance_change", using: Transform.stringToDecimalTransform)
        tvl = try? map.value("tvl", using: Transform.stringToDecimalTransform)
        tvlChange = try? map.value("tvl_change", using: Transform.stringToDecimalTransform)
        etfTotalInflow = try? map.value("etf_total_inflow", using: Transform.stringToDecimalTransform)
        etfDailyInflow = try? map.value("etf_daily_inflow", using: Transform.stringToDecimalTransform)
    }
}
