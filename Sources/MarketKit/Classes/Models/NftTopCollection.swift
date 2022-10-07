import Foundation

public struct NftTopCollection {
    public let blockchainType: BlockchainType
    public let providerUid: String
    public let name: String
    public let thumbnailImageUrl: String?
    public let floorPrice: NftPrice?
    public let volumes: [HsTimePeriod: NftPrice]
    public let changes: [HsTimePeriod: Decimal]
}
