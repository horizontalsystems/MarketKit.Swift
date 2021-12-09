import Foundation
import ObjectMapper
import HsToolKit

struct CoinPriceResponse: ImmutableMappable {
    let uid: String
    let price: Decimal
    let priceChange: Decimal
    let lastUpdated: TimeInterval

    init(uid: String, price: Decimal, priceChange: Decimal, lastUpdated: TimeInterval) {
        self.uid = uid
        self.price = price
        self.priceChange = priceChange
        self.lastUpdated = lastUpdated
    }

    init(map: Map) throws {
        uid = try map.value("uid")
        price = try map.value("price", using: Transform.stringToDecimalTransform)
        priceChange = try map.value("price_change_24h", using: Transform.stringToDecimalTransform)
        lastUpdated = try map.value("last_updated")
    }

    func coinPrice(currencyCode: String) -> CoinPrice {
        CoinPrice(
            coinUid: uid,
            currencyCode: currencyCode,
            value: price,
            diff: priceChange,
            timestamp: lastUpdated
        )
    }

}

class CoinPriceMapper: IApiMapper {
    typealias T = [CoinPriceResponse]

    func map(statusCode: Int, data: Any?) throws -> T {
        guard let data = data as? [Any] else {
            return []
        }
        return data.compactMap { coin -> CoinPriceResponse? in
            guard let coin = coin as? [String: Any],
                  let uid = coin["uid"] as? String,
                  let priceString = coin["price"] as? String,
                  let price = Decimal(string: priceString),
                  let timestampInt = coin["last_updated"] as? Int,
                  let priceChangeString = coin["price_change_24h"] as? String,
                  let priceChange = Decimal(string: priceChangeString) else {
                print("FOUND FAILED: \(coin)")
                return nil
            }

            return CoinPriceResponse(uid: uid, price: price, priceChange: priceChange, lastUpdated: TimeInterval(timestampInt))
        }
    }

}
