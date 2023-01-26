import Foundation
import RxSwift

protocol IChartInfoManagerDelegate: AnyObject {
    func didUpdate(chartInfo: ChartInfo, key: ChartInfoKey)
    func didFoundNoChartInfo(key: ChartInfoKey)
}

class ChartManager {
    weak var delegate: IChartInfoManagerDelegate?

    private let coinManager: CoinManager
    private let storage: ChartStorage
    private let hsProvider: HsProvider

    private let indicatorPoints: Int

    init(coinManager: CoinManager, storage: ChartStorage, hsProvider: HsProvider, indicatorPoints: Int) {
        self.coinManager = coinManager
        self.storage = storage
        self.hsProvider = hsProvider
        self.indicatorPoints = indicatorPoints
    }

    private static var utcStartOfToday: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar.startOfDay(for: Date())
    }

    private static func chartInfo(points: [ChartPoint], periodType: HsPeriodType) -> ChartInfo? {
        guard let lastPoint = points.last, let firstPoint = points.first else {
            return nil
        }

        let lastPointTimestamp = TimeInterval(lastPoint.timestamp)

        // visible window for chart
        let startTimestamp: TimeInterval
        let currentTimestamp = Date().timeIntervalSince1970

        let lastPointGap = currentTimestamp - lastPointTimestamp
        switch periodType {
        case .byPeriod(let interval):
            startTimestamp = lastPointTimestamp - interval.range
            // if points not in visible window (too early) just return nil
            if lastPointGap > interval.range {
                return nil
            }
        case .byStartTime: startTimestamp = firstPoint.timestamp
        }


        return ChartInfo(
                points: points,
                startTimestamp: startTimestamp,
                endTimestamp: currentTimestamp,
                expired: lastPointGap > periodType.expiration
        )
    }

    private func storedChartPoints(key: ChartInfoKey) -> [ChartPoint] {
        storage.chartPoints(key: key)
    }

}

extension ChartManager {

    func lastSyncTimestamp(key: ChartInfoKey) -> TimeInterval? {
        storedChartPoints(key: key).last?.timestamp
    }

    func chartPriceStart(coinUid: String) -> Single<TimeInterval> {
        hsProvider.coinPriceChartStart(coinUid: coinUid).map { $0.timestamp }
    }

    func chartInfo(coinUid: String, currencyCode: String, periodType: HsPeriodType) -> ChartInfo? {
        guard let fullCoin = try? coinManager.fullCoins(coinUids: [coinUid]).first else {
            return nil
        }

        let key = ChartInfoKey(coin: fullCoin.coin, currencyCode: currencyCode, periodType: periodType)
        return Self.chartInfo(points: storedChartPoints(key: key), periodType: periodType)
    }

    func chartInfoSingle(coinUid: String, currencyCode: String, periodType: HsPeriodType) -> Single<ChartInfo> {
        guard let fullCoin = try? coinManager.fullCoins(coinUids: [coinUid]).first else {
            return Single.error(Kit.KitError.noChartData)
        }

        return hsProvider
                .coinPriceChartSingle(coinUid: fullCoin.coin.uid, currencyCode: currencyCode, periodType: periodType, indicatorPoints: indicatorPoints)
                .flatMap { chartCoinPriceResponse in
                    let points = chartCoinPriceResponse.map {
                        $0.chartPoint
                    }

                    if let chartInfo = Self.chartInfo(points: points, periodType: periodType) {
                        return Single.just(chartInfo)
                    }

                    return Single.error(Kit.KitError.noChartData)
                }
    }

    func handleUpdated(chartPoints: [ChartPoint], key: ChartInfoKey) {
        let records = chartPoints.map { point in
            ChartPointRecord(
                    coinUid: key.coin.uid,
                    currencyCode: key.currencyCode,
                    periodType: key.periodType,
                    timestamp: point.timestamp,
                    value: point.value,
                    volume: point.extra[ChartPoint.volume]
            )
        }

        storage.deleteChartPoints(key: key)
        storage.save(chartPoints: records)

        if let chartInfo = Self.chartInfo(points: chartPoints, periodType: key.periodType) {
            delegate?.didUpdate(chartInfo: chartInfo, key: key)
        } else {
            delegate?.didFoundNoChartInfo(key: key)
        }
    }

    func handleNoChartPoints(key: ChartInfoKey) {
        delegate?.didFoundNoChartInfo(key: key)
    }

}
