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

    func coinPricesSingle(coinUids: [String], currencyCode: String) -> Single<[CoinPrice]> {
        let currency = currencyCode.lowercased()

        let parameters: Parameters = [
            "ids": coinUids.joined(separator: ","),
            "vs_currencies": currency,
            "include_24hr_change": "true",
            "include_last_updated_at": "true"
        ]

        let context = Context(currency: currency)

        return networkManager.single(url: "\(baseUrl)/simple/price", method: .get, parameters: parameters, context: context)
                .map { (priceMap: [String: PriceResponse]) -> [CoinPrice] in
                    priceMap.compactMap { coinUid, response in
                        response.coinPrice(coinUid: coinUid, currencyCode: currencyCode)
                    }
                }
    }

    func coinPriceChartSingle(coinUid: String, currencyCode: String, periodType: HsPeriodType) -> Single<[ChartPoint]> {
        var parameters: Parameters = [
            "vs_currency": currencyCode.lowercased()
        ]

        let pointInterval: HsPointTimePeriod

        switch periodType {
        case .byPeriod(let timePeriod):
            parameters["days"] = days(timePeriod: timePeriod)
            parameters["interval"] = interval(timePeriod: timePeriod)

            pointInterval = HsChartHelper.pointInterval(timePeriod)
        case .byStartTime(let startTime):
            parameters["days"] = "max"

            pointInterval = HsChartHelper.intervalForAll(genesisTime: startTime)
        }

        return networkManager.single(url: "\(baseUrl)/coins/\(coinUid)/market_chart", method: .get, parameters: parameters)
                .map { (response: MarketChartResponse) -> [ChartPoint] in
                    let points = response.normalized(interval: pointInterval.interval)

                    return points.map { point in
                        ChartPoint(
                                timestamp: point.timestamp,
                                value: Decimal(point.price),
                                extra: [ChartPoint.volume: Decimal(point.volume)]
                        )
                    }
                }
    }

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

    private struct Context: MapContext {
        let currency: String
    }

    public struct PriceResponse: ImmutableMappable {
        public let price: Double?
        public let change24h: Double?
        public let lastUpdatedAt: Double?

        public init(map: Map) throws {
            let currency = (map.context as? Context)?.currency ?? "usd"

            price = try? map.value(currency)
            change24h = try? map.value("\(currency)_24h_change")
            lastUpdatedAt = try? map.value("last_updated_at")
        }

        func coinPrice(coinUid: String, currencyCode: String) -> CoinPrice? {
            guard let price, let lastUpdatedAt else {
                return nil
            }

            let currentTimestamp = Date().timeIntervalSince1970
            let timestamp: TimeInterval

            if currentTimestamp - lastUpdatedAt < 10 * 60 {
                timestamp = currentTimestamp
            } else {
                timestamp = lastUpdatedAt
            }

            return CoinPrice(
                    coinUid: coinUid,
                    currencyCode: currencyCode,
                    value: Decimal(price),
                    diff: change24h.map { Decimal($0) },
                    timestamp: timestamp
            )
        }
    }

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
