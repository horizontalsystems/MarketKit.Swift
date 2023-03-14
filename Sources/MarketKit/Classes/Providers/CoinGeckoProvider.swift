import Foundation
import RxSwift
import HsToolKit
import Alamofire
import ObjectMapper

class CoinGeckoProvider {
    private let baseUrl = "https://api.coingecko.com/api/v3"

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    private func days(timePeriod: HsTimePeriod) -> String {
        switch timePeriod {
        case .day1: return "1"
        case .week1: return "7"
        case .week2: return "14"
        case .month1: return "30"
        case .month3: return "90"
        case .month6: return "180"
        case .year1: return "365"
        case .year2: return "730"
        }
    }

    private func interval(timePeriod: HsTimePeriod) -> String {
        switch timePeriod {
        case .day1, .week1, .week2, .month6, .year1, .year2: return ""
        case .month1, .month3: return "daily"
        }
    }

}

extension CoinGeckoProvider {

    func cexVolumesSingle(coinUid: String, currencyCode: String, timePeriod: HsTimePeriod) -> Single<AggregatedChartPoints> {
        let parameters: Parameters = [
            "vs_currency": currencyCode.lowercased(),
            "days": days(timePeriod: timePeriod),
            "interval": interval(timePeriod: timePeriod)
        ]

        return networkManager.single(url: "\(baseUrl)/coins/\(coinUid)/market_chart", method: .get, parameters: parameters)
                .map { (response: MarketChartResponse) -> AggregatedChartPoints in
                    let points = response.normalized(interval: HsChartHelper.pointInterval(timePeriod).interval)

                    var total: Double = 0

                    if let lastPoint = points.last {
                        for point in points {
                            if (lastPoint.timestamp - point.timestamp).remainder(dividingBy: 24 * 60 * 60) == 0 {
                                total += point.volume
                            }
                        }
                    }

                    return AggregatedChartPoints(
                            points: points.map { point in
                                ChartPoint(timestamp: point.timestamp, value: Decimal(point.volume))
                            },
                            aggregatedValue: Decimal(total)
                    )
                }
    }

    func exchangesSingle(limit: Int, page: Int) -> Single<[Exchange]> {
        let parameters: Parameters = [
            "per_page": limit,
            "page": page
        ]

        return networkManager.single(url: "\(baseUrl)/exchanges", method: .get, parameters: parameters)
    }

    func marketTickersSingle(coinId: String) -> Single<CoinGeckoCoinResponse> {
        let parameters: Parameters = [
            "tickers": "true",
            "localization": "false",
            "market_data": "false",
            "community_data": "false",
            "developer_data": "false",
            "sparkline": "false"
        ]

        return networkManager.single(url: "\(baseUrl)/coins/\(coinId)", method: .get, parameters: parameters)
    }

}

extension CoinGeckoProvider {

    public struct MarketChartResponse: ImmutableMappable {
        public let prices: [[Double]]
        public let marketCaps: [[Double]]
        public let totalVolumes: [[Double]]

        public init(map: Map) throws {
            prices = try map.value("prices")
            marketCaps = try map.value("market_caps")
            totalVolumes = try map.value("total_volumes")
        }

        func normalized(interval: TimeInterval) -> [Point] {
            let currenTimestamp = Date().timeIntervalSince1970
            var points = [TimeInterval: Point]()

            for (index, priceArray) in prices.enumerated() {
                guard priceArray.count == 2, totalVolumes.count > index else {
                    return []
                }

                let volumeArray = totalVolumes[index]

                guard volumeArray.count == 2 else {
                    return []
                }

                let timestamp = priceArray[0] / 1000
                let price = priceArray[1]
                let volume = volumeArray[1]

                let resetSecondsTimestamp = Double(Int(timestamp / 60)) * 60
                let normalizedTimestamp = Double(Int((resetSecondsTimestamp - 1) / interval)) * interval + interval

                if normalizedTimestamp < currenTimestamp {
                    points[normalizedTimestamp] = Point(timestamp: normalizedTimestamp, price: price, volume: volume)
                }
            }

            return points.values.sorted { lhsPoint, rhsPoint in lhsPoint.timestamp < rhsPoint.timestamp }
        }

        struct Point {
            let timestamp: TimeInterval
            let price: Double
            let volume: Double
        }
    }

}
