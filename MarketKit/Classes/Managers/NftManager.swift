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

    private func tokenType(address: String) -> TokenType {
        if address == zeroAddress {
            return .native
        } else {
            return .eip20(address: address)
        }
    }

    private func tokenMap(addresses: [String]) -> [String: Token] {
        do {
            var map = [String: Token]()
            let tokenTypes = addresses.map { tokenType(address: $0) }
            let tokens = try coinManager.tokens(queries: tokenTypes.map { TokenQuery(blockchainType: .ethereum, tokenType: $0) })

            for token in tokens {
                switch token.type {
                case .native:
                    map[zeroAddress] = token
                case .eip20(let address):
                    map[address.lowercased()] = token
                default:
                    ()
                }
            }

            return map
        } catch {
            return [:]
        }
    }

    private func nftPrice(token: Token?, value: Decimal?, shift: Bool) -> NftPrice? {
        guard let token = token, let value = value else {
            return nil
        }

        return NftPrice(
                token: token,
                value: shift ? Decimal(sign: .plus, exponent: -token.decimals, significand: value) : value
        )
    }

    private func createNftPrices(values: [HsTimePeriod: Decimal], ethereumToken: Token?) -> [HsTimePeriod: NftPrice] {
        Dictionary<HsTimePeriod, NftPrice>(uniqueKeysWithValues: values.compactMap { key, value in
            guard let nftPrice = nftPrice(token: ethereumToken, value: value, shift: false) else {
                return nil
            }

            return (key, nftPrice)
        })
    }

    private func collection(response: NftCollectionResponse, ethereumToken: Token? = nil) -> NftCollection {
        let ethereumToken = ethereumToken ?? (try? coinManager.token(query: TokenQuery(blockchainType: .ethereum, tokenType: .native)))

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
                stats: collectionStats(response: response.stats, ethereumToken: ethereumToken),
                statCharts: statCharts(statChartPoints: response.statChartPoints, ethereumToken: ethereumToken)
        )
    }

    private func collectionStats(response: NftCollectionStatsResponse, ethereumToken: Token?) -> NftCollectionStats {
        NftCollectionStats(
                count: response.count,
                ownerCount: response.ownerCount,
                totalSupply: response.totalSupply,
                averagePrice1d: nftPrice(token: ethereumToken, value: response.averagePrice1d, shift: false),
                averagePrice7d: nftPrice(token: ethereumToken, value: response.averagePrice7d, shift: false),
                averagePrice30d: nftPrice(token: ethereumToken, value: response.averagePrice30d, shift: false),
                floorPrice: nftPrice(token: ethereumToken, value: response.floorPrice, shift: false),
                totalVolume: response.totalVolume,
                marketCap: nftPrice(token: ethereumToken, value: response.marketCap, shift: false),
                volumes: createNftPrices(values: [
                    .day1: response.oneDayVolume,
                    .week1: response.sevenDayVolume,
                    .month1: response.thirtyDayVolume
                ], ethereumToken: ethereumToken),
                changes: [
                    .day1: response.oneDayChange,
                    .week1: response.sevenDayChange,
                    .month1: response.thirtyDayChange
                ]
        )
    }

    private func statCharts(statChartPoints: [CollectionStatChartPointResponse]?, ethereumToken: Token?) -> NftCollectionStatCharts? {
        guard let statChartPoints = statChartPoints else {
            return nil
        }

        let oneDayVolumePoints = statChartPoints.compactMap { point in point.oneDayVolume.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, token: ethereumToken) } }
        let averagePricePoints = statChartPoints.compactMap { point in point.averagePrice.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, token: ethereumToken) } }
        let floorPricePoints = statChartPoints.compactMap { point in point.floorPrice.map { NftCollectionStatCharts.PricePoint(timestamp: point.timestamp, value: $0, token: ethereumToken) } }
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

        let tokenMap = tokenMap(addresses: addresses)

        return responses.map { response in
            asset(response: response, tokenMap: tokenMap)
        }
    }

    private func asset(response: NftAssetResponse, tokenMap: [String: Token]? = nil) -> NftAsset {
        let map: [String: Token]

        if let tokenMap = tokenMap {
            map = tokenMap
        } else {
            var addresses = [String]()

            if let lastSale = response.lastSale {
                addresses.append(lastSale.paymentTokenAddress)
            }
            for order in response.orders {
                addresses.append(order.paymentToken.address)
            }

            map = self.tokenMap(addresses: addresses)
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
                lastSalePrice: response.lastSale.flatMap { nftPrice(token: map[$0.paymentTokenAddress], value: $0.totalPrice, shift: true) },
                onSale: !response.sellOrders.isEmpty,
                orders: assetOrders(responses: response.orders, tokenMap: map)
        )
    }

    private func assetOrders(responses: [NftOrderResponse], tokenMap: [String: Token]) -> [NftAssetOrder] {
        responses.map { response in
            NftAssetOrder(
                    closingDate: response.closingDate,
                    price: tokenMap[response.paymentToken.address].flatMap { nftPrice(token: $0, value: response.currentPrice, shift: true) },
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

        let tokenMap = tokenMap(addresses: addresses)

        return responses.compactMap { response in
            var amount: NftPrice?

            if let paymentToken = response.paymentToken, let value = response.amount {
                amount = nftPrice(token: tokenMap[paymentToken.address], value: value, shift: true)
            }

            guard let assetResponse = response.asset else {
                return nil
            }

            return NftEvent(
                    asset: asset(response: assetResponse),
                    type: NftEvent.EventType(rawValue: response.type),
                    date: response.date,
                    amount: amount
            )
        }
    }

}

extension NftManager {

    func collections(responses: [NftCollectionResponse]) -> [NftCollection] {
        let ethereumToken = try? coinManager.token(query: TokenQuery(blockchainType: .ethereum, tokenType: .native))

        return responses.map { response in
            collection(response: response, ethereumToken: ethereumToken)
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
        provider.recursiveCollectionsSingle().map { [weak self] responses in
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


    func collectionEventsSingle(collectionUid: String, eventType: NftEvent.EventType?, cursor: String? = nil) -> Single<PagedNftEvents> {
        provider.collectionEventsSingle(collectionUid: collectionUid, eventType: eventType, cursor: cursor).map { [unowned self] response in
            PagedNftEvents(
                    events: events(responses: response.events),
                    cursor: response.cursor
            )
        }
    }

    func assetEventsSingle(contractAddress: String, tokenId: String?, eventType: NftEvent.EventType?, cursor: String? = nil) -> Single<PagedNftEvents> {
        provider.assetEventsSingle(contractAddress: contractAddress, tokenId: tokenId, eventType: eventType, cursor: cursor).map { [unowned self] response in
            PagedNftEvents(
                    events: events(responses: response.events),
                    cursor: response.cursor
            )
        }
    }

}
