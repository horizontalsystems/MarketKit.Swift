import HsToolKit

extension Kit {
    private static let dataDirectoryName = "market-kit"
    private static let databaseFileName = "market-kit"
    private static let hsApiBaseUrl = "http://10.0.1.40:3000/v1"

    public static func instance(minLogLevel: Logger.Level = .error) throws -> Kit {
        let logger = Logger(minLogLevel: minLogLevel)
        let reachabilityManager = ReachabilityManager()
        let storage = try Storage(dataDirectoryUrl: try dataDirectoryUrl(), databaseFileName: databaseFileName)

        let networkManager = NetworkManager(logger: logger)

        let coinManager = CoinManager(storage: storage)
        let hsProvider = HsProvider(baseUrl: hsApiBaseUrl, networkManager: networkManager)
        let coinSyncer = CoinSyncer(hsProvider: hsProvider, coinManager: coinManager)

        return Kit(
                coinManager: coinManager,
                coinSyncer: coinSyncer
        )
    }

    private static func dataDirectoryUrl() throws -> URL {
        let fileManager = FileManager.default

        let url = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(dataDirectoryName, isDirectory: true)

        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        return url
    }

}
