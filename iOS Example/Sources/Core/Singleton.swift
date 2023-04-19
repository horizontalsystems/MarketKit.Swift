import MarketKit

class Singleton {
    static let instance = Singleton()

    let kit: Kit

    init() {
        kit = try! Kit.instance(
                hsApiBaseUrl: "https://api-dev.blocksdecoded.com",
                hsProviderApiKey: nil,
                minLogLevel: .error
        )

        kit.sync()
    }

}
