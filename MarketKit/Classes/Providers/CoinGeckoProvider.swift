import Foundation
import RxSwift
import HsToolKit
import Alamofire
import ObjectMapper

class CoinGeckoProvider {
    private let baseUrl: String
    private let networkManager: NetworkManager

    init(baseUrl: String, networkManager: NetworkManager) {
        self.baseUrl = baseUrl
        self.networkManager = networkManager
    }

}

extension CoinGeckoProvider {

    func chartPointsSingle(key: ChartInfoKey) -> Single<[ChartPoint]> {
        guard let externalId = key.coin.coinGeckoId else {
            return Single.error(CoinGeckoProvider.CoinGeckoError.noCoinGeckoId)
        }

        let url = "\(baseUrl)/coins/\(externalId)/market_chart?vs_currency=\(key.currencyCode)&days=\(key.chartType.coinGeckoDaysParameter)"
        let request = networkManager.session.request(url, method: .get, encoding: JSONEncoding())

        return networkManager.single(request: request, mapper: CoinGeckoChartMapper(intervalInSeconds: key.chartType.intervalInSeconds))
                .map { pointResponses -> [ChartPointResponse] in
                    guard key.chartType.coinGeckoPointCount <= pointResponses.count, let last = pointResponses.last else {
                        return pointResponses
                    }

                    var nextTs = TimeInterval.infinity

                    let hour4: TimeInterval = 4 * 60 * 60
                    let hour8 = 2 * hour4
                    switch key.chartType.intervalInSeconds {
                    case hour4: nextTs = floor(last.timestamp / hour4) * hour4                          // found valid 4h close time
                    case hour8: nextTs = floor(last.timestamp / hour8) * hour8                          // found valid 8h close time
                    default: ()
                    }

                    var lastPoint: ChartPointResponse?
                    let isAggregate = key.chartType.resource == "histoday"
                    var aggregatedVolume: Decimal = 0

                    var result = [ChartPointResponse]()

                    for point in pointResponses.reversed() {
                        if point.timestamp <= nextTs {                              // we found point with needed timestamp
                            if let lastPoint = lastPoint {                          // if we found new point, we must add last one with aggregated volumes
                                result.append(ChartPointResponse(timestamp: lastPoint.timestamp, value: lastPoint.value, volume: isAggregate ? aggregatedVolume : nil))
                                aggregatedVolume = 0
                            }

                            lastPoint = point                                       // set last point and start aggregate volumes
                            aggregatedVolume += isAggregate ? point.volume ?? 0 : 0
                            nextTs = point.timestamp - key.chartType.intervalInSeconds
                        } else {
                            aggregatedVolume += isAggregate ? point.volume ?? 0 : 0 // just add volume and drop point
                        }
                    }

                    return result.reversed()
                }.map {
                    $0.map {
                        ChartPoint(coinUid: key.coin.uid,
                            currencyCode: key.currencyCode,
                            chartType: key.chartType,
                            timestamp: $0.timestamp,
                            value: $0.value,
                            volume: $0.volume)
                    }
                }
    }

}

extension CoinGeckoProvider {

    enum CoinGeckoError: Error {
        case noCoinGeckoId
    }

}
