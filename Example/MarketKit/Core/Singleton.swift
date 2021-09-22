import MarketKit

class Singleton {
    static let instance = Singleton()

    let kit: Kit

    init() {
        kit = try! Kit.instance(hsApiBaseUrl: "http://10.0.1.32:3000", minLogLevel: .debug)

        kit.sync()
    }

}
