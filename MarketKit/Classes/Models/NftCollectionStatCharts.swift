import Foundation

public struct NftCollectionStatCharts {
    public let oneDayVolumePoints: [PricePoint]
    public let averagePricePoints: [PricePoint]
    public let floorPricePoints: [PricePoint]
    public let oneDaySalesPoints: [Point]
}

extension NftCollectionStatCharts {

    public struct PricePoint {
        public let timestamp: TimeInterval
        public let value: Decimal
        public let token: Token?
    }

    public struct Point {
        public let timestamp: TimeInterval
        public let value: Decimal
    }

}
