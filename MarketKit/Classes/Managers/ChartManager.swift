import RxSwift

protocol IChartInfoManagerDelegate: AnyObject {
    func didUpdate(chartInfo: ChartInfo, key: ChartInfoKey)
    func didFoundNoChartInfo(key: ChartInfoKey)
}

class ChartManager {
    weak var delegate: IChartInfoManagerDelegate?

    private let storage: ChartStorage
    private let latestRateManager: CoinPriceManager

    init(storage: ChartStorage, latestRateManager: CoinPriceManager) {
        self.storage = storage
        self.latestRateManager = latestRateManager
    }

    private var utcStartOfToday: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar.startOfDay(for: Date())
    }

    private func chartInfo(chartPoints: [ChartPoint], key: ChartInfoKey) -> ChartInfo? {
        guard let lastPoint = chartPoints.last else {
            return nil
        }

        let startTimestamp: TimeInterval
        var endTimestamp = Date().timeIntervalSince1970
        let lastPointDiffInterval = endTimestamp - lastPoint.timestamp

        if key.chartType == .today {
            startTimestamp = utcStartOfToday.timeIntervalSince1970
            let day = 24 * 60 * 60
            endTimestamp = startTimestamp + TimeInterval(day)
        } else {
            startTimestamp = lastPoint.timestamp - key.chartType.rangeInterval
        }

        guard lastPointDiffInterval < key.chartType.rangeInterval else {
            return nil
        }

        guard lastPointDiffInterval < key.chartType.expirationInterval else {
            // expired chart info, current timestamp more than last point
            return ChartInfo(
                    points: chartPoints,
                    startTimestamp: startTimestamp,
                    endTimestamp: endTimestamp,
                    expired: true
            )
        }

        return ChartInfo(
                points: chartPoints,
                startTimestamp: startTimestamp,
                endTimestamp: endTimestamp,
                expired: false
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

    func chartInfo(key: ChartInfoKey) -> ChartInfo? {
        chartInfo(chartPoints: storedChartPoints(key: key), key: key)
    }

    func handleUpdated(chartPoints: [ChartPoint], key: ChartInfoKey) {
        let records = chartPoints.map {
            ChartPoint(coinUid: $0.coinUid,
                    currencyCode: $0.currencyCode,
                    chartType: $0.chartType,
                    timestamp: $0.timestamp,
                    value: $0.value,
                    volume: $0.volume)
        }

        storage.deleteChartPoints(key: key)
        storage.save(chartPoints: records)

        if let chartInfo = chartInfo(chartPoints: chartPoints, key: key) {
            delegate?.didUpdate(chartInfo: chartInfo, key: key)
        } else {
            delegate?.didFoundNoChartInfo(key: key)
        }
    }

    func handleNoChartPoints(key: ChartInfoKey) {
        delegate?.didFoundNoChartInfo(key: key)
    }

}
