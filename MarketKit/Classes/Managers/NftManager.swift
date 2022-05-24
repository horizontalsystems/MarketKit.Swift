import Foundation
import RxSwift

class NftManager {
    private let zeroAddress = "0x0000000000000000000000000000000000000000"

    private let coinManager: CoinManager
    private let provider: HsNftProvider

    init(coinManager: CoinManager, provider: HsNftProvider) {
        self.coinManager = coinManager
        self.provider = provider
    }

    private func coinType(address: String) -> CoinType {
        if address == zeroAddress {
            return .ethereum
        } else {
            return .erc20(address: address)
        }
    }

    private func platformCoinMap(addresses: [String]) -> [String: PlatformCoin] {
        do {
            var map = [String: PlatformCoin]()
            let coinTypes = addresses.map { coinType(address: $0) }
            let platformCoins = try coinManager.platformCoins(coinTypes: coinTypes)

            for platformCoin in platformCoins {
                switch platformCoin.coinType {
                case .ethereum:
                    map[zeroAddress] = platformCoin
                case .erc20(let address):
                    map[address.lowercased()] = platformCoin
                default:
                    ()
                }
            }

            return map
        } catch {
            return [:]
        }
    }

    private func nftPrice(platformCoin: PlatformCoin?, value: Decimal?, shift: Bool) -> NftPrice? {
        guard let platformCoin = platformCoin, let value = value else {
            return nil
        }

        return NftPrice(
                platformCoin: platformCoin,
                value: shift ? Decimal(sign: .plus, exponent: -platformCoin.decimals, significand: value) : value
        )
    }

    private func createNftPrices(values: [HsTimePeriod: Decimal], ethereumPlatformCoin: PlatformCoin?) -> [HsTimePeriod: NftPrice] {
        Dictionary<HsTimePeriod, NftPrice>(uniqueKeysWithValues: values.compactMap { key, value in
            guard let nftPrice = nftPrice(platformCoin: ethereumPlatformCoin, value: value, shift: false) else {
                return nil
            }

            return (key, nftPrice)
        })
    }

    private func collection(response: NftCollectionResponse, ethereumPlatformCoin: PlatformCoin? = nil) -> NftCollection {
        let ethereumPlatformCoin = ethereumPlatformCoin ?? (try? coinManager.platformCoin(coinType: .ethereum))

        return NftCollection(
                contracts: response.contracts.map { NftCollection.Contract(address: $0.address, schemaName: $0.type) },
                uid: response.uid,
                name: response.name,
                description: response.description,
                imageUrl: response.imageUrl,
                featuredImageUrl: response.featuredImageUrl,
                externalUrl: response.externalUrl,
                discordUrl: response.discordUrl,
                twitterUsername: response.twitterUsername,
                stats: collectionStats(response: response.stats, ethereumPlatformCoin: ethereumPlatformCoin),
                statCharts: statCharts(statChartPoints: response.statChartPoints, ethereumPlatformCoin: ethereumPlatformCoin)
        )
    }

    private func collectionStats(response: NftCollectionStatsResponse, ethereumPlatformCoin: PlatformCoin?) -> NftCollectionStats {
        NftCollectionStats(
                count: response.count,
                ownerCount: response.ownerCount,
                totalSupply: response.totalSupply,
                averagePrice7d: nftPrice(platformCoin: ethereumPlatformCoin, value: response.averagePrice7d, shift: false),
                averagePrice30d: nftPrice(platformCoin: ethereumPlatformCoin, value: response.averagePrice30d, shift: false),
                floorPrice: nftPrice(platformCoin: ethereumPlatformCoin, value: response.floorPrice, shift: false),
                totalVolume: response.totalVolume,
                marketCap: nftPrice(platformCoin: ethereumPlatformCoin, value: response.marketCap, shift: false),
                volumes: createNftPrices(values: [
                    .day1: response.oneDayVolume,
                    .week1: response.sevenDayVolume,
                    .month1: response.thirtyDayVolume
                ], ethereumPlatformCoin: ethereumPlatformCoin),
                changes: [
                    .day1: response.oneDayChange,
                    .week1: response.sevenDayChange,
                    .month1: response.thirtyDayChange
                ]
        )
    }

