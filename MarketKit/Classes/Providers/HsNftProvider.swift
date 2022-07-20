import Foundation
import RxSwift
import ObjectMapper
import HsToolKit
import Alamofire

class HsNftProvider {
    private let collectionLimit = 300
    private let assetLimit = 50

    private let baseUrl: String
    private let networkManager: NetworkManager
    private let headers: HTTPHeaders?
    private let encoding: ParameterEncoding = URLEncoding(boolEncoding: .literal)

    init(baseUrl: String, networkManager: NetworkManager, apiKey: String?) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager

        headers = apiKey.flatMap { HTTPHeaders([HTTPHeader(name: "apikey", value: $0)]) }
    }

}

extension HsNftProvider {

    func recursiveCollectionsSingle(address: String? = nil, page: Int = 1, allCollections: [NftCollectionResponse] = []) -> Single<[NftCollectionResponse]> {
        collectionsSingle(address: address, page: page).flatMap { [unowned self] collections in
            let allCollections = allCollections + collections

            if collections.count == collectionLimit {
                return recursiveCollectionsSingle(address: address, page: page + 1, allCollections: allCollections)
            } else {
                return Single.just(allCollections)
            }
        }
    }

    func recursiveAssetsSingle(address: String, cursor: String? = nil, allAssets: [NftAssetResponse] = []) -> Single<[NftAssetResponse]> {
        assetsSingle(address: address, cursor: cursor).flatMap { [unowned self] response in
            let allAssets = allAssets + response.assets

            if let cursor = response.cursor {
                return recursiveAssetsSingle(address: address, cursor: cursor, allAssets: allAssets)
            } else {
                return Single.just(allAssets)
            }
        }
    }

    func collectionSingle(uid: String) -> Single<NftCollectionResponse> {
        let parameters: Parameters = [
            "include_stats_chart": true,
        ]

        let request = networkManager.session.request("\(baseUrl)/v1/nft/collection/\(uid)", parameters: parameters, encoding: encoding, headers: headers)
        return networkManager.single(request: request)
    }

    func collectionsSingle(address: String? = nil, page: Int? = nil) -> Single<[NftCollectionResponse]> {
        var parameters: Parameters = [
            "limit": collectionLimit
        ]

        if let address = address {
            parameters["asset_owner"] = address
        }

        if let page = page {
            parameters["page"] = page
        }

        let request = networkManager.session.request("\(baseUrl)/v1/nft/collections", parameters: parameters, encoding: encoding, headers: headers)
        return networkManager.single(request: request)
    }

    func assetSingle(contractAddress: String, tokenId: String) -> Single<NftAssetResponse> {
        let parameters: Parameters = [
            "include_orders": true,
        ]

        let request = networkManager.session.request("\(baseUrl)/v1/nft/asset/\(contractAddress)/\(tokenId)", parameters: parameters, encoding: encoding, headers: headers)
        return networkManager.single(request: request)
    }

    func assetsSingle(address: String? = nil, collectionUid: String? = nil, cursor: String? = nil) -> Single<NftAssetsResponse> {
        var parameters: Parameters = [
            "include_orders": true,
            "limit": assetLimit
        ]

        if let address = address {
            parameters["owner"] = address
        }

        if let collectionUid = collectionUid {
            parameters["collection_uid"] = collectionUid
        }

        if let cursor = cursor {
            parameters["cursor"] = cursor
        }

        let request = networkManager.session.request("\(baseUrl)/v1/nft/assets", parameters: parameters, encoding: encoding, headers: headers)
        return networkManager.single(request: request)
    }

    private func eventsSingle(collectionUid: String?, contractAddress: String?, eventType: NftEvent.EventType?, tokenId: String?, cursor: String?) -> Single<NftEventsResponse> {
        var parameters: Parameters = [:]

        if let collectionUid = collectionUid {
            parameters["collection_uid"] = collectionUid
        }

        if let contractAddress = contractAddress {
            parameters["asset_contract"] = contractAddress
        }

        if let eventType = eventType {
            parameters["event_type"] = eventType.rawValue
        }

        if let tokenId = tokenId {
            parameters["token_id"] = tokenId
        }

        if let cursor = cursor {
            parameters["cursor"] = cursor
        }

        let request = networkManager.session.request("\(baseUrl)/v1/nft/events", parameters: parameters, encoding: encoding, headers: headers)
        return networkManager.single(request: request)
    }

