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

    private static func chartInfo(points: [ChartPoint], interval: HsTimePeriod) -> ChartInfo? {
        guard let lastPoint = points.last else {
            return nil
        }

        let lastPointTimestamp = TimeInterval(lastPoint.timestamp)

        // visible window for chart
        let startTimestamp: TimeInterval
        var currentTimestamp = Date().timeIntervalSince1970

        let lastPointGap = currentTimestamp - lastPointTimestamp
        startTimestamp = lastPointTimestamp - interval.range

        // if points not in visible window (too early) just return nil
        guard lastPointGap < interval.range else {
            return nil
        }

        return ChartInfo(
                points: points,
                startTimestamp: startTimestamp,
                endTimestamp: currentTimestamp,
                expired: lastPointGap > interval.expiration
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

    func chartInfo(coinUid: String, currencyCode: String, interval: HsTimePeriod) -> ChartInfo? {
        guard let fullCoin = try? coinManager.fullCoins(coinUids: [coinUid]).first else {
            return nil
        }

        let key = ChartInfoKey(coin: fullCoin.coin, currencyCode: currencyCode, interval: interval)
        return Self.chartInfo(points: storedChartPoints(key: key), interval: interval)
    }

    func chartInfoSingle(coinUid: String, currencyCode: String, interval: HsTimePeriod) -> Single<ChartInfo> {
        guard let fullCoin = try? coinManager.fullCoins(coinUids: [coinUid]).first else {
            return Single.error(Kit.KitError.noChartData)
        }

        let key = ChartInfoKey(coin: fullCoin.coin, currencyCode: currencyCode, interval: interval)
        return hsProvider
                .coinPriceChartSingle(coinUid: fullCoin.coin.uid, currencyCode: currencyCode, interval: interval, indicatorPoints: indicatorPoints)
                .flatMap { chartCoinPriceResponse in
                    let points = chartCoinPriceResponse.map {
                        $0.chartPoint
                    }

                    if let chartInfo = Self.chartInfo(points: points, interval: interval) {
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
                    interval: key.interval,
                    timestamp: point.timestamp,
                    value: point.value,
                    volume: point.extra[ChartPoint.volume]
            )
        }

        storage.deleteChartPoints(key: key)
        storage.save(chartPoints: records)

        if let chartInfo = Self.chartInfo(points: chartPoints, interval: key.interval) {
            delegate?.didUpdate(chartInfo: chartInfo, key: key)
        } else {
            delegate?.didFoundNoChartInfo(key: key)
        }
    }

    func handleNoChartPoints(key: ChartInfoKey) {
        delegate?.didFoundNoChartInfo(key: key)
    }

}
