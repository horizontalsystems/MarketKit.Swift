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

    init(type: String, decimals: Int?, address: String?, symbol: String?) {
        self.type = type
        self.decimals = decimals
        self.address = address
        self.symbol = symbol
    }

    var coinType: CoinType? {
        CoinType(type: type, address: address, symbol: symbol)
    }

    func platform(coinUid: String) -> Platform? {
        guard let decimals = decimals else {
            return nil
        }

        guard let coinType = coinType else {
            return nil
        }

        return Platform(
                coinType: coinType,
                decimals: decimals,
                coinUid: coinUid
        )
    }

    func mapping(map: Map) {
        type     >>> map["type"]
        decimals >>> map["decimals"]
        address  >>> map["address"]
        symbol   >>> map["symbol"]
    }

}
