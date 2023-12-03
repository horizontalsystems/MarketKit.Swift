import Foundation
import ObjectMapper

class DefiCoinRaw: ImmutableMappable {
    let uid: String?
    let name: String
    let logo: String
    let tvl: Decimal
    let tvlRank: Int
    let tvlChange1d: Decimal?
    let tvlChange1w: Decimal?
    let tvlChange2w: Decimal?
    let tvlChange1m: Decimal?
    let tvlChange3m: Decimal?
    let tvlChange6m: Decimal?
    let tvlChange1y: Decimal?
    let chains: [String]
    let chainTvls: [String: Decimal]

    required init(map: Map) throws {
        uid = try? map.value("uid")
        name = try map.value("name")
        logo = try map.value("logo")
        tvl = try map.value("tvl", using: Transform.stringToDecimalTransform)
        tvlRank = try map.value("tvl_rank")
        tvlChange1d = try? map.value("tvl_change_1d", using: Transform.stringToDecimalTransform)
        tvlChange1w = try? map.value("tvl_change_1w", using: Transform.stringToDecimalTransform)
        tvlChange2w = try? map.value("tvl_change_2w", using: Transform.stringToDecimalTransform)
        tvlChange1m = try? map.value("tvl_change_1m", using: Transform.stringToDecimalTransform)
        tvlChange3m = try? map.value("tvl_change_3m", using: Transform.stringToDecimalTransform)
        tvlChange6m = try? map.value("tvl_change_6m", using: Transform.stringToDecimalTransform)
        tvlChange1y = try? map.value("tvl_change_1y", using: Transform.stringToDecimalTransform)
        chains = try map.value("chains")
        chainTvls = (try? map.value("chain_tvls", using: Transform.stringToDecimalTransform)) ?? [:]
    }

    func defiCoin(fullCoin: FullCoin?) -> DefiCoin {
        let type: DefiCoin.DefiCoinType

        if let fullCoin {
            type = .fullCoin(fullCoin: fullCoin)
        } else {
            type = .defiCoin(name: name, logo: logo)
        }

        return DefiCoin(
            type: type,
            tvl: tvl,
            tvlRank: tvlRank,
            tvlChange1d: tvlChange1d,
            tvlChange1w: tvlChange1w,
            tvlChange2w: tvlChange2w,
            tvlChange1m: tvlChange1m,
            tvlChange3m: tvlChange3m,
            tvlChange6m: tvlChange6m,
            tvlChange1y: tvlChange1y,
            chains: chains,
            chainTvls: chainTvls
        )
    }
}
