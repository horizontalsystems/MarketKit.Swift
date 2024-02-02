import Foundation
import ObjectMapper

struct MarketInfoRaw: ImmutableMappable {
    let uid: String
    let price: Decimal?
    let priceChange24h: Decimal?
    let priceChange7d: Decimal?
    let priceChange14d: Decimal?
    let priceChange30d: Decimal?
    let priceChange200d: Decimal?
    let priceChange1y: Decimal?
    let marketCap: Decimal?
    let marketCapRank: Int?
    let totalVolume: Decimal?
    let athPercentage: Decimal?
    let atlPercentage: Decimal?
    let listedOnTopExchanges: Bool?
    let solidCex: Bool?
    let solidDex: Bool?
    let goodDistribution: Bool?

    public init(map: Map) throws {
        uid = try map.value("uid")
        price = try? map.value("price", using: Transform.stringToDecimalTransform)
        priceChange24h = try? map.value("price_change_24h", using: Transform.stringToDecimalTransform)
        priceChange7d = try? map.value("price_change_7d", using: Transform.stringToDecimalTransform)
        priceChange14d = try? map.value("price_change_14d", using: Transform.stringToDecimalTransform)
        priceChange30d = try? map.value("price_change_30d", using: Transform.stringToDecimalTransform)
        priceChange200d = try? map.value("price_change_200d", using: Transform.stringToDecimalTransform)
        priceChange1y = try? map.value("price_change_1y", using: Transform.stringToDecimalTransform)
        marketCap = try? map.value("market_cap", using: Transform.stringToDecimalTransform)
        marketCapRank = try? map.value("market_cap_rank")
        totalVolume = try? map.value("total_volume", using: Transform.stringToDecimalTransform)
        athPercentage = try? map.value("ath_percentage", using: Transform.stringToDecimalTransform)
        atlPercentage = try? map.value("atl_percentage", using: Transform.stringToDecimalTransform)
        listedOnTopExchanges = try? map.value("listed_on_top_exchanges")
        solidCex = try? map.value("solid_cex")
        solidDex = try? map.value("solid_dex")
        goodDistribution = try? map.value("good_distribution")
    }

    func marketInfo(fullCoin: FullCoin) -> MarketInfo {
        MarketInfo(
            fullCoin: fullCoin,
            price: price,
            priceChange24h: priceChange24h,
            priceChange7d: priceChange7d,
            priceChange14d: priceChange14d,
            priceChange30d: priceChange30d,
            priceChange200d: priceChange200d,
            priceChange1y: priceChange1y,
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            totalVolume: totalVolume,
            athPercentage: athPercentage,
            atlPercentage: atlPercentage,
            listedOnTopExchanges: listedOnTopExchanges,
            solidCex: solidCex,
            solidDex: solidDex,
            goodDistribution: goodDistribution
        )
    }
}
