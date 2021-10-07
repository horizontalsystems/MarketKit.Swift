import Foundation
import ObjectMapper

class CoinGeckoCoinResponse: ImmutableMappable {
    let id: String
    let symbol: String
    let name: String
    let platforms: [String: String]
    let tickers: [MarketTickerRaw]

    private let smartContractRegex = try! NSRegularExpression(pattern: "^0[xX][A-z0-9]+$")
    private let smartContractPlatforms = ["tron", "ethereum", "eos", "binance-smart-chain", "binancecoin"]

    public var exchangeIds: [String] {
        tickers.map { $0.marketId }
    }

    required init(map: Map) throws {
        id = try map.value("id")
        symbol = try map.value("symbol")
        name = try map.value("name")
        platforms = try map.value("platforms")
        tickers = try map.value("tickers")
    }

    private func isSmartContractAddress(symbol: String?) -> Bool {
        guard let symbolUnwrapped = symbol, symbolUnwrapped.count == 42 else {
            return false
        }

        return smartContractRegex.firstMatch(in: symbolUnwrapped, options: [], range: NSRange(location: 0, length: symbolUnwrapped.count)) != nil
    }

    func marketTickers(imageUrls: [String: String]) -> [MarketTicker] {
        let contractAddresses = platforms.compactMap { (platformName, contractAddress) -> String? in
            smartContractPlatforms.contains(platformName) ? contractAddress.lowercased() : nil
        }

        return tickers.compactMap { raw -> MarketTicker? in
            guard raw.lastRate > 0, raw.volume > 0 else {
                return nil
            }

            var base = raw.base
            var target = raw.target
            var volume = raw.volume
            var lastRate = raw.lastRate

            if !contractAddresses.isEmpty {
                if contractAddresses.contains(raw.base.lowercased()) {
                    base = symbol.uppercased()
                } else if contractAddresses.contains(raw.target.lowercased()) {
                    target = symbol.uppercased()
                }
            }

            if isSmartContractAddress(symbol: base) || isSmartContractAddress(symbol: target) {
                return nil
            }

            if base.lowercased() == symbol.lowercased() {
                base = symbol.uppercased()
                target = target.uppercased()
            } else if target.lowercased() == symbol.lowercased() {
                target = base.uppercased()
                base = symbol.uppercased()

                volume = volume * lastRate
                lastRate = 1 / lastRate
            } else {
                return nil
            }

            let imageUrl = imageUrls[raw.marketId]
            return MarketTicker(
                    base: base,
                    target: target,
                    marketName: raw.marketName,
                    marketImageUrl: imageUrl,
                    rate: lastRate,
                    volume: volume
            )
        }
    }

}

extension CoinGeckoCoinResponse {

    struct MarketTickerRaw: ImmutableMappable {
        let base: String
        let target: String
        let marketId: String
        let marketName: String
        let lastRate: Decimal
        let volume: Decimal

        init(map: Map) throws {
            base = try map.value("base")
            target = try map.value("target")
            marketId = try map.value("market.identifier")
            marketName = try map.value("market.name")
            lastRate = try map.value("rate", using: Transform.stringToDecimalTransform)
            volume = try map.value("volume", using: Transform.stringToDecimalTransform)
        }
    }

}
