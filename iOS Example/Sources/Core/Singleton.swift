import MarketKit

class Singleton {
    static let instance = Singleton()

    let kit: Kit

    init() {
        kit = try! Kit.instance(
            hsApiBaseUrl: "https://api-dev.blocksdecoded.com",
            minLogLevel: .error
        )

        kit.sync()
    }
}