    private func statCharts(statChartPoints: [CollectionStatChartPointResponse]?, ethereumPlatformCoin: PlatformCoin?) -> NftCollectionStatCharts? {
        guard let statChartPoints = statChartPoints else {
            return nil
        }

        let oneDayVolumePoints = statChartPoints.compactMap { point in point.oneDayVolume.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, coin: ethereumPlatformCoin) } }
        let averagePricePoints = statChartPoints.compactMap { point in point.averagePrice.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, coin: ethereumPlatformCoin) } }
        let floorPricePoints = statChartPoints.compactMap { point in point.floorPrice.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, coin: ethereumPlatformCoin) } }
        let oneDaySalesPoints = statChartPoints.compactMap { point in point.oneDaySales.map { NftCollectionStatCharts.Point(timestamp: point.timestamp, value: $0) } }

        if oneDayVolumePoints.isEmpty && averagePricePoints.isEmpty && floorPricePoints.isEmpty && oneDayVolumePoints.isEmpty {
            return nil
        }

        return NftCollectionStatCharts(
                oneDayVolumePoints: oneDayVolumePoints,
                averagePricePoints: averagePricePoints,
                floorPricePoints: floorPricePoints,
                oneDaySalesPoints: oneDaySalesPoints
        )
    }

    private func assets(responses: [NftAssetResponse]) -> [NftAsset] {
        var addresses = [String]()

        for response in responses {
            if let lastSale = response.lastSale {
                addresses.append(lastSale.paymentTokenAddress)
            }
        }

        let platformCoinMap = platformCoinMap(addresses: addresses)

        return responses.map { response in
            asset(response: response, platformCoinMap: platformCoinMap)
        }
    }

    private func asset(response: NftAssetResponse, platformCoinMap: [String: PlatformCoin]? = nil) -> NftAsset {
        let map: [String: PlatformCoin]

        if let platformCoinMap = platformCoinMap {
            map = platformCoinMap
        } else {
            var addresses = [String]()

            if let lastSale = response.lastSale {
                addresses.append(lastSale.paymentTokenAddress)
            }
            for order in response.orders {
                addresses.append(order.paymentToken.address)
            }

            map = self.platformCoinMap(addresses: addresses)
        }

        return NftAsset(
                contract: NftCollection.Contract(address: response.contract.address, schemaName: response.contract.type),
                collectionUid: response.collectionUid,
                tokenId: response.tokenId,
                name: response.name,
                imageUrl: response.imageUrl,
                imagePreviewUrl: response.imagePreviewUrl,
                description: response.description,
                externalLink: response.externalLink,
                permalink: response.permalink,
                traits: response.traits.map { NftAsset.Trait(type: $0.type, value: $0.value, count: $0.count) },
                lastSalePrice: response.lastSale.flatMap { nftPrice(platformCoin: map[$0.paymentTokenAddress], value: $0.totalPrice, shift: true) },
                onSale: !response.sellOrders.isEmpty,
                orders: assetOrders(responses: response.orders, platformCoinMap: map)
        )
    }

    private func assetOrders(responses: [NftOrderResponse], platformCoinMap: [String: PlatformCoin]) -> [NftAssetOrder] {
        responses.map { response in
            NftAssetOrder(
                    closingDate: response.closingDate,
                    price: platformCoinMap[response.paymentToken.address].flatMap { nftPrice(platformCoin: $0, value: response.currentPrice, shift: true) },
                    emptyTaker: response.takerAddress == zeroAddress,
                    side: response.side,
                    v: response.v,
                    ethValue: Decimal(sign: .plus, exponent: -response.paymentToken.decimals, significand: response.currentPrice) * response.paymentToken.ethPrice
            )
        }
    }

    private func events(responses: [NftEventResponse]) -> [NftEvent] {
        var addresses = [String]()

        for response in responses {
            if let paymentToken = response.paymentToken {
                addresses.append(paymentToken.address)
            }
        }

        let platformCoinMap = platformCoinMap(addresses: addresses)

        return responses.compactMap { response in
            var amount: NftPrice?

            if let paymentToken = response.paymentToken, let value = response.amount {
                amount = nftPrice(platformCoin: platformCoinMap[paymentToken.address], value: value, shift: true)
            }

            return NftEvent(
                    asset: asset(response: response.asset),
                    type: NftEvent.EventType(rawValue: response.type),
                    date: response.date,
                    amount: amount
            )
        }
    }

}

extension NftManager {

    func collections(responses: [NftCollectionResponse]) -> [NftCollection] {
        let ethereumPlatformCoin = try? coinManager.platformCoin(coinType: .ethereum)

        return responses.map { response in
            collection(response: response, ethereumPlatformCoin: ethereumPlatformCoin)
        }
    }

    func assetCollectionSingle(address: String) -> Single<NftAssetCollection> {
        let collectionsSingle = provider.recursiveCollectionsSingle(address: address).map { [weak self] responses in
            self?.collections(responses: responses) ?? []
        }

        let assetsSingle = provider.recursiveAssetsSingle(address: address).map { [weak self] responses in
            self?.assets(responses: responses) ?? []
        }

        return Single.zip(collectionsSingle, assetsSingle).map { collections, assets in
            NftAssetCollection(collections: collections, assets: assets)
        }
    }

    func collectionSingle(uid: String) -> Single<NftCollection> {
        provider.collectionSingle(uid: uid).map { [unowned self] response in
            collection(response: response)
        }
    }

    func collectionsSingle() -> Single<[NftCollection]> {
        provider.collectionsSingle().map { [weak self] responses in
            self?.collections(responses: responses) ?? []
        }
    }

    func assetSingle(contractAddress: String, tokenId: String) -> Single<NftAsset> {
        provider.assetSingle(contractAddress: contractAddress, tokenId: tokenId).map { [unowned self] response in
            asset(response: response)
        }
    }

    func assetsSingle(collectionUid: String, cursor: String? = nil) -> Single<PagedNftAssets> {
        provider.assetsSingle(collectionUid: collectionUid, cursor: cursor).map { [unowned self] response in
            PagedNftAssets(
                    assets: assets(responses: response.assets),
                    cursor: response.cursor
            )
        }
    }

    func eventsSingle(collectionUid: String, eventType: NftEvent.EventType?, cursor: String? = nil) -> Single<PagedNftEvents> {
        provider.eventsSingle(collectionUid: collectionUid, eventType: eventType, cursor: cursor).map { [unowned self] response in
            PagedNftEvents(
                    events: events(responses: response.events),
                    cursor: response.cursor
            )
        }
    }

}