    func collectionEventsSingle(collectionUid: String?, eventType: NftEvent.EventType?, cursor: String?) -> Single<NftEventsResponse> {
        eventsSingle(collectionUid: collectionUid, contractAddress: nil, eventType: eventType, tokenId: nil, cursor: cursor)
    }

    func assetEventsSingle(contractAddress: String?, tokenId: String?, eventType: NftEvent.EventType?, cursor: String?) -> Single<NftEventsResponse> {
        eventsSingle(collectionUid: nil, contractAddress: contractAddress, eventType: eventType, tokenId: tokenId, cursor: cursor)
    }

}

struct NftCollectionResponse: ImmutableMappable {
    let contracts: [NftAssetContractResponse]
    let uid: String
    let name: String
    let description: String?
    let imageUrl: String?
    let featuredImageUrl: String?
    let externalUrl: String?
    let discordUrl: String?
    let twitterUsername: String?
    let stats: NftCollectionStatsResponse
    let statChartPoints: [CollectionStatChartPointResponse]?

    init(map: Map) throws {
        contracts = (try? map.value("asset_contracts")) ?? []
        uid = try map.value("uid")
        name = try map.value("name")
        description = try? map.value("description")
        imageUrl = try? map.value("image_data.image_url")
        featuredImageUrl = try? map.value("image_data.featured_image_url")
        externalUrl = try? map.value("links.external_url")
        discordUrl = try? map.value("links.discord_url")
        twitterUsername = try? map.value("links.twitter_username")
        stats = try map.value("stats")
        statChartPoints = try? map.value("stats_chart")
    }
}

struct NftAssetContractResponse: ImmutableMappable {
    let address: String
    let type: String

    init(map: Map) throws {
        address = try map.value("address")
        type = try map.value("type")
    }
}

struct NftAssetsResponse: ImmutableMappable {
    let cursor: String?
    let assets: [NftAssetResponse]

    init(map: Map) throws {
        cursor = try? map.value("cursor.next")
        assets = try map.value("assets")
    }
}

struct NftAssetResponse: ImmutableMappable {
    let contract: NftAssetContractResponse
    let collectionUid: String
    let tokenId: String
    let name: String?
    let imageUrl: String?
    let imagePreviewUrl: String?
    let description: String?
    let externalLink: String?
    let permalink: String?
    let traits: [NftTraitResponse]
    let lastSale: NftSaleResponse?
    let sellOrders: [NftOrderResponse]
    let orders: [NftOrderResponse]

    init(map: Map) throws {
        contract = try map.value("contract")
        collectionUid = try map.value("collection_uid")
        tokenId = try map.value("token_id")
        name = try? map.value("name")
        imageUrl = try? map.value("image_data.image_url")
        imagePreviewUrl = try? map.value("image_data.image_preview_url")
        description = try? map.value("description")
        externalLink = try? map.value("links.external_link")
        permalink = try? map.value("links.permalink")
        traits = (try? map.value("attributes")) ?? []
        lastSale = try? map.value("markets_data.last_sale")
        sellOrders = (try? map.value("markets_data.sell_orders")) ?? []
        orders = (try? map.value("markets_data.orders")) ?? []
    }
}

struct NftTraitResponse: ImmutableMappable {
    let type: String
    let value: String
    let count: Int

    init(map: Map) throws {
        type = try map.value("trait_type")

        if let value: String = try? map.value("value") {
            self.value = value
        } else if let value: Int = try? map.value("value") {
            self.value = "\(value)"
        } else if let value: Double = try? map.value("value") {
            self.value = "\(value)"
        } else {
            value = ""
        }

        count = try map.value("trait_count")
    }
}

struct NftSaleResponse: ImmutableMappable {
    let totalPrice: Decimal
    let paymentTokenAddress: String

    init(map: Map) throws {
        totalPrice = try map.value("total_price", using: Transform.stringToDecimalTransform)
        paymentTokenAddress = try map.value("payment_token.address")
    }
}

