import ObjectMapper

class PlatformResponse: ImmutableMappable {
    let type: String
    let decimals: Int?
    let address: String?
    let symbol: String?

    required init(map: Map) throws {
        type = try map.value("type")
        decimals = try? map.value("decimals")
        address = try? map.value("address")
        symbol = try? map.value("symbol")
    }

    func platform(coinUid: String) -> Platform? {
        guard let decimals = decimals else {
            return nil
        }
        guard let coinType = CoinType(type: type, address: address, symbol: symbol) else {
            return nil
        }

        return Platform(
                coinType: coinType,
                decimals: decimals,
                coinUid: coinUid
        )
    }

}
