import Foundation
import HsToolKit
import ObjectMapper

struct CoinPriceResponse: ImmutableMappable {
    let uid: String
    let price: Decimal
    let priceChange24h: Decimal?
    let priceChange1d: Decimal?
    let lastUpdated: TimeInterval

    init(uid: String, price: Decimal, priceChange: Decimal?, priceChange24h: Decimal?, priceChange1d: Decimal?, lastUpdated: TimeInterval) {
        self.uid = uid
        self.price = price
        self.priceChange24h = priceChange24h
        self.priceChange1d = priceChange1d
        self.lastUpdated = lastUpdated
    }

    init(map: Map) throws {
        uid = try map.value("uid")
        price = try map.value("price", using: Transform.stringToDecimalTransform)
        priceChange24h = try? map.value("price_change_24h", using: Transform.stringToDecimalTransform)
        priceChange1d = try? map.value("price_change_1d", using: Transform.stringToDecimalTransform)
        lastUpdated = try map.value("last_updated")
    }

    func coinPrice(currencyCode: String) -> CoinPrice {
        CoinPrice(
            coinUid: uid,
            currencyCode: currencyCode,
            value: price,
            diff24h: priceChange24h,
            diff1d: priceChange1d,
            timestamp: lastUpdated
        )
    }
}
