import MarketKit

class Singleton {
    static let instance = Singleton()

    let kit: Kit

    init() {
        kit = try! Kit.instance(
            hsApiBaseUrl: "https://api-dev.blocksdecoded.com",
            appVersion: "1.0.0",
            appId: "app-id",
            minLogLevel: .error
        )

        kit.sync()
    }

}
