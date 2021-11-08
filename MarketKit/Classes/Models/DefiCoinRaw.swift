import Foundation
import ObjectMapper

class DefiCoinRaw: ImmutableMappable {
    let uid: String?
    let name: String
    let logo: String
    let tvl: Decimal
    let tvlRank: Int
    let tvlChange1d: Decimal?
    let tvlChange7d: Decimal?
    let tvlChange30d: Decimal?
    let chains: [String]

    required init(map: Map) throws {
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

    func defiCoin(fullCoin: FullCoin?) -> DefiCoin {
        let type: DefiCoin.DefiCoinType

        if let fullCoin = fullCoin {
            type = .fullCoin(fullCoin: fullCoin)
        } else {
            type = .defiCoin(name: name, logo: logo)
        }

        return DefiCoin(
                type: type,
                tvl: tvl,
                tvlRank: tvlRank,
                tvlChange1d: tvlChange1d,
                tvlChange7d: tvlChange7d,
                tvlChange30d: tvlChange30d,
                chains: chains
        )
    }

}