struct NftCollectionStatsResponse: ImmutableMappable {
    let count: Int?
    let ownerCount: Int?
    let totalSupply: Int
    let oneDayChange: Decimal
    let sevenDayChange: Decimal
    let thirtyDayChange: Decimal
    let averagePrice1d: Decimal
    let averagePrice7d: Decimal
    let averagePrice30d: Decimal
    let floorPrice: Decimal?
    let totalVolume: Decimal?
    let marketCap: Decimal
    let oneDayVolume: Decimal
    let sevenDayVolume: Decimal
    let thirtyDayVolume: Decimal

    init(map: Map) throws {
        count = try? map.value("count")
        ownerCount = try? map.value("num_owners")
        totalSupply = try map.value("total_supply")
        totalVolume = try map.value("total_volume", using: Transform.doubleToDecimalTransform)
        marketCap = try map.value("market_cap", using: Transform.doubleToDecimalTransform)
        oneDayChange = try map.value("one_day_change", using: Transform.doubleToDecimalTransform)
        sevenDayChange = try map.value("seven_day_change", using: Transform.doubleToDecimalTransform)
        thirtyDayChange = try map.value("thirty_day_change", using: Transform.doubleToDecimalTransform)
        averagePrice1d = try map.value("one_day_average_price", using: Transform.doubleToDecimalTransform)
        averagePrice7d = try map.value("seven_day_average_price", using: Transform.doubleToDecimalTransform)
        averagePrice30d = try map.value("thirty_day_average_price", using: Transform.doubleToDecimalTransform)
        floorPrice = try? map.value("floor_price", using: Transform.doubleToDecimalTransform)
        oneDayVolume = try map.value("one_day_volume", using: Transform.doubleToDecimalTransform)
        sevenDayVolume = try map.value("seven_day_volume", using: Transform.doubleToDecimalTransform)
        thirtyDayVolume = try map.value("thirty_day_volume", using: Transform.doubleToDecimalTransform)
    }
}

struct NftOrderResponse: ImmutableMappable {
    private static let reusableDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ss", locale: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        return dateFormatter
    }()

    let closingDate: Date
    let currentPrice: Decimal
    let paymentToken: NftPaymentTokenResponse
    let takerAddress: String
    let side: Int
    let v: Int?

    init(map: Map) throws {
        closingDate = try map.value("closing_date", using: DateFormatterTransform(dateFormatter: Self.reusableDateFormatter))
        currentPrice = try map.value("current_price", using: Transform.stringToDecimalTransform)
        paymentToken = try map.value("payment_token_contract")
        takerAddress = try map.value("taker.address")
        side = try map.value("side")
        v = try? map.value("v")
    }
}

struct NftPaymentTokenResponse: ImmutableMappable {
    let address: String
    let decimals: Int
    let ethPrice: Decimal

    init(map: Map) throws {
        address = try map.value("address")
        decimals = try map.value("decimals")
        ethPrice = try map.value("eth_price", using: Transform.stringToDecimalTransform)
    }
}

struct NftEventsResponse: ImmutableMappable {
    let cursor: String?
    let events: [NftEventResponse]

    init(map: Map) throws {
        cursor = try? map.value("cursor.next")
        events = try map.value("events")
    }
}

struct NftEventResponse: ImmutableMappable {
    private static let reusableDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS", locale: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        return dateFormatter
    }()

    let asset: NftAssetResponse
    let type: String
    let date: Date
    let amount: Decimal?
    let paymentToken: NftPaymentTokenResponse?

    init(map: Map) throws {
        asset = try map.value("asset")
        date = try map.value("date", using: DateFormatterTransform(dateFormatter: Self.reusableDateFormatter))
        type = try map.value("type")
        amount = try? map.value("amount", using: Transform.stringToDecimalTransform)
        paymentToken = try? map.value("markets_data.payment_token")
    }
}

struct CollectionStatChartPointResponse: ImmutableMappable {
    let timestamp: TimeInterval
    let oneDayVolume: Decimal?
    let averagePrice: Decimal?
    let floorPrice: Decimal?
    let oneDaySales: Decimal?

    init(map: Map) throws {
        timestamp = try map.value("timestamp")
        oneDayVolume = try? map.value("one_day_volume", using: Transform.stringToDecimalTransform)
        averagePrice = try? map.value("average_price", using: Transform.stringToDecimalTransform)
        floorPrice = try? map.value("floor_price", using: Transform.stringToDecimalTransform)
        oneDaySales = try? map.value("one_day_sales", using: Transform.stringToDecimalTransform)
    }
}
