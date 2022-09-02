import Foundation
import RxSwift

class NftManager {
    private let coinManager: CoinManager
    private let provider: HsNftProvider

    init(coinManager: CoinManager, provider: HsNftProvider) {
        self.coinManager = coinManager
        self.provider = provider
    }

    private func nftPrice(token: Token?, value: Decimal?) -> NftPrice? {
        guard let token = token, let value = value else {
            return nil
        }

        return NftPrice(token: token, value: value)
    }

    private func statCharts(blockchainType: BlockchainType, responses: [CollectionStatChartPointResponse]) -> NftCollectionStatCharts? {
        guard !responses.isEmpty else {
            return nil
        }

        let baseToken = try? coinManager.token(query: TokenQuery(blockchainType: blockchainType, tokenType: .native))

        let oneDayVolumePoints = responses.compactMap { point in
            point.oneDayVolume.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, token: baseToken) }
        }
        let averagePricePoints = responses.compactMap { point in
            point.averagePrice.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, token: baseToken) }
        }
        let floorPricePoints = responses.compactMap { point in
            point.floorPrice.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, token: baseToken) }
        }
        let oneDaySalesPoints = responses.compactMap { point in
            point.oneDaySales.map { NftCollectionStatCharts.Point(timestamp: point.timestamp, value: $0) }
        }

        return NftCollectionStatCharts(
                oneDayVolumePoints: oneDayVolumePoints,
                averagePricePoints: averagePricePoints,
                floorPricePoints: floorPricePoints,
                oneDaySalesPoints: oneDaySalesPoints
        )
    }

    private func baseTokenMap(blockchainTypes: [BlockchainType]) -> [BlockchainType: Token] {
        do {
            var map = [BlockchainType: Token]()
            let tokens = try coinManager.tokens(queries: blockchainTypes.map { TokenQuery(blockchainType: $0, tokenType: .native) })

            for token in tokens {
                map[token.blockchainType] = token
            }

            return map
        } catch {
            return [:]
        }
    }

    private func collection(response: NftTopCollectionResponse, baseTokenMap: [BlockchainType: Token]) -> NftTopCollection {
        let blockchainType = BlockchainType(uid: response.blockchainUid)
        let baseToken = baseTokenMap[blockchainType]

        let volumes: [HsTimePeriod: NftPrice?] = [
            .day1: nftPrice(token: baseToken, value: response.volume1d),
            .week1: nftPrice(token: baseToken, value: response.volume7d),
            .month1: nftPrice(token: baseToken, value: response.volume30d)
        ]

        let changes: [HsTimePeriod: Decimal?] = [
            .day1: response.change1d,
            .week1: response.change7d,
            .month1: response.change30d
        ]

        return NftTopCollection(
                blockchainType: blockchainType,
                providerUid: response.providerUid,
                name: response.name,
                thumbnailImageUrl: response.thumbnailImageUrl,
                floorPrice: nftPrice(token: baseToken, value: response.floorPrice),
                volumes: volumes.compactMapValues { $0 },
                changes: changes.compactMapValues { $0 }
        )
    }

}

extension NftManager {

    func collectionStatChartsSingle(blockchainType: BlockchainType, providerUid: String) -> Single<NftCollectionStatCharts?> {
        provider.collectionStatChartPointsSingle(providerUid: providerUid)
                .map { [weak self] responses in
                    guard let strongSelf = self else {
                        throw Kit.KitError.weakReference
                    }

                    return strongSelf.statCharts(blockchainType: blockchainType, responses: responses)
                }
    }

    func topCollections(responses: [NftTopCollectionResponse]) -> [NftTopCollection] {
        let blockchainUids = Array(Set(responses.map { $0.blockchainUid }))
        let blockchainTypes = blockchainUids.map { BlockchainType(uid: $0) }
        let baseTokenMap = baseTokenMap(blockchainTypes: blockchainTypes)

        return responses.map { response in
            collection(response: response, baseTokenMap: baseTokenMap)
        }
    }

    func topCollectionsSingle() -> Single<[NftTopCollection]> {
        provider.topCollectionsSingle()
                .map { [weak self] responses in
                    guard let strongSelf = self else {
                        throw Kit.KitError.weakReference
                    }

                    return strongSelf.topCollections(responses: responses)
                }
    }

}
