import Foundation

public struct NftCollectionStatCharts {
    public let oneDayVolumePoints: [PricePoint]
    public let averagePricePoints: [PricePoint]
    public let floorPricePoints: [PricePoint]
    public let oneDaySalesPoints: [Point]

    public init(oneDayVolumePoints: [PricePoint], averagePricePoints: [PricePoint], floorPricePoints: [PricePoint], oneDaySalesPoints: [Point]) {
        self.oneDayVolumePoints = oneDayVolumePoints
        self.averagePricePoints = averagePricePoints
        self.floorPricePoints = floorPricePoints
        self.oneDaySalesPoints = oneDaySalesPoints
    }

}

extension NftCollectionStatCharts {

    public class PricePoint: Point {
        public let token: Token?

        public init(timestamp: TimeInterval, value: Decimal, token: Token?) {
            self.token = token
            super.init(timestamp: timestamp, value: value)
        }

    }

    public class Point {
        public let timestamp: TimeInterval
        public let value: Decimal

        public init(timestamp: TimeInterval, value: Decimal) {
            self.timestamp = timestamp
            self.value = value
        }

    }

}
