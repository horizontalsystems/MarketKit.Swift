import HsToolKit
import Foundation

class CoinGeckoChartMapper: IApiMapper {
    private let intervalInSeconds: TimeInterval?

    init(intervalInSeconds: TimeInterval? = nil) {
        self.intervalInSeconds = intervalInSeconds
    }

    private func nearest(timestamp: TimeInterval, truncInterval: TimeInterval) -> TimeInterval {
        let lower = floor(timestamp / truncInterval) * truncInterval
        return (timestamp - lower > truncInterval / 2) ? (lower + truncInterval) : lower
    }

    private func normalize(charts: [ChartPointResponse]) -> [ChartPointResponse] {
        guard let intervalInSeconds = intervalInSeconds else {
            return charts
        }

        var normalized = [TimeInterval: ChartPointResponse]()
        var latestDelta: TimeInterval = 0

        let normalizedInterval: TimeInterval
        let hourInterval: TimeInterval = 60 * 60
        let dayInterval = 24 * hourInterval

        switch intervalInSeconds {
        case 0 ..< hourInterval: normalizedInterval = 60                           // normalize to nearest minute if interval less than day
        case hourInterval ..< dayInterval: normalizedInterval = hourInterval       // normalize to nearest hour if interval from day to
        default: normalizedInterval = dayInterval                                  // normalize to nearest day if other interval
        }

        for point in charts {
            let normalizedInterval = nearest(timestamp: point.timestamp, truncInterval: normalizedInterval)
            let delta = abs(normalizedInterval - point.timestamp)

            if normalized[normalizedInterval] != nil, delta > latestDelta {
                continue
            }

            normalized[normalizedInterval] = point
            latestDelta = delta
        }

        return normalized.sorted(by: { $0.0 < $1.0 }).map { key, point in ChartPointResponse(timestamp: key, value: point.value, volume: point.volume)}
    }

    func map(statusCode: Int, data: Any?) throws -> [ChartPointResponse] {
        var charts = [ChartPointResponse]()

        guard let chartsMap = data as? [String: Any],
              let rates = chartsMap["prices"] as? [[Any]],
              let volumes = chartsMap["total_volumes"] as? [[Any]] else {
            throw NetworkManager.RequestError.emptyResponse(statusCode: statusCode)
        }

        for (index, rateArray) in rates.enumerated() {
            if rateArray.count == 2 && volumes.count >= index, volumes[index].count == 2,
               let timestamp = rateArray[0] as? Int,
               let rate = Decimal(convertibleValue: rateArray[1]),
               let volume = Decimal(convertibleValue: volumes[index][1]) {
                charts.append(ChartPointResponse(timestamp: TimeInterval(timestamp/1000), value: rate, volume: volume))
            }
        }

        return normalize(charts: charts)
    }

}
