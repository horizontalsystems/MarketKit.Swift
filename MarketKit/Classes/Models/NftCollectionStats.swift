import Foundation

public struct NftCollectionStats {
    public let count: Int?
    public let ownerCount: Int?
    public let totalSupply: Int
    public let averagePrice1d: NftPrice?
    public let averagePrice7d: NftPrice?
    public let averagePrice30d: NftPrice?
    public let floorPrice: NftPrice?
    public let totalVolume: Decimal?
    public let marketCap: NftPrice?

    public let volumes: [HsTimePeriod: NftPrice]
    public let changes: [HsTimePeriod: Decimal]

    public init(count: Int?, ownerCount: Int?, totalSupply: Int, averagePrice1d: NftPrice?, averagePrice7d: NftPrice?, averagePrice30d: NftPrice?, floorPrice: NftPrice?, totalVolume: Decimal?, marketCap: NftPrice?, volumes: [HsTimePeriod: NftPrice], changes: [HsTimePeriod: Decimal]) {
        self.count = count
        self.ownerCount = ownerCount
        self.totalSupply = totalSupply
        self.averagePrice1d = averagePrice1d
        self.averagePrice7d = averagePrice7d
        self.averagePrice30d = averagePrice30d
        self.floorPrice = floorPrice
        self.totalVolume = totalVolume
        self.marketCap = marketCap
        self.volumes = volumes
        self.changes = changes
    }

}
