import Foundation
import ObjectMapper
import Alamofire
import HsToolKit

class HsNftProvider {
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

    func topCollections() async throws -> [NftTopCollectionResponse] {
        let parameters: Parameters = [
            "simplified": true
        ]

        return try await networkManager.fetch(url: "\(baseUrl)/v1/nft/collections", parameters: parameters, encoding: encoding, headers: headers)
    }

}

struct NftTopCollectionResponse: ImmutableMappable {
    let blockchainUid: String
    let providerUid: String
    let name: String
    let thumbnailImageUrl: String?
    let floorPrice: Decimal?
    let volume1d: Decimal?
    let change1d: Decimal?
    let volume7d: Decimal?
    let change7d: Decimal?
    let volume30d: Decimal?
    let change30d: Decimal?

    init(map: Map) throws {
        blockchainUid = try map.value("blockchain_uid")
        providerUid = try map.value("opensea_uid")
        name = try map.value("name")
        thumbnailImageUrl = try? map.value("thumbnail_url")
        floorPrice = try? map.value("floor_price", using: Transform.doubleToDecimalTransform)
        volume1d = try? map.value("volume_1d", using: Transform.doubleToDecimalTransform)
        change1d = try? map.value("change_1d", using: Transform.doubleToDecimalTransform)
        volume7d = try? map.value("volume_7d", using: Transform.doubleToDecimalTransform)
        change7d = try? map.value("change_7d", using: Transform.doubleToDecimalTransform)
        volume30d = try? map.value("volume_30d", using: Transform.doubleToDecimalTransform)
        change30d = try? map.value("change_30d", using: Transform.doubleToDecimalTransform)
    }
}
