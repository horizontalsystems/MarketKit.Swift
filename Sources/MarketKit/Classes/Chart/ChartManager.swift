import Foundation
import RxSwift

class ChartManager {
    private let storage: ChartStorage
    private let hsProvider: HsProvider

    init(storage: ChartStorage, hsProvider: HsProvider) {
        self.storage = storage
        self.hsProvider = hsProvider
    }

    private static func chartInfo(points: [ChartPoint], periodType: HsPeriodType) -> ChartInfo? {
        guard let lastPoint = points.last, let firstPoint = points.first else {
            return nil
        }

        // visible window for chart
        let startTimestamp: TimeInterval
        let currentTimestamp = Date().timeIntervalSince1970
        let lastPointGap = currentTimestamp - lastPoint.timestamp

        switch periodType {
        case .byPeriod(let interval):
            startTimestamp = lastPoint.timestamp - interval.range
            // if points not in visible window (too early) just return nil
            if lastPointGap > interval.range {
                return nil
            }
        case .byStartTime:
            startTimestamp = firstPoint.timestamp
        }

        return ChartInfo(
                points: points,
                startTimestamp: startTimestamp,
                endTimestamp: currentTimestamp,
                expired: lastPointGap > periodType.expiration
        )
    }

}

extension ChartManager {

    func chartPriceStart(coinUid: String) -> Single<TimeInterval> {
        hsProvider.coinPriceChartStart(coinUid: coinUid).map { $0.timestamp }
    }

    func chartInfo(coinUid: String, currencyCode: String, periodType: HsPeriodType) -> ChartInfo? {
        let key = ChartInfoKey(coinUid: coinUid, currencyCode: currencyCode, periodType: periodType)

        guard let points = try? storage.chartPoints(key: key) else {
            return nil
        }

        return Self.chartInfo(points: points, periodType: periodType)
    }

    func chartInfoSingle(coinUid: String, currencyCode: String, periodType: HsPeriodType) -> Single<ChartInfo> {
        hsProvider.coinPriceChartSingle(coinUid: coinUid, currencyCode: currencyCode, periodType: periodType)
                .flatMap { responses in
                    let points = responses.map { $0.chartPoint }

//                    let key = ChartInfoKey(coinUid: coinUid, currencyCode: currencyCode, periodType: periodType)
//                    self.handleFetched(chartPoints: points, key: key)

                    guard let chartInfo = Self.chartInfo(points: points, periodType: periodType) else {
                        return Single.error(Kit.KitError.noChartData)
                    }

                    return Single.just(chartInfo)
                }
    }

    func handleFetched(chartPoints: [ChartPoint], key: ChartInfoKey) {
        let records = chartPoints.map { point in
            ChartPointRecord(
                    coinUid: key.coinUid,
                    currencyCode: key.currencyCode,
                    periodType: key.periodType,
                    timestamp: point.timestamp,
                    value: point.value,
                    volume: point.extra[ChartPoint.volume]
            )
        }

        try? storage.deleteChartPoints(key: key)
        try? storage.save(chartPoints: records)
    }

}
